--[[
	首冲
]]

_G.UIOperactivitesFirstRecharge = BaseUI:new('UIOperactivitesFirstRecharge');
UIOperactivitesFirstRecharge.actVO = {}
UIOperactivitesFirstRecharge.actId = nil
UIOperactivitesFirstRecharge.isShowEffect = 0
UIOperactivitesFirstRecharge.soundDic = {13045,13046}
UIOperactivitesFirstRecharge.lastSoundTime = 0
UIOperactivitesFirstRecharge.soundGapTime = 6500
UIOperactivitesFirstRecharge.lastTime = 0
function UIOperactivitesFirstRecharge:Create()
	self:AddSWF('operactivitesFirstRechage.swf',true,'center');
end

function UIOperactivitesFirstRecharge:OnLoaded(objSwf)
	objSwf.btnClose.click = function() self:OnBtnCloseClick(); end;
	RewardManager:RegisterListTips( objSwf.rewardList )
	
	objSwf.btnGet.click = function()
		if self.actVO and self.actVO.isAward == 1 then--0 - 没有， 1 - 可领， 2 - 已领
			self:GetRewardClick()
		elseif self.actVO and self.actVO.isAward == 0 then
			self:OnBtnChargeClick()
		end
	 end
	 
	 objSwf.mcYilingqu:gotoAndStop(objSwf.mcYilingqu._totalframes);
	-- objSwf.btnGotoCharge.click = function() self:OnBtnChargeClick() end
end

function UIOperactivitesFirstRecharge:OnBtnChargeClick()
	local faild = function(url)
		if url then
			_sys:browse(url);
		else
			Version:Charge();
		end
	end
	if not UIFirstRechargeWindow:Open(1,faild) then
		print('first recharge faild!');
	end
end

--领奖点击
function UIOperactivitesFirstRecharge:GetRewardClick()
	local objSwf = self.objSwf
	if not objSwf then return end
	if self.actVO and self.actVO.id and self.actVO.id > 0 then
		if GetCurTime() - self.lastTime > OperactivitiesConsts.delayReawrd then
			FPrint('领奖点击'..self.actVO.id)		
			OperactivitiesController:ReqGetPartyAward(self.actVO.id, 1)	
			self.lastTime = GetCurTime()
		end
	end	
end

function UIOperactivitesFirstRecharge:IsTween()
	return true
end

function UIOperactivitesFirstRecharge:GetPanelType()
	return 1
end

function UIOperactivitesFirstRecharge:IsShowSound()
	return true
end

function UIOperactivitesFirstRecharge:OnShow()
	local objSwf = self.objSwf
	if not objSwf then return end
	if self.args and self.args[1] then
		self.currentIconId = self.args[1]	
	end
	self.currentIconId = OperactivitiesConsts.iconShouchong
	
	self.isShowEffect = 1
	OperactivitiesController:ReqPartyList(self.currentIconId)
	objSwf.effectAward:playEffect(0)
	
	if not OperactivitiesModel.isClickIconList[OperactivitiesConsts.iconShouchong] then
		OperactivitiesModel.isClickIconList[OperactivitiesConsts.iconShouchong] = true
		Notifier:sendNotification(NotifyConsts.UpdateOperActBtnIconState);
	end
	
	local curSoundTime = GetCurTime()
	if self.lastSoundTime <= 0 then
		self:PlayOpenSound()
		self.lastSoundTime = GetCurTime()
	else
		if curSoundTime > self.lastSoundTime + self.soundGapTime then
			self:PlayOpenSound()
			self.lastSoundTime = GetCurTime()
		end
	end
end

function UIOperactivitesFirstRecharge:PlayOpenSound()
	local soundId = self.soundDic[math.random(2)]
	
	SoundManager:PlaySfx(soundId)
end

function UIOperactivitesFirstRecharge:GetWidth()
	return 1616
end

function UIOperactivitesFirstRecharge:GetHeight()
	return 702
end

function UIOperactivitesFirstRecharge:InitList()
	local objSwf = self.objSwf
	if not objSwf then return end
	
	local actVO = OperactivitiesModel:GetFirstChargeActVO(self.currentIconId)
	if actVO then
		UIOperactivitesFirstRecharge.actId = actVO.id
		FTrace(actVO, '首冲')
		self.actVO = actVO
		objSwf.rewardList.dataProvider:cleanUp()
		if not actVO.reward then actVO.reward = '' end
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

function UIOperactivitesFirstRecharge:OnBtnCloseClick()
	self:Hide();
end

function UIOperactivitesFirstRecharge:ListNotificationInterests()
	return {
		NotifyConsts.OperActivityInitInfo,
		NotifyConsts.UpdateOperActAwardState,
		NotifyConsts.UpdateGroupInfo,
		NotifyConsts.OperActivityInitState,
	}
end

function UIOperactivitesFirstRecharge:HandleNotification( name, body )
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
		OperactivitiesModel:GoRewardfun(self.objSwf.btnGet, actVO.reward)
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

function UIOperactivitesFirstRecharge:OnHide()
	local objSwf = self.objSwf
	if not objSwf then return end

	local name = 'UIOperactivitesFirst1'
	local objUIDraw1 = UIDrawManager:GetUIDraw(name);
	if self.objUIDraw1 then
		self.objUIDraw1:SetDraw(false);
	end
	
	name = 'UIOperactivitesFirst2'
	local objUIDraw2 = UIDrawManager:GetUIDraw(name);
	if self.objUIDraw2 then
		self.objUIDraw2:SetDraw(false);
	end
	
	if self.timerKey then TimerManager:UnRegisterTimer(self.timerKey) end
	
	local objSwf = self.objSwf
	if not objSwf then return end
	objSwf.effectAward:stopEffect()
end

function UIOperactivitesFirstRecharge:OnDelete()
	local objSwf = self.objSwf
	if not objSwf then return end

	local name = 'UIOperactivitesFirst1'
	local objUIDraw1 = UIDrawManager:GetUIDraw(name);
	if objUIDraw1 then
		objUIDraw1:SetUILoader(nil);
	end
	
	name = 'UIOperactivitesFirst2'
	local objUIDraw2 = UIDrawManager:GetUIDraw(name);
	if objUIDraw2 then
		objUIDraw2:SetUILoader(nil);
	end
end

function UIOperactivitesFirstRecharge:Show3DWeapon()
	local objSwf = self.objSwf
	if not objSwf then return end	
	
	local loader = objSwf.roleLoader1
	local name      = 'UIOperactivitesFirst1'
	if not self.objUIDraw1 then
		self.objUIDraw1 = UISceneDraw:new( name, loader, _Vector2.new(1800, 1200), true);
	end	
	self.objUIDraw1:SetUILoader( loader )	
	local src = 'v_sc_shenbing.sen'
	if not src then return end
	self.objUIDraw1:SetScene(src);	
	self.objUIDraw1:SetDraw(true);
	
	
	loader = objSwf.roleLoader2
	name      = 'UIOperactivitesFirstRecharge2'
	if not self.objUIDraw2 then
		self.objUIDraw2 = UISceneDraw:new( name, loader, _Vector2.new(1800, 1200), true);
	end	
	self.objUIDraw2:SetUILoader( loader )	
	local src = 'v_sc_jiangziya.sen'
	if not src then return end
	self.objUIDraw2:SetScene(src);
	self.objUIDraw2:SetDraw(true);	
end

function UIOperactivitesFirstRecharge:WithRes()
	return {"slotQuality6_64.swf", "slotQuality3_64.swf", "slotQuality5_64.swf"}
end