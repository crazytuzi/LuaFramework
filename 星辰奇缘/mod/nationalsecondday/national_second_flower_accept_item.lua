NationalSecondFlowerAcceptItem = NationalSecondFlowerAcceptItem or BaseClass()

function NationalSecondFlowerAcceptItem:__init(gameObject,isHasDoubleClick,index,parentWin,parentTransform)
    self.parentTransform = parentTransform
    self.index = index
    self.gameObject = gameObject
    self.parent = parentWin
    self.isHasDoubleClick = isHasDoubleClick
    -- self.effect = nil

    -- self.flashMoreEffect = nil

    self.extra = {inbag = false, nobutton = true}
    self.slot = ItemSlot.New(self.gameObject.transform:Find("ItemSlot"),isHasDoubleClick)
    self.slot:ShowBg(false)
    self.id = nil
    self.extra = {inbag = false, nobutton = true}
    self.isFlash = false
    self.isSelect = false
    self.isBig = false
    self.isBig2 = false
    self.firstEffect = nil

    self:Init()
end

function NationalSecondFlowerAcceptItem:__delete()
    -- if self.effect ~= nil then
    --     self.effect:DeleteMe()
    --     self.effect = nil
    -- end

    -- if self.flashMoreEffect ~= nil then
    --     self.flashMoreEffect:DeleteMe()
    --     self.flashMoreEffect = nil
    -- end
    if self.tweenScalerId ~= nil then
        Tween.Instance:Cancel(self.tweenScalerId)
        self.tweenScalerId = nil
    end

    if self.tweenScalerId2 ~= nil then
        Tween.Instance:Cancel(self.tweenScalerId2)
        self.tweenScalerId2 = nil
    end

end


function NationalSecondFlowerAcceptItem:Init()
    self.transform = self.gameObject.transform
    self.normalBg = self.transform:Find("NormalBg")
    self.selectBg = self.transform:Find("SelectBg")
    self.notFlashBg = self.transform:Find("Bg")
    self.notFlashCircle = self.transform:Find("NormalBg/NotFlashCircle")
    self.flashCircle = self.transform:Find("NormalBg/FlashCircle")
    self.selectBg.gameObject:SetActive(false)
    self.rotationSelect = self.transform:Find("RotationSelect")
    self.nameText = self.transform:Find("NameText"):GetComponent(Text)
    self.nameText.fontSize = 20
    self.nameText.gameObject:SetActive(false)
    self.selectBtn = self.transform:Find("SelectButton"):GetComponent(Button)
    self.selectBtn.gameObject:SetActive(false)
    self.selectBtn.onClick:AddListener(function() self.parent:ApplyButton(self) end)
end


function NationalSecondFlowerAcceptItem:SetSlot(id,extro,num)
    self.id = id
    local data = DataItem.data_get[id]
    self.slot:SetAll(data,extro)
    self.slot.gameObject.gameObject:SetActive(true)
    if num ~= nil then
        self.slot:SetNum(num)
    end
    self.slot.qualityBg.gameObject:SetActive(false)
    self.nameText.text = string.format("<color='#FFFF00'>%s</color>",DataItem.data_get[id].name)
    self.slot:ShowBg(false)
    self.slot.selectObj:GetComponent(Image).color = Color(0,0,0,0)
    self.slot:SetNotips()
    -- self.slot.button.onClick:RemoveAllListeners()
    -- self.slot.button.onClick:AddListener(function() self.parent:ApplyButton(self) end)
end



-- function NationalSecondFlowerAcceptItem:ShowEffect(t)
--     if t == true then
--         if self.effect == nil then
--              self.effect = BibleRewardPanel.ShowEffect(20223, self.transform, Vector3(1, 1, 1), Vector3(0, 0, -3))
--         end
--         self.effect:SetActive(true)

--     else
--         if self.effect ~= nil then
--             self.effect:SetActive(false)
--         end

--     end
-- end
function NationalSecondFlowerAcceptItem:IsFlash(t)
    if t ~= nil then
        self.isFlash = t
    end
    if self.isFlash == true then
        self.notFlashBg.gameObject:SetActive(false)
        self.notFlashCircle.gameObject:SetActive(false)
        self.flashCircle.gameObject:SetActive(true)
        self.slot.imgLoader:SetIconColor(Color(1,1,1,1))
        if self.firstEffect == nil then
            self.firstEffect = BibleRewardPanel.ShowEffect(20421, self.flashCircle.gameObject.transform, Vector3(1,1,1), Vector3(0,0, -50))
        end
        self.firstEffect:SetActive(true)
    else
        self.notFlashBg.gameObject:SetActive(true)
        self.notFlashCircle.gameObject:SetActive(true)
        self.flashCircle.gameObject:SetActive(false)
        self.slot.imgLoader:SetIconColor(Color(1,1,1,0.5))
        if self.firstEffect ~= nil then
            self.firstEffect:SetActive(false)
        end
    end

end

function NationalSecondFlowerAcceptItem:ApplyButton(t)
    self:ButtonChange(t)
    if t == true then
        if self.tweenScalerId == nil and self.isBig == false then
            self.tweenScalerId = Tween.Instance:Scale(self.transform.gameObject, Vector3(1.18,1.18,1),0.12, function()  end, LeanTweenType.easeOutQuad):setLoopPingPong(1).id
            self.isBig = true
        end
    end
end

function NationalSecondFlowerAcceptItem:RefreshBig()
    self.transform.gameObject.localScale = Vector3(1,1,1)
end


function NationalSecondFlowerAcceptItem:ButtonChange(t)
    self.selectBg.gameObject:SetActive(t)
    self.nameText.gameObject:SetActive(t)

    if self.tweenScalerId ~= nil then
        Tween.Instance:Cancel(self.tweenScalerId)
        self.tweenScalerId = nil
    end

    if self.tweenScalerId2 ~= nil then
        Tween.Instance:Cancel(self.tweenScalerId2)
        self.tweenScalerId2 = nil
        self.isBig2 = false
    end

    self.transform.localScale = Vector3(1,1,1)

    if t == true then
        self.slot.transform.anchoredPosition = Vector2(-73,-23)
        self.notFlashBg.gameObject:SetActive(false)
        self.rotationSelect.gameObject:SetActive(false)
        if self.firstEffect ~= nil then
            self.firstEffect:SetActive(false)
        end
    else
        self.slot.transform.anchoredPosition = Vector2(-38.7,-13)
        self.rotationSelect.gameObject:SetActive(false)
        if self.isFlash == false then
            self.notFlashBg.gameObject:SetActive(true)
        end
    end


end

function NationalSecondFlowerAcceptItem:ApplyBig()
    if self.tweenScalerId2 == nil and self.isBig2 == false then
        self.tweenScalerId2 = Tween.Instance:Scale(self.transform.gameObject, Vector3(1.05,1.05,1.05),0.2, function()  self.isBig2 = false end, LeanTweenType.easeOutQuad).id
        self.isBig2 = true
    end
end

function NationalSecondFlowerAcceptItem:ShowSelectBg(t)
    self.rotationSelect.gameObject:SetActive(t)
    self.isSelect = t
end

function NationalSecondFlowerAcceptItem:GetSelectBg()
    return self.isSelect
end




