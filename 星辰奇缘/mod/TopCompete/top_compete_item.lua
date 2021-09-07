TopCompeteItem = TopCompeteItem or BaseClass()

function TopCompeteItem:__init(gameObject, parent)
    self.parent = parent
    self.gameObject = gameObject
    self.transform = self.gameObject.transform
    self.bg =  self.transform:FindChild("bg"):GetComponent(Image)
    self.ImgClasses= self.transform:FindChild("ImgClasses"):GetComponent(Image)
    self.ImgClasses.gameObject:SetActive(false)
    self.TxtClasses= self.transform:FindChild("TxtClasses"):GetComponent(Text)
    self.ImgCon = self.transform:FindChild("ImgHead")
    self.ImgHead = self.ImgCon:FindChild("Img"):GetComponent(Image)
    self.TxtName= self.transform:FindChild("TxtName"):GetComponent(Text)
    self.TxtAtScore= self.transform:FindChild("TxtAtScore"):GetComponent(Text)
    self.TxtAdd = self.transform:FindChild("TxtAdd"):GetComponent(Text)
    self.TxtScore =  self.transform:FindChild("TxtScore"):GetComponent(Text)

    self.ImgCon.gameObject:SetActive(false)
end

function TopCompeteItem:Release()
    self.ImgClasses.sprite = nil
    self.ImgHead.sprite = nil
end

function TopCompeteItem:InitPanel(_data)

end

function TopCompeteItem:update_my_self(data, index)
    self.data = data
    if index%2 == 0 then
        --偶数
        self.bg.color = ColorHelper.ListItem1
    else
        --单数
        self.bg.color = ColorHelper.ListItem2
    end

    self.ImgClasses.sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, "ClassesIcon_" ..  tostring(data.classes))
    self.ImgClasses.gameObject:SetActive(true)
    self.TxtClasses.text = string.format(ColorHelper.ListItemStr, string.format("%s%s", TI18N("首席"),KvData.classes_name[data.classes]))
    self.TxtName.text = string.format(ColorHelper.ListItemStr, data.name)
    self.TxtAtScore.text = string.format(ColorHelper.ListItemStr, tostring(data.score))
    self.TxtAdd.text = string.format(ColorHelper.ListItemStr, tostring(math.floor(data.rank_point*0.05)))
    self.TxtScore.text = string.format(ColorHelper.ListItemStr, tostring(data.score+math.floor(data.rank_point*0.05)))
    self.ImgHead.sprite =  PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.heads , string.format("%s_%s",tostring(data.classes),tostring(data.sex)))

    self.ImgCon.gameObject:SetActive(true)
end

function TopCompeteItem:Refresh()

end