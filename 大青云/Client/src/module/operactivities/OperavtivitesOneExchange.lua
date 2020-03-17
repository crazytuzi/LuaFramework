--[[
	商业活动  (一堆等级显示的玩意)
	2015年10月12日, PM 04:59:58
]]

_G.UIOperavtivitesOneExchange = BaseUI:new('UIOperavtivitesOneExchange');
UIOperavtivitesOneExchange.remainTime = 0
UIOperavtivitesOneExchange.timerKey = nil;
UIOperavtivitesOneExchange.itemList = {}
UIOperavtivitesOneExchange.lastTime = 0
function UIOperavtivitesOneExchange:Create()
	self:AddSWF('operactivitesExchangeList.swf',true,nil);
end

function UIOperavtivitesOneExchange:OnLoaded(objSwf)
	objSwf.getBtn1.click = function() self:GetRewardClick() end
	objSwf.btnCharge.click = function() self:OnBtnChargeClick(); end

	RewardManager:RegisterListTips(objSwf.rewardList)
end

function UIOperavtivitesOneExchange:OnBtnChargeClick()
	Version:Charge()
end

function UIOperavtivitesOneExchange:OnShow()
	local group = OperActUIManager.currentGroupId	
	
	OperactivitiesController:RespPartyInfo(group)
end

function UIOperavtivitesOneExchange:UpdateUI()
	local objSwf = self.objSwf
	if not objSwf then return end
	
	local group = OperActUIManager.currentGroupId	
	objSwf.rewardList.dataProvider:cleanUp();
	local actList = OperactivitiesModel.groupList[group]
	objSwf.rewardList.dataProvider:push( unpack(RewardManager:Parse( actList[1].reward )));
	objSwf.rewardList:invalidateData();
	objSwf.txtRemindTime.text = ""
	local state1 = actList[1]:GetIsArawdState() or 0
	if state1 == 2 then
		objSwf.getBtn1._visible = false
	else
		objSwf.getBtn1._visible = true
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

	local iconList = split(actList[1].showModel, ',')
	if iconList[1] then
		imgUrl = ResUtil:GetOperActivityIcon(iconList[1])
		if imgUrl ~= objSwf.imgshow1.source then
			objSwf.imgshow1.source = imgUrl
		end
	end
	objSwf.showList.dataProvider:cleanUp()
	local list = {}
	if iconList[2] then
		for i = 1, toint(iconList[3]) do
			imgUrl = ResUtil:GetOperActivityIcon(iconList[2] .. i..".png")
			local vo = {}
			vo.icon = imgUrl
			if imgUrl then
				table.insert(list, UIData.encode(vo))
			end
		end
	end
	if iconList[4] then
		local swf = ResUtil:GetUIUrl(iconList[4])
		if objSwf.imgshow2.source ~= swf then
			objSwf.imgshow2.source = swf
		end
	end
	objSwf.showList.dataProvider:push(unpack(list))
	objSwf.showList:invalidateData()
	
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

function UIOperavtivitesOneExchange:Ontimer()
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

function UIOperavtivitesOneExchange:OnHide()
	if self.timerKey then 
		TimerManager:UnRegisterTimer(self.timerKey);
		self.timerKey = nil;
	end
end

--领奖点击
function UIOperavtivitesOneExchange:GetRewardClick()
	if GetCurTime() - self.lastTime > OperactivitiesConsts.delayReawrd then
		local group = OperActUIManager.currentGroupId	
		local actList = OperactivitiesModel.groupList[group]
		local state = actList[1]:GetIsArawdState() or 0
		if state == 1 then
			local goFunc = function ()
				OperactivitiesController:ReqGetPartyAward(actList[1].id, 1)
			end
			local cost = split(actList[1].consume, ",")
			UIConfirm:Open("是否花费"..cost[2] .."元宝购买此物品",goFunc);
		else
			local chargefunc = function ()
				Version:Charge()
			end
			UIConfirm:Open(StrConfig['vip6'],chargefunc,nil,StrConfig['vip20']);
		end
		self.lastTime = GetCurTime()
	end
	
end

function UIOperavtivitesOneExchange:ListNotificationInterests()
	return {
		NotifyConsts.OperActivityInitInfo,
		NotifyConsts.UpdateOperActAwardState,
		NotifyConsts.UpdateGroupInfo,
		NotifyConsts.PlayerAttrChange,
		NotifyConsts.OperActivityInitState,
	}
end

function UIOperavtivitesOneExchange:HandleNotification( name, body )
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

function UIOperavtivitesOneExchange:CheckItemId(itemId)
	if not self.itemList then return false end
	for k, v in pairs (self.itemList) do
		if v == itemId then
			return true
		end
	end
	
	return false
end