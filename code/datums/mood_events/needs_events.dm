//nutrition
/datum/mood_event/fat
	description = "<B>Estou tão gordo...</B>" //muh fatshaming
	mood_change = -6

/datum/mood_event/too_wellfed
	description = "Acho que comi de mais."
	mood_change = 0

/datum/mood_event/wellfed
	description = "Estou cheio!"
	mood_change = 8

/datum/mood_event/fed
	description = "Recentemente eu comi algo."
	mood_change = 5

/datum/mood_event/hungry
	description = "Estou ficando um pouco faminto."
	mood_change = -6

/datum/mood_event/starving
	description = "Estou FAMINTO!"
	mood_change = -10

//charge
/datum/mood_event/supercharged
	description = "Eu não posso manter toda essa energia dentro de mim, preciso liberar um pouco rápido!"
	mood_change = -10

/datum/mood_event/overcharged
	description = "Eu me sinto perigosamente sobrecarregado, talvez eu devesse liberar um pouco de energia."
	mood_change = -4

/datum/mood_event/charged
	description = "Eu sinto a energia dentro de minhas veias!"
	mood_change = 6

/datum/mood_event/lowpower
	description = "Minha energia está baixa, Eu deveria recarregar em algum lugar."
	mood_change = -6

/datum/mood_event/decharged
	description = "Eu estou desesperadamente precisando de eletricidade!"
	mood_change = -10

//Disgust
/datum/mood_event/gross
	description = "Eu vi algo nojento."
	mood_change = -4

/datum/mood_event/verygross
	description = "Acho que vou vomitar..."
	mood_change = -6

/datum/mood_event/disgusted
	description = "Oh Deus, isso é nojento..."
	mood_change = -8

/datum/mood_event/disgust/bad_smell
	description = "Eu consigo sentir o cheiro de algo horrivelmente apodrecido dentro desta sala."
	mood_change = -6

/datum/mood_event/disgust/nauseating_stench
	description = "O fedor de carcaças podres é insuportável!"
	mood_change = -12

/datum/mood_event/disgust/dirty_food
	description = "Aquilo estava muito sujo para comer..."
	mood_change = -6
	timeout = 4 MINUTES

//Generic needs events
/datum/mood_event/shower
	description = "Recentemente eu tive um ótimo banho."
	mood_change = 4
	timeout = 5 MINUTES

/datum/mood_event/shower/add_effects(shower_reagent)
	if(istype(shower_reagent, /datum/reagent/blood))
		if(HAS_TRAIT(owner, TRAIT_MORBID) || HAS_TRAIT(owner, TRAIT_EVIL) || (owner.mob_biotypes & MOB_UNDEAD))
			description = "The sensation of a lovely blood shower felt good."
			mood_change = 6 // you sicko
		else
			description = "I have recently had a horrible shower raining blood!"
			mood_change = -4
			timeout = 3 MINUTES
	else if(istype(shower_reagent, /datum/reagent/water))
		if(HAS_TRAIT(owner, TRAIT_WATER_HATER) && !HAS_TRAIT(owner, TRAIT_WATER_ADAPTATION))
			description = "I hate being wet!"
			mood_change = -2
			timeout = 3 MINUTES
		else
			return // just normal clean shower
	else // it's dirty ass water
		description = "I have recently had a dirty shower!"
		mood_change = -3
		timeout = 3 MINUTES

/datum/mood_event/hot_spring
	description = "It's so relaxing to bathe in steamy water..."
	mood_change = 5

/datum/mood_event/hot_spring_hater
	description = "No, no, no, no, I don't want to take a bath!"
	mood_change = -2

/datum/mood_event/hot_spring_left
	description = "That was an enjoyable bath."
	mood_change = 4
	timeout = 4 MINUTES

/datum/mood_event/hot_spring_hater_left
	description = "I hate baths! And I hate how cold it's once you step out of it!"
	mood_change = -3
	timeout = 2 MINUTES

/datum/mood_event/fresh_laundry
	description = "There's nothing like the feeling of a freshly laundered jumpsuit."
	mood_change = 2
	timeout = 10 MINUTES

/datum/mood_event/surrounded_by_silicon
	description = "I'm surrounded by perfect lifeforms!!"
	mood_change = 8

/datum/mood_event/around_many_silicon
	description = "So many silicon lifeforms near me!"
	mood_change = 4

/datum/mood_event/around_silicon
	description = "The silicon lifeforms near me are absolutely perfect."
	mood_change = 2

/datum/mood_event/around_organic
	description = "The organics near me remind me of the inferiority of flesh."
	mood_change = -2

/datum/mood_event/around_many_organic
	description = "So many disgusting organics!"
	mood_change = -4

/datum/mood_event/surrounded_by_organic
	description = "I'm surrounded by disgusting organics!!"
	mood_change = -8

/datum/mood_event/completely_robotic
	description = "I've abandoned my feeble flesh, my form is perfect!!"
	mood_change = 8

/datum/mood_event/very_robotic
	description = "I'm more robot than organic!"
	mood_change = 4

/datum/mood_event/balanced_robotic
	description = "I'm part machine, part organic."
	mood_change = 0

/datum/mood_event/very_organic
	description = "I hate this feeble and weak flesh!"
	mood_change = -4

/datum/mood_event/completely_organic
	description = "I'm completely organic, this is miserable!!"
	mood_change = -8
