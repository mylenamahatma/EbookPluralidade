extends Control

var paginas = []
var audios = []
var indice = 0
var som_ligado = true

@onready var imagem = $imagem
@onready var btn_anterior = $BtnAnterior
@onready var btn_proximo = $BtnProximo

@onready var audio_player = $AudioStreamPlayer
@onready var btn_audio = $BtnAudio   # TextureButton

# Paleta dos botões laranja
const COR_PADRAO = Color("#f26423")
const COR_HOVER = Color("#e0541b")
const COR_PRESSIONADO = Color("#c34716")

func _ready():
	# IMAGENS DAS PÁGINAS
	paginas = [
		preload("res://assets/images/capa.png"),
		preload("res://assets/images/pagina1.png"),
		preload("res://assets/images/pagina2.png"),
		preload("res://assets/images/pagina3.png"),
		preload("res://assets/images/pagina4.png"),
		preload("res://assets/images/pagina5.png"),
		preload("res://assets/images/pagina6.png"),
		preload("res://assets/images/contracapa.png")
	]

	# ÁUDIOS — MESMO NOME DAS IMAGENS
	audios = [
		preload("res://assets/audios/capa.ogg"),
		preload("res://assets/audios/pagina1.ogg"),
		preload("res://assets/audios/pagina2.ogg"),
		preload("res://assets/audios/pagina3.ogg"),
		preload("res://assets/audios/pagina4.ogg"),
		preload("res://assets/audios/pagina5.ogg"),
		preload("res://assets/audios/pagina6.ogg"),
		preload("res://assets/audios/contracapa.ogg")
	]

	# Conectar botões
	btn_anterior.connect("pressed", Callable(self, "_voltar"))
	btn_proximo.connect("pressed", Callable(self, "_avancar"))
	btn_audio.connect("pressed", Callable(self, "_alternar_audio"))

	# Aplicar estilo laranja
	_configurar_estilo_botao(btn_anterior)
	_configurar_estilo_botao(btn_proximo)

	# Ícone inicial do botão de som
	btn_audio.texture_normal = preload("res://assets/icons/audio_on.png")

	atualizar_pagina()


# CONFIGURAÇÃO DE ESTILO DOS BOTÕES
func _configurar_estilo_botao(botao):
	botao.remove_theme_stylebox_override("normal")
	botao.remove_theme_stylebox_override("hover")
	botao.remove_theme_stylebox_override("pressed")

	var estilo_normal = StyleBoxFlat.new()
	estilo_normal.bg_color = COR_PADRAO
	estilo_normal.set_corner_radius_all(24)
	estilo_normal.border_color = Color.WHITE
	estilo_normal.set_border_width_all(2)

	var estilo_hover = estilo_normal.duplicate()
	estilo_hover.bg_color = COR_HOVER

	var estilo_pressed = estilo_normal.duplicate()
	estilo_pressed.bg_color = COR_PRESSIONADO

	botao.add_theme_stylebox_override("normal", estilo_normal)
	botao.add_theme_stylebox_override("hover", estilo_hover)
	botao.add_theme_stylebox_override("pressed", estilo_pressed)

	botao.add_theme_color_override("font_color", Color.WHITE)
	botao.add_theme_font_size_override("font_size", 24)


# ATUALIZAR PÁGINA
func atualizar_pagina():
	# Troca a imagem
	imagem.texture = paginas[indice]
	imagem.expand = true
	imagem.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED

	# Mostrar / esconder botão anterior
	btn_anterior.visible = indice != 0
	btn_anterior.text = "Página anterior"

	# Texto do botão próximo
	if indice == paginas.size() - 1:
		btn_proximo.text = "Voltar ao início"
	else:
		btn_proximo.text = "Próxima página"

	# Áudio automático
	audio_player.stop()

	if som_ligado:
		audio_player.stream = audios[indice]
		audio_player.play()


# AVANÇAR PÁGINA
func _avancar():
	if indice < paginas.size() - 1:
		indice += 1
	else:
		indice = 0
	atualizar_pagina()


# VOLTAR PÁGINA
func _voltar():
	indice = max(0, indice - 1)
	atualizar_pagina()


# BOTÃO DE SOM ON/OFF
func _alternar_audio():
	som_ligado = !som_ligado

	if som_ligado:
		btn_audio.texture_normal = preload("res://assets/icons/audio_on.png")
		audio_player.stream = audios[indice]
		audio_player.play()
	else:
		btn_audio.texture_normal = preload("res://assets/icons/audio_off.png")
		audio_player.stop()    # NÃO VOLTA DE PÁGINA AGORA!
