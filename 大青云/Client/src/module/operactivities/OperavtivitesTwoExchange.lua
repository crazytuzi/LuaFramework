--[[
	商业活动  (特殊)
	2015年10月12日, PM 04:59:58
]]

_G.UIOperavtivitesTwoExchange = BaseUI:new('UIOperavtivitesTwoExchange');
UIOperavtivitesTwoExchange.remainTime = 0
UIOperavtivitesTwoExchange.timerKey = nil;
UIOperavtivitesTwoExchange.itemList = {}
UIOperavtivitesTwoExchange.lastTime = 0
UIOperavtivitesTwoExchange.nPage = 1
function UIOperavtivitesTwoExchange:Create()
	self:AddSWF('operactivitesTwoEchange.swf',true,nil);
end

function UIOperavtivitesTwoExchange:OnLoaded(objSwf)
	objSwf.getBtn1.click = function()
		self:GetRewardClick()
	end
	for i = 1, 2 do
		objSwf['pageBtn' ..i].click = function()
			self:OnPageClick(i)
		end
	end
	RewardManager:RegisterListTips(objSwf.rewardList)
end

function UIOperavtivitesTwoExchange:OnBtnChargeClick()
	Version:Charge()
end

function UIOperavtivitesTwoExchange:OnPageClick(i)
	if self.nPage == i then
		return
	end
	self.nPage = i
	self:UpdateUI()
end

function UIOperavtivitesTwoExchange:OnShow()
	local group = OperActUIManager.currentGroupId	
	
	OperactivitiesController:RespPartyInfo(group)
	self.objSwf['pageBtn' .. self.nPage].selected = true
end

function UIOperavtivitesTwoExchange:UpdateUI()
	local objSwf = self.objSwf
	if not objSwf then return end
	
	local group = OperActUIManager.currentGroupId	
	objSwf.rewardList.dataProvider:cleanUp();
	local actList = OperactivitiesModel.groupList[group]
	for i = 1, 2 do
		if actList[i] then
			objSwf['pageBtn' ..i]._visible = true
			if objSwf['pageBtn' ..i].icon.source ~= ResUtil:GetOperActivityIcon(actList[i].imagePic) then
				objSwf['pageBtn' ..i].icon.source = ResUtil:GetOperActivityIcon(actList[i].imagePic)
			end
		else
			objSwf['pageBtn' ..i]._visible = false
		end
	end

	objSwf.rewardList.dataProvider:push( unpack(RewardManager:Parse(actList[self.nPage].conditionTxt)));
	objSwf.rewardList:invalidateData();
	objSwf.txtRemindTime.text = ""
	local state = actList[self.nPage]:GetIsArawdState() or 0
	if state == 2 then
		objSwf.getBtn1._visible = false
		objSwf.effect._visible = false
	else
		objSwf.effect._visible = true
		objSwf.getBtn1._visible = true
	end
	if state == 2 then
		objSwf.mcYilingqu._visible = true
		objSwf.mcYilingqu:gotoAndStop(18)
	else
		objSwf.mcYilingqu._visible = false
	end
	local cost = split(actList[self.nPage].consume, ",")
	objSwf.txtCost1.text = cost[2]
	-- objSwf.txt_getNum.text = actList[self.nPage].count .. "/" ..actList[self.nPage].receiveTime
	
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
	local modelProfList = split(actList[self.nPage].showModel, ',')
	self.showModel = modelProfList[1]
	if modelProfList[2] then
		if objSwf.icon2.source ~= ResUtil:GetOperActivityIcon(modelProfList[2]) then
			objSwf.icon2.source = ResUtil:GetOperActivityIcon(modelProfList[2])
		end
		objSwf.icon2._visible = true
	else
		objSwf.icon2._visible = false
	end
	self:Show3DWeapon()
end

function UIOperavtivitesTwoExchange:Show3DWeapon()
	local objSwf = self.objSwf
	if not objSwf then return end	
	
	if not self.showModel or self.showModel == "" then
		if self.objUIDraw then
			self.objUIDraw:SetDraw(false);
		end
		return
	end
	
	local loader = objSwf.roleLoader
	if not self.objUIDraw then
		self.objUIDraw = UISceneDraw:new( "UIOperavtivitesTwoExchange", loader, _Vector2.new(400, 300), true);
	end	
	self.objUIDraw:SetUILoader( loader )	
	local src = self.showModel
	if not src then return end
	self.objUIDraw:SetScene(src);	
	self.objUIDraw:SetDraw(true);	
end

function UIOperavtivitesTwoExchange:Ontimer()
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
	if hour == 0 and mint == 0 and sec >= 2 and sec <= 3 then
		if self.timerKey then 
			TimerManager:UnRegisterTimer(self.timerKey);
			self.timerKey = nil;
		end;
		UIMainOperActivites:Hide()
	end
end;

function UIOperavtivitesTwoExchange:OnHide()
	if self.timerKey then 
		TimerManager:UnRegisterTimer(self.timerKey);
		self.timerKey = nil;
	end
	self.nPage = 1

	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
	end
end

function UIOperavtivitesTwoExchange:OnDelete()
	if self.objUIDraw then
		self.objUIDraw:SetUILoader(nil);
	end
end

--领奖点击
function UIOperavtivitesTwoExchange:GetRewardClick()
	if GetCurTime() - self.lastTime > OperactivitiesConsts.delayReawrd then
		local group = OperActUIManager.currentGroupId	
		local actList = OperactivitiesModel.groupList[group]
		local state = actList[self.nPage]:GetIsArawdState() or 0
		if state == 1 then
			local goFunc = function ()
				OperactivitiesController:ReqGetPartyAward(actList[self.nPage].id, 1)
			end
			local cost = split(actList[self.nPage].consume, ",")
			local award = RewardManager:ParseToVO(actList[self.nPage].conditionTxt)[1]
			local itemCfg = t_item[award.id]
			if not itemCfg then
				itemCfg = t_equip[award.id]
			end
			UIConfirm:Open("是否花费"..cost[2] .."元宝购买" .. string.format("<font color = '%s'><u>%sx%s</u></font>", TipsConsts:GetItemQualityColor(itemCfg.quality), itemCfg.name, award.count),goFunc);
		else
			local chargefunc = function ()
				Version:Charge()
			end
			UIConfirm:Open(StrConfig['vip6'],chargefunc,nil,StrConfig['vip20']);
		end
		self.lastTime = GetCurTime()
	end
	
end

function UIOperavtivitesTwoExchange:ListNotificationInterests()
	return {
		NotifyConsts.OperActivityInitInfo,
		NotifyConsts.UpdateOperActAwardState,
		NotifyConsts.UpdateGroupInfo,
		NotifyConsts.PlayerAttrChange,
		NotifyConsts.OperActivityInitState,
	}
end

function UIOperavtivitesTwoExchange:HandleNotification( name, body )
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

function UIOperavtivitesTwoExchange:CheckItemId(itemId)
	if not self.itemList then return false end
	for k, v in pairs (self.itemList) do
		if v == itemId then
			return true
		end
	end
	
	return false
end