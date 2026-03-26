## A static class to help with star generation.
class_name StarGeneration extends Node

static var vowels = ["a", "e", "i", "o", "u", "y"]
# dipthongs can be any combination of vowels
static var consonants = ["b", "c", "d", "f", "g", "h", "j", "k", "l", "m", "n", "p", "q", "r", "s", "t", "v", "w", "x", "z"]

enum StarSize {
	O = 0,
	B = 1,
	A = 2,
	F = 3,
	G = 4,
	K = 5,
	M = 6,
}

static func weighted_randint(args : Array[Array]) -> int:
	# check that the probabilities given equal 1
	var probabilitySum = 0.0
	for possibilityTuple in args:
		probabilitySum += possibilityTuple[1]
	if abs(1 - probabilitySum) > 0.001:
		push_error("The sum of probabilities does not equal 1!")
	
	# the way this works is: we add the possibility[1] (the probability) to possibilitySum every iteration of the loop.
	# if randomNumber is less than possiblitySum, we return possibility[0].
	# otherwise, we keep going with the loop.
	var possibilitySum = 0
	var randomNumber = GlobalRNG.rng.randf()

	for possibility in args:
		possibilitySum += possibility[1]
		if randomNumber < possibilitySum:
			return possibility[0]
		else:
			continue
	return 0

static func chance_boolean(probabilityTrue:float=0.5) -> bool:
	if randf() < probabilityTrue:
		return true
	else:
		return false


static func generate_random_name():
	var finalName = ''
	var wordCount = weighted_randint([[1, 0.7], [2, 0.25], [3, 0.05]])

	for wordNumber in range(wordCount):

		var syllableCount = weighted_randint([[1, 0.1], [2, 0.3], [3, 0.4], [4, 0.2]])

		for syllable in range(syllableCount):
			# starting consonant
			if chance_boolean(0.8):
				finalName += consonants.pick_random()
			
			# dipthong (or vowel) chance
			if chance_boolean(0.2):
				finalName += vowels.pick_random() + vowels.pick_random()
			else:
				finalName += vowels.pick_random()
			
			# ending consonant pair
			for i in range(weighted_randint([[0, 0.8], [1, 0.2]])):
				finalName += consonants.pick_random()
		
		if wordNumber != wordCount-1:
			finalName += ' '
		
	# ending number
	if chance_boolean(0.2):
		finalName += ' - {}'.format(GlobalRNG.rng.randi_range(0, 15))

	# make sure our name isn't something stupid
	# if it's too short, generate a new name and return it
	if len(finalName) <= 2:
		return generate_random_name()
	else:
		return finalName

# credit to @AymericG on stackoverflow from this post: 
# https://stackoverflow.com/questions/21977786/star-b-v-color-index-to-apparent-rgb-color
## From my old galaxy generator. Turns black body value to color
static func bv2rgb(bv):
	if bv < -0.40: bv = -0.40
	if bv > 2.00: bv = 2.00

	var r = 0.0
	var g = 0.0
	var b = 0.0
	var t

	if  -0.40 <= bv and bv <0.00:
		t=(bv+0.40)/(0.00+0.40)
		r=0.61+(0.11*t)+(0.1*t*t)
	elif 0.00 <= bv and bv <0.40:
		t=(bv-0.00)/(0.40-0.00)
		r=0.83+(0.17*t)
	elif 0.40 <= bv and bv <2.10:
		t=(bv-0.40)/(2.10-0.40)
		r=1.00
	
	if  -0.40 <= bv and bv <0.00:
		t=(bv+0.40)/(0.00+0.40)
		g=0.70+(0.07*t)+(0.1*t*t)
	elif 0.00 <= bv and bv <0.40:
		t=(bv-0.00)/(0.40-0.00)
		g=0.87+(0.11*t)
	elif 0.40 <= bv and bv <1.60:
		t=(bv-0.40)/(1.60-0.40)
		g=0.98-(0.16*t)
	elif 1.60 <= bv and bv <2.00:
		t=(bv-1.60)/(2.00-1.60)
		g=0.82-(0.5*t*t)
	if  -0.40 <= bv and bv <0.40:
		t=(bv+0.40)/(0.40+0.40)
		b=1.00
	elif 0.40 <= bv and bv <1.50:
		t=(bv-0.40)/(1.50-0.40)
		b=1.00-(0.47*t)+(0.1*t*t)
	elif 1.50 <= bv and bv <1.94:
		t=(bv-1.50)/(1.94-1.50)
		b=0.63-(0.6*t*t)
	
	return Color.from_rgba8(round(r * 255), round(g * 255), round(b * 255))

static func uniform(from : float, to : float):
	return GlobalRNG.rng.randf_range(from, to)
static func MakeStar():
	var starName = generate_random_name()
	var size = weighted_randint([[0, 0.001], [1, 0.05], [2, 0.149], [3, 0.1], [4, 0.15], [5, 0.25], [6, 0.3]])
	var starColor = 0
	var starSize = 0
	match size:
		StarSize.O:
			starColor = bv2rgb(uniform(-0.4, -0.2))
			starSize = uniform(6.6, 10)
		StarSize.B:
			starColor = bv2rgb(uniform(-0.2, 0.0))
			starSize = uniform(1.8, 6.6)
		StarSize.A:
			starColor = bv2rgb(uniform(0.0, 0.3))
			starSize = uniform(1.4, 1.8)
		StarSize.F:
			starColor = bv2rgb(uniform(0.3, 0.6))
			starSize = uniform(1.15, 1.4)
		StarSize.G:
			starColor = bv2rgb(uniform(0.6, 0.9))
			starSize = uniform(0.96, 1.15)
		StarSize.K:
			starColor = bv2rgb(uniform(0.9, 1.4))
			starSize = uniform(0.7, 0.96)
		StarSize.M:
			starColor = bv2rgb(uniform(1.4, 2.0))
			starSize = uniform(0.3, 0.96)
		_:
			push_error("Bad harvardSpectral! Make sure it is of type StarSize!")
	
	return [starName, starColor, starSize]
