--[[
    This module is developed by Eason
    2015/10/21
]]

local FriendLayer = class("FriendLayer", BaseLayer)

local localVars = {
    pageIndex = {friendsList = 1, addFriend = 2, applicationList = 3, friendAssist = 4},
    selectedPageIndex = 0,
    
    buttonNames = {"Btn_allget", "Btn_allsend", "Btn_changeRecommend", "Btn_requestAll", "Btn_ignoreAll", "Btn_acceptAll"},
    buttons = {},

    normalTextures   = {"ui_new/friend/tab1b.png", "ui_new/friend/tab2b.png", "ui_new/friend/tab3b.png", "ui_new/friend/tab4b.png"},
    selectedTextures = {"ui_new/friend/tab1.png" , "ui_new/friend/tab2.png", "ui_new/friend/tab3.png", "ui_new/friend/tab4.png" },

    textInputPanel = nil,
    textInput = nil,
    txt_shangxian = nil,

    tableViewDataSource = {},
}

local function switchPage(layer, index, isFromeBtn)
    if layer.sideBtns[index] then
        for i,v in ipairs(layer.sideBtns) do
            v:setTextureNormal(localVars.normalTextures[i])
            v:setTouchEnabled(true)
        end
        if isFromeBtn then
            layer.tableView:setScrollToBegin()
        end

        layer.sideBtns[index]:setTextureNormal(localVars.selectedTextures[index])
        layer.sideBtns[index]:setTouchEnabled(false)

        layer.friendAssistNode:setVisible(false)

        localVars.selectedPageIndex = index
        FriendManager:setSelectedPageIndex(index)

        localVars.txt_shangxian:setVisible(false)
        if index == localVars.pageIndex.friendsList then
            localVars.textInputPanel:setVisible(false)
            FriendManager:requestFriendList()

            CommonManager:removeRedPoint(layer.sideBtns[1])
            FriendManager:hideNewFriendRedPoint()
            localVars.txt_shangxian:setVisible(true)

        elseif index == localVars.pageIndex.addFriend then
            localVars.textInputPanel:setVisible(true)
            FriendManager:requestRecommendFriend()

        elseif index == localVars.pageIndex.applicationList then
            localVars.textInputPanel:setVisible(false)
            FriendManager:requestFriendApplyList()

            CommonManager:removeRedPoint(layer.sideBtns[3])
            FriendManager:hideNewApplyRedPoint()
        elseif index == localVars.pageIndex.friendAssist then
            localVars.textInputPanel:setVisible(false)
            layer.friendAssistNode:setVisible(true)
            layer.friendAssistCount:setText(AssistFightManager:getAssistOtherCount())


            local function friendAssistCallBack()

                layer:refreshUI() 
                layer.friendAssistCount:setText(AssistFightManager:getAssistOtherCount())    
                Public:addBtnWaterEffect(layer.friendAssistBtnReward, false,1)
                if FriendManager:isAssitAwardGet() then
                    local playerTbl = {}
                    for k,v in pairs(localVars.tableViewDataSource) do            
                        playerTbl[#playerTbl + 1] = v.baseInfo.playerId            
                    end
                    if #playerTbl > 0 then
                        Public:addBtnWaterEffect(layer.friendAssistBtnReward, true,1)
                    end
                end   

            end
            AssistFightManager:requestFriendAssistList(friendAssistCallBack)            
        end

        for i, v in ipairs(localVars.buttons) do
            if i == 2 * index - 1 then
                v:setVisible(true)
            elseif i == 2 * index then
                v:setVisible(true)
            else
                v:setVisible(false)
            end
        end

        layer:refreshUI()
        if isFromeBtn then
            local offY = 0
            if index == localVars.pageIndex.friendAssist then
                offY = layer.tableViewPanel:getContentSize().height - 168*(#localVars.tableViewDataSource)
            else
                offY = layer.tableViewPanel:getContentSize().height - 146*(#localVars.tableViewDataSource)
            end
            layer.tableView:setContentOffset(ccp(0,offY))
        end
    end
end

-- function FriendLayer.friendAssistCallBack()
    
--     local friendAssistList = AssistFightManager:getFriendAssistListForView()
--     for i, v in ipairs(friendAssistList) do
--         localVars.tableViewDataSource[i] = v
--     end
--     self:refreshUI()
-- end

function FriendLayer:ctor(data)
    self.super.ctor(self, data)

    self.buttonEvents = {
        self.onGetAll,
        self.onSendAll,
        self.onChangeRecommend,
        self.onRequestAll,
        self.onIgnoreAll,
        self.onAcceptAll}

    -- init
    self:init("lua.uiconfig_mango_new.friends.FriendList")
end

function FriendLayer:initUI(ui)
    self.super.initUI(self, ui)

    -- add topbar
    self.generalHead = CommonManager:addGeneralHead(self, 10)
    self.generalHead:setData(ModuleType.Friend, {HeadResType.COIN, HeadResType.SYCEE})

    -- friends num
    self.textFriendsNum = TFDirector:getChildByPath(ui, "txt_sl")
    assert(self.textFriendsNum)

    -- search button
    self.searchButton = TFDirector:getChildByPath(ui, "searchButton")
    assert(self.searchButton)

    -- side buttons
    self.sideBtns = {}
    local sideBtnNames = {"btn_friends", "btn_add", "btn_sq", "btn_zhuzhan"}
    for i,v in ipairs(sideBtnNames) do
        self.sideBtns[i] = TFDirector:getChildByPath(ui, v)
        assert(self.sideBtns[i])

        self.sideBtns[i].name = v
        self.sideBtns[i].parent = self
    end

    -- buttons
    for i, v in ipairs(localVars.buttonNames) do
        localVars.buttons[i] = TFDirector:getChildByPath(ui, v)
        assert(localVars.buttons[i])
    end

    -- table view
    local tableViewPanel = TFDirector:getChildByPath(ui, "Panel_List")
    assert(tableViewPanel)

    local tableView = TFTableView:create()
    tableView:setTableViewSize(tableViewPanel:getContentSize())
    tableView:setDirection(TFTableView.TFSCROLLVERTICAL)
    tableView:setVerticalFillOrder(TFTableView.TFTabViewFILLTOPDOWN)
    tableView.parent = self
    tableViewPanel:addChild(tableView)
    self.tableViewPanel = tableViewPanel

    self.tableView = tableView
    -- Public:bindScrollFun(tableView)

    -- input text
    localVars.textInputPanel = TFDirector:getChildByPath(ui, "bg_input")
    assert(localVars.textInputPanel)

    localVars.textInput = TFDirector:getChildByPath(localVars.textInputPanel, "txt_input")
    localVars.textInput.parent = self
    localVars.textInput:setMaxLengthEnabled(true)
    localVars.textInput:setMaxLength(10)
    localVars.textInput:setCursorEnabled(true)

    localVars.txt_shangxian = TFDirector:getChildByPath(ui, "txt_shangxian")

    self.cellModel = createUIByLuaNew("lua.uiconfig_mango_new.friends.FriendZhuzhanCell")
    self.cellModel:retain()

    self.friendAssistNode = TFDirector:getChildByPath(ui, "Panel_Friendzhuzhan")
    self.friendAssistBtnReward = TFDirector:getChildByPath(self.friendAssistNode, "Btn_getrewads")
    self.friendAssistBtnOneKey = TFDirector:getChildByPath(self.friendAssistNode, "Btn_allzhuzhan")
    self.friendAssistCount = TFDirector:getChildByPath(self.friendAssistNode, "txt_num")    

end

function FriendLayer:onShow()
    self.super.onShow(self)

        switchPage(self, localVars.selectedPageIndex, false)
    -- switch page
    -- if localVars.selectedPageIndex == localVars.pageIndex.friendAssist then
    --     switchPage(self, localVars.pageIndex.friendAssist, false)
    -- else
    --     switchPage(self, localVars.pageIndex.friendsList, false)
    -- end    

    if self.generalHead then
        self.generalHead:onShow()
    end

    FriendManager:hideRedPoint()
    self:updateRedPoint()
end

function FriendLayer:onHide()
    FriendManager:setSelectedPageIndex(0)
end

function FriendLayer:registerAllButtonEvents()
    for i,v in ipairs(localVars.buttons) do
        v:addMEListener(TFWIDGET_CLICK, audioClickfun(self.buttonEvents[i]))
    end
end

function FriendLayer:registerEvents()
    self.super.registerEvents(self)

    if localVars.selectedPageIndex ~= localVars.pageIndex.friendAssist then
        localVars.selectedPageIndex = localVars.pageIndex.friendsList
    end

    for _,v in pairs(self.sideBtns) do
        v:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onSideBtnsClicked))
    end

    self.searchButton:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onSearchFriend))
    self.friendAssistBtnReward:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onFriendAssistBtnReward))
    self.friendAssistBtnReward.logic = self
    self.friendAssistBtnOneKey:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onFriendAssistBtnOneKey))
    self.friendAssistBtnOneKey.logic = self


    self:registerAllButtonEvents()

    self.tableView:addMEListener(TFTABLEVIEW_SIZEFORINDEX         , self.cellSizeForTable)
    self.tableView:addMEListener(TFTABLEVIEW_SIZEATINDEX          , self.tableCellAtIndex)
    self.tableView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, self.numberOfCellsInTableView)
    self.tableView.logic = self

    self.onUpdateList = function(event)
        self:refreshUI()

        if localVars.selectedPageIndex == localVars.pageIndex.friendAssist then
            Public:addBtnWaterEffect(self.friendAssistBtnReward, false,1)
            if FriendManager:isAssitAwardGet() then
                local playerTbl = {}
                for k,v in pairs(localVars.tableViewDataSource) do            
                    playerTbl[#playerTbl + 1] = v.baseInfo.playerId            
                end
                if #playerTbl > 0 then
                    Public:addBtnWaterEffect(self.friendAssistBtnReward, true,1)
                end
            end   
        end

    end
    TFDirector:addMEGlobalListener(FriendManager.UpdateList, self.onUpdateList)

    self.getAssistRoleCallBack = function(event)
        -- local friendAssistList = AssistFightManager:getFriendAssistListForView()
        -- for i, v in ipairs(friendAssistList) do
        --     localVars.tableViewDataSource[i] = v
        -- end                
        local friendName = event.data[1][1]
        local roleName = event.data[1][2]
        -- print('event.data= ',event.data)
        if self.oldAssitCount then
            local count = AssistFightManager:getAssistOtherCount() - self.oldAssitCount
            if count ~= 0 then
                -- local str = TFLanguageManager:getString(ErrorCodeData.Assist_Assist_success_they)
                -- str = string.format(str, count)                
                local str = stringUtils.format(localizable.Assist_Assist_success_they, count)

                if self.delayMessageTimer then
                    TFDirector:removeTimer(self.delayMessageTimer)
                    self.delayMessageTimer = nil
                end
                self.delayMessageTimer = TFDirector:addTimer(400, -1, nil, function () 
                    if self.delayMessageTimer then
                        TFDirector:removeTimer(self.delayMessageTimer)
                        self.delayMessageTimer = nil
                    end
                    toastMessage(str)
                end)                
            end
            self.oldAssitCount = nil
        else
            if friendName and roleName then
                -- local str = TFLanguageManager:getString(ErrorCodeData.Assist_Somebody_Assist_You)
                -- str = string.format(str, friendName, roleName)
                local str = stringUtils.format(localizable.Assist_Somebody_Assist_You, friendName, roleName)
                
                toastMessage(str)
            end
        end
        self:refreshUI()
        self.friendAssistCount:setText(AssistFightManager:getAssistOtherCount())
    end
    TFDirector:addMEGlobalListener(AssistFightManager.GETASSISTROLESUCCESSFORFRIEND, self.getAssistRoleCallBack)    

    if self.generalHead then
        self.generalHead:registerEvents()
    end
end

function FriendLayer:removeEvents()
    for _,v in pairs(self.sideBtns) do
        v:removeMEListener(TFWIDGET_CLICK)
    end

    self.searchButton:removeMEListener(TFWIDGET_CLICK)

    for _,v in pairs(localVars.buttons) do
        v:removeMEListener(TFWIDGET_CLICK)
    end

    self.tableView:removeMEListener(TFTABLEVIEW_SIZEFORINDEX)
    self.tableView:removeMEListener(TFTABLEVIEW_SIZEATINDEX)
    self.tableView:removeMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW)

    TFDirector:removeMEGlobalListener(FriendManager.UpdateList, self.onUpdateList)
    self.onUpdateList = nil
    TFDirector:removeMEGlobalListener(AssistFightManager.GETASSISTROLESUCCESSFORFRIEND, self.getAssistRoleCallBack)
    self.getAssistRoleCallBack = nil

    if self.generalHead then
        self.generalHead:removeEvents()
    end
    if self.delayMessageTimer then
        TFDirector:removeTimer(self.delayMessageTimer)
        self.delayMessageTimer = nil
    end
    self.super.removeEvents(self)
end

function FriendLayer:dispose()
    if self.generalHead then
        self.generalHead:dispose()
        self.generalHead = nil
    end

    if self.cellModel then
        self.cellModel:release()
        self.cellModel = nil
    end

    self.super.dispose(self)
end

function FriendLayer.onSideBtnsClicked(sender)
    if sender.name == "btn_friends" then
        switchPage(sender.parent, localVars.pageIndex.friendsList,true)
    elseif sender.name == "btn_add" then
        switchPage(sender.parent, localVars.pageIndex.addFriend,true)
    elseif sender.name == "btn_sq" then
        switchPage(sender.parent, localVars.pageIndex.applicationList,true)
    elseif sender.name == "btn_zhuzhan" then
        local openLevel = FunctionOpenConfigure:getOpenLevel(1203)
        if MainPlayer:getLevel() >= openLevel then
            switchPage(sender.parent, localVars.pageIndex.friendAssist,true)
        else
            toastMessage(localizable.Assist_No_open)
        end        
    end
end

function FriendLayer.cellSizeForTable(table, idx)
    -- print('-----------refreshUI--------------',localVars.selectedPageIndex)
    if localVars.selectedPageIndex == localVars.pageIndex.friendAssist then
        return 168,731
    else
        return 148,731
    end
end

function FriendLayer.tableCellAtIndex(table, idx)
    local self = table.logic
    local cell = table:dequeueCell()

    if not cell then
        cell = TFTableViewCell:create()

        local friendCell = require("lua.logic.friends.FriendCell"):new()
        cell.friendCell = friendCell
        cell:addChild(friendCell)
        friendCell:setVisible(false)

        local assistCell = self.cellModel:clone()
        cell.assistCell = assistCell
        cell:addChild(assistCell)
        assistCell:setVisible(false)
    end
    -- print('localVars.tableViewDataSource = ',table:getContentSize())
    -- print('localVars.tableViewDataSource = ',table:getContentOffset())
    if localVars.selectedPageIndex == localVars.pageIndex.friendAssist then
        cell.friendCell:setVisible(false)
        cell.assistCell:setVisible(true)
        cell.assistCell:setPosition(ccp(0,0))
        self:cellInfoSet(cell.assistCell, idx+1)
    else
        cell.friendCell:setVisible(true)
        cell.assistCell:setVisible(false)
        cell.friendCell:setPosition(ccp(0,0))
        cell.friendCell:setInfo(localVars.selectedPageIndex, localVars.tableViewDataSource[idx + 1])
    end    

    return cell
end


function FriendLayer:cellInfoSet( panel, idx )

    if panel.boundData == nil then
        panel.boundData = true
        panel.userHeadNode = TFDirector:getChildByPath(panel, 'bg_head')
        panel.userHead = TFDirector:getChildByPath(panel.userHeadNode, 'Img_icon')
        panel.userLevel = TFDirector:getChildByPath(panel.userHeadNode, 'txt_level')
        panel.userVip = TFDirector:getChildByPath(panel, 'txt_vip')
        panel.userName = TFDirector:getChildByPath(panel, 'txt_name')

        --added by wuqi
        panel.userImgVip = TFDirector:getChildByPath(panel, "img_vip")

        panel.provideInfo = {}
        for i=1,2 do
            local bgNode = TFDirector:getChildByPath(panel, 'rolebg'..i)
            panel.provideInfo[i] = {}
            --panel.provideInfo[i].btn
            panel.provideInfo[i].btnFrame = TFDirector:getChildByPath(panel, 'rolebg'..i)
            panel.provideInfo[i].btn = TFDirector:getChildByPath(bgNode, 'roleicon')
            panel.provideInfo[i].count = TFDirector:getChildByPath(bgNode, 'txt_cishu')
            panel.provideInfo[i].noCount = TFDirector:getChildByPath(bgNode, 'img_wucishu')
            panel.provideInfo[i].roleName = TFDirector:getChildByPath(bgNode, 'txt_rolename')
            panel.provideInfo[i].playerNameBg = TFDirector:getChildByPath(bgNode, 'bg_suoqu'..i)
            panel.provideInfo[i].playerName = TFDirector:getChildByPath(bgNode, 'txt_suoqu')

            panel.provideInfo[i].btn:setTouchEnabled(true)
            panel.provideInfo[i].btn.idx = i
            panel.provideInfo[i].btn.logic = self            
            panel.provideInfo[i].btn:addMEListener(TFWIDGET_CLICK,audioClickfun(self.provideBtnClick))
        end

        local requestNode = TFDirector:getChildByPath(panel, 'bg_xuqiu')
        panel.requestBtn = TFDirector:getChildByPath(requestNode, 'roleicon')
        panel.requestRoleName = TFDirector:getChildByPath(requestNode, 'txt_rolename3')
        panel.requestPlayerNameBg = TFDirector:getChildByPath(requestNode, 'bg_tigong')
        panel.requestPlayerName = TFDirector:getChildByPath(requestNode, 'txt_tigong')
        panel.requestDone = TFDirector:getChildByPath(requestNode, 'icon_yizhuzhan')

        panel.requestBtn:setTouchEnabled(true)
        panel.requestBtn.logic = self
        panel.requestBtn:addMEListener(TFWIDGET_CLICK,audioClickfun(self.requestBtnClick))
    end

    panel.requestBtn.idx = idx
    panel.provideInfo[1].btn.cellIdx = idx
    panel.provideInfo[2].btn.cellIdx = idx

    local dataInfo = localVars.tableViewDataSource[idx]

    --added by wuqi
    panel.userVip:setVisible(true)
    panel.userImgVip:setVisible(false)

    if dataInfo then
        --baseInfo
        local RoleIcon = RoleData:objectByID(dataInfo.baseInfo.icon)                                --pck change head icon and head icon frame
        panel.userHead:setTexture(RoleIcon:getIconPath())
        Public:addFrameImg(panel.userHead,dataInfo.baseInfo.headPicFrame)                          --end
        Public:addInfoListen(panel.userHead,true,1,dataInfo.baseInfo.playerId)
        panel.userLevel:setText(dataInfo.baseInfo.level.."d")
        panel.userVip:setText("o"..dataInfo.baseInfo.vip)
        panel.userName:setText(dataInfo.baseInfo.name)

        --added by wuqi
        if dataInfo.baseInfo.vip > 15 then
            panel.userVip:setVisible(false)
            panel.userImgVip:setVisible(true)
            Public:addVipEffect(panel.userImgVip, dataInfo.baseInfo.vip, 0.64)
        end

        -- print('dataInfo = ',dataInfo)
        for i=1,2 do
            if dataInfo.provideRole[i] and dataInfo.provideRole[i].role then
                panel.provideInfo[i].btnFrame:setVisible(true)
                panel.provideInfo[i].btnFrame:setTexture(GetColorIconByQuality(dataInfo.provideRole[i].role.quality))
                panel.provideInfo[i].btn:setTexture(dataInfo.provideRole[i].role:getIconPath())
                panel.provideInfo[i].roleName:setText(dataInfo.provideRole[i].role.name)
                
                panel.provideInfo[i].noCount:setVisible(false)
                panel.provideInfo[i].playerNameBg:setVisible(false)
                panel.provideInfo[i].count:setVisible(false)

                local count = dataInfo.provideRole[i].maxTimes - dataInfo.provideRole[i].times
                if dataInfo.provideRole[i].times == 0 then
                    panel.provideInfo[i].count:setVisible(true)
                    panel.provideInfo[i].count:setText(dataInfo.provideRole[i].times .. '/' .. dataInfo.provideRole[i].maxTimes)
                elseif count <= 0 then
                    panel.provideInfo[i].noCount:setVisible(true)
                    panel.provideInfo[i].playerNameBg:setVisible(true)
                    
                    panel.provideInfo[i].playerName:setText(dataInfo.provideRole[i].playerName)
                else
                    panel.provideInfo[i].count:setVisible(true)
                    panel.provideInfo[i].count:setText(dataInfo.provideRole[i].times .. '/' .. dataInfo.provideRole[i].maxTimes)
                    panel.provideInfo[i].playerNameBg:setVisible(true)
                    panel.provideInfo[i].playerName:setText(dataInfo.provideRole[i].playerName)
                end
            else
                panel.provideInfo[i].btnFrame:setVisible(false)
            end
        end

        -- print('dataInforequestRole = ',dataInfo.requestRole)
        if dataInfo.requestRole.role then
            panel.requestBtn:setVisible(true)
            panel.requestBtn:setTexture(dataInfo.requestRole.role:getIconPath())
            panel.requestRoleName:setText(dataInfo.requestRole.role.name)
            panel.requestPlayerNameBg:setVisible(false)
            panel.requestDone:setVisible(false)

            if dataInfo.requestRole.playerName and dataInfo.requestRole.playerName ~= "" then
                -- print('dataInfo.requestRole.playerName = ',dataInfo.requestRole.playerName)
                panel.requestPlayerNameBg:setVisible(true)
                panel.requestPlayerName:setText(dataInfo.requestRole.playerName)               
            end 
            CommonManager:updateRedPoint(panel.requestBtn, false, ccp(10, 10))       

            if dataInfo.isGive then
                panel.requestDone:setVisible(true)
            elseif self:canGiveRole( dataInfo.baseInfo.playerId, dataInfo.requestRole.role, false ) then
                CommonManager:updateRedPoint(panel.requestBtn, true, ccp(10, 10))
            end
        else
            panel.requestBtn:setVisible(false)
        end
    end
end

function FriendLayer.numberOfCellsInTableView(table)
    -- print('#localVars.tableViewDataSource = ',#localVars.tableViewDataSource)
    return #localVars.tableViewDataSource
end

function FriendLayer:refreshUI()
    self.textFriendsNum:setText(#FriendManager:getFriendInfoList() .. "/" .. VipRuleManager:getFriendNum())
    localVars.textInput:setText("")

    self:initTableViewDataSource()

    -- print('-----------refreshUI---RRRRRRRRRRR-----------',localVars.selectedPageIndex)    
    -- self.tableView:reloadData()
    if localVars.selectedPageIndex == localVars.pageIndex.friendsList then 
        if self.firstdrawTbl == nil or self.firstdrawTbl == false then
            self.firstdrawTbl = true

            self.tableView:reloadData()
        else
            -- if 
            local offset = self.tableView:getContentOffset()
            -- print("offset 1 = ", offset)
            self.tableView:reloadData()
            local ContentSize = self.tableView:getContentSize()
            local ViewSize    = self.tableView:getViewSize()
            local newY2       = ContentSize.height - ViewSize.height
            -- print("ViewSize 1 = ", ViewSize)
            local newY1 = math.abs(offset.y)
            if offset.y < 0 and newY1 > newY2 then
                newY1 = 0 - newY2

                offset.y = newY1
            end
            if newY2 <= 0 then
                self.tableView:setScrollToBegin()
            else
                self.tableView:setContentOffset(offset)
            end

            
            -- print("ContentSize 1 = ", ContentSize)
        end
    else
        self.tableView:reloadData()
    end
    -- print('self.tableView:setContentOffset = ',self.tableView:getContentOffset())



    self:updateRedPoint()
end

function FriendLayer:initTableViewDataSource()
    

    localVars.tableViewDataSource = nil
    localVars.tableViewDataSource = {}

    -- if self.tableView then
    --     self.tableView:setContentOffset(ccp(0,255))
    -- end



    if localVars.selectedPageIndex == localVars.pageIndex.friendsList then
        local friendInfoList = FriendManager:getFriendInfoList()
        for i, v in ipairs(friendInfoList) do
            v.info.give = v.give
            localVars.tableViewDataSource[i] = v.info
        end
        
        -- local sortFunc = function(a, b) return b.lastLoginTime < a.lastLoginTime end
        local function sortFriendFun(friend1, friend2)
            if friend1.online == true and friend2.online == false then
                return true
                
            elseif friend1.online == friend2.online then
                if friend1.lastLoginTime <= friend2.lastLoginTime then
                    return false
                else
                    return true
                end
            end
            return false
        end
        table.sort(localVars.tableViewDataSource, sortFriendFun)

    elseif localVars.selectedPageIndex == localVars.pageIndex.addFriend then
        local recommendFriendList = FriendManager:getRecommendFriendList()
        for i, v in ipairs(recommendFriendList) do
            v.info.apply = v.apply
            localVars.tableViewDataSource[i] = v.info
        end

    elseif localVars.selectedPageIndex == localVars.pageIndex.applicationList then
        local friendApplyList = FriendManager:getFriendApplyList()
        for i, v in ipairs(friendApplyList) do
            localVars.tableViewDataSource[i] = v
        end

        local sortFunc = function(a, b) return b.lastLoginTime < a.lastLoginTime end
        table.sort(localVars.tableViewDataSource, sortFunc)
    elseif localVars.selectedPageIndex == localVars.pageIndex.friendAssist then
        localVars.tableViewDataSource = {}
        local friendAssistList = AssistFightManager:getFriendAssistListForView()
        if friendAssistList then
            for i, v in ipairs(friendAssistList) do
                localVars.tableViewDataSource[i] = v
            end                
        end  
        -- if self.tableView then
        --     self.tableView:setContentOffset(ccp(0,204))
        -- end
    end

    -- print(localVars.tableViewDataSource)
end

function FriendLayer.onSearchFriend(sender)
    local text = localVars.textInput:getText()
    if string.len(text) < 1 then
        --toastMessage("请输入玩家名称")
        toastMessage(localizable.common_input_player_name)
    else
        FriendManager:queryPlayer(text)
    end
end

function FriendLayer.onGetAll(sender)
    FriendManager:getAll()
end

function FriendLayer.onSendAll(sender)
    FriendManager:sendAll()
end

function FriendLayer.onChangeRecommend(sender)
    FriendManager:requestRecommendFriend()
end

function FriendLayer.onRequestAll(sender)
    FriendManager:requestAllFriend()
end

function FriendLayer.onIgnoreAll(sender)
    FriendManager:excuteFriendApply(4, 0)
end

function FriendLayer.onAcceptAll(sender)
    FriendManager:excuteFriendApply(2, 0)
end

function FriendLayer:updateRedPoint()
    -- print("FriendLayer:updateRedPoint()")
    CommonManager:updateRedPoint(self.sideBtns[1], FriendManager:isShowNewFriendRedPoint(), ccp(0, -10))
    CommonManager:updateRedPoint(self.sideBtns[3], FriendManager:isShowNewApplyRedPoint(), ccp(0, -10))
    CommonManager:updateRedPoint(self.sideBtns[4], FriendManager:isAssitAwardGet(), ccp(0, -10))
end

function FriendLayer.provideBtnClick( btn )
    local self = btn.logic
    local idx = btn.idx
    local dataIndex = btn.cellIdx
    local data = localVars.tableViewDataSource[dataIndex]
    if data == nil or data.provideRole[idx] == nil then
        return
    end

    if data.isGet then
        toastMessage(localizable.Assist_This_player_Already_Assist_You)
        return
    end
    if data.provideRole[idx].maxTimes <= data.provideRole[idx].times then
        toastMessage(localizable.Assist_Hero_No_time)
        return
    end   
    AssistFightManager:requestGetAssitRole( data.baseInfo.playerId, data.provideRole[idx].role.id, AssistFightManager.GETASSISTROLESUCCESSFORFRIEND )    
end

function FriendLayer.requestBtnClick( btn )
    local self = btn.logic
    local idx = btn.idx
    local data = localVars.tableViewDataSource[idx]
    self.oldAssitCount = nil
    if self:canGiveRole( data.baseInfo.playerId, data.requestRole.role, true ) then
        AssistFightManager:requestGiveAssisRole( {data.baseInfo.playerId} )
    end
end

function FriendLayer:canGiveRole( playerId, role, needMsg)
    role = role or {}
    if AssistFightManager:checkInassistPlayerList( playerId ) then
        if needMsg then
            toastMessage(localizable.Assist_Already_Assist_This_player)
        end
        return false
    end
    local cardRole = CardRoleManager:getRoleById(role.id)
    if cardRole and cardRole.gmId ~= 0 then
        local useInfo = AssistFightManager.myRoleUseCountList[cardRole.id] or {}
        local useCount = useInfo.times or 0
        -- print('cardRole.quality = ',cardRole.quality)
        -- print('AssistFightManager.myRoleUseCountList = ',AssistFightManager.myRoleUseCountList)
        if (cardRole.quality == 5 and useCount < 3) or (cardRole.quality == 4 and useCount < 1) then
            return true
        else            
            if needMsg then
                toastMessage(localizable.Assist_Their_Hero_No_time)
            end
            return false
        end
    else
        if needMsg then
            toastMessage(localizable.Assist_No_hero)
        end
        return false
    end
end

function FriendLayer.onFriendAssistBtnReward( btn )
    local self = btn.logic
    local playerTbl = {}
    if FriendManager:isAssitAwardGet() then
        for k,v in pairs(localVars.tableViewDataSource) do            
            playerTbl[#playerTbl + 1] = v.baseInfo.playerId            
        end
        if #playerTbl <= 0 then
            toastMessage(localizable.Assist_Assist_gift)
            return
        end
        AssistFightManager:requestDrawAssitAward(0)
    else
        toastMessage(localizable.Assist_Assist_gift)
    end
end

function FriendLayer.onFriendAssistBtnOneKey( btn )
    local self = btn.logic

    local playerTbl = {}
    for k,v in pairs(localVars.tableViewDataSource) do
        if v.isGive == false and self:canGiveRole( v.baseInfo.playerId, v.requestRole.role, false ) then
            playerTbl[#playerTbl + 1] = v.baseInfo.playerId
        end
    end
    if #playerTbl <= 0 then
        toastMessage(localizable.Assist_NO_Assist_friend)
        return
    end
    -- print('playerTbl = ',playerTbl)
    self.oldAssitCount = AssistFightManager:getAssistOtherCount()
    --self.oldAssitCount 区分是否为一键助战
    AssistFightManager:requestGiveAssisRole( playerTbl )
end

function FriendLayer:showZhuzhanPage()
    switchPage(self, localVars.pageIndex.friendAssist,true)
end
return FriendLayer