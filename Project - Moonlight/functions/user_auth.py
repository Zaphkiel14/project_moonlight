from mysql.connector import MySQLConnection, Error
from connections import read_config

def loginuser(username, password):
    """
    Accepts a username and password,
    if username not exists, returns user not found
    if username exists but password is incorrect, returns password incorrect
    if username == "" or password == "" returns please fill in the username and/or password
    :param username:
    :param password:
    :return: user_id, user role
    """
    args = (username, password, '', 0,'')  # Initializing output values with placeholders

    try:
        # Read database configuration from the config file
        config = read_config()

        # Establish a connection to the MySQL database
        with MySQLConnection(**config) as conn:
            # Create a cursor to execute SQL queries
            with conn.cursor() as cursor:
                # Call the stored procedure 'LoginUser'
                result_args = cursor.callproc('LoginUser', args)
                
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


    