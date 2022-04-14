GuildGuardItem = GuildGuardItem or class("GuildGuardItem", BaseItem);
local this = GuildGuardItem

function GuildGuardItem:ctor(obj, data)
    self.abName = "dungeon";
    self.image_ab = "dungeon_image";
    self.layer = "Bottom"

    self.data = data;

    self.transform = obj.transform
    self.gameObject = self.transform.gameObject;
    self.transform_find = self.transform.Find;

    self.events = {};
    self.schedules = {};

    self:Init();
end

function GuildGuardItem:dctor()
    GlobalEvent:RemoveTabListener(self.events);
    if self.schedule then
        GlobalSchedule:Stop(self.schedule);
    end
end

function GuildGuardItem:Init()
    self.is_loaded = true;
    self.nodes = {
        "rank","name","hurt",
    }
    self:GetChildren(self.nodes)

    --SetLocalPosition(self.transform, 0, 0, 0);
    self:InitUI();

    self:AddEvents();
end
--堕落战神 <color=#ffffff>Lv.260</color>
function GuildGuardItem:InitUI()
    self.rank = GetText(self.rank);
    self.name = GetText(self.name);
    self.hurt = GetText(self.hurt);

    self:ClearData();
end

function GuildGuardItem:ClearData()
    self.rank.text = "";
    self.name.text = "";
    self.hurt.text = "";
end

function GuildGuardItem:SetData(data , name)
    self.rank.text = data.rank;
    self.name.text = tostring(name or data.base.name);
    self.hurt.text = tostring(GetShowNumber(data.sort));
end



function GuildGuardItem:AddEvents()

end

function GuildGuardItem:UpdateData()

end

