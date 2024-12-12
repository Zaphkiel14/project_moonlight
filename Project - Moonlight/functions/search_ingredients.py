from mysql.connector import MySQLConnection, Error
from connections import read_config

def SearchIngredients(searchIngredients: str):
    """"
    search database for ingredients containing the searched string in any pattern
    :param searchIngredients: a pattern to search for ingredients
    :type: str
    :return: a list of ingredients
    :examples: >>>>>> searchIngredients = 'es' return "cheese"

    """

    args = (searchIngredients)  # Initializing output values with placeholders

    try:
        # Read database configuration from the config file
        config = read_config()

        # Establish a connection to the MySQL database
        with MySQLConnection(**config) as conn:
            # Create a cursor to execute SQL queries
            with conn.cursor() as cursor:
                # Call the stored procedure 'LoginUser'
                cursor.callproc('SearchIngredients', args)
                
                for result in cursor.callproc('SearchIngredients', args):
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

