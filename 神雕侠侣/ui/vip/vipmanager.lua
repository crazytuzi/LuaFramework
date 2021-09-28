require "protocoldef.knight.gsp.battle.cvipbuy"
require "protocoldef.knight.gsp.battle.cvipdrop"
require "utils.stringbuilder"

VipManager = {}
VipManager.__index = VipManager

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function VipManager.getInstance()
	LogInfo("enter get vipmanager instance")
    if not _instance then
        _instance = VipManager:new()
    end
    return _instance
end

function VipManager.getInstanceNotCreate()
    return _instance
end

function VipManager.Destroy()
	if _instance then 
		LogInfo("destroy vipmanager")
		_instance = nil
	end
end

function VipManager.GetCurVIPLevel()
    if _instance and _instance.m_iVipLevel then
        return _instance.m_iVipLevel
    else
        return 0
    end
end

------------------- private: -----------------------------------

function VipManager:new()
    local self = {}
	setmetatable(self, VipManager)
	self:Init()

    return self
end

function VipManager:Init()
	LogInfo("vipmanager init")
	self.m_iVipLevel = 0
	self.m_iRemainTime = 0
	self.m_iVipcdtime = {}
	self.m_bCanTakeAward = {}	
end

function VipManager:SetInfo(level, vipremaintime, takeawardflag, vipcdtime)
	LogInfo("vipmanager set info")
	GetDataManager():HandleVipBuy(self.m_iVipLevel, level)
	self.m_iVipLevel = level
	self.m_iRemainTime = vipremaintime

	self.m_iVipcdtime["vip1"] = vipcdtime["vip1"]
	self.m_iVipcdtime["vip2"] = vipcdtime["vip2"]
	self.m_iVipcdtime["vip3"] = vipcdtime["vip3"]

	self.m_bCanTakeAward["vip1"] = takeawardflag["vip1"]
	self.m_bCanTakeAward["vip2"] = takeawardflag["vip2"]
	self.m_bCanTakeAward["vip3"] = takeawardflag["vip3"]

	if CPetAndUserIcon:GetSingleton() then
		CPetAndUserIcon:GetSingleton():SetVipLevel(level)
	end 

	local VipDialog = nil
	if Config.MOBILE_ANDROID == 1 and Config.CUR_3RD_LOGIN_SUFFIX == "ydjd" then
		VipDialog = require "ui.vip.vipdialog_ydjd"
	else 
		VipDialog = require "ui.vip.vipdialog_default"
	end
	if VipDialog.getInstanceNotCreate() then 
		VipDialog.getInstanceNotCreate():Init()
	end
	LogInfo("vipmanager setinfo end")
end

function VipManager:BuyFubenTime(serverid, yuanbao)
	LogInfo("vipmanager buy")
	self.m_iBuyServerID = serverid
	local strbuilder = StringBuilder:new()	
	strbuilder:SetNum("parameter1", yuanbao)
	GetMessageManager():AddConfirmBox(eConfirmNormal,strbuilder:GetString(MHSD_UTILS.get_msgtipstring(145057)),VipManager.HandleBuyClicked,self,CMessageManager.HandleDefaultCancelEvent,CMessageManager)
	strbuilder:delete()
end

function VipManager:HandleBuyClicked()
	LogInfo("vipmanager handle buy clicked")
	local vipBuy = CVipBuy.Create()
	vipBuy.serverid = self.m_iBuyServerID
	LuaProtocolManager.getInstance():send(vipBuy)
	GetMessageManager():CloseConfirmBox(eConfirmNormal, false)
end

function VipManager:run(elapse)
	if self.m_iRemainTime and self.m_iRemainTime > 0 then
		self.m_iRemainTime = self.m_iRemainTime - elapse
	end
end

function VipManager:AskVipProduct(yuanbao, productid)
	LogInfo("vipmanager AskVipDrop")
	self.m_iProductID = productid
	if yuanbao == 0 then
		if Config.TRD_PLATFORM == 1 then
			if (Config.CUR_3RD_PLATFORM == "app") then 
				SDXL.ChannelManager:StartBuyYuanbao(0, "", productid, 0, 0, 0)
			elseif Config.CUR_3RD_PLATFORM == "feiliu" then
				SDXL.ChannelManager:StartBuyYuanbao(0, "com.wm.sdxl_" .. productid, 0, 0, 0, 0)
			elseif Config.MOBILE_ANDROID == 1 and Config.CUR_3RD_LOGIN_SUFFIX == "txqq" then
				local LuaAndroid = require "android"
				LuaAndroid.startBuy(productid, 1)
            elseif Config.CUR_3RD_LOGIN_SUFFIX == "unpy" then
                local luaj = require "luaj"
                local ret , getLocalMacAddress ,getLocalIpAddress,getImei,getUID
                ret, getLocalMacAddress   = luaj.callStaticMethod("com.wanmei.mini.condor.wo.WoPlatform", "getLocalMacAddress", nil, "()Ljava/lang/String;")
                ret, getLocalIpAddress   = luaj.callStaticMethod("com.wanmei.mini.condor.wo.WoPlatform", "getLocalIpAddress", nil, "()Ljava/lang/String;")
                ret, getImei   = luaj.callStaticMethod("com.wanmei.mini.condor.wo.WoPlatform", "getImei", nil, "()Ljava/lang/String;")
                ret, getVersioncode   = luaj.callStaticMethod("com.wanmei.mini.condor.wo.WoPlatform", "getVersioncode", nil, "()Ljava/lang/String;")
                ret, getUID   = luaj.callStaticMethod("com.wanmei.mini.condor.wo.WoPlatform", "getUID", nil, "()Ljava/lang/String;")
                local luap = CConfirmCharge.Create()
                luap.goodid = productid
                luap.goodnum = 1
                luap.extra = "unpy" .. "#" .. getUID .. "#" .. getLocalMacAddress .. "#" .. getLocalIpAddress .. "#" .. getImei .. "#" .. getVersioncode
                LuaProtocolManager.getInstance():send(luap)
			else
				local luap = CConfirmCharge.Create()

				luap.goodid = productid 
				luap.goodnum = 1
				LuaProtocolManager.getInstance():send(luap)
			end
		end
	else
		local strbuilder = StringBuilder:new()	
		strbuilder:SetNum("parameter1", yuanbao)
		GetMessageManager():AddConfirmBox(eConfirmNormal,strbuilder:GetString(MHSD_UTILS.get_msgtipstring(145059)),VipManager.HandleBuyVip,self,CMessageManager.HandleDefaultCancelEvent,CMessageManager)
		strbuilder:delete()
	end
end

function VipManager:HandleBuyVip()
	LogInfo("vipmanager handle vipdrop")
	if Config.TRD_PLATFORM == 1 then
		if (Config.CUR_3RD_PLATFORM == "app") then 
			SDXL.ChannelManager:StartBuyYuanbao(0, "", self.m_iProductID, 0, 0, 0)
		elseif Config.CUR_3RD_PLATFORM == "feiliu" then
			SDXL.ChannelManager:StartBuyYuanbao(0, "com.wm.sdxl_" .. self.m_iProductID, 0, 0, 0, 0)
		elseif Config.MOBILE_ANDROID == 1 and Config.CUR_3RD_LOGIN_SUFFIX == "txqq" then
			local LuaAndroid = require "android"
			LuaAndroid.startBuy(self.m_iProductID, 1)
         elseif Config.CUR_3RD_LOGIN_SUFFIX == "unpy" then
            local luaj = require "luaj"
            local ret , getLocalMacAddress ,getLocalIpAddress,getImei,getUID
            ret, getLocalMacAddress   = luaj.callStaticMethod("com.wanmei.mini.condor.wo.WoPlatform", "getLocalMacAddress", nil, "()Ljava/lang/String;")
            ret, getLocalIpAddress   = luaj.callStaticMethod("com.wanmei.mini.condor.wo.WoPlatform", "getLocalIpAddress", nil, "()Ljava/lang/String;")
            ret, getImei   = luaj.callStaticMethod("com.wanmei.mini.condor.wo.WoPlatform", "getImei", nil, "()Ljava/lang/String;")
            ret, getVersioncode   = luaj.callStaticMethod("com.wanmei.mini.condor.wo.WoPlatform", "getVersioncode", nil, "()Ljava/lang/String;")
            ret, getUID   = luaj.callStaticMethod("com.wanmei.mini.condor.wo.WoPlatform", "getUID", nil, "()Ljava/lang/String;")
            local luap = CConfirmCharge.Create()
			luap.goodid = self.m_iProductID
			luap.goodnum = 1
            luap.extra = "unpy" .. "#" .. getUID .. "#" .. getLocalMacAddress .. "#" .. getLocalIpAddress .. "#" .. getImei .. "#" .. getVersioncode
			LuaProtocolManager.getInstance():send(luap)
		else
			local luap = CConfirmCharge.Create()

			luap.goodid = self.m_iProductID
			luap.goodnum = 1
			LuaProtocolManager.getInstance():send(luap)
		end
	end

	GetMessageManager():CloseConfirmBox(eConfirmNormal, false)
end

function VipManager:AskVipDrop(yuanbao, viplevel)
	LogInfo("vipmanager ask vip drop")
	self.m_iDropVip = viplevel
	local strbuilder = StringBuilder:new()	
	strbuilder:SetNum("parameter1", yuanbao)
	GetMessageManager():AddConfirmBox(eConfirmNormal,strbuilder:GetString(MHSD_UTILS.get_msgtipstring(145059)),VipManager.HandleVipDrop,self,CMessageManager.HandleDefaultCancelEvent,CMessageManager)
	strbuilder:delete()
end

function VipManager:HandleVipDrop()
	LogInfo("vipmanager handle vip drop")
	local vipDrop = CVipDrop.Create()
	vipDrop.viplevel = self.m_iDropVip
	LuaProtocolManager.getInstance():send(vipDrop)		
	GetMessageManager():CloseConfirmBox(eConfirmNormal, false)
end

return VipManager
