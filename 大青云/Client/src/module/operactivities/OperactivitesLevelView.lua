_G.UIOperactivitesLevel = BaseUI:new('UIOperactivitesLevel');
UIOperactivitesLevel.remainTime = 0
UIOperactivitesLevel.timerKey = nil;
UIOperactivitesLevel.itemList = {}
UIOperactivitesLevel.lastTime = 0
function UIOperactivitesLevel:Create()
	self:AddSWF('operactivitesLevelPanel.swf',true,"center");
end

function UIOperactivitesLevel:OnLoaded(objSwf)
	objSwf.btnGet.click = function() self:GetRewardClick() end
	objSwf.btnClose.click = function() self:Hide() end

	RewardManager:RegisterListTips(objSwf.rewardList)
	RewardManager:RegisterListTips(objSwf.rewardList1)
end

function UIOperactivitesLevel:OnBtnChargeClick()
	Version:Charge()
end

function UIOperactivitesLevel:OnShow()
	local objSwf = self.objSwf
	if not objSwf then return end
	
	self.currentIconId = OperactivitiesConsts.iconLevel
	OperactivitiesController:ReqPartyList(self.currentIconId)

	if not OperactivitiesModel.isClickIconList[OperactivitiesConsts.iconLevel] then
		OperactivitiesModel.isClickIconList[OperactivitiesConsts.iconLevel] = true
		Notifier:sendNotification(NotifyConsts.UpdateOperActBtnIconState);
	end
end

function UIOperactivitesLevel:UpdateUI()
	local objSwf = self.objSwf
	if not objSwf then return end
	
	local actVo, group = OperactivitiesModel:GetGroupVo(self.currentIconId)
	objSwf.rewardList.dataProvider:cleanUp();
	if not actVo.reward then
		OperactivitiesController:RespPartyInfo(group)
		return
	end
	objSwf.rewardList.dataProvider:push( unpack(RewardManager:Parse(actVo.reward )));
	objSwf.rewardList:invalidateData();
	objSwf.rewardList1.dataProvider:cleanUp();
	objSwf.rewardList1.dataProvider:push( unpack(RewardManager:Parse("160000003#160000003#160000003#160000003#160000003#160000003#160000003")));
	objSwf.rewardList1:invalidateData();
	objSwf.txtRemindTime.text = ""
	local state1 = actVo:GetIsArawdState() or 0
	if state1 == 2 then
		objSwf.effect._visible = false
		objSwf.btnGet._visible = false
	else
		objSwf.effect._visible = true
		objSwf.btnGet._visible = true
	end
	if state1 == 2 then
		objSwf.mcYilingqu1._visible = true
		objSwf.mcYilingqu1:gotoAndStop(18)
	else
		objSwf.mcYilingqu1._visible = false
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

function UIOperactivitesLevel:Ontimer()
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
		UIOperactivitesLevel:Hide()
	end
end;

function UIOperactivitesLevel:OnHide()
	if self.timerKey then 
		TimerManager:UnRegisterTimer(self.timerKey);
		self.timerKey = nil;
	end
end

--领奖点击
function UIOperactivitesLevel:GetRewardClick()
	if GetCurTime() - self.lastTime > OperactivitiesConsts.delayReawrd then
		local actVo = OperactivitiesModel:GetGroupVo(self.currentIconId)
		if not actVo then
			return
		end
		local state = actVo:GetIsArawdState() or 0
		if state == 1 then
			local goFunc = function ()
				OperactivitiesController:ReqGetPartyAward(actVo.id, 1)
				if self:IsShow() then
					local startPos = UIManager:PosLtoG(self.objSwf.item1,70,17);
					RewardManager:FlyIcon(RewardManager:ParseToVO(actVo.reward),startPos,5,true,60)
				end
			end
			local cost = split(actVo.consume, ",")
			local award = RewardManager:ParseToVO(actVo.reward)[1]
			local itemCfg = t_item[award.id]
			if not itemCfg then
				itemCfg = t_equip[award.id]
			end
			UIConfirm:Open("是否花费"..cost[2] .."元宝购买" .. string.format("<font color = '%s'><u>%sx%s</u></font>", TipsConsts:GetItemQualityColor(itemCfg.quality), itemCfg.name, award.count),goFunc,nil,nil,nil,nil,nil,nil,actVo.reward);
		else
			local chargefunc = function ()
				Version:Charge()
			end
			UIConfirm:Open(StrConfig['vip6'],chargefunc,nil,StrConfig['vip20']);
		end
		self.lastTime = GetCurTime()
	end
	
end

function UIOperactivitesLevel:ListNotificationInterests()
	return {
		NotifyConsts.OperActivityInitInfo,
		NotifyConsts.UpdateOperActAwardState,
		NotifyConsts.UpdateGroupInfo,
		NotifyConsts.PlayerAttrChange,
		NotifyConsts.OperActivityInitState,
	}
end

function UIOperactivitesLevel:HandleNotification( name, body )
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
		Notifier:sendNotification(NotifyConsts.UpdateGroupItemList)
	elseif name == NotifyConsts.PlayerAttrChange then 
		if body.type == enAttrType.eaUnBindMoney then 
			self:UpdateUI()			
			Notifier:sendNotification(NotifyConsts.UpdateGroupItemList); 
		end;
	end	
end

function UIOperactivitesLevel:IsTween()
	return true
end

function UIOperactivitesLevel:GetPanelType()
	return 1
end

function UIOperactivitesLevel:IsShowSound()
	return true
end