// Species trait debuffs
/datum/mood_event/dry_skin
	description = "Minha pele parece terrivelmente seca...\n"
	mood_change = -2

// Surgery mood debuffs
/datum/mood_event/mild_surgery
	description = "Mesmo que eu não pudesse me sentir a maior parte, parece errado estar acordado enquanto alguém trabalha em seu corpo. Ugh!\n"
	mood_change = -1
	timeout = 5 MINUTES

/datum/mood_event/severe_surgery
	description = "Espero... ELES ME ABRIRAM - E EU SENTI CADA SEGUNDO DISSO!\n"
	mood_change = -4
	timeout = 15 MINUTES

/datum/mood_event/robot_surgery
	description = "Ter minhas partes robóticas mexidas enquanto eu estava consciente parece tão errado ... se eu tivesse um modo de suspensão!\n"
	mood_change = -4
	timeout = 10 MINUTES
