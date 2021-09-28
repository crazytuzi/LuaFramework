-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_diceMonster = i3k_class("wnd_diceMonster", ui.wnd_base)

function wnd_diceMonster:ctor()
	self._totalCount = 0
end

function wnd_diceMonster:configure()
	local widgets = self._layout.vars
	widgets.closeBtn:onClick(self, self.onCloseUI)
end

function wnd_diceMonster:onShow()

end

function wnd_diceMonster:refresh(groupID, info, isFlower)
	if not isFlower then
		self:setUI(info, groupID)
	else
		self:setFlowerUI(info, groupID)
	end
	local widgets = self._layout.vars
	widgets.rewardBtn:onClick(self, self.onRewardBtn, groupID)
end

-- 0 ~ 100
function wnd_diceMonster:updateProcessBar(cur)
	local total = self._totalCount
	local widgets = self._layout.vars
	local percent = cur / total * 100
	if percent > 100 then
		percent = 100
	end
	widgets.processBar:setPercent(percent)
	widgets.processLabel:setText(cur.."/"..total)
	if cur >= total then
		self:setRewardUI()
	else
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Dice, "updateDiceEventStatus", DICE_STATUS_DOING)
	end
end

function wnd_diceMonster:updateScroll(items)
	local widgets = self._layout.vars
	widgets.scroll:removeAllChildren()
	for k, v in ipairs(items) do
		local node = require("ui/widgets/hdjyt")()
		node.vars.bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v.id))
		node.vars.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.id, i3k_game_context:IsFemaleRole()))
		-- node.vars.lock:setVisible(v.id > 0)
		node.vars.count:setText(v.count)
		node.vars.btn:onClick(self, self.onItemTip, v.id)
		widgets.scroll:addItem(node)
	end
	self._rewards = items
end

function wnd_diceMonster:onItemTip(sender, itemID)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemID)
end

--------------------------------------------------------------------
function wnd_diceMonster:getTaskID(groupID)
	local roleLevel = g_i3k_game_context:GetLevel()
	local index = 0
	for k, v in ipairs(i3k_db_dice_monster) do
		if v.groupID == groupID then
			if v.level > roleLevel then
				return index
			else
				index = k
			end
		end
	end
	return index
end

function wnd_diceMonster:setUI(info, groupID)
	local taskID = self:getTaskID(groupID)
	local cfg = i3k_db_dice_monster[taskID]
	local widgets = self._layout.vars
	local monsterName = i3k_db_monsters[cfg.monsterID].name
	widgets.descLabel:setText("任务描述：击败".. monsterName ..cfg.monsterCount.."次")
	self._totalCount = cfg.monsterCount
	self:updateProcessBar(info.nowEventCounts)
	self:updateScroll(cfg.rewards)
	widgets.goBtn:onClick(self, self.onGoToMonster, cfg.monsterID)
	local widgets = self._layout.vars
	local data = { id = groupID, msg = "打怪任务"}
	widgets.cancelBtn:onClick(self, self.onCancelBtn, data)
end

function wnd_diceMonster:onGoToMonster(sender, monsterId)
	g_i3k_ui_mgr:CloseUI(eUIID_Dice)
	self:onCloseUI()
	local callBack = function ()
		g_i3k_game_context:SetAutoFight(true)
	end
	g_i3k_game_context:GotoMonsterPos(monsterId, callBack)
end


----------------------------送花任务也是相同的ui--------------------------------------
function wnd_diceMonster:getFlowerTaskID(groupID)
	local roleLevel = g_i3k_game_context:GetLevel()
	local index = 0
	for k, v in ipairs(i3k_db_dice_flower) do
		if v.groupID == groupID then
			if v.level > roleLevel then
				return index
			else
				index = k
			end
		end
	end
	return index
end


function wnd_diceMonster:setFlowerUI(info, groupID)
	local taskID = self:getFlowerTaskID(groupID)
	local cfg = i3k_db_dice_flower[taskID]
	local widgets = self._layout.vars
	local flowerCfg = i3k_db_dice_flower[taskID].needs
	widgets.descLabel:setText("任务描述：赠送任意玩家"..flowerCfg.count.."朵花")
	self._totalCount = flowerCfg.count
	self:updateProcessBar(info.nowEventCounts)
	self:updateScroll(i3k_db_dice_flower[taskID].rewards)
	widgets.goBtn:onClick(self, self.onGoFlowerBtn)
	local data = { id = groupID, msg = "送花任务"}
	widgets.cancelBtn:onClick(self, self.onCancelBtn, data)
end

function wnd_diceMonster:onGoFlowerBtn(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_Dice)
	self:onCloseUI()
end

-----------------------------------------
function wnd_diceMonster:onCancelBtn(sender, data)
	local msg = i3k_get_string(16396, data.msg)
	local callback = function (ok)
		if ok then
			self:onCloseUI()
			i3k_sbean.giveUpDiceEvent(data.id)
		end
	end
	g_i3k_ui_mgr:ShowMessageBox2(msg, callback)
end

-- 任务成功，显示领奖按钮
function wnd_diceMonster:setRewardUI()
	local widgets = self._layout.vars
	widgets.goBtn:hide()
	widgets.cancelBtn:hide()
	widgets.rewardBtn:show()
end

function wnd_diceMonster:onRewardBtn(sender, groupID)
	local rewards = self._rewards
	local isEnoughTable = {}
	for k, v in ipairs(rewards) do
		isEnoughTable[v.id] = v.count
	end
	local isEnough = g_i3k_game_context:IsBagEnough(isEnoughTable)
	if not isEnough then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16390))
		return
	end

	local callback = function ()
		g_i3k_ui_mgr:CloseUI(eUIID_DiceMonster)
		g_i3k_ui_mgr:ShowGainItemInfo(rewards)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Dice, "updateDiceEventStatus", DICE_STATUS_FINISH)
	end
	i3k_sbean.finishDiceEvent(groupID, 1, 1, callback)
end


function wnd_create(layout, ...)
	local wnd = wnd_diceMonster.new()
	wnd:create(layout, ...)
	return wnd;
end
