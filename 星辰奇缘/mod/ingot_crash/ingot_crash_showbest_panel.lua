-- -------------------------------
-- 钻石联赛冠军展示界面
-- 黄耀聪
-- -------------------------------
IngotCrashShowBestPanel = IngotCrashShowBestPanel or BaseClass(BasePanel)

function IngotCrashShowBestPanel:__init(model)
    self.model = model
    self.name = "IngotCrashShowBestPanel"
    self.resList = {
        {file = AssetConfig.playkillbestpreview, type = AssetType.Main},
        {file = AssetConfig.levelbreakeffect1, type = AssetType.Dep},
        {file = AssetConfig.levelbreakeffect2, type = AssetType.Dep},
        {file = AssetConfig.playerkilltexture, type = AssetType.Dep},
    }
    self.index = 1

    self.OnOpenEvent:AddListener(function() self:OnShow() end)
end

function IngotCrashShowBestPanel:__delete()
    if self.rotateId ~= nil then
      LuaTimer.Delete(self.rotateId)
      self.rotateId = nil
    end

    if self.rightImg ~= nil then
        self.rightImg.sprite = nil
        self.rightImg = nil
    end

    if self.leftImg ~= nil then
        self.leftImg.sprite = nil
        self.leftImg = nil
    end

    if self.previewComp ~= nil then
        self.previewComp:DeleteMe()
        self.previewComp = nil
    end

    self:AssetClearAll()
end

function IngotCrashShowBestPanel:OnShow()
    self.championList = self.openArgs
    self:Update()
end

function IngotCrashShowBestPanel:OnHide()
end

function IngotCrashShowBestPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.playkillbestpreview))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform
    self.title = self.transform:Find("Main/Title"):GetComponent(Text)
    self.transform:Find("Main/OKButton"):GetComponent(Button).onClick:AddListener(function() self.model:CloseChampions() end)
    self.preview = self.transform:Find("Main/Preview")

    local reward = self.transform:Find("Main/RewardList")
    self.name = reward:Find("Reward1/Text"):GetComponent(Text)
    self.lev = reward:Find("Reward2/Content/Text"):GetComponent(Text)
    self.step = reward:Find("Reward3/Text"):GetComponent(Text)
    self.star = reward:Find("Reward3/Text/Val"):GetComponent(Text)
    self.score = reward:Find("Reward4/Text"):GetComponent(Text)

    self.reward4 = reward:Find("Reward4")
    self.stepRect = self.step.transform:GetComponent(RectTransform)

    self.right = self.transform:Find("Main/Right")
    self.rightImg = self.right:GetComponent(Image)
    self.right:GetComponent(Button).onClick:AddListener(function() self:Right() end)

    self.left = self.transform:Find("Main/Left")
    self.leftImg = self.left:GetComponent(Image)
    self.left:GetComponent(Button).onClick:AddListener(function() self:Left() end)

    self.RoleBg1 = self.transform:Find("Main/RoleBg1")
    self.RoleBg2 = self.transform:Find("Main/RoleBg2")
    for i=1,2 do
        self.RoleBg1:Find("Image"..i):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.levelbreakeffect1, "LevelBreakEffect1")
    end

    for i=1,4 do
        self.RoleBg2:Find("Image"..i):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.levelbreakeffect2, "LevelBreakEffect2")
    end

    self:OnShow()
    reward:Find("Reward3/Text/Icon").gameObject:SetActive(false)
    reward:Find("Reward3/Text/Val").gameObject:SetActive(false)
    self.step.horizontalOverflow = 1

    self.transform:Find("Main/OKButton/Text"):GetComponent(Text).text = TI18N("哇666！")
end

function IngotCrashShowBestPanel:Left()
  if self.index - 1 == 0 then
    return
  end
  self.index = self.index - 1
  self:Update()
end

function IngotCrashShowBestPanel:Right()
  if self.index + 1 > #self.championList then
    return
  end
  self.index = self.index + 1
  self:Update()
end

function IngotCrashShowBestPanel:Update()
    self:showBgAni()

    self.title.text = TI18N("钻石联赛冠军")
    self.data = self.championList[self.index]
    self.name.text = self.data.name
    self.lev.text = string.format(TI18N("%s (%s-%s级)"), DataGoldLeague.data_group[self.data.group_id].name, DataGoldLeague.data_group[self.data.group_id].min_lev, DataGoldLeague.data_group[self.data.group_id].max_lev)
    self.step.text = string.format(TI18N("称号：<color='#ffff00'>%s</color>"), DataHonor.data_get_honor_list[DataGoldLeague.data_honor[string.format("%s_%s", DataGoldLeague.data_group[self.data.group_id].rank_type, 1)].honor_id].name)
    self.reward4.gameObject:SetActive(false)

    self.rightImg.gameObject:SetActive(self.index ~= #self.championList)
    self.leftImg.gameObject:SetActive(self.index ~= 1)

    self:UpdatePreview()
end

function IngotCrashShowBestPanel:UpdatePreview()
    local callback = function(composite)
        self:SetRawImage(composite)
    end
    local setting = {
        name = "PlayerkillNo1Role"
        ,orthographicSize = 0.7
        ,width = 341
        ,height = 341
        ,offsetY = -0.4
    }
    local modelData = {type = PreViewType.Role, classes = self.data.classes, sex = self.data.sex, looks = self.data.looks}
    if self.previewComp == nil then
        self.previewComp = PreviewComposite.New(callback, setting, modelData)
    else
        self.previewComp:Reload(modelData, callback)
    end
    self.previewComp:Show()
end

function IngotCrashShowBestPanel:SetRawImage(composite)
    local rawImage = composite.rawImage
    rawImage.transform:SetParent(self.preview.transform)
    rawImage.transform.localPosition = Vector3(0, 0, 0)
    rawImage.transform.localScale = Vector3(1, 1, 1)
    rawImage:SetActive(true)
    self.preview.gameObject:SetActive(true)
end


function IngotCrashShowBestPanel:showBgAni()
    if self.rotateId ~= nil then
        LuaTimer.Delete(self.rotateId)
        self.rotateId = nil
    end
    self.rotateId = LuaTimer.Add(0, 10, function() self:Rotate() end)
end

function IngotCrashShowBestPanel:Rotate()
    self.RoleBg1.transform:Rotate(Vector3(0, 0, 0.3))
    self.RoleBg2.transform:Rotate(Vector3(0, 0, -0.5))
end
