require "Core.Module.Common.UIItem"


YaoQingPiPeiItem = class("YaoQingPiPeiItem", UIItem);


YaoQingPiPeiItem.MESSAGE_YAOQINGPIPEIITEM_SELECTED_CHANGE = "MESSAGE_YAOQINGPIPEIITEM_SELECTED_CHANGE";

YaoQingPiPeiItem.currSelect = nil;

function YaoQingPiPeiItem:New()
    self = { };
    setmetatable(self, { __index = YaoQingPiPeiItem });
    return self
end
 

function YaoQingPiPeiItem:UpdateItem(data)
    self.data = data
end

function YaoQingPiPeiItem:Init(gameObject, data)

    self.gameObject = gameObject;

    self.fbtxtTitle = UIUtil.GetChildByName(self.gameObject, "UILabel", "fbtxtTitle");

    self.icoSelect = UIUtil.GetChildByName(self.gameObject, "UISprite", "icoSelect");
    self.icoSelect.gameObject:SetActive(false);
    self:SetData(data);


    self._onClickBtn = function(go) self:_OnClickBtn(self) end
    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn);


end

function YaoQingPiPeiItem:SetActive(v)
    self.gameObject.gameObject:SetActive(v);
end


function YaoQingPiPeiItem:SetData(data)

    self.data = data;
    self.fbtxtTitle.text = data.name;

end

function YaoQingPiPeiItem:CheckSelect(selectData, min_lv, max_lv)

    if self.data.id == selectData.id then
        self.selectInfo = { min_lv = min_lv, max_lv = max_lv };
        self.tnum = 3;
        UpdateBeat:Add(self.TrySetselect, self)

    end

end

function YaoQingPiPeiItem:TrySetselect()

    self.tnum = self.tnum - 1;

    if self.tnum <= 0 then
        self:_OnClickBtn();
        UpdateBeat:Remove(self.TrySetselect, self);
        self.selectInfo = nil;
    end

end


function YaoQingPiPeiItem:_OnClickBtn()

    if YaoQingPiPeiItem.currSelect ~= nil then
        YaoQingPiPeiItem.currSelect.icoSelect.gameObject:SetActive(false);
    end

    YaoQingPiPeiItem.currSelect = self;
    YaoQingPiPeiItem.currSelect.icoSelect.gameObject:SetActive(true);
    
    if YaoQingPiPeiTypeItem.typeItemSelectIcon ~= nil then
      YaoQingPiPeiTypeItem.typeItemSelectIcon.gameObject:SetActive(false);
    end

    YaoQingPiPeiTypeItem.typeItemSelectIcon = YaoQingPiPeiTypeItem.currSelect.icoSelect;
     YaoQingPiPeiTypeItem.typeItemSelectIcon.gameObject:SetActive(true);

    MessageManager.Dispatch(YaoQingPiPeiItem, YaoQingPiPeiItem.MESSAGE_YAOQINGPIPEIITEM_SELECTED_CHANGE, self);

end


function YaoQingPiPeiItem:_Dispose()

     UpdateBeat:Remove(self.TrySetselect, self);
    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");

    self.gameObject = nil;


end