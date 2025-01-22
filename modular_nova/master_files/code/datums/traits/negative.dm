// NOVA NEGATIVE TRAITS

/datum/quirk/alexithymia
    name = "Alexitimia"
    desc = "Você não consegue avaliar com precisão seus sentimentos."
    value = -4
    mob_trait = TRAIT_MOOD_NOEXAMINE
    medical_record_text = "O paciente é incapaz de comunicar suas emoções."
    icon = FA_ICON_QUESTION_CIRCLE

/datum/quirk/fragile
    name = "Fragilidade"
    desc = "Você se sente incrivelmente frágil. Queimaduras e contusões doem mais do que na média das pessoas!"
    value = -6
    medical_record_text = "O corpo do paciente se adaptou à baixa gravidade. Infelizmente, ambientes de baixa gravidade não são propícios ao desenvolvimento de ossos fortes."
    icon = FA_ICON_TIRED

/datum/quirk_constant_data/fragile
    associated_typepath = /datum/quirk/fragile
    customization_options = list(
        /datum/preference/numeric/fragile_customization/brute,
        /datum/preference/numeric/fragile_customization/burn,
    )

/datum/preference/numeric/fragile_customization
    abstract_type = /datum/preference/numeric/fragile_customization
    category = PREFERENCE_CATEGORY_MANUALLY_RENDERED
    savefile_identifier = PREFERENCE_CHARACTER

    minimum = 1.25
    maximum = 5 // 5x dano, arbitrário

    step = 0.01

/datum/preference/numeric/fragile_customization/apply_to_human(mob/living/carbon/human/target, value, datum/preferences/preferences)
    return FALSE

/datum/preference/numeric/fragile_customization/create_default_value()
    return 1.25

/datum/preference/numeric/fragile_customization/brute
    savefile_key = "fragile_brute"

/datum/preference/numeric/fragile_customization/burn
    savefile_key = "fragile_burn"

/datum/quirk/fragile/post_add()
    . = ..()

    var/mob/living/carbon/human/user = quirk_holder
    var/datum/preferences/prefs = user.client.prefs
    var/brutemod = prefs.read_preference(/datum/preference/numeric/fragile_customization/brute)
    var/burnmod = prefs.read_preference(/datum/preference/numeric/fragile_customization/burn)

    user.physiology.brute_mod *= brutemod
    user.physiology.burn_mod *= burnmod

/datum/quirk/fragile/remove()
    . = ..()

    var/mob/living/carbon/human/user = quirk_holder
    var/datum/preferences/prefs = user.client.prefs
    var/brutemod = prefs.read_preference(/datum/preference/numeric/fragile_customization/brute)
    var/burnmod = prefs.read_preference(/datum/preference/numeric/fragile_customization/burn)
    // causará problemas se o usuário mudar esse valor antes da remoção, mas quando as peculiaridades são removidas além de qdel
    user.physiology.brute_mod /= brutemod
    user.physiology.burn_mod /= burnmod

/datum/quirk/monophobia
    name = "Monofobia"
    desc = "Você ficará cada vez mais estressado quando não estiver na companhia de outros, desencadeando reações de pânico que variam de doença a ataques cardíacos."
    value = -6
    gain_text = span_danger("Você se sente muito sozinho...")
    lose_text = span_notice("Você sente que poderia estar seguro sozinho.")
    medical_record_text = "O paciente se sente doente e angustiado quando não está perto de outras pessoas, levando a níveis potencialmente letais de estresse."
    icon = FA_ICON_PEOPLE_ARROWS_LEFT_RIGHT

/datum/quirk/monophobia/post_add()
    . = ..()
    var/mob/living/carbon/human/user = quirk_holder
    user.gain_trauma(/datum/brain_trauma/severe/monophobia, TRAUMA_RESILIENCE_ABSOLUTE)

/datum/quirk/monophobia/remove()
    . = ..()
    var/mob/living/carbon/human/user = quirk_holder
    user?.cure_trauma_type(/datum/brain_trauma/severe/monophobia, TRAUMA_RESILIENCE_ABSOLUTE)

/datum/quirk/no_guns
    name = "Sem Armas"
    desc = "Por qualquer motivo, você é incapaz de usar armas de fogo. A razão pode variar, mas cabe a você decidir."
    gain_text = span_notice("Você sente que não será mais capaz de usar armas de fogo...")
    lose_text = span_notice("Você de repente sente que pode usar armas de fogo novamente!")
    medical_record_text = "O paciente é incapaz de usar armas de fogo. Razão desconhecida."
    value = -6
    mob_trait = TRAIT_NOGUNS
    icon = FA_ICON_GUN
