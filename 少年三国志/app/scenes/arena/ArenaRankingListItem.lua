local ArenaRankingListItem = class("ArenaRankingListItem",function()
	--记得修改json
    return CCSItemCellBase:create("ui_layout/arena_ArenaRankingListItem.json")
end)
local AwardConst = require("app.const.AwardConst")

require("app.cfg.knight_info")
function ArenaRankingListItem:ctor(...)
	self._checkUserInfoFunc = nil
	self._knightPic = self:getImageViewByName("ImageView_knight")

	self._shengwangLabel = self:getLabelByName("Label_shengwang")
	self._moneyLabel = self:getLabelByName("Label_money")
	self._xilianLabel = self:getLabelByName("Label_xilian")
	self._levelLabel = self:getLabelByName("Label_level")
	self._nameLabel = self:getLabelByName("Label_name")
	-- 下面被重新赋值
	-- self._bgImage = self:getImageViewByName("ImageView_knight_bg")  
	self.qualityBtn = self:getButtonByName("Button_knight")
	self._checkLineup = self:getButtonByName("Button_checkLineup")
	self._rankImageView = self:getImageViewByName("ImageView_rank")
	self._rankLabel = self:getLabelBMFontByName("LabelBMFont_rank")
	-- 背景图片
	self._bgImage = self:getImageViewByName("ImageView_bg_2")   
	-- 排名奖励信息部分的背景图片
	self._bgInnerBoard = self:getImageViewByName("Image_Inner_Board_Bg")
	self:registerBtnClickEvent("Button_checkLineup",function()
		if self._checkUserInfoFunc ~= nil then
			self._checkUserInfoFunc()
		end
		end)
	self._nameLabel:createStroke(Colors.strokeBrown,1)
end

function ArenaRankingListItem:setCheckUserInfoFunc(func)
	self._checkUserInfoFunc = func
end

--[[
	前三名使用图片
	之后使用字库
]]
function ArenaRankingListItem:update(user)
	if user == nil then return end
	-- self._checkLineup:setTouchEnabled(user.user_id ~= G_Me.userData.id)
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


	local goods01 = AwardConst.getAwardGoods01(user.rank)
	local goods02 = AwardConst.getAwardGoods02(user.rank)
	local goods03 = AwardConst.getAwardGoods03(user.rank)
	if goods01 ~= nil then
	    self._shengwangLabel:setText(G_GlobalFunc.ConvertNumToCharacter3(goods01.size))
	else
	    self._shengwangLabel:setText(0)
	end
	if goods02 ~= nil then
	    self._moneyLabel:setText(G_GlobalFunc.ConvertNumToCharacter3(goods02.size))
	else
		self._moneyLabel:setText(0)
	end 
	if goods03 ~= nil then
	    self._xilianLabel:setText(G_GlobalFunc.ConvertNumToCharacter3(goods03.size))
	else
		self._xilianLabel:setText(0)
	end 
	self.qualityBtn:loadTextureNormal(G_Path.getEquipColorImage(knight.quality,G_Goods.TYPE_KNIGHT))
	self.qualityBtn:loadTexturePressed(G_Path.getEquipColorImage(knight.quality,G_Goods.TYPE_KNIGHT))
	if self:isRobt(user) then
		local level = math.pow(user.fight_value,0.33)
		level = level - level%1
		--self._levelLabel:setText(G_lang:get("LANG_LEVEL_FORMAT_CHN",{levelValue=level}))
		self._levelLabel:setText(level .. G_lang:get("LANG_FIGHTEND_GONGXI_AFTER"))
	else
		-- self._levelLabel:setText(G_lang:get("LANG_LEVEL_FORMAT_CHN",{levelValue=user.level}))
		self._levelLabel:setText(user.level .. G_lang:get("LANG_FIGHTEND_GONGXI_AFTER"))
	end

	self:showWidgetByName("ImageView_rank",user.rank <= 3)
	self:showWidgetByName("LabelBMFont_rank",user.rank > 3)

	if user.rank <= 3 then 
		-- self._rankImageView:loadTexture(self._rankImages[user.rank],UI_TEX_TYPE_LOCAL)
		self._rankImageView:loadTexture(G_Path.getPHBImage(user.rank))
	else
		self._rankLabel:setText(user.rank)
	end
	self._nameLabel:setColor(Colors.qualityColors[knight.quality])
	self._nameLabel:setText(user.name)
end

function ArenaRankingListItem:isRobt(user)
	return user.user_id < 10000
end

return ArenaRankingListItem
	
