local COMMON_VIEW = 1
local SALE_VIEW = 2

local PetListCell = class("PetListCell", function(param)
	return CCTableViewCell:new()
end)

function PetListCell:getContentSize()
	return cc.size(360, 154)
end

function PetListCell:getJinjieBtn()
	return self._rootnode.jinjieBtn
end

function PetListCell:getHeadIcon()
	return self._rootnode.headIcon
end

function PetListCell:create(param)
	local changeSoldMoney = param.changeSoldMoney
	local addSellItem = param.addSellItem
	local removeSellItem = param.removeSellItem
	self.createJinJieLayer = param.createJinjieListenr
	self.createQiangHuaLayer = param.createQiangHuaListener
	self.cellIndex = param.id
	self._onHeadIcon = param.onHeadIcon
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("pet/pet_list_item.ccbi", proxy, self._rootnode)
	node:setPosition(315, self._rootnode.itemBg:getContentSize().height / 2)
	self:addChild(node)
	self.bg = self._rootnode.itemBg
	self.headIcon = self._rootnode.headIcon
	self.clsTTF = self._rootnode.cls
	local bTouch = false
	local offsetX = 0
	
	--名称
	self.heroName = ui.newTTFLabelWithShadow({
	text = "",
	font = FONTS_NAME.font_fzcy,
	x = 0,
	y = self._rootnode.nameBg:getContentSize().height * 0.5,
	size = 22,
	align = ui.TEXT_ALIGN_LEFT,
	color = FONT_COLOR.WHITE,
	shadowColor = FONT_COLOR.BLACK,
	})
	self.heroName:align(display.LEFT_CENTER, 5, self._rootnode.nameBg:getContentSize().height/2)
	self.heroName:addTo(self._rootnode.nameBg)
	
	--进阶
	self.heroCls = ui.newTTFLabelWithShadow({
	text = "0",
	size = 20,
	font = FONTS_NAME.font_fzcy,
	align = ui.TEXT_ALIGN_LEFT,
	color = cc.c3b(85, 210, 68),
	shadowColor = FONT_COLOR.BLACK,
	})
	self.heroCls:align(display.LEFT_CENTER, 0, self._rootnode.nameBg:getContentSize().height/2)
	self.heroCls:addTo(self._rootnode.nameBg)
	
	--进阶按键
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
	
	--强化按键
	ResMgr.setControlBtnEvent(self._rootnode.qianghuaBtn, function()
		self.createQiangHuaLayer(self.objId, self.index)
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
	
	self.selBtn:registerScriptTapHandler(selFunc)
	self.unseleBtn:registerScriptTapHandler(unSelFunc)
	
	self:refresh(self.cellIndex, param.viewType)
	return self
	
end

function PetListCell:tableCellTouched(x, y)
	local icon = self.headIcon
	local size = icon:getContentSize()
	if cc.rectContainsPoint(cc.rect(0,0,size.width, size.height), icon:convertToNodeSpace(cc.p(x, y))) then
		PostNotice(NoticeKey.REMOVE_TUTOLAYER)
		self._onHeadIcon(self.index)
	end
end

function PetListCell:setStars(num)
	for i = 1, 5 do
		if num < i then
			self._rootnode["star" .. i]:setVisible(false)
		else
			self._rootnode["star" .. i]:setVisible(true)
		end
	end
end

function PetListCell:beTouched()
	dump(self.cellIndex)
end

function PetListCell:onExit()
end

function PetListCell:refresh(id, viewType, isSel)
	local curList
	if viewType == COMMON_VIEW then
		curList = PetModel.totalTable
		self._rootnode.commonNode:setVisible(true)
		self._rootnode.sellNode:setVisible(false)
	else
		self._rootnode.commonNode:setVisible(false)
		self._rootnode.sellNode:setVisible(true)
		curList = PetModel.sellAbleData
	end
	--dump(curList)
	self.index = id + 1
	self.cellData = curList[id + 1]
	self.objId = self.cellData._id
	if self.cellData.lock ~= 1 then
		self._rootnode.lock_icon:setVisible(false)
	else
		self._rootnode.lock_icon:setVisible(true)
	end
	self.resID = self.cellData.resId
	local curCardData = ResMgr.getPetData(self.resID)
	self.cls = self.cellData.cls
	self.clsTTF:setString("")
	if self.cls == 0 then
		self.heroCls:setString("")
	else
		self.heroCls:setString("+" .. self.cls)
	end
	self.lvl = self.cellData.level
	if self.lvl ~= nil then
		self.lv:setString("LV." .. self.lvl)
	end
	
	self._rootnode.zizhi:removeAllChildren()
	local heroZizhi = ui.newTTFLabelWithShadow({
	text = common:getLanguageString("@Quolity") .. curCardData.arr_zizhi,
	font = FONTS_NAME.font_fzcy,
	size = 20,
	color = display.COLOR_WHITE,
	shadowColor = display.COLOR_BLACK,
	})
	
	heroZizhi:align(display.LEFT_CENTER, 10, self._rootnode.zizhi:getContentSize().height / 2)
	self._rootnode.zizhi:addChild(heroZizhi)
	
	local nameStr = curCardData.name
	self.heroName:setString(nameStr)
	self.heroCls:setPositionX(self.heroName:getPositionX() + self.heroName:getContentSize().width + 5)
	self.price = curCardData.price
	self._rootnode.price:setString(self.price)
	self._rootnode.qianghuaBtn:setVisible(true)
	if curCardData.isItem == 1 then
		self._rootnode.jinjieBtn:setVisible(false)
		self._rootnode.qianghuaBtn:setVisible(false)
	end
	if curCardData.limit == 0 then
		self._rootnode.jinjieBtn:setVisible(false)
	else
		self._rootnode.jinjieBtn:setVisible(true)
	end
	if self.cellData.fateState == 1 then
		self._rootnode.qingyuanIcon:setVisible(true)
	else
		self._rootnode.qingyuanIcon:setVisible(false)
	end
	local a = self.cellData.cid
	if 0 < self.cellData.cid then
		self._rootnode.ownername:setVisible(true)
		local heroName = HeroModel.getHeroNameByResId(self.cellData.cid)
		self._rootnode.ownername:setString(common:getLanguageString("@zhuangbeiyu") .. heroName)
	else
		self._rootnode.ownername:setVisible(false)
	end
	self.starsNum = curCardData.star
	self:setStars(self.starsNum)
	self.heroName:setColor(NAME_COLOR[self.starsNum])
	ResMgr.refreshIcon({
	id = self.resID,
	itemBg = self.headIcon,
	resType = ResMgr.PET,
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

function PetListCell:runEnterAnim()
	local delayTime = self.cellIndex * 0.15
	local sequence = transition.sequence({
	CCCallFuncN:create(function()
		self:setPosition(cc.p(self:getContentSize().width / 2 + 315, self:getPositionY()))
	end),
	CCDelayTime:create(delayTime),
	CCMoveBy:create(0.3, cc.p(-(self:getContentSize().width / 2 + 315), 0))
	})
	self:runAction(sequence)
end

return PetListCell