require "Core.Module.Equip.Item.ProductDressPanelItem"

EquipDressTipPanelControll = class("EquipDressTipPanelControll")
function EquipDressTipPanelControll:New()
    self = { };
    setmetatable(self, { __index = EquipDressTipPanelControll });
    return self;
end


function EquipDressTipPanelControll:Init(gameObject)
    self.gameObject = gameObject;

    local _ScrollView = UIUtil.GetChildByName(self.gameObject, "Transform", "ScrollView");
    self.pd_phalanx = UIUtil.GetChildByName(_ScrollView, "LuaAsynPhalanx", "pd_phalanx");
    self.product_pd_phalanx = Phalanx:New();
    self.product_pd_phalanx:Init(self.pd_phalanx, ProductDressPanelItem);

    self:Hide();

    MessageManager.AddListener(EquipProxy, EquipProxy.MESSAGE_EQUIP_DRESSCOMPLETE, self.DressSuccess, self);
    MessageManager.AddListener(EquipNotes, EquipNotes.MESSAGE_EQUIPDRESSTIPPANELCONTROLL_SHOW, self.Show, self);
    MessageManager.AddListener(EquipNotes, EquipNotes.MESSAGE_EQUIPDRESSTIPPANELCONTROLL_HIDE, self.Hide, self);
    MessageManager.AddListener(EquipNotes, EquipNotes.MESSAGE_EQUIPDRESSTIPPANELCONTROLL_UPDATA, self.UpData, self);

end


function EquipDressTipPanelControll:Show()

    SetUIEnable(self.gameObject, true);

end

function EquipDressTipPanelControll:Hide()
    SetUIEnable(self.gameObject, false);
end

function EquipDressTipPanelControll:UpData(eqs)

    local t_num = table.getn(eqs);
    self.product_pd_phalanx:Build(t_num, 1, eqs);

end

function EquipDressTipPanelControll:DressSuccess(index)

    if self.product_pd_phalanx ~= nil then
        local items = self.product_pd_phalanx._items;

        for key, value in pairs(items) do

            local tg = value.itemLogic;
            if tg.index == index then
                tg:SetActive(false);
                return;
            end
        end
    end


end




function EquipDressTipPanelControll:Dispose()

    MessageManager.RemoveListener(EquipProxy, EquipProxy.MESSAGE_EQUIP_DRESSCOMPLETE, self.DressSuccess, self);
    MessageManager.RemoveListener(EquipNotes, EquipNotes.MESSAGE_EQUIPDRESSTIPPANELCONTROLL_SHOW, self.Show, self);
    MessageManager.RemoveListener(EquipNotes, EquipNotes.MESSAGE_EQUIPDRESSTIPPANELCONTROLL_HIDE, self.Hide, self);
    MessageManager.RemoveListener(EquipNotes, EquipNotes.MESSAGE_EQUIPDRESSTIPPANELCONTROLL_UPDATA, self.UpData, self);


    if self.product_pd_phalanx ~= nil then
        self.product_pd_phalanx:Dispose();
        self.product_pd_phalanx = nil;
    end
    self.gameObject = nil;
    self.pd_phalanx = nil;
end
