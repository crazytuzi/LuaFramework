require "ui.dialog"

local TotalDamageDlg = {}
setmetatable(TotalDamageDlg, Dialog)
TotalDamageDlg.__index = TotalDamageDlg

TotalDamageDlg.eIncreaseTick = 700
TotalDamageDlg.eTotalTick = 1000

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function TotalDamageDlg.getInstance()
    if not _instance then
        _instance = TotalDamageDlg:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function TotalDamageDlg.getInstanceAndShow()
    if not _instance then
        _instance = TotalDamageDlg:new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end
    
    return _instance
end

function TotalDamageDlg.getInstanceNotCreate()
    return _instance
end

function TotalDamageDlg.DestroyDialog()
	if _instance then 
		_instance:OnClose()
		_instance = nil
	end
end

function TotalDamageDlg.ToggleOpenClose()
	if not _instance then 
		_instance = TotalDamageDlg:new() 
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

function TotalDamageDlg.GetLayoutFileName()
    return "battlenumber.layout"
end

function TotalDamageDlg:OnCreate()
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
	self.m_num = winMgr:getWindow("battlenumber/num")
	self.m_num:setVisible(false)
end

------------------- private: -----------------------------------

function TotalDamageDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, TotalDamageDlg)
	self.m_totledamage = -1
	self.m_showdamage = 0
	self.m_iTick = 0
    return self
end

function TotalDamageDlg:run(delta)
	if self:IsVisible() == false then
		return
	end
	if self.m_totledamage == -1 then
		self:SetVisible(false)
		self.m_num:setVisible(false)
		return
	end
	self.m_iTick = self.m_iTick + delta
	if self.m_iTick > TotalDamageDlg.eTotalTick then
		self.m_totledamage = -1
		return
	end
	--self.m_showdamage = self.m_totledamage * self.m_iTick / TotalDamageDlg.eIncreaseTick
	self.m_showdamage = self.m_totledamage * (math.pow(self.m_iTick / TotalDamageDlg.eIncreaseTick, 3))
	if self.m_showdamage > self.m_totledamage then
		self.m_showdamage = self.m_totledamage
	end
	self:shownum(self.m_showdamage)
end

function TotalDamageDlg:shownum(num)
	num = math.floor(num)
	self.m_num:setText(tostring(num))
	self.m_num:setVisible(true)
end

function TotalDamageDlg:setDamage(damage)
	self.m_showdamage = 0
	-- 加血是正值，掉血是负值
	self.m_totledamage = math.abs(damage)
	self.m_iTick = 0
	self:SetVisible(true)
end

return TotalDamageDlg
