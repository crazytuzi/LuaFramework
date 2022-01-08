

local MiningFightReportMoreLayer = class("MiningFightReportMoreLayer", BaseLayer)

function MiningFightReportMoreLayer:ctor(data)
    self.super.ctor(self, data)
    self:init("lua.uiconfig_mango_new.mining.minimgBattleRecordDiag")
end

function MiningFightReportMoreLayer:initUI(ui)
    self.super.initUI(self,ui)
    self.ui = ui

    self.btn_close      = TFDirector:getChildByPath(ui, 'btn_close')
    self.panel_hukuang  = TFDirector:getChildByPath(ui, 'bg_zhankai2')

    self.panel_hukuang:removeFromParentAndCleanup(false)
    self.panel_hukuang:retain()

    self.Panel_FriendList = TFDirector:getChildByPath(ui, 'panel_list')
end

function MiningFightReportMoreLayer:registerEvents(ui)
    self.super.registerEvents(self)

    ADD_ALERT_CLOSE_LISTENER(self,self.btn_close)
end


function MiningFightReportMoreLayer:removeEvents()

    self.super.removeEvents(self)
end

function MiningFightReportMoreLayer:onShow()
    self.super.onShow(self)
    self:refreshUI()
end

function MiningFightReportMoreLayer:refreshUI()

    self:drawTableview()
end

function MiningFightReportMoreLayer:removeUI()

    if self.panel_hukuang then
        self.panel_hukuang:release()
    end

   self.super.removeUI(self)
end


function MiningFightReportMoreLayer:drawTableview()

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


function MiningFightReportMoreLayer.numberOfCellsInTableView(table)
    local self  = table.logic
    local num   = #MiningManager.reportList

    return num
end

function MiningFightReportMoreLayer.cellSizeForTable(table,idx)
    return 200, 773
end

function MiningFightReportMoreLayer.tableCellAtIndex(table, idx)
    local self = table.logic
    local cell = table:dequeueCell()
    local node = nil
    if nil == cell then
        table.cells = table.cells or {}
        cell = TFTableViewCell:create()
        table.cells[cell] = true

        node = self.panel_hukuang:clone()

        node:setPosition(ccp(5, 0))
        cell:addChild(node)
        node:setTag(617)
        node.logic = self
    end

    node = cell:getChildByTag(617)
    node.index = idx + 1

    self:drawCell(node)

    node:setVisible(true)
    return cell
end

function MiningFightReportMoreLayer:drawCell(node)
    local txt_times = TFDirector:getChildByPath(node, "txt_times")

    local img_hukuang   = TFDirector:getChildByPath(node, "img_hukuang")
    local img_tou1      = TFDirector:getChildByPath(node, "img_tou1")
    local img_tou2      = TFDirector:getChildByPath(node, "img_tou2")
    local txt_miaoshu   = TFDirector:getChildByPath(node, "txt_miaoshu")

    local index = node.index

    local report = MiningManager.reportList[index]
    self:drawPlayNode(img_tou1, report.fromRole, report.reportId)
    self:drawPlayNode(img_tou2, report.targetRole, report.reportId)

    --txt_times:setText("第"..index.."次打劫")
    txt_times:setText(stringUtils.format(localizable.MiningFightReLayer_dajie,index))

    local result    = report.win

    local strExtend = localizable.Mining_UI4_win
    if result == false then
        strExtend = localizable.Mining_UI4_lost
    end

    -- --%s与%s战斗，战斗失败
    local str = stringUtils.format(strExtend, report.fromRole.name, report.targetRole.name)


    txt_miaoshu:setText(str)
end

function MiningFightReportMoreLayer:drawPlayNode(node, player,reportId)
    local txt_battletime = TFDirector:getChildByPath(node, "txt_battletime")

    local img_head          = TFDirector:getChildByPath(node, "img_head")
    local txt_name          = TFDirector:getChildByPath(node, "txt_name")
    local btn_huifang       = TFDirector:getChildByPath(node, "btn_huifang")
    local img_hu            = TFDirector:getChildByPath(node, "img_hu")
    local img_headBg        = TFDirector:getChildByPath(node, "img_di")
    -- if player == nil then
    --     img_head:setVisible(false)
    --     txt_name:setVisible(false)
    --     btn_huifang:setVisible(false)
    --     if img_hu then
    --         img_hu:setVisible(false)
    --     end

    --     return
    -- end

    txt_name:setText(player.name)

    if player.icon == nil or player.icon <= 0 then                          --pck change head icon and head icon frame
        player.icon = player.profession
    end
    local roleId = player.icon
    local role = RoleData:objectByID(roleId);
    img_head:setTexture(role:getIconPath());
    Public:addFrameImg(img_head,player.headPicFrame)                       --end
    Public:addInfoListen(img_head,true,1,player.playerId)
    if player.playerId == MainPlayer:getPlayerId() then
        Public:addInfoListen(img_head,false)
    end
    btn_huifang.logic = self
    btn_huifang.reportId = reportId
    btn_huifang:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onClickFightReport))

       --     ├┄┄level=90,
       -- ├┄┄vipLevel=15,
       -- ├┄┄power=270671,
       -- ├┄┄playerId=23,
       -- ├┄┄name="铁拳问雁",
       -- ├┄┄profession=80
end

function MiningFightReportMoreLayer.onClickMoreFightReport(sender)

end

function MiningFightReportMoreLayer.onClickFightReport(sender)
    print("onclick fight report = ",sender.reportId)

            showLoading()
        TFDirector:send(c2s.PLAY_ARENA_TOP_BATTLE_REPORT, {sender.reportId})
end

return MiningFightReportMoreLayer
