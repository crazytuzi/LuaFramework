local data_item_nature = require("data.data_item_nature")
local data_refine_refine = require("data.data_refine_refine")
local data_jiban_jiban = require("data.data_jiban_jiban")
local data_shangxiansheding_shangxiansheding = require("data.data_shangxiansheding_shangxiansheding")
local data_item_item = require("data.data_item_item")
local RequestInfo = require("network.RequestInfo")

local BaseSkillInfoLayer = class("BaseSkillInfoLayer", function()
	return require("utility.ShadeLayer").new(cc.c4b(0, 0, 0, 155))
end)

local Item = class("Item", function(heroid, data)
	local proxy = CCBProxy:create()
	local rootnode = {}
	local node = CCBuilderReaderLoad("skill/skill_jiban.ccbi", proxy, rootnode)
	rootnode.skillName:setString(data.name)
	local color, cls
	if heroid == 1 or heroid == 2 then
		heroid = game.player.m_gender
		color = NAME_COLOR[game.player:getStar()]
		--进阶等级
		cls = game.player:getClass()
	end
	local cardData = ResMgr.getCardData(heroid)
	color = color or NAME_COLOR[cardData.star[1]]
	if cardData then
		local name = cardData.name
		if heroid == 1 or heroid == 2 then
			name = game.player:getPlayerName()
		end
		local nameLabel = ui.newTTFLabelWithShadow({
		text = name,
		font = FONTS_NAME.font_fzcy,
		size = 20,
		color = color,
		shadowColor = display.COLOR_BLACK,
		align = ui.TEXT_ALIGN_CENTER,
		})
		ResMgr.replaceKeyLable(nameLabel, rootnode.heroName, 0, 0)
		nameLabel:align(display.CENTER)
	else
		rootnode.heroName:setString(common:getLanguageString("@NoCardID") .. tostring(heroid))
	end
	
	ResMgr.refreshIcon({
	itemBg = rootnode.headIcon,
	id = heroid,
	resType = ResMgr.HERO,
	cls = cls
	})
	local bFlag = 0
	for i = 1, 3 do
		if data[string.format("nature%d", i)] ~= 0 then
			local nature = data_item_nature[data[string.format("nature%d", i)]]
			if nature.id == 33 or nature.id == 34 then
				bFlag = bFlag + 1
			end
		end
	end
	local bSkip = false
	local tmpStr = ""
	for i = 1, 3 do
		if data[string.format("nature%d", i)] ~= 0 then
			local nature = data_item_nature[data[string.format("nature%d", i)]]
			local val = ""
			if nature.type == 1 then
				val = tostring(data[string.format("value%d", i)])
			else
				val = tostring(data[string.format("value%d", i)] / 100) .. "%"
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
	rootnode.jibanDes:setString(string.format("%s%s", data.describe, tmpStr))
	return node
end)

function BaseSkillInfoLayer:ctor(param)
	local _info = param.info
	local _subIndex = param.subIndex
	local _index = param.index
	local _listener = param.listener
	local _bEnemy = param.bEnemy
	local _closeListener = param.closeListener
	local _baseInfo = data_item_item[_info.resId]
	local refineInfo = data_refine_refine[_info.resId]
	dump(_info)
	self._proxy = CCBProxy:create()
	self._rootnode = {}
	local winSize, nodePos, bScroll
	if refineInfo and refineInfo.arr_jiban then
		winSize = CCSizeMake(display.width, display.height - 30)
		nodePos = ccp(display.width / 2, 0)
		bScroll = true
	else
		if _bEnemy then
			winSize = cc.size(display.width, 700)
		else
			winSize = cc.size(display.width, 760)
		end
		nodePos = cc.p(display.cx, display.cy - winSize.height / 2)
		bScroll = false
	end
	local bgNode = CCBuilderReaderLoad("skill/skill_info.ccbi", self._proxy, self._rootnode, self, winSize)
	self:addChild(bgNode, 1)
	bgNode:setPosition(nodePos)
	local infoNode
	if _bEnemy then
		infoNode = CCBuilderReaderLoad("skill/skill_detail.ccbi", self._proxy, self._rootnode, self, CCSizeMake(winSize.width, winSize.height - 2 - 20 - 68))
		infoNode:setPosition(cc.p(0, 20))
		bgNode:addChild(infoNode)
		self._rootnode.bottomMenuNode:setVisible(false)
	else
		infoNode = CCBuilderReaderLoad("skill/skill_detail.ccbi", self._proxy, self._rootnode, self, CCSizeMake(winSize.width, winSize.height - 2 - 85 - 68))
		infoNode:setPosition(cc.p(0, 85))
		bgNode:addChild(infoNode)
	end
	
	self._rootnode.scrollView:setTouchEnabled(bScroll)
	self._rootnode.titleLabel:setString(common:getLanguageString("@KungfuInfo"))
	self._rootnode.closeBtn:setVisible(true)
	
	--关闭按键
	self._rootnode.closeBtn:addHandleOfControlEvent(function()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		if _closeListener then
			_closeListener()
		end
		self:removeSelf()
	end,
	CCControlEventTouchUpInside)
	
	local heroName = ui.newTTFLabelWithShadow({
	text = _baseInfo.name,
	font = FONTS_NAME.font_haibao,
	size = 30,
	align = ui.TEXT_ALIGN_CENTER,
	color = NAME_COLOR[_info.star],
	shadowColor = display.COLOR_BLACK,
	})
	ResMgr.replaceKeyLable(heroName, self._rootnode.itemNameLabel, 0, 0)
	heroName:align(display.CENTER)
	
	local jlLabel = ui.newTTFLabelWithShadow({
	text = "",
	font = FONTS_NAME.font_haibao,
	size = 30,
	align = ui.TEXT_ALIGN_CENTER,
	color = FONT_COLOR.GREEN_1,
	shadowColor = display.COLOR_BLACK,
	})
	
	ResMgr.replaceKeyLable(jlLabel, self._rootnode.itemNameLabel, heroName:getContentSize().width / 2, 0)
	jlLabel:align(display.LEFT_CENTER)
	
	self._rootnode.itemNameLabel:removeSelf()
	
	self._rootnode.descLabel:setString(_baseInfo.describe)
	self._rootnode.cardName:setString(_baseInfo.name)
	local function change()
		self._rootnode.changeBtn:setEnabled(false)
		push_scene(require("game.form.SkillChooseScene").new({
		index = _index,
		subIndex = _subIndex,
		cid = _info.cid,
		callback = function(data)
			if data then
				_listener(data)
			end
			self:removeSelf()
		end
		}))
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
	end
	local getIndexById = function(id)
		for k, v in ipairs(game.player:getSkills()) do
			if v._id == id then
				return k
			end
		end
	end
	local function takeOff()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		RequestHelper.formation.putOnEquip({
		pos = _index,
		subpos = _subIndex,
		callback = function(data)
			if string.len(data["0"]) > 0 then
				CCMessageBox(data["0"], "Tip")
			else
				_info.pos = 0
				_info.cid = 0
				if _listener then
					_listener(data)
				end
				self:removeSelf()
			end
		end
		})
	end
	for i = 1, _info.star do
		self._rootnode[string.format("star%d", i)]:setVisible(true)
	end
	self._rootnode.cardImageBg:setDisplayFrame(display.newSpriteFrame(string.format("item_card_bg_%d.png", _info.star)))
	local path = ResMgr.getLargeImage(_baseInfo.bicon, ResMgr.EQUIP)
	self._rootnode.skillImage:setDisplayFrame(display.newSprite(path):getDisplayFrame())
	local function refresh()
		self._rootnode.curLvLabel:setString(_info.level)
		local index = 1
		for i = 1, 4 do
			local prop = _info.baseRate[i]
			local str = ""
			if prop > 0 then
				local nature = data_item_nature[BASE_PROP_MAPPPING[i]]
				if nature.type == 1 then
					str = string.format("+%d", prop)
				else
					str = string.format("+%.2f%%", prop / 100)
				end
				self._rootnode["basePropLabel_" .. tostring(index)]:setString(str)
				self._rootnode["stateName" .. tostring(index)]:setString(nature.nature .. tostring("："))
				index = index + 1
			end
		end
		if data_refine_refine[_info.resId] and data_refine_refine[_info.resId].Refine and 0 < data_refine_refine[_info.resId].Refine then
			local propCount = #refineInfo.arr_nature2
			local num = math.floor(_info.propsN / propCount) + 1
			local index = _info.propsN % propCount
			if index == 0 and 0 < _info.propsN then
				index = propCount
				num = num - 1
			end
			for k, v in ipairs(refineInfo.arr_nature2) do
				local nature = data_item_nature[v]
				local value = refineInfo.arr_value2[k]
				self._rootnode["nbPropLabel_" .. tostring(k)]:setString(nature.nature .. "：")
				if nature.type == 2 then
					if k <= index then
						local val = num * value * 0.01
						if val == math.ceil(val) then
							self._rootnode[string.format("nbPropValueLabel_%d", k)]:setString(string.format("+%d%%", val))
						else
							self._rootnode[string.format("nbPropValueLabel_%d", k)]:setString(string.format("+%.1f%%", val))
						end
					elseif num == 1 then
						self._rootnode[string.format("nbPropValueLabel_%d", k)]:setString("0")
					else
						local val = (num - 1) * value * 0.01
						if val == math.ceil(val) then
							self._rootnode[string.format("nbPropValueLabel_%d", k)]:setString(string.format("+%d%%", val))
						else
							self._rootnode[string.format("nbPropValueLabel_%d", k)]:setString(string.format("+%.1f%%", (num - 1) * value * 0.01))
						end
					end
				elseif k <= index then
					self._rootnode[string.format("nbPropValueLabel_%d", k)]:setString(string.format("+%d", num * value))
				elseif num == 1 then
					self._rootnode[string.format("nbPropValueLabel_%d", k)]:setString("0")
				else
					self._rootnode[string.format("nbPropValueLabel_%d", k)]:setString(string.format("+%d", (num - 1) * value))
				end
			end
			if num >= 1 and index == propCount then
				jlLabel:setString(string.format("+%d", num))
				jlLabel:setPositionX(heroName:getPositionX() + heroName:getContentSize().width / 2)
			elseif num > 1 then
				jlLabel:setString(string.format("+%d", num - 1))
				jlLabel:setPositionX(heroName:getPositionX() + heroName:getContentSize().width / 2)
			end
		end
	end
	if refineInfo and refineInfo.arr_nature1 then
		for k, v in ipairs(refineInfo.arr_nature1) do
			local nature = data_item_nature[v]
			local str = nature.nature
			if nature.type == 1 then
				str = str .. "：+" .. tostring(refineInfo.arr_value1[k])
			else
				str = str .. string.format("：+%d%%", refineInfo.arr_value1[k] / 100)
			end
			if refineInfo.arr_level[k] <= data_shangxiansheding_shangxiansheding[8].level then
				local proName = string.format("lockPropLabel_%d", k)
				if _info.level >= refineInfo.arr_level[k] then
					self._rootnode[proName]:setColor(ccc3(147, 5, 0))
				else
					str = str .. "(" .. refineInfo.arr_level[k] .. common:getLanguageString("@jiesuo")
				end
				self._rootnode[proName]:setString(str)
				self._rootnode[proName]:setVisible(true)
			end
		end
	else
		self._rootnode.lockPropLabel_1:setVisible(true)
	end
	local height = self._rootnode.jiBanNode:getContentSize().height + 50
	if refineInfo and refineInfo.arr_jiban ~= nil then
		for k, v in ipairs(refineInfo.arr_jiban) do
			if refineInfo.arr_card[k] then
				local item = Item.new(refineInfo.arr_card[k], data_jiban_jiban[v])
				height = height + item:getContentSize().height
				item:setPosition(self._rootnode.contentView:getContentSize().width / 2, -(k - 1) * item:getContentSize().height - self._rootnode.jiBanNode:getContentSize().height - 30)
				self._rootnode.contentView:addChild(item, 1)
			else
				__G__TRACKBACK__(string.format("please check arr_jiban and arr_card: sikllid = %d", _info.resId))
			end
		end
		local jbNode = CCBuilderReaderLoad("skill/skill_jiban_bg.ccbi", self._proxy, self._rootnode, self, CCSizeMake(winSize.width, height - self._rootnode.jiBanNode:getContentSize().height + 10))
		jbNode:setPosition(cc.p(display.width / 2, -self._rootnode.jiBanNode:getContentSize().height + 15))
		self._rootnode.contentView:addChild(jbNode, 0)
	else
		self._rootnode.jiBanNode:setVisible(false)
	end
	local sz = cc.size(self._rootnode.contentView:getContentSize().width, self._rootnode.contentView:getContentSize().height + height)
	self._rootnode.descView:setContentSize(sz)
	self._rootnode.contentView:setPosition(cc.p(sz.width / 2, sz.height))
	self._rootnode.scrollView:updateInset()
	self._rootnode.scrollView:setContentOffset(cc.p(0, -sz.height + self._rootnode.scrollView:getViewSize().height), false)
	refresh()
	if _subIndex and _index then
		self._rootnode.changeBtn:addHandleOfControlEvent(change, CCControlEventTouchUpInside)
		self._rootnode.takeOffBtn:addHandleOfControlEvent(takeOff, CCControlEventTouchUpInside)
	else
		self._rootnode.changeBtn:setVisible(false)
		self._rootnode.takeOffBtn:setVisible(false)
	end
	local function refine()
		local bHasOpen, prompt = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.NeiWaiGong_JingLian, game.player:getLevel(), game.player:getVip())
		if not bHasOpen then
			show_tip_label(prompt)
			return
		end
		self:setVisible(false)
		local req = RequestInfo.new({
		modulename = "skill",
		funcname = "refine",
		param = {
		op = 1,
		id = _info._id
		},
		oklistener = function(data)
			if data.allow == 1 then
				local baseInfo = {
				_id = _info._id,
				resId = _info.resId
				}
				local layer = require("game.skill.SkillRefineLayer").new({
				refineInfo = data,
				baseInfo = baseInfo,
				callback = function(bRequest, propN)
					if bRequest then
						_info.propsN = propN
					end
					refresh()
					if _listener then
						_listener()
					end
					self:removeSelf()
				end
				})
				game.runningScene:addChild(layer, 100)
			else
				show_tip_label(common:getLanguageString("@KungfuNotRefine"))
			end
		end
		})
		RequestHelperV2.request(req)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
	end
	local function qiangHu()
		if _info.level >= data_shangxiansheding_shangxiansheding[4].level then
			show_tip_label(common:getLanguageString("@KungfuMax"))
			return
		end
		local req = RequestInfo.new({
		modulename = "skill",
		funcname = "qianghua",
		param = {
		op = 1,
		cids = _info._id
		},
		oklistener = function(data)
			self:setVisible(false)
			data["1"]._id = _info._id
			local layer = require("game.skill.SkillQiangHuaLayer").new({
			info = data["1"],
			callback = function()
				_info.baseRate = data["1"].baseRate
				_info.level = data["1"].lv
				refresh()
				if _listener then
					_listener()
				end
				self:removeSelf()
			end
			})
			game.runningScene:addChild(layer, 10)
			game.player:setSilver(data["2"])
		end
		})
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		RequestHelperV2.request(req)
	end
	
	if data_refine_refine[_info.resId] and data_refine_refine[_info.resId].Refine and 0 < data_refine_refine[_info.resId].Refine then
		self._rootnode.xiLianBtn:setVisible(true)
	else
		self._rootnode.xiLianBtn:setVisible(false)
	end
	if _baseInfo.pos >= 101 and _baseInfo.pos <= 104 then
		self._rootnode.qiangHuBtn:setVisible(false)
	end
	
	self._rootnode.qiangHuBtn:addHandleOfControlEvent(qiangHu, CCControlEventTouchUpInside)
	self._rootnode.xiLianBtn:addHandleOfControlEvent(refine, CCControlEventTouchUpInside)
end

return BaseSkillInfoLayer