# Trabalho de conclusão de curso

## Descrição
Implementação de um sistema web para monitoramento de ambientes climatizados. 

Os arquivos que estão presentes na nasta sd/ devem ser copiados para o micro SD Card mantendo-se a estrutura atual.
Não é necessário copiar a pasta sd/

### Informações adicionais
* Pasta libraries/
Contêm as bibliotecas utilizadas no projeto. Estão aqui no controle de versão justamente
para que se for necessário ajusar as bibliotecas - e está sendo para o caso do WebServer.h - nós teremos um controle
de versão sobre elas

O ideal é que se crie um link simbólico da pasta libraries aqui versionada e substitua a pasta libraries do Arduino.

## Links
*  [Projeto Arduino](http://arduino.cc/en)
*  [Projeto Webduino](http://code.google.com/p/webduino/)
*  [Dallas Temperature Control Library](http://www.milesburton.com/?title=Dallas_Temperature_Control_Library)

### Tutorials
*  [Tutorial Sensor de Temperatura](http://www.synbio.org.uk/instrumentation-news/1484.html) 
*  [SD Card](http://www.ladyada.net/learn/arduino/ethfiles.html)

## Configurando Ruby on Rails environment

### RVM

Passos retirados do site oficial em [Installing RVM](https://rvm.beginrescueend.com/rvm/install/).

Rode o comando abaixo para instalação

    $ bash < <(curl -sk https://raw.github.com/wayneeseguin/rvm/master/binscripts/rvm-installer)

Adicione a seguinte linha no `.bashrc` (Linux) ou `.bash_profile` do MacOS X

    [[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

Depois feche e reabra o terminal para carregar as configurações do RVM

## Instalando o Ruby

Rode os comandos abaixo

Instalando o ruby 1.9.2

    $ rvm install 1.9.2-p290

Aguarde o processo de download, compilação e instalação finalzar.

## Configurando o Rails

O projeto rails já está disponível aqui no Github, ao executar um `git pull origin master` aparecerá uma pasta de nome `webmonitor`, ela é o sistema Rails.

Este sistema utiliza o banco de dados MySQL com usuário `root` e senha `root` na máquina local, portanto é preciso criar/configurar estas permissões para prosseguir.

Uma vez configurado o MySQL é hora de realizar o setup do Rails, para tanto entre na pasta `webmonitor` (uma pergunta será realizada, responda `y`) e rode os comandos:

    $ gem install bundler rake
    $ bundle install
    $ rake db:setup
    $ rails s # isso inicializará o servidor rails

# Contatos
m3nd3s@gmail.com
renato@tecnoteam.com.br

