local LIANZHAN_ZORDER = 31
local LEVELUP_ZORDER = 33
local MAX_ZORDER = 100

local SubMapInfoLayer = class("SubMapInfoLayer", function(levelData, _subMapInfo)
	return display.newLayer()
end)

function SubMapInfoLayer:ctor(levelData, _subMapInfo, removeListener, refreshSubInfo)
	SubMapModel.levelData = levelData
	self.removeListener = removeListener
	self.refreshSubInfo = refreshSubInfo
	PostNotice(NoticeKey.REMOVE_TUTOLAYER)
	display.addSpriteFramesWithFile("ui/ui_shuxingIcon.plist", "ui/ui_shuxingIcon.png")
	self._subMapInfo = _subMapInfo
	self:setNodeEventEnabled(true)
	self:setTouchEnabled(true)
	local colorbg = display.newColorLayer(cc.c4b(0, 0, 0, 150))
	colorbg:setContentSize(cc.size(display.width, display.height))
	colorbg:setPosition(0, 0)
	self:addChild(colorbg)
	self._bagObj = self._subMapInfo["3"]
	self._isBagFull = false
	if 0 < #self._bagObj then
		self._isBagFull = true
	end
	local proxy = CCBProxy:create()
	local levelrootnode = {}
	local levelBoard = CCBuilderReaderLoad("ccbi/battle/level_grade.ccbi", proxy, levelrootnode)
	local starboard = levelrootnode.itemBg
	self._id = levelData.id
	local originHeight = 325
	local rewardSize = 145
	local levelBoardOffHeight = levelBoard:getContentSize().height * levelData.star
	local rewardOffHeight = rewardSize * (math.floor((#levelData.arr_dropid - 1) / 5) + 1)
	local win_height = originHeight + levelBoardOffHeight + rewardOffHeight + 15
	local rootnode = {}
	local node = CCBuilderReaderLoad("fuben/sub_map_info.ccbi", proxy, rootnode, self, cc.size(display.width, win_height))
	node:setPosition(display.cx, display.cy)
	self:addChild(node)
	rootnode.title_lbl:setPositionY(win_height - 21)
	rootnode.boss_node:setPositionY(win_height - 75)
	for i = 1, levelData.star do
		local tag = "star_" .. i
		rootnode[tag]:setVisible(true)
	end
	local curStar = self._subMapInfo["1"][tostring(levelData.id)].star
	if curStar < levelData.star then
		if levelData.star == 1 then
			rootnode.star_1:setDisplayFrame(display.newSpriteFrame("submap_star_dark.png"))
		elseif levelData.star == 2 then
			rootnode.star_1:setDisplayFrame(display.newSpriteFrame("submap_star_dark.png"))
			if curStar == 0 then
				rootnode.star_2:setDisplayFrame(display.newSpriteFrame("submap_star_dark.png"))
			end
		elseif curStar == 0 then
			rootnode.star_1:setDisplayFrame(display.newSpriteFrame("submap_star_dark.png"))
			rootnode.star_2:setDisplayFrame(display.newSpriteFrame("submap_star_dark.png"))
			rootnode.star_3:setDisplayFrame(display.newSpriteFrame("submap_star_dark.png"))
		elseif curStar == 1 then
			rootnode.star_1:setDisplayFrame(display.newSpriteFrame("submap_star_dark.png"))
			rootnode.star_3:setDisplayFrame(display.newSpriteFrame("submap_star_dark.png"))
		elseif curStar == 2 then
			rootnode.star_3:setDisplayFrame(display.newSpriteFrame("submap_star_dark.png"))
		end
	end
	local titleLabel = ui.newTTFLabelWithOutline({
	text = levelData.name,
	font = FONTS_NAME.font_haibao,
	size = 30,
	color = FONT_COLOR.LEVEL_NAME,
	outlineColor = FONT_COLOR.BLACK,	
	align = ui.TEXT_ALIGN_CENTER,
	x = rootnode.level_title:getContentSize().width / 2,
	y = rootnode.level_title:getContentSize().height / 2
	})
	self._needPower = levelData.power
	rootnode.level_title:addChild(titleLabel)
	rootnode.tag_info_tili:setString(self._needPower)
	rootnode.tag_tiaozhan_max:setString("/" .. levelData.number)
	self._dayCnt = self._subMapInfo["1"][tostring(levelData.id)].cnt
	if self._dayCnt > levelData.number then
		ResMgr.debugBanner(common:getLanguageString("@ServerLeftTimeError", self._dayCnt, levelData.number))
		self._dayCnt = levelData.number
	elseif 0 > self._dayCnt then
		ResMgr.debugBanner(common:getLanguageString("@ServerLeftTimeErrorDesc2", self._dayCnt))
		self._dayCnt = 0
	end
	rootnode.tag_tiaozhan_count:setString(tostring(self._dayCnt))
	self.restNum = rootnode.tag_tiaozhan_count
	alignNodesOneByAllCenterX(rootnode.tag_tiaozhan_count:getParent(), {
	rootnode.sub_info_label_1,
	rootnode.tag_tiaozhan_count,
	rootnode.tag_tiaozhan_max
	}, 1)
	alignNodesOneByAllCenterX(rootnode.sub_info_label_2:getParent(), {
	rootnode.sub_info_label_2,
	rootnode.tag_info_tili
	}, 1)
	
	--self._lianzhanCnt = levelData.lianzhan
	self._lianzhanCnt = levelData.number	
	if self._lianzhanCnt > self._dayCnt then
		self._lianzhanCnt = self._dayCnt
	end
	
	self._hastouchLianzhan = false
	self._secWait = self._subMapInfo["2"].secWait
	self._clearGold = self._subMapInfo["2"].cdClrCnt
	
	--返回
	rootnode.tag_close:addHandleOfControlEvent(function()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		ResMgr.isInSubInfo = false
		if self.removeListener ~= nil then
			self.removeListener()
		end
		self:removeSelf()
	end,
	CCControlEventTouchUpInside)
	
	--阵容
	rootnode.tag_info_buzhen:addHandleOfControlEvent(function()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		rootnode.tag_info_buzhen:setEnabled(false)
		local formCtrl = require("game.form.FormCtrl")
		formCtrl.createFormSettingLayer({
		parentNode = game.runningScene,
		touchEnabled = true,
		closeListener = function()
			rootnode.tag_info_buzhen:setEnabled(true)
		end
		})
	end,
	CCControlEventTouchUpInside)
	
	local bossBoardBg = rootnode.tag_bossinfo
	local iconSize = 0
	if #levelData.arr_dropid > 5 then
		iconSize = rewardSize * 2
	else
		iconSize = rewardSize
	end
	local boardWidth = bossBoardBg:getContentSize().width
	local boardHeight = bossBoardBg:getContentSize().height
	local offx = -boardWidth * 0.5
	local offy = -boardHeight * 0.4
	local bgSize = bossBoardBg:getContentSize()
	local bossIconBg = ResMgr.getLevelBossIcon(levelData.icon, levelData.type)
	bossIconBg:setPosition(bossBoardBg:getContentSize().width * 0.17, bossBoardBg:getContentSize().height * 0.45)
	bossBoardBg:addChild(bossIconBg)
	local levelModeBg = display.newScale9Sprite("#levelinfo_boss_bg2.png", 0, 0, CCSize(bgSize.width, 10 + (levelBoard:getContentSize().height + 5) * levelData.star))
	levelModeBg:setPosition(bossBoardBg:getPositionX(), bossBoardBg:getPositionY() - bossBoardBg:getContentSize().height / 2 - 5)
	levelModeBg:setAnchorPoint(0.5, 1)
	bossBoardBg:addChild(levelModeBg)
	self.passedStars = self._subMapInfo["1"][tostring(levelData.id)].star
	self._levelItems = {}
	local item = require("game.Maps.LevelGradeItem").new({
	grade = 1,
	star = self._subMapInfo["1"][tostring(levelData.id)].star,
	silver = levelData.num1[1],
	xiahun = levelData.num1[2],
	coinType = levelData.coin1,
	desc = levelData.describe1,
	lianzhanCnt = self._lianzhanCnt,
	secWait = self._secWait,
	needGold = self._clearGold,
	lianzhanFight = handler(self, SubMapInfoLayer.lianzhanFight),
	fight = function(grade, isPassed)
		self:normalFight(grade, levelData, isPassed)
	end
	})
	item:setPosition(levelModeBg:getContentSize().width / 2, levelModeBg:getContentSize().height - 8 - item:getContentSize().height / 2)
	levelModeBg:addChild(item)
	table.insert(self._levelItems, item)
	if levelData.star > 1 then
		local item2 = require("game.Maps.LevelGradeItem").new({
		grade = 2,
		star = self._subMapInfo["1"][tostring(levelData.id)].star,
		silver = levelData.num2[1],
		xiahun = levelData.num2[2],
		coinType = levelData.coin1,
		desc = levelData.describe2,
		lianzhanCnt = self._lianzhanCnt,
		secWait = self._secWait,
		needGold = self._clearGold,
		lianzhanFight = handler(self, SubMapInfoLayer.lianzhanFight),
		fight = function(grade, isPassed)
			self:normalFight(grade, levelData, isPassed)
		end
		})
		item2:setPosition(item:getPositionX(), item:getPositionY() - item:getContentSize().height - 5)
		levelModeBg:addChild(item2)
		table.insert(self._levelItems, item2)
	end
	if levelData.star == 3 then
		local item3 = require("game.Maps.LevelGradeItem").new({
		grade = 3,
		star = self._subMapInfo["1"][tostring(levelData.id)].star,
		silver = levelData.num3[1],
		xiahun = levelData.num3[2],
		coinType = levelData.coin1,
		desc = levelData.describe3,
		lianzhanCnt = self._lianzhanCnt,
		secWait = self._secWait,
		needGold = self._clearGold,
		lianzhanFight = handler(self, SubMapInfoLayer.lianzhanFight),
		fight = function(grade, isPassed)
			self:normalFight(grade, levelData, isPassed)
		end
		})
		item3:setPosition(item:getPositionX(), item:getPositionY() - item:getContentSize().height * 2 - 5)
		levelModeBg:addChild(item3)
		table.insert(self._levelItems, item3)
	end
	if levelData.arr_dropid ~= nil then
		local data_item_item = require("data.data_item_item")
		local chanceToLootBoard = display.newScale9Sprite("#levelinfo_boss_bg2.png", 0, 0, cc.size(levelModeBg:getContentSize().width, iconSize * 1))
		chanceToLootBoard:setPosition(levelModeBg:getContentSize().width / 2, -chanceToLootBoard:getContentSize().height / 2 - 15)
		levelModeBg:addChild(chanceToLootBoard)
		
		local fontcolor = {
		FONT_COLOR.WHITE,
		FONT_COLOR.GREEN_1,
		FONT_COLOR.BLUE,
		FONT_COLOR.PURPLE,
		FONT_COLOR.ORANGE
		}
		local itemType = 1
		local iconWidth = 95
		local iconHeight = 95
		for k, v in pairs(levelData.arr_dropid) do
			local itemData = data_item_item[v]
			ResMgr.showAlert(itemData, common:getLanguageString("@ServerItemTable", v))
			if itemData.type <= 3 then
				itemType = ResMgr.EQUIP
			elseif itemData.type == 5 then
				itemType = ResMgr.HERO
			else
				itemType = ResMgr.ITEM
			end
			local itemName
			local itemIcon = ResMgr.getIconSprite({id = v, resType = itemType})
			local posX = iconWidth * 0.85 + math.floor((k - 1) % 5) * iconWidth * 1.1
			local posY = chanceToLootBoard:getContentSize().height - iconHeight * 0.735 - 1 * itemIcon:getContentSize().height * math.floor((k - 1) / 5)
			if k > 5 then
				if itemName ~= nil then
					posY = posY - itemName:getContentSize().height - 5
				else
					posY = posY - 30
				end
				if itemType == ResMgr.HERO then
					posY = posY + 8
				end
			end
			itemIcon:setPosition(posX, posY)
			chanceToLootBoard:addChild(itemIcon)
			local y = -10
			if itemType == ResMgr.HERO then
				y = -8
			end
			itemName = ui.newTTFLabelWithShadow({
			text = itemData.name,
			font = FONTS_NAME.font_fzcy,
			size = 20,
			color = fontcolor[itemData.quality],
			shadowColor = FONT_COLOR.BLACK,
			x = itemIcon:getContentSize().width / 2,
			y = y,
			align = ui.TEXT_ALIGN_CENTER
			})
			itemIcon:addChild(itemName)
			if itemData.type == 3 then
				local suipianIcon = display.newSprite("#sx_suipian.png")
				suipianIcon:setRotation(-15)
				suipianIcon:setAnchorPoint(ccp(0, 1))
				suipianIcon:setPosition(-0.13 * itemIcon:getContentSize().width, 0.9 * itemIcon:getContentSize().height)
				itemIcon:addChild(suipianIcon)
			elseif itemData.type == 5 then
				local canhunIcon = display.newSprite("#sx_canhun.png")
				canhunIcon:setRotation(-18)
				canhunIcon:setAnchorPoint(ccp(0, 1))
				canhunIcon:setPosition(-0.13 * itemIcon:getContentSize().width, 0.93 * itemIcon:getContentSize().height)
				itemIcon:addChild(canhunIcon)
			end
		end
	end
	self:addChild(levelBoard)
	levelBoard:removeSelf()
	self:schedule(function()
		if self._secWait > 0 then
			self._secWait = self._secWait - 1
			self._subMapInfo["2"].secWait = self._secWait
		end
	end,
	1)
end

function SubMapInfoLayer:checkBag()
	local function extendBag(data)
		if self._bagObj[1].curCnt < data["1"] then
			table.remove(self._bagObj, 1)
		else
			self._bagObj[1].cost = data["4"]
			self._bagObj[1].size = data["5"]
		end
		if #self._bagObj > 0 then
			self:addChild(require("utility.LackBagSpaceLayer").new({
			bagObj = self._bagObj,
			callback = function(data)
				extendBag(data)
			end
			}),
			MAX_ZORDER)
		else
			self._isBagFull = false
		end
	end
	if self._isBagFull == true then
		self:addChild(require("utility.LackBagSpaceLayer").new({
		bagObj = self._bagObj,
		callback = function(data)
			extendBag(data)
		end
		}), MAX_ZORDER)
	end
end

--创建购买地图数量
function SubMapInfoLayer:createBuyMsgBox()
	local submapID = game.player.m_cur_normal_fuben_ID
	local buySubMapBox = require("game.Maps.SubMapBuyMsgBox").new({
	removeListener = function()
		if self.refreshSubInfo ~= nil then
			self.refreshSubInfo()
		end
	end,
	errorCallBack = function()
		local function _callback(errorCode, mapData)
			if errorCode == "" then
				local msg = {
				submapID = submapID,
				subMap = mapData.subMapStar
				}
				scene = UIManager:newScene("SubMapLayer")
				game.runningScene = scene
				local layer = UIManager:getSubMapLayer(msg)
				scene:addChild(layer)
				display.replaceScene(scene, "fade", 0.3, display.COLOR_WHITE)
				GameStateManager.currentState = GAME_STATE.STATE_SUBMAP
			else
				CCMessageBox(errorCode, "server data error")
			end
		end
		MapModel:requestMapData(clickedBigMapId, _callback)
		self:removeSelf()
	end
	})
	display.getRunningScene():addChild(buySubMapBox, 1000)
end

function SubMapInfoLayer:normalFight(grade, levelData, isPassed)
	if self._dayCnt <= 0 then
		SubMapModel.curlevelId = levelData.id
		self:createBuyMsgBox()
		return
	end
	if game.player:getStrength() < self._needPower then
		self:addChild(require("game.Maps.TiliMsgBox").new({
		updateListen = function()
			PostNotice(NoticeKey.CommonUpdate_Label_Tili)
		end
		}), MAX_ZORDER)
	elseif self._isBagFull == true then
		self:checkBag()
	else
		local msg = {}
		msg.levelData = levelData
		msg.grade = grade
		msg.star = self.passedStars
		msg.needPower = self._needPower
		msg.isPassed = isPassed
		PostNotice(NoticeKey.REMOVE_TUTOLAYER)
		GameStateManager:ChangeState(GAME_STATE.STATE_NORMAL_BATTLE, msg)
	end
end

function SubMapInfoLayer:lianzhanFight(grade)
	local bHasOpen, prompt = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.ShilianZhan_FuBen, game.player:getLevel(), game.player:getVip())
	if not bHasOpen then
		show_tip_label(prompt)
		return
	end
	local function clearTime()
		if game.player:getGold() < self._clearGold then
			show_tip_label(common:getLanguageString("@PriceEnough"))
		else
			RequestHelper.lianzhan.clearCDTime({
			id = self._id,
			t = 2,
			callback = function(data)
				dump(data)
				if string.len(data["0"]) > 0 then
					CCMessageBox(data["0"], "Error")
				else
					for i, v in ipairs(self._levelItems) do
						v:updateBtnMsg()
					end
					self._secWait = 0
					self._subMapInfo["2"].secWait = 0
					game.player:updateMainMenu({
					gold = data["1"]
					})
				end
			end
			})
		end
	end
	if self._secWait > 0 then
		local msgBox = require("game.Maps.LianzhanMsgBox").new({
		gold = self._clearGold,
		listener = function()
			clearTime()
		end
		})
		self:addChild(msgBox, LIANZHAN_ZORDER)
		return
	end
	local totalNeedPower = self._lianzhanCnt * self._needPower
	if totalNeedPower > game.player:getStrength() then
		self:addChild(require("game.Maps.TiliMsgBox").new({
		updateListen = function()
			PostNotice(NoticeKey.CommonUpdate_Label_Tili)
		end
		}),MAX_ZORDER)
	elseif self._isBagFull == true then
		self:checkBag()
	else
		local function lianzhanReq(...)
			RequestHelper.lianzhan.battle({
			id = tostring(self._id),
			type = tostring(grade),
			n = tostring(self._lianzhanCnt),
			callback = function(data)
				MapModel:setCurSmallMapData(self._id, grade, self._lianzhanCnt)
				game.player:setStrength(game.player.m_strength - totalNeedPower)
				if string.len(data["0"]) > 0 then
					CCMessageBox(data["0"], "Error")
				else
					self._hastouchLianzhan = false
					local lianzhanResult = require("game.Maps.LianzhanLayer").new({
					id = self._id,
					data = data,
					closeListener = function()
						local action = transition.sequence({
						CCFadeOut:create(0.3),
						CCCallFunc:create(function()
							if self.removeListener ~= nil then
								self.removeListener(true)
							end
						end),
						CCRemoveSelf:create(true)
						})
						self:runAction(action)
					end
					})
					self:addChild(lianzhanResult, LIANZHAN_ZORDER)
					local beforeLevel = game.player.getLevel()
					local curlevel = data["4"] or beforeLevel
					local curExp = data["5"] or 0
					game.player:updateMainMenu({lv = curlevel, exp = curExp})
					local curLv = game.player:getLevel()
					if beforeLevel < curLv then
						local curNail = game.player:getNaili()
						self:addChild(UIManager:getLayer("game.LevelUp.LevelUpLayer", nil, {
						level = beforeLevel,
						uplevel = curLv,
						naili = curNail,
						curExp = curExp
						}), LEVELUP_ZORDER)
					end
				end
			end
			})
		end
		if self._hastouchLianzhan == false then
			self._hastouchLianzhan = true
			lianzhanReq()
		end
	end
end

function SubMapInfoLayer:onEnter()
	TutoMgr.active()
	ResMgr.removeMaskLayer()
end

function SubMapInfoLayer:onExit()
	ResMgr.isInSubInfo = false
	self:unscheduleUpdate()
	CCTextureCache:sharedTextureCache():removeUnusedTextures()
end

return SubMapInfoLayer