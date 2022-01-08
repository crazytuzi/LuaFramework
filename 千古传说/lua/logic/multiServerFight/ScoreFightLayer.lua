--[[
******跨服个人战-积分赛*******

	-- by quanhuan
	-- 2016/2/22
	
]]

local ScoreFightLayer = class("ScoreFightLayer",BaseLayer)

function ScoreFightLayer:ctor(data)

	self.super.ctor(self, data)
	self:init("lua.uiconfig_mango_new.kuafuwulin.KuaFuJiFen")
end

function ScoreFightLayer:initUI( ui )

	self.super.initUI(self, ui)

    self.generalHead = CommonManager:addGeneralHead(self)
    self.generalHead:setData(ModuleType.KFWLDH,{HeadResType.SYCEE})

    local bg = TFDirector:getChildByPath(ui, 'bg')
    TFResourceHelper:instance():addArmatureFromJsonFile("effect/ui/zhengbasai_jifen_bg.xml")
    local effect = TFArmature:create("zhengbasai_jifen_bg_anim")
    effect:setPosition(ccp(568,320))
    bg:addChild(effect,100)
    effect:playByIndex(0,-1,-1,1)

    self.txtTime = {}
    local titleNode = TFDirector:getChildByPath(ui, 'img_title_fight')
    self.fightStartTips = TFDirector:getChildByPath(titleNode, 'img_jijiangkaishi')
    self.fightingTips = TFDirector:getChildByPath(titleNode, 'txt_shijianshengyu')
    self.fightEndTips = TFDirector:getChildByPath(titleNode, 'img_bishaijieshu')
    self.fightTipsImg = TFDirector:getChildByPath(titleNode, 'img_dzz')

    --第几场标志
    titleNode = nil
    titleNode = TFDirector:getChildByPath(ui, 'Panel_Content')
    self.imgTitle = {}
    for i=1,2 do
        self.imgTitle[i] = TFDirector:getChildByPath(titleNode, 'img_jifen'..i)
        self.imgTitle[i]:setVisible(false)
    end

    --我的信息
    titleNode = nil
    titleNode = TFDirector:getChildByPath(ui, 'Panel_mypaiming')
    self.txtMyRank = TFDirector:getChildByPath(titleNode, 'txt_paiming')
    self.txtMyRank:setVisible(false)
    self.txtMyScore = TFDirector:getChildByPath(titleNode, 'txt_jifen')
    self.txtMyScore:setVisible(false)

    --排行榜信息
    self.ScrollView = TFDirector:getChildByPath(ui, 'ScrollView_KuaFuJiFen_1')
    titleNode = nil
    titleNode = TFDirector:getChildByPath(ui, 'ScrollView_KuaFuJiFen_1')
    self.scrollCell = TFDirector:getChildByPath(titleNode, 'no3')
    self.scrollCell:setVisible(false)

    self.ScrollView:setInnerContainerSize(CCSizeMake(250,84*20))
    self.scrollData = {}
    for i=1,20 do
        local panelCell = self.scrollCell:clone()
        panelCell:setVisible(true)
        panelCell:setPosition(ccp(0,(20-i)*84))
        self.ScrollView:addChild(panelCell)
        self.scrollData[i] = {}

        
        self.scrollData[i].imgRank = TFDirector:getChildByPath(panelCell, 'img_no')
        self.scrollData[i].txtRank = TFDirector:getChildByPath(panelCell, 'no4')
        if i <= 3 then
            self.scrollData[i].imgRank:setVisible(true)
            self.scrollData[i].imgRank:setTexture("ui_new/leaderboard/no"..i..".png")
            self.scrollData[i].txtRank:setVisible(false)
        else
            self.scrollData[i].imgRank:setVisible(false)
            self.scrollData[i].txtRank:setVisible(true)
            self.scrollData[i].txtRank:setText(i)
        end
        self.scrollData[i].name = TFDirector:getChildByPath(panelCell, 'txt_no3')
        self.scrollData[i].name:setVisible(false)
        self.scrollData[i].score = TFDirector:getChildByPath(panelCell, 'txt_jifen')
        self.scrollData[i].score:setVisible(false)
        self.scrollData[i].serverName = TFDirector:getChildByPath(panelCell, 'txt_fuwu')
        self.scrollData[i].serverName:setVisible(false)
    end

    --进攻信息
    self.atkInfo = {}
    local atkNode = TFDirector:getChildByPath(ui, 'bg_jingong')
    self.atkInfo.txt_zhanji = TFDirector:getChildByPath(atkNode, "txt_zhanji")
    self.atkInfo.txt_liansheng = TFDirector:getChildByPath(atkNode, "txt_liansheng")
    self.atkInfo.btn_jinggong = TFDirector:getChildByPath(atkNode, "btn_jinggong")

    --防守信息
    self.defInfo = {}
    local defNode = TFDirector:getChildByPath(ui, 'bg_fangshou')
    self.defInfo.txt_zhanji = TFDirector:getChildByPath(defNode, "txt_zhanji")
    self.defInfo.txt_liansheng = TFDirector:getChildByPath(defNode, "txt_liansheng")
    self.defInfo.btn_fangshou = TFDirector:getChildByPath(defNode, "btn_fangshou")
    

    self.btn_guizhe = TFDirector:getChildByPath(ui, "btn_guizhe")
    self.btn_zhanbao = TFDirector:getChildByPath(ui, "btn_zhanbao")

    --创建TabView
    self.tabViewTiaomuUI = TFDirector:getChildByPath(ui, "Panel_luxiang")
    self.tabViewTiaomu =  TFTableView:create()
    self.tabViewTiaomu:setTableViewSize(self.tabViewTiaomuUI:getContentSize())
    self.tabViewTiaomu:setDirection(TFTableView.TFSCROLLVERTICAL)
    self.tabViewTiaomu:setVerticalFillOrder(TFTableView.TFTabViewFILLTOPDOWN)
    self.tabViewTiaomu.logic = self
    self.tabViewTiaomuUI:addChild(self.tabViewTiaomu)
    self.tabViewTiaomu:setPosition(ccp(0,0))

    self.img_line1 = TFDirector:getChildByPath(ui, "img_line1")
    self.img_line1:setVisible(false)
    self.img_line2 = TFDirector:getChildByPath(ui, "img_line2")
    self.img_line2:setVisible(false)

    self.cellModel  = TFDirector:getChildByPath(self.tabViewTiaomuUI, 'panel_luxiang1')
    self.cellModel:setVisible(false) 
    self.cellModelX =  self.cellModel:getPositionX()
    self.cellModelY =  0--self.cellModel:getContentSize().height-- - 10
end

function ScoreFightLayer:removeUI()
	self.super.removeUI(self)
end

function ScoreFightLayer:onShow()
    self.super.onShow(self)
    self.generalHead:onShow()
end

function ScoreFightLayer:registerEvents()

    if self.registerEventCallFlag then
        return
    end
	self.super.registerEvents(self)

    if self.generalHead then
        self.generalHead:registerEvents()
    end
    math.randomseed(os.time())
    
    self.getGrandUpdateCallBack = function (event)

        if self.randTimer == nil then
            
            local count = 1 + math.ceil(math.random()*100)%10
            count = count*1000
            -- print('countcountcountcountcount = ',count)
            self.randTimer = TFDirector:addTimer(count, 1, nil, function () 
                if self.randTimer then
                    TFDirector:removeTimer(self.randTimer)
                    self.randTimer = nil
                end  
                local state = self.currStateType
                -- print('statestatestatestatestate = ',state)
                if state == MultiServerFightManager.ActivityState_2 or state == MultiServerFightManager.ActivityState_4 then
                    MultiServerFightManager:requestCrossChampionsInfos(state,MultiServerFightManager.updateChampoinMsg)    
                end
            end)
        end
    end
    TFDirector:addMEGlobalListener(MultiServerFightManager.getGrandUpdate, self.getGrandUpdateCallBack)

    self.updateChampoinCallBack = function ( event )
    -- print('updateChampoinCallBackupdateChampoinCallBackupdateChampoinCallBack = = = ')
        self.rankDataInfo = MultiServerFightManager:getRankInfosForChampions()
        self.rankDataInfo.replays = self.rankDataInfo.replays or {}
        self.tableData = clone(self.rankDataInfo.replays)

        self:showMyInfo()
        self:showRankInfo()
        self:showCutDownTimer()
        if self.tabViewTiaomu then
            self.tabViewTiaomu:reloadData()
        end
    end
    TFDirector:addMEGlobalListener(MultiServerFightManager.updateChampoinMsg, self.updateChampoinCallBack)

    self.btn_guizhe:addMEListener(TFWIDGET_CLICK, audioClickfun(self.btnRuleClick))

    self.defInfo.btn_fangshou:addMEListener(TFWIDGET_CLICK, audioClickfun(self.btnDefClick))
    self.atkInfo.btn_jinggong:addMEListener(TFWIDGET_CLICK, audioClickfun(self.btnAtkClick))

    self.btn_zhanbao:addMEListener(TFWIDGET_CLICK, audioClickfun(self.btnZhanBaoClick))

    self.tabViewTiaomu:addMEListener(TFTABLEVIEW_SIZEFORINDEX, self.cellSizeForTable)
    self.tabViewTiaomu:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, self.numberOfCellsInTableView)
    self.tabViewTiaomu:addMEListener(TFTABLEVIEW_SIZEATINDEX, self.tableCellAtIndex)
    self.tabViewTiaomu:addMEListener(TFTABLEVIEW_SCROLL, self.tableScroll)
    self.tabViewTiaomu:reloadData()

    self.registerEventCallFlag = true 
end

function ScoreFightLayer:removeEvents()

    self.super.removeEvents(self)

	if self.generalHead then
        self.generalHead:removeEvents()
    end	

    self.tabViewTiaomu:removeMEListener(TFTABLEVIEW_SIZEFORINDEX)
    self.tabViewTiaomu:removeMEListener(TFTABLEVIEW_SIZEATINDEX)
    self.tabViewTiaomu:removeMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW)

    if self.countDownTimer then
        TFDirector:removeTimer(self.countDownTimer)
        self.countDownTimer = nil
    end 

    if self.randTime then
        TFDirector:removeTimer(self.randTime)
        self.randTime = nil
    end

    if self.updateChampoinCallBack then
        TFDirector:removeMEGlobalListener(MultiServerFightManager.updateChampoinMsg, self.updateChampoinCallBack)
        self.updateChampoinCallBack = nil
    end
    if self.getGrandUpdateCallBack then
        TFDirector:removeMEGlobalListener(MultiServerFightManager.getGrandUpdate, self.getGrandUpdateCallBack)
        self.getGrandUpdateCallBack = nil
    end
    
    self.registerEventCallFlag = nil  
end

function ScoreFightLayer:dispose()
	self.super.dispose(self)
    if self.generalHead then
        self.generalHead:dispose()
        self.generalHead = nil
    end    
end

function ScoreFightLayer:setData(stateType)
    self.currStateType = stateType
    self.rankDataInfo = MultiServerFightManager:getRankInfosForChampions()
    self.rankDataInfo.replays = self.rankDataInfo.replays or {}
    self.tableData = clone(self.rankDataInfo.replays)
    -- print('rankDataInfo = ',self.rankDataInfo)
    self:showMyInfo()
    self:showRankInfo()
    self:showCutDownTimer()

    if self.tabViewTiaomu then
        self.tabViewTiaomu:reloadData()
    end
end

function ScoreFightLayer:showCutDownTimer()

    local timeInfo = MultiServerFightManager:getFightTimeByState( self.currStateType )
    local currTime = MultiServerFightManager:getCurrSecond()
    local countDown = 0
    local txtNum = nil
    if self.countDownTimer then
        TFDirector:removeTimer(self.countDownTimer)
        self.countDownTimer = nil
    end
    -- if self.currStateType == MultiServerFightManager.ActivityState_1 
    --     or self.currStateType == MultiServerFightManager.ActivityState_3 then
    --     self.fightStartTips:setVisible(true)
    --     self.fightingTips:setVisible(false)
    --     self.fightEndTips:setVisible(false)
    --     self.fightTipsImg:setVisible(false)
    --     txtNum = TFDirector:getChildByPath(self.fightStartTips, 'txt_ready_time')
    --     countDown = timeInfo.fightTime - currTime
    -- else
    if self.currStateType == MultiServerFightManager.ActivityState_2
        or self.currStateType == MultiServerFightManager.ActivityState_4 then
        self.fightStartTips:setVisible(false)
        self.fightingTips:setVisible(false)
        self.fightEndTips:setVisible(false)
        self.fightTipsImg:setVisible(false)
        if currTime < timeInfo.fightTime then
            self.fightStartTips:setVisible(true)
            txtNum = TFDirector:getChildByPath(self.fightStartTips, 'txt_ready_time')
            countDown = timeInfo.fightTime - currTime
        elseif currTime < timeInfo.endTime then
            self.fightTipsImg:setVisible(true)
            self.fightingTips:setVisible(true)
            txtNum = TFDirector:getChildByPath(self.fightingTips, 'txt_shengyushijian')
            countDown = timeInfo.endTime - currTime
        else
            self.fightEndTips:setVisible(true)
            return
        end
    end

    if countDown <= 0 then
        countDown = 0
    end 
    txtNum:setText(FactionFightManager:getTimeString( countDown ))    

    self.countDownTimer = TFDirector:addTimer(1000, -1, nil, function ()
        if countDown <= 0 then
            if self.countDownTimer then
                TFDirector:removeTimer(self.countDownTimer)
                self.countDownTimer = nil
            end
            txtNum:setText(FactionFightManager:getTimeString( countDown ))  
            self:showCutDownTimer()
        else
            countDown = countDown - 1
            txtNum:setText(FactionFightManager:getTimeString( countDown ))
        end
    end)
end

function ScoreFightLayer:showMyInfo()
    local currIndex = math.ceil(self.currStateType/2)

    self.imgTitle[currIndex]:setVisible(true)

    --我的信息
    if self.currStateType == MultiServerFightManager.ActivityState_1 or self.currStateType == MultiServerFightManager.ActivityState_3 then
        local str = stringUtils.format(localizable.multiFight_atk_details, 0, 0)
        self.atkInfo.txt_zhanji:setText(str)
        str = stringUtils.format(localizable.multiFight_atk_liansheng, 0)
        self.atkInfo.txt_liansheng:setText(str)

        local str = stringUtils.format(localizable.multiFight_atk_details, 0, 0)
        self.defInfo.txt_zhanji:setText(str)
        str = stringUtils.format(localizable.multiFight_atk_liansheng, 0)
        self.defInfo.txt_liansheng:setText(str)
        return
    end
    self.txtMyRank:setVisible(true)
    self.txtMyScore:setVisible(true)
    if self.rankDataInfo.myRank == nil or self.rankDataInfo.myRank == 0 then
        self.txtMyRank:setText(0)
        self.txtMyScore:setText(0)

        self.atkInfo.btn_jinggong:setGrayEnabled(true)
        self.defInfo.btn_fangshou:setGrayEnabled(true)
        self.atkInfo.btn_jinggong:setTouchEnabled(false)
        self.defInfo.btn_fangshou:setTouchEnabled(false)
    else
        self.atkInfo.btn_jinggong:setGrayEnabled(false)
        self.defInfo.btn_fangshou:setGrayEnabled(false)
        self.atkInfo.btn_jinggong:setTouchEnabled(true)
        self.defInfo.btn_fangshou:setTouchEnabled(true)
        self.txtMyRank:setText(self.rankDataInfo.myRank)
        self.txtMyScore:setText(self.rankDataInfo.score)
    end

    -- --进攻信息
    local atkWin = self.rankDataInfo.atkWin or 0
    local atkLost = self.rankDataInfo.atkLost or 0
    local str = stringUtils.format(localizable.multiFight_atk_details, atkWin, atkLost)
    self.atkInfo.txt_zhanji:setText(str)
    local atkWinStreak = self.rankDataInfo.atkWinStreak or 0
    str = stringUtils.format(localizable.multiFight_atk_liansheng, atkWinStreak)
    self.atkInfo.txt_liansheng:setText(str)

    local defWin = self.rankDataInfo.defWin or 0
    local defLost = self.rankDataInfo.defLost or 0
    local str = stringUtils.format(localizable.multiFight_atk_details, defWin, defLost)
    self.defInfo.txt_zhanji:setText(str)
    local defWinStreak = self.rankDataInfo.defWinStreak or 0
    str = stringUtils.format(localizable.multiFight_atk_liansheng, defWinStreak)
    self.defInfo.txt_liansheng:setText(str)
end

function ScoreFightLayer:showRankInfo()
    
    --排行榜信息
    if self.currStateType == MultiServerFightManager.ActivityState_1 or self.currStateType == MultiServerFightManager.ActivityState_3 then
        return
    end
    -- print('==================================self.rankDataInfo = ',self.rankDataInfo)
    for i=1,20 do            

        local data = (self.rankDataInfo.ranks and self.rankDataInfo.ranks[i])
        if data then
            self.scrollData[i].name:setText(data.name)
            self.scrollData[i].name:setVisible(true)
            self.scrollData[i].score:setText(localizable.multiFight_score..data.score)
            self.scrollData[i].score:setVisible(true)
            self.scrollData[i].serverName:setVisible(true)
            self.scrollData[i].serverName:setText(data.serverName)
        else
            self.scrollData[i].name:setVisible(false)
            self.scrollData[i].score:setVisible(false)
            self.scrollData[i].serverName:setVisible(false)
        end
    end
end

function ScoreFightLayer.btnRuleClick( btn )
    MultiServerFightManager:openRuleLayer()
end

function ScoreFightLayer.btnDefClick( btn )
    MultiServerFightManager:btnDefClick()
end

function ScoreFightLayer.btnAtkClick( btn )
    MultiServerFightManager:btnAtkClick()
end

function ScoreFightLayer.btnZhanBaoClick( btn )
    local layer = AlertManager:addLayerByFile("lua.logic.multiServerFight.KuaFuBattlefieldLayer", AlertManager.BLOCK_AND_GRAY)
    AlertManager:show()
end

function ScoreFightLayer:refreshArrowBtn()
    local currPosition = self.tabViewTiaomu:getContentOffset()
    print("currPosition = ",currPosition)
    if self.tabViewTiaomu then
        self.tableData = self.tableData or {}
        local guildPracticeNum = #self.tableData
        local offsetMax = self.tabViewTiaomuUI:getContentSize().height-122*guildPracticeNum
        local currPosition = self.tabViewTiaomu:getContentOffset()
        if currPosition.y < 0 and offsetMax >= currPosition.y then
            self.img_line1:setVisible(false)
        else
            self.img_line1:setVisible(false)
        end

        if currPosition.y >= 0 then
            self.img_line2:setVisible(false)
        else
            self.img_line2:setVisible(false)
        end
    end
end

function ScoreFightLayer.tableScroll( table )
    local self = table.logic
    self:refreshArrowBtn()
end


function ScoreFightLayer.cellSizeForTable(table,idx)
    return 122,254
end

function ScoreFightLayer.numberOfCellsInTableView(table)
    local self = table.logic

    local num = 0
    if self.tableData then
        num = #self.tableData
    end
    return num
end

function ScoreFightLayer.tableCellAtIndex(table, idx)

    local self = table.logic
    local cell = table:dequeueCell()
    local panel = nil
    if cell == nil then
        cell = TFTableViewCell:create()
        panel = self.cellModel:clone()
        local size = panel:getContentSize()
        panel:setPosition(ccp(self.cellModelX, self.cellModelY))
        cell:addChild(panel)
        panel:setVisible(true)
        cell.panelNode = panel
    else
        panel = cell.panelNode
    end
    self:cellInfoSet(panel, idx+1)

    return cell
end

function ScoreFightLayer:cellInfoSet(panel, idx)

    
    local data = self.tableData[idx]

    local atkNode = TFDirector:getChildByPath(panel, "panel_tou1")
    local atkFrame = TFDirector:getChildByPath(atkNode, "img_tou2")
    local atkIcon = TFDirector:getChildByPath(atkNode, "img_touxiang")
    local atkName = TFDirector:getChildByPath(atkNode, "txt_name")    
    local atkWin = TFDirector:getChildByPath(atkNode, "panel_shengli")
    local atkLose = TFDirector:getChildByPath(atkNode, "panel_shibai")
    


    local defNode = TFDirector:getChildByPath(panel, "panel_tou2")
    local defFrame = TFDirector:getChildByPath(defNode, "img_tou2")
    local defIcon = TFDirector:getChildByPath(defNode, "img_touxiang")
    local defName = TFDirector:getChildByPath(defNode, "txt_name")
    local defWin = TFDirector:getChildByPath(defNode, "panel_shengli")
    local defLose = TFDirector:getChildByPath(defNode, "panel_shibai")

    local btn_luxiang = TFDirector:getChildByPath(panel, "btn_luxiang")
    local txt_time = TFDirector:getChildByPath(panel, "txt_time")
    
    local RoleIcon = RoleData:objectByID(data.atkUseIcon)
    atkIcon:setTexture(RoleIcon:getIconPath())  
    Public:addFrameImg(atkIcon,data.atkFrameId) 
    atkName:setText(data.atkName)

    RoleIcon = RoleData:objectByID(data.defUseIcon)
    defIcon:setTexture(RoleIcon:getIconPath())  
    Public:addFrameImg(defIcon,data.defFrameId) 
    defName:setText(data.defNam)

    if data.atkWin then
        atkWin:setVisible(true)
        atkLose:setVisible(false)
        defWin:setVisible(false)
        defLose:setVisible(true)
    else
        atkWin:setVisible(false)
        atkLose:setVisible(true)
        defWin:setVisible(true)
        defLose:setVisible(false)
    end

    btn_luxiang.replayId = data.replayId
    btn_luxiang:addMEListener(TFWIDGET_CLICK, audioClickfun(self.recordBtnClick))

    local dTime = MainPlayer:getNowtime() - math.floor(data.createTime/1000)
    if dTime < 0 then
        dTime = 0
    end
    local txtTime = FriendManager:formatTimeToStringWithOut(dTime)
    txt_time:setText(txtTime)    
end
   
function ScoreFightLayer.recordBtnClick( btn )
    local replayId = btn.replayId
    if replayId and replayId ~= 0 then
        print("replay id = ",replayId)
        MultiServerFightManager:onBtnReportClick( replayId )
    end
end 
return ScoreFightLayer