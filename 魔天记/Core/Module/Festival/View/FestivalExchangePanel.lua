require "Core.Module.Common.UIComponent"
local FestivalExChangeItem = require "Core.Module.Festival.View.FestivalExChangeItem"
local FestivalExchangePanel = class("FestivalExchangePanel", UIComponent)

function FestivalExchangePanel:New(trs)
    self = { }
    setmetatable(self, { __index = FestivalExchangePanel })
    if (trs) then
        self:Init(trs)
    end
    return self
end
function FestivalExchangePanel:_Init()
    self._isInit = false
    self:_InitReference()
    self:_InitListener()
end
function FestivalExchangePanel:_InitReference()
    self._phalanxInfo = UIUtil.GetChildByName(self._transform, "LuaAsynPhalanx", "scrollView/phalanx")
    self._phalanx = Phalanx:New()
    self._phalanx:Init(self._phalanxInfo, FestivalExChangeItem)
    self._scollview = UIUtil.GetChildByName(self._transform, "UIScrollView", "scrollView")

    local listData = FestivalMgr.GetExchangeConfigs()
    local list_num = table.getn(listData)

    if list_num > 0 then
        self._phalanx:Build(list_num, 1, listData)
    end
    --self:UpdatePanel()
end

function FestivalExchangePanel:_InitListener()
end

function FestivalExchangePanel:_Dispose()
    if (self._phalanx) then
        self._phalanx:Dispose()
        self._phalanx = nil
    end
end

function FestivalExchangePanel:_DisposeReference()
end

function FestivalExchangePanel:UpdatePanel()
    local item = self._phalanx:GetItems()
    local l_num = table.getn(item)
    if l_num > 0 then
        for i = 1, l_num do
            local obj = item[i].itemLogic
            obj:UpdateItem(item[i].data)
        end
    end
end

return FestivalExchangePanel