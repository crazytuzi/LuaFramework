

local MiningAskForHelpLayer = class("MiningAskForHelpLayer", BaseLayer)


local BtnResNormalList = {}
BtnResNormalList[1] = "ui_new/friend/tab1b.png"
BtnResNormalList[2] = "ui_new/faction/tab_bpcy2.png"


local BtnResHighLightList = {}
BtnResHighLightList[1] = "ui_new/friend/tab1.png"
BtnResHighLightList[2] = "ui_new/faction/tab_bpcy.png"

function MiningAskForHelpLayer:ctor(data)
    self.super.ctor(self, data)
    self.miningIndex = data
    self:init("lua.uiconfig_mango_new.mining.FriendHelp")
end

function MiningAskForHelpLayer:initUI(ui)
    self.super.initUI(self,ui)
    self.ui = ui

    self.btn_friends    =  TFDirector:getChildByPath(ui, 'btn_friends')
    self.btn_guild      =  TFDirector:getChildByPath(ui, 'btn_add')

    self.txt_hysl       =  TFDirector:getChildByPath(ui, 'txt_hysl')
    self.txt_sl         =  TFDirector:getChildByPath(ui, 'txt_sl')
    self.txt_shangxian  =  TFDirector:getChildByPath(ui, 'txt_shangxian')


    self.typeButton = {}
    self.typeButton[1] = self.btn_friends

    self.typeButton[2] = self.btn_guild

    -- cell
    self.Panel_FriendCell  =  TFDirector:getChildByPath(ui, 'Panel_FriendCell')
    self.Panel_FriendCell:setVisible(false)


    self.Panel_FriendList = TFDirector:getChildByPath(ui, 'Panel_List')

    self.MemberList    = TFArray:new()

    self.typeIndex = 1
    -- 对应按钮的索引
    self.curChooseTypeIndex  = 0
    self:drawDefaultType(self.typeIndex)

    -- txt_sl 隐藏
    self.txt_sl:setVisible(false)

    print("----MiningManager:requestGuardPlayer")
    MiningManager:requestGuardPlayer()
end

function MiningAskForHelpLayer:registerEvents(ui)
    self.super.registerEvents(self)

    for i=1,2 do
        self.typeButton[i].index = i
        self.typeButton[i].logic = self
        self.typeButton[i]:addMEListener(TFWIDGET_CLICK, audioClickfun(self.OnclikTypeButton),1)
    end

    
    self.askForHelpCallBack = function(event)
        AlertManager:close(AlertManager.TWEEN_NONE);
    end
    TFDirector:addMEGlobalListener(MiningManager.EVENT_ASK_FOR_HELP_RESULT, self.askForHelpCallBack)


    self.getGuardListCallBack = function(event)
        self:filterMemList()
        self:drawTableview()

        -- local str = TFLanguageManager:getString(ErrorCodeData.Mining_UI2)
        self.txt_shangxian:setText(localizable.Mining_UI2)

        -- str = TFLanguageManager:getString(ErrorCodeData.Mining_UI1)
        -- str = string.format(str, self.maxMemberNum)
        local str = stringUtils.format(localizable.Mining_UI1, self.maxMemberNum)

        self.txt_hysl:setText(str)
    end
    TFDirector:addMEGlobalListener(MiningManager.EVENT_GUARD_REPLAY_LIST_RESULT, self.getGuardListCallBack)
end

function MiningAskForHelpLayer:removeEvents()

    TFDirector:removeMEGlobalListener(MiningManager.EVENT_ASK_FOR_HELP_RESULT, self.askForHelpCallBack)
    self.askForHelpCallBack = nil

    TFDirector:removeMEGlobalListener(MiningManager.EVENT_GUARD_REPLAY_LIST_RESULT, self.getGuardListCallBack)
    self.getGuardListCallBack = nil

    self.super.removeEvents(self)
end

function MiningAskForHelpLayer:onShow()
    self.super.onShow(self)
    self:refreshBaseUI()
end

function MiningAskForHelpLayer:refreshBaseUI()


end

function MiningAskForHelpLayer:removeUI()
   self.super.removeUI(self)
end

function MiningAskForHelpLayer.OnclikTypeButton(sender)
    local self  = sender.logic
    local index = sender.index

    if self.curChooseTypeIndex == index then
        return
    end

    self:drawDefaultType(index)
end


function MiningAskForHelpLayer:drawDefaultType(index)
    if self.curChooseTypeIndex == index then
        return
    end

    local btn = nil
    -- 绘制上面的按钮
    if self.btnLastIndex ~= nil then
        btn = self.typeButton[self.btnLastIndex]
        btn:setTextureNormal(BtnResNormalList[self.btnLastIndex])
    end

    self.btnLastIndex = index
    self.curChooseTypeIndex  = index

    btn = self.typeButton[self.curChooseTypeIndex]
    btn:setTextureNormal(BtnResHighLightList[self.btnLastIndex])


    -- self:onClickDay(index)
    self:filterMemList()
    self:drawTableview()
    -- self.txt_hysl       =  TFDirector:getChildByPath(ui, 'txt_hysl')
    -- self.txt_sl         =  TFDirector:getChildByPath(ui, 'txt_sl')
    -- self.txt_shangxian  =  TFDirector:getChildByPath(ui, 'txt_shangxian')

    -- local str = TFLanguageManager:getString(ErrorCodeData.Mining_UI2)
    self.txt_shangxian:setText(localizable.Mining_UI2)

    -- str = TFLanguageManager:getString(ErrorCodeData.Mining_UI1)
    -- str = string.format(str, self.maxMemberNum)

    local str = stringUtils.format(localizable.Mining_UI1, self.maxMemberNum)
    self.txt_hysl:setText(str)
end

function MiningAskForHelpLayer:onClickDay(index)

end


function MiningAskForHelpLayer:drawTableview()

    if self.FriendsTableView ~= nil then
        self.FriendsTableView:reloadData()
        self.FriendsTableView:setScrollToBegin(false)
        return
    end

    local  FriendsTableView =  TFTableView:create()
    FriendsTableView:setTableViewSize(self.Panel_FriendList:getContentSize())
    FriendsTableView:setDirection(TFTableView.TFSCROLLVERTICAL)
    FriendsTableView:setVerticalFillOrder(TFTableView.TFTabViewFILLTOPDOWN)
    FriendsTableView:setPosition(self.Panel_FriendList:getPosition())
    self.FriendsTableView = FriendsTableView
    self.FriendsTableView.logic = self

    FriendsTableView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, self.cellSizeForTable)
    FriendsTableView:addMEListener(TFTABLEVIEW_SIZEATINDEX, self.tableCellAtIndex)
    FriendsTableView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, self.numberOfCellsInTableView)
    FriendsTableView:reloadData()

    self.Panel_FriendList:getParent():addChild(self.FriendsTableView,1)
end


function MiningAskForHelpLayer.numberOfCellsInTableView(table)
    local self  = table.logic
    local num   = self.MemberList:length()
    return num
end

function MiningAskForHelpLayer.cellSizeForTable(table,idx)
    return 137, 718
end

function MiningAskForHelpLayer.tableCellAtIndex(table, idx)
    local self = table.logic
    local cell = table:dequeueCell()
    local node = nil
    if nil == cell then
        table.cells = table.cells or {}
        cell = TFTableViewCell:create()
        table.cells[cell] = true

        node = self.Panel_FriendCell:clone()

        node:setPosition(ccp(5, 0))
        cell:addChild(node)
        node:setTag(617)
        node.logic = self
        node:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onClickOpenDiag))
    end

    node = cell:getChildByTag(617)
    node.index = idx + 1
    self:drawFriendTitle(node)

    node:setVisible(true)
    return cell
end

function MiningAskForHelpLayer:drawFriendTitle(node)
    local img_head      = TFDirector:getChildByPath(node, 'Img_icon')
    local txt_level     = TFDirector:getChildByPath(node, 'txt_level')
    local txt_name      = TFDirector:getChildByPath(node, 'txt_name')
    local txt_vip       = TFDirector:getChildByPath(node, 'txt_vip')
    local txt_power     = TFDirector:getChildByPath(node, 'txt_zdl')
    local btn_request   = TFDirector:getChildByPath(node, 'Btn_send')
    local img_headBg   = TFDirector:getChildByPath(node, 'bg_head')

    local index         = node.index

    btn_request.logic = self
    btn_request.index = index
    btn_request:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onClickRequestHelp))


    img_headBg.logic = self
    img_headBg.index = index
    --img_headBg:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onClickOpenDiag))

    local playerInfo = self.MemberList:objectAt(index)

    if playerInfo == nil then
        print("can't find player...")
        return
    end

    --txt_power:setText("战斗力:"..playerInfo.minePower)
    txt_power:setText(stringUtils.format(localizable.common_CE,playerInfo.minePower))
    txt_vip:setText("o"..playerInfo.vip)
    txt_name:setText(playerInfo.name)
    txt_level:setText(playerInfo.level)

    local RoleIcon = RoleData:objectByID(playerInfo.icon)                       --pck change head icon and head icon frame
    img_head:setTexture(RoleIcon:getIconPath())
    Public:addFrameImg(img_head,playerInfo.headPicFrame)                       --end

    btn_request.playerId = playerInfo.playerId
    --自己不能查看自己
    if playerInfo.playerId == MainPlayer:getPlayerId() then
        img_headBg:setTouchEnabled(false)
        txt_name:setColor(ccc3(145,60,41))
        Public:addInfoListen(img_head,false)
    else
        img_headBg:setTouchEnabled(true)
        txt_name:setColor(ccc3(61,61,61))
        Public:addInfoListen(img_head,true,1,playerInfo.playerId)
    end
end


function MiningAskForHelpLayer.onClickOpenDiag(sender)
    -- 暂时头像不做点击
    if 1 then
        return
    end

    local self  = sender.logic
    local index = sender.index

    local player = self.MemberList:objectAt(index)

    if player == nil then
        return
    end

    local info = {}
    info.profession     = player.profession
    info.level          = player.level
    info.name           = player.name
    info.vip            = player.vip
    info.power          = player.minePower or 0
    info.lastLoginTime  = player.lastLoginTime
    info.playerId       = player.playerId
    info.online         = player.online
    info.icon           = player.icon                         --pck change head icon and head icon frame
    info.headPicFrame    = player.headPicFrame           --end

    local layer = require("lua.logic.friends.FriendInfoLayer"):new(1)
    AlertManager:addLayer(layer,AlertManager.BLOCK_AND_GRAY_CLOSE, AlertManager.TWEEN_1)
    layer:setInfo(info)
    AlertManager:show()
end


function MiningAskForHelpLayer.onClickRequestHelp(sender)
    local self      = sender.logic
    local index     = sender.index
    local playerId  = sender.playerId


    print("请求护矿  playerId = ", playerId)

    MiningManager:reauestGuardMine(playerId, self.miningIndex)

end

function MiningAskForHelpLayer:filterMemList()

    local player     = nil

    local chooseType = self.curChooseTypeIndex

    local filterList = self:getMyProtectPlayer()

    self.MemberList:clear()
    self.curMemberNum = 0
    -- true 过滤， false不过滤
    local function filterFunc(playerId, minePower)

        if  playerId == MainPlayer:getPlayerId() then
            -- print("111111111")
            return true
        end

        if  minePower == 0 then
            -- print("2222222222")
            return true
        end

        for k,v in pairs(filterList) do
            if playerId == v then
                -- print("3333")
                return true
            end
        end
        -- for i=1,#filterList do
        --     if playerId == filterList[i] then
        --     print("3333")
        --         return true
        --     end
        -- end

        return false
    end

    local function sortFunc(player1, player2)
        if player1.minePower > player2.minePower then
            return true
        end

        return false
    end

    -- 1 好友  2 帮派
    if chooseType == 1 then
        local friendInfoList = FriendManager:getFriendInfoList()

        self.maxMemberNum = #friendInfoList

        for i=1, #friendInfoList do
            local player = friendInfoList[i].info

            player.minePower = player.minePower or 0
            if player and filterFunc(player.playerId, player.minePower) == false then
                self.MemberList:push(player)
            end
        end

    else

        local memberInfo = FactionManager:getMemberInfo()

        self.maxMemberNum = #memberInfo

        for i=1, #memberInfo do
            local player = memberInfo[i]

            -- player.minePower = 100 + i
            player.minePower = player.minePower or 0
            if player and filterFunc(player.playerId, player.minePower) == false then
                self.MemberList:push(player)
            end
        end
    end

    self.maxMemberNum = self.MemberList:length()
    -- minePower
    if self.MemberList:length() < 1 then
        toastMessage(localizable.Mining_No_Lineup)
        return
    end

    self.MemberList:sort(sortFunc)


    self.curMemberNum = 0
    -- for i=1,#filterList do
    --     if filterList[i] > 0 then
    --         self.curMemberNum = self.curMemberNum + 1
    --     end
    -- end
    for k,v in pairs(filterList) do
        if v > 0 then
            self.curMemberNum = self.curMemberNum + 1
        end
    end
end

function MiningAskForHelpLayer:getMyProtectPlayer()
    -- GuardPlayerList
    print("MiningAskForHelpLayer:getMyProtectPlayer = ", MiningManager.GuardPlayerList)
    if MiningManager.GuardPlayerList == nil then
        print("没有护驾记录")
        return MiningManager:getMyProtectPlayer()
    end

    local list = {}

    list[1] = MiningManager.protectPlayList[1]
    list[2] = MiningManager.protectPlayList[2]
    for i=1,#MiningManager.GuardPlayerList do
        local index = 2 + i

        list[index] = MiningManager.GuardPlayerList[i]
    end

    print("list = ", list)
    return list


    -- return MiningManager:getMyProtectPlayer()
end

return MiningAskForHelpLayer
