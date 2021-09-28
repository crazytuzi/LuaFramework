require "Core.Module.Common.UIComponent"
require "Core.Module.Mall.View.Item.SubMallVIPListItem"

SubGongXunCoinPanel = class("SubGongXunCoinPanel", UIComponent);
function SubGongXunCoinPanel:New(trs)
    self = { };
    setmetatable(self, { __index = SubGongXunCoinPanel });
    if (trs) then
        self:Init(trs)
    end
    return self
end


function SubGongXunCoinPanel:_Init()
    self:_InitReference();
    self:_InitListener();
end

function SubGongXunCoinPanel:_InitReference()
    self._phalanxInfo = UIUtil.GetChildByName(self._transform, "LuaAsynPhalanx", "scrollView/itemPhalanx")
    self._phalanx = Phalanx:New()
    self._scrollView = UIUtil.GetChildByName(self._transform, "UIScrollView", "scrollView")

    self._phalanx:Init(self._phalanxInfo, SubMallVIPListItem)

    self._centerOnChild = UIUtil.GetChildByName(self._transform, "UICenterOnChild", "scrollView/itemPhalanx")
    self._currentGo = nil
    self._delegate = function(go) self:_OnCenterCallBack(go) end
    self._centerOnChild.onCenter = self._delegate

    self._pagePhalanxInfo = UIUtil.GetChildByName(self._transform, "LuaAsynPhalanx", "pagePhalanx");
    self._pagePhalanx = Phalanx:New();
    self._pagePhalanx:Init(self._pagePhalanxInfo, CommonPageItem, true)

   

end

function SubGongXunCoinPanel:_OnCenterCallBack(go)
    if (go) then
        if (self._currentGo == go) then
            return
        end
        self._currentGo = go

        local index = self._phalanx:GetItemIndex(go)
        local item = self._pagePhalanx:GetItem(index)
        if (item) then
            item.itemLogic:SetToggle(true)
            self._phalanx:GetItem(index).itemLogic:SetItemToggle(1, true)
        end
    end
end



function SubGongXunCoinPanel:_InitListener()
end

function SubGongXunCoinPanel:_Dispose()
    self:_DisposeReference();
    self._scrollView = nil
end

function SubGongXunCoinPanel:_DisposeReference()
    self._phalanx:Dispose()
    self._phalanx = nil

    

    self._delegate = nil;
    if self._centerOnChild and self._centerOnChild.onCenter then
        self._centerOnChild.onCenter:Destroy();
    end
end

function SubGongXunCoinPanel:UpdatePanel()
    local data = MallManager.GetItemDatas(3)

    if (data and table.getCount(data) > 0) then
        local tempdata = { }
        local index = 1
        local count = 1
        for k, v in ipairs(data) do
            if (count > 8) then
                index = index + 1
                count = 1
            end

            if (tempdata[index] == nil) then
                tempdata[index] = { }
            end
            tempdata[index][count] = v
            count = count + 1
            if v.id==800 then
             PrintTable(v);
            end 
           
        end

        self._phalanx:Build(1, table.getCount(tempdata), tempdata)
        self._pagePhalanx:BuildSpe(table.getCount(tempdata), { })
        local cur = MallManager.GetCurrentSelectItemInfo()
        if ((not table.contains(data, cur)) or(cur == nil)) then
            local item = self._phalanx:GetItem(1)
            if (item) then
                item.itemLogic:SetItemToggle(1, true)
                self._pagePhalanx:GetItem(1).itemLogic:SetToggle(true)
                self._currentGo = item.gameObject
            end
        end
    else
       MallProxy.SendGetMallItem(3)
    end
end

function SubGongXunCoinPanel:ResetScrollView()
    self._scrollView:ResetPosition()
end