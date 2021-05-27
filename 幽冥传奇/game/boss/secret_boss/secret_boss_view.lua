local SecretBossView = BaseClass(SubView)

function SecretBossView:__init()
	self.texture_path_list = {
		'res/xui/boss.png',
	}
    self.config_tab = {
    	{"boss_ui_cfg", 1, {0}},
		{"boss_ui_cfg", 5, {0}},
	}
end

function SecretBossView:__delete()
end

function SecretBossView:LoadCallBack(index, loaded_times)
	self:CreateBossList()
	self:CreateDropCells()
	self:CreateMonsterAnimation()
	
	self.rich_link = RichTextUtil.CreateLinkText(Language.Boss.SecretBossTimesBuy, 16, COLOR3B.GREEN, nil, true)
	self.rich_link:setPosition(600, 76)
	self.node_t_list.layout_secret_boss.node:addChild(self.rich_link, 100)
	
	XUI.AddClickEventListener(self.rich_link, BindTool.Bind(self.OnClickBuyTimes, self))
	XUI.AddClickEventListener(self.node_t_list.layout_secret_boss.btn_tip.node, BindTool.Bind(self.OnClickTipHandler, self))
	XUI.AddClickEventListener(self.node_t_list.layout_secret_boss.btn_join_challenge.node, BindTool.Bind(self.OnClickJoinChallenge, self))
	
	EventProxy.New(SecretBossData.Instance, self):AddEventListener(SecretBossData.UPDATA_SECRET_DATA, BindTool.Bind(self.OnUpdateSecretData, self))
	EventProxy.New(BossData.Instance, self):AddEventListener(BossData.UPDATE_BOSS_DATA, BindTool.Bind(self.OnUpdateBossData, self))
	EventProxy.New(RoleData.Instance, self):AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.RoleAttrChange, self))
	EventProxy.New(LunHuiData.Instance, self):AddEventListener(LunHuiData.LUNHUI_DATA_CHANGE, BindTool.Bind(self.OnBossStateChange, self))
	self.scene_change = GlobalEventSystem:Bind(SceneEventType.SCENE_CHANGE_COMPLETE, BindTool.Bind(self.SceneChange, self))
	SecretBossCtrl.Instance.GetSecretBossReq(1)
	self.boss_id = 0
	self.boss_type = 0
	self.enter_scene = 0
	self.boss_rest_time = 0
	self.node_t_list.lbl_boss_reflush_time.node:setVisible(false)
	self.txt_remind_link = RichTextUtil.CreateLinkText(Language.Common.RemindSet, 20, COLOR3B.GREEN)
	self.txt_remind_link:setPosition(844, 454)
	self.node_t_list.layout_secret_boss.node:addChild(self.txt_remind_link, 50)
	XUI.AddClickEventListener(self.txt_remind_link, BindTool.Bind(self.OnClickLinkText, self), true)


	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.OnBagItemChange, self))
end

--显示指数回调
function SecretBossView:ShowIndexCallBack(index)
	local secret_data = SecretBossData.Instance:GetSecretData()
	self.node_t_list.layout_secret_boss.lbl_juanzhou_num.node:setString(string.format(Language.Boss.ScrestScrollNum, BagData.Instance:GetItemNumInBagById(secret_data.consume)))
end

function SecretBossView:CreateTimer()
	if self.boss_rest_time > 0 then 
		CountDown.Instance:RemoveCountDown(self.timer1)
		self.timer1 = CountDown.Instance:AddCountDown(self.boss_rest_time, 1, BindTool.Bind(self.UpdateTimer,self))
	else
		self.node_t_list.lbl_boss_reflush_time.node:setVisible(false)
	end
end

function SecretBossView:UpdateTimer()
	self.boss_rest_time=self.boss_rest_time-1
	if self.boss_rest_time <= 0 then
		self.node_t_list.lbl_boss_reflush_time.node:setVisible(false)
		self.boss_rest_time=0
		CountDown.Instance:RemoveCountDown(self.timer1)
	else 
		self.node_t_list.lbl_boss_reflush_time.node:setVisible(true)
	end
	str = string.format(Language.Boss.BossRebornStr, TimeUtil.FormatSecond(self.boss_rest_time))
	self.node_t_list.lbl_boss_reflush_time.node:setString(str)
end

function SecretBossView:ReleaseCallBack()
	if self.boss_list then
		self.boss_list:DeleteMe()
		self.boss_list = nil 
	end

	if self.monster_display then
		self.monster_display:DeleteMe()
		self.monster_display = nil 
	end

	if self.drop_cell_list  then
		for k,v in pairs(self.drop_cell_list ) do
			v:DeleteMe()
		end
		self.drop_cell_list = nil
	end
	CountDown.Instance:RemoveCountDown(self.timer1)
	GlobalEventSystem:UnBind(self.scene_change)
end

function SecretBossView:CreateMonsterAnimation()
	if nil == self.monster_display then
		self.monster_display = ModelAnimate.New(ResPath.GetMonsterAnimPath, self.node_t_list.layout_secret_boss.node, GameMath.MDirDown)
		self.monster_display:SetAnimPosition(500,280)
		self.monster_display:SetFrameInterval(FrameTime.RoleStand)
		self.monster_display:SetZOrder(20)
	end
end

function SecretBossView:CreateBossList()
	if nil ~= self.boss_list then
		return
	end

	local ph = self.ph_list.ph_boss_list
	self.boss_list = ListView.New()
	self.boss_list:Create(ph.x + 6, ph.y, ph.w, ph.h, nil, SecretBossView.SecretBossItemRender, nil, nil, self.ph_list.ph_jifen_boss_item)
	self.boss_list:SetItemsInterval(10)
	self.boss_list:SetJumpDirection(ListView.Top)
	self.boss_list:SetSelectCallBack(BindTool.Bind(self.SelectBossListCallback, self))
	self.node_t_list.layout_secret_boss.node:addChild(self.boss_list:GetView(), 20)
end

function SecretBossView:CreateDropCells()
	if nil ~= self.drop_cell_list then
		return
	end

	self.drop_cell_list = {}
	for i = 1, 4 do
		local ph = self.ph_list["ph_drop_cell_" .. i]
		local cell = SecretBossView.DropItemRender.New()
		cell:SetAnchorPoint(0.5, 0.5)
		cell:SetPosition(ph.x, ph.y)
		cell:SetUiConfig(ph, true)
		cell:SetIndex(i)
		self.node_t_list.layout_secret_boss.node:addChild(cell:GetView(), 20)
		table.insert(self.drop_cell_list, cell)
	end
end

function SecretBossView:OnBagItemChange()
	local secret_data = SecretBossData.Instance:GetSecretData()
	self.node_t_list.layout_secret_boss.lbl_juanzhou_num.node:setString(string.format(Language.Boss.ScrestScrollNum, BagData.Instance:GetItemNumInBagById(secret_data.consume)))
end

function SecretBossView:OnUpdateSecretData()
	self:FlushBossData()
	local secret_data = SecretBossData.Instance:GetSecretData()
	self.node_t_list.layout_secret_boss.lbl_last_times.node:setString(secret_data.enter_times .. Language.Fuben.Text_2)
end

function SecretBossView:OnUpdateBossData()
	self:FlushBossData()
end

function SecretBossView:RoleAttrChange(vo)
	if vo.key == OBJ_ATTR.CREATURE_LEVEL or 
		vo.key == OBJ_ATTR.ACTOR_CIRCLE then 
		self:FlushBossData()
	end
end

function SecretBossView:OnBossStateChange()
	self:FlushBossData()
end

function SecretBossView:FlushBossData()
	self.boss_list:SetDataList(SecretBossData.Instance:GetSecretBossList())
	self.boss_list:SelectIndex(1)
end

function SecretBossView:SelectBossListCallback(item)
	local select_data = item and item:GetData()
	if select_data then
		self:FlushSecretBossInfo(select_data)
	end
end

function SecretBossView:FlushSecretBossInfo(data)
	if nil == data or nil == data.index then return end
	local boss_cfg = BossData.GetMosterCfg(data.boss_id)
	local boss_name = data.boss_name
	self.boss_id = data.boss_id
	self.boss_type = data.boss_type
	self.scene_id = data.scene_id
	local is_enough, tip = BossData.BossIsEnoughAndTip(data)
	
	self.node_t_list.lbl_boss_name.node:setString(boss_name .. "(" .. tip .. ")")
	self.monster_display:Show(boss_cfg.modelid)
	self.monster_display:MakeGray(data.refresh_time > 0)
	local model_cfg = BossData.GetMosterModelCfg(boss_cfg.modelid)
	self.monster_display:SetScale(model_cfg.modelScale)
	
	local state = data.refresh_time > 0 and 1 or 2
	self.node_t_list.img_boss_state.node:loadTexture(ResPath.GetBoss("stamp_" .. state))

	local role_name = SecretBossData.Instance:GetAttributionName(data.boss_id) or Language.Common.No
	self.node_t_list.lbl_affiliation_name.node:setString(role_name)
	self.node_t_list.lbl_challenge_limit.node:setVisible(not is_enough)
	self.node_t_list.lbl_challenge_limit.node:setString(tip .. Language.Fuben.Open)
	self.node_t_list.btn_join_challenge.node:setVisible(is_enough)
	self.node_t_list.img_boss_state.node:setVisible(is_enough)

	local drop_list = {}
	local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	for k,v in pairs(data.boss_drop) do
		if v.job == prof then
			drop_list[#drop_list + 1] = {item_id = v.id, num = 1, is_bind = v.bind}
		end
	end
	self:FlushDropList(drop_list)

	--秘境boss倒计时
	local rest_time = data.refresh_time - (Status.NowTime - data.now_time) 
	if(rest_time > 0) then
		self.boss_rest_time=rest_time
		str = string.format(Language.Boss.BossRebornStr, TimeUtil.FormatSecond(self.boss_rest_time))
		self.node_t_list.lbl_boss_reflush_time.node:setString(str)
		self.node_t_list.lbl_boss_reflush_time.node:setVisible(true)
		self:CreateTimer()
	else
		CountDown.Instance:RemoveCountDown(self.timer1)
		self.node_t_list.lbl_boss_reflush_time.node:setVisible(false)
	end
end

function SecretBossView:FlushDropList(list)
	for i,v in ipairs(self.drop_cell_list) do
		v:SetData(list[i])
	end
end

function SecretBossView:OnClickJoinChallenge()
	BossCtrl.CSChuanSongBossScene(self.boss_type, self.boss_id)
	self.enter_scene = self.scene_id
end

function SecretBossView:OnClickTipHandler()
	DescTip.Instance:SetContent(Language.Boss.SecretBossTips, Language.Boss.SecretBossTipsName)
end

function SecretBossView:OnClickBuyTimes()
	SecretBossCtrl.GetSecretBossReq(2)
end

function SecretBossView:OnClickLinkText()
	local boss_list = SecretBossData.Instance:GetSecretBossRemindInfo()
	ViewManager.Instance:OpenViewByDef(ViewDef.BossRefreshRemind)
	ViewManager.Instance:FlushViewByDef(ViewDef.BossRefreshRemind, 0, nil, {data = boss_list})
end

function SecretBossView:SceneChange()
	local scene_id = Scene.Instance:GetSceneId()
	if scene_id == self.enter_scene then 
		ViewManager.Instance:CloseViewByDef(ViewDef.Boss)
	end
end


SecretBossView.SecretBossItemRender = BaseClass(BaseRender)
local SecretBossItemRender = SecretBossView.SecretBossItemRender

function SecretBossItemRender:__init()
end

function SecretBossItemRender:__delete()
end

function SecretBossItemRender:CreateChild()
	BaseRender.CreateChild(self)
	XUI.RichTextSetCenter(self.node_tree.rich_boss_name.node)
end

function SecretBossItemRender:OnFlush()
	if nil == self.data then return end
	-- self.node_tree.img_arrow.node:setVisible(false)

	if self.cache_select and self.is_select then
		self.cache_select = false
		self:CreateSelectEffect()
	end
	self:OnSelectChange(self.is_select)
	if self.data.boss_name ~= nil and self.node_tree.rich_boss_name.node then
		local is_enough, tip = BossData.BossIsEnoughAndTip(self.data)
		self.node_tree.img_can_kill.node:setVisible(self.data.boss_state == 0)
		local str = string.format(Language.Boss.SecertBossName, is_enough and "f8dba9" or "8b7c6a", self.data.boss_name, tip)
		RichTextUtil.ParseRichText(self.node_tree.rich_boss_name.node, str, 19)
	end
end

function SecretBossItemRender:CreateSelectEffect()
	if nil == self.node_tree.img_bg then
		self.cache_select = true
		return
	end
	local size = self.node_tree.img_bg.node:getContentSize()
	self.select_effect = XUI.CreateImageView(size.width / 2, size.height / 2, ResPath.GetCommon("toggle_120_select"), true)
	
	if nil == self.select_effect then
		ErrorLog("BaseRender:CreateSelectEffect fail")
		return
	end
	self.node_tree.img_bg.node:addChild(self.select_effect, 999)
end

function SecretBossItemRender:OnSelectChange(is_select)
	-- if self.node_tree.img_arrow then 
	-- 	self.node_tree.img_arrow.node:setVisible(is_select)
	-- end
end



SecretBossView.DropItemRender = BaseClass(BaseRender)
local DropItemRender = SecretBossView.DropItemRender

function DropItemRender:__init()
end

function DropItemRender:__delete()
	if self.cell then
		self.cell:DeleteMe()
		self.cell = nil
	end
	self.item_lv_text = nil
end

function DropItemRender:CreateChild()
	BaseRender.CreateChild(self)
	
	local size = self.view:getContentSize()
	
	self.cell = BaseCell.New()
	self.cell:SetAnchorPoint(0.5, 0.5)
	self.cell:SetRightBottomTexVisible(false)
	self.cell:SetPosition(size.width / 2, size.height / 2)
	self.view:addChild(self.cell:GetView())
	
	self.item_lv_text = XUI.CreateText(size.width / 2, 0, 0, 0, nil, "", nil, 18, COLOR3B.YELLOW)
	self.item_lv_text:setAnchorPoint(0.5, 1)
	self.view:addChild(self.item_lv_text, 50)
end

function DropItemRender:OnFlush()
	if self.data == nil then return end
	self.cell:SetData(self.data)
	self.cell:SetProfIconVisible(false)
	self.cell:SetRightTopNumText(0)

	local limit_level, zhuan = ItemData.GetItemLevel(self.data.item_id)
	local equip_level = limit_level .. Language.Common.Ji
	if 0 ~= zhuan then 
		equip_level = zhuan .. Language.Common.Zhuan
	end
	self.item_lv_text:setString(equip_level)
end 

return SecretBossView