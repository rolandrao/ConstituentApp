import pandas as pd


df = pd.read_csv('constituent_data.csv')

df = df[:50]

df.to_csv('voter_data_sliced.csv')
df.to_json('voter_data_sliced.json', orient='records')