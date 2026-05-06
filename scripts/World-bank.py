import requests
from requests.exceptions import HTTPError
import pandas as pd
import time
import logging
from datetime import datetime
import os



BASE_URL = "https://api.worldbank.org/v2/country/"         
COUNTRIES = ["BLZ","CRI","SLV","GTM","HND","NIC","PAN"]       
INDICATORS = {
    "total_external_debt":        "DT.DOD.DECT.CD",
    "long_term_debt":             "DT.DOD.DLXF.CD",
    "short_term_debt":            "DT.DOD.DSTC.CD",
    "public_guaranteed_debt":     "DT.DOD.DPPG.CD",
    "private_nonguaranteed_debt": "DT.DOD.DPNG.CD",
    "imf_credit":                 "DT.DOD.DIMF.CD"
}
DATE_RANGE = "2000:2023"



def fetch_indicator(country_code, indicator_code, date_range):
    

    
    try:
        
        url=(BASE_URL+country_code+"/indicator/"+indicator_code+"?"+"format=json"+"&date="+date_range+"&per_page=30")

        response = requests.get(url)
        response.raise_for_status()


        response_json = response.json()
       

        if not isinstance(response_json, list):
             print("Response is not right type")
             return []

     
        if response_json[0].get('message'):
            print(f"Error de API: {response_json[0]['message']}")
            return []

  
        if len(response_json) < 2:
            print("No data in response")
            return []
                    
        
        response = response_json[1]
        

        result= []

        for item in response:

            print(item['indicator']['id'])
            result.append({    
                "country_id": item['country']['id'],
                "country_value": item['country']['value'],
                "country_iso_code":item['countryiso3code'],
                "indicator":item['indicator']['id'],
                "date":item['date'],
                "value":item['value']})

       
        return result
        
    except HTTPError as http_err:
        print(f'HTTP error occurred: {http_err}')  
    except Exception as err:
       

        print(f'Other error occurred: {err}')  
   

     


   



def fetch_with_retry(country_code, indicator_code,date_range,retries=3, delay=2):

    
    for attempt in range(retries):
        try:
                result=fetch_indicator(country_code,indicator_code,date_range)
                return result
                
        except Exception as e:
            if attempt < retries - 1: 
                print(f"Attempt {attempt + 1} failed: {e}. Retrying...")
                time.sleep(delay) 
            else:
                print("All attempts failed.")
                raise 
    



def build_dataset(countries, indicators, date_range):
   
    result = []
    for country in countries:
        for indicator, code in indicators.items():
            raw_data = fetch_with_retry(country, code, date_range)

            if isinstance(raw_data, list):
                
                for r in raw_data:
                    r['type_of_indicator'] = indicator 
                
                result.extend(raw_data)
            time.sleep(0.1)




    return pd.DataFrame(result)
    
    



def save_to_csv(df, path):
  



    if not os.path.exists(path):
        os.makedirs(path)
        print(f"carpeta '{path}' creada")


    timestamp=datetime.now().strftime("%Y%m%d_%H%M")
    filename = f"debt_central_america{timestamp}.csv"
    latest ="debt_central_america_latest.csv"
    path_historical= os.path.join(path,filename)
    path_latest = os.path.join(path,latest)
    
    try:
        df.to_csv(path_historical,index=False, encoding='utf-8' )
        df.to_csv(path_latest, index=False)
        print(f"Saving data on'{path}'")
        print(f"archivos creados{path_historical,path_latest}")
    except Exception as e:
        print(f"The process of saving the data has failed{e}")
    
    


if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)
   
    df = build_dataset(COUNTRIES, INDICATORS, DATE_RANGE)
    
    

    if not df.empty:
        print(f"Dataset created with shape: {df.shape}")
        print(f"Dataset information:{df.head()}")
        folder = "data_world_bank"
        save_to_csv(df,folder)
        

    else:
        print("There was an error creting the dataset")





    