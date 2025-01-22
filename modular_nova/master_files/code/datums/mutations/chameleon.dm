// toggleable chameleon skin
/datum/mutation/human/chameleon
	power_path = /datum/action/cooldown/spell/chameleon_skin_activate

/datum/action/cooldown/spell/chameleon_skin_activate
	name = "Activate Chameleon Skin"
	desc = "Os cromatóforos em sua pele se ajustam ao seu entorno, desde que você permaneça imóvel."
	spell_requirements = NONE
	button_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	button_icon_state = "ninja_cloak"

/datum/action/cooldown/spell/chameleon_skin_activate/cast(list/targets, mob/user = usr)
	. = ..()

	if(HAS_TRAIT(user,TRAIT_CHAMELEON_SKIN))
		chameleon_skin_deactivate(user)
		return

	ADD_TRAIT(user, TRAIT_CHAMELEON_SKIN, GENETIC_MUTATION)
	to_chat(user, "A pigmentação da sua pele muda e começa a assumir as cores do seu entorno.")

/datum/action/cooldown/spell/chameleon_skin_activate/proc/chameleon_skin_deactivate(mob/user = usr)
	if(!HAS_TRAIT_FROM(user,TRAIT_CHAMELEON_SKIN, GENETIC_MUTATION))
		return

	REMOVE_TRAIT(user, TRAIT_CHAMELEON_SKIN, GENETIC_MUTATION)
	user.alpha = 255
	to_chat(user, text("Sua pele muda enquanto volta a suas cores originais."))
