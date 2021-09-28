-- PetBagBookCellTwo.lua

require("app.cfg.pet_info")
local PetPic = require("app.scenes.common.PetPic")
local MergeEquipment = require("app.data.MergeEquipment")
local EffectNode = require "app.common.effects.EffectNode"

local PetBagBookCellTwo = class("PetBagBookCellTwo",function()
    return CCSItemCellBase:create("ui_layout/petbag_BookCell2.json")
end)

PetBagBookCellTwo.MAX_CELL_NUM = 2 -- 战宠最大数量

local function createGaoGuangEffect()

    local effect = EffectNode.new("effect_szkpgy", 
        function(event, frameIndex)
            if event == "finish" then end
        end
    )
    effect:setScaleX(1.17)
    effect:setScaleY(0.8)
    effect:setPositionXY(2, -0.5)
    effect:play()
    return effect
end

function PetBagBookCellTwo:ctor()

        self:setTouchEnabled(true)
     
        for i = 1, PetBagBookCellTwo.MAX_CELL_NUM do
            self:registerWidgetClickEvent("Image_heroClick" .. i, function()
                self:click(i)
            end) 
        end
        
        if require("app.scenes.mainscene.SettingLayer").showEffectEnable() then

            for i = 1, PetBagBookCellTwo.MAX_CELL_NUM do
                self:getImageViewByName("Image_heroClick" .. i):addNode(createGaoGuangEffect())
            end
        end
end

function PetBagBookCellTwo:click(index)

    if not self._data then
        return
    end
    local petid  = self._data["pet_"..index]
    if petid and petid > 0 then
        require("app.scenes.common.dropinfo.DropInfo").show(G_Goods.TYPE_PET, petid)
    end
end

function PetBagBookCellTwo:updateData(data)

    self._data = data
    local name = self:getLabelByName("Label_title")

    for i = 1, PetBagBookCellTwo.MAX_CELL_NUM do
        self:initPet(i, data and data["pet_" .. i] or 0)
        name:setText(data and data.name or "???")
    end

    name:createStroke(Colors.strokeBrown, 1)
    self:updateAttrs(data)
end

function PetBagBookCellTwo:initPet(index,baseid)

    local namebgImage   = self:getImageViewByName("Image_namebg"..index)
    local nameLabel     = self:getLabelByName("Label_name"..index)
    local futureLabel   = self:getLabelByName("Label_future"..index)
    local defaultImage  = self:getImageViewByName("Image_default"..index)
    local heroPanel     = self:getPanelByName("Panel_hero"..index)
    local heroAreaPanel = self:getPanelByName("Panel_heroArea"..index)

    if baseid ~= 0 then

        local petData = pet_info.get(baseid)

        namebgImage:setVisible(true)

        nameLabel:setText(petData.name)
        nameLabel:setColor(Colors.qualityColors[petData.quality])
        nameLabel:createStroke(Colors.strokeBrown, 1)

        futureLabel:setVisible(false)
        defaultImage:setVisible(false)

        heroPanel:removeAllNodes()
        heroPanel:setPositionXY(70, 5)

        local isGray = not G_Me.bagData.petData:hasPetBookById(baseid)

        local petPath = G_Path.getPetReadyEffect(petData.ready_id)
        local petEffect = EffectNode.new(petPath, nil, nil, nil, nil, isGray )
        self:getImageViewByName("Image_bg"..index):showAsGray(isGray)
        petEffect:setScale(0.5)
        petEffect:play()
        if isGray then
            petEffect:pause()
        end
        heroPanel:addNode(petEffect)

        heroAreaPanel:setVisible(true)
    else

        futureLabel:setVisible(true)
        futureLabel:createStroke(Colors.strokeBrown, 1)

        namebgImage:setVisible(false)

        defaultImage:setVisible(true)
        defaultImage:loadTexture("ui/pet/tujian_chongwu.png")

        heroAreaPanel:setVisible(false)
    end
end

function PetBagBookCellTwo:getWidth()
      local width = self:getContentSize().width
      return width
end

function PetBagBookCellTwo:updateAttrs(data )

    local allLabel = self:getLabelByName("Label_showAll")
    allLabel:setText(G_lang:get("LANG_PET_ALLACTIVE"))
    allLabel:createStroke(Colors.strokeBrown, 1)

    if data then

        local count = 0

        for i = 1,4 do 

            local attrTypeLabel = self:getLabelByName("Label_attrtype"..i)
            local attrValueLabel = self:getLabelByName("Label_attrvalue"..i)

            if data["attribute_value_"..i] == 0 then

                attrTypeLabel:setVisible(false)
                attrValueLabel:setVisible(false)
            else

                local attrtype,attrvalue,strtype,strvalue = MergeEquipment.convertAttrTypeAndValue(data["attribute_type_"..i], data["attribute_value_"..i])
                attrTypeLabel:setVisible(true)
                attrValueLabel:setVisible(true)

                if G_Me.bagData.petData:hasPetBookById(data.pet_1) and G_Me.bagData.petData:hasPetBookById(data.pet_2) then

                    attrTypeLabel:setColor(Colors.darkColors.ATTRIBUTE)
                    attrValueLabel:setColor(Colors.darkColors.ATTRIBUTE)
                else

                    attrTypeLabel:setColor(Colors.darkColors.TIPS_02)
                    attrValueLabel:setColor(Colors.darkColors.TIPS_02)
                end

                attrTypeLabel:setText(strtype)
                attrTypeLabel:createStroke(Colors.strokeBrown, 1)
                attrValueLabel:setText("+"..strvalue)
                attrValueLabel:createStroke(Colors.strokeBrown, 1)
                count = count + 1
            end
        end

        if G_Me.bagData.petData:hasPetBookById(data.pet_1) and G_Me.bagData.petData:hasPetBookById(data.pet_2) then
            
            self:getImageViewByName("Image_arrow"):showAsGray(false)
        else
            
            self:getImageViewByName("Image_arrow"):showAsGray(true)
        end
    else

        for i = 1,4 do
            local attrTypeLabel = self:getLabelByName("Label_attrtype"..i)
            local attrValueLabel = self:getLabelByName("Label_attrvalue"..i)

            attrTypeLabel:setColor(Colors.darkColors.TIPS_02)
            attrTypeLabel:setText("???")
            attrTypeLabel:createStroke(Colors.strokeBrown, 1)

            attrValueLabel:setColor(Colors.darkColors.TIPS_02)
            attrValueLabel:setText("???")
            attrValueLabel:createStroke(Colors.strokeBrown, 1)
        end
        self:getImageViewByName("Image_arrow"):showAsGray(true)
 
    end
end

return PetBagBookCellTwo
