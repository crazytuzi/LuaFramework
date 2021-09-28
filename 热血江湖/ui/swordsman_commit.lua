-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_swordsman_commit = i3k_class("wnd_swordsman_commit", ui.wnd_base)

local ITEMWIDGET = "ui/widgets/daxiat1"

local ROWCOUNT = 7

function wnd_swordsman_commit:ctor()
	self._taskType = 0
	self._chooseId = 0
	self._itemId = 0
	self._showItem = nil
	self._isCommit = false
	self._timeCount = 0
end

function wnd_swordsman_commit:configure()
	self._layout.vars.close_btn:onClick(self, self.onCloseUI)
	self._layout.vars.sureBtn:onClick(self, self.onSureBtn)
	self._layout.vars.cancelBtn:onClick(self, self.onCancelBtn)
end

function wnd_swordsman_commit:refresh(taskType, id)
	self._taskType = taskType
	self._chooseId = id
	self._layout.vars.scroll:removeAllChildren()
	local count = #i3k_db_choose_items_reward[id]
	local allCount = math.ceil(count / ROWCOUNT) * ROWCOUNT
	local children = self._layout.vars.scroll:addItemAndChild(ITEMWIDGET, ROWCOUNT, allCount)
	for k, v in ipairs(children) do
		v.vars.chooseIcon:hide()
		v.vars.itemCount:hide()
		local itemId = i3k_db_choose_items_reward[id][k]
		if itemId and itemId ~= 0 then
			--v.vars.itemBtn:onClick(self, self.onChooseItem, itemId)
			v.vars.itemBtn:onTouchEvent(self, self.onChooseItem, itemId)
			v.vars.itemBg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(itemId))
			v.vars.itemIcon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemId, g_i3k_game_context:IsFemaleRole()))
			v.vars.lock:setVisible(itemId > 0)
		else
			v.vars.lock:hide()
		end
	end
end

function wnd_swordsman_commit:onSureBtn(sender)
	if self._itemId == 0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18298))
	elseif g_i3k_game_context:GetBagIsFull() then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18297))
	else
		self._isCommit = true
		--i3k_sbean.task_exchange_item(self._taskType, self._itemId, self._chooseId)
	end
end

function wnd_swordsman_commit:onChooseItem(sender, eventType, itemId)
	if not self._isCommit then
		if eventType == ccui.TouchEventType.began then
			if self._itemId ~= itemId then
				local children = self._layout.vars.scroll:getAllChildren()
				for k, v in ipairs(children) do
					if i3k_db_choose_items_reward[self._chooseId][k] and i3k_db_choose_items_reward[self._chooseId][k] == itemId then
						v.vars.chooseIcon:show()
					else
						v.vars.chooseIcon:hide()
					end
				end
				self._itemId = itemId
			end
			self._showItem = g_i3k_coroutine_mgr:StartCoroutine(function()
				g_i3k_coroutine_mgr.WaitForSeconds(1)
				self:showItemTips()
			end)
		elseif eventType == ccui.TouchEventType.ended then
			g_i3k_coroutine_mgr:StopCoroutine(self._showItem)
		elseif eventType == ccui.TouchEventType.canceled then
			g_i3k_coroutine_mgr:StopCoroutine(self._showItem)
		end
	end
end

function wnd_swordsman_commit:showItemTips()
	g_i3k_ui_mgr:ShowCommonItemInfo(self._itemId)
end

function wnd_swordsman_commit:onUpdate(dTime)
	if self._isCommit then
		self._layout.vars.processRoot:show()
		self._timeCount = self._timeCount + dTime
		self._layout.vars.progress:setPercent(self._timeCount / 3 * 100)
		if self._timeCount >= 3 then
			self._isCommit = false
			self._timeCount = 0
			self._layout.vars.processRoot:hide()
			i3k_sbean.task_exchange_item(self._taskType, self._itemId, self._chooseId)
		end
	else
		self._layout.vars.processRoot:hide()
	end
end

function wnd_swordsman_commit:onCancelBtn(sender)
	self._isCommit = false
	self._timeCount = 0
	self._layout.vars.processRoot:hide()
end

function wnd_swordsman_commit:onHide()
	g_i3k_coroutine_mgr:StopCoroutine(self._showItem)
end

function wnd_create(layout)
	local wnd = wnd_swordsman_commit.new()
	wnd:create(layout)
	return wnd
end