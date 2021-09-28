-- 上交指定物品集齐送礼
local M = class( "temp91" , require("src/TabViewLayer") )
function M:ctor( params )
    self.data = {};

    createSprite( self , "res/layers/activity/bg7.jpg" , cc.p( 0 , 0 ) , cc.p( 0 , 0 ) )

    self:createTableView( self , cc.size(692, 296), cc.p(4, 2) , true )

    local function createLayout()
        self.data = DATA_Activity.CData["netData"]
        if self.data then
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

    local function getFun(  )
        DATA_Activity:setTempOffPos( self:getTableView():getContentOffset() ) 
        DATA_Activity:getAward( { idx = curData.index , awards = curData["awards"] } )
    end
    local btnCfg = { game.getStrByKey("exchange") , game.getStrByKey("lotteryEX_no") , game.getStrByKey("already") .. game.getStrByKey("exchange") }
    local menuitem = createMenuItem(cell,"res/component/button/2.png" ,cc.p( 600 , size.height/2 ) , getFun  )
    createLabel( menuitem , btnCfg[ curData.state + 1 ]  ,getCenterPos( menuitem ) , cc.p( 0.5 , 0.5 ) , 22 , nil , nil , nil , MColor.lable_yellow , nil , nil , MColor.black , 3 )
    menuitem:setEnabled( curData.state == 0  )
    
    -- 碎片物品
    local iconGroup = __createAwardGroup( curData["needs"], nil, 90)
    cell:addChild( iconGroup )

    local arrowSpr = createSprite(cell , "res/group/arrows/20.png" , cc.p( 300 , size.height/2 ) , cc.p( 0 , 0.5 ))

    -- 兑换物品
    local exchangeIconGroup = __createAwardGroup( curData["rewards"], nil, 90)
    cell:addChild( exchangeIconGroup )

    -- 图标左对齐
    local fragmentWidth = #(curData["needs"]) * 90;
    local exchangeWdith = #(curData["rewards"]) * 90;

    setNodeAttr( iconGroup , cc.p( 0 , size.height/2 ) , cc.p( 0 , 0.5 ) )
    arrowSpr:setPosition(cc.p(fragmentWidth + 20, size.height/2));
    setNodeAttr( exchangeIconGroup , cc.p( fragmentWidth + 20 + 45, size.height/2 ) , cc.p( 0 , 0.5 ) )

    return cell
end

function M:numberOfCellsInTableView( table )
  return self.data.list and tablenums( self.data.list ) or 0
end




return M