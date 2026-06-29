/proc/go_to_bluespace(turf/T, entropy = 1, isglobal, ateleatom, adestination, aprecision = 0, afteleport = 1, aeffectin, aeffectout, asoundin, asoundout, no_checks = FALSE)
	bluespace_entropy(entropy, ateleatom, isglobal)
	do_teleport(ateleatom, adestination, aprecision, afteleport, aeffectin, aeffectout, asoundin, asoundout, no_checks)

///boilerplate that hands off entropy gain to whichever type proc makes sense.
/proc/bluespace_entropy(value, atom/target, isglobal)
	//global instead feeds directly to global entropy
	if(isglobal)
		SSentropy.global_entropy = max(0, SSentropy.global_entropy + value)
		return

	//if it's an area, just write it directly to entropy
	if(istype(target, /area))
		target.add_area_entropy(value)
	else//otherwise, contaminate the atom
		target.contaminate(value)

// /proc/bluespace_distorsion(turf/T, minor_distortion=FALSE)
// 	var/bluespace_event = rand(1, 100)
// 	switch(bluespace_event)
// 		if(1 to 30)
// 			trash_buble(T, minor_distortion)
// 		if(30 to 55)
// 			bluespace_roaches(T, minor_distortion)
// 		if(55 to 75)
// 			bluespace_stranger(T, minor_distortion)
// 		if(75 to 90)
// 			bluespace_cristals_event(T, minor_distortion)
// 		if(90 to 100)
// 			bluespace_gift(T, minor_distortion)


/proc/bluespace_cristals_event(turf/T, minor_distortion)
	var/list/areas = list()
	var/area/A = get_area(T)
	var/distortion_amount = 1
	var/amount = rand(2,3)
	if(A && !minor_distortion)
		areas = list(A)
		if(A in GLOB.ship_areas)
			areas = GLOB.ship_areas.Copy()
			distortion_amount = rand(2,3)
	for(var/j = 1 to distortion_amount)
		var/turf/Ttarget = T
		if(areas.len)
			A = pick(areas)
			var/turf/Ttarget2 = A.random_space()
			if(Ttarget2)
				Ttarget = Ttarget2
		for(var/i=1 to amount)
			Ttarget = get_random_secure_turf_in_range(Ttarget, 4)
			if(Ttarget)
				new /obj/structure/bs_crystal_structure(Ttarget)
				do_sparks(3, 0, Ttarget)

/proc/bluespace_gift(turf/T, minor_distortion)
	var/second_gift = rand(2,10)
	var/area/A = get_area(T)
	if(A && !minor_distortion)
		if(A in GLOB.ship_areas)
			A = pick(GLOB.ship_areas)
	if(A)
		var/turf/newT = A.random_space()
		if(newT)
			T = newT
	T = get_random_secure_turf_in_range(T, 4)
	if(!T)
		return
	if(GLOB.bluespace_gift <= 0 && !minor_distortion)
		new /obj/item/oddity/broken_necklace(T)
		do_sparks(3, 0, T)
		log_and_message_admins("Bluespace gif spawned: [jumplink(T)]") //unique item
	else
		second_gift *= 10
	if(prob(second_gift))
		var/obj/O = pickweight(RANDOM_RARE_ITEM - /obj/item/stash_spawner)
		new O(T)
		do_sparks(3, 0, T)

/proc/bluespace_stranger(turf/T, minor_distortion)
	var/area/A = get_area(T)
	if(A)
		if(!minor_distortion && (A in GLOB.ship_areas))
			A = pick(GLOB.ship_areas)
		var/turf/newT = A.random_space()
		if(newT)
			T = newT
	T = get_random_secure_turf_in_range(T, 4)
	var/mob/living/simple_animal/hostile/stranger/S = new (T)
	if(minor_distortion && prob(95))
		S.maxHealth = S.maxHealth/1.5
		S.health = S.maxHealth
		S.empy_cell = TRUE
	log_and_message_admins("Stranger spawned: [jumplink(T)]")

/proc/bluespace_roaches(turf/T, minor_distortion)
	var/list/areas = list()
	var/area/A = get_area(T)
	var/distortion_amount = 1
	var/amount = rand(5,12)
	if(A && !minor_distortion)
		areas = list(A)
		if(A in GLOB.ship_areas)
			areas = GLOB.ship_areas.Copy()
			distortion_amount = rand(2,4)
	for(var/j = 1; j <= distortion_amount; j++)
		var/turf/Ttarget = get_random_secure_turf_in_range(T, 4)
		if(areas.len)
			A = pick(areas)
			var/turf/Ttarget2 = A.random_space()
			if(Ttarget2)
				Ttarget = get_random_secure_turf_in_range(Ttarget2, 4)
		for(var/i=1; i<=amount; i++)
			if(Ttarget)
				new /mob/living/carbon/superior_animal/roach/bluespace(Ttarget)

/proc/trash_buble(turf/T, minor_distortion)
	var/list/areas = list()
	var/area/A = get_area(T)
	var/distortion_amount = 1
	var/amount = rand(25, 50)
	if(A && !minor_distortion)
		areas = list(A)
		if(A in GLOB.ship_areas)
			areas = GLOB.ship_areas.Copy()
			distortion_amount = rand(2, 8)
	for(var/j = 1; j <= distortion_amount; j++)
		var/turf/Ttarget = T
		if(areas.len)
			A = pick(areas)
			var/turf/Ttarget2 = A.random_space()
			if(Ttarget2)
				Ttarget = Ttarget2
		for(var/i = 1; i <= amount; i++)
			Ttarget = get_random_secure_turf_in_range(Ttarget, 5)
			if(Ttarget)
				new /obj/spawner/junk(Ttarget)
				do_sparks(3, 0, Ttarget)


///effect which visibly warps space around a location and gives every nearby atom bluespace entropy
/proc/bluespace_surge(turf/target, range = 2, strength = 15)
	if(!target)
		return
	//shockwave effect
	//get list of turfs in range
		//contaminate contents
		//chance to randomly tp contents
