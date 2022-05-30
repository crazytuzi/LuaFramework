local data_jingyingfuben_jingyingfuben = require("data.data_jingyingfuben_jingyingfuben")
local data_huodongfuben_huodongfuben = require("data.data_huodongfuben_huodongfuben")
local MAX_ZODER = 1001
local OPENLAYER_ZORDER = MAX_ZODER + 1
local JIEFUJIPIN_ID = 1
local JingYingListOffset
local jingYingListNum = 0


local BaseScene = require("game.BaseScene")
local ChallengeScene = class("ChallengeScene", BaseScene)


function ChallengeScene:sendJingYingReq()
	RequestHelper.JingyingFuBenList({
	callback = function(data)
		JingYingModel.initData(data)
		self:updateJingYingList()
	end
	})
end

function ChallengeScene:updateJingYingList()
	self.view_type = CHALLENGE_TYPE.JINGYING_VIEW
	self._rootnode.active_num_bg:setVisible(false)
	self._rootnode.today_rest_node:setVisible(true)
	self._rootnode.today_rest_num:setString(JingYingModel.getRestNum())
	self.jingyingRestNum = JingYingModel.getRestNum()
	self:checkDayLeftCnt({
	jingyingNum = JingYingModel.getRestNum()
	})
	if JingYingModel.getRestNum() > 0 then
		self._rootnode.jingying_num_bg:setVisible(true)
	else
		self._rootnode.jingying_num_bg:setVisible(false)
	end
	local maxLv = JingYingModel.getMaxLv()
	local totalNum = maxLv + 2
	local isAllLvlDone = false
	if totalNum > #data_jingyingfuben_jingyingfuben then
		totalNum = #data_jingyingfuben_jingyingfuben
		isAllLvlDone = true
	end
	local function createFunc(idx)
		local item = require("game.Challenge.JingYingCell").new()
		return item:create({
		viewSize = cc.size(self._rootnode.list_bg:getContentSize().width, self._rootnode.list_bg:getContentSize().height * 0.95),
		idx = idx,
		totalNum = totalNum,
		isAllLvlDone = isAllLvlDone
		})
	end
	local function refreshFunc(cell, idx)
		cell:refresh(idx + 1, isAllLvlDone)
	end
	local itemList = require("utility.TableViewExt").new({
	size = cc.size(self._rootnode.list_bg:getContentSize().width, self.getCenterHeightWithSubTop()),
	direction = kCCScrollViewDirectionVertical,
	createFunc = createFunc,
	refreshFunc = refreshFunc,
	cellNum = totalNum,
	cellSize = cc.size(display.width * 0.9, 200),
	touchFunc = function(cell)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		print(totalNum - cell:getIdx())
		PostNotice(NoticeKey.REMOVE_TUTOLAYER)
		local function removeFunc()
			self.isTouchJingYingCell = false
		end
		if self.isTouchJingYingCell ~= true then
			self.isTouchJingYingCell = true
			if cell:getIsAllowPlay() then
				if JingYingModel.getRestNum() > 0 then
					local index = cell:getIdx()
					local layer = require("game.Challenge.JingYingFuBenInfoBox").new(cell:getIdx() + 1, removeFunc)
					display.getRunningScene():addChild(layer, 10000)
				else
					removeFunc()
					show_tip_label(common:getLanguageString("@ToDayChallengeRunOut"))
				end
			else
				removeFunc()
				show_tip_label(common:getLanguageString("@Unlocked"))
			end
		end
	end
	})
	self.listView:removeAllChildren()
	self.listView:addChild(itemList)
	self.jingYingList = itemList
	local cell = itemList:cellAtIndex(0)
	if cell ~= nil then
		local tutoBtn = cell:getTutoBtn()
		TutoMgr.addBtn("jingying_fuben_chuchumaolu", tutoBtn)
	end
	local tuto = self._rootnode.tab2
	TutoMgr.addBtn("huodongfuben_tab", tuto)
	TutoMgr.active()
	local cellSizeHeight = 200
	if JingYingListOffset then
		local listSize = self.jingYingList:getContentSize()
		if listSize.height < totalNum * cellSizeHeight then
			if totalNum > jingYingListNum then
				JingYingListOffset.y = 0
			end
			self.jingYingList:setContentOffset(JingYingListOffset)
		end
	end
	jingYingListNum = totalNum
end

function ChallengeScene:saveJingYingListOffset()
	if self.view_type == CHALLENGE_TYPE.JINGYING_VIEW and self.jingYingList then
		JingYingListOffset = self.jingYingList:getContentOffset()
	end
end

function ChallengeScene:sendHuoDongReq()
	RequestHelper.HuoDongFuBenList({
	callback = function(data)
		dump("huodong data")
		dump(data)
		HuoDongFuBenModel.initData(data)
		PostNotice(NoticeKey.REMOVE_TUTOLAYER)
		self:updateHuoDongList()
	end
	})
end

function ChallengeScene:updateHuoDongList()
	self.view_type = CHALLENGE_TYPE.HUODONG_VIEW
	self.huodong_fuben_list = HuoDongFuBenModel.getFubenList()
	self._rootnode.today_rest_node:setVisible(false)
	self._rootnode.jingying_num_bg:setVisible(false)
	local openList = {}
	local closeList = {}
	for i = 1, #data_huodongfuben_huodongfuben do
		for k, v in pairs(self.huodong_fuben_list) do
			local aid = checkint(k)
			local item = data_huodongfuben_huodongfuben[aid]
			if item.order == i then
				if v.openCnt > 0 then
					table.insert(openList, aid)
					break
				end
				table.insert(closeList, aid)
				break
			end
		end
	end
	
	local huodongIdList = openList
	for i, v in ipairs(closeList) do
		table.insert(huodongIdList, v)
	end
	
	local dayLeftCnt = 0
	for k, v in pairs(self.huodong_fuben_list) do
		dayLeftCnt = dayLeftCnt + v.surplusCnt
	end
	
	self:checkDayLeftCnt({huodongNum = dayLeftCnt})
	local filename = "game.Challenge.HuoDongCell"
	local function createFunc(idx)
		local item = require(filename).new()
		return item:create({
		viewSize = cc.size(self._rootnode.list_bg:getContentSize().width, self._rootnode.list_bg:getContentSize().height * 0.95),
		aid = huodongIdList[idx + 1],
		refreshFunc = function()
			self:sendHuoDongReq()
		end
		})
	end
	local function refreshFunc(cell, idx)
		cell:refresh(huodongIdList[idx + 1])
	end
	local itemList = require("utility.TableViewExt").new({
	size = cc.size(self._rootnode.list_bg:getContentSize().width, self.getCenterHeightWithSubTop()),
	direction = kCCScrollViewDirectionVertical,
	createFunc = createFunc,
	refreshFunc = refreshFunc,
	cellNum = #huodongIdList,
	cellSize = require(filename).new():getContentSize(),
	touchFunc = function(cell, x, y)
		local actId = huodongIdList[cell:getIdx() + 1]
		local itemId = HuoDongFuBenModel.getItemID(actId)
		local itemNum = HuoDongFuBenModel.getItemNum(actId)
		local isEnough = true
		if itemId ~= 0 and itemNum == 0 then
			isEnough = false
		end
		local function toBat()
			if actId == JIEFUJIPIN_ID then
				local ruleLayer = require("game.Huodong.jiefuRuleLayer").new({
				jumpFunc = function()
					GameStateManager:ChangeState(GAME_STATE.STATE_HUODONG_BATTLE, actId)
				end
				})
				display:getRunningScene():addChild(ruleLayer, 1000)
			else
				GameStateManager:ChangeState(GAME_STATE.STATE_HUODONG_BATTLE, actId)
			end
		end
		if actId == JIEFUJIPIN_ID then
			if cell:getIsAllowPlay() then
				if 0 < HuoDongFuBenModel.getRestNum(tostring(actId)) then
					toBat()
				elseif 0 < cell:getOpenCnt() then
					if itemId ~= 0 and itemNum > 0 then
						toBat()
					else
						show_tip_label(common:getLanguageString("@ToDayChallengeRunOut"))
					end
				else
					show_tip_label(common:getLanguageString("@ActivityOpen"))
				end
			else
				local trueId = actId
				local fubenData = data_huodongfuben_huodongfuben[trueId]
				show_tip_label(fubenData.tips)
			end
		else
			local fbInfo = data_huodongfuben_huodongfuben[actId]
			RequestHelper.challengeFuben.actDetail({
			aid = actId,
			sysId = fbInfo.sys_id,
			callback = function(data)
				--if data.err == "" then
				game.runningScene:addChild(require("game.ChallengeFuben.ChallengeFubenLayer").new({
				parentCell = cell,
				fbId = actId,
				rtnObj = data,
				refreshCellFunc = function()
					cell:setLeftCnt(HuoDongFuBenModel.getRestNum(actId))
					self:checkDayLeftCnt({})
				end
				}), MAX_ZODER)
				--end
			end
			})
		end
	end
	})
	self.listView:removeAllChildren()
	self.listView:addChild(itemList)
end

function ChallengeScene:sendZhenShenReq()
	self:ZhenShenFuBenList({
	callback = function(data)
		dump(data)
		ZhenShenModel.initData(data)
		self:updateZhenShenList()
	end
	})
end

function ChallengeScene:ZhenShenFuBenList(param)
	dump(param)
	local _callback = param.callback
	local msg = {
	m = "actbattle",
	a = "realbodypve"
	}
	RequestHelper.request(msg, _callback)
end

function ChallengeScene:updateZhenShenList()
	self.view_type = CHALLENGE_TYPE.ZHENSHEN_VIEW
	self.zhenshenRestNum = ZhenShenModel.getRestNum()
	self._rootnode.today_rest_node:setVisible(false)
	self._rootnode.zhenshen_label_2:setString(self.zhenshenRestNum)
	self:checkDayLeftCnt({
	zhenshenNum = self.zhenshenRestNum
	})
	self.zhenshen_fuben_list = ZhenShenModel.getFubenList()
	local huodongIdList = self.zhenshen_fuben_list
	local function createFunc(idx)
		local item = require("game.Challenge.ZhenShenCell").new()
		return item:create({
		data_1 = huodongIdList[idx * 2 + 1],
		data_2 = huodongIdList[idx * 2 + 2]
		})
	end
	
	local function refreshFunc(cell, idx)
		cell:refresh({
		data_1 = huodongIdList[idx * 2 + 1],
		data_2 = huodongIdList[idx * 2 + 2]
		})
	end
	
	local function getHeros(_cards)
		local cards = {}
		local formHero = {}
		for i, v in ipairs(_cards) do
			table.insert(cards, {
			id = v.cardId,
			resId = v.resId,
			star = v.star,
			pos = v.pos,
			cls = v.cls,
			level = v.level,
			initLife = v.initLife,
			anger = v.anger
			})
		end
		if self._view_type == CHALLENGE_TYPE.ZHENSHEN_VIEW and (self._formHero == nil or #self._formHero <= 0) then
			self._formHero = {}
			for i = 1, 6 do
				for j, v in ipairs(_cards) do
					if v.pos == i then
						table.insert(self._formHero, {
						index = j,
						pos = v.pos
						})
						break
					end
				end
			end
		end
		return cards, self._formHero
	end
	local getHeroById = function(id, cards)
		for k, v in ipairs(cards) do
			if id == v.cardId then
				return k, v
			end
		end
		return nil
	end
	
	local data_zhenshenfuben_zhenshenfuben = require("data.data_zhenshenfuben_zhenshenfuben")
	local itemList = require("utility.TableViewExt").new({
	size = cc.size(self._rootnode.list_bg:getContentSize().width, self.getCenterHeightWithSubTop() - self.zhenShenTop:getContentSize().height + 10),
	direction = kCCScrollViewDirectionVertical,
	createFunc = createFunc,
	refreshFunc = refreshFunc,
	cellNum = math.ceil(#huodongIdList / 2),
	cellSize = require("game.Challenge.ZhenShenCell").new():getContentSize(),
	touchFunc = function(cell, x, y)
		--_listViewTouchNode:setTouchEnabled(false)
		local idx = cell:getIdx()
		for i = 1, 2 do
			local node = cell:getNode(i)
			local pos = node:convertToNodeSpace(cc.p(x, y))
			if cell:isExist(i) == true and cc.rectContainsPoint(cc.rect(0, 0, node:getContentSize().width, node:getContentSize().height), pos) then
				local zhenShenInfo = huodongIdList[idx * 2 + i]
				local fbId = zhenShenInfo.fbId
				if zhenShenInfo.battleState == 1 then
					if 0 >= ZhenShenModel.getRestNum() then
						show_tip_label(common:getLanguageString("@zhenshenerror2"))
						break
					end
					local fbInfo = data_zhenshenfuben_zhenshenfuben[fbId]
					fbInfo.sys_id = 7
					GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
					RequestHelper.challengeFuben.actDetail({
					aid = fbId,
					sysId = fbInfo.sys_id,
					errback = function()
						--_listViewTouchNode:setTouchEnabled(true)
					end,
					callback = function(data)
						--_listViewTouchNode:setTouchEnabled(true)
						local cards, formHero = getHeros(data.cards, nil)
						local zhenshenKey = "zhenshen_fmt_" .. tostring(game.player.m_uid) .. "_" .. tostring(game.player.m_serverID) .. "_" .. tostring(fbId)
						local str = CCUserDefault:sharedUserDefault():getStringForKey(zhenshenKey, "")
						local needLeadRole = false
						if fbInfo.lead_role == 0 then
							needLeadRole = false
						elseif fbInfo.lead_role == 1 then
							needLeadRole = true
						end
						push_scene(require("game.scenes.formSettingBaseScene").new({
						fbId = fbId,
						sysId = fbInfo.sys_id,
						formSettingType = FormSettingType.ZhenShenFuBenType,
						heros = cards or {},
						save_form_title = zhenshenKey,
						needLeadRole = needLeadRole,
						confirmFunc = function(fmtStr)
							local function callBackFunc()
								self.zhenshenRestNum = ZhenShenModel.getRestNum()
								self:checkDayLeftCnt({
								zhenshenNum = self.zhenshenRestNum
								})
								self.listView:removeAllChildren()
								self.zhenShenListView:removeAllChildren()
								self:sendZhenShenReq()
							end
							ZhenShenModel.startFight(fmtStr, fbInfo, fbId, 1, callBackFunc)
						end
						}))
					end
					})
				else
					show_tip_label(common:getLanguageString("@zhenshenerror1"))
				end
				--_listViewTouchNode:setTouchEnabled(true)
				return
			end
		end
		--_listViewTouchNode:setTouchEnabled(true)
	end
	})
	self.zhenShenListView:addChild(itemList)
	--self.zhenShenListView:addChild(_listViewTouchNode)
end

function ChallengeScene:checkDayLeftCnt(param)
	local jingyingNum = param.jingyingNum or game.player:getJingyingNum()
	local huodongNum = param.huodongNum or game.player:getHuodongNum()
	local zhenshenNum = param.zhenshenNum or game.player:getZhenshenNum()
	if game.player:getAppOpenData().appstore == APPOPEN_STATE.close then
		huodongNum = 0
	end
	game.player:setJingyingNum(jingyingNum)
	game.player:setHuodongNum(huodongNum)
	game.player:setZhenshenNum(zhenshenNum)
	if game.player:getHuodongNum() <= 0 then
		self._rootnode.active_num_bg:setVisible(false)
	else
		local bHasOpen, _ = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.HuoDong_FuBen, game.player:getLevel(), game.player:getVip())
		if not bHasOpen then
			self._rootnode.active_num_bg:setVisible(false)
		else
			self._rootnode.active_num_bg:setVisible(true)
		end
		self._rootnode.huodong_num:setString(tostring(game.player:getHuodongNum()))
	end
	if game.player:getJingyingNum() <= 0 then
		self._rootnode.jingying_num_bg:setVisible(false)
	else
		local bHasOpen, _ = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.JiYing_FuBen, game.player:getLevel(), game.player:getVip())
		if not bHasOpen then
			self._rootnode.jingying_num_bg:setVisible(false)
		else
			self._rootnode.jingying_num_bg:setVisible(true)
		end
		self._rootnode.jingying_num:setString(tostring(game.player:getJingyingNum()))
	end
	if game.player:getZhenshenNum() <= 0 then
		self._rootnode.zhenshen_num_bg:setVisible(false)
	else
		local bHasOpen, _ = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.ZhenShen_FuBen, game.player:getLevel(), game.player:getVip())
		if not bHasOpen then
			self._rootnode.zhenshen_num_bg:setVisible(false)
		else
			self._rootnode.zhenshen_num_bg:setVisible(true)
		end
		self._rootnode.zhenshen_num:setString(tostring(game.player:getZhenshenNum()))
	end
	self._rootnode.zhenshen_label_2:setString(game.player:getZhenshenNum())
	alignNodesOneByAll({
	self._rootnode.zhenshen_label_1,
	self._rootnode.zhenshen_label_2,
	self._rootnode.zhenshen_label_3,
	self._rootnode.zhenshen_label_4
	}, 5)
end

function ChallengeScene:addChallengeTime(type)
	if type == CHALLENGE_TYPE.JINGYING_VIEW then
		if self.jingyingRestNum > 0 then
			ResMgr.showMsg(6)
		else
			local buyMsgBox = require("game.Challenge.JingYingBuyMsgBox").new({
			aid = actId,
			removeListener = function()
				self:saveJingYingListOffset()
				self:updateJingYingList()
			end
			})
			display.getRunningScene():addChild(buyMsgBox, 1000)
		end
	else
		local bHasOpen, _prompt = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.ZhenShen_FuBen, game.player:getLevel(), game.player:getVip())
		if not bHasOpen then
			show_tip_label(_prompt)
			return
		end
		local buyMsgBox = require("game.Challenge.ZhenShenBuyMsgBox").new({
		removeListener = function()
			self.listView:removeAllChildren()
			self.zhenShenListView:removeAllChildren()
			self:updateZhenShenList()
		end
		})
		display.getRunningScene():addChild(buyMsgBox, 1000)
	end
end

function ChallengeScene:ctor(viewType)
	ChallengeScene.super.ctor(self, {
	contentFile = "challenge/challenge_bg.ccbi",
	subTopFile = "challenge/challenge_up_tab.ccbi",
	topFile = "public/top_frame_other.ccbi",
	isOther = true
	})
	
	local viewType = viewType or CHALLENGE_TYPE.JINGYING_VIEW
	display.addSpriteFramesWithFile("ui/ui_coin_icon.plist", "ui/ui_coin_icon.png")
	game.runningScene = self
	self.listView = self._rootnode.listView
	self.jingyingPlusBtn = self._rootnode.jingying_plus_btn
	self.zhenShenNode = self._rootnode.zhenShenNode
	self.zhenShenListView = self._rootnode.zhenShenListView
	self.zhenShenTop = self._rootnode.zhenShenTop
	self.zhenshenPlusBtn = self._rootnode.zhenshen_plus_btn
	
	self.jingyingPlusBtn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		self:addChallengeTime(CHALLENGE_TYPE.JINGYING_VIEW)
	end,
	CCControlEventTouchUpInside)
	
	self.zhenshenPlusBtn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		self:addChallengeTime(CHALLENGE_TYPE.ZHENSHEN_VIEW)
	end,
	CCControlEventTouchUpInside)
	
	self._rootnode.backBtn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		GameStateManager:ChangeState(GAME_STATE.STATE_MAIN_MENU)
	end,
	CCControlEventTouchUpInside)
	
	self.viewType = 0
	local function onTabBtn(tag)
		self:saveJingYingListOffset()
		if self.firstOnTab == nil then
			self.firstOnTab = false
		else
			GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_yeqian))
		end
		local canClick = true
		local bHasOpen = false
		local prompt
		if CHALLENGE_TYPE.JINGYING_VIEW == tag then
			bHasOpen, prompt = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.JiYing_FuBen, game.player:getLevel(), game.player:getVip())
		elseif CHALLENGE_TYPE.HUODONG_VIEW == tag then
			bHasOpen, prompt = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.HuoDong_FuBen, game.player:getLevel(), game.player:getVip())
		elseif CHALLENGE_TYPE.ZHENSHEN_VIEW == tag then
			bHasOpen, prompt = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.ZhenShen_FuBen, game.player:getLevel(), game.player:getVip())
		end
		if CHALLENGE_TYPE.ZHENSHEN_VIEW ~= tag then
			if not bHasOpen then
				show_tip_label(prompt)
				canClick = false
			end
		elseif not bHasOpen then
			show_tip_label(prompt)
			canClick = true
		end
		if canClick then
			self.viewType = tag
			if CHALLENGE_TYPE.JINGYING_VIEW == tag then
				self.zhenShenNode:setVisible(false)
				self:sendJingYingReq()
			elseif CHALLENGE_TYPE.HUODONG_VIEW == tag then
				self.zhenShenNode:setVisible(false)
				self:sendHuoDongReq()
			elseif CHALLENGE_TYPE.ZHENSHEN_VIEW == tag then
				self.zhenShenNode:setVisible(true)
				self.zhenShenTop:setPositionY(self.getCenterHeightWithSubTop() - self.zhenShenTop:getContentSize().height)
				self.listView:removeAllChildren()
				self.zhenShenListView:removeAllChildren()
				self:sendZhenShenReq()
				self.jingYingList = nil
			end
		end
	end
	if game.player:getAppOpenData().appstore == APPOPEN_STATE.close then
		self._rootnode.tab2:setVisible(false)
		self._rootnode.tab3:setVisible(false)
	else
		self._rootnode.tab2:setVisible(true)
		self._rootnode.tab3:setVisible(true)
	end
	local function initTab()
		CtrlBtnGroupAsMenu({
		self._rootnode.tab1,
		self._rootnode.tab2,
		self._rootnode.tab3
		}, function(idx)
			onTabBtn(idx)
		end)
	end
	initTab()
	onTabBtn(viewType)
	self._rootnode.tab1:setEnabled(viewType ~= CHALLENGE_TYPE.JINGYING_VIEW)
	self._rootnode.tab2:setEnabled(viewType ~= CHALLENGE_TYPE.HUODONG_VIEW)
	self._rootnode.tab3:setEnabled(viewType ~= CHALLENGE_TYPE.ZHENSHEN_VIEW)
	self.jingying_fuben_list = {}
	self.huodong_fuben_list = {}
	self.zhenshen_fuben_list = {}
	self:checkDayLeftCnt({})
	if game.player:getLevel() < 60 or game.player:getAppOpenData().zhenshen == APPOPEN_STATE.close then
		self._rootnode.tab3:setVisible(false)
		self._rootnode.zhenshen_num_bg:setVisible(false)
	end
	self._bExit = false
end

function ChallengeScene:onEnter()
	game.runningScene = self
	ChallengeScene.super.onEnter(self)
	self:checkDayLeftCnt({})
	display.addSpriteFramesWithFile("ui/ui_challenge.plist", "ui/ui_challenge.png")
	display.addSpriteFramesWithFile("ui/ui_coin_icon.plist", "ui/ui_coin_icon.png")
	--self:regNotice()
	local levelData = game.player:getLevelUpData()
	if levelData.isLevelUp then
		do
			local _, systemIds = OpenCheck.checkIsOpenNewFuncByLevel(levelData.beforeLevel, levelData.curLevel)
			game.player:updateLevelUpData({isLevelUp = false})
			local function createOpenLayer()
				if #systemIds > 0 then
					local systemId = systemIds[1]
					self:addChild(require("game.OpenSystem.OpenLayer").new({systemId = systemId, confirmFunc = createOpenLayer}), OPENLAYER_ZORDER)
					table.remove(systemIds, 1)
				end
			end
			createOpenLayer()
		end
	end
	TutoMgr.active()
	if self._bExit == true then
		self._bExit = false
		local broadcastBg = self._rootnode.broadcast_tag
		game.broadcast:reSet(broadcastBg)
	end
end

function ChallengeScene:onExit()
	--self:unregNotice()
	ChallengeScene.super.onExit(self)
	self:saveJingYingListOffset()
	TutoMgr.removeBtn("huodongfuben_tab")
	TutoMgr.removeBtn("jingying_fuben_chuchumaolu")
	self._bExit = true
end

return ChallengeScene