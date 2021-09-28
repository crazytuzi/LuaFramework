RankContent = BaseClass(LuaUI)

function RankContent:__init(...)
	self.URL = "ui://7dvfcqznygx0r";
	self:__property(...)
	self:Config()
end

function RankContent:SetProperty(...)
	
end

function RankContent:Config()
	
end

function RankContent:RegistUI(ui)
	self.ui = ui or self.ui or UIPackage.CreateObject("Rank","RankContent");

	self.listBg = self.ui:GetChild("listBg")
	self.headBg = self.ui:GetChild("headBg")
	self.list = self.ui:GetChild("list")
	self.headContainer = self.ui:GetChild("headContainer")
	self.n23 = self.ui:GetChild("n23")
	self.tipsBtn = self.ui:GetChild("tipsBtn")
	self.n14 = self.ui:GetChild("n14")
	self.myRank = self.ui:GetChild("myRank")
	self.n16 = self.ui:GetChild("n16")
	self.myRankInfo = self.ui:GetChild("myRankInfo")
	self.head2 = self.ui:GetChild("head2")
	self.head1 = self.ui:GetChild("head1")
	self.head3 = self.ui:GetChild("head3")
	self.n21 = self.ui:GetChild("n21")

	self.head1 = RankHead.Create(self.head1)
	self.head2 = RankHead.Create(self.head2)
	self.head3 = RankHead.Create(self.head3)
	self.descTips = nil

	self.colNameList = {}
	self.contentItemList = {}
	self.rankType = -1
	self.reqLocking = false
	self.rankListWidth  = self.list.width
	self.reqedPageDic = {}
	self.curPage = 0
	self.curBigType = 0
	self.curSmallType = 0

	self.data = RankModel:GetInstance():GetTabCfgData()
	self.rankTabBtns = Accordion.New()
	self.rankTabBtns:SetData(self.data, function(selectData)
		local change = true
		if tonumber(selectData[1]) == self.curBigType and tonumber(selectData[2]) == self.curSmallType then
			change = false
		end
		if change then
			self.curBigType = tonumber(selectData[1])
			self.curSmallType = tonumber(selectData[2])
			self:ChangeTab()
		end
	end, 1, 0)
	self.rankTabBtns:SetXY(140, 120)
	self.rankTabBtns:AddTo(self.ui)
	--self:SetDefault()

	self:AddEvent()
end

function RankContent:AddEvent()
	self.updateHandler = RankModel:GetInstance():AddEventListener(RankConst.UpdateRankData, function (data) self:RefreshContent(data) end)
	self.selectHandler = RankModel:GetInstance():AddEventListener(RankConst.SelectRankItem, function (data) self:OnSelectItemHandler(data) end)

	self.list.scrollPane.onScrollEnd:Add(self.OnScrollEndHandler, self)

	-- self.tipsBtn.onClick:Add(function(e)
	-- 	self:ShowDescPanel(e)
	-- end)
	self.tipsBtn.onClick:Add(self.OnBtnShowDescClick , self)
end

function RankContent:RemoveEvent()
	RankModel:GetInstance():RemoveEventListener(self.updateHandler)
	RankModel:GetInstance():RemoveEventListener(self.selectHandler)

	self.list.scrollPane.onScrollEnd:Remove(self.OnScrollEndHandler, self)
end

-- function RankContent:ShowDescPanel(context)
-- 	local pos = layerMgr:GetUILayer():GlobalToLocal(Vector2(Stage.inst.touchPosition.x, Stage.inst.touchPosition.y))
-- 	local descPanel = DescPanel.New()
-- 	descPanel:SetContent(1)
-- 	UIMgr.ShowPopup(descPanel, false, 0, 0, function()
-- 		UIMgr.HidePopup()
-- 	end)
-- end

function RankContent:OnBtnShowDescClick()
	if self.descTips == nil then
		self.descTips = DescPanel.New()
	end
	self.descTips:SetContent(1)

	UIMgr.ShowPopup(self.descTips, false, 0, 0, function()
		if self.descTips ~= nil then
			UIMgr.HidePopup(self.descTips.ui)
			self.descTips = nil
		end
	end)
end

function RankContent:ChangeTab()
	self:Reset()
	self:ReqPageData(self.curPage)
end

function RankContent:ReqPageData(reqPage)
	self.reqLocking = true
	local pageSize = RankModel:GetInstance().pageSize
	local startIndex = (reqPage - 1)*pageSize + 1
	RankController:GetInstance():ReqGetRankList(self.curBigType, self.curSmallType, startIndex, pageSize)
end

function RankContent:SetDefault()
	self.curBigType = 1
	self.curSmallType = 0
	self:ReqPageData(1)
end

function RankContent:Reset()
	self.curPage = 1
	self.reqedPageDic = {}
	self:ClearContent()
	self.head1:ShowEmpty()
	self.head2:ShowEmpty()
	self.head3:ShowEmpty()
end

function RankContent:OnScrollEndHandler(contenxt)
	if contenxt.sender.isBottomMost and not self.reqLocking then
		local reqPage = self.list.numItems / RankModel:GetInstance().pageSize + 1      --self.curPage+++++												 
		if self.reqedPageDic[reqPage] == nil then
			self:ReqPageData(reqPage)
		end
	end
end

function RankContent:RefreshContent(data)
	local changeType = tonumber(data[1]) ~= self.rankType
	self.rankType = tonumber(data[1])
	self.data = data[2]

	self:SetRankColsHead(changeType)
	local infoTxt = ""
	if self.rankType == RankModel.Type.Battle then
		infoTxt = "我的战力"
	elseif self.rankType == RankModel.Type.Equip then
		infoTxt = "我的神兵"
	elseif self.rankType == RankModel.Type.Gold then
		infoTxt = "我的财富"
	end 
	self.rankList = self.data.rankList
	self.index = 1

	if self.data.myRank ~= 0 then
		self.myRank.text = StringFormat("我的排名:{0}", self.data.myRank)
	else
		self.myRank.text = "我的排名:未上榜"
	end

	if self.data.myValue ~= 0 then
		self.myRankInfo.text = infoTxt..":"..self.data.myValue
	else
		self.myRankInfo.text = infoTxt..":0"
	end
	self:SetTop3Info(self.rankList)
	RenderMgr.Add(function () self:RefreshContentInFrame() end, "RankContent:RefreshContentInFrame")
end

function RankContent:SetRankColsHead(reset)
	if reset then
		while self.headContainer.numChildren > 0 do
			self.headContainer:RemoveChildAt(0)
		end
		local cols = RankModel:GetInstance():GetRankCols(self.rankType)
		local cellWidth = self.rankListWidth / #cols
		local cellHeight = 38
		local x = 0
		local y = (60 - 38)*0.5
		for i = 1, #cols do
			local colHeadCell = self:GetColNameComFromPool()
			colHeadCell:GetChild("name").text = RankModel:GetInstance():GetColName(cols[i])
			colHeadCell.width = cellWidth
			colHeadCell.x = x 
			colHeadCell.y = y 
			x = x + cellWidth
			self.headContainer:AddChild(colHeadCell)
		end
	end
end

function RankContent:SetTop3Info(rankData)
	for i = 1, #rankData do
		if rankData[i].rank == 1 then
			self.head1:SetData(rankData[i])
		end
		if rankData[i].rank == 2 then
			self.head2:SetData(rankData[i])
		end
		if rankData[i].rank == 3 then
			self.head3:SetData(rankData[i])
		end
	end
end

function RankContent:RefreshContentInFrame()
	if self.index <= #self.rankList then
		local item = self:GetRankItemFromPool()
		item:Refresh(self.rankList[self.index], RankModel:GetInstance():GetRankCols(self.rankType))
		self.list:AddChild(item.ui)
		self.index = self.index + 1
	else
		RenderMgr.Remove("RankContent:RefreshContentInFrame")
		self.data = nil
		self.index = nil
		self.reqLocking = false
		self.list.scrollPane:ScrollBottom()

		--计算当前显示的是第几页
		local integer, decimals = math.modf(self.list.numItems / RankModel:GetInstance().pageSize)
		if self.list.numItems % RankModel:GetInstance().pageSize == 0 then
			self.curPage = self.list.numItems / RankModel:GetInstance().pageSize
		else
			self.curPage = integer + 1
		end
		self.reqedPageDic[self.curPage] = true
	end
end

function RankContent:GetColNameComFromPool()
	for i = 1, #self.colNameList do
		if self.colNameList[i].parent == nil then
			return self.colNameList[i]
		end
	end
	local colNamCom = UIPackage.CreateObject("Rank", "RankColName")
	table.insert(self.colNameList, colNamCom)
	return colNamCom
end

function RankContent:DestoryColNamePool()
	-- while self.headContainer.numChildren > 0 do
	-- 	local obj = self.headContainer:RemoveChildAt(0)
	-- 	destroyUI(obj)
	-- end
	-- self.ui:RemoveChild(self.headContainer)
	-- destroyUI(self.headContainer)
	self.colNameList = nil
end

function RankContent:GetRankItemFromPool()
	for i = 1, #self.contentItemList do
		if self.contentItemList[i].ui.parent == nil then
			return self.contentItemList[i]
		end
	end
	local item = UIPackage.CreateObject("Rank", "RankItem")
	item = RankItem.Create(item)
	table.insert(self.contentItemList, item)
	return item
end

function RankContent:DestoryRankItemPool()
	for i = 1, #self.contentItemList do
		self.contentItemList[i]:Destroy() 
	end
	self.contentItemList = {}
end

function RankContent:ClearContent()
	RankItem.CurSelectItem = nil
	self.list:RemoveChildren()
	for i = 1, #self.contentItemList do
		self.contentItemList[i]:Reset()
	end
end

function RankContent:ClearDescTips()
	self.descTips = nil
end

function RankContent.Create(ui, ...)
	return RankContent.New(ui, "#", {...})
end

function RankContent:__delete()
	self:RemoveEvent()
	self.head1:Destroy()
	self.head2:Destroy()
	self.head3:Destroy()
	
	self:DestoryColNamePool()
	self:DestoryRankItemPool()

	self.rankTabBtns:Destroy()
	self.rankTabBtns = nil

	self.head1 = nil
	self.head2 = nil
	self.head3 = nil
	self.reqedPageDic = nil
	self.updateHandler = nil

	self:ClearDescTips()
end