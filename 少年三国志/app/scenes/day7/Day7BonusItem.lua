--Day7BonusItem.lua

require("app.cfg.days7_activity_info")
local FunctionLevelConst = require("app.const.FunctionLevelConst")

local Days7ActivityData = require("app.data.Days7ActivityData")

local Day7BonusItem = class("Day7BonusItem", function ( ... )
	return CCSItemCellBase:create("ui_layout/day7_ListItem.json")
end)

function Day7BonusItem:ctor( ... )
	self:attachImageTextForBtn("Button_get", "Image_34")

	self:enableLabelStroke("Label_name_1", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_name_2", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_name_3", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_name_4", Colors.strokeBrown, 1 )
end

function Day7BonusItem:updateItem( bonusId )
	bonusId = bonusId or 0

	local activityInfo = days7_activity_info.get(bonusId)
	if not activityInfo then
		return 
	end

	self:showTextWithLabel("Panel_title", activityInfo.directions)

	local _showItem = function ( typeId, valueId, count, index )
		if typeId < 1 or count < 1 then 
			return false
		end

		index = index or 1
		local goodInfo = G_Goods.convert(typeId, valueId, count)
		if not goodInfo then 
			return false
		end

		self:showWidgetByName("Image_item_"..index, true)

		local image = self:getImageViewByName("Image_icon_"..index)
		if image then 
			image:loadTexture(goodInfo.icon, UI_TEX_TYPE_LOCAL)
		end

		image = self:getImageViewByName("Image_pingji_"..index)
		if image then 
			if typeId == G_Goods.TYPE_FRAGMENT then
				image:loadTexture(G_Path.getEquipColorImage(goodInfo.quality, G_Goods.TYPE_FRAGMENT))
			else
				image:loadTexture(G_Path.getAddtionKnightColorImage(goodInfo.quality))
			end
		end

		image = self:getImageViewByName("Image_back_"..index)
		if image then 
			image:loadTexture(G_Path.getEquipIconBack(goodInfo.quality))
		end

		self:showTextWithLabel("Label_name_"..index, "x"..G_GlobalFunc.ConvertNumToCharacter3(count))

		self:registerWidgetClickEvent("Image_icon_"..index, function ( ... )
			require("app.scenes.common.dropinfo.DropInfo").show(typeId, valueId) 
		end)

		return true
	end

	local flagImg = self:getImageViewByName("Image_flag")
	local completeNum = 0
	local status = Days7ActivityData.ACTIVITY_STATUS.CLOSED
	local activityData = G_Me.days7ActivityData:getActivityInfoById(bonusId)
	if activityData then 
		completeNum = activityData.progress
		status = activityData.status
	end

		local isOpen = (status == Days7ActivityData.ACTIVITY_STATUS.OPEN)
		
		if isOpen then
			self:showWidgetByName("Button_get", true)
			self:showWidgetByName("Button_go", false)
			flagImg:setVisible(false)

		else
			self:showWidgetByName("Button_get", false)


			local isOver = status == Days7ActivityData.ACTIVITY_STATUS.OVER

			if isOver then
				--yilingqu
				self:showWidgetByName("Button_go", false)
				flagImg:setVisible( true)
				flagImg:loadTexture("ui/text/txt/jqfb_yilingqu.png")


				 -- and 
					-- "ui/text/txt/weidacheng.png" or "ui/text/txt/jqfb_yilingqu.png")
			else
				--weidacheng

				if G_Me.days7ActivityData:isActivityOverTime() then 
					self:showWidgetByName("Button_go", false)
					flagImg:setVisible( true)
					flagImg:loadTexture("ui/text/txt/weidacheng.png")

				else
					local hasGoStatus = self:_initGoBtn(activityInfo.task_type, activityInfo.limit_time_client)
					if hasGoStatus then
						self:showWidgetByName("Button_go", true)
						flagImg:setVisible( false)

						local btnImg = self:getImageViewByName("Image_go_image")
						if activityInfo.task_type == 1 or activityInfo.task_type == 2 then 
							btnImg:loadTexture("ui/text/txt-small-btn/quchongzhi.png")
						else
							btnImg:loadTexture("ui/text/txt-small-btn/qianwang.png")
						end	
					else
						self:showWidgetByName("Button_go", false)
						flagImg:setVisible( true)
						flagImg:loadTexture("ui/text/txt/weidacheng.png")

					end
					
				end
			end



		end

	



		
	-- else
	-- 	__Log("activityData is nil for bonusId:%d", bonusId)
	-- 	self:showWidgetByName("Button_go", false)
	-- 	self:showWidgetByName("Button_get", false)
	-- 	flagImg:setVisible(true)
	-- 	flagImg:loadTexture("ui/text/txt/weidacheng.png")
	-- end

	self:showTextWithLabel("Label_itemName", G_GlobalFunc.formatText(activityInfo.directions, 
				{num1 = completeNum}) )

	local index = 1
	if _showItem(activityInfo.type_1, activityInfo.value_1, activityInfo.size_1, index) then 
		index = index + 1
	end
	if _showItem(activityInfo.type_2, activityInfo.value_2, activityInfo.size_2, index) then 
		index = index + 1
	end
	if _showItem(activityInfo.type_3, activityInfo.value_3, activityInfo.size_3, index) then 
		index = index + 1
	end
	if _showItem(activityInfo.type_4, activityInfo.value_4, activityInfo.size_4, index) then 
		index = index + 1
	end

	for loopi = index , 4 do 
		self:showWidgetByName("Image_item_"..loopi, false)
	end

	self:registerBtnClickEvent("Button_get", function()
		if activityInfo.reward_type == 2 then 
			require("app.scenes.sanguozhi.SanguozhiSelectAwardLayer").show(activityInfo, function ( selectIndex )
				G_HandlersManager.daysActivityHandler:sendFinishDaysActivity(bonusId, selectIndex or 1)
			end)
		else
			G_HandlersManager.daysActivityHandler:sendFinishDaysActivity(bonusId, 0)
		end				
	end)
end

function Day7BonusItem:_initGoBtn( taskType, dayIndex )
	-- if type(taskType) ~= "number" then 
	-- 	return false
	-- end

	local sceneType = 0
	local sceneName = nil
	if taskType == 1 or taskType == 2 then 
		self:registerBtnClickEvent("Button_go", function ( ... )
			require("app.scenes.shop.recharge.RechargeLayer").show()
			end)
		return true
	elseif taskType == 3 or taskType == 4 then 
		sceneName = "DungeonMainScene"
	elseif taskType == 5 or taskType == 6 or taskType == 11 or
	 taskType == 12 or taskType == 16 then 
		sceneName = "HeroScene"
	elseif taskType == 22 or taskType == 23 then 
		sceneName = "TreasureMainScene"
	elseif taskType == 7 then 
		sceneName = "ArenaScene"
		sceneType = FunctionLevelConst.ARENA_SCENE
	elseif taskType == 8 then 
		sceneName = "TreasureComposeScene"
		sceneType = FunctionLevelConst.TREASURE_COMPOSE
	elseif taskType == 9 or taskType == 10 or taskType == 21 then 
		sceneName = "WushScene"
		sceneType = FunctionLevelConst.TOWER_SCENE
	elseif taskType == 13 or taskType == 14 then 
		sceneName = "MoShenScene"
		sceneType = FunctionLevelConst.MOSHENG_SCENE
	elseif taskType == 15 then
		sceneName = "ShopScene" 
	elseif taskType == 17 then 
		sceneName = "HeroFosterScene"
	elseif taskType == 18 then 
		sceneName = "StoryDungeonMainScene" 
		sceneType = FunctionLevelConst.STORY_DUNGEON
	elseif taskType == 19 or taskType == 20 then 
		sceneName = "SecretShopScene" 
	end

	self:registerBtnClickEvent("Button_go", function ( ... )
		if sceneType > 0 and not G_moduleUnlock:checkModuleUnlockStatus(sceneType) then 
			return 
		end

		if sceneName then 
			uf_sceneManager:popToRootAndReplaceScene(require(GlobalFunc.getScenePath(sceneName)).new(nil, nil, nil, nil, GlobalFunc.sceneToPack("app.scenes.day7.Day7Scene", {dayIndex})))
		end
	end)

	return sceneName ~= nil
end

return Day7BonusItem