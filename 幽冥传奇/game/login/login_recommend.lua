LoginView = LoginView or BaseClass(BaseView)

function LoginView:InitRecommendView()
	self.recommend = self.node_tree.layout_bg.layout_server_recommend

	-- 推荐
	self.recommond_server_list = ListView.New()
	self.recommond_server_list:Create(65, -50, 620, 100, nil, LoginServerItem)
	self.recommond_server_list:GetView():setAnchorPoint(0.5, 0.5)
	self.recommond_server_list:SetSelectCallBack(BindTool.Bind(self.OnTjServerListSelect, self))
	self.node_tree.layout_bg.layout_server_recommend.node:addChild(self.recommond_server_list:GetView(), 100)

	-- 最近
	self.last_server_list = ListView.New()
	self.last_server_list:Create(65, 80, 620, 100, nil, LoginServerItem)
	self.last_server_list:GetView():setAnchorPoint(0.5, 0.5)
	self.last_server_list:SetSelectCallBack(BindTool.Bind(self.OnLastServerListSelect, self))
	self.node_tree.layout_bg.layout_server_recommend.node:addChild(self.last_server_list:GetView(), 100)
end

function LoginView:RecommondReleaseCallBack()
	if nil ~= self.recommond_server_list then
		self.recommond_server_list:DeleteMe()
		self.recommond_server_list = nil
	end

	if nil ~= self.last_server_list then
		self.last_server_list:DeleteMe()
		self.last_server_list = nil
	end
end

function LoginView:OnFlushRecommond(data)
	local tj_server_data = data.server_list[data.recommend_server]
	self.recommond_server_list:SetDataList({tj_server_data})
	self.recommond_server_list:CancelSelect()

	local last_server_data = data.server_list[data.last_server]
	self.last_server_list:SetDataList({last_server_data})
	self.last_server_list:SelectIndex(1)
end

function LoginView:OnTjServerListSelect(item)
	self.cur_server_data = item:GetData()
	self.last_server_list:CancelSelect()
end

function LoginView:OnLastServerListSelect(item)
	if item then
		self.cur_server_data = item:GetData()
	end
	self.recommond_server_list:CancelSelect()
end
