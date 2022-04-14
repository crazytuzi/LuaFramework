DungeonLeftCenterItem = DungeonLeftCenterItem or class("DungeonLeftCenterItem", BaseItem);
local this = DungeonLeftCenterItem
local ConfigLanguage = require('game.config.language.CnLanguage')
function DungeonLeftCenterItem:ctor(obj, data)
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

function DungeonLeftCenterItem:dctor()
    GlobalEvent:RemoveTabListener(self.events);
    if self.schedule then
        GlobalSchedule:Stop(self.schedule);
    end
end

function DungeonLeftCenterItem:Init()
    self.is_loaded = true;
    self.nodes = {
        "boss_name", "item_bg", "status", "selected", "statustime", "order_img"
    }
    self:GetChildren(self.nodes)

    SetLocalPosition(self.transform, 0, 0, 0);
    self:InitUI();

    self:AddEvents();
end
--堕落战神 <color=#ffffff>Lv.260</color>
function DungeonLeftCenterItem:InitUI()
    self.boss_name = GetText(self.boss_name);
    self.status = GetText(self.status);
    self.selected = GetImage(self.selected);
    self.selected.gameObject:SetActive(false);
    if self.order_img then
        self.order_img = GetImage(self.order_img)
    end

    self.statustime = GetText(self.statustime);
    SetGameObjectActive(self.statustime, false);
    if self.data then
        local creep = Config.db_creep[self.data.id];
        local bossConfig = Config.db_boss[self.data.id];
        if bossConfig and DungeonModel:GetInstance():IsBeastBoss(bossConfig.type) then
            if bossConfig.seq == 1 or bossConfig.seq == 2 then
                local bossInfoTab = DungeonModel:GetInstance():GetDungeonBossInfo(bossConfig.type , bossConfig.id);
                if bossInfoTab then
                    self.boss_name.text = "<color=#ffffff>" .. creep.name .. "  " .. bossInfoTab.num .. "</color>";
                else
                    self.boss_name.text = "<color=#ffffff>" .. creep.name .. "  " .. 0 .. "</color>";
                end
            --elseif bossConfig.seq == 2 then
            --    self.boss_name.text = "<color=#ffffff>" .. creep.name .. "  " ..  "</color>";
            else
                self.boss_name.text = "<color=#ffffff>" .. creep.name .. "  " .. string.format(ConfigLanguage.Common.Level, creep.level) .. "</color>";
            end
        elseif bossConfig and bossConfig.peace == 0 then
            self.boss_name.text = "<color=#ffffff>" .. creep.name .. "  " .. string.format(ConfigLanguage.Common.Level, creep.level) .. "</color>";
        else
            self.boss_name.text = "<color=#21D760>" .. creep.name ..  "  " .. string.format(ConfigLanguage.Common.Level, creep.level) .. "</color>";--21D760
        end
        if self.order_img then
            if bossConfig and bossConfig.order >= 3 then
                SetVisible(self.order_img, true)
                lua_resMgr:SetImageTexture(self,self.order_img, 'dungeon_image', 'order_' .. bossConfig.order ,true)
            else
                SetVisible(self.order_img, false)
            end
        end

        if self.data.order then
            local bossinfo = DungeonModel:GetInstance():GetDungeonBossInfo(enum.BOSS_TYPE.BOSS_TYPE_WORLD, self.data.id);
            if bossinfo then
                local time = bossinfo.born;--1541494877
                self:StartSechudle(time);
            end
        else
            self.boss_name.text = creep.name;
            self.status.text = string.format(ConfigLanguage.Common.Level, creep.level);
        end

    end

end

function DungeonLeftCenterItem:AddEvents()
    AddEventListenerInTab(DungeonEvent.WORLD_BOSS_INFO , handler(self, self.HandleBossInfoUpdate) , self.events);
end

function DungeonLeftCenterItem:UpdateData()

end

function DungeonLeftCenterItem:StartSechudle(time)
    self.time = time;
    self.status.text = "";
    local timeTab = TimeManager:GetLastTimeData(os.time(), time);
    if timeTab then
        if self.schedule then
            --print2("=========================" .. self.schedule)
            GlobalSchedule:Stop(self.schedule);
        end
        self.schedule = GlobalSchedule.StartFun(handler(self, self.CountTime), 1, -1);
        self:CountTime();
    else
        self.status.text = "Spawned";
    end
end

function DungeonLeftCenterItem:CountTime()
    local timeTab = TimeManager:GetLastTimeData(os.time(), self.time);
    local timestr = "";
    if timeTab then
        timeTab.hour = timeTab.hour or 0;
        timeTab.min = timeTab.min or 0;
        if timeTab.hour then
            timestr = timestr .. string.format("%02d", timeTab.hour) .. ":";
        end
        if timeTab.min then
            timestr = timestr .. string.format("%02d", timeTab.min) .. ":";
        end
        if timeTab.sec then
            timestr = timestr .. string.format("%02d", timeTab.sec);
        end
        SetGameObjectActive(self.statustime, true);
        SetGameObjectActive(self.status, false);
        self.statustime.text = "<color=#D6302F>" .. timestr .. "</color>";
    else
        if self.schedule then
            GlobalSchedule:Stop(self.schedule);
        end
        SetGameObjectActive(self.statustime, false);
        SetGameObjectActive(self.status, true);
        self.status.text = "Spawned"
        self.schedule = nil;
    end
end

function DungeonLeftCenterItem:SetSelected(bool)
    bool = toBool(bool);
    self.selected.gameObject:SetActive(bool);
end


function DungeonLeftCenterItem:HandleBossInfoUpdate(data)
    if data and data.id == self.data.id then
        local creep = Config.db_creep[self.data.id];
        local bossConfig = Config.db_boss[self.data.id];
        if DungeonModel:GetInstance():IsBeastBoss(bossConfig.type)  and (self.data.seq == 1 or self.data.seq == 2)
        then
            local bossInfoTab = DungeonModel:GetInstance():GetDungeonBossInfo(self.data.type , self.data.id);
            if bossInfoTab then
                self.boss_name.text = "<color=#ffffff>" .. creep.name .. "  " .. bossInfoTab.num .. "</color>";
            else
                self.boss_name.text = "<color=#ffffff>" .. creep.name .. "  " .. 0 .. "</color>";
            end
        --elseif self.data.seq == 2 then
        --    self.boss_name.text = "<color=#ffffff>" .. creep.name .. "  " ..  "</color>";
        else
            self.boss_name.text = "<color=#ffffff>" .. creep.name .. "  " .. string.format(ConfigLanguage.Common.Level, creep.level) .. "</color>";
        end
    end
end