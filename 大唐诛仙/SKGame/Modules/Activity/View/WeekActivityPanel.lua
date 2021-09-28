WeekActivityPanel = BaseClass(CommonBackGround)

function WeekActivityPanel:__init( ... )
	self.id = "DayActivityPanel"
	self.bgUrl = "bg_big1"
	self:SetTitle("周活动")
	self.showBtnClose = true
	self.openTopUI = true
	self.openResources = {1, 2}
	-- self.isOnOtherClose = false
end

function WeekActivityPanel:ToCreate()
	self.banner = WeekTop.Create(self.banner)
	self:AddToCreateList(self.banner)
end

function WeekActivityPanel:AddToCreateList(gui)
	table.insert(self.creatList, gui)
end

function WeekActivityPanel:DestroyCreate()
	destroyUIList(self.creatList)
	self.creatList = {}
end

function WeekActivityPanel:AddEvent()
	-- self.ui.onClick:Add(self.OnClickHandler, self)
end

function WeekActivityPanel:RemoveEvent()
	-- self.ui.onClick:Remove(self.OnClickHandler, self)
end

function WeekActivityPanel:Upate()
	self.listData = ActivityModel:GetInstance():GetWeekActivity()

	self.index = 1
	
	RenderMgr.Add(function () self:RefreshContentInFrame() end, "WeekActivityPanel:RefreshContentInFrame")
end

function WeekActivityPanel:RefreshContentInFrame()
	if self.index <= #self.listData then
		local item = UIPackage.CreateObject("Activity", "WeekItem")
		item = WeekItem.Create(item)
		item:Update(self.listData[self.index], self.index)
		self:AddToCreateList(item)
		self.list:AddChild(item.ui)
		self.index = self.index + 1
	else
		RenderMgr.Realse("WeekActivityPanel:RefreshContentInFrame")
		self.data = nil
		self.index = nil
		self:SetDaySelect()
	end
end

function WeekActivityPanel:SetDaySelect()
	local day = tonumber(TimeTool.GetWeekDay())
	if day == 1 then --星期一
		self.select.x = 287
	elseif day == 2 then --星期二
		self.select.x = 415
	elseif day == 3 then --星期三
		self.select.x = 541
	elseif day == 4 then --星期四
		self.select.x = 668
	elseif day == 5 then --星期五
		self.select.x = 796
	elseif day == 6 then --星期六
		self.select.x = 922
	elseif day == 7 then --星期日
		self.select.x = 1046
	end
end

function WeekActivityPanel:OnClickHandler(context)
	local clickX = context.data.x/GameConst.scaleX
	if clickX > 159 and clickX < 301 then
		self.select.x = 159
	elseif clickX < 429 then --星期一
		self.select.x = 287
	elseif clickX < 557 then --星期二
		self.select.x = 415
	elseif clickX < 683 then --星期三
		self.select.x = 541
	elseif clickX < 810 then --星期四
		self.select.x = 668
	elseif clickX < 938 then --星期五
		self.select.x = 796
	elseif clickX < 1064 then --星期六
		self.select.x = 922
	elseif clickX >= 1064 and clickX < 1188 then --星期日
		self.select.x = 1046
	end
end

-- 布局UI
function WeekActivityPanel:Layout()
	self.ui = UIPackage.CreateObject("Activity","WeekActivityPanel");
	
	self.n1 = self.ui:GetChild("n1")
	self.select = self.ui:GetChild("select")
	self.list = self.ui:GetChild("list")
	self.banner = self.ui:GetChild("banner")

	self.creatList = {}
	self:ToCreate()
	self:AddEvent()

	self:Upate()

end

-- Dispose use WeekActivityPanel obj:Destroy()
function WeekActivityPanel:__delete()
	RenderMgr.Realse("WeekActivityPanel:RefreshContentInFrame")
	self:DestroyCreate()
	self:RemoveEvent()

	self.creatList = nil
end