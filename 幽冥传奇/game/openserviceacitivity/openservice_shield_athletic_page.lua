-- 开服神盾竞技
OpenServiceShieldAthleticPage = OpenServiceShieldAthleticPage or BaseClass()

function OpenServiceShieldAthleticPage:__init()
	self.view = nil
	
end	

function OpenServiceShieldAthleticPage:__delete()
	self:RemoveEvent()

	if self.list_view then
		self.list_view:DeleteMe()
		self.list_view = nil
	end
	self.view = nil
end	

--初始化页面接口
function OpenServiceShieldAthleticPage:InitPage(view)
	--绑定要操作的元素
	self.view = view
	self:CreateAwardList()
	self:InitEvent()
	self:OnOpenSerShieldAthleticDataChange()
end	

--初始化事件
function OpenServiceShieldAthleticPage:InitEvent()
	self.shield_athletic_evt = GlobalEventSystem:Bind(OpenServerActivityEventType.OPENSERVER_SHIELD_ATHLETIC, BindTool.Bind(self.OnOpenSerShieldAthleticDataChange, self))
end

--移除事件
function OpenServiceShieldAthleticPage:RemoveEvent()
	if self.shield_athletic_evt then
		GlobalEventSystem:UnBind(self.shield_athletic_evt)
		self.shield_athletic_evt = nil
	end
end

function OpenServiceShieldAthleticPage:CreateAwardList()
	if not self.list_view then
		local ph = self.view.ph_list.ph_item_list_4_9
		self.list_view = ListView.New()
		self.list_view:Create(ph.x, ph.y, ph.w, ph.h, direction, OpenSevrAthleticAwardItem, nil, false, self.view.ph_list.ph_list_item_4_9)
		self.list_view:SetItemsInterval(3)
		self.list_view:SetJumpDirection(ListView.Top)
		self.view.node_t_list.layout_shield_ahletic.node:addChild(self.list_view:GetView(), 100)
	end
end

--更新视图界面
function OpenServiceShieldAthleticPage:UpdateData(data)
	for k, v in pairs(data) do
		if k == "all" then
			OpenServiceAcitivityCtrl.Instance:GetOpenSerAthleticAwardInfoReq(OPEN_ATHLETICS_TYPE.Shield)
		end
	end
end

function OpenServiceShieldAthleticPage:OnOpenSerShieldAthleticDataChange()
	local data = OpenServiceAcitivityData.Instance:GetOpenSerOneAthleticData(OPEN_ATHLETICS_TYPE.Shield)
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

	local my_info = OpenServiceAcitivityData.Instance:GetOpenSerMyStageLvInfo(OPEN_ATHLETICS_TYPE.Shield)
	if my_info.my_stage then
		local content = string.format(Language.OpenServiceAcitivity.BinPinMyInfo, string.format(Language.OpenServiceAcitivity.StageAndLv[OPEN_ATHLETICS_TYPE.Shield], my_info.my_stage))
		RichTextUtil.ParseRichText(self.view.node_t_list.rich_openser_sports_my_info_9.node, content, 20)
	end
end