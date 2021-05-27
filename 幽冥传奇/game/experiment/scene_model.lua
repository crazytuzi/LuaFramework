--------------------------------------------------
--模拟动画场景模态（模拟动画时，上面放一层，防止操作）
--------------------------------------------------
SceneModal = SceneModal or BaseClass(XuiBaseView)
function SceneModal:__init()
	if SceneModal.Instance then
		ErrorLog("[SceneModal] Attemp to create a singleton twice !")
	end
	SceneModal.Instance = self

	self.texture_path_list[1] = 'res/xui/experiment.png'
	self.config_tab = {
		{"scene_obj_ui", 2, {0}},
	}

	self.zodaer = COMMON_CONSTS.ZORDER_GUIDE
end

function SceneModal:__delete()
	SceneModal.Instance = nil
end

function SceneModal:ReleaseCallBack()
 	self.role_1 = nil
 	self.role_2 = nil

 	if self.progressbar1 then
 		self.progressbar1:DeleteMe()
 		self.progressbar1 = nil
 	end

 	if self.progressbar2 then
 		self.progressbar2:DeleteMe()
 		self.progressbar2 = nil
 	end
end

function SceneModal:CloseCallBack()
	-- self.ui_node_list = {}
	-- self.ui_ph_list = {}
end

function SceneModal:OpenCallBack()
end

function SceneModal:LoadCallBack()
	local screen_w = HandleRenderUnit:GetWidth()
	local screen_h = HandleRenderUnit:GetHeight()
	self.root_node:setContentSize(cc.size(screen_w, screen_h))
	self.root_node:setPosition(0, 0)
	self.root_node:setAnchorPoint(0,0)

	XUI.AddClickEventListener(self.node_t_list.skip_btn.node, function ()
		self:OnPkPlayEnd()
	end)
end

function SceneModal:OnFlush()
end

function SceneModal:ShowIndexCallBack()
	self:OnEnterRob()
end







-- 进入pk场景回调
function SceneModal:OnEnterRob()
	self.is_in_pk = true

	self.node_t_list.layout_rob_tip.node:setVisible(false)
	self.node_t_list.lbl_rob_tip.node:setString(self.data.role_info.power <= RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_BATTLE_POWER) and Language.Dig.RobTip3 or Language.Dig.RobTip4)
	-- 
	self.obj_create_bind = GlobalEventSystem:Bind(ObjectEventType.OBJ_CREATE, BindTool.Bind(self.OnObjCreate, self))

	-- 屏蔽所有界面，停止主角所有动作
	GuideCtrl.Instance:CloseForeshowBaseView()
	Scene.Instance:GetMainRole():StopMove()
	Scene.Instance:GetMainRole():ClearAction()
	self:SetOtherOpenViewVisible(false)
	self:SetOtherSceneObjsVisible(false)

	--视角移至地图中心
	local real_pos_x, real_pos_y = HandleRenderUnit:LogicToWorldXY(42, 54)
	HandleGameMapHandler:setViewCenterPoint(real_pos_x, real_pos_y)

	-- 初始化pk玩家信息
	self:InitRoleState()

	-- 开始倒计时
	local go_time = 3
	self.node_t_list.layout_downtime.node:setVisible(true)
	self.node_t_list.layout_downtime.img_time.node:loadTexture(ResPath.GetExperiment("num_" .. go_time))
	self.node_t_list.layout_downtime.img_time.node:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 1.2), cc.ScaleTo:create(0.2, 1)))
	if nil == self.resume_timer then
		self.resume_timer = nil
		self.resume_timer = GlobalTimerQuest:AddRunQuest(function ()
			go_time = go_time - 1
			if go_time == 0 then
				self:DeleteDownTimer()
				self.node_t_list.layout_downtime.node:setVisible(false)
				self:OnPkPlay()
			else
				self.node_t_list.layout_downtime.img_time.node:loadTexture(ResPath.GetExperiment("num_" .. go_time))
				self.node_t_list.layout_downtime.img_time.node:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 1.2), cc.ScaleTo:create(0.2, 1)))
			end
		end, 1)
	end

end

function SceneModal:DeleteDownTimer()
	if self.resume_timer then
		GlobalTimerQuest:CancelQuest(self.resume_timer)
		self.resume_timer = nil
	end
end

-- 退出pk场景
function SceneModal:OnEndRob()
	self.is_in_pk = false
	self.data = nil
	self:SetOtherSceneObjsVisible(true)
	self:SetOtherOpenViewVisible(true)

	if nil ~= self.obj_create_bind then		
		GlobalEventSystem:UnBind(self.obj_create_bind)
		self.obj_create_bind = nil
	end
	
	SceneModal.Instance:Close()

	HandleGameMapHandler:ResetViewCenterPoint()

	ExperimentCtrl.SendExperimentOptReq(7)
end





-------------------------------------
-- 模拟pk

-- 倒计时结束 开始pk
function SceneModal:OnPkPlay()
	self.role_1.PlayAct("atk1")
	self.role_2.PlayAct("atk1")

	self.hp_1 = 100
	self.hp_2 = 100
	-- 按时扣血 弹伤害文字
	self.fight_timer = GlobalTimerQuest:AddRunQuest(function ()		
		self:FitghtUpdate()
	end, FrameTime.Effect * 7)
end

-- pk结束 一方胜出
function SceneModal:OnPkPlayEnd()
	self:DeleteDownTimer()
	self:DeleteFightTimer()
	self.node_t_list.layout_rob_tip.node:setVisible(true)
	self.node_t_list.layout_downtime.node:setVisible(false)
	GlobalTimerQuest:AddDelayTimer(function ()		
		self:Close()
		self:OnEndRob()
	end, 1.2)

	local is_self_win = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_BATTLE_POWER) >= self.data.role_info.power

	if is_self_win then
		self.progressbar2:SetPercent(0, false)
	else
		self.progressbar1:SetPercent(0, false)
	end

	self.role_1.PlayAct(is_self_win and "stand" or SceneObjState.Dead)
	self.role_2.PlayAct(is_self_win and SceneObjState.Dead or "stand")
end

-- 模拟pk掉血 血条减少 弹出伤害文字
function SceneModal:FitghtUpdate()
	local hp_reduce_1 = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_BATTLE_POWER) /  (RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_BATTLE_POWER) + self.data.role_info.power)
	local hp_reduce_2 = self.data.role_info.power / (RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_BATTLE_POWER) + self.data.role_info.power)

	self.progressbar1:SetPercent(self.hp_1, false)
	self.progressbar2:SetPercent(self.hp_2, false)
	self.hp_1 = self.hp_1 + hp_reduce_1 * 4 - 10
	self.hp_2 = self.hp_2 + hp_reduce_2 * 4 - 10

	local ph = self.ph_list.ph_action
	local real_pos_x, real_pos_y = HandleRenderUnit:LogicToWorldXY(42, 54)
	local hurt_1 = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_MAX_HP) * (hp_reduce_1 * 4 + 10) / 100
	local hurt_2 = self.data.role_info.HP * (hp_reduce_2 * 4 + 10) / 100
	FightTextMgr:OnChangeHp(real_pos_x - 200, real_pos_y + 30, hurt_1, 0)
	FightTextMgr:OnChangeHp(real_pos_x, real_pos_y + 30, hurt_2, 0)

	if self.hp_1 <= 0 or self.hp_2 <= 0 then
		self:DeleteFightTimer()
		self:OnPkPlayEnd()
		self.hp_1 = 100
		self.hp_2 = 100
	end
end

function SceneModal:DeleteFightTimer()
	if self.fight_timer then
		GlobalTimerQuest:CancelQuest(self.fight_timer)
		self.fight_timer = nil
	end
end





-------------------------------
-- UI创建 玩家初始化

local zOrder_res = {myself = {10, 11}, other = {10, 9}}
function SceneModal:CreateRole(info)
	local role = {}
	local act_sp = RenderUnit.CreateAnimSprite(nil, nil, nil, nil)
	act_sp:setScale(1.3)
	self.node_t_list.layer_dig_pk_show.node:addChild(act_sp, zOrder_res[info.is_self and "myself" or "other"][1])

	local act_wuqi_sp = RenderUnit.CreateAnimSprite(nil, nil, nil, nil)
	act_wuqi_sp:setScale(1.3)
	self.node_t_list.layer_dig_pk_show.node:addChild(act_wuqi_sp, zOrder_res[info.is_self and "myself" or "other"][2])

	role.PlayAct = function (name)
		local act_num = name == SceneObjState.Dead and 1 or COMMON_CONSTS.MAX_LOOPS
		local anim_path, anim_name = ResPath.GetRoleAnimPath(info.cloth, name, info.dir)
		act_sp:setAnimate(anim_path, anim_name, act_num, FrameTime.Effect, false)

		if info.weapon ~= 0 then
			local anim_path2, anim_name2 = ResPath.GetWuqiAnimPath(info.weapon, name, info.dir)
			act_wuqi_sp:setAnimate(anim_path2, anim_name2, act_num, FrameTime.Effect, false)
		end
	end

	role.SetPosition = function (x, y)
		act_sp:setPosition(x, y)
		act_wuqi_sp:setPosition(x, y)
	end

	return role
end

function SceneModal:InitRoleState()
	local role1_info = {
		power = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_BATTLE_POWER),
		cloth = RoleData.Instance:GetAttr(OBJ_ATTR.ENTITY_MODEL_ID),
		weapon = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_WEAPON_APPEARANCE),
		sex = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX),
		name = RoleData.Instance:GetRoleName(),
		dir = GameMath.DirRight,
		is_self = true,
	}

	local role2_info = self.data.role_info
	role2_info.dir = GameMath.DirLeft
	role2_info.name = ExperimentData.Instance:GetDigSlotInfoByIndex(self.data.slot).role_name

	-- 头像栏
	self.node_t_list.img_head1.node:loadTexture(ResPath.GetRoleHead("small_1_" .. role1_info.sex))
	self.node_t_list.img_head1.node:setScaleX(1)
	self.node_t_list.img_head2.node:loadTexture(ResPath.GetRoleHead("small_1_" .. role2_info.sex))

	self.node_t_list.lbl_rob1_name.node:setString(role1_info.name)
	self.node_t_list.lbl_rob2_name.node:setString(role2_info.name)

	if nil == self.progressbar2 or nil == self.progressbar1 then
		local prog = XUI.CreateLoadingBar(164, 42, ResPath.GetExperiment("hp_bar2"), true, nil, false, 143, 20, cc.rect(15,2,14,6))
		prog:setLocalZOrder(999)
		self.node_t_list.layout_role_1.node:addChild(prog)
		self.progressbar1 = ProgressBar.New()
		self.progressbar1:SetView(prog)

		local prog2 = XUI.CreateLoadingBar(140, 42, ResPath.GetExperiment("hp_bar2"), true, nil, false, 143, 20, cc.rect(15,2,14,6))
		prog2:setLocalZOrder(999)
		prog2:setScaleX(-1)
		self.node_t_list.layout_role_2.node:addChild(prog2)
		self.progressbar2 = ProgressBar.New()
		self.progressbar2:SetView(prog2)
	end
	self.progressbar1:SetPercent(100)
	self.progressbar2:SetPercent(100)

	-- 人物动画
	if nil == self.role_1 or nil == self.role_2 then
		self.role_1 = self:CreateRole(role1_info)
		local ph = self.ph_list.ph_action
		self.role_1.SetPosition(ph.x, ph.y)

		self.data.role_info.dir = GameMath.DirLeft
		self.role_2 = self:CreateRole(role2_info)
		local ph2 = self.ph_list.ph_action2
		self.role_2.SetPosition(ph2.x, ph2.y)
	end
	self.role_1.PlayAct("stand")
	self.role_2.PlayAct("stand")
end




---------------------------------
-- 外部调用 

-- 刷新pk状态
function SceneModal:SetData(data)
	self.data = data
end

function SceneModal:IsInPk()
	return self.is_in_pk
end




--------------------------------
-- 场景切换处理

--场景中有对象生成
function SceneModal:OnObjCreate(obj)
	local obj_id = obj:GetObjId()
	-- 大剧情中隐藏不属于剧情的场景对象形象
	GlobalTimerQuest:AddDelayTimer(function()
		local obj = Scene.Instance:GetObjectByObjId(obj_id)
		if nil ~= obj then
			obj:GetModel():SetAllVisible(false)
		end
	end, 0)
end

function SceneModal:SetOtherSceneObjsVisible(value)
	for k,v in pairs(Scene.Instance.obj_list) do
		v:GetModel():SetAllVisible(value)
		if value and v.UpdateShow then
			v:UpdateShow()
		end
	end
	Scene.Instance:GetMainRole():GetModel():SetAllVisible(value)

	if value then
		Scene.Instance:RefreshPingBiRole()
	end
end

function SceneModal:SetOtherOpenViewVisible(value)
	if value then
		ViewManager.Instance:OpenViewByDef(ViewDef.MainUi)
	else
		ViewManager.Instance:CloseAllView()
		ViewManager.Instance:CloseViewByDef(ViewDef.MainUi)
	end
end

