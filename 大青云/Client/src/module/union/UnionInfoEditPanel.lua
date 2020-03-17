--[[
帮派:帮派列表面板
liyuan
2014年11月20日16:22:09
]]


_G.UIUnionInfoEditPanel = BaseUI:new("UIUnionInfoEditPanel")
UIUnionInfoEditPanel.lastNotice = ''
UIUnionInfoEditPanel.maxNoticeLength = 120;
function UIUnionInfoEditPanel:Create()
	self:AddSWF("unionInfoEditPanel.swf", true, "top");
end

function UIUnionInfoEditPanel:OnLoaded(objSwf, name)

	objSwf.btnOK.click = function() 
		local unionNotice = ''
		if objSwf.txtUnionInfo.text ~= objSwf.txtUnionInfo.defaultText then
			unionNotice = objSwf.txtUnionInfo.text or ''
			unionNotice = _G.strtrim(unionNotice)
		end
		UnionController:ReqChangeGuildNotice(unionNotice) 
		self:Hide() 
	end
	objSwf.btnCancel.click = function() self:Hide() end
	
	--close button
	objSwf.btnClose.click = function() self:Hide() end
	
	objSwf.txtUnionInfo.textChange = function()
								local name = objSwf.txtUnionInfo.text;
								if string.getLen(name) > UIUnionInfoEditPanel.maxNoticeLength then
									-- FloatManager:AddCenter(StrConfig['union51']);
									objSwf.txtUnionInfo.text = string.sub(name,1,180)
								end
	end
end

function UIUnionInfoEditPanel:Open(lastNotice)
	self.lastNotice = lastNotice
	
	self:Show()
end

function UIUnionInfoEditPanel:OnShow(name)
	local objSwf = self:GetSWF("UIUnionInfoEditPanel")
	if not objSwf then return; end
	
	objSwf.txtUnionInfo.text = ""
	if self.lastNotice and self.lastNotice ~= '' then
		objSwf.txtUnionInfo.text = self.lastNotice
	end
end

--消息处理
function UIUnionInfoEditPanel:HandleNotification(name,body)
	if not self.bShowState then return end
	local objSwf = self:GetSWF("UIUnionInfoEditPanel")
	if not objSwf then return; end
	
	if name == NotifyConsts.StageClick then
		local ipSearchTarget = string.gsub(objSwf.txtUnionInfo._target,"/",".");
		local ipSearchTarget1 = string.gsub(objSwf.btnOK._target,"/",".");
		if string.find(body.target,ipSearchTarget) or string.find(body.target,ipSearchTarget1) then
			return;
		end
	
		self:OnIpSearchFocusOut()
	elseif name == NotifyConsts.StageFocusOut then
		self:OnIpSearchFocusOut()
	end
end

-- 消息监听
function UIUnionInfoEditPanel:ListNotificationInterests()
	return {NotifyConsts.StageClick,
			NotifyConsts.StageFocusOut};
end

------------------------------------------------------------------------------
--									UI事件处理
------------------------------------------------------------------------------

--输入文本失去焦点
function UIUnionInfoEditPanel:OnIpSearchFocusOut()
	local objSwf = self.objSwf
	if not objSwf then return; end
	if objSwf.txtUnionInfo.focused then
		objSwf.txtUnionInfo.focused = false;
	end
end
function UIUnionInfoEditPanel:IsShowSound()
	return true;
end

function UIUnionInfoEditPanel:IsShowLoading()
	return true;
end