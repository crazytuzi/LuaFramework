-- ---------------------------
-- 礼包打开展示元素
-- hosr
-- ---------------------------
FaceGetItem = FaceGetItem or BaseClass()

function FaceGetItem:__init(gameObject, parent)

    self.gameObject = gameObject
    self.parent = parent
    self.gameObject:SetActive(false)
    self:InitPanel()
    self.tweedList = {}
end

function FaceGetItem:__delete()
    for k,v in pairs(self.tweedList) do
        Tween.Instance:Cancel(v)
        v = nil
    end
    if self.slot then
        self.slot:DeleteMe()
    end


    self.slot = nil
end

function FaceGetItem:InitPanel()
    self.transform = self.gameObject.transform
    self.name = self.transform:Find("Name"):GetComponent(Text)

end

-- {item_id = 10312,bind = 0,num = 1}
function FaceGetItem:SetData(data)
    self.type = data.type
    self.faceType = data.faceType
    self.data = data
     if self.type == 1 then
        self.slot = ItemSlot.New()
        UIUtils.AddUIChild(self.transform:Find("Slot").gameObject, self.slot.gameObject)
    elseif self.type == 2 then
        self.slot = FaceItem.New(self.gameObject.transform)
        self.gameObject:AddComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures,"ItemDefault")
    elseif self.type == 3 then
        self.gameObject:AddComponent(Image).sprite = self.parent.assetWrapper:GetSprite(AssetConfig.face_textures,"rightPoint")
    end

    if self.type == 1 then
        local base = BaseUtils.copytab(DataItem.data_get[self.data.item_id])
        if base == nil then
            self.slot:SetAll(nil)
            self.name.text = ""
        else
            local item = ItemData.New()
            item:SetBase(base)
            item.bind = self.data.bind
            item.quantity = self.data.number
            self.slot:SetAll(item, {nobutton = true})
            self.slot:SetNum(self.data.number)
            self.name.text = ColorHelper.color_item_name(item.quality, item.name)
        end
        self.slot.transform.localScale = Vector3.one * 2.5
        self.gameObject:SetActive(false)
    elseif self.type == 2 then
        if self.faceType == 2 then
            self.slot:Show(self.data.item_id,Vector2(9,-5),nil,Vector2(50,50))
            self.name.text = "大表情"
        else
            if self.data.item_id == 114 or self.data.item_id == 123 or self.data.item_id == 124 or self.data.item_id == 125 or self.data.item_id == 126 or self.data.item_id == 128 or self.data.item_id == 135 then
                self.slot:Show(self.data.item_id,Vector2(-4,-16),nil,Vector2(70,38))
            else
                self.slot:Show(self.data.item_id,Vector2(7.8,-11),nil,Vector2(50,50))
            end
            self.name.text = "小表情"
        end
    elseif self.type == 3 then
        self.name.gameObject:SetActive(false)
    end

end

function FaceGetItem:Show()
    local tweenId = nil
    if self.type == 1 then
        tweenId = Tween.Instance:Scale(self.slot.gameObject, Vector3.one, 0.2, nil, LeanTweenType.linear).id
        self.gameObject:SetActive(true)
    else
        tweenId =Tween.Instance:Scale(self.gameObject, Vector3.one, 0.2, nil, LeanTweenType.linear).id
        self.gameObject:SetActive(true)
    end
    self.tweedList[#self.tweedList + 1] = tweenId
end