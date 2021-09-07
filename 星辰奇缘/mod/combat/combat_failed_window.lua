-- I18NBlacksmithsButtonIcon
-- I18NMarketButtonIcon
-- I18NGuardianButtonIcon
-- I18NSkillButtonIcon

CombatFailedWindow = CombatFailedWindow or BaseClass(BaseWindow)

function CombatFailedWindow:__init(manager)
    self.name = "CombatFailedWindow"
    self.Mgr = manager
    self.resList = {
        {file = AssetConfig.combat_failedwin, type = AssetType.Main}
        ,{file = AssetConfig.combat_texture, type = AssetType.Dep}
    }
end

function CombatFailedWindow:__delete()
    self:ClearDepAsset()
end

function CombatFailedWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.combat_failedwin))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self.Con = self.transform:Find("Main/Con")
    self.bt1 = self.Con:Find("Bt1")
    self.Text1 = self.bt1:Find("Num"):GetComponent(Text)
    self.Text1.text = TI18N("打造、镶嵌")
    self.bt2 = self.Con:Find("Bt2")
    self.Text2 = self.bt2:Find("Num"):GetComponent(Text)
    self.Text2.text = TI18N("洗宠、打书")
    self.bt3 = self.Con:Find("Bt3")
    self.Text3 = self.bt3:Find("Num"):GetComponent(Text)
    self.Text3.text = TI18N("守护招募")
    self.bt4 = self.Con:Find("Bt4")
    self.Text4 = self.bt4:Find("Num"):GetComponent(Text)
    self.Text4.text = TI18N("人物技能提升")

    self.bt1:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.mainui_textures, "I18NBlacksmithsButtonIcon")
    -- self.bt2:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.mainui_textures, "I18NMarketButtonIcon")
    self.bt3:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.mainui_textures, "I18NGuardianButtonIcon")
    self.bt4:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.mainui_textures, "I18NSkillButtonIcon")

    self.bt1:GetComponent(Button).onClick:AddListener(function () WindowManager.Instance:CloseWindow(self) WindowManager.Instance:OpenWindowById(WindowConfig.WinID.eqmadvance) end)
    self.bt2:GetComponent(Button).onClick:AddListener(function () WindowManager.Instance:CloseWindow(self) WindowManager.Instance:OpenWindowById(WindowConfig.WinID.pet) end)
    self.bt3:GetComponent(Button).onClick:AddListener(function () WindowManager.Instance:CloseWindow(self) WindowManager.Instance:OpenWindowById(WindowConfig.WinID.guardian) end)
    self.bt4:GetComponent(Button).onClick:AddListener(function () WindowManager.Instance:CloseWindow(self) WindowManager.Instance:OpenWindowById(WindowConfig.WinID.skill) end)
end