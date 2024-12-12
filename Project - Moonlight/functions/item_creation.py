from mysql.connector import MySQLConnection, Error
from connections import read_config

def create_new_item(item_name, item_description, item_picture, item_has_addons, item_has_size, item_category, item_price, item_addons, item_ingredients):
    args = (item_name, item_description, item_picture, item_has_addons, item_has_size, item_category, item_price, item_addons, item_ingredients)

    try:
        # Read database configuration from the config file
        config = read_config()

        # Establish a connection to the MySQL database
        with MySQLConnection(**config) as conn:
            # Create a cursor to execute SQL queries
            with conn.cursor() as cursor:
                # Call the stored procedure 'InsertNewItem'
                cursor.callproc('InsertNewItem', args)
                
                # Commit the transaction if the procedure modifies data
                conn.commit()

                # Retrieve output arguments if any (uncomment and adjust indices as needed)
                # result_args = cursor.callproc('InsertNewItem', args)
                # item_id = result_args[0]  # Adjust the index if the procedure returns an ID
                # return item_id

    except Error as e:
        print(f"Error: {e}")
        raise e

    finally:
        if conn is not None and conn.is_connected():
            conn.close()
            print('Connection is closed.')