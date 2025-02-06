

/mob/living/carbon/alien/adult/attack_hulk(mob/living/carbon/human/user)
	. = ..()
	if(!.)
		return
	adjustBruteLoss(15)
	var/hitverb = ((client.language == LANGUAGE_ENGLISH ? "hit" : client.language == LANGUAGE_PORTUGUESE ? "acerta" : "Error: code/modules/mob/living/carbon/alien/adult/adult_defense.dm line: 8 "))
	if(mob_size < MOB_SIZE_LARGE)
		safe_throw_at(get_edge_target_turf(src, get_dir(user, src)), 2, 1, user)
		hitverb = ((client.language == LANGUAGE_ENGLISH ? "slam" : client.language == LANGUAGE_PORTUGUESE ? "esmaga" : "Error: code/modules/mob/living/carbon/alien/adult/adult_defense.dm line: 11 "))
	playsound(loc, SFX_PUNCH, 25, TRUE, -1)
	visible_message(span_danger((client.language == LANGUAGE_ENGLISH ? "[user] [hitverb]s [src]!" : client.language == LANGUAGE_PORTUGUESE ? "[user] [hitverb]!" : "Error: code/modules/mob/living/carbon/alien/adult/adult_defense.dm line: 13 ")), \
					span_userdanger((client.language == LANGUAGE_ENGLISH ? "[user] [hitverb]s you!" : client.language == LANGUAGE_PORTUGUESE ? "[user] [hitverb] você!" : "Error: code/modules/mob/living/carbon/alien/adult/adult_defense.dm line: 14 ")), span_hear((client.language == LANGUAGE_ENGLISH ? ("You hear a sickening sound of flesh hitting flesh!") : client.language == LANGUAGE_PORTUGUESE ? "Você ouve um som repugnante de carne se chocando!" : "Error: code/modules/mob/living/carbon/alien/adult/adult_defense.dm line: 14 ")), COMBAT_MESSAGE_RANGE, user)
	to_chat(user, span_danger((client.language == LANGUAGE_ENGLISH ? "You [hitverb] [src]!" : client.language == LANGUAGE_PORTUGUESE ? "Você [hitverb] [src]!" : "Error: code/modules/mob/living/carbon/alien/adult/adult_defense.dm line: 15 ")))

/mob/living/carbon/alien/adult/attack_hand(mob/living/carbon/human/user, list/modifiers)
	. = ..()
	if(.)
		return TRUE
	var/damage = rand(1, 9)
	if (prob(90))
		playsound(loc, SFX_PUNCH, 25, TRUE, -1)
		visible_message(span_danger((client.language == LANGUAGE_ENGLISH ? ("[user] punches [src]!") : client.language == LANGUAGE_PORTUGUESE ? "[user] soca [src]!" : "Error: code/modules/mob/living/carbon/alien/adult/adult_defense.dm line: 24 ")), \
						span_userdanger((client.language == LANGUAGE_ENGLISH ? ("[user] punches you!") : client.language == LANGUAGE_PORTUGUESE ? "[user] soca você!" : "Error: code/modules/mob/living/carbon/alien/adult/adult_defense.dm line: 25 ")), span_hear((client.language == LANGUAGE_ENGLISH ? ("You hear a sickening sound of flesh hitting flesh!") : client.language == LANGUAGE_PORTUGUESE ? "Você ouve um som repugnante de carne se chocando!" : "Error: code/modules/mob/living/carbon/alien/adult/adult_defense.dm line: 25 ")), COMBAT_MESSAGE_RANGE, user)
		to_chat(user, span_notice(client.language == LANGUAGE_ENGLISH ? "You punch [src]!" : client.language == LANGUAGE_PORTUGUESE ? "Você soca [src]!" : client.language == LANGUAGE_ENGLISH ? "You punch [src]!" : "Error: code/modules/mob/living/carbon/alien/adult/adult_defense.dm line: 26 "))
		if ((stat != DEAD) && (damage > 9 || prob(5)))//Regular humans have a very small chance of knocking an alien down.
			Unconscious(40)
			visible_message(span_danger(client.language == LANGUAGE_ENGLISH ? ("[user] knocks [src] down!") : client.language == LANGUAGE_PORTUGUESE ? "[user] derruba [src] !" : client.language == LANGUAGE_ENGLISH ? ("[user] knocks [src] down!") : "Error: code/modules/mob/living/carbon/alien/adult/adult_defense.dm line: 29"), \
							span_userdanger((client.language == LANGUAGE_ENGLISH ? ("[user] knocks you down!") : client.language == LANGUAGE_PORTUGUESE ? "[user] derruba você !" : "Error: code/modules/mob/living/carbon/alien/adult/adult_defense.dm line: 30 ")), span_hear((client.language == LANGUAGE_ENGLISH ? ("You hear a sickening sound of flesh hitting flesh!") : client.language == LANGUAGE_PORTUGUESE ? "Você ouve um som nauseante de carne se chocando!" : "Error: code/modules/mob/living/carbon/alien/adult/adult_defense.dm line: 30 ")), null, user)
			to_chat(user, span_danger((client.language == LANGUAGE_ENGLISH ? "You knock [src] down!" : client.language == LANGUAGE_PORTUGUESE ? "Você derruba [src]!" : "Error: code/modules/mob/living/carbon/alien/adult/adult_defense.dm line: 31 ")))
		var/obj/item/bodypart/affecting = get_bodypart(get_random_valid_zone(user.zone_selected))
		apply_damage(damage, BRUTE, affecting)
		log_combat(user, src, "attacked")
	else
		playsound(loc, 'sound/items/weapons/punchmiss.ogg', 25, TRUE, -1)
		visible_message(span_danger((client.language == LANGUAGE_ENGLISH ? ("[user]'s punch misses [src]!") : client.language == LANGUAGE_PORTUGUESE ? "O soco de [user] erra [src]!" : "Error: code/modules/mob/living/carbon/alien/adult/adult_defense.dm line: 37 ")), \
						span_danger((client.language == LANGUAGE_ENGLISH ? ("You avoid [user]'s punch!") : client.language == LANGUAGE_PORTUGUESE ? "Você desvia do soco de [user]!" : "Error: code/modules/mob/living/carbon/alien/adult/adult_defense.dm line: 38 ")), span_hear((client.language == LANGUAGE_ENGLISH ? ("You hear a swoosh!") : client.language == LANGUAGE_PORTUGUESE ? "Você ouve um swoosh!" : "Error: code/modules/mob/living/carbon/alien/adult/adult_defense.dm line: 38 ")), COMBAT_MESSAGE_RANGE, user)
		to_chat(user, span_warning((client.language == LANGUAGE_ENGLISH ? "Your punch misses [src]!" : client.language == LANGUAGE_PORTUGUESE ? "Seu soco erra [src]!" : "Error: code/modules/mob/living/carbon/alien/adult/adult_defense.dm line: 39 ")))

/mob/living/carbon/alien/adult/do_attack_animation(atom/A, visual_effect_icon, obj/item/used_item, no_effect)
	if(!no_effect && !visual_effect_icon)
		visual_effect_icon = ATTACK_EFFECT_CLAW
	..()
