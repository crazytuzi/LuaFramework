---
--- Created by  Administrator
--- DateTime: 2020/7/29 15:18
---
ToemsBuyTip = ToemsBuyTip or class("ToemsBuyTip", WindowPanel)
local this = ToemsBuyTip

function ToemsBuyTip:ctor(parent_node, parent_panel)
    self.abName = "toems"
    self.assetName = "ToemsBuyTip"
    self.layer = "UI"
    self.parentPanel = parent_panel
    self.events = {}
    --ToemsBuyTip.super.Load(self)
    self.items = {};

    self.model = ToemsModel.GetInstance()
    self.schedules = {};
    self.panel_type = 4;
end

function ToemsBuyTip:dctor()
    GlobalEvent:RemoveTabListener(self.events)
    if self.item then
        self.item:destroy();
    end
    self.item = nil
end
function ToemsBuyTip:Open(data)
    self.data = data;
    WindowPanel.Open(self)
end

function ToemsBuyTip:LoadCallBack()
    self.nodes = {
        "contentText", "icon", "sure",
    }
    self:GetChildren(self.nodes)

    self:InitUI()
    self:AddEvent()
    --300006
    self:SetTileTextImage("toems_image", "Toems_title_4");
end

function ToemsBuyTip:InitUI()
    self.contentText = GetText(self.contentText);
    self.sure = GetButton(self.sure);
    local itemConfig = Config.db_item[300006];
    local data = self.data;
    local restrict = String2Table(data.restrict);
    local level = restrict[2];
    local cost = String2Table(self.data.cost)
    local itemID = cost[1];
    local need = cost[2];
    self.item = GoodsIconSettorTwo(self.icon);
    local param = {}
    param["item_id"] = itemID;
    param["can_click"] = true;
    local num = BagModel:GetInstance():GetItemNumByItemID(300006);
    if num >= need then
        --self.item:SetNumText(num .. "/" .. need);
        param["num"] = "<color=#2CA321>"..num .. "</color>/"..need;
    else
        --self.item:SetNumText(num .. "/<color=#ff0000>" .. need .. "</color>");
        param["num"] = "<color=#ff0000>"..num .. "</color>/"..need;
    end

    param["bind"] = true;
    param["size"] = { x = 80, y = 80 }
    self.item:SetIcon(param);

    --self.item:SetData(30015, 0);

    --self.item:ShowTextBg(true);
    self.contentText.text = string.format("Consumes <color=#2CA321>%s</color> to permanently add <color=#2CA321>1 </color> totems\n\n\n\n\n(When Lv<color=#2CA321>%s</color>reached, an additional <color=#2CA321>%s</color> totem assist position can be added)",itemConfig.name,GetLevelShow(tonumber(level)),self.data.slot - 3)
   -- self.contentText.text = "消耗<color=#2CA321>" .. (itemConfig and itemConfig.name or "图腾拓展卡") .. "</color>永久增加<color=#2CA321>1</color>个助战异兽" .. "\n\n\n\n\n" .. "（<color=#2CA321>" .. GetLevelShow(tonumber(level)) .. "</color>级时可额外增加第<color=#2CA321>".. (self.data.slot - 3) .. "</color>个异兽助战位置）"
end

function ToemsBuyTip:AddEvent()
    AddClickEvent(self.sure.gameObject, handler(self, self.HandleAddMaxSummon));
end
function ToemsBuyTip:HandleAddMaxSummon(go, x, y)
    local num = BagModel:GetInstance():GetItemNumByItemID(300006);
    if num > 0 then
        ToemsController:GetInstance():RequesAddSummonInfo();
    else
        Notify.ShowText("Your totem expansion card is insufficient");
    end
    self:Close();
end