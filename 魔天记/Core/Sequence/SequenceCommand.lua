SequenceCommand = { };

function SequenceCommand.DelayFrame()
    return SequenceTrigger.New(SequenceEvent.New( { eventType = SequenceEventType.DELAY_FRAME }));
end
 
function SequenceCommand.Delay(time, ignoreTimeScale)
    ignoreTimeScale = ignoreTimeScale or false;
    return SequenceTrigger.New(
        SequenceEvent.New( { eventType = SequenceEventType.DELAY, eventArgs = { time, ignoreTimeScale } })
    );
end

function SequenceCommand.WaitForEvent(sequenceEventType, args, sequenceEventFilter,onTrigger)
    return SequenceTrigger.New(
        SequenceEvent.New( { eventType = sequenceEventType, eventArgs = args, eventFilter = sequenceEventFilter,triggerCallBack = onTrigger })
    );
end

SequenceCommand.Common = {

    GoToPos = function(map, pos, r, range) 
        r = r or 0.3;
        range = range or 0;
        if TaskUtils.InArea(map, pos, r) then
            return nil;
        else
            HeroController.GetInstance():MoveTo(pos, map, true);
        end
        local filter = function(args) return TaskUtils.InMap(map) and TaskUtils.InCircle(args, pos, r) end;
        return SequenceCommand.WaitForEvent(SequenceEventType.Base.MOVE_TO_PATH_END, nil, filter);
    end;

    TalkToNpc = function(npcId)
        local filter = function(args) return(args == npcId) end;
        return SequenceCommand.WaitForEvent(SequenceEventType.Base.TALK_TO_NPC, nil, filter);
    end;

    GoToNpc = function(npcId)
        local nearToNpc = TaskUtils.CheckPosToNpc(npcId);
        if nearToNpc then
            return nil;
        else
            HeroController.GetInstance():MoveToNpc(npcId);
            local filter = function(args) return(args == npcId) end;
            return SequenceCommand.WaitForEvent(SequenceEventType.Base.MOVE_TO_NPC_END, nil, filter);
        end
    end;

    GoToScene = function(mapId, pos, ingoreLoad)

        if TaskUtils.InMap(mapId) then
            return nil;
        end

        if pos == nil then
            local mapCfg = ConfigManager.GetMapById(mapId);
            pos = Convert.PointFromServer(mapCfg.born_x, mapCfg.born_y, mapCfg.born_z);
        end

        local toScene = { };
        toScene.sid = mapId;
        toScene.position = pos;
        -- GameSceneManager.to = toScene;
        if ingoreLoad then
            GameSceneManager.GotoScene(mapId, nil, toScene);
        else
            GameSceneManager.GotoSceneByLoading(mapId,nil,toScene);
        end

        local filter = function(args) return(args == mapId) end;
        return SequenceCommand.WaitForEvent(SequenceEventType.Base.MOVE_TO_SCENE, nil, filter);
    end;

}

SequenceCommand.Task = {

    TaskFinish = function(taskId)
        local filter = function(args) return(args == taskId) end;
        return SequenceCommand.WaitForEvent(SequenceEventType.Base.TASK_FINISH, nil, filter);
    end;

    TransmitToNpc = function(npcId)
        local npcCfg = ConfigManager.GetNpcById(npcId);
        local map = npcCfg.map;
        local pos = Vector3(npcCfg.x / 100, 0, npcCfg.z / 100);
        if TaskUtils.InArea(map, pos, 20) then
            MsgUtils.ShowTips("task/payTips");
            return SequenceCommand.Common.GoToNpc(npcId);
        else
            return SequenceCommand.Task.TaskTransmit(map, pos);
        end
    end;

    --任务传送
    TaskTransmit = function(map, pos)
        HeroController.GetInstance():StopAction(3);
        HeroController.GetInstance():Stand();
        --local map = tonumber(p[1]);
        --local pos = Convert.PointFromServer(tonumber(p[2]), 0, tonumber(p[3]));
        
        TaskProxy.ReqPayToDo();

        if TaskUtils.InMap(map) == false then
            --不同地图时传送
            return SequenceCommand.Common.GoToScene(map, pos, true);
        elseif TaskUtils.InArea(map, pos, 12) then
            --在有范围内时走过去
            MsgUtils.ShowTips("task/payTips");
            return SequenceCommand.Common.GoToPos(map, pos);
        else
            --同地图瞬移
            TaskProxy.SendTransLate(pos);
            return SequenceCommand.WaitForEvent(SequenceEventType.Base.TRANSMIT_END);
        end
    end;
}

SequenceCommand.Guide = {
    
    GuideClickBlank = SequenceCommand.WaitForEvent(SequenceEventType.Guide.BLANK_CLICK);

    --引导点击
    GuideClickUI = function(msg, targets, anchorTr, waitFor, posType, offset, useMask,effectOffset,canSkip,maskAlpha)
        local p = {};
        p.useMask = useMask;
        
        local tmp = nil;
        if type(targets) == "table" then
            p.target = targets;
            tmp = targets[1];
        else
            p.target = {targets};
            tmp = targets;
        end

        p.msg = msg;
        if anchorTr == nil then
            if tmp then
                p.anchorTr = tmp.transform;
            end
        else
            p.anchorTr = anchorTr;
        end

        p.posType = posType or GuideTools.Pos.CUSTOM;
        p.offset = offset or Vector3.zero;
        p.effectOffset = effectOffset or Vector3.zero;
        p.canSkip = (canSkip ~= false) and true or false;
        p.maskAlpha = maskAlpha;
        
        ModuleManager.SendNotification(GuideNotes.OPEN_GUIDE_CLICK, p);
        
        return waitFor;
    end;

    GuideSelectRoleUI = function(msg, target, waitFor, posType, offset, useMask, canSkip)
        local p = {};
        p.useMask = useMask;        
        p.target = target
        p.msg = msg;
        p.posType = posType or GuideTools.Pos.CUSTOM;
        p.offset = offset or Vector3.zero;
        p.effectOffset = effectOffset or Vector3.zero;     
        p.canSkip = (canSkip ~= false) and true or false;
           
        ModuleManager.SendNotification(GuideNotes.OPEN_GUIDE_SELECT_ROLE, p);        
        return waitFor;
    end;

    SelectMonster = function(monId) 
        local filter = function(args) 
            if args.roleType == ControllerType.MONSTER or args.roleType == ControllerType.PUPPET then
                return args.info.kind == monId;
            end
            return false;
        end;
        return SequenceCommand.WaitForEvent(SequenceEventType.Guide.GUIDE_CLICK_TARGET, nil, filter);
    end


}

SequenceCommand.UI = {
    
    --等待某个panel打开. 参数是panel._name(默认是Transform的名字).
    ForcePanelInit = function(name)
        local filter = function(panel) 
            Warning("-->" .. panel)
            if panel == name then
                GuideManager.forceSysGo = nil;
                return true
            else
                return false;
            end
        end;
        return SequenceCommand.WaitForEvent(SequenceEventType.Guide.PANEL_INIT, nil, filter);
    end;

    PanelInit = function(name)
        local filter = function(panel) return panel == name; end;
        return SequenceCommand.WaitForEvent(SequenceEventType.Guide.PANEL_INIT, nil, filter);
    end;

    PanelStart = function(name)
        local filter = function(panel) return panel == name; end;
        return SequenceCommand.WaitForEvent(SequenceEventType.Guide.PANEL_START, nil, filter);
    end;

    --跟ForcePanelOpened区别是非强制. 可关闭.
    PanelOpened = function(name)
        local filter = function(panel) return panel == name; end;
        return SequenceCommand.WaitForEvent(SequenceEventType.Guide.PANEL_OPENED, nil, filter);
    end;

    PanelClosed = function(name)
        local filter = function(panel) return panel == name; end;
        return SequenceCommand.WaitForEvent(SequenceEventType.Guide.PANEL_CLOSEED, nil, filter);
    end;

    --点击关闭按钮
    CloseBtnClick = function(name)
        local filter = function(panel) return name == panel end;
        return SequenceCommand.WaitForEvent(SequenceEventType.Guide.PANEL_CLOSEBTN_CLICK, nil, filter);
    end;
}


