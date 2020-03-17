--[[公告更新面板
zhangshuhui
2016年11月26日11:09:16
]]

_G.UIUpdateNoticeView = BaseUI:new("UIUpdateNoticeView")

function UIUpdateNoticeView:Create()
	self:AddSWF("updateNoticePanel.swf", true, 'center')
end

function UIUpdateNoticeView:OnLoaded(objSwf,name)
	objSwf.btnclose.click = function () self:Hide(); end
end

function UIUpdateNoticeView:IsTween()
	return true
end

function UIUpdateNoticeView:GetPanelType()
	return 1
end

function UIUpdateNoticeView:BeforeTween()
	self.tweenStartPos = UIMainTop:GetMailBtnPos()
end

function UIUpdateNoticeView:GetWidth(szName)
	return 464 
end

function UIUpdateNoticeView:GetHeight(szName)
	return 688
end

function UIUpdateNoticeView:OnShow(name)
	--显示
	self:ShowUpdateNoticeInfo();
end

function UIUpdateNoticeView:OnHide()
end

--显示
function UIUpdateNoticeView:ShowUpdateNoticeInfo()
	local objSwf = self.objSwf;
	if not objSwf then return end
	
	objSwf.textArea.htmlText = updateContentcfg.context;
end