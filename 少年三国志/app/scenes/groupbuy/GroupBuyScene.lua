-- GroupBuyScene.lua
-- 限时团购

local GroupBuyMainLayer = require("app.scenes.groupbuy.mainlayer.GroupBuyMainLayer")

local GroupBuyScene = class("GroupBuyScene", UFCCSBaseScene)

function GroupBuyScene:ctor( ... )
	self.super.ctor(self, ...)
end

function GroupBuyScene:onSceneLoad()
	self._mianLayer = GroupBuyMainLayer.create()
	self:addUILayerComponent("GroupBuyMainLayer", self._mianLayer, true)
end

function GroupBuyScene:onSceneEnter()
	self:_addCommonComponents()
end

function GroupBuyScene:onSceneExit()
	self:_removeCommonComponents()
end

function GroupBuyScene:_addCommonComponents()
  local topBar = G_commonLayerModel:getStrengthenRoleInfoLayer() 
  self:addUILayerComponent("Topbar", topBar, true) 
  local speedBar = G_commonLayerModel:getSpeedbarLayer()
  speedBar:setSelectBtn()
  self:addUILayerComponent("SpeedBar", speedBar, true)
  self:adapterLayerHeight(self._mianLayer, topBar, speedBar, 0, -20)
end

function GroupBuyScene:_removeCommonComponents()
	self:removeComponent(SCENE_COMPONENT_GUI, "Topbar")
  self:removeComponent(SCENE_COMPONENT_GUI, "SpeedBar")
end

return GroupBuyScene