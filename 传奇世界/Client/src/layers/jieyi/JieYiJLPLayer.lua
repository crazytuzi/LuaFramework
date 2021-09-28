local JieYiJLPLayer = class("JieYiJLPLayer",function () return cc.Layer:create() end)

JieYiJLPLayer.rootNode = nil
JieYiJLPLayer.relationship = nil
JieYiJLPLayer.progressbar = nil
JieYiJLPLayer.progressNum = nil
JieYiJLPLayer.scrollView = nil
JieYiJLPLayer.checkBox = nil

JieYiJLPLayer.jyMemTab = nil
JieYiJLPLayer.baseJYLayer = nil

function JieYiJLPLayer:ctor(bJYLayer)
    self:unregisterNetWorkCallBack()
    self:addTopContent()
    self:addScrollViewContent()
    self:addCheckBox()
    self:addGPDYBtn()
    self:addHelpBtn()

    self:registerNetWorkCallBack()
    self:loadData()
    self.baseJYLayer = bJYLayer
end
---------------------------------------------------------------------------------------------------------------
----UI Adding----------
function JieYiJLPLayer:addTopContent()
    --createSprite(self,"res/common/bg/bg.png",cc.p(480,290))
	--local bg_6 = createSprite(self,"res/common/bg/bg-6.png",cc.p(480,290))
    local bg_6 = cc.Node:create()
    bg_6:setPosition(cc.p(15, 23))
    bg_6:setContentSize(cc.size(930, 535))
    bg_6:setAnchorPoint(cc.p(0, 0))
    self:addChild(bg_6)

    local bg = cc.Sprite:create("res/common/scalable/panel_outer_base_1.png", cc.size(890,500))
	bg:setAnchorPoint(cc.p(0, 0))
    bg:setPosition(cc.p(20,20))
	bg:getTexture():setTexParameters(gl.LINEAR, gl.LINEAR, gl.REPEAT, gl.REPEAT)
    bg_6:addChild(bg)
    local ibg = createSprite(self,"res/common/bg/infoBg16-1.png",cc.p(480,488))
    createLabel(ibg,game.getStrByKey("jy_relationshipLevel"),cc.p(120,50),cc.p(1,0.5),22,nil,nil,nil,MColor.lable_yellow)
    self.relationship = createLabel(ibg,"",cc.p(125,50),cc.p(0,0.5),22,nil,nil,nil,MColor.green)
    createLabel(ibg,game.getStrByKey("jy_qyz"),cc.p(340,50),cc.p(1,0.5),22,nil,nil,nil,MColor.lable_yellow)
    --local pbBg = createSprite(ibg,"res/common/progress/jy_bg.png",cc.p(345,50),cc.p(0,0.5)) 
    --local pb = cc.ProgressTimer:create(cc.Sprite:create("res/common/progress/jy_bar.png"))
    local pbBg = cc.Scale9Sprite:create("res/common/progress/jd18-bg.png")
    pbBg:setContentSize(cc.size(503,26))
    pbBg:setAnchorPoint(cc.p(0,0.5))
    pbBg:setCapInsets(cc.rect(30,6,230,10))
    pbBg:setPosition(cc.p(345,50))
    ibg:addChild(pbBg)
    local pb = createLoadingBar(false,{
            parent = pbBg,
            size = cc.size(479,18),
            percentage = 0,
            pos = cc.p(13,13),
            res = "res/component/progress/yellowBar.png",
            dir  = true, --œÚ”“
            anchor = cc.p(0,0.5),
        })

    --pb:setPosition(cc.p(13,13))
    --pb:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    --pb:setAnchorPoint(cc.p(0.0,0.5))
    --pb:setBarChangeRate(cc.p(1, 0))
    --pb:setMidpoint(cc.p(0,1))
    --pb:setPercentage(50)
    --pbBg:addChild(pb)
    self.progressbar = pb
    self.progressNum = createLabel(pbBg,"",cc.p(250,13),cc.p(0.5,0.5),22,nil,nil,nil,MColor.lable_yellow)
    self.rootNode = bg_6
end

function JieYiJLPLayer:addScrollViewContent()
	local s9 = CreateListTitle(self.rootNode, cc.p(465,388), 890, 47)
    createLabel(s9,game.getStrByKey("jy_title_name"),cc.p(104,26),cc.p(0.5,0.5),22,nil,nil,nil,MColor.lable_yellow)
    createLabel(s9,game.getStrByKey("jy_title_zhiye"),cc.p(310,26),cc.p(0.5,0.5),22,nil,nil,nil,MColor.lable_yellow)
    createLabel(s9,game.getStrByKey("jy_title_level"),cc.p(470,26),cc.p(0.5,0.5),22,nil,nil,nil,MColor.lable_yellow)
    createLabel(s9,game.getStrByKey("jy_title_shenfen"),cc.p(700,26),cc.p(0.5,0.5),22,nil,nil,nil,MColor.lable_yellow)

    -- scroll view
    local scrollView = cc.ScrollView:create()
    scrollView:setViewSize(cc.size( 892,285 ))
    scrollView:setPosition( cc.p( 15 , 75 ) )
    scrollView:ignoreAnchorPointForPosition(true)

    --scrollView:setContainer(node)
    scrollView:updateInset()

    scrollView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL )
    scrollView:setClippingToBounds(true)
    scrollView:setBounceable(true)
    self.rootNode:addChild(scrollView)
    --scrollView:setContentOffset( cc.p(0, -node:getContentSize().height+scrollView:getViewSize().height ))
    self.scrollView = scrollView
end

function JieYiJLPLayer:addCheckBox()
     -- checkbox
    local function checkBoxCallBack(arg1,a2)
        -- a2 0 select 1 nonselect
        g_msgHandlerInst:sendNetDataByTableExEx(SWORN_CS_DO_ACTION, "SwornDoAction", {type = 3})     

    end
    local cbox = ccui.CheckBox:create("res/component/checkbox/1.png",            -- normal
                                    "res/component/checkbox/1-2.png",           -- normal press
                                    "res/component/checkbox/1-2.png",           -- active
                                    "res/component/checkbox/1.png",             -- normal disable
                                    "res/component/checkbox/1-2.png")           -- active disable
    cbox:setPosition(cc.p(40,52))
    self.rootNode:addChild(cbox)
    cbox:addEventListener(checkBoxCallBack)
    self.checkBox = cbox
    createLabel(self.rootNode,game.getStrByKey("jy_checkbox_con"),cc.p(60,52),cc.p(0,0.5),24,nil,nil,nil,MColor.lable_black)
end

function JieYiJLPLayer:addGPDYBtn()
    local function quitJy()
        local function onYesFunc()
            g_msgHandlerInst:sendNetDataByTableExEx(SWORN_CS_DO_ACTION, "SwornDoAction", {type=2})
        end
        MessageBoxYesNo(game.getStrByKey("jy_gpdy"),game.getStrByKey("jy_gpdy_confirm"),onYesFunc,nil)
    end
    local qj = createMenuItem(self.rootNode,"res/component/button/49.png",cc.p(0,0),quitJy)
    qj:setPosition(cc.p(820,52))
    createLabel(qj,game.getStrByKey("jy_gpdy"),cc.p(68,22),cc.p(0.5,0.5),22,nil,nil,nil,MColor.lable_yellow)
end

function JieYiJLPLayer:addHelpBtn()
    local function helpBtnFunc()
		local helpLayer = require("src/layers/jieyi/JieYiHelpLayer").new()
        getRunScene():addChild(helpLayer,201)
	end
	createMenuItem(self.rootNode, "res/component/button/small_help2.png", cc.p(700, 52), helpBtnFunc)
end
----UI Adding----------
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
----Data Adding----------
function JieYiJLPLayer:loadData()
    local function basicInfo(luaBuffer)
        local retTable = g_msgHandlerInst:convertBufferToTable("SwornBasicInfoRet", luaBuffer)
        local re = retTable.relation
        local onLineRemind = retTable.online_hint
        local teamMem = retTable.bros    -- {"name","profession","level","is_leader","role_id" }
        self.jyMemTab = teamMem
        -- for temp use
        --teamMem = {{name="jsm",profession = 1,level=11,is_leader=1,sid=1},{name="jsm1",profession = 1,level=11,is_leader=0,sid=1},{name="jsm2",profession = 1,level=11,is_leader=0,sid=1}}

        self:setRelationShipName(re)
        self:setRemindCheckBox(onLineRemind)
        self:addTeamMember(teamMem)
	    --require("src/layers/jieyi/JieYiCommFunc").setJYData(retTable.sworn_id,retTable.bros)
    end
    g_msgHandlerInst:sendNetDataByTableExEx(SWORN_CS_REQUEST_INFO, "RequestSwornInfo", {type=1})
	--addNetLoading(SWORN_CS_REQUEST_INFO,SWORN_SC_BASIC_INFO)
    g_msgHandlerInst:registerMsgHandler( SWORN_SC_BASIC_INFO , basicInfo )
    
    --[[
        local re = 2000
        local onLineRemind = true
        local teamMem = nil    -- {"name","profession","level","is_leader","sid" }
        -- for temp use
        teamMem = {{name="jsm",profession = 1,level=11,is_leader=1,sid=1},{name="jsm1",profession = 1,level=11,is_leader=0,sid=1},{name="jsm2",profession = 1,level=11,is_leader=0,sid=1}}

        local totalRe = self:setRelationShipName(re)
        self:setRemindCheckBox(onLineRemind)
        self:addTeamMember(teamMem)

        self.progressbar:setPercentage(re*100/totalRe)
        self.progressNum:setString(re .. "/" .. totalRe)
    ]]
end

function JieYiJLPLayer:setRelationShipName(re)
    -- relationshipName
    local localData = require("src/config/qyz_info")
    local totalRe = re
    local relationshipName = ""
    local lastQYZ = 0
    local lastRelationShipName = ""
    for k,v in pairs(localData) do
        if re < v.qyzNum and re >= lastQYZ then
            relationshipName = lastRelationShipName
            totalRe = v.qyzNum
            break
        end
        lastQYZ = v.qyzNum
        lastRelationShipName = v.name
    end
    
    if relationshipName == "" then
        local lData = localData[#localData]
        relationshipName = lData.name
        totalRe = lData.qyzNum
        re = totalRe
    end

    self.relationship:setString(relationshipName)
	-- relationshipName end

    self.progressbar:setPercent(re*100/totalRe)
    self.progressNum:setString(re .. "/" .. totalRe)
end

function JieYiJLPLayer:setRemindCheckBox(checked)
    self.checkBox:setSelected(checked)
end

function JieYiJLPLayer:setAndReorderMemTab(tab,leaderId)
    local bossData = nil
    local i=1
    for k,v in pairs(tab) do
        if leaderId and leaderId == v.role_id then
            bossData = v
        elseif (not leaderId) and v.is_leader then
            bossData = v
        end

        if bossData then
            table.remove(tab,i)
            break
        end

        i = i + 1
    end
    table.insert(tab,1,bossData)
    return tab 

end

function JieYiJLPLayer:addTeamMember(memData,leaderId)
    -- {"name","profession","level","is_leader","sid" }
    local tmpData = self:setAndReorderMemTab(memData,leaderId) 
    local dataNum = #tmpData
    local node = cc.Node:create()
    local contentPos = {cc.p(104,33),cc.p(310,33),cc.p(470,33),cc.p(700,33)}    -- content pos in every line in scrollview
    local dataIndex = dataNum

    local function dealRemoveMem(_,a2)
        local tmpStr = stringsplit(a2:getName(),"||") 
        local tarId = tmpStr[1]
        local tarName = tmpStr[2]
        local function onYesFunc()
            g_msgHandlerInst:sendNetDataByTableExEx(SWORN_CS_DO_ACTION, "SwornDoAction", {type=1,target_id=tarId})
        end
        MessageBoxYesNo(game.getStrByKey("jy_remove_title"),string.format(game.getStrByKey("jy_remove_confirm"),tarName) ,onYesFunc,nil)
    end

    local isBoss = false
    local bossId = -1
    if leaderId then
        if leaderId == userInfo.currRoleStaticId then
            isBoss = true
        end
        bossId = leaderId
    else
        for k,v in pairs(tmpData) do
            if v.is_leader then
                if v.role_id == userInfo.currRoleStaticId then     
                    isBoss = true
                end
                bossId = v.role_id
                break
            end
        end
    end
    
    for k,v in pairs(tmpData) do
        local s9 = cc.Scale9Sprite:create("res/common/bg/titleBg4.png")
        s9:setContentSize(cc.size(888,60))
        s9:setAnchorPoint(cc.p(0,0))
        s9:setCapInsets(cc.rect(10,5,470,40))
        s9:setPosition(cc.p(5,(dataIndex-1)*65))
        dataIndex = dataIndex - 1
        node:addChild(s9)

        createLabel(s9,v.name,contentPos[1],cc.p(0.5,0.5),24,nil,nil,nil,MColor.lable_black)
        createLabel(s9,getSchoolByName(tonumber(v.profession)),contentPos[2],cc.p(0.5,0.5),24,nil,nil,nil,MColor.lable_black)
        createLabel(s9,v.level,contentPos[3],cc.p(0.5,0.5),24,nil,nil,nil,MColor.lable_black)

        local jy_re = game.getStrByKey("jy_member")

        if isBoss then
            if v.role_id == userInfo.currRoleStaticId then
                jy_re = game.getStrByKey("jy_boss")
            else
                local mItem = createMenuItem(s9,"res/component/button/48_sel.png",cc.p(0,0), dealRemoveMem )
                mItem:setPosition(cc.p(820,30))
                --mItem:setTag(v.role_id)
                --mItem:setName(v.name)
                mItem:setName(v.role_id .. "||" .. v.name)
                createLabel(mItem,game.getStrByKey("jy_remove"),cc.p(45,22),cc.p(0.5,0.5),22,nil,nil,nil,MColor.lable_yellow)
            end
        else
            if bossId and v.role_id == bossId then
                jy_re = game.getStrByKey("jy_boss")
            end
        end

        createLabel(s9,jy_re,contentPos[4],cc.p(0.5,0.5),24,nil,nil,nil,MColor.lable_black)
    end
    node:setContentSize(cc.size(890,dataNum*65-5))
    self.scrollView:setContainer(node)
    self.scrollView:setContentOffset( cc.p(0, -node:getContentSize().height+self.scrollView:getViewSize().height ))
end
----Data Adding----------
---------------------------------------------------------------------------------------------------------------
function JieYiJLPLayer:removeMemById(rid,leaderId)
    local i = 1
    for k,v in pairs(self.jyMemTab) do
        if v.role_id == rid then
            table.remove(self.jyMemTab,i)
            break
        end
        i = i + 1
    end
    self:addTeamMember(self.jyMemTab,leaderId)
end

function JieYiJLPLayer:registerNetWorkCallBack()
    local function removeBaseJYLayer()
        if self.baseJYLayer then
            self.baseJYLayer:removeFromParent()
        end 
    end
    local function onOperationRet(luaBuffer)
        local retTable = g_msgHandlerInst:convertBufferToTable("SwornDoActionRet", luaBuffer)
        local jyCommFunc = require("src/layers/jieyi/JieYiCommFunc")
        if retTable.type == 1 then
            -- remove mem
            self:removeMemById(retTable.target_id,retTable.leader_id)
            if retTable.target_id == userInfo.currRoleStaticId then
                jyCommFunc.setJYData(0,nil)
                MessageBox(game.getStrByKey("jy_removed"),nil,removeBaseJYLayer)    
            else
                local soName = jyCommFunc.getJYMemName(retTable.target_id)
                if soName then
                    MessageBox( string.format(game.getStrByKey("jy_someone_remove"),soName) ,nil,nil)    
                end
            end
        elseif retTable.type == 2 then
            -- gepaoduanyi
            if retTable.target_id == userInfo.currRoleStaticId then
                jyCommFunc.setJYData(0,nil)
                MessageBox(game.getStrByKey("jy_quit"),nil,removeBaseJYLayer)    
            else
                local soName = jyCommFunc.getJYMemName(retTable.target_id)
                if soName then
                    MessageBox( string.format(game.getStrByKey("jy_someone_quit"),soName) ,nil,nil)    
                end
                self:removeMemById(retTable.target_id,retTable.leader_id)
            end
            
        elseif retTable.type == 3 then
            -- online remind
            -- only send network request 
        elseif retTable.type == 4 then
            -- jieyi dismiss
            jyCommFunc.setJYData(0,nil)
            MessageBox(game.getStrByKey("jy_dismiss"),nil,removeBaseJYLayer)
        end
    end
    g_msgHandlerInst:registerMsgHandler( SWORN_SC_DO_ACTION_RET , onOperationRet )
end

function JieYiJLPLayer:unregisterNetWorkCallBack()
    local func1 = g_msgHandlerInst:getMsgHandler( SWORN_SC_BASIC_INFO )  
    local func2 = g_msgHandlerInst:getMsgHandler( SWORN_SC_DO_ACTION_RET )  
    local function eventCallback(eventType)
        if eventType == "exit" then
            g_msgHandlerInst:registerMsgHandler( SWORN_SC_BASIC_INFO , func1 )  
            g_msgHandlerInst:registerMsgHandler( SWORN_SC_DO_ACTION_RET , func2 )  
        end
    end
     self:registerScriptHandler(eventCallback)
end

return JieYiJLPLayer