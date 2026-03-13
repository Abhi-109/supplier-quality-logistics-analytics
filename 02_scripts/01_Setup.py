import os
import sys

# --- TASK 1: AUTOMATED FOLDER INITIALIZATION ---
def initialize_workspace():
    folders = [
        '01_raw_data',
        '02_scripts',
        '03_processed_data',
        '04_visualizations',
        '05_corporate_governance'
    ]
    
    print("🚀 Initializing Enterprise Workspace...")
    for folder in folders:
        if not os.path.exists(folder):
            os.makedirs(folder)
            print(f"Created: {folder}")
        else:
            print(f"Already Exists: {folder}")

# --- TASK 2: KPI LOGIC FRAMEWORK ---
def calculate_defect_rate(damaged_qty, total_qty):
    """Calculates the weighted defect percentage for a supplier."""
    if total_qty == 0: return 0
    return round((damaged_qty / total_qty) * 100, 2)

def calculate_lead_time_variance(actual_days, expected_days):
    """Measures the reliability gap in delivery logistics."""
    return actual_days - expected_days

# --- TASK 3: SYSTEM READINESS CHECK ---
def run_readiness_check():
    print("\n🔍 System Readiness Audit:")
    print(f"Python Version: {sys.version.split()[0]}")
    # Verify if raw files are in the correct place
    raw_path = "01_raw_data\\honeyrich_supply_logs_10k.csv"
    if os.path.exists(raw_path):
        print(f"Data Status: {raw_path} detected.")
    else:
        print(f"Data Status: honeyrich_supply_logs_10k.csv not found in 01_raw_data.")

if __name__ == "__main__":
    initialize_workspace()
    run_readiness_check()
    print("\n Day 1 Workspace Setup Completed Successfully.")