
-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_memoryCard = i3k_class("wnd_memoryCard",ui.wnd_base)

local DELAYTIME = 4 --延迟
local TIMEPOINT = 10
local RowItemCount = 6
local NeedCardTwo = 2
local NeedCardFour = 4

local TrueIcon = 8008
local FalseIcon = 8009

function wnd_memoryCard:ctor()
	self._id = nil
	self._cfg = nil
	self._timeFlag = false
	self._timeTick = 0
	self._limitTime = 0

	self._cardsInfo = {}
	self._isSelectedTb = {}
	self._matchCount = 0
	self._turnCo = nil
	self._rightCo = nil
	self._wrongCo = nil
end

function wnd_memoryCard:configure()
	local widgets = self._layout.vars
	widgets.close:onClick(self, self.onMyClose)

	self.timeLabel = widgets.timeLabel
end

function wnd_memoryCard:refresh(info)
	local widgets = self._layout.vars
	self._cfg = i3k_db_findMooncake[info.id]
	self._id = info.id

	self._limitTime = self._cfg.limitTime - DELAYTIME
	self.timeLabel:setText(i3k_get_show_rest_time(self._limitTime))
	self.timeLabel:setTextColor(g_i3k_get_cond_color(true))

	widgets.num:setText("剩余次数:" .. (self._cfg.dayTimes - info.useTimes))

	self:updateCardInfo()
	self:updateCardModel()
end

function wnd_memoryCard:updateCardInfo()
	self._cardsInfo = {}
	local minRand = self._cfg.imageTotal[1][1]
	local maxRand = self._cfg.imageTotal[1][2]
	local memoryCardFourNum = self._cfg.memoryCardFourNum
	local size = (maxRand - minRand + 1 - memoryCardFourNum) * NeedCardTwo + memoryCardFourNum * NeedCardFour
	self._cardsInfo = g_i3k_db.i3k_db_get_repeat_randrom_number(size, minRand, maxRand, NeedCardTwo, NeedCardFour, memoryCardFourNum)
end

function wnd_memoryCard:updateCardModel()
	local widgets = self._layout.vars
	widgets.scroll:removeAllChildren()
	widgets.scroll:stateToNoSlip()

	local allBars = widgets.scroll:addChildWithCount("ui/widgets/fanfanlet", RowItemCount, #self._cardsInfo)
	for i, v in ipairs(allBars) do
		local modelID = self._cardsInfo[i]
		local mcfg = i3k_db_models[modelID]
		v.vars.model:setSprite(mcfg.path)
		v.vars.model:setSprSize(mcfg.uiscale)
		v.vars.model:setRotation(math.pi*0.5, -math.pi*0.5)
		v.vars.model:playAction("stand")
		v.vars.btn:onClick(self, self.onSelectCard, i)
	end
end

function wnd_memoryCard:onSelectCard(sender, index)
	--[[
	if self._turnCo then
		return g_i3k_ui_mgr:PopupTipMessage("正在翻牌中")
	end
	]]
	if #self._isSelectedTb >= 2 then
		return
		--return g_i3k_ui_mgr:PopupTipMessage("已达到最大翻牌数量")
	end

	for _, v in ipairs(self._isSelectedTb) do
		if v.index == index then
			return g_i3k_ui_mgr:PopupTipMessage("该张卡片已经被您翻开，请您点击其他卡背")
		end
	end
	
	local allBars = self._layout.vars.scroll:getAllChildren()
	for i, v in ipairs(allBars) do
		if i == index then
			table.insert(self._isSelectedTb, {index = index, id = self._cardsInfo[index], widget = v})
			break
		end
	end
	self._turnCo = g_i3k_coroutine_mgr:StartCoroutine(function()
		self:playCardAni(index, "turn")
		g_i3k_coroutine_mgr.WaitForSeconds(1)
		if self._isSelectedTb and #self._isSelectedTb == 2 then
			self:checkIsMatch()
		end
		g_i3k_coroutine_mgr:StopCoroutine(self._turnCo)
		self._turnCo = nil
	end)
end

function wnd_memoryCard:checkIsMatch()
	local firstID = self._isSelectedTb[1].id
	local secondID = self._isSelectedTb[2].id
	local isRight = firstID == secondID
	self:playTurnResultAnis(isRight)
	self:playTurnCardAction(isRight)
end

function wnd_memoryCard:playTurnCardAction(isRight)
	if isRight then
		self._rightCo = g_i3k_coroutine_mgr:StartCoroutine(function()
			for _, v in ipairs(self._isSelectedTb or {}) do
				v.widget.vars.btn:hide()
				self:playCardAni(v.index, "right")
			end
			g_i3k_coroutine_mgr.WaitForSeconds(1)
			for _, v in ipairs(self._isSelectedTb or {}) do
				v.widget.vars.model:hide()
			end
			self._isSelectedTb = {}
			g_i3k_coroutine_mgr:StopCoroutine(self._rightCo)
			self._rightCo = nil
		end)
	else
		self._wrongCo = g_i3k_coroutine_mgr:StartCoroutine(function()
			g_i3k_coroutine_mgr.WaitForSeconds(1)
			for _, v in ipairs(self._isSelectedTb or {}) do
				self:playCardAni(v.index, "wrong")
			end
			self._isSelectedTb = {}
			g_i3k_coroutine_mgr:StopCoroutine(self._wrongCo)
			self._wrongCo = nil
		end)
	end
	if isRight then
		self._matchCount = self._matchCount + 2
		--g_i3k_ui_mgr:PopupTipMessage("匹配成功")
	else
		--g_i3k_ui_mgr:PopupTipMessage("匹配失败")
	end
end

--播放翻牌结果动画
function wnd_memoryCard:playTurnResultAnis(isRight)
	if isRight then
		self._layout.vars.false_icon:setImage(g_i3k_db.i3k_db_get_icon_path(TrueIcon))
		self._layout.anis.c_cuo.play()
	end
end

--播放卡片模型动作
function wnd_memoryCard:playCardAni(index, actName)
	local widgets = self._layout.vars
	local allBars = widgets.scroll:getAllChildren()
	if allBars[index] then
		local model = allBars[index].vars.model
		local btn = allBars[index].vars.btn
		if actName == "right" then
			model:playAction("death")
		elseif actName == "wrong" then
			model:pushActionList("turn02", 1)
			model:pushActionList("stand", -1)
			model:playActionList()
		elseif actName == "turn" then
			model:pushActionList("turn01", 1)
			model:pushActionList("stand01", -1)
			model:playActionList()
		end
	end
end

function wnd_memoryCard:startCountTime()
	self._timeFlag = true
end

function wnd_memoryCard:onUpdate(dTime)
	if self._timeFlag then
		self._timeTick = self._timeTick + dTime
		if self._timeTick >= 1 then
			self._timeTick = 0
			self._limitTime = self._limitTime - 1
			self._limitTime = self._limitTime >= 0 and self._limitTime or 0
			self.timeLabel:setText(i3k_get_show_rest_time(self._limitTime))
			self.timeLabel:setTextColor(g_i3k_get_cond_color(self._limitTime > TIMEPOINT))
			if self._limitTime <= 0 then
				self:gameOver()
			else
				if self._matchCount == #self._cardsInfo then
					self:gameSuccess()
				end
			end
		end
	end
end

--游戏成功
function wnd_memoryCard:gameSuccess()
	self._timeTick = 0
	self._timeFlag = false

	i3k_sbean.findMooncake_getItems(self._id)
end

--游戏结束
function wnd_memoryCard:gameOver()
	self._timeTick = 0
	self._timeFlag = false

	g_i3k_ui_mgr:AddTask(self, {}, function(ui)
		if g_i3k_ui_mgr:GetUI(eUIID_MessageBox2) then
			g_i3k_ui_mgr:CloseUI(eUIID_MessageBox2)
		end 

		g_i3k_ui_mgr:OpenUI(eUIID_FindFail) 
	end, 1) 
end

--是否再次尝试
function wnd_memoryCard:ifCountine()
	local callback = function(ok)
		if ok then
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_MemoryCard, "resetData")
			i3k_sbean.findMooncake_start(self._id)
		else
			self:onCloseUI()
		end
	end
	
	if g_i3k_ui_mgr:GetUI(eUIID_MessageBox2) then
		g_i3k_ui_mgr:CloseUI(eUIID_MessageBox2)
	end
	
	g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(16503), callback)
end

function wnd_memoryCard:resetData()
	self._isSelectedTb = {}
	self._matchCount = 0
	self._turnCo = nil
	self._rightCo = nil
	self._wrongCo = nil
end

function wnd_memoryCard:onHide()
	if self._turnCo then
		g_i3k_coroutine_mgr:StopCoroutine(self._turnCo)
		self._turnCo = nil
	end
	if self._rightCo then
		g_i3k_coroutine_mgr:StopCoroutine(self._rightCo)
		self._rightCo = nil
	end
	if self._wrongCo then
		g_i3k_coroutine_mgr:StopCoroutine(self._wrongCo)
		self._wrongCo = nil
	end
end

function wnd_memoryCard:onMyClose(sender)
	local callback = function(ok)
		if ok then
			g_i3k_ui_mgr:CloseUI(eUIID_MemoryCard)
		end 
	end
	
	g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(16501), callback)
end

function wnd_create(layout, ...)
	local wnd = wnd_memoryCard.new()
	wnd:create(layout, ...)
	return wnd;
end

