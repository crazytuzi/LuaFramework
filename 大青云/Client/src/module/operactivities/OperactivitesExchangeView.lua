--[[
	商业活动  (本日充值)
	2015年10月12日, PM 04:59:58
]]

_G.UIOperactivitesExchange = BaseUI:new('UIOperactivitesExchange');
UIOperactivitesExchange.remainTime = 0
UIOperactivitesExchange.timerKey = nil;
UIOperactivitesExchange.itemList = {}
UIOperactivitesExchange.lastTime = 0
function UIOperactivitesExchange:Create()
	self:AddSWF('operactivitesExchange.swf',true,nil);
end

function UIOperactivitesExchange:OnLoaded(objSwf)
	-- 
	objSwf.list.handlerRewardClick = function (e) self:GetRewardClick(e); end
	objSwf.list.itemRewardRollOver = function (e) TipsManager:ShowItemTips(e.item.id); end
	objSwf.list.itemRewardRollOut = function () TipsManager:Hide(); end
end

function UIOperactivitesExchange:OnBtnChargeClick()
	Version:Charge()
end

function UIOperactivitesExchange:OnShow()
	local group = OperActUIManager.currentGroupId	
	
	OperactivitiesController:RespPartyInfo(group)
end

function UIOperactivitesExchange:UpdateUI()
	local objSwf = self.objSwf
	if not objSwf then return end
	
	local group = OperActUIManager.currentGroupId	
	objSwf.list.dataProvider:cleanUp();
	local allData = self:GetListData();
	objSwf.list.dataProvider:push( unpack(allData) );
	objSwf.list:invalidateData();
	
	objSwf.txtGroupTxt.text = OperactivitiesModel:GetGroupTxtByGroupId(group)
	objSwf.txtRemindTime.text = ""
	objSwf.txtTotalGold.text = ""
	
	local imgUrl = OperactivitiesModel:GetGroupImageByGroupId(group)
	if imgUrl and imgUrl ~= "" then
		imgUrl = ResUtil:GetOperActivityIcon(imgUrl)
		if imgUrl ~= objSwf.imgshow.source then
			objSwf.imgshow.source = imgUrl		
		end
	else
		objSwf.imgshow.source = ""
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
	
	self.itemList = OperactivitiesModel:GetExchangeItemList(group)
end

function UIOperactivitesExchange : Ontimer()
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

function UIOperactivitesExchange:OnHide()
	if self.timerKey then 
		TimerManager:UnRegisterTimer(self.timerKey);
		self.timerKey = nil;
	end
end

--所有数据
function UIOperactivitesExchange:GetListData()
	local group = OperActUIManager.currentGroupId	
	local actList = OperactivitiesModel.groupList[group]	
	FPrint('UIOperactivitesExchange:GetListData所有数据'..group)
	FTrace(actList)
	
	local list = {}
	local vo;
	for i , v in ipairs(actList) do		
		vo = {};
		vo.id = v.id	
		vo.eachTxt = v.eachTxt or 'cannotfindid'..v.id
		
		local getcount = v.count or 0
		local rtime = v.receiveTime or 0
		local num = rtime - getcount
		if not num or num < 0 then num = 0 end
		vo.receiveTime = num		
		
		vo.isAward = v:GetIsArawdState() or 0
		if num <= 0 then
			vo.isAward = 0
		end
		if not v.reward then v.reward = '' end
		if not v.consume then v.consume = '' end

		vo.reward = v.reward
		vo.progress = OperactivitiesModel:GetActPrecess(v.id)
		local majorStr = UIData.encode(vo);
		
		local rewardList = RewardManager:Parse( v.reward );
		local rewardStr = table.concat(rewardList, "@");
		-- FPrint(rewardStr)
		
		local consumeList = RewardManager:Parse( v.consume );
		local consumeStr = table.concat(consumeList, "@");
		-- FPrint(consumeStr)
		
		local finalStr = majorStr .. "*" .. rewardStr .. "*" .. consumeStr;
		table.push(list, finalStr);
	end
	return list
end

--领奖点击
function UIOperactivitesExchange:GetRewardClick(e)
	if GetCurTime() - self.lastTime > OperactivitiesConsts.delayReawrd then
		FPrint('领奖点击'.. e.item.id)	
		OperactivitiesController:ReqGetPartyAward(e.item.id, 1)
		self.lastTime = GetCurTime()
	end
	
end

function UIOperactivitesExchange:PlayYilingqu(actId)
	local objSwf = self.objSwf
	if not objSwf then return end

	local group = OperActUIManager.currentGroupId
	local actList = OperactivitiesModel.groupList[group]	
	
	local list = {}
	local vo;
	for i , v in ipairs(actList) do	
		if v.id == actId then	
			if v.reward and v.reward ~= '' then
				local uiSlot = self.objSwf.list:getRendererAt(i - 1)
				if uiSlot then
					OperactivitiesModel:GoRewardfun(uiSlot, v.reward)
				end
			end
		end
	end	
end

function UIOperactivitesExchange:ListNotificationInterests()
	return {
		NotifyConsts.OperActivityInitInfo,
		NotifyConsts.UpdateOperActAwardState,
		NotifyConsts.UpdateGroupInfo,
		NotifyConsts.BagItemNumChange,
		NotifyConsts.PlayerAttrChange,
		NotifyConsts.OperActivityInitState,
	}
end

function UIOperactivitesExchange:HandleNotification( name, body )
	if not self:IsShow() then
		return
	end 

	if name == NotifyConsts.OperActivityInitInfo then
		-- self:UpdateUI()
	elseif name == NotifyConsts.OperActivityInitState then
		self:UpdateUI()
	elseif name == NotifyConsts.UpdateOperActAwardState then
		self:UpdateUI()
		self:PlayYilingqu(body.actId)
	elseif name == NotifyConsts.UpdateGroupInfo then
		local group = OperActUIManager.currentGroupId	
		if group == body.groupId then
			self:UpdateUI()		
			Notifier:sendNotification(NotifyConsts.UpdateGroupItemList); 
		end
	elseif name == NotifyConsts.BagItemNumChange then
		if self:CheckItemId(body.id) then
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

function UIOperactivitesExchange:CheckItemId(itemId)
	if not self.itemList then return false end
	for k, v in pairs (self.itemList) do
		if v == itemId then
			return true
		end
	end
	
	return false
end