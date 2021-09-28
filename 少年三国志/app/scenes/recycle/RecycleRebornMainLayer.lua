-- RecycleRebornMainLayer

local REBORN_PRICE = 50

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

local ALIGN_CENTER = "align_center"
local ALIGN_LEFT = "align_left"
local ALIGN_RIGHT = "align_right"

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

require "app.cfg.knight_info"


local RecycleRebornMainLayer = class("RecycleRebornMainLayer", UFCCSNormalLayer)

function RecycleRebornMainLayer.create(...)
    return RecycleRebornMainLayer.new("ui_layout/recycle_knightRebornMainLayer.json", nil, ...)
end

function RecycleRebornMainLayer:ctor(...)
    
    RecycleRebornMainLayer.super.ctor(self, ...)
    
    -- 重生返还初始武将以及养成所用的所有资源
    -- _updateLabel(self, "Label_desc1", G_lang:get("LANG_RECYCLE_REBORN_DESC1"))
    
    -- 价格
    _updateLabel(self, "Label_price", REBORN_PRICE, Colors.strokeBrown)
    
    -- 绑定重生按钮
    self:registerBtnClickEvent("Button_reborn", function()
        self:onButtonRebornClicked()       
    end)

    self._effectNode = {}
    
    if require("app.scenes.mainscene.SettingLayer").showEffectEnable() then
    
        -- 背景特效
        local EffectNode = require "app.common.effects.EffectNode"
        local backEffect = EffectNode.new("effect_jinjiechangjing")
        local parent = self:getImageViewByName("ImageView_8508")
        parent:addNode(backEffect)
        backEffect:setScale(0.5)
        backEffect:setPositionXY(0, -38)

        self._effectNode.play = function()
            backEffect:play()
        end
    end
    
    self:registerBtnClickEvent("Button_help", function()
        self:onButtonHelpClicked()
    end)
    
end

function RecycleRebornMainLayer:onButtonRebornClicked(  )
    if self._locked then return end

    local knights = {knight_id={}, type=3}
    for k, knight in pairs(self._selectKnights) do
        knights.knight_id[#knights.knight_id+1] = knight.id
    end
    G_HandlersManager.recycleHandler:sendRecycleKnight(knights)  -- 3表示重生预览
end

function RecycleRebornMainLayer:onButtonHelpClicked(  )
--        local layer = require("app.scenes.recycle.RecycleHelpLayer").create(G_lang:get("LANG_RECYCLE_REBORN_TITLE"), G_lang:get("LANG_RECYCLE_REBORN_HELP_DESC"))
--        uf_sceneManager:getCurScene():addChild(layer)
    
    require("app.scenes.common.CommonHelpLayer").show({
        {title=G_lang:get("LANG_RECYCLE_REBORN_TITLE"), content=G_lang:get("LANG_RECYCLE_REBORN_HELP_DESC")}
    } )
end

function RecycleRebornMainLayer:onLayerEnter()
    
    self:resetSelectState()
    
    -- 播放特效
    if self._effectNode and self._effectNode.play then
        self._effectNode:play()
    end
    
    -- local btn = self:getButtonByName("Button_help")
    -- local label = self:getLabelByName("Label_desc1")
    -- btn:setPositionXY(label:getPositionX() + label:getSize().width/2 + btn:getSize().width/2, label:getPositionY())
    
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_RECYCLE_PREVIEW, self._onRecycleRebornEvent, self)
    
end

function RecycleRebornMainLayer:onLayerExit()
    
    uf_eventManager:removeListenerWithTarget(self)
    
end

function RecycleRebornMainLayer:_initSelecteds()
    
    -- 先获取全部的武将，挑选符合要求的武将
    self._knights = {}
    local knightList = G_Me.bagData.knightsData:getKnightsList()
    require "app.cfg.knight_info"

    local mainKnight = nil
    
    for key, knight in pairs(knightList) do
        -- 未上阵，等级大于1，天命等级大于1，突破大于0
        -- if G_Me.formationData:getKnightTeamId(knight.id) == 0 and knight_info.get(knight.base_id).quality > 1 and
        --     (knight.level > 1 or 
        --     knight.halo_level > 1 or 
        --     knight_info.get(knight.base_id).advanced_level >= 1 or
        --     knight.training.hp > 0 or
        --     knight.training.at > 0 or 
        --     knight.training.pd > 0 or
        --     knight.training.md > 0) then
        --     knight.potential = knight_info.get(knight.base_id).potential
        --     self._knights[#self._knights+1] = knight
        -- end
        -- 2.1.5版本优化为未上阵、品质为蓝色及以上的武将都可以重生
        if (G_Me.formationData:getKnightTeamId(knight.id) == 0 and knight_info.get(knight.base_id).potential >= 13) or 
            (G_Me.formationData:getKnightTeamId(knight.id) == 0 and knight_info.get(knight.base_id).quality > 1 and
            (knight.level > 1 or 
            knight.halo_level > 1 or 
            knight_info.get(knight.base_id).advanced_level >= 1 or
            knight.training.hp > 0 or
            knight.training.at > 0 or 
            knight.training.pd > 0 or
            knight.training.md > 0)) then

            knight.potential = knight_info.get(knight.base_id).potential
            self._knights[#self._knights+1] = knight
        end

        if knight.id == G_Me.formationData:getMainKnightId() and
            (knight.halo_level > 1 or 
            knight_info.get(knight.base_id).advanced_level >= 1 or
            knight.training.hp > 0 or
            knight.training.at > 0 or 
            knight.training.pd > 0 or
            knight.training.md > 0 or 
            knight.awaken_level > 0) then
            
            mainKnight = knight
        end
    end

    -- 排序，按照资质从大到小排序，资质一致则根据等级从大到小排序，等级一致则根据ID从小到大排序
    table.sort(self._knights, function(a, b)
        return a.level > b.level or (a.level == b.level and (a.potential > b.potential))

        --a.potential > b.potential or (a.potential == b.potential and (a.level > b.level or (a.level == b.level and a.base_id < b.base_id)))
    end)
    
    if mainKnight then
        table.insert(self._knights, 1, G_Me.bagData.knightsData:getMainKightInfo())
    end
end

function RecycleRebornMainLayer:initSelectState(selectKnights, anima)
    
    self._selectKnights = selectKnights or self._selectKnights
    
    anima = anima == nil and true or anima
    
    -- 更新knight
    if self._selectKnights and #self._selectKnights >= 1 then
        
        self:getPanelByName("Panel_added"):setVisible(true)
        self:getPanelByName("Panel_before_add"):setVisible(false)
        
        local knight = self._selectKnights[1]

        -- knight的配置文件
        require "app.cfg.knight_info"
        local knightConfig = knight_info.get(knight.base_id)

        -- 隐藏按钮
        self:getButtonByName("Button_selected"):setVisible(false)

        -- 显示图像
        local img = self:getImageViewByName("Image_selected")
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
        shadow:setPositionXY(tonumber(config.shadow_x - config.x) - img:getSize().width * (anchorPoint.x - 0.5),  tonumber(config.shadow_y - config.y) - img:getSize().height * (anchorPoint.y - 0.5))
        img:addNode(shadow, -3)

        self:getImageViewByName("Image_name"):setVisible(true)

        -- 名称
        local name = self:getLabelByName("Label_name")
        name:setColor(Colors.qualityColors[knightConfig.quality])
        name:createStroke(Colors.strokeBlack,1)
        name:setText(knightConfig.name.." +"..knightConfig.advanced_level)
        
        -- 等级
        _updateLabel(self, "Label_content_level_desc", G_lang:get("LANG_RECYCLE_REBORN_LEVEL_DESC"))
        _updateLabel(self, "Label_content_level", knight.level)
        local getPosition = _autoAlign(ccp(0, 0), {self:getLabelByName("Label_content_level_desc"),
        self:getLabelByName("Label_content_level")}, ALIGN_LEFT)
        self:getLabelByName("Label_content_level_desc"):setPosition(getPosition(1))
        self:getLabelByName("Label_content_level"):setPosition(getPosition(2))

        -- 突破
        _updateLabel(self, "Label_content_advance_desc", G_lang:get("LANG_RECYCLE_REBORN_ADVANCE_DESC"))
        _updateLabel(self, "Label_content_advance", knightConfig.advanced_level > 0 and '+'..knightConfig.advanced_level or '0')
        local getPosition = _autoAlign(ccp(0, 0), {self:getLabelByName("Label_content_advance_desc"),
        self:getLabelByName("Label_content_advance")}, ALIGN_LEFT)
        self:getLabelByName("Label_content_advance_desc"):setPosition(getPosition(1))
        self:getLabelByName("Label_content_advance"):setPosition(getPosition(2))

        -- 天命
        _updateLabel(self, "Label_content_destiny_desc", G_lang:get("LANG_RECYCLE_REBORN_DESTINY_DESC"))
        _updateLabel(self, "Label_content_destiny", G_lang:get("LANG_RECYCLE_REBORN_DESTINY_AMOUNT", {destiny=knight.halo_level}))
        local getPosition = _autoAlign(ccp(0, 0), {self:getLabelByName("Label_content_destiny_desc"),
        self:getLabelByName("Label_content_destiny")}, ALIGN_LEFT)
        self:getLabelByName("Label_content_destiny_desc"):setPosition(getPosition(1))
        self:getLabelByName("Label_content_destiny"):setPosition(getPosition(2))
        
        -- 当前天命值
        _updateLabel(self, "Label_content_destiny_exp_desc", G_lang:get("LANG_RECYCLE_REBORN_DESTINY_EXP_DESC"))
        _updateLabel(self, "Label_content_destiny_exp", knight.halo_exp)
        local getPosition = _autoAlign(ccp(0, 0), {self:getLabelByName("Label_content_destiny_exp_desc"),
        self:getLabelByName("Label_content_destiny_exp")}, ALIGN_LEFT)
        self:getLabelByName("Label_content_destiny_exp_desc"):setPosition(getPosition(1))
        self:getLabelByName("Label_content_destiny_exp"):setPosition(getPosition(2))

        --觉醒等级
        local stars = G_Me.bagData.knightsData:getKnightAwakenLevelByKnightId(knight.id) or -1
        self:showWidgetByName("Panel_Star", stars >= 0)
        if stars >= 0 then 
            self:showWidgetByName("Image_Star1", stars >= 1)
            self:showWidgetByName("Image_Star2", stars >= 2)
            self:showWidgetByName("Image_Star3", stars >= 3)
            self:showWidgetByName("Image_Star4", stars >= 4)
            self:showWidgetByName("Image_Star5", stars >= 5)
            self:showWidgetByName("Image_Star6", stars >= 6)
        end
        
        -- 文字描述
        if knight.id == G_Me.formationData:getMainKnightId() then
            _updateLabel(self, "Label_result_desc", G_lang:get("LANG_RECYCLE_REBORN_DESC_MAIN")) 
        else
            _updateLabel(self, "Label_result_desc", G_lang:get("LANG_RECYCLE_REBORN_DESC1"))            
        end

        -- 化神等级
        local godTitleLabel = self:getLabelByName("Label_God_Level")
        local godImage = self:getImageViewByName("Image_God_Level")
        if knightConfig.god_level == 0 and knight.pulse_level == 0 then
            godTitleLabel:setVisible(false)
            godImage:setVisible(false)
        else
            local HeroGodCommon = require "app.scenes.herofoster.god.HeroGodCommon"
            godTitleLabel:setVisible(true)
            godImage:setVisible(true)
            local nowGodLevel = G_Me.bagData.knightsData:getGodLevel(knight.id)
            godTitleLabel:setText(HeroGodCommon.getDisplyLevel4(nowGodLevel, knightConfig.quality))
            godImage:loadTexture(G_Path.getGodQualityShuiYin(knightConfig.quality))
        end


        
    else
        
        -- 显示按钮
        self:getButtonByName("Button_selected"):setVisible(true)
        self:getImageViewByName("Image_selected"):setVisible(false)
        self:getImageViewByName("Image_name"):setVisible(false)
        
        self:getPanelByName("Panel_added"):setVisible(false)
        self:getPanelByName("Panel_before_add"):setVisible(true)
                
    end
    
end

function RecycleRebornMainLayer:_onRecycleRebornEvent(message)
    
    -- dump(message)

    local item = rawget(message, "item") or {}
    local knights = rawget(message, "knight_food") or {}
    local essence = rawget(message, "essence")
    local money = rawget(message, "money")
    local soul = rawget(message, "soul")
    local award = rawget(message, "award") or {}
    
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
    
    -- local _award = {}
    -- for i=1, #award do
    --     _award[#_award+1] = award[i]
    -- end
    local _award = clone(award)
    
    -- 觉醒道具按照id从小到大排列
    table.sort(_award, function(a, b)
        if a.type ~= b.type then
            return a.type < b.type
        else
            return a.value < b.value
        end
    end)
    
    award = _award
    
    -- 预览弹框
    local RecyclePreviewLayer = require("app.scenes.recycle.RecyclePreviewLayer")
    local layer = RecyclePreviewLayer.create(RecyclePreviewLayer.LAYOUT_REBORN_KNIGHT, {
        -- "武将重生后将会获得以下物品"
        {"Label_result_desc", {text=G_lang:get("LANG_RECYCLE_REBORN_PREVIEW_DESC")}},
        -- 消耗
        {"Label_price_desc", {text=G_lang:get("LANG_RECYCLE_REBORN_PRICE_DESC")}},
        -- 价格
        {"Label_price", {text=REBORN_PRICE, color=G_Me.userData.gold < REBORN_PRICE and ccc3(0xf2, 0x79, 0x0d) or nil}},
    })
    uf_sceneManager:getCurScene():addChild(layer)

    layer:registerBtnClickEvent("Button_ok", function()
             
        if G_Me.userData.gold < REBORN_PRICE then
--            G_MovingTip:showMovingTip(G_lang:get("LANG_RECYCLE_REBORN_GOLD_EMPTY"))
            require("app.scenes.shop.GoldNotEnoughDialog").show()
            return
        end
        
        if knights.count > 0 then
            local CheckFunc = require("app.scenes.common.CheckFunc")
            if CheckFunc.checkDiffByType(G_Goods.TYPE_KNIGHT, knights.count) then
                return
            end
        end
        
        local params = {knight_id={}, type=1}
        for k, knight in pairs(self._selectKnights) do
            params.knight_id[#params.knight_id+1] = knight.id
        end
        G_HandlersManager.recycleHandler:sendRecycleKnight(params)
        
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
    
    -- 添加卡牌
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
    
    -- 添加道具
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
    
    if #award > 0 then
        local fragmentNum = 0
        -- 这里因为重生以后只有一种碎片，这里需要把碎片的数量加一下
        local fragmentType = 0
        local fragmentValue = 0
        -- 返回的红色武将精华数量需要特殊处理，蛋疼
        local hongsewujiangjinghuaNum = 0
        for i=1, #award do
            if award[i].type ~= G_Goods.TYPE_FRAGMENT then
                if award[i].type == 3 and award[i].value == 3 then
                    -- 红色武将精华
                    hongsewujiangjinghuaNum = hongsewujiangjinghuaNum + award[i].size
                else
                    local goodConfig = G_Goods.convert(award[i].type, award[i].value)
                    datas.add{
                        {"ImageView_item", {visible=true}},
                        {"ImageView_frame", {texture=G_Path.getEquipColorImage(goodConfig.quality, goodConfig.type)}},
                        {"ImageView_head", {texture=goodConfig.icon, texType=UI_TEX_TYPE_LOCAL}},
                        {"ImageView_bg", {visible=true, texture=G_Path.getEquipIconBack(goodConfig.quality)}},
                        {"Label_name", {text=goodConfig.name, stroke=Colors.strokeBlack, color=Colors.qualityColors[goodConfig.quality]}},
                        {"Label_amount", {text='x'..award[i].size, stroke=Colors.strokeBlack}},
                    }
                end                
            else
                fragmentNum = fragmentNum + award[i].size
                if fragmentType == 0 then fragmentType = award[i].type end
                if fragmentValue == 0 then fragmentValue = award[i].value end
            end            
        end
        if fragmentNum > 0 then
            local goodConfig = G_Goods.convert(fragmentType, fragmentValue, fragmentNum)
            datas.add{
                {"ImageView_item", {visible=true}},
                {"ImageView_frame", {texture=G_Path.getEquipColorImage(goodConfig.quality,goodConfig.type)}},
                {"ImageView_head", {texture=goodConfig.icon, texType=UI_TEX_TYPE_LOCAL}},
                {"ImageView_bg", {visible=true, texture=G_Path.getEquipIconBack(goodConfig.quality)}},
                {"Label_name", {text=goodConfig.name, stroke=Colors.strokeBlack, color=Colors.qualityColors[goodConfig.quality]}},
                {"Label_amount", {text='x'..goodConfig.size, stroke=Colors.strokeBlack}},
            }
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

function RecycleRebornMainLayer:resetSelectState()
    
    -- 更新当前的界面状态
    self:initSelectState{}   -- 初始化空表
    
    -- 更新当前可选武将
    self:_initSelecteds()
    
end

function RecycleRebornMainLayer:getAvailableSelecteds()
    return self._knights
end

function RecycleRebornMainLayer:getSelecteds()
    return self._selectKnights
end

function RecycleRebornMainLayer:lock() self._locked = true end
function RecycleRebornMainLayer:unlock() self._locked = false end

return RecycleRebornMainLayer
