tidychess
================
Josh Merrell

-   [Introduction](#introduction)
-   [Exploration of Functions](#exploration-of-functions)
-   [Chess Data](#chess-data)

Introduction
============

**Terminology**

-   **game data**
-   **positional data**
-   **PGN format**
-   **FEN format**
-   **matrix format**
-   **tidy format**
-   **positional mobility**
-   **pathPrior**: planning to change the name to *theoretical mobility*. Lists the squares a piece can move on an empty chessboard.
-   **Post functions**: planning to change the name to *ingame* functions. They were named for *aposteriori*, and they list the squares to which a piece can move from a given position.

Exploration of Functions
========================

**Setup**

``` r
invisible(lapply(list.files("R", "\\.R$", full.names = T), source))
```

**The mobility\_piece function**

``` r
# if position_vec is not passed as an input, 
# it is assumed that no other pieces are on the board
mobility_piece(piece = "bishop", square = "e5")
```

    ##  [1] "a1" "b2" "b8" "c3" "c7" "d4" "d6" "f6" "f4" "g7" "g3" "h8" "h2"

``` r
# if board is empty, specified piece is not on specified square:
mobility_piece(piece = "white pawn", square = "a2", position_vec = empty())

# white pawns travel up and black pawns travel down
mobility_piece(piece = "black pawn", square = "e5")
```

    ## [1] "e4"

``` r
mobility_piece(piece = "white pawn", square = "e5")
```

    ## [1] "e6"

``` r
# pawns of unspecified color might go either direction
mobility_piece(piece = "pawn", square = "e5")
```

    ## [1] "e6?" "e4?"

``` r
# mobility_piece() piece type from position_vec & square:
mobility_piece(square = "a2", position_vec = setup(includeEmpty = F)[1,])
```

    ## [1] "a3" "a4"

``` r
# if piece input conflicts with square & position_vec inputs, it is overriden:
mobility_piece(square = "a2", 
               position_vec = setup(includeEmpty = F)[1,], 
               piece = "white rook")
```

    ## [1] "a3" "a4"

**compare post & prior**

``` r
mobility_board(position_vec = setup())
```

    ## total white black 
    ##    40    20    20

``` r
patterns <- c("white bishops" = "white bishop",
              "black knights"="black knight",
              "pawns"="pawn")
pieces <- unique(unlist(setup()[2,]));  pieces <- pieces[!is.na(pieces)]
mobility_board(position_vec = setup(), patterns = patterns)
```

    ##         total white bishops black knights         pawns 
    ##            40             0             4            32

``` r
mobility_board(position_vec = setup(), patterns = pieces)
```

    ##        total   black Rook   black pawn   white pawn   white Rook 
    ##           40            0           16           16            0 
    ## black Knight white Knight black Bishop white Bishop  black Queen 
    ##            4            4            0            0            0 
    ##  white Queen   black King   white King 
    ##            0            0            0

``` r
rm(patterns, pieces)
```

**new\_position**

``` r
positions <- setup()
positions <- rbind(positions, new_position(new_pgn = "1.e3",
                                           position_vec = positions))
positions[,c("e2","e3")]
rm(positions)
```

**to.FEN**

``` r
to.FEN(setup()[1,])
```

Chess Data
==========

**Bash-managed scraping**

``` bash
#!/bin/bash
# obtain list of previously stored data to avoid duplication
aws s3 ls s3://jbchess/data --recursive > temp.txt

# iterate through a range of numbers
for n in $(seq 200 1000)
do

  # adjust both numbers to the proper order of magnitude
    first=$(($n*1000+1))
    last=$(($n*1000+1000))
    # record the beginning & ending range of numbers; include a timestamp
    echo start $first $last $(date)
    
    # pass the range of numbers to the scrape.chess.com function
    Rscript R/scrape.chess.com.R $first $last
    
    # move the acquired data to the bucket
    aws s3 mv data s3://jbchess/data --recursive
done
```

**acquire sample of chess data**

``` bash
# use the shell to extract sample of chess games:
aws s3 cp "s3://jbchess/data/chess.com IDs 1-1000.csv" "data/chess.com IDs 1-1000.csv"
```
