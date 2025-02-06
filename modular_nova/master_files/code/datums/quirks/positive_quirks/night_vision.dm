// Esta variante da peculiaridade de visão noturna aplica offsets de cor à visão noturna de um mob com base na cor dos olhos escolhida.
// Algumas cores de olhos produzirão efeitos mecânicos de visão noturna ligeiramente mais fortes apenas por causa de seus valores RGB serem mais altos (tipicamente cores mais claras).

/datum/quirk/night_vision
    desc = "Você pode ver um pouco melhor na escuridão do que a maioria dos humanoides comuns. Se seus olhos são naturalmente mais sensíveis à luz por outros meios (como ser fotofóbico ou uma pessoa mariposa), esse efeito é significativamente mais forte."
    medical_record_text = "Os órgãos sensoriais visuais do paciente demonstram desempenho não padrão em condições de pouca luz."
    var/nv_color = null /// Armazena a cor de visão noturna selecionada pelo jogador
    var/list/nv_color_cutoffs = null /// Contém os color_cutoffs aplicados aos olhos do usuário com nossa tonalidade personalizada (uma vez construída)

/datum/quirk/night_vision/add_unique(client/client_source)
    . = ..()
    nv_color = client_source?.prefs.read_preference(/datum/preference/color/nv_color)
    if (isnull(nv_color))
        var/mob/living/carbon/human/human_holder = quirk_holder
        nv_color = process_chat_color(human_holder.eye_color_left)
    nv_color_cutoffs = calculate_color_cutoffs(nv_color)
    refresh_quirk_holder_eyes() // garantir que aplicamos a sobreposição

/// Calcular os color_cutoffs do órgão ocular usados na visão noturna com uma cor hexadecimal fornecida, ajustando e escalando adequadamente.
/datum/quirk/night_vision/proc/calculate_color_cutoffs(color)
    var/mob/living/carbon/human/target = quirk_holder

    // se tivermos olhos mais sensíveis, aumentar o poder
    var/obj/item/organ/eyes/target_eyes = target.get_organ_slot(ORGAN_SLOT_EYES)
    if (!istype(target_eyes))
        return
    var/infravision_multiplier = max(0, (-(target_eyes.flash_protect) * NOVA_NIGHT_VISION_SENSITIVITY_MULT)) + 1

    var/list/new_rgb_cutoffs = new /list(3)
    for(var/i in 1 to 3)
        var/base_color = hex2num(copytext(color, (i*2), (i*2)+2)) //converter o valor hexadecimal fornecido para RGB
        var/adjusted_color = max(((base_color / 255) * (NOVA_NIGHT_VISION_POWER_MAX * infravision_multiplier)), (NOVA_NIGHT_VISION_POWER_MIN * infravision_multiplier)) //converter linearmente a cor dos olhos em um intervalo de color_cutoff, garantindo que esteja ajustado
        new_rgb_cutoffs[i] = adjusted_color

    return new_rgb_cutoffs

/datum/quirk_constant_data/night_vision
    associated_typepath = /datum/quirk/night_vision
    customization_options = list(/datum/preference/color/nv_color)

// Preferência do cliente para a cor da visão noturna
/datum/preference/color/nv_color
    savefile_key = "nv_color"
    savefile_identifier = PREFERENCE_CHARACTER
    category = PREFERENCE_CATEGORY_MANUALLY_RENDERED

/datum/preference/color/nv_color/is_accessible(datum/preferences/preferences)
    if (!..(preferences))
        return FALSE

    return "Night Vision" in preferences.all_quirks

/datum/preference/color/nv_color/apply_to_human(mob/living/carbon/human/target, value)
    return

// executar o Blessed Runechat Proc, pois ele faz a maior parte do que queremos em relação ao ajuste de luminância. poderia ser melhor? provavelmente. é mais trabalho? sim, é MUITO trabalho.
/datum/preference/color/nv_color/deserialize(input, datum/preferences/preferences)
    return process_chat_color(sanitize_hexcolor(input))

/datum/preference/color/nv_color/serialize(input)
    return process_chat_color(sanitize_hexcolor(input))

/datum/preference/color/nv_color/create_default_value()
    return process_chat_color("#[random_color()]")
