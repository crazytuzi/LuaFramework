-- Filename：	AnimationXML.lua
-- Author：		lichenyang
-- Date：		2015-3-24
-- Purpose：		特效动画解析模块
require "script/utils/extern"
require "script/utils/LuaUtil"
AnimationXML = class("AnimationXML")

function AnimationXML:ctor()
	self.cacheData = {}
	self.actionName = ""
	self.layerCount = 0
end

function AnimationXML:load( p_effectName )
	self.actionName = p_effectName
	--兼容lua 格式的动画
	local luaFilePath = CCFileUtils:sharedFileUtils():fullPathForFilename(self.actionName .. ".lua")
	if CCFileUtils:sharedFileUtils():isFileExist(luaFilePath) and Platform.getOS() ~= "wp" then
		self.cacheData = require (p_effectName)
		self.layerCount = table.count(self.cacheData)
	else
		local i = 0
		local xmlName = p_effectName.."_"..i..".xml"
		local xmlFullpath = CCFileUtils:sharedFileUtils():fullPathForFilename(xmlName)
		while CCFileUtils:sharedFileUtils():isFileExist(xmlFullpath) do
			self:loadXml(xmlName)
			i = i + 1
			xmlName = p_effectName.."_"..i..".xml"
		 	xmlFullpath = CCFileUtils:sharedFileUtils():fullPathForFilename(xmlName)
		end
		self.layerCount = i
	end
end

function AnimationXML:loadXml( p_xmlPath )
	-- local xmlPath = CCFileUtils:sharedFileUtils():fullPathForFilename(p_xmlPath)

	local xmlBuffer = CCString:createWithContentsOfFile(p_xmlPath):getCString()
	-- print(xmlBuffer)
	local xml = require "script/utils/LuaXml"
    local xmlTable = LuaXML.eval(xmlBuffer)

    local actionNode = xmlTable:find("action")
    self.cacheData[actionNode.actionName] = {}
    -- print(actionNode.actionName)
    for i=1,tonumber(actionNode.totalFrame) do
    	local frameXml 		= actionNode[i]:find("frameInfo")
    	local framInfo      = {}
    	-- print("frameXml",frameXml)
    	-- print_t(frameXml)
    	if frameXml[1] then
			framInfo.alpha      = (tonumber(frameXml[1].alpha) or 1) * 255
			framInfo.bitmapName = frameXml[1].bitmapName
			framInfo.scaleX     = tonumber(frameXml[1].scaleX) or 1
			framInfo.scaleY     = tonumber(frameXml[1].scaleY) or 1
			framInfo.rotation   = tonumber(frameXml[1].rotation) or 0
			framInfo.rotationX  = tonumber(frameXml[1].rotaionX) or 0
			framInfo.rotationY  = tonumber(frameXml[1].rotaionY) or 0
			local posInfo		= string.split(frameXml[1].position, ",")
			framInfo.posX   	= tonumber(posInfo[1])
			framInfo.posY   	= tonumber(posInfo[2])
		end
		framInfo.framNum 	= tonumber(frameXml.frame)
		framInfo.isKeyFrame  = frameXml.isKeyFrame
		self.cacheData[actionNode.actionName][framInfo.framNum] = framInfo
    end
    -- print_t(self.cacheData)
end

function AnimationXML:getXmlData()
	return self.cacheData
end

function AnimationXML:getLayerCount()
	return self.layerCount
end

function AnimationXML:getMaxFrameCount()
	local maxCount = 0
	for k,v in pairs(self.cacheData) do
		if table.count(v) > maxCount then
			maxCount = table.count(v)
		end
	end
	return maxCount
end

function AnimationXML:getLayerIndex( p_layerName )
	local strTable = string.split(p_layerName, "_")
	local index = tonumber(strTable[#strTable])
	return index
end

function AnimationXML:getBitmapNames( p_layerName )
	local nameArray = {}
	for k,v in pairs(self.cacheData[p_layerName]) do
		if nameArray[v.bitmapName] == nil and v.bitmapName ~= nil then
			nameArray[v.bitmapName] = v.bitmapName
		end
	end
	return nameArray
end

function AnimationXML:getKeyFrameCount()
	local keyCount = 0
	for layerName,layerData in pairs(self.cacheData) do	
		for k,v in pairs(layerData) do
			if v.isKeyFrame then
				keyCount = keyCount + 1
			end
		end
	end
	return keyCount
end