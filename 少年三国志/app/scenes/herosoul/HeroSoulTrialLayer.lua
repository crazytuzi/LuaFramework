local KnightPic = require("app.scenes.common.KnightPic")
local EffectSingleMoving = require("app.common.effects.EffectSingleMoving")
local VipConst = require("app.const.VipConst")

local HeroSoulTrialLayer = class("HeroSoulTrialLayer", UFCCSNormalLayer)

HeroSoulTrialLayer.REFRESH_QUALITY_LIMITED = 6

function HeroSoulTrialLayer.create(...)
	return HeroSoulTrialLayer.new("ui_layout/herosoul_TrialLayer.json", nil, ...)
end

function HeroSoulTrialLayer:ctor(json, param, ...)
	self._nDungeonId = 1
	self._tDropList = {}
	self._tListView = nil

	self._imgKinght = nil
	self._tBreath = nil
	self._tDungeonTmpl = nil
	self._tWhisperLayer = nil

	self._nFreeRefreshCount = 0

	self.super.ctor(self, json, param, ...)
end

function HeroSoulTrialLayer:onLayerLoad()
	self:_getFreeRefreshCount()
	self:_initView()
	self:_initWidgets()
	self:_hideKnight()
end

function HeroSoulTrialLayer:onLayerEnter()
	self:_updateAfterBattleReturn()
	
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_HERO_SOUL_GET_DUNGEON_INFO_SUCC, self._onRefreshDungeon, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_HERO_SOUL_ACQUIRE_CHALLENGE_SUCC, self._onOpenBattleScene, self)

	G_HandlersManager.heroSoulHandler:sendKsoulDungeonInfo()
end

function HeroSoulTrialLayer:onLayerExit()
	uf_eventManager:removeListenerWithTarget(self)
	self:_removeKnightPic()
end

function HeroSoulTrialLayer:onLayerUnload()
	
end

function HeroSoulTrialLayer:_initView()
	G_GlobalFunc.updateLabel(self, "Label_Chart", {stroke=Colors.strokeBrown})
	G_GlobalFunc.updateLabel(self, "Label_Chart_Value", {stroke=Colors.strokeBrown, text=G_Me.heroSoulData:getActivatedChartsNum()})
	G_GlobalFunc.updateLabel(self, "Label_Lingyu", {stroke=Colors.strokeBrown})
	G_GlobalFunc.updateLabel(self, "Label_Lingyu_Value", {stroke=Colors.strokeBrown, text=G_Me.userData.hero_soul_point})

	G_GlobalFunc.updateLabel(self, "Label_DropDesc", {stroke=Colors.strokeBrown})
	G_GlobalFunc.updateLabel(self, "Label_CTimes", {stroke=Colors.strokeBrown})
	G_GlobalFunc.updateLabel(self, "Label_CTimes_Value", {stroke=Colors.strokeBrown})
	G_GlobalFunc.updateLabel(self, "Label_Name", {stroke=Colors.strokeBrown})
	G_GlobalFunc.updateLabel(self, "Label_Dungeon_Desc", {stroke=Colors.strokeBrown})

	G_GlobalFunc.updateLabel(self, "Label_Gold", {stroke=Colors.strokeBrown})
	G_GlobalFunc.updateLabel(self, "Label_Refresh", {stroke=Colors.strokeBrown})

	G_GlobalFunc.updateLabel(self, "Label_Free", {stroke=Colors.strokeBrown})
	G_GlobalFunc.updateLabel(self, "Label_Free_Num", {stroke=Colors.strokeBrown})
end

function HeroSoulTrialLayer:_initWidgets()
	-- 背包
	self:registerBtnClickEvent("Button_Bag", function()
		uf_sceneManager:getCurScene():goToLayer("HeroSoulBagLayer", true)
	end)
	-- 返回
	self:registerBtnClickEvent("Button_Back", function()
		uf_sceneManager:getCurScene():goBack()
	end)
	-- 挑战
	self:registerBtnClickEvent("Button_Challenge", function()
		if G_Me.heroSoulData:getLeftDgnChallengeCount() > 0 then
			G_HandlersManager.heroSoulHandler:sendKsoulDungeonChallenge()
		else
			G_GlobalFunc.showVipNeedDialog(VipConst.HERO_SOUL_TRIAL)
		end
	end)
	-- 刷新怪物
	self:registerBtnClickEvent("Button_Refresh", function()
		if self._tDungeonTmpl.quality >= HeroSoulTrialLayer.REFRESH_QUALITY_LIMITED then
			MessageBoxEx.showYesNoMessage("", G_lang:get("LANG_HERO_SOUL_SURE_REFRESH_DUNGEON"), nil, 
			function()
				G_HandlersManager.heroSoulHandler:sendKsoulDungeonRefresh()
			end, 
			nil)
		else
			G_HandlersManager.heroSoulHandler:sendKsoulDungeonRefresh()
		end
	end)
	-- 将灵商店
	self:registerBtnClickEvent("Button_Shop", function()
		local pack = G_GlobalFunc.sceneToPack("app.scenes.herosoul.HeroSoulScene", {nil, nil, nil, require("app.const.HeroSoulConst").TRIAL})
		uf_sceneManager:popToRootAndReplaceScene(require("app.scenes.herosoul.HeroSoulShopScene").new(pack))
	end)
end

function HeroSoulTrialLayer:_updateAfterBattleReturn()
	G_GlobalFunc.updateLabel(self, "Label_Lingyu_Value", {text=G_Me.userData.hero_soul_point})
end

function HeroSoulTrialLayer:_onUpdateChallengeTimes()
	local nTimes = G_Me.heroSoulData:getLeftDgnChallengeCount()
	G_GlobalFunc.updateLabel(self, "Label_CTimes_Value", {text=G_lang:get("LANG_HERO_SOUL_CHALLENGE_TIMES", {num=nTimes})})

	local alignFunc = G_GlobalFunc.autoAlign(ccp(0, 0), {
        self:getLabelByName('Label_CTimes'),
        self:getLabelByName('Label_CTimes_Value'),
    }, "C")
    self:getLabelByName('Label_CTimes'):setPositionXY(alignFunc(1))
    self:getLabelByName('Label_CTimes_Value'):setPositionXY(alignFunc(2)) 
end

function HeroSoulTrialLayer:_prepareData()
	self._tDropList = nil

	self._tDungeonTmpl = ksoul_dungeon_info.get(self._nDungeonId)

	self._tDropList = {
		{type=G_Goods.TYPE_HERO_SOUL_POINT, value=0, size=self._tDungeonTmpl.ksoul_point},
	}

	for i=1, 1 do
		local nType = G_Goods.TYPE_HERO_SOUL
		local nValue = self._tDungeonTmpl["ksoul_id"..i]
		local nSize = self._tDungeonTmpl["ksoul_size"..i]
		if nValue ~= 0 then
			local tDropInfo = {type=nType, value=nValue, size=nSize}
			table.insert(self._tDropList, #self._tDropList + 1, tDropInfo)
		end
	end

end

function HeroSoulTrialLayer:_initListView()
	if not self._tListView then
        local panel = self:getPanelByName("Panel_ListView")
        self._tListView = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_HORIZONTAL)
        self._tListView:setCreateCellHandler(function()
            return require("app.scenes.herosoul.HeroSoulDropItemCell").new()
        end)
		self._tListView:setUpdateCellHandler(function(list, index, cell)
			local tDropInfo = self._tDropList[index + 1]
			if tDropInfo then
				cell:updateItem(tDropInfo)
			end
		end)
        self._tListView:initChildWithDataLength(table.nums(self._tDropList))
    end
end

function HeroSoulTrialLayer:_onRefreshDungeon(tData)
	self._nDungeonId = tData.id

	self:_prepareData()
	self:_initListView()
	self:_createKnightPic(false)
	self:_onUpdateChallengeTimes()
	self:_setRefreshCost()

	self._tListView:reloadWithLength(#self._tDropList)

	if self._tWhisperLayer then
		self._tWhisperLayer:removeFromParentAndCleanup(true)
		self._tWhisperLayer = nil
	end

	--
	local needAction = true
	if needAction then
		local knightPanel = self:getPanelByName("Panel_Knight")
		local knightDizuo = self:getPanelByName("Panel_Knight_Di")

		local callback = nil
		local centerPtx, centerPty = knightPanel:convertToWorldSpaceXY(0, 0)
		centerPtx, centerPty = knightDizuo:convertToNodeSpaceXY(centerPtx, centerPty)
		local KnightAppearEffect2 = require("app.scenes.hero.KnightAppearEffect2")
		local ani = nil 
	    ani = KnightAppearEffect2.new(self._tDungeonTmpl.res_id, function()
	        local soundConst = require("app.const.SoundConst")
	        G_SoundManager:playSound(soundConst.GameSound.KNIGHT_DOWN)
	    	if callback then 
	    		callback() 
	    	end
	    	if ani then
	    		ani:removeFromParentAndCleanup(true)
	    	end
	    	self:_showKnight()

			local tParent = self:getPanelByName("Panel_Talk")
			local ptPos = tParent:getPositionInCCPoint()
			self:_playNPCWhisper(tParent, 300, 320, ptPos, self._tDungeonTmpl.talk)

	    end)
	    ani:setPositionXY(centerPtx, centerPty)
	    ani:play()
	    ani:setScale(knightPanel:getScale())
	    knightDizuo:addNode(ani)
	end
end

function HeroSoulTrialLayer:_createKnightPic(isVisible)
	isVisible = isVisible or false

	local knightPanel = self:getPanelByName("Panel_Knight")
	local nResId = self._tDungeonTmpl.res_id
	if knightPanel then
		-- 如果有，就先删掉，方便显示新的头像
		knightPanel:setScale(0.8)
		self:_removeKnightPic()
		if not self._imgKinght and not self._tBreath then
			self._imgKinght = KnightPic.createKnightPic(self._tDungeonTmpl.res_id, knightPanel, "default_knight", true)
			self._tBreath = EffectSingleMoving.run(knightPanel, "smoving_idle", nil, {position=true}, 1+ math.floor(math.random()*20))
		end
	end

	G_GlobalFunc.updateLabel(self, "Label_Name", {text=self._tDungeonTmpl.name, color=Colors.qualityColors[self._tDungeonTmpl.quality]})

	-- 
	if isVisible then
		self:_showKnight()
	else
		self:_hideKnight()
	end
end

function HeroSoulTrialLayer:_showKnight()
	self:showWidgetByName("Panel_Knight", true)
	self:showWidgetByName("Image_Name_Bg", true)
end

function HeroSoulTrialLayer:_hideKnight()
	self:showWidgetByName("Panel_Knight", false)
	self:showWidgetByName("Image_Name_Bg", false)
end

function HeroSoulTrialLayer:_removeKnightPic()
	if self._imgKinght then
		if self._tBreath then
			self._tBreath:stop()
			self._tBreath = nil
		end
		self._imgKinght:removeFromParentAndCleanup(true)
		self._imgKinght = nil
	end
end

function HeroSoulTrialLayer:_setRefreshCost()
	local nPrice = G_GlobalFunc.getPrice(35, G_Me.heroSoulData:getDgnRefreshCount() + 1)

	self:showWidgetByName("Panel_Free", nPrice == 0)
	self:showWidgetByName("Panel_NotFree", nPrice ~= 0)

	if nPrice == 0 then
		local nFreeRefreshCount = self._nFreeRefreshCount - G_Me.heroSoulData:getDgnRefreshCount()
		G_GlobalFunc.updateLabel(self, "Label_Free_Num", {text=nFreeRefreshCount..G_lang:get("LANG_HERO_SOUL_COUNT")})
		local alignFunc = G_GlobalFunc.autoAlign(ccp(0, 0), {
	        self:getLabelByName('Label_Free'),
	        self:getLabelByName('Label_Free_Num'),
	    }, "C")
	    self:getLabelByName('Label_Free'):setPositionXY(alignFunc(1))
	    self:getLabelByName('Label_Free_Num'):setPositionXY(alignFunc(2)) 
	else
		G_GlobalFunc.updateLabel(self, "Label_Gold", {text=nPrice})
		local alignFunc = G_GlobalFunc.autoAlign(ccp(0, 0), {
	        self:getImageViewByName('Image_Gold'),
	        self:getLabelByName('Label_Gold'),
	        self:getLabelByName('Label_Refresh'),
	    }, "C")
	    self:getImageViewByName('Image_Gold'):setPositionXY(alignFunc(1))
	    self:getLabelByName('Label_Gold'):setPositionXY(alignFunc(2))
	    self:getLabelByName('Label_Refresh'):setPositionXY(alignFunc(3)) 
	end
end

function HeroSoulTrialLayer:_onOpenBattleScene(tData)
	local couldSkip = false
    local scene = nil
    local function showFunction( ... )
    	local tAtkStage = G_Me.expansionDungeonData:getAtkStage()
    	scene = require("app.scenes.herosoul.HeroSoulBattleScene").new(tData, couldSkip, ...)
        uf_sceneManager:pushScene(scene)
    end
    local function finishFunction( ... )
    	if scene ~= nil then
    		scene:play()
    	end
    end
    G_Loading:showLoading(showFunction, finishFunction)
end

-- 播放这个NPC的台词
function HeroSoulTrialLayer:_playNPCWhisper(tParent, nStartX, nEndX, ptPos, text)
    local NPCWhisper = require("app.scenes.common.NPCWhisper")
    local nDir = 1

    if nStartX < nEndX then
        nDir = NPCWhisper.SPEAK_DIR.LEFT
        ptPos.x = ptPos.x + 30
        ptPos.y = ptPos.y - 100
    else
        nDir = NPCWhisper.SPEAK_DIR.RIGHT
        ptPos.x = ptPos.x - 30
        ptPos.y = ptPos.y - 100
    end

    local szText = text or "" --"宁可我负天下人，不可天下人负我！"
    if not self._tWhisperLayer then
        self._tWhisperLayer = NPCWhisper.create(nDir, szText, NPCWhisper.TYPE_STORYDUNGEON)
        self._tWhisperLayer:setTag(110)
        tParent:addNode(self._tWhisperLayer, 11)
        self._tWhisperLayer:setPosition(ptPos)
    end
end

function HeroSoulTrialLayer:_getFreeRefreshCount()
	for i=1, 20 do 
		local nPrice = G_GlobalFunc.getPrice(35, i)
		if nPrice == 0 then
			self._nFreeRefreshCount = self._nFreeRefreshCount + 1
		end
	end
end

return HeroSoulTrialLayer