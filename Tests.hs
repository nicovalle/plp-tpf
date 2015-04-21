import Grafo
import Tipos
import Lomoba
import Parser
import Test.HUnit

-- evaluar t para correr todos los tests
t = runTestTT allTests

allTests = test [
	"parser" ~: testsParser,
	"grafo" ~: testsGrafo
	]

testsParser = test [
	(Var "p") 						~=? (parse "p"),
	(And (Var "p") (Var "q")) 		~=? (parse "p && q"),
	(Or (Var "p") (Var "q")) 		~=? (parse "p || q"),
	(Or (Not (Var "p")) (Var "q"))	~=? (parse "!p || q"),
	(And (D (Var "p")) (Var "q")) 	~=? (parse "<>p && q"),
	(And (B (Var "p")) (Var "q")) 	~=? (parse "[]p && q"),
	(D (And (Var "p") (Var "q"))) 	~=? (parse "<>(p && q)"),
	(B (And (Var "p") (Var "q"))) 	~=? (parse "[](p && q)")]

testsGrafo = test [
	--nodos	
	[1] ~~? (nodos (agNodo 1 vacio)),
	[1,2] ~~? (nodos (agNodo 2 (agNodo 1 vacio))),
	--vecinos	
	[1] ~~? (vecinos (agEje (2,1) (agNodo 2 (agNodo 1 vacio))) 2 ),
	[] ~~? (vecinos (agEje (2,1) (agNodo 2 (agNodo 1 vacio))) 1 ),
	[1,2,3] ~~? (nodos((agEje(3,2) (agEje (1,3) (agEje (1,2)(agNodo 3 (agNodo 2 (agNodo 1 vacio)))))))),
	[2,3] ~~? (vecinos (agEje(3,2) (agEje (1,3) (agEje (1,2)(agNodo 3 (agNodo 2 (agNodo 1 vacio)))))) 1),
	[2] ~~? (vecinos (agEje(3,2) (agEje (1,3) (agEje (1,2)(agNodo 3 (agNodo 2 (agNodo 1 vacio)))))) 3),
	[] ~~? (vecinos (agEje(3,2) (agEje (1,3) (agEje (1,2)(agNodo 3 (agNodo 2 (agNodo 1 vacio)))))) 2),	
	--sacarNodo
	[2] ~~? (nodos(sacarNodo 1 ((agNodo 2 (agNodo 1 vacio))))),	
	[] ~~? (vecinos (sacarNodo 2 (agEje(3,2) (agEje (1,3) (agEje (1,2)(agNodo 3 (agNodo 2 (agNodo 1 vacio))))))) 3 ),
	[3] ~~? (vecinos (sacarNodo 2 (agEje(3,2) (agEje (1,3) (agEje (1,2)(agNodo 3 (agNodo 2 (agNodo 1 vacio))))))) 1 ),
	[1,3] ~~? (nodos (sacarNodo 2 (agEje(3,2) (agEje (1,3) (agEje (1,2)(agNodo 3 (agNodo 2 (agNodo 1 vacio)))))))),	
	--lineal	
	[1,2,3,4] ~~? (nodos (lineal [1,2,3,4])), 	
	[2] ~~?	(vecinos (lineal [1,2,3,4]) 1),
	[3] ~~?	(vecinos (lineal [1,2,3,4]) 2),
	[4] ~~?	(vecinos (lineal [1,2,3,4]) 3),
	[] ~~?	(vecinos (lineal [1,2,3,4]) 4)
	
	]

---------------
--  helpers  --
---------------

-- idem ~=? pero sin importar el orden
(~~?) :: (Ord a, Eq a, Show a) => [a] -> [a] -> Test
expected ~~? actual = (sort expected) ~=? (sort actual)
	where
		sort = foldl (\r e -> push r e) []
		push r e = (filter (e<=) r) ++ [e] ++ (filter (e>) r)
