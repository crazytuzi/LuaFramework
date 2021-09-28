-- CityScene
-- 领地主场景

local function _updateLabel(target, name, params)
    
    local label = target:getLabelByName(name)
    if params.stroke ~= nil then
        label:createStroke(params.stroke, 1)
    end
    
    if params.color ~= nil then
        label:setColor(params.color)
    end
    
    if params.text ~= nil then
        label:setText(params.text)
    end
    
    if params.visible ~= nil then
        label:setVisible(params.visible)
    end
    
end

local function _updateImageView(target, name, params)
    
    local img = target:getImageViewByName(name)
    if params.texture ~= nil then
        img:loadTexture(params.texture, params.texType or UI_TEX_TYPE_LOCAL)
    end
    
    if params.visible ~= nil then
        img:setVisible(params.visible)
    end
    
end

require "app.cfg.knight_info"
require "app.cfg.city_common_event_info"
require "app.cfg.city_end_event_info"
require "app.cfg.function_level_info"

local CityPatrolAwardLayer = require("app.scenes.city.CityPatrolAwardLayer")
local CityOneKeyPatrolLayer = require("app.scenes.city.CityOneKeyPatrolLayer")

local CityScene = class("CityScene", UFCCSBaseScene)

-- 场景主界面类型
CityScene.TYPE_MAIN = 1
CityScene.TYPE_CHALLENGE = 2
CityScene.TYPE_ADD = 3
CityScene.TYPE_ADD_LIST = 4
CityScene.TYPE_PATROL = 5
CityScene.TYPE_PATROL_STATE = 6
CityScene.TYPE_TECH = 7


function CityScene:ctor(_, _, _, _, scenePack)

    CityScene.super.ctor(self)
    
    -- 缓存layer
    self._cacheLayers = {layers = {}}
    
    self._cacheLayers.add = function(key, layer)
        assert(layer, "The layer could not be nil !")
        local _layer = self._cacheLayers.layers[key]
        if _layer and _layer ~= layer then
            _layer:release()
        end
        layer:retain()
        self._cacheLayers.layers[key] = layer
    end
    
    self._cacheLayers.get = function(key)
        return self._cacheLayers.layers[key]
    end
    
    self._cacheLayers.release = function()
        for k, layer in pairs(self._cacheLayers.layers) do
            layer:release()
        end
        self._cacheLayers.layers = {}
    end
    
    -- 加载主界面，一般情况下是大地图的领地界面
    self:_loadLayer(CityScene.TYPE_MAIN, 0, scenePack)
    
--    -- 初次进入领地，请求我方数据，然后保存起来
--    if not G_Me.cityData:isMyCity() then
--        G_HandlersManager.cityHandler:sendCityInfo(0)
--    end
       
end

function CityScene:onSceneExit()
    
    uf_eventManager:removeListenerWithTarget(self)
    
end

function CityScene:onSceneUnload()
    
    -- 释放缓存
    self._cacheLayers:release()
    -- move to ZhengZhanLayer:onLayerLoad
    -- if not G_Me.cityData:isMyCity() then
    --     G_Me.cityData:resetMyCity()
    -- end
    
end

function CityScene:_loadLayer(cityType, ...)
    
    cityType = cityType or CityScene.TYPE_MAIN
    self._cityType = cityType

    -- 公共组件
    if cityType ~= CityScene.TYPE_ADD_LIST then
        self._roleInfo = G_commonLayerModel:getBarRoleInfoLayer()
        self:addUILayerComponent("RoleInfoUI",self._roleInfo,true)
    end
    
    self._speedBar = G_commonLayerModel:getSpeedbarLayer()
    self:addUILayerComponent("SpeedBar", self._speedBar,true)
    
    -- 领主界面
    if cityType == CityScene.TYPE_MAIN then
        
        self._curLayer = self:_loadCityMainLayer(...)
        self:addUILayerComponent("curLayer",self._curLayer,true)
        self._curLayer:setZOrder(-1)
        
        self:adapterLayerHeight(self._curLayer, self._roleInfo, self._speedBar, 0, 0)

    -- 挑战领地界面
    elseif cityType == CityScene.TYPE_CHALLENGE then
        
        self._curLayer = self:_loadCityChallengeMainLayer(...)
        self:addUILayerComponent("curLayer",self._curLayer,true)
        self._curLayer:setZOrder(-1)
        
        self:adapterLayerHeight(self._curLayer, self._roleInfo, nil, 0, 0)

    -- 领地添加巡逻武将界面
    elseif cityType == CityScene.TYPE_ADD then
        
        self._curLayer = self:_loadCityAddMainLayer(...)
        self:addUILayerComponent("curLayer",self._curLayer,true)
        self._curLayer:setZOrder(-1)
        
        self:adapterLayerHeight(self._curLayer, self._roleInfo, nil, 0, 0)

    -- 领地添加巡逻武将界面
    elseif cityType == CityScene.TYPE_ADD_LIST then
        
        self._curLayer = self:_loadCityAddListLayer(...)
        uf_sceneManager:getCurScene():addChild(self._curLayer)
        self._curLayer:setZOrder(-1)

    -- 领地准备巡逻界面
    elseif cityType == CityScene.TYPE_PATROL then
        
        self._curLayer = self:_loadCityPatrolSelectLayer(...)        
        self:addUILayerComponent("curLayer",self._curLayer,true)
        self._curLayer:setZOrder(-1)
        
        self:adapterLayerHeight(self._curLayer, self._roleInfo, nil, 0, 0)

    -- 领地巡逻结果界面
    elseif cityType == CityScene.TYPE_PATROL_STATE then
        
        self._curLayer = self:_loadCityPatrolStateLayer(...)        
        self:addUILayerComponent("curLayer",self._curLayer,true)
        self._curLayer:setZOrder(-1)
        
        self:adapterLayerHeight(self._curLayer, self._roleInfo, nil, 0, 0)

    -- 领地科技界面
    elseif cityType == CityScene.TYPE_TECH then
        self._curLayer = self:_loadCityTechLayer()
        self:addUILayerComponent("curLayer",self._curLayer,true)
        self._curLayer:setZOrder(-1)

        --self:adapterLayerHeight(self._curLayer, nil, self._speedBar, 0, 0)
    end
    
    G_commonLayerModel:setDelayUpdate(false)
    
end

function CityScene:_unloadLayer()
            
    self:removeComponent(SCENE_COMPONENT_GUI, "SpeedBar")
    self:removeComponent(SCENE_COMPONENT_GUI, "RoleInfoUI")
    
    if self._cityType == CityScene.TYPE_ADD_LIST then
        self._curLayer:removeFromParent()
    else
        self:removeComponent(SCENE_COMPONENT_GUI, "curLayer")
    end
    
end

-- 载入领地主界面
function CityScene:_loadCityMainLayer(cityIndex, scenePack)
    
    local layer = self._cacheLayers.get("CityMainLayer") or require("app.scenes.city.CityMainLayer").create(cityIndex)
    if layer then
        layer:initData(cityIndex)
    end

    -- 城池按钮
    local function onCityClick(widget, state)
        
        if not state or state == 2 then
            local name = widget:getName()
            local index = tonumber(string.sub(name, string.len(name), string.len(name)))
            self:_enterCity(index)
        end
    end

    for i=1, G_Me.cityData.MAX_CITY_NUM do
        -- 城池按钮要响应
        layer:registerBtnClickEvent("Button_city"..i, onCityClick)
        -- 冒泡按钮也要响应
        layer:registerWidgetTouchEvent("Image_bubble"..i, onCityClick)
    end
    
    layer:registerBtnClickEvent("Button_back", function()
        local packScene = G_GlobalFunc.packToScene(scenePack)
        if not packScene then 
            packScene = require("app.scenes.mainscene.PlayingScene").new()
        end
        uf_sceneManager:replaceScene(packScene)
    end)
    
    layer:registerBtnClickEvent("Button_back_city", function()
--        if not G_Me.cityData:isMyCity() then
--            G_HandlersManager.cityHandler:sendCityInfo(0)
--        end
        G_Loading:showLoading(function()
            G_Me.cityData:resetMyCity()
        end)
    end)

    -- get awards of all cities once
    layer:registerBtnClickEvent("Button_onekey_harvest", function()
        if G_Me.cityData:needHarvest() then
            CityPatrolAwardLayer.create(0, function()
                uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CITY_INFO, nil, false)
            end)
        else
            G_MovingTip:showMovingTip(G_lang:get("LANG_CITY_NO_AWARD"))
        end
    end)

    -- patrol all cities in one time
    layer:registerBtnClickEvent("Button_onekey_patrol", function()
        CityOneKeyPatrolLayer.show()
    end)

    -- city technology
    layer:registerBtnClickEvent("Button_tech", function()
        self:_unloadLayer()
        self:_loadLayer(CityScene.TYPE_TECH)
    end)
    
    layer:registerBtnClickEvent("Button_friend", function()
        
        -- 没有好友或者没有好友达到32级（挂机开启等级）时
        local friends = G_Me.friendData:getFriendList()
        local _friends = {}
        for i=1, #friends do
            if friends[i].level >= function_level_info.get(require("app.const.FunctionLevelConst").CITY_PLUNDER).level then
                _friends[#_friends+1] = friends[i].id
            end
        end
        
        if #friends == 0 or #_friends == 0 then
            
            -- 弹框提示
            local addLayer = UFCCSModelLayer.new("ui_layout/city_PatrolAddFriendLayer.json", Colors.modelColor)
            uf_sceneManager:getCurScene():addChild(addLayer)
            addLayer:closeAtReturn(true)
            require("app.common.effects.EffectSingleMoving").run(addLayer, "smoving_bounce")
            addLayer:adapterWithScreen()
            
            _updateLabel(addLayer, "Label_add_friend_desc", {text=G_lang:get("LANG_CITY_MAIN_LAYER_ADD_FRIEND_DESC")})
            
            local function _onClose()
                addLayer:animationToClose()
                local soundConst = require("app.const.SoundConst")
                G_SoundManager:playSound(soundConst.GameSound.BUTTON_SHORT)
            end
            
            addLayer:registerBtnClickEvent("Button_close", _onClose)
            addLayer:enableAudioEffectByName("Button_close", false)
            
            addLayer:registerBtnClickEvent("Button_cancel", _onClose)
            
            addLayer:registerBtnClickEvent("Button_certain", function()
                uf_sceneManager:getCurScene():addChild(require("app.scenes.friend.FriendSugListLayer").create())
                addLayer:animationToClose()
            end)
            
        else
            uf_sceneManager:getCurScene():addChild(require("app.scenes.city.CityFriendListLayer").create(function(friend)
                G_Loading:showLoading(function()
                    G_HandlersManager.cityHandler:sendCityInfo(friend.id)
                end)
            end))
        end
        
    end)
    
    self._cacheLayers.add("CityMainLayer", layer)
    
    return layer
end

-- 载入挑战主界面
function CityScene:_loadCityChallengeMainLayer(index)
    
    local layer = self._cacheLayers.get("CityChallengeLayer") or require("app.scenes.city.CityChallengeLayer").create(index)
    if layer then
        layer:initData(index)
    end

    layer:registerBtnClickEvent("Button_back", function()
        self:_unloadLayer()
        self:_loadLayer(CityScene.TYPE_MAIN)
    end)
            
    self._cacheLayers.add("CityChallengeLayer", layer)
    
    return layer
end

-- 载入添加巡逻武将主界面
function CityScene:_loadCityAddMainLayer(index)
    
    local layer = self._cacheLayers.get("CityAddLayer") or require("app.scenes.city.CityAddLayer").create(index)
    if layer then
        layer:initData(index)
    end

    layer:registerBtnClickEvent("Button_back", function()
        self:_unloadLayer()
        self:_loadLayer(CityScene.TYPE_MAIN)
    end)
    
    layer:registerBtnClickEvent("Button_add", function()
        self:_unloadLayer()
        self:_loadLayer(CityScene.TYPE_ADD_LIST, index)
    end)
            
    self._cacheLayers.add("CityAddLayer", layer)
    
    return layer
end

function CityScene:_loadCityAddListLayer(index)
        
    -- 加载可选武将列表
    -- 先获取全部的武将，挑选符合要求的武将
    local knights = {}
    local knightList = clone(G_Me.bagData.knightsData:getKnightsList())

    -- 主角的id
    local base_id = G_Me.bagData.knightsData:getBaseIdByKnightId(G_Me.formationData:getMainKnightId())
    
    -- 查找是否包含此advance_code
    local function _containKnight(advance_code)
        local cityEndEventInfo = city_end_event_info
        for i=1, cityEndEventInfo.getLength() do
            local record = cityEndEventInfo.indexOf(i)
            if record.advance_code == advance_code then
                return true
            end
        end
    end
    
    -- 先按照id和advance_level排序，便于以后索引
    table.sort(knightList, function(a, b)
        local aConfig = knight_info.get(a.base_id)
        local bConfig = knight_info.get(b.base_id)
        return aConfig.advance_code == bConfig.advance_code and aConfig.advanced_level > bConfig.advanced_level or aConfig.id < bConfig.id
    end)

    for key, knight in pairs(knightList) do
        -- 资质大于4，不是主角， 按照advance_code > levciel > 上阵 > 随便
        local advance_code = knight_info.get(knight.base_id).advance_code

        if _containKnight(advance_code) and knight.base_id ~= base_id then
            local oldKnight = knights[advance_code]
            if oldKnight then
                if knight.level > oldKnight.level then
                    knights[advance_code] = knight
                    knight.potential = knight_info.get(knight.base_id).potential
                elseif knight.level == oldKnight.level then
                    local knightUp = G_Me.formationData:getKnightTeamId(knight.id)
                    local oldKnightUp = G_Me.formationData:getKnightTeamId(oldKnight.id)
                    if knightUp > oldKnightUp then
                        knights[advance_code] = knight
                        knight.potential = knight_info.get(knight.base_id).potential
                    end
                end
            else
                knights[advance_code] = knight
                knight.potential = knight_info.get(knight.base_id).potential
            end
        end
    end
    
    local _knights = {}
    for k, knight in pairs(knights) do
        _knights[#_knights+1] = knight
    end
    
    knights = _knights
    
    -- 把巡逻中的单独抽出来，再按照一定规则排序,然后组合在一起
    local _knightsA = {}
    local _knightsB = {}
    for i=1, #knights do
        if G_Me.cityData:isPatrollingThisKnight(knights[i].base_id) then
            _knightsA[#_knightsA+1] = knights[i]
        else
            _knightsB[#_knightsB+1] = knights[i]
        end
    end

    -- 排序优先级：上阵武将 > 上阵武将同阵营 > 资质 > ID
    local knightNumOfGroup = G_Me.formationData:getMainTeamCountryIds()
    local sortFunc = function (a, b)
        local infoA = knight_info.get(a.base_id)
        local infoB = knight_info.get(b.base_id)

        -- 上阵武将
        local isAInTeam = G_Me.formationData:hasKnightOnTeam(infoA.advance_code, 1)
        local isBInTeam = G_Me.formationData:hasKnightOnTeam(infoB.advance_code, 1)

        if isAInTeam ~= isBInTeam then
            return isAInTeam
        end

        -- 上阵武将同阵营
        if infoA.group ~= infoB.group then
            numA = knightNumOfGroup[infoA.group]
            numB = knightNumOfGroup[infoB.group]

            if numA and numB then
                return numA > numB
            elseif numA or numB then
                return numA ~= nil
            end
        end

        -- 资质
        if a.potential ~= b.potential then
            return a.potential > b.potential
        end

        -- 阵营
        if infoA.group ~= infoB.group then
            return infoA.group < infoB.group
        end

        -- ID
        return infoA.advance_code < infoB.advance_code
    end
    
    -- 排序，按照资质从大到小排序，资质一致则根据等级从大到小排序，等级一致则根据ID从小到大排序
    table.sort(_knightsA, sortFunc)
    table.sort(_knightsB, sortFunc)
    
    for i=1, #_knightsA do
        _knightsB[#_knightsB+1] = _knightsA[i]
    end
    
    knights = _knightsB
    
    local layer = self._cacheLayers.get("CityAddListLayer") or require("app.scenes.city.CityAddListLayer").create(knights, nil, index, function()
        local selectKnights = self._curLayer:getSelecteds()
        self:_unloadLayer()
        self:_loadLayer(CityScene.TYPE_PATROL, self._curLayer:getCityIndex(), selectKnights[1])
    end,
    function()
        self:_unloadLayer()
        self:_loadLayer(CityScene.TYPE_ADD, self._curLayer:getCityIndex())
    end)
    
    if layer then
        layer:initData(knights, nil, index)
    end
    
    self._cacheLayers.add("CityAddListLayer", layer)
    
    return layer
    
end

-- 载入巡逻武将选择主界面
function CityScene:_loadCityPatrolSelectLayer(index, knight)
    
    local layer = self._cacheLayers.get("CityPatrolSelectLayer") or require("app.scenes.city.CityPatrolSelectLayer").create(index, knight)
    
    if layer then
        layer:initData(index, knight, function()
            self:_unloadLayer()
            self:_loadLayer(CityScene.TYPE_PATROL_STATE, index)
        end)
    end
    
    layer:registerBtnClickEvent("Button_back", function()
        self:_unloadLayer()
        self:_loadLayer(CityScene.TYPE_MAIN)
    end)
        
    layer:registerWidgetTouchEvent("Panel_switch_head", function(widget, state)
        if state == 2 and not layer:isPatrolling() then
            self:_unloadLayer()
            self:_loadLayer(CityScene.TYPE_ADD_LIST, index)
        end
    end)
    
    self._cacheLayers.add("CityPatrolSelectLayer", layer)
        
    return layer
end

-- 载入巡逻中主界面
function CityScene:_loadCityPatrolStateLayer(index)
    local layer = self._cacheLayers.get("CityPatrolStateLayer") or require("app.scenes.city.CityPatrolStateLayer").create(index)
    if layer then
        layer:initData(index)
    end
    
    layer:registerBtnClickEvent("Button_back", function()
        self:_unloadLayer()
        self:_loadLayer(CityScene.TYPE_MAIN)
    end)
    
    -- 领取按钮
    layer:registerBtnClickEvent("Button_get_award", function()
        CityPatrolAwardLayer.create(index, function()
            if self and self._unloadLayer then
                self:_unloadLayer()
                self:_loadLayer(CityScene.TYPE_MAIN)
            end
        end)
    end)
    
    self._cacheLayers.add("CityPatrolStateLayer", layer)
    
    return layer
    
end

-- 载入领地科技界面
function CityScene:_loadCityTechLayer()
    local jumpCallback = function(index)
        self:_enterCity(index)
    end

    local layer = self._cacheLayers.get("CityTechLayer") or require("app.scenes.city.CityTechLayer").create(jumpCallback)

    layer:registerBtnClickEvent("Button_Back", function()
        self:_unloadLayer()
        self:_loadLayer(CityScene.TYPE_MAIN)
    end)

    self._cacheLayers.add("CityTechLayer", layer)

    return layer
end

-- 进入城池
function CityScene:_enterCity(index)
    local city = G_Me.cityData:getCityByIndex(index)
    local state = city.state
            
    -- 未解锁
    if G_Me.cityData:isMyCity() and city.isLock then
        G_MovingTip:showMovingTip(G_lang:get("LANG_CITY_MAIN_LAYER_UNLOCK_CITY_DESC", {city=city_info.get(index-1).name}))
        -- 可攻打
    elseif G_Me.cityData:isMyCity() and state == G_Me.cityData.CITY_NEED_ATTACK then
        self:_unloadLayer()
        self:_loadLayer(CityScene.TYPE_CHALLENGE, index)
        -- 尚未添加巡逻人
    elseif G_Me.cityData:isMyCity() and state == G_Me.cityData.CITY_NEED_PATROL then
        self:_unloadLayer()
        self:_loadLayer(CityScene.TYPE_ADD, index)
        -- 巡逻中
    elseif state == G_Me.cityData.CITY_PATROLLING then
        self:_unloadLayer()
        self:_loadLayer(CityScene.TYPE_PATROL_STATE, index)
        -- 可丰收或出现暴动
    elseif state == G_Me.cityData.CITY_HARVEST or state == G_Me.cityData.CITY_RIOT then
        if G_Me.cityData:isMyCity() or state == G_Me.cityData.CITY_RIOT then
            self:_unloadLayer()
            self:_loadLayer(CityScene.TYPE_PATROL_STATE, index)
        elseif not G_Me.cityData:isMyCity() then
            G_MovingTip:showMovingTip(G_lang:get("LANG_CITY_MAIN_LAYER_UNLOCK_FRIEND_CITY_DESC"))
        end
    elseif not G_Me.cityData:isMyCity() then
        G_MovingTip:showMovingTip(G_lang:get("LANG_CITY_MAIN_LAYER_UNLOCK_FRIEND_CITY_DESC"))
    end
end

return CityScene