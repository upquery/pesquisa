var loading;

function chamar(proc, alvo){

    var alvo = alvo || '.main';
    loading = document.querySelector('.spinner');  
    loading.classList.add('ativado');
    var request = new XMLHttpRequest(); //aqui inicializa a requisição
    request.open('POST', 'dwu.pesquisa.' + proc, true); //esse ponto define a procedure de comunicação

    if ( proc == 'GRAVA_RESPOSTA' ) {
        request.send(alvo)
    }

    request.onload = function(){  

        if(request.status == 200){
            //document.querySelector(alvo).innerHTML = request.responseText;   
           //alert('Enviado com sucesso')     
            console.log('Enviado com sucesso')        
        }
    }; 

    //window.scrollTo(0, 0);
};


document.addEventListener('click', function(e){
    if ( e.target.id == 'button-enviar') {
        if (document.querySelector('.selected')) {
            document.querySelector('.selected').classList.remove('selected');
        }

        e.target.classList.add('selected');
    }

    if ( e.target.id == 'botao-tela-aviso') {
        if (document.querySelector('.selected')) {
            document.querySelector('.selected').classList.remove('selected');
        }

        e.target.classList.add('selected');
    }
    
    if ( e.target.classList.contains ('s-checkbox')) {
        var parentDivCheckbox = e.target.closest('.CHECKBOX');
        var sChecks = parentDivCheckbox.querySelectorAll('.s-checkbox');

            sChecks.forEach(sCheck => {
                if (sCheck === e.target) {
                    sCheck.classList.add('c-selected');
                }
            });
    };

    if ( e.target.classList.contains ('s-peso')) {
        var parentDivPeso = e.target.closest('.PESO');
        var sPesos = parentDivPeso.querySelectorAll('.s-peso');

            sPesos.forEach(sPeso => {
                if (sPeso === e.target) {
                    sPeso.classList.add('p-selected');
                }
                else {
                    sPeso.classList.remove('p-selected');
                }
            });     
    };

    if ( e.target.classList.contains ('s-radio')) {
        var parentDivRadio = e.target.closest('.RADIO');
        var sRadios = parentDivRadio.querySelectorAll('.s-radio');
        
            sRadios.forEach(sRadio => {
                if (sRadio === e.target) {
                    sRadio.classList.add('r-selected');
                }
                else {
                    sRadio.classList.remove('r-selected');
                };
            });
    };

    if ( e.target.classList.contains ('s-botao')) {
        var parentDivBotao = e.target.closest('.BOTAO');
        var sBotaos = parentDivBotao.querySelectorAll('.s-botao');

            sBotaos.forEach(sBotao => {
                if (sBotao === e.target) {
                    sBotao.classList.add('b-selected');
                }
                else {
                    sBotao.classList.remove('b-selected');
                }
            });
    };

    if ( e.target.classList.contains ('s-emoji')) {
        var parentDivBotao = e.target.closest('.EMOJI');
        var sBotaos = parentDivBotao.querySelectorAll('.s-emoji');

            sBotaos.forEach(sBotao => {
                if (sBotao === e.target) {
                    sBotao.classList.add('e-selected');
                }
                else {
                    sBotao.classList.remove('e-selected');
                }
            });
    };

    if ( e.target.classList.contains ('s-texto')) {
        var parentDivTexto = e.target.closest('.TEXTO');
        var sTextos = parentDivTexto.querySelectorAll('.s-texto');

            sTextos.forEach(sTexto => {
                if (sTexto === e.target) {
                    sTexto.classList.add('t-selected');
                }
                else {
                    sTexto.classList.remove('t-selected');
                }
            });
    };

    if ( e.target.classList.contains ('s-star')) {
        var parentDivStar = e.target.closest('.STAR');
        var sStars = parentDivStar.querySelectorAll('.s-star');

            sStars.forEach(sStar => {
                if (sStar === e.target) {
                    sStar.classList.add('s-selected');
                }
                else {
                    sStar.classList.remove('s-selected');
                }
            });
    };

    //Pintar as estrelas anteriores 
    if ( e.target.classList.contains ('s-star')) {
        let vl_opcao = e.target.getAttribute('data-valor'),
            total =  e.target.getAttribute('data-total');

        let respostaStar;

        var resposta = e.target.closest('.STAR');
        var stars = resposta.querySelectorAll('.s-star');

         for (var i = 0; i <= total; i++) {         

            star = stars[i];
                if( i < vl_opcao) {
                    star.style.color = 'gold';
                    respostaStar = vl_opcao;
                }
                else {
                    star.style.color = '#d3d3d3';
                }
        }
        e.target.closest('div').setAttribute('data-resposta-star', vl_opcao);
    };
});

function ColetaDados() {

    var respostas = document.querySelectorAll('.resposta');
    var total = respostas.length;
    var selecionados = 0;
    var dados = [];

    for (resp of respostas) {


        justificativa = '';
        respostas = ''; 
        perg = '';
        cont = 0;  

        for ( sel of resp.querySelectorAll('.selected, .t-selected, .s-selected, .b-selected, .p-selected, .c-selected, .r-selected, .e-selected')){
            respostas = sel.getAttribute('data-valor');
            perg = sel.getAttribute('data-perg');
            var numPerg = perg.match(/\d+/)[0];
            opcao = sel.id.split("-")
            var opcaoSelect = opcao[1];

            var valido = true;

            for ( just of resp.querySelectorAll('.abre-input textarea')) {
                //justificativa = just.value;

                if (just.getAttribute('data-obrigatorio') == "S") {
                    if (just.value.trim() == '') {
                        just.style.borderColor = '#FF0000';
                        //just.focus();
                        just.placeholder = 'Campo obrigatório não preenchido';
                        valido = false;
                    }
                    else {
                        justificativa = just.value;
                    }
                }
                else {
                    justificativa = just.value;
                }
            };

            if (!valido) {
                break;
            }
            
            for (text of resp.querySelectorAll('[name="campoTexto"]')) {
                if (text.getAttribute('data-obrigatorio') == "S") {
                    if (text.value.trim() == '') {
                        text.style.borderColor = '#FF0000';
                        text.placeholder = 'Campo texto obrigatório não preenchido';
                        valido = false;
                        avisoDiv('Campo texto não preenchido')
                    } else {
                        respostas = text.value;
                        justificativa = null;
                        text.style.borderColor = 'initial';
                    }
                }
            }

            if (!valido) {
                break;
            }

            var countCheck = document.querySelectorAll('.CHECKBOX');
            var cliqCheck = document.querySelectorAll('.c-selected');

            var countCliq = cliqCheck.length - countCheck.length;

            cont = cont + 1  
        
            if (cont == 0) {
                console.log('Erro');
                avisoDiv('Há campos não preenchidos');
                break;
            }
            
            else {
                selecionados++
                dados.push({
                    id_pesquisa: CD_PQS,
                    cd_pergunta: numPerg,
                    cliente: CLIENTE,
                    usuario: USUARIO,
                    cd_opcao: opcaoSelect,
                    respostas: respostas,
                    justificativa: justificativa
                });
            };
  
    };
    
		if (selecionados == total + countCliq ) {

            for (item of dados) {                
                chamar('GRAVA_RESPOSTA', 'prm_id_pesquisa='+item.id_pesquisa+'&prm_cd_pergunta='+item.cd_pergunta+'&prm_cliente='+item.cliente+'&prm_usuario='+item.usuario+'&prm_cd_opcao='+item.cd_opcao+'&prm_respostas='+encodeURIComponent(item.respostas)+'&prm_justificativa='+encodeURIComponent(item.justificativa));
               
            }
            avisoDiv('Pesquisa enviada com sucesso!');
            abrirPopup();
        };
    };

            var divsObrigatorias = document.querySelectorAll('.RADIO, .PESO, .STAR, .CHECKBOX, .BOTAO, .TEXTO, .EMOJI');

            divsObrigatorias.forEach(function(divsObrigatorias){
            var pegarDivs = divsObrigatorias.querySelector('.selected, .t-selected, .s-selected, .b-selected, .p-selected, .c-selected, .r-selected, .e-selected');

                if( pegarDivs == null) {
                    divsObrigatorias.style.background = '#FFE6E6';
                    divsObrigatorias.focus();
                    
                    var nome = divsObrigatorias.className;
                    var num = divsObrigatorias.id;
                    num = num.replace(/perg-/, "")
                    nome = nome.replace(/obrigatorio/, "");

                    avisoDiv(`Pergunta ${num} do tipo ${nome} não selecionada`);   
                    }
                    else if ( pegarDivs != null) {
                    divsObrigatorias.style.background = 'initial';
                };
            });
            
            
            //Campos TextArea justificativa de cada uma das perguntas 
            var camposTexto = document.querySelectorAll('.abre-input textarea');

            var algumVazio = false;

            for (let i = 0; i < camposTexto.length; i++) {
            
                if (camposTexto[i].getAttribute('data-obrigatorio') == "S" && camposTexto[i].value.trim() == '') {
                    camposTexto[i].style.borderColor = '#FF0000';
                    camposTexto[i].placeholder = 'Campo obrigatório não preenchido';
                    avisoDiv('Campo justificativa não preenchido');
                    algumVazio = true;

                } 
                else {
                   camposTexto[i].style.borderColor = 'initial';
                }    
            }; 
};
    
function avisoDiv(tagAviso) {
    let aviso = document.getElementById('aviso-hidden');
        aviso.style.visibility = 'visible';

    var avisoSpan = document.getElementById('aviso-validacao');
        avisoSpan.innerHTML = tagAviso;
    
        setTimeout(function(){
            aviso.style.visibility = 'hidden';   
        }, 5000);

        window.addEventListener('scroll', () => {
            var avisoDiv = document.getElementById('aviso-hidden');
                if (window.scrollY > 200) {
                  avisoDiv.classList.add('active');
                } else {
                  avisoDiv.classList.remove('active');
                }
         });
};

function fecharAviso () {
    let aviso = document.getElementById('aviso-hidden');
        aviso.style.visibility = 'hidden'   
};

function abrirPopup() {
    let abrirPop = document.getElementById('mostrarPop');
    abrirPop.classList.add('active');

    let tirarBotao = document.getElementById('button-enviar');
    tirarBotao.classList.add('ativado');
};

function fecharAvisoPop() {
    let fecharPop = document.getElementById('mostrarPop');
    fecharPop.classList.remove('active')
};