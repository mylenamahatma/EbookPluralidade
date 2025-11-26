extends Control

var paginas = []
var audios = []
var indice = 0
var som_ligado = true
var video_tocando = false

@onready var imagem = $Imagem
@onready var btn_anterior = $BtnAnterior
@onready var btn_proximo = $BtnProximo
@onready var audio_player = $AudioStreamPlayer
@onready var btn_audio = $BtnAudio

# Video
@onready var video = $VideoPlayer
@onready var btn_video_toggle = $VideoPlayer/BtnToggle

# Partículas na página 3
@onready var particulas = $Particulas3

# Container do acelerômetro na página 6
@onready var acelerometro_container = $AcelerometroContainer

# Cores dos botões laranja
const COR_PADRAO = Color("#f26423")
const COR_HOVER = Color("#e0541b")
const COR_PRESSIONADO = Color("#c34716")


func _ready():
	# Carregar imagens
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

	# Carregar áudios
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

	# Configurar VideoStreamPlayer
	video.stream = preload("res://assets/videos/video.ogv")
	video.paused = true
	video.visible = false
	video_tocando = false

	btn_video_toggle.visible = false
	btn_video_toggle.text = "Play"
	btn_video_toggle.pressed.connect(_video_toggle)
	_configurar_estilo_botao(btn_video_toggle)

	# Conectar botões
	btn_anterior.pressed.connect(_voltar)
	btn_proximo.pressed.connect(_avancar)
	btn_audio.pressed.connect(_alternar_audio)

	# Aplicar estilo laranja
	_configurar_estilo_botao(btn_anterior)
	_configurar_estilo_botao(btn_proximo)

	btn_audio.texture_normal = preload("res://assets/icons/audio_on.png")

	atualizar_pagina()


# ===============================
# CONFIGURAR BOTÕES LARANJA
# ===============================
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


# ===============================
# ATUALIZAR PÁGINA
# ===============================
func atualizar_pagina():
	imagem.texture = paginas[indice]
	imagem.expand = true
	imagem.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED

	# Botões anterior/proximo
	btn_anterior.visible = indice != 0
	btn_anterior.text = "Página anterior"

	if indice == paginas.size() - 1:
		btn_proximo.text = "Voltar ao início"
	else:
		btn_proximo.text = "Próxima página"

	# Reset vídeo se não for página 5
	if indice != 5:
		video.stop()
		video.paused = true
		video.visible = false
		btn_video_toggle.visible = false
		video_tocando = false
	else:
		video.visible = true
		btn_video_toggle.visible = true
		btn_video_toggle.text = "Play"
		video.paused = true
		video_tocando = false

	# Mostrar partículas somente na página 3
	if indice == 3:
		particulas.visible = true
		particulas.restart()
	else:
		particulas.visible = false

	# Mostrar acelerômetro somente na página 6
	if indice == 6:
		acelerometro_container.visible = true
	else:
		acelerometro_container.visible = false

	# Áudio automático
	if indice != 5:
		if som_ligado:
			audio_player.stream = audios[indice]
			audio_player.play()
	else:
		if som_ligado:
			audio_player.stream = audios[indice]
			audio_player.play()


# ===============================
# NAVEGAÇÃO
# ===============================
func _avancar():
	indice = (indice + 1) % paginas.size()
	atualizar_pagina()


func _voltar():
	indice = max(0, indice - 1)
	atualizar_pagina()


# ===============================
# ÁUDIO ON/OFF
# ===============================
func _alternar_audio():
	som_ligado = !som_ligado
	if som_ligado:
		btn_audio.texture_normal = preload("res://assets/icons/audio_on.png")
		if not video_tocando:
			audio_player.stream = audios[indice]
			audio_player.play()
	else:
		btn_audio.texture_normal = preload("res://assets/icons/audio_off.png")
		audio_player.stop()


# ===============================
# BOTÃO VIDEO PLAY/PAUSE
# ===============================
func _video_toggle():
	if video_tocando:
		video.paused = true
		video_tocando = false
		btn_video_toggle.text = "Play"
	else:
		if not video.is_playing():
			video.play()
		video.paused = false
		video_tocando = true
		btn_video_toggle.text = "Pausa"
		audio_player.stop()  # parar narração
