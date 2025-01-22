GLOBAL_VAR_INIT(DNR_trait_overlay, generate_DNR_trait_overlay())

/// Instantiates GLOB.DNR_trait_overlay by creating a new mutable_appearance instance of the overlay.
/proc/generate_DNR_trait_overlay()
	RETURN_TYPE(/mutable_appearance)

	var/mutable_appearance/DNR_trait_overlay = mutable_appearance('modular_nova/modules/indicators/icons/DNR_trait_overlay.dmi', "DNR", FLY_LAYER)
	DNR_trait_overlay.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA | KEEP_APART
	return DNR_trait_overlay


// NOVA NEUTRAL TRAITS
/datum/quirk/excitable
    name = "Animado!"
    desc = "Carinhos na cabeça fazem seu rabo balançar! Você é muito animado! BALANÇA BALANÇA."
    gain_text = span_notice("Você anseia por alguns carinhos na cabeça!")
    lose_text = span_notice("Você não se importa mais tanto com carinhos na cabeça.")
    medical_record_text = "O paciente parece se animar facilmente."
    value = 0
    mob_trait = TRAIT_EXCITABLE
    icon = FA_ICON_LAUGH_BEAM
/datum/quirk/affectionaversion
    name = "Aversão a Afeição"
    desc = "Você se recusa a ser lambido ou cutucado por ciborgues quadrúpedes."
    gain_text = span_notice("Você foi adicionado aos registros de Não Lamber e Não Cutucar.")
    lose_text = span_notice("Você foi removido dos registros de Não Lamber e Não Cutucar.")
    medical_record_text = "O paciente está nos registros de Não Lamber e Não Cutucar."
    value = 0
    mob_trait = TRAIT_AFFECTION_AVERSION
    icon = FA_ICON_CIRCLE_EXCLAMATION

/datum/quirk/personalspace
    name = "Espaço Pessoal"
    desc = "Você prefere que as pessoas mantenham as mãos longe do seu traseiro."
    gain_text = span_notice("Você gostaria que as pessoas mantivessem as mãos longe do seu traseiro.")
    lose_text = span_notice("Você está menos preocupado com as pessoas tocando seu traseiro.")
    medical_record_text = "O paciente demonstra reações negativas ao seu posterior ser tocado."
    value = 0
    mob_trait = TRAIT_PERSONALSPACE
    icon = FA_ICON_HAND_PAPER

/datum/quirk/dnr
    name = "Não Reviver"
    desc = "Por qualquer motivo, você não pode ser revivido de nenhuma maneira."
    gain_text = span_notice("Seu espírito fica muito marcado para aceitar a ressurreição.")
    lose_text = span_notice("Você pode sentir sua alma se curando novamente.")
    medical_record_text = "O paciente é um DNR e não pode ser revivido de nenhuma maneira."
    value = 0
    mob_trait = TRAIT_DNR
    icon = FA_ICON_SKULL_CROSSBONES

/datum/quirk/dnr/add(client/client_source)
	. = ..()

	quirk_holder.update_dnr_hud()

/datum/quirk/dnr/remove()
	var/mob/living/old_holder = quirk_holder

	. = ..()

	old_holder.update_dnr_hud()

/mob/living/prepare_data_huds()
	. = ..()

	update_dnr_hud()

/// Adds the DNR HUD element if src has TRAIT_DNR. Removes it otherwise.
/mob/living/proc/update_dnr_hud()
	set_hud_image_state(DNR_HUD, "hud_dnr")
	if(HAS_TRAIT(src, TRAIT_DNR))
		set_hud_image_active(DNR_HUD)
	else
		set_hud_image_inactive(DNR_HUD)

/mob/living/carbon/human/examine(mob/user)
	. = ..()

	if(stat != DEAD && HAS_TRAIT(src, TRAIT_DNR) && (HAS_TRAIT(user, TRAIT_SECURITY_HUD) || HAS_TRAIT(user, TRAIT_MEDICAL_HUD)))
		. += "\n[span_boldwarning("Esse individuo não pode ser revivido, e pode ficar permanente morto caso tenha a chance de morrer!")]"

/datum/atom_hud/data/human/dnr
	hud_icons = list(DNR_HUD)

// uncontrollable laughter
/datum/quirk/item_quirk/joker
    name = "Afeto Pseudobulbar"
    desc = "Em intervalos aleatórios, você sofre surtos incontroláveis de riso."
    value = 0
    quirk_flags = QUIRK_HUMAN_ONLY|QUIRK_PROCESSES
    medical_record_text = "O paciente sofre com surtos súbitos e incontroláveis de riso."
    var/pcooldown = 0
    var/pcooldown_time = 60 SECONDS
    icon = FA_ICON_GRIN_TEARS

/datum/quirk/item_quirk/joker/add_unique(client/client_source)
	give_item_to_holder(/obj/item/paper/joker, list(LOCATION_BACKPACK = ITEM_SLOT_BACKPACK, LOCATION_HANDS = ITEM_SLOT_HANDS))

/datum/quirk/item_quirk/joker/process()
	if(pcooldown > world.time)
		return
	pcooldown = world.time + pcooldown_time
	var/mob/living/carbon/human/user = quirk_holder
	if(user && istype(user))
		if(user.stat == CONSCIOUS)
			if(prob(20))
				user.emote("ri")
				addtimer(CALLBACK(user, /mob/proc/emote, "ri"), 5 SECONDS)
				addtimer(CALLBACK(user, /mob/proc/emote, "ri"), 10 SECONDS)

/obj/item/paper/joker
    name = "cartão de deficiência"
    icon = 'modular_nova/master_files/icons/obj/card.dmi'
    icon_state = "joker"
    desc = "Sorria, mesmo que seu coração esteja doendo."
    default_raw_text = "<i>\
            <div style='border-style:solid;text-align:center;border-width:5px;margin: 20px;margin-bottom:0px'>\
            <div style='margin-top:20px;margin-bottom:20px;font-size:150%;'>\
            Perdoe meu riso:<br>\
            Eu tenho uma condição.\
            </div>\
            </div>\
            </i>\
            <br>\
            <center>\
            <b>\
            MAIS NO VERSO\
            </b>\
            </center>"
    /// Se o cartão está atualmente virado.
    var/flipped = FALSE
    /// A versão virada do default_raw_text.
    var/flipside_default_raw_text = "<i>\
            <div style='border-style:solid;text-align:center;border-width:5px;margin: 20px;margin-bottom:0px'>\
            <div style='margin-top:20px;margin-bottom:20px;font-size:100%;'>\
            <b>\
            É uma condição médica que causa riso súbito,<br>\
            frequente e incontrolável que<br>\
            não corresponde ao que você sente.<br>\
            Pode acontecer em pessoas com lesão cerebral<br>\
            ou certas condições neurológicas.<br>\
            </b>\
            </div>\
            </div>\
            </i>\
            <br>\
            <center>\
            <b>\
            POR FAVOR, DEVOLVA ESTE CARTÃO\
            </b>\
            </center>"
    /// Versão virada de raw_text_inputs.
    var/list/datum/paper_input/flipside_raw_text_inputs
    /// Versão virada de raw_stamp_data.
    var/list/datum/paper_stamp/flipside_raw_stamp_data
    /// Versão virada de raw_field_input_data.
    var/list/datum/paper_field/flipside_raw_field_input_data
    /// Versão virada de input_field_count
    var/flipside_input_field_count = 0


/obj/item/paper/joker/Initialize(mapload)
	. = ..()
	if(flipside_default_raw_text)
		add_flipside_raw_text(flipside_default_raw_text)


/**
 * This is an unironic copy-paste of add_raw_text(), meant to have the same functionalities, but for the flipside.
 *
 * This simple helper adds the supplied raw text to the flipside of the paper, appending to the end of any existing contents.
 *
 * This a God proc that does not care about paper max length and expects sanity checking beforehand if you want to respect it.
 *
 * The caller is expected to handle updating icons and appearance after adding text, to allow for more efficient batch adding loops.
 * * Arguments:
 * * text - The text to append to the paper.
 * * font - The font to use.
 * * color - The font color to use.
 * * bold - Whether this text should be rendered completely bold.
 */
/obj/item/paper/joker/proc/add_flipside_raw_text(text, font, color, bold)
	var/new_input_datum = new /datum/paper_input(
		text,
		font,
		color,
		bold,
	)

	flipside_input_field_count += get_input_field_count(text)

	LAZYADD(flipside_raw_text_inputs, new_input_datum)


/obj/item/paper/joker/update_icon()
	..()
	icon_state = "joker"

/obj/item/paper/joker/click_alt(mob/user)
	var/list/datum/paper_input/old_raw_text_inputs = raw_text_inputs
	var/list/datum/paper_stamp/old_raw_stamp_data = raw_stamp_data
	var/list/datum/paper_stamp/old_raw_field_input_data = raw_field_input_data
	var/old_input_field_count = input_field_count

	raw_text_inputs = flipside_raw_text_inputs
	raw_stamp_data = flipside_raw_stamp_data
	raw_field_input_data = flipside_raw_field_input_data
	input_field_count = flipside_input_field_count

	flipside_raw_text_inputs = old_raw_text_inputs
	flipside_raw_stamp_data = old_raw_stamp_data
	flipside_raw_field_input_data = old_raw_field_input_data
	flipside_input_field_count = old_input_field_count

	flipped = !flipped
	update_static_data()

	balloon_alert(user, "card flipped")
	return CLICK_ACTION_SUCCESS

/datum/quirk/feline_aspect
    name = "Aspecto Felino"
    desc = "Você tende a agir como um felino, por qualquer motivo. Isso substituirá a maioria das peculiaridades de fala baseadas na língua."
    gain_text = span_notice("Nya poderia ir atrás de um pouco de erva-dos-gatos agora mesmo...")
    lose_text = span_notice("Você se sente menos atraído por lasers.")
    medical_record_text = "O paciente parece possuir comportamento muito semelhante ao de um felino."
    mob_trait = TRAIT_FELINE
    icon = FA_ICON_CAT

/datum/quirk/feline_aspect/add_unique(client/client_source)
    var/mob/living/carbon/human/human_holder = quirk_holder
    var/obj/item/organ/tongue/cat/new_tongue = new(get_turf(human_holder))

    ADD_TRAIT(human_holder, TRAIT_WATER_HATER, QUIRK_TRAIT)

    new_tongue.copy_traits_from(human_holder.get_organ_slot(ORGAN_SLOT_TONGUE))
    new_tongue.Insert(human_holder, special = TRUE, movement_flags = DELETE_IF_REPLACED)

/datum/quirk/feline_aspect/remove()
    var/mob/living/carbon/human/human_holder = quirk_holder
    var/obj/item/organ/tongue/new_tongue = new human_holder.dna.species.mutanttongue

    REMOVE_TRAIT(human_holder, TRAIT_WATER_HATER, QUIRK_TRAIT)

    new_tongue.copy_traits_from(human_holder.get_organ_slot(ORGAN_SLOT_TONGUE))
    new_tongue.Insert(human_holder, special = TRUE, movement_flags = DELETE_IF_REPLACED)

/datum/quirk/canine_aspect
    name = "Aspecto Canino"
    desc = "Latido. Você parece agir como um canino por qualquer motivo. Isso substituirá a maioria das peculiaridades de fala baseadas na língua."
    gain_text = span_notice("B-.. Tiras de bacon...")
    lose_text = span_notice("Você sente menos problemas de abandono.")
    mob_trait = TRAIT_CANINE
    icon = FA_ICON_DOG
    value = 0
    medical_record_text = "O paciente foi visto cavando no lixo. Fique de olho nele."

/datum/quirk/canine_aspect/add_unique(client/client_source)
    var/mob/living/carbon/human/human_holder = quirk_holder
    var/obj/item/organ/tongue/dog/new_tongue = new(get_turf(human_holder))

    new_tongue.copy_traits_from(human_holder.get_organ_slot(ORGAN_SLOT_TONGUE))
    new_tongue.Insert(human_holder, special = TRUE, movement_flags = DELETE_IF_REPLACED)

/datum/quirk/canine_aspect/remove()
    var/mob/living/carbon/human/human_holder = quirk_holder
    var/obj/item/organ/tongue/new_tongue = new human_holder.dna.species.mutanttongue

    new_tongue.copy_traits_from(human_holder.get_organ_slot(ORGAN_SLOT_TONGUE))
    new_tongue.Insert(human_holder, special = TRUE, movement_flags = DELETE_IF_REPLACED)

/datum/quirk/avian_aspect
    name = "Aspecto Aviário"
    desc = "Você tem um cérebro de pássaro, ou você tem o cérebro de um pássaro. Isso substituirá a maioria das peculiaridades de fala baseadas na língua."
    gain_text = span_notice("BAWWWWWK DEIXE O HEADSET BAWKKKKK!")
    lose_text = span_notice("Você se sente menos inclinado a sentar em ovos.")
    mob_trait = TRAIT_AVIAN
    icon = FA_ICON_KIWI_BIRD
    value = 0
    medical_record_text = "O paciente exibe comportamentos semelhantes aos de aves."

/datum/quirk/avian_aspect/add_unique(client/client_source)
    var/mob/living/carbon/human/human_holder = quirk_holder
    var/obj/item/organ/tongue/avian/new_tongue = new(get_turf(human_holder))

    new_tongue.copy_traits_from(human_holder.get_organ_slot(ORGAN_SLOT_TONGUE))
    new_tongue.Insert(human_holder, special = TRUE, movement_flags = DELETE_IF_REPLACED)

/datum/quirk/avian_aspect/remove()
    var/mob/living/carbon/human/human_holder = quirk_holder
    var/obj/item/organ/tongue/new_tongue = new human_holder.dna.species.mutanttongue

    new_tongue.copy_traits_from(human_holder.get_organ_slot(ORGAN_SLOT_TONGUE))
    new_tongue.Insert(human_holder, special = TRUE, movement_flags = DELETE_IF_REPLACED)

#define SEVERITY_STUN 1
#define SEVERITY_SNEEZE 2
#define SEVERITY_KNOCKDOWN 3
#define SEVERITY_BLEP 4

GLOBAL_LIST_INIT(possible_snout_sensitivities, list(
    "Stun" = SEVERITY_STUN,
    "Sneeze" = SEVERITY_SNEEZE, //Inclui um atordoamento
    "Collapse" = SEVERITY_KNOCKDOWN,
    "Blep" = SEVERITY_BLEP,
))

/datum/quirk/sensitivesnout
    name = "Focinho Sensível"
    desc = "Seu rosto sempre foi sensível, e dói muito quando alguém o cutuca!"
    gain_text = span_notice("Seu rosto está extremamente sensível.")
    lose_text = span_notice("Seu rosto parece dormente.")
    medical_record_text = "O nariz do paciente parece ter um aglomerado de nervos na ponta, recomendaria evitar contato direto."
    value = 0
    mob_trait = TRAIT_SENSITIVESNOUT
    icon = FA_ICON_FINGERPRINT
    var/severity = SEVERITY_KNOCKDOWN
    COOLDOWN_DECLARE(emote_cooldown)

/datum/quirk_constant_data/sensitive_snout
    associated_typepath = /datum/quirk/sensitivesnout
    customization_options = list(/datum/preference/choiced/snout_sensitivity)

/datum/quirk/sensitivesnout/add(client/client_source)
    var/desired_severity = GLOB.possible_snout_sensitivities[client_source?.prefs?.read_preference(/datum/preference/choiced/snout_sensitivity)]
    severity = isnum(desired_severity) ? desired_severity : 1

/datum/quirk/sensitivesnout/proc/get_booped(attacker)
    var/can_emote = FALSE
    if(COOLDOWN_FINISHED(src, emote_cooldown))
        can_emote = TRUE
        COOLDOWN_START(src, emote_cooldown, 5 SECONDS)
    if (ishuman(quirk_holder) && can_emote)
        var/mob/living/carbon/human/human_holder = quirk_holder
        human_holder.force_say()
    switch(severity)
        if(SEVERITY_STUN)
            to_chat(quirk_holder, span_warning("[attacker] cutuca você no seu nariz sensível, congelando você no lugar!"))
            quirk_holder.Stun(1 SECONDS)
        if(SEVERITY_SNEEZE)
            quirk_holder.Stun(1 SECONDS)
            if(can_emote)
                to_chat(quirk_holder, span_warning("[attacker] cutuca você no seu nariz sensível! Você não consegue segurar um espirro!"))
                quirk_holder.emote("sneeze")
        if(SEVERITY_KNOCKDOWN)
            to_chat(quirk_holder, span_warning("[attacker] cutuca você no seu nariz sensível, derrubando você no chão!"))
            quirk_holder.Knockdown(1 SECONDS)
            quirk_holder.apply_damage(30, STAMINA)
        if(SEVERITY_BLEP)
            if(can_emote)
                to_chat(quirk_holder, span_warning("[attacker] cutuca você no seu nariz sensível! Você coloca a língua para fora por reflexo!"))
                quirk_holder.emote("blep")

#undef SEVERITY_STUN
#undef SEVERITY_SNEEZE
#undef SEVERITY_KNOCKDOWN
#undef SEVERITY_BLEP

/datum/quirk/overweight
    name = "Sobrepeso"
    desc = "Você pesa mais do que uma pessoa média do seu tamanho, você já se acostumou com isso."
    gain_text = span_notice("Seu corpo parece pesado.")
    lose_text = span_notice("Você de repente se sente mais leve!")
    value = 0
    icon = FA_ICON_HAMBURGER // Estou com muita fome. Me dê o hambúrguer!
    medical_record_text = "O paciente pesa mais do que a média."
    mob_trait = TRAIT_OFF_BALANCE_TACKLER

/datum/quirk/overweight/add(client/client_source)
    quirk_holder.add_movespeed_modifier(/datum/movespeed_modifier/overweight)

/datum/quirk/overweight/remove()
    quirk_holder.remove_movespeed_modifier(/datum/movespeed_modifier/overweight)

/datum/movespeed_modifier/overweight
    multiplicative_slowdown = 0.5 // Aproximadamente o de uma mochila, o suficiente para ser impactante, mas não debilitante.

/datum/mood_event/fat/New(mob/parent_mob, ...)
    . = ..()
    if(HAS_TRAIT_FROM(parent_mob, TRAIT_OFF_BALANCE_TACKLER, QUIRK_TRAIT))
        mood_change = 0 // Eles provavelmente estão acostumados com isso, sem razão para ficar visceralmente chateado com isso.
        description = "<b>Eu sou gordo.</b>"
