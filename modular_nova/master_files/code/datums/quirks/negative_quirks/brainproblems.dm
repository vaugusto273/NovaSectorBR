// Renomeia os problemas cerebrais do TG para serem mais genéricos. Nunca houve um tumor de qualquer maneira!
/datum/quirk/item_quirk/brainproblems
    name = "Degeneração Cerebral"
    desc = "Você tem uma condição letal no seu cérebro que está lentamente destruindo-o. Melhor trazer um pouco de manitol!"
    medical_record_text = "O paciente tem uma condição letal no cérebro que está lentamente causando morte cerebral."
    icon = FA_ICON_BRAIN

// Substituição da peculiaridade Tumor Cerebral para espécies robóticas/sintéticas com cérebros positrônicos.
// Não aparece no TGUI ou na janela de preferências de personagem.
/datum/quirk/item_quirk/brainproblems/synth
    name = "Anomalia de Cascata Positrônica"
    desc = "Seu cérebro positrônico está lentamente se corrompendo devido a uma anomalia em cascata. Melhor trazer um pouco de solda líquida!"
    gain_text = "<span class='danger'>Você se sente com falhas.</span>"
    lose_text = "<span class='notice'>Você não se sente mais com falhas.</span>"
    medical_record_text = "O paciente tem uma anomalia em cascata no cérebro que está lentamente causando morte cerebral."
    icon = FA_ICON_BRAZILIAN_REAL_SIGN
    mail_goodies = list(/obj/item/storage/pill_bottle/liquid_solder/braintumor)
    hidden_quirk = TRUE

// Se brainproblems for adicionado a um synth, isso desvia para a peculiaridade brainproblems/synth.
// TODO: Adicionar mais desvios específicos do cérebro quando o PR #16105 for mesclado
/datum/quirk/item_quirk/brainproblems/add_to_holder(mob/living/new_holder, quirk_transfer, client/client_source)
    if(!issynthetic(new_holder) || type != /datum/quirk/item_quirk/brainproblems)
        // Deferir para os problemas cerebrais do TG se o personagem não for robótico.
        return ..()

    // TODO: Verificar o tipo de cérebro e desviar para a peculiaridade de problemas cerebrais apropriada
    var/datum/quirk/item_quirk/brainproblems/synth/bp_synth = new
    qdel(src)
    return bp_synth.add_to_holder(new_holder, quirk_transfer, client_source)

// Sintéticos recebem solda líquida com Tumor Cerebral em vez de manitol.
/datum/quirk/item_quirk/brainproblems/synth/add_unique(client/client_source)
    give_item_to_holder(
        /obj/item/storage/pill_bottle/liquid_solder/braintumor,
        list(
            LOCATION_LPOCKET = ITEM_SLOT_LPOCKET,
            LOCATION_RPOCKET = ITEM_SLOT_RPOCKET,
            LOCATION_BACKPACK = ITEM_SLOT_BACKPACK,
            LOCATION_HANDS = ITEM_SLOT_HANDS,
        ),
        flavour_text = "Isso vai mantê-lo vivo até que você possa garantir um suprimento de medicação. Não dependa muito deles!",
    )
