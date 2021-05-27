local OneForeverBackView = BaseClass(SubView)

function OneForeverBackView:__init()
	self.texture_path_list = {
		--'res/xui/boss.png',
	}
    self.config_tab = {
		{"diamond_back_ui_cfg", 4, {0}},
	}
end

function OneForeverBackView:__delete()
end

function OneForeverBackView:ReleaseCallBack()
	if self.onef_list then
		self.onef_list:DeleteMe()
		self.onef_list = nil
	end
end

function OneForeverBackView:LoadCallBack(index, loaded_times)
	self:OneForeverBackList()
	
	EventProxy.New(DiamondBackData.Instance, self):AddEventListener(DiamondBackData.ONE_FOREVER_BACK, BindTool.Bind(self.OnOneForeverBack, self))
	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.OnOneForeverBack, self))
end

function OneForeverBackView:ShowIndexCallBack()
	self:Flush()
end

function OneForeverBackView:OnOneForeverBack()
	self:Flush()
end

function OneForeverBackView:OneForeverBackList()
	if nil == self.onef_list then
		local ph = self.ph_list.ph_onef_list
		self.onef_list = ListView.New()
		self.onef_list:Create(ph.x, ph.y, ph.w, ph.h, nil, OneForeverBackView.OneForeverRender, nil, nil, self.ph_list.ph_onef_item)
		-- self.onef_list:GetView():setAnchorPoint(0, 0)
		self.onef_list:SetJumpDirection(ListView.Top)
		self.node_t_list.layout_one_forver.node:addChild(self.onef_list:GetView(), 100)
	end		
end

function OneForeverBackView:OnFlush(param_t)
	self.onef_list:SetDataList(DiamondBackData.Instance:GetOneForeverList())
end

OneForeverBackView.OneForeverRender = BaseClass(BaseRender)
local OneForeverRender = OneForeverBackView.OneForeverRender
function OneForeverRender:__init()	

end

function OneForeverRender:__delete()	
	if self.cell_1 then
		self.cell_1:DeleteMe()
		self.cell_1 = nil 
	end

	if self.cell_2 then
		self.cell_2:DeleteMe()
		self.cell_2 = nil 
	end
end

function OneForeverRender:CreateChild()
	BaseRender.CreateChild(self)

	XUI.AddClickEventListener(self.node_tree.btn_onef_back.node, BindTool.Bind1(self.OnonefBack, self), true)

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

function OneForeverRender:OnFlush()
	if self.data == nil then return end

	local color = self.data.onef_num > 0 and self.data.onef_num ~= 0 and COLOR3B.GREEN or Str2C3b("9c9181")
	self.node_tree.lbl_onef_num.node:setColor(color)
	self.node_tree.lbl_onef_num.node:setString(string.format(Language.DiamondBack.RemindNum, self.data.onef_num))
	self.node_tree.btn_onef_back.node:setVisible(self.data.onef_num ~= 0)
	self.node_tree.btn_onef_back.node:setEnabled(self.data.onef_is_back == 1)
	
	local cfg = self.data.cfg or {}
	local consume = cfg.consume and cfg.consume[1]
	self.cell_1:SetData(ItemData.InitItemDataByCfg(consume))

	local award = cfg.awards and cfg.awards[1]
	self.cell_2:SetData(ItemData.InitItemDataByCfg(award))
end

function OneForeverRender:OnonefBack()
	DiamondBackCtrl.Instance:SendDiamondBackReq(2, self.data.onef_index)
end

function OneForeverRender:CreateSelectEffect()
end

return OneForeverBackView