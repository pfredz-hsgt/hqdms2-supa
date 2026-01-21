import { supabase } from '../supabaseClient';
import * as XLSX from 'xlsx';

// Helper for error handling
const handleError = (error) => {
  console.error('Supabase API Error:', error);
  throw error;
};

// --- Drugs API ---
export const drugsAPI = {
  getAll: async () => {
    const { data, error } = await supabase
      .from('drugs')
      .select('*, departments(name), enrollments(count)')
      .order('name');

    if (error) handleError(error);

    // Transform data to match previous API structure
    return {
      data: data.map(drug => ({
        ...drug,
        department_name: drug.departments?.name,
        current_active_patients: drug.enrollments?.[0]?.count || 0 // Note: this count might need adjustment if logic requires filtering active only in the count
      }))
    };
  },

  getById: async (id) => {
    const { data, error } = await supabase
      .from('drugs')
      .select('*, departments(name)')
      .eq('id', id)
      .single();

    if (error) handleError(error);
    return { data: { ...data, department_name: data.departments?.name } };
  },

  create: async (drugData) => {
    const { data, error } = await supabase.from('drugs').insert([drugData]).select().single();
    if (error) handleError(error);
    return { data };
  },

  update: async (id, drugData) => {
    const { data, error } = await supabase.from('drugs').update(drugData).eq('id', id).select().single();
    if (error) handleError(error);
    return { data };
  },

  delete: async (id) => {
    const { error } = await supabase.from('drugs').delete().eq('id', id);
    if (error) handleError(error);
    return { data: { message: 'Drug deleted successfully' } };
  },

  getQuotaStatus: async (id) => {
    // This requires aggregation. We can do two queries or one with rpc if available.
    // Client side aggregation approach:
    const { data: drug, error: drugError } = await supabase.from('drugs').select('name, quota_number').eq('id', id).single();
    if (drugError) handleError(drugError);

    const { count, error: countError } = await supabase
      .from('enrollments')
      .select('*', { count: 'exact', head: true })
      .eq('drug_id', id)
      .eq('is_active', true);

    if (countError) handleError(countError);

    return {
      data: {
        name: drug.name,
        quota_number: drug.quota_number,
        active_patients: count,
        available_slots: drug.quota_number - count
      }
    };
  }
};

// --- Patients API ---
export const patientsAPI = {
  getAll: async (search) => {
    let query = supabase.from('patients').select('*').order('name');
    if (search) {
      query = query.or(`name.ilike.%${search}%,ic_number.ilike.%${search}%`);
    }
    const { data, error } = await query;
    if (error) handleError(error);
    return { data };
  },

  getById: async (id) => {
    const { data, error } = await supabase.from('patients').select('*').eq('id', id).single();
    if (error) handleError(error);
    return { data };
  },

  create: async (patientData) => {
    const { data, error } = await supabase.from('patients').insert([patientData]).select().single();
    if (error) handleError(error);
    return { data };
  },

  update: async (id, patientData) => {
    const { data, error } = await supabase.from('patients').update(patientData).eq('id', id).select().single();
    if (error) handleError(error);
    return { data };
  },

  delete: async (id) => {
    const { error } = await supabase.from('patients').delete().eq('id', id);
    if (error) handleError(error);
    return { data: { message: 'Patient deleted successfully' } };
  },

  getEnrollments: async (id) => {
    const { data, error } = await supabase
      .from('enrollments')
      .select(`
            *,
            drugs (name, department_id, departments(name))
        `)
      .eq('patient_id', id)
      .order('created_at', { ascending: false });
    if (error) handleError(error);

    return {
      data: data.map(e => ({
        ...e,
        drug_name: e.drugs?.name,
        department_name: e.drugs?.departments?.name
      }))
    };
  }
};

// --- Enrollments API ---
export const enrollmentsAPI = {
  getAll: async (params = {}) => {
    let query = supabase
      .from('enrollments')
      .select(`
        *,
        patients (name, ic_number),
        drugs (name, department_id),
        departments:drugs(departments(name)) 
      `) // Nested join via drugs
      .order('created_at', { ascending: false });

    // Note: departments:drugs(departments(name)) is a bit tricky in Supabase syntax if relations aren't named
    // Alternatively we fetch flat and join in JS or fix relation naming.
    // Let's assume standard relation names.
    // Actually easier to just select *, patients(*), drugs(*, departments(*))

    // Applying Filters
    if (params.drug_id) query = query.eq('drug_id', params.drug_id);
    if (params.patient_id) query = query.eq('patient_id', params.patient_id);
    if (params.active_only === 'true') query = query.eq('is_active', true);
    if (params.active_only === 'false') query = query.eq('is_active', false);

    // Search is harder with joins in Supabase directly unless we use flattening.
    // For now we might ignore search on server side if not critical or fetch more and filter client side.
    // But let's try strict filtering if possible.

    const { data, error } = await query;
    if (error) handleError(error);

    // Client side filtering for search if necessary
    let result = data.map(e => ({
      ...e,
      patient_name: e.patients?.name,
      ic_number: e.patients?.ic_number,
      drug_name: e.drugs?.name,
      department_name: e.drugs?.departments?.name // This path depends on how Supabase returns deeper joins
    }));

    if (params.search) {
      const term = params.search.toLowerCase();
      result = result.filter(r =>
        r.patient_name?.toLowerCase().includes(term) ||
        r.ic_number?.toLowerCase().includes(term)
      );
    }

    return { data: result };
  },

  getById: async (id) => {
    const { data, error } = await supabase
      .from('enrollments')
      .select(`*, patients(name, ic_number), drugs(name, department_id, departments(name))`)
      .eq('id', id)
      .single();
    if (error) handleError(error);

    return {
      data: {
        ...data,
        patient_name: data.patients?.name,
        ic_number: data.patients?.ic_number,
        drug_name: data.drugs?.name,
        department_name: data.drugs?.departments?.name
      }
    };
  },

  create: async (data) => {
    // 1. Check Quota - handled by UI or optimistically. 
    // We can double check here using getQuotaStatus logic if we want strict enforcement.
    // For now, simple insert.
    const { data: result, error } = await supabase.from('enrollments').insert([{
      ...data,
      cost_per_year: data.cost_per_day ? data.cost_per_day * 365 : 0 // Calculate logic moved here
    }]).select().single();

    if (error) handleError(error);
    return { data: result };
  },

  update: async (id, data) => {
    const updateData = { ...data };
    if (updateData.cost_per_day !== undefined) {
      updateData.cost_per_year = updateData.cost_per_day ? updateData.cost_per_day * 365 : 0;
    }

    const { data: result, error } = await supabase.from('enrollments').update(updateData).eq('id', id).select().single();
    if (error) handleError(error);
    return { data: result };
  },

  delete: async (id) => {
    const { error } = await supabase.from('enrollments').delete().eq('id', id);
    if (error) handleError(error);
    return { data: { message: 'Enrollment deleted successfully' } };
  },

  // Custom Logic moved to Client
  getPotentialDefaulters: async () => {
    // Fetch ALL active enrollments and filter in JS
    const { data, error } = await supabase
      .from('enrollments')
      .select(`
         *,
         patients(name, ic_number),
         drugs(name, department_id, departments(name))
       `)
      .eq('is_active', true);

    if (error) handleError(error);

    const now = new Date();
    const defaulters = data.filter(e => {
      if (e.spub) return false; // Ignore SPUB for basic check or apply custom SPUB logic
      if (!e.latest_refill_date) return false; // Or should this count?

      const refillDate = new Date(e.latest_refill_date);
      const daysSince = (now - refillDate) / (1000 * 60 * 60 * 24);

      return daysSince > 180; // 6 months
    }).map(e => ({
      ...e,
      patient_name: e.patients?.name,
      ic_number: e.patients?.ic_number,
      drug_name: e.drugs?.name,
      department_name: e.drugs?.departments?.name,
      days_since_refill: Math.floor((new Date() - new Date(e.latest_refill_date)) / (1000 * 60 * 60 * 24))
    }));

    return { data: defaulters };
  },

  moveToDefaulter: async (id, data) => {
    // 1. Get enrollment details first
    const { data: enrollment, error: fetchError } = await supabase
      .from('enrollments')
      .select('*, patients(name), drugs(name)')
      .eq('id', id)
      .single();

    if (fetchError) handleError(fetchError);

    // 2. Insert into defaulters table
    const daysSince = enrollment.latest_refill_date
      ? Math.floor((new Date() - new Date(enrollment.latest_refill_date)) / (1000 * 60 * 60 * 24))
      : 0;

    const { error: insertError } = await supabase.from('defaulters').insert([{
      enrollment_id: id,
      drug_id: enrollment.drug_id,
      patient_id: enrollment.patient_id,
      last_refill_date: enrollment.latest_refill_date,
      days_since_refill: daysSince,
      remarks: data.remarks || `Moved to defaulter list on ${new Date().toISOString().split('T')[0]}`
    }]);

    if (insertError) handleError(insertError);

    // 3. Deactivate enrollment
    const { error: updateError } = await supabase
      .from('enrollments')
      .update({ is_active: false })
      .eq('id', id)
      .select()
      .single();

    if (updateError) handleError(updateError);

    return { data: { message: 'Patient moved to defaulter list successfully' } };
  },

  updateRefill: async (id, payload) => {
    const { data, error } = await supabase
      .from('enrollments')
      .update({ latest_refill_date: payload.latest_refill_date })
      .eq('id', id)
      .select()
      .single();
    if (error) handleError(error);
    return { data };
  },

  deactivate: async (id, payload) => {
    const { data, error } = await supabase
      .from('enrollments')
      .update({ is_active: false, remarks: payload.reason }) // Appending reason to remarks logic might need to be done in JS first if we want to keep old remarks
      .eq('id', id)
      .select()
      .single();
    if (error) handleError(error);
    return { data };
  },

  getYearlyCosts: async (params = {}) => {
    // 1. Fetch all ACTIVE enrollments with relations
    let query = supabase
      .from('enrollments')
      .select(`
        *,
        patients (name, ic_number),
        drugs (name, department_id, departments(name))
      `)
      .eq('is_active', true);

    if (params.department_id) {
      // Filter by department (requires filtering on joined table, which Supabase supports if inner join, 
      // but simpler to fetch all active and filter in JS for small datasets or use specific syntax)
      // For now, let's filter in JS to be safe and simple given the join structure.
    }

    const { data: rawData, error } = await query;
    if (error) handleError(error);

    let enrollments = rawData.map(e => {
      const costPerDay = parseFloat(e.cost_per_day || 0);
      const yearCost = costPerDay * 365;

      return {
        ...e,
        patient_name: e.patients?.name,
        ic_number: e.patients?.ic_number,
        drug_name: e.drugs?.name,
        department_name: e.drugs?.departments?.name,
        department_id: e.drugs?.department_id,
        calculated_yearly_cost: yearCost
      };
    });

    // 2. Filter by Department if requested
    if (params.department_id) {
      enrollments = enrollments.filter(e => e.department_id === parseInt(params.department_id));
    }

    // 3. Aggregate Data
    const summary = {
      totalCost: 0,
      totalEnrollments: enrollments.length,
      activeEnrollments: enrollments.length,
      averageCostPerEnrollment: 0
    };

    const departmentTotals = {};

    enrollments.forEach(e => {
      summary.totalCost += e.calculated_yearly_cost;

      const deptName = e.department_name || 'Unknown';
      if (!departmentTotals[deptName]) {
        departmentTotals[deptName] = { total: 0, count: 0 };
      }
      departmentTotals[deptName].total += e.calculated_yearly_cost;
      departmentTotals[deptName].count += 1;
    });

    if (summary.totalEnrollments > 0) {
      summary.averageCostPerEnrollment = summary.totalCost / summary.totalEnrollments;
    }

    return {
      data: {
        summary,
        departmentTotals,
        enrollments
      }
    };
  }
};

// --- Departments API ---
export const departmentsAPI = {
  getAll: async () => {
    // Fetch departments
    const { data: departments, error: deptError } = await supabase
      .from('departments')
      .select('*')
      .order('name');

    if (deptError) handleError(deptError);

    // Fetch all drugs to count per department
    const { data: drugs, error: drugsError } = await supabase
      .from('drugs')
      .select('id, department_id');

    if (drugsError) handleError(drugsError);

    // Fetch all active enrollments to count per department
    const { data: enrollments, error: enrollError } = await supabase
      .from('enrollments')
      .select('drug_id')
      .eq('is_active', true);

    if (enrollError) handleError(enrollError);

    // Create a map of drug_id to department_id
    const drugToDept = {};
    const drugCountByDept = {};

    drugs.forEach(drug => {
      drugToDept[drug.id] = drug.department_id;
      drugCountByDept[drug.department_id] = (drugCountByDept[drug.department_id] || 0) + 1;
    });

    // Count enrollments per department
    const enrollmentCountByDept = {};
    enrollments.forEach(enrollment => {
      const deptId = drugToDept[enrollment.drug_id];
      if (deptId) {
        enrollmentCountByDept[deptId] = (enrollmentCountByDept[deptId] || 0) + 1;
      }
    });

    // Attach counts to departments
    const enrichedDepartments = departments.map(dept => ({
      ...dept,
      drug_count: drugCountByDept[dept.id] || 0,
      total_enrollments: enrollmentCountByDept[dept.id] || 0
    }));

    return { data: enrichedDepartments };
  },

  getById: async (id) => {
    const { data, error } = await supabase.from('departments').select('*').eq('id', id).single();
    if (error) handleError(error);
    return { data };
  },

  create: async (data) => {
    const { data: result, error } = await supabase.from('departments').insert([data]).select().single();
    if (error) handleError(error);
    return { data: result };
  },

  update: async (id, data) => {
    const { data: result, error } = await supabase.from('departments').update(data).eq('id', id).select().single();
    if (error) handleError(error);
    return { data: result };
  },

  delete: async (id) => {
    const { error } = await supabase.from('departments').delete().eq('id', id);
    if (error) handleError(error);
    return { data: { message: 'Department deleted successfully' } };
  },

  getSummary: async (id) => {
    // Aggregate client side
    const { data, error } = await supabase
      .from('drugs')
      .select('id, enrollments(count)')
      .eq('department_id', id);

    if (error) handleError(error);

    const totalDrugs = data.length;
    const totalPatients = data.reduce((acc, drug) => acc + (drug.enrollments?.[0]?.count || 0), 0);

    return { data: { totalDrugs, totalPatients } };
  }
};

// --- Reports API ---
export const reportsAPI = {
  getDashboard: async () => {
    // We need to fetch counts.
    // Supabase .count() is useful here.

    const getCount = async (table, filter) => {
      let q = supabase.from(table).select('*', { count: 'exact', head: true });
      if (filter) q = q.match(filter);
      const { count } = await q;
      return count;
    };

    try {
      const today = new Date().toISOString().split('T')[0];

      // Run independent queries in parallel
      const [
        totalDepts,
        totalDrugs,
        totalPatients,
        activeEnrollments,
        drugsData,
        activeCostsData,
        recentRefillsData,
        defaultersResult
      ] = await Promise.all([
        getCount('departments'),
        getCount('drugs'),
        getCount('patients'),
        getCount('enrollments', { is_active: true }),
        // For total quota sum
        supabase.from('drugs').select('quota_number'),
        // For total annual cost sum
        supabase.from('enrollments').select('cost_per_day').eq('is_active', true),
        // For recent refills count
        supabase.from('enrollments').select('*', { count: 'exact', head: true }).eq('latest_refill_date', today),
        // For potential defaulters count
        enrollmentsAPI.getPotentialDefaulters()
      ]);

      // Calculate sums
      const totalQuota = drugsData.data?.reduce((sum, d) => sum + (d.quota_number || 0), 0) || 0;
      const totalAnnualCost = activeCostsData.data?.reduce((sum, e) => sum + ((e.cost_per_day || 0) * 365), 0) || 0;

      return {
        data: {
          total_departments: totalDepts,
          total_drugs: totalDrugs,
          total_patients: totalPatients,
          active_enrollments: activeEnrollments,
          total_quota: totalQuota,
          total_annual_cost: totalAnnualCost,
          recent_refills: recentRefillsData.count || 0,
          potential_defaulters: defaultersResult.data?.length || 0
        }
      };
    } catch (error) {
      console.error('Error fetching dashboard data:', error);
      return {
        data: {
          total_departments: 0,
          total_drugs: 0,
          total_patients: 0,
          active_enrollments: 0,
          total_quota: 0,
          total_annual_cost: 0,
          recent_refills: 0,
          potential_defaulters: 0
        }
      };
    }
  },

  getQuotaUtilization: async (params = {}) => {
    // 1. Fetch all drugs with department info
    let drugsQuery = supabase.from('drugs').select('*, departments(name)');

    if (params.department_id) {
      drugsQuery = drugsQuery.eq('department_id', params.department_id);
    }

    const { data: drugs, error: drugsError } = await drugsQuery;
    if (drugsError) handleError(drugsError);

    // 2. Fetch all active enrollments to count them
    // Note: A more efficient way would be to group by drug_id in SQL if using RPC, 
    // but here we do simple client aggregation.
    const { data: enrollments, error: enrollError } = await supabase
      .from('enrollments')
      .select('drug_id')
      .eq('is_active', true);

    if (enrollError) handleError(enrollError);

    // Count enrollments per drug
    const enrollmentCounts = {};
    enrollments.forEach(e => {
      enrollmentCounts[e.drug_id] = (enrollmentCounts[e.drug_id] || 0) + 1;
    });

    // 3. Construct report data
    const reportData = drugs.map(drug => {
      const activeCount = enrollmentCounts[drug.id] || 0;
      const utilization = drug.quota_number > 0 ? (activeCount / drug.quota_number) * 100 : 0;

      // Determine status
      let status = 'LOW';
      if (activeCount >= drug.quota_number) status = 'FULL';
      else if (utilization >= 90) status = 'HIGH';
      else if (utilization >= 75) status = 'MEDIUM';

      return {
        department_name: drug.departments?.name,
        drug_name: drug.name,
        quota_number: drug.quota_number,
        active_patients: activeCount,
        available_slots: Math.max(0, drug.quota_number - activeCount),
        utilization_percentage: Math.round(utilization),
        status
      };
    });

    return { data: reportData };
  },

  getDefaulters: async (params = {}) => {
    // Reuse logic from enrollmentsAPI.getPotentialDefaulters but apply department filter
    const { data: defaulters } = await enrollmentsAPI.getPotentialDefaulters();

    let result = defaulters;
    if (params.department_id) {
      result = result.filter(d => d.drugs?.department_id === parseInt(params.department_id));
    }

    return { data: result };
  },

  getCostAnalysis: async (params = {}) => {
    // Analyze active enrollments for cost distribution
    // Similar to getYearlyCosts but grouped by drug/department with different stats

    const { data: rawData } = await enrollmentsAPI.getYearlyCosts({ ...params });
    // Reuse getYearlyCosts because it already fetches active enrollments and calculates yearly costs!
    // We just need to regroup the 'enrollments' array it returns.

    const enrollments = rawData.enrollments; // These are active enrollments

    // Group by Drug ID
    const drugStats = {};

    enrollments.forEach(e => {
      const drugId = e.drug_id;
      if (!drugStats[drugId]) {
        drugStats[drugId] = {
          department_name: e.department_name,
          drug_name: e.drug_name,
          patient_count: 0,
          total_annual_cost: 0,
          unit_price: e.cost_per_day // Assumption: cost per day is proxy for unit price or we take avg
        };
      }
      drugStats[drugId].patient_count++;
      drugStats[drugId].total_annual_cost += e.calculated_yearly_cost;
    });

    const reportData = Object.values(drugStats).map(stat => ({
      ...stat,
      avg_cost_per_patient: stat.patient_count > 0 ? stat.total_annual_cost / stat.patient_count : 0
    }));

    return { data: reportData };
  },

  exportExcel: async (params) => {
    // Fetch data based on report type
    // This is a simplified version. For full fidelity we'd match the exact SQL logic from the backend.

    let data = [];
    let filename = 'report';

    if (params.report_type === 'all_enrollments') {
      const { data: raw } = await supabase
        .from('enrollments')
        .select(`*, patients(name, ic_number), drugs(name, departments(name))`);

      data = raw.map(e => ({
        'Department': e.drugs?.departments?.name,
        'Drug Name': e.drugs?.name,
        'Patient Name': e.patients?.name,
        'IC Number': e.patients?.ic_number,
        'Start Date': e.prescription_start_date,
        'Annual Cost': e.cost_per_year
      }));
      filename = 'enrollments_export';
    }

    // Generate Worksheet
    const ws = XLSX.utils.json_to_sheet(data);
    const wb = XLSX.utils.book_new();
    XLSX.utils.book_append_sheet(wb, ws, "Report");

    // Write to buffer and trigger download
    XLSX.writeFile(wb, `${filename}.xlsx`);

    // We don't return data to the caller in the same way, or we return a success status
    return { data: { message: 'Download started' } };
  }
};

// --- Settings API (Supabase Integration) ---
// Using a 'settings' table or similar. If not exists, we use local state or a meta table.
// Assuming 'settings' table exists with single row or key-value.
export const settingsAPI = {
  get: async () => {
    const { data, error } = await supabase.from('settings').select('*').single();
    if (error) {
      console.error('Settings fetch error:', error);
      // Return defaults instead of empty object to prevent switches showing false
      return {
        data: {
          allowNewEnrollments: true,
          allowNewDrugs: true,
          allowNewDepartments: true,
          allowNewPatients: true
        }
      };
    }
    return { data };
  },
  update: async (data) => {
    // Upsert
    const { data: result, error } = await supabase.from('settings').upsert({ id: 1, ...data }).select().single();
    if (error) handleError(error);
    return { data: result };
  }
};

// --- Auth API (Compat layer) ---
export const authAPI = {
  login: async (creds) => {
    // This is now handled by AuthContext using supabase.auth directly, 
    // but if we keep this for compatibility:
    const { data, error } = await supabase.auth.signInWithPassword({
      email: creds.email,
      password: creds.password
    });
    if (error) throw error;
    return { data: { success: true, user: data.user, session: data.session } };
  },

  register: async (values) => {
    const { data, error } = await supabase.auth.signUp({
      email: values.email,
      password: values.password,
      options: {
        data: {
          name: values.name,
          ic_number: values.ic_number // storing as metadata
        }
      }
    });
    if (error) throw error;
    return { data: { success: true, user: data.user } };
  },

  resetPassword: async (values) => {
    const { error } = await supabase.auth.resetPasswordForEmail(values.email);
    if (error) throw error;
    return { data: { success: true } };
  }
};

const api = {
  drugsAPI,
  patientsAPI,
  enrollmentsAPI,
  departmentsAPI,
  reportsAPI,
  settingsAPI,
  authAPI
};

export default api;
