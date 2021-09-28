local JieYiSkillLayer = class("JieYiSkillLayer",function () return cc.Layer:create() end)

JieYiSkillLayer.openedSlotId = nil
JieYiSkillLayer.svNode = nil
JieYiSkillLayer.btnsTab = nil
JieYiSkillLayer.skillPointLabel = nil
JieYiSkillLayer.lineTab = nil
JieYiSkillLayer.txingTab = nil

JieYiSkillLayer.skillPoint = nil
JieYiSkillLayer.skillsTab = nil

JieYiSkillLayer.isBigBoss = false -- daitoudage

local ITEMZORDERS = {
    ["LINESZORDER"] = 100,
    ["BUTTONSLOTZORDER"] = 101,
    ["TXINGZORDER"] = 101,
    ["POINTSZORDER"] = 101
}

function JieYiSkillLayer:ctor()
    --createSprite(self,"res/common/bg/bg.png",cc.p(480,290))
	--createSprite(self,"res/common/bg/bg-6.png",cc.p(480,290))
    local bg_6 = createSprite(self,"res/jieyi/jySkillbg.png",cc.p(480,290))

    -- scroll view content
    local node = cc.Node:create()
    -- scroll view
    local scrollView = cc.ScrollView:create()
    scrollView:setViewSize(cc.size( 892,500 ))
    scrollView:setPosition( cc.p( 0 , -5 ) )
    scrollView:ignoreAnchorPointForPosition(true)

    scrollView:setContainer(node)
    scrollView:updateInset()

    scrollView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL )
    scrollView:setClippingToBounds(true)
    scrollView:setBounceable(true)
    bg_6:addChild(scrollView)

    createSprite(node,"res/jieyi/skillLineBg.png",cc.p(655,270),cc.p(0.5,0.5))
    node:setContentSize(cc.size(1057+109*2,401+109))
    scrollView:setContentOffset( cc.p(0, -node:getContentSize().height+scrollView:getViewSize().height ))
    self.svNode = node

    local jyMemData = require("src/layers/jieyi/JieYiCommFunc").getJYMemData(userInfo.currRoleStaticId)
    if jyMemData and jyMemData.is_leader then
        self.isBigBoss = true
    end

    self:unregisterNetWorkCallBack()
    self:addSkillBtns()
    self:addPoints()
    self:addResetBtn(bg_6)
    self:addLines()
    self:addTXing()
    self:loadData()
end

function JieYiSkillLayer:updateAllItems()
    self:setOpenedSlotId()
    self:updateLines()
    self:updateTXing()
    self:setSlotCanClick()
    self.skillPointLabel:setString(self.skillPoint)
end

function JieYiSkillLayer:loadData()
    local function skillInfo(luaBuffer)
        local retTable = g_msgHandlerInst:convertBufferToTable("SwornSkillInfoRet", luaBuffer)
        local skillPoint = 0
        local skillTab = {}
        -- when we do not write this for ,after reset all skills retTable.skills will not exist in this for but still exist when called by retTable.skills ????
        for k,v in pairs(retTable) do
            if type(v) == "number" then
                skillPoint = v
            end
            if type(v) == "table" then
                skillTab = v
            end
        end
        
        self.skillPoint = skillPoint
        self.skillsTab = skillTab
        self:updateAllItems()
        
    end
    g_msgHandlerInst:sendNetDataByTableExEx(SWORN_CS_REQUEST_INFO, "RequestSwornInfo", {type=2})
	--addNetLoading(SWORN_CS_REQUEST_INFO,SWORN_SC_SKILL_INFO)
    g_msgHandlerInst:registerMsgHandler( SWORN_SC_SKILL_INFO , skillInfo )
    
    -- init data 
    self.skillPoint = 0
    self.skillsTab = {}
    self:updateAllItems()
end

function JieYiSkillLayer:setOpenedSlotId()
    -- load skill icons
    self.openedSlotId = {}
    for k,v in pairs(self.skillsTab) do
        for m,n in pairs(self.btnsTab) do
            if v == n.skillId then
                --n:setEnabled(true)
                table.insert(self.openedSlotId,n.slotId)
            end
        end    
    end
end

function JieYiSkillLayer:setSlotCanClick()
    for k,v in pairs(self.btnsTab) do
        v.canClick = false
        v.icon:addColorGray()
        -- check pre skill
        local preSkillOpend = true
        if #v.preSkillID ~= 0 then
            for m,n in pairs(v.preSkillID) do
                if not self:isSlotIdOpened(n) then
                    preSkillOpend = false
                    break
                end
            end        
        end

        if preSkillOpend and v.skillCost <= self.skillPoint then
            v.canClick = true
            --v:setEnabled(true)
        end

        -- already learned
        for m,n in pairs(self.skillsTab) do
            if v.skillId == n then
                v.canClick = false
                v.icon:removeColorGray()
                break    
            end
        end
    end
end

function JieYiSkillLayer:addLines()
    local node = self.svNode
    local lineData = require("src/config/jySkillLineInfo") 
    local anchorPoint = cc.p(0.5,0.5)
    self.lineTab = {}
    for k,v in pairs(lineData) do
        local line = createSprite(node,"res/jieyi/z.png",cc.p(v.pos[1],v.pos[2]),anchorPoint,ITEMZORDERS.LINESZORDER)
        line:setFlippedY( tonumber(v.isFlip) == 1 and true or false )
        line.frontId = v.frontId
        line.backId = v.backId
        table.insert(self.lineTab,line)
    end
end

function JieYiSkillLayer:updateLines()
    for _,line in pairs(self.lineTab) do
        line:setVisible(false)
        if self:isSlotIdOpened(line.frontId) and self:isSlotIdOpened(line.backId) then
            line:setVisible(true)     
        end
    end
end

function JieYiSkillLayer:addTXing()
    local node = self.svNode
    local txingData = require("src/config/JYTPosInfo")
    local anchorPoint = cc.p(0.5,0.5)
    self.txingTab = {}
    for k,v in pairs(txingData) do
        local txing = createSprite(node,"res/jieyi/txing.png",cc.p(v.pos[1],v.pos[2]),anchorPoint,ITEMZORDERS.TXINGZORDER)
        txing:setFlippedX( tonumber(v.isFlip) == 1 and true or false )
        txing.btnId1 = v.btnId1
        txing.btnId2 = v.btnId2
        txing.btnId3 = v.btnId3
        table.insert(self.txingTab,txing)
    end
end

function JieYiSkillLayer:updateTXing()
    for _,txing in pairs(self.txingTab) do
        txing:setVisible(false)
        if self:isSlotIdOpened(txing.btnId1) and self:isSlotIdOpened(txing.btnId2) and self:isSlotIdOpened(txing.btnId3) then
            txing:setVisible(true)     
        end
    end
end

function JieYiSkillLayer:addPoints()
    local node = self.svNode
    local pointsData = require("src/config/jySkillPointPosInfo")
    local anchorPoint = cc.p(0.5,0.5)
    local pointsTab = {}
    for k,v in pairs(pointsData) do
        local point = createSprite(node,"res/jieyi/jiaobiao.png",cc.p(v.pos[1],v.pos[2]),anchorPoint,ITEMZORDERS.POINTSZORDER)
        table.insert(pointsTab,point)
    end
end

function JieYiSkillLayer:addNewSkill(skillId,skillPoint)
    for k,v in pairs(self.skillsTab) do
        if v == skillId then
            skillId = nil
        end
    end
    if skillId then
        table.insert(self.skillsTab,skillId)
        self.skillPoint = skillPoint
        self:updateAllItems()
    end
end

function JieYiSkillLayer:addSkillBtns()
    local node = self.svNode
    local btnsData = require("src/config/jySkillBtnPosInfo")
    local anchorPoint = cc.p(0.5,0.5)
    self.btnsTab = {}
    local function onSkillClickRet(luaBuffer)
        local retTable = g_msgHandlerInst:convertBufferToTable("OperateSwornPsvSkillRet", luaBuffer)
        if retTable.type == 1 then
            self:addNewSkill(retTable.skill_id,retTable.points)
        end
    end

    local function sendSkillLearn(skillId)
        g_msgHandlerInst:sendNetDataByTableExEx(SWORN_CS_OPERATE_PSV_SKILL, "OperateSwornPsvSkill", {type=1,skill_id=skillId})
	    --addNetLoading(,)
        g_msgHandlerInst:registerMsgHandler( SWORN_SC_OPERATE_PSV_SKILLRET , onSkillClickRet )
    end
    local function onSkillClick(_,a2) 
        local canClick = a2.canClick
        if not canClick or not self.isBigBoss then
            MessageBox(a2.description,nil,nil)
            return
        end

        MessageBoxYesNo(a2.title,a2.description, function () sendSkillLearn(a2.skillId) end,nil, game.getStrByKey("jieyi_active") )        
    end
    for k,v in pairs(btnsData) do
        local btn = createMenuItem(node,"res/jieyi/skillbtn.png",cc.p(v.pos[1],v.pos[2]),onSkillClick,ITEMZORDERS.BUTTONSLOTZORDER)
        btn.slotId = v.id
        --btn:setEnabled(false)
        table.insert(self.btnsTab,btn)
    end

    local localData = require("src/config/SwornSkill")
    for k,v in pairs(localData) do
        for m,n in pairs(self.btnsTab) do
           if n.slotId == v.q_id then
               local icon = createGraySprite(n,"res/jieyi/" .. v.q_icon .. ".png",cc.p(54.5,54.5),cc.p(0.5,0.5))
               n.icon = icon
               n.skillId = v.q_id
               n.description = v.q_description
               n.title = v.q_Name
               n.skillCost = v.q_cost
               n.preSkillID = v.q_PreSkillID ~= nil and stringsplit(v.q_PreSkillID,",") or {}
           end
        end
    end
end

function JieYiSkillLayer:isSlotIdOpened(slotId)
    slotId = tonumber(slotId)
    for k,v in pairs(self.openedSlotId) do
        if v == slotId then
            return true
        end
    end
    return false
end

function JieYiSkillLayer:addResetBtn(bg_6)
    createLabel(bg_6,game.getStrByKey("jy_validSkillPoint"),cc.p(706,31),cc.p(1,0.5),20,nil,nil,nil,MColor.lable_yellow) 
    self.skillPointLabel = createLabel(bg_6,0,cc.p(708,31),cc.p(0,0.5),22,nil,nil,nil,MColor.lable_yellow) 
    
    local function onResetBtnClickRet(luaBuffer)
        local retTable = g_msgHandlerInst:convertBufferToTable("OperateSwornPsvSkillRet", luaBuffer)
        if retTable.type == 2 then
            -- reset
            self.skillPoint = retTable.points
            self.skillsTab = {}
            self:updateAllItems()
        end 
        
        -- clear skilltab
    end
    local function onResetBtnClick()
        g_msgHandlerInst:sendNetDataByTableExEx(SWORN_CS_OPERATE_PSV_SKILL, "OperateSwornPsvSkill", {type=2} )
	    --addNetLoading(,)
        g_msgHandlerInst:registerMsgHandler( SWORN_SC_OPERATE_PSV_SKILLRET , onResetBtnClickRet )
    end
    local btn = createMenuItem(bg_6,"res/component/button/49.png",cc.p(820,32),onResetBtnClick)
    createLabel(btn,game.getStrByKey("jy_resetBtn"),cc.p(66,20),cc.p(0.5,0.5),22,nil,nil,nil,MColor.lable_yellow)
    btn:setEnabled(false)
    if self.isBigBoss then
        btn:setEnabled(true)
    end
end 

function JieYiSkillLayer:unregisterNetWorkCallBack()  
    local function eventCallback(eventType)
        if eventType == "exit" then
            g_msgHandlerInst:registerMsgHandler( SWORN_SC_SKILL_INFO , nil )  
            g_msgHandlerInst:registerMsgHandler( SWORN_SC_OPERATE_PSV_SKILLRET , nil )  
        end
    end
     self:registerScriptHandler(eventCallback)
end

return JieYiSkillLayer