-- 转生boss

local CircleBossView = BaseClass(SubView)

function CircleBossView:__init()
	self.texture_path_list = {
		'res/xui/boss.png',
	}
    self.config_tab = {
  	 	{"new_boss_ui_cfg", 6, {0}},
		{"new_boss_ui_cfg", 5, {0}},
	}
end

function CircleBossView:__delete()
end

function CircleBossView:LoadCallBack(index, loaded_times)
	-- self.boss_list = nil
	self:CreateBossList()
	self.award_cell_list = nil
	self.monster_display = nil
	-- self.fuben_id = 0 
	self:CreateAwardCells()
	self:CreateMonsterAnimation()
	self.select_index = 1

	-- XUI.AddClickEventListener(self.node_t_list.layout_other_boss.btn_tip.node, BindTool.Bind(self.OnClickTipHandler, self))
	XUI.AddClickEventListener(self.node_t_list.layout_other_boss.btn_enter.node, BindTool.Bind(self.OnClickChallengeHandler, self))
	self.scene_change = GlobalEventSystem:Bind(SceneEventType.SCENE_CHANGE_COMPLETE, BindTool.Bind(self.SceneChange, self))
	EventProxy.New(RoleData.Instance, self):AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.RoleAttrChange, self))

	EventProxy.New(NewlyBossData.Instance, self):AddEventListener(NewlyBossData.NEWLY_BOSS_REMIND, BindTool.Bind(self.Flush, self))
end

function CircleBossView:ShowIndexCallBack()
	self.select_index = 1
	self.boss_list:ChangeToIndex(1)
	self:Flush()
end

function CircleBossView:ReleaseCallBack()
	if self.boss_list then
		self.boss_list:DeleteMe()
		self.boss_list = nil 
	end

	if self.monster_display then
		self.monster_display:DeleteMe()
		self.monster_display = nil 
	end

	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end

	if self.award_cell_list  then
		for k,v in pairs(self.award_cell_list ) do
			v:DeleteMe()
		end
		self.award_cell_list = nil
	end
	GlobalEventSystem:UnBind(self.scene_change)
end

function CircleBossView:CreateMonsterAnimation()
	if nil == self.monster_display then
		self.monster_display = ModelAnimate.New(ResPath.GetMonsterAnimPath, self.node_t_list.layout_other_boss.node, GameMath.MDirDown)
		-- self.monster_display:SetAnimPosition(550,265)
		self.monster_display:SetFrameInterval(FrameTime.RoleStand)
		self.monster_display:SetZOrder(100)
	end
end

function CircleBossView:CreateBossList()
	if nil ~= self.boss_list then
		return
	end

	local ph = self.ph_list.ph_boss_list
	self.boss_list = ListView.New()
	self.boss_list:Create(ph.x, ph.y, ph.w, ph.h, nil, CircleBossView.CircleBossRender, nil, nil, self.ph_list.ph_boss_item)
	self.boss_list:SetItemsInterval(10)
	self.boss_list:SetJumpDirection(ListView.Top)
	self.boss_list:SetSelectCallBack(BindTool.Bind(self.SelectBossListCallback, self))
	self.node_t_list.layout_other_boss.node:addChild(self.boss_list:GetView(), 101)
end

function CircleBossView:CreateAwardCells()
	if nil ~= self.award_cell_list then
		return
	end

	self.award_cell_list = {}
	for i = 1, 6 do
		local ph = self.ph_list["ph_award_cell_" .. i]
		local cell = BaseCell.New()
		cell:GetView():setAnchorPoint(0.5, 0.5)
		cell:SetPosition(ph.x, ph.y)
		self.node_t_list.layout_other_boss.node:addChild(cell:GetView(), 102)
		table.insert(self.award_cell_list, cell)
	end
end


function CircleBossView:OnFlush(param_t)
	local boss_list
	if self:GetViewDef() == ViewDef.NewlyBossView.Wild.CircleBoss then
		boss_list = NewBossData.Instance:SetRareBossInfo(4)
	elseif self:GetViewDef() == ViewDef.NewlyBossView.Rare.MoyuBoss then
		boss_list = NewBossData.Instance:SetRareBossInfo(9)
	end

	self.boss_list:SetDataList(boss_list)

	self.boss_list:SelectIndex(self.select_index)
	self.node_t_list.btn_tx.node:setVisible(self:GetViewDef() == ViewDef.NewlyBossView.Wild.CircleBoss)
end

function CircleBossView:OnGetUiNode(node_name)
	-- 选择boss
	local boss_level = string.match(node_name, "^PersonalBossLevel(%d+)$")
	boss_level = tonumber(boss_level)
	if boss_level ~= nil then
		local list_index = nil
		for k, v in pairs(PersonalBossData.Instance:GetPersonalBossList()) do
			if v.boss_level == boss_level then
				list_index = k
				break
			end
		end

		if nil ~= list_index then
			if self.boss_list and self.boss_list:GetItemAt(list_index) then
				return self.boss_list:GetItemAt(list_index):GetView(), true
			end
		end
	end

	return CircleBossView.super.OnGetUiNode(self, node_name)
end

function CircleBossView:RoleAttrChange(vo)
	if vo.key == OBJ_ATTR.CREATURE_LEVEL or 
		vo.key == OBJ_ATTR.ACTOR_KILL_DEVIL_TOKEN or
		vo.key == OBJ_ATTR.ACTOR_CIRCLE then 
			self:Flush()
	end
end

function CircleBossView:OnBossStateChange()
	self:Flush()
end

function CircleBossView:SelectBossListCallback(item, index)
	local select_data = item and item:GetData()
	if select_data then
		self.select_index = index
		self:FlushPersonalBossInfo(select_data)
	end
end

function CircleBossView:FlushPersonalBossInfo(data)
	if data == nil or next(data) == nil then return end
	local boss_cfg = BossData.GetMosterCfg(data.boss_id)
	local boss_name = data.boss_name
	local is_enough, tip = BossData.BossIsEnoughAndTip(data)
	self.node_t_list.lbl_boss_name.node:setString(boss_name)
	self.node_t_list.lbl_boss_lv.node:setString(data.bosslv .. "级")
	-- self.node_t_list.lbl_flush_time.node:setString(string.format(Language.Boss.BossFlushTime, data.limit_time/60))
	-- self.node_t_list.lbl_boss_scene.node:setLocalZOrder(999)
	self.monster_display:Show(boss_cfg.modelid)
	self.monster_display:SetAnimPosition(630,250)
	-- if boss_cfg.modelid == 139 then
	-- 	self.monster_display:SetAnimPosition(550,100)
	-- else
	-- 	self.monster_display:SetAnimPosition(550,240)
	-- end
	local model_cfg = BossData.GetMosterModelCfg(boss_cfg.modelid)
	-- self.monster_display:SetScale(model_cfg.modelScale)
	self.monster_display:SetScale(0.8)

	local left_time = data.refresh_time - Status.NowTime + data.now_time
	self.node_t_list.lbl_flush_time.node:setColor(left_time > 0 and COLOR3B.RED or COLOR3B.GREEN)
	
	if left_time > 0 then
		if self.timer then
			GlobalTimerQuest:CancelQuest(self.timer)
			self.timer = nil
		end

		local callback = function()
			
			local left_time = data.refresh_time - Status.NowTime + data.now_time
			if left_time > 0 then
				self.node_t_list["lbl_flush_time"].node:setString(TimeUtil.FormatSecond(left_time, 3) .. "后刷新")
			else
				self.node_t_list.lbl_flush_time.node:setString("已刷新")
				if self.timer then
					GlobalTimerQuest:CancelQuest(self.timer)
					self.timer = nil
				end
			end
		end
		callback()
		self.timer = GlobalTimerQuest:AddTimesTimer(callback, 1, left_time)
	else
		if self.timer then
			GlobalTimerQuest:CancelQuest(self.timer)
			self.timer = nil
		end
		self.node_t_list.lbl_flush_time.node:setString("已刷新")
	end

	local color = is_enough and "55ff00" or "ff0000"
	local lv_str = string.format(Language.Boss.CircleBossLv[2], color, tip)
	RichTextUtil.ParseRichText(self.node_t_list.rich_lv_need.node, lv_str, 19)	

	local item = ItemData.FormatItemData(data.consumes[1])
	
	if item then
		local n = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_KILL_DEVIL_TOKEN)
		self.node_t_list.lbl_consume.node:setString("消耗屠魔令：")
		self.node_t_list.lbl_need_num.node:setString(n .. "/" .. StdMonster[data.boss_id].nKillDevilTokenLimit)
		self.node_t_list.lbl_need_num.node:setColor(n >= item.num and COLOR3B.GREEN or COLOR3B.RED)
	end
	local drop_list = {}
	local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	for k,v in pairs(data.boss_drop) do
		drop_list[#drop_list + 1] = {item_id = v.id, num = 1, is_bind = v.bind}
	end
	self:FlushAwardList(drop_list)
end

function CircleBossView:FlushAwardList(data_list)
	for k, v in pairs(self.award_cell_list) do
		v:SetData(data_list[k])
	end
end


function CircleBossView:OnClickTipHandler()
	DescTip.Instance:SetContent(Language.Boss.RareBossTips, Language.Boss.RareBossTipsName)
end

function CircleBossView:OnClickChallengeHandler()
	local data = self.boss_list:GetSelectItem():GetData()

	local item = ItemData.FormatItemData(data.consumes[1])
	
	if item == nil then return end
	local comsume = ShopData.GetItemPriceCfg(item.item_id)
	local n = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_KILL_DEVIL_TOKEN)
	if n >= item.num then
		if data.chuansongId == 0 then
			BossCtrl.CSChuanSongBossScene(data.boss_type, data.boss_id)
		else
			GuajiCtrl.Instance:FlyByIndex(data.chuansongId)
		end
	else
		if comsume then
			TipCtrl.Instance:OpenQuickTipItem(false, {item.item_id, comsume.price[1].type, 1})
		else
			TipCtrl.Instance:OpenGetStuffTip(item.item_id)
		end
	end
end

function CircleBossView:SceneChange()
	local fuben_type = Scene.Instance:GetSceneLogic():GetFubenType()
	if fuben_type == FubenType.PersonalBoss then 
		ViewManager.Instance:CloseViewByDef(ViewDef.Boss)
	end
end


CircleBossView.CircleBossRender = BaseClass(BaseRender)
local CircleBossRender = CircleBossView.CircleBossRender
function CircleBossRender:__init()
end

function CircleBossRender:__delete()
end

function CircleBossRender:CreateChild()
	CircleBossRender.super.CreateChild(self)
	XUI.RichTextSetCenter(self.node_tree.rich_boss_name.node)
	XUI.RichTextSetCenter(self.node_tree.rich_boss_lv.node)
end

function CircleBossRender:OnFlush()
	-- self.node_tree.img_remind_flag.node:setVisible(false)
	local is_enough, tip = BossData.BossIsEnoughAndTip(self.data)
	local name = ""
	-- self.node_tree.img_remind_flag.node:setVisible(self.data.boss_state ~= 2)
	local is_rem = BossData.Instance:GetRemindFlag(self.data.boss_type, self.data.rindex) == 0
	
	self.node_tree.img_unopen.node:setVisible(false) 		--self.data.boss_state == 0 and is_rem
	if self.data.boss_name ~= nil and self.node_tree.rich_boss_name.node and nil ~= self.data.rindex then
		local color = "55ff00"
		local lv_color = COLOR3B.GREEN--"55ff00"
		if 2 == self.data.boss_state then
			color = "8b7c6a" 
			-- lv_color = COLOR3B.RED--"ff0000"
		elseif 3 == self.data.boss_state then
			color = "c2c2c2"
			-- lv_color = COLOR3B.G_W--"c2c2c2"
		end
		local str = string.format(Language.Boss.RareBossName, color, self.data.boss_name)
		local str_lv = string.format(Language.Boss.MoyuBossLv, color, self.data.bosslv)
		local txt_state = ""
		if is_enough then
		-- 	str_lv = string.format(Language.Boss.FieldBossLv, lv_color, self.data.bosslv)
			txt_state = (self.data.boss_state == 0 and is_rem) and "已刷新" or "未刷新"
			lv_color = (self.data.boss_state == 0 and is_rem) and COLOR3B.GREEN or COLOR3B.G_W
		else
			txt_state = tip .. "开启"--string.format(Language.Boss.CircleBossLv[1], lv_color, tip)
			lv_color = COLOR3B.RED
		end
		RichTextUtil.ParseRichText(self.node_tree.rich_boss_name.node, str, 18)
		RichTextUtil.ParseRichText(self.node_tree.rich_boss_lv.node, str_lv, 18)
		self.node_tree.lbl_boss_open.node:setString(txt_state)
		self.node_tree.lbl_boss_open.node:setColor(lv_color)
	end


	if self.cache_select and self.is_select then
		self.cache_select = false
		self:CreateSelectEffect()
	end
	-- self:OnSelectChange(self.is_select)
end

-- function CircleBossRender:CreateSelectEffect()

-- end

-- function CircleBossRender:OnSelectChange(is_select)
	-- if self.node_tree.img_arrow then 
	-- 	self.node_tree.img_arrow.node:setVisible(is_select)
	-- end
-- end


CircleBossView.PerBossListView = BaseClass(ListView)
local PerBossListView = CircleBossView.PerBossListView

--list事件回调
function PerBossListView:ListEventCallback(sender, event_type, index)
	if self.items[index + 1] then 
		local data = self.items[index + 1].data
		if data.state == 0 then return end
	end
	PerBossListView.super.ListEventCallback(self, sender, event_type, index)
end


return CircleBossView