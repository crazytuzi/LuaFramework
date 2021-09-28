--CCSUIHooker.lua


local CCSUIHooker = {
	__sceneHookerObjs = {},
	__layerHookerObjs = {},

	__sceneHookerTargetPair = {},
	__layerHookerTargetPair = {},

	__sceneHookerName = "__scene_hooker_name__",
	__layerHookerName = "__layer_hooker_name__",

	__tempSceneAddHooker = {},
	__tempLayerAddHooker = {},

	__tempRemoveHooker = {},

	__isHookerScene = false,
	__isHookerLayer = false,
}

CCSUIHooker.hookerSceneWithName = function ( sceneName, fun, target )
	if type(sceneName) ~= "string" or fun == nil or target == nil then
		return 
	end

	if not CCSUIHooker.__isHookerScene then
		local sceneHookArr = CCSUIHooker.__sceneHookerObjs[sceneName] or {}
		table.insert(sceneHookArr, #sceneHookArr + 1, {fun, target})

		CCSUIHooker.__sceneHookerObjs[sceneName] = sceneHookArr
		CCSUIHooker.__sceneHookerTargetPair[sceneName] = 1
	else
		table.insert(CCSUIHooker.__tempSceneAddHooker, #CCSUIHooker.__tempSceneAddHooker + 1, {sceneName, fun, target})
	end

	--dump(CCSUIHooker.__sceneHookerObjs)
	--dump(CCSUIHooker.__sceneHookerTargetPair)
end

CCSUIHooker.hookerScene = function ( fun, target )
	CCSUIHooker.hookerSceneWithName(CCSUIHooker.__sceneHookerName, fun, target)
end

CCSUIHooker.hookerLayerWithName = function ( layerName, fun, target )
	if type(layerName) ~= "string" or fun == nil or target == nil then
		return 
	end

	if not CCSUIHooker.__isHookerLayer then
		local layerHookArr = CCSUIHooker.__layerHookerObjs[layerName] or {}
		table.insert(layerHookArr, #layerHookArr + 1, {fun, target})

		CCSUIHooker.__layerHookerObjs[layerName] = layerHookArr
		CCSUIHooker.__layerHookerTargetPair[layerName] = 1
	else
		table.insert(CCSUIHooker.__tempLayerAddHooker, #CCSUIHooker.__tempLayerAddHooker + 1, {layerName, fun, target})
	end
	--dump(CCSUIHooker.__layerHookerObjs)
	--dump(CCSUIHooker.__layerHookerTargetPair)
end

CCSUIHooker.hookerLayer = function ( fun, target )
	CCSUIHooker.hookerLayerWithName(CCSUIHooker.__layerHookerName, fun, target)
end

CCSUIHooker.unHookerWithSceneName = function ( sceneName, target )
	if sceneName and target and CCSUIHooker.__sceneHookerObjs[sceneName] then 
		for key, value in pairs(CCSUIHooker.__sceneHookerObjs[sceneName]) do
			if value[2] == target then 
				table.remove(CCSUIHooker.__sceneHookerObjs[sceneName], key)
				return
			end
		end
		--CCSUIHooker.__sceneHookerObjs[sceneName] = nil
	end
end

CCSUIHooker.unHookerWithLayerName = function ( layerName, target )
--dump(CCSUIHooker.__layerHookerObjs)
	if layerName and target and CCSUIHooker.__layerHookerObjs[layerName] then 
		for key, value in pairs(CCSUIHooker.__layerHookerObjs[layerName]) do
			if value[2] == target then 
				table.remove(CCSUIHooker.__layerHookerObjs[layerName], key)
				return
			end
		end
		--CCSUIHooker.__layerHookerObjs[layerName] = nil
	end
--dump(CCSUIHooker.__layerHookerObjs)
end

CCSUIHooker.unHookerWithTarget = function ( target ) 
	if not target then
		return 
	end

	if CCSUIHooker.__isHookerScene or CCSUIHooker.__isHookerLayer then
		table.insert(CCSUIHooker.__tempRemoveHooker, #CCSUIHooker.__tempRemoveHooker + 1, target)
		return 
	end

--dump(CCSUIHooker.__sceneHookerObjs)
--dump(CCSUIHooker.__sceneHookerTargetPair)
	for sceneName, value1 in pairs(CCSUIHooker.__sceneHookerTargetPair) do 
		CCSUIHooker.unHookerWithSceneName(sceneName, target)
		--CCSUIHooker.__sceneHookerTargetPair[sceneName] = nil
	end

--dump(CCSUIHooker.__sceneHookerObjs)
--dump(CCSUIHooker.__sceneHookerTargetPair)
	for layerName, value1 in pairs(CCSUIHooker.__layerHookerTargetPair) do 
		CCSUIHooker.unHookerWithLayerName(layerName, target)
		--CCSUIHooker.__layerHookerTargetPair[layerName] = nil
	end
end

CCSUIHooker._addTempHooker = function ( ... )
	for key, value in CCSUIHooker.__tempSceneAddHooker do
		if type(value) == "table" then
			CCSUIHooker.hookerSceneWithName(value[1], value[2], value[3])
		end
	end
	CCSUIHooker.__tempSceneAddHooker = {}

	for key, value in CCSUIHooker.__tempLayerAddHooker do
		if type(value) == "table" then
			CCSUIHooker.hookerLayerWithName(value[1], value[2], value[3])
		end
	end
	CCSUIHooker.__tempLayerAddHooker = {}
end

CCSUIHooker._removeTempHooker = function ( ... )
	for key, value in pairs(CCSUIHooker.__tempRemoveHooker) do
		--if type(value) == "table" then
			CCSUIHooker.unHookerWithTarget(value)
		--end
	end
	CCSUIHooker.__tempRemoveHooker = {}
end

CCSUIHooker._doHitHooker = function ( isScene, name, ... )
	if type(name) ~= "string" then
		return 
	end

	local hookerFun = function ( name, objs, ... )
		if not objs or #objs < 1 then
			return 
		end

		local args = {...}
		for key, value in pairs(objs) do 
			if type(value) == "table" then
				if value[1] and value[2] then 
					value[1](value[2], name, unpack(args))
				elseif value[1] then
					value[1](name, unpack(args))
				end
			end
		end
	end

	isScene = isScene or false
	local hookerObjs = isScene and CCSUIHooker.__sceneHookerObjs[name] or 
	CCSUIHooker.__layerHookerObjs[name]

	--if not isScene then
	--	__Log("do hit layer:%s", name)
	--	dump(hookerObjs)
	--end
	if hookerObjs and #hookerObjs > 0 then
		CCSUIHooker.__isHookerScene = true
		hookerFun(name, hookerObjs, ...)
		CCSUIHooker.__isHookerScene = false
	end

	hookerObjs = isScene and CCSUIHooker.__sceneHookerObjs[CCSUIHooker.__sceneHookerName] or 
	CCSUIHooker.__layerHookerObjs[CCSUIHooker.__layerHookerName]
	if hookerObjs and #hookerObjs > 0 then
		CCSUIHooker.__isHookerScene = true
		hookerFun(name, hookerObjs, ...)
		CCSUIHooker.__isHookerScene = false
	end

	CCSUIHooker._removeTempHooker()
end

CCSUIHooker.hitSceneHooker = function ( sceneName, ... )
	CCSUIHooker._doHitHooker(true, sceneName, ...)
end

CCSUIHooker.hitLayerHooker = function ( layerName, ... )
	CCSUIHooker._doHitHooker(false, layerName, ...)
end

CCSUIHooker.dumpLayerHooker = function ( ... )
	dump(CCSUIHooker.__layerHookerObjs)
	dump(CCSUIHooker.__layerHookerTargetPair)
end

CCSUIHooker.dumpSceneHooker = function ( ... )
	dump(CCSUIHooker.__sceneHookerObjs)
	dump(CCSUIHooker.__sceneHookerTargetPair)
end

return CCSUIHooker