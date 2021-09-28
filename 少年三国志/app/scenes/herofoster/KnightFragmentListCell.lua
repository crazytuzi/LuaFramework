require("app.cfg.fragment_info")


local EffectNode = require "app.common.effects.EffectNode"
local KnightFragmentListCell = class("KnightFragmentListCell",function()
    return CCSItemCellBase:create("ui_layout/equipment_EquipmentFragmentListCell.json")
end)

function KnightFragmentListCell:ctor()
    self:setTouchEnabled(true)
    self._toGetFunc = nil
    self._checkInfoFunc = nil
    self._composeFunc = nil
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
    -- self:enableLabelStroke("Label_yishangzhen", Colors.strokeBrown,1)
end


function KnightFragmentListCell:setTogetButtonClickEvent( func )
    self._toGetFunc = func
end
function KnightFragmentListCell:setComposeFunc(func)
    self._composeFunc = func
end
function KnightFragmentListCell:setCheckFragmentInfoFunc(func)
    self._checkInfoFunc = func
end

function KnightFragmentListCell:blurFragment( blur )
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
function KnightFragmentListCell:updateData(fragment)
    --从表里读取的fragment
    local __fragment = fragment_info.get(fragment.id)
    if G_Me.formationData:getKnightTeamIdByFragment(__fragment.fragment_value) == 1 then 
        self._yishangzhen:setVisible(true)
        self._yishangzhen:setText(G_lang:get("LANG_FRAGMENT_YISHANGZHEN"))
    elseif G_Me.formationData:getKnightTeamIdByFragment(__fragment.fragment_value) == 2 then 
        self._yishangzhen:setVisible(true)
        self._yishangzhen:setText(G_lang:get("LANG_FRAGMENT_YUANJUN"))
    elseif G_Me.formationData:getKnightTeamIdByFragment(__fragment.fragment_value) == 0 then 
        self._yishangzhen:setVisible(false)
    end
    self._nameLabel:setColor(Colors.qualityColors[__fragment.quality])
    self._nameLabel:setText(__fragment.name)

    self._fragmentImage:loadTexture(G_Path.getKnightIcon(__fragment.res_id),UI_TEX_TYPE_LOCAL)
    self._pinjikuangBtn:loadTextureNormal(G_Path.getEquipColorImage(__fragment.quality, G_Goods.TYPE_FRAGMENT))
    local shuliangTagLabel = self:getLabelByName("Label_shuliangbuzu")
    if fragment.num < __fragment.max_num then
        shuliangTagLabel:setVisible(true)
        
        shuliangTagLabel:setColor(Colors.lightColors.DESCRIPTION)
        self._numLabel:setColor(Colors.lightColors.DESCRIPTION)
        shuliangTagLabel:setText(G_lang:get("LANG_FRAGMENT_NOT_ENOUGH"))
    else
        shuliangTagLabel:setVisible(false)
        self._numLabel:setColor(Colors.lightColors.ATTRIBUTE)
        shuliangTagLabel:setText(G_lang:get("LANG_FRAGMENT_COMPOSE_AVAILABLE"))
    end
    self:showWidgetByName("Button_compose",fragment.num >= __fragment.max_num)
    -- 碎片一键合成多次
    local imageBtnText = self:getImageViewByName("ImageView_Btn_Text")
    if fragment.num >= __fragment.max_num * 2 then
        imageBtnText:loadTexture("ui/text/txt-small-btn/yijianhecheng.png", UI_TEX_TYPE_LOCAL)
    else
        imageBtnText:loadTexture("ui/text/txt-middle-btn/m_hecheng.png", UI_TEX_TYPE_LOCAL)
    end

    self:showWidgetByName("Button_get",fragment.num < __fragment.max_num)
    local _num = fragment.num .. "/" .. __fragment.max_num
    self._numLabel:setText(_num)

    if self._numLabel then
        self._numLabel:removeAllNodes()
    end
end


return KnightFragmentListCell
