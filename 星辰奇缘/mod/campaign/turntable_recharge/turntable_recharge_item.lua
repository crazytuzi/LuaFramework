TurnTableRechargeItem = TurnTableRechargeItem or BaseClass()

function TurnTableRechargeItem:__init(gameObject,isHasDoubleClick,index,parentWin,parentTransform)
    self.parentTransform = parentTransform
    self.index = index
    self.gameObject = gameObject
    self.parent = parent
    self.isHasDoubleClick = isHasDoubleClick
    -- local resources = {
    --   {file = AssetConfig.bible_rechargepanel_textures, type = AssetType.Dep}
    -- }
    -- self.assetWrapper = AssetBatchWrapper.New()
    -- self.assetWrapper:LoadAssetBundle(resources)

    self.effect = nil

    self.flashEffect = nil
    self.flashMoreEffect = nil

    self.beautifulEffect = nil

    self.extra = {inbag = false, nobutton = true}
    self.slot = ItemSlot.New(self.gameObject.transform:Find("ItemSlot"),isHasDoubleClick)
    self.slot:ShowBg(false)     --去掉背景（此脚本有两处）
    self.id = nil
    -- self.rotationTweenId = nil


    self.extra = {inbag = false, nobutton = true}
    self:Init()
end

function TurnTableRechargeItem:__delete()
     -- if self.rotationTweenId ~= nil then
     --    Tween.Instance:Cancel(self.rotationTweenId)
     --    self.rotationTweenId = nil
     -- end
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


function TurnTableRechargeItem:Init()
    self.transform = self.gameObject.transform
    self.bg = self.transform:Find("Bg")
    self.bg.gameObject:SetActive(false)
    self.hasGet = self.transform:Find("HasGet")
    self.hasGet.gameObject:SetActive(false)
    self.label = self.transform:Find("LabelMod")
    self.nameText = self.transform:Find("NameText"):GetComponent(Text)
end


function TurnTableRechargeItem:SetSlot(id,extro,num)
    self.id = id
    local data = DataItem.data_get[id]
    self.slot:SetAll(data,extro)
    self.slot.gameObject.gameObject:SetActive(true)
    if num ~= nil then
        self.slot:SetNum(num)
    end
    self.slot.qualityBg.gameObject:SetActive(false)
    self.nameText.text = DataItem.data_get[id].name
    self.slot:ShowBg(false)     --去掉背景（此脚本有两处）
    self.slot.selectObj:GetComponent(Image).color = Color(0,0,0,0)
    -- self.nameText.text = DataItem.data_get[self.id].name
    -- self.bgButton.onClick:AddListener(function() self:ApplyButton() end)
end

function TurnTableRechargeItem:ShowEffect(t)
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


function TurnTableRechargeItem:SetActivate(t)
    self.hasGet.gameObject:SetActive(t == 1)
    self.bg.gameObject:SetActive(t == 1)
end
function TurnTableRechargeItem:ShowBeautifulEffect(t)
    if t == 1 then
        -- if self.beautifulEffect == nil then
        --      self.beautifulEffect = BibleRewardPanel.ShowEffect(20223, self.transform, Vector3(0.9, 0.9, 1), Vector3(0, 0, -3))
        -- end
        -- self.beautifulEffect:SetActive(true)
        self.label.gameObject:SetActive(true)
    else
        -- if self.beautifulEffect ~= nil then
        --     self.beautifulEffect:SetActive(false)
        -- end
        self.label.gameObject:SetActive(false)
    end

end


-- function TurnTableRechargeItem:ShowLabel(t,str)
--     if t == true then
--        self.label.gameObject:SetActive(true)
--     else
--        self.label.gameObject:SetActive(false)
--     end
--     if str ~= nil then
--         self.labelText.text = TI18N(str)
--     end
-- end


function TurnTableRechargeItem:ActiveSelect(t)
    if t == true then
        self.slot.button.onClick:AddListener(function() self.slot:ClickSelf() end)
    else
        self.slot.button.onClick:RemoveAllListeners()
    end
end

function TurnTableRechargeItem:ShowSelect(t)
    if t == true then
        self.slot.selectObj:SetActive(true)
    else
        self.slot.selectObj:SetActive(false)
    end
end


function TurnTableRechargeItem:IsActiveSelect()
    return self.slot.selectObj.activeSelf
end


function TurnTableRechargeItem:ShowFlashEffect(t)
    if t == true then
        if self.flashEffect== nil then
             self.flashEffect = BibleRewardPanel.ShowEffect(20024, self.transform, Vector3(1, 1, 1), Vector3(2, -6, -400))
        end
        self.flashEffect:SetActive(true)
    else
        if self.flashEffect ~= nil then
            self.flashEffect:SetActive(false)
        end
    end
end


function TurnTableRechargeItem:ShowFlashMoreEffect(t)
    if t == true then
        if self.flashMoreEffect== nil then
             self.flashMoreEffect = BibleRewardPanel.ShowEffect(20025, self.transform, Vector3(1, 1, 1), Vector3(2, -6, -400))
        end
        self.flashMoreEffect:SetActive(true)
    else
        if self.flashMoreEffect ~= nil then
            self.flashMoreEffect:SetActive(false)
        end
    end
end


function TurnTableRechargeItem:ApplyButton()
   local baseId = self.id
   local data = DataItem.data_get[baseId]
   local itemData = ItemData.New()
   itemData:SetBase(data)
   TipsManager.Instance:ShowItem({gameObject = self.transform.gameObject, itemData = itemData,extra = self.extra})
end


