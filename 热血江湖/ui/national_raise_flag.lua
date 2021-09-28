-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_national_raise_flag = i3k_class("wnd_national_raise_flag", ui.wnd_base)

local LAYER_GUOQINGJIET = "ui/widgets/guoqingjiet"

function wnd_national_raise_flag:ctor()
	self._timeCounter = 0
	self._endTime = 0
	self._isShowLeftTime = false  --是否显示倒计时（旗子到顶端）
	self._index = 0 --记录红旗的位置
end

function wnd_national_raise_flag:configure()
	self.record_scroll = self._layout.vars.record_scroll
	self.leftTime = self._layout.vars.leftTime
	self.content = self._layout.vars.content

	self.add_oil_btn = self._layout.vars.add_oil_btn
	self.add_oil_btn:onClick(self, self.onAddSomeOilBtn)

	--self.rank_list_btn = self._layout.vars.rank_list_btn
	--self.rank_list_btn:onClick(self, self.onOilRankListBtn)

	--self.lucky_dog_btn = self._layout.vars.lucky_dog_btn
	--self.lucky_dog_btn:onClick(self, self.onLuckyDogBtn)

	self._layout.vars.close:onClick(self, self.onCloseUI)
	self._layout.vars.help_btn:onClick(self, self.onShowHelp)

	self.boxAni = {[1] = self._layout.anis.c_bx, [2] = self._layout.anis.c_bx3, [3] = self._layout.anis.c_bx5}
	self.flagAni = {[1] = self._layout.anis.c_sq1, [2] = self._layout.anis.c_sq2, [3] = self._layout.anis.c_sq3, [4] = self._layout.anis.c_sq4}
end

function wnd_national_raise_flag:refresh(info)
	self.myScore = info.score  --我的分数
	self.luckyRole = info.luckyRole
	self.startTime = info.lastTime  --倒计时开始时间
	self.dayOilTimes = info.dayOilTimes
	if self.startTime ~= 0 then
		self._isShowLeftTime = true
		self._endTime = self.startTime + i3k_db_national_activity_cfg.cool_time
		self.add_oil_btn:disableWithChildren()
		self.leftTime:hide()
		--self:refreshLeftTime()
	else
		self._isShowLeftTime = false
		self._endTime = 0
		self.add_oil_btn:enableWithChildren()
		self.leftTime:hide()
	end
	self.content:setText(i3k_get_string(16385))
	self:refreshBoxState(info)
end

function wnd_national_raise_flag:refreshBoxState(info)
	local curScore = info.allscore
	
	local widget = self._layout.vars
	local takedRewards = info.reward

	local function getStageInfo()
		for k = 1, 3 do
			local score = i3k_db_national_cheer_reward[k].level
			if curScore <= score then
				return k
			end
		end
		return #i3k_db_national_cheer_reward
	end
	local stage = getStageInfo()
	local interval = {0, 64, 84, 100}  --进度条区间
	local maxScore = i3k_db_national_cheer_reward[stage].level
	local minScore = (stage == 1) and 0 or i3k_db_national_cheer_reward[stage - 1].level
	local percent = interval[stage] + (curScore - minScore)/(maxScore - minScore) * (interval[stage + 1] - interval[stage])
	widget.progress:setPercent(percent <= 100 and percent or 100)

	for k = 1, 3 do
		local gifts = i3k_db_national_cheer_reward[k].reward
		local score = i3k_db_national_cheer_reward[k].level

		widget["reward_icon"..k]:setVisible(not takedRewards[score])
		widget["reward_get_icon"..k]:setVisible(takedRewards[score])

		if curScore > 0 and curScore >= score then
			local callback = function()
				local isDownFlag = false
				local isUpFlag = false
				i3k_sbean.sync_national_activity(isDownFlag, isUpFlag)
			end
			if not takedRewards[score] then
				self.boxAni[k].play()
			else
				self.boxAni[k].stop()
			end
			widget["reward_btn"..k]:onClick(self, self.onTakeFlagGift, {gifts = gifts, score = score, takedRewards = takedRewards[score], callback = callback})
		else
			self.boxAni[k].stop()
			widget["reward_btn"..k]:onClick(self, self.onShowFlagGiftInfo, {gifts = gifts, score = score})
		end
	end
end

function wnd_national_raise_flag:refreshLogInfo(history)
	self.record_scroll:removeAllChildren()
	for _, v in ipairs(history or {}) do
		local item = require(LAYER_GUOQINGJIET)()
		item.vars.des:setText(i3k_get_string(16376, v.name, v.oilTimes))
		self.record_scroll:addItem(item)
	end
end

--我要加油
function wnd_national_raise_flag:onAddSomeOilBtn(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_NationalAddOil)
	g_i3k_ui_mgr:RefreshUI(eUIID_NationalAddOil, self.dayOilTimes)
end

--加油榜
function wnd_national_raise_flag:onOilRankListBtn(sender)
	i3k_sbean.sync_oil_rank(self.myScore)
end

--幸运者
function wnd_national_raise_flag:onLuckyDogBtn(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_NationalLuckyDog)
	g_i3k_ui_mgr:RefreshUI(eUIID_NationalLuckyDog, self.luckyRole)
end

--领取宝箱奖励
function wnd_national_raise_flag:onTakeFlagGift(sender, data)
	local giftsTb = data.gifts

	if data.takedRewards then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16371))
	end

	local isEnoughTable = { }
	for _, v in ipairs(giftsTb) do
		isEnoughTable[v.id] = v.count
	end
	local isEnough = g_i3k_game_context:IsBagEnough(isEnoughTable)
	if isEnough then
		i3k_sbean.take_oil_reward(data.score, data.gifts, data.callback)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16372))
	end
end

--查看宝箱奖励
function wnd_national_raise_flag:onShowFlagGiftInfo(sender, data)
	local gift = {}
	local gifts = data.gifts
	for i = 1, #gifts do
		gift[i] = {ItemID = gifts[i].id, count = gifts[i].count}
	end
	g_i3k_ui_mgr:OpenUI(eUIID_RewardTips)
	g_i3k_ui_mgr:RefreshUI(eUIID_RewardTips, gift, data.score)
end

function wnd_national_raise_flag:refreshLeftTime()
	local leftTime = self._endTime - i3k_game_get_time()
	if leftTime <= 0 then --倒计时为0，刷新界面
		self._isShowLeftTime = false
		local isDownFlag = true
		local isUpFlag = false
		i3k_sbean.sync_national_activity(isDownFlag, isUpFlag)
		return
	end
	local hour = math.floor(leftTime/3600)
	local min = math.floor(leftTime%3600/60)
	local sec = leftTime - hour*3600 - min*60
	self.leftTime:setText(string.format("%02d时%02d分%02d秒后可加油", hour, min, sec))
end

function wnd_national_raise_flag:playDownFlagAni()
	if self.startTime == 0 then
		--self.flagAni[4].play()
	end
end

function wnd_national_raise_flag:playUpFlagAni(curScore)
	for k = 1, #self.flagAni do
		self.flagAni[k].stop()
	end

	local tempIndex = self._index
	for k = 1, 3 do
		local score = i3k_db_national_cheer_reward[k].level
		if curScore > 0 and curScore >= score then
			self._index = k
		end
	end

	if self._index ~= 0 and self._index ~= tempIndex then
		self.flagAni[self._index].play()
	end
end

--[[
function wnd_national_raise_flag:onUpdate(dTime)
	if self._isShowLeftTime then
		self._timeCounter = self._timeCounter + dTime
		if self._timeCounter > 1 then
			self:refreshLeftTime()
			self._timeCounter = 0
		end
	end
end
]]

function wnd_national_raise_flag:onShowHelp(sender)
	g_i3k_ui_mgr:ShowHelp(i3k_get_string(16386))
end

function wnd_create(layout, ...)
	local wnd = wnd_national_raise_flag.new();
		wnd:create(layout, ...);
	return wnd;
end
