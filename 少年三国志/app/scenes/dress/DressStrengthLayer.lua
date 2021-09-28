
local DressStrengthLayer = class("DressStrengthLayer",UFCCSNormalLayer)
require("app.cfg.dress_info")
require("app.cfg.skill_info")
require("app.cfg.knight_info")
local MergeEquipment = require("app.data.MergeEquipment")
local KnightPic = require("app.scenes.common.KnightPic")
local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
local JumpBackCard = require("app.scenes.common.JumpBackCard")
local EffectNode = require "app.common.effects.EffectNode"

local itemId = 45

function DressStrengthLayer.create( container)   
    local layer = DressStrengthLayer.new("ui_layout/dress_StrengthLayer.json") 
    layer:setContainer(container)
    return layer
end

function DressStrengthLayer:ctor(...)
    self.super.ctor(self, ...)

    -- self._equipment = G_Me.dressData:getDressed() 
    -- if not self._equipment then

    -- end
    self._nameLabel = self:getLabelByName("Label_dressName")
    self._nameLabel:createStroke(Colors.strokeBrown, 1)
    self._heroPanel = self:getPanelByName("Panel_hero")
    self._numLabel = self:getLabelByName("Label_iconNum")
    self._yinNum = self:getLabelByName("Label_yinnum")
    self._nextTargetLabel = self:getLabelByName("Label_nextTarget")
    self._hePanel = self:getPanelByName("Panel_he")
    self._arrowImg = self:getImageViewByName("Image_arrow")
    self._hePanel:setVisible(false)
    self._numLabel:createStroke(Colors.strokeBrown, 1)
    self._yinNum:createStroke(Colors.strokeBrown, 1)
    
    self:baseInit()

    self:registerBtnClickEvent("Button_strength", function()
        if self._playing then
            return
        end
        if self._equipment.level >= G_Me.dressData:getMaxLevel() then
            G_MovingTip:showMovingTip(G_lang:get("LANG_DRESS_STRMAX"))
        else
            local cur = G_Me.bagData:getPropCount(itemId)
            local need = G_Me.dressData:getCostItem(self._equipment)
            local money = G_Me.dressData:getCostMoney(self._equipment)
            if cur < need then
                require("app.scenes.common.acquireInfo.AcquireInfoLayer").show(G_Goods.TYPE_ITEM, itemId,
                 GlobalFunc.sceneToPack("app.scenes.dress.DressMainScene"))
                return 
            end
            if money > G_Me.userData.money then
                require("app.scenes.common.acquireInfo.AcquireInfoLayer").show(G_Goods.TYPE_MONEY, 0,
                 GlobalFunc.sceneToPack("app.scenes.dress.DressMainScene"))
                return 
            end
            self:updataData()
            G_HandlersManager.dressHandler:sendUpgradeDress(self._equipment.id)
        end
    end)
    self:registerBtnClickEvent("Button_show", function()
        -- local show = require("app.scenes.dress.DressStrengthShow").create(self._equipment)
        -- uf_sceneManager:getCurScene():addChild(show)
        local layer = require("app.scenes.common.CommonAttrLayer").show(G_Me.dressData:getSkillTxt(self._equipment), tonumber(self._equipment.level))
        layer:setDesc(G_lang:get("LANG_DRESS_STRLEVEL3"))
        layer:setTitle("ui/text/txt/shizhuangtianfu.png")
    end)
    self:getPanelByName("Panel_heroClick"):setTouchEnabled(true)
    self:registerWidgetClickEvent("Panel_heroClick", function()
        local dress = self._equipment
        if dress then
            require("app.scenes.dress.DressInfo").showEquipmentInfo(dress,self._container )
        end
    end)
end

function DressStrengthLayer:onLayerEnter( )
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_DRESS_UPDATE, self._onChangeRsp, self)
    self._playing = false
end

function DressStrengthLayer:setContainer(container )
    self._container = container
end

function DressStrengthLayer:reset( )
    self._equipment = self._container:getChoosed()
    self._equipmentInfo = G_Me.dressData:getDressInfo(self._equipment.base_id) 
    self:updataData()

    local attrPanel = self:getWidgetByName("Panel_attr")
    local posx,posy = attrPanel:getPosition()
    attrPanel:setPosition(ccp(posx+300,posy))
    local showButton = self:getWidgetByName("Button_show")
    local posx,posy = showButton:getPosition()
    showButton:setPosition(ccp(posx+300,posy))
    local strPanel = self:getWidgetByName("Panel_strength")
    local posx,posy = strPanel:getPosition()
    strPanel:setPosition(ccp(posx,posy-200))
    strPanel:setOpacity(0)
    self:_heroComeAnime()
end

function DressStrengthLayer:enterAnime( )
    -- GlobalFunc.flyIntoScreenLR({self:getWidgetByName("Panel_dressList")}, false, 0.2, 2, 100)
    -- GlobalFunc.flyIntoScreenTB({self:getWidgetByName("Panel_attr")}, false, 0.2, 2, 100)
    -- self:_heroComeAnime()
end

function DressStrengthLayer:updataData( )
    self:updateInit()
    self:updateHero()
    self:updateAttr()
end

function DressStrengthLayer:_onChangeRsp(data)
    if data.ret == 1 then
        -- G_MovingTip:showMovingTip(G_lang:get("LANG_DRESS_STRSUCCESS"))

        if self._endEffect then
            self._endEffect:stop()
            self._endEffect:removeFromParentAndCleanup(true)
            self._endEffect = nil
        end
        local EffectNode = require "app.common.effects.EffectNode"
        self._endEffect = EffectNode.new("effect_juexing_b", function(event, frameIndex)
            if event == "forever" then
                self._endEffect:stop()
                self._endEffect:removeFromParentAndCleanup(true)
                self._endEffect = nil
                self:updataData()
            end
        end)
        self._heroPanel:addNode(self._endEffect,20) 
        self._endEffect:setPositionXY(0,200)
        self._endEffect:setScale(1.5)
        self._endEffect:play()
        -- self:updataData()

        self:updateInit()
        local level = self._equipment.level
        local attr = {}
        for j = 1 ,  4 do 
            local attrtype,attrvalue,strtype,strvalue = MergeEquipment.convertAttrTypeAndValue(self._equipmentInfo["strength_type_"..j], self._equipmentInfo["strength_value_"..j])
            table.insert(attr,#attr+1,{typeString=strtype,delta=attrvalue})
        end
        self:_flyAttr({level=level,attr=attr})
    end
end

function DressStrengthLayer:onLayerExit()
    self.super:onLayerExit()
    uf_eventManager:removeListenerWithTarget(self)
end


function DressStrengthLayer:adapterLayer()
    self:adapterWidgetHeight("Panel_container", "", "", 0, 160)

    self:enterAnime()
end

function DressStrengthLayer:updateHero()
    local knightId, baseId = G_Me.formationData:getTeamKnightIdAndBaseIdByIndex(1, 1)
    local info = knight_info.get(baseId)
    local resid = info.res_id
    if self._equipment then
        resid = G_Me.dressData:getDressedResidWithDress(baseId,self._equipment.base_id)
    end
    if self._knight then
        self._knight:removeFromParentAndCleanup(true)
    end
    self._knight = KnightPic.createKnightPic( resid, self._heroPanel, "knightImg",true )
    -- self._knight:setScale(0.6)
    self._heroPanel:setScale(0.8)
    self:breathe(true)
end

function DressStrengthLayer:baseInit()
    -- local info = self._equipmentInfo
    local iconPanel = self:getPanelByName("Panel_icon")
    iconPanel:removeAllChildrenWithCleanup(true)
    local icon = GlobalFunc.createIcon({type=3,value=itemId,click=true})
    iconPanel:addChild(icon)
    icon:setPosition(ccp(0,-55))
    local nameLabel = self:getLabelByName("Label_iconName")
    local g = G_Goods.convert(3, itemId)
    nameLabel:setText(g.name)
    nameLabel:setColor(Colors.qualityColors[g.quality])
    nameLabel:createStroke(Colors.strokeBrown,1)
end

function DressStrengthLayer:updateInit()
    local info = self._equipmentInfo
    self._nameLabel:setText(info.name)
    self._nameLabel:setColor(Colors.qualityColors[info.quality])

    local cur = G_Me.bagData:getPropCount(itemId)
    local need = G_Me.dressData:getCostItem(self._equipment)
    local str = cur.."/"..need
    self._numLabel:setText(str)
    self._numLabel:setColor(need > cur and Colors.darkColors.TIPS_01 or Colors.darkColors.DESCRIPTION)

    local money = G_Me.dressData:getCostMoney(self._equipment)
    self._yinNum:setText(money)
    self._yinNum:setColor(money > G_Me.userData.money and Colors.darkColors.TIPS_01 or Colors.darkColors.DESCRIPTION)
end

function DressStrengthLayer:changeAnime()
    -- local panel = self:getPanelByName("Panel_breathe")
    -- self._breathEffect = EffectSingleMoving.run(self:getPanelByName("Panel_breathe"), "smoving_idle", nil, {})
    -- local guangImg = self:getImageViewByName("Image_guang")
    -- guangImg:stopAllActions()
    -- local fadeInAction = CCFadeIn:create(0.5)
    -- local fadeOutAction = CCFadeOut:create(0.5)
    -- local seqAction = CCSequence:createWithTwoActions(fadeInAction, fadeOutAction)
    -- seqAction = CCRepeatForever:create(seqAction)
    -- guangImg:runAction(seqAction)
end

function DressStrengthLayer:updateAttr()

    local mainTitle = self:getLabelByName("Label_attrTitle")
    mainTitle:setText(G_lang:get("LANG_DRESS_STRLEVEL"))
    mainTitle:createStroke(Colors.strokeBrown,1)
    local level = self._equipment.level
    for i = 1 , 2 do 
        if level+i-1 <= G_Me.dressData:getMaxLevel() then
            local title = self:getLabelByName("Label_attrTitle"..i)
            title:createStroke(Colors.strokeBrown, 1)
            title:setText(G_lang:get("LANG_DRESS_STRLEVEL2",{level=level+i-1}))
            title:setVisible(true)
            self._arrowImg:setVisible(true)
            for j = 1 ,  4 do 
                local value = self:getLabelByName("Label_attrValue"..i.."_"..j)
                value:createStroke(Colors.strokeBrown, 1)
                local attrtype,attrvalue,strtype,strvalue = MergeEquipment.convertAttrTypeAndValue(self._equipmentInfo["strength_type_"..j], self._equipmentInfo["strength_value_"..j]*(level+i-2))
                value:setText(strvalue)
                value:setVisible(true)

                if i == 1 then
                    local attr = self:getLabelByName("Label_attrType"..j)
                    attr:createStroke(Colors.strokeBrown, 1)
                    attr:setText(strtype)
                end
            end
        else
            local title = self:getLabelByName("Label_attrTitle"..i)
            title:setVisible(false)
            self._arrowImg:setVisible(false)
            for j = 1 ,  4 do 
                local value = self:getLabelByName("Label_attrValue"..i.."_"..j)
                value:setVisible(false)
            end
        end
    end
    -- if level+1 == self._equipmentInfo.unite_clear_level then
    --     self._hePanel:setVisible(true)
    --     local skillid = self._equipmentInfo.unite_skill_id
    --     local skill = skill_info.get(skillid)
    --     local heName = self:getLabelByName("Label_heName")
    --     heName:setText(skill.name)
    --     heName:createStroke(Colors.strokeBrown, 1)
    -- else
    --     self._hePanel:setVisible(false)
    -- end
    self._hePanel:setVisible(false)

    local targetId = 0
    local find = false
    for i = 1 , 7 do
        if not find then
            local skillId = self._equipmentInfo["passive_skill_"..i]
            if skillId > 0 and self._equipment.level < self._equipmentInfo["strength_level_"..i] then
                targetId = self._equipmentInfo["passive_skill_"..i]
                find = true
            end
        end
    end
    if find then
        local skillInfo = passive_skill_info.get(targetId)
        local str = "["..skillInfo.name.."]  "..skillInfo.directions
        self._nextTargetLabel:setText(str)
    else
        self._nextTargetLabel:setText("")
    end
end

function DressStrengthLayer:choosedDress(id)
    -- print("DressChooseLayer:choosedDress "..id)
    self._equipment = G_Me.dressData:getDressByBaseId(id)
    self._equipmentInfo = G_Me.dressData:getDressInfo(self._equipment.base_id) 
    self:_heroChangeAnime()
    -- self:updataData()
end

function DressStrengthLayer:breathe(status)
    if status then
        if self._bossEffect == nil then
                    local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
                    self._bossEffect = EffectSingleMoving.run(self._heroPanel, "smoving_idle", nil, {})
        end
    else
        if self._bossEffect ~= nil then
                    self._bossEffect:stop()
                    self._bossEffect = nil
        end
    end
end


function DressStrengthLayer:_heroChangeAnime()
    self._playing = true
    self._container:_setListClick(false)
    local baseScale = self._knight:getParent():getScale()
    local oldPosx, oldPosy = self._knight:getParent():getPosition()
    self:breathe(false)
    require("app.common.effects.EffectSingleMoving").run(self._knight:getParent(), "smoving_out", function(event)
        if event == "finish" then
            self._knight:setVisible(false)
            self._knight:getParent():setScale(baseScale)
            self._knight:getParent():setPosition(ccp(oldPosx,oldPosy))
            local EffectNode = require "app.common.effects.EffectNode"
            local node = EffectNode.new("effect_yan", function()
                -- if self._callback then
                --     self._callback()
                -- end
                self._knight:setVisible(true)
                self:updataData()
                self:_heroComeAnime(function()
                    end)
            end)
            self._knight:getParent():addNode(node)
            node:setPositionXY(50, 200)
            node:setScale(1.5)
            node:play()
            self:getWidgetByName("Panel_attr"):runAction(CCMoveBy:create(0.2,ccp(300,0)))
            self:getWidgetByName("Button_show"):runAction(CCMoveBy:create(0.2,ccp(300,0)))
            self:getWidgetByName("Panel_strength"):runAction(CCSpawn:createWithTwoActions(CCMoveBy:create(0.2,ccp(0,-200)),CCFadeOut:create(0.2)))
        end
    end)

end

function DressStrengthLayer:_heroComeAnime(callback)
    self._playing = true
    self._container:_setListClick(false)
    local knightId, baseId = G_Me.formationData:getTeamKnightIdAndBaseIdByIndex(1, 1)
    local info = knight_info.get(baseId)
    local resid = info.res_id
    if self._equipment then
        resid = G_Me.dressData:getDressedResidWithDress(baseId,self._equipment.base_id)
    end
    local knight = self._heroPanel
    local worldPos = knight:convertToWorldSpace(ccp(0,0))
    local jumpKnight = JumpBackCard.create()
    local start = knight:convertToWorldSpace(ccp(-400,0))
    knight:getParent():addNode(jumpKnight)
    self._knight:setVisible(false)
     jumpKnight:play(resid, start, 0.5, worldPos, 0.8, function() 
        jumpKnight:removeFromParentAndCleanup(true)
        self._playing = false
        self._container:_setListClick(true)
        self._knight:setVisible(true)
        if callback then
            callback()
        end
    end )
    self:getWidgetByName("Panel_attr"):runAction(CCMoveBy:create(0.2,ccp(-300,0)))
    self:getWidgetByName("Button_show"):runAction(CCMoveBy:create(0.2,ccp(-300,0)))
    self:getWidgetByName("Panel_strength"):runAction(CCSpawn:createWithTwoActions(CCMoveBy:create(0.2,ccp(0,200)),CCFadeIn:create(0.2)))
end


function DressStrengthLayer:_flyAttr(data) 

    local afterLevel = data.level

    G_flyAttribute._clearFlyAttributes()
    
    local levelTxt = G_lang:get("LANG_DRESS_STRSUCCESSLEVEL", {level=afterLevel})

    G_flyAttribute.addNormalText(levelTxt,Colors.darkColors.DESCRIPTION, self:getLabelByName("Label_attrTitle1"), delta)

    for k , v in pairs(data.attr) do 
        G_flyAttribute.addAttriChange(v.typeString, v.delta, self:getLabelByName("Label_attrValue1_"..k))
    end

    local targetId = 0
    local find = false
    for i = 1 , 7 do
        if not find then
            local skillId = self._equipmentInfo["passive_skill_"..i]
            if skillId > 0 and self._equipment.level == self._equipmentInfo["strength_level_"..i] then
                targetId = self._equipmentInfo["passive_skill_"..i]
                find = true
            end
        end
    end
    if find then
        local skillInfo = passive_skill_info.get(targetId)
        local skillTxt = G_lang:get("LANG_DRESS_GET_SKILL", {name=skillInfo.name})
        G_flyAttribute.addNormalText(skillTxt,Colors.darkColors.TITLE_01, self._nextTargetLabel, nil)
    end

    G_flyAttribute.play(function ( ... )
        self:updataData()
    end, 1.5)
end

return DressStrengthLayer

