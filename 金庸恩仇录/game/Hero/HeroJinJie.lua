local data_jinjie_jinjie = require("data.data_jinjie_jinjie")
local HeroJinJie = class("HeroJinJie", function(param)
	return require("utility.ShadeLayer").new()
end)
local PRIVIEW_OP = "1"
local JINJIE_OP = "2"
function HeroJinJie:sendRes(param)
	RequestHelper.getJinJieRes({
	callback = function(data)
		self:init(data)
	end,
	id = param.id,
	op = param.op
	})
end
function HeroJinJie:updateListData(leftData)
	local cellData = self.list[self.index]
	cellData.cls = leftData.cls
	cellData.level = leftData.lv
	cellData.star = leftData.star
	self.cls = leftData.cls or 0
	if self.resID == 1 or self.resID == 2 then
		game.player.m_class = leftData.cls
	end
end
function HeroJinJie:removeCard(removeList)
	if removeList ~= nil then
		for i = 1, #removeList do
			dump(removeList[i])
			for k = 1, #HeroModel.totalTable do
				if HeroModel.totalTable[k].id == removeList[i] then
					table.remove(HeroModel.totalTable, k)
					break
				end
			end
		end
	end
end
function HeroJinJie:init(data)
	self.data = data
	dump("jinjiedatata ")
	dump(data)
	local removeList = data["8"]
	self:removeCard(removeList)
	local leftData = data["2"]
	local leftResID = leftData.resId
	local leftCls = leftData.cls
	self.cls = leftCls or 0
	self.resID = leftResID
	local heroStaticData = ResMgr.getCardData(leftResID)
	local job = heroStaticData.job
	ResMgr.refreshJobIcon(self._rootnode.left_job_icon, job)
	ResMgr.refreshJobIcon(self._rootnode.right_job_icon, job)
	local leftNameStr = heroStaticData.name
	if leftResID == 1 or leftResID == 2 then
		leftNameStr = game.player.m_name
	end
	local leftStarsNum = leftData.star
	local leftLv = leftData.lv
	self.lv = leftLv
	local leftBase = leftData.base
	self:updateListData(leftData)
	self._rootnode.image:setDisplayFrame(ResMgr.getHeroFrame(leftResID, leftCls))
	ResMgr.refreshCardBg({
	sprite = self._rootnode.card_left,
	star = leftStarsNum,
	resType = ResMgr.HERO_BG_UI
	})
	local starNum = leftStarsNum or 0
	for i = 1, 5 do
		local star = self._rootnode["star" .. i]
		if i > starNum then
			star:setVisible(false)
		else
			star:setVisible(true)
		end
	end
	self.leftHeroName:setString(leftNameStr)
	self.leftHeroName:setColor(NAME_COLOR[starNum])
	if leftCls == 0 then
		self.leftHeroCls:setVisible(false)
	else
		self.leftHeroCls:setVisible(true)
		self.leftHeroCls:setString("+" .. leftCls)
	end
	alignNodesOneByOne(self.leftHeroName, self.leftHeroCls, 5)
	self._rootnode.lvl:setString(leftLv)
	alignNodesOneByOne(self._rootnode.lvl_Tag, self._rootnode.lvl)
	for i = 1, 4 do
		self._rootnode["baseState" .. i]:setString(leftBase[i])
		alignNodesOneByOne(self._rootnode["baseState_Tag_" .. i], self._rootnode["baseState" .. i])
	end
	local isReachLimit = false
	local rightData = data["3"]
	if rightData.base == nil then
		isReachLimit = true
		ResMgr.showErr(200007)
		self._rootnode.right_info:setVisible(false)
		self._rootnode.card_right:setVisible(false)
		self._rootnode.arrow:setVisible(false)
		self._rootnode.jingLianBtn:setVisible(false)
		self.costNum = 0
		self._rootnode.scrow_node:removeAllChildren()
	else
		self._rootnode.right_info:setVisible(true)
		self._rootnode.card_right:setVisible(true)
		self._rootnode.arrow:setVisible(true)
		self._rootnode.jingLianBtn:setVisible(true)
		do
			local rightResID = rightData.resId
			local rightCls = rightData.cls
			local rightIconNameRes = ResMgr.getCardData(rightResID).arr_body[rightCls + 1]
			local rightIconPath = ResMgr.getLargeImage(rightIconNameRes, ResMgr.HERO)
			local rightNameStr = ResMgr.getCardData(rightResID).name
			if rightResID == 1 or rightResID == 2 then
				rightNameStr = game.player.m_name
			end
			local rightStarsNum = rightData.star or leftStarsNum
			ResMgr.refreshCardBg({
			sprite = self._rootnode.card_right,
			star = rightStarsNum,
			resType = ResMgr.HERO_BG_UI
			})
			local rightLv = rightData.lv
			local rightBase = rightData.base
			self._rootnode.rightimage:setDisplayFrame(ResMgr.getHeroFrame(rightResID, rightCls))
			local starNum = rightStarsNum or 0
			for i = 1, 5 do
				local star = self._rootnode["rightstar" .. i]
				if i > starNum then
					star:setVisible(false)
				else
					star:setVisible(true)
				end
			end
			self.rightHeroName:setString(rightNameStr)
			self.rightHeroName:setColor(NAME_COLOR[starNum])
			if rightCls == 0 then
				self.rightHeroCls:setVisible(false)
			else
				self.rightHeroCls:setVisible(true)
				self.rightHeroCls:setString("+" .. rightCls)
			end
			self._rootnode.rightLv:setString(rightLv)
			alignNodesOneByOne(self._rootnode.rightLv_Tag, self._rootnode.rightLv)
			alignNodesOneByOne(self.rightHeroName, self.rightHeroCls, 5)
			for i = 1, 4 do
				self._rootnode["right_state_" .. i]:setString(rightBase[i])
				alignNodesOneByOne(self._rootnode["right_state_Tag_" .. i], self._rootnode["right_state_" .. i])
			end
			self.costNum = data["5"]
			local itemData = data["4"]
			self.notEnough = true
			self.costData = itemData
			for i = 1, #itemData do
				local itemsResId = itemData[i].id
				local itemsHaveNum = itemData[i].n2
				local itemsNeedNum = itemData[i].n1
				local itemType = itemData[i].t
				if itemsHaveNum < itemsNeedNum then
					self.notEnough = false
				end
			end
			local function createfuncCell(idx)
				local item = require("game.Hero.JinJieCell").new()
				dump("creerer")
				return item:create({
				id = idx,
				listData = itemData,
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
			cellNum = #itemData,
			cellSize = require("game.Hero.JinJieCell").new():getContentSize()
			})
			self._rootnode.scrow_node:addChild(itemList)
		end
	end
	self._rootnode.cost_silver:setString(self.costNum)
	alignNodesOneByAll({
	self._rootnode.cost_silver_Tag,
	self._rootnode.yinbiIcon,
	self._rootnode.cost_silver
	}, 5)
	if data["1"] == 0 and data["3"].base == nil then
		self._rootnode.jingLianBtn:setVisible(false)
		self._rootnode.right_info:setVisible(false)
		self._rootnode.card_right:setVisible(false)
		self._rootnode.cost_silver:setVisible(false)
	end
end
function HeroJinJie:onExit()
	TutoMgr.removeBtn("herojinjielayer_kaishijinjie_btn")
	TutoMgr.removeBtn("herojinjielayer_back_btn")
end
function HeroJinJie:onEnter()
	TutoMgr.addBtn("herojinjielayer_kaishijinjie_btn", self._rootnode.jingLianBtn)
	TutoMgr.addBtn("herojinjielayer_back_btn", self._rootnode.backBtn)
	TutoMgr.active()
	self._rootnode.jingLianBtn:setEnabled(true)
end

function HeroJinJie:ctor(param)
	ResMgr.createBefTutoMask(self)
	dump("jinjinijinininiinin")
	local FROM_LIST = 1
	local FROM_FORMATION = 2
	self.removeListener = param.removeListener
	self.incomeType = param.incomeType
	dump("self.income" .. self.incomeType)
	self:setNodeEventEnabled(true)
	local listInfo = param.listInfo
	self.objId = listInfo.id
	dump("self.objId" .. self.objId)
	self.updateTableFunc = listInfo.updateTableFunc
	self.list = listInfo.listData
	self.index = listInfo.cellIndex
	self.resetList = listInfo.resetList
	self.upNumFunc = listInfo.upNumFunc
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("hero/hero_jinjie.ccbi", proxy, self._rootnode)
	node:setPosition(display.cx, display.cy)
	self:addChild(node)
	local curHeight = node:getContentSize().height
	local orHeight = 633
	local scale = curHeight / orHeight
	
	--名称
	self.leftHeroName = ui.newTTFLabelWithShadow({
	text = common:getLanguageString("@Hero"),
	font = FONTS_NAME.font_fzcy,
	x = self._rootnode.left_info:getContentSize().width * 0.4,
	y = self._rootnode.left_info:getContentSize().height * 0.85,
	size = 20,
	align = ui.TEXT_ALIGN_CENTER,
	color = FONT_COLOR.WHITE,
	shadowColor = FONT_COLOR.BLACK,
	
	})
	self.leftHeroName:setAnchorPoint(ccp(0.5, 0.5))
	self._rootnode.left_info:addChild(self.leftHeroName)
	
	--资质
	self.leftHeroCls = ui.newTTFLabelWithShadow({
	text = "+0",
	x = self._rootnode.left_info:getContentSize().width * 0.4,
	y = self._rootnode.left_info:getContentSize().height * 0.85,
	font = FONTS_NAME.font_fzcy,
	size = 20,
	align = ui.TEXT_ALIGN_CENTER,
	color = NAME_COLOR[2],
	shadowColor = FONT_COLOR.BLACK,
	})
	self.leftHeroCls:setAnchorPoint(cc.p(0.5, 0.5))
	self._rootnode.left_info:addChild(self.leftHeroCls)
	
	--名称
	self.rightHeroName = ui.newTTFLabelWithShadow({
	text = common:getLanguageString("@Hero"),
	font = FONTS_NAME.font_fzcy,
	x = self._rootnode.right_info:getContentSize().width * 0.4,
	y = self._rootnode.right_info:getContentSize().height * 0.85,
	size = 20,
	align = ui.TEXT_ALIGN_CENTER,
	color = FONT_COLOR.WHITE,
	shadowColor = FONT_COLOR.BLACK,
	})
	self.rightHeroName:setAnchorPoint(ccp(0.5, 0.5))
	self._rootnode.right_info:addChild(self.rightHeroName)
	
	--资质
	self.rightHeroCls = ui.newTTFLabelWithShadow({
	text = "+0",
	x = self._rootnode.right_info:getContentSize().width * 0.4,
	y = self.rightHeroName:getPositionY(),
	font = FONTS_NAME.font_fzcy,
	size = 20,
	align = ui.TEXT_ALIGN_CENTER,
	color = NAME_COLOR[2],
	shadowColor = FONT_COLOR.BLACK,
	})
	self.rightHeroCls:setAnchorPoint(ccp(0.5, 0.5))
	self._rootnode.right_info:addChild(self.rightHeroCls)
	self.curOp = PRIVIEW_OP
	self:sendRes({
	id = self.objId,
	op = self.curOp
	})
	--if self.first == nil then
	--	self.first = true
	
	self._rootnode.backBtn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		if self.removeListener ~= nil then
			self.removeListener()
		end
		self:removeSelf()
		dump("________________________推送移除返回按键___________________________")
		PostNotice(NoticeKey.REMOVE_TUTOLAYER, "HeroJinJie")
	end,
	CCControlEventTouchUpInside)
	
	self._rootnode.jingLianBtn:setEnabled(false)
	
	--精炼
	self._rootnode.jingLianBtn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		local jinjieIndex = 2
		if self.resID == 1 or self.resID == 2 then
			jinjieIndex = 1
		end
		local clsIndex = self.cls + 1
		local jinjieData = data_jinjie_jinjie[clsIndex]
		local limitLv = jinjieData.level[jinjieIndex]
		if limitLv > self.lv then
			local str = ResMgr.getMsg(9) .. limitLv .. ResMgr.getMsg(10)
			show_tip_label(str)
		else
			local playerSilver = game.player:getSilver()
			if self.notEnough == false then
				ResMgr.showErr(200018)
			elseif playerSilver < self.costNum then
				ResMgr.showErr(100005)
			else
				ResMgr.createMaskLayer(display.getRunningScene())
				self._rootnode.jingLianBtn:setEnabled(false)
				self._rootnode.backBtn:setEnabled(false)
				self.curOp = JINJIE_OP
				RequestHelper.getJinJieRes({
				callback = function(data)
					PostNotice(NoticeKey.REMOVE_TUTOLAYER)
					PostNotice(NoticeKey.LOCK_BOTTOM)
					local function createEndLayer()
						ResMgr.removeMaskLayer()
						local finLayer = require("game.Hero.HeroJinJieEndLayer").new({
						data = self.data,
						removeListener = function()
							self._rootnode.jingLianBtn:setEnabled(true)
							self._rootnode.backBtn:setEnabled(true)
							PostNotice(NoticeKey.UNLOCK_BOTTOM)
						end
						})
						display:getRunningScene():addChild(finLayer, 9999)
						GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_xiakejingjie))
						if data["1"] == 0 and data["3"].base == nil then
							self._rootnode.jingLianBtn:setVisible(false)
							self._rootnode.right_info:setVisible(false)
							self._rootnode.card_right:setVisible(false)
							self:init(data)
						else
							self:init(data)
							if self.resetList then
								self.resetList()
							end
						end
					end
					local startArma = ResMgr.createArma({
					resType = ResMgr.UI_EFFECT,
					armaName = "xiakejinjie_qishou",
					frameFunc = createEndLayer
					})
					startArma:setPosition(display.cx, display.cy)
					display:getRunningScene():addChild(startArma, 9999)
					dump(data)
					game.player.m_silver = game.player.m_silver - self.costNum
					PostNotice(NoticeKey.CommonUpdate_Label_Silver)
					game.player.m_class = data["2"].cls
					if data["2"] ~= nil and data["2"].cls > 5 then
						local heroInfo = ResMgr.getCardData(data["2"].resId)
						Broad_heroLevelUpData.heroName = heroInfo.name
						Broad_heroLevelUpData.type = heroInfo.type
						Broad_heroLevelUpData.star = heroInfo.star[data["2"].cls + 1]
						Broad_heroLevelUpData.class = data["2"].cls
						game.broadcast:showHeroLevelUp()
					end
					if data["2"].totalProArr ~= nil and data["2"].supportPos ~= nil then
						HelpLineModel:setTotalProArrData(data["2"].totalProArr)
						local card = {}
						card.resId = data["2"].resId
						card.lv = data["2"].lv
						card.cls = data["2"].cls
						card.start = data["2"].start
						card.base = data["2"].base
						card.id = data["2"].id
						HelpLineModel:setHelpData(data["2"].supportPos, card)
					end
				end,
				id = self.objId,
				op = self.curOp
				})
			end
		end
	end,
	CCControlEventTouchUpInside)
	
end

return HeroJinJie