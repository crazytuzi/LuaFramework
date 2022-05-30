local data_item_nature = require("data.data_item_nature")
local data_cheats_cheats = require("data.data_miji_miji")
local data_battleskill_battleskill = require("data.data_battleskill_battleskill")
local data_talent_talent = require("data.data_talent_talent")
local data_shentong_shentong = require("data.data_shentong_shentong")

local Item = class("Item", function ()
	return CCTableViewCell:new()
end)

function Item:getContentSize()
	return cc.size(display.width, 158)
end

function Item:create(param)
	local _viewSize = param.viewSize
	local _listener = param.listener
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("cheats/cheats_list_item.ccbi", proxy, self._rootnode)
	node:setPosition(_viewSize.width / 2, self._rootnode.itemBg:getContentSize().height / 2)
	self:addChild(node)
	
	self._rootnode.touchNode:setTouchEnabled(true)
	self.heroName = ui.newTTFLabelWithShadow({
	text = "",
	font = FONTS_NAME.font_fzcy,
	size = 22,
	align = ui.TEXT_ALIGN_LEFT,
	color = FONT_COLOR.WHITE,
	shadowColor = FONT_COLOR.BLACK,
	})
	self.heroName:setAnchorPoint(ccp(0, 0.5))
	self._rootnode.itemNameLabel:addChild(self.heroName)
	self.headIcon = self._rootnode.headIcon
	self._rootnode.yanxiBtn:setVisible(false)
	self._rootnode.upgradeBtn:setVisible(true)
	self._rootnode.upgradeBtn:addHandleOfControlEvent(function (sender, eventName)
		if _listener then
			_listener(self._rootnode.upgradeBtn, self:getIdx())
		end
	end,
	CCControlEventTouchUpInside)
	self:refresh(param)
	return self
end

function Item:getTutoBtn()
	return self._rootnode.upgradeBtn
end

local CheatsType = {
"cheats_xinfa_tab.png",
"cheats_juexue_tab.png"
}

function Item:refresh(param)
	local itemData = param.itemData
	local id = itemData.resId
	local starsNum = data_cheats_cheats[id].quality
	local ceng = itemData.floor
	local localItemData = ResMgr.getRefreshIconItem(id, ITEM_TYPE.cheats)
	self.heroName:setString(localItemData.name)
	self.heroName:setPosition(self.heroName:getContentSize().width / 2, 0)
	self.heroName:setColor(NAME_COLOR[starsNum])
	ResMgr.refreshIcon({
	id = id,
	itemBg = self.headIcon,
	resType = ResMgr.CHEATS,
	star = starsNum
	})
	self._rootnode.flagSprite:setDisplayFrame(display.newSpriteFrame(CheatsType[data_cheats_cheats[id].type]))
	self._rootnode.lvNum:setString(common:getLanguageString("@CheatsCeng", ceng))
	self._rootnode.qualitySprite:setDisplayFrame(display.newSpriteFrame(string.format("item_board_num_%d.png", starsNum)))
	if itemData.sub_type == 1 then
		local skillId = data_cheats_cheats[id].skill[1]
		local shentong = data_shentong_shentong[skillId]
		local skillData = data_talent_talent[shentong.arr_talent[ceng]]
		self._rootnode.cheats_skill_name:setString(skillData.name)
		self._rootnode.cheats_skill_des:setString(skillData.type)
	else
		local skillId = data_cheats_cheats[id].skill[ceng]
		local skillData = data_battleskill_battleskill[skillId]
		self._rootnode.cheats_skill_name:setString(skillData.name)
		self._rootnode.cheats_skill_des:setString(skillData.desc)
	end
	local cid = itemData.cid
	if cid > 0 then
		local card = ResMgr.getCardData(cid)
		if card.id == 1 or card.id == 2 then
			self._rootnode.equipHeroName:setString(common:getLanguageString("@EquipAt", game.player:getPlayerName()))
		else
			self._rootnode.equipHeroName:setString(common:getLanguageString("@EquipAt", card.name))
		end
	else
		self._rootnode.equipHeroName:setString("")
	end
end

local CheatsChooseScene = class("CheatsChooseScene", function ()
	return require("game.BaseScene").new({
	contentFile = "public/window_content_scene.ccbi",
	subTopFile = "formation/formation_equip_sub_top.ccbi",
	bgImage = "ui_common/common_bg.png",
	imageFromBottom = true
	})
end)

function CheatsChooseScene:ctor(param)
	game.runningScene = self
	local _index = param.index
	local _subIndex = param.subIndex
	local _callback = param.callback
	local _cid = param.cid
	local _onData = param.onData
	PostNotice(NoticeKey.UNLOCK_BOTTOM)
	self._rootnode.choseTopName:setString(common:getLanguageString("@choseCheats"))
	game.runningScene = self
	ResMgr.createBefTutoMask(self)
	local _sz = self._rootnode.listView:getContentSize()
	
	--·µ»Ø
	self._rootnode.backBtn:addHandleOfControlEvent(function (sender, eventName)
		self._rootnode.backBtn:setEnabled(false)
		_callback()
		pop_scene()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
	end,
	CCControlEventTouchUpInside)
	
	
	local _data = {}
	for k, v in ipairs(CheatsModel.totalTable) do
		local sub_type = 2
		if _subIndex == 16 or _subIndex == 17 then
			sub_type = 1
		end
		if sub_type == data_cheats_cheats[v.resId].type and v.cid ~= _cid and (_onData == nil or _onData and _onData[v.resId] == nil) then
			v.sub_type = sub_type
			table.insert(_data, v)
		end
	end
	local function putoff()
		for k, v in ipairs(_data) do
			if v.pos == _index and v.cid == _cid then
				v.pos = 0
				v.cid = 0
				break
			end
		end
	end
	CheatsModel.sort(_data)
	local function onEquipment(buttonCell, cellIdx)
		local function wearEquipment(...)
			GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
			RequestHelper.formation.putOnCheats({
			pos = _index,
			subpos = _subIndex,
			id = _data[cellIdx + 1].id,
			callback = function (data)
				PostNotice(NoticeKey.REMOVE_TUTOLAYER)
				if string.len(data["0"]) > 0 then
					CCMessageBox(data["0"], "Tip")
				else
					putoff()
					if _callback then
						_data[cellIdx + 1].pos = _index
						_data[cellIdx + 1].cid = _cid
						_callback(data)
					end
					pop_scene()
				end
			end
			})
		end
		local item_cid = _data[cellIdx + 1].cid
		if item_cid > 0 then
			local card = ResMgr.getCardData(item_cid)
			local userName = ""
			if card.id == 1 or card.id == 2 then
				userName = game.player:getPlayerName()
			else
				userName = card.name
			end
			local texts = common:getLanguageString("@IsReplace", userName)
			local lbl = ResMgr.createOutlineMsgTTF({
			text = texts,
			color = white,
			outlineColor = black
			})
			local msgBox = require("utility.MsgBoxEx").new({
			resTable = {
			{lbl}
			},
			confirmFunc = function (msgBox)
				wearEquipment()
			end
			})
			game.runningScene:addChild(msgBox, 11)
		else
			wearEquipment()
		end
	end
	self._scrollItemList = require("utility.TableViewExt").new({
	size = cc.size(_sz.width, _sz.height),
	direction = kCCScrollViewDirectionVertical,
	createFunc = function (idx)
		local item = Item.new()
		idx = idx + 1
		return item:create({
		viewSize = _sz,
		itemData = _data[idx],
		index = idx,
		listener = function (buttonCell, cellIdx)
			onEquipment(buttonCell, cellIdx)
		end
		})
	end,
	refreshFunc = function (cell, idx)
		idx = idx + 1
		cell:refresh({
		index = idx,
		itemData = _data[idx]
		})
	end,
	cellNum = #_data,
	cellSize = Item.new():getContentSize()
	})
	self._scrollItemList:setPosition(0, 0)
	self._rootnode.listView:addChild(self._scrollItemList)
end

function CheatsChooseScene:onEnter()
	game.runningScene = self
	self:setBroadcast()
	local cell = self._scrollItemList:cellAtIndex(0)
	if cell ~= nil then
		local tutoBtn = cell:getTutoBtn()
		TutoMgr.addBtn("equip_list_equipon_btn", tutoBtn)
	end
	TutoMgr.active()
end

function CheatsChooseScene:onExit()
	TutoMgr.removeBtn("equip_list_equipon_btn")
end

return CheatsChooseScene