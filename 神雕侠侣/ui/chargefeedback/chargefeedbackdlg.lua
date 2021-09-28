require "ui.dialog"


local ChargeFeedbackDlg = {}
setmetatable(ChargeFeedbackDlg, Dialog)
ChargeFeedbackDlg.__index = ChargeFeedbackDlg

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function ChargeFeedbackDlg.getInstance()
	print("enter get ChargeFeedbackDlg dialog instance")
    if not _instance then
        _instance = ChargeFeedbackDlg:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function ChargeFeedbackDlg.getInstanceAndShow()
	print("enter ChargeFeedbackDlg dialog instance show")
    if not _instance then
        _instance = ChargeFeedbackDlg:new()
        _instance:OnCreate()
	else
		print("set ChargeFeedbackDlg dialog visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function ChargeFeedbackDlg.getInstanceNotCreate()
    return _instance
end

function ChargeFeedbackDlg.DestroyDialog()
	if _instance then 
		_instance:OnClose()
		_instance = nil
	end
end

function ChargeFeedbackDlg.ToggleOpenClose()
	if not _instance then 
		_instance = ChargeFeedbackDlg:new() 
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

function ChargeFeedbackDlg.GetLayoutFileName()
    return "lishichongzhifankuimain.layout"
end

function ChargeFeedbackDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, ChargeFeedbackDlg)

    return self
end

function ChargeFeedbackDlg:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

	self.m_days = winMgr:getWindow("lishichongzhifankuimain/Back/shuoming/txt")
	self.m_percentvalue = winMgr:getWindow("lishichongzhifankuimain/Back/red/txt/tt")
	self.m_nexttext = winMgr:getWindow("lishichongzhifankuimain/Back/down1")
	self.m_nextpercent = winMgr:getWindow("lishichongzhifankuimain/Back/down/num1")	
	
	self.m_tips = CEGUI.Window.toPushButton(winMgr:getWindow("lishichongzhifankuimain/Back/imgb"))
	self.m_tips:subscribeEvent("Clicked", ChargeFeedbackDlg.HandleTipsBtn, self)
	
	self.m_reward = CEGUI.Window.toPushButton(winMgr:getWindow("lishichongzhifankuimain/Back/imgb1"))
	self.m_reward:subscribeEvent("Clicked", ChargeFeedbackDlg.HandleRewardBtn, self)
end

function ChargeFeedbackDlg:HandleTipsBtn()
	ChargeFeedbackDlg:ShowTips()
end

function ChargeFeedbackDlg:ShowTips()
	local ChargeFeedbackHints = require "ui.chargefeedback.chargefeedbackhints"
	ChargeFeedbackHints.getInstanceAndShow()
end

function ChargeFeedbackDlg:HandleRewardBtn()
	if self.m_flag ~= 1 then
		ChargeFeedbackDlg:ShowTips()
		return
	end
	
	local req = require("protocoldef.knight.gsp.activity.chongzhifanli.cgetrechargeback").Create()
	LuaProtocolManager.getInstance():send(req)
end

function ChargeFeedbackDlg:Initial(days,percent,nextpercent,has_next,flag)
	self.m_days:setText(tostring(days))
	self.m_percentvalue:setText(tostring(percent))
	self.m_nextpercent:setText(tostring(nextpercent))
	self.m_flag = flag	
	if has_next == 0 then
		self.m_nexttext:setVisible(false)
	else
		self.m_nexttext:setVisible(true)
	end	
end

return ChargeFeedbackDlg