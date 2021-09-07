-- @author hze
-- @date #2019/05/30#
--幸运树-摇一下活动item
LuckyTreeItem = LuckyTreeItem or BaseClass()

function LuckyTreeItem:__init(transform, parent)
    self.transform = transform
    self.gameObject = transform.gameObject
    self.parent = parent
    self.__active = self.gameObject.activeSelf

    self.delta = 3 --shake偏移量
    self.x = 0  --记录偏移量比

    self:InitPanle()
end

function LuckyTreeItem:__delete()
    if self.iconloader ~= nil then
        self.iconloader:DeleteMe()
        self.iconloader = nil
    end

    if self.coolEffect ~= nil then
        self.coolEffect:DeleteMe()
        self.coolEffect = nil
    end

    if self.selectEffect ~= nil then
        self.selectEffect:DeleteMe()
        self.selectEffect = nil
    end

    if self.shakeTimer ~= nil then 
        LuaTimer.Delete(self.shakeTimer)
        self.shakeTimer = nil
    end
end

function LuckyTreeItem:Show()

end

function LuckyTreeItem:Hide()

end

function LuckyTreeItem:InitPanle()
    local t = self.transform
    self.iconImg = t:Find("IconImg")
    self.iconImg.transform.sizeDelta = Vector2(60,60)

    self.obtained = t:Find("Obtained").gameObject
    self.btn = self.transform:GetComponent(Button)

    self.numBgObj = self.transform:Find("NumBg").gameObject
    self.numTxt = self.transform:Find("NumBg/Text"):GetComponent(Text)
    
    self.select = self.transform:Find("Select").gameObject
    self.select:SetActive(false)
    
    self.btn.onClick:RemoveAllListeners()
    self.btn.onClick:AddListener(function() 
        self:OnClick()
    end)

end

function LuckyTreeItem:SetVal(data)
    self.data = data

    if self.iconloader == nil then 
        self.iconloader = SingleIconLoader.New(self.iconImg.gameObject)
    end
    self.iconloader:SetSprite(SingleIconType.Item, data.icon)

    self.obtained:SetActive(data.isFlag)

    if data.item_num == 1 then 
        self.numBgObj:SetActive(false)
    else
        self.numBgObj:SetActive(true)
        self.numTxt.text = data.item_num
    end

    if data.isEffect then
        if self.coolEffect == nil then 
            self.coolEffect = BaseUtils.ShowEffect(20443, self.iconImg, Vector3.one, Vector3(0, 0, -250))
        end
        self.coolEffect:SetActive(true)
    else
        if self.coolEffect ~= nil then 
            self.coolEffect:SetActive(false)
        end
    end
end

function LuckyTreeItem:SetSelectEffectActive(bool)
    if self.select.activeSelf ~= bool then 
        self.select:SetActive(bool)
    end
end

function LuckyTreeItem:Shake(bool)
    if self.shakeTimer ~= nil then 
        LuaTimer.Delete(self.shakeTimer)
        self.shakeTimer = nil
    end
    -- Quaternion.Euler
    if bool then 
        self.x = 0
        self.shakeTimer = LuaTimer.Add(0, 1, function()
            self.x = self.x + 36
            self.x = (self.x - 36) % 360 + 36
            local z = math.sin( self.x / 360 * math.pi)
            -- print(z * 30)
            self.transform.localRotation = Quaternion.Euler(0, 0, z*self.delta)
        end)
    end
end

function LuckyTreeItem:OnClick()
    local itemdata = ItemData.New()
    itemdata:SetBase(BackpackManager.Instance:GetItemBase(self.data.item_id))
    TipsManager.Instance:ShowItem({["gameObject"] = self.transform.gameObject, ["itemData"] = itemdata, ["extra"] = {nobutton = true}})
end
