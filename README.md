# Generador de Video HDMI/DVI con Tang Nano 9K

Este proyecto documenta e implementa la lógica necesaria para generar una salida de video HDMI desde una FPGA Tang Nano 9K utilizando Gowin EDA. El diseño se basa en un módulo principal (Top Module) que interconecta IP Cores nativos de Gowin con un controlador VGA personalizado.

## Arquitectura y Funcionamiento

El flujo de video se construye a partir de los siguientes bloques fundamentales:

* **Top Module (`top.v`):** Es el archivo principal del proyecto. Actúa como el contenedor que enlaza todas las señales internas, conectando los generadores de reloj, el controlador de imagen y el transmisor hacia los pines físicos de la FPGA. Se construyó utilizando las plantillas de instanciación proporcionadas por el IP Core Generator de Gowin.

* **Gestión de Relojes (rPLL y CLKDIV):**
  Para adaptarse a los tiempos exactos que requiere un monitor, se parte del oscilador interno de la Tang Nano (27 MHz):
  1. Un **rPLL** multiplica esta frecuencia de entrada para generar un reloj serial de alta velocidad (125 MHz).
  2. Un divisor de hardware (**CLKDIV**) toma esos 125 MHz y los divide exactamente entre 5 para obtener el reloj de píxel (25 MHz) necesario para la resolución base.

* **Controlador VGA (`vga_controller.v`):**
  Es el módulo encargado de gestionar el barrido de la pantalla. Genera los pulsos de sincronización (horizontal y vertical) y la señal de habilitación de datos (`de`). Además, define el patrón visual en pantalla mediante el sistema RGB. Cada canal de color (Red, Green, Blue) utiliza 8 bits de profundidad, asignando intensidades a través de valores hexadecimales de dos dígitos (por ejemplo, `8'hFF` para el valor máximo).

* **Transmisor DVI (`DVI_TX_Top`):**
  Generado mediante el IP Core de multimedia de Gowin. Toma las señales de sincronización y los colores de 8 bits del controlador VGA y los codifica. Se configuró específicamente con el estándar de I/O en modo **ELVDS** (Emulated LVDS) para garantizar la compatibilidad física y el correcto ruteo hacia el puerto HDMI integrado en la placa.
