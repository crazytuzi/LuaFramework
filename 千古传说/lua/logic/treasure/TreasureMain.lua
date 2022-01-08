--[[
    寻宝
    -- by yongkang
    -- 2016-02-22   ini
]]
local TreasureMain = class("TreasureMain",BaseLayer)

function TreasureMain:ctor(data)
    self.super.ctor(self, data)
    self.recordList = {}
    self:init("lua.uiconfig_mango_new.treasure.TreasureMain")
end

function TreasureMain:initUI( ui )
    self.super.initUI(self, ui)
    self.ui = ui
    self.btn_close = TFDirector:getChildByPath(ui, 'btn_fanhui')

    self.box_imgs = {"icon/item/30049.png","icon/item/30006.png","icon/item/30005.png","icon/item/30004.png","icon/item/30050.png"}

    self.typeButton ={}
    local btn_myHistory = TFDirector:getChildByPath(ui, 'btn_title1')  
    local btn_playerHistory = TFDirector:getChildByPath(ui, 'btn_title2')    
    table.insert(self.typeButton,btn_myHistory)       
    table.insert(self.typeButton,btn_playerHistory)
    

    self.btn_treasures ={}
    local btn_treasure1 = TFDirector:getChildByPath(ui,'btn_treasure1')
    local btn_treasure10 = TFDirector:getChildByPath(ui,'btn_treasure10')
    local btn_treasure30 = TFDirector:getChildByPath(ui,'btn_treasure30')

    table.insert(self.btn_treasures,btn_treasure1)
    table.insert(self.btn_treasures,btn_treasure10)
    table.insert(self.btn_treasures,btn_treasure30)

    self.btn_golds ={}
    local txt_treasure1 = TFDirector:getChildByPath(btn_treasure1,'txt_numb')
    local txt_treasure10 = TFDirector:getChildByPath(btn_treasure10,'txt_numb')
    local txt_treasure30 = TFDirector:getChildByPath(btn_treasure30,'txt_numb')
    table.insert(self.btn_golds,txt_treasure1)
    table.insert(self.btn_golds,txt_treasure10)
    table.insert(self.btn_golds,txt_treasure30)


    self.txt_numb_haves = {}
    local txt_numb_hava1 = TFDirector:getChildByPath(btn_treasure1,'txt_numb_have')
    local txt_numb_hava10 = TFDirector:getChildByPath(btn_treasure10,'txt_numb_have')
    local txt_numb_hava30 = TFDirector:getChildByPath(btn_treasure30,'txt_numb_have')
    table.insert(self.txt_numb_haves,txt_numb_hava1)
    table.insert(self.txt_numb_haves,txt_numb_hava10)
    table.insert(self.txt_numb_haves,txt_numb_hava30)

    self.btn_props ={}
    local img_res_icon1 = TFDirector:getChildByPath(btn_treasure1,'img_res_icon')
    local img_res_icon10 = TFDirector:getChildByPath(btn_treasure10,'img_res_icon')
    local img_res_icon30 = TFDirector:getChildByPath(btn_treasure30,'img_res_icon')
    table.insert(self.btn_props,img_res_icon1)
    table.insert(self.btn_props,img_res_icon10)
    table.insert(self.btn_props,img_res_icon30)

    self.btn_baoxiang   = TFDirector:getChildByPath(ui,'btn_baoxiang')
    self.btn_baoxiang_get   = TFDirector:getChildByPath(ui,'btn_baoxiang_s')
    self.txt_count = TFDirector:getChildByPath(ui,'txt_numb')
    self.loading_bar = TFDirector:getChildByPath(ui,'loadingbar_1')
    
    self.txt_time = TFDirector:getChildByPath(ui,'txt_time')

    self.bg_icon = TFDirector:getChildByPath(ui,'bg_icon')
    self.img_icon = TFDirector:getChildByPath(self.bg_icon,'img_icon')

    self.panel_list = TFDirector:getChildByPath(ui,'Panel_list')
    self.panel_1 = TFDirector:getChildByPath(ui,'Panel1')
    self.panel_pro = TFDirector:getChildByPath(ui,'panel_pro')

    self.btnIndex = 2
    self.bFistDraw = true
    self.curBtnIndex  = 0
    self.recordList ={}
    
    self.bClick = true

    self.currNode = nil
    self.m_currentItemIndex = 1
    self.m_targetNumber = 1
    self.updateTimer = nil

    self.nodes = {}
    local sizeX = 83.5
    local sizeY = 78.5
    local positionX = 414
    local positionY = 156
    local leftTop = 6
    local rightTop = 11
    local rightBottom = 16
    for i=1,19 do
        local node = createUIByLuaNew("lua.uiconfig_mango_new.treasure.IconXuanZhong")
        if i > 16 then
            node:setScale(0.65)

            node:setPosition(ccp(positionX-16+(19-i + 1)*(sizeX + 26),positionY))
        else     
            node:setScale(0.54)
            if i <= leftTop then
               node:setPosition(ccp(positionX,positionY + sizeY * (i- 1)))
            elseif i <= rightTop then
                node:setPosition(ccp(positionX+(i-leftTop)*sizeX,positionY+ (leftTop-1)  * sizeY)) 
            elseif i <= rightBottom then
                node:setPosition(ccp(positionX+(leftTop-1)*sizeX,positionY+(rightBottom-i ) * sizeY)) 
            else
                node:setPosition(ccp(positionX+(19-i + 1)*sizeX,positionY))
            end
        end        
        table.insert(self.nodes, node)
        self.panel_1:addChild(node)
    end


    self.Panel_Paihang = TFDirector:getChildByPath(self, 'Panel_Paihang')
    self.img_di = TFDirector:getChildByPath(self.Panel_Paihang, 'img_di')
    self.btn_jifen = TFDirector:getChildByPath(self.Panel_Paihang, 'btn_jifen')
    self.btn_shuaxin = TFDirector:getChildByPath(self.Panel_Paihang, 'btn_shuaxin')
    self.panel_rank = TFDirector:getChildByPath(self.Panel_Paihang, 'panel_rank')
    self.panel_rank_2 = TFDirector:getChildByPath(self.Panel_Paihang, 'panel_rank_2')
    self.panel_gun = TFDirector:getChildByPath(self.Panel_Paihang, 'panel_gun')

    self.panel_rank:retain()
    self.panel_rank:removeFromParent(true)
    self.panel_rank:setVisible(false)
    self.panel_rank_2:retain()
    self.panel_rank_2:removeFromParent(true)
    self.panel_rank_2:setVisible(false)
    self.img_di:setPositionX(0)
    self.rankLayer_show = false
    TreasureManager:refreshRankList()
end

function TreasureMain:loadData(count,configMessage,golds,props,boxCounts,boxIndex,round,boxRewardList,actTime,freeTimes)
    print(count.."----------count---------------")
        

    self.count = count
    self.configList = configMessage
    self.golds = golds
    self.props = props
    self.boxCounts = boxCounts
    self.boxIndex = boxIndex
    self.round = round
    self.boxRewardList = boxRewardList
    self.m_totalItemCount = #self.configList
    self.freeTimes = freeTimes
    self.time = math.ceil(actTime / 1000 )
    --self.time = 5
    self:refresUI()
   -- self.txt_count:setText(self.count)
    self.highNodes ={}
    for i=1,#self.configList do
       self:initCell(self.nodes[i],self.configList[i]) 
    end

    
    local activity = OperationActivitiesManager:ActivityWithType(OperationActivitiesManager.Type_Active_XunBao)
    if activity then
        self.time = activity.endTime - MainPlayer:getNowtime()
        if self.time <= 0 then
            self.time = 0 
        end    
    end
    
    if  self.end_timerID == nil then
        self.end_timerID = TFDirector:addTimer(1000, -1, nil, 
        function() 
            if self.end_timerID ~= nil then
                self:showNextTimer()
            end
        end)
    end
    self.isCrossServer = false
    local activity_score = OperationActivitiesManager:ActivityWithType(OperationActivitiesManager.Type_Score_XunBao)
    if activity_score then
        self.isCrossServer = activity_score.multiSever
    end
    self:showNextTimer()
end

function TreasureMain:showNextTimer()

    self.time = self.time - 1
    if self.time <=  0 then
        if self.end_timerID then
            TFDirector:removeTimer(self.end_timerID)
            self.end_timerID = nil
        end
        toastMessage(localizable.treasureMain_tiemout)
        AlertManager:close()
    end    
    local timeCount = self.time
    local secInOneDay  = 24 * 3600
    local day = math.floor(timeCount/secInOneDay)
    local sec   = timeCount - secInOneDay * day
    local time1 = math.floor(sec/3600)
    local time2 = math.floor((sec-time1 * 3600)/60)
    local time3 = math.fmod(sec, 60)
    local timedesc1 = stringUtils.format(localizable.common_time_5, day, time1, time2, time3)
    self.txt_time:setText(timedesc1)
end

function TreasureMain:refresUI()
    --按钮   
    for i=1,3 do
        local tool = BagManager:getItemById(tonumber(self.props[i]))
        self.btn_props[i]:setVisible(true)
        if tool and tool.num >= 1 then
            self.btn_props[i]:setTexture(tool:GetPath()) 
            self.btn_props[i]:setScale(0.4)
            self.btn_golds[i]:setText("1") 
            self.txt_numb_haves[i]:setVisible(true)
            self.txt_numb_haves[i]:setText(stringUtils.format(localizable.changetProLayer_have ,tool.num))
        else
            self.btn_props[i]:setTexture("ui_new/common/xx_yuanbao_icon.png")
            self.btn_props[i]:setScale(1)
            self.btn_golds[i]:setText(self.golds[i])
            self.txt_numb_haves[i]:setVisible(false)
        end    
    end
    if self.boxIndex >=0 and self.boxIndex <=5 then
        if self.boxIndex == 5 then
            self.boxIndex = 0
            self.round = self.round + 1
        end   
       
        local nextBoxCount = self.boxCounts[self.boxIndex + 1] + (self.round) * self.boxCounts[5]
        print("nextBoxCount----------"..nextBoxCount)
        local percent = self.count / nextBoxCount * 100
        if percent >= 100 then
            percent =100
        end    
        self.loading_bar:setPercent(percent)
        --self.txt_count:setText(string.format(localizable.treasureMain_text2, self.count , nextBoxCount ))
    self.txt_count:setText(stringUtils.format(localizable.treasureMain_text2, self.count, nextBoxCount))
        self.btn_baoxiang_get:setTexture(self.box_imgs[self.boxIndex + 1])

        local open_state = true
        if self.count < nextBoxCount then
            open_state = false
        end 
        TreasureManager.bRed = open_state
        CommonManager:setRedPoint(self.btn_baoxiang_get, open_state,"boxOpen",ccp(-6,-12)) 
        CommonManager:setRedPoint(self.btn_baoxiang, open_state,"boxOpen",ccp(-6,-12)) 

    end    
    --更新免费状态  
    if self.freeTimes > 0 then
        self.btn_props[1]:setVisible(false)
        self.btn_golds[1]:setText(localizable.treasureMain_text4)
        TreasureManager.bFreeRed = true
        self.txt_numb_haves[1]:setVisible(false)
    else
        TreasureManager.bFreeRed = false
        --CommonManager:setRedPoint(self.btn_treasures[1], TreasureManager.bFreeRed,"btn_treasures",ccp(0,0)) 
        
    end  
     CommonManager:setRedPoint(self.btn_treasures[1], TreasureManager.bFreeRed,"boxOpen",ccp(2,5))   
end


function TreasureMain:drawDefault(index)
    if self.curBtnIndex == index then
        return
    end
    --1个人历史2玩家历史
    local btn = nil
    if self.btnLastIndex ~= nil then
        btn = self.typeButton[self.btnLastIndex]
        btn:setTextureNormal("ui_new/treasure/tab_"..self.btnLastIndex..".png")
    end

    self.btnLastIndex = index
    self.curBtnIndex  = index

    btn = self.typeButton[self.curBtnIndex]
    btn:setTextureNormal("ui_new/treasure/tab_"..self.btnLastIndex.."h.png")
    self:onClickDay(index)
end

function TreasureMain:onClickDay(index)
    self.bFistDraw = true
    --self.EggRecordList = GoldEggManager.EggRecordList[index]
    --local nowCount = #self.recordList
    TreasureManager.recordList[index] = {}
    TreasureManager:requestRecord(0, 2, index)
end

function TreasureMain:runHighAction()
    --if self.m_currentItemIndex < self.m_targetNumber then--
        self:highlightTargetItem(self.m_currentItemIndex)
        self.m_currentItemIndex = self.m_currentItemIndex + 1        
        
        if self.updateTimerID then
                TFDirector:removeTimer(self.updateTimerID)
                self.updateTimerID = nil
        end
        local round = math.random(2)+3
        local round_now = 0
        local need_time = 0
        self.updateTimerID = TFDirector:addTimer(30, -1, nil,
            function()
                if self.updateTimerID ~= nil then
                    local last = (round - round_now)*self.m_totalItemCount + self.m_targetNumber - self.m_currentItemIndex
                    if last < 8 then
                        need_time = need_time + 30
                        if need_time >= 200 then
                            if self:nextItem(round ,round_now,1) then
                                round_now = round_now + 1
                            end
                            need_time = 0
                        end
                    else
                        local speed = math.random(2)
                        if self:nextItem(round ,round_now,speed) then
                            round_now = round_now + 1
                        end
                    end

                end
        end)
    --end
end

function TreasureMain:nextItem(round ,round_now,index)   
    --print(self.m_currentItemIndex)
    self:highlightTargetItem(self.m_currentItemIndex);
    if self.m_currentItemIndex == self.m_targetNumber and round == round_now then
        self:doOverAction()
        if self.updateTimerID then
            TFDirector:removeTimer(self.updateTimerID)
            self.updateTimerID = nil
        end
    end    
    self.m_currentItemIndex = self.m_currentItemIndex + index
   -- print("---%d---%d---%d",self.m_currentItemIndex,self.m_targetNumber,self.m_totalItemCount)
    if self.m_currentItemIndex  > self.m_totalItemCount then
        self.m_currentItemIndex = 1
        return true
    end
    return false
end

function TreasureMain:doOverAction()
    self:initMoveCell()
end

function TreasureMain:highlightTargetItem( target)
    for i = 1, #self.configList do
        if target ~= i then
            self:unhighlightItem(i)
        else
            self:highlightItem(i)
        end
    end
end

function TreasureMain:highlightItem(index)
    if index < 1 and index > #self.configList then
        return
    end
    self.highNodes[index]:setVisible(true)
end

function TreasureMain:unhighlightItem(index)
    if index < 1 and index > #self.configList then
        return
    end
    self.highNodes[index]:setVisible(false)
end

function TreasureMain:playAnim(rewardList)
    if self.effect then
        self.effect:playByIndex(0, -1, -1, 0)
    else 
        local filePath = "effect/xunbao.xml"
        TFResourceHelper:instance():addArmatureFromJsonFile(filePath)
        local effect = TFArmature:create("xunbao_anim")
        effect:setAnimationFps(GameConfig.ANIM_FPS)
        effect:playByIndex(0, -1, -1, 0)
        effect:setVisible(true)
        effect:setPosition(ccp(480 ,320))
        self.panel_1:addChild(effect,100)
        self.effect = effect
    end

    self.effect:addMEListener(TFARMATURE_COMPLETE,function()
        self.effect:removeMEListener(TFARMATURE_COMPLETE) 
        self.bClick = true
         print("fuck dwk---------------->")
        self:refreshHistoryByMe()
        TreasureManager:openResultLayer(rewardList)
    end)
end


function TreasureMain:initCell(node,configList)    
    local bg_icon = TFDirector:getChildByPath(node, 'bg_icon')
    local img_icon = TFDirector:getChildByPath(node, 'img_icon')
    local txt_num = TFDirector:getChildByPath(node, 'txt_num')
    local img_xuanzhong  = TFDirector:getChildByPath(node, 'img_xuanzhong')
    img_xuanzhong:setVisible(false)
    local img_jingpin = TFDirector:getChildByPath(node, 'img_jingpin')
    img_jingpin:setVisible(false)
    local img_jipin = TFDirector:getChildByPath(node, 'img_jipin')
    img_jipin:setVisible(false)

    table.insert(self.highNodes,img_xuanzhong)

    local item = configList
    print(configList)
    local roleTypeId = item.resId
    local newCardRoleData = nil
    local path = nil
    if item.resType == EnumDropType.ROLE then
        newCardRoleData = RoleData:objectByID(roleTypeId)
        if newCardRoleData == nil then
            print('roleTypeId = ', roleTypeId)
        end
        path = newCardRoleData:getIconPath()
    else
        local data = {}
        data.type   = item.resType
        data.itemId = item.resId
        data.number = item.number
        newCardRoleData = BaseDataManager:getReward(data)
        path = newCardRoleData.path
    end

    if newCardRoleData ~= nil then
        bg_icon:setTexture(GetColorIconByQuality(newCardRoleData.quality))
        img_icon:setTexture(path)
        img_icon:setTouchEnabled(true)
        img_icon:addMEListener(TFWIDGET_CLICK,
        audioClickfun(function()
            Public:ShowItemTipLayer(roleTypeId, item.resType)
        end))

        if item.resType == EnumDropType.GOODS then

            newCardRoleData = ItemData:objectByID(roleTypeId)
            
            newCardRoleData.itemid = newCardRoleData.id

            if newCardRoleData.type == EnumGameItemType.Soul and newCardRoleData.kind ~= 3 then
                Public:addPieceImg(img_icon,newCardRoleData,true)
            elseif newCardRoleData.type == EnumGameItemType.Piece then
                Public:addPieceImg(img_icon,newCardRoleData,true)
            else
                Public:addPieceImg(img_icon,newCardRoleData,false)
            end

        end
        print("item.number------"..item.number)      
        txt_num:setText(item.number)
        --
        if item.quality and item.quality == 1 then
            img_jingpin:setVisible(true)
        elseif item.quality and item.quality == 2 then
            img_jipin:setVisible(true)
        elseif item.quality and item.quality == 3 then
            print("jingpin")
        end    
    end

end

function TreasureMain:initMoveCell()   
    local node = createUIByLuaNew("lua.uiconfig_mango_new.treasure.IconXuanZhong");
    node:setScale(0.5)
    self:initCell(node,self.configList[self.m_targetNumber])
    node:setPosition(ccp(self.nodes[self.m_targetNumber]:getPosition()))

    local array = TFVector:create()
    local seqArr = TFVector:create()

    local moveTo = CCMoveTo:create(0.5,ccp(591,328))
    array:addObject(moveTo)
    local scaleTo = CCScaleTo:create(0.5,1)
    array:addObject(scaleTo)  
    local spawn = CCSpawn:create(array)
    seqArr:addObject(spawn) 
        local funcall = CCCallFuncN:create(
        function ()
            self.bClick = true
            --移除上一次的
            self:refreshHistoryByMe()
            local x = self.panel_1:getChildByTag(999)
            if x then
                x:removeFromParentAndCleanup(true)
            end
            node:setTag(999)
            
            local data = TreasureManager:getReward()
            local rewardList = data.rewardList
            print("rewardList--------once")

            if #rewardList > 0 then
                local reward = rewardList[1]
                local commonReward ={}
                commonReward.type   = reward.resType
                commonReward.itemId = reward.resId
                commonReward.number = reward.number
    
                local rewardItem =  BaseDataManager:getReward(commonReward) 
                RewardManager:toastRewardMessage(rewardItem)
            end 


        end
    )
    seqArr:addObject(funcall) 
      
    local action = CCSequence:create(seqArr)
    node:runAction(action)
   
    self.panel_1:addChild(node)    

end

function TreasureMain.onBtnClose()
    AlertManager:close();
end

function TreasureMain.onBtnClickType(sender)
    local self  = sender.logic
    local index = sender.index

    if self.curBtnIndex == index then
        local offsetPos = self.myResultTableView:getContentOffset()
        return
    end
    self:drawDefault(index)
end

function TreasureMain.onBtnTreansure(btn)
    local self =  btn.logic
    local index = btn.index
    if self.bClick ~= true then --只有执行完一轮动画 才能下一次点击
        toastMessage(localizable.treasureMain_text1)
        return
    end
    if self.time <= 0  then --
        toastMessage(localizable.treasureMain_tiemout)
        return
    end

    local tool = BagManager:getItemById(tonumber(self.props[index]))    
    --首先判断免费次数
    if self.freeTimes > 0 and index == 1  then 
        self:requestInfo(1,0) 
        self.freeTimes = self.freeTimes - 1   
    elseif tool and tool.num > 0 then --物品不足
        self:requestInfo(index,tool.num)
    else
        if MainPlayer:isEnoughSycee(tonumber(self.golds[index]), true) then--物品不足 判断元宝
            self:requestInfo(index,0)
        end            
    end   

    
end

function TreasureMain:requestInfo(index,toolNumber)
      
    if index == 1 then  --一次
        TreasureManager:requestReward(1)
        self.bClick = false
    elseif  index == 2 then
        TreasureManager:requestReward(10)
        self.bClick = false
    elseif index == 3 then
        if toolNumber == 0 then
            if TreasureManager.bTips == false then
                    CommonManager:showOperateSureTipLayer(
                        function(data, widget)
                            TreasureManager:requestReward(30)
                            self.bClick = false
                            TreasureManager.bTips = widget:getSelectedState() or false;
                        end,
                        function(data, widget)
                            AlertManager:close()
                            TreasureManager.bTips = widget:getSelectedState() or false;
                        end,
                        {
                            --title="操作确认",
                            --msg = "寻宝30次需要花费"..self.golds[3].."元宝，是否确认",                            --title="操作确认",
                            title=localizable.TreasureMain_tips1,
                            msg = stringUtils.format(localizable.TreasureMain_tips2,self.golds[3]),
                            showtype = AlertManager.BLOCK_AND_GRAY
                        }
                    )
                    --return
            else
                TreasureManager:requestReward(30)
                self.bClick = false
            end    
        else
            TreasureManager:requestReward(30)
            self.bClick = false
        end
    end 

    if self.currNode then 
        self.currNode:setVisible(false)      
    end
end


function TreasureMain.onBtnBox(sender)
    print("onBtnBox")
    local self = sender.logic
    local layer = require("lua.logic.treasure.TreasureBox"):new()
    layer:loadData(self.boxCounts,self.round,self.boxIndex,self.count,self.boxRewardList)
    AlertManager:addLayer(layer,AlertManager.BLOCK_AND_GRAY_CLOSE,AlertManager.TWEEN_1)
    AlertManager:show()
end

function TreasureMain.onBtnGetBox(sender)
    local self = sender.logic
   -- boxIndex
    TreasureManager:requestBoxReward(self.boxIndex + 1)
end

function TreasureMain:refresRecordUI()
    if self.myResultTableView ~= nil then
        
        local offsetSize1 = self.myResultTableView:getContentSize()
      --  print("offsetSize1 = ", offsetSize1)
        self.myResultTableView:reloadData()
        if self.bFistDraw == false then
            local offsetSize2 = self.myResultTableView:getContentSize()
            if #self.recordList > 0  then  
                if offsetSize1.height > 400 then
                    self.myResultTableView:setContentOffset(ccp(0, offsetSize1.height - offsetSize2.height)) 
                end               
                               
            end
        else
            self.myResultTableView:setScrollToBegin(false)
            self.bFistDraw = false
        end
        
        return
    end

    local  myResultTableView =  TFTableView:create()
    myResultTableView:setTableViewSize(self.panel_list:getContentSize())
    myResultTableView:setDirection(TFTableView.TFSCROLLVERTICAL)
    myResultTableView:setVerticalFillOrder(TFTableView.TFTabViewFILLTOPDOWN)
    myResultTableView:setPosition(self.panel_list:getPosition())
    self.myResultTableView = myResultTableView
    self.myResultTableView.logic = self

    myResultTableView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, self.cellSizeForTable)
    myResultTableView:addMEListener(TFTABLEVIEW_SIZEATINDEX, self.tableCellAtIndex)
    myResultTableView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, self.numberOfCellsInTableView)
    myResultTableView:reloadData()

    self.panel_list:getParent():addChild(self.myResultTableView,1)
    self.bFistDraw = false
end

function TreasureMain.numberOfCellsInTableView(table)
    local self = table.logic

    return #self.recordList + 1
end

function TreasureMain.cellSizeForTable(table,idx)
    local self = table.logic

    local totalCount = #self.recordList

    local height , width =   0, 318
    local index = idx + 1

    local totalCount = #self.recordList

    if index  == (totalCount + 1) then
        height = 50
    else
        local rewardData = self.recordList[index]
        local countOfReward = #rewardData.rewardList

        local number =math.floor(countOfReward / 5)
        local mod = math.fmod(countOfReward,5)

        if mod == 0 then
            number = number - 1
        end    
        height = number * 59 + 110
    end     
    return height , width
end

function TreasureMain.tableCellAtIndex(table, idx)
    local self = table.logic
    local cell = table:dequeueCell()
    local node = nil
    if nil == cell then
        table.cells = table.cells or {}
        cell = TFTableViewCell:create()
        table.cells[cell] = true
        node = createUIByLuaNew("lua.uiconfig_mango_new.treasure.HistoryCell");

        cell:addChild(node)
    end

    cell.index = idx + 1
    self:drawResultNode(cell, idx + 1)
    return cell
end

function TreasureMain:drawResultNode(cell, index)

    local totalCount = #self.recordList
    local panel_cells = {}
    for i=1,6 do
        local panel_cell = TFDirector:getChildByPath(cell,"panel_cell"..i)  
        table.insert(panel_cells,panel_cell)
    end
    local panel_cell9 = TFDirector:getChildByPath(cell,"panel_cell9")  
    --最后显示加载更多
    if index  == (totalCount + 1) then
        local node = panel_cell9
        node:setVisible(true)

        for k,v in pairs(panel_cells) do
            v:setVisible(false)
        end

        local btn_more = TFDirector:getChildByPath(node, 'btn_more')

        btn_more:addMEListener(TFWIDGET_CLICK, audioClickfun(
            function ( )
                self:loadMore()
            end
        ),1)

        if btn_more then
            if self.curBtnIndex == 1 then
                btn_more:setTextureNormal("ui_new/zadan/btn_ckgd.png")
            else
                btn_more:setTextureNormal("ui_new/zadan/btn_ckzx.png")
            end
        end
        return
    end
    panel_cell9:setVisible(false)

  
    local rewardData = self.recordList[index]
    local countOfReward = #rewardData.rewardList

    local row =  math.floor( countOfReward / 5 )
    local mod = math.fmod(countOfReward,5 )
    if mod == 0 then
        row = row - 1
    end 

    row = row + 1
    local node = panel_cells[row]
    for k,v in pairs(panel_cells) do
        if k == row then
            v:setVisible(true)
        else
            v:setVisible(false)
        end
    end

    local txt_time = TFDirector:getChildByPath(node, 'txt_time')
    --print("positiony-----"..txt_time:getPosition().y)
    local txt_name = TFDirector:getChildByPath(node, 'txt_name')
    local positionY = txt_time:getPosition().y

    txt_name:setText(rewardData.playerName)

    local timestamp = math.floor(rewardData.createTime/1000)
    local date   = os.date("*t", timestamp)
    local timeDesc = date.year.."-"..date.month.."-"..date.day
    local timeDesc = string.format("%s", timeDesc)
    local timeDesc2 = os.date("%X", timestamp)
    txt_time:setText(timeDesc2)
    
    for i=200,231 do
        local x = node:getChildByTag(i)
        if x then
            x:removeFromParentAndCleanup(true)
        end
    end
    for i=1,countOfReward do
        self:ShowRoleIcon(node, i, rewardData.rewardList , positionY)
    end
  
    --txt_name:setVisible(true)
    if self.curBtnIndex == 1 then
       --txt_name:setVisible(false)
    end
end

function TreasureMain:ShowRoleIcon(node, itemIndex, configList,positiony)
    self.itemIndex = itemIndex
    local Gapx = 65
    local Gapy = 70
    local row = 1   

    local posX = 75 + math.mod(itemIndex-1,5) * 59  
    if configList then
        row =  math.floor( itemIndex / 5)
        local mod = math.fmod(itemIndex,5 )
        if mod == 0 then
            row = row - 1
        end
        posY =  positiony - (row + 1) * 59 
        posY = posY - 12 
    end    

    local item = configList[itemIndex]
    local roleTypeId = item.resId
    local newCardRoleData = nil
    local path = nil
    if item.resType == EnumDropType.ROLE then
        newCardRoleData = RoleData:objectByID(roleTypeId)
        if newCardRoleData == nil then
          --  print('roleTypeId = ', roleTypeId)
        end
        path = newCardRoleData:getIconPath()
    else
        local data = {}
        data.type   = item.resType
        data.itemId = item.resId
        data.number = item.number

        newCardRoleData = BaseDataManager:getReward(data)
        path = newCardRoleData.path
    end

    if newCardRoleData ~= nil then
        local roleQualityImg = TFImage:create()
        roleQualityImg:setTexture(GetColorIconByQuality(newCardRoleData.quality))
        --roleQualityImg:setAnchorPoint(ccp(1, 0))
        roleQualityImg:setPosition(ccp(posX, posY))
        roleQualityImg:setScale(0.44)
        roleQualityImg:setOpacity(255)
        roleQualityImg:setTag(200 + itemIndex)
        node:addChild(roleQualityImg,100)

        local roleIcon = TFImage:create()
        roleQualityImg:addChild(roleIcon)
        roleIcon:setTexture(path)
        roleIcon:setTouchEnabled(true)
        roleIcon:addMEListener(TFWIDGET_CLICK,
        audioClickfun(function()
            Public:ShowItemTipLayer(roleTypeId, item.resType)
        end))

        if item.resType == EnumDropType.GOODS then
            newCardRoleData = ItemData:objectByID(roleTypeId)          
            newCardRoleData.itemid = newCardRoleData.id
            if newCardRoleData.type == EnumGameItemType.Soul and newCardRoleData.kind ~= 3 then
                Public:addPieceImg(roleIcon,newCardRoleData,true)
            elseif newCardRoleData.type == EnumGameItemType.Piece then
                Public:addPieceImg(roleIcon,newCardRoleData,true)
            else
                Public:addPieceImg(roleIcon,newCardRoleData,false)
            end
        end
        local txt_num = TFLabelBMFont:create()
        txt_num:setFntFile("font/num_212.fnt")

        txt_num:setAnchorPoint(ccp(1, 0))
        txt_num:setPosition(ccp(52, -60))
        txt_num:setText(item.number)
        -- txt_num:setFontSize(20)
        roleQualityImg:addChild(txt_num)
    end
end

function TreasureMain:loadMore()
    --------tag
    local nowCount = #self.recordList
    print("nowCount--------------"..nowCount)
    --1个人历史2玩家历史
    if self.curBtnIndex == 2 then
        self.recordList ={}    
        self.bFistDraw = true
    end  
    TreasureManager:requestRecord(nowCount, 2, self.curBtnIndex)
end

    --寻宝之后刷新历史
function TreasureMain:refreshHistoryByMe()

        if self.curBtnIndex == 1 then
            TreasureManager.recordList[self.curBtnIndex] = {}
            self.bFistDraw = true
            TreasureManager:requestRecord(0, 2, self.curBtnIndex)
        end
end


function TreasureMain:showResult()
    TreasureManager:openResultLayer()
end

function TreasureMain:removeUI()
    self.super.removeUI(self)  

    if self.panel_rank then
        self.panel_rank:release()
        self.panel_rank = nil
    end
    if self.panel_rank_2 then
        self.panel_rank_2:release()
        self.panel_rank_2 = nil
    end
end

function TreasureMain:onShow()
    self.super.onShow(self)

    if self.rankLayer_show then
        self.img_di:setPositionX(-228)
    else
        self.img_di:setPositionX(0)
    end

end

function TreasureMain:registerEvents()
    self.super.registerEvents(self)
    
    self.btn_close:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onBtnClose))
    self.btn_baoxiang:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onBtnBox))
    self.btn_baoxiang_get:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onBtnGetBox))
    

    self.btn_shuaxin:addMEListener(TFWIDGET_CLICK, audioClickfun(self.OnclikRefreshRankLayer),1)
    self.btn_jifen:addMEListener(TFWIDGET_CLICK, audioClickfun(self.OnclikOpenRankLayer),1)
    self.btn_jifen.logic = self
    self.btn_baoxiang.logic = self
    self.btn_baoxiang_get.logic = self

    for k,v in pairs(self.btn_treasures) do
        v.logic = self
        v.index = k
        v:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onBtnTreansure))
    end
    
    for k,v in pairs(self.typeButton) do
        v.logic = self
        v.index = k
        v:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onBtnClickType))
    end

    self.receiveRecordResult = function(event)
        local newCount = event.data[1].newcount
        local recordLists = TreasureManager.recordList       
        if self.curBtnIndex == 2 then --玩家历史            
            self.recordList = {}      
            self.recordList = recordLists[2] or {}        
                                
        elseif self.curBtnIndex == 1  and self.bFistDraw == false  then
            --local newCount = #recordLists[1] - #self.recordList 
            if newCount and newCount < 1 then
                 toastMessage("没有更多的寻宝历史了")
            else
                self.recordList = {}
                self.recordList = recordLists[1] or  {}     
            end
        elseif self.curBtnIndex == 1  then --个人历史
            self.recordList = {}
            self.recordList = recordLists[1] or {}     
        end         
        print("size-------------------"..#self.recordList) 
        self:refresRecordUI()
    end
    TFDirector:addMEGlobalListener(TreasureManager.HistoryMessage, self.receiveRecordResult)

    self.onOnceResult = function()
        local data = TreasureManager:getReward()
        print("onOnceResult--------------")
        print(data)
        if data == nil then
            return
        end
        
        local count = #data.rewardList
        if #data.rewardList == 1 then
            local random = data.index or math.random(19)
            if random > 0 and random < 20 then
                if self.currNode then 
                    self.currNode:setVisible(false)            
                    self.currNode = self.highNodes[random]
                    self.currNode:setVisible(true)
                else
                    self.currNode = self.highNodes[random]
                    self.currNode:setVisible(true)
                end
            end
            self.m_currentItemIndex = self.m_targetNumber
            self.m_targetNumber = random     
            self:runHighAction()
        else
            self:playAnim(data.rewardList)
        end 

        self.count =  self.count + count
        self:refresUI()
    end
    TFDirector:addMEGlobalListener(TreasureManager.RewardMessageOnce,self.onOnceResult)

    self.onBoxResult = function(event)
        print("onOnceResult------------")
        print(event)
        self.round = event.data[1].round
        self.boxIndex = event.data[1].boxIndex
        self:refresUI()
    end
    TFDirector:addMEGlobalListener(TreasureManager.BoxMessage,self.onBoxResult)
    
    self:drawDefault(self.btnIndex)



    self.RefreshRankListCallBack = function(event)
        self:refreshRankList()
    end
    TFDirector:addMEGlobalListener(TreasureManager.Fresh_Rank_Notice, self.RefreshRankListCallBack)


end


function TreasureMain:removeEvents()
    self.super.removeEvents(self)

    TFDirector:removeMEGlobalListener(TreasureManager.RewardMessageOnce,self.onOnceResult)
    TFDirector:removeMEGlobalListener(TreasureManager.HistoryMessage, self.receiveRecordResult)
    TFDirector:removeMEGlobalListener(TreasureManager.BoxMessage,self.onBoxResult)
    
    TFDirector:removeMEGlobalListener(TreasureManager.Fresh_Rank_Notice, self.RefreshRankListCallBack)
    self.RefreshRankListCallBack = nil

end


function TreasureMain:dispose()
    self.super.dispose(self)

    if self.end_timerID then
        TFDirector:removeTimer(self.end_timerID)
        self.end_timerID = nil
    end

     if self.updateTimerID then
        TFDirector:removeTimer(self.updateTimerID)
        self.updateTimerID = nil
    end
end


function TreasureMain.OnclikRefreshRankLayer(sender)
    TreasureManager:refreshRankList()
end

function TreasureMain.OnclikOpenRankLayer(sender)
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


function TreasureMain:refreshRankList()
    if self.tableView == nil then
        local  tableView =  TFTableView:create()
        tableView:setTableViewSize(self.panel_gun:getContentSize())
        tableView:setDirection(TFTableView.TFSCROLLVERTICAL)
        tableView:setVerticalFillOrder(TFTableView.TFTabViewFILLTOPDOWN)


        tableView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, TreasureMain.rank_cellSizeForTable)
        tableView:addMEListener(TFTABLEVIEW_SIZEATINDEX, TreasureMain.rank_tableCellAtIndex)
        tableView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, TreasureMain.rank_numberOfCellsInTableView)
        self.tableView = tableView
        self.tableView.logic = self
        self.panel_gun:addChild(tableView)
    end
    self.tableView:reloadData()

    local txt_paiming = TFDirector:getChildByPath(self.img_di, 'txt_paiming')
    local rank_txt = TFDirector:getChildByPath(txt_paiming, 'txt_num')
    local txt_jifen = TFDirector:getChildByPath(self.img_di, 'txt_jifen')
    local txt_score = TFDirector:getChildByPath(txt_jifen, 'txt_num')
    if TreasureManager.myRank.rank > 0 and TreasureManager.myRank.rank <= 50 then
        rank_txt:setText(TreasureManager.myRank.rank)
    else
        --rank_txt:setText("未入榜")
        rank_txt:setText(localizable.shalu_info_txt1)
    end
    txt_score:setText(TreasureManager.myRank.score)
end


function TreasureMain.rank_cellSizeForTable(table,idx)
    local self = table.logic
    if self.isCrossServer then
        return 80,190
    else
        return 60,190
    end
    return 60,190
end


function TreasureMain.rank_tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    local self = table.logic
    if nil == cell then
        cell = TFTableViewCell:create()
        local panel_rank = nil
        if self.isCrossServer then
            panel_rank = self.panel_rank:clone()
        else
            panel_rank = self.panel_rank_2:clone()
        end
        panel_rank:setVisible(true)
        panel_rank:setPosition(ccp(0,0))
        cell:addChild(panel_rank)
        cell.panel_rank = panel_rank
    end
    local rankInfo = TreasureManager.rankList:getObjectAt(idx+1)
    if rankInfo then
        self:loadRankInfo( rankInfo , cell.panel_rank )
    else
        cell.panel_rank:setVisible(false)
    end
    return cell
end

function TreasureMain:loadRankInfo( rankInfo , panel )
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

function TreasureMain.rank_numberOfCellsInTableView(table)
    return TreasureManager.rankList:length()
end
return TreasureMain