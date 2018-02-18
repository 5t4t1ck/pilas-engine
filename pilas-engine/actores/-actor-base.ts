class ActorBase {
  tipo: String;
  sprite: Phaser.Sprite;
  pilas: Pilas;
  id_color: string;

  constructor(pilas, x: number = 0, y: number = 0, imagen = "sin_imagen") {
    this.pilas = pilas;
    this.sprite = new Phaser.Sprite(pilas.game, 0, 0, imagen);
    this.x = x;
    this.y = y;
    this.rotacion = 0;
    this.escala_x = 1;
    this.escala_y = 1;
    this.id_color = this.generar_color_para_depurar();

    this.pilas.game.world.add(this.sprite);
    //this.pilas.escena_actual.agregar_actor(this);
    this.sprite["actor"] = this;

    try {
      this.iniciar();
    } catch (e) {
      this.pilas.emitir_excepcion_al_editor(e, "iniciar actor");
    }

    this.sprite.update = () => {
      try {
        this.actualizar();
      } catch (e) {
        this.pilas.emitir_excepcion_al_editor(e, "actualizar actor");
      }
    };

    this.pilas.escena_actual().agregar_actor(this);
  }

  iniciar() {}

  serializar() {
    return {
      tipo: this.tipo,
      x: Math.round(this.x),
      y: Math.round(this.y),
      centro_x: this.centro_x,
      centro_y: this.centro_y,
      rotacion: this.rotacion,
      escala_x: this.escala_x,
      escala_y: this.escala_y,
      imagen: this.sprite.key,
      transparencia: this.transparencia,
      id_color: this.id_color
    };
  }

  generar_color_para_depurar() {
    let opacidad = "FF";
    return this.pilas.utilidades.obtener_color_al_azar(opacidad);
  }

  actualizar() {}

  get imagen(): string {
    return this.sprite.frameName;
  }

  set imagen(nombre: string) {
    this.sprite.loadTexture(nombre);
  }

  set x(_x: number) {
    let { x } = this.pilas.convertir_coordenada_de_pilas_a_phaser(_x, 0);
    this.sprite.x = x;
  }

  get x() {
    let { x } = this.pilas.convertir_coordenada_de_phaser_a_pilas(this.sprite.x, 0);
    return x;
  }

  set y(_y: number) {
    let { y } = this.pilas.convertir_coordenada_de_pilas_a_phaser(0, _y);
    this.sprite.y = y;
  }

  get y() {
    let { y } = this.pilas.convertir_coordenada_de_phaser_a_pilas(0, this.sprite.y);
    return y;
  }

  set rotacion(angulo: number) {
    this.sprite.angle = -(angulo % 360);
  }

  get rotacion() {
    return -this.sprite.angle % 360;
  }

  set escala_x(s) {
    this.sprite.scale.x = s;
  }

  get escala_x() {
    return this.sprite.scale.x;
  }

  set escala_y(s) {
    this.sprite.scale.y = s;
  }

  get escala_y() {
    return this.sprite.scale.y;
  }

  get escala() {
    /*
    if (this.escala_x != this.escala_y) {
      console.warning("La escala x e y difieren, se asume que la escala_x es la más importante.");
    }
    */

    return this.escala_x;
  }

  set escala(escala) {
    this.escala_x = escala;
    this.escala_y = escala;
  }

  get centro_y() {
    return this.sprite.anchor.y;
  }

  set centro_y(y) {
    let comunes = {
      centro: 0.5,
      arriba: 0,
      abajo: 1,
      medio: 0.5
    };

    if (comunes[y] !== undefined) {
      y = comunes[y];
    }

    this.sprite.anchor.y = y;
  }

  get centro_x() {
    return this.sprite.anchor.x;
  }

  set centro_x(x) {
    let comunes = {
      centro: 0.5,
      izquierda: 0,
      derecha: 1,
      medio: 0.5
    };

    if (comunes[x] !== undefined) {
      x = comunes[x];
    }

    this.sprite.anchor.x = x;
  }

  set transparencia(t) {
    t = this.pilas.utilidades.limitar(t, 0, 100);
    this.sprite.alpha = 1 - t / 100;
  }

  get transparencia() {
    return (1 - this.sprite.alpha) * 100;
  }

  toString() {
    let clase = this.constructor["name"];
    return `<${clase} en (${this.x}, ${this.y})>`;
  }

  crear_figura_rectangular(ancho: number = 0, alto: number = 0, estatico: boolean = false) {
    this.sprite.game.physics.p2.enable([this.sprite], false);
    this.sprite.body.static = estatico;

    if (ancho && alto) {
      this.sprite.body.setRectangle(ancho, alto);
    } else {
      this.sprite.body.setRectangle(this.ancho, this.alto);
    }

    this.sprite.body.angle = -this.rotacion;
  }

  crear_figura_circular(radio: number = 0, estatico: boolean = false) {
    this.sprite.game.physics.p2.enable([this.sprite], false);
    this.sprite.body.static = estatico;

    if (radio) {
      this.sprite.body.setCircle(radio);
    } else {
      this.sprite.body.setCircle(this.ancho / 2 * this.escala_x);
    }

    this.sprite.body.angle = -this.rotacion;
  }

  get ancho() {
    return this.sprite.width;
  }

  get alto() {
    return this.sprite.height;
  }

  set alto(a: number) {
    console.log("No puede definir este atributo");
  }

  set ancho(a: number) {
    console.log("No puede definir este atributo");
  }

  get estatico() {
    if (this.sprite.body) {
      return this.sprite.body.static;
    }
  }

  set estatico(estatico: boolean) {
    if (this.sprite.body) {
      if (estatico) {
        this.sprite.body.velocity.x = 0;
        this.sprite.body.velocity.y = 0;
        this.sprite.body.angularVelocity = 0;
      }

      this.sprite.body.static = estatico;
    }
  }

  set dinamico(dinamico: boolean) {
    this.estatico = !dinamico;
  }

  get dinamico() {
    return !this.estatico;
  }

  cada_segundo() {}
}
