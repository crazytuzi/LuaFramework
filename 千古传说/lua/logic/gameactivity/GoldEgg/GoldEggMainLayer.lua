
local GoldEggMainLayer = class("GoldEggMainLayer", BaseLayer)

-- local GoldEggMainLayer = class("GoldEggMainLayer", function(...)
--     local layer = TFPanel:create()
--     return layer
-- end)
function GoldEggMainLayer:ctor(data)
    self.super.ctor(self)
    self:init("lua.uiconfig_mango_new.zadan.ZaDanMain")
end

-- function GoldEggMainLayer:ctor(data)
--         local button = TFButton:create()
--         local pos = ccp(300, -480)
--         self:addChild(button)
--         button:setTextureNormal("ui_new/operatingactivities/new/btn_quzhaomu.png")
--         button:setAnchorPoint(ccp(0.5, 0.5))
--         button:setPosition(pos)
--         button:setZOrder(100)
--         button:addMEListener(TFWIDGET_CLICK,
--         function()
            
--         end)
-- end

function GoldEggMainLayer:initUI(ui)
	self.super.initUI(self,ui)

    self.img_dan1    = TFDirector:getChildByPath(self, 'img_dan1')
    self.img_dan2    = TFDirector:getChildByPath(self, 'img_dan2')

    self.btn_close     = TFDirector:getChildByPath(self, 'btn_close')
    self.btn_history   = TFDirector:getChildByPath(self, 'btn_lishi')

    self.txt_time = TFDirector:getChildByPath(self, 'txt_time')


    self.panel_huadong = TFDirector:getChildByPath(self, 'panel_huadong')
    self.panel_scroll = TFDirector:getChildByPath(self, 'panel_scroll')
    self.panel_item = TFDirector:getChildByPath(self, 'panel_item')
    self.Panel_Paihang = TFDirector:getChildByPath(self, 'Panel_Paihang')
    self.img_di = TFDirector:getChildByPath(self.Panel_Paihang, 'img_di')
    self.btn_jifen = TFDirector:getChildByPath(self.Panel_Paihang, 'btn_jifen')
    self.btn_shuaxin = TFDirector:getChildByPath(self.Panel_Paihang, 'btn_shuaxin')
    self.panel_rank = TFDirector:getChildByPath(self.Panel_Paihang, 'panel_rank')
    self.panel_gun = TFDirector:getChildByPath(self.Panel_Paihang, 'panel_gun')
    self.panel_rank_2 = TFDirector:getChildByPath(self.Panel_Paihang, 'panel_rank_2')

    self.panel_scroll:retain()
    self.panel_item:retain()
    self.panel_rank:retain()
    self.panel_rank:removeFromParent(true)
    self.panel_scroll:setVisible(false)
    self.panel_item:setVisible(false)
    self.panel_rank:setVisible(false)
    self.panel_rank_2:retain()
    self.panel_rank_2:removeFromParent(true)
    self.panel_rank_2:setVisible(false)

    self.img_dan1.eggType = 1
    self.img_dan2.eggType = 2
    
    self.historyLayer = {}

    self.img_di:setPositionX(0)
    self.rankLayer_show = false
    GoldEggManager:refreshRankList()
end

function GoldEggMainLayer:initShowOtherRewardHistoryLayer()
    if self.historyLayer == nil then
        self.historyLayer = {}
    else
        for i=1,#self.historyLayer do
            self.historyLayer[i]:removeFromParent(true)
        end
        self.historyLayer = {}
    end
    local length = GoldEggManager.showOtherHistory:length()
    local temp = 1
    for v in GoldEggManager.showOtherHistory:iterator() do
        print("initShowOtherRewardHistoryLayer   v = ",v)
        local layer = self.panel_scroll:clone()
        layer:setVisible(true)
        local txt_name = TFDirector:getChildByPath(layer, 'txt_name')
        --txt_name:setText(v.playerName.."获得了")
        txt_name:setText(stringUtils.format(localizable.goldEggMain_get, v.playerName))
        local width = txt_name:getContentSize().width
        if v.rewardList then
            for i=1,#v.rewardList do
                local reward = v.rewardList[i]
                local item_panel = self.panel_item:clone()
                item_panel:setVisible(true)
                local rewardItem = BaseDataManager:getReward({itemId = reward.resId, type = reward.resType,number = reward.number})
                Public:loadIconNode(item_panel,rewardItem)
                layer:addChild(item_panel)
                item_panel:setPosition(ccp(width,4))
                width = width + item_panel:getContentSize().width
            end
        end
        local size = layer:getContentSize()
        layer:setContentSize(CCSize(width,size.height))
        self.panel_huadong:addChild(layer)
        self.historyLayer[temp] = layer
        self.historyLayer[temp].width = width
        temp = temp + 1
    end
    if temp > 1 then
        self.historyLayer[1]:setPosition(ccp(810,-40))
    end
    for i=2,(temp-1) do
        local posX = self.historyLayer[i-1]:getPositionX()
        self.historyLayer[i]:setPosition(ccp(posX+self.historyLayer[i-1].width+100 ,-40))
    end
end


function GoldEggMainLayer:registerEvents()
    self.super.registerEvents(self)


    ADD_ALERT_CLOSE_LISTENER(self, self.btn_close)

    -- self.pvpBtn.logic = self
    -- self.pvpBtn.eggType = 1
    -- self.pvpBtn:addMEListener(TFWIDGET_CLICK, audioClickfun(self.OnclikSiliverEgg),1)

    -- self.pveBtn.logic = self
    -- self.pveBtn.eggType = 2
    -- self.pveBtn:addMEListener(TFWIDGET_CLICK, audioClickfun(self.OnclikGlodEgg),1)

    -- self.btn_chat:addMEListener(TFWIDGET_CLICK, audioClickfun(self.OnclikHitEgg),1)
    self.btn_history:addMEListener(TFWIDGET_CLICK, audioClickfun(self.OnclikHistory),1)
    self.btn_shuaxin:addMEListener(TFWIDGET_CLICK, audioClickfun(self.OnclikRefreshRankLayer),1)
    self.btn_jifen:addMEListener(TFWIDGET_CLICK, audioClickfun(self.OnclikOpenRankLayer),1)
    self.btn_jifen.logic = self
    self.receiveEggResult = function(event)
        self:refreshUI()
        -- 砸蛋奖励
        self.eggReward  = event.data[1].reward

        local eggType =  self.eggReward.type
        self:showGetEffect(eggType)
    end
    TFDirector:addMEGlobalListener(GoldEggManager.GET_HIT_EGG_EVENT, self.receiveEggResult)


    self.receiveGoldUpdate = function(event)
        self:refreshUI()
    end
    TFDirector:addMEGlobalListener(GoldEggManager.GOLD_EGG_UPDATE, self.receiveGoldUpdate)

    self.ShowHistroyNoticeCallBack = function(event)
        self:initShowOtherRewardHistoryLayer()
    end
    TFDirector:addMEGlobalListener(GoldEggManager.Show_Histroy_Notice, self.ShowHistroyNoticeCallBack)

    self.RefreshRankListCallBack = function(event)
        self:refreshRankList()
    end
    TFDirector:addMEGlobalListener(GoldEggManager.Fresh_Rank_Notice, self.RefreshRankListCallBack)


    self.showOtherHistoryTimer = TFDirector:addTimer(30,-1,nil,function ()
        self:showOtherHistory()
    end)
end

function GoldEggMainLayer:removeEvents()

    TFDirector:removeMEGlobalListener(GoldEggManager.GET_HIT_EGG_EVENT, self.receiveEggResult)
    self.receiveEggResult = nil

    TFDirector:removeMEGlobalListener(GoldEggManager.GOLD_EGG_UPDATE, self.receiveGoldUpdate)
    self.receiveGoldUpdate = nil
    TFDirector:removeMEGlobalListener(GoldEggManager.Show_Histroy_Notice, self.ShowHistroyNoticeCallBack)
    self.ShowHistroyNoticeCallBack = nil
    TFDirector:removeMEGlobalListener(GoldEggManager.Fresh_Rank_Notice, self.RefreshRankListCallBack)
    self.RefreshRankListCallBack = nil

    if self.showOtherHistoryTimer then
        TFDirector:removeTimer(self.showOtherHistoryTimer)
        self.showOtherHistoryTimer = nil
    end

    self.super.removeEvents(self)
end


function GoldEggMainLayer:removeUI()
    self.super.removeUI(self)
    if self.panel_scroll then
        self.panel_scroll:release()
        self.panel_scroll = nil
    end
    if self.panel_item then
        self.panel_item:release()
        self.panel_item = nil
    end
    if self.panel_rank then
        self.panel_rank:release()
        self.panel_rank = nil
    end
    if self.panel_rank_2 then
        self.panel_rank_2:release()
        self.panel_rank_2 = nil
    end
end

function GoldEggMainLayer:onShow()
    self.super.onShow(self)

    if self.rankLayer_show then
        self.img_di:setPositionX(-228)
    else
        self.img_di:setPositionX(0)
    end
    self:refreshUI()
end

function GoldEggMainLayer:dispose()
    self.super.dispose(self)
end

function GoldEggMainLayer:refreshUI()
    local activity = OperationActivitiesManager:ActivityWithType(OperationActivitiesManager.Type_Hit_Egg)

    if activity then
        local descTime = OperationActivitiesManager:getDateString(activity.startTime, activity.endTime, activity.status)

        --self.txt_time:setText("活动时间："..descTime)
        self.txt_time:setText(stringUtils.format(localizable.common_activity_time1,descTime))
    end
    print("activity.multiSever==",activity)
    self.isCrossServer = false
    local activity_score = OperationActivitiesManager:ActivityWithType(OperationActivitiesManager.Type_Score_Egg)
    if activity_score then
        self.isCrossServer = activity_score.multiSever
    end
    self:drawEgg(self.img_dan1)
    self:drawEgg(self.img_dan2)
end

function GoldEggMainLayer.OnclikSiliverEgg(sender)
    local self      = sender.logic
    local eggType   = sender.eggType

    -- body
    local eggInfo = GoldEggManager:getEggInfo(eggType)

    print("===========egg info =============")
    self:printEggInfo(eggInfo)
    print("===========end =============")
end

function GoldEggMainLayer.OnclikGlodEgg(sender)
    local self = sender.logic
    -- body
    local eggType   = sender.eggType

    -- body
    local eggInfo = GoldEggManager:getEggInfo(eggType)

    print("===========egg info =============")
    self:printEggInfo(eggInfo)
    print("===========end =============")
end

function GoldEggMainLayer.OnclikHitEgg(sender)
    GoldEggManager:RequestBreakGoldEgg(1, 1)
end

    -- required int32 type = 1;            //1银蛋2金蛋
    -- required int32 resType = 2;         //消耗资源类型
    -- required int32 resId = 3;           //消耗资源ID
    -- required int32 number = 4;          //消耗资源个数
    -- required int32 score = 5;           //积分
    -- required int32 freeTime = 6;        //免费次数
    -- required string reward = 7;         //随机奖励配置 类型,id,数量&类型,id,数量

function GoldEggMainLayer:printEggInfo(eggInfo)
    -- body
    --local eggDesc = {"银蛋", "金蛋"}
    local eggDesc = localizable.goldEggMain_egg_type
    local eggType = eggInfo.type

    print("================", eggDesc[eggType])

    local commonReward = {}
    commonReward.type   = tonumber(eggInfo.resType)
    commonReward.itemId = tonumber(eggInfo.resId)
    commonReward.number = tonumber(eggInfo.number)
    local rewarddata = BaseDataManager:getReward(commonReward)
    print("commonReward = ", commonReward)
    local myToolNum = MainPlayer:getGoodsNum(rewarddata)

    print("eggInfo.resId = ", eggInfo.resId)
    print("==== 砸蛋道具 名字         = ",     rewarddata.name)
    print("==== 砸蛋每次消耗道具个数  = ",     rewarddata.number)
    print("==== 砸蛋道具剩余个数      = ",     myToolNum)
    print("==== 砸蛋获取的积分        = ",     eggInfo.score)
    print("==== 砸蛋免费次数          = ",     eggInfo.freeTime)
end

function GoldEggMainLayer:showGetEffect(cardType)
    local blockUI = TFPanel:create();
    blockUI:setSize(GameConfig.WS);
    blockUI:setTouchEnabled(true); 

    blockUI:setBackGroundColorType(TF_LAYOUT_COLOR_SOLID);
    blockUI:setBackGroundColorOpacity(200);
    blockUI:setBackGroundColor(ccc3(  0,   0,   0));
    AlertManager:getTopLayer().toScene:addLayer(blockUI);

    TFResourceHelper:instance():addArmatureFromJsonFile("effect/hit_egg_effect.xml")
    local effect = TFArmature:create("hit_egg_effect_anim")
    if effect == nil then
        return
    end
    local index = 0
    if cardType == 1 then
        index = 1
    end
    -- effect:setZOrder(-100)
    effect:setAnimationFps(GameConfig.ANIM_FPS)
    effect:playByIndex(index, -1, -1, 0)
    effect:setPosition(ccp(GameConfig.WS.width/2, GameConfig.WS.height/2))

    blockUI:addChild(effect)
    play_zhaomu_pengwan()

    
    local function showResult()
        blockUI:removeFromParent()

        -- GoldEggManager:showResult()
    end

    local temp = 0
    effect:addMEListener(TFARMATURE_UPDATE,function()
        temp = temp + 1
        if temp == 61 then
            GoldEggManager:showResult()
        end
    end)

    effect:addMEListener(TFARMATURE_COMPLETE,showResult)
    -- blockUI:addMEListener(TFWIDGET_CLICK,showResult)
end

function GoldEggMainLayer:drawEgg(eggNode)
    --local hammerDesc = {"银锤子", "金锤子"}
    local hammerDesc = localizable.goldEggItem_hammer_type
    local eggType = eggNode.eggType
    local eggInfo = GoldEggManager:getEggInfo(eggType)

    self:printEggInfo(eggInfo)

    local btn_chakan    = TFDirector:getChildByPath(eggNode, 'btn_chakan')
    local btn_zadan     = TFDirector:getChildByPath(eggNode, 'btn_zadan')
    local txt_cost      = TFDirector:getChildByPath(eggNode, 'txt_num')
    local txt_own       = TFDirector:getChildByPath(eggNode, 'txt_yongyou')
    local txt_mianfei   = TFDirector:getChildByPath(eggNode, 'txt_mianfei')
    local txt_danhuanum = TFDirector:getChildByPath(eggNode, 'txt_danhuanum')
    local txt_danhua    = TFDirector:getChildByPath(eggNode, 'txt_danhua')


    local commonReward = {}
    commonReward.type   = tonumber(eggInfo.resType)
    commonReward.itemId = tonumber(eggInfo.resId)
    commonReward.number = tonumber(eggInfo.number)
    local rewarddata = BaseDataManager:getReward(commonReward)

    local myToolNum = MainPlayer:getGoodsNum(rewarddata)

    --local myOwn = "(当前拥有"..myToolNum..")"
    local myOwn =stringUtils.format(localizable.goldEggMain_number, myToolNum)
    txt_cost:setText(eggInfo.number)
    txt_own:setText(myOwn)

    btn_chakan:addMEListener(TFWIDGET_CLICK, audioClickfun(
        function ()
            GoldEggManager:CheckEggReward(eggType)
        end
    ),1)

    btn_zadan:addMEListener(TFWIDGET_CLICK, audioClickfun(
        function ()
            if eggInfo.freeTime == 0 and myToolNum < commonReward.number then
                --toastMessage("没有足够的"..hammerDesc[eggType])
                toastMessage(stringUtils.format(localizable.goldEggItem_no_hammer,hammerDesc[eggType]))
                return
            end
            print("eggType = ", eggType)
            GoldEggManager:RequestBreakGoldEgg(eggType, 1)
        end
    ),1)


    txt_mianfei:setVisible(false)
    if eggInfo.freeTime > 0 then
        txt_mianfei:setVisible(true)
    end

    -- /
    txt_danhuanum:setText(eggInfo.score)
    if CC_TARGET_PLATFORM == CC_PLATFORM_IOS then
        txt_danhuanum:setFontSize(16)
        local posY = txt_danhuanum:getPositionY()
        txt_danhuanum:setPositionY(posY-5)
    end
    --txt_danhua:setText("获得积分")
    txt_danhua:setText(localizable.common_get_score)
end


function GoldEggMainLayer.OnclikHistory(sender)
    GoldEggManager:ShowRecordLayer()
end


function GoldEggMainLayer.OnclikRefreshRankLayer(sender)
    GoldEggManager:refreshRankList()
end
function GoldEggMainLayer.OnclikOpenRankLayer(sender)
    local self = sender.logic
    if self.rank_tween ~= nil then
        TFDirector:killTween(self.rank_tween)
    end
    if self.rankLayer_show then
        self.rank_tween = {
            target = self.img_di,
            {
                duration = 0.3,
                ease = {type=TFEaseType.EASE_IN_OUT, rate=3},
                x = 0,
            },
        }
        self.rankLayer_show = false
    else
        self.rank_tween = {
            target = self.img_di,
            {
                duration = 0.3,
                ease = {type=TFEaseType.EASE_IN_OUT, rate=3},
                x = -228,
            },
        }
        self.rankLayer_show = true
    end
    TFDirector:toTween(self.rank_tween)
end


--[[
 local posX = self.historyLayer[i-1]:getPositionX()
        self.historyLayer[i]:setPosition(ccp(posX+self.historyLayer[i-1].width+30 ,0))
]]
function GoldEggMainLayer:showOtherHistory()
    for i=1,#self.historyLayer do
        local layer = self.historyLayer[i]
        local posX = layer:getPositionX()
        layer:setPositionX(posX - 2)
    end

    for i=1,#self.historyLayer do
        local layer = self.historyLayer[i]
        local posX = layer:getPositionX()
        if posX + layer.width <= 0 then
            local temp_num = (i-1) > 0 and (i-1) or #self.historyLayer
            local temp_layer = self.historyLayer[temp_num]
            posX = temp_layer:getPositionX() + temp_layer.width + 100
            posX = math.max(posX,810)
            layer:setPositionX(posX)
        end
    end
end

function GoldEggMainLayer:refreshRankList()
    if self.tableView == nil then
        local  tableView =  TFTableView:create()
        tableView:setTableViewSize(self.panel_gun:getContentSize())
        tableView:setDirection(TFTableView.TFSCROLLVERTICAL)
        tableView:setVerticalFillOrder(TFTableView.TFTabViewFILLTOPDOWN)


        tableView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, GoldEggMainLayer.cellSizeForTable)
        tableView:addMEListener(TFTABLEVIEW_SIZEATINDEX, GoldEggMainLayer.tableCellAtIndex)
        tableView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, GoldEggMainLayer.numberOfCellsInTableView)
        self.tableView = tableView
        self.tableView.logic = self
        self.panel_gun:addChild(tableView)
    end
    self.tableView:reloadData()

    local txt_paiming = TFDirector:getChildByPath(self.img_di, 'txt_paiming')
    local rank_txt = TFDirector:getChildByPath(txt_paiming, 'txt_num')
    local txt_jifen = TFDirector:getChildByPath(self.img_di, 'txt_jifen')
    local txt_score = TFDirector:getChildByPath(txt_jifen, 'txt_num')
    if GoldEggManager.myRank.rank > 0 and GoldEggManager.myRank.rank <= 50 then
        rank_txt:setText(GoldEggManager.myRank.rank)
    else
        --rank_txt:setText("未入榜")
        rank_txt:setText(localizable.shalu_info_txt1)
    end
    txt_score:setText(GoldEggManager.myRank.score)
end


function GoldEggMainLayer.cellSizeForTable(table,idx)
    local self = table.logic
    if self.isCrossServer then
        return 80,190
    else
        return 60,190
    end
    return 60,190
end


function GoldEggMainLayer.tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    local self = table.logic
    if nil == cell then
        cell = TFTableViewCell:create()
        local panel_rank = nil
        if self.isCrossServer then
            panel_rank = self.panel_rank_2:clone()
        else
            panel_rank = self.panel_rank:clone()
        end
        panel_rank:setVisible(true)
        panel_rank:setPosition(ccp(0,0))
        cell:addChild(panel_rank)
        cell.panel_rank = panel_rank
    end
    local rankInfo = GoldEggManager.rankList:getObjectAt(idx+1)
    print("------------------------->11111111")
    if rankInfo then
        print("------------------------->2222222222")
        self:loadRankInfo( rankInfo , cell.panel_rank )
    else
        print("------------------------->3333333")
        cell.panel_rank:setVisible(false)
    end
    return cell
end

function GoldEggMainLayer:loadRankInfo( rankInfo , panel )
    -- if rankInfo == nil then
    --     panel:setVisible(false)
    --     return
    -- end
    panel:setVisible(true)

    local txt_name = TFDirector:getChildByPath(panel, 'txt_name')
    local txt_num = TFDirector:getChildByPath(panel, 'txt_num')
    local txt_xuhao = TFDirector:getChildByPath(panel, 'txt_xuhao')
    txt_name:setText(rankInfo.name)
    txt_num:setText(rankInfo.score)
    txt_xuhao:setText(rankInfo.rank)
    print("self.isCrossServer = ",self.isCrossServer)
    if self.isCrossServer then
        local txt_server = TFDirector:getChildByPath(panel, 'txt_server')
        if txt_server then
            txt_server:setText("（"..rankInfo.serverName.."）")
        end
    end
end

function GoldEggMainLayer.numberOfCellsInTableView(table)
    return GoldEggManager.rankList:length()
end

return GoldEggMainLayer