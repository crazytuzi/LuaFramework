require("scripts/game/guide/story")
require("scripts/game/guide/story_modal")
require("scripts/game/guide/story_dialog")
require("scripts/game/guide/guide_data")
require("scripts/game/guide/guide_view")
require("scripts/game/guide/key_equip_view")
require("scripts/game/guide/welcome_view")
require("scripts/game/guide/foreshow_base_view")
require("scripts/game/guide/foreshow_view")
require("scripts/game/guide/get_skill_remind_view")
require("scripts/game/guide/get_brand_remind_view")
require("scripts/game/guide/bisha_preview_view")
require("scripts/game/guide/bisha_rec_view")

-- 引导 功能预告
GuideCtrl = GuideCtrl or BaseClass(BaseController)
GuideCtrl.TaskGuideLevel = 75		-- 任务引导等级(自动继续下一步)
GuideCtrl.AutoTaskLevel = 70		-- 自动任务等级(站着不动会自动做任务)
GuideCtrl.ClearingEnd = "clearingend"

function GuideCtrl:__init()
	if GuideCtrl.Instance ~= nil then
		ErrorLog("[GuideCtrl] attempt to create singleton twice!")
		return
	end
	GuideCtrl.Instance = self

	self.bisha_preview_view = BiShaPreviewView.New(ViewDef.BiShaPreview)
	self.bisha_rec_view = BiShaRecView.New(ViewDef.BiShaRecView)
	self.story = Story.New()
	self.guide_data = GuideData.New()
	self.guide_view = GuideView.New()
	self.key_equip_view = KeyEquipView.New()
	self.welcome_view = WelcomeView.New()

	self.is_auto_task = true
	self.last_task_update_time = 0

	self.guide_id = 0
	self.guide_index = 0
	self.guide_type = FuncGuideType.OnClick
	self.step_list = {}
	self.is_next = true
	self.is_guideing = false				-- 是否引导中
	self.first_nil_time = 0

	self.key_equip_view_open = false
	self.new_equip_cfg = {}
	self.new_item_cfg = {}
	self.clean_up_use_item_list = {}
	self.get_use_item_list = {}

	self.is_welcome_guided = false

	self.delay_auto_do_task_timer = nil

	GlobalEventSystem:Bind(LoginEventType.LOADING_COMPLETED, BindTool.Bind(self.OnLoginCompleted, self))
	RoleData.Instance:AddEventListener(OBJ_ATTR.CREATURE_LEVEL, BindTool.Bind(self.OnRoleLevelChange, self))
	BagData.Instance:AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.OnItemChange, self))
	--EquipData.Instance:AddEventListener(EquipData.CHANGE_ONE_EQUIP, BindTool.Bind(self.OnChangeOneEquip, self))

	self.task_event_proxy = EventProxy.New(TaskData.Instance)
	self.task_event_proxy:AddEventListener(TaskData.ADD_ONE_TASK, BindTool.Bind(self.OnAddOneTask, self))
	self.task_event_proxy:AddEventListener(TaskData.FINISH_ONE_TASK, BindTool.Bind(self.OnFinishOneTask, self))
	self.task_event_proxy:AddEventListener(TaskData.TASK_VALUE_CHANGE, BindTool.Bind(self.OnTaskValueChange, self))
	self.task_event_proxy:AddEventListener(TaskData.ON_TASK_LIST, BindTool.Bind(self.OnTaskList, self))

	self:RegisterAllProtocols()
end

function GuideCtrl:__delete()
	GuideCtrl.Instance = nil

	self.bisha_preview_view:DeleteMe()
	self.bisha_rec_view:DeleteMe()
	self.story:DeleteMe()
	self.guide_view:DeleteMe()
	self.key_equip_view:DeleteMe()
	self.welcome_view:DeleteMe()

	self.task_event_proxy:DeleteMe()

	if self.foreshow_view then
		self.foreshow_view:DeleteMe()
		self.foreshow_view = nil
	end

	if self.foreshow_base_view then
		self.foreshow_base_view:DeleteMe()
		self.foreshow_base_view = nil
	end

	if self.get_skill_remind_view then
		self.get_skill_remind_view:DeleteMe()
		self.get_skill_remind_view = nil
	end

	if self.get_brand_remind_view then
		self.get_brand_remind_view:DeleteMe()
		self.get_brand_remind_view = nil
	end

	Runner.Instance:RemoveRunObj(self)
end

function GuideCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCOpenOnHookGuide, "OnOpenOnHookGuide")
end

function GuideCtrl:OnOpenOnHookGuide(protocol)
	if protocol.on_hook_type == 1 then
		-- ViewManager.Instance:FlushView(ViewDef.MainUi, 0, "act_skillbar_auto_fight_effect")
	else
		if GuajiCache.guaji_type ~= GuajiType.Auto and Scene.Instance:GetMainRole() then
			Scene.Instance:GetMainRole():StopMove()
			GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
		end
	end
end

function GuideCtrl:Update(now_time, elapse_time)
	if Story.Instance:GetIsStoring() then
		return
	end

	if self.welcome_view:IsOpen() then
		return
	elseif not self.is_welcome_guided then
		self.is_welcome_guided = true
		if RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL) == 1 then
			self.welcome_view:SetClickCallBack(BindTool.Bind(self.AutoTaskNow, self))
			self.welcome_view:Open()
			Scene.Instance:GetMainRole():StopMove()
			return
		end
	end

	if self.is_guideing then
		self:OnGuide()
	end

	if self.is_auto_task then
		self:OnAutoTask(now_time, elapse_time)
	end

	self:UpdateForeshow()
end

function GuideCtrl:StartGuide(guide_id)
	local guide_cfg = self.guide_data:GetGuideCfgById(guide_id)
	if self.guide_id == guide_id or nil == guide_cfg then
		return
	end

	ViewManager.Instance:CloseAllView()
	self.step_list = guide_cfg.step_list
	self.guide_id = guide_id
	self.is_guideing = true
	self.guide_index = 0

	self:NextGuide()
end

function GuideCtrl:NextGuide()
	self.guide_index = self.guide_index + 1
	self.first_nil_time = Status.NowTime
	if nil == self.step_list[self.guide_index] then
		self:EndGuide()
	else
	end
end

function GuideCtrl:EndGuide()
	self.guide_id = 0
	self.is_guideing = false
	self.guide_view:Close()
end

function GuideCtrl:IsFuncGuideing()
	if self.is_guideing then
		if nil ~= self.step_list[self.guide_index] then
			return true
		end
	end

	return false
end

function GuideCtrl:OnGuide()
	if GuideCtrl.CanSkipNextStep(self.step_list[self.guide_index - 1]) then
		self:NextGuide()
		return 
	end
	local step_cfg = self.step_list[self.guide_index]
	self.guide_type = step_cfg.guide_type or FuncGuideType.OnClick
	local size = cc.size(0, 0)
	local pos = cc.p(0, 0)
	if self.guide_type == FuncGuideType.OnClick then
		local node, is_next = ViewManager.Instance:GetUiNode(step_cfg.view_name, 
			step_cfg.node_name)
		if nil == node or (node.isFamilyVisible and not node:isFamilyVisible()) then
			if 0 == self.first_nil_time then
				self.first_nil_time = Status.NowTime
			end
			if Status.NowTime - self.first_nil_time >= 2 then
				self.first_nil_time = 0
				self:EndGuide()
			end
			return
		end

		self.is_next = (nil == is_next) or is_next
		self.first_nil_time = 0


		local node_size = node:getContentSize()
		local pos1 = node:convertToWorldSpace(cc.p(0, 0))
		local pos2 = node:convertToWorldSpace(cc.p(node_size.width, node_size.height))
		local pos3 = node:convertToWorldSpace(cc.p(node_size.width, 0))
		local pos4 = node:convertToWorldSpace(cc.p(0, node_size.height))

		if step_cfg.pos then
			-- 以高为标准 所以需要计算x的拉伸比例
			-- 配置中的坐标为屏幕左下角与点击坐标的距离 x轴拉伸后需计算出x轴的拉伸坐标
			-- (design_width + scale_x) / design_height = frame_size.width / frame_size.height

			-- 设计分辨率
			local design_height = 768
			local design_width = 1380
			
			-- 实际屏幕大小（已拉伸）
			local frame_size = cc.Director:getInstance():getOpenGLView():getFrameSize()

			-- 拉伸距离
			local scale_x = frame_size.width / frame_size.height * design_height - design_width

			local x = (step_cfg.pos.x - 50) + scale_x / 2
			local cfg_pos = cc.p(x, step_cfg.pos.y - 50)

			pos1 = cc.p(cfg_pos.x, cfg_pos.y)
			pos2 = cc.p(cfg_pos.x + 80, cfg_pos.y + 80)
			pos3 = cc.p(cfg_pos.x + 80, cfg_pos.y)
			pos4 = cc.p(cfg_pos.x, cfg_pos.y + 80)
		end

		-- 取得节点内容各个点的世界坐标后生成新的rect
		local min_x = math.min(pos1.x, pos2.x, pos3.x, pos4.x)
		local min_y = math.min(pos1.y, pos2.y, pos3.y, pos4.y)
		local max_x = math.max(pos1.x, pos2.x, pos3.x, pos4.x)
		local max_y = math.max(pos1.y, pos2.y, pos3.y, pos4.y)
		pos = cc.p(min_x, min_y)
		size = cc.size(max_x - min_x, max_y - min_y)
	elseif self.guide_type == FuncGuideType.TouchMove then
		self.is_next = true
		local screen_w, screen_h = HandleRenderUnit:GetWidth(), HandleRenderUnit:GetHeight()
		pos.x = step_cfg.rect.x + screen_w / 2 - step_cfg.rect.w / 2
		pos.y = step_cfg.rect.y + screen_h / 2 - step_cfg.rect.h / 2
		size.width = step_cfg.rect.w
		size.height = step_cfg.rect.h

		if Status.NowTime - self.first_nil_time >= 60 then
			self.first_nil_time = 0
			self:EndGuide()
			return
		end
	end

	self.guide_view:Open(step_cfg)
	self.guide_view:SetCenterRect(pos.x, pos.y, size.width, size.height)
end

function GuideCtrl:OnGuideTouch(move_distance)
	if self.guide_type ~= FuncGuideType.TouchMove then
		return
	end

	local step_cfg = self.step_list[self.guide_index]
	if nil == step_cfg then
		return
	end

	local move_xy = self.step_list[self.guide_index].move_xy
	local node, is_next = ViewManager.Instance:GetUiNode(step_cfg.view_name, step_cfg.node_name)
	if node and move_xy then
		node:scrollToPositionY(- move_xy.y, 0.5, true)
		self:NextGuide()
	end
end

function GuideCtrl:OnClick()
	if self.guide_type ~= FuncGuideType.OnClick then
		return
	end

	if self.is_next then
		self:NextGuide()
	else
		ViewManager.Instance:CloseAllView()
	end
end

function GuideCtrl.CanSkipNextStep(cfg)
	if nil == cfg then
		return false
	end

	return false
end

---------------------------------------------------------------------------------

function GuideCtrl:OnLoginCompleted()
	self:UpdateAutoTaskFlag()

	self.last_task_update_time = Status.NowTime
	Runner.Instance:AddRunObj(self, 4)

	self.guide_data:InitForeshowList()
end

function GuideCtrl:IsAutoTask()
	return self.is_auto_task
end

function GuideCtrl:SetForceStopTask(value)
	self.is_un_auto_task = value
	self:UpdateAutoTaskFlag()
end

function GuideCtrl:UpdateAutoTaskFlag()
	self.is_auto_task = not self.is_un_auto_task and RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL) < AutoDoTaskLv
end

function GuideCtrl:OnRoleLevelChange(vo)
	self:UpdateAutoTaskFlag()
end

-- 功能引导
function GuideCtrl:CheckFuncGuide(trigger_type, task_info)
	if nil == task_info then
		return
	end

	if trigger_type > 0 then
		for k, v in pairs(GuideData.Instance:GetGuideCfg()) do
			if v.trigger_type == trigger_type and v.trigger_param == task_info.task_id then
				self:StartGuide(v.id)
				break
			end
		end
	end
end

---------------------------------------------------------------------------------
-- 自动任务 begin
---------------------------------------------------------------------------------
function GuideCtrl:OnTaskValueChange(task_id)
	self:AutoTaskNow()
	if TaskState.Complete == TaskData.Instance:GetTaskStateById(task_id) then
		-- 任务目标完成后,停止自动做任务的动作
		if MoveCache.task_id == task_id then
			GuajiCtrl.Instance:ClearAllOperate()
		end
	end
end

function GuideCtrl:OnTaskList()
	local main_task = TaskData.Instance:GetMainTaskInfo()
	self:CheckFuncGuide(FuncGuideTriggerType.AddTask, main_task)
end

function GuideCtrl:OnAddOneTask(task_info)
	self:AutoTaskNow()

	if task_info then
		-- 显示接受任务特效
		GlobalTimerQuest:AddDelayTimer(function()
			local node = HandleRenderUnit:GetUiNode()
			local ui_size = HandleRenderUnit:GetSize()
			if nil ~= node then
				HandleRenderUnit.PlayEffectOnce(311, node, COMMON_CONSTS.ZORDER_SYSTEM_EFFECT, ui_size.width - 270, ui_size.height - 235, true)
			end
		end, 0.5)
	end

	self:CheckFuncGuide(FuncGuideTriggerType.AddTask, task_info)
end

function GuideCtrl:OnFinishOneTask(task_info)
	self:AutoTaskNow()
end

function GuideCtrl:AutoTaskNow()
	self.last_task_update_time = self.last_task_update_time - 999
end

function GuideCtrl:OnAutoTask(now_time, elapse_time)
	if now_time >= self.last_task_update_time + AutoDoTaskTimeSpace then
		self.last_task_update_time = now_time
			
		local task_info = TaskData.Instance:GetMainTaskInfo()
		if not self:CanAutoTask(task_info) then
			return
		end
		MainuiTask.HandleTask(task_info, {ignore_view_link = true, ignore_submit_task = true})
	end
end

-- 是否可以自动做任务
function GuideCtrl:CanAutoTask(task_info)
	if nil == task_info then
		return false
	end

	if nil ~= task_info.target then
		if task_info.target.target_type == TaskTarget.UpLevel then
			return false
		end
	end

	local main_role = Scene.Instance:GetMainRole()

	-- 当MoveCache.task_id == 0 时不是在自动做任务，是玩家正在操作
	if MoveCache.task_id == 0 and not main_role:IsStand() then
		return false
	end

	if self.guide_view:IsOpen() then
		return false
	end

	if ViewManager.Instance:IsOpen(ViewDef.NpcDialog) 
		or ViewManager.Instance:IsOpen(ViewDef.SpecialSpecialDialog)
		or ViewManager.Instance:IsOpen(ViewDef.TransmitNpcDialog) then
		return false
	end

	-- 正在攻击中
	if not main_role:IsAtkEnd(true) then
		self.last_task_update_time = Status.NowTime + 0.4 - 3
		return false
	end

	if Scene.Instance:CanPickFallItem() then
		return false
	end

	return true
end
---------------------------------------------------------------------------------
-- 自动任务 end
---------------------------------------------------------------------------------

------------------------------------------------------------------------
-- 一键穿装备begin
------------------------------------------------------------------------
local function sort_new_equip(a, b)
	local equip_a = BagData.Instance:GetOneItemBySeries(a.series)
	local equip_b = BagData.Instance:GetOneItemBySeries(b.series)
	return ItemData.Instance:GetItemScoreByData(equip_a) < ItemData.Instance:GetItemScoreByData(equip_b)
end

local function BetterEquip(list)
	local number = 1 --每种类型取五件
	local type_list ={}
	local new_list = {}
	local i = #list
	while i > 0 do
		local cfg = ItemData.Instance:GetItemConfig(list[i].item_id) 
		if not type_list[cfg.type] then
			type_list[cfg.type] = 1
		else
			type_list[cfg.type] = type_list[cfg.type] + 1
		end
		if(type_list[cfg.type] <= number) then
			table.insert(new_list,1,list[i])
		end
		i= i-1
	end
	return new_list
end

function GuideCtrl:OnItemChange(event)
	local index = 0
	self.new_item_cfg = {}
	if event.CheckAllItemDataByFunc then
		event.CheckAllItemDataByFunc(function (vo)
			if vo.change_type == ITEM_CHANGE_TYPE.ADD then
				local can_show = self:CheckCanEquipBySeries(vo.data.series)
				if vo.reason ~= ItemGetType.TakeOffItem
				and vo.reason ~= ItemGetType.GodEquipItem
				and (can_show == 1 or can_show == 2)
				then
					if not IS_ON_CROSSSERVER then
						table.insert(self.new_equip_cfg, {item_id = vo.data.item_id, series = vo.data.series})
					end
				else
					table.insert(self.new_item_cfg, {item_id = vo.data.item_id, series = vo.data.series})
				end
			end

			if vo.change_type == ITEM_CHANGE_TYPE.CHANGE then
				table.insert(self.new_item_cfg, {item_id = vo.data.item_id, series = vo.data.series})
			end
		end)

		self:GetItemOpenView()
		if not next(self.new_equip_cfg) then return end
		table.sort(self.new_equip_cfg, sort_new_equip) -- 排序
		self.new_equip_cfg = BetterEquip(self.new_equip_cfg) -- 每种类型只取1个
		self:OnChangeOneEquip()
	end
end

function GuideCtrl:OnChangeOneEquip()
	if not self.key_equip_view_open  then
		local item = table.remove(self.new_equip_cfg ,1)
		if nil~= item then
			local equip = BagData.Instance:GetOneItemBySeries(item.series)
			local can_show , eq_data = self:CheckCanEquipBySeries(item.series)
			self:OpenKeyEquipView(equip,eq_data)
		end
	end
	-- if not next(self.new_equip_cfg) then     --最后一个物品装备弹框消失后一秒再开始替换上最好的装备
	-- 	self.delay_cd = CountDown.Instance:AddCountDown(5, 5, BindTool.Bind(self.AutoEquip, self))
	-- end
end

function GuideCtrl:AutoEquip()
	-- EquipCtrl.Instance:AutoReplaceEquip()
	-- CountDown.Instance:RemoveCountDown(self.delay_cd)
end

-- 获得物品弹出面板
function GuideCtrl:GetItemOpenView()
	self.get_use_item_list = self.get_use_item_list or {}

	local bag_data = BagData.Instance:GetItemDataList() or {}

	for k, v in ipairs(self.new_item_cfg) do
		local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
		if ItemData.Instance:CanCleanUpAutoUse(v) and nil ~= item_cfg and not EquipData.CheckHasLimit(item_cfg) then
			local item = bag_data[v.series or 0]
			if item then
				table.insert(self.get_use_item_list, item)
			end
		end
	end

	local item = table.remove(self.get_use_item_list)
	while(item)
	do
		local item_data = bag_data[item.series or 0]
		if item_data then
			if not self.key_equip_view_open then
				self:OpenKeyEquipView(item)
			end
			break
		else
			item = table.remove(self.get_use_item_list)
		end
	end
	
end

-- 直接使用物品
function GuideCtrl:GetDirectUseItem(item)
	if nil == item then return end
	if self:IsNormalUseItem(item) then
		BagCtrl.Instance:SendUseItem(item.series, 0, item.num)
	end
end

-- 是否是普通的可直接使用的物品
function GuideCtrl:IsNormalUseItem(item_id)
	if item_id == nil then return false end
	local value = CleintItemShowCfg[1] and CleintItemShowCfg[1][item_id]
	return value ~= nil
end

function GuideCtrl:RemindItemUse()
	self.clean_up_use_item_list = self.clean_up_use_item_list or {}
	for k, v in pairs(BagData.Instance:GetItemDataList()) do
		local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
		if ItemData.Instance:CanCleanUpAutoUse(v) and nil ~= item_cfg and not EquipData.CheckHasLimit(item_cfg) then
			table.insert(self.clean_up_use_item_list, v)
		end

		local can_show = self:CheckCanEquipBySeries(v.series)
		if (can_show == 1 or can_show == 2) then
			if not IS_ON_CROSSSERVER then
				table.insert(self.new_equip_cfg, {item_id = v.item_id, series = v.series})
			end
		end
	end

	if next(self.new_equip_cfg) then
		table.sort(self.new_equip_cfg, sort_new_equip) -- 排序
		self.new_equip_cfg = BetterEquip(self.new_equip_cfg) -- 每种类型只取1个
	end

	self:UpdateRemindItemUse()
end

function GuideCtrl:UpdateRemindItemUse()
	if not self.key_equip_view_open  then
		local item = table.remove(self.clean_up_use_item_list)
		if nil ~= item then
			self:OpenKeyEquipView(item)
		else
			GlobalEventSystem:Fire(GuideCtrl.ClearingEnd)
		end
	end
end

function GuideCtrl:CheckCanEquipBySeries(series)  --只是检查是否需要打开面板
	local equip = BagData.Instance:GetOneItemBySeries(series)
	if nil == equip then return end
	local can_show, eq_data = self:CanShowKeyEquipView(equip)
	return can_show, eq_data
end

-- function GuideCtrl:CheckKeyEquipViewOpen(series)  --检查并打开面板
-- 	local equip = BagData.Instance:GetOneItemBySeries(series)
-- 	if nil == equip then return end
-- 	local can_show, eq_data = self:CanShowKeyEquipView(equip)
-- 	if can_show == 1 then
-- 		self:OpenKeyEquipView(equip, eq_data)
-- 	end
-- 	return can_show
-- end

function GuideCtrl:OpenKeyEquipView(equip, eq_data)
	if type(equip) ~= "table" then return end

	-- 屏蔽弹窗判断
	local item_id = equip.item_id or 0
	local cfg_list = CleintItemShowCfg[2] or {}
	if cfg_list[item_id] then return end

	self.key_equip_view_open = true
	self.key_equip_view:SetData(equip, eq_data)
end

function GuideCtrl:CanShowKeyEquipView(equip)
	local item_cfg = ItemData.Instance:GetItemConfig(equip.item_id)

	-- 基础装备
	local is_better, hand_pos, equip_slot, old_equip = false, nil, nil, nil
	if EquipData.CanEquip(equip) then
		if ItemData.IsBaseEquipType(item_cfg.type) -- 基础神装
		-- or ItemData.IsPeerlessEquip(item_cfg.type) -- 传世神装
		or ItemData.IsRexue(item_cfg.type) -- 热血装备
		or ItemData.GetIHandEquip(item_cfg.item_id) -- 灭霸手套
		then
			is_better, hand_pos, equip_slot = EquipData.Instance:GetIsBetterEquip(equip, true) -- true 表示忽略穿戴条件判断

		-- 星魂装备
		elseif item_cfg.type == ItemData.ItemType.itConstellationItem then
			is_better, hand_pos, equip_slot = ItemData.GetXinghunTip(item_cfg.stype, equip, item_cfg.type)

		-- 守护神装
		elseif item_cfg.type == ItemData.ItemType.itGuardEquip then
			is_better, hand_pos, old_equip = ItemData.GetGuardEquipTip(item_cfg.stype, equip, item_cfg.type)

		-- 翅膀装备
		elseif item_cfg.type == ItemData.ItemType.itWingEquip then
			local can_equip = false
			if item_cfg.stype >= 11 then
				can_equip = WingData.GetNewWingIsOpen()
			else
				can_equip = true
			end

			if can_equip then
				is_better, hand_pos, old_equip = ItemData.GetWingEquipTip(item_cfg.stype, equip, item_cfg.type)
			end

		-- 时装和幻武, 不比对评分
		elseif item_cfg.type == ItemData.ItemType.itWuHuan or item_cfg.type == ItemData.ItemType.itFashion then
			is_better, hand_pos, old_equip = true, 0, equip

		-- 宠物装备
		elseif ItemData.GetIsHeroEquip(equip.item_id) then
			if ZhanjiangCtrl.GetPetEquipIsOpen() then
				is_better, hand_pos, old_equip = ItemData.GetZhanjiangTip(equip, item_cfg.type)
			end

		-- 战纹装备
		elseif ItemData.GetIsZhanwenType(item_cfg.type) then
			if BattleFuwenData.Instance:CheckIsWearable(equip) then
				is_better, hand_pos, old_equip = true, 0, equip
			end

		end
	end

	if is_better then
		if self.key_equip_view_open then
			return 2
		else
			return 1, old_equip and EquipData.Instance:GetEquipDataBySolt(equip_slot)
		end
	end

	-- 天山雪莲
	if IsInTable(equip.item_id, CLIENT_GAME_GLOBAL_CFG.xuelian_items) and not RoleData.HasBuffGroup(BUFF_GROUP.BLOOD_RETURNING) then
		return self.key_equip_view_open and 2 or 1
	end

	return 0
end

function GuideCtrl:KeyEquipViewCloseCallBack(item_id)
	self.key_equip_view_open = false

	if item_id then
		local index = nil
		for k, item in pairs(self.get_use_item_list) do
			if item.item_id == item_id then
				self.get_use_item_list[k] = nil
			end
		end
		for k, item in pairs(self.clean_up_use_item_list) do
			if item.item_id == item_id then
				self.clean_up_use_item_list[k] = nil
			end
		end
	end
end
------------------------------------------------------------------------
-- 一键穿装备end
------------------------------------------------------------------------

------------------------------------------------------------------------
-- 功能预告begin
------------------------------------------------------------------------
local update_foreshow_time = NOW_TIME
function GuideCtrl:UpdateForeshow()
	if 1 > (NOW_TIME - update_foreshow_time) then
		return
	end
	update_foreshow_time = NOW_TIME

	local cur_foreshow_obj = self.guide_data:GetCurForeshowObj()
	if cur_foreshow_obj then
		cur_foreshow_obj:update()	-- 预告基础view更新
	end
end

function GuideCtrl:OpenForeshowView()
	if nil == self.foreshow_view then
		self.foreshow_view = ForeshowView.New()
	end

	self.foreshow_view:Open()
end

function GuideCtrl:GetForeshowBaseView()
	if nil == self.foreshow_base_view then
		self.foreshow_base_view = ForeshowBaseView.New()
	end

	return self.foreshow_base_view
end

function GuideCtrl:CloseForeshowBaseView()
	if nil ~= self.foreshow_base_view then
		self.foreshow_base_view:Close()
	end
end
------------------------------------------------------------------------
-- 功能预告end
------------------------------------------------------------------------

------------------------------------------------------------------------
-- 获取技能提醒begin
------------------------------------------------------------------------
function GuideCtrl:OpenSkillRemindView()
	if nil == self.get_skill_remind_view then
		self.get_skill_remind_view = GetSkillRemindView.New()
	end

	self.get_skill_remind_view:AutoOpen()
end
------------------------------------------------------------------------
-- 获取技能提醒end
------------------------------------------------------------------------

------------------------------------------------------------------------
-- 获得翻牌机会begin
------------------------------------------------------------------------
function GuideCtrl:OpenBrandRemindView()
	if nil == self.get_brand_remind_view then
		self.get_brand_remind_view = GetBrandRemindView.New()
	end

	self.get_brand_remind_view:AutoOpen()
end
------------------------------------------------------------------------
-- 获得翻牌机会end
------------------------------------------------------------------------