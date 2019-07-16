# compgraf4

### Pré-requisitos

Certifique-se de possuir o Java instalado em sua máquina. A seguir, são necessários os seguintes artefatos:

* [Processing >= 3.5.3](https://processing.org/download/) - Ambiente de programação
disponível para Windows, Linux e MacOS. A versão exata utilizada
neste projeto é a [3.5.3](http://download.processing.org/processing-3.5.3-linux64.tgz).

A biblioteca [G4P](http://www.lagers.org.uk/g4p/) é utilizada no projeto como base para a interface gráfica.

Para instalar, abra a IDE do Processing e execute os seguintes passos:

* Selecione no menu superior a opção "Sketch"
* Selecione "Importar Biblioteca..." => "Adicionar Biblioteca..."
* Selecione G4P na listagem exibida e clique em "Install" no canto inferior direito da janela

### Execução

Utilizando o Processing IDE, deve-se executar o arquivo 'Main.pde', dentro da pasta de mesmo nome.
Ao iniciar, o programa irá exibir no canto direito da janela dois menus para realização de rotação e/ou translação do objeto, como mostrado a seguir:

![Controle de transformações](Docs/controle_transform.png?raw=true "Configuração padrão para transformações")

Como pode-se ver, mais à esquerda estão os controles de translação e mais à direita os referentes à rotação. Deve-se alterar os pontos para cada operação da forma desejada (desde que seja obedecida a forma (x,y,z) exemplificada), assim como o ângulo para rotação em graus. Clicando nos botões abaixo das caixas de edição irá iniciar a transformação desejada.


## Outros links

* [Documentação do G4P](http://www.lagers.org.uk/g4p/ref/index.html) - documentação da biblioteca de interface gráfica do Processing.