local COMMON_VIEW = 1
local SALE_VIEW = 2
display.addSpriteFramesWithFile("ui/ui_submap.plist", "ui/ui_submap.png")

local HeroListCell = class("HeroListCell", function(param)
	return CCTableViewCell:new()
end)

function HeroListCell:getContentSize()
	return cc.size(display.width, 154)
end

function HeroListCell:getJinjieBtn()
	return self._rootnode.jinjieBtn
end

function HeroListCell:getHeadIcon()
	return self._rootnode.headIcon
end

function HeroListCell:create(param)
	local changeSoldMoney = param.changeSoldMoney
	local addSellItem = param.addSellItem
	local removeSellItem = param.removeSellItem
	self.choseTable = param.choseTable
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("hero/hero_list_item.ccbi", proxy, self._rootnode)
	node:setPosition(display.cx, self._rootnode.itemBg:getContentSize().height / 2)
	self:addChild(node)
	self.cellIndex = param.id
	self.createJinJieLayer = param.createJinjieListenr
	self.createQiangHuaLayer = param.createQiangHuaListener
	self.bg = self._rootnode.itemBg
	self.list = param.listData
	self.saleList = param.saleData
	self.headIcon = self._rootnode.headIcon
	self.clsTTF = self._rootnode.cls
	
	self.onHeadIcon = param.onHeadIcon
	
	self.heroName = ui.newTTFLabelWithShadow({
	text = "",
	font = FONTS_NAME.font_fzcy,
	x = 10,
	y = self._rootnode.nameBg:getContentSize().height * 0.5,
	size = 22,
	align = ui.TEXT_ALIGN_LEFT,
	shadowColor = display.COLOR_BLACK,
	})
	self.heroName:setAnchorPoint(cc.p(0.5, 0.5))
	self.heroName:setPositionX(self.heroName:getContentSize().width / 2)
	self._rootnode.nameBg:addChild(self.heroName)
	self.heroCls = ui.newTTFLabelWithShadow({
	text = "0",
	size = 20,
	color = cc.c3b(85, 210, 68),
	shadowColor = display.COLOR_BLACK,
	font = FONTS_NAME.font_fzcy,
	align = ui.TEXT_ALIGN_LEFT,
	x = 0,
	y = self.heroName:getPositionY()
	})
	self.heroCls:setAnchorPoint(cc.p(0.5, 0.5))
	self._rootnode.nameBg:addChild(self.heroCls)
	self.lv = self._rootnode.lvNum
	
	ResMgr.setControlBtnEvent(self._rootnode.jinjieBtn, function()
		local bHasOpen, prompt = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.XiaKe_JinJie, game.player:getLevel(), game.player:getVip())
		if not bHasOpen then
			show_tip_label(prompt)
		else
			PostNotice(NoticeKey.REMOVE_TUTOLAYER)
			self.createJinJieLayer(self.objId, self.index)
		end
	end)
	
	ResMgr.setControlBtnEvent(self._rootnode.qianghuaBtn, function()
		if self.lvl < game.player.m_level then
			self.createQiangHuaLayer(self.objId, self.index)
		else
			show_tip_label(common:getLanguageString("@MCisGod"))
		end
	end)
	
	self.selBtn = self._rootnode.unSelIcon
	self.unseleBtn = self._rootnode.selIcon
	
	local function selFunc()
		self.selBtn:setVisible(false)
		self.unseleBtn:setVisible(true)
		changeSoldMoney(self.price)
		addSellItem(self.objId, self.index)
	end
	local function unSelFunc()
		self.selBtn:setVisible(true)
		self.unseleBtn:setVisible(false)
		changeSoldMoney(0 - self.price)
		removeSellItem(self.objId, self.index)
	end
	
	self.selBtn:registerScriptTapHandler(function()
		selFunc()
	end)
	
	self.unseleBtn:registerScriptTapHandler(function()
		unSelFunc()
	end)
	
	self:refresh(self.cellIndex, param.viewType, param.isSel)
	return self
end

function HeroListCell:setStars(num)
	for i = 1, 5 do
		if num < i then
			self._rootnode["star" .. i]:setVisible(false)
		else
			self._rootnode["star" .. i]:setVisible(true)
		end
	end
end

function HeroListCell:tableCellTouched(x, y)
	local icon = self._rootnode["headIcon"]	
	local bound = icon:getCascadeBoundingBox()	
	if bound:containsPoint(cc.p(x, y)) then	
		PostNotice(NoticeKey.REMOVE_TUTOLAYER)		
		self.onHeadIcon(self.index)
	end		
end

function HeroListCell:beTouched()
	--dump(self.cellIndex)
end

function HeroListCell:onExit()
end

function HeroListCell:refresh(id, viewType, isSel)
	local curList
	if viewType == COMMON_VIEW then
		curList = HeroModel.totalTable
		self._rootnode.commonNode:setVisible(true)
		self._rootnode.sellNode:setVisible(false)
	else
		self._rootnode.commonNode:setVisible(false)
		self._rootnode.sellNode:setVisible(true)
		curList = HeroModel.sellAbleData
	end
	--dump("ddddddddddddddddddd" ..viewType) --九 -零 -一-起 玩-w-w-w-.9-0-1 -7-5-.-com
	--dump("ddddddddddddddddddd" ..id)
	self.index = id + 1
	self.cellData = curList[id + 1]
	self.objId = self.cellData._id
	if self.cellData.lock ~= 1 then
		self._rootnode.lock_icon:setVisible(false)
	else
		self._rootnode.lock_icon:setVisible(true)
	end
	local battleSize = 0
	if self.cellData.battle ~= nil then
		battleSize = #self.cellData.battle
	end
	--czy
	local battleIcon = self._rootnode.has_battle_icon
	battleIcon:setTouchEnabled(true)
	battleIcon:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		if event.name == "began" then
			return true
		elseif event.name == "ended" then
			ResMgr.showErr(800017)
		end
	end)
	if battleSize > 0 then
		battleIcon:setVisible(true)
	else
		battleIcon:setVisible(false)
	end
	self.resID = self.cellData.resId
	local curCardData = ResMgr.getCardData(self.resID)
	self.cls = self.cellData.cls
	self.clsTTF:setString("")
	if self.cls == 0 then
		self.heroCls:setString("")
	else
		self.heroCls:setString("+" .. self.cls)
	end
	self.lvl = self.cellData.level
	ResMgr.showAlert(self.lvl, "level is null,objId:" .. self.objId)
	if self.lvl ~= nil then
		self.lv:setString("LV." .. self.lvl)
	end
	local zizhiData = curCardData.arr_zizhi
	if zizhiData ~= nil then
		local zizhiValue = zizhiData[self.cls + 1]
		self._rootnode.zizhi:removeAllChildren()
		local heroZizhi = ui.newTTFLabelWithShadow({
		text = common:getLanguageString("@Quolity") .. zizhiValue,
		font = FONTS_NAME.font_fzcy,
		shadowColor = display.COLOR_BLACK,
		size = 20,
		align = ui.TEXT_ALIGN_LEFT
		})
		heroZizhi:align(display.LEFT_CENTER, 10, self._rootnode.zizhi:getContentSize().height / 2)
		--heroZizhi:setPosition(10, self._rootnode.zizhi:getContentSize().height / 2)
		self._rootnode.zizhi:addChild(heroZizhi)
	end
	local job = curCardData.job
	ResMgr.refreshJobIcon(self._rootnode.job_icon, job)
	local nameStr = curCardData.name
	if self.resID == 1 or self.resID == 2 then
		nameStr = game.player.m_name
	end
	self.heroName:setString(nameStr)
	self.heroName:setPositionX(self.heroName:getContentSize().width / 2 + 20)
	alignNodesOneByOne(self.heroName, self.heroCls)
	self.price = curCardData.price
	self._rootnode.price:setString(self.price)
	if curCardData.advance == 1 then
		self._rootnode.jinjieBtn:setVisible(true)
	else
		self._rootnode.jinjieBtn:setVisible(false)
	end
	if self.resID == 1 or self.resID == 2 then
		self._rootnode.qianghuaBtn:setVisible(false)
	else
		self._rootnode.qianghuaBtn:setVisible(true)
	end
	self.isQingyuan = #self.cellData.relation
	if self.isQingyuan ~= 0 then
		self._rootnode.qingyuanIcon:setVisible(true)
	else
		self._rootnode.qingyuanIcon:setVisible(false)
	end
	self.pos = self.cellData.pos
	if self.pos ~= 0 then
		self._rootnode.shangzhenIcon:setVisible(true)
		self._rootnode.zhuzhenIcon:setVisible(false)
		self._rootnode.qingyuanIcon:setVisible(false)
	elseif self.cellData.supportPos ~= 0 then
		self._rootnode.shangzhenIcon:setVisible(false)
		self._rootnode.zhuzhenIcon:setVisible(true)
		self._rootnode.qingyuanIcon:setVisible(false)
	else
		self._rootnode.shangzhenIcon:setVisible(false)
		self._rootnode.zhuzhenIcon:setVisible(false)
	end
	self.starsNum = self.cellData.star
	self:setStars(self.starsNum)
	self.heroName:setColor(NAME_COLOR[self.starsNum])
	ResMgr.refreshIcon({
	id = self.resID,
	itemBg = self.headIcon,
	resType = ResMgr.HERO,
	cls = self.cls
	})
	if isSel == true then
		self._rootnode.unSelIcon:setVisible(false)
		self._rootnode.selIcon:setVisible(true)
	else
		self._rootnode.selIcon:setVisible(false)
		self._rootnode.unSelIcon:setVisible(true)
	end
end

function HeroListCell:runEnterAnim()
	local delayTime = self.cellIndex * 0.15
	local sequence = transition.sequence({
	CCCallFuncN:create(function()
		self:setPosition(cc.p(self:getContentSize().width / 2 + display.width / 2, self:getPositionY()))
	end),
	CCDelayTime:create(delayTime),
	CCMoveBy:create(0.3, cc.p(-(self:getContentSize().width / 2 + display.width / 2), 0))
	})
	self:runAction(sequence)
end

return HeroListCell