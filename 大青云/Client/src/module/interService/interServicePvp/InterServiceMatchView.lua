--[[
跨服匹配面板
liyuan
]]

_G.UIInterServiceMatchView = BaseUI:new("UIInterServiceMatchView");

function UIInterServiceMatchView:Create()
	self:AddSWF("interServerMatchPanel.swf", true, "center");
end

function UIInterServiceMatchView:OnLoaded(objSwf)
	
	objSwf.btnEnter.click = function() 
		InterServicePvpController:ReqExitMatchPvp()
	end	
	
end





-----------------------------------------------------------------------
function UIInterServiceMatchView:IsTween()
	return true;
end

function UIInterServiceMatchView:GetPanelType()
	return 1;
end

function UIInterServiceMatchView:IsShowSound()
	return true;
end

function UIInterServiceMatchView:OnShow()
	local objSwf = self.objSwf;
	if not objSwf then return; end	
		
end

function UIInterServiceMatchView:OnHide()
end

function UIInterServiceMatchView:GetWidth()
	return 903;
end

function UIInterServiceMatchView:GetHeight()
	return 632;
end

function UIInterServiceMatchView:OnBtnCloseClick()
	self:Hide();
end

function UIInterServiceMatchView:OnDelete()
	
end

---------------------------------消息处理------------------------------------
--监听消息列表
function UIInterServiceMatchView:ListNotificationInterests()
	return {
		
	};
end

--处理消息
function UIInterServiceMatchView:HandleNotification(name, body)
	
end

