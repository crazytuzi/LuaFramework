--[[在线礼包 ]]--
local temp2 = class( "temp2" , require("src/TabViewLayer") )

function temp2:ctor( params )
    self.data = {}
    self.showTimeIndex = 1
    self.btnCfg = { game.getStrByKey("lottery_getOne") , game.getStrByKey("lotteryEX_no") , game.getStrByKey("getOver") }

    createSprite(self,"res/layers/activity/bg/bg9.png",cc.p( 8 ,307 ) , cc.p( 0 , 0 ) )
    self:createTableView(self,cc.size(918,280),cc.p( 0 , 25 ),true)
    self:getTableView():setBounceable(true)
    self:getTableView():setClippingToBounds(true)

    self.createLayout = function()
        self.data = DATA_Activity.CData["netData"]
        if self.data then
            self.data.list = self.data.list or {}
            local num = tablenums( self.data.list )
            for i=1, num do
                local curData = self.data.list[i]
                if curData.sec > 0 then
                    self.showTimeIndex = i
                    break
                end
            end

            if self["getTableView"] then
                self:getTableView():reloadData()
                if DATA_Activity:getTempOffPos() then
                    self:getTableView():setContentOffset( DATA_Activity:getTempOffPos() )
                    DATA_Activity:setTempOffPos( nil ) 
                end
            end
            
        end

    end

    DATA_Activity:readData( self.createLayout )

end


function temp2:cellSizeForTable(table,idx) 
    return 110 , 680
end

function temp2:tableCellAtIndex(tableView,idx)
    local cell = tableView:dequeueCell()
    local str = ""
    if cell == nil then
        cell = cc.TableViewCell:new()
    else
        cell:removeAllChildren()
    end
    
    local function getTimeStr(time)
        return string.format("%02d", (math.floor(time/60/60)%60)) .. ":" .. string.format("%02d", (math.floor(time/60)%60)) .. ":" .. string.format("%02d", math.floor(time%60)) 
    end

    local idex = idx + 1
    local bg = createSprite(cell , "res/common/table/cell16.png" , cc.p( 4 + 8 , 0 ) , cc.p( 0 , 0 ))
    bg:setScaleX( 0.97 )
    createLabel(cell, string.format(game.getStrByKey("online_award"), self.data.list[idex ]["time"] ) ,cc.p(40,60),cc.p(0,0.5),22,true,nil,nil,MColor.lable_yellow)
    local curData = self.data.list[idex ]
    if curData.sec > 0 and self.showTimeIndex == idex then
        createLabel(bg, game.getStrByKey("online_award1"), cc.p(38, 30), cc.p(0, 0.5), 22, true):setColor(MColor.lable_yellow)
        local timeLab = createLabel(bg, " " .. getTimeStr(curData.sec), cc.p(135, 30), cc.p(0, 0.5), 22, true)
        timeLab:setColor(MColor.white)
        cell.time =  startTimerAction(cell, 1, true, function()
            if curData.sec > 0 then
                curData.sec = curData.sec - 1
                timeLab:setString(" " .. getTimeStr(curData.sec))                         
            else
                local func = function()
                    DATA_Activity:setTempOffPos( self:getTableView():getContentOffset() ) 
                    DATA_Activity:readData(self.createLayout())
                end
                DATA_Activity:readData(func)
                startTimerAction(cell, 1, false, func)
                timeLab:setString("")
                if cell.time then
                    cell:stopAction(cell.time)
                end
                cell.time = nil                    
            end
        end)
    end
    local function getFun()
        DATA_Activity:getAward( { idx = self.data.list[idex].index , awards = self.data.list[idex ]["awards"] }  )
    end
    local menuitem = createMenuItem(cell,"res/component/button/39.png" ,cc.p( 630 , bg:getContentSize().height/2 ) , getFun  )
    createLabel( menuitem , self.btnCfg[ self.data.list[idex].state + 1 ]  ,getCenterPos( menuitem ) , cc.p( 0.5 , 0.5 ) , 22 , true , nil , nil , MColor.yellow_gray , nil , nil , MColor.black , 3 )
    menuitem:setEnabled( self.data.list[idex].state == 0  )

    local iconGroup = __createAwardGroup( self.data.list[idex ]["awards"] )
    setNodeAttr( iconGroup , cc.p( 250 , 58 ) , cc.p( 0 , 0.5 ) )
    cell:addChild( iconGroup )

    return cell
end


function temp2:numberOfCellsInTableView( table )
    return ( self.data and self.data.list ) and  tablenums( self.data.list ) or 0 
end

return temp2
