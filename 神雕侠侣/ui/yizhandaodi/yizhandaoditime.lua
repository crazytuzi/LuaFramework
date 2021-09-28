require "ui.dialog"

YiZhanDaoDiTimeDlg = {}
setmetatable(YiZhanDaoDiTimeDlg, Dialog)
YiZhanDaoDiTimeDlg.__index = YiZhanDaoDiTimeDlg

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function YiZhanDaoDiTimeDlg.getInstance()
	-- print("enter get YiZhanDaoDiTimeDlg dialog instance")
    if not _instance then
        _instance = YiZhanDaoDiTimeDlg:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function YiZhanDaoDiTimeDlg.getInstanceAndShow()
	-- print("enter YiZhanDaoDiTimeDlg dialog instance show")
    if not _instance then
        _instance = YiZhanDaoDiTimeDlg:new()
        _instance:OnCreate()
	else
		-- print("set YiZhanDaoDiTimeDlg dialog visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function YiZhanDaoDiTimeDlg.getInstanceNotCreate()
    return _instance
end

function YiZhanDaoDiTimeDlg.DestroyDialog()
	if _instance then 
		_instance:OnClose()
		_instance = nil
	end
end

function YiZhanDaoDiTimeDlg.ToggleOpenClose()
	if not _instance then 
		_instance = YiZhanDaoDiTimeDlg:new() 
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

function YiZhanDaoDiTimeDlg.GetLayoutFileName()
    return "yizhandaoditime.layout"
end

function YiZhanDaoDiTimeDlg:OnCreate()
	-- print("YiZhanDaoDiTimeDlg dialog oncreate begin")
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
	self.m_pTime = winMgr:getWindow("Yizhandaoditime/text/text1")
	self.m_pNum  = winMgr:getWindow("Yizhandaoditime/text1/text1")

    -- subscribe event
	self:GetWindow():subscribeEvent("WindowUpdate", YiZhanDaoDiTimeDlg.HandleWindowUpdate, self)

	-- print("YiZhanDaoDiTimeDlg dialog oncreate end")
end

------------------- private: -----------------------------------


function YiZhanDaoDiTimeDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, YiZhanDaoDiTimeDlg)
	self.m_time = 10
    return self
end

function YiZhanDaoDiTimeDlg:Refresh(time, num)
	-- print("YiZhanDaoDiTimeDlg:Refresh time = " .. tostring(time))
	self.m_time = time/1000
	if time <= 0 then
		YiZhanDaoDiTimeDlg.DestroyDialog()
	else
		self.m_pTime:setText(tostring(math.floor(time/1000)))
		self.m_pNum:setText(tostring(num))
	end
end

function YiZhanDaoDiTimeDlg:HandleWindowUpdate(args)
	if GetScene():GetMapID() ~= 1569 then
		YiZhanDaoDiTimeDlg.DestroyDialog()
		return
	end
	local time = CEGUI.toUpdateEventArgs(args).d_timeSinceLastFrame
	local t1 = math.floor(self.m_time)
	self.m_time = self.m_time - time
	local t2 = math.floor(self.m_time)
	if self.m_time <= 0 then
		YiZhanDaoDiTimeDlg.DestroyDialog()
		return
	end
	if t1 == t2 then
		return
	end
	-- print("YiZhanDaoDiTimeDlg:HandleWindowUpdate time = " .. self.m_time)
	self.m_pTime:setText(math.floor(self.m_time))
	if math.fmod(math.floor(self.m_time), 5) == 1 then
		local CCountdown = require "protocoldef.knight.gsp.activity.yzdd.ccountdown"
		local req = CCountdown.Create()
		LuaProtocolManager.getInstance():send(req)
	end
end

return YiZhanDaoDiTimeDlg
