/datum/action/item_action/organ_action
	name = "Ação de Orgão"
	check_flags = AB_CHECK_CONSCIOUS

/datum/action/item_action/organ_action/IsAvailable(feedback = FALSE)
	var/obj/item/organ/attached_organ = target
	if(!attached_organ.owner)
		return FALSE
	return ..()

/datum/action/item_action/organ_action/toggle
	name = "Alternar Orgão"

/datum/action/item_action/organ_action/toggle/New(Target)
	..()
	var/obj/item/organ/organ_target = target
	name = "Alternar [organ_target.name]"

/datum/action/item_action/organ_action/use
	name = "Usar Orgão"

/datum/action/item_action/organ_action/use/New(Target)
	..()
	var/obj/item/organ/organ_target = target
	name = "Usar [organ_target.name]"
