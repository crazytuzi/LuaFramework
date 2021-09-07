-- @author 黄耀聪
-- @date 2017年3月11日

GuildSiegeButtonPanel = GuildSiegeButtonPanel or BaseClass(BasePanel)

function GuildSiegeButtonPanel:__init(model, gameObject)
    self.model = model
    self.gameObject = gameObject
    self.name = "GuildSiegeButtonPanel"

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)

    self:InitPanel()
end

function GuildSiegeButtonPanel:__delete()
    self.OnHideEvent:Fire()
    self:AssetClearAll()
end

function GuildSiegeButtonPanel:InitPanel()
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    self.transform = t

    self.main = t:Find("ButtonList")

    self.watchBtn = t:Find("ButtonList/Button1"):GetComponent(Button)
    self.checkBtn = t:Find("ButtonList/Button2"):GetComponent(Button)

    self.watchBtn.onClick:AddListener(function() self:OnWatch() end)
    self.checkBtn.onClick:AddListener(function() self:OnCheck() end)

    t:GetComponent(Button).onClick:AddListener(function() self:Hiden() end)
end

function GuildSiegeButtonPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function GuildSiegeButtonPanel:OnOpen()
    self:RemoveListeners()

    self.targetCastle = self.openArgs
end

function GuildSiegeButtonPanel:OnHide()
    self:RemoveListeners()
end

function GuildSiegeButtonPanel:RemoveListeners()
end

function GuildSiegeButtonPanel:OnWatch()
    if CombatManager.Instance.isWatching then
        NoticeManager.Instance:FloatTipsByString(TI18N("正在观战中"))
    elseif CombatManager.Instance.isFighting then
        NoticeManager.Instance:FloatTipsByString(TI18N("正在战斗中"))
    else
        if self.targetCastle ~= nil then
            GuildSiegeManager.Instance:send19112(self.targetCastle.type, self.targetCastle.order)
        end
        self:Hiden()
    end
end

function GuildSiegeButtonPanel:OnCheck()
    if self.targetCastle ~= nil then
        self.model:ShowPlayer(self.targetCastle)
    end
    self:Hiden()
end

function GuildSiegeButtonPanel:SetPos(x, y)
    self.main.anchoredPosition = Vector2(x, y)
    return self.main.sizeDelta
end

