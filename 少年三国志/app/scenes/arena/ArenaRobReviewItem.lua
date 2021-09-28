-- 战况回顾条目


local ArenaRobReviewItem = class("ArenaRobReviewItem", function ( ... )
	return CCSItemCellBase:create("ui_layout/arena_RobReviewItem.json")
end)


function ArenaRobReviewItem:ctor( ... )
	self._nameLabel = self:getLabelByName("Label_Name")
	self._levelLabel = self:getLabelByName("Label_level")
	self._robRiceLabel = self:getLabelByName("Label_Rob_Rice")	
	self._knightPic = self:getImageViewByName("ImageView_knight")
	self._qualityBtn = self:getButtonByName("Button_knight")

	self:_createStrokes()
end

function ArenaRobReviewItem:_createStrokes( ... )
	self._nameLabel:createStroke(Colors.strokeBrown, 1)
end

function ArenaRobReviewItem:updateCell( enemyInfo , callbackLineUp, callbackRevenge)
	self._enemyInfo = enemyInfo

	-- 要先把各个空间的状态置为最初始时默认的状态
	self:showWidgetByName("Panel_Revenge_Words", false)
	self:showWidgetByName("Panel_Lose_Words", false)
	self:showWidgetByName("Button_Revenge", true)
	self:getButtonByName("Button_Revenge"):setTouchEnabled(true)

	local knightPic = require("app.scenes.common.KnightPic")
    local knight = knight_info.get(enemyInfo.base_id)
    if not knight then
        return
    end

	self._nameLabel:setText(enemyInfo.name)
	self._nameLabel:setColor(Colors.qualityColors[knight.quality])
	self._levelLabel:setText(G_lang:get("LANG_ROB_RICE_LEVEL", {num = enemyInfo.level}))
	self._robRiceLabel:setText(G_lang:get("LANG_ROB_RICE_RICE_2", {num = enemyInfo.rob_rice}))


	local res_id = G_Me.dressData:getDressedResidWithClidAndCltm(enemyInfo.base_id, enemyInfo.dress_base,enemyInfo.clid,enemyInfo.cltm , enemyInfo.clop)
	self._knightPic:loadTexture(G_Path.getKnightIcon(res_id))

	self._qualityBtn:loadTextureNormal(G_Path.getEquipColorImage(knight.quality,G_Goods.TYPE_KNIGHT))
	self._qualityBtn:loadTexturePressed(G_Path.getEquipColorImage(knight.quality,G_Goods.TYPE_KNIGHT))

	if enemyInfo.rob_result == 0 then
		self:showWidgetByName("Button_Revenge", false)
		self:showWidgetByName("Panel_Lose_Words", true)
		self:showWidgetByName("Panel_Win_Words", false)
	else
		self:showWidgetByName("Panel_Win_Words", true)
		self:showWidgetByName("Panel_Lose_Words", false)
	end

	self:registerBtnClickEvent("Button_Check_Line_Up", function ( ... )
		if callbackLineUp then
			callbackLineUp()
		end
	end)

	self:registerBtnClickEvent("Button_Revenge", function ( ... )
		if callbackRevenge then
			callbackRevenge()
		end
	end)

	self:attachImageTextForBtn("Button_Revenge","Image_23")

	-- 如果已复仇则复仇按钮置灰
	if enemyInfo.revenge == 1 then
		__Log("enemyInfo.revenge == 1")
		self:getButtonByName("Button_Revenge"):setTouchEnabled(false)
	end

	-- 自己曾经攻打过的玩家，别人复仇打败了你
	if enemyInfo.revenge == 2 then
		self:showWidgetByName("Panel_Win_Words", false)
		self:showWidgetByName("Panel_Lose_Words", false)
		self:showWidgetByName("Panel_Revenge_Words", true)
		self:showWidgetByName("Button_Revenge", false)

		self:getLabelByName("Label_Rob_Rice_Revenge"):setText(G_lang:get("LANG_ROB_RICE_RICE_2", {num = enemyInfo.rob_rice}))
	end
end


return ArenaRobReviewItem