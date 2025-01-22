/datum/wound_pregen_data/loss
	abstract = FALSE

	wound_path_to_generate = /datum/wound/loss
	required_limb_biostate = NONE
	require_any_biostate = TRUE

	required_wounding_types = list(WOUND_ALL)

	wound_series = WOUND_SERIES_LOSS_BASIC

	threshold_minimum = WOUND_DISMEMBER_OUTRIGHT_THRESH // not actually used since dismembering is handled differently, but may as well assign it since we got it

/datum/wound/loss
	name = "Ferida de desmembramento"
	desc = "ai porra!!"

	sound_effect = 'sound/effects/dismember.ogg'
	severity = WOUND_SEVERITY_LOSS
	status_effect_type = null
	scar_keyword = "dismember"
	wound_flags = null
	already_scarred = TRUE // We manually assign scars for dismembers through endround missing limbs and aheals

	/// The wounding_type of the attack that caused us. Used to generate the description of our scar. Currently unused, but primarily exists in case non-biological wounds are added.
	var/loss_wounding_type

/// Our special proc for our special dismembering, the wounding type only matters for what text we have
/datum/wound/loss/proc/apply_dismember(obj/item/bodypart/dismembered_part, wounding_type = WOUND_SLASH, outright = FALSE, attack_direction)
	if(!istype(dismembered_part) || !dismembered_part.owner || !(dismembered_part.body_zone in get_viable_zones()) || isalien(dismembered_part.owner) || !dismembered_part.can_dismember())
		qdel(src)
		return

	set_victim(dismembered_part.owner)
	var/self_msg

	if(dismembered_part.body_zone == BODY_ZONE_CHEST)
		occur_text = "se abre, fazendo com que os órgãos internos de [victim.p_their()] se derramem!"
		self_msg = "se abre, fazendo com que seus órgãos internos se derramem!"
	else
		occur_text = dismembered_part.get_dismember_message(wounding_type, outright)

	var/msg = span_bolddanger("[victim]'s [dismembered_part.plaintext_zone] [occur_text] reporte para tradução loss.dm")

	victim.visible_message(msg, span_userdanger("Seu [dismembered_part.plaintext_zone] [self_msg ? self_msg : occur_text] reporte para tradução ou correção loss.dm"))

	loss_wounding_type = wounding_type

	set_limb(dismembered_part)
	second_wind()
	log_wound(victim, src)
	if(dismembered_part.can_bleed() && wounding_type != WOUND_BURN && victim.blood_volume)
		victim.spray_blood(attack_direction, severity)
	dismembered_part.dismember(wounding_type == WOUND_BURN ? BURN : BRUTE, wounding_type = wounding_type)
	qdel(src)
	return TRUE

/obj/item/bodypart/proc/get_dismember_message(wounding_type, outright)
	var/occur_text

	if(outright)
		switch(wounding_type)
			if(WOUND_BLUNT)
				occur_text = "é completamente esmagado até virar uma polpa grotesca, separando-o completamente!"
			if(WOUND_SLASH)
				occur_text = "é completamente cortado, separando-o completamente!"
			if(WOUND_PIERCE)
				occur_text = "é completamente estourado, separando-o completamente!"
			if(WOUND_BURN)
				occur_text = "é completamente incinerado, virando pó!"
	else
		var/bone_text = get_internal_description()
		var/tissue_text = get_external_description()

		switch(wounding_type)
			if(WOUND_BLUNT)
				occur_text = "é partido pelo ultimo [bone_text] segurando tudo junto, cortando-o completamente!"
			if(WOUND_SLASH)
				occur_text = "é cortado no último [tissue_text] segurando tudo junto, cortando-o completamente!"
			if(WOUND_PIERCE)
				occur_text = "é perfurado através do último [tissue_text] segurando tudo junto, cortando-o completamente!"
			if(WOUND_BURN)
				occur_text = "é completamente incinerado, caindo em pó!"

	return occur_text
