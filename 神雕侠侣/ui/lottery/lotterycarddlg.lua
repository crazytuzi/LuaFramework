require "ui.dialog"

require "protocoldef.knight.gsp.npc.cdonefortunewheel"

LotteryCardDlg = {}
setmetatable(LotteryCardDlg, Dialog)
LotteryCardDlg.__index = LotteryCardDlg

LotteryCardDlg.ACTION_NONE = 0
LotteryCardDlg.ACTION_START = 1
LotteryCardDlg.ACTION_STOP = 2
LotteryCardDlg.ACTION_UP = 3
LotteryCardDlg.ACTION_DOWN = 4
LotteryCardDlg.ACTION_LINE = 5
LotteryCardDlg.ACTION_WAIT = 6
LotteryCardDlg.ACTION_WANTSTOP = 7

LotteryCardDlg.UP_TIME = 0.5
LotteryCardDlg.DOWN_TIME = 2
LotteryCardDlg.LINE_TIME = 3
LotteryCardDlg.LINE_SPEED = 4*math.pi
LotteryCardDlg.MIN_SPEED = 0.3*math.pi
------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function LotteryCardDlg.getInstance()
	print("enter get lotterycarddlg dialog instance")
    if not _instance then
        _instance = LotteryCardDlg:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function LotteryCardDlg.getInstanceAndShow()
	print("enter lotterycarddlg dialog instance show")
    if not _instance then
        _instance = LotteryCardDlg:new()
        _instance:OnCreate()
	else
		print("set lotterycarddlg dialog visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function LotteryCardDlg.getInstanceNotCreate()
    return _instance
end

function LotteryCardDlg.DestroyDialog()
	if _instance then 
		_instance:OnClose()
		_instance = nil
	end
end

function LotteryCardDlg.ToggleOpenClose()
	if not _instance then 
		_instance = LotteryCardDlg:new() 
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

function LotteryCardDlg.GetLayoutFileName()
    return "lotterydialog.layout"
end

function LotteryCardDlg:OnCreate()
	print("lotterycarddlg dialog oncreate begin")
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
	self.m_itemcells = {}
	self.m_itemtxts = {}
	for i=0,9 do
		self.m_itemcells[i+1] = CEGUI.Window.toItemCell(winMgr:getWindow("LotteryDialog/diban/card/item" .. i))
		self.m_itemtxts[i+1] = CEGUI.Window.toItemCell(winMgr:getWindow("LotteryDialog/diban/card/txt" .. i))
	end
	self.m_start = winMgr:getWindow("LotteryDialog/diban/start")
	self.m_effect = winMgr:getWindow("LotteryDialog/effect")
	self.m_arroweffect = GetGameUIManager():AddUIEffect(self.m_effect, MHSD_UTILS.get_effectpath(10395))

    -- subscribe event
    self.m_start:subscribeEvent("Clicked", LotteryCardDlg.HandleStartClicked, self) 
--	self:GetWindow():subscribeEvent("WindowUpdate", LotteryCardDlg.HandleWindowUpdate, self)

	print("lotterycarddlg dialog oncreate end")
end

------------------- private: -----------------------------------

function LotteryCardDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, LotteryCardDlg)

	self.m_action = LotteryCardDlg.ACTION_NONE
	self.m_speed = 0
	self.m_angle = 0
	self.m_upspeed = LotteryCardDlg.LINE_SPEED/LotteryCardDlg.UP_TIME
	self.m_linetime = LotteryCardDlg.LINE_TIME
	self.m_itemindex = 1
    return self
end

function LotteryCardDlg:initdlg(itemids, index, npckey, serviceid)
	local numReg = #itemids
    for i = 1, numReg, 1 do
		local data = itemids[i]
		self:initItem(i, data.itemtype, data.id, data.num, data.times)
		print("i=" .. i)
		print("itemtype=" .. data.itemtype)
		print("id=" .. data.id)
		print("num=" .. data.num)
		print("times=" .. data.times)
	end
	self.m_itemindex = index
	self.m_npckey = npckey
	self.m_serviceid = serviceid
	print("self.m_itemindex= " .. index)
	print("self.m_npckey= " .. npckey)
	print("self.m_serviceid= " .. serviceid)
end

function LotteryCardDlg:initItem(i, itemtype, baseid, num, times)
	self.m_itemcells[i]:SetBackGroundEnable(false)
	-- 物品
	if itemtype == 1 then
		local itembean = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(baseid)
		self.m_itemcells[i]:SetImage(GetIconManager():GetItemIconByID(itembean.icon))
		self.m_itemcells[i]:SetTextUnit(num)
		self.m_itemtxts[i]:setText("[border='FF340B00'][colrect='tl:FFFFF660 tr:FFFFF660 bl:FFFFAE00 br:FFFFAE00']" ..itembean.name)
	end
	-- 经验
	if itemtype == 2 then
		local itembean = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(50045)
		self.m_itemcells[i]:SetImage(GetIconManager():GetItemIconByID(itembean.icon))
		if num > 10000 then
			local txt = math.floor(num/100)/10
			self.m_itemtxts[i]:setText(txt .. MHSD_UTILS.get_resstring(402))
		else
			self.m_itemtxts[i]:setText("[border='FF002256'][colrect='tl:FFF0FF00 tr:FFF0FF00 bl:FF8AFF00 br:FF8AFF00']" .. num)
		end
	end
	-- 金钱
	if itemtype == 3 then
		local itembean = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(50046)
		self.m_itemcells[i]:SetImage(GetIconManager():GetItemIconByID(itembean.icon))
		if num > 10000 then
			local txt = math.floor(num/100)/10
			self.m_itemtxts[i]:setText(txt .. MHSD_UTILS.get_resstring(402))
		else
			self.m_itemtxts[i]:setText("[border='FF340B00'][colrect='tl:FFFFF660 tr:FFFFF660 bl:FFFFAE00 br:FFFFAE00']" .. num)
		end
	end
	-- 储备金
	if itemtype == 4 then
		local itembean = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(50046)
		self.m_itemcells[i]:SetImage(GetIconManager():GetItemIconByID(itembean.icon))
		if num > 10000 then
			local txt = math.floor(num/100)/10
			self.m_itemtxts[i]:setText(txt .. MHSD_UTILS.get_resstring(402))
		else
			self.m_itemtxts[i]:setText("[border='FF340B00'][colrect='tl:FFFFF660 tr:FFFFF660 bl:FFFFAE00 br:FFFFAE00']" .. num)
		end
	end
end

function LotteryCardDlg:HandleStartClicked(args)
	if self.m_action == LotteryCardDlg.ACTION_NONE then
		self.m_linetime = LotteryCardDlg.LINE_TIME
		self.m_action = LotteryCardDlg.ACTION_START
		self.m_start:setVisible(false)
		self.m_start:setProperty("NormalImage", "set:MainControl27 image:stop") 
	end
	if self.m_action == LotteryCardDlg.ACTION_LINE then
		self.m_start:setVisible(false)
		self.m_start:setProperty("NormalImage", "set:MainControl27 image:out") 
		self.m_action = LotteryCardDlg.ACTION_WANTSTOP
	end
	if self.m_action == LotteryCardDlg.ACTION_STOP then
		print("self.m_npckey= " .. self.m_npckey)
		print("self.m_serviceid= " .. self.m_serviceid)
        
        local actionReg = CDoneFortuneWheel.Create()
        actionReg.npckey = self.m_npckey
        actionReg.taskid = self.m_serviceid
        actionReg.succ = 1
        actionReg.flag = 0
        LuaProtocolManager.getInstance():send(actionReg)
		
        LotteryCardDlg.DestroyDialog()
	end
end

function LotteryCardDlg:GoAction(delta)
	local v = self.m_speed
	self.m_angle = math.mod((delta*v + self.m_angle), 2*math.pi)
	self.m_arroweffect:SetRotationRadian(self.m_angle)
end

function LotteryCardDlg:run(delta)
	if     self.m_action == LotteryCardDlg.ACTION_NONE then
		return
	elseif self.m_action == LotteryCardDlg.ACTION_START then
		self.m_action = LotteryCardDlg.ACTION_UP
	elseif self.m_action == LotteryCardDlg.ACTION_STOP then
		self.m_speed = 0
		return
	elseif self.m_action == LotteryCardDlg.ACTION_UP then
		self.m_speed = self.m_speed + self.m_upspeed*delta
		if self.m_speed >= LotteryCardDlg.LINE_SPEED then
			self.m_speed = LotteryCardDlg.LINE_SPEED
			self.m_action = LotteryCardDlg.ACTION_LINE
			self.m_start:setVisible(true)
		end
	elseif self.m_action == LotteryCardDlg.ACTION_DOWN then
		self.m_speed = self.m_speed - self.m_downspeed*delta
		if self.m_speed < LotteryCardDlg.MIN_SPEED then
			self.m_speed = LotteryCardDlg.MIN_SPEED
			self.m_action = LotteryCardDlg.ACTION_WAIT
		end
	elseif self.m_action == LotteryCardDlg.ACTION_WANTSTOP then
		self.m_action = LotteryCardDlg.ACTION_DOWN
		local angle = self.m_itemindex*0.2*math.pi - self.m_angle
		self.m_downspeed = LotteryCardDlg.LINE_SPEED / ((12*math.pi + 2*angle)/LotteryCardDlg.LINE_SPEED)
		return
	elseif self.m_action == LotteryCardDlg.ACTION_LINE then
	--[[
		self.m_linetime = self.m_linetime - delta
		if self.m_linetime < 0 then
			self.m_action = LotteryCardDlg.ACTION_DOWN
			local angle = self.m_itemindex*0.2*math.pi - self.m_angle
			self.m_downspeed = LotteryCardDlg.LINE_SPEED / ((12*math.pi + 2*angle)/LotteryCardDlg.LINE_SPEED)
			return
		end
	]]
	elseif self.m_action == LotteryCardDlg.ACTION_WAIT then
		local angle = math.mod(self.m_angle + math.pi*8/180, 2*math.pi) -- 避开[-8, +8]区间
		local angle_l = self.m_itemindex*0.2*math.pi + math.pi*4/180  -- 角度区间 左 (正值)
		local angle_r = angle_l + math.pi*8/180  --角度区间 右(正值)
		if angle > angle_l and angle < angle_r then
			self.m_action = LotteryCardDlg.ACTION_STOP
			self.m_start:setVisible(true)
			return
		end
	end
	self.m_angle = math.mod(math.mod((delta*self.m_speed + self.m_angle), 2*math.pi)+2*math.pi, 2*math.pi)
	self.m_arroweffect:SetRotationRadian(self.m_angle)
--	print("speed = " .. self.m_speed .. "  angle = " .. self.m_angle)
end

return LotteryCardDlg
