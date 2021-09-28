-- HeroSoulScene 将灵模块的主界面
-- the main scene of the hero soul module
local HeroSoulScene = class("HeroSoulScene", UFCCSBaseScene)

function HeroSoulScene:ctor(_, _, scenePack, szGoTo, ...)
	self._topBar		= nil
	self._bottomBar		= nil
	self._mainBody		= nil

	self._curLayerName  = nil 	-- name of the current active layer
	self._backLayerName = nil 	-- name of the layer to go back to
	self._willBack		= false	-- whether to go back to previous layer

	self._szGoTo		= szGoTo or require("app.const.HeroSoulConst").MAIN

	self.super.ctor(self, nil, nil, ...)
	G_GlobalFunc.savePack(self, scenePack)
end

function HeroSoulScene:onSceneEnter(...)
	self:registerKeypadEvent(true)

	-- add top bar and bottom bar
	if not self._topBar then
		self._topBar	= G_commonLayerModel:getStrengthenRoleInfoLayer()
		self:addUILayerComponent("TopBar", self._topBar, true)
	end

	if not self._bottomBar then
		self._bottomBar = G_commonLayerModel:getSpeedbarLayer()
		self:addUILayerComponent("BottomBar", self._bottomBar, true)
	end

	if self._szGoTo then
		self:goToLayer(self._szGoTo, false)
	end

	-- go to default main layer
	if not self._mainBody then
		self:goToLayer("HeroSoulMainLayer", false)
	end
end

function HeroSoulScene:onSceneExit()
	if self._topBar then
		self._topBar:setVisible(true)
		self:removeComponent(SCENE_COMPONENT_GUI, "TopBar")
		self._topBar = nil
	end
	if self._bottomBar then
		self._bottomBar:setVisible(true)
		self:removeComponent(SCENE_COMPONENT_GUI, "BottomBar")
		self._bottomBar = nil
	end
end


function HeroSoulScene:onBackKeyEvent()
	self:goBack()
    return true
end

function HeroSoulScene:goBack()
	--[[
	if self._willBack then
		self:goToLayer(self._backLayerName, false)
	elseif self._curLayerName ~= "HeroSoulMainLayer" then
		self:goToLayer("HeroSoulMainLayer", false)
	else
		local packScene = G_GlobalFunc.createPackScene(self)
    	if not packScene then 
       		packScene = require("app.scenes.mainscene.MainScene").new()
    	end
    	uf_sceneManager:replaceScene(packScene)
	end
	]]

	local packScene = G_GlobalFunc.createPackScene(self)
	if self._willBack then
		self:goToLayer(self._backLayerName, false, unpack(self._backLayerParams))
	elseif packScene then
    	uf_sceneManager:replaceScene(packScene)
    elseif self._curLayerName ~= "HeroSoulMainLayer" then
		self:goToLayer("HeroSoulMainLayer", false)
	else
		if not packScene then 
       		packScene = require("app.scenes.mainscene.MainScene").new()
    	end
    	uf_sceneManager:replaceScene(packScene)
	end
end

function HeroSoulScene:goToLayer(layerName, willBack, ...)
	-- remove current layer
	if self._mainBody then
		if self._mainBody.layerName == layerName then
			return
		end

		self:removeChild(self._mainBody)
	end

	-- add new layer
	self._mainBody = require("app.scenes.herosoul." .. layerName).create(...)
	self._mainBody:setZOrder(-1)
	self._mainBody.layerName = layerName
	self:addChild(self._mainBody)

	local isBagLayer = (layerName == "HeroSoulBagLayer")
	local bottomRef = (not isBagLayer) and self._bottomBar or nil
	self._bottomBar:setVisible(not isBagLayer)
	self:adapterLayerHeight(self._mainBody, self._topBar, bottomRef, -10, 0)

	-- record layer name
	self._willBack = willBack
	self._backLayerName = willBack and self._curLayerName or nil
	self._backLayerParams = willBack and {...} or {}
	self._curLayerName = layerName

	-- adapt layer
	if self._mainBody.adapterLayer then
		self._mainBody:adapterLayer()
	end

	if self._mainBody.jumpToPercent then
		self._mainBody:jumpToPercent()
	end
end


return HeroSoulScene