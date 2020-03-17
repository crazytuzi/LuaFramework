--[[
	商业活动  (本日充值)--暂时可能要废弃了
	2015年10月12日, PM 04:59:58
]]

_G.UIOperactivitesExchangeSpecial = BaseUI:new('UIOperactivitesExchangeSpecial');
UIOperactivitesExchangeSpecial.remainTime = 0
UIOperactivitesExchangeSpecial.timerKey = nil;
UIOperactivitesExchangeSpecial.itemList = {}
UIOperactivitesExchangeSpecial.lastTime = 0
function UIOperactivitesExchangeSpecial:Create()
	self:AddSWF('operactivitesExchange1.swf',true,nil);
end

function UIOperactivitesExchangeSpecial:OnLoaded(objSwf)
	for i = 1, 2 do
		objSwf['getBtn' ..i].click = function()
			self:GetRewardClick(i)
		end
	end
	objSwf.btnCharge.click = function() self:OnBtnChargeClick(); end

	RewardManager:RegisterListTips(objSwf.rewardList)
	RewardManager:RegisterListTips(objSwf.rewardList1)
end

function UIOperactivitesExchangeSpecial:OnBtnChargeClick()
	Version:Charge()
end

function UIOperactivitesExchangeSpecial:OnShow()
	local group = OperActUIManager.currentGroupId	
	
	OperactivitiesController:RespPartyInfo(group)
end

function UIOperactivitesExchangeSpecial:UpdateUI()
	local objSwf = self.objSwf
	if not objSwf then return end
	
	local group = OperActUIManager.currentGroupId	
	objSwf.rewardList.dataProvider:cleanUp();
	objSwf.rewardList1.dataProvider:cleanUp();	
	local actList = OperactivitiesModel.groupList[group]
	objSwf.rewardList.dataProvider:push( unpack(RewardManager:Parse( actList[1].reward )));
	objSwf.rewardList:invalidateData();
	objSwf.txtRemindTime.text = ""
	local state1 = actList[1]:GetIsArawdState() or 0
	if state1 ~= 1 then
		objSwf.getBtn1.disabled = true
	else
		objSwf.getBtn1.disabled = false
	end
	if state1 == 2 then
		objSwf.mcYilingqu1._visible = true
		objSwf.mcYilingqu1:gotoAndStop(18)
	else
		objSwf.mcYilingqu1._visible = false
	end
	local imgUrl = OperactivitiesModel:GetGroupImageByGroupId(group)
	if imgUrl and imgUrl ~= "" then
		imgUrl = ResUtil:GetOperActivityIcon(imgUrl)
		if imgUrl ~= objSwf.imgshow.source then
			objSwf.imgshow.source = imgUrl		
		end
	else
		objSwf.imgshow.source = ""
	end
	objSwf.imgshow._visible = false
	local cost = split(actList[1].consume, ",")
	objSwf.txtCost1.text = "消耗：" .. cost[2] .. "元宝"
	if not actList[2] then
		objSwf.txtLabel2._visible = false
		objSwf.txtZhuangbi._visible = true
		objSwf.txtZhuangbi.source = ResUtil:GetOperActivityIcon(actList[1].imagePic)
		objSwf.getBtn2._visible = false
		objSwf.itemt1._visible = false
		objSwf.txtCost2._visible = false
		objSwf.mcYilingqu2._visible = false
		objSwf.txtLabel1.text = ""
		objSwf.txtLabel2.text = ""
	else
		objSwf.txtLabel2._visible = true
		objSwf.txtCost2._visible = true
		objSwf.getBtn2._visible = true
		objSwf.itemt1._visible = true
		objSwf.txtZhuangbi._visible = false
		objSwf.txtLabel1.text = "黄金礼包"
		objSwf.txtLabel2.text = "钻石礼包"
		objSwf.rewardList1.dataProvider:push( unpack(RewardManager:Parse( actList[2].reward )));
		objSwf.rewardList1:invalidateData();
		local state2 = actList[2]:GetIsArawdState() or 0
		if state2 ~= 1 then
			objSwf.getBtn2.disabled = true
		else
			objSwf.getBtn2.disabled = false
		end
		if state2 == 2 then
			objSwf.mcYilingqu2._visible = true
			objSwf.mcYilingqu2:gotoAndStop(18)
		else
			objSwf.mcYilingqu2._visible = false
		end
		local cost = split(actList[2].consume, ",")
		objSwf.txtCost2.text = "消耗：" .. cost[2] .. "元宝"
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
	
	-- self.itemList = OperactivitiesModel:GetExchangeItemList(group)
end

function UIOperactivitesExchangeSpecial:Ontimer()
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
	if not self.isSendDaoqi then
		if self.remainTime <= -10 then
			self.isSendDaoqi = true
			if self.timerKey then 
				TimerManager:UnRegisterTimer(self.timerKey);
				self.timerKey = nil;
				
			end;
			UIMainOperActivites:Hide()
		end
	end
	
	if not self.isSendKuatian then
		
		local day,hour,mint,sec = CTimeFormat:sec2formatEx(GetLocalTime())
		FPrint('当前的小时和分'..hour..':'..mint..':'..sec)
		if hour == 0 and mint == 0 and sec == 10 then
			self.isSendKuatian = true
			if self.timerKey then 
				TimerManager:UnRegisterTimer(self.timerKey);
				self.timerKey = nil;
			end;
			UIMainOperActivites:Hide()
		end
	end
end;

function UIOperactivitesExchangeSpecial:OnHide()
	if self.timerKey then 
		TimerManager:UnRegisterTimer(self.timerKey);
		self.timerKey = nil;
	end
end

--领奖点击
function UIOperactivitesExchangeSpecial:GetRewardClick(i)
	if GetCurTime() - self.lastTime > OperactivitiesConsts.delayReawrd then
		local group = OperActUIManager.currentGroupId	
		local actList = OperactivitiesModel.groupList[group]
		OperactivitiesController:ReqGetPartyAward(actList[i].id, 1)
		self.lastTime = GetCurTime()
	end
	
end

function UIOperactivitesExchangeSpecial:ListNotificationInterests()
	return {
		NotifyConsts.OperActivityInitInfo,
		NotifyConsts.UpdateOperActAwardState,
		NotifyConsts.UpdateGroupInfo,
		NotifyConsts.PlayerAttrChange,
		NotifyConsts.OperActivityInitState,
	}
end

function UIOperactivitesExchangeSpecial:HandleNotification( name, body )
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

function UIOperactivitesExchangeSpecial:CheckItemId(itemId)
	if not self.itemList then return false end
	for k, v in pairs (self.itemList) do
		if v == itemId then
			return true
		end
	end
	
	return false
end