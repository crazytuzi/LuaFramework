--SpecialActivityTargetListItem.lua
require("app.cfg.special_holiday_info")
local SpecialActivityMainLayer = require("app.scenes.specialActivity.SpecialActivityMainLayer")

local FunctionLevelConst = require("app.const.FunctionLevelConst")
local FuCommon = require("app.scenes.dafuweng.FuCommon")

local SpecialActivityTargetListItem = class("SpecialActivityTargetListItem", function ( ... )
	return CCSItemCellBase:create("ui_layout/specialActivity_TargetListItem.json")
end)

function SpecialActivityTargetListItem:ctor( ... )
	self:attachImageTextForBtn("Button_get", "Image_34")

	self:enableLabelStroke("Label_name_1", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_name_2", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_name_3", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_name_4", Colors.strokeBrown, 1 )

	self._titleLabel = self:getLabelByName("Label_itemName")
	self._timesTitleLabel = self:getLabelByName("Label_timesTitle")
	self._timesLabel = self:getLabelByName("Label_times")

	self._getButton = self:getButtonByName("Button_get")
	self._goButton = self:getButtonByName("Button_go")
	self._rechargeButton = self:getButtonByName("Button_recharge")
	self._flagImg = self:getImageViewByName("Image_flag")

	self:registerBtnClickEvent("Button_get", function (  )
		G_HandlersManager.specialActivityHandler:sendGetSpecialHolidayActivityReward(self._data.id)
		end)
	self:registerBtnClickEvent("Button_go", function (  )
		if self:checkTime() then
			self:_clickGo(self._data.task_type)
		end
		end)
	self:registerBtnClickEvent("Button_recharge", function (  )
		if self:checkTime() then
			require("app.scenes.shop.recharge.RechargeLayer").show()
		end
		end)
	for i = 1 , 4 do 
		self:registerWidgetClickEvent("Image_icon_"..i,function (  )
			require("app.scenes.common.dropinfo.DropInfo").show(self._data["type_"..i],self._data["value_"..i]) 
		end)
	end

	self:initRichLabel()
	local EffectNode = require "app.common.effects.EffectNode"
	self.node = EffectNode.new("effect_around2")     
	self.node:setScale(1.4) 
	self._getButton:addNode(self.node)
	self.node:play()
	self.node:setVisible(false)
end

function SpecialActivityTargetListItem:initRichLabel( )
	local label = self:getLabelByName("Label_itemName")
	label:setVisible(false)
	local clr = label:getColor()
	self._labelClr = ccc3(clr.r, clr.g, clr.b)
	self._richText = CCSRichText:create(600, 45)
	self._richText:setFontName(label:getFontName())
	self._richText:setFontSize(label:getFontSize())
	local x, y = label:getPosition()
	self._richText:setPosition(ccp(x+285, y-5))
	self._richText:setShowTextFromTop(true)
	local parent = label:getParent()
	if parent then
	    parent:addChild(self._richText, 5)
	end
end

function SpecialActivityTargetListItem:updateData( data )
	self._data = data
	self._curInfo = G_Me.specialActivityData:getCurInfo(data.id)
	local progress = self._curInfo and self._curInfo.progress or 0
	local awardCount = self._curInfo and self._curInfo.award_count or 0
	local canAward = self._curInfo and self._curInfo.can_award or false
	local progressNum = math.min(progress, data.task_value1)
	local strings = "<root><text color='5258818' value='"..data.directions.."'/></root>"
	strings = string.gsub(strings,"([^/])X","%1' /><text color='12922112' value='X' /><text color='5258818' value='")
	strings = string.gsub(strings,"([^/])Y","%1' /><text color='12922112' value='Y' /><text color='5258818' value='")
	strings = string.gsub(strings,"X","#task_value1#")
	strings = string.gsub(strings,"Y","#task_value2#")
	strings = G_lang:getByString(strings,{num1=progressNum,task_value1=data.task_value1,task_value2=data.task_value2})
	
	self._richText:clearRichElement()
	self._richText:appendContent(strings, self._labelClr)
	self._richText:reloadData()

	self._timesTitleLabel:setVisible(data.task_type == 1 and data.task_value2 > 0)
	self._timesLabel:setVisible(data.task_type == 1 and data.task_value2 > 0)
	if data.task_type == 1 and data.task_value2 > 0 then
		self._timesLabel:setText(data.task_value2-awardCount.."/"..data.task_value2)
	end

	for i = 1 , 4 do 
		if data["type_"..i] > 0 then
			local g = G_Goods.convert(data["type_"..i], data["value_"..i])
			self:getImageViewByName("Image_item_"..i):setVisible(true)
			self:getImageViewByName("Image_icon_"..i):loadTexture(g.icon)
			self:getImageViewByName("Image_pingji_"..i):loadTexture(G_Path.getEquipColorImage(g.quality,data["type_"..i]))
			self:getImageViewByName("Image_back_"..i):loadTexture(G_Path.getEquipIconBack(g.quality))
			self:getLabelByName("Label_name_"..i):setText("x"..GlobalFunc.ConvertNumToCharacter4(data["size_"..i]))
		else
			self:getImageViewByName("Image_item_"..i):setVisible(false)
		end
	end

	local canGet = canAward
	-- local canGet = (data.tags == SpecialActivityMainLayer.TAB1 and progress >= 1) or (data.tags ~= SpecialActivityMainLayer.TAB1 and progress >= data.task_value1)
	local hasGot = (data.task_type == 1 and data.task_value2 > 0 and awardCount >= data.task_value2) or (data.task_type ~= 1 and awardCount >= 1)
	self._rechargeButton:setVisible(data.task_type == 1 and not canGet and not hasGot)
	self._goButton:setVisible(data.task_type ~= 1 and not canGet and not hasGot)
	self._getButton:setVisible(not hasGot and canGet)
	self.node:setVisible(not hasGot and canGet)
	self._flagImg:setVisible(hasGot)

	if data.task_type == 43 and not canGet and not hasGot then
		self._rechargeButton:setVisible(false)
		self._goButton:setVisible(false)
		self._getButton:setVisible(false)
		self._flagImg:setVisible(true)
		self._flagImg:loadTexture("ui/text/txt/weidacheng.png")
	else
		self._flagImg:loadTexture("ui/text/txt/jqfb_yilingqu.png")
	end
end

function SpecialActivityTargetListItem:_clickGo( taskType )

	local sceneType = 0
	local sceneName = nil
	if (taskType >= 2 and taskType <= 13) or taskType == 17 or taskType == 18 or taskType == 42 or taskType == 44 then
		sceneName = "HeroScene"
	elseif taskType >= 14 and taskType <= 16 then 
		sceneName = "DressMainScene"
		sceneType = FunctionLevelConst.DRESS
	elseif taskType >= 18 and taskType <= 22 then 
		sceneName = "PetBagMainScene"
		sceneType = FunctionLevelConst.PET
	elseif taskType == 23 then 
		if G_Me.richData:getState() == FuCommon.STATE_CLOSE  then
		    G_MovingTip:showMovingTip(G_lang:get("LANG_FU_NOACT"))
		    return 
		end
		sceneName = "RichScene"
		sceneType = FunctionLevelConst.RICHMAN
	elseif taskType == 24 then 
		sceneName = "WushScene"
		sceneType = FunctionLevelConst.TOWER_SCENE
	elseif taskType == 25 then
		sceneName = "TreasureComposeScene" 
		sceneType = FunctionLevelConst.TREASURE_COMPOSE
	elseif taskType == 26 or taskType == 27 then 
		if G_Me.groupBuyData:isOpen() then
		    sceneName = "GroupBuyScene"
		else
		    G_MovingTip:showMovingTip(G_lang:get("LANG_GROUP_BUY_END_OVER"))
		    return
		end
	elseif taskType == 28 then 
		sceneName = "HardDungeonMainScene" 
		sceneType = FunctionLevelConst.HARDDUNGEON
	elseif taskType >= 29 and taskType <= 31 then 
		sceneName = "MoShenScene" 
		sceneType = FunctionLevelConst.MOSHENG_SCENE
	elseif taskType >= 32 and taskType <= 34 then 
		if G_Me.wheelData:getState() == FuCommon.STATE_CLOSE  then
		    G_MovingTip:showMovingTip(G_lang:get("LANG_FU_NOACT"))
		    return 
		end
		sceneName = "WheelScene"
		sceneType = FunctionLevelConst.WHEEL
	elseif taskType == 35 then 
		sceneName = "DungeonMainScene"
	elseif taskType == 36 or taskType == 37 then 
		if G_Me.legionData:hasCorp() then
		    sceneName = "LegionScene"
		else 
		    sceneName = "LegionListScene"
		end   
		sceneType = FunctionLevelConst.LEGION
	elseif taskType == 38 or taskType == 39 then 
		if G_Me.trigramsData:getState() == FuCommon.STATE_CLOSE then
		        G_MovingTip:showMovingTip(G_lang:get("LANG_FU_NOACT"))
		        return 
		end
		sceneName = "TrigramsScene"
		sceneType = FunctionLevelConst.TRIGRAMS
	elseif taskType == 40 or taskType == 41 then 
		sceneName = "PetShopScene"
		sceneType = FunctionLevelConst.PET_SHOP
	elseif taskType == 45 then 
		sceneName = "HeroSoulScene"
		sceneType = FunctionLevelConst.HERO_SOUL
	end

	if sceneType > 0 and not G_moduleUnlock:checkModuleUnlockStatus(sceneType) then 
		return 
	end
	-- print(taskType,sceneName,GlobalFunc.getScenePath(sceneName))
	if sceneName then 
		uf_sceneManager:popToRootAndReplaceScene(require(GlobalFunc.getScenePath(sceneName)).new(nil, nil, nil, nil, GlobalFunc.sceneToPack("app.scenes.specialActivity.SpecialActivityScene")))
	end
end

function SpecialActivityTargetListItem:checkTime( )
	local arr1 = G_ServerTime:getLeftSeconds(self._data.start_time)
	local arr2 = G_ServerTime:getLeftSeconds(self._data.end_time)
	if arr1 > 0 then
		G_MovingTip:showMovingTip(G_lang:get("LANG_SPECIAL_ACTIVITY_BUYTIME_AFTER"))
		return false
	end
	if arr2 < 0 then
		G_MovingTip:showMovingTip(G_lang:get("LANG_SPECIAL_ACTIVITY_BUYTIME_BEFORE"))
		return false
	end
	return true
end

return SpecialActivityTargetListItem