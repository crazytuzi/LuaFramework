local wsysCommFunc = require("src/layers/weddingSystem/WeddingSysCommFunc")

local function onWeddingSysErrorRecv(luaBuffer)
    local retTable = g_msgHandlerInst:convertBufferToTable("MarriageError", luaBuffer)
    wsysCommFunc.showWeddingSysError(retTable.res)
    print("MarriageError --------------------------------------------------------------",retTable.res)
end

local function onFemaleRecvXunLiReq()
    local maleId = -1
    local function yesCallback()
        print("btn yes clicked")
        g_msgHandlerInst:sendNetDataByTableExEx(MARRIAGE_CS_TOUR_ANSWER, "MarriageTourAnswer", {res=0,maleSID=maleId})
    end
    local function noCallback()
        -- send proto
        print("btn no clicked")
        g_msgHandlerInst:sendNetDataByTableExEx(MARRIAGE_CS_TOUR_ANSWER, "MarriageTourAnswer", {res=1,maleSID=maleId})
    end
    local function onXunLiReqReci(luaBuffer)
        print("MARRIAGE_SC_TOUR_ASK received ................................................")
        if MRoleStruct:getAttr(PLAYER_SEX) ~= 1 then
            print("MARRIAGE_SC_TOUR_ASK dealed ................................................")
            local retTable = g_msgHandlerInst:convertBufferToTable("MarriageTourAsk", luaBuffer)
            maleId = retTable.maleSID
            MessageBoxYesNoEx(game.getStrByKey("tip"),game.getStrByKey("wdsys_xunliTip1"),yesCallback,noCallback,game.getStrByKey("wdsys_btnYes"),game.getStrByKey("wdsys_btnNo"),false,true,30,3)
        end
    end
    g_msgHandlerInst:registerMsgHandler( MARRIAGE_SC_TOUR_ASK , onXunLiReqReci )
    print("MARRIAGE_SC_TOUR_ASK registe ................................................")
end

local function onXunLiResGet()
    local function onXunLiResRecv(luaBuffer)
        local retTable = g_msgHandlerInst:convertBufferToTable("MarriageTourResult", luaBuffer)
        print("on xunli res recv ...............................................................")
        if retTable.res == 0 then
            -- success
            print("xunli success ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")
            local xlMissonlayer = require("src/layers/weddingSystem/XunLiMissionLayer").new()
            getRunScene():addChild(xlMissonlayer)
        else    
            -- fail
            print("xunli fail ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")
            MessageBox(game.getStrByKey("wdsys_notReady"))
        end
        wsysCommFunc.removeMaleCancellXunLiMessageBox()
    end
    g_msgHandlerInst:registerMsgHandler( MARRIAGE_SC_TOUR_RESULT , onXunLiResRecv )
end

local function onSubMissionFinish(luaBuffer)
    local retTable = g_msgHandlerInst:convertBufferToTable("MarriageSCFinishTask", luaBuffer)
    print("on subMission finish:------------------------------------------ ",retTable.taskType,retTable.taskStep,retTable.nextType,retTable.nextStep)
    if retTable.taskType ~= retTable.nextType then
        -- goto yuelao npc talk
        wsysCommFunc.xunliMissionData = {["curTaskId"]=retTable.taskType,["curSubTaskId"]=retTable.taskStep,["curTaskStatus"]=1}
    else
        wsysCommFunc.xunliMissionData = {["curTaskId"]=retTable.nextType,["curSubTaskId"]=retTable.nextStep,["curTaskStatus"]=0}
    end
    wsysCommFunc.refreshLeftMissionBoard()
    wsysCommFunc.taskClickCallBack()
end

local function onWeddingStatusRecv(luaBuffer)
    local retTable = g_msgHandlerInst:convertBufferToTable("MarriageInfo", luaBuffer)
    local maleId = retTable.maleSID
    local femaleId = retTable.femaleSID
    local weddingStatus = retTable.status
    local xunLiStatus = retTable.tourinfo
    local weddingOpenedStatus = retTable.weddingStatus
    print("=====================================")
    print("maleId",maleId,femaleId,weddingStatus)
    print("=====================================")
    --wsysCommFunc.WeddingStatus.BEFORE_XUNLI
    wsysCommFunc.maleId = maleId
    wsysCommFunc.femaleId = femaleId
    wsysCommFunc.weddingStatus = weddingStatus
    wsysCommFunc.weddingOpenedStatus = weddingOpenedStatus
    wsysCommFunc.marriageID = retTable.marriageID
    print("wsysCommFunc.weddingOpenedStatus =============================== ",wsysCommFunc.weddingOpenedStatus)
    
    local statusData = xunLiStatus[1]
    wsysCommFunc.xunliMissionData.curTaskId = statusData.taskType
    wsysCommFunc.xunliMissionData.curSubTaskId = statusData.taskStep
    wsysCommFunc.xunliMissionData.curTaskStatus = statusData.status

    print("wsysCommFunc.xunliMissionData.curTaskStatus:",wsysCommFunc.xunliMissionData.curTaskStatus)
    wsysCommFunc.refreshLeftMissionBoard()
end

local function onMissionMonsterKillNumRecv(luaBuffer)
    print("-------------------------------cur monster killed----------------------------------------")
    local retTable = g_msgHandlerInst:convertBufferToTable("MarriageTourTaskUpdateStatus", luaBuffer)
    wsysCommFunc.setKilledMosnterNum(retTable.count)
    print("wsysCommFunc.curMonsterKilledNum:",wsysCommFunc.curMonsterKilledNum)
end

local function onXunLiAllMissionFinish(luaBuffer)
    print("-------------------------------on xunli all mission finish----------------------------------------")
    local retTable = g_msgHandlerInst:convertBufferToTable("MarriageSCTourTaskFinish", luaBuffer)
    wsysCommFunc.showAllMissionFinishConfirm()
end

local function onXunLiFinishConfirmFinish(luaBuffer)
    local retTable = g_msgHandlerInst:convertBufferToTable("MarriageSCEnterCeremony", luaBuffer)
    print("-------------------------------on xunli finish confirm finsih---------------------------------------")
    if retTable.res == 0 then
        -- success
        TIPS({str=game.getStrByKey("wdsys_xunliConfirm_FinishSuccess"),type=1})
        wsysCommFunc.setXunLiUniqueLayer(nil)
        --wsysCommFunc.weddingStatus = 3
    else
        -- fail
        if not wsysCommFunc.weddingSysLayers.stillNeedConsider then
            TIPS({str=game.getStrByKey("wdsys_xunliConfirm_FinishFail"),type=1})
            wsysCommFunc.weddingSysLayers.stillNeedConsider = false
        end
        wsysCommFunc.setXunLiUniqueLayer(nil)
    end 
    wsysCommFunc.refreshLeftMissionBoard()
end

local function onWaitOtherOneNoticeRecv(luaBuffer)
    local retTable = g_msgHandlerInst:convertBufferToTable("MarriageSCEnterCeremonyWait", luaBuffer)
    print("-------------------------------onWaitOtherOneNoticeRecv---------------------------------------")
    wsysCommFunc.showWaitConfirmBox()
end

local function onWeddingCeremonyFinish(luaBuffer)
    local retTable = g_msgHandlerInst:convertBufferToTable("MarriageSCArriaveCeremonyPoint", luaBuffer)
    print("-------------------------------MarriageSCArriaveCeremonyPoint---------------------------------------")
    wsysCommFunc.addOrDeleteAutoPlayLayer(true)
    wsysCommFunc.weddingStatus = 3
end

local function onWeddingCarStartMove(luaBuffer)
    local retTable = g_msgHandlerInst:convertBufferToTable("MarriageSCWeddingCarStart", luaBuffer)
    local wCarId = retTable.targetID
    wsysCommFunc.weddingCarId = wCarId
    print("onWeddingCarStartMove wedding car id ===================================== ",wsysCommFunc.weddingCarId)

    local wCar = require("src/layers/weddingSystem/RoleGoWithWeddingCar").new()
    wCar:beginGoWith()
end

local function onWeddingCarStopMove(luaBuffer)
    local retTable = g_msgHandlerInst:convertBufferToTable("MarriageSCWeddingCarStop", luaBuffer)
end

local function onWeddingCarDisapear(luaBuffer)
    local retTable = g_msgHandlerInst:convertBufferToTable("MarriageSCWeddingCarFini", luaBuffer)
end

local function onWeddingKindRecv(luaBuffer)
    local retTable = g_msgHandlerInst:convertBufferToTable("MarriageSCStartWeddingSucc", luaBuffer)
    print("-------------------------------MarriageSCStartWeddingSucc---------------------------------------")
    wsysCommFunc.weddingOpenedStatus = 1
end

g_msgHandlerInst:registerMsgHandler( MARRIAGE_SC_ERROR , onWeddingSysErrorRecv )
onFemaleRecvXunLiReq()
onXunLiResGet()
g_msgHandlerInst:registerMsgHandler( MARRIAGE_SC_FINISH_TASK , onSubMissionFinish )
g_msgHandlerInst:registerMsgHandler( MARRIAGE_INFO , onWeddingStatusRecv )
g_msgHandlerInst:registerMsgHandler( MARRIAGE_TOUR_TASK_UPDATE_STATUS , onMissionMonsterKillNumRecv )
g_msgHandlerInst:registerMsgHandler( MARRIAGE_SC_TOUR_TASK_FINISH , onXunLiAllMissionFinish )
g_msgHandlerInst:registerMsgHandler( MARRIAGE_SC_ENTER_CEREMONY , onXunLiFinishConfirmFinish )
g_msgHandlerInst:registerMsgHandler( MARRIAGE_SC_ENTER_CEREMONY_WAIT , onWaitOtherOneNoticeRecv )
g_msgHandlerInst:registerMsgHandler( MARRIAGE_SC_ARRIAVE_CEREMONY_POINT , onWeddingCeremonyFinish )
g_msgHandlerInst:registerMsgHandler( MARRIAGE_SC_WEDDING_CAR_START , onWeddingCarStartMove )
g_msgHandlerInst:registerMsgHandler( MARRIAGE_SC_WEDDING_CAR_STOP , onWeddingCarStopMove )
g_msgHandlerInst:registerMsgHandler( MARRIAGE_SC_WEDDING_CAR_FINI , onWeddingCarDisapear )
g_msgHandlerInst:registerMsgHandler( MARRIAGE_SC_START_WEDDING_SUCC , onWeddingKindRecv )

------------------------------------------------------------------------------------------
local function onDialogMsgRecv(luaBuffer)
    print("MARRIAGE_SC_WEDDING_INVITATION_INFO recv ........................................................")
    local retTable = g_msgHandlerInst:convertBufferToTable("MarriageSCWeddingInvitationInfo", luaBuffer)
    local rId = retTable.roleID
    local mId = retTable.marriageID
    local mName = retTable.maleName
    local fName = retTable.femaleName
    wsysCommFunc.showTransformDialog(mId,mName,fName)
end
g_msgHandlerInst:registerMsgHandler( MARRIAGE_SC_WEDDING_INVITATION_INFO , onDialogMsgRecv )

local function onKickOutSomeOneRecv(luaBuffer)
    print("onKickOutSomeOneRecv recv ........................................................")
    local retTable = g_msgHandlerInst:convertBufferToTable("MarriageSCWeddingKickOut", luaBuffer)
    local textCon = game.getStrByKey("wdsys_kickedOut")
    if retTable.roleSID == userInfo.currRoleStaticId then
        textCon = string.format(textCon,game.getStrByKey("wdsys_self"))
    else
        textCon = string.format(textCon,retTable.roleName)
    end
    MessageBox( textCon )
end
g_msgHandlerInst:registerMsgHandler( MARRIAGE_SC_WEDDING_KICKOUT , onKickOutSomeOneRecv )

local function onWeddingSceneInfoRecv(luaBuffer)
    print("onWeddingSceneInfoRecv recv ........................................................")
    local retTable = g_msgHandlerInst:convertBufferToTable("MarriageSCWeddingVenueInfo", luaBuffer)
    
    wsysCommFunc.wdSceneXQPJData = retTable.playInfo
    wsysCommFunc.wdSceneLMHBLYSData = retTable.ambienceInfo

    wsysCommFunc.wdSceneMaleId = retTable.maleSID
    wsysCommFunc.wdSceneFemaleId = retTable.femaleSID

    wsysCommFunc.wdSceneMarriageId = retTable.marriageID
end
g_msgHandlerInst:registerMsgHandler( MARRIAGE_SC_WEDDING_VENUE_INFO , onWeddingSceneInfoRecv )

print("weddingSysMsgHandler call backs called ")