-- CrossWarOpponentItem
-- This class shows the knight picture and info of an opponent

local CrossWarOpponentItem = class("CrossWarOpponentItem", function()
	return CCSPageCellBase:create("ui_layout/crosswar_OpponentItem.json")
end)

require("app.cfg.contest_points_buff_info")
local EffectNode = require("app.common.effects.EffectNode")
local EffectSingleMoving = require("app.common.effects.EffectSingleMoving")
local KnightPic = require("app.scenes.common.KnightPic")
local CrossWarBuyPanel = require("app.scenes.crosswar.CrossWarBuyPanel")

function CrossWarOpponentItem:ctor(index, matchLayer)
	self._index 			= index
	self._matchLayer		= matchLayer
	self._userId			= nil
	self._serverId			= nil
	self._knightPic			= nil
	self._appearEffect		= nil
	self._idleEffect		= nil
	self._labelPower 		= self:getLabelByName("Label_Power")

	-- create strokes for labels
	self:_createStrokes()

	-- replace the picture of the base plate
	local basePlate = self:getImageViewByName("ImageView_Dizuo")
	basePlate:loadTexture(G_Path.getBattleConfigImage('base', "base_1.png"))

	-- register touch event on the bounding box of the knight
	self:registerWidgetTouchEvent("Panel_TouchBox", handler(self, self._onTouchKnightBox))

	-- not visible at first
	self:setVisible(false)
end

function CrossWarOpponentItem:_createStrokes()
	self:enableLabelStroke("Label_ServerName", Colors.strokeBrown, 2)
	self:enableLabelStroke("Label_UserName", Colors.strokeBrown, 2)
	self:enableLabelStroke("Label_Power", Colors.strokeBrown, 2)
	self:enableLabelStroke("Label_WinGet", Colors.strokeBrown, 2)
	self:enableLabelStroke("Label_MedalNum", Colors.strokeBrown, 2)
end

function CrossWarOpponentItem:update()
	-- get the opponent info
	local info = G_Me.crossWarData:getOpponentInfo(self._index)
	if not info then
		self:setVisible(false)
		return
	else
		self:setVisible(true)
	end

	self._userId = info.id
	self._serverId = info.sid

	-- set info labels
	self:showTextWithLabel("Label_ServerName", "[" .. info.sname .. "]")
	self:showTextWithLabel("Label_UserName", info.name)

	local power = G_GlobalFunc.ConvertNumToCharacter(info.fight_value)
	self._labelPower:setText(G_lang:get("LANG_MOSHEN_ATTACK_VALUE",{rank=power}))

	-- set group icon
	local icon = self:getImageViewByName("ImageView_GroupIcon")
	icon:setVisible(info.group ~= 0)
	if info.group ~= 0 then		
		local iconTexture = contest_points_buff_info.get(info.group).icon2
		icon:loadTexture(iconTexture)

		local iconX = self._labelPower:getPositionX() - self._labelPower:getContentSize().width / 2
		icon:setPositionX(iconX)
	end

	-- set win info
	self:showTextWithLabel("Label_MedalNum", info.medalNum)

	-- adjust the info panel to show at center
	local winInfoPanel = self:getPanelByName("Panel_WinInfo")
	local children = {}
	if device.platform == "wp8" or device.platform == "winrt" then
        children = winInfoPanel:getChildrenWidget() or {}
    else
       	children = winInfoPanel:getChildren() or {}
    end
    local count = 0
    if children then 
     	count = children:count()
 	end

	local totalWidth = 0
	for i = 0, count - 1 do
		local obj = children:objectAtIndex(i)
		obj:setPositionX(totalWidth)
		totalWidth = totalWidth + obj:getContentSize().width
	end
	
	-- create knight pic and set touch event
	local parent = self:getPanelByName("Panel_Knight")
	local resID = G_Me.dressData:getDressedResidWithClidAndCltm(info.main_role, info.dress_id,
		rawget(info,"clid"),rawget(info,"cltm"),rawget(info,"clop"))

	if self._knightPic then
		self._knightPic:removeFromParentAndCleanup(true)
		self._knightPic = nil
	end

	self._knightPic = KnightPic.createBattleKnightPic(resID, parent, "Knight_Pic", false)

	-- reset the scale factor of the knight panel
	parent:setScale(1)

	-- adjust UI according to the "isBeaten" status
	self:setBeaten(info.isBeaten)

	-- add appear effect and idle effect
	if not info.isBeaten then
		self._knightPic:setOpacity(0)
		self:showWidgetByName("Panel_UserInfo", false)
		self:getPanelByName("Panel_TouchBox"):setTouchEnabled(false)

		if not self._appearEffect then
			self._appearEffect = EffectNode.new("effect_card_show", function(event)
							if event == "show" then
								self._knightPic:runAction(CCFadeIn:create(0.2))
        	            	elseif event == "finish" then
            	            	self._appearEffect:stop()
            	            	self._appearEffect:setVisible(false)
                	        	self:showWidgetByName("Panel_UserInfo", true)
                	        	self:getPanelByName("Panel_TouchBox"):setTouchEnabled(true)
                    		end
                		end)
			self:getPanelByName("Panel_Effect"):addNode(self._appearEffect)
		end

		self._appearEffect:setVisible(true)
    	self._appearEffect:play()
    	G_SoundManager:playSound(require("app.const.SoundConst").GameSound.KNIGHT_SHOW)

    	if not self._idleEffect then
    		self._idleEffect = EffectSingleMoving.run(parent, "smoving_idle", nil, {})
    	end
   	end
end

function CrossWarOpponentItem:setBeaten(isBeaten)
	-- disable the knight picture if it's beaten
	if isBeaten and self._knightPic then
		self._knightPic:showAsGray(true)
	end

	-- show or hide the "beaten" label, and user infos
	self:showWidgetByName("ImageView_Beaten", isBeaten)
	self:showWidgetByName("Panel_UserInfo", not isBeaten)

	-- stop the idle effect
	if isBeaten and self._idleEffect then
		self._idleEffect:stop()
		self._idleEffect = nil
	end
end

-- touch event of the knight box
function CrossWarOpponentItem:_onTouchKnightBox(widget, event)
	-- zoom the knight pic when touching in the box range, 
	-- to simulate the illusion that you are clicking on the knight button
	if event == TOUCH_EVENT_BEGAN then
		self._knightPic:setScale(1.1)
	elseif event == TOUCH_EVENT_ENDED or event == TOUCH_EVENT_CANCELED then
		self._knightPic:setScale(1)
	end

	-- deal with the logic when touch ended
	if event == TOUCH_EVENT_ENDED then
		local crossData = G_Me.crossWarData

		if crossData:isOpponentBeaten(self._index) then
			-- this opponent is already beaten
			G_MovingTip:showMovingTip(G_lang:get("LANG_CROSS_WAR_HAS_BEATEN"))

		elseif not crossData:canChallenge() then
			-- check if can buy challenge count today
			if not crossData:canBuyChallenge() then
				-- purshase count has reached limitation
				G_MovingTip:showMovingTip(G_lang:get("LANG_CROSS_WAR_CHALLENGE_COUNT_NOT_ENOUGH"))
				return
			end

			-- pop up the purchase panel
			CrossWarBuyPanel.show(CrossWarBuyPanel.BUY_CHALLENGE)
		else
			-- challenge this opponent
			if self._userId and self._serverId then
				G_HandlersManager.crossWarHandler:sendChallengeScoreEnemy(self._serverId, self._userId)
				
				-- save the opponent's index
				self._matchLayer:setChallengedIndex(self._index)
			end
		end
	end
end

return CrossWarOpponentItem