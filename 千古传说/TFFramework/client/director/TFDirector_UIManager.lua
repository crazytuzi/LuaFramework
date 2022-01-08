local TFSceneManager 		= require('TFFramework.client.manager.TFSceneManager')
local TFUILoadManager       = require('TFFramework.client.manager.TFUILoadManager')
local TFSceneManagerModel = {}

-------------------------------------------- new UI Manager ------------------------------------
local objCurScene
function TFDirector:readConfig(szAppPath)
	local tGameConfig = require(szAppPath)
	TFSceneManagerModel.szGameConfigPathDir = TFSceneManager:getFileDir(szAppPath)
	TFSceneManagerModel.tScenes = {}
	TFSceneManagerModel.tScenesInOrder = {}
	for nID, tScene in pairs(tGameConfig.scenes) do
		local szPath = tScene.path
		szPath = string.trim(szPath)
		szPath = string.gsub(szPath, '/', '.')
		if string.lower(szPath['-4']) == '.lua' then
			szPath = szPath['1:-5']
		end
		TFSceneManagerModel.tScenes[tScene.name] = TFSceneManagerModel.szGameConfigPathDir .. szPath
		TFSceneManagerModel.tScenesInOrder[nID] = tScene.name
	end
	return TFSceneManagerModel.tScenes, TFSceneManagerModel.tScenesInOrder
end

function TFDirector:createMEScene(szName)
	local objScene
	local szSceneName = szName
	if TFSceneManagerModel.tScenes and TFSceneManagerModel.tScenes[szName] ~= nil then
		szName = TFSceneManagerModel.tScenes[szName]
	end
	objScene = require(szName)
	TFDirector:unRequire(szName)	--???
	local objCurScene = nil
	if instanceOf(objScene) ~= NONE_CLASS then --???
		objCurScene = objScene:new(tData)
	else
		local tSceneData = objScene
		objCurScene = TFSceneManager:createMEEditorScene(tSceneData, TFSceneManagerModel.szGameConfigPathDir .. szSceneName .. '.')
	end
	return objCurScene
end

-- this method use for editor begin

function TFDirector:createMEEditorScene(szName)
	local objScene
	local szSceneName = szName
	if TFSceneManagerModel.tScenes and TFSceneManagerModel.tScenes[szName] ~= nil then
		szName = TFSceneManagerModel.tScenes[szName]
	end
	objScene = require(szName)
	TFDirector:unRequire(szName)	--???
	local objCurScene = nil
	if instanceOf(objScene) ~= NONE_CLASS then --???
		objCurScene = objScene:new(tData)
	else
		local tSceneData = objScene
		local szPrePath = TFSceneManager:getFileDir(szSceneName)
		objCurScene = TFSceneManager:createMEEditorScene(tSceneData, szPrePath, true)
	end
	return objCurScene
end

-- -- this method use for editor end

-- szScene 不为空：从szScene里读取模块szModule；为空：直接读取szModule的模块(全路径)
function TFDirector:createMEModule(szModule, szScene, isStopGC)
    --collectgarbage("stop")
	if szScene ~= nil then
		if TFSceneManagerModel.tScenes and TFSceneManagerModel.tScenes[szScene] ~= nil then
			local szPrePath = TFSceneManagerModel.szGameConfigPathDir .. szScene .. '.'
			szModule = szPrePath .. szModule
			tScene = require(TFSceneManagerModel.tScenes[szScene])
			for k, v in pairs(tScene) do
				if v.name == szModule then
					local szUIPath = v['ui']
					local szLogicPath = v['logic']
					if szLogicPath == "" then szLogicPath = nil end
					local ui = TFUILoadManager:loadModule(szPrePath .. szUIPath, szLogicPath, v.name, v.x, v.y)
					return ui
				end
			end
		end
	end
	local ui = createUIByLua(szModule)
    --collectgarbage("collect")
	return ui
end

function TFDirector:getUI(szModule)
	local ui = TFUILoadManager:getUI(szModule)
	if ui == nil then
		for i, v in pairs(TFSceneManagerModel.tScenes) do
			local tScene = require(v)
			print(szPrePath)
			for k, t in pairs(tScene) do
				if t.name == szModule then
					local szUIPath = t['ui']
					local szLogicPath = t['logic']
					if szLogicPath == "" then szLogicPath = nil end
					local szPrePath = TFSceneManagerModel.szGameConfigPathDir .. t['layer'] .. '.'
					ui = TFUILoadManager:loadModule(szPrePath .. szUIPath, szLogicPath, t.name, t.x, t.y)
					return ui
				end
			end
		end
	end
	return ui
end

function TFDirector:pushScene(objScene)
	return me.Director:pushScene(objScene)
end

function TFDirector:popScene()
	return me.Director:popScene()
end

function TFDirector:replaceScene(objScene)
	return me.Director:replaceScene(objScene)
end

--[[ 	@param szPath:  Need to PreLoad Lua Resource
	@param CallBackFunc
--]]
-- Use for file that is export by Editor
function TFDirector:preLoadResourceByPath(szPath, CallBackFunc)
	local tRes
	if type(szPath) == 'string' then
		tRes = require(szPath).respaths
	else
		tRes = szPath.respaths
	end
	local nTotle = 0
	local nCount = 0

	local callBackFunc = function (target)
		nCount = nCount + 1
		TFFunction.call(CallBackFunc, nCount, nTotle)
		if nCount == nTotle then
			TFResourceCache:sharedResourceCache():unregisterScriptHandler()
		end
	end
	TFResourceCache:sharedResourceCache():registerScriptHandler(callBackFunc)

	local tImage = tRes.textures
	nTotle = nTotle + table.maxn(tImage)
	for k,v in pairs(tImage) do
		TFResourceCache:sharedResourceCache():addResourceAsync(v, Resource_Image)
	end

	local tArmature = tRes.armatures
	nTotle = nTotle + table.maxn(tArmature)
	for k,v in pairs(tArmature) do
		TFResourceCache:sharedResourceCache():addResourceAsync(v, Resource_Armature)
	end

	local tMovieClip = tRes.movieclips
	nTotle = nTotle + table.maxn(tMovieClip)
	for k,v in pairs(tMovieClip) do
		TFResourceCache:sharedResourceCache():addResourceAsync(v, Resource_MovieClip)
	end

	--sync me.TextureCache:addImage(v) 
end

--[[ 	@param tRes:  Need to PreLoad Lua Resource put in table, such as:
{
	"Modle1.lua",
	"test/skill/fight.lua",
	.......
}
	@param CallBackFunc
--]]
function TFDirector:preLoadResourceByTable(tPath, CallBackFunc)
	local tReturn = {}
	tReturn.respaths = {}
	local tRes = tReturn.respaths
	tRes.textures = {}
	tRes.armatures = {}
	tRes.movieclips = {}
	for _, szPath in pairs(tPath) do
		local res = require(szPath).respaths
		local t = res.textures
		for i, v in pairs(t) do
			for j, k in pairs(tRes.textures) do
				if k == v then break end
			end
			tRes.textures[#tRes + 1] = v
		end
		t = res.armatures
		for i, v in pairs(t) do
			for j, k in pairs(tRes.armatures) do
				if k == v then break end
			end
			tRes.armatures[#tRes.armatures + 1] = v
		end
		t = res.movieclips
		for i, v in pairs(t) do
			for j, k in pairs(tRes.movieclips) do
				if k == v then break end
			end
			tRes.movieclips[#tRes.movieclips + 1] = v
		end
	end
	TFDirector:preLoadResourceByPath(tReturn, CallBackFunc)
end
