UIManager = {}
UIManager.BagLayer = nil
UIManager.MainMenuLayer = nil
UIManager.HeroSettingLayer = nil
UIManager.BigMapLayer = nil
UIManager.SubMapLayer = nil
UIManager.LayerMap = {}

UIManager.Layers = {}
UIManager.curLayer = nil

function UIManager:newScene(sceneName)
	local scene = display.newScene(sceneName)
	game.runningScene = scene
	--[[local onEnter = function (scene)
	local children = scene:getChildren()
	if children ~= nil then
		for i = 1, #children do
			local child = children[i]
			if child.onEnter then
				child:onEnter()
			end
		end
	end
end

scene.onEnter = onEnter
local onExit = function (scene)
	local children = scene:getChildren()
	if children ~= nil then
		for i = 1, #children do
			local child = children[i]
			if child.onExit then
				child:onExit()
			end
		end
	end
end
scene.onExit = onExit]]
return scene
end

--
function UIManager:getSubMapLayer(msg)
	--if self.SubMapLayer == nil then
	self.SubMapLayer = require("game.Maps.SubMap").new()
	--	self.SubMapLayer:retain()
	--end
	self.SubMapLayer:setSubMapData(msg)
	return self.SubMapLayer
end

--±³°ü
function UIManager:getBagLayer(msg)
	--if self.BagLayer == nil then
	self.BagLayer = require("game.Bag.BagLayer").new(msg)
	--	self.BagLayer:retain()
	--end
	return self.BagLayer
end

--Ö÷²Ëµ¥
function UIManager:getMainMenuLayer(msg)
	--if self.MainMenuLayer == nil then
	self.MainMenuLayer = require("game.scenes.MainMenuLayer").new(msg)
	--	self.MainMenuLayer:retain()
	--end
	return self.MainMenuLayer
end

function UIManager:getHeroSettingLayer(msg)
	--if self.HeroSettingLayer == nil then
	self.HeroSettingLayer = require("game.form.HeroSettingLayer").new(msg)
	--	self.HeroSettingLayer:retain()
	--end
	if msg then
		self.HeroSettingLayer:setHeroIndex(msg.type, msg.pos)
	end
	self.HeroSettingLayer:needInit()
	return self.HeroSettingLayer
end

function UIManager:getBigMapLayer(msg)
	--if self.BigMapLayer == nil then
	self.BigMapLayer = require("game.Maps.BigMapLayer").new(msg)
	--	self.BigMapLayer:retain()
	--end
	self.BigMapLayer:setEnterMsg(msg)
	return self.BigMapLayer
end

function UIManager:releaseUI()
	if self.SubMapLayer ~= nil then
		self.SubMapLayer:removeSelf()
		--self.SubMapLayer:release()
	end
	if self.BagLayer ~= nil then
		self.BagLayer:removeSelf()
		--self.BagLayer:release()
	end
	if self.MainMenuLayer ~= nil then
		self.MainMenuLayer:removeSelf()
		--self.MainMenuLayer:release()
	end
	if self.HeroSettingLayer ~= nil then
		self.HeroSettingLayer:removeSelf()
		--self.HeroSettingLayer:release()
	end
	if self.BagLayer ~= nil then
		self.BagLayer:removeSelf()
		--self.BagLayer:release()
	end
	self.BagLayer = nil
	self.MainMenuLayer = nil
	self.HeroSettingLayer = nil
	self.BigMapLayer = nil
	self.SubMapLayer = nil
end

function UIManager:getLayer(layerName, newParam, initData)
	layer = require(layerName).new(newParam)
	layer:setNodeEventEnabled(true)
	layer:init(initData)
	return layer
end