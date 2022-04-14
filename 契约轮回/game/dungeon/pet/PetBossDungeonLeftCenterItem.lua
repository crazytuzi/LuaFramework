---
--- Created by R2D2.
--- DateTime: 2019/6/11 14:49
---

PetBossDungeonLeftCenterItem = PetBossDungeonLeftCenterItem or class("PetBossDungeonLeftCenterItem", BaseItem)
local this = PetBossDungeonLeftCenterItem

function PetBossDungeonLeftCenterItem:ctor(obj, data)
    self.abName = "dungeon"
    self.image_ab = "dungeon_image"
    self.layer = "Bottom"

    self.data = data
    self.transform = obj.transform
    self.gameObject = self.transform.gameObject
    self.transform_find = self.transform.Find

    self.events = {}
    self.schedules = {}

    self:InitUI()
    self:AddEvents()

    self:RefreshView()
end

function PetBossDungeonLeftCenterItem:dctor()
    GlobalEvent:RemoveTabListener(self.events)

    self:StopBornSchedule()
    self:StopWeakSchedule()
end

function PetBossDungeonLeftCenterItem:InitUI()
    self.is_loaded = true
    self.nodes = {
        "Bg", "Selected", "Name",  "StateImg", "Time",
    }
    self:GetChildren(self.nodes)

    self.BgImg = GetImage(self.Bg)
    self.boss_name = GetText(self.Name)
    self.selected = GetImage(self.Selected)
    self.statusTime = GetText(self.Time)
    self.stateImg = GetImage(self.StateImg)

    self.selected.enabled = false
end

function PetBossDungeonLeftCenterItem:AddEvents()
    local function call_back()
        --DungeonModel:GetInstance():PrintPetBoss()
        if self.CallBack then
            self.CallBack(self)
        end
    end
    AddClickEvent(self.Bg.gameObject, call_back)
end

function PetBossDungeonLeftCenterItem:SetData(data)
    self.data = data
    self:RefreshView()
end

function PetBossDungeonLeftCenterItem:SetCallBack(callback)
    self.CallBack = callback
end

function PetBossDungeonLeftCenterItem:RefreshView()

    if (self.data == nil) then
        return
    end

   self:RefreshBossInfo()
   self:RefreshState()
end

function PetBossDungeonLeftCenterItem:RefreshState()
    self:StopBornSchedule()
    self:StopWeakSchedule()

    SetGameObjectActive(self.statusTime, false)
    self.stateImg.enabled = false

    self.bornTime = self.data.born
    self.weakTime = self.data.weak or 0

    local timeTab = TimeManager:GetLastTimeData(os.time(),self.bornTime)
    local weakTimeTab = TimeManager:GetLastTimeData(os.time(), self.weakTime)

    ---如果等待重生，优先显示
    if(timeTab) then
        SetGameObjectActive(self.statusTime, false)
        self.stateImg.enabled = true
        self.bornSchedule = GlobalSchedule.StartFun(handler(self, self.WaitBorn), 1, -1)
        return
    end

    ---如果有回退计时，则不显示状态图片
    if weakTimeTab then
        SetGameObjectActive(self.statusTime, true)
        self.stateImg.enabled = false
        self:WaitWeak()
        self.weakSchedule = GlobalSchedule.StartFun(handler(self, self.WaitWeak), 1, -1)
    else
        SetGameObjectActive(self.statusTime, false)
    end
end

--function PetBossDungeonLeftCenterItem:RefreshStateImage()
--
--    local timeTab = TimeManager:GetLastTimeData(os.time(),self.bornTime)
--
--    if timeTab then
--        --self:ChangeStateImage(2)
--        self.stateImg.enabled = true
--        self.bornSchedule = GlobalSchedule.StartFun(handler(self, self.WaitBorn), 1, -1)
--    else
--        self.stateImg.enabled = false
--        --self:ChangeStateImage(1)
--    end
--end

-----设置状态，1为已刷新，2为重生中
--function PetBossDungeonLeftCenterItem:ChangeStateImage(state)
--    lua_resMgr:SetImageTexture(self, self.stateImg, self.image_ab, "petboss_d_State_" .. state , true)
--    self.stateImg.enabled = true
--end

function PetBossDungeonLeftCenterItem:StopWeakCountDown()
    self:StopWeakSchedule()
    self.statusTime.text =  ""
end

function PetBossDungeonLeftCenterItem:RefreshBossInfo()
    local creep = Config.db_creep[self.data.id]
    self.boss_name.text = string.format("%s   %d%s", creep.name, creep.level, ConfigLanguage.Mix.Level)
    lua_resMgr:SetImageTexture(self, self.BgImg, self.image_ab, "petboss_d_bg_" .. self.data.config.qual, true)
end

function PetBossDungeonLeftCenterItem:StopBornSchedule()
    if self.bornSchedule then
        GlobalSchedule:Stop(self.bornSchedule)
        self.bornSchedule = nil
    end
end

function PetBossDungeonLeftCenterItem:StopWeakSchedule()
    if self.weakSchedule then
        GlobalSchedule:Stop(self.weakSchedule)
        self.weakSchedule = nil
    end
end

function PetBossDungeonLeftCenterItem:WaitBorn()
    local timeTab = TimeManager:GetLastTimeData(os.time(), self.bornTime)
    if not timeTab then
        self.stateImg.enabled = false
    end
end

function PetBossDungeonLeftCenterItem:WaitWeak()
    local timeTab = TimeManager:GetLastTimeData(os.time(), self.weakTime)
    local timestr = ""
    if timeTab then
        timeTab.hour = timeTab.hour or 0
        timeTab.min = timeTab.min or 0
        if timeTab.hour then
            timestr = timestr .. string.format("%02d", timeTab.hour) .. ":"
        end
        if timeTab.min then
            timestr = timestr .. string.format("%02d", timeTab.min) .. ":"
        end
        if timeTab.sec then
            timestr = timestr .. string.format("%02d", timeTab.sec)
        end
        self.statusTime.text = timestr -- "<color=#D6302F>" .. timestr .. "</color>"
    else
        self:StopWeakSchedule()
        SetGameObjectActive(self.statusTime, false)
    end
end

function PetBossDungeonLeftCenterItem:UpdateData()

end

function PetBossDungeonLeftCenterItem:ChangeBoss(newId)
    local config = Config.db_boss[newId]
    if (config) then
        self.data.id = newId
        self.data.config = config

        self:RefreshBossInfo()
        self:RefreshState()
    end
end

function PetBossDungeonLeftCenterItem:SetSelected(bool)
    bool = toBool(bool)
    self.selected.enabled = bool
end