-- -------------------------------
-- 英雄擂台冠军展示界面
-- hosr
-- -------------------------------
PlayerkillShowBestPanel = PlayerkillShowBestPanel or BaseClass(BasePanel)

function PlayerkillShowBestPanel:__init(model)
    self.model = model
    self.resList = {
        {file = AssetConfig.playkillbestpreview, type = AssetType.Main},
        {file = AssetConfig.levelbreakeffect1, type = AssetType.Dep},
        {file = AssetConfig.levelbreakeffect2, type = AssetType.Dep},
    }
    self.index = 1
end

function PlayerkillShowBestPanel:__delete()
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
end

function PlayerkillShowBestPanel:OnShow()
    self:Update()
end

function PlayerkillShowBestPanel:OnHide()
end

function PlayerkillShowBestPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.playkillbestpreview))
    self.gameObject.name = "PlayerkillShowBestPanel"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform
    self.title = self.transform:Find("Main/Title"):GetComponent(Text)
    self.transform:Find("Main/OKButton"):GetComponent(Button).onClick:AddListener(function() self.model:CloseNo1Show() end)
    self.preview = self.transform:Find("Main/Preview")

    local reward = self.transform:Find("Main/RewardList")
    self.name = reward:Find("Reward1/Text"):GetComponent(Text)
    self.lev = reward:Find("Reward2/Content/Text"):GetComponent(Text)
    self.step = reward:Find("Reward3/Text"):GetComponent(Text)
    self.star = reward:Find("Reward3/Text/Val"):GetComponent(Text)
    self.score = reward:Find("Reward4/Text"):GetComponent(Text)
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
end

function PlayerkillShowBestPanel:Left()
  if self.index - 1 == 0 then
    return
  end
  self.index = self.index - 1
  self:Update()
end

function PlayerkillShowBestPanel:Right()
  if self.index + 1 > 2 then
    return
  end
  self.index = self.index + 1
  self:Update()
end

function PlayerkillShowBestPanel:Update()
    self:showBgAni()
    self.data = nil
    if self.index == 1 then
        self.leftImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Arrow13")
        self.rightImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Arrow7")
        self.left.localScale = Vector3.one
        self.right.localScale = Vector3.one
        -- 本服
        self.data = PlayerkillManager.Instance.serverNo1Data
        self.title.text = TI18N("本服冠军")
    elseif self.index == 2 then
        self.leftImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Arrow7")
        self.rightImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Arrow13")
        self.left.localScale = Vector3(-1, 1, 1)
        self.right.localScale = Vector3(-1, 1, 1)
        -- 世界
        self.title.text = TI18N("跨服冠军")
        self.data = PlayerkillManager.Instance.worldNo1Data
    end
    if self.data.name == "" then
        local nostr = TI18N("暂无数据")
        self.name.text = nostr
        self.lev.text = nostr
        self.star.text = ""
        self.step.text = nostr
        self.score.text = nostr
        self.stepRect.sizeDelta = Vector2(self.step.preferredWidth, 30)
        self.preview.gameObject:SetActive(false)
    else
        self.name.text = self.data.name
        -- self.lev.text = PlayerkillEumn.LevName[self.data.rank_lev]
        self.lev.text = string.format(TI18N("等级段:%s"), PlayerkillEumn.GetRankTypeName(self.data.lev, self.data.break_times))
        -- self.star.text = string.format("x%s", self.data.star)
        self.star.text = ""
        self.baseData = DataRencounter.data_info[self.data.rank_lev]
        self.step.text = string.format(TI18N("%s%s %s"), self.baseData.rencounter, self.baseData.title, self.data.star)
        self.score.text = string.format(TI18N("赛季胜场:%s/%s"), self.data.season_win_times, self.data.season_join_times)

        self.stepRect.sizeDelta = Vector2(self.step.preferredWidth, 30)

        self:UpdatePreview()
    end
end

function PlayerkillShowBestPanel:UpdatePreview()
    local callback = function(composite)
        self:SetRawImage(composite)
    end
    local setting = {
        name = "PlayerkillNo1Role"
        ,orthographicSize = 0.6
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

function PlayerkillShowBestPanel:SetRawImage(composite)
    local rawImage = composite.rawImage
    rawImage.transform:SetParent(self.preview.transform)
    rawImage.transform.localPosition = Vector3(0, 0, 0)
    rawImage.transform.localScale = Vector3(1, 1, 1)
    rawImage:SetActive(true)
    self.preview.gameObject:SetActive(true)
end


function PlayerkillShowBestPanel:showBgAni()
    if self.rotateId ~= nil then
        LuaTimer.Delete(self.rotateId)
        self.rotateId = nil
    end
    self.rotateId = LuaTimer.Add(0, 10, function() self:Rotate() end)
end

function PlayerkillShowBestPanel:Rotate()
    self.RoleBg1.transform:Rotate(Vector3(0, 0, 0.3))
    self.RoleBg2.transform:Rotate(Vector3(0, 0, -0.5))
end
