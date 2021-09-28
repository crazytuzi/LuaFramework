--[[ 小助手 ]]--
local M = class("aideLayer", require ("src/TabViewLayer") )

function M:ctor( params )
  -- local bg = createBgSprite(self,game.getStrByKey("title_strong"))
  -- self.bg = bg
  
  local bg = self
  --底部提示条
  self.leftBtnData = {}--{10,11,12,13,14,15,16,17,18,19}
  
  createSprite(bg, "res/common/bg/buttonBg2.png", cc.p(12, 20), cc.p(0, 0))
  createSprite(bg, "res/common/bg/tableBg2.png", cc.p(208, 20), cc.p(0, 0))

  local config = { "title_strong" , "title_lvup" , "title_gold" ,  "title_zhenqi"  , "title_gift" }
  local left_titles = {}
  for k,v in pairs(config)do
    left_titles[k] = game.getStrByKey(v)
  end
  self.title_select_idx = 1
  self.list_data = {}
  local callback = function(idx)
    self.title_select_idx = idx
    self:getTableView():reloadData()
  end
  require("src/LeftSelectNode").new(bg,left_titles,nil,nil,callback)

  self:setData()
  self:createTableView(bg , cc.size( 750 , 520 ),cc.p( 200 , 30 ) , true )
  self:getTableView():setLocalZOrder(125)
end

function M:numberOfCellsInTableView(table)
   return tablenums( self.aide_data[self.title_select_idx])
end

function M:setData()
  local config = getConfigItemByKey( "Aide" )
  local data = {}
  for key , v in pairs(config ) do
    data[v.lei] = data[v.lei] or {}
    data[v.lei][#data[v.lei]+1] = v
  end

  for key , v in pairs( data ) do
    sortFunc = function( a , b ) return (b.px or 2) > (a.px or 1) end
    table.sort( v , sortFunc )
  end
  self.aide_data = data
end

function M:cellSizeForTable(table,idx) 
    return 117 , 750
end

function M:tableCellAtIndex( table , idx )
  local cell = table:dequeueCell()
  local index = idx + 1 
  local curData = self.aide_data[self.title_select_idx][index]

  if cell == nil  then
    cell = cc.TableViewCell:new()
  else
    cell:removeAllChildren()
  end
  createLabel( cell , curData.shuo , cc.p( 55 , 77 ) , cc.p( 0 , 0 ) , 20 , nil , nil , nil , MColor.yellow , nil , nil)
  createLabel( cell , curData.ms , cc.p( 55 , 45 ) , cc.p( 0 , 0 ) , 20 , nil , nil , nil , MColor.white , nil , nil)
  createLabel( cell , game.getStrByKey( "recommend" ) , cc.p( 55 , 16 ) , cc.p( 0 , 0 ) , 20 , nil , nil , nil , MColor.white , nil , nil)

  local group = cc.Node:create()
  setNodeAttr( group ,  cc.p( 110 , -5 ) , cc.p( 0 , 0.5 ) )
  cell:addChild( group )
  for i = 1 , curData.xing do
      createSprite( group , "res/group/star/1.png" , cc.p( i * 36 , 15 ) , cc.p( 0 , 0 ) )
  end
  local line = createSprite( cell , "res/common/bg/bg-1.png" , cc.p( 378 , 0 ) , cc.p( 0.5 , 0 ) )
  --line:setScaleX( 0.8 )
  local menuitem = createMenuItem( cell , "res/component/button/50.png" , cc.p( 670 , 60 ) , function()__GotoTarget( curData )  end )
  createLabel( menuitem , game.getStrByKey("getinto")  , cc.p( menuitem:getContentSize().width/2 , menuitem:getContentSize().height/2 ) , cc.p( 0.5 , 0.5 ) , 25 , true , nil , nil , MColor.yellow_gray , nil , nil , MColor.black , 3 )

  return cell
end

return M