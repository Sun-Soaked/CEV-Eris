/proc/gibs(atom/location, var/datum/dna/MobDNA, gibber_type = /obj/effect/gibspawner/generic, var/fleshcolor, var/bloodcolor)
	new gibber_type(location,MobDNA,fleshcolor,bloodcolor)

/obj/effect/gibspawner
	var/sparks = 0 //whether sparks spread on Gib()
	var/virusProb = 20 //the chance for viruses to spread on the gibs
	var/list/gibtypes = list()
	var/list/gibamounts = list()
	var/list/gibdirections = list() //of lists
	var/fleshcolor //Used for gibbed humans.
	var/bloodcolor //Used for gibbed humans.

/obj/effect/gibspawner/Initialize(mapload, datum/dna/MobDNA, fleshcolor, bloodcolor)
	. = ..()

	if(gibtypes.len != gibamounts.len)
		stack_trace("Gib list amount length mismatch!")
		return
	if(gibamounts.len != gibdirections.len)
		stack_trace("Gib list dir length mismatch!")
		return

	if(fleshcolor)
		src.fleshcolor = fleshcolor
	if(bloodcolor)
		src.bloodcolor = bloodcolor

	if(sparks)
		var/datum/effect/effect/system/spark_spread/s = new
		s.set_up(2, 1, get_turf(loc)) // Not sure if it's safe to pass an arbitrary object to set_up, todo
		s.start()

	Gib(loc, MobDNA)

	return INITIALIZE_HINT_QDEL

/obj/effect/gibspawner/proc/Gib(atom/location, datum/dna/MobDNA = null)
	var/obj/effect/decal/cleanable/blood/gibs/gib = null

	for(var/i = 1, i<= gibtypes.len, i++)
		if(gibamounts[i])
			for(var/j = 1, j<= gibamounts[i], j++)
				var/gibType = gibtypes[i]
				gib = new gibType(location)

				// Apply human species colouration to masks.
				if(fleshcolor)
					gib.fleshcolor = fleshcolor
				if(bloodcolor)
					gib.basecolor = bloodcolor
				gib.update_icon()

				gib.blood_DNA = list()
				if(MobDNA)
					gib.blood_DNA[MobDNA.unique_enzymes] = MobDNA.b_type
				else if(istype(src, /obj/effect/gibspawner/human)) // Probably a monkey
					gib.blood_DNA["Non-human DNA"] = "A+"
				if(isturf(location))
					var/list/directions = gibdirections[i]
					if(directions.len)
						gib.streak(directions)
