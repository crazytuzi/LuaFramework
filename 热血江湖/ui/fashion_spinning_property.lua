-------------------------------------------------------
module(..., package.seeall)

local require = require

local ui = require("ui/base")

-------------------------------------------------------

wnd_fashion_spinning_property = i3k_class("wnd_fashion_spinning_property",ui.wnd_base)

local LAYER_SZJF2T = "ui/widgets/szjf2t"
local PROP_OPEN_CONDITION = i3k_db_fashion_base_info.prop_open_condition  --第二属性开启条件
local PROP_GROUP = 
{
	PROP_GROUP_ORIGIN 	= 1,
	PROP_GROUP_NEW 		= 2,
	PROP_GROUP_REWARD 	= 3,
}

function wnd_fashion_spinning_property:ctor()
	self.fashionId = 0
	self.propGroupId = nil  --选择的属性组(原属性0，新属性1，奖励属性2)

	self.prop = {}  	--原属性组
	self.prop1 = {}  	--属性组1
	self.prop2 = {}  	--属性组2
	self.propGrop = 
	{
		[1] = self.prop,
		[2] = self.prop1,
		[3] = self.prop2,	
	}
	
	self.originPower = 0   		 --原属性战力
	self.newPower = 0   		 --属性组1战力
	self.rewardPower = 0   		 --属性组2战力

	self.is_show_prop = false 	 --是否展示奖励属性
	self.consumeItems = {}  	 --再次精纺所需物品
end

function wnd_fashion_spinning_property:configure()
	local widgets = self._layout.vars
	self.rewardProp = widgets.reward_prop  	--奖励属性
	self.otherProp = widgets.other_prop  	--奖励属性的开启条件

	widgets.save_btn:onClick(self, self.saveProperty)
	widgets.refresh_btn:onClick(self, self.refreshProperty)

	for i = 1, 3 do
		widgets["select_btn_"..i]:setTag(i)
		widgets["select_btn_"..i]:onClick(self, self.selectProperty)
	end
end

function wnd_fashion_spinning_property:refresh(fashionId, property1, property2)
	self.fashionId = fashionId
	self.prop1 = property1
	self.prop2 = property2
	self.propGrop[PROP_GROUP.PROP_GROUP_NEW] = self.prop1
	self.propGrop[PROP_GROUP.PROP_GROUP_REWARD] = self.prop2

	self:updateOriginProprety()
	self:updateNewProperty()
	self:updateRewardProperty()
end

function wnd_fashion_spinning_property:updateOriginProprety()
	local widgets = self._layout.vars
	local prop = g_i3k_game_context:GetPropertyByFashionId(self.fashionId)  --vector
	local power = self:getFightPowerByProp(prop)
	self.originPower = power
	widgets.power_1:setText(power)
	
	widgets.scroll_1:removeAllChildren()
	for _, v in ipairs(prop) do
		local des = self:getPropertyDes(v.id, v.value)
		widgets.scroll_1:addItem(des)
	end

	self.propGrop[PROP_GROUP.PROP_GROUP_ORIGIN] = prop
end

function wnd_fashion_spinning_property:updateNewProperty()
	local widgets = self._layout.vars
	local power = self:getFightPowerByProp(self.prop1)
	widgets.power_2:setText(power)
	self.newPower = power

	if power > self.originPower then
		widgets.change_2:show()
		widgets.change_2:setImage(g_i3k_db.i3k_db_get_icon_path(174))
	elseif power < self.originPower then
		widgets.change_2:show()
		widgets.change_2:setImage(g_i3k_db.i3k_db_get_icon_path(175))
	else
		widgets.change_2:hide()
	end

	widgets.scroll_2:removeAllChildren()
	for _, v in pairs(self.prop1) do
		local des = self:getPropertyDes(v.id, v.value)
		widgets.scroll_2:addItem(des)
	end
end

function wnd_fashion_spinning_property:updateRewardProperty()
	local count = g_i3k_game_context:GetAllActivationFashionsCount()
	local is_show_prop = (count >= PROP_OPEN_CONDITION)
	self.rewardProp:setVisible(is_show_prop)
	self.otherProp:setVisible(not is_show_prop)

	local widgets = self._layout.vars
	if is_show_prop then
		local power = self:getFightPowerByProp(self.prop2)
		widgets.power_3:setText(power)
		self.rewardPower = power

		if power > self.originPower then
			widgets.change_3:show()
			widgets.change_3:setImage(g_i3k_db.i3k_db_get_icon_path(174))
		elseif power < self.originPower then
			widgets.change_3:show()
			widgets.change_3:setImage(g_i3k_db.i3k_db_get_icon_path(175))
		else
			widgets.change_3:hide()
		end

		widgets.scroll_3:removeAllChildren()
		for _, v in ipairs(self.prop2) do
			local des = self:getPropertyDes(v.id, v.value)
			widgets.scroll_3:addItem(des)
		end
	else
		widgets.open_condition:setText(string.format("拥有%s件以上时装可自动启动此项", PROP_OPEN_CONDITION))
	end
	
	if not is_show_prop then
		widgets["select_btn_"..3]:disableWithChildren()
	end
	self.is_show_prop = is_show_prop
end

function wnd_fashion_spinning_property:getPropertyDes(propId, value)
	local des = require(LAYER_SZJF2T)()
	local _t = i3k_db_prop_id[propId]
	local _desc = _t.desc
	_desc = _desc..":"
	des.vars.desc:setText(_desc)

	local maxValue = i3k_db_fashion_prop_max[propId] and i3k_db_fashion_prop_max[propId].maxValue or 0
	des.vars.max_img:setVisible(not (value < maxValue or maxValue == 0))
	
	des.vars.value:setText(i3k_get_prop_show(propId, value))
	return des
end

function wnd_fashion_spinning_property:selectProperty(sender)
	local tag = sender:getTag()
	local widgets = self._layout.vars
	self.propGroupId = tag - 1
	for i = 1, 3 do
		widgets["select_bg_"..i]:setVisible(i == tag)
	end
end

--保存精纺属性
function wnd_fashion_spinning_property:saveProperty(sender)
	if self.propGroupId then
		local newPower = self:getFightPowerByProp(self.propGrop[self.propGroupId + 1])
		i3k_sbean.fashion_save_worsted(self.fashionId, self.propGroupId, self.propGrop[self.propGroupId + 1], self.originPower, newPower)
	else
		g_i3k_ui_mgr:PopupTipMessage("您需要选择属性方可保存")
	end
end

--再次精纺
function wnd_fashion_spinning_property:refreshProperty(sender)
	local isItemEnough = self:isItemEnough()
	local isBetterProp = self:isBetterProp()
	if isItemEnough then
		if not isBetterProp then
			i3k_sbean.fashion_worsted(self.fashionId, self.consumeItems, true)
		else
			local desc = i3k_get_string(15541)
			local fun = (function(ok)
				if ok then
					i3k_sbean.fashion_worsted(self.fashionId, self.consumeItems, true)
				end
			end)
			g_i3k_ui_mgr:ShowMessageBox2(desc,fun)
		end
	else
		g_i3k_ui_mgr:PopupTipMessage("精纺所需物品不足")
	end
end

function wnd_fashion_spinning_property:isItemEnough()
	local isItemEnough = true  --道具是否足够
	local timesNow = g_i3k_game_context:GetFashionSpinningTimes(self.fashionId)
	self.consumeItems = {}
	local consumeItems = {}
	for i, v in ipairs(i3k_db_fashion_consume) do
		local cfg_times = v.spinningNum  --精纺次数
		if timesNow < cfg_times then
			consumeItems = v.item
			break
		end
	end
	if timesNow >= i3k_db_fashion_consume[#i3k_db_fashion_consume].spinningNum then
		consumeItems = i3k_db_fashion_consume[#i3k_db_fashion_consume].item
	end
	for _, v in ipairs(consumeItems) do
		if v.itemId ~= 0 and v.needCount ~= 0 then
			local haveCount = g_i3k_game_context:GetCommonItemCanUseCount(v.itemId)
			local _t = i3k_sbean.DummyGoods.new()
			_t.id = v.itemId
			_t.count = v.needCount
			table.insert(self.consumeItems, _t)

			if haveCount < v.needCount then
				isItemEnough = false
			end
		end
	end
	return isItemEnough
end

--是否有更好的属性（战力）
function wnd_fashion_spinning_property:isBetterProp()
	local isBetterProp = false
	if self.newPower > self.originPower or self.rewardPower > self.originPower then
		isBetterProp = true
	end
	return isBetterProp
end

--根据属性算战力，prop是vector
function wnd_fashion_spinning_property:getFightPowerByProp(prop)
	local propertyTb = g_i3k_game_context:ConvertVectorToMap(prop)
	local power = g_i3k_db.i3k_db_get_battle_power(propertyTb, true)
	return power
end

function wnd_create(layout)
	local wnd = wnd_fashion_spinning_property.new()
	wnd:create(layout)
	return wnd
end
