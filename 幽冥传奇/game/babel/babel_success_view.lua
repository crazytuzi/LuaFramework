 BabelSuccessView = BabelSuccessView or BaseClass(BaseView)

function BabelSuccessView:__init()
	 self.texture_path_list = {
		'res/xui/babel.png',
		'res/xui/experiment.png'
	}

	self.order = 0
	self.config_tab = {
        --{"common_ui_cfg", 1, {0}},
        {"babel_ui_cfg", 3, {0}},
		--{"common_ui_cfg", 2, {0}, nil , 999},
    }
end

function BabelSuccessView:__delete()
	-- body
end

function BabelSuccessView:ReleaseCallBack()
	if self.grid_list then
		self.grid_list:DeleteMe()
		self.grid_list = nil
	end
	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end
end

function BabelSuccessView:LoadCallBack()
	
	if self.grid_list == nil then
		local ph = self.ph_list.ph_award_list
		local grid_scroll = GridScroll.New()
		grid_scroll:Create(ph.x, ph.y, ph.w, ph.h, 3, 80, ItemRewardCellRender, ScrollDir.Vertical, false, self.ph_list.ph_grid_item)
		self.grid_list = grid_scroll
		self.node_t_list.layout_babel_win.node:addChild(grid_scroll:GetView(), 2)
		self.grid_list:GetView():setAnchorPoint(0,0)
		self.grid_list:JumpToTop()
	end

	XUI.AddClickEventListener(self.node_t_list.layout_receive.node, BindTool.Bind1(self.OnExitFuben, self))
	XUI.AddClickEventListener(self.node_t_list.layout_continue.node, BindTool.Bind1(self.OnContinue, self))
end

function BabelSuccessView:OnBabelDataChange()
	-- self:SetShowInfo()
end

function BabelSuccessView:OpenCallBack()
	-- body
end

function BabelSuccessView:CloseCallBack()
	-- body
end

function BabelSuccessView:ShowIndexCallBack(index)
	self:Flush(index)

	self.time = 3
	local callback = function()
		self.time = self.time - 1
		if self:IsOpen() then
			self.node_t_list["lbl_time"].node:setString(string.format("(%d)", self.time))
		end

		if self.time <= 0 then
			self:CancelTimer()
			self:OnContinue()
		end
	end

	self:CancelTimer()
	self.node_t_list["lbl_time"].node:setString(string.format("(%d)", self.time))
	self.timer = GlobalTimerQuest:AddTimesTimer(callback, 1, self.time)
end


function BabelSuccessView:CancelTimer()
	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end
end


function BabelSuccessView:OnContinue()
	local remian_num = BabelData.Instance:GetRemianNum()
	if remian_num > 0 then
		BabelCtrl.Instance:SendOpeateBabel(OperateType.Fighting)
		ViewManager.Instance:CloseViewByDef(ViewDef.BabelWin)
		self:CancelTimer()
	else
		SysMsgCtrl.Instance:FloatingTopRightText(Language.Babel.FightNumNotEnough)
		self:OnExitFuben()
		self:CancelTimer()
	end
end

function BabelSuccessView:OnExitFuben()
	local fuben_id = FubenData.Instance:GetFubenId()
	FubenCtrl.OutFubenReq(fuben_id)
	ViewManager.Instance:CloseViewByDef(ViewDef.BabelWin)
	self:CancelTimer()
end

function BabelSuccessView:ClearOther( ... )
	self:CancelTimer()
end


function BabelSuccessView:OnFlush(param_t)

	for k,v in pairs(param_t) do
		if k == "reward" then
			self.grid_list:SetDataList(v.reward)
		end
	end	
end


ItemRewardCellRender = ItemRewardCellRender or BaseClass(BaseRender)
function ItemRewardCellRender:__init()
	-- body
end

function ItemRewardCellRender:__delete()
	if self.cell then
		self.cell:DeleteMe()
		self.cell = nil 
	end
end

function ItemRewardCellRender:CreateChild()
	BaseRender.CreateChild(self)
	if self.cell == nil then
		local ph = self.ph_list.ph_cell_rewrad
		self.cell = BaseCell.New()
		self.cell:GetView():setPosition(ph.x, ph.y)
		self.view:addChild(self.cell:GetView(), 99)
	end
end

function ItemRewardCellRender:OnFlush()
	if self.data == nil then
		return
	end
	local item_id = self.data.id
	if self.data.id == 0 then
		item_id = 493
	end
	self.cell:SetData({item_id = item_id, num =1, is_bind = 0})
end

function ItemRewardCellRender:CreateSelectEffect()

end
