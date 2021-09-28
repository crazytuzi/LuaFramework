require "Core.Module.Common.UIComponent"
local FestivalChargeItem = require "Core.Module.Festival.View.FestivalChargeItem"
local FestivalChargePanel = class("FestivalChargePanel", UIComponent)

function FestivalChargePanel:New(trs)
    self = { }
    setmetatable(self, { __index = FestivalChargePanel })
    if (trs) then
        self:Init(trs)
    end
    return self
end
function FestivalChargePanel:_Init()
    self._isInit = false
    self:_InitReference()
    self:_InitListener()
end
function FestivalChargePanel:_InitReference()
    self._phalanxInfo = UIUtil.GetChildByName(self._transform, "LuaAsynPhalanx", "scrollView/phalanx")
    self._phalanx = Phalanx:New()
    self._phalanx:Init(self._phalanxInfo, FestivalChargeItem)
    self._scollview = UIUtil.GetChildByName(self._transform, "UIScrollView", "scrollView")
    self.btncharge = UIUtil.GetChildByName(self._transform, "UIButton", "btncharge")

    local listData = FestivalMgr.GetMidRechargeConfigs()
    local list_num = table.getn(listData)
    for i = 1, list_num do
        local c = listData[i]
        c.st = FestivalMgr.GetChargeState(c.id, c.param2)
    end
    table.sort(listData, function(a, b)
        local as = a.st
        local bs = b.st
        if as == 2 and bs ~= 2 then return false
        elseif as ~= 2 and bs == 2 then return true end
        return a.id < b.id
    end)
    if list_num > 0 then
        self._phalanx:Build(list_num, 1, listData)
    end
    --self:UpdatePanel()
end

function FestivalChargePanel:_InitListener()
    self._onClickBtncharge = function(go) self:_OnClickBtncharge() end
    UIUtil.GetComponent(self.btncharge, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtncharge)
end

function FestivalChargePanel:_OnClickBtncharge()
    ModuleManager.SendNotification(FestivalNotes.CLOSE_FESTIVAL_PANEL)
    --ModuleManager.SendNotification(MallNotes.OPEN_MALLPANEL, { val = 3 })
    ModuleManager.SendNotification(ActivityGiftsNotes.OPEN_ACTIVITYGIFTSPANEL,{code_id=3 })
end

function FestivalChargePanel:_Dispose()
    UIUtil.GetComponent(self.btncharge, "LuaUIEventListener"):RemoveDelegate("OnClick")
    self._onClickBtncharge = nil
    if (self._phalanx) then
        self._phalanx:Dispose()
        self._phalanx = nil
    end
end

function FestivalChargePanel:_DisposeReference()
end

function FestivalChargePanel:UpdatePanel()
    local item = self._phalanx:GetItems()
    local l_num = table.getn(item)
    if l_num > 0 then
        for i = 1, l_num do
            local obj = item[i].itemLogic
            obj:UpdateItem(obj.data)
        end
    end
end

return FestivalChargePanel