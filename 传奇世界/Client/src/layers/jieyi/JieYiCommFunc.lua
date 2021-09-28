local JieYiCommonFunc = class("JieYiCommonFunc")

JieYiCommonFunc.JYErrorCodeSwitch = {
    [1] = "jieyi_noteam",
    [2] = "jieyi_levelNotEnough",
    [3] = "jieyi_wrongnpc",
    [4] = "jieyi_diffjy",
    [5] = "jieyi_enter_fail",
    [6] = "jieyi_refuse",
    [7] = "jieyi_noJLP",
    [8] = "jieyi_maxMem",
    [9] = "jieyi_minMem",
    [10] = "jieyi_leader",
    [11] = "jieyi_notexist",
    [12] = "jieyi_noSworn",
    [13] = "jieyi_invalideTar",
    [14] = "jieyi_noSKillPoint",
    [15] = "jieyi_preSkill",
    [16] = "jieyi_skillLearned",
    [17] = "jieyi_invalidSkill",
    [18] = "jieyi_cantTransmit",
    [19] = "jieyi_notexist_zh",
    [20] = "jieyi_learn_noskill",
    [21] = "jieyi_reset_notTeamBoss",
    [22] = "jy_tooQuick",
    [23] = "jieyi_noNewMem",
}

local memTab = {}       -- used for restore members already agree jieyi
local jzLayer = nil     -- juanzhou node

JieYiCommonFunc.jyDataTab = {jyId=0,jyMem={}}

function JieYiCommonFunc.setJYData(jyId,jyMem)
    JieYiCommonFunc.jyDataTab.jyId = jyId
    JieYiCommonFunc.jyDataTab.jyMem = jyMem
end

function JieYiCommonFunc.getJYId()
    return JieYiCommonFunc.jyDataTab.jyId
end

function JieYiCommonFunc.getJYMemData(rid)
    local rData = nil
    if not JieYiCommonFunc.jyDataTab.jyMem then
        return rData
    end
    for k,v in pairs(JieYiCommonFunc.jyDataTab.jyMem) do
        if v.role_id == rid then
            rData = v
            break
        end 
    end
    return rData
end

function JieYiCommonFunc.getJYMemName(rid)
    local memData = JieYiCommonFunc.getJYMemData(rid)
    if memData and memData.name then
        return memData.name
    end
    return nil
end

function JieYiCommonFunc.showJieYiErrorCode(res,sid)
    -- jieyi result tips
    -- 1 in no team 2 level not enough 3 clicked wrong npc 4 diff jieye 5 enter jieyi scene faile 
    -- 6 refuse jieyi 7 no jinlanpu 8 jieyi member more than max num
    local key = JieYiCommonFunc.JYErrorCodeSwitch[res]
    if key then
        local str = game.getStrByKey(key)
        if (res == 4 or res == 7) and sid then
            local memName = nil
            if sid == userInfo.currRoleStaticId then
                memName = game.getStrByKey("jy_self_name") 
            else
                memName = getMemNameFromTeam(sid)
            end

            if not memName then
                memName = ""
            end
            str = string.format(str,memName)
        end
        --if res == 12 or res == 2 then
        --    TIPS({type=1,str=str})
        --else
        --    MessageBox(str)
        --end
        TIPS({type=1,str=str})
    end
    if res == 6 then
        -- remove jzLayer
        JieYiCommonFunc.onJieYiFailed()
    end
end

function JieYiCommonFunc.showJieYiConfirmDialog()
   local function yesFunc()
        g_msgHandlerInst:sendNetDataByTable(SWORN_CS_START_CEREMONY, "StartSwornCeremonyRet", {ret=1})
   end
   local function noFunc()
        g_msgHandlerInst:sendNetDataByTable(SWORN_CS_START_CEREMONY, "StartSwornCeremonyRet", {ret=0})
   end

   local title = game.getStrByKey("jieyi_confirm_tile")
   local content = game.getStrByKey("jieyi_confirm_content")
   local yesBtnCon = game.getStrByKey("jieyi_yesbtn_con")
   local noBtnCon = game.getStrByKey("jieyi_nobtn_con")
   --MessageBoxYesNo(title,content,yesFunc,noFunc,yesBtnCon,noBtnCon)

   --MessageBoxYesNoEx(title,content,yesFunc,noFunc,yesBtnCon,noBtnCon,false,true,30,3)

   local node = JieYiCommonFunc.showJuanZhouLayer()
   node:setPosition(cc.p(display.cx,display.cy))
   Director:getRunningScene():addChild(node,10000)
end

function JieYiCommonFunc.showJuanZhouLayer()
    -- 
    local node = cc.Node:create()
    -- juanzhou begin
    local tmpPath = "res/jieyi/"
    
    local halfOfRollDis = 440
    local rollTime = 3
    local rollAction = cc.MoveBy:create(rollTime,cc.p(halfOfRollDis*2,0))

    local clipNode = cc.ClippingNode:create()
    node:addChild(clipNode)

    local stencil1 = cc.Sprite:create(tmpPath .."jieyibg.png")
    stencil1:setAnchorPoint(cc.p( 0.5 , 0.5 ))
    stencil1:setPosition(cc.p(0,0))
    stencil1:runAction(rollAction)    
    clipNode:setStencil(stencil1)
    clipNode:setInverted(true)
    clipNode:setAlphaThreshold(0)

    local zhouLeft = createSprite(node,tmpPath .. "zhou.png",cc.p(-halfOfRollDis,0))
    local zhouRight = createSprite(node,tmpPath .. "zhou.png",cc.p(-halfOfRollDis,0))
    zhouRight:setFlippedX(true)
    zhouRight:runAction( rollAction:clone() )
    -- juanzhou end

    -- add juanzhou content
    -- add bg
    local bg = createSprite(clipNode,tmpPath .."jieyibg.png",cc.p(0,0))
    -- add flower
    local flower = Effects:create(true)
    flower:playActionData("sworn", 17 , rollTime , 1 )
    clipNode:addChild(flower)
    -- add button
    local jzNodeTab = {bg,zhouLeft,zhouRight}
    local closeMenu
    local function funcYes()
        g_msgHandlerInst:sendNetDataByTableExEx(SWORN_CS_START_CEREMONY, "StartSwornCeremonyRet", {ret=1})
        closeMenu:setEnabled(false)
        closeMenu:setVisible(false)
    end
    local function funcNo()
        g_msgHandlerInst:sendNetDataByTableExEx(SWORN_CS_START_CEREMONY, "StartSwornCeremonyRet", {ret=0})
        --g_msgHandlerInst:registerMsgHandler( GIVEWINE_SC_GETWINE_NUM, function(...) hejiu(...) end)
        JieYiCommonFunc.onJieYiFailed()
        
        -- scroll back
        --local rollBackAction = cc.MoveBy:create(rollTime,cc.p(-halfOfRollDis*2,0))
        --stencil1:runAction(rollBackAction)
        --zhouRight:runAction(rollBackAction:clone())
    end
    local btnNode,menuYes,menuNo = MenuItemYesNoEx(funcYes,funcNo,game.getStrByKey("jieyi_yesbtn_con") ,nil,true,30,2,false)
    btnNode:setPosition(cc.p(52,-200))
    btnNode:setScale(0.8)
    clipNode:addChild(btnNode)
    menuNo:setEnabled(false)
    menuNo:setVisible(false)
    -- close button
    closeMenu = createMenuItem(clipNode,"res/component/button/x2.png",cc.p(0,0),funcNo)		
    setNodeAttr(closeMenu, cc.p(400,160), cc.p(0.5, 0.5))
	registerOutsideCloseFunc( node , funcNo )
    -- add content end
    jzLayer = node
    jzLayer.jzNodeTab = jzNodeTab
    jzLayer.jzBg = bg   -- no use for now

    return node
end

function JieYiCommonFunc.onJieYiSuccess()
    -- fadeout
    local foTime = 0.5
    for k,v in pairs(jzLayer.jzNodeTab) do
        v:runAction(cc.FadeOut:create(foTime))
    end
    jzLayer:runAction(cc.Sequence:create(cc.DelayTime:create(foTime),cc.RemoveSelf:create()))
    -- success effect
    --[[ 
    local successNode = cc.Node:create()
    successNode:setPosition(cc.p(display.cx,display.cy))
    getRunScene():addChild(successNode,10000)
    successNode:runAction(cc.Sequence:create(cc.DelayTime:create(1.0),cc.RemoveSelf:create()))

    local flower = Effects:create(true)
    flower:playActionData("swornsuccess", 11 , 1 , 1 )
    successNode:addChild(flower)

    local sFont = cc.Sprite:create("res/jieyi/jieyisuccess.png")
    sFont:setVisible(false)
    sFont:runAction( cc.Sequence:create(cc.DelayTime:create(0.5),cc.Show:create(),cc.ScaleTo:create(0.3,1.5),cc.ScaleTo:create(0.2,1),cc.RemoveSelf:create()))
    successNode:addChild(sFont)
    ]]
    playCommonFontEffect(1)
end

function JieYiCommonFunc.onJieYiFailed()
    if jzLayer then
        jzLayer:removeFromParent()
        jzLayer = nil
    end
    memTab = {}
end

function JieYiCommonFunc.addJieYiMem(roleId,jyRes)
    local memNum = #memTab + 1
    if jzLayer and roleId then
        for k,v in pairs(memTab) do
            if v == roleId then
                roleId = nil
                break
            end
        end
        if roleId then
            table.insert(memTab,roleId)
        end
    end
    -- update mem list
    if not roleId then
        return
    end
    
    local switchMemNodePos = {
        [1] = cc.p(-70,70),
        [2] = cc.p(70,70),
        [3] = cc.p(-70,-80),
        [4] = cc.p(70,-80),
    }

    local memName = getMemNameFromTeam(roleId)
    
    if not memName then
        return
    end
    local node = cc.Node:create()
    createSprite(node,"res/jieyi/shouyin.png")
    createLabel(node,memName)
    node:setPosition(switchMemNodePos[memNum])
    jzLayer:addChild(node)
    if jyRes then
        JieYiCommonFunc.onJieYiSuccess()
        memTab = {}
    end
end

function JieYiCommonFunc.showZHRemindLayer(zhzId,zhzName,zhzMapId)      -- zhaohuan zhe data id name mapId
    -- zhaohuan msgbox
    local function onYesFunc()
        g_msgHandlerInst:sendNetDataByTableExEx(SWORN_CS_OPERATE_ATV_SKILL, "OperateSwornAtvSkill", {type=3,target_id=zhzId})
        -- will return in SWORN_SC_ENTER_SCENE if any error ocurred
    end
    local con = string.format(game.getStrByKey("jy_zh_content"),zhzName,getMapInfoData(zhzMapId).q_map_name)
    MessageBoxYesNo(game.getStrByKey("jy_zh_title"),con,onYesFunc,nil,game.getStrByKey("sure"),game.getStrByKey("cancel"))
end

function JieYiCommonFunc.getJieYiRelationShipNameWithLevel(lv)
    local localData = require("src/config/qyz_info")
    local relationshipName = ""
    for k,v in pairs(localData) do
        if v.level == lv then
            relationshipName = v.name
            break
        end
    end
    return relationshipName
end

function JieYiCommonFunc.onJieYiDismiss()

end

return JieYiCommonFunc