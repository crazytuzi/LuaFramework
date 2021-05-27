-- 蚩尤结界

local ChiYouBossView = BaseClass(SubView)

function ChiYouBossView:__init()
	self:SetModal(true)
	self.texture_path_list = {
		'res/xui/chi_you.png',
		'res/xui/boss.png'
	}
	self.config_tab = {
		{"new_boss_ui_cfg", 10, {0}},
	}
	
	self.cy_num = 0
end

function ChiYouBossView:ReleaseCallBack()
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
end

function ChiYouBossView:LoadCallBack(index, loaded_times)
	self:CreateRewardCells()
	self:CreateBossGrid()

	XUI.AddClickEventListener(self.node_t_list.btn_shenshi.node, BindTool.Bind2(self.OnShenshi, self))
	XUI.AddClickEventListener(self.node_t_list.btn_ques2.node, BindTool.Bind2(self.OpenTip, self))

	XUI.AddClickEventListener(self.node_t_list.btn_left.node, BindTool.Bind2(self.OnBtnLeft, self))
	XUI.AddClickEventListener(self.node_t_list.btn_right.node, BindTool.Bind2(self.OnBtnRight, self))

	EventProxy.New(ChiYouData.Instance, self):AddEventListener(ChiYouData.CHIYOU_BOSS_NUM, BindTool.Bind(self.OnChiyouNum, self))
	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.OnChiyouNum, self))--监听背包变化

	local ph = self.ph_list["ph_layer_num"]
	self.layer_num = NumberBar.New()
	self.layer_num:SetRootPath(ResPath.GetCommon("num_143_"))
	self.layer_num:SetPosition(ph.x+30, ph.y)
	self.layer_num:SetGravity(NumberBarGravity.Center)
	self.node_t_list["layout_chiyou"].node:addChild(self.layer_num:GetView(), 300, 300)
	self:AddObj("layer_num")
end

function ChiYouBossView:OpenTip( ... )
	DescTip.Instance:SetContent(Language.DescTip.CHiYouContent, Language.DescTip.CHiYouTitle)
end

function ChiYouBossView:OnChiyouNum()
	self:Flush()
end

function ChiYouBossView:CreateBossGrid()
	local ph = self.ph_list.ph_boss_list
	local cell_num = #ChiYouJieZhenCfg.BossId
	if nil == self.chiyou_grid  then
		self.chiyou_grid = BaseGrid.New() 
		self.chiyou_grid:SetPageChangeCallBack(BindTool.Bind(self.OnPageChangeCallBack, self))
		local grid_node = self.chiyou_grid:CreateCells({w = ph.w, h = ph.h, itemRender = ChiyouBossRender, ui_config = self.ph_list.ph_boss_panel, cell_count = cell_num, col = 1, row = 1})
		self.node_t_list.layout_chiyou.node:addChild(grid_node, 10)
		self.chiyou_grid:GetView():setPosition(ph.x, ph.y)
		local fanli_list = ChiYouJieZhenCfg.BossId
		if not fanli_list[0] and fanli_list[1] then
			fanli_list[0] = table.remove(fanli_list, 1)
		end
		self.chiyou_grid:SetDataList(fanli_list)
	end
	self:AddObj("chiyou_grid")
end

function ChiYouBossView:OnPageChangeCallBack()
	self:UpdateBtnState()
end

-- 左边按钮点击
function ChiYouBossView:OnBtnLeft()
	local index = self.chiyou_grid:GetCurPageIndex() or 0
	if index > 1 then
		self.chiyou_grid:ChangeToPage(index - 1)
	end
	self:UpdateBtnState()
end

-- 右边按钮点击
function ChiYouBossView:OnBtnRight()
	local index = self.chiyou_grid:GetCurPageIndex() or 0
	if index < self.chiyou_grid:GetPageCount() then
		self.chiyou_grid:ChangeToPage(index + 1)
	end
	self:UpdateBtnState()
end

function ChiYouBossView:UpdateBtnState()
	self.node_t_list.btn_left.node:setVisible(not (self.chiyou_grid:GetCurPageIndex() == 1))
	self.node_t_list.btn_right.node:setVisible(not (self.chiyou_grid:GetCurPageIndex() == self.chiyou_grid:GetPageCount()))

	self.node_t_list.img_boss_name.node:loadTexture(ResPath.GetBoss("chiyou_name" .. self.chiyou_grid:GetCurPageIndex()))
end

function ChiYouBossView:CreateRewardCells()
	self.cell_list = {}
	for i = 1, 8 do
		local ph = self.ph_list["ph_item_cell" .. i]
		local cell = BaseCell.New()
		cell:SetPosition(ph.x, ph.y)
		cell:SetAnchorPoint(0.5, 0.5)
		self.node_t_list.layout_chiyou.node:addChild(cell:GetView(), 103)
		table.insert(self.cell_list, cell)
	end
	self:SetCellData()
end

function ChiYouBossView:ShowIndexCallBack(index)
	self:Flush()
end

function ChiYouBossView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
	ChiYouCtrl.SendChiYouReq(1)
end

function ChiYouBossView:CloseCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function ChiYouBossView:OnFlush(param_t, index)
	local num = ChiYouData.Instance:GetChiyouTime()
	self.cy_num = num

	local n = BagData.Instance:GetItemNumInBagById(ChiYouJieZhenCfg.consume.id, nil)
	local num_str = string.format(Language.Blessing.ChiyouNum, n)
	RichTextUtil.ParseRichText(self.node_t_list.rich_shenshi_num.node, num_str, 18)
	XUI.RichTextSetCenter(self.node_t_list.rich_shenshi_num.node)

	self.layer_num:SetNumber(num)

	self.node_t_list.img_cy_falg.node:setVisible(ChiYouData.Instance:RemindChiyouNum() > 0)

	self:UpdateBtnState()
end

function ChiYouBossView:SetCellData()
	local data = ChiYouJieZhenCfg.PreviewAward
	for k,v in pairs(self.cell_list) do
		local item_data = {}
		if nil ~= data[k] then
			item_data.item_id = data[k].id
			item_data.num = data[k].count
			item_data.is_bind = data[k].bind or 0
			
			v:SetData(item_data)
		else
			v:SetData(nil)
		end
	end
end

function ChiYouBossView:OnShenshi()
	local n = BagData.Instance:GetItemNumInBagById(ChiYouJieZhenCfg.consume.id, nil)
	if n > 0 then
		if self.cy_num == ChiYouJieZhenCfg.throwMax then
			Scene.SendQuicklyTransportReqByNpcId(ChiYouJieZhenCfg.NpcId)
		else
			ChiYouCtrl.SendChiYouReq(2)
		end
	else
		TipCtrl.Instance:OpenGetStuffTip(ChiYouJieZhenCfg.consume.id)
	end
end

ChiyouBossRender = ChiyouBossRender or BaseClass(BaseRender)
function ChiyouBossRender:__init()
	self.chiyou_display = nil
end

function ChiyouBossRender:__delete()
	if self.chiyou_display then
		self.chiyou_display:DeleteMe()
		self.chiyou_display = nil 
	end
end

function ChiyouBossRender:CreateChild()
	BaseRender.CreateChild(self)
	
	local ph = self.ph_list.ph_dia_boss
	if nil == self.chiyou_display then
		self.chiyou_display = ModelAnimate.New(ResPath.GetMonsterAnimPath, self.view, GameMath.MDirDown)
		self.chiyou_display:SetAnimPosition(ph.x+20, 0)
		self.chiyou_display:SetFrameInterval(FrameTime.RoleStand)
		self.chiyou_display:SetZOrder(100)
	end

	RenderUnit.CreateEffect(1108, self.view, 10, nil, nil, ph.x+20, -50)
end

function ChiyouBossRender:OnFlush()
	if nil == self.data then return end

	
	self.chiyou_display:Show(BossData.GetMosterCfg(self.data).modelid or nil)
	self.chiyou_display:SetScale(1)
end

function ChiyouBossRender:CreateSelectEffect()
end

return ChiYouBossView