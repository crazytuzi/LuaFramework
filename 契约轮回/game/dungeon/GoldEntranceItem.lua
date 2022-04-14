GoldEntranceItem = GoldEntranceItem or class("GoldEntranceItem", Node)
local this = GoldEntranceItem

function GoldEntranceItem:ctor(obj, data)
    self.transform = obj.transform
    self.gameObject = self.transform.gameObject;
    self.data = data;
    self.image_ab = "dungeon_image";
    self.transform_find = self.transform.Find;
    self.events = {};
    self:Init();
    self:AddEvents();
end

function GoldEntranceItem:dctor()
    GlobalEvent:RemoveTabListener(self.events);
    self.staritems = nil;
end

function GoldEntranceItem:Init()
    self.is_loaded = true;
    self.nodes = {
        "stars/star_2", "stars", "stars/star_1", "level_text", "stars/star_3", "open_text", "normal", "selected",
    }
    self:GetChildren(self.nodes);

    self:InitUI();
end

function GoldEntranceItem:InitUI()
    self.staritems = {};--三颗星
    for i = 1, 3, 1 do
        self.staritems[i] = GetToggle(self["star_" .. i]);
    end
    self.level_text = GetText(self.level_text);
    self.normal = GetImage(self.normal);
    self.selected = GetImage(self.selected);

    self:SetStar(0);

    if self.data then
        self:SetLevel(self.data.level .. "Level");
    end
end

function GoldEntranceItem:AddEvents()

end

function GoldEntranceItem:SetLevel(lv)
    self.level_text.text = tostring(lv);
end

function GoldEntranceItem:SetSelected(bool)
    bool = toBool(bool);
    self.selected.gameObject:SetActive(bool);
    self.normal.gameObject:SetActive(not bool);
end

function GoldEntranceItem:SetOpen(bool)
    bool = toBool(bool);
    self.stars.gameObject:SetActive(bool);
    self.open_text.gameObject:SetActive(not bool);
end

function GoldEntranceItem:SetStar(num)
    for i = 1, 3, 1 do
        if self.staritems[i] then
            self.staritems[i].isOn = false;
        end
    end
    local bs = BitState(num);
    for i = 1, 3, 1 do
        self.staritems[i].isOn = bs:Contain(BitState.State[i]);
    end
    --for i = 1, num, 1 do
    --    if self.staritems[i] then
    --        self.staritems[i].isOn = true;
    --    end
    --eniamling




end
