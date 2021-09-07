GuildMergeItem = GuildMergeItem or BaseClass()

function GuildMergeItem:__init(parent, gameObject, index)
    self.parent = parent
    self.gameObject = GameObject.Instantiate(gameObject)
    self.transform = self.gameObject.transform
    self.transform:SetParent(gameObject.transform.parent)
    self.transform.localScale = Vector3.one
    self.data = nil
    self.index = index

    self.bg =  self.transform:FindChild("bg"):GetComponent(Image)
    self.selBg= self.transform:FindChild("selBg"):GetComponent(Image)
    self.selBg.gameObject:SetActive(false)
    self.TxtName= self.transform:FindChild("TxtName"):GetComponent(Text)
    self.TxtLev= self.transform:FindChild("TxtLev"):GetComponent(Text)
    self.TxtNum= self.transform:FindChild("TxtNum"):GetComponent(Text)
    self.TxtNumRect = self.transform:FindChild("TxtNum"):GetComponent(RectTransform)
    self.TxtLeader= self.transform:FindChild("TxtLeader"):GetComponent(Text)
    self.ImgToTem =  self.transform:FindChild("ImgTuTeng"):GetComponent(Image)

    local newY = (index - 1)*-47
    local rect = self.transform:GetComponent(RectTransform)
    rect.anchoredPosition = Vector2(0, newY)

    self.gameObject:GetComponent(Button).onClick:AddListener(function() self.parent:on_select_item(self)  end)
end

function GuildMergeItem:Release()
    self.ImgToTem.sprite = nil
end

function GuildMergeItem:InitPanel(_data)
    self.data = _data

    self.TxtName.text = self.data.Name
    self.TxtLev.text = tostring(self.data.Lev)

    local fenzi = self.data.MemNum + self.data.FreshNum
    local fenmu = self.data.MaxMemNum + self.data.MaxFreshNum

    self.TxtNum.text = string.format(ColorHelper.ListItemStr, string.format("%s/%s", fenzi , fenmu))
    self.TxtNumRect.sizeDelta = Vector2(self.TxtNum.preferredWidth, 30)
    self.TxtLeader.text = string.format(ColorHelper.ListItemStr, self.data.LeaderName)

    self.ImgToTem.sprite = self.parent.assetWrapper:GetSprite(AssetConfig.guild_totem_icon , tostring(self.data.ToTem))


    if self.index%2 == 0 then
        --偶数
        self.bg.color = ColorHelper.ListItem1
    else
        --单数
        self.bg.color = ColorHelper.ListItem2
    end
end

function GuildMergeItem:Refresh()

end

function GuildMergeItem:on_set_selected_state(state)
    self.selBg.gameObject:SetActive(state)
end