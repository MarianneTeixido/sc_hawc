# sc_hawc

## Descripción 
Sistema cuadrafónico de audio para manipular en tiempo real los datos provenientes de un archivo CSV con los valores de las curvas de luz de las fuentes Crab Nebula, Mrk421 y Mrk501. Tomadas por el Observatorio Hawc https://www.hawc-observatory.org/

De forma adicional contiene buffers con muestras de audio retomadas de las entrevistas realizadas por Cintia Durán a astrónomos del Instituto de Astronomía, acerca de la emisión de rayos gamma.  

sc_hawc está conectado vía OSC con ofhawc https://github.com/EmilioOcelotl/ofhawc para manipular la luminosidad de cada fuente según la lectura de valores. 

## Contexto
Código desarrollado en el marco del Hackaton Astronómico ACT 2018.
