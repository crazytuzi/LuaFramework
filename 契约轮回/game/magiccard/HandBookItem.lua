HandBookItem = HandBookItem or class("HandBookItem", Node)
local this = HandBookItem

function HandBookItem:ctor(obj, tab)
    self.transform = obj.transform
    self.gameObject = self.transform.gameObject;
    self.data = tab;
    self.image_ab = "magiccard_image";
    self.transform_find = self.transform.Find;
    self.events = {};
    self:Init();
    self:AddEvents();
end

function HandBookItem:Init()
    self.is_loaded = true;
    self.nodes = {
        "price_bg", "cname", "selected", "card",
    }
    self:GetChildren(self.nodes);

    self:InitUI();
end

function HandBookItem:InitUI()
    self.cname = GetText(self.cname);
    self.selected = GetImage(self.selected);
    SetGameObjectActive(self.selected, false);
    if self.data then
        local cardID = self.data.id;
        local carddata = Config.db_magic_card[cardID];
        self.carditem = MagicCard(self.card, carddata);
        --不显示卡名,不显示卡等级
        self.carditem:ShowCardName(false);
        self.carditem:ShowCardLV(false);
        self.carditem:ShowStars(false);
        self.cname.text = tostring(carddata.name);
    end
end
--通过颜色,槽位,星数之类判断是否某种卡
function HandBookItem:IsType(handbook_type)
    if self.data and self.data.booktype == handbook_type then
        return true;
    end
    return false;
    --local cardID = self.data.id;
    --local cardConfig = Config.db_magic_card[cardID];
    --local itemConfig = Config.db_item[cardID];
    --return itemConfig and itemConfig.color == color;
end

function HandBookItem:SetSelected(bool)
    SetGameObjectActive(self.selected, bool);
end

function HandBookItem:AddEvents()

end

function HandBookItem:dctor()
    GlobalEvent:RemoveTabListener(self.events);
    if self.schedule then
        GlobalSchedule:Stop(self.schedule);
    end
    if self.carditem then
        self.carditem:destroy();
    end
    self.carditem = nil;
end