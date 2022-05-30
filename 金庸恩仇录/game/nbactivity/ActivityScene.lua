ccb = ccb or {}
ccb["nbHuodongCtrl"] = {}

local data_nbactivity = require("data.data_nbactivity")
local data_jingcaihuodong_jingcaihuodong = require("data.data_jingcaihuodong_jingcaihuodong")
local data_item_item =  require("data.data_item_item")
local data_card_card =  require("data.data_card_card")

local BaseSceneExt = require("game.BaseSceneExt")
local ActivityScene = class("ActivityScene", BaseSceneExt)

function ActivityScene:ctor(showType)
	display.addSpriteFramesWithFile("ui/ui_nbhuodong_icons.plist", "ui/ui_nbhuodong_icons.png")
	ActivityScene.super.ctor(self, {
	bottomFile = "public/bottom_frame.ccbi",
	topFile    = "nbhuodong/nbhuodong_top.ccbi"
	})
	self.firstEnter = true
	self._contentNode = display.newNode()
	self:addChild(self._contentNode)
	self:sendActRes(showType)
end

function ActivityScene:onEnter()
	ActivityScene.super.onEnter(self)
	PostNotice(NoticeKey.UNLOCK_BOTTOM)
end

function ActivityScene:onExit()
	ActivityScene.super.onExit(self)
	if self._contentNode and self._contentNode:getChildByTag(111) then
		if self._contentNode:getChildByTag(111).clear then
			self._contentNode:getChildByTag(111):clear()
		end
	end
	CCTextureCache:sharedTextureCache():removeUnusedTextures()
end

function ActivityScene:getTypeCellIndex(showType)
	for i, v in ipairs(self._data) do
		if showType == v.huodong then
			return i - 1
		end
	end
end

function ActivityScene:sendActRes(showType)
	local firstType = self:init()
	if showType ~= nil then
		self:changeShowLayer(showType)
	else
		self:changeShowLayer(firstType)
	end
end


function ActivityScene:changeShowLayer(showType)
	if showType ~= nil and self._showType ~= showType then
		self._showType = showType
		self._cellIndex = self:getTypeCellIndex(self._showType)
		self:updateLayer(self._showType, self._cellIndex)
	end
end

function ActivityScene:init()
	self._data = {}
	for k, v in ipairs(data_jingcaihuodong_jingcaihuodong) do
		if ActStatusModel.getIsActOpen(v.huodong) and v.open == 1 then
			if v.huodong == nbActivityShowType.VipShouchong then
				if not game.player:getIsHasBuyGold() then
					table.insert(self._data, v)
				end
			elseif v.huodong == nbActivityShowType.VipFuli then
				if game.player:getVip() > 0 then
					table.insert(self._data, v)
				end
			else
				table.insert(self._data, v)
			end
		end
	end
	local sortFunc = function(a, b)
		return a.weight < b.weight
	end
	table.sort(self._data, sortFunc)
	local firstType
	if #self._data > 0 then
		firstType = self._data[1].huodong
	end
	
	local headListNode = self._rootnode["headList"]
	local headListNodeSize = headListNode:getContentSize()
	
	local function createFunc(index)
		local item = require("game.nbactivity.ActivityItem").new()
		return item:create({
		viewSize = cc.size(headListNodeSize.width, headListNodeSize.height),
		itemData = self._data[index + 1]
		})
	end
	
	local function refreshFunc(cell, index)
		local selected = false
		if index == self._cellIndex then
			selected = true
		end
		cell:refresh(self._data[index + 1], selected)
	end
	
	local function listDelegate(p1, p2, p3, p4)
		if (p2 == cc.ui.UIListView.CELL_TAG) then
			print(">>>>>>>>>>>>>>>CELL_TAG<<<<<<<<<<<<<<<<<")
			local con = createFunc(p3)
			local size = con:getContentSize()
			local item = self._listView:newItem(con)
			item:setItemSize(size.width, size.height)
			return item
		elseif (p2 == cc.ui.UIListView.CELL_SIZE_TAG)then
			print(">>>>>>>>>>>>>>>CELL_SIZE_TAG<<<<<<<<<<<<<<<<<")
			return headListNodeSize.width, headListNodeSize.height
		elseif (p2 == cc.ui.UIListView.COUNT_TAG)then
			print(">>>>>>>>>>>>>>>COUNT_TAG<<<<<<<<<<<<<<<<<")
			return #self._data
		elseif (p2 == cc.ui.UIListView.CLICKED_TAG)then
			print(">>>>>>>>>>>>>>>CLICKED_TAG<<<<<<<<<<<<<<<<<")
			GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_yeqian))
			local cell = p4:getContent()
			local id = cell:getId()
			--local index = cell:getIdx()
			if self._showType ~= id then
				self:updateLayer(id, p3)
			end
		elseif (p2 == cc.ui.UIListView.UNLOAD_CELL_TAG)then
			print(">>>>>>>>>>>>>>>UNLOAD_CELL_TAG<<<<<<<<<<<<<<<<<")
		end
	end
	
	local function onTouchDelegate(event)
		if (event.name == "clicked")then
			print(">>>>>>>>>>>>>>>CLICKED_TAG<<<<<<<<<<<<<<<<<")
			GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_yeqian))
			local cell = event.item:getContent()
			local id = cell:getId()
			local index = event.itemPos
			if self._showType ~= id then
				self:updateLayer(id, index -1)
			end
		end
	end
	
	local params = {
	viewRect = cc.rect(0, 0, headListNodeSize.width, headListNodeSize.height),
	direction = cc.ui.UIScrollView.DIRECTION_HORIZONTAL,
	touchOnContent = true
	}
	
	self._listView = cc.ui.UIListView.new(params)
	self._listView:setDelegate(listDelegate)
	self._listView:onTouch(onTouchDelegate)
	
	for i, child in ipairs(self._data) do
		local con = createFunc(i - 1)
		local size = con:getContentSize()
		local item = self._listView:newItem(con)
		item:setItemSize(size.width, size.height)
		self._listView:addItem(item)
	end
	self._listView:reload()
	headListNode:addChild(self._listView)
	
	return firstType
end


function ActivityScene:updateLayer(showType, cellIndex)
	local viewSize = cc.size(display.width, self:getContentHeight())
	if self._contentNode and self._contentNode:getChildByTag(111) then
		if self._contentNode:getChildByTag(111).clear then
			self._contentNode:getChildByTag(111):clear()
		end
	end
	print("-----type"..showType)
	if showType == nbActivityShowType.KeZhan then
		print("-------------------->客栈<----------------------")
		self._showType = showType
		self._contentNode:removeAllChildrenWithCleanup(true)
		local sleepLayer = require("game.nbactivity.SleepLayer").new({
		viewSize = viewSize
		})
		sleepLayer:setPosition(display.cx, self:getBottomHeight())
		self._contentNode:addChild(sleepLayer, 1)
	elseif showType == nbActivityShowType.xianshiDuiHuan then
		print("-------------------->限时兑换<----------------------")
		self._showType = showType
		self._contentNode:removeAllChildrenWithCleanup(true)
		local sleepLayer = require("game.nbactivity.DuiHuan.DuiHuanMainView").new({
		size = viewSize
		})
		sleepLayer:setPosition(0, self:getBottomHeight())
		self._contentNode:addChild(sleepLayer, 1 ,111)
	elseif showType == nbActivityShowType.huanggongTanBao then
		print("-------------------->皇宫探宝<----------------------")
		local bHasOpen, prompt = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.TanBao, game.player:getLevel(), game.player:getVip())
		if not bHasOpen then
			show_tip_label(prompt)
		else
			self._showType = showType
			self._contentNode:removeAllChildrenWithCleanup(true)
			local sleepLayer = require("game.nbactivity.TanBao.TanbaoMainView").new({
			size = viewSize
			})
			sleepLayer:setPosition(0, self:getBottomHeight())
			self._contentNode:addChild(sleepLayer, 1 , 111)
		end
	elseif showType == nbActivityShowType.migongWaBao then
		print("-------------------->迷宫挖宝<----------------------")
		self._showType = showType
		self._contentNode:removeAllChildrenWithCleanup(true)
		local sleepLayer = require("game.nbactivity.WaBao.WaBaoMainView").new({
		size = viewSize
		})
		sleepLayer:setPosition(0, self:getBottomHeight())
		self._contentNode:addChild(sleepLayer, 1 ,111)
	elseif showType == nbActivityShowType.ShenMi then
		print("-------------------->神秘商店<----------------------")
		local bHasOpen, prompt = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.ShenMi_Shop, game.player:getLevel(), game.player:getVip())
		if not bHasOpen then
			show_tip_label(prompt)
		else
			self._showType = showType
			self._contentNode:removeAllChildrenWithCleanup(true)
			local shenmiLayer = require("game.nbactivity.ShenmiShop.ShenmiLayer").new({
			viewSize = viewSize
			})
			shenmiLayer:setPosition(display.width/2, self:getBottomHeight())
			self._contentNode:addChild(shenmiLayer, 1)
		end
	elseif showType == nbActivityShowType.CaiQuan then
		print("-------------------->猜拳<----------------------")
		self._showType = showType
		self._contentNode:removeAllChildrenWithCleanup(true)
		local caiQuanLayer = require("game.nbactivity.CaiQuan.CaiQuanLayer").new({
		viewSize = viewSize
		})
		caiQuanLayer:setPosition(display.width/2, self:getBottomHeight())
		self._contentNode:addChild(caiQuanLayer, 1)
	elseif  showType == nbActivityShowType.xianshiShop then
		print("-------------------->限时商店<----------------------")
		self._showType = showType
		self._contentNode:removeAllChildrenWithCleanup(true)
		local caiQuanLayer = require("game.nbactivity.XianShiShop.XianShiMainView").new({
		viewSize = viewSize
		})
		caiQuanLayer:setPosition(0, self:getBottomHeight())
		self._contentNode:addChild(caiQuanLayer, 1)
	elseif  showType == nbActivityShowType.LimitHero then
		print("-------------------->限时豪杰<----------------------")
		local bHasOpen, prompt = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.LimitHero, game.player:getLevel(), game.player:getVip())
		if not bHasOpen then
			show_tip_label(prompt)
		else
			self._showType = showType
			self._contentNode:removeAllChildrenWithCleanup(true)
			local caiQuanLayer = require("game.nbactivity.LimitHero.LimitHeroLayer").new({
			viewSize = viewSize
			})
			caiQuanLayer:setPosition(display.width/2, self:getBottomHeight())
			self._contentNode:addChild(caiQuanLayer, 1)
		end
	elseif showType == nbActivityShowType.MonthCard then
		print("-------------------->月卡<----------------------")
		self._showType = showType
		self._contentNode:removeAllChildrenWithCleanup(true)
		local monthCardLayer = require("game.nbactivity.MonthCard.MonthCardLayer").new({
		viewSize = viewSize
		})
		monthCardLayer:setPosition(display.cx, self:getBottomHeight())
		self._contentNode:addChild(monthCardLayer, 1)
	elseif showType == nbActivityShowType.VipFuli then
		print("-------------------->vip福利<----------------------")
		self._showType = showType
		self._contentNode:removeAllChildrenWithCleanup(true)
		local vipFuliLayer = require("game.nbactivity.VipFuli.VipFuliLayer").new({
		viewSize = viewSize
		})
		vipFuliLayer:setPosition(display.cx, self:getBottomHeight())
		self._contentNode:addChild(vipFuliLayer, 1)
	elseif showType == nbActivityShowType.VipShouchong then
		print("-------------------->首充礼包<----------------------")
		self._showType = showType
		self._contentNode:removeAllChildrenWithCleanup(true)
		local vipFuliLayer = require("game.nbactivity.ShouchongLibao.ShouchongLibaoLayer").new({
		viewSize = viewSize
		})
		vipFuliLayer:setPosition(display.cx, self:getBottomHeight())
		self._contentNode:addChild(vipFuliLayer, 1)
	elseif showType == nbActivityShowType.LeijiLogin then
		print("-------------------->累积登录<----------------------")
		self._showType = showType
		local function addLeijiLoginLayer()
			self._contentNode:removeAllChildrenWithCleanup(true)
			local leijiLoginLayer = require("game.nbactivity.LeijiLogin.LeijiLoginLayer").new({
			viewSize = viewSize,
			rewardDatas = self._leijiLoginListData
			})
			leijiLoginLayer:setPosition(display.cx, self:getBottomHeight())
			self._contentNode:addChild(leijiLoginLayer, 1)
		end
		
		if self._leijiLoginListData == nil then
			RequestHelper.leijiLogin.getListData({
			callback = function (data)
				self._leijiLoginListData = {}
				self._leijiLoginListData = self:createLeijiRewardData(data.listObj)
				addLeijiLoginLayer()
			end
			})
		else
			addLeijiLoginLayer()
		end
		
	elseif showType == nbActivityShowType.Yueqian then
		print("-------------------->月签<----------------------")
		self._showType = showType
		self._contentNode:removeAllChildrenWithCleanup(true)
		
		local yueqianLayer = require("game.nbactivity.Yueqian.YueqianLayer").new({
		viewSize = viewSize
		})
		yueqianLayer:setPosition(display.cx, self:getBottomHeight())
		self._contentNode:addChild(yueqianLayer, 1)
		
	elseif showType == nbActivityShowType.DengjiTouzi then
		print("-------------------->等级投资<----------------------")
		self._showType = showType
		self._contentNode:removeAllChildrenWithCleanup(true)
		local touziLayer = require("game.nbactivity.DengjiTouzi.DengjiTouziLayer").new({
		viewSize = viewSize
		})
		touziLayer:setPosition(display.cx, self:getBottomHeight())
		self._contentNode:addChild(touziLayer, 1)
	elseif  showType == nbActivityShowType.DialyActivity then
		self._showType = showType
		self._contentNode:removeAllChildrenWithCleanup(true)
		local bng = display.newSprite("bg/duobao_bg.jpg")
		bng:setScale(display.height/bng:getContentSize().height)
		bng:setAnchorPoint(cc.p(0,0))
		self._contentNode:addChild(bng)
		RequestHelper.dialyTask.getTaskList({
		callback = function (data, err)
			dump(data)
			if err ~= "" then
				dump(err)
			else
				local layer = require("game.nbactivity.Huodong.TaskPopup").new(data,self,viewSize)
				layer:setAnchorPoint(cc.p(0.5,0))
				layer:setPosition(0, self:getBottomHeight())
				self._contentNode:addChild(layer,1)
			end
		end
		})
	elseif  showType == nbActivityShowType.chongwuchouka then
		self._showType = showType
		self._contentNode:removeAllChildrenWithCleanup(true)
		local petChouKaLayer = require("game.nbactivity.ChongwuChouKa.ChongwuChouKaLayer").new(viewSize)
		petChouKaLayer:align(display.CENTER_BOTTOM, display.cx, self:getBottomHeight())
		self._contentNode:addChild(petChouKaLayer, 1)
	elseif showType == nbActivityShowType.creditShop then
		self._showType = showType
		self._contentNode:removeAllChildrenWithCleanup(true)
		local creditShopLayer = require("game.nbactivity.Credit.CreditShop").new({viewSize = viewSize})
		creditShopLayer:setPosition(0, self:getBottomHeight())
		self._contentNode:addChild(creditShopLayer, 1, 111)
	end
	
	if self._showType == showType then
		self._cellIndex = cellIndex
		for i = 0, #self._listView.items_ - 1 do
			local item = self._listView.items_[i + 1]
			item = item:getContent()
			if item ~= nil then
				if self._cellIndex == i then
					item:setSelected(true)
				else
					item:setSelected(false)
				end
			end
		end
		
		local cellContentSize = require("game.nbactivity.ActivityItem").new():getContentSize()
		-- 当前每页显示的个数	
		local pageCount = (self._listView:getViewRect().width) / cellContentSize.width
		local maxMove = #self._listView.items_ - pageCount
		local curIndex = 0
		local tmpCount = self._cellIndex + 1
		if tmpCount > pageCount then
			curIndex = tmpCount - pageCount
		end
		
		if curIndex > maxMove then
			curIndex = maxMove
		end
		
		if self.firstEnter then
			-- 刷新 精彩活动 顶部 icon位置
			if (#self._listView.items_ > pageCount ) then
				--self._listView:scrollTo(-3 * cellContentSize.width, 0)
				self._listView:scrollTo(cc.p((-curIndex * cellContentSize.width), 0))
				--self._listView:setContentOffset(CCPoint((-curIndex * cellContentSize.width), 0))
			end
			self.firstEnter = false
		end
	end
end

function ActivityScene:createLeijiRewardData(listData)
	
	local tmpRewardDatas = {}
	local rewardDatas = {}
	
	for j, d in pairs(listData) do
		local itemData = {}
		for i, v in ipairs(d) do
			local itemType = v.t
			local itemId = v.id
			local itemNum = v.n
			
			local iconType = ResMgr.getResType(v.t)
			local itemInfo
			
			if iconType == ResMgr.HERO then
				itemInfo = ResMgr.getCardData(itemId)
			else
				itemInfo = data_item_item[itemId]
			end
			
			table.insert(itemData, {
			id = itemId,
			type = itemType,
			num = itemNum or 0,
			name = itemInfo.name,
			describe = itemInfo.describe or "",
			iconType = iconType
			})
		end
		table.insert(tmpRewardDatas, {
		day = checkint(j),
		itemData = itemData
		})
	end
	
	for i = 1, #tmpRewardDatas do
		for k, v in ipairs(tmpRewardDatas) do
			if v.day == i then
				table.insert(rewardDatas, v)
				break
			end
		end
	end
	
	return rewardDatas
	
end

return ActivityScene