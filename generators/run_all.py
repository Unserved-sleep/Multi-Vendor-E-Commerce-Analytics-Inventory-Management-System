import subprocess

files=[

"01_reference_data.py",
"02_catalog.py",
"03_inventory.py",
"04_orders.py",
"05_payments.py",
"06_engagement.py",
"07_returns.py"
]

for f in files:

    subprocess.run([
        "python",
        f
    ])