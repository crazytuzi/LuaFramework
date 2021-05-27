HeroGoldDunView = HeroGoldDunView or BaseClass(XuiBaseView)

function HeroGoldDunView:__init()
	self.config_tab = {
		{"common_ui_cfg", 1, {0}},
		{"common_ui_cfg", 2, {0}},
		{"hero_gold_ui_cfg", 1, {0}},
	}
	self.texture_path_list = {
		"res/xui/knight.png",
		"res/xui/hero_gold.png",}
	self:SetModal(true)
	self.title_img_path = ResPath.GetHeroGold("hero_gold_dun_title")
end

function HeroGoldDunView:__delete()
end

function HeroGoldDunView:ReleaseCallBack()
	if  self.monster_display then
		self.monster_display:DeleteMe()
		self.monster_display = nil
	end
	if self.soul_stone  then
		for k,v in ipairs(self.soul_stone) do
			v:DeleteMe()
		end
		self.soul_stone = nil
	end
	if self.soul_cell  then
		for k,v in ipairs(self.soul_cell) do
			v:DeleteMe()
		end
		self.soul_cell = nil
	end
	-- self.cell_temp:DeleteMe()
	-- self.cell_temp = nil
	if self.draw_node then
		self.draw_node:clear()
		self.draw_node:removeFromParent()
		self.draw_node = nil
	end
	self.effec_1 = nil
	if self.achieve_evt then
		GlobalEventSystem:UnBind(self.achieve_evt)
		self.achieve_evt = nil
	end
end

function HeroGoldDunView:CreateSoulStoneCell()
	self:UpdateButton()
	local cfg = HeroGoldDunData.Instance:GetEquipBossCfg()
	self.draw_node = cc.DrawNode:create()
	self.node_t_list.layot_gold_dun.node:addChild(self.draw_node, 100)
	self.draw_node:clear()
	if not self.soul_stone then
		self.soul_stone = {}
		local data = {}
		for i,v in ipairs(cfg) do
			local ph = self.ph_list["ph_img_"..i]
			data[i] = {id = 0, num = 1, is_bind = 0, index = i, level = 0, bool_open = 0, pos = 0, activate =0}
			local cur_data = v
			local img_red
			if i ~= 5 then
				local pos1,pos2
				if i == 1 then
					pos1,pos2 = cc.p(ph.x+50,ph.y+133),cc.p(ph.x+50,ph.y+213)
				 	self:drawLine(pos1,pos2)
					img_red = XUI.CreateImageView(ph.x+50+180, ph.y+213, ResPath.GetKnight("temp_dot"), true)
					pos1,pos2 = cc.p(ph.x+50+180,ph.y+213),cc.p(ph.x+50,ph.y+213)
				 	self:drawLine(pos1,pos2)						
				elseif i == 2 then
					pos1,pos2 = cc.p(ph.x+50,ph.y+133),cc.p(ph.x+50,ph.y+213)
				 	self:drawLine(pos1,pos2)
					img_red = XUI.CreateImageView(ph.x+50-170, ph.y+213, ResPath.GetKnight("temp_dot"), true)
					pos1,pos2 = cc.p(ph.x+50-170,ph.y+213),cc.p(ph.x+50,ph.y+213)				 	
				 	self:drawLine(pos1,pos2)
				elseif i == 3 then
					pos1,pos2 = cc.p(ph.x+50,ph.y+133),cc.p(ph.x+50,ph.y+193)
					self:drawLine(pos1,pos2)
					img_red = XUI.CreateImageView(ph.x+50-80, ph.y+193, ResPath.GetKnight("temp_dot"), true)
					pos1,pos2 = cc.p(ph.x+50-80,ph.y+193),cc.p(ph.x+50,ph.y+193)
				 	self:drawLine(pos1,pos2)
				elseif i == 4 then
					pos1,pos2 = cc.p(ph.x+50,ph.y+133),cc.p(ph.x+50,ph.y+193)
					self:drawLine(pos1,pos2)
					img_red = XUI.CreateImageView(ph.x+50+100, ph.y+193, ResPath.GetKnight("temp_dot"), true)
					pos1,pos2 = cc.p(ph.x+50+100,ph.y+193),cc.p(ph.x+50,ph.y+193)
				 	self:drawLine(pos1,pos2)			
				end
			else
				self:drawLine(cc.p(ph.x+50,ph.y+133), cc.p(ph.x+50,ph.y+183))
				img_red = XUI.CreateImageView(ph.x+50,ph.y+183, ResPath.GetKnight("temp_dot"), true)
			end
			self.node_t_list.layot_gold_dun.node:addChild(img_red, 100)
			local cell = self:CreateStoneRender(ph, cur_data,i)
			cell:AddClickEventListener(BindTool.Bind1(self.OnClickCell, self), true)
			table.insert(self.soul_stone, cell)			
		end
		if not self.effec_1 then
				local ph = self.ph_list["current_container"]
				self.effec_1 = AnimateSprite:create()
				self.node_t_list.layot_gold_dun.node:addChild(self.effec_1,99)
				self.effec_1:setPosition(ph.x,ph.y)
				local path, name = ResPath.GetEffectAnimPath(GodShieldBossConfig.shieldEffect)
				self.effec_1:setAnimate(path, name, loop or COMMON_CONSTS.MAX_LOOPS, 0.17, false)
		end
	end
	if not self.soul_cell then
		self.soul_cell = {}
		local ph = self.ph_list["ph_reward_cell"]
		for i = 1, 4 do
			local cell = BaseCell.New()
			cell:SetPosition(ph.x+(i-1)*90, ph.y)
			cell:GetView():setAnchorPoint(0, 0)
			cell:GetView():setVisible(false)
			self.node_t_list.layot_gold_dun.node:addChild(cell:GetView(), 103)
			table.insert(self.soul_cell, cell)
		end
	end
	self.select_data1 = cfg[1]
	self.select_index = 1
	if self.select_data1 then
		self:setStoneRenderData(self.select_data1.DropsShow)	
		local config = ItemData.Instance:GetItemConfig(self.select_data1.enterConsume[1].id)
		self:setStoneLeveltxt(self.select_data1.enterLevelLimit[1],self.select_data1.enterLevelLimit[2],config.name,self.select_data1.enterConsume[1].count)
		local monster_cfg = BossData.GetMosterCfg(self.select_data1.monsters[1].monsterId)
		if monster_cfg then
			self.monster_display:Show(monster_cfg.modelid)
		end
		local flag = 0
		local role_level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)		-- 人物等级
		local circle_level = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)		-- 人物转生等级
		if role_level>=self.select_data1.enterLevelLimit[2] and circle_level >= self.select_data1.enterLevelLimit[1] and self.select_data1.state==0  then
			flag = 1
		end
		if self.select_data1.state==0 then
			self.node_t_list.btn_map_1.node:setTitleText(Language.HeroGold.NoFit)
		else
			self.node_t_list.btn_map_1.node:setTitleText(Language.HeroGold.HadFit)
		end
		XUI.SetLayoutImgsGrey(self.node_t_list.btn_map_1.node, flag <= 0, true)
	end
	-- if not self.cell_temp then
	-- 	local ph = self.ph_list["ph_cell"]
	-- 	self.cell_temp = BaseCell.New()
	-- 	self.cell_temp:SetPosition(ph.x, ph.y)
	-- 	self.cell_temp:GetView():setAnchorPoint(0, 0)
	-- 	self.cell_temp:SetData({item_id = GodShieldBossConfig.showIcon, num = 0, is_bind = 0})
	-- 	self.node_t_list.layot_gold_dun.node:addChild(self.cell_temp:GetView(), 103)
	-- 	self.node_t_list.txt_title_show.node:setString(GodShieldBossConfig.shieldName)
	-- end
	self.node_t_list.ph_cell.node:loadTexture(ResPath.GetItem(GodShieldBossConfig.showIcon))
	RichTextUtil.ParseRichText(self.node_t_list.txt_show1.node,GodShieldBossConfig.getDesc,18,cc.c3b(0xff, 0xff, 0xff))	
	RichTextUtil.ParseRichText(self.node_t_list.txt_show2.node,GodShieldBossConfig.attDesc,18,cc.c3b(0xff, 0xff, 0xff))
	RichTextUtil.ParseRichText(self.node_t_list.txt_show3.node,GodShieldBossConfig.skillDesc,18,cc.c3b(0xff, 0xff, 0xff))
end

function HeroGoldDunView:drawLine(pos1, pos2)
	self.draw_node:drawSegment(pos1, pos2, 1, cc.c4f(0.894, 0.741, 0.137, 1))
end

function HeroGoldDunView:setStoneLeveltxt(circle,level,money,num)
	if circle> 0 then
		RichTextUtil.ParseRichText(self.node_t_list.txt_desc.node,string.format(Language.HeroGold.DunCostTxt2,circle,level,money,num),22,cc.c3b(0x00, 0xff, 0x00))
	else
		RichTextUtil.ParseRichText(self.node_t_list.txt_desc.node,string.format(Language.HeroGold.DunCostTxt1,level,money,num),22,cc.c3b(0x00, 0xff, 0x00))
	end
	self.node_t_list.txt_desc.node:setHorizontalAlignment(RichHAlignment.HA_CENTER)
end

function HeroGoldDunView:setStoneRenderData(data)
	if not data then return end 
	for i,v in ipairs(self.soul_cell) do
		v:GetView():setVisible(true)
	end
	for i,v in ipairs(data) do
		self.soul_cell[i]:GetView():setVisible(true)
		if v.type >0 then
			local virtual_item_id = ItemData.Instance:GetVirtualItemId(v.type)
			self.soul_cell[i]:SetData({item_id = virtual_item_id, num = v.count, is_bind = 0,strengthen_level= v.strong})
		else
			self.soul_cell[i]:SetData({item_id = v.id, num = v.count, is_bind = 0,strengthen_level= v.strong})
		end
	end
end

function HeroGoldDunView:CreateStoneRender(ph, cur_data,index)
	local cell = HeroGoldDunRender.New()
	local render_ph = self.ph_list.lay_tocell
	cell:SetUiConfig(render_ph, true)
	cell:SetIndex(index)
	cell:GetView():setPosition(ph.x, ph.y)
	self.node_t_list.layot_gold_dun.node:addChild(cell:GetView(), 999)
	if cur_data then	
		cell:SetData(cur_data)
	end
	return cell
end

function HeroGoldDunView:OnClickCell(cell)
	if nil == cell and  cell:GetData() ~= nil then return end
	self.select_data1 = cell:GetData()
	self.select_index = cell:GetIndex()
	if self.select_data1 then
		local monster_cfg = BossData.GetMosterCfg(self.select_data1.monsters[1].monsterId)
		if monster_cfg then 
			self.monster_display:Show(monster_cfg.modelid)
		end
		self:setStoneRenderData(self.select_data1.DropsShow)
		local config	
		if self.select_data1.enterConsume[1].type > 0 then
			local virtual_item_id = ItemData.Instance:GetVirtualItemId(self.select_data1.enterConsume[1].type)
			config = ItemData.Instance:GetItemConfig(virtual_item_id)
		else
			config = ItemData.Instance:GetItemConfig(self.select_data1.enterConsume[1].id)
		end
		self:setStoneLeveltxt(self.select_data1.enterLevelLimit[1],self.select_data1.enterLevelLimit[2],config.name,self.select_data1.enterConsume[1].count)	
		local flag = 0
		local role_level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)		-- 人物等级
		local circle_level = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)		-- 人物转生等级
		if role_level>=self.select_data1.enterLevelLimit[2] and circle_level >= self.select_data1.enterLevelLimit[1] and self.select_data1.state==0  then
			flag = 1
		end
		if self.select_data1.state==0 then
			self.node_t_list.btn_map_1.node:setTitleText(Language.HeroGold.NoFit)
		else
			self.node_t_list.btn_map_1.node:setTitleText(Language.HeroGold.HadFit)
		end
		XUI.SetLayoutImgsGrey(self.node_t_list.btn_map_1.node, flag <= 0, true)
	end
end

function HeroGoldDunView:creatBoss()
	if not self.monster_display then
		local ph = self.ph_list.ph_page10_model
		self.monster_display = ModelAnimate.New(ResPath.GetMonsterAnimPath, self.node_t_list.layot_gold_dun.node, GameMath.MDirDown)
		self.monster_display:SetAnimPosition(ph.x,ph.y)
		self.monster_display:SetFrameInterval(FrameTime.RoleStand)
		self.monster_display:SetZOrder(9999)
	end
end	

function HeroGoldDunView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self:creatBoss()
		self:CreateSoulStoneCell()
		self.node_t_list.btn_activity.node:addClickEventListener(BindTool.Bind(self.OnActivity, self))
		self.node_t_list.btn_map_1.node:addClickEventListener(BindTool.Bind(self.OnChallenge, self))
		self.achieve_evt = GlobalEventSystem:Bind(HeroGoldEvent.HeroGoldDun, BindTool.Bind(self.UpdateData, self))
	end
end

function HeroGoldDunView:OnChallenge()
	if not self.select_index then return end
	HeroGoldDunCtrl.Instance:HeroDunReq(2,self.select_index)
end

function HeroGoldDunView:OnActivity()
	HeroGoldDunCtrl.Instance:HeroDunReq(3,0)
end

function HeroGoldDunView:UpdateData()
	local cfg = HeroGoldDunData.Instance:GetEquipBossCfg()
	if cfg  then
		for i,v in ipairs(cfg) do
			self.soul_stone[i]:SetData(v)
		end
	end
	self:UpdateButton()
end

function HeroGoldDunView:UpdateButton()
	local activat = HeroGoldDunData.Instance:GetEquipDunState()
	XUI.SetLayoutImgsGrey(self.node_t_list.btn_activity.node, activat == 1, true)
end

function HeroGoldDunView:OnClose()
	self:Close()
	AudioManager.Instance:PlayClickBtnSoundEffect()
end

function HeroGoldDunView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
	HeroGoldDunCtrl.Instance:HeroDunReq(1,0)
end

function HeroGoldDunView:ShowIndexCallBack(index)
	self:Flush(index)
end

function HeroGoldDunView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function HeroGoldDunView:OnFlush(param_t, index)

end


HeroGoldDunRender = HeroGoldDunRender or BaseClass(BaseRender)
function HeroGoldDunRender:__init()

end

function HeroGoldDunRender:__delete()

end

function HeroGoldDunRender:CreateChild()
	BaseRender.CreateChild(self)
end

function HeroGoldDunRender:OnFlush()
	if nil == self.data then return end
	local path = nil 
	local monster_cfg = BossData.GetMosterCfg(self.data.monsters[1].monsterId)
	if monster_cfg == nil then
		return 
	end
	local id = 10000
	if monster_cfg.icon > 0 then
		id = monster_cfg.icon
	end
	self.node_tree.img_bg.node:loadTexture(ResPath.GetBossHead("boss_icon_"..id))
	local monster_data = ConfigManager.Instance:GetMonsterConfig(self.data.monsters[1].monsterId)
	if monster_data and monster_data.name then
		local strname = DelNumByString(monster_data.name)
		self.node_tree.txt_1.node:setString(strname)
	end
	local str =  string.format(Language.StrenfthFb.Limit_level,self.data.enterLevelLimit[2]) 
	if self.data.enterLevelLimit[1]>0 then
		self.node_tree.txt_2.node:setString(self.data.enterLevelLimit[1]..Language.Common.Zhuan..str)
	else
		self.node_tree.txt_2.node:setString(str)
	end
	self.node_tree.txt_2.node:setColor(COLOR3B.BRIGHT_GREEN)
	self.node_tree.img_hadfit.node:setVisible(self.data and self.data.state== 1 or false)
	if self.data.state==1 then
		self.node_tree.txt_2.node:setString(Language.HeroGold.EndFit)
		self.node_tree.txt_2.node:setColor(COLOR3B.G_W2)
	end

end

