--[[
	商业活动  (特殊)
	2015年10月12日, PM 04:59:58
]]

_G.UIOperactivitesSpecialExchange = BaseUI:new('UIOperactivitesSpecialExchange');
UIOperactivitesSpecialExchange.remainTime = 0
UIOperactivitesSpecialExchange.timerKey = nil;
UIOperactivitesSpecialExchange.itemList = {}
UIOperactivitesSpecialExchange.lastTime = 0
UIOperactivitesSpecialExchange.nPage = 1
function UIOperactivitesSpecialExchange:Create()
	self:AddSWF('operactivitesSpecialEchange.swf',true,nil);
end

function UIOperactivitesSpecialExchange:OnLoaded(objSwf)
	objSwf.getBtn1.click = function()
		self:GetRewardClick()
	end
	for i = 1, 4 do
		objSwf['pageBtn' ..i].click = function()
			self:OnPageClick(i)
		end
	end
	-- objSwf.btnCharge.click = function() self:OnBtnChargeClick(); end

	RewardManager:RegisterListTips(objSwf.rewardList)
end

function UIOperactivitesSpecialExchange:OnBtnChargeClick()
	Version:Charge()
end

function UIOperactivitesSpecialExchange:OnPageClick(i)
	if self.nPage == i then
		return
	end
	self.nPage = i
	self:UpdateUI()
end

function UIOperactivitesSpecialExchange:OnShow()
	local group = OperActUIManager.currentGroupId	
	self.nPage = 1
	OperactivitiesController:RespPartyInfo(group)
	self.objSwf['pageBtn' .. self.nPage].selected = true
end

function UIOperactivitesSpecialExchange:UpdateUI()
	local objSwf = self.objSwf
	if not objSwf then return end
	
	local group = OperActUIManager.currentGroupId	
	objSwf.rewardList.dataProvider:cleanUp();
	local actList = OperactivitiesModel.groupList[group]
	self.actList = {}
	for k, v in ipairs(actList) do
		if OperactivitiesModel:GetAcRemainTime(v) > 0 then
			table.insert(self.actList, v)
		end
	end
	for i = 1, 4 do
		if self.actList[i] then
			objSwf['pageBtn' ..i]._visible = true
			if objSwf['pageBtn' ..i].icon.source ~= ResUtil:GetOperActivityIcon(self.actList[i].imagePic) then
				objSwf['pageBtn' ..i].icon.source = ResUtil:GetOperActivityIcon(self.actList[i].imagePic)
			end
		else
			objSwf['pageBtn' ..i]._visible = false
		end
	end
	if not self.actList[self.nPage] then
		self.nPage = self.nPage - 1
		self:UpdateUI()
	end
	objSwf.rewardList.dataProvider:push( unpack(RewardManager:Parse( self.actList[self.nPage].reward )));
	objSwf.rewardList:invalidateData();
	objSwf.txtRemindTime.text = ""
	local state = self.actList[self.nPage]:GetIsArawdState() or 0
	if state == 2 then
		objSwf.effect._visible = false
		objSwf.getBtn1._visible = false
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
	local cost = split(self.actList[self.nPage].consume, ",")
	objSwf.txtCost1.text = "消耗 " .. cost[2] .. " 元宝可购买"
	objSwf.txt_getNum.text = self.actList[self.nPage].count .. "/" ..self.actList[self.nPage].receiveTime
	
	self.remainTime = OperactivitiesModel:GetAcRemainTime(self.actList[self.nPage])
	if self.remainTime and self.remainTime > 0 then
		if self.timerKey then 
			TimerManager:UnRegisterTimer(self.timerKey);
			self.timerKey = nil;
		end;
		self.timerKey = TimerManager:RegisterTimer(function() self:Ontimer() end,1000,0);
		self:Ontimer();
	end
	
	-- self.itemList = OperactivitiesModel:GetExchangeItemList(group)
	local modelProfList = split(self.actList[self.nPage].showModel, ',')
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

function UIOperactivitesSpecialExchange:Show3DWeapon()
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
		self.objUIDraw = UISceneDraw:new( "UIOperactivitesSpecialExchange", loader, _Vector2.new(400, 300), true);
	end	
	self.objUIDraw:SetUILoader( loader )	
	local src = self.showModel
	if not src then return end
	self.objUIDraw:SetScene(src);	
	self.objUIDraw:SetDraw(true);	
end

function UIOperactivitesSpecialExchange:Ontimer()
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

function UIOperactivitesSpecialExchange:OnHide()
	if self.timerKey then 
		TimerManager:UnRegisterTimer(self.timerKey);
		self.timerKey = nil;
	end
	self.nPage = 1
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
	end
end

function UIOperactivitesSpecialExchange:OnDelete()
	if self.objUIDraw then
		self.objUIDraw:SetUILoader(nil);
	end
end

--领奖点击
function UIOperactivitesSpecialExchange:GetRewardClick()
	if GetCurTime() - self.lastTime > OperactivitiesConsts.delayReawrd then
		local group = OperActUIManager.currentGroupId	
		local state = self.actList[self.nPage]:GetIsArawdState() or 0
		if state == 1 then
			local goFunc = function ()
				OperactivitiesController:ReqGetPartyAward(self.actList[self.nPage].id, 1)
			end
			local cost = split(self.actList[self.nPage].consume, ",")
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

function UIOperactivitesSpecialExchange:ListNotificationInterests()
	return {
		NotifyConsts.OperActivityInitInfo,
		NotifyConsts.UpdateOperActAwardState,
		NotifyConsts.UpdateGroupInfo,
		NotifyConsts.PlayerAttrChange,
		NotifyConsts.OperActivityInitState,
	}
end

function UIOperactivitesSpecialExchange:HandleNotification( name, body )
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

function UIOperactivitesSpecialExchange:CheckItemId(itemId)
	if not self.itemList then return false end
	for k, v in pairs (self.itemList) do
		if v == itemId then
			return true
		end
	end
	
	return false
end