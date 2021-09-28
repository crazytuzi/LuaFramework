module(..., package.seeall)

local require = require

local ui = require("ui/base")

wnd_fiveElements = i3k_class("fiveElements",ui.wnd_base)

local ALL_FIVE_ELEMENTS = 5
local ALL_FIVE_ELEMENTS_LOCK = 4

function wnd_fiveElements:ctor()
	self._finishFlagList = {}
	self._btnList = {}
	self._isFinishList = {}
	self._selectList = {}
	self._animationList = {}
	self._openingEventIndex = 0
	self._currSelectIndex = 0
end

function wnd_fiveElements:configure()
	local widget = self._layout.vars
	local animation = self._layout.anis

	self.close_btn = widget.close_btn
	self.close_btn:onClick(self, self.onCloseUI)
	
	self.start_btn = widget.start_btn
	self.start_btn:onClick(self, self.onStartBtnClick)
	
	self.pet_btn = widget.pet_btn
	self.pet_btn:onClick(self, self.onPetBtnClick)
	
	self.help_btn = widget.help_btn
	self.help_btn:onClick(self, self.onHelpBtnClick)
	
	self.start_text = widget.start_text
	self.title_text = widget.title_text
	self.desc_text = widget.desc_text
	self.detail_text = widget.detail_text
	
	for i = 1, ALL_FIVE_ELEMENTS do
		self._btnList[i] = widget['btn' .. i]
		self._btnList[i]:onClick(self, self.onFiveElementsBtnClick, i)
		self._isFinishList[i] = widget['isFinish' .. i]
		self._selectList[i] = widget['select' .. i]
		self._animationList[i] = animation['c_jh0' .. i]
		self._finishFlagList[i] = false
	end
	local startIndex = g_i3k_game_context:getFiveElementsStartIndex()
	local finishCount = g_i3k_game_context:getFiveElementsFinishCount()
	self._openingEventIndex = startIndex
	for i = 1, finishCount do
		local currNum = startIndex+i-1>ALL_FIVE_ELEMENTS and startIndex+i-1-ALL_FIVE_ELEMENTS or startIndex+i-1
		local nextNum = currNum+1>ALL_FIVE_ELEMENTS and currNum+1-ALL_FIVE_ELEMENTS or currNum+1
		self._finishFlagList[currNum] = true
		self._openingEventIndex = nextNum
	end
end

function wnd_fiveElements:refresh()
	local finishCount = g_i3k_game_context:getFiveElementsFinishCount()
	self.title_text:setVisible(false)
	self.desc_text:setVisible(false)
	self.detail_text:setVisible(false)
	self.start_btn:SetIsableWithChildren(false)
	local isStart = self._openingEventIndex == 0
	local isFinish = g_i3k_game_context:getFiveElementsUnlockFlag() == 0 and finishCount == ALL_FIVE_ELEMENTS_LOCK or finishCount == ALL_FIVE_ELEMENTS
	if isStart then
		self.start_text:setText(i3k_get_string(18168))
		self.start_text:setVisible(true)
	elseif isFinish then
		self.start_text:setText(i3k_get_string(18183))
		self.start_text:setVisible(true)
	elseif g_i3k_game_context:getFiveElementsEnterTimes() == i3k_db_five_elements.enterTimes then
		self.start_text:setText(i3k_get_string(18174))
		self.start_text:setVisible(true)
	else
		self.start_text:setVisible(false)
	end
	for i = 1, ALL_FIVE_ELEMENTS do
		self._isFinishList[i]:setVisible(self._finishFlagList[i])
		self._selectList[i]:setVisible(false)
		self:setAnimationStatus(self._animationList[i], i)
		local isOpen = g_i3k_game_context:isFiveElementsSelectedOpening(i, self._openingEventIndex) and self._openingEventIndex ~= 0
		if isOpen then
			self:changeSelect(i)
			self.start_btn:SetIsableWithChildren(true)
		end
	end
end

function wnd_fiveElements:onStartBtnClick(sender)
	if g_i3k_game_context:IsInRoom() or g_i3k_game_context:getMatchState() ~= 0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(142))
		return
	end
	local function func()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_FiveElements,"startCB")
	end
	g_i3k_game_context:CheckMulHorse(func)
end

function wnd_fiveElements:onPetBtnClick(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_SuicongDungeonPlay)
	g_i3k_ui_mgr:RefreshUI(eUIID_SuicongDungeonPlay)
end

function wnd_fiveElements:onHelpBtnClick(sender)
	g_i3k_ui_mgr:ShowHelp(i3k_get_string(18167))
end

function wnd_fiveElements:onFiveElementsBtnClick(sender, currSelect)
	self:changeSelect(currSelect)
	local isOpen = g_i3k_game_context:isFiveElementsSelectedOpening(currSelect, self._openingEventIndex)
	self.start_btn:SetIsableWithChildren(isOpen)
end

--切换按钮
function wnd_fiveElements:changeSelect(currSelect)
	self._currSelectIndex = currSelect
	self.title_text:setVisible(currSelect ~= 0)
	self.detail_text:setVisible(currSelect ~= 0)
	self.detail_text:setText(i3k_get_string(18175 + currSelect))
	self.desc_text:setVisible(currSelect ~= 0)
	self.desc_text:setText(i3k_get_string(18168 + currSelect))
	for i = 1, ALL_FIVE_ELEMENTS do
		self._selectList[i]:setVisible(currSelect == i)
	end
end

function wnd_fiveElements:startCB()
	local hero_lvl = g_i3k_game_context:GetLevel()

	local func3 = function () -- 随从
		local allPets, playPets = g_i3k_game_context:GetYongbingData()
		local count = 0
		if playPets[DUNGEON] then
			count = #playPets[DUNGEON]
		end
		local have = 0
		for k,v in pairs(allPets) do
			have = have + 1
		end
		local max_count = 1
		local first = g_i3k_db.i3k_db_get_common_cfg().posUnlock.first;
		local second = g_i3k_db.i3k_db_get_common_cfg().posUnlock.second;
		local third = g_i3k_db.i3k_db_get_common_cfg().posUnlock.third;
		if hero_lvl >= third then
			max_count = 3
		elseif hero_lvl >= second then
			max_count = 2
		end
		if count < max_count  and have - count > 0 then
			local fun = (function(ok)
				if ok then
					g_i3k_ui_mgr:OpenUI(eUIID_SuicongDungeonPlay)
					g_i3k_ui_mgr:RefreshUI(eUIID_SuicongDungeonPlay)
				else
					self:enterDungeon()
				end
			end)
			local desc = i3k_get_string(286)
			g_i3k_ui_mgr:ShowMessageBox2(desc,fun)
			return
		else
			self:enterDungeon()
		end
	end

	local func2 = function ()  --队伍
		local teamId = g_i3k_game_context:GetTeamId()
		if teamId ~= 0 then
			local fun = (function(ok)
				if ok then
					func3()
				else
					return
				end
			end)
			g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(68),fun)
			return
		else
			func3()
			return
		end
		self:enterDungeon()
	end

	local func1 = function ()
		if not g_i3k_db.i3k_db_get_five_element_can_enter() then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(778))
			return
		end
		
		if hero_lvl < i3k_db_five_elements.openLevel then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(60))
			return
		end
		
		if g_i3k_game_context:getFiveElementsEnterTimes() >= i3k_db_five_elements.enterTimes then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(71))
			return
		end
		
		func2()
	end

	func1()

end

function wnd_fiveElements:enterDungeon()
	local fun = function ()
		local _, playPets = g_i3k_game_context:GetYongbingData()
		if self._openingEventIndex == 0 then
			i3k_sbean.five_elements_org(self._currSelectIndex, playPets[DUNGEON])
		else
			i3k_sbean.five_elements_start(playPets[DUNGEON])
		end
	end
	g_i3k_game_context:CheckJudgeEmailIsFull(fun)
end

function wnd_fiveElements:setAnimationStatus(anis, i)
	local isOpen = g_i3k_game_context:isFiveElementsSelectedOpening(i, self._openingEventIndex) and self._openingEventIndex ~= 0
	if isOpen then
		anis:play()
	else
		anis:stop()
	end
end
function wnd_create(layout)
	local wnd = wnd_fiveElements.new()
	wnd:create(layout)
	return wnd
end
