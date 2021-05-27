local PersonalBossView = BaseClass(SubView)

function PersonalBossView:__init()
	self.texture_path_list = {
		'res/xui/boss.png',
	}
    self.config_tab = {
    	{"boss_ui_cfg", 1, {0}},
		{"boss_ui_cfg", 2, {0}},
	}
end

function PersonalBossView:__delete()
end

function PersonalBossView:LoadCallBack(index, loaded_times)
	self.boss_list = nil
	self.award_cell_list = nil
	self.monster_display = nil
	self.fuben_id = 0 
	self.select_index = 0
	self:CreateBossList()
	self:CreateAwardCells()
	self:CreateMonsterAnimation()

	XUI.AddClickEventListener(self.node_t_list.layout_personal_boss.btn_tip.node, BindTool.Bind(self.OnClickTipHandler, self))
	XUI.AddClickEventListener(self.node_t_list.layout_personal_boss.btn_challenge.node, BindTool.Bind(self.OnClickChallengeHandler, self))
	self.scene_change = GlobalEventSystem:Bind(SceneEventType.SCENE_CHANGE_COMPLETE, BindTool.Bind(self.SceneChange, self))
	EventProxy.New(RoleData.Instance, self):AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.RoleAttrChange, self))
	-- EventProxy.New(LunHuiData.Instance, self):AddEventListener(LunHuiData.LUNHUI_DATA_CHANGE, BindTool.Bind(self.OnBossStateChange, self))
end

function PersonalBossView:ShowIndexCallBack()
	self:Flush()
end

function PersonalBossView:ReleaseCallBack()
	if self.boss_list then
		self.boss_list:DeleteMe()
		self.boss_list = nil 
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

function PersonalBossView:CreateMonsterAnimation()
	if nil == self.monster_display then
		self.monster_display = ModelAnimate.New(ResPath.GetMonsterAnimPath, self.node_t_list.layout_personal_boss.node, GameMath.MDirDown)
		self.monster_display:SetAnimPosition(550,265)
		self.monster_display:SetFrameInterval(FrameTime.RoleStand)
		self.monster_display:SetZOrder(100)
	end
end

function PersonalBossView:CreateBossList()
	if nil ~= self.boss_list then
		return
	end

	local ph = self.ph_list.ph_boss_list
	self.boss_list = PersonalBossView.PerBossListView.New()
	self.boss_list:Create(ph.x + 6, ph.y, ph.w, ph.h, nil, PersonalBossView.BossItemRender, nil, nil, self.ph_list.ph_boss_item)
	self.boss_list:SetItemsInterval(10)
	self.boss_list:SetJumpDirection(ListView.Top)
	self.boss_list:SetSelectCallBack(BindTool.Bind(self.SelectBossListCallback, self))
	self.node_t_list.layout_personal_boss.node:addChild(self.boss_list:GetView(), 20)
end

function PersonalBossView:CreateAwardCells()
	if nil ~= self.award_cell_list then
		return
	end

	self.award_cell_list = {}
	for i = 1, 7 do
		local ph = self.ph_list["ph_award_cell_" .. i]
		local cell = BaseCell.New()
		cell:GetView():setAnchorPoint(0.5, 0.5)
		cell:SetPosition(ph.x, ph.y)
		self.node_t_list.layout_personal_boss.node:addChild(cell:GetView(), 20)
		table.insert(self.award_cell_list, cell)
	end
end


function PersonalBossView:OnFlush(param_t)
	self.boss_list:SetDataList(PersonalBossData.Instance:GetPersonalBossList())
	self.boss_list:SelectIndex(1)
end

function PersonalBossView:OnGetUiNode(node_name)
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

	return PersonalBossView.super.OnGetUiNode(self, node_name)
end

function PersonalBossView:RoleAttrChange(vo)
	if vo.key == OBJ_ATTR.CREATURE_LEVEL or 
		vo.key == OBJ_ATTR.ACTOR_CIRCLE then 
			self:Flush()
	end
end

function PersonalBossView:OnBossStateChange()
	self:Flush()
end

function PersonalBossView:SelectBossListCallback(item)
	local select_data = item and item:GetData()
	if select_data then
		self.select_index = select_data.index
		self:FlushPersonalBossInfo(select_data)
	end
end

function PersonalBossView:FlushPersonalBossInfo(data)
	if data == nil or next(data) == nil then return end
	local boss_cfg = BossData.GetMosterCfg(data.bossId)
	local boss_name = data.fubenName
	local is_enough, tip = BossData.BossIsEnoughAndTip(data)
	self.node_t_list.lbl_boss_name.node:setString(boss_name .. "(" .. tip .. ")")
	self.monster_display:Show(boss_cfg.modelid)
	local model_cfg = BossData.GetMosterModelCfg(boss_cfg.modelid)
	self.monster_display:SetScale(model_cfg.modelScale)
	if boss_cfg.modelid == 139 then
		self.monster_display:SetAnimPosition(550,100)
	else
		self.monster_display:SetAnimPosition(550,240)
	end
	local txt = data.viplv and "专属" or Language.Boss.PerBossCanChallenge
	self.node_t_list.lbl_boss_scene.node:setString(tip .. txt)
	self.node_t_list.lbl_boss_scene.node:setLocalZOrder(999)

	self.node_t_list.lbl_challenge_limit.node:setVisible(not is_enough)
	self.node_t_list.lbl_challenge_limit.node:setString(tip .. Language.Boss.PerBossCanChallenge)
	self.node_t_list.btn_challenge.node:setVisible(is_enough)

	local drop_list = {}
	local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	for k,v in pairs(data.drops) do
		drop_list[#drop_list + 1] = {item_id = v.id, num = 1, is_bind = v.bind}
	end
	self:FlushAwardList(drop_list)
end

function PersonalBossView:FlushAwardList(data_list)
	for k, v in pairs(self.award_cell_list) do
		v:SetData(data_list[k])
	end
end


function PersonalBossView:OnClickTipHandler()
	DescTip.Instance:SetContent(Language.Boss.PerBossTips, Language.Boss.PerBossTipsName)
end

function PersonalBossView:OnClickChallengeHandler()
	local data = self.boss_list:GetSelectItem():GetData()
	if data and data.fubenId then
		FubenCtrl.EnterFubenReq(data.fubenId)
	-- 	self.fuben_id = data.fubenId
	end
end

function PersonalBossView:SceneChange()
	local fuben_type = Scene.Instance:GetSceneLogic():GetFubenType()
	if fuben_type == FubenType.PersonalBoss then 
		ViewManager.Instance:CloseViewByDef(ViewDef.Boss)
	end
end


PersonalBossView.BossItemRender = BaseClass(BaseRender)
local BossItemRender = PersonalBossView.BossItemRender
function BossItemRender:__init()
end

function BossItemRender:__delete()
end

function BossItemRender:CreateChild()
	BossItemRender.super.CreateChild(self)
	XUI.RichTextSetCenter(self.node_tree.rich_boss_name.node)
end

function BossItemRender:OnFlush()
	self.node_tree.img_remind_flag.node:setVisible(false)
	-- self.node_tree.img_arrow.node:setVisible(false)
	local is_enough, tip = BossData.BossIsEnoughAndTip(self.data)
	local name = ""
	self.node_tree.img_remind_flag.node:setVisible(self.data.state == 2)
	
	if self.data.fubenName ~= nil and self.node_tree.rich_boss_name.node and nil ~= self.data.index then
		local color = "8b7c6a"
		if 2 == self.data.state then
			color = "55ff00" 
		end
		self.node_tree.img_unopen.node:setVisible(false)
		local str = string.format(Language.Boss.RareBossName, color, self.data.fubenName)
		RichTextUtil.ParseRichText(self.node_tree.rich_boss_name.node, str, 19)
	end

	--特权卡标记
	-- if self.data.is_tequan and not self.tip then
	-- 	self.tip = XUI.CreateImageView(57, 33, ResPath.GetBoss("tip"), true)
	-- 	self.view:addChild(self.tip, 110)
	-- end
	-- if self.tip then
	-- 	self.tip:setVisible(self.data.is_tequan)
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


PersonalBossView.PerBossListView = BaseClass(ListView)
local PerBossListView = PersonalBossView.PerBossListView

--list事件回调
function PerBossListView:ListEventCallback(sender, event_type, index)
	if self.items[index + 1] then 
		local data = self.items[index + 1].data
		if data.state == 0 then return end
	end
	PerBossListView.super.ListEventCallback(self, sender, event_type, index)
end


return PersonalBossView