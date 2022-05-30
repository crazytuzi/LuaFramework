local data_item_item = require("data.data_item_item")
local data_card_card = require("data.data_card_card")
--local data_fashion_fashion = require("data.data_fashion_fashion")
local data_cheats_cheats = require("data.data_miji_miji")

local Item = class("item", function()
	return CCTableViewCell:new()
end)

function Item:getContentSize()
	return cc.size(105, 95)
end

function Item:create(param)
	local _viewSize = param.viewSize
	local _itemData = param.itemData
	self.sprite = display.newSprite("ui/ui_empty.png")
	self.sprite:setPosition(self:getContentSize().width / 2, _viewSize.height * 0.57)
	self:addChild(self.sprite)
	self.nameLabel = ui.newTTFLabelWithOutline({
	text = "",
	font = FONTS_NAME.font_fzcy,
	size = 20,
	dimensions = cc.size(80, 100),
	outlineColor = FONT_COLOR.BLACK,
	align = ui.TEXT_ALIGN_CENTER,
	valign = TEXT_VALIGN_TOP,
	})
	self.nameLabel:align(display.TOP_CENTER)
	self.nameLabel:setPosition(self:getContentSize().width / 2, 40)
	self:addChild(self.nameLabel)
	self.numLabel = ui.newTTFLabelWithOutline({
	text = "",
	font = FONTS_NAME.font_fzcy,
	size = 20,
	color = FONT_COLOR.GREEN_1,
	align = ui.TEXT_ALIGN_RIGHT
	})
	self:addChild(self.numLabel)
	self:refresh(param)
	return self
end

function Item:refresh(param)
	local _itemData = param.itemData
	local _resType = ResMgr.getResType(_itemData.t)
	ResMgr.refreshIcon({
	itemBg = self.sprite,
	id = _itemData.id,
	resType = _resType
	})
	self.nameLabel:setString(ResMgr.getItemNameByType(_itemData.id, _resType))
	self.nameLabel:setColor(ResMgr.getItemNameColorByType(_itemData.id, _resType))
	self.numLabel:setString(tostring(_itemData.num))
	self.numLabel:setPosition(cc.p(self:getContentSize().width - self.numLabel:getContentSize().width / 2 - 10, self:getContentSize().height * 0.5))
end

local function herosort(l, r)
	if l.star ~= r.star then
		return l.star < r.star
	elseif l.cls == 0 and r.cls > 0 then
		return true
	elseif l.cls > 0 and r.cls > 0 then
		if l.cls == r.cls then
			return l.level < r.level
		else
			return l.cls < r.cls
		end
	elseif l.cls == 0 and r.cls == 0 then
		return l.level + l.resId + data_card_card[l.resId].arr_zizhi[1] > r.level + r.resId + data_card_card[r.resId].arr_zizhi[1]
	end
end

local equipsort = function(l, r)
	if l.star ~= r.star then
		return l.star < r.star
	else
		return l.level < r.level
	end
end

local skillsort = function(l, r)
	if l.star ~= r.star then
		return l.star < r.star
	else
		return l.level < r.level
	end
end

local cheatssort = function(l, r)
	if l.star ~= r.star then
		return l.star < r.star
	else
		return l.level < r.level
	end
end

local BaseScene = require("game.BaseScene")
local SplitStoveScene = class("SplitStoveScene", BaseScene)

local BTN_NAME_MAPPING = {}
local VIEW_TYPE = {REFINE = 1, REBORN = 2}

function SplitStoveScene:init()
	for _, v in pairs(VIEW_TYPE) do
		for _, t in pairs(LIAN_HUA_TYEP) do
			local n = #self._itemsData[v][t]
			for i = 1, n do
				table.remove(self._itemsData[v][t], 1)
			end
		end
	end
	for _, t in pairs(LIAN_HUA_TYEP) do
		local info = self._list[t]
		for k, v in ipairs(info) do
			if t == LIAN_HUA_TYEP.HERO then
				v.name = ResMgr.getCardData(v.resId).name
			elseif t == LIAN_HUA_TYEP.SHIZHUANG then
				v.name = data_item_item[v.resId].name
			elseif t == LIAN_HUA_TYEP.CHEATS then
				v.name = data_cheats_cheats[v.resId].name
			else
				v.name = data_item_item[v.resId].name
			end
			if v.refining == 1 then
				table.insert(self._itemsData[VIEW_TYPE.REFINE][t], k)
			end
			if v.reborn == 1 then
				table.insert(self._itemsData[VIEW_TYPE.REBORN][t], k)
			end
		end
	end
end

function SplitStoveScene:ctor()
	game.runningScene = self
	SplitStoveScene.super.ctor(self, {
	contentFile = "lianhualu/ccb_lianhualu.ccbi",
	subTopFile = "lianhualu/lianhualu_tab_view.ccbi",
	bgImage = "ui/jpg_bg/lianhualu_bg2.jpg",
	scaleMode = 1
	})
	
	ResMgr.removeBefLayer()
	display.addSpriteFramesWithFile("icon/icon_equip.plist", "icon/icon_equip.png")
	BTN_NAME_MAPPING[1] = common:getLanguageString("@tianjiaxiake")
	BTN_NAME_MAPPING[2] = common:getLanguageString("@tianjiazhuangbei")
	BTN_NAME_MAPPING[3] = common:getLanguageString("@tianjiawuxue")
	BTN_NAME_MAPPING[4] = common:getLanguageString("@tianjiachongwu")
	BTN_NAME_MAPPING[5] = common:getLanguageString("@sz_tianjiashizhuang")
	BTN_NAME_MAPPING[6] = common:getLanguageString("@tianjiaCheats")
	BTN_NAME_MAPPING[7] = common:getLanguageString("@tianjiahuanyipi")
	if game.player:getAppOpenData().lianhuashenmi == APPOPEN_STATE.close then
		self._rootnode.secretShopBtn:setVisible(false)
	else
		self._rootnode.secretShopBtn:setVisible(true)
	end
	local xunhuanEffect = ResMgr.createArma({
	resType = ResMgr.UI_EFFECT,
	armaName = "lianhualuhuoyan",
	isRetain = true
	})
	xunhuanEffect:setPosition(self._rootnode.firePos:getContentSize().width / 2, xunhuanEffect:getContentSize().height / 7)
	self._rootnode.firePos:addChild(xunhuanEffect, -10)
	local function resetQuickBtn(tag)
		for enumType, i in pairs(LIAN_HUA_TYEP) do
			if i ~= tag then
				self._rootnode["quickAddBtn_" .. i]:setTitleForState(BTN_NAME_MAPPING[i], CCControlStateNormal)
				self._rootnode["quickAddBtn_" .. i].index = nil
			else
				self._rootnode["quickAddBtn_" .. i]:setTitleForState(BTN_NAME_MAPPING[7], CCControlStateNormal)
			end
		end
	end
	self._selectedType = LIAN_HUA_TYEP.HERO
	self._selected = {}
	self._itemsData = {
	[VIEW_TYPE.REFINE] = {
	[LIAN_HUA_TYEP.HERO] = {},
	[LIAN_HUA_TYEP.EQUIP] = {},
	[LIAN_HUA_TYEP.SKILL] = {},
	[LIAN_HUA_TYEP.PET] = {},
	[LIAN_HUA_TYEP.SHIZHUANG] = {},
	[LIAN_HUA_TYEP.CHEATS] = {}
	},
	[VIEW_TYPE.REBORN] = {
	[LIAN_HUA_TYEP.HERO] = {},
	[LIAN_HUA_TYEP.EQUIP] = {},
	[LIAN_HUA_TYEP.SKILL] = {},
	[LIAN_HUA_TYEP.PET] = {},
	[LIAN_HUA_TYEP.SHIZHUANG] = {},
	[LIAN_HUA_TYEP.CHEATS] = {}
	}
	}
	local function onAddBtn(tag)
		self._rootnode["btn" .. tostring(tag)]:setTouchEnabled(false)
		self:init()
		push_scene(require("game.SplitStove.ItemChooseScene").new({
		list = self._list,
		items = self._itemsData[self._viewType],
		splitType = self._selectedType,
		viewType = self._viewType,
		selected = self._selected,
		closeListener = function(splitType, data)
			if data ~= self._selected then
				resetQuickBtn(0)
			end
			self:refreshItem(splitType, data)
			self._rootnode["btn" .. tostring(tag)]:setTouchEnabled(true)
		end
		}))
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
	end
	
	local function onQuickAddBtn(sender, eventName)
		local t
		if sender:getTag() == LIAN_HUA_TYEP.HERO then
			t = LIAN_HUA_TYEP.HERO
		elseif sender:getTag() == LIAN_HUA_TYEP.EQUIP then
			t = LIAN_HUA_TYEP.EQUIP
		elseif sender:getTag() == LIAN_HUA_TYEP.SKILL then
			t = LIAN_HUA_TYEP.SKILL
		elseif sender:getTag() == LIAN_HUA_TYEP.PET then
			t = LIAN_HUA_TYEP.PET
		elseif sender:getTag() == LIAN_HUA_TYEP.SHIZHUANG then
			if #self._itemsData[self._viewType][LIAN_HUA_TYEP.SHIZHUANG] == 0 then
				show_tip_label(common:getLanguageString("@sz_bufuhe5"))
			else
				self._selectedType = LIAN_HUA_TYEP.SHIZHUANG
				self._selected = {}
				self._animIsRunning = false
				resetQuickBtn(0)
				onAddBtn(1)
			end
			return
		elseif sender:getTag() == LIAN_HUA_TYEP.CHEATS then
			if #self._itemsData[self._viewType][LIAN_HUA_TYEP.CHEATS] == 0 then
				show_tip_label(common:getLanguageString("您没有符合炼化条件的秘笈"))
			else
				self._selectedType = LIAN_HUA_TYEP.CHEATS
				self._selected = {}
				self._animIsRunning = false
				resetQuickBtn(0)
				onAddBtn(2)
			end
			return
		else
			show_tip_label(data_error_error[2800001].prompt)
			return
		end
		local data = {}
		local idx = sender.index or 0
		local len
		if #self._itemsData[self._viewType][t] >= 4 then
			len = 4
		else
			len = #self._itemsData[self._viewType][t]
		end
		for i = 1, len do
			idx = idx + 1
			if idx > #self._itemsData[self._viewType][t] then
				idx = 1
				break
			end
			if self._itemsData[self._viewType][t][idx] then
				data[self._itemsData[self._viewType][t][idx]] = true
				sender.index = idx
				if idx == #self._itemsData[self._viewType][t] then
					sender.index = 0
					break
				end
			else
				break
			end
		end
		if len == 0 then
			local str = common:getLanguageString("@bufuhe1")
			if t == LIAN_HUA_TYEP.EQUIP then
				str = common:getLanguageString("@bufuhe2")
			elseif t == LIAN_HUA_TYEP.SKILL then
				str = common:getLanguageString("@bufuhe3")
			elseif t == LIAN_HUA_TYEP.PET then
				str = common:getLanguageString("@bufuhe4")
			elseif t == LIAN_HUA_TYEP.SHIZHUANG then
				str = common:getLanguageString("@sz_bufuhe5")
			elseif t == LIAN_HUA_TYEP.CHEATS then
				str = common:getLanguageString("@bufuhe6")
			end
			show_tip_label(str)
		else
			resetQuickBtn(sender:getTag())
		end
		self:refreshItem(t, data)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
	end
	local function onTabBtn(tag)
		if self._animIsRunning then
			return
		else
			self:refreshItem()
			if tag == 1 then
				self:onRefineView()
			elseif tag == 2 then
				resetQuickBtn(0)
				self:onRebornView()
			end
		end
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
	end
	local function onDescBtn()
		local layer = require("game.SplitStove.SplitDescLayer").new(self._viewType)
		self:addChild(layer, 100)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
	end
	local function onReborn()
		local id
		for k, v in pairs(self._selected) do
			if v then
				id = k
			end
		end
		if id == nil then
			show_tip_label(common:getLanguageString("@qingxuanze"))
			return
		end
		if checknumber(self._rootnode.costGoldLabel:getString()) > game.player:getGold() then
			show_tip_label(common:getLanguageString("@GoldCoinEnough"))
			return
		end
		dump(self._list[self._selectedType][id])
		self._rootnode.btn0:setVisible(false)
		self._rootnode.rebornBtn:setEnabled(false)
		self._rootnode.descBtn:setEnabled(false)
		self._animIsRunning = true
		RequestHelper.split.reborn({
		callback = function(data)
			dump(data)
			if data["3"] then
				self:bagFull(data["3"])
				self._rootnode.btn0:setVisible(true)
				self._rootnode.rebornBtn:setEnabled(true)
				self._rootnode.descBtn:setEnabled(true)
			else
				self:updataData(id, data["2"][1])
				game.player:setGold(data["4"])
				self:clearIcon()
				local effect = ResMgr.createArma({
				resType = ResMgr.UI_EFFECT,
				armaName = "lianhuatexiao",
				isRetain = false,
				finishFunc = function()
					self:updateResult(data["1"])
					self._rootnode.btn0:setVisible(true)
					self._rootnode.rebornBtn:setEnabled(true)
					self._rootnode.descBtn:setEnabled(true)
					self._selectedType = LIAN_HUA_TYEP.HERO
					self._selected = {}
					self._animIsRunning = false
				end
				})
				effect:setPosition(display.width / 2, display.height / 2)
				self:addChild(effect, 1000)
			end
		end,
		t = tostring(self._selectedType),
		id = self._list[self._selectedType][id].id
		})
	end
	for i = 0, 4 do
		local key = "btn" .. tostring(i)
		self._rootnode[key]:addNodeEventListener(cc.NODE_TOUCH_EVENT, c_func(onAddBtn, i))
		self._rootnode[key]:setTouchEnabled(true)
	end
	self._rootnode.lianhuaBtn:addHandleOfControlEvent(function()
		local bShow = false
		local bQiang = false
		for k, v in pairs(self._selected) do
			if self._list[self._selectedType][k].star == 5 then
				bShow = true
			end
			if self._list[self._selectedType][k].cls and self._list[self._selectedType][k].cls > 0 then
				bQiang = true
			end
		end
		if bShow or bQiang then
			local str
			if self._selectedType == LIAN_HUA_TYEP.HERO then
				str = common:getLanguageString("@lianhuats1")
			elseif self._selectedType == LIAN_HUA_TYEP.EQUIP then
				str = common:getLanguageString("@lianhuats2")
			elseif self._selectedType == LIAN_HUA_TYEP.SKILL then
				str = common:getLanguageString("@lianhuats3")
			elseif self._selectedType == LIAN_HUA_TYEP.PET then
				str = common:getLanguageString("@lianhuats4")
			elseif self._selectedType == LIAN_HUA_TYEP.SHIZHUANG then
				str = common:getLanguageString("@sz_lianhuats5")
			elseif self._selectedType == LIAN_HUA_TYEP.CHEATS then
				str = common:getLanguageString("@lianhuats6")
			end
			local layer = require("game.SplitStove.SplitTip").new({
			listener = function()
				self:onLianHua(function()
					self:init()
				end)
			end,
			str = str
			})
			self:addChild(layer, 10)
		else
			self:onLianHua(function()
				self:init()
			end)
		end
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
	end,
	CCControlEventTouchDown)
	
	for enumType, i in pairs(LIAN_HUA_TYEP) do
		self._rootnode["quickAddBtn_" .. tostring(i)]:addHandleOfControlEvent(onQuickAddBtn, CCControlEventTouchDown)
	end
	self:refreshItem()
	self:onRefineView()
	self._rootnode.rebornBtn:addHandleOfControlEvent(onReborn, CCControlEventTouchDown)
	CtrlBtnGroupAsMenu({
	self._rootnode.tab1,
	self._rootnode.tab2
	},
	onTabBtn)
	self._rootnode.descBtn:addHandleOfControlEvent(onDescBtn, CCControlEventTouchDown)
	self._rootnode.secretShopBtn:addHandleOfControlEvent(handler(self, SplitStoveScene.onSecretShopBtn), CCControlEventTouchDown)
	RequestHelper.split.status({
	callback = function(data)
		if string.len(data["0"]) > 0 then
			show_tip_label(data["0"])
		else
			table.sort(data["1"], herosort)
			table.sort(data["2"], equipsort)
			table.sort(data["3"], skillsort)
			table.sort(data["4"], skillsort)
			table.sort(data["6"], cheatssort)
			self._list = {
			[LIAN_HUA_TYEP.HERO] = data["1"],
			[LIAN_HUA_TYEP.EQUIP] = data["2"],
			[LIAN_HUA_TYEP.SKILL] = data["3"],
			[LIAN_HUA_TYEP.PET] = data["4"],
			[LIAN_HUA_TYEP.SHIZHUANG] = data["5"],
			[LIAN_HUA_TYEP.CHEATS] = data["6"]
			}
			self:init()
		end
	end
	})
end

function SplitStoveScene:bagFull(info)
	local layer = require("utility.LackBagSpaceLayer").new({bagObj = info})
	self:addChild(layer, 10)
end

function SplitStoveScene:refreshItem(selectedType, data)
	self._selectedType = selectedType or LIAN_HUA_TYEP.HERO
	self._selected = data or {}
	self._rootnode.costGoldLabel:setString("0")
	local items = {}
	local function showSplitIcon()
		local i
		if self._viewType == VIEW_TYPE.REFINE then
			i = 1
		else
			i = 0
		end
		local n = 1
		for k, v in pairs(self._selected) do
			--dump("2222222222222222222222")
			--dump(k)
			if  n <= 4 then
				local index = "icon" .. tostring(i) .. "Sprite"
				self._rootnode[index]:setVisible(false)
				local icon
				if self._selectedType == LIAN_HUA_TYEP.HERO then
					icon = ResMgr.getIconSprite({
					id = self._list[LIAN_HUA_TYEP.HERO][k].resId,
					resType = ResMgr.HERO
					})
				elseif self._selectedType == LIAN_HUA_TYEP.EQUIP then
					icon = ResMgr.getIconSprite({
					id = self._list[LIAN_HUA_TYEP.EQUIP][k].resId,
					resType = ResMgr.EQUIP
					})
				elseif self._selectedType == LIAN_HUA_TYEP.SKILL then
					icon = ResMgr.getIconSprite({
					id = self._list[LIAN_HUA_TYEP.SKILL][k].resId,
					resType = ResMgr.EQUIP
					})
				elseif self._selectedType == LIAN_HUA_TYEP.PET then
					icon = ResMgr.getIconSprite({
					id = self._list[LIAN_HUA_TYEP.PET][k].resId,
					resType = ResMgr.PET
					})
				elseif self._selectedType == LIAN_HUA_TYEP.SHIZHUANG then
					icon = ResMgr.getIconSprite({
					id = self._list[LIAN_HUA_TYEP.SHIZHUANG][k].resId,
					resType = ResMgr.FASHION
					})
				elseif self._selectedType == LIAN_HUA_TYEP.CHEATS then
					icon = ResMgr.getIconSprite({
					id = self._list[LIAN_HUA_TYEP.CHEATS][k].resId,
					resType = ResMgr.CHEATS
					})
				end
				if icon then
					self._rootnode["iconPos_" .. tostring(i)]:addChild(icon)
					local resid = self._list[self._selectedType][k].resId
					local iconName = ui.newTTFLabelWithShadow({
					text = "",
					font = FONTS_NAME.font_fzcy,
					size = 20,
					shadowColor = FONT_COLOR.BLACK
					})
					local name = ""
					if self._selectedType == LIAN_HUA_TYEP.HERO then
						local card = ResMgr.getCardData(resid)
						name = card.name
						iconName:setColor(NAME_COLOR[card.star[1]])
					elseif self._selectedType == LIAN_HUA_TYEP.EQUIP then
						name = data_item_item[resid].name
						iconName:setColor(NAME_COLOR[data_item_item[resid].quality])
					elseif self._selectedType == LIAN_HUA_TYEP.SKILL then
						name = data_item_item[resid].name
						iconName:setColor(NAME_COLOR[data_item_item[resid].quality])
					elseif self._selectedType == LIAN_HUA_TYEP.PET then
						name = data_item_item[resid].name
						iconName:setColor(NAME_COLOR[data_item_item[resid].quality])
					elseif self._selectedType == LIAN_HUA_TYEP.SHIZHUANG then
						name = data_item_item[resid].name
						iconName:setColor(NAME_COLOR[data_item_item[resid].quality])
					elseif self._selectedType == LIAN_HUA_TYEP.CHEATS then
						name = data_cheats_cheats[resid].name
						iconName:setColor(NAME_COLOR[data_cheats_cheats[resid].quality])
					end
					iconName:setString(name)
					iconName:setPosition(icon:getContentSize().width / 2, -iconName:getContentSize().height * 0.45)
					icon:addChild(iconName)
				end
			end
			n = n + 1
			i = i + 1
			local rtn
			if self._viewType == VIEW_TYPE.REFINE then
				rtn = "rtn"
			else
				rtn = "rtnReborn"
			end
			self._rootnode.costGoldLabel:setString(tostring(self._list[self._selectedType][k].cost))
			dump(self._list[self._selectedType][k][rtn])
			for kk, vv in ipairs(self._list[self._selectedType][k][rtn]) do
				if items[vv.id] then
					items[vv.id] = {
					n = items[vv.id].n + vv.n,
					t = vv.t
					}
				else
					items[vv.id] = {
					n = vv.n,
					t = vv.t
					}
				end
			end
		end
	end
	local function showResultIcon()
		local _tempData = {}
		for k, v in pairs(items) do
			table.insert(_tempData, {
			id = k,
			num = v.n,
			t = v.t
			})
		end
		table.sort(_tempData, function(l, r)
			return l.t < r.t
		end)
		local tableView = require("utility.TableViewExt").new({
		size = self._rootnode.splitItemsBg:getContentSize(),
		direction = kCCScrollViewDirectionHorizontal,
		createFunc = function(idx)
			idx = idx + 1
			local item = Item.new()
			return item:create({
			itemData = _tempData[idx],
			viewSize = self._rootnode.splitItemsBg:getContentSize(),
			idx = idx
			})
		end,
		refreshFunc = function(cell, idx)
			idx = idx + 1
			cell:refresh({
			itemData = _tempData[idx],
			idx = idx
			})
		end,
		cellNum = #_tempData,
		cellSize = cc.size(105, 95),
		touchFunc = function(cell)
			local idx = cell:getIdx() + 1
			resType = ResMgr.getResType(_tempData[idx].t)
			local item = ResMgr.getItemByType(_tempData[idx].id, resType)
			local infoLayer = require("game.Huodong.ItemInformation").new({
			id = _tempData[idx].id,
			type = _tempData[idx].t,
			name = item.name,
			describe = item.describe,
			endFunc = function()
			end
			})
			self:addChild(infoLayer, 10)
		end
		})
		self._rootnode.splitItemsBg:addChild(tableView)
	end
	self:clearIcon()
	showSplitIcon()
	showResultIcon()
end

function SplitStoveScene:updataData(index, data)
	if self._list[self._selectedType][index] then
		for k, v in pairs(self._list[self._selectedType][index]) do
			self._list[self._selectedType][index][k] = data[k]
		end
	end
	self:init()
end

function SplitStoveScene:removeData(ids)
	for _, v in ipairs(ids) do
		for k, vv in ipairs(self._list[self._selectedType]) do
			if vv.id == v then
				table.remove(self._list[self._selectedType], k)
				break
			end
		end
	end
end

function SplitStoveScene:setIconVisible(bVisible)
	for i = 1, 4 do
		local key = "btn" .. tostring(i)
		self._rootnode[key]:setVisible(bVisible)
	end
end

function SplitStoveScene:clearIcon()
	self._rootnode.costGoldLabel:setString("0")
	for i = 0, 4 do
		self._rootnode["icon" .. tostring(i) .. "Sprite"]:setVisible(true)
		self._rootnode["iconPos_" .. tostring(i)]:removeAllChildrenWithCleanup(true)
	end
	self._rootnode.splitItemsBg:removeAllChildrenWithCleanup(true)
end

function SplitStoveScene:updateResult(data)
	local itemData = {}
	for k, v in ipairs(data) do
		local iconType = ResMgr.getResType(v.t) or ResMgr.ITEM
		local itemInfo = ResMgr.getItemByType(v.id, iconType)
		table.insert(itemData, {
		id = v.id,
		type = itemInfo.type,
		name = itemInfo.name,
		describe = itemInfo.describe,
		iconType = iconType,
		num = v.n or 0,
		hideCorner = true
		})
		if 2 == v.id then
			game.player:addSilver(v.n)
		end
	end
	local title = common:getLanguageString("@huodejl")
	local msgBox = require("game.Huodong.RewardMsgBox").new({title = title, cellDatas = itemData})
	self:addChild(msgBox, 10)
	PostNotice(NoticeKey.CommonUpdate_Label_Silver)
	PostNotice(NoticeKey.CommonUpdate_Label_Gold)
end

function SplitStoveScene:onLianHua(callback)
	local ids = {}
	for k, v in pairs(self._selected) do
		table.insert(ids, self._list[self._selectedType][k].id)
	end
	if 0 == #ids then
		show_tip_label(common:getLanguageString("@xuanzelhwp"))
	else
		self:setIconVisible(false)
		self._rootnode.lianhuaBtn:setEnabled(false)
		self._rootnode.quickAddBtn_1:setEnabled(false)
		self._rootnode.quickAddBtn_2:setEnabled(false)
		self._rootnode.descBtn:setEnabled(false)
		self._animIsRunning = true
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_lianhualu))
		RequestHelper.split.refine({
		callback = function(data)
			if string.len(data["0"]) > 0 then
				show_tip_label(data["0"])
			else
				self:removeData(ids)
				self:clearIcon()
				local effect = ResMgr.createArma({
				resType = ResMgr.UI_EFFECT,
				armaName = "lianhuatexiao",
				isRetain = false,
				finishFunc = function()
					GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_duobaohecheng))
					self:updateResult(data["1"])
					self:setIconVisible(true)
					self._rootnode.lianhuaBtn:setEnabled(true)
					self._rootnode.quickAddBtn_1:setEnabled(true)
					self._rootnode.quickAddBtn_2:setEnabled(true)
					self._rootnode.descBtn:setEnabled(true)
					self._selectedType = LIAN_HUA_TYEP.HERO
					self._selected = {}
					for enumType, i in pairs(LIAN_HUA_TYEP) do
						self._rootnode["quickAddBtn_" .. i]:setTitleForState(BTN_NAME_MAPPING[i], CCControlStateNormal)
					end
					self._rootnode[string.format("quickAddBtn_%d", 1)].index = nil
					self._rootnode[string.format("quickAddBtn_%d", 2)].index = nil
					self._rootnode[string.format("quickAddBtn_%d", 3)].index = nil
					self._rootnode[string.format("quickAddBtn_%d", 4)].index = nil
					self._rootnode[string.format("quickAddBtn_%d", 5)].index = nil
					self._animIsRunning = false
					if callback then
						callback()
					end
				end
				})
				effect:setPosition(display.cx, display.cy)
				self:addChild(effect, 1000)
			end
		end,
		t = tostring(self._selectedType),
		ids = ids
		})
	end
end

function SplitStoveScene:onSecretShopBtn()
	local bHasOpen, prompt = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.ShenMi_Shop, game.player:getLevel(), game.player:getVip())
	if not bHasOpen then
		show_tip_label(prompt)
	else
		GameStateManager:ChangeState(GAME_STATE.STATE_JINGCAI_HUODONG, nbActivityShowType.ShenMi)
	end
	GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
end

function SplitStoveScene:onRefineView()
	self._viewType = VIEW_TYPE.REFINE
	self._rootnode.rebornNode:setVisible(false)
	self._rootnode.refineNode:setVisible(true)
end

function SplitStoveScene:onRebornView()
	self._viewType = VIEW_TYPE.REBORN
	self._rootnode.rebornNode:setVisible(true)
	self._rootnode.refineNode:setVisible(false)
	self._rootnode.costGoldLabel:setString("0")
end

function SplitStoveScene:onEnter()
	game.runningScene = self
	SplitStoveScene.super.onEnter(self)
	PostNotice(NoticeKey.UNLOCK_BOTTOM)
	if self._bExit then
		self._bExit = false
		--local broadcastBg = self._rootnode.broadcast_tag
		--game.broadcast:reSet(broadcastBg)
	end
end

function SplitStoveScene:onExit()
	SplitStoveScene.super.onExit(self)
	self._bExit = true
	CCTextureCache:sharedTextureCache():removeUnusedTextures()
end

return SplitStoveScene