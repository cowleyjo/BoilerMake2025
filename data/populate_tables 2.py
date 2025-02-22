import sqlite3
import csv

# Connect to SQLite database
conn = sqlite3.connect('rescu.db')
cursor = conn.cursor()
tables = cursor.fetchall()

print(tables)

conn.commit()
conn.close()