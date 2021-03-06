module Lomoba where
import Grafo
import Tipos
import qualified Data.List as List (union, intersect)


-- ---------------------------------Sección 6--------- Lomoba ---------------------------

-- Ejercicio 10
-- Realiza recursión estructural sobre expresiónes.
foldExp :: (Prop -> b) -> (b -> b) -> (b -> b -> b) -> (b -> b -> b) -> (b -> b) -> (b -> b) -> Exp -> b
foldExp fVar fNot fOr fAnd fD fB ei =
	let frec = foldExp fVar fNot fOr fAnd fD fB
	in case ei of
		Var p -> fVar p
		Not e -> fNot (frec e)
		Or e1 e2 -> fOr (frec e1) (frec e2)
		And e3 e4 -> fAnd (frec e3) (frec e4)
		D e5 -> fD (frec e5)
		B e6 -> fB (frec e6)

-- Ejercicio 11
-- Devuelve un la visibilidad de una fórmula, es decir cuánto del grafo se
-- utiliza para evaluarla.
visibilidad :: Exp -> Integer
visibilidad = foldExp fVar fNot fOr fAnd fD fB
	where   fVar = const 0
		fNot = id
		fOr = max
		fAnd = max
		fD = (1+)
		fB = (1+)

-- Ejercicio 12
-- Lista las variables que aparecen en la fórmula.
extraer :: Exp -> [Prop]
extraer = foldExp fVar fNot fOr fAnd fD fB
	where   fVar p = [p]
		fNot = id
		fOr = List.union
		fAnd = List.union
		fD = id
		fB = id

-- Ejercicio 13
-- Dado un modelo, decide si una fórmula es verdadera en un mundo.
eval :: Modelo -> Mundo -> Exp -> Bool
eval m w e = eval' m e w

eval' :: Modelo -> Exp -> Mundo -> Bool
eval' m@(K g v) = foldExp fVar fNot fOr fAnd fD fB
	where	fVar x w = elem w (v x)
		fNot rec w = not (rec w)
		fOr recI recD w = (recI w) || (recD w)
		fAnd recI recD w = (recI w) && (recD w)
		fD rec w = any rec (vecinos g w)
		fB rec w = all rec (vecinos g w)

-- Ejercicio 14
-- Devuelve todos los mundos de un modelo para los que vale una expresión.
valeEn :: Exp -> Modelo -> [Mundo]
valeEn e m@(K g v) = filter (eval' m e) (nodos g)

-- Ejercicio 15
-- Devuelve un modelo en el que para todos los mundos vale la expresión dada.
quitar :: Exp -> Modelo -> Modelo
quitar e m@(K g v) = K g' v'
	where   g' = foldl (flip sacarNodo) g (noValeEn e m)
		v' p = List.intersect (nodos g') (v p)

noValeEn :: Exp -> Modelo ->[Mundo]
noValeEn e m@(K g v) = filter (not . eval' m e) (nodos g)

-- Ejercicio 16
-- Dado un modelo, indica si para todos sus mundos vale una expresión.
cierto :: Modelo -> Exp -> Bool
cierto m@(K g v) e = all (eval' m e) (nodos g)
