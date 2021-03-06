# Etiquetas

Las etiquetas son útiles para clasificar actores y simplificar interacciones.

Por ejemplo, en un juego podríamos tener 10, 20 o 30 actores diferentes que tengan el rol de "enemigos". En cuyo caso simplemente podríamos asignarle a todos la misma etiqueta para distinguirlos de los demás.

Las etiquetas se pueden definir directamente en el inspector de pilas:

![ilasEngine 2018-03-25 22-40-0](assets/PilasEngine 2018-03-25 22-40-02.png)

O bien, también se puede directamente desde el editor código usando el atributo **etiqueta** así:

```typescript
class Caja extends ActorBase {
  iniciar() {
    this.etiqueta = "enemigo";
  }

  actualizar() {}
}
```

## Etiquetas para distinguir colisiones

Vamos describir un uso típico de las etiquetas: las etiquetas son muy útiles para distinguir colisiones.

Cuando pilas detecta una colisión entre dos actores llamará a la función _cuando_comienza_una_colision_ y enviará el parámetro _actor_ como referencia al actor que entró en contacto.

Así que esto es lo que se suele hacer, imaginemos que nuestro actor _protagonista_ pueda capturar moneras pero debe perder vidas si toca un enemigo. Podríamos hacer algo así:

```typescript
class Protagonista extends Actor {
  // otras funciones...

  cuando_comienza_una_colision(actor) {
    if (actor.etiqueta === "moneda") {
      actor.eliminar();
      this.pilas.reproducir_sonido("moneda");
      // sumar puntaje, emitir particulas etc...
    }

    if (actor.etiqueta === "enemigo") {
      this.estado = "perder";
      this.vidas -= 1;
      // emitir sonido de game over, mostrar textos etc...
    }
  }
}
```
