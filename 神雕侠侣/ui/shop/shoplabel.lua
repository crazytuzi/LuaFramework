require "utils.mhsdutils"
require "ui.dialog"

local ShopLabel = {}
setmetatable(ShopLabel, Dialog)
ShopLabel.__index = ShopLabel

local _instance

function ShopLabel.getInstance()
	if not _instance then
		_instance = ShopLabel:new()
		_instance:OnCreate()
	end
	return _instance
end

function ShopLabel.getInstanceNotCreate()
	return _instance
end

function ShopLabel.GetLayoutFileName()
	return "Lable.layout"
end

function ShopLabel:OnCreate()
	Dialog.OnCreate(self,nil, "shoplabel")

	local winMgr = CEGUI.WindowManager:getSingleton()
	self.m_pButton1 = winMgr:getWindow( "shoplabelLable/button")
	self.m_pButton2 = winMgr:getWindow( "shoplabelLable/button1")
	self.m_pButton3 = winMgr:getWindow( "shoplabelLable/button2")
	self.m_pButton4 = winMgr:getWindow( "shoplabelLable/button3")
	self.m_pButton5 = winMgr:getWindow( "shoplabelLable/button4")

	self.m_pButton1:setText(MHSD_UTILS.get_resstring(3033))
	self.m_pButton2:setText(MHSD_UTILS.get_resstring(3034))

	self.m_pButton3:setVisible(false)
	self.m_pButton4:setVisible(false)
	self.m_pButton5:setVisible(false)

	self.m_pButton1:subscribeEvent("Clicked", ShopLabel.HandleLabel1BtnClicked, self)
	self.m_pButton2:subscribeEvent("Clicked", ShopLabel.HandleLabel2BtnClicked, self)
end

function ShopLabel:new()
	local self={}
	self = Dialog:new()
	setmetatable(self, ShopLabel)
	return self
end

function ShopLabel.DestroyDialog()	
	LogInfo("ShopLabel destroy dialog")
	if _instance then
		_instance:OnClose()
		_instance = nil
        require("ui.shop.shopdlg").DestroyDialog()
        require("ui.shop.shopsecretdlg").DestroyDialog()
	end	

end

function ShopLabel.Show(index, other)
	ShopLabel.getInstance():ShowOnly(index)
	if other ~= nil then
	 local shopdlg = require "ui.shop.shopdlg"
	 shopdlg.getInstanceAndShow():SetIndex(other)
	end
end

function ShopLabel:ShowOnly(index)
  local shopdlg = require "ui.shop.shopdlg"
  local shopsecretdlg = require "ui.shop.shopsecretdlg"
	--hide all
	if shopdlg.getInstanceNotCreate() then
		shopdlg:getInstanceNotCreate():GetWindow():setVisible(false)
	end

	if shopsecretdlg.getInstanceNotCreate() then
		shopsecretdlg:getInstanceNotCreate():GetWindow():setVisible(false)
	end

	--show index dialog
	if index == 1 then
		shopdlg.getInstanceAndShow():SetLimitTimeBuyData(self.m_limitTimeBuyData, self.m_lefttime)
	elseif index == 2 then
		shopsecretdlg.getInstanceAndShow()
	end
end

function ShopLabel:HandleLabel1BtnClicked(e)
	LogInfo("label 1 clicked")
	self:ShowOnly(1)
end

function ShopLabel:HandleLabel2BtnClicked(e)
	LogInfo("label 2 clicked")
	self:ShowOnly(2)
end

function ShopLabel:SetLimitTimeBuyData(data, lefttime)
	LogInfo("ShopLabel:SetLimitTimeBuyData")
	self.m_limitTimeBuyData = data
  self.m_lefttime = lefttime
end

return ShopLabel
