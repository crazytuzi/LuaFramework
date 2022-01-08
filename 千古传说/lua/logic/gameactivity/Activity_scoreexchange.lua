local Activity_scoreexchange = class("Activity_scoreexchange", BaseLayer)

local Score_ShowOneServerPoint = {-2,-30}
local Score_ShowMultiServerPoint = {-15,-43}


function Activity_scoreexchange:ctor(type)
    self.super.ctor(self)
    self.id   = type
    self.type =OperationActivitiesManager.Type_Exchange
    self:init("lua.uiconfig_mango_new.operatingactivities.10choujifen")
end

function Activity_scoreexchange:initUI(ui)
    self.super.initUI(self,ui)
    self.img_award 				= TFDirector:getChildByPath(ui, 'img_award')

    self.panel_list 			= TFDirector:getChildByPath(ui, 'panel_list')
    self.txt_time               = TFDirector:getChildByPath(ui, 'txt_time')
    self.txt_content            = TFDirector:getChildByPath(ui, 'txt_content')
    self.txt_jifen              = TFDirector:getChildByPath(ui, 'txt_jifen')
    self.txt_paiming            = TFDirector:getChildByPath(ui, 'txt_paiming')
    self.txt_weirubang          = TFDirector:getChildByPath(ui, 'txt_weirubang')
 
    local activity     = OperationActivitiesManager:getActivityInfo(self.id)
    self.activity      = activity
    self.rewardList    = activity.activityReward
    print("self.rewardList = ",self.rewardList)
end



function Activity_scoreexchange:removeUI()
    self.super.removeUI(self)
end

function Activity_scoreexchange:onShow()
    self.super.onShow(self)

    self:refreshUI()
end

function Activity_scoreexchange:dispose()
    self.super.dispose(self)
end

function Activity_scoreexchange:refreshUI()   
    self:drawRewardList()

    local activity = OperationActivitiesManager:getActivityInfo(self.id)



    -- self.txt_jifen              = TFDirector:getChildByPath(ui, 'txt_jifen')
    -- self.txt_paiming            = TFDirector:getChildByPath(ui, 'txt_paiming')
    self.txt_jifen:setText(activity.value)
    self.txt_paiming:setText(activity.rank)

    self.txt_paiming:setVisible(true)
    self.txt_weirubang:setVisible(false)
    if activity.rank == 0 then
        self.txt_paiming:setVisible(false)
        self.txt_weirubang:setVisible(true)
    end

    print("activity.details = ", activity.details)
    if not activity then
        self.txt_time:setText("")
        self.txt_content:setText("")

    else
        -- os.date("%x", os.time()) <== 返回自定义格式化时间字符串（完整的格式化参数），这里是"11/28/08"
        local startTime = ""
        local endTime   = ""

    -- 0、活动强制无效，不显示该活动；1、长期显示该活动 2、自动检测，过期则不显示',
        local status = activity.status or 1

        if status == 1 then
            --self.txt_time:setText("永久有效")
            self.txt_time:setText(localizable.common_time_longlong)
        else
            if activity.startTime then
                startTime = self:getDateString(activity.startTime)
            end
            if activity.endTime then
                endTime   = self:getDateString(activity.endTime)
            end

            self.txt_time:setText(startTime .. " - " .. endTime)
        end

        self.txt_content:setText(activity.details)
    end
end


function Activity_scoreexchange:setLogic(logic)
    self.logic = logic
end

function Activity_scoreexchange:registerEvents()
    print("Activity_scoreexchange:registerEvents()------------------")
    self.super.registerEvents(self)

    self.updateRewardCallback = function(event)
        self:refreshUI()
    end

    TFDirector:addMEGlobalListener(OperationActivitiesManager.MSG_ACTIVITY_PROGRESS_UPDATE,self.updateRewardCallback)
    -- TFDirector:addMEGlobalListener(OperationActivitiesManager.GET_ACITIVTY_REWARD_SUCCESS,self.updateRewardCallback)
end

function Activity_scoreexchange:removeEvents()
    print("Activity_scoreexchange:removeEvents()------------------")
    self.super.removeEvents(self)
    TFDirector:removeMEGlobalListener(OperationActivitiesManager.MSG_ACTIVITY_PROGRESS_UPDATE,self.updateRewardCallback)
end

function Activity_scoreexchange:getDateString(timestamp)

    if not timestamp then
        return
    end

    local date   = os.date("*t", timestamp)

    --return date.month.."月"..date.day.."日"..date.hour.."时"..date.min.."分"
    return stringUtils.format(localizable.common_time_4, date.month,date.day,date.hour,date.min)
    
end

function Activity_scoreexchange:drawRewardList()
    if self.fateTableView ~= nil then
        self.fateTableView:reloadData()
        -- self.fateTableView:setScrollToBegin(false)
        self.fateTableView:setVisible(true)
        return
    end

    local  fateTableView =  TFTableView:create()
    fateTableView:setTableViewSize(self.panel_list:getContentSize())
    fateTableView:setDirection(TFTableView.TFSCROLLVERTICAL)
    fateTableView:setVerticalFillOrder(TFTableView.TFTabViewFILLTOPDOWN)
    fateTableView:setPosition(self.panel_list:getPosition())
    self.fateTableView = fateTableView
    self.fateTableView.logic = self

    fateTableView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, self.cellSizeForTable_fate)
    fateTableView:addMEListener(TFTABLEVIEW_SIZEATINDEX, self.tableCellAtIndex_fate)
    fateTableView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, self.numberOfCellsInTableView_fate)
    fateTableView:reloadData()

    self.panel_list:getParent():addChild(self.fateTableView,1)
end

function Activity_scoreexchange.numberOfCellsInTableView_fate(table)
    local self = table.logic

    return self.rewardList:length()
end

function Activity_scoreexchange.cellSizeForTable_fate(table,idx)
    return 131, 553
end

function Activity_scoreexchange.tableCellAtIndex_fate(table, idx)
    local self = table.logic
    local cell = table:dequeueCell()
    local node = nil
    if nil == cell then
        table.cells = table.cells or {}
        cell = TFTableViewCell:create()
        table.cells[cell] = true

        node = createUIByLuaNew("lua.uiconfig_mango_new.operatingactivities.10choujifenCell")

        node:setPosition(ccp(10, -10))
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

function Activity_scoreexchange:drawCell(node)
    local itemList = {}
    for i=1,3 do
        itemList[i] = {}
        itemList[i].bg             = TFDirector:getChildByPath(node, 'img_bg_' .. i)
        itemList[i].icon           = TFDirector:getChildByPath(node, 'img_icon_' .. i)
        itemList[i].number         = TFDirector:getChildByPath(node, 'txt_number_' .. i)
    end
    local txt_title     =  TFDirector:getChildByPath(node, 'txt_title')
    local txt_desc      =  TFDirector:getChildByPath(node, 'txt_dq')
    local txt_score     =  TFDirector:getChildByPath(node, 'txt_score')
    local txt_username  =  TFDirector:getChildByPath(node, 'txt_username')
    local txt_server  =  TFDirector:getChildByPath(node, 'txt_server')
    local btn_extraReward  =  TFDirector:getChildByPath(node, 'btn_extraReward')

    --txt_desc:setText("当前排名段最低积分")
    txt_desc:setText(localizable.activity_min_score)


    local index = node.index

    --local rankDesc = "活动积分第%d-%d名奖励"
    local rankDesc = localizable.activity_rank_reward1 --"活动积分第%d-%d名奖励"


    -- local rewardInfo   = self.rewardList:objectAt(index)
    local rewardInfo   = self.rewardList:objectByID(index)


    local minlevel = rewardInfo.minlevel
    local maxlevel = rewardInfo.maxlevel

    if minlevel ~= maxlevel then
        rankDesc = stringUtils.format(rankDesc, minlevel, maxlevel)
    else
        rankDesc = localizable.activity_rank_reward2 --"活动积分第%d名奖励"
        rankDesc = stringUtils.format(rankDesc, minlevel)
    end

    txt_title:setText(rankDesc)
    txt_score:setText(rewardInfo.status)

    print(" rewardInfo.minlevel = ",  rewardInfo.minlevel)
    print(" rewardInfo.maxlevel = ",  rewardInfo.maxlevel)
    print(" rewardInfo.userName = ",  rewardInfo.userName)
    local prizeUserName = stringUtils.format(localizable.activity_user_reward, rewardInfo.minlevel, rewardInfo.userName)
    txt_username:setText(prizeUserName)


    if self.activity.multiSever and rewardInfo.serverName and rewardInfo.serverName ~= ""  then
        txt_server:setVisible(true)
        local serverName = string.format("（%s）",  rewardInfo.serverName)
        txt_server:setText(serverName)
        txt_desc:setPositionY(Score_ShowMultiServerPoint[1])
        txt_score:setPositionY(Score_ShowMultiServerPoint[2])
    else
        txt_server:setVisible(false)
        txt_desc:setPositionY(Score_ShowOneServerPoint[1])
        txt_score:setPositionY(Score_ShowOneServerPoint[2])
    end
    print("rewardInfo.extraStatus = ",rewardInfo.extraStatus)
    if rewardInfo.extraStatus ~= 0 then
        btn_extraReward:setVisible(true)
        btn_extraReward:addMEListener(TFWIDGET_CLICK,audioClickfun(function ()
                local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.gameactivity.ExtraReward",AlertManager.BLOCK_AND_GRAY_CLOSE,AlertManager.TWEEN_1);        
                layer:loadData(rewardInfo.extraReward, rewardInfo.extraStatus);
                AlertManager:show();       
            end))
    else
        btn_extraReward:setVisible(false)
    end

    local rewardItems = rewardInfo.reward
    local itemCount = rewardItems:length()
    for i=1,3 do
        if i <= itemCount then
            itemList[i].bg:setVisible(true)
            local item = rewardItems:objectAt(i)
            local info = BaseDataManager:getReward(item)
            if item.res_type == EnumDropType.GOODS then
                local goodsData = ItemData:objectByID(item.res_id)
                itemList[i].bg:setTexture(GetBackgroundForGoods(goodsData))
            else
                itemList[i].bg:setTexture(GetColorIconByQuality(info.quality))
            end
            
            itemList[i].icon:setTexture(info.path)
    
            if item.number > 1 then
                itemList[i].number:setVisible(true)
                itemList[i].number:setText("X" .. item.number)
            else
                itemList[i].number:setVisible(false)
            end


            if item.type == EnumDropType.GOODS then
                local rewardItem = {itemid = item.itemid}

                local itemData   = ItemData:objectByID(item.itemid)

                if itemData.type == EnumGameItemType.Piece or itemData.type == EnumGameItemType.Soul then
                    Public:addPieceImg(itemList[i].icon,rewardItem,true)
                else
                    Public:addPieceImg(itemList[i].icon,rewardItem,false)
                end
                -- adad  = dadaadad + 1
            end

            itemList[i].bg:addMEListener(TFWIDGET_CLICK, audioClickfun(function ()
                Public:ShowItemTipLayer(item.itemid, item.type);
                -- body
            end))
        else
            itemList[i].bg:setVisible(false)
        end
    end
end

return Activity_scoreexchange