extends Node

var planetUidTracker : Dictionary[int, Planet] = {}

func registerPlanet(planet : Planet):
	planetUidTracker[planet.uid] = planet

func getPlanet(uid : int):
	return planetUidTracker[uid]
