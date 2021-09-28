-- RecyclePetRebornMainLayer.lua

require "app.cfg.pet_info"
local EffectNode = require "app.common.effects.EffectNode"
local GlobalFunc = require("app.global.GlobalFunc")

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

local COST_GOLD = 200 -- 写死花费200元宝

local RecyclePetRebornMainLayer = class("RecyclePetRebornMainLayer", UFCCSNormalLayer)

function RecyclePetRebornMainLayer.create(...)
	return RecyclePetRebornMainLayer.new("ui_layout/recycle_petRebornMainLayer.json", ...)
end

function RecyclePetRebornMainLayer:ctor(...)
	
	self.super.ctor(self, ...)

    self._pets = {}
    self._selectPets = {}

	self._priceLabel = self:getLabelByName("Label_Price")
    self._priceLabel:createStroke(Colors.strokeBlack,1)
	self._descLabel = self:getLabelByName("Label_desc")
    self._resultDescLabel = self:getLabelByName("Label_result_desc")

	self._descLabel:setText(G_lang:get("LANG_RECYCLE_PET_REBORN_DESC"))
    self._resultDescLabel:setText(G_lang:get("LANG_RECYCLE_PET_REBORN_DESC"))
    self._priceLabel:setText(0)

    -- 特效
    local EffectNode = require "app.common.effects.EffectNode"
    self._bgEffect = EffectNode.new("effect_shoulan_bg")
    self._bgEffect:setPosition(ccp(216, -160))
    local parent = self:getPanelByName("Panel_Effect_BG")
    parent:addNode(self._bgEffect)  

	-- 绑定重生按钮
    self:registerBtnClickEvent("Button_reborn", function()
        self:onButtonRebornClicked()       
    end)

end

function RecyclePetRebornMainLayer:onButtonRebornClicked(  )
    if self._locked then return end
        
    -- 如果没有可归隐的武将则直接提示
    if table.nums(self._pets) == 0 then
        G_MovingTip:showMovingTip(G_lang:get("LANG_RECYCLE_SELECT_PET_REBORN_EMPTY"))
        return
    end
    
    -- 未选中则提示
    if table.nums(self._selectPets) == 0 then
        G_MovingTip:showMovingTip(G_lang:get("LANG_RECYCLE_PET_REBORN_EMPTY"))
        return
    end
    
    local pet_id = {}
    for k, pet in pairs(self._selectPets) do
        table.insert(pet_id, pet.id)
    end
    G_HandlersManager.recycleHandler:sendRecyclePet(pet_id, 3)
end

function RecyclePetRebornMainLayer:onLayerEnter()
    
    self:resetSelectState()

    self._bgEffect:play()

    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_RECYCLE_PET_PREVIEW, self._onRecycleEvent, self)

end

function RecyclePetRebornMainLayer:onLayerExit()
    
    uf_eventManager:removeListenerWithTarget(self)
    
end

function RecyclePetRebornMainLayer:playRecycleAnimation()
    
    local effectNode = nil
    
    -- 返回一个控制函数
    return function(command, callback)
        
        command = command or "play"
        
        if command == "play" then

            -- 直接把事件通过回调往外抛
            effectNode = require("app.common.effects.EffectNode").new("effect_hotfire", callback)
            self:getPanelByName("Panel_effect"):addNode(effectNode)
            effectNode:play()
            effectNode:setScale(3)
    --        effectNode:setPosition(ccp(display.cx, display.cy))
                        
        elseif command == "reset" then
            
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

-- 点击分解按钮后的预览
function RecyclePetRebornMainLayer:_onRecycleEvent(data)

    if data == nil then assert(false) end

    local item = clone(rawget(data, "item")) or {}
    local money = rawget(data, "money") and data.money or 0
    local fight_score = rawget(data, "fight_score") and data.fight_score or 0

    local RecyclePreviewLayer = require("app.scenes.recycle.RecyclePreviewLayer")
    local layer = RecyclePreviewLayer.create(RecyclePreviewLayer.LAYOUT_PET_REBORN, {
        -- "宝物重生后将会获得以下物品"
        {"Label_result_desc", {text=G_lang:get("LANG_RECYCLE_PET_REBORN_PREVIEW_DESC")}},
        -- 消耗
        {"Label_price_desc", {text=G_lang:get("LANG_RECYCLE_PET_PRICE_DESC")}},
        -- 价格
        {"Label_price", {text=COST_GOLD, color=G_Me.userData.gold < COST_GOLD and ccc3(0xf2, 0x79, 0x0d) or nil}},
    })
    uf_sceneManager:getCurScene():addChild(layer)
    
    layer:registerBtnClickEvent("Button_ok", function()
             
        if G_Me.userData.gold < COST_GOLD then
--            G_MovingTip:showMovingTip(G_lang:get("LANG_RECYCLE_TREASURE_REBORN_GOLD_EMPTY"))
            require("app.scenes.shop.GoldNotEnoughDialog").show()
            return
        end
        
        G_HandlersManager.recycleHandler:sendRecyclePet({self._selectPets[1].id}, 1)
        
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
    
    for i=1, #item do

        local goodConfig = G_Goods.convert(item[i].type, item[i].value)
        
        datas.add{
            {"ImageView_item", {visible=true}},
            {"ImageView_frame", {texture=G_Path.getEquipColorImage(goodConfig.quality,goodConfig.type)}},
            {"ImageView_head", {texture=goodConfig.icon, texType=UI_TEX_TYPE_LOCAL}},
            {"ImageView_bg", {texture=G_Path.getEquipIconBack(goodConfig.quality)}},
            {"Label_name", {text=goodConfig.name, stroke=Colors.strokeBlack, color=Colors.qualityColors[goodConfig.quality]}},
            {"Label_amount", {text="x"..item[i].size, stroke=Colors.strokeBlack}},
        }

    end

    -- 战宠积分
    if fight_score and fight_score > 0 then
        local goodConfig = G_Goods.convert(G_Goods.TYPE_PET_SCORE)

        datas.add{
            {"ImageView_item", {visible=true}},
            {"ImageView_frame", {texture=G_Path.getEquipColorImage(goodConfig.quality,goodConfig.type)}},
            {"ImageView_head", {texture=goodConfig.icon, texType=UI_TEX_TYPE_LOCAL}},
            {"ImageView_bg", {visible=true, texture=G_Path.getEquipIconBack(goodConfig.quality)}},
            {"Label_name", {text=goodConfig.name, stroke=Colors.strokeBlack, color=Colors.qualityColors[goodConfig.quality]}},
            {"Label_amount", {text='x'..fight_score, stroke=Colors.strokeBlack}},
        }
    end
    
    -- 银两
    if money and money > 0 then
        local goodConfig = G_Goods.convert(G_Goods.TYPE_MONEY)

        datas.add{
            {"ImageView_item", {visible=true}},
            {"ImageView_frame", {texture=G_Path.getEquipColorImage(goodConfig.quality,goodConfig.type)}},
            {"ImageView_head", {texture=goodConfig.icon, texType=UI_TEX_TYPE_LOCAL}},
            {"ImageView_bg", {visible=true, texture=G_Path.getEquipIconBack(goodConfig.quality)}},
            {"Label_name", {text=goodConfig.name, stroke=Colors.strokeBlack, color=Colors.qualityColors[goodConfig.quality]}},
            {"Label_amount", {text='x'..GlobalFunc.ConvertNumToCharacter(money), stroke=Colors.strokeBlack}},
        }
    end
    
    layer:updateListView("Panel_list", datas.get())
end

function RecyclePetRebornMainLayer:_initSelecteds()
    
    self._pets = {}
    local petList = G_Me.bagData.petData:getPetList()
    
    for key, pet in pairs(petList) do
        
        -- 未上阵 未护佑
        if pet.id ~= G_Me.bagData.petData:getFightPetId() and not G_Me.formationData:isProtectPetByPetId(pet.id) then

            table.insert(self._pets, pet)
        end
    end

    table.sort(self._pets, function(a, b)
        return a.level > b.level or (a.level == b.level and a.base_id < b.base_id)
    end)
end

function RecyclePetRebornMainLayer:initSelectState(selectPets, anima)
    
    self._selectPets = selectPets or self._selectPets
    
    anima = anima == nil and true or anima
    
    -- 更新knight
    if self._selectPets and #self._selectPets >= 1 then
        
        self:getPanelByName("Panel_added"):setVisible(true)
        self:getPanelByName("Panel_before_add"):setVisible(false)

        local pet = self._selectPets[1]

        -- knight的配置文件
        local petConfig = pet_info.get(pet.base_id)

        -- 隐藏按钮
        self:getButtonByName("Button_selected"):setVisible(false)
        self:getPanelByName("Panel_Click"):setVisible(true)

        -- 显示图像
        local img = self:getImageViewByName("Image_selected")
        img:setVisible(false)

        if self._petNode == nil then
            self._petNode = display.newNode()
            self:getPanelByName("Panel_8766"):addNode(self._petNode)
            self._petNode:setPosition(ccp(img:getPositionX(), img:getPositionY() - 210))
        end

        self._petNode:setVisible(true)

        self._petNode:removeAllChildren()
        local petPath = G_Path.getPetReadyEffect(petConfig.ready_id)
        self._petEffect = EffectNode.new(petPath)
        self._petEffect:setScale(0.9)
        self._petEffect:play()

        -- 要做动画
        if anima then

            local EffectMovingNode = require "app.common.effects.EffectMovingNode"
            if self._node ~= nil then
                self._petNode:removeAllChildren()
            end
            self._node = EffectMovingNode.new("moving_card_jump", 
                function(key)
                    if key == "char" then                                          
                        return self._petEffect
                    elseif key == "effect_card_dust" then
                        local effect   = EffectNode.new("effect_card_dust") 

                        effect:play()
                        return effect  
                    end
                end,
                function(event)
                    if event == "finish" then
                        if self._endCallback ~= nil then
                            self._endCallback()
                        end
                    end
                end
            )
            self._node:play()
            self._petNode:addChild(self._node)
        end

        self._priceLabel:setText(COST_GOLD)

--         -- 星级
-- --            self:getPanelByName("Panel_stars"..count):setVisible(true)
-- --            for i=1, 6 do
-- --                self:getImageViewByName("ImageView_star_dark"..count.."_"..i):setVisible(i > knightConfig.star)
-- --            end

        self:getImageViewByName("Image_name"):setVisible(true)

        -- 名称
        local name = self:getLabelByName("Label_name")
        name:setColor(Colors.qualityColors[petConfig.quality])
        name:createStroke(Colors.strokeBlack,1)
        name:setText(petConfig.name)

-- --            -- 级别, 大于0则显示，否则不显示
-- --            if knightConfig.advanced_level > 0 then
-- --                local grade = self:getLabelByName("Label_grade"..count)
-- --                grade:createStroke(Colors.strokeBlack,1)
-- --                grade:setText('+'..knightConfig.advanced_level)
-- --            else
-- --                self:getLabelByName("Label_grade"..count):setVisible(false)
-- --            end

-- --        -- 取消按钮
-- --        -- 调整取消按钮的位置
-- --        local btnCancel = self:getButtonByName("Button_cancel")
-- --        btnCancel:setVisible(true)
-- --        btnCancel:setPosition(ccp(-120, 400))
-- --
-- --        self:registerBtnClickEvent("Button_cancel", function()
-- --            self._selectKnights[1] = nil
-- --            self:initSelectState(self._selectKnights, false)
-- --        end)
        
        -- 强化等级
        _updateLabel(self, "Label_content_strength_desc", G_lang:get("LANG_RECYCLE_PET_LEVEL_DESC"))
        _updateLabel(self, "Label_content_strength", G_lang:get("LANG_RECYCLE_PET_LEVEL", {level=pet.level}))
        local getPosition = _autoAlign(ccp(0, 0), {self:getLabelByName("Label_content_strength_desc"),
        self:getLabelByName("Label_content_strength")}, ALIGN_LEFT)
        self:getLabelByName("Label_content_strength_desc"):setPosition(getPosition(1))
        self:getLabelByName("Label_content_strength"):setPosition(getPosition(2))

        -- 星级
        _updateLabel(self, "Label_content_star_desc", G_lang:get("LANG_RECYCLE_PET_STAR_DESC"))
        local pet_info = pet_info.get(pet.base_id)
        for index = 1 , 5 do 
            self:getImageViewByName("Image_Star"..index):loadTexture(pet_info.star >= index and "ui/yangcheng/star_juexing.png" or "ui/yangcheng/star_juexing_kong.png")
        end

        -- 神炼
        _updateLabel(self, "Label_content_refine_desc", G_lang:get("LANG_RECYCLE_PET_SHENLINA_DESC"))
        _updateLabel(self, "Label_content_refine", pet.addition_lvl)
        local getPosition = _autoAlign(ccp(0, 0), {self:getLabelByName("Label_content_refine_desc"),
        self:getLabelByName("Label_content_refine")}, ALIGN_LEFT)
        self:getLabelByName("Label_content_refine_desc"):setPosition(getPosition(1))
        self:getLabelByName("Label_content_refine"):setPosition(getPosition(2))
        
--         -- 文字描述
--         _updateLabel(self, "Label_result_desc", G_lang:get("LANG_RECYCLE_pet_REBORN_DESC1"))
        
    else
        
        -- 显示按钮
        self:getPanelByName("Panel_added"):setVisible(false)
        self:getPanelByName("Panel_before_add"):setVisible(true)
        self:getButtonByName("Button_selected"):setVisible(true)
        self:getImageViewByName("Image_selected"):setVisible(false)
        self:getImageViewByName("Image_name"):setVisible(false)
        self:getPanelByName("Panel_Click"):setVisible(false)
        if self._petNode then
            self._petNode:setVisible(false)
        end
        self._priceLabel:setText(0)
    end
    
end

function RecyclePetRebornMainLayer:resetSelectState()
    
    -- 更新当前的界面状态
    self:initSelectState{}   -- 初始化空表
    
    -- 更新当前可选武将
    self:_initSelecteds()
    
end

function RecyclePetRebornMainLayer:getAvailableSelecteds()
	return self._pets
end

function RecyclePetRebornMainLayer:getSelecteds()
    return self._selectPets
end

function RecyclePetRebornMainLayer:lock()
    self._locked = true
end

function RecyclePetRebornMainLayer:unlock()
    self._locked = false
end

return RecyclePetRebornMainLayer