ConsignMineItemPage = ConsignMineItemPage or BaseClass()


function ConsignMineItemPage:__init()
	self.view = nil
end

function ConsignMineItemPage:__delete()
	self:RemoveEvent()
	if self.my_consign_list ~= nil then
		self.my_consign_list:DeleteMe()
		self.my_consign_list = nil 
	end
end

--初始化页面
function ConsignMineItemPage:InitPage(view)
	--绑定要操作的元素
	self.view = view
	self:UpdateMyConsignList()
end
	

function ConsignMineItemPage:InitEvent()
	if self.my_consign_info_event then
		GlobalEventSystem:UnBind(self.my_consign_info_event)
		self.my_consign_info_event = nil
	end
	self.my_consign_info_event = GlobalEventSystem:Bind(ConsignEventType.GET_MY_CONSIGN_INFO, BindTool.Bind(self.OnFlushMyConsignItem, self))
end

--移除事件
function ConsignMineItemPage:RemoveEvent()
	if self.my_consign_info_event then
		GlobalEventSystem:UnBind(self.my_consign_info_event)
		self.my_consign_info_event = nil
	end
end

--更新视图界面
function ConsignMineItemPage:UpdateData(data)
	for k,v in pairs(data) do
		if k == "all" then
			self:FlushMineItem()
		end
	end
end

function ConsignMineItemPage:UpdateMyConsignList()
	if  self.my_consign_list == nil then
		local ph = self.view.ph_list.ph_my_consign_list
		self.my_consign_list = ListView.New()
		self.my_consign_list:Create(ph.x, ph.y, ph.w, ph.h, nil, ConsignItemRender, nil, nil,  self.view.ph_list.ph_list_my_consign_item)
		self.my_consign_list:GetView():setAnchorPoint(0, 0)
		self.my_consign_list:SetItemsInterval(2)
		self.my_consign_list:SetJumpDirection(ListView.Top)
		self.my_consign_list:JumpToTop(true)
		self.view.node_t_list.layout_my_consign.node:addChild(self.my_consign_list:GetView(), 100)
	end
end

function ConsignMineItemPage:FlushMineItem()
	local data = ConsignData.Instance:GetMyConsignItemsData()
	if data == nil or data.item_list == nil then return end
	self.my_consign_list:SetDataList(data.item_list)
end

function ConsignMineItemPage:OnFlushMyConsignItem()
	self:Flush(TabIndex.consign_mine_item)
end