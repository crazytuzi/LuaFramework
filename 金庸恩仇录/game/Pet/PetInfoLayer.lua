local data_item_nature = require("data.data_item_nature")
local data_talent_talent = require("data.data_talent_talent")
local data_jiban_jiban = require("data.data_jiban_jiban")
local data_battleskill_battleskill = require("data.data_battleskill_battleskill")
local data_shentong_shentong = require("data.data_shentong_shentong")
local data_pet_skill = require("data.data_petskill_petskill")
require("utility.richtext.richText")
require("data.data_langinfo")

local ST_COLOR = {
cc.c3b(255, 38, 0),
cc.c3b(43, 164, 45),
cc.c3b(28, 94, 171),
cc.c3b(218, 129, 29)
}

local DesignSize = {
ST = cc.size(display.width, 80),
JN = cc.size(display.width, 240),
JB = cc.size(display.width, 55),
JJ = cc.size(display.width, 150)
}

local ResShenTongCost = 50

local PetInfoLayer = class("PetInfoLayer", function()
	return require("utility.ShadeLayer").new(cc.c4b(100, 100, 100, 0))
end)

local JNItem = class("JNItem", function(t)
	local height = 0
	local proxy = CCBProxy:create()
	local rootnode = {}
	local node = CCBuilderReaderLoad("pet/pet_skill_item.ccbi", proxy, rootnode, display.newNode(), CCSizeMake(DesignSize.JN.width, DesignSize.JN.height + height))
	local objID = t.petObjId
	local skillNameTab = {}
	local function updataSkillLvCallBack(par)
		if skillNameTab["skillName_" .. par.idx] then
			skillNameTab["skillName_" .. par.idx].lvLable:setString(par.lv)
		end
	end
	local showType = t.infoType
	if t.infoType == 1 or t.infoType == 2 then
		showType = 2
	elseif t.infoType == 3 then
		showType = 1
	end
	for k, v in ipairs(t) do
		if skillNameTab["skillName_" .. k] == nil then
			if v.t == 1 then
				skillNameTab["skillName_" .. k] = PetModel.getPetSkillIcon({
				id = v.info.id,
				level = v.lv,
				nameColor = NAME_COLOR[1],
				showName = true,
				lockType = v.t,
				customName = common:getLanguageString("@SkillJinJieUnlock", t.skillAdd[k])
				})
			else
				skillNameTab["skillName_" .. k] = PetModel.getPetSkillIcon({
				id = v.info.id,
				level = v.lv,
				showName = true,
				lockType = v.t
				})
			end
			skillNameTab["skillName_" .. k]:setAnchorPoint(cc.p(0, 0))
			skillNameTab["skillName_" .. k]:setPosition(0, 20)
			rootnode["skill_" .. k]:addChild(skillNameTab["skillName_" .. k])
		end
		--czy
		addTouchListener(rootnode["skill_" .. k], function(sender, eventType)
			if eventType == EventType.began and v.t ~= 2 then
				local itemInfo = require("game.Pet.PetSkillInfo").new({
				objId = objID,
				updataSkillCallBack = updataSkillLvCallBack,
				id = v.info.id,
				lv = v.lv,
				lock = v.t,
				skillType = showType
				})
				if t.obj ~= nil then
					t.obj:addChild(itemInfo, 1000)
				else
					CCDirector:sharedDirector():getRunningScene():addChild(itemInfo, 1000)
				end
			end
		end)
	end
	return node
end)

local JBItem = class("JBItem", function(t, relation)
	local height = 0
	local nodes = {}
	for k, v in ipairs(t) do
		if k > 6 then
			return
		end
		local color1 = "777777"
		local color2 = "777777"
		if relation == 1 then
			color1 = "ff6c00"
			color2 = "ff6c00"
		end
		local bFlag = 0
		for i = 1, 3 do
			if v[string.format("nature%d", i)] ~= nil then
				local nature = data_item_nature[v[string.format("nature%d", i)]]
				if nature.id == 33 or nature.id == 34 then
					bFlag = bFlag + 1
				end
			end
		end
		local tmpStr = ""
		local bSkip = false
		for i = 1, 3 do
			if v[string.format("nature%d", i)] ~= nil then
				local nature = data_item_nature[v[string.format("nature%d", i)]]
				local val = ""
				if nature.type == 1 then
					val = tostring(v.value1)
				else
					val = tostring(v.value1) .. "%"
				end
				if (nature.id == 33 or nature.id == 34) and bFlag == 2 then
					if bSkip == false then
						tmpStr = tmpStr .. string.format("，%s+%s", common:getLanguageString("@Defence"), val)
						bSkip = true
					end
				else
					tmpStr = tmpStr .. string.format("，%s+%s", nature.nature, val)
				end
			end
		end
		local htmlText = "<font size=\"22\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#%s\">%s    </font><font size=\"22\" color=\"#%s\">%s%s</font>"
		local infoNode = getRichText(string.format(htmlText, color1, v.name, color2, v.describe, tmpStr), display.width * 0.88)
		table.insert(nodes, infoNode)
		height = height + infoNode:getContentSize().height + 10
	end
	height = height + 15
	local proxy = CCBProxy:create()
	local rootnode = {}
	local node = CCBuilderReaderLoad("pet/pet_jiban_item.ccbi", proxy, rootnode, display.newNode(), CCSizeMake(DesignSize.JB.width, DesignSize.JB.height + height))
	height = 0
	for i = #nodes, 1, -1 do
		nodes[i]:setPosition(30, nodes[i]:getContentSize().height + height - 14)
		node:addChild(nodes[i])
		height = nodes[i]:getContentSize().height + height + 5
	end
	return node
end)

local JJItem = class("JJItem", function(str)
	local proxy = CCBProxy:create()
	local rootnode = {}
	local sz = DesignSize.JJ
	if string.utf8len(str) / 28 > 3 then
		sz = cc.size(DesignSize.JJ.width, DesignSize.JJ.height + 15)
	elseif string.utf8len(str) / 28 < 2 then
		sz = cc.size(DesignSize.JJ.width, DesignSize.JJ.height - 20)
	end
	local node = CCBuilderReaderLoad("pet/pet_intr_item.ccbi", proxy, rootnode, display.newNode(), sz)
	rootnode.descLabel:setDimensions(cc.size(node:getContentSize().width * 0.88, 100))
	rootnode.descLabel:setString(str)
	return node
end)

function PetInfoLayer:initLock()
	local petData = PetModel.getPetByObjId(self.objID)
	
	--锁定
	self._rootnode.lock_btn:addHandleOfControlEvent(function()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		self._rootnode.lock_btn:setEnabled(false)
		self._rootnode.unlock_btn:setEnabled(false)
		ResMgr.showMsg(28)
		self._rootnode.lock_btn:setVisible(false)
		self._rootnode.unlock_btn:setVisible(true)
		local a = self._info._id
		RequestHelper.lockPet({
		cids = "" .. self.objID,
		acc = game.player:getAccount(),
		lock = 1,
		callback = function()
			self.isLock = true
			self._rootnode.lock_btn:setEnabled(true)
			self._rootnode.unlock_btn:setEnabled(true)
			petData.lock = 1
		end
		})
	end,
	CCControlEventTouchUpInside)
	
	--解锁
	self._rootnode.unlock_btn:addHandleOfControlEvent(function()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		self._rootnode.lock_btn:setEnabled(false)
		self._rootnode.unlock_btn:setEnabled(false)
		ResMgr.showMsg(29)
		self._rootnode.lock_btn:setVisible(true)
		self._rootnode.unlock_btn:setVisible(false)
		RequestHelper.lockPet({
		cids = "" .. self.objID,
		acc = game.player:getAccount(),
		lock = 0,
		callback = function()
			self._rootnode.lock_btn:setEnabled(true)
			self._rootnode.unlock_btn:setEnabled(true)
			self.isLock = false
			petData.lock = 0
		end
		})
	end,
	CCControlEventTouchUpInside)
end

function PetInfoLayer:ctor(param, infoType)
	self:setNodeEventEnabled(true)
	self._broadcastBg = param.broadcastBg
	self.removeListener = param.removeListener
	local petData
	if param.cellIndex then
		self.cellIndex = param.cellIndex
		petData = PetModel.totalTable[self.cellIndex]
	else
		self.petId = param.petId
		petData = PetModel.getInitPetDataById(param.petId)
	end
	self._detailInfo = petData
	self.objID = self._detailInfo._id
	self._proxy = CCBProxy:create()
	self._rootnode = {}
	local bgHeight = display.height
	self.needUpdate = false
	local bgNode = CCBuilderReaderLoad("pet/pet_info.ccbi", self._proxy, self._rootnode, self, CCSizeMake(display.width, bgHeight - 30))
	self:addChild(bgNode, 1)
	bgNode:setPosition(display.width / 2, display.cy - bgHeight / 2)
	local infoNode = CCBuilderReaderLoad("pet/pet_info_detail.ccbi", self._proxy, self._rootnode, self, CCSizeMake(display.width, bgHeight - 30 - 85 - 68))
	infoNode:setPosition(ccp(0, 85))
	bgNode:addChild(infoNode)
	self.petSize = self._rootnode.tag_card_bg:getContentSize()
	self.petSize.width = self.petSize.width * self._rootnode.tag_card_bg:getScaleX()
	self.petSize.height = self.petSize.height * self._rootnode.tag_card_bg:getScaleY()
	self._rootnode.bottomMenuNode:setZOrder(1)
	
	--名称
	local heroNameLabel = ui.newTTFLabelWithShadow({
	text = "",
	font = FONTS_NAME.font_haibao,
	align = ui.TEXT_ALIGN_CENTER,
	size = 28,
	color = FONT_COLOR.WHITE,
	shadowColor = FONT_COLOR.BLACK,
	})
	
	ResMgr.replaceKeyLable(heroNameLabel, self._rootnode.itemNameLabel, 0, 0)
	heroNameLabel:align(display.CENTER)
	
	--进阶
	local clsLabel = ui.newTTFLabelWithShadow({
	text = "",
	font = FONTS_NAME.font_haibao,
	size = 28,
	color = cc.c3b(46, 194, 49),
	shadowColor = FONT_COLOR.BLACK,
	})
	
	ResMgr.replaceKeyLable(clsLabel, self._rootnode.itemNameLabel, 0, 0)
	clsLabel:align(display.LEFT_CENTER)
	self._rootnode.itemNameLabel:removeSelf()
	
	local _index = param.index
	display.addSpriteFramesWithFile("ui_zhenrong.plist", "ui_zhenrong.png")
	local pt = self._rootnode.scrollView:convertToWorldSpace(cc.p(0, 0))
	local _info = petData
	local _changeHeroListener = param.changeHero
	local _refreshHeroListener = param.refreshHero
	local _baseInfo = ResMgr.getPetData(_info.resId)
	if _baseInfo.isItem == 1 then
		self._rootnode.jinJieBtn:setVisible(false)
		self._rootnode.qiangHuBtn:setVisible(false)
	end
	self.infoType = infoType
	if infoType == 2 then
		self._rootnode.changeBtn:setVisible(false)
		self.createJinjieLayer = param.createJinjieLayer
		self.createQiangHuaLayer = param.createQiangHuaLayer
		self._rootnode.lock_node:setVisible(false)
		self:initLock()
	elseif infoType == 3 then
		self._rootnode.changeBtn:setVisible(false)
		self._rootnode.lock_node:setVisible(false)
		self._rootnode.qiangHuBtn:setVisible(false)
		self._rootnode.jinJieBtn:setVisible(false)
	else
		self._rootnode.changeBtn:setVisible(true)
		self._rootnode.lock_node:setVisible(false)
	end
	self._rootnode.titleLabel:setString(common:getLanguageString("@PetInfo"))
	function self.refresh(_)
		self._rootnode.contentViewNode:removeAllChildrenWithCleanup(true)
		local nameText = _baseInfo.name
		heroNameLabel:setString(nameText)
		heroNameLabel:setColor(NAME_COLOR[self._detailInfo.star])
		if self._detailInfo.cls > 0 then
			clsLabel:setString(string.format("+%d", self._detailInfo.cls))
			clsLabel:setPositionX(heroNameLabel:getPositionX() + heroNameLabel:getContentSize().width/2)
		end
		self._rootnode.curLevalLabel:setString(tostring(self._detailInfo.level))
		local maxLv = math.min(self._detailInfo.levelLimit, game.player.m_level)
		self._rootnode.maxLevalLabel:setString(tostring(maxLv))
		self._rootnode.cardName:setString(_baseInfo.name)
		self._rootnode.tag_card_bg:setDisplayFrame(display.newSprite("#card_ui_bg_" .. self._detailInfo.star .. ".png"):getDisplayFrame())
		local a = self._detailInfo.star
		for i = 1, self._detailInfo.star do
			self._rootnode["star" .. i]:setVisible(true)
		end
		for i = 1, 4 do
			self._rootnode[string.format("basePropLabel_%d", i)]:setString(tostring(math.ceil(self._detailInfo.baseRate[i] + self._detailInfo.addBaseRate[i])))
		end
		local heroImg = ResMgr.getPetData(self._detailInfo.resId).body
		local heroPath = CCFileUtils:sharedFileUtils():fullPathForFilename(ResMgr.getLargeImage(heroImg, ResMgr.PET))
		self._rootnode.heroImage:setDisplayFrame(display.newSprite(heroPath):getDisplayFrame())
		local imageSize = self._rootnode.heroImage:getContentSize()
		local scale = 1
		if imageSize.width > self.petSize.width or imageSize.height > self.petSize.height then
			scale = math.min(self.petSize.width / imageSize.width, self.petSize.height / imageSize.height)
		end
		self._rootnode.heroImage:setScale(scale)
		local height = 0
		local function addJNItem()
			local t = {}
			t.petObjId = self.objID
			local petData
			if param.cellIndex then
				petData = PetModel.getPetByObjId(self.objID)
			else
				petData = PetModel.getInitPetDataById(self.petId)
			end
			t.infoType = self.infoType
			local _baseInfo = ResMgr.getPetData(petData.resId)
			if not _baseInfo.skills then
				return
			end
			local skillCount = #_baseInfo.skills
			for i = 1, skillCount do
				local skillInfo = data_pet_skill[_baseInfo.skills[i]]
				if skillInfo then
					for j = 1, #petData.skills do
						if petData.skills[j] == _baseInfo.skills[i] then
							table.insert(t, {
							info = skillInfo,
							lv = petData.skillLevels[j],
							t = 0
							})
							break
						elseif j == #petData.skills then
							table.insert(t, {
							info = skillInfo,
							lv = 1,
							t = 1
							})
						end
					end
				end
			end
			for q = skillCount, 3 do
				table.insert(t, {
				info = {id = 0},
				lv = 1,
				t = 2
				})
			end
			t.skillAdd = _baseInfo.skillAdd
			if #t > 0 then
				t.obj = self
				local item = JNItem.new(t)
				item:setPosition(self._rootnode.contentView:getContentSize().width / 2, -height + 40)
				self._rootnode.contentViewNode:addChild(item)
				height = height + item:getContentSize().height + 2
			end
		end
		local function addJBItem()
			local t = {}
			local petData
			if param.cellIndex then
				petData = PetModel.getPetByObjId(self.objID)
			else
				petData = PetModel.getInitPetDataById(self.petId)
			end
			local _baseInfo = ResMgr.getPetData(petData.resId)
			if _baseInfo.fateType == nil then
				return
			end
			local data = {}
			data.name = ""
			data.describe = _baseInfo.fateDesc
			for i = 1, #_baseInfo.fateType do
				data["nature" .. i] = _baseInfo.fateType[i]
				if petData.cls > 0 then
					data["value" .. i] = _baseInfo.fateBase + _baseInfo.fateAdd[petData.cls]
				else
					data["value" .. i] = _baseInfo.fateBase
				end
			end
			table.insert(t, data)
			local item = JBItem.new(t, petData.fateState)
			item:setPosition(self._rootnode.contentView:getContentSize().width / 2, -height + 40)
			self._rootnode.contentViewNode:addChild(item)
			height = height + item:getContentSize().height + 2
		end
		local function addJJItem(str)
			local item = JJItem.new(str)
			item:setPosition(self._rootnode.contentView:getContentSize().width / 2, -height + 40)
			self._rootnode.contentViewNode:addChild(item)
			height = height + item:getContentSize().height + 2
		end
		local function resizeContent()
			local sz = cc.size(self._rootnode.contentView:getContentSize().width, self._rootnode.contentView:getContentSize().height + height - 40)
			self._rootnode.descView:setContentSize(sz)
			self._rootnode.contentView:setPosition(cc.p(sz.width / 2, sz.height))
			self._rootnode.scrollView:updateInset()
			self._rootnode.scrollView:setContentOffset(cc.p(0, -sz.height + self._rootnode.scrollView:getViewSize().height), false)
		end
		addJNItem()
		addJBItem()
		addJJItem(_baseInfo.attribute)
		resizeContent()
	end
	
	local function change()
		self:removeSelf()
		if _changeHeroListener then
			_changeHeroListener()
		end
	end
	
	local getIndexById = function(id)
		for k, v in ipairs(game.player:getSkills()) do
			if v._id == id then
				return k
			end
		end
	end
	
	local function close()
		local remove;
		PostNotice(NoticeKey.REMOVE_TUTOLAYER)
		if _refreshHeroListener then
			_refreshHeroListener(self._detailInfo)
		end
		if self.removeListener ~= nil then
			remove = self.removeListener(self.needUpdate)
		end
		if not remove then
			self:removeSelf()
		end
	end
	
	local function qiangHua()
		self._rootnode.qiangHuBtn:setEnabled(false)
		PostNotice(NoticeKey.REMOVE_TUTOLAYER)
		if infoType == 2 then
			self.createQiangHuaLayer(self.objID, self.cellIndex, function()
				self._rootnode.qiangHuBtn:setEnabled(true)
				self:requestHeroInfo()
			end)
		elseif infoType == 1 then
			local petList = PetModel.getPetTable()
			local petIndex
			for key, petData in pairs(petList) do
				if petData._id == _info._id then
					petIndex = key
					break
				end
			end
			local petQHLayer = require("game.Pet.PetQiangHuaLayer").new({
			index = petIndex,
			id = self.objID,
			listData = petList,
			removeListener = function(isQH)
				self._rootnode.qiangHuBtn:setEnabled(true)
				if isQH ~= false then
					self.needUpdate = true
					self:requestHeroInfo()
				end
				if self._broadcastBg ~= nil then
					game.broadcast:reSet(self._broadcastBg)
				end
			end,
			resetList = function()
			end
			})
			self:addChild(petQHLayer, 102)
		end
	end
	
	local function jinJie()
		self._rootnode.jinJieBtn:setEnabled(false)
		PostNotice(NoticeKey.REMOVE_TUTOLAYER)
		if infoType == 1 then
			local bHasOpen, prompt = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.XiaKe_JinJie, game.player:getLevel(), game.player:getVip())
			if not bHasOpen then
				show_tip_label(prompt)
			else
				local petList = PetModel.getPetTable()
				local petIndex
				for key, petData in pairs(petList) do
					if petData._id == _info._id then
						petIndex = key
						break
					end
				end
				local jinJieLayer = require("game.Pet.PetJinJie").new({
				incomeType = 2,
				listInfo = {
				id = _info._id,
				listData = petList,
				cellIndex = petIndex
				},
				removeListener = function(isJinJie)
					self._rootnode.jinJieBtn:setEnabled(true)
					if isJinJie then
						self.needUpdate = true
						self:requestHeroInfo()
					end
				end
				})
				self:addChild(jinJieLayer, 102)
			end
		elseif infoType == 2 then
			local bHasOpen, prompt = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.XiaKe_JinJie, game.player:getLevel(), game.player:getVip())
			if not bHasOpen then
				show_tip_label(prompt)
			else
				self.createJinjieLayer(self.objID, self.cellIndex, function()
					self._rootnode.jinJieBtn:setEnabled(true)
					self:requestHeroInfo()
				end)
			end
		elseif infoType == 3 then
			close()
		end
	end
	resetbtn(self._rootnode.closeBtn, bgNode, 1)
	self._rootnode.closeBtn:setVisible(true)
	self._rootnode.closeBtn:addHandleOfControlEvent(close, CCControlEventTouchUpInside)
	self._rootnode.changeBtn:addHandleOfControlEvent(change, CCControlEventTouchUpInside)
	self._rootnode.qiangHuBtn:setEnabled(false)
	self._rootnode.qiangHuBtn:addHandleOfControlEvent(qiangHua, CCControlEventTouchUpInside)
	self._rootnode.jinJieBtn:setEnabled(false)
	self._rootnode.jinJieBtn:addHandleOfControlEvent(jinJie, CCControlEventTouchUpInside)
	
	TutoMgr.addBtn("hero_info_qianghua_btn", self._rootnode.qiangHuBtn)
	self._info = _info
	if infoType == 3 then
		self:refresh()
	else
		self:requestHeroInfo()
	end
	local touchMaskLayer = require("utility.TouchMaskLayer").new({
	btns = {
	self._rootnode.jinJieBtn,
	self._rootnode.qiangHuBtn,
	self._rootnode.changeBtn,
	self._rootnode.closeBtn
	},
	contents = {
	cc.rect(0, 81, self._rootnode.descView:getContentSize().width, self._rootnode.descView:getContentSize().height)
	}
	})
	self:addChild(touchMaskLayer, 100)
end

function PetInfoLayer:requestHeroInfo(listener)
	local petData = PetModel.getPetByObjId(self.objID)
	local _baseInfo = ResMgr.getPetData(petData.resId)
	self._detailInfo = petData
	self._detailInfo.levelLimit = math.min(_baseInfo.maxLevel, game.player.m_level)
	self._detailInfo.star = _baseInfo.star
	self:refresh()
	local addBtn, label
	if self.getUpgradeBtn1 then
		addBtn = self:getUpgradeBtn1()
	end
	if self.getNumLabel then
		label = self:getNumLabel()
	end
	if self.infoType == 2 then
		if self._detailInfo.lock == 0 then
			self._rootnode.lock_btn:setVisible(true)
			self._rootnode.unlock_btn:setVisible(false)
		else
			self._rootnode.lock_btn:setVisible(false)
			self._rootnode.unlock_btn:setVisible(true)
		end
		if self._detailInfo.resId == 1 or self._detailInfo.resId == 2 then
			self._rootnode.lock_node:setVisible(false)
		else
			self._rootnode.lock_node:setVisible(true)
		end
	end
	
	local closeBtn = self._rootnode.closeBtn
	TutoMgr.addBtn("heroinfo_shentong_num", label)
	TutoMgr.addBtn("heroinfo_shentong_plus", addBtn)
	TutoMgr.addBtn("heroinfo_close_btn", closeBtn)
	TutoMgr.active()
	self._rootnode.jinJieBtn:setEnabled(true)
	self._rootnode.qiangHuBtn:setEnabled(true)
end

function PetInfoLayer:onExit()
	TutoMgr.removeBtn("hero_info_qianghua_btn")
	TutoMgr.removeBtn("heroinfo_shentong_num")
	TutoMgr.removeBtn("heroinfo_shentong_plus")
	TutoMgr.removeBtn("heroinfo_close_btn")
end

return PetInfoLayer