import pandas as pd


df = pd.read_csv('../assets/data/voter_data_with_coords.csv')

df = df[:1000]

# df.to_csv('../assets/data/voter_data_with_coords.csv')
df.to_json('../assets/data/voter_data_with_coords_sliced.json', orient='records')