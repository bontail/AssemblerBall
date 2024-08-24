
# AssemblerBall

#### 2D game written in ARM Assembly with SDL2

![AssemblerBall Process](AssemblerBallProcess.gif)

### Git

```shell
git clone https://github.com/bontail/AssemblerBall.git
```

To run the game, you will need to have SDL2 library, Python, Cmake installed on your system.<br>
You can install SDL2 library using your system's package manager or by downloading them from their respective websites.<br>

### Run

```shell
make start_server
```
Open a second terminal window.

```shell
mkdir build && cd build
cmake .. && cmake --build .
./AssemblerBall
```