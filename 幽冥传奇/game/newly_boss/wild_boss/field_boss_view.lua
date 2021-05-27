-- 野外boss

local FieldBossView = BaseClass(SubView)

function FieldBossView:__init()
	self.texture_path_list = {
		'res/xui/boss.png',
	}
    self.config_tab = {
		{"new_boss_ui_cfg", 3, {0}},
	}
end

function FieldBossView:__delete()
end

function FieldBossView:LoadCallBack(index, loaded_times)
	-- self.boss_list = nil
	self:CreateBossList()
	self.award_cell_list = nil
	self.monster_display = nil
	-- self.fuben_id = 0 
	self:CreateAwardCells()
	self:CreateMonsterAnimation()
	self.select_index = 1

	-- XUI.AddClickEventListener(self.node_t_list.layout_wild_boss.btn_tip.node, BindTool.Bind(self.OnClickTipHandler, self))
	XUI.AddClickEventListener(self.node_t_list.layout_wild_boss.btn_challenge.node, BindTool.Bind(self.OnClickChallengeHandler, self))
	self.node_t_list.layout_wild_boss.btn_challenge.node:setVisible(false)
	self.scene_change = GlobalEventSystem:Bind(SceneEventType.SCENE_CHANGE_COMPLETE, BindTool.Bind(self.SceneChange, self))
	EventProxy.New(RoleData.Instance, self):AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.RoleAttrChange, self))
	EventProxy.New(NewlyBossData.Instance, self):AddEventListener(NewlyBossData.NEWLY_BOSS_REMIND, BindTool.Bind(self.Flush, self))
	EventProxy.New(BossData.Instance, self):AddEventListener(BossData.UPDATE_BOSS_DATA, BindTool.Bind(self.Flush, self))
end

function FieldBossView:ShowIndexCallBack()
	self.select_index = 1
	self.boss_list:ChangeToIndex(1)
	self:Flush()
end

function FieldBossView:ReleaseCallBack()
	if self.boss_list then
		self.boss_list:DeleteMe()
		self.boss_list = nil 
	end

	if self.boss_item then
		self.boss_item:DeleteMe()
		self.boss_item = nil 
	end

	if self.monster_display then
		self.monster_display:DeleteMe()
		self.monster_display = nil 
	end

	if self.award_cell_list  then
		for k,v in pairs(self.award_cell_list ) do
			v:DeleteMe()
		end
		self.award_cell_list = nil
	end
	GlobalEventSystem:UnBind(self.scene_change)
end

function FieldBossView:CreateMonsterAnimation()
	if nil == self.monster_display then
		self.monster_display = ModelAnimate.New(ResPath.GetMonsterAnimPath, self.node_t_list.layout_wild_boss.node, GameMath.MDirDown)
		-- self.monster_display:SetAnimPosition(550,265)
		self.monster_display:SetFrameInterval(FrameTime.RoleStand)
		self.monster_display:SetZOrder(100)
	end
end

function FieldBossView:CreateBossList()
	if nil ~= self.boss_list then
		return
	end

	local ph = self.ph_list.ph_boss_list
	self.boss_list = ListView.New()
	self.boss_list:Create(ph.x, ph.y, ph.w, ph.h, nil, FieldBossView.FieldBossRender, nil, nil, self.ph_list.ph_boss_item)
	self.boss_list:SetItemsInterval(10)
	self.boss_list:SetJumpDirection(ListView.Top)
	self.boss_list:SetSelectCallBack(BindTool.Bind(self.SelectBossListCallback, self))
	self.node_t_list.layout_wild_boss.node:addChild(self.boss_list:GetView(), 101)

	if nil ~= self.boss_item then
		return
	end

	local ph = self.ph_list.ph_enter_list
	self.boss_item = ListView.New()
	self.boss_item:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Horizontal, FieldBossView.BossItemRender, nil, nil, self.ph_list.ph_enter_item)
	self.boss_item:SetItemsInterval(10)
	self.boss_item:SetJumpDirection(ListView.Top)
	self.boss_item:SetSelectCallBack(BindTool.Bind(self.SelectBossItemCallback, self))
	self.node_t_list.layout_wild_boss.node:addChild(self.boss_item:GetView(), 101)
end

function FieldBossView:SelectBossItemCallback()
	-- body
end

function FieldBossView:CreateAwardCells()
	if nil ~= self.award_cell_list then
		return
	end

	self.award_cell_list = {}
	for i = 1, 7 do
		local ph = self.ph_list["ph_award_cell_" .. i]
		local cell = BaseCell.New()
		cell:GetView():setAnchorPoint(0.5, 0.5)
		cell:SetPosition(ph.x, ph.y)
		self.node_t_list.layout_wild_boss.node:addChild(cell:GetView(), 102)
		table.insert(self.award_cell_list, cell)
	end
end


function FieldBossView:OnFlush(param_t)
	local boss_list
	-- if self:GetViewDef() == ViewDef.Boss.RareBoss then
	-- 	boss_list = NewBossData.Instance:SetRareBossInfo(2)
	-- elseif self:GetViewDef() == ViewDef.Boss.MoshaBoss then
		-- boss_list = NewBossData.Instance:SetRareBossInfo(1)
	-- end
	-- PrintTable(NewlyBossData.Instance:GetFieldBossData()[1])
	boss_list = NewlyBossData.Instance:GetFieldBossData(1)
	self.boss_list:SetDataList(boss_list)

	self.boss_item:SetDataList(boss_list and boss_list[self.select_index].item)


	self.boss_list:SelectIndex(self.select_index)
end

function FieldBossView:OnGetUiNode(node_name)
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

	return FieldBossView.super.OnGetUiNode(self, node_name)
end

function FieldBossView:RoleAttrChange(vo)
	if vo.key == OBJ_ATTR.CREATURE_LEVEL or 
		vo.key == OBJ_ATTR.ACTOR_CIRCLE then 
			self:Flush()
	end
end

function FieldBossView:OnBossStateChange()
	self:Flush()
end

function FieldBossView:SelectBossListCallback(item, index)
	local select_data = item and item:GetData()
	if select_data then
		self.select_index = index
		self:FlushPersonalBossInfo(select_data)
	end
end

function FieldBossView:FlushPersonalBossInfo(data)
	if data == nil or next(data) == nil then return end
	local boss_cfg = BossData.GetMosterCfg(data.boss_id)
	local boss_name = data.boss_name
	local is_enough, tip = BossData.BossIsEnoughAndTip(data)
	self.node_t_list.lbl_boss_name.node:setString(boss_name)
	self.node_t_list.lbl_boss_lv.node:setString(data.bosslv .. "级")

	-- self.node_t_list.lbl_flush_time.node:setString(string.format(Language.Boss.BossFlushTime, data.limit_time/60))
	-- self.node_t_list.lbl_boss_scene.node:setLocalZOrder(999)
	self.monster_display:Show(boss_cfg.modelid)
	if boss_cfg.modelid == 139 then
		self.monster_display:SetAnimPosition(550,100)
	else
		self.monster_display:SetAnimPosition(550,240)
	end
	local model_cfg = BossData.GetMosterModelCfg(boss_cfg.modelid)
	self.monster_display:SetScale(model_cfg.modelScale)

	self.boss_item:SetDataList(data.item)

	local drop_list = {}
	local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	for k,v in pairs(data.boss_drop) do
		drop_list[#drop_list + 1] = {item_id = v.id, num = 1, is_bind = v.bind}
	end
	self:FlushAwardList(drop_list)
end

function FieldBossView:FlushAwardList(data_list)
	for k, v in pairs(self.award_cell_list) do
		v:SetData(data_list[k])
	end
end


function FieldBossView:OnClickTipHandler()
	DescTip.Instance:SetContent(Language.Boss.RareBossTips, Language.Boss.RareBossTipsName)
end

function FieldBossView:OnClickChallengeHandler()
	local data = self.boss_list:GetSelectItem():GetData()
	-- if data and data.fubenId then
	-- 	FubenCtrl.EnterFubenReq(data.fubenId)
	-- 	self.fuben_id = data.fubenId
	-- end
	-- Scene.SendQuicklyTransportReqByNpcId(192)
	
	if data.chuansongId == 0 then
		BossCtrl.CSChuanSongBossScene(data.boss_type, data.boss_id)
	else
		GuajiCtrl.Instance:FlyByIndex(data.chuansongId)
	end
end

function FieldBossView:SceneChange()
	local fuben_type = Scene.Instance:GetSceneLogic():GetFubenType()
	if fuben_type == FubenType.PersonalBoss then 
		ViewManager.Instance:CloseViewByDef(ViewDef.Boss)
	end
end


FieldBossView.FieldBossRender = BaseClass(BaseRender)
local FieldBossRender = FieldBossView.FieldBossRender
function FieldBossRender:__init()
end

function FieldBossRender:__delete()
end

function FieldBossRender:CreateChild()
	FieldBossRender.super.CreateChild(self)
	XUI.RichTextSetCenter(self.node_tree.rich_boss_name.node)
	XUI.RichTextSetCenter(self.node_tree.rich_boss_lv.node)
end

function FieldBossRender:OnFlush()
	-- self.node_tree.img_remind_flag.node:setVisible(false)
	local is_enough, tip = BossData.BossIsEnoughAndTip(self.data)
	local name = ""
	-- self.node_tree.img_remind_flag.node:setVisible(self.data.boss_state ~= 2)
	local is_rem = BossData.Instance:GetRemindFlag(self.data.boss_type, self.data.rindex) == 0
	
	self.node_tree.img_unopen.node:setVisible(self.data.boss_state == 0 and is_rem)
	if self.data.boss_name ~= nil and self.node_tree.rich_boss_name.node and nil ~= self.data.rindex then
		local color = "55ff00"
		if 2 == self.data.boss_state then
			color = "8b7c6a" 
		elseif 3 == self.data.boss_state then
			color = "c2c2c2" 
		end
		local str = string.format(Language.Boss.RareBossName, color, self.data.boss_name)
		local str_lv = ""
		if is_enough then
			str_lv = string.format(Language.Boss.FieldBossLv, color, self.data.bosslv)
		else
			str_lv = string.format(Language.Boss.CircleBossLv[1], color, tip)
		end
		RichTextUtil.ParseRichText(self.node_tree.rich_boss_name.node, str, 18)
		RichTextUtil.ParseRichText(self.node_tree.rich_boss_lv.node, str_lv, 18)
	end


	if self.cache_select and self.is_select then
		self.cache_select = false
		self:CreateSelectEffect()
	end
	-- self:OnSelectChange(self.is_select)
end

function FieldBossRender:CreateSelectEffect()
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

-- function FieldBossRender:OnSelectChange(is_select)
	-- if self.node_tree.img_arrow then 
	-- 	self.node_tree.img_arrow.node:setVisible(is_select)
	-- end
-- end


FieldBossView.PerBossListView = BaseClass(ListView)
local PerBossListView = FieldBossView.PerBossListView

--list事件回调
function PerBossListView:ListEventCallback(sender, event_type, index)
	if self.items[index + 1] then 
		local data = self.items[index + 1].data
		if data.state == 0 then return end
	end
	PerBossListView.super.ListEventCallback(self, sender, event_type, index)
end

FieldBossView.BossItemRender = BaseClass(BaseRender)
local BossItemRender = FieldBossView.BossItemRender
function BossItemRender:__init()
	
end

function BossItemRender:__delete()
	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end
end

function BossItemRender:CreateChild()
	BaseRender.CreateChild(self)

	XUI.AddClickEventListener(self.node_tree.btn_enter.node, BindTool.Bind(self.OnClickEnter, self))
end

function BossItemRender:OnFlush()
	if nil == self.data then return end

	self.node_tree.lbl_map_name.node:setString(self.data.scene)
	self.node_tree.img_bg.node:setGrey(self.data.state == 0)
	self.node_tree.flush_time.node:setVisible(self.data.state == 0)
	self.node_tree.btn_enter.node:setEnabled(self.data.is_kill)

	local left_time = self.data.refresh_time - Status.NowTime + self.data.now_time
	self.node_tree.flush_time.node:setColor(left_time > 0 and COLOR3B.RED or COLOR3B.GREEN)
	if left_time > 0 then
		self.node_tree.btn_enter.node:setVisible(false)	
		if self.timer then
			GlobalTimerQuest:CancelQuest(self.timer)
			self.timer = nil
		end

		local callback = function()
			local left_time = self.data.refresh_time - Status.NowTime + self.data.now_time
			if left_time > 0 then
				self.node_tree["flush_time"].node:setString(TimeUtil.FormatSecond(left_time, 3) .. "后刷新")
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
		self.node_tree.flush_time.node:setString("")
		self.node_tree.btn_enter.node:setVisible(true)	
	end
end

function BossItemRender:OnClickEnter()
	if self.data.cs_id == 0 then
		BossCtrl.CSChuanSongBossScene(self.data.boss_type, self.data.boss_id)
		NewlyBossCtrl.Instance:GetChange(true)
	else
		GuajiCtrl.Instance:FlyByIndex(self.data.cs_id)
	end
end

function BossItemRender:CreateSelectEffect()
end


return FieldBossView