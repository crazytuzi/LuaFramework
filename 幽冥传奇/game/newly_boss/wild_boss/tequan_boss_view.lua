-- 专属boss

local TequanBossView = BaseClass(SubView)

local is_tequan_id = {
	[50] = 1,
	[51] = 2,
	[52] = 3,
}

function TequanBossView:__init()
	self.texture_path_list = {
		'res/xui/boss.png',
	}
    self.config_tab = {
		{"new_boss_ui_cfg", 4, {0}},
	}
end

function TequanBossView:__delete()
end

function TequanBossView:LoadCallBack(index, loaded_times)
	self.boss_list = nil
	self.award_cell_list = nil
	self.monster_display = nil
	self.fuben_id = 0 
	self.select_index = 0
	self:CreateBossList()
	self:CreateAwardCells()
	self:CreateMonsterAnimation()

	-- XUI.AddClickEventListener(self.node_t_list.layout_vip_boss.btn_tip.node, BindTool.Bind(self.OnClickTipHandler, self))
	XUI.AddClickEventListener(self.node_t_list.layout_vip_boss.btn_enter.node, BindTool.Bind(self.OnClickChallengeHandler, self))
	self.scene_change = GlobalEventSystem:Bind(SceneEventType.SCENE_CHANGE_COMPLETE, BindTool.Bind(self.SceneChange, self))
	EventProxy.New(RoleData.Instance, self):AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.RoleAttrChange, self))
	-- EventProxy.New(LunHuiData.Instance, self):AddEventListener(LunHuiData.LUNHUI_DATA_CHANGE, BindTool.Bind(self.OnBossStateChange, self))
	EventProxy.New(FubenData.Instance, self):AddEventListener(FubenData.BOSS_ENTER_TIMES, BindTool.Bind(self.Flush, self))
end

function TequanBossView:ShowIndexCallBack()
	self:Flush()
end

function TequanBossView:ReleaseCallBack()
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

function TequanBossView:CreateMonsterAnimation()
	if nil == self.monster_display then
		self.monster_display = ModelAnimate.New(ResPath.GetMonsterAnimPath, self.node_t_list.layout_vip_boss.node, GameMath.MDirDown)
		self.monster_display:SetAnimPosition(550,265)
		self.monster_display:SetFrameInterval(FrameTime.RoleStand)
		self.monster_display:SetZOrder(100)
	end
end

function TequanBossView:CreateBossList()
	if nil ~= self.boss_list then
		return
	end

	local ph = self.ph_list.ph_boss_list
	self.boss_list = TequanBossView.PerBossListView.New()
	self.boss_list:Create(ph.x, ph.y, ph.w, ph.h, nil, TequanBossView.BossItemRender, nil, nil, self.ph_list.ph_boss_item)
	self.boss_list:SetItemsInterval(10)
	self.boss_list:SetJumpDirection(ListView.Top)
	self.boss_list:SetSelectCallBack(BindTool.Bind(self.SelectBossListCallback, self))
	self.node_t_list.layout_vip_boss.node:addChild(self.boss_list:GetView(), 20)
end

function TequanBossView:CreateAwardCells()
	if nil ~= self.award_cell_list then
		return
	end

	self.award_cell_list = {}
	for i = 1, 7 do
		local ph = self.ph_list["ph_award_cell_" .. i]
		local cell = BaseCell.New()
		cell:GetView():setAnchorPoint(0.5, 0.5)
		cell:SetPosition(ph.x, ph.y)
		self.node_t_list.layout_vip_boss.node:addChild(cell:GetView(), 101)
		table.insert(self.award_cell_list, cell)
	end
end


function TequanBossView:OnFlush(param_t)
	self.boss_list:SetDataList(PersonalBossData.Instance:SetPersonalBossList())
	self.boss_list:SelectIndex(1)
end

function TequanBossView:OnGetUiNode(node_name)
	-- 选择boss
	local boss_level = string.match(node_name, "^PersonalBossLevel(%d+)$")
	boss_level = tonumber(boss_level)
	if boss_level ~= nil then
		local list_index = nil
		for k, v in pairs(PersonalBossData.Instance:SetPersonalBossList()) do
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

	return TequanBossView.super.OnGetUiNode(self, node_name)
end

function TequanBossView:RoleAttrChange(vo)
	if vo.key == OBJ_ATTR.CREATURE_LEVEL or 
		vo.key == OBJ_ATTR.ACTOR_CIRCLE then 
			self:Flush()
	end
end

function TequanBossView:OnBossStateChange()
	self:Flush()
end

function TequanBossView:SelectBossListCallback(item)
	local select_data = item and item:GetData()
	if select_data then
		self.select_index = select_data.index
		self:FlushPersonalBossInfo(select_data)
	end
end

function TequanBossView:FlushPersonalBossInfo(data)
	if data == nil or next(data) == nil then return end
	local boss_cfg = BossData.GetMosterCfg(data.bossId)
	local boss_name = data.fubenName
	local is_enough, tip = BossData.BossIsEnoughAndTip(data)
	self.node_t_list.lbl_boss_name.node:setString(boss_name)
	self.monster_display:Show(boss_cfg.modelid)
	local model_cfg = BossData.GetMosterModelCfg(boss_cfg.modelid)
	self.monster_display:SetScale(model_cfg.modelScale)
	if boss_cfg.modelid == 139 then
		self.monster_display:SetAnimPosition(550,100)
	else
		self.monster_display:SetAnimPosition(550,240)
	end
	local txt = is_enough and (data.boss_lv .. "级") or (tip ..(data.viplv and "专属" or Language.Boss.VipBossTxt[is_tequan_id[data.fubenId]]))
	self.node_t_list.lbl_boss_lv.node:setString(txt)
	-- self.node_t_list.lbl_boss_scene.node:setLocalZOrder(999)
	
	local left_time = data.cd_time-Status.NowTime
	if left_time > 0 then
		if self.timer then
			GlobalTimerQuest:CancelQuest(self.timer)
			self.timer = nil
		end

		self.node_t_list["lbl_time"].node:setVisible(true)
		local callback = function()
			
			local left_time = data.cd_time - Status.NowTime
			if left_time > 0 then
				self.node_t_list["lbl_time"].node:setString(TimeUtil.FormatSecond(left_time, 3) .. "后+1")
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
		self.node_t_list["lbl_time"].node:setVisible(false)
	end

	local color = data.times >= data.Number and "55ff00" or "ff0000"
	local times_txt = string.format(Language.Boss.TequanBossGroup[2], color, data.times, data.Number)
	RichTextUtil.ParseRichText(self.node_t_list["rich_times_need"].node, times_txt, 19)
	
	local role_lv = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	local color = data.needLevel <= role_lv and "1eff00" or "ff2828"
	local lv_txt = string.format(Language.Boss.TequanBossGroup[1], color, data.needLevel .. "级开启")
	RichTextUtil.ParseRichText(self.node_t_list["rich_lv_need"].node, lv_txt, 19)

	local n = BagData.Instance:GetItemNumInBagById(data.item_id, nil)
	self.node_t_list.lbl_veed_num.node:setString(n .. "/" .. data.item_count)
	self.node_t_list.lbl_veed_num.node:setColor(n >= data.item_count and COLOR3B.GREEN or COLOR3B.RED)

	local drop_list = {}
	local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	for k,v in pairs(data.drops) do
		drop_list[#drop_list + 1] = {item_id = v.id, num = 1, is_bind = v.bind}
	end
	self:FlushAwardList(drop_list)
end

function TequanBossView:FlushAwardList(data_list)
	for k, v in pairs(self.award_cell_list) do
		v:SetData(data_list[k])
	end
end


function TequanBossView:OnClickTipHandler()
	DescTip.Instance:SetContent(Language.Boss.PerBossTips, Language.Boss.PerBossTipsName)
end

function TequanBossView:OnClickChallengeHandler()
	local data = self.boss_list:GetSelectItem():GetData()

	local item = ShopData.GetItemPriceCfg(data.item_id)
	local n = BagData.Instance:GetItemNumInBagById(data.item_id, nil)
	if n >= data.item_count then
		if data and data.fubenId then
			FubenCtrl.EnterFubenReq(data.fubenId)
		end
	else
		if item then
			TipCtrl.Instance:OpenQuickTipItem(false, {data.item_id, item.price[1].type, 1})
		else
			TipCtrl.Instance:OpenGetStuffTip(data.item_id)
		end
	end

end

function TequanBossView:SceneChange()
	local fuben_type = Scene.Instance:GetSceneLogic():GetFubenType()
	if fuben_type == FubenType.PersonalBoss then 
		ViewManager.Instance:CloseViewByDef(ViewDef.Boss)
	end
end


TequanBossView.BossItemRender = BaseClass(BaseRender)
local BossItemRender = TequanBossView.BossItemRender
function BossItemRender:__init()
end

function BossItemRender:__delete()
end

function BossItemRender:CreateChild()
	BossItemRender.super.CreateChild(self)
	XUI.RichTextSetCenter(self.node_tree.rich_boss_name.node)
end

function BossItemRender:OnFlush()
	-- self.node_tree.img_remind_flag.node:setVisible(false)
	-- self.node_tree.img_arrow.node:setVisible(false)
	local is_enough, tip = BossData.BossIsEnoughAndTip(self.data)
	local name = ""
	-- self.node_tree.img_remind_flag.node:setVisible(self.data.state == 2)
	
	self.node_tree.img_unopen.node:setVisible(self.data.state == 2)
	if self.data.fubenName ~= nil and self.node_tree.rich_boss_name.node and nil ~= self.data.index then
		local color = "8b7c6a"
		local lv_color = ""
		local lv_txt = ""--tip .. (self.data.viplv and "开启" or Language.Boss.VipBossTxt[is_tequan_id[self.data.fubenId]])
		if 2 == self.data.state then
			color = "55ff00"
		end


		if self.data.is_tequan then
			if PrivilegeData.Instance:IsTeQuan(is_tequan_id[self.data.fubenId]) then
				lv_txt = "【" .. self.data.boss_lv .. "级】"
				lv_color = (0 == self.data.state) and COLOR3B.GRAY2 or COLOR3B.GREEN
			else
				lv_txt = Language.Boss.VipBossTxt[is_tequan_id[self.data.fubenId]]
				lv_color = COLOR3B.RED
			end
		else
			if is_enough then
				lv_txt = "【" .. self.data.boss_lv .. "级】"
				lv_color = (0 == self.data.state) and COLOR3B.GRAY2 or COLOR3B.GREEN
			else
				lv_txt = tip .. "开启"
				lv_color = COLOR3B.RED
			end
		end
		local str = string.format(Language.Boss.RareBossName, color, self.data.fubenName)
		RichTextUtil.ParseRichText(self.node_tree.rich_boss_name.node, str, 19)
		self.node_tree.lbl_boss_lv.node:setString(lv_txt)
		self.node_tree.lbl_boss_lv.node:setColor(lv_color)
	end

	--特权卡标记
	-- if self.data.is_tequan and not self.tip then
	-- 	self.tip = XUI.CreateImageView(57, 33, ResPath.GetBoss("tip"), true)
	-- 	self.view:addChild(self.tip, 110)
	-- end
	-- if self.tip then
	self.node_tree.img_tip.node:setVisible(self.data.is_tequan and PrivilegeData.Instance:IsTeQuan(is_tequan_id[self.data.fubenId]))
	-- end

	if self.cache_select and self.is_select then
		self.cache_select = false
		self:CreateSelectEffect()
	end
	-- self:OnSelectChange(self.is_select)
end

function BossItemRender:CreateSelectEffect()
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

-- function BossItemRender:OnSelectChange(is_select)
	-- if self.node_tree.img_arrow then 
	-- 	self.node_tree.img_arrow.node:setVisible(is_select)
	-- end
-- end


TequanBossView.PerBossListView = BaseClass(ListView)
local PerBossListView = TequanBossView.PerBossListView

--list事件回调
function PerBossListView:ListEventCallback(sender, event_type, index)
	if self.items[index + 1] then 
		local data = self.items[index + 1].data
		-- if data.state == 0 then return end
	end
	PerBossListView.super.ListEventCallback(self, sender, event_type, index)
end


return TequanBossView