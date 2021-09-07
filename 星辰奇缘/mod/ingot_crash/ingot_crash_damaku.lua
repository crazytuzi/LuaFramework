-- @author 黄耀聪
-- @date 2017年7月12日, 星期三

IngotCrashDamaku = IngotCrashDamaku or BaseClass(BasePanel)

function IngotCrashDamaku:__init(model)
    self.model = model
    self.name = "IngotCrashDamaku"

    self.resList = {
        {file = AssetConfig.ingotcrash_damaku, type = AssetType.Main}
        ,{file = AssetConfig.combat_texture, type = AssetType.Dep}
        ,{file = AssetConfig.combat2_texture, type = AssetType.Dep}
    }

    self.updateListener = function() self:Reload() end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function IngotCrashDamaku:__delete()
    self.OnHideEvent:Fire()
    self:AssetClearAll()
end

function IngotCrashDamaku:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.ingotcrash_damaku))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(ChatManager.Instance.model.chatCanvas, self.gameObject)
    self.transform = t

    self.damakuBtn = t:Find("Damaku"):GetComponent(Button)
    self.noDamakuBtn = t:Find("NoDamaku"):GetComponent(Button)
    self.noDamakuImage = self.noDamakuBtn.gameObject:GetComponent(Image)
    self.noDamakuIcon = t:Find("NoDamaku/Icon").gameObject

    self.damakuBtn.onClick:AddListener(function() self:OnDamaku() end)
    self.noDamakuBtn.onClick:AddListener(function() self:OnCloseDamaku() end)

    self.damakuBtn.transform.anchoredPosition = Vector2(85,-104)
    self.noDamakuBtn.transform.anchoredPosition = Vector2(159,-104)
end

function IngotCrashDamaku:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function IngotCrashDamaku:OnOpen()
    self:RemoveListeners()
    IngotCrashManager.Instance.onUpdateDamaku:AddListener(self.updateListener)

    self:Reload()
end

function IngotCrashDamaku:OnHide()
    self:RemoveListeners()
end

function IngotCrashDamaku:RemoveListeners()
    IngotCrashManager.Instance.onUpdateDamaku:RemoveListener(self.updateListener)
end

function IngotCrashDamaku:Reload()
    if IngotCrashManager.Instance.isShowDamaku == true then
        self.noDamakuIcon:SetActive(true)
        self.noDamakuImage.sprite = self.assetWrapper:GetSprite(AssetConfig.combat_texture, "sendbtn")
    else
        self.noDamakuIcon:SetActive(false)
        self.noDamakuImage.sprite = self.assetWrapper:GetSprite(AssetConfig.combat_texture, "unsendbtn")
    end
end

function IngotCrashDamaku:OnDamaku()
    DanmakuManager.Instance.model:OpenPanel({sendCall = function(msg)
        IngotCrashManager.Instance.isShowDamaku = true
        IngotCrashManager.Instance.onUpdateDamaku:Fire()
        IngotCrashManager.Instance:send20014(msg)
    end})
end

function IngotCrashDamaku:OnCloseDamaku()
    IngotCrashManager.Instance.isShowDamaku = not (IngotCrashManager.Instance.isShowDamaku or false)
    if IngotCrashManager.Instance.isShowDamaku == true then
        NoticeManager.Instance:FloatTipsByString(TI18N("<color='#ffff00'>已开启弹幕</color>"))
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("<color='#ffff00'>已关闭弹幕</color>，当前弹幕消失后生效"))
    end
    print(tostring(IngotCrashManager.Instance.isShowDamaku))
    self:Reload()
end
