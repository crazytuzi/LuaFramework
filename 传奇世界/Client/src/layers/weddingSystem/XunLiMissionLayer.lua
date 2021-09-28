local XunLiMissionLayer = class("XunLiMissionLayer", function () return cc.Layer:create() end )

XunLiMissionLayer.FLOWERKIND = 
{
    ["FEIWU"] = 1,
    ["CHIRE"] = 2,
    ["PANSHI"] = 3
}

XunLiMissionLayer.MISSIONSTATUS = 
{
    ["FINISH"] = 1,
    ["DOING"] = 2,
    ["NOTSTART"] = 3,
}

XunLiMissionLayer.taskId = nil
XunLiMissionLayer.subTaskId = nil
XunLiMissionLayer.taskStatus = nil

XunLiMissionLayer.wsysCommFunc = nil

function XunLiMissionLayer:ctor()

    self.wsysCommFunc = require("src/layers/weddingSystem/WeddingSysCommFunc")

    local bg = createSprite(self,"res/weddingSystem/yuelaobg.png",cc.p(display.cx,display.cy), cc.p(0.5,0.5))

    local closeLayer = function()
        self:removeSelf()
    end
    registerOutsideCloseFunc( bg , closeLayer , true , false ) 

    local close_item = createTouchItem(bg, "res/component/button/X.png", cc.p(950,480), closeLayer, nil)
	close_item:setLocalZOrder(500)

    self:getMissionData(bg)

    self:unregisterNetWorkCallBack()
end

function XunLiMissionLayer:getMissionData(bg)

    local function onMissionDataRecv(luaBuffer)
        local retTable = g_msgHandlerInst:convertBufferToTable("MarriageSCCurTask", luaBuffer)
        local taskId = retTable.taskType
        local subTaskId = retTable.taskStep
        local status = retTable.status
        -------------------------------------------------------
        self.taskId = taskId
        self.subTaskId = subTaskId
        self.taskStatus = status
        self.wsysCommFunc.xunliMissionData = {["curTaskId"]=taskId,["curSubTaskId"]=subTaskId,["curTaskStatus"]=status}
        -------------------------------------------------------
        print("cur taskid, subTaskId status ============================================================",taskId,subTaskId,status)
        local fwStatus = self.MISSIONSTATUS.NOTSTART
        local crStatus = self.MISSIONSTATUS.NOTSTART
        local psStatus = self.MISSIONSTATUS.NOTSTART
        if taskId == 0 then    
        elseif taskId == 1 then
            fwStatus = self.MISSIONSTATUS.DOING
            crStatus = self.MISSIONSTATUS.NOTSTART
            psStatus = self.MISSIONSTATUS.NOTSTART
        elseif taskId == 2 then
            fwStatus = self.MISSIONSTATUS.FINISH
            crStatus = self.MISSIONSTATUS.DOING
            psStatus = self.MISSIONSTATUS.NOTSTART
        elseif taskId == 3 then
            fwStatus = self.MISSIONSTATUS.FINISH
            crStatus = self.MISSIONSTATUS.FINISH
            psStatus = self.MISSIONSTATUS.DOING
        end

        if (taskId == 3 and status == 1) or (status == 2) then
            fwStatus = self.MISSIONSTATUS.FINISH
            crStatus = self.MISSIONSTATUS.FINISH
            psStatus = self.MISSIONSTATUS.FINISH
        end

        local feiwu = self:addItemByStatus(self.FLOWERKIND.FEIWU,fwStatus)
        bg:addChild(feiwu)

        local chire = self:addItemByStatus(self.FLOWERKIND.CHIRE,crStatus)
        bg:addChild(chire)

        local panshi = self:addItemByStatus(self.FLOWERKIND.PANSHI,psStatus)
        bg:addChild(panshi)
    
        self:addButtons(bg,fwStatus,psStatus)

        self.wsysCommFunc:refreshLeftMissionBoard()
    end
    g_msgHandlerInst:sendNetDataByTableExEx(MARRIAGE_CS_TOUR_CUR_TASK, "MarriageCSCurTask", {})
    g_msgHandlerInst:registerMsgHandler( MARRIAGE_SC_TOUR_CUR_TASK , onMissionDataRecv )
    print("MarriageCSCurTask send +++++++++++++++++++++++++++++++++++++++++++++++++++++++++")

end

function XunLiMissionLayer:addButtons(bg,fwStatus,psStatus)
    local function onMissionGiveUpRecv(args)
        --local retTable = g_msgHandlerInst:convertBufferToTable("MarriageTourTaskGiveUp", luaBuffer)
        TIPS({type=1,str=game.getStrByKey("wdsys_giveupXunLi")})
        self.wsysCommFunc.recoverXunLiData()
        self.wsysCommFunc.refreshLeftMissionBoard()
        self:removeSelf()
    end
    local function onGiveUpBtnClicked()
        print("giveup button clicked")
        g_msgHandlerInst:sendNetDataByTableExEx(MARRIAGE_CS_TOUR_TASK_GIVEUP, "MarriageTourTaskGiveUpReq", {})
        g_msgHandlerInst:registerMsgHandler( MARRIAGE_SC_TOUR_TASK_GIVEUP , onMissionGiveUpRecv )
    end
    local function giveUpBtnFunc()
        MessageBoxYesNo(game.getStrByKey("wdsys_xunliTitle"),game.getStrByKey("wdsys_giveUpConfirm"),onGiveUpBtnClicked,nil)
	end
	local xlBtn = createMenuItem(bg, "res/component/button/50.png", cc.p(850, 100), giveUpBtnFunc)
    createLabel(xlBtn,game.getStrByKey("wdsys_btnGiveUp"),cc.p(68,30),cc.p(0.5,0.5),22,nil,nil,nil,MColor.lable_yellow)


    local function onCurMissionRecv(luaBuffer)
        local retTable = g_msgHandlerInst:convertBufferToTable("MarriageSCTask", luaBuffer)
        local missionId = retTable.taskType
        local subMissionId = retTable.taskStep
        print("missionId & subMissionId :",missionId,subMissionId)
        self.wsysCommFunc.doMissionWithIds(missionId,subMissionId)
        self.wsysCommFunc.refreshLeftMissionBoard()
        self:removeSelf()
    end
    local function goOnBtnFunc()

        print("go on button clicked")
        if (self.taskId and self.taskId >0) and (self.subTaskId and self.subTaskId>0) and self.taskStatus == 0 then
            print("cur task is unfinish .........................................................")
            self.wsysCommFunc.doMissionWithIds(self.taskId,self.subTaskId)
            self:removeSelf()
            return
        end
        if psStatus == self.MISSIONSTATUS.FINISH then
            print("all mision finished .........................................................")
            g_msgHandlerInst:sendNetDataByTableExEx(MARRIAGE_CS_TOUR_TASK_FINISH, "MarriageTourTaskFinish", {})
            self:removeSelf()
            return
        end
        g_msgHandlerInst:sendNetDataByTableExEx(MARRIAGE_CS_RECV_TASK, "MarriageCSRecvTask", {})
        g_msgHandlerInst:registerMsgHandler( MARRIAGE_SC_TASK , onCurMissionRecv )

	end
	local xlBtn = createMenuItem(bg, "res/component/button/50.png", cc.p(530, 100), goOnBtnFunc)
    local goOnLabel = createLabel(xlBtn,game.getStrByKey("wdsys_getMissionBtn"),cc.p(68,30),cc.p(0.5,0.5),22,nil,nil,nil,MColor.lable_yellow)
    if fwStatus ~= self.MISSIONSTATUS.NOTSTART then
        goOnLabel:setString(game.getStrByKey("wdsys_btnGoOnMission"))
    end
    if psStatus == self.MISSIONSTATUS.FINISH then
        goOnLabel:setString(game.getStrByKey("wdsys_btnCommitMission"))
    end

end

function XunLiMissionLayer:addItemByStatus(flowerkind,status)
    -- feiwu chire panshi 1 wancheng 2 weiwancheng
    local s9bg
    local s9Pos
    local flowerResName
    local flowerName
    local flowerContent = ""
    if flowerkind == self.FLOWERKIND.FEIWU then
        s9Pos = cc.p(690,390)
        flowerName = game.getStrByKey("wdsys_feiwuName")
        flowerContent = game.getStrByKey("wdsys_feiwuContent")
        if status == self.MISSIONSTATUS.FINISH then
            s9bg = "res/weddingSystem/yellowbg.png"
            flowerResName = "res/weddingSystem/feiwuflower1.png"
        elseif status == self.MISSIONSTATUS.DOING then
            s9bg = "res/weddingSystem/greenbg.png"
            flowerResName = "res/weddingSystem/feiwuflower2.png"
        elseif status == self.MISSIONSTATUS.NOTSTART then
            s9bg = "res/weddingSystem/yellowbg.png"
            flowerResName = "res/weddingSystem/feiwuflower2.png"
        end
    elseif flowerkind == self.FLOWERKIND.CHIRE then
        s9Pos = cc.p(690,285)
        flowerName = game.getStrByKey("wdsys_chireName")
        flowerContent = game.getStrByKey("wdsys_chireContent")
        if status == self.MISSIONSTATUS.FINISH then
            s9bg = "res/weddingSystem/yellowbg.png"
            flowerResName = "res/weddingSystem/chireflower1.png"
        elseif status == self.MISSIONSTATUS.DOING then
            s9bg = "res/weddingSystem/greenbg.png"
            flowerResName = "res/weddingSystem/chireflower2.png"
        elseif status == self.MISSIONSTATUS.NOTSTART then
            s9bg = "res/weddingSystem/yellowbg.png"
            flowerResName = "res/weddingSystem/chireflower2.png"
        end
    elseif flowerkind == self.FLOWERKIND.PANSHI then
        flowerName = game.getStrByKey("wdsys_panshiName")
        flowerContent = game.getStrByKey("wdsys_panshiContent")
        s9Pos = cc.p(690,180)
        if status == self.MISSIONSTATUS.FINISH then
            s9bg = "res/weddingSystem/yellowbg.png"
            flowerResName = "res/weddingSystem/panshiflower1.png"
        elseif status == self.MISSIONSTATUS.DOING then
            s9bg = "res/weddingSystem/greenbg.png"
            flowerResName = "res/weddingSystem/panshiflower2.png"
        elseif status == self.MISSIONSTATUS.NOTSTART then
            s9bg = "res/weddingSystem/yellowbg.png"
            flowerResName = "res/weddingSystem/panshiflower2.png"
        end
    end

    local s9 = cc.Scale9Sprite:create(s9bg)
    s9:setContentSize(cc.size(499,100))
    s9:setAnchorPoint(cc.p(0.5,0.5))
    s9:setCapInsets(cc.rect(20,20,24,24))
    s9:setPosition(s9Pos)
    createSprite(s9,flowerResName,cc.p(60,46),cc.p(0.5,0.5))
    createLabel(s9,flowerName,cc.p(140,70),cc.p(0,0.5),22,nil,nil,nil,MColor.brown)
    createLabel(s9,flowerContent,cc.p(140,32),cc.p(0,0.5),20,nil,nil,nil,MColor.brown)
    if status == self.MISSIONSTATUS.FINISH then
        --createSprite(s9,"",cc.p(430,50),cc.p(0.5,0.5))
        createLabel(s9,game.getStrByKey("wdsys_finishMissionBtn"),cc.p(430,50),cc.p(0.5,0.5),22,nil,nil,nil,MColor.red)
    elseif status == self.MISSIONSTATUS.DOING then
        createLabel(s9,game.getStrByKey("wdsys_missionDoing"),cc.p(430,50),cc.p(0.5,0.5),22,nil,nil,nil,MColor.green)
    elseif status == self.MISSIONSTATUS.NOTSTART then
        createLabel(s9,game.getStrByKey("wdsys_missionNotStart"),cc.p(430,50),cc.p(0.5,0.5),22,nil,nil,nil,MColor.red)
    end
    local function touchCallBack()
        print("touch call back")
    end
    addTouchEventListen(s9,touchCallBack)
    return s9
end

function XunLiMissionLayer:unregisterNetWorkCallBack()
    local function eventCallback(eventType)
        if eventType == "exit" then
            g_msgHandlerInst:registerMsgHandler( MARRIAGE_SC_TOUR_CUR_TASK , nil )  
            g_msgHandlerInst:registerMsgHandler( MARRIAGE_SC_TOUR_TASK_GIVEUP , nil )  
            g_msgHandlerInst:registerMsgHandler( MARRIAGE_SC_TASK , nil )  
        end
    end
     self:registerScriptHandler(eventCallback)
end

function XunLiMissionLayer:removeSelf()
    self.wsysCommFunc.weddingSysLayers.xunliUniqueLayer = nil
    self:removeFromParent()
end

return XunLiMissionLayer