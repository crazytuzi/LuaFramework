-- @author 黄耀聪
-- @date 2016年6月30日

MasqueradeRankItem = MasqueradeRankItem or BaseClass()

function MasqueradeRankItem:__init(model, gameObject, assetWrapper)
    self.model = model
    self.gameObject = gameObject
    self.transform = gameObject.transform
    self.assetWrapper = assetWrapper

    local t = self.transform
    self.rankText = t:Find("Rank"):GetComponent(Text)
    self.rankImage = t:Find("Rank/Image"):GetComponent(Image)
    self.nameText = t:Find("Character/Name"):GetComponent(Text)
    self.iconImage = t:Find("Character/Icon/Image"):GetComponent(Image)
    self.levText = t:Find("Lev"):GetComponent(Text)
    self.floorText = t:Find("Floor"):GetComponent(Text)
    self.jobText = t:Find("Job"):GetComponent(Text)
    self.scoreText = t:Find("Score"):GetComponent(Text)

    if t:Find("Select") ~= nil then
        self.selectObj = t:Find("Select").gameObject
    end
    if t:Find("Bg") ~= nil then
        self.bgObj = t:Find("Bg").gameObject
    end
    self.rect = gameObject:GetComponent(RectTramsform)
    self.btn = gameObject:GetComponent(Button)

    self.btn.onClick:AddListener(function()
        local model = self.model

        if model.selectObj ~= nil and not BaseUtils.isnull(model.selectObj) then
            model.selectObj:SetActive(false)
        end
        model.selectIndex = index
        self.selectObj:SetActive(true)
        model.selectObj = self.selectObj
    end)
end

function MasqueradeRankItem:__delete()
end

function MasqueradeRankItem:update_my_self(data, index)
    local model = self.model
    self.btn.enabled = (data.rank == nil and index ~= 0)
    if self.bgObj ~= nil then
        self.bgObj:SetActive(data.rank ~= nil or (index ~= nil and index % 2 == 1))
    end
    self.index = index
    if self.selectObj ~= nil then
        self.selectObj:SetActive(index ~= nil and model.selectIndex == index)
    end

    if index == nil or index == 0 then
        self.rankText.text = TI18N("榜外")
        self.rankImage.gameObject:SetActive(false)
    elseif index > 3 then
        self.rankText.text = tostring(index)
        self.rankImage.gameObject:SetActive(false)
    else
        self.rankText.text = ""
        self.rankImage.gameObject:SetActive(true)
        self.rankImage.sprite = self.assetWrapper:GetSprite(AssetConfig.rank_textures, "place_"..index)
    end

    self.nameText.text = data.name
    self.jobText.text = KvData.classes_name[data.classes]
    self.levText.text = tostring(data.lev)
    self.scoreText.text = tostring(data.score)
    self.floorText.text = tostring(DataElf.data_map[data.map_base_id].id)
    self.iconImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.heads, string.format("%s_%s", data.classes, data.sex))
end

function MasqueradeRankItem:SetActive(bool)
    self.gameObject:SetActive(bool)
end



