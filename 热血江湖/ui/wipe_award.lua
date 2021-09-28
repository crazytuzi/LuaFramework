-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_wipe_award = i3k_class("wnd_wipe_award", ui.wnd_base)

local LAYER_SDWC1 = "ui/widgets/sdwc1" -- title
local LAYER_SDWC2 = "ui/widgets/sdwc2" -- sTitle
local LAYER_SDWC3 = "ui/widgets/sdwc3" -- sItem
local LAYER_SDWC4 = "ui/widgets/sdwc4" -- item
local LAYER_SDWC5 = "ui/widgets/sdwc5" -- 蓝绿装备自动售卖转换能量


function wnd_wipe_award:ctor()
	self._card_data = nil
	self._coin = nil
	self._exp = nil
	self._normaol_data = nil
	self._item = {}
end

function wnd_wipe_award:configure()
	self._layout.vars.close_btn:onClick(self,self.onCloseUI)
end

function wnd_wipe_award:refresh(coin,exp,totlaNormal,totlCard,count, name, sweepCounts)
	self._coin = coin
	self._exp = exp
	self._normaol_data = totlaNormal
	self._card_data = totlCard
	self._count = count
	self._name = name
	self._sweepCounts = sweepCounts
	local delay = cc.DelayTime:create(0.15)--序列动作 动画播了0.15秒后显示奖励
	local seq =	cc.Sequence:create(cc.CallFunc:create(function ()
		self._layout.anis.c_dakai.play()
	end), delay, cc.CallFunc:create(function ()
		self:updateScroll()
	end))
	self:runAction(seq)
end

function wnd_wipe_award:updateScroll()
	local item_scroll = self._layout.vars.item_scroll
	if item_scroll then
		item_scroll:removeAllChildren()
		local count = self._count

		local tips_index = 0
		local RowitemCount = 8
		local use_height = 0
		for i=1,count do
			--TODO UIScrollList addItem形式和addChildWithCount形式混合添加的方式
			--每次使用addItemAndChild都会且只会将本次添加的全部控件以table_array的形式返回
			--次数标题
			self:setAutoSaleEquipLabel(item_scroll, self._normaol_data[i])
			local titleNode = item_scroll:addItemAndChild(LAYER_SDWC1)--addItem形式的只需要把控件的路径字符串传参数就行
			local str		
			if self._name then
				str = string.format("%s共%d次", self._name[i], self._sweepCounts[i])
			else
				str = string.format("第%d次", i)	
			end
	
			titleNode[1].vars.textLable:setText(str)--返回值是一个table_array，因为只加了一个，所以titleNode[1]就是添加的控件

			--扫荡奖励文本
			item_scroll:addItemAndChild(LAYER_SDWC2)--不需要对控件操作，所以不需要接取返回值

			--扫荡奖励经验、金钱
			local reward = item_scroll:addItemAndChild(LAYER_SDWC3)
			reward = reward[1]
			reward.vars.exp_icon:setImage(g_i3k_db.i3k_db_get_icon_path(107))
			reward.vars.exp_lable:setText(self._exp[i])
			reward.vars.coin_lable:setText(self._coin[i])

			--扫荡奖励物品
			local itemCount = #self._normaol_data[i]
			local items = self._normaol_data[i]
			local children = item_scroll:addItemAndChild(LAYER_SDWC4, 7, itemCount)--一行添加多个的参数：路径字符串、每行个数、总个数
			for k,v in ipairs(children) do
				local itemid = self._normaol_data[i][k].id
				local count = self._normaol_data[i][k].count
				tips_index = tips_index + 1
				self._item[tips_index] = itemid
				v.vars.countLabel:setText("x"..count)
				v.vars.item_btn:setTag(tips_index)
				v.vars.item_btn:onClick(self,self.onItemTips)
				v.vars.icon_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(itemid))
				v.vars.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemid,i3k_game_context:IsFemaleRole()))
			end

			--翻牌奖励文本
			local cardTitleNode = item_scroll:addItemAndChild(LAYER_SDWC2)
			local cardStr = string.format("%s", "副本翻牌奖励")
			cardTitleNode[1].vars.title:setText(cardStr)

			--翻牌奖励物品
			local itemCount2 = #self._card_data[i]
			local cardChildren = item_scroll:addItemAndChild(LAYER_SDWC4, 7, itemCount2)
			for k, v in ipairs(cardChildren) do
				local itemid = self._card_data[i][k].id
				local itemCount = self._card_data[i][k].count
				tips_index = tips_index + 1
				self._item[tips_index] = itemid
				v.vars.countLabel:setText("x"..itemCount)
				v.vars.item_btn:setTag(tips_index)
				v.vars.item_btn:onClick(self,self.onItemTips)
				v.vars.icon_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(itemid))
				v.vars.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemid,i3k_game_context:IsFemaleRole()))
			end
		end
	end
end

function wnd_wipe_award:checkIsEquip(id)
	return math.abs(id) > 10000000
end

-- 只出售蓝绿色的
function wnd_wipe_award:checkEquipRank(id)
	local rank = g_i3k_db.i3k_db_get_common_item_rank(id)
	return rank < 4 -- 小于紫色品质(白 绿 蓝)
end

function wnd_wipe_award:setAutoSaleEquipLabel(scroll, rewards)
	local cfg = g_i3k_game_context:GetUserCfg()
	local open = cfg:GetAutoSaleEquip()
	if open then
		local equipPower = 0
		for k, v in ipairs(rewards) do
			if self:checkIsEquip(v.id) and self:checkEquipRank(v.id) then
				local _equip = g_i3k_db.i3k_db_get_equip_item_cfg(v.id)
				local sell = _equip.sellItem * v.count
				equipPower = equipPower + sell
				i3k_log("id = "..v.id.." energy = ".._equip.sellItem .." count = "..v.count)
			end
		end
		local widget = require(LAYER_SDWC5)()
		widget.vars.title:setText(i3k_get_string(15524, equipPower))
		scroll:addItem(widget)
	end
	
	if cfg:GetAutoSaleDrug() then
		local widget = require(LAYER_SDWC5)()
		widget.vars.title:setText(i3k_get_string(17140))
		scroll:addItem(widget)
	end
end
function wnd_wipe_award:onItemTips(sender)
	local tag = sender:getTag()
	local itemid = self._item[tag]
	g_i3k_ui_mgr:ShowCommonItemInfo(itemid)
end

--[[function wnd_wipe_award:onClose(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_WIPEAward)
end--]]

function wnd_create(layout)
	local wnd = wnd_wipe_award.new();
		wnd:create(layout);
	return wnd;
end
