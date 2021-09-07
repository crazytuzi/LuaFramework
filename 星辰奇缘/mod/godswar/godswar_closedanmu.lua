--zyh
GodsWarCloseDanmu = GodsWarCloseDanmu or BaseClass(BasePanel)

function GodsWarCloseDanmu:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "GodsWarCloseDanmu"

    self.resList = {
        {file = AssetConfig.guilddragon_closedamaku, type = AssetType.Main}
    }

    self.infoListener = function() self:Update() end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function GodsWarCloseDanmu:__delete()
    self.OnHideEvent:Fire()
    self:AssetClearAll()
end

function GodsWarCloseDanmu:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.guilddragon_closedamaku))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = t

    local btn = self.gameObject:GetComponent(Button)
    if btn == nil then
        btn = self.gameObject:AddComponent(Button)
    end
    btn.onClick:AddListener(function() self.model:CloseDamakuSetting() end)

    self.closeDamakuObj = self.transform:Find("CloseDamaku").gameObject
    self.sysDamakuBtn = self.closeDamakuObj.transform:Find("System"):GetComponent(Button)
    self.sysDamakuTickObj = self.closeDamakuObj.transform:Find("System/TickBg/Tick").gameObject
    self.playerDamakuBtn = self.closeDamakuObj.transform:Find("Player"):GetComponent(Button)
    self.playerDamakuTickObj = self.closeDamakuObj.transform:Find("Player/TickBg/Tick").gameObject

    self.sysDamakuBtn.onClick:AddListener(function() self:OnDamakuTick(GuildDragonEnum.DamakuType.System) end)
    self.playerDamakuBtn.onClick:AddListener(function() self:OnDamakuTick(GuildDragonEnum.DamakuType.Player) end)
end

function GodsWarCloseDanmu:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function GodsWarCloseDanmu:OnOpen()
    self:RemoveListeners()
    GodsWarWorShipManager.Instance.OnUpdateGodsWarWorShipDanMu:AddListener(self.infoListener)

    self:Update()
end

function GodsWarCloseDanmu:OnHide()

    self:RemoveListeners()
end

function GodsWarCloseDanmu:RemoveListeners()
    GodsWarWorShipManager.Instance.OnUpdateGodsWarWorShipDanMu:RemoveListener(self.infoListener)
end

function GodsWarCloseDanmu:Update()
    self.sysDamakuTickObj:SetActive(GodsWarWorShipManager.Instance.GodsWarDamakuSystemValue == 0)
    self.playerDamakuTickObj:SetActive(GodsWarWorShipManager.Instance.GodsWarDamakuPlayerValue == 0)
end

function GodsWarCloseDanmu:OnDamakuTick(type)
    if type == GuildDragonEnum.DamakuType.System then
            GodsWarWorShipManager.Instance:Send17943(1,1 - GodsWarWorShipManager.Instance.GodsWarDamakuSystemValue)
    elseif type == GuildDragonEnum.DamakuType.Player then
            GodsWarWorShipManager.Instance:Send17943(2,1 - GodsWarWorShipManager.Instance.GodsWarDamakuPlayerValue)
    end
end

