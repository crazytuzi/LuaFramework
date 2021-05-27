-- 星魂boss

local XhBossView = BaseClass(SubView)

function XhBossView:__init()
	self.texture_path_list = {
		'res/xui/boss.png',
	}
    self.config_tab = {
		{"new_boss_ui_cfg", 8, {0}},
	}

	self.boss_data = {}
end

function XhBossView:__delete()
end

function XhBossView:LoadCallBack(index, loaded_times)
	-- self.boss_list = nil
	self:CreateBossList()
	self.award_cell_list = nil
	self.monster_display = nil
	-- self.fuben_id = 0 
	self:CreateAwardCells()
	self:CreateMonsterAnimation()
	self.select_index = 1

	XUI.AddClickEventListener(self.node_t_list.layout_moyu_boss.btn_tip.node, BindTool.Bind(self.OnClickTipHandler, self))
	XUI.AddClickEventListener(self.node_t_list.layout_moyu_boss.btn_challenge.node, BindTool.Bind(self.OnClickChallengeHandler, self))
	self.scene_change = GlobalEventSystem:Bind(SceneEventType.SCENE_CHANGE_COMPLETE, BindTool.Bind(self.SceneChange, self))
	EventProxy.New(RoleData.Instance, self):AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.RoleAttrChange, self))
	XUI.AddClickEventListener(self.node_t_list.btn_tx.node, BindTool.Bind(self.OnClickBossTixing, self))
	EventProxy.New(NewlyBossData.Instance, self):AddEventListener(NewlyBossData.NEWLY_BOSS_REMIND, BindTool.Bind(self.Flush, self))
end

function XhBossView:ShowIndexCallBack()
	self.select_index = 1
	self.boss_list:ChangeToIndex(1)
	self:Flush()
end

function XhBossView:ReleaseCallBack()
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

function XhBossView:CreateMonsterAnimation()
	if nil == self.monster_display then
		self.monster_display = ModelAnimate.New(ResPath.GetMonsterAnimPath, self.node_t_list.layout_moyu_boss.node, GameMath.MDirDown)
		-- self.monster_display:SetAnimPosition(550,265)
		self.monster_display:SetFrameInterval(FrameTime.RoleStand)
		self.monster_display:SetZOrder(100)
	end
end

function XhBossView:CreateBossList()
	if nil ~= self.boss_list then
		return
	end

	local ph = self.ph_list.ph_boss_list
	self.boss_list = ListView.New()
	self.boss_list:Create(ph.x, ph.y, ph.w, ph.h, nil, XhBossView.MoyuBossRender, nil, nil, self.ph_list.ph_boss_item)
	self.boss_list:SetItemsInterval(10)
	self.boss_list:SetJumpDirection(ListView.Top)
	self.boss_list:SetSelectCallBack(BindTool.Bind(self.SelectBossListCallback, self))
	self.node_t_list.layout_moyu_boss.node:addChild(self.boss_list:GetView(), 20)
end

function XhBossView:CreateAwardCells()
	if nil ~= self.award_cell_list then
		return
	end

	self.award_cell_list = {}
	for i = 1, 6 do
		local ph = self.ph_list["ph_award_cell_" .. i]
		local cell = BaseCell.New()
		cell:GetView():setAnchorPoint(0.5, 0.5)
		cell:SetPosition(ph.x, ph.y)
		self.node_t_list.layout_moyu_boss.node:addChild(cell:GetView(), 102)
		table.insert(self.award_cell_list, cell)
	end
end


function XhBossView:OnFlush(param_t)
	local boss_list
	if self:GetViewDef() == ViewDef.NewlyBossView.Rare.XhBoss then
		boss_list = NewBossData.Instance:SetRareBossInfo(3)
	elseif self:GetViewDef() == ViewDef.NewlyBossView.Rare.ShenWei then
		boss_list = NewBossData.Instance:SetRareBossInfo(8)
	end

	self.boss_data = boss_list
	self.boss_list:SetDataList(boss_list)

	self.boss_list:SelectIndex(self.select_index)
end

function XhBossView:OnClickBossTixing()
	ViewManager.Instance:OpenViewByDef(ViewDef.BossRefreshRemind)
	ViewManager.Instance:FlushViewByDef(ViewDef.BossRefreshRemind, 0, nil, {data = self.boss_data})
end

function XhBossView:OnGetUiNode(node_name)
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

	return XhBossView.super.OnGetUiNode(self, node_name)
end

function XhBossView:RoleAttrChange(vo)
	if vo.key == OBJ_ATTR.CREATURE_LEVEL or 
		vo.key == OBJ_ATTR.ACTOR_KILL_DEVIL_TOKEN or
		vo.key == OBJ_ATTR.ACTOR_CIRCLE then 
			self:Flush()
	end
end

function XhBossView:OnBossStateChange()
	self:Flush()
end

function XhBossView:SelectBossListCallback(item, index)
	local select_data = item and item:GetData()
	if select_data then
		self.select_index = index
		self:FlushPersonalBossInfo(select_data)
	end
end

function XhBossView:FlushPersonalBossInfo(data)
	if data == nil or next(data) == nil then return end
	local boss_cfg = BossData.GetMosterCfg(data.boss_id)
	local boss_name = data.boss_name
	local is_enough, tip = BossData.BossIsEnoughAndTip(data)
	self.node_t_list.lbl_boss_name.node:setString(boss_name)
	self.node_t_list.lbl_boss_lv.node:setString(data.bosslv .. "级")
	-- self.node_t_list.lbl_flush_time.node:setString(string.format(Language.Boss.BossFlushTime, data.limit_time/60))
	-- self.node_t_list.lbl_boss_scene.node:setLocalZOrder(999)
	self.monster_display:Show(boss_cfg.modelid)
	-- if boss_cfg.modelid == 139 then
		self.monster_display:SetAnimPosition(630,250)
	-- else
	-- 	self.monster_display:SetAnimPosition(630,300)
	-- end
	local model_cfg = BossData.GetMosterModelCfg(boss_cfg.modelid)
	self.monster_display:SetScale(0.8)  --model_cfg.modelScale

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

function XhBossView:FlushAwardList(data_list)
	for k, v in pairs(self.award_cell_list) do
		v:SetData(data_list[k])
	end
end


function XhBossView:OnClickTipHandler()
	DescTip.Instance:SetContent(Language.Boss.ShenweiBossTips, Language.Boss.ShenweiBossTipsName)
end

function XhBossView:OnClickChallengeHandler()
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

function XhBossView:SceneChange()
	local fuben_type = Scene.Instance:GetSceneLogic():GetFubenType()
	if fuben_type == FubenType.PersonalBoss then 
		ViewManager.Instance:CloseViewByDef(ViewDef.Boss)
	end
end


XhBossView.MoyuBossRender = BaseClass(BaseRender)
local MoyuBossRender = XhBossView.MoyuBossRender
function MoyuBossRender:__init()
end

function MoyuBossRender:__delete()
end

function MoyuBossRender:CreateChild()
	MoyuBossRender.super.CreateChild(self)
	XUI.RichTextSetCenter(self.node_tree.rich_boss_name.node)
	XUI.RichTextSetCenter(self.node_tree.rich_boss_lv.node)
end

function MoyuBossRender:OnFlush()
	-- self.node_tree.img_remind_flag.node:setVisible(false)
	local is_enough, tip = BossData.BossIsEnoughAndTip(self.data)
	local name = ""
	-- self.node_tree.img_remind_flag.node:setVisible(self.data.boss_state ~= 2)
	
	-- self.node_tree.img_unopen.node:setVisible(self.data.boss_state == 1)
	if self.data.boss_name ~= nil and self.node_tree.rich_boss_name.node and nil ~= self.data.rindex then
		local color = "55ff00"
		
		local zt_txt = self.data.boss_state == 0 and "已刷新" or "未刷新"
		local zt_color = self.data.boss_state == 0 and COLOR3B.GREEN or COLOR3B.G_W2
		if 2 == self.data.boss_state then
			color = "8b7c6a" 
			zt_txt = tip .. "开启"
			zt_color = COLOR3B.RED
		elseif 3 == self.data.boss_state then
			color = "c2c2c2" 
		end
		local str = string.format(Language.Boss.RareBossName, color, self.data.boss_name)
		local str_lv = string.format(Language.Boss.MoyuBossLv, color, self.data.bosslv)
		RichTextUtil.ParseRichText(self.node_tree.rich_boss_name.node, str, 18)
		RichTextUtil.ParseRichText(self.node_tree.rich_boss_lv.node, str_lv, 18)
		self.node_tree.lbl_boss_open.node:setString(zt_txt)
		self.node_tree.lbl_boss_open.node:setColor(zt_color)
	end


	-- if self.cache_select and self.is_select then
	-- 	self.cache_select = false
	-- 	self:CreateSelectEffect()
	-- end
	-- self:OnSelectChange(self.is_select)
end

-- function MoyuBossRender:CreateSelectEffect()
-- 	if nil == self.node_tree.img_bg then
-- 		self.cache_select = true
-- 		return
-- 	end
-- 	local size = self.node_tree.img_bg.node:getContentSize()
-- 	self.select_effect = XUI.CreateImageView(size.width / 2, size.height / 2, ResPath.GetCommon("toggle_120_select"), true)
	
-- 	if nil == self.select_effect then
-- 		ErrorLog("BaseRender:CreateSelectEffect fail")
-- 		return
-- 	end
-- 	self.node_tree.img_bg.node:addChild(self.select_effect, 999)
-- end

-- function MoyuBossRender:OnSelectChange(is_select)
	-- if self.node_tree.img_arrow then 
	-- 	self.node_tree.img_arrow.node:setVisible(is_select)
	-- end
-- end


XhBossView.PerBossListView = BaseClass(ListView)
local PerBossListView = XhBossView.PerBossListView

--list事件回调
function PerBossListView:ListEventCallback(sender, event_type, index)
	if self.items[index + 1] then 
		local data = self.items[index + 1].data
		if data.state == 0 then return end
	end
	PerBossListView.super.ListEventCallback(self, sender, event_type, index)
end


return XhBossView