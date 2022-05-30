local data_ui_ui = require("data.data_ui_ui")
local data_huodongfuben_huodongfuben

local BaseScene = require("game.BaseSceneExt")
local formSettingBaseScene = class("HeroShowScene", BaseScene)

local VIEW_TYPE = {
ALL = 1,
GONG = 2,
FANG = 3,
FU = 4
}
local HELP_VIEW_TYPE = {Normal = 1, Help = 2}
local MAX_ZORDER = 11

function formSettingBaseScene:ctor(param)
	formSettingBaseScene.super.ctor(self, {
	contentFile = "huashan/huashan_choose_scene.ccbi",
	bottomFile = "huashan/huashan_bottom.ccbi",
	topFile = "huashan/huashan_top.ccbi"
	})
	
	local _bg = display.newSprite("ui_common/common_bg.png")
	local _bgW = display.width
	self._formHero = param.formHero
	self._content_label = param.content_label or data_ui_ui[14].content
	if param.formHero then
		self._save_form_title = nil
	else
		self._save_form_title = param.save_form_title
	end
	self._checkLife = false
	self._fbId = param.fbId
	self._sysId = param.sysId
	local showFunc = param.showFunc
	local changeFormaitonFunc = param.changeFormaitonFunc
	self._needLeadRole = param.needLeadRole
	self._formSettingType = param.formSettingType
	if self._formSettingType == nil then
		show_tip_label(common:getLanguageString("@shujuyc1"))
		return
	elseif self._formSettingType == FormSettingType.ZhenShenFuBenType then
		data_huodongfuben_huodongfuben = require("data.data_zhenshenfuben_zhenshenfuben")
		self._content_label = data_huodongfuben_huodongfuben[self._fbId].recommend
		self._rootnode.save_node:setVisible(false)
		self._rootnode.startBtn:setVisible(true)
		self._fbId = param.fbId
		self._sysId = param.sysId
	elseif self._formSettingType == FormSettingType.HuoDongFuBenType then
		data_huodongfuben_huodongfuben = require("data.data_huodongfuben_huodongfuben")
		self._content_label = data_huodongfuben_huodongfuben[self._fbId].recommend
		self._rootnode.save_node:setVisible(true)
		self._rootnode.startBtn:setVisible(false)
		self._bHasChangeFormation = false
		self._bHasChangeFormList = false
		self._bHasSaveFormaiton = false
		self._zhandouLi = 0
	elseif self._formSettingType == FormSettingType.BangPaiZhanType then
		self._checkLife = true
		self.btnName = common:getLanguageString("@Kaishitiaozhan")
	elseif self._formSettingType == FormSettingType.KuaFuZhanType then
		self.btnName = param.btnName
	elseif self._formSettingType == FormSettingType.BangPaiFuBenType then
		self._content_label = data_ui_ui[12].content
	elseif self._formSettingType == FormSettingType.HuaShanType then
		self._checkLife = true
	end
	self._helpViewType = HELP_VIEW_TYPE.Normal
	self._rootnode.setFormAdjust:setVisible(false)
	if showFunc ~= nil then
		showFunc()
	end
	self._confirmFunc = param.confirmFunc
	self._closeFunc = param.closeFunc
	if self._formSettingType == FormSettingType.BangPaiFuBenType or self._formSettingType == FormSettingType.BangPaiZhanType or self._formSettingType == FormSettingType.HuaShanType then
		self._heros = param.heros or {}
	else
		self._heros = HelpLineModel:setHeroHelpState(param.heros or {})
		if self._formHero then
			for _, formHero in pairs(self._formHero) do
				local heroId = param.heros[formHero.index].id
				for key, hero in pairs(self._heros) do
					if hero.id == heroId then
						formHero.index = key
						break
					end
				end
			end
		end
	end
	local _bgH = display.height - self._rootnode.topFrameNode:getContentSize().height
	_bg:setPosition(_bgW / 2, _bgH / 2)
	_bg:setScaleX(_bgW / _bg:getContentSize().width)
	_bg:setScaleY(_bgH / _bg:getContentSize().height)
	self:addChild(_bg, 0)
	self._rootnode.content_msg_lbl:setString(self._content_label)
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
	local function getHelpfmtstr()
		local str = "["
		for k, v in ipairs(self._helpHeros) do
			local hero = self._heros[v.index]
			if hero then
				str = str .. string.format("[%s,%d],", hero.id, k)
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
			local helpfmt = getHelpfmtstr()
			changeFormaitonFunc(self._heros, self._zhandouLi, fmt, helpfmt)
		end
	end
	local function saveFormation()
		local str = getfmtstr()
		RequestHelper.challengeFuben.save({
		aid = self._fbId,
		fmt = str,
		sysId = self._sysId,
		errback = function()
			self._rootnode.saveFormBtn:setEnabled(true)
		end,
		callback = function(data)
			self._rootnode.saveFormBtn:setEnabled(true)
			self._bHasSaveFormaiton = true
			self._zhandouLi = data.zhandouLi
			changeFormFunc()
			pop_scene()
		end
		})
	end
	self._rootnode.returnBtn:addHandleOfControlEvent(function()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		if self._formSettingType == FormSettingType.HuoDongFuBenType then
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
		else
			pop_scene()
		end
		if self._closeFunc then
			self._closeFunc()
		end
	end,
	CCControlEventTouchUpInside)
	
	local function fight()
		local str = getfmtstr()
		if self._save_form_title then
			CCUserDefault:sharedUserDefault():setStringForKey(self._save_form_title, str)
			CCUserDefault:sharedUserDefault():flush()
		end
		if self._confirmFunc then
			self._confirmFunc(str)
		end
	end
	if self.btnName then
		resetctrbtnString(self._rootnode.startBtn, self.btnName)
	end
	self._rootnode.startBtn:addHandleOfControlEvent(function()
		if #self._formHero == 0 then
			show_tip_label(common:getLanguageString("@HintSelectHero"))
			return
		end
		if self._formSettingType == FormSettingType.ZhenShenFuBenType then
			local fbInfo = data_huodongfuben_huodongfuben[self._fbId]
			local formHero = getFormInfo()
			local isHasCard = false
			for k, v in ipairs(formHero) do
				if v.resId == fbInfo.cardId then
					isHasCard = true
					break
				end
			end
			if isHasCard == false then
				show_tip_label(common:getLanguageString("@zhenshenerror3"))
				return
			end
		end
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		--[[
		if #self._formHero < 6 then
			local tipLayer = require("game.huashan.HuaShanHeroLessTip").new({listener = fight})
			game.runningScene:addChild(tipLayer, MAX_ZORDER)
		else
			fight()
		end
		]]
		fight()
	end,
	CCControlEventTouchUpInside)
	
	self._rootnode.saveFormBtn:addHandleOfControlEvent(function()
		if #self._formHero == 0 then
			ResMgr.showErr(2900097)
		else
			self._rootnode.saveFormBtn:setEnabled(false)
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
				self._rootnode.saveFormBtn:setEnabled(true)
				msgBox:removeSelf()
			end
			})
			game.runningScene:addChild(msgBox, MAX_ZORDER)
		end
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
	end,
	CCControlEventTouchUpInside)
	
	self._rootnode.setFormAdjust:setVisible(false)
	self._rootnode.setFormAdjust:addHandleOfControlEvent(function()
		if self._helpViewType == HELP_VIEW_TYPE.Normal then
			self._helpViewType = HELP_VIEW_TYPE.Help
			self._zhuzhenItemList:setVisible(true)
			self._chooseItemList:setVisible(false)
			local tb = HelpLineModel:getHeroHelpTbl()
			self._rootnode.numLabel:setString(tostring(#self._helpHeros) .. "/" .. tostring(tb.num))
			common:reSetButtonState(self._rootnode.setFormAdjust, common:getLanguageString("@FormAdjust_1"))
		else
			self._helpViewType = HELP_VIEW_TYPE.Normal
			self._zhuzhenItemList:setVisible(false)
			self._chooseItemList:setVisible(true)
			self._rootnode.numLabel:setString(tostring(#self._formHero))
			common:reSetButtonState(self._rootnode.setFormAdjust, common:getLanguageString("@FormAdjust_2"))
		end
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
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
			closeListener = function(bHasChange)
				for k, v in ipairs(self._formHero) do
					v.pos = formHero[k].pos
				end
				self._rootnode.setFormBtn:setEnabled(true)
				if self._formSettingType == FormSettingType.HuoDongFuBenType then
					self._bHasChangeFormation = bHasChange
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
	
	local function onTabBtn(tag)
		self._viewType = tag
		self._heroList:resetListByNumChange(#self._groupHerosData[tag])
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_yeqian))
	end
	
	local function loadForm()
		for k, v in ipairs(self._heros) do
			v.state = HERO_STATE.unselected
			if v.resId == 1 or v.resId == 2 then
				v.bIsSelf = true
			else
				v.bIsSelf = false
			end
			if self._formSettingType == FormSettingType.BangPaiFuBenType then
			--if self._formSettingType == FormSettingType.BangPaiFuBenType or  self._formSettingType == FormSettingType.KuaFuZhanType then
				if self._formHero == nil then
					self._formHero = {}
				end
				if v.bIsSelf == true then				
					if self._needLeadRole then
						table.insert(self._formHero, {
						index = k,
						pos = v.pos
						})
					end
					v.state = HERO_STATE.selected
				elseif v.isUse == 0 then
					v.state = HERO_STATE.unselected
				elseif v.isUse == 1 then
					v.state = HERO_STATE.hasJoined
				end
			end
		end
		if self._helpHeros == nil then
			self._helpHeros = {}
		end
		
		--ÖúÕ½Î»ÏÀ¿Í
		if self._formSettingType ~= FormSettingType.BangPaiFuBenType and self._formSettingType ~= FormSettingType.HuaShanType and self._formSettingType ~= FormSettingType.BangPaiZhanType then
			local tbl = HelpLineModel:getHeroHelpTbl()
			for k, v in ipairs(self._heros) do
				if tbl[v.resId] then
					v.state = HERO_STATE.zhuzhen
					table.insert(self._helpHeros, {index = k})
				end
			end
		end
		
		if not self._formHero and self._save_form_title then
			self._formHero = {}
			local str = CCUserDefault:sharedUserDefault():getStringForKey(self._save_form_title, "")
			for id, pos in string.gmatch(str, "%[(%d+),(%d+)%]") do
				local k, hero = getHeroById(checknumber(id))
				if hero and (not self._checkLife or 0 < hero.life) and hero.state ~= HERO_STATE.zhuzhen then
					hero.state = HERO_STATE.selected
					table.insert(self._formHero, {
					index = k,
					pos = checknumber(pos)
					})
				end
			end
		else
			local tbl = {}
			if self._formSettingType ~= FormSettingType.BangPaiFuBenType and self._formSettingType ~= FormSettingType.HuaShanType and self._formSettingType ~= FormSettingType.BangPaiZhanType then
				tbl = HelpLineModel:getHeroHelpTbl()
			end
			if self._formHero then
				for k, v in ipairs(self._heros) do
					for _, m in ipairs(self._formHero) do
						if m.index == k and tbl[v.resId] == nil then
							v.state = HERO_STATE.selected
							break
						end
					end
				end
			end
		end
		
		if self._formSettingType ~= FormSettingType.BangPaiFuBenType and self._formSettingType ~= FormSettingType.HuaShanType and self._formSettingType ~= FormSettingType.BangPaiZhanType then
			local tbl = HelpLineModel:getHeroHelpTbl()
			local newFormHero = {}
			for k, v in ipairs(self._formHero) do
				local hero = self._heros[v.index]
				if not tbl[hero.resId] then
					newFormHero[#newFormHero + 1] = v
				end
			end
			self._formHero = newFormHero
		end
		self._rootnode.numLabel:setString(tostring(#self._formHero))
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

function formSettingBaseScene:groupHero()
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
			table.insert(t[#t], v)
		end
	end
end

function formSettingBaseScene:getEmptyPos()
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

function formSettingBaseScene:initHeroListView()
	local function existSameHero(resId)
		for k, v in ipairs(self._formHero) do
			if self._heros[v.index].resId == resId then
				return true
			end
		end
		return false
	end
	local fbinfo
	if self._formSettingType == FormSettingType.ZhenShenFuBenType or self._formSettingType == FormSettingType.HuoDongFuBenType then
		fbinfo = data_huodongfuben_huodongfuben[self._fbId]
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
	touchFunc = function(cell, x, y)
		local idx = cell:getIdx() + 1
		local function info(i)
			local info = self._groupHerosData[self._viewType][idx]
			if info and info[i] then
				for k, v in ipairs(self._heros) do
					if info[i].id == v.id then
						if self._checkLife and info[i].life == 0 then
							show_tip_label(common:getLanguageString("@HeroDead"))
							break
						end
						if info[i].state == HERO_STATE.selected then
							show_tip_label(common:getLanguageString("@HeroAlreadyInBattle"))
							break
						end
						if info[i].state == HERO_STATE.hasJoined then
							show_tip_label(common:getLanguageString("@HeroAlreadyInBattle"))
							break
						end
						if info[i].state ~= HERO_STATE.selected then
							if info[i].state == HERO_STATE.zhuzhen then
								show_tip_label(common:getLanguageString("@zhuzhen_InBattle"))
								return
							end
							if self._helpViewType == HELP_VIEW_TYPE.Normal then
								if #self._formHero >= 6 then
									show_tip_label(common:getLanguageString("@MaxBattleMember"))
									break
								end
								if existSameHero(info[i].resId) then
									show_tip_label(common:getLanguageString("@RefuseSameHero"))
									break
								end
								if self._formSettingType == FormSettingType.ZhenShenFuBenType then
									self._bHasChangeFormList = true
								end
								info[i].state = HERO_STATE.selected
								table.insert(self._formHero, {
								index = k,
								pos = self:getEmptyPos()
								})
							
								info[i].order = #self._formHero
								
								
								dump("3333333333333333333333333")
								dump(self._formHero)
								dump(info[i])
								
								
								self._chooseItemList:resetListByNumChange(#self._formHero)
								self._rootnode.numLabel:setString(tostring(#self._formHero))
								self._heroList:reloadCell(
								idx - 1,
								{itemData = info, info = fbinfo}
								)
								if #self._formHero > 1 then
									local w = self._chooseItemList:cellAtIndex(0):getContentSize().width * #self._formHero
									if w > self._chooseItemList:getContentSize().width then
										self._chooseItemList:setContentOffset(ccp(self._chooseItemList:getContentSize().width - w, 0), true)
									end
								end
								break
							end
							local tb = HelpLineModel:getHeroHelpTbl()
							if #self._helpHeros < tb.num then
								info[i].state = HERO_STATE.zhuzhen
								table.insert(self._helpHeros,
								{index = k}
								)
								info[i].order = #self._helpHeros
								self._zhuzhenItemList:resetListByNumChange(#self._helpHeros)
								self._rootnode.numLabel:setString(tostring(#self._helpHeros) .. "/" .. tostring(tb.num))
								self._heroList:reloadCell(idx - 1, {itemData = info, info = fbinfo})
								if 1 < #self._helpHeros then
									local w = self._zhuzhenItemList:cellAtIndex(0):getContentSize().width * #self._helpHeros
									if w > self._zhuzhenItemList:getContentSize().width then
										self._zhuzhenItemList:setContentOffset(ccp(self._zhuzhenItemList:getContentSize().width - w, 0), true)
									end
								end
								break
							end
							show_tip_label(common:getLanguageString("@zhuzhenMaxError"))
						end
						break
					end
				end
			end
		end
		for i = 1, 5 do
			local icon = cell:getIcon(i)
			if icon ~= nil then
				local pos = icon:convertToNodeSpace(cc.p(x, y))
				if cc.rectContainsPoint(cc.rect(0, 0, icon:getContentSize().width, icon:getContentSize().height), pos) then
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
function formSettingBaseScene:initChooseListView()
	local sz = self._rootnode.selectListView:getContentSize()
	local selectedItem = require("game.huashan.HuaShanSelectItem")
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
		local curIndex = self._formHero[idx].index
		if self._heros[curIndex].bIsSelf == true and self._needLeadRole == true then
			ResMgr.showErr(2900088)
			return
		end
		self._heros[curIndex].state = HERO_STATE.unselected
		local bBreak = false
		for k, v in ipairs(self._groupHerosData[self._viewType]) do
			for i = 1, 5 do
				if v[i] and v[i].id == self._heros[curIndex].id then
					if self._formSettingType == FormSettingType.ZhenShenFuBenType or self._formSettingType == FormSettingType.HuoDongFuBenType then
						self._heroList:reloadCell(k - 1, {
						itemData = v,
						info = data_huodongfuben_huodongfuben[self._fbId]
						})
						if self._formSettingType == FormSettingType.HuoDongFuBenType then
							self._bHasChangeFormList = true
						end
					else
						self._heroList:reloadCell(k - 1, {itemData = v})
					end
					bBreak = true
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
	})
	self._zhuzhenItemList = require("utility.TableViewExt").new({
	size = cc.size(sz.width, sz.height),
	direction = kCCScrollViewDirectionHorizontal,
	createFunc = function(idx)
		local item = selectedItem.new()
		idx = idx + 1
		return item:create({
		viewSize = sz,
		itemData = self._heros[self._helpHeros[idx].index],
		idx = idx
		})
	end,
	refreshFunc = function(cell, idx)
		idx = idx + 1
		cell:refresh({
		idx = idx,
		itemData = self._heros[self._helpHeros[idx].index]
		})
	end,
	cellNum = #self._helpHeros,
	cellSize = selectedItem.new():getContentSize(),
	touchFunc = function(cell)
		local idx = cell:getIdx() + 1
		local curIndex = self._helpHeros[idx].index
		if self._heros[curIndex].bIsSelf == true and self._needLeadRole == true then
			ResMgr.showErr(2900088)
			return
		end
		self._heros[curIndex].state = HERO_STATE.unselected
		local bBreak = false
		for k, v in ipairs(self._groupHerosData[self._viewType]) do
			for i = 1, 5 do
				if v[i] and v[i].id == self._heros[curIndex].id then
					if self._formSettingType == FormSettingType.ZhenShenFuBenType or self._formSettingType == FormSettingType.HuoDongFuBenType then
						self._heroList:reloadCell(k - 1, {
						itemData = v,
						info = data_huodongfuben_huodongfuben[self._fbId]
						})
						if self._formSettingType == FormSettingType.HuoDongFuBenType then
							self._bHasChangeFormList = true
						end
					else
						self._heroList:reloadCell(k - 1, {itemData = v})
					end
					bBreak = true
				end
			end
			if bBreak then
				break
			end
		end
		self._heros[curIndex].order = 0
		table.remove(self._helpHeros, idx)
		for i, v in ipairs(self._helpHeros) do
			self._heros[v.index].order = i
		end
		self._zhuzhenItemList:resetListByNumChange(#self._helpHeros)
		local tb = HelpLineModel:getHeroHelpTbl()
		self._rootnode.numLabel:setString(tostring(#self._helpHeros) .. "/" .. tostring(tb.num))
	end
	})
	self._zhuzhenItemList:setPosition(0, 0)
	self._zhuzhenItemList:setVisible(false)
	self._rootnode.selectListView:addChild(self._chooseItemList)
	self._rootnode.selectListView:addChild(self._zhuzhenItemList)
end

function formSettingBaseScene:onEnter()
	game.runningScene = self
	formSettingBaseScene.super.onEnter(self)
end

function formSettingBaseScene:onExit()
	formSettingBaseScene.super.onExit(self)
	CCTextureCache:sharedTextureCache():removeUnusedTextures()
end

return formSettingBaseScene