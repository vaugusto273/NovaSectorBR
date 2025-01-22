// NOVA GOOD TRAITS

/datum/quirk/hard_soles
    name = "Solas Endurecidas"
    desc = "Você está acostumado a andar descalço e não sofrerá os efeitos negativos de fazê-lo."
    value = 2
    mob_trait = TRAIT_HARD_SOLES
    gain_text = span_notice("O chão não parece mais tão áspero nos seus pés.")
    lose_text = span_danger("Você começa a sentir as saliências e imperfeições no chão.")
    medical_record_text = "Os pés do paciente são mais resistentes à tração."
    icon = FA_ICON_PERSON_RUNNING

/datum/quirk/linguist
    name = "Linguista"
    desc = "Você é um estudante de várias línguas e possui um ponto adicional de linguagem."
    value = 4
    mob_trait = TRAIT_LINGUIST
    gain_text = span_notice("Seu cérebro parece mais equipado para lidar com diferentes modos de conversa.")
    lose_text = span_danger("Sua compreensão dos pontos mais finos dos idiomas dracônicos desaparece.")
    medical_record_text = "O paciente demonstra alta plasticidade cerebral em relação ao aprendizado de línguas."
    icon = FA_ICON_BOOK_ATLAS

/datum/quirk/sharpclaws
    name = "Garras Afiadas"
    desc = "Seja pela biologia inerente de um caçador ou pela sua teimosa recusa em cortar as unhas antes das aulas de Jiu-Jitsu, seus ataques desarmados são mais afiados e farão as pessoas sangrarem."
    value = 2
    gain_text = span_notice("Suas palmas doem um pouco devido à afiação das suas unhas.")
    lose_text = span_danger("Você sente um vazio distinto enquanto suas unhas ficam cegas; boa sorte para coçar aquela coceira.")
    medical_record_text = "O paciente acabou arranhando as almofadas da mesa de exame; recomendado que ele considere cortar as garras."
    icon = FA_ICON_LINES_LEANING

/datum/quirk/sharpclaws/add(client/client_source)
    var/mob/living/carbon/human/human_holder = quirk_holder
    if(!istype(human_holder))
        return FALSE

    var/obj/item/bodypart/arm/left/left_arm = human_holder.get_bodypart(BODY_ZONE_L_ARM)
    if(left_arm)
        left_arm.unarmed_attack_verbs = list("cortar")
        left_arm.unarmed_attack_effect = ATTACK_EFFECT_CLAW
        left_arm.unarmed_attack_sound = 'sound/items/weapons/slash.ogg'
        left_arm.unarmed_miss_sound = 'sound/items/weapons/slashmiss.ogg'
        left_arm.unarmed_sharpness = SHARP_EDGED

    var/obj/item/bodypart/arm/right/right_arm = human_holder.get_bodypart(BODY_ZONE_R_ARM)
    if(right_arm)
        right_arm.unarmed_attack_verbs = list("cortar")
        right_arm.unarmed_attack_effect = ATTACK_EFFECT_CLAW
        right_arm.unarmed_attack_sound = 'sound/items/weapons/slash.ogg'
        right_arm.unarmed_miss_sound = 'sound/items/weapons/slashmiss.ogg'
        right_arm.unarmed_sharpness = SHARP_EDGED

/datum/quirk/sharpclaws/remove(client/client_source)
    var/mob/living/carbon/human/human_holder = quirk_holder
    var/obj/item/bodypart/arm/left/left_arm = human_holder.get_bodypart(BODY_ZONE_L_ARM)
    if(left_arm)
        left_arm.unarmed_attack_verbs = initial(left_arm.unarmed_attack_verbs)
        left_arm.unarmed_attack_effect = initial(left_arm.unarmed_attack_effect)
        left_arm.unarmed_attack_sound = initial(left_arm.unarmed_attack_sound)
        left_arm.unarmed_miss_sound = initial(left_arm.unarmed_miss_sound)
        left_arm.unarmed_sharpness = initial(left_arm.unarmed_sharpness)

    var/obj/item/bodypart/arm/right/right_arm = human_holder.get_bodypart(BODY_ZONE_R_ARM)
    if(right_arm)
        right_arm.unarmed_attack_verbs = initial(right_arm.unarmed_attack_verbs)
        right_arm.unarmed_attack_effect = initial(right_arm.unarmed_attack_effect)
        right_arm.unarmed_attack_sound = initial(right_arm.unarmed_attack_sound)
        right_arm.unarmed_miss_sound = initial(right_arm.unarmed_miss_sound)
        right_arm.unarmed_sharpness = initial(right_arm.unarmed_sharpness)

/datum/quirk/water_breathing
    name = "Respiração Aquática"
    desc = "Você é capaz de respirar debaixo d'água!"
    value = 2
    mob_trait = TRAIT_WATER_BREATHING
    gain_text = span_notice("Você se torna agudamente consciente da umidade em seus pulmões e no ar. É agradável.")
    lose_text = span_danger("Você de repente percebe que a umidade em seus pulmões parece <i>realmente estranha</i>, e quase se engasga com ela!")
    medical_record_text = "O paciente possui biologia compatível com respiração aquática."
    icon = FA_ICON_FISH

// AdditionalEmotes *turf quirks
/datum/quirk/water_aspect
    name = "Aspecto Aquático (Emotes)"
    desc = "(Inato Aquático) Sociedades subaquáticas são seu lar, o espaço não é muito diferente. (Diga *turf para lançar)"
    value = 0
    mob_trait = TRAIT_WATER_ASPECT
    gain_text = span_notice("Você sente que pode controlar a água.")
    lose_text = span_danger("De alguma forma, você perdeu sua habilidade de controlar a água!")
    medical_record_text = "O paciente possui uma coleção de nanobots projetados para sintetizar H2O."
    icon = FA_ICON_WATER

/datum/quirk/webbing_aspect
    name = "Aspecto de Tecelagem (Emotes)"
    desc = "(Inato Inseto) Pessoas inseto capazes de tecer não são desconhecidas de receber inveja daqueles que não possuem uma impressora 3D natural. (Diga *turf para lançar)"
    value = 0
    mob_trait = TRAIT_WEBBING_ASPECT
    gain_text = span_notice("Você poderia facilmente tecer uma teia.")
    lose_text = span_danger("De alguma forma, você perdeu sua habilidade de tecer.")
    medical_record_text = "O paciente tem a habilidade de tecer teias com seda naturalmente sintetizada."
    icon = FA_ICON_STICKY_NOTE

/datum/quirk/floral_aspect
    name = "Aspecto Floral (Emotes)"
    desc = "(Inato Podperson) Pesquisa de Kudzu não é inútil, a tecnologia de fotossíntese rápida está aqui! (Diga *turf para lançar)"
    value = 0
    mob_trait = TRAIT_FLORAL_ASPECT
    gain_text = span_notice("Você sente que pode crescer vinhas.")
    lose_text = span_danger("De alguma forma, você perdeu sua habilidade de fotossintetizar rapidamente.")
    medical_record_text = "O paciente pode fotossintetizar rapidamente para crescer vinhas."
    icon = FA_ICON_PLANT_WILT

/datum/quirk/ash_aspect
    name = "Aspecto de Cinzas (Emotes)"
    desc = "(Inato Lagarto) A habilidade de forjar cinzas e chamas, um poder grandioso - mas usado principalmente para teatro. (Diga *turf para lançar)"
    value = 0
    mob_trait = TRAIT_ASH_ASPECT
    gain_text = span_notice("Há uma forja fumegante dentro de você.")
    lose_text = span_danger("De alguma forma, você perdeu sua habilidade de cuspir fogo.")
    medical_record_text = "Os pacientes possuem uma glândula de cuspir fogo comumente encontrada em pessoas lagarto."
    icon = FA_ICON_FIRE

/datum/quirk/sparkle_aspect
    name = "Aspecto de Brilho (Emotes)"
    desc = "(Inato Mariposa) Brilhe como o pó das asas de uma mariposa, ou como um encontro barato em um bordel. (Diga *turf para lançar)"
    value = 0
    mob_trait = TRAIT_SPARKLE_ASPECT
    gain_text = span_notice("Você está coberto de pó brilhante!")
    lose_text = span_danger("De alguma forma, você se limpou completamente do glitter..")
    medical_record_text = "O paciente parece estar fabuloso."
    icon = FA_ICON_HAND_SPARKLES

/datum/quirk/no_appendix
    name = "Sobrevivente de Apendicite"
    desc = "Você teve um encontro com apendicite no passado e não tem mais apêndice."
    icon = FA_ICON_NOTES_MEDICAL
    value = 2
    gain_text = span_notice("Você não tem mais apêndice.")
    lose_text = span_danger("Seu apêndice magicamente... cresceu novamente?")
    medical_record_text = "O paciente teve apendicite no passado e teve seu apêndice removido cirurgicamente."
    /// O apêndice original do mob
    var/obj/item/organ/appendix/old_appendix

/datum/quirk/no_appendix/post_add()
    var/mob/living/carbon/carbon_quirk_holder = quirk_holder
    old_appendix = carbon_quirk_holder.get_organ_slot(ORGAN_SLOT_APPENDIX)

    if(isnull(old_appendix))
        return

    old_appendix.Remove(carbon_quirk_holder, special = TRUE)
    old_appendix.moveToNullspace()

    STOP_PROCESSING(SSobj, old_appendix)

/datum/quirk/no_appendix/remove()
    var/mob/living/carbon/carbon_quirk_holder = quirk_holder

    if(isnull(old_appendix))
        return

    var/obj/item/organ/appendix/current_appendix = carbon_quirk_holder.get_organ_slot(ORGAN_SLOT_APPENDIX)

    // se não ganhamos um apêndice novo, coloque o antigo de volta
    if(isnull(current_appendix))
        old_appendix.Insert(carbon_quirk_holder, special = TRUE)
    else
        qdel(old_appendix)

    old_appendix = null

/datum/quirk/sensitive_hearing // Audição Teshari, mas como uma peculiaridade
    name = "Audição Sensível"
    desc = "Você pode ouvir até os sons mais baixos, mas é mais vulnerável a danos auditivos como resultado. NOTA: Isso é uma desvantagem direta para Teshari!"
    icon = FA_ICON_HEADPHONES_SIMPLE
    value = 6
    gain_text = span_notice("Você poderia ouvir um alfinete cair a 3 metros de distância.")
    lose_text = span_danger("Sua audição parece menos sensível.")
    medical_record_text = "O paciente obteve pontuações muito altas em testes auditivos."

    var/obj/item/organ/ears/old_ears // As orelhas originais do mob, apenas por precaução.
    var/obj/item/organ/ears/sensitive/sensitive_ears = new /obj/item/organ/ears/sensitive // As orelhas substitutas.

/datum/quirk/sensitive_hearing/post_add()
    var/mob/living/carbon/carbon_quirk_holder = quirk_holder
    old_ears = carbon_quirk_holder.get_organ_slot(ORGAN_SLOT_EARS)

    if(!isnull(old_ears))
        old_ears.Remove(carbon_quirk_holder, special = TRUE)
        old_ears.moveToNullspace()
        STOP_PROCESSING(SSobj, old_ears)

    sensitive_ears.Insert(carbon_quirk_holder, special = TRUE)

/datum/quirk/sensitive_hearing/remove()
    var/mob/living/carbon/carbon_quirk_holder = quirk_holder
    var/obj/item/organ/ears/current_ears = carbon_quirk_holder.get_organ_slot(ORGAN_SLOT_EARS)

    if(isnull(old_ears)) // Faça novas orelhas genéricas se as originais estiverem faltando
        old_ears = new /obj/item/organ/ears

    // Retorne as orelhas originais.
    if(!isnull(current_ears))
        current_ears.Remove(carbon_quirk_holder, special = TRUE)
        qdel(current_ears)

    old_ears.Insert(carbon_quirk_holder, special = TRUE)
    old_ears = null
