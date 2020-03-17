--[[
VIP main panel
2015-7-23 17:20:01
haohu
]]
--------------------------------------------------------------

_G.UIVip = BaseUI:new("UIVip")

UIVip.TAB_RENEW       = "renew"
UIVip.TAB_WELFARE     = "welfare"
UIVip.TAB_PREROGATIVE = "prerogative"
UIVip.TAB_INFO = "VIPINFO"

UIVip.tabButton = {}
UIVip.currentTab = ""

UIVip.redid = 1;

function UIVip:Create()
	self:AddSWF( "vipPanel.swf", true, "center" )
	--
	self:AddChild( UIVipRenew, UIVip.TAB_RENEW )
	self:AddChild( UIVipWelfare, UIVip.TAB_WELFARE )
	self:AddChild( UIVipPrerogative, UIVip.TAB_PREROGATIVE )
	self:AddChild( UIVipInfo, UIVip.TAB_INFO )
end

function UIVip:OnLoaded( objSwf )
	self:GetChild( UIVip.TAB_RENEW ):SetContainer( objSwf.childPanel )
	self:GetChild( UIVip.TAB_WELFARE ):SetContainer( objSwf.childPanel )
	self:GetChild( UIVip.TAB_PREROGATIVE ):SetContainer( objSwf.childPanel )
	self:GetChild( UIVip.TAB_INFO ):SetContainer( objSwf.childPanel )
	--
	objSwf.btnClose.click = function() self:OnBtnCloseClick() end
	objSwf.btnCharge.click = function() self:OnBtnChargeClick() end
	objSwf.btnsendredpacket.click = function() self:OnBtnSendRedPacketClick() end
	objSwf.btnsendredpacket.rollOver = function() self:OnBtnSendRedPacketRollOver() end
	objSwf.btnsendredpacket.rollOut = function() TipsManager:Hide(); end
	--
	self.tabButton[ UIVip.TAB_RENEW ]       = objSwf.btnTabRenew
	self.tabButton[ UIVip.TAB_WELFARE ]     = objSwf.btnTabWelfare
	self.tabButton[ UIVip.TAB_PREROGATIVE ] = objSwf.btnTabPrerogative
	-- objSwf.btnTabWelfare._visible = false
	for btnName, btn in pairs(self.tabButton) do
		btn.click = function() self:OnTabButtonClick( btnName ) end
	end
	
	objSwf.siBlessing.rollOver = function()
		local tipsTxt = StrConfig["vip131"];
		TipsManager:ShowTips( TipsConsts.Type_Normal, tipsTxt, TipsConsts.ShowType_Normal, TipsConsts.Dir_RightDown );
	end
	objSwf.siBlessing.rollOut = function() TipsManager:Hide();  end
	
	
end

function UIVip:OnDelete()
	for k, _ in pairs( self.tabButton ) do
		self.tabButton[k] = nil
	end
end

--面板加载的附带资源
function UIVip:WithRes()
	return { "vipRenewPanel.swf" }
end

function UIVip:IsTween()
	return true
end

function UIVip:GetPanelType()
	return 1
end

function UIVip:IsShowSound()
	return true
end

function UIVip:OnShow()
	self:TurnToSubpanel( UIVip.TAB_RENEW )
	self:ShowVipLevel()
	self:ShowVipExp()
	self:UnRegisterTime();
	self:InitVipRedPoint();
	self:RegisterTime();
end
UIVip.timerKey = nil;
function UIVip:InitVipRedPoint(  )
	local objSwf = self.objSwf
	if not objSwf then return; end
	local canEnter1,num = VipModel:GetWelfareNum()
	if canEnter1 then
		PublicUtil:SetRedPoint(objSwf.btnTabWelfare, RedPointConst.showNum, num)
	else
		PublicUtil:SetRedPoint(objSwf.btnTabWelfare, RedPointConst.showNum, 0)
	end
end

function UIVip:RegisterTime()
	self.timerKey = TimerManager:RegisterTimer(function()
		self:InitVipRedPoint();
	end,1000,0); 
end
function UIVip:UnRegisterTime()
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timerKey)
		self.timerKey = nil;
	end
end
function UIVip:OnHide()
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timerKey)
		self.timerKey = nil;
	end
end

function UIVip:GetWidth()
	return 1239
end

function UIVip:GetHeight()
	return 753
end

function UIVip:OnTabButtonClick( btnName )
	self:TurnToSubpanel( btnName )
end

function UIVip:ShowVipLevel()
	local objSwf = self.objSwf
	if not objSwf then return end
	objSwf.numLoaderFight.num = VipController:GetVipLevel()
end

function UIVip:ShowVipExp()
	local objSwf = self.objSwf
	if not objSwf then return end
	local curexp = VipModel:GetVipExp()
	local levelUpExp = VipController:GetLevelUpExp() or 0
	objSwf.txtExp.text = string.format( "%s/%s", curexp, levelUpExp )
	objSwf.siBlessing.maximum = levelUpExp
	objSwf.siBlessing.value = curexp
	
	local temp = levelUpExp - curexp
	objSwf.txtCondition.text = string.format( StrConfig["vip132"], temp, VipController:GetVipLevel()+1 )
end

function UIVip:TurnToSubpanel(panelName)
	self.currentTab = panelName
	local tabBtn = self.tabButton[panelName]
	if tabBtn then
		tabBtn.selected = true
	end
	local child = self:GetChild(panelName)
	if child and not child:IsShow() then
		self:ShowChild( panelName )
	end
end

function UIVip:OnBtnCloseClick()
	self:Hide()
end

function UIVip:OnBtnChargeClick()
	if not Version:IsShowRechargeButton() then return; end
	Version:Charge()
end

function UIVip:OnBtnSendRedPacketClick()
	local objSwf = self.objSwf
	if not objSwf then return end
	if VipController:GetCanSendRepacket() == false then
		FloatManager:AddNormal( StrConfig["redpacket6"], objSwf.btnsendredpacket);
		return;
	end
	if RedPacketModel:GetCurNum() <= 0 then
		FloatManager:AddNormal( StrConfig["redpacket4"], objSwf.btnsendredpacket);
		return;
	end
	RedPacketController:ReqSendRedPacket();
end

function UIVip:OnBtnSendRedPacketRollOver()
	local tipsTxt = StrConfig["redpacket1"];
	TipsManager:ShowTips( TipsConsts.Type_Normal, tipsTxt, TipsConsts.ShowType_Normal, TipsConsts.Dir_RightDown );
end

function UIVip:ListNotificationInterests()
	return {
		NotifyConsts.PlayerAttrChange,
		NotifyConsts.VipExp,
	}
end

function UIVip:HandleNotification( name, body )
	if not self:IsShow() then
		return
	end

	if name == NotifyConsts.PlayerAttrChange then
		if body.type == enAttrType.eaVIPLevel then
			self:ShowVipLevel()
			self:ShowVipExp()
		end
	elseif name == NotifyConsts.VipExp then
		self:ShowVipLevel()
		self:ShowVipExp()
	end	
end