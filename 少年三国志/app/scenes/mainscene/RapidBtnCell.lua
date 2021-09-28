--RapidBtnCell.lua
local EffectNode = require "app.common.effects.EffectNode"

local RapidBtnCell = class("RapidBtnCell", function ( ... )
	return CCSItemCellBase:create("ui_layout/mainscene_rapidCell.json")
end)


function RapidBtnCell:ctor( ... )
	self._effectNode = nil

	self:enableLabelStroke("Label_desc", Colors.strokeBrown, 2 )
end

function RapidBtnCell:updateItem( rapidInfo )
	if type(rapidInfo) ~= "table" then 
		__LogError("[RapidBtnCell:updateItem] wrong rapidInfo type")
		return 
	end

	local btn = self:getButtonByName("Button_rapid_btn")
	if btn and type(rapidInfo.icon) == "string" then 
		btn:loadTextureNormal(rapidInfo.icon, UI_TEX_TYPE_LOCAL)
	end

	self:showWidgetByName("Image_tip", type(rapidInfo.tipIcon) == "string")
	if type(rapidInfo.tipIcon) == "string" then
		local img = self:getImageViewByName("Image_tip")
		if img then 
			img:loadTexture(rapidInfo.tipIcon, UI_TEX_TYPE_LOCAL)
		end
	end

	if not self._effectNode and btn then 
		self._effectNode = EffectNode.new("effect_zhenzhan")
        self._effectNode:play()
        btn:addNode(self._effectNode, 2)
	end

	local desc = G_lang:isLangExist(rapidInfo.descId) and G_lang:get(rapidInfo.descId) or rapidInfo.descId
	self:showTextWithLabel("Label_desc", desc)

	local labelDesc = self:getLabelByName("Label_desc")
	if labelDesc then
		labelDesc:setPositionY(25)
	end

	self:registerBtnClickEvent("Button_rapid_btn", function ( ... )
		if rapidInfo.jumpScene == "CrossPVPScene" then
			-- 决战赤壁逻辑较复杂，所以从一个管理类来启动
			require("app.scenes.crosspvp.CrossPVP").launch()
		else
			local scene = GlobalFunc.generateSceneBySceneName(rapidInfo.jumpScene, rapidInfo.param)
			if scene then 
				uf_sceneManager:popToRootAndReplaceScene(scene)
			end
		end
	end)


end


return RapidBtnCell

