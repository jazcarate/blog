---
layout: post
title: koncierge Una librería para segmentar usuarios 
date: 2020-09-14
canonical_url: https://dev.to/florius/koncierge-una-libreria-para-segmentar-usuarios-fjp
summary: La historia de una librería para evaluar variantes de tests AB, dado una definición de un experimento con un DSL parecido a Mongo y un contexto.
tag: show-and-tell
---

_El post original se puede leer en mi [dev.to]({{ page.canonical_url }})._

## Trasfondo

En donde estoy trabajando, cada nuevo feature o idea, pasa por un proceso de _A/B Testing_.
Normalmente lo que hacemos es:

  1. Generamos una hipótesis del estilo: "Si los usuarios tuviesen una notificación cuando pasa `X`, entonces van a hacer `Y` más seguido".
  2. Desarrollamos esta notificación, o lo que sea.
  3. Apuntamos a algún mercado para participar de esta prueba
  4. Dividimos a la mitad de los usuarios de ese mercado, tal que vean e interactúen con en nuevo feature, mientras que la otra mitad (grupo _control_) no.
  5. Esperamos dos semanas
  6. Comparamos las métricas entre los dos grupos.

Este último paso puede llevar a miles de ramificaciones: Activamos el feature para toda la población. Cambiamos algo y volvemos a hacer una prueba. Lo deshabilitamos por completo porque nuestra hipótesis era incorrecta. Etc, etc.

Para la segmentación de la población, estamos usando un servicio de un tercero. A este servicio, ocasionalmente le brindamos la información de segmentación de nuestros usuarios.
Información como

    El usuario `123` es de Madrid

para que luego, cuando queramos segmentar, podríamos segmentar solo usuarios de Madrid.

Este servicio externo, adicionalmente, solo nos provee acceso a las variantes (si un usuario pertenece al segmento, es parte del grupo de control, o es parte del grupo que participa) mediante un SDK para usar en móviles (iOS y Android).

Esto nos presentaba dos dificultades:

  1. Si quisiéramos hacer un A/B Test en alguno de los micro-servicios de backend, no podríamos consultar a este servicio.
  2. Si quisiéramos segmentar por algo de lo que no le habíamos informado al servicio, deberíamos compartirle toda esta nueva información para que este pueda segmentar.

Por esta situación, decidimos crear un micro-servicio que se encargue de segmentar y separar en variantes a nuestros usuarios.

## Problemas

Rápidamente nos vimos enfrentados a resolver como hacer para obtener la información para segmentar.

Normalmente segmentamos por país, lo que sería sencillo hacer que el nuevo micro-servicio consultara con otro micro-servicio de información; y obtuviese el país del usuario.
Con esta nueva información, podríamos segmentar.

Lo que presenta un desafío interesante:

    Como evitar que este micro-servicio crezca
    cada vez introduzcamos un nuevo micro-servicio que almacene
    alguna información del usuario?

Por eso, pensamos que podríamos delegar la responsabilidad de obtener el _contexto_ del usuario, a quien consuma este micro-servicio; por lo que una llamada podría ser:

    Dado el usuario `123`, de Madrid;
    a qué variante pertenece?

De esta manera, es quien consume quien necesita saber todas las dependencias del experimento, y cada experimento puede tener dependencias distintas, de distintas formas de computarse, y el micro-servicio podría no crecer.


## DSL (Domain-specific language - Lenguaje específico de dominio)

Ya sabíamos como querríamos que se comporte el micro-servicio, ahora necesitábamos una forma de expresar como querríamos segmentar nuestra población. Hacía poco estaba trabajando mucho con [`Mongo`](https://www.mongodb.com/) y se me ocurrió que un lenguaje de consultas como el de mongo podría ser interesante de explorar.
De tal forma que una segmentación como:

    Quiero que solo participen del experimento `EXP001`,
    usuarios quienes sean de Madrid.
    De estos, la mitad estarán en el grupo de participando
    y el esto en control.

Se transformaría en:

{% highlight json %}
{
  "EXP001": {
    "ubicación": "Madrid",
    "$children": {
      "participando": { "$rand": { "$gt": 0.5 } },
      "control": {}
    }
  }
}
{% endhighlight %}

[Playground](https://koncierge-playground.herokuapp.com/?context=%7B%0A%20%20%20%20%22ubicaci%C3%B3n%22:%20%22Madrid%22,%0A%20%20%20%20%22userId%22:%205%0A%7D&experiment=%7B%0A%20%20%20%20%22EXP001%22:%20%7B%0A%20%20%20%20%20%20%20%20%22ubicaci%C3%B3n%22:%20%22Madrid%22,%0A%20%20%20%20%20%20%20%20%22%24children%22:%20%7B%0A%20%20%20%20%20%20%20%20%20%20%20%20%22participando%22:%20%7B%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%22%24rand%22:%20%7B%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%22%24gt%22:%200.5%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%7D%0A%20%20%20%20%20%20%20%20%20%20%20%20%7D,%0A%20%20%20%20%20%20%20%20%20%20%20%20%22control%22:%20%7B%7D%0A%20%20%20%20%20%20%20%20%7D%0A%20%20%20%20%7D%0A%7D)

De esta manera, quien consuma al micro-servicio debería proveer, al menos, la información de la `"ubicación"` del usuario.
Una posible consulta podría ser con el contexto:

{% highlight json %}
{
    "ubicación": "Madrid",
    "userId": 5
}
{% endhighlight %}

El micro-servicio debería responder que pertenece al `EXP001` (dado que la ubicación empareja con la definición), y podría pertenecer a la variante `participando` o `control`.
Los usuarios deberían estar distribuidos 50%-50%; dado que hay un 50% de probabilidad que un numero al azar, uniformemente distribuido entre 0 y 1 (como es `$rand`) sea mayor a 0.5.

Con esta idea, sabiendo que la intención era que el micro-servicio no dependiente de ninguna otra parte de arquitectura de nuestro ecosistema; se me ocurrió que podría desarrollarlo como una librería pública; por si alguien más tiene la necesidad que tuvimos nosotros.

## koncierge 🛎

La librería está en [GitHub :: jazcarate/koncierge](https://github.com/jazcarate/koncierge#readme)