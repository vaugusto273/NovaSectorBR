/datum/action/item_action/adjust
	name = "Ajustar Item"

/datum/action/item_action/adjust/New(Target)
	..()
	var/obj/item/item_target = target
	name = "Ajustar [item_target.name]"
