from flask import Flask, request, render_template

app = Flask(__name__)

instances = []

@app.route('/')
def index():
    return render_template('index.html', instances=instances)

@app.route('/receive_data', methods=['POST'])
def receive_data():
    instance_data = request.form['data']
    instances.append(instance_data)
    return 'Data received'

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
