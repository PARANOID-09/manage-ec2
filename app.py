from flask import Flask, request, jsonify, render_template

app = Flask(__name__)

# Create a list to store received instance data
instances = []

@app.route('/api/instance-data', methods=['POST'])
def receive_instance_data():
    try:
        # Parse JSON payload from request
        instance_data = request.get_json()

        # Append received instance data to the list
        instances.append(instance_data)

        # Return a success response
        return jsonify({'status': 'success', 'message': 'Instance data received.'}), 200

    except Exception as e:
        # Return an error response
        return jsonify({'status': 'error', 'message': str(e)}), 400

@app.route('/')
def index():
    # Render the index.html template with the instances data
    return render_template('index.html', instances=instances)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
