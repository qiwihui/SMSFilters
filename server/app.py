# coding: utf-8
#/usr/bin/python

from flask import Flask, request, abort, jsonify
import json

app = Flask(__name__)

@app.route('/v1/sms', methods=['POST'])
def new_sms():
    """添加新信息
    """
    if not request.json or not 'message' in request.json:
        abort(400)
    new_message = request.json
    # TODO: save new message in a database
    print(new_message)
    with open("message", "a") as f:
        f.write(json.dumps(new_message)+"\n")
    return jsonify({'data': new_message, 'received': 1}), 201

if __name__ == '__main__':
    app.run(debug=False, host='0.0.0.0', port=80)
