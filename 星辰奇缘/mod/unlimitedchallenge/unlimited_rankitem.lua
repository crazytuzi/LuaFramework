UnlimitedRankItem = UnlimitedRankItem or BaseClass()

function UnlimitedRankItem:__init(gameObject, parent)
    self.gameObject = gameObject
    self.data = nil

    self.parent = parent

    self.transform = self.gameObject.transform

    self.ImgOne = self.transform:GetComponent(Image)
    self.rankText = self.transform:Find("Rank"):GetComponent(Text)
    self.HeadImg = self.transform:Find("Head/Image"):GetComponent(Image)
    self.NameText = self.transform:Find("Name"):GetComponent(Text)
    self.TimeText = self.transform:Find("Time"):GetComponent(Text)
    self.RoundText = self.transform:Find("Round"):GetComponent(Text)
    self.transform:Find("Button"):GetComponent(Button).onClick:AddListener(function()
        self:ClickSelf()
    end)
end

--设置
function UnlimitedRankItem:InitPanel(_data)
    self.data = _data
    self.HeadImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.heads, self.data.classes.."_"..self.data.sex)
    self.NameText.text = self.data.name
    self.rankText.text = tostring(self.data.rank)
    self.TimeText.text = BaseUtils.formate_time_gap(self.data.use_time, ":", 0, BaseUtils.time_formate.HOUR)
    self.RoundText.text = self.data.wave
end

--设置索引
function UnlimitedRankItem:set_my_index(_index)
    self.item_index = _index
    if self.item_index%2 == 0 then
        --偶数
        self.ImgOne.color = ColorHelper.ListItem1
    else
        --单数
        self.ImgOne.color = ColorHelper.ListItem2
    end
end

--更新内容
function UnlimitedRankItem:update_my_self(_data, _index)
    self:set_my_index(_index)
    self.data = _data
    self.HeadImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.heads, self.data.classes.."_"..self.data.sex)
    self.NameText.text = string.format(ColorHelper.ListItemStr, self.data.name)
    self.rankText.text = string.format(ColorHelper.ListItemStr, tostring(self.data.rank))
    self.TimeText.text = string.format(ColorHelper.ListItemStr, BaseUtils.formate_time_gap(self.data.use_time, ":", 0, BaseUtils.time_formate.HOUR))
    self.RoundText.text = string.format(ColorHelper.ListItemStr, self.data.wave)
end

function UnlimitedRankItem:Refresh(args)

end

function UnlimitedRankItem:ClickSelf()
    self.parent:ShowMate(self.data)
end