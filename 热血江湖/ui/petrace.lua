-------------------------------------------------------
module(..., package.seeall)

local require = require

local ui = require("ui/base")

-------------------------------------------------------
local PETS_NUM = 3 -- 需要显示的宠物数量
local DIAMOND_TYPE = 1
local COIN_TYPE = 2

wnd_petRace = i3k_class("wnd_petRace",ui.wnd_base)

function wnd_petRace:ctor()
	self._selectPetID = nil
end

function wnd_petRace:configure()
	local widgets = self._layout.vars
	widgets.close:onClick(self, self.onCloseUI)
	widgets.helpBtn:onClick(self, self.onHelpBtn)
	widgets.diamondBtn:onClick(self, self.onDiamond)
	widgets.coinBtn:onClick(self, self.onCoin)
end

function wnd_petRace:onShow()
	self:updateRules()
end

function wnd_petRace:refresh(pets, data)
	self:updateModels(pets)
	self:updateMyVoteInfo(data)
end

function wnd_petRace:updateModels(pets)
	local widgets = self._layout.vars
	local cfg = i3k_db_common.petRacePets
	local totalScore = 0
	local myScore = 0
	for i = 1, PETS_NUM do
		if pets[i] then
			totalScore = totalScore + pets[i].allScore
			myScore = myScore + pets[i].myscore
			if pets[i].myscore > 0 then
				self._mySelectPetID = i -- 我当前投票的宠物id
			end
		end
	end
	self._myScore = myScore
	widgets.myVote:setText("当前竞猜积分："..self._myScore)

	for i = 1, PETS_NUM do
		local module = widgets["model"..i]
		local modelID = cfg[i].modelID
		ui_set_hero_model(module, modelID)
		module:setRotation(2)
		widgets["name"..i]:setText(i3k_get_string(cfg[i].name))
		local statusID = pets[i] and pets[i].statusId
		local statusNameID = i3k_db_common.petRaceStatus[statusID] and i3k_db_common.petRaceStatus[statusID].name
		local statusName = statusNameID and i3k_get_string(statusNameID) or "未知"
		widgets["status"..i]:setText("状态："..statusName)
		local rate = pets[i] and pets[i].allScore > 0 and pets[i].allScore or 0
		local scoreRate = i3k_db_common.petRace.scoreRate
		widgets["rate"..i]:setText("支持率："..rate * scoreRate)
		widgets["petBtn"..i]:onClick(self, self.onPetBtn, i)
		widgets["select"..i]:hide()
	end
end

function wnd_petRace:updateMyVoteInfo(data)
	if data.ticketPet ~= 0 then
		self._selectPetID = data.ticketPet -- 未投入是nil
	end
	local widgets = self._layout.vars
	if data.ticketPet ~= 0 then
		widgets["select"..data.ticketPet]:show()
	end
	self:updateVoteTimes(data.ticketTime)
end

-- InvokeUIFunction
function wnd_petRace:updateVoteTimes(voteTimes)
	self._ticketTime = voteTimes
	local widgets = self._layout.vars
	local allVoteTimes = i3k_db_common.petRace.allVoteTimes
	widgets.diamondTimes:setText("剩余次数："..(allVoteTimes - voteTimes))
end

-- function wnd_petRace:addMyScore(score)
	-- local widgets = self._layout.vars
	-- local newScore = self._myScore + score
	-- self._myScore = newScore
	-- widgets.myVote:setText("当前竞猜积分："..self._myScore)
-- end

-- 设置显示固定的内容
function wnd_petRace:updateRules()
	local widgets = self._layout.vars
	local scoreDiamond = self:getAddScore(DIAMOND_TYPE, 1)
	local scoreCoin = self:getAddScore(COIN_TYPE, 1)
	local rate = i3k_db_common.petRace.deltRate
	widgets.rules:setText(i3k_get_string(16008, scoreCoin, scoreDiamond, rate))

	local needCoin = i3k_db_common.petRace.needItems[COIN_TYPE].count
	widgets.coinCount:setText("x"..needCoin)
	local needDiamond = i3k_db_common.petRace.needItems[DIAMOND_TYPE].count
	widgets.diamondCount:setText("x"..needDiamond)
end


function wnd_petRace:onPetBtn(sender, index)
	if self._mySelectPetID and self._mySelectPetID ~= index then
		g_i3k_ui_mgr:PopupTipMessage("不可切换已经投票过的宠物")
		return
	end
	local widgets = self._layout.vars
	self._selectPetID = index
	for i = 1, PETS_NUM do
		widgets["select"..i]:setVisible(i == index)
	end
end

function wnd_petRace:checkNeedItems(itemType, count)
	local needItemID = i3k_db_common.petRace.needItems[itemType].id
	local needCount = i3k_db_common.petRace.needItems[itemType].count -- 每次使用数量
	local canUseCount = g_i3k_game_context:GetCommonItemCanUseCount(needItemID)
	if count * needCount <= canUseCount then
		return true
	else
		return false
	end
end

function wnd_petRace:checkLeftVoteTimes(times)
	local allVoteTimes = i3k_db_common.petRace.allVoteTimes
	local leftTimes = allVoteTimes - self._ticketTime
	return leftTimes >= times
end

-- 每次投票会增加的积分
function wnd_petRace:getAddScore(itemType, count)
	local score = i3k_db_common.petRace.needItems[itemType].score -- 每次使用数量
	return score * count
end

function wnd_petRace:checkVoteTime()
	local nowTime = i3k_game_get_time() % 86400
	local beginTime = i3k_db_common.petRace.beforeTime
	local endTime = i3k_db_common.petRace.startTime
	return nowTime <= endTime and beginTime <= nowTime
end

function wnd_petRace:checkVote(itemType, ticketNum)
	if not self._selectPetID then
		g_i3k_ui_mgr:PopupTipMessage("未选中任何宠物")
		return false
	end
	if not self:checkNeedItems(itemType, ticketNum) then
		local itemName = itemType == DIAMOND_TYPE and "元宝" or "铜钱"
		g_i3k_ui_mgr:PopupTipMessage(itemName.."不足")
		return false
	end
	if not self:checkLeftVoteTimes(ticketNum) then
		g_i3k_ui_mgr:PopupTipMessage("投票次数不足")
		return false
	end
	if not self:checkVoteTime() then
		g_i3k_ui_mgr:PopupTipMessage("当前不在投票时间范围内")
		return false
	end
	return true
end

function wnd_petRace:onDiamond(sender)
	local ticketNum = 1 -- 每次使用1次
	if not self:checkVote(DIAMOND_TYPE, ticketNum) then
		return
	end
	local score = self:getAddScore(DIAMOND_TYPE, ticketNum)
	i3k_sbean.petRunVote(self._selectPetID, 1, ticketNum, self._ticketTime, score)
end

function wnd_petRace:onCoin(sender)
	local ticketNum = 1 -- 每次使用1次
	if not self:checkVote(COIN_TYPE, ticketNum) then
		return
	end
	local score = self:getAddScore(COIN_TYPE, ticketNum)
	i3k_sbean.petRunVote(self._selectPetID, 0, ticketNum, self._ticketTime, score)
end

function wnd_petRace:onHelpBtn(sender)
	g_i3k_ui_mgr:ShowHelp(i3k_get_string(16009))
end

function wnd_create(layout)
	local wnd = wnd_petRace.new()
	wnd:create(layout)
	return wnd
end
