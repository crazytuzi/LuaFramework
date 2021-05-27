GuideData = GuideData or BaseClass()

-- 功能引导触发类型
FuncGuideTriggerType = {
	AddTask = 1,			-- 接任务
	CompleteTask = 2,		-- 完成任务
	FinishTask = 3,			-- 交任务
	UpLevel = 4,			-- 升级
	EnterScene = 5,			-- 进入场景
	Born = 6,				-- 开场
	StoryEnd = 7,			-- 剧情结束
}

FuncGuideType = {
	OnClick = 1,			-- 点击
	TouchMove = 2,			-- 触摸移动
}

StoryType = {
	Large = 1,			-- 大剧情，会屏蔽大量非剧情内容
	Samll = 2,			-- 小剧情，不影响玩家的正常游戏操作
}

ActorId = {
	MainRole = 999,
}

--剧情动作。
--所有动作支持分职业配置，如<frof1>来吧</prof1><frof2>打怪吧</prof2>
ActorAction = {
	--人物出生			参数：（x##y##血量##速度##职业##方向##武器##翅膀进化##翅膀特殊##坐骑）							
	--怪物出生 			参数：（x##y##配置id##血量##方向）
	--精灵出生			参数:  (x##y##配置id##方向)
	--特效出生			参数：（x##y##配置id##循环次数##播放频率##scale）
	--插画出生 			参数：（x##y##插画路径##缩放##rect.x##rect.y##rect.w##rect.h）注：区域从左上角开始
	--幕布出生 			参数： (x##y##宽##高##透明度)
	--字幕出生 			参数:  (x##y##宽##高##对齐方式) 注：文字支持html格式 ，对齐方式为left, center, right
 	Born = "born",

	Dialog = "dialog", 								--对话 							参数：对话内容
	Appear = "appear",								--出现 							参数：出现类型(1直接出现,2淡入)#特效id#淡入时间（秒）
	Disappear = "disappear",						--消失 							参数：消失类型(1直接消失,2淡出)#特效id#淡出时间（秒）
	Move = "move",									--移动 							参数：x#y#速度或时间
	MoveBack = "moveback",							--移动回去 						参数：无
	Fly = "fly",									--直接飞到某地					参数：x#y
	FlyBack = "flyback",							--飞回原地						参数：x#y
	DoNothing = "donothing",						--不做任何事					参数：无
	DoAttack = "do_attack",							--打人							参数：scale#time
	ChangeObjAttr = "change_obj_attr",				--死亡							参数：scale#time
	Shake = "shake",								--特效震动 						参数：震级(1,2,3)
	CreateScene = "create_scene",					--创建虚拟场景      			参数：场景id
	ServerStartPlay = "req_server_start_play",		--请求服务端开始表演
	RunAction = "run_action",						--动作							参数：scale#time
	AutoFight = "auto_fight",						--主角自动战斗

	-- ChangeBlood = "change_blood",					--改变血量（模防战斗包） 		参数：受伤者actor_id#攻击者id#技能id#fighttype#伤害者
 	-- CloneMainRole = "clone_mainrole",				--克隆主角						参数：无 			
 	-- ChangeAppearance = "change_appearance",			--外观改变						参数：武器#翅膀#坐骑					
	-- Talk = "talk",									--说话 							参数：说话内容
	-- ResetPos = "reset_pos",							--重置位置（人物等模防战斗包）  参数：重置方式##x##y （重置方式有：1.击退或冲锋，2.直接设置位置）
	-- Gathering = "gathering",							--特效采集中					参数：采集时间
	-- TurnRound = "turn_round", 						--转向							参数：方向(0,1,2,3 分别代表up,right,down,left)
	-- Flying = "flying",		 						--飞行 							参数：过程（"up"或"down")				
}

ActorType = {
	MainRole = "main_role",							--主角
	CloneMainRole = "clone_main_role",				--克隆主角
	Role = "role",									--角色
	Monster = "monster",							--怪物
	Npc = "npc",									--NPC
	Camera = "camera",								--摄象机
	Effect = "effect",								--特效(广义上，相当于系统)
	Curtain = "curtain",							--幕布
	Patting = "patting",							--插画
	FallItem = "fall_item",							--掉落物品
	Subtitle = "subtitle",							--字幕
	-- Mount = "mount",								--坐骑
	-- Combat = "combat",								--战斗
	-- Gather = "gather",								--采集物
}

function GuideData:__init()
	if GuideData.Instance ~= nil then
		ErrorLog("[GuideData] attempt to create singleton twice!")
		return
	end
	GuideData.Instance = self

	self.guide_cfg = {}
	self:InitGuideCfg()

	self:InitForeshow()
end

function GuideData:__delete()
end

function GuideData:InitGuideCfg()
	local guide_cfg = ConfigManager.Instance:GetClientConfig("FunctionGuide")
	for k, v in pairs(guide_cfg) do
		self.guide_cfg[v.id] = v
	end
end

function GuideData:GetGuideCfg()
	return self.guide_cfg
end

function GuideData:GetGuideCfgById(guide_id)
	return self.guide_cfg[guide_id]
end

-- 增加一个预告对象到队列
-- foreshow_id 对象标识
-- base_view 预告基础视图信息  {eff_res_id:显示特效id不能为nil, auto_click==true:达到判断条件自动触发点击方法}
-- click_func 预告基础视图点击方法
-- rec_condition 是否可领取判断方法 bool
-- complete_condition 对象是否完成判断方法 bool
-- foreshow_view_param 其它参数
-- init_func, delete_func, update_func 预告基础view 初始方法 清除方法 更新方法 
function GuideData:CreateForeshowObj(foreshow_id, base_view, click_func, rec_condition, complete_condition, foreshow_view_param, init_func, delete_func, update_func)
	if complete_condition and complete_condition() then	-- 不增加已完成的对象
		return
	end

	table.insert(self.foreshow_client_list, 1, 
	{
		foreshow_id = foreshow_id,
		base_view = base_view,
		foreshow_view_param = foreshow_view_param,
		click_func = click_func,
		rec_condition = rec_condition,
		complete_condition = complete_condition,
		init = init_func or self.ForeshowBaseViewInit,
		delete = delete_func or self.ForeshowBaseViewDelete,
		update = update_func or self.ForeshowBaseViewUpdate,
	})
end

-- 预告基础view 通用初始方法
function GuideData.ForeshowBaseViewInit(obj)
	if nil == obj.base_view.node then
		obj.base_view.node = GuideCtrl.Instance:GetForeshowBaseView()
	end
	obj.base_view.node:Open()
	obj.base_view.node:FlyToScene()
	obj.base_view.rec_state = obj.rec_condition()
end

-- 预告基础view 通用更新方法
function GuideData.ForeshowBaseViewUpdate(obj)
	if true == obj.complete_condition() then
		GuideData.Instance.cur_foreshow_obj = nil
		obj:delete()
		return
	end

	if not obj.base_view.node:IsOpen() then
		obj:init()
	end

	local rec_cond = obj.rec_condition()
	if obj.base_view.rec_state ~= rec_cond then
		obj.base_view.node:Flush()
		if rec_cond and obj.base_view.auto_click and obj.click_func then
			-- 达到要求自动弹出
			obj.base_view.node:EffectFlyToCenter()
		end
		obj.base_view.rec_state = rec_cond
	end
end

-- 预告基础view 通用销毁方法
function GuideData.ForeshowBaseViewDelete(obj)
	-- 在场景中显示装逼的文字，一段时间后消失
	if nil ~= obj.foreshow_view_param and nil ~= obj.foreshow_view_param.desc_img_path then
		local hx, hy = HandleRenderUnit:GetWidth(), HandleRenderUnit:GetHeight()
		local img_path = ResPath.GetScene("foreshow_" .. obj.foreshow_view_param.desc_img_path)
		local text_img = XUI.CreateImageView(hx / 2 - 25, 216, img_path, true)
		-- HandleRenderUnit:AddUi(text_img, 0)
		text_img:setOpacity(0)
		text_img:setScale(4)
		local node_grid = cc.NodeGrid:create()
		HandleRenderUnit:AddUi(node_grid, 0)
		node_grid:addChild(text_img)

		local show_in_time = 0.7
		local spawn = cc.Spawn:create(cc.EaseExponentialIn:create(cc.ScaleTo:create(show_in_time, 1)), cc.FadeIn:create(show_in_time / 2))
		-- local call_func = cc.CallFunc:create(function() node_grid:runAction(cc.Shaky3D:create(3, cc.size(15, 10), 4, true)) end)
		local call_func = cc.CallFunc:create(function() CommonAction.ShowShakeAction(text_img) end)
		local sequence = cc.Sequence:create(spawn, call_func)
		text_img:runAction(sequence)

		GlobalTimerQuest:AddDelayTimer(
			function()
				local sequence = cc.Sequence:create(
					cc.FadeOut:create(0.8),
					cc.CallFunc:create(function()
						if nil ~= node_grid then
							node_grid:removeFromParent()
							node_grid = nil
						end
					end)
				)
				text_img:runAction(sequence)
			end,
			5
		)
	end

	obj.base_view.node:Close()
	obj = nil
end

function GuideData:InitForeshow()
	self.foreshow_start_level = 5
	self.foreshow_client_list = {}

	self.equip_data_init = false
	self.title_data_init = false
	GlobalEventSystem:Bind(MainRoleDataInitEventType.TITLE_DATA, BindTool.Bind(self.OnMainRoleTitleDataInit, self))
	GlobalEventSystem:Bind(MainRoleDataInitEventType.EQUIP_DATA, BindTool.Bind(self.OnMainRoleEquipDataInit, self))
end

function GuideData:OnMainRoleEquipDataInit()
	self.equip_data_init = true
end

function GuideData:OnMainRoleTitleDataInit()
	self.title_data_init = true
end

function GuideData:IsAllMainRoleDataInit()
	return self.equip_data_init and self.title_data_init
end

function GuideData:GetCurForeshowObj()
	if nil == self.cur_foreshow_obj then
		self.cur_foreshow_obj = table.remove(self.foreshow_client_list)
		if self.cur_foreshow_obj then
			if self.cur_foreshow_obj.init then
				self.cur_foreshow_obj:init()	-- 预告基础view初始化
			end
		end
	end
	return self.cur_foreshow_obj
end

function GuideData:InitForeshowList()
	-- GlobalTimerQuest:CancelQuest(self.foreshow_delay_timer)
	-- if not self:IsAllMainRoleDataInit() or SUPER_CHEST_STATE_ENUM.DATA_IS_DISABLE == OtherData.Instance:GetSuperChestState() then
	-- 	self.foreshow_delay_timer = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.InitForeshowList, self), 0.5)
	-- 	return
	-- end

	-- -- 达到5级开始功能预告
	-- local complete_condition = function() return 5 <= RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL) end
	-- local temp_func = function() end
	-- local update_func = function(obj)
	-- 	if obj.complete_condition() then
	-- 		GuideData.Instance.cur_foreshow_obj = nil
	-- 	end
	-- end
	-- self:CreateForeshowObj(0, nil, nil, nil, complete_condition, nil, temp_func, temp_func, update_func)

	-- -- 称号
	-- local rec_condition = function() return 10 <= RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL) end
	-- local complete_condition = function() return 1 == TitleData.Instance:GetTitleActive(27) end
	-- local click_func = function() GuideCtrl.Instance:OpenForeshowView() end
	-- local btn_func = function(view_node)
	-- 	if rec_condition() and not complete_condition() then
	-- 		local act_item = BagData.Instance:GetOneItem(1733)
	-- 		if act_item then
	-- 			BagCtrl.Instance:SendUseItem(act_item.series, 0, 1)
	-- 		end
	-- 	end
	-- 	view_node:Close()
	-- end
	-- local base_view = {eff_res_id = 337, level = 10, auto_click = true}
	-- local foreshow_view_param = {desc_img_path = "desc2", btn_func = btn_func}
	-- self:CreateForeshowObj(1, base_view, click_func, rec_condition, complete_condition, foreshow_view_param)

	-- -- 玉佩
	-- local rec_condition = function() return 30 <= RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL) end
	-- local complete_condition = function() return nil ~= EquipData.Instance:GetGridData(EquipData.EquipIndex.Meterial) end
	-- local click_func = function() GuideCtrl.Instance:OpenForeshowView() end
	-- local base_view = {eff_res_id = 1101, level = 30, auto_click = true}
	-- local btn_func = function(view_node)
	-- 	if rec_condition() and not complete_condition() then
	-- 		ComposeCtrl.Instance:SendForgingEquipReq(ComposeData.SHENQI_TYPE.YP)
	-- 	end
	-- 	view_node:Close()
	-- end
	-- local foreshow_view_param = {desc_img_path = "desc1", btn_func = btn_func}
	-- self:CreateForeshowObj(2, base_view, click_func, rec_condition, complete_condition, foreshow_view_param)

	-- -- 翅膀
	-- local rec_condition = function() return 40 <= RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL) end
	-- local complete_condition = function() return 0 < RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SWING_ID) end
	-- local click_func = function() GuideCtrl.Instance:OpenForeshowView() end
	-- local base_view = {eff_res_id = 1103, level = 40, auto_click = true}
	-- local btn_func = function(view_node)
	-- 	if rec_condition() and not complete_condition() then
	-- 		WingCtrl.SendWingActReq()
	-- 	end
	-- 	view_node:Close()
	-- end
	-- local foreshow_view_param = {desc_img_path = "desc4", btn_func = btn_func}
	-- self:CreateForeshowObj(3, base_view, click_func, rec_condition, complete_condition, foreshow_view_param)

	-- -- 护盾
	-- local rec_condition = function() return 46 <= RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL) end
	-- local complete_condition = function() return nil ~= EquipData.Instance:GetGridData(EquipData.EquipIndex.Shield) end
	-- local click_func = function() GuideCtrl.Instance:OpenForeshowView() end
	-- local base_view = {eff_res_id = 1104, level = 46, auto_click = true}
	-- local btn_func = function(view_node)
	-- 	if rec_condition() and not complete_condition() then
	-- 		ComposeCtrl.Instance:SendForgingEquipReq(ComposeData.SHENQI_TYPE.HD)
	-- 	end
	-- 	view_node:Close()
	-- end
	-- local foreshow_view_param = {desc_img_path = "desc5", btn_func = btn_func}
	-- self:CreateForeshowObj(4, base_view, click_func, rec_condition, complete_condition, foreshow_view_param)

	-- -- 超级宝箱
	-- local rec_condition = function() return 50 <= RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL) end
	-- local complete_condition = function() return SUPER_CHEST_STATE_ENUM.ALREADY_REC == OtherData.Instance:GetSuperChestState() end
	-- local click_func = function() GuideCtrl.Instance:OpenForeshowView() end
	-- local base_view = {eff_res_id = 1225, level = 50, auto_click = true}
	-- local btn_func = function(view_node)
	-- 	if rec_condition() and not complete_condition() then
	-- 		ProtocolPool.Instance:GetProtocol(CSRecSuperChest):EncodeAndSend()
	-- 	end
	-- 	view_node:Close()
	-- end
	-- local foreshow_view_param = {desc_img_path = "desc12", btn_func = btn_func}
	-- self:CreateForeshowObj(2, base_view, click_func, rec_condition, complete_condition, foreshow_view_param)

	-- -- 官印
	-- local rec_condition = function() return 56 <= RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL) end
	-- local complete_condition = function() return 0 < OfficeData.Instance:GetOfficeSealLevel() end
	-- local click_func = function() GuideCtrl.Instance:OpenForeshowView() end
	-- local base_view = {eff_res_id = 1105, level = 56, auto_click = true}
	-- local btn_func = function(view_node)
	-- 	if rec_condition() and not complete_condition() then
	--         OfficeCtrl.SendOfficeSealRea()
	-- 	end
	-- 	view_node:Close()
	-- end
	-- local foreshow_view_param = {desc_img_path = "desc6", btn_func = btn_func}
	-- self:CreateForeshowObj(5, base_view, click_func, rec_condition, complete_condition, foreshow_view_param)

	-- -- 成就
	-- local rec_condition = function() return 60 <= RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL) end
	-- local complete_condition = function() return nil ~= EquipData.Instance:GetGridData(EquipData.EquipIndex.Decoration) end
	-- local click_func = function() GuideCtrl.Instance:OpenForeshowView() end
	-- local base_view = {eff_res_id = 1106, level = 60, auto_click = true}
	-- local btn_func = function(view_node)
	-- 	if rec_condition() and not complete_condition() then
	-- 		ComposeCtrl.Instance:SendForgingEquipReq(ComposeData.SHENQI_TYPE.XZ)
	-- 	end
	-- 	view_node:Close()
	-- end
	-- local foreshow_view_param = {desc_img_path = "desc11", btn_func = btn_func}
	-- self:CreateForeshowObj(6, base_view, click_func, rec_condition, complete_condition, foreshow_view_param)

	-- -- 宝石
	-- local rec_condition = function() return 63 <= RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL) end
	-- local complete_condition = function() return nil ~= EquipData.Instance:GetGridData(EquipData.EquipIndex.EquipDiamond) end
	-- local click_func = function() GuideCtrl.Instance:OpenForeshowView() end
	-- local base_view = {eff_res_id = 1107, level = 63, auto_click = true}
	-- local btn_func = function(view_node)
	-- 	if rec_condition() and not complete_condition() then
	-- 		ComposeCtrl.Instance:SendForgingEquipReq(ComposeData.SHENQI_TYPE.BS)
	-- 	end
	-- 	view_node:Close()
	-- end
	-- local foreshow_view_param = {desc_img_path = "desc7", btn_func = btn_func}
	-- self:CreateForeshowObj(7, base_view, click_func, rec_condition, complete_condition, foreshow_view_param)

	-- -- 魂珠
	-- local rec_condition = function() return 70 <= RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL) end
	-- local complete_condition = function() return nil ~= EquipData.Instance:GetGridData(EquipData.EquipIndex.Seal) end
	-- local click_func = function() GuideCtrl.Instance:OpenForeshowView() end
	-- local base_view = {eff_res_id = 1109, level = 70, auto_click = true}
	-- local btn_func = function(view_node)
	-- 	if rec_condition() and not complete_condition() then
	-- 		ComposeCtrl.Instance:SendForgingEquipReq(ComposeData.SHENQI_TYPE.SZ)
	-- 	end
	-- 	view_node:Close()
	-- end
	-- local foreshow_view_param = {desc_img_path = "desc9", btn_func = btn_func}
	-- self:CreateForeshowObj(8, base_view, click_func, rec_condition, complete_condition, foreshow_view_param)

	-- -- 斗笠
	-- local rec_condition = function() return 75 <= RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL) end
	-- local complete_condition = function() return nil ~= EquipData.Instance:GetGridData(EquipData.EquipIndex.HatsPos) end
	-- local click_func = function() GuideCtrl.Instance:OpenForeshowView() end
	-- local base_view = {eff_res_id = 1110, level = 75, auto_click = true}
	-- local btn_func = function(view_node)
	-- 	if rec_condition() and not complete_condition() then
	-- 		ComposeCtrl.Instance:SendForgingEquipReq(ComposeData.SHENQI_TYPE.DouLi)
	-- 	end
	-- 	view_node:Close()
	-- end
	-- local foreshow_view_param = {desc_img_path = "desc10", btn_func = btn_func}
	-- self:CreateForeshowObj(9, base_view, click_func, rec_condition, complete_condition, foreshow_view_param)

	-- -- 登陆奖励预告
	-- local login_reward_list = {
	-- 	1111,
	-- 	1112,
	-- 	1113,
	-- 	1114,
	-- 	1115,
	-- 	1116,
	-- 	1117,
	-- 	1118,
	-- 	1119,
	-- 	1120,
	-- 	1113,
	-- 	1114,
	-- 	1115,
	-- 	1116,
	-- 	1121,
	-- }
	-- for days, eff_res_id in pairs(login_reward_list) do
	-- 	local rec_condition = function() return days <= LoginRewardData.Instance:GetAddLoginTimes() end
	-- 	local complete_condition = function() return 2 == LoginRewardData.Instance:GetLoginRewardFlag(days) end
	-- 	local click_func = function() ViewManager.Instance:Open(ViewName.LoginReward, days) end
	-- 	local base_view = {eff_res_id = eff_res_id, login_days = days}
	-- 	self:CreateForeshowObj(10, base_view, click_func, rec_condition, complete_condition)
	-- end
	
	-- -- 特权卡
	-- local rec_condition = function() return true end
	-- local complete_condition = function() return false end
	-- local click_func = function() ViewManager.Instance:Open(ViewName.PrivilegeView) end
	-- local base_view = {eff_res_id = 889, level = 0, auto_click = true, eff_scale = 1.2, foreshow_text_vis = false, foreshow_bg_vis = false}
	-- local btn_func = function(view_node)
	-- 	if rec_condition() and not complete_condition() then
	-- 		ComposeCtrl.Instance:SendForgingEquipReq(ComposeData.SHENQI_TYPE.DouLi)
	-- 	end
	-- 	view_node:Close()
	-- end
	-- local foreshow_view_param = {desc_img_path = "", btn_func = btn_func}
	-- local init_func = function (obj)
	-- 	GuideData.ForeshowBaseViewInit(obj)

	-- 	GlobalEventSystem:Fire(MainUIEventType.PRIVILEGE_VIEW_SHOW_IN_FORESHOW)

	-- 	local function showRemind(show)
	-- 		if show then
	-- 			if nil == obj.base_view.remind_img then
	-- 				local remind_img = XUI.CreateImageView(25, 20, ResPath.GetMainui("remind_flag"), true)
	-- 				obj.base_view.node:GetRootNode():addChild(remind_img, 30)
	-- 				obj.base_view.remind_img = remind_img
	-- 			else
	-- 				obj.base_view.remind_img:setVisible(true)
	-- 			end
	-- 		else
	-- 			if nil ~= obj.base_view.remind_img then
	-- 				obj.base_view.remind_img:setVisible(false)
	-- 			end
	-- 		end
	-- 	end

	-- 	showRemind(RemindManager.Instance:GetRemindGroup(RemindGroupName.PrivilegeView) > 0)

	-- 	GlobalEventSystem:Bind(OtherEventType.REMINDGROUP_CAHANGE, function (group_name, num)
	-- 		if group_name == RemindGroupName.PrivilegeView then
	-- 			showRemind(num > 0)
	-- 		end
	-- 	end)

	-- end
	-- if not IS_AUDIT_VERSION then
	-- 	self:CreateForeshowObj(999, base_view, click_func, rec_condition, complete_condition, foreshow_view_param, init_func)
	-- end
end
