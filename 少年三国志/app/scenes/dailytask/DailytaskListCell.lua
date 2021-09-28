local DailytaskListCell = class("DailytaskListCell",function()
    return CCSItemCellBase:create("ui_layout/dailytask_taskCell.json")
end)

require("app.cfg.daily_mission_info")
require("app.cfg.daily_box_info")
local Goods = require("app.setting.Goods")
local FunctionLevelConst = require("app.const.FunctionLevelConst")

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

function DailytaskListCell:ctor()
    self._type = 1

    self:setTouchEnabled(true)
    -- self._pro = self:getLabelByName("Label_type")
    self._goButton = self:getButtonByName("Button_go")
    self._getButton = self:getButtonByName("Button_get")
    self._gotStat = self:getImageViewByName("Image_got")
    self._gotStat:setVisible(false)

    local EffectNode = require "app.common.effects.EffectNode"
    self.node = EffectNode.new("effect_around2")     
    self.node:setScale(1.4) 
    self._getButton:addNode(self.node)
    self.node:setVisible(false)

    self:registerBtnClickEvent("Button_border", function ( widget )
        if self._info ~= nil then
            require("app.scenes.common.dropinfo.DropInfo").show(self._info.award1_type,self._info.award1_value) 
        end
    end)    
    self:registerBtnClickEvent("Button_go", function ( widget )
        self:_go(self._info.function_id)
    end)   
    self:registerBtnClickEvent("Button_get", function ( widget )
        G_HandlersManager.dailytaskHandler:sendFinishDailyMission(self._data.id)
    end)   
    self:registerCellClickEvent(function ( cell, index )
        if self._type == 1 then
            self:_go(self._info.function_id)
        elseif self._type == 2 then
            G_HandlersManager.dailytaskHandler:sendFinishDailyMission(self._data.id)
        else

        end
    end) 
end

function DailytaskListCell:updateData(data)

    self._data = data

    local info = daily_mission_info.get(data.id)
    self._info = info

    local proText = data.progress.."/"..info.require_times
    -- self:getLabelByName("Label_process_num"):setText(proText) 
    -- self:getLabelByName("Label_process"):setText(G_lang:get("LANG_ACHIEVEMENT_ITEM_PROCESS_DESC")) 

    local labelProcess = self:getLabelByName("Label_process")
    local labelProcessNum = self:getLabelByName("Label_process_num")
    labelProcess:setText(G_lang:get("LANG_ACHIEVEMENT_ITEM_PROCESS_DESC")) 
    labelProcessNum:setText(proText) 
    local getPosition = _autoAlign(ccp(0, 0), {labelProcess, labelProcessNum}, ALIGN_CENTER)
    labelProcess:setPosition(getPosition(1))
    labelProcessNum:setPosition(getPosition(2))

    local g = Goods.convert(info.award1_type, info.award1_value)

    --icon    
    self:getImageViewByName("ImageView_equipment_icon"):loadTexture(info.icon)
    -- self:getImageViewByName("ImageView_equipment_icon"):loadTexture(g.icon)
    -- self:getButtonByName("Button_border"):loadTextureNormal(G_Path.getEquipColorImage(g.quality,g.type))
    -- self:getButtonByName("Button_border"):loadTexturePressed(G_Path.getEquipColorImage(g.quality,g.type))
    self:getLabelByName("Label_num"):setText("×"..info.award1_size)
    self:getLabelByName("Label_num"):createStroke(Colors.strokeBrown, 1)
     
    self:getLabelByName("Label_name"):setText(info.name)
    self:getLabelByName("Label_name"):createStroke(Colors.strokeBrown, 1)

    -- self:getLabelByName("Label_desc"):setText(info.comment)

    self:getLabelByName("Label_22"):setText(G_lang:get("LANG_DAILYTASK_AWARD"))

    -- local awardText = g.name.."×"..info.award1_size.."  "..G_lang:get("LANG_DAILYTASK_SCORE0").."×"..info.points
    local awardText = g.name.."×"..info.award1_size..", "..G_lang:get("LANG_DAILYTASK_SCORE0").."×"..info.points
    self:getLabelByName("Label_award"):setText('          '..awardText)

    if data.progress >= info.require_times then
        self._goButton:setVisible(false)
        if data.is_finished then 
            --已领取
            self._type = 3
            self._getButton:setVisible(false)
            self._gotStat:setVisible(true)
            self.node:setVisible(false)
        else
            --可领取
            self._type = 2
            self._getButton:setVisible(true)
            self._gotStat:setVisible(false)
            self.node:play()
            self.node:setVisible(true)
        end
    else
        --未完成
        self._type = 1
        self._goButton:setVisible(true)
        self._getButton:setVisible(false)
        self._gotStat:setVisible(false)
        self.node:setVisible(false)
    end
    
end

function DailytaskListCell:onLayerUnload()
    
    uf_eventManager:removeListenerWithTarget(self)

end

function DailytaskListCell:_go(functionId)
    
        local moduleId = 0
        self._functionId = functionId
        self._functionValue = nil
        self._chapterId = 0
        self._scenePack = GlobalFunc.sceneToPack("app.scenes.mainscene.MainScene",{})

        local sceneName = nil
        if self._functionId == 1 then
            sceneName = "app.scenes.dungeon.DungeonMainScene"
        elseif self._functionId == 2 then
            sceneName = "app.scenes.storydungeon.StoryDungeonMainScene"
            moduleId = FunctionLevelConst.STORY_DUNGEON
        elseif self._functionId == 3 then
            sceneName = "app.scenes.shop.ShopScene"
        elseif self._functionId == 4 then
            sceneName = "app.scenes.secretshop.SecretShopScene"
            moduleId = FunctionLevelConst.SECRET_SHOP
        elseif self._functionId == 5 then
            sceneName = "app.scenes.arena.ArenaScene"
            self._chapterId = 1
            moduleId = FunctionLevelConst.ARENA_SCENE
        elseif self._functionId == 6 then
            sceneName = "app.scenes.wush.WushScene"
            moduleId = FunctionLevelConst.TOWER_SCENE
        elseif self._functionId == 7 then
            sceneName = "app.scenes.treasure.TreasureComposeScene"
            moduleId = FunctionLevelConst.TREASURE_COMPOSE
        elseif self._functionId == 8 then
            sceneName = "app.scenes.shop.ShopScene"
        elseif self._functionId == 9 then
            sceneName = "app.scenes.shop.ShopScene"
        elseif self._functionId == 10 then
            sceneName = "app.scenes.moshen.MoShenScene"
            moduleId = FunctionLevelConst.MOSHENG_SCENE
        elseif self._functionId == 11 then
            sceneName = "app.scenes.recycle.RecycleScene"
        elseif self._functionId == 12 then
            sceneName = "app.scenes.recycle.RecycleScene"
        elseif self._functionId == 13 then
            sceneName = "app.scenes.moshen.MoShenScene"
            moduleId = FunctionLevelConst.MOSHENG_SCENE
        elseif self._functionId == 14 then
            sceneName = "app.scenes.friend.FriendMainScene"
        elseif self._functionId == 15 then
            sceneName = "app.scenes.herofoster.HeroFosterScene"
        elseif self._functionId == 16 then
            sceneName = "app.scenes.equipment.EquipmentMainScene"
        elseif self._functionId == 17 then
            sceneName = "app.scenes.treasure.TreasureMainScene"
        elseif self._functionId == 18 then
            sceneName = "app.scenes.city.CityScene"
        elseif self._functionId == 19 then
            sceneName = "app.scenes.harddungeon.HardDungeonMainScene"
        elseif self._functionId == 20 then
            sceneName = "app.scenes.vip.VipMapScene"
        elseif self._functionId == 21 then
            sceneName = "app.scenes.themedrop.ThemeDropMainScene"
        elseif self._functionId == 22 then
            sceneName = "app.scenes.crusade.CrusadeScene"
        elseif self._functionId == 23 then
            sceneName = "app.scenes.dailypvp.DailyPvpMainScene"
            moduleId = FunctionLevelConst.DAILY_PVP
        elseif self._functionId == 24 then
            sceneName = "app.scenes.herosoul.HeroSoulScene"
            moduleId = FunctionLevelConst.HERO_SOUL
            self._chapterId = require("app.const.HeroSoulConst").TERRACE
        elseif self._functionId == 25 then
            sceneName = "app.scenes.herosoul.HeroSoulScene"
            moduleId = FunctionLevelConst.HERO_SOUL
            self._chapterId = require("app.const.HeroSoulConst").TRIAL
        elseif self._functionId == 26 then
            sceneName = "app.scenes.activity.ActivityMainScene"
            moduleId = FunctionLevelConst.FORTUNE
            self._functionValue = G_Me.activityData:getFortuneIndex()
        end

        if moduleId > 0 and not G_moduleUnlock:checkModuleUnlockStatus(moduleId) then 
            return 
        end

        if sceneName then
            if self._functionId == 25 or self._functionId == 24 then 
                uf_sceneManager:popToRootAndReplaceScene(require(sceneName).new(nil, nil, self._scenePack, self._chapterId))
            else
                uf_sceneManager:popToRootAndReplaceScene(require(sceneName).new(nil, nil, self._functionValue, self._chapterId, self._scenePack))
            end
        end
end

return DailytaskListCell
