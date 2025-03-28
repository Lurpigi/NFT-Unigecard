import csv
import json
import os

csv_file = "unigecard/metadati.csv" 

output_dir = "unigecard/metadati"
os.makedirs(output_dir, exist_ok=True)


with open(csv_file, mode='r', encoding='utf-8-sig') as file:
    reader = csv.DictReader(file)

    print(reader.fieldnames)
    
    for row in reader:
        data = {
            "id": int(row["Numero"]),
            "name": row["personaggio"],
            "image": "",
            "description": row["Descrizione"],
            "attributes": [
                {"trait_type": "illustratore", "value": row["illustratore"]},
                {"trait_type": "tipo", "value": row["tipo"]}
            ]
        }
        
        json_file = os.path.join(output_dir, f"{row['Numero']}.json")
        
        with open(json_file, mode='w', encoding='utf-8') as json_f:
            json.dump(data, json_f, indent=2, ensure_ascii=False)

print("Finito!")
