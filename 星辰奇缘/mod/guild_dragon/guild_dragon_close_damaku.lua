-- @author 黄耀聪
-- @date 20171205

GuildDragonCloseDamaku = GuildDragonCloseDamaku or BaseClass(BasePanel)

function GuildDragonCloseDamaku:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "GuildDragonCloseDamaku"

    self.resList = {
        {file = AssetConfig.guilddragon_closedamaku, type = AssetType.Main}
    }

    self.infoListener = function() self:Update() end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function GuildDragonCloseDamaku:__delete()
    self.OnHideEvent:Fire()
    self:AssetClearAll()
end

function GuildDragonCloseDamaku:InitPanel()
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

function GuildDragonCloseDamaku:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function GuildDragonCloseDamaku:OnOpen()
    self:RemoveListeners()
    GuildDragonManager.Instance.myInfoEvent:AddListener(self.infoListener)

    self:Update()
end

function GuildDragonCloseDamaku:OnHide()
    self:RemoveListeners()
end

function GuildDragonCloseDamaku:RemoveListeners()
    GuildDragonManager.Instance.myInfoEvent:RemoveListener(self.infoListener)
end

function GuildDragonCloseDamaku:Update()
    self.sysDamakuTickObj:SetActive(GuildDragonManager.Instance.model.myData.sys_value == 0)
    self.playerDamakuTickObj:SetActive(GuildDragonManager.Instance.model.myData.ply_value == 0)
end

function GuildDragonCloseDamaku:OnDamakuTick(type)
    if type == GuildDragonEnum.DamakuType.System then
        GuildDragonManager.Instance:send20513(type, 1 - GuildDragonManager.Instance.model.myData.sys_value)
    elseif type == GuildDragonEnum.DamakuType.Player then
        GuildDragonManager.Instance:send20513(type, 1 - GuildDragonManager.Instance.model.myData.ply_value)
    end
end

