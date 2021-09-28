
-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_passExamGift = i3k_class("wnd_passExamGift",ui.wnd_base)

local TYPE_DIVINE = 1
local TYPE_RECORD = 2

local NEED_MODEL_NUM = 6
local TOTAL_MODEL_NUM = 6

local DICE_IMG = {[0] = 7449, [1] = 7443, [2] = 7444, [3] = 7445, [4] = 7446, [5] = 7447, [6] = 7448}

function wnd_passExamGift:ctor()
	self._info = nil
	self._co = nil
	self._isFirstOpen = true
end

function wnd_passExamGift:configure()
	local widgets = self._layout.vars
	widgets.close:onClick(self, self.onCloseUI)

	local startTimeText = g_i3k_get_MonthAndDayTime(i3k_db_pass_exam_gift_cfg.startTime)
	local endTimeText = g_i3k_get_MonthAndDayTime(i3k_db_pass_exam_gift_cfg.endTime)
	widgets.actTime1:setText(i3k_get_string(17440, startTimeText, endTimeText))
	widgets.actTime2:setText(i3k_get_string(17440, startTimeText, endTimeText))

	widgets.tips:setText(i3k_get_string(17441))

	self._modelList = {}
	for i = 1, TOTAL_MODEL_NUM do
		self._modelList[i] = widgets["diceModel"..i]
	end

	self._typeButton = {}
	self._typeButton = {widgets.tabBtn1, widgets.tabBtn2}
	for i, v in ipairs(self._typeButton) do
		v:onClick(self, self.onTabBtn, i)
	end

	widgets.divineBtn:onClick(self, self.onDivine)
end

function wnd_passExamGift:refresh(info, isFirstOpen)
	self._info = info
	self._isFirstOpen = isFirstOpen
	self:onTypeChanged(TYPE_DIVINE)
end

function wnd_passExamGift:onTabBtn(sender, showType)
	self:onTypeChanged(showType)
end

function wnd_passExamGift:onTypeChanged(showType)
	local widgets = self._layout.vars
	for _, v in ipairs(self._typeButton) do
		v:stateToNormal()
	end
	self._typeButton[showType]:stateToPressed()

	widgets.rootDivine:setVisible(showType == TYPE_DIVINE)
	widgets.rootRecord:setVisible(showType == TYPE_RECORD)

	if showType == TYPE_DIVINE then
		self:updateDivineUI()
	elseif showType == TYPE_RECORD then
		self:updateRecordUI()
	end
end

function wnd_passExamGift:updateDivineUI()
	local widgets = self._layout.vars
	local info = self._info

	local remainTime = i3k_db_pass_exam_gift_cfg.dayJoinTime - info.dayTimes
	local item = i3k_db_pass_exam_gift_cfg.cost
	local isItemEnough = g_i3k_game_context:GetCommonItemCanUseCount(item.id) >= item.count

	widgets.canDevineRed:setVisible(remainTime > 0 and isItemEnough)
	widgets.remainTime:setText(i3k_get_string(17442, remainTime))

	widgets.item:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(item.id))
	widgets.itemIcon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(item.id, g_i3k_game_context:IsFemaleRole()))
	widgets.itemCount:setText("x" .. item.count)
	widgets.itemCount:setTextColor(isItemEnough and "ff377f0c" or "ffff0000")
	widgets.itemBtn:onClick(self, self.onItemTips, item.id)
	
	--初始模型位置和动作
	if self._isFirstOpen then
		local modelList = {}
		for i = 1, NEED_MODEL_NUM do
			table.insert(modelList, self._modelList[i])
		end
		self:initDiceModel(modelList)
	end
end

function wnd_passExamGift:onDivine(sender)
	local info = self._info
	local item = i3k_db_pass_exam_gift_cfg.cost
	local remainTime = i3k_db_pass_exam_gift_cfg.dayJoinTime - info.dayTimes
	if remainTime <= 0 then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17443))
	end
	if g_i3k_game_context:GetCommonItemCanUseCount(item.id) < item.count then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17444))
	end
	--卜算
	i3k_sbean.admission_conduct(item)
end

--随机骰子模型组合
function wnd_passExamGift:getRandModelList()
	local modelList = {}
	local list = g_i3k_db.i3k_db_get_no_repeat_randrom_number(NEED_MODEL_NUM, TOTAL_MODEL_NUM)
	for _, index in ipairs(list) do
		table.insert(modelList, self._modelList[index])
	end
	return modelList
end

--初始化骰子模型
function wnd_passExamGift:initDiceModel(modelList)
	for _, v in ipairs(self._modelList) do
		self:setIsShowModel(v, false)
	end
	for _, v in ipairs(modelList) do
		self:setModel(v)
		self:setIsShowModel(v, true)
	end
end

--设置骰子模型
function wnd_passExamGift:setModel(model)
	local modelID = 2830
	local path = i3k_db_models[modelID].path
	local uiscale = i3k_db_models[modelID].uiscale
	model:setSprite(path)
	model:setSprSize(uiscale)
	model:setRotation(-math.pi*0.5, -math.pi*1.8)
end

--是否显示骰子模型
function wnd_passExamGift:setIsShowModel(model, isShow)
	model:setVisible(isShow)
end

--InvokeUIFunction播放骰子动画
function wnd_passExamGift:playDiceAction(rewardID)
	self._co = g_i3k_coroutine_mgr:StartCoroutine(function()
		self:setButtonTouchEvent(false)

		local diceList = g_i3k_db.i3k_db_get_passExamGift_diceList(rewardID)
		local modelList = self:getRandModelList()
		self:initDiceModel(modelList)
		for i, v in ipairs(modelList) do
			v:playAction(tostring(diceList[i]))
		end
		g_i3k_coroutine_mgr.WaitForSeconds(2.75)
		for i, v in ipairs(modelList) do
			v:playAction(tostring(diceList[i]).."loop")
		end
		g_i3k_coroutine_mgr.WaitForSeconds(0.3)

		self:showGetItemInfo(rewardID, diceList)
		self:setButtonTouchEvent(true)
		i3k_sbean.admission_sync_info()

		g_i3k_coroutine_mgr:StopCoroutine(self._co)
		self._co = nil
	end)
end

function wnd_passExamGift:showGetItemInfo(rewardID, diceList)
	g_i3k_ui_mgr:OpenUI(eUIID_PassExamGiftReward)
	g_i3k_ui_mgr:RefreshUI(eUIID_PassExamGiftReward, rewardID, diceList)
end

--设置按钮触摸事件
function wnd_passExamGift:setButtonTouchEvent(isTouch)
	self._layout.vars.close:setTouchEnabled(isTouch)
	self._layout.vars.divineBtn:setTouchEnabled(isTouch)
	for _, v in ipairs(self._typeButton) do
		v:setTouchEnabled(isTouch)
	end
end

function wnd_passExamGift:updateRecordUI()
	local widgets = self._layout.vars
	local info = self._info

	widgets.scroll:removeAllChildren()
	for rewardID, v in ipairs(i3k_db_pass_exam_gift_reward) do
		local ui = require("ui/widgets/dengkeyoulit")()
		ui.vars.desc:setText(v.name..v.diceDesc)

		for i = 1, 6 do
			local diceNum = v.diceShow[i]
			if diceNum then
				ui.vars["dice"..i]:setImage(g_i3k_db.i3k_db_get_icon_path(DICE_IMG[diceNum]))
			end
		end
		for i = 1, 3 do
			local item = v.reward[i]
			if item then
				ui.vars["item"..i]:show()
				ui.vars["item"..i]:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(item.id))
				ui.vars["itemIcon"..i]:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(item.id, g_i3k_game_context:IsFemaleRole()))
				ui.vars["itemCount"..i]:setText("x"..item.count)
				ui.vars["itemSuo"..i]:setVisible(g_i3k_db.i3k_db_get_reward_lock_visible(item.id))
				ui.vars["itemBtn"..i]:onClick(self, self.onItemTips, item.id)
			else
				ui.vars["item"..i]:hide()
			end
		end

		local getTimes = info.rewardTimes[rewardID] and info.rewardTimes[rewardID] or 0
		ui.vars.getTimes:setText(i3k_get_string(17445, getTimes))
		widgets.scroll:addItem(ui)
	end
end

function wnd_passExamGift:onItemTips(sender, itemId)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemId)
end

function wnd_passExamGift:onHide()
	if self._co then
		g_i3k_coroutine_mgr:StopCoroutine(self._co)
		self._co = nil
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_passExamGift.new()
	wnd:create(layout, ...)
	return wnd;
end

