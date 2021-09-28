
-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_passExamGiftReward = i3k_class("wnd_passExamGiftReward",ui.wnd_base)

local DENGKEYOULIJLT2_WIDGET = "ui/widgets/dengkeyoulijlt2"
local DENGKEYOULIJLT1_WIDGET = "ui/widgets/dengkeyoulijlt1"

local RowitemCount = 3
local DICE_IMG = {[0] = 7449, [1] = 7443, [2] = 7444, [3] = 7445, [4] = 7446, [5] = 7447, [6] = 7448}

function wnd_passExamGiftReward:ctor()

end

function wnd_passExamGiftReward:configure()
	local widgets = self._layout.vars
	
	self.scroll = widgets.scroll
	self.diceScroll = widgets.diceScroll
	self.diceDesc = widgets.diceDesc
	widgets.ok:onClick(self, self.closeButton)
end

function wnd_passExamGiftReward:refresh(rewardID, diceList)
	local delay = cc.DelayTime:create(0.15)--序列动作 动画播了0.15秒后显示奖励
	local seq =	cc.Sequence:create(cc.CallFunc:create(function ()
		self._layout.anis.c_dakai.play()
	end), delay, cc.CallFunc:create(function ()
		self:updateDiceName(rewardID)
		self:updateDiceScroll(diceList)
		self:updateScroll(rewardID)
	end))
	self:runAction(seq)
end

function wnd_passExamGiftReward:updateDiceName(rewardID)
	self.diceDesc:setText(i3k_db_pass_exam_gift_reward[rewardID].name)
end

function wnd_passExamGiftReward:updateDiceScroll(diceList)
	self.diceScroll:removeAllChildren()
	for _, v in ipairs(diceList or {}) do
		local ui = require(DENGKEYOULIJLT1_WIDGET)()
		ui.vars.diceIcon:setImage(g_i3k_db.i3k_db_get_icon_path(DICE_IMG[v]))
		self.diceScroll:addItem(ui)
	end
	self.diceScroll:stateToNoSlip()
end

function wnd_passExamGiftReward:updateScroll(rewardID)
	local itemsData = i3k_db_pass_exam_gift_reward[rewardID].reward
	self.scroll:removeAllChildren()
	for i, e in pairs(itemsData) do
		local _layer = require(DENGKEYOULIJLT2_WIDGET)()
		local widget = _layer.vars
		local id = e.id
		widget.item_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
		widget.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id, g_i3k_game_context:IsFemaleRole()))
		local count = 0
		if e.count then
			count = e.count
		end
		widget.item_count:setText("x"..count)
		widget.suo:setVisible(g_i3k_db.i3k_db_get_reward_lock_visible(id))
		widget.item_name:setText(g_i3k_db.i3k_db_get_common_item_name(id))
		widget.item_btn:onClick(self, self.onItemInfo, id)
		self.scroll:addItem(_layer)
	end
end

function wnd_passExamGiftReward:onItemInfo(sender, itemid)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemid)
end

function wnd_passExamGiftReward:closeButton(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_PassExamGiftReward)
end

function wnd_create(layout, ...)
	local wnd = wnd_passExamGiftReward.new()
	wnd:create(layout, ...)
	return wnd;
end

