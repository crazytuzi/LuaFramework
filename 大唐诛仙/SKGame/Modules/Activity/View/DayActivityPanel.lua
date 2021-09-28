DayActivityPanel = BaseClass(CommonBackGround)

function DayActivityPanel:__init( ... )
	self.id = "DayActivityPanel"
	self.bgUrl = "bg_big1"
	self:SetTitle("活 动")
	self.showBtnClose = true
	self.openTopUI = true
	self.openResources = {1, 2}
	self.useCache = false -- 缓存窗口

	self.ui = UIPackage.CreateObject("Activity","DayActivityPanel");

	self.list = self.ui:GetChild("list")
	self.desc = self.ui:GetChild("desc")
	self.name = self.ui:GetChild("name")
	self.weekBtn = self.ui:GetChild("weekBtn")
	self.signBtn = self.ui:GetChild("signBtn")
	self.signBtn.visible = false

	self.rewardContanier = GComponent.New()
	self.rewardContanier.x = self.name.x + 110
	self.rewardContanier.y = self.name.y - 10
	self.ui:AddChild(self.rewardContanier)

	self.contentItemList = {}
	self.creatList = {}
	self.listData = nil
	self.index = 1
	self.curShowData = nil
	self.showType = 1 --1:普通 2:限时

	-- 标签
	local res0 = UIPackage.GetItemURL("Common","btn_fenye1")
	local res1 = UIPackage.GetItemURL("Common","btn_fenye2")
	local tabDatas = {
		{label="每日任务", res0=res0, res1=res1, id="0", red=false}, 
		{label="限时任务", res0=res0, res1=res1, id="1", red=false},
	}
	local offX, offY = 150, 120

	self.btn1ClickFirst = true
	local btn1Click = function()
		self:ShowNormal()
	end
	local btn2Click = function()
		self:ShowLimit()
		GlobalDispatcher:DispatchEvent(EventName.MAINUI_RED_TIPS, {moduleId = FunctionConst.FunEnum.activity , state = false })
		self:RefershDayLimitActivityRedTips(false)
		ActivityModel:GetInstance():SetLastShowRedTipsFlag(false)
	end
	local function tabClickCallback( idx, id )
		if id == "0" then
			btn1Click()
		elseif id == "1" then
			btn2Click()
		end
	end
	local ctrl, tabs = CreateTabbar(self.ui, 1, tabClickCallback, tabDatas, offX, offY, 0, 200, 200, 52)

	self.giftList = {}

	self:ToCreate()
	self:AddEvent()

	self.weekActivityPanel = nil
	self.tabs = tabs
	self:RefershDayLimitActivityRedTips(ActivityModel:GetInstance():GetLastShowRedTipsFlag())
end

function DayActivityPanel:ToCreate()

end

function DayActivityPanel:AddToCreateList(gui)
	table.insert(self.creatList, gui)
end

function DayActivityPanel:DestroyCreate()
	destroyUIList(self.creatList)
	self.creatList = {}
end

function DayActivityPanel:AddEvent()
	self.weekBtn.onClick:Add(self.OnWeekBtnClickHandler, self)

	self.selectHandler = ActivityModel:GetInstance():AddEventListener(ActivityConst.SelectActivityItem, function (data) self:OnSelectItemHandler(data) end)
	self.handler1 = GlobalDispatcher:AddEventListener(EventName.RefershDayLimitActivityRedTips , function(isNeedShow) self:RefershDayLimitActivityRedTips(isNeedShow) end)
end


function DayActivityPanel:RemoveEvent()
	self.weekBtn.onClick:Remove(self.OnWeekBtnClickHandler, self)

	ActivityModel:GetInstance():RemoveEventListener(self.selectHandler)

	GlobalDispatcher:RemoveEventListener(self.handler1)
end

function DayActivityPanel:OnSelectItemHandler(data)
	self.curShowData = data
	
	self:ShowInfo()
end

function DayActivityPanel:ShowInfo()
	while self.rewardContanier.numChildren > 0 do
		self.rewardContanier:RemoveChildAt(0)
	end
	self.desc.text = StringFormat("[color=#2e3341]活动描述：[/color]".."[color=#2e3341]{0}[/color]", self.curShowData.des)
	for i,v in ipairs(self.giftList) do
		v:Destroy()
	end
	self.giftList = {}

	for i = 1, #self.curShowData.reward do
		local iconData = self.curShowData.reward[i]
		local icon = PkgCell.New(self.rewardContanier)
		icon:SetXY(100*(i - 1), 0)	
		icon:OpenTips(true)
		icon:SetDataByCfg(iconData[1], iconData[2], iconData[3], 0)
		self.giftList[i] = icon
	end
end

function DayActivityPanel:Refresh()
	if self.showType == 1 then
		self:ShowNormal()
	else
		self:ShowLimit()
	end
end

function DayActivityPanel:ShowNormal()
	self.showType = 1
	self:ClearContent()

	self.listData = ActivityModel:GetInstance():GetDayNormalActivity()
	self.index = 1
	RenderMgr.Add(function () self:RefreshContentInFrame() end, "DayActivityPanel:RefreshContentInFrame")
end

function DayActivityPanel:ShowLimit()
	self.showType = 2
	self:ClearContent()

	self.listData = ActivityModel:GetInstance():GetDayLimitActivity()
	self.index = 1
	
	RenderMgr.Add(function () self:RefreshContentInFrame() end, "DayActivityPanel:RefreshContentInFrame")
end

function DayActivityPanel:RefreshContentInFrame()
	if self.index <= #self.listData then
		local item = self:GetActivityItemFromPool()
		item:Update(self.listData[self.index])
		self.list:AddChild(item.ui)
		if self.index == 1 then
			item:Select()
		end
		self.index = self.index + 1
	else
		RenderMgr.Realse("DayActivityPanel:RefreshContentInFrame")
		self.data = nil
		self.index = nil
	end
end

function DayActivityPanel:GetActivityItemFromPool()
	for i = 1, #self.contentItemList do
		if self.contentItemList[i].ui.parent == nil then
			return self.contentItemList[i]
		end
	end
	local item = UIPackage.CreateObject("Activity", "ActivityItem")
	item = ActivityItem.Create(item)
	table.insert(self.contentItemList, item)
	return item
end

function DayActivityPanel:DestoryActivityItemPool()
	if not self.contentItemList then return end
	for i = 1, #self.contentItemList do
		self.contentItemList[i]:Destroy() 
	end
	self.contentItemList = nil
end

function DayActivityPanel:ClearContent()
	ActivityItem.CurSelectItem = nil
	self.list:RemoveChildren()
	for i = 1, #self.contentItemList do
		self.contentItemList[i]:Reset()
	end

	while self.rewardContanier.numChildren > 0 do
		self.rewardContanier:RemoveChildAt(0)
	end
end

function DayActivityPanel:OnWeekBtnClickHandler()
	if self.weekActivityPanel == nil or not self.weekActivityPanel.Inited then
		self.weekActivityPanel = WeekActivityPanel.New()
	end
	self.weekActivityPanel:Open()
end

-- 关闭
function DayActivityPanel:Close()
	RenderMgr.Realse("DayActivityPanel:RefreshContentInFrame")
	CommonBackGround.Close(self)
	if self.weekActivityPanel then
		self.weekActivityPanel:Close()
		self.weekActivityPanel = nil
	end
end

function DayActivityPanel:Layout()
	self.container:AddChild(self.ui) -- 不改动，注意自行设置self.ui位置
end


function DayActivityPanel:RefershDayLimitActivityRedTips(isNeedShow)
	if isNeedShow ~= nil then
		if self.tabs then
			SetTabRedTips(self.tabs , "1" , isNeedShow)
		end
	end
end

-- Dispose use DayActivityPanel obj:Destroy()
function DayActivityPanel:__delete()
	self:DestoryActivityItemPool()
	self:DestroyCreate()
	self:RemoveEvent()
	if self.rewardContanier then
		destroyUI(self.rewardContanier)
		self.rewardContanier = nil
	end
	if self.giftList then
		for i,v in ipairs(self.giftList) do
			v:Destroy()
		end
		self.giftList = nil
	end
	if self.weekActivityPanel and self.weekActivityPanel.Inited then
		self.weekActivityPanel:Destroy()
	end
	self.weekActivityPanel = nil
	RenderMgr.Realse("DayActivityPanel:RefreshContentInFrame")
	self.creatList = nil
	self.curShowData = nil
	self.tabs = nil
end