require("utility.BottomBtnEvent")
local data_jiban_jiban = require("data.data_jiban_jiban")
local data_shentong_shentong = require("data.data_shentong_shentong")
local data_talent_talent = require("data.data_talent_talent")
local data_item_item = require("data.data_item_item")
local formationLayer = require("game.form.formationLayer")
local data_refine_refine = require("data.data_refine_refine")
local data_cheats_cheats = require("data.data_miji_miji")
local RequestInfo = require("network.RequestInfo")

local HeroIcon = class("HeroIcon", function ()
	return CCTableViewCell:new()
end)

function HeroIcon:getContentSize()
	return cc.size(115, 115)
end

function HeroIcon:ctor()
end

function HeroIcon:selected()
	self._lightBoard:setVisible(true)
end

function HeroIcon:unselected()
	self._lightBoard:setVisible(false)
end

function HeroIcon:create(param)
	local _viewSize = param.viewSize
	local _itemData = param.itemData
	self._heroIcon = display.newSprite("#zhenrong_equip_hero_bg.png")
	self:addChild(self._heroIcon)
	self._heroIcon:setPosition(self._heroIcon:getContentSize().width / 2, _viewSize.height / 2)
	self._lightBoard = display.newSprite("#zhenrong_select_board.png")
	self._lightBoard:setPosition(self._heroIcon:getContentSize().width / 2, _viewSize.height / 2)
	self:addChild(self._lightBoard)
	self._lightBoard:setVisible(false)
	self:refresh(param)
	return self
end

function HeroIcon:refresh(param)
	local _itemData = param.itemData
	if param.idx == param.index then
		self:selected()
	else
		self:unselected()
	end
	if type(_itemData) == "number" then
	else
		self._heroIcon:setVisible(true)
		ResMgr.refreshIcon({
		itemBg = self._heroIcon,
		cls = _itemData.cls,
		id = param.itemData.resId,
		resType = ResMgr.HERO
		})
	end
end

local getDataOpen = function (sysID)
	local data_open_open = require("data.data_open_open")
	for k, v in ipairs(data_open_open) do
		if sysID == v.system then
			return v
		end
	end
end
local MOVE_OFFSET = display.width / 3

local EnemyFormLayer = class("EnemyFormLayer", function ()
	return require("utility.ShadeLayer").new()
end)

local SHOWTYPE = {
FORMATION = 1,
SPIRIT = 2,
PET = 3,
CHEATS = 4
}

local ST_COLOR = {
cc.c3b(255, 38, 0),
cc.c3b(43, 164, 45),
cc.c3b(28, 94, 171),
cc.c3b(218, 129, 29)
}

local FormCheatsChildTag = 104

function EnemyFormLayer:switchView(bRefresh)
	if self._showType == SHOWTYPE.PET then
		self._rootnode.petInfoView:setVisible(true)
		self._rootnode.heroInfoView:setVisible(false)
	else
		self._rootnode.petInfoView:setVisible(false)
		self._rootnode.heroInfoView:setVisible(true)
		if self._showType == SHOWTYPE.SPIRIT then
			self._rootnode.spiritNode:setVisible(true)
			self._rootnode.equipNode:setVisible(false)
			self._rootnode.cheatsNode:setVisible(false)
		elseif self._showType == SHOWTYPE.CHEATS then
			self._rootnode.spiritNode:setVisible(false)
			self._rootnode.equipNode:setVisible(false)
			self._rootnode.cheatsNode:setVisible(true)
		else
			self._rootnode.spiritNode:setVisible(false)
			self._rootnode.equipNode:setVisible(true)
			self._rootnode.cheatsNode:setVisible(false)
		end
	end
	self:setFormBg(self._showType ~= SHOWTYPE.PET)
	if bRefresh then
		self:refreshHero(self._index)
	end
end

function EnemyFormLayer:setFormBg(normalTypeBg)
	if self.normalTypeBg == normalTypeBg then
		return
	end
	self.normalTypeBg = normalTypeBg
	local bg
	if normalTypeBg then
		bg = display.newSprite("bg/formation_bg.jpg")
	else
		bg = display.newSprite("bg/pet_bg.jpg")
	end
	self.bg:setDisplayFrame(bg:getDisplayFrame())
	local bgSize = bg:getContentSize()
	local showSize = self._rootnode.bgNode:getContentSize()
	self.bg:setScaleX(showSize.width / bgSize.width)
	self.bg:setScaleY(showSize.height / bgSize.height)
end

function EnemyFormLayer:ctor(showType, enemyID, closeFunc, guidName)
	self:setNodeEventEnabled(true)
	self._enemyID = enemyID
	self._guidName = guidName
	self._index = 1
	if showType then
		self._showType = showType
	else
		self._showType = 1
	end
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("formation/formation_layer.ccbi", proxy, self._rootnode)
	node:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
	self:addChild(node, 1)
	local bgSprite = display.newSprite("bg/formation_bg.jpg")
	bgSprite:setPosition(self._rootnode.bgNode:getContentSize().width / 2, self._rootnode.bgNode:getContentSize().height / 2)
	bgSprite:setScaleX(self._rootnode.bgNode:getContentSize().width / bgSprite:getContentSize().width)
	bgSprite:setScaleY(self._rootnode.bgNode:getContentSize().height / bgSprite:getContentSize().height)
	self._rootnode.bgNode:addChild(bgSprite)
	self.normalTypeBg = true
	self.bg = bgSprite
	
	--关闭
	self._rootnode.closeBtn:addHandleOfControlEvent(function (sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		if closeFunc ~= nil then
			closeFunc()
		end
		self:removeSelf()
	end,
	CCControlEventTouchUpInside)
	
	if not common:getLanguageChineseType() then
		for i = 1, 6 do
			self._rootnode["jbLabel_" .. i]:setScale(0.8)
		end
	end
	
	for i = 1, 4 do
		self._rootnode["btn_" .. i]:addHandleOfControlEvent(function (sender, eventName)
			GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
			if self._showType == i then
				return
			else
				self._showType = i
				self:switchView(true)
			end
		end,
		CCControlEventTouchUpInside)
	end
	
	self:switchView()
	self:initEquip()
	self:initPet()
	self:request()
end

function EnemyFormLayer:refreshSpiritNode()
	local _level = self._enemyInfo.level
	for k, v in ipairs(getDataOpen(OPENCHECK_TYPE.ZhenQi).level) do
		if v <= _level then
			self._rootnode["spiritLock_" .. tostring(k)]:setVisible(false)
			local spiritNodeName = "spiritNode_" .. tostring(k)
			local s = display.newSprite("#zhenrong_add.png")
			s:setPosition(self._rootnode[spiritNodeName]:getContentSize().width / 2, self._rootnode[spiritNodeName]:getContentSize().height / 2)
			self._rootnode[spiritNodeName]:addChild(s)
		end
	end
end

function EnemyFormLayer:request()
	local function initEnemyData(data)
		self._cardList = data["1"]
		self._equip = data["2"]
		self._spirit = data["3"]
		self._formation = data["5"]
		self._pet = data["6"]
		self._cheats = data["7"] or {}
		self._enemyInfo = {
		level = data["1"][1].level,
		cls = data["1"][1].cls,
		name = data["1"][1].name,
		group = data["4"] or "",
		pet = data["6"],
		cheats = data["7"] or {}
		}
	end
	if type(self._enemyID) == "string" then
		local reqs = {}
		table.insert(reqs, RequestInfo.new({
		modulename = "fmt",
		funcname = "list",
		param = {
		acc2 = self._enemyID
		},
		oklistener = function (data)
			dump(data["4"])
			initEnemyData(data)
		end
		}))
		RequestHelperV2.request2(reqs, function ()
			self:update()
		end)
	elseif type(self._enemyID) == "table" then
		initEnemyData(self._enemyID)
		self:update()
	end
end

function EnemyFormLayer:refreshHeroFigure(index)
	local hero = self._cardList[index]
	local pet = self._pet[index][1]
	local card = ResMgr.getCardData(hero.resId)
	self._rootnode.jobSprite:setDisplayFrame(display.newSpriteFrame(string.format("zhenrong_job_%d.png", card.job)))
	if self._showType ~= SHOWTYPE.PET then
		if currentCard ~= card then
			if self.playerSound then
				audio.stopSound(self.playerSound)
				self.playerSound = nil
			end
			if card.displaySound ~= nil then
				self.playerSound = GameAudio.palyHeroDub("sound/" .. ResMgr.PERSION_SFX .. "/" .. card.displaySound)
			end
			currentCard = card
		end
		local name = hero.name or HeroModel.getHeroNameByResId(hero.resId)
		self._rootnode.nameLabel:setString(name)
		self._rootnode.nameLabel:setColor(NAME_COLOR[hero.star])
		if hero.cls > 0 then
			self._rootnode.clsLabel:setVisible(true)
			self._rootnode.clsLabel:setString("+" .. tostring(hero.cls))
		else
			self._rootnode.clsLabel:setVisible(false)
		end
		self:refreshFormStar(hero.star)
		local heroPath = ResMgr.getHeroBodyName(hero.resId, hero.cls, hero.fashionId or 0)
		self._rootnode.heroImg:setDisplayFrame(display.newSprite(heroPath):getDisplayFrame())
		if display.widthInPixels / display.heightInPixels > 0.67 then
			self._rootnode.heroImg:setScale(0.85)
		end
	else
		self:formPetRefresh(pet, hero)
	end
end

function EnemyFormLayer:refreshHero(index, bScrollHead)
	if bScrollHead then
		if (self._index - 1) * 115 < math.abs(self._scrollItemList:getContentOffset().x) then
			self._scrollItemList:setContentOffset(cc.p(-(self._index - 1) * 115, 0), true)
		elseif self._index * 115 > math.abs(self._scrollItemList:getContentOffset().x) + self._scrollItemList:getContentSize().width then
			self._scrollItemList:setContentOffset(cc.p(-self._index * 115 + self._scrollItemList:getContentSize().width, 0), true)
		end
	end
	self._rootnode.bottomInfoView:setVisible(true)
	local hero = self._cardList[index]
	HeroSettingModel.cardIndex = index
	HeroSettingModel.setEnemyList(self._cardList, self._equip)
	if hero then
		for i = 1, 6 do
			local cell = self._scrollItemList:cellAtIndex(i - 1)
			if cell then
				if i == index then
					cell:selected()
				else
					cell:unselected()
				end
			end
		end
		self:refreshHeroFigure(index)
		self._rootnode.currentLevelLabel:setString(tostring(hero.level))
		self._rootnode.maxLevelLabel:setString(tostring(hero.levelLimit))
		self._rootnode.hpLabel:setString(tostring(hero.base[1]))
		self._rootnode.atkLabel:setString(tostring(hero.base[2]))
		self._rootnode.defLabel1:setString(tostring(hero.base[3]))
		self._rootnode.defLabel2:setString(tostring(hero.base[4]))
		for i = 1, 5 do
			self._rootnode["heroStar_" .. tostring(i)]:setVisible(false)
			if i <= 4 then
				self._rootnode["heroStar_2_" .. tostring(i)]:setVisible(false)
			end
		end
		for i = 1, hero.star do
			if hero.star == 4 or hero.star == 2 then
				self._rootnode["heroStar_2_" .. tostring(i)]:setVisible(true)
			else
				self._rootnode["heroStar_" .. tostring(i)]:setVisible(true)
			end
		end
		if 0 < hero.cls then
			self._rootnode.clsLabel:setVisible(true)
			self._rootnode.clsLabel:setString("+" .. tostring(hero.cls))
		else
			self._rootnode.clsLabel:setVisible(false)
		end
		for i = 1, 3 do
			self._rootnode["stNameLabel_" .. tostring(i)]:setString("")
			self._rootnode["leadLabel_" .. tostring(i)]:setString("")
		end
		for k, v in ipairs(hero.shenIDAry) do
			local stData = data_shentong_shentong[data_talent_talent[v].shentong]
			local tid
			if hero.shenLvAry[k] == 0 then
				tid = stData.arr_talent[hero.shenLvAry[k] + 1]
			else
				tid = stData.arr_talent[hero.shenLvAry[k]]
			end
			local talent = data_talent_talent[tid]
			if talent then
				self._rootnode["stNameLabel_" .. tostring(k)]:setString(talent.name)
				self._rootnode["leadLabel_" .. tostring(k)]:setString(tostring(hero.shenLvAry[k]))
				if 0 < hero.shenLvAry[k] then
					self._rootnode["stNameLabel_" .. tostring(k)]:setColor(ST_COLOR[stData.type])
					self._rootnode["leadLabel_" .. tostring(k)]:setColor(ST_COLOR[stData.type])
				else
					self._rootnode["stNameLabel_" .. tostring(k)]:setColor(cc.c3b(127, 127, 127))
					self._rootnode["leadLabel_" .. tostring(k)]:setColor(cc.c3b(127, 127, 127))
				end
			else
				show_tip_label(common:getLanguageString("@MitacNotExist", tostring(tid)))
			end
		end
		for i = 1, 6 do
			local jbKey = string.format("jbLabel_%d", i)
			self._rootnode[jbKey]:setVisible(false)
		end
		do
			local heroFate = {}
			local card = ResMgr.getCardData(hero.resId)
			if card.fate1 then
				for k, v in ipairs(card.fate1) do
					if k > 6 then
						return
					end
					local jbKey = string.format("jbLabel_%d", k)
					self._rootnode[jbKey]:setVisible(true)
					self._rootnode[jbKey]:setString(data_jiban_jiban[v].name)
					self._rootnode[jbKey]:setColor(cc.c3b(119, 119, 119))
					for i, j in ipairs(hero.relation) do
						if v == j then
							self._rootnode[jbKey]:setColor(cc.c3b(255, 108, 0))
							local _type = data_jiban_jiban[v].type
							if _type == 2 or _type == 3 then
								if type(data_jiban_jiban[v].cond1) == "table" then
									for _, skillId in pairs(data_jiban_jiban[v].cond1) do
										heroFate[skillId] = true
									end
								else
									heroFate[data_jiban_jiban[v].cond1] = true
								end
							end
						end
					end
				end
			end
			alignNodesOneByOne(self._rootnode.Life1, self._rootnode.hpLabel, 1)
			alignNodesOneByOne(self._rootnode.Attack1, self._rootnode.atkLabel, 1)
			alignNodesOneByOne(self._rootnode.ThingDefense1, self._rootnode.defLabel1, 1)
			alignNodesOneByOne(self._rootnode.LawDefense1, self._rootnode.defLabel2, 1)
			local function refreshSpiritIcon()
				for k = 1, #getDataOpen(OPENCHECK_TYPE.ZhenQi).level do
					local spiritNodeName = "spiritNode_" .. tostring(k)
					self._rootnode["spiritBtn_" .. tostring(k)]:setOpacity(255)
					self._rootnode[spiritNodeName]:removeChildByTag(100, true)
				end
				for k, v in ipairs(self._spirit[index]) do
					local spiritNodeName = "spiritNode_" .. tostring(v.subpos - 6)
					local s = require("game.Spirit.SpiritIcon").new({
					id = v._id,
					resId = v.resId,
					lv = v.level,
					exp = v.curExp or 0,
					bShowName = true,
					bShowLv = true,
					offsetY = 8
					})
					s:setPosition(self._rootnode[spiritNodeName]:getContentSize().width / 2, self._rootnode[spiritNodeName]:getContentSize().height / 2 - 12)
					self._rootnode[spiritNodeName]:addChild(s, 100, 100)
					self._rootnode["spiritBtn_" .. tostring(v.subpos - 6)]:setOpacity(0)
				end
			end
			local function refreshEquipIcon()
				for k = 1, 6 do
					local equipNodeName = "equipNode_" .. tostring(k)
					self._rootnode[equipNodeName]:removeChildByTag(100, true)
				end
				for k, v in ipairs(self._equip[index]) do
					if v.subpos ~= POS_SHIZHUANG then
						local equipNodeName = "equipNode_" .. tostring(v.subpos)
						local equipBaseInfo = data_item_item[v.resId]
						local path = CCFileUtils:sharedFileUtils():fullPathForFilename(ResMgr.getIconImage(equipBaseInfo.icon, ResMgr.EQUIP))
						local s = ResMgr.getIconSprite({
						id = v.resId,
						resType = ResMgr.EQUIP,
						hasCorner = true
						})
						s:setPosition(self._rootnode[equipNodeName]:getContentSize().width / 2, self._rootnode[equipNodeName]:getContentSize().height / 2)
						self._rootnode[equipNodeName]:addChild(s, 100, 100)
						local quality						
						if equipBaseInfo.Suit or heroFate[v.resId] then
							quality = equipBaseInfo.quality
						end
						if quality then
							local quas = {
							"",
							"pinzhikuangliuguang_lv",
							"pinzhikuangliuguang_lan",
							"pinzhikuangliuguang_zi",
							"pinzhikuangliuguang_jin",
							"pinzhikuangliuguang_jin"
							}
							local holoName = quas[equipBaseInfo.quality]
							local suitArma = ResMgr.createArma({
							resType = ResMgr.UI_EFFECT,
							armaName = holoName,
							isRetain = true
							})
							suitArma:setPosition(s:getContentSize().width / 2, s:getContentSize().height / 2)
							s:addChild(suitArma)
						end
						local label = ui.newTTFLabelWithOutline({
						text = data_item_item[v.resId].name,
						size = 22,
						font = FONTS_NAME.font_fzcy,
						align = ui.TEXT_ALIGN_CENTER,
						color = NAME_COLOR[data_item_item[v.resId].quality],
						outlineColor = display.COLOR_BLACK,
						})
						label:setPosition(s:getContentSize().width / 2, -label:getContentSize().height / 2)
						s:addChild(label)
						label = ui.newTTFLabelWithOutline({
						text = string.format("%d", v.level),
						size = 22,
						font = FONTS_NAME.font_fzcy,
						color = display.COLOR_WHITE,
						outlineColor = display.COLOR_BLACK,
						})
						s:addChild(label)
						label:align(display.LEFT_TOP, 5, s:getContentSize().height)
						local obj
						local obj = self._equip[index][k]
						if obj and obj.propsN and obj.propsN > 0 then
							local refineInfo = data_refine_refine[v.resId]
							local propCount = #refineInfo.arr_nature2
							local num = math.floor(obj.propsN / propCount)
							if num > 0 then
								display.addSpriteFramesWithFile("ui/2015_03_18.plist", "ui/2015_03_18.png")
								local diamond = display.newSprite("#2015_03_18_diamond.png")
								diamond:setPosition(s:getContentSize().width * 0.55, diamond:getContentSize().height * 0.7)
								s:addChild(diamond)
								local jlLabel = ui.newTTFLabelWithShadow({
								text = tostring(num),
								font = FONTS_NAME.font_haibao,
								size = 20,
								color = FONT_COLOR.GREEN_1,
								shadowColor = FONT_COLOR.BLACK
								})
								jlLabel:setPosition(diamond:getContentSize().width, diamond:getContentSize().height / 2)
								diamond:addChild(jlLabel)
							end
						end
					end
				end
			end
			if self._showType == SHOWTYPE.SPIRIT then
				refreshSpiritIcon()
			elseif self._showType == SHOWTYPE.PET then
				self:refreshPetSkillIcon(index)
			elseif self._showType == SHOWTYPE.CHEATS then
				self:refreshCheatsIcon(index)
			else
				refreshEquipIcon()
			end
		end
	end
end

function EnemyFormLayer:resetHeadData()
	self._headData = {}
	for k, v in ipairs(self._cardList) do
		table.insert(self._headData, v)
	end
end

function EnemyFormLayer:initHeadList()
	self:resetHeadData()
	if self._scrollItemList then
		self._scrollItemList:reloadData()
		if #self._headData - self._index < self._index then
			self._scrollItemList:setContentOffset(cc.p(self._scrollItemList:minContainerOffset().x, 0))
		end
		return
	end
	self._scrollItemList = require("utility.TableViewExt").new({
	size = cc.size(self._rootnode.headList:getContentSize().width, self._rootnode.headList:getContentSize().height),
	createFunc = function (idx)
		idx = idx + 1
		local item = HeroIcon.new()
		return item:create({
		viewSize = self._rootnode.headList:getContentSize(),
		itemData = self._headData[idx],
		idx = idx,
		index = self._index
		})
	end,
	refreshFunc = function (cell, idx)
		idx = idx + 1
		cell:refresh({
		idx = idx,
		itemData = self._headData[idx],
		index = self._index
		})
	end,
	cellNum = #self._headData,
	cellSize = HeroIcon.new():getContentSize(),
	touchFunc = function (cell)
		local idx = cell:getIdx() + 1
		--self._rootnode.touchNode:setTouchEnabled(true)
		if type(self._headData[idx]) == "table" then
			self._index = idx
			self:refreshHero(idx)
		end
	end
	})
	self._scrollItemList:setPosition(cc.p(0, 0))
	self._rootnode.headList:addChild(self._scrollItemList)
end

function EnemyFormLayer:initTouchNode()
	local touchNode = require("utility.MyLayer").new({
	name = "touchNode",
	size = cc.size(320, 300),
	swallow = true,
	parent = self._rootnode.touchNode,
	})
	touchNode:setPosition(80, 40)
	local currentNode
	local targPosX, targPosY = self._rootnode.heroImg:getPosition()
	local function moveToTargetPos()
		currentNode:runAction(CCMoveTo:create(0.2, cc.p(display.width * 0.5, targPosY)))
	end
	local function resetHeroImage(side)
		if side == 1 then
			currentNode:setPosition(display.width * 1.5, targPosY)
		elseif side == 2 then
			currentNode:setPosition(-display.width * 0.5, targPosY)
		end
		currentNode:runAction(CCMoveTo:create(0.2, cc.p(display.width * 0.5, targPosY)))
	end
	local offsetX = 0
	
	local function onTouchBegan(event)
		currentNode = self._showType ~= SHOWTYPE.PET and self._rootnode.heroImg or self._rootnode.petImg
		targPosX, targPosY = currentNode:getPosition()
		offsetX = event.x
		--dump(self._rootnode)
		--dump(self._rootnode.touchNode:convertToWorldSpace(cc.p(0,0)))
		return true
	end
	
	local function onTouchMove(event)
		local posX, posY = currentNode:getPosition()
		currentNode:setPosition(posX + event.x - event.prevX, posY)
	end
	local function onTouchEnded(event)
		offsetX = event.x - offsetX
		if offsetX >= MOVE_OFFSET then
			if self._index > 1 then
				self._index = self._index - 1
				self:refreshHero(self._index, true)
				resetHeroImage(2)
			else
				moveToTargetPos()
			end
		elseif offsetX <= -MOVE_OFFSET then
			if self._index < #self._cardList then
				self._index = self._index + 1
				self:refreshHero(self._index, true)
				resetHeroImage(1)
			else
				moveToTargetPos()
			end
		else
			moveToTargetPos()
		end
	end
	
	touchNode:setTouchHandler(function (event)
		if event.name == "began" then
			return onTouchBegan(event)
		elseif event.name == "moved" then
			onTouchMove(event)
		elseif event.name == "ended" then
			onTouchEnded(event)
		end
	end)
end

function EnemyFormLayer:initEquip()
	local function onIcon(tag, info)
		if tag < 5 then
			if info then
				self:setVisible(false)
				local layer = require("game.Equip.CommonEquipInfoLayer").new({
				index = self._index,
				subIndex = tag,
				info = info,
				bEnemy = true,
				closeListener = function ()
					self:setVisible(true)
				end
				})
				game.runningScene:addChild(layer, self:getZOrder() + 1)
			else
				printf("数据为空")
			end
		elseif info then
			self:setVisible(false)
			local layer = require("game.skill.BaseSkillInfoLayer").new({
			index = self._index,
			subIndex = tag,
			info = info,
			bEnemy = true,
			closeListener = function ()
				self:setVisible(true)
			end
			})
			game.runningScene:addChild(layer, self:getZOrder() + 1)
		else
			printf("数据为空")
		end
	end
	local function onClick(tag)
		local bChangeScene = true
		for k, v in ipairs(self._equip[self._index]) do
			if v.subpos == tag then
				for k, vs in ipairs(self._formation[self._index]) do
					if vs.pos == tag then
						v.cuilian = vs
					end
				end
				v.role = self._cardList[1]
				onIcon(tag, v)
				return
			end
		end
	end
	for i = 1, 6 do
		do
			local key = "equipBtn_" .. tostring(i)
			self._rootnode[key]:setTouchEnabled(true)
			self._rootnode[key]:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
				if event.name == "began" then
					PostNotice(NoticeKey.REMOVE_TUTOLAYER)
					onClick(i)
				end
			end)
		end
	end
end

function EnemyFormLayer:initCheats()
	local function onCheatsIcon(cheatsData, tag)
		table.sort(cheatsData.props, function (a, b)
			return a.idx < b.idx
		end)
		local descLayer = require("game.Cheats.CheatsInfoLayer").new({
		id = cheatsData.id,
		info = {
		data = cheatsData,
		index = self._index,
		subIndex = tag + 15,
		resId = cheatsData.resId
		},
		enemy = true
		}, 3)
		self:addChild(descLayer, 2)
	end
	
	local function onClick(tag)
		for k, v in ipairs(self._cheats[self._index] or {}) do
			if v.subpos - 15 == tag then
				onCheatsIcon(v, tag)
				break
			end
		end
	end
	
	for i = 1, 3 do
		--czy
		self._rootnode["cheatsBtn_" .. tostring(i)]:setTouchEnabled(true)
		self._rootnode["cheatsBtn_" .. tostring(i)]:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
			if event.name == "began" then
				PostNotice(NoticeKey.REMOVE_TUTOLAYER)
				onClick(i)
			end
		end)
	end
end

function EnemyFormLayer:initSpirit()
	
	local function onSpiritIcon(spiritData, tag)
		local descLayer = require("game.Spirit.SpiritInfoLayer").new(4, spiritData)
		self:addChild(descLayer, 2)
	end
	
	local function onClick(tag)
		for k, v in ipairs(self._spirit[self._index]) do
			if v.subpos - 6 == tag then
				onSpiritIcon(v, tag)
				break
			end
		end
	end
	
	for i = 1, 8 do
		self._rootnode["spiritBtn_" .. tostring(i)]:registerScriptTapHandler(onClick)
	end
end

function EnemyFormLayer:update()
	local teamName = ""
	dump("-------------------------------------------")
	dump(self._enemyInfo)
	if #self._enemyInfo.group > 0 then
		teamName = string.format("  [%s]", self._enemyInfo.group)
	end
	
	dump("-------------------------------------------")
	local nameLabel = ui.newTTFLabelWithOutline({
	text = tostring(self._enemyInfo.name) .. teamName,
	size = 26,
	font = FONTS_NAME.font_haibao,
	align = ui.TEXT_ALIGN_CENTER,
	color = cc.c3b(255, 234, 0),
	outlineColor = display.COLOR_BLACK,
	})
	
	ResMgr.replaceKeyLableEx(nameLabel, self._rootnode, "titleNameLabel", 0, 0)
	nameLabel:align(display.CENTER)
	
	
	self:refreshSpiritNode()
	self:initHeadList()
	self:refreshHero(1)
	self:initSpirit()
	self:initPet()
	self:initCheats()
	self:initTouchNode()
end

function EnemyFormLayer:refreshFormStar(nums)
	if nums > 0 then
		self._rootnode.starBg:setVisible(true)
		for i = 1, 5 do
			self._rootnode["heroStar_" .. tostring(i)]:setVisible(false)
			if i <= 4 then
				self._rootnode["heroStar_2_" .. tostring(i)]:setVisible(false)
			end
		end
		for i = 1, nums do
			if nums == 4 or nums == 2 then
				self._rootnode["heroStar_2_" .. tostring(i)]:setVisible(true)
			else
				self._rootnode["heroStar_" .. tostring(i)]:setVisible(true)
			end
		end
	else
		self._rootnode.starBg:setVisible(false)
	end
end

local petSkillIconTag = 5438

function EnemyFormLayer:initPet()
	local function onClick(tag)
		if tag > 4 then
			return
		end
		if not self._pet[self._index][1] then
			return
		end
		if not self:getChildByTag(petSkillIconTag) then
			local petData = ResMgr.getPetData(self._pet[self._index][1].resId)
			if petData.skills == nil or petData.skills[tag] == nil then
				return
			end
			local itemInfo = require("game.Pet.PetSkillInfo").new({
			id = petData.skills[tag],
			skillType = 1,
			lv = self._pet[self._index][1].skillLevels[tag] or 1
			})
			self:addChild(itemInfo, petSkillIconTag, petSkillIconTag)
		end
	end
	for i = 1, 4 do
		do
			local key = "petSkillBtn_" .. tostring(i)
			self._rootnode[key]:setTouchEnabled(true)
			self._rootnode[key]:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
				if event.name == "began" then
					PostNotice(NoticeKey.REMOVE_TUTOLAYER)
					onClick(i)
					return true
				end
			end)
		end
	end
end

function EnemyFormLayer:refreshPetSkillIcon(index)
	formationLayer.refreshPetSkillIcon(self, index)
end

function EnemyFormLayer:refreshCheatsIcon(index)
	for k = 1, 3 do
		local cheatsNodeName = "cheatsNode_" .. tostring(k)
		self._rootnode[cheatsNodeName]:removeChildByTag(FormCheatsChildTag, true)
	end
	local tmpIndex = {}
	for k, v in ipairs(self._cheats[index] or {}) do
		tmpIndex[v.subpos - 15] = v
	end
	for idx = 1, 3 do
		v = tmpIndex[idx]
		if v then
			local cheatsNodeName = "cheatsNode_" .. tostring(idx)
			local cheatsBaseInfo = data_cheats_cheats[v.resId]
			local path = CCFileUtils:sharedFileUtils():fullPathForFilename(ResMgr.getIconImage(cheatsBaseInfo.icon, ResMgr.CHEATS))
			local s = ResMgr.getIconSprite({
			id = v.resId,
			resType = ResMgr.CHEATS,
			hasCorner = true
			})
			s:setPosition(self._rootnode[cheatsNodeName]:getContentSize().width / 2, self._rootnode[cheatsNodeName]:getContentSize().height / 2)
			self._rootnode[cheatsNodeName]:addChild(s, 100, FormCheatsChildTag)
			if cheatsBaseInfo.quality then
				local quas = {
				"",
				"pinzhikuangliuguang_lv",
				"pinzhikuangliuguang_lan",
				"pinzhikuangliuguang_zi",
				"pinzhikuangliuguang_jin",
				 "pinzhikuangliuguang_jin"
				}
				local holoName = quas[cheatsBaseInfo.quality]
				local suitArma = ResMgr.createArma({
				resType = ResMgr.UI_EFFECT,
				armaName = holoName,
				isRetain = true
				})
				suitArma:setPosition(s:getContentSize().width / 2, s:getContentSize().height / 2)
				s:addChild(suitArma)
			end
			
			local label = ui.newTTFLabelWithOutline({
			text = cheatsBaseInfo.name,
			size = 22,
			font = FONTS_NAME.font_fzcy,
			align = ui.TEXT_ALIGN_CENTER,
			color = NAME_COLOR[cheatsBaseInfo.quality],
			outlineColor = display.COLOR_BLACK,
			})
			label:setPosition(s:getContentSize().width / 2, -label:getContentSize().height * 0.7)
			s:addChild(label)
			
			label = ui.newTTFLabelWithOutline({
			text = string.format("%d", v.floor or 1),
			size = 22,
			font = FONTS_NAME.font_fzcy,
			color = display.COLOR_WHITE,
			outlineColor = display.COLOR_BLACK,
			})
			s:addChild(label)
			label:setPosition(cc.p(20 - label:getContentSize().width / 2, s:getContentSize().height - 14))
		end
	end
end

function EnemyFormLayer:formPetRefresh(pet, hero)
	formationLayer.formPetRefresh(self, pet, hero)
end

function EnemyFormLayer:setPetImgBg(imgName)
	imgName = imgName or "ui/ui_empty.png"
	if imgName ~= self.petImgName then
		self.petImgName = imgName
		self._rootnode.petImg:setDisplayFrame(display.newSprite(self.petImgName):getDisplayFrame())
		self._rootnode.petImg:setAnchorPoint(0.5, 0.5)
	end
end

function EnemyFormLayer:onEnter()
end

function EnemyFormLayer:onExit()
	HeroSettingModel.restoreHeroList()
end

return EnemyFormLayer