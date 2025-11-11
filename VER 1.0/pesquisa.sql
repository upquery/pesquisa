SET DEFINE OFF
CREATE OR REPLACE PACKAGE BODY PESQUISA  IS
               
    PROCEDURE MAIN (PRM_USUARIO     VARCHAR2 DEFAULT NULL,
                    PRM_CLIENTE     VARCHAR2 DEFAULT NULL,
                    PRM_ID_PESQUISA VARCHAR2 DEFAULT NULL) AS
    
    WS_CSS          VARCHAR2(200);
    ws_ds_titulo    VARCHAR2(1000);
    ws_ds_pesquisa  VARCHAR2(500);
    ws_id_cliente   VARCHAR2(20);
    ws_id_pesquisa  VARCHAR2(4);
    ws_valor        VARCHAR2(10);
    ws_id_situacao  VARCHAR2(4);
    ws_respondido   exception;
  

    BEGIN
        ws_id_cliente := PRM_CLIENTE;

        select max(cd_pesquisa), max(id_situacao) into ws_id_pesquisa, ws_id_situacao from pqs_pesquisas where cd_pesquisa = nvl(PRM_ID_PESQUISA, 1); 

        if ws_id_pesquisa is null then
            raise ws_respondido;
        elsif (ws_id_cliente = '${CLIENTE}' or prm_usuario = '${USUARIO}') or (ws_id_cliente = 'N/A') then    
            raise ws_respondido;
        elsif (prm_cliente is null and prm_usuario is null and prm_id_pesquisa is null) then
            raise ws_respondido;
        elsif ws_id_situacao <> 'A' then
            raise ws_respondido;  
        end if;
 
        select count(*) into ws_valor
        from pqs_respostas
        where cd_cliente = nvl(ws_id_cliente,'999999999')
        and  cd_pesquisa = ws_id_pesquisa
        and  cd_usuario = prm_usuario
        and cd_usuario  <> 'DWU';

        if ws_valor > 0 then

            raise ws_respondido;

        end if; 

        htp.p('<script>');

            htp.prn('const ');
            for i in(select cd_constante, vl_constante from bi_constantes) loop
                htp.prn(i.cd_constante||' = "'||fun.lang(i.vl_constante)||'", ');
            end loop;
            htp.prn('TR_END = "";');
            htp.p('const USUARIO = "'||nvl(prm_usuario, 'DWU')||'";');
            htp.p('const CLIENTE = "'||ws_id_cliente||'";');
            htp.p('const CD_PQS = "'||ws_id_pesquisa||'";');
            
        htp.p('</script>');

        htp.p('<!DOCTYPE html>');
        htp.p('<html lang="pt-br">');
                
            htp.p('<head>');

                htp.p('<link rel="favicon" href="dwu.fcl.download?arquivo=upquery-icon.png"/>');
                htp.p('<link rel="shortcut icon" href="dwu.fcl.download?arquivo=upquery-icon.png"/>');
                htp.p('<link rel="stylesheet" href="dwu.fcl.download?arquivo=pesquisa.css"/>' );
                htp.p('<script src="dwu.fcl.download?arquivo=pesquisa.js"></script>');
                htp.p('<link href="https://fonts.googleapis.com/css?family=Montserrat" rel="stylesheet" type="text/css">');
                htp.p('<link href="https://fonts.googleapis.com/css?family=Rubik" rel="stylesheet" type="text/css">');
                htp.p('<link href="https://fonts.googleapis.com/css?family=Quicksand" rel="stylesheet" type="text/css">');
                htp.p('<link rel="stylesheet" href="dwu.fcl.download?arquivo='||nvl(ws_css, 'ideativo')||'.css">');
                htp.p('<link rel="stylesheet" href="dwu.fcl.download?arquivo=MADETOMMY.otf">');
                --htp.p('<meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1, maximum-scale=1">');
                htp.p('<meta name="viewport" content="width=device-width, initial-scale=1">');
                htp.p('<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />');
				htp.p('<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />');
				htp.p('<meta name="google" content="notranslate" />');
                htp.p('<title>PESQUISA - UPQUERY</title>');

            htp.p('</head>');

            htp.p('<body style="position: absolute; width: 100%; margin: 0; display: block; /*display: flex; flex-flow: column nowrap;">');      

                htp.p('<div class="spinner"></div>');

                --     htp.p('<script>');
                --         htp.p('var redirecionarDepois = () => {
                --             window.history.replaceState({}, document.title, "/conhecimento/dwu.pesquisa.main");
                --         };');
                --     htp.p('</script>');
                -- htp.p('<body onload="setTimeout(redirecionarDepois, 100);">');
                                                                        
                htp.p('<div id="main" class="bgimg">');

                    htp.p('<div id="container" class="container">');

                        select ds_pesquisa, ds_titulo into ws_ds_pesquisa, ws_ds_titulo from pqs_pesquisas where cd_pesquisa = ws_id_pesquisa; 

                        htp.p('<div class="logo-up">');
                            htp.p('<img class="img-logo-up"src="dwu.fcl.download?arquivo=logo-upquery-pesquisa.png" width="400">');
                        htp.p('</div>');
                        htp.p('<h3>'||ws_ds_titulo||'</h3>');
                        htp.p('<p>'||ws_ds_pesquisa||'</p>');
                            
                        pesquisa.monta_pergunta(ws_id_pesquisa);     

                        htp.p('<div class="centralizarDivBotao">');
                            htp.p('<button id="button-enviar" class="botao-enviar" onclick="enviarFormulario(this)">Enviar</button>');
                        htp.p('</div>');                             
                    htp.p('</div>');

                    htp.p('<div class="aviso" id="aviso-hidden">');
                        htp.p('<span id="aviso-validacao">Aviso tal</span>');
                        htp.p('<span class="fechar-aviso" onclick="fecharAviso()">FECHAR</span>');
                    htp.p('</div>');

                    htp.p('<div class="poppup" id="mostrarPop">');
                        htp.p('<div class="pqs-agradecimento">');
                            htp.p('<span class="fechar-aviso-pop" onclick="fecharAvisoPop()">FECHAR</span>');
                                htp.p('<div class="logo-up-pop">');
                                    --htp.p('<img class="img-logo-up"src="dwu.fcl.download?arquivo=logo-upquery-pesquisa.png" width="360" height="214">');
                                    htp.p('<img class="img-logo-up"src="dwu.fcl.download?arquivo=logo-upquery-pesquisa.png" width="400">');
                                htp.p('</div>');
                            htp.p('<h2 class="pop-h2">Sua pesquisa foi enviada com sucesso!</h2>');
                            htp.p('<span class="pop-span">UpQuery agradece!</span>');
                            htp.p('<div class="botao-pop">');
                                htp.p('<a href="https://www.upquery.com/" target="_blank"> <button class="pop-site" >Clique aqui e conheça nosso site</button></a>');
                            htp.p('</div>');
                        htp.p('</div>');
                    htp.p('</div>');
                    
				htp.p('</div>');
                

			htp.p('</body>');
    exception 
        when ws_respondido then
            TELA_AVISO(PRM_ID_PESQUISA, prm_usuario, ws_id_cliente);
        when others then
            
            insert into bi_log_sistema values (sysdate, 'PESQUISA.MAIN (others):'|| DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, PRM_USUARIO||'-'||WS_ID_CLIENTE, 'ERRO');
			commit;
    END MAIN;

    PROCEDURE TELA_AVISO  (PRM_ID_PESQUISA VARCHAR2 DEFAULT NULL,
                           PRM_ID_USUARIO  VARCHAR2 DEFAULT NULL,
                           PRM_CLIENTE     VARCHAR2 DEFAULT NULL) as 

    
    ws_css          VARCHAR2(200);
    ws_id_pesquisa  VARCHAR2(3);
    ws_nome_cliente VARCHAR2(200);
    ws_id_cliente   VARCHAR2(200);
    ws_id_situacao  VARCHAR2(4);


    BEGIN
        -- ws_id_pesquisa := PRM_ID_PESQUISA;
        select max(cd_pesquisa) into ws_id_pesquisa from pqs_pesquisas where cd_pesquisa = PRM_ID_PESQUISA; 
        ws_id_cliente := PRM_CLIENTE;

        

            /* select id_situacao into ws_id_situacao from pqs_pesquisas where cd_pesquisa = ws_id_pesquisa;  */

            htp.p('<!DOCTYPE html>');
            htp.p('<html lang="pt-br">');
                    
                htp.p('<head>');

                    htp.p('<link rel="favicon" href="dwu.fcl.download?arquivo=upquery-icon.png"/>');
                    htp.p('<link rel="shortcut icon" href="dwu.fcl.download?arquivo=upquery-icon.png"/>');
                    htp.p('<link rel="stylesheet" href="dwu.fcl.download?arquivo=pesquisa.css"/>' );
                    htp.p('<script src="dwu.fcl.download?arquivo=pesquisa.js"></script>');
                    htp.p('<link href="https://fonts.googleapis.com/css?family=Montserrat" rel="stylesheet" type="text/css">');
                    htp.p('<link href="https://fonts.googleapis.com/css?family=Rubik" rel="stylesheet" type="text/css">');
                    htp.p('<link href="https://fonts.googleapis.com/css?family=Quicksand" rel="stylesheet" type="text/css">');
                    htp.p('<link rel="stylesheet" href="dwu.fcl.download?arquivo='||nvl(ws_css, 'ideativo')||'.css">');
                    htp.p('<link rel="stylesheet" href="dwu.fcl.download?arquivo=MADETOMMY.otf">');
                    htp.p('<meta name="viewport" content="width=device-width, initial-scale=1">');
                    htp.p('<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />');
                    htp.p('<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />');
                    htp.p('<meta name="google" content="notranslate" />');
                    htp.p('<title>PESQUISA - UPQUERY</title>');

                htp.p('</head>');

                htp.p('<body style="position: absolute; width: 100%; margin: 0; display: block; /*display: flex; flex-flow: column nowrap;*/">');   

                 htp.p('<script>');
                        htp.p('var redirecionarDepois = () => {');
                            htp.p('    window.history.replaceState({}, document.title, "http://cloud.upquery.com/conhecimento/dwu.pesquisa.main");');
                        htp.p('}');
                    htp.p('</script>');
                            htp.p('<body onload="setTimeout(redirecionarDepois, 100);">');

                    htp.p('<div class="spinner"></div>');

                    htp.p('<div id="main-tela-aviso" class="bgimg">');
                        htp.p('<div class="container-tela-aviso">');
                            htp.p('<div class="logo-up">');
                                --htp.p('<img class="img-logo-up"src="dwu.fcl.download?arquivo=logo-upquery-pesquisa.png" width="360" height="188">');
                                htp.p('<img class="img-logo-up"src="dwu.fcl.download?arquivo=logo-upquery-pesquisa.png" width="400">');
                            htp.p('</div>'); 

                            if ws_id_cliente = 'N/A'  then
                                    htp.p('<h3 id="notfound" class="tela-aviso">Não foi encontrado!</h3>');
                                    htp.p('<p id="notfound-p">Opss!! Desculpas mas não foi possível encontrar os dados para preencher nossa pesquisa, por favor tente acessar novamente pelo BI da sua empresa.');
                                htp.p('<div class="centralizarDivBotao">');
                                    htp.p('<button id="botao-tela-aviso" onclick="window.close()">Fechar</button>');
                                htp.p('</div>');
                            elsif ws_id_cliente = '${CLIENTE}' or PRM_ID_USUARIO = '${USUARIO}' then
                                    htp.p('<h3 id="notfound" class="tela-aviso">Você tentou acessar por um link externo!</h3>');
                                    htp.p('<p id="notfound-p">Opss! Parece que você tentou acessar por um link externo, tente acessar novamente pelo seu BI através das notificações você será encaminhado corretamente.');
                                htp.p('<div class="centralizarDivBotao">');
                                    htp.p('<button id="botao-tela-aviso" onclick="window.close()">Fechar</button>');
                                htp.p('</div>'); 
                            elsif ws_id_cliente is null and PRM_ID_USUARIO is null and ws_id_pesquisa is null or ws_id_pesquisa is null  then
                                    htp.p('<h3 id="notfound" class="tela-aviso">Essa pesquisa está indisponível!</h3>');
                                    htp.p('<p id="notfound-p">Opss! Essa pesquisa pode não estar mais disponível, ou ocorreu algum erro. Tente acessar novamente pelo BI.');
                                htp.p('<div class="centralizarDivBotao">');
                                    htp.p('<button id="botao-tela-aviso" onclick="window.close()">Fechar</button>');
                                htp.p('</div>'); 
                                --select t1.nm_cliente*,t2.nm_usuario into from taux_clientes t1 left join cli_usuarios t2 on t1.cd_cliente = t2.cd_cliente;
                           /* elsif ws_id_situacao <> 'A' then
                                 select nm_cliente into ws_nome_cliente from taux_clientes where cd_cliente = ws_id_cliente;
                                    htp.p('<h3 class="tela-aviso">'||PRM_ID_USUARIO||' Está pesquisa está inativa</h3>');
                                    htp.p('<h4>'||ws_nome_cliente||'</h4>');
                                    htp.p('<p id="agrad">Opss! Sinto muito, mas parece que está pesquisa se encontra inativa neste momento.');
                                htp.p('<div class="centralizarDivBotao">');
                                    htp.p('<button id="botao-tela-aviso" onclick="window.close()">Fechar</button>');
                                htp.p('</div>'); */
                            else
                                select max(nm_cliente) into ws_nome_cliente from taux_clientes where cd_cliente = ws_id_cliente;
                                    htp.p('<h3 class="tela-aviso">O usuário '||PRM_ID_USUARIO||' já respondeu nossa pesquisa de satisfação '||ws_id_pesquisa||'</h3>');
                                    htp.p('<h4>'||ws_nome_cliente||'</h4>');
                                    htp.p('<p id="agrad">Agradecemos pelo seu feedback sobre a nossa pesquisa de satisfação. <br> Sua opinião é muito importante para nós, pois nos ajuda a melhorar os nossos serviços e a oferecer uma experiência mais satisfatória para você.');
                                htp.p('<div class="centralizarDivBotao">');
                                    htp.p('<button id="botao-tela-aviso" onclick="window.close()">Fechar</button>');
                                htp.p('</div>');
                            end if;

                        htp.p('</div>');
                    htp.p('</div>');

                htp.p('</body>');    


    exception
        when others then
            htp.p(sqlerrm);
            insert into bi_log_sistema values (sysdate, 'PESQUISA.TELA_AVISO (others):'|| DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - ID PESQUISA: '||WS_ID_PESQUISA,  PRM_ID_USUARIO||'-'||WS_ID_CLIENTE, 'ERRO');
			commit; 
    END TELA_AVISO;

    PROCEDURE MONTA_PERGUNTA (PRM_ID_PESQUISA VARCHAR2) AS
        
        cursor crs_monta_pergunta is
            select v.*, rownum as num from (
                select cd_pesquisa, cd_pergunta, ds_pergunta, ds_grupo, nr_ordem, tp_resposta, id_obrigatorio, id_multipla, id_justificativa, rownum
                from pqs_perguntas
                where	cd_pesquisa = prm_id_pesquisa
                order by cd_pergunta
            )  v;

        ws_monta_pergunta crs_monta_pergunta%rowtype;
        ws_count number;
        ws_class  varchar2(200);
        ws_style  varchar2(100);
        ws_tag    varchar2(500);        
        ws_id_perg varchar2(100);

    begin
        open crs_monta_pergunta;
			loop
				fetch crs_monta_pergunta into ws_monta_pergunta;
				exit when crs_monta_pergunta%notfound;

                htp.p('<div class="pergunta" id="tit-perg-'||ws_monta_pergunta.cd_pergunta||'">');
                    htp.p('<span class="tit-pergunta">'
                        ||ws_monta_pergunta.num||'. '||ws_monta_pergunta.ds_pergunta||
                    '</span>'); 
                htp.p('</div>');
                htp.p('<div class="resposta">');

                    -- ws_class := upper(ws_monta_pergunta.tp_resposta);
                    -- if ws_monta_pergunta.id_obrigatorio = 'S' then 
                    --     ws_class := ws_class||' obrigatorio';
                    -- end if;    
                    --htp.p('<div class="'||ws_class||'" id="perg-'||ws_monta_pergunta.cd_pergunta||'" data-resposta="">');

                    if upper(ws_monta_pergunta.tp_resposta) in ('STAR','PESO', 'CHECKBOX', 'RADIO', 'RADIO2', 'BOTAO', 'TEXTO', 'TEXTO2', 'EMOJI') then
                        ws_class := 'resposta-area '||upper(ws_monta_pergunta.tp_resposta);

                        if ws_monta_pergunta.id_obrigatorio = 'S' then 
                            ws_class := ws_class||' obrigatorio';
                        end if;    

                        if upper(ws_monta_pergunta.tp_resposta) = 'CHECKBOX' or ws_monta_pergunta.id_multipla = 'S' then
                            ws_class := ws_class||'" data-multipla="S';
                        end if;    

                        htp.p('<div class="'||ws_class||'" data-num="'||ws_monta_pergunta.num||'" data-opcao="" data-valor="" id="perg-'||ws_monta_pergunta.cd_pergunta||'">');

                        select count(*) into ws_count from pqs_pergunta_opcao 
                        where cd_pesquisa = ws_monta_pergunta.cd_pesquisa 
                        and cd_pergunta = ws_monta_pergunta.cd_pergunta;

                        for a in (select v.*, rownum as num from (
                                select * from pqs_pergunta_opcao
                                    where cd_pesquisa = ws_monta_pergunta.cd_pesquisa 
                                    and cd_pergunta = ws_monta_pergunta.cd_pergunta
                                order by nr_ordem
                            ) v ) 
                        loop 
                            ws_style := '';
                            if a.codigo is not null then 
                                if upper(ws_monta_pergunta.tp_resposta) = 'STAR' then
                                    ws_style := ' style="color:'||a.codigo||'; "'; 
                                else
                                    ws_style := ' style="background:'||a.codigo||'; "'; 
                                end if;   
                            end if;
                            
                            ws_tag := ws_style||' title="'||a.ds_opcao||'" class="s-'||lower(ws_monta_pergunta.tp_resposta)||' campo" id="'||ws_monta_pergunta.cd_pergunta||'-'||a.cd_opcao||'" data-perg="perg-'||ws_monta_pergunta.cd_pergunta||'" data-opcao="'||a.cd_opcao||'" data-valor="'||a.vl_opcao||'" data-total="'||ws_count||'" ';
                            
                            if upper(ws_monta_pergunta.tp_resposta) = 'PESO' then 
                                ws_tag := ws_tag||'onclick="setSelect(this)"';
                                htp.p('<a '||ws_tag||'>'||a.vl_opcao||'</a>');
                            

                            elsif upper(ws_monta_pergunta.tp_resposta) = 'CHECKBOX' then
                                ws_tag := ws_tag||'onchange="setMultipla(this)"';
                                htp.p('<input type="checkbox" name="'||a.vl_opcao||'" '||ws_tag||'"><label for="'||ws_monta_pergunta.cd_pergunta||'-'||a.cd_opcao||'">'||a.vl_opcao||'</label>');
                            

                            elsif upper(ws_monta_pergunta.tp_resposta) = 'RADIO' then
                                ws_tag := ws_tag||'onchange="setSelect(this)"';
                                htp.p('<input type="radio" name="radio-'||ws_monta_pergunta.cd_pergunta||'" '||ws_tag||'"><label for="'||ws_monta_pergunta.cd_pergunta||'-'||a.cd_opcao||'"> '||a.vl_opcao||'</label>');

                            elsif upper(ws_monta_pergunta.tp_resposta) = 'RADIO2' then
                                -- htp.p('<span><input type="radio" name="radio-'||ws_monta_pergunta.cd_pergunta||'" '||ws_tag||'"><label for="'||ws_monta_pergunta.cd_pergunta||'-'||a.cd_opcao||'"> '||a.ds_opcao||'</label></span>');
                                ws_tag := ws_tag||'onchange="setSelect(this)"';
                                htp.p('<label for="'||ws_monta_pergunta.cd_pergunta||'-'||a.cd_opcao||'">');
                                    htp.p('<input type="radio" name="radio-'||ws_monta_pergunta.cd_pergunta||'" '||ws_tag||'  />');
                                    htp.p(a.ds_opcao);
                                htp.p('</label>');
                            elsif upper(ws_monta_pergunta.tp_resposta) = 'BOTAO' then
                                ws_tag := ws_tag||'onclick="setSelect(this)"';
                                htp.p('<button type="checkbox" '||ws_tag||' >'||a.vl_opcao||'</button>');

                            elsif upper(ws_monta_pergunta.tp_resposta) = 'TEXTO' then
                                ws_tag := ws_tag||'onblur="setTexto(this)"';
                                htp.p('<textarea '||ws_tag||'" name="campoTexto" placeholder="responda aqui" maxlength="2000" data-obrigatorio="S" ></textarea>');

                            elsif upper(ws_monta_pergunta.tp_resposta) = 'EMOJI' then 
                                ws_tag := ws_tag||'onclick="setSelect(this)"';
                                htp.p('<a '||ws_tag||'>'||a.codigo||'</a>');
                            
                            elsif upper(ws_monta_pergunta.tp_resposta) = 'STAR' then
                                if a.num = 1 then
                                    ws_tag := ws_tag||'onclick="setSelect(null, event)"';
                                end if;
                                htp.p('<span '||ws_tag||'>');
                            
                            elsif upper(ws_monta_pergunta.tp_resposta) = 'TEXTO2' then
                                ws_tag := ws_tag||'onblur="setTexto(this)"';
                                htp.p('<input type="text" name="campoTextoSimples" onblur="setTexto(this)" placeholder="'||nvl(a.ds_opcao, 'Responda aqui')||'" '||ws_tag||'/>');
                            end if;
                        end loop;

                        if upper(ws_monta_pergunta.tp_resposta) = 'STAR' then 
                            for a in (select cd_opcao
                                        from pqs_pergunta_opcao 
                                        where cd_pesquisa = ws_monta_pergunta.cd_pesquisa 
                                        and cd_pergunta = ws_monta_pergunta.cd_pergunta
                                        order by nr_ordem )  loop 
                                htp.p('</span>');
                            end loop;
                        end if;    
                        htp.p('</div>');  
                    end if;

                    if ws_monta_pergunta.id_justificativa = 'S' and ws_monta_pergunta.tp_resposta not in ('TEXTO') then
                        htp.p('<div class="abre-input-texto">');   
                            htp.p('<div class="abre-input">');
                                htp.p('<textarea maxlength="500" placeholder="Justifique sua resposta" data-obrigatorio="'||ws_monta_pergunta.id_obrigatorio||'" class="justificativa"></textarea>');
                            htp.p('</div>');
                        htp.p('</div>');
                    end if;
                    htp.p('</div>');
            end loop;
        close crs_monta_pergunta;
    exception
      when others then
        htp.p('ERRO MONTA PERGUNTA: '||sqlerrm||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
    end MONTA_PERGUNTA;
    
    PROCEDURE GRAVA_RESPOSTA (PRM_ID_PESQUISA   VARCHAR2 DEFAULT NULL,
                              PRM_CLIENTE       VARCHAR2 DEFAULT NULL,
                              PRM_USUARIO       VARCHAR2 DEFAULT NULL,
                              PRM_RESPOSTAS     VARCHAR2 DEFAULT NULL,
                              PRM_CD_PERGUNTA   VARCHAR2 DEFAULT NULL,
                              PRM_CD_OPCAO      VARCHAR2 DEFAULT NULL,
                              PRM_JUSTIFICATIVA VARCHAR2 DEFAULT NULL) as

        ws_error            exception;
        ws_id_pesquisa      varchar2(10);
        ws_cliente          varchar2(100);
        ws_usuario          varchar2(100);
        ws_resposta         varchar2(2000);
        ws_pergunta         varchar2(10);
        ws_cd_opcao         varchar2(10);
        ws_justificativa    varchar2(1000);

    begin
        ws_id_pesquisa:=nvl(prm_id_pesquisa,'N/A');
        ws_cliente:= nvl(prm_cliente,'N/A');
        ws_usuario:= nvl(prm_usuario,'N/A');
        ws_resposta:= nvl(prm_respostas, 'N/A');
        ws_pergunta:= nvl(prm_cd_pergunta, 'N/A');
        ws_cd_opcao:= nvl(prm_cd_opcao, 'N/A');
        ws_justificativa:= nvl(prm_justificativa, null);

        if ws_id_pesquisa <> 'N/A' and ws_cliente <> 'N/A' and ws_usuario <> 'N/A' then

            begin
                insert into pqs_respostas (CD_PESQUISA, CD_PERGUNTA, CD_CLIENTE, CD_USUARIO, CD_OPCAO, DH_RESPOSTA, VL_RESPOSTA, VL_JUSTIFICATIVA) 
                    values                (ws_id_pesquisa, ws_pergunta,  ws_cliente, ws_usuario, ws_cd_opcao, sysdate, ws_resposta, ws_justificativa);
            exception
            when others then
                raise ws_error;
            end;
            
            commit;
            htp.p('OK');
        else
            raise ws_error;
        end if;

    exception
      when ws_error then
        rollback;
        htp.p('FAIL'||sqlerrm);
    END GRAVA_RESPOSTA;

    FUNCTION TRADUZIR (PRM_TEXTO VARCHAR2) RETURN VARCHAR2 AS
       
        ws_translate varchar2(1000);
        
    BEGIN

        ws_translate:= translate( prm_texto,'ÁÇÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÜáçéíóúàèìòùâêîôûãõëü',
                                            'ACEIOUAEIOUAEIOUAOEUaceiouaeiouaeiouaoeu');

        return(ws_translate);

    END TRADUZIR;

    FUNCTION GET_TRANSLATOR ( prm_texto         varchar2,
                              prm_origem_lang   varchar2,
                              prm_destino_lang  varchar2 ) return varchar2 as 

        ws_request varchar2(4000);

    BEGIN

        ws_request := UTL_HTTP.REQUEST('http://translate.google.com/translate_a/t?client=j'||chr(38)||'text='||trim(replace(prm_texto, ' ', '+'))||chr(38)||'hl=pt'||chr(38)||'sl='||prm_origem_lang||chr(38)||'tl='||prm_destino_lang);
        ws_request := REGEXP_SUBSTR(ws_request,'trans\":(\".*?\"),\"');
        ws_request := substr(ws_request,9,length(ws_request)-11);

        return(ws_request);

    END GET_TRANSLATOR;

    procedure respostas_pesquisa( prm_json_respostas varchar2 ) as
        ws_dt_resposta      date:= sysdate;
        ws_sql_case         varchar2(2000);
        ws_sql_where        varchar2(2000);
        ws_pergs_unicas     varchar2(300);
        ws_count            number;
        ws_unic             number:= 0;
        ws_total_obrig      number;
        ws_obrig            varchar2(500);

        ws_json             JSON_OBJECT_T;
        ws_respostas        JSON_ARRAY_T;
        resp                JSON_OBJECT_T;
        ws_cd_pesquisa      varchar2(20); 
        ws_cd_cliente       varchar2(20); 
        ws_cd_usuario       varchar2(20);    

        ws_cd_pergunta      pqs_respostas.cd_pergunta%type;
        ws_cd_opcao         pqs_respostas.cd_opcao%type;
        ws_vl_resposta      pqs_respostas.vl_resposta%type;
        ws_vl_justificativa pqs_respostas.vl_justificativa%type;

        ws_id_obrigatorio   varchar2(20);
        ws_id_unico         varchar2(20);  

        procedure add_obrigatorio(prm_pergunta varchar2) is
        begin
            if ws_obrig is null or '|'||ws_obrig||'|' not like '%|'||prm_pergunta||'|%'  then
                if ws_obrig is not null then
                    ws_obrig:= ws_obrig||'|';
                end if;
                ws_obrig:= ws_obrig||prm_pergunta;
            end if;
        end add_obrigatorio; 
        /* retornos possíveis: OK - ERRO|Indicação das perguntas|Indicação do erro|Erro Oracle */
    begin
        
        ws_json := json_object_t(prm_json_respostas);
        ws_cd_pesquisa := ws_json.get_string('cd_pesquisa');
        ws_cd_cliente  := nvl(ws_json.get_string('cd_cliente'),'999999999');
        ws_cd_usuario  := upper(ws_json.get_string('cd_usuario'));

        select count(*) into ws_count from pqs_pesquisas where cd_pesquisa = ws_cd_pesquisa and id_situacao <> 'I'; 
        if ws_count = 0 then
            htp.p('ERRO||PESQUISA INDISPONÍVEL');
            return;
        end if;

        select count(*), count(decode(id_obrigatorio,'S',1,0)) into ws_count, ws_total_obrig from pqs_perguntas where cd_pesquisa = ws_cd_pesquisa;
        if ws_count = 0 then 
            htp.p('ERRO||NENHUMA PERGUNTA ENCONTRADA PARA ESSA PESQUISA');
            return;
        end if;

        -- controle de 1 resposta por usuario
        select count(distinct dh_resposta) into ws_count from PQS_RESPOSTAS 
        where cd_pesquisa = ws_cd_pesquisa and cd_cliente = ws_cd_cliente and upper(cd_usuario) = ws_cd_usuario and ws_cd_usuario <> 'DWU' ;
        if ws_count > 0 then
            htp.p('ERRO||USUÁRIO "'||upper(ws_cd_usuario)||'" JÁ RESPONDEU ESSA PESQUISA');
            return;
        end if;

        ws_respostas := ws_json.get_array('respostas');
        
        if ws_respostas.get_size = 0 then
            htp.p('ERRO||NENHUMA RESPOSTA REGISTRADA');
            return;
        end if;

        for i in 0..ws_respostas.get_size-1 loop
            
            resp := JSON_OBJECT_T(ws_respostas.get(i));

            ws_cd_pergunta := resp.get_string('cd_pergunta');
            ws_cd_opcao := resp.get_string('cd_opcao');
            ws_vl_resposta := resp.get_string('vl_resposta');
            ws_vl_justificativa := resp.get_string('vl_justificativa');

            select count(*), max(id_obrigatorio), max(id_unico) into ws_count, ws_id_obrigatorio, ws_id_unico 
            from pqs_perguntas where cd_pesquisa = ws_cd_pesquisa and cd_pergunta = ws_cd_pergunta;

            if ws_count = 0 then
                continue;
            end if;

            if ws_id_obrigatorio = 'S' then
                if ws_vl_resposta is null then
                    rollback;
                    htp.p('ERRO|'||ws_cd_pergunta||'|OBRIGATORIO');
                    return;
                end if; 
                add_obrigatorio(ws_cd_pergunta);
            end if;

            if ws_vl_resposta is not null then
                insert into pqs_respostas (cd_pesquisa, cd_pergunta, cd_cliente, cd_usuario, cd_opcao, dh_resposta, vl_resposta, vl_justificativa) 
                values (ws_cd_pesquisa, ws_cd_pergunta, ws_cd_cliente, ws_cd_usuario, ws_cd_opcao, ws_dt_resposta, ws_vl_resposta, ws_vl_justificativa);
            end if;

            -- chaves de respostas unicas
            if ws_id_unico = 'S' then
                if ws_unic > 0 then
                    ws_pergs_unicas := ws_pergs_unicas||',';
                    ws_sql_case     := ws_sql_case||',';
                    ws_sql_where    := ws_sql_where||' AND ';  
                end if;

                ws_unic := ws_unic + 1;
                ws_sql_case := ws_sql_case ||'MAX(CASE WHEN cd_pergunta = '''||ws_cd_pergunta||''' THEN lower(vl_resposta) END) AS p_'||ws_unic;
                ws_sql_where:= ws_sql_where||'p_'||ws_unic||' = lower('''||ws_vl_resposta||''')'; 
                ws_pergs_unicas:=ws_pergs_unicas||ws_cd_pergunta;
            end if;

        end loop;

        select count(*) into ws_count from fun.vpipe(ws_obrig) where ws_obrig is not null;
        if ws_total_obrig <> ws_count then
            rollback;
            htp.p('ERRO||'||(ws_total_obrig - ws_count)||' PERGUNTAS OBRIGATÓRIAS SEM RESPOSTAS');
            return;
        end if;

        if ws_unic > 0 then
            begin
                EXECUTE IMMEDIATE 'select count(*) from (
                    select '||ws_sql_case||' from pqs_respostas 
                    where cd_pesquisa = :cd_pesquisa and not (cd_usuario = :cd_usuario and cd_cliente = :cd_cliente and dh_resposta = :dt_resposta )
                    group by cd_cliente, cd_usuario, dh_resposta
                ) v1 where '||ws_sql_where
                INTO ws_count USING ws_cd_pesquisa, ws_cd_usuario, ws_cd_cliente, ws_dt_resposta;

                if ws_count > 0 then
                    rollback;
                    htp.p('ERRO|'||ws_pergs_unicas||'|UNICO');
                    return;
                end if;
            exception when others then
                rollback;
                insert into err_txt values('Erro pesquisa='||ws_cd_pesquisa||'= ID_UNICO|'||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - '||DBMS_UTILITY.FORMAT_ERROR_STACK);
                commit;
                htp.p('ERRO|'||ws_pergs_unicas||'|UNICO|'||sqlerrm); 
                return;
            end;
        end if;

        commit;
        htp.p('OK');
        
    exception
      when others then
        rollback;
        htp.p('ERRO||GERAL|'||sqlerrm);
        insert into err_txt values('Erro pesquisa='||ws_cd_pesquisa||'= GERAL|'||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - '||DBMS_UTILITY.FORMAT_ERROR_STACK);
        commit;
    end respostas_pesquisa;

END PESQUISA;
/
SHOW ERROR;