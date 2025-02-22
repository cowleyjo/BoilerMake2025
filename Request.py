from flask import Flask, jsonify, request
from flask_cors import CORS

import sqlite3
import requests
import math

import sqlite3
import logging

# Create a new SQLite database or connect to an existing one
conn = sqlite3.connect('my_database.db')
cursor = conn.cursor()

# Create the 'users' table if it doesn't exist
cursor.execute('''
    CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        password TEXT NOT NULL,
        type TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL
    )
''')

# Commit changes and close the connection
conn.commit()
# conn.close()

# Dummy data for users

# Create a connection to the SQLite database
# conn = sqlite3.connect('my_database.db')
cursor = conn.cursor()

# Insert dummy data into the 'users' table

# Commit changes and close the connection
conn.commit()
conn.close()

app = Flask(__name__)
CORS(app)


def haversine(lat1, lon1, lat2, lon2):
    R = 6371  # Earth's radius in km

    # Convert degrees to radians
    lat1, lon1, lat2, lon2 = map(math.radians, [lat1, lon1, lat2, lon2])

    # Haversine formula
    dlat = lat2 - lat1
    dlon = lon2 - lon1
    a = math.sin(dlat / 2)**2 + math.cos(lat1) * math.cos(lat2) * math.sin(dlon / 2)**2
    c = 2 * math.asin(math.sqrt(a))
    
    return R * c  # Distance in km


API_KEY = '459106e0e6454bf69a1afe468d23fed9'  # Replace with your OpenCage API key

def get_coordinates_from_address(address: str):
    # Encode the address
    encoded_address = requests.utils.quote(address)
    
    # Construct the URL for OpenCage API request
    url = f'https://api.opencagedata.com/geocode/v1/json?q={encoded_address}&key={API_KEY}'
    
    # Make the request to OpenCage API
    response = requests.get(url)
    
    if response.status_code == 200:
        data = response.json()
        
        if data['results']:
            # Extract latitude and longitude
            latitude = data['results'][0]['geometry']['lat']
            longitude = data['results'][0]['geometry']['lng']
            print(latitude)
            print(longitude)
            return latitude, longitude  # Return as a tuple of floats
        else:
            return None, None  # No results found
    else:
        return None, None  # Handle any errors during the API call


@app.route('/get-pet', methods=['GET'])
def get_pet():

    lon = float(request.args.get('longitude'))  # 'longitude' from request
    lat = float(request.args.get('latitude'))  # 'latitude' from request
    radius = float(request.args.get('radius'))  # 'radius' from request

    # Establish connection to DB
    conn = sqlite3.connect('my_database.db') #TODO: REPLACE WITH NAME
    cursor = conn.cursor()

    found = False
    while (found != True):
        #picks a random row
        cursor.execute("SELECT * FROM users ORDER BY RANDOM() LIMIT 1;")
        row = cursor.fetchone()  # Get a single row (fetchone instead of fetchall)

        shelter_lon = row[1]  #TODO: change number here
        shelter_lat = row[2]  #TODO: change number here


        distance = haversine(lon, lat, shelter_lon, shelter_lat)  #TODO: probably need to change numbers here to to access individual lat and long
        if (distance <= radius):
            found = True

    # Close connection to DB
    conn.close()

    # Check if a row was found and reformmat
    if row:
        output = {"id": row[0], "name": row[1], "age": row[2]} #TODO: MAKE NORMAL PROPERTIES
        return jsonify(output)
    else:
        return jsonify({"error": "No data found"}), 404


@app.route('/check-user', methods=['GET'])
def check_user():
    
    username = request.args.get('username')  # 'username' from request
    password = request.args.get('password')  # 'password' from request
    user_type = request.args.get('type')  # 'type' from request

    # Establish connection to DB
    conn = sqlite3.connect('my_database.db')  # Replace with actual database name
    cursor = conn.cursor()

    # Modify the SQL query to match all conditions: username, password, and type
    cursor.execute("""
        SELECT * FROM users 
        WHERE username = ? AND password = ? AND type = ?
    """, (username, password, user_type))

    row = cursor.fetchone()  # Fetch a single matching row
    
    # Close connection to DB
    conn.close()

    if row:
        return jsonify({"found": "true"})
    else:
        return jsonify({"found": "false"})

    


@app.route('/make-user', methods=['POST'])
def make_user():
    username = request.form.get('username')  # Change to .form.get() for POST request
    password = request.form.get('password')
    user_type = request.form.get('type')
    location = request.form.get('location')

    # Ensure the location is valid and get coordinates
    lat, lon = get_coordinates_from_address(location) if location else (None, None)
    print(f"Received location: {location}, Coordinates: {lat}, {lon}")  # Debugging

    # Check for empty values
    if not username or not password or not user_type or not location:
        return jsonify({"status": "failure", "message": "Missing required fields"}), 400

    try:
        # Establish connection to DB
        conn = sqlite3.connect('my_database.db')
        cursor = conn.cursor()
        print("Attempting to write")

        # Insert the new user into the database
        cursor.execute("""
            INSERT INTO users (username, password, type, latitude, longitude) 
            VALUES (?, ?, ?, ?, ?)
        """, (username, password, user_type, lat, lon))

        # Commit the transaction
        conn.commit()
        print("User added successfully!")  # Debugging

    except Exception as e:
        print(f"Error inserting data: {e}")
        conn.rollback()
        return jsonify({"status": "failure", "message": f"Error: {e}"}), 500

    finally:
        # Close connection
        conn.close()

    return jsonify({"status": "success", "message": "User created successfully!"}), 200




@app.route('/pick-pet', methods=['POST'])
def pick_pet():

    adopterUsername = request.args.get('adopterUsername')
    adopterPassword = request.args.get('adopterPassword')
    petID = request.args.get('petID')

    #Establish connection to DB
    conn = sqlite3.connect('my_database.db') #TODO: REPLACE WITH NAME
    cursor = conn.cursor()

    cursor.execute("SELECT * FROM users ORDER BY RANDOM() LIMIT 1;") #TODO: replace to get pet
    row = cursor.fetchone

    # Close connection to DB
    conn.close()

    if row:
        return jsonify({"found": "true"}), 200
    else:
        return jsonify({"found": "false"}), 404
    

if __name__ == '__main__':
    app.run(debug=True)