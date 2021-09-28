--由于在developerLayer里要同时显示 强化/精炼 equip/treasure等4个页面,所以分开来写逻辑比较清楚

local EquipmentRefine= class("EquipmentRefine")
local RefineItemCell = require("app.scenes.equipment.cell.EquipmentRefineItemCell")
local EffectNode = require "app.common.effects.EffectNode"

local ItemConst = require("app.const.ItemConst")
local Colors = require("app.setting.Colors")
local EquipmentInfo = require("app.scenes.equipment.EquipmentInfo")

local qualityIcon = {"chuji.png",
                    "zhongji.png",
                    "gaoji.png",
                    "jipin.png",}
local imageBegin = "ui/yangcheng/"

function EquipmentRefine:ctor(container)
    self._container = container
    self._useRefineItemId = 0
    self._playing = false
    self._oldRefineLevel = 0
    self._refineListView = nil
    self._refineCellPosition = nil -- 选择精炼的cell的位置, 为了展示动画用
    self._refineClickCount = 0 -- 精炼石点击次数
    self._refineClickShowCount = 0 -- 用于显示
    self._schedule = nil
end

local refineItems = {ItemConst.ITEM_ID.REFINE_ITEM1, ItemConst.ITEM_ID.REFINE_ITEM2, ItemConst.ITEM_ID.REFINE_ITEM3, ItemConst.ITEM_ID.REFINE_ITEM4  }


--初始化
function EquipmentRefine:onLayerLoad( )
    local container = self._container
    self:initContainer()

    container:getLabelByName("Label_refineCurrentAttr1Title"):createStroke(Colors.strokeBrown,1)
    container:getLabelByName("Label_refineCurrentAttr1Value"):createStroke(Colors.strokeBrown,1)
    container:getLabelByName("Label_refineCurrentAttr2Title"):createStroke(Colors.strokeBrown,1)
    container:getLabelByName("Label_refineCurrentAttr2Value"):createStroke(Colors.strokeBrown,1)

    container:getLabelByName("Label_refineNextAttr1Title"):createStroke(Colors.strokeBrown,1)
    container:getLabelByName("Label_refineNextAttr1Value"):createStroke(Colors.strokeBrown,1)
    container:getLabelByName("Label_refineNextAttr2Title"):createStroke(Colors.strokeBrown,1)
    container:getLabelByName("Label_refineNextAttr2Value"):createStroke(Colors.strokeBrown,1)

    container:getLabelByName("Label_refineProgress"):createStroke(Colors.strokeBrown,1)
    container:getLabelByName("Label_meicailiao"):setText(G_lang:get("LANG_REFINE_NO_CAILIAO"))

    container:getLabelByName("Label_benjie"):createStroke(Colors.strokeBrown,2)
    container:getLabelByName("Label_xiayijie"):createStroke(Colors.strokeBrown,2)

    self._container:registerBtnClickEvent("Button_buyRefine",function ()
          -- require("app.scenes.common.dropinfo.DropInfo").show(G_Goods.TYPE_ITEM, REFINE_ITEM1)
          require("app.scenes.common.acquireInfo.AcquireInfoLayer").show(G_Goods.TYPE_ITEM, ItemConst["ITEM_ID"].REFINE_ITEM1,
            GlobalFunc.sceneToPack("app.scenes.equipment.EquipmentDevelopeScene", {2}))
    end)

    self._container:registerBtnClickEvent("Button_showAttr",function ()
        require("app.scenes.common.CommonAttrLayer").show(container:getEquipment():getSkillTxt(), tonumber(container:getEquipment().refining_level))
    end)

    self._container:registerBtnClickEvent("Button_fastRefine",function ()
        if  self._playing then
            return false
        end
        self._oldRefineLevel = container:getEquipment().refining_level
        local layer = require("app.scenes.equipment.FastRefineLayer")
        layer.show(layer.TYPE_EQUIPMENT,self._container:getEquipment())
    end)

    --建立4个cell显示精灵石
    -- self._refineListView = CCSListViewEx:createWithPanel(container:getPanelByName("Panel_refineItemContainer"), LISTVIEW_DIR_HORIZONTAL)

    -- self._refineListView:setCreateCellHandler(function ( list, index)
    --     local cell =  RefineItemCell.new(list, index)
    --     cell:setCallback(handler(self,  self.onClick))
    --     return cell
    -- end)

    self._cell1 = RefineItemCell.new()
    self._cell2 = RefineItemCell.new()
    self._cell3 = RefineItemCell.new()
    self._cell4 = RefineItemCell.new()
    self._cell1:setCallback(handler(self,  self.onClick))
    self._cell2:setCallback(handler(self,  self.onClick))
    self._cell3:setCallback(handler(self,  self.onClick))
    self._cell4:setCallback(handler(self,  self.onClick))

    local gap = G_moduleUnlock:isModuleUnlock(require("app.const.FunctionLevelConst").FAST_REFINE) and -7 or 0
    local hlayout = require("app.common.layout.HLayout").new(self._container:getPanelByName("Panel_refineItemContainer"), gap, "center")
    hlayout:add(self._cell1)
    hlayout:add(self._cell2)
    hlayout:add(self._cell3)
    hlayout:add(self._cell4)

    self:_refreshRefineItems()

    --精炼返回事件
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_EQUIPMENT_REFINE, self._onRefineResult, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_EQUIPMENT_FASTREFINE, self._onRefineResult, self)

    self._refineClickCount = 0
    self._refineClickShowCount = 0
end

function EquipmentRefine:initContainer( )
    local open = G_moduleUnlock:isModuleUnlock(require("app.const.FunctionLevelConst").FAST_REFINE)
    self._container:getButtonByName("Button_fastRefine"):setVisible(open)

    local baseOffset = open and 1 or 0
    self._container:getLabelByName("Label_curLevel"):setPositionXY(95-baseOffset*15,153)
    self._container:getImageViewByName("ImageView_progress"):setPositionXY(335-baseOffset*20,153)
    self._container:getImageViewByName("ImageView_progress"):setScaleX(open and 0.90 or 1)
    self._container:getLabelByName("Label_refineProgress"):setPositionXY(335-baseOffset*20,153)
    self._container:getPanelByName("Panel_refineItemContainer"):setPositionXY(0-baseOffset*40,10)
end

-- function EquipmentRefine:onLayerEnter( ... )
--     -- uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_EQUIPMENT_REFINE, self._onRefineResult, self)
-- end

function EquipmentRefine:onLayerExit( ... )
    self._refineClickCount = 0
    self._refineClickShowCount = 0
    uf_eventManager:removeListenerWithTarget(self)
    if self._effect then 
        self._effect:removeFromParentAndCleanup(true)
        self._effect = nil
    end
    if self._fire then 
        self._fire:removeFromParentAndCleanup(true)
        self._fire = nil
    end
    if self._luzi then 
        self._luzi:removeFromParentAndCleanup(true)
        self._luzi = nil
    end
end

function EquipmentRefine:_refreshRefineItems()
    local container = self._container

    -- local hasRefineItems = {}
    -- for i=1,#refineItems do
    --     local refineItemInfo = G_Me.bagData.propList:getItemByKey(refineItems[i])
    --     if refineItemInfo and refineItemInfo.num > 0 then
    --         table.insert(hasRefineItems, refineItems[i])
    --     end

    -- end

    -- if #hasRefineItems == 0 then
    --     container:getButtonByName("Button_buyRefine"):setVisible(true)
    --     self._refineListView:setVisible(false)
    -- else
    --     container:getButtonByName("Button_buyRefine"):setVisible(false)
    --     self._refineListView:setVisible(true)

    --     self._refineListView:setUpdateCellHandler(function ( list, index, cell)
    --          if  index < #hasRefineItems then
    --             cell:updateData(hasRefineItems[index+1]) 
    --          end
    --     end)
    --     self._refineListView:initChildWithDataLength( #hasRefineItems)
    -- end

    container:getButtonByName("Button_buyRefine"):setVisible(false)
    -- self._refineListView:setVisible(true)

    -- self._refineListView:setUpdateCellHandler(function ( list, index, cell)
    --      if  index < #refineItems then
    --         cell:updateData(refineItems[index+1]) 
    --      end
    -- end)
    -- self._refineListView:initChildWithDataLength( #refineItems)
  self._cell1:updateData(refineItems[1],container:getEquipment(),self._useRefineItemId == refineItems[1] and self._refineClickShowCount or 0) 
  self._cell2:updateData(refineItems[2],container:getEquipment(),self._useRefineItemId == refineItems[2] and self._refineClickShowCount or 0) 
  self._cell3:updateData(refineItems[3],container:getEquipment(),self._useRefineItemId == refineItems[3] and self._refineClickShowCount or 0) 
  self._cell4:updateData(refineItems[4],container:getEquipment(),self._useRefineItemId == refineItems[4] and self._refineClickShowCount or 0) 

end

function EquipmentRefine:onClick(refineItemId, cell, _type)
    if  self._playing then
        return false
    end
    -- print("onClick")
    -- if _type then
    --     self._refineClickTime = G_ServerTime:getTime()
    --     return
    -- end
    local container = self._container
    local equipment = container:getEquipment()
    if not equipment then
        return
    end
    self._refineCellPosition = cell:getImagePosition()
    self._useRefineItemId = refineItemId
    self._oldRefineLevel = equipment.refining_level

    local level = equipment.refining_level
    local maxLevel = equipment:getMaxRefineLevel()
    if level >= maxLevel then
        G_MovingTip:showMovingTip(G_lang:get("LANG_REFINE_LEVEL_LIMIT"))
        return false
    end

    if _type then
        self._refineClickCount = self._refineClickCount + 1
        self._refineClickShowCount = self._refineClickCount
        self:_flyIcon()
        if self:checkUpLevel() then
            self:endRefine()
        else
            if self._schedule == nil then
                self._schedule = GlobalFunc.addTimer(0.1, handler(self, self._onUpdate))
            end
        end
        return true
    end

    -- local refineItemInfo = G_Me.bagData.propList:getItemByKey(refineItemId)
    -- local baseInfo = item_info.get(refineItemId)
    if self._refineClickCount == 1 then
        local x, y = container:getLabelByName("Label_refineProgress"):convertToWorldSpaceXY(0, 0)
        require("app.scenes.common.CommonInfoTipLayer").show(G_lang:get("LANG_KNIGHT_GUANZHI_REPEAT_TIP"), y + 60, 2)
    end

    if self._refineClickCount > 0 then
        self:endRefine()
    end
    -- if refineItemInfo and refineItemInfo.num > 0 then

    -- else
    --     G_MovingTip:showMovingTip(G_lang:get("LANG_NO_ENOUGH_AMOUNT", {item_name=baseInfo.name}))

    -- end

    return true
end

function EquipmentRefine:endRefine()

    if self._schedule then
        GlobalFunc.removeTimer(self._schedule)
        self._schedule = nil
    end
    local container = self._container
    local equipment = container:getEquipment()
    local refineItemId = self._useRefineItemId
    -- print("send  refineItemId  "..refineItemId.."   ClickCount   "..self._refineClickCount)
    -- self._refineClickCount = 12320
    G_HandlersManager.equipmentStrengthenHandler:sendEquipmentRefine(equipment.id, refineItemId,self._refineClickCount)
    self._refineClickCount = 0
    self._playing = true
    
end

function EquipmentRefine:stopCellEffect()
    self._cell1:stopEffect()
    self._cell2:stopEffect()
    self._cell3:stopEffect()
    self._cell4:stopEffect()
end

function EquipmentRefine:setTouchable(able)
    self._playing = not able
end

function EquipmentRefine:updateView()

    local container = self._container
    local equipment = container:getEquipment()

    -- local equipment = container:getEquipment()
    -- local totalExp = 0
    -- for i = 0 , equipment:getMaxRefineLevel() do 
    --     totalExp = totalExp + equipment:getRefineNextLevelExp(i)
    -- end
    -- print("totalExp "..totalExp)
    -- 精炼标题图
    local nextRefineLevel = equipment:getNextRefineLevel()
    -- container:getImageViewByName("ImageView_refineCurrentTitle"):loadTexture(  G_Path.getRefineLevelPic(equipment.refining_level ) )
    -- container:getImageViewByName("ImageView_refineNextTitle"):loadTexture(  G_Path.getRefineLevelPic(nextRefineLevel) )

    -- -- 精炼标题
    -- container:getLabelByName("Label_refineCurrentTitle"):setText(  G_lang.getJinglianValue(equipment.refining_level))
    -- container:getLabelByName("Label_refineNextTitle"):setText(  G_lang.getJinglianValue( nextRefineLevel))


    --当前精炼属性
    local attrs = equipment:getRefineAttrs()
    EquipmentInfo.setAttrLabels(container, attrs,  {"Label_refineCurrentAttr1Title", "Label_refineCurrentAttr1Value", "Label_refineCurrentAttr2Title", "Label_refineCurrentAttr2Value"} )


    --下个精炼属性
    local next_attrs = equipment:getRefineAttrs(equipment:getNextRefineLevel())
    EquipmentInfo.setAttrLabels(container,next_attrs,  {"Label_refineNextAttr1Title", "Label_refineNextAttr1Value", "Label_refineNextAttr2Title", "Label_refineNextAttr2Value"} )

    --当前精炼面板
    -- container:getLabelByName("Label_currentRefineLevel"):setText( G_lang.getJinglianValue(equipment.refining_level) )
    container:getLabelByName("Label_currentRefineLevel"):setText(G_lang:get("LANG_JING_LIAN_LEVEL"))
    container:getLabelByName("Label_curLevel"):setText(G_lang:get("LANG_JING_LIAN_NEW", {level = equipment.refining_level}))
    -- container:getLabelByName("Label_currentRefineLevel"):createStroke(Colors.strokeBrown,1)
    -- container:getLabelByName("Label_curLevel"):createStroke(Colors.strokeBrown,1)

    self:updateExpBar()

end

function EquipmentRefine:updateExpBar()

    local container = self._container
    local equipment = container:getEquipment()

    local leftRefineExp = equipment:getLeftRefineExp()
    if self._refineClickShowCount > 0 then
        local baseInfo = item_info.get(self._useRefineItemId)
        leftRefineExp = leftRefineExp + self._refineClickShowCount * baseInfo.item_value
    end
    container:getLabelByName("Label_refineProgress"):setText( leftRefineExp .. "/" ..  equipment:getRefineNextLevelExp() )


    local percent = leftRefineExp  /  equipment:getRefineNextLevelExp() * 100
    container:getLoadingBarByName("LoadingBar_refineProgress"):setPercent(percent)


    self:_refreshRefineItems()

end

function EquipmentRefine:checkUpLevel()
    if self._refineClickCount > 0 then
        local container = self._container
        local equipment = container:getEquipment()
        local leftRefineExp = equipment:getLeftRefineExp()
        local baseInfo = item_info.get(self._useRefineItemId)
        leftRefineExp = leftRefineExp + self._refineClickCount * baseInfo.item_value
        local expNeed = equipment:getRefineNextLevelExp(equipment.refining_level)
        return leftRefineExp >= expNeed
    else
        return false
    end
end

function EquipmentRefine:onUncheck()
    self:_stopEffect()
    self._playing = false
end

function EquipmentRefine:onLayerUnload()
    self:onUncheck()
    uf_eventManager:removeListenerWithTarget(self)

end

function EquipmentRefine:_stopEffect()

    if self._effect  ~= nil then

        self._effect:stop()
        self._effect:removeFromParentAndCleanup(true)
        self._effect = nil    
    end
end

function EquipmentRefine:_getIndex( refineItemId)
    for i = 1, 4 do 
        if refineItemId == refineItems[i] then
            return i
        end
    end
    return 1
end

function EquipmentRefine:_onUpdate( )
        local refineItemInfo = G_Me.bagData.propList:getItemByKey(self._useRefineItemId)
        local baseInfo = item_info.get(self._useRefineItemId)
        if refineItemInfo and refineItemInfo.num > self._refineClickCount then
            self._refineClickCount = self._refineClickCount + 1
            self._refineClickShowCount = self._refineClickCount
            self:_flyIcon()
            if self:checkUpLevel() then
                self:endRefine()
            end
        else
            G_MovingTip:showMovingTip(G_lang:get("LANG_NO_ENOUGH_AMOUNT", {item_name=baseInfo.name}))
            self:endRefine()
        end 
end

----------------------------------网络接收---------------------


function EquipmentRefine:_onRefineResult(data)    
    if data.ret == NetMsg_ERROR.RET_OK then
        local baseInfo = item_info.get(self._useRefineItemId)
        local container = self._container
        local equipment = container:getEquipment()
        self._refineClickShowCount = self._refineClickCount

        local refineAni = function ( levelup )
            if levelup then
                self._playing = true
                self:stopCellEffect()
                local nextLevel = equipment.refining_level

                local attrs = equipment:getRefineAttrs(self._oldRefineLevel )
                local attrsNext = equipment:getRefineAttrs(nextLevel)

                --属性变化:
                for i=1,#attrsNext do
                    local deltaString = G_lang.getGrowthValue(attrsNext[i].type, attrsNext[i].value - attrs[i].value)
                    attrsNext[i].delta = deltaString
                end

                local finishEffect  = false
                local finish_callback = function()
                    if G_SceneObserver:getSceneName() ~= "EquipmentDevelopeScene" then
                        return
                    end
                    if finishEffect then
                        self._playing = false
                        self:updateView()

                    end

                end

                if self._effect == nil then 
                        self._effect = EffectNode.new("effect_particle_star", 
                            function(event, frameIndex)
                                if event == "forever" then
                                    self:_stopEffect()
                                    finishEffect = true
                                    self:_flyAttr(attrsNext,finish_callback)
                                end
                                -- if event == "finish" then
                                --     self._effect:removeFromParentAndCleanup(true)
                                --     finishEffect = true
                                --     self:_flyAttr(attrsNext,finish_callback)
                                -- end
                            end
                        )
                end
                -- self._effect:setScale(5)
                -- self._effect:play()
                container:getEffectNode():addNode(self._effect)

                if self._fire == nil then 
                    self._fire = EffectNode.new("effect_hotfire", 
                        function(event, frameIndex)
                            if event == "finish" then
                                if self._fire then
                                    self._fire:removeFromParentAndCleanup(true)
                                    self._fire = nil
                                end
                                if self._effect then 
                                    self._effect:play()
                                end
                            end
                        end
                    )
                    self._fire:setPosition(ccp(0,-100))
                    self._fire:setScale(2)
                    container:getEffectNode():addNode(self._fire)
                    self._fire:play()
                end
            else
                -- self:updateView()
                self._playing = false
                self:updateExpBar()
            end
        end
        local levelup = self._oldRefineLevel < equipment.refining_level
        refineAni(levelup)
    end
end

function EquipmentRefine:_flyIcon( )

    local baseInfo = item_info.get(self._useRefineItemId)
    local container = self._container
    local equipment = container:getEquipment()

    local addXXXX = function ( )
        -- 精炼值+XXXX 
        local pt = container:getLabelByName("Label_refineProgress"):convertToWorldSpace(ccp(0, 0))
        pt.y = pt.y + 60
        local tip = require("app.scenes.equipment.tip.EquipmentRefineTip").new()
        tip:setPosition(pt)
        tip:playWithText(G_lang:get("LANG_REFINE_TIP", {refine_exp=baseInfo.item_value}))
        tip:setScale(2)
        local moveScale = CCScaleTo:create(1.0,1)
        tip:runAction(moveScale)
        uf_notifyLayer:getTipNode():addChild(tip) 
    end

    --产生一个icon, 缩小飞到经验条
    -- local icon = CCSprite:create(G_Path.getItemIcon(baseInfo.res_id))
    local icon = CCSprite:create(imageBegin..qualityIcon[self:_getIndex(self._useRefineItemId)])
    icon:setPosition(container:convertToNodeSpace(self._refineCellPosition))
    icon:setScale(0.9)
    local rect = icon:getContentSize()
    local pos = ccp(0,0)
    if self._useRefineItemId == refineItems[1] then 
        pos = ccp(-rect.width/2,0)
    elseif self._useRefineItemId == refineItems[2] then 
        pos = ccp(-rect.width/6,0)
    elseif self._useRefineItemId == refineItems[3] then 
        pos = ccp(rect.width/6,0)
    elseif self._useRefineItemId == refineItems[4] then 
        pos = ccp(rect.width/2,0)
    end
    local emiter = CCParticleSystemQuad:create("particles/lizi1.plist")
    emiter:setPosition(pos)
    icon:addChild(emiter)
    container:addChild(icon)
    transition.scaleTo(icon, {time=0.6, scaleX=0.1, scaleY =0.1})
    transition.fadeTo(icon, {time=0.6, opacity=0})
    local ptx, pty = container:getLabelByName("Label_refineProgress"):getPosition()
    local moveto = CCMoveTo:create(0.6, ccp(ptx, pty+10))
    local seq= transition.sequence({
        moveto,
        CCCallFunc:create(
            function() 
                emiter:stopSystem()
                self:updateExpBar()
                addXXXX()
                local added = nil
                added = EffectNode.new("effect_jinglian_xiaoshi", 
                    function(event, frameIndex)
                        if event == "finish" then
                            added:removeFromParentAndCleanup(true)
                        end
                    end
                )
                container:addChild(added)
                added:setPosition(ccp(ptx, pty+10))
                added:play()
                icon:removeFromParentAndCleanup(true)
            end
        )
    })
    icon:runAction(seq)
end

function EquipmentRefine:_flyAttr( attrsNext,finish_callback)
    if not self._container or not self._container.isRunning or not self._container:isRunning() then 
        return 
    end
    if self._container.onEquipJinglian then 
        self._container:onEquipJinglian()
    end
    G_flyAttribute._clearFlyAttributes()

    local deltaLevel = self._container:getEquipment().refining_level - self._oldRefineLevel
    local levelTxt = G_lang:get("LANG_JING_LIAN_MOVE", {equip=self._container._equipment:getInfo().name,level=self._container:getEquipment().refining_level})

    local basePic = self._container:getImageViewByName("ImageView_pic")
    local basePos = basePic:getParent():convertToWorldSpace(ccp(basePic:getPosition()))
    local size = basePic:getContentSize()
    local pos1 = ccp(basePos.x,basePos.y+size.height/2)
    G_flyAttribute.addNormalText(levelTxt,Colors.uiColors.ORANGE, self._container:getLabelByName("Label_curLevel"))
    
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
        --print("attr" .. i .. "," .. attrInfo.typeString  .. ":" .. attrInfo.delta)
        G_flyAttribute.addAttriChange(attrInfo.typeString, attrInfo.delta, self._container:getLabelByName(labelName))
    end
    attrsNext = {}

    G_flyAttribute.play(function ( ... )
        finish_callback()
    end)
end

return EquipmentRefine