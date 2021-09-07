SceneData = SceneData or BaseClass()

local meta = SceneData

function meta:__init()
	if meta.Instance then
		print_error("[SceneData]:Attempt to create singleton twice!")
	end
	meta.Instance = self
end

function meta:__delete()
	meta.Instance = nil
end

function meta:TargetSelectIsTask(value)
	return value == SceneTargetSelectType.TASK
end

function meta:TargetSelectIsScene(value)
	return value == SceneTargetSelectType.SCENE
end

function meta:TargetSelectIsSelect(value)
	return value == SceneTargetSelectType.SELECT
end