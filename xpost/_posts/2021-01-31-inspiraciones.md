---
layout: post
title: Inspiraciones
date: 2021-01-31
canonical: https://dev.to/florius/inspiraciones-824
summary: ¿Te pasa de querer programar algo y no saber que? tengo un bloqueo de ideas hace tiempo, quiero hacer algo con xxx y no se me ocurre qué hacer.
---

_El post original se puede leer en mi [dev.to]({{ page.canonical }})._

> Te pasa de querer programar algo y no saber que? tengo un bloqueo de ideas hace tiempo, quiero hacer algo con xxx y no se me ocurre qué /cazzo/ hacer

Así empezó la conversación con un amigo. Después de hablar un poco, creo haber destilado un par de ideas que me gustaría compartir

## ¿Por qué yo?

> **Q**: Habiendo miles de otros posts de miles de otras personas -muchas mejor calificadas que yo-, por qué leer este?
>
> **A**: Creo que mi enfoque es mucho más especifico del que eh encontrado: Proyectos personales de programación, cuyo principal driver[^1] es aprender algo nuevo.

### Prove it
En mi porfolio ([florius.com.ar](https://florius.com.ar/)) podrás ver alguno de los proyectos más recientes y más interesantes. No son muchísimos, pero son algunos. Siempre estoy tinkering[^2] con algo nuevo.

## Fuentes de inspiración
Voy a separar la inspiración en 3 categorías, no porque una sea más "fácil" o menos costosa; si no porque he conocido personas que están muy entonadas con una u otra categoría, y tal vez alguna de esta resuene más contigo.

### Level 1 - Directo
En el trabajo, me pasa a veces que estoy haciendo algo, y pienso
> “Uh, esto sería super guay si fuese así”

Pero caigo en la realidad de que no habría forma que pueda completar el feature en el tiempo si hiciera todo ese cambio, ni que me aprueben un PR si agrego siete millones de bibliotecas 😅.
Entonces me lo anoto:
“Estaría bueno una aplicación que haga X o una biblioteca que haga Y”.

Tiene una aplicación real, concreta y directa (por eso el nombre); que si existiese la usaría aquí y ahora. Pero no existe.

Algunos ejemplos de esto mismo
- [GitHub :: koncierge 🔔](https://github.com/jazcarate/koncierge): Necesitabamos segmentar clientes según un u otro atributo; entonces se me ocurrió que un DSL parecido al query-dsl de Mongo podría verse bien. Finalmente terminamos utilizando algo similar en produción!
- [GitHub:: Apples and Oranges](https://github.com/jazcarate/aao):  Tambien en el trabajo quería una forma de testear un código que tenía todos `BigInt`s, algunos números tenían impuestos otros no; entonces no podía sumar libremente unos con otros; por lo que me ocurrió una librería para “tagear” objetos.
- [GitHub :: marble-OS](https://github.com/jazcarate/marble-os): En la facultad, para probar y evaluar trabajos prácticos, muchas veces necesitabamos lanzar programas de manera sincronizada. La mejor herramienta hasta el momento era ser una persona alta que pueda presionar en dos computadoras diferentes la tecla `↵ Enter`.

Para este tipo de proyectos, recomiendo siempre estar atento a hacerse este tipo de preguntas:
- Este feature/bug/issue en el que estoy trabajando: ¿Tiene alguna parte súper interesante que podría extraer en su propia cosa?
- ¿Puedo desacoplar completamente esta sección de lógica en su propia cosa?
- Veo que alguien tomó esta decisión de arquitectura; ¿por qué no lo habrán hecho diferente? ¿puedo hacerlo de otra forma?

### Level 2 - Concretization
Otra “forma” que suelo descubrir nuevas ideas es encontrar un blog post o algo que sea una idea abstracta, y convertirla en algo más concreto.
No es casual que me guste mirar videos sobre matemática!

En esta categoría no empiezo de un proyecto como en la categoría anterior, si no que llego a un proyecto desde algo más abstracto.

Algunos ejemplos de mis proyectos que surgieron a partir de esta forma de encarar problemas:
- [GitHub:: Apples and Oranges # leyes de tags](https://github.com/jazcarate/aao#tag-laws): Hace algunos 3 años vi una charla de “propagators” por [YouTube :: Edward Kmett](https://www.youtube.com/watch?v=acZkF6Q2XKs). Sumamente interesante! Adicionalmente semirretículos es un tema que eh dado en clase de Matemática Discreta; y nunca le encontré una aplicación tan directa y _linda_.
- [GitHub :: Tryhard # applicativos en todos lados](https://github.com/jazcarate/tryhard/blob/main/src/Tryhard/TUI.hs#L360-L362) _(warning: el código es un desastre, estaba trabajando en eso, pero otro proyecto se llevó toda mi atención por ahora 🙈): También viendo un video de [YouTube :: Tsoding](https://www.youtube.com/watch?v=RtYWKG_zZrM) y la relación de [Applicative](https://hackage.haskell.org/package/base-4.14.1.0/docs/Control-Applicative.html#t:Applicative) y [Monoid](https://hackage.haskell.org/package/base-4.14.1.0/docs/Data-Monoid.html#t:Monoid) y como podríá usar esto para "sumar" resultados de [OpenDota](https://www.opendota.com/).
- **WIP** `rapt`: También en un video de [YouTube :: Computerphile](https://www.youtube.com/user/Computerphile) *(¿tendré un problema con la consumición de videos?)* sobre onion routing, y encriptación en capas; junto con contraseñas y OTP[^3]. Se que tengo una idea ahí, pero creo que es muy parecida a [Vault, de HashiCorp](https://www.vaultproject.io/).

Para este tipo de proyectos recomiendo pensar cada vez que escuches o leas algo (no importa de que; no digo oque hay que solo hacer uso de matemática! Estoy seguro que otras ramas de la ciencia son tan aptas a esto.) pensar:
- ¿Cómo podría usar eso?
- ¿En qué universo esta idea sería útil?
- ¿Veo que dice que se puede usar en `X` e `Y`; se podrá usar en `Z`?

(**bonus**: Creo que este mentalidad ayuda mucho a adquirir nuevos conocimientos. Más que una atención pasiva sobre un tema nuevo)

### Level 3 - Snapshot
A mi gusto, la mejor forma de inspiración: Cuando pienso solo en una interacción, en una pantalla, en un link.

- [GitHub :: es-dia-de-helado-de-fruta](https://jazcarate.github.io/es-dia-de-helado-de-fruta/): Mi novia me dijo que hoy no era día de helado de fruta, porque hacía mucho frio. Sería ideal tener una página que le pueda pasar para **demostrarle** la temperatura
- [FrasaL](https://frasal.florius.com.ar/?q=velocidad%20de%20dios): Tienes un amigo que habla español traduciendo **literalmente**  verbos preposicionales del ingles? Dice cosas como “velocidad de dios” en vez de “buena suerte”, y quieres pasar una página como [DeepL](https://www.deepl.com/en/translator) para ayudar a otras personas a comprenderle?
- [GitHub :: delCanioBot](https://github.com/JuanFdS/delCanioBot): Necesitas un bot que genere imágenes de Nicolás del Caño, a razón de el _[meme del año, Nico del Caño](https://www.youtube.com/watch?v=tdOP4V4mtoY)_?

A veces estos _chistes_ incluso terminan siendo aplicaciones de verdad, como una aplicación para coordinar car pooling ([GitHub :: catapult](https://github.com/jazcarate/catapult)).

No tengo una buena recomendación para estos proyectos "chistes", más que intentar hacerte pensar que no necesariamente un proyecto tiene que ser completamente serio; y son muchas veces estos proyectos que se combinan y que sirven de lugar para aprender nuevas tecnologías o metodologías. Y te podrían brindar un _armazón_ para proyectos al futuro.

### Level 9000 - Todas las anteriores
Lamentablemente, la “creatividad” no es un proceso súper directo. A veces algo sale por un lado, a veces por otro. A veces 2 ideas inconexas se conectan en una idea mejor.
Personalmente, me gusta escribir estas esbozos de ideas en un receptáculo físico. hay quienes prefieren un archivo en la computadora. Hay quienes tienen varios pre-ideas en la mente a la vez y nueva información decanta esas pre-ideas en un proyecto.

Gracias por tu tiempo, y espero que algo de todo esto te ayude a encontrar inspiración!

---

[^1]: *driver*: Un factor que hace que suceda o se desarrolle un fenómeno particular.
[^2]: *tinkering*: Intentar reparar o mejorar algo de manera casual o poco metódica.
[^3]: *otp*: One-time password
