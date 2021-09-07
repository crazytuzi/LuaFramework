RideSelectItem = RideSelectItem or BaseClass()

function RideSelectItem:__init(parent, origin_item, index)
    self.index = index
    self.parent = parent
    self.gameObject = GameObject.Instantiate(origin_item)
    self.transform = self.gameObject.transform
    self.transform:SetParent(origin_item.transform.parent)
    self.transform.localScale = Vector3.one

    self.transform:GetComponent(Button).onClick:AddListener(function()
        self:OnClick()
    end)

    self.HeadCon = self.transform:FindChild("HeadCon")
    self.Head = self.HeadCon:FindChild("Head"):GetComponent(Image)

    self.LVText = self.transform:FindChild("LVText"):GetComponent(Text)
    self.NameText = self.transform:FindChild("NameText"):GetComponent(Text)

    self.LVText.text = ""
    self.NameText.text = ""

    --根据index 设置gameObject的位置
    local newY = (index - 1)*-80
    local rect = self.transform:GetComponent(RectTransform)
    rect.anchoredPosition = Vector2(5.2, newY)

end

function RideSelectItem:Release()

end


function RideSelectItem:set_item_data(data, callback)
    self.data = data
    self.callback = callback

    self.Head.sprite = self.parent.assetWrapper:GetSprite(AssetConfig.headride, data.base.head_id)
    self.LVText.text = string.format("Lv.%s", data.lev)
    self.NameText.text = data.base.name
end

function RideSelectItem:OnClick()
    if self.callback ~= nil then
        self.callback(self.data)
        self.parent.model:CloseRideSelectUI()
    else
        self.parent:item_click(self.data)
    end 
end