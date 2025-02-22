from flask import Flask, jsonify, request
from flask_cors import CORS

import sqlite3
import requests
import math


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
    
    username = request.args.get('username') # 'username' from request
    password = request.args.get('password') # 'password' from request
    type = request.args.get('type') # 'type' from request

    #Establish connection to DB
    conn = sqlite3.connect('my_database.db') #TODO: REPLACE WITH NAME
    cursor = conn.cursor()

    cursor.execute("SELECT * FROM users ORDER BY RANDOM() LIMIT 1;") #TODO: replace to get user
    row = cursor.fetchone
    
    # Close connection to DB
    conn.close()

    if row:
        return jsonify({"found": "true"})
    else:
        return jsonify({"found": "false"})
    


@app.route('/make-user', methods=['POST'])
def make_user():

    username = request.args.get('username') # 'username' from request
    password = request.args.get('password') # 'password' from request
    type = request.args.get('type') # 'type' from request

    #Establish connection to DB
    conn = sqlite3.connect('my_database.db') #TODO: REPLACE WITH NAME
    cursor = conn.cursor()

    cursor.execute("SELECT * FROM users ORDER BY RANDOM() LIMIT 1;") #TODO: replace to make user
    row = cursor.fetchone

    # Close connection to DB
    conn.close()


    return jsonify({"status": "success"}), 200



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