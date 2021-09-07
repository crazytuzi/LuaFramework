-- region *.lua
-- Date 2017-4-28 jia
-- 套娃奖励item
-- endregion
DollsRandomRewardItem = DollsRandomRewardItem or BaseClass(BasePanel)
function DollsRandomRewardItem:__init(callback)
   -- self.parent = parent
    self.callback = callback
    self.resList = {
        { file = AssetConfig.dollsrandomrewarditem, type = AssetType.Main }
    }
    self.hasInit = false
    self.gameObject = nil
    self.delateTimer = nil
    self.slot = nil
    self.floatCounter = 0
    self.gameObject = nil
end

function DollsRandomRewardItem:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.dollsrandomrewarditem))
    self.gameObject.name = "DollsRandomRewardItem"
   
    self.transform = self.gameObject.transform
    self.transform.localScale = Vector3.one
    self.transform.localPosition = Vector3.zero

    self.TxtItemName = self.transform:Find("TxtItemName"):GetComponent(Text)

    self.slot = ItemSlot.New()
    UIUtils.AddUIChild(self.gameObject, self.slot.gameObject)
    self.slot.gameObject:SetActive(false)
    self.TxtItemName.gameObject:SetActive(false)
    if self.callback ~= nil then
        self.callback()
    end
end

function DollsRandomRewardItem:__delete()
    if self.shakeID ~= nil then
        Tween.Instance:Cancel(self.shakeID)
        self.shakeID = nil
    end
    if self.delateTimer ~= nil then
        LuaTimer.Delete(self.delateTimer)
        self.delateTimer = nil
    end
    if not BaseUtils.isnull(self.gameObject) then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function DollsRandomRewardItem:SetData(data)
    if data ~= nil then
        local itemData = BackpackManager.Instance:GetItemBase(data.base_id)
        local quality = itemData.quality or  1
        itemData.show_num = true
        itemData.quantity = data.num
        itemData.bind = data.bind
        self.slot:SetAll(itemData, nil)
        self.TxtItemName.text = ColorHelper.color_item_name(quality, itemData.name)
    end
end

function DollsRandomRewardItem:StartShake(delateTime)
    self.achPointX = self.transform:GetComponent(RectTransform).localPosition.x
    self.achPointY = self.transform:GetComponent(RectTransform).localPosition.y
    self.slot.gameObject:SetActive(false)
    self.TxtItemName.gameObject:SetActive(false)
    if tonumber(delateTime) > 0 then
        self.delateTimer = LuaTimer.Add(delateTime,
        function()
            self:StartShake(0)
        end )
    else
        if self.delateTimer ~= nil then
            LuaTimer.Delete(self.delateTimer)
            self.delateTimer = nil
        end
        self.achPointY = self.achPointY - 80
        self.transform:GetComponent(RectTransform).localPosition = Vector2(self.achPointX, self.achPointY)
        self.slot.gameObject:SetActive(true)
        self.TxtItemName.gameObject:SetActive(true)

        self.shakeID = Tween.Instance:MoveLocalY(self.gameObject, self.achPointY + 80, 0.2,
        function()
            if self.shakeID ~= nil then
                Tween.Instance:Cancel(self.shakeID)
                self.shakeID = nil
            end
            self.achPointY = self.achPointY + 80
            self.delateTimer = LuaTimer.Add(0, 16, function() self:FloatIcon() end)
        end , LeanTweenType.linear).id
    end
end

function DollsRandomRewardItem:FloatIcon()
    self.floatCounter = self.floatCounter + 1
    self.transform:GetComponent(RectTransform).localPosition = Vector2(self.achPointX, self.achPointY + 6 + 10 * math.sin(self.floatCounter * math.pi / 90 * 1.5))
end
