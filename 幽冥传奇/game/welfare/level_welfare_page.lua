-- 等级福利界面
LevelWelfarePage = LevelWelfarePage or BaseClass()

function LevelWelfarePage:__init()
	self.view = nil
end

function LevelWelfarePage:__delete()
	self.view = nil
	if self.reward_info_list then
		self.reward_info_list:DeleteMe()
		self.reward_info_list = nil
	end
end

function LevelWelfarePage:InitPage(view)
	self.view = view
	self:CreateGiftInfoList()
	local data = WelfareData.Instance:GetLevelWelfarecfg()
	self.view.node_t_list.levelText.node:setString(RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL))
	self.view.node_t_list.levelText.node:setScale(1.5)
end

function LevelWelfarePage:CreateGiftInfoList()
	if not self.reward_info_list then
		local ph = self.view.ph_list.ph_level_reward_list
		self.reward_info_list = ListView.New()
		self.reward_info_list:Create(ph.x, ph.y, ph.w, ph.h, direction, LevelWelfareItem, nil, false, self.view.ph_list.ph_list_level_reward_info)
		self.reward_info_list:SetItemsInterval(3)
		self.reward_info_list:SetJumpDirection(ListView.Top)
		self.view.node_t_list.page10.node:addChild(self.reward_info_list:GetView(), 100)
	end
end

--更新视图界面
function LevelWelfarePage:UpdateData(data)
	self.view.node_t_list.levelText.node:setString(RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL))
	local data = WelfareData.Instance:GetLevelWelfarecfg()
	self.reward_info_list:SetDataList(data.awards)
end	
LevelWelfareItem = LevelWelfareItem or BaseClass(BaseRender)
function LevelWelfareItem:__init()

end

function LevelWelfareItem:__delete()
	for k,v in pairs(self.reward_cell) do
		v:DeleteMe()
	end
	self.reward_cell = {}
end

function LevelWelfareItem:CreateChild()
	BaseRender.CreateChild(self)
	self.reward_cell = {}
	for i = 1, 4 do
		local ph = self.ph_list["ph_cell_"..i]
		local cell = BaseCell.New()
		cell:SetPosition(ph.x, ph.y)
		cell:GetView():setAnchorPoint(0, 0)
		self.view:addChild(cell:GetView(), 103)
		table.insert(self.reward_cell, cell)
	end
	self.node_tree.btn_can_receive.node:addClickEventListener(BindTool.Bind(self.GetConsume, self))
	self.node_tree.btn_yuanbao_can_receive.node:addClickEventListener(BindTool.Bind(self.GetYuanbaoConsume, self))
end

function LevelWelfareItem:OnFlush()
	if self.data == nil then return end
	self.node_tree.txt_item_name.node:setString(self.data.item_desc)
	self.node_tree.txt_yuanbao.node:setString(self.data.item_exConsume[1].count)
	self.node_tree.img_yuanbao.node:setVisible(false)
	self.node_tree.txt_yuanbao.node:setVisible(false)
	local data = {}
	if self.data.yb_state == LEVEL_WELFARE_STATE.NOT_COMPLETE  then
		self.node_tree.img_not.node:setVisible(true)
		self.node_tree.btn_can_receive.node:setVisible(false)
		self.node_tree.btn_yuanbao_can_receive.node:setVisible(false)
		self.node_tree.img_receive.node:setVisible(false)
		data = self.data.item_awards
	elseif self.data.yb_state == LEVEL_WELFARE_STATE.CAN_FETCH  then
		self.node_tree.img_not.node:setVisible(false)
		if self.data.state == LEVEL_WELFARE_STATE.HAVE_FETCHED then
			self.node_tree.btn_can_receive.node:setVisible(false)
			self.node_tree.btn_yuanbao_can_receive.node:setVisible(true)
			self.node_tree.img_yuanbao.node:setVisible(true)
			self.node_tree.txt_yuanbao.node:setVisible(true)
			data = self.data.item_exAwards
		
		else
			self.node_tree.btn_can_receive.node:setVisible(true)
			self.node_tree.btn_yuanbao_can_receive.node:setVisible(false)
			data = self.data.item_awards
		end	
		self.node_tree.img_receive.node:setVisible(false)
	else
		self.node_tree.img_not.node:setVisible(false)
		self.node_tree.btn_can_receive.node:setVisible(false)
		self.node_tree.btn_yuanbao_can_receive.node:setVisible(false)
		self.node_tree.img_receive.node:setVisible(true)
		data = self.data.item_exAwards
	end
	for k,v in pairs(self.reward_cell) do
		v:GetView():setVisible(false)
	end
	for k,v in pairs(data) do
		if self.reward_cell[k] ~= nil  then
			self.reward_cell[k]:GetView():setVisible(true)
			local id = 0
			if v.type ~= 0 then
				id = ItemData.Instance:GetVirtualItemId(v.type)
				v.bind = 0
			else
				id = v.id
			end
			self.reward_cell[k]:SetData({item_id = id, num = v.count, is_bind = v.bind })
		end
	end
end

-- 创建选中特效
function LevelWelfareItem:CreateSelectEffect()
	
end

function LevelWelfareItem:GetConsume()
	WelfareCtrl.Instance:LevelWelfareAwardReq(self.data.pos, 0)
end
function LevelWelfareItem:GetYuanbaoConsume()
	WelfareCtrl.Instance:LevelWelfareAwardReq(self.data.pos, 1)
end