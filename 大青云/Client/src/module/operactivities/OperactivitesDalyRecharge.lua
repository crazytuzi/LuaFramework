--[[
	每日首冲
]]

_G.UIOperactivitesDalyRecharge = BaseUI:new('UIOperactivitesDalyRecharge');
UIOperactivitesDalyRecharge.actVO = {}
UIOperactivitesDalyRecharge.actId = 0
UIOperactivitesDalyRecharge.isShowEffect = 0
UIOperactivitesDalyRecharge.lastTime = 0
UIOperactivitesDalyRecharge.timerKey = nil;

function UIOperactivitesDalyRecharge:Create()
	self:AddSWF('operactivitesDalyRechage.swf',true,'center');
end

function UIOperactivitesDalyRecharge:OnLoaded(objSwf)
	objSwf.btnClose.click = function() self:OnBtnCloseClick(); end;
	RewardManager:RegisterListTips( objSwf.rewardList )
	
	objSwf.btnGet.click = function()
		-- FTrace(self.actVO)
		if self.actVO and self.actVO.isAward == 1 then--0 - 没有， 1 - 可领， 2 - 已领
			self:GetRewardClick()
		elseif self.actVO and self.actVO.isAward == 0 then
			self:OnBtnChargeClick()
		end
	 end
	 objSwf.mcYilingqu:gotoAndStop(objSwf.mcYilingqu._totalframes);
	-- objSwf.btnGotoCharge.click = function() self:OnBtnChargeClick() end
end

function UIOperactivitesDalyRecharge:GetWidth()
	return 1020
end

function UIOperactivitesDalyRecharge:GetHeight()
	return 530
end

function UIOperactivitesDalyRecharge:OnBtnChargeClick()
	Version:Charge()
end

function UIOperactivitesDalyRecharge:IsTween()
	return true
end

function UIOperactivitesDalyRecharge:GetPanelType()
	return 1
end

function UIOperactivitesDalyRecharge:IsShowSound()
	return true
end

--领奖点击
function UIOperactivitesDalyRecharge:GetRewardClick()
	local objSwf = self.objSwf
	if not objSwf then return end
	
	FPrint('领奖点击'..self.actId)
	if self.actId and self.actId > 0 then
		if GetCurTime() - self.lastTime > OperactivitiesConsts.delayReawrd then
			FPrint('领奖点击'..self.actId)
			-- local actVO = OperactivitiesModel:GetActVOById(self.actVO.actId)
			OperactivitiesController:ReqGetPartyAward(self.actId, 1)	
			self.lastTime = GetCurTime()
		end
	end	
end

function UIOperactivitesDalyRecharge:OnShow()
	local objSwf = self.objSwf
	if not objSwf then return end

	if self.args and self.args[1] then
		self.currentIconId = self.args[1]	
	end
	self.isShowEffect = 1
	OperactivitiesController:ReqPartyList(self.currentIconId)	
	objSwf.effectAward:playEffect(0)
	
	if not OperactivitiesModel.isClickIconList[OperactivitiesConsts.iconShouchongDay] then
		OperactivitiesModel.isClickIconList[OperactivitiesConsts.iconShouchongDay] = true
		Notifier:sendNotification(NotifyConsts.UpdateOperActBtnIconState);
	end
	
	if self.timerKey then 
		TimerManager:UnRegisterTimer(self.timerKey);
		self.timerKey = nil;
	end;
	
	self.timerKey = TimerManager:RegisterTimer(function() 
			self:Ontimer()
		end,1000,0);
end

function UIOperactivitesDalyRecharge : Ontimer()
	local objSwf = self.objSwf
	if not objSwf then return end			
	local day,hour,mint,sec = CTimeFormat:sec2formatEx(GetLocalTime())
	if hour == 0 and mint == 0 and sec >= 2 and sec <= 3 then
		if self.timerKey then 
			TimerManager:UnRegisterTimer(self.timerKey);
			self.timerKey = nil;
		end;			

		self:Hide()
	end	
end;

function UIOperactivitesDalyRecharge:InitList()
	local objSwf = self.objSwf
	if not objSwf then return end
	
	local actVO = OperactivitiesModel:GetFirstChargeActVO(self.currentIconId)
	if actVO then
		FTrace(actVO, '每日首冲')
		if not actVO.reward then actVO.reward = '' end
		self.actVO = actVO
		self.actId = actVO.id
		objSwf.rewardList.dataProvider:cleanUp()
		local list = RewardManager:ParseToVO(actVO.reward)
		for i = 1, 6 do
			if list[i] then
				local itemCfg = t_item[list[i].id]
				if not itemCfg then
					itemCfg = t_equip[list[i].id]
				end
				objSwf['txtName' ..i].htmlText = string.format("<font color = '%s'>%s</font>", TipsConsts:GetItemQualityColor(itemCfg.quality), itemCfg.name)
			else
				objSwf['txtName' ..i].text = ""
			end
		end
		objSwf.rewardList.dataProvider:push( unpack( RewardManager:Parse( actVO.reward ) ) )
		objSwf.rewardList:invalidateData()
		
		objSwf.mcYilingqu._visible = false
		objSwf.btnGet.visible = true
		if actVO.isAward == 1 then--0 - 没有， 1 - 可领， 2 - 已领
			objSwf.btnGet.visible = true
		elseif actVO.isAward == 2 then
			objSwf.btnGet.visible = false
			if self.isShowEffect == 1 then
				objSwf.mcYilingqu:gotoAndPlay(1)
			else 
				objSwf.mcYilingqu:gotoAndStop(objSwf.mcYilingqu._totalframes);			
			end
			objSwf.mcYilingqu._visible = true	
			objSwf.effectAward:stopEffect()
		end
		
	end
	self:Show3DWeapon()
	self.isShowEffect = 0
end

function UIOperactivitesDalyRecharge:OnBtnCloseClick()
	self:Hide();
end

function UIOperactivitesDalyRecharge:ListNotificationInterests()
	return {
		NotifyConsts.OperActivityInitInfo,
		NotifyConsts.UpdateOperActAwardState,
		NotifyConsts.UpdateGroupInfo,
		NotifyConsts.OperActivityInitState,
	}
end

function UIOperactivitesDalyRecharge:HandleNotification( name, body )
	if not self:IsShow() then
		return
	end
	local objSwf = self.objSwf
	if not objSwf then return end
	
	if name == NotifyConsts.OperActivityInitInfo then
		if body.btn == self.currentIconId then
			OperactivitiesController:ReqPartyStatList(self.currentIconId)
		end
	elseif name == NotifyConsts.UpdateOperActAwardState then
		self.isShowEffect = 1
		self:InitList()
		local actVO = OperactivitiesModel:GetFirstChargeActVO(self.currentIconId)	
		if not actVO then return end
		if not actVO.reward then actVO.reward = '' end
		OperactivitiesModel:GoRewardfun(objSwf.btnGet, actVO.reward)
	elseif name == NotifyConsts.UpdateGroupInfo then	
		local actVO = OperactivitiesModel:GetFirstChargeActVO(self.currentIconId)	
		if actVO and actVO.group == body.groupId then
			self:InitList()
		end
	elseif name == NotifyConsts.OperActivityInitState then	
		local actVO = OperactivitiesModel:GetFirstChargeActVO(self.currentIconId)	
		if actVO then
			OperactivitiesController:RespPartyInfo(actVO.group)
		end
	end
end

function UIOperactivitesDalyRecharge:OnHide()
	-- local name = 'UIOperactivitesDalyRecharge1'
	-- local objUIDraw1 = UIDrawManager:GetUIDraw(name);
	-- if self.objUIDraw1 then
		-- self.objUIDraw1:SetDraw(false);
	-- end
	
	local name = 'UIOperactivitesDalyRecharge2'
	local objUIDraw2 = UIDrawManager:GetUIDraw(name);
	if self.objUIDraw2 then
		self.objUIDraw2:SetDraw(false);
	end
	
	if self.timerKey then 
		TimerManager:UnRegisterTimer(self.timerKey);
		self.timerKey = nil;
	end;
end

function UIOperactivitesDalyRecharge:OnDelete()
	-- local name = 'UIOperactivitesDalyRecharge1'
	-- local objUIDraw1 = UIDrawManager:GetUIDraw(name);
	-- if objUIDraw1 then
		-- objUIDraw1:SetUILoader(nil);
	-- end
	
	local name = 'UIOperactivitesDalyRecharge2'
	local objUIDraw2 = UIDrawManager:GetUIDraw(name);
	if objUIDraw2 then
		objUIDraw2:SetUILoader(nil);
	end
end

function UIOperactivitesDalyRecharge:Show3DWeapon()
	local objSwf = self.objSwf
	if not objSwf then return end	
	
	-- local loader = objSwf.roleLoader1
	-- local name      = 'UIOperactivitesDalyRecharge1'
	-- if not self.objUIDraw1 then
		-- self.objUIDraw1 = UISceneDraw:new( name, loader, _Vector2.new(1800, 1200), true);
	-- end	
	-- self.objUIDraw1:SetUILoader( loader )	
	-- local src = 'vip_zq_binghunma.sen'
	-- if not src then return end
	-- self.objUIDraw1:SetScene(src);	
	-- self.objUIDraw1:SetDraw(true);
	
	local loader = objSwf.roleLoader2
	local name   = 'UIOperactivitesDalyRecharge2'
	if not self.objUIDraw2 then
		self.objUIDraw2 = UISceneDraw:new( name, loader, _Vector2.new(1800, 1200), true);
	end	
	self.objUIDraw2:SetUILoader( loader )	
	local src = 'v_sc_nvmote.sen'
	if not src then return end
	self.objUIDraw2:SetScene(src);	
	self.objUIDraw2:SetDraw(true);
end