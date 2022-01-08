--[[
******老玩家回归界面*******
    -- by yao
    -- 2016/2/16
]]

local PlayerBackMainLayer = class("PlayerBackMainLayer", BaseLayer)

function PlayerBackMainLayer:ctor(data)
    self.super.ctor(self,data)
    self.btn_huiguilibao= nil       --回归礼包按钮
    self.btn_huiguirenwu= nil       --回归任务按钮
    self.btn_close      = nil       --关闭按钮
    self.btn_zhaohui    = nil       --召回奖励按钮
    self.btn_lingqu     = nil       --领取礼包按钮
    self.panel_libao    = nil       --礼包的图层
    self.txt_time       = nil       --倒计时
    self.timeId         = nil
    self.tabViewRenwuUI = nil       --任务tableUI
    self.tabViewRenwu   = nil       --任务tableview
    self.cellModel      = nil     
    self.showtaskList   = nil       --需要显示的任务列表
    self.panelArr       = {}        --保存任务显示条
    self:init("lua.uiconfig_mango_new.playerback.PlayerBackMain")
end

function PlayerBackMainLayer:initUI(ui)
	self.super.initUI(self,ui)
    self.btn_close      = TFDirector:getChildByPath(ui, "btn_close")
    self.btn_huiguilibao= TFDirector:getChildByPath(ui, "btn_huigui1")
    self.btn_huiguirenwu= TFDirector:getChildByPath(ui, "btn_huigui2")
    self.btn_zhaohui    = TFDirector:getChildByPath(ui, "btn_zhaohui")
    self.btn_lingqu     = TFDirector:getChildByPath(ui, "btn_lingqu")
    self.panel_libao    = TFDirector:getChildByPath(ui, "panel_libao")
    self.txt_time       = TFDirector:getChildByPath(ui, "txt_time")
    self.img_kuang      = TFDirector:getChildByPath(ui, "img_kuang")
    self.panel_textarea = TFDirector:getChildByPath(ui, "panel_textarea")
    self.tabViewRenwuUI = TFDirector:getChildByPath(ui, "panel_renwu")

    self.btn_huiguilibao.logic = self
    self.btn_huiguirenwu.logic = self
    self.btn_huiguilibao:setTextureNormal("ui_new/back/tab_libaoh.png")
    self.btn_huiguirenwu:setTextureNormal("ui_new/back/tab_renwu.png")

    self.showtaskList = PlayBackManager:getShowTaskList()

    local size = self.panel_textarea:getContentSize()
    self.richtext  = TFRichText:create(size)
    self.richtext:setFontSize(18)
    self.richtext:setPosition(ccp(260, size.height))
    self.richtext:setAnchorPoint(ccp(0.5,1))
    self.panel_textarea:addChild(self.richtext)


    -- local notifyStr = "欢迎大侠重出江湖！\n为了让大侠尽快适应,我们特别为您准备了海量福利和丰厚的回归大礼包,助您急速追赶，后来居上!\n在这里您可以开启您的专属回归任务，完成后即可获得丰厚任务奖励。\n在此期间，大侠进行#green#闯关所获得的团队经验提高到1.5；闯关所获得的蛇胆数量提高到1.5倍，#end#让您在等级上后顾无忧。\n最后，我们为您诚意送上的这份回归大礼包，点击下方按钮即可领取，随着您的成长。礼包内容也将愈加丰厚，愿您的江湖之路一帆风顺，早日重回武林巅峰！"
    -- local description = notifyStr
    -- description = description:gsub("#green#",            [[</font><font face = "simhei" color="#008030" fontSize = "18">]] );
    -- description = description:gsub("#end#",            [[</font><font face = "simhei" color="#3d3d3d" fontSize = "18">]]);
    -- description = description:gsub("\n",               [[<br/>]]);
    -- local des = [[<p style="text-align:left; margin:2px">]];
    -- des = des .. [[<font face = "simhei" color="#3d3d3d" fontSize = "17">]]
    -- des = des .. description
    -- des = des .. [[</font>]]
    -- des = des .. [[</p>]]
    -- self.richtext:setText(des)

    --local desc1 = "欢迎大侠重出江湖！<br/>为了让大侠尽快适应，我们特别为您准备了海量福利和丰厚的回归大礼包，助您急速追赶，后来居上!<br/>在这里您可以开启您的专属回归任务，完成后即可获得丰厚任务奖励。<br/>在此期间，大侠进行"
    --local servername = "闯关所获得的团队经验提高到1.5；闯关所获得的蛇胆数量提高到1.5倍，"
    --local desc2 = "让您在等级上后顾无忧。<br/>最后，我们为您诚意送上的这份回归大礼包，点击下方按钮即可领取，随着您的成长。礼包内容也将愈加丰厚，愿您的江湖之路一帆风顺，早日重回武林巅峰！"
    local desc1 = localizable.playerbackMain_text1  
    local servername = localizable.playerbackMain_text2
    local desc2 = localizable.playerbackMain_text3
    local strFormat =[[<p style="text-align:left; margin:3px"><font face = "simhei" color="#3d3d3d" fontSize="18">%s</font><font face = "simhei" color="#008030" fontSize="18">%s</font><font face = "simhei" color="#3d3d3d" fontSize="18">%s</font></p>]]
    local notifyStr = ""
    notifyStr = string.format(strFormat, desc1, servername, desc2)
    self.richtext:setText(notifyStr)

    self:showRemainingTime()
    self:drowTableView()
    self:showLibaoBtnState()
    self:cutDowntimer()
end

function PlayerBackMainLayer:loadData(page)
    
end

function PlayerBackMainLayer:removeUI()
    TFDirector:removeTimer(self.timeId)
    for k,v in pairs(self.panelArr) do
        v:removeUI()
    end
    self.super.removeUI(self)
end

-----断线重连支持方法
function PlayerBackMainLayer:onShow()
    self.super.onShow(self)
end

function PlayerBackMainLayer:registerEvents()
    self.super.registerEvents(self)
    self.btn_close:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onCloseBtnCallBack))
    self.btn_huiguilibao:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onHuiguiLibaoBtnCallBack))
    self.btn_huiguirenwu:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onHuiguiRenwuBtnCallBack))
    self.btn_zhaohui:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onZhaohuijiangliBtnCallBack))
    self.btn_lingqu:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onLingquLibaoBtnCallBack))

   

    self.updateTask = function(event)
        self.showtaskList = PlayBackManager:getShowTaskList()
        self:drowTableView()
    end
    TFDirector:addMEGlobalListener(PlayBackManager.UPDATETASK ,self.updateTask)

    --邀请码领取礼包成功
    self.lingquSuccess = function(event)
        self.btn_zhaohui:setTouchEnabled(false)
        self.btn_zhaohui:setTextureNormal("ui_new/back/btn_lqlbh.png")
    end
    TFDirector:addMEGlobalListener(PlayBackManager.LIBAOLINGQUSUCCESS ,self.lingquSuccess)

    --专属礼包领取成功
    self.lingquSuccess2 = function(event)
        self.btn_lingqu:setTouchEnabled(false)
        self.btn_lingqu:setTextureNormal("ui_new/back/btn_lqlbh.png")
    end
    TFDirector:addMEGlobalListener(PlayBackManager.ZHUANGSHULIBAOLINGQUSUCCESS ,self.lingquSuccess2)
end

function PlayerBackMainLayer:removeEvents()
    self.btn_close:removeMEListener(TFWIDGET_CLICK)
    self.btn_huiguilibao:removeMEListener(TFWIDGET_CLICK)
    self.btn_huiguirenwu:removeMEListener(TFWIDGET_CLICK)
    self.btn_zhaohui:removeMEListener(TFWIDGET_CLICK)
    self.btn_lingqu:removeMEListener(TFWIDGET_CLICK)

    self.tabViewRenwu:removeMEListener(TFTABLEVIEW_SIZEFORINDEX)
    self.tabViewRenwu:removeMEListener(TFTABLEVIEW_SIZEATINDEX)
    self.tabViewRenwu:removeMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW)

    TFDirector:removeMEGlobalListener(PlayBackManager.UPDATETASK ,self.updateTask)
    self.updateTask = nil
    TFDirector:removeMEGlobalListener(PlayBackManager.LIBAOLINGQUSUCCESS ,self.lingquSuccess)
    self.lingquSuccess = nil
    TFDirector:removeMEGlobalListener(PlayBackManager.ZHUANGSHULIBAOLINGQUSUCCESS ,self.lingquSuccess2)
    self.lingquSuccess2 = nil

    self.super.removeEvents(self)
end

function PlayerBackMainLayer:dispose()
    self.super.dispose(self)
end

function PlayerBackMainLayer:drowTableView()
    if self.tabViewRenwu ~= nil then
        self.tabViewRenwu:reloadData()
        self.tabViewRenwu:setScrollToBegin(false)
        self.tabViewRenwu:setVisible(true)
        return
    end
    --创建TabView
    self.tabViewRenwu =  TFTableView:create()
    self.tabViewRenwu:setTableViewSize(self.tabViewRenwuUI:getContentSize())
    self.tabViewRenwu:setDirection(TFTableView.TFSCROLLVERTICAL)    
    self.tabViewRenwu:setVerticalFillOrder(TFTableView.TFTabViewFILLTOPDOWN)
    self.tabViewRenwu.logic = self
    self.tabViewRenwuUI:addChild(self.tabViewRenwu)
    self.tabViewRenwu:setPosition(ccp(0,0))
    self.tabViewRenwu:setVisible(false)
     --注册TabView事件
    self.tabViewRenwu:addMEListener(TFTABLEVIEW_SIZEFORINDEX, self.cellSizeForTable)
    self.tabViewRenwu:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, self.numberOfCellsInTableView)
    self.tabViewRenwu:addMEListener(TFTABLEVIEW_SIZEATINDEX, self.tableCellAtIndex)
    self.tabViewRenwu:reloadData()
end

--显示礼包按钮状态
function PlayerBackMainLayer:showLibaoBtnState()
    local info = PlayBackManager:getRecallReturnInfo()
    if info.fromPlayerId ~= 0 then
        self.btn_zhaohui:setTouchEnabled(false)
        self.btn_zhaohui:setTextureNormal("ui_new/back/btn_lqlbh.png")
    end
    local rewardGot = info.rewardGot
    --print("rewardGot =",rewardGot)
    local rewardtype = bit_and(rewardGot,1)
    if rewardtype == 1 then
        self.btn_lingqu:setTouchEnabled(false)
        self.btn_lingqu:setTextureNormal("ui_new/back/btn_lqlbh.png")
    end
end

--关闭按钮回调
function PlayerBackMainLayer.onCloseBtnCallBack(sender)
    AlertManager:close()
end

--回归礼包按钮回调
function PlayerBackMainLayer.onHuiguiLibaoBtnCallBack(sender)
    local self = sender.logic
    self.btn_huiguilibao:setTextureNormal("ui_new/back/tab_libaoh.png")
    self.btn_huiguirenwu:setTextureNormal("ui_new/back/tab_renwu.png")
    self.panel_libao:setVisible(true)
    self.tabViewRenwu:setVisible(false)
end

--回归任务按钮回调
function PlayerBackMainLayer.onHuiguiRenwuBtnCallBack(sender)
    local self = sender.logic
    self.btn_huiguilibao:setTextureNormal("ui_new/back/tab_libao.png")
    self.btn_huiguirenwu:setTextureNormal("ui_new/back/tab_renwuh.png")
    self.panel_libao:setVisible(false)
    self.tabViewRenwu:setVisible(true)
    local num = #self.showtaskList
    if num == 0 then
        --toastMessage("没有可领取任务")
        toastMessage(localizable.playerbackMain_not_task)
    end
end

--召回奖励按钮回调
function PlayerBackMainLayer.onZhaohuijiangliBtnCallBack(sender)
    PlayBackManager:showPlayerBackRewardLayer()
end

--领取礼包按钮回调
function PlayerBackMainLayer.onLingquLibaoBtnCallBack(sender)
    PlayBackManager:lingquLibao()
end

--显示倒计时
function PlayerBackMainLayer:showRemainingTime()
    local info = PlayBackManager:getRecallReturnInfo()
    local function showCutDownString( times )
        local str = nil
        local day = math.floor(times/(3600*24))
        local hour = math.floor(times/3600%24)
        local min = math.floor(times%3600/60)
        local sec = times%60        
        --str =  string.format("%02d",day).."天".. string.format("%02d",hour).."时"..string.format("%02d",min).."分"..string.format("%02d",sec).."秒"   
        str =  stringUtils.format(localizable.common_time_5,day,hour,min,sec)
        return str
    end
    local endtime = info.backTime + 7*24*3600
    local nowtime = MainPlayer:getNowtime()
    local gaptime = endtime - nowtime
    if gaptime < 0 then
        gaptime = 0
        self.txt_time:setText(showCutDownString(gaptime))
        TFDirector:stopTimer(self.timeId)
        AlertManager:close()
        return
    end
    self.txt_time:setText(showCutDownString(gaptime))
end

--倒计时计时器
function PlayerBackMainLayer:cutDowntimer()
    local function update(delta)
        self:showRemainingTime()
    end
    self.timeId = TFDirector:addTimer(1000, -1, nil, update)
end

function PlayerBackMainLayer.cellSizeForTable(table,idx)
    return 110,730
end

function PlayerBackMainLayer.numberOfCellsInTableView(table)
    local self = table.logic
    local num = #self.showtaskList
    return num
end

function PlayerBackMainLayer.tableCellAtIndex(table, idx)
    local self = table.logic
    local cell = table:dequeueCell()
    local panel = nil
    if cell == nil then
        cell = TFTableViewCell:create()
        panel = require('lua.logic.playerback.PlayerBackCell'):new()
        local size = panel:getContentSize()
        panel:setPosition(ccp(panel:getPositionX()+14,panel:getContentSize().height/2 - 50))
        cell:addChild(panel)
        panel:setVisible(true)
        cell.panelNode = panel
        self.panelArr[idx+1] = panel
    else
        panel = cell.panelNode
    end
    panel:setData(self.showtaskList[idx+1])
    return cell
end

return PlayerBackMainLayer