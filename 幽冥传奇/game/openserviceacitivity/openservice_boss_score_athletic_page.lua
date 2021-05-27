-- 开服六道竞技
OpenServiceBossScoAthleticPage = OpenServiceBossScoAthleticPage or BaseClass()

function OpenServiceBossScoAthleticPage:__init()
	self.view = nil
	
end	

function OpenServiceBossScoAthleticPage:__delete()
	self:RemoveEvent()

	if self.list_view then
		self.list_view:DeleteMe()
		self.list_view = nil
	end
	self.view = nil
end	

--初始化页面接口
function OpenServiceBossScoAthleticPage:InitPage(view)
	--绑定要操作的元素
	self.view = view
	self:CreateAwardList()
	self:InitEvent()
	self:OnOpenSerBossScoAthleticDataChange()
end	

--初始化事件
function OpenServiceBossScoAthleticPage:InitEvent()
	self.boss_sco_athletic_evt = GlobalEventSystem:Bind(OpenServerActivityEventType.OPENSERVER_BOSS_SCOCRE_ATHLETIC, BindTool.Bind(self.OnOpenSerBossScoAthleticDataChange, self))
end

--移除事件
function OpenServiceBossScoAthleticPage:RemoveEvent()
	if self.boss_sco_athletic_evt then
		GlobalEventSystem:UnBind(self.boss_sco_athletic_evt)
		self.boss_sco_athletic_evt = nil
	end
end

function OpenServiceBossScoAthleticPage:CreateAwardList()
	if not self.list_view then
		local ph = self.view.ph_list.ph_item_list_4_10
		self.list_view = ListView.New()
		self.list_view:Create(ph.x, ph.y, ph.w, ph.h, direction, OpenSevrAthleticAwardItem, nil, false, self.view.ph_list.ph_list_item_4_10)
		self.list_view:SetItemsInterval(3)
		self.list_view:SetJumpDirection(ListView.Top)
		self.view.node_t_list.layout_boss_score_ahletic.node:addChild(self.list_view:GetView(), 100)
	end
end

--更新视图界面
function OpenServiceBossScoAthleticPage:UpdateData(data)
	for k, v in pairs(data) do
		if k == "all" then
			OpenServiceAcitivityCtrl.Instance:GetOpenSerAthleticAwardInfoReq(OPEN_ATHLETICS_TYPE.BossScore)
		end
	end
end

function OpenServiceBossScoAthleticPage:OnOpenSerBossScoAthleticDataChange()
	local data = OpenServiceAcitivityData.Instance:GetOpenSerOneAthleticData(OPEN_ATHLETICS_TYPE.BossScore)
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

	local my_info = OpenServiceAcitivityData.Instance:GetOpenSerMyStageLvInfo(OPEN_ATHLETICS_TYPE.BossScore)
	if my_info.my_stage then
		local content = string.format(Language.OpenServiceAcitivity.BinPinMyInfo, string.format(Language.OpenServiceAcitivity.StageAndLv[OPEN_ATHLETICS_TYPE.BossScore], my_info.my_stage))
		RichTextUtil.ParseRichText(self.view.node_t_list.rich_openser_sports_my_info_10.node, content, 20)
	end
end