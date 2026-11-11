# Juego de Snake en Hardware (HDMI) con Tang Nano 9K

Este proyecto documenta e implementa un juego de "Snake" completamente diseñado en hardware (Verilog) sobre una FPGA Tang Nano 9K utilizando Gowin EDA. El sistema genera una salida de video HDMI nativa, lee comandos desde el PC por puerto serial (USB) y ejecuta toda la lógica de colisiones y renderizado en tiempo real sin el uso de un microprocesador.

## Arquitectura y Funcionamiento

El diseño sigue un enfoque modular, separando la lógica del juego (Modelo), la interfaz visual (Vista) y la captura de entradas (Controlador). El flujo se construye a partir de los siguientes bloques fundamentales:

### 1. Interfaz de Video y Relojes
- **Top Module (`top_module.v`):** Es el archivo principal del proyecto. Actúa como el panel de conexiones maestro que enlaza los generadores de reloj, la recepción UART, el cerebro del juego y el renderizador de video, ruteando las señales hacia los pines físicos de la FPGA.
- **Gestión de Relojes (rPLL y CLKDIV):** Para adaptarse a los tiempos exactos del estándar de video, se parte del oscilador interno (27 MHz):
  1. Un **rPLL** multiplica la entrada para generar un reloj serial de alta velocidad (125 MHz).
  2. Un **CLKDIV** toma esos 125 MHz y los divide entre 5 para obtener el reloj de píxel (25 MHz) necesario para la resolución de 640x480@60Hz.
- **Transmisor DVI (`DVI_TX_Top`):** IP Core nativo configurado en modo **ELVDS**. Toma las señales de sincronización y los colores de 8 bits y los codifica físicamente hacia el puerto HDMI integrado de la placa.

### 2. Controlador de Entradas (UART)
- **Receptor Serial (`uart_rx.v`):** Implementa comunicación asíncrona a 115200 baudios leyendo directamente el pin RX (Pin 18) del puente USB-Serial integrado en la placa. Permite al usuario controlar la serpiente enviando los caracteres ASCII `w`, `a`, `s`, `d` desde una terminal serial en el PC (ej. PuTTY) sin necesidad de componentes externos.

### 3. Lógica del Juego (El Cerebro)
- **Snake Logic (`snake_logic.v`):** Máquina de estados finitos que calcula el comportamiento del juego en una cuadrícula virtual de 20x20. Sus características principales incluyen:
  - **Memoria expansible:** Utiliza un arreglo de registros que se desplaza en cascada para guardar las coordenadas del cuerpo. Los datos se envían a la capa de video mediante un vector aplanado (Flattened Vector) para optimizar el ruteo interno.
  - **Aleatoriedad por Hardware:** Utiliza un contador continuo corriendo a la velocidad del reloj de 25 MHz como "semilla" para ubicar las manzanas en coordenadas pseudo-aleatorias en el instante exacto en que ocurre una colisión.
  - **Reglas y Colisiones:** 
    - **Manzanas Amarillas:** Hacen crecer el cuerpo.
    - **Manzanas Rojas (Veneno):** Reducen el tamaño del cuerpo. Si el tamaño es 0, causan la muerte.
    - **Win/Loss:** El juego se detiene con victoria si la serpiente alcanza el tamaño máximo (10 segmentos). Se detiene con derrota (Game Over) si la cabeza colisiona con cualquier segmento activo de su propio cuerpo.

### 4. Renderizado Visual (La Vista)
- **Controlador VGA (`vga_controller.v`):** Genera los pulsos de sincronización (HS, VS) y escanea masivamente el arreglo del cuerpo para dibujar el juego en tiempo real. Renderiza el fondo cuadriculado, asigna colores distintos a la cabeza y al cuerpo dinámico, y superpone recuadros geométricos de alerta (Rojo para Game Over, Dorado para Victoria) cuando el cerebro del juego activa las banderas correspondientes.
