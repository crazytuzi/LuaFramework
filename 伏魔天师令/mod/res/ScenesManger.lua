require "mod.res.ResourceList"
require "mod.res.LoadResScene"
require "mod.res.SpineManager"

ScenesManger=ScenesManger or {}

ScenesManger.lastResourceId=Cfg.UI_AccountLogin

ScenesManger.sceneResType=1
ScenesManger.layerResType=2

ScenesManger.sameResList=
{
	[_G.Const.CONST_MAP_WELKIN_FIRST]=_G.Const.CONST_FUNC_OPEN_WELKIN,
	[_G.Const.CONST_MAP_WELKIN_BATTLE]=_G.Const.CONST_FUNC_OPEN_WELKIN,
	[_G.Const.CONST_MAP_WELKIN_ONLY]=_G.Const.CONST_FUNC_OPEN_WELKIN,
}

ScenesManger.noReleaseResList=
{
	[Cfg.UI_StageResources]=1,
	[Cfg.UI_SelectSeverScene]=1,
	[Cfg.UI_BattleStageResources]=1,
}

ScenesManger.subResList={}

-- function ScenesManger.loadLayer(sceneObj,fileList)
-- 	ScenesManger.currentSceneObj=sceneObj
-- 	local ShowUI = function ()
-- 		ScenesManger.currentSceneObj:show()
-- 	end

-- 	if fileList==nil or #fileList==0 then
-- 		ShowUI()
-- 		return
-- 	end

-- 	resType=ScenesManger.layerResType
-- 	local loadResScene = LoadResScene(nil,resType)
-- 	loadResScene:load(fileList, ShowUI)
-- end

function ScenesManger.loadScene(sceneObj,sceneId,fileList,resType,isSubscene,spineList,gafList)
	sceneId=ScenesManger.sameResList[sceneId] or sceneId
	print("ScenesManger.loadScene sceneId=",sceneId,"resType=",resType,"isSubscene=",isSubscene,"spineList=",spineList)
	print("ScenesManger.lastResourceId=",ScenesManger.lastResourceId)
	if ScenesManger.isLoading then
		return
	end
	fileList=fileList or {}

	ScenesManger.currentSceneId=sceneId
	if not isSubscene then
		ScenesManger.releaseResource(sceneId)
	end
	ScenesManger.currentSceneObj=sceneObj


	local function ShowUI(sceneId,isNoRes)
		ScenesManger.currentSceneObj:show(sceneId)
		if isNoRes then
			return
		end

    	CCLOG("end ScenesManger.loadScene==============>> sceneId=%d",sceneId)
    	if isSubscene then
    		table.insert(ScenesManger.subResList,sceneId)
    	else
    		ScenesManger.lastResourceId=sceneId
    	end
	end

	if ScenesManger.lastResourceId==sceneId then
		if Cfg.UI_StageResources~=sceneId and 
			Cfg.UI_BattleStageResources~=sceneId then

			-- print("ScenesManger.lastResourceId==sceneId   Cfg.UI_StageResources~=sceneId Cfg.UI_BattleStageResources~=sceneId")

			fileList=Cfg.ResList.GetList(sceneId, fileList)
			for _,fileName in pairs(fileList) do
				local searchPlist=string.find(fileName, ".plist")
				if searchPlist then
					cc.SpriteFrameCache:getInstance():addSpriteFrames(fileName)
				end
			end

			ShowUI(sceneId)
			return
		end
	end

	if isSubscene then
		for _,v in pairs(ScenesManger.subResList) do
			if v== sceneId then
				print("has sub res==========>>>>")
				ShowUI(sceneId)
				return
			end
		end
	end

	Cfg.ResList.GetList(sceneId,fileList)

	if next(fileList)==nil then
		ShowUI(sceneId,true)
		return
	end

	-- for k,v in pairs(fileList) do
	-- 	print(k,v)
	-- end

	-- print("ScenesManger.loadScene========================>>>4")

	resType=resType or ScenesManger.layerResType
	local loadResScene=LoadResScene(sceneId,resType,fileList,ShowUI,spineList,gafList)
	-- loadResScene:load(fileList,ShowUI)

	ScenesManger.isLoading=true

	print("end ScenesManger.loadScene========================>>>5")
end

function ScenesManger.releaseResource(resourceId)
	if ScenesManger.lastResourceId==nil or ScenesManger.lastResourceId==resourceId then
		return
	end

	if ScenesManger.noReleaseResList[ScenesManger.lastResourceId]~=nil then		
		return
	end

    CCLOG("ScenesManger.releaseResource==============>> lastResourceId=%d",ScenesManger.lastResourceId)

	local lastFileList=Cfg.ResList.GetList(ScenesManger.lastResourceId, lastFileList)
	for _,fileName in pairs(lastFileList) do
		ScenesManger.releaseFile(fileName)
	end

	if #ScenesManger.subResList>0 then
		local sceneId=ScenesManger.subResList[1]
		table.remove(ScenesManger.subResList,1)
		if ScenesManger.currentSceneId~=sceneId then
			ScenesManger.lastResourceId=sceneId
			ScenesManger.releaseResource(ScenesManger.currentSceneId)
		end
	end
end

function ScenesManger.releaseFile(fileName)
	local searchPos=string.find(fileName, ".plist")
	if searchPos then
		-- CCLOG("ScenesManger.releaseResource plistFileName=%s",fileName)
		cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile(fileName)

		local pvrFileName = string.sub(fileName,0,searchPos)
		-- pvrFileName=pvrFileName.."pvr.ccz"
		-- CCLOG("ScenesManger.releaseResource pvrFileName=%s",pvrFileName)
		cc.Director:getInstance():getTextureCache():removeTextureForKey(pvrFileName.."pvr.ccz")
		cc.Director:getInstance():getTextureCache():removeTextureForKey(pvrFileName.."png")
		-- local pngFileName=pvrFileName.."png"
		-- cc.Director:getInstance():getTextureCache():removeTextureForKey(pngFileName)
	else
		searchPos=string.find(fileName, ".png")
		if searchPos then
			-- CCLOG("ScenesManger.releaseResource fileName=%s",fileName)
			cc.Director:getInstance():getTextureCache():removeTextureForKey(fileName)
		else
			searchPos=string.find(fileName, ".jpg")
			if searchPos then
				cc.Director:getInstance():getTextureCache():removeTextureForKey(fileName)
			end
		end
	end
end

function ScenesManger.releaseFileArray(_fileArray)
	if _fileArray==nil or type(_fileArray)~="table" then return end
	for fileName,_ in pairs(_fileArray) do
		ScenesManger.releaseFile(fileName)
	end
end

function ScenesManger.releaseLoginResource()
	local fileList=Cfg.ResList.GetList(Cfg.UI_SelectSeverScene)
	ScenesManger.releaseFileArray(fileList)
end

function ScenesManger.releaseForChangeRole()
	if _G.g_Stage==nil then return end
	_G.g_Stage:releaseCharacterResource()
end

function ScenesManger.releaseLoadingResources()
	local tempArray={
		["ui/bg/bg_loading.jpg"]=true,
		["ui/logo.jpg"]=true
	}
	ScenesManger.releaseFileArray(tempArray)
end

-- function ScenesManger.releaseCCBIRes(ccbiName)
-- 	print("ScenesManger.releaseCCBIRes ccbiName=",ccbiName)
-- 	ccbiName=tostring(ccbiName)
-- 	local searchIndex=string.find(ccbiName, "ccbi/%d+_normal.ccbi")
-- 	if searchIndex~=nil then
-- 		CPlayer[4]=CPlayer[4] or {}
-- 		if CPlayer[4][ccbiName]==nil then
-- 			local tempFileName = string.gsub(ccbiName,"ccbi/","ccbResources/")
-- 			local plistFileName = string.gsub(tempFileName,".ccbi",".plist")
-- 			cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile(plistFileName)
-- 			local pvrFileName = string.gsub(tempFileName,".ccbi",".pvr.ccz")
-- 			cc.Director:getInstance():getTextureCache():removeTextureForKey(pvrFileName)
-- 			local pngFileName = string.gsub(tempFileName,".ccbi",".png")
-- 			cc.Director:getInstance():getTextureCache():removeTextureForKey(pngFileName)
-- 		end
-- 	end
-- end

