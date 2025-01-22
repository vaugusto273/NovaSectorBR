/datum/quirk/narcolepsy
    name = "Narcolepsia"
    desc = "Você pode adormecer a qualquer momento e se sentir cansado frequentemente."
    icon = FA_ICON_CLOUD_MOON_RAIN
    value = -8
    hardcore_value = 8
    medical_record_text = "O paciente pode adormecer involuntariamente durante atividades normais."
    mail_goodies = list(
        /obj/item/reagent_containers/cup/glass/coffee,
        /obj/item/reagent_containers/cup/soda_cans/space_mountain_wind,
        /obj/item/storage/pill_bottle/prescription_stimulant,
    )

/datum/quirk/narcolepsy/post_add()
    . = ..()
    var/mob/living/carbon/human/user = quirk_holder
    user.gain_trauma(/datum/brain_trauma/severe/narcolepsy/permanent, TRAUMA_RESILIENCE_ABSOLUTE)

    var/obj/item/storage/medkit/civil_defense/comfort/stocked/stimmies = new()
    if(quirk_holder.equip_to_slot_if_possible(stimmies, ITEM_SLOT_BACKPACK, qdel_on_fail = TRUE, initial = TRUE, indirect_action = TRUE))
        to_chat(quirk_holder, span_info("Você recebeu um kit de suporte de sintomas emitido pela empresa contendo estimulantes leves para ajudar a permanecer acordado neste turno. Use com responsabilidade. Consulte seu provedor de cuidados alocado se você experimentar quaisquer efeitos colaterais."))

/datum/quirk/narcolepsy/remove()
    . = ..()
    var/mob/living/carbon/human/user = quirk_holder
    user?.cure_trauma_type(/datum/brain_trauma/severe/narcolepsy/permanent, TRAUMA_RESILIENCE_ABSOLUTE)

/datum/brain_trauma/severe/narcolepsy/permanent
    scan_desc = "narcolepsia"

// similar ao pai, mas mais lento
/datum/brain_trauma/severe/narcolepsy/permanent/on_life(seconds_per_tick, times_fired)
    if(owner.IsSleeping())
        return
    if(owner.reagents.has_reagent(/datum/reagent/medicine/modafinil))
        return // estimulante que já bloqueia o sono
    if(owner.reagents.has_reagent(/datum/reagent/medicine/synaptizine))
        return // estimulante leve facilmente feito na química

    var/sleep_chance = 0.333 //3
    var/drowsy = !!owner.has_status_effect(/datum/status_effect/drowsiness)
    var/caffeinated = HAS_TRAIT(owner, TRAIT_STIMULATED)
    if(drowsy)
        sleep_chance = 1
    if(caffeinated) // torna muito difícil adormecer com cafeína
        sleep_chance = sleep_chance / 2

    if(!drowsy && SPT_PROB(sleep_chance, seconds_per_tick))
        to_chat(owner, span_warning("Você se sente cansado..."))
        owner.adjust_drowsiness(rand(30 SECONDS, 60 SECONDS))

    else if(drowsy && SPT_PROB(sleep_chance, seconds_per_tick))
        to_chat(owner, span_warning("Você adormece."))
        owner.Sleeping(rand(20 SECONDS, 30 SECONDS))
