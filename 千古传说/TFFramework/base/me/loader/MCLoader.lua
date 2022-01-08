--
-- Author: MiYu
-- Date: 2014-03-04 20:20:21
--

local function createMC(pDict, szActions)
	if pDict then
		local pMovieClip = TFMCData:new()
		pMovieClip:autorelease()
		if pMovieClip == nil then
			return
		end
		local metaDic = pDict.meta
		pMovieClip:setScale(metaDic.scale or 1.0)
		pMovieClip:setFrameFps(metaDic.frameFps or 0)
		pMovieClip:setRate(metaDic.rate or 1.0)
		local spriteSizeDic = metaDic.spriteSize
		local w = spriteSizeDic.w or 0
		local h = spriteSizeDic.h or 0
		pMovieClip:setMovieSize(CCSizeMake(w, h))
		local framesDic = pDict.frames
		local registerX = 0
		local registerY = 0
		local spriteFrames = TFIntMap:create()
		for name, currentFrame in pairs(framesDic) do
			local frameNum = currentFrame.frameNum or 0
			
			local frame = me.FrameCache:spriteFrameByName(name)
			if frame then
				spriteFrames:setObject(frame, frameNum)
			end
		end
		--解析mc嵌入属性
		if pDict.embed then
			local embedDic = pDict.embed
			if embedDic.curTotalFrameX then
				pMovieClip:setEmbedCurTotalFrameX(embedDic.curTotalFrameX)
			end
			if embedDic.sizeType then
				pMovieClip:setEmbedSizeType(embedDic.sizeType)
			end
			if embedDic.flight then
				pMovieClip:setEmbedFlight(embedDic.flight)
			end
			if embedDic.showNamePosY then
				pMovieClip:setEmbedShowNamePosY(embedDic.showNamePosY)
			end
			if embedDic.offsetY then
				pMovieClip:setEmbedOffsetY(embedDic.offsetY)
			end
			if embedDic.noShadow then
				pMovieClip:setEmbedNoShadow(embedDic.noShadow)
			end
		end

		local actionsDic = pDict.actions
		for name, actionDic in pairs(actionsDic) do
			if not szActions or szActions =="" or name == "default" or string.find(szActions, name) then
				local beginIndex = actionDic.start or 0
				local endIndex = actionDic['end'] or 0

				local animFrames = TFVector:create()
				local pLastFrame = me.MCManager:getBeginNullFrame()
				for i = beginIndex, endIndex do
					local pFrame = spriteFrames:objectForKey(i)
					if pFrame == nil then
						pFrame = pLastFrame
					end
					if pFrame then
						animFrames:addObject(pFrame)
						pLastFrame = pFrame
					end
				end
				pMovieClip:getActions():setObject(animFrames, name)
			end
		end
		me.MCManager:setTempMCData(pMovieClip)
	end
end

local function decodeJson(szContent, nType)
	local temp
	if nType == 0 then
		temp = json.decode(szContent)
	elseif nType == 3 then
		local filePath = me.FileUtils:fullPathForFilename(szContent)
		szContent = io.readfile(filePath)
		temp = json.decode(szContent)
	end
	return temp
end

local mcDict = {}
--[[
	szContent: json字符串, 或json文件路径
	objText: 纹理
	nIndex: 纹理索引
	nType: 0, json字符串 3, json文件路径 1, 解析json 2, 清理缓存
--]]
local function MCLoader(szContent, objText, nIndex, nType, szActions)
	if nType == 0 or nType == 3 then
		if not szContent or not objText or not nIndex then return end
		local dictionary
		if not mcDict[szContent] then
			dictionary = decodeJson(szContent, nType)
			mcDict[szContent] = dictionary
		else
			dictionary = mcDict[szContent]
		end

		local metaDic = dictionary.meta
		local spriteSizeDict = metaDic.spriteSize

		local spriteSize
		if spriteSizeDict ~= nil then
			spriteSize = CCSizeMake(spriteSizeDict.w or 0, spriteSizeDict.h or 0)
		end

		local framesDict = dictionary.frames

		local registerX, registerY = 0, 0
		local frameNum, currentRegister, pRectDic, rect, offset, frame
		for spriteFrameName, currentFrame in pairs(framesDict) do
			currentFrame.pngIndex = currentFrame.pngIndex or 0
			if currentFrame.pngIndex == nIndex then
				frameNum = currentFrame.frameNum or 0
				currentRegister = currentFrame.registerPoint
				registerX = currentRegister.x or 0
				registerY = currentRegister.y or 0
				pRectDic = currentFrame.frame
				rect = CCRectMake(pRectDic.x or 0, pRectDic.y or 0
										, pRectDic.w or spriteSize.width, pRectDic.h or spriteSize.height)
				offset = ccp(registerX, -registerY)
				frame = CCSpriteFrame:createWithTexture(objText, rect, false, offset, rect.size)
				me.FrameCache:addSpriteFrame(frame, spriteFrameName)
			end
		end
	elseif nType == 1 then
		local dictionary
		if not mcDict[szContent] then
			dictionary = decodeJson(szContent)
			mcDict[szContent] = dictionary
		else
			dictionary = mcDict[szContent]
		end
		createMC(dictionary, szActions)
	elseif nType == 2 then
		mcDict = {}
	end
end

me.MCManager:registerLuaLoadHandle(MCLoader)
