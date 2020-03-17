--[[
帮派:帮派列表面板
liyuan
2014年11月20日16:22:09
]]


_G.UIUnionInfoDialog = BaseUI:new("UIUnionInfoDialog")
UIUnionInfoDialog.guildId = nil
UIUnionInfoDialog.applyFlag = nil

function UIUnionInfoDialog:Create()
	self:AddSWF("unionInfoDialogPanel.swf", true, "top");
end

function UIUnionInfoDialog:OnLoaded(objSwf, name)
	objSwf.btnClear.visible = false;
	objSwf.btnClear.click = function() self:OnBtnClearClick(); end
	objSwf.btnClose.click = function() self:OnBtnCloseClick() end
	objSwf.labUnionNotice.text = UIStrConfig['union71']
	objSwf.btnCreate.click = function()
		-- 点申请
		if not self.guildId then return end
		
		UnionController:ReqApplyGuild(self.guildId, 1)
		self.objSwf.btnCreate.disabled = true
	end
end

function UIUnionInfoDialog:OnBtnCloseClick()
	self:Hide()
end

function UIUnionInfoDialog:ShowUnionInfo(guildId, applyFlag)
	self.guildId = guildId
	self.applyFlag = applyFlag
	if guildId then UnionController:ReqOtherGuildInfo(guildId) end
	self:UpdateBtnCreateState(applyFlag)
end

function UIUnionInfoDialog:OnShow(name)
	if self.guildId then UnionController:ReqOtherGuildInfo(self.guildId) end
	self:UpdateBtnCreateState(self.applyFlag)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.btnClear.visible = GMModule:IsGM();
end

function UIUnionInfoDialog:UpdateBtnCreateState(applyFlag)
	if not self.objSwf then return end
	
	if UnionUtils:CheckMyUnion() then 
		self.objSwf.btnCreate.label = UIStrConfig["union49"]
		self.objSwf.btnCreate.disabled = true
		return
	end
	
	if applyFlag == 1 then
		self.objSwf.btnCreate.label = UIStrConfig["union92"]
		self.objSwf.btnCreate.disabled = true
	else
		self.objSwf.btnCreate.label = UIStrConfig["union49"]
		self.objSwf.btnCreate.disabled = false
	end
end

function UIUnionInfoDialog:Open(guildId, applyFlag)
	self.guildId = guildId
	self.applyFlag = applyFlag
	self:Show()
end

--消息处理
function UIUnionInfoDialog:HandleNotification(name,body)
	if not self.bShowState then return end
	local objSwf = self:GetSWF("UIUnionInfoDialog")
	if not objSwf then return; end
	
	if name == NotifyConsts.OtherGuildInfoUpdate then
		self:UpdateUnionInfo(body.guildInfo)
	elseif name == NotifyConsts.SetUnionApplyResult then
		if body.guildId == self.guildId then
			UpdateBtnCreateState(body.applyFlag)
		end
	end
end

-- 消息监听
function UIUnionInfoDialog:ListNotificationInterests()
	return {NotifyConsts.OtherGuildInfoUpdate,
			NotifyConsts.SetUnionApplyResult};
end

function UIUnionInfoDialog:UpdateUnionInfo(guildInfo)
	local objSwf = self:GetSWF("UIUnionInfoDialog")
	if not objSwf then return; end
	-- FTrace(guildInfo)
	local extendNum = guildInfo.extendNum or 0
	local maxMemCnt = UnionUtils:GetUnionMemMaxNum(guildInfo.level) + extendNum
	local infoStr = '<font color="#9f7a31">'..UIStrConfig['union10']..'</font>'..guildInfo.guildName..'<br/>'..
					'<font color="#9f7a31">'..UIStrConfig['union7']..'</font>'..guildInfo.rank..'<br/>'..
					'<font color="#9f7a31">'..UIStrConfig['union11']..'</font>'..guildInfo.guildMasterName..'<br/>'..
					'<font color="#9f7a31">'..UIStrConfig['union8']..'</font>'..guildInfo.level..'<br/>'..
					'<font color="#9f7a31">'..UIStrConfig['union66']..'</font>'..guildInfo.captial..'<br/>'..
					'<font color="#9f7a31">'..UIStrConfig['union12']..'</font>'..guildInfo.memCnt..'/'..maxMemCnt..'<br/>'
					
	objSwf.txtUnionInfo.htmlText = infoStr
	objSwf.txtUnionNotice.text = ChatUtil.filter:filter(guildInfo.guildNotice);
end
function UIUnionInfoDialog:IsShowSound()
	return true;
end

function UIUnionInfoDialog:IsShowLoading()
	return true;
end

function UIUnionInfoDialog:OnBtnClearClick()
	if not self.guildId then return; end
	GMController:ChangeGuildAnn(self.guildId,"")
	local  objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.txtUnionNotice.text = "";
end
















