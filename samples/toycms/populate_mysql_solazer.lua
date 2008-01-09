local db = 'solazer'

require "luasql.mysql"
require "orbit.model"

local env = luasql.mysql()
local conn = env:connect(db, "root", "password")

local mapper = orbit.model.new("toycms_", conn, "mysql")



-- Table post

local t = mapper:new('post')

-- Record 1

local rec = {
 ["in_home"] = true,
 ["id"] = 1,
 ["body"] = "<p><img class=\"floatright\" src=\"$image_vpath/vdevinganca_interno.jpg\" alt=\"\" />Passado numa Londres totalitária do futuro, V de Vingança conta a história de Evey (Natalie Portman de Star Wars), uma jovem doce e tranquila que é salva de uma situação de vida ou morte por um vigilante mascarado, conhecido apenas por \"V\" (Hugo Weaving de Matrix).</p> \
            <p>Incomparavelmente carismático e ferozmente dotado na arte do combate e do logro, V dá início a uma revolução quando detona dois marcos da cidade de Londres e toma o controle das ondas de rádio e TV, urgindo os seus concidadãos a rebelarem-se contra a tirania e opressão.</p>\
            <p>À medida que Evey descobre a verdade sobre o misterioso V, ela descobre também algumas verdades sobre si própria e assim emerge uma inesperada aliada no plano para trazer liberdade e justiça a uma sociedade marcada pela crueldade e corrupção.</p>",
 ["published_at"] = 1168394580,
 ["abstract"] = "<i>V de Vingança</i> é um filme de 2006 estrelado por Natalie Portman e Hugo Weaving. É uma adaptação da graphic novel de Alan Moore, V for Vendetta, produzida pelos Irmãos Wachowski (mais conhecidos pela trilogia Matrix).",
 ["title"] = "V de Vingança",
 ["external_url"] = "",
 ["section_id"] = 1,
 ["image"] = "vdevinganca.jpg",
 ["published"] = true,
 ["user_id"] = 1}
rec = t:new(rec)
rec:save(true)

-- Record 2

local rec = {
 ["in_home"] = true,
 ["id"] = 2,
 ["body"] = "				  <p>Os Mutantes é uma banda brasileira formada em 1966, em São Paulo, por Rita Lee (vocais), Sérgio Dias (guitarra, vocais) e Arnaldo Baptista (baixo, teclado, vocais).</p>\
            <p>Os Mutantes foi um dos grupos mais dinâmicos, talentosos e radicais da era psicodélica. Um trio de experimentalistas musicais, a banda inovou no uso de feedback, distorção e truques de estúdio de todos os tipos.</p>\
            <p>Depois de quase 30 anos ausentes dos palcos, o grupo retorna em 2006 com sua formação clássica, exceção feita a Rita Lee, que não aceitou voltar ao grupo. A cantora Zélia Duncan foi convidada a assumir os vocais e desde então acompanha a banda.</p>\
\
",
 ["published_at"] = 1168222680,
 ["abstract"] = "Os Mutantes é uma banda brasileira formada em 1966, em São Paulo, por Rita Lee (vocais), Sérgio Dias (guitarra, vocais) e Arnaldo Baptista (baixo, teclado, vocais).",
 ["title"] = "Os Mutantes",
 ["external_url"] = "",
 ["section_id"] = 2,
 ["image"] = "mutantes.jpg",
 ["published"] = true,
 ["user_id"] = 1}
rec = t:new(rec)
rec:save(true)

-- Record 3

local rec = {
 ["in_home"] = true,
 ["id"] = 3,
 ["body"] = "          <p>Cada Um Com Seus Pobrema é uma peça de teatro brasileira, escrita e é interpretada por Marcelo Médici.</p>\
          <p>O ator interpreta nove personagens e surpreende com sua agilidade de mudar radicalmente de expressão e voz: empregada Cleusa; a vidente Mãe Jatira; Jonson, irmão do ator; o último mico leão dourado; o corintiano Sanderson, que vende chiclete na porta do teatro; a smurfete; a apresentadora infantil Tia Penha; a dona do teatro Yumi; e o ator.</p>\
          <p>O personagem central é um ator de teatro que ao desistir de fazer sua apresentação e começa a falar sobre sua própria vida. Surgem então os demais personagens, todos politicamente incorretos, comentando e criticando várias situações do cotidiano.</p>\
\
",
 ["published_at"] = 1167790740,
 ["abstract"] = "Cada Um Com Seus Pobrema é uma peça de teatro brasileira, escrita e é interpretada por Marcelo Médici.",
 ["title"] = "Cada Um Com Seus Pobrema",
 ["external_url"] = "",
 ["section_id"] = 3,
 ["image"] = "cadaum.jpg",
 ["published"] = true,
 ["user_id"] = 1}
rec = t:new(rec)
rec:save(true)

-- Record 4

local rec = {
 ["id"] = 4,
 ["body"] = "          <p><img src=\"$image_vpath/angelina.jpg\" class=\"floatright\" width=\"200\" alt=\"\" />Angelina Jolie Voight (Los Angeles, 4 de junho de 1975) é uma atriz americana.</p>\
          <p>Filha do também ator e diretor de cinema Jon Voight e da ex-atriz e modelo de Marcheline Bertrand, Angelina tornou-se Embaixadora da Boa Vontade da ONU após conhecer o Camboja nas gravações do filme Tomb Raider; na mesma época a actriz adotou um bebê cambojano, Maddox, iniciando, assim, uma mudança radical em sua vida.</p>\
          <p><img src=\"$image_vpath/angelina_interno1.jpg\" class=\"floatleft\" width=\"200\" alt=\"\" />Em 2005 a ser relacionada com Brad Pitt, com quem partilhou a tela em Mr. and Mrs. Smith. Enquanto os dois negavam qualquer envolvimento, o casal começou a ser fotografado junto e a voar à volta do globo em missões humanitárias, juntamente com os filhos adotivos da atriz.</p>\
          <p>Brad Pitt acompanhou-a à Etiópia em Julho de 2005 para adotar sua filha Zahara que vivia num orfanato desse país. No fim de 2005, Brad e Angelina visitaram por duas vezes o Paquistão como embaixadores das Nações Unidas para ajudar às vítimas de um terremoto. A 2 de Dezembro de 2005 foi anunciado que Pitt tinha iniciado o processo legal de adoção dos dois filhos adotivos de Angelina, o filho Maddox (nascido em 2002) e a filha Zahara, tendo requerido também a mudança dos apelidos destes para Jolie-Pitt.</p>\
          <p><img src=\"$image_vpath/angelina_interno2.jpg\" class=\"floatright\" width=\"200\" alt=\"\" />Pouco mais de um mês depois, a 19 de Janeiro de 2006, um juiz de Santa Mônica, na Califórnia, aprovou o pedido. A 27 de Maio de 2006, Angelina Jolie deu à luz, em Swakopmund, na Namíbia, o primeiro filho biológico do casal, uma menina a quem chamaram Shiloh Nouvel Jolie-Pitt, que nasceu num ambiente envolto num enorme secretismo.</p>\
          <p>Com um talento e beleza invulgares, esta atriz escolheu não usar o sobrenome do pai, que é um ator Oscarizado, pois parece que têm uma má relação. Angelina entrou com doze anos para o Lee Strasberg Theatre Institute, onde participou em diversas peças do mesmo. Frequentou também a Universidade de Nova Iorque, tendo-se graduado em Filme.</p>\
          <p>Trabalhou também como modelo profissional em Londres, Nova Iorque e Los Angeles e participou em vídeos musicais dos Rolling Stones, Meat Loaf, Lenny Kravitz, Antonello Venditti e The Lemonheads. Também participou em cinco das obras que o seu irmão James Haven Voight, realizou para a escola de cinema da Califórnia do Sul que frequentava na altura.</p>\
            <p>\
            <strong>FILMOGRAFIA</strong><br>\
          - Lara Croft Tomb Raider: A Origem da Vida (Lara Croft Tomb Raider: The Cradle of Life, 2003)<br>\
          - Uma Vida em Sete Dias (Life or Something Like It, 2002) <br>\
          - Lara Croft:Tomb Raider (Lara Croft: Tomb Raider, 2001) <br>\
          - Pecado Original (Original Sin, 2001) <br>\
          - 60 Segundos (Gone in Sixty Seconds, 2000) <br>\
          - Garota, Interrompida (Girl, Interrupted, 1999) <br>\
          - O Colecionador de Ossos (The Bone Collector, 1999). <br>\
          - Alto Controle (Pushing Tin, 1999) <br>\
          - Corações Apaixonados (Playing by Heart, 1998) <br>\
          - Hell’s Kitchen (1998) <br>\
          - Gia – Fama e Destruição (Gia, 1998) <br>\
          - Brincando Com a Morte (Playing God, 1997) <br>\
          - George Wallace – O Homem Que Vendeu Sua Alma (George Wallace, 1997) <br>\
          - True Women (1997) <br>\
          - Duas Famílias em Pé de Guerra (Love Is All There Is, 1996) <br>\
          - Mojave Sob o Luar do Deserto (Mojave Moon, 1996) <br>\
          - Rebeldes (Foxfire, 1996) <br>\
          - Without Evidence (1995) <br>\
          - Hackers – Piratas de Computador (Hackers, 1995) <br>\
          - Cyborg 2 (Cyborg 2: Glass Shadow, 1993) <br>\
          - Lookin’ to Get Out (1982)<br>\
          </p>\
\
",
 ["published_at"] = 1169259660,
 ["abstract"] = "<strong>Angelina Jolie</strong> tornou-se Embaixadora da Boa Vontade da ONU após conhecer o Camboja nas gravações do filme Tomb Raider.",
 ["title"] = "Angelina Jolie",
 ["external_url"] = "",
 ["section_id"] = 6,
 ["image"] = "angelina.jpg",
 ["published"] = true,
 ["user_id"] = 1}
rec = t:new(rec)
rec:save(true)

-- Record 5

local rec = {
 ["id"] = 5,
 ["body"] = "            <p>Estados Unidos &#151; O estado americano de West Virginia, que tem os maiores problemas com obesidade infantil em todos os Estados Unidos, decidiu adotar uma solução radical: videogame. O governo tem planos de instalar máquinas de \"Dance Dance Revolution\", jogo desenvolvido pela empresa japonesa Konami.</p>\
            <p>A idéia é colocar o popular game dançante em todas as escolas públicas. O governo cita estudos que mostraram que o jogo ajuda a interromper o ganho de peso.</p>\
            <p>Resultados preliminares de um estudo de 24 semanas com 50 crianças obesas ou com sobrepeso, com idades entre 7 e 12, mostraram que as que jogaram o jogo em casa por pelo menos 30 minutos cinco dias por semana mantiveram seu peso e viram uma redução em alguns fatores de risco para doença cardíaca e diabetes.</p>\
            <p>O grupo de controle do estudo era composto por 12 crianças que não jogaram o videogame pelas primeiras 12 semanas, mas então passaram a jogar até o final do estudo. Essas crianças acumularam cerca de três quilos durante a primeira fase do estudo, mas depois tiveram o peso estabilizado na segunda metade. O consumo de alimentos não foi monitorado pelo estudo.</p>\
\
",
 ["published_at"] = 1170383100,
 ["abstract"] = "",
 ["title"] = "Escolas usam game para combater obesidade",
 ["external_url"] = "",
 ["section_id"] = 7,
 ["image"] = "",
 ["published"] = true,
 ["user_id"] = 1}
rec = t:new(rec)
rec:save(true)

-- Record 6

local rec = {
 ["id"] = 6,
 ["body"] = "            <p>Davos &#151; Fusão da TV com a Internet</p>\
            <p>Segundo Bill Gates, presidente da Microsoft, em cinco anos a tv estará completamente mudada com a sua inserção na internet. Nos últimos anos sites de vídeo como YouTube vem tranformando a relação da imagem com o usuário. Existe uma diminuição de horas assistidas na televisão.</p>\
\
",
 ["published_at"] = 1170037560,
 ["abstract"] = "",
 ["title"] = "Fusão da TV com a Internet",
 ["external_url"] = "",
 ["section_id"] = 7,
 ["image"] = "",
 ["published"] = true,
 ["user_id"] = 1}
rec = t:new(rec)
rec:save(true)

-- Record 7

local rec = {
 ["id"] = 7,
 ["body"] = "            <p><img class=\"floatright\" src=\"$image_vpath/200px-Wikipedia-logo.jpg\" alt=\"\" />Estados Unidos &#151;YouTube e Wikipedia são campeões em 2006. Saiu a lista das cinco marcas mais fortes do mundo no ano de 2006, segundo a tradicional pesquisa anual da revista on-line Brandchannel.com. Quatro das cinco são do mundo da alta tecnologia, e duas delas são estreantes que deram muito o que falar no ano que passou YouTube e Wikipedia.</p>\
            <p>Google foi campeão mais uma vez</p>\
            <p>Logotipo da Wikipédia.A campeã, mais uma vez, foi a companhia de internet Google, que já havia faturado no ano passado. No segundo posto apareceu a Apple. Mas as maiores surpresas foram mesmo o YouTube e a Wikipedia, que nunca haviam figurado nas \"cinco mais\", e empurraram a famosa marca de cafeteria americana Starbucks para a quinta posição.</p>\
\
",
 ["published_at"] = 1169778420,
 ["abstract"] = "",
 ["title"] = "YouTube e Wikipedia são campeões em 2006",
 ["external_url"] = "",
 ["section_id"] = 7,
 ["image"] = "",
 ["published"] = true,
 ["user_id"] = 1}
rec = t:new(rec)
rec:save(true)

-- Record 8

local rec = {
 ["id"] = 8,
 ["body"] = "            <p><img class=\"floatright\" src=\"$image_vpath/Imagem_Lula_Bono.jpg\" alt=\"\" />Brasil — Bono, o cantor da banda de rock U2 que tem uma apresentação marcada para São Paulo, participou de um almoço com o Presidente Luiz Inácio Lula da Silva e sua esposa Dona Marisa, no último domingo, na Granja do Torto.</p>\
            <p>\"É um sonho estar aqui, porque Lula luta não só contra a pobreza, mas também contra a pobreza no mundo, como na África. Estou muito animado com isso\", disse o cantor.\
            <p>Bono disse em entrevista para a Radiobras que foi \"um grande encontro, com um almoço maravilhoso\" o que teve com Lula. Ele disse que o Brasil é a \"primeira liderança da América Latina\" e que Lula \"surgiu no mundo como uma grande novidade\".\
            <p>O cantor disse que irá doar a sua guitarra para o Programa Fome Zero.</p>\
\
",
 ["published_at"] = 1171938420,
 ["abstract"] = "",
 ["title"] = "Bono diz que Lula luta contra a pobreza no mundo",
 ["external_url"] = "",
 ["section_id"] = 7,
 ["image"] = "",
 ["published"] = true,
 ["user_id"] = 1}
rec = t:new(rec)
rec:save(true)

-- Record 9

local rec = {
 ["id"] = 9,
 ["body"] = "<p><img class=\"floatright\" src=\"$image_vpath/dogville_interno.jpg\" alt=\"\" />O filme chama a atenção pela simplicidade de seus cenários e cortes de cenas não convencionais. Todo o filme foi filmado dentro de um galpão localizado na Suécia com o mínimo de artefatos, há poucas mesas e algumas paredes, mas normalmente há apenas marcações no chão indicando que ali é a casa de tal pessoa, ou há um arbusto. </p>\
            <p>Apesar dos personagens fazerem constantes referências a paisagem, ou ao céu, o fundo é infinito, tendo constantes alterações de luz e cor que indicam mudanças de dia/noite, clima e de momentos importantes do filme. O filme ainda tem um narrador onisciente e é o próprio Lars von Trier quem controla a câmera.</p>\
            <p>Tudo isso são artimanhas do diretor para que o público não se esqueça de que assistem a uma peça de ficção, valorizando o trabalho dos atores. O resultado é aberto a opiniões: alguns espectadores saem maravilhados com a sensibilidade com que Lars retrata a arrogância humana e a atuação brilhante (Nicole Kidman, vencedora do Oscar por As Horas) outros acham o filme longo e maçante (o filme tem cerca de 2 horas e meia de duração).</p>\
            <p>Dogville apresenta claras referências visuais e influências de produção herdadas do movimento Dogma 95, manifesto cinematográfico que foi iniciado pelo próprio Lars Von Trier. Em Dogville temos a ausência de trilha sonora no filme, câmera na mão, não há deslocamentos temporais ou geográficos. Entretanto, em Dogville há a presença de gruas, iluminação artificial e cenografia, itens que eram proibidos no Manifesto Dogma 95.</p>\
            <p>Existem visíveis influências teatrais em Dogville, como o teatro de Bertolt Brecht, que costumava colocar avisos de 'atenção, não se emocione, isso é ficção' em suas peças; o teatro caixa preta, realizado em um único cenário com as paredes todas pretas, e finalmente o teatro do absurdo, onde os atores improvisam e criam situações onde interagem com objetos imaginários.</p>\
            <p>Percebe-se na construção da trama e no foco humanista do tratamento dos personagens influências de escolas de filosofia, especialmente as gregas. Por duas vezes cita-se nos diálogos os ensinamentos dos estoicistas, uma escola que pregava o abandono da emoção para vivermos sem dor. E muito da moral história gira em torno da diferença entre o altruísmo - dar sem esperar nada - e o quid pro quod - que exige uma compensação equivalente para cada ação.</p>",
 ["published_at"] = 1168213320,
 ["abstract"] = "<i>Dogville</i> é um filme dinamarquês lançado em 2003 e dirigido por Lars von Trier, estrelando Nicole Kidman (Oscar de melhor atriz) e Paul Bettany.",
 ["title"] = "Dogville",
 ["external_url"] = "",
 ["section_id"] = 1,
 ["image"] = "dogville.jpg",
 ["published"] = true,
 ["user_id"] = 1}
rec = t:new(rec)
rec:save(true)

-- Record 10

local rec = {
 ["id"] = 10,
 ["body"] = "            <p><img class=\"floatright\" src=\"$image_vpath/matrix_interno.jpg\" alt=\"\" />Matrix, ou The Matrix é um filme realizado pelos irmãos Wachowski e protagonizado por Keanu Reeves no papel de Neo. O filme consegue colocar (para alguns de forma superficial, para outros de forma pertinente e profunda) em seu enredo temas relacionados a diversas religiões e mitologias (cristianismo, judaísmo, budismo, taoismo), tecnologia (realidade virtual, inteligência artificial), e filosofia (mito da caverna de Platão, dúvida metódica de Descartes),temas pré socráticos, em meio a filosofia natural taoísta das artes marciais e efeitos especiais que revolucionaram a história do cinema, influenciando várias produções cinematográficas em uma determinada época. Assim mantém-se ao lado de filmes como \"metrópolis\" e \"2001: uma odisséia no espaço\" como obra singular da ficção científica.</p>\
            <p>Na história o mundo encontra-se devastado pela guerra nuclear e o que restou da humanidade é escrava das máquinas vivendo em uma realidade virtual que simularia nosso mundo do século XX, as máquinas precisam da bioeletricidade que o corpo humano produz, e para isso ocorrer é necessário que os seres humanos sejam cultivados e vivam em uma sociedade. Como em \"Admirável Mundo Novo\" de Aldous Huxley, os seres humanos são cultivados, fabricados pelas máquinas e pelo poder e assim ignoram a falsa realidade que os rodeiam. A outra parcela da humanidade vive em Zion (Sião), uma comunidade que vive no subsolo terrestre, é o único lugar onde todos são livres, fora da simulação da Matrix, fazem resistência e vivem uma guerra secular contra o domínio das máquinas.</p>\
            <p>O exército de Sião invade o sistema da Matrix para combatê-la no ciberespaço, existem várias naves hovercrafts de Sião, fazendo uma guerrilha contra a matrix, com capitães comandando a tripulações de hackers e soldados, Nabucodonosor é a nave do capitão Morpheus, que acredita, junto com sua tripulação, na vinda de um salvador que irá libertar a humanidade do domínio das máquinas. Neo é este salvador e Morpheus, como João Batista, é o que vai revelar o destino de Neo no mundo.</p>\
            <p>Neo ao ser desconectado da Matrix, passa mal, não aceita e tem náuseas (como no \"mito da caverna\"...a luz da realidade, fora da caverna...que incomoda), é a descoberta de uma nova vida fora dos moldes à que ele sempre foi condicionado. As artes marciais são muito presentes, devido a influência de noções budistas e taoistas, de superação e desprêendimento do mundo material - falso -,que leva ao aprisionamento da mente, como no pensamento filosófico budista. Neo precisa deixar de ser escravo de sua mente para superar a falsa realidade, e assim consegue desenvolver seu kung fu além dos limites da física materialista da Matrix. Matrix foi escrito em três partes (desde o lançamento do primeiro filme), sempre foi concebido para ser uma trilogia.</p>\
            <p>O primeiro filme é a revelação do salvador, em Matrix Reloaded e no Matrix Revolutions Neo seguirá o seu destino na missão de salvar a humanidade, junto com Trinity, uma guerreira inspirada na samurai cyborg do livro Neuromancer de Willian Gibson (principal influência de Matrix). Em Reloaded (\"recarregado\", como um programa de software reprogramável) Neo faz a trindade com Morpheus e Trinity e estes tem como missão reprogramar, em 72 horas, o mainframe (computador central da matrix)para que um mega ataque à Sião não se realize, pois cada vez mais os revolucionários libertários de Zion tem libertado mais pessoas da falsa realidade, colocando em risco o funcionamento do sistema inteiro que faz a matrix.</p>\
            <p>Neo, na segunda metade da trilogia,tem sonhos com a morte de Trinity e insiste em um longo e complexo diálogo com a Oráculo, em saber se pode ou não mudar o destino. Outra parte interessante é a sua conversa com o Arquiteto, que é parte da Matrix materializada em um indivíduo, este é como se fosse o progama base da Matrix, estremamente racional, lógico...como o Deus cristão-hebreu,como a ciência contemporânea. A Oráculo seria o outro programa base da Matrix (como um cerébro dividido em duas partes), porém ela representa a mística, o inesplicável, a fé, a religiosidade...possui uma sabedoria não racionalista sobre o universo. Estes dois programas fazem a Matrix e estão em desacordo, pois a Oráculo ajuda a humanidade zionita a se libertar de uma forma justa (livre-arbítrio), ela não quer o fim da Matrix, mas acredita no livre-arbítrio dos humanos, e não em um sistema imposto e repressor, como o Arquiteto quer.</p>\
            <p>Outro personagem pertinente é o Agente Smith, um programa de segurança do sistema que está ultrapassado (ao ser derrotado por Neo no primeiro filme), e deixado de lado pela Matrix, mas que não aceita seu destino (e buscando um novo propósito existencial)se rebela tanto contra a Matrix quanto contra a humanidade, se tornando um vírus que pode acabar derrubando o sistema e assim matando todos que estão ali presos (a única forma de alguém sair dali vivo é pelo despertar da consciência e a livre opção, a pílula vermelha, que representa a fuga da \"caverna\"). Neo, como Jesus e Buda, possui como destino não fazer a guerra contra as máquinas (como o personagem John Connor da série Terminator), pois esta já existe há muitos anos, mas sim levar ao fim desta guerra. Ele traz uma mensagem de paz e como isso acontece é o tema presente na terceira parte da trilogia.</p>\
            <p>Matrix é um filme complexo que interliga 3 campos de saberes diferentes, como a informática, religiosidades e filosofias, assim gerando muitas polêmicas. Não é um filme de fácil comprêensão, gerando muitas vezes críticas limitadas e vazias, talvez por que cada ramo destes três saberes estão segmentados na cabeça dos ocidentais.</p>\
\
",
 ["published_at"] = 1167867780,
 ["abstract"] = "<i>Matrix</i> é um filme realizado pelos irmãos Wachowski e protagonizado por Keanu Reeves no papel de Neo. O filme consegue colocar em seu enredo temas relacionados a diversas religiões e mitologias, tecnologia, filosofia, temas pré socráticos, em meio a filosofia natural taoísta das artes marciais e efeitos especiais que revolucionaram a história do cinema, influenciando várias produções cinematográficas em uma determinada época.",
 ["title"] = "Matrix",
 ["external_url"] = "",
 ["section_id"] = 1,
 ["image"] = "matrix.jpg",
 ["published"] = true,
 ["user_id"] = 1}
rec = t:new(rec)
rec:save(true)

-- Record 11

local rec = {
 ["id"] = 11,
 ["body"] = "",
 ["published_at"] = 1168908360,
 ["abstract"] = "",
 ["title"] = "Alicia Keys",
 ["external_url"] = "",
 ["section_id"] = 6,
 ["image"] = "alicia_keys.jpg",
 ["published"] = true,
 ["user_id"] = 1}
rec = t:new(rec)
rec:save(true)

-- Record 12

local rec = {
 ["id"] = 12,
 ["body"] = "",
 ["published_at"] = 1168476420,
 ["abstract"] = "",
 ["title"] = "Bono Vox",
 ["external_url"] = "",
 ["section_id"] = 6,
 ["image"] = "bono_vox.jpg",
 ["published"] = true,
 ["user_id"] = 1}
rec = t:new(rec)
rec:save(true)

-- Record 13

local rec = {
 ["id"] = 13,
 ["body"] = "",
 ["published_at"] = 1168044480,
 ["abstract"] = "",
 ["title"] = "Nicole Kidman",
 ["external_url"] = "",
 ["section_id"] = 6,
 ["image"] = "nicole.jpg",
 ["published"] = true,
 ["user_id"] = 1}
rec = t:new(rec)
rec:save(true)

-- Record 14

local rec = {
 ["id"] = 14,
 ["body"] = "",
 ["published_at"] = 1167785280,
 ["abstract"] = "",
 ["title"] = "Tom Hanks",
 ["external_url"] = "",
 ["section_id"] = 6,
 ["image"] = "tom_hanks.jpg",
 ["published"] = true,
 ["user_id"] = 1}
rec = t:new(rec)
rec:save(true)

-- Table comment

local t = mapper:new('comment')

-- Table user

local t = mapper:new('user')

-- Record 1

local rec = {
 ["id"] = 1,
 ["name"] = "Fabio Mascarenhas",
 ["login"] = "mascarenhas@acm.org",
 ["password"] = "password"}
rec = t:new(rec)
rec:save(true)

-- Record 2

local rec = {
 ["id"] = 2,
 ["name"] = "André Carregal",
 ["login"] = "carregal@pobox.com",
 ["password"] = "password"}
rec = t:new(rec)
rec:save(true)

-- Table section

local t = mapper:new('section')

-- Record 1

local rec = {
 ["id"] = 1,
 ["description"] = "Notícias sobre cinema e resenhas de filmes.",
 ["title"] = "Cinema",
 ["tag"] = "menu-cinema"}
rec = t:new(rec)
rec:save(true)

-- Record 2

local rec = {
 ["id"] = 2,
 ["description"] = "",
 ["title"] = "Música",
 ["tag"] = "menu-musica"}
rec = t:new(rec)
rec:save(true)

-- Record 3

local rec = {
 ["id"] = 3,
 ["description"] = "",
 ["title"] = "Teatro",
 ["tag"] = "menu-teatro"}
rec = t:new(rec)
rec:save(true)

-- Record 4

local rec = {
 ["id"] = 4,
 ["description"] = "",
 ["title"] = "Livros",
 ["tag"] = "menu-livros"}
rec = t:new(rec)
rec:save(true)

-- Record 5

local rec = {
 ["id"] = 5,
 ["description"] = "",
 ["title"] = "Noite",
 ["tag"] = "menu-noite"}
rec = t:new(rec)
rec:save(true)

-- Record 6

local rec = {
 ["id"] = 6,
 ["description"] = "",
 ["title"] = "Perfil",
 ["tag"] = "perfil"}
rec = t:new(rec)
rec:save(true)

-- Record 7

local rec = {
 ["id"] = 7,
 ["description"] = "",
 ["title"] = "Notícias",
 ["tag"] = "noticias"}
rec = t:new(rec)
rec:save(true)
