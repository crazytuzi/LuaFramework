ChiYouView = ChiYouView or BaseClass(BaseView)

function ChiYouView:__init()
	self.title_img_path = ResPath.GetWord("word_chiyou")
	self:SetModal(true)
	self:SetBackRenderTexture(true)
	
	self.texture_path_list = {
		'res/xui/chi_you.png'
	}
	self.config_tab = {
		{"common_ui_cfg", 1, {0}},
		{"chi_you_ui_cfg", 1, {0}},
		{"common_ui_cfg", 2, {0}, nil, 999},
	}
	
	self.cy_num = 0
end

function ChiYouView:ReleaseCallBack()
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	if nil ~= self.chiyou_progressbar then
		self.chiyou_progressbar:DeleteMe()
		self.chiyou_progressbar = nil
	end

	if self.chiyou_display then
		self.chiyou_display:DeleteMe()
		self.chiyou_display = nil 
	end
end

function ChiYouView:LoadCallBack(index, loaded_times)
	self.chiyou_display = nil
	self:CreateRewardCells()

	XUI.AddClickEventListener(self.node_t_list.btn_shenshi.node, BindTool.Bind2(self.OnShenshi, self))
	XUI.AddClickEventListener(self.node_t_list.btn_ques2.node, BindTool.Bind2(self.OpenTip, self))

	EventProxy.New(ChiYouData.Instance, self):AddEventListener(ChiYouData.CHIYOU_BOSS_NUM, BindTool.Bind(self.OnChiyouNum, self))
	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.OnChiyouNum, self))--监听背包变化
	
	self.chiyou_progressbar = ProgressBar.New()
	self.chiyou_progressbar:SetView(self.node_t_list.prog9_chiyou.node)
	self.chiyou_progressbar:SetTotalTime(0)
	self.chiyou_progressbar:SetTailEffect(991, nil, true)
	self.chiyou_progressbar:SetEffectOffsetX(-20)
	self.chiyou_progressbar:SetPercent(0)

	-- local pos_x, pos_y = self.node_t_list.hyd_score.node:getPosition()
	RenderUnit.CreateEffect(1108, self.node_t_list.img_boss.node, 10, nil, nil, 200, 55)

	if nil == self.chiyou_display then
		self.chiyou_display = ModelAnimate.New(ResPath.GetMonsterAnimPath, self.node_t_list.layout_chiyou.node, GameMath.MDirDown)
		self.chiyou_display:SetAnimPosition(670,150)
		self.chiyou_display:SetFrameInterval(FrameTime.RoleStand)
		self.chiyou_display:SetZOrder(100)
	end
end

function ChiYouView:OpenTip( ... )
	DescTip.Instance:SetContent(Language.DescTip.CHiYouContent, Language.DescTip.CHiYouTitle)
end

function ChiYouView:OnChiyouNum()
	self:Flush()
end

function ChiYouView:CreateRewardCells()
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

function ChiYouView:ShowIndexCallBack(index)
	self:Flush()
end

function ChiYouView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
	ChiYouCtrl.SendChiYouReq(1)
end

function ChiYouView:CloseCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function ChiYouView:OnFlush(param_t, index)
	local num = ChiYouData.Instance:GetChiyouTime()
	self.cy_num = num
	-- self.chiyou_progressbar:SetPercent(num / ChiYouJieZhenCfg.throwMax * 100)

	-- self.node_t_list.lbl_chiyou_prog.node:setString(string.format(Language.Blessing.ChiyouNum, num, ChiYouJieZhenCfg.throwMax))
	-- local txt = num == ChiYouJieZhenCfg.throwMax and Language.Blessing.ChiyouBtnTxt[2] or Language.Blessing.ChiyouBtnTxt[1]
	-- self.node_t_list.btn_shenshi.node:setTitleText(txt)

	-- self.node_t_list.btn_shenshi.node:setVisible(num ~= ChiYouJieZhenCfg.throwMax)
	-- self.chiyou_display:Show(num == ChiYouJieZhenCfg.throwMax and BossData.GetMosterCfg(ChiYouJieZhenCfg.BossId).modelid or nil)
	-- self.chiyou_display:SetScale(2)

	self.node_t_list.img_cy_falg.node:setVisible(ChiYouData.Instance:RemindChiyouNum() > 0)
end

function ChiYouView:SetCellData()
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

function ChiYouView:OnShenshi()
	-- local n = BagData.Instance:GetItemNumInBagById(ChiYouJieZhenCfg.consume.id, nil)
	-- if n > 0 then
	-- 	if self.cy_num == ChiYouJieZhenCfg.throwMax then
	-- 		Scene.SendQuicklyTransportReqByNpcId(ChiYouJieZhenCfg.NpcId)
	-- 	else
	-- 		ChiYouCtrl.SendChiYouReq(2)
	-- 	end
	-- else
	-- 	TipCtrl.Instance:OpenGetStuffTip(ChiYouJieZhenCfg.consume.id)
	-- end
	ViewManager.Instance:OpenViewByDef(ViewDef.NewlyBossView.Rare.MiJing)
end