local data_error_error = require("data.data_error_error")
local HeiShiItem = class(HeiShiItem, function()
	return CCTableViewCell:new()
end)
local MAX_ZODER = 1001

function HeiShiItem:getContentSize()
	if self.Cntsize ~= nil then
	else
		local proxy = CCBProxy:create()
		local rootnode = {}
		local node = CCBuilderReaderLoad("nbhuodong/heishi_duihuan_item.ccbi", proxy, rootnode)
		self.Cntsize = rootnode.itemBg:getContentSize()
	end
	return self.Cntsize
end

function HeiShiItem:create(param)
	local viewSize = param.viewSize
	local jifen = param.jifen
	self.callback = param.callback
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("nbhuodong/heishi_duihuan_item.ccbi", proxy, self._rootnode)
	node:setPosition(viewSize.width * 0.5, self._rootnode.itemBg:getContentSize().height * 0.5)
	self:addChild(node)
	
	self._rootnode.exchangeBtn:addHandleOfControlEvent(function()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		self:exchange()
	end,
	CCControlEventTouchUpInside)
	
	--czy
	local rewardIcon = self._rootnode.itemIcon
	self._rootnode.itemIcon:setTouchEnabled(true)
	rewardIcon:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
		self._rootnode.itemIcon:setTouchEnabled(false)
		if event.name == "began" then
			return true
		elseif event.name == "ended" then
			self:onInformation()
			self._rootnode.itemIcon:setTouchEnabled(true)
		end
	end)
	self:refresh(param.idx, param.itemData, jifen)
	return self
end

function HeiShiItem:onInformation()
	if not self.data then
		return
	end
	local staticData = ResMgr.getItemByType(self.data.itemId, ResMgr.getResType(self.data.type))
	local itemInfo = require("game.Huodong.ItemInformation").new({
	id = self.data.itemId,
	type = self.data.type,
	name = staticData.name,
	describe = staticData.describe
	})
	game.runningScene:addChild(itemInfo, MAX_ZODER)
end

function HeiShiItem:refresh(idx, data, jifen)
	self.data = data
	self.jifen = jifen
	self.idx = idx
	local staticData = ResMgr.getItemByType(data.itemId, ResMgr.getResType(data.type))
	local rewardIcon = self._rootnode.itemIcon
	rewardIcon:removeAllChildrenWithCleanup(true)
	ResMgr.refreshIcon({
	id = data.itemId,
	resType = ResMgr.getResType(data.type),
	itemBg = rewardIcon,
	iconNum = data.num,
	isShowIconNum = false,
	numLblSize = 22,
	numLblColor = cc.c3(0, 255, 0),
	numLblOutColor = cc.c3(0, 0, 0),
	itemType = data.type
	})
	local nameColor = ResMgr.getItemNameColorByType(data.itemId, ResMgr.getResType(data.type))
	local nameLbl = ui.newTTFLabelWithShadow({
	text = staticData.name,
	size = 22,
	color = nameColor,
	shadowColor = cc.c3b(0, 0, 0),
	font = FONTS_NAME.font_haibao,
	align = ui.TEXT_ALIGN_CENTER
	})
	nameLbl:setPosition(nameLbl:getContentSize().width / 2, -nameLbl:getContentSize().height / 2)
	self._rootnode.name_lbl:removeAllChildren()
	self._rootnode.name_lbl:addChild(nameLbl)
	self._rootnode.cost_name:setString(common:getLanguageString("@tbexchangerequest", data.price))
	self._rootnode.exchange_num:setString(common:getLanguageString("@blackmarketall") .. data.serverLast .. "/" .. data.serverLimit)
	self._rootnode.exchange_num_sing:setString(common:getLanguageString("@blackmarketone") .. data.selfBuy .. "/" .. data.selfLimit)
end

function HeiShiItem:exchange()
	local data = self.data
	local serverNum = data.serverLast
	local selfNum = data.selfLimit - data.selfBuy
	local jifenNum = math.floor(tonumber(self.jifen) / tonumber(data.price))
	local staticData = ResMgr.getItemByType(data.itemId, ResMgr.getResType(data.type))
	local itemData = {
	had = math.min(math.min(selfNum, jifenNum), serverNum),
	limitNum = math.min(math.min(selfNum, jifenNum), serverNum),
	name = staticData.name,
	price = data.price,
	id = data.id
	}
	if math.min(selfNum, serverNum) <= 0 then
		show_tip_label(data_error_error[2400003].prompt)
		return
	end
	if self.jifen < self.data.price then
		show_tip_label(data_error_error[1500710].prompt)
		return
	end
	local param = {}
	param.itemData = itemData
	function param.listener(buynum, jifen, id, num, pnum)
		if self.callback then
			if not buynum then
				self.callback()
				return
			end
			self.callback(jifen, self.idx, num, pnum)
			local datas = {
			id = data.itemId,
			type = data.type,
			iconType = ResMgr.getResType(data.type),
			name = staticData.name,
			describe = staticData.describe,
			num = tonumber(buynum) * tonumber(data.num)
			}
			local cellDatas = {}
			table.insert(cellDatas, datas)
			game.runningScene:addChild(require("game.Huodong.RewardMsgBox").new({cellDatas = cellDatas, num = 1}), MAX_ZODER)
		end
	end
	local popup = require("game.nbactivity.TanBao.HeiShiExchangeCountBox").new(param)
	popup:setPositionY(0)
	display.getRunningScene():addChild(popup, 1000000)
end

return HeiShiItem