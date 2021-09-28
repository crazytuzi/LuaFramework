local TreasureSaoDangItem = class("TreasureSaoDangItem",function()
    return CCSItemCellBase:create("ui_layout/treasure_TreasureSaoDangItem.json")
end)

local EffectNode = require "app.common.effects.EffectNode"
require("app.cfg.treasure_fragment_info")
function TreasureSaoDangItem:ctor(...)
	self._timeLabel = self:getLabelByName("Label_time")
	self._expLabel = self:getLabelByName("Label_exp")
	self._moneyLabel = self:getLabelByName("Label_money")
	self._nameLabel = self:getLabelByName("Label_name")
	self._sizeLabel = self:getLabelByName("Label_size")

	self._robResultEffect = nil
	-- 结果
	self._failedLabel = self:getLabelByName("Label_failed")
	self._successLabel = self:getLabelByName("Label_success")
	self._fragmentLabel = self:getLabelByName("Label_fragmentName")

	self._timeLabel:createStroke(Colors.strokeBrown,1)
	self._sizeLabel:createStroke(Colors.strokeBrown,1)

	self._failedLabel:createStroke(Colors.strokeBrown,1)
	self._successLabel:createStroke(Colors.strokeBrown,1)
	self._nameLabel:createStroke(Colors.strokeBrown,1)
	self._fragmentLabel:createStroke(Colors.strokeBrown,1)
	
	self:getLabelByName("Label_rookieBuffValue"):setText("")

end


function TreasureSaoDangItem:_init()
	self._timeLabel:setText("")
	self._expLabel:setText("")
	self._moneyLabel:setText("")
	self._nameLabel:setText("")
	self._sizeLabel:setText("")
	self._failedLabel:setText("")
	self._fragmentLabel:setText("")

	if self._robResultEffect then
		self._robResultEffect:removeFromParentAndCleanup(true)
		self._robResultEffect = nil
	end
end
--[[
	local t = {
		id = data.base_id,
		battle_times = data.battle_times,
		break_reason = data.break_reason,
		rob_result = data.rob_result[i],
		turnover = data.turnover_rewards[i],
		awardList = data.rewards[i]
	}
]]
function TreasureSaoDangItem:updateSaoDangItem(data)
	self:_init()
	if not data then
		return
	end
	self._timeLabel:setText(G_lang:get("LANG_DUNGEON_GATENUM",{num=data.battle_times}))

	for i,v in ipairs(data.awardList) do
		if v.type == G_Goods.TYPE_EXP then
			-- expGood = G_Good.convert(v.type,v.value,v.size)
			self._expLabel:setText(v.size)
			--新手光环经验
    		self:getLabelByName("Label_rookieBuffValue"):setText(G_Me.userData:getExpAdd(v.size))

		elseif v.type == G_Goods.TYPE_MONEY then
			-- moneyGood = G_Good.convert(v.type,v.value,v.size)
			self._moneyLabel:setText(v.size)
		end
	end
	if data.rob_result then
		local fragment = treasure_fragment_info.get(data.id)
		if fragment then
			self._fragmentLabel:setText(fragment.name)
			self._fragmentLabel:setColor(Colors.qualityColors[fragment.quality])
			self:showWidgetByName("Panel_failed",false)
			self:showWidgetByName("Panel_success",true)
			self._robResultEffect = EffectNode.new("effect_dbts_star",nil)
			local panel = self:getPanelByName("Panel_success")
			panel:addNode(self._robResultEffect)
			self._robResultEffect:setPositionY(panel:getContentSize().height/2)
			self._robResultEffect:setPositionX(panel:getContentSize().width/2)
			self._robResultEffect:play()
		else
			self:showWidgetByName("Panel_failed",false)
			self:showWidgetByName("Panel_success",false)
		end
	else
		self._failedLabel:setText(G_lang:get("LANG_ROB_FRAGMENT_FAILED"))
		self:showWidgetByName("Panel_failed",true)
		self:showWidgetByName("Panel_success",false)
	end
	local good = G_Goods.convert(data.turnover.type,data.turnover.value,data.turnover.size)
	if not good then
		self:showWidgetByName("Panel_9",false)
	else
		self:showWidgetByName("Panel_9",true)
		self:getImageViewByName("Image_item_bg"):loadTexture(G_Path.getEquipIconBack(good.quality))
		self:getImageViewByName("Image_item"):loadTexture(good.icon)
		self:getButtonByName("Button_22"):loadTextureNormal(G_Path.getEquipColorImage(good.quality,good.type))
		self:getButtonByName("Button_22"):loadTexturePressed(G_Path.getEquipColorImage(good.quality,good.type))
		self._sizeLabel:setText("x" .. good.size)
		self._nameLabel:setText(good.name)
		self._nameLabel:setColor(Colors.qualityColors[good.quality])
	end
end

return TreasureSaoDangItem
	
