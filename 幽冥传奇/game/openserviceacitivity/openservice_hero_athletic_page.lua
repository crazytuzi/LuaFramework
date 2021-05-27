-- 开服竞麒麟姬竞技
OpenServiceHeroAthleticPage = OpenServiceHeroAthleticPage or BaseClass()

function OpenServiceHeroAthleticPage:__init()
	self.view = nil
	
end	

function OpenServiceHeroAthleticPage:__delete()
	self:RemoveEvent()

	if self.list_view then
		self.list_view:DeleteMe()
		self.list_view = nil
	end
	self.view = nil
end	

--初始化页面接口
function OpenServiceHeroAthleticPage:InitPage(view)
	--绑定要操作的元素
	self.view = view
	self:CreateAwardList()
	self:InitEvent()
	self:OnOpenSerHeroAthleticDataChange()
end	

--初始化事件
function OpenServiceHeroAthleticPage:InitEvent()
	self.hero_athletic_evt = GlobalEventSystem:Bind(OpenServerActivityEventType.OPENSERVER_HERO_ATHLETIC, BindTool.Bind(self.OnOpenSerHeroAthleticDataChange, self))
end

--移除事件
function OpenServiceHeroAthleticPage:RemoveEvent()
	if self.hero_athletic_evt then
		GlobalEventSystem:UnBind(self.hero_athletic_evt)
		self.hero_athletic_evt = nil
	end
end

function OpenServiceHeroAthleticPage:CreateAwardList()
	if not self.list_view then
		local ph = self.view.ph_list.ph_item_list_4_5
		self.list_view = ListView.New()
		self.list_view:Create(ph.x, ph.y, ph.w, ph.h, direction, OpenSevrAthleticAwardItem, nil, false, self.view.ph_list.ph_list_item_4_5)
		self.list_view:SetItemsInterval(3)
		self.list_view:SetJumpDirection(ListView.Top)
		self.view.node_t_list.layout_hero_ahletic.node:addChild(self.list_view:GetView(), 100)
	end
end

--更新视图界面
function OpenServiceHeroAthleticPage:UpdateData(data)
	for k, v in pairs(data) do
		if k == "all" then
			OpenServiceAcitivityCtrl.Instance:GetOpenSerAthleticAwardInfoReq(OPEN_ATHLETICS_TYPE.Hero)
		end
	end
end

function OpenServiceHeroAthleticPage:OnOpenSerHeroAthleticDataChange()
	local data = TableCopy(OpenServiceAcitivityData.Instance:GetOpenSerOneAthleticData(OPEN_ATHLETICS_TYPE.Hero))
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

	local my_info = OpenServiceAcitivityData.Instance:GetOpenSerMyStageLvInfo(OPEN_ATHLETICS_TYPE.Hero)
	if my_info.my_stage then
		local step, star = ZhanjiangData.GetFuWenStepStar(my_info.my_stage)
		local content = string.format(Language.OpenServiceAcitivity.BinPinMyInfo, string.format(Language.OpenServiceAcitivity.StageAndLv[OPEN_ATHLETICS_TYPE.Hero], step, star))
		RichTextUtil.ParseRichText(self.view.node_t_list.rich_openser_sports_my_info_5.node, content, 20)
	end
end