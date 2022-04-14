---
--- Created by R2D2.
--- DateTime: 2019/6/5 19:16
---

PetBossItemView = PetBossItemView or class("PetBossItemView", Node)
local this = PetBossItemView

function PetBossItemView:ctor(obj, data)
    self.transform = obj.transform
    self.data = data

    self.gameObject = self.transform.gameObject
    self.transform_find = self.transform.Find

    ---@generic 模型旋转角度，临时做法，应该放到配置里面去
    self.yRotate = 180
    self.abName = "dungeon"
    self.imageAb = "dungeon_image"

    self:InitUI()
    self:AddEvent()

    if (self.data) then
        self:RefreshView()
    end
end

function PetBossItemView:dctor()
    self:StopWeakSchedule()
    self:StopBornSchedule()

    self.callback = nil
    self.countDownCallBack = nil
end

function PetBossItemView:InitUI()
    self.is_loaded = true
    self.nodes = {
        "Bg","Icon", "Selected", "Attention",
        "RankText", "BossName", "Session","TimeText"
    }
    self:GetChildren(self.nodes)

    self.bgImg = GetImage(self.Bg)
    self.iconImg = GetImage(self.Icon)
    self.selectImg = GetImage(self.Selected)
    self.attentionToggle = GetToggle(self.Attention)
    self.rankText = GetText(self.RankText)
    self.nameText = GetText(self.BossName)
    self.sessionText = GetText(self.Session)
    self.timeText = GetText(self.TimeText)

    SetVisible(self.Attention, false)
    self:SetSelected(false)
    self:SetAttention(false)
end

function PetBossItemView:AddEvent()
    local function toggle_callBack(toggle, isOn)
        if self.ToggleCallBack then
            self.ToggleCallBack(self, isOn)
        end
    end
    AddValueChange(self.Attention.gameObject, toggle_callBack)

    local function item_callBack()
        if self.CallBack then
            self.CallBack(self)
        end
    end
    AddClickEvent(self.Icon.gameObject, item_callBack)
end

function PetBossItemView:SetData(data, index)
    self.petData = data
    self.index = index
    ---保持兼容
    self.data = data.config

    self:RefreshView()
    self:SetAttention(self.petData.care)
end

---是否选中
function PetBossItemView:SetSelected(isSelect)
    isSelect = toBool(isSelect)
    self.selectImg.enabled = isSelect
end

---是否关注
function PetBossItemView:SetAttention(isAttention)
    isAttention = toBool(isAttention)
    self.attentionToggle.isOn = isAttention
end

function PetBossItemView:SetCallBack(callback, toggleCallBack,countDownCallBack)
    self.CallBack = callback
    self.ToggleCallBack = toggleCallBack
    self.countDownCallBack = countDownCallBack
end

function PetBossItemView:ChangeBoss(newId)
    local config = Config.db_boss[newId]
    if (config) then
        self.petData.id = newId
        self.petData.config = config
        self.data = config
        self:RefreshView()
    end
end

function PetBossItemView:RefreshView()
    self:RefreshItem()

    SetVisible(self.Session, true)
    self.timeText.text = ""
    self:StopWeakSchedule()
    self:StopBornSchedule()

    if(self:RefreshBorn()) then
        SetVisible(self.Session, false)
    else
        if( self:RefreshWeak()) then
            SetVisible(self.Session, false)
        end
    end
end

function PetBossItemView:RefreshItem()
    local cfg = self.data
    local creepCfg = Config.db_creep[cfg.id]
    lua_resMgr:SetImageTexture(self, self.bgImg, self.imageAb, "petboss_bg_" .. cfg.qual, true)
    lua_resMgr:SetImageTexture(self, self.iconImg, "iconasset/icon_boss_image", tostring(cfg.boss_res), true)
    self.rankText.text = cfg.order .. ConfigLanguage.Dungeon.Rank
    self.nameText.text = cfg.name .. "  " .. string.format(ConfigLanguage.Common.Level, creepCfg.level)
    ---现在又不要显示半场信息了，先置空，以免策划反复
    self.sessionText.text = "" -- ConfigLanguage.Dungeon["Pet_Boss_Session" .. cfg.group]
end

function PetBossItemView:RefreshBorn()
    --if self.petData.config.name == "猫" then
    --    logError( string.format("OS_Time = %s, name = %s, born= %s, weak=  %s",os.time(), self.petData.config.name, self.petData.born, self.petData.weak))
    --end
    local timeTab = TimeManager:GetLastTimeData(os.time(),self.petData.born)
    if(timeTab) then
        self.timeText.text = "Wait for resurrection"
        self.bornSchedule = GlobalSchedule.StartFun(handler(self, self.WaitBorn), 1, -1)
        return true
    else
        return false
    end
end

function PetBossItemView:RefreshWeak()
    self.timeText.text = ""

    local timeTab = TimeManager:GetLastTimeData(os.time(), self.petData.weak)
    ---有回退计时
    if(timeTab) then
        self:WaitWeak()
        self.weakSchedule = GlobalSchedule.StartFun(handler(self, self.WaitWeak), 1, -1)
        return true
    else
        return false
    end
end

function PetBossItemView:WaitBorn()
    local timeTab = TimeManager:GetLastTimeData(os.time(), self.petData.born)
    if not timeTab then
        if self.countDownCallBack then
            self.countDownCallBack()
        end
        self:StopBornSchedule()
    end
end

---品质倒退倒计时
function PetBossItemView:WaitWeak()
    local timeTab = TimeManager:GetLastTimeData(os.time(), self.petData.weak)
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
        self.timeText.text = timestr -- "<color=#D6302F>" .. timestr .. "</color>"
    else
        if self.countDownCallBack then
            self.countDownCallBack()
        end
        self:StopWeakSchedule()
        self.timeText.text = ""
    end
end

function PetBossItemView:StopBornSchedule()
    if self.bornSchedule then
        GlobalSchedule:Stop(self.bornSchedule)
        self.bornSchedule = nil
    end
end

function PetBossItemView:StopWeakSchedule()
    if self.weakSchedule then
        GlobalSchedule:Stop(self.weakSchedule)
        self.weakSchedule = nil
    end
end