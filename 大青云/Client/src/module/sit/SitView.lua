--[[
打坐面板
郝户
2014年11月11日16:29:14
]]

_G.UISit = BaseUI:new("UISit");


-- 子面板名字
UISit.DETAIL = "detail"
UISit.NEARBY = "nearby"
UISit.trailMC = nil;
function UISit:Create()
	self:AddSWF( "sitPanel.swf", true, "bottomFloat" );

	self:AddChild( UISitDetail, UISit.DETAIL );
	self:AddChild( UISitNearby, UISit.NEARBY );
end

function UISit:OnLoaded(objSwf)
	self:GetChild( UISit.DETAIL ):SetContainer( objSwf.childPanelDetail );
	self:GetChild( UISit.NEARBY ):SetContainer( objSwf.childPanelNearby );

	objSwf.txtTime.autoSize   = "left"
	objSwf.txtExp.autoSize    = "left"
	-- objSwf.txtZhenqi.autoSize = "left"
	objSwf.lblTime.text   = UIStrConfig['sit001']
	objSwf.lblExp.text    = UIStrConfig['sit003']
	-- objSwf.lblZhenqi.text = UIStrConfig['sit004']
	objSwf.btnDetail.click = function() self:OnBtnDetailClick() end

	self.trailMC = objSwf.trailEffect;
	self.trailMC._visible = false;
end

--面板加载的附带资源
function UISit:WithRes()
	return { "sitDetailPanel.swf", "sitNearbyPanel.swf" };
end

function UISit:OnShow()
	self:StartTimer();
	self:InitShow();
	UnionController:ReqAidInfo() -- 请求帮派加持信息
end

function UISit:OnHide()
	self:StopTimer();
	self:PlayEffect(false)
	self:ResetIndicator()
	if self.trailMC then
		self.trailMC._visible = false;
	end
end

function UISit:GetWidth()
	return 389
end

function UISit:GetHeight()
	return 150
end

function UISit:InitShow()
	self:ShowGain()
	self:ShowBonus()
	self:PlayEffect(true)
	self:TryShowNearbySit()
	self:UpdateLayout()
end

function UISit:ShowGain()
	local objSwf = self.objSwf
	if not objSwf then return end
	objSwf.txtExp.text = SitModel:GetGainExp()
	-- objSwf.txtZhenqi.text = SitModel:GetGainzhenqi()
end

function UISit:TryShowNearbySit()
	if SitModel:HasNearbySit() then
		self:ShowChild( UISit.NEARBY )
	end
end

function UISit:UpdateLayout()
	local objSwf = UISit.objSwf
	if not objSwf then return end
	local isShowDetail = UISitDetail:IsShow()
	local isShowNearby = UISitNearby:IsShow()
	if isShowDetail and isShowNearby then
		objSwf.childPanelNearby._y = -266
	elseif isShowNearby then
		objSwf.childPanelNearby._y = -182
	end
end

function UISit:PlayEffect(play)
	local objSwf = UISit.objSwf
	if not objSwf then return end
	if play then
		objSwf.effect.completeOnce = function() self:PlayTrailEffect();  end
		objSwf.effect:playEffect(0)
	else
		objSwf.effect:stopEffect()
		objSwf.effect.completeOnce = nil;
	end
end

function UISit:ShowBonus()
	local objSwf = UISit.objSwf
	if not objSwf then return end
	local bonus = SitUtils:GetBonus()
	-- objSwf.numLoader:drawStr( 100 + bonus..'p' ) -- 'p'为'%'
end

function UISit:OnBtnDetailClick()
	if UISitDetail:IsShow() then
		UISitDetail:Hide()
	else
		UISitDetail:Show()
	end
end


---------------------------计时处理---------------------------------
local time
local timerKey
function UISit:StartTimer()
	time = 0
	local cb = function() self:OnTimer() end
	timerKey = TimerManager:RegisterTimer( cb, 1000, 0 );
	self:UpdateTimeShow(true)
end

function UISit:OnTimer()
	time = time + 1;
	self:UpdateTimeShow()
end

function UISit:UpdateTimeShow(isInit)
	local objSwf = self.objSwf
	if not objSwf then return end
	objSwf.txtTime.text = SitUtils:ParseTime(time)
	if isInit then return end
	-- objSwf.timeIndicator.maximum = 10
	-- objSwf.timeIndicator.value = math.min( objSwf.timeIndicator.value + 1, 10 )
end

function UISit:ResetIndicator()
	local objSwf = self.objSwf
	if not objSwf then return end
	-- objSwf.timeIndicator.maximum = 10
	objSwf.timeIndicator.value = 0
end

function UISit:StopTimer()
	if timerKey then
		TimerManager:UnRegisterTimer( timerKey );
		timerKey = nil;
		time = 0;
	end
end
---------------------------拖尾特效处理---------------------------------
function UISit:PlayTrailEffect()
	if not self.trailMC then return; end
	local startX = 184;
	local startY = 56;

	local posg = UIMainSkill:GetExpPosG()
	if not posg then return end
	local posl = UIManager:PosGtoL( self.objSwf, posg.x, posg.y )
	self.trailMC._visible = true;
	self.trailMC._x = startX;
	self.trailMC._y = startY;
	self.trailMC:playEffect(1);
	self.trailMC._rotation = GetAngleTwoPoint(_Vector2.new(startX,startY), posl) - 90;
	Tween:To(self.trailMC, 1.2, { _y = posl.y, _x = posl.x, ease = Cubic.easeOut }, { onComplete = function()
		if not UISit:IsShow() then return; end
		if self.trailMC then
			self.trailMC._visible = false;
		end
		if self.trailMC then
			self.trailMC:stopEffect();
		end
	end} )
end

---------------------------消息处理---------------------------------
--监听消息列表
function UISit:ListNotificationInterests()
	return {
		NotifyConsts.SitFormationChange,
		NotifyConsts.RandomDungeonStep,
		NotifyConsts.SitGainChange,
		NotifyConsts.SitNearby,
		NotifyConsts.SitCancel,
		NotifyConsts.UnionAidInfoUpDate,
		NotifyConsts.UnionAidLevelUpDate,
		NotifyConsts.VipPeriod,
		NotifyConsts.PlayerAttrChange,
	};
end

--处理消息
function UISit:HandleNotification(name, body)
	if name == NotifyConsts.SitGainChange then
		self:ShowGain()
		self:ResetIndicator()
	elseif name == NotifyConsts.SitFormationChange then
		self:ShowBonus()
	elseif name == NotifyConsts.VipPeriod then
		self:ShowBonus()
	elseif name == NotifyConsts.PlayerAttrChange then
		if body.type == enAttrType.eaVIPLevel then
			self:ShowBonus()
		end
	elseif name == NotifyConsts.RandomDungeonStep then
		self:ShowBonus()
	elseif name == NotifyConsts.UnionAidInfoUpDate or name == NotifyConsts.UnionAidLevelUpDate then
		self:ShowBonus()
	elseif name == NotifyConsts.SitNearby then
		self:OnSitNearbyInfo()
	elseif name == NotifyConsts.SitCancel then
		self:Hide();
	end
end

function UISit:OnSitNearbyInfo()
	if not UISitNearby:IsShow() then
		UISitNearby:Show()
	end
end