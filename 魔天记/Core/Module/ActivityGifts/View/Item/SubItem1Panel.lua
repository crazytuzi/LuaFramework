require "Core.Module.Common.UIComponent"

require "Core.Module.ActivityGifts.View.Item.ActivityGiftsLimitBuyItem"

SubItem1Panel = class("SubItem1Panel", UIComponent);



function SubItem1Panel:New(trs)
    self = { };
    setmetatable(self, { __index = SubItem1Panel });
    if (trs) then
        self:Init(trs)
    end
    return self
end


function SubItem1Panel:_Init()
    self._isInit = false
    self:_InitReference();
    self:_InitListener();
    self:UpdatePanel()
    ActivityGiftsProxy.SendGetLimitBuyInfo()
end

function SubItem1Panel:_InitReference()
    self._item = { }
    self._goItems = { }
    for i = 1, 3 do
        self._goItems[i] = UIUtil.GetChildByName(self._transform, "item" .. i).gameObject
        self._item[i] = ActivityGiftsLimitBuyItem.New(self._goItems[i])
    end

    self._btnOneKeyBuy = UIUtil.GetChildByName(self._transform, "UIButton", "btnOneKeyBuy");

    self._onClickAllBuy = function(go) self:OnClickAllBuy(self) end
    UIUtil.GetComponent(self._btnOneKeyBuy, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickAllBuy);
end

function SubItem1Panel:_InitListener()

end 

function SubItem1Panel:_Dispose()



end

function SubItem1Panel:_DisposeReference()
    UIUtil.GetComponent(self._btnOneKeyBuy, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickAllBuy = nil;

end

function SubItem1Panel:UpdatePanel()
    local datas = ActivityGiftsDataManager.GetLimitBuyInfo()
    local allBuy = true;
    for i = 1, 3 do
        self._item[i]:UpdateItem(datas[i])
        
        if datas[i].num and datas[i].num <= 0 then
            allBuy = false;
        end
    end

    self._btnOneKeyBuy.gameObject:SetActive(allBuy);
end

function SubItem1Panel:OnClickAllBuy()
    VIPManager.SendCharge(12, nil);
end
