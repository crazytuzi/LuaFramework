local data_ui_ui = require("data.data_ui_ui")
local data_union_fuben_union_fuben = require("data.data_union_fuben_union_fuben")
local MAX_ZORDER = 11
local VIEW_TYPE = {
ALL = 1,
GONG = 2,
FANG = 3,
FU = 4
}

local BaseScene = require("game.BaseSceneExt")
local GuildFubenChooseHeroScene = class("GuildFubenChooseHeroScene", BaseScene)

function GuildFubenChooseHeroScene:ctor(param)
	GuildFubenChooseHeroScene.super.ctor(self, {
	contentFile = "huashan/huashan_choose_scene.ccbi",
	bottomFile = "huashan/huashan_bottom.ccbi",
	topFile = "huashan/huashan_top.ccbi"
	})
	
	local _bg = display.newSprite("ui_common/common_bg.png")
	local _bgW = display.width
	self._id = param.id
	local showFunc = param.showFunc
	local tbl = {}
	self._heros = {}
	for key, hero in pairs(HelpLineModel.supports) do
		if hero.roleCard then
			tbl[hero.roleCard.resId] = hero.roleCard
		end
	end
	for key, hero in pairs(param.cardsList) do
		if tbl[hero.resId] then
			if hero.cardId == tbl[hero.resId].id then
				hero.state = 4
				self._heros[#self._heros + 1] = hero
			end
		else
			self._heros[#self._heros + 1] = hero
		end
	end
	local fbItem = data_union_fuben_union_fuben[self._id]
	if fbItem.lead_role == 1 then
		self._needLeadRole = true
	else
		self._needLeadRole = false
	end
	local _bgH = display.height - self._rootnode.topFrameNode:getContentSize().height
	_bg:setPosition(_bgW / 2, _bgH / 2)
	_bg:setScaleX(_bgW / _bg:getContentSize().width)
	_bg:setScaleY(_bgH / _bg:getContentSize().height)
	self:addChild(_bg, 0)
	self._rootnode.content_msg_lbl:setString(data_ui_ui[12].content)
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
	self._rootnode.returnBtn:addHandleOfControlEvent(function()
		pop_scene()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
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
			closeListener = function()
				for k, v in ipairs(self._formHero) do
					v.pos = formHero[k].pos
				end
				setFormBtn:setEnabled(true)
			end,
			callback = function()
			end
			})
		end
		})
	end,
	CCControlEventTouchUpInside)
	
	local function extendBag(data)
		if self._bagObj[1].curCnt < data["1"] then
			table.remove(self._bagObj, 1)
		else
			self._bagObj[1].cost = data["4"]
			self._bagObj[1].size = data["5"]
		end
		if #self._bagObj > 0 then
			game.runningScene:addChild(require("utility.LackBagSpaceLayer").new({
			bagObj = self._bagObj,
			callback = function(data)
				extendBag(data)
			end
			}), MAX_ZORDER)
		end
	end
	local function fight()
		local str = getfmtstr()
		RequestHelper.Guild.unionFBfight({
		id = self._id,
		sysid = fbItem.sys_id,
		fmt = getfmtstr(),
		callback = function(data)
			local rtnObj = data.rtnObj
			if rtnObj.isFull == 1 then
				self._bagObj = rtnObj.packet
				game.runningScene:addChild(require("utility.LackBagSpaceLayer").new({
				bagObj = self._bagObj,
				callback = function(data)
					extendBag(data)
				end
				}), MAX_ZORDER)
			elseif rtnObj.isDead == 1 then
				ResMgr.showErr(2900097)
				game.player:getGuildMgr():forceUpdateFbInfoLayer({
				reqEndFunc = function()
					pop_scene()
				end
				})
			else
				pop_scene()
				game.player:getGuildMgr():setFbHasFight(true)
				local scene = require("game.guild.guildFuben.GuildFubenBattleScene").new({
				data = data,
				id = self._id
				})
				push_scene(scene)
			end
			GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		end
		})
	end
	self._rootnode.startBtn:addHandleOfControlEvent(function()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		--[[
		if #self._formHero == 0 then
			ResMgr.showErr(2900097)
		elseif #self._formHero < 6 then
			local tipLayer = require("game.huashan.HuaShanHeroLessTip").new({listener = fight})
			game.runningScene:addChild(tipLayer, MAX_ZORDER)
		else
			fight()
		end
		]]
		if #self._formHero == 0 then
			ResMgr.showErr(2900097)
		else
			fight()
		end
	end,
	CCControlEventTouchUpInside)
	
	local function onTabBtn(tag)
		self._viewType = tag
		self._heroList:resetCellNum(#self._groupHerosData[tag])
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
	self._formHero = {}
	for i, v in ipairs(self._heros) do
		v.id = v.cardId
		if v.resId == 1 or v.resId == 2 then
			v.bIsSelf = true
			if self._needLeadRole then
				table.insert(self._formHero, {
				index = i,
				pos = v.pos
				})
			end
		else
			v.bIsSelf = false
		end
		if v.bIsSelf == true then
			v.state = GUILD_FUBEN_HERO_STATE.selected
		elseif v.isUse == 0 then
			v.state = GUILD_FUBEN_HERO_STATE.unselected
		elseif v.isUse == 1 then
			v.state = GUILD_FUBEN_HERO_STATE.hasJoined
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

function GuildFubenChooseHeroScene:groupHero()
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

function GuildFubenChooseHeroScene:getEmptyPos()
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

function GuildFubenChooseHeroScene:initHeroListView()
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
	local sz = self._rootnode.scrollListView:getContentSize()
	local heroItem = require("game.guild.guildFuben.GuildFubenHeroItem")
	self._heroList = require("utility.TableViewExt").new({
	size = CCSizeMake(sz.width, sz.height - self._rootnode.content_msg_lbl:getContentSize().height - 5),
	direction = kCCScrollViewDirectionVertical,
	createFunc = function(idx)
		local item = heroItem.new()
		idx = idx + 1
		return item:create({
		viewSize = sz,
		itemData = self._groupHerosData[self._viewType][idx],
		idx = idx
		})
	end,
	refreshFunc = function(cell, idx)
		idx = idx + 1
		cell:refresh({
		idx = idx,
		itemData = self._groupHerosData[self._viewType][idx]
		})
	end,
	cellNum = #self._groupHerosData[self._viewType],
	cellSize = heroItem.new():getContentSize(),
	touchFunc = function(cell)
		local idx = cell:getIdx() + 1
		local pos = cell:convertToNodeSpace(ccp(posX, posY))
		local sz = cell:getContentSize()
		local i = 0
		if pos.x > sz.width * 0.8 and pos.x < sz.width then
			i = 5
		elseif pos.x > sz.width * 0.6 then
			i = 4
		elseif pos.x > sz.width * 0.4 then
			i = 3
		elseif pos.x > sz.width * 0.2 then
			i = 2
		elseif 0 < pos.x then
			i = 1
		end
		if i >= 1 and i <= 5 then
			local info = self._groupHerosData[self._viewType][idx]
			if info and info[i] then
				for k, v in ipairs(self._heros) do
					if info[i].id == v.id then
						if info[i].state == GUILD_FUBEN_HERO_STATE.hasJoined then
							ResMgr.showErr(2900087)
							break
						end
						if info[i].state == GUILD_FUBEN_HERO_STATE.selected then
							ResMgr.showErr(2900096)
							break
						end
						if info[i].state == GUILD_FUBEN_HERO_STATE.unselected then
							if #self._formHero >= 6 then
								ResMgr.showErr(2900095)
								break
							end
							if existSameHero(info[i].resId) then
								ResMgr.showErr(600005)
								break
							end
							info[i].state = GUILD_FUBEN_HERO_STATE.selected
							self._heroList:reloadCell(idx - 1, {itemData = info})
							table.insert(self._formHero, {
							index = k,
							pos = self:getEmptyPos()
							})
							self._chooseItemList:resetListByNumChange(#self._formHero)
							self._rootnode.numLabel:setString(tostring(#self._formHero))
							if 1 < #self._formHero then
								local w = self._chooseItemList:cellAtIndex(0):getContentSize().width * #self._formHero
								if w > self._chooseItemList:getContentSize().width then
									self._chooseItemList:setContentOffset(ccp(self._chooseItemList:getContentSize().width - w, 0), true)
								end
							end
							break
						end
						if info[i].state == GUILD_FUBEN_HERO_STATE.zhuzhen_Joined then
							show_tip_label(common:getLanguageString("@zhuzhen_InBattle"))
						end
						break
					end
				end
			end
		end
	end
	})
	self._heroList:setPosition(0, 9)
	self._rootnode.scrollListView:addChild(self._heroList)
end

function GuildFubenChooseHeroScene:initChooseListView()
	local sz = self._rootnode.selectListView:getContentSize()
	local selectedItem = require("game.guild.guildFuben.GuildFubenHeroSelectItem")
	self._chooseItemList = require("utility.TableViewExt").new({
	size = cc.size(sz.width, sz.height),
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
		local curIdx = self._formHero[idx].index
		if self._heros[curIdx].bIsSelf == true and self._needLeadRole == true then
			ResMgr.showErr(2900088)
		else
			self._heros[curIdx].state = GUILD_FUBEN_HERO_STATE.unselected
			local bBreak = false
			for k, v in ipairs(self._groupHerosData[self._viewType]) do
				for i = 1, 5 do
					if v[i] and v[i].id == self._heros[curIdx].id then
						self._heroList:reloadCell(k - 1, {itemData = v})
						bBreak = true
					end
				end
				if bBreak then
					break
				end
			end
			table.remove(self._formHero, idx)
			self._chooseItemList:resetListByNumChange(#self._formHero)
			self._rootnode.numLabel:setString(tostring(#self._formHero))
		end
	end
	})
	self._chooseItemList:setPosition(0, 0)
	self._rootnode.selectListView:addChild(self._chooseItemList)
end

function GuildFubenChooseHeroScene:onEnter()
	game.runningScene = self
	GuildFubenChooseHeroScene.super.onEnter(self)
end

function GuildFubenChooseHeroScene:onExit()
	GuildFubenChooseHeroScene.super.onExit(self)
	CCTextureCache:sharedTextureCache():removeUnusedTextures()
end

return GuildFubenChooseHeroScene