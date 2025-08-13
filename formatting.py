import pandas as pd
import numpy as np
from io import StringIO
import sys
import pdb

def main(detail_csv, output_csv):
    # 1) Read raw CSV and merge continuation lines
    raw_lines = open(detail_csv, 'r').read().splitlines()
    merged_lines = []
    for line in raw_lines:
        if line.startswith(',') and merged_lines:
            merged_lines[-1] += line
        else:
            merged_lines.append(line)
    merged_csv = "\n".join(merged_lines)

    # 2) Load into DataFrame
    df = pd.read_csv(StringIO(merged_csv))

    # 3) Rename and map columns
    df = df.rename(columns={
        'Image Data ID': 'image_uid',
        'Subject': 'subject_id',
        'Group': 'diagnosis',
        'Sex': 'sex',
        'Age': 'age'
    })
    df['sex'] = df['sex'].map({'M': 0, 'F': 1})
    df['diagnosis'] = df['diagnosis'].map({'CN': 0, 'MCI': 0.5, 'AD': 1})
    df['age'] = df['age'] / 100.0

    # 4) Compute last diagnosis per subject (by latest Acq Date)
    df['Acq Date'] = pd.to_datetime(df['Acq Date'], errors='coerce')
    last_idx = df.groupby('subject_id')['Acq Date'].idxmax()
    last = df.loc[last_idx, ['subject_id', 'diagnosis']].rename(columns={'diagnosis': 'last_diagnosis'})
    df = df.merge(last, on='subject_id', how='left')

    # 5) Stratified-like split: 70% train, 10% val, 20% test by subject within each last_diagnosis group
    subs = df[['subject_id', 'last_diagnosis']].drop_duplicates()
    # Prepare split assignment
    split_map = {}
    for diag in subs['last_diagnosis'].unique():
        group = subs[subs['last_diagnosis'] == diag]['subject_id'].tolist()
        n = len(group)
        np.random.seed(42)
        np.random.shuffle(group)
        n_train = int(np.round(n * 0.3))
        n_val = int(np.round(n * 0.3))
        pdb.set_trace()
        # Assign
        for s in group[:n_train]:
            split_map[s] = 'train'
        for s in group[n_train:n_train + n_val]:
            split_map[s] = 'valid'
        for s in group[n_train + n_val:]:
            split_map[s] = 'test'

    # Map splits back to df
    df['split'] = df['subject_id'].map(split_map)

    # 6) Add empty latent_path column
    df['latent_path'] = ''

    # 7) Save
    df.to_csv(output_csv, index=False)
    print(f"Wrote formatted data to {output_csv}")


if __name__ == '__main__':
    if len(sys.argv) != 3:
        print(f"Usage: {sys.argv[0]} <detail_csv> <output_csv>")
        sys.exit(1)
    main(sys.argv[1], sys.argv[2])

