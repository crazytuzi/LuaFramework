--[[ 在线时长奖励 ]]--
local M = class( "temp151" , require("src/TabViewLayer") )
function M:ctor( params )
    self.data = {};

    --self.showTimeIndex = 1

    createSprite( self , "res/layers/activity/bg7.jpg" , cc.p( 0 , 0 ) , cc.p( 0 , 0 ) )

    self:createTableView( self , cc.size(692, 296), cc.p(4, 2) , true )

    local function createLayout()
        self.data = DATA_Activity.CData["netData"]
        if self.data then

            --[[
            self.data.list = self.data.list or {}
            local num = tablenums( self.data.list )
            for i=1, num do
                if self.data.onlineTime < self.data.list[i].level then
                    self.showTimeIndex = i;
                    break;
                end
            end
            ]]

            if self["getTableView"] then
                self:getTableView():reloadData()
                if DATA_Activity:getTempOffPos() then
                    self:getTableView():setContentOffset( DATA_Activity:getTempOffPos() )
                    DATA_Activity:setTempOffPos( nil ) 
                end
            end
            
        end
    end

    DATA_Activity:readData(createLayout)

end


function M:cellSizeForTable(table,idx) 
    return 124, 692
end


function M:tableCellAtIndex( table , idx )
    local cell = table:dequeueCell()
    local str = ""
    if cell == nil then
        cell = cc.TableViewCell:new()
    else
        cell:removeAllChildren()
    end
    
    local index = idx + 1
    local curData = self.data.list[index]

    local bg = createSprite(cell , "res/common/table/tiao.png" , cc.p( 0 , 0 ) , cc.p( 0 , 0 ))
    local size = bg:getContentSize()

    createLabel( cell , curData.level/60 .. game.getStrByKey("minute") , cc.p( 10 , size.height/2 ) , cc.p( 0 , 0.5 ) , 20 , nil , nil , nil , MColor.lable_yellow )

    --[[
    local function getTimeStr(time)
        return string.format("%02d", (math.floor(time/60/60)%60)) .. ":" .. string.format("%02d", (math.floor(time/60)%60)) .. ":" .. string.format("%02d", math.floor(time%60)) 
    end

    if self.data.onlineTime < curData.level and self.showTimeIndex == index then
        local timeLab = createLabel(bg, " " .. getTimeStr(curData.level - self.data.onlineTime), cc.p(0, 0), cc.p(0, 0), 20, true)
        timeLab:setColor(MColor.white)
        cell.time = startTimerAction(cell, 1, true, function()
            if self.data.onlineTime < curData.level then
                self.data.onlineTime = self.data.onlineTime + 1
                timeLab:setString(" " .. getTimeStr(curData.level - self.data.onlineTime))                         
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
    ]]

    local function getFun(  )
        DATA_Activity:setTempOffPos( self:getTableView():getContentOffset() ) 
        DATA_Activity:getAward( { idx = curData.level , awards = curData["awards"] } )
    end
    local btnCfg = { game.getStrByKey("lottery_getOne") , game.getStrByKey("lotteryEX_no") , game.getStrByKey("getOver") }
    local menuitem = createMenuItem(cell,"res/component/button/2.png" ,cc.p( 600 , size.height/2 ) , getFun  )
    createLabel( menuitem , btnCfg[ curData.state + 1 ]  ,getCenterPos( menuitem ) , cc.p( 0.5 , 0.5 ) , 22 , nil , nil , nil , MColor.lable_yellow , nil , nil , MColor.black , 3 )
    menuitem:setEnabled( curData.state == 0  )

    

    local iconGroup = __createAwardGroup( curData["awards"], nil, 90)
    setNodeAttr( iconGroup , cc.p( 70 , size.height/2 ) , cc.p( 0 , 0.5 ) )
    cell:addChild( iconGroup )

    return cell
end

function M:numberOfCellsInTableView( table )
  return self.data.list and tablenums( self.data.list ) or 0
end




return M