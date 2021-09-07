GivePresentPlayerItem = GivePresentPlayerItem or BaseClass()

function GivePresentPlayerItem:__init(gameObject, args)
    self.gameObject = gameObject
    self.transform = self.gameObject.transform
    self.data = nil
    self.args = args
    self.index = 1
    self.assetWrapper = args.assetWrapper
end

function GivePresentPlayerItem:Release()

end

function GivePresentPlayerItem:InitPanel(_data)
    self.data = _data.data
    self.transform:Find("NameText"):GetComponent(Text).text = self.data.name
    self.transform:Find("Head"):GetComponent(Image).sprite = self:GetHead(self.data.classes, self.data.sex)
    self.transform:Find("Head").gameObject:SetActive(true)
    self.transform:Find("FriendshipText"):GetComponent(Text).text = FriendManager.Instance:GetIntimacy(self.data.id, self.data.platform, self.data.zone_id)
    self.transform:Find("FriendshipText").gameObject:SetActive(self.data.intimacy ~= nil)
    self.transform:Find("hart").gameObject:SetActive(self.data.intimacy ~= nil)
    self.transform:Find("NotFriendText").gameObject:SetActive(self.data.intimacy == nil)
    self.transform:Find("LevText"):GetComponent(Text).text = tostring(self.data.lev)
    self.index = _data.item_index
    if _data.item_index == 1 then
        self.args.onclick(self.gameObject, self.data)
    end
    self.transform:GetComponent(Button).onClick:AddListener(function() self.args.onclick(self.gameObject, self.data) end)
end

function GivePresentPlayerItem:Refresh(_data)
    self.data = _data[self.index]
    self.transform:Find("NameText"):GetComponent(Text).text = self.data.name
    self.transform:Find("Head"):GetComponent(Image).sprite = self:GetHead(self.data.classes, self.data.sex)
    self.transform:Find("Head").gameObject:SetActive(true)
    self.transform:Find("FriendshipText"):GetComponent(Text).text = FriendManager.Instance:GetIntimacy(self.data.id, self.data.platform, self.data.zone_id)
    self.transform:Find("FriendshipText").gameObject:SetActive(self.data.intimacy ~= nil)
    self.transform:Find("hart").gameObject:SetActive(self.data.intimacy ~= nil)
    self.transform:Find("NotFriendText").gameObject:SetActive(self.data.intimacy == nil)
    self.transform:Find("LevText"):GetComponent(Text).text = tostring(self.data.lev)
end

function GivePresentPlayerItem:GetHead(classes, sex)
    local name = tostring(classes) .. "_" .. tostring(sex)
    local sprite = self.assetWrapper:GetSprite(AssetConfig.heads, name)
    return sprite
end