extends RefCounted
class_name WeightedPicker

class Weighted:
	var item
	var weight: float
	var probability: float
	
	@warning_ignore("shadowed_variable")
	func _init(item, weight: float) -> void:
		self.item = item
		self.weight = weight

var _items: Array[Weighted]
var _weight_sum: float = 0

func append(items: Array, weights: Array[float]) -> void:
	var weight: float
	for i: int in range(items.size()):
		weight = weights[i]
		if (weight > 0):
			_weight_sum += weight
			_items.push_back(Weighted.new(items[i], weight))
	_items.sort_custom(func(a: Weighted, b: Weighted): return a.weight > b.weight)
	
	_update_probabilities()

func add(item, weight: float) -> void:
	if (weight <= 0):
		return
	
	if (_items.is_empty()):
		_items.push_back(Weighted.new(item, weight))
		_items[0].probability = 1
	elif (has(item)):
		update(item, weight)
	else:
		_weight_sum += weight
		_items.insert(_bisect(weight), Weighted.new(item, weight))
		
		_update_probabilities()

func update(item, new_weight: float) -> void:
	var old_index: int = _find(item)
	var new_index: int = _bisect(new_weight)
	
	_weight_sum += new_weight - _items[old_index].weight
	
	if (old_index == new_index):
		_items[old_index].weight = new_weight
	else:
		_items.remove_at(old_index)
		_items.insert(new_index, Weighted.new(item, new_weight))
	
	_update_probabilities()

func pick():
	if (_items.is_empty()):
		return
	
	var random: float = randf()
	
	if (_items.size() == 1 or random == 0 or random == 1):
		return _items[0].item
	
	for item: Weighted in _items:
		if (random < item.probability):
			return item.item
		random -= item.probability

func remove(item) -> void:
	var index = _find(item)
	
	if (index == null):
		return
	
	_weight_sum -= _items[index].weight
	_items.remove_at(index)
	
	_update_probabilities()

func has(search_item) -> bool:
	for item: Weighted in _items:
		if (item.item == search_item):
			return true
	return false

func _bisect(weight: float) -> int:
	var left: int = 0
	var right: int = _items.size()
	var mid: int
	
	while left < right:
		@warning_ignore("integer_division")
		mid = (left + right) / 2
		
		if (_items[mid].weight <= weight):
			left = mid + 1
		else:
			right = mid
	return mid

func _find(search_item):
	for i: int in range(_items.size()):
		if (_items[i].item == search_item):
			return i
	return null

func _update_probabilities() -> void:
	for item: Weighted in _items:
		item.probability = item.weight / _weight_sum
