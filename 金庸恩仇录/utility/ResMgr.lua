local data_pet_pet = require("data.data_pet_pet")
local data_item_item = require("data.data_item_item")
local data_card_card = require("data.data_card_card")
local data_shake_shake = require("data.data_shake_shake")
local data_atk_number_time_time = require("data.data_atk_number_time_time")
local data_viplevel_viplevel = require("data.data_viplevel_viplevel")
local data_message_message = require("data.data_message_message")
local data_item_nature = require("data.data_item_nature")
local data_pet_skill = require("data.data_petskill_petskill")
local data_fashion_fashion = require("data.data_fashion_fashion")
local data_cheats_cheats = require("data.data_miji_miji")
require("data.data_error_error")
require("utility.MppUI")


local ccs = ccs or {}
ccs.MovementEventType = {
START = 0,
COMPLETE = 1,
LOOP_COMPLETE = 2,
}

local ResMgr = {}
ResMgr.isShowCharName = false

--[[是否在进入小地图的信息界面]]
ResMgr.isInSubInfo = false

--[[是否在进入小地图界面里]]
ResMgr.intoSubMap = false

--[[战斗缩放的基数]]
ResMgr.TIME_SCALE_BASE_FACTOR = data_atk_number_time_time[1]["game_scale"]/1000 or 1

ResMgr.battleTimeScale = 1

function ResMgr.setTimeScale(scale)
	CCDirector:sharedDirector():getScheduler():setTimeScale(scale*ResMgr.TIME_SCALE_BASE_FACTOR)
end

ResMgr.spriteFrameCntTable = {}

function ResMgr.addSpriteFramesWithFile(plistFilename, image)
	if ResMgr.spriteFrameCntTable[plistFilename] == nil then
		ResMgr.spriteFrameCntTable[plistFilename] = 0
	end
	ResMgr.spriteFrameCntTable[plistFilename] = ResMgr.spriteFrameCntTable[plistFilename] + 1
	display.addSpriteFramesWithFile(plistFilename, image)
end

function ResMgr.removeSpriteFramesWithFile(plistFilename, image)
	if ResMgr.spriteFrameCntTable[plistFilename] ~= nil and ResMgr.spriteFrameCntTable[plistFilename] > 0 then
		ResMgr.spriteFrameCntTable[plistFilename] = ResMgr.spriteFrameCntTable[plistFilename] - 1
	end
	if ResMgr.spriteFrameCntTable[plistFilename] ~= nil and ResMgr.spriteFrameCntTable[plistFilename] == 0 then
		display.removeSpriteFramesWithFile(plistFilename, image)
	end
end

function ResMgr:getPosInScene(node)
	local nodeCenterPos = cc.p(node:getContentSize().width / 2, node:getContentSize().height / 2)
	local nodePos = node:convertToWorldSpace(nodeCenterPos)
	return nodePos
end

function ResMgr.flipCard(sprite, refreshFunc, curTime)
	local time = curTime or 0.2
	sprite:runAction(transition.sequence({
	CCScaleTo:create(time, 0.01, 1),
	CCCallFuncN:create(refreshFunc),
	CCScaleTo:create(time, 1, 1)
	}))
end

function ResMgr.runFuncByOpenCheck(param)
	local openKey = param.openKey
	local openFunc = param.openFunc
	local bHasOpen, prompt = OpenCheck.getOpenLevelById(openKey, game.player:getLevel(), game.player:getVip())
	if not bHasOpen then
		show_tip_label(prompt)
	elseif openFunc ~= nil then
		openFunc()
	end
end

ResMgr.SFX = "sfx"
ResMgr.BATTLE_SFX = "battlesfx"
ResMgr.SKILL_SFX = "skill"
ResMgr.PERSION_SFX = "person"

function ResMgr.playSfx(sfxName, sfxDir)
	local path = "sound/" .. sfxDir .. "/" .. sfxName
	return GameAudio.playSound(path, false)
end

function ResMgr.getMsg(id)
	local msg = data_message_message[id]
	return msg.text
end

function ResMgr.showMsg(id, delay)
	local msg = data_message_message[id]
	if msg ~= nil then
		local text = msg.text
		show_tip_label(text, delay)
	else
		show_tip_label(common:getLanguageString("@cuo") .. id)
	end
end

function ResMgr.showErr(id, str)
	local msgStr = str or ""
	local errMsg = data_error_error[id]
	if errMsg ~= nil then
		local text = errMsg.prompt
		show_tip_label(text .. msgStr)
	else
		show_tip_label(common:getLanguageString("@cuo") .. id)
	end
end

function ResMgr.getNatureName(natureId)
	return data_item_nature[natureId].nature
end

--[[1装备2时装3装备碎片4内外功5武将碎片6精元只有动画icon7可使用物品  只有icon8武将9内功碎片10外功碎片11礼品]]
ResMgr.HERO     = 1
ResMgr.EQUIP    = 2
ResMgr.ITEM     = 3

--[[根据名字跟type在不同路径下寻找资源 1 人物 2 武器装备 3 背包物品]]
ResMgr.UI_EFFECT = 4
ResMgr.NORMAL_EFFECT = 5
ResMgr.SPIRIT = 6
ResMgr.TEST_EFFECT = 7

--[[创建动画的类型， 用来规定在哪个路径下]]
ResMgr.HERO_BG_BATTLE = 6
ResMgr.HERO_BG_UI = 7
ResMgr.ITEM_BG_UI = 8
ResMgr.PET = 9
ResMgr.PET_SKILL = 10
ResMgr.FASHION = 11
ResMgr.CHEATS = 17
ResMgr.CHEATS_SUIPIAN = 18

--[[竞技场，夺宝，论剑，的敌人的名字]]
ResMgr.oppName = ""
--icon's tag
ResMgr.iconImage = 1
ResMgr.iconFrame = 2
ResMgr.isBottomEnabled = true

function ResMgr.getCardData(index)
	local cardData = data_card_card[index]
	if cardData == nil then
		show_tip_label("卡牌不存在_id: " ..index)
		return
	end
	if cardData.table == 0 then
		return cardData
	else
		local cardName = "data_"..cardData.table.."_card"
		local npcCard = require("data."..cardName)
		return npcCard[index]
	end
end

function ResMgr.getPetData(index)
	local petData = data_pet_pet[index]
	return petData
end

function ResMgr.getPetNameColor(resId)
	local petData = ResMgr.getPetData(resId)
	local star = petData.star or 1
	if star > #QUALITY_COLOR then
		star = 1
	end
	local nameColor = QUALITY_COLOR[star]
	return nameColor
end

function ResMgr.getPetSkillData(index)
	local petDataSkill = data_pet_skill[index]
	return petDataSkill
end

function ResMgr.getCheatsData(index)
	local cheatsData = data_cheats_cheats[index]
	cheatsData.resId = cheatsData.id
	return cheatsData
end

function ResMgr.getIconSprite(param)
	local id = param.id
	local resType = param.resType
	local cls = param.cls or 0
	local star = param.star
	local hasCorner = param.hasCorner or false
	display.addSpriteFramesWithFile("ui/ui_icon_frame.plist", "ui/ui_icon_frame.png")
	local path = ""
	local _data = {}
	local itemStar = 1
	local cardData
	if resType == ResMgr.HERO then
		path = "hero"
		cardData = ResMgr.getCardData(id)
		itemStar = star or cardData.star[1]
	elseif resType == ResMgr.EQUIP or resType == ResMgr.FASHION then
		path = "equip"
		_data = data_item_item
		itemStar = star or _data[id].quality
	elseif resType == ResMgr.ITEM then
		_data = data_item_item
		path = "items"
		if _data[id].type == ITEM_TYPE.zhenshen then
			path = "hero"
		end
		itemStar = star or _data[id].quality
	elseif resType == ResMgr.PET then
		path = "pet"
		_data = data_pet_pet
		itemStar = star or _data[id].star
	elseif resType == ResMgr.PET_SKILL then
		path = "pet"
		_data = ResMgr.getPetSkillData(id)
		itemStar = star or 4
		--[[
	elseif resType == ResMgr.FASHION then
		path = "equip"
		-data = data_fashion_fashion
		itemStar = star or _data[id].quality
		]]
	elseif resType == ResMgr.CHEATS or resType == ResMgr.CHEATS_SUIPIAN then
		path = "cheats"
		_data = data_cheats_cheats
		itemStar = star or _data[id].quality
	end
	if resType == ResMgr.HERO then
		--传过来的CLS最少为0，而这里查询最小为1
		path = path .. "/icon/" .. cardData.arr_icon[cls + 1] .. ".png"
	elseif resType == ResMgr.PET_SKILL then
		path = path .. "/skill/" .. _data.skillIcon .. ".png"
	else
		path = path .. "/icon/" .. _data[id].icon .. ".png"
	end
	local itemBg = display.newSprite(string.format("#icon_frame_bg_%d.png", itemStar))
	local item = display.newSprite(path)
	local itemFrame = display.newSprite(string.format("#icon_frame_board_%d.png", itemStar))
	item:setTag(ResMgr.iconImage)
	itemFrame:setTag(ResMgr.iconFrame)
	itemBg:addChild(item)
	item:setPosition(itemBg:getContentSize().width / 2, itemBg:getContentSize().height / 2)
	itemBg:addChild(itemFrame)
	itemFrame:setPosition(itemBg:getContentSize().width / 2, itemBg:getContentSize().height / 2)
	if hasCorner == true then
		local itemCorner = display.newSprite(string.format("#icon_corner_%d.png", itemStar))
		itemCorner:setPosition(itemCorner:getContentSize().width / 2, itemFrame:getContentSize().height - itemCorner:getContentSize().height / 2)
		itemFrame:addChild(itemCorner)
	end
	if _data[id] ~= nil and _data[id].type == ITEM_TYPE.zhenshen then
		local zhenshenIcon = display.newSprite("ui_CommonResouces/ui_zhenshen.png")
		zhenshenIcon:setRotation(-15)
		zhenshenIcon:setAnchorPoint(cc.p(0, 1))
		zhenshenIcon:setPosition(-0.13 * itemBg:getContentSize().width, 0.9 * itemBg:getContentSize().height)
		itemBg:addChild(zhenshenIcon, 100)
	end
	return itemBg
end
function ResMgr.createMaskLayer(node)
	local trueColor = ccc4(0, 0, 0, 0)
	if ResMgr.greenLayer == nil then
		ResMgr.greenLayer = require("utility.MaskLayer").new({
		color = trueColor,
		notice = NoticeKey.REMOVE_MASKLAYER
		})
		ResMgr.greenLayer:retain()
	end
	if ResMgr.greenLayer:getParent() ~= nil then
		ResMgr.greenLayer:removeSelf()
	end
	if node == nil then
		display.getRunningScene():addChild(ResMgr.greenLayer, MASK_LAYER_ZORDER)
	else
		node:addChild(ResMgr.greenLayer, MASK_LAYER_ZORDER)
	end
end
function ResMgr.removeTutoMask()
	if ResMgr.blueLayer ~= nil then
		if ResMgr.blueLayer:getParent() ~= nil then
			ResMgr.blueLayer:removeSelf()
		end
		if ResMgr.blueLayer ~= nil then
			ResMgr.blueLayer:release()
		end
	end
	ResMgr.blueLayer = nil
end
function ResMgr.setControlBtnEvent(btn, func, sound, maxInterval)
	btn.lastPressTime = 0
	local maxInter = maxInterval or 0.4
	btn:addHandleOfControlEvent(function ()
		local curTime = GameModel.getLocalTimeInSec()
		if curTime - btn.lastPressTime < maxInter then
			return
		end
		btn.lastPressTime = curTime
		if func ~= nil then
			func()
		end
		if sound == nil then
			GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		elseif sound ~= "" then
			GameAudio.playSound(ResMgr.getSFX(sound))
		end
	end,
	CCControlEventTouchUpInside)
end
function ResMgr.setNodeEvent(param)
	local curNode = param.node
	local tableViewRect = param.tableViewRect
	local touchFunc = param.touchFunc
	local isMoved = false
	curNode.lastPressTime = 0
	local maxInter = param.maxInterval or 0.15
	curNode:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
		local touchPos = cc.p(event.x, event.y)
		local isInViewBg
		if tableViewRect == nil then
			isInViewBg = true
		else
			isInViewBg = tableViewRect:containsPoint(touchPos)
		end
		if isInViewBg == true then
			if event.name == "began" then
				local curTime = os.clock()
				if curTime - curNode.lastPressTime < maxInter then
					return true
				end
				curNode.lastPressTime = curTime
				isMoved = false
				return true
			elseif event.name == "moved" then
				if math.abs(event.y - event.prevY) > 10 or 10 < math.abs(event.x - event.prevX) then
					isMoved = true
				end
			elseif event.name == "ended" then
				ResMgr.delayFunc(1, function ()
					isMoved = false
				end,
				self)
				if isMoved ~= true and touchFunc ~= nil then
					touchFunc()
				end
			end
		end
	end)
end

function ResMgr.createTutoMask(node)
	local trueColor = ccc4(0, 0, 0, 0)
	ResMgr.blueLayer = require("utility.SimpleColorLayer").new(trueColor)
	ResMgr.blueLayer:setTouchSwallowEnabled(true)
	ResMgr.blueLayer:retain()
	if node == nil then
		display.getRunningScene():addChild(ResMgr.blueLayer, TUTO_MASK_ZORDER)
	else
		node:addChild(ResMgr.blueLayer, TUTO_MASK_ZORDER)
	end
end

function ResMgr.getArrangedNode(rowTable)
	local arrNode = display.newNode()
	local rowWidth = 0
	for i = 1, #rowTable do
		rowWidth = rowWidth + rowTable[i]:getContentSize().width
	end
	local posX = 0
	for i = 1, #rowTable do
		rowTable[i]:align(display.LEFT_CENTER, posX, rowTable[i]:getContentSize().height / 2)
		posX = posX + rowTable[i]:getContentSize().width + 5
		arrNode:addChild(rowTable[i])
	end
	arrNode.rowWidth = rowWidth
	return arrNode
end

function ResMgr.createNomarlMsgTTF(param)
	local text = param.text or ""
	local color = param.color or cc.c3b(59, 4, 4)
	local size = param.size or 22
	local normalLabel = ui.newTTFLabel({
	text = text,
	color = color,
	size = size,
	font = FONTS_NAME.font_fzcy,
	align = ui.TEXT_ALIGN_LEFT
	})
	return normalLabel
end
function ResMgr.createOutlineMsgTTF(param)
	local text = param.text or ""
	local color = param.color or cc.c3b(255, 255, 255)
	local outlineColor = param.outlineColor or cc.c3b(0, 0, 0)
	local size = param.size or 22
	local shaTTF = ui.newTTFLabelWithOutline({
	text = text,
	size = size,
	color = color,
	outlineColor = outlineColor,
	font = FONTS_NAME.font_fzcy,
	align = ui.TEXT_ALIGN_LEFT
	})
	if param.parentNode ~= nil then
		param.parentNode:removeAllChildren()
		param.parentNode:addChild(shaTTF)
	end
	return shaTTF
end
function ResMgr.createShadowMsgTTF(param)
	local text = param.text or ""
	local color = param.color or cc.c3b(255, 255, 255)
	local shadowColor = param.shadowColor or cc.c3b(0, 0, 0)
	local size = param.size or 22
	local shaTTF = ui.newTTFLabelWithShadow({
	text = text,
	size = size,
	color = color,
	shadowColor = shadowColor,
	font = FONTS_NAME.font_fzcy,
	align = ui.TEXT_ALIGN_LEFT,
	dimensions = param.dimensions
	})
	if param.parentNode ~= nil then
		param.parentNode:removeAllChildren()
		param.parentNode:addChild(shaTTF)
	end
	return shaTTF
end

function ResMgr.getVipIconTTF()
	local vipLv = game.player.m_vip
	local vipIcon = display.newSprite("ui/new_btn/vip_icon.png")
	vipIcon:align(display.LEFT_CENTER)
	local lvTTF = ui.newBMFontLabel({
	text = "VIP" .. vipLv,
	font = "fonts/font_vip.fnt",
	--align = ui.TEXT_ALIGN_LEFT,
	--valign = TEXT_VALIGN_BOTTOM,
	})
	lvTTF:align(display.LEFT_CENTER)
	return vipIcon, lvTTF
end

function ResMgr.removeBefLayer()
	dump("removoeododobebe")
	for i = 1, #ResMgr.befTutoTable do
		if ResMgr.befTutoTable[i]:getParent() ~= nil then
			ResMgr.befTutoTable[i]:removeSelf()
		end
		ResMgr.befTutoTable[i]:release()
	end
	ResMgr.befTutoTable = {}
end

ResMgr.befTutoTable = {}
function ResMgr.createBefTutoMask(node)
	dump("createteetbefffuffu")
	local trueColor = cc.c4b(0, 0, 0, 0)
	if GAME_DEBUG == true and  SHOW_MASK_LAYER == true then
		trueColor = cc.c4b(100, 0, 0, 100)
	end
	local befTutoLayer = display.newColorLayer(trueColor)
	befTutoLayer:setTouchEnabled(true)
	befTutoLayer:retain()
	ResMgr.befTutoTable[#ResMgr.befTutoTable + 1] = befTutoLayer
	if node == nil then
		display:getRunningScene():addChild(befTutoLayer, BEF_MASK_ZORDER)
	else
		node:addChild(befTutoLayer, BEF_MASK_ZORDER)
	end
end
function ResMgr.removeMaskLayer()
	PostNotice(NoticeKey.REMOVE_MASKLAYER)
end
function ResMgr.createTouchLayer(node)
	dump("toutoutotutu")
	local trueColor = cc.c4b(0, 0, 0, 0)
	if ResMgr.touchLayer == nil then
		ResMgr.touchLayer = require("utility.MaskLayer").new({color = trueColor})
		ResMgr.touchLayer:retain()
	end
	if ResMgr.touchLayer:getParent() ~= nil then
		ResMgr.touchLayer:removeSelf()
	end
	if node == nil then
		display:getRunningScene():addChild(ResMgr.touchLayer, BEF_MASK_ZORDER)
	else
		node:addChild(ResMgr.touchLayer, BEF_MASK_ZORDER)
	end
end
function ResMgr.removeTouchLayer()
	ResMgr.touchLayer:removeSelf()
end
function ResMgr.createParticle(filename)
	local path = "ccs/particle/" .. filename .. ".plist"
	local part = CCParticleSystemQuad:create(path)
	return part
end
function ResMgr.debugBanner(str)
	if (device.platform == "windows" or device.platform == "mac") and SHOW_MASK_LAYER == true then
		local debugTip = require("utility.NormalBanner").new({tipContext = str, delayTime = 5})
		debugTip:setPosition(display.width / 2, display.height * 0.7)
		display:getRunningScene():addChild(debugTip, 1000000)
	end
end
function ResMgr.isEnoughSilver(num)
	if num > game.player.m_silver then
		return false
	else
		return true
	end
end
function ResMgr.refreshMoneyIcon(param)
	display.addSpriteFramesWithFile("ui/ui_coin_icon.plist", "ui/ui_coin_icon.png")
	local itemBg = param.itemBg
	local moneyType = param.moneyType
	local tempBg
	if moneyType == 1 then
		tempBg = display.newSprite("#icon_gold.png")
	elseif moneyType == 2 then
		tempBg = display.newSprite("#icon_lv_silver.png")
	elseif moneyType == 10 then
		tempBg = display.newSprite("#icon_hunyu.png")
	elseif moneyType == 16 then
		tempBg = display.newSprite("#icon_chonghun.png")
	end
	if tempBg ~= nil then
		itemBg:setDisplayFrame(tempBg:getDisplayFrame())
	end
end
function ResMgr.refreshItemWithTagNumName(param)
	display.addSpriteFramesWithFile("ui/ui_shuxingIcon.plist", "ui/ui_shuxingIcon.png")
	local itemType = param.itemType
	local itemId = param.id
	local itemCls = param.cls
	local hasCorner = param.hasCorner
	local star = param.star
	local itemNum = param.itemNum or 1
	local isShowIconNum = param.isShowIconNum or 1
	local isGray = param.isGray or false
	local itemBg = param.itemBg
	local resType = param.resType
	local iconType
	if resType == nil then
		iconType = ResMgr.getResType(param.itemType)
	else
		iconType = resType
	end
	itemBg.group = {}
	
	--创建icon
	ResMgr.refreshIcon({
	id = itemId,
	resType = iconType,
	itemType = itemType,
	cls = itemCls,
	hasCorner = hasCorner,
	star = star,
	itemBg = itemBg,
	isGray = isGray
	})
	local cornerSprite = itemBg:getChildByTag(ResMgr.cornerTag)
	if cornerSprite then
		itemBg.group.tag = cornerSprite
	end
	local nameStr = ResMgr.getItemNameByType(itemId, iconType)
	local nameColor = ResMgr.getItemNameColorByType(itemId, iconType)
	if isGray == true then
		nameColor = cc.c3b(115, 115, 115)
	end
	local nameLbl = ui.newTTFLabelWithShadow({
	text = nameStr,
	size = 20,
	color = nameColor,
	shadowColor = FONT_COLOR.BLACK,
	font = FONTS_NAME.font_fzcy,
	align = ui.TEXT_ALIGN_CENTER,
	dimensions = cc.size(100, 0)
	})
	local itemSize = itemBg:getContentSize()
	nameLbl:setPosition(itemSize.width / 2, param.namePosY or -12)
	if isShowIconNum ~= 0 then
		local numTTF = ResMgr.createShadowMsgTTF({
		text = itemNum,
		color = cc.c3b(0, 255, 0),
		size = 22
		})
		numTTF:align(display.RIGHT_BOTTOM, itemSize.width - 5, 0)
		itemBg:addChild(numTTF)
	end
	if nameLbl ~= nil then
		itemBg:addChild(nameLbl)
		itemBg.group.name = nameLbl
	end
	function itemBg.getItem(name)
		return itemBg.group[name]
	end
	function itemBg.getGroup()
		return itemBg.group
	end
end
function ResMgr.getPlateItemIcon(id)
	local path = "items/icon/" .. data_item_item[id].icon .. ".png"
	local icon = display.newSprite(path)
	return icon
end
ResMgr.cornerTag = 8745
ResMgr.zhenshenTag = 8746
function ResMgr.refreshIcon(param)
	local FILETER_TAG = 10001
	local SUIT_ARMA_TAG = 10002
	local itemType = param.itemType
	local itemBg = param.itemBg
	local isReturn = false
	if itemBg == nil then
		isReturn = true
		itemBg = display.newSprite()
	end
	local IMAGE_TAG = 1
	local FRAME_TAG = 2
	local id = param.id
	local cardData
	local resType = param.resType
	local cls = param.cls or 0
	local hasCorner = param.hasCorner or false
	local star = param.star
	local iconNum = param.iconNum or 0
	local isShowIconNum = param.isShowIconNum or false
	local numLblSize = param.numLblSize or 22
	local numLblColor = param.numLblColor or cc.c3b(0, 255, 0)
	local numLblOutColor = param.numLblOutColor or cc.c3b(0, 0, 0)
	local isGray = param.isGray
	local cleanTable = {}
	display.addSpriteFramesWithFile("ui/ui_icon_frame.plist", "ui/ui_icon_frame.png")
	local path = ""
	local _data = {}
	local itemStar = 1
	if resType == ResMgr.HERO then
		path = "hero"
		_data = ResMgr.getCardData(id)
		cardData = ResMgr.getCardData(id)
		itemStar = cardData.star[cls + 1]
	elseif resType == ResMgr.EQUIP or resType == ResMgr.FASHION then
		path = "equip"
		_data = data_item_item
		itemStar = star or _data[id].quality
	elseif resType == ResMgr.ITEM then
		_data = data_item_item
		path = "items"
		if _data[id].type == ITEM_TYPE.zhenshen then
			path = "hero"
			itemType = _data[id].type
		end
		itemStar = star or _data[id].quality
	elseif resType == ResMgr.PET then
		path = "pet"
		_data = data_pet_pet
		itemStar = star or _data[id].star
	elseif resType == ResMgr.PET_SKILL then
		path = "pet"
		cardData = ResMgr.getPetSkillData(id)
		--[[
	elseif resType == ResMgr.FASHION then
		path = "equip"
		_data = data_fashion_fashion
		if not data_fashion_fashion[id] then
			id = id + game.player.getGender()
		end
		itemStar = star or _data[id].quality
		]]
	elseif resType == ResMgr.CHEATS or resType == ResMgr.CHEATS_SUIPIAN then
		path = "cheats"
		_data = data_cheats_cheats
		itemStar = star or _data[id].quality
	end
	if resType == ResMgr.HERO then
		--传过来的CLS最少为0，而这里查询最小为1
		cls = cls + 1
		if cls > #cardData.arr_icon then
			path = path .. "/icon/" .. cardData.arr_icon[#cardData.arr_icon] .. ".png"
		else
			path = path .. "/icon/" .. cardData.arr_icon[cls] .. ".png"
		end
	elseif resType == ResMgr.PET_SKILL then
		path = path .. "/skill/" .. cardData.skillIcon .. ".png"
	elseif resType == ResMgr.PET then
		path = path .. "/icon/" .. _data[id].icon .. ".png"
	else
		path = path .. "/icon/" .. _data[id].icon .. ".png"
	end
	local tempBg
	tempBg = display.newSprite(string.format("#icon_frame_bg_%d.png", itemStar or 1))
	itemBg:setDisplayFrame(tempBg:getDisplayFrame())
	if isGray == true then
		local fileter = display.newGraySprite(string.format("#icon_frame_bg_%d.png", itemStar or 1), {
		0.4,
		0.4,
		0.4,
		0.1
		})
		fileter:setPosition(itemBg:getContentSize().width / 2, itemBg:getContentSize().height / 2)
		itemBg:addChild(fileter)
		itemBg:removeChildByTag(FILETER_TAG, true)
		fileter:setTag(FILETER_TAG)
	end
	local zhenshenSprite = itemBg:getChildByTag(ResMgr.zhenshenTag)
	if zhenshenSprite ~= nil and zhenshenSprite:getParent() ~= nil then
		zhenshenSprite:removeFromParentAndCleanup(true)
	end
	local item = itemBg:getChildByTag(IMAGE_TAG)
	if item == nil then
		if isGray == true then
			item = display.newGraySprite(path, {
			0.4,
			0.4,
			0.4,
			0.1
			})
		else
			item = display.newSprite(path)
		end
		itemBg:addChild(item)
		item:setTag(IMAGE_TAG)
		item:setPosition(itemBg:getContentSize().width / 2, itemBg:getContentSize().height / 2)
	else
		local tempItem
		if isGray == true then
			tempItem = display.newGraySprite(path, {
			0.4,
			0.4,
			0.4,
			0.1
			})
		else
			tempItem = display.newSprite(path)
		end
		item:setDisplayFrame(tempItem:getDisplayFrame())
	end
	local itemFrame = itemBg:getChildByTag(FRAME_TAG)
	if itemFrame == nil then
		if isGray == true then
			itemFrame = display.newGraySprite(string.format("#icon_frame_board_%d.png", itemStar or 1), {
			0.4,
			0.4,
			0.4,
			0.1
			})
		else
			itemFrame = display.newSprite(string.format("#icon_frame_board_%d.png", itemStar or 1))
		end
		if itemFrame ~= nil then
			itemBg:addChild(itemFrame)
			itemFrame:setTag(FRAME_TAG)
			itemFrame:setPosition(itemBg:getContentSize().width / 2, itemBg:getContentSize().height / 2)
		end
	else
		local tempFrame = display.newSprite(string.format("#icon_frame_board_%d.png", itemStar or 1))
		if tempFrame ~= nil then
			itemFrame:setDisplayFrame(tempFrame:getDisplayFrame())
		end
	end
	if hasCorner == true then
		local itemCorner = display.newSprite(string.format("#icon_corner_%d.png", itemStar or 1))
		itemCorner:setPosition(itemFrame:getContentSize().width - itemCorner:getContentSize().width / 2, itemCorner:getContentSize().height / 2)
		itemFrame:addChild(itemCorner)
	end
	if iconNum > 1 or iconNum == 1 and isShowIconNum == true then
		local numLbl = ui.newTTFLabelWithOutline({
		text = tostring(iconNum),
		size = numLblSize,
		color = numLblColor,
		outlineColor = numLblOutColor,
		font = FONTS_NAME.font_fzcy,
		align = ui.TEXT_ALIGN_LEFT
		})
		--numLbl:setPosition(itemFrame:getContentSize().width - numLbl:getContentSize().width - 5, numLbl:getContentSize().height / 2)
		numLbl:align(display.RIGHT_BOTTOM, itemFrame:getContentSize().width - 5, 0)
		itemFrame:addChild(numLbl)
	end
	if itemBg:getChildByTag(SUIT_ARMA_TAG) ~= nil then
		itemBg:removeChildByTag(SUIT_ARMA_TAG, true)
	end
	local itemBgWidth = itemBg:getContentSize().width
	local itemBgHeight = itemBg:getContentSize().height
	if resType == ResMgr.EQUIP then
		if _data[id].Suit ~= nil and isGray ~= true then
			local quas = {
			"",
			"pinzhikuangliuguang_lv",
			"pinzhikuangliuguang_lan",
			"pinzhikuangliuguang_zi",
			"pinzhikuangliuguang_jin",
			"pinzhikuangliuguang_jin"
			}
			local holoName = quas[_data[id].quality]
			if holoName ~= "" then
				local suitArma = ResMgr.createArma({
				resType = ResMgr.UI_EFFECT,
				armaName = holoName,
				isRetain = true
				})
				suitArma:setPosition(itemBg:getContentSize().width / 2, itemBg:getContentSize().height / 2)
				suitArma:setTouchEnabled(false)
				itemBg:addChild(suitArma)
				suitArma:setTag(SUIT_ARMA_TAG)
			end
		end
	elseif resType == ResMgr.FASHION and _data[id].quality == 5 then
		local suitArma = ResMgr.createArma({
		resType = ResMgr.UI_EFFECT,
		armaName = "pinzhikuangliuguang_jin",
		isRetain = true
		})
		suitArma:setPosition(itemBg:getContentSize().width / 2, itemBg:getContentSize().height / 2)
		suitArma:setTouchEnabled(false)
		itemBg:addChild(suitArma)
		suitArma:setTag(SUIT_ARMA_TAG)
	end
	itemBg:setContentSize(cc.size(itemBgWidth, itemBgHeight))
	if itemType then
		local tagName
		if itemType == ITEM_TYPE.zhuangbei_suipian then
			if _data[id].para2 == ITEM_TYPE.shizhuang then
				tagName = "#sx_shizhuang.png"
			else
				tagName = "#sx_suipian.png"
			end
		elseif resType == ResMgr.CHEATS_SUIPIAN then
			tagName = "#sx_miji.png"
		elseif itemType == ITEM_TYPE.canhun or itemType == ITEM_TYPE.chongwu_suipian then
			tagName = "#sx_canhun.png"
		end
		if tagName ~= nil then
			display.addSpriteFramesWithFile("ui/ui_shuxingIcon.plist", "ui/ui_shuxingIcon.png")
			local tagSprite = display.newSprite(tagName)
			tagSprite:setPosition(itemBg:getContentSize().width * 0.3, itemBg:getContentSize().height * 0.85)
			tagSprite:setRotation(-20)
			itemBg:addChild(tagSprite)
			tagSprite:setTag(ResMgr.cornerTag)
		end
		if itemType == ITEM_TYPE.zhenshen then
			local zhenshenIcon = display.newSprite("ui_CommonResouces/ui_zhenshen.png")
			zhenshenIcon:setRotation(-20)
			zhenshenIcon:setPosition(itemBg:getContentSize().width * 0.2, itemBg:getContentSize().height * 0.85)
			itemBg:addChild(zhenshenIcon)
			zhenshenIcon:setTag(ResMgr.zhenshenTag)
		end
	end
	if isReturn then
		return itemBg
	end
end
function ResMgr.getItemNameColorByType(id, iconType)
	local nameColor = cc.c3b(255, 255, 255)
	if iconType == ResMgr.ITEM or iconType == ResMgr.EQUIP then
		nameColor = ResMgr.getItemNameColor(id)
	elseif iconType == ResMgr.HERO then
		nameColor = ResMgr.getHeroNameColor(id)
	elseif iconType == ResMgr.PET then
		nameColor = ResMgr.getPetNameColor(id)
	elseif iconType == ResMgr.FASHION then
		nameColor = ResMgr.getFashionNameColor(id)
	elseif iconType == ResMgr.CHEATS or iconType == ResMgr.CHEATS_SUIPIAN then
		nameColor = ResMgr.getCheatsNameColor(id)
	end
	return nameColor
end
function ResMgr.getRefreshIconItem(id, itemType)
	local resType = ResMgr.getResType(itemType)
	local item
	if resType == ResMgr.ITEM or resType == ResMgr.EQUIP or resType == ResMgr.FASHION then
		item = data_item_item[id]
	elseif resType == ResMgr.HERO then
		item = data_card_card[id]
	elseif resType == ResMgr.PET then
		item = data_pet_pet[id]
		--[[
	elseif resType == ResMgr.FASHION then
		if not data_fashion_fashion[id] then
			id = id + game.player.getGender()
		end
		item = data_fashion_fashion[id]
		]]
		
	elseif resType == ResMgr.CHEATS then
		item = data_cheats_cheats[id]
	end
	local iconItem = {}
	iconItem.id = item.id
	iconItem.type = itemType
	iconItem.name = item.name
	iconItem.describe = item.describe
	iconItem.iconType = resType
	return iconItem
end

function ResMgr.getItemByType(id, resType)
	local item
	if resType == ResMgr.FASHION or resType == ResMgr.ITEM or resType == ResMgr.EQUIP or resType == ResMgr.CHEATS_SUIPIAN then
		item = data_item_item[id]
	elseif resType == ResMgr.HERO then
		item = data_card_card[id]
	elseif resType == ResMgr.PET then
		item = data_pet_pet[id]
		--[[
	elseif resType == ResMgr.FASHION then
		if not data_fashion_fashion[id] then
			id = id + game.player.getGender()
		end
		item = data_fashion_fashion[id]
		]]
	elseif resType == ResMgr.CHEATS then
		item = data_cheats_cheats[id]
	end
	return item
end
function ResMgr.getItemNameByType(id, resType)
	local name
	if resType == ResMgr.FASHION or resType == ResMgr.ITEM or resType == ResMgr.EQUIP or resType == ResMgr.CHEATS_SUIPIAN then
		name = data_item_item[id].name
	elseif resType == ResMgr.HERO then
		name = data_card_card[id].name
	elseif resType == ResMgr.PET then
		name = data_pet_pet[id].name
		--[[
	elseif resType == ResMgr.FASHION then
		if not data_fashion_fashion[id] then
			id = id + game.player.getGender()
		end
		name = data_fashion_fashion[id].name
		]]
	elseif resType == ResMgr.CHEATS then
		name = data_cheats_cheats[id].name
	end
	return name
end
function ResMgr.getIconImage(name, resType)
	local path = ""
	if resType == ResMgr.HERO then
		path = "hero"
	elseif resType == ResMgr.EQUIP or resType == ResMgr.FASHION then
		path = "equip"
	elseif resType == ResMgr.ITEM then
		path = "items"
	elseif resType == ResMgr.CHEATS or resType == ResMgr.CHEATS_SUIPIAN then
		path = "cheats"
	end
	path = path .. "/icon/" .. name .. ".png"
	return path
end
function ResMgr.getLargeImage(name, resType)
	local path = ""
	if resType == ResMgr.HERO or resType == ResMgr.FASHION then
		path = "hero"
	elseif resType == ResMgr.EQUIP then
		path = "equip"
	elseif resType == ResMgr.ITEM then
		path = "items"
	elseif resType == ResMgr.PET then
		path = "pet"
	elseif resType == ResMgr.CHEATS or resType == ResMgr.CHEATS_SUIPIAN then
		path = "cheats"
	end
	path = path .. "/large/" .. name .. ".png"
	return path
end

function ResMgr.getMidImage(name, resType)
	local path = ""
	if resType == ResMgr.HERO then
		path = "ccs/cardHeros/" .. name .. "0.png"
	end
	return path
end

function ResMgr.getHeroMidImage(resId, cls, fashionId)
	local imageName
	if (resId == 1 or resId == 2) and fashionId ~= nil and fashionId > 0 then
		--dump(fashionId)
		imageName = data_item_item[fashionId].image[resId]
		--fashionId = fashionId or game.player:getFashionId()
		--if fashionId > 0 then
		--	imageName = data_item_item[fashionId].image[resId]
		--end
	end
	if not imageName then
		local cardData = ResMgr.getCardData(resId)
		imageName = cardData.arr_image[cls + 1]
	end
	local sprite = display.newSprite("ccs/cardHeros/" .. imageName .. "0.png")
	return sprite
end

function ResMgr.getHeroBodyName(resId, cls, fashionId)
	local pngName
	if resId == 1 or resId == 2 then
		fashionId = fashionId or game.player:getFashionId()
		if fashionId > 0 then
			pngName = data_item_item[fashionId].body[resId]
		end
	end
	if not pngName then
		local cardData = ResMgr.getCardData(resId)
		pngName = cardData.arr_body[cls + 1]
	end
	local pngPath = ResMgr.getLargeImage(pngName, ResMgr.HERO)
	return pngPath
end

function ResMgr.getHeroFrame(resId, cls, fashionId)
	local pngName
	if resId == 1 or resId == 2 then
		local id = fashionId or game.player:getFashionId()
		fashiondata = data_item_item[id]
		if fashiondata then
			pngName = fashiondata.body[resId]
		end
	end
	if not pngName then
		local cardData = ResMgr.getCardData(resId)
		pngName = cardData.arr_body[cls + 1]
	end
	local pngPath = ResMgr.getLargeImage(pngName, ResMgr.HERO)
	local tempSprite = display.newSprite(pngPath)
	return tempSprite:getDisplayFrame()
end

function ResMgr.getPetFrame(resId, cls)
	local petData = ResMgr.getPetData(resId)
	local pngName = petData.body
	local pngPath = ResMgr.getLargeImage(pngName, ResMgr.PET)
	local tempSprite = display.newSprite(pngPath)
	return tempSprite:getDisplayFrame()
end

function ResMgr.getLargeFrame(resType, resId, cls)
	if resType == ResMgr.HERO then
		return ResMgr.getHeroFrame(resId, cls or 0)
	elseif resType == ResMgr.EQUIP then
		local bigIcon = "equip/large/" .. data_item_item[resId].icon .. ".png"
		return display.newSprite(bigIcon):getDisplayFrame()
	elseif resType == ResMgr.ITEM then
		local bigIcon = "equip/large/" .. data_item_item[resId].icon .. ".png"
		return display.newSprite(bigIcon):getDisplayFrame()
	elseif resType == ResMgr.PET then
		return ResMgr.getPetFrame(resId, cls or 0)
	elseif resType == ResMgr.CHEATS or resType == ResMgr.CHEATS_SUIPIAN then
		local bigIcon = "cheats/large/" .. data_cheats_cheats[resId].icon .. ".png"
		return display.newSprite(bigIcon):getDisplayFrame()
	end
end
function ResMgr.refreshCardBg(param)
	local sprite = param.sprite
	local star = param.star
	local resType = param.resType
	local scaleX = sprite:getScaleX()
	local scaleY = sprite:getScaleY()
	if resType == ResMgr.HERO_BG_BATTLE then
		display.addSpriteFramesWithFile("ui_common/card_bg.plist", "ui_common/card_bg.png")
		sprite:setDisplayFrame(display.newSpriteFrame("kapai_" .. star .. ".png"))
	elseif resType == ResMgr.HERO_BG_UI then
		display.addSpriteFramesWithFile("ui/card_ui_bg.plist", "ui/card_ui_bg.png")
		sprite:setDisplayFrame(display.newSpriteFrame("card_ui_bg_" .. star .. ".png"))
	elseif resType == ResMgr.ITEM_BG_UI then
		display.addSpriteFramesWithFile("ui/ui_item_card_bg.plist", "ui/ui_item_card_bg.png")
		sprite:setDisplayFrame(display.newSpriteFrame("item_card_bg_" .. star .. ".png"))
	else
		dump(common:getLanguageString("@mei"))
	end
	sprite:setScaleX(scaleX)
	sprite:setScaleY(scaleY)
end

function ResMgr.createArma(param)
	local resType = param.resType --是哪种类型的动画 是普通动画？还是UI动画  指向不同的路径	
	local armaName = param.armaName --动画的名字	
	local frameTag = param.frameTag or "atkEff" --规定动画过程中触发的关键帧	
	local frameFunc = param.frameFunc --关键帧的回调函数
	local finishFunc = param.finishFunc --动画完结的回调函数	
	local playIndex = param.playIndex or 0
	local isRetain = param.isRetain --是否保留
	local path = ""
	if resType == ResMgr.NORMAL_EFFECT then
		path = "ccs/effect/" .. armaName .. "/" .. armaName .. ".ExportJson"
	elseif resType == ResMgr.UI_EFFECT then
		path = "ccs/ui_effect/" .. armaName .. "/" .. armaName .. ".ExportJson"
	elseif resType == ResMgr.SPIRIT then
		path = "jingmai/" .. armaName .. "/" .. armaName .. ".ExportJson"
	elseif resType == ResMgr.TEST_EFFECT then
		path = "ccs/testAnim/" .. armaName .. "/" .. armaName .. ".ExportJson"
	end
	
	if path ~= "" then
		CCArmatureDataManager:sharedArmatureDataManager():removeArmatureFileInfo(path)
		CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo(path)
		do
			local tempArma = CCArmature:create(armaName)
			tempArma:getAnimation():setFrameEventCallFunc(function (bone, evt, originFrameIndex, currentFrameIndex)
				if evt == frameTag and frameFunc ~= nil then
					frameFunc()
				end
			end)
			tempArma:getAnimation():setMovementEventCallFunc(function (armatureBack, movementType, movementID)
				if movementType == ccs.MovementEventType.COMPLETE then
					if isRetain ~= true then
						CCArmatureDataManager:sharedArmatureDataManager():removeArmatureFileInfo(path)
						tempArma:removeSelf()
					end
					if finishFunc ~= nil then
						finishFunc(tempArma)
					end
				end
			end)
			tempArma:getAnimation():playWithIndex(playIndex)
			return tempArma
		end
	else
		dump("Not this resTye")
	end
end

function ResMgr.ReleaseUIArmature(armaName)
	local path = "ccs/ui_effect/" .. armaName .. "/" .. armaName .. ".ExportJson"
	CCArmatureDataManager:sharedArmatureDataManager():removeArmatureFileInfo(path)
end

function ResMgr.getResType(itemType)
	if itemType == ITEM_TYPE.canhun or itemType == ITEM_TYPE.xiake then
		return ResMgr.HERO
	elseif itemType == ITEM_TYPE.zhenqi or itemType == ITEM_TYPE.daoju or itemType == ITEM_TYPE.lipin or itemType == ITEM_TYPE.cailiao or itemType == ITEM_TYPE.zhenshen then
		return ResMgr.ITEM
	elseif itemType == ITEM_TYPE.zhuangbei or itemType == ITEM_TYPE.zhuangbei_suipian or itemType == ITEM_TYPE.wuxue or itemType == ITEM_TYPE.neigong_suipian or itemType == ITEM_TYPE.waigong_suipian then
		return ResMgr.EQUIP
	elseif itemType == ITEM_TYPE.chongwu or itemType == ITEM_TYPE.chongwu_suipian then
		return ResMgr.PET
	elseif itemType == ITEM_TYPE.shizhuang then
		return ResMgr.FASHION
	elseif itemType == ITEM_TYPE.cheats then
		return ResMgr.CHEATS
	elseif itemType == ITEM_TYPE.xinfa_suipian or itemType == ITEM_TYPE.juexue_suipian then
		return ResMgr.CHEATS_SUIPIAN
	else
		return ResMgr.ITEM
	end
end
--[[通过ResId来返回究竟这个resid 是道具 还是装备 仅限装备/道具表]]
function ResMgr.getItemTypeByResId(resId)
	local curType = data_item_item[resId].type
	if curType ~= nil then
		return ResMgr.getResType(curType)
	else
		show_tip_label("ResMgr.getItemTypeByResId 不存在resId")
	end
end

function ResMgr.getItemNameColorHex(resId)
	local quality = data_item_item[resId].quality
	local nameColor = NAME_COLOR_HEX[quality]
	return nameColor
end
function ResMgr.getItemNameColor(resId)
	local quality = data_item_item[resId].quality
	local nameColor = NAME_COLOR[quality]
	return nameColor
end
function ResMgr.refreshItemName(param)
	local label = param.label
	local resId = param.resId
	local name = data_item_item[resId].name
	local nameColor = ResMgr.getItemNameColor(resId)
	label:setString(name)
	label:setColor(nameColor)
end
function ResMgr.getHeroNameColorHexByClass(resId, class)
	local class = class or 1
	local cardData = ResMgr.getCardData(resId)
	local star = cardData.star[class] or 1
	if star > #QUALITY_COLOR_HEX then
		star = 1
	end
	local nameColor = QUALITY_COLOR_HEX[star]
	return nameColor
end
function ResMgr.getHeroNameColor(resId)
	local cardData = ResMgr.getCardData(resId)
	local star = cardData.star[1] or 1
	if star > #QUALITY_COLOR then
		star = 1
	end
	local nameColor = QUALITY_COLOR[star]
	return nameColor
end
function ResMgr.refreshHeroName(param)
	local label = param.label
	local resId = param.resId
	local cardData = ResMgr.getCardData(resId)
	local name = cardData.name
	label:setString(name)
	local nameColor = ResMgr.getHeroNameColor(resId)
	label:setColor(nameColor)
end
--[[
关卡boss的icon
name：图片的名字
coverType: icon 三种 类型
]]
function ResMgr.getLevelBossIcon(name, coverType)
	dump("boss icon: " .. name .. "," .. coverType)
	local path = "hero" .. "/icon/" .. name .. ".png"
	local iconSprite = display.newSprite(path)
	local coverName = ""
	if coverType == 1 then
		coverName = "#submap_icon_copper.png"
	elseif coverType == 2 then
		coverName = "#submap_icon_silver.png"
	elseif coverType == 3 then
		coverName = "#submap_icon_gold.png"
	end
	local coverSprite = display.newSprite(coverName)
	coverSprite:setPosition(iconSprite:getContentSize().width / 2, iconSprite:getContentSize().height / 2)
	iconSprite:addChild(coverSprite)
	return iconSprite
end
function ResMgr.delayFunc(delayTime, func, node)
	local runFuncNode = display.newNode()
	if node ~= nil then
		node:addChild(runFuncNode)
	else
		display.getRunningScene():addChild(runFuncNode)
	end
	local delayTime = CCDelayTime:create(delayTime)
	local func = CCCallFunc:create(function ()
		func()
	end)
	local removeNodeFunc = CCCallFunc:create(function ()
		runFuncNode:removeSelf()
	end)
	runFuncNode:runAction(transition.sequence({
	delayTime,
	func,
	removeNodeFunc
	}))
end
-- 背包类型
function ResMgr.getBagTypeDes(bagType)
	if bagType == BAG_TYPE.zhuangbei then
		return common:getLanguageString("@Equit")
	elseif bagType == BAG_TYPE.shizhuang then
		return common:getLanguageString("@shizhuang")
	elseif bagType == BAG_TYPE.zhuangbei_suipian then
		return common:getLanguageString("@zbsuipian")
	elseif bagType == BAG_TYPE.wuxue then
		return common:getLanguageString("@wuxue")
	elseif bagType == BAG_TYPE.canhun then
		return common:getLanguageString("@canhun")
	elseif bagType == BAG_TYPE.zhenqi then
		return common:getLanguageString("@zhenqi")
	elseif bagType == BAG_TYPE.daoju then
		return common:getLanguageString("@daoju")
	elseif bagType == BAG_TYPE.xiake then
		return common:getLanguageString("@Hero")
	elseif bagType == BAG_TYPE.neigong_suipian then
		return common:getLanguageString("@ngsuipian")
	elseif bagType == BAG_TYPE.waigong_suipian then
		return common:getLanguageString("@wgsuipian")
	elseif bagType == BAG_TYPE.chongwu then
		return common:getLanguageString("@pet")
	elseif bagType == BAG_TYPE.chongwu_suipian then
		return common:getLanguageString("@petSpirit")
	elseif bagType == BAG_TYPE.lipin then
		return common:getLanguageString("@Gift")
	elseif bagType == BAG_TYPE.cheats then
		return common:getLanguageString("@Cheats")
	else
		show_tip_label("")
		return common:getLanguageString("@wuclxbb")
	end
end

--以后可能会根据平台使用不同的音乐文件
function ResMgr.getSound(filename)
	return "sound/" .. filename .. ".mp3"
end

--SFX_NAME在GameConst中，列出所有音效的文件名--GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_shengli))
function ResMgr.getSFX(filename)
	return "sound/sfx/" .. filename .. ".mp3"
end

--[[
data：需要传入的数据，比如某张表，某个id的数据msg ：错误信息，输出哪张表，哪个id
example: ResMgr.showAlert(data_item_item[v],"数据表 data_item_item:"..v)
]]
function ResMgr.showAlert(data, msg)
	if (device.platform == "windows" or device.platform == "mac") and type(data) == "nil" then
		--CCMessageBox(common:getLanguageString("@cuowu"), msg)
		show_tip_label(msg);
	end
end

function ResMgr.refreshJobIcon(sprite, job)
	if job == 1 then
		sprite:setDisplayFrame(display.newSpriteFrame("hero_warrior_icon.png"))
	elseif job == 2 then
		sprite:setDisplayFrame(display.newSpriteFrame("hero_tank_icon.png"))
	elseif job == 3 then
		sprite:setDisplayFrame(display.newSpriteFrame("hero_magic_icon.png"))
	else
		dump(common:getLanguageString("@buczcl"))
	end
end

function ResMgr.shakeScr(param)
	--node是要震动那个节点
	--shakeId是需要调用的shake表中的哪个Id
	local node = param.node
	local shakeId = param.shakeId
	local width = param.width
	local height = param.height
	local orX = param.orX or node:getPositionX()
	local orY = param.orY or node:getPositionY()
	if shakeId ~= 0 then
		node:stopAllActions()
		local shakeData = data_shake_shake[shakeId]
		local start_time = shakeData.start_time / 1000 or 0.1
		local interval = shakeData.interval / 1000 or 0.1
		local arr_dir = shakeData.arr_dir or {}
		local startDelayAct = CCDelayTime:create(start_time)
		local shakeActions = {}
		shakeActions[#shakeActions + 1] = startDelayAct
		local node_width = width or node:getContentSize().width
		local node_height = height or node:getContentSize().height
		for i = 1, #arr_dir do
			do
				local offsetX = arr_dir[i][1] * node_width / 1000
				local offsetY = arr_dir[i][2] * node_height / 1000
				local setPosFuncAct = CCCallFunc:create(function ()
					node:setPosition(orX + offsetX, orY + offsetY)
				end)
				shakeActions[#shakeActions + 1] = setPosFuncAct
				if i ~= #arr_dir then
					local curDelayAct = CCDelayTime:create(interval)
					shakeActions[#shakeActions + 1] = curDelayAct
				else
				end
			end
		end
		local backToAct = CCCallFunc:create(function ()
			node:setPosition(orX, orY)
		end)
		shakeActions[#shakeActions + 1] = backToAct
		local delayEndTime = 0.08
		local delayEnd = CCDelayTime:create(delayEndTime)
		shakeActions[#shakeActions + 1] = delayEnd
		local seqAct = transition.sequence(shakeActions)
		node:runAction(seqAct)
	end
end

function ResMgr.getVipLevelData(vipLevel)
	local vipData
	for i, v in ipairs(data_viplevel_viplevel) do
		if v.vip == vipLevel then
			vipData = v
		end
	end
	ResMgr.showAlert(vipData, common:getLanguageString("@biaolimy") .. vipLevel .. common:getLanguageString("@deshuju"))
	return vipData
end

function ResMgr.showTextureCache(...)
	if GAME_DEBUG == true and device.platform == "ios" then
		printf("=========[CCTextureCache:sharedTextureCache()]==========")
		do
			local sharedTextureCache = CCTextureCache:sharedTextureCache()
			local function showMemoryUsage()
				printInfo(string.format("LUA VM MEMORY USED: %0.2f KB", collectgarbage("count")))
				sharedTextureCache:dumpCachedTextureInfo()
				printInfo("---------------------------------------------------")
			end
			showMemoryUsage()
		end
	end
end

function ResMgr.startTime()
	ResMgr.m_startTime = os.clock()
end

function ResMgr.endTime()
	show_tip_label(os.clock() - ResMgr.m_startTime)
	printf("==[test time]==" .. os.clock() - ResMgr.m_startTime)
	dump(os.clock() - ResMgr.m_startTime)
end

function ResMgr.checkSensitiveWord(wordStr)
	--检测是否含有敏感词汇
	local data_pingbi_pingbi = require("data.data_pingbi_pingbi")
	while string.find(wordStr, " ") do
		wordStr = string.gsub(wordStr, " ", "")
	end
	if string.len(wordStr) == 0 then
		return true
	end
	local contian
	for i, v in ipairs(data_pingbi_pingbi) do
		contian = string.find(wordStr, v.words)
		if contian ~= nil then
			dump(v.id)
			dump(v.words)
			dump(contian)
			break
		end
	end
	if contian ~= nil then
		return true
	else
		return false
	end
end

function ResMgr.getFashionData(id)
	return data_item_item[id]
end

function ResMgr.getFashionNameColor(id)
	return NAME_COLOR[data_item_item[id].quality]
end

function ResMgr.getCheatsNameColor(id)
	local quality = data_cheats_cheats[id].quality
	local nameColor = NAME_COLOR[quality]
	return nameColor
end

function ResMgr.setMetatableByKV(_table)
	setmetatable(_table, {__mode = "kv"})
end

ResMgr.highEndDevice = nil
function ResMgr.isHighEndDevice()
	if ResMgr.highEndDevice == nil then
		local isHigh = true
		if device.platform == "android" then
			local totalMemory
			if CSDKShell.GetDeviceInfo().totalMemory ~= nil then
				totalMemory = checkint(CSDKShell.GetDeviceInfo().totalMemory)
			end
			if totalMemory ~= nil and totalMemory < 1000 then
				isHigh = false
			elseif totalMemory == nil then
				local devices = require("data.data_android_device_android_device")
				local deviceType = CSDKShell.GetDeviceInfo().deviceType
				for k, v in pairs(devices) do
					if v.str_name == deviceType then
						isHigh = true
						break
					end
				end
			end
		end
		ResMgr.highEndDevice = isHigh
	end
	return ResMgr.highEndDevice
end


function ResMgr.addPromptRes()
	display.addSpriteFramesWithFile("ui/ui_toplayer.plist", "ui/ui_toplayer.pvr.ccz")
end

function ResMgr.replaceKeyLable(lable, temp, x, y, orderZ)
	local px, py = temp:getPosition()
	lable:setPosition(px + x, py + y)
	local z
	if orderZ ~= nil then
		z = orderZ
	else
		z = temp:getLocalZOrder()
	end
	lable:addTo(temp:getParent(), z)
end

function ResMgr.replaceKeyLableEx(lable, allNode, keyName, x, y, orderZ)
	local temp = allNode[keyName]
	local px, py = temp:getPosition()
	lable:setPosition(px + x, py + y)
	local z
	if orderZ ~= nil then
		z = orderZ
	else
		z = temp:getLocalZOrder()
	end
	lable:addTo(temp:getParent(), z)
	temp:removeSelf()
	allNode[keyName] = lable
end


function ResMgr.newUIButton(params)
	local image  = ui.newImageMenuItem(params)
	if params.handle then
		image:registerScriptTapHandler(params.handle)
	end
	local menu = ui.newMenu({image})
	return menu
end

function ResMgr.newNormalButton(params)
	local scaleBegan = params.scaleBegan or 1.0
	local scaleEnd = params.scaleEnd or 1.0
	local sprite =  display.newSprite(params.sprite)
	local button = cc.Layer:create()
	button = tolua.cast(button,"cc.Layer")
	button:ignoreAnchorPointForPosition(false)
	button:addChild(sprite)
	button:setTouchEnabled(true)
	local size = sprite:getContentSize()
	button:setContentSize(size)
	button.sprite = sprite
	sprite:setPosition(size.width/2, size.height/2)
	button:setScale(scaleEnd)
	button._handle =  params.handle
	--button._began = params.began
	button:registerScriptTouchHandler(function (event, x, y)
		if event == "began" then
			local bound = button:getCascadeBoundingBox()
			if bound:containsPoint(cc.p(x, y)) then
				--if button._began then
				--	button._began()
				--end
				button._bound = bound
				button:setScale(scaleBegan)
				return true
			end
		elseif event == "ended" then
			button:setScale(scaleEnd)
			if button._handle and button._bound:containsPoint(cc.p(x, y)) then
				button._handle()
			end
		elseif event == "cancelled" then
			button:setScale(scaleEnd)
		end
	end)
	
	button.replaceNormalButton = function (_, img)
		local sprite = display.newSprite(img)
		button.sprite:setDisplayFrame(sprite:getDisplayFrame())
		local size = button.sprite:getContentSize()
		button:setContentSize(size)
		sprite:setPosition(size.width/2, size.height/2)
	end
	
	button.alignNormalButton = function (_, align, x, y)
		if x and y then
			button:align(align, x, y)
		else
			button:align(align)
		end
	end
	
	button.setTouchHandle = function (_, handle)
		button._handle = handle
	end
	
	button.bgAddChild = function (_, node)
		button.sprite:addChild(node)
	end
	
	button.bgClear = function (_)
		button.sprite:removeAllChildren()
	end
	
	return button
end

function ResMgr.replaceNormalButton(button, img)
	local sprite = display.newSprite(img)
	button.sprite:setDisplayFrame(sprite:getDisplayFrame())
	local size = button.sprite:getContentSize()
	button:setContentSize(size)
	sprite:setPosition(size.width/2, size.height/2)
end

function ResMgr.alignNormalButton(button, align, x, y)
	if x and y then
		button:align(align, x, y)
	else
		button:align(align)
	end
end

return ResMgr