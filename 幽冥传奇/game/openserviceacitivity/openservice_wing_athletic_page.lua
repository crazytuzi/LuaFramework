-- 开服竞技羽翼竞技
OpenServiceWingAthleticPage = OpenServiceWingAthleticPage or BaseClass()

function OpenServiceWingAthleticPage:__init()
	self.view = nil
	
end	

function OpenServiceWingAthleticPage:__delete()
	self:RemoveEvent()
	if self.list_view then
		self.list_view:DeleteMe()
		self.list_view = nil
	end
	self.view = nil
end	

--初始化页面接口
function OpenServiceWingAthleticPage:InitPage(view)
	--绑定要操作的元素
	self.view = view
	self:CreateAwardList()
	self:InitEvent()
	self:OnOpenSerWingAthleticDataChange()
	
end	

--初始化事件
function OpenServiceWingAthleticPage:InitEvent()
	self.wing_athletic_evt = GlobalEventSystem:Bind(OpenServerActivityEventType.OPENSERVER_WING_ATHLETIC, BindTool.Bind(self.OnOpenSerWingAthleticDataChange, self))
end

--移除事件
function OpenServiceWingAthleticPage:RemoveEvent()
	if self.wing_athletic_evt then
		GlobalEventSystem:UnBind(self.wing_athletic_evt)
		self.wing_athletic_evt = nil
	end
end

function OpenServiceWingAthleticPage:CreateAwardList()
	if not self.list_view then
		local ph = self.view.ph_list.ph_item_list_2
		self.list_view = ListView.New()
		self.list_view:Create(ph.x, ph.y, ph.w, ph.h, direction, OpenSevrAthleticAwardItem, nil, false, self.view.ph_list.ph_list_item_2)
		self.list_view:SetItemsInterval(3)
		self.list_view:SetJumpDirection(ListView.Top)
		self.view.node_t_list.layout_wing_ahletic.node:addChild(self.list_view:GetView(), 100)
	end
end

--更新视图界面
function OpenServiceWingAthleticPage:UpdateData(data)
	for k, v in pairs(data) do
		if k == "all" then
			OpenServiceAcitivityCtrl.Instance:GetOpenSerAthleticAwardInfoReq(OPEN_ATHLETICS_TYPE.Wing)
		end
	end
end

function OpenServiceWingAthleticPage:OnOpenSerWingAthleticDataChange()
	local data = TableCopy(OpenServiceAcitivityData.Instance:GetOpenSerOneAthleticData(OPEN_ATHLETICS_TYPE.Wing))
	data = OpenServiceAcitivityData.SortAthleticData(data)
	-- local real_data = {}
	-- local arr_idx = 1
	-- for k, v in ipairs(data) do
	-- 	if k ~= 1 then
	-- 		real_data[arr_idx] = v
	-- 		arr_idx = arr_idx + 1
	-- 	end
	-- end

	if self.list_view then
		self.list_view:SetDataList(data)
	end

	local my_info = OpenServiceAcitivityData.Instance:GetOpenSerMyStageLvInfo(OPEN_ATHLETICS_TYPE.Wing)
	if my_info.my_stage then
		local content = string.format(Language.OpenServiceAcitivity.BinPinMyInfo, string.format(Language.OpenServiceAcitivity.StageAndLv[OPEN_ATHLETICS_TYPE.Wing], my_info.my_stage))
		RichTextUtil.ParseRichText(self.view.node_t_list.rich_openser_sports_my_info_2.node, content, 20)
	end
end