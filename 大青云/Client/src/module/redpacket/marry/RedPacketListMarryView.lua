--[[新婚红包列表界面
]]

_G.UIRedPacketListMarry = UIRedPacketListView:new("UIRedPacketListMarry")

function UIRedPacketListMarry:Init(objSwf)
	objSwf.bg:gotoAndPlay("marry")
end

function UIRedPacketListMarry:GetModel()
	return RedPacketMarryModel
end

function UIRedPacketListMarry:GetRemindView()
	return UIRedPacketRemindMarry
end