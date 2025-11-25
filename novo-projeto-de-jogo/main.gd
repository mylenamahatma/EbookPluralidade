extends Control

var paginas = []
var indice = 0

@onready var imagem = $imagem
@onready var btn_anterior = $BtnAnterior
@onready var btn_proximo = $BtnProximo

const COR_PADRAO = Color("#f26423")
const COR_HOVER = Color("#e0541b")
const COR_PRESSIONADO = Color("#c34716")

func _ready():
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

	btn_anterior.connect("pressed", Callable(self, "_voltar"))
	btn_proximo.connect("pressed", Callable(self, "_avancar"))

	_configurar_estilo_botao(btn_anterior)
	_configurar_estilo_botao(btn_proximo)

	btn_anterior.text = "Página anterior"
	btn_proximo.text = "Próxima página"

	atualizar_pagina()


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


func atualizar_pagina():
	imagem.texture = paginas[indice]

	if indice == 0:
		btn_anterior.visible = false
	else:
		btn_anterior.visible = true
		btn_anterior.text = "Página anterior"

	if indice == paginas.size() - 1:
		btn_proximo.text = "Voltar ao início"
	else:
		btn_proximo.text = "Próxima página"


func _avancar():
	if indice < paginas.size() - 1:
		indice += 1
	else:
		indice = 0
	atualizar_pagina()


func _voltar():
	indice = max(0, indice - 1)
	atualizar_pagina()
