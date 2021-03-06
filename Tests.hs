import Grafo
import Tipos
import Lomoba
import Parser
import Test.HUnit

-- evaluar t para correr todos los tests
t = runTestTT allTests

allTests = test [
	"parser" ~: testsParser,
	"grafo" ~: testsGrafo,
	"lomoba" ~: testsLomoba
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
	--nodos	y agNodo
	[1] ~~? (nodos (agNodo 1 vacio)),
	[1,2] ~~? (nodos (agNodo 2 (agNodo 1 vacio))),

	--vecinos y egEje
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
	[] ~~?	(vecinos (lineal [1,2,3,4]) 4),

	--union
	[1,2,3] ~~? (nodos (union (agEje (1,2) (agNodo 2 (agNodo 1 vacio))) (agEje (3,1) (agEje (1,3) (agNodo 3 (agNodo 1 vacio)))))),
	[2,3] ~~? (vecinos (union (agEje (1,2) (agNodo 2 (agNodo 1 vacio))) (agEje (3,1) (agEje (1,3) (agNodo 3 (agNodo 1 vacio))))) 1),
	[] ~~? (vecinos (union (agEje (1,2) (agNodo 2 (agNodo 1 vacio))) (agEje (3,1) (agEje (1,3) (agNodo 3 (agNodo 1 vacio))))) 2),
	[1] ~~? (vecinos (union (agEje (1,2) (agNodo 2 (agNodo 1 vacio))) (agEje (3,1) (agEje (1,3) (agNodo 3 (agNodo 1 vacio))))) 3),
	[1,2,3,4] ~~? (nodos (union (vacio) (lineal [1,2,3,4]))),	
	
	--clasura	
	[1,2,3,4] ~~? (nodos (clausura (lineal [1,2,3,4]))),
	[1,2,3,4] ~~? (vecinos (clausura (lineal [1,2,3,4])) 1),
	[2,3,4] ~~? (vecinos (clausura (lineal [1,2,3,4])) 2),
	[3,4] ~~? (vecinos (clausura (lineal [1,2,3,4])) 3),
	[4] ~~?(vecinos (clausura (lineal [1,2,3,4])) 4)
	]

testsLomoba = test [
	-- foldExp
        exp1 ~=? (foldExp Var Not Or And D B exp1),

	-- visibilidad
	0 ~=? (visibilidad (parse "p")),
	1 ~=? (visibilidad (parse "<>p")),
	1 ~=? (visibilidad (parse "!<>p")),
	2 ~=? (visibilidad (parse "<>!<>p")),
	2 ~=? (visibilidad (parse "<><>p || <><>q")),
	3 ~=? (visibilidad (parse "<>(<>p || <><>q)")),
	3 ~=? (visibilidad (parse "[](<>p && <>[]q)")),

	-- extraer
	["p"] ~~? (extraer (parse "p")),
	["p"] ~~? (extraer (parse "<>p")),
	["p"] ~~? (extraer (parse "[]p")),
	["p", "q"] ~~? (extraer (parse "p||q")),	
	["p", "q"] ~~? (extraer (parse "p&&q")),
	["p"] ~~? (extraer (parse "<><>p || <><>p")),
	["p", "q", "r"] ~~? (extraer (parse "(p||q)&&[]<>r")),	
	["p", "q", "r"] ~~? (extraer (parse "<>((p||q)&&[]<>r)")),

	-- eval
	True ~=? eval modelo1 1 (parse "p"),
	False ~=? eval modelo1 1 (parse "q"),

	True ~=? eval modelo1 4 (parse "r && q"),
	False ~=? eval modelo1 4 (parse "p && q"),

	True ~=? eval modelo1 1 (parse "p || q"),
	False ~=? eval modelo1 2 (parse "p || q"),

	True ~=? eval modelo1 2 (parse "!p || q"),
	False ~=? eval modelo1 1 (parse "!p || q"),
	True ~=? eval modelo1 3 (parse "!p || q"),

	False ~=? eval modelo1 1 (parse "<>p && p"),
	True ~=? eval modelo1 1 (parse "<>q && p"),

	True ~=? eval modelo1 1 (parse "[]r"),
	False ~=? eval modelo1 1 (parse "[]q"),

	False ~=? eval modelo1 1 (parse "<>(p && q)"),
	True ~=? eval modelo1 1 (parse "<>(r && q)"),

	True ~=? eval modelo1 2 (parse "[](!p && q)"),

	-- valeEn
	[1] ~~? valeEn (parse "p") modelo1,
	[2,3,4] ~~? valeEn (parse "!p") modelo1,
	[3,4] ~~? valeEn (parse "q") modelo1,
	[1,2] ~~? valeEn (parse "<>q") modelo1,
	[2,3,4] ~~? valeEn (parse "[]q") modelo1,
	[1,3,4] ~~? valeEn (parse "[]r") modelo1,
	[4] ~~? valeEn (parse "r && q") modelo1,
	[1,2,3,4] ~~? valeEn (parse "r || (q || p)") modelo1,
	[1,3] ~~? valeEn (parse "!r && (q || p)") modelo1,
	[] ~~? valeEn (parse "s") modelo1,
	
	
	--quitar
	[1] ~~? let (K g _) = quitar (parse "p") modelo1 in nodos g,
	[4,2] ~~? let (K g _) = quitar (parse "r") modelo1 in nodos g,
	[4] ~~? let (K g _) = quitar (parse "r&&q") modelo1 in nodos g,
	[1,3,4] ~~? let (K g _) = quitar (parse "[]r") modelo1 in nodos g,
	[1] ~~? let (K g _) = quitar (parse "<>r") modelo1 in nodos g,

	--cierto
	True ~=? cierto (K vacio (const [])) (parse "p"),
	True ~=? cierto (K vacio (const [])) (parse "[]p"),
	False ~=? cierto modelo1 (parse "p"),
	True ~=? cierto modelo1 (parse "[][]q")
	]

modelo1 = K (union (lineal [1,2,3]) (lineal [1,4]) ) v1
	where	v1 "p" = [1] 
		v1 "q" = [3,4]
		v1 "r" = [2,4]
		v1 _ = []

exp1 = parse "<>[]p || q && r"

---------------
--  helpers  --
---------------

-- idem ~=? pero sin importar el orden
(~~?) :: (Ord a, Eq a, Show a) => [a] -> [a] -> Test
expected ~~? actual = (sort expected) ~=? (sort actual)
	where
		sort = foldl (\r e -> push r e) []
		push r e = (filter (e<=) r) ++ [e] ++ (filter (e>) r)
