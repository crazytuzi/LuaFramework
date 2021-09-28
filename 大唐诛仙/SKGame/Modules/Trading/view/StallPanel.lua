-- 寄  售
StallPanel = BaseClass()
function StallPanel:__init(root)
	self.ui = UIPackage.CreateObject("Trading","StallPanel")
	
	self.c1 = self.ui:GetController("c1") -- 控制显示 购买 ｜ 寄售面板切换
	self.tabLayer = self.ui:GetChild("tabLayer") -- 标签容器

	-- 购买
	self.buyGroup = self.ui:GetChild("buyGroup")
	self.sortBg = self.ui:GetChild("sortBg")
	self.line = self.ui:GetChild("line")
	self.sortConn = self.ui:GetChild("sortConn")  -- 筛选容器
	self.tabConn = self.ui:GetChild("tabConn") -- 类型容器
	
	self.itemConn = self.ui:GetChild("itemConn") -- 商品列表容器

	-- 寄售
	self.sellGroup = self.ui:GetChild("sellGroup")
	self.cellConn = self.ui:GetChild("cellConn") -- 格子容器
	self.gridConn = self.ui:GetChild("gridConn") -- 摊位容器

	root:AddChild(self.ui)
	self:SetXY(143, 111)
	self:Config()
	self:Layout()
	self:InitEvent()
	-- debugDrag(self)
end
function StallPanel:Config()
	self.model = TradingModel:GetInstance()
	self.curSelectedItem = nil
	self.curSelectedCell = nil
	self.curSelectedShelf = nil

	self.sortBars = {}
	self.curSort = {0, 0, 0} -- 0升序，1降序
	self.items = {}
	self.curItemsList = {}

	self.shelfs = {}
	self.cells = {}

	self.bigType = self.model.bigType2 or 0
	self.subType = self.model.subType2 or 0

	self.pkgSelected = nil
	self.shelfSelected = nil

end
function StallPanel:InitEvent()
	self.itemConn.scrollPane.inertiaDisabled = false
	self.itemConn.scrollPane.onScrollEnd:Add(function (e)
		if e.sender.isBottomMost then
			self:ReqBuyData() -- 请求货架物品
		end
	end)
	
	self.handle1 = self.model:AddEventListener(TradingConst.STALL_MY_CHANGED, function ()
		self:UpdateShelf() -- 我的货架变化
	end)
	self.handle2 = self.model:AddEventListener(TradingConst.STALL_PKG_CHANGED, function ()
		self:UpdatePkg() -- 我的背包变化
	end)
	self.handle3 = self.model:AddEventListener(TradingConst.STALL_SYS_CHANGED, function ()
		self:Update() -- 购买列表变化
	end)
	self.handle4 = self.model:AddEventListener(TradingConst.SHELF_NUM_CHANGE, function ()
		self:OpenShelf() -- 扩展货架
	end)

	if not self.handle5 then
		self.handle5 = GlobalDispatcher:AddEventListener(TradingConst.STALL_BUY, function ()
			if not self.ui or not self.ui.visible or not self.curSelectedItem then return end
			local obj = self.curSelectedItem
			TradingAlertPanel.ShowI(obj.data, obj.data.num, function (data,num)
				if not data or not num or num == 0 then return end
				TradingController:GetInstance():C_TradeBuy(data.id, num)
			end)
		end) -- 寄售购买提示事件
	end
	if not self.handle6 then
		self.handle6 = GlobalDispatcher:AddEventListener(TradingConst.STALL_PUTON, function ()
			if not self.ui or not self.ui.visible then return end
			local obj = self.curSelectedCell
			if not obj or not obj.data then return end
			if obj and obj.data and obj.data:GetCfgData() and obj.data:GetCfgData().isTrade ~= 1 then print("不可出售") return end
			TradingAlertPanel.ShowII(obj.data, obj.data.num, function (data, num, price)
				if num == 0 or price == 0 then print("出售操作有误!") return end
				TradingController:GetInstance():C_TradeSell(data.id, num, price)
			end)
		end) -- 上架提示事件
	end
	if not self.handle7 then
		self.handle7 = GlobalDispatcher:AddEventListener(TradingConst.STALL_PUTOFF, function ()
			if not self.ui or not self.ui.visible or not self.curSelectedShelf then return end
			local obj = self.curSelectedShelf
			if obj.data then
				TradingController:GetInstance():C_OffShelf(obj.data.id)
			end
		end) -- 下架提示事件
	end
	if not self.handle8 then
		--重新上架
		self.handle8 = GlobalDispatcher:AddEventListener(TradingConst.STALL_RE_PUTON, function ()
			if not self.ui or not self.ui.visible then return end
			local obj = self.curSelectedShelf
			if not obj or not obj.data then return end
			if obj and obj.data and obj.data:GetCfgData() and obj.data:GetCfgData().isTrade ~= 1 then print("不可出售") return end
			local data = obj.data
			local num = data.num or 1
			local price = 0
			if data.cfg then
				price = data.cfg.tradeInitPrice or data.cfg.tradeMinPrice
			else
				price = data.price
			end
			local player = SceneModel:GetInstance():GetMainPlayer()
			if player then
				if player.gold >= price * num * TradingConst.Fee[2] then
					TradingController:C_ReUpShelf(data.id)
				else
					Message:GetInstance():TipsMsg("金币不足")
				end
			end
		end)
	end
end
function StallPanel:Layout()
-- 购买
	local accordion = Accordion.New()
	accordion:AddTo(self.tabConn)
	accordion:SetXY(4, 0)
	self.accordion = accordion
	accordion:SetData( TradingConst.stallTabs, function ( selectData )
		if self.subType == selectData[2] or not selectData[2] then return end
		self.bigType = selectData[1]
		self.subType = selectData[2]
		if self.curSelectedItem then
			self.curSelectedItem:SetSelected(false)
			self.curSelectedItem = nil
		end
		
		self.model:ResetSysItems() -- 清空数据再请求
		for i,v in ipairs(self.items) do
			v:Destroy()
		end
		self.items = {}
		self.curItemsList = {}
		self:ReqBuyData()
	end)
	self.accordion:SetSelect(self.bigType, self.subType)

	local res0 = UIPackage.GetItemURL("Common", "paixu_00")
	local res1 = UIPackage.GetItemURL("Common", "paixu_01")
	local icon0 = "Icon/Other/arrow_01"
	local icon1 = "Icon/Other/arrow_11"
	local labels = {"等级", "价格", "品质"}
	for i=1,3 do
		local bar = UIPackage.CreateObject("Common" , "CustomCheckBox0")
		bar:GetChild("layer0").url = res0
		bar:GetChild("layer1").url = res1
		bar:GetChild("icon0").url = icon0
		bar:GetChild("icon1").url = icon1
		bar:GetChild("icon0"):SetXY(98,12)
		bar:GetChild("icon1"):SetXY(98,12)
		bar.title = labels[i]
		bar:SetSize(132, 42)
		self.sortConn:AddChild(bar)
		bar.x = (i-1)*148
		bar.y = 0
		bar.data=0
		self.curSort[i] = bar.data
		bar.onClick:Add(function ()
			bar.data = bar.data == 0 and 1 or 0
			self.curSort[i] = bar.data
			self:Update()
		end)
		self.sortBars[i] = bar
	end

-- 寄售
	local defaultNum = TradingConst.TotalShelf
	local rowNum = 2
	for i=1,defaultNum do
		local shelf = self.shelfs[i]
		if not shelf then
			shelf = TradingItem.New(TradingConst.itemType.shelf) -- 下架
			self.shelfs[i] = shelf
			if i > self.model.shelfNum then
				shelf:SetLock(1)
			else
				shelf:SetLock(0)
			end
			shelf:SetCallback(function ( obj )
				if not obj then return end
				if obj.isLock then
					UIMgr.Win_Confirm("提示", getRichTextContent(StringFormat("您确定花费{1}个[img=42,42]Icon/Goods/{0}[/img]\n开启一个货架吗？", 
						GoodsVo.GoodIcon[TradingConst.OpenStallGridPrice[1]], 
						TradingConst.OpenStallGridPrice[2])), "确定", "取消", function()
							TradingController:GetInstance():C_ExtendGrid() -- 开启货架
						end, nil)
				else
					if obj ~= self.curSelectedShelf then
						if self.curSelectedShelf then
							self.curSelectedShelf:SetSelected(false)
						end
						self.curSelectedShelf = obj
						obj:SetSelected(true)
					end
				end
			end)
			shelf:SetXY(math.floor((i-1)%rowNum)*370+2,math.floor((i-1)/rowNum)*118)
			shelf:AddTo(self.gridConn)
		end
	end
	defaultNum = TradingConst.PkgNum
	for i=1,defaultNum do
		local cell = self.cells[i]
		if not cell then
			cell = PkgCell.New(self.cellConn, nil, nil)
			self.cells[i] = cell
			cell:SetXY(math.floor((i-1)%rowNum)*92+8,math.floor((i-1)/rowNum)*92)
			cell:SetTipsType(TradingConst.itemType.pkgStall)
		end
		self.cells[i] = cell
	end

-- 总标签
	res0 = UIPackage.GetItemURL("Common","btn_fenye1")
	res1 = UIPackage.GetItemURL("Common","btn_fenye2")
	local tabDatas = {
		{label="购买", res0=res0, res1=res1, id=TradingConst.stallTabType.buy, red=false}, 
		{label="寄售", res0=res0, res1=res1, id=TradingConst.stallTabType.sell, red=false}
	}
	local function tabClickCallback( idx, id )
		if id == TradingConst.stallTabType.buy then -- 购买
			self.c1.selectedIndex = 0
			self.model:RemoveStallEvent()
		else 									-- 寄售货架
			self.c1.selectedIndex = 1
			self.model:ListenStallEvent()
			self.model:UpdatePkgData()-- 同步个人背包数据
		end
		self:Update()
	end
	ctrl, tabs =  CreateTabbar(self.tabLayer, 1, tabClickCallback, tabDatas, 100, 6, 0, 130, 124, 50)
	self.tabCtrl = ctrl
	self.tabs = tabs
	-- debugDrag(accordion)
end
-- 请求货架上购买列表数据
function StallPanel:ReqBuyData()
	local itemNum = #self.curItemsList
	--if self.subType and self.subType ~= 0 and self.subType < 10 then
	if self.subType and self.subType >= 0 and self.subType < 10 then
		TradingController:GetInstance():C_GetTradeList(1, self.subType, itemNum+1) -- 装备类
	else
		TradingController:GetInstance():C_GetTradeList(2, self.subType, itemNum+1) -- 道具类
	end
end
-- 检测有无默认选择标签
function StallPanel:CheckDefaultSelectTabType()
	if self.model.stallTabType then
		local idx = tonumber(self.model.stallTabType)
		self.tabCtrl.selectedIndex = idx or self.c1.selectedIndex
		self.model.stallTabType = nil
	end
end
-- 更新
function StallPanel:Update()
	local model = self.model
	local dataLists = {}
	if self.c1.selectedIndex == 0 then
		local vo = nil
		local item = nil
		self.curItemsList = {} -- 存在列表
		dataLists = model:GetSysItems()
		SortTableBy3Key( dataLists, "level", "price", "rare", self.curSort[1]==0, self.curSort[2]==0, self.curSort[3]==0 )
		for _,v in ipairs(self.items) do
			v:RemoveFromParent()
		end
		for i=1,#dataLists do
			vo = dataLists[i]
			item = self.items[i]
			if not item then
				item = TradingItem.New(TradingConst.itemType.sysSell) -- 购买
				self.items[i] = item
				item:SetCallback(function ( obj )
					if not obj or not obj.data then return end
					if obj ~= self.curSelectedItem then
						if self.curSelectedItem then
							self.curSelectedItem:SetSelected(false)
						end
						self.curSelectedItem = obj
						obj:SetSelected(true)
					end
				end)
			end
			item:SetXY(math.floor((i-1)%2)*370+2,math.floor((i-1)/2)*118)
			item:AddTo(self.itemConn)
			item:Update(vo.data)
			table.insert(self.curItemsList, item)
		end
		dataLists = nil
	else								-- 寄售
		self:UpdatePkg()
		self:UpdateShelf()
	end
end
-- 更新背包
function StallPanel:UpdatePkg()
	local model = self.model
	local dataLists = model:GetPkgItems()
	local function selectCallback( obj )
		if obj and self.curSelectedCell ~= obj then
			if self.curSelectedCell then
				self.curSelectedCell:SetSelected(false)
			end
			self.curSelectedCell = obj
			obj:SetSelected(true)
		end
	end
	local i = 1
	for _,v in pairs(dataLists) do
		local cell = self.cells[i]
		if not cell then
			cell = PkgCell.New(self.cellConn, nil, nil)
			self.cells[i] = cell
			cell:SetXY(math.floor((i-1)%2)*92+8,math.floor((i-1)/2)*92)
		end
		self.cells[i] = cell
		cell:SetData(v)
		cell:SetSelectCallback( selectCallback )
		cell:SetTipsType(TradingConst.itemType.pkgStall) -- 上架
		i=i+1
	end
	for j=i, #self.cells do
		self.cells[j]:SetData( nil )
	end
end
-- 更新货架
function StallPanel:UpdateShelf()
	local model = self.model
	local dataLists = model:GetMyItems()
	local shelf = nil
	local i = 1
	for _,v in pairs(dataLists) do
		shelf = self.shelfs[i]
		shelf:Update(v)
		i = i + 1
	end
	local k = 0
	for j=i,#self.shelfs do
		if not self.shelfs[j].isLock and self.shelfs[j].data then
			self.shelfs[j]:Update(nil)
			if self.curSelectedShelf == self.shelfs[j] then
				self.curSelectedShelf:SetSelected(false)
				self.curSelectedShelf = nil
			end
			k = k + 1
		end
	end
end

-- 扩展货架
function StallPanel:OpenShelf()
	local shelf = self.shelfs[self.model.shelfNum]
	if shelf then
		shelf:SetLock(0)
	end
end
-- 切换面板时的开关显示
function StallPanel:SetVisible( bool )
	self.ui.visible = bool
	local model = self.model
	if bool then
		self:CheckDefaultSelectTabType()
		if self.c1.selectedIndex == 1 then
			model:ListenStallEvent()
			model:UpdatePkgData()
		end
		if self.bigType ~= model.bigType2 or self.subType ~= model.subType2 then 
			local result = self.accordion:SetSelect(model.bigType2, model.subType2)
			if result then
				model.bigType2 = nil
				model.subType2 = nil
			end
		end
		local itemNum = #self.curItemsList or 0
		if itemNum < math.floor(TradingConst.Offset*0.5) then
			if self.subType and self.subType >= 0 and self.subType < 10 then
				--TradingController:GetInstance():C_GetTradeList(1, self.subType, itemNum+1) -- 装备类
				TradingController:GetInstance():C_GetTradeList(1, self.subType, 1) -- 装备类
			else
				TradingController:GetInstance():C_GetTradeList(2, self.subType, itemNum+1) -- 道具类
			end
		end
	else
		model:RemoveStallEvent()
	end
end
function StallPanel:SetXY(x, y)
	self.ui:SetXY(x, y)
end
function StallPanel:__delete()
	if self.model then
		self.model:RemoveEventListener(self.handle1)
		self.model:RemoveEventListener(self.handle2)
		self.model:RemoveEventListener(self.handle3)
		self.model:RemoveEventListener(self.handle4)
		self.model:ResetTradingData()
	end
	GlobalDispatcher:RemoveEventListener(self.handle5)
	GlobalDispatcher:RemoveEventListener(self.handle6)
	GlobalDispatcher:RemoveEventListener(self.handle7)
	GlobalDispatcher:RemoveEventListener(self.handle8)

	for i,v in ipairs(self.items) do
		v:Destroy()
	end
	for i,v in ipairs(self.shelfs) do
		v:Destroy()
	end
	for i,v in ipairs(self.cells) do
		v:Destroy()
	end
	self.items = nil
	self.shelfs = nil
	self.cells = nil
	self.model:RemoveStallEvent()
	self.accordion:Destroy()
	self.accordion = nil
	self.curSelectedItem=nil
	self.curSelectedCell=nil
	self.curSelectedShelf=nil
	for i,v in ipairs(self.sortBars) do
		destroyUI( v )
	end
	self.sortBars = nil
end