-- zzl
-- 2016/7/6

ExamFinalRankItem = ExamFinalRankItem or BaseClass()

function ExamFinalRankItem:__init(gameObject, parent)
    self.gameObject = gameObject
    self.data = nil
    self.parent = parent

    local itr = self.gameObject.transform

    self.transform = self.gameObject.transform
    self.ImgBg = self.transform:GetComponent(Image)


    self.ImgRank = self.transform:FindChild("ImgRank"):GetComponent(Image)
    self.TxtRank = self.transform:FindChild("TxtRank"):GetComponent(Text)
    self.TxtName = self.transform:FindChild("TxtName"):GetComponent(Text)
    self.TxtScore = self.transform:FindChild("TxtScore"):GetComponent(Text)

    -- self.TxtRank.fontSize = 16
    -- self.TxtName.fontSize = 16
    -- self.TxtScore.fontSize = 16
end

function ExamFinalRankItem:Release()

end

function ExamFinalRankItem:Refresh()

end

function ExamFinalRankItem:update_my_self(_data, item_index)
    self.data = _data

    if item_index%2 == 0 then
        --偶数
        self.ImgBg.color = ColorHelper.ListItem1
    else
        --单数
        self.ImgBg.color = ColorHelper.ListItem2
    end
    self.ImgRank.gameObject:SetActive(false)
    self.TxtRank.text = ""

    if item_index == 1 then
        self.ImgRank.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "iconFirst")
        self.ImgRank.gameObject:SetActive(true)
    elseif item_index == 2 then
        self.ImgRank.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "iconsecond")
        self.ImgRank.gameObject:SetActive(true)
    elseif item_index == 3 then
        self.ImgRank.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "iconthree")
        self.ImgRank.gameObject:SetActive(true)
    else
        self.TxtRank.text = tostring(item_index)
    end

    self.TxtName.text = _data.name
    self.TxtScore.text = tostring(_data.score)
end