-- RecycleKnightMainLayer

local function _updateLabel(target, name, text, stroke, color)
    
    local label = target:getLabelByName(name)
    assert(label ~= nil, "label is nil")
    if stroke then
        label:createStroke(stroke, 1)
    end
    if color then
        label:setColor(color)
    end
    
    label:setText(text)
end

local function _updateImageView(target, name, texture, texType)
    
    local img = target:getImageViewByName(name)
    assert(img ~= nil, "img is nil")
    img:loadTexture(texture, texType)
    
end

require "app.cfg.knight_info"

local EffectNode = require "app.common.effects.EffectNode"

local RecycleKnightMainLayer = class("RecycleKnightMainLayer", UFCCSNormalLayer)

function RecycleKnightMainLayer.create(...)
    return RecycleKnightMainLayer.new("ui_layout/recycle_knightMainLayer.json", ...)
end

function RecycleKnightMainLayer:ctor(...)
    
    RecycleKnightMainLayer.super.ctor(self, ...)
        
    -- 绑定归隐按钮
    self:registerBtnClickEvent("Button_recycle", function()
        self:onRecycleButtonClicked()       
    end)
    
    -- 绑定自动添加
    self:registerBtnClickEvent("Button_auto_add", function()
        self:onAutoAddButtonClicked()       
    end)
    
    -- 特效
    local EffectNode = require "app.common.effects.EffectNode"
    local effect = EffectNode.new("effect_wujiangfengjie")
    local parent = self:getPanelByName("Panel_effect")
    parent:addNode(effect)

    self._shineNode = effect
    
    local backEffect = nil
    
    if require("app.scenes.mainscene.SettingLayer").showEffectEnable() then

        -- 背景特效
        backEffect = EffectNode.new("effect_jinjiechangjing")
        parent = self:getImageViewByName("ImageView_8508")
        parent:addNode(backEffect)
        backEffect:setScale(0.5)
        backEffect:setPosition(ccp(0, -38))
        
    end
    
    self._effectNode = {}
    self._effectNode.play = function()
        effect:play()
        if backEffect then
            backEffect:play()
        end
    end
    
    self:getLabelByName("Label_knight_tip"):setText(G_lang:get("LANG_RECYCLE_KNIGHT_TIPS"))
    self:enableLabelStroke("Label_knight_tip", Colors.strokeBrown, 1 )
    
    self:registerBtnClickEvent("Button_help", function()
        self:onHelpButtonClicked()
    end)
    
end

function RecycleKnightMainLayer:onRecycleButtonClicked()
    if self._locked then return end
        
    -- 如果没有可归隐的武将则直接提示
    if table.nums(self._knights) == 0 then
        G_MovingTip:showMovingTip(G_lang:get("LANG_RECYCLE_SELECT_KNIGHT_EMPTY"))
        return
    end
    
    -- 未选中则提示
    if table.nums(self._selectKnights) == 0 then
        G_MovingTip:showMovingTip(G_lang:get("LANG_RECYCLE_KNIGHT_EMPTY"))
        return
    end
    
    local knights = {knight_id = {}, type=2}
    for k, knight in pairs(self._selectKnights) do
        knights.knight_id[#knights.knight_id+1] = knight.id
    end
    G_HandlersManager.recycleHandler:sendRecycleKnight(knights)
end

function RecycleKnightMainLayer:onAutoAddButtonClicked(  )
    if self._locked then return end
        
    local btn = self:getButtonByName("Button_auto_add")
    btn:removeAllNodes()
    
    -- 单位已满
    if table.nums(self._selectKnights) >= 5 then
        G_MovingTip:showMovingTip(G_lang:get("LANG_RECYCLE_KNIGHT_FULL"))
        return
    end
    
    -- 已无剩余
    if table.nums(self._selectKnights) == table.nums(self._knights) then
        G_MovingTip:showMovingTip(G_lang:get("LANG_RECYCLE_KNIGHT_NO_REMAIN"))
        return
    end
    
    -- 除橙色级别以外已无剩余
    local _knightList = {}
    for i=1, #self._knights do
        local knight = self._knights[i]
        local knightConfig = knight_info.get(knight.base_id)
        assert(knightConfig, "Could not find the knight info with id: "..knight.base_id)
        
        if knightConfig.potential < 20 then
           _knightList[#_knightList+1] = knight 
        end
    end
    
    if #_knightList == 0 then
        G_MovingTip:showMovingTip(G_lang:get("LANG_RECYCLE_KNIGHT_QUALITY_NO_REMAIN"))
        return
    end
    
    -- 如果没有可归隐的武将则直接提示
    if table.nums(self._knights) == 0 then
        G_MovingTip:showMovingTip(G_lang:get("LANG_RECYCLE_SELECT_KNIGHT_EMPTY"))
        return
    end
    
    local index = 1
    local myLevel = G_Me.userData.level
    while table.nums(self._selectKnights) < 5 and self._knights[index] do
        
        local knight = self._knights[index]
        local knightConfig = knight_info.get(knight.base_id)
        assert(knightConfig, "Could not find the knight info with id: "..knight.base_id)
        
        if not self._selectKnights[index] and knightConfig.potential < 20 then
            -- 【2.1.0优化】20级以前“自动添加”只添加绿、蓝将，20级可以默认添加紫将（已经上阵4个将）
            if myLevel < 20 or G_Me.formationData:getFormationHeroCount() < 4 then
                if knightConfig.quality < 4 then 
                    self._selectKnights[index] = self._knights[index]    
                end
            else
                self._selectKnights[index] = self._knights[index]
            end
        end
        index = index + 1
    end

    -- 如果等级小于20或者上阵不足4个武将，自动添加时没有绿、蓝将则弹个提示
    if (myLevel < 20 or G_Me.formationData:getFormationHeroCount() < 4) and table.nums(self._selectKnights) == 0 then
        G_MovingTip:showMovingTip(G_lang:get("LANG_RECYCLE_KNIGHT_NO_REMAIN"))
        return
    end

    self:initSelectState()
end

function RecycleKnightMainLayer:onHelpButtonClicked(  )
--        local layer = require("app.scenes.recycle.RecycleHelpLayer").create(G_lang:get("LANG_RECYCLE_KNIGHT_TITLE"), G_lang:get("LANG_RECYCLE_KNIGHT_HELP_DESC"))
--        uf_sceneManager:getCurScene():addChild(layer)

    require("app.scenes.common.CommonHelpLayer").show({
        {title=G_lang:get("LANG_RECYCLE_KNIGHT_TITLE"), content=G_lang:get("LANG_RECYCLE_KNIGHT_HELP_DESC")}
    } )
end

function RecycleKnightMainLayer:onLayerEnter()
    
    -- 每次加载都初始化新表，不保存上一次的选择结果
    self:resetSelectState()
    
    -- 播放特效
    if self._effectNode then
        self._effectNode:play()
    end
    
    -- 如果有可回收的武将则显示流光特效
    local btn = self:getButtonByName("Button_auto_add")
    btn:removeAllNodes()
    
    if G_Me.bagData:hasKnightToRecycle() then
        local node = EffectNode.new("effect_around2")
        node:setScaleX(1.5)
        node:setScaleY(1.6)
        node:setPosition(ccp(-2, -2))
        node:play()
        btn:addNode(node)
    end
    
    local btn = self:getButtonByName("Button_help")
    local label = self:getLabelByName("Label_knight_tip")
    btn:setPositionXY(label:getPositionX() + label:getSize().width/2 + btn:getSize().width/2 - 10, label:getPositionY())
    
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_RECYCLE_PREVIEW, self._onRecycleKnightEvent, self)
    
end

function RecycleKnightMainLayer:onLayerExit()
    
    uf_eventManager:removeListenerWithTarget(self)
    
end

function RecycleKnightMainLayer:_initSelecteds()
    
    -- 先获取全部的武将，挑选符合要求的武将
    self._knights = {}
    local knightList = G_Me.bagData.knightsData:getKnightsList()
    require "app.cfg.knight_info"
    
    for key, knight in pairs(knightList) do
        -- 武将资质>=12且未上阵
        if knight_info.get(knight.base_id).potential >= 12 and
            G_Me.formationData:getKnightTeamId(knight.id) == 0 then
            knight.potential = knight_info.get(knight.base_id).potential
            self._knights[#self._knights+1] = knight
        end
    end

    -- 排序，按照资质从小到大排序，资质一致则根据等级从大到小排序，等级一致则根据ID从小到大排序
    table.sort(self._knights, function(a, b)
        return a.potential < b.potential or (a.potential == b.potential and (a.level > b.level or (a.level == b.level and a.base_id < b.base_id)))
    end)
    
end

function RecycleKnightMainLayer:initSelectState(selectKnights, anima)
    
    self._selectKnights = selectKnights or self._selectKnights
    
    anima = anima == nil and true or anima
    
    -- 更新knight
    if self._selectKnights then

        require "app.cfg.knight_info"
        
        local count = 1
        for index, knight in pairs(self._selectKnights) do

            -- knight的配置文件
            local knightConfig = knight_info.get(knight.base_id)

            -- 隐藏按钮
            self:getButtonByName("Button_selected"..count):setVisible(false)

            -- 显示图像
            local img = self:getImageViewByName("ImageView_selected"..count)
            img:setVisible(true)
            
            -- 要做动画
            if anima then
                local positionOffsetY = -50
                img:setPositionY(img:getPositionY() + positionOffsetY * -1)
                local moveAction = CCEaseIn:create(CCMoveBy:create(0.2, ccp(0, positionOffsetY)), 0.2)
                img:runAction(moveAction)
            end
            
            -- 校准位置
            local config = decodeJsonFile(G_Path.getKnightPicConfig(knightConfig.res_id))
            img:loadTexture(G_Path.getKnightPic(knightConfig.res_id))
            img:setAnchorPoint(ccp((img:getSize().width/2 - tonumber(config.x)) / img:getSize().width, (img:getSize().height/2 - tonumber(config.y)) / img:getSize().height))
            
            img:removeAllNodes()
            
            -- 阴影
            local shadow = CCSprite:create(G_Path.getKnightShadow())
            local anchorPoint = img:getAnchorPoint()
            shadow:setPosition(ccp(tonumber(config.shadow_x - config.x) - img:getSize().width * (anchorPoint.x - 0.5),  tonumber(config.shadow_y - config.y) - img:getSize().height * (anchorPoint.y - 0.5)))
            img:addNode(shadow, -3)
            
            -- 星级
--            self:getPanelByName("Panel_stars"..count):setVisible(true)
--            for i=1, 6 do
--                self:getImageViewByName("ImageView_star_dark"..count.."_"..i):setVisible(i > knightConfig.star)
--            end

            self:getPanelByName("Panel_label"..count):setVisible(true)

            -- 名称
            local name = self:getLabelByName("Label_name"..count)
            name:setColor(Colors.qualityColors[knightConfig.quality])
            name:createStroke(Colors.strokeBlack,1)
            name:setText(knightConfig.name)

            -- 级别, 大于0则显示，否则不显示
            if knightConfig.advanced_level > 0 then
                local grade = self:getLabelByName("Label_grade"..count)
                grade:setColor(Colors.qualityColors[knightConfig.quality])
                grade:createStroke(Colors.strokeBlack,1)
                grade:setText('+'..knightConfig.advanced_level)
                grade:setVisible(true)
                
                -- 因为grade和name的父类是同一个，所以这里直接设置位置偏移即可，注意这里grade的锚点是(0, 0.5)
                grade:setPositionX(name:getPositionX() + name:getSize().width/2)
                
            else
                self:getLabelByName("Label_grade"..count):setVisible(false)
            end
            
            -- 取消按钮
            -- 调整取消按钮的位置
            local btnCancel = self:getButtonByName("Button_cancel"..count)
            btnCancel:setVisible(true)
            btnCancel:setPosition(ccp(-120, 400))
            
            self:registerBtnClickEvent("Button_cancel"..count, function()
                self._selectKnights[index] = nil
                self:initSelectState(self._selectKnights, false)
            end)
            
            count = count + 1

        end

        -- 其余全部恢复显示按钮
        for i=count, 5 do
            self:getButtonByName("Button_selected"..i):setVisible(true)
            self:getImageViewByName("ImageView_selected"..i):setVisible(false)
--            self:getPanelByName("Panel_stars"..i):setVisible(false)
            self:getPanelByName("Panel_label"..i):setVisible(false)
        end
    end
    
end

function RecycleKnightMainLayer:_onRecycleKnightEvent(message)
    
    -- dump(message)

    local item = rawget(message, "item") or {}
    local knights = rawget(message, "knight_food") or {}
    local essence = rawget(message, "essence")
    local money = rawget(message, "money")
    local soul = rawget(message, "soul")
    
    local _knights = {}
    local count = 0
    for i=1, #knights do
        local bMatch = false
        for j=1, #_knights do
            if _knights[j].id == knights[i] then
                bMatch = true
                _knights[j].size = _knights[j].size + 1
                count = count + 1
                break
            end
        end
        if not bMatch then
            _knights[#_knights+1] = {id=knights[i], size=1}
            count = count + 1
        end
    end
    
    knights = _knights
    knights.count = count
    
    local hasAdvanceKnight = function()
        for k, knight in pairs(self._selectKnights) do
            local knightConfig = knight_info.get(knight.base_id)
            assert(knightConfig, "Could not find the knight config with id: "..knight.base_id)
            -- 紫色（4）及以上算高品质
            if knightConfig.quality >= 4 then
                return true
            end
        end
        return false
    end
    
    local hasSameKnightContain = function()
        for i=2, 6 do
            local _, baseId = G_Me.formationData:getTeamKnightIdAndBaseIdByIndex(1, i)
            if baseId ~= 0 then -- 0表示这个位置上没有人
                local baseKnightConfig = knight_info.get(baseId)
                assert(baseKnightConfig, "Could not find the knight config with id: "..tostring(baseId))

                for k, knight in pairs(self._selectKnights) do
                    local knightConfig = knight_info.get(knight.base_id)
                    assert(knightConfig, "Could not find the knight config with id: "..tostring(knight.base_id))
                    if knightConfig.advance_code == baseKnightConfig.advance_code then
                        return true
                    end
                end
            end
        end
        return false
    end
    
    -- 预览弹框
    local RecyclePreviewLayer = require("app.scenes.recycle.RecyclePreviewLayer")
    local layer = RecyclePreviewLayer.create(RecyclePreviewLayer.LAYOUT_KNIGHT, {
        -- "武将分解后将会获得以下物品"
        {"Label_result_desc", {text=G_lang:get("LANG_RECYCLE_KNIGHT_PREVIEW_DESC")}},
        -- 高品质或同名武将提示
        {"Label_tips", {visible=hasAdvanceKnight() or hasSameKnightContain(), text=hasSameKnightContain() and G_lang:get("LANG_RECYCLE_KNIGHT_ADVANCE_CODE_TIPS") or G_lang:get("LANG_RECYCLE_KNIGHT_ADVANCE_TIPS")}}
    })
    uf_sceneManager:getCurScene():addChild(layer)
    
    layer:registerBtnClickEvent("Button_ok", function()
        -- transfer the callback fun to parent layer before layer will dismiss
        self.__EFFECT_FINISH_CALLBACK__ = layer.__EFFECT_FINISH_CALLBACK__
        
        if knights.count > 0 then
            local CheckFunc = require("app.scenes.common.CheckFunc")
            if CheckFunc.checkDiffByType(G_Goods.TYPE_KNIGHT, knights.count) then
                return
            end
        end

        local knights = {knight_id = {}, type=0}
        for k, knight in pairs(self._selectKnights) do
            knights.knight_id[#knights.knight_id+1] = knight.id
        end
        G_HandlersManager.recycleHandler:sendRecycleKnight(knights)
        
        layer:animationToClose()
        
    end)

    -- 更新数据
    -- 先把数据打包封装
    
    local datas = {container = {}}
    
    datas.add = function(data)
        datas.container[#datas.container+1] = data
    end
    
    datas.get = function()
        return clone(datas.container)
    end
    
    datas.count = function()
        return #datas.container
    end
    
    -- 更新返还卡牌角色
    for i=1, #knights do
        local knightConfig = knight_info.get(knights[i].id)

        datas.add{
            {"ImageView_item", {visible=true}},
            {"ImageView_frame", {texture=G_Path.getEquipColorImage(knightConfig.quality,G_Goods.TYPE_KNIGHT)}},
            {"ImageView_head", {texture=G_Path.getKnightIcon(knightConfig.res_id), texType=UI_TEX_TYPE_LOCAL}},
            {"ImageView_bg", {visible=false}},
            {"Label_name", {text=knightConfig.name, stroke=Colors.strokeBlack, color=Colors.qualityColors[knightConfig.quality]}},
            {"Label_amount", {text="x"..knights[i].size, stroke=Colors.strokeBlack}},
        }
    end

    -- 更新道具
    for i=1, #item do
        local goodConfig = G_Goods.convert(item[i].type, item[i].value)

        datas.add{
            {"ImageView_item", {visible=true}},
            {"ImageView_frame", {texture=G_Path.getEquipColorImage(goodConfig.quality,goodConfig.type)}},
            {"ImageView_head", {texture=goodConfig.icon, texType=UI_TEX_TYPE_LOCAL}},
            {"ImageView_bg", {visible=true, texture=G_Path.getEquipIconBack(goodConfig.quality)}},
            {"Label_name", {text=goodConfig.name, stroke=Colors.strokeBlack, color=Colors.qualityColors[goodConfig.quality]}},
            {"Label_amount", {text="x"..item[i].num, stroke=Colors.strokeBlack}},
        }
    end

    -- 精魄
    if essence then
        local goodConfig = G_Goods.convert(13)    --  13表示武魂（精魄）

        datas.add{
            {"ImageView_item", {visible=true}},
            {"ImageView_frame", {texture=G_Path.getEquipColorImage(goodConfig.quality,goodConfig.type)}},
            {"ImageView_head", {texture=goodConfig.icon, texType=UI_TEX_TYPE_LOCAL}},
            {"ImageView_bg", {visible=true, texture=G_Path.getEquipIconBack(goodConfig.quality)}},
            {"Label_name", {text=goodConfig.name, stroke=Colors.strokeBlack, color=Colors.qualityColors[goodConfig.quality]}},
            {"Label_amount", {text='x'..essence, stroke=Colors.strokeBlack}},
        }
    end

    -- 银两
    if money then
        local goodConfig = G_Goods.convert(1)    -- 1表示银两

        datas.add{
            {"ImageView_item", {visible=true}},
            {"ImageView_frame", {texture=G_Path.getEquipColorImage(goodConfig.quality,goodConfig.type)}},
            {"ImageView_head", {texture=goodConfig.icon, texType=UI_TEX_TYPE_LOCAL}},
            {"ImageView_bg", {visible=true, texture=G_Path.getEquipIconBack(goodConfig.quality)}},
            {"Label_name", {text=goodConfig.name, stroke=Colors.strokeBlack, color=Colors.qualityColors[goodConfig.quality]}},
            {"Label_amount", {text='x'..G_GlobalFunc.ConvertNumToCharacter(money), stroke=Colors.strokeBlack}},
        }
    end

    -- 神魂
    if soul then
        local goodConfig = G_Goods.convert(G_Goods.TYPE_SHENHUN)

        datas.add{
            {"ImageView_item", {visible=true}},
            {"ImageView_frame", {texture=G_Path.getEquipColorImage(goodConfig.quality,goodConfig.type)}},
            {"ImageView_head", {texture=goodConfig.icon, texType=UI_TEX_TYPE_LOCAL}},
            {"ImageView_bg", {visible=true, texture=G_Path.getEquipIconBack(goodConfig.quality)}},
            {"Label_name", {text=goodConfig.name, stroke=Colors.strokeBlack, color=Colors.qualityColors[goodConfig.quality]}},
            {"Label_amount", {text='x'..soul, stroke=Colors.strokeBlack}},
        }
    end

    -- 红色武将额外返还物品
    local extraItem = rawget(message, "award")
    if extraItem then
        local awardsExtra = message.award
        -- 返回的红色武将精华数量需要特殊处理，蛋疼
        local hongsewujiangjinghuaNum = 0
        for i=1, #awardsExtra do

            if awardsExtra[i].type == 3 and awardsExtra[i].value == 3 then
                -- 红色武将精华
                hongsewujiangjinghuaNum = hongsewujiangjinghuaNum + awardsExtra[i].size
            else
                local goodConfig = G_Goods.convert(awardsExtra[i].type, awardsExtra[i].value)
                datas.add{
                    {"ImageView_item", {visible=true}},
                    {"ImageView_frame", {texture=G_Path.getEquipColorImage(goodConfig.quality, goodConfig.type)}},
                    {"ImageView_head", {texture=goodConfig.icon, texType=UI_TEX_TYPE_LOCAL}},
                    {"ImageView_bg", {visible=true, texture=G_Path.getEquipIconBack(goodConfig.quality)}},
                    {"Label_name", {text=goodConfig.name, stroke=Colors.strokeBlack, color=Colors.qualityColors[goodConfig.quality]}},
                    {"Label_amount", {text='x'..awardsExtra[i].size, stroke=Colors.strokeBlack}},
                }
            end
        end

        if hongsewujiangjinghuaNum > 0 then
            local goodConfig = G_Goods.convert(3, 3)
            datas.add{
                {"ImageView_item", {visible=true}},
                {"ImageView_frame", {texture=G_Path.getEquipColorImage(goodConfig.quality, goodConfig.type)}},
                {"ImageView_head", {texture=goodConfig.icon, texType=UI_TEX_TYPE_LOCAL}},
                {"ImageView_bg", {visible=true, texture=G_Path.getEquipIconBack(goodConfig.quality)}},
                {"Label_name", {text=goodConfig.name, stroke=Colors.strokeBlack, color=Colors.qualityColors[goodConfig.quality]}},
                {"Label_amount", {text='x'..hongsewujiangjinghuaNum, stroke=Colors.strokeBlack}},
            }
        end
    end

    layer:updateListView("Panel_list", datas.get())
    
end

function RecycleKnightMainLayer:playRecycleAnimation()
    
    -- 这里为了保存原始的位置及缩放比等参数，采用闭包的方法
    
    -- 先记录原始的参数，方便重置
    local originalScales = {}
    local originalOpacitys = {}
    local originalPositions = {}
    
    -- 归隐动画，5表示最多显示5个
    for i=1, 5 do
        local img = self:getImageViewByName("ImageView_selected"..i)
        if img then
            originalScales[i] = img:getScale()
            originalOpacitys[i] = img:getOpacity()
            originalPositions[i] = ccp(img:getPosition())
        end
    end
    
    local effectNode = nil
    
    -- 返回一个控制函数
    return function(command, callback)
        
        command = command or "play"
        
        if command == "play" then
                                    
            -- 人物动画播放时长
            local durationFrame = 15
            
            local array = CCArray:create()
            
            -- 先是人物动画
            array:addObject(CCCallFunc:create(function()
                
                local shine = self._shineNode
                local dstPosition = shine:convertToWorldSpace(ccp(0, 50))

                -- 归隐动画，5表示最多显示5个
                for i=1, 5 do
                    local img = self:getImageViewByName("ImageView_selected"..i)
                    if img:isVisible() then -- 表示其有选中

                        -- 隐藏名称
                        self:getPanelByName("Panel_label"..i):setVisible(false)
                        -- 隐藏取消按钮
                        self:getButtonByName("Button_cancel"..i):setVisible(false)

                        local array = CCArray:create()
            --                array:addObject(CCFadeOut:create(durationFrame/30))
                        array:addObject(CCScaleTo:create(durationFrame/30, 0.2))

                        local dstPosition1 = img:getParent():convertToNodeSpace(dstPosition)
            --                array:addObject(CCMoveTo:create(durationFrame/30, dstPosition1))
                        array:addObject(CCJumpTo:create(durationFrame/30, dstPosition1, 80, 1))

                        img:runAction(CCSequence:createWithTwoActions(CCSpawn:create(array), CCCallFunc:create(function()
                            img:setScale(originalScales[i])
                            img:setOpacity(originalOpacitys[i])
                            img:setPosition(originalPositions[i])
                            img:setVisible(false)
                        end)))
                    end
                end
            end))
            
            -- 延迟
            array:addObject(CCDelayTime:create(durationFrame/30))
            
            -- 然后是特效
            array:addObject(CCCallFunc:create(function()
                
                -- 直接把事件通过回调往外抛
                effectNode = require("app.common.effects.EffectNode").new("effect_wujiangfengjie_2", callback)
                self:getPanelByName("Panel_effect"):addNode(effectNode)
                effectNode:play()
        --        effectNode:setPosition(ccp(display.cx, display.cy))
            end))
            
            self:runAction(CCSequence:create(array))
                        
        elseif command == "reset" then
            
            for i=1, 5 do
                local img = self:getImageViewByName("ImageView_selected"..i)
                if img then
                    img:setScale(originalScales[i])
                    img:setOpacity(originalOpacitys[i])
                    img:setPosition(originalPositions[i])
                    img:setVisible(false)
                end
            end
            
            self:stopAllActions()
            
            if effectNode then
                effectNode:removeFromParent()
                effectNode = nil
            end
            
            if callback then
                callback(command)
            end
            
        end
        
    end

end

function RecycleKnightMainLayer:resetSelectState()
    
    -- 更新当前的界面状态
    self:initSelectState{}   -- 初始化空表
    
    -- 更新当前可选武将
    self:_initSelecteds()
    
end

function RecycleKnightMainLayer:getAvailableSelecteds()
    return self._knights
end

function RecycleKnightMainLayer:getSelecteds()
    return self._selectKnights
end

function RecycleKnightMainLayer:lock()
    self._locked = true
end

function RecycleKnightMainLayer:unlock()
    self._locked = false
end

return RecycleKnightMainLayer
