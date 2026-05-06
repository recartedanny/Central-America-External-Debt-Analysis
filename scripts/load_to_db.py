import sqlite3
import pandas as pd
import os



def get_connection(db_path):


    folder = os.path.dirname(db_path)

    if folder and not os.path.exists(folder):
        os.makedirs(folder)
        
        print(f"carpeta '{folder}' creada")
    

    try:
        conn = sqlite3.connect(db_path)
        print(f"Conection stablish with succes{db_path}")
        return conn

 
    except Exception as e:
        print(f"Conection wasnt able to stablish: {e}")
        return None
    



def create_schema(conn):
   
    cursor=conn.cursor()

    cursor.execute("""CREATE TABLE IF NOT EXISTS CENTRAL_AMERICA_DEBT(
    country_id TEXT,
    country_value TEXT,
    country_iso_code TEXT,
    indicator TEXT,
    date INTEGER,
    value REAL,
    type_of_indicator TEXT,
    PRIMARY KEY (country_id, indicator, date)

    )""")


    



def load_dataframe(conn, df):
  
    try:
            cursor=conn.cursor()
            cursor.execute("DELETE FROM CENTRAL_AMERICA_DEBT")
            conn.commit()
            df.to_sql("CENTRAL_AMERICA_DEBT",conn,if_exists='append',index=False)
            print("Datos guardados correctamente")
    except Exception as e:
        print(f"Conection wasnt able to stablish {e}")
        raise

    


def run_sanity_checks(conn):
    

    cursor = conn.cursor()
    try:
        cursor.execute(""" 
        SELECT COUNT(*) FROM CENTRAL_AMERICA_DEBT;

        """)
        (total_rows,)=cursor.fetchone()

        if total_rows == 1008:
            print("Total rows have passed the test")
        else:
            print(f"Total rows have not passed the test {total_rows}")

    except Exception as e:
        print(f"There was an error:{e}")

    try:
        cursor.execute(""" 
        SELECT COUNT(DISTINCT country_id) FROM CENTRAL_AMERICA_DEBT;

         """)
        (total_countries,)=cursor.fetchone()
        # Costa Rica and Panama return no data for any indicator in World Bank database
        if total_countries == 5:
         print("PASS: country count")
        else:
            print(f"Total countries have not passed the test {total_countries}")

    except Exception as e:
        print(f"There was an error:{e}")

    try:
        cursor.execute(""" 
        SELECT MIN(date), MAX(date) FROM CENTRAL_AMERICA_DEBT;

        """)
        min_date, max_date = cursor.fetchone()

        if (min_date, max_date) == (2000,2023):
            print("Range date have passed the test")
        else:
            print(f"Date range have not passed the test{min_date,max_date}")
        

    except Exception as e:
        print(f"There was an error:{e}")
    

    
if __name__ == "__main__":
    
    path= "data_world_bank/debt_central_america_latest.csv"
    db_path ="database_central_america_debt/debt.db"
    df= pd.read_csv(path)
    conn= get_connection(db_path)
    try:
        create_schema(conn)
        load_dataframe(conn, df)
        run_sanity_checks(conn)
    finally:
        conn.close()
        print("Connection closed")
        
    
