
local EffectNode = require "app.common.effects.EffectNode"

local ItemConst = require("app.const.ItemConst")
local Colors = require("app.setting.Colors")
local EquipmentInfo = require("app.scenes.equipment.EquipmentInfo")
local TreasureRefineCailiaoCell = require("app.scenes.treasure.cell.TreasureRefineCailiaoCell")
local TreasureInfo = require("app.scenes.treasure.TreasureInfo")

local TreasureRefineLayer = class("TreasureRefineLayer",UFCCSNormalLayer)

require("app.cfg.treasure_advance_info")
require("app.cfg.equipment_skill_info")
function TreasureRefineLayer.create(...)
    return require("app.scenes.treasure.develope.TreasureRefineLayer").new("ui_layout/treasure_TreasureRefineLayer.json", ...)
end


function TreasureRefineLayer:ctor(...)    
    self._treasureJinglianTargetId = 0
    self._wearPosId = 0

    self.super.ctor(self,...)
    self._effect  =nil
    self._playing = false

    self._showAttrButton = self:getButtonByName("Button_showAttr")
    self._showAttrButton:setVisible(false)
end


function TreasureRefineLayer:setEquipment(equipment)
    self._equipment = equipment 

    if equipment then 
        local inLiueupId = equipment:getWearingKnightId()
        if inLiueupId > 0 then 
            local teamId, posId = G_Me.formationData:getKnightPosInTeam(inLiueupId)
            if teamId == 1 and posId > 0 then 
                self._wearPosId = posId
                self._treasureJinglianTargetId = G_Me.formationData:getKnightTreasureTarget(false, posId)

                __Log("self._treasureJinglianTargetId:%d,", 
                    self._treasureJinglianTargetId)
            end
        end
        self._showAttrButton:setVisible(#self._equipment:getSkillTxt() > 0)
    end
end

-- 红色宝物神兵技能达到之后的文字特效  copy from EquipmentDevelopeLayer:_redEquipmentSkill()
function TreasureRefineLayer:_redTreasureSkill()
    local baseInfo = self._equipment:getInfo()
    for i=1, 10 do
        local equipmentSkillId = baseInfo["equipment_skill_"..i]
        if equipmentSkillId and equipmentSkillId ~= 0 then
            local equipmentSkillInfo = equipment_skill_info.get(equipmentSkillId)
            if self._equipment.refining_level == equipmentSkillInfo.open_value then
                -- 满足要求 神兵技能XXXX激活
                local desc = G_lang:get("LANG_KNIGHT_TARGET_ATTRI_CHANGE_TIP_EQUIPMENT", {targetName = equipmentSkillInfo.name})
                G_flyAttribute.doAddRichtext(desc, 40, nil, nil, self._showAttrButton)
                local curTargetDesc = G_lang.getGrowthTypeName(
                    equipmentSkillInfo.attribute_type).."+"..G_lang.getGrowthValue(
                    equipmentSkillInfo.attribute_type, equipmentSkillInfo.attribute_value)
                if equipmentSkillInfo.attribute_type == 0 then 
                    -- 属性没有固定增加值  显示描述
                    local tempDesc = GlobalFunc.autoNewLine(string.split(equipmentSkillInfo.directions,"（")[1],10,1)
                    for i = 1,#tempDesc do 
                        G_flyAttribute.addNormalText( tempDesc[i] , Colors.titleGreen, self._showAttrButton, nil, nil, 40)
                    end
                else 
                    G_flyAttribute.addNormalText( curTargetDesc , Colors.titleGreen, self._showAttrButton, nil, nil, 40)
                end
                break 
            end
        end
    end
end

function TreasureRefineLayer:onTreasureJinglian( ... )
self:_redTreasureSkill()
    if self._wearPosId < 1 then 
        return 
    end

    local treasureJinglianTarget, targetLevel = G_Me.formationData:getKnightTreasureTarget(false, self._wearPosId)
    if treasureJinglianTarget <= self._treasureJinglianTargetId then 
        return 
    end

    self._treasureJinglianTargetId = treasureJinglianTarget
    local desc = G_lang:get("LANG_KNIGHT_TARGET_ATTRI_CHANGE_TIP", {targetName = G_lang:get("LANG_KNIGHT_TREASURE_JINGLIAN_TARGET_NAME"), targeLevel = treasureJinglianTarget})
    G_flyAttribute.doAddRichtext(desc, nil, nil, nil, nil)

    local targetRecord = team_target_info.get(4, targetLevel)
    if targetRecord then 
        if targetRecord.att_type_1 > 0 then
            local curTargetDesc = G_lang.getGrowthTypeName(
                targetRecord.att_type_1).."+"..G_lang.getGrowthValue(
                targetRecord.att_type_1, targetRecord.att_value_1)
            G_flyAttribute.addNormalText(curTargetDesc, Colors.titleGreen)
        end
        if targetRecord.att_type_2 > 0 then
            local curTargetDesc = G_lang.getGrowthTypeName(
                targetRecord.att_type_2).."+"..G_lang.getGrowthValue(
                targetRecord.att_type_2, targetRecord.att_value_2)
            G_flyAttribute.addNormalText(curTargetDesc, Colors.titleGreen)
        end
        if targetRecord.att_type_3 > 0 then
            local curTargetDesc = G_lang.getGrowthTypeName(
                targetRecord.att_type_3).."+"..G_lang.getGrowthValue(
                targetRecord.att_type_3, targetRecord.att_value_3)
            G_flyAttribute.addNormalText(curTargetDesc, Colors.titleGreen)
        end
    end
end
-- function TreasureRefineLayer:onLayerEnter( ... )
--     -- uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_TREASURE_REFINE, self._onRefineResult, self)
-- end

function TreasureRefineLayer:onLayerExit( ... )
    uf_eventManager:removeListenerWithTarget(self)
    if self._effect then 
        self._effect:removeFromParentAndCleanup(true)
    end
    if self._fire then 
        self._fire:removeFromParentAndCleanup(true)
    end
end

function TreasureRefineLayer:onBackKeyEvent( ... )
    if CCDirector:sharedDirector():getSceneCount() > 1 then 
                uf_sceneManager:popScene()
    else
        uf_sceneManager:replaceScene(require("app.scenes.treasure.TreasureMainScene").new())
    end

    return true
end

--初始化
function TreasureRefineLayer:onLayerLoad( )    
    self:registerWidgetClickEvent("ImageView_pic", function()
        -- uf_sceneManager:popScene()
        self:onBackKeyEvent()
    end)

    self:registerBtnClickEvent("Button_showAttr",function ()
        require("app.scenes.common.CommonAttrLayer").show(self._equipment:getSkillTxt(), tonumber(self._equipment.refining_level))
    end)

    self:getLabelByName("Label_refineCurrentAttr1Title"):createStroke(Colors.strokeBrown,1)
    self:getLabelByName("Label_refineCurrentAttr1Value"):createStroke(Colors.strokeBrown,1)
    self:getLabelByName("Label_refineCurrentAttr2Title"):createStroke(Colors.strokeBrown,1)
    self:getLabelByName("Label_refineCurrentAttr2Value"):createStroke(Colors.strokeBrown,1)

    self:getLabelByName("Label_refineNextAttr1Title"):createStroke(Colors.strokeBrown,1)
    self:getLabelByName("Label_refineNextAttr1Value"):createStroke(Colors.strokeBrown,1)
    self:getLabelByName("Label_refineNextAttr2Title"):createStroke(Colors.strokeBrown,1)
    self:getLabelByName("Label_refineNextAttr2Value"):createStroke(Colors.strokeBrown,1)

    self:getLabelByName("Label_benjieshuxing"):createStroke(Colors.strokeBrown,2)
    self:getLabelByName("Label_xiayijieshuxing"):createStroke(Colors.strokeBrown,2)

    self:getLabelByName("Label_levelDesc"):createStroke(Colors.strokeBrown,1)
    self:getLabelByName("Label_curLevel"):createStroke(Colors.strokeBrown,1)

    self._cell1 = TreasureRefineCailiaoCell.new()
    self._cell2 = TreasureRefineCailiaoCell.new()


    local hlayout = require("app.common.layout.HLayout").new(self:getPanelByName("Panel_cailiaoContainer"), 0, "center")
    hlayout:add(self._cell1)
    hlayout:add(self._cell2)

    self:_treasureMove("ImageView_pic",true)

    -- --精炼返回事件

    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_TREASURE_REFINE, self._onRefineResult, self)


end



--强化等级, 精炼等级
local sortFunc = function(a,b) 
    
    if a.level ~= b.level then
        return a.level < b.level
    end

    return a.refining_level < b.refining_level
end

local function getTreasureCailiaoList(treasure,size)
    --遍历背包, 找到同名宝物, 最低等级那个
    local treasureList = G_Me.bagData:getTreasureListByTreasure(treasure)
    -- 除去已装备的
    -- 去掉已强化和精炼的
    local equipWearOn = G_Me.formationData:getAllFightTreasureList()
    local noWearEquipList = {}
    for key, value in pairs(treasureList) do 
      if value and not equipWearOn[value["id"]] and value.level == 1 and value.refining_level == 0 then
        table.insert(noWearEquipList, #noWearEquipList + 1, value)
      end
    end
    --按照强化等级和突破等级排序
    table.sort(noWearEquipList, sortFunc)

    local cailiaoList = {}
    local hasHighLevel = false
    for i=1, size  do
        if i <= #noWearEquipList  then
            local treasure = noWearEquipList[i]

            table.insert(cailiaoList, treasure.id)
            if treasure.level > 1 or treasure.refining_level >= 1 then
                hasHighLevel = true
            end
        else
            break
        end
    end

    return cailiaoList, hasHighLevel, #noWearEquipList

end



function TreasureRefineLayer:updateView()


    local info = self._equipment:getInfo()
    local nextRefineLevel = self._equipment:getNextRefineLevel()

    local advance_info = treasure_advance_info.get(nextRefineLevel)



    --资质
    self:getLabelByName("Label_zizhi"):setText(G_lang:get("LANG_ZIZHI_VALUE", {zizhi=info.potentiality}))

    --大图
    self:getImageViewByName("ImageView_pic"):loadTexture(self._equipment:getPic())


    --名字
    local nameLabel = self:getLabelByName("Label_equipmentName")
    nameLabel:setColor(Colors.getColor(info.quality))
    nameLabel:setText(info.name)
    nameLabel:createStroke(Colors.strokeBrown, 2)

    -- -- 精炼标题
    -- self:getLabelByName("Label_refineCurrentTitle"):setText(  G_lang.getJinglianValue(self._equipment.refining_level))
    -- self:getLabelByName("Label_refineNextTitle"):setText(  G_lang.getJinglianValue( nextRefineLevel))

    self:getLabelByName("Label_levelDesc"):setText(G_lang:get("LANG_JING_LIAN_CURLEVEL"))
    self:getLabelByName("Label_curLevel"):setText(self._equipment.refining_level..G_lang:get("LANG_JING_LIAN_CURLEVEL2"))

    -- --当前精炼属性
    local attrs = self._equipment:getRefineAttrs()
    TreasureInfo.setAttrLabels(self, attrs,  {"Label_refineCurrentAttr1Title", "Label_refineCurrentAttr1Value", "Label_refineCurrentAttr2Title", "Label_refineCurrentAttr2Value"} )


    -- --下个精炼属性
    local next_attrs = self._equipment:getRefineAttrs(self._equipment:getNextRefineLevel())
    TreasureInfo.setAttrLabels(self, next_attrs,  {"Label_refineNextAttr1Title", "Label_refineNextAttr1Value", "Label_refineNextAttr2Title", "Label_refineNextAttr2Value"} )

    --精炼材料
    -- self:getLabelByName("Label_refineCailiao"):setText(G_lang:get("LANG_JING_LIAN_CAILIAO"))

    --advance_info.cost_num_1 是银两数量, 
    --advance_info.cost_num_2 是精炼石数量
    --advance_info.cost_num_3 是同名宝物数量
    --花费银两
    -- self:getLabelByName("Label_refineMoneyTitle"):setText(G_lang:get("LANG_JING_LIAN_MONEY_COST2"))
    self._per = 1
    --local vip = self:getLabelByName("Label_vip")
    --if G_Me.userData.vip < 4 then
        --vip:setText(G_lang:get("LANG_TREASURE_VIP1"))
    --    self._per = 1
        --vip:setVisible(true)
    --elseif G_Me.userData.vip < 7 then
       -- vip:setText(G_lang:get("LANG_TREASURE_VIP2"))
    --    self._per = 0.5
        --vip:setVisible(true)
    --else
       -- vip:setText(G_lang:get("LANG_TREASURE_VIP3"))
        --vip:setVisible(false)
    --    self._per = 0
    --end
    -- vip:createStroke(Colors.strokeBrown,1)


    local money = self:getLabelByName("Label_refineMoney")
    if advance_info.cost_num_1*self._per > G_Me.userData.money then
      money:setColor(Colors.lightColors.TIPS_01)
    else
        money:setColor(Colors.lightColors.DESCRIPTION)
    end
    money:setText(advance_info.cost_num_1*self._per)

    -- money:createStroke(Colors.strokeBrown,1)

    --材料里的精炼石
    --拥有精炼石的数量
    local itemInfo = G_Me.bagData.propList:getItemByKey(advance_info.cost_value_2)
    local itemCount = itemInfo == nil and 0 or itemInfo.num
    self._cell1:updateData(G_Goods.TYPE_ITEM, advance_info.cost_value_2, advance_info.cost_num_2, itemCount,self._equipment)
    
    --材料里的宝物
    local treasureCailiaoList, hasHighLevel, totalCount = getTreasureCailiaoList(self._equipment, advance_info.cost_num_3)

    self._cell2:updateData(G_Goods.TYPE_TREASURE, info.id, advance_info.cost_num_3, totalCount,self._equipment)




    local function startRefine()
        G_HandlersManager.treasureHandler:sendRefiningTreasure(self._equipment.id, treasureCailiaoList)
    end

    self:registerBtnClickEvent("Button_refine", function()
        if self._playing then
            return
        end

        local level = self._equipment.refining_level
        local maxLevel = self._equipment:getMaxRefineLevel()
        if level >= maxLevel then
            G_MovingTip:showMovingTip(G_lang:get("LANG_REFINE_LEVEL_LIMIT"))
            return
        end

        if G_Me.userData.money < advance_info.cost_num_1*self._per then
            -- G_MovingTip:showMovingTip(G_lang:get("LANG_XILIAN_MONEY_BUZU"))
            require("app.scenes.common.acquireInfo.AcquireInfoLayer").show(G_Goods.TYPE_MONEY, 0,
                GlobalFunc.sceneToPack("app.scenes.equipment.EquipmentDevelopeScene", {self._equipment,2}))
            return
        end

        if advance_info.cost_num_2 > itemCount then 
            -- G_MovingTip:showMovingTip(G_lang:get("LANG_XILIAN_CAILIAO_BUZU"))
            require("app.scenes.common.acquireInfo.AcquireInfoLayer").show(G_Goods.TYPE_ITEM, advance_info.cost_value_2,
                GlobalFunc.sceneToPack("app.scenes.treasure.TreasureDevelopeScene", {self._equipment,2}))
            return
        end

        if advance_info.cost_num_3 > totalCount then 
            -- G_MovingTip:showMovingTip(G_lang:get("LANG_XILIAN_CAILIAO_BUZU"))
            require("app.scenes.common.acquireInfo.AcquireInfoLayer").show(G_Goods.TYPE_TREASURE, self._equipment.base_id,
                GlobalFunc.sceneToPack("app.scenes.treasure.TreasureDevelopeScene", {self._equipment,2}))
            return
        end

        if hasHighLevel then
            MessageBoxEx.showYesNoMessage(nil, 
                G_lang:get("LANG_XILIAN_HAS_HIGH_LEVEL_CAILIAO"), false, 
                function ( ... )
                    startRefine()
                end
            )
        else
            startRefine()
        end
    
    end)
   

end

function TreasureRefineLayer:_stopEffect()

    if self._effect  ~= nil then
        self._effect:stop()
        self:getImageViewByName("ImageView_pic"):removeChild(self._effect)
        self._effect = nil    
    end
end

function TreasureRefineLayer:onUncheck()

    self:_stopEffect()
    self._playing = false
end

function TreasureRefineLayer:onLayerUnload()
    self:onUncheck()
    uf_eventManager:removeListenerWithTarget(self)

end

----------------------------------网络接收---------------------


function TreasureRefineLayer:_onRefineResult(data)    
    if data.ret == NetMsg_ERROR.RET_OK then

        -- self:updateView()


        local deltaLevel = 1
        local oldLevel = self._equipment.refining_level - deltaLevel
        local nextLevel = self._equipment.refining_level

        local attrs = self._equipment:getRefineAttrs(oldLevel )
        local attrsNext = self._equipment:getRefineAttrs(nextLevel)

        --属性变化:
        for i=1,#attrsNext do
            attrsNext[i].delta = attrsNext[i].value - attrs[i].value
        end

        self._playing = true

        local finish_callback = function()
            self._playing = false
            self:updateView()
        end

        local scale = 2.5
        self._effect = EffectNode.new("effect_particle_star", 
            function(event, frameIndex)
                if event == "forever" then
                    self:_stopEffect()
                    -- self._playing = false   
                    self:_flyAttr(attrsNext,finish_callback)
                end
            end
        )
        self._effect:setScale(scale)
        -- self._effect:play()
        self._playing = true   
        self:getImageViewByName("ImageView_pic"):addNode(self._effect)

        self._fire = EffectNode.new("effect_hotfire", 
            function(event, frameIndex)
                if event == "finish" then
                    self._fire:removeFromParentAndCleanup(true)
                    self._fire = nil
                    if self._effect then
                        self._effect:play()
                    end
                end
            end
        )
        self._fire:setPosition(ccp(0,-300))
        self._fire:setScale(6)
        self:getImageViewByName("ImageView_pic"):addNode(self._fire)
        self._fire:play()

    end
end

function TreasureRefineLayer:_flyAttr( attrsNext,finish_callback)
    if not self or not self.isRunning or not self:isRunning() then 
        return 
    end
    
    local levelTxt = G_lang:get("LANG_JING_LIAN_MOVE", {equip=self._equipment:getInfo().name,level=self._equipment.refining_level})

    self:onTreasureJinglian()
    -- G_flyAttribute.addNormalText(levelTxt,nil, self._container:getLabelByName("Label_refineCurrentTitle"), levelDelta)
    G_flyAttribute.addNormalText(levelTxt,Colors.uiColors.ORANGE, self:getLabelByName("Label_curLevel"), levelDelta)
    
    --属性加成
    for i, attrInfo in ipairs(attrsNext) do 
        local labelName 
        if i == 1 then
            labelName = "Label_refineCurrentAttr1Value"
        elseif i==2 then
            labelName = "Label_refineCurrentAttr2Value"
        else
            break
        end
        local type,value,typeString,valueString = self._equipment.convertAttrTypeAndValue(attrInfo.type, attrInfo.delta)
        -- print("attr" .. i .. "," .. attrInfo.typeString  .. ":" .. attrInfo.delta)
        G_flyAttribute.addAttriChange(attrInfo.typeString, valueString, self:getLabelByName(labelName))

    end
    attrsNext = {}

    G_flyAttribute.play(function ( ... )
        finish_callback()
    end)
end


function TreasureRefineLayer:_treasureMove( imgName, blur )
  if not imgName then
    return 
  end
  local imgCtrl = self:getWidgetByName(imgName)
  if not imgCtrl then
    return 
  end

  blur = blur or false

  local time = 1.0
  local offset = 10

  if blur then
    imgCtrl:stopAllActions()
    local anime1 = CCMoveBy:create(time,ccp(0,offset))
    local anime2 = CCMoveBy:create(time,ccp(0,-offset))
    local seqAction = CCSequence:createWithTwoActions(anime1, anime2)
    seqAction = CCRepeatForever:create(seqAction)
    imgCtrl:runAction(seqAction)
  else
    imgCtrl:stopAllActions()
  end
end

return TreasureRefineLayer