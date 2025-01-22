/*
	Burn wounds
*/

// TODO: well, a lot really, but specifically I want to add potential fusing of clothing/equipment on the affected area, and limb infections, though those may go in body part code
/datum/wound/burn
	name = "Queimaduras"
	a_or_from = "de"
	sound_effect = 'sound/effects/wounds/sizzle1.ogg'

/datum/wound/burn/flesh
	name = "Pele queimada"
	a_or_from = "de"
	processes = TRUE

	default_scar_file = FLESH_SCAR_FILE

	treatable_by = list(/obj/item/stack/medical/ointment, /obj/item/stack/medical/mesh) // sterilizer and alcohol will require reagent treatments, coming soon

	// Flesh damage vars
	/// How much damage to our flesh we currently have. Once both this and infestation reach 0, the wound is considered healed
	var/flesh_damage = 5
	/// Our current counter for how much flesh regeneration we have stacked from regenerative mesh/synthflesh/whatever, decrements each tick and lowers flesh_damage
	var/flesh_healing = 0

	// Infestation vars (only for severe and critical)
	/// How quickly infection breeds on this burn if we don't have disinfectant
	var/infestation_rate = 0
	/// Our current level of infection
	var/infestation = 0
	/// Our current level of sanitization/anti-infection, from disinfectants/alcohol/UV lights. While positive, totally pauses and slowly reverses infestation effects each tick
	var/sanitization = 0

	/// Once we reach infestation beyond WOUND_INFESTATION_SEPSIS, we get this many warnings before the limb is completely paralyzed (you'd have to ignore a really bad burn for a really long time for this to happen)
	var/strikes_to_lose_limb = 3

/datum/wound/burn/flesh/handle_process(seconds_per_tick, times_fired)

	if (!victim || HAS_TRAIT(victim, TRAIT_STASIS))
		return

	. = ..()
	if(strikes_to_lose_limb <= 0) // we've already hit sepsis, nothing more to do
		victim.adjustToxLoss(0.25 * seconds_per_tick)
		if(SPT_PROB(0.5, seconds_per_tick))
			victim.visible_message(span_danger("A infecção nos restos do [limb.plaintext_zone] de [victim] se movem e borbulham de maneira nauseante!"), span_warning("Você consegue sentir a infecção nos resto do [limb.plaintext_zone] se movendo por suas veias!"), vision_distance = COMBAT_MESSAGE_RANGE)
		return

	for(var/datum/reagent/reagent as anything in victim.reagents.reagent_list)
		if(reagent.chemical_flags & REAGENT_AFFECTS_WOUNDS)
			reagent.on_burn_wound_processing(src)

	if(HAS_TRAIT(victim, TRAIT_VIRUS_RESISTANCE))
		sanitization += 0.9

	if(limb.current_gauze)
		limb.seep_gauze(WOUND_BURN_SANITIZATION_RATE * seconds_per_tick)

	if(flesh_healing > 0) // good bandages multiply the length of flesh healing
		var/bandage_factor = limb.current_gauze?.burn_cleanliness_bonus || 1
		flesh_damage = max(flesh_damage - (0.5 * seconds_per_tick), 0)
		flesh_healing = max(flesh_healing - (0.5 * bandage_factor * seconds_per_tick), 0) // good bandages multiply the length of flesh healing

	// if we have little/no infection, the limb doesn't have much burn damage, and our nutrition is good, heal some flesh
	if(infestation <= WOUND_INFECTION_MODERATE && (limb.burn_dam < 5) && (victim.nutrition >= NUTRITION_LEVEL_FED))
		flesh_healing += 0.2

	// here's the check to see if we're cleared up
	if((flesh_damage <= 0) && (infestation <= WOUND_INFECTION_MODERATE))
		to_chat(victim, span_green("As queimaduras em seu [limb.plaintext_zone] foram limpas!"))
		qdel(src)
		return

	// sanitization is checked after the clearing check but before the actual ill-effects, because we freeze the effects of infection while we have sanitization
	if(sanitization > 0)
		var/bandage_factor = limb.current_gauze?.burn_cleanliness_bonus || 1
		infestation = max(infestation - (WOUND_BURN_SANITIZATION_RATE * seconds_per_tick), 0)
		sanitization = max(sanitization - (WOUND_BURN_SANITIZATION_RATE * bandage_factor * seconds_per_tick), 0)
		return

	infestation += infestation_rate * seconds_per_tick
	switch(infestation)
		if(0 to WOUND_INFECTION_MODERATE)
			return

		if(WOUND_INFECTION_MODERATE to WOUND_INFECTION_SEVERE)
			if(SPT_PROB(15, seconds_per_tick))
				victim.adjustToxLoss(0.2)
				if(prob(6))
					to_chat(victim, span_warning("As bolhas em seu [limb.plaintext_zone] jorram um pus estranho..."))

		if(WOUND_INFECTION_SEVERE to WOUND_INFECTION_CRITICAL)
			if(!disabling)
				if(SPT_PROB(1, seconds_per_tick))
					to_chat(victim, span_warning("<b>O seu [limb.plaintext_zone] trava por completo, enquanto você tenta retomar o controle da infecção!</b>"))
					set_disabling(TRUE)
					return
			else if(SPT_PROB(4, seconds_per_tick))
				to_chat(victim, span_notice("Você reganha os sentidos em seu [limb.plaintext_zone], mas ainda está fudido!"))
				set_disabling(FALSE)
				return

			if(SPT_PROB(10, seconds_per_tick))
				victim.adjustToxLoss(0.5)

		if(WOUND_INFECTION_CRITICAL to WOUND_INFECTION_SEPTIC)
			if(!disabling)
				if(SPT_PROB(1.5, seconds_per_tick))
					to_chat(victim, span_warning("<b>Você de repente perde toda a sensação da infecção supurante em seu [limb.plaintext_zone]!</b>"))
					set_disabling(TRUE)
					return
			else if(SPT_PROB(1.5, seconds_per_tick))
				to_chat(victim, span_notice("Você mal consegue sentir seu [limb.plaintext_zone], e você tem que se esforçar para manter o controle!"))
				set_disabling(FALSE)
				return

			if(SPT_PROB(2.48, seconds_per_tick))
				if(prob(20))
					to_chat(victim, span_warning("Você contempla a vida sem o seu [limb.plaintext_zone]..."))
					victim.adjustToxLoss(0.75)
				else
					victim.adjustToxLoss(1)

		if(WOUND_INFECTION_SEPTIC to INFINITY)
			if(SPT_PROB(0.5 * infestation, seconds_per_tick))
				strikes_to_lose_limb--
				switch(strikes_to_lose_limb)
					if(2 to INFINITY)
						to_chat(victim, span_deadsay("<b>A infecção em seu [limb.plaintext_zone] está literalmente pingando, você se sente horrivel!</b>"))
					if(1)
						to_chat(victim, span_deadsay("<b>A infecção praticamente ja dominou o seu [limb.plaintext_zone]!</b>"))
					if(0)
						to_chat(victim, span_deadsay("<b>Os ultimos nervos morrem em seu [limb.plaintext_zone] murcho, já que a infecção paralisa completamente o conector da articulação.</b>"))
						threshold_penalty = 120 // piss easy to destroy
						set_disabling(TRUE)

/datum/wound/burn/flesh/set_disabling(new_value)
	. = ..()
	if(new_value && strikes_to_lose_limb <= 0)
		treat_text_short = "Amputar ou augmentar o membro imediatamente ou colocar o paciente em criogenia."
	else
		treat_text_short = initial(treat_text_short)

/datum/wound/burn/flesh/get_wound_description(mob/user)
	if(strikes_to_lose_limb <= 0)
		return span_deadsay("<B>O [limb.plaintext_zone] de [victim.p_Their()] travou por completo e está não funcional.</B>")

	var/list/condition = list("[victim.p_Their()] [limb.plaintext_zone] [examine_desc]")
	if(limb.current_gauze)
		var/bandage_condition
		switch(limb.current_gauze.absorption_capacity)
			if(0 to 1.25)
				bandage_condition = "quase arruinado"
			if(1.25 to 2.75)
				bandage_condition = "gravemente ferido"
			if(2.75 to 4)
				bandage_condition = "ligeiramente manchado"
			if(4 to INFINITY)
				bandage_condition = "limpo"

		condition += " abaixo de uma camada de [bandage_condition] em seu [limb.current_gauze.name]."
	else
		switch(infestation)
			if(WOUND_INFECTION_MODERATE to WOUND_INFECTION_SEVERE)
				condition += ", [span_deadsay("com sinais de infecção iniciais.")]"
			if(WOUND_INFECTION_SEVERE to WOUND_INFECTION_CRITICAL)
				condition += ", [span_deadsay("com manchas crescentes de infecção.")]"
			if(WOUND_INFECTION_CRITICAL to WOUND_INFECTION_SEPTIC)
				condition += ", [span_deadsay("com estrias de infecção podre!")]"
			if(WOUND_INFECTION_SEPTIC to INFINITY)
				return span_deadsay("<B> O [limb.plaintext_zone] é uma bagunça de pele carbonizada e podridão infectada de [victim.p_Their()]!</B>")
			else
				condition += "!"

	return "<B>[condition.Join()]</B>"

/datum/wound/burn/flesh/severity_text(simple = FALSE)
	. = ..()
	. += " Burn / "
	switch(infestation)
		if(-INFINITY to WOUND_INFECTION_MODERATE)
			. += "Não"
		if(WOUND_INFECTION_MODERATE to WOUND_INFECTION_SEVERE)
			. += "Médio"
		if(WOUND_INFECTION_SEVERE to WOUND_INFECTION_CRITICAL)
			. += "<b>Severo</b>"
		if(WOUND_INFECTION_CRITICAL to WOUND_INFECTION_SEPTIC)
			. += "<b>Critico</b>"
		if(WOUND_INFECTION_SEPTIC to INFINITY)
			. += "<b>Total</b>"
	. += " Infecção "

/datum/wound/burn/flesh/get_scanner_description(mob/user)
	if(strikes_to_lose_limb <= 0) // Unclear if it can go below 0, best to not take the chance
		var/oopsie = "Tipo: [name]<br>Gravidade: [severity_text()]"
		oopsie += "<div class='ml-3'>Nivel de infecção: [span_deadsay("A parte do corpo sofreu sepse completa e deve ser removida. Amputar ou aumentar o membro imediatamente ou colocar o paciente em um criotubo.")]</div>"
		return oopsie

	. = ..()
	. += "<div class='ml-3'>"

	if(infestation <= sanitization && flesh_damage <= flesh_healing)
		. += "Sem tratamento nescessario: Queimaduras vão se curar em breve."
	else
		switch(infestation)
			if(WOUND_INFECTION_MODERATE to WOUND_INFECTION_SEVERE)
				. += "Nivel de Infecção: Médio\n"
			if(WOUND_INFECTION_SEVERE to WOUND_INFECTION_CRITICAL)
				. += "Nivel de Infecção: Severo\n"
			if(WOUND_INFECTION_CRITICAL to WOUND_INFECTION_SEPTIC)
				. += "Nivel de Infecção: [span_deadsay("CRITICO")]\n"
			if(WOUND_INFECTION_SEPTIC to INFINITY)
				. += "Nivel de Infecção: [span_deadsay("PERDA IMINENTE")]\n"
		if(infestation > sanitization)
			. += "\tDesbridamento cirúrgico, antibióticos/esterilizadores ou bandagem regenerativa eliminarão a infecção. As lanternas UV paramédicas também são eficazes.\n"

		if(flesh_damage > 0)
			. += "Danos na carne detectados: A aplicação de pomada, bandagem regenerativa, Synthflesh ou ingestão de Miner's Salve reparará a carne danificada. Boa nutrição, descanso e manutenção da ferida limpa também podem reparar lentamente a carne.\n"
	. += "</div>"

/*
	new burn common procs
*/

/// Checks if the wound is in a state that ointment or flesh will help
/datum/wound/burn/flesh/proc/can_be_ointmented_or_meshed()
	if(infestation > 0 || sanitization < infestation)
		return TRUE
	if(flesh_damage > 0 || flesh_healing <= flesh_damage)
		return TRUE
	return FALSE

/// Paramedic UV penlights
/datum/wound/burn/flesh/proc/uv(obj/item/flashlight/pen/paramedic/I, mob/user)
	if(!COOLDOWN_FINISHED(I, uv_cooldown))
		to_chat(user, span_notice("[I] ainda está recarregando!"))
		return TRUE
	if(infestation <= 0 || infestation < sanitization)
		to_chat(user, span_notice("Não há infecção para tratar em [limb.plaintext_zone] de [victim]!"))
		return TRUE

	user.visible_message(span_notice("[user] elimina as queimaduras em [limb] de [victim] usando [I]."), span_notice("Você cura as queimaduras em [limb.plaintext_zone] de [user == victim ? "your" : "[victim]'s"] usando [I]."), vision_distance=COMBAT_MESSAGE_RANGE)
	sanitization += I.uv_power
	COOLDOWN_START(I, uv_cooldown, I.uv_cooldown_length)
	return TRUE

/datum/wound/burn/flesh/treat(obj/item/I, mob/user)
	if(istype(I, /obj/item/flashlight/pen/paramedic))
		return uv(I, user)

// people complained about burns not healing on stasis beds, so in addition to checking if it's cured, they also get the special ability to very slowly heal on stasis beds if they have the healing effects stored
/datum/wound/burn/flesh/on_stasis(seconds_per_tick, times_fired)
	. = ..()
	if(strikes_to_lose_limb <= 0) // we've already hit sepsis, nothing more to do
		if(SPT_PROB(0.5, seconds_per_tick))
			victim.visible_message(span_danger("A infecção nos restos do [limb.plaintext_zone] de [victim] se movem e borbulham de maneira nauseante!"), span_warning("Você consegue sentir a infecção nos restos de seu [limb.plaintext_zone] se mexendo em suas veias!"), vision_distance = COMBAT_MESSAGE_RANGE)
		return
	if(flesh_healing > 0)
		flesh_damage = max(flesh_damage - (0.1 * seconds_per_tick), 0)
	if((flesh_damage <= 0) && (infestation <= 1))
		to_chat(victim, span_green("As queimaduras em seu [limb.plaintext_zone] foram curadas!"))
		qdel(src)
		return
	if(sanitization > 0)
		infestation = max(infestation - (0.1 * WOUND_BURN_SANITIZATION_RATE * seconds_per_tick), 0)

/datum/wound/burn/flesh/on_synthflesh(reac_volume)
	flesh_healing += reac_volume * 0.5 // 20u patch will heal 10 flesh standard

/datum/wound_pregen_data/flesh_burn
	abstract = TRUE

	required_wounding_types = list(WOUND_BURN)
	required_limb_biostate = BIO_FLESH

	wound_series = WOUND_SERIES_FLESH_BURN_BASIC

/datum/wound/burn/get_limb_examine_description()
	return span_warning("A carne neste membro parece ter passado do ponto.")

// we don't even care about first degree burns, straight to second
/datum/wound/burn/flesh/moderate
	name = "Queimadura de segundo grau"
	desc = "Paciente está sofrendo queimaduras consideráveis com leve penetração na pele, enfraquecendo a integridade do membro e aumentando as sensações de queimação."
	treat_text = "Aplique pomada tópica ou malha regenerativa na ferida."
	treat_text_short = "Aplique auxílio de cura, como malha regenerativa."
	examine_desc = "Está gravemente queimado e formando bolhas."
	occur_text = "desencadeia queimaduras vermelhas violentas."
	severity = WOUND_SEVERITY_MODERATE
	damage_multiplier_penalty = 1.1
	threshold_penalty = 30 // burns cause significant decrease in limb integrity compared to other wounds
	status_effect_type = /datum/status_effect/wound/burn/flesh/moderate
	flesh_damage = 5
	scar_keyword = "burnmoderate"

	simple_desc = "A pele do paciente está queimada, enfraquecendo o membro e multiplicando a percepção de dano!"
	simple_treat_text = "Pomada acelerará a recuperação, assim como a malha regenerativa. O risco de infecção é insignificante."
	homemade_treat_text = "Chá saudável acelerará a recuperação. Sal, ou preferencialmente uma mistura de água salgada, irá desinfetar a ferida, mas o primeiro causará irritação na pele, aumentando o risco de infecção."

/datum/wound_pregen_data/flesh_burn/second_degree
	abstract = FALSE

	wound_path_to_generate = /datum/wound/burn/flesh/moderate

	threshold_minimum = 40

/datum/wound/burn/flesh/severe
	name = "Queimaduras de Terceiro Grau"
	desc = "O paciente está sofrendo queimaduras extremas com penetração total da pele, criando sério risco de infecção e integridade do membro muito reduzida."
	treat_text = "Aplique rapidamente auxílios de cura, como Synthflesh ou malha regenerativa, na ferida. \
        Desinfete a ferida e desbride cirurgicamente qualquer pele infectada, e enfaixe com gaze limpa / use pomada para prevenir infecções adicionais. \
        Se o membro estiver travado, deve ser amputado, aumentado ou tratado com criogenia."
	treat_text_short = "Aplique auxílios de cura, como malha regenerativa, Synthflesh ou criogenia e desinfete / desbride. \
        Gaze limpa ou pomada retardarão a taxa de infecção."
	examine_desc = "parece seriamente carbonizado, com manchas vermelhas agressivas"
	occur_text = "carboniza rapidamente, expondo tecido arruinado e espalhando queimaduras vermelhas irritadas"
	severity = WOUND_SEVERITY_SEVERE
	damage_multiplier_penalty = 1.2
	threshold_penalty = 40
	status_effect_type = /datum/status_effect/wound/burn/flesh/severe
	treatable_by = list(/obj/item/flashlight/pen/paramedic, /obj/item/stack/medical/ointment, /obj/item/stack/medical/mesh)
	infestation_rate = 0.07 // appx 9 minutes to reach sepsis without any treatment
	flesh_damage = 12.5
	scar_keyword = "burnsevere"

	simple_desc = "A pele do paciente está gravemente queimada, enfraquecendo significativamente o membro e agravando ainda mais os danos!!"
	simple_treat_text = "<b>Bandagens acelerarão a recuperação</b>, assim como <b>pomada ou bandagem regenerativa</b>. <b>Spaceacilin, sterilizine e Miner's Salve</b> ajudarão com a infecção."
	homemade_treat_text = "<b>Chá saudável</b> acelerará a recuperação. <b>Sal</b>, ou preferencialmente uma mistura de <b>água salgada</b>, desinfetará a ferida, mas o primeiro especialmente causará irritação e desidratação da pele, acelerando a infecção. <b>Space Cleaner</b> pode ser usado como desinfetante em uma emergência."

/datum/wound_pregen_data/flesh_burn/third_degree
	abstract = FALSE

	wound_path_to_generate = /datum/wound/burn/flesh/severe

	threshold_minimum = 80

/datum/wound/burn/flesh/critical
	name = "Queimaduras Catastróficas"
	desc = "O paciente está sofrendo uma perda quase total de tecido, com músculos e ossos significativamente carbonizados, criando um risco de infecção que ameaça a vida e uma integridade da parte do corpo praticamente inexistente."
	treat_text = "Aplique imediatamente auxílios de cura, \
	como Synthflesh ou bandagem regenerativa na ferida. Desinfete a ferida e faça a desbridagem cirúrgica da pele infectada, \
	depois envolva com gaze limpa ou use pomada para evitar infecções adicionais. \
	Se o membro estiver travado, ele deve ser amputado, augmentado ou tratado com criogenia."
	treat_text_short = "Aplique auxílio de cura como bandagem regenerativa, Synthflesh ou criogenia, e desinfete/desbride.\
	 Gaze limpa ou pomada reduzirá a taxa de infecção."
	examine_desc = "É uma bagunça destruída de ossos empalidecidos, gordura derretida e tecido carbonizado."
	occur_text = "Vaporiza-se enquanto a carne, os ossos e a gordura se derretem juntos em uma bagunça horrível."
	severity = WOUND_SEVERITY_CRITICAL
	damage_multiplier_penalty = 1.3
	sound_effect = 'sound/effects/wounds/sizzle2.ogg'
	threshold_penalty = 80
	status_effect_type = /datum/status_effect/wound/burn/flesh/critical
	treatable_by = list(/obj/item/flashlight/pen/paramedic, /obj/item/stack/medical/ointment, /obj/item/stack/medical/mesh)
	infestation_rate = 0.075 // appx 4.33 minutes to reach sepsis without any treatment
	flesh_damage = 20
	scar_keyword = "burncritical"

	simple_desc = "A pele do paciente está destruída e o tecido carbonizado, deixando o membro com quase <b>nenhuma integridade</b> e uma chance drástica de <b>infecção</b>!!!"
	simple_treat_text = "Imediatamente <b>enfaixe</b> a ferida e trate-a com <b>pomada ou bandagem regenerativa</b>. <b>Spaceacilin, esterilizine ou 'Miner's Salve'</b> ajudarão a prevenir infecções. Busque cuidados profissionais <b>imediatamente</b>, antes que a septicemia se instale e a ferida se torne intratável."
	homemade_treat_text = "<b>Chá saudável</b> ajudará na recuperação. Uma mistura de <b>sal-gema com água</b>, aplicada topicamente, pode ajudar a prevenir infecções no curto prazo, mas sal de cozinha puro NÃO é recomendado. <b>Space Cleaner</b> pode ser usado como desinfetante em uma emergência.."

/datum/wound_pregen_data/flesh_burn/fourth_degree
	abstract = FALSE

	wound_path_to_generate = /datum/wound/burn/flesh/critical

	threshold_minimum = 140

///special severe wound caused by sparring interference or other god related punishments.
/datum/wound/burn/flesh/severe/brand
	name = "Holy Brand"
	desc = "Patient is suffering extreme burns from a strange brand marking, creating serious risk of infection and greatly reduced limb integrity."
	examine_desc = "appears to have holy symbols painfully branded into their flesh, leaving severe burns."
	occur_text = "chars rapidly into a strange pattern of holy symbols, burned into the flesh."
	simple_desc = "Patient's skin has had strange markings burned onto it, significantly weakening the limb and compounding further damage!!"

/datum/wound_pregen_data/flesh_burn/third_degree/holy
	abstract = FALSE
	can_be_randomly_generated = FALSE

	wound_path_to_generate = /datum/wound/burn/flesh/severe/brand

/// special severe wound caused by the cursed slot machine.
/datum/wound/burn/flesh/severe/cursed_brand
	name = "Ancient Brand"
	desc = "Patient is suffering extreme burns with oddly ornate brand markings, creating serious risk of infection and greatly reduced limb integrity."
	examine_desc = "appears to have ornate symbols painfully branded into their flesh, leaving severe burns"
	occur_text = "chars rapidly into a pattern that can only be described as an agglomeration of several financial symbols, burned into the flesh"

/datum/wound/burn/flesh/severe/cursed_brand/get_limb_examine_description()
	return span_warning("The flesh on this limb has several ornate symbols burned into it, with pitting throughout.")

/datum/wound_pregen_data/flesh_burn/third_degree/cursed_brand
	abstract = FALSE
	can_be_randomly_generated = FALSE

	wound_path_to_generate = /datum/wound/burn/flesh/severe/cursed_brand
