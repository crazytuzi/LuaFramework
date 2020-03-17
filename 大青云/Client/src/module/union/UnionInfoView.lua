--[[
帮派:首页面板
liyuan
2014年11月20日16:22:09
]]


_G.UIUnionInfo = BaseUI:new("UIUnionInfo")
UIUnionInfo.ResItemsController = nil
function UIUnionInfo:Create()
	self:AddSWF("unionInfoPanel.swf", true, "center");
end

function UIUnionInfo:OnLoaded(objSwf, name)

	objSwf.aidTip._visible = false;
	objSwf.btnInfo.click = function() self:OnEditNotice() end
	
	objSwf.btnLevelUp.click = function() self:OnBtnLevelUpClick() end
	objSwf.btnLevelUp.rollOver = function() self:ShowLevelUpTips() end 
	objSwf.btnLevelUp.rollOut = function() TipsManager:Hide(); end
	
	objSwf.btnContribute.click = function() UIUnionContributionPanel:Show() end
	objSwf.btnJiachi.click = function() UIUnionAidPanel:OpenPanel() end
	objSwf.btnJiachi.rollOver = function() 
		if UIUnionAidPanel.bShowState or UIUnionContributionPanel.bShowState then return; end
		--objSwf.aidTip._visible = true; 
		--self:OnShowAidTip();
		UIUnionAidTips:Show();
	end
	objSwf.btnJiachi.rollOut = function() 
		objSwf.aidTip._visible = false; 
		UIUnionAidTips:Hide();
	end
	
	--帮派祈福
	objSwf.btnPray.click = function() UIUnionPrayView:OpenPanel() end
	objSwf.btnPray.rollOver = function() TipsManager:ShowBtnTips(string.format(StrConfig["unionPray004"],ResUtil:GetTipsLineUrl()),TipsConsts.Dir_RightDown); end
	objSwf.btnPray.rollOut = function() TipsManager:Hide(); end
	
	
	for i=7, 17 do 
		objSwf['labUnionInfo'..i].text = UIStrConfig['union'..i]
	end
	
	-- 资源列表
	self.ResItemsController = UnionResController:New(objSwf, true, true)
	self.ResItemsController.GetItemNeedNum = function(itemId)
												return UnionUtils:GetResLevelUpNeedNum(UnionModel.MyUnionInfo.level, itemId)
											end
											
	objSwf.btnSkill.click = function() 
		UIShopCarryOn:OpenShopByType(ShopConsts.T_Guild)
		-- UIUnionSkill:Show() 
	end	
	-- objSwf.btnSkill.rollOver = function() TipsManager:ShowBtnTips(string.format(StrConfig["union69"],ResUtil:GetTipsLineUrl()),TipsConsts.Dir_RightDown); end
	-- objSwf.btnSkill.rollOut = function() TipsManager:Hide(); end
	
	objSwf.proLoaderValue.loadComplete = function(e) self:OnNumValueLoadComplete(e); end
	objSwf.proLoaderMax.loadComplete   = function(e) self:OnNumMaxLoadComplete(e); end
	objSwf.mcMaxLevel._visible = false
end
function UIUnionInfo:ShowPrayButton()
	local objSwf = self.objSwf
	if not objSwf then return end
	local qingtongNum,baiyinNum,huangjinNum = UnionUtils:CheckContribution()
	if qingtongNum > 0 or baiyinNum > 0 or huangjinNum > 0 then
		objSwf.btnContribute:showEffect(ResUtil:GetButtonEffect10());
	else
		objSwf.btnContribute:clearEffect();
	end
end
function UIUnionInfo:OnNumValueLoadComplete(e)
	local objSwf = self.objSwf
	if not objSwf then return end
	objSwf.proLoaderValue._x = objSwf.posSign._x - objSwf.proLoaderValue.width
end

function UIUnionInfo:OnNumMaxLoadComplete(e)
	local objSwf = self.objSwf
	if not objSwf then return end
	objSwf.proLoaderMax._x = objSwf.posSign._x + objSwf.posSign._width
end

function UIUnionInfo:OnShow(name)
	local objSwf = self:GetSWF("UIUnionInfo")
	if not objSwf then return; end
	

	objSwf.txtRank.text = UnionModel.MyUnionInfo.rank
	objSwf.txtLevel.text = string.format(StrConfig['union31'],UnionModel.MyUnionInfo.level)
	objSwf.txtPower.text = UnionModel.MyUnionInfo.power
	
	objSwf.txtName.text = UnionModel.MyUnionInfo.guildName
	objSwf.txtMaster.text = UnionModel.MyUnionInfo.guildMasterName
	if UnionModel.MyUnionInfo.pos == UnionConsts.DutyLeader then
		objSwf.txtMaster.text = MainPlayerController:GetPlayer():GetName()
	end
	local extendNum = UnionModel.MyUnionInfo.extendNum or 0
	objSwf.txtNum.text = UnionModel.MyUnionInfo.memCnt..'/'..(UnionUtils:GetUnionMemMaxNum(UnionModel.MyUnionInfo.level) + extendNum)
	
	objSwf.txtMyDuty.text = UnionUtils:GetOperDutyName(UnionModel.MyUnionInfo.pos)
	objSwf.txtCurContribution.text = UnionModel.MyUnionInfo.contribution
	objSwf.txtTotalContribution.text = UnionModel.MyUnionInfo.totalContribution
	objSwf.txtInfo.text = ChatUtil.filter:filter(UnionModel.MyUnionInfo.guildNotice)
	
	self:UpdateUnionResList()
	self:UpdateUnionMoney()
	self:UpdatePermission()
	self:ShowUnionLevelIcon();	--帮派等级对应的右下角图标
	
	objSwf.tipsArea.rollOver = function() self:OnProcessBarMoneyOver(); end
	objSwf.tipsArea.rollOut = function() self:OnProcessBarMoneyOut(); end
	
	UnionController:ReqGetUnionPray();--请求获得帮派祈福
	UnionController:ReqAidInfo();
	self:InitRedPoint()
	self:RegisterTimers()
	self:ShowPrayButton()
end

-- 帮派升级
--adder:houxudong
--date:2016/8/1 11:31:00
UIUnionInfo.timerKey = nil;
function UIUnionInfo:InitRedPoint(  )
	local objSwf = self.objSwf
	if not objSwf then return; end
	if UnionUtils:CheckCanUnionLvUp() then
		PublicUtil:SetRedPoint(objSwf.btnLevelUp, nil, 1)
	else
		PublicUtil:SetRedPoint(objSwf.btnLevelUp, nil, 0)
	end
	if UnionUtils:CheckAidLevelUp() then
		PublicUtil:SetRedPoint(objSwf.btnJiachi, nil, 1)
	else
		PublicUtil:SetRedPoint(objSwf.btnJiachi, nil, 0)
	end
	if UnionUtils:CheckPray() then
		PublicUtil:SetRedPoint(objSwf.btnPray, nil, 1)
	else
		PublicUtil:SetRedPoint(objSwf.btnPray, nil, 0)
	end
end

function UIUnionInfo:RegisterTimers( )
	self.timerKey = TimerManager:RegisterTimer(function()
		self:InitRedPoint()
	end,1000,0); 
end

function UIUnionInfo:ShowUnionLevelIcon()
	local objSwf = self.objSwf
	if not objSwf then return end
	local unionLevel = UnionModel.MyUnionInfo.level;
	local unionLevelCfg = t_guild[unionLevel];
	if not unionLevelCfg then return end
	if objSwf.load_unionLevel.source ~= ResUtil:GetUnionLevelIcon(unionLevelCfg.lvicon) then
		objSwf.load_unionLevel.source = ResUtil:GetUnionLevelIcon(unionLevelCfg.lvicon);
		objSwf.load_unionLevel.loaded = function ()
			objSwf.load_unionLevel._x = objSwf.btnLevelUp._x + objSwf.btnLevelUp._width / 2  - objSwf.load_unionLevel._width / 2;
		end
	end
	
end

--消息处理
function UIUnionInfo:HandleNotification(name,body)
	if not self.bShowState then return end
	local objSwf = self:GetSWF("UIUnionInfo")
	if not objSwf then return; end
	
	if name == NotifyConsts.EditNoticeUpdate then
		objSwf.txtInfo.text = ChatUtil.filter:filter(body.guildNotice)
	elseif name == NotifyConsts.ChangeLeaderUpdate then
		objSwf.txtMyDuty.text = UnionUtils:GetOperDutyName(UnionModel.MyUnionInfo.pos)
		self:UpdatePermission()
	elseif name == NotifyConsts.UpdateContribute then
		objSwf.txtCurContribution.text = UnionModel.MyUnionInfo.contribution
		objSwf.txtTotalContribution.text = UnionModel.MyUnionInfo.totalContribution
		
		self:UpdateUnionResList()
		self:UpdateUnionMoney()
	elseif name == NotifyConsts.UpdateMyUnionMemInfo then
		-- objSwf.txtCurContribution.text = UnionModel.MyUnionInfo.contribution
		-- objSwf.txtTotalContribution.text = UnionModel.MyUnionInfo.totalContribution
		objSwf.txtMyDuty.text = UnionUtils:GetOperDutyName(UnionModel.MyUnionInfo.pos)
		self:UpdatePermission()
	elseif name == NotifyConsts.UpdateGuildInfo then
		self:OnShow()
	elseif name == NotifyConsts.ChangeGuildMasterName then
		objSwf.txtMaster.text = UnionModel.MyUnionInfo.guildMasterName
	elseif name == NotifyConsts.BagItemNumChange then
		self:ShowPrayButton()
	end
end

--tip加持显示
function UIUnionInfo:OnShowAidTip()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local cfg = UnionModel.aidInfo;
	if cfg == {} then return end
	objSwf.aidTip.txt_10.text = StrConfig['union175'];
	objSwf.aidTip.txt_5.text = StrConfig['union155'];
	if not cfg.aidLevel then return end
	local cfgInfo = t_guildwash[cfg.aidLevel]
	if not cfgInfo then return end
	objSwf.aidTip.txt_1.text = string.format(StrConfig['union151'],cfg.aidLevel);
	objSwf.aidTip.txt_2.htmlText = string.format(StrConfig['union152'],cfgInfo.expadd);
	objSwf.aidTip.txt_3.htmlText = string.format(StrConfig['union153'],cfgInfo.moneyadd);
	objSwf.aidTip.txt_4.htmlText = string.format(StrConfig['union154'],cfgInfo.zazenadd);
	objSwf.aidTip.txt_6.htmlText = StrConfig['union156'] .. string.format(StrConfig['union157'],cfg.att);
	objSwf.aidTip.txt_7.htmlText = StrConfig['union156'] .. string.format(StrConfig['union158'],cfg.def);
	objSwf.aidTip.txt_8.htmlText = StrConfig['union156'] .. string.format(StrConfig['union159'],cfg.maxhp);
	objSwf.aidTip.txt_9.htmlText = StrConfig['union156'] .. string.format(StrConfig['union160'],cfg.cri);
	
	objSwf.aidTip.txt_20.htmlText = string.format(StrConfig['union165'],cfgInfo.atkmax);
	objSwf.aidTip.txt_21.htmlText = string.format(StrConfig['union165'],cfgInfo.defmax);
	objSwf.aidTip.txt_22.htmlText = string.format(StrConfig['union165'],cfgInfo.hpmax);
	objSwf.aidTip.txt_23.htmlText = string.format(StrConfig['union165'],cfgInfo.subdefmax);
end

-- 消息监听
function UIUnionInfo:ListNotificationInterests()
	return {NotifyConsts.EditNoticeUpdate, 
			NotifyConsts.ChangeLeaderUpdate,
			NotifyConsts.UpdateContribute,
			NotifyConsts.ChangeGuildMasterName,
			NotifyConsts.BagItemNumChange,
			NotifyConsts.UpdateGuildInfo};
end

function UIUnionInfo:OnHide()
	UIUnionAidPanel:OnHide()
	if UIUnionContributionPanel.bShowState then
		UIUnionContributionPanel:Hide()
	end
	if UIUnionInfoEditPanel.bShowState then
		UIUnionInfoEditPanel:Hide()
	end
	if self.timerKey then
		self.timerKey = nil;
	end
end

------------------------------------------------------------------------------
--									UI事件处理
------------------------------------------------------------------------------
--技能鼠标移上
function UIUnionInfo:OnProcessBarMoneyOver()
	local colorStr = '#00ff00'
	local needLiveness = UnionUtils:GetUnionLevelUpNeedLiveness(UnionModel.MyUnionInfo.level)
	if UnionModel.MyUnionInfo.liveness < needLiveness then
		colorStr = '#ff0000'
	end
	local livenessStr = '<font color="'..colorStr..'">'..UnionModel.MyUnionInfo.liveness..'/'..needLiveness..'</font>'
	TipsManager:ShowBtnTips( string.format(StrConfig["union46"],livenessStr));
end

--技能鼠标移出
function UIUnionInfo:OnProcessBarMoneyOut()
	TipsManager:Hide();
end

-- 更新公告
function UIUnionInfo:OnEditNotice()
	if UnionModel.MyUnionInfo and UnionModel.MyUnionInfo.guildNotice then
		UIUnionInfoEditPanel:Open(UnionModel.MyUnionInfo.guildNotice)
	else
		UIUnionInfoEditPanel:Open('')
	end
end

-- 更新帮派活跃度
function UIUnionInfo:UpdateUnionMoney()
	local objSwf = self.objSwf
	if not objSwf then return; end
	
	local colorStr = '#FFFFFF'
	local needLiveness = UnionUtils:GetUnionLevelUpNeedLiveness(UnionModel.MyUnionInfo.level)
	if UnionModel.MyUnionInfo.liveness < needLiveness then
		colorStr = '#780000'
	end
	-- objSwf.labProcess.htmlText = '<font color="'..colorStr..'">'..UnionModel.MyUnionInfo.liveness..'/'..needLiveness..'</font>'
	
	objSwf.proLoaderValue.num = UnionModel.MyUnionInfo.liveness
	objSwf.proLoaderMax.num   = needLiveness
	objSwf.siBlessing.maximum = needLiveness;
	objSwf.siBlessing.value   = UnionModel.MyUnionInfo.liveness;
end

-- Tips1. 格式：升级条件<br/>帮派活跃度：500/1000（红字未达成）<br/>帮派资金：600/500（绿字已达成）这种。
function UIUnionInfo:ShowLevelUpTips()
	local objSwf = self.objSwf
	if not objSwf then return; end
	
	local colorStr = '<font color="#00ff00">（'..StrConfig['union48']..'）</font>'
	local needLiveness = UnionUtils:GetUnionLevelUpNeedLiveness(UnionModel.MyUnionInfo.level)
	if UnionModel.MyUnionInfo.liveness < needLiveness then
		colorStr = '<font color="#ff0000">（'..StrConfig['union49']..'）</font>'
	end
	
	local tipsLiveness = UnionModel.MyUnionInfo.liveness..'/'..needLiveness..colorStr..UnionResController:GetUnionResListStr()
	TipsManager:ShowBtnTips(string.format(StrConfig['union110'], tipsLiveness),TipsConsts.Dir_RightDown);
end

-- 更新帮派资源
function UIUnionInfo:UpdateUnionResList()
	local objSwf = self.objSwf
	if not objSwf then return; end

	-- 帮派资源列表
	self.ResItemsController:UpdateUnionResList()
end

-- 更新权限
function UIUnionInfo:UpdatePermission()
	local objSwf = self.objSwf
	if not objSwf then return; end
	
	-- 修改公告
	if UnionUtils:GetUnionPermissionByDuty(UnionModel.MyUnionInfo.pos, UnionConsts.mod_notice) == 1 then
		objSwf.btnInfo.visible = true
	else
		objSwf.btnInfo.visible = false
	end
	
	-- 升级
	objSwf.mcMaxLevel._visible = false
	if UnionUtils:GetUnionPermissionByDuty(UnionModel.MyUnionInfo.pos, UnionConsts.levelup) == 1 then
		if UnionModel.MyUnionInfo.level >= UnionConsts.UnionMaxLevel then
			objSwf.btnLevelUp.visible = false
		else
			objSwf.btnLevelUp.visible = true
		end
	else
		objSwf.btnLevelUp.visible = false
	end
	
	if UnionModel.MyUnionInfo.level >= UnionConsts.UnionMaxLevel then
		objSwf.mcMaxLevel._visible = true
	end
end

function UIUnionInfo:OnBtnLevelUpClick()
	if not UnionUtils:IsLevelUpReached() then
		FloatManager:AddSysNotice(2005034);--帮派升级所需资源不足，无法升级
		return
	end
	
	if not UnionUtils:IsLevelUpLivenessReached() then
		FloatManager:AddSysNotice(2005062);--帮派活跃度不足，无法升级
		return
	end
	SoundManager:PlaySfx(2053)
	UnionController:ReqLvUpGuild()
end

function UIUnionInfo:OnDelete()	
	if self.UnionResController then
		self.UnionResController:OnDelete()
		self.UnionResController = nil
	end
end


























