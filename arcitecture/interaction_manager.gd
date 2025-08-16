class_name InteractionManager extends RefCounted

static var _interactions : Array[Interactive] = []
static var _completed : Array[Interactive] = []

static var _domain_helper := 0.0
static var _domain_tween : Tween

static func add_interaction(thing: Interactive) -> void:
	if _interactions.has(thing):
		return
	_interactions.append(thing)
	update_percentage()

static func interaction_complete(thing: Interactive) -> void:
	if _completed.has(thing):
		return
	_completed.append(thing)
	update_percentage()

static func update_percentage() -> void:
	if _interactions.is_empty():
		return
	var value =   _completed.size() / float(_interactions.size())
	if is_equal_approx(value, _domain_helper):
		return
	if _domain_tween:
		if _domain_tween.is_valid():
			_domain_tween.kill()
	_domain_tween = World.get_world().create_tween()
	_domain_tween.set_trans(Tween.TRANS_LINEAR)
	_domain_tween.tween_method(set_domain, _domain_helper, value, .5)
	prints(_completed.size(),  float(_interactions.size()),  value)


static func set_domain(value: float) -> void:
	_domain_helper = value
	AmbientColor.update_domain(_domain_helper)
	PointLight2D_Extended.update_domain(_domain_helper)
