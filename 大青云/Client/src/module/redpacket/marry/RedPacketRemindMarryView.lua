--[[新婚红包界面
]]

_G.UIRedPacketRemindMarry = BaseUI:new("UIRedPacketRemindMarry")

function UIRedPacketRemindMarry:Create()
	self:AddSWF("redpacketRemindMarry.swf", true, "bottom2")
end

function UIRedPacketRemindMarry:OnLoaded(objSwf)
	objSwf.btnredpacketremind.click = function() self:OnBtnRedpacketClick(); end;
end

--点击红包按钮
function UIRedPacketRemindMarry:OnBtnRedpacketClick()
	UIRedPacketListMarry:Show();
end