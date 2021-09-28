require "ui.dialog"
require "utils.mhsdutils"


LuckyWheelDlg = {}
setmetatable(LuckyWheelDlg, Dialog)
LuckyWheelDlg.__index = LuckyWheelDlg

LuckyWheelDlg.ACTION_NONE = 0
LuckyWheelDlg.ACTION_START = 1
LuckyWheelDlg.ACTION_STOP = 2
LuckyWheelDlg.ACTION_UP = 3
LuckyWheelDlg.ACTION_DOWN = 4
LuckyWheelDlg.ACTION_LINE = 5
LuckyWheelDlg.ACTION_WAIT = 6
LuckyWheelDlg.ACTION_WANTSTOP = 7

LuckyWheelDlg.UP_TIME = 0.5
LuckyWheelDlg.DOWN_TIME = 2
LuckyWheelDlg.LINE_TIME = 3
LuckyWheelDlg.LINE_SPEED = 4*math.pi
LuckyWheelDlg.MIN_SPEED = 0.3*math.pi

if require "config".isTaiWan() then
	LuckyWheelDlg.PROCESS_MAX_HP = 300
	LuckyWheelDlg.PROCESS_MAX_TP = 3000
else
	LuckyWheelDlg.PROCESS_MAX_HP = 100
	LuckyWheelDlg.PROCESS_MAX_TP = 1000
end
------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function LuckyWheelDlg.getInstance()
	print("enter get LuckyWheelDlg dialog instance")
    if not _instance then
        _instance = LuckyWheelDlg:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function LuckyWheelDlg.getInstanceAndShow()
	print("enter LuckyWheelDlg dialog instance show")
    if not _instance then
        _instance = LuckyWheelDlg:new()
        _instance:OnCreate()
	else
		print("set LuckyWheelDlg dialog visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function LuckyWheelDlg.getInstanceNotCreate()
    return _instance
end

function LuckyWheelDlg.DestroyDialog()
	if _instance then 
		_instance:OnClose()
		_instance = nil
	end
end

function LuckyWheelDlg.ToggleOpenClose()
	if not _instance then 
		_instance = LuckyWheelDlg:new() 
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

function LuckyWheelDlg.GetLayoutFileName()
    return "zhuanpan.layout"
end

function LuckyWheelDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, LuckyWheelDlg)

    self.m_data = {}
    self.m_data.bltyless = 0
    self.m_data.bltyileftnums = 0
    self.m_data.qznfless = 0
    self.m_data.qznfleftnums = 0
    self.m_data.delaytime = 0

    self.m_selectid = 1
    self.m_untakenaward = 0
    self.m_flag = 0
    self.m_prize = {} -- should be -1 
    for i=1,2 do 
    	self.m_prize[i] = {}
    	self.m_prize[i].hasprize = 0
    	self.m_prize[i].index = 0
    end

	self.m_action = LuckyWheelDlg.ACTION_NONE
	self.m_speed = 0
	self.m_angle = 0
	self.m_upspeed = LuckyWheelDlg.LINE_SPEED/LuckyWheelDlg.UP_TIME
	self.m_downspeed = LuckyWheelDlg.LINE_SPEED/LuckyWheelDlg.DOWN_TIME
	self.m_linetime = LuckyWheelDlg.LINE_TIME
    return self
end

function LuckyWheelDlg:OnCreate()
	print("LuckyWheelDlg dialog oncreate begin")
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()

	self.m_itemcells = {}
	self.m_itemtxts = {}
	
	self.m_itemcells[1] = CEGUI.Window.toItemCell(winMgr:getWindow("zhuanpan/luckyback/cell" .. tostring(9)))
	self.m_itemtxts[1] = winMgr:getWindow("zhuanpan/luckyback/red/txt" .. tostring(9))
	for i=1,9 do
		self.m_itemcells[i+1] = CEGUI.Window.toItemCell(winMgr:getWindow("zhuanpan/luckyback/cell" .. tostring(i-1)))
		self.m_itemtxts[i+1] = winMgr:getWindow("zhuanpan/luckyback/red/txt" .. tostring(i-1))
	end

	self.m_title = winMgr:getWindow("zhuanpan/luckyback/title")

	self.m_close = CEGUI.Window.toPushButton(winMgr:getWindow("zhuanpan/close"))
	self.m_close:subscribeEvent("Clicked", LuckyWheelDlg.DestroyDialog, self)
	self.m_hundredbtn = CEGUI.Window.toPushButton(winMgr:getWindow("zhuanpan/left/qiehuan0"))
	self.m_hundredbtn:subscribeEvent("Clicked", LuckyWheelDlg.HandleBtnClick, self)
	self.m_hundredbtn:setID(1)
	self.m_hneedmoney = winMgr:getWindow("zhuanpan/left/bar/txt/tt")
	self.m_hprogressbar = CEGUI.Window.toProgressBar(winMgr:getWindow("zhuanpan/left/bar"))
	self.m_hremaintimes = winMgr:getWindow("zhuanpan/left/shuoming3")

	self.m_thousandbtn = CEGUI.Window.toPushButton(winMgr:getWindow("zhuanpan/left/qiehuan1"))
	self.m_thousandbtn:subscribeEvent("Clicked", LuckyWheelDlg.HandleBtnClick, self)
	self.m_thousandbtn:setID(2)

	self.m_tneedmoney = winMgr:getWindow("zhuanpan/left/bar1/txt/tt")
	self.m_tprogressbar = CEGUI.Window.toProgressBar(winMgr:getWindow("zhuanpan/left/bar1"))
	self.m_tremaintimes = winMgr:getWindow("zhuanpan/left/shuoming7")

	self.m_charge = CEGUI.Window.toPushButton(winMgr:getWindow("zhuanpan/chongzhi"))
	self.m_charge:subscribeEvent("Clicked", LuckyWheelDlg.HandleChargeBtn, self)
	self.m_remaindays = winMgr:getWindow("zhuanpan/time/txt0")
	self.m_remainhours = winMgr:getWindow("zhuanpan/time/txt1")
	self.m_remainmins = winMgr:getWindow("zhuanpan/time/txt2")


	self.m_start = winMgr:getWindow("zhuanpan/luckyback/imgebtn")
	self.m_start:subscribeEvent("Clicked", LuckyWheelDlg.HandleStartClicked, self) 

	self.m_effect = winMgr:getWindow("zhuanpan/luckyback/effect")
	self.m_arroweffect = GetGameUIManager():AddUIEffect(self.m_effect, MHSD_UTILS.get_effectpath(10395))
	
	self:initWheelPannel(self.m_selectid)

	print("LuckyWheelDlg dialog oncreate end")
end

------------------- private: -----------------------------------

function LuckyWheelDlg:SetUntakenPrizePos(idx)
	local angle = idx * 0.2*math.pi
	self.m_arroweffect:SetRotationRadian(angle)
end

function LuckyWheelDlg:CleanAllItems()
	for i=1, 10 do
		self.m_itemcells[i]:Clear()
		self.m_itemtxts[i]:setText("")
	end
end

function LuckyWheelDlg:initWheelPannel(typeid)
	local tbl = BeanConfigManager.getInstance():GetTableByName("knight.gsp.game.chappycompass")
	for i=1, 10 do
		self.m_itemcells[i]:SetBackGroundEnable(false)
		local u = tbl:getRecorder(i+9 + (typeid - 1)*10)
		-- print(" ", i+9 + (typeid - 1)*10, " ",u.id, " ", u.itemid)
		local item = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(u.itemid)
		self.m_itemcells[i]:SetImage(GetIconManager():GetItemIconByID(item.icon))
		self.m_itemtxts[i]:setText(item.name)
	end
	if typeid ==1 then
		self.m_title:setProperty("Image","set:MainControl32 image:zbailitiaoyi")
	else
		self.m_title:setProperty("Image","set:MainControl32 image:zqianzainanfeng")
	end
end

function LuckyWheelDlg:HandleBtnClick(args)
	local e = CEGUI.toWindowEventArgs(args)
	local typeid = e.window:getID()
	if typeid == self.m_selectid then
		return 
	end

	if self.m_flag == 1 then
		return 
	end

	if typeid ~= self.m_selectid and self.m_prize[self.m_selectid].hasprize == 1 then
		--need a tips
		GetGameUIManager():AddMessageTip(MHSD_UTILS.get_msgtipstring(146150))
		return
	end

	self.m_selectid = typeid
	self:ResetPannel()
	print("CLICKED :", typeid)
	-- self:CleanAllItems()
	self:initWheelPannel(typeid)
end
function LuckyWheelDlg:SetPannelData(ztype,index,zpinfo)
	print("SetPannelData begin")
	-- self.m_prizetype = ztype
	self.m_prize[ztype].index = index
	self.m_data.bltyless = zpinfo.bltyless
	self.m_data.bltyileftnums = zpinfo.bltyileftnums
	self.m_data.qznfless = zpinfo.qznfless
	self.m_data.qznfleftnums = zpinfo.qznfleftnums
	self.m_data.delaytime = zpinfo.delaytime

	print(self.m_data.bltyileftnums," ",self.m_data.qznfleftnums," ",self.m_data.delaytime)

	self:InitPannelData()

	print("SetPannelData end")
end


function LuckyWheelDlg:InitPannelData()
	print("setInitialData begin")
	self.m_untakenaward = 0
	-- local idx = ztype
	-- local flag = index 
	local info = self.m_data
	print(info.bltyileftnums," ",info.qznfless," ", info.qznfleftnums, " ", info.delaytime)
	self.m_hremaintimes:setText(tostring(info.bltyileftnums))
	self.m_hneedmoney:setText(tostring(info.bltyless))

	self.m_hprogressbar:setProgress((LuckyWheelDlg.PROCESS_MAX_HP-info.bltyless)/LuckyWheelDlg.PROCESS_MAX_HP)
	self.m_tremaintimes:setText(tostring(info.qznfleftnums))

	self.m_tneedmoney:setText(tostring(info.qznfless))
	self.m_tprogressbar:setProgress((LuckyWheelDlg.PROCESS_MAX_TP-info.qznfless)/LuckyWheelDlg.PROCESS_MAX_TP)

	local seconds = math.floor(info.delaytime/1000)
	local days = math.floor(seconds/(3600*24))
    local leftMinSec = seconds - days*3600*24
 
    local hours = math.floor(leftMinSec/3600)
    local leftMinSec = leftMinSec - hours*3600

    local mins = math.floor(leftMinSec/60)

    if hours < 0 then
        hours = 0
    end
    if mins < 0 then
        mins = 0
    end
    if days < 0 then
        days = 0
    end
    self.m_remaindays:setText(tostring(days))
    self.m_remainhours:setText(tostring(hours))
    self.m_remainmins:setText(tostring(mins))
	print("setInitialData end")
end

function LuckyWheelDlg:SetPrizeIndex(ztype,idx, zpinfo)
	print("@@@@set the idx: ",idx, " ", ztype)
	self.m_prize[ztype].hasprize = 1
	self.m_prize[ztype].index = idx
	self.m_action = LuckyWheelDlg.ACTION_WANTSTOP
	self:RefreshPannel(zpinfo)
end

function LuckyWheelDlg:HandleUntakenPrize(ztype,index,zpinfo)
	print("HandleUntakenPrize begin","untaken: ",ztype," ", index)
	self.m_untakenaward = 1
	self.m_selectid = ztype
	self.m_prize[ztype].hasprize = 1
	self.m_prize[ztype].index = index

	self:RefreshPannel(zpinfo)

	self.m_data.bltyileftnums = zpinfo.bltyileftnums 
	self.m_data.bltyless = zpinfo.bltyless
	self.m_data.qznfleftnums = zpinfo.qznfleftnums
	self.m_data.qznfless = zpinfo.qznfless
	self.m_data.delaytime = zpinfo.delaytime

    self.m_start:setProperty("HoverImage", "set:MainControl27 image:out")
    self.m_start:setProperty("NormalImage", "set:MainControl27 image:out") 
    self.m_start:setProperty("PushedImage", "set:MainControl27 image:out") 
    self.m_action = LuckyWheelDlg.ACTION_STOP

    self:initWheelPannel(ztype)
    self:SetUntakenPrizePos(index)
    -- self.m_action == LuckyWheelDlg.ACTION_STOP 
    print("HandleUntakenPrize begin")
end

function LuckyWheelDlg:RefreshPannel(zpinfo)
	print("refresh pannel ")
	local a = zpinfo.bltyileftnums
	local b = zpinfo.bltyless
	local c = zpinfo.qznfleftnums
	local d = zpinfo.qznfless
	local e = zpinfo.delaytime

	self.m_data.bltyileftnums = zpinfo.bltyileftnums 
	self.m_data.bltyless = zpinfo.bltyless
	self.m_data.qznfleftnums = zpinfo.qznfleftnums
	self.m_data.qznfless = zpinfo.qznfless
	self.m_data.delaytime = zpinfo.delaytime

	self.m_hremaintimes:setText(tostring(a))
	self.m_hneedmoney:setText(tostring(b))
	self.m_hprogressbar:setProgress((LuckyWheelDlg.PROCESS_MAX_HP-b)/LuckyWheelDlg.PROCESS_MAX_HP)
	self.m_tremaintimes:setText(tostring(c))
	self.m_tneedmoney:setText(tostring(d))
	self.m_tprogressbar:setProgress((LuckyWheelDlg.PROCESS_MAX_TP-d)/LuckyWheelDlg.PROCESS_MAX_TP)

	local seconds = math.floor(e/1000)
	local days = math.floor(seconds/(3600*24))
    local leftMinSec = seconds - days*3600*24
    
    local hours = math.floor(leftMinSec/3600)
    local leftMinSec = leftMinSec - hours*3600

    local mins = math.floor(leftMinSec/60)
    -- local secs = math.floor(leftMinSec - mins*60)

    if hours < 0 then
        hours = 0
    end
    if mins < 0 then
        mins = 0
    end
    if days < 0 then
        days = 0
    end

    self.m_remaindays:setText(tostring(days))
    self.m_remainhours:setText(tostring(hours))
    self.m_remainmins:setText(tostring(mins))

    -- self.m_start:setVisible(true)
    -- self.m_prizeidx = 0
    print("refresh pannel end")
end

function LuckyWheelDlg:ResetPannel()
	self.m_speed = 0
	local id = self.m_selectid
	
	if self.m_prize[self.m_selectid].hasprize == 0 then
		self.m_arroweffect:SetRotationRadian(0)
		self.m_action = LuckyWheelDlg.ACTION_NONE
		self.m_start:setProperty("HoverImage", "set:MainControl27 image:start")
    	self.m_start:setProperty("NormalImage", "set:MainControl27 image:start")
    	self.m_start:setProperty("PushedImage", "set:MainControl27 image:start")
    else
    	print("has prize idx: ", id, " ", self.m_prize[id].index)
    	self:SetUntakenPrizePos(self.m_prize[id].index)
		self.m_action = LuckyWheelDlg.ACTION_STOP
		self.m_start:setProperty("HoverImage", "set:MainControl27 image:out")
    	self.m_start:setProperty("NormalImage", "set:MainControl27 image:out")
    	self.m_start:setProperty("PushedImage", "set:MainControl27 image:out")
    end
end

function LuckyWheelDlg:setFetchResult(flag,status)
	print("setFetchResult begin: ",flag, " st: ",status)
	-- self.m_takesucess = flag
	local id = self.m_selectid
	if flag == 1 then
		-- self.m_prize[id].hasprize = 0
		if self.m_untakenaward == 1 then
			if status == 0 then
				LuckyWheelDlg.DestroyDialog()
			end
			-- self.m_prize[id].index = 0
			-- self.m_start:setVisible(false)
	  --       self.m_start:setProperty("HoverImage", "set:MainControl27 image:start")
	  --       self.m_start:setProperty("NormalImage", "set:MainControl27 image:start")
	  --       self.m_start:setProperty("PushedImage", "set:MainControl27 image:start")
			self.m_untakenaward = 0
		end
		--show the start image
		self.m_start:setVisible(true)
		self.m_action = LuckyWheelDlg.ACTION_NONE
		self.m_flag = 0
	end
	print("setFetchResult end")
end

function LuckyWheelDlg:HandleStartClicked(args)
	-- print("m_untakenaward: ",self.m_untakenaward," bl: ",self.m_data.bltyileftnums, " qz: ", self.m_data.qznfleftnums)
	if self.m_untakenaward == 1 then
		--fetch the untaken award
		print("untaken award")
		if GetRoleItemManager():IsBagFull() == true then
			GetGameUIManager():AddMessageTip(MHSD_UTILS.get_msgtipstring(146151))
			return 
		end
		local req = require "protocoldef.knight.gsp.activity.dazhuanpan.cfetchaward":new()
		req.ztype = self.m_selectid
		LuaProtocolManager.getInstance():send(req)
		self.m_start:setVisible(false)
        self.m_start:setProperty("HoverImage", "set:MainControl27 image:start")
        self.m_start:setProperty("NormalImage", "set:MainControl27 image:start")
        self.m_start:setProperty("PushedImage", "set:MainControl27 image:start")
        self.m_action = LuckyWheelDlg.ACTION_NONE
		return 
	end

	print("### ", self.m_data.bltyileftnums," ",self.m_selectid," ",self.m_data.qznfleftnums)
	if ((self.m_data.bltyileftnums<=0 and self.m_selectid == 1) or (self.m_data.qznfleftnums<=0 and self.m_selectid==2)) and self.m_prize[self.m_selectid].hasprize == 0 then
		GetGameUIManager():AddMessageTip(MHSD_UTILS.get_msgtipstring(146113))
		return
	end
		
	if self.m_action == LuckyWheelDlg.ACTION_NONE then
		self.m_linetime = LuckyWheelDlg.LINE_TIME
		self.m_action = LuckyWheelDlg.ACTION_START

		self.m_flag = 1

		self.m_start:setVisible(false)
		self.m_start:setProperty("HoverImage", "set:MainControl27 image:stop")
		self.m_start:setProperty("NormalImage", "set:MainControl27 image:stop") 
		self.m_start:setProperty("PushedImage", "set:MainControl27 image:stop")  
	end
	if self.m_action == LuckyWheelDlg.ACTION_LINE then
		-- print("ask stop")
		self.m_start:setVisible(false)
		self.m_start:setProperty("HoverImage", "set:MainControl27 image:out")
		self.m_start:setProperty("NormalImage", "set:MainControl27 image:out") 
		self.m_start:setProperty("PushedImage", "set:MainControl27 image:out") 

		local req = require "protocoldef.knight.gsp.activity.dazhuanpan.cnotifystop":new()
		req.ztype = self.m_selectid
		LuaProtocolManager.getInstance():send(req)
		print("send cnotifystop over")
	end

	if self.m_action == LuckyWheelDlg.ACTION_STOP then
		-- print("fetch the prize")
		if GetRoleItemManager():IsBagFull() == true then
			GetGameUIManager():AddMessageTip(MHSD_UTILS.get_msgtipstring(146151))
			return 
		end
		local req = require "protocoldef.knight.gsp.activity.dazhuanpan.cfetchaward":new()
		req.ztype = self.m_selectid
		LuaProtocolManager.getInstance():send(req)
	
		self.m_prize[self.m_selectid].hasprize  = 0

        self.m_start:setVisible(false)
        self.m_start:setProperty("HoverImage", "set:MainControl27 image:start")
        self.m_start:setProperty("NormalImage", "set:MainControl27 image:start")
        self.m_start:setProperty("PushedImage", "set:MainControl27 image:start")
        -- self.m_action = LuckyWheelDlg.ACTION_NONE

    end
end

function LuckyWheelDlg:HandleChargeBtn()
    ChargeDialog.GeneralReqCharge()
	return true
end

function LuckyWheelDlg:run(delta)
	-- print("ACT: ",self.m_action)
	if self.m_action == LuckyWheelDlg.ACTION_NONE then
		return
	elseif self.m_action == LuckyWheelDlg.ACTION_START then
		self.m_action = LuckyWheelDlg.ACTION_UP
	elseif self.m_action == LuckyWheelDlg.ACTION_STOP then
		self.m_speed = 0
		return
	elseif self.m_action == LuckyWheelDlg.ACTION_UP then
		self.m_speed = self.m_speed + self.m_upspeed*delta
		if self.m_speed > LuckyWheelDlg.LINE_SPEED then
			self.m_speed = LuckyWheelDlg.LINE_SPEED
			self.m_action = LuckyWheelDlg.ACTION_LINE
			self.m_start:setVisible(true)
		end
	elseif self.m_action == LuckyWheelDlg.ACTION_DOWN then
		self.m_speed = self.m_speed - self.m_downspeed*delta
		if self.m_speed < LuckyWheelDlg.MIN_SPEED then
			self.m_speed = LuckyWheelDlg.MIN_SPEED
			self.m_action = LuckyWheelDlg.ACTION_WAIT
		end
	elseif self.m_action == LuckyWheelDlg.ACTION_WANTSTOP then
		local angle = self.m_prize[self.m_selectid].index * 0.2*math.pi - self.m_angle
		self.m_downspeed = LuckyWheelDlg.LINE_SPEED / ((12*math.pi + 2*angle)/LuckyWheelDlg.LINE_SPEED)
		
		-- print("Angle: ", angle)
		self.m_action = LuckyWheelDlg.ACTION_DOWN
		-- print("set to ACTION_DOWN")
		return	
	elseif self.m_action == LuckyWheelDlg.ACTION_WAIT then
		local angle = math.mod(self.m_angle + math.pi*8/180, 2*math.pi) -- 避开[-8, +8]区间
		local angle_l = self.m_prize[self.m_selectid].index * 0.2*math.pi + math.pi*4/180  -- 角度区间 左 (正值)
		local angle_r = angle_l + math.pi*8/180  --角度区间 右(正值)
		if angle > angle_l and angle < angle_r then
			self.m_action = LuckyWheelDlg.ACTION_STOP
			self.m_speed = 0
			-- self.m_downspeed = LuckyWheelDlg.LINE_SPEED/LuckyWheelDlg.DOWN_TIME
			self.m_start:setVisible(true)
			-- print("set to ACTION_STOP", angle_l," ",angle," ",angle_r)
			return
		end
		-- print(self.m_prize[self.m_selectid].index, " ",angle_l," ",angle," ",angle_r)
		print("wait to stop")
	end
	self.m_angle = math.mod(math.mod((delta*self.m_speed + self.m_angle), 2*math.pi)+2*math.pi, 2*math.pi)
	self.m_arroweffect:SetRotationRadian(self.m_angle)
	-- print("Angle 1: ",self.m_angle)
--	print("speed = " .. self.m_speed .. "  angle = " .. self.m_angle)
end

return LuckyWheelDlg
