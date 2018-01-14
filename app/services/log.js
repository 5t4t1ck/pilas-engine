import Service from "@ember/service";
import Ember from "ember";

export default Service.extend({
  bus: Ember.inject.service(),
  items: [],
  iniciado: false,

  iniciar() {
    if (this.get("iniciado")) {
      return;
    }

    this.get("bus").on("error", this, "alRecibirUnErrorDesdeElBus");
  },

  error(mensaje, detalle) {
    this.get("items").pushObject({ tipo: "error", mensaje: mensaje, detalle: detalle });
  },

  limpiar() {
    this.set("items", []);
  },

  alRecibirUnErrorDesdeElBus(datos) {
    this.error(datos.mensaje, datos.stack);
  }
});