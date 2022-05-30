local QIANGHUA_VIEW = 1
local XIAHUN_VIEW = 2

local HeroQiangHuaLayer = class("HeroQiangHuaLayer", function(param)
	return require("utility.ShadeLayer").new()
end)

function HeroQiangHuaLayer:init()
end

function HeroQiangHuaLayer:setUpBottomVisible(isVis)
	self.top:setVisible(isVis)
	self.bottom:setVisible(isVis)
end

function HeroQiangHuaLayer:setUpSilver(num)
	self.top:setSilver(num)
end

function HeroQiangHuaLayer:setUpGoldNum(num)
	self.top:setGodNum(num)
end

function HeroQiangHuaLayer:playQiangHuaAnim(cardBg)
	local effect = ResMgr.createArma({
	resType = ResMgr.UI_EFFECT,
	armaName = "zhuangbeiqianghua",
	isRetain = false,
	finishFunc = function()
	end
	})
	GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_xiakeqianghua))
	if cardBg then
		local efPos = ResMgr:getPosInScene(cardBg)
		effect:setPosition(efPos)
		display.getRunningScene():addChild(effect, 10000)
	end
end


function HeroQiangHuaLayer:updateQiangHua(param)
	self:setUpSilver(self.updateQiangHuaData["2"])
	self._rootnode.xiahunPage:setVisible(false)
	self._rootnode.qianghua_btn_node:setVisible(true)
	self._rootnode.qianghuaPage:setVisible(true)
	self._rootnode.xiahun_btn_node:setVisible(false)
	local baseStates = self.updateQiangHuaData["1"].base
	for i = 1, 4 do
		self._rootnode["baseState" .. i]:setString(baseStates[i])
		alignNodesOneByAll({
		self._rootnode["baseState_Tag_" .. i],
		self._rootnode["baseState" .. i],
		self._rootnode["addState" .. i]
		}, 5)
	end
	local addStates = self.updateQiangHuaData["1"].add
	local cost = self.updateQiangHuaData["1"].cost
	self.cost = cost
	local getExp = self.updateQiangHuaData["1"].curExp
	if self.costNumWithShadow == nil then
		self.costNumWithShadow = ui.newTTFLabelWithShadow({
		text = "0",
		size = 22,
		x = 0,
		y = self._rootnode.cost_icon:getPositionY(),
		color = cc.c3b(255, 255, 255),
		shadowColor = display.COLOR_BLACK,
		font = FONTS_NAME.font_fzcy,
		align = ui.TEXT_ALIGN_LEFT,
		})
		
		self.costNumWithShadow:align(display.LEFT_CENTER)
		self._rootnode.node_Tag:addChild(self.costNumWithShadow)
		
		self.expNumWithShadow = ui.newTTFLabelWithShadow({
		text = "0",
		size = 22,
		x = 0,
		y = self._rootnode.exp_label:getPositionY(),
		color = cc.c3b(132, 234, 50),
		shadowColor = display.COLOR_BLACK,
		font = FONTS_NAME.font_fzcy,
		align = ui.TEXT_ALIGN_LEFT,
		})
		
		self.expNumWithShadow:align(display.LEFT_CENTER)
		self._rootnode.node_Tag:addChild(self.expNumWithShadow)
		
	end
	if param.op == 2 then
		self.costNumWithShadow:setString("0")
		self.expNumWithShadow:setString("0")
		self:playQiangHuaAnim(self._rootnode.qh_card_bg)
		for i = 1, #addStates do
			self._rootnode["addState" .. i]:setVisible(false)
		end
	else
		self.costNumWithShadow:setString(cost)
		self.expNumWithShadow:setString(cost)
		for i = 1, #addStates do
			self._rootnode["addState" .. i]:stopAllActions()
			if addStates[i] ~= 0 then
				self._rootnode["addState" .. i]:setVisible(true)
				self._rootnode["addState" .. i]:setString("+" .. addStates[i])
				local fadeTime = 1
				self._rootnode["addState" .. i]:runAction(CCRepeatForever:create(transition.sequence({
				CCFadeTo:create(fadeTime, 0),
				CCFadeTo:create(fadeTime, 250)
				})))
			else
				self._rootnode["addState" .. i]:setVisible(false)
				self._rootnode["addState" .. i]:setString(addStates[i])
			end
		end
	end
	local curLv = self.updateQiangHuaData["1"].curLv
	local nextLv = self.updateQiangHuaData["1"].lv
	local limit = self.updateQiangHuaData["1"].limit
	local normalBarSprite = self._rootnode.empty
	if self.addBar == nil then
		self.addBar = display.newProgressTimer("#shine_green_bar.png", display.PROGRESS_TIMER_BAR)
		self.addBar:setMidpoint(cc.p(0, 0.5))
		self.addBar:setBarChangeRate(cc.p(1, 0))
		self.addBar:setAnchorPoint(cc.p(0, 0.5))
		self.addBar:setPosition(0, self._rootnode.empty:getContentSize().height / 2)
		self._rootnode.empty:addChild(self.addBar)
		self.addBar:setPercentage(80)
		self.normalBar = display.newProgressTimer("#blue_bar.png", display.PROGRESS_TIMER_BAR)
		self.normalBar:setMidpoint(cc.p(0, 0.5))
		self.normalBar:setAnchorPoint(cc.p(0, 0.5))
		self.normalBar:setBarChangeRate(cc.p(1, 0))
		self._rootnode.empty:addChild(self.normalBar)
		self.normalBar:setPosition(0, self._rootnode.empty:getContentSize().height / 2)
		self.normalBar:setPercentage(60)
	end
	local fadeTime = 1
	if param.op == 1 then
		self.addBar:stopAllActions()
		self.addBar:runAction(CCRepeatForever:create(transition.sequence({
		CCFadeOut:create(fadeTime),
		CCFadeIn:create(fadeTime)
		})))
	else
		self.addBar:stopAllActions()
	end
	local level = self.updateQiangHuaData["1"].lv
	self._rootnode.lvNum:setString(level)
	self.level = level
	self._rootnode.lvNum:stopAllActions()
	self._rootnode.orLvNum:setOpacity(0)
	self._rootnode.orLvNum:stopAllActions()
	self._rootnode.orLvNum:setString(curLv)
	self._rootnode.lvNum:setOpacity(255)
	self._rootnode.lvNum:stopAllActions()
	if curLv ~= nextLv then
		self.addBar:setPercentage(100)
		self:shineLvl(curLv, nextLv)
	else
		local curExp = self.updateQiangHuaData["1"].curExp
		local addExp = self.updateQiangHuaData["1"].exp
		self.addBar:setPercentage(addExp / limit * 100)
		self.normalBar:setPercentage(curExp / limit * 100)
	end
	if param.op == 2 or self.curLevel == 0 then
		self.curLevel = level
	end
	local starNum = self.updateQiangHuaData["1"].star
	self._rootnode.qh_card_bg:setDisplayFrame(display.newSprite("#card_ui_bg_" .. starNum .. ".png"):getDisplayFrame())
	for i = 1, 5 do
		self._rootnode["star" .. i]:setVisible(starNum >= i)
	end
	local resId = self.updateQiangHuaData["1"].resId
	local cls = self.updateQiangHuaData["1"].cls
	self._rootnode.image:setDisplayFrame(ResMgr.getHeroFrame(resId, cls))
	local heroStaticData = ResMgr.getCardData(resId)
	local job = heroStaticData.job
	ResMgr.refreshJobIcon(self._rootnode.qianghua_job_icon, job)
	local choseNum = #self.choseTable
	for i = 1, 5 do
		if i > choseNum then
			local cellSprite = display.newSprite("#zhenrong_add.png")
			self._rootnode["iconSprite" .. i]:setDisplayFrame(cellSprite:getDisplayFrame())
			self._rootnode["iconSprite" .. i]:removeAllChildren()
		else
			local resId = self.sellAbleList[self.choseTable[i]].resId
			local cls = self.sellAbleList[self.choseTable[i]].cls
			ResMgr.refreshIcon({
			itemBg = self._rootnode["iconSprite" .. i],
			id = resId,
			resType = ResMgr.HERO,
			cls = cls
			})
		end
	end
	TutoMgr.active()
	alignNodesOneByOne(self._rootnode.cost_icon, self.costNumWithShadow, 5)
	alignNodesOneByOne(self._rootnode.exp_label, self.expNumWithShadow, 5)
end

function HeroQiangHuaLayer:shineFont(shineObj, endFunc)
	local fadeTime = 1
	shineObj:stopAllActions()
	shineObj:runAction(CCRepeatForever:create(transition.sequence({
	CCFadeIn:create(fadeTime),
	CCFadeOut:create(fadeTime),
	CCCallFunc:create(function()
		if endFunc ~= nil then
			endFunc()
		end
	end)
	})))
end

function HeroQiangHuaLayer:shineLvl(curLv, nextLv)
	self._rootnode.lvNum:stopAllActions()
	self._rootnode.orLvNum:stopAllActions()
	self._rootnode.lvNum:setOpacity(0)
	self._rootnode.orLvNum:setOpacity(255)
	if curLv ~= nil then
		self._rootnode.orLvNum:setString(curLv)
	end
	if nextLv ~= nil then
		self._rootnode.lvNum:setString(nextLv)
	end
	local fadeTime = 1
	if self.orNumFadeIn == nil then
		self._rootnode.lvNum:setOpacity(0)
		function self.lvNumFadeIn()
			self._rootnode.lvNum:runAction(transition.sequence({
			CCFadeIn:create(fadeTime),
			CCFadeOut:create(fadeTime),
			CCCallFunc:create(function()
				self.orNumFadeIn()
			end)
			}))
		end
		function self.orNumFadeIn()
			self._rootnode.orLvNum:runAction(transition.sequence({
			CCFadeIn:create(fadeTime),
			CCFadeOut:create(fadeTime),
			CCCallFunc:create(function()
				self.lvNumFadeIn()
			end)
			}))
		end
	end
	self.orNumFadeIn()
end

function HeroQiangHuaLayer:updateXiaHun(param)
	self._rootnode.xiahunPage:setVisible(true)
	self._rootnode.qianghuaPage:setVisible(false)
	self._rootnode.qianghua_btn_node:setVisible(false)
	self._rootnode.xiahun_btn_node:setVisible(true)
	self.addBar:stopAllActions()
	local baseNums = self.xiahunData["1"].base
	local addNums = self.xiahunData["1"].add
	for i = 1, 4 do
		self._rootnode["baseState" .. i]:setString(baseNums[i])
		self._rootnode["addState" .. i]:setString("+" .. addNums[i])
		self._rootnode["addState" .. i]:setVisible(true)
		if param.op == 1 then
			self:shineFont(self._rootnode["addState" .. i])
		else
			self._rootnode["addState" .. i]:stopAllActions()
		end
		alignNodesOneByAll({
		self._rootnode["baseState_Tag_" .. i],
		self._rootnode["baseState" .. i],
		self._rootnode["addState" .. i]
		}, 5)
	end
	local costNum = self.xiahunData["1"].cost
	self._rootnode.cost_silver_num:setString(costNum)
	self.xiahunCostNum = costNum
	local getExp = self.xiahunData["1"].exp
	self._rootnode.get_exp_num:setString(getExp)
	self.curXiaHunNum = self.xiahunData["1"].hun[1]
	self.needXiaHunNum = self.xiahunData["1"].hun[2]
	self._rootnode.cur_xiahun_num:setString(self.curXiaHunNum)
	self._rootnode.need_xiahun_num:setString(self.needXiaHunNum)
	local curLevelNum = self.xiahunData["1"].lv
	self:shineLvl(curLevelNum, curLevelNum + 1)
	self.xiahunLv = curLevelNum
	self.level = curLevelNum
	if self.addBar == nil then
		self.addBar = display.newProgressTimer("#shine_green_bar.png", display.PROGRESS_TIMER_BAR)
		self.addBar:setMidpoint(cc.p(0, 0.5))
		self.addBar:setBarChangeRate(cc.p(1, 0))
		self.addBar:setAnchorPoint(cc.p(0, 0.5))
		self.addBar:setPosition(0, self._rootnode.empty:getContentSize().height / 2)
		self._rootnode.empty:addChild(self.addBar)
		self.addBar:setPercentage(80)
		self.normalBar = display.newProgressTimer("#blue_bar.png", display.PROGRESS_TIMER_BAR)
		self.normalBar:setMidpoint(cc.p(0, 0.5))
		self.normalBar:setAnchorPoint(cc.p(0, 0.5))
		self.normalBar:setBarChangeRate(cc.p(1, 0))
		self._rootnode.empty:addChild(self.normalBar)
		self.normalBar:setPosition(0, self._rootnode.empty:getContentSize().height / 2)
		self.normalBar:setPercentage(60)
	end
	if param.op == 2 then
		self.normalBar:setPercentage(0)
	end
	self.addBar:setPercentage(100)
	self:shineFont(self.addBar)
	local resId = self.xiahunData["1"].resId
	local cls = self.xiahunData["1"].cls
	local starNum = self.xiahunData["1"].star
	local heroStaticData = ResMgr.getCardData(resId)
	local job = heroStaticData.job
	ResMgr.refreshJobIcon(self._rootnode.qianghua_job_icon, job)
	for i = 1, 5 do
		self._rootnode["star" .. i]:setVisible(i <= starNum)
	end
	self._rootnode.qh_card_bg:setDisplayFrame(display.newSprite("#card_ui_bg_" .. starNum .. ".png"):getDisplayFrame())
	self._rootnode.image:setDisplayFrame(ResMgr.getHeroFrame(resId, cls))
	alignNodesOneByOne(self._rootnode.cost_silver_num_Tag, self._rootnode.cost_silver_num, 5)
	alignNodesOneByOne(self._rootnode.get_exp_num_Tag, self._rootnode.get_exp_num, 5)
	alignNodesOneByOne(self._rootnode.cur_xiahun_num_Tag, self._rootnode.cur_xiahun_num, 5)
	alignNodesOneByOne(self._rootnode.need_xiahun_num_Tag, self._rootnode.need_xiahun_num, 5)
end

function HeroQiangHuaLayer:updateListData(data)
	if data.op == 2 then
		local cellData = self.heroList[self.index]
		local changeData = data["1"]
		if cellData ~= nil then
			cellData.cls = changeData.cls
			cellData.level = changeData.lv
			cellData.star = changeData.star
			self.level = changeData.lv
		end
	end
	self.resetList()
end

function HeroQiangHuaLayer:ctor(param)
	display.addSpriteFramesWithFile("ui/ui_herolist_v2.plist", "ui/ui_herolist_v2.png")
	self.isQiangHuaAlready = false
	self.removeListener = param.removeListener
	self.heroList = param.listData
	self.index = param.index
	self.resetList = param.resetList
	self.curLevel = 0
	self.objId = self.heroList[self.index]._id
	printf(self.objId)
	self.xiahunLv = 0
	self.sellAbleList = {}
	local rawlist = self.heroList
	for i = #rawlist, 1, -1 do
		local pos = rawlist[i].pos
		if pos == 0 then
			local cls = rawlist[i].cls
			if cls == 0 then
				local resId = rawlist[i].resId
				local cardData = ResMgr.getCardData(resId)
				if cardData.lysis == 1 and rawlist[i].lock ~= 1 and 0 >= #rawlist[i].battle and rawlist[i]._id ~= self.objId and rawlist[i].supportPos == 0 then
					self.sellAbleList[#self.sellAbleList + 1] = rawlist[i]
					self.sellAbleList[#self.sellAbleList].orIndex = i
				end
			end
		end
	end
	HeroModel.sort(self.sellAbleList, true)
	self.bottom = require("game.scenes.BottomLayer").new(true)
	self:addChild(self.bottom, 1)
	self.top = require("game.scenes.TopLayer").new()
	self:addChild(self.top, 1)
	local proxy = CCBProxy:create()
	self._rootnode = {}
	function self.nextXiaHun()
		self:sendRes({
		viewType = XIAHUN_VIEW,
		op = 1,
		n = 1
		})
	end
	local node = CCBuilderReaderLoad("hero/hero_qianghua.ccbi", proxy, self._rootnode, self, CCSizeMake(display.width, display.height - self.bottom:getContentSize().height - self.top:getContentSize().height))
	node:align(display.CENTER_BOTTOM, display.cx, self.bottom:getContentSize().height)
	--node:setAnchorPoint(cc.p(0.5, 0))
	--node:setPosition(display.cx, self.bottom:getContentSize().height)
	self:addChild(node)
	self._curView = QIANGHUA_VIEW
	local function onTabBtn(tag)
		if tag == 1 then
			if self._curView ~= QIANGHUA_VIEW then
				self._curView = QIANGHUA_VIEW
				self:sendRes({viewType = QIANGHUA_VIEW, op = 1})
				dump("qianghua ")
			end
		elseif self._curView ~= XIAHUN_VIEW then
			self._curView = XIAHUN_VIEW
			self:sendRes({
			viewType = XIAHUN_VIEW,
			op = 1,
			n = 1
			})
			dump("xiahun ")
		end
		self._curView = tag
	end
	CtrlBtnGroupAsMenu({
	self._rootnode.tab1,
	self._rootnode.tab2
	}, function(idx)
		onTabBtn(idx)
	end)
	self.choseTable = {}
	for i = 1, 5 do
		do
			local iconBtn = self._rootnode["btn" .. i]
			iconBtn:registerScriptTapHandler(function(tag)
				iconBtn:setEnabled(false)
				self:setUpBottomVisible(false)
				local qiangHuaChoseLayer = require("game.Hero.HeroChoseLayer").new({
				listData = self.heroList,
				sellAbleData = self.sellAbleList,
				index = self.index,
				choseTable = self.choseTable,
				updateFunc = handler(self, self.sendObRes),
				setUpBottomVisible = function()
					self:setUpBottomVisible(true)
				end,
				removeListener = function()
					self._rootnode["btn" .. i]:setEnabled(true)
				end
				})
				self:addChild(qiangHuaChoseLayer)
			end)
		end
	end
	
	--返回
	self.backBtn = self._rootnode.backBtn
	self.backBtn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		for i = 1, #self.sellAbleList do
			self.sellAbleList[i].isChosen = false
		end
		if self.removeListener ~= nil then
			self.removeListener(self.isQiangHuaAlready)
		end
		self:removeSelf()
	end,
	CCControlEventTouchUpInside)
	
	--侠魂返回
	self._rootnode.xiahun_back_btn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		for i = 1, #self.sellAbleList do
			self.sellAbleList[i].isChosen = false
		end
		if self.removeListener ~= nil then
			self.removeListener(self.isQiangHuaAlready)
		end
		self:removeSelf()
	end,
	CCControlEventTouchUpInside)
	
	--强化
	self.cost = 0
	self.qianghuaBtn = self._rootnode.qianghuaBtn
	self.qianghuaBtn:addHandleOfControlEvent(function(sender, eventName)
		self.qianghuaBtn:setEnabled(false)
		PostNotice(NoticeKey.REMOVE_TUTOLAYER)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		if #self.choseTable ~= 0 then
			if self.cost < game.player.m_silver then
				if self.curLevel < game.player.m_level then
					ResMgr.createMaskLayer(display.getRunningScene())
					self:sendQiangHuaRes()
				else
				end
			else
				ResMgr.showErr(2300006)
			end
		else
			ResMgr.showErr(200021)
		end
		self:performWithDelay(function()
			self._rootnode.qianghuaBtn:setEnabled(true)
		end,
		0.8)
	end,
	CCControlEventTouchUpInside)
	
	--自动添加
	self.autoBtn = self._rootnode.autoBtn
	self.autoBtn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		if #self.sellAbleList == 0 then
			show_tip_label(common:getLanguageString("@NumberNotEnough", common:getLanguageString("@Hero")))
		elseif #self.choseTable < 5 then
			self:autoSel()
		else
			show_tip_label(common:getLanguageString("@HeroQuantityMax"))
		end
	end,
	CCControlEventTouchUpInside)
	
	TutoMgr.addBtn("qianghua_btn_qianghua", self.qianghuaBtn)
	TutoMgr.addBtn("qianghua_btn_autoadd", self.autoBtn)
	self.xiahunCostNum = 0
	--侠魂强化
	self._rootnode.xiahun_qianghua_btn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		if ResMgr.isEnoughSilver(self.xiahunCostNum) then
			if self.curXiaHunNum >= self.needXiaHunNum then
				if self.xiahunLv < game.player.m_level then
					self:sendRes({
					viewType = XIAHUN_VIEW,
					op = 2,
					n = 1
					})
				else
					ResMgr.showErr(200020)
				end
			else
				ResMgr.showErr(200022)
			end
		else
			ResMgr.showErr(2300006)
		end
	end,
	CCControlEventTouchUpInside)
	
	--侠魂强化5次
	self._rootnode.xiahun_5_time_btn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		if ResMgr.isEnoughSilver(self.xiahunCostNum) then
			if self.curXiaHunNum >= self.needXiaHunNum then
				if self.xiahunLv < game.player.m_level then
					self:sendRes({
					viewType = XIAHUN_VIEW,
					op = 2,
					n = 5
					})
				else
					ResMgr.showErr(200020)
				end
			else
				ResMgr.showErr(200022)
			end
		else
			ResMgr.showErr(2300006)
		end
	end,
	CCControlEventTouchUpInside)
	
	self:sendRes({viewType = QIANGHUA_VIEW, op = 1})
end

function HeroQiangHuaLayer:autoSel()
	if self.level < game.player.m_level then
		for i = 1, 5 - #self.choseTable do
			for j = 1, #self.sellAbleList do
				local isExist = false
				local resId = self.sellAbleList[j].resId
				local cardData = ResMgr.getCardData(resId)
				local isAuto = cardData.autoadd
				if isAuto == 1 then
					for k = 1, #self.choseTable do
						if self.choseTable[k] == j then
							isExist = true
							break
						end
					end
					if isExist == false then
						self.choseTable[#self.choseTable + 1] = j
						self.sellAbleList[j].isChosen = true
						break
					end
				end
			end
		end
		if #self.choseTable == 0 then
		end
		self:sendRes({viewType = QIANGHUA_VIEW, op = 1})
	else
		ResMgr.showErr(200020)
	end
	PostNotice(NoticeKey.REMOVE_TUTOLAYER)
end

function HeroQiangHuaLayer:clearData()
	dump("clear clear")
	local objList = {}
	for i = 1, #self.choseTable do
		local objId = self.sellAbleList[self.choseTable[i]]._id
		objList[#objList + 1] = objId
	end
	for i = 1, #objList do
		for j = 1, #self.sellAbleList do
			if self.sellAbleList[j]._id == objList[i] then
				table.remove(self.sellAbleList, j)
				for k = 1, #self.heroList do
					if self.heroList[k]._id == objList[i] then
						table.remove(self.heroList, k)
						break
					end
				end
				break
			end
		end
	end
	self.choseTable = {}
	self.resetList()
end

function HeroQiangHuaLayer:sendQiangHuaRes()
	self:sendRes({viewType = QIANGHUA_VIEW, op = 2})
end

function HeroQiangHuaLayer:sendRes(param)
	local viewType = param.viewType
	if viewType == QIANGHUA_VIEW then
		local idsTable = {}
		idsTable[#idsTable + 1] = self.objId
		for i = 1, #self.choseTable do
			idsTable[#idsTable + 1] = self.sellAbleList[self.choseTable[i]]._id
		end
		local sellStr = ""
		for i = 1, #idsTable do
			if #sellStr ~= 0 then
				sellStr = sellStr .. "," .. idsTable[i]
			else
				sellStr = sellStr .. idsTable[i]
			end
		end
		RequestHelper.getCardQianghuaRes({
		callback = function(data)
			ResMgr.removeMaskLayer()
			if #data["0"] > 0 then
				show_tip_label(data["0"])
			else
				if param.op == 2 then
					self.isQiangHuaAlready = true
					self:clearData()
					game.player.m_silver = game.player.m_silver - self.cost
					self.top:setSilver(game.player.m_silver)
					data.op = 2
				else
					data.op = 1
				end
				self.updateQiangHuaData = data
				self:updateListData(data)
				self:updateQiangHua({
				op = param.op
				})
				self:refreshHelpData(data)
			end
		end,
		errback = function(data)
			if param.op == 1 then
				self.choseTable = {}
			end
		end,
		op = param.op,
		cids = sellStr
		})
	elseif viewType == XIAHUN_VIEW then
		RequestHelper.getXiaHunQianghuaRes({
		callback = function(data)
			ResMgr.removeMaskLayer()
			self.xiahunData = data
			local silver = data["2"]
			game.player.m_silver = silver
			PostNotice(NoticeKey.CommonUpdate_Label_Silver)
			self.top:setSilver(game.player.m_silver)
			self:updateXiaHun({
			op = param.op
			})
			if param.op == 2 then
				self:playQiangHuaAnim(self._rootnode.qh_card_bg)
			end
			data.op = param.op
			self:updateListData(data)
			self:refreshHelpData(data)
		end,
		id = self.objId,
		op = param.op,
		n = param.n
		})
	else
		ResMgr.removeMaskLayer()
		ResMgr.debugBanner(common:getLanguageString("@HintNoType"))
	end
end

function HeroQiangHuaLayer:refreshHelpData(data)
	if data["1"].totalProArr ~= nil and data["1"].supportPos ~= nil then
		HelpLineModel:setTotalProArrData(data["1"].totalProArr)
		local card = {}
		card.resId = data["1"].resId
		card.lv = data["1"].lv
		card.cls = data["1"].cls
		card.start = data["1"].start
		card.base = data["1"].base
		card.id = data["1"].id
		HelpLineModel:setHelpData(data["1"].supportPos, card)
	end
end

function HeroQiangHuaLayer:sendObRes()
	self:sendRes({viewType = QIANGHUA_VIEW, op = 1})
end

function HeroQiangHuaLayer:onEnter()
end

function HeroQiangHuaLayer:onExit()
	TutoMgr.removeBtn("qianghua_btn_qianghua")
	TutoMgr.removeBtn("qianghua_btn_autoadd")
end

return HeroQiangHuaLayer