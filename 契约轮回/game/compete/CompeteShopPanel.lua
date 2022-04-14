---
--- Created by  Administrator
--- DateTime: 2019/11/22 10:12
---
CompeteShopPanel = CompeteShopPanel or class("CompeteShopPanel", WindowPanel)
local this = CompeteShopPanel

function CompeteShopPanel:ctor(parent_node, parent_panel)
    self.abName = "compete"
    self.assetName = "CompeteShopPanel"
    self.layer = LayerManager.LayerNameList.UI
    self.use_background = true
    self.change_scene_close = true
    self.panel_type = 2;
    self.events = {}
    self.gevents = {}
    self.items = {}
    self.model = CompeteModel:GetInstance()
end

function CompeteShopPanel:dctor()
    GlobalEvent:RemoveTabListener(self.gevents)
    self.model:RemoveTabListener(self.events)
    if self.items then
        for i, v in pairs(self.items) do
            v:destroy()
        end
        self.items = {}
    end
end

function CompeteShopPanel:LoadCallBack()
    self.nodes = {
        "moneyObj/moneyText","moneyObj/moneyName","ScrollView/Viewport/leftContent","CompeteShopItem","moneyObj/moneyIcon",
    }
    self:GetChildren(self.nodes)
    self.moneyText = GetText(self.moneyText)
    self.moneyName = GetText(self.moneyName)
    self.moneyIcon = GetImage(self.moneyIcon)
    self:InitUI()
    self:AddEvent()
    self:SetTileTextImage("compete_image", "compete_title2");
end

function CompeteShopPanel:InitUI()
    local iconName = Config.db_item[enum.ITEM.ITEM_ARENA_MONEY].icon
    GoodIconUtil:CreateIcon(self, self.moneyIcon, iconName, true)
    local money =  RoleInfoModel:GetInstance():GetRoleValue(Constant.GoldType.CompeteScore)
    self.moneyText.text = money
    self.moneyName.text = "Ring Coin"

    local items = self.model:GetShopItems()
    local function sort_func(a, b)
        return a.order < b.order
    end
    table.sort(items, sort_func)
    for i = 1, #items do
        local item = self.items[i]
        if not item then
            item = CompeteShopItem(self.CompeteShopItem.gameObject,self.leftContent,"UI")
            self.items[i] = item
        end
        item:SetData(items[i])
    end
end

function CompeteShopPanel:AddEvent()
    self.gevents[#self.gevents] = GlobalEvent:AddListener(ShopEvent.SuccessToBuyGoodsInShop,handler(self,self.SuccessToBuyGoodsInShop))
end

function CompeteShopPanel:SuccessToBuyGoodsInShop()
    local money =  RoleInfoModel:GetInstance():GetRoleValue(Constant.GoldType.CompeteScore)
    self.moneyText.text = money
end