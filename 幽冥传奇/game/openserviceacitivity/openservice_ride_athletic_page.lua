-- 开服骑术竞技
OpenServiceRideAthleticPage = OpenServiceRideAthleticPage or BaseClass()

function OpenServiceRideAthleticPage:__init()
	self.view = nil
	
end	

function OpenServiceRideAthleticPage:__delete()
	self:RemoveEvent()

	if self.list_view then
		self.list_view:DeleteMe()
		self.list_view = nil
	end
	self.view = nil
end	

--初始化页面接口
function OpenServiceRideAthleticPage:InitPage(view)
	--绑定要操作的元素
	self.view = view
	self:CreateAwardList()
	self:InitEvent()
	self:OnOpenSerRideAthleticDataChange()
end	

--初始化事件
function OpenServiceRideAthleticPage:InitEvent()
	self.ride_athletic_evt = GlobalEventSystem:Bind(OpenServerActivityEventType.OPENSERVER_RIDE_ATHLETIC, BindTool.Bind(self.OnOpenSerRideAthleticDataChange, self))
end

--移除事件
function OpenServiceRideAthleticPage:RemoveEvent()
	if self.ride_athletic_evt then
		GlobalEventSystem:UnBind(self.ride_athletic_evt)
		self.ride_athletic_evt = nil
	end
end

function OpenServiceRideAthleticPage:CreateAwardList()
	if not self.list_view then
		local ph = self.view.ph_list.ph_item_list_4_6
		self.list_view = ListView.New()
		self.list_view:Create(ph.x, ph.y, ph.w, ph.h, direction, OpenSevrAthleticAwardItem, nil, false, self.view.ph_list.ph_list_item_4_6)
		self.list_view:SetItemsInterval(3)
		self.list_view:SetJumpDirection(ListView.Top)
		self.view.node_t_list.layout_ride_ahletic.node:addChild(self.list_view:GetView(), 100)
	end
end

--更新视图界面
function OpenServiceRideAthleticPage:UpdateData(data)
	for k, v in pairs(data) do
		if k == "all" then
			OpenServiceAcitivityCtrl.Instance:GetOpenSerAthleticAwardInfoReq(OPEN_ATHLETICS_TYPE.Ride)
		end
	end
end

function OpenServiceRideAthleticPage:OnOpenSerRideAthleticDataChange()
	local data = OpenServiceAcitivityData.Instance:GetOpenSerOneAthleticData(OPEN_ATHLETICS_TYPE.Ride)
	local real_data = {}
	local arr_idx = 1
	for k, v in ipairs(data) do
		if k ~= 1 then
			real_data[arr_idx] = v
			arr_idx = arr_idx + 1
		end
	end

	if self.list_view then
		self.list_view:SetDataList(real_data)
	end
end