---
--- Created by R2D2.
--- DateTime: 2019/4/28 19:34
---
PetBaseSkillView = PetBaseSkillView or class("PetBaseSkillView",Node)

function PetBaseSkillView:ctor()

end

function PetBaseSkillView:dctor()
    self.skillItems = nil
end

function PetBaseSkillView:AddItem(icon, lock, level, title, lockTip)
    self.skillItems = self.skillItems or {}

    local item = {}
    item["Index"] = #self.skillItems + 1
    item["Icon"] = GetImage(icon)
    item["Lock"] = GetImage(lock)
    item["Level"] = GetImage(level)
    --item["Title"] = GetText(title)
    --item["LockTip"] = GetText(lockTip)

    local function call_back(index)
        --print("<<color=#00ff00>----------" .. tostring(item["Index"]) .. "-----------</color>")
        local tipView = lua_panelMgr:GetPanelOrCreate(PetSkillTipView)
        local data = self.SkillsTab[item["Index"]]
        local vpPos = item.Icon.transform.position
        --pos = LayerManager:UIWorldToScreenPoint(pos.x, pos.y)
        vpPos = LayerManager:UIWorldToViewportPoint(vpPos.x, vpPos.y, vpPos.z)
        tipView:SetData(data, vpPos, self.MainSkillOpenTimes)
        tipView:Open()
    end
    AddButtonEvent(item.Icon.gameObject, call_back)

    table.insert(self.skillItems, item)
end

function PetBaseSkillView:RefreshView(petData)
    local key = petData.Config.order .. "@" .. (petData.Data and petData.Data.extra or 0)
    local cfg = Config.db_pet_evolution[key]

    self.SkillsTab = String2Table(cfg.skill)

    for _, v in ipairs(self.SkillsTab) do
        if (v[3] == 1 and v[4] == 0) then
            self:GetMainSkillOpenTimes(cfg)
            break
        end
    end

    for i, _ in ipairs(self.skillItems) do
        self:RefreshItem(i)
    end
end

function PetBaseSkillView:RefreshItem(index)

    local item = self.skillItems[index]
    local data = self.SkillsTab[index]
    local cfg = Config.db_skill[data[1]]

    local skillType = data[3]
    local isLock = (data[4] == 0)

    lua_resMgr:SetImageTexture(self, item.Icon, "iconasset/icon_skill", tostring(cfg.icon), true)
    lua_resMgr:SetImageTexture(self, item.Level, "pet_image", "Roman_" .. data[2], true)
    --item.Title.text = ConfigLanguage.Pet["SkillTitle" .. skillType]
    item.Lock.enabled = isLock

    if (skillType == 1 and isLock) then
        ShaderManager.GetInstance():SetImageGray(item.Icon)
        --item.LockTip.text = string.format(ConfigLanguage.Pet.SkillOpenConditionTip, self.MainSkillOpenTimes)
    else
        ShaderManager.GetInstance():SetImageNormal(item.Icon)
        --item.LockTip.text = ""
    end
end

---奥义开放的突破次数
function PetBaseSkillView:GetMainSkillOpenTimes(config)
    local tabs = {}
    local cfg = config

    while (cfg)
    do
        table.insert(tabs, cfg)
        local key = cfg.order
        local times = cfg.times + 1
        cfg = Config.db_pet_evolution[key .. "@" .. times]
    end

    local times = nil
    for _, v in ipairs(tabs) do
        local t = String2Table(v.skill)

        for _, w in ipairs(t) do
            if w[3] == 1 and w[4] == 1 then
                times = v.times
                break
            end
        end
        if (times) then
            break ;
        end
    end

    self.MainSkillOpenTimes = times
end

