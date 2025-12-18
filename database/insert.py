def convert_line(line):
    parts = line.strip().split(",")

    # Skip empty or invalid lines
    if len(parts) != 5:
        return None

    id_value = parts[0]
    string_values = parts[1:]

    return f"({id_value}, " + ",".join(f"'{v}'" for v in string_values) + ")"


input_file = "insert.txt"
output_file = "insert2.txt"

rows = []

with open(input_file, "r", encoding="utf-8") as infile:
    for line in infile:
        converted = convert_line(line)
        if converted:
            rows.append(converted)

with open(output_file, "w", encoding="utf-8") as outfile:
    outfile.write(
        "INSERT INTO public.patients "
        "(id, name, ic_number, created_at, updated_at) VALUES\n"
    )
    outfile.write(",\n".join(rows))
    outfile.write(";\n")

print("SQL file generated successfully.")
