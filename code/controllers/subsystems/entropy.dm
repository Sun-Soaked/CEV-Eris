/*
	The entropy subsystem handles the simulation of Bluespace Entropy- the gradual decay of the veil between the
	Simulacrum and Realspace, caused by simulacrum activity.

	A local entropy condition is stored on each area, and determines the type and frequency of local bluespace events triggered
	In that area

	Global Entropy is stored here & is tallied based on the total number of areas above the entropy bleed threshold
	When above a certain threshold, 'blueout' weather is periodically triggered, which causes chaotic bluespace events
	to happen all across the ship.

	TODO:
	-scale of euclid(monitors bluespace entropy levels, techno relic)
	-relics(items with ambient bluespace entropy), obtrusions(bluespace anomalies), bluespace horrors
	-annoying & harmless bluespace events (area becomes blue filtered, lights flicker, some tiles become temporarily scrambled, etc.)
	-bluespace sprite effects (tying peoples shoes together, hallucinations, stealing items, etc.)
	-Reality Stabilizes(techno machine that reduces entropy over time)
	-Church ritual that triggers a dangerous event in exchange for immediately dropping entropy (exorcism? cleanse?)
	-Obelisks slowly drain entropy in their area
	-Storyteller events that cause entropy to build up around certain important ship obj (bluespace drive, grav gen)
	-Storyteller event that spawns in bluespace entropy-causing objects
	-Killing bluespace mobs & destroying entropic objects drains entropy slightly

	-some rarer bluespace mobs should be extremely resistant to normal dmg and only killable with psionics(coming 2022) & church magic
	-all bluespace mobs should take sanity attacks as normal dmg(so sanity gun is a potential tool against them, etc.)

	Ideas I will not implement(but would be neat):
	-Have a catastrophic round-end effect for extremely high global entropy
*/
SUBSYSTEM_DEF(entropy)
	name = "Entropy"

	init_order = INIT_ORDER_LATELOAD
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME

	wait = 3 SECONDS

	///list of atoms we should be processing contamination on
	var/list/contaminated = list()

	///used for area firing cache
	var/list/currentrun = list()

	///the global version of bluespace entropy. Tallied from local entropy conditions
	var/global_entropy

	//todo: do these
	///a ref to a unique oddity that gives random people the ability to check bluespace entropy lvl.
	var/bluespace_gift
	///a ref to a unique faction obj that relays info on the entropy status of the ship
	var/euclids_scale

	///base cooldown for global "blueouts" cased by high total entropy
	var/base_blueout_interval = 25 MINUTES
	///reference to next blueout time (generated actively by base interval + chaos level, some rng)
	var/next_blueout = null

	///Ref which stores areas that are ready to invoke an entropy event. from which ~1-3 are picked for invoking an entropy event
	var/list/distortcandidates = list()

	///Ref containing areas which are currently bleeding bluepaces to global entropy
	var/list/bleeding_zones = list()

	///Pool compiled at init which keeps track of all possible distortion events
	var/list/distortion_pool = list()

	///sanity cd to prevent the game chugging out ssevent by running a bajillion entropy events in a few seconds
	var/global_distortion_cd

	// ///interval for checking the bluespace entropy effect over time of areas by caching their contents(expensive)
	// var/scan_interval = 1 MINUTE
	// ///next entropy scan
	// var/next_scan

/datum/controller/subsystem/entropy/Initialize()
	// 	next_scan = world.time + scan_interval

	// Set up our main distortion pool for later
	for(var/event in subtypesof(/datum/event/distortion))
		var/datum/event/distortion/devent = event
		if(devent.enabled)
			distortion_pool += new devent
	.=..()

/datum/controller/subsystem/entropy/fire(resumed = FALSE)
	// var/scan_areas
	// if (world.time >= next_scan)
	// 	next_scan = world.time + scan_interval
	// 	scan_areas = true
	var/list/currentcontam = list()
	//resets our run if it was cleared of items successfully
	//(retaining run till completion allows us to dynamically resume previous runs if subsystem is paused and resumed)
	if(!currentrun)
		currentrun = GLOB.ship_areas.Copy()
		currentcontam = contaminated.Copy()
		distortcandidates.Cut()
		bleeding_zones.Cut()
	//iterate through areas ship areas, processing their entropy.
	var/list/currentruncache = currentrun //caching in a ref this does something apparently
	while(currentruncache)
		var/area/ourarea = currentruncache[currentruncache.len]
		currentruncache.len--

		//process area entropy
		process_entropy(ourarea)

		//also if it's really yucked up with bluespace, add it to entropy bleedout
		if(ourarea.bluespace_entropy >= ENTROPY_BLEED_THRESHOLD)
			bleeding_zones += ourarea

	//process global entropy below
	//anything above ~2 or 3 bleeding areas with decent entropy will cause positive entropy growth
	var/tick_entropy = ENTROPY_GLOBAL_DECAY
	for(var/area/bleeder as anything in bleeding_zones)
		tick_entropy += (ENTROPY_GLOBAL_BLEED * (1 + (bleeder.bluespace_entropy / 300))) * (GLOB.chaos_level > 1 ? GLOB.chaos_level / 2 : 1)

	//only run if there is global entropy to remove or entropy change is a positive integer
	if(global_entropy || tick_entropy >= 0)
		global_entropy = max(0, (global_entropy + min(tick_entropy, 0.5)))

	//process danger zone stuff
	if(global_entropy >= ENTROPY_GLOBAL_WARN)
		//todo: try to ping the scale of euclid
		if(global_entropy >= ENTROPY_GLOBAL_BLUEOUT)//if you let global entropy get out of control
			if(!next_blueout)
				next_blueout = world.time + ((base_blueout_interval / GLOB.chaos_level))
			else if(next_blueout <= world.time)//and then let time pass with it in overload
				blueout()//bad things happen
			return
		//if we're below blueout level, clear blueout delay for next usage
		next_blueout = null

	//now do atom contamination
	for(var/atom/yucky as anything in currentcontam)
		if(yucky.bluespace_entropy && !iscarbon(yucky))
			process_contamination(yucky)
		else//if it shouldn't be processed anymore, chuck it from our list for future fires
			contaminated.Remove(yucky)

///handles entropy ticking on individual areas
/datum/controller/subsystem/entropy/proc/process_entropy(/area/ourarea)
	//update our area's entropy & get vars
	ourarea.redraw_entropy()
	var/area_entropy_activity = ourarea.entropic_affect
	var/area_bluespace_entropy = ourarea.bluespace_entropy
	//run if we have active bluespace entropy, or entropy activity will increase entropy
	if(area_bluespace_entropy  || area_entropy_activity > 0)
		area_bluespace_entropy = max(0, area_bluespace_entropy + (area_entropy_activity * get_entropic_mod(ourarea, FALSE)))
		//roll for possible distortion
		if(global_distortion_cd <= world.time && area_bluespace_entropy > ENTROPY_LEVEL_FAINT)
			var/rand_value = ENTROPY_BASE_DISTORTCHANCE * get_entropic_mod(ourarea)
			if(prob(rand_value) && ourarea.local_distort_cd <= world.time)
				//apply cd's and cast distortion to area
				ourarea.local_distort_cd = world.time + (ourarea.local_distort_interval / get_entropic_mod(ourarea))
				global_distortion_cd = world.time + 1 MINUTES
				var/major_chance = (rand_value / 4)
				ourarea.attempt_distortion(major_chance)


///returns a distortion event based on distortion rarity & supplied flags
/datum/controller/subsystem/entropy/proc/get_distortion(event_flags)
	//var/list/datum/event/distortion/globalpool = distortion_pool
	if(!LAZYLEN(distortion_pool))//how was this even called before init?
		return

	var/list/datum/event/distortion/ourpool = list()
	//compile viable events from global pool to our local one
	for(var/datum/event/distortion/ourdistortion as anything in distortion_pool)
		var/passed = TRUE

		//check whether event has the required flags.
		for(var/flag as anything in event_flags)
			if(!ourdistortion.flags & flag)
				passed = FALSE
		if(!passed)//if not, go back and get the next event
			continue

		//passed vibe check. stick into our new pool
		ourpool += ourdistortion
		ourpool[ourdistortion] = ourdistortion.rarity
	//when it's all done, let's grab an event from the pool based on event rarity
	return pickweight(ourpool)

///returns a mult based on area bluespace entropy & chaos level. increases by .25% for each 100 of entropy or 1 lvl. of chaos level
/datum/controller/subsystem/entropy/proc/get_entropic_mod(/area/ourarea, use_entropy = TRUE, use_chaos = TRUE)
	var/ourmult = 0
	if(use_entropy)
		ourmult = (1 + (ourarea.bluespace_entropy / 400))
	if(use_chaos)
		ourmult = ourmult * (1 + ((GLOB.chaos_level - 1) / 4))
	return ourmult

///ticks down contamination on contaminated atoms each ssentropy tick until it reaches zero. When it reaches zero, remove entropy from atom
/datum/controller/subsystem/entropy/proc/process_contamination(/atom/yucky)

	if(yucky.bluespace_entropy <= 0)
		yucky.entropic_affect = null
		contaminated.Remove(yucky)
		return

	//experiment: multiplier removal w. extra little bit to make sure last bit gets removed
	yucky.bluespace_entropy = (yucky.bluespace_entropy * 0.95) - 0.05

	if(!yucky.entropy_constant)
		yucky.entropy_affect = determine_entropy_affect(yucky)

///sets up the entropy effect of an object conditional to it's contamination
///alongside conditional effects of different entropy levels
/datum/controller/subsystem/entropy/proc/determine_entropy_affect(atom/yucky)
	yucky.entropy_affect = ATOM_ENTROPY_MURMUR
	if(yucky.bluespace_entropy > ENTROPY_LEVEL_TRACE)
		yucky.entropy_affect = ATOM_ENTROPY_SONG
		//something something add v. faint wibbly blue overlay(that only psychic vision can see? Potential psy plane content
		if(yucky.bluespace_entropy > ENTROPY_LEVEL_FAINT)
			//effect gets brighter
			//create a bit of faint visible light? To warn nearby people there's a psychic chernobyl happening
			yucky.entropy_affect = ATOM_ENTROPY_CHORUS

///Causes a horrible bluespace-enroaching fate to befall the ship
/datum/controller/subsystem/entropy/proc/blueout()
//todo: blueout
