local LookConsignView = BaseClass(SubView)

LookConsignView.EditBoxInitNum = 0

function LookConsignView:__init()
	self.texture_path_list[1] = 'res/xui/consign.png'
	self.config_tab = {
		{"consign_ui_cfg", 4, {0}},
	}
	if LookConsignView.Instance then
		ErrorLog("[ConsignData] Attemp to create a singleton twice !")
	end
	
	LookConsignView.Instance = self
end

function LookConsignView:LoadCallBack()
	self.layout_my_consign = self.node_t_list.layout_my_consign.node
	
	
	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.OnMyConsignData, self))
	EventProxy.New(ConsignData.Instance, self):AddEventListener(ConsignData.MY_CONSIGN_DATA, BindTool.Bind(self.OnMyConsignData, self))--事件监听
	
end

function LookConsignView:ReleaseCallBack()
	
	if nil ~= self.my_consign_list then
		self.my_consign_list:DeleteMe()
		self.my_consign_list = nil
	end

end


function LookConsignView:ShowIndexCallBack()
	self:Flush()
end

function LookConsignView:OnFlush(param_t)
	
	
	---- 我的寄售界面 ----
	self:UpdateMyConsignList()
end

function LookConsignView:OnMyConsignData()
	self:Flush()
end

-------------------------------------
-- 我的寄售界面
function LookConsignView:UpdateMyConsignList()
	if self.my_consign_list == nil then
		local ph = self.ph_list.ph_my_consign_list
		self.my_consign_list = ListView.New()
		self.my_consign_list:Create(ph.x, ph.y, ph.w, ph.h, nil, ConsignItemRender, nil, nil, self.ph_list.ph_list_my_consign_item)
		self.my_consign_list:GetView():setAnchorPoint(0, 0)
		self.my_consign_list:SetItemsInterval(2)
		self.my_consign_list:SetJumpDirection(ListView.Top)
		self.my_consign_list:JumpToTop(true)
		self.layout_my_consign:addChild(self.my_consign_list:GetView(), 100)
	end
	
	local data = ConsignData.Instance:GetMyConsignItemsData()
	if data == nil or data.item_list == nil then return end
	self.my_consign_list:SetDataList(data.item_list)
end

-------------------------------------
-- ConsignItemRender
-------------------------------------
ConsignItemRender = ConsignItemRender or BaseClass(BaseRender)
function ConsignItemRender:__init()
end

function ConsignItemRender:__delete()	
	if nil ~= self.cell then
		self.cell:DeleteMe()
		self.cell = nil
	end
end

function ConsignItemRender:CreateChild()
	BaseRender.CreateChild(self)
	local ph = self.ph_list.ph_item_cell
	if nil == self.cell then
		self.cell = BaseCell.New()
		self.cell:SetPosition(ph.x, ph.y)
		self.cell:SetIndex(i)
		self.cell:SetAnchorPoint(0.5, 0.5)
		self.view:addChild(self.cell:GetView(), 103)
		
		self.cell:SetName(GRID_TYPE_BAG)
	end
	
	self.node_tree.btn_remove.node:addClickEventListener(BindTool.Bind(self.OnClickRemoveHandler, self))
end

function ConsignItemRender:OnClickRemoveHandler()
	if nil == self.data then return end
	local operation = 0
	if self.data.remain_time <= Status.NowTime then operation = 1 end
	ConsignCtrl.Instance:SendCancelConsignItemReq(self.data.item_data.series, self.data.item_handle, operation)
end

function ConsignItemRender:OnFlush()
	if nil == self.data then return end
	self.cell:SetData(self.data.item_data)
	
	local item_cfg, big_type = ItemData.Instance:GetItemConfig(self.data.item_data.item_id)
	if nil == item_cfg then
		GlobalTimerQuest:AddDelayTimer(function()
			self:OnFlush()
		end, 0)
		return
	end
	
	local str = EquipTip.GetEquipName(item_cfg, self.data.item_data, EquipTip.FROM_CONSIGN_ON_SELL)
	RichTextUtil.ParseRichText(self.node_tree.rich_txt_item_name.node, str, 20, Str2C3b(string.sub(string.format("%06x", item_cfg.color), 1, 6)))
	
	self.node_tree.txt_price.node:setString(self.data.item_price)
	-- self.node_tree.img_bg.node:setColor(self:GetIndex() % 2 == 0 and Str2C3b("1D1E1F") or Str2C3b("FFFFFF"))
	
	self:SetTimerCountDown()
end

-- 设置倒计时
function ConsignItemRender:SetTimerCountDown()
	if nil == self.data then return end
	if self.data.remain_time <= Status.NowTime then
		self.node_tree.txt_remain_time.node:setString(Language.Consign.TimeOut)
		self.node_tree.txt_remain_time.node:setColor(COLOR3B.RED)
		return
	end
	local time_tab = TimeUtil.Format2TableDHM(self.data.remain_time - Status.NowTime)
	self.node_tree.txt_remain_time.node:setString(string.format(Language.Consign.TimeTips, time_tab.day, time_tab.hour, time_tab.min))
	self.node_tree.txt_remain_time.node:setColor(cc.c3b(204, 204, 204))
end

function ConsignItemRender:GetCountDownKey()
	if nil == self.data then return end
	local key = "consign_item_render_" .. self.data.item_handle
	return key
end

return LookConsignView 