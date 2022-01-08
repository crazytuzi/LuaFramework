

local MiningFightReportLayer = class("MiningFightReportLayer", BaseLayer)

function MiningFightReportLayer:ctor(data)
    self.super.ctor(self, data)
    self:init("lua.uiconfig_mango_new.mining.minimgBattleRecords")
end

function MiningFightReportLayer:initUI(ui)
    self.super.initUI(self,ui)
    self.ui = ui

    self.btn_close      = TFDirector:getChildByPath(ui, 'btn_close')
    self.panel_hukuang  = TFDirector:getChildByPath(ui, 'panel_hukuang')

    self.panel_hukuang:removeFromParentAndCleanup(false)
    self.panel_hukuang:retain()

    self.Panel_FriendList = TFDirector:getChildByPath(ui, 'panel_list')


    MiningManager:requestReplayList()
end

function MiningFightReportLayer:registerEvents(ui)
    self.super.registerEvents(self)

    ADD_ALERT_CLOSE_LISTENER(self,self.btn_close)

    self.recvReplayCallBack = function(event)
        if MiningManager.MineReplayResult then
            self:resortReportList()
            self:drawTableview()
        else
            --toastMessage("暂无记录")
            toastMessage(localizable.common_not_record)
        end
    end
    TFDirector:addMEGlobalListener(MiningManager.EVENT_GET_REPLAY_RESULT, self.recvReplayCallBack)

end


function MiningFightReportLayer:removeEvents()
    TFDirector:removeMEGlobalListener(MiningManager.EVENT_GET_REPLAY_RESULT, self.recvReplayCallBack)
    self.recvReplayCallBack = nil


    self.super.removeEvents(self)
end

function MiningFightReportLayer:onShow()
    self.super.onShow(self)
    self:refreshUI()
end

function MiningFightReportLayer:refreshUI()

    -- self:drawTableview()
end

function MiningFightReportLayer:removeUI()

    if self.panel_hukuang then
        self.panel_hukuang:release()
    end

   self.super.removeUI(self)
end


function MiningFightReportLayer:drawTableview()

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


function MiningFightReportLayer.numberOfCellsInTableView(table)
    local self  = table.logic
    local num   = #MiningManager.MineReplayResult

    return num
end

function MiningFightReportLayer.cellSizeForTable(table,idx)
    return 200, 773
end

function MiningFightReportLayer.tableCellAtIndex(table, idx)
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

function MiningFightReportLayer:drawCell(node)
    local index = node.index
    -- self.MineReplayResult.infos

    local txt_battletime = TFDirector:getChildByPath(node, "txt_battletime")
    local txt_date = TFDirector:getChildByPath(node, "txt_date")

    local img_hukuang   = TFDirector:getChildByPath(node, "img_hukuang")
    local img_tou1      = TFDirector:getChildByPath(node, "img_tou1")
    local img_tou2      = TFDirector:getChildByPath(node, "img_tou2")
    local img_tou3      = TFDirector:getChildByPath(node, "img_tou3")
    local txt_miaoshu   = TFDirector:getChildByPath(node, "txt_miaoshu")
    local btn_zhankai   = TFDirector:getChildByPath(node, "btn_zhankai")

    local replayData = MiningManager.MineReplayResult[index]
    local time       = replayData.time
    local player     = replayData.infos
    -- required int32 challengePlayerCount = 4;
    -- required int32 challengeGuardCount = 5;
    -- required int32 id = 6;

    -- //玩家信息 0 挑战者 1 挖矿者 2护矿者
    local role1 = player[1]
    local role2 = player[2]
    local role3 = player[3]

    self:drawPlayNode(img_tou1, role1)
    self:drawPlayNode(img_tou2, role2)
    self:drawPlayNode(img_tou3, role3)

    -- 1 打劫成功 2 打劫失败 3 守矿成功 4 守矿失败
    local fightType = 1
    local result    = replayData.sucess
    if role1 then
        if role1.playerId == MainPlayer:getPlayerId() then
            print("玩家自己是打劫者")
            fightType = 1
            if result == false then
                fightType = 2
            end
        else
            print("玩家是守矿着")
            fightType = 3
            if result == true then
                fightType = 4
            end
        end
    end

    local strExtend = ""
    if role3 then
        -- strExtend = TFLanguageManager:getString(ErrorCodeData.Mining_UI3)
        -- strExtend = string.format(strExtend, role3.name, replayData.challengeGuardCount)
        strExtend = stringUtils.format(localizable.Mining_UI3, role3.name, replayData.challengeGuardCount)
    end

    -- local str = TFLanguageManager:getString(ErrorCodeData.Mining_UI3_win)
    -- if result == false then
    --     str = TFLanguageManager:getString(ErrorCodeData.Mining_UI3_lost)
    -- end
    
    local str = localizable.Mining_UI3_win
    if result == false then
        str = localizable.Mining_UI3_lost
    end

    -- %s前来打劫，与%s战斗%d次，%s打劫成功
    str = stringUtils.format(str, role1.name, role2.name, replayData.challengePlayerCount, strExtend)

    if fightType == 1 or fightType == 2 or fightType == 4 then
        -- coin
        local coinNum = replayData.coin or 0
        -- local coin = TFLanguageManager:getString(ErrorCodeData.Mining_Rob_Success)
        -- coin = string.format(coin, replayData.coin)
        -- str = str ..",".. coin

        local coin = nil
        local robResource = replayData.robResource
        local table,tableNum = stringToTable(robResource,'&')
        --local baoshidengji = {"一级","二级"}
        local baoshidengji =localizable.MiningFightReLayer_baoshidengji
        for i=1,tableNum do 
            local robtable = stringToTable(table[i],',')
            local data = {}
            data.type = tonumber(robtable[1])
            data.itemId = tonumber(robtable[2])
            data.number = tonumber(robtable[3])

            if data.type == EnumDropType.COIN then
                -- coin = TFLanguageManager:getString(ErrorCodeData.Mining_Rob_Success)
                -- coin = string.format(coin, robtable[3])
                coin = localizable.Mining_Rob_Success
                coin = stringUtils.format(coin, robtable[3])

            elseif data.type == EnumDropType.SYCEE then
                -- coin = TFLanguageManager:getString(ErrorCodeData.Mining_Rob_Acer)
                -- coin = string.format(coin, robtable[3])                
                coin = localizable.Mining_Rob_Acer
                coin = stringUtils.format(coin, robtable[3])

            elseif data.type == EnumDropType.GOODS then
                if robtable[2] == "30021" then
                    -- coin = TFLanguageManager:getString(ErrorCodeData.Mining_Rob_Refined_stone)
                    -- coin = string.format(coin, robtable[3])

                    coin = localizable.Mining_Rob_Refined_stone
                    coin = stringUtils.format(coin, robtable[3])

                elseif robtable[2] == "40039" then
                    -- coin = TFLanguageManager:getString(ErrorCodeData.Mining_Rob_Gemstone)
                    -- coin = string.format(coin, robtable[3],baoshidengji[1])
                    coin = localizable.Mining_Rob_Gemstone
                    coin = stringUtils.format(coin, robtable[3],baoshidengji[1])

                elseif robtable[2] == "40040" then
                    -- coin = TFLanguageManager:getString(ErrorCodeData.Mining_Rob_Gemstone)
                    -- coin = string.format(coin, robtable[3],baoshidengji[1])

                    coin = localizable.Mining_Rob_Gemstone
                    coin = stringUtils.format(coin, robtable[3],baoshidengji[1])
                    
                end
            end
            
            str = str ..",".. coin
        end
    end
    

    txt_miaoshu:setText(str)

    local res = {"img_jkcg.png", "img_jksb.png", "img_hkcg.png", "img_hksb.png"}
    img_hukuang:setTexture("ui_new/mining/"..res[fightType])

    btn_zhankai.logic = self
    btn_zhankai.index = index
    btn_zhankai:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onClickMoreFightReport))
    btn_zhankai.id = replayData.id


    time = math.ceil(time/1000)
    time = MainPlayer:getNowtime() - time
    txt_battletime:setText(MiningFightReportLayer:formatTimeToString(time))

    local timestamp = math.floor(replayData.time/1000)
    local date   = os.date("*t", timestamp)
    local timeDesc = date.year.."-"..date.month.."-"..date.day
    local timeDesc = string.format("%s", timeDesc)

    txt_date:setText(timeDesc)
    -- txt_battletime:setText
end

function MiningFightReportLayer:drawPlayNode(node, player)
    local txt_battletime = TFDirector:getChildByPath(node, "txt_battletime")

    local img_head          = TFDirector:getChildByPath(node, "img_head")
    local txt_name          = TFDirector:getChildByPath(node, "txt_name")
    local btn_huifang       = TFDirector:getChildByPath(node, "btn_huifang")
    local img_hu            = TFDirector:getChildByPath(node, "img_hu")
    local img_headBg        = TFDirector:getChildByPath(node, "img_di")

    btn_huifang:setVisible(false)
    img_head:setVisible(true)
    txt_name:setVisible(true)

    if img_hu then
        img_hu:setVisible(true)
    end

    if player == nil then
        img_head:setVisible(false)
        txt_name:setVisible(false)
        btn_huifang:setVisible(false)
        if img_hu then
            img_hu:setVisible(false)
        end

        return
    end
    -- required int32 playerId = 1;                //玩家编号
    -- required string name = 2;                   //玩家名称
    -- required int32 profession = 3;              //职业
    txt_name:setText(player.name)

    if player.icon == nil or player.icon <= 0 then                          --pck change head icon and head icon frame
        player.icon = player.profession
    end
    local roleId = player.icon
    local role = RoleData:objectByID(roleId);
    img_head:setTexture(role:getIconPath());
    Public:addFrameImg(img_head,player.headPicFrame)                       --end
    Public:addInfoListen(img_head,true,1,player.playerId)
    btn_huifang.logic = self
    btn_huifang.index = index
    btn_huifang:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onClickFightReport))
end

function MiningFightReportLayer.onClickMoreFightReport(sender)
    MiningManager:requestReplayDetail(sender.id)
end

function MiningFightReportLayer.onClickFightReport(sender)
    print("onclick fight report")
end

function MiningFightReportLayer:formatTimeToString(passTime)
    local str

    passTime = passTime / 60
    if passTime < 60 then
        if passTime < 1 then
            passTime = 1
        end

        --str = "" .. math.floor(passTime) .. "分钟前"
        str = stringUtils.format(localizable.common_min_befor,math.floor(passTime))
    else
        passTime = passTime / 60
        if passTime < 24 then
            --str = "" .. math.floor(passTime) .. "小时前"
            str =stringUtils.format(localizable.common_hour_befor, math.floor(passTime) )

        else
            passTime = passTime / 24

            if passTime < 7 then
                --str = "" .. math.floor(passTime) .. "天前"
                str = stringUtils.format(localizable.common_day_befor, math.floor(passTime) )

            else
                passTime = passTime / 7
                if passTime < 2 then
                    --str = "1周前"
                    str = stringUtils.format(localizable.common_week_befor,1)
                else
                    --str = "2周前"
                    str = stringUtils.format(localizable.common_week_befor,2)
                end
            end
        end
    end

    return str
end

function MiningFightReportLayer:resortReportList()
    if MiningManager.MineReplayResult == nil then
        return
    end

    local sortFunc = function(a, b) 
        if a.time > b.time then
            return true
        end

        return false
    end
    table.sort(MiningManager.MineReplayResult, sortFunc)
end

return MiningFightReportLayer
