-- 天下第一武道会，每项ITEM
-- @author zgs
NoOneRankItem = NoOneRankItem or BaseClass()

function NoOneRankItem:__init(gameObject, panel)
    self.gameObject = gameObject
    self.transform = self.gameObject.transform

    self.data = nil
    self.index = 1

    self.panel = panel

    self.isNeedShowTips = true

    self.noText = self.gameObject.transform:Find("RankValue"):GetComponent(Text)
    self.noImg = self.gameObject.transform:Find("RankValue/RankImage"):GetComponent(Image)
    -- self.classImg = self.gameObject.transform:Find("Character/Icon/Image"):GetComponent(Image)
    self.nameText = self.gameObject.transform:Find("Character/Name"):GetComponent(Text)
    self.nameText.gameObject:GetComponent(RectTransform).anchoredPosition = Vector2(50,0)
    self.classText = self.gameObject.transform:Find("Job"):GetComponent(Text)
    self.levText = self.gameObject.transform:Find("Score"):GetComponent(Text)
    self.transform:GetComponent(Button).onClick:AddListener(function()
        self:OnClickSelf()
    end)
    -- self.levText = self.gameObject.transform:Find("TxtLev"):GetComponent(Text)
    -- self.posText = self.gameObject.transform:Find("TxtPos"):GetComponent(Text)
    -- self.gxText = self.gameObject.transform:Find("TxtGx"):GetComponent(Text)
    -- self.cupText = self.gameObject.transform:Find("TxtCup"):GetComponent(Text)
    -- self.lastLoginext = self.gameObject.transform:Find("TxtLastLogin"):GetComponent(Text)
    self.headImg = self.gameObject.transform:Find("Character/Icon/Image"):GetComponent(Image)
    local rect = self.headImg.gameObject:GetComponent(RectTransform)
    rect.anchorMax = Vector2(0.5,0.5)
    rect.anchorMin = Vector2(0.5,0.5)
    -- rect.offsetMin = Vector2.zero
    -- rect.offsetMax = Vector2.zero
    self.headImg.gameObject:GetComponent(RectTransform).anchoredPosition = Vector2(0,0)
    self.headImg.gameObject:SetActive(false)
    self.bgImg = self.gameObject.transform:Find("Bg"):GetComponent(Image)
    -- self.tog = self.gameObject.transform:Find("Toggle"):GetComponent(Toggle)
    -- self.tog.onValueChanged:AddListener(function(status) self:OnCheck(status) end)
end

function NoOneRankItem:InitPanel(_data)
    self:update_my_self(_data)
end

--设置索引
function NoOneRankItem:set_my_index(_index)
    self.index = _index
    if self.index % 2 == 0 then
        self.bgImg.color = Color32(129, 179, 233,255)
    else
        self.bgImg.color = Color32(155, 198, 239,255)
    end
end

--更新内容
function NoOneRankItem:update_my_self(_data, _index)
    -- BaseUtils.dump(_data,"NoOneRankItem:update_my_self ========== ")
    self.data = _data
    self:set_my_index(_index)
    -- self.tog.isOn = self.lastTogOn
    local v = self.data
    self.headImg.sprite = PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.heads , string.format("%s_%s",tostring(v.classes),tostring(v.sex)))
    self.headImg.gameObject:SetActive(true)
    self.nameText.text = v.name
    self.classText.text = KvData.classes_name[v.classes]
    if v.rank_lev ~= nil then
        self.levText.text = DataTournament.data_list[v.rank_lev].name
    elseif v.val1 ~= nil then
        self.levText.text = tostring(v.val1)
        -- if self.panel.showType == 4 then
        --     if self.panel.subIndex == 4 then
        --         self.levText.text = tostring(v.val1) .. "(万)"
        --     end
        -- end
    end
    self.noText.text = tostring(self.index)
    if self.index < 4 then
        self.noImg.gameObject:SetActive(true)
        self.noImg.sprite = self.panel.assetWrapper:GetSprite(AssetConfig.glory_textures, "place_"..self.index)
        self.noImg:SetNativeSize()
    else
        self.noImg.gameObject:SetActive(false)
    end
end

function NoOneRankItem:OnClickSelf()
    TipsManager.Instance:ShowPlayer(self.data)
end
