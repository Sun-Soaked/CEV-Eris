//deprecated vars(phase out)
GLOBAL_VAR_INIT(bluespace_hazard_threshold, 150)
GLOBAL_VAR_INIT(bluespace_entropy, 0)
GLOBAL_VAR_INIT(bluespace_gift, 0)
GLOBAL_VAR_INIT(bluespace_distotion_cooldown, 10 MINUTES)

//flags used to get bluespace events for distortion
//thresholds
#define	BLUESPACE_EVENT_FAINT	1
#define	BLUESPACE_EVENT_GLOWING	2
#define	BLUESPACE_EVENT_SHIMMERING 4
#define	BLUESPACE_EVENT_LUMINOUS 8
#define BLUESPACE_EVENT_RADIANT 16
#define BLUESPACE_EVENT_BLINDING 32//technically not a real 'threshold' but radiant needs an upscale for major events
//type tags
///living mobs are spawned by the event
#define BLUESPACE_EVENT_ENTITY 64
///a physical object is spawned by the event
#define BLUESPACE_EVENT_ANOMALY 128
///an affect processed in perpetuity on the area/till the event datum concludes
#define BLUESPACE_EVENT_FIELD 256

//entropy threshold defines for different types of entropic event
#define ENTROPY_LEVEL_TRACE 25 //No bluespace event, area will begin to indicate it has entropy
#define ENTROPY_LEVEL_FAINT 50 //rare minor bluespace events, basically a warning tier
#define ENTROPY_LEVEL_GLOWING 100 //more common minor bluespace events, annoying tier
#define ENTROPY_LEVEL_SHIMMERING 200 //some more significant bluespace events, starts to become haunted
#define ENTROPY_LEVEL_LUMINOUS 300 //common bluespace events from a mix of danger levels, area becomes actively hazardous
#define ENTROPY_LEVEL_RADIANT 400 //frequent dangerous bluespace events, area is actively hostile to continued habitation

///the initial entropy decay in ship areas, before sources of entropy & entropy reduction contribute their stuff
#define ENTROPY_BASE_ACTIVITY -0.25
///the initial chance of an entropy distortion in a given area each entropy tick, affected by chaos level
#define ENTROPY_BASE_DISTORTCHANCE 0.5

//global bluespace defines
///The level at which entropy in an area starts to 'bleed' into global entropy, contributing to possible ship-wide blueout
#define ENTROPY_BLEED_THRESHOLD ENTROPY_LEVEL_SHIMMERING
///The base activity of global entropy each tick(before modifiers are applied)
#define ENTROPY_GLOBAL_DECAY -0.025
///The base amnt. of entropy added to global entropy for each bleeding zone. amplified by local entropy & chaos level
#define ENTROPY_GLOBAL_BLEED 0.01
///The level at which the scale of euclid starts transmitting automated warning announcements of imminent blueout risk
#define ENTROPY_GLOBAL_WARN 175
///The level at which global entropy begins to trigger 'blueouts'; catastrophic ship-wide bluespace events
#define ENTROPY_GLOBAL_BLUEOUT 215

//entropy levels of atoms. fed to per-ssentropy tick accumulation on local areas
//for reality stabilizer(stops all positive entropy gain, then continuously reduces entropy by this value)
#define ATOM_ENTROPY_DISTRUPT -2.5
//for atoms which are currently providing active entropy suppression(like active obelisks)
#define ATOM_ENTROPY_ACTIVE_SUPPRESSION -0.5
//for atoms which passively chip away at entropy slightly(like cruciformed humans, some church items like lit candles)
#define ATOM_ENTROPY_SUPPRESSION -0.25
//for atoms with weak bluespace activity. Unable to overcome normal entropy decay unless stacked heavily
#define ATOM_ENTROPY_MURMUR 0.25
//for generic bluespace-generating atoms & atoms with contamination
#define ATOM_ENTROPY_SONG 0.5
//for atoms which can singlehandledly(if slowly) cause contamination buildup
#define ATOM_ENTROPY_CHORUS 1
//for atoms which are intended to singlehandedly cause dangerous accumulation quickly(like bluespace obelisks)
#define ATOM_ENTROPY_CACOPHANY 2.5
//used for extremely rapid & dangerous buildup(generally short term)
#define ATOM_ENTROPY_SCREAM 5
//the max value of local per-atom entropy contamination
#define MAX_ATOM_ENTROPY 100
