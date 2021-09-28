local CrossWarChampionItem = class("CrossWarChampionItem", function()
	return CCSItemCellBase:create("ui_layout/crosswar_ChampionItem.json")
end)

require("app.cfg.title_info")
require("app.cfg.contest_rank_award_info")
local KnightPic 		= require("app.scenes.common.KnightPic")
local CrossWarCommon 	= require("app.scenes.crosswar.CrossWarCommon")
local CrossWarBuyPanel 	= require("app.scenes.crosswar.CrossWarBuyPanel")
local EffectSingleMoving= require("app.common.effects.EffectSingleMoving")
local ArenaHeroAnimation= require("app.scenes.arena.ArenaHeroAnimation")

function CrossWarChampionItem:ctor(matchLayer)
	self._matchLayer	= matchLayer
	self._bg 			= self:getImageViewByName("Image_ArenaBg")
	self._flag 			= self:getButtonByName("Button_Flag")
	self._knightPanel	= self:getPanelByName("Panel_Knight")
	self._effectPanel 	= self:getPanelByName("Panel_Effect")
	self._knightPic 	= nil
	self._idleEffect 	= nil
	self._index			= 0
	self._isLeft		= false
	self._isSelf 		= false
	self._rank 			= 0
	self._name			= ""
	self._baseID		= 0
	self._resID			= 0
	self._bgID			= 0
	self._isFirstEnter	= true

	-- create strokes
	self:enableLabelStroke("Label_UserName", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_ServerName", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_Power", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_Rank", Colors.strokeBrown, 2)
	self:enableLabelStroke("Label_Title", Colors.strokeBlack, 2)

	-- register button events
	self:registerBtnClickEvent("Button_Flag", handler(self, self._onClickKnight))

	-- hide the base by default
	self:showWidgetByName("Image_Base", false)
end

-- 参数：1 - index，2 - 此cell是否为空，3 - 角色是否站左侧, 4 - 背景图ID
function CrossWarChampionItem:update(index, isEmpty, atLeft, bgID)
	self._isLeft	= atLeft
	self._index		= index
	self._bgID 		= bgID
	self._bg:loadTexture("ui/arena/bg_jinji_" .. bgID ..".png")

	-- 第一次刷新，什么都不做，只是设置一下背景
	if self._isFirstEnter then
		self._isFirstEnter = false
		return
	end

	-- 空cell，不显示内容，直接返回
	self:showWidgetByName("Image_Base", not isEmpty)
	if isEmpty then return end

	-- 调整底座（和人物）的位置
	self:getImageViewByName("Image_Base"):setPositionX(atLeft and 103 or 343)

	-- 获取玩家信息
	local user 	= G_Me.crossWarData:getUserInChampionList(index)

	-- 设置底座排名
	self:showTextWithLabel("Label_Rank", G_lang:get("LANG_ARENA_RANKING", {rank = user.rank}))

	-- 刷新UI
	self:updateContent(user)

	-- 刷新称号
	self:updateTitle(user.rank)
end

function CrossWarChampionItem:updateContent(user)
	self._isSelf= user.sid == G_PlatformProxy:getLoginServer().id and user.user_id == G_Me.userData.id
	self._rank	= user.rank
	self._name 	= user.name
	self._baseID= user.main_role
	self._resID = G_Me.dressData:getDressedResidWithClidAndCltm(user.main_role, user.dress_id,
		rawget(user,"clid"),rawget(user,"cltm"),rawget(user,"clop"))

	-- 设置旗子颜色（前10名为橙色，我自己为红色，其他为黄色）
	local isTop10 = user.rank <= CrossWarCommon.CHAMPIONSHIP_TOP_RANKS
	local flagImg = self._isSelf and "qizi_own" or "qizi_normal"
	local postFix = isTop10 and "_qianshi.png" or ".png"
	self._flag:loadTextureNormal("ui/arena/" .. flagImg .. postFix)

	-- 设置名字，服务器，战力
	self:showTextWithLabel("Label_UserName", user.name)
	self:showTextWithLabel("Label_ServerName", "[" .. string.gsub(user.sname, "^.-%((.-)%)", "%1") .. "]")

	local power = G_GlobalFunc.ConvertNumToCharacter(user.fight_value)
	self:showTextWithLabel("Label_Power", G_lang:get("LANG_INFO_FIGHT") .. "：" .. tostring(power))

	-- 创建武将图片
	if self._knightPic then
		self._knightPic:removeFromParentAndCleanup(true)
		self._knightPic = nil
	end
	self._knightPic = KnightPic.createKnightButton(self._resID, self._knightPanel, "Knight_Pic", self, handler(self, self._onClickKnight), true)

	-- 添加呼吸效果
	if not self._idleEffect then
		self._idleEffect = EffectSingleMoving.run(self._knightPanel, "smoving_idle", nil, {})
	end	
end

-- 比赛结束后要在头上显示称号
function CrossWarChampionItem:updateTitle(rank)
	local image = self:getImageViewByName("Image_Title")
	local label = self:getLabelByName("Label_Title")
	local isChampionshipEnd = G_Me.crossWarData:isChampionshipEnd()
	image:setVisible(isChampionshipEnd)
	label:setVisible(isChampionshipEnd)

	local titleInfo = nil
	if isChampionshipEnd then
		for i = 1, contest_rank_award_info.getLength() do
			v = contest_rank_award_info.get(i)
			if v.type == CrossWarCommon.MODE_CHAMPIONSHIP then
				if rank >= v.rank_min and rank <= v.rank_max then
					titleInfo = title_info.get(v.title_id)
					break
				end
			end
		end
	end

	if titleInfo then
		image:loadTexture(titleInfo.picture)
		label:setText(titleInfo.name)
		label:setColor(Colors.qualityColors[titleInfo.quality])
	end
end

function CrossWarChampionItem:_onClickKnight()
	if self._matchLayer:canClickListItem() == false then
		return
	end

	if self._isSelf then
		-- 不能攻击自己
		G_MovingTip:showMovingTip(G_lang:get("LANG_ARENA_CANNOT_ATTACK_SELF"))
	elseif G_Me.crossWarData:isChampionshipEnd() then
		-- 争霸赛已结束，不能挑战
		G_MovingTip:showMovingTip(G_lang:get("LANG_CROSS_WAR_CANNOT_CHALLENGE_2"))
	elseif not G_Me.crossWarData:isQualify() then
		-- 没有参赛资格，不能挑战
		G_MovingTip:showMovingTip(G_lang:get("LANG_CROSS_WAR_CANNOT_CHALLENGE_1"))
	elseif G_Me.crossWarData:getChallengeCount() == 0 then
		-- 没有挑战次数，跳出购买框
		CrossWarBuyPanel.show(CrossWarBuyPanel.BUY_CHALLENGE)
	elseif self._rank <= CrossWarCommon.CHAMPIONSHIP_TOP_RANKS and G_Me.crossWarData:getRankInChampionship() > 20 then
		-- 20名以外的不能挑战前10名
		G_MovingTip:showMovingTip(G_lang:get("LANG_ARENA_RANK_LESS_THAN_20"))
	else
		-- 向上层传送被挑战者的部分信息
		self._matchLayer:setChallengeInfo(self._index, self._rank, self._name, self._baseID, self._resID, self._isLeft, self._bgID, self)

		-- 发送挑战请求
		G_HandlersManager.crossWarHandler:sendChallengeChampion(self._rank)
	end
end

-- 挑战成功，踢人的动画
function CrossWarChampionItem:playKickEffect(loserResID, winnerResID, callback)
	-- 先隐藏自己的角色和旗子
	self._flag:setVisible(false)
	self._knightPanel:setVisible(false)

	-- 踢人完成后的回调
	local animCallBack = function()
		-- 显示自己的角色和旗子，删除动画
		self._knightPanel:setVisible(true)
		self._flag:setVisible(true)
		self._anim:removeFromParentAndCleanup(true)
		self._anim = nil

		-- 旗子从上降下
        local size = CCDirector:sharedDirector():getWinSize()
        local posX,posY = self._flag:getPosition() 
        self._flag:setPosition(self:convertToWorldSpace(ccp(posX,size.height)))
        local ease1 = CCMoveTo:create(0.8*posY/size.height, ccp(posX,posY))
        local arr = CCArray:create()
        arr:addObject(ease1)
        arr:addObject(CCCallFunc:create(callback))
        self._flag:runAction(CCSequence:create(arr)) 
	end

	-- 创建踢人动画并播放
	local left  = self._isLeft and "right" or "left"
	self._anim = ArenaHeroAnimation.create(winnerResID, loserResID, left, animCallBack)
	self._effectPanel:addNode(self._anim)
end

return CrossWarChampionItem