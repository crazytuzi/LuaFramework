-- 道具合成

local ItemComposeScene = class("ItemComposeScene", UFCCSBaseScene)

-- 参数改成这样为了配合道具获取途径模块统一调用
function ItemComposeScene:ctor( _, _, composeType, _, packScene, ... )

	self._mainLayer = nil
	self._roleInfo = nil
	self._speedbar = nil
	self._packScene = packScene
	self._composeType = composeType

	self.super.ctor(self, ...)
end

function ItemComposeScene:onSceneLoad( ... )
end

function ItemComposeScene:onSceneEnter( ... )
	if not self._mainLayer then
		self._mainLayer = require("app.scenes.bag.itemcompose.ItemComposeMainLayer").create(self._composeType, self._packScene)
	end
	self:addUILayerComponent("ItemComposeMainLayer", self._mainLayer, true)

	--顶部
	if not self._roleInfo then
   		self._roleInfo = G_commonLayerModel:getBagRoleInfoLayer()
   	end
   	self:addUILayerComponent("Topbar",self._roleInfo,true)

   	if not self._speedbar then
   		self._speedbar = G_commonLayerModel:getSpeedbarLayer()
   	end
   	self:addUILayerComponent("SpeedBar", self._speedbar, true)
end


function ItemComposeScene:onSceneExit( ... )
	self:removeComponent(SCENE_COMPONENT_GUI, "Topbar")
    self:removeComponent(SCENE_COMPONENT_GUI, "SpeedBar")
end

function ItemComposeScene:onSceneUnload( ... )
	-- body
end


return ItemComposeScene