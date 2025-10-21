import sys
import jwt
import json

def decode_jwt(token: str):
    decoded = jwt.decode(token, options={"verify_signature": False})
    print(json.dumps(decoded, indent=4))
    return decoded

if __name__ == "__main__":
    raw = sys.argv[1]
    decode_jwt(raw)
