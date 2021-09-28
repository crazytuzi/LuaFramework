--[[ 角色等级分段奖励 ]]--
local M = class( "temp156" , require("src/TabViewLayer") )
function M:ctor( params )
    self.data = {}

    createSprite( self , "res/layers/activity/bg7.jpg" , cc.p( 0 , 0 ) , cc.p( 0 , 0 ) )

    self:createTableView( self , cc.size(692, 296), cc.p(4, 2) , true )

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

    createLabel( cell , string.format( game.getStrByKey("level_text") , curData.level ) , cc.p( 20 , size.height/2 ) , cc.p( 0 , 0.5 ) , 24 , nil , nil , nil , MColor.lable_yellow )

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