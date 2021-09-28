require("app.cfg.fragment_info")

local EffectNode = require "app.common.effects.EffectNode"

local PetBagFragmentItem = class("PetBagFragmentItem",function()
    return CCSItemCellBase:create("ui_layout/equipment_EquipmentFragmentListCell.json")
end)

function PetBagFragmentItem:ctor()
    self:setTouchEnabled(true)
    self._toGetFunc = nil
    self._composeFunc = nil
    self._checkInfoFunc = nil
    self._pinjikuangBtn = self:getButtonByName("Button_pinji")
    self._fragmentImage = self:getImageViewByName("ImageView_fragment")
    self._nameLabel = self:getLabelByName("Label_fragmentName")
    self._numLabel = self:getLabelByName("Label_fragmentNum")
    self._yishangzhen = self:getLabelByName("Label_yishangzhen")
    self._yishangzhen:setVisible(false)
    self:registerBtnClickEvent("Button_get", function ( widget )
        if self._toGetFunc ~= nil then self._toGetFunc() end
    end)    
    self:registerBtnClickEvent("Button_compose", function ( widget )
        if self._composeFunc ~= nil then self._composeFunc() end
    end)    

    self:registerBtnClickEvent("Button_pinji", function ( widget )
        if self._checkInfoFunc ~= nil then self._checkInfoFunc() end
    end)    
    self:registerCellClickEvent(function() 
        if self._toGetFunc ~= nil then self._toGetFunc() end
    end)

    self:enableLabelStroke("Label_fragmentName", Colors.strokeBrown,1)

end


function PetBagFragmentItem:setTogetButtonClickEvent( func )
    self._toGetFunc = func
end
function PetBagFragmentItem:setComposeFunc(func)
    self._composeFunc = func
end

function PetBagFragmentItem:setCheckFragmentInfoFunc(func)
    self._checkInfoFunc = func
end


function PetBagFragmentItem:blurFragment( blur )
    if blur then
        local around = nil
        around = EffectNode.new("effect_around1", 
            function(event)
                if event == "finish" and around then 
                    around:removeFromParentAndCleanup(true)
                    around = nil
                end
        end)
        self._numLabel:addNode(around, 2)
        around:setScaleX(2.8)
        around:setScaleY(0.9)
        around:play()

        local gSize = self._numLabel:getSize()
        --around:setPositionX(gSize.width/2)
    else
        if self._numLabel then
            self._numLabel:removeAllNodes()
        end
    end
end

--[[服务器返回的fragment]]
function PetBagFragmentItem:updateData(fragment)

    self:blurFragment(false)

    --从表里读取的fragment
    local __fragment = fragment_info.get(fragment.id)
    if G_Me.bagData.petData:getFightPet() and 
        pet_info.get(G_Me.bagData.petData:getFightPet()["base_id"]).relife_id == fragment.id then 
        self._yishangzhen:setVisible(true)
    end
    self._nameLabel:setColor(Colors.qualityColors[__fragment.quality])
    self._nameLabel:setText(__fragment.name)    
    self._fragmentImage:loadTexture(G_Path.getPetIcon(__fragment.res_id),UI_TEX_TYPE_LOCAL)
    self._pinjikuangBtn:loadTextureNormal(G_Path.getEquipColorImage(__fragment.quality,G_Goods.TYPE_FRAGMENT))
    self._pinjikuangBtn:loadTexturePressed(G_Path.getEquipColorImage(__fragment.quality,G_Goods.TYPE_FRAGMENT))
    self:getImageViewByName("Image_ball"):loadTexture(G_Path.getEquipIconBack(__fragment.quality))
    local shuliangTagLabel = self:getLabelByName("Label_shuliangbuzu")
    shuliangTagLabel:setPositionX(165)
    if fragment.num < __fragment.max_num then
        shuliangTagLabel:setVisible(true)
        shuliangTagLabel:setText(G_lang:get("LANG_FRAGMENT_NOT_ENOUGH"))
        shuliangTagLabel:setColor(Colors.lightColors.DESCRIPTION)
        self._numLabel:setColor(Colors.lightColors.DESCRIPTION)
    else
        shuliangTagLabel:setVisible(false)
        self._numLabel:setColor(Colors.lightColors.ATTRIBUTE)
        shuliangTagLabel:setText(G_lang:get("LANG_FRAGMENT_COMPOSE_AVAILABLE"))
    end

    self:showWidgetByName("Button_compose",fragment.num >= __fragment.max_num)
    self:showWidgetByName("Button_get",fragment.num < __fragment.max_num)
    local _num = fragment.num .. "/" .. __fragment.max_num
    self._numLabel:setText(_num)

    local imgBack = self:getImageViewByName("Image_ball")
    if imgBack then
        imgBack:loadTexture(G_Path.getEquipIconBack(__fragment.quality))
    end

    -- 判断有没有已经合成的宠物，要留着碎片，不让合成
    -- 额，现在又让合成了，代码先注释掉，万一突然又不让合成了方便修改
    local hasSameTmplPet = false
    -- local tPetList = G_Me.bagData.petData:getPetList() or {}
    -- for key, val in pairs(tPetList) do
    --     local tPet = val
    --     -- 碎片对应的0星模板
    --     local t0StarTmpl = pet_info.get(__fragment.fragment_value)
    --     -- 进阶码相同
    --     local tPetTmpl = pet_info.get(tPet["base_id"])
    --     if tPetTmpl.advanced_id == t0StarTmpl.advanced_id then
    --         hasSameTmplPet = true
    --         break
    --     end
    -- end
    if hasSameTmplPet then
        self._numLabel:setColor(Colors.lightColors.DESCRIPTION)
        shuliangTagLabel:setColor(Colors.lightColors.DESCRIPTION)
        shuliangTagLabel:setText(G_lang:get("LANG_PET_EXIST_SAME_TMPL_PET"))
        shuliangTagLabel:setVisible(true)
        self:showWidgetByName("Button_compose", false)
        self:showWidgetByName("Button_get", true)
    end
end


return PetBagFragmentItem
