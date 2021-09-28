require "ui.dialog"
require "utils.mhsdutils"
require "utils.stringbuilder"

FirstChargeTipDialog = {}
setmetatable(FirstChargeTipDialog, Dialog)
FirstChargeTipDialog.__index = FirstChargeTipDialog

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function FirstChargeTipDialog.getInstance()
	LogInfo("FirstChargeTipDialog getinstance")
    if not _instance then
        _instance = FirstChargeTipDialog:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function FirstChargeTipDialog.getInstanceAndShow()
	print("enter instance show")
    if not _instance then
        _instance = FirstChargeTipDialog:new()
        _instance:OnCreate()
	else
		print("set visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function FirstChargeTipDialog.getInstanceNotCreate()
    return _instance
end

function FirstChargeTipDialog.DestroyDialog()
	if _instance then 
		_instance:OnClose()		
		_instance = nil
	end
end

function FirstChargeTipDialog.ToggleOpenClose()
	if not _instance then 
		_instance = FirstChargeTipDialog:new() 
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

function FirstChargeTipDialog.GetLayoutFileName()
    return "addcashcheck.layout"
end

function FirstChargeTipDialog:OnCreate()
	LogInfo("enter FirstChargeTipDialog oncreate")
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
    self.m_ContinueBtn = CEGUI.Window.toPushButton(winMgr:getWindow("addcashcheck/OK"))
    self.m_Charge1000Btn = CEGUI.Window.toPushButton(winMgr:getWindow("addcashcheck/Canle"))
    self.m_CloseBtn = CEGUI.Window.toPushButton(winMgr:getWindow("addcashcheck/closed"))

    -- subscribe event
	self.m_ContinueBtn:subscribeEvent("Clicked", FirstChargeTipDialog.HandleContinueBtnClick, self) 
	self.m_Charge1000Btn:subscribeEvent("Clicked", FirstChargeTipDialog.HandleCharge1000BtnClick, self) 
	self.m_CloseBtn:subscribeEvent("Clicked", FirstChargeTipDialog.HandleCloseBtnClick, self) 
    
    if ( Config.TRD_PLATFORM == 1 and Config.MOBILE_ANDROID == 0 and Config.CUR_3RD_PLATFORM == "kris" ) or Config.isKoreanAndroid() then
		self.cancel = CEGUI.Window.toPushButton(winMgr:getWindow("addcashcheck/cancle"))
        if self.cancel then
            self.cancel:subscribeEvent("Clicked", FirstChargeTipDialog.HandleCloseBtnClick, self)
        end
	end
end

function FirstChargeTipDialog:SetGoodID(goodid, yuanbaomax)
	self.goodid = goodid
	self.yuanbaomax = yuanbaomax
	local strbuilder = StringBuilder:new()	
	local tt = BeanConfigManager.getInstance():GetTableByName("knight.gsp.yuanbao.caddcashlua") 
	local record = tt:getRecorder(yuanbaomax)
    if (Config.TRD_PLATFORM==1 and Config.CUR_3RD_PLATFORM == "efunios") or (Config.MOBILE_ANDROID == 1 and Config.CUR_3RD_LOGIN_SUFFIX == "efad") then
		local strNum = string.format("%.2f", record.sellpricenum / 100.0)
		strbuilder:Set("parameter1", strNum) 
    elseif Config.TRD_PLATFORM==1 and Config.CUR_3RD_PLATFORM == "this" then
		local strNum = string.format("%.2f", record.sellpricenum / 100.0)
		strbuilder:Set("parameter1", strNum)
	else
		strbuilder:SetNum("parameter1", record.sellpricenum) 
	end
    	if (Config.TRD_PLATFORM==1 and Config.CUR_3RD_PLATFORM == "efunios") or (Config.MOBILE_ANDROID == 1 and Config.CUR_3RD_LOGIN_SUFFIX == "efad") then
		self.m_Charge1000Btn:setText(strbuilder:GetString(MHSD_UTILS.get_resstring(3037)))
	else
		self.m_Charge1000Btn:setText(strbuilder:GetString(MHSD_UTILS.get_resstring(2991)))
	end
	strbuilder:delete()
end

------------------- private: -----------------------------------


function FirstChargeTipDialog:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, FirstChargeTipDialog)

    return self
end

function FirstChargeTipDialog:HandleContinueBtnClick(args)
	if Config.TRD_PLATFORM == 1 then
		if (Config.CUR_3RD_PLATFORM=="app") then 
			SDXL.ChannelManager:StartBuyYuanbao(0, "", self.goodid, 0, 0, 0)
		elseif Config.CUR_3RD_PLATFORM == "feiliu" then
			SDXL.ChannelManager:StartBuyYuanbao(0, "com.wm.sdxl_" .. self.goodid, 0, 0, 0, 0)
		elseif Config.MOBILE_ANDROID == 1 and Config.CUR_3RD_LOGIN_SUFFIX == "txqq" then
			local LuaAndroid = require "android"
			LuaAndroid.startBuy(self.goodid, 1)
         elseif Config.CUR_3RD_LOGIN_SUFFIX == "unpy" then
			local luaj = require "luaj"
            local ret , getLocalMacAddress ,getLocalIpAddress,getImei,getUID
            ret, getLocalMacAddress   = luaj.callStaticMethod("com.wanmei.mini.condor.wo.WoPlatform", "getLocalMacAddress", nil, "()Ljava/lang/String;")
            ret, getLocalIpAddress   = luaj.callStaticMethod("com.wanmei.mini.condor.wo.WoPlatform", "getLocalIpAddress", nil, "()Ljava/lang/String;")
            ret, getImei   = luaj.callStaticMethod("com.wanmei.mini.condor.wo.WoPlatform", "getImei", nil, "()Ljava/lang/String;")
            ret, getVersioncode   = luaj.callStaticMethod("com.wanmei.mini.condor.wo.WoPlatform", "getVersioncode", nil, "()Ljava/lang/String;")
            ret, getUID   = luaj.callStaticMethod("com.wanmei.mini.condor.wo.WoPlatform", "getUID", nil, "()Ljava/lang/String;")
            local luap = CConfirmCharge.Create()
			luap.goodid = self.goodid
			luap.goodnum = 1
            luap.extra = "unpy" .. "#" .. getUID .. "#" .. getLocalMacAddress .. "#" .. getLocalIpAddress .. "#" .. getImei .. "#" .. getVersioncode
			LuaProtocolManager.getInstance():send(luap)
		else
			require "protocoldef.knight.gsp.yuanbao.cconfirmcharge"
			local luap = CConfirmCharge.Create()

			luap.goodid = self.goodid
			luap.goodnum = 1
			LuaProtocolManager.getInstance():send(luap)
		end
	end

	FirstChargeTipDialog.DestroyDialog()
end

function FirstChargeTipDialog:HandleCharge1000BtnClick(args)
	if Config.TRD_PLATFORM == 1 then
		if (Config.CUR_3RD_PLATFORM=="app") then
			SDXL.ChannelManager:StartBuyYuanbao(0, "", self.yuanbaomax, 0, 0, 0)
		elseif Config.CUR_3RD_PLATFORM == "feiliu" then
			SDXL.ChannelManager:StartBuyYuanbao(0, "com.wm.sdxl_" .. self.yuanbaomax, 0, 0, 0, 0)
		elseif Config.MOBILE_ANDROID == 1 and Config.CUR_3RD_LOGIN_SUFFIX == "txqq" then
			local LuaAndroid = require "android"
			LuaAndroid.startBuy(self.yuanbaomax, 1)
         elseif Config.CUR_3RD_LOGIN_SUFFIX == "unpy" then
            local ret , getLocalMacAddress ,getLocalIpAddress,getImei,getUID
            ret, getLocalMacAddress   = luaj.callStaticMethod("com.wanmei.mini.condor.wo.WoPlatform", "getLocalMacAddress", nil, "()Ljava/lang/String;")
            ret, getLocalIpAddress   = luaj.callStaticMethod("com.wanmei.mini.condor.wo.WoPlatform", "getLocalIpAddress", nil, "()Ljava/lang/String;")
            ret, getImei   = luaj.callStaticMethod("com.wanmei.mini.condor.wo.WoPlatform", "getImei", nil, "()Ljava/lang/String;")
            ret, getVersioncode   = luaj.callStaticMethod("com.wanmei.mini.condor.wo.WoPlatform", "getVersioncode", nil, "()Ljava/lang/String;")
            ret, getUID   = luaj.callStaticMethod("com.wanmei.mini.condor.wo.WoPlatform", "getUID", nil, "()Ljava/lang/String;")
            local luap = CConfirmCharge.Create()
			luap.goodid = self.yuanbaomax
			luap.goodnum = 1
            luap.extra = "unpy" .. "#" .. getUID .. "#" .. getLocalMacAddress .. "#" .. getLocalIpAddress .. "#" .. getImei .. "#" .. getVersioncode
			LuaProtocolManager.getInstance():send(luap)

		else
			require "protocoldef.knight.gsp.yuanbao.cconfirmcharge"
			local luap = CConfirmCharge.Create()
	
			luap.goodid = self.yuanbaomax 
			luap.goodnum = 1
			LuaProtocolManager.getInstance():send(luap)
		end
	end
	FirstChargeTipDialog.DestroyDialog()
end

function FirstChargeTipDialog:HandleCloseBtnClick(args)
	FirstChargeTipDialog.DestroyDialog()
end

return FirstChargeTipDialog
