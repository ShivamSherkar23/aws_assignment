from urllib import response
from flask import Flask
import boto3
from flask import jsonify

app = Flask(__name__)

client = boto3.client('ec2', region_name='us-east-1')

@app.route("/ec2",methods=['GET'])
def get_instance_info():
    instance = {}
    list_resp = []
    response = client.describe_instances()
    # print(jsonify(response))
    
    for a in response['Reservations']:
        instanceinfo = a['Instances']
        for e in instanceinfo:
            id = e['InstanceId']
            for f in e['NetworkInterfaces']:
                Ip = f["Association"]["PublicIp"]
                instance[id] = {
                "instance_ip": Ip
                }
                list_resp.append(instance)
    return jsonify(list_resp)
if __name__ == '__main__':
   app.run(host='0.0.0.0',port=5000)