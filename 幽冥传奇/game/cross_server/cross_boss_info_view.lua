-- 星魂boss

local CBossInfoView = BaseClass(SubView)

function CBossInfoView:__init()
	self.texture_path_list = {
		'res/xui/boss.png',
	}
    self.config_tab = {
		{"cross_boss_ui_cfg", 1, {0}},
	}

	self.boss_data = {}
	self.tabbar_idx = 1
	self.select_index = 1
end

function CBossInfoView:__delete()
end

function CBossInfoView:LoadCallBack(index, loaded_times)
	local name_list = {}
	for k, v in pairs(CrossConfig.crossFBConfigList) do
		name_list[#name_list + 1] = v.tipName
	end
	self.wild_tabbar = Tabbar.New()
	-- self.wild_tabbar:SetTabbtnTxtOffset(-10, 0)
	self.wild_tabbar:CreateWithNameList(self.node_t_list.layout_moyu_boss.node, 0, 500, function (index)
		self.tabbar_idx = index
		self:Flush()
	end, name_list, false, ResPath.GetCommon("toggle_121"))

	-- self.boss_list = nil
	self:CreateBossList()
	self.award_cell_list = nil
	self.monster_display = nil
	-- self.fuben_id = 0 
	self:CreateAwardCells()
	self:CreateMonsterAnimation()

	XUI.AddClickEventListener(self.node_t_list.layout_moyu_boss.btn_tip.node, BindTool.Bind(self.OnClickTipHandler, self))
	XUI.AddClickEventListener(self.node_t_list.layout_moyu_boss.btn_challenge.node, BindTool.Bind(self.OnClickChallengeHandler, self))
	XUI.AddClickEventListener(self.node_t_list.btn_tx.node, BindTool.Bind(self.OnClickBossTixing, self))

	self.scene_change = GlobalEventSystem:Bind(SceneEventType.SCENE_CHANGE_COMPLETE, BindTool.Bind(self.SceneChange, self))
	
	EventProxy.New(RoleData.Instance, self):AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.RoleAttrChange, self))
	local cross_server_data_event_proxy = EventProxy.New(CrossServerData.Instance, self)
	cross_server_data_event_proxy:AddEventListener(CrossServerData.COPY_DATA_CHANGE, BindTool.Bind(self.Flush, self))
	cross_server_data_event_proxy:AddEventListener(CrossServerData.CROSS_TUMO_ADD_TIME, BindTool.Bind(self.Flush, self))
end

function CBossInfoView:ShowIndexCallBack()
	self.wild_tabbar:SelectIndex(1)
	self.select_index = 1
	self.boss_list:ChangeToIndex(1)
	self:Flush()
end

function CBossInfoView:ReleaseCallBack()
	if self.boss_list then
		self.boss_list:DeleteMe()
		self.boss_list = nil 
	end

	if self.monster_display then
		self.monster_display:DeleteMe()
		self.monster_display = nil 
	end

	if self.wild_tabbar then
		self.wild_tabbar:DeleteMe()
		self.wild_tabbar = nil 
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

function CBossInfoView:CreateMonsterAnimation()
	if nil == self.monster_display then
		self.monster_display = ModelAnimate.New(ResPath.GetMonsterAnimPath, self.node_t_list.layout_moyu_boss.node, GameMath.MDirDown)
		-- self.monster_display:SetAnimPosition(550,265)
		self.monster_display:SetFrameInterval(FrameTime.RoleStand)
		self.monster_display:SetZOrder(100)
	end
end

function CBossInfoView:CreateBossList()
	if nil ~= self.boss_list then
		return
	end

	local ph = self.ph_list.ph_boss_list
	self.boss_list = ListView.New()
	self.boss_list:Create(ph.x, ph.y, ph.w, ph.h, nil, CBossInfoView.MoyuBossRender, nil, nil, self.ph_list.ph_boss_item)
	self.boss_list:SetItemsInterval(10)
	self.boss_list:SetJumpDirection(ListView.Top)
	self.boss_list:SetSelectCallBack(BindTool.Bind(self.SelectBossListCallback, self))
	self.node_t_list.layout_moyu_boss.node:addChild(self.boss_list:GetView(), 20)
end

function CBossInfoView:CreateAwardCells()
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


function CBossInfoView:OnFlush(param_t)
	self.boss_list:SetDataList(CrossServerData.Instance:GetSceneDataByIdx(self.tabbar_idx))
	self.boss_list:SelectIndex(self.select_index)

	local time = CrossServerData.Instance:GetCrossTumoAddTime()
	local left_time = time - os.time()
	if left_time > 0 then
		if self.timer then
			GlobalTimerQuest:CancelQuest(self.timer)
			self.timer = nil
		end

		local callback = function()
			local time = CrossServerData.Instance:GetCrossTumoAddTime()
			local left_time = time - os.time()
			if left_time > 0 then
				self.node_t_list["lbl_addtime"].node:setString("(" .. TimeUtil.FormatSecond(left_time, 3) .. "+1)")
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
		self.node_t_list.lbl_addtime.node:setString("")
	end

	for i,v in ipairs(CrossConfig.crossFBConfigList) do
		self.wild_tabbar:SetRemindByIndex(i, CrossServerData.Instance:GetCrossBossInfoRemindByIdx(i) > 0)
	end
end

function CBossInfoView:OnClickBossTixing()
	ViewManager.Instance:OpenViewByDef(ViewDef.BossRefreshRemind)
	ViewManager.Instance:FlushViewByDef(ViewDef.BossRefreshRemind, 0, nil, {data = CrossServerData.Instance:GetSceneDataByIdx(self.tabbar_idx)})
end

function CBossInfoView:OnGetUiNode(node_name)
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

	return CBossInfoView.super.OnGetUiNode(self, node_name)
end

function CBossInfoView:RoleAttrChange(vo)
	if vo.key == OBJ_ATTR.CREATURE_LEVEL or 
		vo.key == OBJ_ATTR.ACTOR_CROSS_KILL_DEVIL_TOKEN or
		vo.key == OBJ_ATTR.ACTOR_SWING_LEVEL or
		vo.key == OBJ_ATTR.ACTOR_CIRCLE then 
			self:Flush()
	end
end

function CBossInfoView:OnBossStateChange()
	self:Flush()
end

function CBossInfoView:SelectBossListCallback(item, index)
	local select_data = item and item:GetData()
	if select_data then
		self.select_index = index
		self:FlushPersonalBossInfo(select_data)
	end
end

function CBossInfoView:FlushPersonalBossInfo(data)
	if data == nil or next(data) == nil then return end
	local consumes = data.consumes
	local drops = data.drops
	local boss_info = CrossServerData.Instance:GetCrossBossInfoById(data.BossId)
	local refresh_time = boss_info and boss_info.refresh_time or 0
	local now_time = boss_info and boss_info.now_time or 0

	local boss_cfg = BossData.GetMosterCfg(data.BossId)
	local boss_name = data.boss_name
	local is_enough, tip, test_style = BossData.BossIsEnoughAndTip(data)
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

	local left_time = refresh_time - Status.NowTime + now_time
	self.node_t_list.lbl_flush_time.node:setColor(left_time > 0 and COLOR3B.RED or COLOR3B.GREEN)
	if left_time > 0 then
		if self.timer then
			GlobalTimerQuest:CancelQuest(self.timer)
			self.timer = nil
		end

		local callback = function()
			local left_time = refresh_time - Status.NowTime + now_time
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
	if test_style == 1 then
		lv_str = string.format("{color;%s;%s开启}", color, tip)
	else
		lv_str = string.format(Language.Boss.CircleBossLv[2], color, tip)
	end
	RichTextUtil.ParseRichText(self.node_t_list.rich_lv_need.node, lv_str, 19)	

	local n = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CROSS_KILL_DEVIL_TOKEN)
	if StdMonster[data.BossId].nCsKillDevilTokenLimit and StdMonster[data.BossId].nCsKillDevilTokenLimit > 0 then
		local item = ItemData.FormatItemData(consumes[1])
		self.node_t_list.lbl_consume.node:setString("消耗跨服屠魔令：")
		self.node_t_list.lbl_need_num.node:setString(n .. "/" .. StdMonster[data.BossId].nCsKillDevilTokenLimit)
		self.node_t_list.lbl_need_num.node:setColor(n >= item.num and COLOR3B.GREEN or COLOR3B.RED)
	end

	self.node_t_list.lbl_num.node:setString(n .. "/" .. GlobalConfig.nInitCsDevilToken)

	local drops = {}
	local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	for k,v in pairs(data.drops) do
		drops[#drops + 1] = {item_id = v.id, num = 1, is_bind = v.bind}
	end
	self:FlushAwardList(drops)
end

function CBossInfoView:FlushAwardList(data_list)
	for k, v in pairs(self.award_cell_list) do
		v:SetData(data_list[k])
	end
end


function CBossInfoView:OnClickTipHandler()
	DescTip.Instance:SetContent(Language.Boss.CrossBossTips[self.tabbar_idx], Language.Boss.CrossBossTipsName[self.tabbar_idx])
end

function CBossInfoView:OnClickChallengeHandler()
	local data = self.boss_list:GetSelectItem():GetData()

	local item = ItemData.FormatItemData(data.consumes[1])
	
	if item == nil then return end
	local comsume = ShopData.GetItemPriceCfg(item.item_id)
	local n = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_KILL_DEVIL_TOKEN)
	if n >= item.num then
		local scene_idx = 1
		for i,v in ipairs(CrossConfig.crossFBConfigList[self.tabbar_idx].SceneInfo) do
			if v.ScencId == data.SceneId then
				scene_idx = i
				break
			end
		end
		CrossServerCtrl.Instance.SentJoinCrossServerReq(self.tabbar_idx, scene_idx)
	else
		if comsume then
			TipCtrl.Instance:OpenQuickTipItem(false, {item.item_id, comsume.price[1].type, 1})
		else
			TipCtrl.Instance:OpenGetStuffTip(item.item_id)
		end
	end
end

function CBossInfoView:SceneChange()
	local fuben_type = Scene.Instance:GetSceneLogic():GetFubenType()
	if fuben_type == FubenType.PersonalBoss then 
		ViewManager.Instance:CloseViewByDef(ViewDef.Boss)
	end
end


CBossInfoView.MoyuBossRender = BaseClass(BaseRender)
local MoyuBossRender = CBossInfoView.MoyuBossRender
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
	if self.data.BossName ~= nil and self.node_tree.rich_boss_name.node then
		local color = "55ff00"
		local is_flush = false
		if CrossServerData.Instance:GetCrossBossIsRemind(self.data.type, self.data.BossId) then
			local boss_info = CrossServerData.Instance:GetCrossBossInfoById(self.data.BossId)
			local refresh_time = boss_info and boss_info.refresh_time or 0
			local now_time = boss_info and boss_info.now_time or 0
			is_flush = (refresh_time - Status.NowTime + now_time) <= 0 
		end
		
		local zt_txt = is_flush and "已刷新" or "未刷新"
		local zt_color = is_flush and COLOR3B.GREEN or COLOR3B.G_W2
		if not is_enough then
			color = "8b7c6a" 
			zt_txt = tip .. "开启"
			zt_color = COLOR3B.RED
		else
			color = "c2c2c2" 
		end
		local str = string.format(Language.Boss.RareBossName, color, self.data.BossName)
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


CBossInfoView.PerBossListView = BaseClass(ListView)
local PerBossListView = CBossInfoView.PerBossListView

--list事件回调
function PerBossListView:ListEventCallback(sender, event_type, index)
	if self.items[index + 1] then 
		local data = self.items[index + 1].data
		if data.state == 0 then return end
	end
	PerBossListView.super.ListEventCallback(self, sender, event_type, index)
end


return CBossInfoView