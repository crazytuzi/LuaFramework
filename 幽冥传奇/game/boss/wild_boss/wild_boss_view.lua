local WildBossView = BaseClass(SubView)

function WildBossView:__init()
	self.texture_path_list = {
		'res/xui/boss.png',
	}
    self.config_tab = {
   		{"boss_ui_cfg", 1, {0}},
		{"boss_ui_cfg", 3, {0}},
	}
end

function WildBossView:__delete()
end

function WildBossView:LoadCallBack(index, loaded_times)
	self.boss_item = nil
	self.enter_scene = 0
	self.flush_time = 0
	self:CreateBossListItem()

	EventProxy.New(WildBossData.Instance, self):AddEventListener(WildBossData.UPDATE_ROLE_DATA, BindTool.Bind(self.OnUpdateRoleData, self))
	EventProxy.New(BossData.Instance, self):AddEventListener(BossData.UPDATE_BOSS_DATA, BindTool.Bind(self.OnUpdateBossData, self))
	EventProxy.New(RoleData.Instance, self):AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.RoleAttrChange, self))
	EventProxy.New(LunHuiData.Instance, self):AddEventListener(LunHuiData.LUNHUI_DATA_CHANGE, BindTool.Bind(self.OnBossStateChange, self))
	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.OnBagItemChange, self))
	self.scene_change = GlobalEventSystem:Bind(SceneEventType.SCENE_CHANGE_COMPLETE, BindTool.Bind(self.SceneChange, self))

	self.txt_remind_link = RichTextUtil.CreateLinkText(Language.Common.RemindSet, 20, COLOR3B.GREEN)
	self.txt_remind_link:setPosition(790, 620)
	self.node_t_list.layout_wild_boss.node:addChild(self.txt_remind_link, 50)
	XUI.AddClickEventListener(self.txt_remind_link, BindTool.Bind(self.OnClickLinkText, self), true)

	self.txt_buy_link = RichTextUtil.CreateLinkText(Language.Boss.BuyJuanzhou, 20, COLOR3B.GREEN)
	self.txt_buy_link:setPosition(390, 618)
	self.node_t_list.layout_wild_boss.node:addChild(self.txt_buy_link, 50)
	XUI.AddClickEventListener(self.txt_buy_link, BindTool.Bind(self.OnClickBuyText, self), true)

	WildBossCtrl.GetWildBossOwnInfo()
	self:CreateTimer()
end

function WildBossView:ReleaseCallBack()
	if self.boss_item then
		self.boss_item:DeleteMe()
		self.boss_item = nil
	end
	
	CountDown.Instance:RemoveCountDown(self.timer1)
	
	GlobalEventSystem:UnBind(self.scene_change)
end

function WildBossView:CreateTimer()
	if self.flush_time > TimeCtrl.Instance:GetServerTime() then 
		CountDown.Instance:RemoveCountDown(self.timer1)
		self.timer1 = CountDown.Instance:AddCountDown(self.flush_time - TimeCtrl.Instance:GetServerTime(), 1, BindTool.Bind(self.UpdateTimer, self))
	end
end

function WildBossView:UpdateTimer()
	if self.flush_time <= TimeCtrl.Instance:GetServerTime() then
		self.node_t_list.layout_wild_boss.lbl_limit_time.node:setVisible(false)
	else 
		self.node_t_list.layout_wild_boss.lbl_limit_time.node:setVisible(true)
	end
	local str = string.format(Language.Boss.ChallengeRecoverStr, TimeUtil.FormatSecond(self.flush_time - TimeCtrl.Instance:GetServerTime()))
	self.node_t_list.layout_wild_boss.lbl_limit_time.node:setString(str)
end

function WildBossView:CreateBossListItem()
	if nil == self.boss_item then
		local ph = self.ph_list.ph_boss_item_list
		self.boss_item = ListView.New()
		self.boss_item:Create(ph.x, ph.y, ph.w, ph.h, nil, WildBossItemRender, nil, nil, self.ph_list.ph_boss_item)
		self.boss_item:SetItemsInterval(2)
		self.boss_item:SetJumpDirection(ListView.Top)
		self.boss_item.item_render:SetBtnClickCallBack(BindTool.Bind(self.ButtonClickCallback, self))
		self.node_t_list.layout_wild_boss.node:addChild(self.boss_item:GetView(), 20)
	end
end

function WildBossView:OnUpdateBossData()
	self:FlushBossData()
end

function WildBossView:OnUpdateRoleData()
	self:FlushRoleData()
	self:FlushBossData()
end

function WildBossView:RoleAttrChange(vo)
	if vo.key == OBJ_ATTR.CREATURE_LEVEL or 
		vo.key == OBJ_ATTR.ACTOR_CIRCLE then 
		self:FlushBossData()
	end
end

function WildBossView:OnBossStateChange()
	self:FlushBossData()
end

function WildBossView:OnBagItemChange()
	self:FlushRoleData()
end

function WildBossView:FlushRoleData()
	local challenge_info = WildBossData.Instance:GetChallengeInfo()
	self.flush_time = challenge_info.cd_time
	self.node_t_list.layout_wild_boss.lbl_challenge_times.node:setString((challenge_info.total_count - challenge_info.enter_times) .. "/" .. challenge_info.total_count)
	self.node_t_list.layout_wild_boss.lbl_challenge_times.node:setColor((challenge_info.total_count - challenge_info.enter_times)  > 0 and COLOR3B.GREEN or COLOR3B.RED)
	self.node_t_list.layout_wild_boss.lbl_scroll_num.node:setString("(" .. BagData.Instance:GetItemNumInBagById(challenge_info.consume_id) .. ")")
	
	self:CreateTimer()
	self.node_t_list.layout_wild_boss.lbl_limit_time.node:setVisible(self.flush_time > TimeCtrl.Instance:GetServerTime())
end

function WildBossView:FlushBossData()
	local boss_list = WildBossData.Instance:GetBossListInfo()
    if IS_AUDIT_VERSION then
        local temp_list ={}
        for k, v in ipairs(boss_list) do
            if k > 20 then
                break
            else
                table.insert(temp_list, v)
            end
        end
        boss_list = temp_list
    end
	self.boss_item:SetDataList(boss_list)
end

function WildBossView:SceneChange()
	local scene_id = Scene.Instance:GetSceneId()
	if scene_id == self.enter_scene then 
		ViewManager.Instance:CloseViewByDef(ViewDef.Boss)
	end
end

function WildBossView:ButtonClickCallback(item)
	local data = item:GetData()
	self.enter_scene = data.scene_id
end


function WildBossView:OnClickLinkText()
	local boss_list = WildBossData.Instance:GetBossRemindInfo()
	ViewManager.Instance:OpenViewByDef(ViewDef.BossRefreshRemind)
	ViewManager.Instance:FlushViewByDef(ViewDef.BossRefreshRemind, 0, nil, {data = boss_list})
end

function WildBossView:OnClickBuyText()
	ViewManager.Instance:OpenViewByDef(ViewDef.Shop.Bind_yuan)
end

WildBossItemRender = WildBossItemRender or BaseClass(BaseRender)
function WildBossItemRender:__init()
	self.boss_count_prog = nil
	self.drop_cell = nil
	self.reborn_timer = nil
	self.btn_click_cb = nil
end

function WildBossItemRender:__delete()
	if self.boss_count_prog then
		self.boss_count_prog:DeleteMe()
		self.boss_count_prog = nil
	end
	if self.drop_cell then
		for k,v in pairs(self.drop_cell) do
			v:DeleteMe()
		end
		self.drop_cell = nil
	end

	CountDown.Instance:RemoveCountDown(self.reborn_timer)
end

function WildBossItemRender:CreateChild()
	BaseRender.CreateChild(self)

	self.boss_count_prog = ProgressBar.New()
	self.boss_count_prog:SetView(self.node_tree.prog9_up_progress.node)
	self.boss_count_prog:SetTotalTime(0)
	self.boss_count_prog:SetTailEffect(991, nil, true)
	self.boss_count_prog:SetEffectOffsetX(-20)
	self.boss_count_prog:SetPercent(0)

	self:CreateDropCell()

	self.node_tree.lbl_reborn_time.node:setVisible(false)
	XUI.AddClickEventListener(self.node_tree.btn_challenge.node, BindTool.Bind(self.OnClickChallenge, self), true)
end

function WildBossItemRender:CreateUpdateTimer()
	CountDown.Instance:RemoveCountDown(self.reborn_timer)
	self.reborn_timer = CountDown.Instance:AddCountDown(self.data.refresh_time + self.data.now_time - Status.NowTime, 1, BindTool.Bind(self.UpdateRebornTime, self))
end

function WildBossItemRender:UpdateRebornTime()
	local is_enough = BossData.BossIsEnoughAndTip(self.data)
	local now_time = Status.NowTime
	local has_reborn = true
	local str = ""
	if self.data.refresh_time + self.data.now_time - now_time <= 0 then
		self.node_tree.btn_challenge.node:setVisible(is_enough)
		has_reborn = false
	else
		str = string.format(Language.Boss.BossRebornStr, TimeUtil.FormatSecond(self.data.refresh_time + self.data.now_time - now_time))
	end
	local time = (1 - (self.data.refresh_time + self.data.now_time - now_time) / self.data.limit_time) * 100
	self.boss_count_prog:SetPercent(time)
	if self.node_tree.lbl_reborn_time then 
		self.node_tree.lbl_reborn_time.node:setVisible(has_reborn)
		self.node_tree.lbl_reborn_time.node:setString(str)
	end
end

function WildBossItemRender:CreateDropCell()
	self.drop_cell = {}
	for i = 1, 6 do
		local ph = self.ph_list["ph_award_cell_" .. i]
		local cell = BaseCell.New()
		cell:SetPosition(ph.x, ph.y)
		cell:SetIndex(i)
		cell:SetAnchorPoint(0.5, 0.5)
		self.view:addChild(cell:GetView(), 300)
		table.insert(self.drop_cell, cell)
	end
end

function WildBossItemRender:OnClickChallenge()
	BossCtrl.CSChuanSongBossScene(self.data.boss_type, self.data.boss_id)
	if self.btn_click_cb then 
		self.btn_click_cb(self)
	end
end

function WildBossItemRender:SetBtnClickCallBack(callback)
	self.btn_click_cb = callback
end

function WildBossItemRender:OnFlush()
	if nil == self.data then return end
	self.node_tree.lbl_reborn_time.node:setVisible(false)
	self.node_tree.lbl_boss_name.node:setString(self.data.boss_name)
	local is_enough, tip = BossData.BossIsEnoughAndTip(self.data)
	self.node_tree.lbl_open_limit.node:setString(tip .. Language.Fuben.Open)
	self.node_tree.lbl_boss_level.node:setString(tip)

	if 0 ~= self.data.boss_state then
		self:CreateUpdateTimer()
	end

	local now_time = Status.NowTime
	self.boss_count_prog:SetPercent((self.data.limit_time - self.data.refresh_time - self.data.now_time + now_time) / self.data.limit_time * 100)
	self.node_tree.btn_challenge.node:setVisible(is_enough and self.data.boss_state == 0)
	self.node_tree.img_state.node:setVisible(is_enough and self.data.boss_state == 1)
	self.node_tree.lbl_open_limit.node:setVisible(not is_enough)

	local boss_cfg = BossData.GetMosterCfg(self.data.boss_id)
	local boss_head = XUI.CreateImageView(106, 80, ResPath.GetBoss(boss_cfg.modelid), true)
	self.view:addChild(boss_head, 100)

	local drop_list = {}
	local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	for k,v in pairs(self.data.boss_drop) do
		if v.job == 0 or (v.job > 0 and v.job == prof) then
			drop_list[#drop_list + 1] = {item_id = v.id, num = 1, is_bind = v.bind}
		end
	end
	self:FlushDropItem(drop_list)
end

function WildBossItemRender:FlushDropItem(list)
	for i,v in ipairs(self.drop_cell) do
		v:SetData(list[i])
		local limit_level, zhuan = ItemData.GetItemLevel(list[i].item_id)
		local equip_level = limit_level .. Language.Common.Ji
		if 0 ~= zhuan then 
			equip_level = zhuan .. Language.Common.Zhuan
		end
		self.node_tree["lbl_award_item_" .. i].node:setString(equip_level)
	end
end

function WildBossItemRender:CreateSelectEffect()
end

return WildBossView