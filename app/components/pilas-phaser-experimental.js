import Ember from "ember";
import utils from "../utils/utils";

export default Ember.Component.extend({
  ancho: 400,
  alto: 400,
  estado: null,
  bus: Ember.inject.service(),
  contexto: null,

  didInsertElement() {
    let iframe = this.$("iframe")[0];

    iframe.onload = () => {
      let contexto = iframe.contentWindow;
      this.set("contexto", contexto);

      let data = {
        tipo: "iniciar_pilas",
        ancho: this.get("ancho"),
        alto: this.get("alto")
      };

      this.set("funcionParaAtenderMensajes", e => {
        return this.atenderMensajesDePilas(contexto, e);
      });

      contexto.postMessage(data, utils.HOST);

      window.addEventListener("message", this.get("funcionParaAtenderMensajes"), false);

      this.get("bus").on("cargarEscena", this, "alCargarEscenaDesdeElEditor");
      this.get("bus").on("ejecutarEscena", this, "alTenerQueEjecutarEscena");
    };
  },

  willDestroyElement() {
    window.removeEventListener("message", this.get("funcionParaAtenderMensajes"));

    this.get("bus").off("cargarEscena", this, "alCargarEscenaDesdeElEditor");
    this.get("bus").off("ejecutarEscena", this, "alTenerQueEjecutarEscena");
  },

  alCargarEscenaDesdeElEditor({ escena }) {
    let data = {
      tipo: "define_escena",
      nombre: "editorState",
      escena: escena
    };

    this.contexto.postMessage(data, utils.HOST);
  },

  alTenerQueEjecutarEscena({ escena }) {
    let data = {
      tipo: "ejecutar_escena",
      nombre: "editorState",
      escena: escena
    };

    this.contexto.postMessage(data, utils.HOST);
  },

  atenderMensajesDePilas(contexto, e) {
    if (e.origin !== utils.HOST) {
      return;
    }

    /*
    if (e.data.tipo === "movimiento_del_mouse") {
      this.set("mouse_x", e.data.x);
      this.set("mouse_y", e.data.y);
    }
    */

    if (e.data.tipo === "finaliza_carga_de_recursos") {
      this.get("bus").trigger("finalizaCarga");
    }

    if (e.data.tipo === "termina_de_mover_un_actor") {
      this.get("bus").trigger("moverActor", e.data);
    }

    if (e.data.tipo === "comienza_a_mover_un_actor") {
      this.get("bus").trigger("comienzaAMoverActor", e.data);
    }
  },
  actions: {
    detener() {
      this.set("estado", this.get("estado").detener());
    }
  }
});
