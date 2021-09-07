BibleRechargeItem = BibleRechargeItem or BaseClass()

function BibleRechargeItem:__init(gameObject,isHasDoubleClick,index,parentWin,parentTransform)
    self.parentTransform = parentTransform
    self.dataList = dataList
    self.index = index
    self.gameObject = gameObject
    self.parent = parent
    self.isHasDoubleClick = isHasDoubleClick
    local resources = {
      {file = AssetConfig.bible_rechargepanel_textures, type = AssetType.Dep}
    }
    self.assetWrapper = AssetBatchWrapper.New()
    self.assetWrapper:LoadAssetBundle(resources)

    self.effect = nil

    self.flashEffect = nil
    self.flashMoreEffect = nil

    self.beautifulEffect = nil

    self.extra = {inbag = false, nobutton = true}
    self.slot = ItemSlot.New(self.gameObject.transform:Find("ItemSlot"),isHasDoubleClick)
    self.slot:ShowBg(false)
    self.id = nil
    self.rotationTweenId = nil
    self.activeSelect = false


    self.extra = {inbag = false, nobutton = true}
    self:Init()
end

function BibleRechargeItem:__delete()
     if self.rotationTweenId ~= nil then
        Tween.Instance:Cancel(self.rotationTweenId)
        self.rotationTweenId = nil
     end
    if self.effect ~= nil then
        self.effect:DeleteMe()
        self.effect = nil
    end

    if self.flashEffect ~= nil then
        self.flashEffect:DeleteMe()
        self.flashEffect = nil
    end

    if self.flashMoreEffect ~= nil then
        self.flashMoreEffect:DeleteMe()
        self.flashMoreEffect = nil
    end


    if self.beautifulEffect ~= nil then
        self.beautifulEffect:DeleteMe()
        self.beautifulEffect = nil
    end

end


function BibleRechargeItem:Init()
    self.transform = self.gameObject.transform
    self.bgImg = self.transform:GetComponent(Image)

    self.nameText = self.transform:Find("NameImage/Text"):GetComponent(Text)
    self.nameImg = self.transform:Find("NameImage"):GetComponent(Image)
    self.label = self.transform:Find("LabelMod")
    self.labelImg = self.transform:Find("LabelMod"):GetComponent(Image)
    self.labelText = self.transform:Find("LabelMod/I18N_Text"):GetComponent(Text)
    self.labelText.text = "稀有"

    self.rotationTr = self.transform:Find("rotation")

    self.flashIconTr = self.transform:Find("Flash")

    self.bgButton = self.transform:Find("Button"):GetComponent(Button)

end

function BibleRechargeItem:SetData(data)

    if data == true then
        self:ShowEffect(true)
    else
        self:ShowEffect(false)
    end
end

function BibleRechargeItem:SetSlot(id,extro,Type)
    self.type = Type
    self.id = id
    local data = DataItem.data_get[id]
    self.slot:SetAll(data,extro)
    self.slot:ShowBg(false)
    self.slot.qualityBg.gameObject:SetActive(false)
    self.nameText.text = DataItem.data_get[self.id].name
    self.bgButton.onClick:AddListener(function() self:ApplyButton() end)
end

function BibleRechargeItem:ShowEffect(t)
    if t == true then
        if self.effect == nil then
             self.effect = BibleRewardPanel.ShowEffect(20223, self.transform, Vector3(1, 1, 1), Vector3(0, 0, -3))
        end
        self.effect:SetActive(true)
    else
        if self.effect ~= nil then
            self.effect:SetActive(false)
        end
    end
end


function BibleRechargeItem:ShowBeautifulEffect(t)
    if t == true then
        if self.beautifulEffect == nil then
             self.beautifulEffect = BibleRewardPanel.ShowEffect(20384, self.transform, Vector3(0.9, 0.9, 1), Vector3(0, 0, -3))
        end
        self.beautifulEffect:SetActive(true)
    else
        if self.beautifulEffect ~= nil then
            self.beautifulEffect:SetActive(false)
        end
    end

end


function BibleRechargeItem:ShowLabel(t,str)
    if t == true then
       self.label.gameObject:SetActive(true)
    else
       self.label.gameObject:SetActive(false)
    end
    if str ~= nil then
        self.labelText.text = TI18N(str)
    end
end


function BibleRechargeItem:ActiveSelect(t)
    if t == true then
        self.slot.button.onClick:AddListener(function() self.slot:ClickSelf() end)
    else
        self.slot.button.onClick:RemoveAllListeners()
    end
end

function BibleRechargeItem:ShowSelect(t)
    if t == true then
        self.slot.selectObj:SetActive(true)
    else
        self.slot.selectObj:SetActive(false)
    end
end


function BibleRechargeItem:IsActiveSelect()
    return self.slot.selectObj.activeSelf
end


function BibleRechargeItem:ShowFlashEffect(t)
    if t == true then
        if self.flashEffect== nil then
             self.flashEffect = BibleRewardPanel.ShowEffect(20382, self.transform, Vector3(1, 1, 1), Vector3(0, 0, -2))
        end
        self.flashEffect:SetActive(true)
    else
        if self.flashEffect ~= nil then
            self.flashEffect:SetActive(false)
        end
    end
end


function BibleRechargeItem:ShowFlashMoreEffect(t)
    if t == true then
        if self.flashMoreEffect== nil then
             self.flashMoreEffect = BibleRewardPanel.ShowEffect(20383, self.transform, Vector3(1, 1, 1), Vector3(0, 0, -2))
        end
        self.flashMoreEffect:SetActive(true)
    else
        if self.flashMoreEffect ~= nil then
            self.flashMoreEffect:SetActive(false)
        end
    end
end

function BibleRechargeItem:ShowDevelop(num)

    if num == 3 then
        self.bgImg.sprite = self.assetWrapper:GetSprite(AssetConfig.bible_rechargepanel_textures,"itemimg2")
        self.nameImg.sprite = self.assetWrapper:GetSprite(AssetConfig.bible_rechargepanel_textures,"textbg")
        self.nameImg.color = Color(1,1,1,1)
        self.rotationTr.gameObject:SetActive(true)
        self.flashIconTr.gameObject:SetActive(false)
        self:RotationBg()
    else
        if self.rotationTweenId ~= nil then
          Tween.Instance:Cancel(self.rotationTweenId)
          self.rotationTweenId = nil
        end
        self.bgImg.sprite = self.assetWrapper:GetSprite(AssetConfig.bible_rechargepanel_textures,"itemBg")
        self.nameImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures,"SkillNameBg")
        self.nameImg.color = Color(1,1,1,79/255)
        self.rotationTr.gameObject:SetActive(false)
        if num == 1 then
            self.flashIconTr.gameObject:SetActive(false)
        else
            self.flashIconTr.gameObject:SetActive(true)
        end
    end
end


function BibleRechargeItem:RotationBg()
    if self.rotationTweenId == nil then
        self.rotationTweenId  = Tween.Instance:ValueChange(0,360,4, function() self.rotationTweenId = nil self:RotationBg(callback) end, LeanTweenType.Linear,function(value) self:RotationChange(value) end).id
    end
end

function BibleRechargeItem:RotationChange(value)
   self.rotationTr.localRotation = Quaternion.Euler(0, 0, value)
end


function BibleRechargeItem:ApplyButton()
   local baseId = self.id
   local data = DataItem.data_get[baseId]
   local itemData = ItemData.New()
   itemData:SetBase(data)
   TipsManager.Instance:ShowItem({gameObject = self.transform.gameObject, itemData = itemData,extra = self.extra})
end

function BibleRechargeItem:Hide()
    if self.rotationTweenId ~= nil then
       Tween.Instance:Cancel(self.rotationTweenId)
        self.rotationTweenId = nil
    end
end


