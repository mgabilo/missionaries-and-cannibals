# Missionaries and cannibals solver

This is a solver written in common Lisp for the missionaries and cannibals problem. From the [Wikipedia article](https://en.wikipedia.org/wiki/Missionaries_and_cannibals_problem):
 
*In the missionaries and cannibals problem, three missionaries and
three cannibals must cross a river using a boat which can carry at
most two people, under the constraint that, for both banks, if there
are missionaries present on the bank, they cannot be outnumbered by
cannibals (if they were, the cannibals would eat the missionaries).
The boat cannot cross the river by itself with no people on board.*


In this program, the initial state and goal state are configurable,
as well as the number of missionaries and cannibals, and the number
of passengers the boat can hold. 


## Example usage

Run clisp from the command line and type the following within the interpreter.

```
(load "mc.lisp")
(mis-can)
```

You will be prompted to set up the problem.


```
Enter the Initial State. 
Format:  ((LEFT SIDE ATOMS) (RIGHT SIDE ATOMS))
Example: ((M1 M2 M3 M4 C1 C2 C3 C4 B) ())
```

I will enter the following:

```
((M1 M2 M3 C1 C2 C3 B) ())
```

This stands for three missionaries and three cannibals (and the boat)
on the starting side. You will be prompted to enter the goal state.

```
Enter the Goal State. 
Format:  ((LEFT SIDE ATOMS) (RIGHT SIDE ATOMS))
Example: (() (M1 M2 M3 M4 C1 C2 C3 C4 B))
```

I will enter the following:

```
(() (M1 M2 M3 C1 C2 C3 B))
```

This stands for the three missionaries, three cannibals, and the boat
on the ending side.  You will then be promted to enter the boat
capacity. I will enter 2.

The program produces the following output.

```
SOLUTION GENERATED. THE PATH TO THE GOAL IS DISPLAYED.

((M1 M2 M3 C1 C2 C3 B) NIL)
((C3 M3 M2 M1) (B C2 C1))
((C2 B C3 M3 M2 M1) (C1))
((M1 M2 M3) (C3 B C2 C1))
((B C3 M1 M2 M3) (C1 C2))
((M3 C3) (M2 M1 B C1 C2))
((C1 B M2 M3 C3) (C2 M1))
((C3 C1) (M3 M2 B C2 M1))
((C2 B C3 C1) (M1 M2 M3))
((C1) (C3 B C2 M1 M2 M3))
((B C3 C1) (M3 M2 M1 C2))
(NIL (C1 C3 B M3 M2 M1 C2))
THE FOLLOWING STATES WERE GENERATED.

((NIL (C1 C3 B M3 M2 M1 C2)) 7 ((B C3 C1) (M3 M2 M1 C2)))
(((M1 B C1) (M3 M2 C2 C3)) 4 ((C1) (C3 B C2 M1 M2 M3)))
(((B C3 C1) (M3 M2 M1 C2)) 4 ((C1) (C3 B C2 M1 M2 M3)))
(((C1) (C3 B C2 M1 M2 M3)) 6 ((C2 B C3 C1) (M1 M2 M3)))
(((C2 B C3 C1) (M1 M2 M3)) 3 ((C3 C1) (M3 M2 B C2 M1)))
(((C3 C1) (M3 M2 B C2 M1)) 5 ((C1 B M2 M3 C3) (C2 M1)))
(((C1 B M2 M3 C3) (C2 M1)) 2 ((M3 C3) (M2 M1 B C1 C2)))
(((M3 C3) (M2 M1 B C1 C2)) 5 ((B C3 M1 M2 M3) (C1 C2)))
(((B C3 M1 M2 M3) (C1 C2)) 2 ((M1 M2 M3) (C3 B C2 C1)))
(((M1 M2 M3) (C3 B C2 C1)) 4 ((C2 B C3 M3 M2 M1) (C1)))
(((C2 B C3 M3 M2 M1) (C1)) 1 ((C3 M3 M2 M1) (B C2 C1)))
(((C3 C2 M3 M2 M1) (B C1)) 2 ((M1 M2 M3 C1 C2 C3 B) NIL))
(((C3 C2 M3 M2) (B C1 M1)) 3 ((M1 M2 M3 C1 C2 C3 B) NIL))
(((C3 M3 M2 M1) (B C2 C1)) 3 ((M1 M2 M3 C1 C2 C3 B) NIL))
(((M1 M2 M3 C1 C2 C3 B) NIL) 0 NIL)
NIL
```


## License

This project is licensed under the MIT License (see the [LICENSE](LICENSE) file for details)


