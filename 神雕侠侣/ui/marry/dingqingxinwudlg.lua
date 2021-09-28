require "ui.dialog"
require "utils.mhsdutils"
require "utils.stringbuilder"

DingQingXinWuDialog = {}
setmetatable(DingQingXinWuDialog, Dialog)
DingQingXinWuDialog.__index = DingQingXinWuDialog

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function DingQingXinWuDialog.getInstance()
	LogInfo("enter get DingQingXinWuDialog instance")
    if not _instance then
        _instance = DingQingXinWuDialog:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function DingQingXinWuDialog.getInstanceAndShow()
	LogInfo("enter DingQingXinWuDialog instance show")
    if not _instance then
        _instance = DingQingXinWuDialog:new()
        _instance:OnCreate()
	else
		LogInfo("set DingQingXinWuDialog visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function DingQingXinWuDialog.getInstanceNotCreate()
    return _instance
end

function DingQingXinWuDialog.DestroyDialog()
	if _instance then 
		LogInfo("destroy DingQingXinWuDialog")
		_instance:OnClose()
		_instance = nil
	end
end

----/////////////////////////////////////////------

function DingQingXinWuDialog.GetLayoutFileName()
    return "lovething.layout"
end

function DingQingXinWuDialog:OnCreate()
	LogInfo("DingQingXinWuDialog oncreate begin")
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- group buttons
    self.m_pGroupBtn1 = CEGUI.Window.toGroupButton(winMgr:getWindow("lovething/main2/card"))
    self.m_pGroupBtn1:setID(1)
	self.m_pGroupBtn2 = CEGUI.Window.toGroupButton(winMgr:getWindow("lovething/main2/card1"))
	self.m_pGroupBtn2:setID(2)
	self.m_pGroupBtn3 = CEGUI.Window.toGroupButton(winMgr:getWindow("lovething/main2/card2"))
	self.m_pGroupBtn3:setID(3)

	--main descripe
	self.m_pDescribe = winMgr:getWindow("lovething/main3/txt")
	--sub title
	self.m_pSubTittle = winMgr:getWindow("lovething/main3/txt2")
	--price
	self.m_pPrice = winMgr:getWindow("lovething/main3/txt3")
	--buy button
	self.m_pBuyBtn = CEGUI.Window.toPushButton(winMgr:getWindow("lovething/main3/btn"))
	self.m_pBuyBtn:subscribeEvent("Clicked", DingQingXinWuDialog.HandleBuyClicked, self)

	self.m_pCloseBtn = CEGUI.Window.toPushButton(winMgr:getWindow("lovething/close"))
	self.m_pCloseBtn:subscribeEvent("Clicked", DingQingXinWuDialog.HandleCloseClicked, self)

	self.m_pGroupBtn1:subscribeEvent("SelectStateChanged", DingQingXinWuDialog.HandleSelectedChanged, self);
	self.m_pGroupBtn2:subscribeEvent("SelectStateChanged", DingQingXinWuDialog.HandleSelectedChanged, self);
	self.m_pGroupBtn3:subscribeEvent("SelectStateChanged", DingQingXinWuDialog.HandleSelectedChanged, self);
	self.m_pGroupBtn1:setSelected(true)

	self.m_itemIndex = 1
	
  --******* for ydjd
  if Config.MOBILE_ANDROID == 1 and Config.CUR_3RD_LOGIN_SUFFIX == "ydjd" then
    self.m_pGroupBtn1:setVisible(false)
    self.m_pGroupBtn2:setVisible(false)
    self.m_pGroupBtn3:setSelected(true)
    self.m_pGroupBtn3:setPosition(self.m_pGroupBtn1:getPosition())
    self.m_itemIndex = 3
  end
  --******* for ydjd

	LogInfo("DingQingXinWuDialog oncreate end")
end

------------------- private: -----------------------------------

function DingQingXinWuDialog:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, DingQingXinWuDialog)
    return self
end

function DingQingXinWuDialog:HandleSelectedChanged(args)
	LogInfo("DingQingXinWuDialog HandleSelectedChanged.")

	local index = CEGUI.toWindowEventArgs(args).window:getID()
	self.m_itemIndex = index

	if index == 1 then
		self.m_pDescribe:setText(MHSD_UTILS.get_resstring(3071))
		self.m_pSubTittle:setText(MHSD_UTILS.get_resstring(3074))
		self.m_pPrice:setText(MHSD_UTILS.get_resstring(3077))
	elseif index == 2 then
		self.m_pDescribe:setText(MHSD_UTILS.get_resstring(3070))
		self.m_pSubTittle:setText(MHSD_UTILS.get_resstring(3073))
		self.m_pPrice:setText(MHSD_UTILS.get_resstring(3076))
	elseif index == 3 then
		self.m_pDescribe:setText(MHSD_UTILS.get_resstring(3069))
		self.m_pSubTittle:setText(MHSD_UTILS.get_resstring(3072))
		self.m_pPrice:setText(MHSD_UTILS.get_resstring(3075))
	end
end

function DingQingXinWuDialog:HandleCloseClicked(args)
	self.DestroyDialog()
end

function DingQingXinWuDialog:HandleBuyClicked(args)
	LogErr("DingQingXinWuDialog HandleBuyClicked clicked.")

    if Config.MOBILE_ANDROID == 1 and Config.CUR_3RD_LOGIN_SUFFIX == "lngz" then
        require "luaj"
        local param = {}
        param[1] = tostring(GetDataManager():GetMainCharacterID())
        luaj.callStaticMethod("com.wanmei.mini.condor.longzhong.PlatformLongZhong", "purchase2", param, "(Ljava/lang/String;)V")
    	return
    elseif Config.MOBILE_ANDROID == 1 and Config.CUR_3RD_LOGIN_SUFFIX == "efad" then
        require "luaj"
        local param = {}
        param[1] = tostring(GetDataManager():GetMainCharacterLevel())
        param[2] = tostring(GetDataManager():GetMainCharacterName())
        luaj.callStaticMethod("com.wanmei.mini.condor.efun.PlatformEFun", "purchase2", param, nil)
        return
    elseif Config.MOBILE_ANDROID == 1 and Config.CUR_3RD_LOGIN_SUFFIX == "twap" then
	    local LuaAndroid = require "android"
	    LuaAndroid.TwApp01buy()
        return
    elseif Config.MOBILE_ANDROID == 1 and Config.CUR_3RD_LOGIN_SUFFIX == "tw36" then
	    local LuaAndroid = require "android"
	    LuaAndroid.Tw360buy()
        return
    end

	local ckind = 8
	
  if self.m_itemIndex == 1 then
    ckind = 8
  end
  if self.m_itemIndex == 2 then
    ckind = 7
  end
  if self.m_itemIndex == 3 then
    ckind = 6
  end
  
  --for app
  if Config.CUR_3RD_PLATFORM == "app" then
	if ckind == 6 then
		SDXL.ChannelManager:StartBuyYuanbao(0, "", 197, 0, 0, 0)
	end
	if ckind == 7 then
		SDXL.ChannelManager:StartBuyYuanbao(0, "", 198, 0, 0, 0)
	end
	if ckind == 8 then
		SDXL.ChannelManager:StartBuyYuanbao(0, "", 199, 0, 0, 0)
	end
	return
  end
  
  --for feiliu
  if Config.CUR_3RD_PLATFORM == "feiliu" then
	if ckind == 6 then
		SDXL.ChannelManager:StartBuyYuanbao(0, "com.wm.sdxl_" .. 240, 0, 0, 0, 0)
	end
	if ckind == 7 then
		SDXL.ChannelManager:StartBuyYuanbao(0, "com.wm.sdxl_" .. 241, 0, 0, 0, 0)
	end
	if ckind == 8 then
		SDXL.ChannelManager:StartBuyYuanbao(0, "com.wm.sdxl_" .. 242, 0, 0, 0, 0)
	end
	return
  end
	
  --for txqq
  if Config.MOBILE_ANDROID == 1 and Config.CUR_3RD_LOGIN_SUFFIX == "txqq" then
	local LuaAndroid = require "android"
	if ckind == 6 then
		LuaAndroid.startBuy(197, 1)
	end
	if ckind == 7 then
		LuaAndroid.startBuy(198, 1)
	end
	if ckind == 8 then
		LuaAndroid.startBuy(199, 1)
	end
	return
  end
  
  --for unpy
    if  Config.CUR_3RD_LOGIN_SUFFIX == "unpy" then
		local goodid = -1
		if ckind == 6 then
			goodid = 243
		end
		if ckind == 7 then
			goodid = 244
		end
		if ckind == 8 then
			goodid = 245
		end
		
		local luaj = require "luaj"
		local ret , getLocalMacAddress ,getLocalIpAddress,getImei,getUID
		ret, getLocalMacAddress   = luaj.callStaticMethod("com.wanmei.mini.condor.wo.WoPlatform", "getLocalMacAddress", nil, "()Ljava/lang/String;")
		ret, getLocalIpAddress   = luaj.callStaticMethod("com.wanmei.mini.condor.wo.WoPlatform", "getLocalIpAddress", nil, "()Ljava/lang/String;")
		ret, getImei   = luaj.callStaticMethod("com.wanmei.mini.condor.wo.WoPlatform", "getImei", nil, "()Ljava/lang/String;")
		ret, getVersioncode   = luaj.callStaticMethod("com.wanmei.mini.condor.wo.WoPlatform", "getVersioncode", nil, "()Ljava/lang/String;")
		ret, getUID   = luaj.callStaticMethod("com.wanmei.mini.condor.wo.WoPlatform", "getUID", nil, "()Ljava/lang/String;")
		local luap = CConfirmCharge.Create()
		luap.goodid = goodid
		luap.goodnum = 1
		luap.extra = "unpy" .. "#" .. getUID .. "#" .. getLocalMacAddress .. "#" .. getLocalIpAddress .. "#" .. getImei .. "#" .. getVersioncode
		LuaProtocolManager.getInstance():send(luap)
		return
  end
 
	local suffix =  Config.CUR_3RD_LOGIN_SUFFIX
	if suffix == "lahu" then
	 suffix = "apps"
	end
	
	--only kind for 6
  local ids = BeanConfigManager.getInstance():GetTableByName("knight.gsp.yuanbao.caddcashlua"):getAllID()
  for k,v in pairs(ids) do
    local item = BeanConfigManager.getInstance():GetTableByName("knight.gsp.yuanbao.caddcashlua"):getRecorder(v)
    if item.kind == ckind and item.roofid == suffix then
      require "protocoldef.knight.gsp.yuanbao.cconfirmcharge"
      local luap = CConfirmCharge.Create()  
      luap.goodid = item.id
      luap.goodnum = 1
      LuaProtocolManager.getInstance():send(luap)
      return
    end
  end
  
  --if not find，use 91 default
	suffix = "wl91"
    for k,v in pairs(ids) do
		local item = BeanConfigManager.getInstance():GetTableByName("knight.gsp.yuanbao.caddcashlua"):getRecorder(v)
		if item.kind == ckind and item.roofid == suffix then
		  require "protocoldef.knight.gsp.yuanbao.cconfirmcharge"
		  local luap = CConfirmCharge.Create()  
		  luap.goodid = item.id
		  luap.goodnum = 1
		  LuaProtocolManager.getInstance():send(luap)
		  return
		end
	end
end

return DingQingXinWuDialog
