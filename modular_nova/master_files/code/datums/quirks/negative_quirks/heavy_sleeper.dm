// re-adds heavy sleeper
/datum/quirk/heavy_sleeper
	name = "Dorminhoco"
	desc = "Você dorme como uma pedra! Sempre que você é colocado para dormir ou fica inconsciente, você demora um pouco mais para acordar."
	icon = FA_ICON_BED
	value = -2
	mob_trait = TRAIT_HEAVY_SLEEPER
	gain_text = span_danger("Você se sente sonolento.")
	lose_text = span_notice("Você se sente acordado novamente.")
	medical_record_text = "O paciente tem resultados anormais no estudo do sono e é difícil de acordar."
	hardcore_value = 2
	mail_goodies = list(
		/obj/item/clothing/glasses/blindfold,
		/obj/effect/spawner/random/bedsheet/any,
		/obj/item/clothing/under/misc/pj/red,
		/obj/item/clothing/head/costume/nightcap/red,
		/obj/item/clothing/under/misc/pj/blue,
		/obj/item/clothing/head/costume/nightcap/blue,
		/obj/item/pillow/random,
	)
