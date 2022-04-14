---
--- Created by R2D2.
--- DateTime: 2019/4/28 20:22
---
PetSkillTipView = PetSkillTipView or class("PetSkillTipView", BasePanel)
local PetSkillTipView = PetSkillTipView

local blockChecker

function PetSkillTipView:ctor()
    self.abName = "pet"
    self.imageAb = "pet_image"
    self.assetName = "PetSkillTipView"
    self.layer = "UI"

    self.use_background = false
    self.show_sidebar = false

    blockChecker = blockChecker or UIBlockChecker()
end

function PetSkillTipView:Open()
    PetSkillTipView.super.Open(self)
end

function PetSkillTipView:dctor()
    blockChecker:dctor()
end

function PetSkillTipView:LoadCallBack()
    self.nodes = { "Tip", "Tip/Icon", "Tip/Lock", "Tip/Level", "Tip/Title", "Tip/LockTip",
    "Tip/Name", "Tip/type", "Tip/CD", "Tip/CdText", "Tip/Desc",
    }
    self:GetChildren(self.nodes)

    self:InitUI()
    self:AddEvent()

    if (self.skillData) then
        self:RefreshView()
    end
end

function PetSkillTipView:InitUI()

    blockChecker:InitUI(self.gameObject, self.Tip)
    blockChecker:SetOverBlockCallBack(handler(self, self.OnOverBlock))

    self.skillIcon = GetImage(self.Icon)
    self.skillLock = GetImage(self.Lock)
    self.skillLevel = GetImage(self.Level)
    self.skillLockTip = GetText(self.LockTip)
    self.skillTitle = GetText(self.Title)
    self.skillName = GetText(self.Name)
    self.skillType = GetText(self.type)
    self.skillCD = GetText(self.CD)
    self.skillDesc = GetText(self.Desc)

    self.fullSize = self.transform.sizeDelta
end

function PetSkillTipView:AddEvent()

end

function PetSkillTipView:SetData(data, vpPos, skillOpenTimes)
    self.skillData = data
    self.vpPos = vpPos
    self.skillOpenTimes = skillOpenTimes
    if (self.is_loaded) then
        self:RefreshView()
    end
end

function PetSkillTipView:RefreshView()

    local cfg = Config.db_skill[self.skillData[1]]
    local skillType = self.skillData[3]
    local isLock = self.skillData[4] == 0

    lua_resMgr:SetImageTexture(self, self.skillIcon, "iconasset/icon_skill", tostring(cfg.icon), true)
    lua_resMgr:SetImageTexture(self, self.skillLevel, "pet_image", "Roman_" .. self.skillData[2], true)
    self.skillTitle.text = ConfigLanguage.Pet["SkillTitle" .. skillType]
    self.skillLock.enabled = isLock

    if (skillType == 1 and isLock) then
        ShaderManager.GetInstance():SetImageGray(self.skillIcon)
        self.skillLockTip.text = string.format(ConfigLanguage.Pet.SkillOpenConditionTip, self.skillOpenTimes)
    else
        ShaderManager.GetInstance():SetImageNormal(self.skillIcon)
        self.skillLockTip.text = ""
    end

    self.skillName.text = cfg.name
    self.skillDesc.text = cfg.desc

    local descY = self.skillDesc.preferredHeight
	local _, posY = GetAnchoredPosition(self.Desc)
	posY = math.abs(posY)
	
    SetSizeDeltaY(self.Desc, descY)
    SetSizeDeltaY(self.Tip, posY + descY + 10)

    if cfg.type == 1 then
        SetVisible(self.type, false)
        SetVisible(self.CdText, true)
        local combineId = cfg.id .. "@1"
        local time = Config.db_skill_level[combineId].cd
        self.skillCD.text = tonumber(time) / 1000 .. ConfigLanguage.Date.Second
    else
        SetVisible(self.type, true)
        SetVisible(self.CdText, false)
        self.skillCD.text = ""
        self.skillType.text = cfg.type_show
    end

    ---视口坐标转成窗口坐标
    self.clickPos = Vector2(self.fullSize.x * self.vpPos.x, self.fullSize.y * self.vpPos.y)
    self:SetViewPosition()
end

function PetSkillTipView:OnOverBlock()
    self:Close()
end

function PetSkillTipView:GetArea()
    local areas = {
        { x = -1, y = 1 }, --左上角
        { x = 1, y = 1 }, --右上角
        { x = 1, y = -1 }, --右下角
        { x = -1, y = -1 } --左下角
    }

    local size = self.Tip.sizeDelta

    for _, v in ipairs(areas) do
        local newPos = Vector2.__mul(v, 50) ---50为偏移量
        local offset = Vector2(v.x * size.x, v.y * size.y)
        newPos = newPos + self.clickPos + offset
        --print("<<color=#00ff00>" .. tostring(v) .. " ->" .. tostring(newPos) .. "</color>")
        if (newPos.x >= 0 and newPos.x <= self.fullSize.x and newPos.y >= 0 and newPos.y <= self.fullSize.y) then
            return v, newPos
        end
    end

    --如果都不合适就放顶左上角
    return areas[1], Vector2(0, self.fullSize.y)
end

function PetSkillTipView:SetViewPosition()

    local area, screenPos = self:GetArea()
    local size = self.Tip.sizeDelta
    local pivot = self.Tip.pivot
    ---Rect相对位移
    local baseOffset = Vector2(pivot.x * self.fullSize.x, pivot.y * self.fullSize.y)

    local pos = screenPos - baseOffset - Vector2(area.x * size.x * pivot.x, area.y * size.y * pivot.y)

    SetAnchoredPosition(self.Tip, pos.x, pos.y)
end