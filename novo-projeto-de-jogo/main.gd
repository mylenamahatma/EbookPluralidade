extends Control 

# ===============================
# VARIÁVEIS GLOBAIS
# ===============================
var paginas = []
var audios = []
var indice = 0
var som_ligado = true
var video_tocando = false

# ZOOM (somente página 3)
var zoom_atual = 1.0
var zoom_min = 1.0
var zoom_max = 3.0

# ===============================
# NODES PRINCIPAIS
# ===============================
@onready var imagem = $Imagem
@onready var btn_anterior = $BtnAnterior
@onready var btn_proximo = $BtnProximo
@onready var audio_player = $AudioStreamPlayer
@onready var btn_audio = $BtnAudio

# Vídeo
@onready var video = $VideoPlayer
@onready var btn_video_toggle = $VideoPlayer/BtnToggle

# Partículas página 3
@onready var particulas = $Particulas3

# Pluralidade (página 3)
@onready var pluralidade = $Pluralidade

# Container acelerômetro página 6
@onready var acelerometro_container = $AcelerometroContainer

# Container página 1
@onready var pagina1_container = $Pagina1Container

# ===============================
# CORES BOTÕES
# ===============================
const COR_PADRAO = Color("#f26423")
const COR_HOVER = Color("#e0541b")
const COR_PRESSIONADO = Color("#c34716")

# ===============================
# READY
# ===============================
func _ready():
	_carregar_recursos()
	_configurar_video()
	_conectar_botoes()
	atualizar_pagina()

# ===============================
# CARREGAR IMAGENS E ÁUDIOS
# ===============================
func _carregar_recursos():
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

# ===============================
# CONFIGURAR VÍDEO
# ===============================
func _configurar_video():
	video.stream = preload("res://assets/videos/video.ogv")
	video.paused = true
	video.visible = false
	video_tocando = false

	btn_video_toggle.visible = false
	btn_video_toggle.text = "Play"
	btn_video_toggle.pressed.connect(_video_toggle)
	_configurar_estilo_botao(btn_video_toggle)

# ===============================
# CONECTAR BOTÕES
# ===============================
func _conectar_botoes():
	btn_anterior.pressed.connect(_voltar)
	btn_proximo.pressed.connect(_avancar)
	btn_audio.pressed.connect(_alternar_audio)

	_configurar_estilo_botao(btn_anterior)
	_configurar_estilo_botao(btn_proximo)

	btn_audio.texture_normal = preload("res://assets/icons/audio_on.png")

# ===============================
# ESTILO BOTÃO
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

	# Página 1
	pagina1_container.visible = indice == 1

	# Somente página 3 mostra a pluralidade
	pluralidade.visible = (indice == 3)

	# Reset da pluralidade na página 3
	if indice == 3:
		zoom_atual = 1.0
		pluralidade.scale = Vector2(1, 1)
		pluralidade.position = Vector2(0, 0)

	# Botões navegação
	btn_anterior.visible = indice != 0
	btn_anterior.text = "Página anterior"
	btn_proximo.text = "Voltar ao início" if indice == paginas.size() - 1 else "Próxima página"

	# Vídeo página 5
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

	# Partículas página 3
	particulas.visible = (indice == 3)
	if indice == 3:
		particulas.restart()

	# Acelerômetro página 6
	acelerometro_container.visible = (indice == 6)

	# Áudio
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
# PLAY / PAUSE VÍDEO
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
		audio_player.stop()

# ===============================
# INPUT — ZOOM E ARRASTAR SÓ A PLURALIDADE (PÁGINA 3)
# ===============================
func _input(event):
	if indice != 3:
		return

	# Zoom (pinça) — só o PNG pluralidade
	if event is InputEventMagnifyGesture:
		zoom_atual = clamp(zoom_atual * event.factor, zoom_min, zoom_max)
		pluralidade.scale = Vector2(zoom_atual, zoom_atual)

	# Arrastar — só a pluralidade
	if event is InputEventScreenDrag:
		pluralidade.position += event.relative
