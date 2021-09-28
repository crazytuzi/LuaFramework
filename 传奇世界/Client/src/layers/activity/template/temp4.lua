local weekList = class("weekList",require("src/TabViewLayer"))

function weekList:ctor(chooseTemp)
    self.spCfg = {"boxUnable1","boxUnable1","unpassed_box1","boxCan1"}
    --self.spCfg = { "wood" , "wood"  , "silver" ,  "gold" }
    self.leftTabTemp = nil
    self.menuBtn = {}
    local stext = {}
    self.Mprop = require "src/layers/bag/prop"
    self.data = nil
    self.btnCfg = { game.getStrByKey("lottery_getOne") , game.getStrByKey("lotteryEX_no") , game.getStrByKey("getOver") }
    local boxTabData = nil
    self.firstSend = true
    self.openboxNum = 0
    local timer,timer1,lab,lab1 
    -- local closeBtn = function()
    --     removeFromParent(self)
    -- end

    -- local colorbg = cc.LayerColor:create(cc.c4b(0, 0, 0, 175))
    -- self:addChild(colorbg)

    -- local bg = createSprite(self,"res/common/bg/bg59.png",g_scrCenter)
    -- local bgsize = bg:getContentSize()
    -- createLabel(bg,game.getStrByKey("week_list"),cc.p(bgsize.width/2,bgsize.height-72),cc.p(0.5,0.5),26,true,nil,nil,MColor.name_yellow)
    -- createTouchItem(bg,"res/component/button/X.png",cc.p(bgsize.width-70,bgsize.height-72),closeBtn)
    local bg = self
    local bgsize = DATA_Activity.riteLayer.bg:getContentSize()
    -- self.bar = createBar( {
    --     bg = "res/component/progress/active1.png" ,
    --     front = {path = "res/component/progress/active2.png", offX = 2,offY = 0} ,
    --     parent = bg,
    --     pos = cc.p(120,430) ,
    --     anchor = cc.p(0,0.5) ,
    --     percentage = 0,
    -- })
    -- local barSize = self.bar:getContentSize()
    self.bar = createLoadingBar(true,{
            parent = bg,
            size = cc.size(700,18),
            percentage = 0,
            pos = cc.p(180,451),
            res = "res/component/progress/yellowBar.png",
            dir  = true, --向右
            anchor = cc.p(0,0.5),
        })
    local barSize = cc.size(700,18)

    local fun = function(i)
        local closeBtn1 = function()
            removeFromParent(self.smallbg)
            self.smallbg = nil
        end
        if self.smallbg then
            removeFromParent(self.smallbg)
            self.smallbg = nil
        end
        self.smallbg = createSprite(bg,"res/common/5.png",cc.p(bgsize.width/2,bgsize.height/2),nil,100)
        createLabel(self.smallbg,game.getStrByKey("week_boxgift"),cc.p(206,262),nil,22,true,nil,nil,MColor.lable_yellow)
        registerOutsideCloseFunc(self.smallbg,closeBtn1,true)
        createTouchItem(self.smallbg,"res/component/button/X.png",cc.p(386,262),closeBtn1)
        if boxTabData then
            for k,v in pairs(boxTabData) do
                local num = math.abs(v["index"])
                if num == i then
                    self.openboxNum = num
                    local iconGroup = __createAwardGroup( v["box"] ,nil,nil,nil,false )
                    setNodeAttr( iconGroup , cc.p( 193-#v["box"]*50 , 165 ) , cc.p( 0 , 0.5 ) )
                    self.smallbg:addChild( iconGroup )
                    self.in_menuitem = createMenuItem(self.smallbg,"res/component/button/2.png" ,cc.p( 206 , 50 ) , function() self:call(v["index"] ,v["awards"] ) end  )
                    createLabel( self.in_menuitem , self.btnCfg[ math.floor(v["status"]) + 1 ]  ,getCenterPos( self.in_menuitem ) , cc.p( 0.5 , 0.5 ) , 22 , true , nil , nil , MColor.yellow_gray , 3 , nil , MColor.black , 3 )
                    self.in_menuitem:setEnabled( v["status"] == 0  )
                    break
                end
            end
        end
    end
    local skillball = createSprite(self.bar,"res/layers/battle/score_bg.png",cc.p(-40,2))
	createLabel(skillball,game.getStrByKey("week_score"),cc.p(50,17),nil,16,true,nil,nil,MColor.lable_yellow)
    for i=1,#self.spCfg do
        self.menuBtn[i] = createSprite(self.bar,"res/fb/defense/"..self.spCfg[i]..".png",cc.p(barSize.width*i/4-10,22),nil,nil,0.8)
        self.menuBtn[i]:setVisible(false)
        local listenner = cc.EventListenerTouchOneByOne:create()
        listenner:setSwallowTouches(false)
        listenner:registerScriptHandler(function(touch,event)
            local pt = touch:getLocation()      
            pt = self.menuBtn[i]:getParent():convertToNodeSpace(pt)
            if cc.rectContainsPoint(self.menuBtn[i]:getBoundingBox(),pt) then
                self.menuBtn[i]:runAction(cc.ScaleTo:create(0.05,1,1))  
                return true
            end
        end,cc.Handler.EVENT_TOUCH_BEGAN)
        listenner:registerScriptHandler(function(touch, event)
            self.menuBtn[i]:runAction(cc.Sequence:create(cc.ScaleTo:create(0.05,0.8,0.8)))
            AudioEnginer.playTouchPointEffect()
            local pt = touch:getLocation()
            pt = self.menuBtn[i]:getParent():convertToNodeSpace(pt)
            if cc.rectContainsPoint(self.menuBtn[i]:getBoundingBox(),pt) then
                fun(i) 
            end
        end,cc.Handler.EVENT_TOUCH_ENDED )

        listenner:registerScriptHandler(function(touch, event)
            self.menuBtn[i]:runAction(cc.Sequence:create(cc.ScaleTo:create(0.05,0.8,0.8)))
            AudioEnginer.playTouchPointEffect()
            local pt = touch:getLocation()
            pt = self.menuBtn[i]:getParent():convertToNodeSpace(pt)
            if cc.rectContainsPoint(self.menuBtn[i]:getBoundingBox(),pt) then
                fun(i) 
            end
        end,cc.Handler.EVENT_TOUCH_CANCELLED )
        local eventDispatcher = self.menuBtn[i]:getParent():getEventDispatcher()
        eventDispatcher:addEventListenerWithSceneGraphPriority(listenner,self.menuBtn[i]:getParent())        
    end
    self.haveAwards = {false,false,false,false,false,false,false}
    chooseTemp = chooseTemp or 0
    self.title_select_idx = chooseTemp+1    
    self.createLayout = function()
        self.data = {}
        self.data = DATA_Activity.CData["netData"]

        for k,v in pairs(self.data.list) do
            if math.floor(v["status"]) == 1 then
                local link = getConfigItemByKey("SevenFestivalDB","q_id",v["index"],"q_link")
                if not link then
                    v["status"] = 1.5 
                end
            end
        end
        table.sort( self.data.list , function( a , b )
                local _bool = false
                if a["status"] < b["status"] then
                    _bool = true
                elseif a["status"] == b["status"] then
                    if a["index"] < b["index"] then
                        _bool = true
                    end
                end
                return _bool
        end )
        if self["getTableView"] then
            self:getTableView():reloadData()
            if DATA_Activity:getTempOffPos() then   
              self:getTableView():setContentOffset( DATA_Activity:getTempOffPos() )
              DATA_Activity:setTempOffPos( nil ) 
            end
        end
        
    end

    local callback = function(idx)
        self.title_select_idx = idx
        DATA_Activity:readData(self.createLayout,self.title_select_idx)
    end
    local dayTab = {}
    local day = 7
    for i = 1 , day do
        table.insert(dayTab,game.getStrByKey("week_login"..i))
    end

    g_msgHandlerInst:registerMsgHandler(ACTIVITY_SC_SEVEN_FESTIVAL, function(buf)
        local t = g_msgHandlerInst:convertBufferToTable("ActivitySevenFestivalInfo", buf)
        local point = t.point
        local total = t.totalPoint
        local countdown = t.countdown
        local countdown2 = t.countdown2
        local day = t.day        
        local boxStatus = {}
        local boxTab = {}
        local dayTemp = 0
        self.haveAwards = {t.redDot1,t.redDot2,t.redDot3,t.redDot4,t.redDot5,t.redDot6,t.redDot7}
        for k,v in pairs(t.info) do
            boxTab[k] = {["index"] = v.index,["point"] = v.point,["status"] = math.floor(v.status)}
            for i,j in pairs(v.reward) do
                local boxTab1 = {}
                boxTab1[i] = {}
                boxTab1[i]["id"] = j.itemID            --奖励ID
                boxTab1[i]["num"] = j.count           --奖励个数
                boxTab1[i]["showBind"] = true;
                boxTab1[i]["isBind"] = j.bind       --绑定(1绑定0不绑定)
                boxTab1[i]["streng"] = j.strength        --强化等级
                boxTab1[i]["time"] = j.timeLimit          --限时时间

                boxTab[k]["box"] = boxTab1
            end
            local num = math.abs(boxTab[k]["index"])
            if self.firstSend then
                createScale9Sprite(self.bar,"res/common/scalable/4.png",cc.p(barSize.width*(boxTab[k]["point"])/total-2,-41),cc.size(40,20))
                stext[num] = createLabel(self.bar,tostring(boxTab[k]["point"]),cc.p(barSize.width*(boxTab[k]["point"])/total-2,-41),nil,20,true,nil,nil,MColor.white)
                self.menuBtn[num]:setPosition(cc.p(barSize.width*(boxTab[k]["point"])/total-10,22))
                self.menuBtn[num]:setVisible(true)
            end
            boxStatus[num] = {}
            boxStatus[num][1] = (boxTab[k]["status"] == 2)
            boxStatus[num][2] = (boxTab[k]["status"] == 0)
            if self.openboxNum == num and self.smallbg and self.in_menuitem and not self.firstSend then                
                local text = tolua.cast(self.in_menuitem:getChildByTag(3), "cc.Label")
                if text then
                    text:setString(self.btnCfg[ math.floor(v["status"]) + 1 ])
                end
                -- self.in_menuitem:setEnabled( v["status"] == 0  )
                local beGray = function()
                    self.in_menuitem:setEnabled( v["status"] == 0  )
                end
                performWithDelay(self,beGray,0.1)
            end
        end        
        boxTabData = boxTab
        if self.firstSend then
            createScale9Sprite(bg,"res/common/scalable/16.png",cc.p(508,508),cc.size(864,26))
            lab = createLabel(bg,"",cc.p(100,508),cc.p(0,0.5),18,true,10,nil,MColor.yellow)
            lab1 = createLabel(bg,"",cc.p(510,508),cc.p(0,0.5),18,true,10,nil,MColor.yellow)
            local timeChange = function(time)
                -- local dates = os.date("*t",time)
                if time <= 0 then
                    time = 0
                end
                local dates = {}
                dates.day = math.floor(time/(24*3600))
                dayTemp = dates.day
                dates.hour = math.floor(time%(24*3600)/3600)
                dates.min = math.floor(time%(24*3600)%3600/60)
                dates.sec = time%(24*3600)%3600%60
                lab:setString(game.getStrByKey("week_acover")..string.format(game.getStrByKey("week_downTime"),dates.day,dates.hour,dates.min,dates.sec))--                    
            end
            local timeChange1 = function(time)
                if time <= 0 then
                    time = 0
                    removeFromParent(self)
                    DATA_Activity.riteLayer:changePage(2,true)
                    return 
                end
                local dates = {}
                dates.day = math.floor(time/(24*3600))
                dates.hour = math.floor(time%(24*3600)/3600)
                dates.min = math.floor(time%(24*3600)%3600/60)
                dates.sec = time%(24*3600)%3600%60
                lab1:setString(game.getStrByKey("week_getover")..string.format(game.getStrByKey("week_downTime"),dates.day,dates.hour,dates.min,dates.sec))--                
            end
            timeChange(countdown)
            timeChange1(countdown2)
            local timeShow = function(detime)
                if countdown <= 0 then
                    if timer then
                        timer:stopAllActions()
                    end
                    return
                end
                countdown = countdown - detime
                timeChange(countdown)
            end
            local timeShow1 = function(detime)
                if countdown2 <= 0 then
                    if timer1 then
                        timer1:stopAllActions()
                    end
                    return
                end
                countdown2 = countdown2 - detime
                timeChange1(countdown2)
            end
            timer = startTimerActionEx(self, 1, true, timeShow)
            timer1 = startTimerActionEx(self, 1, true, timeShow1)

            createLabel(skillball,tostring(point),cc.p(48,59),nil,30,true,nil,nil,MColor.white)
            local btnGroup = {def = "res/component/button/40.png" ,sel = "res/component/button/40_sel.png"}            
            chooseTemp = 6 - dayTemp
            self.title_select_idx = chooseTemp + 1
            DATA_Activity:readData(self.createLayout,self.title_select_idx)
            self.tabViewNode = require("src/LeftSelectNode_ex").new(self,dayTab,cc.size(180,322),cc.p(63,43),callback,btnGroup,true,chooseTemp,nil,day,game.getStrByKey("week_noactime"))            
        end
        -- if self then
        --     self:progress(100*point/total,boxStatus)
        -- end

        if self.tabViewNode then
            self:progress(100*point/total,boxStatus)
            self.tabViewNode:getTableView():reloadData()
            if chooseTemp then
                if chooseTemp > 4 and self.firstSend then 
                    self.tabViewNode:getTableView():setContentOffset(cc.p(0,0))                    
                end
            end
            if self.leftTabTemp then               
                self.tabViewNode:getTableView():setContentOffset( self.leftTabTemp )
                self.leftTabTemp = nil
            end
        end
        self.firstSend = false
    end)

    self:createTableView(bg,cc.size(708,320),cc.p(245,43),true)        
    DATA_Activity:readData(self.createLayout,self.title_select_idx)    



    -- registerOutsideCloseFunc( bg , closeBtn)
    -- SwallowTouches(self)
    
end

function weekList:progress(bar,params)
    if bar then
        self.bar:setPercent(bar)
    end
    if params then
        local effCfg = {"copper","copper","silver","gold"}
        --local effCfg = { "sevenprize" , "sevenprize" , "sevenprize" ,  "sevenprize" }
        for i=1,#params do
            if params[i][1] then
                -- self.menuBtn[i]:setTexture("res/layers/activity/box/"..self.spCfg[i].."_o.png")
                self.menuBtn[i]:setTexture("res/fb/defense/"..self.spCfg[i].."_cmp.png")
                self.menuBtn[i]:setScale(0.8)
            else
                -- self.menuBtn[i]:setTexture("res/layers/activity/box/"..self.spCfg[i].."_c.png")
                self.menuBtn[i]:setTexture("res/fb/defense/"..self.spCfg[i]..".png")
                self.menuBtn[i]:setScale(0.8)
            end
            if params[i][2] then
                if not self.menuBtn[i]:getChildByTag(1) then
                    local eff = Effects:create(false)
                    eff:playActionData( effCfg[i] , 10 , 2 , -1 )
                    eff:setPosition(cc.p(48,59))
                    eff:setScale(0.8)
                    self.menuBtn[i]:addChild( eff,1,1 ) 
                    addEffectWithMode(eff,1)            
                end
            else
                if self.menuBtn[i]:getChildByTag(1) then
                    local eff = tolua.cast(self.menuBtn[i]:getChildByTag(1),"Effects")
                    removeFromParent(eff)
                    eff = nil
                end
            end
        end        
    end
end

function weekList:cellSizeForTable(table,idx)
    return 126,708
end

function weekList:numberOfCellsInTableView(table)
    local count = 0
    if self.data then
        count = #self.data.list
    end
    return count
end

function weekList:tableCellTouched(table,cell)

end


function weekList:call(num , awards )
    if self.tabViewNode then
        self.leftTabTemp = self.tabViewNode:getTableView():getContentOffset()        
    end
    DATA_Activity:setTempOffPos( self:getTableView():getContentOffset() ) 
    DATA_Activity:getAward( { idx = num , awards = awards } )
end

function weekList:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    if nil == cell then
        cell = cc.TableViewCell:new()
    else 
        cell:removeAllChildren()
    end
    createSprite(cell,"res/common/table/cell34.jpg",cc.p(356,64))
    if self.data then
        local str = self.data.list--
        local keys = {}
        for k, v in pairs(str) do
            keys[#keys + 1] = v
        end        
        local iconGroup = __createAwardGroup( keys[idx+1 ]["awards"] ,nil,nil,nil,false )
        setNodeAttr( iconGroup , cc.p( 5 , 60 ) , cc.p( 0 , 0.5 ) )
        cell:addChild( iconGroup )
        local weekData = getConfigItemByKey("SevenFestivalDB","q_id",keys[idx+1]["index"])
        createLabel(cell,game.getStrByKey("week_condition"),cc.p(190,80),cc.p(0,0.5),20,true,nil,nil,MColor.lable_yellow)
        createLabel(cell,game.getStrByKey("week_cur"),cc.p(190,40),cc.p(0,0.5),20,true,nil,nil,MColor.lable_yellow)
        createLabel(cell,weekData.q_typechn,cc.p(300,80),cc.p(0,0.5),20,true,nil,nil,MColor.lable_yellow)

        local pro = keys[idx+1]["prog"]
        if pro > weekData.q_num then
            pro = weekData.q_num
        end
        local c = MColor.red
        if pro == weekData.q_num then
            c = MColor.green
        end
        createLabel(cell,pro.."/"..tostring(weekData.q_num),cc.p(300,40),cc.p(0,0.5),20,true,nil,nil,c)
        if math.floor(keys[idx+1].status ) == 1 then
            if weekData.q_link then                
                    local isOpen = false
                    local word
                    local menuitem = createMenuItem(cell,"res/component/button/2.png" ,cc.p( 615 , 60 ) , function()
                                        if weekData.q_level and MRoleStruct:getAttr(ROLE_LEVEL) < weekData.q_level then
                                            TIPS({type = 1,str = string.format(game.getStrByKey("func_unavailable_lv"),weekData.q_level)})
                                        else
                                            if weekData.Value then
                                                __GotoTarget( {ru = tostring(weekData.q_link),Value = tonumber(weekData.Value) } )
                                                isOpen = true
                                            else
                                                word,isOpen = __GotoTarget( {ru = tostring(weekData.q_link)} )
                                            end
                                            if isOpen then
                                                removeFromParent(self)
                                                if DATA_Activity.riteLayer then
                                                    removeFromParent(DATA_Activity.riteLayer)
                                                end
                                            end
                                        end
                                      end  )
                    createLabel( menuitem , game.getStrByKey("week_go") ,getCenterPos( menuitem ) , cc.p( 0.5 , 0.5 ) , 22 , true , nil , nil , MColor.yellow_gray , nil , nil , MColor.black , 3 )                
            else
                createSprite(cell,"res/component/flag/17.png",cc.p( 615 , 60 ))
            end
        elseif keys[idx+1].status == 2 then
            createSprite(cell,"res/component/flag/18.png",cc.p( 615 , 60 ))
        else
            local menuitem = createMenuItem(cell,"res/component/button/2.png" ,cc.p( 615 , 60 ) , function() self:call(keys[idx+1]["index"] , keys[idx+1 ]["awards"]  ) end  )
            createLabel( menuitem , self.btnCfg[ math.floor(keys[idx+1].status) + 1 ]  ,getCenterPos( menuitem ) , cc.p( 0.5 , 0.5 ) , 22 , true , nil , nil , MColor.yellow_gray , nil , nil , MColor.black , 3 )
            menuitem:setEnabled( keys[idx+1].status == 0  )
            menuitem:setVisible(keys[idx+1].status == 0)
        end
    end
    return cell
end

return weekList