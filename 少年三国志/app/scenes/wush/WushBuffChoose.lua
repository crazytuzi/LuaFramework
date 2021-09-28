require("app.cfg.dead_battle_buff_info")
require("app.cfg.passive_skill_info")

local WushBuffChoose = class("WushBuffChoose", UFCCSNormalLayer)

function WushBuffChoose:ctor(jsonFile)
    self.super.ctor(self, jsonFile)
    self:showAtCenter(true)
    self._clickIndex = 0
    self:getLabelByName("Label_star"):createStroke(Colors.strokeBrown,1)
    -- self:getLabelByName("Label_none"):createStroke(Colors.strokeBrown,1)
    -- self:getLabelByName("Label_12"):createStroke(Colors.strokeBrown,1)
    self.initBuffTable(self:getPanelByName("Panel_buffList"))
    -- self._callback = callback
    -- self:initBuffTable()
    local title1 = self:getLabelByName("Label_attrTitle")
    local title2 = self:getLabelByName("Label_addTitle")
    local title3 = self:getLabelByName("Label_12")
    title1:createStroke(Colors.strokeBrown,1)
    title2:createStroke(Colors.strokeBrown,1)
    title3:createStroke(Colors.strokeBrown,1)
    title1:setText(G_lang:get("LANG_WUSH_BUFFTITLE1"))
    title2:setText(G_lang:get("LANG_WUSH_BUFFTITLE2"))
    title3:setText(G_lang:get("LANG_WUSH_BUFFTITLE3"))
    self:getLabelByName("Label_none"):setText(G_lang:get("LANG_WUSH_BUFFTITLE4"))
    self:getLabelByName("Label_none"):createStroke(Colors.strokeBrown,1)
    
    self:registerBtnClickEvent("Button_fight", function()
        self:_onChoosedBuff(self._clickIndex)
    end)
    self:registerWidgetClickEvent("Panel_buff1", function ( ... )
      self:_click(1)
    end)
    self:registerWidgetClickEvent("Panel_buff2", function ( ... )
      self:_click(2)
    end)
    self:registerWidgetClickEvent("Panel_buff3", function ( ... )
      self:_click(3)
    end)
end

function WushBuffChoose:_click(index)
    self._clickIndex = index
    for i = 1,3 do
        self:getImageViewByName("Image_gou"..i):setVisible(false)
    end
    self:getImageViewByName("Image_gou"..index):setVisible(true)
end

function WushBuffChoose:onLayerEnter( )
    require("app.common.effects.EffectSingleMoving").run(self, "smoving_bounce")
    -- self:closeAtReturn(true)
    -- uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_WUSH_GET_BUFF, self._onWushBuffRsp, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_WUSH_APPLY_BUFF, self._onBuffApply, self)

    local list = G_Me.wushData:getBuffList()
    local hasBuff = false
    for k,v in pairs(list) do
        hasBuff = true
    end
    if hasBuff then
        self:getLabelByName("Label_none"):setVisible(false)
    else
        self:getLabelByName("Label_none"):setVisible(true)
    end
end

function WushBuffChoose:_onWushBuffRsp(data)
    self:updateView(G_Me.wushData:getBuffToChoose())
end

function WushBuffChoose:init(callback)
    self._callback = callback
    -- G_HandlersManager.wushHandler:sendWushGetBuff()
    self:updateView(G_Me.wushData:getBuffToChoose())
end

function WushBuffChoose.initBuffTable(panel)
    -- local panel = self:getPanelByName("Panel_buffList")
    local itemWidth = 160
    local itemHeight = 40
    local index = 0
    local list = G_Me.wushData:getBuffList()
    for k,v in pairs(list) do
        local x = (index%3)*itemWidth
        local y = (2-math.floor(index/3))*itemHeight
        WushBuffChoose.addBuff(index,{type=k,value=v},panel,x,y)
        index = index + 1
    end
end

function WushBuffChoose.addBuff(id,buffData,_panel,x,y)
    local btn = CCSGUIReaderEx:shareReaderEx():widgetFromJsonFile("ui_layout/wush_buffCell.json")
    _panel:addChild(btn)
    btn:setTag(id)
    btn:setPosition(ccp(x,y))
    -- local desc = G_lang.getGrowthTypeName(buffData.type)
    -- local value = G_lang.getGrowthValue(buffData.type,buffData.value)
    -- print(buffData.type.." "..buffData.value.." "..desc.." "..value)
    local desc,value = G_Me.wushData.convertAttrTypeAndValue(buffData.type,buffData.value)
    local descLabel = btn:getChildByName("Label_desc")
    if descLabel then
        descLabel = tolua.cast(descLabel,"Label")
        descLabel:setText(desc)
        descLabel:createStroke(Colors.strokeBrown, 1)
    end
    local valueLabel = btn:getChildByName("Label_value")
    if valueLabel then
        valueLabel = tolua.cast(valueLabel,"Label")
        valueLabel:setText("+"..value)
        valueLabel:createStroke(Colors.strokeBrown, 1)
    end
end

function WushBuffChoose:updateView(buff)  
    self:getLabelByName("Label_star"):setText(G_Me.wushData:getStarCur())
    self:_initBuff(1,buff[1])
    self:_initBuff(2,buff[2])
    self:_initBuff(3,buff[3])
end

function WushBuffChoose:_initBuff(index,buffId)
    local skill = passive_skill_info.get(buffId)
    -- local desc = G_lang.getGrowthTypeName(skill.affect_type)
    -- local value = G_lang.getGrowthValue(skill.affect_type,skill.affect_value)
    local desc,value = G_Me.wushData.convertAttrTypeAndValue(skill.affect_type,skill.affect_value)
    local star = G_Me.wushData:getStarCur()
    if star < index*3 then 
        self:getLabelByName("Label_star"..index):setColor(Colors.qualityColors[6])
    else
        self:getLabelByName("Label_star"..index):setColor(Colors.lightColors.DESCRIPTION)
    end
    self:getLabelByName("Label_star"..index):setText(index*3)
    self:getLabelByName("Label_desc"..index):setText(desc)
    self:getLabelByName("Label_value"..index):setText("+"..value)
    self:getImageViewByName("Image_gou"..index):setVisible(false)
    self:getImageViewByName("Image_icon"..index):loadTexture(G_Me.wushData:getBuffIcon(skill.affect_type))
end

function WushBuffChoose:_onChoosedBuff(index)
    if index == 0 then
        G_MovingTip:showMovingTip(G_lang:get("LANG_WUSH_NEEDBUFF"))
        return
    end
    if G_Me.wushData:getStarCur() < index*3 then
        G_MovingTip:showMovingTip(G_lang:get("LANG_WUSH_STARNOENGHOU"))
        return
    end
    -- self:close()
    local list = G_Me.wushData:getBuffToChoose()
    G_Me.wushData:setBuffToChooseIndex(index)
    G_HandlersManager.wushHandler:sendWushApplyBuff(list[index])
end

function WushBuffChoose:_onBuffApply()
    if self._callback then
        self._callback()
    end
    self:animationToClose()
end

function WushBuffChoose:onLayerExit()
    self.super:onLayerExit()
    uf_eventManager:removeListenerWithTarget(self)
end

function WushBuffChoose:onLayerUnload( ... )

end

return WushBuffChoose
