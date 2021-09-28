-- HeroAwakenItemComposeLayer

local ALIGN_CENTER = "align_center"
local ALIGN_LEFT = "align_left"
local ALIGN_RIGHT = "align_right"
require("app.cfg.item_awaken_info")
require("app.cfg.item_awaken_compose")
local BagConst = require("app.const.BagConst")
local FunctionLevelConst = require "app.const.FunctionLevelConst"
-- @basePosition 这里指的是基准点的位置，因为现在只支持居中对齐，所以basePosition指的是中心点的位置
-- @items 需要对齐的子项，是个table
-- @align 对齐方式

local function _autoAlign(basePosition, items, align)
    
    -- 先统计总共的宽度，因为这里居中对齐不需要考虑高度
    local totalWidth = 0
    for i=1, #items do
        totalWidth = totalWidth + items[i]:getContentSize().width
    end
    
    local function _convertToNodePosition(position, item)

        -- print("position.x: "..position.x.." position.y: "..position.y)

        -- 默认是以ccp(0, 0.5)为标准
        local anchorPoint = item:getAnchorPoint()
        return ccp(position.x + anchorPoint.x * item:getContentSize().width, position.y + (anchorPoint.y - 0.5) * item:getContentSize().height)

    end
    
    if align == ALIGN_CENTER then

        -- 然后返回一个函数，用来获取每一项节点的位置（通过index）
        return function(index)

            assert(index > 0 and index <= #items, "Invalid index: "..index)

            -- 统计下目前为止左边项所占据的宽度
            local _width = 0
            for i=1, index-1 do
                _width = _width + items[i]:getContentSize().width
            end

            -- print("basePosition.x: "..basePosition.x.." basePosition.y: "..basePosition.y)
            -- print("totalWidth: "..totalWidth)
            -- print("_width: ".._width)

            return _convertToNodePosition(ccp(basePosition.x - totalWidth/2 + _width, 0), items[index])

        end
        
    elseif align == ALIGN_LEFT then
        
        return function(index)

            assert(index > 0 and index <= #items, "Invalid index: "..index)

            -- 统计下目前为止左边项所占据的宽度
            local _width = 0
            for i=1, index-1 do
                _width = _width + items[i]:getContentSize().width
            end

            -- print("basePosition.x: "..basePosition.x.." basePosition.y: "..basePosition.y)
            -- print("totalWidth: "..totalWidth)
            -- print("_width: ".._width)

            return _convertToNodePosition(ccp(basePosition.x + _width, 0), items[index])

        end
        
    elseif align == ALIGN_RIGHT then
        
        return function(index)

            assert(index > 0 and index <= #items, "Invalid index: "..index)

            -- 统计下目前为止左边项所占据的宽度
            local _width = 0
            for i=1, index-1 do
                _width = _width + items[i]:getContentSize().width
            end

            -- print("basePosition.x: "..basePosition.x.." basePosition.y: "..basePosition.y)
            -- print("totalWidth: "..totalWidth)
            -- print("_width: ".._width)

            return _convertToNodePosition(ccp(basePosition.x - totalWidth + _width, 0), items[index])

        end

    else
        
        assert(false, "Now we don't support other align type :"..align)
        
    end

end


require "app.cfg.item_awaken_info"
require "app.cfg.item_awaken_compose"
require "app.cfg.way_type_info"
require "app.cfg.way_function_info"

local FunctionLevelConst = require "app.const.FunctionLevelConst"
local EffectNode = require "app.common.effects.EffectNode"


local HeroAwakenItemComposeLayer = class("HeroAwakenItemComposeLayer", UFCCSModelLayer)


function HeroAwakenItemComposeLayer.create(...)
    return HeroAwakenItemComposeLayer.new("ui_layout/HeroAwakenItemComposeLayer.json", Colors.modelColor, ...)
end

function HeroAwakenItemComposeLayer:ctor(_, _, _, itemId, scenePack, callback)
    
    HeroAwakenItemComposeLayer.super.ctor(self)
    
    self:closeAtReturn(true)
    self:adapterWithScreen()
    
    self._itemNums = {}
    self._middlePosition = 0
    -- 创建场景的参数
    self._scenePack = scenePack
    self._parentLayer = nil
    -- 跳转到合成界面
    self._scenePack.param[3] = itemId

    -- 道具id
    self._itemId = itemId

    -- 当前顶端道具id
    self._topId = itemId

    -- 回调通知
    self._callback = callback
    
    -- 合成过程中所需的item
    self._composeItems = {container = {}}
    
    self._composeItems.add = function(level, item)
        local levelContainer = self._composeItems.container[level] or {}
        levelContainer[#levelContainer+1] = item
        self._composeItems.container[level] = levelContainer
    end
    
    self._composeItems.remove = function(level)
        table.remove(self._composeItems.container, level)
    end
    
    self._composeItems.clear = function(level)
        self._composeItems.container[level] = {}
    end
    
    self._composeItems.at = function(level, index)
        return self._composeItems.container[level][index]
    end
    
    self._composeItems.count = function(level)
        return #self._composeItems.container[level]
    end
    
    self._composeItems.levelCount = function()
        return #self._composeItems.container
    end
    
    self._composeItems.add(1, {id=itemId, num=1})
    
end

function HeroAwakenItemComposeLayer:onBackKeyEvent( ... )
    if self._lock then return end
    -- 上层需要刷新  注意红色觉醒道具处理
    if self._parentLayer and item_awaken_info.get(self._itemId).quality < BagConst.QUALITY_TYPE.RED then 
        self._parentLayer:reloadCheckBox(G_Me.shopData:isAwakenTags(self._itemId) )
    end 
    self:animationToClose()
    local soundConst = require("app.const.SoundConst")
    G_SoundManager:playSound(soundConst.GameSound.BUTTON_SHORT)
    return true
end

function HeroAwakenItemComposeLayer:onLayerEnter()
    self:registerKeypadEvent(true)
    require("app.common.effects.EffectSingleMoving").run(self, "smoving_bounce")
    self:_updateView()
end

function HeroAwakenItemComposeLayer:setParentLayer(_parent)
    self._parentLayer = _parent
end 

function HeroAwakenItemComposeLayer:_updateView()
    
    self:registerBtnClickEvent("Button_close", function(widget)
        self:onBackKeyEvent()
    end )
    self:enableAudioEffectByName("Button_close", false)
    
    -- 更新合成树/获取方式
    if self:canBeComposed(self._composeItems.at(self._composeItems.levelCount(), 1).id) then
        self:updateComposeTree(nil, false)
    else
        self:updateTheWay(nil, false)
    end
end

function HeroAwakenItemComposeLayer:popItem()
    self._composeItems.remove(self._composeItems.levelCount())
end

function HeroAwakenItemComposeLayer:enoughToCompose()
    -- 取栈顶的数据，判断背包里的道具数量是否大于等于期望的道具数量
    local item = self._composeItems.at(self._composeItems.levelCount(), 1)
    
    return G_Me.bagData:getAwakenItemNumById(item.id) >= item.num
end

-- 获取当前页面玩家操作到的合成层级
function HeroAwakenItemComposeLayer:getLevel()
    return self._composeItems.levelCount()
end

function HeroAwakenItemComposeLayer:canBeComposed(itemId)
    
    local itemInfo = item_awaken_info.get(itemId)
    assert(itemInfo, "Could not find the awaken item with id: "..itemId)
    
    return itemInfo.compose_id ~= 0

end

-- 更新合成树，level表示第几层合成树, 默认为最顶层
function HeroAwakenItemComposeLayer:updateComposeTree(level, withAnimation)
    
    level = level or self._composeItems.levelCount()
    
    -- 首先看看这个道具由几层合成, 第一个节点的数据表示主合成道具
    local item = self._composeItems.at(level, 1)

    self._topId = item.id
    local itemInfo = item_awaken_info.get(item.id)
    assert(itemInfo, "Could not find the awaken item with id: "..item.id)
    
    -- 显示合成树，隐藏来源方式
    self:updatePanel("Panel_compose_tree", {visible=true})
    self:updatePanel("Panel_compose_way", {visible=false})
    
    -- 先清理当前层级数据
    self._composeItems.clear(level)
    
    -- 添加主合成道具
    self._composeItems.add(level, item)
    
    local itemComposeInfo = nil
    
    if self:canBeComposed(item.id) then
        itemComposeInfo = item_awaken_compose.get(itemInfo.compose_id)
        -- 最多4个部件合成
        for i=1, 4 do
            local composePartId = itemComposeInfo["compose_part_"..i]
            if composePartId ~= 0 then
                self._composeItems.add(level, {id=composePartId, num=itemComposeInfo["compose_num_"..i]})
            end
        end
    else
        assert(false, "This item ("..item.id..") could not be composed !")
    end
    
    -- 默认有动画，除非指定没有
    if withAnimation or withAnimation == nil then
        local panel = self:getPanelByName("Panel_compose_tree")
        panel:stopAllActions()
        panel:setOpacity(0)
        panel:runAction(CCFadeIn:create(0.15))
    end
    
    -- 根据判断出来当前的道具需要几个合成来决定使用那个UI显示, -1是扣除要合成的那个
    local count = self._composeItems.count(level) - 1
    self:updatePanel("Panel_compose_tree2", {visible=(count == 2)})
    self:updatePanel("Panel_compose_tree3", {visible=(count == 3)})
    self:updatePanel("Panel_compose_tree4", {visible=(count == 4)})
    
    -- 清理所有动画
    for i=2, 4 do
        self:getPanelByName("Panel_compose_tree"..i):removeAllNodes()
    end
    
    -- 然后更新合成树
 
    -- 主合成道具名称title
    self:updateLabel("Label_title", {text=itemInfo.name, color=Colors.qualityColors[itemInfo.quality], stroke=Colors.strokeBrown, strokeSize=2})
    
    -- 品级框
    self:updateImageView("Image_main_item_frame"..count, {texture=G_Path.getEquipColorImage(itemInfo.quality), texType=UI_TEX_TYPE_PLIST})
    -- 背景
    self:updateImageView("Image_main_item_bg"..count, {texture=G_Path.getEquipIconBack(itemInfo.quality), texType=UI_TEX_TYPE_PLIST})
    -- icon
    self:updateImageView("Image_main_item_icon"..count, {texture=itemInfo.icon})
    -- 数量
    self:updateLabel("Label_main_item_amount"..count, {text=G_Me.bagData:getAwakenItemNumById(item.id).."/"..item.num, stroke=Colors.strokeBrown, strokeSize=2})
    --checkbox
    self:updateLabel("Label_select_name", {text=itemInfo.name, color=Colors.qualityColors[itemInfo.quality], stroke=Colors.strokeBrown, strokeSize=2})
    self:updateLabel("Label_select_0", {text=G_lang:get("LANG_AWAKEN_TAGS_TEXT"),  stroke=Colors.strokeBrown, strokeSize=2})

    -- 标记一下有没有道具不足
    local enoughItems = true
    local missItemId = nil
    
    -- 然后是合成所需道具
    for i=1, count do
        
        local subItem = self._composeItems.at(level, i+1)
        local subItemId = subItem.id
        local subItemInfo = item_awaken_info.get(subItemId)
        assert(subItemInfo, "Could not find the awaken item with id: "..subItemId)
        
        -- 品级框
        self:updateImageView("Image_branch_item_frame"..count..i, {texture=G_Path.getEquipColorImage(subItemInfo.quality), texType=UI_TEX_TYPE_PLIST})
        -- 背景
        self:updateImageView("Image_branch_item_bg"..count..i, {texture=G_Path.getEquipIconBack(subItemInfo.quality), texType=UI_TEX_TYPE_PLIST})
        -- icon
        self:updateImageView("Image_branch_item_icon"..count..i, {texture=subItemInfo.icon})
        
        -- 数量
        local curNum = G_Me.bagData:getAwakenItemNumById(subItemId)
        local expectNum = subItem.num
        self:updateLabel("Label_branch_item_amount"..count..i, {text=curNum.."/"..expectNum, color=curNum < expectNum and Colors.qualityColors[6] or Colors.darkColors.DESCRIPTION, stroke=Colors.strokeBrown, strokeSize=2})
        
        enoughItems = enoughItems and curNum >= expectNum
        missItemId = missItemId or (not enoughItems and subItemId)
        
        self:registerWidgetClickEvent("Image_branch_item"..count..i, function()
            
            if self._lock then return end
            
            -- 添加一个数据至下一层级
            self._composeItems.add(level+1, subItem)
            
            -- 看看是否是可合成的道具
            if self:canBeComposed(subItemId) then    
                -- 然后更新下一层级的合成树
                self:updateComposeTree(level+1)
            -- 不可合成，则直接去获取
            else
                self:updateTheWay(level+1)
            end
        end)
        
    end
    
    -- 更新道具合成游标
    self:updateItemCursor()
    
    -- 合成花费
    self:updateLabel("Label_compose_cost_desc", {text=G_lang:get("LANG_AWAKEN_ITEM_COMPOSE_COST_DESC")})
    self:updateLabel("Label_compose_cost_amount", {text=itemComposeInfo.compose_cost})
    
    -- 校准一下位置
    local getPosition = _autoAlign(ccp(0, 0), {self:getLabelByName("Label_compose_cost_desc"), self:getImageViewByName("Image_cost_icon"), self:getLabelByName("Label_compose_cost_amount")}, ALIGN_CENTER)
    self:getLabelByName("Label_compose_cost_desc"):setPosition(getPosition(1))
    self:getImageViewByName("Image_cost_icon"):setPosition(getPosition(2))
    self:getLabelByName("Label_compose_cost_amount"):setPosition(getPosition(3))
    
    self:getButtonByName("Button_compose"):setEnabled(true)
    self:getButtonByName("Button_compose_0"):setEnabled(true)

-- 等级限制开启
    if G_moduleUnlock:isModuleUnlock(FunctionLevelConst.FAST_COMPOSE_AWAKEN_ITEM) == false and self._middlePosition == 0 then
        self._middlePosition = self:getButtonByName("Button_compose"):getPositionX()/2 + self:getButtonByName("Button_compose_0"):getPositionX()/2 
        self:getButtonByName("Button_compose_0"):setPositionX(self._middlePosition)
        self:getButtonByName("Button_compose"):setVisible(false)
    end 

     -- 合成
    self:registerBtnClickEvent("Button_compose_0", function() 
        if self._lock then return end
        
        -- 银两不足或者有道具不足都要提示
        if not enoughItems then
            if self:canBeComposed(missItemId) then
                G_MovingTip:showMovingTip(G_lang:get("LANG_AWAKEN_COMPOSE_ITEM_ERROR_NO_ENOUGH_ITEM_TREE"))
            else
                G_MovingTip:showMovingTip(G_lang:get("LANG_AWAKEN_COMPOSE_ITEM_ERROR_NO_ENOUGH_ITEM_WAY"))
            end
        elseif G_Me.userData.money < itemComposeInfo.compose_cost then
            G_MovingTip:showMovingTip(G_lang:get("LANG_AWAKEN_COMPOSE_ITEM_ERROR_NO_ENOUGH_MONEY"))
        else
            -- 请求合成装备，把选择项通过回调函数通知外面，自己不做决定
            if self._callback then
                self._callback(item.id, self)
            end
        end
    end)

    -- 一键合成
    self:registerBtnClickEvent("Button_compose", function()
        
        if self._lock then return end


        local curNum = G_Me.bagData:getAwakenItemNumById(item.id)
        local expectNum = item.num
        local canNum = 0
        -- 如果现有的数目已经够了，就只合成一个
        if curNum >= expectNum then 
            canNum = G_Me.bagData:awakenItemCanBeFastComposed(item.id , 1)
        else 
            canNum = G_Me.bagData:awakenItemCanBeFastComposed(item.id , expectNum - curNum)
        end 
        -- print("canNum = " .. tostring(canNum))
        if self._callback and canNum > 0 then
            self:checkNum()
            self._callback(item.id, self, true,canNum)
        end
        if canNum == 0 then 
            G_MovingTip:showMovingTip(G_lang:get("LANG_AWAKEN_COMPOSE_ITEM_ERROR_NO_ENOUGH_ITEM_WAY"))
        elseif canNum == -1 then 
            G_MovingTip:showMovingTip(G_lang:get("LANG_AWAKEN_COMPOSE_ITEM_ERROR_NO_ENOUGH_MONEY"))
        end 

    end)

    if G_moduleUnlock:isModuleUnlock(FunctionLevelConst.AWAKEN_MARK) and item_awaken_info.get(self._topId).quality < BagConst.QUALITY_TYPE.RED then 
        self:getPanelByName("Panel_checkbox"):setVisible(true)
        -- 先判断是否应该选中
        self:getCheckBoxByName("CheckBox_select_0"):setSelectedState(G_Me.shopData:isAwakenTags(self._topId))

        self:registerCheckboxEvent("CheckBox_select_0", function ( ... )
            self:_onCheckBoxChange(...)
        end)
    else 
        self:getPanelByName("Panel_checkbox"):setVisible(false)
    end 

    --add by kaka 都可以获取 否则要增加品质限制
    self:registerBtnClickEvent("Button_get", function()
        require("app.scenes.common.acquireInfo.AcquireInfoLayer").show(G_Goods.TYPE_AWAKEN_ITEM, itemInfo.id, self._scenePack)
    end)
    
end

function HeroAwakenItemComposeLayer:_onCheckBoxChange( checkbox, checkType, isCheck )
    if isCheck then 
        if not G_Me.shopData:canAdd(self._topId) then 
            G_MovingTip:showMovingTip(G_lang:get("LANG_AWAKEN_TAGS_MAX"))
            checkbox:setSelectedState(false)
            return
        end 
        G_HandlersManager.awakenShopHandler:sendAddShopTag(self._topId)
    else
        G_HandlersManager.awakenShopHandler:sendDelShopTag(self._topId)
    end 
end

function HeroAwakenItemComposeLayer:checkNum()

    local level = self._composeItems.levelCount()
    local count = self._composeItems.count(level) - 1
    -- print("checkNum level = " ..  tostring(level) .. " count = " .. tostring(count))
    for i=1, count do
        local subItem = self._composeItems.at(level, i+1)
        local subItemId = subItem.id
        local curNum = G_Me.bagData:getAwakenItemNumById(subItemId)
        local expectNum = subItem.num
        self._itemNums[i] = curNum
        dump(self._itemNums)
    end 
end 
-- 一键合成成功之后模拟假数据显示 然后播放特效
function HeroAwakenItemComposeLayer:doNotRealLabelAndAnimation(complete)
    local level = self._composeItems.levelCount()
    local count = self._composeItems.count(level) - 1
        -- 然后是合成所需道具
    -- print("level = " .. tostring(level))
    -- print("count = " .. tostring(count))
    for i=1, count do
        local subItem = self._composeItems.at(level, i+1)
        local subItemId = subItem.id
        -- 数量
        local curNum = G_Me.bagData:getAwakenItemNumById(subItemId)
        local expectNum = subItem.num
        -- print("count = " .. tostring(count))
        -- print("curNum = " .. tostring(curNum))
        -- print("expectNum = " .. tostring(expectNum))
        if complete then 
            if self._itemNums[i] < expectNum then 
                self:updateLabel("Label_branch_item_amount"..count..i, {text = curNum+expectNum.."/"..expectNum, color = Colors.darkColors.DESCRIPTION, stroke=Colors.strokeBrown, strokeSize=2})
                self:playSubComposeAnimation(subItemId,count,i)
            end 
        else 
            if self._itemNums[i] ~= curNum then 
                self:playSubComposeAnimation(subItemId,count,i)
            end 
        end 
        
    end 
end 
 -- 子合成动画
function HeroAwakenItemComposeLayer:playSubComposeAnimation(itemId,count,index)

    local effect 
    effect = EffectNode.new("effect_prepare_compose", function(event, frameIndex)
        if event == "finish" then
            self:removeChild(effect)
        end
    end)
    effect:play()
    -- local count = self._composeItems.count(1) - 1
    local x,y = self:getImageViewByName("Image_branch_item" .. tostring(count) .. tostring(index)):convertToWorldSpaceXY(0, 0)
    effect:setPosition(ccp(x,y))
    self:addChild(effect) 
end 

function HeroAwakenItemComposeLayer:playComposeAnimation(callback)
    
    local level = self._composeItems.levelCount()
    local count = self._composeItems.count(level) - 1
    
    self:getButtonByName("Button_compose"):setEnabled(false)
    self:getButtonByName("Button_compose_0"):setEnabled(false)
    self:getButtonByName("Button_get"):setEnabled(false)

    
    local panelTree = self:getPanelByName("Panel_compose_tree"..count)
    panelTree:removeAllNodes()
    
    for i=1, count do
        
        -- 首先看看这个道具由几层合成, 第一个节点的数据表示主合成道具
        local item = self._composeItems.at(level, i+1)
        local itemInfo = item_awaken_info.get(item.id)
        assert(itemInfo, "Could not find the awaken item with id: "..item.id)
        
        local node = display.newNode()
        panelTree:addNode(node, 100)
        
        node:setPosition(ccp(self:getImageViewByName("Image_branch_item"..count..i):getPosition()))

        local icon = display.newSprite(itemInfo.icon)
        node:addChild(icon)
        
        local actionArr = CCArray:create()
        actionArr:addObject(CCDelayTime:create((i-1) * 0.05))
        
        local imgMainItem = self:getImageViewByName("Image_main_item"..count)        
        actionArr:addObject(CCMoveTo:create(0.2, ccp(imgMainItem:getPosition())))

        actionArr:addObject(CCCallFunc:create(function()
            if i == 1 then

                local effect = EffectNode.new("effect_particle_star")
                panelTree:addNode(effect, 100)
                effect:setPosition(ccp(imgMainItem:getPosition()))
                effect:play()
                effect:setScale(0.5)

                local actionArr = CCArray:create()
                actionArr:addObject(CCDelayTime:create(0.7))
                actionArr:addObject(CCFadeOut:create(0.3))
                actionArr:addObject(CCRemoveSelf:create())
                actionArr:addObject(CCCallFunc:create(function()
                    if callback then
                        callback("finish")
                    end
                    self:getButtonByName("Button_compose"):setEnabled(true)
                    self:getButtonByName("Button_compose_0"):setEnabled(true)
                    self:getButtonByName("Button_get"):setEnabled(true)

                end))

                effect:runAction(CCSequence:create(actionArr))
            end
        end))
        
        actionArr:addObject(CCRemoveSelf:create())
        
        node:runAction(CCSequence:create(actionArr))
    end
    
end

function HeroAwakenItemComposeLayer:updateTheWay(level, withAnimation)

    level = level or self._composeItems.levelCount()
    
    -- 首先看看这个道具由几层合成, 第一个节点的数据表示主合成道具
    local item = self._composeItems.at(level, 1)
    self._topId = item.id
    local itemInfo = item_awaken_info.get(item.id)
    assert(itemInfo, "Could not find the awaken item with id: "..item.id)
    
    local wayInfo = way_type_info.get(G_Goods.TYPE_AWAKEN_ITEM, item.id)
    assert(wayInfo, "Could not find the way of item with type and id : "..G_Goods.TYPE_AWAKEN_ITEM..", "..item.id)
        
    local wayTypeInfos = {container = {}}
    wayTypeInfos.add = function(info)
        wayTypeInfos.container[#wayTypeInfos.container+1] = info
    end
    
    wayTypeInfos.count = function()
        return #wayTypeInfos.container
    end
    
    wayTypeInfos.at = function(index)
        return wayTypeInfos.container[index]
    end
    
    -- 最多15种渠道
    for i=1, 15 do
        local wayId = wayInfo["way_id"..i]
        if wayId ~= 0 then
            wayTypeInfos.add(wayId)
        end
    end

    -- 先隐藏所有的合成树
    self:updatePanel("Panel_compose_tree", {visible=false})
    self:updatePanel("Panel_compose_way", {visible=true})
    
    -- 清理所有动画
    for i=2, 4 do
        self:getPanelByName("Panel_compose_tree"..i):removeAllNodes()
    end
    
    if withAnimation or withAnimation == nil then
        local panel = self:getPanelByName("Panel_compose_way")
        panel:stopAllActions()
        panel:setOpacity(0)
        panel:runAction(CCFadeIn:create(0.15))
    end
    
    -- 更新主合成道具
    -- 品级框
    self:updateImageView("Image_way_item_frame", {texture=G_Path.getEquipColorImage(itemInfo.quality), texType=UI_TEX_TYPE_PLIST})
    -- 背景
    self:updateImageView("Image_way_item_bg", {texture=G_Path.getEquipIconBack(itemInfo.quality), texType=UI_TEX_TYPE_PLIST})
    -- icon
    self:updateImageView("Image_way_item_icon", {texture=itemInfo.icon})
    -- 名称
    self:updateLabel("Label_way_item_name", {text=itemInfo.name, color=Colors.qualityColors[itemInfo.quality], stroke=Colors.strokeBrown, strokeSize=2})
    -- 获得途径
    self:updateLabel("Label_way_desc", {text=G_lang:get("LANG_AWAKEN_ITEM_WAY_DESC")})
    
    self:updateLabel("Label_select_name", {text=itemInfo.name, color=Colors.qualityColors[itemInfo.quality], stroke=Colors.strokeBrown, strokeSize=2})
    self:updateLabel("Label_select_0", {text=G_lang:get("LANG_AWAKEN_TAGS_TEXT"),  stroke=Colors.strokeBrown, strokeSize=2})
    -- 然后是列表
    if not self._wayListView then
        
        -- 创建列表
        local panel = self:getPanelByName("Panel_way_list")
        
        local listview = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_VERTICAL)
        self._wayListView = listview

        -- 分别设置创建方法和更新方法
        self._wayListView:setCreateCellHandler(function(list, index)
            local cell = CCSItemCellBase:create("ui_layout/HeroAwakenWayItemCell.json")
            cell:setTouchEnabled(true)
            return cell
        end)
        
    end

    self._wayListView:setUpdateCellHandler(function(list, index, cell)
        
        local wayId = wayTypeInfos.at(index+1)
        local wayFunctionInfo = way_function_info.get(wayId)
        assert(wayFunctionInfo, "Could not find the way function info with id: "..tostring(wayId))

        cell._functionId = wayFunctionInfo.function_id
        cell._functionValue = wayFunctionInfo.function_value
        cell._chapterId = wayFunctionInfo.chapter_id
        
        -- icon
        self:updateImageView("Image_way_icon", {texture=G_Path.getWayIcon(wayFunctionInfo.icon)}, cell)
        -- 名称
        self:updateLabel("Label_way_name", {text=wayFunctionInfo.name, stroke=Colors.strokeBrown, strokeSize=2}, cell)
        -- 说明
        self:updateLabel("Label_way_desc", {text=wayFunctionInfo.directions}, cell)
        
        -- 是否开启
        local isOpen = self:isFunctionOpen(wayFunctionInfo.function_id, wayFunctionInfo.function_value, wayFunctionInfo.chapter_id)
        self:updateLabel("Label_way_lock", {visible=not isOpen, stroke=Colors.strokeBrown, strokeSize=2}, cell)
        self:updateButton("Button_way_togo", {visible=isOpen}, cell)

        local curCount = 0
        local maxCount = 0
        if cell._functionId == 1 then 
            curCount, maxCount = G_Me.dungeonData:getCurAndMaxChallengeTimes(cell._chapterId, cell._functionValue)
        elseif cell._functionId == 24 then
            curCount, maxCount = G_Me.hardDungeonData:getCurAndMaxChallengeTimes(cell._chapterId, cell._functionValue)
        end

        if curCount > 0 or maxCount > 0 then 
            cell:showTextWithLabel("Label_addition", G_lang:get("LANG_DUNGEON_LEFT_COUNTS", {count1=curCount, count2=maxCount}))
        else
            cell:showTextWithLabel("Label_addition", "")
        end
        
        -- 前往
        cell:registerBtnClickEvent("Button_way_togo", function()
            self:_doWayFunction(wayFunctionInfo)
        end)
        
        cell:registerCellClickEvent(function(...)
            self:_doWayFunction(wayFunctionInfo)
        end)
        
    end)

    self._wayListView:initChildWithDataLength(wayTypeInfos.count())
    
    -- 更新道具合成游标
    self:updateItemCursor()
    
    -- 先判断是否应该选中
    self:getCheckBoxByName("CheckBox_select_0"):setSelectedState(G_Me.shopData:isAwakenTags(self._topId))

    self:registerBtnClickEvent("Button_way_back", function()
        -- 移除当前顶层的数据
        self._composeItems.remove(level)
        self:updateComposeTree(level-1)
    end)
    
end

function HeroAwakenItemComposeLayer:isFunctionOpen( funId, funValue, chapterId )
    local flag = true 
    if funId == 1 then 
            if funValue > 0 then 
                    flag = not G_Me.dungeonData:isNeedRequestChapter()
                    flag = flag and G_Me.dungeonData:isOpenDungeon(chapterId, funValue)
            else
                    flag = true
            end
    elseif funId == 2 then
            if funValue > 0 then
                    flag = G_moduleUnlock:isModuleUnlock(FunctionLevelConst.STORY_DUNGEON)
                    flag = flag and G_Me.storyDungeonData:isOpenDungeon(funValue)
            end
    elseif funId == 4 then
            flag = G_moduleUnlock:isModuleUnlock(FunctionLevelConst.SECRET_SHOP)
    elseif funId == 5 then
            flag = G_moduleUnlock:isModuleUnlock(FunctionLevelConst.ARENA_SCENE)
    elseif funId == 6 then
            flag = G_moduleUnlock:isModuleUnlock(FunctionLevelConst.TOWER_SCENE)
    elseif funId == 7 then
            flag = G_moduleUnlock:isModuleUnlock(FunctionLevelConst.TREASURE_COMPOSE)
    elseif funId == 10 then 
            flag = G_moduleUnlock:isModuleUnlock(FunctionLevelConst.MOSHENG_SCENE)
    elseif funId == 13 then 
            flag = G_moduleUnlock:isModuleUnlock(FunctionLevelConst.VIP_SCENE)
            flag = flag and G_Me.userData.vip >= chapterId or false
    elseif funId == 17 or funId == 18 or funId == 19 or funId == 21 or funId == 22 then
            flag = G_moduleUnlock:isModuleUnlock(FunctionLevelConst.LEGION)
    elseif funId == 20 then
            flag = G_moduleUnlock:isModuleUnlock(FunctionLevelConst.CITY_PLUNDER)
    elseif funId == 24 then
            flag = G_moduleUnlock:isModuleUnlock(FunctionLevelConst.HARDDUNGEON)
            if funValue > 0 then 
                    flag = not G_Me.hardDungeonData:isNeedRequestChapter()
                    flag = flag and G_Me.hardDungeonData:isOpenDungeon(chapterId, funValue)
            else
                    flag = true
            end
    elseif funId == 25 then
            flag = G_moduleUnlock:isModuleUnlock(FunctionLevelConst.AWAKEN)
    elseif funId == 27 then
            flag = funValue == 1 and (G_Me.wheelData:getState() < 3) or (G_Me.richData:getState() < 3)
            if funValue == 3 then
                flag = G_moduleUnlock:isModuleUnlock(FunctionLevelConst.TRIGRAMS)
            end
    elseif funId == 29 then
        flag = G_moduleUnlock:isModuleUnlock(FunctionLevelConst.INVITOR) and  G_Setting:get("open_invitor") == "1"
    elseif funId == 30 then
        flag = G_moduleUnlock:isModuleUnlock(FunctionLevelConst.TREASURE_COMPOSE)
    elseif funId == 31 then
            flag = G_moduleUnlock:isModuleUnlock(FunctionLevelConst.CRUSADE)
    elseif funId == 32 then
        flag = G_moduleUnlock:isModuleUnlock(FunctionLevelConst.PET_SHOP)
    elseif funId == 33 then
            flag = G_moduleUnlock:isModuleUnlock(FunctionLevelConst.ITEM_COMPOSE)
    elseif funId == 34 then
            flag = G_moduleUnlock:isModuleUnlock(FunctionLevelConst.CROSS_PVP)
    end

    return flag
end

function HeroAwakenItemComposeLayer:_doWayFunction(wayInfo)

    --self._functionId = 3
    --self._functionValue = 6
    local moduleId = 0
    local functionId = wayInfo.function_id
    local chapter_id = wayInfo.chapter_id
    local function_value = wayInfo.function_value
    
    if functionId < 1 then 
        return 
    end
    
    local sceneName = nil
    if functionId == 1 then
        sceneName = "app.scenes.dungeon.DungeonMainScene"
    elseif functionId == 2 then
        sceneName = "app.scenes.storydungeon.StoryDungeonMainScene"
        moduleId = FunctionLevelConst.STORY_DUNGEON
    elseif functionId == 3 then
        sceneName = "app.scenes.shop.ShopScene"
    elseif functionId == 4 then
        sceneName = "app.scenes.secretshop.SecretShopScene"
        moduleId = FunctionLevelConst.SECRET_SHOP
    elseif functionId == 5 then
        sceneName = "app.scenes.shop.score.ShopScoreScene"
        chapter_id = 1
        moduleId = FunctionLevelConst.ARENA_SCENE
    elseif functionId == 6 then
        chapter_id = 4
        sceneName = "app.scenes.shop.score.ShopScoreScene"
        moduleId = FunctionLevelConst.TOWER_SCENE
    elseif functionId == 7 then
        sceneName = "app.scenes.treasure.TreasureComposeScene"
        moduleId = FunctionLevelConst.TREASURE_COMPOSE
    elseif functionId == 8 then
        sceneName = "app.scenes.shop.ShopScene"
    elseif functionId == 9 then
        sceneName = "app.scenes.shop.ShopScene"
    elseif functionId == 10 then
        --not open at present
        sceneName = "app.scenes.moshen.MoShenScene"
        moduleId = FunctionLevelConst.MOSHENG_SCENE
    elseif functionId == 11 then
        sceneName = "app.scenes.recycle.RecycleScene"
    elseif functionId == 12 then
        sceneName = "app.scenes.recycle.RecycleScene"
    elseif self._functionId == 13 then 
        sceneName = "app.scenes.vip.VipMapScene"
    elseif functionId == 14 then 
        sceneName = "app.scenes.arena.ArenaScene"
    elseif functionId == 15 then 
        sceneName = "app.scenes.wush.WushScene"
    elseif functionId == 16 then 
        chapter_id = 2
        sceneName = "app.scenes.shop.score.ShopScoreScene"
        moduleId = FunctionLevelConst.MOSHENG_SCENE
    elseif functionId == 17 then
        if G_Me.legionData:hasCorp() then
            sceneName = "app.scenes.legion.LegionScene"
        else
            sceneName = "app.scenes.legion.LegionListScene"    	
        end
    elseif functionId == 18 then
        if G_Me.legionData:hasCorp() then
            chapter_id = 6
            sceneName = "app.scenes.shop.score.ShopScoreScene"
        else
            sceneName = "app.scenes.legion.LegionListScene"    	
        end
    elseif functionId == 19 then
        if G_Me.legionData:hasCorp() and G_Me.legionData:getDungeonOpen() then
            sceneName = "app.scenes.legion.LegionNewDungeionScene"
        else
            sceneName = "app.scenes.legion.LegionListScene"    	
        end
    elseif functionId == 20 then
        sceneName = "app.scenes.city.CityScene" 	
    elseif functionId == 21 then
        if G_Me.legionData:hasCorp() then
            sceneName = "app.scenes.legion.LegionSacrificeScene"
        else
            sceneName = "app.scenes.legion.LegionListScene"    	
        end
    elseif functionId == 22 then
        if G_Me.legionData:hasCorp() then
            sceneName = "app.scenes.legion.LegionHallScene"
        else
            sceneName = "app.scenes.legion.LegionListScene"    	
        end
    elseif functionId == 23 then
        sceneName = "app.scenes.wheel.WheelScene"
    elseif functionId == 24 then
        sceneName = "app.scenes.harddungeon.HardDungeonMainScene"
        moduleId = FunctionLevelConst.HARDDUNGEON
    elseif functionId == 25 then
        sceneName = "app.scenes.awakenshop.AwakenShopScene"
        moduleId = FunctionLevelConst.AWAKEN
    elseif self._functionId == 26 then
        sceneName = "app.scenes.bag.BagScene"
        moduleId = FunctionLevelConst.AWAKEN
        self._functionValue = 2
    elseif self._functionId == 27 then
        moduleId = 0
        if self._functionValue == 1 then
            sceneName = "app.scenes.wheel.WheelScene"
        elseif self._functionValue == 2 then
            sceneName = "app.scenes.dafuweng.RichScene"
        elseif self._functionValue == 3 then
            moduleId = FunctionLevelConst.TRIGRAMS
            sceneName = "app.scenes.shop.score.ShopScoreScene"
            self._chapterId = SCORE_TYPE.TRIGRAMS
        end 
    elseif self._functionId == 28 then
        moduleId = FunctionLevelConst.CROSS_WAR
        self._chapterId = 8
        sceneName = "app.scenes.shop.score.ShopScoreScene"
    elseif self._functionId == 29 then
        moduleId = FunctionLevelConst.INVITOR
        self._functionValue = G_Me.activityData:getInvitorIndex()
        sceneName = "app.scenes.activity.ActivityMainScene"
    elseif self._functionId == 30 then
        sceneName = "app.scenes.treasure.TreasureComposeScene"
        moduleId = FunctionLevelConst.TREASURE_SMELT
    elseif self._functionId == 31 then
        sceneName = "app.scenes.crusade.CrusadeScene"
        moduleId = FunctionLevelConst.CRUSADE
    elseif self._functionId == 32 then
        sceneName = "app.scenes.pet.shop.PetShopScene"
        moduleId = FunctionLevelConst.PET_SHOP
    elseif self._functionId == 33 then
        sceneName = "app.scenes.bag.itemcompose.ItemComposeScene"
        moduleId = FunctionLevelConst.ITEM_COMPOSE
    elseif self._functionId == 34 then
        sceneName = "app.scenes.crosspvp.CrossPVPScene"
        moduleId = FunctionLevelConst.CROSS_PVP
    end

    __Log("function_id:%d, function_value:%d, chapterId:%d", functionId, function_value, chapter_id)
    if moduleId > 0 and not G_moduleUnlock:checkModuleUnlockStatus(moduleId) then 
        return 
    end

    if moduleId == FunctionLevelConst.TRIGRAMS and G_Me.trigramsData:isClose() then
        G_MovingTip:showMovingTip(G_lang:get("LANG_BAG_ITEM_IS_OVER"))
        return
    end

    self:startGuideIfNeed(functionId, function_value, chapter_id)

    if sceneName then
        if functionId == 1 or functionId == 24 then 
            uf_sceneManager:popToRootAndReplaceScene(require(sceneName).new(nil, nil, function_value, chapter_id, self._scenePack))
        --elseif self._functionId == 3 or self._functionId == 8 or self._functionId == 9 then 

        --elseif self._functionId == 2 then 
        --	uf_sceneManager:popToRootAndReplaceScene(require(sceneName).new())
        elseif self._functionId == 29 then 
            uf_sceneManager:popToRootAndReplaceScene(require(sceneName).new(self._functionValue))
        else
            uf_sceneManager:popToRootAndReplaceScene(require(sceneName).new(nil, nil, nil, nil, self._scenePack))
        end
    elseif self._functionId == 35 then
        -- 运营活动
         G_MovingTip:showMovingTip(G_lang:get("LANG_ACQUIRE_ATTENTION"))
    end
end

function HeroAwakenItemComposeLayer:updateItemCursor()
    
    -- 当前层级
    local level = self._composeItems.levelCount()
    
    local scrollView = self:getScrollViewByName("ScrollView_cursor")
    -- 先前的层级
    local prelevelCount = math.ceil(scrollView:getChildrenCount() / 2)
    
    scrollView:removeAllChildren()
    
    local totalWidth = 0
    local padding = 12
    
    -- 这里遍历要算上箭头的数量，而不仅仅是几层的数量
    for i=1, level+level-1 do
        -- 逢单是框，双是箭头
        local cell = nil
        if i % 2 == 1 then
            cell = CCSItemCellBase:create("ui_layout/HeroAwakenItemComposeCursorLayer.json")
        else
            cell = CCSItemCellBase:create("ui_layout/HeroAwakenItemComposeCursorArrowLayer.json")
        end
        
        cell:setPositionX(totalWidth + padding)
        scrollView:addChild(cell)
        totalWidth = totalWidth + cell:getSize().width
        
        -- 取框更新
        if i % 2 == 1 then
            
            local index = math.ceil(i/2)
            
            -- 更新cell
            self:updateImageView("Image_cursor_frame", {visible=(index==level)}, cell)
            
            -- 必须是最顶层（新加层）且不是回退的那种才做动画
            if index == level and level > prelevelCount then
                local imgEquipment = cell:getImageViewByName("Image_equipment")
                imgEquipment:setOpacity(0)
                imgEquipment:runAction(CCFadeIn:create(0.1))
            end
            
            local subItemId = self._composeItems.at(index, 1).id
            local subItemInfo = item_awaken_info.get(subItemId)
            assert(subItemInfo, "Could not find the awaken item with id: "..subItemId)
            
            -- 品级框
            self:updateImageView("Image_equipment_frame", {texture=G_Path.getEquipColorImage(subItemInfo.quality), texType=UI_TEX_TYPE_PLIST}, cell)
            -- 背景
            self:updateImageView("Image_equipment_bg", {texture=G_Path.getEquipIconBack(subItemInfo.quality), texType=UI_TEX_TYPE_PLIST}, cell)
            -- icon
            self:updateImageView("Image_equipment_icon", {texture=subItemInfo.icon}, cell)
            
            cell:registerWidgetClickEvent("Image_equipment", function()
                
                if self._lock then return end
                
                if index < level then
                    -- 清除不用的数据
                    for j=level, index+1, -1 do
                        self._composeItems.remove(j)
                    end
                    self:updateComposeTree(index)
                end
            end)
            
        end
        
    end
    
    totalWidth = totalWidth + padding
    
    local size = scrollView:getContentSize()
    scrollView:setInnerContainerSize(CCSizeMake(totalWidth, size.height))
    
    -- 超过5层就位置就摆出去了，所以这里设置一下如果超过5层则直接按照最右对齐
    if level >= 5 then
        scrollView:jumpToRight()
    end
    
end

function HeroAwakenItemComposeLayer:updateLabel(name, params, target)
    
    target = target or self
    
    local label = target:getLabelByName(name)
    assert(label, "Could not find the label with name: "..name)
    
    if params.stroke ~= nil and label.createStroke then
        label:createStroke(params.stroke, params.strokeSize or 1)
    end
    
    if params.color ~= nil and label.setColor then
        label:setColor(params.color)
    end
    
    if params.text ~= nil and label.setText then
        label:setText(params.text)
    end
    
    if params.visible ~= nil and label.setVisible then
        label:setVisible(params.visible)
    end

end

function HeroAwakenItemComposeLayer:updateImageView(name, params, target)
    
    target = target or self
    
    local img = target:getImageViewByName(name)
    assert(img, "Could not find the image with name: "..name)
    
    if params.texture ~= nil and img.loadTexture then
        img:loadTexture(params.texture, params.texType or UI_TEX_TYPE_LOCAL)
    end
    
    if params.visible ~= nil and img.setVisible then
        img:setVisible(params.visible)
    end
    
end

function HeroAwakenItemComposeLayer:updateButton(name, params, target)
    
    target = target or self
    
    local btn = target:getButtonByName(name)
    assert(btn, "Could not find the button with name: "..name)
    
    if params.visible ~= nil and btn.setVisible then
        btn:setVisible(params.visible)
    end
    
end

function HeroAwakenItemComposeLayer:updatePanel(name, params, target)
    
    target = target or self
    
    local panel = target:getPanelByName(name)
    assert(panel, "Could not find the panel with name: "..name)
    
    if params.visible ~= nil and panel.setVisible then
        panel:setVisible(params.visible)
    end
    
end

function HeroAwakenItemComposeLayer:lock() self._lock = true end
function HeroAwakenItemComposeLayer:unlock() self._lock = false end

function HeroAwakenItemComposeLayer:startGuideIfNeed( funId, funValue, chapterId )
    if (funId == 1 and funValue > 0) or funId == 3 or funId == 8 or funId == 9 or funId == 24 then 
        local acquireGuide = require("app.scenes.common.acquireInfo.AcquireInfoGuide")
        if funId == 1 and G_moduleUnlock:isModuleUnlock(FunctionLevelConst.DUNGEON_SAODANG) then
            -- local statgeData = G_Me.dungeonData:getStageData(chapterId, funValue)
            -- if statgeData and statgeData._star == 3 then
            --     funId = 20
            -- end
            if G_Me.dungeonData:isOnSweepStatus(chapterId, funValue) then 
                funId = 20
            end
        end

        if funId == 24 and G_moduleUnlock:isModuleUnlock(FunctionLevelConst.HARDDUNGEON) then 
            -- local statgeData = G_Me.hardDungeonData:getStageData(chapterId, funValue)
            -- if statgeData and statgeData._star == 3 then
            --     funId = 30
            -- end
            if G_Me.hardDungeonData:isOnSweepStatus(chapterId, funValue) then 
                funId = 30
            end
        end

        local ret = acquireGuide.runGuide(funId, chapterId, funValue)
    end
end

return HeroAwakenItemComposeLayer
