VERSION=$(shell git describe --tags)
NOMBRE="pilas-engine"
NOMBREBIN="pilas-engine"
DATE=`date +'%y.%m.%d %H:%M:%S'`

# Le indica a la compilación de binarios si puede borrar todos los .map
ELIMINAR_MAPS=1

# Binarios
BIN_ELECTRON=./node_modules/.bin/electron
BIN_TYPEDOC=./node_modules/.bin/typedoc
BIN_TYPESCRIPT=./node_modules/typescript/bin/tsc
BIN_SPRITESHEET=./node_modules/.bin/spritesheet-js
BIN_GITBOOK=./node_modules/.bin/gitbook
BIN_EMBER=./node_modules/.bin/ember
BIN_SURGE=./node_modules/.bin/surge
BIN_ELECTRON_PACKAGER=./node_modules/.bin/electron-packager
BIN_ELECTRON_REBUILD=./node_modules/.bin/electron-rebuild
BIN_PRETTIER=./node_modules/.bin/prettier
FLAGS_ELECTRON_PACKAGER=--asar

N=[0m
G=[01;32m
Y=[01;33m
B=[01;34m

define log
	@echo "${G}▷$(1) ${N}"
endef

define task
	@echo ""
	@echo "${Y}-$(1)${N}"
endef

comandos:
	@echo ""
	@echo "${B}Comandos disponibles para ${Y}${NOMBRE}${N} (versión: ${VERSION})"
	@echo ""
	@echo "  ${Y}Generales de la aplicación${N}"
	@echo ""
	@echo "    ${G}iniciar${N}                Instala dependencias."
	@echo "    ${G}compilar${N}               Compila la aplicación."
	@echo "    ${G}compilar_live${N}          Compila la aplicación en modo continuo."
	@echo "    ${G}electron${N}               Ejecuta la aplicación en electron (sin compilar)."
	@echo "    ${G}ejecutar${N}               Ejecuta la aplicación en modo desarrollo."
	@echo "    ${G}test${N}                   Ejecuta los tests de la aplicación."
	@echo "    ${G}sprites_ember${N}          Genera las imágenes de la aplicación."
	@echo "    ${G}prettier${N}               Corrige el formato y la sintaxis de todos los archivos."
	@echo "    ${G}actualizar_typescript${N}  Actualiza typescript a una versión más reciente."
	@echo "    ${G}actualizar_definiciones${N}Actualiza las definiciones de typescript para phaser."
	@echo "    ${G}actualizar_jsbeautify${N}  Actualiza jsbeautify a una versión más reciente."
	@echo ""
	@echo "  ${Y}Relacionados con pilas ${N}"
	@echo ""
	@echo "    ${G}compilar_pilas${N}               Genera pilasengine.js."
	@echo "    ${G}compilar_pilas_live${N}          Genera pilasengine.js, ejemplos y tests."
	@echo "    ${G}api${N}                          Genera la documentación de API para pilas."
	@echo "    ${G}pilas_manual${N}                 Genera el manual de pilas."
	@echo "    ${G}pilas_manuales_descargables${N}  Genera los pdf, epub y mobi del manual."
	@echo "    ${G}pilas_manual_web${N}             Sube el manual a la web."
	@echo "    ${G}pilas_sprites${N}                Genera los spritesheets."
	@echo "    ${G}actualizar_phaser${N}            Actualiza phaser a una versión más reciente."
	@echo ""
	@echo "  ${Y}Para distribuir${N}"
	@echo ""
	@echo "    ${G}version_patch${N}          Genera una versión PATCH."
	@echo "    ${G}version_minor${N}          Genera una versión MINOR."
	@echo "    ${G}version_major${N}          Genera una versión MAJOR."
	@echo "    ${G}binarios${N}               Genera los binarios de la aplicación."
	@echo ""
	@echo ""

iniciar:
	$(call task, "Iniciando el proyecto.")
	$(call log, "Instalando dependencias.")
	@npm install
	$(call log, "Preparando dependencias binarias para electron")
	./node_modules/.bin/electron-rebuild

compilar:
	$(call log, "Iniciando compilación.")
	${BIN_EMBER} build --environment develop

compilar_live:
	$(call log, "Iniciando compilación.")
	${BIN_EMBER} build --environment develop --watch

s: serve

serve:
	$(call log, "Iniciando ember s")
	yarn start

ejecutar: serve

prettier:
	${BIN_PRETTIER} --write 'app/**/*.js'
	${BIN_PRETTIER} ./node_modules/.bin/prettier --write 'tests/**/*.js'

version_patch:
	${BIN_EMBER} release

version_minor:
	${BIN_EMBER} release --minor

version_major:
	${BIN_EMBER} release --major

electron:
	@echo "${G}Iniciando electron ... (pero sin compilar desde cero).${N}"
	${BIN_ELECTRON} .

changelog:
	@git log `git describe --tags --abbrev=0` --pretty=format:"  * %s" > CHANGELOG.txt
	@echo "Generando el archivo CHANGELOG.txt"

api:
	$(call log, "Generando documentacion de pilas-engine")
	cd pilas-engine; ../${BIN_TYPEDOC} --out ../public/api/ ./ --hideGenerator

compilar_pilas:
	$(call log, "Compilando pilas-engine")
	yarn compilar_pilas

compilar_pilas_live:
	$(call log, "Compilando ejemplos de pilas-engine en modo live")
	yarn compilar_pilas_live

pilas_sprites:
	$(call log, "Actualizando imagenes para usar en pilas ...")
	${BIN_SPRITESHEET} sprites/* -p public/imagenes_agrupadas/ -f pixi.js --padding=10
	@echo ""
	@echo "${G}Listo, las archivos que se generaron son:"
	@echo ""
	@echo "    public/imagenes_agrupadas/spritesheet.json"
	@echo "    public/imagenes_agrupadas/spritesheet.png"
	@echo "${N}"


test:
	$(call log, "Ejecutando test...")
	${BIN_EMBER} test

deploy_a_surge:
	rm -rf dist
	@echo "Compilando la aplicación en modo producción..."
	${BIN_EMBER} build --prod
	@echo "Subiendo contenido al sitio de surge."
	${BIN_SURGE} dist pilas-engine.surge.sh

binarios:
	$(call task, "Comenzando a generar binarios.")
	$(call log, "Limpiando directorio de binarios ...")
	@rm -rf binarios
	$(call log, "Compilando aplicación ember ...")
	${BIN_EMBER} build
	$(call log, "Generando binarios ...")
ifeq ($(ELIMINAR_MAPS), 1)
	$(call log, "Eliminando archivos .map porque la variable ELIMINAR_MAPS vale 1")
	@rm dist/assets/*.map
endif
	$(call log, "Instalando dependencias de produccion ...")
	cp prod-electron.js dist/electron.js
	cp prod-package.json dist/package.json
	cd dist/; npm install
	cd dist; ../${BIN_ELECTRON_REBUILD} --arch=x64 --electron-version=1.6.10
	$(call log, "Compilando para osx - 64 bits ...")
	cd dist; tar xvzf ../extras/serialport-v5.1.0-beta5-electron-v53-darwin-x64.tar.gz
	cd dist; cp build/Release/serialport.node node_modules/serialport/build/Release/
	cd dist; rm -rf build
	cd dist; ../${BIN_ELECTRON_PACKAGER} . ${NOMBREBIN} --platform=darwin --arch=x64 --electron-version=1.6.10 --out=../binarios ${FLAGS_ELECTRON_PACKAGER}
	$(call log, "Compilando para windows - 32 bits ...")
	cd dist; tar xvzf ../extras/serialport-v5.1.0-beta5-electron-v53-win32-ia32.tar.gz
	cd dist; cp build/Release/serialport.node node_modules/serialport/build/Release/
	cd dist; rm -rf build
	cd dist; ../${BIN_ELECTRON_PACKAGER} . ${NOMBREBIN} --platform=win32 --arch=ia32 --electron-version=1.6.10 --out=../binarios ${FLAGS_ELECTRON_PACKAGER}
	$(call log, "Compilando para windows - 64 bits ...")
	cd dist; tar xvzf ../extras/serialport-v5.1.0-beta5-electron-v53-win32-x64.tar.gz
	cd dist; cp build/Release/serialport.node node_modules/serialport/build/Release/
	cd dist; rm -rf build
	cd dist; ../${BIN_ELECTRON_PACKAGER} . ${NOMBREBIN} --platform=win32 --arch=x64 --electron-version=1.6.10 --out=../binarios ${FLAGS_ELECTRON_PACKAGER}
	$(call log, "Compilando para linux - 32 bits ...")
	cd dist; tar xvzf ../extras/serialport-v5.1.0-beta5-electron-v53-linux-ia32.tar.gz
	cd dist; cp build/Release/serialport.node node_modules/serialport/build/Release/
	cd dist; rm -rf build
	cd dist; ../${BIN_ELECTRON_PACKAGER} . ${NOMBREBIN} --platform=linux --arch=ia32 --electron-version=1.6.10 --out=../binarios ${FLAGS_ELECTRON_PACKAGER}
	$(call log, "Compilando para linux - 64 bits ...")
	cd dist; tar xvzf ../extras/serialport-v5.1.0-beta5-electron-v53-linux-x64.tar.gz
	cd dist; cp build/Release/serialport.node node_modules/serialport/build/Release/
	cd dist; rm -rf build
	cd dist; ../${BIN_ELECTRON_PACKAGER} . ${NOMBREBIN} --platform=linux --arch=x64 --electron-version=1.6.10 --out=../binarios ${FLAGS_ELECTRON_PACKAGER}
	$(call log, "Comprimiendo ...")
	@zip -qr binarios/${NOMBREBIN}-osx-64_bits.zip     binarios/${NOMBREBIN}-darwin-x64
	@zip -qr binarios/${NOMBREBIN}-windows-32_bits.zip binarios/${NOMBREBIN}-win32-ia32
	@zip -qr binarios/${NOMBREBIN}-windows-64_bits.zip binarios/${NOMBREBIN}-win32-x64
	@zip -qr binarios/${NOMBREBIN}-linux-32_bits.zip binarios/${NOMBREBIN}-linux-ia32
	@zip -qr binarios/${NOMBREBIN}-linux-64_bits.zip binarios/${NOMBREBIN}-linux-x64

sprites_ember:
	$(call log, "Generando Spritesheets para la aplicación ember...")
	@./node_modules/.bin/spritesheet-js imagenes/* -p public/assets/ -f css --padding=2
	@echo ""
	@echo "${G}Listo, las archivos que se generaron son:"
	@echo ""
	@echo "    public/assets/spritesheet.json"
	@echo "    public/assets/spritesheet.png"
	@echo "${N}"


.PHONY: tmp docs binarios

pilas_manual:
	$(call log, "Generando documentación")
	${BIN_GITBOOK} build
	@rm -rf public/manual
	@mv _book public/manual
	@echo ""
	@echo "${G}OK, la documentación quedó en public/manual"
	@echo ""

pilas_manual_web: pilas_manual
	${BIN_SURGE} public/manual manual-pilas-engine.surge.sh

pilas_manuales_descargables:
	$(call log, "Generando archivos de documentación")
	${BIN_GITBOOK} pdf
	${BIN_GITBOOK} epub
	${BIN_GITBOOK} mobi
	@rm -rf manuales
	@mkdir manuales
	@mv book.epub manuales/
	@mv book.mobi manuales/
	@mv book.pdf manuales/
	@echo ""
	@echo "${G}OK, los archivos generados están en el directorio manuales"
	@echo ""


actualizar_phaser:
	@echo "${Y}Para actualizar phaser, hay que seguir estos pasos:${N}"
	@echo "${Y}${N}"
	@echo "${Y} - Subir el número de versión de package.json.${N}"
	@echo "${Y} - Ejecutar npm install.${N}"
	@echo "${Y} - Copiar phaser al directorio public:${N}"
	@echo "${Y}${N}"
	@echo "${Y}        cp node_modules/phaser/dist/phaser.js public/${N}"
	@echo "${Y}${N}"

actualizar_typescript:
	@echo "${Y}Para actualizar typescript, hay que seguir estos pasos:${N}"
	@echo "${Y}${N}"
	@echo "${Y} - Subir el número de versión de package.json.${N}"
	@echo "${Y} - Ejecutar npm install.${N}"
	@echo "${Y} - Copiar typescript.js al directorio public:${N}"
	@echo "${Y}${N}"
	@echo "${Y}        cp node_modules/typescript/lib/typescript.js public${N}"
	@echo "${Y}${N}"

actualizar_definiciones:
	@wget https://raw.githubusercontent.com/photonstorm/phaser3-docs/master/typescript/phaser.d.ts -O pilas-engine/declaraciones/phaser.d.ts


actualizar_jsbeautify:
	@echo "${Y}Para actualizar jsbeautify, hay que seguir estos pasos:${N}"
	@echo "${Y}${N}"
	@echo "${Y} - Subir el número de versión de package.json.${N}"
	@echo "${Y} - Ejecutar npm install.${N}"
	@echo "${Y} - Copiar el archivo beautify.js al directorio vendor:${N}"
	@echo "${Y}${N}"
	@echo "${Y}        cp node_modules/js-beautify/js/lib/beautify.js vendor${N}"
	@echo "${Y}${N}"
