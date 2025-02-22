-- Create the 'Pets' table
CREATE TABLE Pets (
    id INTEGER PRIMARY KEY,
    intakedate TEXT,
    intakereason TEXT,
    istransfer INTEGER,  -- 1 for TRUE, 0 for FALSE
    sheltercode TEXT,
    identichipnumber TEXT,
    animalname TEXT,
    breedname TEXT,
    basecolour TEXT,
    speciesname TEXT,
    animalage INTEGER,
    sexname TEXT,
    location TEXT,
    movementdate TEXT,
    movementtype TEXT,
    istrial INTEGER,  -- 1 for TRUE, 0 for FALSE
    returndate TEXT,
    returnedreason TEXT,
    deceaseddate TEXT,
    deceasedreason TEXT,
    diedoffshelter INTEGER,  -- 1 for TRUE, 0 for FALSE
    puttosleep INTEGER,  -- 1 for TRUE, 0 for FALSE
    isdoa INTEGER  -- 1 for TRUE, 0 for FALSE
);

-- Create the 'Adopters' table
CREATE TABLE Adopters (
    adopter_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    contact_info TEXT
    location TEXT
);

-- Create the 'Shelters' table
CREATE TABLE Shelters (
    shelter_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    location TEXT
);

-- Create the 'Adopters_Pets' table
CREATE TABLE Adopters_Pets (
    adopter_id INTEGER,
    pet_id INTEGER,
    adoption_date TEXT,
    PRIMARY KEY (adopter_id, pet_id),
    FOREIGN KEY (adopter_id) REFERENCES Adopters(adopter_id),
    FOREIGN KEY (pet_id) REFERENCES Pets(id)
);
