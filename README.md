# John Conway's Game of Life
It is a mathematical game created by John Conway. It is a game that evolves in a bidimensional matrix. The cells could be either alive(1) or dead(0). <br>
A cell evolves in this way:
- a cell with less than 2 alive neighbors die
- a cell with 2 or 3 alive neighbors survive
- a cell with more than 3 alive neighbors die
- a dead cell with 3 alive neighbor becomes alive 
This rules are referred to the old matrix.

# Technology
- Assembly MIPS

# Logic of the program
The function called "countNearCells" counts the sum of the neighbor cells. It is used for every cell in the "evolution" function. This function that takes the old matrix and fills the new one. Every time the new matrix is printed