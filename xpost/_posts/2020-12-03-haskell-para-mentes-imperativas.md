---
layout: post
title: Haskell para mentes imperativas
date: 2020-12-03
canonical_url: https://dev.to/florius/haskell-para-mentes-imperativas-4n7k
summary: En este post quiero explorar algunas cosas que creo que me hubiesen servido para aprender Haskell. Teniendo una base en algún lenguaje imperativo, usar esta para programar en Haskell.
---

_El post original se puede leer en mi [dev.to]({{ page.canonical_url }})._

Browseando YouTube encontré una playlist con un nombre muy interesante: “[Haskell for Imperative Programmers](https://www.youtube.com/watch?v=Vgu82wiiZ90&list=PLe7Ei6viL6jGp1Rfu0dil1JH1SHk9bgDV)” en donde el autor Philipp Hagenlocher explica conceptos de Haskell en videos cortos, concisos, con varios ejemplos y hasta algunos ejercicios. Lo que me inspiró a pensar cómo podría aprender alguien que tiene raíces en un paradigma imperativo. Por suerte no tuve que usar mucho la imaginación, ya que yo comencé con lenguajes imperativos, y en mi trabajo utilizo mayoritariamente el paradigma de objetos.

En este post quiero explorar algunas cosas que creo que me hubiesen servido para aprender Haskell. Teniendo una base en algún lenguaje imperativo, usar esta para programar en Haskell.

Si crees que entras en esta categoría, continúa leyendo.

### Prefacio
En este post haré uso de analogías y de patrones fuertemente asociados a la programación imperativa, de tal forma que la carga para aclimatarse al nuevo paradigma sea la menor posible, pero no considero esta la mejora forma de programar de forma funcional. Mi razonamiento es que: usando nuestro conocimiento previo ayude a comenzar a escalar la pendiente que es aprender un paradigma nuevo, y que esto a su vez dispare nuevas e interesantes investigaciones.


## Variables

Veo muy comúnmente la cara de espanto cuando uno habla de un lenguaje, como Haskell, donde la inmutabilidad está por defecto. Prontamente surge la pregunta de “cómo puedo asignar una variable” o “como puedo cambiar el valor de un contador”.
Recordemos que Haskell es un lenguaje de programación [Turing completo](https://es.wikipedia.org/wiki/Turing_completo), así que no es que *no se pueda* hacer, solo que hay que reconocer  que hay diferentes formas de afrontar un problema.

En Haskell, el símbolo `=` no representa una asignación, si no es más próximo a la idea matemática del `=` donde lo leemos (e interpretamos) como que algo **es** otra cosa.

En un lenguaje imperativo `x = 3` lo leemos como “asignamos el valor `3` a la variable `x`”, donde en un paradigma funcional, lo deberíamos interpretar como “`x` *es* 3”. `x` no puede cambiar. `x` simplemente *es*. 

Se que esta justificación suele no quitar el pavor. Tras indagar más a fondo, suelo descubrir que hay dos temas distintos (pero muy  sobrelapados en los lenguajes imperativos):

Ponerle nombre a algo “intermedio”. Por ejemplo, si uno está escribiendo un método, y ve que hay una operación que se repite dos veces, suele ser considerado una buena práctica extraer lo común a una “variable” y ponerle nombre. Por ejemplo, podríamos empezar con un método:

{% highlight java %}
Int foo(List<Int> xs) {
  if(xs.size() > 3)
    return -1;
  else
    return xs.size();
}
{% endhighlight %}

y luego refactorizar a algo como:

{% highlight java %}
Int foo(List<Int> xs) {
  Int tamaño = xs.size();
  if(tamaño > 3)
    return -1;
  else
    return tamaño;
}
{% endhighlight %}

En este acaso `tamaño` si bien es una “variable”, su intención no es variar en el contexto de la función. Es tan común y útil poder aseverar sobre qué cosas no cambian, que en otros lenguajes existe la idea que las “variables” puedan ser constantes (vaya oxímoron). Como `const` en JavaScript y PHP, `val`/`var`en Kotlin, variables en mayúsculas en Python o `final` en Java.

Lectores atentos pueden reconocer un potencial problema en esta refactorización, en donde no podemos asegurar 100% que el método `List::size()` no cambia la lista, y que invocarlo 2 veces como en el código de “antes” podría no ser igual al código de “despues” en donde solo se invoca una vez. Dado que conocemos la semántica de `List::size()`, podemos descansar que no va a alterar la lista; pero a veces, por la naturaleza de la mutabilidad, esto lleva a problemas. Toda una categoría de problemas que simplemente no pueden ocurrir en un mundo inmutable 😉.

Esto mismo podríamos lograr en Haskell con palabras reservadas como `let … in` o `where`.

{% highlight haskell %}
foo :: [Int] -> Int
foo xs = if length xs then
         -1
       else
         length xs
{% endhighlight %}
Y luego del refactor:
{% highlight haskell %}
foo :: [Int] -> Int
foo xs =
   let tamaño = length xs
   in if tamaño > 3 then
         -1
       else
         tamaño
{% endhighlight %}
o
{% highlight haskell %}
foo :: [Int] -> Int
foo xs = if tamaño > 3 then
         -1
       else
         tamaño
   where tamaño = length xs
{% endhighlight %}   

Si bien hacen lo mismo, tienen sutiles diferencias a las entraré en detalle (pero si está aquí: [Let vs. Where - HaskellWiki](https://wiki.haskell.org/Let_vs._Where )).

## Cosas que cambian

El otro *sabor* de variables, es el de algo que cambia; y aquí, no tenemos suerte. No vamos a poder hacerlo. Pero eso no quita que podamos generar abstracciones para poder escribir algo que *se parezca*.

Pero antes de hablar de cosas que cambian, primero necesitamos estar de acuerdo en algunas convenciones. Cosas como
{% highlight c %}
void bar(int* x){
    *x += 4;
}
{% endhighlight %}
En donde una función altera el valor que se le pasa son *el mal*, y no poder hacerlo es un *feature* (Aunque me encanta la idea de [Pure destination-passing style in Linear Haskell](https://www.tweag.io/blog/2020-11-11-linear-dps/) cuando se apalanca del maravilloso sistema de tipos).

Algo mucho más sensible sería una función que tome el argumento y devuelva un nuevo número, resultado de la suma del argumento y 4. 

Pero no siempre es tan sencillo. A veces tenemos varias mutaciones encadenadas, o unas que dependen de otras; por lo que podemos aplicar este algoritmo mental:
Cada vez que fuésemos a cambiar una variable, en realidad utilizaremos una nueva variable que sea el resultado del cambio, y de ahora en adelante, utilizar el nuevo nombre.

Por ejemplo, con la nueva herramienta de `let … in`:
{% highlight ruby %}
def buzz (n)
  ret = n
  ret = ret % 3
  ret = ret +2
  ret = ret + 5
  ret > 3
end
{% endhighlight %}
{% highlight haskell %}
buzz n =
  let 
       x0 = n
       x1 = x0 `mod` 3
       x2 = x1 + 2
       x3 = x2 + 5
  In x3 > 3
{% endhighlight %}
Si esta forma de escribir parece tediosa (lo es!), al final de la próxima sección volveremos sobre esto, pero todavía tenemos algo que podemos hacer. Revisemos qué es lo que es tan inconveniente: nombrar los pasos intermedios (`x0 - x3`) ¿Podemos no hacerlo?.

De esta forma nos acercamos a un patrón muy común en funcional, en donde uno tiene funciones intermedias que toman un valor, y devuelven “el nuevo” valor. Podemos concatenar estas operaciones (que hablan de cambios, no de variables).

Imaginemos el mismo ejemplo, pero vamos a re escribirlo en pequeñas funciones intermedias que cambien el valor. 
{% highlight haskell %}
buzz n =
  let f0 x = x `mod` 3
       f1 x = x + 2
       f2 x = x + 5
       f3 x = x > 3
      
       x0 = n
       x1 = f0 x0
       x2 = f1 x1
       x3 = f2 x2
  In f3 x3
{% endhighlight %}
Lamentablemente como es un ejemplo tan sintético, los nombres de las funciones intermedias serán malos; pero espero que puedan imaginarse que estas funciones sean cosas como `incrementarEdad`, `extraerDinero` u otro nombre más cercano al dominio de lo que esten programando.

Por ello voy a cambiar levemente el ejemplo para tener algo que sea más humanamente legible.
{% highlight haskell %}
numeroValidador x = x `mod` 3
normalizarValidador x = x + 2
migrarCoeficiente x = x + 5
esValido x = x > 3

tarjetaValida n =
       x0 = numeroValidador n
       x1 = normalizarValidador x0
       x2 = migrarCoeficiente x1
  In esValido x2
{% endhighlight %}
Ahora podemos intentar pensar sobre nuestra `tarjetaValida`, donde lo que tiene que pasar es, en orden: 

1. Dado un número pasado como parámetro (`n`)
2. Tomamos el número validador (`x mod 3`)
3. Lo normalizamos (`x + 2`)
4. Migramos el coeficiente (`x + 5`)
5. Y chequeamos que sea válido (`x > 3`)

Probablemente todavía no sea evidente, pero ahora podemos hacer un refactor de “inline” en cada variable intermedia (`x0 - x3`). Empecemos con `x3` e iremos ineline-ando de a una
{% highlight haskell %}
tarjetaValida n =
       x0 = n
       x1 = numeroValidador x0
       x2 = normalizarValidador x1
  In esValido (migrarCoeficiente  x1)
{% endhighlight %}
{% highlight haskell %}
tarjetaValida n =
       x0 = n
       x1 = numeroValidador x0
  In esValido (migrarCoeficiente  (normalizarValidador  x1))
{% endhighlight %}
{% highlight haskell %}
tarjetaValida n =
       x0 = n
  esValido  (migrarCoeficiente (normalizarValidador (numeroValidador x0)))
{% endhighlight %}
{% highlight haskell %}
tarjetaValida n =
  esValido  (migrarCoeficiente (normalizarValidador (numeroValidador n)))
{% endhighlight %}
Esto se parece mucho más a la descripción funcional de `tarjetaValida`, pero está escrito “al revés”. Por razones como esta existen [combinadores como `&`](https://hackage.haskell.org/package/base-4.14.0.0/docs/Data-Function.html#v:-38- ), donde hablando mal y pronto, éste es el operador de _aplicación reversa_.

{% highlight haskell %}
tarjetaValida n =
  n &
  numeroValidador &
  normalizarValidador &
  migrarCoeficiente &
  esValido
{% endhighlight %}

Es interesante notar como todas nuestras funciones de “cambio” tienen la misma firma: `:: Int -> Int`. De forma más genérica, son funciones que toman un valor de un tipo, y _devuelven_ algo del mismo tipo.

### Aplicación parcial
Con el código que tenemos hasta aquí; podríamos cambiarlo para que `migrarCoeficiente` no siempre sume 5, si no que pueda ser parametrizable por una letra.
Sabiendo que hay una función que transforma una letra a un número [`ord :: Char -> Int`](https://hackage.haskell.org/package/base-4.14.0.0/docs/Data-Char.html#v:ord ) 
Podríamos cambiar `migrarCoeficiente` a:
{% highlight haskell %}
migrarCoeficiente :: Char -> Int -> Int
migrarCoeficiente letra x = x + (ord caracter)
{% endhighlight %}
Ahora nuestra `tarjetaValida` no sufre muchos cambios:
{% highlight haskell %}
tarjetaValida n =
  n &
  numeroValidador &
  normalizarValidador &
  migrarCoeficiente 'f' &
  esValido
{% endhighlight %}
Y eso fué gracias a [la currificación](http://aprendehaskell.es/content/OrdenSuperior.html) de todas las funciones en Haskell!

### A veces

Otro gran “hack” que nos permite la mutabilidad, es la de cambiar el valor, pero solo según un flujo de control. Algo como:
{% highlight python %}
def qux(n):
  ret = n
  if(ret % 3):
    ret = 10
  return ret
{% endhighlight %}
En donde asignamos una variable que según uno u otro flujo de control puede cambiar. Siempre podremos reescribir esto de forma inmutable. Por ejemplo
{% highlight haskell %}
qux n = if n `mod` 3 == 0 then 10 else n
{% endhighlight %}

Interesante notar que necesitamos un `else` que “deje todo como estaba”, pues no podemos “no hacer nada” en esta forma de escribirlo.


## Monadas

_(No podía ser un post de Haskell, y no mencionar a las monadas)_

Una idea en la programación imperativa muy arraigada es que uno escribe una línea debajo de la otra, y esto hace que se ejecuten en ese orden.
Tan arraigada que casi no se considera una decisión del lenguaje, pero lo es! Es una decisión de diseño, y una que en un paradigma funcional es fácil escaparse.

Pero a veces, queremos ordenar una secuencia de cosas. Recordemos el ejemplo anterior de `buz`. Hay una monada (y probablemente [miles de](http://aprendehaskell.es/content/MasMonadas.html) [tutoriales de](https://gist.github.com/sdiehl/8d991a718f7a9c80f54b) [como](https://wiki.haskell.org/State_Monad) [implementarla](https://mmhaskell.com/monads/state)) llamada “state” que representa una forma de secuenciar operaciones, e ir mutando un valor. Por lo que uno podría escribir algo mucho más parecido a la forma imperativa:

{% highlight haskell %}
--            |----- Va a ir mutando un Int
--            v   v- va a retornar un booleano
buz :: State Int Bool
buz =
  get >>= (\ret -> set (ret `mod` 3)) >>
  get >>= (\ret -> put (ret + 2)) >>
  get >>= (\ret -> set (ret + 5)) >>
  get >>= (\ret -> return (ret > 3))
{% endhighlight %}

Cada `ret` en este caso solo existe dentro del lambda _(todo lo que esté entre `(\` y `)`)_

Muchas veces se ven las monadas con el [_azúcar sintáctico_](https://es.wikipedia.org/wiki/Az%C3%BAcar_sint%C3%A1ctico ) de la notación `do`, que lo hace muy conveniente porque nos deja, como en un paradigma imperativo, escribir una línea debajo de la otra.

### Monadas Cont.
Otra gran razón para implementar una secuencia de operaciones, es que estas puedan fallar. El fallo en cualquier renglón invalide toda la computación. Pensemos en métodos que podrían lanzar excepciones.
Para esto también existe una monada! Y podríamos escribir algo como:
{% highlight swift %}
func precio(itemConNombre nombre: String) throws {
        guard let item = inventario[name] else {
            throw Errores.noExiste(nombre: nombre)
        }

        guard item.cantidad > 0 else {
            throw Errores.fueraDeStock
        }

        item.price
}
{% endhighlight %}

De esta forma
{% highlight haskell %}
data Errores = FueraDeStock | NoExiste String

buscar :: Inventario -> String -> Maybe Item
buscar = (...)

precio :: String -> Either Errores Int
precio nombre = do
    item <- maybe (Left (NoExiste nombre)) Right itemEncontrado -- (1)
    when (cantidad item > 0) (Left FueraDeStock)
    return precio item
  where
    itemEncontrado :: Maybe Item
    itemEncontrado = buscar inventario nombre
{% endhighlight %}

La idea de la función [`maybe`](https://hackage.haskell.org/package/base-4.14.0.0/docs/Prelude.html#v:maybe) es poder extraer el valor de un `Maybe` (algo que puede o no estar). En el caso de que pueda fallar, _devolveremos_ un `Left` (recordemos, representaría como lanzar una excepción), y en el caso que hubiese un `Item`, devolveremos un `Right`.

De esta forma, no _ejecutaremos_ el `return` hasta que no pasen las dos condiciones anteriores.


## Getter y Setter

Por último, quiero tocar algo de modelado, y la parte de lo que menos quiero escribir, porque es la que más se separa del paradigma; pero no obstante puedo ver cómo alguien puede estar tentado a utilizar herramientas de modelado de paradigmas que ya conoce, y pensar en un [_record_](http://aprendehaskell.es/content/ClasesDeTipos.html) es parecido a un objeto. Pero si así fuera… donde ponemos los métodos de este objeto?! (Sin entrar en el mundo de [`lens`](https://hackage.haskell.org/package/lens)).
No voy a objetar (🤭) porque se que yo lo hice durante mucho tiempo, así que mientras que sepamos que hay _tela para cortar_, por ahora puedo vivir con que pensemos que son objetos.
{% highlight csharp %}
class Point
{
    public int edad;
}
{% endhighlight %}

podríamos escribirlo así:
{% highlight haskell %}
data Persona = Persona { edad :: Int }
{% endhighlight %}
Y tendremos _gratis_ la función `edad :: Persona -> Int` que “saca” la edad de una persona. Cual un getter, y la construcción:
{% highlight haskell %}
cambiarEdad :: Int -> Persona -> Persona
cambiarEdad nuevaEdad persona = persona { edad = nuevaEdad }
{% endhighlight %}
Como un setter. Pero, como en OOP no estamos limitados a simplemente asignar el nuevo valor; podríamos hacer lo que queramos!
{% highlight haskell %}
cambiarEdad :: Int -> Persona -> Persona
cambiarEdad nuevaEdad persona = persona { edad = nuevaEdad + 3 }
{% endhighlight %}

Podemos encontrar un patrón recurrente, donde tengamos funciones que _terminen_ con el tipo: `foo :: … -> Algo -> Algo`. Si recordamos el ejemplo de `tarjetaValida`, todas las funciones intermedias que teníamos eran del tipo: `:: Int -> Int`, y el ejercicio al lector hubiera generado una función con el tipo: `:: Char -> Int -> Int`. Podemos pensar en toda esta familia de funciones como funciones que “alteran”. Además ahora ya sabemos cómo combinarlas!
Por ejemplo, concatenar listas  [`(++) :: [a] -> [a] -> [a] `](https://hackage.haskell.org/package/base-4.14.0.0/docs/GHC-List.html#v:-43--43-) en donde toma una primera lista y una segunda, y las “altera” (recordando que en realidad lo que hace es _devolver_ una nueva lista) o tomar los primeros `n` elementos ([`take :: Int -> [a] -> [a]`](https://hackage.haskell.org/package/base-4.14.0.0/docs/GHC-List.html#v:take)). Hay muchísimas funciones como estas, y probablemente escribamos tantas de estas como “métodos” podrían tener nuestros objetos, si lo modelamos en OOP.

{% highlight kotlin %}
class Persona(var edad: Int, var altura: Int) {
    fun crecer(años : Int) {
                 this.edad += años
                 this.altura += años*2
    }
}
{% endhighlight %}
{% highlight haskell %}
data Persona = Persona { edad :: Int, altura :: Int }

crecer :: Int -> Persona -> Persona
crecer años persona = Persona { edad = edad persona + años,  altura = altura persona + (años * 2) }
{% endhighlight %}

## Fin
Espero que con estas herramientas, el prospecto de programar en Haskell sea menos aterrorizador.
