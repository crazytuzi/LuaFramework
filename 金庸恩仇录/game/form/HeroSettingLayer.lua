local FormUpLayerTag = 241
local HeadListType = {NormalType = 0, ZhuZhenType = -1}
require("utility.BottomBtnEvent")
local data_jiban_jiban = require("data.data_jiban_jiban")
local data_shentong_shentong = require("data.data_shentong_shentong")
local data_talent_talent = require("data.data_talent_talent")
local data_item_item = require("data.data_item_item")
local data_cheats_cheats = require("data.data_miji_miji")
local data_refine_refine = require("data.data_refine_refine")
local formationLayer = require("game.form.formationLayer")
local data_helper_helper = require("data.data_helper_helper")
local data_helperlevel_helperlevel = require("data.data_helperlevel_helperlevel")
local data_card_card = require("data.data_card_card")
local data_battleskill_battleskill = require("data.data_battleskill_battleskill")
local FormAddHeroTag = 101
local FormAddPetTag = 102
local FormEquipChildTag = 103
local FormCheatsChildTag = 104
local RequestInfo = require("network.RequestInfo")

local HeroIcon = class("HeroIcon", function ()
	return CCTableViewCell:new()
end)

function HeroIcon:getContentSize()
	return cc.size(115, 115)
end

function HeroIcon:ctor()
end

function HeroIcon:getTutoBtn()
	return self.addSprite
end

local spirit_Add_Tag = 6481
function HeroIcon:create(param)
	local _viewSize = param.viewSize
	local _itemData = param.itemData
	self._heroIcon = display.newSprite("#zhenrong_equip_hero_bg.png")
	self:addChild(self._heroIcon)
	self._heroIcon:setPosition(self._heroIcon:getContentSize().width / 2, _viewSize.height / 2)
	self._actIcon = display.newSprite("#zhenrong_lock_bg.png")
	self:addChild(self._actIcon)
	self._actIcon:setPosition(self._actIcon:getContentSize().width / 2, _viewSize.height / 2)
	local label = ui.newTTFLabel({
	text = "",
	size = 18,
	font = FONTS_NAME.font_fzcy,
	color = cc.c3b(155, 155, 155)
	})
	label:setPosition(self._actIcon:getContentSize().width / 2, self._actIcon:getContentSize().height * 0.3)
	self._actIcon:addChild(label)
	label:setTag(1)
	local addSprite = display.newSprite("#zhenrong_add.png")
	addSprite:setPosition(self._actIcon:getContentSize().width / 2, self._actIcon:getContentSize().height / 2)
	self._actIcon:addChild(addSprite)
	addSprite:setTag(2)
	self.addSprite = self._heroIcon
	self._lightBoard = display.newSprite("#zhenrong_select_board.png")
	self._lightBoard:setPosition(self._heroIcon:getContentSize().width / 2, _viewSize.height / 2)
	self:addChild(self._lightBoard)
	self._lightBoard:setVisible(false)
	self:refresh(param)
	return self
end

function HeroIcon:selected()
	self._lightBoard:setVisible(true)
end

function HeroIcon:unselected()
	self._lightBoard:setVisible(false)
end

function HeroIcon:refresh(param)
	local _itemData = param.itemData
	self._heroIcon:setVisible(false)
	self._actIcon:setVisible(false)
	if param.idx == param.index then
		self:selected()
	else
		self:unselected()
	end
	display.addSpriteFramesWithFile("ui_zhenrong.plist", "ui_zhenrong.png")
	if type(_itemData) == "number" then
		self._actIcon:setVisible(true)
		self._actIcon:getChildByTag(1):setVisible(false)
		self._actIcon:getChildByTag(2):setVisible(false)
		if _itemData > HeadListType.NormalType then
			self._actIcon:setDisplayFrame(display.newSpriteFrame("zhenrong_lock_bg.png"))
			self._actIcon:getChildByTag(1):setVisible(true)
			self._actIcon:getChildByTag(1):setString(common:getLanguageString("@LevelOpen", _itemData))
		elseif _itemData == HeadListType.NormalType then
			self._actIcon:setDisplayFrame(display.newSpriteFrame("zhenrong_equip_hero_bg.png"))
			self._actIcon:getChildByTag(2):setVisible(true)
			self._actIcon:getChildByTag(2):setPosition(self._actIcon:getContentSize().width / 2, self._actIcon:getContentSize().height / 2)
		elseif _itemData == HeadListType.ZhuZhenType then
			self._actIcon:setDisplayFrame(display.newSpriteFrame("zhenrong_zhuzhen.png"))
		end
	else
		self._heroIcon:setVisible(true)
		ResMgr.refreshIcon({
		itemBg = self._heroIcon,
		cls = _itemData.cls,
		id = param.itemData.resId,
		resType = ResMgr.HERO
		})
	end
end
local MOVE_OFFSET = display.width / 3

local HeroSettingLayer = class("HeroSettingLayer", function ()
	return display.newLayer()
end)

local SHOWTYPE = {
FORMATION = 1,
SPIRIT = 2,
PET = 3,
ZhuZhen = 4,
CHEATS = 5
}
local getDataOpen = function (sysID)
	local data_open_open = require("data.data_open_open")
	for k, v in ipairs(data_open_open) do
		if sysID == v.system then
			return v
		end
	end
end

function HeroSettingLayer:switchView(bRefresh)
	self._rootnode.bottomInfoView:setVisible(true)
	self._rootnode.zhuZhenNode:setVisible(false)
	self._rootnode.zhuZhenNode_Info:setVisible(false)
	self._rootnode.touchNode:setTouchEnabled(true)
	if self._showType == SHOWTYPE.PET then
		self._rootnode.petInfoView:setVisible(true)
		self._rootnode.heroInfoView:setVisible(false)
	elseif self._showType ~= SHOWTYPE.ZhuZhen then
		self._rootnode.petInfoView:setVisible(false)
		self._rootnode.heroInfoView:setVisible(true)
		self._rootnode.bottomInfoView:setVisible(true)
		if self._showType == SHOWTYPE.SPIRIT then
			self._rootnode.spiritNode:setVisible(true)
			self._rootnode.equipNode:setVisible(false)
			self._rootnode.cheatsNode:setVisible(false)
		elseif self._showType == SHOWTYPE.CHEATS then
			self._rootnode.cheatsNode:setVisible(true)
			self._rootnode.spiritNode:setVisible(false)
			self._rootnode.equipNode:setVisible(false)
		else
			self._rootnode.cheatsNode:setVisible(false)
			self._rootnode.spiritNode:setVisible(false)
			self._rootnode.equipNode:setVisible(true)
		end
	else
		self._rootnode.zhuZhenNode:setVisible(true)
		self._rootnode.zhuZhenNode_Info:setVisible(false)
		self._rootnode.bottomInfoView:setVisible(false)
	end
	
	self:setButtonEnable(self._showType)
	
	self:setFormBg(self._showType ~= SHOWTYPE.PET)
	if bRefresh then
		self:refreshHero(self._index)
	end
end

function HeroSettingLayer:setFormBg(normalTypeBg)
	if self.normalTypeBg == normalTypeBg then
		return
	end
	self.normalTypeBg = normalTypeBg
	local bg
	if normalTypeBg then
		bg = display.newSprite("bg/formation_bg.jpg")
	else
		bg = display.newSprite("bg/pet_bg.jpg")
	end
	self.bg:setDisplayFrame(bg:getDisplayFrame())
	local bgSize = bg:getContentSize()
	bg:setScaleX(display.width / bgSize.width)
	bg:setScaleY((display.height - 295) / bgSize.height)
end

function HeroSettingLayer:ctor(showType)
	self._petSkillBtn = {}
	self._roleEquipBtn = {}
	self._spiritBtn = {}
	
	self:setNodeEventEnabled(true)
	local bg = display.newSprite("bg/formation_bg.jpg")
	bg:setPosition(display.cx, display.cy - 17.5)
	bg:setScaleX(display.width / bg:getContentSize().width)
	bg:setScaleY((display.height - 265) / bg:getContentSize().height)
	self:addChild(bg, 0)
	self.bg = bg
	self.normalTypeBg = true
	self.isformSelf = true
	self._showType = 1
	self:setContentSize(cc.size(display.width, display.height))
	self._rootnode = {}
	local node = LoadUI("formation/formation_scene.ccbi", self._rootnode)
	node:setAnchorPoint(0.5, 0.5)
	node:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
	self:addChild(node, 1)
	if not common:getLanguageChineseType() then
		for i = 1, 6 do
			self._rootnode["jbLabel_" .. i]:setScale(0.8)
		end
	end
	local items = {
	"mainSceneBtn",
	"formSettingBtn",
	"battleBtn",
	"activityBtn",
	"bagBtn",
	"shopBtn"
	}
	
	BottomBtnEvent.lightenBottomMenu(self._rootnode)
	self.namebgY = self._rootnode.hero_name_bg:getPositionY()
	BottomBtnEvent.registerBottomEvent(self._rootnode)
	local _level = game.player:getLevel()
	for k, v in ipairs(getDataOpen(OPENCHECK_TYPE.ZhenQi).level) do
		if v <= _level then
			self._rootnode["spiritLock_" .. tostring(k)]:setVisible(false)
			local spiritNodeName = "spiritNode_" .. tostring(k)
			local s = display.newSprite("#zhenrong_add.png")
			s:setPosition(self._rootnode[spiritNodeName]:getContentSize().width / 2, self._rootnode[spiritNodeName]:getContentSize().height / 2)
			self._rootnode[spiritNodeName]:addChild(s)
			s:setTag(spirit_Add_Tag)
		end
	end
	for k, v in ipairs(getDataOpen(OPENCHECK_TYPE.CheatsOpen).level) do
		if v <= _level then
			self._rootnode["cheatsLock_" .. tostring(k + 15)]:setVisible(false)
		end
		self._rootnode["cheatsOpen_" .. tostring(k + 15)]:setString("   " .. v .. " \n级开放")
	end
	
	--淬炼
	self._rootnode.btn_culian:addHandleOfControlEvent(function (sender, eventName)
		local bHasOpen, prompt = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.ZHUANGBEICULIAN, game.player:getLevel(), game.player:getVip())
		if not bHasOpen then
			show_tip_label(prompt)
			canShow = false
		else
			if self._noHero then
				show_tip_label(data_error_error[3600007].prompt)
				return
			end
			local num = 0
			for k, v in pairs(self._equip[self._index]) do
				if v.type == 1 then
					num = num + 1
				end
			end
			if num < 4 then
				show_tip_label(data_error_error[3600007].prompt)
				return
			end
			GameStateManager:ChangeState(GAME_STATE.STATE_CULIAN_MAIN, {
			_index = self._index,
			_objId = self._cardList[self._index].objId,
			_pos = 1
			})
		end
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
	end,
	CCControlEventTouchDown)
	
	--装备
	self._rootnode.btn_zhuangbei:addHandleOfControlEvent(function (sender, eventName)
		if self._showType == SHOWTYPE.FORMATION then
			return
		end
		self._showType = SHOWTYPE.FORMATION
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		self:switchView(true)
	end,
	CCControlEventTouchDown)
	
	--真气
	self._rootnode.btn_zhenqi:addHandleOfControlEvent(function (sender, eventName)
		if self._showType == SHOWTYPE.SPIRIT then
			return
		end
		self._showType = SHOWTYPE.SPIRIT
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		self:switchView(true)
	end,
	CCControlEventTouchDown)
	
	--宠物
	self._rootnode.btn_pet:addHandleOfControlEvent(function (sender, eventName)
		if self._showType == SHOWTYPE.PET then
			return
		end
		local bHasOpen, prompt = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.ChongWu, game.player:getLevel(), game.player:getVip())
		if not bHasOpen then
			show_tip_label(prompt)
		else
			self._showType = SHOWTYPE.PET
			GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
			self:switchView(true)
		end
	end,
	CCControlEventTouchDown)
	
	--秘籍
	self._rootnode.btn_cheats:addHandleOfControlEvent(function (sender, eventName)
		if self._showType == SHOWTYPE.CHEATS then
			return
		end
		local bHasOpen, prompt = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.Cheats, game.player:getLevel(), game.player:getVip())
		if not bHasOpen then
			show_tip_label(prompt)
		else
			self._showType = SHOWTYPE.CHEATS
			GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
			self:switchView(true)
		end
	end,
	CCControlEventTouchDown)
	
	--图鉴
	self._rootnode.tujianBtn:addHandleOfControlEvent(function (sender, eventName)
		if self._showType ~= SHOWTYPE.CHEATS then
			return
		end
		GameStateManager:ChangeState(GAME_STATE.STATE_HANDBOOK_CHEATS)
	end,
	CCControlEventTouchDown)
	
	--快速装备	
	self._rootnode.quickEquipBtn:addHandleOfControlEvent(function (sender, eventName)
		local t --0:装备 1:真气2:宠物3:秘籍
		if self._showType == SHOWTYPE.PET then
			t = 2
		elseif self._showType == SHOWTYPE.SPIRIT then
			t = 1
		elseif self._showType == SHOWTYPE.CHEATS then
			t = 3
		else
			t = 0
		end
		RequestHelper.formation.quickEquip({
		pos = self._index,
		cardId = self._cardList[self._index].resId,
		type = t,
		errback = function ()
			PostNotice(NoticeKey.REMOVE_TUTOLAYER)
		end,
		callback = function (data)
			if t == 3 then
				self:resetFormData(data)
				self:refreshHero(self._index)
				for k, v in ipairs(CheatsModel.totalTable) do
					if v.pos == self._index or v.cid == self._cardList[self._index].resId then
						v.pos = 0
						v.cid = 0
					end
				end
				for k, v in ipairs(self._cheats[self._index]) do
					local cheats = self:getCheatsByID(v.objId)
					if cheats then
						cheats.pos = v.pos
						cheats.cid = self._cardList[self._index].resId
					end
				end
			elseif t == 2 then
				self:resetFormData(data)
				self:refreshHero(self._index)
				local petList = PetModel.getPetTable()
				for k, v in ipairs(petList) do
					if v.pos == self._index or v.cid == self._cardList[self._index].resId then
						v.pos = 0
						v.cid = 0
						break
					end
				end
				local formPet = self._pet[self._index][1]
				if formPet then
					local pet = PetModel.getPetByObjId(formPet._id)
					pet.pos = formPet.pos
					pet.cid = self._cardList[self._index].resId
				end
			elseif t == 1 then
				self:resetFormData(data)
				self:refreshHero(self._index)
				for k, v in ipairs(game.player:getSpirit()) do
					if v.pos == self._index or v.cid == self._cardList[self._index].resId then
						v.pos = 0
						v.cid = 0
					end
				end
				for k, v in ipairs(self._spirit[self._index]) do
					local spirit = self:getSpiritByID(v.objId)
					if spirit then
						spirit.pos = v.pos
						spirit.cid = self._cardList[self._index].resId
					end
				end
			else
				--装备位置
				for k, v in ipairs(game.player:getEquipments()) do
					if v.pos == self._index then
						v.pos = 0
						v.cid = 0
					end
				end
				for k, v in ipairs(game.player:getSkills()) do
					if v.pos == self._index then
						v.pos = 0
						v.cid = 0
					end
				end
				for k, v in ipairs(data["2"][self._index]) do
					local equip
					if v.subpos == 5 or v.subpos == 6 then
						equip = self:getSkillByID(v.objId)
					else
						equip = self:getEquipByID(v.objId)
					end
					if equip then
						equip.pos = v.pos
						equip.cid = self._cardList[self._index].resId
					end
				end
				if data["7"] ~= nil then
					for k, v in pairs(self._fashionList) do
						v.isWare = 0
						if v.id == data["7"].id then
							v.isWare = game.player.getGender()
						end
					end
					FashionModel.fashionListSort()
					game.player:setFashionId(data["7"].fashionId)
				end
				self:resetFormData(data)
				self:refreshHero(self._index)
			end
			PostNotice(NoticeKey.REMOVE_TUTOLAYER)
		end
		})
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
	end,
	CCControlEventTouchUpInside)
	
	--布阵
	self._rootnode.heroSettingBtn:addHandleOfControlEvent(function (sender, eventName)
		if self.requestDone == true then
			GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
			self:setForm()
		end
	end,
	CCControlEventTouchUpInside)
	
	--切换卡牌
	self._rootnode.changeHeroBtn:addHandleOfControlEvent(function ()
		self:performWithDelay(function ()
			push_scene(require("game.form.HeroChooseScene").new({
			index = self._index,
			callback = function (data)
				game.runningScene = self:getParent()
				self:resetFormData(data)
				self:initHeadList()
				self:refreshHero(self._index)
			end,
			closelistener = function ()
				game.runningScene = self:getParent()
			end
			}))
		end,
		0.12)
	end,
	CCControlEventTouchUpInside)
	
	--强化
	self._rootnode.qianghua_btn:addHandleOfControlEvent(function (sender, eventName)
		local bHasOpen, prompt = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.QIANGHUADASHI, game.player:getLevel(), game.player:getVip())
		if not bHasOpen then
			show_tip_label(prompt)
			canShow = false
		else
			if self._noHero then
				show_tip_label(data_error_error[3600006].prompt)
				return
			end
			local num = 0
			for k, v in pairs(self._equip[self._index]) do
				if v.type ~= 1 then
					num = num + 1
				end
			end
			if num < 2 then
				show_tip_label(data_error_error[3600006].prompt)
				return
			end
			local qhMainPopup = require("game.QiangHuaDashi.QhMainPopup").new({
			_index = self._index,
			_objId = self._cardList[self._index].objId,
			callBack = function ()
				self:requestForRefreshForm()
			end
			})
			CCDirector:sharedDirector():getRunningScene():addChild(qhMainPopup, 100)
		end
	end,
	CCControlEventTouchUpInside)
	
	self:initTouchNode()
	self:initSpirit()
	self:initEquip()
	self:initPet()
	self:initFashion()
	self:initCheats()
	self:switchView()
	addbackevent(self)
end

--获取时装列表
function HeroSettingLayer:needInit()
	FashionModel.getListReq(function (list)
		--dump(list)
		--self._fashionList = list
	end)
	self:update()
end

function HeroSettingLayer:setForm()
	if self._formSettingView then
		return
	end
	self._rootnode.heroInfoView:setVisible(false)
	self._rootnode.petInfoView:setVisible(false)
	self._rootnode.bottomInfoView:setVisible(false)
	self._rootnode.touchNode:setTouchEnabled(false)
	local formCtrl = require("game.form.FormCtrl")
	self._formSettingView = formCtrl.createFormSettingLayer({
	parentNode = self,
	touchEnabled = false,
	list = self._cardList,
	sz = cc.size(display.width * 0.9, display.height - 297),
	pos = cc.p(display.cx, display.cy - 20),
	closeListener = function ()
		self:switchView()
		if self._showType ~= SHOWTYPE.ZhuZhen then
			self:refreshHero(self._index)
			self._rootnode.touchNode:setTouchEnabled(true)
		end
		self._formSettingView = nil
	end,
	callback = handler(self, HeroSettingLayer.resetFormData)
	})
end

function HeroSettingLayer:regLockNotice()
	RegNotice(self, function ()
		self:setHeroScrollDisabled(true)
	end,
	NoticeKey.LOCK_TABLEVIEW)
	RegNotice(self, function ()
		self:setHeroScrollDisabled(false)
	end,
	NoticeKey.UNLOCK_TABLEVIEW)
end

function HeroSettingLayer:setBottomBtnEnabled(bEnabled)
	ResMgr.isBottomEnabled = bEnabled
	BottomBtnEvent.setTouchEnabled(bEnabled)
end

function HeroSettingLayer:unLockNotice()
	UnRegNotice(self, NoticeKey.LOCK_TABLEVIEW)
	UnRegNotice(self, NoticeKey.UNLOCK_TABLEVIEW)
end

function HeroSettingLayer:request()
	local reqs = {}
	table.insert(reqs, RequestInfo.new({
	modulename = "equip",
	funcname = "list",
	param = {},
	oklistener = function (data)
		game.player:setEquipments(data["1"])
	end
	}))
	table.insert(reqs, RequestInfo.new({
	modulename = "spirit",
	funcname = "list",
	param = {},
	oklistener = function (data)
		game.player:setSpirit(data["1"])
		game.player:setSpiritBagMax(data["3"])
	end
	}))
	table.insert(reqs, RequestInfo.new({
	modulename = "hero",
	funcname = "list",
	param = {},
	oklistener = function (data)
		game.player:setHero(data["1"])
	end
	}))
	table.insert(reqs, RequestInfo.new({
	modulename = "skill",
	funcname = "list",
	param = {},
	oklistener = function (data)
		game.player:setSkills(data["1"])
	end
	}))
	table.insert(reqs, RequestInfo.new({
	modulename = "pet",
	funcname = "list",
	param = {},
	oklistener = function (data)
		PetModel.setPetTable(data["1"])
	end
	}))
	table.insert(reqs, RequestInfo.new({
	modulename = "cheats",
	funcname = "list",
	param = {},
	oklistener = function (data)
		CheatsModel.setCheatsTable(data["1"])
	end
	}))
	RequestHelperV2.request2(reqs, function ()
		self.requestDone = true
		require("game.Spirit.SpiritCtrl").request()
	end)
	
	self._cardList = game.player.m_formation["1"]
	self._equip = game.player.m_formation["2"]
	self._spirit = game.player.m_formation["3"]
	self._formation = game.player.m_formation["5"]
	self._pet = game.player.m_formation["6"]
	self._cheats = game.player.m_formation["7"]
	
	self:update()
end

function HeroSettingLayer:onAddHero()
	if self._showType == SHOWTYPE.PET or self._showType ~= SHOWTYPE.ZhuZhen then
		self._showType = SHOWTYPE.FORMATION
		self:switchView()
	end
	self._onAddHero = true
	self._rootnode.bottomInfoView:setVisible(true)
	self._rootnode.zhuZhenNode:setVisible(false)
	self._rootnode.zhuZhenNode_Info:setVisible(false)
	self._rootnode.jobSprite2:setVisible(false)
	self._rootnode.nameLabel:setString("")
	local heroNode = self._rootnode.heroImg:getChildByTag(FormAddHeroTag)
	if heroNode == nil then
		self:setHeroImgBg("#zhenrong_hero.png")
		local bgsize = self._rootnode.heroImg:getContentSize()
		heroNode = require("utility.MyLayer").new({
		name = "zhenrong_hero_btn",
		size = bgsize,
		})
		heroNode:setTag(FormAddHeroTag)
		heroNode:ignoreAnchorPointForPosition(false)
		heroNode:setPosition(bgsize.width/2, bgsize.height/2)
		--heroNode:align(display.CENTER)
		self._rootnode.heroImg:addChild(heroNode)
		TutoMgr.addBtn("zhenrong_anniu_yinying", self._rootnode.heroImg)
		PostNotice(NoticeKey.REMOVE_TUTOLAYER)
		print("创建背景事件监听")
		heroNode:setTouchHandler(function(event)
			if event.name == "began" then
				heroNode:setTouchEnabled(false)
				PostNotice(NoticeKey.REMOVE_TUTOLAYER)
				push_scene(require("game.form.HeroChooseScene").new({
				callback = function (data)
					PostNotice(NoticeKey.REMOVE_TUTOLAYER)
					self._onAddHero = false
					if self._formSettingView then
						self._formSettingView:removeSelf()
						self._formSettingView = nil
					end
					if #self._cardList < #data["1"] then
						self._index = #data["1"]
					end
					self:resetFormData(data)
					self:initHeadList()
					self:refreshHero(self._index)
				end,
				closelistener = function ()
					self:onAddHero()
				end
				}))
			end
		end)
		TutoMgr.active()
	else
		heroNode:setTouchEnabled(true)
	end
	
	self._rootnode.currentLevelLabel:setString("0")
	self._rootnode.maxLevelLabel:setString("0")
	self._rootnode.hpLabel:setString("")
	self._rootnode.atkLabel:setString("")
	self._rootnode.defLabel1:setString("")
	self._rootnode.defLabel2:setString("")
	self._rootnode.clsLabel:setString("")
	self._rootnode.levelNode:setVisible(false)
	for i = 1, 3 do
		self._rootnode[string.format("leadLabel_%d", i)]:setString("0")
	end
	for i = 1, 6 do
		self._rootnode[string.format("jbLabel_%d", i)]:setString("")
	end
	for k = 1, 6 do
		local equipNodeName = "equipNode_" .. tostring(k)
		self._rootnode[equipNodeName]:removeChildByTag(FormEquipChildTag, true)
		self._rootnode["greenNode_" .. k]:setVisible(false)
		self._rootnode["redNode_" .. k]:setVisible(false)
	end
	for k = 1, #getDataOpen(OPENCHECK_TYPE.ZhenQi).level do
		local spiritNodeName = "spiritNode_" .. tostring(k)
		self._rootnode[spiritNodeName]:removeChildByTag(FormEquipChildTag, true)
		self._rootnode["spiritBtn_" .. tostring(k)]:setOpacity(255)
	end
	for k = 1, #getDataOpen(OPENCHECK_TYPE.CheatsOpen).level do
		local cheatsNodeName = "cheatsNode_" .. tostring(k)
		self._rootnode[cheatsNodeName]:removeChildByTag(FormCheatsChildTag, true)
		self._rootnode["cheatsBtn_" .. tostring(k)]:setOpacity(255)
	end
	self:refreshFormStar(0)
	self._rootnode.changeHeroBtn:setVisible(false)
	self._rootnode.shizhuangNode:setVisible(false)
	self:setBtnEnable(false)
end

function HeroSettingLayer:setBtnEnable(b)
	--[[for i = 1, 8 do
	self._rootnode["spiritBtn_" .. tostring(i)]:setEnabled(b)
end
for i = 1, 6 do
	local key = "equipBtn_" .. tostring(i)
	self._rootnode[key]:setTouchEnabled(b)
end
for i = 1, 3 do
	local key = "cheatsBtn_" .. tostring(i)
	self._rootnode[key]:setTouchEnabled(b)
	end]]
	self._rootnode.touchNode:setTouchEnabled(b)
end

function HeroSettingLayer:setButtonEnable(tag)
	for k, v in ipairs(self._petSkillBtn) do
		v:setTouchEnabled(tag == SHOWTYPE.PET)
	end
	for k, v in ipairs(self._roleEquipBtn) do
		v:setTouchEnabled(tag == SHOWTYPE.FORMATION)
	end
	for k, v in ipairs(self._spiritBtn) do
		v:setEnabled(tag == SHOWTYPE.SPIRIT)
	end
	for i = 1, 3 do
		self._rootnode["cheatsBtn_" .. i]:setTouchEnabled(tag == SHOWTYPE.CHEATS)
	end
end

local ST_COLOR = {
cc.c3b(255, 38, 0),
cc.c3b(43, 164, 45),
cc.c3b(28, 94, 171),
cc.c3b(218, 129, 29)
}

function HeroSettingLayer:refreshProp(hero)
	self._rootnode.hpLabel:setString(tostring(hero.base[1]))
	self._rootnode.atkLabel:setString(tostring(hero.base[2]))
	self._rootnode.defLabel1:setString(tostring(hero.base[3]))
	self._rootnode.defLabel2:setString(tostring(hero.base[4]))
end

function HeroSettingLayer:isExistEquipByPos(pos)
	for k, v in ipairs(game.player:getEquipments()) do
		if pos == data_item_item[v.resId].pos then
			return true
		end
	end
	return false
end

local currentCard
function HeroSettingLayer:refreshFormStar(nums)
	if nums > 0 then
		self._rootnode.starBg:setVisible(true)
		for i = 1, 5 do
			self._rootnode["heroStar_" .. tostring(i)]:setVisible(false)
			if i <= 4 then
				self._rootnode["heroStar_2_" .. tostring(i)]:setVisible(false)
			end
		end
		for i = 1, nums do
			if nums == 4 or nums == 2 then
				self._rootnode["heroStar_2_" .. tostring(i)]:setVisible(true)
			else
				self._rootnode["heroStar_" .. tostring(i)]:setVisible(true)
			end
		end
	else
		self._rootnode.starBg:setVisible(false)
	end
end

function HeroSettingLayer:setHeroImgBg(imgName)
	imgName = imgName or "ui/ui_empty.png"
	if imgName ~= self.heroImgName then
		self.heroImgName = imgName
		self._rootnode.heroImg:setDisplayFrame(display.newSprite(self.heroImgName):getDisplayFrame())
	end
end

function HeroSettingLayer:refreshHeroFigure(index)
	if not self.hasInit and not self._bExit then
		return
	end
	local hero = self._cardList[index]
	local pet = self._pet[index][1]
	local card = ResMgr.getCardData(hero.resId)
	if self._showType ~= SHOWTYPE.PET then
		if index > 1 then
			self._rootnode.changeHeroBtn:setVisible(true)
			self._rootnode.shizhuangNode:setVisible(false)
		else
			self._rootnode.changeHeroBtn:setVisible(false)
			if game.player:getAppOpenData().appstore == APPOPEN_STATE.open then
				self._rootnode.shizhuangNode:setVisible(true)
			else
				self._rootnode.shizhuangNode:setVisible(false)
			end
			self:refreshHeroFashionIcon()
		end
		self._rootnode.jobSprite2:setVisible(true)
		local jobSpriteFrame = display.newSpriteFrame(string.format("zhenrong_work_%d.png", card.job))
		if jobSpriteFrame then
			self._rootnode.jobSprite2:setDisplayFrame(jobSpriteFrame)
		end
		if currentCard ~= card then
			if self.playerSound then
				audio.stopSound(self.playerSound)
				self.playerSound = nil
			end
			if card.displaySound ~= nil then
				self.playerSound = GameAudio.palyHeroDub("sound/" .. ResMgr.PERSION_SFX .. "/" .. card.displaySound)
			end
			currentCard = card
		end
		local name = HeroModel.getHeroNameByResId(hero.resId)
		self._rootnode.nameLabel:setString(name)
		self._rootnode.nameLabel:setColor(NAME_COLOR[hero.star])
		if hero.cls > 0 then
			self._rootnode.clsLabel:setVisible(true)
			self._rootnode.clsLabel:setString("+" .. tostring(hero.cls))
		else
			self._rootnode.clsLabel:setVisible(false)
		end
		self:refreshFormStar(hero.star)
		local heroPath = ResMgr.getHeroBodyName(hero.resId, hero.cls, hero.fashionId)
		self:setHeroImgBg(heroPath)
		if display.widthInPixels / display.heightInPixels > 0.67 then
			self._rootnode.heroImg:setScale(0.85)
			self._rootnode.hero_name_bg:setPosition(self._rootnode.hero_name_bg:getPositionX(), self.namebgY + self._rootnode.hero_name_bg:getContentSize().height / 2)
			for i = 1, 8 do
				self._rootnode["equipNode_" .. i]:setScale(0.85)
				self._rootnode["spiritNode_" .. i]:setScale(0.85)
				self._rootnode["equipBtn_" .. i]:setScale(0.85)
			end
			for i = 1, 3 do
				self._rootnode["cheatsBtn_" .. i]:setScale(0.85)
			end
		end
		local l = self._rootnode.heroImg:getChildByTag(FormAddHeroTag)
		if l then
			l:removeSelf()
		end
	else
		self:formPetRefresh(pet, hero)
	end
end

function HeroSettingLayer:refreshHeadHero(index, bScrollHead)
	if bScrollHead then
		if (self._index - 1) * 115 < math.abs(self._scrollItemList:getContentOffset().x) then
			self._scrollItemList:setContentOffset(cc.p(-(self._index - 1) * 115, 0), true)
		elseif self._index * 115 > math.abs(self._scrollItemList:getContentOffset().x) + self._scrollItemList:getContentSize().width then
			self._scrollItemList:setContentOffset(cc.p(-self._index * 115 + self._scrollItemList:getContentSize().width, 0), true)
		end
	end
	for i = 1, #self._headData do
		local cell = self._scrollItemList:cellAtIndex(i - 1)
		if cell then
			if i == index then
				cell:selected()
			else
				cell:unselected()
			end
		end
	end
end

function HeroSettingLayer:refreshHero(index, bScrollHead)
	self._noHero = false
	self.unUsedEquip = self.unUsedEquip or {}
	self:refreshHeadHero(index, bScrollHead)
	self:setBtnEnable(true)
	self._rootnode.levelNode:setVisible(true)
	self._onAddHero = false
	if self._formSettingView ~= nil then
		if self._formSettingView._close == false then
			self._formSettingView:removeSelf()
		end
		self._rootnode.touchNode:setTouchEnabled(true)
		self._formSettingView = nil
	end
	if index > #self._cardList then
		return
	end
	if self._showType ~= SHOWTYPE.ZhuZhen then
		self._rootnode.bottomInfoView:setVisible(true)
	end
	local hero = self._cardList[index]
	local pet = self._pet[index][1]
	if hero then
		self:refreshHeroFigure(index)
		self._rootnode.currentLevelLabel:setString(tostring(hero.level))
		self._rootnode.maxLevelLabel:setString(tostring(hero.levelLimit))
		self:refreshProp(hero)
		for i = 1, 3 do
			self._rootnode["stNameLabel_" .. tostring(i)]:setString("")
			self._rootnode["leadLabel_" .. tostring(i)]:setString("")
		end
		for k, v in ipairs(hero.shenIDAry) do
			local stData = data_shentong_shentong[data_talent_talent[v].shentong]
			local tid
			if hero.shenLvAry[k] == 0 then
				tid = stData.arr_talent[hero.shenLvAry[k] + 1]
			else
				tid = stData.arr_talent[hero.shenLvAry[k]]
			end
			local talent = data_talent_talent[tid]
			if talent then
				self._rootnode["stNameLabel_" .. tostring(k)]:setString(talent.name)
				self._rootnode["leadLabel_" .. tostring(k)]:setString(tostring(hero.shenLvAry[k]))
				if hero.shenLvAry[k] > 0 then
					self._rootnode["stNameLabel_" .. tostring(k)]:setColor(ST_COLOR[stData.type])
					self._rootnode["leadLabel_" .. tostring(k)]:setColor(ST_COLOR[stData.type])
				else
					self._rootnode["stNameLabel_" .. tostring(k)]:setColor(cc.c3b(127, 127, 127))
					self._rootnode["leadLabel_" .. tostring(k)]:setColor(cc.c3b(127, 127, 127))
				end
			else
				show_tip_label(common:getLanguageString("@MitacNotExist", tostring(tid)))
			end
		end
		for i = 1, 6 do
			local jbKey = string.format("jbLabel_%d", i)
			self._rootnode[jbKey]:setVisible(false)
		end
		do
			local heroFate = {}
			local heroData = ResMgr.getCardData(hero.resId)
			if ResMgr.getCardData(hero.resId).fate1 then
				for k, v in ipairs(ResMgr.getCardData(hero.resId).fate1) do
					if k > 6 then
						return
					end
					local jbKey = string.format("jbLabel_%d", k)
					self._rootnode[jbKey]:setVisible(true)
					self._rootnode[jbKey]:setString(data_jiban_jiban[v].name)
					self._rootnode[jbKey]:setColor(cc.c3b(119, 119, 119))
					for i, j in ipairs(hero.relation) do
						if v == j then
							self._rootnode[jbKey]:setColor(cc.c3b(255, 108, 0))
							local _type = data_jiban_jiban[v].type
							if _type == 2 or _type == 3 then
								if type(data_jiban_jiban[v].cond1) == "table" then
									for _, skillId in pairs(data_jiban_jiban[v].cond1) do
										heroFate[skillId] = true
									end
								else
									heroFate[data_jiban_jiban[v].cond1] = true
								end
							end
						end
					end
				end
			end
			alignNodesOneByOne(self._rootnode.Life1, self._rootnode.hpLabel, 1)
			alignNodesOneByOne(self._rootnode.Attack1, self._rootnode.atkLabel, 1)
			alignNodesOneByOne(self._rootnode.ThingDefense1, self._rootnode.defLabel1, 1)
			alignNodesOneByOne(self._rootnode.LawDefense1, self._rootnode.defLabel2, 1)
			local function refreshSpiritIcon()
				for k = 1, #getDataOpen(OPENCHECK_TYPE.ZhenQi).level do
					local spiritNodeName = "spiritNode_" .. tostring(k)
					self._rootnode["spiritBtn_" .. tostring(k)]:setOpacity(255)
					self._rootnode[spiritNodeName]:removeChildByTag(FormEquipChildTag, true)
				end
				for k, v in ipairs(self._spirit[index]) do
					local spiritNodeName = "spiritNode_" .. tostring(v.subpos - 6)
					local s = require("game.Spirit.SpiritIcon").new({
					id = v._id,
					resId = v.resId,
					lv = v.level,
					exp = v.curExp or 0,
					bShowName = true,
					bShowLv = true,
					offsetY = 8
					})
					s:setPosition(self._rootnode[spiritNodeName]:getContentSize().width / 2, self._rootnode[spiritNodeName]:getContentSize().height / 2 - 12)
					self._rootnode[spiritNodeName]:addChild(s, 100, FormEquipChildTag)
					self._rootnode["spiritBtn_" .. tostring(v.subpos - 6)]:setOpacity(0)
				end
			end
			local function refreshEquipIcon()
				for k = 1, 6 do
					local equipNodeName = "equipNode_" .. tostring(k)
					self._rootnode[equipNodeName]:removeChildByTag(FormEquipChildTag, true)
					self._rootnode["redNode_" .. k]:setVisible(false)
				end
				HeroSettingModel.cardIndex = index
				local _eqIdx = {
				1,
				2,
				3,
				4,
				5,
				6
				}
				local tmpIndex = {}
				for k, v in ipairs(self._equip[index]) do
					tmpIndex[v.subpos] = v
				end
				for idx = 1, 6 do
					v = tmpIndex[idx]
					if not v then
						if self.unUsedEquip[idx] then
							self._rootnode["redNode_" .. idx]:setVisible(true)
						end
					else
						local equipNodeName = "equipNode_" .. tostring(v.subpos)
						local equipBaseInfo = data_item_item[v.resId]
						_eqIdx[idx] = 0
						if self._rootnode["greenNode_" .. idx]:isVisible() then
							self._rootnode["greenNode_" .. idx]:setVisible(false)
						end
						local path = CCFileUtils:sharedFileUtils():fullPathForFilename(ResMgr.getIconImage(equipBaseInfo.icon, ResMgr.EQUIP))
						local s = ResMgr.getIconSprite({
						id = v.resId,
						resType = ResMgr.EQUIP,
						hasCorner = true
						})
						s:setPosition(self._rootnode[equipNodeName]:getContentSize().width / 2, self._rootnode[equipNodeName]:getContentSize().height / 2)
						self._rootnode[equipNodeName]:addChild(s, 100, FormEquipChildTag)
						local _fn = "redNode_" .. v.subpos
						if v.cid == 1 then
							self._rootnode[_fn]:setVisible(true)
						else
							self._rootnode[_fn]:setVisible(false)
						end
						local obj
						if v.subpos == 5 or v.subpos == 6 then
							obj = self:getSkillByID(v.objId) or {}
						else
							obj = self:getEquipByID(v.objId) or {}
						end
						if obj.propsN and 0 < obj.propsN then
							local refineInfo = data_refine_refine[v.resId]
							local propCount = #refineInfo.arr_nature2
							local num = math.floor(obj.propsN / propCount)
							if num > 0 then
								display.addSpriteFramesWithFile("ui/2015_03_18.plist", "ui/2015_03_18.png")
								local diamond = display.newSprite("#2015_03_18_diamond.png")
								diamond:setPosition(s:getContentSize().width * 0.55, diamond:getContentSize().height * 0.7)
								s:addChild(diamond)
								local jlLabel = ui.newTTFLabelWithShadow({
								text = tostring(num),
								font = FONTS_NAME.font_haibao,
								size = 20,
								color = FONT_COLOR.GREEN_1,
								shadowColor = display.COLOR_BLACK,
								})
								jlLabel:setPosition(diamond:getContentSize().width, diamond:getContentSize().height / 2)
								diamond:addChild(jlLabel)
							end
						end
						local quality
						if equipBaseInfo.Suit or heroFate[v.resId] then
							quality = equipBaseInfo.quality
						end
						if quality then
							local quas = {
							"",
							"pinzhikuangliuguang_lv",
							"pinzhikuangliuguang_lan",
							"pinzhikuangliuguang_zi",
							"pinzhikuangliuguang_jin",
							"pinzhikuangliuguang_jin"
							}
							local holoName = quas[equipBaseInfo.quality]
							local suitArma = ResMgr.createArma({
							resType = ResMgr.UI_EFFECT,
							armaName = holoName,
							isRetain = true
							})
							suitArma:setPosition(s:getContentSize().width / 2, s:getContentSize().height / 2)
							s:addChild(suitArma)
						end
						
						local label = ui.newTTFLabelWithOutline({
						text = data_item_item[v.resId].name,
						size = 22,
						font = FONTS_NAME.font_fzcy,
						align = ui.TEXT_ALIGN_CENTER,
						color = NAME_COLOR[data_item_item[v.resId].quality],
						outlineColor = display.COLOR_BLACK,
						})
						label:setPosition(s:getContentSize().width / 2, -label:getContentSize().height * 0.7)
						s:addChild(label)
						
						label = ui.newTTFLabelWithOutline({
						text = string.format("%d", v.level or obj.level),
						size = 22,
						font = FONTS_NAME.font_fzcy,
						color = display.COLOR_WHITE,
						outlineColor = display.COLOR_BLACK,
						})
						label:align(display.LEFT_TOP, 0, s:getContentSize().height)
						s:addChild(label)
					end
				end
				for _, p in ipairs(_eqIdx) do
					if _eqIdx[_] ~= 0 then
						local _rn = "greenNode_" .. _eqIdx[_]
						self._rootnode[_rn]:setVisible(true)
					end
				end
			end
			if self._showType == SHOWTYPE.SPIRIT then
				refreshSpiritIcon()
			elseif self._showType == SHOWTYPE.PET then
				self:refreshPetSkillIcon(index)
			elseif self._showType == SHOWTYPE.CHEATS then
				self:refreshCheatsIcon(index)
			else
				refreshEquipIcon()
			end
		end
	end
end

function HeroSettingLayer:resetHeadData()
	local posOpen = getDataOpen(OPENCHECK_TYPE.ZhenRong)
	self._headData = self._headData or {}
	local index = 1
	for k, v in ipairs(posOpen.level) do
		if v <= game.player:getLevel() then
			if self._headData[index] then
				self._headData[index] = HeadListType.NormalType
			else
				table.insert(self._headData, HeadListType.NormalType)
			end
			index = index + 1
		end
	end
	local cardNum = #posOpen.level
	if cardNum > #self._headData then
		if self._headData[index] then
			self._headData[index] = posOpen.level[index]
		else
			table.insert(self._headData, posOpen.level[#self._headData + 1])
		end
	end
	if #self._headData == cardNum and self._headData[cardNum] == HeadListType.NormalType then
		local zhuZhenIndex = cardNum + 1
		local zhuZhenOpen = getDataOpen(OPENCHECK_TYPE.ZhuZhen)
		for k, v in ipairs(zhuZhenOpen.level) do
			if v <= game.player:getLevel() then
				if self._headData[zhuZhenIndex] then
					self._headData[zhuZhenIndex] = HeadListType.ZhuZhenType
				else
					table.insert(self._headData, HeadListType.ZhuZhenType)
				end
			else
				table.insert(self._headData, zhuZhenOpen.level[k])
			end
			zhuZhenIndex = zhuZhenIndex + 1
		end
	end
	if self._cardList ~= nil then
		for k, v in ipairs(self._cardList) do
			if 0 == self._headData[k] then
				self._headData[k] = v
			end
		end
	end
	--dump("sssssssssssssssssssssssssssssssssssssss")
	--dump(self._headData)
	--dump(self._cardList)
end

function HeroSettingLayer:initHeadList()
	self:resetHeadData()
	if self._scrollItemList then
		self._scrollItemList:resetListByNumChange(#self._headData)
		if #self._headData - self._index < self._index then
			if self._scrollItemList:minContainerOffset().x > 0 then
				self._scrollItemList:setContentOffset(cc.p(0, 0))
			else
				self._scrollItemList:setContentOffset(cc.p(self._scrollItemList:minContainerOffset().x, 0))
			end
		end
		local cell = self._scrollItemList:cellAtIndex(#self._headData - 2)
		if cell ~= nil then
			local btn = cell:getTutoBtn()
			TutoMgr.addBtn("zhenrongzhujiemian_btn_erhaowei", btn)
		end
		return
	end
	self._scrollItemList = require("utility.TableViewExt").new({
	size = cc.size(self._rootnode.headList:getContentSize().width, self._rootnode.headList:getContentSize().height),
	createFunc = function (idx)
		idx = idx + 1
		local item = HeroIcon.new()
		return item:create({
		viewSize = self._rootnode.headList:getContentSize(),
		itemData = self._headData[idx],
		idx = idx,
		index = self._index
		})
	end,
	refreshFunc = function (cell, idx)
		idx = idx + 1
		cell:refresh({
		idx = idx,
		itemData = self._headData[idx],
		index = self._index
		})
	end,
	cellNum = #self._headData,
	cellSize = HeroIcon.new():getContentSize(),
	touchFunc = function (cell)
		if self._showType == SHOWTYPE.ZhuZhen then
			self._showType = SHOWTYPE.FORMATION
		end
		PostNotice(NoticeKey.REMOVE_TUTOLAYER)
		local idx = cell:getIdx() + 1
		self._rootnode.touchNode:setTouchEnabled(true)
		if type(self._headData[idx]) == "table" then
			self._index = idx
			self:switchView(true)
			self._noHero = false
		else
			if HeadListType.ZhuZhenType == self._headData[idx] then
				self:requestZhuZhenInfo(idx)
			elseif HeadListType.NormalType == self._headData[idx] then
				self:onAddHero()
			else
				show_tip_label(common:getLanguageString("@LevelOpen", self._headData[idx]))
			end
			self._noHero = true
		end
	end
	})
	self._scrollItemList:setPosition(0, 0)
	self._rootnode.headList:addChild(self._scrollItemList)
	
	local cell = self._scrollItemList:cellAtIndex(#self._headData - 2)
	if cell ~= nil then
		local btn = cell:getTutoBtn()
		TutoMgr.addBtn("zhenrongzhujiemian_btn_erhaowei", btn)
	end
end

function HeroSettingLayer:requestZhuZhenInfo(idx)
	local function _callback()
		self._index = idx
		self:onPartnerView()
		self:refreshHeadHero(idx)
	end
	HelpLineModel:getHelpInfo({callback = _callback})
end

function HeroSettingLayer:onPartnerView()
	self._showType = SHOWTYPE.ZhuZhen
	self:setButtonEnable(SHOWTYPE.ZhuZhen)
	self._rootnode.touchNode:setTouchEnabled(false)
	self._rootnode.starBg:setVisible(false)
	self._rootnode.bottomInfoView:setVisible(false)
	self._rootnode.heroInfoView:setVisible(false)
	self._rootnode.petInfoView:setVisible(false)
	self._rootnode.zhuZhenNode:setVisible(true)
	self._rootnode.zhuZhenNode_Info:setVisible(false)
	self:refreshHelpLine()
	if self.zhuZhenPageNode == nil then
		local pageNodeParent = self._rootnode.zhuZhenScrollNode
		local pageNodes = {}
		for i, v in ipairs(data_helper_helper) do
			local itemData = HelpLineModel:getCurrentPage(i)
			local zhuZhenItem = require("game.form.FormZhuZhenItem").new({itemData = itemData})
			table.insert(pageNodes, zhuZhenItem)
		end
		self.zhuZhenPageNode = require("app.ui.PageScrollLayer").new({
		width = pageNodeParent:getContentSize().width,
		height = pageNodeParent:getContentSize().height,
		pageSize = 1,
		rowSize = 1,
		nodes = pageNodes,
		bVertical = false,
		bFreeScroll = false,
		x = 0,
		y = 0,
		callFunc = function (index)
			HelpLineModel:setCurrentPage(index)
			self:refreshHelpLine()
		end,
		callTouchFunc = function (index)
			self:showZhenWeiInfo(index)
		end
		})
		self._rootnode.zhuZhenScrollNode:addChild(self.zhuZhenPageNode)
	end
end

function HeroSettingLayer:showZhenWeiInfo(index)
	
	local function refreshHeroFunc(data)
		self:refreshHelpLine()
		self:refreshPageHero(index)
	end
	
	local function changeHeroFunc(data)
		--dump(data)
		--dump("11111111111111111111111111111111111111111")
		HelpLineModel:setTotalProArrData(data.totalProArr)
		HelpLineModel:setHelpData(data.supportPos, data.roleCard)
		self:refreshHelpLine()
		self:refreshPageHero(data.supportPos)
	end
	
	if index == HelpLineModel.currentPage then
		local pageData = HelpLineModel:getCurrentPage()
		if pageData then
			--dump(pageData.data)
			if pageData.data ~= nil and pageData.data.resId ~= 0 then
				local cardData = pageData.data
				local layer = require("game.Hero.HeroInfoLayer").new({
				info = {
				objId = cardData.id,
				resId = cardData.resId
				},
				index = index,
				changeHero = changeHeroFunc,
				refreshHero = refreshHeroFunc,
				broadcastBg = self._rootnode.broadcast_tag,
				fromLayer = HEROINFOLAYER_FROM.FROM_ZHENWEI
				},
				1)
				game.runningScene:addChild(layer, 100)
			elseif pageData.data ~= nil and pageData.data.resId == 0 then
				self:performWithDelay(function ()
					push_scene(require("game.form.HeroChooseScene").new({
					index = index,
					fromLayer = HEROINFOLAYER_FROM.FROM_ZHENWEI,
					callback = function (data)
						game.runningScene = self:getParent()
						HelpLineModel:setTotalProArrData(data.totalProArr)
						HelpLineModel:setHelpData(data.supportPos, data.roleCard)
						self:refreshHelpLine()
						self:refreshPageHero(data.supportPos)
					end,
					closelistener = function ()
						game.runningScene = self:getParent()
					end
					}))
				end,
				0.12)
			else
				local buy = true
				if index > 1 then
					local prePageData = HelpLineModel:getCurrentPage(index - 1)
					if prePageData.data == nil then
						buy = false
					end
				else
					local pageData = HelpLineModel:getCurrentPage(index)
					if pageData.data ~= nil then
						buy = false
						show_tip_label(data_error_error[3800002].prompt)
					end
				end
				if buy == true then
					local buyMsgBox = require("game.form.FormZhuZhenBuyMsgBox").new({
					pos = index,
					removeListener = function (supportPos)
						self:refreshHelpLine()
						self:refreshPageHero(supportPos)
					end
					})
					display.getRunningScene():addChild(buyMsgBox, 1000)
				end
			end
		end
	end
end

function HeroSettingLayer:refreshPageHero(index)
	index = index or HelpLineModel.currentPage
	if self.zhuZhenPageNode then
		--dump(index)
		local itemData = HelpLineModel:getCurrentPage(index)
		--dump(itemData)
		dump(itemData)
		self.zhuZhenPageNode:refreshItem(index, itemData)
	end
end

function HeroSettingLayer:refreshHelpLine()
	for i, v in ipairs(HelpLineModel.totalProArr) do
		self._rootnode["zhuZhen_Label_" .. i]:setString("+" .. tostring(v))
	end
	local pageData = HelpLineModel:getCurrentPage()
	--dump(pageData)
	if pageData and pageData.data ~= nil then
		self._rootnode.zhuZhenQiangHuaBtn:setVisible(true)
	else
		self._rootnode.zhuZhenQiangHuaBtn:setVisible(false)
	end
	--dump(pageData.data)
	if pageData and pageData.data ~= nil and pageData.data.resId > 0 then
		local cardData = pageData.data
		self._rootnode.zhuZhen_CardDes:setVisible(true)
		self._rootnode.zhuZhen_Des:setVisible(false)
		local item = data_card_card[cardData.resId]
		local groupDes = item.groupDes or {}
		local html = ""
		for i, v in ipairs(groupDes) do
			local desArr = string.split(v, ":")
			if desArr and #desArr == 2 then
				html = html .. "<font size=\"22\" color=\"#FEEAC4\">" .. data_battleskill_battleskill[tonumber(desArr[1])].name .. ":</font>"
				local cardArr = string.split(desArr[2], ",")
				for k, v in pairs(cardArr) do
					html = html .. "<font size=\"22\" color=\"#FEEAC4\">" .. data_card_card[tonumber(v)].name .. " </font>"
				end
			end
			if i ~= #groupDes then
				html = html .. "</br>"
			end
		end
		if html == "" then
			html = "<font size=\"22\" color=\"#FEEA00\">" .. "合体技敬请期待" .. "</font>"
		end
		local skill_ContentNode = self._rootnode.zhuZhen_SkillDes
		skill_ContentNode:removeAllChildren(true)
		local contentLabel = getRichText(html, skill_ContentNode:getContentSize().width - 20, nil, 5, ui.TEXT_ALIGN_CENTER, true)
		contentLabel:setPosition(10, (skill_ContentNode:getContentSize().height + contentLabel:getContentSize().height) / 2 - contentLabel.offset)
		skill_ContentNode:addChild(contentLabel)
		local level = pageData.data.level
		local itemData = data_helper_helper[pageData.index]
		local proPercent = string.format("%.1f", (itemData.property + level * itemData.propertyUp) * 100)
		local proValue = 0
		local proValue2 = 0
		local strValue_1 = ""
		local strValue_2 = ""
		if pageData.type == HelpLineDesType.HPType then
			proValue = tonumber(proPercent) / 100 * cardData.base[1]
			strValue_1 = common:getLanguageString("@zhuzhen_ProFrom", proPercent, common:getLanguageString("@life2"))
			strValue_2 = common:getLanguageString("@zhuzhen_ProAdd", common:getLanguageString("@life2"), string.format("%d", proValue))
		elseif pageData.type == HelpLineDesType.AttackType then
			proValue = tonumber(proPercent) / 100 * cardData.base[2]
			strValue_1 = common:getLanguageString("@zhuzhen_ProFrom", proPercent, common:getLanguageString("@Attack2"))
			strValue_2 = common:getLanguageString("@zhuzhen_ProAdd", common:getLanguageString("@Attack2"), string.format("%d", proValue))
		elseif pageData.type == HelpLineDesType.DefType then
			proValue = tonumber(proPercent) / 100 * cardData.base[3]
			proValue2 = tonumber(proPercent) / 100 * cardData.base[4]
			strValue_1 = common:getLanguageString("@zhuzhen_ProDefFrom", proPercent, common:getLanguageString("@ThingDefense2"), common:getLanguageString("@LawDefense2"))
			strValue_2 = common:getLanguageString("@zhuzhen_ProDefAdd", common:getLanguageString("@ThingDefense2"), string.format("%d", proValue), common:getLanguageString("@LawDefense2"), string.format("%d", proValue2))
		end
		self._rootnode.zhuZhen_Prop_1:setString(strValue_1)
		self._rootnode.zhuZhen_Prop_2:setString(strValue_2)
	else
		self._rootnode.zhuZhen_CardDes:setVisible(false)
		local des = self:getZhuZhenDes(pageData.type)
		self._rootnode.zhuZhen_DesLabel:setString(des)
		self._rootnode.zhuZhen_Des:setVisible(true)
	end
end

function HeroSettingLayer:getZhuZhenDes(type)
	if type == HelpLineDesType.HPType then
		return common:getLanguageString("@zhuzhen_xueliang")
	elseif type == HelpLineDesType.AttackType then
		return common:getLanguageString("@zhuzhen_gongji")
	elseif type == HelpLineDesType.DefType then
		return common:getLanguageString("@zhuzhen_fangyu")
	else
		return ""
	end
end

function HeroSettingLayer:initTouchNode()
	local touchNode = self._rootnode.touchNode
	local touchNodeNew = require("utility.MyLayer").new({
	name = "touchNode",
	size = cc.size(320, 300),
	swallow = true,
	})
	touchNode:addChild(touchNodeNew)
	self._rootnode["touchNode"] = touchNodeNew
	touchNode = touchNodeNew
	touchNode:setTouchEnabled(true)
	local touchMoving = false
	local currentNode
	local targPosX, targPosY = self._rootnode.heroImg:getPosition()
	local function moveToTargetPos()
		touchMoving = true
		currentNode:runAction(transition.sequence({
		CCMoveTo:create(0.2, cc.p(targPosX, targPosY)),
		CCCallFunc:create(function ()
			touchMoving = false
		end)
		}))
	end
	local function resetHeroImage(side)
		if side == 1 then
			currentNode:setPosition(display.width * 1.5, targPosY)
		elseif side == 2 then
			currentNode:setPosition(-display.width * 0.5, targPosY)
		end
		touchMoving = true
		currentNode:runAction(transition.sequence({
		CCMoveTo:create(0.2, cc.p(targPosX, targPosY)),
		CCCallFunc:create(function ()
			touchMoving = false
		end)
		}))
	end
	local offsetX = 0
	local bTouch
	local function onTouchBegan(event)
		if touchMoving then
			return false
		end
		currentNode = self._showType ~= SHOWTYPE.PET and self._rootnode.heroImg or self._rootnode.petImg
		targPosX, targPosY = currentNode:getPosition()
		offsetX = event.x
		bTouch = true
		return true
	end
	local function onTouchMove(event)
		if touchMoving then
			return
		end
		if self._bHeroScrollDisabled ~= true then
			local posX, posY = currentNode:getPosition()
			currentNode:setPosition(posX + event.x - event.prevX, posY)
		end
		if math.abs(event.x - event.prevX) > 8 then
			bTouch = false
		end
	end
	local function onTouchEnded(event)
		if touchMoving then
			return
		end
		if self._bHeroScrollDisabled ~= true then
			offsetX = event.x - offsetX
			if offsetX >= MOVE_OFFSET then
				if self._index > 1 then
					self._index = self._index - 1
					self:refreshHero(self._index, true)
					resetHeroImage(2)
				else
					moveToTargetPos()
				end
			elseif offsetX <= -MOVE_OFFSET then
				if self._index < #self._cardList then
					self._index = self._index + 1
					self:refreshHero(self._index, true)
					resetHeroImage(1)
				else
					moveToTargetPos()
				end
			else
				moveToTargetPos()
			end
		end
		if bTouch then
			PostNotice(NoticeKey.REMOVE_TUTOLAYER)
			game.runningScene = self:getParent()
			if self._showType == SHOWTYPE.PET then
				if self._cardList[self._index] then
					self:touchPetNodeEvent()
				end
			else
				local function refreshFunc(data)
					if data then
						if data.shenIDAry then
							for k, v in ipairs(data.shenIDAry) do
								self._cardList[self._index].shenIDAry[k] = v
								self._cardList[self._index].shenLvAry[k] = data.shenLvAry[k]
							end
						end
						for k, v in ipairs(data.base) do
							self._cardList[self._index].base[k] = v
						end
						self._cardList[self._index].level = data.level or data.lv or self._cardList[self._index].level
						self._cardList[self._index].cls = data.cls
					end
					self:requestForRefreshForm()
				end
				local function changeFunc(data)
					self:resetFormData(data)
					self:initHeadList()
					self:refreshHero(self._index)
				end
				local layer = require("game.Hero.HeroInfoLayer").new({
				info = {
				objId = self._cardList[self._index].objId,
				resId = self._cardList[self._index].resId
				},
				index = self._index,
				broadcastBg = self._rootnode.broadcast_tag,
				changeHero = changeFunc,
				refreshHero = refreshFunc
				},
				1)
				game.runningScene:addChild(layer, 100)
			end
		end
	end
	
	touchNode:setTouchHandler(function (event)
		if self._showType == SHOWTYPE.ZhuZhen then
			touchNode:setTouchEnabled(false)
			return false
		end
		if event.name == "began" then
			return onTouchBegan(event)
		elseif event.name == "moved" then
			onTouchMove(event)
		elseif event.name == "ended" then
			onTouchEnded(event)
		end
	end)
end

function HeroSettingLayer:setHeroScrollDisabled(b)
	self._bHeroScrollDisabled = b
end

function HeroSettingLayer:resetFormData(data)
	if data ~= nil then
		game.player.m_formation = data
		game.player.addCulianAttr()
		self._cardList = data["1"]
		self._equip = data["2"]
		self._spirit = data["3"]
		self._formation = data["5"]
		if data["6"] then
			self._pet = data["6"]
		end
		if data["7"] then
			self._cheats = data["7"]
		end
		self._bInit = true
		local betterEquip = 0
		for _, equips in pairs(self._equip or {}) do
			for k, v in ipairs(equips) do
				if v.cid == 1 then
					betterEquip = betterEquip + 1
				end
			end
		end
		game.player:set_betterEquip(betterEquip)
		addPrompt(self._rootnode)
		self.unUsedEquip = {}
		for k, v in ipairs(game.player:getEquipments()) do
			if v.cid == 0 and v.subpos ~= 16 then
				self.unUsedEquip[v.subpos] = true
			end
		end
		for k, v in ipairs(game.player:getSkills()) do
			if v.cid == 0 then
				self.unUsedEquip[v.subpos] = true
			end
		end
		
		for k, v in ipairs(CheatsModel.totalTable or {}) do
			if v.cid == 0 then
				local cheatsData = ResMgr.getCheatsData(v.resId)
				if cheatsData.type == 1 then
					self.unUsedEquip[16] = true
					self.unUsedEquip[17] = true
				elseif cheatsData.type == 2 then
					self.unUsedEquip[18] = true
				end
			end
		end
	end
	
end

function HeroSettingLayer:updateAfterCheats(data)
	if data then
		self:resetFormData(data)
		self:refreshHero(self._index)
	end
end

function HeroSettingLayer:updateAfterSpirit(data)
	if data then
		self:resetFormData(data)
		self:refreshHero(self._index)
	end
end

function HeroSettingLayer:initSpirit()
	local function showChooseScene(tag, filter, objId)
		push_scene(require("game.form.SpiritChooseScene").new({
		index = self._index,
		subIndex = tag + 6,
		cid = self._cardList[self._index].resId,
		callback = handler(self, HeroSettingLayer.updateAfterSpirit),
		filter = filter,
		objId = objId
		}))
	end
	
	local function onSpiritIcon(spiritData, tag, filter)
		local descLayer = require("game.Spirit.SpiritInfoLayer").new(1, spiritData, function (bUpgrade)
			self._rootnode["spiritBtn_" .. tostring(tag)]:setEnabled(true)
			if bUpgrade then
				self._bUpgrade = true
			else
				showChooseScene(tag, filter, spiritData.objId)
			end
		end,
		function()
			self._rootnode["spiritBtn_" .. tostring(tag)]:setEnabled(true)
		end)
		
		self:addChild(descLayer, 2)
	end
	
	local function onClick(tag)
		local _level = game.player:getLevel()
		if _level < getDataOpen(OPENCHECK_TYPE.ZhenQi).level[tag] then
			show_tip_label(common:getLanguageString("@CurrLocationXOpen", getDataOpen(OPENCHECK_TYPE.ZhenQi).level[tag]))
			return
		end
		--self._rootnode["spiritBtn_" .. tostring(tag)]:setEnabled(false)
		local filter = {}
		for k, v in ipairs(self._spirit[self._index]) do
			filter[data_item_item[v.resId].pos] = true
		end
		local bChangeScene = true
		for k, v in ipairs(self._spirit[self._index]) do
			if v.subpos - 6 == tag then
				bChangeScene = false
				filter[data_item_item[v.resId].pos] = false
				onSpiritIcon(v, tag, filter)
				break
			end
		end
		if bChangeScene then
			showChooseScene(tag, filter)
		end
	end
	
	for i = 1, 8 do
		local btn = self._rootnode["spiritBtn_" .. tostring(i)]
		btn:registerScriptTapHandler(onClick)
		table.insert(self._spiritBtn, btn)
	end
	
end

function HeroSettingLayer:initCheats()
	
	local function showChooseScene(tag)
		local _onData = {}
		for k, v in pairs(self._cheats[self._index]) do
			_onData[v.resId] = 1
		end
		push_scene(require("game.form.CheatsChooseScene").new({
		index = self._index,
		subIndex = tag + 15,
		cid = self._cardList[self._index].resId,
		onData = _onData,
		callback = handler(self, HeroSettingLayer.updateAfterCheats)
		}))
	end
	
	local function onCheatsIcon(cheatsData, tag)
		local data = self:getCheatsByID(cheatsData.id)
		local _onData = {}
		for k, v in pairs(self._cheats[self._index]) do
			_onData[v.resId] = 1
		end
		local descLayer = require("game.Cheats.CheatsInfoLayer").new({
		id = cheatsData.id,
		onData = _onData,
		info = {
		data = data,
		index = self._index,
		subIndex = tag + 15,
		resId = cheatsData.resId,
		cid = self._cardList[self._index].resId
		},
		listener = function (formData)
			if formData then
				self:resetFormData(formData)
				self:refreshHero(self._index)
			else
				RequestHelperV2.request(RequestInfo.new({
				modulename = "fmt",
				funcname = "list",
				param = {},
				oklistener = function (data)
					self:resetFormData(data)
					self:refreshHero(self._index)
				end
				}))
			end
		end,
		closeListener = function ()
			--self._rootnode["cheatsBtn_" .. tostring(tag)]:setTouchEnabled(true)
		end
		}, 1)
		self:addChild(descLayer, 2)
	end
	local function onClick(tag)
		local _level = game.player:getLevel()
		if _level < getDataOpen(OPENCHECK_TYPE.CheatsOpen).level[tag] then
			show_tip_label(common:getLanguageString("@CurrLocationXOpen", getDataOpen(OPENCHECK_TYPE.CheatsOpen).level[tag]))
			return
		end
		--self._rootnode["cheatsBtn_" .. tostring(tag)]:setTouchEnabled(false)
		local bChangeScene = true
		for k, v in ipairs(self._cheats[self._index]) do
			if v.subpos - 15 == tag then
				bChangeScene = false
				onCheatsIcon(v, tag)
				break
			end
		end
		if bChangeScene then
			showChooseScene(tag)
		end
	end
	
	for i = 1, 3 do
		local name = "cheatsBtn_" .. i
		self._rootnode[name] = addNodeTouchListener(self._rootnode[name], function (event)
			if event.name == "began" then
				PostNotice(NoticeKey.REMOVE_TUTOLAYER)
				onClick(i)
			end
		end)
	end
	
end

function HeroSettingLayer:getEquipByID(id)
	for k, v in ipairs(game.player:getEquipments()) do
		if v._id == id then
			return v
		end
	end
	return nil
end

function HeroSettingLayer:getSkillByID(id)
	for k, v in ipairs(game.player:getSkills()) do
		if v._id == id then
			return v
		end
	end
	return nil
end

function HeroSettingLayer:getSpiritByID(id)
	for k, v in ipairs(game.player:getSpirit()) do
		if v._id == id then
			return v
		end
	end
	return nil
end

function HeroSettingLayer:getCheatsByID(id)
	for k, v in ipairs(CheatsModel.totalTable) do
		if v.id == id then
			return v
		end
	end
	return nil
end

function HeroSettingLayer:initEquip()
	local function onIcon(tag, info)
		if tag < 5 then
			local d = self:getEquipByID(info.objId)
			d.role = self._cardList[1]
			d.cuilian = info.cuilian
			if d then
				local touchNode = self._rootnode["equipBtn_" .. tostring(tag)]
				touchNode:setTouchEnabled(false)
				local layer = require("game.Equip.CommonEquipInfoLayer").new({
				index = self._index,
				subIndex = tag,
				info = d,
				closeListener = function ()
					touchNode:setTouchEnabled(true)
				end,
				listener = function (formData)
					touchNode:setTouchEnabled(true)
					if formData then
						self:resetFormData(formData)
						self:refreshHero(self._index)
					else
						RequestHelperV2.request(RequestInfo.new({
						modulename = "fmt",
						funcname = "list",
						param = {},
						oklistener = function (data)
							self:resetFormData(data)
							self:refreshHero(self._index)
						end
						}))
					end
				end
				})
				self:addChild(layer, 10)
			else
				printf("数据为空")
			end
		else
			local d = self:getSkillByID(info.objId)
			if d then
				local touchNode = self._rootnode["equipBtn_" .. tostring(tag)]
				touchNode:setTouchEnabled(false)
				local layer = require("game.skill.BaseSkillInfoLayer").new({
				index = self._index,
				subIndex = tag,
				info = d,
				closeListener = function ()
					touchNode:setTouchEnabled(true)
				end,
				listener = function (data)
					touchNode:setTouchEnabled(true)
					if data then
						self:resetFormData(data)
						self:refreshHero(self._index)
					else
						self:requestForRefreshForm()
					end
				end
				})
				self:addChild(layer, 10)
			else
				printf("数据为空")
			end
		end
	end
	local function onClick(tag)
		if tag > 4 and game.player:getLevel() < 10 then
			show_tip_label(common:getLanguageString("@KungfuFuction10Open"))
			return
		end
		local bChangeScene = true
		for k, v in ipairs(self._equip[self._index]) do
			if v.subpos == tag then
				for k, vs in ipairs(self._formation[self._index]) do
					if vs.pos == tag then
						v.cuilian = vs
					end
				end
				bChangeScene = false
				onIcon(tag, v)
				return
			end
		end
		if bChangeScene then
			if tag < 5 then
				self._rootnode["equipBtn_" .. tostring(tag)]:setTouchEnabled(false)
				push_scene(require("game.form.EquipChooseScene").new({
				index = self._index,
				subIndex = tag,
				cid = self._cardList[self._index].resId,
				callback = function (data)
					if data then
						self:resetFormData(data)
					end
				end
				}))
			else
				self._rootnode["equipBtn_" .. tostring(tag)]:setTouchEnabled(false)
				push_scene(require("game.form.SkillChooseScene").new({
				index = self._index,
				subIndex = tag,
				cid = self._cardList[self._index].resId,
				callback = function (data)
					if data then
						self:resetFormData(data)
					end
				end
				}))
			end
		end
	end
	
	for i = 1, 6 do
		local key = "equipBtn_" .. tostring(i)
		local btn = require("utility.MyLayer").new({
		name = key,
		size = self._rootnode[key]:getContentSize(),
		swallow = true,
		touchHandler = function (event)
			if event.name == "began" then
				PostNotice(NoticeKey.REMOVE_TUTOLAYER)
				onClick(i)
			end
		end
		})
		self._rootnode[key]:addChild(btn)
		table.insert(self._roleEquipBtn, tolua.cast(btn,"cc.Layer"))
		self._rootnode[key] = btn
	end
end

function HeroSettingLayer:addHero(heroData)
	table.insert(self._cardList, heroData)
	for k, v in ipairs(self._headData) do
		if type(v) == "number" and v == 0 then
			self._headData[k] = heroData
			self._scrollItemList:reloadCell(k - 1, {itemData = heroData})
			break
		end
	end
end

function HeroSettingLayer:update()
	if GameStateManager.currentState ~= GAME_STATE.STATE_ZHENRONG then
		return
	end
	if self._cardList ~= nil then
		self:initHeadList()
		self:refreshHero(self._index or 1)
		TutoMgr.addBtn("zhenrong_hero_image", self._rootnode.heroImg)
		TutoMgr.active()
	end
end

function HeroSettingLayer:refreshChoukaNotice()
	local choukaNotice = self._rootnode.chouka_notice
	if choukaNotice ~= nil then
		if game.player:getChoukaNum() > 0 then
			choukaNotice:setZOrder(2)
			choukaNotice:setVisible(true)
		else
			choukaNotice:setVisible(false)
		end
	end
end

function HeroSettingLayer:setHeroIndex(showType, indexPos)
	if showType then
		self._showType = showType
	end
	if indexPos then
		self._index = indexPos
	end
end

function HeroSettingLayer:onEnter(indexPos)
	self.hasInit = true
	local _level = game.player:getLevel()
	for k, v in ipairs(getDataOpen(OPENCHECK_TYPE.ZhenQi).level) do
		if v <= _level then
			local spiritNodeName = "spiritNode_" .. tostring(k)
			local spiritNode = self._rootnode[spiritNodeName]
			self._rootnode["spiritLock_" .. tostring(k)]:setVisible(false)
			if not spiritNode:getChildByTag(spirit_Add_Tag) then
				local s = display.newSprite("#zhenrong_add.png")
				s:setPosition(self._rootnode[spiritNodeName]:getContentSize().width / 2, self._rootnode[spiritNodeName]:getContentSize().height / 2)
				self._rootnode[spiritNodeName]:addChild(s)
				s:setTag(spirit_Add_Tag)
			end
		end
	end
	for k, v in ipairs(getDataOpen(OPENCHECK_TYPE.CheatsOpen).level) do
		if v <= _level then
			self._rootnode["cheatsLock_" .. tostring(k + 15)]:setVisible(false)
		end
		self._rootnode["cheatsOpen_" .. tostring(k + 15)]:setString("   " .. v .. " \n级开放")
	end
	if self._rootnode.nowTimeLabel then
		self._rootnode.nowTimeLabel:setString(GetSystemTime())
		self._rootnode.nowTimeLabel:schedule(function ()
			self._rootnode.nowTimeLabel:setString(GetSystemTime())
		end,
		60)
	end
	self._index = self._index or 1
	self:setBottomBtnEnabled(true)
	game.runningScene = self:getParent()
	ResMgr.createBefTutoMask(self)
	
	if self._scrollItemList ~= nil then
		local cell = self._scrollItemList:cellAtIndex(#self._headData - 2)
		if cell ~= nil then
			local btn = cell:getTutoBtn()
			TutoMgr.addBtn("zhenrongzhujiemian_btn_erhaowei", btn)
		end
	end
	
	self:switchView()
	display.addSpriteFramesWithFile("ui_zhenrong.plist", "ui_zhenrong.png")
	RegNotice(
	self,
	function ()
		self:setBottomBtnEnabled(false)
	end,
	NoticeKey.LOCK_BOTTOM)
	RegNotice(self, function ()
		self:setBottomBtnEnabled(true)
	end,
	NoticeKey.UNLOCK_BOTTOM)
	self:request()
	self:regLockNotice()
	self:refreshChoukaNotice()
	self._bUpgrade = true
	if self._bUpgrade then
		self._bUpgrade = false
		self:requestForRefreshForm()
	end
	
	if self._formSettingView == nil then
		self._bExit = false
		if self._onAddHero then
			self:onAddHero()
		end
	end
	
	local tuBtn = self._rootnode.battleBtn
	TutoMgr.addBtn("zhenrong_btn_fuben", tuBtn)
	TutoMgr.addBtn("zhujiemian_btn_huodong", self._rootnode.activityBtn)
	TutoMgr.addBtn("equip_waigong_btn", self._rootnode.equipBtn_5)
	TutoMgr.addBtn("equip_weapon_btn", self._rootnode.equipBtn_2)
	TutoMgr.addBtn("quickEquipBtn", self._rootnode.quickEquipBtn)
	TutoMgr.addBtn("btn_pet", self._rootnode.btn_pet)
	
	TutoMgr.active()
	local _jiangHuBtnNoticeTag = 6841
	local _jiangHuBtnNotice = tuBtn:getChildByTag(_jiangHuBtnNoticeTag)
	if not _jiangHuBtnNotice then
		display.addSpriteFramesWithFile("ui/ui_toplayer.plist", "ui/ui_toplayer.pvr.ccz")
		_jiangHuBtnNotice = display.newSprite("#toplayer_mail_tip.png")
		_jiangHuBtnNotice:setAnchorPoint(cc.p(1, 1))
		_jiangHuBtnNotice:setPosition(tuBtn:getContentSize().width, tuBtn:getContentSize().height)
		_jiangHuBtnNotice:setVisible(false)
		tuBtn:addChild(_jiangHuBtnNotice, 100, _jiangHuBtnNoticeTag)
	end
	if _jiangHuBtnNotice ~= nil then
		if game.player:getJiangHuBoxNum() > 0 then
			_jiangHuBtnNotice:setVisible(true)
		else
			_jiangHuBtnNotice:setVisible(false)
		end
	end
	addPrompt(self._rootnode)
	local data_config_config = require("data.data_config_config")
	if game.player.getLevel() >= data_config_config[1].tip_jianghu_level_begin and game.player.getLevel() < data_config_config[1].tip_jianghu_level then
		if self._jiantouEff ~= nil then
			self._jiantouEff:removeSelf()
		end
		local rootNode = {}
		self._jiantouEff = LoadUI("mainmenu/navigtion.ccbi", rootNode)
		self._jiantouEff:setVisible(true)
		self._jiantouEff:setPosition(tuBtn:getContentSize().width / 2, tuBtn:getContentSize().height / 2)
		rootNode.mJianTouNode:setVisible(false)
		tuBtn:addChild(self._jiantouEff)
	end
	
	local broadcastBg = self._rootnode.broadcast_tag
	if broadcastBg ~= nil then
		game.broadcast:reSet(broadcastBg)
	end
	
	--助阵强化
	self._rootnode.zhuZhenQiangHuaBtn:addHandleOfControlEvent(function ()
		local pageData = HelpLineModel:getCurrentPage()
		if pageData and pageData.data ~= nil then
			self._rootnode.zhuZhenNode_Info:setVisible(true)
			self._rootnode.zhuZhenNode:setVisible(false)
			self:refreshZhenWeiScrollInfoData(pageData.index)
			self:refreshZhenWeiInfoData(pageData.index)
		else
			show_tip_label("还没有开启此格子")
		end
	end,
	CCControlEventTouchUpInside)
	
	--助阵返回
	self._rootnode.zhenrong_zhuzhen_fanhui:addHandleOfControlEvent(function ()
		local pageData = HelpLineModel:getCurrentPage()
		if pageData and pageData.data ~= nil then
			self:refreshHelpLine()
			self:refreshPageHero()
			self._rootnode.zhuZhenNode_Info:setVisible(false)
			self._rootnode.zhuZhenNode:setVisible(true)
		else
			show_tip_label("还没有开启此格子")
		end
	end,
	CCControlEventTouchUpInside)
	
	--助阵确认
	self._rootnode.confirmBtn:addHandleOfControlEvent(function (sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		local helperData
		local pageData = HelpLineModel:getCurrentPage()
		if pageData and pageData.data ~= nil then
			if pageData.data.level + 1 > #data_helperlevel_helperlevel then
				show_tip_label(common:getLanguageString("@zhuzhen_full_level"))
				return
			end
			helperData = data_helperlevel_helperlevel[pageData.data.level + 1]
		else
			return
		end
		if helperData and game.player.m_silver < helperData.expend then
			ResMgr.showMsg(8)
			return
		end
		if HelpLineModel.fu < helperData.itemNum then
			show_tip_label(common:getLanguageString("@zhuzhen_use_empty"))
			return
		end
		HelpLineModel:upLevelHelp({
		pos = pageData.index,
		callback = function (data)
			HelpLineModel:setZhenWeiData(data)
			self:refreshZhenWeiInfoData()
			show_tip_label(common:getLanguageString("@Intensify") .. common:getLanguageString("@SuccessLabel"))
		end
		})
	end,
	CCControlEventTouchUpInside)
	
end

function HeroSettingLayer:refreshZhenWeiScrollInfoData(pos)
	local scrollView = self._rootnode.zhuzhen_info_scroll_node
	local contentViewSize = self._rootnode.contentView:getContentSize()
	self._rootnode.contentView:removeAllChildren()
	local height = 2
	for i, v in ipairs(data_helper_helper[pos].unlockLevel) do
		local str_1 = ""
		local str_type = data_helper_helper[pos].unlockproperty[i]
		if str_type == 81 then
			str_1 = common:getLanguageString("@life2")
		elseif str_type == 82 then
			str_1 = common:getLanguageString("@Attack2")
		elseif str_type == 83 then
			str_1 = common:getLanguageString("@ThingDefense2")
		elseif str_type == 84 then
			str_1 = common:getLanguageString("@LawDefense2")
		end
		local str = common:getLanguageString("@zhuzhen_wei_des", v)
		local lbl = CCLabelTTF:create(str, FONTS_NAME.font_fzcy, 19)
		lbl:setAnchorPoint(cc.p(0, 1))
		lbl:setPosition(20, -height)
		local str2 = common:getLanguageString("@zhuzhen_wei_des2", str_1, data_helper_helper[pos].value[i])
		local lbl2 = CCLabelTTF:create(str2, FONTS_NAME.font_fzcy, 19)
		lbl2:setAnchorPoint(cc.p(0, 1))
		lbl2:setPosition(220, -height)
		lbl:setColor(cc.c3b(94, 77, 41))
		lbl2:setColor(cc.c3b(94, 77, 41))
		self._rootnode.contentView:addChild(lbl)
		self._rootnode.contentView:addChild(lbl2)
		height = height + lbl:getContentSize().height
	end
	local sz = cc.size(contentViewSize.width, contentViewSize.height + height)
	self._rootnode.descView:setContentSize(sz)
	self._rootnode.contentView:setPosition(cc.p(sz.width / 2, sz.height))
	scrollView:updateInset()
	scrollView:setContentOffset(cc.p(0, -sz.height + scrollView:getViewSize().height), false)
end

function HeroSettingLayer:refreshZhenWeiInfoData(pos)
	local pageData = HelpLineModel:getCurrentPage(pos)
	if pageData and pageData.data ~= nil then
		local str = self:getLevelPro(pageData.index, pageData.data.level, pageData.type)
		self._rootnode.zhuzhen_info_left:setVisible(true)
		self._rootnode.info_add_1:setString(str)
		self._rootnode.zhuZhenWei_LV:setString(tostring(pageData.data.level))
		if pageData.data.level == #data_helperlevel_helperlevel then
			self._rootnode.zhuzhen_info_right:setVisible(false)
		else
			self._rootnode.zhuzhen_info_right:setVisible(true)
			local str_2 = self:getLevelPro(pageData.index, pageData.data.level + 1, pageData.type)
			self._rootnode.info_add_2:setString(str_2)
		end
		self:setProImage(pageData.type)
		self:setUsePro(pageData.data.level + 1)
	else
		show_tip_label("数据异常")
	end
end

function HeroSettingLayer:setUsePro(level)
	self._rootnode.zhuzhen_all:setString(":" .. tostring(HelpLineModel.fu) .. ")")
	if level > #data_helperlevel_helperlevel then
		self._rootnode.zhuzhen_xiaohao:setVisible(false)
		return
	end
	self._rootnode.zhuzhen_xiaohao:setVisible(true)
	self._rootnode.info_use_1:setVisible(true)
	self._rootnode.info_use_2:setVisible(true)
	local itemData = data_helperlevel_helperlevel[level]
	self._rootnode.info_use_1:setString(itemData.expend)
	self._rootnode.info_use_2:setString(itemData.itemNum)
end

function HeroSettingLayer:setProImage(pro_type)
	self._rootnode.info_type_label:setDisplayFrame(display.newSpriteFrame("zhenrong_zhuzhen_lable_" .. pro_type .. ".png"))
	self._rootnode.info_type:setDisplayFrame(display.newSpriteFrame("zhenrong_zhuzhen_type_" .. pro_type .. ".png"))
end

function HeroSettingLayer:getLevelPro(index, level, pro_type)
	local itemData = data_helper_helper[index]
	local proPercent = (itemData.property + level * itemData.propertyUp) * 100
	local strValue_1 = ""
	if pro_type == HelpLineDesType.HPType then
		strValue_1 = common:getLanguageString("@life2") .. "+" .. string.format("%.1f", proPercent) .. "%"
	elseif pro_type == HelpLineDesType.AttackType then
		strValue_1 = common:getLanguageString("@Attack2") .. "+" .. string.format("%.1f", proPercent) .. "%"
	elseif pro_type == HelpLineDesType.DefType then
		strValue_1 = common:getLanguageString("@ThingDefense2") .. "+" .. string.format("%.1f", proPercent) .. "%\n" .. common:getLanguageString("@LawDefense2") .. "+" .. string.format("%.1f", proPercent) .. "%"
	end
	return strValue_1
end

function HeroSettingLayer:requestForRefreshForm()
	local reqs = {}
	table.insert(reqs, RequestInfo.new({
	modulename = "skill",
	funcname = "list",
	param = {},
	oklistener = function (data)
		game.player:setSkills(data["1"])
	end
	}))
	table.insert(reqs, RequestInfo.new({
	modulename = "fmt",
	funcname = "list",
	param = {},
	oklistener = function (data)
		self:resetFormData(data)
		self:refreshHero(self._index)
	end
	}))
	RequestHelperV2.request2(reqs, function ()
	end)
end

function HeroSettingLayer:onExit()
	HeroSettingModel.cardIndex = 0
	UnRegNotice(self, NoticeKey.LOCK_BOTTOM)
	UnRegNotice(self, NoticeKey.UNLOCK_BOTTOM)
	self:setHeroImgBg()
	self:setPetImgBg()
	self._bExit = true
	TutoMgr.removeBtn("zhenrongzhujiemian_btn_erhaowei")
	TutoMgr.removeBtn("equip_waigong_btn")
	TutoMgr.removeBtn("zhenrong_anniu_yinying")
	TutoMgr.removeBtn("zhujiemian_btn_huodong")
	TutoMgr.removeBtn("equip_weapon_btn")
	TutoMgr.removeBtn("quickEquipBtn")
	TutoMgr.removeBtn("btn_pet")
	self:unLockNotice()
	ResMgr.showTextureCache()
	CCTextureCache:sharedTextureCache():removeUnusedTextures()
	self.hasInit = false
end

function HeroSettingLayer:onEnterTransitionFinish()
	
end

function HeroSettingLayer:changePet()
	self:performWithDelay(function ()
		push_scene(require("game.form.FormChoosePetScene").new({
		index = self._index,
		cid = self._cardList[self._index].resId,
		callback = function (data)
			if data then
				self:resetFormData(data)
				self:initHeadList()
			end
		end,
		closelistener = function ()
		end
		}))
	end,
	0.12)
end

function HeroSettingLayer:initPet()
	local function onClick(tag)
		if tag > 4 then
			return
		end
		if not self._pet[self._index][1] then
			return
		end
		local pet = self._pet[self._index][1]
		local petData = ResMgr.getPetData(pet.resId)
		if not petData.skills or not petData.skills[tag] then
			return
		end
		local petSkillInfo
		if pet.skills[tag] then
			petSkillInfo = require("game.Pet.PetSkillInfo").new({
			objId = pet._id,
			id = petData.skills[tag],
			skillType = 2,
			lv = pet.skillLevels[tag] or 1,
			closeFunc = function (skillLevelUp)
				if skillLevelUp then
					self:requestForRefreshForm()
				end
			end,
			updataSkillCallBack = function (skillIndex, skillLevel)
			end
			})
		else
			petSkillInfo = require("game.Pet.PetSkillInfo").new({
			objId = self._pet[self._index][1]._id,
			id = petData.skills[tag],
			skillType = 3,
			lv = self._pet[self._index][1].skillLevels[tag] or 1
			})
		end
		game.runningScene:addChild(petSkillInfo, FormUpLayerTag, FormUpLayerTag)
	end
	
	for i = 1, 4 do
		local key = "petSkillBtn_" .. tostring(i)
		local btn = require("utility.MyLayer").new({
		name = key,
		size = self._rootnode[key]:getContentSize(),
		swallow = true,
		touchHandler = function (event)
			if event.name == "ended" then
				PostNotice(NoticeKey.REMOVE_TUTOLAYER)
				onClick(i)
			end
		end
		})
		self._rootnode[key]:addChild(btn)
		table.insert(self._petSkillBtn, tolua.cast(btn,"cc.Layer"))
		self._rootnode[key] = btn
	end
	
	self._rootnode.changePetBtn:addHandleOfControlEvent(function ()
		self:changePet()
	end,
	CCControlEventTouchUpInside)
end

function HeroSettingLayer:refreshCheatsIcon(index)
	for k = 1, 3 do
		local cheatsNodeName = "cheatsNode_" .. tostring(k)
		self._rootnode[cheatsNodeName]:removeChildByTag(FormCheatsChildTag, true)
		self._rootnode["cheatsRedNode_" .. k]:setVisible(false)
	end
	HeroSettingModel.cardIndex = index
	local _cheatsIdx = {
	1,
	2,
	3
	}
	local tmpIndex = {}
	
	for k, v in ipairs(self._cheats[index] or {}) do
		tmpIndex[v.subpos - 15] = v
	end
	
	for idx = 1, 3 do
		v = tmpIndex[idx]
		if not v then --没有装备
			local _level = game.player:getLevel()
			if _level >= getDataOpen(OPENCHECK_TYPE.CheatsOpen).level[idx] then
				--存在没有装备的秘籍	
				if self.unUsedEquip[idx + 15] == true then
					self._rootnode["cheatsRedNode_" .. idx]:setVisible(true)
				end
			else
				_cheatsIdx[idx] = 0
			end
		else
			local cheatsNodeName = "cheatsNode_" .. tostring(idx)
			local cheatsBaseInfo = data_cheats_cheats[v.resId]
			_cheatsIdx[idx] = 0
			if self._rootnode["cheatsGreenNode_" .. idx]:isVisible() then
				self._rootnode["cheatsGreenNode_" .. idx]:setVisible(false)
			end
			local path = CCFileUtils:sharedFileUtils():fullPathForFilename(ResMgr.getIconImage(cheatsBaseInfo.icon, ResMgr.CHEATS))
			local s = ResMgr.getIconSprite({
			id = v.resId,
			resType = ResMgr.CHEATS,
			hasCorner = true
			})
			s:setPosition(self._rootnode[cheatsNodeName]:getContentSize().width / 2, self._rootnode[cheatsNodeName]:getContentSize().height / 2)
			self._rootnode[cheatsNodeName]:addChild(s, 100, FormCheatsChildTag)
			--秘籍框右上角小红点	
			local _fn = "cheatsRedNode_" .. idx
			if v.cid == 1 then
				self._rootnode[_fn]:setVisible(true)
			else
				self._rootnode[_fn]:setVisible(false)
			end
			if cheatsBaseInfo.quality then
				local quas = {
				"",
				"pinzhikuangliuguang_lv",
				"pinzhikuangliuguang_lan",
				"pinzhikuangliuguang_zi",
				"pinzhikuangliuguang_jin",
				"pinzhikuangliuguang_jin"
				}
				local holoName = quas[cheatsBaseInfo.quality]
				local suitArma = ResMgr.createArma({
				resType = ResMgr.UI_EFFECT,
				armaName = holoName,
				isRetain = true
				})
				suitArma:setPosition(s:getContentSize().width / 2, s:getContentSize().height / 2)
				s:addChild(suitArma)
			end
			
			local label = ui.newTTFLabelWithOutline({
			text = cheatsBaseInfo.name,
			size = 22,
			font = FONTS_NAME.font_fzcy,
			align = ui.TEXT_ALIGN_CENTER,
			color = NAME_COLOR[cheatsBaseInfo.quality],
			outlineColor = display.COLOR_BLACK,
			})
			label:setPosition(s:getContentSize().width / 2, -label:getContentSize().height * 0.7)
			s:addChild(label)
			
			label = ui.newTTFLabelWithOutline({
			text = string.format("%d", v.floor or 1),
			size = 22,
			font = FONTS_NAME.font_fzcy,
			color = display.COLOR_WHITE,
			outlineColor = display.COLOR_BLACK,
			})
			s:addChild(label)
			label:setPosition(cc.p(20 - label:getContentSize().width / 2, s:getContentSize().height - 14))
		end
	end
	
	--加号图标
	for j, p in ipairs(_cheatsIdx) do
		if _cheatsIdx[j] ~= 0 then
			local _rn = "cheatsGreenNode_" .. _cheatsIdx[j]
			self._rootnode[_rn]:setVisible(true)
		end
	end
end

function HeroSettingLayer:refreshPetSkillIcon(index)
	formationLayer.refreshPetSkillIcon(self, index)
end

function HeroSettingLayer:formPetRefresh(pet, hero)
	formationLayer.formPetRefresh(self, pet, hero)
end

function HeroSettingLayer:setPetImgBg(imgName)
	imgName = imgName or "ui/ui_empty.png"
	if imgName ~= self.petImgName then
		self.petImgName = imgName
		self._rootnode.petImg:setDisplayFrame(display.newSprite(self.petImgName):getDisplayFrame())
		self._rootnode.petImg:setAnchorPoint(0.5, 0.5)
	end
end

function HeroSettingLayer:touchPetNodeEvent()
	if not self._pet[self._index][1] then
		self:performWithDelay(function ()
			push_scene(require("game.form.FormChoosePetScene").new({
			index = self._index,
			cid = self._cardList[self._index].resId,
			callback = function (data)
				if data then
					self:resetFormData(data)
					self:initHeadList()
				end
			end,
			closelistener = function ()
			end
			}))
		end,
		0.12)
	else
		local pet = self._pet[self._index][1]
		local petList = PetModel.getPetTable()
		local petIndex
		for key, petData in pairs(petList) do
			if petData._id == pet._id then
				petIndex = key
				break
			end
		end
		local layer = require("game.Pet.PetInfoLayer").new({
		cellIndex = petIndex,
		broadcastBg = self._rootnode.broadcast_tag,
		changeHero = function ()
			self:changePet()
		end,
		removeListener = function (changed)
			if changed then
				self:requestForRefreshForm()
			end
		end
		}, 1)
		game.runningScene:addChild(layer, FormUpLayerTag, FormUpLayerTag)
	end
end

function HeroSettingLayer:initFashion()
	local function fashionBtnFuc()
		local bHasOpen, prompt = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.Fashion, game.player:getLevel(), game.player:getVip())
		if not bHasOpen then
			show_tip_label(prompt)
			return
		end
		local fashionList = FashionModel.getFashionList()
		if not fashionList then
			show_tip_label(common:getLanguageString("@DataInRequest"))
			return
		end
		if #fashionList == 0 then
			show_tip_label(common:getLanguageString("@fashionNoChange"))
			return
		end
		
		if not FashionModel.equipFashion then
			push_scene(require("game.form.FormChooseFashionScene").new({
			callback = function (data)
			end
			}))
		else
			local layer = require("game.shizhuang.FashionInfoLayer").new({
			info = FashionModel.equipFashion,
			changeListener = function ()
				self:requestForRefreshForm()
			end,
			removeListener = function (hasChange)
			end
			}, 1)
			self:addChild(layer, 10)
		end
	end
	
	--时装按键
	local key = "equipBtn_7"
	self._rootnode[key]:setTouchEnabled(true)
	self._rootnode[key]:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
		if event.name == "began" then
			PostNotice(NoticeKey.REMOVE_TUTOLAYER)
			fashionBtnFuc()
		end
	end)
end

--[[ 时装位置]]
function HeroSettingLayer:refreshHeroFashionIcon()
	local fashionNode = self._rootnode.equipNode_7
	fashionNode:removeAllChildren()
	local fashionId = game.player:getFashionId()
	dump(fashionId)
	if fashionId > 0 then
		local nodeSize = fashionNode:getContentSize()
		local item = ResMgr.refreshIcon({
		id = fashionId,
		resType = ResMgr.FASHION,
		itemType = ITEM_TYPE.shizhuang
		})
		item:setPosition(nodeSize.width * 0.5, nodeSize.height * 0.5)
		fashionNode:addChild(item)
		self._rootnode.greenNode_7:setVisible(false)
	else
		self._rootnode.greenNode_7:setVisible(true)
	end
end

return HeroSettingLayer