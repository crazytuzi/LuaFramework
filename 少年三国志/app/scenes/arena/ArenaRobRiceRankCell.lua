-- 争粮战中粮草排行榜的条目

local ArenaRobRiceRankCell = class("ArenaRobRiceRankCell", function ( ... )
	return CCSItemCellBase:create("ui_layout/arena_RobRiceRankingListItem.json")
end)


function ArenaRobRiceRankCell:ctor( ... )
	self._knightPic = self:getImageViewByName("ImageView_knight")
	self._levelLabel = self:getLabelByName("Label_level")
	self._nameLabel = self:getLabelByName("Label_name")
	-- 背景图片
	self._bgImage = self:getImageViewByName("ImageView_bg_2")   
	-- 排名奖励信息部分的背景图片
	self._bgInnerBoard = self:getImageViewByName("Image_Inner_Board_Bg")

	self._riceLabel = self:getLabelByName("Label_Rice")
	self._fightValueLabel = self:getLabelByName("Label_Fight_Value")
	self._rankLabel = self:getLabelBMFontByName("LabelBMFont_rank")
	self._rankImageView = self:getImageViewByName("ImageView_rank")
	self._qualityBtn = self:getButtonByName("Button_knight")
end


function ArenaRobRiceRankCell:updateCell( user, callbackLineup )
	if user == nil then return end

	if user.user_id == G_Me.userData.id then
		self._bgImage:loadTexture("board_red.png",UI_TEX_TYPE_PLIST)
		self._bgInnerBoard:loadTexture("list_board_red.png", UI_TEX_TYPE_PLIST)
	else
		self._bgImage:loadTexture("board_normal.png",UI_TEX_TYPE_PLIST)
		self._bgInnerBoard:loadTexture("list_board.png", UI_TEX_TYPE_PLIST)
	end
	local knight = knight_info.get(user.base_id)

	local res_id = G_Me.dressData:getDressedResidWithClidAndCltm(user.base_id,user.dress_base,user.clid,user.cltm , user.clop)
	self._knightPic:loadTexture(G_Path.getKnightIcon(res_id))

	self._nameLabel:setColor(Colors.qualityColors[knight.quality])
	self._nameLabel:setText(user.name)
	self._nameLabel:createStroke(Colors.strokeBrown, 1)

	self._levelLabel:setText(G_lang:get("LANG_ROB_RICE_LEVEL", {num = user.level}))
	self._riceLabel:setText(user.rice)
	self._fightValueLabel:setText(GlobalFunc.ConvertNumToCharacter(user.fight_value))

	self._qualityBtn:loadTextureNormal(G_Path.getEquipColorImage(knight.quality,G_Goods.TYPE_KNIGHT))
	self._qualityBtn:loadTexturePressed(G_Path.getEquipColorImage(knight.quality,G_Goods.TYPE_KNIGHT))

	self:showWidgetByName("ImageView_rank",user.rice_rank <= 3)
	self:showWidgetByName("LabelBMFont_rank",user.rice_rank > 3)

	if user.rice_rank <= 3 then 
		self._rankImageView:loadTexture(G_Path.getPHBImage(user.rice_rank))
	else
		self._rankLabel:setText(user.rice_rank)
	end

	self:registerBtnClickEvent("Button_checkLineup", function ( ... )
		if callbackLineup then
			callbackLineup()
		end
	end)
end



return ArenaRobRiceRankCell