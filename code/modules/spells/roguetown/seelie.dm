/obj/effect/proc_holder/spell/invoked/seelie_dust
	name = "Seelie Dust"
	overlay_state = "createlight"
	releasedrain = 50
	charge_max = 150 SECONDS
	range = 7
	cast_without_targets = TRUE
	sound = 'sound/magic/churn.ogg'
	invocation_type = "none" //can be none, whisper, emote and shout

/obj/effect/proc_holder/spell/invoked/seelie_dust/cast(list/targets, mob/living/user)
	. = ..()
	user.emote("giggle")
	var/target = targets[1]
	if(isliving(target))
		var/obj/item/reagent_containers/powder/K = new /obj/item/reagent_containers/powder/SD(get_turf(target))
		K.reagents.trans_to(target, K.reagents.total_volume, transfered_by = user, method = "swallow")
		user.log_message("has drugged [key_name(target)] with Seelie dust", LOG_ATTACK)
		qdel(K)
	return TRUE

//Unfinished spells to be finished at a later date:
#if 0
/obj/effect/proc_holder/spell/targeted/static_room
	name = "Static"
	range = 12
	overlay_state = "necra"
	releasedrain = 30
	charge_max = 30 SECONDS
	max_targets = 0
	cast_without_targets = TRUE
	sound = 'sound/magic/churn.ogg'
	invocation = "*laugh"
	invocation_type = "none" //can be none, whisper, emote and shout

/obj/effect/proc_holder/spell/targeted/static_room/cast(list/targets, mob/user = usr)
	. = ..()
	for(var/mob/living/carbon/CA in targets)
		if(CA.has_status_effect(STATUS_EFFECT_STUN))
			for(CA in targets)
				if(CA.anti_magic_check())
					visible_message(span_warning("[src] fizzles on contact with [CA]!"))
					playsound(get_turf(CA), 'sound/magic/magic_nulled.ogg', 100)
					qdel(src)
					return BULLET_ACT_BLOCK
				if(isliving(CA))
					CA.electrocute_act(1, src)
				return TRUE
	return TRUE


//Because seelie glows constantly, this seemed unnecessary. May revisit if we can find a better execution
	
/obj/effect/proc_holder/spell/invoked/brighten
	name = "Light"
	overlay_state = "tamebeast"
	releasedrain = 30
	charge_max = 30 SECONDS
	range = 7
	cast_without_targets = TRUE
	sound = 'sound/magic/churn.ogg'
	invocation_type = "none" //can be none, whisper, emote and shout

/obj/effect/proc_holder/spell/invoked/brighten/cast(list/targets, mob/user)
	. = ..()
	user.emote("giggle")
	var/target = targets[1]
	if(isliving(target) && !isseelie(target) && iscarbon(target))
		light(target)
		return TRUE

/obj/effect/proc_holder/spell/invoked/brighten/proc/light(mob/target)
	target.set_light(2, 1, "#d4fcac")
	sleep(100)
	target.set_light(0, 0, null)
#endif

/obj/effect/proc_holder/spell/invoked/summon_rat
	name = "Call Beast"
	overlay_state = "dendor"
	releasedrain = 30
	charge_max = 90 SECONDS		//Lowered cooldown from 2 minutes. Not significant but enough to be more useful
	range = 7
	cast_without_targets = TRUE
	sound = 'sound/magic/churn.ogg'
	invocation_type = "none" //can be none, whisper, emote and shout

/obj/effect/proc_holder/spell/invoked/summon_rat/cast(list/targets, mob/user)
	. = ..()
	var/turf/T = get_turf(targets[1])
	user.emote("giggle")
	var/chance = rand(1,100)
	if(chance == 100)
		new /mob/living/simple_animal/hostile/retaliate/rogue/bigrat (T)
		user.log_message("has summoned a rous in an attempt to summon rat", LOG_GAME)
	else
		new /obj/item/reagent_containers/food/snacks/smallrat (T)
		user.log_message("has summoned a rat through the spell", LOG_GAME)
	return TRUE

/obj/effect/proc_holder/spell/invoked/strip
	name = "Strip Clothes"
	overlay_state = "bcry"
	releasedrain = 80
	charge_max = 2 MINUTES	//Less cooldown - more chaos. Used to be 6 minutes, change based on feedback
	range = 1
	cast_without_targets = TRUE
	sound = 'sound/magic/churn.ogg'
	invocation_type = "none" //can be none, whisper, emote and shout

/obj/effect/proc_holder/spell/invoked/strip/cast(list/targets, mob/user)
	. = ..()
	user.emote("giggle")
	var/mob/living/target = targets[1]
	if(iscarbon(target))
		var/obj/item/object = target.get_item_by_slot(pick(SLOT_GLOVES,SLOT_SHOES,SLOT_HEAD))
		if(!istype(object, /obj/item/clothing/head/roguetown/helmet))//Can't take helmets!	
			target.dropItemToGround(object)
		user.log_message("has stripped a piece of clothing from [key_name(target)] via spell", LOG_ATTACK)
		target.log_message("has had a piece of clothing stripped by [key_name(user)] via spell", LOG_ATTACK)
	return TRUE

/obj/effect/proc_holder/spell/invoked/drain_stam
	name = "Drain"
	overlay_state = "bloodsteal"
	releasedrain = 1
	charge_max = 3 MINUTES
	range = 1
	sound = 'sound/magic/churn.ogg'
	invocation_type = "none" //can be none, whisper, emote and shout
	//random_target = TRUE
	//random_target_priority = TARGET_RANDOM
	cast_without_targets = TRUE

/obj/effect/proc_holder/spell/invoked/drain_stam/cast(list/targets, mob/user)
	. = ..()
	if(targets.len == 0)
		to_chat(user, span_warning("There is no one close enough to drain from!"))
	if(iscarbon(targets[1]))
		var/mob/living/target = targets[1]
		var/mob/living/carbon/human/caster = user
		if((target.energy > 100) && (caster.energy < (caster.max_energy - 60)) )
			to_chat(target, span_warning("I suddenly feel burdened and fatigued!"))
			to_chat(user, span_warning("I reinvigorate myself with [target]'s energy!"))
			user.log_message("has drained the stamina from [key_name(target)]", LOG_ATTACK)
			target.log_message("has had their stamina drained by [key_name(user)]", LOG_ATTACK)
			target.energy_add(-100)
			caster.stamina_add(61)
			return TRUE
		else if(target.energy < 100)
			to_chat(user, span_warning("[target] is too exhausted to drain from!"))
			return FALSE
		else if(caster.energy >= (caster.max_energy - 60))
			to_chat(target, span_warning("I suddenly feel burdened and fatigued!"))
			to_chat(user, span_warning("I dont feel any more invigorated than I did..."))
			user.log_message("has drained the stamina from [key_name(target)]", LOG_ATTACK)
			target.log_message("has had their stamina drained by [key_name(user)]", LOG_ATTACK)
			target.energy_add(-100)
			return TRUE
		else
			to_chat(user, span_warning("I have no idea how I caused this to happen"))
			return FALSE
	else
		to_chat(user, span_warning("I cant drain energy from that!"))
	
	return FALSE
		

/obj/effect/proc_holder/spell/invoked/replenish
	name = "Replenish Nature"
	overlay_state = "blesscrop"
	releasedrain = 40
	charge_max = 3 MINUTES
	range = 1
	cast_without_targets = TRUE
	sound = 'sound/magic/churn.ogg'
	invocation_type = "none" //can be none, whisper, emote and shout

/obj/effect/proc_holder/spell/invoked/replenish/cast(list/targets, mob/user)
	. = ..()
	var/obj/structure/flora/roguegrass/bush/bushes = targets[1]
	if(isemptylist(bushes.looty))
		bushes.looty.Insert(1, pickweight(list(/obj/item/reagent_containers/food/snacks/grown/berries/rogue=5,
						/obj/item/reagent_containers/food/snacks/grown/berries/rogue/poison=3,
						/obj/item/reagent_containers/food/snacks/grown/rogue/pipeweed=1)), /obj/item/natural/thorn, /obj/item/natural/fibers)
		to_chat(user, span_notice("The bush has been replenished"))
	else
		to_chat(user, span_notice("I can only replenish emptied bushes..."))
	return TRUE

/obj/effect/proc_holder/spell/invoked/projectile/animate_object
	name = "Animate Object"
	overlay_state = "bigpsy"
	//user.emote("laugh")
	sound = 'sound/magic/lightning.ogg'
	range = 8
	projectile_type = /obj/projectile/magic/animate
	releasedrain = 55		//Decrease drain from 95, extra blue bar is taken out UPON bolt hitting something
	chargedrain = 1
	chargetime = 15
	charge_max = 5 MINUTES	//Decrease cooldown from 8 minutes, felt excessive based on testing and feedback
	warnie = "spellwarning"
	no_early_release = TRUE
	movement_interrupt = FALSE
	charging_slowdown = 3
	chargedloop = /datum/looping_sound/invokegen
	associated_skill = /datum/skill/magic/arcane

/obj/effect/proc_holder/spell/targeted/roustame
	name = "Tame Rous"
	range = 5
	overlay_state = "tamebeast"
	releasedrain = 30
	charge_max = 1 MINUTES	//Decreased from 3 minutes. Intermitant weirdness, wouldnt always work even if conditions were met, lowering cooldown should help
	max_targets = 0
	cast_without_targets = TRUE
	sound = 'sound/magic/churn.ogg'
	invocation = "Feel my presence, and be calmed."
	invocation_type = "whisper" //can be none, whisper, emote and shout

/obj/effect/proc_holder/spell/targeted/roustame/cast(list/targets, mob/user = usr)
	. = ..()
	visible_message(span_green("[usr] soothes the beast with Seelie dust."))
	// This list should contain all the creatures that can be tamed with this spell.
	var/list/tame_types = list(
		/mob/living/simple_animal/hostile/retaliate/rogue/bigrat,
	)

	if(!targets.len || !istype(targets[1], /mob/living/simple_animal))
		to_chat(user, span_warning("You must target a valid creature!"))
		return FALSE

	var/mob/living/simple_animal/target = targets[1]

	if(!(target.type in tame_types))
		to_chat(user, span_warning("You cannot tame that!"))
		return FALSE

	else if(target.mind != null && target.mind.awakened == TRUE)
		target.unawaken_beast(target, user.ckey)
		return FALSE

	for(var/mob/living/simple_animal/hostile/retaliate/rogue/bigrat/B in oview(2))
		if(!B.tame)
			B.tame = TRUE
			B.tamed()
			B.body_eater = FALSE
			B.faction += list("neutral") //Makes the Rous not target the Seelie when on aggro
		B.enemies = list()
		B.aggressive = 0
		B.LoseTarget()

	if(user.mind.awakened_animals < 1)
		// Ask the caster if they want to awaken the animal
		var/awaken_choice = alert(user, "Do you want to awaken the [target.real_name]?", "Awaken Beast", "Yes", "No")
		if(awaken_choice == "Yes")
			// Poll for candidates to control the tamed animal
			var/list/candidates = pollCandidatesForMob("Do you want to play as a tamed rous?", null, null, null, 100, target, POLL_IGNORE_TAMED_BEAST)
			// If there are candidates, assign control to a player
			if(LAZYLEN(candidates))
				var/mob/C = pick(candidates)
				target.awaken_rous(user, C.ckey)
				target.mind.awakened = TRUE
				target.visible_message(span_warning("The rous' eyes light up with intelligence as it awakens!"), runechat_message = TRUE)
				to_chat(C, span_notice("You have been chosen to control the rous."))
				return TRUE
			// If there are no candidates, the animal will have been calmed but not controlled
			else
				target.visible_message(span_warning("The rous seems calmer but remains mindless."), runechat_message = TRUE)
				return TRUE
			user.log_message("has tamed a rous via the spell", LOG_GAME)
			return TRUE
		else
			target.visible_message(span_warning("The [target.real_name] seems calmer but remains mindless."), runechat_message = TRUE)
	else if(user.mind.awakened_animals >= user.mind.awakened_max)
		to_chat(user, span_warning("I cannot sustain another awakened beast.."))
		return FALSE


/mob/living/simple_animal/proc/awaken_rous(mob/living/carbon/human/master, ckey = null)
	if(ckey) // If a player is controlling the animal
		src.ckey = ckey
		to_chat(src, span_userdanger("I was once a creature of instinct, but now... completely new thoughts and ideas flood my mind! I can think! I am free!"))
		to_chat(master, span_notice("You have awakened the [src.real_name]."))

	if(ai_controller) // Disable AI controller if it exists
		ai_controller = new /datum/ai_controller/basic_controller(src)

	return TRUE

/obj/effect/proc_holder/spell/targeted/seelie_kiss
	name = "Regenerative Kiss"
	overlay_state = "heal"
	releasedrain = 0
	charge_max = 90 SECONDS		//Decreased from 4 minutes to increase utility, almost never used but when needed its really needed
	range = 1
	invocation_type = "none" //can be none, whisper, emote and shout

/obj/effect/proc_holder/spell/targeted/seelie_kiss/cast(list/targets, mob/user)
	. = ..()
	if(iscarbon(targets[1]))
		var/mob/living/carbon/target = targets[1]
		var/obj/item/reagent_containers/powder/K = new /obj/item/reagent_containers/powder/SK(target.loc)
		K.reagents.trans_to(target, K.reagents.total_volume, transfered_by = user, method = "swallow")
		target.add_nausea(9)
		to_chat(target, span_notice("I suddenly feel reinvigorated!"))
		to_chat(user, span_notice("I have reinvigorated [target] with a kiss."))
		user.log_message("has blessed [key_name(target)] with a kiss spell, healing them a little", LOG_ATTACK)
		target.log_message("has been blessed by [key_name(user)] with a kiss spell, healing them a little", LOG_ATTACK)
		user.emote("kiss")
		qdel(K)
		return TRUE
	return FALSE

/obj/effect/proc_holder/spell/invoked/projectile/splash
	name = "Water splash"
	overlay_state = "bloodlightning"
	range = 8
	projectile_type = /obj/projectile/magic/water
	releasedrain = 50
	chargedrain = 1
	chargetime = 5
	charge_max = 35 SECONDS		//Decreased significantly from 3 minutes to support new Seelie maid
	warnie = "spellwarning"
	no_early_release = TRUE
	movement_interrupt = FALSE
	charging_slowdown = 3
	chargedloop = /datum/looping_sound/invokegen

/obj/item/reagent_containers/powder/SK
	list_reagents = list(/datum/reagent/medicine/healthpot = 2, /datum/reagent/medicine/manapot = 2)	//Buff strength of regen kiss slightly, now 2 units of red and 2 units of blue

/obj/item/reagent_containers/powder/SD
	list_reagents = list(/datum/reagent/seelie_drugs = 10)

/obj/item/reagent_containers/glass/bucket/wooden/spell_water
	list_reagents = list(/datum/reagent/water = 40)

/obj/effect/proc_holder/spell/invoked/summon_berry
	name = "Summon Berry"
	range = 7
	overlay_state = "berry_spell"
	releasedrain = 30
	charge_max = 2 MINUTES	//Decreased slightly from 3 minutes
	cast_without_targets = TRUE
	sound = 'sound/items/gem.ogg' // Not a spell sound but infinitely more fun and, I think, fitting!
	invocation = "A berry for someone in need..."
	invocation_type = "whisper"

/obj/effect/proc_holder/spell/invoked/summon_berry/cast(list/targets, mob/user)
	. = ..()
	user.emote("giggle")
	var/turf/T = get_turf(targets[1])
	if(prob(50))
		var/obj/item/reagent_containers/food/snacks/grown/berries/rogue/berry = new get_turf(T)
		berry.become_rotten()
		user.visible_message(span_notice("[user] summons a rotten berry!"))
	else
		new /obj/item/reagent_containers/food/snacks/grown/berries/rogue (T)
		user.visible_message(span_notice("[user] summons a tasty berry!"))
	return TRUE

//Sate crop will satisfy hunger requirement, but not bless crops. Removes need for ash or poop.
/obj/effect/proc_holder/spell/targeted/sate_crop
	name = "Nutrify Crop"
	range = 5
	overlay_state = "blesscrop"
	releasedrain = 30
	charge_max = 30 SECONDS
	cast_without_targets = TRUE
	sound = 'sound/items/gem.ogg' // Not a spell sound but copied from berry summon.
	invocation = "Sated crops for hungry people..."
	invocation_type = "whisper"

/obj/effect/proc_holder/spell/targeted/sate_crop/cast(list/targets,mob/user = usr)
	. = ..()
	var/growed = FALSE
	var/amount_blessed = 0
	for(var/obj/structure/soil/soil in view(4))
		soil.adjust_nutrition(150)
		growed = TRUE
		// Nutrifies only up to 5 crops
		if(amount_blessed >= 5)
			break
	if(growed)
		visible_message(span_green("[usr] sates the nearby crops with magical nutrients!"))
	return growed
