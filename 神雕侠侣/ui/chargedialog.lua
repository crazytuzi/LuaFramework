require "ui.dialog"
require "ui.chargecell"

require "utils.mhsdutils"
require "manager.beanconfigmanager"
require "protocoldef.knight.gsp.yuanbao.creqserverid"
require "protocoldef.knight.gsp.yuanbao.creqcharge"

ChargeDialog = {}
setmetatable(ChargeDialog, Dialog)
ChargeDialog.__index = ChargeDialog 
ChargeDialog.m_ChargeState = 1
ChargeDialog.m_ChargeFlag = 0

s_flagYHReqServiceID = 1

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;

function ChargeDialog.GeneralReqCharge()
	local LuaAndroid = require "android"

	if Config.MOBILE_ANDROID == 1 and Config.CUR_3RD_LOGIN_SUFFIX == "lngz" then
        require "luaj"
        local param = {}
        param[1] = tostring(GetDataManager():GetMainCharacterID())
        luaj.callStaticMethod("com.wanmei.mini.condor.longzhong.PlatformLongZhong", "purchase2", param, "(Ljava/lang/String;)V")
    elseif Config.MOBILE_ANDROID == 1 and Config.CUR_3RD_LOGIN_SUFFIX == "efad" then
        require "luaj"
        local param = {}
        param[1] = tostring(GetDataManager():GetMainCharacterLevel())
        param[2] = tostring(GetDataManager():GetMainCharacterName())
        luaj.callStaticMethod("com.wanmei.mini.condor.efun.PlatformEFun", "purchase2", param, nil)
    elseif Config.MOBILE_ANDROID == 1 and Config.CUR_3RD_LOGIN_SUFFIX == "twap" then
        local LuaAndroid = require "android"
        LuaAndroid.TwApp01buy()
    elseif Config.MOBILE_ANDROID == 1 and Config.CUR_3RD_LOGIN_SUFFIX == "tw36" then
        local LuaAndroid = require "android"
        LuaAndroid.Tw360buy()
    else
	    local reqAction = CReqCharge.Create()
	    LuaProtocolManager.getInstance():send(reqAction)
	end
end

function ChargeDialog.getInstance()
	LogInfo("ChargeDialog getinstance")
    if not _instance then
        _instance = ChargeDialog:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function ChargeDialog.getInstanceAndShow()
	print("enter instance show")
    if not _instance then
        _instance = ChargeDialog:new()
        _instance:OnCreate()
	else
		print("set visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function ChargeDialog.getInstanceNotCreate()
    return _instance
end

function ChargeDialog.DestroyDialog()
	if _instance then 
		_instance:OnClose()		
		_instance = nil
	end
end

function ChargeDialog.ToggleOpenClose()
	if not _instance then 
		_instance = ChargeDialog:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function ChargeDialog.IsShow()
    if _instance and _instance:IsVisible() then
        return true
    else
        return false
    end
end

----/////////////////////////////////////////------

function ChargeDialog.GetLayoutFileName()
    return "addcashdlg.layout"
end

function ChargeDialog:OnCreate()
	LogInfo("enter ChargeDialog oncreate")
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
	self.m_TabBtn = {}
    self.m_TabBtn["charge"] = CEGUI.Window.toPushButton(winMgr:getWindow("addcash/main/btn1"))
    self.m_TabBtn["history"] = CEGUI.Window.toPushButton(winMgr:getWindow("addcash/main/btn2"))

	self.m_Back = {}
    self.m_Back["charge"] = {}
	self.m_Back["charge"]["back"] = CEGUI.Window.toScrollablePane(winMgr:getWindow("addcash/main/scroll"))
    self.m_Back["history"] =  {}
	self.m_Back["history"]["back"] = winMgr:getWindow("addcash/main");
	self.m_Back["history"]["lastpage"] = CEGUI.Window.toPushButton(winMgr:getWindow("addcash/main/up"));
	self.m_Back["history"]["nextpage"] = CEGUI.Window.toPushButton(winMgr:getWindow("addcash/main/down"));
	self.m_Back["history"]["list"] = {}
	for i = 0,2 do
		self.m_Back["history"]["list"][i+1] = {} 
		self.m_Back["history"]["list"][i+1]["status"] = winMgr:getWindow("addcash/main/info" .. i);
		self.m_Back["history"]["list"][i+1]["billid"] = winMgr:getWindow("addcash/main/num" .. i);
		self.m_Back["history"]["list"][i+1]["time"] = winMgr:getWindow("addcash/main/time" .. i);
		self.m_Back["history"]["list"][i+1]["money"] = winMgr:getWindow("addcash/main/money" .. i);
		self.m_Back["history"]["list"][i+1]["channel"] = winMgr:getWindow("addcash/main/step" .. i);
	end

    -- subscribe event
	for k,v in pairs(self.m_TabBtn) do
		v:subscribeEvent("Clicked", ChargeDialog.HandleTabChangeClick, self) 
	end
	self.m_Back["history"]["lastpage"]:subscribeEvent("Clicked", ChargeDialog.HandleLastPageClick, self) 
	self.m_Back["history"]["nextpage"]:subscribeEvent("Clicked", ChargeDialog.HandleNextPageClick, self) 

    --init settings
	self.m_TabBtn["charge"]:setID(1)
	self.m_TabBtn["history"]:setID(2)

	self.m_TabBtn["charge"]:setVisible(false)
	self.m_TabBtn["history"]:setVisible(true)

	self.m_Back["charge"]["back"]:setVisible(true)
	self.m_Back["history"]["back"]:setVisible(false)

	self.m_Back["history"]["lastpage"]:setEnabled(false)
	self.m_Back["history"]["nextpage"]:setEnabled(false)

    --add for yi huan android
    self.m_btnYHGuanWangCharge = CEGUI.Window.toPushButton(winMgr:getWindow("addcash/go"))
    if self.m_btnYHGuanWangCharge then
        self.m_btnYHGuanWangCharge:subscribeEvent("Clicked", ChargeDialog.HandleClickYHGuanWangCharge, self)
        self.m_btnYHGuanWangCharge:setVisible(false)
    end
    if self.m_btnYHGuanWangCharge and Config.MOBILE_ANDROID == 1 and Config.CUR_3RD_LOGIN_SUFFIX == "efad" then
        self.m_btnYHGuanWangCharge:setVisible(true)
    end

    --add for unicomonly android
    self.m_txtUnicom = winMgr:getWindow("addcash/chinaunicom")
    if self.m_txtUnicom then
        self.m_txtUnicom:setVisible(false)
    end
    if self.m_txtUnicom and Config.MOBILE_ANDROID == 1 and Config.CUR_3RD_LOGIN_SUFFIX == "unsd" then
        self.m_txtUnicom:setVisible(true)
    end
    
	self:ResetAllHistory()
end

function ChargeDialog:HandleClickYHGuanWangCharge(args)
    
    if Config.MOBILE_ANDROID == 1 and Config.CUR_3RD_LOGIN_SUFFIX == "efad" then
        local reqAction = CReqServerId.Create()
        reqAction.flag = s_flagYHReqServiceID
        LuaProtocolManager.getInstance():send(reqAction)
    end

    return true
end

function ChargeDialog:AddGood(id, goodid, price, yuanbao, present, beishu, yuanbao_max)
	self.m_cell = self.m_cell or {}
	print("charge id " .. id  .. " goodid " .. goodid.. " yuanbao " .. yuanbao .. " price " .. price .. "present " .. present .. "beishu" .. beishu)

	self.m_cell[id] = ChargeCell.CreateNewDlg(self.m_Back["charge"]["back"], id)
	self.m_cell[id]:Init(goodid, price, yuanbao, present, beishu, yuanbao_max)
	self.m_cell[id]:GetWindow():setPosition(
				CEGUI.UVector2(CEGUI.UDim(0 ,math.mod(id-1, 4) * self.m_cell[id]:GetWindow():getPixelSize().width + 1),
				CEGUI.UDim(0,math.floor((id-1)/4)*self.m_cell[id]:GetWindow():getPixelSize().height + 1))) 
end

function ChargeDialog:ResetAllProducts()
	if not self.m_cell then return end

	for k,v in pairs(self.m_cell) do
		v:OnClose()
		v = nil
	end
	self.m_cell = nil
end

function ChargeDialog:ResetAllHistory()
	for k,v in pairs(self.m_Back["history"]["list"]) do 
		v["status"]:setText("")
		v["billid"]:setText("")
		v["time"]:setText("")
		v["money"]:setText("")
		v["channel"]:setText("")
	end
end

function ChargeDialog:SetHistoryPage(cur, total)
	LogInfo("history page " .. cur .. " total " .. total)
	self.m_Page = cur
	self.m_TotalPage = total

	self.m_Back["history"]["lastpage"]:setEnabled(true)
	self.m_Back["history"]["nextpage"]:setEnabled(true)

	if self.m_Page <= 1 then
		self.m_Back["history"]["lastpage"]:setEnabled(false)
	end
	if self.m_Page >= self.m_TotalPage then
		self.m_Back["history"]["nextpage"]:setEnabled(false)
	end

end

function ChargeDialog:AddHistory(id, billid, state, createtime, price)
	LogInfo("id " .. id)
	self.m_Back["history"]["list"][id]["status"]:setText(self:GetStatus(state))
	self.m_Back["history"]["list"][id]["billid"]:setText(tostring(billid))
	self.m_Back["history"]["list"][id]["time"]:setText(os.date("%Y-%m-%d %H:%M:%S", createtime / 1000))
	if (Config.TRD_PLATFORM==1 and Config.CUR_3RD_PLATFORM == "efunios") or (Config.MOBILE_ANDROID == 1 and Config.CUR_3RD_LOGIN_SUFFIX == "efad") then
		self.m_Back["history"]["list"][id]["money"]:setText(tostring(price/100) .. MHSD_UTILS.get_resstring(2921))
	else
		self.m_Back["history"]["list"][id]["money"]:setText(tostring(price) .. MHSD_UTILS.get_resstring(2765))
	end
	if Config.TRD_PLATFORM==1 then
		if Config.CUR_3RD_PLATFORM == "91" then
			self.m_Back["history"]["list"][id]["channel"]:setText(MHSD_UTILS.get_resstring(2763))
		end
		if Config.CUR_3RD_PLATFORM == "pp" then
			self.m_Back["history"]["list"][id]["channel"]:setText(MHSD_UTILS.get_resstring(2764))
		end
	end

end

function ChargeDialog:GetStatus(state)
	local statustable = {}
	statustable[0] = MHSD_UTILS.get_resstring(2760)
	statustable[1] = MHSD_UTILS.get_resstring(2762)
	statustable[2] = MHSD_UTILS.get_resstring(2761)
	return statustable[state]
end
------------------- private: -----------------------------------


function ChargeDialog:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, ChargeDialog)

    return self
end


function ChargeDialog:HandleTabChangeClick(args)
	local winargs = CEGUI.toWindowEventArgs(args)
	local btn = winargs.window
	local btnID = btn:getID()
	if btnID == 1 then
		print("1 btn clicked")
		self.m_Back["charge"]["back"]:setVisible(true)
		self.m_Back["history"]["back"]:setVisible(false)

		self.m_TabBtn["charge"]:setVisible(false)
		self.m_TabBtn["history"]:setVisible(true)
	else
		print("2 btn clicked")
		self.m_Back["charge"]["back"]:setVisible(false)
		self.m_Back["history"]["back"]:setVisible(true)

		self.m_TabBtn["charge"]:setVisible(true)
		self.m_TabBtn["history"]:setVisible(false)

		self.m_Page = 1
		self.m_TotalPage = 0
		require "protocoldef.knight.gsp.yuanbao.creqchargehistory"
		local luap = CReqChargeHistory.Create()
		luap.page = 1
		LuaProtocolManager.getInstance():send(luap)

	end
end

function ChargeDialog:HandleLastPageClick(args)
	self.m_Page = self.m_Page - 1

	require "protocoldef.knight.gsp.yuanbao.creqchargehistory"
	local luap = CReqChargeHistory.Create()
	luap.page = self.m_Page
	LuaProtocolManager.getInstance():send(luap)
end

function ChargeDialog:HandleNextPageClick(args)
	self.m_Page = self.m_Page + 1
		
	require "protocoldef.knight.gsp.yuanbao.creqchargehistory"
	local luap = CReqChargeHistory.Create()
	luap.page = self.m_Page
	LuaProtocolManager.getInstance():send(luap)
end

return ChargeDialog
