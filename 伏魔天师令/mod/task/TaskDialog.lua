local WinSize=cc.Director:getInstance():getWinSize()
local ViewSize=cc.size(WinSize.width,202)
local NamePosX=270
local NamePosY=95
local SayPosY=ViewSize.height-55

local P_NPC_SIZE=cc.size(300,300)


local P_TYPE_CLOSE=-10
local P_TYPE_NOT_LEVEL=-9
local P_TYPE_WAIT=-5
local P_TYPE_GOON=_G.Const.CONST_TASK_DIALOG_TYPE0
local P_TYPE_SEND=_G.Const.CONST_TASK_DIALOG_TYPE1
local P_TYPE_SEND_ACCEPT=11
local P_TYPE_SEND_FINISH=12
local P_TYPE_BACK_ACCEPT=13
local P_TYPE_BACK_FINISH=14
local P_TYPE_WAIT_NEXT=15


local TaskDialog=classGc(view,function(self)
	self.m_mediator=require("mod.task.TaskDialogMediator")(self)

    self.m_myProperty=_G.GPropertyProxy:getMainPlay()
    self.m_myPro=self.m_myProperty:getPro()
    self.m_halfSprArray={}
    self.m_szNameArray={}
    self.m_resourcesArray={}
end)

function TaskDialog.create(self,_npcId,_isUserTouch)
	self.m_npcId=_npcId
	self.m_isUserTouch=_isUserTouch

	local function onTouchBegan()
        if self.m_rootLayer==nil then return end
        self:__touchCallBack()
        return true
    end
	local listerner=cc.EventListenerTouchOneByOne:create()
	listerner:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
	listerner:setSwallowTouches(true)

	self.m_rootLayer=cc.LayerColor:create(cc.c4b(0,0,0,0))
    self.m_rootLayer:runAction(cc.FadeTo:create(0.2,255*0.3))
	self.m_rootLayer:getEventDispatcher():addEventListenerWithSceneGraphPriority(listerner,self.m_rootLayer)

	self:init()
	return self.m_rootLayer
end

function TaskDialog.init(self)
	self:__initParams()
	self:__initTaskParams()
	self:__initView()
    _G.pmainView:hide()
end

function TaskDialog.__initParams(self)
    local npcName,npcSkin,npcSay=self:__getThisNpcParams(self.m_npcId)
    
    self.m_npcSkin = npcSkin or 1
    self.m_szSays  = npcSay or ""               --初始化随机说话
    -- self.m_szName  = npcName or "error"

    self.m_szNameArray[_G.Const.CONST_TASK_DIALOG_PLAYER]=self.m_myProperty:getName()
    self.m_szNameArray[_G.Const.CONST_TASK_DIALOG_NPC]=npcName or "error"

    -- self.m_szSays="接送i打手机丢了垃圾啊善良的骄傲了教案善良的我骄傲手机丢了阿拉斯加单位"
end
function TaskDialog.__getThisNpcParams(self,_npcId)
    local npcNode=_G.GTaskProxy:getNpcNodeById(_npcId)
    if npcNode==nil then
        local command=CErrorBoxCommand("no NPC found id:"..self.m_npcId)
        controller:sendCommand(command)
        return nil
    end
    return npcNode.npc_name,npcNode.head,npcNode.says1
end

function TaskDialog.__initTaskParams(self)
	--判断是否有任务
    self.m_preTaskInfo = self.m_taskInfo
    self.m_taskInfo    = {}
    if not _G.GTaskProxy:getInitialized() then
        return
    end

    local l_task_list = _G.GTaskProxy:getTaskDataList()
    if not l_task_list then 
        return
    end

    --查找该NPC的任务列表
    for i, value in ipairs( l_task_list ) do
        local taskNode = _G.GTaskProxy:getTaskDataById( value.id )
        if taskNode then
            local nBeginNpcId = taskNode.npc.s.npc
            local nEndNpcId   = taskNode.npc.e.npc
            
            if nBeginNpcId == self.m_npcId 
                and value.state <= _G.Const.CONST_TASK_STATE_UNFINISHED
                and value.state >= _G.Const.CONST_TASK_STATE_ACTIVATE then
                value.name  = taskNode.name
                value.lv    = taskNode.lv
                value.type  = taskNode.type
                value.interface = taskNode.interface
                self.m_taskInfo[ #self.m_taskInfo + 1 ] = value
            elseif  nEndNpcId == self.m_npcId and value.state == _G.Const.CONST_TASK_STATE_FINISHED then
                value.name  = taskNode.name
                value.lv    = taskNode.lv
                value.type  = taskNode.type
                value.interface = taskNode.interface
                self.m_taskInfo[ #self.m_taskInfo + 1 ] = value
            end
        end
    end

    --排序 两种方式
    if #self.m_taskInfo > 1 then
        if not self.m_isUserTouch then
            --寻路进来的 
            --排序方案：当前寻路的任务->主线(状态可接以上)->再到其他状态高的支线->不可接主线
            local currentTask = _G.GTaskProxy:getMainTask()
            local curTask     = nil
            local zhuXianTask = nil
            local ortherList  = {}
            local ortherCount = 0
            for i,v in ipairs(self.m_taskInfo) do
                local isSave = false
                if currentTask ~= nil then
                    if v.id == currentTask.id then
                        curTask = v
                        isSave = true
                    end
                end
                if isSave == false 
                    and v.type == _G.Const.CONST_TASK_TYPE_MAIN 
                    and v.state > _G.Const.CONST_TASK_STATE_ACTIVATE then
                    zhuXianTask = v
                    isSave = true
                end

                if isSave == false then
                    ortherCount=ortherCount+1
                    ortherList[ortherCount]=v
                end
            end

            local taskList = {}
            if curTask == nil and zhuXianTask == nil then
                taskList[1] = self.m_taskInfo[1]
                taskList[2] = self.m_taskInfo[2]
            elseif curTask ~= nil and zhuXianTask == nil then
                taskList[1] = curTask
                taskList[2] = ortherList[1]
            elseif curTask == nil and zhuXianTask ~= nil then
                taskList[1] = zhuXianTask
                taskList[2] = ortherList[1]
            else
                taskList[1] = curTask
                taskList[2] = zhuXianTask
            end

            self.m_taskInfo = taskList
        else
            --用户自己点的
            --排序方案：先可完成的任务->可接主线->可接支线->进行中主线->进行中支线
            local function local_ortherList_sort( value1, value2 )
                if value1.state == _G.Const.CONST_TASK_STATE_FINISHED
                    or value2.state == _G.Const.CONST_TASK_STATE_FINISHED then
                    if value1.state == value2.state then
                        if value1.type == value2.type then
                            return value1.type > value2.type
                        else
                            return value1.id < value2.id
                        end
                    else
                        return value1.state == _G.Const.CONST_TASK_STATE_FINISHED
                    end
                elseif value1.state == _G.Const.CONST_TASK_STATE_ACCEPTABLE
                    or value2.state == _G.Const.CONST_TASK_STATE_ACCEPTABLE then
                    if value1.state == value2.state then
                        if value1.type == value2.type then
                            return value1.type > value2.type
                        else
                            return value1.id < value2.id
                        end
                    else
                        return value1.state == _G.Const.CONST_TASK_STATE_ACCEPTABLE
                    end
                elseif value1.state == _G.Const.CONST_TASK_STATE_UNFINISHED
                    or value2.state == _G.Const.CONST_TASK_STATE_UNFINISHED then
                    if value1.state == value2.state then
                        if value1.type == value2.type then
                            return value1.type > value2.type
                        else
                            return value1.id < value2.id
                        end
                    else
                        return value1.state == _G.Const.CONST_TASK_STATE_UNFINISHED
                    end
                elseif value1.state == value2.state then
                    if value1.type == value2.type then
                        return value1.id < value2.id
                    else
                        return value1.type < value2.type
                    end
                else
                    return value1.state > value2.state
                end
            end
            --重新排序
            table.sort( self.m_taskInfo, local_ortherList_sort )

            local newList = {}
            newList[1] = self.m_taskInfo[1]
            newList[2] = self.m_taskInfo[2]
            self.m_taskInfo = newList
        end
    end

    --方便操作
    for i,task in ipairs(self.m_taskInfo) do
    	print("llllllllllllll---->>",i,task.id)
        self.m_taskInfo[task.id] = task
    end

    self.m_isUserTouch = nil
end

function TaskDialog.__initView(self)
    self.m_mainNode=cc.Node:create()
    self.m_rootLayer:addChild(self.m_mainNode)

    local upBackGround=ccui.Scale9Sprite:createWithSpriteFrameName("general_dialog_bg.png")
    upBackGround:setPosition(cc.p(ViewSize.width*0.5,WinSize.height-40))
    upBackGround:setPreferredSize(cc.size(ViewSize.width,ViewSize.height))
    upBackGround:setOpacity(0)
    upBackGround:setScaleY(-1)
    self.m_mainNode:addChild(upBackGround)

	local downBackGround=ccui.Scale9Sprite:createWithSpriteFrameName("general_dialog_bg.png")
	downBackGround:setPosition(cc.p(ViewSize.width*0.5,ViewSize.height*0.5))
	downBackGround:setPreferredSize(cc.size(ViewSize.width,ViewSize.height))
    downBackGround:setOpacity(0)
	self.m_mainNode:addChild(downBackGround)

	self.m_nameLabel=_G.Util:createLabel("",24)
    self.m_nameLabel:setOpacity(0)
    self.m_nameLabel:setAnchorPoint(cc.p(0,0.5))
    self.m_nameLabel:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GOLD))
	self.m_mainNode:addChild(self.m_nameLabel)

	self.m_sayLabel=_G.Util:createLabel("",22)
	self.m_sayLabel:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
	self.m_sayLabel:setDimensions(ViewSize.width - P_NPC_SIZE.width - 40,0)
    -- self.m_sayLabel:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_PALEGREEN))
    self.m_sayLabel:setOpacity(0)
    self.m_sayLabel:setAnchorPoint(cc.p(0,1))
	self.m_mainNode:addChild(self.m_sayLabel)

    local szImg=string.format("painting/1000%d.png",self.m_myProperty:getPro())
    local spr1=_G.ImageAsyncManager:createNormalSpr(szImg)
    spr1:setOpacity(0)
    -- spr1:setScale(0.7)
    spr1:setPosition(P_NPC_SIZE.width*0.5,P_NPC_SIZE.height*0.5)
    self.m_mainNode:addChild(spr1)

    self.m_resourcesArray[szImg]=szImg

    szImg=string.format("painting/%d.png",self.m_npcSkin)
    if not _G.FilesUtil:check(szImg) then
        szImg="painting/20031.png"
    end
    local spr2=_G.ImageAsyncManager:createNormalSpr(szImg)
    spr2:setOpacity(0)
    spr2:setScaleX(-1)
    spr2:setPosition(WinSize.width - P_NPC_SIZE.width*0.5,P_NPC_SIZE.height*0.5)
    self.m_mainNode:addChild(spr2)

    self.m_resourcesArray[szImg]=szImg

    self.m_halfSprArray[_G.Const.CONST_TASK_DIALOG_PLAYER]=spr1
    self.m_halfSprArray[_G.Const.CONST_TASK_DIALOG_NPC]=spr2

	local function c(sender, eventType)
        if eventType==ccui.TouchEventType.ended then
            self:closeWindow()
        end
    end
    local szNormal="general_view_close.png"
	local button=gc.CButton:create(szNormal)
	local btnSize=cc.size(70,70)
    button:setPosition(cc.p(ViewSize.width-btnSize.width*0.5,640-btnSize.height*0.5))
    button:addTouchEventListener(c)
    button:setSoundPath("bg/ui_sys_clickoff.mp3")
    button:ignoreContentAdaptWithSize(false)
    button:setContentSize(btnSize)
    button:setButtonScale(0.8)
    self.m_mainNode:addChild(button,10)

    local function fun()
        if #self.m_taskInfo==0 then
            self:__showContent(_G.Const.CONST_TASK_DIALOG_NPC,self.m_szSays,P_TYPE_CLOSE)
        else
            self:__loadNormalTask()
        end
    end
    local actionTimes=0.2
    downBackGround:runAction(cc.Sequence:create(cc.FadeTo:create(actionTimes,255),cc.CallFunc:create(fun)))
    upBackGround:runAction(cc.FadeTo:create(actionTimes,255))
end

function TaskDialog.__touchCallBack(self)
    print("__touchCallBack=======>>>>",self.m_touchType)
    if self.m_touchType==P_TYPE_CLOSE or self.m_touchType==P_TYPE_NOT_LEVEL then
        self:closeWindow()
    elseif self.m_touchType==P_TYPE_GOON then
        self:__showCurDialog()
    elseif self.m_touchType==P_TYPE_SEND then
        if self.m_curTaskData~=nil then
            local nState=self.m_curTaskData.state
            if nState==_G.Const.CONST_TASK_STATE_ACCEPTABLE then
                -- 接受任务
                local msg=REQ_TASK_ACCEPT()
                msg:setArgs(self.m_curTaskData.id)
                _G.Network:send(msg)
                self.m_sendType=P_TYPE_SEND_ACCEPT
            elseif nState==_G.Const.CONST_TASK_STATE_FINISHED then
                -- 提交任务
                _G.GTaskProxy:setMainTask(self.m_curTaskData)
                local msg=REQ_TASK_SUBMIT()
                msg:setArgs(self.m_curTaskData.id,0)
                _G.Network:send(msg)
                self.m_sendType=P_TYPE_SEND_FINISH
            elseif nState==_G.Const.CONST_TASK_STATE_UNFINISHED then
                _G.GTaskProxy:setMainTask(self.m_curTaskData)
                self:gotoTask()
            end
        else
            self:closeWindow()
        end
    end
end

function TaskDialog.__loadNormalTask(self)
    self.m_dialogPos=nil
    self.m_dialogCnf=nil
    self.m_curTaskData=nil
    self.m_touchType=nil
    self.m_sendType=nil

    print("[任务对话] __loadNormalTask===========>>>>>>")

    if #self.m_taskInfo==0 then
        self:closeWindow()
    else
        local curTask=self.m_taskInfo[1]
        self.m_curTaskData=curTask

        if curTask.state==_G.Const.CONST_TASK_STATE_ACTIVATE then
            self.m_curTaskData=nil
            self:__showContent(_G.Const.CONST_TASK_DIALOG_NPC,string.format("%d级再过来找我吧。",curTask.lv),P_TYPE_NOT_LEVEL,true)
            return
        elseif curTask.state==_G.Const.CONST_TASK_STATE_ACCEPTABLE then
            -- 可接
            self.m_dialogCnf=_G.Cfg.task[curTask.id].say_start
        elseif curTask.state==_G.Const.CONST_TASK_STATE_UNFINISHED then
            -- 接受未完成
            self.m_dialogCnf=_G.Cfg.task[curTask.id].say_ing
        elseif curTask.state==_G.Const.CONST_TASK_STATE_FINISHED then
            -- 接受未完成
            self.m_dialogCnf=_G.Cfg.task[curTask.id].say_end
        end
        if self.m_dialogCnf==nil or #self.m_dialogCnf==0 then
            self.m_dialogCnf=self:__getTestDialogData()
            local command=CErrorBoxCommand("没有配置对话")
            controller:sendCommand(command)
            -- self:closeWindow()
        else
            self:__checkDialogCnfReal(self.m_dialogCnf)
        end
        self:__showCurDialog()
    end
end
function TaskDialog.__checkDialogCnfReal(self,_dialogCnf)
    local hasTpye1=false
    for i=1,#_dialogCnf do
        if _dialogCnf[i].type==_G.Const.CONST_TASK_DIALOG_TYPE1 then
            if hasTpye1 then
                _dialogCnf[i].type=_G.Const.CONST_TASK_DIALOG_TYPE0
            end
            hasTpye1=true
        elseif _dialogCnf[i].type~=_G.Const.CONST_TASK_DIALOG_TYPE0 then
            _dialogCnf[i].type=_G.Const.CONST_TASK_DIALOG_TYPE0
        end
    end
    if not hasTpye1 then
        _dialogCnf[#_dialogCnf].type=_G.Const.CONST_TASK_DIALOG_TYPE1

        if self.m_curTaskData.state==_G.Const.CONST_TASK_STATE_ACCEPTABLE
            or self.m_curTaskData.state==_G.Const.CONST_TASK_STATE_FINISHED then
            local command=CErrorBoxCommand("该对话没有设置类型 1")
            controller:sendCommand(command)
        end
    end
end

function TaskDialog.__showCurDialog(self)
    if self.m_dialogCnf==nil then return end
    self.m_dialogPos=self.m_dialogPos or 0
    self.m_dialogPos=self.m_dialogPos+1

    local dialogData=self.m_dialogCnf[self.m_dialogPos]
    if dialogData==nil then
        if self.m_curTaskData.state==_G.Const.CONST_TASK_STATE_UNFINISHED then
            self:gotoTask()
        -- elseif self.m_curTaskData.state==_G.Const.CONST_TASK_STATE_FINISHED then
        elseif self.m_sendType==P_TYPE_BACK_FINISH then
            self:__checkNextTask()
        else
            self:__loadNormalTask()
        end
        return
    end

    self:__showContent(dialogData.id,dialogData.msg,dialogData.type)
end

function TaskDialog.__acceptBack(self,_taskId)
    if self.m_sendType==P_TYPE_SEND_ACCEPT then
        if self.m_curTaskData.id==_taskId then
            print("[任务对话] __acceptBack===========>>>>>>")
            self.m_sendType=P_TYPE_BACK_ACCEPT
            self:__showCurDialog()
        end
    else
        local function nDelayFun()
            self:__checkNextTask()
        end
        performWithDelay(self.m_mainNode,nDelayFun,1)
    end
end
function TaskDialog.__finishBack(self,_taskId)
    if self.m_sendType==P_TYPE_SEND_FINISH then
        if self.m_curTaskData.id==_taskId then
            print("[任务对话] __finishBack===========>>>>>>")
            self.m_sendType=P_TYPE_BACK_FINISH
            self:__showCurDialog()
        end
    else
        local function nDelayFun()
            self:__checkNextTask()
        end
        performWithDelay(self.m_mainNode,nDelayFun,1)
    end
end

function TaskDialog.__showContent(self,_id,_info,_type,_isRed)
    self.m_touchType=_type

    if _id~=_G.Const.CONST_TASK_DIALOG_PLAYER and _id~=_G.Const.CONST_TASK_DIALOG_NPC then
        -- CCMessageBox("对话id 填错。。","ERROR")
        -- local command=CErrorBoxCommand("该对话没有设置类型")
        -- controller:sendCommand(command)
        -- return
        local npcName,npcSkin,npcSay=self:__getThisNpcParams(_id)
        if npcName==nil then
            return
        end

        if self.m_halfSprArray[_id]==nil then
            local szImg=string.format("painting/%d.png",npcSkin)
            if not _G.FilesUtil:check(szImg) then
                szImg="painting/20031.png"
            end
            local tempNpcSpr=_G.ImageAsyncManager:createNormalSpr(szImg)
            tempNpcSpr:setOpacity(0)
            tempNpcSpr:setScaleX(-1)
            tempNpcSpr:setPosition(WinSize.width - P_NPC_SIZE.width*0.5,P_NPC_SIZE.height*0.5)
            self.m_mainNode:addChild(tempNpcSpr)

            self.m_halfSprArray[_id]=tempNpcSpr
            self.m_szNameArray[_id]=npcName

            self.m_resourcesArray[szImg]=szImg
        end
    end

    local talkSpr=self.m_halfSprArray[_id]
    local szName=self.m_szNameArray[_id]
    self.m_nameLabel:setString(szName)
    self.m_sayLabel:setString(_info)

    if _isRed then
        if not self.m_isSayRed then
            self.m_isSayRed=true
            self.m_sayLabel:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_RED))
        end
    elseif self.m_isSayRed then
        self.m_isSayRed=nil
        self.m_sayLabel:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_PALEGREEN))
    end

    -- talkSpr:setOpacity(255)
    talkSpr:stopAllActions()
    talkSpr:runAction(cc.FadeTo:create(0.1,255))
    for k,v in pairs(self.m_halfSprArray) do
        if k~=_id then
            v:stopAllActions()
            v:setOpacity(0)
        end
    end

    self.m_nameLabel:setOpacity(255)
    self.m_sayLabel:setOpacity(255)

    if _id==_G.Const.CONST_TASK_DIALOG_PLAYER then
        self.m_nameLabel:setPosition(P_NPC_SIZE.width,95)
        self.m_sayLabel:setPosition(P_NPC_SIZE.width,70)
    else
        self.m_nameLabel:setPosition(40,95)
        self.m_sayLabel:setPosition(40,70)
    end
end

function TaskDialog.__getTestDialogData(self)
    if self.m_textDialogArray==nil then
        self.m_textDialogArray={
            [1]={
                [1]={id=1,type=0,msg=[[<模板1> <2人对话4次> AAAAAAAAAAAAAAAAAAAAAAA]]},
                [2]={id=0,type=0,msg=[[<模板1> <2人对话4次> BBBBBBBBBBBBBB]]},
                [3]={id=1,type=0,msg=[[<模板1> <2人对话4次> CCCCCCCCCCCCCCCCCCCCCCCCCCCCCC]]},
                [4]={id=0,type=1,msg=[[<模板1> <2人对话4次> DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD]]}
            },
            [2]={
                [1]={id=1,type=0,msg=[[<模板2> <2人对话2次> AAAAAAAAAAAAAAAAAAAAAAA]]},
                [2]={id=0,type=1,msg=[[<模板2> <2人对话2次> BBBBBBBBBBB]]},
            },
            [3]={
                [1]={id=1,type=0,msg=[[<模板3> <3人对话4次> AAAAAAAAAAAAAAAAAAAAAAA]]},
                [1]={id=0,type=0,msg=[[<模板3> <3人对话4次> BBBBBBB]]},
                [1]={id=11001,type=0,msg=[[<模板3> <3人对话4次> CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC]]},
                [1]={id=1,type=1,msg=[[<模板3> <3人对话4次> DDDDDDDDDDDDDDDDD]]},
            },
            [4]={
                [1]={id=1,type=1,msg=[[<模板4> <1人对话1次> AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA]]},
            },
        }
    end
    
    return self.m_textDialogArray[math.ceil(4*gc.MathGc:random_0_1())]
end

function TaskDialog.__checkNextTask(self)
    self.m_touchType=P_TYPE_WAIT_NEXT
    print("[任务对话] __checkNextTask===========>>>>>> 1")
    local function local_checkHasOther()
        self:__initTaskParams()
        if #self.m_taskInfo>0 then
            self:__loadNormalTask()
        else
            self:closeWindow()
        end
        return
    end

    local function local_goAcceptTask()
        local taskArray=_G.GTaskProxy:getTaskDataList()
        for i=1,#taskArray do
            if taskArray[i].state==_G.Const.CONST_TASK_STATE_ACCEPTABLE then
                _G.GTaskProxy:setMainTask(taskArray[i])
                self:gotoTask()
                return
            end
        end
        self:closeWindow()
        -- if #taskArray>0 then
        --     _G.pmainView:getIconActivity():showTaskGuideEffect()
        -- end
    end

    if #self.m_taskInfo>1 then
        local_checkHasOther()
        return
    end

    print("[任务对话] __checkNextTask===========>>>>>> 2")
    local taskNode=_G.Cfg.task[self.m_curTaskData.id]
    if taskNode.next==0 then
        local_goAcceptTask()
        return
    end
    print("[任务对话] __checkNextTask===========>>>>>> 3")
    local nextNode=_G.Cfg.task[taskNode.next]
    if not nextNode then
        local_goAcceptTask()
        return
    end
    print("[任务对话] __checkNextTask===========>>>>>> 4")
    self.m_mainNode:stopAllActions()
    performWithDelay(self.m_mainNode,local_checkHasOther,0.3)
end

function TaskDialog.gotoTask(self)
    self:closeWindow()
    local command=CTaskDialogUpdateCommand(CTaskDialogUpdateCommand.GOTO_TASK)
    _G.controller:sendCommand(command)
end

function TaskDialog.closeWindow(self)
	if self.m_rootLayer==nil then return end

    print("TaskDialog.closeWindow==>>",debug.traceback())

    _G.pmainView:show()

	self:destroy()

    _G.ScenesManger.releaseFileArray(self.m_resourcesArray)

    local function nFun1(_node)
        _node:removeFromParent(true)
    end
    self.m_rootLayer:runAction(cc.Sequence:create(cc.DelayTime:create(0.01),cc.CallFunc:create(nFun1)))

    local function nFun2()
        _G.g_Stage.m_cancelTouch=nil
    end
    _G.Scheduler:performWithDelay(0.5,nFun2)
    _G.g_Stage.m_cancelTouch=true

    self.m_rootLayer=nil
end

function TaskDialog.setUpdateView(self,_taskId,_taskState)
    self.m_mainNode:stopAllActions()
    
    self:__initTaskParams()

    local function local_gotoTask()
        local currentTask=_G.GTaskProxy:getMainTask()

        if currentTask==nil then
            self:closeWindow()
            return
        end
        
        local task_type = currentTask.type
        local task_target_type = currentTask.target_type
        if task_type == _G.Const.CONST_TASK_TYPE_BRANCH 
            and task_target_type == _G.Const.CONST_TASK_TARGET_OTHER then
            --支线，不主动弹出对应界面
            self:closeWindow()
            -- _G.pmainView:getIconActivity():showTaskGuideEffect()
        else
            self:gotoTask()
        end
    end

    if #self.m_taskInfo==0 then
        if _taskState == _G.Const.CONST_TASK_STATE_FINISHED then
            local_gotoTask()
        else
            local mainTask=_G.GTaskProxy:getMainTask()
            if mainTask~=nil and mainTask.type==_G.Const.CONST_TASK_TYPE_MAIN and mainTask.state==_G.Const.CONST_TASK_STATE_ACCEPTABLE then
                -- 自动接下个主线任务
                self:gotoTask()
            else
                self:__checkNextTask()
                -- self:closeWindow()
                -- _G.pmainView:getIconActivity():showTaskGuideEffect()
            end
        end
        return
    end

    local curTask=self.m_taskInfo[1]
    if self.m_curTaskData~=nil and self.m_curTaskData.id~=curTask.id then
        if _taskId==self.m_curTaskData.id then
            local hasThisTask=nil
            for i=1,#self.m_taskInfo do
                local nTask=self.m_taskInfo[i]
                if nTask.id==_taskId then
                    hasThisTask=nTask
                end
            end
            if hasThisTask~=nil then
                if _taskState==_G.Const.CONST_TASK_STATE_UNFINISHED then
                    self.m_curTaskData=hasThisTask
                    self:__acceptBack(_taskId)
                    return
                end
            end
        end

        if curTask.state==_G.Const.CONST_TASK_STATE_ACTIVATE then
            local mainTask=_G.GTaskProxy:getMainTask()
            if mainTask.type==_G.Const.CONST_TASK_TYPE_BRANCH and mainTask.state==_G.Const.CONST_TASK_STATE_ACCEPTABLE then
                local function nFun()
                    self:gotoTask()
                end
                performWithDelay(self.m_mainNode,nFun,0.3)
                return
            end
        end
        print("WWWWWWWW========>>>>  222222")
        self:__loadNormalTask()
        return
    end
    self.m_curTaskData=curTask

    -- if self.m_curTaskData~=nil and curTask.id~=self.m_currentTaskId then
    --     --不同任务，重新显示可接任务
    --     self:__loadNormalTask()
    -- else
    if curTask.state == _G.Const.CONST_TASK_STATE_UNFINISHED then
        --接受任务
        if curTask.target_type ==_G.Const.CONST_TASK_TARGET_TALK then 
            --对话
            self:__acceptBack(_taskId)
        else
            if curTask.interface~=0 then
                if self.m_preTaskInfo == nil or (self.m_preTaskInfo[curTask.id].state ~= curTask.state) then
                    self :closeWindow()
                    -- _G.pmainView:getIconActivity():showTaskGuideEffect()
                    print("1 setUpdateView=======>>>>  ",curTask.interface)
                    _G.GLayerManager:openLayerByMapOpenId(curTask.interface)
                else
                    self:__acceptBack(_taskId)
                end
            else
                local_gotoTask()
            end
        end
    elseif curTask.state == _G.Const.CONST_TASK_STATE_FINISHED then
        --完成未提交
        if curTask.interface ~= 0 then
            if self.m_preTaskInfo == nil or (self.m_preTaskInfo[curTask.id].state ~= curTask.state) then
                self:closeWindow()
                -- _G.pmainView :getIconActivity():showTaskGuideEffect()
                print("2 setUpdateView=======>>>>  ",curTask.interface)
                _G.GLayerManager:openLayerByMapOpenId(curTask.interface)
            else
                self:__acceptBack(_taskId)
            end
        else
            self:__acceptBack(_taskId)
        end
    elseif curTask.state == _G.Const.CONST_TASK_STATE_ACCEPTABLE then
        -- or curTask.state == _G.Const.CONST_TASK_STATE_ACTIVATE then
        --激活、可接
        if self.m_touchType==P_TYPE_WAIT_NEXT or self.m_touchType==P_TYPE_NOT_LEVEL then
            self:__loadNormalTask()
        end
    else
        CCLOG("@@@@@@ >> 我操~~~ 怎么没有处理她？？")
        CCLOG("_taskId->%d",_taskId)
        CCLOG("_taskState->%d",_taskState)
        CCLOG("111 id->%d",curTask.id)
        CCLOG("111 state->%d",curTask.state)
        CCLOG("111 target_type->%d",curTask.target_type)
    end
end

function TaskDialog.removeTaskCallBack(self,_taskId)
    if not _taskId or not _G.Cfg.task[_taskId] then
        self :closeWindow()
        return
    end

    self:__finishBack(_taskId)
end

return TaskDialog
