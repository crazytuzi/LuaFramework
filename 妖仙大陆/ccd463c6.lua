


local Util = require "Zeus.Logic.Util"
local _M = {
    minValue = nil,maxValue = nil,value = nil,funcClickCallback = nil,funcCloseCallback = nil,firstOpen = nil
}
_M.__index = _M

local ui_names = {
    {name = "btn_numbox_delete",click = function(self)
        self.value = math.floor(self.value/10)
        if self.funcClickCallback then
            self.funcClickCallback(self.value)
        end
    end},
    {name = "btn_numboxfix",click = function(self)
        if self.value < self.minValue then
            self.value = self.minValue
        end
        if self.funcClickCallback then
            self.funcClickCallback(self.value)
        end
        if self.funcCloseCallback then
            self.funcCloseCallback(self.value)
        end
        self.menu:Close()
    end},
    {name = "cvs_numberbox"}
}

function _M:SetValue(min,max,initValue,funcClickCallback,funcCloseCallback,tipMax)
    self.minValue = min
    self.maxValue = max
    self.value = initValue
    self.funcClickCallback = funcClickCallback
    self.funcCloseCallback = funcCloseCallback
    self.tipMax = tipMax
    self.firstOpen = true
end

function _M:click(index)
    if self.firstOpen then
        self.value = index
    else
        self.value = self.value * 10 + index
    end
    if self.value > self.maxValue then
        self.value = self.maxValue
        if self.tipMax then
            GameAlertManager.Instance:ShowNotify(self.tipMax)
        end
    end
    if self.funcClickCallback then
        self.funcClickCallback(self.value)
    end
    self.firstOpen = false
end

function _M:SetPos(pos)
    self.cvs_numberbox.X = pos.X
    self.cvs_numberbox.Y = pos.Y
end

function InitComponent(self,tag)
    self.menu = LuaMenuU.Create('xmds_ui/common/numberbox.gui.xml',tag)
    self.menu.Enable = true
    Util.CreateHZUICompsTable(self.menu, ui_names, self)
    self.menu.CacheLevel = -1
	self.menu.ShowType = UIShowType.Cover
    self.menu.event_PointerClick = function()
        if self.value < self.minValue then
            self.value = self.minValue
        end
        if self.funcClickCallback then
            self.funcClickCallback(self.value)
        end
        if self.funcCloseCallback then
            self.funcCloseCallback(self.value)
        end
        self.menu:Close()
    end
    for i = 0,9,1 do
        local btn = self.cvs_numberbox:FindChildByEditName("btn_numbox"..i,false)
        btn.event_PointerClick = function()
            self:click(i)
        end
    end
end

function _M.Create(tag)
    local ret = {}
    setmetatable(ret,_M)
    InitComponent(ret,tag)
    return ret
end

return _M

