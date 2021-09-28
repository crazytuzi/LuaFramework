require "ui.dialog"

local LotteryConsumeBtn = {}
setmetatable(LotteryConsumeBtn, Dialog)
LotteryConsumeBtn.__index = LotteryConsumeBtn

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function LotteryConsumeBtn.getInstance()
	print("enter get LotteryConsumeBtn dialog instance")
	if not _instance then
		_instance = LotteryConsumeBtn:new()
		_instance:OnCreate()
	end

	return _instance
end

function LotteryConsumeBtn.getInstanceAndShow()
	print("enter LotteryConsumeBtn dialog instance show")
	if not _instance then
		_instance = LotteryConsumeBtn:new()
		_instance:OnCreate()
	else
		print("set LotteryConsumeBtn dialog visible")
		_instance:SetVisible(true)
	end

	return _instance
end

function LotteryConsumeBtn.getInstanceNotCreate()
	return _instance
end

function LotteryConsumeBtn.DestroyDialog()
	if _instance then
		_instance:OnClose()
		_instance = nil
	end
end

function LotteryConsumeBtn.ToggleOpenClose()
	if not _instance then
		_instance = LotteryConsumeBtn:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

----/////////////////////////////////////////------

function LotteryConsumeBtn.GetLayoutFileName()
	return "xiaohaozhuanpanbtn.layout"
end

function LotteryConsumeBtn:OnCreate()
	print("LotteryConsumeBtn dialog oncreate begin")
	Dialog.OnCreate(self)

	local winMgr = CEGUI.WindowManager:getSingleton()

	self.m_Btn = CEGUI.Window.toPushButton(winMgr:getWindow("xiaohaozhuanpan/btn"))
	if self.m_Btn then
		self.m_Btn:subscribeEvent("Clicked", self.HandleBtnClick, self)
	end

	print("LotteryConsumeBtn dialog oncreate end")
end

------------------- private: -----------------------------------

function LotteryConsumeBtn:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, LotteryConsumeBtn)

	return self
end

function LotteryConsumeBtn:HandleBtnClick()
	local CCsZhuanpanInfo = require 'protocoldef.knight.gsp.activity.cszhuanpan.ccszhuanpaninfo'
	local info = CCsZhuanpanInfo.Create()
	LuaProtocolManager.getInstance():send(info)
end

function LotteryConsumeBtn:addEffect()
	if not self.m_Btn then return end
	if not GetGameUIManager():IsWindowHaveEffect(self.m_Btn) then
		GetGameUIManager():AddUIEffect(self.m_Btn, MHSD_UTILS.get_effectpath(10305))
	end
end

return LotteryConsumeBtn