--[[ 等级礼包 ]]--
local M = class( "temp3" , require("src/TabViewLayer") )
function M:ctor( params )
    self.data = {}

    createSprite( self , "res/layers/activity/bg/bg11.png" , cc.p( 8 ,307 ) , cc.p( 0 , 0 ) )


    self:createTableView( self , cc.size(918,280),cc.p(0,25) , true )

    local function createLayout()
        self.data = DATA_Activity.CData["netData"]
        if self["getTableView"] then
            self:getTableView():reloadData()
            if DATA_Activity:getTempOffPos() then
              self:getTableView():setContentOffset( DATA_Activity:getTempOffPos() )
              DATA_Activity:setTempOffPos( nil ) 
            end
        end
    
    end
    DATA_Activity:readData(createLayout)

end


function M:cellSizeForTable(table,idx) 
    return 110 , 680
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

    local bg = createSprite(cell , "res/common/table/cell16.png" , cc.p( 4 + 8, 0 ) , cc.p( 0 , 0 ))
    bg:setScaleX( 0.97 )
    local size = bg:getContentSize()

    createLabel( cell , string.format( game.getStrByKey("level_text") , curData.level ) , cc.p( 40 , size.height/2 ) , cc.p( 0 , 0.5 ) , 24 , nil , nil , nil , MColor.lable_yellow )

    local function getFun(  )
        DATA_Activity:setTempOffPos( self:getTableView():getContentOffset() ) 
        DATA_Activity:getAward( { idx = curData.level , awards = curData["awards"] }   )
    end
    local btnCfg = { game.getStrByKey("lottery_getOne") , game.getStrByKey("lotteryEX_no") , game.getStrByKey("getOver") }
    local menuitem = createMenuItem(cell,"res/component/button/39.png" ,cc.p( 630 , size.height/2 ) , getFun  )
    createLabel( menuitem , btnCfg[ curData.state + 1 ]  ,getCenterPos( menuitem ) , cc.p( 0.5 , 0.5 ) , 22 , nil , nil , nil , MColor.lable_yellow , nil , nil , MColor.black , 3 )
    menuitem:setEnabled( curData.state == 0  )

    

    local iconGroup = __createAwardGroup( curData["awards"] )
    setNodeAttr( iconGroup , cc.p( 130 , size.height/2 ) , cc.p( 0 , 0.5 ) )
    cell:addChild( iconGroup )

    return cell
end

function M:numberOfCellsInTableView( table )
  return self.data.list and tablenums( self.data.list ) or 0
end




return M