from flask import Flask, jsonify, request
from flask_cors import CORS
import sqlite3
import requests
import math


app = Flask(__name__)
CORS(app)

def get_coordinates(address):
    url = "https://nominatim.openstreetmap.org/search"
    params = {
        "q": address,
        "format": "json",
        "limit": 1
    }

    response = requests.get(url, params=params)
    data = response.json()

    if data:
        lat = data[0]["lat"]
        lon = data[0]["lon"]
        return float(lat), float(lon)
    else:
        return None
    

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
    conn = sqlite3.connect('rescu.db')
    cursor = conn.cursor()

    found = False
    while (found != True):
        #picks a random row
        cursor.execute("SELECT * FROM Pets ORDER BY RANDOM() LIMIT 1;")
        row = cursor.fetchone() 

        cursor.exceute("SELECT * FROM Shelters WHERE username = ? AND password = ?", (row[8], row[9])) #TODO: change num
        shelter = cursor.fetchone()

        shelter = get_coordinates(shelter[-1]) #TODO: change num
        shelter_lon = shelter[1]
        shelter_lat = shelter[0]


        distance = haversine(lat, lon, shelter_lat, shelter_lon)  
        if (distance <= radius):
            found = True

      
    # Close connection to DB
    conn.close()

    # Check if a row was found and reformmat
    if row:
        output = {"id": row[0], "name": row[1], "age": row[2], 
                  "sex": row[3], "size": row[4], "type": row[5], 
                  "descr": row[6], "pic": row[7], "shelter": shelter[0], "location": shelter[1]} #TODO: change nums
        return jsonify(output)
    else:
        return jsonify({"error": "No data found"}), 404


@app.route('/check-user', methods=['GET'])
def check_user():

    username = (request.args.get('username')) 
    password = (request.args.get('password')) 
    type = (request.args.get('type')) 

    #Establish connection to DB
    conn = sqlite3.connect('rescu.db')
    cursor = conn.cursor()

    cursor.execute("SELECT * FROM Shelters WHERE username = ? AND password = ?", (username, password))
    row = cursor.fetchone
    
    # Close connection to DB
    conn.close()

    if row:
        return jsonify({"found": "true", "location": row[3]}) #TODO: check num
    else:
        return jsonify({"found": "false"})
    


@app.route('/make-user', methods=['POST'])
def make_user():
    
    username = (request.args.get('username'))
    password = (request.args.get('password'))
    type = (request.args.get('type'))
    location = (request.args.get('location'))


    #Establish connection to DB
    conn = sqlite3.connect('rescu.db')
    cursor = conn.cursor()

    if type == "adopter":
        cursor.execute("INSERT INTO Adopters (username, password, location) VALUES (?, ?, ?)", (username, password, location))
        conn.commit()

    else:
        cursor.execute("INSERT INTO Shelters (username, password, location) VALUES (?, ?, ?)", (username, password, location))
        conn.commit()

    # Close connection to DB
    conn.close()

    return jsonify({"status": "success"}), 200



@app.route('/pick-pet', methods=['POST'])
def pick_pet():

    id = float(request.args.get('id'))

    #Establish connection to DB
    conn = sqlite3.connect('rescu.db')
    cursor = conn.cursor()

    cursor.execute("SELECT * FROM users ORDER BY RANDOM() LIMIT 1;") #TODO: replace to put pet and adopter toegether in 4th table
    conn.commit()

    # Close connection to DB
    conn.close()


@app.route('/update-shelter', methods=['POST'])
def update_shelter():
    #TODO: all the logic here isnt right

    username = (request.args.get('username'))
    password = (request.args.get('password'))

    #Establish connection to DB
    conn = sqlite3.connect('rescu.db')
    cursor = conn.cursor()

    cursor.execute("SELECT * FROM users ORDER BY RANDOM() LIMIT 1;") #TODO: replace to get pet:adopter pairs that belong to this shelter
    row = cursor.fetchall()

    # Close connection to DB
    conn.close()

    
    return jsonify({"status": "success"}), 200


    

if __name__ == '__main__':
    app.run(debug=True)