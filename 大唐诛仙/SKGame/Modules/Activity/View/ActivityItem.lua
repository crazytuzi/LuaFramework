ActivityItem = BaseClass(LuaUI)

ActivityItem.CurSelectItem = nil
function ActivityItem:__init(...)
	self.URL = "ui://oa3ahys9mfyib";
	self:__property(...)
	self:Config()
end

function ActivityItem:SetProperty(...)
	
end

function ActivityItem:Config()
	-- self.unopenURL = UIPackage.GetItemURL("Activity" ,"weikaiqi")
	-- self.fbURL = UIPackage.GetItemURL("Activity" ,"fubenItem")
	-- self.xsURL = UIPackage.GetItemURL("Activity" ,"xuanshangItem")
	-- self.huanURL = UIPackage.GetItemURL("Activity" ,"huanItem")
end

function ActivityItem:RegistUI(ui)
	self.ui = ui or self.ui or UIPackage.CreateObject("Activity","ActivityItem");

	self.itemBg = self.ui:GetChild("itemBg")
	self.select = self.ui:GetChild("select")
	self.name = self.ui:GetChild("name")
	self.count = self.ui:GetChild("count")
	self.gotoBtn = self.ui:GetChild("gotoBtn")
	self.time = self.ui:GetChild("time")

	self.data = nil
	self.infoPanel = nil

	self.icon = PkgCell.New(self.ui)
	self.icon:SetXY(82, 76)	
	self.icon:OpenTips(false)
	
	self:AddEvent()
	self:Reset()
end

function ActivityItem.Create(ui, ...)
	return ActivityItem.New(ui, "#", {...})
end

function ActivityItem:AddEvent()
	self.icon.ui.onClick:Add(self.ShowInfo, self)
	self.itemBg.onClick:Add(self.OnClickHandler, self)
	self.gotoBtn.onClick:Add(self.OnGotoBtnClickHandler, self)
end

function ActivityItem:RemoveEvent()
	self.icon.ui.onClick:Remove(self.ShowInfo, self)
	self.itemBg.onClick:Remove(self.OnClickHandler, self)
	self.gotoBtn.onClick:Remove(self.OnGotoBtnClickHandler, self)
end

function ActivityItem:OnGotoBtnClickHandler()
	ActivityController:GetInstance():Close()
	GlobalDispatcher:DispatchEvent(EventName.GuideFunctionTrigger, self.data.guideId)
	GlobalDispatcher:DispatchEvent(EventName.FinishNewbieGuideStep)
end

function ActivityItem:Update(data)
	self.data = data
	local dynamicData = ActivityModel:GetInstance():GetActivityDataById(self.data.id)

	self.name.text = self.data.name
	self.time.text = self.data.timeShow
	self.icon:SetDataByCfg(2, self.data.icon, 1, 0)
	local times = ""
	if dynamicData then
		local mainLevel = SceneModel:GetInstance():GetMainPlayer().level 
		local viplevel =  ActivityModel:GetInstance():GetVipLevelAdd( self.data.id )
		local haveTimes = 0
		if self.data.type == 1 then
			haveTimes = self.data.maxCount + viplevel - dynamicData.enterCount
			times = math.max( 0, haveTimes ).."/"..self.data.maxCount + viplevel
		else
			haveTimes = self.data.maxCount - dynamicData.enterCount
			times = math.max( 0, haveTimes ).."/"..self.data.maxCount
		end
		
		if dynamicData.state == 0 then -- 已开启
			self.gotoBtn.grayed = false
			self.gotoBtn.touchable = true
		else -- 未开启或无次数
			self.gotoBtn.grayed = true
			self.gotoBtn.touchable = false
			-- self.itemBg.url = UIPackage.GetItemURL("Activity" ,"weikaiqi")
		end
		self.gotoBtn.title = "前往"

		if self.data.limitLevel > mainLevel then -- 等级未够
			self.gotoBtn.grayed = true
			self.gotoBtn.touchable = false
			self.gotoBtn.title = StringFormat("{0}级开启", self.data.limitLevel)
		end
	else
		times = self.data.maxCount.."/"..self.data.maxCount
	end
	self.count.text = StringFormat("次数 {0}", times)
end

function ActivityItem:ShowInfo()
	if self.data == nil then return end
	if not self.infoPanel or not self.infoPanel.ui then
		self.infoPanel = WeekCellInfoPanel.New()
	end
	self.infoPanel:SetData(self.data)
	UIMgr.ShowPopup(self.infoPanel)
end

function ActivityItem:Reset()
	self:UnSelect()
end

function ActivityItem:OnClickHandler()
	if ActivityItem.CurSelectItem then
		ActivityItem.CurSelectItem:UnSelect()
	end
	self:Select()
end

function ActivityItem:Select()
	self.select.visible = true
	ActivityItem.CurSelectItem = self
	ActivityModel:GetInstance():DispatchEvent(ActivityConst.SelectActivityItem, self.data)
end

function ActivityItem:UnSelect()
	self.select.visible = false
end

function ActivityItem:__delete()
	self:RemoveEvent()
	if ActivityItem.CurSelectItem == self then
		ActivityItem.CurSelectItem = nil
	end
	if self.icon then
		self.icon:Destroy()
		self.icon = nil
	end
	self.data = nil
	if self.infoPanel then
		self.infoPanel:Destroy()
	end
	self.infoPanel = nil
end