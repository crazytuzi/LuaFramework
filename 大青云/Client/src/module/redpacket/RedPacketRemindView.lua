--[[全服红包界面
zhangshuhui
2015年10月7日19:59:00
]]

_G.UIRedPacketRemindView = BaseUI:new("UIRedPacketRemindView")

function UIRedPacketRemindView:Create()
	self:AddSWF("redpacketRemindPanel.swf", true, "bottom2")
end

function UIRedPacketRemindView:OnLoaded(objSwf,name)
	--关闭
	objSwf.btnredpacketremind.click = function() self:OnBtnRedpacketClick(); end;
end

--点击红包按钮
function UIRedPacketRemindView:OnBtnRedpacketClick()
	UIRedPacketListView:Show();
end

function UIRedPacketRemindView:OnShow(name)
	self:UpdateRedPacketNum();
end

function UIRedPacketRemindView:UpdateRedPacketNum()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.btnredpacketremind.tfnum = RedPacketModel:GetredpacketNum();
end