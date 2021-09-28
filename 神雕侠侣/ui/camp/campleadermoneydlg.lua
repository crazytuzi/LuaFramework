local Dialog = require "ui.dialog"

CampLeaderMoneyDlg = {}
setmetatable(CampLeaderMoneyDlg, Dialog)
CampLeaderMoneyDlg.__index = CampLeaderMoneyDlg

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function CampLeaderMoneyDlg.getInstance()
	LogInfo("enter get CampLeaderMoneyDlg instance")
    if not _instance then
        _instance = CampLeaderMoneyDlg:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function CampLeaderMoneyDlg.getInstanceAndShow()
	LogInfo("enter CampLeaderMoneyDlg instance show")
    if not _instance then
        _instance = CampLeaderMoneyDlg:new()
        _instance:OnCreate()
	else
		LogInfo("set CampLeaderMoneyDlg visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function CampLeaderMoneyDlg.getInstanceNotCreate()
    return _instance
end

function CampLeaderMoneyDlg.DestroyDialog()
	if _instance then 
		LogInfo("destroy CampLeaderMoneyDlg")
		_instance:OnClose()
		_instance = nil
	end
end

function CampLeaderMoneyDlg.ToggleOpenClose()
	if not _instance then 
		_instance = CampLeaderMoneyDlg:new() 
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

function CampLeaderMoneyDlg.GetLayoutFileName()
    return "campleadermoney.layout"
end

function CampLeaderMoneyDlg:OnCreate()
	LogInfo("CampLeaderMoneyDlg oncreate begin")
    Dialog.OnCreate(self)
    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
	self.m_pTotalNum = winMgr:getWindow("campleadermoney/num0") -- 剩余基金
	self.m_pPerNum = winMgr:getWindow("campleadermoney/num1") -- 回报单额
	self.m_pMore100W = CEGUI.toPushButton(winMgr:getWindow("campleadermoney/more1")) -- 追加100万
	self.m_pMore1000W = CEGUI.toPushButton(winMgr:getWindow("campleadermoney/more2")) -- 追加1000万
	self.m_pUp1W = CEGUI.toPushButton(winMgr:getWindow("campleadermoney/add2")) -- 增加1万
	self.m_pDown1W = CEGUI.toPushButton(winMgr:getWindow("campleadermoney/add1")) -- 减少1万
	self.m_pOK = CEGUI.toPushButton(winMgr:getWindow("campleadermoney/ok")) -- 开启回报
	self.m_pCancel = CEGUI.toPushButton(winMgr:getWindow("campleadermoney/ok5")) -- 全部取出
	self.m_pClose = winMgr:getWindow("campleadermoney/closed")

    -- subscribe event
	self.m_pMore100W:setID(1)
	self.m_pMore100W:subscribeEvent("Clicked", CampLeaderMoneyDlg.HandleBtnClicked, self) 
	self.m_pMore1000W:setID(2)
	self.m_pMore1000W:subscribeEvent("Clicked", CampLeaderMoneyDlg.HandleBtnClicked, self) 
	self.m_pUp1W:setID(3)
	self.m_pUp1W:subscribeEvent("Clicked", CampLeaderMoneyDlg.HandleBtnClicked, self) 
	self.m_pDown1W:setID(4)
	self.m_pDown1W:subscribeEvent("Clicked", CampLeaderMoneyDlg.HandleBtnClicked, self) 
	self.m_pOK:setID(5)
	self.m_pOK:subscribeEvent("Clicked", CampLeaderMoneyDlg.HandleBtnClicked, self) 
	self.m_pCancel:setID(6)
	self.m_pCancel:subscribeEvent("Clicked", CampLeaderMoneyDlg.HandleBtnClicked, self) 
	self.m_pClose:subscribeEvent("Clicked", CampLeaderMoneyDlg.HandleCloseBtnClicked, self)

	LogInfo("CampLeaderMoneyDlg oncreate end")
end

------------------- private: -----------------------------------


function CampLeaderMoneyDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, CampLeaderMoneyDlg)
    return self
end

function CampLeaderMoneyDlg:Refresh(num, per)
	self.m_money = 0
	self.m_num = num/10000
	self.m_per = per/10000
	self.m_pTotalNum:setText(tostring(self.m_num))
	self.m_pPerNum:setText(tostring(self.m_per))
end

function CampLeaderMoneyDlg:HandleBtnClicked(args)
	LogInfo("CampLeaderMoneyDlg HandleBtnClicked")
	local e = CEGUI.toWindowEventArgs(args)
	local id = e.window:getID()
	local temp = 0
	if     id == 1 then -- 追加100万
		temp = self.m_money + 100
		if GetRoleItemManager():GetPackMoney() < temp*10000 then
			GetGameUIManager():AddMessageTipById(145647)
			return
		end
		if temp+self.m_num > 99999 then
			GetGameUIManager():AddMessageTipById(145648)
			return
		end
		self.m_money = temp
		self.m_pTotalNum:setText(tostring(self.m_num+self.m_money))
	elseif id == 2 then -- 追加1000万
		temp = self.m_money + 1000
		if GetRoleItemManager():GetPackMoney() < temp*10000 then
			GetGameUIManager():AddMessageTipById(145647)
			return
		end
		if temp+self.m_num > 99999 then
			GetGameUIManager():AddMessageTipById(145648)
			return
		end
		self.m_money = temp
		self.m_pTotalNum:setText(tostring(self.m_num+self.m_money))
	elseif id == 3 then -- 增加1万
		temp = self.m_per + 1
		if temp > 50 then
			GetGameUIManager():AddMessageTipById(145649)
			return
		end
		self.m_per = temp
		self.m_pPerNum:setText(tostring(self.m_per))
	elseif id == 4 then -- 减少1万
		temp = self.m_per - 1
		if temp < 0 then
			GetGameUIManager():AddMessageTipById(145650)
			return
		end
		self.m_per = temp
		self.m_pPerNum:setText(tostring(self.m_per))
	elseif id == 5 then -- 开启回报
		local CUpdateFoundInfo = require "protocoldef.knight.gsp.campleader.cupdatefoundinfo"
		local req = CUpdateFoundInfo.Create()
		req.addfoundmoney = self.m_money*10000
		req.returnmoney = self.m_per*10000
		LuaProtocolManager.getInstance():send(req)
	elseif id == 6 then -- 全部取出
		local CReqGetFound = require "protocoldef.knight.gsp.campleader.creqgetfound"
		local req = CReqGetFound.Create()
		LuaProtocolManager.getInstance():send(req)
	end
end

function CampLeaderMoneyDlg:HandleCloseBtnClicked(args)
	CampLeaderMoneyDlg.DestroyDialog()
	return true
end

return CampLeaderMoneyDlg
