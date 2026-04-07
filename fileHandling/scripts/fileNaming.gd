class_name FileNaming
extends Object

static func makeUniquePath(path: String, fileLevel := true) -> String:
	var checker: Callable = \
		FileAccess.file_exists if fileLevel else DirAccess.dir_exists_absolute
	if not checker.call(path): return path
	var pathParts: PackedStringArray = path.split(".")
	var base: String = pathParts[0]
	var suffix: String = pathParts[-1]
	var count: int = 1
	while true:
		var newPath = "%s-%d.%s" % [base, count, suffix]
		if not checker.call(newPath): return newPath
		count += 1
	return path + "_WHY_CAN'T_WE_FIND_A_VALID_PATH_FOR_THIS_FILE"

static func getBackupPrefix() -> String:
	return makeUniquePath("BACKUP_%s" % [Time.get_datetime_string_from_system()])
