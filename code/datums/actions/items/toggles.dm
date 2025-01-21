/datum/action/item_action/toggle

/datum/action/item_action/toggle/New(Target)
	..()
	var/obj/item/item_target = target
	name = "Alternar [item_target.name]"

/datum/action/item_action/toggle_light
	name = "Alternar Luz"

/datum/action/item_action/toggle_computer_light
	name = "Alternar lanterna"

/datum/action/item_action/toggle_hood
	name = "Alternar capuz"

/datum/action/item_action/toggle_firemode
	button_icon = 'modular_nova/master_files/icons/mob/actions/actions_items.dmi' // NOVA EDIT ADDITION
	button_icon_state = "fireselect_no" // NOVA EDIT ADDITION
	name = "Alternar modo de disparo"

/datum/action/item_action/toggle_gunlight
	name = "Alternar lanterna da arma"

/datum/action/item_action/toggle_mode
	name = "Alternar Modo"

/datum/action/item_action/toggle_barrier_spread
	name = "Alternar Barrier Spread"

/datum/action/item_action/toggle_paddles
	name = "Alternar Paddles"

/datum/action/item_action/toggle_mister
	name = "Alternar Mister"

/datum/action/item_action/toggle_helmet_light
	name = "Alternar luz do capacete"

/datum/action/item_action/toggle_welding_screen
	name = "Alternar proteção de solda"

/datum/action/item_action/toggle_spacesuit
	name = "Alternar regulador termal do traje"
	button_icon = 'icons/mob/actions/actions_spacesuit.dmi'
	button_icon_state = "thermal_off"

/datum/action/item_action/toggle_spacesuit/apply_button_icon(atom/movable/screen/movable/action_button/button, force)
	var/obj/item/clothing/suit/space/suit = target
	if(istype(suit))
		button_icon_state = "thermal_[suit.thermal_on ? "on" : "off"]"

	return ..()

/datum/action/item_action/toggle_helmet_flashlight
	name = "Alternar lanterna do capacete"

/datum/action/item_action/toggle_helmet_mode
	name = "Alternar modo do capacete"

/datum/action/item_action/toggle_voice_box
	name = "Alternar Voice Box"

/datum/action/item_action/toggle_human_head
	name = "Alternar Human Head"

/datum/action/item_action/toggle_helmet
	name = "Alternar capacete"

/datum/action/item_action/toggle_seclight
	name = "Alternar lanterna da segurança"

/datum/action/item_action/toggle_jetpack
	name = "Alternar Jetpack"

/datum/action/item_action/jetpack_stabilization
	name = "Alternar Jetpack estabilização"

/datum/action/item_action/jetpack_stabilization/IsAvailable(feedback = FALSE)
	var/obj/item/tank/jetpack/linked_jetpack = target
	if(!istype(linked_jetpack) || !linked_jetpack.on)
		return FALSE
	return ..()

/datum/action/item_action/toggle_hud
	name = "Alternar Implant HUD"
	desc = "Desativa os visuais do implante HUD. Você ainda pode acessar as informações de exame."

/datum/action/item_action/toggle_hud/Trigger(trigger_flags)
	. = ..()
	if(!.)
		return
	var/obj/item/organ/cyberimp/eyes/hud/hud_implant = target
	hud_implant.toggle_hud(owner)

/datum/action/item_action/wheelys
	name = "Alternar Rodas"
	desc = "Faz as rodas dos seus sapatos saírem ou entrarem."
	button_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "wheelys"

/datum/action/item_action/kindle_kicks
	name = "Activate Kindle Kicks"
	desc = "Kick you feet together, activating the lights in your Kindle Kicks."
	button_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "kindleKicks"

/datum/action/item_action/storage_gather_mode
	name = "Switch gathering mode"
	desc = "Switches the gathering mode of a storage object."
	background_icon = 'icons/mob/actions/actions_items.dmi'
	background_icon_state = "storage_gather_switch"
	overlay_icon_state = "bg_tech_border"

/datum/action/item_action/flip
	name = "Flip"

/datum/action/item_action/call_link
	name = "Call MODlink"

// NOVA EDIT ADDITION START
/datum/action/item_action/toggle_hide_face
	name = "Alternar Face Hiding"
// NOVA EDIT ADDITION END

/datum/action/item_action/toggle_wearable_hud
	name = "Alternar Wearable HUD"
	desc = "Toggles your wearable HUD. You can still access examine information while it's off."

/datum/action/item_action/toggle_wearable_hud/Trigger(trigger_flags)
	. = ..()
	if(!.)
		return
	var/obj/item/clothing/glasses/hud/hud_display = target
	hud_display.toggle_hud_display(owner)

/datum/action/item_action/toggle_nv
	name = "Alternar Night Vision"
	var/stored_cutoffs
	var/stored_colour

/datum/action/item_action/toggle_nv/New(obj/item/clothing/glasses/target)
	. = ..()
	target.AddElement(/datum/element/update_icon_updates_onmob)

/datum/action/item_action/toggle_nv/Trigger(trigger_flags)
	if(!istype(target, /obj/item/clothing/glasses))
		return ..()
	var/obj/item/clothing/glasses/goggles = target
	var/mob/holder = goggles.loc
	if(!istype(holder) || holder.get_slot_by_item(goggles) != ITEM_SLOT_EYES)
		holder = null
	if(stored_cutoffs)
		goggles.color_cutoffs = stored_cutoffs
		goggles.flash_protect = FLASH_PROTECTION_SENSITIVE
		stored_cutoffs = null
		if(stored_colour)
			goggles.change_glass_color(stored_colour)
		playsound(goggles, 'sound/items/night_vision_on.ogg', 30, TRUE, -3)
	else
		stored_cutoffs = goggles.color_cutoffs
		stored_colour = goggles.glass_colour_type
		goggles.color_cutoffs = list()
		goggles.flash_protect = FLASH_PROTECTION_NONE
		if(stored_colour)
			goggles.change_glass_color(null)
		playsound(goggles, 'sound/machines/click.ogg', 30, TRUE, -3)
	holder?.update_sight()
	goggles.update_appearance()
