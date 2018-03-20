import { later } from '@ember/runloop';
import $ from 'jquery';
import { Promise as EmberPromise } from 'rsvp';
import { registerAsyncHelper } from "@ember/test";

export default registerAsyncHelper("esperarElemento", function(app, selector) {
  return new EmberPromise((success, fail) => {
    let cantidadDeIntentos = 0;

    function existeElemento() {
      return $(selector).length > 0;
    }

    consultarExistenciaDiferida();

    function consultarExistenciaDiferida() {
      later(() => {
        if (existeElemento()) {
          success();
        } else {
          cantidadDeIntentos += 1;

          if (cantidadDeIntentos > 20) {
            fail(new Error(`No se encontró el elemento '${selector}', incluso con una espera.`));
          } else {
            consultarExistenciaDiferida();
          }
        }
      }, 1000);
    }
  });
});
