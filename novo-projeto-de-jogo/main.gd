extends Control  

# ===============================
# VARIÁVEIS GLOBAIS
# ===============================
var paginas = []
var audios = []
var indice = 0
var som_ligado = true
var video_tocando = false

# ZOOM (somente página 3 e 4)
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

# Partículas página 3 e 4
@onready var particulas = $Particulas3

# Pluralidade (zoom página 3 e 4)
@onready var pluralidade = $Pluralidade

# Container acelerômetro página 6
@onready var acelerometro_container = $AcelerometroContainer

# Container página 1
@onready var pagina1_container = $Pagina1Container

# ===============================
# BONECOS DANÇANDO (PÁGINA 2)
# ===============================
@onready var menino = $Menino
@onready var menina = $Menina
@onready var foliao = $Foliao

# ===============================
# INSTRUMENTOS
# ===============================
@onready var btn_pandeiro = $BtnPandeiro
@onready var btn_tambor = $BtnTambor
@onready var btn_ganza = $BtnGanza

var audio_pandeiro = preload("res://assets/audios/pandeiro.ogg")
var audio_tambor = preload("res://assets/audios/tambor.ogg")
var audio_ganza = preload("res://assets/audios/ganza.ogg")
var audio_instrumento = AudioStreamPlayer.new()

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

	add_child(audio_instrumento)

	setup_boneco(menino, ["res://assets/images/menino1.png","res://assets/images/menino2.png","res://assets/images/menino3.png"])
	setup_boneco(menina, ["res://assets/images/menina1.png","res://assets/images/menina2.png","res://assets/images/menina3.png"])
	setup_boneco(foliao, ["res://assets/images/foliao1.png","res://assets/images/foliao2.png","res://assets/images/foliao3.png"])

	btn_pandeiro.pressed.connect(_toca_pandeiro)
	btn_tambor.pressed.connect(_toca_tambor)
	btn_ganza.pressed.connect(_toca_ganza)

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
	btn_video_toggle.visible = false
	video_tocando = false

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

	pagina1_container.visible = (indice == 1)

	pluralidade.visible = (indice == 3 or indice == 4)

	if indice == 3 or indice == 4:
		zoom_atual = 1.0
		pluralidade.scale = Vector2(1, 1)
		# abaixar a pluralidade para não cobrir o botão de áudio
		pluralidade.position = Vector2(0, 200)  # ajuste Y conforme necessário

	btn_anterior.visible = indice != 0
	btn_anterior.text = "Página anterior"
	btn_proximo.text = "Voltar ao início" if indice == paginas.size() - 1 else "Próxima página"

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

	particulas.visible = (indice == 3 or indice == 4)
	if indice == 3 or indice == 4:
		particulas.restart()

	acelerometro_container.visible = (indice == 6)

	# 🔥 ÁUDIO ON/OFF
	if som_ligado and not video_tocando:
		audio_player.stream = audios[indice]
		audio_player.play()
	else:
		audio_player.stop()

	var pagina2_ativa = (indice == 2)
	menino.visible = pagina2_ativa
	menina.visible = pagina2_ativa
	foliao.visible = pagina2_ativa
	btn_pandeiro.visible = pagina2_ativa
	btn_tambor.visible = pagina2_ativa
	btn_ganza.visible = pagina2_ativa

	if pagina2_ativa:
		menino.play("danca")
		menina.play("danca")
		foliao.play("danca")

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
# PLAY / PAUSE DO VÍDEO
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
# INPUT — ZOOM E ARRASTAR (PÁG 3 e 4)
# ===============================
func _input(event):
	if indice != 3 and indice != 4:
		return

	if event is InputEventMagnifyGesture:
		zoom_atual = clamp(zoom_atual * event.factor, zoom_min, zoom_max)
		pluralidade.scale = Vector2(zoom_atual, zoom_atual)

	if event is InputEventScreenDrag:
		pluralidade.position += event.relative

# ===============================
# BONECOS E INSTRUMENTOS
# ===============================
func setup_boneco(boneco: AnimatedSprite2D, imagens):
	var frames = SpriteFrames.new()
	frames.add_animation("danca")
	for img in imagens:
		frames.add_frame("danca", load(img))
	frames.set_animation_speed("danca", 5.0)
	boneco.frames = frames
	boneco.animation = "danca"
	boneco.play()

func _toca_pandeiro():
	audio_instrumento.stream = audio_pandeiro
	audio_instrumento.play()

func _toca_tambor():
	audio_instrumento.stream = audio_tambor
	audio_instrumento.play()

func _toca_ganza():
	audio_instrumento.stream = audio_ganza
	audio_instrumento.play()
