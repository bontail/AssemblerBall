
file = open("menu_text.s", "w")

value = ""

x_diff = 60
y_diff = 40

for x in range(0, x_diff):
    for y in range(0, y_diff):
        value += f"drawPoint (WINDOW_W / 2) + {x}, (WINDOW_H / 2) - {y + x}\n"
        value += f"drawPoint (WINDOW_W / 2) - {x}, (WINDOW_H / 2) - {y + x}\n"

for x in range(x_diff, x_diff + 30):
    for y in range(0, x_diff + y_diff):
        value += f"drawPoint (WINDOW_W / 2) + {x}, (WINDOW_H / 2) - {y}\n"
        value += f"drawPoint (WINDOW_W / 2) - {x}, (WINDOW_H / 2) - {y}\n"


for x in range(x_diff, x_diff + 30):
    for y in range(0, (x_diff + y_diff) // 2):
        value += f"drawPoint (WINDOW_W / 2) + {x}, (WINDOW_H / 2) + {y}\n"
        value += f"drawPoint (WINDOW_W / 2) - {x}, (WINDOW_H / 2) + {y}\n"


file.write(value)
