; Michael Gabilondo
; mgabilo@gmail.com
; Missionaries and Cannibals solver
;
(defvar *cannibals* '(C1 C2 C3 C4 C5))
(defvar *missionaries* '(M1 M2 M3 M4 M5))

; (mis-can) gets the initial state, goal and boat capacity from user input, and
; outputs one of the following.
;
; 1. If there is a solution, it outputs a listing of states, where each state is
; on the path from the initial state to the goal.
;
; 2. If there is not a solution, it outputs a listing of association lists of
; states that were generated (ie. the contents of CLOSED). These are of the
; form ( (state h par) ...)
(defun mis-can ()
  (prog (initial goal boat-cap)
		(format t "Enter the Initial State. ~%")
		(format t "Format:  ((LEFT SIDE ATOMS) (RIGHT SIDE ATOMS)) ~%")
		(format t "Example: ((M1 M2 M3 M4 C1 C2 C3 C4 B) ()) ~%")
		(setq initial (read))

		(format t "Enter the Goal State. ~%")
		(format t "Format:  ((LEFT SIDE ATOMS) (RIGHT SIDE ATOMS)) ~%")
		(format t "Example: (() (M1 M2 M3 M4 C1 C2 C3 C4 B)) ~%")
		(setq goal (read))
	
		(format t "Enter the Boat Capacity. E.g. 2 ~%")
		(setq boat-cap (read))

		(let ( (solution (mis-can-solve (list (list initial (heuristic initial goal) nil)) nil goal boat-cap)))
		  (cond
			((state-eq (caar solution) goal)
			 (format t "SOLUTION GENERATED. THE PATH TO THE GOAL IS DISPLAYED. ~%")
			 (dolist (x (rebuild-path solution (car solution))) (print x))
			 (format t " ~%")
			 (format t "THE FOLLOWING STATES WERE GENERATED. ~%")
			 (dolist (x solution) (print x)))
			(t
			 (format t "THERE IS NO SOLUTION. THE FOLLOWING (STATE HEURISTIC PARENT) TRIPLES WERE GENERATED. ~%")
			 (dolist (x solution) (print x)))))))

;(move source dest mis-num can-num) Moves (mis-num) missionaries and (can-num)
;cannibals from (source) to (dest) and returns ((new-source) (new-dest)). B
;from (source) is always moved, so take care that one of (mis-num) or (can-num)
;is non-zero -- the boat is not allowed to cross the river with no one on it.
;
;(source) is a list of atoms from the union of *cannibals*, *missionaries*, and {B}
;(dest) is a list of atoms from the union of *cannibals* and *missionaries*
;(mis-num) is an integer >= 0, indicating the number of missionaries to move to (dest)
;(can-num) is an integer >= 0, indicating the number of cannibals to move to (dest)
;&optinal arguments are for internal function use.
;
;Returns a list containing two sublists. The first sublist contains those atoms
;from (source) that were not moved to (dest). The second is the union of those
;atoms from (source) that were moved to (dest) and the original contents of
;(dest).
(defun move (source dest mis-num can-num &optional (boat-num 1) new-source)
  (cond
	((null source) (list new-source dest))

	((and (> mis-num 0) (member (car source) *missionaries*))
	 (move (cdr source) (cons (car source) dest) (- mis-num 1) can-num boat-num new-source))

	((and (> can-num 0) (member (car source) *cannibals*))
	 (move (cdr source) (cons (car source) dest) mis-num (- can-num 1) boat-num new-source))

	((and (> boat-num 0) (eq (car source) 'B))
	 (move (cdr source) (cons (car source) dest) mis-num can-num (- boat-num 1) new-source))

	(t (move (cdr source) dest mis-num can-num boat-num (cons (car source) new-source)))))


;(mc-count mc)
;(mc) is a list of atoms containing elements from union of *cannibals* and *missionaries* and {B}
;Returns a 3-tuple containing three integers: the first is the number of *missionaries*
;in (mc), the second is the number of *cannibals* in (mc), third is number of B's.
(defun mc-count (mc)
  (cond
	((null mc) '(0 0 0))
	((member (car mc) *missionaries*) (mapcar '+ '(1 0 0) (mc-count (cdr mc))))
	((member (car mc) *cannibals*) (mapcar '+ '(0 1 0) (mc-count (cdr mc))))
	((eq (car mc) 'B) (mapcar '+ '(0 0 1) (mc-count (cdr mc))))
	(t (mapcar '+ (mc-count (cdr mc))))))

;(count-atoms l)
;(l) is a list
;Returns the number of atoms in (l)
(defun count-atoms (l)
  (cond
	((null l) 0)
	((atom (car l)) (+ 1 (count-atoms (cdr l))))
	(t (count-atoms (cdr l)))))

;(valid-state-p state)
;(state) is ( (atoms from *cannibals* union *missionaries*) (ditto) )
;Returns t if both the left side and right side meet the constraint that the
;number of cannibals cannot exceed the number of missionaries whenever there is
;at least one missionary.
(defun valid-state-p (state)
  (let ((ls-count (mc-count (car state)))
		(rs-count (mc-count (cadr state))))
	(cond
	  ((and (< (car ls-count) (cadr ls-count)) (> (car ls-count) 0)) nil)
	  ((and (< (car rs-count) (cadr rs-count)) (> (car rs-count) 0)) nil)
	  (t t))))

;(gen-move-tuples boat-cap)
;(boat-cap) is the capacity of the boat
;(mc-source-count) is (#-mis #-can) on side of river we are moving from.
;
;Returns a list of 2-tuples. First # of each tuple is how many missionaries
;moving over; second is # of cannibals. Includes all such possibilities given
;the boat size constraints and number of mis & can on the original side. Does
;NOT take into account # cannibals <= # missionaries constraint.
(defun gen-move-tuples (boat-cap mc-source-count)
  (let ( (k (+ boat-cap 1)) (res nil) )
	(dotimes (i (+ boat-cap 1))
	  (dotimes (j k)
		(if (and (not (eq (+ i j) 0))
				 (<= i (car mc-source-count))
				 (<= j (cadr mc-source-count)))
		  (setq res (cons (list i j) res))))
	  (setq k (- k 1)))
	res))

;This is an auxiliary function for (move-generator). Like (move) except returns
;nil if the move is not legal; if the move is legal, returns what (move) does
;inside another list, so that (move-generator) handles the parenthesis
;correctly.
;
;(reverse-p), if not NIL, will return the new state as (dest source) instead of
;(source dest).
(defun move-if-valid (source dest mis-num can-num &optional reverse-p)
  (let ((state (move source dest mis-num can-num)))
	(cond
	  ((null (valid-state-p state)) nil)
	  (reverse-p (list (reverse state)))
	  (t (list state)))))

;Given the (state), returns a list of the legal moves returned by (move).
(defun move-generator (state boat-cap)
  (cond
	((member 'B (car state))
	 (mapcan (lambda (tup) (move-if-valid (car state) (cadr state) (car tup) (cadr tup)))
			 (gen-move-tuples boat-cap (mc-count (car state)))))
	((member 'B (cadr state))
	 (mapcan (lambda (tup) (move-if-valid (cadr state) (car state) (car tup) (cadr tup) 1))
			 (gen-move-tuples boat-cap (mc-count (cadr state)))))))

;(state-count state)
;Returns ( (#m #c #b) (#m #c #b) ) for the (state)
(defun state-count (state)
  (list (mc-count (car state)) (mc-count (cadr state))))

;(state-eq lhs rhs)
;(lhs) and (rhs) are states. Returns T if their left sides have the same (#m #c
;#b) and their right sides have the same (#m #c #b).
(defun state-eq (lhs rhs)
  (cond ((equal (state-count lhs) (state-count rhs)) t)))

; Returns the heuristic denoting how close state is to goal
(defun heuristic (state goal)
  (heuristic-aux (state-count state) (state-count goal)))

(defun heuristic-aux (state goal)
  (cond
	((null (car state)) 0)
	(t (+ (min (caar state) (caar goal)) (min (car (cadr state)) (car (cadr goal)))
		  (heuristic-aux (list (cdr (car state)) (cdr (cadr state)))
					 (list (cdr (car goal)) (cdr (cadr goal))))))))

; Returns the heuristic value representing the goal state
(defun goal-heuristic (goal)
  (heuristic goal goal))

; Generates an association list ( (child_1 heuristic parent) (child_2 h p) ...)
(defun gen-assoc (children parent goal)
  (mapcar (lambda (child) (list child (heuristic child goal) parent)) children))

;(member-assoc m l)
;(m) is a state
;(l) is a list of association lists
;Returns the association list X_i if any of the association lists X_i in (l)
;contain a state that is (state-eq) to (m) -- otherwise NIL
(defun member-assoc (m l)
  (cond
	((null l) nil)
	((state-eq  m (caar l)) (car l))
	(t (member-assoc m (cdr l)))))


; Returns T if state is not in (open-assoc) and not in (closed-assoc)
; (state) is a (state H parent-state)
; (open-assoc) and (closed-assoc) are lists elements of the form of (state)
(defun new-state-p (state open-assoc closed-assoc)
  (cond
	((or (member-assoc state open-assoc)
		  (member-assoc state closed-assoc)) nil)
	(t t)))

; Inserts children into open-assoc in order and if they have not already been
; generated.
(defun insert-open-assoc (children-assoc open-assoc closed-assoc)
  (cond
	((null children-assoc) open-assoc)
	((new-state-p (caar children-assoc) open-assoc closed-assoc)
	 (insert-open-assoc (cdr children-assoc) (insert-state-assoc (car children-assoc) open-assoc) closed-assoc))
	(t (insert-open-assoc (cdr children-assoc) open-assoc closed-assoc))))

; Inserts a (state h p) triple (st-assoc) into st-assoc-list) sorted by heuristic value
(defun insert-state-assoc (st-assoc st-assoc-list)
  (cond
	((null st-assoc-list) (list st-assoc))
	((>= (cadr st-assoc) (cadr (car st-assoc-list))) (cons st-assoc st-assoc-list))
	(t (cons (car st-assoc-list) (insert-state-assoc st-assoc (cdr st-assoc-list))))))

; Given initial state (open-assoc) as ( (state H nil) ), (closed-assoc) as nil,
; a goal state (goal) and (boat-cap), returns one of two things.
;
; 1. If there is a solution, returns an association list with the first
; association as (GOAL-STATE GOAL-HEURISTIC PARENT), and the rest of the
; associations are the elements that were generated and closed.
;
; 2. If there is no solution, returns an association list with all the elements
; that were generated and closed (none would be open); you can tell this apart
; from (1) by the lack of the goal association as the first assoc.
(defun mis-can-solve (open-assoc closed-assoc goal boat-cap)
  (cond 
	((null open-assoc) closed-assoc)
	((eq (cadr (car open-assoc)) (goal-heuristic goal))
	 (append open-assoc closed-assoc))
	(t (mis-can-solve (insert-open-assoc
						(gen-assoc (move-generator (caar open-assoc) boat-cap) (caar open-assoc) goal)
						(cdr open-assoc) (cons (car open-assoc) closed-assoc))
					  (cons (car open-assoc) closed-assoc) goal boat-cap))))

; Returns a list of states from the initial state to the goal, where
; (solved-assoc) is output from (mis-can-solve) and (goal-assoc-state) is the
; first element of that output (the goal assoc).
(defun rebuild-path (solved-assoc goal-assoc-state)
  (let ((parent-assoc-state (member-assoc (caddr goal-assoc-state) solved-assoc)))
	(cond
	  ((null parent-assoc-state) (list (car goal-assoc-state)))
	  (t (append  (rebuild-path solved-assoc parent-assoc-state) (list (car goal-assoc-state)) ))))) 

