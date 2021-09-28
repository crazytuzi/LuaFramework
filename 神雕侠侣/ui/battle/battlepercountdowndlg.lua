require "ui.dialog"

local BattlePerCountDownDlg = {}
setmetatable(BattlePerCountDownDlg, Dialog)
BattlePerCountDownDlg.__index = BattlePerCountDownDlg

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function BattlePerCountDownDlg.getInstance()
    if not _instance then
        _instance = BattlePerCountDownDlg:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function BattlePerCountDownDlg.getInstanceAndShow()
    if not _instance then
        _instance = BattlePerCountDownDlg:new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end
    
    return _instance
end

function BattlePerCountDownDlg.getInstanceNotCreate()
    return _instance
end

function BattlePerCountDownDlg.DestroyDialog()
	if _instance then 
		_instance:OnClose()
		_instance = nil
	end
end

function BattlePerCountDownDlg.ToggleOpenClose()
	if not _instance then 
		_instance = BattlePerCountDownDlg:new() 
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

function BattlePerCountDownDlg.GetLayoutFileName()
    return "battlecount.layout"
end

function BattlePerCountDownDlg:OnCreate()
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
	self.m_wait = winMgr:getWindow("battlecount/wait")
	self.m_num = winMgr:getWindow("battlecount/num")

	self.m_wait:setVisible(false)
	self.m_num:setVisible(false)
end

------------------- private: -----------------------------------

function BattlePerCountDownDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, BattlePerCountDownDlg)
	self.m_count = -3
    return self
end

function BattlePerCountDownDlg:run(delta)
	delta = delta/1000
	if self.m_count < -2 then
		return
	end
	if self.m_count == -2 then
		self.m_wait:setVisible(false)
		self.m_num:setVisible(false)
		self.m_count = self.m_count -1
		return
	end
	if self.m_count == -1 then
		self.m_wait:setVisible(true)
		self.m_num:setVisible(false)
		return
	end
	local temp = math.ceil(self.m_count)
	self.m_count = self.m_count - delta
	if self.m_count < -0.1 then
		self.m_count = -1
		return
	end
	if temp ~= math.ceil(self.m_count) then
		self.m_num:setText(tostring(math.ceil(self.m_count)))
	end
end

function BattlePerCountDownDlg:setCount(count)
	self.m_count = count
	if self.m_count >=0 then
		self.m_num:setText(tostring(self.m_count))
		self.m_num:setVisible(true)
	end
end

return BattlePerCountDownDlg
