local SuitLimitBackView = BaseClass(SubView)

function SuitLimitBackView:__init()
	self.texture_path_list = {
		--'res/xui/boss.png',
	}
    self.config_tab = {
		{"diamond_back_ui_cfg", 3, {0}},
	}
end

function SuitLimitBackView:__delete()
end

function SuitLimitBackView:ReleaseCallBack()
	if self.suit_list then
		self.suit_list:DeleteMe()
		self.suit_list = nil
	end
end

function SuitLimitBackView:LoadCallBack(index, loaded_times)
	self:SuitLimitList()
	
	EventProxy.New(DiamondBackData.Instance, self):AddEventListener(DiamondBackData.SUIT_BACK_DATA, BindTool.Bind(self.OnSuitBack, self))
	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.OnBagItemChange, self))

	local _s, _e = DiamondBackData.Instance:ActOpenStartTime()
	self.node_t_list.lbl_suit_time.node:setString(string.format(Language.DiamondBack.OpneTimeShow, _s.year, _s.month, _s.day, _e.year, _e.month, _e.day))
end

function SuitLimitBackView:ShowIndexCallBack()
	self:Flush()
end

function SuitLimitBackView:OnSuitBack()
	self:Flush()
end

function SuitLimitBackView:OnBagItemChange()
	for i, v in ipairs(self.suit_list:GetAllItems()) do
		v:OnFlush()
	end
end


function SuitLimitBackView:SuitLimitList()
	if nil == self.suit_list then
		local ph = self.ph_list.ph_suit_list
		self.suit_list = ListView.New()
		self.suit_list:Create(ph.x, ph.y, ph.w, ph.h, nil, SuitLimitBackView.SuitLimitRender, nil, nil, self.ph_list.ph_suit_item)
		-- self.suit_list:GetView():setAnchorPoint(0, 0)
		self.suit_list:SetJumpDirection(ListView.Top)
		self.node_t_list.layout_suit_back.node:addChild(self.suit_list:GetView(), 100)
	end		
end

function SuitLimitBackView:OnFlush(param_t)
	self.suit_list:SetDataList(DiamondBackData.Instance:GetSuitList())
end

SuitLimitBackView.SuitLimitRender = BaseClass(BaseRender)
local SuitLimitRender = SuitLimitBackView.SuitLimitRender
function SuitLimitRender:__init()	

end

function SuitLimitRender:__delete()	
	if self.cell_list then
		self.cell_list:DeleteMe()
		self.cell_list = nil 
	end

	if self.cell then
		self.cell:DeleteMe()
		self.cell = nil 
	end
end

function SuitLimitRender:CreateChild()
	BaseRender.CreateChild(self)

	local ph = self.ph_list["ph_cell_list"] or {x = 0, y = 0, w = 1, h = 1,}
	local ph_item = {x = 0, y = 0, w = BaseCell.SIZE, h = BaseCell.SIZE,}
	local parent = self.view
	local item_render = BaseCell
	local line_dis = ph_item.w + 2
	local direction = ScrollDir.Horizontal -- 滑动方向-横向 -- Vertical=1：竖向 Horizontal=2：横向：Both=3：横竖都可以
	
	local grid_scroll = GridScroll.New()
	grid_scroll:Create(ph.x, ph.y, ph.w, ph.h, 1, line_dis, item_render, direction, false, ph_item)
	parent:addChild(grid_scroll:GetView(), 20)
	self.cell_list = grid_scroll

	local parent = self.view
	local ph = self.ph_list["ph_cell"] or {x = 0, y = 0, w = 10, h = 10}
	local cell = BaseCell.New()
	cell:SetPosition(ph.x, ph.y)
	parent:addChild(cell:GetView(), 99)
	self.cell = cell

	XUI.AddClickEventListener(self.node_tree.btn_suit_back.node, BindTool.Bind1(self.OnSuitBack, self), true)
end

function SuitLimitRender:OnFlush()
	if self.data == nil then return end


	local cfg = self.data.cfg or {}
	local consume = cfg.consume or {}
	local can_recycle = true -- 可以分解
	local list = {}
	for index, item in ipairs(consume) do
		list[index] = ItemData.InitItemDataByCfg(item)
		if can_recycle then
			local num = BagData.Instance:GetItemNumInBagById(item.id)
			can_recycle = num >= item.count
		end
	end
	self.cell_list:SetDataList(list)
	self.cell_list:GetView():jumpToTop()

	local award = cfg.awards and cfg.awards[1]
	self.cell:SetData(ItemData.InitItemDataByCfg(award))

	local color = self.data.suit_num ~= 0 and COLOR3B.GREEN or Str2C3b("9c9181")
	self.node_tree["lbl_suit_num"].node:setColor(color)
	self.node_tree.lbl_suit_num.node:setString(string.format(Language.DiamondBack.RemindSuit, self.data.suit_num))

	self.node_tree.btn_suit_back.node:setEnabled(can_recycle)
	self.node_tree.btn_suit_back.node:setVisible(self.data.suit_num ~= 0)
end

function SuitLimitRender:OnSuitBack()
	DiamondBackCtrl.Instance:SendDiamondBackReq(1, self.data.suit_index)
end

function SuitLimitRender:CreateSelectEffect()
end

return SuitLimitBackView