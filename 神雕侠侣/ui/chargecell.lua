ChargeCell = {}

setmetatable(ChargeCell, Dialog)
ChargeCell.__index = ChargeCell
local prefix = 0
------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
function ChargeCell.CreateNewDlg(pParentDlg, id)
	LogInfo("enter ChargeCell.CreateNewDlg")
	local newDlg = ChargeCell:new()
	newDlg:OnCreate(pParentDlg,id)

    return newDlg
end
----/////////////////////////////////////////------

function ChargeCell.GetLayoutFileName()
    return "addcashcell.layout"
end

function ChargeCell:OnCreate(pParentDlg, id)
	LogInfo("enter ChargeCell oncreate")
	prefix = prefix + 1
    Dialog.OnCreate(self, pParentDlg, prefix)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
	self.m_back = winMgr:getWindow(tostring(prefix) .. "addcashcell")
	self.m_icon = winMgr:getWindow(tostring(prefix) .. "addcashcell/item")
	self.m_yuanbao = {}
	self.m_yuanbaoNumWnd = winMgr:getWindow(tostring(prefix) .. "addcashcell/num")
	self.m_yuanbaoPicWnd = winMgr:getWindow(tostring(prefix) .. "addcashcell/info")
	for i = 5,0,-1 do
		self.m_yuanbao[5-i+1] = winMgr:getWindow(tostring(prefix) .. "addcashcell/num/num" .. i)
	end
	self.m_price = {}
	for i = 5,0,-1 do
		self.m_price[5-i+1] = winMgr:getWindow(tostring(prefix) .. "addcashcell/num1/num" .. i)
	end
	self.m_extraback = winMgr:getWindow(tostring(prefix) .. "addcashcell/back")
	self.m_extra = {}
	for i = 4,0,-1 do
		self.m_extra[4-i+1] = winMgr:getWindow(tostring(prefix) .. "addcashcell/add/num" .. i)
	end
	self.m_buybtn = winMgr:getWindow(tostring(prefix) .. "addcashcell/btn")
	self.m_cashnum = winMgr:getWindow(tostring(prefix) .. "addcashcell/num1")

    -- subscribe event
	self.m_buybtn:subscribeEvent("Clicked", ChargeCell.HandleBuyBtnClick, self) 
    --init settings
	self.m_ID = id

	self.m_cashicon = winMgr:getWindow(tostring(prefix) .. "addcashcell/info1")
	self.image_91dou = winMgr:getWindow(tostring(prefix) .. "addcashcell/info2")
	self.m_cashicon:setVisible(true)
	self.image_91dou:setVisible(false)

	if Config.TRD_PLATFORM == 1 then
	-- 若是91平台，显示91豆
		if Config.CUR_3RD_PLATFORM == "91" then
			self.image_91dou:setVisible(true)
			self.m_cashicon:setVisible(false)
		end
	end

	self.m_FanbeiMark = winMgr:getWindow(tostring(prefix) .. "addcashcell/biaozhi")

	LogInfo("exit ChargeCell OnCreate")
end

------------------- public: -----------------------------------

function ChargeCell:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, ChargeCell)

    return self
end

function ChargeCell:Init(goodid, price, yuanbao, present, beishu, yuanbao_max)
	print("ChargeCell:Init goodid: " .. goodid)
	local rec = BeanConfigManager.getInstance():GetTableByName("knight.gsp.yuanbao.caddcashlua"):getRecorder(goodid)
	if rec then
		self.m_icon:setProperty("Image", rec.itemicon)
		if rec.kind ~= 5 then
			self:SetPrice(price, rec.cashkind,rec.unititem)
		end
	end

	self.goodid = goodid
	if rec.kind ~= 5 then
		self:SetYuanbao(yuanbao)
		self:SetExtra(present)
	end
	
	self.beishu = beishu
	if self.beishu > 0 then
		self:SetFanbei(true)
	else
		self:SetFanbei(false)
	end

	self.yuanbaomax = yuanbao_max

	--VIP or marry
	if (rec.kind >= 2 and rec.kind <= 4) or (rec.kind >= 6 and rec.kind <= 8) then
		self.m_yuanbaoNumWnd:setVisible(false)
		self.m_yuanbaoPicWnd:setVisible(false)
		self.m_extraback:setVisible(false)
	end
	if rec.kind == 5 then
		self.m_yuanbaoNumWnd:setVisible(false)
		self.m_yuanbaoPicWnd:setVisible(false)
		self.m_extraback:setVisible(false)
		self.m_cashicon:setVisible(false)
		self.image_91dou:setVisible(false)
		self.m_cashnum:setVisible(false)
	end
	--unicomonly 
	if Config.MOBILE_ANDROID == 1 and Config.CUR_3RD_LOGIN_SUFFIX == "unsd" then
		if goodid == 114 or goodid == 115 or goodid == 116 then
			self.m_extraback:setVisible(false)
		end
	end

end

function ChargeCell:HandleBuyBtnClick(args)
	LogInfo("enter HandlerBuyBtnClick goodid " .. self.goodid .. "stat "..ChargeDialog.m_ChargeState)
	if self.goodid == 90 then
		require "luaj"
		luaj.callStaticMethod("com.wanmei.mini.condor.unicomonly.UnicomPlatform", "chargeTrafficPacket", nil, "()V")
		return true
	end
	require "protocoldef.knight.gsp.yuanbao.cconfirmcharge"

	local item = BeanConfigManager.getInstance():GetTableByName("knight.gsp.yuanbao.caddcashlua"):getRecorder(self.goodid)
	print("goodid = ",tostring(self.goodid), "max = ", tostring(self.yuanbaomax))
	if ChargeDialog.m_ChargeState == 0 and item.kind == 1 and self.yuanbaomax ~= 0 then
		--unicom charge for a little RMB 
		if Config.CUR_3RD_LOGIN_SUFFIX == "unsd" and (self.goodid == 114 or self.goodid == 115 or self.goodid == 116) then
			require "protocoldef.knight.gsp.yuanbao.cconfirmcharge"
			local luap = CConfirmCharge.Create()	
			luap.goodid = self.goodid
			luap.goodnum = 1
			LuaProtocolManager.getInstance():send(luap)
			return
		elseif self.goodid ~= self.yuanbaomax then
			require "ui.firstchargetipdialog"
			FirstChargeTipDialog.getInstance():SetGoodID(self.goodid, self.yuanbaomax)
			return
		end
	end
 
	--VIP 
	if item.kind == 2 or item.kind == 3 or item.kind == 4 then
		local viplevel = item.kind - 1
		local buyVipProduct = CBuyVipProduct.Create()	
		buyVipProduct.productid = self.goodid
		buyVipProduct.viplevel = viplevel 
		LuaProtocolManager.getInstance():send(buyVipProduct)
		return 					
	end

	if Config.TRD_PLATFORM == 1 then
		if (Config.CUR_3RD_PLATFORM == "app") then
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
			local luap = CConfirmCharge.Create()
			luap.goodid = self.goodid
			luap.goodnum = 1
			LuaProtocolManager.getInstance():send(luap)
		end
	end

	return true
end

function ChargeCell:SetPrice(price, cashkind,unititem)
	if price >= 1000000 then return end

	local num = price
	local t_price = {}
	local pos = 1
	local zerovisible = false
	for i = 6,1,-1 do
		local txt = math.floor(num/math.pow(10,i-1))
		if i == 3 and cashkind == 2 then
			zerovisible = true
		end
		num = math.mod(num, math.pow(10,i-1))

		if txt>0 then
			t_price[pos] = "set:MainControl10 image:blue" .. txt
			pos = pos+1
			zerovisible = true
		else
			if zerovisible then
			t_price[pos] = "set:MainControl10 image:blue" .. txt
				pos = pos+1
			end
		end
	end
	-- self.m_cashicon  默认＝1  图标是人民币 3韩元
	if cashkind == 2 then
		self.m_cashicon:setProperty("Image", "set:MainControl10 image:zdollar")
		pos = pos+1
		t_price[pos-1] = t_price[pos-2]
		t_price[pos-2] = t_price[pos-3]
		t_price[pos-3] = "set:MainControl10 image:z0"
	elseif  unititem then 
		self.m_cashicon:setProperty("Image", unititem)
	end
	
	for i=1, pos-1 do
		self.m_price[i]:setProperty("Image", t_price[i])
		self.m_price[i]:setVisible(true)
	end
	for i=pos, 6 do
		self.m_price[i]:setVisible(false)
	end
end

function ChargeCell:SetYuanbao(yuanbao)
	if yuanbao >= 1000000 then return end
	if yuanbao == 0 then
		self.m_yuanbaoNumWnd:setVisible(false)
		self.m_yuanbaoPicWnd:setVisible(false)
		return
	else
		self.m_yuanbaoNumWnd:setVisible(true)
		self.m_yuanbaoPicWnd:setVisible(true)
	end

	local num = yuanbao
	local pos = 1
	local zerovisible = false
	for i = 6,1,-1 do
		local txt = math.floor(num/math.pow(10,i-1))
		num = math.mod(num, math.pow(10,i-1))

		self.m_yuanbao[pos]:setVisible(true)
		if txt > 0 then 
			self.m_yuanbao[pos]:setProperty("Image", "set:MainControl10 image:blue" .. txt)
			zerovisible = true
			pos = pos + 1
		else
			if zerovisible then
				self.m_yuanbao[pos]:setProperty("Image", "set:MainControl10 image:blue" .. txt)
				pos = pos + 1
			end
		end
	end
	for i= pos,6 do
		self.m_yuanbao[i]:setVisible(false)
	end
end

function ChargeCell:SetExtra(present)
	if present >= 100000 then return end

	if present == 0 then 
		self.m_extraback:setVisible(false)
	else
		self.m_extraback:setVisible(true)
	end

	local offflag =  (present < 1000)
	local num = present
	local zerovisible = false
	local pos = 1
	if offflag then 
		self.m_extra[1]:setVisible(false)
		pos = 2 
	end

	for i = 5,1,-1 do
		local txt = math.floor(num/math.pow(10,i-1))
		num = math.mod(num, math.pow(10,i-1))

		self.m_extra[pos]:setVisible(true)
		if txt > 0 then 
			self.m_extra[pos]:setProperty("Image", "set:MainControl10 image:red" .. txt)
			zerovisible = true
			pos = pos + 1
		else
			if zerovisible then
				self.m_extra[pos]:setProperty("Image", "set:MainControl10 image:red" .. txt)
				pos = pos + 1
			end
		end
	end
	for i= pos,5 do
		self.m_extra[i]:setVisible(false)
	end
end

function ChargeCell:SetFanbei(isFanbei)
	if isFanbei then
		self.m_buybtn:setProperty("HoverImage", "set:MainControl10 image:chongzhiback1")
	    self.m_buybtn:setProperty("NormalImage", "set:MainControl10 image:chongzhiback1")
	    self.m_buybtn:setProperty("PushedImage", "set:MainControl10 image:chongzhiback1")
	    self.m_buybtn:setProperty("DisabledImage", "set:set:MainControl10 image:chongzhiback1")
	    self.m_FanbeiMark:setVisible(true)
	else
		self.m_buybtn:setProperty("HoverImage", "set:MainControl10 image:chongzhiback")
	    self.m_buybtn:setProperty("NormalImage", "set:MainControl10 image:chongzhiback")
	    self.m_buybtn:setProperty("PushedImage", "set:MainControl10 image:chongzhiback")
	    self.m_buybtn:setProperty("DisabledImage", "set:set:MainControl10 image:chongzhiback")
	    self.m_FanbeiMark:setVisible(false)
	end
end

return ChargeCell
