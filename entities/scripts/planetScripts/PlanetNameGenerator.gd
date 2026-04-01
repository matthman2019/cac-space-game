class_name PlanetNameGenerator extends Node

# ~40 prefixes × ~25 mids (optional) × ~25 suffixes = 25,000+ base combos
# × optional modifier = 100,000+ possible unique planet names

static var prefixes: Array[String] = [
	"Ar", "Vel", "Ker", "Zar", "Tor", "Nex", "Vos", "Eth", "Mal", "Sol",
	"Drak", "Cor", "Lux", "Mir", "Pax", "Ryn", "Sev", "Thal", "Ux", "Vor",
	"Wyn", "Xal", "Yor", "Zel", "Bor", "Cal", "Dar", "Fen", "Gal", "Hyr",
	"Ith", "Jun", "Kas", "Lor", "Mur", "Nav", "Oph", "Per", "Rus", "Tak",
	"Eld", "Fyn", "Ghor", "Isk", "Keth", "Lyv", "Morg", "Nul", "Orv", "Prel"
]

static var mids: Array[String] = [
	"an", "os", "eth", "ar", "on", "en", "is", "ul", "or", "ax",
	"el", "in", "um", "yr", "iv", "ath", "ix", "ev", "ov", "al",
	"un", "ep", "ir", "ek", "yl", "oth", "esh", "em", "ob", "ur"
]

static var suffixes: Array[String] = [
	"ia", "os", "ar", "um", "on", "us", "ix", "ax", "an", "ath",
	"el", "ion", "is", "eth", "ora", "ys", "id", "ux", "yn", "eon",
	"ara", "ite", "ium", "ula", "oir", "ash", "eld", "orn", "eph", "yke"
]

# Weighted: 4 empty strings = ~57% chance of no modifier
static var modifiers: Array[String] = [
	"", "", "", "", "", "", "",
	"Prime", "Minor", "Major",
	"I", "II", "III", "IV", "V",
	"Alpha", "Beta", "Gamma", "Delta", "Epsilon"
]

static func generate() -> String:
	var prefix = prefixes[GlobalRNG.rng.randi_range(0, prefixes.size() - 1)]

	# ~50% chance to add a mid-syllable
	var mid = ""
	if GlobalRNG.rng.randf() > 0.5:
		mid = mids[GlobalRNG.rng.randi_range(0, mids.size() - 1)]

	var suffix = suffixes[GlobalRNG.rng.randi_range(0, suffixes.size() - 1)]
	var modifier = modifiers[GlobalRNG.rng.randi_range(0, modifiers.size() - 1)]

	@warning_ignore("shadowed_variable_base_class")
	var name = prefix + mid + suffix

	# Capitalize first letter (already is, but safe)
	name = name[0].to_upper() + name.substr(1).to_lower()

	if modifier != "":
		name += " " + modifier

	return name
