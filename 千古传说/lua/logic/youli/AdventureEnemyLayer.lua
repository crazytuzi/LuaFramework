--[[
******杀戮记录层*******

    -- by Chikui Peng
    -- 2016/3/31
]]

local AdventureEnemyLayer = class("AdventureEnemyLayer", BaseLayer)

function AdventureEnemyLayer:ctor(data)
    self.super.ctor(self, data)
    self.dataList = {}
    self:init("lua.uiconfig_mango_new.youli.ChouRenRecord")
end

function AdventureEnemyLayer:initUI(ui)
    self.super.initUI(self, ui)
    self.Panel_list = TFDirector:getChildByPath(ui, "panel_list")
    self.btn_help   = TFDirector:getChildByPath(ui, "btn_help")
    self.btn_close  = TFDirector:getChildByPath(ui, "btn_close")
    self.btn_close.logic = self
    self:initTableView()
end

function AdventureEnemyLayer:onShow()
    self.super.onShow(self)
    if AdventureManager.isFightingEnemy == true then
        AdventureManager.isFightingEnemy = false
        AdventureManager:requestEnemyList()
    end
end

function AdventureEnemyLayer:registerEvents()
    self.super.registerEvents(self)
    ADD_ALERT_CLOSE_LISTENER(self,self.btn_close)
    self.btn_close:setClickAreaLength(100);
    self.btn_help:addMEListener(TFWIDGET_CLICK, audioClickfun(handler(AdventureEnemyLayer.OnRuleClick,self)))

    self.fuchouEndCallBack = function ( event )
        if event.data[1].type == 21 then
            AdventureManager:requestEnemyList()
        end
    end
    TFDirector:addMEGlobalListener(AdventureManager.fightEndMessage, self.fuchouEndCallBack)

    self.getDataListCallBack = function ( event )
        self:initTableData()
        self.tableView:reloadData()
    end
    TFDirector:addMEGlobalListener(AdventureManager.enemyListData, self.getDataListCallBack)
end


function AdventureEnemyLayer:removeEvents()
    self.super.removeEvents(self)
    TFDirector:removeMEGlobalListener(AdventureManager.fightEndMessage, self.fuchouEndCallBack)
    TFDirector:removeMEGlobalListener(AdventureManager.enemyListData, self.getDataListCallBack)
end

function AdventureEnemyLayer:dispose()
    self.super.dispose(self)
end

function AdventureEnemyLayer:OnRuleClick( sender )
    CommonManager:showRuleLyaer('youlichouren')
end

function AdventureEnemyLayer:initTableData()
    self.dataList = AdventureManager:getEnemyList() or {}
end

function AdventureEnemyLayer:initTableView()
    self:initTableData()
    local  tableView =  TFTableView:create()

    self.tableView = tableView
    tableView:setTableViewSize(self.Panel_list:getContentSize())
    tableView:setDirection(TFTableView.TFSCROLLVERTICAL)
    tableView:setVerticalFillOrder(TFTableView.TFTabViewFILLTOPDOWN)

    self.tableView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, handler(AdventureEnemyLayer.cellSizeForTable,self))
    self.tableView:addMEListener(TFTABLEVIEW_SIZEATINDEX, handler(AdventureEnemyLayer.tableCellAtIndex,self))
    self.tableView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, handler(AdventureEnemyLayer.numberOfCellsInTableView,self))
    --self.tableView:addMEListener(TFTABLEVIEW_SCROLL, handler(AdventureEnemyLayer.tableScroll,self))
    self.Panel_list:addChild(tableView)
    self.tableView:reloadData()
end

function AdventureEnemyLayer:cellSizeForTable(table,idx)
    return 156,760
end

function AdventureEnemyLayer:tableCellAtIndex(table, idx)
    idx = idx + 1
    local cell = table:dequeueCell()
    if nil == cell then
        cell = TFTableViewCell:create()
        local node = createUIByLuaNew("lua.uiconfig_mango_new.youli.ChouRenCell")
        cell:addChild(node,1,101)

        --[[local img_bg = TFDirector:getChildByPath(node, "bg")
        img_bg:setScale9Enabled(true)
        img_bg:setImageSizeType(1)
        img_bg:setCapInsets(CCRectMake(25,20,20,45))
        img_bg:setContentSize(node:getSize())]]
        local txt_time = TFDirector:getChildByPath(cell, "txt_time")
        self.strTimeLast = txt_time:getString()
        local txt_zhanli = TFDirector:getChildByPath(cell, "txt_zhanli")
        txt_zhanli:setColor(ccc3(182,72,47))
    end
    self:setCellInfo(cell,idx)
    return cell
end

function AdventureEnemyLayer:numberOfCellsInTableView(table)
    local num = #self.dataList
    if num < 0 then num = 0 end
    return num
end

function AdventureEnemyLayer:setCellInfo(cell,idx)
    local info = self.dataList[idx]
    if info == nil then
        cell:getChildByTag(101):setVisible(false)
        return
    end
    cell:getChildByTag(101):setVisible(true)
    local headIcon = TFDirector:getChildByPath(cell, "Img_icon")
    local txt_time = TFDirector:getChildByPath(cell, "txt_time")
    local txt_shalu = TFDirector:getChildByPath(cell, "txt_shalu")
    local txt_tongbi = TFDirector:getChildByPath(cell, "txt_tongbi")
    local txt_yueli = TFDirector:getChildByPath(cell, "txt_yueli")
    local txt_name = TFDirector:getChildByPath(cell, "txt_name")
    local txt_guild = TFDirector:getChildByPath(cell, "txt_guild")
    local txt_zhanli = TFDirector:getChildByPath(cell, "txt_zhanli")
    local txt_shaluzhi = TFDirector:getChildByPath(cell, "txt_shaluzhi")
    local txt_gold = TFDirector:getChildByPath(cell, "txt_gold")
    local txt_free = TFDirector:getChildByPath(cell, "txt_free")
    local img_gold = TFDirector:getChildByPath(cell, "img_gold")
    local btn_fight = TFDirector:getChildByPath(cell, "btn_fight")
    local role = RoleData:objectByID(info.icon)
    if role then
        headIcon:setTexture(role:getIconPath())
    end
    Public:addFrameImg(headIcon,info.headPicFrame)
    Public:addInfoListen(headIcon,true,2,info.id)
    txt_name:setText(info.name)

    self.strTimeLast = self.strTimeLast or ""

    local time = (MainPlayer:getNowtime() - info.battleTime/1000)/60
    local timeType = localizable.time_minute_txt
    if time < 0 then time = 1 end
    if time > 60 then 
        timeType = localizable.time_hour_txt
        time = time / 60
        if time > 24 then
            timeType = localizable.time_day_txt
            time = time / 24
        end
    end
    
    txt_time:setText(math.floor(time)..timeType..self.strTimeLast)

    txt_shalu:setText(info.rewardMassacre)

    txt_tongbi:setText(info.rewardCoin)

    txt_yueli:setText(info.rewardExperience)

    txt_zhanli:setText(info.power)

    txt_shaluzhi:setText(info.massacreValue)

    local costGold = ConstantData:objectByID("Kill.CancelRefreshCD.Gold").value
    local curCostGold = 0
    if info.revengeNum > 0 then
        local ConfigureInfo = PlayerResConfigure:objectByID(12)
        if ConfigureInfo then
            curCostGold = ConfigureInfo:getPrice(info.revengeNum)
        end
        txt_gold:setText(curCostGold.."")
        img_gold:setVisible(true)
        txt_gold:setVisible(true)
        txt_free:setVisible(false)
    else
        img_gold:setVisible(false)
        txt_gold:setVisible(false)
        txt_free:setVisible(true)
    end
    txt_guild:setText(info.guildName)
    btn_fight.curCostGold = curCostGold
    btn_fight.playerId = info.id
    btn_fight:addMEListener(TFWIDGET_CLICK, audioClickfun(handler(AdventureEnemyLayer.OnFightClick,self)),1)
end

function AdventureEnemyLayer:OnFightClick(sender)
    if sender.curCostGold > 0 then
        local warningMsg = stringUtils.format(localizable.shalurecord_txt1,sender.curCostGold)
        CommonManager:showOperateSureLayer(
            function()
                AdventureManager:openShaluVsLayer(sender.playerId,AdventureManager.fightType_1)
            end,
            nil,
            {
                msg = warningMsg
            }
        )
    else
        AdventureManager:openShaluVsLayer(sender.playerId,AdventureManager.fightType_1)
    end
end
return AdventureEnemyLayer