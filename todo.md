# TODO

## Pieces
### Rook
- can go horizontally and vertically as long as there is no blocking piece
### Bishop
- can go diagonally in both directions as long as there is no blocking piece
### Knight
- can go in "L" shape for 8 directions as long as there is no blocking piece on that specified point
### Queen 
- can go in the 8-directions that are available as long as in one of the directions there is no blocking piece
### King
- can move in the eight directions once, if there is no blocking piece
### Pawn
- if it is the first move, it can move upto two forward places
- else it moves, one step forward
- can be promoted to `queen`, `knight`, `bishop`, or `rook`
- can take another pawn if that pawn comes to an adjacent position by using two step movement, which is called *en passant*
- can take pieces if they are on the two forward diagonal sides

## Castling
### Conditions
- The `king` has not moved until now
- The `rook` has not moved until now
- The `king` is not in check
- There is no other piece between `king` and `rook`

# Check and Checkmate
