local URGENCY_BROADCAST_ZORDER = 1130
local HUODONG_TAG = 113
local HUODONG_ZORDER = 113
local kUpdateChatTime = 60

require("game.GameConst")
require("game.guild.utility.GuildGameConst")
ccb = ccb or {}
ccb.mainMenuAni = {}

local MainMenuLayer = class("MainMenuLayer", function ()
	return display.newLayer()
end)

MainMenuLayer.tutoBtns = {}
MainMenuLayer.HongBaoState = {RECEIVED = -1, EXPIRED = -2}

function MainMenuLayer:ctor(params)
	self:setNodeEventEnabled(true)
	self._params = params
	self.scheduler = nil
	addbackevent(self)
	self.blackLayer = display.newColorLayer(cc.c4b(0, 0, 0, 0))
	self:addChild(self.blackLayer)
	local proxy = CCBProxy:create()
	local rootnode = rootnode or {}
	local ccb_mm_name = "ccbi/mainmenu/mainmenu.ccbi"
	local curTime = tonumber(os.date("%H", os.time()))
	local GameDevice = require("sdk.GameDevice")
	if curTime > 18 or curTime < 6 then
		ccb_mm_name = "ccbi/mainmenu/mainmenu_night.ccbi"
	end
	local node = CCBuilderReaderLoad(ccb_mm_name, proxy, rootnode)
	node:setPosition(0, display.cy)
	self:addChild(node)
	self.moveBg = rootnode.tag_earth
	local homeBg2oraginalX = rootnode.homgBg2:getPositionX()
	local homeBg2oraginalY = rootnode.homgBg2:getPositionY()
	local homeBg3oraginalX = rootnode.homgBg3:getPositionX()
	local homeBg3oraginalY = rootnode.homgBg3:getPositionY()
	self.acceLayer = rootnode.controlLayer
	node = CCBuilderReaderLoad("ccbi/mainmenu/mm_top_layer.ccbi", proxy, rootnode)
	self:addChild(node)
	self.info_box = rootnode.info_box
	self.topFrame = rootnode.tag_zhanli
	self.playerInfoNode = rootnode
	self.timeLabel = rootnode.tag_time
	local lastX = 0
	local isTouchMove = true
	local curMoveNum = 0
	self.bottom = require("game.scenes.BottomLayer").new()
	self:addChild(self.bottom, 100)
	self:bottomBtns_2(self.bottom:getContentSize().height * 1.15)
	if (device.platform == "windows" or device.platform == "mac") and ENABLE_CHEAT == true then
		local cheatLayer = require("game.scenes.cheatMenuLayer").new()
		self:addChild(cheatLayer, 10000)
	end
	if (CSDKShell.getYAChannelID() == CHANNELID.IOS_APP_HANS or CSDKShell.getYAChannelID() == CHANNELID.IOS_EW_APP_HANS) and game.player:getAppOpenData().appstore == APPOPEN_STATE.close then
		local adSprite = display.newSprite("logo/logo_ad.png")
		adSprite:setPosition(self._rootnode.tag_pet:getContentSize().width / 2, self._rootnode.tag_pet:getContentSize().height / 2)
		self._rootnode.tag_pet:addChild(adSprite)
	end
	
	local bigMapID
	if MapModel:getCurrentBigMapID() ~= 0 then
		bigMapID = MapModel:getCurrentBigMapID()
	end
	
	MapModel:requestMapData(bigMapID)
	
	RequestHelper.formation.list({
	m = "fmt",
	a = "list",
	pos = "0",
	param = {},
	callback = function (data)
		game.player.m_formation = data
		game.player.addCulianAttr()
	end
	})
	
	RequestHelper.getEquipList({
	callback = function (data)
		game.player:setEquipments(data["1"])
		--dump(data)
	end
	})
	
	self._rootnode.tag_lingjiang_node:setVisible(false)
	self.scheduler = require("framework.scheduler")
end

function MainMenuLayer:updateFriendActIcon()
	if GameModel.isFriendActive() then
		self._rootnode.friend_red_point:setVisible(true)
	else
		self._rootnode.friend_red_point:setVisible(false)
	end
end

function MainMenuLayer:playMusic()
	GameAudio.playMainmenuMusic(true)
end

function MainMenuLayer:updateInfo()
	local function callBack()
		self:refreshNotice()
	end
	game.player:updateBaseData(callBack)
end


function MainMenuLayer:onEnter(param)
	self:regNotice()
	CCArmatureDataManager:purge()
	display.removeUnusedSpriteFrames()
	
	self.showNote = self._params.showNote
	ResMgr.setTimeScale(1)
	
	--print("~~~~~~~~~~~~~~~~~亲  测  源 码 网  w w w. q  c y m  w .c o m~~~~~~进入_MainMenuLayer:onEnter")
	if ccb.mainMenuAni ~= nil and ccb.mainMenuAni.mAnimationManager ~= nil then
		ccb.mainMenuAni.mAnimationManager:runAnimationsForSequenceNamed("anim")
	end
	
	--[[if self.bottom ~= nil then
	self.bottom:removeFromParent()
	self.bottom = require("game.scenes.BottomLayer").new()
	self:addChild(self.bottom, 100)
	end]]
	
	self.bottom:addTutoBtns()
	self:addTutoBtns()
	TutoMgr.removeBtn("zhenrong_btn_shouye")
	
	--local broadcastBg = self.playerInfoNode.broadcast_tag
	game.broadcast:reSet(self.playerInfoNode.broadcast_tag)
	
	collectgarbage("collect")
	
	self:updateInfo()
	
	local function getUnRead()
		GameRequest.chat.getUnRead({
		name = game.player:getPlayerName(),
		type = "1",
		callback = function (data)
			game.player:setChatNewNum(data.worldUnreadNum or 0)
			PostNotice(NoticeKey.MainMenuScene_chatNewNum)
			game.player.hb_activityisopen = data.redPacketState == 1
			if game.player.hb_activityisopen then
				game.player:updateHongBao(function ()
					self:checkIsShowHongBao()
				end)
			else
				self:checkIsShowHongBao()
			end
			local param = {}
			param.sleepState = data.sleepState
			param.bossState = data.bossState
			param.limitCardstate = data.limitCardstate
			param.unionBossState = data.unionBossState
			param.bbqState = data.bbqState
			param.caiquan = data.caiquan
			param.yabiao = data.yabiao
			param.rouletteStatus = data.rouletteStatus
			param.mazeState = data.mazeState
			param.LimitShopState = data.LimitShopState
			param.CreditShopState = data.CreditShopState
			param.fishOpenState = data.fishOpenState
			param.luckOpenState = data.luckOpenState
			game.player:updateMainMenu(param)
			if data.unionBossState == GUILD_QL_CHALLENGE_STATE.hasOpen then
				game.player:getGuildMgr():setGuildInfo({
				id = data.unionId
				})
			end
			self:UpdateQuickAccess()
		end
		})
	end
	
	getUnRead()
	self.schedulerUnread = self.scheduler.scheduleGlobal(getUnRead, kUpdateChatTime, false)
	self:playMusic()
	local str = GetSystemTime()
	self.timeLabel:setString(str)
	local function update(...)
		local str = GetSystemTime()
		self.timeLabel:setString(str)
		if game.player.m_isShowOnlineReward and self.onlineRewardTime ~= nil and self.onlineRewardTime > 0 then
			self.onlineRewardTime = self.onlineRewardTime - 1
			self._rootnode.tag_onlineTimeLbl:setString(format_time(self.onlineRewardTime))
			self._rootnode.online_notice:setVisible(false)
			self:createParticalEff(self._rootnode.tag_zaixian_node, false)
			if self.onlineRewardTime <= 0 then
				self._rootnode.tag_onlineTimeLbl:setVisible(false)
				self._rootnode.tag_onlineCanGet:setVisible(true)
				self._rootnode.online_notice:setVisible(true)
				self._rootnode.online_num:setString("1")
				self:createParticalEff(self._rootnode.tag_zaixian_node, true)
			end
		end
		if game.player.hb_activityisopen then
			if 0 < game.player.hb_lasttime then
				game.player.hb_lasttime = game.player.hb_lasttime - 1
				if game.player.hb_lasttime == 0 then
					game.player:updateHongBao()
				end
			end
			if 0 < game.player.hb_livetime then
				game.player.hb_livetime = game.player.hb_livetime - 1
				if game.player.hb_livetime == 0 then
					game.player:updateHongBao()
				end
			end
			self:checkIsShowHongBao()
		end
	end
	
	self.schedulerUpdateTimeLabel = self.scheduler.scheduleGlobal(update, 1, false)
	ResMgr.createBefTutoMask(self)
	game.urgencyBroadcast:checkAndShow()
	
	--公告
	if self.showNote ~= nil and self.showNote == true and #game.player.m_gamenote > 0 then
		local noteLayer = require("game.Huodong.GameNote").new()
		game.runningScene:addChild(noteLayer, GAMENOTE_ZORDER, HUODONG_TAG)
	end
	
	GameModel.refreshNotice()
	
	if game.player:getAppOpenData().zaixian == APPOPEN_STATE.close then
		self._rootnode.tag_zaixian_node:setVisible(false)
	else
		self._rootnode.tag_zaixian_node:setVisible(true)
	end
	
	if game.player:getAppOpenData().kaifu == APPOPEN_STATE.close then
		self._rootnode.tag_kaifu_node:setVisible(false)
	else
		self._rootnode.tag_kaifu_node:setVisible(true)
	end
	
	if game.player:getAppOpenData().dengji == APPOPEN_STATE.close then
		self._rootnode.tag_dengji_node:setVisible(false)
	else
		self._rootnode.tag_dengji_node:setVisible(true)
	end
	
	if game.player:getAppOpenData().chengzhang == APPOPEN_STATE.close then
		self._rootnode.tag_chengzhangzhilu:setVisible(false)
	else
		self._rootnode.tag_chengzhangzhilu:setVisible(true)
	end
	
	if game.player:getAppOpenData().kaifukuanghuan == APPOPEN_STATE.close then
	else
	end
	
	if game.player:getAppOpenData().huodong == APPOPEN_STATE.close then
		self._rootnode.tag_jingcai_node:setVisible(false)
	else
		self._rootnode.tag_jingcai_node:setVisible(true)
	end
	
	if game.player:getAppOpenData().shouchong == APPOPEN_STATE.close then
		self._rootnode.tag_shouchong:setVisible(false)
	else
		self._rootnode.tag_shouchong:setVisible(true)
	end
	
	if game.player:getAppOpenData().chongwu == APPOPEN_STATE.close then
		self._rootnode.tag_pet:setVisible(false)
	else
		self._rootnode.tag_pet:setVisible(true)
	end
	
	self:checkMailTip()
	self:checkKuangHuanGou()
	self:checkKaiFuKuangHuan()
	self:checkHeFuKuangHuan()
	self:checkCJQiTianLe()
	self:checkIsShowShouchong()
	self:checkOnlineReward()
	self:checkLevelReward()
	self:checkKaifuReward()
	self:checkIsShowHongBao()
	
	self:rePostionItems()
	
	
	TutoMgr.active()
	self._params = nil
end

function MainMenuLayer:regNotice()
	
	RegNotice(self, handler(self, MainMenuLayer.refreshPlayerBoard), NoticeKey.MainMenuScene_Update)
	
	RegNotice(self, function ()
		self.bottom:setVisible(false)
	end,
	NoticeKey.MAINSCENE_HIDE_BOTTOM_LAYER)
	
	RegNotice(self, function ()
		self.bottom:setVisible(true)
	end,
	NoticeKey.MAINSCENE_SHOW_BOTTOM_LAYER)
	
	RegNotice(self, handler(self, MainMenuLayer.checkOnlineReward), NoticeKey.MainMenuScene_OnlineReward)
	RegNotice(self, handler(self, MainMenuLayer.checkRewardCenter), NoticeKey.MainMenuScene_RewardCenter)
	
	RegNotice(self, function ()
		if game.player:getAppOpenData().chengzhang == APPOPEN_STATE.open and ENABLE_DAILY_TASK == true then
			self:checkDiaLayTask()
		end
	end,
	NoticeKey.MainMenuScene_ChengZhangZhilu)
	
	RegNotice(self, handler(self, MainMenuLayer.checkQiandao), NoticeKey.MainMenuScene_Qiandao)
	
	RegNotice(self, function ()
		if game.player:getAppOpenData().dengji == APPOPEN_STATE.open then
			self:checkLevelReward()
		end
	end,
	NoticeKey.MainMenuScene_DengjiLibao)
	RegNotice(self, function ()
		if game.player:getAppOpenData().kaifu == APPOPEN_STATE.open then
			self:checkKaifuReward()
		end
	end,
	NoticeKey.MainMenuScene_KaifuLibao)
	RegNotice(self, function ()
		if game.player:getAppOpenData().appstore == APPOPEN_STATE.open then
			self:checkKaiFuKuangHuan()
			self:checkHeFuKuangHuan()
			self:checkCJQiTianLe()
			self:checkKuangHuanGou()
		end
	end,
	NoticeKey.MainMenuScene_kaifukuanghuan)
	
	RegNotice(self, function ()
		if game.player:getAppOpenData().shouchong == APPOPEN_STATE.open then
			self:checkIsShowShouchong()
		end
	end,
	NoticeKey.MainMenuScene_Shouchong)
	
	RegNotice(self, handler(self, MainMenuLayer.checkChatNewNum), NoticeKey.MainMenuScene_chatNewNum)
	RegNotice(self, handler(self, MainMenuLayer.checkChallengeNotice), NoticeKey.MainMenuScene_challenge)
	RegNotice(self, handler(self, MainMenuLayer.playMusic), NoticeKey.MainMenuScene_Music)
	RegNotice(self, handler(self, MainMenuLayer.checkUrgencyBroadcast), NoticeKey.MainMenuScene_UrgencyBroadcast)
	RegNotice(self, handler(self, MainMenuLayer.checkMailTip), NoticeKey.MAIL_TIP_UPDATE)
	RegNotice(self, handler(self, MainMenuLayer.updateFriendActIcon), NoticeKey.UP_FRIEND_ICON_ACT)
	RegNotice(self, handler(self, MainMenuLayer.checkGuildApplyNum), NoticeKey.CHECK_GUILD_APPLY_NUM)
	RegNotice(self, handler(self, MainMenuLayer.updateInfo), NoticeKey.APP_ENTER_FOREGROUND_EVENT_IN_GAME)
	
end

function MainMenuLayer:rePostionItems()
	local xPos = self._rootnode.tag_zaixian_node:getPositionX()
	local width = 100
	if self._rootnode.tag_zaixian_node:isVisible() == true then
		xPos = xPos + width
	end
	if self._rootnode.tag_kaifu_node:isVisible() == true then
		self._rootnode.tag_kaifu_node:setPositionX(xPos)
		xPos = xPos + width
	end
	if self._rootnode.tag_dengji_node:isVisible() == true then
		self._rootnode.tag_dengji_node:setPositionX(xPos)
		xPos = xPos + width
	end
	if self._rootnode.tag_chengzhangzhilu:isVisible() == true then
		self._rootnode.tag_chengzhangzhilu:setPositionX(xPos)
		xPos = xPos + width
	end
end

--帮派申请数量
function MainMenuLayer:checkGuildApplyNum()
	if game.player:getGuildApplyNum() > 0 then
		self._rootnode.guild_notice:setVisible(true)
	else
		self._rootnode.guild_notice:setVisible(false)
	end
end

--邮件提醒
function MainMenuLayer:checkMailTip()
	if game.player:hasMailTip() == true then
		self._rootnode.mail_notice:setVisible(true)
		self._rootnode.mail_notice_bottom:setVisible(true)
	else
		self._rootnode.mail_notice:setVisible(false)
		self._rootnode.mail_notice_bottom:setVisible(false)
	end
end

function MainMenuLayer:refreshNotice()
	PostNotice(NoticeKey.MainMenuScene_Update)
	PostNotice(NoticeKey.MainMenuScene_OnlineReward)
	PostNotice(NoticeKey.MainMenuScene_RewardCenter)
	PostNotice(NoticeKey.MainMenuScene_Qiandao)
	PostNotice(NoticeKey.MainMenuScene_DengjiLibao)
	PostNotice(NoticeKey.MainMenuScene_KaifuLibao)
	PostNotice(NoticeKey.BottomLayer_Chouka)
	PostNotice(NoticeKey.BottomLayer_JiangHu)
	PostNotice(NoticeKey.BottomLayer_ZhenRong)
	PostNotice(NoticeKey.MainMenuScene_challenge)
	PostNotice(NoticeKey.MainMenuScene_Shouchong)
	PostNotice(NoticeKey.MainMenuScene_ChengZhangZhilu)
	PostNotice(NoticeKey.MAIL_TIP_UPDATE)
	PostNotice(NoticeKey.CHECK_GUILD_APPLY_NUM)
	PostNotice(NoticeKey.MainMenuScene_equipments)
	PostNotice(NoticeKey.MainMenuScene_xiakes)
	PostNotice(NoticeKey.MainMenuScene_kaifukuanghuan)
	PostNotice(NoticeKey.MainMenuScene_pet)
end

function MainMenuLayer:checkIsShowShouchong()
	if game.player:getIsHasBuyGold() == true or game.player:getAppOpenData().shouchong == APPOPEN_STATE.close then
		self._rootnode.tag_shouchong:setVisible(false)
	elseif game.player:getIsHasBuyGold() == false then
		self._rootnode.tag_shouchong:setVisible(true)
	end
end

function MainMenuLayer:checkUrgencyBroadcast()
	if game.urgencyBroadcast:getParent() ~= nil then
		game.urgencyBroadcast:removeFromParentAndCleanup(true)
	end
	game.urgencyBroadcast:setIsShow(true)
	game.urgencyBroadcast:setPosition(display.cx, display.cy)
	self:addChild(game.urgencyBroadcast, URGENCY_BROADCAST_ZORDER)
end

function MainMenuLayer:checkChallengeNotice()
	if game.player:getIsShowChallengeNotice() then
		self._rootnode.challenge_notice:setVisible(true)
	else
		self._rootnode.challenge_notice:setVisible(false)
	end
end
function MainMenuLayer:checkChatNewNum()
	if game.player:getChatNewNum() > 0 then
		self._rootnode.chat_notice:setVisible(true)
		self:createNoticeFadeEff(self._rootnode.chat_eff, true)
	else
		self._rootnode.chat_notice:setVisible(false)
		self:createNoticeFadeEff(self._rootnode.chat_eff, false)
	end
end
function MainMenuLayer:checkOnlineReward()
	if game.player:getAppOpenData().zaixian == APPOPEN_STATE.open then
		if not game.player.m_isShowOnlineReward then
			self._rootnode.tag_zaixian_node:setVisible(false)
			self:createParticalEff(self._rootnode.tag_zaixian_node, false)
		else
			self._rootnode.tag_zaixian_node:setVisible(true)
			if game.player.m_onlineRewardTime <= 0 then
				self._rootnode.tag_onlineCanGet:setVisible(true)
				self._rootnode.tag_onlineTimeLbl:setVisible(false)
				self._rootnode.online_notice:setVisible(true)
				self._rootnode.online_num:setString("1")
				self:createParticalEff(self._rootnode.tag_zaixian_node, true)
			else
				self.onlineRewardTime = game.player.m_onlineRewardTime
				self._rootnode.tag_onlineTimeLbl:setString(format_time(self.onlineRewardTime))
				self._rootnode.tag_onlineTimeLbl:setVisible(true)
				self._rootnode.tag_onlineCanGet:setVisible(false)
				self._rootnode.online_notice:setVisible(false)
				self:createParticalEff(self._rootnode.tag_zaixian_node, false)
			end
		end
	end
end
function MainMenuLayer:checkIsShowHongBao()
	if game.player:getAppOpenData().redbag == APPOPEN_STATE.open and game.player.hb_activityisopen then
		if game.player.hb_lasttime == -2 then
			self._rootnode.tag_hongbao_node:setVisible(false)
			return
		end
		self._rootnode.tag_hongbao_node:setVisible(true)
		if game.player.hb_livetime > 0 then
			game.player.hb_isshake = true
			self._rootnode.tag_hongbaoTimeLbl:setVisible(false)
		elseif game.player.hb_lasttime > 0 then
			game.player.hb_isshake = false
			self._rootnode.tag_hongbaoTimeLbl:setVisible(true)
			self._rootnode.tag_hongbaoTimeLbl:setString(format_time(game.player.hb_lasttime))
		end
		self:createParticalEff(self._rootnode.tag_hongbao_node, game.player.hb_isshake)
	else
		self._rootnode.tag_hongbao_node:setVisible(false)
	end
	PostNotice(NoticeKey.MainMenuScene_kaifukuanghuan)
end

function MainMenuLayer:openHongBao()
	if game.player.hb_livetime == MainMenuLayer.HongBaoState.RECEIVED then
		show_tip_label(data_error_error[2112].prompt)
		return
	end
	if game.player.hb_livetime == MainMenuLayer.HongBaoState.EXPIRED then
		show_tip_label(data_error_error[2113].prompt)
		return
	end
	local function _callback(data)
		dump(data)
		game.player.hb_lasttime = tonumber(data.rtnObj.endTime)
		game.player.hb_livetime = tonumber(data.rtnObj.residueRewardTime)
		self:checkIsShowHongBao()
		if data.rtnObj.errorCode and data.rtnObj.errorCode ~= 0 then
			show_tip_label(data_error_error[data.rtnObj.errorCode].prompt)
			return
		end
		local getdata = data.rtnObj.proList
		local dataTemp = {}
		for k, v in pairs(getdata) do
			local temp = {}
			temp.id = v.id
			temp.num = v.n
			temp.type = v.t
			temp.iconType = ResMgr.getResType(v.t)
			temp.name = require("data.data_item_item")[v.id].name
			table.insert(dataTemp, temp)
			if v.id == 1 then
				game.player:setGold(game.player.m_gold + v.n)
				self.playerInfoNode.label_gold:setString(game.player.m_gold)
			elseif v.id == 2 then
				game.player:setSilver(game.player.m_silver + v.n)
				self.playerInfoNode.label_silver:setString(game.player.m_silver)
			end
		end
		self:createHongBaoArmature(dataTemp)
	end
	local _error = function (err)
	end
	local msg = {m = "activity", a = "redPackets"}
	RequestHelper.request(msg, _callback, _error)
end

--红包
function MainMenuLayer:createHongBaoArmature(dataTemp)
	local function secondArm()
		local function callback()
			if CCDirector:sharedDirector():getRunningScene():getChildByTag(11111) then
				CCDirector:sharedDirector():getRunningScene():removeChildByTag(11111)
			end
			if CCDirector:sharedDirector():getRunningScene():getChildByTag(22222) then
				CCDirector:sharedDirector():getRunningScene():removeChildByTag(22222)
			end
			if self:getChildByTag(135555) then
				self:removeChildByTag(135555)
			end
		end
		local msgBox = require("game.Huodong.RewardMsgBox").new({
		title = common:getLanguageString("@RedbagInfo"),
		cellDatas = dataTemp,
		confirmFunc = callback
		})
		CCDirector:sharedDirector():getRunningScene():addChild(msgBox, 135555)
		local bgEffect = ResMgr.createArma({
		resType = ResMgr.UI_EFFECT,
		armaName = "xiakejinjie_xunhuan",
		isRetain = false
		})
		bgEffect:setScale(0.6)
		bgEffect:setPosition(display.cx, display.cy)
		CCDirector:sharedDirector():getRunningScene():addChild(bgEffect, 10, 22222)
	end
	local winSize = CCDirector:sharedDirector():getWinSize()
	local mask = CCLayerColor:create()
	mask:setContentSize(winSize)
	mask:setColor(cc.c3b(0, 0, 0))
	mask:setOpacity(150)
	mask:setAnchorPoint(cc.p(0, 0))
	mask:setTouchEnabled(true)
	self:addChild(mask, 1, 135555)
	local bgEffect = ResMgr.createArma({
	resType = ResMgr.UI_EFFECT,
	armaName = "xiakejinjie_qishou",
	isRetain = false,
	frameFunc = secondArm,
	finishFunc = function ()
	end
	})
	bgEffect:setScale(0.6)
	bgEffect:setPosition(display.cx, display.cy)
	CCDirector:sharedDirector():getRunningScene():addChild(bgEffect, 10, 11111)
end

--领奖中心
function MainMenuLayer:checkRewardCenter()
	if not game.player.m_isShowRewardCenter then
		self._rootnode.tag_lingjiang_node:setVisible(false)
		self:createParticalEff(self._rootnode.tag_lingjiang_node, false)
	else
		self._rootnode.tag_lingjiang_node:setVisible(true)
		if game.player:getRewardcenterNum() > 0 then
			self._rootnode.rewardcenter_notice:setVisible(true)
			self._rootnode.rewardcenter_num:setString(game.player:getRewardcenterNum())
			self:createParticalEff(self._rootnode.tag_lingjiang_node, true)
		else
			self._rootnode.rewardcenter_notice:setVisible(false)
			self:createParticalEff(self._rootnode.tag_lingjiang_node, false)
		end
	end
end

function MainMenuLayer:checkDiaLayTask()
	local red_node = self._rootnode.tag_chengzhangzhilu:getChildByTag(111)
	if not game.player.m_isShowChengzhang or game.player:getAppOpenData().chengzhang == APPOPEN_STATE.close then
		if red_node then
			red_node:removeFromParent()
		end
	else
		if not red_node then
			display.addSpriteFramesWithFile("ui/ui_toplayer.plist", "ui/ui_toplayer.pvr.ccz")
			local tagnew = display.newSprite("#toplayer_mail_tip.png")
			tagnew:setPosition(cc.p(85, 85))
			self._rootnode.tag_chengzhangzhilu:addChild(tagnew, 0, 111)
			red_node = self._rootnode.tag_chengzhangzhilu:getChildByTag(111)
		end
		local bHasOpen, prompt = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.DailyTask, game.player:getLevel(), game.player:getVip())
		if not bHasOpen then
			red_node:setVisible(false)
		else
			red_node:setVisible(true)
		end
	end
end

function MainMenuLayer:checkQiandao()
	local bHasOpen, _ = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.QianDao, game.player:getLevel(), game.player:getVip())
	if bHasOpen and game.player:getQiandaoNum() > 0 then
		self._rootnode.qiandao_notice:setVisible(true)
		self._rootnode.qiandao_num:setString(game.player:getQiandaoNum())
		self:createNoticeFadeEff(self._rootnode.qiandao_eff, true)
	else
		self._rootnode.qiandao_notice:setVisible(false)
		self:createNoticeFadeEff(self._rootnode.qiandao_eff, false)
	end
	if game.player:getAppOpenData().qiandao == APPOPEN_STATE.open then
		self._rootnode.tag_qiandao_node:setVisible(true)
	else
		self._rootnode.tag_qiandao_node:setVisible(false)
	end
end

function MainMenuLayer:checkLevelReward()
	if not game.player.m_isSHowDengjiLibao or game.player:getAppOpenData().dengji == APPOPEN_STATE.close then
		self._rootnode.tag_dengji_node:setVisible(false)
		self:createParticalEff(self._rootnode.tag_dengji_node, false)
	else
		self._rootnode.tag_dengji_node:setVisible(true)
		if game.player:getDengjilibao() > 0 then
			self._rootnode.dengji_notice:setVisible(true)
			self._rootnode.dengji_num:setString(game.player:getDengjilibao())
			self:createParticalEff(self._rootnode.tag_dengji_node, true)
		else
			self._rootnode.dengji_notice:setVisible(false)
			self:createParticalEff(self._rootnode.tag_dengji_node, false)
		end
	end
end

function MainMenuLayer:checkKaiFuKuangHuan()
	if not game.player.m_isKaiFuKuangHuan then
		self._rootnode.tag_kaifukuanghuan_node:setVisible(false)
		self:createParticalEff(self._rootnode.tag_kaifukuanghuan_node, false)
		TutoMgr.removeBtn("main_scene_qitianle_btn")
		self.tutoBtns.main_scene_qitianle_btn = nil
	else
		self._rootnode.tag_kaifukuanghuan_node:setVisible(true)
		if game.player:getkuangHuanNum() > 0 then
			self._rootnode.kuanghuan_notice:setVisible(true)
			self._rootnode.kuanhuan_num:setString(game.player:getkuangHuanNum())
			self:createParticalEff(self._rootnode.tag_kaifukuanghuan_node, true)
		else
			self._rootnode.kuanghuan_notice:setVisible(false)
			self:createParticalEff(self._rootnode.tag_kaifukuanghuan_node, false)
		end
	end
end

function MainMenuLayer:checkKuangHuanGou()
	self._rootnode.kuanghuangou:removeAllChildrenWithCleanup(true)
	local size = self._rootnode.kuanghuangou:getContentSize()
	local kuanghuangou = KuangHuanModel:getKuangHuanGou()
	local posX = 95
	if self._rootnode.tag_hongbao_node:isVisible() == true then
		posX = 0
	end
	if #kuanghuangou > 0 then
		for i, v in ipairs(kuanghuangou) do
			local function callback(type)
				local layer = require("game.kuanghuangou.KuangHuanGouView").new({type = type})
				CCDirector:sharedDirector():getRunningScene():addChild(layer, 1000)
				self._kaifuInstance = layer
			end
			local topIconItem = require("game.scenes.TopIconItem").new({
			callback = callback,
			type = v.t,
			num = game.player.m_kuangHuanGouNum[tostring(v.t)]
			})
			topIconItem:setPosition(size.width + posX - 53 - (i - 1) * 100, size.height / 2)
			self:createParticalEff(topIconItem, true)
			self._rootnode.kuanghuangou:addChild(topIconItem)
		end
	end
end

--七天乐
function MainMenuLayer:checkCJQiTianLe()
	if not game.player.m_isCJQiTianLe then
		TutoMgr.removeBtn("main_scene_qitianle_btn")
		self._rootnode.tag_cjqitianle_node:setVisible(false)
		self:createParticalEff(self._rootnode.tag_cjqitianle_node, false)
	else
		TutoMgr.addBtn("main_scene_qitianle_btn", self._rootnode.tag_cjqitianle)
		self._rootnode.tag_cjqitianle_node:setVisible(true)
		require("game.KaiFuHuiKui.KaiFuConst")
		local jieriType = game.player:getAppOpenData().seven_day
		resetctrbtnimage(self._rootnode.tag_cjqitianle, "ui/ui_jieri7tian/" .. JieRi_head_name[jieriType] .. "_7day_icon.png")
		if game.player:getCJQiTianLeNum() > 0 then
			self._rootnode.cjqitianle_notice:setVisible(true)
			self._rootnode.cjqitianle_num:setString(game.player:getCJQiTianLeNum())
			self:createParticalEff(self._rootnode.tag_cjqitianle_node, true)
		else
			self._rootnode.cjqitianle_notice:setVisible(false)
			self:createParticalEff(self._rootnode.tag_cjqitianle_node, false)
		end
	end
end

--合服狂欢
function MainMenuLayer:checkHeFuKuangHuan()
	if not game.player.m_isHeFuKuangHuan or game.player:getAppOpenData().kaifu == APPOPEN_STATE.close then
		self._rootnode.tag_hefukuanghuan_node:setVisible(false)
		self:createParticalEff(self._rootnode.tag_hefukuanghuan_node, false)
	else
		self._rootnode.tag_hefukuanghuan_node:setVisible(true)
		require("game.KaiFuHuiKui.KaiFuConst")
		resetctrbtnimage(self._rootnode.tag_hefukuanghuan, "ui/ui_jieri7tian/" .. JieRi_head_name[1] .. "_7day_icon.png")
		if game.player:getHeFukuangHuanNum() > 0 then
			self._rootnode.hefukuanghuan_notice:setVisible(true)
			self._rootnode.hefukuanhuan_num:setString(game.player:getHeFukuangHuanNum())
			self:createParticalEff(self._rootnode.tag_hefukuanghuan_node, true)
		else
			self._rootnode.hefukuanghuan_notice:setVisible(false)
			self:createParticalEff(self._rootnode.tag_hefukuanghuan_node, false)
		end
	end
end

--开服奖励
function MainMenuLayer:checkKaifuReward()
	if not game.player.m_isShowKaifuLibao or game.player:getAppOpenData().kaifu == APPOPEN_STATE.close then
		self._rootnode.tag_kaifu_node:setVisible(false)
		self:createNoticeFadeEff(self._rootnode.kaifu_eff, false)
	else
		self._rootnode.tag_kaifu_node:setVisible(true)
		require("game.KaiFuHuiKui.KaiFuConst")
		resetctrbtnimage(self._rootnode.tag_kaifukuanghuan, "ui/ui_jieri7tian/" .. JieRi_head_name[0] .. "_7day_icon.png")
		if 0 < game.player:getKaifuLibao() then
			self._rootnode.kaifu_notice:setVisible(true)
			self._rootnode.kaifu_num:setString(game.player:getKaifuLibao())
			self:createNoticeFadeEff(self._rootnode.kaifu_eff, true)
		else
			self._rootnode.kaifu_notice:setVisible(false)
			self:createNoticeFadeEff(self._rootnode.kaifu_eff, false)
		end
	end
end

function MainMenuLayer:createNormalNoticeEff(effNode, isShow)
	effNode:stopAllActions()
	if isShow then
		effNode:setVisible(true)
		local delayTime = 3
		effNode:runAction(CCRepeatForever:create(transition.sequence({
		CCRotateBy:create(4, 144)
		})))
	else
		effNode:setVisible(false)
	end
end

function MainMenuLayer:createParticalEff(effNode, isShow)
	effNode:stopAllActions()
	effNode:setRotation(0)
	effNode:removeChild(effNode.particle)
	if isShow then
		local function addParticel(node)
			local particle = CCParticleSystemQuad:create("ccs/particle/ui/p_zaixianlibao.plist")
			particle:setPosition(node:getContentSize().width / 2, node:getContentSize().height * 0.7)
			node:addChild(particle, 1000)
			effNode.particle = particle
		end
		local rotateSeq = transition.sequence({
		CCRotateTo:create(0.05, 10),
		CCRotateTo:create(0.05, 0),
		CCRotateTo:create(0.05, -10),
		CCRotateTo:create(0.05, 0)
		})
		local seq = transition.sequence({
		rotateSeq,
		rotateSeq,
		rotateSeq,
		rotateSeq,
		CCDelayTime:create(3)
		})
		local spawn = CCSpawn:createWithTwoActions(seq, CCCallFuncN:create(addParticel))
		effNode:runAction(CCRepeatForever:create(spawn))
	end
end

function MainMenuLayer:createNoticeFadeEff(effNode, isShow)
	effNode:stopAllActions()
	if isShow then
		effNode:setVisible(true)
		local delayTime = 3
		local fadeSeq = transition.sequence({
		CCFadeTo:create(0.5, 100),
		CCFadeTo:create(0.5, 255)
		})
		effNode:runAction(CCRepeatForever:create(transition.sequence({
		fadeSeq,
		fadeSeq,
		fadeSeq
		})))
	else
		effNode:setVisible(false)
	end
end

function MainMenuLayer:refreshLabel()
	if checkint(self._goldLabel:getString()) ~= game.player:getGold() then
		self._goldLabel:runAction(transition.sequence({
		CCScaleTo:create(0.2, 1.5),
		CCCallFunc:create(function ()
			self._goldLabel:setString(tostring(game.player:getGold()))
		end),
		CCScaleTo:create(0.2, 1)
		}))
	end
	if checkint(self._silverLabel:getString()) ~= game.player:getSilver() then
		self._silverLabel:runAction(transition.sequence({
		CCScaleTo:create(0.2, 1.5),
		CCCallFunc:create(function ()
			self._silverLabel:setString(tostring(game.player:getSilver()))
		end),
		CCScaleTo:create(0.2, 1)
		}))
	end
end

function MainMenuLayer:BlackLayerFadeIn()
	dump("BlackLayer FadeIn")
	transition.fadeTo(self.blackLayer, {time = 0.5, opacity = 100})
end

function MainMenuLayer:BlackLayerFadeOut()
	dump("BlackLayer FadeOut")
	transition.fadeTo(self.blackLayer, {time = 0.5, opacity = 0})
end

function MainMenuLayer:addTutoBtns()
	for k, v in pairs(self.tutoBtns) do
		TutoMgr.addBtn(k, v)
	end
end

function MainMenuLayer:bottomBtns_2(posY)
	local proxy = CCBProxy:create()
	self._rootnode = self._rootnode or {}
	local node = CCBuilderReaderLoad("ccbi/mainmenu/bottom_icons.ccbi", proxy, self._rootnode)
	node:setPosition(0, posY)
	self:addChild(node)
	self._buttomLayer = node
	
	--更多功能按键
	local moreFuncBtn = self._rootnode.moreFunc_btn
	local moreFuncTouchNode = self._rootnode.moreFunc_touch_node
	local moreFuncNode = self._rootnode.moreFunc_node
	local function checkTouchMoreFuncNode(init)
		if init or moreFuncNode:isVisible() then
			moreFuncBtn:unselected()
			moreFuncNode:setVisible(false)
			moreFuncTouchNode:setTouchEnabled(false)
		else
			moreFuncNode:setVisible(true)
			moreFuncTouchNode:setTouchEnabled(true)
			moreFuncBtn:selected()
		end
	end
	checkTouchMoreFuncNode(true)
	--[[moreFuncTouchNode:addNodeEventListener(cc.NODE_TOUCH_CAPTURE_EVENT, function (event)
	local posX = event.x
	local posY = event.y
	local pos = moreFuncNode:convertToNodeSpace(ccp(posX, posY))
	if CCRectMake(0, 0, moreFuncNode:getContentSize().width, moreFuncNode:getContentSize().height):containsPoint(pos) == false then
		checkTouchMoreFuncNode()
	end
	end)]]
	
	moreFuncBtn:registerScriptTapHandler(function (tag)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		checkTouchMoreFuncNode()
	end)
	
	
	local tagNames = {
	"tag_shezhi",
	"tag_zhenqi",
	"tag_lianhualu",
	"tag_zhuangbei",
	"tag_xiake",
	"tag_tiaozhan",
	"tag_jingmai",
	"tag_liaotian",
	"tag_jianghulu",
	"tag_pet",
	"tag_bangpai",
	"tag_mail_bottom",
	"tag_friend",
	"tag_gonggao",
	"tag_rank_list",
	"tag_miji"
	}
	local tips = display.newSprite("#toplayer_mail_tip.png")
	tips:setPosition(self._rootnode.tag_gonggao:getContentSize().width * 0.9, self._rootnode.tag_gonggao:getContentSize().height * 0.9)
	self._rootnode.tag_gonggao:addChild(tips)
	tips:setVisible(false)
	local function onTouch(tag)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		PostNotice(NoticeKey.REMOVE_TUTOLAYER)
		if tag == tagNames[1] then
			if self:getChildByTag(HUODONG_TAG) == nil then
				local settingLayer = require("game.Setting.SettingLayer").new()
				self:addChild(settingLayer, HUODONG_ZORDER, HUODONG_TAG)
			end
		elseif tag == tagNames[2] then
			GameStateManager:ChangeState(GAME_STATE.STATE_JINGYUAN)
		elseif tag == tagNames[3] then
			GameStateManager:ChangeState(GAME_STATE.STATE_LIANHUALU)
		elseif tag == tagNames[4] then
			GameStateManager:ChangeState(GAME_STATE.STATE_EQUIPMENT)
		elseif tag == tagNames[5] then
			GameStateManager:ChangeState(GAME_STATE.STATE_XIAKE)
		elseif tag == tagNames[6] then
			GameStateManager:ChangeState(GAME_STATE.STATE_TIAOZHAN)
		elseif tag == tagNames[7] then
			GameStateManager:ChangeState(GAME_STATE.STATE_JINGMAI)
		elseif tag == tagNames[8] then
			if self:getChildByTag(HUODONG_TAG) == nil then
				RewardLayerMgr.createLayerByType(RewardLayerMgrType.chat, self, HUODONG_ZORDER, HUODONG_TAG)
			end
		elseif tag == tagNames[9] then
			GameStateManager:ChangeState(GAME_STATE.STATE_JIANGHULU)
		elseif tag == tagNames[12] then
			GameStateManager:ChangeState(GAME_STATE.STATE_MAIL)
		elseif tag == tagNames[10] then
			if (CSDKShell.getYAChannelID() == CHANNELID.IOS_APP_HANS or CSDKShell.getYAChannelID() == CHANNELID.IOS_EW_APP_HANS) and game.player:getAppOpenData().appstore == APPOPEN_STATE.close then
				CSDKShell.openAdvertisement()
			else
				GameStateManager:ChangeState(GAME_STATE.STATE_PET)
			end
		elseif tag == "tag_friend" then
			GameStateManager:ChangeState(GAME_STATE.STATE_FRIENDS)
		elseif tag == "tag_bangpai" then
			if ENABLE_GUILD == true then
				GameStateManager:ChangeState(GAME_STATE.STATE_GUILD)
			else
				show_tip_label(data_error_error[2800001].prompt)
			end
		elseif tag == "tag_gonggao" then
			GameStateManager:ChangeState(GAME_STATE.STATE_HANDBOOK)
		elseif tag == "tag_rank_list" then
			ResMgr.runFuncByOpenCheck({
			openKey = OPENCHECK_TYPE.RANK_LIST,
			openFunc = function ()
				GameStateManager:ChangeState(GAME_STATE.STATE_RANK_SCENE)
			end
			})
		elseif tag == "tag_miji" then
			local bHasOpen, prompt = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.Cheats, game.player:getLevel(), game.player:getVip())
			if not bHasOpen then
				show_tip_label(prompt)
			else
				GameStateManager:ChangeState(GAME_STATE.STATE_MIJI)
			end
		end
	end
	self.bottomIconTouch = onTouch
	for i, v in ipairs(tagNames) do
		do
			local btn = self._rootnode[tagNames[i]]
			if tagNames[i] == "tag_xiake" then
				TutoMgr.addBtn("zhujiemian_xiake_btn", btn)
				self.tutoBtns.zhujiemian_xiake_btn = btn
			end
			if tagNames[i] == "tag_tiaozhan" then
				TutoMgr.addBtn("zhujiemian_tiaozhan_btn", btn)
				self.tutoBtns.zhujiemian_tiaozhan_btn = btn
			end
			if tagNames[i] == "tag_lianhualu" then
				TutoMgr.addBtn("zhujiemian_lianhualu", btn)
				self.tutoBtns.zhujiemian_lianhualu = btn
			end
			if tagNames[i] == "tag_jingmai" then
				TutoMgr.addBtn("zhujiemian_jingmai", btn)
				self.tutoBtns.zhujiemian_jingmai = btn
			end
			btn:addHandleOfControlEvent(function (sender, eventName)
				PostNotice(NoticeKey.REMOVE_TUTOLAYER)
				onTouch(v)
				sender:setScale(1)
				sender:setHighlighted(false)
			end,
			CCControlEventTouchUpInside)
		end
	end
	self:initPlayerBoard()
	self:initTopFrame()
end

function MainMenuLayer:testData(...)
	for k, v in pairs(data_card_card) do
		local path = "hero/icon/" .. v.arr_icon[1] .. ".png"
		if io.exists(path) == false then
			dump(path)
		end
	end
end

function MainMenuLayer:initTopFrame(...)
	local proxy = CCBProxy:create()
	self._rootnode = self._rootnode or {}
	local node = CCBuilderReaderLoad("ccbi/mainmenu/top_icons.ccbi", proxy, self._rootnode)
	node:setPosition(0, self.topFrame:getPositionY() - 30)
	self.topFrame:addChild(node)
	local tagNames = {
	"tag_chengzhangzhilu",
	"tag_dengji",
	"tag_shouchong",
	"tag_jingcai",
	"tag_qiandao",
	"tag_lingjiang",
	"tag_zaixian",
	"tag_mail",
	"tag_kaifu",
	"tag_guildboss",
	"tag_kaifukuanghuan",
	"tag_hefukuanghuan",
	"tag_hongbao",
	"tag_cjqitianle"
	}
	
	self._rootnode.tag_onlineTimeLbl:setPositionY(-14)
	self._rootnode.tag_onlineCanGet:setPositionY(-14)
	self:createNoticeFadeEff(self._rootnode.jingcai_eff, true)
	
	local function onTouch(tag)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		PostNotice(NoticeKey.REMOVE_TUTOLAYER)
		if tag == tagNames[1] then
			local bHasOpen, prompt = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.DailyTask, game.player:getLevel(), game.player:getVip())
			if not bHasOpen then
				show_tip_label(prompt)
			elseif self:getChildByTag(HUODONG_TAG) == nil then
				RewardLayerMgr.createLayerByType(RewardLayerMgrType.dailyTask, self, HUODONG_ZORDER, HUODONG_TAG)
			end
		elseif tag == tagNames[2] then
			local bHasOpen, prompt = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.DengJiLiBao, game.player:getLevel(), game.player:getVip())
			if not bHasOpen then
				show_tip_label(prompt)
			elseif self:getChildByTag(HUODONG_TAG) == nil then
				RewardLayerMgr.createLayerByType(RewardLayerMgrType.levelReward, self, HUODONG_ZORDER, HUODONG_TAG)
			end
		elseif tag == tagNames[3] then
			if self:getChildByTag(HUODONG_TAG) == nil then
				local chongzhiLayer = require("game.shop.Chongzhi.ChongzhiLayer").new()
				self:addChild(chongzhiLayer, HUODONG_ZORDER, HUODONG_TAG)
			end
		elseif tag == tagNames[4] then
			GameStateManager:ChangeState(GAME_STATE.STATE_JINGCAI_HUODONG)
		elseif tag == tagNames[5] then
			local bHasOpen, prompt = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.QianDao, game.player:getLevel(), game.player:getVip())
			if not bHasOpen then
				show_tip_label(prompt)
			elseif self:getChildByTag(HUODONG_TAG) == nil then
				RewardLayerMgr.createLayerByType(RewardLayerMgrType.dailyLogin, self, HUODONG_ZORDER, HUODONG_TAG)
			end
		elseif tag == tagNames[6] then
			if self:getChildByTag(HUODONG_TAG) == nil then
				RewardLayerMgr.createLayerByType(RewardLayerMgrType.rewardCenter, self, HUODONG_ZORDER, HUODONG_TAG)
			end
		elseif tag == tagNames[7] then
			if self:getChildByTag(HUODONG_TAG) == nil then
				RewardLayerMgr.createLayerByType(RewardLayerMgrType.onlineReward, self, HUODONG_ZORDER, HUODONG_TAG)
			end
		elseif tag == tagNames[8] then
			GameStateManager:ChangeState(GAME_STATE.STATE_MAIL)
		elseif tag == tagNames[9] then
			if self:getChildByTag(HUODONG_TAG) == nil then
				RewardLayerMgr.createLayerByType(RewardLayerMgrType.kaifuReward, self, HUODONG_ZORDER, HUODONG_TAG)
			end
		elseif tag == tagNames[10] then
			GameStateManager:ChangeState(GAME_STATE.STATE_GUILD_QL_BOSS, false)
		elseif tag == tagNames[11] then
			local layer = require("game.KaiFuHuiKui.KaiFuMainView").new({
			type = KUANGHUAN_TYPE.KAIFU
			})
			CCDirector:sharedDirector():getRunningScene():addChild(layer, 1000)
			self._kaifuInstance = layer
		elseif tag == tagNames[12] then
			local layer = require("game.KaiFuHuiKui.KaiFuMainView").new({
			type = KUANGHUAN_TYPE.HEFU
			})
			CCDirector:sharedDirector():getRunningScene():addChild(layer, 1000)
			self._kaifuInstance = layer
		elseif tag == tagNames[13] then
			self:openHongBao()
		elseif tag == tagNames[14] then
			local layer = require("game.KaiFuHuiKui.KaiFuMainView").new({
			type = KUANGHUAN_TYPE.CHUNJIE
			})
			CCDirector:sharedDirector():getRunningScene():addChild(layer, 1000)
			self._kaifuInstance = layer
		end
	end
	for i, v in ipairs(tagNames) do
		do
			local btn = self._rootnode[tagNames[i]]
			if i == 5 then
				TutoMgr.addBtn("main_scene_qiandao_btn", btn)
				self.tutoBtns.main_scene_qiandao_btn = btn
			elseif i == 9 then
				TutoMgr.addBtn("main_scene_kaifulibao_btn", btn)
				self.tutoBtns.main_scene_kaifulibao_btn = btn
			elseif i == 2 then
				TutoMgr.addBtn("main_scene_dengjilibao_btn", btn)
				self.tutoBtns.main_scene_dengjilibao_btn = btn
			elseif i == 11 then
				TutoMgr.addBtn("main_scene_qitianle_btn", btn)
				self.tutoBtns.main_scene_qitianle_btn = btn
			end
			
			btn:addHandleOfControlEvent(function (sender, eventName)
				onTouch(v)
				sender:setScale(1)
				sender:setHighlighted(false)
			end,
			CCControlEventTouchUpInside)
			
		end
	end
end

function MainMenuLayer:refreshPlayerBoard(...)
	self.playerInfoNode.tag_lv:setString(game.player.m_level)
	self.playerInfoNode.label_vip:setString(game.player.m_vip)
	self.playerInfoNode.label_silver:setString(game.player.m_silver)
	self.playerInfoNode.label_gold:setString(game.player.m_gold)
	self.playerInfoNode.label_zhanli:setString(game.player.m_battlepoint)
	self.playerInfoNode.label_tili:setString(game.player.m_strength .. "/" .. game.player.m_maxStrength)
	self.playerInfoNode.label_naili:setString(game.player.m_energy .. "/" .. game.player.m_maxEnergy)
	self.playerInfoNode.label_exp:setString(game.player.m_exp .. "/" .. game.player.m_maxExp)
	local temptext = self.playerInfoNode[CCB_PLAYER_INFO.mm_name]:getChildByTag(10000)
	
	if temptext and temptext:getParent() and game.player.m_name ~= temptext:getString() then
		temptext:removeSelf()
		temptext = nil
		local text = ui.newTTFLabelWithOutline({
		text = game.player.m_name,
		x = 5,
		y = self.playerInfoNode[CCB_PLAYER_INFO.mm_name]:getContentSize().height * 0.78,
		font = FONTS_NAME.font_fzcy,
		size = 20,
		color = FONT_COLOR.PLAYER_NAME,
		outlineColor = display.COLOR_BLACK,
		--align = ui.TEXT_ALIGN_LEFT,
		})
		text:setTag(10000)
		self.playerInfoNode[CCB_PLAYER_INFO.mm_name]:addChild(text)
		text:align(display.LEFT_CENTER)
	end
	
	local function refreshBar(...)
		local percent = game.player.m_strength / game.player.m_maxStrength
		if percent > 1 then
			percent = 1
		end
		local barWidth = self.playerInfoNode.tag_tili:getContentSize().width
		local bar = self.playerInfoNode.tag_tili_bar
		bar:setTextureRect(cc.rect(bar:getTextureRect().x, bar:getTextureRect().y, barWidth * percent, bar:getTextureRect().height))
		percent = game.player.m_energy / game.player.m_maxEnergy
		if percent > 1 then
			percent = 1
		end
		local bar = self.playerInfoNode.tag_naili_bar
		bar:setTextureRect(cc.rect(bar:getTextureRect().x, bar:getTextureRect().y, barWidth * percent, bar:getTextureRect().height))
		percent = game.player.m_exp / game.player.m_maxExp
		if percent > 1 then
			percent = 1
		end
		local bar = self.playerInfoNode.tag_exp_bar
		bar:setTextureRect(cc.rect(bar:getTextureRect().x, bar:getTextureRect().y, barWidth * percent, bar:getTextureRect().height))
	end
	refreshBar()
end

function MainMenuLayer:initPlayerBoard(...)
	local headImgName = game.player:getPlayerIconName()
	local playerHead = self.playerInfoNode.head_icon
	playerHead:setDisplayFrame(display.newSpriteFrame(headImgName))
	local touchLayer = require("utility.MyLayer").new({
	name = headImgName,
	size = playerHead:getContentSize(),
	swallow = true,
	touchHandler = function (event)
		if event.name == "began" then
			GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
			local function cb(...)
				
			end
			self:showPlayerInfo(cb)
		end
	end
	})
	playerHead:addChild(touchLayer)
	
	self.playerInfoNode.tag_lv:setString(game.player.m_level)
	local text = ui.newTTFLabelWithOutline({
	text = game.player.m_name,
	x = 5,
	y = self.playerInfoNode[CCB_PLAYER_INFO.mm_name]:getContentSize().height * 0.78,
	font = FONTS_NAME.font_fzcy,
	size = 20,
	color = FONT_COLOR.PLAYER_NAME,
	outlineColor = display.COLOR_BLACK,
	align = ui.TEXT_ALIGN_LEFT
	})
	text:setTag(10000)
	self.playerInfoNode[CCB_PLAYER_INFO.mm_name]:addChild(text)
	text:align(display.LEFT_CENTER)
	self:refreshPlayerBoard()
end

function MainMenuLayer:showPlayerInfo(cb)
	local playerInfoLayer = require("game.scenes.PlayerInfoLayer").new(self.playerInfoNode, cb)
	self:addChild(playerInfoLayer, GAMENOTE_ZORDER)
end

function MainMenuLayer:btnTouchFunc(btnName)
	if self:getChildByTag(HUODONG_TAG) then
		self:removeChildByTag(HUODONG_TAG)
	end
	if self._rootnode[btnName] then
		self.bottomIconTouch(btnName)
	end
end

function MainMenuLayer:onExit()
	print("~~~~~~~~~~~~~~~~~~~~~~~退出MainMenuLayer:onExit")
	if game.urgencyBroadcast:getIsHasShow() then
		game.urgencyBroadcast:setIsShow(false)
	end
	if self._kaifuInstance and self._kaifuInstance.close then
		self._kaifuInstance:close()
		self._kaifuInstance = nil
	end
	local huodongLayer = self:getChildByTag(HUODONG_TAG)
	if huodongLayer ~= nil and huodongLayer.closeSelf then
		huodongLayer:closeSelf()
	end
	
	UnRegNotice(self, NoticeKey.MainMenuScene_Update)
	UnRegNotice(self, NoticeKey.MAINSCENE_HIDE_BOTTOM_LAYER)
	UnRegNotice(self, NoticeKey.MAINSCENE_SHOW_BOTTOM_LAYER)
	UnRegNotice(self, NoticeKey.MainMenuScene_OnlineReward)
	UnRegNotice(self, NoticeKey.MainMenuScene_RewardCenter)
	UnRegNotice(self, NoticeKey.MainMenuScene_Qiandao)
	UnRegNotice(self, NoticeKey.MainMenuScene_DengjiLibao)
	UnRegNotice(self, NoticeKey.MainMenuScene_KaifuLibao)
	UnRegNotice(self, NoticeKey.MainMenuScene_chatNewNum)
	UnRegNotice(self, NoticeKey.MainMenuScene_challenge)
	UnRegNotice(self, NoticeKey.MainMenuScene_ChengZhangZhilu)
	UnRegNotice(self, NoticeKey.MainMenuScene_Music)
	UnRegNotice(self, NoticeKey.MainMenuScene_UrgencyBroadcast)
	UnRegNotice(self, NoticeKey.MainMenuScene_Shouchong)
	UnRegNotice(self, NoticeKey.MAIL_TIP_UPDATE)
	UnRegNotice(self, NoticeKey.MainMenuScene_kaifukuanghuan)
	UnRegNotice(self, NoticeKey.MainMenuScene_equipments)
	UnRegNotice(self, NoticeKey.MainMenuScene_xiakes)
	UnRegNotice(self, NoticeKey.MainMenuScene_pet)
	UnRegNotice(self, NoticeKey.UP_FRIEND_ICON_ACT)
	UnRegNotice(self, NoticeKey.CHECK_GUILD_APPLY_NUM)
	UnRegNotice(self, NoticeKey.APP_ENTER_FOREGROUND_EVENT_IN_GAME)
	
	
	self.scheduler.unscheduleGlobal(self.schedulerUpdateTimeLabel)
	self.scheduler.unscheduleGlobal(self.schedulerUnread)
	
	TutoMgr.removeBtn("zhujiemian_xiake_btn")
	TutoMgr.removeBtn("zhujiemian_tiaozhan_btn")
	TutoMgr.removeBtn("main_scene_qiandao_btn")
	TutoMgr.removeBtn("zhujiemian_lianhualu")
	TutoMgr.removeBtn("zhujiemian_jingmai")
	TutoMgr.removeBtn("main_scene_qitianle_btn")
	display.removeSpriteFramesWithFile("ui/ui_main_menu.plist", "ui/ui_main_menu.pvr.ccz")
	display.removeSpriteFramesWithFile("ui/ui_mm_day.plist", "ui/ui_mm_day.pvr.ccz")
	display.removeSpriteFramesWithFile("ui/ui_mm_night.plist", "ui/ui_mm_night.pvr.ccz")
	display.removeSpriteFramesWithFile("ui/ui_toplayer.plist", "ui/ui_toplayer.pvr.ccz")
	display.removeSpriteFramesWithFile("ui/ui_bottom2.plist", "ui/ui_bottom2.pvr.ccz")
	display.removeSpriteFramesWithFile("ui/ui_gamenote.plist", "ui/ui_gamenote.png")
	CCTextureCache:sharedTextureCache():removeUnusedTextures()
	
end

--更新快捷菜单
function MainMenuLayer:UpdateQuickAccess(...)
	display.addSpriteFramesWithFile("2015_03_03.plist", "2015_03_03.png")
	local onBtn = function (tag)
		if tag == QuickAccess.SLEEP then
			GameStateManager:ChangeState(GAME_STATE.STATE_JINGCAI_HUODONG, nbActivityShowType.KeZhan)
		elseif tag == QuickAccess.BOSS then
			GameStateManager:ChangeState(GAME_STATE.STATE_WORLD_BOSS)
		elseif tag == QuickAccess.LIMITCARD then
			GameStateManager:ChangeState(GAME_STATE.STATE_JINGCAI_HUODONG, nbActivityShowType.LimitHero)
		elseif tag == QuickAccess.GUILD_BOSS then
			GameStateManager:ChangeState(GAME_STATE.STATE_GUILD_QL_BOSS, false)
		elseif tag == QuickAccess.GUILD_BBQ then
			GameStateManager:ChangeState(GAME_STATE.STATE_GUILD)
		elseif tag == QuickAccess.TANBAO then
			GameStateManager:ChangeState(GAME_STATE.STATE_JINGCAI_HUODONG, nbActivityShowType.huanggongTanBao)
		elseif tag == QuickAccess.WABAO then
			GameStateManager:ChangeState(GAME_STATE.STATE_JINGCAI_HUODONG, nbActivityShowType.migongWaBao)
		elseif tag == QuickAccess.SHOP then
			GameStateManager:ChangeState(GAME_STATE.STATE_JINGCAI_HUODONG, nbActivityShowType.xianshiShop)
		elseif tag == QuickAccess.YABIAO then
			GameStateManager:ChangeState(GAME_STATE.STATE_YABIAO_SCENE)
		elseif tag == QuickAccess.LUCKY_POOL then
			GameStateManager:ChangeState(GAME_STATE.STATE_JINGCAI_HUODONG, nbActivityShowType.luckyPool)
		elseif tag == QuickAccess.CREDIT_SHOP then
			GameStateManager:ChangeState(GAME_STATE.STATE_JINGCAI_HUODONG, nbActivityShowType.creditShop)
		elseif tag == QuickAccess.DIAOYU_ACT then
			GameStateManager:ChangeState(GAME_STATE.STATE_JINGCAI_HUODONG, nbActivityShowType.diaoyu)
		end
	end
	self._rootnode.quickAccessNode:removeAllChildrenWithCleanup(true)
	local menus = {}
	dump(game.player.m_quickAccessState)
	for k, v in pairs(game.player.m_quickAccessState) do
		local canShow = true
		if k == QuickAccess.SLEEP and game.player:getAppOpenData().kezhan == APPOPEN_STATE.close then
			canShow = false
		end
		if canShow == true and v and v == 1 then
			local item = ui.newImageMenuItem({
			image = string.format("#2015_03_03_%d.png", k),
			imageSelected = string.format("#2015_03_03_%d.png", k),
			tag = k,
			})
			item:registerScriptTapHandler(onBtn)
			table.insert(menus, item)
		end
	end
	local menu = ui.newMenu(menus)
	menu:alignItemsHorizontally()
	self._rootnode.quickAccessNode:addChild(menu)
end

function addPrompt(rootNode)
	local arrayBtn = common:yuan3(type(rootNode) == "table", rootNode.formSettingBtn, rootNode)
	local _BetterEquipNoticeTag = 6841
	local _topImg = arrayBtn:getChildByTag(_BetterEquipNoticeTag)
	if not _topImg then
		display.addSpriteFramesWithFile("ui/ui_toplayer.plist", "ui/ui_toplayer.pvr.ccz")
		_topImg = display.newSprite("#toplayer_mail_tip.png")
		_topImg:align(display.TOP_RIGHT, arrayBtn:getContentSize().width, arrayBtn:getContentSize().height)
		_topImg:setVisible(false)
		arrayBtn:addChild(_topImg, 100, _BetterEquipNoticeTag)
	end
	if _topImg ~= nil then
		if game.player:getBetterEquip() > 0 then
			_topImg:setVisible(true)
		else
			_topImg:setVisible(false)
		end
	end
end

return MainMenuLayer