import csv
import sys
import re

# ================= CONFIGURATION =================
# Input Files
FILE_LOCAL_DRUGS = 'local_drugs.txt'         # Format: COPY dump (Tabs)
FILE_LOCAL_PATIENTS = 'local_patients.txt'   # Format: COPY dump (Tabs)
FILE_RAW_ENROLLMENTS = 'enrollments_RAW.txt' # Format: COPY dump (Tabs)

FILE_SUPA_DRUGS = 'supa_drugs.csv'           # Format: Standard CSV from Supabase
FILE_SUPA_PATIENTS = 'supa_patients.csv'     # Format: Standard CSV from Supabase

# Output File
OUTPUT_FILE = 'supa_enrollments.csv'

# Column Indexes for RAW COPY Dumps (0-based)
# Enrollments: (id, drug_id, patient_id, ...)
IDX_ENROLL_DRUG_ID = 1
IDX_ENROLL_PATIENT_ID = 2

# Drugs: (id, name, ...)
IDX_LOCAL_DRUG_ID = 0
IDX_LOCAL_DRUG_NAME = 1

# Patients: (id, name, ic_number, ...)
IDX_LOCAL_PATIENT_ID = 0
IDX_LOCAL_PATIENT_IC = 2  # We strictly use index 2 (IC), ignoring index 1 (Name)

# ================= HELPER FUNCTIONS =================

def clean_key(val):
    """
    Standardizes keys for comparison.
    - Removes whitespace
    - Uppercases text
    - For ICs, it removes dashes if they exist, to ensure pure number matching.
    """
    if not val:
        return ""
    # Remove whitespace and dashes (common in ICs)
    clean_val = str(val).strip().replace("-", "")
    return clean_val.upper()

def load_supabase_csv_map(filename, key_col_name, id_col_name='id'):
    """
    Reads a standard CSV from Supabase and returns a dict { Key: ID }
    """
    mapping = {}
    try:
        with open(filename, 'r', encoding='utf-8-sig') as f:
            reader = csv.DictReader(f)
            # check if columns exist
            if key_col_name not in reader.fieldnames:
                print(f"Error: Column '{key_col_name}' not found in {filename}. Available: {reader.fieldnames}")
                sys.exit(1)
                
            for row in reader:
                key = clean_key(row[key_col_name])
                if key:
                    mapping[key] = row[id_col_name]
        print(f"Loaded {len(mapping)} records from {filename} (using {key_col_name})")
        return mapping
    except FileNotFoundError:
        print(f"Error: Could not find {filename}")
        sys.exit(1)

def load_local_dump_map(filename, id_idx, key_idx):
    """
    Reads a Postgres COPY dump (Tab separated) and returns { ID: Key }
    """
    mapping = {}
    try:
        with open(filename, 'r', encoding='utf-8') as f:
            for line in f:
                if line.startswith('COPY') or line.startswith('\\.') or not line.strip():
                    continue
                
                parts = line.split('\t')
                if len(parts) > max(id_idx, key_idx):
                    local_id = parts[id_idx].strip()
                    # We grab the key (IC or Drug Name) and clean it immediately
                    match_value = clean_key(parts[key_idx])
                    mapping[local_id] = match_value
        print(f"Loaded {len(mapping)} records from {filename}")
        return mapping
    except FileNotFoundError:
        print(f"Error: Could not find {filename}")
        sys.exit(1)

# ================= MAIN LOGIC =================

def process_migration():
    print("--- 1. Loading Mappings ---")
    
    # 1. Load Supabase Data (Target IDs)
    # Drugs still match by Name (Hope no special chars here, otherwise we need to clean them too)
    supa_drug_map = load_supabase_csv_map(FILE_SUPA_DRUGS, 'name')
    
    # Patients STRICTLY match by 'ic_number'
    supa_patient_map = load_supabase_csv_map(FILE_SUPA_PATIENTS, 'ic_number')

    # 2. Load Local Data (Source References)
    # Drugs: Old ID -> Name
    local_drug_map = load_local_dump_map(FILE_LOCAL_DRUGS, IDX_LOCAL_DRUG_ID, IDX_LOCAL_DRUG_NAME)
    
    # Patients: Old ID -> IC Number (Skipping Name entirely)
    local_patient_map = load_local_dump_map(FILE_LOCAL_PATIENTS, IDX_LOCAL_PATIENT_ID, IDX_LOCAL_PATIENT_IC)

    print("\n--- 2. Processing Enrollments ---")
    
    success_count = 0
    skipped_count = 0
    
    with open(FILE_RAW_ENROLLMENTS, 'r', encoding='utf-8') as infile, \
         open(OUTPUT_FILE, 'w', newline='', encoding='utf-8') as outfile:
        
        headers = [
            'drug_id', 'patient_id', 'prescription_start_date', 'prescription_end_date',
            'latest_refill_date', 'spub', 'remarks', 'cost_per_year', 'is_active',
            'created_at', 'updated_at', 'dose_per_day', 'cost_per_day'
        ]
        writer = csv.writer(outfile)
        writer.writerow(headers)

        for line in infile:
            if line.startswith('COPY') or line.startswith('\\.') or not line.strip():
                continue

            cols = line.strip().split('\t')
            
            if len(cols) < 14: 
                print(f"Skipping malformed line: {line[:30]}...")
                continue

            old_drug_id = cols[IDX_ENROLL_DRUG_ID]
            old_patient_id = cols[IDX_ENROLL_PATIENT_ID]

            # --- RESOLVE DRUG ---
            # Old ID -> Name -> New ID
            drug_name = local_drug_map.get(old_drug_id)
            # Note: We clean the drug name from map just in case before looking up
            new_drug_id = supa_drug_map.get(drug_name) if drug_name else None

            # --- RESOLVE PATIENT (VIA IC) ---
            # Old ID -> IC Number -> New ID
            patient_ic = local_patient_map.get(old_patient_id)
            new_patient_id = supa_patient_map.get(patient_ic) if patient_ic else None

            if not new_drug_id or not new_patient_id:
                # Debugging info
                missing = []
                if not new_drug_id: 
                    missing.append(f"DrugID {old_drug_id} (Name: '{drug_name}')")
                if not new_patient_id: 
                    missing.append(f"PatientID {old_patient_id} (IC: '{patient_ic}')")
                
                print(f"Skipping Row: {', '.join(missing)} not found in Supabase.")
                skipped_count += 1
                continue

            # Write clean row
            clean_cols = [c if c != '\\N' else '' for c in cols]
            
            row_to_write = [
                new_drug_id,          
                new_patient_id,       
                clean_cols[3],        # start_date
                clean_cols[4],        # end_date
                clean_cols[5],        # refill_date
                clean_cols[6],        # spub
                clean_cols[7],        # remarks
                clean_cols[8],        # cost_year
                clean_cols[9],        # is_active
                clean_cols[10],       # created_at
                clean_cols[11],       # updated_at
                clean_cols[12],       # dose
                clean_cols[13]        # cost_day
            ]
            
            writer.writerow(row_to_write)
            success_count += 1

    print("\n--- Summary ---")
    print(f"Successfully processed: {success_count}")
    print(f"Skipped due to missing references: {skipped_count}")
    print(f"Output generated: {OUTPUT_FILE}")

if __name__ == "__main__":
    process_migration()