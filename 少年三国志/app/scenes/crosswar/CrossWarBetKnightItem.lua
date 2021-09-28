local CrossWarBetKnightItem = class("CrossWarBetKnightItem", function()
	return CCSItemCellBase:create("ui_layout/crosswar_BetKnightItem.json")
end)

local KnightPic 		= require("app.scenes.common.KnightPic")
local BetSelectLayer 	= require("app.scenes.crosswar.CrossWarBetSelectLayer")
local CrossWarCommon	= require("app.scenes.crosswar.CrossWarCommon")
local EffectSingleMoving= require("app.common.effects.EffectSingleMoving")

function CrossWarBetKnightItem:ctor()
	-- create strokes
	self:enableLabelStroke("Label_No", Colors.strokeBrown, 2)
	self:enableLabelStroke("Label_ServerName", Colors.strokeBrown, 2)
	self:enableLabelStroke("Label_UserName", Colors.strokeBrown, 2)

	-- let the "add" button blink
	local fadeIn = CCFadeIn:create(2.5)
	local fadeOut = CCFadeOut:create(2.5)
	local seq = CCSequence:createWithTwoActions(fadeIn, fadeOut)
	self:getWidgetByName("Button_Add"):runAction(CCRepeatForever:create(seq))

	-- register button events
	self:registerBtnClickEvent("Button_Add", handler(self, self._onClickAdd))
	self:registerWidgetTouchEvent("Root", handler(self, self._onClickSelf))
end

function CrossWarBetKnightItem:update(index)
	self._betIndex = index

	-- use different base for 1st and 2nd index
	local base = self:getImageViewByName("Image_Base")
	if index == 1 then
		base:loadTexture("ui/crosswar/dizuo_zhengba3.png")
	elseif index == 2 then
		base:loadTexture("ui/crosswar/dizuo_zhengba2.png")
	else
		base:loadTexture("ui/crosswar/dizuo_zhengba.png")
	end

	-- set No.
	self:showTextWithLabel("Label_No", tostring(index))

	-- get the bet user info
	local betUser = G_Me.crossWarData:getBetUser(index)
	self:showWidgetByName("Image_InfoFrame", betUser ~= nil)
	self:showWidgetByName("Panel_Knight", betUser ~= nil)
	self:showWidgetByName("Button_Add", betUser == nil)

	-- set user info
	if betUser then
		local knightInfo = knight_info.get(betUser.main_role)

		-- user name and server name
		self:showTextWithLabel("Label_UserName", betUser.name)
		self:showTextWithLabel("Label_ServerName", "[" .. string.gsub(betUser.sname, "^.-%((.-)%)", "%1") .. "]")
		self:getLabelByName("Label_UserName"):setColor(Colors.qualityColors[knightInfo.quality])

		-- knight pic
		if self._knightPic then
			self._knightPic:removeFromParentAndCleanup(true)
			self._knightPic = nil
		end

		local parent = self:getPanelByName("Panel_Knight")
		local resID = G_Me.dressData:getDressedResidWithClidAndCltm(betUser.main_role, betUser.dress_id,
			rawget(betUser,"clid"),rawget(betUser,"cltm"),rawget(betUser,"clop"))
		self._knightPic = KnightPic.createBattleKnightPic(resID, parent, "Knight_Pic", true)

		-- idle effect
		if not self._idleEffect then
			self._idleEffect = EffectSingleMoving.run(parent, "smoving_idle", nil, {})
		end
	end
end

function CrossWarBetKnightItem:_onClickAdd()
	self:_pullDataOrShowLayer()
end

function CrossWarBetKnightItem:_onClickSelf(widget, event)
	if event == TOUCH_EVENT_ENDED then
		self:_pullDataOrShowLayer()
	end
end

function CrossWarBetKnightItem:_pullDataOrShowLayer()
	if G_Me.crossWarData:getCurState() == CrossWarCommon.STATE_AFTER_SCORE_MATCH then
		self:_showBetSelectLayer()
	else
		G_MovingTip:showMovingTip(G_lang:get("LANG_CROSS_WAR_BET_OVER_1"))
	end
end

function CrossWarBetKnightItem:_showBetSelectLayer()
	G_Me.crossWarData:sortBetListByFight()
	uf_sceneManager:getCurScene():addChild(BetSelectLayer.create(self._betIndex))
	uf_eventManager:removeListenerWithTarget(self)
end

return CrossWarBetKnightItem