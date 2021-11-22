import logging
import requests
import json

## Log file parameters##
logFile = './output.log'
logging.basicConfig(filename=logFile, filemode='a',
                    format='%(asctime)s - %(levelname)s - %(message)s', level=logging.INFO)

## File output parameter
input_file_path = './config.json'
number_of_characters = 15


def respone_status(response):
    if response.status_code == 200:
        logging.info("Trying to fetch data from URL: " + (json_data['url']))
    else:
        logging.error("URL " + (json_data['url']) + " is not available")
        exit()


with open(input_file_path, 'r+', encoding='utf-8') as json_file:
    json_data = json.load(json_file)
    #print(json_data['url'])
    response = requests.get(url=json_data['url'])
    #print(response.status_code)
    respone_status(response)
    content = str(response.content)
    update_content = {"content": content[:number_of_characters]}
    json_data.update(update_content)
    json_file.seek(0)
    json.dump(json_data, json_file)
    logging.info("updated value: " + str(update_content))
    print("Please check config.json file")
