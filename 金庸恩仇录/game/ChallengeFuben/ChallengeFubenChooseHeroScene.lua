local data_huodongfuben_huodongfuben = require("data.data_huodongfuben_huodongfuben")
local HERO_STATE = {
unselected = -1,
selected = 1,
zhuzhen = 4
}
local VIEW_TYPE = {
ALL = 1,
GONG = 2,
FANG = 3,
FU = 4
}
local MAX_ZORDER = 11

local BaseScene = require("game.BaseSceneExt")
local ChallengeFubenChooseHeroScene = class("ChallengeFubenChooseHeroScene", BaseScene)

function ChallengeFubenChooseHeroScene:ctor(param)
	
	ChallengeFubenChooseHeroScene.super.ctor(self, {
	contentFile = "huashan/huashan_choose_scene.ccbi",
	bottomFile = "huashan/huashan_bottom.ccbi",
	topFile = "huashan/huashan_top.ccbi"
	})
	
	local _bg = display.newSprite("ui_common/common_bg.png")
	local _bgW = display.width
	self._needLeadRole = param.needLeadRole
	self._fbId = param.fbId
	self._sysId = param.sysId
	local showFunc = param.showFunc
	local changeFormaitonFunc = param.changeFormaitonFunc
	self._cllbackFunc = param.cllbackFunc
	self._bHasChangeFormation = false
	self._bHasChangeFormList = false
	self._bHasSaveFormaiton = false
	self._zhandouLi = 0
	self._view_type = param.view_type or CHALLENGE_TYPE.JINGYING_VIEW
	dump(self._formHero)
	if self._view_type == CHALLENGE_TYPE.ZHENSHEN_VIEW then
		data_huodongfuben_huodongfuben = require("data.data_zhenshenfuben_zhenshenfuben")
	else
		data_huodongfuben_huodongfuben = require("data.data_huodongfuben_huodongfuben")
	end
	local tbl = {}
	self._heros = {}
	for key, hero in pairs(HelpLineModel.supports) do
		if hero.roleCard then
			tbl[hero.roleCard.resId] = hero.roleCard
		end
	end
	for key, hero in pairs(param.cards) do
		if tbl[hero.resId] then
			if hero.cardId == tbl[hero.resId].id then
				hero.state = 4
				self._heros[#self._heros + 1] = hero
			end
		else
			self._heros[#self._heros + 1] = hero
		end
	end
	self._formHero = {}
	for key, hero in pairs(param.formHero) do
		if not tbl[hero.resId] then
			self._formHero[#self._formHero + 1] = hero
		end
	end
	local _bgH = display.height - self._rootnode.topFrameNode:getContentSize().height
	_bg:setPosition(_bgW / 2, _bgH / 2)
	_bg:setScaleX(_bgW / _bg:getContentSize().width)
	_bg:setScaleY(_bgH / _bg:getContentSize().height)
	self:addChild(_bg, 0)
	self._rootnode.save_node:setVisible(true)
	self._rootnode.startBtn:setVisible(false)
	self._rootnode.content_msg_lbl:setString(data_huodongfuben_huodongfuben[self._fbId].recommend)
	local function getHeroById(id)
		for k, v in ipairs(self._heros) do
			if id == v.id then
				return k, v
			end
		end
		return nil
	end
	local function getfmtstr()
		local str = "["
		for k, v in ipairs(self._formHero) do
			local hero = self._heros[v.index]
			if hero then
				str = str .. string.format("[%s,%d],", hero.id, v.pos)
			end
		end
		str = str .. "]"
		return str
	end
	local function getFormInfo()
		local formList = {}
		for i = 1, 6 do
			local idxHero = self._formHero[i]
			if idxHero then
				local hero = self._heros[idxHero.index]
				if hero then
					local tmp = {
					pos = idxHero.pos,
					resId = hero.resId,
					cls = hero.cls,
					level = hero.level,
					star = hero.star,
					objId = hero.id
					}
					table.insert(formList, tmp)
				end
			end
		end
		return formList
	end
	local function changeFormFunc()
		if changeFormaitonFunc ~= nil then
			for i, v in ipairs(self._formHero) do
				self._heros[v.index].pos = v.pos
				self._heros[v.index].order = i
			end
			local fmt = getfmtstr()
			changeFormaitonFunc(self._heros, self._zhandouLi, fmt)
		end
	end
	local saveFormBtn = self._rootnode.saveFormBtn
	local function saveFormation()
		local str = getfmtstr()
		RequestHelper.challengeFuben.save({
		aid = self._fbId,
		fmt = str,
		sysId = self._sysId,
		errback = function()
			saveFormBtn:setEnabled(true)
		end,
		callback = function(data)
			saveFormBtn:setEnabled(true)
			dump(data)
			if data.err == "" then
				self._bHasSaveFormaiton = true
				self._zhandouLi = data.rtnObj
				changeFormFunc()
				pop_scene()
			end
		end
		})
	end
	self._rootnode.returnBtn:addHandleOfControlEvent(function()
		if self._bHasChangeFormation == true or self._bHasChangeFormList == true then
			if self._bHasSaveFormaiton == true then
				changeFormFunc()
				pop_scene()
			else
				local lbl1 = ResMgr.createOutlineMsgTTF({
				text = common:getLanguageString("@IsSave"),
				color = white,
				outlineColor = black,
				size = size
				})
				local lbl2 = ResMgr.createOutlineMsgTTF({
				text = common:getLanguageString("@Save"),
				color = white,
				outlineColor = black,
				size = size
				})
				local msgBox = require("utility.MsgBoxEx").new({
				resTable = {
				{lbl1},
				{lbl2}
				},
				confirmFunc = function(msgBox)
					saveFormation()
					msgBox:removeSelf()
				end,
				closeFunc = function(msgBox)
					msgBox:removeSelf()
					pop_scene()
				end,
				backFunc = function(msgBox)
					msgBox:removeSelf()
				end
				})
				game.runningScene:addChild(msgBox, MAX_ZORDER)
			end
		else
			pop_scene()
		end
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
	end,
	CCControlEventTouchUpInside)
	
	if self._view_type == CHALLENGE_TYPE.ZHENSHEN_VIEW then
		self._rootnode.saveFormBtn:setVisible(false)
		self._rootnode.startBtn:setVisible(true)
		self._rootnode.startBtn:addHandleOfControlEvent(function()
			local fbInfo = data_huodongfuben_huodongfuben[self._fbId]
			if #self._formHero == 0 then
				ResMgr.showErr(2900097)
			else
				do
					local formHero = getFormInfo()
					local isHasCard = false
					for k, v in ipairs(formHero) do
						if v.resId == fbInfo.cardId then
							isHasCard = true
							break
						end
					end
					local function toBat()
						RequestHelper.challengeFuben.rbPveBattle({
						id = self._fbId,
						fmt = getfmtstr(),
						npc = 1,
						errback = function(data)
							if data.errCode ~= nil and data.errCode ~= 0 then
								dump(data)
								ResMgr.showErr(data.errCode)
							end
						end,
						callback = function(data)
							dump(data)
							if data["0"] ~= "" then
								if self._errback ~= nil then
									self._errback()
								end
								if data.errCode ~= nil and data.errCode ~= 0 then
									dump(data)
									ResMgr.showErr(data.errCode)
								end
							else
								local _fmt = getfmtstr()
								local zhenshen_Key = "zhenshen_fmt_" .. tostring(game.player.m_uid) .. "_" .. tostring(game.player.m_serverID) .. "_" .. self._fbId
								CCUserDefault:sharedUserDefault():setStringForKey(zhenshen_Key, _fmt)
								CCUserDefault:sharedUserDefault():flush()
								local scene = require("game.Challenge.HuoDongBattleScene").new({
								fubenid = self._fbId,
								sysId = fbInfo.sys_id,
								npcLv = 1,
								fmt = _fmt,
								zhanli = data["8"] or 0,
								viewType = self._view_type,
								data = data,
								errback = function(isError)
									pop_scene()
								end,
								endFunc = function(bIsWin)
									pop_scene()
									pop_scene()
									if bIsWin == true then
										local times = ZhenShenModel.getRestNum() - 1
										ZhenShenModel.setRestNum(times)
										if self._cllbackFunc ~= nil then
											self._cllbackFunc()
										end
									end
								end
								})
								push_scene(scene)
							end
						end
						})
					end
					if isHasCard == true then
						--[[
						if #formHero < 6 then
							local tipLayer = require("game.huashan.HuaShanHeroLessTip").new({
							listener = function()
								toBat()
							end,
							closeFunc = function()
							end
							})
							game.runningScene:addChild(tipLayer, self:getZOrder() + 10000)
						else
							toBat()
						end
						]]
						toBat()
					else
						show_tip_label(common:getLanguageString("@zhenshenerror3"))
					end
				end
			end
			GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		end,
		CCControlEventTouchUpInside)
		
	end
	self._rootnode.saveFormBtn:addHandleOfControlEvent(function()
		if #self._formHero == 0 then
			ResMgr.showErr(2900097)
		else
			saveFormBtn:setEnabled(false)
			local lbl = ResMgr.createOutlineMsgTTF({
			text = common:getLanguageString("@IsSaveUp"),
			color = white,
			outlineColor = black,
			size = size
			})
			local msgBox = require("utility.MsgBoxEx").new({
			resTable = {
			{lbl}
			},
			confirmFunc = function(msgBox)
				saveFormation()
			end,
			closeFunc = function(msgBox)
				saveFormBtn:setEnabled(true)
				msgBox:removeSelf()
			end
			})
			game.runningScene:addChild(msgBox, MAX_ZORDER)
		end
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
	end,
	CCControlEventTouchUpInside)
	
	local setFormBtn = self._rootnode.setFormBtn
	setFormBtn:addHandleOfControlEvent(function()
		setFormBtn:setEnabled(false)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		if #self._formHero == 0 then
			ResMgr.showErr(2900097)
			setFormBtn:setEnabled(true)
			return
		end
		local formHero = getFormInfo()
		RequestHelper.huashan.zhandouli({
		fmt = getfmtstr(),
		callback = function(data)
			dump(data)
			local formCtrl = require("game.form.FormCtrl")
			self._formSettingView = formCtrl.createFormSettingLayer({
			parentNode = self,
			touchEnabled = true,
			list = formHero,
			bTmpPos = true,
			zdlNum = data.rtnObj,
			closeListener = function(bHasChange)
				for k, v in ipairs(self._formHero) do
					v.pos = formHero[k].pos
				end
				setFormBtn:setEnabled(true)
				if self._view_type ~= CHALLENGE_TYPE.ZHENSHEN_VIEW then
					self._bHasChangeFormation = bHasChange
				end
			end,
			callback = function()
			end
			})
		end
		})
	end,
	CCControlEventTouchUpInside)
	
	local function onTabBtn(tag)
		self._viewType = tag
		self._heroList:resetCellNum(#self._groupHerosData[tag], false, false)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_yeqian))
	end
	CtrlBtnGroupAsMenu({
	self._rootnode.tab1,
	self._rootnode.tab2,
	self._rootnode.tab3,
	self._rootnode.tab4
	}, onTabBtn)
	self._groupHerosData = {}
	for _, v in pairs(VIEW_TYPE) do
		self._groupHerosData[v] = {}
	end
	for i, v in ipairs(self._heros) do
		v.id = v.cardId
		if v.resId == 1 or v.resId == 2 then
			v.bIsSelf = true
		else
			v.bIsSelf = false
		end
		v.state = HERO_STATE.unselected
		for _, m in ipairs(self._formHero) do
			if m.index == i then
				v.state = HERO_STATE.selected
				break
			end
		end
	end
	self._viewType = VIEW_TYPE.ALL
	self:groupHero()
	self:initChooseListView()
	self:initHeroListView()
	self._rootnode.numLabel:setString(tostring(#self._formHero))
	if showFunc ~= nil then
		showFunc()
	end
end

function ChallengeFubenChooseHeroScene:groupHero()
	local heroGroup = {}
	for k, v in pairs(VIEW_TYPE) do
		heroGroup[v] = {}
	end
	for k, v in pairs(self._heros) do
		local hero = ResMgr.getCardData(v.resId)
		if hero.job == 1 then
			table.insert(heroGroup[VIEW_TYPE.GONG], v)
		elseif hero.job == 2 then
			table.insert(heroGroup[VIEW_TYPE.FANG], v)
		elseif hero.job == 3 then
			table.insert(heroGroup[VIEW_TYPE.FU], v)
		end
		table.insert(heroGroup[VIEW_TYPE.ALL], v)
		local path = "hero/icon/" .. hero.arr_icon[v.cls + 1] .. ".png"
		CCTextureCache:sharedTextureCache():addImage(path)
	end
	for _, viewType in pairs(VIEW_TYPE) do
		local t = self._groupHerosData[viewType]
		for k, v in ipairs(heroGroup[viewType]) do
			if k % 5 == 1 then
				table.insert(t, {})
			end
			for j, vs in pairs(HelpLineModel.supports) do
				if vs.roleCard and vs.roleCard.resId == v.resId then
					v.state = 4
				end
			end
			table.insert(t[#t], v)
		end
	end
end

function ChallengeFubenChooseHeroScene:getEmptyPos()
	local tmpPos = #self._formHero + 1
	local b
	for i = 1, 6 do
		b = true
		for _, v in ipairs(self._formHero) do
			if i == v.pos then
				b = false
				break
			end
		end
		if b then
			tmpPos = i
			break
		end
	end
	return tmpPos
end

function ChallengeFubenChooseHeroScene:initHeroListView()
	self._rootnode.touchNode:setTouchEnabled(true)
	local posX = 0
	local posY = 0
	self._rootnode.touchNode:addNodeEventListener(cc.NODE_TOUCH_CAPTURE_EVENT, function(event)
		posX = event.x
		posY = event.y
	end)
	local function existSameHero(resId)
		for k, v in ipairs(self._formHero) do
			if self._heros[v.index].resId == resId then
				return true
			end
		end
		return false
	end
	local fbinfo = data_huodongfuben_huodongfuben[self._fbId]
	local sz = self._rootnode.scrollListView:getContentSize()
	local heroItem = require("game.guild.guildFuben.GuildFubenHeroItem")
	self._heroList = require("utility.TableViewExt").new({
	size = CCSizeMake(sz.width, sz.height - 45),
	direction = kCCScrollViewDirectionVertical,
	createFunc = function(idx)
		local item = heroItem.new()
		idx = idx + 1
		return item:create({
		viewSize = sz,
		itemData = self._groupHerosData[self._viewType][idx],
		idx = idx,
		info = fbinfo
		})
	end,
	refreshFunc = function(cell, idx)
		idx = idx + 1
		cell:refresh({
		idx = idx,
		itemData = self._groupHerosData[self._viewType][idx],
		info = fbinfo
		})
	end,
	cellNum = #self._groupHerosData[self._viewType],
	cellSize = heroItem.new():getContentSize(),
	touchFunc = function(cell)
		local idx = cell:getIdx() + 1
		local function info(i)
			local info = self._groupHerosData[self._viewType][idx]
			if info and info[i] then
				for k, v in ipairs(self._heros) do
					if info[i].id == v.id then
						if info[i].state == HERO_STATE.selected then
							ResMgr.showErr(2900096)
							break
						end
						if info[i].state == HERO_STATE.unselected then
							if #self._formHero >= 6 then
								ResMgr.showErr(2900095)
								break
							end
							if existSameHero(info[i].resId) then
								ResMgr.showErr(600005)
								break
							end
							if self._view_type ~= CHALLENGE_TYPE.ZHENSHEN_VIEW then
								self._bHasChangeFormList = true
							end
							info[i].state = HERO_STATE.selected
							self._heroList:reloadCell(idx - 1, {itemData = info, info = fbinfo})
							table.insert(self._formHero, {
							index = k,
							pos = self:getEmptyPos()
							})
							info[i].order = #self._formHero
							self._chooseItemList:resetListByNumChange(#self._formHero)
							self._rootnode.numLabel:setString(tostring(#self._formHero))
							if #self._formHero > 1 then
								local w = self._chooseItemList:cellAtIndex(0):getContentSize().width * #self._formHero
								if w > self._chooseItemList:getContentSize().width then
									self._chooseItemList:setContentOffset(ccp(self._chooseItemList:getContentSize().width - w, 0), true)
								end
							end
							break
						end
						if info[i].state == HERO_STATE.zhuzhen then
							show_tip_label(common:getLanguageString("@zhuzhen_InBattle"))
						end
						break
					end
				end
			end
		end
		for i = 1, 5 do
			local icon = cell:getIcon(i)
			if icon ~= nil then
				local pos = icon:convertToNodeSpace(ccp(posX, posY))
				if CCRectMake(0, 0, icon:getContentSize().width, icon:getContentSize().height):containsPoint(pos) then
					info(i)
					break
				end
			end
		end
	end
	})
	self._heroList:setPosition(0, 9)
	self._rootnode.scrollListView:addChild(self._heroList)
end

function ChallengeFubenChooseHeroScene:initChooseListView()
	local sz = self._rootnode.selectListView:getContentSize()
	local selectedItem = require("game.guild.guildFuben.GuildFubenHeroSelectItem")
	local fbinfo = data_huodongfuben_huodongfuben[self._fbId]
	self._chooseItemList = require("utility.TableViewExt").new({
	size = CCSizeMake(sz.width, sz.height),
	direction = kCCScrollViewDirectionHorizontal,
	createFunc = function(idx)
		local item = selectedItem.new()
		idx = idx + 1
		return item:create({
		viewSize = sz,
		itemData = self._heros[self._formHero[idx].index],
		idx = idx
		})
	end,
	refreshFunc = function(cell, idx)
		idx = idx + 1
		cell:refresh({
		idx = idx,
		itemData = self._heros[self._formHero[idx].index]
		})
	end,
	cellNum = #self._formHero,
	cellSize = selectedItem.new():getContentSize(),
	touchFunc = function(cell)
		local idx = cell:getIdx() + 1
		local curIndex = self._formHero[idx].index
		if self._heros[curIndex].bIsSelf == true and self._needLeadRole == true then
			ResMgr.showErr(2900088)
		else
			self._heros[curIndex].state = HERO_STATE.unselected
			self._heros[curIndex].pos = -1
			local bBreak = false
			for k, v in ipairs(self._groupHerosData[self._viewType]) do
				for i = 1, 5 do
					if v[i] and v[i].id == self._heros[curIndex].id then
						self._heroList:reloadCell(k - 1, {itemData = v, info = fbinfo})
						bBreak = true
						if self._view_type ~= CHALLENGE_TYPE.ZHENSHEN_VIEW then
							self._bHasChangeFormList = true
						end
					end
				end
				if bBreak then
					break
				end
			end
			self._heros[curIndex].order = 0
			table.remove(self._formHero, idx)
			for i, v in ipairs(self._formHero) do
				self._heros[v.index].order = i
			end
			self._chooseItemList:resetListByNumChange(#self._formHero)
			self._rootnode.numLabel:setString(tostring(#self._formHero))
		end
	end
	})
	self._chooseItemList:setPosition(0, 0)
	self._rootnode.selectListView:addChild(self._chooseItemList)
end

function ChallengeFubenChooseHeroScene:onEnter()
	game.runningScene = self
	ChallengeFubenChooseHeroScene.super.onEnter(self)
end

function ChallengeFubenChooseHeroScene:onExit()
	ChallengeFubenChooseHeroScene.super.onExit(self)
	CCTextureCache:sharedTextureCache():removeUnusedTextures()
end

return ChallengeFubenChooseHeroScene