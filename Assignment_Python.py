import pandas as pd
import json
import numpy as np
from datetime import datetime, timedelta

df = pd.read_csv('data.csv', dtype={'id': 'int'}) 

df['contracts'] = df['contracts'].apply(lambda x: json.loads(x) if isinstance(x, str) else [])

exp_df = df.explode('contracts', ignore_index=True)
flat_df = pd.json_normalize(json.loads(exp_df.to_json(orient = 'records')))

flat_df = flat_df.drop(columns=['contracts'])
flat_df.columns = [col.replace('contracts.', '') for col in flat_df.columns]

flat_df.replace('', pd.NA, inplace=True)
flat_df = flat_df.replace({np.nan: pd.NA})
flat_df['claim_date'] = pd.to_datetime(flat_df['claim_date'], format='%d.%m.%Y', dayfirst=True).dt.date
flat_df['contract_date'] = pd.to_datetime(flat_df['contract_date'], format='%d.%m.%Y', dayfirst=True).dt.date

#number of calims for last 180 days
def tot_claim_cnt_l180d (id_PK):
    today = datetime.today().date()
    start_date = today - timedelta(days=180)
    id_df = flat_df[flat_df['id'] == id_PK]
    filtered_df = id_df[(id_df['claim_date'] >= start_date) & (id_df['claim_date'].notna())]
    distinct_claims = filtered_df['claim_id'].nunique()
    if id_df['claim_id'].nunique() == 0:
        return -3
    else:
        return distinct_claims

#there was no claim_date which was from last 180 days, 
#i thought it might have been an outdated task so i also added a feature for last year
#number of calims for last 360 days
def tot_claim_cnt_l360d (id_PK):
    today = datetime.today().date()
    start_date = today - timedelta(days=360)
    id_df = flat_df[flat_df['id'] == id_PK]
    filtered_df = id_df[(id_df['claim_date'] >= start_date) & (id_df['claim_date'].notna())]
    distinct_claims = filtered_df['claim_id'].nunique()
    if id_df['claim_id'].nunique() == 0:
        return -3
    else:
        return distinct_claims
    
#sum of exposure loans without tbc loans
def disb_bank_loan_wo_tbc (id_PK):
    id_df = flat_df[flat_df['id'] == id_PK]
    exclude_banks = ['LIZ', 'LOM', 'MKO', 'SUG']
    filtered_df = id_df[~id_df['bank'].isin(exclude_banks) & id_df['bank'].notna()]
    filt_disbursments = filtered_df.dropna(subset=['contract_date']) 
    if id_df['claim_id'].nunique() == 0:
        return -3
    elif len(filt_disbursments)==0:
        return -1
    else : 
        return filt_disbursments['loan_summa'].sum()

#number of days since last loan
def day_sinlastloan (id_PK):
 
    id_df = flat_df[flat_df['id'] == id_PK]
    if id_df['claim_id'].nunique() == 0:
        return -3
    filtered_df = id_df.dropna(subset=['summa']) 
    if len(filtered_df)==0:
        return -1 
    max_contract_date = filtered_df['contract_date'].max()

    application_date = df[df['id']==id_PK]['application_date'].astype(str).str.replace(r'\.\d+', '', regex=True)
    application_date = application_date = pd.to_datetime(application_date,format='%Y-%m-%d %H:%M:%S%z',errors='coerce').dt.date
    application_date = application_date.max()
    if isinstance(max_contract_date, pd.Timestamp):
        max_contract_date = max_contract_date.date()
    date_diff = application_date - max_contract_date
    return date_diff.days

df_with_features = df.drop(columns=['contracts'])
df_with_features['tot_claim_cnt_l180d'] = df_with_features['id'].apply(tot_claim_cnt_l180d)
df_with_features['tot_claim_cnt_l360d'] = df_with_features['id'].apply(tot_claim_cnt_l360d)
df_with_features['disb_bank_loan_wo_tbc'] = df_with_features['id'].apply(disb_bank_loan_wo_tbc)
df_with_features['day_sinlastloan'] = df_with_features['id'].apply(day_sinlastloan)
df_with_features.to_csv('contract_features.csv', index=False, mode='w')
flat_df.to_csv('flattened_data.csv', index=False, mode='w')
