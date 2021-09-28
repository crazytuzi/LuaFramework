require "ui.dialog"
require "utils.mhsdutils"
require "utils.stringbuilder"
require "protocoldef.knight.gsp.battle.cbuyvipproduct"

VipDialogDefault = {
	m_pVipLevel = 0,
    m_vipcdtime = {},
    m_vipaward = {},
    m_iSelectID = 1,
    m_vip1Price = 0,
    m_vip2Price = 0,
    m_vip3Price = 0
}
setmetatable(VipDialogDefault, Dialog)
VipDialogDefault.__index = VipDialogDefault

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function VipDialogDefault.getInstance()
	LogInfo("enter get VipDialogDefault instance")
    if not _instance then
        _instance = VipDialogDefault:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function VipDialogDefault.getInstanceAndShow()
	LogInfo("enter VipDialogDefault instance show")
    if not _instance then
        _instance = VipDialogDefault:new()
        _instance:OnCreate()
	else
		LogInfo("set VipDialogDefault visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function VipDialogDefault.getInstanceNotCreate()
    return _instance
end

function VipDialogDefault.DestroyDialog()
	print("ssssssss" , _instance )
	if _instance then 
		LogInfo("destroy VipDialogDefault")
		_instance:OnClose()
		_instance = nil
	end
end

function VipDialogDefault.ToggleOpenClose()
	if not _instance then 
		_instance = VipDialogDefault:new() 
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

function VipDialogDefault.GetLayoutFileName()
    return "vipnew.layout"
end

function VipDialogDefault:OnCreate()
	LogInfo("VipDialogDefault oncreate begin")
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
    self.m_pVipBtn = {}
    self.m_pVipBtn[1] = CEGUI.Window.toPushButton(winMgr:getWindow("vipnew/back/btn/imgbtn0"))
    self.m_pVipBtn[1]:setID(1)
	self.m_pVipBtn[2] = CEGUI.Window.toPushButton(winMgr:getWindow("vipnew/back/btn/imgbtn1"))
    self.m_pVipBtn[2]:setID(2)
    self.m_pVipBtn[3] = CEGUI.Window.toPushButton(winMgr:getWindow("vipnew/back/btn/imgbtn2"))
    self.m_pVipBtn[3]:setID(3)

	self.m_pTitle = winMgr:getWindow("vipnew/back/donw/left/txt")
	self.m_pDescribe = CEGUI.Window.toRichEditbox(winMgr:getWindow("vipnew/back/donw/left/backtxt"))
	self.m_pRewardYB = winMgr:getWindow("vipnew/back/donw/text1")
	self.m_pDailyYB = winMgr:getWindow("vipnew/back/donw/text4/txt")
	self.m_pItem1 = winMgr:getWindow("vipnew/back/donw/item")
	self.m_pItem2 = winMgr:getWindow("vipnew/back/donw/item1")
	self.m_pItem1 = CEGUI.Window.toItemCell(winMgr:getWindow("vipnew/back/donw/item"))
	self.m_pItem2 = CEGUI.Window.toItemCell(winMgr:getWindow("vipnew/back/donw/item1"))
	self.m_pImg1 = winMgr:getWindow("vipnew/back/donw/item/image")
	self.m_pImg2 = winMgr:getWindow("vipnew/back/donw/item1/image")

	self.m_pTimeLeft = winMgr:getWindow("vipnew/back/donw/itemtxt0")

	self.m_pBuyBtn = CEGUI.Window.toPushButton(winMgr:getWindow("vipnew/back/donw/imgbtn0"))
	self.m_pGiftBtn = CEGUI.Window.toPushButton(winMgr:getWindow("vipnew/back/donw/imgbtn1"))

	self.m_pLevel = winMgr:getWindow("vipnew/back/donw/mytxt1")
	self.m_pTime = winMgr:getWindow("vipnew/back/donw/mytxt11")
    -- subscribe event
	
	for i=1, 3 do 
		self.m_pVipBtn[i]:subscribeEvent("Clicked", VipDialogDefault.HandleVipSelectChange, self)
	end

	self.m_pBuyBtn:subscribeEvent("Clicked", VipDialogDefault.HandleBuyClicked, self)
	self.m_pGiftBtn:subscribeEvent("Clicked",VipDialogDefault.HandleRewardBtnClicked,self)
	
	self.m_pImg1:setVisible(false)
	self.m_pImg2:setVisible(false)

	local rec = BeanConfigManager.getInstance():GetTableByName("knight.gsp.yuanbao.caddcashlua"):getAllID()
	-- print("rec len: ", #rec)
	local haveGet = false

	for k,v in pairs(rec) do
		local rd = BeanConfigManager.getInstance():GetTableByName("knight.gsp.yuanbao.caddcashlua"):getRecorder(v)
		if Config.CUR_3RD_LOGIN_SUFFIX == rd.roofid then
			haveGet = true
			if rd.kind == 2 then
				self.m_vip1Price = rd.sellpricenum
			elseif rd.kind == 3 then
				self.m_vip2Price = rd.sellpricenum
			elseif rd.kind == 4 then
				self.m_vip3Price = rd.sellpricenum
			end
		end
	end

	if not haveGet then
		for k,v in pairs(rec) do
			local rd = BeanConfigManager.getInstance():GetTableByName("knight.gsp.yuanbao.caddcashlua"):getRecorder(v)
			if rd.roofid == "wl91" then
				haveGet = true
				if rd.kind == 2 then
					self.m_vip1Price = rd.sellpricenum
				elseif rd.kind == 3 then
					self.m_vip2Price = rd.sellpricenum
				elseif rd.kind == 4 then
					self.m_vip3Price = rd.sellpricenum
				end
			end
		end
	end

	self.m_pVip1Num = {}
	for i=1, 2, 1 do
		self.m_pVip1Num[i] = winMgr:getWindow("vipnew/back/commonback/vip1/num" .. tostring(i))
	end 
	self.m_pVip2Num = {}
	for i=1, 3, 1 do
		self.m_pVip2Num[i] = winMgr:getWindow("vipnew/back/commonback/vip2/num" .. tostring(i))
	end 
	self.m_pVip3Num = {}
	for i=1, 3, 1 do
		self.m_pVip3Num[i] = winMgr:getWindow("vipnew/back/commonback/vip3/num" .. tostring(i))
	end

	for i=1, 2, 1 do
		local txt = math.floor((self.m_vip1Price%10^i)/(10^(i-1)))
		self.m_pVip1Num[3-i]:setProperty("Image", "set:MainControl10 image:red" .. tostring(txt))
	end 
	if Config.CUR_3RD_LOGIN_SUFFIX == "apps" or Config.CUR_3RD_LOGIN_SUFFIX == "feil" then
		for i=1, 2, 1 do
			local txt = math.floor((self.m_vip2Price%10^i)/(10^(i-1)))
			self.m_pVip2Num[3-i]:setProperty("Image", "set:MainControl10 image:red" .. tostring(txt))
		end 
		self.m_pVip2Num[3]:setVisible(false)
	else
		for i=1, 3, 1 do
			local txt = math.floor((self.m_vip2Price%10^i)/(10^(i-1)))
			self.m_pVip2Num[4-i]:setProperty("Image", "set:MainControl10 image:red" .. tostring(txt))
		end 
	end
	for i=1, 3, 1 do
		local txt = math.floor((self.m_vip3Price%10^i)/(10^(i-1)))
		self.m_pVip3Num[4-i]:setProperty("Image", "set:MainControl10 image:red" .. tostring(txt))
	end 

	self.m_pDescribe:setTopAfterLoadFont(true)
	self:Init()

	LogInfo("VipDialogDefault oncreate end")

end

------------------- private: -----------------------------------

function VipDialogDefault:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, VipDialogDefault)
    return self
end

function VipDialogDefault:Init(args)
	-- self.m_pVipLevel:setText(MHSD_UTILS.get_resstring(2808))
	LogInfo("Init begin")

	self.m_pTimeLeft:setText("")
	
	self.m_pLevel:setText(MHSD_UTILS.get_resstring(2808))
	self.m_pTime:setText(MHSD_UTILS.get_resstring(2808))

	self.m_pGiftBtn:setEnabled(false)
	self.m_pGiftBtn:setVisible(false)
	
 	local btn = self.m_pVipBtn[self.m_iSelectID]
 	if not GetGameUIManager():IsWindowHaveEffect(btn) then
        GetGameUIManager():AddUIEffect(btn , MHSD_UTILS.get_effectpath(10435))
    end 

	local vipmanager = VipManager.getInstanceNotCreate()
	if vipmanager and vipmanager.m_iVipLevel ~= 0 then	
		self.m_pVipLevel = vipmanager.m_iVipLevel
		-- print("VIP: ", self.m_pVipLevel , "<-- ", vipmanager.m_iVipLevel, " ct", vipmanager.m_iVipcdtime["vip" .. tostring(self.m_pVipLevel)])
		self.m_pLevel:setText(MHSD_UTILS.get_resstring(2804 + vipmanager.m_iVipLevel))
		for i=1, 3 do
			local vipstr = "vip" .. tostring(i)
			self.m_vipcdtime[vipstr] = vipmanager.m_iVipcdtime[vipstr]
			self.m_vipaward[vipstr] = vipmanager.m_bCanTakeAward[vipstr]
		end
		local time = vipmanager.m_iRemainTime
		local hour = (time / 3600 / 1000) % 24
		local day = (time / 3600 / 1000) / 24	
		local strBuild = StringBuilder:new()
		strBuild:SetNum("parameter1", math.floor(day))
		strBuild:SetNum("parameter2", math.ceil(hour))
		self.m_pTime:setText(strBuild:GetString(MHSD_UTILS.get_resstring(2804)))
		strBuild:delete()
	end

	self:RefreshVipInfo()

	self:HandleCdTime()

end

function VipDialogDefault:HandleRewardBtnClicked(args)
	LogInfo("VipDialogDefault handle rewardbtn clicked")
	local giftLevel = 2 + self.m_iSelectID
 	GetPKManager():RequestReward(giftLevel)
 	self:Init()
 	self:HandleCdTime()
 	-- self:ToggleBuyGift(false,true, true)
end

function VipDialogDefault:HandleCdTime()
	LogInfo("VipDialogDefault:HandleCdTime")
	if self.m_pVipLevel > 0 then
		local vip = "vip" .. tostring(self.m_iSelectID)
		local vipcdtime = self.m_vipcdtime[vip]
		if self.m_vipaward[vip] == 0  then 
			if vipcdtime > 0 then
			-- can buy the vip
				print("PROC BUY VIP")
				local time = vipcdtime
				local hour = (time / 3600 / 1000) % 24
				local day = (time / 3600 / 1000) / 24	
				local strBuild = StringBuilder:new()
				strBuild:SetNum("parameter1", math.floor(day))
				strBuild:SetNum("parameter2", math.ceil(hour))
				local str = strBuild:GetString(MHSD_UTILS.get_msgtipstring(145829))
				self.m_pTimeLeft:setText(str)
				self:ToggleBuyGift(false, true, true)
				strBuild:delete()
			else
				self.m_pTimeLeft:setText("")
				self:ToggleBuyGift(false, false, true)
			end
		else 
			self.m_pTimeLeft:setText("")
			self:ToggleBuyGift(true, false, false)
		end
	else
		self.m_pTimeLeft:setText("")
		self:ToggleBuyGift(false, false, true)
	end

	LogInfo("VipDialogDefault:HandleCdTime: end")
end

function VipDialogDefault:RefreshVipInfo()
	LogInfo("RefreshVipInfo begin")
	local vipinfo = knight.gsp.game.GetCVIPconfigTableInstance():getRecorder(self.m_iSelectID)
	-- print("###SEID: ", self.m_iSelectID, "  ", vipinfo.title, "  ", vipinfo.des)
	self.m_pTitle:setText(vipinfo.title)
	self.m_pDescribe:Clear()
	self.m_pDescribe:AppendParseText(CEGUI.String(vipinfo.des))
	self.m_pDescribe:Refresh()
	self.m_pDescribe:HandleTop()

	self.m_pRewardYB:setText(vipinfo.rewardyuanbao)
	self.m_pDailyYB:setText(vipinfo.dailyyuanbao)

	local itemattr = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(vipinfo.item1)
	self.m_pItem1:SetImage(GetIconManager():GetImageByID(itemattr.icon))
	self.m_pItem1:SetTextUnit(tostring(vipinfo.num1))
	self.m_pItem1:setID(itemattr.id)
	self.m_pItem1:subscribeEvent("TableClick", CGameItemTable.HandleShowTootipsWithItemID, CGameItemTable)

	itemattr = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(vipinfo.item2)
	self.m_pItem2:SetImage(GetIconManager():GetImageByID(itemattr.icon))
	self.m_pItem2:SetTextUnit(tostring(vipinfo.num2))
	self.m_pItem2:setID(itemattr.id)
	self.m_pItem2:subscribeEvent("TableClick", CGameItemTable.HandleShowTootipsWithItemID, CGameItemTable)
	LogInfo("VipDialogDefault: RefreshVipInfo end")
end

function VipDialogDefault:HandleVipSelectChange(args)
	LogInfo("VipDialogDefault handle vip select change")
	
	local e = CEGUI.toWindowEventArgs(args)
	local curID = e.window:getID()

	local preBtn = self.m_pVipBtn[self.m_iSelectID]
	local curBtn = self.m_pVipBtn[curID]

	print("PREID: ", self.m_iSelectID, "CURID: ", curID)

	if curID ~= self.m_iSelectID and GetGameUIManager():IsWindowHaveEffect(preBtn) then
		GetGameUIManager():RemoveUIEffect(preBtn)
        GetGameUIManager():AddUIEffect(curBtn , MHSD_UTILS.get_effectpath(10435))
        self.m_iSelectID = curID       
    end

	self:RefreshVipInfo()
	self:HandleCdTime()
end

function VipDialogDefault:ToggleBuyGift(giftEnable,iconEnable,buyEnable)
	-- body
	self.m_pGiftBtn:setEnabled(giftEnable)
	self.m_pGiftBtn:setVisible(giftEnable)
	self.m_pImg1:setVisible(iconEnable)
	self.m_pImg2:setVisible(iconEnable)
	self.m_pBuyBtn:setEnabled(buyEnable)
	self.m_pBuyBtn:setVisible(buyEnable)
end

function VipDialogDefault:HandleBuyClicked(args)
	LogInfo("VipDialogDefault handle buy clicked")


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


	local vip = "vip" .. tostring(self.m_iSelectID)
	if self.m_pVipLevel > 0 and self.m_iSelectID == self.m_pVipLevel and self.m_vipcdtime[vip] > 0 then
	    	local vipCdTime = self.m_vipcdtime[vip]
	    	-- self:ToggleBuyGift(false,true,true)
	    	local hour = (vipCdTime/ 3600 / 1000) % 24
			local day = (vipCdTime / 3600 / 1000) / 24	
			local strBuild = StringBuilder:new()
			strBuild:SetNum("parameter1", math.floor(day))
			strBuild:SetNum("parameter2", math.ceil(hour))
	    	local str = strBuild:GetString(MHSD_UTILS.get_msgtipstring(145828))
	    	LogInfo("CD TIP: ", str)
	    	GetMessageManager():AddConfirmBox(eConfirmNormal,
	  			str, 
	  			VipDialogDefault.HandleBuyVip,
	  			self,
	  			CMessageManager.HandleDefaultCancelEvent,
	  			CMessageManager)
	  		strBuild:delete()
	else 
		-- self:ToggleBuyGift(false, false, true)
		self:HandleBuyVip()    
    end
	
end

function VipDialogDefault:HandleBuyVip(args)
	self.goodid = -1
	local id = self.m_iSelectID
	local ids = BeanConfigManager.getInstance():GetTableByName("knight.gsp.yuanbao.caddcashlua"):getAllID()
	-- print("IDNO: ",ids)
    for k,v in pairs(ids) do
		local item = BeanConfigManager.getInstance():GetTableByName("knight.gsp.yuanbao.caddcashlua"):getRecorder(v)
		if (Config.CUR_3RD_LOGIN_SUFFIX == item.roofid or (Config.CUR_3RD_LOGIN_SUFFIX == "lahu" and item.roofid == "apps")) and item.kind == (id + 1) then
            self.goodid = item.id
			break
		end
	end

	--default 91
	if self.goodid == -1 then
		local id = self.m_iSelectID
		local ids = BeanConfigManager.getInstance():GetTableByName("knight.gsp.yuanbao.caddcashlua"):getAllID()

		for k,v in pairs(ids) do
			local item = BeanConfigManager.getInstance():GetTableByName("knight.gsp.yuanbao.caddcashlua"):getRecorder(v)
			if item.roofid == "wl91" and item.kind == (id + 1) then
				self.goodid = item.id
				break
			end
		end
	end
	LogInfo("vip buy good id = " .. tostring(self.goodid))

	if Config.CUR_3RD_LOGIN_SUFFIX == "ydjd" and self.goodid ~= 94 then
		GetGameUIManager():AddMessageTipById(145072)
		return true
	end
	if self.goodid == -1 then
		GetGameUIManager():AddMessageTipById(145072)
		return true
	end
	local buyVipProduct = CBuyVipProduct.Create()	
	buyVipProduct.productid = self.goodid
	buyVipProduct.viplevel = id
	LuaProtocolManager.getInstance():send(buyVipProduct) 
    return true
end

return VipDialogDefault
