
require "utils.mhsdutils"
require "ui.shijiebei.shijiebeishopdlg"
require "ui.shijiebei.shijiebeirankdlg"
require "ui.dialog"

ShijiebeiLabel = {}

setmetatable(ShijiebeiLabel, Dialog)
ShijiebeiLabel.__index = ShijiebeiLabel

local _instance

function ShijiebeiLabel.getInstance()
	if not _instance then
		_instance = ShijiebeiLabel:new()
		_instance:OnCreate()
	end
	return _instance
end

function ShijiebeiLabel.getInstanceNotCreate()
	return _instance
end

function ShijiebeiLabel.GetLayoutFileName()
	return "Lable.layout"
end

function ShijiebeiLabel:OnCreate()
	Dialog.OnCreate(self,nil, "shijiebei")

	local winMgr = CEGUI.WindowManager:getSingleton()
	self.m_pButton1 = winMgr:getWindow( "shijiebeiLable/button")
	self.m_pButton2 = winMgr:getWindow( "shijiebeiLable/button1")
	self.m_pButton3 = winMgr:getWindow( "shijiebeiLable/button2")
	self.m_pButton4 = winMgr:getWindow( "shijiebeiLable/button3")
	self.m_pButton5 = winMgr:getWindow( "shijiebeiLable/button4")

	self.m_pButton1:setText(MHSD_UTILS.get_resstring(3086))
	self.m_pButton2:setText(MHSD_UTILS.get_resstring(3087))

	self.m_pButton3:setVisible(false)
	self.m_pButton4:setVisible(false)
	self.m_pButton5:setVisible(false)

	self.m_pButton1:subscribeEvent("Clicked", ShijiebeiLabel.HandleLabel1BtnClicked, self)
	self.m_pButton2:subscribeEvent("Clicked", ShijiebeiLabel.HandleLabel2BtnClicked, self)
end

function ShijiebeiLabel:new()
	local self={}
	self = Dialog:new()
	setmetatable(self, ShijiebeiLabel)
	return self
end

function ShijiebeiLabel.DestroyDialog()	
	LogInfo("ShijiebeiLabel destroy dialog")	
	if _instance then
		_instance:OnClose()
		_instance = nil
	end	
end

function ShijiebeiLabel.Show(index)
	ShijiebeiLabel.getInstance():ShowOnly(index)
end

function ShijiebeiLabel:ShowOnly(index)
	--hide all
	if ShijiebeiShopDialog.getInstanceNotCreate() then
		ShijiebeiShopDialog:getInstanceNotCreate():GetWindow():setVisible(false)
	end

	if ShijiebeiRankDialog.getInstanceNotCreate() then
		ShijiebeiRankDialog:getInstanceNotCreate():GetWindow():setVisible(false)
	end

	--show index dialog
	if index == 1 then
		local _tmp = ShijiebeiShopDialog.getInstanceAndShow()
		_tmp:SetLeftTimes(self.m_used_times, self.m_free_times, self.m_pay_times)
	elseif index == 2 then
		local _tmp = ShijiebeiRankDialog.getInstanceAndShow()
		_tmp:SetRankData(self.m_rank)
	end
end

function ShijiebeiLabel:HandleLabel1BtnClicked(e)
	LogInfo("label 1 clicked")
	require "protocoldef.knight.gsp.activity.football.cfootballinfo"
    local p = CFootballInfo.Create()
    require "manager.luaprotocolmanager":send(p)
end

function ShijiebeiLabel:HandleLabel2BtnClicked(e)
	LogInfo("label 2 clicked")

	require "protocoldef.knight.gsp.activity.football.cfootballrank"
    local p = CFootballRank.Create()
    require "manager.luaprotocolmanager":send(p)
end

function ShijiebeiLabel:SetLeftTimes(used_times, free_times, pay_times)
	LogInfo("ShijiebeiLabel:SetLeftTimes")
	self.m_used_times = used_times
	self.m_free_times = free_times
	self.m_pay_times = pay_times
end

function ShijiebeiLabel:SetRankData(rank)
	LogInfo("ShijiebeiLabel:SetRankData")
	self.m_rank = rank
end

return ShijiebeiLabel
