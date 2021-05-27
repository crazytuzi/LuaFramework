--万魔界面
WanshoumopuWanmoPage = WanshoumopuWanmoPage or BaseClass()
function WanshoumopuWanmoPage:__init()

end	

function WanshoumopuWanmoPage:__delete()
	self:RemoveEvent()	
	self.view = nil

	if self.wanmo_list then
		self.wanmo_list:DeleteMe()
		self.wanmo_list = nil
	end
end	

--初始化页面接口
function WanshoumopuWanmoPage:InitPage(view)
	--绑定要操作的元素
	self.view = view
	self:InitEvent()
	self:CreateshowList()
	self.select_index = 1
end	
--初始化事件
function WanshoumopuWanmoPage:InitEvent()

end

function WanshoumopuWanmoPage:CreateshowList()
	local ph = self.view.ph_list.ph_wanmo_list
	self.wanmo_list = ListView.New()
	self.wanmo_list:Create(ph.x, ph.y, ph.w, ph.h, direction, WanMoRender, nil, false, self.view.ph_list.ph_wanmo_item)
	self.wanmo_list:SetItemsInterval(3)
	self.wanmo_list:SetMargin(3)
	self.wanmo_list:GetView():setAnchorPoint(0, 0)
	self.wanmo_list:SetJumpDirection(ListView.Top)
	-- self.wanmo_list:SetSelectCallBack(BindTool.Bind(self.SelectTypeCallback, self))
	self.view.node_t_list.layout_wanmo.node:addChild(self.wanmo_list:GetView(), 100)
end

--移除事件
function WanshoumopuWanmoPage:RemoveEvent()
	
end

--更新视图界面
function WanshoumopuWanmoPage:UpdateData(data)
	self.wanmo_list:SetJumpDirection(ListView.Top)
	local real_data = WanShouMoPuData.Instance:GetWanshouDataByType(2)
	self.wanmo_list:SetDataList(real_data)
end

function WanshoumopuWanmoPage:FlushData(data)
	local real_data = WanShouMoPuData.Instance:GetWanshouDataByType(2)
	self.wanmo_list:SetDataList(real_data)
end