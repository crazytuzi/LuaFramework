local TaskProxy=classGc(function(self)
	self.m_bInitialized=false		--默认未初始化
	self.m_taskDataList	= {}		--任务数据
	self.m_mainTask		= nil		--当前指引任务

    self.m_acceptSoundArray={}

    local mediator=require("mod.support.TaskProxyMediator")(self)
end)

local __CONST_TASK_STATE_FINISHED=_G.Const.CONST_TASK_STATE_FINISHED
local __CONST_TASK_STATE_UNFINISHED=_G.Const.CONST_TASK_STATE_UNFINISHED
local __CONST_TASK_STATE_ACCEPTABLE=_G.Const.CONST_TASK_STATE_ACCEPTABLE
local __CONST_TASK_STATE_ACTIVATE=_G.Const.CONST_TASK_STATE_ACTIVATE

function TaskProxy.setInitialized(self, _value)
	self.m_bInitialized=_value
end

function TaskProxy.getInitialized(self)
	return self.m_bInitialized
end

function TaskProxy.removeTaskByData(self, _ackMsg)
    local removeId    =_ackMsg.id
    
    --从列表中移除
    local removeReason=false
    for i=1,#self.m_taskDataList do
        local task=self.m_taskDataList[i]
        if task.id==removeId then
            --清空该任务对应endnpc头上的图标
            local command=CNpcUpdateCommand(CNpcUpdateCommand.DELETE)
            command.taskData=task            
            _G.controller :sendCommand(command)

            removeReason=true
            table.remove(self.m_taskDataList, i)
            break
        end
    end

    if removeReason==false then return end
    
    --取消当前任务设置
    if self.m_mainTask~=nil and removeId==self.m_mainTask.id then
        self : cleanMainTask()
        self : autoMainTask()
    end

    --完成任务特效
    local TaskEffectsCommand=CTaskEffectsCommand(_G.Const.CONST_TASK_STATE_SUBMIT) -- 1是接受任务 2是完成任务
    TaskEffectsCommand.taskId=_ackMsg.id
    controller:sendCommand(TaskEffectsCommand)

    --界面需要更新  接受这命令把
    local command=CTaskDataUpdataCommand(_ackMsg.MsgID)
    command.id=_ackMsg.id
    controller :sendCommand(command)
end

function TaskProxy.autoMainTask(self)
    local guiderTask=self :getMainTask()
    local testData  =self :getTaskDataList()

    if guiderTask==nil then
        self :setMainTask(testData[1])
    elseif testData[1]~=nil then
        if testData[1].id~=guiderTask.id or testData[1].state~=guiderTask.state then
            self :setMainTask(testData[1])
        end
    end
end

--任务数据
function TaskProxy.updateOneTaskData(self, _value)
    local taskTb =_value
    local preTask=nil
    local preIdx =nil
    for i=1,#self.m_taskDataList do
        local task=self.m_taskDataList[i]
        if taskTb.id==task.id then
            preTask=task
            preIdx =i
            break
        end
    end
    print("[TaskProxy.updateOneTaskData]", taskTb.id, taskTb.state, taskTb.current)
    if preTask==nil or preTask.state~=taskTb.state or preTask.current~=taskTb.current then
        print("[TaskProxy.updateOneTaskData]  update this task")

        --完善任务数据
        taskTb.type=0
        local taskNode=self :getTaskDataById(taskTb.id)
        if taskNode~=nil then
            taskTb.type=taskNode.type
            taskTb.sNpc=taskNode.npc.s.npc
            taskTb.eNpc=taskNode.npc.e.npc

            --测试检查---》》》》》
            if taskTb.target_type==6 or taskTb.target_type==7 then
                local nnn_target="target_"..taskTb.target_type
                if taskNode[nnn_target]==nil then
                    CCMessageBox(_G.Lang.ERROR_N[138],_G.Lang.ERROR_N[139]..taskTb.id)
                end
            end
        else
            return
        end

        --删除之前的，添加新的任务数据
        local curIdx=preIdx or #self.m_taskDataList+1
        self.m_taskDataList[curIdx]=taskTb

        --排序
        if #self.m_taskDataList>1 then
            self:sortTaskData()
        end
        
        if preTask==nil then
            --更新npc图标
            local command=CNpcUpdateCommand(CNpcUpdateCommand.ADD)
            command.taskData=taskTb
            _G.controller :sendCommand(command)

            self:autoMainTask()

            if taskTb.state==__CONST_TASK_STATE_UNFINISHED then
                local command  =CGuideTouchCammand(CGuideTouchCammand.TASK_RECEIVE)
                command.touchId=taskTb.id
                _G.controller:sendCommand(command)
            end
        elseif taskTb.state~=preTask.state then
            --更新npc图标
            local command=CNpcUpdateCommand(CNpcUpdateCommand.UPDATE)
            command.taskData=taskTb
            _G.controller :sendCommand(command)

            if preTask.state==__CONST_TASK_STATE_ACCEPTABLE
                and taskTb.state>=__CONST_TASK_STATE_UNFINISHED then
                self :setMainTask(taskTb)
                local TaskEffectsCommand =CTaskEffectsCommand(__CONST_TASK_STATE_UNFINISHED) -- 1是接受任务 2是完成任务
                TaskEffectsCommand.taskId=taskTb.id
                _G.controller:sendCommand(TaskEffectsCommand)

                if taskTb.state==__CONST_TASK_STATE_UNFINISHED then
                    local command  =CGuideTouchCammand(CGuideTouchCammand.TASK_RECEIVE)
                    command.touchId=taskTb.id
                    _G.controller:sendCommand(command)
                elseif taskTb.state==__CONST_TASK_STATE_FINISHED then
                    local command  =CGuideTouchCammand(CGuideTouchCammand.TASK_FINISH)
                    command.touchId=taskTb.id
                    _G.controller:sendCommand(command)
                end

                local npcCnf=_G.Cfg.scene_npc[taskTb.sNpc]
                local szSound=npcCnf.sound
                if szSound~=nil and szSound~=0 then
                    if self.m_acceptSoundArray[szSound]==nil then
                        _G.Util:playAudioEffect(szSound)
                        self.m_acceptSoundArray[szSound]=true
                    else
                        self.m_acceptSoundArray[szSound]=nil
                    end
                end
            elseif taskTb.state==__CONST_TASK_STATE_FINISHED then
                local command  =CGuideTouchCammand(CGuideTouchCammand.TASK_FINISH)
                command.touchId=taskTb.id
                _G.controller:sendCommand(command)

                self :autoMainTask()

                if taskTb.target_type==7 then
                    --打副本
                    local mainPlay=_G.GPropertyProxy:getMainPlay()
                    if mainPlay~=nil then
                        local copyGuideData=mainPlay :getTaskInfo()
                        if copyGuideData~=nil 
                            and copyGuideData.type==_G.Const.CONST_TASK_TRACE_MAIN_TASK
                            and copyGuideData.ortherData==taskTb.id then
                            --清除副本指引
                            mainPlay :setTaskInfo()
                        end
                    end
                end
            else
                self :autoMainTask()
            end
        else
            self :autoMainTask()
        end

        if taskTb.state>=__CONST_TASK_STATE_ACTIVATE then
            --界面需要更新  接受这命令把
            local command=CTaskDataUpdataCommand(_G.Msg.ACK_TASK_DATA)
            command.id=taskTb.id
            command.state=taskTb.state
            _G.controller :sendCommand(command)
        end
    end
end

function TaskProxy.getTaskDataList(self)
	return self.m_taskDataList
end

--{对数据进行排序    状态优先,主线>支线, }
function TaskProxy.sortTaskData(self)
    -- 主线与支线时  优先已完成任务的、再到主线(不能接的除外)
    local function func(value1, value2)
        if value1.type<value2.type then
            if value1.state<__CONST_TASK_STATE_FINISHED and value2.state>__CONST_TASK_STATE_UNFINISHED then
                return false
            else
                return value1.state>__CONST_TASK_STATE_ACTIVATE
            end
        elseif value1.type>value2.type then
            if value2.state<__CONST_TASK_STATE_FINISHED and value1.state>__CONST_TASK_STATE_UNFINISHED then
                return true
            else
                return value2.state<__CONST_TASK_STATE_ACCEPTABLE
            end
        else
            if value1.state==value2.state then
                return value1.id<value2.id
            elseif value1.state>__CONST_TASK_STATE_UNFINISHED then
                --value1可完成
                return true
            elseif value2.state>__CONST_TASK_STATE_UNFINISHED then
                --value2可完成
                return false
            elseif value1.state==__CONST_TASK_STATE_ACCEPTABLE then
                --value1可接
                return true
            elseif value2.state==__CONST_TASK_STATE_ACCEPTABLE then
                --value2可接
                return false
            else
                return value1.state>value2.state
            end
        end
    end

    table.sort(self.m_taskDataList, func)

    -- print("\n \n \n \n \n 任务排序后------taskDataSortEnd")
    -- print("///////////////////////////////////////////////")
    -- for i,v in ipairs(self.m_taskDataList) do
    --     print("type=%d,  state=%d,  id=%d,    pos=%d",v.type,v.state,v.id,i)
    -- end
    -- print("///////////////////////////////////////////////")
    -- print("\n \n \n \n \n ")
end

--------------------------淫荡的分割线-----------------------
function TaskProxy.getNpcNodeById(self, _npcId)
    if _npcId==nil then return end
    return _G.Cfg.scene_npc[_npcId]
end

--------------------------淫荡的分割线-----------------------
function TaskProxy.getScenesCopysNodeByCopyId(self, _copyId)
    if _copyId==nil then return end
    -- print("[getScenesCopysNodeByCopyId] _copyId=".._copyId)
    return _G.Cfg.scene_copy[_copyId]
end

--通过id读取 task_cnf数据  返回读取的节点
function TaskProxy.getTaskDataById(self, _taskId)
    if _taskId==nil then return end
    -- print("[getTaskDataById] taskId=".._taskId)
    return _G.Cfg.task[_taskId]
end

function TaskProxy.getSceneNode(self, _scene_id)
    if _scene_id==nil then return end
    return get_scene_data(_scene_id)
end

function TaskProxy.cleanMainTask(self)
    self.m_mainTask=nil
end
--设置主线追踪任务
function TaskProxy.setMainTask(self, _value)
    if _value==nil then
        local updateBtnCommand=CTaskMainCommand()
        controller:sendCommand(updateBtnCommand)
        return
    end

    if self.m_mainTask~=nil then
        if self.m_mainTask.id==_value.id then
            self.m_mainTask.current=_value.current
            self.m_mainTask.max    =_value.max

            if self.m_mainTask.state~=_value.state then
                self.m_mainTask.state=_value.state
                --更新任务指引按钮的图标
                local updateBtnCommand=CTaskMainCommand()
                controller :sendCommand(updateBtnCommand)
            end
            return
        end
    end

    self :cleanMainTask()

     print("当前追踪任务id==", _value.id, _value.state)
     local ccc=self:getTaskDataById(_value.id)
     if ccc==nil then
         print("tasks 表里没找到这个数据-->", _value.id)
         return
     end

     if self.m_mainTask==nil then
         self.m_mainTask={}
     end

     self.m_mainTask.id          =_value.id
     self.m_mainTask.target_type =_value.target_type
     self.m_mainTask.state       =_value.state
     self.m_mainTask.type        =_value.type
    
    local ss=ccc.npc.s
    local ee=ccc.npc.e
    -------------
    
    self.m_mainTask.beginNpc      =ss.npc
    self.m_mainTask.endNpc        =ee.npc
    self.m_mainTask.beginNpcScene =ss.scene   --开始npc的场景
    self.m_mainTask.endNpcScene   =ee.scene   --结束npc的场景
    self.m_mainTask.target_id     =nil

    if self.m_mainTask.target_type==_G.Const.CONST_TASK_TARGET_COPY then
        self.m_mainTask.copy_id=ccc.target_7.copy_id
        self.m_mainTask.current=_value.current
        self.m_mainTask.max    =_value.max
        self.m_mainTask.chapId =nil

        --设置要去的副本类型
        if self.m_mainTask.copy_id then
            local sceneCopys   =nil
            local sceneCopyNode=self :getScenesCopysNodeByCopyId(self.m_mainTask.copy_id)
            if sceneCopyNode then
                self.m_mainTask.chapId=sceneCopyNode.belong_id
            else
                local command=CErrorBoxCommand(string.format("任务:%d,副本ID%d不存在",_value.id,self.m_mainTask.copy_id))
                _G.controller:sendCommand(command)
                -- print("lua error..........>>  TaskProxy.setMainTask copy_id not found ",self.m_mainTask.copy_id)
            end
        else
            print("codeError!!!! TaskProxy.setMainTask copy_id==nil")
        end
    elseif self.m_mainTask.target_type==_G.Const.CONST_TASK_TARGET_OTHER then
        local _target_id=ccc.target_6.id
        if _target_id~=nil then
            self.m_mainTask.target_id=_target_id
        end
        self.m_mainTask.copy_id=nil
    else
        self.m_mainTask.copy_id=nil
    end

    --更新任务指引按钮的图标
    local updateBtnCommand=CTaskMainCommand()
    controller :sendCommand(updateBtnCommand)
end
function TaskProxy.getMainTask(self)
	return self.m_mainTask
end

--设置副本任务，主要用于完成副本任务自动寻路交任务
function TaskProxy.setCopyTask(self, _copyTask)
    self.m_copyTask=_copyTask
end
function TaskProxy.getCopyTask(self)
    return self.m_copyTask
end


--自动寻路信息
function TaskProxy.setAutoFindWayData(self, _npcId, _sceneId)
    if _npcId==nil and _sceneId==nil then
        self.m_autoFindWayList=nil
        return
    end
    self.m_autoFindWayList={}
    self.m_autoFindWayList.npcId  =_npcId
    self.m_autoFindWayList.sceneId=_sceneId
end
function TaskProxy.getAutoFindWayData(self)
    return self.m_autoFindWayList
end

--自动寻路
function TaskProxy.autoWayFinding(self, _npcId, _sceneId)
    if _sceneId==nil or _npcId==nil then return end

    local nNowSceneId=_G.g_Stage :getScenesID()
    if nNowSceneId==_sceneId then
        self :setAutoFindWayData()
        self :goNpcThere(_npcId, _sceneId)
    elseif nNowSceneId~=_sceneId then
        --如果不相等，先跑到当前场景的传送门
        self :goThisCityDoor(_npcId, _sceneId)
    end
end

--去这个npc
function TaskProxy.goNpcThere(self, _npcId, _sceneId)
    local sceneNode=self :getSceneNode(_sceneId)
    if not sceneNode then
        CCMessageBox("codeError!!!! task's question, please notice programmer!","scene_cnf")
        return
    end

    local npcPos=nil
    local sceneNpcList=sceneNode.npc or {}
    for i=1,#sceneNpcList do
        local npc=sceneNpcList[i]
        if npc.npc_id==_npcId then
            npcPos={x=npc.x,y=npc.y}
            break
        end
    end

    if npcPos==nil then
        CCMessageBox("codeError!!!! task's question, this npc disn't in this scene!","scene_cnf  npc")
        return
    end

    local pPosX,pPosY=_G.g_Stage :getMainPlayer() :getLocationXY()
    local distance=_G.Const.CONST_TASK_TALK_DISTANCE

    if math.abs(npcPos.x-pPosX)<=distance 
        and math.abs(npcPos.y-pPosY)<=distance then
        --直接打开
        -- _G.g_CAskTastDialogView:remove()
        _G.GLayerManager:openTaskDialog(_npcId)
        return
    end
    
    local realPos=self:getMoveToNpcRandomPos(npcPos)
    _G.g_Stage:getMainPlayer():findTaskNPC(realPos,_npcId)

    print("[寻路-去这个npc] ", realPos.x, realPos.y,"   npcId->",_npcId)
end

--去 能到这个主城的的传送门
function TaskProxy.goThisCityDoor(self, _npcId, _sceneId)
    --进入其他城市
    self.m_searchDoorList={}
    local curSceneId=_G.g_Stage:getScenesID()
    local nextDoor  =self:findNextSceneDoor(curSceneId, _sceneId)
    if nextDoor==nil then return end

    local doorPos={x=nextDoor.x,y=nextDoor.y}
    _G.g_Stage:getMainPlayer():setMovePos(doorPos)

    self:setAutoFindWayData(_npcId,_sceneId)
end

--查找要去的主城的最近传送门
function TaskProxy.findNextSceneDoor(self, _curSceneId, _goSceneId)
    print("findNextSceneDoor-->>", _curSceneId, _goSceneId)
    local sceneNode=self:getSceneNode(_curSceneId)
    if sceneNode==nil then return end

    local doorMapId   =_G.Const.CONST_MAP_DOOR_MAP
    local sceneDoorCnf=_G.Cfg.scene_door

    local doorList    =sceneNode.door or {}
    local saveDoorList={}
    local saveDoorCount= 0
    for i=1,#doorList do
        local door   =doorList[i]
        local doorId =door[1]
        local doorCnf=sceneDoorCnf[doorId]
        if doorCnf.type==doorMapId then
            --地图传送门
            local thisSceneId=doorCnf.transfer_id
            if thisSceneId==_goSceneId then
                door.x=door[2]
                door.y=door[3]
                return door
            elseif not self.m_searchDoorList[doorId] then
                --没有查询过的
                local myDoor={}
                myDoor.x=door[2]
                myDoor.y=door[3]
                myDoor.sceneId=thisSceneId
                saveDoorCount=saveDoorCount+1
                saveDoorList[saveDoorCount]=myDoor
                self.m_searchDoorList[doorId]=true
            end
        end
    end

    for i=1,saveDoorCount do
        local myDoor=saveDoorList[i]
        local nextDoor=self :findNextSceneDoor(myDoor.sceneId, _goSceneId)
        if nextDoor~=nil then
            --返回最近那个传送门
            return myDoor
        end
    end
end

--跑到副本传送门  直接跑
function TaskProxy.gotoCopyDoor(self)
    --进入副本
    print("TaskProxy.gotoCopyDoor--->进入副本")
    local curSceneId=_G.g_Stage :getScenesID()
    local sceneNode =self :getSceneNode(curSceneId)
    local doorPos   =nil
    local doorList  =sceneNode.door or {}
    for i,door in ipairs(doorList) do
        local doorCnf=_G.Cfg.scene_door[door[1]]
        if doorCnf.type==_G.Const.CONST_MAP_DOOR_OPEN then
            --副本传送门
            doorPos={x=door[2],y=door[3]}
            break
        end
    end

    if doorPos==nil then return end

    local rolePos =cc.p(_G.g_Stage:getMainPlayer():getLocationXY())
    local distance=cc.pGetDistance(rolePos, doorPos)

    print("TaskProxy.gotoCopyDoor-->", doorPos.x, doorPos.y, distance)
    if distance<80 then
        _G.GLayerManager :openLayer(Cfg.UI_CCopyMapLayer)
        return
    end
    _G.g_Stage:getMainPlayer():setMovePos(doorPos)
end

--拿到npc的随机位置
function TaskProxy.getMoveToNpcRandomPos(self, _pos)
    
    local pPosX,pPosY=_G.g_Stage:getMainPlayer():getLocationXY()
    local distance   =_G.Const.CONST_TASK_TALK_DISTANCE
    local movePosX   =_pos.x
    local maxY,minY  =_G.g_Stage:getMapLimitHeight(movePosX)
    maxY=maxY
    minY=maxY-distance+20
    minY=minY<(_pos.y-distance) and (_pos.y-distance)+10 or minY
    local movePosY   =minY
    if maxY>minY then
        movePosY=self :getRandomNum(minY, maxY)
    end

    if pPosX<_pos.x then
        --npc在右边
        movePosX=self :getRandomNum(_pos.x-distance+10, _pos.x+10)
    elseif pPosX>_pos.x then
        --npc在左边
        movePosX=self :getRandomNum(_pos.x-10, _pos.x+distance-10)
    end
    return {x=movePosX,y=movePosY}
end

function TaskProxy.getRandomNum(self, _startNum, _endNum)
    print("getRandomNum--->",_startNum,_endNum)
    local tm={ math.random(_startNum,_endNum),
                 math.random(_startNum,_endNum) 
                }
    return tm[2]
end

function TaskProxy.getNextMainTaskCnf(self)
    local myLv=_G.GPropertyProxy:getMainPlay():getLv()
    if self.m_nextTaskCnf~=nil and self.m_nextTaskLv==myLv then
        return self.m_nextTaskCnf
    end

    self.m_nextTaskCnf=nil
    self.m_nextTaskLv=nil

    local nextLv=myLv+1
    for k,v in pairs(_G.Cfg.task) do
        if v.type==_G.Const.CONST_TASK_TYPE_MAIN and v.lv==nextLv then
            self.m_nextTaskCnf=v
            self.m_nextTaskLv=myLv
            return v
        end
    end
end

--根据任务目标类型打开界面
function TaskProxy.goSomeViewByTargetId(self, _nTarget_id)
    print("goSomeViewByTargetId========>>>",_nTarget_id)
    if _nTarget_id==_G.Const.CONST_TASK_TO_PAY_FIRST then
        --首次充值
        _G.GLayerManager :delayOpenLayer(_G.Const.CONST_FUNC_OPEN_FIRST_GIFT)
    elseif _nTarget_id==_G.Const.CONST_TASK_TO_BUY then           
        --"加入社团" 特别  target_type==6 时
        _G.GLayerManager :delayOpenLayer(_G.Const.CONST_FUNC_OPEN_GANGS)
    elseif _nTarget_id==_G.Const.CONST_TASK_TO_MAKE then
        --打开打造界面
        _G.GLayerManager:openLayerByMapOpenId(_G.Const.CONST_MAP_SMITHY_QUALITY)
    elseif _nTarget_id==_G.Const.CONST_TASK_TO_STRENG
        or _nTarget_id==_G.Const.CONST_TASK_EQUIP_TON then
        --打开强化界面 or 装备强化到N级
        _G.GLayerManager:openLayerByMapOpenId(_G.Const.CONST_MAP_SMITHY)
    elseif _nTarget_id==_G.Const.CONST_TASK_TO_WASH then
        --打开洗练界面
        _G.GLayerManager:openLayerByMapOpenId(_G.Const.CONST_MAP_SMITHY_ENCHANTS)
    elseif _nTarget_id==_G.Const.CONST_TASK_INLIAD_GEMS then
        --镶嵌宝石
        _G.GLayerManager:openLayerByMapOpenId(_G.Const.CONST_MAP_SMITHY_INLAY)
    elseif _nTarget_id==_G.Const.CONST_TASK_TO_PET_FEED then
        --打开美人界面
        -- _G.GLayerManager :delayOpenLayer(_G.Const.CONST_FUNC_OPEN_PET)

        --新需求  跳到坐骑
        _G.GLayerManager :delayOpenLayer(_G.Const.CONST_FUNC_OPEN_MOUNT)
    elseif _nTarget_id==_G.Const.CONST_TASK_TO_MONEY then
        --打开招财
        _G.GLayerManager :delayOpenLayer(_G.Const.CONST_FUNC_OPEN_LUCKY)
    elseif _nTarget_id==_G.Const.CONST_TASK_TO_SANJIESHA then
        --挑战某BOSS
        _G.GLayerManager :delayOpenLayer(_G.Const.CONST_FUNC_OPEN_BOSS)
    elseif _nTarget_id==_G.Const.CONST_TASK_TO_ARENA then
        --打开竞技场
        _G.GLayerManager :delayOpenLayer(_G.Const.CONST_FUNC_OPEN_ARENA)
    elseif _nTarget_id==_G.Const.CONST_TASK_TO_PARTNER
        or _nTarget_id==_G.Const.CONST_TASK_PARTNER_TON then
        --打开伙伴 or --武将达到N级
        _G.GLayerManager :delayOpenLayer(_G.Const.CONST_FUNC_OPEN_PARTNER)
    elseif _nTarget_id==_G.Const.CONST_TASK_TO_BAQI then
        --打开霸气
        _G.GLayerManager :delayOpenLayer(_G.Const.CONST_FUNC_OPEN_SHEN)
    elseif _nTarget_id==_G.Const.CONST_TASK_TO_ZHENFA then
        --打开阵法
        _G.GLayerManager:openLayerByMapOpenId(_G.Const.CONST_MAP_ROLE_GOLD)
    elseif _nTarget_id==_G.Const.CONST_TASK_TO_ZHENBAO then
        --打开珍宝
        _G.GLayerManager :delayOpenLayer(_G.Const.CONST_FUNC_OPEN_JEWELLERY)
    elseif _nTarget_id==_G.Const.CONST_TASK_TO_SHENQI then
        --打开神器
        _G.GLayerManager :delayOpenLayer(_G.Const.CONST_FUNC_OPEN_ARTIFACT_OTHER,nil,303)
    -- elseif _nTarget_id==_G.Const.CONST_TASK_TO_TZMG then
    --     --打开挑战迷宫
    --     _G.GLayerManager :delayOpenLayer(_G.Const.CONST_FUNC_OPEN_FIGHT_SHOW)
    elseif _nTarget_id==_G.Const.CONST_TASK_TO_HLTB then
        --打开皇陵寻宝
        _G.GLayerManager :delayOpenLayer(_G.Const.CONST_FUNC_OPEN_EMPERORTOMB)
    elseif _nTarget_id==_G.Const.CONST_TASK_TO_KUGONG then
        --打开苦工
        _G.GLayerManager :delayOpenLayer(_G.Const.CONST_FUNC_OPEN_MOIL)
    -- elseif _nTarget_id==_G.Const.CONST_TASK_TO_HSMR then
    --     --打开护送美人
    --     _G.GLayerManager :delayOpenLayer(_G.Const.CONST_FUNC_OPEN_DEVIL_ESCORT)
    elseif _nTarget_id==_G.Const.CONST_TASK_MOU_TON
            or _nTarget_id==_G.Const.CONST_TASK_TO_HORSE then
        --坐骑达到N级
        _G.GLayerManager :delayOpenLayer(_G.Const.CONST_FUNC_OPEN_MOUNT)
    elseif _nTarget_id==_G.Const.CONST_TASK_SKILL_TON
            or _nTarget_id==_G.Const.CONST_TASK_TO_SKILL then
        --技能达到N级
        _G.GLayerManager:openLayerByMapOpenId(_G.Const.CONST_MAP_ROLE_SKILL)
    elseif _nTarget_id==_G.Const.CONST_TASK_BAOSHI_HECHENG then
        --宝石合成
        _G.GLayerManager:openLayerByMapOpenId(_G.Const.CONST_MAP_BAG_COMPOSE)
    elseif _nTarget_id==_G.Const.CONST_TASK_WUJIANG__ZHUANGBEI then
        --武将装备
        _G.GLayerManager :delayOpenLayer(_G.Const.CONST_FUNC_OPEN_ROLE)
    elseif _nTarget_id==_G.Const.CONST_TASK_JIHUO_CHENGHAO then
        --激活称号
        _G.GLayerManager:openLayerByMapOpenId(_G.Const.CONST_MAP_ROLE_TITLE)
    elseif _nTarget_id==_G.Const.CONST_TASK_LOOK_THROUGH then
        --翻翻乐
        _G.GLayerManager :delayOpenLayer(_G.Const.CONST_FUNC_OPEN_GAMBLE)
    elseif _nTarget_id==_G.Const.CONST_TASK_MONEY_TREE then
        --摇钱树
        _G.GLayerManager :delayOpenLayer(_G.Const.CONST_FUNC_OPEN_LUCKY)
    elseif _nTarget_id==_G.Const.CONST_TASK_RECEIVE_REWARD then
        --领取奖励
        _G.GLayerManager:openLayerByMapOpenId(_G.Const.CONST_MAP_REWARD_SIGN)
    elseif _nTarget_id==_G.Const.CONST_TASK_DAILY_TASKS then
        --日常任务
        _G.GLayerManager:openLayerByMapOpenId(_G.Const.CONST_MAP_TASK_DAILY)
    elseif _nTarget_id==_G.Const.CONST_TASK_DAILY_TURNTABLE then
        --每日转盘
        _G.GLayerManager :delayOpenLayer(_G.Const.CONST_FUNC_OPEN_TIME_TREASUREHUNT)
        -- _G.GLayerManager :delayOpenLayer(_G.Const.CONST_FUNC_OPEN_DAILY_TURNTABLE)
    elseif _nTarget_id==_G.Const.CONST_TASK_DAILY_ARROW then
        --每日一箭
        _G.GLayerManager :delayOpenLayer(_G.Const.CONST_FUNC_OPEN_TIME_SINGLE)
    elseif _nTarget_id==_G.Const.CONST_TASK_TO_XUNBAO then
        --全民寻宝
        _G.GLayerManager :delayOpenLayer(_G.Const.CONST_FUNC_OPEN_TIME_TREASUREHUNT)
    elseif _nTarget_id==_G.Const.CONST_TASK_TO_TEAM then
        --组队副本
        _G.GLayerManager :delayOpenLayer(_G.Const.CONST_FUNC_OPEN_TEAM)
    elseif _nTarget_id==_G.Const.CONST_TASK_TO_XIAKE then
        --侠客行
        _G.GLayerManager :delayOpenLayer(_G.Const.CONST_FUNC_OPEN_XKX)
    elseif _nTarget_id==_G.Const.CONST_TASK_TO_WUJINXINMO then
        --斗转星移
        _G.GLayerManager :delayOpenLayer(_G.Const.CONST_FUNC_OPEN_DEMONS)
    elseif _nTarget_id==_G.Const.CONST_TASK_TO_FUTU then
        --通天浮屠达到N层
        _G.GLayerManager :delayOpenLayer(_G.Const.CONST_FUNC_OPEN_TOWER)
    elseif _nTarget_id==_G.Const.CONST_TASK_TO_FUTU_FIGHT then
        --挑战通天浮屠N次
        _G.GLayerManager :delayOpenLayer(_G.Const.CONST_FUNC_OPEN_TOWER)
    elseif _nTarget_id==_G.Const.CONST_TASK_GOLDBODY_TON then
        --经脉修炼达到N级
        _G.GLayerManager :openLayerByMapOpenId(_G.Const.CONST_MAP_ROLE_GOLD)
    end
end

return TaskProxy

