NewYearTurnableItem = NewYearTurnableItem or BaseClass()

function NewYearTurnableItem:__init(gameObject,isHasDoubleClick,index,parentWin,parentTransform)
    self.parentTransform = parentTransform
    self.index = index
    self.gameObject = gameObject
    self.parent = parent
    self.isHasDoubleClick = isHasDoubleClick
    local resources = {
       {file = AssetConfig.turnable_texture, type = AssetType.Dep}
    }
    self.assetWrapper = AssetBatchWrapper.New()
    self.assetWrapper:LoadAssetBundle(resources)

    self.effect = nil

    self.flashEffect = nil
    self.flashMoreEffect = nil

    self.beautifulEffect = nil

    self.id = nil
    -- self.rotationTweenId = nil

    self.imgLoader = nil

    self.extra = {inbag = false, nobutton = true}
    self:Init()
end

function NewYearTurnableItem:__delete()
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

    if self.icon ~= nil then
        BaseUtils.ReleaseImage(self.icon)
    end
    if self.level:GetComponent(Image) ~= nil then
        BaseUtils.ReleaseImage(self.level:GetComponent(Image))
    end
    if self.Weight:GetComponent(Image) ~= nil then
        BaseUtils.ReleaseImage(self.Weight:GetComponent(Image))
    end

    if self.assetWrapper ~= nil then
        self.assetWrapper:DeleteMe()
        self.assetWrapper = nil
    end

end


function NewYearTurnableItem:Init()
    self.transform = self.gameObject.transform
    self.px = self.transform.anchoredPosition.x
    self.py = self.transform.anchoredPosition.y
    self.iconBg = self.transform:GetComponent(Image)

    self.iconTrans = self.transform:Find("Icon")
    self.icon = self.transform:Find("Icon"):GetComponent(Image)

    self.level = self.transform:Find("Level")
    self.level.gameObject:SetActive(false)

    self.Weight = self.transform:Find("Weight")
    self.Weight.gameObject:SetActive(false)

    self.selected = self.transform:Find("Selected")
    self.selected.gameObject:SetActive(false)
    self.Num = self.transform:Find("Num"):GetComponent(Text)


end


function NewYearTurnableItem:SetData(id,index)
    self.id = tonumber(id) 
    --tonumber(DataItem.data_get[tonumber(self.id)].icon) == 90002 and 
    if index > 0 and index < 4 then
        --self.level.gameObject:SetActive(true)
        --self.Weight.gameObject:SetActive(true)
        if index == 1 then
            self.level:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.turnable_texture,"specialaward")
            self.Weight:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.turnable_texture,"ThirdtyPercent")
            self:ShowEffect(true,20443)
        elseif index == 2 then
            self.level:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.turnable_texture,"firstprize")
            self.Weight:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.turnable_texture,"TenPercent")
            --self.Weight.gameObject:SetActive(false)
            self:ShowEffect(true,20444)
        elseif index == 3 then
            self.level:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.turnable_texture,"secondprize")
            self.Weight:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.turnable_texture,"fivePercent")
            self:ShowEffect(true,20444)

        -- elseif index == 4 then
        --     self.level.gameObject:SetActive(false)
        --     self.Weight:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.turnable_texture,"fivePercent")
        --     self:ShowEffect(true,20444)
        end
        self.level.gameObject:SetActive(true)
        self.Weight.gameObject:SetActive(true)
    end
    if index == 4 then
        self:ShowEffect(true,20327)
    end
    if self.imgLoader == nil then
        self.imgLoader = SingleIconLoader.New(self.iconTrans.gameObject)
    end
    self.imgLoader:SetSprite(SingleIconType.Item, DataItem.data_get[tonumber(self.id)].icon)
    self.selected:GetComponent(Image).color = Color(0,0,0,0)

    self:ShowFlashEffect(true,index)

end

function NewYearTurnableItem:ShowEffect(t,id)
    if t == true and id ~= nil then
        if self.effect == nil then
             self.effect = BibleRewardPanel.ShowEffect(id, self.transform, Vector3(0.75, 0.75, 0.75), Vector3(0, 0, -400))
        end
        self.effect:SetActive(true)

    else
        if self.effect ~= nil then
            self.effect:SetActive(false)
        end
    end
end


function NewYearTurnableItem:ShowSelect(t)
    if t == true then
        self.selected.GameObject:SetActive(true)
    else
        self.selected.GameObject:SetActive(false)
    end
end

-- function NewYearTurnableItem:ShowBeautifulEffect(t)
--     if t == true then
--         if self.beautifulEffect == nil then
--              self.beautifulEffect = BibleRewardPanel.ShowEffect(20384, self.transform, Vector3(0.9, 0.9, 1), Vector3(0, 0, -3))
--         end
--         self.beautifulEffect:SetActive(true)
--     else
--         if self.beautifulEffect ~= nil then
--             self.beautifulEffect:SetActive(false)
--         end
--     end
-- end



function NewYearTurnableItem:ShowFlashEffect(t,index)

    if t == true then
        if index ~= nil then
            if self.flashEffect == nil then
               self.flashEffect = BibleRewardPanel.ShowEffect(20441, self.transform, Vector3(1, 1, 1), Vector3( -self.px, -self.py, -400),nil,Quaternion.Euler(Vector3(0, 0, (-45)*(index - 2))))
            end
            self.flashEffect:SetActive(false)
        else
            if self.flashEffect == nil then
               self.flashEffect = BibleRewardPanel.ShowEffect(20441, self.transform, Vector3(1, 1, 1), Vector3(-self.px, -self.py, -400))
            end
            self.flashEffect:SetActive(true)
        end
        
    else
        if self.flashEffect ~= nil then
            self.flashEffect:SetActive(false)
        end
    end
end


function NewYearTurnableItem:ShowBlockEffect(t)
    if t == true then
        if self.flashMoreEffect== nil then
             self.flashMoreEffect = BibleRewardPanel.ShowEffect(20442, self.transform, Vector3(1, 1, 1), Vector3(2, -6, -400))
        end
        self.flashMoreEffect:SetActive(true)
    else
        if self.flashMoreEffect ~= nil then
            self.flashMoreEffect:SetActive(false)
        end
    end
end