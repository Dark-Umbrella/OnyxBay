/datum/ai_emotion
	var/overlay
	var/ckey

/datum/ai_emotion/New(over, key)
	overlay = over
	ckey = key

var/list/ai_status_emotions = list(
	"Very Happy" 				= new /datum/ai_emotion("ai_veryhappy"),
	"Happy" 					= new /datum/ai_emotion("ai_happy"),
	"Neutral" 					= new /datum/ai_emotion("ai_neutral"),
	"Unsure" 					= new /datum/ai_emotion("ai_unsure"),
	"Confused" 					= new /datum/ai_emotion("ai_confused"),
	"Sad" 						= new /datum/ai_emotion("ai_sad"),
	"Surprised" 				= new /datum/ai_emotion("ai_surprised"),
	"Upset" 					= new /datum/ai_emotion("ai_upset"),
	"Angry" 					= new /datum/ai_emotion("ai_angry"),
	"BSOD" 						= new /datum/ai_emotion("ai_bsod"),
	"Blank" 					= new /datum/ai_emotion("ai_off"),
	"Problems?" 				= new /datum/ai_emotion("ai_trollface"),
	"Awesome" 					= new /datum/ai_emotion("ai_awesome"),
	"Dorfy" 					= new /datum/ai_emotion("ai_urist"),
	"Facepalm" 					= new /datum/ai_emotion("ai_facepalm"),
	"Friend Computer" 			= new /datum/ai_emotion("ai_friend"),
	"Tribunal" 					= new /datum/ai_emotion("ai_tribunal", "serithi"),
	"Tribunal Malfunctioning"	= new /datum/ai_emotion("ai_tribunal_malf", "serithi"),
	"Ship Scan" 				= new /datum/ai_emotion("ai_shipscan")
	)

/proc/get_ai_emotions(ckey)
	var/list/emotions = new
	for(var/emotion_name in ai_status_emotions)
		var/datum/ai_emotion/emotion = ai_status_emotions[emotion_name]
		if(!emotion.ckey || emotion.ckey == ckey)
			emotions += emotion_name

	return emotions

/proc/set_ai_status_displays(mob/user)
	var/list/ai_emotions = get_ai_emotions(user.ckey)
	var/emote = input("Please, select a status!", "AI Status", null, null) in ai_emotions
	for (var/obj/machinery/M in GLOB.ai_status_display_list) //change status
		if(istype(M, /obj/machinery/ai_status_display))
			var/obj/machinery/ai_status_display/AISD = M
			AISD.emotion = emote
			AISD.update_icon()
		//if Friend Computer, change ALL displays
		else if(istype(M, /obj/machinery/status_display))

			var/obj/machinery/status_display/SD = M
			if(emote=="Friend Computer")
				SD.friendc = 1
			else
				SD.friendc = 0

/obj/machinery/ai_status_display
	icon = 'icons/obj/status_display.dmi'
	icon_state = "frame"
	name = "AI display"
	anchored = TRUE
	density = FALSE
	layer = ABOVE_WINDOW_LAYER

	var/mode = 0	// 0 = Blank
					// 1 = AI emoticon
					// 2 = Blue screen of death

	var/picture_state	// icon_state of ai picture

	var/emotion = "Neutral"
	var/image/picture = null
	var/image/picture_overlight = null
	var/image/static_overlay = null

/obj/machinery/ai_status_display/Initialize()
	. = ..()
	GLOB.ai_status_display_list += src

	if(!picture)
		picture = image('icons/obj/status_display.dmi', icon_state = "blank")

	if(!picture_overlight)
		picture_overlight = image('icons/obj/status_display.dmi', icon_state = "blank")
		picture_overlight.alpha = 96
		picture_overlight.plane = EFFECTS_ABOVE_LIGHTING_PLANE
		picture_overlight.layer = ABOVE_LIGHTING_LAYER

	if(!static_overlay)
		static_overlay = image('icons/obj/status_display.dmi', icon_state = "static")
		static_overlay.plane = EFFECTS_ABOVE_LIGHTING_PLANE
		static_overlay.layer = ABOVE_LIGHTING_LAYER

/obj/machinery/ai_status_display/Destroy()
	GLOB.ai_status_display_list -= src
	overlays.Cut()
	QDEL_NULL(picture)
	QDEL_NULL(picture_overlight)
	QDEL_NULL(static_overlay)
	return ..()

/obj/machinery/ai_status_display/attack_ai/(mob/user)
	var/list/ai_emotions = get_ai_emotions(user.ckey)
	var/emote = input("Please, select a status!", "AI Status", null, null) in ai_emotions
	src.emotion = emote

/obj/machinery/ai_status_display/Process()
	return

/obj/machinery/ai_status_display/update_icon()
	if(stat & (NOPOWER|BROKEN))
		overlays.Cut()
		return

	switch(mode)
		if(0) //Blank
			overlays.Cut()
			picture_state = ""
		if(1) // AI emoticon
			var/datum/ai_emotion/ai_emotion = ai_status_emotions[emotion]
			set_picture(ai_emotion.overlay)
		if(2) // BSOD
			set_picture("ai_bsod")

/obj/machinery/ai_status_display/proc/set_picture(state)
	if(picture_state == state)
		return

	if(state == "ai_off")
		mode = 0
		update_icon()
		return

	picture_state = state
	overlays.Cut()

	picture.icon_state = picture_state
	picture_overlight.icon_state = picture_state

	overlays += picture
	overlays += picture_overlight
	overlays += static_overlay
