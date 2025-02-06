/*
	Blunt/Bone wounds
*/
// TODO: well, a lot really, but i'd kill to get overlays and a bonebreaking effect like Blitz: The League, similar to electric shock skeletons

/datum/wound_pregen_data/bone
	abstract = TRUE
	required_limb_biostate = BIO_BONE

	required_wounding_types = list(WOUND_BLUNT)

	wound_series = WOUND_SERIES_BONE_BLUNT_BASIC

/datum/wound/blunt/bone
	name = "Blunt (Bone) Wound"
	wound_flags = (ACCEPTS_GAUZE | SPLINT_OVERLAY) // NOVA EDIT: MEDICAL -- Makes bone wounds have a splint overlay

	default_scar_file = BONE_SCAR_FILE

	/// Have we been bone gel'd?
	var/gelled
	/// Have we been taped?
	var/taped
	/// If we did the gel + surgical tape healing method for fractures, how many ticks does it take to heal by default
	var/regen_ticks_needed
	/// Our current counter for gel + surgical tape regeneration
	var/regen_ticks_current
	/// If we suffer severe head booboos, we can get brain traumas tied to them
	var/datum/brain_trauma/active_trauma
	/// What brain trauma group, if any, we can draw from for head wounds
	var/brain_trauma_group
	/// If we deal brain traumas, when is the next one due?
	var/next_trauma_cycle
	/// How long do we wait +/- 20% for the next trauma?
	var/trauma_cycle_cooldown
	/// If this is a chest wound and this is set, we have this chance to cough up blood when hit in the chest
	var/internal_bleeding_chance = 0

/*
	Overwriting of base procs
*/
/datum/wound/blunt/bone/wound_injury(datum/wound/old_wound = null, attack_direction = null)
	// hook into gaining/losing gauze so crit bone wounds can re-enable/disable depending if they're slung or not
	if(limb.body_zone == BODY_ZONE_HEAD && brain_trauma_group)
		processes = TRUE
		active_trauma = victim.gain_trauma_type(brain_trauma_group, TRAUMA_RESILIENCE_WOUND)
		next_trauma_cycle = world.time + (rand(100-WOUND_BONE_HEAD_TIME_VARIANCE, 100+WOUND_BONE_HEAD_TIME_VARIANCE) * 0.01 * trauma_cycle_cooldown)

	if(limb.held_index && victim.get_item_for_held_index(limb.held_index) && (disabling || prob(30 * severity)))
		var/obj/item/I = victim.get_item_for_held_index(limb.held_index)
		if(istype(I, /obj/item/offhand))
			I = victim.get_inactive_held_item()

		if(I && victim.dropItemToGround(I))
			victim.visible_message(span_danger("[victim] drops [I] in shock!"), span_warning("<b>The force on your [limb.plaintext_zone] causes you to drop [I]!</b>"), vision_distance=COMBAT_MESSAGE_RANGE)

	update_inefficiencies()
	return ..()

/datum/wound/blunt/bone/set_victim(new_victim)

	if (victim)
		UnregisterSignal(victim, list(COMSIG_LIVING_UNARMED_ATTACK, COMSIG_MOB_FIRED_GUN))
	if (new_victim)
		RegisterSignal(new_victim, COMSIG_LIVING_UNARMED_ATTACK, PROC_REF(attack_with_hurt_hand))
		RegisterSignal(new_victim, COMSIG_MOB_FIRED_GUN, PROC_REF(firing_with_messed_up_hand))

	return ..()

/datum/wound/blunt/bone/remove_wound(ignore_limb, replaced)
	limp_slowdown = 0
	limp_chance = 0
	QDEL_NULL(active_trauma)
	return ..()

/datum/wound/blunt/bone/handle_process(seconds_per_tick, times_fired)
	. = ..()

	if (!victim || HAS_TRAIT(victim, TRAIT_STASIS))
		return

	if(limb.body_zone == BODY_ZONE_HEAD && brain_trauma_group && world.time > next_trauma_cycle)
		if(active_trauma)
			QDEL_NULL(active_trauma)
		else
			active_trauma = victim.gain_trauma_type(brain_trauma_group, TRAUMA_RESILIENCE_WOUND)
		next_trauma_cycle = world.time + (rand(100-WOUND_BONE_HEAD_TIME_VARIANCE, 100+WOUND_BONE_HEAD_TIME_VARIANCE) * 0.01 * trauma_cycle_cooldown)

	var/is_bone_limb = ((limb.biological_state & BIO_BONE) && !(limb.biological_state & BIO_FLESH))
	if(!gelled || (!taped && !is_bone_limb))
		return

	regen_ticks_current++
	if(victim.body_position == LYING_DOWN)
		if(SPT_PROB(30, seconds_per_tick))
			regen_ticks_current += 1
		if(victim.IsSleeping() && SPT_PROB(30, seconds_per_tick))
			regen_ticks_current += 1

	if(!is_bone_limb && SPT_PROB(severity * 1.5, seconds_per_tick))
		victim.take_bodypart_damage(rand(1, severity * 2), wound_bonus=CANT_WOUND)
		victim.adjustStaminaLoss(rand(2, severity * 2.5))
		if(prob(33))
			to_chat(victim, span_danger("Você sente uma dor aguda no corpo enquanto seus ossos estão se reformando!"))

	if(regen_ticks_current > regen_ticks_needed)
		if(!victim || !limb)
			qdel(src)
			return
		to_chat(victim, span_green("O seu [limb.plaintext_zone] se recuperou de seu [name]!"))
		remove_wound()

/// If we're a human who's punching something with a broken arm, we might hurt ourselves doing so
/datum/wound/blunt/bone/proc/attack_with_hurt_hand(mob/M, atom/target, proximity)
	SIGNAL_HANDLER

	if(victim.get_active_hand() != limb || !proximity || !victim.combat_mode || !ismob(target) || severity <= WOUND_SEVERITY_MODERATE)
		return NONE

	// With a severe or critical wound, you have a 15% or 30% chance to proc pain on hit
	if(prob((severity - 1) * 15))
		// And you have a 70% or 50% chance to actually land the blow, respectively
		if(HAS_TRAIT(victim, TRAIT_ANALGESIA) || prob(70 - 20 * (severity - 1)))
			if(!HAS_TRAIT(victim, TRAIT_ANALGESIA))
				to_chat(victim, span_danger("A fratura em seu [limb.plaintext_zone] dispara com dor enquanto voce ataca [target]!"))
			victim.apply_damage(rand(1, 5), BRUTE, limb, wound_bonus = CANT_WOUND, wound_clothing = FALSE)
		else
			victim.visible_message(span_danger("[victim] acerta de maneira fraca [target] com [victim.p_their()] quebrado [limb.plaintext_zone], sentindo dor!"), \
			span_userdanger("Você falha em acertar [target] pois a fratura em seu [limb.plaintext_zone] por uma forte dor!"), vision_distance=COMBAT_MESSAGE_RANGE)
			INVOKE_ASYNC(victim, TYPE_PROC_REF(/mob, emote), "scream")
			victim.Stun(0.5 SECONDS)
			victim.apply_damage(rand(3, 7), BRUTE, limb, wound_bonus = CANT_WOUND, wound_clothing = FALSE)
			return COMPONENT_CANCEL_ATTACK_CHAIN

	return NONE

/// If we're a human who's firing a gun with a broken arm, we might hurt ourselves doing so
/datum/wound/blunt/bone/proc/firing_with_messed_up_hand(datum/source, obj/item/gun/gun, atom/firing_at, params, zone, bonus_spread_values)
	SIGNAL_HANDLER

	switch(limb.body_zone)
		if(BODY_ZONE_L_ARM)
			// Heavy guns use both hands so they will always get a penalty
			// (Yes, this means having two broken arms will make heavy weapons SOOO much worse)
			// Otherwise make sure THIS hand is firing THIS gun
			if(gun.weapon_weight <= WEAPON_MEDIUM && !IS_LEFT_INDEX(victim.get_held_index_of_item(gun)))
				return

		if(BODY_ZONE_R_ARM)
			// Ditto but for right arm
			if(gun.weapon_weight <= WEAPON_MEDIUM && !IS_RIGHT_INDEX(victim.get_held_index_of_item(gun)))
				return

		else
			// This is not arm wound, so we don't care
			return

	if(gun.recoil > 0 && severity >= WOUND_SEVERITY_SEVERE && prob(25 * (severity - 1)))
		if(!HAS_TRAIT(victim, TRAIT_ANALGESIA))
			to_chat(victim, span_danger("A fratura em seu [limb.plaintext_zone] explode de dor quando [gun] retrocede!"))
		victim.apply_damage(rand(1, 3) * (severity - 1) * gun.weapon_weight, BRUTE, limb, wound_bonus = CANT_WOUND, wound_clothing = FALSE)

	if(!HAS_TRAIT(victim, TRAIT_ANALGESIA))
		bonus_spread_values[MAX_BONUS_SPREAD_INDEX] += (15 * severity * (limb.current_gauze?.splint_factor || 1))

/datum/wound/blunt/bone/receive_damage(wounding_type, wounding_dmg, wound_bonus)
	if(!victim || wounding_dmg < WOUND_MINIMUM_DAMAGE)
		return
	if(ishuman(victim))
		var/mob/living/carbon/human/human_victim = victim
		if(HAS_TRAIT(human_victim, TRAIT_NOBLOOD))
			return

	if(limb.body_zone == BODY_ZONE_CHEST && victim.blood_volume && prob(internal_bleeding_chance + wounding_dmg))
		var/blood_bled = rand(1, wounding_dmg * (severity == WOUND_SEVERITY_CRITICAL ? 2 : 1.5)) // 12 brute toolbox can cause up to 18/24 bleeding with a severe/critical chest wound
		switch(blood_bled)
			if(1 to 6)
				victim.bleed(blood_bled, TRUE)
			if(7 to 13)
				victim.visible_message(
					span_smalldanger("Um fino fio de sangue escorre da boca de [victim] devido ao golpe no peito de [victim.p_their()]."),
					span_danger("Você tosse um pouco de sangue por conta do golpe em seu torso."),
					vision_distance = COMBAT_MESSAGE_RANGE,
				)
				victim.bleed(blood_bled, TRUE)
			if(14 to 19)
				victim.visible_message(
					span_smalldanger("Sangue jorra da boca de [victim] devido ao golpe no peito de [victim.p_their()]!"),
					span_danger("Você cospe um fio de sangue devido ao golpe no seu peito!"),
					vision_distance = COMBAT_MESSAGE_RANGE,
				)
				victim.create_splatter(victim.dir)
				victim.bleed(blood_bled)
			if(20 to INFINITY)
				victim.visible_message(
					span_danger("Sangue espirra da boca de [victim] devido ao golpe no peito de [victim.p_their()]!"),
					span_bolddanger("Você engasga com um jato de sangue devido ao golpe no seu peito!"),
					vision_distance = COMBAT_MESSAGE_RANGE,
				)
				victim.bleed(blood_bled)
				victim.create_splatter(victim.dir)
				victim.add_splatter_floor(get_step(victim.loc, victim.dir))

/datum/wound/blunt/bone/modify_desc_before_span(desc)
	. = ..()

	if (!limb.current_gauze)
		if(taped)
			. += ", [span_notice("e parece estar se reformando sob uma fita cirúrgica!")]"
		else if(gelled)
			. += ", [span_notice("com partículas efervescentes de gel ósseo azul faiscando no osso!")]"

/datum/wound/blunt/get_limb_examine_description()
	return span_warning("Os ossos deste membro parecem estar gravemente rachados.")

/*
	New common procs for /datum/wound/blunt/bone/
*/

/datum/wound/blunt/bone/get_scar_file(obj/item/bodypart/scarred_limb, add_to_scars)
	if (scarred_limb.biological_state & BIO_BONE && (!(scarred_limb.biological_state & BIO_FLESH))) // only bone
		return BONE_SCAR_FILE
	else if (scarred_limb.biological_state & BIO_FLESH && (!(scarred_limb.biological_state & BIO_BONE)))
		return FLESH_SCAR_FILE

	return ..()

/// Joint Dislocation (Moderate Blunt)
/datum/wound/blunt/bone/moderate
	name = "Deslocação de junta"
	desc = "O membro do paciente foi deslocado da articulação, causando dor e redução da função motora."
	treat_text = "Aplique o Redutor de Ossos no membro afetado. \
A realocação manual por meio de uma pegada agressiva e um abraço apertado no membro afetado também pode ser suficiente."
	treat_text_short = "Aplique o Redutor de Ossos ou realoque manualmente o membro."
	examine_desc = "está desajeitadamente deslocado de seu lugar"
	occur_text = "se desloca violentamente e fica fora de lugar"
	severity = WOUND_SEVERITY_MODERATE
	interaction_efficiency_penalty = 1.3
	limp_slowdown = 3
	limp_chance = 50
	threshold_penalty = 15
	treatable_tools = list(TOOL_BONESET)
	status_effect_type = /datum/status_effect/wound/blunt/bone/moderate
	scar_keyword = "dislocate"

	simple_desc = "O osso do paciente foi deslocado, causando coxeo ou redução da destreza."
	simple_treat_text = "<b>Enfaixar</b> a ferida reduzirá seu impacto até que seja tratada com um redutor de ossos. Normalmente, é tratada ao agarrar agressivamente a pessoa e, de forma útil, colocar o membro de volta no lugar, embora haja espaço para maus-tratos ao fazer isso."
	homemade_treat_text = "Além de enfaixar e realinhar, <b>redutores de ossos</b> podem ser impressos em tornos e utilizados em si mesmo ao custo de grande dor. Como último recurso, <b>esmagar</b> o paciente com um <b>ferrolho</b> às vezes tem sido observado como uma forma de corrigir o membro deslocado."

/datum/wound_pregen_data/bone/dislocate
	abstract = FALSE

	wound_path_to_generate = /datum/wound/blunt/bone/moderate

	required_limb_biostate = BIO_JOINTED

	threshold_minimum = 35

/datum/wound/blunt/bone/moderate/Destroy()
	if(victim)
		UnregisterSignal(victim, COMSIG_LIVING_DOORCRUSHED)
	return ..()

/datum/wound/blunt/bone/moderate/set_victim(new_victim)

	if (victim)
		UnregisterSignal(victim, COMSIG_LIVING_DOORCRUSHED)
	if (new_victim)
		RegisterSignal(new_victim, COMSIG_LIVING_DOORCRUSHED, PROC_REF(door_crush))

	return ..()

/// Getting smushed in an airlock/firelock is a last-ditch attempt to try relocating your limb
/datum/wound/blunt/bone/moderate/proc/door_crush()
	SIGNAL_HANDLER
	if(prob(40))
		victim.visible_message(span_danger("[victim] tem o seu [limb.plaintext_zone] deslocado volta para o lugar!"), span_userdanger("Seu [limb.plaintext_zone] deslocado volta para o lugar! Ai!"))
		remove_wound()

/datum/wound/blunt/bone/moderate/try_handling(mob/living/user)
	if(user.usable_hands <= 0 || user.pulling != victim)
		return FALSE
	if(!isnull(user.hud_used?.zone_select) && user.zone_selected != limb.body_zone)
		return FALSE

	if(user.grab_state == GRAB_PASSIVE)
		to_chat(user, span_warning("Você deve estar segurando [victim] de forma agressiva para manipular [victim.p_their()] [LOWER_TEXT(name)]!"))
		return TRUE

	if(user.grab_state >= GRAB_AGGRESSIVE)
		user.visible_message(span_danger("[user] começa a torcer e forçar o [limb.plaintext_zone] deslocado de [victim]!"), span_notice("Você começa a torcer e forçar o [limb.plaintext_zone] deslocado de [victim]..."), ignored_mobs=victim)
		to_chat(victim, span_userdanger("[user] começa a torcer e forçar seu [limb.plaintext_zone] deslocado!"))
		if(!user.combat_mode)
			chiropractice(user)
		else
			malpractice(user)
		return TRUE

/// If someone is snapping our dislocated joint back into place by hand with an aggro grab and help intent
/datum/wound/blunt/bone/moderate/proc/chiropractice(mob/living/carbon/human/user)
	var/time = base_treat_time

	if(!do_after(user, time, target=victim, extra_checks = CALLBACK(src, PROC_REF(still_exists))))
		return

	if(prob(65))
		user.visible_message(span_danger("[user] coloca de volta no lugar o [limb.plaintext_zone] deslocado de [victim]!"), span_notice("Você coloca de volta no lugar o [limb.plaintext_zone] deslocado de [victim]!"), ignored_mobs=victim)
		to_chat(victim, span_userdanger("[user] coloca de volta no lugar o seu [limb.plaintext_zone] deslocado!"))
		victim.emote("scream")
		victim.apply_damage(20, BRUTE, limb, wound_bonus = CANT_WOUND)
		qdel(src)
	else
		user.visible_message(span_danger("[user] torce dolorosamente o [limb.plaintext_zone] deslocado de [victim]!"), span_danger("Você torce dolorosamente o [limb.plaintext_zone] deslocado de [victim]!"), ignored_mobs=victim)
		to_chat(victim, span_userdanger("[user] torce dolorosamente o seu [limb.plaintext_zone] deslocado!"))
		victim.apply_damage(10, BRUTE, limb, wound_bonus = CANT_WOUND)
		chiropractice(user)

/// If someone is snapping our dislocated joint into a fracture by hand with an aggro grab and harm or disarm intent
/datum/wound/blunt/bone/moderate/proc/malpractice(mob/living/carbon/human/user)
	var/time = base_treat_time

	if(!do_after(user, time, target=victim, extra_checks = CALLBACK(src, PROC_REF(still_exists))))
		return

	if(prob(65))
		user.visible_message(span_danger("[user] coloca o [limb.plaintext_zone] deslocado de [victim] de volta com um estalo horrível!"), span_danger("Você coloca o [limb.plaintext_zone] deslocado de [victim] de volta com um estalo horrível!"), ignored_mobs=victim)
		to_chat(victim, span_userdanger("[user] coloca o seu [limb.plaintext_zone] deslocado de volta com um estalo horrível!"))
		victim.emote("scream")
		victim.apply_damage(25, BRUTE, limb, wound_bonus = 30)
	else
		user.visible_message(span_danger("[user] torce dolorosamente o [limb.plaintext_zone] deslocado de [victim]!"), span_danger("Você torce dolorosamente o [limb.plaintext_zone] deslocado de [victim]!"), ignored_mobs=victim)
		to_chat(victim, span_userdanger("[user] torce dolorosamente o seu [limb.plaintext_zone] deslocado!"))
		victim.apply_damage(10, BRUTE, limb, wound_bonus = CANT_WOUND)
		malpractice(user)

/datum/wound/blunt/bone/moderate/treat(obj/item/I, mob/user)
	var/scanned = HAS_TRAIT(src, TRAIT_WOUND_SCANNED)
	var/self_penalty_mult = user == victim ? 1.5 : 1
	var/scanned_mult = scanned ? 0.5 : 1
	var/treatment_delay = base_treat_time * self_penalty_mult * scanned_mult

	if(victim == user)
		victim.visible_message(span_danger("[user] começa [scanned ? "expertly" : ""] a reajustar [victim.p_their()] [limb.plaintext_zone] com [I]."), span_warning("Você começa a reajustar seu [limb.plaintext_zone] com [I][scanned ? ", mantendo as indicações da holo-imagem em mente" : ""]..."))
	else
		user.visible_message(span_danger("[user] começa [scanned ? "expertly" : ""] a reajustar [limb.plaintext_zone] de [victim] com [I]."), span_notice("Você começa a reajustar [limb.plaintext_zone] de [victim] com [I][scanned ? ", mantendo as indicações da holo-imagem em mente" : ""]..."))




	if(!do_after(user, treatment_delay, target = victim, extra_checks=CALLBACK(src, PROC_REF(still_exists))))
		return TRUE

	if(victim == user)
		victim.apply_damage(15, BRUTE, limb, wound_bonus = CANT_WOUND)
		victim.visible_message(span_danger("[user] termina de resetar o [limb.plaintext_zone] de [victim]!"), span_userdanger("Você resetou seu [limb.plaintext_zone]!"))
	else
		victim.apply_damage(10, BRUTE, limb, wound_bonus = CANT_WOUND)
		user.visible_message(span_danger("[user] termina de reajustar [limb.plaintext_zone] de [victim]!"), span_nicegreen("Você termina de reajustar [limb.plaintext_zone] de [victim]!"), ignored_mobs=victim)
		to_chat(victim, span_userdanger("[user] resets your [limb.plaintext_zone]!"))

	victim.emote("scream")
	qdel(src)
	return TRUE

/*
	Severe (Hairline Fracture)
*/

/datum/wound/blunt/bone/severe
	name = "Fratura"
	desc = "O osso do paciente sofreu uma rachadura na fundação, causando dor intensa e funcionalidade reduzida do membro."
	treat_text = "eparar cirurgicamente. Em caso de emergência, uma aplicação de gel ósseo sobre a área afetada se consertará com o tempo. \
    Uma tala ou tipóia de gaze médica também pode ser usada para evitar que a fratura piore."
	treat_text_short = "Reparar cirurgicamente, ou aplicar gel ósseo. Uma tala ou tipóia de gaze também pode ser usada."
	examine_desc = "parece grotescamente inchado, com protuberâncias irregulares sugerindo lascas no osso"
	occur_text = "espalha lascas de osso e desenvolve um hematoma de aparência desagradável"

	severity = WOUND_SEVERITY_SEVERE
	interaction_efficiency_penalty = 2
	limp_slowdown = 6
	limp_chance = 60
	threshold_penalty = 30
	treatable_by = list(/obj/item/stack/sticky_tape/surgical, /obj/item/stack/medical/bone_gel)
	status_effect_type = /datum/status_effect/wound/blunt/bone/severe
	scar_keyword = "bluntsevere"
	brain_trauma_group = BRAIN_TRAUMA_MILD
	trauma_cycle_cooldown = 1.5 MINUTES
	internal_bleeding_chance = 40
	wound_flags = (ACCEPTS_GAUZE | MANGLES_INTERIOR | SPLINT_OVERLAY) // NOVA EDIT - MEDICAL (SPLINT_OVERLAY)
	regen_ticks_needed = 120 // ticks every 2 seconds, 240 seconds, so roughly 4 minutes default

	simple_desc = "O osso do paciente rachou no meio, reduzindo drasticamente a funcionalidade do membro."
	simple_treat_text = "<b>Enfaixar</b> o ferimento reduzirá seu impacto até ser <b>tratado cirurgicamente</b> com gel ósseo e fita cirúrgica."
	homemade_treat_text = "<b>Gel ósseo e fita cirúrgica</b> podem ser aplicados diretamente no ferimento, embora isso seja bastante difícil para a maioria das pessoas realizarem sozinhas, a menos que tenham se medicado com um ou mais <b>analgésicos</b> (Morfina e Miner's Salve são conhecidos por ajudar)."


/datum/wound_pregen_data/bone/hairline
	abstract = FALSE

	wound_path_to_generate = /datum/wound/blunt/bone/severe

	threshold_minimum = 60

/// Compound Fracture (Critical Blunt)
/datum/wound/blunt/bone/critical
	name = "Fratura Composta"
	desc = "Os ossos do paciente sofreram múltiplas fraturas, \
	acompanhadas de uma ruptura na pele, causando dor significativa e inutilidade quase total do membro."
	treat_text = "Imediatamente enfaixe o membro afetado com gaze ou uma tala. Faça reparos cirúrgicos. \
	Em caso de emergência, gel ósseo e fita cirúrgica podem ser aplicados na área afetada para consertar ao longo de um longo período de tempo."
	treat_text_short = "Repare cirurgicamente, ou aplique gel ósseo e fita cirúrgica. Uma tala ou tipoia de gaze também deve ser usada."
	examine_desc = "está completamente esmagado e rachado, expondo fragmentos de osso ao ar livre."
	occur_text = "se parte, expondo ossos quebrados ao ar livre."

	severity = WOUND_SEVERITY_CRITICAL
	interaction_efficiency_penalty = 2.5
	limp_slowdown = 7
	limp_chance = 70
	sound_effect = 'sound/effects/wounds/crack2.ogg'
	threshold_penalty = 50
	disabling = TRUE
	treatable_by = list(/obj/item/stack/sticky_tape/surgical, /obj/item/stack/medical/bone_gel)
	status_effect_type = /datum/status_effect/wound/blunt/bone/critical
	scar_keyword = "bluntcritical"
	brain_trauma_group = BRAIN_TRAUMA_SEVERE
	trauma_cycle_cooldown = 2.5 MINUTES
	internal_bleeding_chance = 60
	wound_flags = (ACCEPTS_GAUZE | MANGLES_INTERIOR | SPLINT_OVERLAY) // NOVA EDIT - MEDICAL (SPLINT_OVERLAY)
	regen_ticks_needed = 240 // ticks every 2 seconds, 480 seconds, so roughly 8 minutes default

	simple_desc = "Os ossos do paciente estão efetivamente completamente despedaçados, causando imobilização total do membro."
	simple_treat_text = "<b>Enfaixar</b> o ferimento reduzirá ligeiramente seu impacto até que seja <b>tratado cirurgicamente</b> com gel ósseo e fita cirúrgica."
	homemade_treat_text = "Embora seja extremamente difícil e lento de realizar, <b>gel ósseo e fita cirúrgica</b> podem ser aplicados diretamente no ferimento, mas isso é praticamente impossível para a maioria das pessoas fazer individualmente, a menos que tenham se medicado com um ou mais <b>analgésicos</b> (Sabe-se que Morfina e Miner's Salve ajudam)."

/datum/wound_pregen_data/bone/compound
	abstract = FALSE

	wound_path_to_generate = /datum/wound/blunt/bone/critical

	threshold_minimum = 115

// doesn't make much sense for "a" bone to stick out of your head
/datum/wound/blunt/bone/critical/apply_wound(obj/item/bodypart/L, silent = FALSE, datum/wound/old_wound = null, smited = FALSE, attack_direction = null, wound_source = "Unknown", replacing = FALSE)
	if(L.body_zone == BODY_ZONE_HEAD)
		occur_text = "se abre, expondo um crânio nu e rachado através da carne e do sangue"
		examine_desc = "tem uma indentação perturbadora, com pedaços de crânio saindot"

	. = ..()

/// if someone is using bone gel on our wound
/datum/wound/blunt/bone/proc/gel(obj/item/stack/medical/bone_gel/I, mob/user)
	// skellies get treated nicer with bone gel since their "reattach dismembered limbs by hand" ability sucks when it's still critically wounded
	if((limb.biological_state & BIO_BONE) && !(limb.biological_state & BIO_FLESH))
		return skelly_gel(I, user)

	if(gelled)
		to_chat(user, span_warning("[user == victim ? "Seu" : "O [limb.plaintext_zone] de [victim]"] já está coberto com gel ósseo!"))
		return TRUE

	user.visible_message(span_danger("[user] começa a aplicar apressadamente [I] em [limb.plaintext_zone] de [victim]..."), span_warning("Você começa a aplicar apressadamente [I] em [user == victim ? "seu" : "[limb.plaintext_zone] de [victim]"], desconsiderando o rótulo de aviso..."))

	if(!do_after(user, base_treat_time * 1.5 * (user == victim ? 1.5 : 1), target = victim, extra_checks=CALLBACK(src, PROC_REF(still_exists))))
		return TRUE

	I.use(1)
	victim.emote("scream")
	if(user != victim)
		user.visible_message(span_notice("[user] finishes applying [I] to [victim]'s [limb.plaintext_zone], emitting a fizzing noise!"), span_notice("You finish applying [I] to [victim]'s [limb.plaintext_zone]!"), ignored_mobs=victim)
		to_chat(victim, span_userdanger("[user] finishes applying [I] to your [limb.plaintext_zone], and you can feel the bones exploding with pain as they begin melting and reforming!"))
	else
		if(!HAS_TRAIT(victim, TRAIT_ANALGESIA))
			if(prob(25 + (20 * (severity - 2)) - min(victim.get_drunk_amount(), 10))) // 25%/45% chance to fail self-applying with severe and critical wounds, modded by drunkenness
				victim.visible_message(span_danger("[victim] fails to finish applying [I] to [victim.p_their()] [limb.plaintext_zone], passing out from the pain!"), span_notice("You pass out from the pain of applying [I] to your [limb.plaintext_zone] before you can finish!"))
				victim.AdjustUnconscious(5 SECONDS)
				return TRUE
		victim.visible_message(span_notice("[victim] finishes applying [I] to [victim.p_their()] [limb.plaintext_zone], grimacing from the pain!"), span_notice("You finish applying [I] to your [limb.plaintext_zone], and your bones explode in pain!"))

	victim.apply_damage(25, BRUTE, limb, wound_bonus = CANT_WOUND)
	victim.apply_damage(100, STAMINA)
	gelled = TRUE
	return TRUE

/// skellies are less averse to bone gel, since they're literally all bone
/datum/wound/blunt/bone/proc/skelly_gel(obj/item/stack/medical/bone_gel/I, mob/user)
	if(gelled)
		to_chat(user, span_warning("[user == victim ? "Your" : "[victim]'s"] [limb.plaintext_zone] is already coated with bone gel!"))
		return

	user.visible_message(span_danger("[user] begins applying [I] to [victim]'s' [limb.plaintext_zone]..."), span_warning("You begin applying [I] to [user == victim ? "your" : "[victim]'s"] [limb.plaintext_zone]..."))

	if(!do_after(user, base_treat_time * (user == victim ? 1.5 : 1), target = victim, extra_checks=CALLBACK(src, PROC_REF(still_exists))))
		return

	I.use(1)
	if(user != victim)
		user.visible_message(span_notice("[user] finishes applying [I] to [victim]'s [limb.plaintext_zone], emitting a fizzing noise!"), span_notice("You finish applying [I] to [victim]'s [limb.plaintext_zone]!"), ignored_mobs=victim)
		to_chat(victim, span_userdanger("[user] finishes applying [I] to your [limb.plaintext_zone], and you feel a funny fizzy tickling as they begin to reform!"))
	else
		victim.visible_message(span_notice("[victim] finishes applying [I] to [victim.p_their()] [limb.plaintext_zone], emitting a funny fizzing sound!"), span_notice("You finish applying [I] to your [limb.plaintext_zone], and feel a funny fizzy tickling as the bone begins to reform!"))

	gelled = TRUE
	processes = TRUE
	return TRUE

/// if someone is using surgical tape on our wound
/datum/wound/blunt/bone/proc/tape(obj/item/stack/sticky_tape/surgical/I, mob/user)
	if(!gelled)
		to_chat(user, span_warning("[user == victim ? "Your" : "[victim]'s"] [limb.plaintext_zone] must be coated with bone gel to perform this emergency operation!"))
		return TRUE
	if(taped)
		to_chat(user, span_warning("[user == victim ? "Your" : "[victim]'s"] [limb.plaintext_zone] is already wrapped in [I.name] and reforming!"))
		return TRUE

	user.visible_message(span_danger("[user] begins applying [I] to [victim]'s' [limb.plaintext_zone]..."), span_warning("You begin applying [I] to [user == victim ? "your" : "[victim]'s"] [limb.plaintext_zone]..."))

	if(!do_after(user, base_treat_time * (user == victim ? 1.5 : 1), target = victim, extra_checks=CALLBACK(src, PROC_REF(still_exists))))
		return TRUE

	if(victim == user)
		regen_ticks_needed *= 1.5

	I.use(1)
	if(user != victim)
		user.visible_message(span_notice("[user] finishes applying [I] to [victim]'s [limb.plaintext_zone], emitting a fizzing noise!"), span_notice("You finish applying [I] to [victim]'s [limb.plaintext_zone]!"), ignored_mobs=victim)
		to_chat(victim, span_green("[user] finishes applying [I] to your [limb.plaintext_zone], you immediately begin to feel your bones start to reform!"))
	else
		victim.visible_message(span_notice("[victim] finishes applying [I] to [victim.p_their()] [limb.plaintext_zone], !"), span_green("You finish applying [I] to your [limb.plaintext_zone], and you immediately begin to feel your bones start to reform!"))

	taped = TRUE
	processes = TRUE
	return TRUE

/datum/wound/blunt/bone/treat(obj/item/I, mob/user)
	if(istype(I, /obj/item/stack/medical/bone_gel))
		return gel(I, user)
	else if(istype(I, /obj/item/stack/sticky_tape/surgical))
		return tape(I, user)

/datum/wound/blunt/bone/get_scanner_description(mob/user)
	. = ..()

	. += "<div class='ml-3'>"

	if(severity > WOUND_SEVERITY_MODERATE)
		if((limb.biological_state & BIO_BONE) && !(limb.biological_state & BIO_FLESH))
			if(!gelled)
				. += "Recommended Treatment: Apply bone gel directly to injured limb. Creatures of pure bone don't seem to mind bone gel application nearly as much as fleshed individuals. Surgical tape will also be unnecessary.\n"
			else
				. += "[span_notice("Note: Bone regeneration in effect. Bone is [round(regen_ticks_current*100/regen_ticks_needed)]% regenerated.")]\n"
		else
			if(!gelled)
				. += "Alternative Treatment: Apply bone gel directly to injured limb, then apply surgical tape to begin bone regeneration. This is both excruciatingly painful and slow, and only recommended in dire circumstances.\n"
			else if(!taped)
				. += "[span_notice("Continue Alternative Treatment: Apply surgical tape directly to injured limb to begin bone regeneration. Note, this is both excruciatingly painful and slow, though sleep or laying down will speed recovery.")]\n"
			else
				. += "[span_notice("Note: Bone regeneration in effect. Bone is [round(regen_ticks_current*100/regen_ticks_needed)]% regenerated.")]\n"

	if(limb.body_zone == BODY_ZONE_HEAD)
		. += "Cranial Trauma Detected: Patient will suffer random bouts of [severity == WOUND_SEVERITY_SEVERE ? "mild" : "severe"] brain traumas until bone is repaired."
	else if(limb.body_zone == BODY_ZONE_CHEST && victim.blood_volume)
		. += "Ribcage Trauma Detected: Further trauma to chest is likely to worsen internal bleeding until bone is repaired."
	. += "</div>"
