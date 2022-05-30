local data_jinjie_jinjie = require("data.data_jinjie_jinjie")
local data_pet_skill = require("data.data_petskill_petskill")

local PetJinJie = class("PetJinJie", function(param)
	return require("utility.ShadeLayer").new()
end)

local PRIVIEW_OP = "1"
local JINJIE_OP = "2"

function PetJinJie:sendRes(param)
	RequestHelper.getPetJinJieRes({
	callback = function(data)
		self:init(data)
	end,
	id = param.id,
	op = param.op
	})
end

function PetJinJie:updateListData(leftData)
	local cellData = self.list[self.index]
	if leftData.cls then
		cellData.cls = leftData.cls
	end
	if leftData.addBaseRate then
		cellData.addBaseRate = leftData.addBaseRate
	end
	if leftData.baseRate then
		cellData.baseRate = leftData.baseRate
	end
	if leftData.skillLevels then
		cellData.skillLevels = leftData.skillLevels
	end
	if leftData.skills then
		cellData.skills = leftData.skills
	end
	self.cls = leftData.cls
end

function PetJinJie:removeCard(removeList)
	if removeList ~= nil then
		for i = 1, #removeList do
			dump(removeList[i])
			for k = 1, #PetModel.totalTable do
				if PetModel.totalTable[k].id == removeList[i] then
					table.remove(PetModel.totalTable, k)
					break
				end
			end
		end
	end
end

function PetJinJie:CouldJinjie()
	local jinjieLimitLevel = ResMgr.getPetData(self.resID).evoLimit[self.cls + 1]
	if jinjieLimitLevel <= self.lv then
		return 0
	end
	show_tip_label(common:getLanguageString("@petJinjieLevelLimit", jinjieLimitLevel))
	return 1
end

function PetJinJie:init(data)
	self.data = data
	dump("jinjie_data")
	dump(data)
	local removeList = data.removePetId
	local a = self.petData
	local leftResID = self.petData.resId
	local leftCls = self.petData.cls
	self.cls = leftCls
	self.resID = leftResID
	local heroStaticData = ResMgr.getPetData(leftResID)
	local leftStarsNum = self.petData.star
	local leftLv = self.petData.level
	self.lv = leftLv
	self._rootnode.image:setDisplayFrame(ResMgr.getPetFrame(leftResID, leftCls))
	ResMgr.refreshCardBg({
	sprite = self._rootnode.card_left,
	star = leftStarsNum,
	resType = ResMgr.HERO_BG_UI
	})
	local starNum = leftStarsNum or 0
	for i = 1, 5 do
		local star = self._rootnode["star" .. i]
		if i > starNum then
			star:setVisible(false)
		else
			star:setVisible(true)
		end
	end
	local leftNameStr = heroStaticData.name
	self.leftHeroName:setString(leftNameStr)
	self.leftHeroName:setColor(NAME_COLOR[starNum])
	if leftCls == 0 then
		self.leftHeroCls:setVisible(false)
	else
		self.leftHeroCls:setVisible(true)
		self.leftHeroCls:setString("+" .. leftCls)
	end
	local x = self.leftHeroName:getPositionX() / 2
	local leftHeroNameWidth = self.leftHeroName:getContentSize().width
	local space = 25
	if leftHeroNameWidth <= 45 then
		space = 55
	end
	self.leftHeroCls:setPosition(x + leftHeroNameWidth + space, self.leftHeroName:getPositionY())
	self._rootnode.lvl:setString(leftLv)
	local leftBase = self.petData.baseRate
	local leftBaseAdd = self.petData.addBaseRate
	for i = 1, 4 do
		self._rootnode["baseState" .. i]:setString(math.ceil(leftBase[i] + leftBaseAdd[i]))
	end
	self._rootnode.yuanfen:setString(PetModel.getPetYuanFenStrByTabId(heroStaticData.id, self.cls))
	local skillCanUse = false
	for q = 1, #heroStaticData.skillAdd do
		if self.cls < heroStaticData.skillAdd[q] and self.cls + 1 >= heroStaticData.skillAdd[q] then
			skillCanUse = true
			local skillData = data_pet_skill[heroStaticData.skills[q]]
			self._rootnode.right_lock:setString(common:getLanguageString("@petgetskill") .. skillData.name)
			break
		end
	end
	self._rootnode.right_lock:setVisible(skillCanUse)
	self.lowLvJinjie = false
	if self.data.showType == 2 then
		self.lowLvJinjie = true
	end
	if self.data.showType == 1 then
		ResMgr.showErr(3385001)
		self._rootnode.right_info:setVisible(false)
		self._rootnode.card_right:setVisible(false)
		self._rootnode.arrow:setVisible(false)
		self._rootnode.jingLianBtn:setVisible(false)
		self.costNum = 0
		self._rootnode.scrow_node:removeAllChildren()
	else
		self._rootnode.right_info:setVisible(true)
		self._rootnode.card_right:setVisible(true)
		self._rootnode.arrow:setVisible(true)
		self._rootnode.jingLianBtn:setVisible(true)
		do
			local rightResID = leftResID
			local rightCls = leftCls + 1
			local rightIconNameRes = ResMgr.getPetData(rightResID).body
			local rightIconPath = ResMgr.getLargeImage(rightIconNameRes, ResMgr.HERO)
			local rightStarsNum = leftStarsNum
			ResMgr.refreshCardBg({
			sprite = self._rootnode.card_right,
			star = rightStarsNum,
			resType = ResMgr.HERO_BG_UI
			})
			local rightLv = leftLv
			self._rootnode.rightimage:setDisplayFrame(ResMgr.getPetFrame(rightResID, rightCls))
			self._rootnode.right_yuanfen:setString(PetModel.getPetYuanFenStrByTabId(heroStaticData.id, self.cls + 1))
			local starNum = rightStarsNum or 0
			for i = 1, 5 do
				local star = self._rootnode["rightstar" .. i]
				if i > starNum then
					star:setVisible(false)
				else
					star:setVisible(true)
				end
			end
			self.rightHeroName:setString(leftNameStr)
			self.rightHeroName:setColor(NAME_COLOR[starNum])
			if rightCls == 0 then
				self.rightHeroCls:setVisible(false)
			else
				self.rightHeroCls:setVisible(true)
				self.rightHeroCls:setString("+" .. rightCls)
			end
			self._rootnode.rightLv:setString(rightLv)
			local x = self.rightHeroName:getPositionX() / 2
			local rightHeroNameWidth = self.rightHeroName:getContentSize().width
			local space = 25
			if rightHeroNameWidth <= 45 then
				space = 55
			end
			self.rightHeroCls:setPosition(x + rightHeroNameWidth + space, self.rightHeroName:getPositionY())
			local nextBase = {}
			for i = 1, 4 do
				nextBase[i] = data.add[i] + leftBase[i] + leftBaseAdd[i]
				self._rootnode["right_state_" .. i]:setString(math.ceil(nextBase[i]))
			end
			self.costNum = data.costSilver
			local itemData = data.itemAry
			self.notEnough = true
			self.costData = itemData
			local sourceData = {}
			for i = 1, 5 do
				if itemData[tostring(i)] ~= nil then
					local itemsResId = itemData[tostring(i)].id
					local itemsNeedNum = itemData[tostring(i)].number
					local itemsHaveNum = itemData[tostring(i)].currentNumber
					local itemType = itemData[tostring(i)].type
					table.insert(sourceData, {
					id = itemsResId,
					t = itemType,
					n2 = itemsHaveNum,
					n1 = itemsNeedNum
					})
					if itemsNeedNum > itemsHaveNum then
						self.notEnough = false
					end
				else
				end
			end
			local function createfuncCell(idx)
				local item = require("game.Hero.JinJieCell").new()
				dump("creerer")
				return item:create({
				id = idx,
				listData = sourceData,
				viewSize = self._rootnode.scrow_node:getContentSize()
				})
			end
			local refreshFunc = function(cell, idx)
				cell:refresh(idx + 1)
			end
			self._rootnode.scrow_node:removeAllChildren()
			local itemList = require("utility.TableViewExt").new({
			size = self._rootnode.scrow_node:getContentSize(),
			createFunc = createfuncCell,
			refreshFunc = refreshFunc,
			cellNum = #sourceData,
			cellSize = require("game.Hero.JinJieCell").new():getContentSize()
			})
			self._rootnode.scrow_node:addChild(itemList)
		end
	end
	self._rootnode.cost_silver:setString(self.costNum)
	if data["1"] == 0 and data["3"].base == nil then
		self._rootnode.jingLianBtn:setVisible(false)
		self._rootnode.right_info:setVisible(false)
		self._rootnode.card_right:setVisible(false)
		self._rootnode.cost_silver:setVisible(false)
	end
end

function PetJinJie:onExit()
	TutoMgr.removeBtn("PetJinJielayer_kaishijinjie_btn")
	TutoMgr.removeBtn("PetJinJielayer_back_btn")
end

function PetJinJie:onEnter()
	TutoMgr.addBtn("PetJinJielayer_kaishijinjie_btn", self._rootnode.jingLianBtn)
	TutoMgr.addBtn("PetJinJielayer_back_btn", self._rootnode.backBtn)
	TutoMgr.active()
	self._rootnode.jingLianBtn:setEnabled(true)
	alignNodesOneByOne(self._rootnode.LevelInfo, self._rootnode.lvl, 3)
	alignNodesOneByOne(self._rootnode.Life, self._rootnode.baseState1, 3)
	alignNodesOneByOne(self._rootnode.Attack, self._rootnode.baseState2, 3)
	alignNodesOneByOne(self._rootnode.ThingDefense, self._rootnode.baseState3, 3)
	alignNodesOneByOne(self._rootnode.LawDefense, self._rootnode.baseState4, 3)
	alignNodesOneByAll({
	self._rootnode.LevelInfo_1,
	self._rootnode.rightLv,
	self._rootnode.right_lv_add
	}, 3)
	alignNodesOneByAll({
	self._rootnode.Life_1,
	self._rootnode.right_state_1,
	self._rootnode.right_state_add_1
	}, 3)
	alignNodesOneByAll({
	self._rootnode.Attack_1,
	self._rootnode.right_state_2,
	self._rootnode.right_state_add_2
	}, 3)
	alignNodesOneByAll({
	self._rootnode.ThingDefense_1,
	self._rootnode.right_state_3,
	self._rootnode.right_state_add_3
	}, 3)
	alignNodesOneByAll({
	self._rootnode.LawDefense_1,
	self._rootnode.right_state_4,
	self._rootnode.right_state_add_4
	}, 3)
end

function PetJinJie:ctor(param)
	ResMgr.createBefTutoMask(self)
	local FROM_LIST = 1
	local FROM_FORMATION = 2
	self.removeListener = param.removeListener
	self.incomeType = param.incomeType
	dump("self.income" .. self.incomeType)
	self:setNodeEventEnabled(true)
	self.needUpdate = false
	local listInfo = param.listInfo
	self.objId = listInfo.id
	self.petData = PetModel.getPetByObjId(self.objId)
	dump("self.objId" .. self.objId)
	self.updateTableFunc = listInfo.updateTableFunc
	self.list = listInfo.listData
	self.index = listInfo.cellIndex
	self.resetList = listInfo.resetList
	self.upNumFunc = listInfo.upNumFunc
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("pet/pet_jinjie.ccbi", proxy, self._rootnode)
	node:setPosition(display.cx, display.cy)
	self:addChild(node)
	local curHeight = node:getContentSize().height
	local orHeight = 633
	local scale = curHeight / orHeight
	
	self.leftHeroName = ui.newTTFLabelWithShadow({
	text = common:getLanguageString("@Hero"),
	font = FONTS_NAME.font_fzcy,
	x = self._rootnode.left_info:getContentSize().width * 0.3,
	y = self._rootnode.left_info:getContentSize().height * 0.9,
	size = 20,
	align = ui.TEXT_ALIGN_LEFT,
	color = FONT_COLOR.WHITE,
	shadowColor = FONT_COLOR.BLACK,
	})
	self._rootnode.left_info:addChild(self.leftHeroName)
	
	self.leftHeroCls = ui.newTTFLabelWithShadow({
	text = "+0",
	x = self.leftHeroName:getPositionX() + self.leftHeroName:getContentSize().width,
	y = self.leftHeroName:getPositionY(),
	font = FONTS_NAME.font_fzcy,
	size = 20,
	align = ui.TEXT_ALIGN_LEFT,
	color = NAME_COLOR[2],
	shadowColor = FONT_COLOR.BLACK,
	})
	self.leftHeroCls:setPosition(self.leftHeroName:getPositionX() + self.leftHeroName:getContentSize().width, self.leftHeroName:getPositionY())
	self._rootnode.left_info:addChild(self.leftHeroCls)
	
	self.rightHeroName = ui.newTTFLabelWithShadow({
	text = common:getLanguageString("@Hero"),
	font = FONTS_NAME.font_fzcy,
	x = self._rootnode.right_info:getContentSize().width * 0.3,
	y = self._rootnode.right_info:getContentSize().height * 0.9,
	size = 20,
	align = ui.TEXT_ALIGN_LEFT,
	color = FONT_COLOR.WHITE,
	shadowColor = FONT_COLOR.BLACK,
	})
	self._rootnode.right_info:addChild(self.rightHeroName)
	
	self.rightHeroCls = ui.newTTFLabelWithShadow({
	text = "+0",
	x = self.rightHeroName:getPositionX() + self.rightHeroName:getContentSize().width,
	y = self.rightHeroName:getPositionY(),
	font = FONTS_NAME.font_fzcy,
	size = 20,
	align = ui.TEXT_ALIGN_LEFT,
	color = NAME_COLOR[2],
	shadowColor = FONT_COLOR.BLACK,
	})
	self.rightHeroCls:setPosition(self.rightHeroName:getPositionX() + self.rightHeroName:getContentSize().width, self.rightHeroName:getPositionY())
	self._rootnode.right_info:addChild(self.rightHeroCls)
	self.curOp = PRIVIEW_OP
	self:sendRes({
	id = self.objId,
	op = self.curOp
	})
	
	if self.first == nil then
		self.first = true
		
		--·µ»Ø
		self._rootnode.backBtn:addHandleOfControlEvent(function(eventName, sender)
			GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
			if self.removeListener ~= nil then
				self.removeListener(self.needUpdate)
			end
			PostNotice(NoticeKey.REMOVE_TUTOLAYER)
			self:removeSelf()
		end,
		CCControlEventTouchUpInside)
		
		--¾«Á¶
		self._rootnode.jingLianBtn:addHandleOfControlEvent(function(eventName, sender)
			GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
			local playerSilver = game.player:getSilver()
			if self.notEnough == false then
				ResMgr.showErr(200018)
			elseif self:CouldJinjie() == 1 then
				return
			elseif playerSilver < self.costNum then
				ResMgr.showErr(100005)
			else
				self._rootnode.jingLianBtn:setEnabled(false)
				self.curOp = JINJIE_OP
				RequestHelper.getPetJinJieRes({
				callback = function(data)
					PostNotice(NoticeKey.REMOVE_TUTOLAYER)
					PostNotice(NoticeKey.LOCK_BOTTOM)
					local function createEndLayer()
						ResMgr.removeMaskLayer()
						local finLayer = require("game.Pet.PetJinJieEndLayer").new({
						perData = self.petData,
						data = data.curPet,
						removeListener = function()
							self._rootnode.jingLianBtn:setEnabled(true)
							self._rootnode.backBtn:setEnabled(true)
							PostNotice(NoticeKey.UNLOCK_BOTTOM)
						end
						})
						display:getRunningScene():addChild(finLayer, 9999)
						GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_xiakejingjie))
						self:updateListData(data.curPet)
						if self.resetList then
							self.resetList()
						end
						self:sendRes({
						id = self.objId,
						op = 1
						})
					end
					local startArma = ResMgr.createArma({
					resType = ResMgr.UI_EFFECT,
					armaName = "xiakejinjie_qishou",
					frameFunc = createEndLayer
					})
					startArma:setPosition(display.cx, display.cy)
					display:getRunningScene():addChild(startArma, 9999)
					--dump(data)
					game.player.m_silver = game.player.m_silver - self.costNum
					self.needUpdate = true
					PostNotice(NoticeKey.CommonUpdate_Label_Silver)
				end,
				id = self.objId,
				op = self.curOp
				})
			end
		end,
		CCControlEventTouchUpInside)
		
	end
end

return PetJinJie