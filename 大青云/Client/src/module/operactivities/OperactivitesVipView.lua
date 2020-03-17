--[[
	商业活动  (特殊)
	2015年10月12日, PM 04:59:58
]]

_G.UIOperactivitesVipGet = BaseUI:new('UIOperactivitesVipGet');
UIOperactivitesVipGet.remainTime = 0
UIOperactivitesVipGet.timerKey = nil;
UIOperactivitesVipGet.itemList = {}
UIOperactivitesVipGet.lastTime = 0

function UIOperactivitesVipGet:Create()
	self:AddSWF('operactivitesVipPanel.swf',true,nil);
end

function UIOperactivitesVipGet:OnLoaded(objSwf)
	for i = 1, 3 do
		objSwf['btn_getReward' ..i].click = function()
			self:GetRewardClick(i)
		end
	end
	for i = 1, 3 do
		objSwf['chargeBtn' ..i].click = function() self:OnBtnVipClick(); end
	end

	RewardManager:RegisterListTips(objSwf.rewardList1)
	RewardManager:RegisterListTips(objSwf.rewardList2)
	RewardManager:RegisterListTips(objSwf.rewardList3)
end

function UIOperactivitesVipGet:OnBtnVipClick()
	UIVip:Show()
end

function UIOperactivitesVipGet:OnShow()
	local group = OperActUIManager.currentGroupId	
	
	OperactivitiesController:RespPartyInfo(group)
end

function UIOperactivitesVipGet:UpdateUI()
	local objSwf = self.objSwf
	if not objSwf then return end
	
	local group = OperActUIManager.currentGroupId	

	objSwf.txtGroupTxt.text = OperactivitiesModel:GetGroupTxtByGroupId(group)
	objSwf.txtRemindTime.text = ""

	local actList = OperactivitiesModel.groupList[group]
	for i = 1, 3 do
		local vo = actList[i]
		if not vo then
			UIMainOperActivites:Hide()
			return
		end
		objSwf['rewardList' ..i].dataProvider:cleanUp();
		objSwf['rewardList' ..i].dataProvider:push( unpack(RewardManager:Parse(vo.reward )));
		objSwf['rewardList' ..i]:invalidateData();	
		local state = vo:GetIsArawdState() or 0
		objSwf["mcYilingqu" ..i]._visible = false
		objSwf["chargeBtn"..i]._visible = false
		objSwf["effectAward" ..i]._visible = false
		if state == 2 then
			objSwf['btn_getReward' ..i]._visible = false
			objSwf["mcYilingqu" ..i]._visible = true
			objSwf["mcYilingqu" ..i]:gotoAndStop(18)
		elseif state == 1 then
			objSwf['btn_getReward' ..i]._visible = true
			objSwf["effectAward" ..i]._visible = true
		else
			objSwf['btn_getReward' ..i]._visible = false
			objSwf["chargeBtn"..i]._visible = true
		end
		local getcount = vo.count or 0
		local rtime = vo.receiveTime or 0
		local num = rtime - getcount
		if not num or num < 0 then num = 0 end
		objSwf["txt_getNum" ..i].text = num
		objSwf['txt_recharge' ..i].text = vo.eachTxt or ""
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

function UIOperactivitesVipGet:Ontimer()
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
		UIMainOperActivites:Hide()
	end

	local day,hour,mint,sec = CTimeFormat:sec2formatEx(GetLocalTime())
	FPrint('当前的小时和分'..hour..':'..mint..':'..sec)
	if hour == 0 and mint == 0 and sec >= 2 and sec <= 3 then
		if self.timerKey then 
			TimerManager:UnRegisterTimer(self.timerKey);
			self.timerKey = nil;
		end;
		UIMainOperActivites:Hide()
	end
end;

function UIOperactivitesVipGet:OnHide()
	if self.timerKey then 
		TimerManager:UnRegisterTimer(self.timerKey);
		self.timerKey = nil;
	end
end

--领奖点击
function UIOperactivitesVipGet:GetRewardClick(i)
	if GetCurTime() - self.lastTime > OperactivitiesConsts.delayReawrd then
		local group = OperActUIManager.currentGroupId	
		local actList = OperactivitiesModel.groupList[group]
		OperactivitiesController:ReqGetPartyAward(actList[i].id, 1)
		self.lastTime = GetCurTime()
	end
	
end

function UIOperactivitesVipGet:ListNotificationInterests()
	return {
		NotifyConsts.OperActivityInitInfo,
		NotifyConsts.UpdateOperActAwardState,
		NotifyConsts.UpdateGroupInfo,
		NotifyConsts.PlayerAttrChange,
		NotifyConsts.OperActivityInitState,
	}
end

function UIOperactivitesVipGet:HandleNotification( name, body )
	if not self:IsShow() then
		return
	end 

	if name == NotifyConsts.OperActivityInitInfo then
		-- self:UpdateUI()
	elseif name == NotifyConsts.OperActivityInitState then
		self:UpdateUI()
	elseif name == NotifyConsts.UpdateOperActAwardState then
		self:UpdateUI()
	elseif name == NotifyConsts.UpdateGroupInfo then
		local group = OperActUIManager.currentGroupId	
		if group == body.groupId then
			self:UpdateUI()		
			Notifier:sendNotification(NotifyConsts.UpdateGroupItemList); 
		end
	elseif name == NotifyConsts.PlayerAttrChange then 
		if body.type == enAttrType.eaUnBindGold or body.type == enAttrType.eaBindGold
			or body.type == enAttrType.eaBindMoney 
			or body.type == enAttrType.eaZhenQi 
			or body.type == enAttrType.eaUnBindMoney then 
			self:UpdateUI()			
			Notifier:sendNotification(NotifyConsts.UpdateGroupItemList); 
		end;
	end	
end

function UIOperactivitesVipGet:CheckItemId(itemId)
	if not self.itemList then return false end
	for k, v in pairs (self.itemList) do
		if v == itemId then
			return true
		end
	end
	
	return false
end