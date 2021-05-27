require("scripts/game/task/task_def")
require("scripts/game/task/task_data")
require("scripts/game/task/npc_dialog_view")
require("scripts/game/task/special_npc_dialog_view")
require("scripts/game/task/special_special_dialog_view")
require("scripts/game/task/transmit_npc_dialog_view")
require("scripts/game/task/takeon_equips_task_view")
require("scripts/game/task/task_help")
require("scripts/game/task/task_active_zhanchong_view")
require("scripts/game/task/task_atctive_other_view")
require("scripts/game/task/task_shacheng_view")
require("scripts/game/task/task_shachang_result_view")
require("scripts/game/task/task_equip_guide_view")
require("scripts/game/task/task_tiyan_equip_guide_view")
require("scripts/game/task/task_tishu_view")
require("scripts/game/task/fun_open_guide_view")
TaskCtrl = TaskCtrl or BaseClass(BaseController)

function TaskCtrl:__init()
	if TaskCtrl.Instance ~= nil then
		ErrorLog("[TaskCtrl] attempt to create singleton twice!")
		return
	end
	TaskCtrl.Instance = self

	self.data = TaskData.New()
	self.npc_dialog_view = NpcDialogView.New(ViewDef.NpcDialog)
	self.transmit_npc_dialog_view = TransmitNpcDialogView.New(ViewDef.TransmitNpcDialog)
	self.special_npc_dialog_view = SpecialNpcDialogView.New(ViewDef.SpecialNpcDialog)

	self.special_special_dialog_view = SpecialSpecialDialogView.New(ViewName.SpecialSpecialDialog)

	self.takeon_equips_task_view = TakeonEquipsTaskView.New(ViewName.TakeonEquipsTask)
	self.task_help = TaskHelpView.New(ViewName.TaskHelp)

	self.task_active_chong = TaskActiveZhanChongView.New(ViewDef.TaskZhanChongEffect)

	self.task_guide_view_other = TaskActiveOtheriew.New(ViewDef.TaskNewXiTongGuide)

	self.shacheng_guilde = TaskShangChengView.New(ViewDef.TaskShaChengGuide) 

	self.shacheng_result = ShaChengResultView.New(ViewDef.TaskShaChengResultGuide)
 
 	self.equip_guide = TaskEquipGuideView.New(ViewDef.TaskEquipGetGuide)

 	self.tiyan_equip_guide = TaskTiYanEquipGuide.New(ViewDef.TaskEquipTiYanGuide)

 	self.tishu_view = TaskTiShuView.New(ViewDef.TiShuTask)

 	self.fun_open_view = FunOpenGuideView.New(ViewDef.FunOpenGuideView)

	self.open_view_name = ""
	self.npc_obj_id = 0

	self:RegisterAllProtocols()

	self:BindGlobalEvent(SceneEventType.SCENE_CHANGE_COMPLETE, BindTool.Bind(self.OnSceneChange, self))
	self:BindGlobalEvent(ObjectEventType.OBJ_DELETE, BindTool.Bind(self.OnObjDelete, self))
	self:BindGlobalEvent(ObjectEventType.OBJ_CREATE, BindTool.Bind(self.OnObjCreate, self))
end

function TaskCtrl:__delete()
	TaskCtrl.Instance = nil
	
	self.npc_dialog_view:DeleteMe()
	self.npc_dialog_view = nil
	
	self.special_npc_dialog_view:DeleteMe()
	self.special_npc_dialog_view = nil
	
	self.special_special_dialog_view:DeleteMe()
	self.special_special_dialog_view = nil
	
	self.transmit_npc_dialog_view:DeleteMe()
	self.transmit_npc_dialog_view = nil
	
	self.takeon_equips_task_view:DeleteMe()
	self.takeon_equips_task_view = nil
	
	self.task_help:DeleteMe()
	self.task_help = nil

	if self.alert then
		self.alert:DeleteMe()
		self.alert = nil
	end

	self.task_active_chong:DeleteMe()
	self.task_active_chong = nil

	self.task_guide_view_other:DeleteMe()
	self.task_guide_view_other = nil

	self.shacheng_guilde:DeleteMe()
	self.shacheng_guilde = nil

	self.shacheng_result:DeleteMe()
	self.shacheng_result = nil

	self.equip_guide:DeleteMe()
	self.equip_guide = nil

	self.tiyan_equip_guide:DeleteMe()
	self.tiyan_equip_guide = nil

	self.tishu_view:DeleteMe()
	self.task_tishu_view = nil

	if self.fun_open_view then
		self.fun_open_view:DeleteMe()
		self.fun_open_view = nil 
	end
end

function TaskCtrl:OnSceneChange()
	-- if self.open_view_name ~= "" then
	-- 	ViewManager.Instance:Close(self.open_view_name)
	-- 	self.open_view_name = ""
	-- 	self.npc_obj_id = 0
	-- end
end

function TaskCtrl:OnObjCreate(obj)
	if obj:GetObjId() == self.npc_obj_id then
		GlobalEventSystem:Fire(ObjectEventType.BE_SELECT, obj, "select")
	end
end

function TaskCtrl:OnObjDelete(obj)
	if obj:GetObjId() == self.npc_obj_id then
		self.npc_obj_id = 0
	end
end

-------------------------------------------------------------------------------
function TaskCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCTaskListAck, "OnTaskListAck")
	self:RegisterProtocol(SCAddTask, "OnAddTask")
	self:RegisterProtocol(SCFinishTask, "OnFinishTask")
	self:RegisterProtocol(SCGiveupTask, "OnGiveupTask")
	self:RegisterProtocol(SCAcceptTaskList, "OnAcceptTaskList")
	self:RegisterProtocol(SCRomoveAcceptTask, "OnRomoveAcceptTask")
	self:RegisterProtocol(SCAddAcceptTaskList, "OnAddAcceptTaskList")
	self:RegisterProtocol(SCTaskValue, "OnTaskValue")
	self:RegisterProtocol(SCTaskTitle, "OnTaskTitle")
	self:RegisterProtocol(SCNpcTalkAck, "OnNpcTalkAck")
	self:RegisterProtocol(SCTransmitNpcDialog, "OnTransmitNpcDialog")
	self:RegisterProtocol(SCSpecialNpcDialog, "OnSpecialNpcDialog")
	
	-- self:RegisterProtocol(SCTaskConsume, "OnTaskConsume")
	-- self:RegisterProtocol(SCTransmitDialog, "OnTransmitDialog")
	self:RegisterProtocol(SCGetHadCompeleteTime, "OnGetHadCompeleteTime")

end

-- 所有的正在进行的任务的数据
function TaskCtrl:OnTaskListAck(protocol)
	self.data:OnTaskList(protocol.task_list)
end

--新增一个任务
function TaskCtrl:OnAddTask(protocol)
	self.data:AddTask(protocol.task_info)
end

--完成一个任务
function TaskCtrl:OnFinishTask(protocol)
	if protocol.error_code == TaskErrorCode.Succ then
		self.data:RemoveTask(protocol.task_id, TaskData.FINISH_ONE_TASK)
	end
	local cfg = TaskConfig[protocol.task_id]
	if cfg and cfg.showTipDesc then
		MainuiCtrl.Instance:ShowTipText(cfg.showTipDesc)
	end

	if cfg and cfg.finish_open_view then
		ViewManager.Instance:OpenViewByStr(cfg.finish_open_view.view_link)
		if cfg.finish_open_view then
			ViewManager.Instance:FlushViewByStr(cfg.finish_open_view.view_link, 0, "param1",cfg.finish_open_view)
		end
	end
	--print(">>>>>>>>>>2")
	--ViewManager.Instance:OpenViewByDef(ViewDef.TaskEquipTiYanGuide)
	-- ViewManager.Instance:FlushViewByStr("TaskNewXiTongGuide", 0, "param1", {view_index = 1})
end

--放弃一个任务
function TaskCtrl:OnGiveupTask(protocol)
	if protocol.error_code == TaskErrorCode.Succ then
		self.data:RemoveTask(protocol.task_id, TaskData.GIVEUP_ONE_TASK)
	end
end

function TaskCtrl:OnAcceptTaskList(protocol)
	self.data:OnAcceptTaskList(protocol.accept_list)
	--print(">>>>>>>>>>23")
end

function TaskCtrl:OnRomoveAcceptTask(protocol)
	self.data:RemoveAcceptTask(protocol.task_id)
	--print(">>>>>>>>>>4")
end

function TaskCtrl:OnAddAcceptTaskList(protocol)
	self.data:OnAddAcceptTaskList(protocol.accept_list)
	--print(">>>>>>>>>>25")
end

function TaskCtrl:OnTaskValue(protocol)
	self.data:SetCurValue(protocol.task_id, protocol.target_index, protocol.cur_value)
	if protocol.task_id == 19 then
		--print(">>>>>>>>>>>>")
		
		if self.data:GetTaskStateById(protocol.task_id) == TaskState.Complete then
			local main_role = Scene.Instance:GetMainRole()
			main_role:StopMove()
			 GlobalTimerQuest:AddDelayTimer(function()
				Scene.Instance:FlyToRolePos(0.6)
		end, 1)
		end
	end

end

function TaskCtrl:OnTaskTitle(protocol)
	self.data:SetTitle(protocol.task_id, protocol.title)
end

function TaskCtrl:OnNpcTalkAck(protocol)
	if 0 ~= protocol.is_open then
		self.open_view_def = ViewDef.NpcDialog
		self.npc_obj_id = protocol.obj_id
		self.open_view_def.view_data = {
			obj_id = protocol.obj_id,
			dialog_type = protocol.dialog_type,
			talk_str = protocol.talk_str,
		}
		ViewManager.Instance:OpenViewByDef(self.open_view_def)
	else
		ViewManager.Instance:CloseViewByDef(self.open_view_def)
		self.open_view_name = ""
		self.npc_obj_id = 0
	end
end

function TaskCtrl:OnTransmitNpcDialog(protocol)
	self.npc_obj_id = protocol.obj_id
	ViewDef.TransmitNpcDialog.view_data = {
		obj_id = protocol.obj_id,
		area_list = protocol.area_list,
	}
	ViewManager.Instance:OpenViewByDef(ViewDef.TransmitNpcDialog)
end

function TaskCtrl:OnSpecialNpcDialog(protocol)
	self.open_view_def = ViewDef.SpecialNpcDialog
	if protocol.dialog_type == NPC_DIALOG_TYPE.ZBT_NPCDLG then
		GlobalEventSystem:Fire(OtherEventType.SUCCESS_ESCORT)
	elseif protocol.dialog_type == NPC_DIALOG_TYPE.PrestigeTaskNpcDla then
		ViewManager.Instance:OpenViewByDef(ViewDef.PrestigeTask)
		return
	elseif protocol.dialog_type == NPC_DIALOG_TYPE.WorshiNpcDlg then
		ViewManager.Instance:OpenViewByDef(ViewDef.Worship)
		local data = Split(protocol.bottom, ",")	
		ViewManager.Instance:FlushViewByDef(ViewDef.Worship, 0, "OnOpenView", data)
		return
	elseif protocol.dialog_type == NPC_DIALOG_TYPE.MYSD_NPCDLG then
		ViewManager.Instance:OpenViewByDef(ViewDef.NewlyBossView.Wild.MayaBoss)
		return
	elseif protocol.dialog_type == NPC_DIALOG_TYPE.CLFB_NPCDLG then
		local open_lv = FubenZongGuanCfg.fubens[1].lv
		if RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL) >= open_lv then
			ViewManager.Instance:OpenViewByDef(ViewDef.Dungeon)
		else
			SysMsgCtrl.Instance:FloatingTopRightText(string.format(Language.Common.NotLevel, open_lv))
		end
		return
	-- elseif protocol.dialog_type == NPC_DIALOG_TYPE.WZAD_NPCDLG then
	-- 	self.open_view_name = ViewName.WeizhiAD
	elseif protocol.dialog_type == NPC_DIALOG_TYPE.DRFB_NPCDLG then
		ViewManager.Instance:OpenViewByDef(ViewDef.FubenMulti)
		return
	elseif protocol.dialog_type == NPC_DIALOG_TYPE.CHIYOU_NPCDLG then
		ViewManager.Instance:OpenViewByDef(ViewDef.ChiyouView)
		return
	elseif protocol.dialog_type == NPC_DIALOG_TYPE.XYCM_NPCDLG then
		ViewManager.Instance:OpenViewByDef(ViewDef.DailyTasks)
		return
	elseif protocol.dialog_type == NPC_DIALOG_TYPE.TiShuTaskNpcDlg then
		ViewManager.Instance:OpenViewByDef(ViewDef.TiShuTask)
		return
	end

	self.npc_obj_id = protocol.obj_id
	self.open_view_def.view_data = {
		obj_id = protocol.obj_id,
		dialog_type = protocol.dialog_type,
		talk_str = protocol.talk_str,
		cond = protocol.cond,
		bottom = protocol.bottom,
		btn_list = protocol.btn_list,
		money_type = protocol.money_type,
		param = protocol.param,
		msg_list = protocol.msg_list,
	}
	ViewManager.Instance:OpenViewByDef(self.open_view_def)
end

-------------------------------------------------------------------------------------------
function TaskCtrl.SendNpcTalkReq(obj_id, func_name)
	local protocol = ProtocolPool.Instance:GetProtocol(CSNpcTalkReq)
	protocol.obj_id = obj_id
	protocol.func_name = func_name
	protocol:EncodeAndSend()
end

function TaskCtrl.SendConmitSubTaskReq(task_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSConmitSubTaskReq)
	protocol.task_id = task_id
	protocol:EncodeAndSend()
end

function TaskCtrl.SendTaskOrderListReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSTaskOrderListReq)
	protocol:EncodeAndSend()
end


function TaskCtrl:OnTaskDoConut(protocol)
	self.data:SetTaskDoCount(protocol)
end

function TaskCtrl.SendTransmitStoneReq(area_index, btn_index)
	local protocol = ProtocolPool.Instance:GetProtocol(CSTransmitStoneReq)
	protocol.area_index = area_index
	protocol.btn_index = btn_index
	protocol:EncodeAndSend()
end

function TaskCtrl.SendTriggerTaskEvent(event_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSTriggerTaskEvent)
	protocol.event_id = event_id
	protocol:EncodeAndSend()
end

function TaskCtrl.SendCompleteTaskReq(task_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSCompleteTaskReq)
	protocol.task_id = task_id
	protocol:EncodeAndSend()
end


function TaskCtrl.SendEnterFubenReq(fuben_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSGEnterFubenReq)
	protocol.fuben_id = fuben_id
	protocol:EncodeAndSend()
end

function TaskCtrl:FlyToConbar(node_name, view_name, path)
	local fly_to_target = ViewManager.Instance:GetUiNode("MainUi", node_name, view_name)
	local path = path
	if "" == path or nil == fly_to_target then return end

	local screen_w = HandleRenderUnit:GetWidth()
	local screen_h = HandleRenderUnit:GetHeight()
	local fly_icon = XUI.CreateImageView(0, 0, path, true)
	fly_icon:setAnchorPoint(0, 0)
	HandleRenderUnit:AddUi(fly_icon, COMMON_CONSTS.ZORDER_SYSTEM_EFFECT, COMMON_CONSTS.ZORDER_SYSTEM_EFFECT)
	local world_pos = fly_icon:convertToWorldSpace(cc.p(0,0))
	fly_icon:setPosition(screen_w / 2, screen_h / 2)

	local fly_to_pos = fly_to_target:convertToWorldSpace(cc.p(0,0))
	local move_to =cc.MoveTo:create(0.8, cc.p(fly_to_pos.x, fly_to_pos.y))
	local spawn = cc.Spawn:create(move_to)
	local callback = cc.CallFunc:create(BindTool.Bind2(self.FlyEnd, self, fly_icon))
	local action = cc.Sequence:create(spawn,callback)
	fly_icon:runAction(action)
end


function TaskCtrl:FlyEnd(fly_icon)
	if fly_icon then
		fly_icon:removeFromParent()
	end
end


------====天书任务===

function TaskCtrl:SendOprateTianShuTask(operate_type, reward_type)
	local protocol = ProtocolPool.Instance:GetProtocol(CSOprateTianShuTask)
	protocol.oprate_type = operate_type
	protocol.reward_type = reward_type
	protocol:EncodeAndSend()
end


--完成次数

function TaskCtrl:OnGetHadCompeleteTime(protocol)
	self.data:SetHadCompeleteTime(protocol)
end
