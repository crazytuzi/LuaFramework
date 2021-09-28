local FuCommon = require("app.scenes.dafuweng.FuCommon")
local EffectNode = require "app.common.effects.EffectNode"

local FuScrollCell = class ("FuScrollCell", function (  )
    return CCSItemCellBase:create("ui_layout/dafuweng_MainCell.json")
end) 

function FuScrollCell:ctor()
    self._iconList = {"ui/dafuweng/icon_qimenbagua.png","ui/dafuweng/icon_xingyunzhuanpan.png","ui/dafuweng/icon_xunyoutanbao.png","ui/dafuweng/icon_fanpai.png"}
    self._titleList = {"ui/text/txt/fjtx_qimenbagua.png","ui/text/txt/fjtx_xingyunzhuanpan.png","ui/text/txt/fjtx_xunyoutanbao.png","ui/text/txt/fjtx_chongzhifanpai.png"}
    self._typeImg = self:getImageViewByName("Image_type")
    self._statesImg = self:getImageViewByName("Image_states")
    self._titleImg = self:getImageViewByName("Image_title")
    self._tipsImg = self:getImageViewByName("Image_tips")
    self._descLabel = self:getLabelByName("Label_desc")
    self._statesLabel = self:getLabelByName("Label_states")
    self._effectPanel = self:getPanelByName("Panel_10")
    self._statesLabel:createStroke(Colors.strokeBrown, 2)
    self._descLabel:createStroke(Colors.strokeBrown, 1)
    self._tipsImg:setVisible(false)

    
end

function FuScrollCell:updateView(_type)
    self._type = _type
    self._typeImg:loadTexture(self._iconList[_type+1])
    self._titleImg:loadTexture(self._titleList[_type+1])
    self._descLabel:setText(G_lang:get("LANG_FU_DES".._type))
    self:refreshView()
end

function FuScrollCell:_condition1()
    -- print("condition1")
    self._statesImg:setVisible(false)
    if not self._effect then
        self._effect = EffectNode.new("effect_huoreing")     
        self._effect:play()
        self._effectPanel:addNode(self._effect,1)
    end
    self._statesLabel:setText(G_lang:get("LANG_FU_STATE2"))
end

function FuScrollCell:_condition2()
    -- print("condition2")
    self._statesImg:setVisible(true)
    if self._effect then 
        self._effect:removeFromParent()
        self._effect = nil
    end
    self._statesLabel:setText(G_lang:get("LANG_FU_STATE1"))
end

function FuScrollCell:_condition3()
    -- print("condition3")
    self._statesImg:setVisible(false)
    if self._effect then 
        self._effect:removeFromParent()
        self._effect = nil
    end
    self._statesLabel:setText("")
end

function FuScrollCell:refreshView()
    if self._type == FuCommon.TRIGRAMS_TYPE_ID then
        if G_Me.trigramsData:getState() == FuCommon.STATE_OPEN then
            self:_condition1()
        elseif G_Me.trigramsData:getState() == FuCommon.STATE_AWARD then
            self:_condition2()
        else
            self:_condition3()
        end
        self._tipsImg:setVisible(G_Me.trigramsData:hasFinalAward())
    elseif self._type == FuCommon.RICH_TYPE_ID then
        if G_Me.richData:getState() == FuCommon.STATE_OPEN then
            self:_condition1()
        elseif G_Me.richData:getState() == FuCommon.STATE_AWARD then
            self:_condition2()
        else
            self:_condition3()
        end
        self._tipsImg:setVisible(G_Me.richData:hasFinalAward() or G_Me.richData:hasAward())
    elseif self._type == FuCommon.WHEEL_TYPE_ID then
        if G_Me.wheelData:getState() == FuCommon.STATE_OPEN then
            self:_condition1()
        elseif G_Me.wheelData:getState() == FuCommon.STATE_AWARD then
            self:_condition2()
        else
            self:_condition3()
        end
        self._tipsImg:setVisible(G_Me.wheelData:hasFinalAward())
    elseif self._type == FuCommon.RECHARGE_TYPE_ID then
        if G_Me.rCardData:isOpen() then
            self:_condition1()
        else
            self:_condition3()
        end
        self._tipsImg:setVisible(false)
    end
    self._statesImg:setColor(ccc3(255,255,255))
end

function FuScrollCell:getType()
    return self._type
end

return FuScrollCell

