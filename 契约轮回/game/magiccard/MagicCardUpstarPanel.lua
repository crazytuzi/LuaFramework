---魔法卡升星页
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by win 10.
--- DateTime: 18/12/04 16:18
---
MagicCardUpstarPanel = MagicCardUpstarPanel or class("MagicCardUpstarPanel", BaseItem)
local this = MagicCardUpstarPanel

function MagicCardUpstarPanel:ctor(parent_node)
    self.abName = "magiccard";
    self.image_ab = "magiccard_image";
    self.assetName = "MagicCardUpstarPanel"
    self.layer = "UI"
    self.currentSelectItem = nil;
    self.model = CardModel.GetInstance()
    self.events = {};
    self.schedules = {};
    MagicCardUpstarPanel.super.Load(self);
    --DungeonCtrl:GetInstance().MagicCardUpstarPanel = self;
end

function MagicCardUpstarPanel:dctor()
    self.model = nil;

    GlobalEvent:RemoveTabListener(self.events);
    self:StopAllSchedules()

    destroyTab(self.items);
    self.items = nil;
    self.currentSelectItem = nil;

    destroyTab(self.awardItems);
    self.awardItems = {};

    if self.currItem then
        self.currItem:destroy();
    end
    self.currItem = nil;

    if self.nextItem then
        self.nextItem:destroy();
    end
    self.nextItem = nil;
end

function MagicCardUpstarPanel:LoadCallBack()
    self.nodes = {
        "card_prop/currprop", "ScrollView/Viewport/Content", "card_prop/nextprop", "upstar_btn", "awardcon", "us_item",
        "max_star", "max_star_2",
    }
    self:GetChildren(self.nodes)

    SetLocalPosition(self.transform, 0, 0, 0)

    self:InitUI();

    self:AddEvent();
end

function MagicCardUpstarPanel:InitUI()
    self.currItem = MagicCardUpstarPropItem(self.currprop);
    self.nextItem = MagicCardUpstarPropItem(self.nextprop);
    self.upstar_btn = GetButton(self.upstar_btn);

    self.max_star = GetImage(self.max_star);
    self.max_star_2 = GetImage(self.max_star_2);
    SetGameObjectActive(self.max_star);
    SetGameObjectActive(self.max_star_2);
    self:InitTogs();
end

function MagicCardUpstarPanel:InitTogs()
    local tab = CardModel.GetInstance().EmbedCards;--在身上的所有的卡片
    SetGameObjectActive(self.us_item.gameObject, true);
    destroyTab(self.items);
    self.items = {};
    local index = 1;
    local pos = 0;
    if self.currentSelectItem then
        pos = self.currentSelectItem.pos;
    end
    for i = 1, 8, 1 do
        if tab[i] then
            local cardId = tab[i].id;
            local itemConfig = Config.db_item[cardId];
            if itemConfig.color >= 4 then
                local item = UpstarScrollItem(newObject(self.us_item), tab[i]);
                item.pos = i;
                self.items[index] = item;
                if pos == i then
                    self.currentSelectItem = item;
                end
                item.gameObject.name = "UpstarScrollItem_" .. index;
                item:SetIsSelected(false);
                item.transform:SetParent(self.Content.transform);
                local redTab = self.model.red_dot_list[2];
                if redTab and redTab[2][cardId] then
                    item:SetRedDotParam(true);
                else
                    item:SetRedDotParam(false);
                end
                SetLocalPosition(item.transform, 0, 0, 0);
                SetLocalScale(item.transform, 1, 1, 1)
                AddClickEvent(item.gameObject, handler(self, self.HandleSelectItem, item));
                index = index + 1;
            end
        end
    end
    local rt = GetRectTransform(self.Content);
    rt.sizeDelta = Vector2(rt.sizeDelta.x, #self.items * 110);

    if #self.items > 0 then
        if self.currentSelectItem ~= nil then
            self:HandleSelectItem(nil, nil, nil, self.currentSelectItem);
        else
            self:HandleSelectItem(nil, nil, nil, self.items[1]);
        end
    end

    SetGameObjectActive(self.us_item.gameObject, false);
end

function MagicCardUpstarPanel:AddEvent()
    AddClickEvent(self.upstar_btn.gameObject, handler(self, self.HandleUpstar));

    --for k, v in pairs(self.items) do
    --    AddClickEvent(v.gameObject, handler(self, self.HandleSelectItem, k));
    --end
    AddEventListenerInTab(CardEvent.CARD_UP_STAR, handler(self, self.HandleUpStarRefresh), self.events);

    AddEventListenerInTab(CardEvent.CARD_LIST, handler(self, self.HandleCardList), self.events);

    local updateGoods = function()
        if self.currentSelectItem then
            self:RefreshProps(self.currentSelectItem);
        end
    end
    AddEventListenerInTab(CardEvent.CARD_BAG_EVENT, updateGoods, self.events);
    AddEventListenerInTab(CardEvent.ADD_CARD, updateGoods, self.events);
    AddEventListenerInTab(CardEvent.DELETE_CARD, updateGoods, self.events);
    AddEventListenerInTab(BagEvent.UpdateGoods, updateGoods, self.events);
end

function MagicCardUpstarPanel:HandleCardList(cards)
    if cards then
        if not self.items or #self.items == 0 then
            self:InitTogs()
        else
            for i = 1, #self.items do
                for k, v in pairs(cards) do
                    if self.items[i].data and self.items[i].data.uid == v.uid then
                        self.items[i]:SetDataAndRefresh(v);
                    end
                end
            end
            if self.currentSelectItem then
                self:RefreshProps(self.currentSelectItem);
            end

        end
    end
end

--@ling autofun
function MagicCardUpstarPanel:HandleSelectItem(go, x, y, v)
    if self.currentSelectItem then
        self.currentSelectItem:SetIsSelected(false);
    end
    self.currentSelectItem = v;
    self.currentSelectItem:SetIsSelected(true);
    self:RefreshProps(self.currentSelectItem);
end
function MagicCardUpstarPanel:RefreshProps(item)
    local data = item.data;
    local cardConfig = Config.db_magic_card[data.id];
    if data then
        self.currItem:RefreshProps(cardConfig, data);
    end
    local nextConfig = Config.db_magic_card[cardConfig.next_star];
    if not nextConfig or item.data.star == cardConfig.max_star then
        SetGameObjectActive(self.upstar_btn, false);
        self.nextItem:RefreshProps(cardConfig, data);
        self.nextItem:SetIsMaxStar(true);
        SetGameObjectActive(self.max_star, true);
        SetGameObjectActive(self.max_star_2, true);
        SetGameObjectActive(self.awardcon);
    else
        SetGameObjectActive(self.awardcon , true);
        SetGameObjectActive(self.upstar_btn, true);
        SetGameObjectActive(self.max_star, false);
        SetGameObjectActive(self.max_star_2, false);
        self.nextItem:SetIsMaxStar(false);
        self.nextItem:RefreshProps(nextConfig, data);
        --更新升星所需材料,有时间可以做优化,只刷新数据,不析构
        destroyTab(self.awardItems);
        self.awardItems = {};
        local costTab = String2Table(cardConfig.cost);
        for i = 1, #costTab, 1 do
            local tab = costTab[i];
            local awarditem = AwardItem(self.awardcon);
            local num = CardModel:GetInstance():GetItemNumByItemID(tab[1])--BagModel:GetInstance():GetItemNumByItemID(costTab[1]);
            awarditem:SetData(tab[1], 0);
            if num >= tab[2] then
                awarditem:SetNumText(tostring(num) .. "/" .. tonumber(tab[2]));
            else
                awarditem:SetNumText("<color=#ff0000>" .. tostring(num) .. "</color>/" .. tonumber(tab[2]));
                awarditem:ShowTextBg(false);
            end

            awarditem:AddClickTips();
            self.awardItems[i] = awarditem;
        end
    end

end

--@ling autofun
function MagicCardUpstarPanel:HandleUpstar(go, x, y)
    if self.currentSelectItem == nil then
        Notify.ShowText("You didn't select any card");
        return ;
    end
    local data = self.currentSelectItem.data;
    local cardConfig = Config.db_magic_card[data.id];
    local costTab = String2Table(cardConfig.cost);
    for i = 1, #costTab, 1 do
        local tab = costTab[i];
        local num = CardModel:GetInstance():GetItemNumByItemID(tab[1]);
        if num < tonumber(tab[2]) then
            Notify.ShowText("Not enough material");
            return ;
        end
    end
    MagicCardCtrl:GetInstance():RequestCardUpstar(self.currentSelectItem.pos);--直接升星
end

--@ling autofun 收到服务器返回升星,重新刷新UI,叫服务器返回dataID
function MagicCardUpstarPanel:HandleUpStarRefresh(data)
    if self.currentSelectItem then
        --self:RefreshProps(self.currentSelectItem);
        self:InitTogs();
    end
end

function MagicCardUpstarPanel:StopAllSchedules()
    for i = 1, #self.schedules, 1 do
        GlobalSchedule:Stop(self.schedules[i]);
    end
    self.schedules = {};
end

function MagicCardUpstarPanel:UpdateReddot()
    local tab = CardModel.GetInstance().EmbedCards;--在身上的所有的卡片
    for i = 1, 8, 1 do
        if tab[i] then
            local cardId = tab[i].id;
            local itemConfig = Config.db_item[cardId];
            if itemConfig.color >= 4 then
                for k,v in pairs(self.items) do
                    local item = v;
                    if v.data.uid == tab[i].uid then
                        local redTab = self.model.red_dot_list[2];
                        if redTab and redTab[2][cardId] then
                            item:SetRedDotParam(true);
                        else
                            item:SetRedDotParam(false);
                        end
                    end
                end

            end
        end
    end
end

--=========================

UpstarScrollItem = UpstarScrollItem or class("UpstarScrollItem", Node)
local this = UpstarScrollItem

function UpstarScrollItem:ctor(obj, tab)
    self.transform = obj.transform
    self.gameObject = self.transform.gameObject;
    self.data = tab;
    self.image_ab = "magiccard_image";
    self.transform_find = self.transform.Find;
    self.events = {};
    self:Init();
    self:AddEvents();
end

function UpstarScrollItem:dctor()
    GlobalEvent:RemoveTabListener(self.events);
    if self.item then
        self.item:destroy();
    end
    self.item = nil;

    if self.red_dot then
        self.red_dot:destroy()
        self.red_dot = nil
    end
end

function UpstarScrollItem:Init()
    self.is_loaded = true;
    self.nodes = {
        "icon", "selected", "base_score", "best_scroe", "item_name", "normal",
    }
    self:GetChildren(self.nodes);

    --InitUI
    self:InitUI();
end

function UpstarScrollItem:InitUI()
    self.selected = GetImage(self.selected);
    self.base_score = GetText(self.base_score);
    self.best_scroe = GetText(self.best_scroe);
    self.item_name = GetText(self.item_name);
    self.normal = GetImage(self.normal);

    self:RefreshData();

    self.red_dot = RedDot(self.transform, nil, RedDot.RedDotType.Nor);
    self.red_dot:SetPosition(120, 42);

    if self.is_udpate_reddot ~= nil then
        self:SetRedDotParam(self.is_udpate_reddot)
        self.is_udpate_reddot = nil
    end
end

function UpstarScrollItem:SetDataAndRefresh(data)
    self.data = data;
    self:RefreshData();
end

function UpstarScrollItem:RefreshData()
    if self.data then
        local cardConfig = Config.db_magic_card[self.data.id];
        self.item_name.text = tostring(cardConfig.name);
        self.base_score.text = "Basic Rating:" .. tostring(cardConfig.score);
        self.best_scroe.text = "Stars:" .. tostring(cardConfig.star);--战力要算出来的啊

        self.item = CardIcon(self.icon, cardConfig);
        self.item:ShowCardName(false);
        self.item:SetCardLv(self.data.extra);
        --self.item:SetData(self.data.id, 0);
        --self.item:SetNumText(tonumber(self.data.extra) .. "级");

        local itemConfig = Config.db_item[self.data.id];
        if itemConfig then
            self.item_name.text = cardConfig.name;
            SetColor(self.item_name, HtmlColorStringToColor("#" .. ColorUtil.GetColor(itemConfig.color)));
        end
    end
end

function UpstarScrollItem:AddEvents()

end

function UpstarScrollItem:SetIsSelected(bool)
    bool = toBool(bool);
    if self.selected then
        SetGameObjectActive(self.selected, bool);
    end
end

function UpstarScrollItem:SetRedDotParam(bool)
    bool = toBool(bool);
    if self.is_loaded then
        self.red_dot:SetRedDotParam(bool)
    else
        self.is_udpate_reddot = bool
    end
end






--======================================================







MagicCardUpstarPropItem = MagicCardUpstarPropItem or class("MagicCardUpstarPropItem", Node)
local this = MagicCardUpstarPropItem

function MagicCardUpstarPropItem:ctor(obj, tab)
    self.transform = obj.transform
    self.gameObject = self.transform.gameObject;
    self.data = tab;
    self.image_ab = "magiccard_image";
    self.transform_find = self.transform.Find;
    self.events = {};
    self:Init();
    self:AddEvents();
end

function MagicCardUpstarPropItem:dctor()
    GlobalEvent:RemoveTabListener(self.events);
    if self.schedule then
        GlobalSchedule:Stop(self.schedule);
    end
    self.values = nil;
    if self.card then
        self.card:destroy();
    end
    self.card = nil;
    self.starItems = nil;
end

function MagicCardUpstarPropItem:Init()
    self.is_loaded = true;
    self.nodes = {
        "card_item", "best_text_1", "best_text_2", "base_text_1", "base_text_2", "current_star_title_image_1", "cardname",

        "stars/star_1", "stars/star_4", "stars/star_5", "stars/star_6", "stars/star_2", "stars/star_3",

        "isBestProp",
    }
    self:GetChildren(self.nodes);

    self:InitUI();
end

function MagicCardUpstarPropItem:InitUI()
    self.values = {};
    self.best_text_1 = GetText(self.best_text_1);

    self.best_text_2 = GetText(self.best_text_2);
    self.base_text_1 = GetText(self.base_text_1);
    self.base_text_2 = GetText(self.base_text_2);

    self.isBestProp = GetText(self.isBestProp);

    self.starItems = {};
    for i = 1, 6, 1 do
        self.starItems[i] = GetImage(self["star_" .. i]);
        SetGameObjectActive(self.starItems[i], true);
    end

    self.cardname = GetText(self.cardname);

    self.base_text_1.text = "";
    self.base_text_2.text = "";
    self.best_text_1.text = "";
    self.best_text_2.text = "";
    self.values[1] = self.base_text_1;
    self.values[2] = self.base_text_2;
    SetGameObjectActive(self.values[2].gameObject, false);
    self.values[3] = self.best_text_1;
    SetGameObjectActive(self.values[3].gameObject, false);
    self.values[4] = self.best_text_2;
    SetGameObjectActive(self.values[4].gameObject, false);

    self.current_star_title_image_1 = GetImage(self.current_star_title_image_1);

    self.card = MagicCard(self.card_item, self.data);

    self.card:ShowStars(false);
    self.card:ShowCardName(false);
    self.card:ShowCardLV(false);

end

function MagicCardUpstarPropItem:ShowStars(bool)
    bool = toBool(bool);
    self.showstar = bool;
    if self.starItems then
        for i = 1, 6, 1 do
            SetGameObjectActive(self.starItems[i], bool);
        end
    end
end

function MagicCardUpstarPropItem:SetMaxStar(num)
    for i = 1, 6, 1 do
        if i <= num then
            SetGameObjectActive(self.starItems[i], true);
            SetAlpha(self.starItems[i], 0.5);
        else
            SetGameObjectActive(self.starItems[i], false);
        end
    end
end

function MagicCardUpstarPropItem:SetStarNum(num)
    for i = 1, num, 1 do
        SetGameObjectActive(self.starItems[i], true);
        SetAlpha(self.starItems[i], 1);
    end
end

function MagicCardUpstarPropItem:AddEvents()

end
--magic_card_upstar_title_deco_max,magic_card_upstar_title_deco_next
function MagicCardUpstarPropItem:SetIsMaxStar(bool)
    bool = toBool(bool);
    if bool then
        --lua_resMgr:SetImageTexture(self, self.current_star_title_image_1, "magiccard_image", "magic_card_upstar_title_deco_max", false);

        --SetGameObjectActive(self.values[2].gameObject, false);
        --SetGameObjectActive(self.values[4].gameObject, false);
        --SetGameObjectActive(self.values[1].gameObject, true);
        --self.values[1].text = "已满级  ";
        --SetGameObjectActive(self.values[3].gameObject, true);
        --self.values[3].text = "已满级  ";
        self.card:ShowMaxStarImg(true);
    else
        --lua_resMgr:SetImageTexture(self, self.current_star_title_image_1, "magiccard_image", "magic_card_upstar_title_deco_next", false);
        self.card:ShowMaxStarImg(false);
    end
end

--刷新4条属性s
function MagicCardUpstarPropItem:RefreshProps(data, cardData)
    self.best_text_1.text = "";
    self.best_text_2.text = "";
    self.base_text_1.text = "";
    self.base_text_2.text = "";
    if data == nil then
        return
    end

    if data then
        local itemConfig = Config.db_item[data.id];
        if itemConfig and cardData then
            self.cardname.text = data.name .. " Lv." .. tostring(cardData.extra);
            SetColor(self.cardname, HtmlColorStringToColor("#" .. ColorUtil.GetColor(itemConfig.color)));
        end
    end

    self:SetMaxStar(data.max_star);
    self:SetStarNum(data.star);

    local cardConfig = Config.db_magic_card[data.id];

    self.card:UpdateData(cardConfig);

    local index = 1;
    local base = String2Table(cardConfig.base);
    local best = String2Table(cardConfig.rare);
    local value = "";
    for k, v in pairs(base) do
        --self.labels[index].text = PROP_ENUM[v[1]].label .. ":";
        local label = PROP_ENUM[v[1]].label .. "：+";
        if v[1] >= 13 then
            value = label .. GetPreciseDecimal(tonumber(v[2]) / 100, 2) .. "%";
        else
            value = label .. tostring(v[2]);
        end
        value = string.gsub(tostring(value), "%.", "d");
        self.values[index].text = value;
        SetGameObjectActive(self.values[index].gameObject, true);

        index = index + 1;
    end
    index = 3;
    local flag = false;
    for k, v in pairs(best) do
        --self.labels[index].text = PROP_ENUM[v[1]].label .. ":";
        local label = PROP_ENUM[v[1]].label .. "：+";
        if v[1] >= 13 then
            value = label .. GetPreciseDecimal(tonumber(v[2]) / 100, 2) .. "%";
        else
            value = label .. tostring(v[2]);
        end

        value = string.gsub(tostring(value), "%.", "d");
        self.values[index].text = value;
        SetGameObjectActive(self.values[index].gameObject, true);

        index = index + 1;
        flag = true;
    end

    SetGameObjectActive(self.isBestProp, not flag);

end

