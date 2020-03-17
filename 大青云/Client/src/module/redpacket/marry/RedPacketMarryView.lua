--[[新婚红包界面
]]

_G.UIRedPacketMarry = UIRedPacketView:new("UIRedPacketMarry")

function UIRedPacketMarry:InitShow(objSwf)
	-- 显示为新婚红包
	objSwf.nameImg:gotoAndStop(2)
	objSwf.img22._visible = false;
end

function UIRedPacketMarry:GetModel()
	return RedPacketMarryModel
end