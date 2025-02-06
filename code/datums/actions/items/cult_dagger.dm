
/datum/action/item_action/cult_dagger
	name = "Desenhar runa de sangue"
	desc = "Use a adaga ritualística para criar uma poderosa runa de sangue."
	button_icon = 'icons/mob/actions/actions_cult.dmi'
	button_icon_state = "draw"
	buttontooltipstyle = "cult"
	background_icon_state = "bg_demon"
	overlay_icon_state = "bg_demon_border"

	default_button_position = "6:157,4:-2"

/datum/action/item_action/cult_dagger/Grant(mob/grant_to)
	if(!IS_CULTIST(grant_to))
		return

	return ..()

/datum/action/item_action/cult_dagger/Trigger(trigger_flags)
	if(target in owner.held_items)
		var/obj/item/target_item = target
		target_item.attack_self(owner)
		return
	var/obj/item/target_item = target
	if(owner.can_equip(target_item, ITEM_SLOT_HANDS))
		owner.temporarilyRemoveItemFromInventory(target_item)
		owner.put_in_hands(target_item)
		target_item.attack_self(owner)
		return

	if(!isliving(owner))
		to_chat(owner, span_warning("Você não possui a força vital necessária para esta ação."))
		return

	var/mob/living/living_owner = owner
	if (living_owner.usable_hands <= 0)
		to_chat(living_owner, span_warning("Você não tem mãos utilizáveis!"))
	else
		to_chat(living_owner, span_warning("Suas mãos estão ocupadas!"))
