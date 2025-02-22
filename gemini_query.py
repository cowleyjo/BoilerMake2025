from google import genai
import os

# TODO: eventually access the API key from txt file
#with open("", "r") as file:
 #   api_key = file.read().strip()  # Ensure no extra spaces/newlines

# TODO: gather data to get summary of animal
# pet data
breedname = "German Shepherd"
animalage = "6 months"
sex = "female"
if breedname is None:
    speciesname = ...
    breedname = speciesname
    

# TODO: down the road 
# adopter data
adopterage = 37
relationship = "married"
adopteractivitylevel = "medium"

kidbool = True # boolean
kids = {"Sadie": 4, "Trent": 3}
kidages = []

if kidbool:
    kidages = [age for _, age in kids.items()]
    kidnum = len(kids)

# prompt Gemini
prompt = f'You are a humane society worker. It is your job to recommend pets to potential owners and you are highly knowledgeable about pets. Briefly provide information about an {animalage} old {sex} {breedname}. Consider that the user is {adopterage} old, {relationship}, have {kidnum} kids, and is {adopteractivitylevel} active. Provide a ranking out of 10 for compatibility with the potential adopter. Ensure that your response is 2-3 sentences'

client = genai.Client(api_key="AIzaSyCqgAROCEhyuz7DxeEtTAEpK8Sndmd1wjU")
response = client.models.generate_content(
    model="gemini-2.0-flash", contents=prompt
)
print(response.text)
