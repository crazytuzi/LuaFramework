LoginView = LoginView or BaseClass(BaseView)

function LoginView:InitAllListView()
	self.alllist = self.node_tree.layout_bg.layout_all

	self.all_server_list = ListView.New()
	self.all_server_list:Create(5, 0, 620, 370, nil, LoginServerItem)
	self.all_server_list:GetView():setAnchorPoint(0, 0)
	self.all_server_list:SetSelectCallBack(BindTool.Bind(self.OnAllServerListSelect, self))
	self.node_tree.layout_bg.layout_all.node:addChild(self.all_server_list:GetView(), 100)
end

function LoginView:AllListReleaseCallBack()
	if nil ~= self.all_server_list then
		self.all_server_list:DeleteMe()
		self.all_server_list = nil
	end
end

function LoginView:OnFlushAll(data)
	if nil == data or 0 == #data then
		Log("data is null")
		return
	end

	self.all_server_list:SetDataList(data)
	self.all_server_list:SelectIndex(1)
	self.all_server_list:JumpToTop(true)
end

function LoginView:OnAllServerListSelect(item)
	self.cur_server_data = item:GetData()
end
