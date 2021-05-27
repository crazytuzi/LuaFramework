-- 开服竞技等级竞技
OpenServiceLevelAthleticPage = OpenServiceLevelAthleticPage or BaseClass()

function OpenServiceLevelAthleticPage:__init()
	self.view = nil
	
end	

function OpenServiceLevelAthleticPage:__delete()
	self:RemoveEvent()
	if self.list_view then
		self.list_view:DeleteMe()
		self.list_view = nil
	end
	self.view = nil

	-- ClientCommonButtonDic[CommonButtonType.OPENSERVER_LEVELATHLETIC_GRID] = nil
end	

--初始化页面接口
function OpenServiceLevelAthleticPage:InitPage(view)
	--绑定要操作的元素
	self.view = view
	self:CreateAwardList()
	self:InitEvent()
	self:OnOpenSerLvAthleticDataChange()
end	

--初始化事件
function OpenServiceLevelAthleticPage:InitEvent()
	self.lev_athletic_evt = GlobalEventSystem:Bind(OpenServerActivityEventType.OPENSERVER_LEVEL_ATHLETIC, BindTool.Bind(self.OnOpenSerLvAthleticDataChange, self))
end

--移除事件
function OpenServiceLevelAthleticPage:RemoveEvent()
	if self.lev_athletic_evt then
		GlobalEventSystem:UnBind(self.lev_athletic_evt)
		self.lev_athletic_evt = nil
	end
end

function OpenServiceLevelAthleticPage:CreateAwardList()
	if not self.list_view then
		local ph = self.view.ph_list.ph_item_list_1
		self.list_view = ListView.New()
		self.list_view:Create(ph.x, ph.y, ph.w, ph.h, direction, OpenServiceLevelAthleticItem, nil, false, self.view.ph_list.ph_list_item_1)
		self.list_view:SetItemsInterval(3)
		self.list_view:SetJumpDirection(ListView.Top)
		-- ClientCommonButtonDic[CommonButtonType.OPENSERVER_LEVELATHLETIC_GRID] = self.list_view
		self.view.node_t_list.layout_lev_ahletic.node:addChild(self.list_view:GetView(), 100)
	end
end

--更新视图界面
function OpenServiceLevelAthleticPage:UpdateData(data)
	for k, v in pairs(data) do
		if k == "all" then
			OpenServiceAcitivityCtrl.Instance:GetOpenSerAthleticAwardInfoReq(OPEN_ATHLETICS_TYPE.Leveling)
		end
	end
end

function OpenServiceLevelAthleticPage:OnOpenSerLvAthleticDataChange()
	local data = TableCopy(OpenServiceAcitivityData.Instance:GetOpenSerOneAthleticData(OPEN_ATHLETICS_TYPE.Leveling))
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
	local my_info = OpenServiceAcitivityData.Instance:GetOpenSerMyStageLvInfo(OPEN_ATHLETICS_TYPE.Leveling)
	if my_info.my_stage then
		local lv = my_info.my_stage % OpenServerCfg.OpenServerCircleRate
		local circle = math.floor(my_info.my_stage / OpenServerCfg.OpenServerCircleRate)
		local content = string.format(Language.OpenServiceAcitivity.BinPinMyInfo, string.format(Language.OpenServiceAcitivity.StageAndLv[OPEN_ATHLETICS_TYPE.Leveling], circle, lv))
		RichTextUtil.ParseRichText(self.view.node_t_list.rich_openser_sports_my_info_1.node, content, 20)
	end

end


OpenServiceLevelAthleticItem = OpenServiceLevelAthleticItem or BaseClass(OpenSevrAthleticAwardItem)
function OpenServiceLevelAthleticItem:__init()
end

function OpenServiceLevelAthleticItem:__delete()
end

function OpenServiceLevelAthleticItem:GetGuideView()
	return self.node_tree.btn_fetch.node
end

function OpenServiceLevelAthleticItem:CompareGuideData(data)
	local circle = data[1]
	local level = data[2]
	return self.data.circle == circle and self.data.level == level
end