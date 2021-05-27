local OneEquipLimitView = BaseClass(SubView)

function OneEquipLimitView:__init()
	self.texture_path_list = {
		--'res/xui/boss.png',
	}
    self.config_tab = {
		{"diamond_back_ui_cfg", 2, {0}},
	}
end

function OneEquipLimitView:__delete()
end

function OneEquipLimitView:ReleaseCallBack()
	if self.one_equip_list then
		self.one_equip_list:DeleteMe()
		self.one_equip_list = nil
	end
end

function OneEquipLimitView:LoadCallBack(index, loaded_times)
	self:OneEquipList()
	
	EventProxy.New(DiamondBackData.Instance, self):AddEventListener(DiamondBackData.ONE_EQUIP_LIST, BindTool.Bind(self.OneEquipList, self))

	local _s, _e = DiamondBackData.Instance:ActOpenStartTime()
	self.node_t_list.lbl_one_equip_time.node:setString(string.format(Language.DiamondBack.OpneTimeShow, _s.year, _s.month, _s.day, _e.year, _e.month, _e.day))
end

function OneEquipLimitView:ShowIndexCallBack()
	self:Flush()
end

function OneEquipLimitView:OneEquipList()
	self:Flush()
end

function OneEquipLimitView:OneEquipList()
	if nil == self.one_equip_list then
		local ph = self.ph_list.ph_one_list
		self.one_equip_list = ListView.New()
		self.one_equip_list:Create(ph.x, ph.y, ph.w, ph.h, nil, OneEquipLimitView.OneEquipLimitRender, nil, nil, self.ph_list.ph_one_item)
		-- self.one_equip_list:GetView():setAnchorPoint(0, 0)
		self.one_equip_list:SetJumpDirection(ListView.Top)
		self.node_t_list.layout_one_limit.node:addChild(self.one_equip_list:GetView(), 100)
	end		
end

function OneEquipLimitView:OnFlush(param_t)
	self.one_equip_list:SetDataList(DiamondBackData.Instance:SetOneEquipList())
end

OneEquipLimitView.OneEquipLimitRender = BaseClass(BaseRender)
local OneEquipLimitRender = OneEquipLimitView.OneEquipLimitRender
function OneEquipLimitRender:__init()	

end

function OneEquipLimitRender:__delete()	
	if self.cell_1 then
		self.cell_1:DeleteMe()
		self.cell_1 = nil 
	end

	if self.cell_2 then
		self.cell_2:DeleteMe()
		self.cell_2 = nil 
	end
end

function OneEquipLimitRender:CreateChild()
	BaseRender.CreateChild(self)

	local parent = self.view
	local ph = self.ph_list["ph_cell_1"] or {x = 0, y = 0, w = 10, h = 10}
	local cell = ActBaseCell.New()
	cell:SetPosition(ph.x, ph.y)
	parent:addChild(cell:GetView(), 99)
	self.cell_1 = cell

	local parent = self.view
	local ph = self.ph_list["ph_cell_2"] or {x = 0, y = 0, w = 10, h = 10}
	local cell = ActBaseCell.New()
	cell:SetPosition(ph.x, ph.y)
	parent:addChild(cell:GetView(), 99)
	self.cell_2 = cell
end

function OneEquipLimitRender:OnFlush()
	if self.data == nil then return end

	local color = self.data.equip_num > 0 and self.data.equip_result == 0 and COLOR3B.GREEN or Str2C3b("9c9181")
	self.node_tree.lbl_remind_num.node:setColor(color)
	self.node_tree.lbl_is_back.node:setColor(color)

	self.node_tree.lbl_remind_num.node:setString(string.format(Language.DiamondBack.RemindNum, self.data.equip_num))
	self.node_tree.lbl_is_back.node:setString(Language.DiamondBack.IsFirstText[self.data.equip_result])
	-- self.node_tree.lbl_is_back.node:setColor(self.data.equip_result == 0 and COLOR3B.G_W or COLOR3B.RED)

	local cfg = self.data.cfg or {}
	local consume = cfg.consume and cfg.consume[1]
	self.cell_1:SetData({item_id = cfg.ItemId, num = 1, is_bind = 0})

	local award = cfg.awards and cfg.awards[1]
	self.cell_2:SetData(ItemData.InitItemDataByCfg(award))
end

function OneEquipLimitRender:OnOpenEquip()
	local data = ItemData.Instance:GetItemConfig(self.data.equip_id)
	TipCtrl.Instance:OpenItem(data, EquipTip.FROME_BROWSE_ROLE)
end

function OneEquipLimitRender:CreateSelectEffect()
end

return OneEquipLimitView