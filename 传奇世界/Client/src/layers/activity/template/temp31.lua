-- 购买资源打折
local M = class( "temp31" , require("src/TabViewLayer") )

local Mcurrency = require "src/functional/currency";

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

    createLabel( cell , curData.groupName, cc.p( 10 , size.height-32 ) , cc.p( 0 , 0 ) , 20 , nil , nil , nil , MColor.lable_yellow )

    
    -- 原价
    local currencyIconCfgs = {
        -- 元宝
        [1] = "3.png",
        -- 绑定元宝
        [2] = "4.png",
        -- 金币
        [3] = "1.png",
    }

    local oldPriceNode = Mnode.combineNode(
	{
		nodes = {
			Mnode.createLabel(
			{
				src = game.getStrByKey("original_price") .. ": ",
				color = MColor.lable_yellow,
				size = 20,
				outline = false,
			}),
			
			Mnode.createSprite(
			{
				src = "res/group/currency/" .. currencyIconCfgs[curData.oldType],
				scale = 0.65,
			}),
			
			Mnode.createLabel(
			{
				src = tostring(curData.oldPrice),
				size = 20,
				color = MColor.lable_yellow,
				outline = false,
			}),
		},
	})
		
	Mnode.addChild(
	{
		parent = cell,
		child = oldPriceNode,
        anchor = cc.p(0, 0),
		pos = cc.p(375, 90),
	})

    local oldPriceSize = oldPriceNode:getContentSize()
			
	Mnode.createColorLayer(
	{
		parent = oldPriceNode,
		src = cc.c4b(236 ,199 ,199, 220),
		cSize = cc.size(oldPriceSize.width, 2),
		anchor = cc.p(0, 0.5),
		pos = cc.p(0, oldPriceSize.height/2),
	})

    -- 现价
    local newPriceNode = Mnode.combineNode(
	{
		nodes = {
			Mnode.createLabel(
			{
				src = game.getStrByKey("new_price") .. ": ",
				color = MColor.white,
				size = 20,
				outline = false,
			}),
			
			Mnode.createSprite(
			{
				src = "res/group/currency/" .. currencyIconCfgs[curData.disType],
				scale = 0.65,
			}),
			
			Mnode.createLabel(
			{
				src = tostring(curData.disPrice),
				size = 20,
				color = MColor.white,
				outline = false,
			}),
		},
	})
		
	Mnode.addChild(
	{
		parent = cell,
		child = newPriceNode,
        anchor = cc.p(0, 0),
		pos = cc.p(525, 90),
	})

    ---------------------------------------------------------------------------------------------------------------

    createLabel( cell , game.getStrByKey("discount") .. ": " .. curData.disDesc, cc.p( 545 , 5 ) , cc.p( 0 , 0 ) , 20 , nil , nil , nil , MColor.lable_yellow )

    local function getFun(  )
        DATA_Activity:setTempOffPos( self:getTableView():getContentOffset() ) 
        DATA_Activity:getAward( { idx = curData.index  , awards = curData["awards"] } )
    end
    -- 0 可购买 1 不可购买 2 已购买
    local btnCfg = { game.getStrByKey("buy") , game.getStrByKey("buy") , game.getStrByKey("havebought") }
    local menuitem = createMenuItem(cell,"res/component/button/2.png" ,cc.p( 600 , 55 ) , getFun  )
    createLabel( menuitem , btnCfg[ curData.state + 1 ]  ,getCenterPos( menuitem ) , cc.p( 0.5 , 0.5 ) , 22 , nil , nil , nil , MColor.lable_yellow , nil , nil , MColor.black , 3 )
    menuitem:setEnabled( curData.state == 0  )

    local iconGroup = __createAwardGroup( curData["awards"], nil, 90)
    setNodeAttr( iconGroup , cc.p( -8 , -17 ) , cc.p( 0 , 0 ) )
    cell:addChild( iconGroup )

    return cell
end

function M:numberOfCellsInTableView( table )
  return self.data.list and tablenums( self.data.list ) or 0
end

return M