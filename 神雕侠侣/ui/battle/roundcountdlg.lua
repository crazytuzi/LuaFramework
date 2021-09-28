require "ui.dialog"

local RoundCountDlg = {}
setmetatable(RoundCountDlg, Dialog)
RoundCountDlg.__index = RoundCountDlg

RoundCountDlg.eAlphaTime = 1200

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function RoundCountDlg.getInstance()
    if not _instance then
        _instance = RoundCountDlg:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function RoundCountDlg.getInstanceAndShow()
    if not _instance then
        _instance = RoundCountDlg:new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end
    
    return _instance
end

function RoundCountDlg.getInstanceNotCreate()
    return _instance
end

function RoundCountDlg.DestroyDialog()
	if _instance then 
		_instance:OnClose()
		_instance = nil
	end
end

function RoundCountDlg.ToggleOpenClose()
	if not _instance then 
		_instance = RoundCountDlg:new() 
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

function RoundCountDlg.GetLayoutFileName()
    return "huihecount.layout"
end

function RoundCountDlg:OnCreate()
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
	self.m_num = winMgr:getWindow("huihecount/num")
	self.m_num:setVisible(false)
end

------------------- private: -----------------------------------

function RoundCountDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, RoundCountDlg)
	self.m_RoundCount = 1
	self.m_Tick = 0
    return self
end

function RoundCountDlg:run(delta)
	if self.m_Tick > RoundCountDlg.eAlphaTime then
		return
	end
	self.m_Tick = self.m_Tick + delta
	local alpha = 1* (self.m_Tick/RoundCountDlg.eAlphaTime)
	if alpha > 1 then
		alpha = 1
	end
	for i=0, 2 do
		self.m_num:setAlpha(alpha);
	end
end

function RoundCountDlg:showRoundCount(roundcount)
	self.m_num:setAlpha(0);
	self.m_num:setText(tostring(roundcount))
	self.m_num:setVisible(true)
end

function RoundCountDlg:changeRoundCount(roundcount)
	self.m_Tick = 0
	self.m_RoundCount = roundcount
	self:showRoundCount(self.m_RoundCount)
end

return RoundCountDlg
