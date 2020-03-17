--[[
帮派:帮派帮主组织
liyuan
2014年11月20日16:22:09
]]


_G.UIUnionInviteDialogPanel = BaseUI:new("UIUnionInviteDialogPanel")
UIUnionInviteDialogPanel.inviteName = ''
UIUnionInviteDialogPanel.inviteInfo = ''
UIUnionInviteDialogPanel.callBackHanlder = nil
UIUnionInviteDialogPanel.cancelHanlder = nil

function UIUnionInviteDialogPanel:Create()
	self:AddSWF("unionInviteDialogPanel.swf", true, "top");
end

function UIUnionInviteDialogPanel:OnLoaded(objSwf, name)
	objSwf.btnOK.click = function() 	
		if self.callBackHanlder then
			self:callBackHanlder()
			self.callBackHanlder = nil
		end	
		self:Hide() 
	end
	objSwf.btnCancel.click = function()
		if self.cancelHanlder then
			self:cancelHanlder()
			self.cancelHanlder = nil
		end
		self:Hide() 
	end	
	objSwf.btnClose.click = function() self:Hide() end	
end

function UIUnionInviteDialogPanel:Open(inviteName,inviteInfo,callBackHanlder,cancelHanlder,name,time)
	self.inviteName = inviteName
	self.inviteInfo = inviteInfo
	self.callBackHanlder = callBackHanlder
	self.cancelHanlder = cancelHanlder
	self.startname = name;
	self.time = time;
	
	if self:IsShow() then
		self:UpdateInfo()
	else
		self:Show()	
	end
end

function UIUnionInviteDialogPanel:OnShow(name)
	self:UpdateInfo()
end

function UIUnionInviteDialogPanel:UpdateInfo()
	local objSwf = self.objSwf
	if not objSwf then return; end
	FPrint(self.inviteName)
	objSwf.txtName.htmlText = self.inviteName
	objSwf.txtInfo.htmlText = self.inviteInfo
	objSwf.startname_txt.htmlText = string.format(StrConfig["union74"],self.startname)
	local year, month, day, hour, minute, second = CTimeFormat:todate(self.time,true);
 	local time = string.format('%02d:%02d:%02d',hour, minute, second);
	objSwf.starttime_txt.htmlText = string.format(StrConfig["union75"],time)
end

------------------------------------------------------------------------------
--									UI事件处理
------------------------------------------------------------------------------
function UIUnionInviteDialogPanel:IsShowSound()
	return true;
end

function UIUnionInviteDialogPanel:IsShowLoading()
	return true;
end
