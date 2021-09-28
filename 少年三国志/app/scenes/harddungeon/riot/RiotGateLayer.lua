local function _updateLabel(target, name, params)
    local label = target:getLabelByName(name)
    if params.stroke ~= nil then
        label:createStroke(params.stroke, params.size and params.size or 1)
    end
   
    if params.color ~= nil then
        label:setColor(params.color)
    end
    
    if params.text ~= nil then
        label:setText(params.text)
    end
    
    if params.visible ~= nil then
        label:setVisible(params.visible)
    end 
end

local function _updateImageView(target, name, params)
    local img = target:getImageViewByName(name)
    if params.texture ~= nil then
        img:loadTexture(params.texture, params.texType or UI_TEX_TYPE_LOCAL)
    end
    
    if params.visible ~= nil then
        img:setVisible(params.visible)
    end 
end


local RiotGateLayer = class("RiotGateLayer", UFCCSModelLayer)

local SCALE_DURATION = 0.2

function RiotGateLayer.create(nChapterId, hideCallback, ...)
	return RiotGateLayer.new("ui_layout/dungeon_Hard_DungeonRiotGateLayer.json", nil, nChapterId, hideCallback, ...)
end

function RiotGateLayer:ctor(json, param, nChapterId, hideCallback, ...)
	self.super.ctor(self, json, param, nChapterId, hideCallback, ...)

	self._nChapterId = nChapterId or 1
	self._hideCallback = hideCallback
	self._tRiotChapter = G_Me.hardDungeonData:getRiotChapterById(self._nChapterId)
	self._isFinishShowAction = false
	self._isOnHideAction = false

	self._tChapterTmpl = hard_dungeon_chapter_info.get(self._tRiotChapter._nChapterId)
	self._tRiotDungeomTmpl = hard_dungeon_roit_info.get(self._tRiotChapter._nRiotId)

	self:_initWidgets()
end

function RiotGateLayer:onLayerEnter()
	self:registerTouchEvent(false,false,0)
	-- 请求战斗成功
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_HARD_RIOT_OPEN_BATTLE_SCENE, self._onOpenBattleScene, self)

	self:_animationToShow()
end

function RiotGateLayer:onLayerExit()
	uf_eventManager:removeListenerWithTarget(self)
end

function RiotGateLayer:_initWidgets()
	-- 武将名字
	local szKnightName = (self._tRiotDungeomTmpl and self._tRiotDungeomTmpl.name) and self._tRiotDungeomTmpl.name or ""

	local quality = self._tRiotDungeomTmpl and self._tRiotDungeomTmpl.quality or 5
	
	_updateLabel(self, "Label_KinghtName", {text=szKnightName, stroke=Colors.strokeBrown, color=Colors.qualityColors[quality]})
	-- 武将形象
	local nBaseId = (self._tRiotDungeomTmpl and self._tRiotDungeomTmpl.image) and self._tRiotDungeomTmpl.image or 13025
	local imgHead = require("app.scenes.common.KnightPic").createKnightPic(nBaseId, self:getPanelByName("Panel_Knight"), "head", false)
	self:getPanelByName("Panel_Knight"):setScale(0.8)
--    imgHead:setScale(0.8)
--    imgHead:setPositionX(self:getPanelByName("Panel_Knight"):getContentSize().width*0.4)
--    imgHead:setPositionY(self:getPanelByName("Panel_Knight"):getContentSize().height*0.56)	
    -- 掉落物品
    for i=1, 3 do
		local tGoods = G_Goods.convert(self._tRiotDungeomTmpl["roit_reward_type_"..i], self._tRiotDungeomTmpl["roit_reward_value_"..i], 1)
		local nMinSize = self._tRiotDungeomTmpl["roit_reward_min_size_"..i] or 1
		local nMaxSize = self._tRiotDungeomTmpl["roit_reward_max_size_"..i] or 1
		self:_initGoods(i, tGoods, nMinSize, nMaxSize)
	end
	-- 对话
	local szTalk = (self._tChapterTmpl and self._tChapterTmpl.text) and self._tChapterTmpl.text or ""
	_updateLabel(self, "Label_Talk", {text=szTalk})
	-- 消耗体力
	local nVit = (self._tRiotDungeomTmpl and self._tRiotDungeomTmpl.roit_cost) and self._tRiotDungeomTmpl.roit_cost or 0
	_updateLabel(self, "Label_Vit", {text=G_lang:get("LANG_HARD_RIOT_COST_VIT"), stroke=Colors.strokeBrown})
	_updateLabel(self, "Label_VitValue", {text=nVit, stroke=Colors.strokeBrown})
	-- 通关奖励
	_updateLabel(self, "Label_PassAward", {text=G_lang:get("LANG_HARD_RIOT_PASS_AWARD"), stroke=Colors.strokeBrown})
	require("app.cfg.role_info")
	local roleData = role_info.get(G_Me.userData.level)
	local nMoney = ((roleData and roleData.pve_money) and roleData.pve_money or 0) * nVit / 5
	local nExp = ((roleData and roleData.pve_exp) and roleData.pve_exp or 0) * nVit / 5
	_updateLabel(self, "Label_PassAward_Money", {text=nExp, stroke=Colors.strokeBrown})
	_updateLabel(self, "Label_PassAward_Exp", {text=nMoney, stroke=Colors.strokeBrown})
	self:getLabelByName("Label_rookieBuffValue"):setText(G_Me.userData:getExpAdd(nExp))
	-- 有概率掉落
	_updateLabel(self, "Label_ProbDrop", {text=G_lang:get("LANG_HARD_RIOT_PROP_GET"), stroke=Colors.strokeBrown})
	
	self:registerBtnClickEvent("Button_Late", handler(self, self._onClickLate))
	self:registerBtnClickEvent("Button_Challenge", handler(self, self._onClickChallenge))
	self:registerBtnClickEvent("Button_Lineup", handler(self, self._onClickLineup))
end

function RiotGateLayer:_initGoods(nIndex, tGoods, nMinSize, nMaxSize)
	local imgBg = self:getImageViewByName("ImageView_bouns" .. nIndex)
	if not tGoods then
		imgBg:setVisible(false)
	else
		imgBg:loadTexture(G_Path.getEquipIconBack(tGoods.quality))
		-- 掉落物品的品质框
		local imgQulaity = self:getImageViewByName("bouns" .. nIndex)
		imgQulaity:loadTexture(G_Path.getEquipColorImage(tGoods.quality, tGoods.type))
		imgQulaity:setTag(nIndex)
		imgQulaity._nType = tGoods.type
		imgQulaity._nValue= tGoods.value
		-- 掉落数量 
		local labelDropNum = tolua.cast(imgQulaity:getChildByName("bounsnum"), "Label")
		local szSize = ""
		if nMinSize ~= nMaxSize then
			szSize = nMinSize .. "~" .. nMaxSize
		else
			szSize = "x" .. nMinSize
		end
		labelDropNum:setText(szSize)
		labelDropNum:createStroke(Colors.strokeBrown,1)
		-- 掉落的物品icon
		local imgIcon = self:getImageViewByName("ico" .. nIndex)
		imgIcon:loadTexture(tGoods.icon)
		self:registerWidgetTouchEvent("bouns" .. nIndex, handler(self, self._onClickGoods))
	end
end

function RiotGateLayer:_onClickGoods(sender, eventType)
	local nType = sender._nType
	local nValue= sender._nValue
    if eventType == TOUCH_EVENT_ENDED then
    	if type(nType) == "number" and type(nValue) == "number" then
        	G_SoundManager:playSound(require("app.const.SoundConst").GameSound.BUTTON_SHORT)
        	require("app.scenes.common.dropinfo.DropInfo").show(nType, nValue)
    	end
    end
end

-- 暂且放过按钮响应
function RiotGateLayer:_onClickLate()
	self:_animationToHide()
end

-- 挑战
function RiotGateLayer:_onClickChallenge()
	-- 判断体力是否充足
	local nVit = (self._tRiotDungeomTmpl and self._tRiotDungeomTmpl.roit_cost) and self._tRiotDungeomTmpl.roit_cost or 5
	if G_Me.userData.vit >= nVit then
		local nChapterId = self._nChapterId
		G_HandlersManager.hardDungeonHandler:sendGetRiotBattleInfo(nChapterId)
	else
		G_GlobalFunc.showPurchasePowerDialog(1)
	end
end

-- 布阵
function RiotGateLayer:_onClickLineup()
	G_SoundManager:playSound(require("app.const.SoundConst").GameSound.BUTTON_SHORT)
    require("app.scenes.hero.HerobuZhengLayer").showBuZhengLayer()
end

function RiotGateLayer:_animationToShow()
	local imgBg = self:getImageViewByName("Image_RiotBg")
	if imgBg then
		imgBg:setScale(0.01)
		local actScaleTo = CCScaleTo:create(SCALE_DURATION, 1)
		local actCallFunc = CCCallFunc:create(function()
			self._isFinishShowAction = true
		end)
		local tArray = CCArray:create()
		tArray:addObject(actScaleTo)
		tArray:addObject(actCallFunc)
		local actSeq = CCSequence:create(tArray)
		imgBg:runAction(actSeq)
	end
end

function RiotGateLayer:_animationToHide()
	if not self._isFinishShowAction then
		return
	end
	if self._isOnHideAction then
		return
	end

	self._isOnHideAction = true
	local imgBg = self:getImageViewByName("Image_RiotBg")
	if imgBg then
		local actScaleTo = CCScaleTo:create(SCALE_DURATION, 0.01)
		local actCallFunc = CCCallFunc:create(function ()
			if self._hideCallback then
				self._hideCallback()
			end
			self:removeFromParentAndCleanup(true)
		end)
		local tArray = CCArray:create()
		tArray:addObject(actScaleTo)
		tArray:addObject(actCallFunc)
		local actSeq = CCSequence:create(tArray)
		imgBg:runAction(actSeq)
	end
end

-- 打开战斗场景
function RiotGateLayer:_onOpenBattleScene(msg)
	local couldSkip = true
    local scene = nil
    local function showFunction( ... )
    	scene = require("app.scenes.harddungeon.riot.RiotBattleScene").new(msg, couldSkip)
        uf_sceneManager:replaceScene(scene)
    end
    local function finishFunction( ... )
    	if scene ~= nil then
    		scene:play()
    	end
    end
    G_Loading:showLoading(showFunction, finishFunction)
end

function RiotGateLayer:onTouchBegin(xPos, yPos)
	local tPanelList = {
		"Panel_110",
	}

	for key, val in pairs(tPanelList) do
		local szPanelName = val
		local panel = self:getPanelByName(szPanelName)
		local x, y = panel:convertToNodeSpaceXY(xPos, yPos)
		local tSize = panel:getSize()
		local tRect = CCRectMake(0, 0, tSize.width, tSize.height)
		if  G_WP8.CCRectContainXY(tRect, x, y) then
		--if tRect:containsPoint(ccp(x, y)) then
			return
		end 
	end

	self:_animationToHide()

    return true
end


return RiotGateLayer