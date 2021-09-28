require "ui.dialog"
DaXiaZhiLuBtn = {}
setmetatable(DaXiaZhiLuBtn, Dialog)
DaXiaZhiLuBtn.__index = DaXiaZhiLuBtn

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function DaXiaZhiLuBtn.getInstance()
    if not _instance then
        _instance = DaXiaZhiLuBtn:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function DaXiaZhiLuBtn.getInstanceAndShow()
    if not _instance then
        _instance = DaXiaZhiLuBtn:new()
        _instance:OnCreate()
	else
		print("set visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function DaXiaZhiLuBtn.getInstanceNotCreate()
    return _instance
end

function DaXiaZhiLuBtn.DestroyDialog()
	if _instance then 
		_instance:OnClose()		
		_instance = nil
	end
end

function DaXiaZhiLuBtn.ToggleOpenClose()
	if not _instance then 
		_instance = DaXiaZhiLuBtn:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end
function DaXiaZhiLuBtn.GetLayoutFileName()
    return "daxiazhilubtn.layout"
end
function DaXiaZhiLuBtn:OnCreate()
    Dialog.OnCreate(self)
    local winMgr = CEGUI.WindowManager:getSingleton()
	self.button = CEGUI.Window.toPushButton(winMgr:getWindow("daxiazhilubtn/button"))
	self.button:subscribeEvent("Clicked",DaXiaZhiLuBtn.HandleClicked,self)
end

------------------- private: -----------------------------------
function DaXiaZhiLuBtn:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, DaXiaZhiLuBtn)
    return self
end

function DaXiaZhiLuBtn:HandleClicked(args)
	require("manager.luaprotocolmanager"):send(require("protocoldef.knight.gsp.activity.veteran.cmasterroad"):new())
--[[	local p = require "protocoldef.knight.gsp.activity.veteran.smasterroad"
	p.veteran = 1
	p.tasks = {}
	local i = 1
	while i <= 13 do
		p.tasks[i] = {taskid = i,count = 0,reward = 0} 
		i = i + 1
	end
	p:process()]]
end


function DaXiaZhiLuBtn.Check()
    local cfg = BeanConfigManager.getInstance():GetTableByName("knight.gsp.task.croadofhero"):getRecorder(0)
	local STARTTIME = cfg.goal
	local ENDTIME = cfg.award --"2014-05-22 23:59:59"
  --  STARTTIME = "2014-01-25 08:00:01"


	local syear,smonth,sday,shour,sminute,ssecond,eyear,emonth,eday,ehour,eminute,esecond ,startTime,endTime
	syear,smonth,sday,shour,sminute,ssecond = string.match(STARTTIME,"(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)")
	eyear,emonth,eday,ehour,eminute,esecond = string.match(ENDTIME,"(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)")
	startTime = os.time({year=syear,month=smonth,day=sday,hour=shour,min=sminute,sec=ssecond})
	endTime = os.time({year=eyear,month=emonth,day=eday,hour=ehour,min=eminute,sec=esecond})
	if startTime < GetServerTime() / 1000 and GetServerTime() / 1000 < endTime and GetDataManager() and GetDataManager():GetMainCharacterLevel() >= 60 then
        return true
    else
        return false
	end
end

function DaXiaZhiLuBtn.CheckAndShow()
	if DaXiaZhiLuBtn.getInstanceNotCreate() then
		return
	end

	if DaXiaZhiLuBtn.Check() then
        DaXiaZhiLuBtn.getInstanceAndShow()
	--	local pos = DaXiaZhiLuBtn.getInstance():GetWindow():getPosition()
	--	DaXiaZhiLuBtn.getInstance():GetWindow():setPosition(CEGUI.UVector2(CEGUI.UDim(pos.x.scale, pos.x.offset+56),CEGUI.UDim(pos.y.scale, pos.y.offset+56)))
	end
end


function DaXiaZhiLuBtn.CheckAndHide()
	if not DaXiaZhiLuBtn.getInstanceNotCreate() then
		return
	end

	if not DaXiaZhiLuBtn.Check() then
        DaXiaZhiLuBtn.DestroyDialog()
	end
end


return DaXiaZhiLuBtn
