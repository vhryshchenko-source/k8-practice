from flask import Flask

from hits.counter import increment

if __name__ == "__main__":
    app = Flask("hits")
    app.add_url_rule("/", "root", increment)
    app.run(host="0.0.0.0", debug=False)
