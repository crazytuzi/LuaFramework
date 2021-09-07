
RushTopCloseDamaku = RushTopCloseDamaku or BaseClass(BasePanel)

function RushTopCloseDamaku:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "RushTopCloseDamaku"

    self.resList = {
        {file = AssetConfig.rushtopclosedamaku, type = AssetType.Main}
    }

    self.infoListener = function() self:Update() end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function RushTopCloseDamaku:__delete()
    self.OnHideEvent:Fire()
    self:AssetClearAll()
end

function RushTopCloseDamaku:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.rushtopclosedamaku))
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

    self.sysDamakuBtn.onClick:AddListener(function() self:OnDamakuTick(RushTopEnum.DamakuType.System) end)
    self.playerDamakuBtn.onClick:AddListener(function() self:OnDamakuTick(RushTopEnum.DamakuType.Player) end)
end

function RushTopCloseDamaku:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function RushTopCloseDamaku:OnOpen()
    self:RemoveListeners()
    RushTopManager.Instance.on20429:AddListener(self.infoListener)
    RushTopManager.Instance.on20431:AddListener(self.infoListener)

    self:Update()
end

function RushTopCloseDamaku:OnHide()
    self:RemoveListeners()
end

function RushTopCloseDamaku:RemoveListeners()
    RushTopManager.Instance.on20429:RemoveListener(self.infoListener)
    RushTopManager.Instance.on20431:RemoveListener(self.infoListener)
end

function RushTopCloseDamaku:Update()
    self.sysDamakuTickObj:SetActive(RushTopManager.Instance.model.playerInfo.sys_barrage == 0)
    self.playerDamakuTickObj:SetActive(RushTopManager.Instance.model.playerInfo.ply_barrage == 0)
end

function RushTopCloseDamaku:OnDamakuTick(type)
    if type == RushTopEnum.DamakuType.System then
        RushTopManager.Instance:Send20431(type, 1 - RushTopManager.Instance.model.playerInfo.sys_barrage)
    elseif type == RushTopEnum.DamakuType.Player then
        RushTopManager.Instance:Send20431(type, 1 - RushTopManager.Instance.model.playerInfo.ply_barrage)
    end
end

