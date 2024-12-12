from mysql.connector import MySQLConnection, Error
from connections import read_config


def SearchAddons(searchAddons):
    args = (searchAddons)  # Initializing output values with placeholders

    try:
        # Read database configuration from the config file
        config = read_config()

        # Establish a connection to the MySQL database
        with MySQLConnection(**config) as conn:
            # Create a cursor to execute SQL queries
            with conn.cursor() as cursor:
                # Call the stored procedure 'LoginUser'
                cursor.callproc('SearchAddons', args)
                
                for result in cursor.callproc('SearchAddons', args):
                    rows =result.fetchall()
                    for row in rows:
                        print(row)


    except Error as e:
        print(e)
        raise e

    finally:
        if conn is not None and conn.is_connected():
            conn.close()
            print('Connection is closed.')

