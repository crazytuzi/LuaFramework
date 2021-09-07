-- zzl
-- 2016/7/6

ExamFinalRankListItem = ExamFinalRankListItem or BaseClass()

function ExamFinalRankListItem:__init(gameObject, parent)
    self.gameObject = gameObject
    self.data = nil
    self.parent = parent

    local itr = self.gameObject.transform

    self.transform = self.gameObject.transform
    self.ImgBg = self.transform:FindChild("Bg"):GetComponent(Image)


    self.TxtRank = self.transform:FindChild("Rank"):GetComponent(Text)
    self.ImgRank = self.transform:FindChild("Rank"):FindChild("Image"):GetComponent(Image)

    self.Character = self.transform:FindChild("Character")

    self.Icon = self.Character:FindChild("Icon")
    self.ImgHead = self.Icon:FindChild("ImgHead"):GetComponent(Image)
    self.Name = self.Character:FindChild("Name"):GetComponent(Text)


    self.Lev = self.transform:FindChild("Lev"):GetComponent(Text)
    self.Job = self.transform:FindChild("Job"):GetComponent(Text)
    self.Floor = self.transform:FindChild("Floor"):GetComponent(Text)

end

function ExamFinalRankListItem:Release()

end

function ExamFinalRankListItem:Refresh()

end

function ExamFinalRankListItem:update_my_self(_data, item_index)
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

    self.Name.text = _data.name
    self.Lev.text = "" --tostring(1)
    self.Job.text = KvData.classes_name[_data.classes]
    self.Floor.text = tostring(_data.score)


    self.ImgHead.sprite = PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.heads , string.format("%s_%s",tostring(_data.classes),tostring(_data.sex)))
    self.ImgHead.gameObject:SetActive(true)
end