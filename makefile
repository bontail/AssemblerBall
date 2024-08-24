menu_text.s:
	python3 utils/create_menu_text.py
	mv menu_text.s src/menu_text.s

start_server:
	python3 utils/server.py
