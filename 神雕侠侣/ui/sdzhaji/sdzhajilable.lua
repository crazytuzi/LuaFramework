local MHSD_UTILS = require "utils.mhsdutils"
local Dialog = require "ui.dialog"
local SDZhiLuDlg = require "ui.sdzhaji.sdzhiludlg"
local SDZhuanJiDlg = require "ui.sdzhaji.sdzhuanjidlg"
local SDZhangJieDlg = require "ui.sdzhaji.sdzhangjiedlg"

SDZhaJiLable = {}

setmetatable(SDZhaJiLable, Dialog)
SDZhaJiLable.__index = SDZhaJiLable

local _instance

function SDZhaJiLable.getInstance()
	if not _instance then
		_instance = SDZhaJiLable:new()
		_instance:OnCreate()
	end
	return _instance
end

function SDZhaJiLable.getInstanceNotCreate()
	return _instance
end

function SDZhaJiLable.GetLayoutFileName()
	return "Lable.layout"
end

function SDZhaJiLable:OnCreate()
	Dialog.OnCreate(self,nil, "SDZhaJi")

	local winMgr = CEGUI.WindowManager:getSingleton()
	self.m_pButton1 = winMgr:getWindow( "SDZhaJiLable/button")
	self.m_pButton2 = winMgr:getWindow( "SDZhaJiLable/button1")
	self.m_pButton3 = winMgr:getWindow( "SDZhaJiLable/button2")
	self.m_pButton4 = winMgr:getWindow( "SDZhaJiLable/button3")
	self.m_pButton5 = winMgr:getWindow( "SDZhaJiLable/button4")

	self.m_pButton1:setText(MHSD_UTILS.get_resstring(3167))
	self.m_pButton2:setText(MHSD_UTILS.get_resstring(3169))

	if GetDataManager():GetMainCharacterLevel() >= 90 then
		self.m_pButton3:setText(MHSD_UTILS.get_resstring(3168))
	else
		self.m_pButton3:setVisible(false)
	end

	self.m_pButton4:setVisible(false)
	self.m_pButton5:setVisible(false)

	self.m_pButton1:subscribeEvent("Clicked", SDZhaJiLable.HandleLabel1BtnClicked, self)
	self.m_pButton2:subscribeEvent("Clicked", SDZhaJiLable.HandleLabel2BtnClicked, self)
	self.m_pButton3:subscribeEvent("Clicked", SDZhaJiLable.HandleLabel3BtnClicked, self)
	self.m_pButton4:subscribeEvent("Clicked", SDZhaJiLable.HandleLabel4BtnClicked, self)
end


function SDZhaJiLable:new()
	local self={}
	self = Dialog:new()
	setmetatable(self, SDZhaJiLable)
	return self
end

function SDZhaJiLable.DestroyDialog()	
	if _instance then
		--close all 
		if SDZhiLuDlg.getInstanceNotCreate() then
			SDZhiLuDlg.CloseDialog()
		end
		if SDZhuanJiDlg.getInstanceNotCreate() then
			SDZhuanJiDlg.CloseDialog()
		end
		if SDZhangJieDlg.getInstanceNotCreate() then
			SDZhangJieDlg.CloseDialog()
		end

		_instance:OnClose()
		_instance = nil
	end	
end

function SDZhaJiLable.Show(index)
	index = index or 1
	
	if index == 1 then
		SDZhiLuDlg.OnRequireOpenSDZhiluDlg()
	elseif index == 2 then
		SDZhuanJiDlg.OnRequireOpenSDZhuanJiDlg()
	elseif index == 3 then
		SDZhangJieDlg.OnRequireOpenSDZhangJieDlg()
	end
end

function SDZhaJiLable.OnReadyShow(index)
	SDZhaJiLable.getInstance():SetVisible(true)
	if index ~= 1 and SDZhiLuDlg.getInstanceNotCreate() then
		SDZhiLuDlg:getInstanceNotCreate():GetWindow():setVisible(false)
	end

	if index ~= 2 and SDZhuanJiDlg.getInstanceNotCreate() then
		SDZhuanJiDlg:getInstanceNotCreate():GetWindow():setVisible(false)
	end

	if index ~= 3 and SDZhangJieDlg.getInstanceNotCreate() then
		SDZhangJieDlg:getInstanceNotCreate():GetWindow():setVisible(false)
	end
end

function SDZhaJiLable:HandleLabel1BtnClicked(e)
	LogInfo("label 1 clicked")
	SDZhaJiLable.Show(1)	
	return true
end

function SDZhaJiLable:HandleLabel2BtnClicked(e)
	LogInfo("label 2 clicked")
	SDZhaJiLable.Show(2)	
	return true
end

function SDZhaJiLable:HandleLabel3BtnClicked(e)
	LogInfo("label 3 clicked")
	SDZhaJiLable.Show(3)	
	return true
end

function SDZhaJiLable:HandleLabel4BtnClicked(e)
	LogInfo("label 4 clicked")
	SDZhaJiLable.Show(4)
	return true
end

return SDZhaJiLable
