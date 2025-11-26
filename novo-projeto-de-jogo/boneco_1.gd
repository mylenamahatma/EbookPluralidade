extends Sprite2D

var dragging := false
var nuvens := []
var destino_x := 0
var limite_esq := 0
var limite_dir := 0

func _ready():
	# Pegar todos os bonecos do grupo "nuvens"
	nuvens = get_tree().get_nodes_in_group("nuvens")

	# Pegar a imagem de fundo atual do Main
	var main = get_tree().get_current_scene()
	if main.has_node("Imagem"):
		var imagem = main.get_node("Imagem") as TextureRect
		limite_esq = imagem.global_position.x
		limite_dir = imagem.global_position.x + imagem.size.x  # usar size.x em vez de rect_size.x

		# Destino final: esquerda ou direita (1/3 ou 2/3)
		if global_position.x < (limite_esq + limite_dir) / 2:
			destino_x = limite_esq + imagem.size.x / 3
		else:
			destino_x = limite_esq + imagem.size.x * 2 / 3

func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed and get_rect().has_point(to_local(event.position)):
			dragging = true
		elif not event.pressed:
			dragging = false
			# Ao soltar, mover para a posição final (1/3 ou 2/3)
			global_position.x = destino_x

	elif event is InputEventScreenDrag and dragging:
		# Arrastar horizontalmente dentro da imagem
		var nova_x = clamp(event.position.x, limite_esq, limite_dir)

		# Evitar colisão com outros bonecos
		var pode_mover = true
		var meu_rect = Rect2(Vector2(nova_x - get_rect().size.x / 2, global_position.y - get_rect().size.y / 2), get_rect().size)
		for n in nuvens:
			if n == self:
				continue
			var rect_outro = Rect2(Vector2(n.global_position.x - n.get_rect().size.x / 2, n.global_position.y - n.get_rect().size.y / 2), n.get_rect().size)
			if meu_rect.intersects(rect_outro):
				pode_mover = false
				break

		if pode_mover:
			global_position.x = nova_x
