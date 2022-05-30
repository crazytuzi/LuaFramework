local data_battleskill_battleskill = require("data.data_battleskill_battleskill")
local data_atk_number_time_time = require("data.data_atk_number_time_time")
local data_jingyingfuben_jingyingfuben = require("data.data_jingyingfuben_jingyingfuben")
local data_huodongfuben_huodongfuben = require("data.data_huodongfuben_huodongfuben")
local data_zhenshenfuben_zhenshenfuben = require("data.data_zhenshenfuben_zhenshenfuben")
local data_battle_battle = require("data.data_battle_battle")
local data_effect_effect = require("data.data_effect_effect")
local data_card_move_card_move = require("data.data_card_move_card_move")
local data_card_rotation_card_rotation = require("data.data_card_rotation_card_rotation")
local data_special_special = require("data.data_special_special")
local data_buff_buff = require("data.data_buff_buff")
local data_atk_number_time_time = require("data.data_atk_number_time_time")
local data_talent_talent = require("data.data_talent_talent")
local data_huodong_huodong = require("data.data_huodong_huodong")
local data_shentong_shentong = require("data.data_shentong_shentong")
local data_drama_battle_battle = require("data.data_drama_battle_battle")
local data_item_nature = require("data.data_item_nature")
local data_union_battle_union_battle = require("data.data_union_battle_union_battle")
local data_union_fuben_union_fuben = require("data.data_union_fuben_union_fuben")
local data_card_card = require("data.data_card_card")
local NORMAL_DAMAGE_TIME = data_atk_number_time_time[1].pugongputongshanghai / 10
local NORMAL_DAMAGE_CRITICAL_TIME = data_atk_number_time_time[1].pugongbaojishanghai / 10
local NORMAL_DAMAGE_BLOCK_TIME = data_atk_number_time_time[1].pugonggedangshanghai / 10
local NORMAL_HEAL_TIME = data_atk_number_time_time[1].pugongjiaxueputong / 10
local NORMAL_HEAL_CRITICAL_TIME = data_atk_number_time_time[1].pugongbaojishanghai / 10
local RAGE_NORMAL_DAMAGE_TIME = data_atk_number_time_time[1].nuqiputongshanghai / 10
local RAGE_NORMAL_CRITICAL_DAMAGE_TIME = data_atk_number_time_time[1].nuqibaojishanghai / 10
local RAGE_BLOCK_TIME = data_atk_number_time_time[1].nuqigedangshanghai / 10
local RAGE_HEAL_TIME = data_atk_number_time_time[1].nuqijiaxueputong / 10
local RAGE_HEAL_CRITICAL_TIME = data_atk_number_time_time[1].nuqijiaxuebaoji / 10
local POISION_DAMAGE_TIME = data_atk_number_time_time[1].zhongdumeihuihediaoxue / 10
local BUFF_HEAL_TIME = data_atk_number_time_time[1].chixumeihuihezhiliao / 10
local NUM_SCALE = data_atk_number_time_time[1].num_scale / 10 or 1
local BACK_TIME = data_atk_number_time_time[1].back_time / 1000 or 0.3
local TAL_ANIM_TYPE = 1
local TAL_PROP_TYPE = 2
local BUFF_TYPE = 3
local SKILL_TYPE = 4
local BACK_TYPE = 5
local TAL_PROP_END_TYPE = 6
local SHOW_SUM_NUM = 1
local T_BATTLE_INIT = 1
local T_BATTLE_INBORN = 2
local T_BATTLE_SPELL = 3
local T_BATTLE_BUFF = 4
local T_BATTLE_END = 9
local DOWN_SIDE = 1
local UP_SIDE = 2
local RESULT_DOWN_WIN = 1
local RESULT_DOWN_LOSE = 2
local NORMAL_CARD_ZORDER = 100
local HELP_CARD_ZORDER = 120
local ANGER_ZORDER = 50
local BG_EFF_ZORDER = 75
local ACTIVE_CARD_ZORDER = 200
local EFFECT_ZORDER = 3000
local NUM_ZORDER = 10000
local FIT_ZORDER = 2000
local RAGE_HEAD_ZORDER = 1100
local NUM_TYPE_DAMAGE_NORMAL = 1
local FUNC_END = 0
local EFFECT_FUNC = 1
local CARD_MOVE_FUNC = 2
local CARE_ROTATE_FUNC = 3
local SPECIAL_FUNC = 4
local FIT_FUNC = 5
local BEFORE_ARISE = 1
local AFTER_ONE_CARD_ARISE = BEFORE_ARISE + 1
local BEFORE_WALK = AFTER_ONE_CARD_ARISE + 1
local AFTER_WALK = BEFORE_WALK + 1
local AFTER_ROUND = AFTER_WALK + 1
local AFTER_BATTLE = AFTER_ROUND + 1
local DODGE_TYPE = 1
local CRITICAL_TYPE = 2
local BLOCK_TYPE = 3
local HEAL_TYPE = 4
local DAMAGE_TYPE = 5
local SUB_HP = 1
local HEAL_HP = 2
local NO_HP = 3
local isSkipDrama = true
local BattleSpeedTipsShow = true
local IM_TYPE = {
none = 0,
wuli = 1,
fashu = 2
}

local BattleLayer = class("BattleLayer", function (param)
	return require("utility.ShadeLayer").new()
end)

function BattleLayer:playDie(card)
	card:playAct("die")
	card:setLife(0)
	local dieStartArma = self:getDieArma()
	dieStartArma:setPosition(card:getPosition())
	card:setVisible(false)
end

function BattleLayer:getDieArma()
	for k, v in pairs(self.dieArms) do
		if v.isUse == false then
			v:setVisible(true)
			v.isUse = true
			v:getAnimation():playWithIndex(0)
			return v
		end
	end
	local dieStartArma = ResMgr.createArma({
	resType = ResMgr.NORMAL_EFFECT,
	armaName = "siwang_qishou",
	finishFunc = function (arma)
		arma.isUse = false
		arma:setVisible(false)
	end,
	isRetain = true
	})
	dieStartArma:retain()
	dieStartArma:setScale(0.7)
	self.dieNode:addChild(dieStartArma, 100)
	self.dieArms[#self.dieArms + 1] = dieStartArma
	return dieStartArma
end

function BattleLayer:releaseUI()
	for k, v in pairs(self.dieArms) do
		v:removeSelf()
		v:release()
	end
	CCArmatureDataManager:sharedArmatureDataManager():removeArmatureFileInfo("ccs/effect/siwang_qishou/siwang_qishou.ExportJson")
	self.dieArms = {}
	for k, v in pairs(self.fontNodes) do
		for k1, v1 in pairs(v) do
			v1:removeSelf()
			v1:release()
		end
	end
	self.fontNodes = {
	{},
	{},
	{}
	}
	for k, v in pairs(self.numNodes) do
		for k1, v1 in pairs(v) do
			v1:removeSelf()
			v1:release()
		end
	end
	self.numNodes = {
	{},
	{},
	{}
	}
	self:clearEnemyCard()
	self:clearFriendCard()
end
function BattleLayer:ctor(param)
	dump("=========count1: ", collectgarbage("count"))
	self.dieArms = {}
	self.fontNodes = {
	{},
	{},
	{}
	}
	self.numNodes = {
	{},
	{},
	{}
	}
	ResMgr.addSpriteFramesWithFile("ui/ui_battle.plist", "ui/ui_battle.png")
	ResMgr.addSpriteFramesWithFile("ui/card_yun.plist", "ui/card_yun.png")
	self:setNodeEventEnabled(true)
	self:initUI()
	self.dieNode = display.newNode()
	self.shakeNode:addChild(self.dieNode)
	self.cPosX = self:getPositionX()
	self.cPosY = self:getPositionY()
	self.befCloud = display.newSprite("#qian.png")
	self.befCloud:setPosition(display.cx, display.cy)
	self.aftCloud = display.newSprite("#hou.png")
	self.aftCloud:setPosition(display.cx, display.cy)
	self.shakeNode:addChild(self.befCloud, -1000)
	self.shakeNode:addChild(self.aftCloud, -1000)
	local nameEff = ResMgr.createArma({
	resType = ResMgr.NORMAL_EFFECT,
	armaName = "nuqiji_zi",
	isRetain = false
	})
	nameEff:setPosition(display.cx, display.cy)
	self.shakeNode:addChild(nameEff, -1000)
	local nameBg = display.newSprite("#da_nuqi_bg.png")
	nameBg:setPosition(display.cx, display.cy)
	self.shakeNode:addChild(nameBg, -1000)
	local rageEff = ResMgr.createArma({
	resType = ResMgr.NORMAL_EFFECT,
	armaName = "dazhaoshifang",
	isRetain = false
	})
	rageEff:setPosition(display.cx, display.cy)
	self.shakeNode:addChild(rageEff, -1000)
end
function BattleLayer:playMusic()
	if self.playing == nil then
		self.playing = true
		if self.fubenType ~= WORLDBOSS_FUBEN and self.fubenType ~= GUILD_QLBOSS_FUBEN then
			GameAudio.playMusic("sound/boss1.mp3", true)
		end
	end
end

function resetParticleSystem(node)
	local nodetype = tolua.type(node)
	if nodetype == "cc.ParticleSystemQuad" then
		local ps = tolua.cast(node, "cc.ParticleSystemQuad")
		ps:setTotalParticles(2)
	else
		local children = node:getChildren()
		if children ~= nil then
			for i = 1, #children do
				resetParticleSystem(children[i])
			end
		end
	end
end

function BattleLayer:init(param)
	ResMgr.addSpriteFramesWithFile("ui/ui_battle.plist", "ui/ui_battle.png")
	ResMgr.addSpriteFramesWithFile("ui/card_yun.plist", "ui/card_yun.png")
	CCUserDefault:sharedUserDefault():setBoolForKey("isBattle", true)
	game.runningScene = self
	self.upDamage = 0
	self.playing = nil
	self.isInbattle = false
	self.maxCountTTF = "/30"
	self.musicIndex = 1
	self.musicName = "pve01"
	self.isInitTimeScale = false
	self.isPassed = param.isPassed
	self._isEnemyPreparedOk = false
	self.star = param.star or 0
	self.fubenType = param.fubenType
	self.fubenId = param.fubenId
	self.fubenData = {}
	ResMgr.setMetatableByKV(self.fubenData)
	self.isShowJumpBtn = true
	self.isShowCount = true
	if self.fubenType == NORMAL_FUBEN then
		self.fubenData = data_battle_battle[self.fubenId]
	elseif self.fubenType == JINGYING_FUBEN then
		self.fubenData = data_jingyingfuben_jingyingfuben[self.fubenId]
	elseif self.fubenType == HUODONG_FUBEN then
		self.fubenData = data_huodongfuben_huodongfuben[self.fubenId]
		if self.fubenId == 1 then
			self.maxCountTTF = "/5"
		end
	elseif self.fubenType == ZHENSHEN_FUBEN then
		self.fubenData = data_zhenshenfuben_zhenshenfuben[self.fubenId]
	elseif self.fubenType == DRAMA_FUBEN then
		self.isShowJumpBtn = false
		self.isShowCount = false
		self.fubenData = data_drama_battle_battle[1]
	elseif self.fubenType == ARENA_FUBEN then
		self.isShowJumpBtn = true
		self.fubenData.ccb_bg = data_huodong_huodong[2].ccb_bg
		self.fubenData.arr_show = data_huodong_huodong[2].arr_show or {1}
		self.fubenData.arise = data_huodong_huodong[2].arise or 2
		self.fubenData.bgm = data_huodong_huodong[2].bgm or "pvp1"
	elseif self.fubenType == LUNJIAN then
		self.isShowJumpBtn = true
		self.fubenData.ccb_bg = data_huodong_huodong[3].ccb_bg
		self.fubenData.arr_show = data_huodong_huodong[3].arr_show or {1}
		self.fubenData.arise = data_huodong_huodong[3].arise or 2
		self.fubenData.bgm = data_huodong_huodong[3].bgm or "pvp1"
	elseif self.fubenType == DUOBAO_FUBEN then
		self.isShowJumpBtn = true
		self.fubenData.ccb_bg = data_huodong_huodong[1].ccb_bg
		self.fubenData.arr_show = data_huodong_huodong[1].arr_show or {1}
		self.fubenData.bgm = data_huodong_huodong[1].bgm or "duobao"
		self.fubenData.arise = data_huodong_huodong[1].arise or 2
	elseif self.fubenType == WORLDBOSS_FUBEN then
		self.isShowJumpBtn = true
		self.isShowHpAndAnger = false
		self.fubenData.ccb_bg = data_huodong_huodong[5].ccb_bg
		self.fubenData.arr_show = data_huodong_huodong[5].arr_show or {1}
		self.fubenData.bgm = data_huodong_huodong[5].bgm or "duobao"
		self.fubenData.arise = data_huodong_huodong[5].arise or 2
	elseif self.fubenType == GUILD_QLBOSS_FUBEN then
		self.isShowJumpBtn = true
		self.isShowHpAndAnger = false
		self.fubenData.ccb_bg = data_union_battle_union_battle[1].ccb_bg
		self.fubenData.arr_show = data_union_battle_union_battle[1].arr_show or {1}
		self.fubenData.bgm = data_union_battle_union_battle[1].bgm or "duobao"
		self.fubenData.arise = data_union_battle_union_battle[1].arise or 2
	elseif self.fubenType == GUILD_FUBEN then
		self.isShowJumpBtn = true
		self.fubenData.ccb_bg = data_union_fuben_union_fuben[self.fubenId].ccb_bg
		self.fubenData.arr_show = data_union_fuben_union_fuben[self.fubenId].arr_show or {1}
		self.fubenData.arise = data_union_fuben_union_fuben[self.fubenId].arise or 2
		self.fubenData.bgm = data_union_fuben_union_fuben[self.fubenId].bgm or "pvp1"
		self.maxCountTTF = "/5"
	elseif self.fubenType == FRIEND_PK then
		self.fubenData.ccb_bg = data_huodong_huodong[2].ccb_bg
		self.fubenData.arr_show = data_huodong_huodong[2].arr_show or {1}
		self.fubenData.arise = data_huodong_huodong[2].arise or 2
		self.fubenData.bgm = data_huodong_huodong[2].bgm or "pvp1"
		self.isShowJumpBtn = false
	elseif self.fubenType == KUAFU_ZHAN then
		self.isShowJumpBtn = true
		self.fubenData.ccb_bg = data_huodong_huodong[2].ccb_bg
		self.fubenData.arr_show = data_huodong_huodong[2].arr_show or {1}
		self.fubenData.arise = data_huodong_huodong[2].arise or 2
		self.fubenData.bgm = data_huodong_huodong[2].bgm or "pvp1"
	elseif self.fubenType == GUILD_BATTLE_WALL_BOSS then
		self.isShowHpAndAnger = false
		self.fubenData.ccb_bg = data_union_battle_union_battle[1].ccb_bg
		self.fubenData.arr_show = data_union_battle_union_battle[1].arr_show or {1}
		self.fubenData.bgm = data_union_battle_union_battle[1].bgm or "duobao"
		self.fubenData.arise = data_union_battle_union_battle[1].arise or 2
	elseif self.fubenType == GUILD_BATTLE_WALL_FIGHT then
		self.fubenData.ccb_bg = data_union_battle_union_battle[1].ccb_bg
		self.fubenData.arr_show = data_union_battle_union_battle[1].arr_show or {1}
		self.fubenData.bgm = data_union_battle_union_battle[1].bgm or "duobao"
		self.fubenData.arise = data_union_battle_union_battle[1].arise or 2
	else
		ResMgr.debugBanner(common:getLanguageString("@NotExistTranscriptType"))
	end
	self.bgRate = self.fubenData.moveRate or 0
	local bgCCB = self.fubenData.ccb_bg
	local proxy = CCBProxy:create()
	if self.bg ~= nil then
		self.bg:removeFromParentAndCleanup(true)
	end
	self.bg = CCBuilderReaderLoad("battle_bg/" .. bgCCB .. ".ccbi", proxy, self.rootnode, self, cc.size(display.width, display.height))
	
	resetParticleSystem(self.bg)
	--dump(ccb)
	--dump("22222222222222222222222222222222")
	ResMgr.showAlert(self.bg, common:getLanguageString("@MapLack", bgCCB))
	self.moveBgNode:addChild(self.bg)
	self.moveBgNode:setPosition(cc.p(0, 0))
	self.bgHeight = 0
	for i = 1, 5 do
		local curBg = self.rootnode["bg_" .. i]
		if curBg == nil then
			break
		else
			self.bgHeight = self.bgHeight + curBg:getContentSize().height
		end
	end
	self.walkTypes = self.fubenData.arr_show
	self.ariseType = self.fubenData.arise or 2
	self.maxReqNum = #self.walkTypes
	self.curReqNum = 1
	local backNum = 0
	for i = 1, self.maxReqNum do
		if self.walkTypes[i] == 2 then
			backNum = backNum + 1
		end
	end
	local moveDistance = self.bgRate / 1000 * self.bgHeight
	self.bg:setPosition(display.cx, display.height - self.bgHeight + backNum * moveDistance)
	self.resultFunc = param.resultFunc
	self.reqFunc = param.reqFunc
	self.friendCard = {}
	self.enemyCard = {}
	ResMgr.setMetatableByKV(self.friendCard)
	ResMgr.setMetatableByKV(self.enemyCard)
	self.friendBuff = {
	{},
	{},
	{},
	{},
	{},
	{}
	}
	self.enemyBuff = {
	{},
	{},
	{},
	{},
	{},
	{}
	}
	ResMgr.setMetatableByKV(self.friendBuff)
	ResMgr.setMetatableByKV(self.enemyBuff)
	for i = 1, 6 do
		ResMgr.setMetatableByKV(self.friendBuff[i])
		ResMgr.setMetatableByKV(self.enemyBuff[i])
	end
	self.battleCount = 0
	self.battleCountTTF:setString(self.battleCount .. self.maxCountTTF)
	self.battleCountTTF:setPosition(8, -self.battleCountTTF:getContentSize().height / 2)
	self.roundName:setPosition(-80, -self.battleCountTTF:getContentSize().height / 2)
	self.countNode:setVisible(self.isShowCount)
	self.countLayer:setVisible(self.isShowCount)
	self.battleEffTable = {}
	self.befTalTable = {}
	self.beAtkTalTable = {}
	self.aftTalTable = {}
	ResMgr.setMetatableByKV(self.battleEffTable)
	ResMgr.setMetatableByKV(self.befTalTable)
	ResMgr.setMetatableByKV(self.beAtkTalTable)
	ResMgr.setMetatableByKV(self.aftTalTable)
	self:resetFontFlag()
	self.incomeData = param.battleData
	if self.fubenType ~= NORMAL_FUBEN then
		self:sendBattleReq()
	end
	self.damageCB = param.damageCB
	self.roundCB = param.roundCB
	self.friendNum = 0
	self.enemyNum = 0
	self:changeBattleCount(0)
end
function BattleLayer:onEnter()
	self:playMusic()
end
function BattleLayer:initUI()
	self.nodeNames = {
	"normal_effect_node",
	"beAtk_effect_node"
	}
	self.nodes = {}
	local contentSize = cc.size(display.width, display.height)
	for i = 1, #self.nodeNames do
		local curNode = display.newNode()
		curNode:setContentSize(contentSize)
		self.nodes[self.nodeNames[i]] = curNode
		if i == 1 then
			self:addChild(curNode)
		else
			self.nodes[self.nodeNames[i - 1]]:addChild(curNode)
		end
	end
	self.shakeNode = display.newNode()
	self.shakeNode:setContentSize(contentSize)
	self.nodes[self.nodeNames[#self.nodeNames]]:addChild(self.shakeNode)
	self.rootnode = {}
	ResMgr.setMetatableByKV(self.rootnode)
	self.bg = nil
	self.moveBgNode = display.newNode()
	self.shakeNode:addChild(self.moveBgNode)
	
	self.roundName = ui.newBMFontLabel({
	text = common:getLanguageString("@Round"),
	font = FONTS_NAME.font_battle_round,
	align = ui.TEXT_ALIGN_LEFT
	})
	self.battleCountTTF = ui.newBMFontLabel({
	text = "",
	font = FONTS_NAME.font_battle_round,
	align = ui.TEXT_ALIGN_LEFT
	})
	self.countNode = display.newNode()
	self.countNode:setPosition(display.width * 0.85, display.height)
	self.countNode:addChild(self.roundName)
	self.countNode:addChild(self.battleCountTTF, 101)
	self.countLayer = display.newColorLayer(cc.c4b(0, 0, 0, 170))
	self.countLayer:setContentSize(display.width, 30)
	self.countLayer:setAnchorPoint(cc.p(0.5, 1))
	self.countLayer:setPosition(0, display.height - 30)
	self:addChild(self.countLayer, NUM_ZORDER)
	self:addChild(self.countNode, NUM_ZORDER)
	self.maskLayer = display.newColorLayer(cc.c4b(0, 0, 0, 0))
	self.maskLayer:setVisible(false)
	self.maskLayer:setContentSize(cc.size(display.width * 2, display.height * 2))
	self.shakeNode:addChild(self.maskLayer, ANGER_ZORDER)
	self.fitMaskLayer = display.newColorLayer(cc.c4b(0, 0, 0, 0))
	self.fitMaskLayer:setVisible(false)
	self.fitMaskLayer:setOpacity(200)
	self.fitMaskLayer:setContentSize(cc.size(display.width * 2, display.height * 2))
	self.shakeNode:addChild(self.fitMaskLayer, FIT_ZORDER)
	self:initPos()
end

--请求战斗数据
function BattleLayer:sendBattleReq()
	self.isInbattle = false
	if self.incomeData == nil then
		self.reqFunc(self.curReqNum)
	else
		self:battleCallBack(self.incomeData)
	end
end

function BattleLayer:battleCallBack(data)
	self.isAbleJump = true
	if self.isInitTimeScale == false and self.fubenType ~= DRAMA_FUBEN then
		self.isInitTimeScale = true
		if self.fubenType ~= NORMAL_FUBEN then
			self:initTimeScale()
		end
	end
	self.totalData = data
	self.battleData = data["2"][1]
	local function initBattle()
		self.isPlayBat = true
		self:initBattle()
	end
	self:initJumpBtn()
	if self.curReqNum == 1 then
		initBattle()
	else
		ResMgr.delayFunc(0.5, initBattle)
	end
end

--跳过按钮
function BattleLayer:initJumpBtn()
	self.isFinal = false
	if self.isShowJumpBtn == true and self.jumpBtn == nil then
		self.jumpBtn = ResMgr.newNormalButton(	{
		scaleBegan = 0.9,
		sprite = "#battle_jump.png",
		handle = function()
			if self.isInbattle == true then
				self:skipBattle()
			else
				show_tip_label(common:getLanguageString("@NotSkip"))
			end
			if device.platform == "windows" or device.platform == "mac" then
				self.isInbattle = true
				self:skipBattle()
			end
		end
		})
		self.jumpBtn:align(display.RIGHT_BOTTOM)
		self.jumpBtn:setPosition(display.width, 0)
		self.shakeNode:addChild(self.jumpBtn, EFFECT_ZORDER + 100)
	end
end

function BattleLayer:skipBattle()
	if device.platform == "windows" or device.platform == "mac" then
		self:playSkipBattle()
		return
	end
	if self.isInbattle == true then
		if self.fubenType == NORMAL_FUBEN then
			if self.isPassed == true then
				self:playSkipBattle()
			else
				local bHasOpen, prompt = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.Tiaoguo_NormalFuben, game.player:getLevel(), game.player:getVip())
				if not bHasOpen then
					show_tip_label(prompt)
				else
					self:playSkipBattle()
				end
			end
			if device.platform == "windows" or device.platform == "mac" then
				self:playSkipBattle()
			end
		elseif self.fubenType == WORLDBOSS_FUBEN or self.fubenType == GUILD_QLBOSS_FUBEN then
			self:playSkipBattle()
		elseif self.fubenType == HUODONG_FUBEN then
			local bHasOpen = false
			local prompt = ""
			if self.fubenId == 1 then
				bHasOpen = true
			else
				bHasOpen, prompt = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.Tiaoguo_HuodongFuben, game.player:getLevel(), game.player:getVip())
			end
			if not bHasOpen then
				show_tip_label(prompt)
			else
				self:playSkipBattle()
			end
		elseif self.fubenType == ZHENSHEN_FUBEN then
			local bHasOpen, prompt = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.Tiaoguo_Zhenshen_FuBen, game.player:getLevel(), game.player:getVip())
			if not bHasOpen then
				show_tip_label(prompt)
			else
				self:playSkipBattle()
			end
		elseif self.fubenType == LUNJIAN then
			bHasOpen, prompt = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.Tiaoguo_HuashanLunjian, game.player:getLevel(), game.player:getVip())
			if not bHasOpen then
				show_tip_label(prompt)
			else
				self:playSkipBattle()
			end
		elseif self.fubenType == JINGYING_FUBEN then
			local bHasOpen, prompt = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.Tiaoguo_JingyingFuben, game.player:getLevel(), game.player:getVip())
			if not bHasOpen then
				show_tip_label(prompt)
			else
				self:playSkipBattle()
			end
		elseif self.fubenType == GUILD_FUBEN then
			local bHasOpen, prompt = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.Tiaoguo_guildFuben, game.player:getLevel(), game.player:getVip())
			if not bHasOpen then
				show_tip_label(prompt)
			else
				self:playSkipBattle()
			end
		elseif self.fubenType == KUAFU_ZHAN or self.fubenType == ARENA_FUBEN or self.fubenType == DUOBAO_FUBEN or self.fubenType == GUILD_BATTLE_WALL_BOSS or self.fubenType == GUILD_BATTLE_WALL_FIGHT then
			self:playSkipBattle()
		end
	else
		show_tip_label(common:getLanguageString("@ForbidToSkip"))
	end
end
function BattleLayer:playSkipBattle()
	self.isPlayBat = false
	local friendResultData = self.totalData["2"][1].f1
	local enemyResultData = self.totalData["2"][1].f2
	if self.isFinal == false then
		self.isFinal = true
		self.battleEffTable = {}
		ResMgr.setMetatableByKV(self.battleEffTable)
		local function playResult(fData, cardTable)
			for curCardId, curCard in pairs(cardTable) do
				for resultId, restLife in pairs(fData) do
					if tonumber(curCardId) == tonumber(resultId) then
						local enPos = self:getPosBySideAndID(curCard:getSideID(), curCard:getPosID())
						curCard:stopAllActions()
						curCard:setPosition(enPos)
						local maxLife = curCard:getLife()
						local hitType = 0
						if curCard:getLife() > 0 then
							self:createNum({
							numType = SUB_HP,
							damageType = hitType,
							isRanPos = 1,
							numValue = math.abs(maxLife - restLife),
							pos = cc.p(curCard:getPositionX(), curCard:getPositionY()),
							card = curCard
							})
							curCard:setLife(restLife)
							if restLife > 0 then
							else
								self:playDie(curCard)
							end
						else
							curCard:setVisible(false)
						end
						curCard:removeFunc()
					end
				end
			end
		end
		playResult(friendResultData, self.friendCard)
		playResult(enemyResultData, self.enemyCard)
		ResMgr.delayFunc(0.8, function ()
			self:battleResult()
		end,
		self)
	end
end
function BattleLayer:initBattle()
	local initData = self.totalData["2"][1].d[1]
	self.friendNum = 0
	self.enemyNum = 0
	self:changeBattleCount(0)
	local f1Data = initData.f1
	local f2Data = initData.f2
	--dump(f1Data)
	--dump(f2Data)
	if self.curReqNum == 1 then
		self:initMyselfGroupCard(f1Data)
	else
		self:clearEnemyCard()
	end
	self.enemyNum = #f2Data
	for i = 1, self.enemyNum do
		local cardID = f2Data[i].id
		local fashionId = f2Data[i].fashionId
		local cardLife = f2Data[i].life
		local cardPos = f2Data[i].pos
		local startAnger = f2Data[i].anger
		local cls = f2Data[i].cls
		local star = f2Data[i].star
		local scale = f2Data[i].scale or 1
		local maxLife = f2Data[i].initLife or cardLife
		local Card = require("game.Charactor.characterCard").new({
		isExist = true,
		id = cardID,
		fashionId = fashionId,
		posId = cardPos,
		anger = startAnger,
		side = UP_SIDE,
		isTouchAble = false,
		scale = scale,
		isShowHpAndAnger = self.isShowHpAndAnger,
		cls = cls,
		star = star,
		maxLife = maxLife,
		isMove = true
		})
		Card:setPosition(self.f2Pos[cardPos])
		local walkType = self.walkTypes[self.curReqNum]
		if walkType ~= 1 then
			Card:setVisible(false)
		end
		Card:setLife(cardLife)
		self.enemyCard[cardPos] = Card
		self.shakeNode:addChild(Card, NORMAL_CARD_ZORDER)
	end
	if self.curReqNum == 1 then
		self:enemyWalk()
	else
		self:cardWalk()
	end
	
	self:setTouchFunc(function (event)
		if event.name == "ended" then
			ResMgr.isShowCharName = not ResMgr.isShowCharName
			for k, v in pairs(self.friendCard) do
				v:changeNameState()
			end
			for k, v in pairs(self.enemyCard) do
				v:changeNameState()
			end
			if self.fubenType == DRAMA_FUBEN then
				self:initSkipDramaBtn()
			end
		end
	end)
	
end
function BattleLayer:initMyselfGroupCard(data)
	local isReady = false
	for k, v in pairs(self.friendCard) do
		isReady = true
		break
	end
	if not isReady then
		self:playMusic()
		if self.fubenType == NORMAL_FUBEN then
			local data_battle_data = data_battle_battle[self.fubenId]
			if data_battle_data.sbattle and data_battle_data.sbattle == 2 and self.star == 0 then
				for i = 1, #data_battle_data.arr_pos - 1 do
					local cardID = data_battle_data.arr_card[i]
					local cardLife = data_card_card[cardID].base[1]
					local cardPos = data_battle_data.arr_pos[i]
					local startAnger = 0
					local cls = 1
					local star = data_card_card[cardID].star[1]
					local scale = 1
					local maxLife = data_card_card[cardID].base[1]
					local Card = require("game.Charactor.characterCard").new({
					isExist = true,
					id = cardID,
					isTouchAble = false,
					cls = cls,
					star = star,
					posId = cardPos,
					side = DOWN_SIDE,
					maxLife = maxLife,
					anger = startAnger,
					scale = scale,
					isMove = true
					})
					Card:setPosition(self.f1Pos[cardPos])
					self.friendCard[cardPos] = Card
					self.friendNum = self.friendNum + 1
					Card:setVisible(false)
					Card:setLife(cardLife)
					self.shakeNode:addChild(Card, NORMAL_CARD_ZORDER)
				end
				local genid = game.player.m_gender
				local cardID = genid
				local cardLife = 100
				local cardPos = data_battle_data.arr_pos[#data_battle_data.arr_pos]
				local startAnger = 0
				local cls = game.player.m_class
				local star = m_star
				local scale = 1
				local maxLife = 100
				local Card = require("game.Charactor.characterCard").new({
				isExist = true,
				id = cardID,
				isTouchAble = false,
				cls = cls,
				star = star,
				posId = cardPos,
				side = DOWN_SIDE,
				maxLife = maxLife,
				anger = startAnger,
				scale = scale,
				isMove = true
				})
				Card:setPosition(self.f1Pos[cardPos])
				self.friendCard[cardPos] = Card
				self.friendNum = self.friendNum + 1
				Card:setVisible(false)
				Card:setLife(cardLife)
				self.shakeNode:addChild(Card, NORMAL_CARD_ZORDER)
				self:refreshMySelfCard(data)
			else
				local cradData = game.player.m_formation["1"]
				if cradData ~= nil then
					for i = 1, #cradData do
						local cardID = cradData[i].resId
						local fashionId = cradData[i].fashionId
						local cardLife = cradData[i].base[1]
						local cardPos = cradData[i].pos
						local startAnger = 0
						local cls = cradData[i].cls
						local star = cradData[i].star
						local scale = 1
						local maxLife = cradData[i].base[1]
						local Card = require("game.Charactor.characterCard").new({
						isExist = true,
						id = cardID,
						fashionId = fashionId,
						isTouchAble = false,
						cls = cls,
						star = star,
						posId = cardPos,
						side = DOWN_SIDE,
						maxLife = maxLife,
						anger = startAnger,
						scale = scale,
						isMove = true
						})
						Card:setPosition(self.f1Pos[cardPos])
						self.friendCard[cardPos] = Card
						self.friendNum = self.friendNum + 1
						Card:setVisible(false)
						Card:setLife(cardLife)
						self.shakeNode:addChild(Card, NORMAL_CARD_ZORDER)
					end
					self:refreshMySelfCard(data)
				end
			end
		else
			for i = 1, #data do
				local cardID = data[i].id
				local fashionId = data[i].fashionId
				local cardLife = data[i].life
				local cardPos = data[i].pos
				local startAnger = data[i].anger
				local cls = data[i].cls
				local star = data[i].star
				local scale = data[i].scale
				local maxLife = data[i].initLife or cardLife
				local Card = require("game.Charactor.characterCard").new({
				isExist = true,
				id = cardID,
				fashionId = fashionId,
				isTouchAble = false,
				cls = cls,
				star = star,
				posId = cardPos,
				side = DOWN_SIDE,
				maxLife = maxLife,
				anger = startAnger,
				scale = scale,
				isMove = true
				})
				Card:setPosition(self.f1Pos[cardPos])
				self.friendCard[cardPos] = Card
				self.friendNum = self.friendNum + 1
				Card:setVisible(false)
				Card:setLife(cardLife)
				self.shakeNode:addChild(Card, NORMAL_CARD_ZORDER)
			end
		end
		self:cardArise()
	elseif self.fubenType == NORMAL_FUBEN then
		self:refreshMySelfCard(data)
	end
end

function BattleLayer:refreshMySelfCard(data)
	dump(data)
	if data then
		for key, hero in pairs(data) do
			local friend = self.friendCard[hero.pos]
			dump(tolua.type(friend))
			friend:setStars(hero.anger)
			friend:updateCardScale(hero.scale)
			friend:setMaxLife(hero.initLife)
			friend:setLife(hero.life)
		end
	end
end

function BattleLayer:initSkipDramaBtn()
	if self.skipDramaBtn == nil then
		local btnSprite = display.newScale9Sprite("#jump_drama_btn.png")
		self.skipDramaBtn = CCControlButton:create("", FONTS_NAME.font_fzcy, 30)
		self.skipDramaBtn:setBackgroundSpriteForState(btnSprite, CCControlStateNormal)
		self.skipDramaBtn:setPreferredSize(cc.size(144, 50))
		self.skipDramaBtn:addHandleOfControlEvent(function ()
			self:skipDrama()
		end,
		CCControlEventTouchUpInside)
		self.skipDramaBtn:setAnchorPoint(cc.p(1, 0))
		self.skipDramaBtn:setPosition(display.width - 22, 60)
		self.shakeNode:addChild(self.skipDramaBtn, 10000000)
		self.skipVis = true
	else
		self.skipVis = not self.skipVis
		self.skipDramaBtn:setVisible(self.skipVis)
	end
end

function BattleLayer:skipDrama()
	DramaMgr.isSkipDrama = true
	self:battleResult()
end

function BattleLayer:dramaMachine(index, dramaTable, dramaEndFunc)
	if dramaTable ~= nil and index <= #dramaTable then
		local function skipFunc()
			self:dramaMachine(#dramaTable + 1, dramaTable, dramaEndFunc)
		end
		local function finFunc()
			self:dramaMachine(index + 1, dramaTable, dramaEndFunc)
		end
		local activeId = dramaTable[index]
		local dramaLayer = require("game.Tutorial.DramaLayer").new(activeId, finFunc, skipFunc)
		self:addChild(dramaLayer, DRAMA_ZORDER)
	else
		dramaEndFunc()
	end
end

function BattleLayer:playDrama(activeTime, dramaEndFunc)
	local isFirst = false
	if self.star == 0 then
		isFirst = true
	end
	local function getDramaByWave(raw_data, num)
		if raw_data == nil then
			return nil
		end
		for i = 1, #raw_data do
			if raw_data[i][1] == self.curReqNum then
				if DramaMgr.isSkipBattleDrama then
					raw_data[i][2] = {}
				end
				if type(raw_data[i][2]) == "number" then
					if raw_data[i][2] == num then
						return raw_data[i][3]
					end
				elseif type(raw_data[i][2]) == "table" then
					return raw_data[i][2]
				else
					ResMgr.debugBanner(common:getLanguageString("@NotExistType"))
				end
			end
		end
		return nil
	end
	local dramaTable
	if activeTime == BEFORE_ARISE then
		dramaTable = self.fubenData.arr_bef_arise
	elseif activeTime == AFTER_ONE_CARD_ARISE then
		dramaTable = getDramaByWave(self.fubenData.arr_aft_one_arise, self.arisePosNum)
	elseif activeTime == BEFORE_WALK then
		dramaTable = getDramaByWave(self.fubenData.arr_bef_walk, 0)
	elseif activeTime == AFTER_WALK then
		dramaTable = getDramaByWave(self.fubenData.arr_aft_walk, 0)
	elseif activeTime == AFTER_ROUND then
		dramaTable = getDramaByWave(self.fubenData.arr_aft_move, self.stateIndex)
	elseif activeTime == AFTER_BATTLE then
		dramaTable = getDramaByWave(self.fubenData.arr_aft_battle, 0)
	else
		GameAssert(false, common:getLanguageString("@NotExistPlot"))
	end
	local isExistDrama = false
	if dramaTable ~= nil and #dramaTable > 0 then
		isExistDrama = true
	end
	local isNormalFuben = false
	if self.fubenType == NORMAL_FUBEN or self.fubenType == DRAMA_FUBEN then
		isNormalFuben = true
	end
	if isNormalFuben and isFirst and isExistDrama then
		self:dramaMachine(1, dramaTable, dramaEndFunc)
	else
		dramaEndFunc()
	end
end
function BattleLayer:cardArise()
	local waitTime = 0.5
	local function startArise()
		local activeTime = BEFORE_WALK
		local function dramaEndFunc()
			self:cardWalk(true)
		end
		if self.ariseType == 1 then
			for k, v in pairs(self.friendCard) do
				v:setVisible(true)
			end
			self:runAction(transition.sequence({
			CCDelayTime:create(waitTime),
			CCCallFunc:create(function ()
				self:playDrama(activeTime, dramaEndFunc)
			end)
			}))
		elseif self.ariseType == 2 then
			do
				local delayTime = 0
				local count = 1
				local friendTable = {}
				for k, v in pairs(self.friendCard) do
					friendTable[#friendTable + 1] = v
				end
				local ariseNum = #friendTable
				self.arisePosNum = 0
				local function ariseMachine(num)
					if num > ariseNum then
						self:playDrama(BEFORE_WALK, dramaEndFunc)
					else
						do
							local curCard = friendTable[num]
							self.arisePosNum = curCard:getPosID()
							curCard:runAction(transition.sequence({
							CCCallFunc:create(function ()
								curCard:setVisible(true)
							end),
							CCCallFunc:create(function ()
								curCard:playAct("born")
							end),
							CCDelayTime:create(0.2),
							CCCallFunc:create(function ()
								local path = "sound/battlesfx/fight_down.mp3"
								GameAudio.playSound(path, false)
								self:shake(1)
							end),
							CCDelayTime:create(waitTime),
							CCCallFunc:create(function ()
								local function ariseEnd()
									return ariseMachine(num + 1)
								end
								self:playDrama(AFTER_ONE_CARD_ARISE, ariseEnd)
							end)
							}))
						end
					end
				end
				ariseMachine(1)
			end
		elseif self.ariseType == 3 then
			do
				local isRunWalkFunc = false
				local path = "sound/battlesfx/fight_shanguang.mp3"
				GameAudio.playSound(path, false)
				for k, v in pairs(self.friendCard) do
					do
						local chuxianEff = ResMgr.createArma({
						resType = ResMgr.UI_EFFECT,
						armaName = "kapaichuxian",
						finishFunc = function ()
						end,
						isRetain = false
						})
						chuxianEff:setPosition(v:getPositionX(), v:getPositionY())
						self.shakeNode:addChild(chuxianEff, NORMAL_CARD_ZORDER - 10)
						v:runAction(transition.sequence({
						CCDelayTime:create(0.1),
						CCCallFunc:create(function ()
							v:setScale(0.1)
							v:setVisible(true)
						end),
						CCScaleTo:create(0.2, 1),
						CCDelayTime:create(waitTime),
						CCCallFunc:create(function ()
							if isRunWalkFunc == false then
								isRunWalkFunc = true
								self:playDrama(activeTime, dramaEndFunc)
							end
						end)
						}))
					end
				end
			end
		elseif self.ariseType == 4 then
			self:cardCasinoArise({
			nextFunc = function ()
				self:playDrama(activeTime, dramaEndFunc)
			end
			})
		else
			ResMgr.debugBanner(common:getLanguageString("@CardError", self.ariseType))
		end
	end
	self:playDrama(BEFORE_ARISE, startArise)
end
function BattleLayer:cardWalk(isSkip)
	isSkip = isSkip or false
	local moveDistance = self.bgRate / 1000 * self.bgHeight
	local moveTime = 2
	local delayTime = 1
	local isRunBattleFunc = false
	local waitTime = 2
	local walkDonwNum = 0
	local walkUpNum = 0
	local function playWalkUpSound()
		walkUpNum = walkUpNum + 1
		if walkUpNum % #self.friendCard == 0 then
			GameAudio.playSound("sound/skill/walk01.mp3", false)
		end
	end
	local walkIndex = 0
	local function playWalkDownSound()
		walkDonwNum = walkDonwNum + 1
		if walkDonwNum % #self.friendCard == 0 then
			walkIndex = walkIndex + 1
			if walkIndex == 6 then
				walkIndex = 1
			end
			local path = "sound/skill/walk0" .. tostring(walkIndex) .. ".mp3"
			GameAudio.playSound(path, false)
		end
	end
	local walkType = self.walkTypes[self.curReqNum] or 1
	if self.fubenType == JINGYING_FUBEN or self.fubenType == HUODONG_FUBEN then
		for k, v in pairs(self.friendCard) do
			if 0 < v:getLife() then
				v:setVisible(true)
				v:setFullLife()
				v:removeAllBuff()
			else
				v:setVisible(false)
			end
		end
	end
	local function dramaAftWalk()
		local function finDrama()
			self:playBattle()
		end
		local scheduler = require("framework.scheduler")
		local checkIsBattle
		checkIsBattle = scheduler.scheduleGlobal(function ()
			if self._isEnemyPreparedOk then
				self:playDrama(AFTER_WALK, finDrama)
				scheduler.unscheduleGlobal(checkIsBattle)
			end
		end,
		0.01)
	end
	if walkType == 1 then
		dramaAftWalk()
	elseif walkType == 2 then
		if self.curReqNum ~= 1 then
			for k, v in pairs(self.enemyCard) do
				v:setPosition(v:getPositionX(), v:getPositionY() + moveDistance)
				v:setVisible(true)
				v:runAction(CCMoveBy:create(moveTime, cc.p(0, -moveDistance)))
			end
		end
		for k, v in pairs(self.friendCard) do
			v:playWalk(playWalkDownSound)
		end
		self.moveBgNode:runAction(transition.sequence({
		CCMoveBy:create(moveTime, cc.p(0, -moveDistance)),
		CCCallFunc:create(function ()
			for k, v in pairs(self.friendCard) do
				v:playAct("stop")
			end
			local path = "sound/skill/walk05.mp3"
			GameAudio.playSound(path, false)
			for k, v in pairs(self.enemyCard) do
				v:playAct("stop")
			end
		end),
		CCDelayTime:create(delayTime),
		CCCallFunc:create(function ()
			dramaAftWalk()
		end)
		}))
	elseif walkType == 3 then
		if isSkip and isSkip == false then
			for k, v in pairs(self.enemyCard) do
				v:setPosition(v:getPositionX(), v:getPositionY() + moveDistance)
				v:setVisible(true)
				v:playWalk(playWalkDownSound)
				v:runAction(transition.sequence({
				CCMoveBy:create(moveTime, cc.p(0, -moveDistance)),
				CCCallFunc:create(function ()
					v:playAct("stop")
				end),
				CCDelayTime:create(delayTime),
				CCCallFunc:create(function ()
					if isRunBattleFunc == false then
						isRunBattleFunc = true
						dramaAftWalk()
					end
				end)
				}))
			end
		else
			dramaAftWalk()
		end
	elseif walkType == 4 then
		if isSkip and isSkip == false then
			for k, v in pairs(self.enemyCard) do
				do
					local chuxianEff = ResMgr.createArma({
					resType = ResMgr.UI_EFFECT,
					armaName = "kapaichuxian",
					finishFunc = function ()
					end,
					isRetain = false
					})
					chuxianEff:setPosition(v:getPositionX(), v:getPositionY())
					self.shakeNode:addChild(chuxianEff, NORMAL_CARD_ZORDER - 10)
					v:runAction(transition.sequence({
					CCDelayTime:create(0.1),
					CCCallFunc:create(function ()
						v:setScale(0.1)
						v:setVisible(true)
					end),
					CCScaleTo:create(0.2, 1),
					CCDelayTime:create(0.5),
					CCCallFunc:create(function ()
						if isRunBattleFunc == false then
							isRunBattleFunc = true
							dramaAftWalk()
						end
					end)
					}))
				end
			end
		else
			dramaAftWalk()
		end
	else
		ResMgr.debugBanner(common:getLanguageString("@RunWayError"))
	end
end
function BattleLayer:enemyWalk()
	local moveDistance = self.bgRate / 1000 * self.bgHeight
	local moveTime = 2
	local delayTime = 1
	local waitTime = 2
	local walkDonwNum = 0
	local walkUpNum = 0
	local function playWalkUpSound()
		walkUpNum = walkUpNum + 1
		if walkUpNum % #self.friendCard == 0 then
			local path = "sound/skill/walk01.mp3"
			GameAudio.playSound(path, false)
		end
	end
	local walkIndex = 0
	local function playWalkDownSound()
		walkDonwNum = walkDonwNum + 1
		if walkDonwNum % #self.friendCard == 0 then
			walkIndex = walkIndex + 1
			if walkIndex == 6 then
				walkIndex = 1
			end
			local path = "sound/skill/" .. "walk0" .. tostring(walkIndex) .. ".mp3"
			GameAudio.playSound(path, false)
		end
	end
	local walkType = self.walkTypes[self.curReqNum] or 1
	if self.fubenType == JINGYING_FUBEN or self.fubenType == HUODONG_FUBEN then
		for k, v in pairs(self.friendCard) do
			if 0 < v:getLife() then
				v:setVisible(true)
				v:setFullLife()
				v:removeAllBuff()
			else
				v:setVisible(false)
			end
		end
	end
	local function dramaAftWalk()
		self:performWithDelay(function ()
			self._isEnemyPreparedOk = true
		end,
		0.5)
	end
	if walkType == 1 then
		dramaAftWalk()
	elseif walkType == 2 then
		for k, v in pairs(self.enemyCard) do
			v:setPosition(v:getPositionX(), v:getPositionY() + moveDistance)
			v:setVisible(false)
			v:runAction(transition.sequence({
			CCMoveBy:create(moveTime, cc.p(0, -moveDistance)),
			CCCallFunc:create(function ()
				v:playAct("stop")
			end),
			CCDelayTime:create(delayTime),
			CCCallFunc:create(function ()
				dramaAftWalk()
				v:setVisible(true)
			end)
			}))
		end
	elseif walkType == 3 then
		for k, v in pairs(self.enemyCard) do
			v:setPosition(v:getPositionX(), v:getPositionY() + moveDistance)
			v:setVisible(true)
			v:playWalk(playWalkDownSound)
			v:runAction(transition.sequence({
			CCMoveBy:create(moveTime, cc.p(0, -moveDistance)),
			CCCallFunc:create(function ()
				v:playAct("stop")
			end),
			CCDelayTime:create(delayTime),
			CCCallFunc:create(function ()
				dramaAftWalk()
			end)
			}))
		end
	elseif walkType == 4 then
		for k, v in pairs(self.enemyCard) do
			do
				local chuxianEff = ResMgr.createArma({
				resType = ResMgr.UI_EFFECT,
				armaName = "kapaichuxian",
				finishFunc = function ()
				end,
				isRetain = false
				})
				chuxianEff:setPosition(v:getPositionX(), v:getPositionY())
				self.shakeNode:addChild(chuxianEff, NORMAL_CARD_ZORDER - 10)
				v:runAction(transition.sequence({
				CCDelayTime:create(0.1),
				CCCallFunc:create(function ()
					v:setScale(0.1)
					v:setVisible(true)
				end),
				CCScaleTo:create(0.2, 1),
				CCDelayTime:create(0.5),
				CCCallFunc:create(function ()
					dramaAftWalk()
				end)
				}))
			end
		end
	else
		ResMgr.debugBanner(common:getLanguageString("@RunWayError"))
	end
end

function BattleLayer:onExit()
	self:releaseUI()
	if TutoMgr.getPlotNum() == 0 then
		TutoMgr.setServerNum({setNum = 30})
	end
	CCUserDefault:sharedUserDefault():setBoolForKey("isBattle", false)
	DramaMgr.isSkipBattleDrama = false
	CCTextureCache:sharedTextureCache():removeUnusedTextures()
	ResMgr.ReleaseUIArmature("kapaichuxian")
	CCArmatureDataManager:purge()
	count = 0
	local function countNode(node)
		local children = node:getChildren()
		if children ~= nil then
			count = count + #children
			for i = 1, #children do
				countNode(children[i])
			end
		end
	end
	countNode(self)
	dump("node:" .. count)
	collectgarbage("collect")
end

function BattleLayer:getTalData(rawTal)
	local befTals = {}
	local beAtkTals = {}
	local aftTals = {}
	local function addTalentData(show, talentData)
		if show == 0 then
		elseif show == 1 then
			befTals[#befTals + 1] = talentData
		elseif show == 3 then
			beAtkTals[#beAtkTals + 1] = talentData
		elseif show == 2 then
			aftTals[#aftTals + 1] = talentData
		else
			ResMgr.debugBanner(common:getLanguageString("@NotExistGift", show))
		end
	end
	if rawTal ~= nil and #rawTal > 0 then
		for i = 1, #rawTal do
			local talentId = rawTal[i].sid
			local talentStaticData = data_talent_talent[talentId]
			local show = talentStaticData.show
			addTalentData(show, rawTal[i])
		end
	end
	return befTals, beAtkTals, aftTals
end

function BattleLayer:playBattle()
	if self.battleData == nil then
		return
	end
	self.isInbattle = true
	self.stateIndex = 1
	self:stateMachine()
end

function BattleLayer:stateMachine()
	if self.isFinal == false then
		self.stateIndex = self.stateIndex + 1
		local atkData = self.battleData.d[self.stateIndex]
		local actCard = self:getCardByData(atkData)
		if actCard ~= nil then
			actCard:setZOrder(ACTIVE_CARD_ZORDER)
		end
		self:changeBattleCount(atkData.n)
		self.roundNum = atkData.n
		self.aftTalTable = {}
		self.beAtkTalTable = {}
		self.befTalTable = {}
		ResMgr.setMetatableByKV(self.aftTalTable)
		ResMgr.setMetatableByKV(self.beAtkTalTable)
		ResMgr.setMetatableByKV(self.befTalTable)
		if atkData.t == T_BATTLE_SPELL then --放怒气技能，或者攻击技能
			
			
			
			
			self.actTable = {}
			ResMgr.setMetatableByKV(self.actTable)
			self:unpackSkillData(self.actTable, atkData)
			return self:atkDataMachine(1, self.actTable)
		elseif atkData.t == T_BATTLE_BUFF then --战斗BUFF
			self.actTable = {}
			ResMgr.setMetatableByKV(self.actTable)
			self:unpackBuffData(self.actTable, atkData)
			--dump("2222222222222222222222222222222222222222")
			return self:atkDataMachine(1, self.actTable)
		elseif atkData.t == T_BATTLE_END then --战斗结算
			return self:battleResult()
		end
	end
end

function BattleLayer:initBuff(buffData)
	local buffSide = buffData.s
	local buffPos = buffData.p
	local buffId = buffData.b
	local isEff = buffData.eff --1 生效 2 移除
	local buffTypes = buffData.k
	local buffValues = buffData.v
	local restLife = buffData.l --buff 触发后剩余血量 是否死亡
	local fileName = data_buff_buff[buffId].special
	local isShowNum = false
	local showTime = 0 --buff显示时间，如果产生数值 则直接进入下一轮
	
	
	
	
	local curType = data_buff_buff[buffId].effect
	if curType == 3 or curType == 4 or curType == 5 or curType == 16 or curType == 17 then
		isShowNum = true
		showTime = 0.1
	end
	local function delyEff()
		local existBuffs
		if buffSide == UP_SIDE then
			existBuffs = self.enemyBuff[buffPos]
		else
			existBuffs = self.friendBuff[buffPos]
		end
		local beAtkCard = self:getCardBySideId(buffSide, buffPos)
		local numT = SUB_HP
		local actName = "stop"
		local curType = data_buff_buff[buffId].effect
		if curType == 4 or curType == 5 or curType == 16 or curType == 17 then
			actName = "hit"
		end
		if #buffValues > 0 then
			if 0 <= buffValues[1] then
				numT = HEAL_HP
			else
				numT = SUB_HP
			end
			local hitType = 0
			if isShowNum then
				self:createNum({
				numType = numT,
				damageType = hitType,
				isRanPos = 1,
				numValue = math.abs(buffValues[1]),
				pos = cc.p(beAtkCard:getPositionX(), beAtkCard:getPositionY()),
				card = beAtkCard
				})
			end
		end
		if isEff == 1 then
			ResMgr.debugBanner("buff生效啦！ buffId是" .. buffId)
			beAtkCard:playAct(actName)
		else
			local fileName = data_buff_buff[buffId].special
			beAtkCard:removeBuff(fileName)
		end
	end
	local runFuncNode = display.newNode()
	self.shakeNode:addChild(runFuncNode)
	local befDelay = CCDelayTime:create(showTime)
	
	local befFunc = CCCallFunc:create(function ()
		delyEff()
	end)
	
	local delayTime = CCDelayTime:create(showTime)
	local func = CCCallFunc:create(function ()
		local card = self:getCardBySideId(buffSide, buffPos)
		card:setLife(restLife)
		if restLife == 0 then
			self:playDie(card)
			card:setVisible(false)
		end
		self:nextRound()
	end)
	local removeNodeFunc = CCCallFunc:create(function ()
		runFuncNode:removeSelf()
	end)
	runFuncNode:runAction(transition.sequence({
	befDelay,
	befFunc,
	delayTime,
	func,
	removeNodeFunc
	}))
end

function BattleLayer:unpackAtkData(atkData)
	local targetResults = atkData.tr
	local fightBack = atkData.fb
	local skillId = atkData.skill
	local skillStaticData = data_battleskill_battleskill[skillId]
	if skillStaticData == nil then
		ResMgr.debugBanner("技能数据为空 ID为" .. skillId)
	end
	local skillName = skillStaticData.name
	local rawTal = atkData.tal
	local skillBuffs = atkData.buff
	local actAnger = atkData.a
	local actCard = self:getCardByData(atkData)
	local ta = atkData.ta
	return targetResults, fightBack, skillId, skillStaticData, skillName, rawTal, skillBuffs, actAnger, actCard, ta
end

function BattleLayer:atkDataMachine(index, actTable)
	if self.isPlayBat ~= true then
		return
	end
	local curAtkData = actTable[index]
	if curAtkData ~= nil then
		local curType = curAtkData.type
		local curData = curAtkData.data
		if curData ~= nil then
			local tr = curData.tr
			self:updateDmageNum(UP_SIDE, self.upDamage)
			self.upDamage = 0
			if tr ~= nil then
				for i = 1, #tr do
					if tr[i].s == 2 then
						self.upDamage = self.upDamage + tr[i].d
					end
				end
			end
		end
		if curType == TAL_ANIM_TYPE then
			return self:cardPlayTal(curData, index, actTable)
		elseif curType == TAL_PROP_TYPE then
			return self:cardPlayProp(curData, index, actTable)
		elseif curType == TAL_PROP_END_TYPE then
			return self:atkDataMachine(index + 1, actTable)
		elseif curType == INIT_BUFF_TYPE then
			return self:initBuff(curData, index, actTable)
		elseif curType == BUFF_TYPE then
			return self:cardPlayBuff(curData, index, actTable)
		elseif curType == SKILL_TYPE then
			return self:cardPlaySkill(curData, index, actTable)
		elseif curType == BACK_TYPE then
			return self:nextRound()
		end
	else
		return self:nextRound()
	end
end
function BattleLayer:cardPlayTal(curData, index, actTable)
	local card = self:getCardByData(curData)
	card:setZOrder(ACTIVE_CARD_ZORDER)
	local talId = curData.sid
	return self:createTalName(card, talId, function ()
		return self:atkDataMachine(index + 1, actTable)
	end)
end

function BattleLayer:cardPlayProp(curData, index, actTable)
	return self:changeProps(curData, card, function ()
		return self:atkDataMachine(index + 1, actTable)
	end)
end

function BattleLayer:cardPlayBuff(curData, index, actTable)
	self:createBuff(curData)
	return self:atkDataMachine(index + 1, actTable)
end

function BattleLayer:cardPlaySkill(curData, index, actTable)
	return self:playSkill(curData, function ()
		return self:atkDataMachine(index + 1, actTable)
	end)
end

function BattleLayer:unpackTalData(actTable, talTable)
	for index = 1, #talTable do
		local talData = talTable[index]
		local curTalData = {}
		curTalData.type = TAL_ANIM_TYPE
		curTalData.data = talData
		actTable[#actTable + 1] = curTalData
		for i = 1, #talData.prop do
			local curProp = {}
			curProp.type = TAL_PROP_TYPE
			curProp.data = talData.prop[i]
			actTable[#actTable + 1] = curProp
			if i == #talData.prop then
				local curPropEnd = {}
				curPropEnd.type = TAL_PROP_END_TYPE
				actTable[#actTable + 1] = curPropEnd
			end
		end
		for i = 1, #talData.skill do
			local skillData = talData.skill[i]
			self:unpackSkillData(actTable, skillData)
		end
		if talData.buff ~= nil then
			self:unpackBuff(actTable, talData.buff)
		end
	end
end

function BattleLayer:unpackBuff(actTable, buffData)
	for i = 1, #buffData do
		local curBuff = {}
		curBuff.type = BUFF_TYPE
		curBuff.data = buffData[i]
		actTable[#actTable + 1] = curBuff
	end
end

function BattleLayer:unpackFightBackData(actTable, fbs)
	for index = 1, #fbs do
		self:unpackSkillData(actTable, fbs[index])
	end
end

--解析buff数据
function BattleLayer:unpackBuffData(actTable, buffData)
	--dump("BattleLayer:unpackBuffData:" .. buffData.b)
	--dump(buffData)
	local buffId = buffData.b
	local curType = data_buff_buff[buffId].effect
	if curType == 16 then
		local anger = 0
		if buffData.k  ~= nil then
			for i = 1, #buffData.k do
				if buffData.k[i] == 79 then
					anger = buffData.v[i]
				end
			end
		end
		if anger < 0 then
			local curData = {}
			curData.idx = 79
			curData.val = anger
			curData.s = buffData.s
			curData.p = buffData.p
			local curProp = {}
			curProp.type = TAL_PROP_TYPE
			curProp.data = curData
			actTable[#actTable + 1] = curProp
		end
	end
	
	local curBuff = {}
	curBuff.type = INIT_BUFF_TYPE
	curBuff.data = buffData
	actTable[#actTable + 1] = curBuff
end

function BattleLayer:unpackSkillData(actTable, skillData)
	local befTals, beAtkTals, aftTals = self:getTalData(skillData.tal)
	if befTals ~= nil then
		self:unpackTalData(actTable, befTals)
	end
	local curSkill = {}
	curSkill.type = SKILL_TYPE
	curSkill.data = skillData
	actTable[#actTable + 1] = curSkill
	if skillData.buff ~= nil and #skillData.buff > 0 then
		self:unpackBuff(actTable, skillData.buff)
	end
	if beAtkTals ~= nil then
		self:unpackTalData(actTable, beAtkTals)
	end
	if skillData.fb ~= nil then
		self:unpackFightBackData(actTable, skillData.fb)
	end
	if aftTals ~= nil then
		self:unpackTalData(actTable, aftTals)
	end
end

function BattleLayer:playRage(atkData, fontScale, specialData)
	local tr, fightBack, skillId, skillStaticData, skillName, rawTal, skillBuffs, actAnger, actCard = self:unpackAtkData(atkData)
	local curScale = fontScale or 1.9
	if actCard:getSideID() == DOWN_SIDE then
		local card = ResMgr.getCardData(actCard.cardResId)
		if card.battleSound then
			ResMgr.playSfx(card.battleSound, ResMgr.PERSION_SFX)
		end
		self:fade(0.1, 1)
		actCard:playShow(specialData)
		self:playSound("skill_nuqidonghua", false)
		local rageNamePos = self:getEffPosByID(5, actCard)[1]
		rageNamePos.y = rageNamePos.y + display.height * data_atk_number_time_time[1].anger_posy / 1000
		local nameEff = ResMgr.createArma({
		resType = ResMgr.NORMAL_EFFECT,
		armaName = "nuqiji_zi",
		isRetain = false
		})
		nameEff:setPosition(rageNamePos)
		display.getRunningScene():addChild(nameEff, EFFECT_ZORDER + 10)
		local nameStr = skillStaticData.rageSpriteName
		if nameStr ~= nil then
			local namePath = "image_name/rage_image/" .. nameStr .. ".png"
			local nameSprite = display.newSprite(namePath)
			local nameBg = display.newSprite("#da_nuqi_bg.png")
			nameBg:setPosition(nameSprite:getContentSize().width / 2 + 30, nameSprite:getContentSize().height / 2)
			nameSprite:addChild(nameBg, -1)
			nameSprite:setPosition(rageNamePos)
			nameSprite:setVisible(false)
			display.getRunningScene():addChild(nameSprite, EFFECT_ZORDER + 100)
			local bigStart = CCCallFunc:create(function ()
				nameSprite:setScale(4)
				nameSprite:setVisible(true)
			end)
			local small = CCScaleTo:create(0.1, curScale)
			local delay = CCDelayTime:create(0.8)
			local fadeOut = CCFadeOut:create(0.2)
			local fadeSpawn = CCSpawn:createWithTwoActions(fadeOut, CCMoveBy:create(0.2, cc.p(-600, 0)))
			local rev = CCCallFunc:create(function ()
				nameSprite:removeSelf()
			end)
			nameSprite:runAction(transition.sequence({
			bigStart,
			small,
			delay,
			fadeSpawn,
			rev
			}))
		end
		local rageEff = ResMgr.createArma({
		resType = ResMgr.NORMAL_EFFECT,
		armaName = "dazhaoshifang",
		isRetain = false
		})
		actCard:addChild(rageEff)
	end
end
function BattleLayer:playSkill(atkData, endFunc)
	local skillId = atkData.skill
	local tr = atkData.tr
	print("----------------------->技能ID: " ..skillId)
	local skillStaticData = data_battleskill_battleskill[skillId]
	local startFuncs = skillStaticData.arr_funcs
	if ResMgr.isHighEndDevice() == false then
		startFuncs = skillStaticData.arr_funcs2
	end
	for i = 1, #startFuncs do
		self:runFunc(startFuncs[i], atkData, endFunc)
	end
end
function BattleLayer:createTalName(card, talId, endFunc)
	local image_name = "image_name/talent_image/" .. data_talent_talent[talId].image_name .. ".png"
	local talData = data_shentong_shentong[data_talent_talent[talId].shentong]
	local stType = talData.type
	local image = {
	"bg_atk",
	"bg_heal",
	"bg_help",
	"bg_def"
	}
	local image_bg_name = "image_name/talent_image/" .. image[stType] .. ".png"
	local tal_bg = display.newSprite(image_bg_name)
	local tal_name = display.newSprite(image_name)
	tal_name:setPosition(tal_bg:getContentSize().width / 2, tal_bg:getContentSize().height / 2)
	tal_bg:addChild(tal_name)
	tal_bg:setPosition(0, -card:getContentSize().height / 2)
	local isAct = data_talent_talent[talId].isAct
	if isAct ~= nil and isAct ~= 0 then
		card:playAct("shentong", nil, endFunc, 1.3)
		local path = "sound/battlesfx/shentongfanzhuan.mp3"
		GameAudio.playSound(path, false)
	else
		endFunc()
	end
	local function effFunc()
		local shentongEff = ResMgr.createArma({
		resType = ResMgr.NORMAL_EFFECT,
		armaName = "shentongbaoqi",
		isRetain = false
		})
		shentongEff:setPosition(card:getPosition())
		self.shakeNode:addChild(shentongEff, EFFECT_ZORDER)
	end
	local scaleFunc = CCCallFunc:create(function ()
		tal_bg:setScaleY(0.1)
	end)
	local nodeScale = CCScaleTo:create(0.2, 1)
	local nodeDelay = CCDelayTime:create(1.3)
	local scaleSmaller = CCScaleTo:create(0.2, 0.1)
	local nodeRev = CCCallFunc:create(function ()
		tal_bg:removeSelf()
	end)
	tal_bg:runAction(transition.sequence({
	scaleFunc,
	nodeScale,
	nodeDelay,
	scaleSmaller,
	nodeRev
	}))
	card:addChild(tal_bg)
end

--属性值改变




function BattleLayer:changeProps(curData, card, talEndFunc)
	local propType = curData.idx
	local propValue = curData.val
	local propSide = curData.s
	local propPos = curData.p
	local propEndLife = curData.l
	local card = self:getCardBySideId(propSide, propPos)
	card:setZOrder(ACTIVE_CARD_ZORDER)
	local fontNode = display.newNode()
	local propFont, propNum
	local isAdd = false
	local healEff
	local natureData = data_item_nature[propType]
	if natureData ~= nil then
		do
			local isShowNum = natureData.isShowNum
			local isShowFont = natureData.isShowFont
			function getPropFont()
				local tempFont
				local pic_name = natureData.prop_pic
				if pic_name ~= nil then
					if propValue > 0 then
						isAdd = true
						tempFont = display.newSprite("#" .. pic_name .. "_up.png")
					else
						isAdd = false
						tempFont = display.newSprite("#" .. pic_name .. "_down.png")
					end
				end
				return tempFont
			end
			function getPropNum()
				local tempPropNum
				if propValue > 0 then
					isAdd = true
					tempPropNum = ui.newBMFontLabel({
					text = "+" .. propValue,
					font = "fonts/font_green.fnt"
					})
				else
					isAdd = false
					tempPropNum = ui.newBMFontLabel({
					text = "-" .. propValue,
					font = "fonts/font_red.fnt"
					})
				end
				return tempPropNum
			end
			local fontNode = display.newNode()
			if isShowFont == 1 and isShowNum == 1 then
				propFont = getPropFont()
				propNum = getPropNum()
				propFont:setAnchorPoint(cc.p(0, 0.5))
				propNum:setAnchorPoint(cc.p(0, 0.5))
				local offsetX = (propFont:getContentSize().width + propNum:getContentSize().width) / 2
				propFont:setPosition(-offsetX, 0)
				propNum:setPosition(-offsetX + propFont:getContentSize().width, 0)
			elseif isShowFont == 1 and isShowNum ~= 1 then
				propFont = getPropFont()
			elseif isShowFont ~= 1 and isShowNum == 1 then
				propNum = getPropNum()
			elseif talEndFunc ~= nil then
				return talEndFunc()
			end
			if propFont ~= nil then
				fontNode:addChild(propFont)
			end
			if propNum ~= nil then
				fontNode:addChild(propNum)
			end
			local scaleFunc = CCCallFunc:create(function ()
				fontNode:setScaleY(0.1)
			end)
			local nodeScale = CCScaleTo:create(0.1, 1)
			local nodeMoveBy = CCMoveBy:create(0.8, cc.p(0, 100))
			local nodeRev = CCCallFunc:create(function ()
				if propType == 21 then
					card:addLife(propValue)
				elseif propType == 79 then
					card:addStars(propValue)
				end
				if talEndFunc ~= nil then
					talEndFunc()
				end
				fontNode:removeSelf()
			end)
			fontNode:runAction(transition.sequence({
			scaleFunc,
			nodeScale,
			nodeMoveBy,
			nodeRev
			}))
			card:addChild(fontNode)
		end
	end
end

--buff显示用
function BattleLayer:createNatureFont(add, natureId, card)
	if add ~= nil then
		local prop_pic = data_item_nature[natureId].prop_pic
		if prop_pic ~= nil then
			do
				local add_str, add_symbo
				if add == 0 then
					add_str = "_down"
					add_symbo = -1
				else
					add_str = "_up"
					add_symbo = 1
				end
				local propSprite = display.newSprite("#" .. prop_pic .. add_str .. ".png")
				local scaleFunc = CCCallFunc:create(function ()
					propSprite:setScaleY(0.1)
				end)
				local nodeScale = CCScaleTo:create(0.1, 1)
				local nodeMoveBy = CCMoveBy:create(0.8, cc.p(0, add_symbo * 50))
				local nodeRev = CCCallFunc:create(function ()
					propSprite:removeSelf()
				end)
				propSprite:runAction(transition.sequence({
				scaleFunc,
				nodeScale,
				nodeMoveBy,
				nodeRev
				}))
				card:addChild(propSprite)
			end
		end
	end
end
function BattleLayer:createDelayNature(card, addTable, natureTable)
	if natureTable ~= nil then
		for i = 1, #natureTable do
			ResMgr.delayFunc(0.8 * (i - 1), function ()
				self:createNatureFont(addTable[i], natureTable[i], card)
			end,
			self)
		end
	end
end
function BattleLayer:playMianYi(card)
	local mianSprite = display.newSprite("#mianyi.png")
	local scaleFunc = CCCallFunc:create(function ()
		mianSprite:setScaleY(0.1)
	end)
	local nodeScale = CCScaleTo:create(0.1, 1)
	local nodeMoveBy = CCMoveBy:create(0.8, cc.p(0, 50))
	local nodeRev = CCCallFunc:create(function ()
		mianSprite:removeSelf()
	end)
	card:addChild(mianSprite)
	mianSprite:runAction(transition.sequence({
	scaleFunc,
	nodeScale,
	nodeMoveBy,
	nodeRev
	}))
end
function BattleLayer:createBuff(data)
	local buffSide = data.s
	local buffPos = data.p
	local isMian = data.isMian
	local card = self:getCardBySideId(buffSide, buffPos)
	if isMian ~= nil and isMian == 1 then
		return self:playMianYi(card)
	end
	local buffId = data.b
	--ResMgr.showAlert(nil, "buff create id:" ..buffId);
	if data_buff_buff[buffId] == nil or data_buff_buff[buffId].arr_props == nil or data_buff_buff[buffId].arr_affect == nil then
		ResMgr.showAlert(nil, "buff not exist id:" ..buffId);
	end
	
	local arr_props = data_buff_buff[buffId].arr_props
	local arr_affect = data_buff_buff[buffId].arr_affect
	
	self:createDelayNature(card, arr_affect, arr_props)
	local replaceId = data.replaceId
	local fileName = data_buff_buff[buffId].special
	local removeBuffName
	if replaceId ~= 0 then
		removeBuffName = data_buff_buff[replaceId].special
	end
	if fileName ~= nil then
		if removeBuffName ~= nil then
			card:removeBuff(removeBuffName)
		end
		card:addBuff(fileName)
	end
end

function BattleLayer:playSound(filename, isLoop)
	local path = "sound/skill/" .. filename .. ".mp3"
	GameAudio.playSound(path, isLoop)
end

function BattleLayer:runFunc(info, atkData, endFunc)
	if self.isPlayBat ~= true then
		return
	end
	local funcType = info[1]
	local funcId = info[2]
	if funcType == FUNC_END then
		return self:skillEnd(atkData, endFunc)
	elseif funcType == EFFECT_FUNC then
		return self:skillEff(funcId, atkData, endFunc)
	elseif funcType == CARD_MOVE_FUNC then
		return self:skillCardMove(funcId, atkData, endFunc)
	elseif funcType == CARE_ROTATE_FUNC then
		return self:skillCardRotate(funcId, atkData, endFunc)
	elseif funcType == SPECIAL_FUNC then
		return self:skillSpecial(funcId, atkData, endFunc)
	elseif funcType == FIT_FUNC then
		return self:skillFit(funcId, atkData, endFunc)
	end
end
function BattleLayer:getTa(ta, side, pos)
	if #ta > 0 then
		for k, v in ipairs(ta) do
			if v.s == side and v.p == pos then
				return v.a
			end
		end
	end
end
function BattleLayer:setCardAnger(card, orAnger, targetAnger)
	local side = card:getSideID()
	local pos = card:getPosID()
	local propFont
	local propSymbo = 1
	if targetAnger ~= nil then
		if targetAnger > 0 then
			propFont = display.newSprite("#battle_nuqi_up.png")
			propSymbo = 1
		elseif targetAnger <= 0 then
			propSymbo = -1
			propFont = display.newSprite("#battle_nuqi_down.png")
		end
		local scaleFunc = CCCallFunc:create(function ()
			propFont:setScaleY(0.1)
		end)
		local nodeScale = CCScaleTo:create(0.1, 1)
		local nodeMoveBy = CCMoveBy:create(0.8, cc.p(0, 50 * propSymbo))
		local nodeRev = CCCallFunc:create(function ()
			propFont:removeSelf()
		end)
		card:addChild(propFont)
		propFont:runAction(transition.sequence({
		scaleFunc,
		nodeScale,
		nodeMoveBy,
		nodeRev
		}))
		card:setStars(orAnger + targetAnger)
	end
end
function BattleLayer:playImEff(card, imType)
	local file
	if imType == IM_TYPE.wuli then
		file = "#battle_wuli_mianyi.png"
	elseif imType == IM_TYPE.fashu then
		file = "#battle_fashu_mianyi.png"
	end
	if file ~= nil then
		do
			local imSprite = display.newSprite(file)
			local scaleFunc = CCCallFunc:create(function ()
				imSprite:setScaleY(0.1)
			end)
			local nodeScale = CCScaleTo:create(0.1, 1)
			local nodeMoveBy = CCMoveBy:create(0.8, cc.p(0, 50))
			local nodeRev = CCCallFunc:create(function ()
				imSprite:removeSelf()
			end)
			card:addChild(imSprite)
			imSprite:runAction(transition.sequence({
			scaleFunc,
			nodeScale,
			nodeMoveBy,
			nodeRev
			}))
		end
	end
end
function BattleLayer:skillEff(funcId, atkData, endFunc)
	local tr, fightBack, skillId, skillStaticData, skillName, rawTal, skillBuffs, actAnger, actCard, ta = self:unpackAtkData(atkData)
	local effectData = data_effect_effect[funcId]
	local effectName = effectData.effectName
	local effectScale = effectData.scale / 1000
	local movePoints = effectData.arr_movePos
	local moveTimes = effectData.arr_moveTime
	local track = effectData.arr_track
	local isMutiple = effectData.isMutiple
	local flipDir = effectData.flipDir
	local dir = effectData.dir
	local interval = effectData.interval
	local funcDelay = effectData.arr_funcDelay
	local funcs = effectData.arr_funcs
	local isPlayName = effectData.isPlayName
	local particleName = effectData.particle
	local sfx = effectData.sfx
	local isHurtEff = false
	if isPlayName == 1 then
		actCard:playTinyShow(skillName)
	end
	local effectShakeId = effectData.shake
	if effectShakeId ~= nil then
		self:effectShake(effectShakeId)
	end
	local effZorder
	if effectData.effZorder == nil then
		effZorder = EFFECT_ZORDER
	elseif effectData.effZorder == 0 then
		effZorder = BG_EFF_ZORDER
	else
		effZorder = EFFECT_ZORDER
	end
	if sfx ~= 0 then
		self:playSound(sfx, false)
	end
	local beHitCount = 0
	local function playBeAtkSound()
		beHitCount = beHitCount + 1
		if beHitCount % #tr == 0 then
			local beAtkSfx = skillStaticData.sfx
			if ResMgr.isHighEndDevice() == false then
				beAtkSfx = skillStaticData.sfx2
			end
			if beAtkSfx ~= nil and beAtkSfx ~= 0 then
				self:playSound(beAtkSfx, false)
			end
		end
	end
	self.battleEffTable = {}
	ResMgr.setMetatableByKV(self.battleEffTable)
	local maxPosNum = 1
	local posTable = {}
	for i = 1, #movePoints do
		local curPos = self:getEffPosByID(movePoints[i], actCard, tr)
		if maxPosNum < #curPos then
			maxPosNum = #curPos
		end
		posTable[#posTable + 1] = curPos
	end
	local isPlay = false
	local mianyiFlagList = {}
	for i = 1, #tr do
		mianyiFlagList[#mianyiFlagList + 1] = {wuli = false, fashu = false}
	end
	local function beAtk(i)
		isHurtEff = true
		playBeAtkSound()
		local shakeType = skillStaticData.shake
		if ResMgr.isHighEndDevice() == false then
			shakeType = skillStaticData.shake2
		end
		self:shake(shakeType)
		local curTr = tr[i]
		local curSide = curTr.s
		local curPos = curTr.p
		local life = curTr.l
		local anger = curTr.a
		local beAtkCard = self:getCardBySideId(curSide, curPos)
		beAtkCard:setLife(life)
		local beEffect = "beEffect"
		if ResMgr.isHighEndDevice() == false then
			beEffect = "beEffect2"
		end
		local beAtkFileName = skillStaticData[beEffect]
		local numCount = curTr.cnt
		local numVal = curTr.h / numCount
		local numT = 1
		local hitTypes = curTr.st
		local actType = DAMAGE_TYPE
		local curActAnger = curTr.sa
		if curActAnger ~= nil then
			actCard:setStars(curActAnger)
		end
		for i = 1, #hitTypes do
			if hitTypes[i] == DODGE_TYPE then
				actType = DODGE_TYPE
				break
			elseif hitTypes[i] == HEAL_TYPE then
				actType = HEAL_TYPE
				break
			else
				actType = CRITICAL_TYPE
			end
		end
		if actType ~= DODGE_TYPE then
			local beAtkEff = ResMgr.createArma({
			resType = ResMgr.NORMAL_EFFECT,
			armaName = beAtkFileName,
			isRetain = false,
			frameFunc = function ()
			end
			})
			beAtkCard:addChild(beAtkEff)
		end
		if actType == DODGE_TYPE then
			beAtkCard:playAct("dodge")
			numT = NO_HP
		elseif actType == HEAL_TYPE then
			numT = HEAL_HP
			beAtkCard:playAct("heal")
		else
			numVal = curTr.d / numCount
			beAtkCard:playAct("hit")
		end
		if numVal > 0 then
			self:createNum({
			numType = numT,
			damageType = actType,
			isRanPos = numCount,
			numValue = numVal,
			pos = cc.p(beAtkCard:getPositionX(), beAtkCard:getPositionY()),
			card = beAtkCard
			})
		end
		for i = 1, #hitTypes do
			self:createFont({
			damageType = hitTypes[i],
			sideID = beAtkCard:getSideID(),
			posID = beAtkCard:getPosID(),
			count = numCount,
			pos = cc.p(beAtkCard:getPositionX(), beAtkCard:getPositionY())
			})
		end
		local imType = curTr.im
		if imType ~= nil then
			local bCan = false
			if imType == IM_TYPE.wuli and mianyiFlagList[i].wuli == false then
				bCan = true
				mianyiFlagList[i].wuli = true
			elseif imType == IM_TYPE.fashu and mianyiFlagList[i].fashu == false then
				bCan = true
				mianyiFlagList[i].fashu = true
			end
			if bCan == true then
				self:playImEff(beAtkCard, imType)
			end
		end
	end
	for i = 1, maxPosNum do
		do
			local parEff
			if particleName ~= nil and particleName ~= 0 then
				parEff = ResMgr.createParticle(particleName)
				self.shakeNode:addChild(parEff, effZorder - 1)
			end
			local isHasShowIm = false
			local effArma = ResMgr.createArma({
			resType = ResMgr.NORMAL_EFFECT,
			armaName = effectName,
			frameTag = "atkEff",
			frameFunc = function ()
				if maxPosNum == 1 then
					for j = 1, #tr do
						if effectData.isEffect == 1 then
							beAtk(j)
						end
					end
				elseif effectData.isEffect == 1 then
					beAtk(i)
				end
			end,
			finishFunc = function ()
				if parEff ~= nil then
					parEff:removeSelf()
				end
				if isHurtEff == true and i == maxPosNum and ta ~= nil and #ta ~= 0 then
					for k = 1, #ta do
						local taSide = ta[k].s
						local taPos = ta[k].p
						local targetAnger = ta[k].a
						local angerCard = self:getCardBySideId(taSide, taPos)
						local orAnger = 0
						for m = 1, #tr do
							if tr[m].s == taSide and tr[m].p == taPos then
								orAnger = tr[m].a
								break
							end
						end
						self:setCardAnger(angerCard, orAnger, targetAnger)
					end
				end
			end,
			isRetain = false
			})
			effArma:setScale(effectScale)
			self.shakeNode:addChild(effArma, effZorder)
			local moveActions = {}
			local partActions = {}
			for j = 1, #posTable do
				local curPos = posTable[j]
				local targetPos
				if i > #curPos then
					targetPos = curPos[1]
				else
					targetPos = curPos[i]
				end
				if flipDir == 1 then
				elseif flipDir == 2 then
					if actCard:getSideID() == UP_SIDE then
						effArma:setScaleY(-1)
					end
				elseif flipDir == 3 and j ~= 1 then
					do
						local angle = self:getAngleByPos(cc.p(effArma:getPosition()), targetPos)
						local rotate = CCCallFunc:create(function ()
							effArma:setRotation(angle)
						end)
						moveActions[#moveActions + 1] = rotate
					end
				end
				if j == 1 then
					effArma:setPosition(targetPos)
					if parEff ~= nil then
						parEff:setPosition(targetPos)
					end
				else
					local moveTo = CCMoveTo:create(moveTimes[j - 1] / 1000, targetPos)
					moveActions[#moveActions + 1] = moveTo
					local partMove = CCMoveTo:create(moveTimes[j - 1] / 1000, targetPos)
					partActions[#partActions + 1] = partMove
				end
			end
			if #moveActions ~= 0 then
				effArma:runAction(transition.sequence(moveActions))
				if parEff ~= nil and #partActions ~= 0 then
					parEff:runAction(transition.sequence(partActions))
				end
			end
		end
	end
	if #funcDelay ~= #funcs then
		ResMgr.debugBanner("调用函数数量与延迟数量不一样 effecId是" .. funcId)
	end
	return self:runDelayFuncs(funcDelay, funcs, atkData, endFunc)
end
function BattleLayer:runDelayFuncs(funcDelay, funcs, atkData, endFunc)
	for i = 1, #funcDelay do
		do
			local runFuncNode = display.newNode()
			self.shakeNode:addChild(runFuncNode)
			local delayTime = CCDelayTime:create(funcDelay[i] / 1000)
			local func = CCCallFunc:create(function ()
				self:runFunc(funcs[i], atkData, endFunc)
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
	end
end
function BattleLayer:skillCardMove(funcId, atkData, endFunc)
	local actCard = self:getCardByData(atkData)
	local tr = atkData.tr
	local MAIN_CARD = 1
	local BEEFF_CARD = 2
	local moveData = data_card_move_card_move[funcId]
	local movePoints = moveData.arr_pos
	local moveTimes = moveData.arr_time
	local moveTrack = moveData.arr_track
	local animName = moveData.animName
	local animSpeed = moveData.animSpeed / 1000
	local target = moveData.target
	local funcDelay = moveData.arr_funcDelay
	local funcs = moveData.arr_funcs
	local cards = {}
	local cardSide
	if target == MAIN_CARD then
		cards[1] = actCard
		cardSide = actCard:getSideID()
	elseif target == BEEFF_CARD then
		for i = 1, #tr do
			cards[#cards + 1] = self:getCardByData(tr[i])
		end
		cardSide = tr[1].s
	else
		ResMgr.debugBanner("不存在的卡牌类型 skillCardMove")
	end
	for i = 1, #cards do
		local curCard = cards[i]
		if animName ~= 0 then
			if actCard:getSideID() == UP_SIDE and animName ~= "trick" and animName ~= "skill_yinshen" and animName ~= "skill_yinshen_back" then
				animName = animName .. "Up"
			end
			curCard:playAct(animName, nil, nil, animSpeed)
		end
		local moveActions = {}
		if #movePoints ~= 0 then
			for j = 1, #movePoints do
				local nextPos = self:getCardMovePos(movePoints[j], cards[i], tr)
				local moveTo = CCMoveTo:create(moveTimes[j] / 1000, nextPos[1])
				moveActions[#moveActions + 1] = moveTo
			end
		end
		if #moveActions ~= 0 then
			cards[i]:runAction(transition.sequence(moveActions))
		end
	end
	for i = 1, #tr do
		if tr[i].ms ~= 0 then
			local trSide = tr[i].s
			local trPos = tr[i].p
			local card = self:getCardBySideId(trSide, trPos)
			card:setZOrder(HELP_CARD_ZORDER)
			local targetPos = self:getPosBySideAndID(tr[i].ms, tr[i].mp)
			if ms ~= 0 then
				if trSide == UP_SIDE then
					targetPos.y = targetPos.y - actCard:getContentSize().height * 0.5
				else
					targetPos.y = targetPos.y + actCard:getContentSize().height * 0.5
				end
			end
			local moveTo = CCMoveTo:create(0.15, targetPos)
			card:runAction(moveTo)
		end
	end
	if #funcDelay ~= #funcs then
		ResMgr.debugBanner("调用函数数量与延迟数量不一样 card move Id是" .. funcId)
	end
	return self:runDelayFuncs(funcDelay, funcs, atkData, endFunc)
end
function BattleLayer:skillCardRotate(funcId, atkData, endFunc)
	local roData = data_card_rotation_card_rotation[funcId]
	local funcDelay = roData.arr_funcDelay
	local funcs = roData.arr_funcs
	if #funcDelay ~= #funcs then
		ResMgr.debugBanner("旋转函数不一样 card move Id是" .. funcId)
	end
	return self:runDelayFuncs(funcDelay, funcs, atkData, endFunc)
end

function BattleLayer:skillSpecial(funcId, atkData, endFunc)
	local actCard = self:getCardByData(atkData)
	local specialData = data_special_special[funcId]
	local funcs = specialData.arr_funcs
	if actCard:getSideID() == DOWN_SIDE then
		local fontScale = specialData.fontRate / 1000
		self:playRage(atkData, fontScale, specialData)
		local funcDelay = specialData.arr_funcDelay
		if #funcDelay ~= #funcs then
			ResMgr.debugBanner("special的delay不一样 special Id是" .. funcId)
		end
		self:runDelayFuncs(funcDelay, funcs, atkData, endFunc)
	else
		for i = 1, #funcs do
			self:runFunc(funcs[i], atkData, endFunc)
		end
	end
end
function BattleLayer:skillFit(funcId, atkData, endFunc)
	local actCard = self:getCardByData(atkData)
	local specialData = data_special_special[funcId]
	local funcs = specialData.arr_funcs
	self.fitMaskLayer:setVisible(true)
	function fitEndFunc(...)
		self.fitMaskLayer:setVisible(false)
		self.fitMaskLayer:removeAllChildrenWithCleanup(true)
		if endFunc then
			endFunc()
		end
	end
	if actCard:getSideID() == DOWN_SIDE then
		local fitGroupNeedCard = data_card_card[actCard:getResId()].groupNeed
		self:playFitSkill(fitGroupNeedCard, atkData, fontScale, specialData)
		local funcDelay = specialData.arr_funcDelay
		if #funcDelay ~= #funcs then
			ResMgr.debugBanner("special的delay不一样 special Id是" .. funcId)
		end
		funcDelay[1] = funcDelay[1] + 500
		self:runDelayFuncs(funcDelay, funcs, atkData, fitEndFunc)
	else
		for i = 1, #funcs do
			self:runFunc(funcs[i], atkData, fitEndFunc)
		end
	end
end
function BattleLayer:playFitSkill(fitGroupNeedCard, atkData, fontScale, specialData)
	local targetResults, fightBack, skillId, skillStaticData, skillName, rawTal, skillBuffs, actAnger, actCard = self:unpackAtkData(atkData)
	local Height_FITBG = display.height - 300
	local FitNode = display.newNode()
	local FitOtherNode = display.newNode()
	self.fitMaskLayer:addChild(FitNode)
	self.fitMaskLayer:addChild(FitOtherNode)
	local FitBgEffect = ResMgr.createArma({
	resType = ResMgr.UI_EFFECT,
	armaName = "hetiji_2",
	isRetain = true
	})
	FitBgEffect:setPosition(display.width / 2, Height_FITBG)
	FitNode:addChild(FitBgEffect, FIT_ZORDER + 10)
	local FitHuoEffect = ResMgr.createArma({
	resType = ResMgr.UI_EFFECT,
	armaName = "hetiji_1",
	isRetain = true
	})
	FitHuoEffect:setPosition(display.width / 2, Height_FITBG)
	FitNode:addChild(FitHuoEffect, FIT_ZORDER + 30)
	local nameSprite
	local curScale = 1
	local nameStr = skillStaticData.rageSpriteName
	if nameStr == nil then
		ResMgr.showErr(-2)
		return
	end
	local namePath = "image_name/rage_image/" .. nameStr .. ".png"
	local nameSprite = display.newSprite(namePath)
	nameSprite:setVisible(false)
	nameSprite:setAnchorPoint(0.5, 0.5)
	nameSprite:setPosition(0, 0)
	FitHuoEffect:addChild(nameSprite, 100)
	if fitGroupNeedCard and #fitGroupNeedCard > 0 then
		if #fitGroupNeedCard == 1 then
			do
				local cardResId_1 = actCard:getResId()
				local cardCls_1 = actCard:getCls() + 1
				local heroPath_1 = ResMgr.getHeroBodyName(cardResId_1, cardCls_1)
				local nameSprite_1 = display.newSprite(heroPath_1)
				nameSprite_1:setAnchorPoint(1, 0.5)
				nameSprite_1:setScale(0.7)
				nameSprite_1:setVisible(false)
				nameSprite_1:setFlipX(true)
				nameSprite_1:setPosition(180, Height_FITBG + 50)
				FitNode:addChild(nameSprite_1, FIT_ZORDER + 20)
				local cardResId_2, cardCls_2, card_fit = self:getCardDataON(fitGroupNeedCard[1], actCard:getSideID())
				local heroPath_2 = ResMgr.getHeroBodyName(cardResId_2, cardCls_2)
				local nameSprite_2 = display.newSprite(heroPath_2)
				nameSprite_2:setAnchorPoint(0, 0.5)
				nameSprite_2:setScale(0.65)
				nameSprite_2:setVisible(false)
				nameSprite_2:setPosition(display.width - 180, Height_FITBG + 50)
				FitNode:addChild(nameSprite_2, FIT_ZORDER + 19)
				local move_1 = CCMoveTo:create(0.01, cc.p(display.width / 2 + 20, nameSprite_1:getPositionY()))
				local move_2 = CCMoveTo:create(0.01, cc.p(display.width / 2 - 20, nameSprite_2:getPositionY()))
				local move_3 = CCMoveTo:create(1, cc.p(display.width / 2 + 30, nameSprite_1:getPositionY()))
				local move_4 = CCMoveTo:create(1, cc.p(display.width / 2 - 30, nameSprite_2:getPositionY()))
				local callfunc1 = CCCallFunc:create(function ()
					nameSprite:setScale(6)
					nameSprite:setVisible(true)
				end)
				local callfunc2 = CCCallFunc:create(function ()
					local small = CCScaleTo:create(0.1, curScale)
					local moveTo = CCMoveTo:create(0.1, cc.p(0, -60))
					local spawn = CCSpawn:createWithTwoActions(moveTo, small)
					nameSprite:runAction(spawn)
				end)
				local ccc_1 = CCCallFunc:create(function ()
					nameSprite_1:setVisible(true)
				end)
				local ccc_setPos_1 = CCCallFunc:create(function ()
					nameSprite_1:setPosition(display.width / 2 - 20, nameSprite_1:getPositionY())
				end)
				local ccc_2 = CCCallFunc:create(function ()
					nameSprite_2:setVisible(true)
				end)
				local ccc_setPos_2 = CCCallFunc:create(function ()
					nameSprite_2:setPosition(display.width / 2 + 20, nameSprite_2:getPositionY())
				end)
				local callfunc3 = CCCallFunc:create(function ()
					FitNode:removeAllChildrenWithCleanup(true)
				end)
				local delayTime = CCDelayTime:create(0.1)
				nameSprite_1:runAction(transition.sequence({
				CCDelayTime:create(0.1),
				ccc_1,
				move_1,
				ccc_setPos_1,
				move_3
				}))
				nameSprite_2:runAction(transition.sequence({
				CCDelayTime:create(0.1),
				ccc_2,
				move_2,
				ccc_setPos_2,
				callfunc1,
				callfunc2,
				move_4,
				delayTime,
				callfunc3
				}))
				local delays = 1.5
				local actCardPosId = actCard:getPosID() % 3
				local leftPosY = display.height * 0.2
				local leftPosX = display.width * 0.35
				local rightPosX = display.width * 0.65
				local actCardPosX = leftPosX
				local otherPosX = rightPosX
				if card_fit == nil then
					if actCardPosId == 0 then
						actCardPosX = rightPosX
						otherPosX = leftPosX
					end
				else
					local tempId = card_fit:getPosID() % 3
					if tempId == 0 and actCardPosId ~= 0 or tempId ~= 0 and actCardPosId ~= 0 and actCardPosId < tempId then
						actCardPosX = leftPosX
						otherPosX = rightPosX
					end
				end
				actCard:playFitShow(delays, actCardPosX, leftPosY, FIT_ZORDER)
				local card_fitPosX = 0
				if otherPosX < display.width / 2 then
					card_fitPosX = -200
				else
					card_fitPosX = display.width + 200
				end
				if card_fit == nil then
					card_fit = require("game.Charactor.characterCard").new({
					isExist = true,
					id = cardResId_2,
					fashionId = nil,
					posId = nil,
					anger = 0,
					side = actCard:getSideID(),
					isTouchAble = false,
					scale = 1,
					isShowHpAndAnger = true,
					cls = 1,
					star = 1,
					maxLife = 100,
					isMove = true
					})
					card_fit:setPosition(card_fitPosX, -200)
					FitOtherNode:addChild(card_fit)
				end
				card_fit:playFitShow(delays, otherPosX, leftPosY, FIT_ZORDER)
				local enemyCardCallfunc = CCCallFunc:create(function ()
					if targetResults ~= nil then
						for i = 1, #targetResults do
							local beAtkCard = self:getCardByData(targetResults[i])
							beAtkCard:setZOrder(beAtkCard:getZOrder() + FIT_ZORDER)
						end
					end
				end)
				self:runAction(transition.sequence({
				CCDelayTime:create(delays),
				enemyCardCallfunc
				}))
			end
		elseif #fitGroupNeedCard == 2 then
		end
	end
end
function BattleLayer:getCardDataON(resId, sideId)
	if sideId == DOWN_SIDE then
		local isInForm = false
		for k, v in pairs(self.friendCard) do
			local _resId = v:getResId()
			if _resId == resId then
				isInForm = true
				return v:getResId(), v:getCls() + 1, v
			end
		end
		if isInForm == false then
			return resId, 1, nil
		end
	else
		local isInForm = false
		for k, v in pairs(self.enemyCard) do
			local _resId = v:getResId()
			if _resId == resId then
				isInForm = true
				return v:getResId(), v:getCls() + 1, v
			end
		end
		if isInForm == false then
			return resId, 1, nil
		end
	end
end
function BattleLayer:nextRound(funcId, actCard, tr)
	local function dramaEndFunc()
		self:stateMachine()
	end
	self:playDrama(AFTER_ROUND, dramaEndFunc)
end
function BattleLayer:skillEnd(atkData, endFunc)
	local targetResults, fightBack, skillId, skillStaticData, skillName, rawTal, skillBuffs, actAnger, actCard = self:unpackAtkData(atkData)
	local backTime = BACK_TIME
	self:resetFontFlag()
	if targetResults ~= nil then
		for i = 1, #targetResults do
			local beAtkCard = self:getCardByData(targetResults[i])
			beAtkCard:setZOrder(NORMAL_CARD_ZORDER)
			local lifeRest = targetResults[i].l
			local anger = targetResults[i].a
			if lifeRest ~= 0 then
				beAtkCard:playAct("stop")
			else
				self:playDie(beAtkCard)
				beAtkCard:setVisible(false)
			end
		end
		local totalDamage
		local isTotal = skillStaticData.sum
		if isTotal == SHOW_SUM_NUM then
			local totalNum = 0
			for i = 1, #targetResults do
				totalNum = totalNum + targetResults[i].d
			end
			totalDamage = ResMgr.createArma({
			resType = ResMgr.NORMAL_EFFECT,
			armaName = "zongshanghai",
			isRetain = false
			})
			display.getRunningScene():addChild(totalDamage, EFFECT_ZORDER)
			local numTTF = ui.newBMFontLabel({
			text = "-" .. totalNum,
			font = "fonts/font_red.fnt",
			size = 30
			})
			local numBone = CCBone:create("numBone")
			numBone:addDisplay(numTTF, 0)
			numBone:changeDisplayWithIndex(0, true)
			numBone:setZOrder(100)
			totalDamage:addBone(numBone, "gunbai")
			totalDamage:setScale(1.4)
			totalDamage:setPosition(display.width * 0.8, display.height / 2)
			totalDamage:getAnimation():playWithIndex(0)
			numBone:changeDisplayWithIndex(0, true)
		end
	end
	local function cardResetFunc(cards)
		for k, card in pairs(cards) do
			do
				local enPos = self:getPosBySideAndID(card:getSideID(), card:getPosID())
				local angel = 0
				local backRota = CCRotateTo:create(backTime, -angel)
				local backMove = CCMoveTo:create(backTime, enPos)
				local backSpawn = CCSpawn:createWithTwoActions(backRota, backMove)
				card:runAction(transition.sequence({
				backSpawn,
				CCCallFunc:create(function ()
					card:setZOrder(NORMAL_CARD_ZORDER)
				end)
				}))
			end
		end
	end
	cardResetFunc(self.friendCard)
	cardResetFunc(self.enemyCard)
	local runNode = display.newNode()
	self.shakeNode:addChild(runNode)
	runNode:runAction(transition.sequence({
	CCDelayTime:create(backTime),
	CCCallFunc:create(function ()
		endFunc()
	end),
	CCRemoveSelf:create(true)
	}))
end
function BattleLayer:safegGtEffPosByID(id, actCard, tr)
	local side = actCard:getSideID()
	local trSide
	if tr ~= nil then
		trSide = tr[1].s
	end
	local pos = {}
	if id == 1 then
		pos[1] = cc.p(actCard:getPosition())
	elseif id == 2 then
		local tempPos = cc.p(actCard:getPosition())
		if side == UP_SIDE then
			tempPos.y = tempPos.y - actCard:getContentSize().height * 0.9
		else
			tempPos.y = tempPos.y + actCard:getContentSize().height * 0.9
		end
		pos[1] = tempPos
	elseif id == 3 then
		for i = 1, #tr do
			local trSide, trP, mp = self:getTruePos(i, tr)
			local orpp = self:getPosBySideAndID(trSide, trP)
			if mp == 1 then
				if trSide == UP_SIDE then
					orpp.y = orpp.y - actCard:getContentSize().height * 0.5
				else
					orpp.y = orpp.y + actCard:getContentSize().height * 0.5
				end
			end
			pos[#pos + 1] = orpp
		end
	elseif id == 4 then
		local tempPos = cc.p(display.cx, display.cy)
		if trSide == UP_SIDE then
			tempPos.y = tempPos.y * 1.5
		else
			tempPos.y = tempPos.y * 0.5
		end
		pos[1] = tempPos
	elseif id == 5 then
		pos[1] = cc.p(display.cx, display.cy)
	elseif id == 6 then
		local tempPos = cc.p(display.cx, display.cy)
		if side == UP_SIDE then
			tempPos.y = tempPos.y + display.height / 4
		else
			tempPos.y = tempPos.y - display.height / 4
		end
		pos[1] = tempPos
	elseif id == 7 then
		local tempPos = cc.p(display.cx, display.cy)
		if trSide == UP_SIDE then
			tempPos.y = display.height
		else
			tempPos.y = 0
		end
		pos[1] = tempPos
	elseif id == 8 then
		local tempPos = cc.p(display.cx, display.cy)
		if side == UP_SIDE then
			tempPos.y = display.height
		else
			tempPos.y = 0
		end
		pos[1] = tempPos
	elseif id == 9 then
		local tempPos = cc.p(actCard:getPosition())
		if side == UP_SIDE then
			tempPos.y = display.height
		else
			tempPos.y = 0
		end
		pos[1] = tempPos
	elseif id == 10 then
		local trSide, trP = self:getTruePos(1, tr)
		local tempPos = self:getPosBySideAndID(trSide, trP)
		if trSide == UP_SIDE then
			tempPos.y = display.height
		else
			tempPos.y = 0
		end
		pos[1] = tempPos
	elseif id == 11 then
		local trSide, trP = self:getTruePos(1, tr)
		if trP > 3 then
			trP = trP - 3
		end
		local tempPos = self:getPosBySideAndID(trSide, trP)
		if trSide == UP_SIDE then
			tempPos.y = tempPos.y - actCard:getContentSize().height * 0.9
		else
			tempPos.y = tempPos.y + actCard:getContentSize().height * 0.9
		end
		pos[1] = tempPos
	elseif id == 12 then
		local trSide, trP = self:getTruePos(1, tr)
		if trP > 3 then
			trP = 5
		else
			trP = 2
		end
		local tempPos = self:getPosBySideAndID(trSide, trP)
		pos[1] = tempPos
	else
		ResMgr.debugBanner("特效位置不存在 id是 " .. id)
	end
	if #pos == 0 then
		ResMgr.debugBanner("特效位置id错误，id为 " .. id)
	end
	return pos
end
function BattleLayer:getEffPosByID(id, actCard, tr)
	return safe_call(function ()
		return self:safegGtEffPosByID(id, actCard, tr)
	end)
end
function BattleLayer:getTruePos(k, tr)
	local trSide = 0
	local trP = 0
	local isMp = 0
	local ms = tr[k].ms
	if ms ~= 0 then
		trSide = ms
		trP = tr[k].mp
		isMp = 1
	else
		trSide = tr[k].s
		trP = tr[k].p
	end
	return trSide, trP, isMp
end
function BattleLayer:getCardMovePos(moveID, actCard, tr)
	local beforRate = 1
	local side = actCard:getSideID()
	local pos = {}
	if moveID == 1 then
		pos[1] = cc.p(actCard:getPosition())
	elseif moveID == 2 then
		local trSide, trP = self:getTruePos(1, tr)
		local tempPos = self:getPosBySideAndID(trSide, trP)
		if side == UP_SIDE then
			tempPos.y = tempPos.y + actCard:getContentSize().height * beforRate
		else
			tempPos.y = tempPos.y - actCard:getContentSize().height * beforRate
		end
		pos[1] = tempPos
	elseif moveID == 3 then
		for i = 1, #tr do
			local trSide, trP = self:getTruePos(i, tr)
			pos[#pos + 1] = self:getPosBySideAndID(trSide, trP)
		end
	elseif moveID == 4 then
		pos[1] = cc.p(display.cx, display.cy)
	elseif moveID == 5 then
		local trSide, trP = self:getTruePos(1, tr)
		if trP > 3 then
			trP = trP - 3
		end
		local tempPos = self:getPosBySideAndID(trSide, trP)
		if trSide == UP_SIDE then
			tempPos.y = tempPos.y - actCard:getContentSize().height * beforRate
		else
			tempPos.y = tempPos.y + actCard:getContentSize().height * beforRate
		end
		pos[1] = tempPos
	elseif moveID == 6 then
		local trSide, trP = self:getTruePos(1, tr)
		trP = 2
		local tempPos = self:getPosBySideAndID(trSide, trP)
		if trSide == UP_SIDE then
			tempPos.y = tempPos.y - actCard:getContentSize().height * beforRate
		else
			tempPos.y = tempPos.y + actCard:getContentSize().height * beforRate
		end
		pos[1] = tempPos
	elseif moveID == 7 then
		local trSide, trP = self:getTruePos(1, tr)
		trP = tr[#tr].p
		local tempPos = self:getPosBySideAndID(trSide, trP)
		if trSide == UP_SIDE then
			tempPos.y = tempPos.y - actCard:getContentSize().height * beforRate
		else
			tempPos.y = tempPos.y + actCard:getContentSize().height * beforRate
		end
		pos[1] = tempPos
	elseif moveID == 8 then
		local trSide, trP = self:getTruePos(1, tr)
		if trP > 3 then
			trP = 5
		else
			trP = 2
		end
		local tempPos = self:getPosBySideAndID(trSide, trP)
		if trSide == UP_SIDE then
			tempPos.y = tempPos.y - actCard:getContentSize().height * beforRate
		else
			tempPos.y = tempPos.y + actCard:getContentSize().height * beforRate
		end
		pos[1] = tempPos
	elseif moveID == 9 then
		local tempPos = cc.p(actCard:getPosition())
		tempPos.x = tempPos.x - actCard:getContentSize().width * 0.9
		pos[1] = tempPos
	elseif moveID == 10 then
		local tempPos = cc.p(actCard:getPosition())
		tempPos.x = tempPos.x + actCard:getContentSize().width * 0.9
		pos[1] = tempPos
	elseif moveID == 11 then
		local tempPos = cc.p(actCard:getPosition())
		local side = actCard:getSideID()
		if side == UP_SIDE then
			tempPos.y = tempPos.y + actCard:getContentSize().height * 0.9
		else
			tempPos.y = tempPos.y - actCard:getContentSize().height * 0.9
		end
		pos[1] = tempPos
	elseif moveID == 12 then
		pos[1] = self.battleEffTable[#self.battleEffTable]:getPosition()
	elseif moveID == 13 then
		local trSide, trP = self:getTruePos(1, tr)
		local tempPos = self:getPosBySideAndID(trSide, trP)
		if trSide == UP_SIDE then
			tempPos.y = display.height + actCard:getContentSize().height
		else
			tempPos.y = 0 - actCard:getContentSize().height
		end
		pos[1] = tempPos
	elseif moveID == 14 then
		local trSide, trP = self:getTruePos(1, tr)
		local tempPos = self:getPosBySideAndID(trSide, trP)
		local trSide = tr[1].s
		if trSide == UP_SIDE then
			tempPos.y = display.height + actCard:getContentSize().height
		else
			tempPos.y = 0 - actCard:getContentSize().height
		end
		tempPos.x = display.width / 2
		pos[1] = tempPos
	else
		ResMgr.debugBanner("卡牌移动位置不存在 id " .. moveID)
	end
	if #pos == 0 then
		ResMgr.debugBanner("卡牌移动位置id错误，id为 " .. moveID)
	end
	return pos
end

function BattleLayer:battleResult()
	local function resultEndFunc()
		self:resetTimeScale()
		if self.fubenType ~= WORLDBOSS_FUBEN and self.fubenType ~= GUILD_QLBOSS_FUBEN then
			GameAudio.stopMusic(false)
		end
		self.resultFunc(self.totalData)
		
		if self.speedBtn ~= nil then
			self.speedBtn:removeSelf()
		end
		
		if self.jumpBtn ~= nil then
			self.jumpBtn:removeSelf()
		end
	end
	
	self.isAbleJump = false
	if self.fubenType == JINGYING_FUBEN then
		local waveData = self.totalData["5"]
		local curLv = waveData[3]
		if curLv == 0 then
			self:playDrama(AFTER_BATTLE, resultEndFunc)
		else
			self.curReqNum = curLv + 1
			self:sendBattleReq()
		end
	elseif self.fubenType == HUODONG_FUBEN or self.fubenType == ZHENSHEN_FUBEN then
		local waveData = self.totalData["5"]
		local curLv = waveData[1]
		if curLv == 0 then
			self:playDrama(AFTER_BATTLE, resultEndFunc)
		else
			self.curReqNum = curLv + 1
			self:sendBattleReq()
		end
	else
		self:playDrama(AFTER_BATTLE, resultEndFunc)
	end
	if self.maxReqNum == 1 then
		ResMgr.setTimeScale(1)
	end
end

function BattleLayer:resetTimeScale()
	ResMgr.setTimeScale(1)
end

function BattleLayer:changeTimeScale(timeScale)
	ResMgr.replaceNormalButton(self.speedBtn, "#battle_spd_" .. timeScale .. ".png")
	ResMgr.setTimeScale(timeScale)
end

function BattleLayer:initTimeScale()
	if (ResMgr.battleTimeScale < 0 or ResMgr.battleTimeScale > 3) then
		ResMgr.battleTimeScale = 1
	end
	self.timeScale = ResMgr.battleTimeScale
	BattleSpeedTipsShow = true
	self.speedBtn = ResMgr.newNormalButton(	{
	scaleBegan = 0.9,
	sprite = "#battle_spd_1.png",
	handle = function()
		local nextSpeed = 1
		if self.timeScale < 3 then
			nextSpeed = self.timeScale + 1
		end
		if game.player:canSetSpeed(nextSpeed, BattleSpeedTipsShow) == true then
			self.timeScale = nextSpeed
			ResMgr.battleTimeScale = nextSpeed--1 + (nextSpeed - 1) * 0.5
			self:changeTimeScale(self.timeScale)
		elseif nextSpeed == 3 then
			if BattleSpeedTipsShow == true then
				BattleSpeedTipsShow = false
			else
				self.timeScale = 1
				ResMgr.battleTimeScale = 1
				self:changeTimeScale(self.timeScale)
			end
		end
	end
	})
	self.speedBtn:align(display.LEFT_BOTTOM)
	self.shakeNode:addChild(self.speedBtn, EFFECT_ZORDER + 100)
	self:changeTimeScale(self.timeScale)
end

function BattleLayer:initPos()
	local displayWidth = display.width
	local displayHight = display.height
	local leftPosX = displayWidth * 0.2
	local centerPosX = displayWidth * 0.5
	local rightPosX = displayWidth * 0.8
	local posY1 = displayHight * 0.66
	local posY2 = displayHight * 0.86
	local posY3 = displayHight * 0.3
	local posY4 = displayHight * 0.11
	self.f2Pos = {
	cc.p(leftPosX, posY1),
	cc.p(centerPosX, posY1),
	cc.p(rightPosX, posY1),
	cc.p(leftPosX, posY2),
	cc.p(centerPosX, posY2),
	cc.p(rightPosX, posY2)
	}
	self.f1Pos = {
	cc.p(leftPosX, posY3),
	cc.p(centerPosX, posY3),
	cc.p(rightPosX, posY3),
	cc.p(leftPosX, posY4),
	cc.p(centerPosX, posY4),
	cc.p(rightPosX, posY4)
	}
end
function BattleLayer:shake(shakeId)
	self:shakeNodeById(shakeId, self.shakeNode)
end
function BattleLayer:effectShake(shakeId)
	self:shakeNodeById(shakeId, self.nodes.normal_effect_node)
end
function BattleLayer:shakeNodeById(shakeId, node)
	ResMgr.shakeScr({
	node = node,
	shakeId = shakeId,
	orX = 0,
	orY = 0
	})
end
function BattleLayer:clearEnemyCard()
	for k, v in pairs(self.enemyCard) do
		v:removeSelf()
	end
	self.enemyCard = {}
	ResMgr.setMetatableByKV(self.enemyCard)
end
function BattleLayer:clearFriendCard()
	for k, v in pairs(self.friendCard) do
		v:removeSelf()
	end
	self.friendCard = {}
	ResMgr.setMetatableByKV(self.friendCard)
end
function BattleLayer:changeBattleCount(countNum)
	if self.battleCount ~= countNum then
		self.battleCount = countNum
		self.battleCountTTF:setString(self.battleCount .. self.maxCountTTF)
		if self.roundCB ~= nil then
			self.roundCB(self.battleCount)
		end
	end
end
function BattleLayer:getPosBySideAndID(side, posID)
	local tempPos
	if side == DOWN_SIDE then
		tempPos = self.f1Pos[posID]
	else
		tempPos = self.f2Pos[posID]
	end
	return cc.p(tempPos.x, tempPos.y)
end
function BattleLayer:getCardBySideId(side, posID)
	if side == DOWN_SIDE then
		return self.friendCard[posID]
	elseif side == UP_SIDE then
		return self.enemyCard[posID]
	end
end

function BattleLayer:getCardByData(atkData)
	return self:getCardBySideId(atkData.s, atkData.p)
end

local maskSize = cc.size(display.width * 2, display.height * 2)

function BattleLayer:fade(time, delayTime)
	self.maskLayer:setVisible(true)
	self.maskLayer:setContentSize(maskSize)
	local fadeTo = CCFadeTo:create(time, 250)
	local delayFade = CCDelayTime:create(delayTime)
	local fadeOut = CCFadeTo:create(time / 2, 0)
	local fadeUnvisible = CCCallFunc:create(function ()
		self.maskLayer:setVisible(false)
	end)
	local fadeTo2 = CCFadeTo:create(time, 0)
	self.maskLayer:stopAllActions()
	self.maskLayer:runAction(transition.sequence({
	fadeTo,
	delayFade,
	fadeTo2,
	fadeUnvisible
	}))
end
function BattleLayer:getAngleByPos(startPos, endPos)
	local x = endPos.x - startPos.x
	local y = endPos.y - startPos.y
	local angle = math.atan2(y, x)
	return 90 - angle * 180 / 3.14
end
function BattleLayer:updateDmageNum(cardSide, num)
	if cardSide ~= nil and cardSide == UP_SIDE and self.damageCB ~= nil then
		self.damageCB(num)
	end
end
local HIT_TYPE_DODAGE = 1
local HIT_TYPE_CRITICAL = 2
local HIT_TYPE_BLOCK = 3
local xTa = {
-0.6,
0.4,
0,
0.4,
0.6
}
local yTa = {
-0.5,
-0.3,
-0.1,
0.3,
0.5
}
BattleLayer.numNodes = {
{},
{},
{}
}
local fontNames = {
"fonts/font_baoji.fnt",
"fonts/font_red.fnt",
"fonts/font_green.fnt"
}
function BattleLayer:getNumNode(nType)
	local numberNodes = self.numNodes[nType]
	local numNode
	for k, v in pairs(numberNodes) do
		if v.isUse ~= true then
			numNode = v
			break
		end
	end
	if numNode == nil then
		numNode = display.newNode()
		numNode.numTTF = ui.newBMFontLabel({
		text = "",
		font = fontNames[nType]
		})
		numNode:addChild(numNode.numTTF)
		numNode:retain()
		numberNodes[#numberNodes + 1] = numNode
	end
	numNode.isUse = true
	return numNode
end

function BattleLayer:createNum(param)
	local numNode
	local card = param.card
	local cardSide
	if card ~= nil then
		cardSide = card:getSideID()
	end
	local numType = param.numType
	local numValue = math.ceil(param.numValue)
	local pos = param.pos
	local isRanPos = param.isRanPos or 1
	local dType = param.damageType
	local DELAY_TIME = NORMAL_DAMAGE_TIME
	local text = ""
	if dType == HIT_TYPE_DODAGE then
	elseif dType == HIT_TYPE_CRITICAL then
		numNode = self:getNumNode(1)
		local baojiBigger = CCScaleTo:create(0.1, 1.5)
		local baojiSmaller = CCScaleTo:create(0.1, 1)
		numNode.numTTF:runAction(transition.sequence({baojiBigger, baojiSmaller}))
		text = "-" .. numValue
	elseif numType == SUB_HP then
		numNode = self:getNumNode(2)
		text = "-" .. numValue
	elseif numType == HEAL_HP then
		numNode = self:getNumNode(3)
		text = "+" .. numValue
	end
	numNode.numTTF:setString(text)
	self.shakeNode:addChild(numNode, NUM_ZORDER)
	local ranPosX = 0
	local ranPosY = 0
	if isRanPos ~= 1 then
		local xRan = xTa[math.random(1, #xTa)]
		local yRan = yTa[math.random(1, #yTa)]
		ranPosX = numNode.numTTF:getContentSize().width * xRan
		ranPosY = numNode.numTTF:getContentSize().height * yRan
	end
	numNode:setPosition(pos.x + ranPosX, pos.y + ranPosY)
	local setSmall = CCCallFunc:create(function ()
		numNode.numTTF:setScale(0.5 * NUM_SCALE)
	end)
	local beBigger = CCScaleTo:create(0.1, 1.5 * NUM_SCALE)
	if dType == HIT_TYPE_CRITICAL then
		beBigger = CCScaleTo:create(0.05, 1.8 * NUM_SCALE)
		DELAY_TIME = NORMAL_HEAL_CRITICAL_TIME
		if numType == SUB_HP then
			self:shake(1)
		end
	end
	local delay = CCDelayTime:create(0.3)
	local beSmaller = CCScaleTo:create(0.1, 0.8, 0.2)
	local reSelf = CCRemoveSelf:create(true)
	local callfunc = CCCallFunc:create(function ()
		numNode.isUse = false
	end)
	numNode:runAction(transition.sequence({
	beBigger,
	delay,
	beSmaller,
	reSelf,
	callfunc
	}))
end
BattleLayer.fontNodes = {
{},
{},
{}
}

function BattleLayer:getFont(dType)
	local typeFontNodes = self.fontNodes[dType]
	local fontNode
	for k, v in pairs(typeFontNodes) do
		if v.isUse ~= true then
			fontNode = v
			break
		end
	end
	if fontNode == nil then
		fontNode = display.newNode()
		if dType == HIT_TYPE_DODAGE then
			fontNode.fontTTF = display.newSprite("#battle_shanbi.png")
		elseif dType == HIT_TYPE_CRITICAL then
			fontNode.fontTTF = display.newSprite("#battle_baoji.png")
		elseif dType == HIT_TYPE_BLOCK then
			fontNode.fontTTF = display.newSprite("#battle_gedang.png")
		end
		fontNode:addChild(fontNode.fontTTF)
		fontNode:retain()
		typeFontNodes[#typeFontNodes + 1] = fontNode
	end
	fontNode.isUse = true
	return fontNode
end

function BattleLayer:createFont(param)
	local count = param.count or 0
	local flag = self.fontFlag[param.sideID][param.posID][param.damageType]
	self.fontFlag[param.sideID][param.posID][param.damageType] = 1
	if param.damageType > 3 then
		return
	end
	if flag == nil then
		do
			local dType = param.damageType
			local fontNode = self:getFont(dType)
			local heightOffset = 0
			self.shakeNode:addChild(fontNode, NUM_ZORDER)
			local fontTTF = fontNode.fontTTF
			if dType == HIT_TYPE_DODAGE then
			elseif dType == HIT_TYPE_CRITICAL then
				fontTTF:setAnchorPoint(cc.p(0.5, 0))
				fontTTF:setScale(0.1)
				local numDelay = CCDelayTime:create(0.2)
				local numScale = CCScaleTo:create(0.1, 0.8)
				fontTTF:runAction(transition.sequence({numDelay, numScale}))
				heightOffset = fontTTF:getContentSize().height * 0.7
			elseif dType == HIT_TYPE_BLOCK then
				fontTTF:setAnchorPoint(cc.p(0.5, 0))
				heightOffset = fontTTF:getContentSize().height * 0.7
				self:playSound("gedang", false)
			end
			local beBigger, DELAY_TIME
			if dType == HIT_TYPE_CRITICAL then
				beBigger = CCScaleTo:create(0.05, 1.8)
				DELAY_TIME = NORMAL_DAMAGE_CRITICAL_TIME + count * 0.2
			else
				beBigger = CCScaleTo:create(0.1, 1.5)
				DELAY_TIME = NORMAL_DAMAGE_CRITICAL_TIME
			end
			local delay = CCDelayTime:create(DELAY_TIME)
			local beSmaller = CCScaleTo:create(0.1, 0.8, 0.2)
			local callfunc = CCCallFunc:create(function ()
				fontNode.isUse = false
			end)
			local reSelf = CCRemoveSelf:create(true)
			fontNode:runAction(transition.sequence({
			beBigger,
			delay,
			beSmaller,
			reSelf,
			callfunc
			}))
			fontNode:setPosition(param.pos.x, param.pos.y + heightOffset)
		end
	end
end

function BattleLayer:resetFontFlag()
	self.fontFlag = {}
	for i = 1, 2 do
		self.fontFlag[i] = {
		{},
		{},
		{},
		{},
		{},
		{}
		}
	end
end
local angelTable = {
0,
-8,
-25,
-30,
-40,
-50
}
local posTable = {
0,
-50,
-60,
-80,
-100,
-110
}
function BattleLayer:cardCasinoArise(param)
	local cardNum = self.friendNum
	local cardTable = self.friendCard
	local orAngel = angelTable[cardNum]
	local orPosX = posTable[cardNum]
	local offsetAngel = 0
	local offsetPosX = 0
	if cardNum ~= 1 then
		offsetAngel = math.abs(orAngel) * 2 / (cardNum - 1)
		offsetPosX = math.abs(orPosX) * 2 / (cardNum - 1)
	end
	local midPos, backPos
	local cardCount = 0
	local finalCount = 0
	local zhankaiTime = 0.2
	local seqTime = 0.2
	local seqOffset = 0.2
	local toRightTime = 0.1
	for k, v in pairs(self.friendCard) do
		v:setVisible(true)
		if midPos == nil then
			midPos = self:getEffPosByID(6, v)[1]
			backPos = self:getEffPosByID(8, v)[1]
		end
		v:setPosition(backPos)
		local curCardAngel = orAngel + cardCount * offsetAngel
		local curCardPos = cc.p(midPos.x + orPosX + cardCount * offsetPosX, midPos.y - math.abs(curCardAngel) * 0.7)
		local fromBack = CCMoveTo:create(0.1, midPos)
		local delay = CCDelayTime:create(0.5)
		local moveTo = CCMoveTo:create(zhankaiTime, curCardPos)
		local rotato = CCRotateTo:create(zhankaiTime, curCardAngel)
		local spawn = CCSpawn:createWithTwoActions(moveTo, rotato)
		local toRightDelay = CCDelayTime:create(seqTime)
		seqTime = seqTime + seqOffset
		local flyPos = self:getPosBySideAndID(v:getSideID(), v:getPosID())
		flyPos.y = flyPos.y + 30
		local moveToRight = CCMoveTo:create(toRightTime, flyPos)
		local rotoRight = CCRotateTo:create(toRightTime, 0)
		local rightSpawn = CCSpawn:createWithTwoActions(moveToRight, rotoRight)
		local scaleToBig = CCScaleTo:create(toRightTime, 1.4)
		local rightToFinal = CCSpawn:createWithTwoActions(rightSpawn, scaleToBig)
		local rightDelay = CCDelayTime:create(0.5)
		local scaleToRight = CCScaleTo:create(0.2, 1)
		local curPos = self:getPosBySideAndID(v:getSideID(), v:getPosID())
		local moveFinalPos = CCMoveTo:create(0.2, curPos)
		local toFinalSpawn = CCSpawn:createWithTwoActions(scaleToRight, moveFinalPos)
		local shakeFunc = CCCallFunc:create(function ()
			self:shake(1)
			finalCount = finalCount + 1
			if finalCount == cardNum then
				self:cardWalk()
			end
		end)
		local seq = transition.sequence({
		delay,
		fromBack,
		spawn,
		toRightDelay,
		rightToFinal,
		rightDelay,
		toFinalSpawn,
		shakeFunc
		})
		v:runAction(seq)
		cardCount = cardCount + 1
	end
end

return BattleLayer