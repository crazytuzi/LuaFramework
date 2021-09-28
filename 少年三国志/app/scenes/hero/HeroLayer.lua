--HeroLayer.lua


local KnightConst = require("app.const.KnightConst")
local funLevelConst = require("app.const.FunctionLevelConst")
local EffectNode = require "app.common.effects.EffectNode"
local AttributeConst = require("app.const.AttributesConst")
local EquipmentConst = require("app.const.EquipmentConst")
local HeroGodCommon = require "app.scenes.herofoster.god.HeroGodCommon"

require("app.cfg.pet_info")

local HeroLayer = class("heroArray", UFCCSNormalLayer)

function HeroLayer:ctor( sonFile, func, heroIndex, isToFriendLayer,... )
	self._curKnightId = 0
    self._curKnightBaseId = 0
	self._heroPageView = nil
	self._curHeroIndex = heroIndex or 1
    self._isToFriendLayer = isToFriendLayer
	self._testText = ""
    self._equipStrengthShow = false
	self._sceneIsEnter = false
	self._activeAssociationArr = {}
	self._associationChange = {}
    self._knightAttriCtrls = {}
    self._knightAttris = {}
    self._oldKnightAttr1 = nil
    self._selectKnightBack = nil
    self._knightScrollView = nil
    self._partnerLayer = nil

    self._shouldMoveWithPage = false
    self._startMoveX = 0
    self._hasCreatePage = false

    self._initBaseInfoPt = ccp(0, 0)
    self._initEquipPt = ccp(0, 0)
    self._baseInfoPanel = nil 
    self._equipPanel = nil
    self._lastPlayAudio = nil

    self._equipList = {}
    self._treasureList = {}
    self._petList = {}

    self._curTimeCost = 0

    self._curHeroCount = 0
    self._knightAttri1 = {}
    self._effectEquipTips = {}

    self._curEquipStrengthTargetId = 0
    self._curEquipJinglianTargetId = 0
    self._curTreasureStrengthTargetId = 0
    self._curTreasureJinglianTargetId = 0

    self._isMovingStatus = false
    self._touchPageView = false
    self._oldPageIndex = 0
    self._allElements = nil
    self._elementVisibleStatus = {}

    self._chongwuUnlock = true
    self._timer = nil -- 换装icon在时间结束后自动消失 
    self.super.ctor(self, sonFile, func, heroIndex, ...)
end

function HeroLayer:updateTimeHandler()
    if G_Me.userData:getClothTime() <= 0 then 
        if self._timer then
            GlobalFunc.removeTimer(self._timer)
        end
        self:_updatePageWithIndex(0)
        self:showWidgetByName("Button_bianshen",false)
        local heroImage = self:getImageViewByName("ImageView_MainHero")
        if heroImage then 
            heroImage:loadTexture(G_Path.getKnightIcon(G_Me.dressData:getDressedPic()), UI_TEX_TYPE_LOCAL)
        end
    end 
end 

function HeroLayer:onLayerLoad( jsonFile, func, heroIndex, ... )
    if not self._timer  and G_Me.userData:getClothTime() > 0 then 
        self._timer = GlobalFunc.addTimer(1, function()  
            if self.updateTimeHandler then 
                self:updateTimeHandler()
            end 
        end)
    end 

    local label = self:getLabelByName("Label_name")
    if label then 
        label:setSize(CCSizeMake(240, 35))
        label:setTextAreaSize(CCSizeMake(240, 35))
    end

	self._curHeroCount = G_Me.formationData:getFormationHeroCount()

    self:enableLabelStroke("Label_name", Colors.strokeBrown, 2 )
    self:enableLabelStroke("Label_zizhi", Colors.strokeBrown, 2 )
    --self:enableLabelStroke("Label_level_value", Colors.strokeBrown, 1 )
    -- self:enableLabelStroke("Label_attack_value", Colors.strokeBrown, 1 )
    -- self:enableLabelStroke("Label_def_wuli_value", Colors.strokeBrown, 1 )
    -- self:enableLabelStroke("Label_hp_value", Colors.strokeBrown, 1 )
    -- self:enableLabelStroke("Label_def_mofa_value", Colors.strokeBrown, 1 )
    -- self:enableLabelStroke("Label_skill_1", Colors.strokeBrown, 1 )
    -- self:enableLabelStroke("Label_skill_2", Colors.strokeBrown, 1 )
    -- self:enableLabelStroke("Label_skill_3", Colors.strokeBrown, 1 )
    -- self:enableLabelStroke("Label_skill_4", Colors.strokeBrown, 1 )
    -- self:enableLabelStroke("Label_skill_5", Colors.strokeBrown, 1 )
    -- self:enableLabelStroke("Label_skill_6", Colors.strokeBrown, 1 )
    self:showWidgetByName("Panel_stars", false)
    self:showWidgetByName("ImageView_country", false)

    local createStoke = function ( name )
        local label = self:getLabelByName(name)
        if label then 
            label:createStroke(Colors.strokeBrown, 2)
        end
    end
    createStoke("Label_16")
    createStoke("Label_zuhe")
    --createStoke("Label_level_name")
    -- createStoke("Label_attack")
    -- createStoke("Label_hp")
    -- createStoke("Label_def_wuli")
    -- createStoke("Label_def_mofa")
    self._knightScrollView = self:getScrollViewByName("ScrollView_knight_list")

--self:showWidgetByName("Panel_HeroPanel", false)

    self:_initHeroPanel()
    self:_initHeroPageView()
    -- self:callAfterFrameCount(2, function ( ... )
    -- 	if self and self._loadHeroPage then 
    --     	self:_loadHeroPage()
    --     end
    -- end)

    table.insert(self._knightAttriCtrls, #self._knightAttriCtrls + 1, self:getWidgetByName("Label_attack_value"))
    table.insert(self._knightAttriCtrls, #self._knightAttriCtrls + 1, self:getWidgetByName("Label_hp_value"))
    table.insert(self._knightAttriCtrls, #self._knightAttriCtrls + 1, self:getWidgetByName("Label_def_wuli_value"))
    table.insert(self._knightAttriCtrls, #self._knightAttriCtrls + 1, self:getWidgetByName("Label_def_mofa_value"))
 
    local bg = self:getImageViewByName("ImageView_back")
    if bg then 
        bg:loadTexture(G_GlobalFunc.isNowDaily() and "ui/background/back_zrbt.png" or "ui/background/back_zrhy.png")
    end

    self:getWidgetByName("Panel_left"):setZOrder(2)
   -- self:_blurEquipStrength()
end

function HeroLayer:onLayerEnter( )
    self:_initKnightList()
    local knightId, baseId = G_Me.formationData:getTeamKnightIdAndBaseIdByIndex(1, self._curHeroIndex)
    if not self._layerIsEnter then
        -- local effect  = EffectNode.new("effect_zrjm")
        -- effect:play()
        -- self:getWidgetByName("ImageView_back"):addNode(effect)

        -- Ã©Â¦â€“Ã¦Â¬Â¡Ã¨Â¿â€ºÃ¥â€¦Â¥Ã¦â€”Â¶Ã¯Â¼Å’Ã¥â€¦Ë†Ã¥Å Â Ã¨Â½Â½Ã¥Â½â€œÃ¥â€°ÂÃ©â‚¬â€°Ã¥Â®Å¡Ã§Å¡â€žÃ¦Â­Â¦Ã¥Â°â€ Ã¥ÂÅ Ã¥â€¦Â¶Ã¨Â£â€¦Ã¥Â¤â€¡Ã¥â€™Å’Ã¥Â±Å¾Ã¦â‚¬Â§Ã¦â€¢Â°Ã¦Â?
        
        if knightId > 0 then 
            --self:_onSwitchToHeroPage(knightId)
            self:_updateKnightSkillList(knightId)
            self:_udpateKnightAttributes(knightId)
            self:_loadFightResourcesForKnight( 1, self._curHeroIndex)
        else
            self:showWidgetByName("Button_dress", false)
            self:showWidgetByName("Button_bianshen", false)
            self:showWidgetByName("Button_change", false)
        end

        local strengthEquip = self:getWidgetByName("Button_strength")
        local showStatus = true
        if strengthEquip then 
            showStatus = strengthEquip:isVisible()

            local effect  = EffectNode.new("effect_StrengthenMasterIcon")
            effect:play()
            strengthEquip:addNode(effect)
            --local panelSize = strengthEquip:getSize()
           -- effect:setPosition(ccp(panelSize.width/2, panelSize.height/2))
        end
        local changeStatus = false
        local changeBtn = self:getWidgetByName("Button_change")
        if changeBtn and changeBtn:isVisible() then 
            changeStatus = true
        end
        local dressStatus = false
        local dressBtn = self:getWidgetByName("Button_dress")
        if dressBtn and dressBtn:isVisible() then 
            dressStatus = true
        end

        if self._curHeroIndex < 7 then
        self:showWidgetByName("Panel_left", false)
        self:showWidgetByName("Image_skill", false)
        self:showWidgetByName("Panel_right", false)
        self:showWidgetByName("Button_1", false)
        self:showWidgetByName("Button_2", false)
        self:showWidgetByName("Button_3", false)
        self:showWidgetByName("Button_4", false)
        self:showWidgetByName("Button_5", false)
        self:showWidgetByName("Button_6", false)
        self:showWidgetByName("Button_7", false)
        self:showWidgetByName("Image_paper", false)
        self:showWidgetByName("Button_strength", false)
        self:showWidgetByName("Button_dress", false)
        self:showWidgetByName("Button_bianshen", false)
        self:showWidgetByName("Button_change", false)
        self:showWidgetByName("ScrollView_knight_list", false)
        self:callAfterFrameCount(1, function ( ... )
            --self:showWidgetByName("Image_baseinfo", true)
            self:showWidgetByName("Panel_left", true)
            self:showWidgetByName("Image_skill", true)
            self:showWidgetByName("Panel_right", true)
            self:showWidgetByName("Button_1", true)
            self:showWidgetByName("Button_2", true)
            self:showWidgetByName("Button_3", true)
            self:showWidgetByName("Button_4", true)
            self:showWidgetByName("Button_5", true)
            self:showWidgetByName("Button_6", true)
            self:showWidgetByName("Button_7", true)
            self:showWidgetByName("Image_paper", true)
            self:showWidgetByName("Button_strength", true)
            if changeStatus then
                self:showWidgetByName("Button_change", changeStatus)
            end
            if dressStatus then
                self:showWidgetByName("Button_dress", dressStatus)
            end
            -- self:showWidgetByName("Button_dress", true)

            GlobalFunc.flyIntoScreenLR({self:getWidgetByName("Button_1"), 
                self:getWidgetByName("Button_4"), 
                self:getWidgetByName("Button_5"), 
                self:getWidgetByName("Button_strength")}, true, 0.2, 5, 50)

            GlobalFunc.flyIntoScreenLR({self:getWidgetByName("Button_3"), 
                self:getWidgetByName("Button_2"), 
                self:getWidgetByName("Button_6"),
                self:getWidgetByName("Button_dress"), 
                self:getWidgetByName("Button_change"),
                self:getWidgetByName("Button_7")}, false, 0.2, 5, 50)

            self:showWidgetByName("ScrollView_knight_list", true)
            GlobalFunc.flyIntoScreenLR({self:getWidgetByName("ScrollView_knight_list")}, false, 0.2, 2, nil)
            GlobalFunc.flyIntoScreenLR({self:getWidgetByName("ImageView_back_main")}, true, 0.2, 2, nil)
           -- GlobalFunc.flyFromMiddleToSize(self:getWidgetByName("Image_paper"), 0.3, 0.1, function ( ... )
            --end)
            GlobalFunc.flyIntoScreenLR({self:getWidgetByName("Image_baseinfo"), 
                    self:getWidgetByName("Panel_left")}, true, 0.2, 2, 50)
                GlobalFunc.flyIntoScreenLR({self:getWidgetByName("Image_skill"), 
                    self:getWidgetByName("Panel_right")}, false, 0.2, 1, 50, function ( ... )
                    	self:_onFinishAnimation()
                    end)
        end)
        else 
            self:_onFinishAnimation()
            if self._curHeroIndex >= 7 then 
                self:_showAllElement(false, false)
            end
        end
        if require("app.scenes.mainscene.SettingLayer").showEffectEnable() then
            G_GlobalFunc.showDayEffect(G_Path.DAY_NIGHT_EFFECT.KNIGHT_ARRAY, self:getWidgetByName("ImageView_back"))
        end
	else
        local stopAction = function ( ctrlName )
            if type(ctrlName) ~= "string" then 
                return 
            end

            local ctrl = self:getWidgetByName(ctrlName)
            if ctrl then 
                ctrl:stopAllActions()
            end
        end
        stopAction("Button_1")
        stopAction("Button_2")
        stopAction("Button_3")
        stopAction("Button_4")
        stopAction("Button_5")
        stopAction("Button_6")
        stopAction("Button_7")
        stopAction("ImageView_back_main")
        stopAction("Image_baseinfo")
        stopAction("Panel_left")
        stopAction("Image_skill")
        stopAction("Panel_right")
        local sortChildren = function ( name )
            local layout = self:getPanelByName(name)
            if layout then 
                layout:requestDoLayout()
            end
        end
        sortChildren("Image_baseinfo")
        sortChildren("Panel_left")
        sortChildren("Image_skill")
        sortChildren("Panel_right")

        -- Ã¥Â½â€œÃ¤Â»Å½Ã¥â€¦Â¶Ã¥Â®Æ’Ã§â€¢Å’Ã©ÂÂ¢Ã¨Â¿â€Ã¥â€ºÅ¾Ã¥Ë†Â°Ã©ËœÂµÃ¥Â®Â¹Ã¦â€”Â¶Ã¯Â¼Å’Ã¨Â¦ÂÃ¦Â£â‚¬Ã¦Å¸Â¥Ã¦ËœÂ¯Ã¥ÂÂ¦Ã¦Å“â€°Ã¥Â±Å¾Ã¦â‚¬Â§Ã¥â‚¬Â¼Ã¥ÂËœÃ¥Å?
        self:_doFlyKnightAttributes()
        self._activeAssociationArr = nil
        -- Ã¥Â½â€œÃ¤Â»Å½Ã¥â€¦Â¶Ã¥Â®Æ’Ã§â€¢Å’Ã©ÂÂ¢Ã¨Â¿â€Ã¥â€ºÅ¾Ã¥Ë†Â°Ã©ËœÂµÃ¥Â®Â¹Ã¦â€”Â¶Ã¯Â¼Å’Ã¨Â¦ÂÃ©â€¡ÂÃ¦â€“Â°Ã¥Å Â Ã¨Â½Â½Ã¨Â£â€¦Ã¥Â¤â€¡Ã¥â€™Å’Ã¥Â®ÂÃ§â€°Â©Ã¦â€¢Â°Ã¦ÂÂ®Ã¯Â¼Å’Ã¥â€ºÂ Ã¤Â¸ÂºÃ¦Å“â€°Ã¥ÂÂ¯Ã¨Æ’Â½Ã¥Ââ€˜Ã§â€Å¸Ã¤Âºâ€ Ã¥Ââ€žÃ§Â§ÂÃ¥Å¸Â¹Ã¥â€¦Â»Ã¨Â¿â€¡Ã§Â¨â€?
		self:_loadFightResourcesForKnight( (self._curHeroIndex > 6) and 2 or 1, self._curHeroIndex > 6 and (self._curHeroIndex - 6) or self._curHeroIndex)

        self:callAfterFrameCount(1, function ( ... ) 
            if self._baseInfoPanel then 
                self._baseInfoPanel:setPosition(self._initBaseInfoPt)
            end

            if self._equipPanel then 
                self._equipPanel:setPosition(self._initEquipPt)
            end
        end)
	end

    self:showWidgetByName("ImageView_type", false)
    self:callAfterFrameCount(1, function ( ... )
        if knightId > 0 then 
            self:_onSwitchToHeroPage(knightId, not self._layerIsEnter)
        end
        self:showWidgetByName("ImageView_type", true)
    end)

    if self._curHeroIndex == 7 and self._petLayer then 
        self._petLayer:onLayerTurn()
    end
    -- Ã¥Â¤â€¡Ã¤Â»Â½Ã¥Â½â€œÃ¥â€°ÂÃ¦Â­Â¦Ã¥Â°â€ Ã¨ÂºÂ«Ã¤Â¸Å Ã§Å¡â€žÃ¨Â£â€¦Ã¥Â¤â€¡Ã¥â€™Å’Ã¥Â®ÂÃ§â€°Â©Ã¦â€¢Â°Ã¦ÂÂ®Ã¯Â¼Å’Ã¤Â»Â¥Ã¤Â¾Â¿Ã¥ÂÅ¡Ã§ÂºÂ¢Ã§â€šÂ¹Ã¨Â®Â¡Ã§Â®â€?
    self:_updateEquipList({1, 2, 3, 4, 5, 6, 7})
	self._layerIsEnter = true  

    self:_startSchedule()

    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_FORMATION_UPDATE, self._onFormationUpdate, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_PET_CHANGE, self._loadPetIcon, self) 
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CHANGE_TEAM_FORMATION, self._onChangeTeamFormation, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_ADD_TEAM_KNIGHT, self._onAddTeamKnight, self)

    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_RECEIVE_ADD_FIGHT_EQUIPMENT, self._onAddFightEquipment, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_RECEIVE_CLEAR_FIGHT_EQUIPMENT, self._onClearFightEquipment, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_RECEIVE_ADD_FIGHT_TREASURE, self._onAddFightTreasure, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_RECEIVE_CLEAR_FIGHT_TREASURE, self._onClearFightTreasure, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_SET_PET_PRITECT, self._onSetPetProtect, self)
    
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_SKILLTREE_LIST, self._updateMainKnightSkillList, self)
end

function HeroLayer:_startSchedule( ... )
    self._curTimeCost = 0 
    self:scheduleUpdate(handler(self, self._onUpdate), 0)
end

function HeroLayer:_stopSchedule( ... )
    self:unscheduleUpdate()
    self._curTimeCost = 0
end

function HeroLayer:_onUpdate( dt )
    self._curTimeCost = self._curTimeCost + dt
    
    if self._curTimeCost > 10 then 
        self._curTimeCost = 0
        self:_onWaitForLongTime()
    end    
end

function HeroLayer:_resetWaitRecord( ... )
    self._curTimeCost = 0
end

function HeroLayer:_onWaitForLongTime( ... )
    if self._curHeroIndex <= 6 then
        self:_playAudioWithKnightBaseId(self._curKnightBaseId)
    end
end

-- Ã©Â¦â€“Ã¦Â¬Â¡Ã¨Â¿â€ºÃ¥â€¦Â¥Ã¦â€”Â¶Ã¯Â¼Å’Ã¦â€™Â­Ã¥Â®Å’Ã¥Å Â¨Ã§â€Â»Ã¥ÂÅ½Ã¥â€ ÂÃ¦Å Å Ã¥Â½â€œÃ¥â€°ÂÃ©â‚¬â€°Ã¥Â®Å¡Ã§Å¡â€žÃ¤ÂºÂºÃ§â€Â¨Ã¥Å Â¨Ã§â€Â»Ã¦Å½â€°Ã¤Â¸â€¹Ã¦ÂÂ¥Ã¯Â?
-- Ã¨Â¿â„¢Ã¦Â Â·Ã¨Æ’Â½Ã©Æ’Â¨Ã¥Ë†â€ Ã§Â¼â€œÃ¥â€™Å’Ã¨Â¿â€ºÃ¥â€¦Â¥Ã¦â€”Â¶Ã¥â€¦Â¨Ã©Æ’Â¨Ã¥ÂÅ’Ã¦â€”Â¶Ã¥Å Â Ã¨Â½Â½Ã§Å¡â€žÃ¥ÂÂ¡Ã©Â¡Â¿Ã©â€”Â®Ã©Â?
function HeroLayer:_onFinishAnimation( ... )
    self._baseInfoPanel = self:getWidgetByName("Panel_baseinfo")
    if self._baseInfoPanel then 
        self._initBaseInfoPt = ccp(self._baseInfoPanel:getPosition())
    end
    self._equipPanel = self:getWidgetByName("equip")
    if self._equipPanel  then 
            self._initEquipPt = ccp(self._equipPanel:getPosition())
    end
    --self:showWidgetByName("Button_strength", G_Me.formationData:isFullEquipForPos(1, self._curHeroIndex))

    local knightId = G_Me.formationData:getKnightIdByIndex(1, self._curHeroIndex)
    self:_dropNewKnight(knightId, function (  )
        if self and self._loadHeroPage then 
            self:_loadHeroPage()
        end
        --self:showWidgetByName("Panel_stars", true)
    end)
end

function HeroLayer:doAdapterWidget( ... )
	self:adapterWidgetHeight("equip_panel", "Panel_knights", "Panel_baseinfo", 0, 15)
end

function HeroLayer:onLayerExit(  )
    self:_udpateKnightAttributes(self._curKnightId)
    self:_onSwitchToHeroPage(self._curKnightId)
    self:_stopSchedule()
    uf_eventManager:removeListenerWithTarget(self)
end

function HeroLayer:onLayerUnload()
    if self._timer then
        GlobalFunc.removeTimer(self._timer)
    end
	if self._partnerLayer then 
		self._partnerLayer:release()
		self._partnerLayer = nil
	end
            if self._petLayer then 
                self._petLayer:release()
                self._petLayer = nil
            end
end

function HeroLayer:_updateEquipList( slot )
    slot = slot or {}
    for key, value in pairs(slot) do 
        if value >= 1 and value <= 4 then 
            self._equipList[value] = G_Me.bagData:getEquipmentListByType( value )
        end

        if value >= 5 and value <= 6 then 
            self._treasureList[value - 4] = G_Me.bagData:getTreasureListByType( value - 4 )
        end

        if value == 7 then
            self._petList = G_Me.bagData.petData:getPetList()
        end
    end

    -- Ã¨Â£â€¦Ã¥Â¤â€?Ã¥Â®ÂÃ§â€°Â©Ã§ÂºÂ¢Ã§â€šÂ¹Ã¨Â®Â¡Ã§Â®â€?
    self:_checkEffectEquip( slot )
end

function HeroLayer:_checkEffectEquip( slot )
    slot = slot or {}

    local checkEquip = function ( slotId )
        if not slotId or slotId < 1 or slotId > 4 then 
            return false
        end

        local equiplist = self._equipList[slotId] or {}
        local wearEquip = G_Me.formationData:getFightEquipmentList(slotId)
        local fightEquipment = G_Me.formationData:getFightEquipmentBySlot(1, self._curHeroIndex, slotId)
        local baseQuality = 0
        if fightEquipment > 0 then      
            local equipmentInfo = G_Me.bagData.equipmentList:getItemByKey(fightEquipment)
            if equipmentInfo then
                local baseInfo = equipment_info.get(equipmentInfo["base_id"])
                if baseInfo then
                    baseQuality = baseInfo.quality
                end
            end
        end

        for key, value in pairs(equiplist) do 
            if value and not wearEquip[value["id"]] then
                local baseInfo = equipment_info.get(value["base_id"]) or nil 
                if baseInfo and baseInfo.quality > baseQuality then 
                    return true
                end
            end
        end

        return false
    end

    local checkTreasure = function ( slotId )
        if not slotId or slotId < 5 or slotId > 6 then 
            return false
        end

        slotId = slotId - 4
        local treasurelist = self._treasureList[slotId] or {}
        local wearEquip = G_Me.formationData:getFightTreasureList(slotId)
        local fightEquipment = G_Me.formationData:getFightTreasureBySlot(1, self._curHeroIndex, slotId)
        local baseQuality = 0

        --dump(_treasurelist)
        --dump(fightEquipment)
        --dump(wearEquip)

        if fightEquipment > 0 then      
            local treasureInfo = G_Me.bagData.treasureList:getItemByKey(fightEquipment)
            if treasureInfo then
                local baseInfo = treasure_info.get(treasureInfo["base_id"])
                if baseInfo then
                    baseQuality = baseInfo.quality
                end
            end
        end

        for key, value in pairs(treasurelist) do 
            if value and not wearEquip[value["id"]] then
                local baseInfo = treasure_info.get(value["base_id"]) or nil 
                if baseInfo and baseInfo.quality > baseQuality then 
                    return true
                end
            end
        end

        return false
    end

    local checkPet = function (slotId)

        local baseFightValue = 0
        local protectPetId = G_Me.formationData:getProtectPetIdByPos(self._curHeroIndex)

        if protectPetId > 0 then

            local petInfo = G_Me.bagData.petData:getPetById(protectPetId)
            baseFightValue = petInfo.fight_value or 0
        else

            if not G_Me.formationData:canShangZhenProtectPet() then
                return false
            end
        end

        local fightPetId = G_Me.bagData.petData:getFightPetId()
        for k, v in pairs(self._petList) do

            if v.id ~= fightPetId and not G_Me.formationData:isProtectPetByPetId(v.id) 
                and not G_Me.formationData:isSampleNameProtectPetByPetIdExclusivePosId(v.id, self._curHeroIndex) then
                if v.fight_value > baseFightValue then
                    return true
                end
            end
        end

        
        return false

    end

    local funLevelConst = require("app.const.FunctionLevelConst")
    local unlockTreasure = G_moduleUnlock:isModuleUnlock(funLevelConst.TREASURE_COMPOSE)

    for key, value in pairs(slot) do 
        if value >= 1 and value <= 4 then
            self._effectEquipTips[value] = checkEquip(value)
            self:showWidgetByName("Image_dot_"..value, self._effectEquipTips[value])             
        end

        if value >= 5 and value <= 6 and unlockTreasure then 
            self._effectEquipTips[value] = checkTreasure(value)
            self:showWidgetByName("Image_dot_"..value, self._effectEquipTips[value])
        end
        if value == 7 then
            self._effectEquipTips[value] = checkPet(value)
            self:showWidgetByName("Image_dot_7", self._effectEquipTips[value])
        end
    end
end

function HeroLayer:_updatePageWithIndex( index )
    local pageItem = self._heroPageView:getPageCell(index)
    if pageItem and pageItem.initPageItem then 
        pageItem:initPageItem(index + 1, self, 1)
    end
end

function HeroLayer:_doFlyKnightAttributes( ... )
    -- Ã¥Â¦â€šÃ¦Å¾Å“Ã¥Â½â€œÃ¥â€°ÂÃ¥Â®ÂÃ§â€°Â©Ã¥Â¼ÂºÃ¥Å’â€“Ã§â€¢Å’Ã©ÂÂ¢Ã¦ËœÂ¾Ã§Â¤ÂºÃ¥Å“Â¨Ã¯Â¼Å’Ã¥Â°Â±Ã¤Â¸ÂÃ§â€Â¨Ã¥ÂÅ¡Ã¥Â±Å¾Ã¦â‚¬Â§Ã©Â£Å¾Ã¨Â¡Å’Ã¤Âºâ€ Ã¯Â¼Å’Ã§â€ºÂ´Ã¦Å½Â¥Ã¦â€ºÂ´Ã¦â€“Â°Ã¥Â±Å¾Ã¦â‚¬Â§Ã¥â‚?
    if self._equipStrengthShow then 
        self:_updatePageWithIndex(self._curHeroIndex - 1)
        self:_udpateKnightAttributes(self._curKnightId)
        self:_onSwitchToHeroPage(self._curKnightId)

        self:_addEquipTreasureTargetChange(true, true)
        --self:_addEquipTreasureTargetChange(false, true)
    else
        self:_addEquipTreasureTargetChange(true)
        --self:_addEquipTreasureTargetChange(false)

        local attri1 = self._knightAttri1
        local attributeLevel1 = G_Me.bagData.knightsData:getKnightAttr1(self._curKnightId)
        G_flyAttribute.addKnightAttri1Change(attri1, attributeLevel1, self._knightAttriCtrls)
        self._knightAttri1 = attributeLevel1
        local knightChanged = false
        local knightInfo = G_Me.bagData.knightsData:getKnightByKnightId(self._curKnightId)
        if knightInfo and knightInfo["base_id"] ~= self._curKnightBaseId then 
            local curKnightInfo = knight_info.get(knightInfo["base_id"])
            local lastKnightInfo = knight_info.get(self._curKnightBaseId)
            if curKnightInfo and lastKnightInfo and curKnightInfo.advanced_level ~= lastKnightInfo.advanced_level then 
                knightChanged = true
                G_flyAttribute.addAttriChange(G_lang:get("LANG_JINGJIE_TITLE"), 
                    curKnightInfo.advanced_level - lastKnightInfo.advanced_level, self:getLabelByName("Label_zizhi"))
            end
        end

        if self._curHeroIndex < 7 then
            G_flyAttribute.play(function ( ... )
                if self.__EFFECT_FINISH_CALLBACK__ then 
                    self.__EFFECT_FINISH_CALLBACK__(...)
                end
                if knightChanged then 
                    self:_updatePageWithIndex(self._curHeroIndex - 1)
                end
                self:_udpateKnightAttributes(self._curKnightId)
                self:_onSwitchToHeroPage(self._curKnightId)
            end)
        else
            G_flyAttribute.cancelFlyAttributes()
        end
    end
       
    self:_updateKnightSkillList(self._curKnightId)
end

function HeroLayer:_onChangeTeamFormation( ret, team, pos, oldKnightId, newKnightId )
    local knightId, baseId = G_Me.formationData:getTeamKnightIdAndBaseIdByIndex(team, pos)
    self:_playAudioWithKnightBaseId(baseId)

	if team ~= 1 then 
		return 
	end
	if ret == NetMsg_ERROR.RET_OK then
		self._oldKnightAttr1 = self._knightAttris[pos]
        self:_loadKnightIcon(pos)
        self:_playRoundAtKnight(pos)

        -- Ã¥Â¦â€šÃ¦Å¾Å“Ã¥Â½â€œÃ¥â€°ÂÃ¦ËœÂ¯Ã¤Â¸ÂÃ¦ËœÂ¯Ã¥Å“Â¨Ã¥Â°ÂÃ¤Â¼â„¢Ã¤Â¼Â´Ã§â€¢Å’Ã©ÂÂ¢Ã¯Â¼Å’Ã¥Ë†â„¢Ã©Å“â‚¬Ã¨Â¦ÂÃ¦â€™Â­Ã¦â€Â¾Ã¦ÂÂ¢Ã¤ÂºÂºÃ¥Å Â¨Ã§â€Â»Ã¥Â¹Â¶Ã¦â€ºÂ´Ã¦â€“Â°Ã¥â€¦Â¶Ã¥Â±Å¾Ã¦â‚¬?
        if self._curHeroIndex ~= 7 then 
        	if pos > 0 then 
        		self:_onHeroHeaderClicked(nil, pos)
        		self:_updatePageWithIndex(pos - 1)
        		self._knightAttri1 = self._oldKnightAttr1
        	end

        	self:_dropNewKnight(newKnightId, function (  )
            	self:_onSwitchToHeroPage(newKnightId)
            	G_flyAttribute.addNormalText(G_lang:get("LANG_CHANGE_KNIGHT_SUCCESS"), nil, nil)
            	--if oldKnightId < 1 then 
            		self:_checkActiveAssocition(newKnightId)
            	--end
            	
            	self:_doFlyKnightAttributes()
            	self._oldKnightAttr1 = nil
			end)            
        end
	end	
end

function HeroLayer:_dropNewKnight( knightId, func )
	if not knightId then
		return func and func()
	end

	local baseId = G_Me.bagData.knightsData:getBaseIdByKnightId(knightId)
	if baseId < 1 then
		return func and func()
	end

    local dressKnightId = 0
    if knightId == G_Me.formationData:getMainKnightId() then 
        dressKnightId = G_Me.dressData:getDressedPic()
    end

    local equipPanel = self:getWidgetByName("equip")
	local panel = self:getWidgetByName("Panel_HeroPanel")
	if not panel or not equipPanel then
		return func and func()
	end

    self:showWidgetByName("Panel_HeroPanel", false)
	local size = panel:getSize()
	local centerPtx, centerPty = panel:convertToWorldSpaceXY(size.width/2, 1)
	centerPtx, centerPty = equipPanel:convertToNodeSpaceXY(centerPtx, centerPty)
    centerPty = centerPty + 45
	local KnightAppearEffect = require("app.scenes.hero.KnightAppearEffect")
	local ani = nil 
    ani = KnightAppearEffect.new(baseId, function()
    	--self:callAfterFrameCount(2, function ( ... )
        local soundConst = require("app.const.SoundConst")
        G_SoundManager:playSound(soundConst.GameSound.KNIGHT_DOWN)
    	if func then 
    		func() 
    	end
    	if ani then
    		ani:removeFromParentAndCleanup(true)
    	end
    	self:showWidgetByName("Panel_HeroPanel", true)
    	--end)
    end, dressKnightId)
    ani:setPositionXY(centerPtx, centerPty)
    ani:play()
    --self:addChild(ani)
    self:getWidgetByName("equip"):addNode(ani)
    
end

function HeroLayer:_onAddTeamKnight( ret, knightId, pos )
	if ret == NetMsg_ERROR.RET_OK then
        self:_onChangeTeamFormation(NetMsg_ERROR.RET_OK, pos > 6 and 2 or 1, pos, 0, knightId)
	end
end

function HeroLayer:_generateAssociateArr( knightId )
    if type(knightId) ~= "number" then 
        return 
    end

    local baseId = G_Me.bagData.knightsData:getBaseIdByKnightId(knightId)
    local knightInfo = G_Me.bagData.knightsData:getKnightByKnightId(knightId)

    local baseInfo = knight_info.get(baseId) or nil
    if not baseInfo or not knightInfo then 
        return nil
    end

            local associateArr = {}
            -- if baseInfo.association_7 < 1 then 
            --     table.insert(associateArr, #associateArr + 1, baseInfo.association_1)
            --     table.insert(associateArr, #associateArr + 1, baseInfo.association_2)
            --     table.insert(associateArr, #associateArr + 1, baseInfo.association_3)
            --     table.insert(associateArr, #associateArr + 1, baseInfo.association_4)
            --     table.insert(associateArr, #associateArr + 1, baseInfo.association_5)
            --     table.insert(associateArr, #associateArr + 1, baseInfo.association_6)
            --     table.insert(associateArr, #associateArr + 1, baseInfo.association_7)
            --     table.insert(associateArr, #associateArr + 1, baseInfo.association_8)
            -- else
                local activeAssociationSkill = knightInfo and knightInfo["association"] or {}
                local activeSkillFlag = {}
                for key, value in pairs(activeAssociationSkill) do 
                    activeSkillFlag[value] = true
                    table.insert(associateArr, #associateArr + 1, value)
                end
                if not activeSkillFlag[baseInfo.association_1] then 
                   table.insert(associateArr, #associateArr + 1, baseInfo.association_1) 
                end
                if not activeSkillFlag[baseInfo.association_2] then 
                   table.insert(associateArr, #associateArr + 1, baseInfo.association_2) 
                end
                if not activeSkillFlag[baseInfo.association_3] then 
                   table.insert(associateArr, #associateArr + 1, baseInfo.association_3) 
                end
                if not activeSkillFlag[baseInfo.association_4] then 
                   table.insert(associateArr, #associateArr + 1, baseInfo.association_4) 
                end
                if not activeSkillFlag[baseInfo.association_5] then 
                   table.insert(associateArr, #associateArr + 1, baseInfo.association_5) 
                end
                if not activeSkillFlag[baseInfo.association_6] then 
                   table.insert(associateArr, #associateArr + 1, baseInfo.association_6) 
                end
                if not activeSkillFlag[baseInfo.association_7] then 
                   table.insert(associateArr, #associateArr + 1, baseInfo.association_7) 
                end
                if not activeSkillFlag[baseInfo.association_8] then 
                   table.insert(associateArr, #associateArr + 1, baseInfo.association_8) 
                end
                if not activeSkillFlag[baseInfo.association_9] then 
                   table.insert(associateArr, #associateArr + 1, baseInfo.association_9) 
                end
                if not activeSkillFlag[baseInfo.association_10] then 
                   table.insert(associateArr, #associateArr + 1, baseInfo.association_10) 
                end
                if not activeSkillFlag[baseInfo.association_11] then 
                   table.insert(associateArr, #associateArr + 1, baseInfo.association_11) 
                end
                if not activeSkillFlag[baseInfo.association_12] then 
                   table.insert(associateArr, #associateArr + 1, baseInfo.association_12) 
                end
            -- end

            return associateArr
end

function HeroLayer:_checkActiveAssocition( knightId )
    -- Ã¦Â£â‚¬Ã¦Å¸Â¥Ã¦Å¸ÂÃ¤Â¸ÂªÃ¦Â­Â¦Ã¥Â°â€ Ã¤Â¸Å Ã©ËœÂµÃ¥ÂÅ½Ã¤Â¼Å¡Ã¦Â¿â‚¬Ã¦Â´Â»Ã¥â€œÂªÃ¤Âºâ€ºÃ§Â¼ËœÃ¥Ë?
	local activeAssociton = G_Me.bagData.knightsData:calcJiPanByNewKnight(knightId) or {}
    if #activeAssociton < 1 then 
        return nil
    end

    local baseId = G_Me.bagData.knightsData:getBaseIdByKnightId(knightId)
    local knightBaseInfo = knight_info.get(baseId) or nil
    if not knightBaseInfo then 
        return nil
    end

    local activeAssociate = self:_generateAssociateArr(knightId)

    local calcJipanIndex = function ( associtionId )
        local index = 0
        local findAssotion = false

        local doCompareAssocition = function ( assocition, destId )
            if assocition > 0 then 
                index = index + 1
            end

            return destId == assocition
        end

        for key, value in pairs(activeAssociate) do 
            if doCompareAssocition(value, associtionId) then 
                return index
            end
        end

        -- if doCompareAssocition(knightBaseInfo.association_1, associtionId) or 
        --    doCompareAssocition(knightBaseInfo.association_2, associtionId) or 
        --    doCompareAssocition(knightBaseInfo.association_3, associtionId) or 
        --    doCompareAssocition(knightBaseInfo.association_4, associtionId) or 
        --    doCompareAssocition(knightBaseInfo.association_5, associtionId) or 
        --    doCompareAssocition(knightBaseInfo.association_6, associtionId) then 
        --     return index
        -- end

        return index
    end

    for key, value in pairs(activeAssociton) do 
        if type(value) == "table" then 
            -- Ã¥Â¦â€šÃ¦Å¾Å“Ã¦Å“â€°Ã¨Â¢Â«Ã¦Â¿â‚¬Ã¦Â´Â»Ã§Å¡â€žÃ§Â¼ËœÃ¥Ë†â€ Ã¯Â¼Å’Ã¥Ë†â„¢Ã¨Â®Â¡Ã§Â®â€”Ã¥â€¡ÂºÃ¦ËœÂ¾Ã§Â¤ÂºÃ¨Â¯Â¥Ã§Â¼ËœÃ¥Ë†â€ Ã§Å¡â€žÃ¦Å½Â§Ã¤Â»Â¶Ã¤Â½ÂÃ§Â½Â®Ã¥Â¹Â¶Ã¤Â¿ÂÃ¥Â­Ë?
            if value[3] == 1 then 
                local index = calcJipanIndex(value[2])
                if index > 0 then 
                    value[3] = self:getWidgetByName("Label_skill_"..index)
                else
                    value[3] = nil
                end
            else
                value[3] = nil
            end
        end
    end

    G_flyAttribute.addAssocitionChange(activeAssociton)

    return activeAssociton
	--return G_playAttribute.playKnightAssociationActive(activeAssociton, retText) or 0
end

function HeroLayer:twinkleIcon( icon, twink )
    if not icon then
            return
        end

--Ã¦Â¸ÂÃ©Å¡ÂÃ¦Â¸ÂÃ¦ËœÂ¾Ã¦Å¸ÂÃ¤Â¸ÂªÃ¦Å½Â§Ã¤Â»Â¶
        twink = twink or false
        icon:stopAllActions()

        if icon and twink then
            local fadeInAction = CCFadeIn:create(0.5)
            local fadeOutAction = CCFadeOut:create(0.5)
            local seqAction = CCSequence:createWithTwoActions(fadeInAction, fadeOutAction)
            seqAction = CCRepeatForever:create(seqAction)
            icon:runAction(seqAction)
        end
end

function HeroLayer:_loadPetIcon(  )
    self:_loadKnightIcon(7)
end

function HeroLayer:_loadKnightIcon( index  )
    -- Ã¦â€ºÂ´Ã¦â€“Â°Ã¦Å“â‚¬Ã¤Â¸Å Ã¦Å½â€™Ã§Å¡â€žÃ¦Â­Â¦Ã¥Â°â€ Ã¥Â¤Â´Ã¥Æ’ÂÃ¥Ë†â€”Ã¨Â?
    local showWidget = function ( rootWidget, name, show )
        if not rootWidget or type(name) ~= "string" then 
            return 
        end

        local widget = rootWidget:getChildByName(name)
        if widget then 
            widget:setVisible(show)
        end
    end

    local showWidgetForWidget = function ( rootWidget, index, show, openLevel )
        if not index or index < 2 or index > 12 then
            return 
        end

        local ctrlIndex = index - 2
        openLevel = openLevel or 1

        local _initPartner = function ( )
            show = not G_moduleUnlock:isModuleUnlock(funLevelConst.PARTNER_ARRAY_1)
            self:showWidgetByName("ImageView_lock_text_"..ctrlIndex, show)
            self:showWidgetByName("Image_huoban_text_"..ctrlIndex, not show)
            --showWidget(rootWidget, "ImageView_lock_icon", show)
            local label = self:getLabelByName("Label_level_"..ctrlIndex)
            if label then
                label:setVisible(show)
                if show then 
                    label:setText(""..openLevel)
                end
            end
        end
        local _initChongwu = function ( ... )
            local pet = G_Me.bagData.petData:getFightPet()
            local hasPet = pet and true or false
            local unlock = G_moduleUnlock:isModuleUnlock(funLevelConst.PET)
            local lockLevel = G_moduleUnlock:getModuleUnlockLevel(funLevelConst.PET)
            self:getLabelByName("Label_level_5"):setVisible(not unlock)
            self:getImageViewByName("ImageView_lock_text_5"):setVisible(not unlock)
            self:getImageViewByName("ImageView_add_icon_5"):setVisible(unlock and not hasPet)
            self:getImageViewByName("ImageView_lock_icon_5"):setVisible(not unlock or hasPet)
            self:getImageViewByName("Image_ball_5"):setVisible(not unlock or hasPet)
            self:getImageViewByName("ImageView_pingji_5"):setVisible(not unlock or hasPet)
            self:getLabelByName("Label_level_5"):setText(lockLevel)
            if pet then
                local info = pet_info.get(pet.base_id)
                self:getImageViewByName("ImageView_lock_icon_5"):loadTexture(G_Path.getPetIcon(info.res_id))
                self:getImageViewByName("ImageView_pingji_5"):loadTexture(G_Path.getEquipColorImage(info.quality))
                self:getImageViewByName("Image_ball_5"):loadTexture(G_Path.getEquipIconBack(info.quality))
            end
            self:twinkleIcon(self:getWidgetByName("ImageView_add_icon_5"), true)
        end

        if index > 6 then
            if index == 7 then 
                    _initChongwu()
            elseif index == 8 then
                    _initPartner()
            end
        elseif not show then
        	self:showWidgetByName("ImageView_lock_icon_"..ctrlIndex, true)
        	self:showWidgetByName("ImageView_add_icon_"..ctrlIndex, false)
        	self:showWidgetByName("Label_level_"..ctrlIndex, false)
        	self:showWidgetByName("ImageView_pingji_"..ctrlIndex, true)
        	self:showWidgetByName("ImageView_lock_text_"..ctrlIndex, false)
            --showWidget(rootWidget, "ImageView_lock_icon", true)
           -- showWidget(rootWidget, "ImageView_add_icon", false)
            --showWidget(rootWidget, "Label_level", false)
            --showWidget(rootWidget, "ImageView_pingji", true)
            --showWidget(rootWidget, "ImageView_lock_text", false)

            self:twinkleIcon(self:getWidgetByName("ImageView_add_icon_"..ctrlIndex), false)
        else
            --showWidget(rootWidget, "ImageView_pingji", false)
        	self:showWidgetByName("ImageView_pingji_"..ctrlIndex, false)
            if index <= G_Me.userData:getMaxTeamSlot() then
        		self:showWidgetByName("Label_level_"..ctrlIndex, false)
        		self:showWidgetByName("ImageView_add_icon_"..ctrlIndex, true)
        		self:showWidgetByName("ImageView_lock_icon_"..ctrlIndex, false)
        		self:showWidgetByName("ImageView_lock_text_"..ctrlIndex, false)
                
                --showWidget(rootWidget, "ImageView_add_icon", true)
                --showWidget(rootWidget, "ImageView_lock_icon", false)
                --showWidget(rootWidget, "Label_level", false)
                self:twinkleIcon(self:getWidgetByName("ImageView_add_icon_"..ctrlIndex), true)
                --showWidget(rootWidget, "ImageView_lock_text", false)
            else
            	local showLock = (index == G_Me.userData:getMaxTeamSlot() + 1)
        		self:showWidgetByName("ImageView_lock_text_"..ctrlIndex, showLock)
        		self:showWidgetByName("ImageView_add_icon_"..ctrlIndex, false)
        		self:showWidgetByName("ImageView_lock_icon_"..ctrlIndex, true)
                
                --showWidget(rootWidget, "ImageView_add_icon", false)
                self:twinkleIcon(self:getWidgetByName("ImageView_add_icon_"..ctrlIndex), false)
                --showWidget(rootWidget, "ImageView_lock_icon", true)

                
                --showWidget(rootWidget, "Label_level", showLock)
                --showWidget(rootWidget, "ImageView_lock_text", showLock )
                
                rootWidget:setEnabled(false)
                local label = self:getLabelByName("Label_level_"..ctrlIndex)
                label = tolua.cast(label, "Label")
                if label then
                	label:setVisible(showLock)
                    label:setText(""..openLevel)
                end
            end
        end
    end

    local loadKnight = function ( widgetName, index, openLevel )
        index = index or 2
        local rootWidget = self:getWidgetByName(widgetName)
        if not rootWidget then 
            return 
        end

        local maxSlot = G_Me.userData:getMaxTeamSlot()
        rootWidget:setVisible(index <= maxSlot + 2)
        if index > maxSlot + 2 then 
            return 
        end

        local knightId, baseId = G_Me.formationData:getTeamKnightIdAndBaseIdByIndex(1, index)
        self:registerBtnClickEvent(widgetName, function ( widget )
            self:_onHeroHeaderClicked(widget, index)
        end)

        require("app.cfg.knight_info")
        local knightInfo = knight_info.get(baseId)
        if knightInfo == nil then
            showWidgetForWidget(rootWidget, index, true, openLevel)
            return 
        end

        local resId = knightInfo.res_id

        local heroImage = self:getImageViewByName("ImageView_lock_icon_"..(index - 2))
        if heroImage then
            if index <= maxSlot then
                heroImage:loadTexture(G_Path.getKnightIcon(resId), UI_TEX_TYPE_LOCAL)
            else
                heroImage:setVisible(false)
            end
        end

        local pingji = self:getImageViewByName("ImageView_pingji_"..(index - 2))
         if pingji then
            pingji:loadTexture(G_Path.getAddtionKnightColorImage(knightInfo.quality))
        end
    
        showWidgetForWidget(rootWidget, index, false, openLevel)
    end

    local unlockLevel = 0
    if index < 7 then 
        unlockLevel = G_moduleUnlock:getModuleUnlockLevel(funLevelConst.BATTLE_ARRAY_2 + index - 2)
    else
    	unlockLevel = G_moduleUnlock:getModuleUnlockLevel(funLevelConst.PARTNER_ARRAY_1)
    end
    loadKnight("Button_back_"..(index - 2), index, unlockLevel)
end

function HeroLayer:_selectKnightItem( selected, index )
    selected = selected or false
    if not selected and not self._selectKnightBack then 
        return 
    end

    -- Ã©â‚¬â€°Ã¦â€¹Â©Ã¦Å“â‚¬Ã¤Â¸Å Ã¦Å½â€™Ã§Å¡â€žÃ¦Â­Â¦Ã¥Â°â€ Ã¥Â¤Â´Ã¥Æ’ÂÃ¥ÂÅ½Ã¯Â¼Å’Ã¦â€ºÂ´Ã¦ÂÂ¢Ã©â‚¬â€°Ã¦â€¹Â©Ã¨Æ’Å’Ã¦â„¢Â¯Ã¯Â¼Å’Ã¥Â¹Â¶Ã¦â€ºÂ´Ã¦â€“Â°Ã¤Â¸â€¹Ã©ÂÂ¢Ã§Å¡â€žÃ¦Â­Â¦Ã¥Â°â€ Ã¤Â¿Â¡Ã¦Â?
    if selected then 
        if not self._selectKnightBack then 
            self._selectKnightBack = ImageView:create()
            self._selectKnightBack:loadTexture("ui/zhengrong/selected_bg.png", UI_TEX_TYPE_LOCAL)
           -- self._selectKnightBack:setVisible(false)
            local container = self._knightScrollView:getInnerContainer() 
            if container then 
                container:addChild(self._selectKnightBack)
            end
        end

        index = index or 2
        local knightItem = self:getWidgetByName("Button_back_"..(index - 2))
        if knightItem then 
            local posx, posy = knightItem:getPosition()
            self._selectKnightBack:setPosition(ccp(posx, posy))
        end
    end

    if self._selectKnightBack then 
        self._selectKnightBack:setVisible(selected)
    end
end

function HeroLayer:_playRoundAtKnight( index )
    index = index or 2
    local knightItem = self:getWidgetByName("Button_back_"..(index - 2))
    if knightItem then 
        self:_playRoundEffect(knightItem)
    end
end

function HeroLayer:_scrollToShowKnight( index )
    index = index or 2 

    -- Ã¨Â·Â³Ã¨Â½Â¬Ã¥Ë†Â°pageviewÃ§Å¡â€žindexÃ§Â´Â¢Ã¥Â¼â€¢Ã©Â¡ÂµÃ¥Å½Â»Ã¦ËœÂ¾Ã§Â¤Â?
    local widget = self:getWidgetByName("Button_back_"..(index - 2))
    local scrollView = self:getScrollViewByName("ScrollView_knight_list")
    if widget and scrollView then 
        local widgetSize = scrollView:getSize()
        local containerSize = scrollView:getInnerContainerSize()
        local left = widget:getLeftInParent()
        local right = widget:getRightInParent()  
        local container = scrollView:getInnerContainer()
        local posx, posy = container:getPosition()
        if widgetSize.width < containerSize.width and 
            ((left + posx >= widgetSize.width) or ((right + posx) <= 0) or 
                ((left + posx < widgetSize.width) and (right + posx > widgetSize.width))) then   
            self._knightScrollView:jumpToPercentHorizontal(100*(left)/(containerSize.width - widgetSize.width))
        end
    end

    --local maxSlot = G_Me.userData:getMaxTeamSlot()
    --if self._knightScrollView then 
    --    self._knightScrollView:jumpToPercentHorizontal(100*(index - 2)/(maxSlot - 1))
    --end
end

function HeroLayer:_initKnightList(  )
    self:_loadKnightIcon(2)
    self:_loadKnightIcon(3)
    self:_loadKnightIcon(4)
    self:_loadKnightIcon(5)
    self:_loadKnightIcon(6)

    -- Ã¥Â°ÂÃ¤Â¼â„¢Ã¤Â¼Â´Ã§Å¡â€žÃ©â€šÂ£Ã¤Â¸ÂªitemÃ¥Â¦â€šÃ¦Å¾Å“Ã¥ÂÅ’Ã¥Â¸Â§Ã¥Å Â Ã¨Â½Â½Ã¯Â¼Å’Ã¤Â¼Å¡Ã¥Â¯Â¼Ã¨â€¡Â´Ã¨Â¿â„¢Ã¤Â¸ÂªÃ§â€¢Å’Ã©ÂÂ¢Ã¨Â¿â€ºÃ¥â€¦Â¥Ã¦â€”Â¶Ã¥ÂÂ¡Ã©Â¡Â¿Ã¤Â¸â‚¬Ã¤Â¼Å¡Ã¯Â¼Å’Ã¦ËœÂ¾Ã§Â¤ÂºÃ¨Â¿ËœÃ¤Â¸ÂÃ¥Â¯Â¹Ã¯Â¼Å’Ã¦Å¡â€šÃ¦Å“Â?
    -- Ã¦â€°Â¾Ã¥Ë†Â°Ã¦â‚¬Å½Ã¤Â¹Ë†Ã¨Â§Â£Ã¥â€ Â³Ã§Å¡â€žÃ£â‚¬â€šÃ¥â€¦Ë†Ã¦â€Â¾Ã§Ââ‚¬
    self:callAfterFrameCount(2, function ( ... )
    	self:_loadKnightIcon(7)
        self:_loadKnightIcon(8)
    end)
    

    -- Ã¥Â½â€œÃ¥â€°ÂÃ¦ËœÂ¾Ã§Â¤ÂºÃ¥Ë†Â°Ã¦Å“â‚¬Ã¥Â¤Â§Ã¥Â¼â‚¬Ã¥Â§â€¹Ã©ËœÂµÃ¤Â½ÂÃ§Å¡â€žÃ¤Â¸â€¹Ã¤Â¸â‚¬Ã¤Â¸ÂªÃ¤Â¸ÂºÃ¦Â­?
    local maxSlot = G_Me.userData:getMaxTeamSlot()
    local widget = nil
    if maxSlot < 6 then 
        widget = self:getWidgetByName("Button_back_"..(maxSlot - 1))
    else
        -- if not self._chongwuUnlock then 
        --     maxSlot = 6
        --     widget = self:getWidgetByName("Button_back_"..(maxSlot - 1))
        -- end
    end
    
    local scrollView = self:getScrollViewByName("ScrollView_knight_list")
    if widget and scrollView then 
        local right = widget:getRightInParent()
        local containerSize = scrollView:getInnerContainerSize()
        scrollView:setInnerContainerSize(CCSizeMake(right + 10, containerSize.height))
    end
	-- local panel = self:getPanelByName("Panel_knightList")
	-- if panel == nil then
	-- 	return 
	-- end
	-- local levelArr = G_Me.userData:getTeamSlotOpenLevel()
	-- self._listview = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_HORIZONTAL)

 --    self._listview:setCreateCellHandler(function ( list, index)
 --        return require("app.scenes.hero.HeroSprite").new(list, index)
 --    end)
 --    self._listview:setUpdateCellHandler(function ( list, index, cell)
 --        if cell.updateHero then 
 --            local openLevel = index + funLevelConst.BATTLE_ARRAY_2
 --            openLevel = G_moduleUnlock:getModuleUnlockLevel(openLevel)
 --            cell:updateHero( index + 2, (index > 4) and 2 or 1 , openLevel)
 --        else
 --            __LogError("cell has no updateHero function!")
 --        end
 --    end)
 --    self._listview:setClickCellHandler(function ( list, index, cell )
 --    	self:_onHeroHeaderClicked(cell, index + 2)
 --    end)
 --    self._listview:setScrollEventHandler(function(list, scrollType, nBegin, nEnd)
 --        if scrollType == SCROLLVIEW_EVENT_SCROLL_TO_LEFT then
 --            self:showWidgetByName("Button_turnleft", false)
 --        elseif scrollType == SCROLLVIEW_EVENT_SCROLL_TO_RIGHT then
 --           self:showWidgetByName("Button_turnright", false)
 --        elseif scrollType == SCROLLVIEW_EVENT_SCROLLING then
 --        	list = tolua.cast(list, "CCSListViewEx")
 --            self:showWidgetByName("Button_turnleft", not self._listview:isAtLeftBoundary())
 --            self:showWidgetByName("Button_turnright", not self._listview:isAtRightBoundary())
 --        end
 --    end)
 --    local image = ImageView:create()
 --    image:loadTexture("ui/zhengrong/selected_bg.png", UI_TEX_TYPE_LOCAL)
 --    self._listview:setClickSelected(true, image)
 --    self._listview:setClippingEnabled(true)
 --    local maxSlot = G_Me.userData:getMaxTeamSlot()
 --    self._listview:reloadWithLength(maxSlot >= 5 and 5 or maxSlot, 0)

 --    self:registerListViewEvent("Panel_knightList", function ( ... )
 --    	-- this function is used for new user guide, you shouldn't care it
 --    end)

    local heroImage = self:getImageViewByName("ImageView_MainHero")
    if not heroImage then
    	return 
    end

    local knightId, baseId = G_Me.formationData:getTeamKnightIdAndBaseIdByIndex(1, 1)
    require("app.cfg.knight_info")
    local knightInfo = knight_info.get(baseId)
    if knightInfo == nil then
        return 
    end
    local resId = knightInfo.res_id
    if knightId == G_Me.formationData:getMainKnightId() then 
        resId = G_Me.dressData:getDressedPic()
    end

    heroImage:loadTexture(G_Path.getKnightIcon(resId), UI_TEX_TYPE_LOCAL)

    local pingji = self:getButtonByName("Button_hero_back")
    if pingji then
    	pingji:loadTextureNormal(G_Path.getAddtionKnightColorImage(knightInfo.quality))
        pingji:loadTexturePressed(G_Path.getAddtionKnightColorImage(knightInfo.quality))
        --pingji:loadTexturePressed(G_Path.getAddtionKnightColorImage(knightInfo.quality))
        --pingji:loadTextureDisabled(G_Path.getAddtionKnightColorImage(knightInfo.quality))
    end

end

function HeroLayer:onTouchBegin( xpos, ypos )
	self._shouldMoveWithPage = false
    self._startMoveX = xpos
    self._isMovingStatus = false

    if self._heroPageView then 
        local x, y = self._heroPageView:convertToNodeSpaceXY(xpos, ypos)
        local wSize = self._heroPageView:getSize()
        self._touchPageView = x > 0 and y > 0 and x < wSize.width and y < wSize.height 
    end

    self._oldPageIndex = self._heroPageView and self._heroPageView:getCurPageIndex() or 0

	if not self._heroPageView or self._heroPageView:getPageCount() <= 6 then
		return
	end

    -- Ã¥Â¦â€šÃ¦Å¾Å“Ã¨Â§Â¦Ã¦â€˜Â¸Ã¥Ë†Â°Ã§Å¡â€žÃ¤Â¸ÂÃ¦ËœÂ¯Ã§Â?Ã©Â¡ÂµÃ¦Ë†â€“Ã§Â?Ã©Â¡Âµpage, Ã¥Â°Â±Ã¤Â¸ÂÃ§Â»Â§Ã§Â»Â­Ã¥Â¤â€žÃ§Ââ€ Ã¨Â§Â¦Ã¦â€˜Â?
	if not self:isWidgetTouched(self._heroPageView:getPageCell(5)) and 
		not self:isWidgetTouched(self._heroPageView:getPageCell(6)) then 
		return 
	end

	if self._curHeroIndex < 6 then 
		return 
	end

	self._shouldMoveWithPage = true
end

function HeroLayer:onTouchMove( xpos, ypos )
    local oldStatus = self._isMovingStatus
    if not self._isMovingStatus and self._touchPageView then 
        local flag = (math.abs(xpos - self._startMoveX) >= 10)
        self._isMovingStatus = ((self._curHeroIndex == 1 and xpos < self._startMoveX) or self._curHeroIndex > 1) and flag
    end

    if not oldStatus and self._isMovingStatus then 
        self:_showAllElement(false)
    end

	if self._shouldMoveWithPage then 
		-- Ã¥Â¦â€šÃ¦Å¾Å“Ã¥Å“Â¨Ã§Â¬Â?Ã©Â¡ÂµÃ¥Ââ€˜Ã¥ÂÂ³Ã¦Â»â€˜Ã¥Å Â¨Ã¦Ë†â€“Ã§Â?Ã©Â¡ÂµÃ¥Ââ€˜Ã¥Â·Â¦Ã¦Â»â€˜Ã¥Å Â¨Ã¯Â¼Å’Ã¥Ë†â„¢Ã¨Â§Â¦Ã¦â€˜Â¸Ã¤Â¸ÂÃ¦â€°Â§Ã¨Â¡Å’Ã¦Â»â€˜Ã¥Å Â?
        if self._curHeroIndex == 6 and xpos > self._startMoveX then 
            return 
        elseif self._curHeroIndex == 7 and xpos < self._startMoveX then 
            return 
        end

        if self._baseInfoPanel then 
            -- self._baseInfoPanel:setPosition(ccp(self._initBaseInfoPt.x + (xpos - self._startMoveX), self._initBaseInfoPt.y))
        end

        if self._equipPanel then 
            -- self._equipPanel:setPosition(ccp(self._initEquipPt.x + (xpos - self._startMoveX), self._initEquipPt.y))
        end
	end

    
end

function HeroLayer:onTouchEnd( xpos, ypos )
    local oldStatus = self._isMovingStatus
    if self._isMovingStatus then 
        self._isMovingStatus = false
    end

    if oldStatus and self._heroPageView then 
        local newPageIndex = self._heroPageView:getCurPageIndex()
        if newPageIndex ~= self._oldPageIndex then 
            if (self._oldPageIndex == 6 and xpos > self._startMoveX) then
                self:_showAllElement(true)
            elseif not ( ((self._oldPageIndex == 5 or self._oldPageIndex == 6 ) and xpos < self._startMoveX) or 
                ( self._oldPageIndex == 7 and xpos > self._startMoveX )) then
                self:_showAllElement(true, true)
            end            
        else
            if newPageIndex < 6 then
                self:_showAllElement(true)
                elseif newPageIndex == 6 then
                    if self._petLayer then
                        self._petLayer:onLayerTurnOut(true)
                    end
            end
        end
    end   

    if self._shouldMoveWithPage and self._heroPageView then 
        -- Ã¥Â¦â€šÃ¦Å¾Å“Ã¥Å“Â¨Ã§Â¬Â?Ã©Â¡ÂµÃ¥Ââ€˜Ã¥ÂÂ³Ã¦Â»â€˜Ã¥Å Â¨Ã¯Â¼Å’Ã¥Ë†â„¢Ã¦ÂÂ¢Ã¥Â¤ÂÃ¥Ë†Â°Ã¥Å½Å¸Ã¤Â½ÂÃ§Â½?
        if self._curHeroIndex == 6 and xpos > self._startMoveX then 
            if self._baseInfoPanel then 
                -- self._baseInfoPanel:setPosition(self._initBaseInfoPt)
            end
            if self._equipPanel then 
               -- self._equipPanel:setPosition(self._initEquipPt)
            end
        elseif self._curHeroIndex ~= 7 or xpos >= self._startMoveX then 
            -- Ã¥Â¦â€šÃ¦Å¾Å“Ã¦ËœÂ¯Ã§Â¬Â?Ã¨â‚¬Å’Ã¥Ââ€˜Ã¥Â·Â¦Ã¦Â»â€˜Ã¥Å Â¨Ã¯Â¼Å’Ã¦Ë†â€“Ã§Â¬Â?Ã©Â¡ÂµÃ¥Ââ€˜Ã¥ÂÂ³Ã¦Â»â€˜Ã¥Å Â¨Ã¯Â¼Å’Ã¥Ë†â„¢Ã¦Â»â€˜Ã¥Å Â¨Ã¥ÂÅ“Ã¦Â­Â¢Ã¦â€”Â¶Ã¯Â¼Å’Ã¦ÂÂ¢Ã¥Â¤ÂÃ¥Å½Å¸Ã¤Â½ÂÃ§Â½Â?
            local pageSize = self._heroPageView:getSize()
            if math.abs(xpos - self._startMoveX) >= pageSize.width/3 then
                --self:_showEquipCtrls(xpos > self._startMoveX)
            else
                if self._baseInfoPanel then 
                    -- self._baseInfoPanel:setPosition(self._initBaseInfoPt)
                end
                if self._equipPanel then 
                    -- self._equipPanel:setPosition(self._initEquipPt)
                end
            end 
        end       
    end
   
end

function HeroLayer:_showAllElement( show, animation )
    if not self._allElements then 
        self._allElements = {}
        table.insert(self._allElements, #self._allElements + 1, self:getWidgetByName("Panel_left"))
        table.insert(self._allElements, #self._allElements + 1, self:getWidgetByName("Panel_right"))
        table.insert(self._allElements, #self._allElements + 1, self:getWidgetByName("Image_baseinfo"))
        table.insert(self._allElements, #self._allElements + 1, self:getWidgetByName("Image_skill"))
        table.insert(self._allElements, #self._allElements + 1, self:getWidgetByName("Panel_name"))
        table.insert(self._allElements, #self._allElements + 1, self:getWidgetByName("Button_change"))
        table.insert(self._allElements, #self._allElements + 1, self:getWidgetByName("Button_dress"))
        table.insert(self._allElements, #self._allElements + 1, self:getWidgetByName("Button_strength"))
        table.insert(self._allElements, #self._allElements + 1, self:getWidgetByName("equip"))
        table.insert(self._allElements, #self._allElements + 1, self:getWidgetByName("Panel_stars"))
        table.insert(self._allElements, #self._allElements + 1, self:getWidgetByName("Image_paper"))
        table.insert(self._allElements, #self._allElements + 1, self:getWidgetByName("Button_7"))
    end

    if show then 
        if animation then 
            GlobalFunc.flyIntoScreenLR({self:getWidgetByName("Button_1"), 
                self:getWidgetByName("Button_4"), 
                self:getWidgetByName("Button_5"), 
                self:getWidgetByName("Button_strength")}, true, 0.2, 5, 50)

            GlobalFunc.flyIntoScreenLR({self:getWidgetByName("Button_3"), 
                self:getWidgetByName("Button_2"), 
                self:getWidgetByName("Button_6"), 
                self:getWidgetByName("Button_dress"), 
                self:getWidgetByName("Button_change"),
                self:getWidgetByName("Button_7")}, false, 0.2, 5, 50)

            GlobalFunc.flyIntoScreenLR({self:getWidgetByName("Image_baseinfo"), 
                    self:getWidgetByName("Panel_left")}, true, 0.2, 2, 50)
            GlobalFunc.flyIntoScreenLR({self:getWidgetByName("Image_skill"), 
                    self:getWidgetByName("Panel_right")}, false, 0.2, 1, 50, function ( ... )
                       -- self:_onFinishAnimation()
                    end)
        end
        for key, value in pairs(self._allElements) do 
            if value and value.setVisible then 
                local visibleStatus = true 
                if not animation then 
                    local vValue = self._elementVisibleStatus[value]
                    visibleStatus = (not vValue) or (vValue and (vValue == 1))
                end
                value:setVisible(visibleStatus)
            end
        end

        if animation then
            self:showWidgetByName("Panel_stars", false)
        end
    else
        local widget = self:getWidgetByName("Button_change")
        if widget then
            self._elementVisibleStatus[widget] = widget:isVisible() and 1 or 0
        end
        widget = self:getWidgetByName("Button_dress")
        if widget then
            self._elementVisibleStatus[widget] = widget:isVisible() and 1 or 0
        end
        widget = self:getWidgetByName("Panel_stars")
        if widget then
            self._elementVisibleStatus[widget] = widget:isVisible() and 1 or 0
        end
        for key, value in pairs(self._allElements) do 
            if value and value.setVisible then 
                value:setVisible(false)
            end
        end
    end
    if self._curHeroIndex == 7 and self._petLayer then
        self._petLayer:onLayerTurnOut(show)
    end
end

function HeroLayer:_showBianShenSetting()
    local bianShenLayer = require("app.scenes.hero.BianShenSettingLayer").create(self)
    uf_notifyLayer:getModelNode():addChild(bianShenLayer)
end 

function HeroLayer:_initHeroPanel(  )
    self:registerBtnClickEvent("Button_bianshen" , function(widget)  
        self:_showBianShenSetting()
    end)
	self:registerBtnClickEvent("Button_mainBattle", function ( widget )
		self:_switchHeros(true)		
	end)
	self:registerBtnClickEvent("Button_yuanjun", function ( widget )
		self:_switchHeros(false)		
	end)

	self:registerBtnClickEvent("Button_save", function ( widget )
		self:_onSaveClicked()		
	end)
	self:registerBtnClickEvent("Button_return", function ( widget )
		self:_onSaveClicked()		
	end)

	self:registerBtnClickEvent("Button_equip", function ( widget )
		self:_onOneClickEquipment()
	end)

	self:registerBtnClickEvent("Button_buzhen", function ( widget )
        self:_showBuzhengLayer()
    end)
	self:registerBtnClickEvent("Button_hero_back", function ( widget )
    	self:_onHeroHeaderClicked(widget, 1)
    end)

    self:registerWidgetClickEvent("Button_strength", function ( widget )
        self:_showStrengthEquipLayer()
    end)
    self:registerBtnClickEvent("Button_change", function ( widget )
        self:_onChangeKnightClick()
    end)
    self:registerBtnClickEvent("Button_dress", function ( widget )
        self:_onDressClicked()
    end)

    self:registerBtnClickEvent("Button_1", function ( widget )
    	self:_onEquipItemClicked(widget, 1, 1)
    end)
    self:registerBtnClickEvent("Button_add_1", function ( widget )
        self:_onEquipItemClicked(widget, 1, 1)
    end)
    self:registerBtnClickEvent("Button_2", function ( widget )
    	self:_onEquipItemClicked(widget, 2, 2)
    end)
    self:registerBtnClickEvent("Button_add_2", function ( widget )
        self:_onEquipItemClicked(widget, 2, 2)
    end)
    self:registerBtnClickEvent("Button_3", function ( widget )
    	self:_onEquipItemClicked(widget, 3, 3)
    end)
    self:registerBtnClickEvent("Button_add_3", function ( widget )
        self:_onEquipItemClicked(widget, 3, 3)
    end)
    self:registerBtnClickEvent("Button_4", function ( widget )
    	self:_onEquipItemClicked(widget, 4, 4)
    end)
    self:registerBtnClickEvent("Button_add_4", function ( widget )
        self:_onEquipItemClicked(widget, 4, 4)
    end)
    self:registerBtnClickEvent("Button_5", function ( widget )
    	self:_onTreasureClicked(widget, 1, 1)
    end)
    self:registerBtnClickEvent("Button_add_5", function ( widget )
        self:_onTreasureClicked(widget, 1, 1)
    end)
    self:registerBtnClickEvent("Button_6", function ( widget )
    	self:_onTreasureClicked(widget, 2, 2)
    end)
    self:registerBtnClickEvent("Button_add_6", function ( widget )
        self:_onTreasureClicked(widget, 2, 2)
    end)
    self:registerBtnClickEvent("Button_7", function ( widget )
        self:_onPetClicked(widget, 1, 1)
    end)
    self:registerBtnClickEvent("Button_add_7", function ( widget )
        self:_onPetClicked(widget, 2, 2)
    end)

    self:registerBtnClickEvent("Label_level_value", function ( widget )
    	
    end)

    
    self:registerBtnClickEvent("Button_juexing", handler(self, self._onJuexingClick))

    -- Ã¥Â½â€œÃ¥Â¤ÂºÃ¥Â®ÂÃ¦Å“ÂªÃ¥Â¼â‚¬Ã¥ÂÂ¯Ã¦â€”Â¶Ã¯Â¼Å’Ã¦ËœÂ¾Ã§Â¤ÂºÃ¥Â¤ÂºÃ¥Â®ÂÃ¦Â¡â€ Ã¤Â¸Å Ã©ÂÂ¢Ã§Å¡â€žÃ©â€ÂÃ¥â€ºÂ¾Ã¦Â â€?
    local lockTreasure = not G_moduleUnlock:isModuleUnlock(funLevelConst.TREASURE_COMPOSE)
    self:showWidgetByName("Image_lock_5", lockTreasure)
    self:showWidgetByName("Image_lock_6", lockTreasure)
    if lockTreasure then 
        self:showWidgetByName("Button_add_5", not lockTreasure)
        self:showWidgetByName("Button_add_6", not lockTreasure)
    end

    if G_GuideMgr and G_GuideMgr:isCurrentGuiding() then 
        self:showWidgetByName("Button_add_1", false)
        self:showWidgetByName("Button_add_2", false)
        self:showWidgetByName("Button_add_3", false)
        self:showWidgetByName("Button_add_4", false)
        self:showWidgetByName("Button_add_5", false)
        self:showWidgetByName("Button_add_6", false)
        self:showWidgetByName("Button_add_7", false)
    else
        self:twinkleIcon(self:getWidgetByName("Button_add_1"), true)
        self:twinkleIcon(self:getWidgetByName("Button_add_2"), true)
        self:twinkleIcon(self:getWidgetByName("Button_add_3"), true)
        self:twinkleIcon(self:getWidgetByName("Button_add_4"), true)
        self:twinkleIcon(self:getWidgetByName("Button_add_5"), true)
        self:twinkleIcon(self:getWidgetByName("Button_add_6"), true)
        self:twinkleIcon(self:getWidgetByName("Button_add_7"), true)
    end

    --Ã¥Â½â€œÃ§â€šÂ¹Ã¥â€¡Â»Ã§Â¼ËœÃ¥Ë†â€ Ã¦Â â€¡Ã©Â¢ËœÃ¥â€™Å’Ã¨Æ’Å’Ã¦â„¢Â¯Ã¦â€”Â¶Ã¯Â¼Å’Ã¦ËœÂ¾Ã§Â¤ÂºÃ¥Â½â€œÃ¥â€°ÂÃ¦Â­Â¦Ã¥Â°â€ Ã§Å¡â€žÃ¨Â¯Â¦Ã§Â»â€ Ã¤Â¿Â¡Ã¦ÂÂ¯Ã¥Â¹Â¶Ã§â€ºÂ´Ã¦Å½Â¥Ã¨Â·Â³Ã¥Ë†Â°Ã¥â€¦Â¶Ã§Â¼ËœÃ¥Ë†â€ Ã©Æ’Â¨Ã¥Ë?
    local showZuhe = function ( ... )
        if not self:_checkKnightValid(self._curHeroIndex) then
            return 
        end

        local heroDesc = require("app.scenes.hero.HeroDescLayer")
        heroDesc.showHeroDesc(uf_sceneManager:getCurScene(), self._curKnightId, true, true, 1, self._curHeroIndex)
    end
    self:registerWidgetClickEvent("Label_zuhe", showZuhe)
    self:registerWidgetClickEvent("Panel_right", showZuhe)
    -- knight header
    --self:showWidgetByName("Button_turnleft", false)
    self:registerBtnClickEvent("Button_turnleft", function ( widget )
        if self._knightScrollView then 
            self._knightScrollView:jumpToPercentHorizontal(0)
        end
    end)
    self:registerBtnClickEvent("Button_turnright", function ( widget )
        if self._knightScrollView then 
            local maxSlot = G_Me.userData:getMaxTeamSlot()
            if maxSlot > 3 then 
                self._knightScrollView:jumpToPercentHorizontal(100)
            end
        end
    end)

    local btn = self:getButtonByName("Button_turnleft")
    if btn then
        btn:setPressedActionEnabled(true)
    end

    btn = self:getButtonByName("Button_turnright")
    if btn then
        btn:setPressedActionEnabled(true)
    end

    for loopi = 1, 6 do 
    	local label = self:getLabelByName("Label_equip_name_"..loopi)
    	if label then
    		label:enableStrokeEx(Colors.strokeBlack, 1)
    	end
    	label = self:getLabelByName("Label_"..loopi)
    	if label then
    		label:enableStrokeEx(Colors.strokeBlack, 1)
    	end
    end

    --local selectBack = self:getWidgetByName("ImageView_select_back")
    --if selectBack then
    --	selectBack:setPosition(ccp(self:getWidgetByName("ImageView_MainHero"):getPosition()))
   -- end
end

function HeroLayer:_showBuzhengLayer( ... )
    self:_stopSchedule()
    require("app.scenes.hero.HerobuZhengLayer").showBuZhengLayer( function ( ... )
        self:_startSchedule()
    end)
end

function HeroLayer:_showStrengthEquipLayer( ... )
    -- Ã¦ËœÂ¾Ã§Â¤ÂºÃ¥Â¼ÂºÃ¥Å’â€“Ã¥Â¤Â§Ã¥Â¸Ë†Ã¦â€”Â¶Ã¯Â¼Å’Ã©Â¦â€“Ã¥â€¦Ë†Ã¦Â£â‚¬Ã¦Å¸Â¥Ã¦ËœÂ¯Ã¥ÂÂ¦Ã¨Â£â€¦Ã¥Â¤â€¡Ã¤Âºâ€?Ã¤Â¸ÂªÃ¨Â£â€¦Ã¥Â?
    local fullEquip = G_Me.formationData:isFullEquipForPos(1, self._curHeroIndex)
    if not fullEquip then 
        return G_MovingTip:showMovingTip(G_lang:get("LANG_KNIGHT_ENTER_EQUIP_STRENGTH_TIP"))
    end
    self._equipStrengthShow = true
    self:_stopSchedule()
    require("app.scenes.hero.StrengthEquipLayer").create(self._curHeroIndex, function ( ... )
        self._equipStrengthShow = false
        self:_startSchedule()
    end)
end

function HeroLayer:_onJuexingClick()
    if not self._hasCreatePage then 
        return 
    end

    local awakenUnlock, awakenQualityLimit, awakenLevelValid, notAwakenMaxLevel = 
        G_Me.bagData.knightsData:isKnightAwakenValid(self._curKnightId)
    if not awakenQualityLimit then
        return G_MovingTip:showMovingTip(G_lang:get("LANG_AWAKEN_KNIGHT_INVALID_DESC"))
    -- Ã¨Â§â€°Ã©â€ â€™Ã¥Å Å¸Ã¨Æ’Â½Ã¦Å“ÂªÃ¨Â§Â£Ã©â€?
    elseif not awakenUnlock then
        -- Ã¨Â¿â„¢Ã©â€¡Å’checkModuleUnlockStatusÃ¦â€“Â¹Ã¦Â³â€¢Ã¥â€ â€¦Ã§â€ºÂ´Ã¦Å½Â¥Ã¦Å â€ºÃ©â€â„¢Ã¨Â¯Â¯Ã¦ÂÂÃ§Â¤ÂºÃ¤Âºâ€ Ã¯Â¼Å’Ã¤Â¸ÂÃ§â€Â¨Ã§Â®Â¡Ã¤Âºâ€?
        return G_moduleUnlock:checkModuleUnlockStatus(funLevelConst.AWAKEN)
    elseif not awakenLevelValid then
        return G_MovingTip:showMovingTip(G_lang:get("LANG_AWAKEN_KNIGHT_LEVEL_INVALID_DESC", {level=G_moduleUnlock:getModuleUnlockLevel(funLevelConst.AWAKEN)}))
    elseif not notAwakenMaxLevel then
        return G_MovingTip:showMovingTip(G_lang:get("LANG_AWAKEN_KNIGHT_LEVEL_MAX_DESC"))
    end

    uf_sceneManager:pushScene(require("app.scenes.herofoster.HeroDevelopScene").new( 
        KnightConst.KNIGHT_TYPE.KNIGHT_JUEXING, self._curKnightId ))
end

function HeroLayer:_onChangeKnightClick( ... )
    -- Ã§â€šÂ¹Ã¥â€¡Â»Ã¦â€ºÂ´Ã¦ÂÂ¢Ã§Å¡â€žÃ¥â€œÂÃ¥Âºâ€Ã¥â€¡Â½Ã¦â€?
    local team1Knight, team1Count = G_Me.formationData:getFirstTeamKnightIds()
    local team2Knight, team2Count = G_Me.formationData:getSecondTeamKnightIds()
    if team1Count + team2Count >= G_Me.bagData.knightsData:getKnightCount() then
        G_MovingTip:showMovingTip(G_lang:get("LANG_NO_SELECT_KNIGHT"))
    else
        local parent = self:getParent()
        
        local heroSelectLayer = require("app.scenes.hero.HeroSelectLayer")

        heroSelectLayer.showHeroSelectLayer(parent, self._curHeroIndex, function ( knightId, effectWaitCallback, teamId, posIndex )
            if knightId then
                if not G_Me.formationData:isKnightValidjForCurrentTeam(teamId, knightId, posIndex) then
                    G_MovingTip:showMovingTip(G_lang:get("LANG_SAME_KNIGHT"))
                    return 
                end
                G_HandlersManager.cardHandler:changeTeamFormation(teamId, 
                    posIndex, knightId )    
            end
        end, nil, 1, self._curHeroIndex)
    end
end

function HeroLayer:_initHeroPageView(  )
	local pagePanel = self:getPanelByName("Panel_HeroPanel")
	if pagePanel == nil then
		return 
	end	

	self._heroPageView = CCSNewPageViewEx:createWithLayout(pagePanel)
	--self._heroPageView = CCSPageViewEx:createWithLayout(pagePanel)
end

function HeroLayer:_loadHeroPage(  )
	local HeroPageItem = require("app.scenes.hero.HeroPageItem")
	self._heroPageView:setPageCreateHandler(function ( page, index )
                    -- local cell = HeroPageItem.new()
              --       cell:initPageItem(index + 1, self, 1)
                    -- cell:setTouchEnabled(true)

              --       local knightId, baseId = G_Me.formationData:getTeamKnightIdAndBaseIdByIndex(1, index + 1)
              --       self._knightAttris[index + 1] = G_Me.bagData.knightsData:getKnightAttr1(knightId)

              --       if index + 1 == 7 then 
              --        self:_onAddPartnerLayer(cell)
              --       end
  		local cell = HeroPageItem.new()
		cell:setTouchEnabled(true)
  		return cell
	end)

    self._heroPageView:setPageUpdateHandler(function ( page, index, cell )
        if cell and cell.initPageItem then 
            cell:initPageItem(index + 1, self, 1)

            if index < 6 and index >= 0 then 
            	local knightId, baseId = G_Me.formationData:getTeamKnightIdAndBaseIdByIndex(1, index + 1)
  	        	self._knightAttris[index + 1] = G_Me.bagData.knightsData:getKnightAttr1(knightId)
  	        end


            if index + 1 == 7 then 
                    self:_onAddChongwuLayer(cell)    		
            elseif index + 1 == 8 then 
                self:_onAddPartnerLayer(cell)
        	else
        		self:_hidepartnerLayer(cell)
        	end
        else
            __Log("-----------------setPageUpdateHandler--------------")
            __Log("cell is %d, cell.initPageItem is %d", cell and 1 or 0, (cell and cell.initPageItem) and 1 or 0 )
        end
    end)

	self._heroPageView:setPageTurnHandler(function ( page, index, cell )
        G_flyAttribute._clearFlyAttributes(  )
        if index >= 1 then
            self:_scrollToShowKnight(index + 1)
        end
        if index > 0 then
            self:_selectKnightItem(true, index + 1)
            --self._listview:selectCell(index - 1)
            self:showWidgetByName("Image_select_back", false)
        else
            self:_selectKnightItem(false)
            --self._listview:unselectCell()
            self:showWidgetByName("Image_select_back", true)
        end

        if index + 1 == 7 then 
               if self._petLayer then 
                self._petLayer:setVisible(true)
        	       self._petLayer:onLayerTurn()
                   self:_updateJuexingStars()
               end
        elseif index + 1 == 8 then
            if self._partnerLayer then 
                self._partnerLayer:setVisible(true)
               self._partnerLayer:onLayerTurn()
               self:_updateJuexingStars()
           end
        end

        local curHeroIndex = self._curHeroIndex
        self._curHeroIndex = index + 1
        if curHeroIndex < 7 and self._curHeroIndex >= 7 then 
            self:_showEquipCtrls(false, false)
        elseif curHeroIndex >= 7 and self._curHeroIndex < 7 then 
            self:_showEquipCtrls(true, false)
        end

        if index < G_Me.userData:getMaxTeamSlot(1) then
		    local knightId, baseId = G_Me.formationData:getTeamKnightIdAndBaseIdByIndex(1, self._curHeroIndex)
		    self:_onSwitchToHeroPage(knightId)
            self:_playAudioWithKnightBaseId(baseId)
            self._activeAssociationArr = nil
            self:_updateKnightSkillList(self._curKnightId)
            self:_udpateKnightAttributes(self._curKnightId)
		    self:_loadFightResourcesForKnight( (index + 1 > 6) and 2 or 1, (index + 1) > 6 and (index + 1 - 6) or (index + 1))
            self:_addEquipTreasureTargetChange(true, true)
		end
	end)

	self._heroPageView:setClickCellHandler(function ( pageView, index, cell)
                if self._curHeroIndex <= 6 then 
                    local knightId, baseId = G_Me.formationData:getTeamKnightIdAndBaseIdByIndex(1, self._curHeroIndex)
        		    self:_onHeroPageViewClicked(index + 1, knightId)
                end
                if self._curHeroIndex == 7 then
                    self:_onPetPageClicked()
                end
	end)
	self._heroPageView:setClippingEnabled(false)

    local maxSlot = G_Me.userData:getMaxTeamSlot()
    if maxSlot >= 6 then 
        maxSlot = 8
    end
	self._heroPageView:showPageWithCount(maxSlot, self._curHeroIndex - 1)

	if maxSlot >= 6 then 
		self:registerTouchEvent(false, false, 0)
	end
    self._hasCreatePage = true
end

function HeroLayer:_playAudioWithKnightBaseId( baseId )
    if not baseId or baseId < 1 then 
        return 
    end
    local knightInfo = knight_info.get(baseId)
    if knightInfo and type(knightInfo.common_sound) == "string"  then 
        if type(self._lastPlayAudio) == "string" then 
            G_SoundManager:stopSound(self._lastPlayAudio)
        end
        if type(knightInfo.common_sound) == "string" and #knightInfo.common_sound > 3 then
            G_SoundManager:playSound(knightInfo.common_sound)
            self._lastPlayAudio = knightInfo.common_sound
        end
    end
end

-- Ã§â€šÂ¹Ã¥â€¡Â»Ã¥Â°ÂÃ¤Â¼â„¢Ã¤Â¼Â´Ã¤Â¸Å Ã©ËœÂµÃ§Å¡â€žÃ¥â€œÂÃ¥Âºâ€Ã¥â€¡Â½Ã¦â€¢Â?
function HeroLayer:_onAddPartnerLayer( cell )
    if not cell then 
        return 
    end

    if not self._partnerLayer then 
        self._partnerLayer = require("app.scenes.hero.PartnerLayer").new("ui_layout/knight_partner.json", self._isToFriendLayer)
        self._isToFriendLayer = false
        self._partnerLayer:retain()

    end 
    self._partnerLayer:removeFromParentAndCleanup(false)
   	cell:getRootWidget():addNode(self._partnerLayer, 1000, 1000)

   	local cellSize = cell:getSize()
   	local partnerSize = self._partnerLayer:getSize()
   	self._partnerLayer:setPosition(ccp(0, cellSize.height - partnerSize.height - 30))
    self._partnerLayer:setVisible(true)
end

function HeroLayer:_onAddChongwuLayer( cell )
     if not cell then 
         return 
     end
     
     if not self._petLayer then 
         self._petLayer = require("app.scenes.hero.HeroPetLayer").new("ui_layout/knight_pet.json")
         self._petLayer:retain()

     end 
     self._petLayer:removeFromParentAndCleanup(false)
        cell:getRootWidget():addNode(self._petLayer, 2000, 2000)

        local pos0 = ccp(self:getPanelByName("Panel_knights"):getPosition())
        local pos1 = ccp(self:getPanelByName("Panel_baseinfo"):getPosition())
        pos0 = self:getPanelByName("Root"):convertToWorldSpace(pos0)
        pos1 = self:getPanelByName("Root"):convertToWorldSpace(pos1)
        pos0 = self:getPanelByName("Panel_HeroPanel"):convertToNodeSpace(pos0)
        pos1 = self:getPanelByName("Panel_HeroPanel"):convertToNodeSpace(pos1)
        local cellSize = cell:getSize()
        local maxHeight = pos0.y - pos1.y
        self._petLayer:adapterWithSize(CCSize(640 ,maxHeight))
        self._petLayer:setPosition(ccp(0,pos1.y))
     self._petLayer:setVisible(true)

end

-- Ã¦Â Â¹Ã¦ÂÂ®pageviewÃ§Å¡â€žÃ¥Â½â€œÃ¥â€°ÂÃ©Â¡ÂµÃ§Â´Â¢Ã¥Â¼â€¢Ã¥â‚¬Â¼Ã¯Â¼Å’Ã¦Å½Â§Ã¥Ë†Â¶Ã¥Â°ÂÃ¤Â¼â„¢Ã¤Â¼Â´Ã§â€¢Å’Ã©ÂÂ¢Ã§Å¡â€žÃ¦ËœÂ¾Ã§Â¤Â?
function HeroLayer:_hidepartnerLayer( cell )
    if not cell then 
        return 
    end
	local widget = cell:getRootWidget()
	if not widget then 
		return 
	end

	local node = widget:getNodeByTag(1000)
	if node then 
		node:setVisible(false)
	end

    local node = widget:getNodeByTag(2000)
    if node then 
        node:setVisible(false)
    end
end

function HeroLayer:_showEquipCtrls( show, scroll )
	show = show or false

        if self._baseInfoPanel then 
            --self._initBaseInfoPt = ccp(self._initBaseInfoPt.x + (show and 640 or -640), self._initBaseInfoPt.y)
            --self._baseInfoPanel:setPosition(self._initBaseInfoPt)

            self._baseInfoPanel:setVisible(show)
        end
        if self._equipPanel then 
            --self._initEquipPt = ccp(self._initEquipPt.x + (show and 640 or -640), self._initEquipPt.y)
            --self._equipPanel:setPosition(self._initEquipPt)
            self._equipPanel:setVisible(show)
        end
end

function HeroLayer:_onHeroPageViewClicked( index, knightId )
	if not index then
		return 
	end
-- Ã§â€šÂ¹Ã¥â€¡Â»pageviewÃ§Å¡â€žÃ¥Â½â€œÃ¥â€°ÂpageÃ§Å¡â€žÃ¥â€œÂÃ¥Â?
	if not knightId or knightId < 1 then
		local team1Knight, team1Count = G_Me.formationData:getFirstTeamKnightIds()
    	local team2Knight, team2Count = G_Me.formationData:getSecondTeamKnightIds()
    	if team1Count + team2Count >= G_Me.bagData.knightsData:getKnightCount() then
    		G_MovingTip:showMovingTip(G_lang:get("LANG_NO_SELECT_KNIGHT"))
    	else
			local heroSelectLayer = require("app.scenes.hero.HeroSelectLayer")
        	heroSelectLayer.showHeroSelectLayer(uf_sceneManager:getCurScene(), self._curHeroIndex, function ( knightId, effectWaitCallback )
                dump(effectWaitCallback)
                self.__EFFECT_FINISH_CALLBACK__ = effectWaitCallback

        		if not G_Me.formationData:isKnightValidjForCurrentTeam(1, knightId, index) then
                	G_MovingTip:showMovingTip(G_lang:get("LANG_SAME_KNIGHT"))
                	return 
            	end

        		G_HandlersManager.cardHandler:addTeamKnight(knightId)
       		 end)
    	end
	else
		local heroDesc = require("app.scenes.hero.HeroDescLayer")
		heroDesc.showHeroDesc(uf_sceneManager:getCurScene(), knightId, true, false, index > 6 and 2 or 1, index)
	end
end

function HeroLayer:_onPetPageClicked( )
    local pet = G_Me.bagData.petData:getFightPet()
    if pet  then
        local tLayer = require("app.scenes.pet.PetInfo").showEquipmentInfo(pet , 2,{})
        tLayer:setTag(10100)
    else
        require("app.scenes.pet.PetSelectPetLayer").show()
    end
end

function HeroLayer:_onHeroHeaderClicked( widget, index )
    if not self._heroPageView then 
        return 
    end

    local _needKnight = function ( index )
        if index > 6 then 
            return 
        end
        
        local knightId, baseId = G_Me.formationData:getTeamKnightIdAndBaseIdByIndex(1, index )
        if knightId < 1 then
           local team1Knight, team1Count = G_Me.formationData:getFirstTeamKnightIds()
           local team2Knight, team2Count = G_Me.formationData:getSecondTeamKnightIds()
           if team1Count + team2Count >= G_Me.bagData.knightsData:getKnightCount() then
              G_MovingTip:showMovingTip(G_lang:get("LANG_NO_SELECT_KNIGHT"))
           else
              local heroSelectLayer = require("app.scenes.hero.HeroSelectLayer")
               heroSelectLayer.showHeroSelectLayer(uf_sceneManager:getCurScene(), self._curHeroIndex, function ( knightId, effectWaitCallback )
                    dump(effectWaitCallback)
                    self.__EFFECT_FINISH_CALLBACK__ = effectWaitCallback

                    if not G_Me.formationData:isKnightValidjForCurrentTeam(1, knightId, index) then
                       G_MovingTip:showMovingTip(G_lang:get("LANG_SAME_KNIGHT"))
                       return 
                    end
                    G_HandlersManager.cardHandler:addTeamKnight(knightId)
                end)
           end        
        end
    end

	local curHeroIndex = self._curHeroIndex
	self._curHeroIndex = index
    if self._curHeroIndex == curHeroIndex then 
        return _needKnight(curHeroIndex)
    end

    if curHeroIndex > 6 and self._curHeroIndex < 7 then 
        self:_showAllElement(true, false)
    end

    -- Ã§â€šÂ¹Ã¥â€¡Â»Ã¦Å“â‚¬Ã¤Â¸Å Ã¦Å½â€™Ã§Å¡â€žÃ¦Â­Â¦Ã¥Â°â€ Ã¥Â¤Â´Ã¥Æ’ÂÃ¦â€”Â¶Ã¯Â¼Å’pageviewÃ¨Â·Â³Ã¨Â½Â¬Ã¥Ë†Â°Ã¨Â¯Â¥Ã¦Â­Â¦Ã¥Â°â€ Ã§Å¡â€žÃ¦ËœÂ¾Ã§Â¤ÂºÃ©Â¡Â?
	if curHeroIndex ~= self._curHeroIndex then
        if self._heroPageView:getCurPageIndex() ~= index - 1 then
            self._heroPageView:jumpToPage(index - 1)
        end
    end
	
	 if curHeroIndex < 7 and self._curHeroIndex >= 7 then 
	 	self:_showEquipCtrls(false, false)
	 elseif curHeroIndex >= 7 and self._curHeroIndex < 7 then 
	 	self:_showEquipCtrls(true, false)
	 end

    if index <= 6 then 
	    _needKnight(index)
    end
    if index == 7 then
        if not G_Me.bagData.petData:getFightPet() then
            require("app.scenes.pet.PetSelectPetLayer").show()
        end
    end	
end

function HeroLayer:_checkKnightValid(  )
    -- Ã¦Â£â‚¬Ã¦Å¸Â¥Ã¥Â½â€œÃ¥â€°ÂÃ¤Â½ÂÃ§Â½Â®Ã¤Â¸Å Ã¦ËœÂ¯Ã¥ÂÂ¦Ã¤Â¸Å Ã©ËœÂµÃ¤Âºâ€ Ã¦Â­Â¦Ã¥Â?
	local teamId = self._curHeroIndex > 6 and 2 or 1
	local knightId = G_Me.formationData:getKnightIdByIndex(teamId, teamId == 2 and (self._curHeroIndex - 6) or self._curHeroIndex)
	if not knightId or knightId < 1 then
		G_MovingTip:showMovingTip(G_lang:get("LANG_LACK_KNIGHT"))
		return false
	end

	return true
end

function HeroLayer:_onEquipItemClicked( widget, index, equipType )
	if not self:_checkKnightValid(index) then
		return 
	end

    -- Ã§â€šÂ¹Ã¥â€¡Â»Ã¨Â£â€¦Ã¥Â¤â€¡Ã¤Â½ÂÃ§Â½Â®Ã§Å¡â€žÃ¥â€œÂÃ¥Â?
	local teamId = self._curHeroIndex > 6 and 2 or 1
    if teamId ~= 1 then 
        return 
    end

	local pos = teamId == 1 and self._curHeroIndex or self._curHeroIndex - 6

	local fightEquipment = G_Me.formationData:getFightEquipmentBySlot(teamId, pos, index)
	if fightEquipment > 0 then
        require("app.scenes.equipment.EquipmentInfo").showEquipmentInfo(G_Me.bagData.equipmentList:getItemByKey(fightEquipment), 
            2, {teamId = teamId, pos=pos, slot=equipType, flag = self._effectEquipTips[index]})


		-- local EquipmentDescLayer = require("app.scenes.hero.EquipmentDescLayer")
		-- EquipmentDescLayer.showEquipmentDescLayer(true, fightEquipment, teamId, pos, equipType)
	else
		local equiplist = self._equipList[equipType] or {}
		--local equiplist = G_Me.bagData:getEquipmentListByType( equipType )
		local equipWearOn = G_Me.formationData:getFightEquipmentList(equipType)
		local unWearEquip = 0
		for key, value in pairs(equiplist) do 
			if value and not equipWearOn[value["id"]] then
				unWearEquip = unWearEquip + 1
			end
		end

		if unWearEquip == 0 then
            require("app.scenes.common.acquireInfo.AcquireInfoLayer").show(G_Goods.TYPE_EQUIPMENT, 1000 + index,
            GlobalFunc.sceneToPack("app.scenes.hero.HeroScene", {self._curHeroIndex}))
			--G_MovingTip:showMovingTip(G_lang:get("LANG_NO_EQUIP"))
		else
			local equipSelectLayer = require("app.scenes.common.EquipSelectLayer")
       	 	equipSelectLayer.showEquipSelectLayer(uf_sceneManager:getCurScene(), self._curHeroIndex, equipType, equiplist, function ( equipId, effectWaitCallback  )
                self.__EFFECT_FINISH_CALLBACK__ = effectWaitCallback
                
                G_flyAttribute._clearFlyAttributes()
                self:_udpateKnightAttributes(self._curKnightId)
                G_HandlersManager.fightResourcesHandler:sendAddFightEquipment( teamId, pos, equipType, equipId)
        	end)
		end		
	end	
end

function HeroLayer:_onTreasureClicked( widget, index, treasureType )
    if not G_moduleUnlock:checkModuleUnlockStatus(funLevelConst.TREASURE_COMPOSE) then 
        return 
    end
    -- Ã§â€šÂ¹Ã¥â€¡Â»Ã¥Â®ÂÃ§â€°Â©Ã¤Â½ÂÃ§Â½Â®Ã§Å¡â€žÃ¥â€œÂÃ¥Â?
	if not self:_checkKnightValid(index) then
		return 
	end

	local teamId = self._curHeroIndex > 6 and 2 or 1
    if teamId ~= 1 then 
        return 
    end
	local pos = teamId == 1 and self._curHeroIndex or self._curHeroIndex - 6

	local fightTreasure = G_Me.formationData:getFightTreasureBySlot(teamId, pos, index)
	if fightTreasure > 0 then
        require("app.scenes.treasure.TreasureInfo").showTreasureInfo(G_Me.bagData.treasureList:getItemByKey(fightTreasure), 
            2, {teamId = teamId, pos=pos, slot=treasureType, flag = self._effectEquipTips[index + 4]})

		-- local EquipmentDescLayer = require("app.scenes.hero.EquipmentDescLayer")
		-- EquipmentDescLayer.showEquipmentDescLayer(false, fightTreasure, teamId, pos, treasureType)
	else
        local treasurelist = self._treasureList[treasureType] or {}
		--local treasurelist = G_Me.bagData:getTreasureListByType( treasureType )
		local equipWearOn = G_Me.formationData:getFightTreasureList(treasureType)
		local unWearEquip = 0
		for key, value in pairs(treasurelist) do 
			if value and not equipWearOn[value["id"]] then
				unWearEquip = unWearEquip + 1
			end
		end

		if unWearEquip == 0 then
            require("app.scenes.common.acquireInfo.AcquireInfoLayer").show(G_Goods.TYPE_TREASURE, index == 1 and 101 or 102,
                GlobalFunc.sceneToPack("app.scenes.hero.HeroScene", {self._curHeroIndex}))
			--G_MovingTip:showMovingTip(G_lang:get("LANG_NO_TREASURE"))
		else
			local equipSelectLayer = require("app.scenes.common.EquipSelectLayer")
        	equipSelectLayer.showEquipSelectLayer(uf_sceneManager:getCurScene(), self._curHeroIndex, treasureType + 4, treasurelist, function ( equipId, effectWaitCallback )
        		self.__EFFECT_FINISH_CALLBACK__ = effectWaitCallback

                G_flyAttribute._clearFlyAttributes()
                self:_udpateKnightAttributes(self._curKnightId)
                G_HandlersManager.fightResourcesHandler:sendAddFightTreasure( teamId, pos, treasureType, equipId)
        	end)
        end
	end	
end

function HeroLayer:_onPetClicked(widget, index, petType)

    if not G_moduleUnlock:checkModuleUnlockStatus(funLevelConst.PET_PROTECT1) then 
        return 
    end

    if not self:_checkKnightValid(index) then
        return 
    end

    local teamId = self._curHeroIndex > 6 and 2 or 1
    if teamId ~= 1 then 
        return
    end

    local pos = teamId == 1 and self._curHeroIndex or self._curHeroIndex - 6

    local protectPet = G_Me.formationData:getProtectPetIdByPos(pos)

    local function showSelectPetProtectLayer()
        require("app.scenes.hero.PetProtectSelectLayer").show(pos, function(petId)
            if petId then
                G_HandlersManager.fightResourcesHandler:sendSetPetProtect(pos, petId)
            end
        end)
    end

    if protectPet > 0 then

        local function removeCallback()

            G_HandlersManager.fightResourcesHandler:sendSetPetProtect(pos, 0)
        end

        local function changeCallback()
            
            showSelectPetProtectLayer()
        end

        local function knightInfoCallback()
            local heroDesc = require("app.scenes.hero.HeroDescLayer")
            heroDesc.showHeroDesc(uf_sceneManager:getCurScene(), self._curKnightId, true, false, 1, self._curHeroIndex)
        end

        local function petInfoCallback()
            local protectPet = G_Me.formationData:getProtectPetIdByPos(self._curHeroIndex)
            local pet = G_Me.bagData.petData:getPetById(protectPet)
            if pet  then
                local tLayer = require("app.scenes.pet.PetInfo").showEquipmentInfo(pet , 3,{})
                tLayer:setTag(10100)
            end
        end

        require("app.scenes.hero.PetProtectLayer").show(pos, removeCallback, changeCallback, knightInfoCallback, petInfoCallback)

    else

        local protectCount = G_Me.formationData:getProtectPetCount()
        if protectCount < 6 then
            if not G_moduleUnlock:checkModuleUnlockStatus(funLevelConst["PET_PROTECT" .. (protectCount + 1)]) then 
                return 
            end
        end

        local count = 0
        local fightPetId = G_Me.bagData.petData:getFightPetId()
        for k, v in pairs(self._petList) do
            if v.id ~= fightPetId and (not G_Me.formationData:isProtectPetByPetId(v.id))
            and (not G_Me.formationData:isSampleNameProtectPetByPetId(v.id)) then
                count = count + 1
                break
            end
        end
        if count <= 0 then
            require("app.scenes.common.acquireInfo.AcquireInfoLayer").show(G_Goods.TYPE_PET, 50000,
                GlobalFunc.sceneToPack("app.scenes.hero.HeroScene", {self._curHeroIndex}))
        else
            showSelectPetProtectLayer()
        end
        
    end

end

function HeroLayer:_onDressClicked( )
    if self._curHeroIndex ~= 1 then 
        return
    end
    local funLevelConst = require("app.const.FunctionLevelConst")
    if G_moduleUnlock:checkModuleUnlockStatus(funLevelConst.DRESS) then
        uf_sceneManager:replaceScene(require("app.scenes.dress.DressMainScene").new())
    end
end

function HeroLayer:_addEquipTreasureTargetChange( isEquip, onlyCalcAttri )
    local targetStrengthId = 0 
    local targetJinglianId = 0 
    onlyCalcAttri = onlyCalcAttri or false

    -- Ã¨Â®Â¡Ã§Â®â€”Ã¨Â£â€¦Ã¥Â¤â€?Ã¥Â®ÂÃ§â€°Â©Ã¤Â¸Å Ã¤Â¸â€¹Ã©ËœÂµÃ¦â€”Â¶Ã¯Â¼Å’Ã¥Â¯Â¹Ã¥Â¼ÂºÃ¥Å’â€“Ã¥Â¤Â§Ã¥Â¸Ë†Ã§Å¡â€žÃ§ÂºÂ§Ã¥Ë†Â«Ã¥Â¸Â¦Ã¦ÂÂ¥Ã§Å¡â€žÃ¦â€Â¹Ã¥ÂË?

    local addTargetAttri = function ( typeId, targetId )
        if type(typeId) ~= "number" or typeId < 1 or typeId > 4 or onlyCalcAttri then 
            return 
        end

        targetId = targetId or 1
        local targetNameDesc = ""
        if typeId == 2 then 
            targetNameDesc = G_lang:get("LANG_KNIGHT_EQUIP_JINGLIAN_TARGET_NAME")
        elseif typeId == 3 then 
            targetNameDesc = G_lang:get("LANG_KNIGHT_TREASURE_STRENGTH_TARGET_NAME")
        elseif typeId == 4 then 
            targetNameDesc = G_lang:get("LANG_KNIGHT_TREASURE_JINGLIAN_TARGET_NAME")
        else
            targetNameDesc = G_lang:get("LANG_KNIGHT_EQUIP_STRENGTH_TARGET_NAME")
        end

        local desc = G_lang:get("LANG_KNIGHT_TARGET_ATTRI_CHANGE_TIP", {targetName = targetNameDesc, targeLevel = targetId})
        G_flyAttribute.doAddRichtext(desc, nil, nil, nil, self:getWidgetByName("Button_strength"))
    end

-- Ã¨Â®Â¡Ã§Â®â€”Ã¨Â£â€¦Ã¥Â¤â€¡Ã§Å¡â€žÃ¥Â½â€œÃ¥â€°ÂÃ¥Â¼ÂºÃ¥Å’â€“Ã¥Â¤Â§Ã¥Â¸Ë†Ã§Â­â€°Ã§Â?
    if isEquip then 
        targetStrengthId = G_Me.formationData:getKnightEquipTarget(true, self._curHeroIndex)
        targetJinglianId = G_Me.formationData:getKnightEquipTarget(false, self._curHeroIndex)
        if self._curEquipStrengthTargetId < targetStrengthId then 
            addTargetAttri(1, targetStrengthId)
            --__Log("_curEquipStrengthTargetId:%d, targetStrengthId:%d", self._curEquipStrengthTargetId, targetStrengthId)
        end
        if self._curEquipJinglianTargetId < targetJinglianId then 
            addTargetAttri(2, targetJinglianId)
            --__Log("_curEquipJinglianTargetId:%d targetJinglianId:%d", self._curEquipJinglianTargetId, targetJinglianId)
        end
        self._curEquipStrengthTargetId = targetStrengthId
        self._curEquipJinglianTargetId = targetJinglianId
        --__Log("_curEquipStrengthTargetId:%d, _curEquipJinglianTargetId:%d", targetStrengthId, targetJinglianId)
    end
-- Ã¨Â®Â¡Ã§Â®â€”Ã¥Â®ÂÃ§â€°Â©Ã§Å¡â€žÃ¥Â½â€œÃ¥â€°ÂÃ¥Â¼ÂºÃ¥Å’â€“Ã¥Â¤Â§Ã¥Â¸Ë†Ã§Â­â€°Ã§Â?
    targetStrengthId = G_Me.formationData:getKnightTreasureTarget(true, self._curHeroIndex)
    targetJinglianId = G_Me.formationData:getKnightTreasureTarget(false, self._curHeroIndex)
    if self._curTreasureStrengthTargetId < targetStrengthId then 
        addTargetAttri(3, targetStrengthId)
        --__Log("_curTreasureStrengthTargetId:%d, targetStrengthId:%d", self._curTreasureStrengthTargetId, targetStrengthId)
    end
    if self._curTreasureJinglianTargetId < targetJinglianId then 
        addTargetAttri(4, targetJinglianId)
        --__Log("_curTreasureJinglianTargetId:%d, targetJinglianId:%d",self._curTreasureJinglianTargetId, targetJinglianId)
    end
    self._curTreasureStrengthTargetId = targetStrengthId
    self._curTreasureJinglianTargetId = targetJinglianId 
    --__Log("_curTreasureStrengthTargetId:%d, _curTreasureJinglianTargetId:%d", targetStrengthId, targetJinglianId)
end

function HeroLayer:_updateAttributeWhenEquipWear( isEquip )
        local attri1 = self._knightAttri1
        local attributeLevel1 = G_Me.bagData.knightsData:getKnightAttr1(self._curKnightId)
        self._knightAttri1 = attributeLevel1

        self:_updateKnightSkillList(self._curKnightId)

        
        G_flyAttribute.addAssocitionChange(self._associationChange)

        self:_addEquipTreasureTargetChange(isEquip)

        G_flyAttribute.addKnightAttri1Change(attri1, attributeLevel1, self._knightAttriCtrls)
        if self._curHeroIndex < 7 then
            G_flyAttribute.play(function ( ... )
                if self.__EFFECT_FINISH_CALLBACK__ then 
                    self.__EFFECT_FINISH_CALLBACK__(...)
                    self.__EFFECT_FINISH_CALLBACK__ = nil
                end

                self:_udpateKnightAttributes(self._curKnightId)
            end)
        else
            G_flyAttribute.cancelFlyAttributes()
        end
end

function HeroLayer:_updateAttributeWhenEquipUnwear( ... )
    local attri1 = self._knightAttri1
    local attributeLevel1 = G_Me.bagData.knightsData:getKnightAttr1(self._curKnightId)
        self._knightAttri1 = attributeLevel1
        --G_playAttribute.playEquipAttributeChangeWithEquipId(oldEquipId, 0)
        --
        self:_updateKnightSkillList(self._curKnightId)

        G_flyAttribute.addKnightAttri1Change(attri1, attributeLevel1, self._knightAttriCtrls)
        if self._curHeroIndex < 7 then
            G_flyAttribute.play(function ( ... )
                self:_udpateKnightAttributes(self._curKnightId)
            end)
        else
            G_flyAttribute.cancelFlyAttributes()
        end
end

function HeroLayer:_onAddFightEquipment( ret, teamId, posId, slotId, equipId, oldEquipId  )
	if ret == NetMsg_ERROR.RET_OK then
		self:_loadEquipment(teamId, slotId, true)

        self:_updateAttributeWhenEquipWear( true )

        self:_checkEffectEquip({slotId})

        --self:showWidgetByName("Button_strength", G_Me.formationData:isFullEquipForPos(1, self._curHeroIndex))
	end
end

function HeroLayer:_onClearFightEquipment( ret, teamId, posId, slotId, oldEquipId  )
	if ret == NetMsg_ERROR.RET_OK then
		self:_loadEquipment(teamId, slotId)

        self:_updateAttributeWhenEquipUnwear()
        self:_addEquipTreasureTargetChange(true, true)

        self:_checkEffectEquip({slotId})

        --self:showWidgetByName("Button_strength", G_Me.formationData:isFullEquipForPos(1, self._curHeroIndex))
	end
end

function HeroLayer:_onAddFightTreasure( ret, teamId, posId, slotId, treasureId, oldTreasureId )
	if ret == NetMsg_ERROR.RET_OK then
		
		if slotId == 1 then
			self:_loadTreasure(teamId, 1, true)
		elseif slotId == 2 then
			self:_loadTreasure(teamId, 2, true)
		end

        self:_updateAttributeWhenEquipWear( false )

        self:_checkEffectEquip({slotId + 4})

	end
end

function HeroLayer:_onClearFightTreasure( ret, teamId, posId, slotId, oldTreasureId  )
	if ret == NetMsg_ERROR.RET_OK then
		--G_playAttribute.playTreasureAttributeChangeWithEquipId(oldTreasureId, 0)
		if slotId == 1 then
			self:_loadTreasure(teamId, 1)
		elseif slotId == 2 then
			self:_loadTreasure(teamId, 2)
		end
        self:_updateAttributeWhenEquipUnwear()
        self:_addEquipTreasureTargetChange(false, true)

        self:_checkEffectEquip({slotId + 4})
	end
end

function HeroLayer:_onSetPetProtect(data)
    

    if data.pet_id > 0 then
        self:_loadPet(1, 1, true)
        self:_updateAttributeWhenEquipWear( false )
    else
        self:_loadPet(1, 1)
        self:_updateAttributeWhenEquipUnwear()
    end

    self:_checkEffectEquip{7}
end

function HeroLayer:_updateMainKnightSkillList(  )
	self:showWidgetByName("Panel_knight_skill", false)
	local slotList = G_Me.skillTreeData:getSoltList()
    if not slotList or slotList[1] == nil then
    	self:showWidgetByName("Panel_mainKnight_skill", false)
    	return 
    else
		self:showWidgetByName("Panel_mainKnight_skill", true)
		require("app.cfg.skill_info")
		local loopi = 1
		for key, value in pairs(slotList) do 
			if value and value > 0 then
				local skillInfo = skill_info.get(value)
				local skillBack = self:getWidgetByName("Button_skill_"..loopi)
				if skillInfo and skillBack then
					local iconPath = G_Path.getSkillIcon(skillInfo.icon)
					local iconSprite = CCSprite:create(iconPath)
					skillBack:addNode(iconSprite)
				end
				self:showWidgetByName("Button_skill_"..loopi, true)
				self:showWidgetByName("ImageView_arrow_"..(loopi - 1), true)

				loopi = loopi + 1
			end
		end

		for loop = loopi, 4 do 
			self:showWidgetByName("Button_skill_"..loop, false)
			 self:showWidgetByName("ImageView_arrow_"..loop, false)
		end
    end
end

function HeroLayer:_updateKnightSkillList( knightId, exceptAssocition )
	self:showWidgetByName("Panel_mainKnight_skill", false)
	self:showWidgetByName("Panel_knight_skill", true)

-- Ã¦â€ºÂ´Ã¦â€“Â°Ã¥Â½â€œÃ¥â€°ÂÃ¦Â­Â¦Ã¥Â°â€ Ã§Å¡â€žÃ§Â¼ËœÃ¥Ë†â€ Ã¤Â¿Â¡Ã¦Â?
	local knightInfo = G_Me.bagData.knightsData:getKnightByKnightId(knightId)
	local baseId = knightInfo and knightInfo["base_id"] or 0
	local resId = 1
	local knightBaseInfo = nil
	if baseId > 0 then
		knightBaseInfo = knight_info.get(baseId)
	end

	if knightBaseInfo ~= nil then
		resId = knightBaseInfo["res_id"]
	end

	local activeAssociationSkill = knightInfo and knightInfo["association"] or {}
    local isSkillActive = function ( skillId )
        if skillId and exceptAssocition and exceptAssocition[skillId] then 
            return false
        end

        for key, value in pairs(activeAssociationSkill) do 
            if value == skillId then
                return true
            end
        end

        return false
    end

	-- local associationSkill = knightBaseInfo and {knightBaseInfo.association_1, knightBaseInfo.association_2,
	-- 						  knightBaseInfo.association_3, knightBaseInfo.association_4,
	-- 						  knightBaseInfo.association_5, knightBaseInfo.association_6,
 --                              knightBaseInfo.association_7, knightBaseInfo.association_8,} or {}
    -- Ã¥Â¦â€šÃ¦Å¾Å“Ã¦ËœÂ¯Ã¤Â¸Â»Ã¥Â°â€ Ã¯Â¼Å’Ã¨Â¿ËœÃ©Å“â‚¬Ã¨Â¦ÂÃ¥Å Â Ã¥â€?-12Ã¥ÂÂ·Ã§Â¼ËœÃ¥Ë†â€ Ã¤Â¿Â¡Ã¦Â?
    --if self._curHeroIndex == 1 then 
     local associationSkill = self:_generateAssociateArr(knightId) or {}
        -- table.insert(associationSkill, #associationSkill + 1, knightBaseInfo.association_7)
        -- table.insert(associationSkill, #associationSkill + 1, knightBaseInfo.association_8)
        -- table.insert(associationSkill, #associationSkill + 1, knightBaseInfo.association_9)
        -- table.insert(associationSkill, #associationSkill + 1, knightBaseInfo.association_10)
        -- table.insert(associationSkill, #associationSkill + 1, knightBaseInfo.association_11)
        -- table.insert(associationSkill, #associationSkill + 1, knightBaseInfo.association_12)
    --end
    -- if self._curHeroIndex == 1 then 
    --     dump(activeAssociationSkill)
    --     associationSkill = {}
    --     for key, value in pairs(activeAssociationSkill) do 
    --         if #associationSkill < 6 then
    --             table.insert(associationSkill, #associationSkill + 1, value)
    --         end
    --     end
    --     if #associationSkill < 6 then 
    --         local tempAssociation = {knightBaseInfo.association_1, knightBaseInfo.association_2,
    --                           knightBaseInfo.association_3, knightBaseInfo.association_4,
    --                           knightBaseInfo.association_5, knightBaseInfo.association_6,
    --                           knightBaseInfo.association_7, knightBaseInfo.association_8,
    --                           knightBaseInfo.association_9, knightBaseInfo.association_10,
    --                           knightBaseInfo.association_11, knightBaseInfo.association_12,}
    --         for key, value in pairs(tempAssociation) do 
    --             if #associationSkill < 6 and not isSkillActive(value) then 
    --                 table.insert(associationSkill, #associationSkill + 1, value)
    --             end
    --         end
    --     end
    -- end
	require("app.cfg.association_info")
	
	local activeAssocition = {}
	local loopi = 1
	for key, value in pairs(associationSkill) do 
		local skillInfo = association_info.get(value)
		if skillInfo then
			local isActive = isSkillActive(value)
			if isActive then
				activeAssocition[value] = 1
			end
			local label = self:getLabelByName("Label_skill_"..loopi)
			if label then
                label:setColor(isActive and Colors.activeSkill or Colors.inActiveSkill)
				label:setText(skillInfo.name)
			end

			local image = self:getImageViewByName("ImageView_dot_"..loopi)
			if image then
				image:setVisible(true)
				image:loadTexture(isActive and "ui/zhengrong/dot_dianliang.png" or "ui/zhengrong/dot_weidianliang.png", UI_TEX_TYPE_LOCAL)
			end

			loopi = loopi + 1
		end
	end

	for loop = loopi, 6 do 
		self:showTextWithLabel("Label_skill_"..loop, "")
		self:showWidgetByName("ImageView_dot_"..loop, false)
	end

	self:_updateKnightAssocitionByEquip( activeAssocition, associationSkill )
	self._activeAssociationArr = activeAssocition
end

function HeroLayer:_updateKnightAssocitionByEquip( activeAssocition, associationSkill )
	if type(activeAssocition) ~= "table" or not self._activeAssociationArr then
		return
	end

    local findAssocitionIndex = function ( associtionId )
        if not associationSkill then 
            return 0
        end

        local index = 1
        for key, value in pairs(associationSkill) do 
            if value == associtionId then 
                return index 
            end

            index = index + 1
        end
        return 0
    end

	self._associationChange = {}
	local knightInfo = G_Me.bagData.knightsData:getKnightByKnightId(self._curKnightId)
	if knightInfo then
        local loopi = 1
		for key, value in pairs(activeAssocition) do 
			if not self._activeAssociationArr[key] then
				table.insert(self._associationChange, #self._associationChange + 1, {knightInfo["base_id"], key, self:getWidgetByName("Label_skill_"..findAssocitionIndex(key))})
			end
            loopi = loopi + 1
		end
	end
end

function HeroLayer:_onSwitchToHeroPage( knightId, delayStar )
	self._curKnightId = knightId or 0

    self:_resetWaitRecord()

	local knightInfo = G_Me.bagData.knightsData:getKnightByKnightId(self._curKnightId)
	local baseId = knightInfo and knightInfo["base_id"] or 0
	local resId = 1
	local knightBaseInfo = nil
	if baseId > 0 then
		knightBaseInfo = knight_info.get(baseId)
	end

    self._curKnightBaseId = baseId

	if knightBaseInfo ~= nil then
		resId = knightBaseInfo["res_id"]
	end

	local mainKnightId = G_Me.formationData:getMainKnightId()
	local heroName = self:getLabelByName("Label_name")
	if heroName ~= nil then
        heroName:setColor(Colors.getColor(knightBaseInfo and knightBaseInfo.quality or 1))
		heroName:setText(knightBaseInfo ~= nil and knightBaseInfo.name or "")
	end

    --化神水印
    local godImage = self:getImageViewByName("Image_God_Level")
    local godLabel = self:getLabelByName("Label_God_Level")
    HeroGodCommon.setGodShuiYin(godImage, godLabel, knightInfo)

	self:showWidgetByName("Panel_name", knightBaseInfo ~= nil)

    --local flag = (knightBaseInfo ~= nil) and G_Me.formationData:isFullEquipForPos(1, self._curHeroIndex)
    --self:showWidgetByName("Button_strength", flag)

    self:showWidgetByName("Button_change", knightBaseInfo ~= nil and mainKnightId ~= self._curKnightId)
    self:showWidgetByName("Button_dress", knightBaseInfo ~= nil and mainKnightId == self._curKnightId)
    self:showWidgetByName("Button_bianshen", knightBaseInfo ~= nil and mainKnightId == self._curKnightId and G_Me.userData:getClothTime() > 0)

	local label = self:getLabelByName("Label_zizhi")
	if label then
        label:setColor(Colors.getColor(knightBaseInfo and knightBaseInfo.quality or 1))
	 	if knightBaseInfo and knightBaseInfo.advanced_level > 0 then
	 		label:setText("+"..knightBaseInfo.advanced_level, true)
	 	else
	 		label:setText("")
	 	end
	 end

	local level = knightInfo and knightInfo["level"] or 1
	label = self:getLabelByName("Label_level_value")
	if label then
		local mainKnightInfo = G_Me.bagData.knightsData:getKnightByKnightId(mainKnightId)
		if knightInfo then
			label:setText(string.format("%d/%d", level, mainKnightInfo["level"] or 1 ))
		else
			label:setText("")
		end
	end

	local image = self:getImageViewByName("ImageView_country")
	if image then
		local groupPath, imgType = G_Path.getKnightGroupIcon(knightBaseInfo and knightBaseInfo.group or -1)
		if groupPath then
			image:loadTexture(groupPath, imgType)
			image:setVisible(true)
		else
			image:setVisible(false)
		end
	end

            -- local dress = self:getButtonByName("Button_dress")
            -- if dress then
            --      if knightBaseInfo and knightBaseInfo.group == 0 then
            --         dress:setVisible(true)
            --     else
            --         dress:setVisible(false)
            --     end
            -- end

	local image = self:getImageViewByName("ImageView_type")
	if image then
		local damagePath, imgType = G_Path.getJobTipsIcon(knightBaseInfo and knightBaseInfo.character_tips or 0)
		if damagePath then
			image:loadTexture(damagePath, imgType)
			image:setVisible(true)
		else
			image:setVisible(false)
		end
	end

    -- Ã¦ËœÂ¾Ã§Â¤ÂºÃ¨Â§â€°Ã©â€ â€™Ã§Å¡â€žÃ¦ËœÅ¸Ã¦Ë?
    self:_updateJuexingStars(knightId, delayStar)
end

function HeroLayer:_updateJuexingStars(knightId, delayStar)
    local stars = -1
    knightId = knightId or 0
    if knightId > 0 then 
       stars = G_Me.bagData.knightsData:getKnightAwakenLevelByKnightId(knightId) or -1
    end

    self:showWidgetByName("Panel_stars", self._curHeroIndex < 7 and  not delayStar and stars >= 0)

    self:showWidgetByName("Image_start_1_full", not delayStar and stars >= 1)
    self:showWidgetByName("Image_start_2_full", not delayStar and stars >= 2)
    self:showWidgetByName("Image_start_3_full", not delayStar and stars >= 3)
    self:showWidgetByName("Image_start_4_full", not delayStar and stars >= 4)
    self:showWidgetByName("Image_start_5_full", not delayStar and stars >= 5)
    self:showWidgetByName("Image_start_6_full", not delayStar and stars >= 6)
    
    local show_juexing_tip = not delayStar and stars >= 0 and G_Me.formationData:hasAwakenEquipForKnightIndex(self._curHeroIndex)

    if show_juexing_tip and self._curKnightId > 0 then
        local awakenUnlock, awakenQualityLimit, awakenLevelValid, notAwakenMaxLevel = 
            G_Me.bagData.knightsData:isKnightAwakenValid(self._curKnightId)
        show_juexing_tip = show_juexing_tip and notAwakenMaxLevel
    end

    self:showWidgetByName("Image_juexing_tip", show_juexing_tip)
end

function HeroLayer:_udpateKnightAttributes( knightId )
	knightId = knightId or 0
	
    local curKnightAttri = nil
	if knightId > 0 then
		curKnightAttri = G_Me.bagData.knightsData:getKnightAttr1(knightId)
	end
    local attributeLevel1 = self._oldKnightAttr1 or curKnightAttri

	local label = self:getLabelByName("Label_hp_value")
	if label  and  knightId > 0 then
		label:setText(attributeLevel1.hp)
	else
		label:setText("")
	end

	label = self:getLabelByName("Label_attack_value")
	if label  and  knightId > 0 then
		label:setText(attributeLevel1.attack)
	else
		label:setText("")
	end

	label = self:getLabelByName("Label_def_wuli_value")
	if label  and  knightId > 0 then
		label:setText(attributeLevel1.phyDefense)
	else
		label:setText("")
	end

	label = self:getLabelByName("Label_def_mofa_value")
	if label  and  knightId > 0 then
		label:setText(attributeLevel1.magicDefense)
	else
		label:setText("")
	end

    self._knightAttri1 = attributeLevel1
    self._knightAttris[self._curHeroIndex] = curKnightAttri
	--label = self:getLabelByName("Label_zizhi")
	--if label then
	--	label:setText(G_lang:get("LANG_ZIZHI_FORMAT", {zizhiValue=(knightBaseInfo and knightBaseInfo.potential or 0)}) )
	--end

end

-- function HeroLayer:_blurBtnAdd(  ) 
--     local btn = self:getWidgetByName("Button_strength")
--     if not btn then
--         return 
--     end

--     btn:stopAllActions()
--     local scaleOut = CCScaleTo:create(2, 1.1)
--     local scaleIn = CCScaleTo:create(2, 0.9)
--     local seqAction = CCSequence:createWithTwoActions(scaleOut, scaleIn)
--     seqAction = CCRepeatForever:create(seqAction)
--     btn:runAction(seqAction)
-- end

function HeroLayer:_loadEquipment ( teamId, index, animation )
	if index == nil or teamId ~= 1 then
		return 
	end
	local pos = (teamId == 1) and self._curHeroIndex or (self._curHeroIndex - 6)
	local pingji = self:getImageViewByName("ImageView_icon_"..index)
	local iconImage = self:getImageViewByName("ImageView_equip_"..index)
    local iconBack = self:getImageViewByName("Image_back_"..index)
    local starsPanel = self:getPanelByName("Panel_stars_equip_" .. index)
	require("app.cfg.equipment_info")
	local fightEquipment = G_Me.formationData:getFightEquipmentBySlot(teamId, pos, index)
	if fightEquipment > 0 then		
		local equipmentInfo = G_Me.bagData.equipmentList:getItemByKey(fightEquipment)
		if equipmentInfo then
			local baseInfo = equipment_info.get(equipmentInfo["base_id"])
        	if baseInfo then
				if iconImage then
					local imgPath = G_Path.getEquipmentIcon(baseInfo.res_id)
					
	        		iconImage:loadTexture(imgPath, UI_TEX_TYPE_LOCAL)
				end

				if pingji then
					pingji:loadTexture(G_Path.getEquipColorImage(baseInfo.quality))
				end

				local pingjiPiece = self:getImageViewByName("ImageView_color_"..index)
				if pingjiPiece then
					pingjiPiece:loadTexture(G_Path.getAddtionKnightColorPieceImage(baseInfo.quality))
				end

                if iconBack then 
                    iconBack:loadTexture(G_Path.getEquipIconBack(baseInfo.quality))
                end

                -- å‡æ˜Ÿç­‰çº§
                local starLevel = equipmentInfo.star
                if starLevel then
                    starsPanel:setVisible(true)
                    for i = 1, EquipmentConst.Star_MAX_LEVEL do
                        self:showWidgetByName(string.format("Image_start_%d_%d_full", index , i), i <= starLevel)

                    end

                    local start_pos = {x = -47, y = -60}
                    starsPanel:setPositionXY(start_pos.x + 9 * (EquipmentConst.Star_MAX_LEVEL - starLevel), start_pos.y)

                else
                    starsPanel:setVisible(false)
                end

				local label = self:getLabelByName("Label_equip_name_"..index)
				if label then
					label:setVisible(true)
                    label:setColor(Colors.getColor(baseInfo.quality))
					label:setText(baseInfo.name)
				end
				self:showTextWithLabel("Label_"..index, ""..equipmentInfo["level"])
				self:showWidgetByName("Label_"..index, true)
			end
		end
	else
		self:showWidgetByName("Label_"..index, false)
		self:showWidgetByName("Label_equip_name_"..index, false)
        self:showWidgetByName("Panel_stars_equip_"..index, false)
	end

    if iconBack then 
        iconBack:setVisible(fightEquipment > 0)
    end

	if pingji then
		pingji:setVisible(fightEquipment > 0)
	end

    if starsPanel then
        starsPanel:setVisible(fightEquipment > 0)
    end
	self:showWidgetByName("ImageView_name_"..index, not fightEquipment or fightEquipment <= 0)
    self:showWidgetByName("Image_dot_"..index, false)

    if animation then 
        self:_playRoundEffect(iconImage)
    else
        if iconImage then 
            iconImage:removeAllNodes()
        end
    end
end

function HeroLayer:_loadTreasure ( teamId, index, animation )
	if index == nil or teamId ~= 1 then
		return 
	end

	local pos = (teamId == 1) and self._curHeroIndex or (self._curHeroIndex - 6)
	require("app.cfg.treasure_info")

	local pingji = self:getImageViewByName("ImageView_icon_"..(index + 4))
	local iconImage = self:getImageViewByName("ImageView_equip_"..(index + 4))
    local iconBack = self:getImageViewByName("Image_back_"..(index+ 4))
	local fightTreasure = G_Me.formationData:getFightTreasureBySlot(teamId, pos, index)
	if fightTreasure > 0 then
		local treasureInfo = G_Me.bagData.treasureList:getItemByKey(fightTreasure)
		if treasureInfo then
			local baseInfo = treasure_info.get(treasureInfo["base_id"])
        	if baseInfo then
				if iconImage then
					local imgPath = G_Path.getTreasureIcon(baseInfo.res_id)
	        		iconImage:loadTexture(imgPath, UI_TEX_TYPE_LOCAL)
        			--iconImage:setVisible(true)
				end

				if pingji then
					pingji:loadTexture(G_Path.getEquipColorImage(baseInfo.quality))
				end

				local pingjiPiece = self:getImageViewByName("ImageView_color_"..(index + 4))
				if pingjiPiece then
					pingjiPiece:loadTexture(G_Path.getAddtionKnightColorPieceImage(baseInfo.quality))
				end

                if iconBack then 
                    iconBack:loadTexture(G_Path.getEquipIconBack(baseInfo.quality))
                end

				local label = self:getLabelByName("Label_equip_name_"..(index + 4))
				if label then
					label:setVisible(true)
                    label:setColor(Colors.getColor(baseInfo.quality))
					label:setText(baseInfo.name)
				end

				self:showTextWithLabel("Label_"..(index + 4), ""..treasureInfo["level"])
				self:showWidgetByName("Label_"..(index + 4), true)

			end
		end
	else
		--local imgPath = G_Path.getEquipmentPartBack(index + 4)
	   -- iconImage:loadTexture(imgPath, UI_TEX_TYPE_LOCAL)
        --iconImage:setVisible(false)
		self:showWidgetByName("Label_"..(index + 4), false)
		self:showWidgetByName("Label_equip_name_"..(index + 4), false)
	end

    if iconBack then 
        iconBack:setVisible(fightTreasure > 0)
    end

    self:showWidgetByName("Image_dot_"..(index + 4), false)
	if pingji then
		pingji:setVisible(fightTreasure > 0)
	end
	self:showWidgetByName("ImageView_name_"..(index + 4), not fightTreasure or fightTreasure <= 0)

    if animation then 
        self:_playRoundEffect(iconImage)
    else
        if iconImage then 
            iconImage:removeAllNodes()
        end
    end
end

-- æˆ˜å® æŠ¤ä½‘
function HeroLayer:_loadPet(teamId, index, animation)
    
    if index == nil or teamId ~= 1 then
        return 
    end

    if G_Me.userData.level < function_level_info.get(funLevelConst.PET_PROTECT1).level - 5 then
        self:showWidgetByName("Panel_button_7",false)
        return
    else
        self:showWidgetByName("Panel_button_7",true)
    end

    local uiIndex = index + 6

    local pos = (teamId == 1) and self._curHeroIndex or (self._curHeroIndex - 6)

    local pingji = self:getImageViewByName("ImageView_icon_"..uiIndex)
    local iconImage = self:getImageViewByName("ImageView_equip_"..uiIndex)
    local iconBack = self:getImageViewByName("Image_back_"..uiIndex)

    local protectPet = G_Me.formationData:getProtectPetIdByPos(pos)

    if protectPet > 0 then

        local pet = G_Me.bagData.petData:getPetById(protectPet)
        local baseInfo = pet_info.get(pet.base_id)

        if baseInfo then
            if iconImage then
                local imgPath = G_Path.getPetIcon(baseInfo.res_id)
                iconImage:loadTexture(imgPath, UI_TEX_TYPE_LOCAL)
            end

            if pingji then
                pingji:loadTexture(G_Path.getEquipColorImage(baseInfo.quality))
            end

            local pingjiPiece = self:getImageViewByName("ImageView_color_"..uiIndex)
            if pingjiPiece then
                pingjiPiece:loadTexture(G_Path.getAddtionKnightColorPieceImage(baseInfo.quality))
            end

            if iconBack then 
                iconBack:loadTexture(G_Path.getEquipIconBack(baseInfo.quality))
            end

            local label = self:getLabelByName("Label_pet_name_"..uiIndex)
            if label then
                label:setVisible(true)
                label:setColor(Colors.getColor(baseInfo.quality))
                label:setText(baseInfo.name)
                label:createStroke(Colors.strokeBrown, 1)
            end
            local numLabel = self:getLabelByName("Label_"..uiIndex)
            numLabel:setText(""..pet["level"])
            numLabel:setVisible(true)
            numLabel:createStroke(Colors.strokeBrown, 1)

        end

    else
        if not G_Me.formationData:canShangZhenProtectPet() then
            self:showWidgetByName("Button_add_7",false)
        else
            self:showWidgetByName("Button_add_7",true)
        end

        self:showWidgetByName("Label_"..uiIndex, false)
        self:showWidgetByName("Label_pet_name_"..uiIndex, false)
    end

    if iconBack then 
        iconBack:setVisible(protectPet > 0)
    end

    if pingji then
        pingji:setVisible(protectPet > 0)
    end

    self:showWidgetByName("ImageView_name_"..uiIndex, not protectPet or protectPet <= 0)
    self:showWidgetByName("Image_dot_"..uiIndex, false)

    if animation then 
        self:_playRoundEffect(iconImage)
    else
        if iconImage then 
            iconImage:removeAllNodes()
        end
    end

end

function HeroLayer:_playRoundEffect( node )
    if not node then 
        return 
    end

    local around = nil
    around = EffectNode.new("effect_around1", 
        function(event)
            if event == "finish" and around then 
                around:removeFromParentAndCleanup(true)
                around = nil
             end
    end)
    node:addNode(around)
    around:setScale(2)
    around:play()

    around:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(2.2), CCRemove:create()))
end

function HeroLayer:_loadFightResourcesForKnight( teamId, pos )
	local teamId = self._curHeroIndex > 6 and 2 or 1

	self:_loadEquipment(teamId, 1)
	self:_loadEquipment(teamId, 2)
	self:_loadEquipment(teamId, 3)
	self:_loadEquipment(teamId, 4)
	
	self:_loadTreasure(teamId, 1)
	self:_loadTreasure(teamId, 2)

    self:_loadPet(teamId, 1)

    self:_checkEffectEquip({1, 2, 3, 4, 5, 6, 7})
end

return HeroLayer
