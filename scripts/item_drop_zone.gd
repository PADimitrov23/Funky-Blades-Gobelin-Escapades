class_name ItemDropZone
extends Marker2D

var item: DraggableItem = null

# Call this whenever you change an item's drop zone.
func register_item(new_item: DraggableItem):
	item = new_item
	item.rest_zone = self


# Always call this on the old drop zone when changing the drop zone
func deregister_item() -> ItemDropZone:
	item = null
	return self


# Swaps this drop zone's item with the passed one and
# gives this zone's item to `new_item`'s drop zone.
func swap(new_item: DraggableItem, other_drop_zone: ItemDropZone):
	other_drop_zone.register_item(item)
	register_item(new_item)
