WeddingEnterView = WeddingEnterView or BaseClass(BaseView)

function WeddingEnterView:__init()
	self.ui_config = {"uis/views/marriageview","WeddingEnterView"}
	self:SetMaskBg(true)
	self.scroller_data = {}
	self.cell_list = {}
end

function WeddingEnterView:__delete()

end

function WeddingEnterView:LoadCallBack()
	self:InitScroller()
	self:ListenEvent("Close",BindTool.Bind(self.ClickClose, self))
end

function WeddingEnterView:SetScrollerData()
	self.scroller_data = MarriageData.Instance:GetGetInviteData()
end

function WeddingEnterView:OpenCallBack()
	self:Flush()
end

function WeddingEnterView:InitScroller()
	self.scroller = self:FindObj("Scroller")
	self.scroller_data = {}
	local delegate = self.scroller.list_simple_delegate
	-- 生成数量
	delegate.NumberOfCellsDel = function()
		return #self.scroller_data
	end
	-- 格子刷新
	delegate.CellRefreshDel = function(cell, data_index)
		data_index = data_index + 1
		local item_cell = self.cell_list[cell]
		if not item_cell then
			item_cell = WedingScrollerCell.New(cell.gameObject)
			self.cell_list[cell] = item_cell
		end
		local data = self.scroller_data[data_index]
		item_cell:SetData(data)
	end
end

function WeddingEnterView:OnFlush()
	self:SetScrollerData()
	self.scroller.scroller:RefreshAndReloadActiveCellViews(true)
end

function WeddingEnterView:ReleaseCallBack()
	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	self.scroller = nil
end

function WeddingEnterView:ClickClose()
	self:Close()
end

--滚动条格子-------------------------------------
WedingScrollerCell = WedingScrollerCell or BaseClass(BaseCell)
function WedingScrollerCell:__init()
	self.male_name = self:FindVariable("MaleName")
	self.female_name = self:FindVariable("Femalename")
	self.wedding_image = self:FindVariable("WeddingImage")
	self.caiji_count = self:FindVariable("CaiJiCount")
	self.max_num = self:FindVariable("MaxNum")
	self:ListenEvent("JoinClick", BindTool.Bind(self.OnCLick, self))
end

function WedingScrollerCell:__delete()

end

function WedingScrollerCell:OnCLick()
	if Scene.Instance:GetSceneType() == SceneType.HunYanFb then
		TipsCtrl.Instance:ShowSystemMsg(Language.Marriage.AlreadyInWeeding)
	else
		MarriageCtrl.Instance:SendEnterWeeding(self.data.yanhui_fb_key)
	end
end

function WedingScrollerCell:OnFlush()
	self.male_name:SetValue(self.data.man_name)
	self.female_name:SetValue(self.data.women_name)
	local hunyan_type = self.data.hunyan_type

	local res_str = hunyan_type == 1 and "HunYan1" or "HunYan2"
	local bunble, asset = ResPath.GetMarryImage(res_str)
	self.wedding_image:SetAsset(bunble, asset)

	local max_num = 0
	local hunyan_cfg = MarriageData.Instance:GetHunYanCfg()
	if hunyan_type == 1 then
		max_num = hunyan_cfg.bind_gold_gather_max or 0
	else
		max_num = hunyan_cfg.gather_max or 0
	end
	self.max_num:SetValue(max_num)
	self.caiji_count:SetValue(max_num - self.data.garden_num)
end
