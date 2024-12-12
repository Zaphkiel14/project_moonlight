from mysql.connector import MySQLConnection, Error
from connections import read_config


def create_new_user(username, password,user_role):
    """
    Accepts a username password and user role to be inserted into the database as a new user to be verified first by the admin before it can be used

    :param username:
    :param password:
    :param user_role:
    :return:
    """
    args = (username, password, user_role)  # Initializing output values with placeholders

    try:
        # Read database configuration from the config file
        config = read_config()

        # Establish a connection to the MySQL database
        with MySQLConnection(**config) as conn:
            # Create a cursor to execute SQL queries
            with conn.cursor() as cursor:
                # Call the stored procedure 'LoginUser'
                result_args = cursor.callproc('procedure-create_new_user', args)
                
                # Debug: Print result_args to understand its structure
                print("Result args:", result_args)

                # Retrieve the output values from result_args based on their positions
                login_message = result_args[2]  # Adjust the index as needed based on debug output
                user_id = result_args[3]
                user_role = result_args[4]

                return login_message, user_id, user_role

    except Error as e:
        print(e)
        raise e

    finally:
        if conn is not None and conn.is_connected():
            conn.close()
            print('Connection is closed.')
    