//Blueout occurs when the ship accumulates too much entropy.	 Very bad and nasty weather event
/datum/weather/blueout
	name = "blueout"
	desc = "The ship briefly skims through the top of bluespace, causing spacetime to boil violently with the release of uncontrolled energies"

	telegraph_duration = 25 SECONDS
	telegraph_message = span_danger("You feel a sense of growing unease..")
	telegraph_sound = 'sound/misc/alarm_siren.ogg'

	weather_message = span_userdanger("<i>The air boils and churns with impossible energies! Flee for your life!</i>")
	weather_overlay = "foamboil"
	weather_duration_lower = 0
	weather_duration_upper = 0
	weather_color = "#04045f"
	weather_sound = 'sound/misc/bloblarm.ogg'

	end_duration = 100
	end_message = span_notice("The world settles into comforting familiarity. It's over... for now.")

	area_type = /area
	//The church is protected by the angels.
	protected_areas = list(/area/eris/neotheology)

	immunity_type = "supernatural"//not implemented but
