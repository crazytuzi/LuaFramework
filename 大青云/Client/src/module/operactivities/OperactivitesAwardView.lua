--[[
	商业活动  (抽奬) (屎一样的需求)
	2015年10月12日, PM 04:59:58
]]

local s_index = {2, 5, 9, 12}

_G.UIOperactivitesAward = BaseUI:new('UIOperactivitesAward');
function UIOperactivitesAward:Create()
	self:AddSWF('operactivitesAward.swf',true,"center");
end

function UIOperactivitesAward:OnLoaded(objSwf)
	-- 充值 vip
	objSwf.btnCharge.click = function() self:OnBtnChargeClick(); end
	objSwf.btnClose.click = function() self:Hide() end
	objSwf.awardBtn.click = function() self:TakeAward() end
	objSwf.vipBtn.click = function() FuncManager:OpenFunc(63) end
	RewardManager:RegisterListTips( objSwf.rewardList )

	objSwf.btnRules.rollOver =  function() TipsManager:ShowBtnTips(StrConfig["operactivites101"],TipsConsts.Dir_RightDown); end
	objSwf.btnRules.rollOut = function(e) TipsManager:Hide(); end
end

function UIOperactivitesAward:OnBtnChargeClick()
	Version:Charge()
end

function UIOperactivitesAward:OnShow()
	self.currentIconId = OperactivitiesConsts.iconHuodong3
	OperactivitiesController:ReqPartyList(self.currentIconId)

	if not OperactivitiesModel.isClickIconList[OperactivitiesConsts.iconHuodong3] then
		OperactivitiesModel.isClickIconList[OperactivitiesConsts.iconHuodong3] = true
		Notifier:sendNotification(NotifyConsts.UpdateOperActBtnIconState);
	end

	for i = 1, 14 do
		if i == 1 then
			self.objSwf['pfx' ..i]._visible = true
			self.startIndex = 1
		else
			self.objSwf['pfx' ..i]._visible = false
		end
	end
end

function UIOperactivitesAward:TakeAward()
	if self.IsTaking then
		return
	end

	local group = OperactivitiesModel:GetAwardGroup()
	local actVO, index = OperactivitiesModel:GetAwardVo(group)
	if not actVO then return end
	if actVO.param3 == 1 then
		self:GetAward()
		return
	end
	if not self.list then
		self.list = {}
	end
	self.IsTaking = true
	self.objSwf.awardBtn.disabled = true
	if actVO.param1 == 3 then
		self.endIndex = 1
		self.list[index] = 1
	elseif actVO.param1 == 4 then
		self.endIndex = 8
		self.list[index] = 8
	else
		self.endIndex = s_index[math.random(4)] + actVO.param1
		self.list[index] = self.endIndex
	end
	
	self.scrollList = {}
	local index = 0
	local allIndex = 0
	for i = 1, 56 do
		if i >= self.startIndex and i <= 42 + self.endIndex then
			allIndex = allIndex + 1
		end
	end
	for i = 1, 56 do
		if i >= self.startIndex and i <= 42 + self.endIndex then
			index = index + 1
			if index < 4 or index + 4 >= allIndex then
				local num = i%14
				if num == 0 then num = 14 end
				for i = 1, 3 do
					table.insert(self.scrollList, num)
				end
			elseif index < 8 or index + 8 >= allIndex then
				local num = i%14
				if num == 0 then num = 14 end
				for i = 1, 2 do
					table.insert(self.scrollList, num)
				end
			else
				local num = i%14
				if num == 0 then num = 14 end
				table.insert(self.scrollList, num)
			end
		end
	end
	self.startIndex = self.endIndex
end

--转完领奖
function UIOperactivitesAward:GetRewardClick()
	local group = OperactivitiesModel:GetAwardGroup()
	local actVO, index = OperactivitiesModel:GetAwardVo(group)
	-- local rewardList = RewardManager:ParseToVO(actVO.reward);
	OperactivitiesController:ReqGetPartyAward(actVO.id, 1)
end

function UIOperactivitesAward:UpdateUI()
	local objSwf = self.objSwf
	if not objSwf then return end
	objSwf.awardBtn.disabled = false
	local group = OperactivitiesModel:GetAwardGroup()
	local actVO, index = OperactivitiesModel:GetAwardVo(group)
	objSwf.rewardList.dataProvider:cleanUp();
	if not actVO.reward then
		OperactivitiesController:RespPartyInfo(group)
		return
	end
	if not self.award then
		self.award = {}
		for i, v in ipairs(RewardManager:Parse(actVO.reward)) do
			if i == 4 then
				self.award[1] = v
			elseif i == 5 then
				self.award[8] = v
			else
				for j = 1, 4 do
					self.award[s_index[j] - 1 + i] = v
				end
			end
		end
	end
	if not self.list then
		self.list = {}
	end
	local actList = OperactivitiesModel.groupList[group]
	for i, v in ipairs(actList) do
		if i < index or (i == index and v.param3 == 1) then
			if not self.list[i] then
				if v.param1 == 3 then
					self.list[i] = 1
				elseif v.param1 == 4 then
					self.list[i] = 8
				else
					self.list[i] = s_index[math.random(4)] + v.param1
				end
			end
		end
	end

	if self.list[index] then
		for i = 1, 14 do
			if i == self.list[index] then
				objSwf['pfx' ..i]._visible = true
				self.startIndex = i
			else
				objSwf['pfx' ..i]._visible = false
			end
		end
	end

	for i = 1, 14 do
		objSwf['icon' ..i]._visible = false
		for k, v in pairs(self.list) do
			if (i == v and k < index) or (i == v and actVO.isAward == 2) then
				objSwf['icon' ..i]._visible = true
				break
			end
		end
	end

	objSwf.rewardList.dataProvider:push( unpack(self.award));
	objSwf.rewardList:invalidateData();
	objSwf.txtcondition.text = actVO.eachTxt
	if actVO.eachTxt and actVO.eachTxt ~= "" then
		objSwf.vipBtn.visible = true
	else
		objSwf.vipBtn.visible = false
	end
	objSwf.txtAwardTimes.text = "本日已抽奖：" ..(index - 1) .."次"

	if actVO.isAward == 2 then
		objSwf.awardBtn.disabled = true
		objSwf.txtAwardTimes.text = "本日已抽奖：" ..index .."次"
	else
		objSwf.awardBtn.disabled = false
	end
	self.remainTime = OperactivitiesModel:GetGroupRemainTimeByGroupId(group)
	if self.remainTime and self.remainTime > 0 then
		if self.timerKey then 
			TimerManager:UnRegisterTimer(self.timerKey);
			self.timerKey = nil;
		end;
		self.timerKey = TimerManager:RegisterTimer(function() self:Ontimer() end,1000,0);
		self:Ontimer();
	end
end

function UIOperactivitesAward:Ontimer()
	local objSwf = self.objSwf
	if not objSwf then return end
	if not self.remainTime or self.remainTime < 0 then self.remainTime = 0 end
	local day,hour,mint,sec = CTimeFormat:sec2formatEx(self.remainTime)
	if day > 0 then
		objSwf.txtRemindTime.text = string.format(StrConfig["operactivites6"],day,hour,mint);
	else
		objSwf.txtRemindTime.text = string.format(StrConfig["operactivites7"],hour,mint);
	end
	
	
	self.remainTime = self.remainTime - 1
	if self.remainTime <= -10 then
		if self.timerKey then 
			TimerManager:UnRegisterTimer(self.timerKey);
			self.timerKey = nil;
			
		end;
		UIOperactivitesAward:Hide()
	end

	local day,hour,mint,sec = CTimeFormat:sec2formatEx(GetLocalTime())
	if hour == 0 and mint == 0 and sec >= 2 and sec <= 3 then
		if self.timerKey then 
			TimerManager:UnRegisterTimer(self.timerKey);
			self.timerKey = nil;
		end;
		
		UIOperactivitesAward:Hide()
	end	
end;

function UIOperactivitesAward:OnHide()
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timerKey);
		self.timerKey = nil;
	end
	self.IsTaking = false
	self.award = nil
	self.scrollList = nil
	UIOperactivitesGetAward:Hide()
end

function UIOperactivitesAward:ListNotificationInterests()
	return {
		NotifyConsts.OperActivityInitInfo,
		NotifyConsts.UpdateGroupInfo,
		NotifyConsts.OperActivityInitState,
		NotifyConsts.UpdateOperActAwardState,
	}
end

function UIOperactivitesAward:HandleNotification( name, body )
	if not self:IsShow() then
		return
	end 

	if name == NotifyConsts.OperActivityInitInfo then
		-- self:UpdateUI()
		OperactivitiesController:ReqPartyStatList(self.currentIconId)
	elseif name == NotifyConsts.OperActivityInitState then
		self:UpdateUI()
	elseif name == NotifyConsts.UpdateOperActAwardState then
		self:UpdateUI()
	elseif name == NotifyConsts.UpdateGroupInfo then
		self:UpdateUI()
	end	
end

local s_time = 1
function UIOperactivitesAward:Update()
	s_time = s_time + 1
	if not (s_time%2 == 0) then
		return
	end
	s_time = 1
	if not self.objSwf then return end
	if self.scrollList then
		local index = self.scrollList[1]
		for i = 1, 14 do
			if i == index then
				self.objSwf['pfx' ..i]._visible = true
				self.objSwf['pfx' ..i]:gotoAndPlay(25)
				self.objSwf['pfxl' ..i]:play()
			else
				self.objSwf['pfx' ..i]._visible = false
			end
		end
		table.remove(self.scrollList, 1)
		if #self.scrollList == 0 then
			self.scrollList = nil
			OperactivitiesController:ReqYunYingDraw()
			TimerManager:RegisterTimer(function() 
				if not self:IsShow() then
					return
				end
				self:GetAward()
				self.IsTaking = false end,
				500,1)
		end
	end
end

function UIOperactivitesAward:GetAward()
	local group = OperactivitiesModel:GetAwardGroup()
	local actVO, index = OperactivitiesModel:GetAwardVo(group)
	if actVO then
		local rewardList = RewardManager:ParseToVO(actVO.reward)
		if index == 4 then
			if VipController:GetVipType() < 1 then
				local func = function()
					UIVip:Show()
				end
				UIConfirm:Open("白银Vip以上特权玩家才可以领取奖励，是否前往开通？",func,nil,"开通", nil, nil, nil, nil, rewardList[actVO.param1 + 1].id .. "," .. rewardList[actVO.param1 + 1].count ..",1")
				return
			end
		end
		if index == 5 then
			if VipController:GetVipType() < 2 then
				local func = function()
					UIVip:Show()
				end
				UIConfirm:Open("黄金Vip以上特权玩家才可以领取奖励，是否前往开通？",func,nil,"开通", nil, nil, nil, nil, rewardList[actVO.param1 + 1].id .. "," .. rewardList[actVO.param1 + 1].count ..",1")
				return
			end
		end
		UIOperactivitesGetAward:OpenGetAward(rewardList[actVO.param1 + 1])
	end
end

function UIOperactivitesAward:IsTween()
	return true
end

function UIOperactivitesAward:GetPanelType()
	return 1
end

function UIOperactivitesAward:IsShowSound()
	return true
end