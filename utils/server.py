import socket
import random

server_sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
client_sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

server_address = ('', 33333)
server_sock.bind(server_address)

client_address = ('127.0.0.1', 44444)

directions = [b'\x00\x00\x00\x00'] * 10  # null direction
directions.append(b'\xff\xff\xff\xff')  # up direction
directions.append(b'\x01\x00\x00\x00')  # down direction

while True:
    data, address = server_sock.recvfrom(4)
    client_sock.sendto(random.choice(directions), client_address)
