 BabelTurnTableView = BabelTurnTableView or BaseClass(BaseView)

function BabelTurnTableView:__init()
	self.is_modal = true
	 self.texture_path_list = {
		'res/xui/babel.png',
	}

	self.order = 0
	self.config_tab = {
        --{"common_ui_cfg", 1, {0}},
        {"babel_ui_cfg", 4, {0}},
		--{"common_ui_cfg", 2, {0}, nil , 999},
    }
end

function BabelTurnTableView:__delete()
	-- body
end

function BabelTurnTableView:ReleaseCallBack()
	if self.cell_list then
		for k, v in pairs(self.cell_list) do
			v:DeleteMe()
		end
		self.cell_list = {}
	end

	if self.data_event then
		GlobalEventSystem:UnBind(self.data_event)
		self.data_event = nil
	end

	if self.index_event then
		GlobalEventSystem:UnBind(self.index_event)
		self.index_event = nil
	end
end

function BabelTurnTableView:LoadCallBack()
	for i=1,10 do
		self.node_t_list["stamp"..i].node:setVisible(false) 
		self.node_t_list["stamp"..i].node:setLocalZOrder(999)
	end
	self.node_t_list.img_arrow.node:setLocalZOrder(999)
	self:CreateCellList()
	self:InitTurnbel()
	self.data_event = GlobalEventSystem:Bind(BABEL_EVENET.DATA_CHANGE, BindTool.Bind1(self.OnBabelDataChange,self))

	self.index_event =  GlobalEventSystem:Bind(BABEL_EVENET.CHOUJIANG_DATA_CHANGE, BindTool.Bind1(self.OnIndexChange,self))

	XUI.AddClickEventListener(self.node_t_list.btn_draw.node, BindTool.Bind1(self.OnZhuanPan, self), true)
end

function BabelTurnTableView:CreateCellList( ... )
	self.cell_list = {}
	for i = 1,  10 do
		local ph = self.ph_list["ph_cell"..i]
		local cell = BaseCell.New()
		cell:SetPosition(ph.x, ph.y)
		self.node_t_list.layout_zhuanpan.node:addChild(cell:GetView(), 99)
		self.cell_list[i] = cell
	end
	
end

function BabelTurnTableView:OnIndexChange(index)
	self:ArrowRotateTo(index)
end

function BabelTurnTableView:OnBabelDataChange( ... )
	--self:FlushCellShow()
end

function BabelTurnTableView:OpenCallBack()
	-- body
end

function BabelTurnTableView:CloseCallBack()
	-- body
end

function BabelTurnTableView:ShowIndexCallBack(index)
	self:Flush(index)

end

function BabelTurnTableView:FlushCellShow()
	local list_data = BabelData.Instance:GetCurShowList()


	for i,v in ipairs(list_data) do
		local data = v.award
		local cell= self.cell_list[i]
		if cell then
			if data.type == tagAwardType.qatEquipment then
				cell:SetData({["item_id"] = data.id, ["num"] = data.count, is_bind = 0 , effectId = 0})
			else
				local virtual_item_id = ItemData.GetVirtualItemId(data.type)
				if virtual_item_id then
					cell:SetData({["item_id"] = virtual_item_id, ["num"] = data.count, is_bind =  0})
				end
			end
		end
	end
	local remain_num = BabelData.Instance:GetRemianChoujiangNum()
	local color = remain_num > 0 and "00ff00" or "ff0000"
	local text = string.format(Language.Babel.ChouajiangNume, color, remain_num)

	for i=1,10 do
		self.node_t_list["stamp"..i].node:setVisible(false) 
	end
	local data = BabelData.Instance:GetRewardData()
	for i=1, 10 do
		local is_get = data[i]
		self.node_t_list["stamp"..i].node:setVisible(is_get > 0)
	end

	 RichTextUtil.ParseRichText(self.node_t_list.rich_num.node, text)
	 XUI.RichTextSetCenter(self.node_t_list.rich_num.node)
end


function BabelTurnTableView:OnFlush()  
	self:FlushCellShow()
end

function BabelTurnTableView:OnZhuanPan()
	if BabelData.Instance:GetRemianChoujiangNum() <= 0 then
		SysMsgCtrl.Instance:FloatingTopRightText(Language.Babel.NotRemainNum)
		return 
	end
	BabelCtrl.Instance:SendOpeateBabel(OperateType.Choujiang)
	self:BeforRotate()
end


function BabelTurnTableView:BeforRotate()
	ItemData.Instance:SetDaley(true)
	self.node_t_list.btn_draw.node:setEnabled(false)
	self.node_t_list.img_draw_txt.node:setGrey(true)
	self.node_t_list.img_arrow.node:setRotation(0)
end


function BabelTurnTableView:ArrowRotateTo(idx)
	local circle = 2
	local to_rotate = 360 / 10 * (idx - 1) + 360 * circle + 18
	local rotate_time = 0.1 * idx + 0.8 * circle
	local rotate_by = cc.RotateBy:create(rotate_time, to_rotate)
	local sequence = cc.Sequence:create(rotate_by, cc.CallFunc:create(function () self:AfterRotate() end))
	self.node_t_list.img_arrow.node:runAction(sequence)
end


function BabelTurnTableView:AfterRotate()
	ItemData.Instance:SetDaley(false)
	self.node_t_list.btn_draw.node:setEnabled(true)
	self.node_t_list.img_draw_txt.node:setGrey(false)
	self:FlushCellShow()
end


function BabelTurnTableView:InitTurnbel()
	local a_y = 1 - ((180 -80) / 2 + 80) / 180
	self.node_t_list.img_arrow.node:setAnchorPoint(0.5, a_y)
	self.node_t_list.img_arrow.node:setPositionY(self.node_t_list.img_arrow.node:getPositionY() - 180 * (0.5 - a_y))
end