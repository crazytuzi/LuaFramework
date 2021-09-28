require "Core.Module.Pattern.Proxy"
require "net/CmdType"
require "net/SocketClientLua"

TaskProxy = Proxy:New();
function TaskProxy:OnRegister()
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Task_List, TaskProxy._RspTaskList);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Task_Get, TaskProxy._RspTaskGet);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Task_Update, TaskProxy._RspTaskUpdate);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Task_Trigger, TaskProxy._RspTaskTrigger);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Task_End, TaskProxy._RspTaskEnd);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Task_Daily_Acc, TaskProxy._RspTaskDailyAcc);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Task_Complete, TaskProxy._RspTaskComplete);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Task_Monster, TaskProxy._RspTaskMonster);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Task_Reward_BuyTime, TaskProxy._RspTaskRewardBuyTime);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Task_Reward_Refresh, TaskProxy._RspTaskRewardRefresh);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Task_Cancel, TaskProxy._RspTaskCancel);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Task_Escort, TaskProxy._RspTaskEscort);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Task_Escort_Fail, TaskProxy._RspTaskEscortFail);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Task_Escort_Trigger, TaskProxy._RspTaskEscortTrigger);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Task_Do_CollectItem, TaskProxy._RspTaskDoCollectItem);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Task_Need_Help, TaskProxy._RspTaskNeedHelp);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Task_Help_List, TaskProxy._RspTaskHelpList);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Task_Help_CollectItem, TaskProxy._RspTaskHelpCollectItem);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Task_Gold_Refresh, TaskProxy._RspGoldRefresh);
    

end

function TaskProxy:OnRemove()
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Task_List, TaskProxy._RspTaskList);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Task_Get, TaskProxy._RspTaskGet);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Task_Update, TaskProxy._RspTaskUpdate);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Task_Trigger, TaskProxy._RspTaskTrigger);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Task_End, TaskProxy._RspTaskEnd);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Task_Daily_Acc, TaskProxy._RspTaskDailyAcc);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Task_Complete, TaskProxy._RspTaskComplete);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Task_Monster, TaskProxy._RspTaskMonster);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Task_Reward_BuyTime, TaskProxy._RspTaskRewardBuyTime);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Task_Reward_Refresh, TaskProxy._RspTaskRewardRefresh);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Task_Cancel, TaskProxy._RspTaskCancel);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Task_Escort, TaskProxy._RspTaskEscort);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Task_Escort_Fail, TaskProxy._RspTaskEscortFail);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Task_Escort_Trigger, TaskProxy._RspTaskEscortTrigger);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Task_Do_CollectItem, TaskProxy._RspTaskDoCollectItem);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Task_Need_Help, TaskProxy._RspTaskNeedHelp);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Task_Help_List, TaskProxy._RspTaskHelpList);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Task_Help_CollectItem, TaskProxy._RspTaskHelpCollectItem);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Task_Gold_Refresh, TaskProxy._RspGoldRefresh);

end

function TaskProxy.TaskJsonToTaskInfo(data)
    local taskList = {};
    for i, v in ipairs(data) do
        taskList[i] = TaskInfo.New(v);
    end
    return taskList;
end

--rsp
--任务列表 0D01
function TaskProxy._RspTaskList(cmd, data)
    if(data ~= nil and data.errCode == nil) then
        local taskList = TaskProxy.TaskJsonToTaskInfo(data.l);
        TaskManager.OnInitTaskList(taskList, data, TaskProxy.isLoginReqList);
        TaskProxy.isLoginReqList = false;
    end
end
--接取任务通知 0D02
function TaskProxy._RspTaskGet(cmd, data)
    if(data ~= nil and data.errCode == nil) then
        local task = TaskInfo.New(data);
        TaskManager.OnGetTask(task, data);   
    end
end
--任务状态通知 0D03
function TaskProxy._RspTaskUpdate(cmd, data)
    if(data ~= nil and data.errCode == nil) then
        TaskManager.OnUpdateTask(data);
        TaskManager.OnUpdateTaskData(data);
    end
end
--任务完成 0D04
function TaskProxy._RspTaskTrigger(cmd, data)
    
end
--发放奖励 0D05
function TaskProxy._RspTaskEnd(cmd, data)
    if(data ~= nil and data.errCode == nil) then
        UISoundManager.PlayUISound(UISoundManager.task_comit);
        TaskManager.OnComitTask(data);
        TaskManager.OnUpdateTaskData(data);
    end
end

--开启循环任务 0D06
function TaskProxy._RspTaskDailyAcc(cmd, data)
    GuideManager.OptSetStatus(GuideManager.Id.GuideLoopTack);
end

--快速完成任务. 0D07
function TaskProxy._RspTaskComplete(cmd, data)
    
end

function TaskProxy._RspTaskMonster(cmd, data)
    
end

function TaskProxy._RspTaskRewardBuyTime(cmd, data)
    if(data ~= nil and data.errCode == nil) then
        TaskManager.OnUpdateTaskData(data);
    end
end

function TaskProxy._RspTaskRewardRefresh(cmd, data)
    if(data ~= nil and data.errCode == nil) then
        local taskList = TaskProxy.TaskJsonToTaskInfo(data.l);
        TaskManager.OnInitTaskList(taskList, data);
        --TaskManager.OnUpdateTaskData(data);
    end
end

function TaskProxy._RspTaskCancel(cmd, data)
    if(data ~= nil and data.errCode == nil) then
        TaskManager.OnCancelTask(data.id);
    end
end
 
--护送任务触发
function TaskProxy._RspTaskEscort(cmd, data)
    SequenceManager.TriggerEvent(SequenceEventType.Base.TASK_ESCORT_START, data.id);
end

--护送任务失败
function TaskProxy._RspTaskEscortFail(cmd, data)
    --"task/escort/fail"
    MsgUtils.ShowTips("task/escort/fail");
end

--护送任务路径触发
function TaskProxy._RspTaskEscortTrigger(cmd, data)
    --log(data.id)
    --log(data.rid)
end

--提交仙盟收集物品任务
function TaskProxy._RspTaskDoCollectItem(cmd, data)
    if(data == nil or data.errCode ~= nil) then
        return;
    end

end
--发布仙盟求助
function TaskProxy._RspTaskNeedHelp(cmd, data)
    if(data == nil or data.errCode ~= nil) then
        return;
    end
    TaskManager.OnUpdateTaskData(data);
    MsgUtils.ShowTips("guild/tips/taskNeedHelp");

    local list = TaskManager.GetGuildList();
    for i, v in ipairs(list) do 
        if v.id == data.id then
            v.guildHelp = 1;
            break;
        end
    end

    MessageManager.Dispatch(GuildNotes, GuildNotes.RSP_TASK_HELP);
end
--获取仙盟求助列表
function TaskProxy._RspTaskHelpList(cmd, data)
    if(data == nil or data.errCode ~= nil) then
        return;
    end 
    MessageManager.Dispatch(GuildNotes, GuildNotes.RSP_TASK_HELPLIST, data);
end
--帮助他人完成仙盟收集物品任务
function TaskProxy._RspTaskHelpCollectItem(cmd, data)
    if(data == nil or data.errCode ~= nil) then
        return;
    end
    MsgUtils.ShowTips("guild/tips/taskHelp");
    MessageManager.Dispatch(GuildNotes, GuildNotes.RSP_HELP_COLLECTITEM, data);
end

--req
function TaskProxy.ReqTaskList()
    TaskProxy.isLoginReqList = true;
    SocketClientLua.Get_ins():SendMessage(CmdType.Task_List);
end

--接取任务(悬赏)
function TaskProxy.ReqTaskAccess(taskId)
    --log("接取悬赏任务" .. taskId);
    SocketClientLua.Get_ins():SendMessage(CmdType.Task_Update, {id = taskId});
end

function TaskProxy.ReqTaskTrigger(taskId)
    SocketClientLua.Get_ins():SendMessage(CmdType.Task_Trigger, {id = taskId});
end

function TaskProxy.ReqTaskFinish(taskId, t)

    t = t or 0;
    --log("领取任务奖励" .. taskId);
    if t == 0 then
        SocketClientLua.Get_ins():SendMessage(CmdType.Task_End, {id = taskId, t = 0});
    else
        MsgUtils.UseBDGoldConfirm(10, nil, "task/reward/payExp", nil, TaskProxy.ConfirmExpComit, nil, taskId, "common/ok", nil, nil, 1);
    end
end

function TaskProxy.ConfirmExpComit(taskId)
    SocketClientLua.Get_ins():SendMessage(CmdType.Task_End, {id = taskId, t = 1});
end

--刷怪
function TaskProxy.ReqMonster(taskId)
    SocketClientLua.Get_ins():SendMessage(CmdType.Task_Monster, {id = taskId});
end

--接取循环任务
function TaskProxy.ReqAccDailyTask()
    SocketClientLua.Get_ins():SendMessage(CmdType.Task_Daily_Acc, nil);
end

--花钱完成任务
function TaskProxy.ReqTaskComplete(taskId)
    SocketClientLua.Get_ins():SendMessage(CmdType.Task_Complete, {id = taskId});
end

--放弃悬赏任务
function TaskProxy.ReqTaskCancel(taskId)
    --log("放弃任务" .. taskId);
    SocketClientLua.Get_ins():SendMessage(CmdType.Task_Cancel, {id = taskId});
end

--悬赏购买次数
function TaskProxy.ReqRewardBuyTime()
    SocketClientLua.Get_ins():SendMessage(CmdType.Task_Reward_BuyTime, nil);
end

--刷新悬赏任务列表
function TaskProxy.ReqRewardRefresh()
    SocketClientLua.Get_ins():SendMessage(CmdType.Task_Reward_Refresh, nil);
end

--触发护送任务
function TaskProxy.ReqTaskEscort(taskId)
    SocketClientLua.Get_ins():SendMessage(CmdType.Task_Escort, {id = taskId});
end

function TaskProxy.ReqTaskDoCollectItem(taskId)
    SocketClientLua.Get_ins():SendMessage(CmdType.Task_Do_CollectItem, {id = taskId});
end

function TaskProxy.ReqTaskNeedHelp(taskId)
    SocketClientLua.Get_ins():SendMessage(CmdType.Task_Need_Help, {id = taskId});
end

function TaskProxy.ReqTaskHelpList()
    SocketClientLua.Get_ins():SendMessage(CmdType.Task_Help_List, nil);
end

function TaskProxy.ReqTaskHelpCollectItem(t, taskId, pid)
    SocketClientLua.Get_ins():SendMessage(CmdType.Task_Help_CollectItem, {t = t, id = taskId, pi = pid});
end

--悬赏刷新品质
function TaskProxy.ReqGoldRefresh(taskId)
    SocketClientLua.Get_ins():SendMessage(CmdType.Task_Gold_Refresh, {id = taskId});
end

function TaskProxy._RspGoldRefresh(cmd, data)
    if(data == nil or data.errCode ~= nil) then
        return;
    end

    TaskManager.ChangeTaskId(data.id, data.nid);
end

function TaskProxy.ReqPayToDo()
    SocketClientLua.Get_ins():SendMessage(CmdType.PayToDoTask);
end

function TaskProxy.SendTransLate(pos)
    local data = {t = 1,id = PlayerManager.playerId, x = tonumber(pos.x * 100),y = 0,z = tonumber(pos.z * 100), a=0}
    SocketClientLua.Get_ins():SendMessage(CmdType.TransLateInScene,data)
end