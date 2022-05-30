require("game.Biwu.BiwuFuc")
local RequestInfo = require("network.RequestInfo")

local data_item_item = require("data.data_item_item")

local QhMainPopup = class("QhMainPopup", function()
	return require("utility.ShadeLayer").new()
end)

function QhMainPopup:ctor(param)
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("lianhualu/qianghuadashi.ccbi", proxy, self._rootnode)
	node:setPosition(display.cx, display.cy)
	self:addChild(node)
	self._callBack = param.callBack
	self._index = param._index
	self._objId = param._objId
	self:setUpView()
end

function QhMainPopup:checkQHLevelUp()
	local keys = {
	"que_stage",
	"str_level",
	"ref_level"
	}
	local level = self._levelGroups[self._pageIndex] + 1
	local baseData = require("data.data_equipmaster_equipmaster")[level]
	local baseNum = baseData[keys[self._pageIndex]]
	for k, v in pairs(self._gongList) do
		if baseNum > v.level then
			return false
		end
	end
	self._qianghuaLevel = self._qianghuaLevel + 1
	self._levelGroups[self._pageIndex] = self._levelGroups[self._pageIndex] + 1
	return true
end

function QhMainPopup:checkJLLevelUp()
	local keys = {
	"que_stage",
	"str_level",
	"ref_level"
	}
	local level = self._levelGroups[self._pageIndex] + 1
	local baseData = require("data.data_equipmaster_equipmaster")[level]
	local baseNum = baseData[keys[self._pageIndex]]
	for k, v in pairs(self._gongList) do
		if baseNum > v.refLevel then
			return false
		end
	end
	self._jinglianLevel = self._jinglianLevel + 1
	self._levelGroups[self._pageIndex] = self._levelGroups[self._pageIndex] + 1
	return true
end

function QhMainPopup:setUpView()
	
	self._rootnode.closeBtn:addHandleOfControlEvent(function(eventName, sender)
		if self._callBack then
			self._callBack()
		end
		self:removeSelf()
	end,
	CCControlEventTouchUpInside)
	
	self._rootnode.closeBtn_bottom:addHandleOfControlEvent(function(eventName, sender)
		if self._callBack then
			self._callBack()
		end
		self:removeSelf()
	end,
	CCControlEventTouchUpInside)
	
	for index = 1, 4 do
		local icon = self._rootnode["reward_icon_" .. index]
		local size = icon:getContentSize()
		local btn = require("utility.MyLayer").new({
		size = size,
		swallow = true,
		parent = icon:getParent(),
		touchHandler = function (event)
			local data
			if self._pageIndex == 1 then
				data = self._equipList[index]
			else
				data = self._gongList[index]
			end
			if data == nil then
				return
			end
			
			if event.name == "began" then
				GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
				if self._pageIndex == 1 then
					GameStateManager:ChangeState(GAME_STATE.STATE_CULIAN_MAIN, {
					_index = self._index,
					_objId = self._objId,					
					_pos = data_item_item[self._equipList[index].resId].pos,				
				})
				elseif self._pageIndex == 2 then
					local req = RequestInfo.new({
					modulename = "skill",
					funcname = "qianghua",
					param = {
					op = 1,
					cids = self._gongList[index].id
					},
					oklistener = function(data)
						data["1"]._id = self._gongList[index].id
						local layer = require("game.skill.SkillQiangHuaLayer").new({
						info = data["1"],
						callback = function(newLevel)
							if newLevel then
								self._gongList[index].level = newLevel
								self:checkQHLevelUp()
								self:pageSelect(self._pageIndex)
							end
						end
						})
						game.runningScene:addChild(layer, 1000)
						game.player:setSilver(data["2"])
					end
					})
					RequestHelperV2.request(req)
				elseif self._pageIndex == 3 then
					local req = RequestInfo.new({
					modulename = "skill",
					funcname = "refine",
					param = {
					op = 1,
					id = self._gongList[index].id
					},
					oklistener = function(data)
						if data.allow == 1 then
							local baseInfo = {
							_id = self._gongList[index].id,
							resId = self._gongList[index].resId
							}
							local layer = require("game.skill.SkillRefineLayer").new({
							refineInfo = data,
							baseInfo = baseInfo,
							callback = function(bRequest, propN)
								if propN then
									self._gongList[index].refLevel = propN
									self:checkJLLevelUp()
									self:pageSelect(self._pageIndex)
								end
							end
							})
							game.runningScene:addChild(layer, 101)
						else
							show_tip_label(common:getLanguageString("@KungfuNotRefine"))
						end
					end
					})
					RequestHelperV2.request(req)
				end
			end
		end
		})
		btn:setPosition(-65, -20)
	end
	
	--武学强化/武学精炼/装备淬炼
	for index = 1, 3 do
		local item = self._rootnode["tab" .. index]
		item:setZOrder(3 - index)
		item:registerScriptTapHandler(function(tag)
			if index == 1 then
				local bHasOpen, prompt = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.ZHUANGBEICULIAN, game.player:getLevel(), game.player:getVip())
				if not bHasOpen then
					show_tip_label(prompt)
					canShow = false
					return
				elseif #self._equipList < 4 then
					show_tip_label(data_error_error[3600007].prompt)
					return
				end
			elseif index == 2 then
				if 2 > #self._gongList then
					show_tip_label(data_error_error[3600006].prompt)
					return
				end
			elseif index == 3 and 2 > #self._gongList then
				show_tip_label(data_error_error[3600006].prompt)
				return
			end
			self:pageSelect(index)
		end)
	end
	
	local function func()
		self:pageSelect(2)
		if self._pageIndex > 1 then
			self:refreshItems(self._gongList)
		else
			self:refreshItems(self._equipList)
		end
		self:refreshView()
	end
	self:getBaseData(func)
	
end

function QhMainPopup:pageSelect(index)
	for index = 1, 3 do
		self._rootnode["tab" .. index]:unselected()
	end
	self._rootnode["tab" .. index]:selected()
	self._pageIndex = index
	if 1 < self._pageIndex then
		self:refreshItems(self._gongList)
	else
		self:refreshItems(self._equipList)
	end
	self:refreshView()
end

function QhMainPopup:refreshItems(list)
	for index = 1, 4 do
		self._rootnode["view_0" .. index]:setVisible(false)
	end
	for k, v in pairs(list) do
		self._rootnode["view_0" .. k]:setVisible(true)
		self:showIcon(self._rootnode["reward_icon_" .. k], v)
	end
end

function QhMainPopup:getEquipByID(id)
	for k, v in ipairs(game.player:getEquipments()) do
		if v._id == id then
			return v
		end
	end
	return nil
end

function QhMainPopup:refreshView()
	local attrBaseData = require("data.data_item_nature")
	local baseData = require("data.data_equipmaster_equipmaster")
	local keys = {
	"arr_que",
	"arr_str",
	"arr_ref"
	}
	local keysSub = {
	"que_stage",
	"str_level",
	"ref_level"
	}
	local level
	if self._pageIndex == 1 then
		self._rootnode.title_title:setString(common:getLanguageString("@cuiliands1", self._culianLevel))
		self._rootnode.value_value:setString(common:getLanguageString("@cuiliands1", self._culianLevel + 1))
		if baseData[self._culianLevel + 1][keysSub[self._pageIndex]] then
			self._rootnode.value_title_sub:setString(common:getLanguageString("@quanshencl", baseData[self._culianLevel + 1].que_stage))
		else
			self._rootnode.value_title_sub:setVisible(false)
		end
		level = self._culianLevel
	elseif self._pageIndex == 2 then
		self._rootnode.title_title:setString(common:getLanguageString("@qianghuads1", self._qianghuaLevel))
		self._rootnode.value_value:setString(common:getLanguageString("@qianghuads1", self._qianghuaLevel + 1))
		if baseData[self._culianLevel + 1][keysSub[self._pageIndex]] then
			self._rootnode.value_title_sub:setString(common:getLanguageString("@quanshenqh", baseData[self._qianghuaLevel + 1].str_level))
		else
			self._rootnode.value_title_sub:setVisible(false)
		end
		level = self._qianghuaLevel
	else
		self._rootnode.title_title:setString(common:getLanguageString("@jingliands1", self._jinglianLevel))
		self._rootnode.value_value:setString(common:getLanguageString("@jingliands1", self._jinglianLevel + 1))
		if baseData[self._culianLevel + 1][keysSub[self._pageIndex]] then
			self._rootnode.value_title_sub:setString(common:getLanguageString("@quanshenjl1", baseData[self._jinglianLevel + 1].ref_level))
		else
			self._rootnode.value_title_sub:setVisible(false)
		end
		level = self._jinglianLevel
	end
	for index = 1, 4 do
		self._rootnode["title_" .. index]:setVisible(false)
		self._rootnode["value_" .. index]:setVisible(false)
	end
	self._rootnode.value_title_sub:setVisible(false)
	self._rootnode.value_value:setVisible(false)
	local function getMaxLenth(pageIndex)
		for i = 1, #baseData do
			if not baseData[i][keys[self._pageIndex] .. "_nature"] then
				dump(i - 1)
				return i - 1
			end
		end
		return #baseData
	end
	if level == 0 then
		for index = 1, 4 do
			self._rootnode["title_" .. index]:setVisible(false)
		end
		level = level + 1
		for index = 1, #baseData[level][keys[self._pageIndex] .. "_nature"] do
			self._rootnode["value_" .. index]:setVisible(true)
			self._rootnode.value_title_sub:setVisible(true)
			self._rootnode.value_value:setVisible(true)
			local id = baseData[level][keys[self._pageIndex] .. "_nature"][index]
			local attrType = attrBaseData[id].type
			local attrName = attrBaseData[id].nature
			local sttrValue = baseData[level][keys[self._pageIndex] .. "_value"][index]
			if type == 1 then
				self._rootnode["value_" .. index]:setString(attrName .. "+" .. sttrValue)
			else
				self._rootnode["value_" .. index]:setString(attrName .. "+" .. math.ceil(sttrValue / 100) .. "%")
			end
		end
	elseif level == getMaxLenth(self._pageIndex) then
		for index = 1, 4 do
			self._rootnode["value_" .. index]:setVisible(false)
			self._rootnode.value_title_sub:setVisible(false)
			self._rootnode.value_value:setVisible(false)
		end
		for index = 1, #baseData[level][keys[self._pageIndex] .. "_nature"] do
			self._rootnode["title_" .. index]:setVisible(true)
			local id = baseData[level][keys[self._pageIndex] .. "_nature"][index]
			local attrType = attrBaseData[id].type
			local attrName = attrBaseData[id].nature
			local sttrValue = baseData[level][keys[self._pageIndex] .. "_value"][index]
			if type == 1 then
				self._rootnode["title_" .. index]:setString(attrName .. "+" .. sttrValue)
			else
				self._rootnode["title_" .. index]:setString(attrName .. "+" .. math.ceil(sttrValue / 100) .. "%")
			end
		end
		local disStr = {
		common:getLanguageString("@cuiliandsmj"),
		common:getLanguageString("@qianghuadsmj"),
		common:getLanguageString("@jingliandsmj")
		}
		self._rootnode["value_" .. 2]:setString(disStr[self._pageIndex])
		self._rootnode["value_" .. 2]:setVisible(true)
	elseif level > 0 and level < getMaxLenth(self._pageIndex) then
		self._rootnode.value_title_sub:setVisible(true)
		self._rootnode.value_value:setVisible(true)
		for index = 1, #baseData[level][keys[self._pageIndex] .. "_nature"] do
			self._rootnode["title_" .. index]:setVisible(true)
			local id = baseData[level][keys[self._pageIndex] .. "_nature"][index]
			local attrType = attrBaseData[id].type
			local attrName = attrBaseData[id].nature
			local sttrValue = baseData[level][keys[self._pageIndex] .. "_value"][index]
			if type == 1 then
				self._rootnode["title_" .. index]:setString(attrName .. "+" .. sttrValue)
			else
				self._rootnode["title_" .. index]:setString(attrName .. "+" .. math.ceil(sttrValue / 100) .. "%")
			end
		end
		level = level + 1
		for index = 1, #baseData[level][keys[self._pageIndex] .. "_nature"] do
			self._rootnode["value_" .. index]:setVisible(true)
			local id = baseData[level][keys[self._pageIndex] .. "_nature"][index]
			local attrType = attrBaseData[id].type
			local attrName = attrBaseData[id].nature
			local sttrValue = baseData[level][keys[self._pageIndex] .. "_value"][index]
			if type == 1 then
				self._rootnode["value_" .. index]:setString(attrName .. "+" .. sttrValue)
			else
				self._rootnode["value_" .. index]:setString(attrName .. "+" .. math.ceil(sttrValue / 100) .. "%")
			end
		end
	else
		show_tip_label(common:getLanguageString("@chongzhisj"))
	end
	local disKeys = {
	common:getLanguageString("@dianjiqucl"),
	common:getLanguageString("@dianjiquqh"),
	common:getLanguageString("@dianjiqujl")
	}
	self._rootnode.bottom_dis_label:setString(disKeys[self._pageIndex])
end

function QhMainPopup:showIcon(node, itemData)
	node:removeAllChildren()
	local icon = ResMgr.refreshIcon({
	id = itemData.resId,
	resType = ResMgr.EQUIP,
	itemBg = node,
	iconNum = 1,
	isShowIconNum = false,
	numLblSize = 22,
	numLblColor = cc.c3b(0, 255, 0),
	numLblOutColor = cc.c3b(0, 0, 0)
	})
	local nameColor = ResMgr.getItemNameColor(itemData.resId)
	local nameLbl = ui.newTTFLabelWithShadow({
	text = require("data.data_item_item")[itemData.resId].name,
	size = 20,
	color = nameColor,
	shadowColor = display.COLOR_BLACK,
	font = FONTS_NAME.font_fzcy,
	align = ui.TEXT_ALIGN_LEFT
	})
	
	nameLbl:align(display.LEFT_CENTER, 120, 65)
	node:addChild(nameLbl)
	
	local keys = {
	"que_stage",
	"str_level",
	"ref_level"
	}
	local level = self._levelGroups[self._pageIndex] + 1
	local baseData = require("data.data_equipmaster_equipmaster")[level]
	local baseNum = baseData[keys[self._pageIndex]]
	local progress = display.newSprite("#qianghua_null.png")
	local fill = display.newProgressTimer("#qianghua_full.png", display.PROGRESS_TIMER_BAR)
	fill:setMidpoint(cc.p(0, 0.5))
	fill:setBarChangeRate(cc.p(1, 0))
	fill:setPosition(progress:getContentSize().width * 0.5, progress:getContentSize().height * 0.5)
	progress:addChild(fill)
	progress:setPosition(180, 35)
	progress:setAnchorPoint(cc.p(0.5, 1))
	node:addChild(progress)
	local proNum
	if self._pageIndex == 1 then
		proNum = itemData.cls
	elseif self._pageIndex == 2 then
		proNum = itemData.level
	else
		proNum = itemData.refLevel
	end
	fill:setPercentage(proNum / baseNum * 100)
	local progressNum = ui.newTTFLabelWithOutline({
	text = proNum .. "/" .. baseNum,
	size = 18,
	color = FONT_COLOR.WHITE,
	align = ui.TEXT_ALIGN_CENTE,
	outlineColor = cc.c3b(0, 0, 0),
	font = FONTS_NAME.font_fzcy
	})
	progressNum:setPosition(progress:getContentSize().width * 0.5 - progressNum:getContentSize().width * 0.5, progress:getContentSize().height * 0.5)
	progressNum:setAnchorPoint(cc.p(0.5, 0.5))
	progress:addChild(progressNum)
	
end

function QhMainPopup:getBaseData(func)
	local function initData(data)
		table.sort(data.equipList, function(a, b)
			return a.pos < b.pos
		end)
		self._equipList = data.equipList
		self._gongList = {
		data.gongList[2],
		data.gongList[1]
		}
		self._culianLevel = data.quenchLevel
		self._qianghuaLevel = data.gongLVLevel
		self._jinglianLevel = data.gongPropLevel
		self._levelGroups = {
		self._culianLevel,
		self._qianghuaLevel,
		self._jinglianLevel
		}
		func()
	end
	
	RequestHelper.qianghuaDashi.getBaseData({
	callback = function(data)
		dump(data)
		initData(data)
	end,
	acc = game.player:getAccount(),
	order = self._index
	})
end

return QhMainPopup