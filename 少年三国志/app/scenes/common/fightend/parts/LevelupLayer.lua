--LevelupLayer.lua

local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
require("app.cfg.role_info")
require("app.cfg.level_guide_info")
require("app.cfg.function_level_info")
local EffectNode = require "app.common.effects.EffectNode"

local FunctionLevelConst = require("app.const.FunctionLevelConst")

local LevelupLayer = class("LevelupLayer", UFCCSNormalLayer)


function LevelupLayer.create( ... )
	local levelup = LevelupLayer.new("ui_layout/fightend_LevelupLayer.json", _, ...)
	return levelup
--	uf_sceneManager:getCurScene():addChild(levelup)
end

function LevelupLayer:ctor( ... )
	self.super.ctor(self, ... )

	--self:showAtCenter(true)
end

function LevelupLayer:onLayerLoad( _, _, oldLevel, newLevel, callback )
	self._oldLevel = oldLevel or 1
	self._newLevel = newLevel or 2
	self._callback = callback
	self._openStampFlag = {}

	self:showWidgetByName("Image_click_continue", false)

	self:enableLabelStroke("Label_level_tile_1", Colors.strokeBrown, 2 )
	self:enableLabelStroke("Label_level_tile_2", Colors.strokeBrown, 2 )
	self:enableLabelStroke("Label_level_tile_3", Colors.strokeBrown, 2 )
	self:enableLabelStroke("Label_level_old_1", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_level_old_2", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_level_old_3", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_level_new_1", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_level_new_2", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_level_new_3", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_title_1", Colors.strokeBrown, 2 )
	self:enableLabelStroke("Label_title_2", Colors.strokeBrown, 2 )
	self:enableLabelStroke("Label_title_3", Colors.strokeBrown, 2 )

end

function LevelupLayer:onLayerEnter( ... )
	require("app.common.effects.EffectSingleMoving").run(self:getWidgetByName("Image_back"), "smoving_bounce", function ( ... )
		--self:setClickClose(true)

		--self:showWidgetByName("Image_click_continue", true)
		G_SoundManager:playSound(require("app.const.SoundConst").GameSound.KNIGHT_UPGRADE)
		
	end)

	self:showWidgetByName("Image_line_1", false)
	self:showWidgetByName("Image_line_2", false)
	self:showWidgetByName("Image_line_3", false)
	self:showWidgetByName("Panel_guide", false)

	self:_initUpgradeInfo()
	self:_initGuideItem()
	

	local around = EffectNode.new("effect_levelup", 
        function(event)
            if event == "finish" then 
            	self:_flyAttributes()
            end
    end)
    self:getWidgetByName("Panel_Root"):addNode(around)
    around:setPositionXY(self:getWidgetByName("Image_title"):getPosition())
    around:play()
end

function LevelupLayer:_flyAttributes( ... )
	self:showWidgetByName("Image_line_1", true)
	self:showWidgetByName("Image_line_2", true)
	self:showWidgetByName("Image_line_3", true)
	self:showWidgetByName("Panel_guide", true)
	GlobalFunc.flyIntoScreenLR({self:getWidgetByName("Panel_1"), 
                self:getWidgetByName("Panel_2"), 
                self:getWidgetByName("Panel_3")}, true, 0.4, 2, 50)

	GlobalFunc.flyIntoScreenLR({self:getWidgetByName("Panel_guide_1"), 
                self:getWidgetByName("Panel_guide_2"), 
                self:getWidgetByName("Panel_guide_3")}, false, 0.4, 2, 50, function ( ... )
                self:_showOpenStamp()
                self:_showAndPlayFinger()
                --EffectSingleMoving.run(self:getWidgetByName("Image_click_continue"), "smoving_wait", nil , {position = true} )
                if self._callback then 
    				self._callback()
    			end
           end)
end

function LevelupLayer:_showOpenStamp( ... )
	local openStampIndex = 0
	for key, value in pairs(self._openStampFlag) do 
			openStampIndex = openStampIndex + 1

			if openStampIndex == 1 then
				self:showWidgetByName("Image_open"..key, true)
				GlobalFunc.flyDown({self:getWidgetByName("Image_open"..key)}, 0.3, 0, 5, function ( ... ) 
				end)
			else
				self:callAfterFrameCount(10*(openStampIndex - 1), function ( ... )
					self:showWidgetByName("Image_open"..key, true)
					GlobalFunc.flyDown({self:getWidgetByName("Image_open"..key)}, 0.3, 0, 5, function ( ... ) 
					end)	
				end)
			end
	end
end

function LevelupLayer:_initUpgradeInfo( ... )
	self:showTextWithLabel("Label_level_old_1", self._oldLevel)
	self:showTextWithLabel("Label_level_new_1", self._newLevel)

	local newRoleInfo = role_info.get(self._newLevel)
	if newRoleInfo then 
		self:showTextWithLabel("Label_level_old_2", G_Me.userData.vit - newRoleInfo.power_recover)
		self:showTextWithLabel("Label_level_old_3", G_Me.userData.spirit - newRoleInfo.energy_recover)
		self:showTextWithLabel("Label_level_new_2", G_Me.userData.vit )
		self:showTextWithLabel("Label_level_new_3", G_Me.userData.spirit)
	end
end


function LevelupLayer:_lackOfForthHero()
    if not G_moduleUnlock:isModuleUnlock(FunctionLevelConst.BATTLE_ARRAY_4) then
        return false
    end

    local mainTeamHeroCount = G_Me.formationData:getFormationHeroCount(1)
    return mainTeamHeroCount < 4
end

function LevelupLayer:_showFingerAtWidget( widget )
    if not widget then 
        return 
    end

    local EffectNode = require "app.common.effects.EffectNode"
    self._fingerEffect = EffectNode.new("effect_finger") 
    --self._fingerEffect:setPositionXY(widget:getPosition())
    widget:addNode(self._fingerEffect)
    self._fingerEffect:setVisible(false)
end

function LevelupLayer:_showAndPlayFinger( ... )
	if not self._fingerEffect then 
		return 
	end

	local parent = self._fingerEffect:getParent()
	if not parent then 
		assert(0)
	end

	local posx, posy = parent:convertToWorldSpaceXY(0, 0)
	posx, posy = self:convertToNodeSpaceXY(posx, posy)
	self._fingerEffect:retain()
	self._fingerEffect:removeFromParentAndCleanup(false)
	self._fingerEffect:setPositionXY(posx, posy)
	self:addChild(self._fingerEffect)
	self._fingerEffect:release()
	self._fingerEffect:setVisible(true)
	self._fingerEffect:play()
end

function LevelupLayer:_initGuideItem( ... )
	local levelGuideInfo = level_guide_info.get(self._newLevel)
	if not levelGuideInfo then 
		self:showWidgetByName("Panel_guide", false)
		return 
	end

	local guideInfo = {}
	local levelValue = 0
	if levelGuideInfo.type_1 > 0 then 
		levelValue = function_level_info.get(levelGuideInfo.type_1)
		if levelValue then
			table.insert(guideInfo, #guideInfo + 1, {level = levelValue.level, value = levelValue})
		end
	end

	if levelGuideInfo.type_2 > 0 then 
		levelValue = function_level_info.get(levelGuideInfo.type_2)
		if levelValue then
			table.insert(guideInfo, #guideInfo + 1, {level = levelValue.level, value = levelValue})
		end
	end

	if levelGuideInfo.type_3 > 0 then 
		levelValue = function_level_info.get(levelGuideInfo.type_3)
		if levelValue then
			table.insert(guideInfo, #guideInfo + 1, {level = levelValue.level, value = levelValue})
		end
	end

	local _sortFun = function ( data1, data2 )
		if data1.level == self._newLevel then 
			return true 
		end
		if data2.level == self._newLevel then 
			return false
		end

		return data1.level < data2.level
	end

	table.sort(guideInfo, _sortFun)

	for key, value in pairs(guideInfo) do 
		local flag = (value.level > self._oldLevel and value.level <= self._newLevel) and 1 or 0
		if flag == 1 then
			table.insert(self._openStampFlag, #self._openStampFlag + 1, flag)
		end
	end

	local loopi = 1
	for key, value in pairs(guideInfo) do 
		self:getImageViewByName("Image_icon_"..loopi):loadTexture(G_Path.getBasicIconById(value.value.icon), UI_TEX_TYPE_LOCAL)
		self:showTextWithLabel("Label_title_"..loopi, value.value.name)
		self:showTextWithLabel("Label_desc_"..loopi, value.value.directions)

		local isGuiding = G_GuideMgr and G_GuideMgr:isCurrentGuiding()
		local willDoGuide = ((value.value.level == self._newLevel) and (value.value.step_id > 0))
		local showTip = (value.value.level > self._newLevel) or willDoGuide or (not willDoGuide and isGuiding)
		self:showWidgetByName("Label_tip_"..loopi, showTip)

		local inactiveGuide = ((value.value.level == self._newLevel) and (value.value.step_id < 1))
		self:showWidgetByName("Button_do_"..loopi, not isGuiding and ((value.value.level < self._newLevel ) or inactiveGuide))

		--__Log("isGuiding:%d, willDoGuide:%d, showtip:%d, inactiveGuide:%d, value.level:%d, newLevel:%d",
		--	isGuiding and 1 or 0, willDoGuide and 1 or 0, showTip and 1 or 0, inactiveGuide and 1 or 0, 
		--	value.value.level, self._newLevel)

		local label = self:getLabelByName("Label_tip_"..loopi)
		if value.value.level > self._newLevel then 
			label:setColor(Colors.titleRed)
			label:setText(G_lang:get("LANG_UPGRADE_OPEN_FORMAT", {levelValue=value.value.level}))
		elseif showTip then 
			label:setColor(ccc3(0x5d, 0x96, 0x04))
			label:setText(G_lang:get("LANG_UPGRADE_OPEN_DESC"))
		end

		self:showWidgetByName("Image_highlight_"..loopi, value.value.level <= self._newLevel)
		self:registerBtnClickEvent("Button_do_"..loopi, function ( widget )
			self:_onClickGuideItem(value.value.id)
		end)

		if (value and value.value.id == FunctionLevelConst.BATTLE_ARRAY_4) and self:_lackOfForthHero() then 
			self:_showFingerAtWidget(self:getWidgetByName("Button_do_"..loopi))
			self:_hookerGuideItemClick()
		end

		loopi = loopi + 1
	end

	for loopi = loopi, 3 do 
		self:showWidgetByName("Panel_guide_"..loopi, false)
	end	
end

function LevelupLayer:_hookerGuideItemClick( ... )
	local oldGuideItemClick = self._onClickGuideItem
	self._onClickGuideItem = function ( obj, funId )
		if funId == FunctionLevelConst.BATTLE_ARRAY_4 then 
			local BattleGuideFunction = require("app.scenes.common.fightend.BattleGuideFunction")
			BattleGuideFunction.linkSceneByType(BattleGuideFunction.HERO_SHANGZHENG_FORTH)
		else
			oldGuideItemClick(obj, funId)
		end
	end
end

function LevelupLayer:_onClickGuideItem( funId )
	local sceneName = nil
	if funId == FunctionLevelConst.STORY_DUNGEON then 
		sceneName = "DungeonMainScene"
	elseif funId == FunctionLevelConst.ARENA_SCENE then 
		sceneName = "ArenaScene"
	elseif funId == FunctionLevelConst.TREASURE_COMPOSE then 
		sceneName = "TreasureComposeScene"
	elseif funId == FunctionLevelConst.TOWER_SCENE then 
		sceneName = "WushScene"
	elseif funId == FunctionLevelConst.KNIGHT_STRENGTH then 
		sceneName = "HeroFosterScene"
	elseif funId == FunctionLevelConst.KNIGHT_JINGJIE then 
		sceneName = "HeroFosterScene"
	elseif funId == FunctionLevelConst.EQUIP_STRENGTH then
		sceneName = "EquipmentMainScene" 
	elseif funId == FunctionLevelConst.SECRET_SHOP then 
		sceneName = "SecretShopScene"
	elseif funId == FunctionLevelConst.DUNGEON_SAODANG then 
		sceneName = "DungeonMainScene"
	elseif funId == FunctionLevelConst.BATTLE_ARRAY_2 or 
		   funId == FunctionLevelConst.BATTLE_ARRAY_3 or 
		   funId == FunctionLevelConst.BATTLE_ARRAY_4 or 
		   funId == FunctionLevelConst.BATTLE_ARRAY_5 or 
		   funId == FunctionLevelConst.BATTLE_ARRAY_6 then 
		sceneName = "HeroScene"
	elseif funId == FunctionLevelConst.TREASURE_STRENGTH then 
		sceneName = "TreasureMainScene"
	elseif funId == FunctionLevelConst.TREASURE_TRAINING then 
		sceneName = "TreasureMainScene"
	elseif funId == FunctionLevelConst.EQUIP_TRAINING then 
		sceneName = "EquipmentMainScene"
	elseif funId == FunctionLevelConst.KNIGHT_GUANGHUAN then 
		sceneName = "HeroFosterScene"
	elseif funId == FunctionLevelConst.KNIGHT_TRAINING then 
		sceneName = "HeroFosterScene"
	elseif funId == FunctionLevelConst.MOSHENG_SCENE then 
		sceneName = "MoShenScene"
	elseif funId == FunctionLevelConst.BATTLE_RATE_2 then 
		sceneName = "DungeonMainScene"
	elseif funId == FunctionLevelConst.BATTLE_RATE_3 then
		sceneName = "DungeonMainScene" 
	elseif funId == FunctionLevelConst.PARTNER_ARRAY_1 or  
		   funId == FunctionLevelConst.PARTNER_ARRAY_2 or  
		   funId == FunctionLevelConst.PARTNER_ARRAY_3 or  
		   funId == FunctionLevelConst.PARTNER_ARRAY_4 or 
		   funId == FunctionLevelConst.PARTNER_ARRAY_5 or  
		   funId == FunctionLevelConst.PARTNER_ARRAY_6 then
		sceneName = "HeroScene" 
	elseif funId == FunctionLevelConst.VIP_SCENE then 
		sceneName = "VipMapScene"
	elseif funId == FunctionLevelConst.CHAT then 
		sceneName = "MainScene"
	elseif funId == FunctionLevelConst.STRENGTH_FIVE_TIMES then
		sceneName = "EquipmentMainScene" 
	elseif funId == FunctionLevelConst.MING_XING_MODULE then 
		sceneName = "SanguozhiMainScene"
	elseif funId == FunctionLevelConst.ZHEN_YING_ZHAO_MU then 
		sceneName = "ShopScene"
	elseif funId == FunctionLevelConst.HALLOFFRAME_SCENE then
		sceneName = "HallOfFrameScene"
	elseif funId == FunctionLevelConst.CITY_PLUNDER then 
		sceneName = "CityScene"
	elseif funId == FunctionLevelConst.LEGION then
        if G_Me.legionData:hasCorp() then
            sceneName = "LegionScene"
        else
            sceneName = "LegionListScene"
        end   
	elseif funId == FunctionLevelConst.DRESS then
		sceneName = "DressMainScene"
	elseif funId == FunctionLevelConst.TREASURE_ROB_5_TIMES then
		sceneName = "TreasureComposeScene"
	end

__Log("funId:%d, sceneName:%s, scenePath:%s", funId, sceneName, GlobalFunc.getScenePath(sceneName))
	if sceneName then 
		uf_sceneManager:popToRootAndReplaceScene(require(GlobalFunc.getScenePath(sceneName)).new())
	end
end

return LevelupLayer
