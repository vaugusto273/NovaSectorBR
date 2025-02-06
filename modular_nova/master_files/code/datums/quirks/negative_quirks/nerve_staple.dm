/datum/quirk/equipping/nerve_staple
    name = "Trava-Nervosa"
    desc = "Você é um pacifista. Não porque você quer ser, mas por causa do dispositivo grampeado em seu olho."
    value = -10 // pacifismo = -8, perder slots de olho = -2
    gain_text = span_danger("Você de repente não consegue levantar a mão para machucar os outros!")
    lose_text = span_notice("Você acha que pode se defender novamente.")
    medical_record_text = "O paciente tem uma Trava-Nervosa e é incapaz de ferir os outros."
    icon = FA_ICON_FACE_ANGRY
    forced_items = list(/obj/item/clothing/glasses/nerve_staple = list(ITEM_SLOT_EYES))
    /// O grampo nervoso anexado à peculiaridade
    var/obj/item/clothing/glasses/nerve_staple/staple

/datum/quirk/equipping/nerve_staple/on_equip_item(obj/item/equipped, successful)
    if (!istype(equipped, /obj/item/clothing/glasses/nerve_staple))
        return
    staple = equipped

/datum/quirk/equipping/nerve_staple/remove()
    . = ..()
    if (!staple || staple != quirk_holder.get_item_by_slot(ITEM_SLOT_EYES))
        return
    to_chat(quirk_holder, span_warning("A Trava-Nervosa de repente cai do seu rosto e derrete[istype(quirk_holder.loc, /turf/open/floor) ? " no chão" : ""]!"))
    qdel(staple)
