-- @author 黄耀聪
-- @date 2016年7月22日

AuctionMyItem = AuctionMyItem or BaseClass()

function AuctionMyItem:__init(model, gameObject, callback)
    self.model = model
    self.gameObject = gameObject
    self.transform = gameObject.transform
    self.callback = callback

    local t = self.transform
    self.item = t:Find("Item")
    self.nameText = t:Find("Name"):GetComponent(Text)
    self.priceText = t:Find("Price/Text"):GetComponent(Text)
    self.button = t:Find("Button"):GetComponent(Button)
    self.btn = gameObject:GetComponent(Button)
    self.slot = nil
    self.itemdata = nil

    self.btn.onClick:AddListener(function()
        if self.idx ~= nil and self.callback ~= nil then
            self.callback(self.idx)
        end
    end)

    self.button.onClick:AddListener(function() self:OnClick() end)
end

function AuctionMyItem:__delete()
    if self.slot ~= nil then
        self.slot:DeleteMe()
        self.slot = nil
    end
end

function AuctionMyItem:update_my_self(data, index)
    local model = self.model
    if self.idx ~= nil and model.mylist[self.idx] ~= nil then
        model.mylist[self.idx].item = nil
    end
    self.idx = data.idx
    data.item = self

    local basedata = DataItem.data_get[data.item_id]
    self.nameText.text = basedata.name
    if self.itemdata == nil then
        self.itemdata = ItemData.New()
        self.slot = ItemSlot.New()
        NumberpadPanel.AddUIChild(self.item, self.slot.gameObject)
    end
    self.itemdata:SetBase(basedata)
    self.slot:SetAll(self.itemdata, {inbag = false, nobutton = true})
    self.priceText.text = tostring(data.gold)
end

function AuctionMyItem:SetActive(bool)
    self.gameObject:SetActive(bool)
end

function AuctionMyItem:OnClick()
    local model = self.model
    model.selectIdx = self.idx
    if self.callback ~= nil then
        self.callback(self.idx)
    end
    model:OpenOperation()
end


