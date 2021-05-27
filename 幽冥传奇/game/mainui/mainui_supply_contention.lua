----------------------------------------------------
-- 主ui小部件（补给争夺）
----------------------------------------------------
MainuiSmallParts = MainuiSmallParts or BaseClass()

function MainuiSmallParts:InItSupplyContention()
	self.mt_layout_top_supplycontention = nil

	self.cells_list = {}
	
	self.supply_contention_score_chage = GlobalEventSystem:Bind(SupplyContentionEventType.SUPPLY_CONTENTION_SCRON_CHANGE, BindTool.Bind1(self.OnScoreChage, self))
	self.supply_contention_pos = GlobalEventSystem:Bind(SupplyContentionEventType.SUPPLY_CONTENTION_ROLE_POS_CHANGE, BindTool.Bind1(self.OnSupplyContentionRolePosChange, self))
end


function MainuiSmallParts:InitSupplyContentionUi()
	local screen_size = HandleRenderUnit:GetSize()
	local layout_width, layout_height = 181 + 170, 81
	self.mt_layout_top_supplycontention = MainuiMultiLayout.CreateMultiLayout(screen_size.width - layout_width, screen_size.height - layout_height, cc.p(0, 0), cc.size(300,150), self.mt_layout_root, -1)

	self.supply_contention_monster_headBg = XUI.CreateImageView(-125,45 - 13, ResPath.GetCommon("bg_104"), true)
	self.mt_layout_top_supplycontention:TextureLayout():addChild(self.supply_contention_monster_headBg)

	self.supply_contention_monster_head = XUI.CreateImageView(-125,45 - 13, ResPath.GetBossHead("boss_icon_10000"), true)
	self.supply_contention_monster_head:setScale(0.9)
	self.mt_layout_top_supplycontention:TextureLayout():addChild(self.supply_contention_monster_head)
	XUI.AddClickEventListener(self.supply_contention_monster_head,BindTool.Bind(self.OnClickSupplyContentionRoleBtn,self),true)

	-- self.supply_contention_monster_name = XUI.CreateText(-290,-10,200,25,cc.TEXT_ALIGNMENT_RIGHT,"")
	self.supply_contention_monster_name = XUI.CreateText(-290 + 55 + 8,-10 - 13,200,25,cc.TEXT_ALIGNMENT_CENTER,"")
	self.supply_contention_monster_name:setAnchorPoint(0, 0)
	self.supply_contention_monster_name:setColor(cc.c3b(255,255,255))
	self.mt_layout_top_supplycontention:TextureLayout():addChild(self.supply_contention_monster_name,100);


	self.supply_contention_myinfo_bg = XUI.CreateImageViewScale9(-60,0,230,100, ResPath.GetCommon("cell_bg_2"),true,cc.rect(16,17,21,18))
	self.supply_contention_myinfo_bg:setAnchorPoint(0, 0)
	self.mt_layout_top_supplycontention:TextureLayout():addChild(self.supply_contention_myinfo_bg)


	self.supply_contention_show_itemBg = XUI.CreateImageView(-60,0, ResPath.GetCommon("cell_100"), true)
	self.supply_contention_show_itemBg:setAnchorPoint(0, 0)
	self.mt_layout_top_supplycontention:TextureLayout():addChild(self.supply_contention_show_itemBg)

	self.supply_contention_show_itemPic = XUI.CreateImageView(-20,40, ResPath.GetItem("1"), true)
	self.supply_contention_show_itemPic:setAnchorPoint(0.5, 0.5)
	self.mt_layout_top_supplycontention:TextureLayout():addChild(self.supply_contention_show_itemPic)
	XUI.AddClickEventListener(self.supply_contention_show_itemPic,BindTool.Bind(self.OnClickSupplyContentionShowProps,self),true)

	self.message_text = XUI.CreateText(self.supply_contention_myinfo_bg:getPositionX() + 80, self.supply_contention_myinfo_bg:getPositionY() + 50,150,25,cc.TEXT_ALIGNMENT_LEF,Language.SupplyContentionAward.Desc_4)
	self.message_text:setAnchorPoint(0, 0)
	self.message_text:setColor(cc.c3b(255,170,0))
	self.mt_layout_top_supplycontention:TextureLayout():addChild(self.message_text);

	self.pro_bar_bg = XUI.CreateImageViewScale9(self.message_text:getPositionX() + 5, self.message_text:getPositionY() - 40, 130, 22, ResPath.GetCommon("prog_106"), true)
	self.pro_bar_bg:setAnchorPoint(0, 0)
	self.mt_layout_top_supplycontention:TextureLayout():addChild(self.pro_bar_bg)
	self.pro_bar = XUI.CreateLoadingBar(self.pro_bar_bg:getPositionX() + 15, self.pro_bar_bg:getPositionY() + 5,ResPath.GetCommon("prog_106_progress"), true, nil, true, 97, 13)
	self.pro_bar:setAnchorPoint(0, 0)
	self.mt_layout_top_supplycontention:TextureLayout():addChild(self.pro_bar)
	self.pro_bar_text = XUI.CreateText(self.pro_bar_bg:getPositionX() + 65, self.pro_bar_bg:getPositionY() + 11,self.pro_bar_bg.width,self.pro_bar_bg.height,cc.TEXT_ALIGNMENT_CENTER,"")
	self.pro_bar_text:setColor(cc.c3b(255,255,255))
	self.mt_layout_top_supplycontention:TextureLayout():addChild(self.pro_bar_text)

	self.supply_contention_show_pane = XUI.CreateLayout(-60,-100,600,100)
	self.supply_contention_show_pane:setAnchorPoint(0, 0)
	self.mt_layout_top_supplycontention:TextureLayout():addChild(self.supply_contention_show_pane)

	local layout_touch = XLayout:create(HandleRenderUnit:GetWidth(), HandleRenderUnit:GetHeight())
	local pos = self.supply_contention_show_pane:convertToNodeSpace(cc.p(0, 0))
	layout_touch:setPosition(pos.x, pos.y)
	self.supply_contention_show_pane:addChild(layout_touch)
	XUI.AddClickEventListener(layout_touch, function()
		self.supply_contention_show_pane:setVisible(false)
	end)

	self.supply_contention_show_bg = XUI.CreateImageViewScale9(0,0,230,100, ResPath.GetCommon("img9_111"),true,cc.rect(19,12,17,22))
	self.supply_contention_show_bg:setAnchorPoint(0, 0)
	self.supply_contention_show_pane:addChild(self.supply_contention_show_bg)

	self.supply_contention_show_closeBtn = XUI.CreateImageView(180,60, ResPath.GetCommon("btn_close"),true)
	self.supply_contention_show_closeBtn:setAnchorPoint(0, 0)
	self.supply_contention_show_pane:addChild(self.supply_contention_show_closeBtn)
	XUI.AddClickEventListener(self.supply_contention_show_closeBtn,BindTool.Bind(self.OnClickCloseShowPane,self),true)

	self:SetShowSupplyContention(false)
	self.supply_contention_show_pane:setVisible(false)
end	


function MainuiSmallParts:OnScoreChage(protocol)
	self.role_type = protocol.type
	if protocol.type == 0 then
		local boss_cfg = BossData.GetMosterCfg(SupplyContentionConfig.boss.monsterId)
		if boss_cfg then
			local icon = 10000
			if boss_cfg.icon and boss_cfg.icon ~= 0 then
				icon = boss_cfg.icon
			end	
			self.supply_contention_monster_head:loadTexture(ResPath.GetBossHead("boss_icon_" .. icon))
			self.supply_contention_monster_name:setString(boss_cfg.name)
			self.supply_contention_monster_head:setScale(0.9)
			self.mt_layout_top_supplycontention:TextureLayout():addChild(self.supply_contention_monster_name);
			self.supply_contention_monster_name:setColor(cc.c3b(255,255,255))	 
		end
	else
		self.supply_contention_monster_head:setScale(1)
		self.supply_contention_monster_head:loadTexture(ResPath.GetRoleHead("hero_" .. protocol.roleData.job))
		self.supply_contention_monster_name:setString(protocol.roleData.name)
		if 	protocol.roleData.teamType == protocol.my_teamType then
			self.supply_contention_monster_name:setColor(cc.c3b(0,0,255))	 
		else 
			self.supply_contention_monster_name:setColor(cc.c3b(255,0,0))
		end		 
	end

	self.my_score = protocol.my_score;
	local rank_cfg_data = SupplyContentionConfig.Awards
	local maxt_num = 0
	local pic = 0
	for i, v in ipairs(rank_cfg_data) do
		if rank_cfg_data[i].condition[1] > self.my_score then
			self.awards_data = rank_cfg_data[i].award
			pic = rank_cfg_data[i].showicon
			maxt_num = rank_cfg_data[i].condition[1];
		end
	end
	if self.my_score >= rank_cfg_data[1].condition[1] then
		self.awards_data = rank_cfg_data[1].award
		pic = rank_cfg_data[1].showicon
		maxt_num = rank_cfg_data[1].condition[1];
	end
	if maxt_num == 0 then
		maxt_num = rank_cfg_data[#rank_cfg_data].condition[1]
	end
	self.supply_contention_show_itemPic:loadTexture(ResPath.GetItem(pic))	
	self.pro_bar:setPercent(self.my_score / maxt_num * 100)
	self.pro_bar_text:setString(self.my_score.."/"..maxt_num)

	local panew = #self.awards_data * 110
	self.supply_contention_show_bg:setContentWH(panew, 100)
	self.supply_contention_show_closeBtn:setPosition(panew - 50, 60)				
end


function MainuiSmallParts:OnSupplyContentionRolePosChange(protocol)
	Scene.Instance:GetMainRole():StopMove() --移动是停止动作
	Scene.Instance:GetMainRole():LeaveFor(SupplyContentionConfig.boss.sceneId, protocol.x, protocol.y)	
end


function MainuiSmallParts:OnClickSupplyContentionRoleBtn()
	if self.role_type == 0 then
		Scene.Instance:GetMainRole():StopMove() --移动是停止动作
		Scene.Instance:GetMainRole():LeaveFor(SupplyContentionConfig.boss.sceneId, SupplyContentionConfig.boss.pos[1], SupplyContentionConfig.boss.pos[2])
	else
		SupplyContentionScoreCtrl.Instance:SendGetRolePosReq()
	end	
end

function MainuiSmallParts:OnClickSupplyContentionShowProps()
	self.supply_contention_show_pane:setVisible(true)
	self:CreateSupplyContentionCell(self.awards_data,self.cells_list,self.supply_contention_show_pane);
end

function MainuiSmallParts:OnClickCloseShowPane()
	self.supply_contention_show_pane:setVisible(false)
end

function MainuiSmallParts:CreateSupplyContentionCell(awards_data,list,pane)
	local cell
	local propsId
	local count
	for i, v in ipairs(awards_data) do
		if not list[i] then
			cell = BaseCell.New()
			cell:SetPosition((i - 1) * 100 + 5, 10)
			cell:SetIndex(i)
			cell:SetAnchorPoint(0, 0)
			cell:SetCellBg(ResPath.GetCommon("cell_100"))
			pane:addChild(cell:GetView(), 100)
			list[i] = cell
		else
			cell = list[i]	
		end
		if v.type > 0 then
			propsId = ItemData.Instance:GetVirtualItemId(v.type)
			if v.type == tagAwardType.qatAddExp then
				count = ItemData.Instance:CalcuSpecialExpVal(v)
			else
				count = v.count
			end
		else
			propsId	= v.id
			count = v.count
		end 
		cell:SetData({item_id = propsId, num = count, is_bind = v.bind})
	end
end


function MainuiSmallParts:SetShowSupplyContention(value)
	self.mt_layout_top_supplycontention:TextureLayout():setVisible(value)
end