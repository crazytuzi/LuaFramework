require "Core.Module.Common.UIItem"
require "Core.Module.Common.ProductCtrl"

EqInBagProductItem = UIItem:New();
 
function EqInBagProductItem:UpdateItem(data)
    self.data = data

end

function EqInBagProductItem:Init(gameObject, data)
    self.data = data
    self.gameObject = gameObject

    self._icon_select = UIUtil.GetChildByName(self.gameObject, "UISprite", "icon_select");
    self._starIcon = UIUtil.GetChildByName(self.gameObject, "Transform", "starIcon");


    self._productCtrl = ProductCtrl:New();

    self._productCtrl:Init(gameObject,{hasLocke=false,use_sprite=true,iconType = ProductCtrl.IconType_rectangle});
    self:UpdateItem(self.data);

    self._productCtrl:SetOnClickBtnHandler(nil);
    self._productCtrl:SetOnClickCallBack(EqInBagProductItem.ClickHandler, self);

    self:Selected(false);

   
     MessageManager.Dispatch(EquipNotes, EquipNotes.MESSAGE_ADDEQINBAGPRODUCTITEM, self);
end

function EqInBagProductItem:ClickHandler(info)
 
     MessageManager.Dispatch(EquipNotes, EquipNotes.MESSAGE_PRODUCTITEMCLICKHANDLER);
end


function EqInBagProductItem:CheckCanSelect()

    local my_id = -1;

    if self._productInfo ~= nil then
        my_id = self._productInfo:GetId();
    end

  

    self:Selected(false);

end

function EqInBagProductItem:Selected(v)
    self._icon_select.gameObject:SetActive(v);
end

--[[
function EqInBagProductItem:SetLock(v)
    self._productCtrl:SetLock(v);
end
]]

function EqInBagProductItem:SetData(productInfo)
    self._productCtrl:SetData(productInfo);
    self._productInfo = productInfo;

    self._starIcon.gameObject:SetActive(false);

    if productInfo ~= nil then
        local quality = productInfo:GetQuality();
        if quality > 4 then
            self:UpdateStar(productInfo);
            self._starIcon.gameObject:SetActive(true);
        end
    end

end

function EqInBagProductItem:UpdateStar(info)

    local star = info:GetStar();

    local icons = { };

    for i = 1, 5 do
        icons[i] = UIUtil.GetChildByName(self._starIcon, "UISprite", "star" .. i);
        icons[i].spriteName = "star2";

        if i <= star then
            icons[i].spriteName = "star3";
            icons[i].gameObject:SetActive(true);
        end

        if star > 5 then
            local ti = star - 5;
            if ti >= i then
                icons[i].spriteName = "star1";
                icons[i].gameObject:SetActive(true);
            end
        end
    end


end

function EqInBagProductItem:_Dispose()
    self.gameObject = nil;
    self._productCtrl:Dispose();
    self._productCtrl = nil;
    self.data = nil;

     self._icon_select = nil;
    self._starIcon = nil;


end