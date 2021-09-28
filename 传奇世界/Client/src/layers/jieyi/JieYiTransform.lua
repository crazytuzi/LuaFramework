local JieYiTransform = class("JieYiTransform",function () return cc.Layer:create() end)

JieYiTransform.bg = nil
JieYiTransform.skillId = nil

function JieYiTransform:ctor(skillId)
    
    self.skillId = skillId
    self:addBg()
    self:loadData()
    SwallowTouches(self)
end

function JieYiTransform:addBg()
    local bg = createSprite(self,"res/common/bg/bg18.png",cc.p(display.cx,display.cy),cc.p(0.5,0.5))
    local s9 = cc.Scale9Sprite:create("res/common/bg/bg18-9.png")
    s9:setContentSize(cc.size(784,450))
    s9:setAnchorPoint(cc.p(0,0))
    s9:setCapInsets(cc.rect(20,20,740,40))
    s9:setPosition(cc.p(35,20))
    bg:addChild(s9)

    --s9 = cc.Scale9Sprite:create("res/common/bg/bg18-13.png")
    --s9:setContentSize(cc.size(768,360))
    --s9:setAnchorPoint(cc.p(0,0))
    --s9:setCapInsets(cc.rect(10,10,200,40))
    --s9:setPosition(cc.p(44,72))
    --bg:addChild(s9)

    local s9 = createScale9Frame(
        bg,
        "res/common/scalable/panel_outer_base_1.png",
        "res/common/scalable/panel_outer_frame_scale9_1.png",
        cc.p(44,72),
        cc.size(768,360),
        5
    )
    s9:setAnchorPoint(cc.p(0,0))
    -- title
    createLabel(bg,game.getStrByKey("jy_csTitle"),cc.p(434,502),cc.p(0.5,0.5),24,nil,nil,nil,MColor.lable_yellow)
    createLabel(bg,game.getStrByKey("jy_jueseming"),cc.p(163,449),cc.p(0.5,0.5),22,nil,nil,nil,MColor.lable_yellow)
    createLabel(bg,game.getStrByKey("jy_curPos"),cc.p(487,449),cc.p(0.5,0.5),22,nil,nil,nil,MColor.lable_yellow)
    createLabel(bg,game.getStrByKey("jy_cantTransit"),cc.p(271,32),cc.p(0,0),20,nil,nil,nil,MColor.alarm_red)

    local function closeFunc()
        self:removeFromParent()
    end
    local bgSize = bg:getContentSize()
    local close_item = createTouchItem(bg, "res/component/button/X.png", cc.p(bgSize.width-40, bgSize.height-28), closeFunc, nil)
	close_item:setLocalZOrder(500)

    self.bg = bg
end

function JieYiTransform:loadData()
    local function jy_member(luaBuffer)
        local retTable = g_msgHandlerInst:convertBufferToTable("SwornAtvSkillInfoRet", luaBuffer)
        local memData = retTable.bros
        --memData = {sid,name,map,x,y}
        self:addScrollView(memData)
    end

    g_msgHandlerInst:sendNetDataByTableExEx(SWORN_CS_REQUEST_ATV_SKILL_INFO, "ReqSwornAtvSkillInfo", {})
	--addNetLoading(SWORN_CS_REQUEST_ATV_SKILL_INFO,SWORN_SC_ATV_SKILL_INFO_RET)
    g_msgHandlerInst:registerMsgHandler( SWORN_SC_ATV_SKILL_INFO_RET , jy_member )

    --local memData = {{sid=1,name="name1",map=1100,x=200,y=300},{sid=2,name="name2",map=1000,x=300,y=400}}
    --self:addScrollView(memData)
end

function JieYiTransform:addScrollView(memData)
    --memData = {sid,name,map,x,y}
    local function onMItemBtnClick(_,btn)
        local targetId = btn:getName()
        g_msgHandlerInst:sendNetDataByTable(SKILL_CS_SWORN_SKILL, "SkillSwornProtocol", {skillId=self.skillId,targetId=targetId})
        if G_MAINSCENE then
            G_MAINSCENE:doSkillCdAction(self.skillId,1)
        end
        self:removeFromParent()
    end
    local node = cc.Node:create()
    local dataNum = #memData
    local i = 1
    for k,v in pairs(memData) do
        while true do
            if v.sid == userInfo.currRoleStaticId then
                --btn:setEnabled(false)
                break
            end
            local item = cc.Node:create()
            local rname = v.name
            createLabel(item,rname,cc.p(116,31) ,cc.p(0.5,0.5),20,nil,nil,nil,MColor.lable_yellow)

            local btn = createMenuItem(item,"res/component/button/49.png",cc.p(680,31),onMItemBtnClick)
            btn:setName(v.sid)
            createLabel(btn,game.getStrByKey("jy_chuansong"),cc.p(68,22),cc.p(0.5,0.5),22,nil,nil,nil,MColor.lable_yellow)

            local mapNameLabel = createLabel(item,"",cc.p(338,31) ,cc.p(0,0.5),20,nil,nil,nil,MColor.lable_yellow)
            if v.map > 0 then
                -- online
                local map_Name = getMapInfoData(v.map).q_map_name
                local posLab = string.format(game.getStrByKey("jy_kuohao"),v.x,v.y)
                local mapName =  map_Name .. posLab
                mapNameLabel:setString(mapName)
            else
                mapNameLabel:setString(game.getStrByKey("jy_status_offline"))
                btn:setEnabled(false)
            end

            createSprite(item, "res/common/bg/line9.png", cc.p(10, 0), cc.p(0.0, 0.0))
            item:setContentSize(cc.size(765,55))
            item:setPosition(cc.p(0,55*(dataNum-i)))
            node:addChild(item)
            i = i + 1
            break
        end
    end
    node:setContentSize(cc.size(765,55*dataNum))

    -- scroll view
    local scrollView = cc.ScrollView:create()
    scrollView:setViewSize(cc.size( 768,350 ))
    scrollView:setPosition( cc.p( 40 , 72 ) )
    scrollView:ignoreAnchorPointForPosition(true)

    scrollView:setContainer(node)
    scrollView:updateInset()

    scrollView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL )
    scrollView:setClippingToBounds(true)
    scrollView:setBounceable(true)
    self.bg:addChild(scrollView)
    scrollView:setContentOffset( cc.p(0, -node:getContentSize().height+scrollView:getViewSize().height ))
end

function JieYiTransform:unregisterNetWorkCallBack()  
    local function eventCallback(eventType)
        if eventType == "exit" then
            g_msgHandlerInst:registerMsgHandler( SWORN_SC_ATV_SKILL_INFO_RET , nil )  
        end
    end
     self:registerScriptHandler(eventCallback)
end

return JieYiTransform