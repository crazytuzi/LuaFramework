local data_ui_ui = require("data.data_ui_ui")

local BaseScene = require("game.BaseSceneExt")
local HuaShanSettingScene = class("HeroShowScene", BaseScene)

local VIEW_TYPE = {
ALL = 1,
GONG = 2,
FANG = 3,
FU = 4
}

local HUASHAN_FORM_INFO = "huashan_form_info" .. tostring(game.player.m_uid)

function HuaShanSettingScene:ctor(param)
	HuaShanSettingScene.super.ctor(self, {
	contentFile = "huashan/huashan_choose_scene.ccbi",
	bottomFile = "huashan/huashan_bottom.ccbi",
	topFile = "huashan/huashan_top.ccbi"
	})
	
	local _bg = display.newSprite("ui_common/common_bg.png")
	local _bgW = display.width
	self._heros = HelpLineModel:setHeroHelpState(param.heros)
	self._floor = param.floor
	self.enemyCombat = param.enemyCombat
	self.enemyName = param.enemyName
	local _bgH = display.height - self._rootnode.topFrameNode:getContentSize().height
	_bg:setPosition(_bgW / 2, _bgH / 2)
	_bg:setScaleX(_bgW / _bg:getContentSize().width)
	_bg:setScaleY(_bgH / _bg:getContentSize().height)
	self:addChild(_bg, 0)
	self._rootnode.content_msg_lbl:setString(data_ui_ui[14].content)
	local function getHeroById(id)
		for k, v in ipairs(self._heros) do
			if id == v.id then
				return k, v
			end
		end
		return nil
	end
	local function loadForm()
		self._formHero = {}
		local tbl = HelpLineModel:getHeroHelpTbl()
		local str = CCUserDefault:sharedUserDefault():getStringForKey(HUASHAN_FORM_INFO, "")
		for id, pos in string.gmatch(str, "%[(%d+),(%d+)%]") do
			local k, hero = getHeroById(checknumber(id))
			if hero and hero.life > 0 and not tbl[hero.cardId] then
				hero.state = 1
				table.insert(self._formHero, {
				index = k,
				pos = checknumber(pos)
				})
			end
		end
		self._rootnode.numLabel:setString(tostring(#self._formHero))
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
					resId = hero.cardId,
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
		for k, v in ipairs(self._formHero) do
			if self._heros[v.index] then
				self._heros[v.index].state = -1
			end
		end
		pop_scene()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
	end,
	CCControlEventTouchUpInside)
	
	self._rootnode.setFormBtn:addHandleOfControlEvent(function()
		self._rootnode.setFormBtn:setEnabled(false)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		if #self._formHero == 0 then
			show_tip_label(common:getLanguageString("@HintSelectHero"))
			self._rootnode.setFormBtn:setEnabled(true)
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
			zdlNum = data.zdl,
			closeListener = function()
				for k, v in ipairs(self._formHero) do
					v.pos = formHero[k].pos
				end
			end,
			callback = function()
			end
			})
		end
		})
		self._rootnode.setFormBtn:setEnabled(true)
	end,
	CCControlEventTouchUpInside)
	
	local function fight()
		local str = getfmtstr()
		CCUserDefault:sharedUserDefault():setStringForKey(HUASHAN_FORM_INFO, str)
		CCUserDefault:sharedUserDefault():flush()
		RequestHelper.huashan.fight({
		fmt = getfmtstr(),
		floor = self._floor,
		callback = function(data)
			pop_scene()
			local scene = require("game.huashan.HuaShanBattleScene").new({
			data = data,
			enemyName = self.enemyName,
			enemyCombat = self.enemyCombat
			})
			display.replaceScene(scene)
			GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		end
		})
	end
	self._rootnode.startBtn:addHandleOfControlEvent(function()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		--[[
		if #self._formHero == 0 then
			show_tip_label(common:getLanguageString("@HintSelectHero"))
		elseif #self._formHero < 6 then
			local tipLayer = require("game.huashan.HuaShanHeroLessTip").new({listener = fight})
			self:addChild(tipLayer, 10)
		else
			fight()
		end
		]]		
		if #self._formHero == 0 then
			show_tip_label(common:getLanguageString("@HintSelectHero"))
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
	self._viewType = VIEW_TYPE.ALL
	loadForm()
	self:groupHero()
	self:initChooseListView()
	self:initHeroListView()
end

function HuaShanSettingScene:groupHero()
	local heroGroup = {}
	for k, v in pairs(VIEW_TYPE) do
		heroGroup[v] = {}
	end
	for k, v in pairs(self._heros) do
		local hero = ResMgr.getCardData(v.cardId)
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

function HuaShanSettingScene:getEmptyPos()
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

function HuaShanSettingScene:initHeroListView()
	
	local function existSameHero(id)
		for k, v in ipairs(		self._formHero) do
			if self._heros[v.index].cardId == id then
				return true
			end
		end
		return false
	end
	local sz = self._rootnode.scrollListView:getContentSize()
	local heroItem = require("game.huashan.HuaShanHeroItem")
	self._heroList = require("utility.TableViewExt").new({
	size = cc.size(sz.width, sz.height - 45),
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
	touchFunc = function(cell,x, y)
		local idx = cell:getIdx() + 1
		local pos = cell:convertToNodeSpace(cc.p(x, y))
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
						if info[i].life == 0 then
							show_tip_label(common:getLanguageString("@HeroDead"))
							break
						end
						if info[i].state ~= 1 then
							if info[i].state == 4 then
								show_tip_label(common:getLanguageString("@zhuzhen_InBattle"))
								return
							end
							if #self._formHero >= 6 then
								show_tip_label(common:getLanguageString("@MaxBattleMember"))
								break
							end
							if existSameHero(info[i].cardId) then
								show_tip_label(common:getLanguageString("@RefuseSameHero"))
								break
							end
							info[i].state = 1
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
									self._chooseItemList:setContentOffset(cc.p(self._chooseItemList:getContentSize().width - w, 0), true)
								end
							end
							break
						end
						show_tip_label(common:getLanguageString("@HeroAlreadyInBattle"))
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

function HuaShanSettingScene:initChooseListView()
	local sz = self._rootnode.selectListView:getContentSize()
	local selectedItem = require("game.huashan.HuaShanSelectItem")
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
		self._heros[self._formHero[idx].index].state = -1
		local bBreak = false
		for k, v in ipairs(self._groupHerosData[self._viewType]) do
			for i = 1, 5 do
				if v[i] and v[i].id == self._heros[self._formHero[idx].index].id then
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
	})
	self._chooseItemList:setPosition(0, 0)
	self._rootnode.selectListView:addChild(self._chooseItemList)
end

function HuaShanSettingScene:onExit()
	HuaShanSettingScene.super.onExit(self)
	CCTextureCache:sharedTextureCache():removeUnusedTextures()
end

return HuaShanSettingScene