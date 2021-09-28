require "Core.Module.Common.UIItem"

WiseEquipInBagItem = class("WiseEquipInBagItem", UIItem);

WiseEquipInBagItem.selectTg = nil;

WiseEquipInBagItem.MESSAGE_WISEEQUIPINBAGITEM_SELECT = "MESSAGE_WISEEQUIPINBAGITEM_SELECT";



function WiseEquipInBagItem:New()
    self = { };
    setmetatable(self, { __index = WiseEquipInBagItem });
    return self
end


function WiseEquipInBagItem:_Init()

    self.product = UIUtil.GetChildByName(self.transform, "Transform", "product");
    self.selectIcon = UIUtil.GetChildByName(self.transform, "UISprite", "selectIcon");
    self.fatIcon = UIUtil.GetChildByName(self.transform, "UISprite", "fatIcon");

    self.txtLev = UIUtil.GetChildByName(self.transform, "UILabel", "txtLev");

    self.productCtr = ProductCtrl:New();
    self.productCtr:Init(self.product, { hasLocke = true, use_sprite = true, iconType = ProductCtrl.IconType_rectangle }, true)
    self.productCtr:SetOnClickBtnHandler(nil)
    self.productCtr:SetOnClickCallBack(WiseEquipInBagItem.ProClick, self);

    self.selectIcon.gameObject:SetActive(false);

    self:UpdateItem(self.data)
end 


function WiseEquipInBagItem:CheckAndSelectOld()

    if WiseEquipInBagItem.select_id == self.data.id then
        self:ProClick();
        return true;
    end
    self.selectIcon.gameObject:SetActive(false);

    return false;
end

function WiseEquipInBagItem:ProClick()

    if self.isJD then

        if WiseEquipInBagItem.selectTg ~= nil and WiseEquipInBagItem.selectTg.selectIcon ~= nil then
            WiseEquipInBagItem.selectTg.selectIcon.gameObject:SetActive(false);
        end
        WiseEquipInBagItem.selectTg = self;
        WiseEquipInBagItem.selectTg.selectIcon.gameObject:SetActive(true);
        WiseEquipInBagItem.select_id = self.data.id;

        MessageManager.Dispatch(WiseEquipInBagItem, WiseEquipInBagItem.MESSAGE_WISEEQUIPINBAGITEM_SELECT, self.data);

    else

        local fairy_lev = self.data:GetLevel();
        local quality = self.data:GetQuality();
        local cf = EquipDataManager.GetFairyGrooveCf(fairy_lev, quality)
        local identify_cost = cf.identify_cost;

        ModuleManager.SendNotification(ConfirmNotes.OPEN_CONFIRM1PANEL, {
            title = LanguageMgr.Get("common/notice"),
            msg = LanguageMgr.Get("WiseEquip/WiseEquipInBagItem/label1",{ n = identify_cost }),

            ok_Label = LanguageMgr.Get("common/ok"),
            cance_lLabel = LanguageMgr.Get("common/cancle"),
            hander = function() WiseEquipPanelProxy.TryWiseEquip_jianding(self.data.id,nil,self.data:GetQuality()) end,
            target = nil,
            data = nil
        } );

    end


end

function WiseEquipInBagItem:SetSelectEQ(eq)
    self.selectEQ = eq;
    self:UpState()
end

function WiseEquipInBagItem:UpState()
    self:UpdateItem(self.data)
end

function WiseEquipInBagItem:UpdateItem(data)
    self.data = data;


    self.productCtr:SetData(data);

    local lv = self.data:GetLevel();
    self.txtLev.text = "Lv." .. lv;

    local kind = self.data:GetKind();

    self.fatIcon.gameObject:SetActive(true);
    self.isJD = self.data:IsHasFairyGroove();
    if not self.isJD then
        self.fatIcon.spriteName = "weiJDIcon";
    else

        local b = EquipDataManager.IsCanFuMoByPro(self.selectEQ, self.data);
        if b then
            self.fatIcon.spriteName = "canFMIcon";

        else
            self.fatIcon.gameObject:SetActive(false);

        end
    end



end




function WiseEquipInBagItem:_Dispose()

    self.productCtr:Dispose();
    self.productCtr = nil;


end



 