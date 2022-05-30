local data_mijicost_mijicost = require("data.data_mijicost_mijicost")
local data_mijiatt_mijiatt = require("data.data_mijiatt_mijiatt")
local data_miji_miji = require("data.data_miji_miji")
local data_item_nature = require("data.data_item_nature")

local CheatsJinJie = class("CheatsJinJie", function(param)
	return require("utility.ShadeLayer").new()
end)

local PRIVIEW_OP = 1
local JINJIE_OP = 2

function CheatsJinJie:sendRes(param)
	CheatsModel.getCheatsJinJieInfo({
	callback = function(data)
		self:init(data)
	end,
	errback = function()
		self._rootnode.jingLianBtn:setEnabled(true)
	end,
	id = param.id,
	op = param.op
	})
end

function CheatsJinJie:init(data)
	local removeList = data.removeIds
	self:removeCheats(removeList)
	self.haveXiuwei = data.xiuwei
	self._rootnode.xiuweiBMF:setString(self.haveXiuwei)
	self.costXiuwei = data.costXiuwei
	self._rootnode.cost_xiuwei:setString(self.costXiuwei)
	local itemData = data.cost
	self.notEnough = true
	
	--[[研习消耗物品]]
	self.costData = itemData
	local sourceData = {}
	for i = 1, 5 do
		local d = itemData[i]
		if d ~= nil then
			table.insert(sourceData, {
			id = d.id,
			t = d.t,
			n2 = d.n1,
			n1 = d.n2
			})
			if d.n2 > d.n1 then
				self.notEnough = false
			end
		end
	end
	
	local function createfuncCell(idx)
		local item = require("game.Hero.JinJieCell").new()
		return item:create({
		id = idx,
		listData = sourceData,
		viewSize = self._rootnode.scrow_node:getContentSize()
		})
	end
	local refreshFunc = function(cell, idx)
		cell:refresh(idx + 1)
	end
	self._rootnode.scrow_node:removeAllChildren()
	local itemList = require("utility.TableViewExt").new({
	size = self._rootnode.scrow_node:getContentSize(),
	createFunc = createfuncCell,
	refreshFunc = refreshFunc,
	cellNum = #sourceData,
	cellSize = require("game.Hero.JinJieCell").new():getContentSize()
	})
	self._rootnode.scrow_node:addChild(itemList)
	if #sourceData == 0 then
		self._rootnode.noCost:setVisible(true)
	else
		self._rootnode.noCost:setVisible(false)
	end
	
	if self._floor == data.floor then
		local cheatsData = CheatsModel.getCheatsByObjId(self.objId)
		if self.curOp == JINJIE_OP and cheatsData and cheatsData.data then
			local data = cheatsData.data
			local isup, mod = CheatsModel.isUpFloor(data.resId, data.level, data.floor)
			if isup == true then
				--突破
				resetctrbtnString(self._rootnode.jingLianBtn, common:getLanguageString("@CheatsTupo"))
			else
				--研习
				resetctrbtnString(self._rootnode.jingLianBtn, common:getLanguageString("@CheatsStudy"))
			end
			if mod ~= 1 then
				self:jinJieAnimation(data.level - 1, data.level)
			else
				self._rootnode.jingLianBtn:setEnabled(true)
				local locak = self._rootnode.DrawNodeTop:getChildByTag(data.level)
				if locak then
					locak:setDisplayFrame(display.newSprite("ui_common/ui_cheats_jinjie_unlock.png"):getDisplayFrame())
				end
				self:playYanxiAni(data.level)
			end
		end
	else
		local mijiyanxi_bg
		mijiyanxi_bg = ResMgr.createArma({
		resType = ResMgr.UI_EFFECT,
		armaName = "ui_mijiyanxi_bg",
		isRetain = true,
		finishFunc = function(...)
			mijiyanxi_bg:removeSelf()
			resetctrbtnString(self._rootnode.jingLianBtn, common:getLanguageString("@CheatsStudy"))
			self._rootnode.jingLianBtn:setEnabled(true)
			self:setBgNode({
			resId = self.resId,
			floor = data.floor,
			level = data.level
			})
		end
		})
		mijiyanxi_bg:setPosition(cc.p(self._rootnode.DrawNode:getContentSize().width / 2, self._rootnode.DrawNode:getContentSize().height / 2))
		self._rootnode.DrawNode:addChild(mijiyanxi_bg, -100)
		
	end
end

function CheatsJinJie:playYanxiAni(i)
	local data = CheatsModel.getCheatsPropsInfo(self.resId, i)
	local x = self._drawNodeSize.width / 2 + data.xy[1][1]
	local y = self._drawNodeSize.height / 2 + data.xy[1][2]
	local unlockAnim
	unlockAnim = ResMgr.createArma({
	resType = ResMgr.UI_EFFECT,
	armaName = "ui_mjiyanxi_jihuo",
	isRetain = true,
	finishFunc = function(...)
		unlockAnim:removeSelf()
	end
	})
	unlockAnim:setPosition(x + 2, y - 1)
	self._rootnode.DrawNodeTop:addChild(unlockAnim, 95)
end

function CheatsJinJie:removeCheats(removeIdList)
	if removeIdList ~= nil and #removeIdList > 0 then
		CheatsModel.removeList(removeIdList)
	end
end

function CheatsJinJie:onExit()
end

function CheatsJinJie:onEnter()
	TutoMgr.active()
	self._rootnode.jingLianBtn:setEnabled(true)
end

--[[秘籍进阶主界面]]
function CheatsJinJie:setBgNode(param)
	self._rootnode.DrawNodeTop:removeAllChildrenWithCleanup(true)
	self._drawNode:clear()
	local resId = param.resId
	local floor = param.floor
	self._floor = floor
	local level = param.level
	local from = 0
	local to = 0
	local isup, mod_lv = CheatsModel.isUpFloor(resId, level, floor)
	from = 1
	to = data_miji_miji[resId].number
	local tmpPos
	local start = to  * (floor - 1)
	for i = from, to do
		local data = CheatsModel.getCheatsPropsInfo(resId, i + start)
		if data and data.xy ~= nil then
			local x = self._drawNodeSize.width / 2 + data.xy[1][1]
			local y = self._drawNodeSize.height / 2 + data.xy[1][2]
			if i ~= from then
				self._drawNode:drawSegment(tmpPos, cc.p(x, y), 3, cc.c4f(0.403921568627451, 0.403921568627451, 0.403921568627451, 1))
				if i <= level then
					self._drawNode:drawSegment(tmpPos, cc.p(x, y), 3, cc.c4f(0.984313725490196, 0.9529411764705882, 0.6196078431372549, 1))
				end
			end
			tmpPos = cc.p(x, y)
			if 1 < #data.xy then
				for j = 2, #data.xy do
					local xx = self._drawNodeSize.width / 2 + data.xy[j][1]
					local yy = self._drawNodeSize.width / 2 + data.xy[j][2]
					self._drawNode:drawSegment(tmpPos, cc.p(xx, yy), 3, cc.c4f(0.403921568627451, 0.403921568627451, 0.403921568627451, 1))
					if i < level then
						self._drawNode:drawSegment(tmpPos, cc.p(xx, yy), 3, cc.c4f(0.984313725490196, 0.9529411764705882, 0.6196078431372549, 1))
					end
					tmpPos = cc.p(xx, yy)
				end
			end
			local value = "+" .. data.number
			if data_item_nature[data.type].type == 2 then
				value = string.format("+%.1f%%", data.number / 100)
			end
			
			local label = ui.newTTFLabel({
			text = data_item_nature[data.type].nature .. "\n" .. tostring(value),
			color = cc.c3b(255, 255, 255),
			font = FONTS_NAME.font_fzcy,
			size = 15,
			align = ui.TEXT_ALIGN_CENTER
			})
			label:setPosition(x, y - 5)
			label:setZOrder(93)
			self._rootnode.DrawNodeTop:addChild(label)
			local spriteName = "ui_common/ui_cheats_jinjie_lock.png"
			if i <= level then
				spriteName = "ui_common/ui_cheats_jinjie_unlock.png"
			end
			local lock = display.newSprite(spriteName)
			lock:setPosition(x, y)
			lock:setZOrder(90)
			lock:setTag(i)
			self._rootnode.DrawNodeTop:addChild(lock)
		else
			--数据异常
			show_tip_label(common:getLanguageString("@shujuyc"))
		end
	end
end

function CheatsJinJie:getAngleByPos(startPos, endPos)
	local x = endPos.x - startPos.x
	local y = endPos.y - startPos.y
	local angle = math.atan2(y, x)
	return 180 - angle * 180 / 3.14
end

function CheatsJinJie:jinJieAnimation(level_1, level_2)
	local goAnim
	goAnim = ResMgr.createArma({
	resType = ResMgr.UI_EFFECT,
	armaName = "ui_mijiyanxi_xian",
	isRetain = true
	})
	self._rootnode.DrawNodeTop:addChild(goAnim, 95)
	local data = CheatsModel.getCheatsPropsInfo(self.resId, level_1)
	local tablePos = {}
	if data and data.xy ~= nil then
		local x = self._drawNodeSize.width / 2 + data.xy[1][1]
		local y = self._drawNodeSize.height / 2 + data.xy[1][2]
		tmpPos = cc.p(x, y)
		if #data.xy > 1 then
			for j = 2, #data.xy do
				local xx = self._drawNodeSize.width / 2 + data.xy[j][1]
				local yy = self._drawNodeSize.width / 2 + data.xy[j][2]
				table.insert(tablePos, {
				tmpPos,
				cc.p(xx, yy)
				})
				tmpPos = cc.p(xx, yy)
			end
		end
		local data2 = CheatsModel.getCheatsPropsInfo(self.resId, level_2)
		local x2 = self._drawNodeSize.width / 2 + data2.xy[1][1]
		local y2 = self._drawNodeSize.height / 2 + data2.xy[1][2]
		table.insert(tablePos, {
		tmpPos,
		cc.p(x2, y2)
		})
	else
		show_tip_label(common:getLanguageString("@shujuyc"))
	end
	local index = 1
	local animation
	function animation()
		if tablePos and tablePos[index] then
			local a = tablePos[index][1]
			local b = tablePos[index][2]
			local x = b.x - a.x
			local y = b.y - a.y
			local angle = self:getAngleByPos(a, b)
			goAnim:setRotation(angle)
			local times = 1
			if math.abs(x) > math.abs(y) then
				times = math.abs(x)
			else
				times = math.abs(y)
			end
			times = math.ceil(times)
			local scheduler = require("framework.scheduler")
			local logoSche
			local index_j = 0
			function drawnHeart()
				if self.isClose or self._drawNode == nil then
					scheduler.unscheduleGlobal(logoSche)
					return
				end
				if index_j > times then
					scheduler.unscheduleGlobal(logoSche)
					index = index + 1
					animation()
				else
					local x = a.x + x / times * index_j
					local y = a.y + y / times * index_j
					goAnim:setPosition(cc.p(x, y))
					self._drawNode:drawDot(cc.p(x, y), 3, cc.c4f(0.984313725490196, 0.9529411764705882, 0.6196078431372549, 1))
				end
				index_j = index_j + 1
			end
			logoSche = scheduler.scheduleGlobal(drawnHeart, 0)
		else
			goAnim:setVisible(false)
			self:playYanxiAni(level_2)
			self._rootnode.jingLianBtn:setEnabled(true)
			local locak = self._rootnode.DrawNodeTop:getChildByTag(level_2)
			locak:setDisplayFrame(display.newSprite("ui_common/ui_cheats_jinjie_unlock.png"):getDisplayFrame())
		end
	end
	animation()
end

function CheatsJinJie:ctor(param)
	ResMgr.createBefTutoMask(self)
	self.isClose = false
	self.removeListener = param.removeListener
	self.objId = param.id or 0
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("cheats/cheats_jinjie.ccbi", proxy, self._rootnode)
	node:setPosition(display.cx, display.cy)
	self:addChild(node)
	self._drawNode = display.newDrawNode()
	self._rootnode.DrawNode:addChild(self._drawNode)
	self._drawNodeSize = self._rootnode.DrawNode:getContentSize()
	local cheatsData = CheatsModel.getCheatsByObjId(self.objId)
	self.resId = cheatsData.data.resId
	self:setBgNode({
	resId = cheatsData.data.resId,
	floor = cheatsData.data.floor,
	level = cheatsData.data.level
	})
	self.curOp = PRIVIEW_OP
	self:sendRes({
	id = self.objId,
	op = self.curOp
	})
	
	local isup, mod, top = CheatsModel.isUpFloor(cheatsData.data.resId, cheatsData.data.level, cheatsData.data.floor)
	if isup == true then
		resetctrbtnString(self._rootnode.jingLianBtn, common:getLanguageString("@CheatsTupo"))
		if top == true then
			self._rootnode.jingLianBtn:setEnabled(false)
		else
			self._rootnode.jingLianBtn:setEnabled(false)
		end
	else
		resetctrbtnString(self._rootnode.jingLianBtn, common:getLanguageString("@CheatsStudy"))
	end
	
	--返回按钮
	self._rootnode.backBtn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		self.isClose = true
		if self.removeListener ~= nil then
			self.removeListener()
		end
		PostNotice(NoticeKey.REMOVE_TUTOLAYER)
		self:removeSelf()
	end,
	CCControlEventTouchUpInside)
	
	--[[研习和突破	]]
	self._rootnode.jingLianBtn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		if self.notEnough == false then
			show_tip_label(common:getLanguageString("@LackRes"))
		elseif self.costXiuwei > self.haveXiuwei then
			ResMgr.showErr(100022)
		else
			self._rootnode.jingLianBtn:setEnabled(false)
			self.curOp = JINJIE_OP
			self:sendRes({
			id = self.objId,
			op = self.curOp
			})
		end
	end,
	CCControlEventTouchUpInside)
end

return CheatsJinJie