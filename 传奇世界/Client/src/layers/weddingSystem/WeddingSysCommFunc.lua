local WeddingSysCommFunc = class("WeddingSysCommFunc", function () return cc.Layer:create() end )

WeddingSysCommFunc.WeddingSysErrorCodeSwitch = {
    [1] = "wdsys_err_unno",
    [2] = "wdsys_err_mem",
    [3] = "wdsys_err_xunli",
    [4] = "wdsys_err_mem",
    [5] = "wdsys_err_lvl",
    [6] = "wdsys_err_mem",
    [7] = "wdsys_distanceTooFar",
    [8] = "wdsys_err_zudui",
    [9] = "wdsys_err_missionAllComplete",
    [30] = "wdsys_err_unmarried",
    [31] = "wdsys_err_weddingOpend",
    [32] = "wdsys_err_yuanbaoNotEnough",
    [33] = "wdsys_err_packageFull",
    [34] = "wdsys_err_peopleSoMany",
    [60] = "wdsys_err_fullPeople",
    [61] = "wdsys_err_levelNotEnough",
    [62] = "wdsys_err_kickOut",
    [63] = "wdsys_err_enterSelfScene",
    [64] = "wdsys_err_weddingNotOpen",
    [65] = "wdsys_err_weddingFinished",
    [66] = "wdsys_err_weddingNotOpen",
    [67] = "wdsys_err_weddingFinished",
    [68] = "wdsys_err_redPacket",
    [69] = "wdsys_err_weddingNotOpen",
    [70] = "wdsys_err_weddingFinished",
    [71] = "wdsys_err_notInWeddingScene",
    [72] = "wdsys_err_yuanbaoNotEnough",
    [73] = "wdsys_err_cutYuanbao",
    [74] = "wdsys_err_redPacketSended",
    [75] = "wdsys_err_weddingFinished",
    [76] = "wdsys_err_weddingNotOpen",
    [77] = "wdsys_err_kickOutSomeOne",
    [78] = "wdsys_err_weddingFinished",
    [79] = "wdsys_err_weddingNotOpen",
    [300] = "wdsys_err_weddingFinished",
    [301] = "wdsys_err_weddingFinished",
    [302] = "wdsys_err_weddingNotOpen",
    [303] = "wdsys_err_weddingNotOpen",
    --[304] = "",
    --[305] = "",
    [306] = "wdsys_err_weddingCarNotExist",
    [87] = "wdsys_err_weddingFinished",
    [81] = "wdsys_err_weddingFinished",
    [83] = "wdsys_wafaCanNotOpen",
    [84] = "wdsys_waitJiaBin",
}

WeddingSysCommFunc.WeddingStatus = 
{
    ["BEFORE_XUNLI"]      = 1,
    ["XUNLI_ING"]         = 2,
    ["XUNLI_FINISH"]      = 3,
    ["WEDDING_NOTSTART"]  = 4,
    ["WEDDING_FINISH"]    = 5,
    ["WEDDING_CALMDOWN"]  = 6
}

WeddingSysCommFunc.MissionWaiteStatus = 
{
    ["WAITNOBODY"] = 0,
    ["WAITFEMALECOMPLETE"] = 1,
    ["WAITMALECOMPLETE"] = 2,
}

-- xunliUniqueLayer  only one layer exist one special time
-- noNeedMissionLayer false true
-- stillNeedConsider false true
WeddingSysCommFunc.weddingSysLayers = {}

local maleCancellXunLiMessageBox = nil
local autoPlayLayer = nil

-----------------------------------------------------------------------------
-- mission status
WeddingSysCommFunc.maleId = nil
WeddingSysCommFunc.femaleId = nil
WeddingSysCommFunc.weddingStatus = nil
WeddingSysCommFunc.xunliMissionData = {["curTaskId"]=0,["curSubTaskId"]=0,["curTaskStatus"]=-1}     -- 0 unfinish 1 finish 2 all finish
WeddingSysCommFunc.weddingOpenedStatus = 0                                                        -- 0 not open 1 open 2 finish
-----------------------------------------------------------------------------
WeddingSysCommFunc.marriageID = nil
WeddingSysCommFunc.waitStatus = 0

----
WeddingSysCommFunc.curThingGetNum = 0
WeddingSysCommFunc.curMonsterKilledNum = 0
----

WeddingSysCommFunc.isWeddingSys = false
WeddingSysCommFunc.weddingCarId = nil

WeddingSysCommFunc.qingJianId = 5201314

-------------------------------------------------------
-- cur wedding scene two people id
WeddingSysCommFunc.wdSceneMaleId = nil
WeddingSysCommFunc.wdSceneFemaleId = nil
WeddingSysCommFunc.wdSceneXQPJData = nil            -- xiuqiu pinjiu data
WeddingSysCommFunc.wdSceneLMHBLYSData = nil         -- liyueshi langmanhuaban data
WeddingSysCommFunc.wdSceneMarriageId = nil         -- current wedding scene's marriage id
-------------------------------------------------------

function WeddingSysCommFunc.showXunLiLayer()
    
    print("WeddingSysCommFunc.showXunLiLayer called --------------------------------------------------------------,",WeddingSysCommFunc.weddingStatus)
    if WeddingSysCommFunc.weddingSysLayers.noNeedMissionLayer then
        return
    end
    -- at most 2 people in team
    local teamMem = G_TEAM_INFO.memCnt
    local errCode = -1
    print("tttttttttttttttttttttttttttttttttttttttttttttttttt")
    if (not teamMem) or teamMem == 0 then
        print("not in team ......................................................")
        if WeddingSysCommFunc.weddingStatus == WeddingSysCommFunc.WeddingStatus.BEFORE_XUNLI or WeddingSysCommFunc.weddingStatus == WeddingSysCommFunc.WeddingStatus.XUNLI_ING then
        print("SingleAccessBeforeXunLi ......................................................")
            local layer = require("src/layers/weddingSystem/SingleAccessBeforeXunLi").new()
            getRunScene():addChild(layer)
            return
        end
        --errCode = 8
    elseif not ( teamMem == 2 and G_TEAM_INFO.team_data[1].sex ~= G_TEAM_INFO.team_data[2].sex ) then
        errCode = 2
    elseif G_TEAM_INFO.team_data[1].roleLevel < 48 or G_TEAM_INFO.team_data[2].roleLevel < 48 then
        errCode = 5
    end
    if errCode ~= -1 then
        WeddingSysCommFunc.showWeddingSysError(errCode)
        return
    end
    if (not WeddingSysCommFunc.weddingStatus) or (WeddingSysCommFunc.weddingStatus == WeddingSysCommFunc.WeddingStatus.BEFORE_XUNLI) then
        -- show xunli layer
        local wsLayer = require("src/layers/weddingSystem/XunLiLayer").new()
        cc.Director:getInstance():getRunningScene():addChild( wsLayer,100 )
    elseif WeddingSysCommFunc.weddingStatus == WeddingSysCommFunc.WeddingStatus.XUNLI_ING then
        if WeddingSysCommFunc.weddingSysLayers.xunliUniqueLayer then
            WeddingSysCommFunc.weddingSysLayers.xunliUniqueLayer:removeFromParent()
        end
        local xlMissonlayer = require("src/layers/weddingSystem/XunLiMissionLayer").new()
        WeddingSysCommFunc.weddingSysLayers.xunliUniqueLayer = xlMissonlayer
        getRunScene():addChild(xlMissonlayer)
    elseif WeddingSysCommFunc.weddingStatus == WeddingSysCommFunc.WeddingStatus.XUNLI_FINISH then
        local xlMissonlayer = require("src/layers/weddingSystem/WeddingMissionLayer").new()
        getRunScene():addChild(xlMissonlayer)
    else
        -- todo 
        
    end

end

function WeddingSysCommFunc.showYueLaoNpcLayerInWeddingScene()
    -- click yuelao npc in wedding scene
    if not WeddingSysCommFunc.wdSceneMaleId or not WeddingSysCommFunc.wdSceneFemaleId then
        MessageBox("wdSceneMaleId or wdSceneFemaleId not recv")
        return
    end
    if userInfo.currRoleStaticId == WeddingSysCommFunc.wdSceneMaleId or userInfo.currRoleStaticId == WeddingSysCommFunc.wdSceneFemaleId then
        -- scene owner
        local xlMissonlayer = require("src/layers/weddingSystem/WeddingSceneLayer").new()
        getRunScene():addChild(xlMissonlayer)
    else
        -- guest
        local xlMissonlayer = WeddingSysCommFunc.createANewLayer("src/layers/weddingSystem/WeddingSceneGuestLayer")     -- require("src/layers/weddingSystem/WeddingSceneGuestLayer").new()
        getRunScene():addChild(xlMissonlayer)
    end
    
end

function WeddingSysCommFunc.showWeddingSysError(errId)
    if errId == 8 then
        local layer = require("src/layers/weddingSystem/SingleAccessBeforeXunLi").new()
        getRunScene():addChild(layer)
        return
    end
    local key = WeddingSysCommFunc.WeddingSysErrorCodeSwitch[errId]
    local text = game.getStrByKey(key)
    if not key then
        text = errId
    end
    --TIPS({type=1,str=text})
    MessageBox(text)
end

function WeddingSysCommFunc.showMaleCancellXunLiMessageBox()
    local function onCancellXunLiRecv()
        TIPS({type=1,str=game.getStrByKey("wdsys_xunliCancelled")}) 
    end
    local function cancellWait()
        local femaleId = WeddingSysCommFunc.getFemaleId()
        g_msgHandlerInst:sendNetDataByTableExEx(MARRIAGE_CS_TOUR_GIVEUP, "MarriageTourGiveUpReq", {femaleSID=femaleId})
        g_msgHandlerInst:registerMsgHandler( MARRIAGE_SC_TOUR_GIVEUP , onCancellXunLiRecv )
        print("female id ===============================================================:",femaleId)
    end
    maleCancellXunLiMessageBox = MessageBox(game.getStrByKey("wdsys_waitFemale"),game.getStrByKey("wdsys_btnCancell"),cancellWait,true)
    if maleCancellXunLiMessageBox then
        print("maleCancellXunLiMessageBox exist ..........................................")
    end
end

function WeddingSysCommFunc.getFemaleId()
    for k,v in pairs(G_TEAM_INFO.team_data) do
        if v.sex ~= MRoleStruct:getAttr(PLAYER_SEX) then
            return v.roleId
        end
    end
    return nil
end

function WeddingSysCommFunc.getFemaleIdMapItemNode()
    for k,v in pairs(G_MAINSCENE.map_layer.item_Node:getChildren()) do
        if v.sex and v.sex == 2 then
            return v:getTag()
        end
    end
    return nil
end

function WeddingSysCommFunc.getMaleIdMapItemNode()
    for k,v in pairs(G_MAINSCENE.map_layer.item_Node:getChildren()) do
        if v.sex and v.sex == 1 then
            return v:getTag()
        end
    end
    return nil
end

function WeddingSysCommFunc.getTeamMemName()
    local name = ""
    for k,v in pairs(G_TEAM_INFO.team_data) do
        if v.sex ~= MRoleStruct:getAttr(PLAYER_SEX) then
            name = v.name
            break
        end
    end
    return name
end

function WeddingSysCommFunc.removeMaleCancellXunLiMessageBox()
    print("removeMaleCancellXunLiMessageBox func called .......................................")
    if maleCancellXunLiMessageBox then
        print("removeMaleCancellXunLiMessageBox func dealed .......................................")
        maleCancellXunLiMessageBox:removeFromParent()
        maleCancellXunLiMessageBox = nil
    end
end

function WeddingSysCommFunc.teamInOneScreen()
    -- no use for now
    if G_TEAM_INFO.memCnt ~= 2 then
        return false
    end
    --[[
    local mem1 = G_TEAM_INFO.team_data[1]
    local mem2 = G_TEAM_INFO.team_data[2]
    local pos1 = mem1:getPosition()
    local pos2 = mem2:getPosition()
    if math.abs( pos1.x - pos2.x ) > display.cx then
        return true
    end
    return false
    ]]

    local mmlayer = cc.Director:getInstance():getRunningScene():getChildByName("MainMapLayer")
    if mmlayer then
        local femaleId = WeddingSysCommFunc.getFemaleId()
        local sprite = mmlayer:isPlayerInOneScreen(femaleId)
        if sprite then
            return true
        end
    end
    return false
end

---------------------------------------------------------------------------------------------------
function WeddingSysCommFunc.doMissionWithIds(missionId,subMissionId)
    print("================================================================")
    print("doMissionWithIds(missionId,subMissionId)",missionId,subMissionId)
    print("================================================================")

    WeddingSysCommFunc.weddingStatus = 2 -- status in xunli ing
    WeddingSysCommFunc.xunliMissionData = {["curTaskId"]=missionId,["curSubTaskId"]=subMissionId,["curTaskStatus"]=0}
    local missionData = WeddingSysCommFunc.getMissonDataWithIdAndSubId(missionId,subMissionId)
    if not missionData then
        return
    end

    if missionData.q_class == 1 then
        -- kill monsters
        -- get monster data
        local mData = getConfigItemByKey("monsterUpdate","q_id",missionData.q_mon_pos)
        print("monsterUpdate,monsterId",missionData.q_mon_pos)
        if not mData then
            MessageBox(game.getStrByKey("wdsys_monsterNotExist"))
            return
        end
        print("targetType,mapId,x,y:",3,mData.q_mapid,mData.q_center_x,mData.q_center_y)
        if WeddingSysCommFunc.shouldSelfWait() then
            print("go to target point directly --------------------------------------------------------------------------")
            local tempData = { targetType = 4 , mapID = mData.q_mapid ,  x = mData.q_center_x , y = mData.q_center_y  }
            __TASK:findPath( tempData )
        else
            print("go to kill monster point directly --------------------------------------------------------------------------")
            local tempData = { targetType = 3 , targetData ={  mapID = mData.q_mapid , pos={{x = mData.q_center_x , y = mData.q_center_y}} ,ID = mData.q_monster_model } }
            __TASK:findPath( tempData )
        end
    else
        -- gather things
        -- get npc data
        local mData = getConfigItemByKey("NPC","q_id",missionData.q_CI_id)
        if not mData then
            MessageBox(game.getStrByKey("wdsys_gatherThingsNotExist"))
            return
        end

         if WeddingSysCommFunc.shouldSelfWait() then
            print("go to gether point stand --------------------------------------------------------------------------")
            local tempData = { targetType = 4 , mapID = mData.q_map ,  x = mData.q_x , y = mData.q_y  }
            __TASK:findPath( tempData )
        else
            print("go to gether point gether directly --------------------------------------------------------------------------")
            --local tempData = { targetType = 2 , mapID = mData.q_map ,  x = mData.q_x , y = mData.q_y  }
            local cjTaskId = missionData.q_taskid
            local tempData = { targetType = 2 , targetData ={  mapID = mData.q_map , pos={{x = mData.q_x , y = mData.q_y}},count=missionData.q_total_count, cur_num = 0,ID=mData.q_id,isWeddingSys = true,caijiTaskId = cjTaskId } }
            __TASK:findPath( tempData )
        end
    end

end
---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------
-- get mission data for UI left mission bar
function WeddingSysCommFunc.showWeddingMission()
    --if WeddingSysCommFunc.xunliMissionData.curTaskStatus == 0 or WeddingSysCommFunc.xunliMissionData.curTaskStatus == 1 then
    if WeddingSysCommFunc.weddingStatus == 2 then    -- in status of xunli 
        print("xunli mission shown -------------------------------------------")
        return {}        -- task will show on left bar
    end
    print("xunli mission not shown -------------------------------------------")
    return nil
end

function WeddingSysCommFunc.getTaskLabel()
    local textContent = "wdsys_err_unno"
    if (WeddingSysCommFunc.xunliMissionData.curTaskStatus == 0) then
        if WeddingSysCommFunc.xunliMissionData.curTaskId == 1 then
            textContent = "wdsys_feiwuName"
        elseif WeddingSysCommFunc.xunliMissionData.curTaskId == 2 then
            textContent = "wdsys_chireName"
        elseif WeddingSysCommFunc.xunliMissionData.curTaskId == 3 then
            textContent = "wdsys_panshiName"
        end
    elseif (WeddingSysCommFunc.xunliMissionData.curTaskStatus == 1) then
        textContent = "wdsys_mission_talk"
    end
    return game.getStrByKey(textContent)
end

function WeddingSysCommFunc.getTypeStrAndContent()
    if (WeddingSysCommFunc.xunliMissionData.curTaskStatus == 0) then
        -- task unfinish
        local textKey = nil
        local textKey2 = nil
        local thingNum = ""
        local missionData = WeddingSysCommFunc.getMissonDataWithIdAndSubId(WeddingSysCommFunc.xunliMissionData.curTaskId,WeddingSysCommFunc.xunliMissionData.curSubTaskId)
        WeddingSysCommFunc.waitStatus = WeddingSysCommFunc.MissionWaiteStatus.WAITNOBODY
        if (WeddingSysCommFunc.xunliMissionData.curTaskId == 1 and WeddingSysCommFunc.xunliMissionData.curSubTaskId == 1)  then
            textKey = "wdsys_mission_title1"
            textKey2 = "wdsys_mission_content1"
            thingNum = string.format(" (%d/%d)",WeddingSysCommFunc.curMonsterKilledNum,missionData.q_total_count) 
        elseif (WeddingSysCommFunc.xunliMissionData.curTaskId == 1 and WeddingSysCommFunc.xunliMissionData.curSubTaskId == 2)  then
            textKey = "wdsys_mission_title3"
            textKey2 = "wdsys_feiwuName"
            if MRoleStruct:getAttr(PLAYER_SEX) == 1 then
                -- female
                thingNum = game.getStrByKey("wdsys_mission_waitFemale")
                WeddingSysCommFunc.waitStatus = WeddingSysCommFunc.MissionWaiteStatus.WAITFEMALECOMPLETE
            end
        elseif (WeddingSysCommFunc.xunliMissionData.curTaskId == 2 and WeddingSysCommFunc.xunliMissionData.curSubTaskId == 1)  then
            textKey = "wdsys_mission_title3"
            textKey2 = "wdsys_mission_content2"
            if MRoleStruct:getAttr(PLAYER_SEX) == 1 then
                -- female
                thingNum = game.getStrByKey("wdsys_mission_waitFemale")
                WeddingSysCommFunc.waitStatus = WeddingSysCommFunc.MissionWaiteStatus.WAITFEMALECOMPLETE
            end
        elseif (WeddingSysCommFunc.xunliMissionData.curTaskId == 2 and WeddingSysCommFunc.xunliMissionData.curSubTaskId == 2)  then
            textKey = "wdsys_mission_title2"
            textKey2 = "wdsys_mission_content3"
            if MRoleStruct:getAttr(PLAYER_SEX) == 2 then
                -- male
                thingNum = game.getStrByKey("wdsys_mission_waitMale")
                WeddingSysCommFunc.waitStatus = WeddingSysCommFunc.MissionWaiteStatus.WAITMALECOMPLETE
            end
        elseif (WeddingSysCommFunc.xunliMissionData.curTaskId == 2 and WeddingSysCommFunc.xunliMissionData.curSubTaskId == 3)  then
            textKey = "wdsys_mission_title4"
            textKey2 = "wdsys_chireName"
            if MRoleStruct:getAttr(PLAYER_SEX) == 2 then
                -- male
                thingNum = game.getStrByKey("wdsys_mission_waitMale")
                WeddingSysCommFunc.waitStatus = WeddingSysCommFunc.MissionWaiteStatus.WAITMALECOMPLETE
            end
        elseif (WeddingSysCommFunc.xunliMissionData.curTaskId == 2 and WeddingSysCommFunc.xunliMissionData.curSubTaskId == 4)  then
            textKey = "wdsys_mission_title4"
            textKey2 = "wdsys_chireName"
            if MRoleStruct:getAttr(PLAYER_SEX) == 1 then
                -- female
                thingNum = game.getStrByKey("wdsys_mission_waitFemale")
                WeddingSysCommFunc.waitStatus = WeddingSysCommFunc.MissionWaiteStatus.WAITFEMALECOMPLETE
                print("wait female --------------------------------------------------------")
            end
        elseif (WeddingSysCommFunc.xunliMissionData.curTaskId == 3 and WeddingSysCommFunc.xunliMissionData.curSubTaskId == 1)  then
            textKey = "wdsys_mission_title3"
            textKey2 = "wdsys_panshiName"
            if MRoleStruct:getAttr(PLAYER_SEX) == 2 then
                -- male
                thingNum = game.getStrByKey("wdsys_mission_waitMale")
                WeddingSysCommFunc.waitStatus = WeddingSysCommFunc.MissionWaiteStatus.WAITMALECOMPLETE
            end
        end
        if textKey then
            print("mission board updated ---------------------------------------------------------------------------------")
            return game.getStrByKey(textKey),game.getStrByKey(textKey2) .. thingNum
        end
    elseif (WeddingSysCommFunc.xunliMissionData.curTaskStatus == 1) then
        return game.getStrByKey("wdsys_mission_title5"),game.getStrByKey("wdsys_mission_content4")
    end
    return game.getStrByKey("wdsys_err_unno"),game.getStrByKey("wdsys_err_unno")
end

function WeddingSysCommFunc.taskClickCallBack()
    print("taskClickCallBack called -------------------------------------------")
    if (WeddingSysCommFunc.xunliMissionData.curTaskStatus == 0) then
        -- task unfinish
        WeddingSysCommFunc.doMissionWithIds(WeddingSysCommFunc.xunliMissionData.curTaskId,WeddingSysCommFunc.xunliMissionData.curSubTaskId)
        return
    elseif (WeddingSysCommFunc.xunliMissionData.curTaskStatus == 1) then
        local mData = getConfigItemByKey("NPC","q_id",11000)
        autoFindWayToSpecialNpc(mData.q_map,mData.q_x,mData.q_y,mData.q_id)
        return
    end
    TIPS({type=1,str=game.getStrByKey("wdsys_err_unno")})
end
---------------------------------------------------------------------------------------------------

function WeddingSysCommFunc.setXunLiUniqueLayer(uLayer)
    if WeddingSysCommFunc.weddingSysLayers.xunliUniqueLayer then
        WeddingSysCommFunc.weddingSysLayers.xunliUniqueLayer:removeFromParent()
    end
    WeddingSysCommFunc.weddingSysLayers.xunliUniqueLayer = uLayer
end

function WeddingSysCommFunc.showAllMissionFinishConfirm()
    -- 
    local function yesCallBack()
        print("on yes btn clicked")
        g_msgHandlerInst:sendNetDataByTableExEx(MARRIAGE_CS_ENTER_CEREMONY, "MarriageCSEnterCeremony", {res=0})
        WeddingSysCommFunc.weddingSysLayers.noNeedMissionLayer = false
        WeddingSysCommFunc.weddingSysLayers.xunliUniqueLayer = nil
    end
    local function noCallBack()
        print("on no btn clicked")
        g_msgHandlerInst:sendNetDataByTableExEx(MARRIAGE_CS_ENTER_CEREMONY, "MarriageCSEnterCeremony", {res=1})
        WeddingSysCommFunc.weddingSysLayers.noNeedMissionLayer = false
        WeddingSysCommFunc.weddingSysLayers.xunliUniqueLayer = nil
        WeddingSysCommFunc.weddingSysLayers.stillNeedConsider = true
    end
    local con = string.format(game.getStrByKey("wdsys_mission_complete_confirm"),WeddingSysCommFunc.getTeamMemName())
    local msgBox = MessageBoxYesNo(game.getStrByKey("tip"), con ,yesCallBack,noCallBack,game.getStrByKey("wdsys_btnYes"),game.getStrByKey("wdsys_btn_consider"))
    WeddingSysCommFunc.setXunLiUniqueLayer(msgBox)
    WeddingSysCommFunc.weddingSysLayers.noNeedMissionLayer = true
end

function WeddingSysCommFunc.showWaitConfirmBox()
    local function yesFunc() end
    local function noFunc()
        print("on cancel btn clicked ---------------------------------------------------------------------")
        WeddingSysCommFunc.weddingSysLayers.xunliUniqueLayer = nil
        g_msgHandlerInst:sendNetDataByTableExEx(MARRIAGE_CS_ENTER_CEREMONY_CANCEL, "MarriageCSEnterCeremonyCancel", {})
        WeddingSysCommFunc.weddingSysLayers.stillNeedConsider = true
    end
    local mBox,yesBtn,noBtn = MessageBoxYesNo(game.getStrByKey("tip"), game.getStrByKey("wdsys_waitOther_confirm") ,yesFunc,noFunc,game.getStrByKey("wdsys_btnYes"),game.getStrByKey("cancel"))
    yesBtn:setEnabled(false)
    yesBtn:setVisible(false)
    local posX = noBtn:getPositionX()
    print("pos ========================================================================",posX)
    noBtn:setPositionX(posX+100)
    WeddingSysCommFunc.setXunLiUniqueLayer(mBox)
end

function WeddingSysCommFunc.setKilledMosnterNum(num)
    WeddingSysCommFunc.curMonsterKilledNum = num
    WeddingSysCommFunc.refreshLeftMissionBoard()
    local missionData = WeddingSysCommFunc.getMissonDataWithIdAndSubId(WeddingSysCommFunc.xunliMissionData.curTaskId,WeddingSysCommFunc.xunliMissionData.curSubTaskId)
    if missionData.q_class == 1 and WeddingSysCommFunc.curMonsterKilledNum >= missionData.q_total_count then
        -- hero do nothing stand alone wait for task finish notification
        game.setAutoStatus(0)
    end
end

function WeddingSysCommFunc.shouldSelfWait()
    print("WeddingSysCommFunc.waitStatus ---------------------------------",WeddingSysCommFunc.waitStatus)
    print("MRoleStruct:getAttr(PLAYER_SEX) ---------------------------------",MRoleStruct:getAttr(PLAYER_SEX))
    if (WeddingSysCommFunc.waitStatus == WeddingSysCommFunc.MissionWaiteStatus.WAITFEMALECOMPLETE and MRoleStruct:getAttr(PLAYER_SEX) == 1) or 
            (WeddingSysCommFunc.waitStatus == WeddingSysCommFunc.MissionWaiteStatus.WAITMALECOMPLETE and MRoleStruct:getAttr(PLAYER_SEX) == 2) then
        return true
    end
    return false
end

function WeddingSysCommFunc.getMissonDataWithIdAndSubId(missionId,subMissionId)
    local mData = nil
    local missionData = getConfigItemByKey("MarriageTourTask","q_taskid")
    for k,v in pairs(missionData) do
        if v.q_type == missionId and v.q_step == subMissionId then
            mData = v
            break
        end
    end
    return mData
end

function WeddingSysCommFunc.recoverXunLiData()
    WeddingSysCommFunc.weddingStatus = nil
    WeddingSysCommFunc.xunliMissionData = {["curTaskId"]=0,["curSubTaskId"]=0,["curTaskStatus"]=-1}
end

function WeddingSysCommFunc.refreshLeftMissionBoard()
    local taskMain = DATA_Mission:getCallback( "main_flag" )
    if taskMain then taskMain() end
end

function WeddingSysCommFunc.addOrDeleteAutoPlayLayer(shouldAdd)
    if shouldAdd and (not autoPlayLayer) then
        autoPlayLayer = require("src/layers/weddingSystem/WeddingSysCeremonyAutoPlay").new()
        autoPlayLayer:autoPlay()
        cc.Director:getInstance():getRunningScene():addChild(autoPlayLayer)
    elseif (not shouldAdd) and autoPlayLayer then
        autoPlayLayer:removeFromParent()
        autoPlayLayer = nil
    end
end

function WeddingSysCommFunc.showTransformDialog(marriageId,maleName,femaleName)
    
    local function yesCallback()
        g_msgHandlerInst:sendNetDataByTableExEx(MARRIAGE_CS_WEDDING_INVITATION, "MarriageCSWeddingInvitation", {marriageID=marriageId})
        print("MarriageCSWeddingInvitation = :",marriageId)
    end
    local textCon = string.format(game.getStrByKey("wdsys_enterWeddingSceneConfirm"),maleName,femaleName) 
    MessageBoxYesNo(game.getStrByKey("tip"),textCon,yesCallback,nil)
end
-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
function WeddingSysCommFunc.createANewLayer(luaPath)
    package.loaded[luaPath] = nil
    return require(luaPath).new()
end
-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
-- qifen & wanfa control
function WeddingSysCommFunc.showLieYueShiNpc(isShow)
    if G_MAINSCENE and G_MAINSCENE.map_layer.mapID >= 2211 and G_MAINSCENE.map_layer.mapID <= 2260  then
        print("wedding scene id check ok ")
        for k,v in pairs(G_MAINSCENE.map_layer.item_Node:getChildren()) do
            print("begin check npc id")
            if v:getTag() >= 13001 and v:getTag() <= 13400 then
                print("npc visible setted to :",isShow)
                v:setVisible(isShow)
            end 
            print("end check npc id")
        end
        print("check over !!!")
    end
end

function WeddingSysCommFunc.onFlowerOpen(endTime)
    -- to do
end

function WeddingSysCommFunc.onLiYueShiOpen(endTime)
    -- show npc & play sound
    -- show npcs
    WeddingSysCommFunc.showLieYueShiNpc(true)
    
    
    -- play sound

end

function WeddingSysCommFunc.onQiangXiuQiuOpen(endTime)
    -- to do 
end

function WeddingSysCommFunc.onPinJiuOpen(endTime)
    -- to do
end
-------------------------------------------------------------------------------------------------
return WeddingSysCommFunc