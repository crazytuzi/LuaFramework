local data_petLevel_petLevel = require("data.data_petlevel_petlevel")
local data_pet_skill = require("data.data_petskill_petskill")
local data_item_nature = require("data.data_item_nature")
local data_item_item = require("data.data_item_item")
local data_shangxiansheding_shangxiansheding = require("data.data_shangxiansheding_shangxiansheding")

local QIANGHUA_VIEW = 1
local XIAHUN_VIEW = 2
ccb = ccb or {}
ccb.aniCtrl = {}

local PetQiangHuaLayer = class("PetQiangHuaLayer", function(param)
	return require("utility.ShadeLayer").new()
end)

function PetQiangHuaLayer:setUpBottomVisible(isVis)
	self.top:setVisible(isVis)
	self.bottom:setVisible(isVis)
end

function PetQiangHuaLayer:setUpSilver(num)
	self.top:setSilver(num)
end

function PetQiangHuaLayer:setUpGoldNum(num)
	self.top:setGodNum(num)
end

function PetQiangHuaLayer:playQiangHuaAnim(cardBg, effFile)
	local effect = ResMgr.createArma({
	resType = ResMgr.UI_EFFECT,
	armaName = effFile,
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

function PetQiangHuaLayer:updateQiangHua(param)
	self:setUpSilver(game.player.m_silver)
	self._rootnode.xiahunPage_0:setVisible(false)
	self._rootnode.xiahunPage_1:setVisible(false)
	self._rootnode.xiahun_btn_node:setVisible(false)
	self._rootnode.qianghuaPage_0:setVisible(true)
	self._rootnode.qianghuaPage_1:setVisible(true)
	self._rootnode.qianghua_btn_node:setVisible(true)
	local baseStates = self.updateQiangHuaData["1"].base
	for i = 1, #baseStates do
		self._rootnode["baseState" .. i]:setString(baseStates[i])
	end
	local addStates = self.updateQiangHuaData["1"].add
	local cost = self.updateQiangHuaData["1"].cost
	self.cost = cost
	local getExp = self.updateQiangHuaData["1"].curExp
	if self.costNumWithShadow == nil then
		self.costNumWithShadow = ui.newTTFLabelWithShadow({
		text = "0",
		size = 22,
		color = FONT_COLOR.WHITE,
		shadowColor = FONT_COLOR.BLACK,
		font = FONTS_NAME.font_fzcy,
		align = ui.TEXT_ALIGN_LEFT
		})
		self.costNumWithShadow:setAnchorPoint(cc.p(0, 0.5))
		self.costNumWithShadow:setPosition(self._rootnode.cost_icon:getContentSize().width + self.costNumWithShadow:getContentSize().width / 2, self._rootnode.exp_label:getContentSize().height * 0.6)
		self._rootnode.cost_icon:addChild(self.costNumWithShadow)
		
		self.expNumWithShadow = ui.newTTFLabelWithShadow({
		text = "0",
		size = 22,
		color = cc.c3b(132, 234, 50),
		shadowColor = FONT_COLOR.BLACK,
		font = FONTS_NAME.font_fzcy,
		align = ui.TEXT_ALIGN_LEFT
		})
		
		ResMgr.replaceKeyLableEx(self.expNumWithShadow, self._rootnode, "exp_label", self.expNumWithShadow:getContentSize().width / 2, 0)
		self.expNumWithShadow:align(display.LEFT_CENTER)
		
	end
	if param.op == 2 then
		self.costNumWithShadow:setString(0)
		self.expNumWithShadow:setString(0)
		self:playQiangHuaAnim(self._rootnode.qh_card_bg, "zhuangbeiqianghua")
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
	local petLevelData = data_petLevel_petLevel[curLv]
	local limit = 1
	if self.updateQiangHuaData["1"].star == 3 then
		limit = petLevelData.expThree
	elseif self.updateQiangHuaData["1"].star == 4 then
		limit = petLevelData.expFour
	elseif self.updateQiangHuaData["1"].star == 5 then
		limit = petLevelData.expFive
	end
	self.curLvExp = limit
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
		local a = self.updateQiangHuaData["1"]
		local curExp = self.updateQiangHuaData["1"].curExp
		local addExp = self.updateQiangHuaData["1"].exp
		if param.op == 1 then
			self.addBar:setPercentage((curExp + addExp) / limit * 100)
		else
			self.addBar:setPercentage(addExp / limit * 100)
		end
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
	local petData = PetModel.getPetByObjId(self.objId)
	local resId = petData.resId
	local cls = petData.cls
	self._rootnode.image:setDisplayFrame(ResMgr.getPetFrame(resId, cls))
	local heroStaticData = ResMgr.getPetData(resId)
	self._rootnode.pet_name:setString(heroStaticData.name)
	local choseNum = #self.choseTable
	for i = 1, 5 do
		if i > choseNum then
			local cellSprite = display.newSprite("#zhenrong_add.png")
			self._rootnode["iconSprite" .. i]:setDisplayFrame(cellSprite:getDisplayFrame())
			self._rootnode["iconSprite" .. i]:removeAllChildren()
		else
			ResMgr.refreshIcon({
			itemBg = self._rootnode["iconSprite" .. i],
			id = 60,
			resType = ResMgr.ITEM
			})
		
		
			-- resId = self.sellAbleList[self.choseTable[i]].resId
			--local cls = self.sellAbleList[self.choseTable[i]].cls
			--ResMgr.refreshIcon({
			--itemBg = self._rootnode["iconSprite" .. i],
			--id = resId,
			--resType = ResMgr.PET,
			--cls = cls
			--})
			
			
			
		end
	end
	TutoMgr.active()
end
function PetQiangHuaLayer:shineFont(shineObj, endFunc)
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

function PetQiangHuaLayer:shineLvl(curLv, nextLv)
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

function PetQiangHuaLayer:showSingleSkillInfo(idx)
	self.daojuEnought = true
	self.selectSkillIndex = idx
	local petData = PetModel.getPetByObjId(self.objId)
	local baseSkillInfo = ResMgr.getPetData(petData.resId).skills
	self.skillId = baseSkillInfo[idx]
	local petSkillData = petData.skills
	local lock = 1
	local skillLv = 1
	for i = 1, #petSkillData do
		if petSkillData[i] == self.skillId then
			skillLv = petData.skillLevels[i]
			lock = 0
			break
		end
	end
	self.selectSkillLock = lock
	local skillData = data_pet_skill[self.skillId]
	self.skillName_5 = nil
	self.skillName_6 = nil
	self._rootnode.skill5:removeAllChildren()
	self._rootnode.skill6:removeAllChildren()
	local nature = data_item_nature[skillData.type]
	local skillvalueAdd = skillData.add
	local skillvalueBase = skillData.base + (skillLv - 1) * skillData.add
	local tag = ""
	if nature.type ~= 1 then
		tag = "%"
	end
	self.xiahunCostNum = 0
	self.needXiaHunNum = 0
	local updataEnable = false
	local nextLv = 0
	self.isMaxLevel = false
	self.lvLow = false	
	local maxPetLevel = 40	
	if skillLv + 1 <= maxPetLevel then
		ccb.aniCtrl.mAnimationManager:runAnimationsForSequenceNamed("panel_0")		
		local lv = skillLv + 1
		if lv > #skillData.levels then
			lv = #skillData.levels
		end
		local levelLimit = skillData.levels[lv]
		if levelLimit <= petData.level then
			updataEnable = true
			self._rootnode.levelLimit:setString("")
		else
			self.lvLow = true
			self._rootnode.levelLimit:setString(common:getLanguageString("@petlvlow", lvMax))
		end
		nextLv = skillLv + 1
		self.xiahunCostNum = skillLv * skillLv * skillData.item2[1] + skillLv * skillData.item2[2]
		self.needXiaHunNum = skillLv * skillLv * skillData.item1[1] + skillLv * skillData.item1[2]
	else
		self.isMaxLevel = true
		ccb.aniCtrl.mAnimationManager:runAnimationsForSequenceNamed("panel_1")
		nextLv = skillLv
		self.xiahunCostNum = 0
		self.needXiaHunNum = 0
		self._rootnode.levelLimit:setString(common:getLanguageString("@petskillLimit"))
	end
	self.skillName_5 = PetModel.getPetSkillIcon({
	id = self.skillId,
	level = skillLv,
	lockType = lock
	})
	self.skillName_5:setAnchorPoint(cc.p(0, 0))
	self.skillName_5:setPosition(0, 20)
	self._rootnode.skill5:addChild(self.skillName_5)
	self.skillName_6 = PetModel.getPetSkillIcon({
	id = self.skillId,
	level = nextLv,
	lockType = lock
	})
	self.skillName_6:setAnchorPoint(cc.p(0, 0))
	self.skillName_6:setPosition(0, 20)
	self._rootnode.skill6:addChild(self.skillName_6)
	self._rootnode.reward_skill_name:setString(skillData.name)
	self._rootnode.shuxing:setString(nature.nature)
	self._rootnode.shuxingbase:setString(tostring(skillvalueBase) .. tag)
	self._rootnode.shuxingadd:setString("+" .. tostring(skillvalueAdd) .. tag)
	alignNodesOneByAll({
	self._rootnode.shuxing,
	self._rootnode.shuxingbase,
	self._rootnode.shuxingadd
	}, 10)
	local lvupItem = data_item_item[self.skillLvUpItemId]
	self._rootnode.spendtype1:setString(common:getLanguageString("@SilverCoin"))
	self._rootnode.spendtype2:setString(lvupItem.name)
	self._rootnode.spendvalue1:setString(tostring(self.xiahunCostNum))
	self._rootnode.spendvalue2:setString(self.skillLvUpCostNum .. "/" .. self.needXiaHunNum)
	alignNodesOneByAll({
	self._rootnode.spendtype2,
	self._rootnode.spendvalue2
	}, 10)
	if not ResMgr.isEnoughSilver(self.xiahunCostNum) then
		self._rootnode.spendvalue1:setColor(FONT_COLOR.DARK_RED)
	else
		self._rootnode.spendvalue1:setColor(FONT_COLOR.WHITE)
	end
	if self.skillLvUpCostNum < self.needXiaHunNum then
		self._rootnode.spendvalue2:setColor(FONT_COLOR.DARK_RED)
	else
		self._rootnode.spendvalue2:setColor(FONT_COLOR.GREEN_1)
	end
	if self.lvLow or not ResMgr.isEnoughSilver(self.xiahunCostNum) or self.skillLvUpCostNum < self.needXiaHunNum then
		self._rootnode.xiahun_qianghua_btn:setEnabled(false)
	else
		self._rootnode.xiahun_qianghua_btn:setEnabled(true)
	end
end

function PetQiangHuaLayer:updateXiaHun(param)
	self._rootnode.xiahunPage_0:setVisible(true)
	self._rootnode.xiahunPage_1:setVisible(true)
	self._rootnode.xiahun_btn_node:setVisible(true)
	self._rootnode.qianghuaPage_0:setVisible(false)
	self._rootnode.qianghuaPage_1:setVisible(false)
	self._rootnode.qianghua_btn_node:setVisible(false)
	self:showSingleSkillInfo(self.selectSkillIndex or 1)
	local petData = PetModel.getPetByObjId(self.objId)
	local petBaseData = ResMgr.getPetData(petData.resId)
	local baseSkillInfo = petBaseData.skills
	local petSkillData = petData.skills
	self._rootnode.pet_name:setString(petBaseData.name)
	for i = 1, 4 do
		local skillNode = self._rootnode["skill" .. i]
		skillNode:removeAllChildren()
		if i <= #baseSkillInfo then
			local touchNode = require("utility.MyLayer").new({
			name = "skillbtn_" .. i,
			swallow = true,
			parent = skillNode,
			size = skillNode:getContentSize(),
			touchHandler = function(event)
				if event.name == EventType.began then
					self:showSingleSkillInfo(i)
				end
			end,
			})
			
			for j = 1, #baseSkillInfo do
				if baseSkillInfo[j] == petSkillData[i] then
					self["skillName_" .. i] = PetModel.getPetSkillIcon({
					id = baseSkillInfo[i],
					level = petData.skillLevels[i],
					showName = true,
					lockType = 0
					})
					self["skillName_" .. i]:setAnchorPoint(cc.p(0, 0))
					self["skillName_" .. i]:setPosition(0, 20)
					self._rootnode["skill" .. i]:addChild(self["skillName_" .. i])
					break
				elseif j == #baseSkillInfo then
					self["skillName_" .. i] = PetModel.getPetSkillIcon({
					id = baseSkillInfo[i],
					nameColor = NAME_COLOR[1],
					level = 1,
					showName = true,
					customName = common:getLanguageString("@SkillJinJieUnlock", petBaseData.skillAdd[i]),
					lockType = 1
					})
					self["skillName_" .. i]:setAnchorPoint(cc.p(0, 0))
					self["skillName_" .. i]:setPosition(0, 20)
					self._rootnode["skill" .. i]:addChild(self["skillName_" .. i])
				end
			end
		else
			self["skillName_" .. i] = PetModel.getPetSkillIcon({lockType = 2})
			self["skillName_" .. i]:setAnchorPoint(cc.p(0, 0))
			self["skillName_" .. i]:setPosition(0, 20)
			self._rootnode["skill" .. i]:addChild(self["skillName_" .. i])
		end
	end
end

function PetQiangHuaLayer:updateListData(data)
	if data.op == 2 then
		local cellData = PetModel.getPetByObjId(self.objId)
		if data ~= nil and cellData ~= nil then
			if data.cls ~= nil then
				cellData.cls = data.cls
			end
			if data.lv ~= nil then
				self.level = data.lv
				cellData.level = data.lv
			end
			if data.star ~= nil then
				cellData.star = data.star
			end
			if data.skillLevels ~= nil then
				cellData.skillLevels = data.skillLevels
			end
			if data.skills ~= nil then
				cellData.skills = data.skills
			end
			if data.baseRate ~= nil then
				cellData.baseRate = data.baseRate
			end
			if data.addBaseRate ~= nil then
				cellData.addBaseRate = data.addBaseRate
			end
			if data.curPet then
				if data.curPet.skillLevels ~= nil then
					cellData.skillLevels = data.curPet.skillLevels
				end
				if data.curPet.skills ~= nil then
					cellData.skills = data.curPet.skills
				end
				if data.curPet.baseRate ~= nil then
					cellData.baseRate = data.curPet.baseRate
				end
				if data.curPet.addBaseRate ~= nil then
					cellData.addBaseRate = data.curPet.addBaseRate
				end
			end
		end
	end
	self.resetList()
end

function PetQiangHuaLayer:ctor(param)
	display.addSpriteFramesWithFile("ui/ui_herolist_v2.plist", "ui/ui_herolist_v2.png")
	self.isQiangHuaAlready = false
	self.removeListener = param.removeListener
	self.heroList = param.listData
	self.index = param.index
	self.resetList = param.resetList
	self.curLevel = 0
	self.objId = param.id
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
				local cardData = ResMgr.getPetData(resId)
				if cardData.lysis == 1 and rawlist[i].lock ~= 1 and rawlist[i]._id ~= self.objId then
					self.sellAbleList[#self.sellAbleList + 1] = rawlist[i]
					self.sellAbleList[#self.sellAbleList].orIndex = i
				end
			end
		end
	end
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
	local node = CCBuilderReaderLoad("pet/pet_qianghua.ccbi", proxy, self._rootnode, self, CCSizeMake(display.width, display.height - self.bottom:getContentSize().height - self.top:getContentSize().height))
	node:setAnchorPoint(cc.p(0.5, 0))
	node:setPosition(display.cx, self.bottom:getContentSize().height)
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
	--[[
	for i = 1, 5 do
		do
			local iconBtn = self._rootnode["btn" .. i]
			iconBtn:registerScriptTapHandler(function(tag)
				local maxLevel, needExp = self:checkPetLevelMax(true)
				if maxLevel then
					return					
				end
				iconBtn:setEnabled(false)
				self:setUpBottomVisible(false)
				local qiangHuaChoseLayer = require("game.Pet.PetChooseLayer").new({
				listData = self.heroList,
				sellAbleData = self.sellAbleList,
				choseTable = self.choseTable,
				needExpValue = needExp,
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
	]]
	
	--返回按键
	self.backBtn = self._rootnode.backBtn
	self.backBtn:addHandleOfControlEvent(function(eventName, sender)
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
	self._rootnode.xiahun_back_btn:addHandleOfControlEvent(function(eventName, sender)
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
	
	--强化按键
	self.cost = 0
	self.qianghuaBtn = self._rootnode.qianghuaBtn
	self.qianghuaBtn:addHandleOfControlEvent(function(sender, eventName)
		PostNotice(NoticeKey.REMOVE_TUTOLAYER)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		if self:checkPetLevelMax() then
			return
		end
		self.qianghuaBtn:setEnabled(false)
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
	
	--自动强化
	self.autoBtn = self._rootnode.autoBtn
	self.autoBtn:addHandleOfControlEvent(function(eventName, sender)
		local isMax, needExp = self:checkPetLevelMax(true)
		if isMax then
			return
		end
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		if #self.choseTable < 5 then
			self:autoSel(needExp)
		else
			show_tip_label(common:getLanguageString("@PetQuantityMax"))
		end
	end,
	CCControlEventTouchUpInside)
	
	TutoMgr.addBtn("qianghua_btn_qianghua", self.qianghuaBtn)
	TutoMgr.addBtn("qianghua_btn_autoadd", self.autoBtn)
	self.xiahunCostNum = 0
	--侠魂强化
	self._rootnode.xiahun_qianghua_btn:addHandleOfControlEvent(function(eventName, sender)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		if not ResMgr.isEnoughSilver(self.xiahunCostNum) then
			ResMgr.showErr(2300006)
			return
		end
		if self.skillLvUpCostNum < self.needXiaHunNum then
			ResMgr.showErr(210033)
			return
		end
		if self.lvLow then
			show_tip_label(common:getLanguageString("@petlvLowUpSkill"))
			return
		end
		if self.selectSkillLock == 1 then
			show_tip_label(common:getLanguageString("@petSkillClose"))
			return
		end
		if self.isMaxLevel then
			show_tip_label(common:getLanguageString("@LevelMax"))
			return
		end
		RequestHelper.getPetSkillLvUpRes({
		callback = function(data)
			ResMgr.removeMaskLayer()
			data.pet.op = 2
			game.player.m_silver = data.silver
			PostNotice(NoticeKey.CommonUpdate_Label_Silver)
			self.top:setSilver(game.player.m_silver)
			self:updateListData(data.pet)
			self:sendRes({
			viewType = XIAHUN_VIEW,
			op = 1,
			n = 1
			})
			self:playQiangHuaAnim(self._rootnode.qh_card_bg, "zhuangbeiqianghua")
		end,
		id = self.objId,
		sklId = self.skillId
		})
	end,
	CCControlEventTouchUpInside)
	
	self:sendRes({viewType = QIANGHUA_VIEW, op = 1})
end

function PetQiangHuaLayer:checkPetLevelMax(getNeedExp)
	local petData = PetModel.getPetByObjId(self.objId)
	--local cellData = ResMgr.getPetData(petData.resId)
	local limitPetLevel = data_shangxiansheding_shangxiansheding[11].level	
	if self.curLevel >= limitPetLevel then
		show_tip_label(common:getLanguageString("@GuildLvMax"))
		return true
	elseif self.curLevel >= game.player.m_level then
		show_tip_label(common:getLanguageString("@petlvMaxLimit"))
		return true
	end
	if getNeedExp then
		local needExp = PetModel.getNeedMaxExp(petData.resId, petData.level, petData.curExp, petData.star)
		return false, needExp
	end
end

function PetQiangHuaLayer:autoSel(needExp)
	if needExp then
		for key, value in pairs(self.choseTable) do
			--local exp = PetModel.getPetExpValue(self.sellAbleList[value])
			--needExp = needExp - exp
			needExp = needExp - 10000
		end
	end
	local num = 5 - #self.choseTable
	for i = 1, num do
		if needExp and needExp <= 0 then
			break
		end
		if #self.choseTable >= self.petItemCount then
			break
		end
		self.choseTable[#self.choseTable + 1] = 1
		--[[
		for j = 1, #self.sellAbleList do
			local isExist = false
			local resId = self.sellAbleList[j].resId
			local cardData = ResMgr.getPetData(resId)
			local isAuto = cardData.isItem
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
					if needExp then
						local exp = PetModel.getPetExpValue(self.sellAbleList[j])
						needExp = needExp - exp
					end
					break
				end
			end
		end
			]]
	end
	if #self.choseTable == 0 then
		show_tip_label(common:getLanguageString("@withoutExpPet"))
	end
	self:sendRes({viewType = QIANGHUA_VIEW, op = 1})
	PostNotice(NoticeKey.REMOVE_TUTOLAYER)
end

function PetQiangHuaLayer:clearData()
	dump("clear clear")
	
	--local objList = {}
	--for i = 1, #self.choseTable do
	--	local objId = self.sellAbleList[self.choseTable[i]]._id
	--	objList[#objList + 1] = objId
	--end
	--for i = 1, #objList do
	--	for j = 1, #self.sellAbleList do
	--		if self.sellAbleList[j]._id == objList[i] then
	--			table.remove(self.sellAbleList, j)
	--			for k = 1, #self.heroList do
	--				if self.heroList[k]._id == objList[i] then
	--					table.remove(self.heroList, k)
	--					break
	--				end
	--			end
	--			break
	--		end
	--	end
	--end
	
	self.choseTable = {}
	self.resetList()
end

function PetQiangHuaLayer:sendQiangHuaRes()
	self:sendRes({viewType = QIANGHUA_VIEW, op = 2})
end

function PetQiangHuaLayer:sendRes(param)
	local viewType = param.viewType
	if viewType == QIANGHUA_VIEW then
		--local idsTable = {}
		--idsTable[#idsTable + 1] = self.objId
		--for i = 1, #self.choseTable do
		--	idsTable[#idsTable + 1] = self.sellAbleList[self.choseTable[i]]._id
		--end
		--local sellStr = ""
		--for i = 1, #idsTable do
		--	if #sellStr ~= 0 then
		--		sellStr = sellStr .. "," .. idsTable[i]
		--	else
		--		sellStr = sellStr .. idsTable[i]
		--	end
		--end
		RequestHelper.getPetQianghuaRes({
		callback = function(data)
			ResMgr.removeMaskLayer()
			if param.op == 2 then
				local a = PetModel.totalTable
				self.isQiangHuaAlready = true
				self:clearData()
				game.player.m_silver = game.player.m_silver - self.cost
				self.top:setSilver(game.player.m_silver)
				data.op = 2
			else
				data.op = 1
			end
			self.petItemCount = data.itemCount
			self.updateQiangHuaData = {}
			self.updateQiangHuaData["1"] = data
			self:updateListData(data)
			self:updateQiangHua({
			op = param.op
			})
		end,
		errback = function(data)
			if param.op == 1 then
				self.choseTable = {}
			end
		end,
		op = param.op,
		petId = self.objId,
		count = #self.choseTable	
		})
	elseif viewType == XIAHUN_VIEW then
		RequestHelper.getPetUsingItem({
		callback = function(data)
			ResMgr.removeMaskLayer()
			self.skillLvUpCostNum = data.sklSize
			self.skillLvUpItemId = data.sklItemId
			self:updateXiaHun({
			op = param.op
			})
		end
		})
	else
		ResMgr.removeMaskLayer()
		ResMgr.debugBanner(common:getLanguageString("@HintNoType"))
	end
end

function PetQiangHuaLayer:sendObRes()
	self:sendRes({viewType = QIANGHUA_VIEW, op = 1})
end

function PetQiangHuaLayer:onEnter()
end

function PetQiangHuaLayer:onExit()
	TutoMgr.removeBtn("qianghua_btn_qianghua")
	TutoMgr.removeBtn("qianghua_btn_autoadd")
end

return PetQiangHuaLayer