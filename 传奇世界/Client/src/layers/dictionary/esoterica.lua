--[[ 小助手 ]]--
local esoterica = class("esoterica", require ("src/TabViewLayer") )

function esoterica:ctor( parent ,num)
  -- local bg = createBgSprite(self,game.getStrByKey("title_strong"))
  -- self.bg = bg
  self.parent = parent
  --底部提示条
  -- createSprite(self,"res/common/bg/bg55-1.png",cc.p(578,533),nil,50)
  createSprite(self,"res/common/bg/bg55-2.png",cc.p(578,75),nil,100)
  local config = { "title_strong" , "title_lvup" , "title_gold" ,  "title_zhenqi"  , "title_gift" }
  local left_titles = {}
  for k,v in pairs(config)do
    left_titles[k] = game.getStrByKey(v)
  end
  self.title_select_idx = (num and num+1 ) or 1
  local page = num or 0
  self.list_data = {}
  local callback = function(idx)
    self.title_select_idx = idx
    self:getTableView():reloadData()
  end
  local btnGroup = {def = "res/component/button/58.png",sel = "res/component/button/58_sel.png"}
  require("src/LeftSelectNode").new(self,left_titles,cc.size(200,465),cc.p(85,70),callback,btnGroup,true,page)

  self:setData()
  self:createTableView(self , cc.size( 602 , 457 ),cc.p( 278 , 73 ) , true , true)
  self:getTableView():setLocalZOrder(125)
end

function esoterica:numberOfCellsInTableView(table)
   return tablenums( self.aide_data[self.title_select_idx])
end

function esoterica:tableCellTouched(table,cell)
end

function esoterica:setData()
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
  G_CONTROL:controlDataFilter( data , "ru" )
  self.aide_data = data
end

function esoterica:cellSizeForTable(table,idx) 
    return 105 , 600
end

function esoterica:tableCellAtIndex( table , idx )
  local cell = table:dequeueCell()
  local index = idx + 1 
  local curData = self.aide_data[self.title_select_idx][index]
  if cell == nil  then
    cell = cc.TableViewCell:new()
  else
    cell:removeAllChildren()
  end
  
  local line = createSprite( cell , "res/common/table/cell23.png" , cc.p( 4 , 3 ) , cc.p( 0 , 0 ) )
  --line:setScaleX( 0.8 )
  createLabel( cell , curData.shuo , cc.p( 20 , 77 ) , cc.p( 0 , 0 ) , 20 , nil , nil , nil , MColor.brown_gray , nil , nil)
  createLabel( cell , curData.ms , cc.p( 20 , 45 ) , cc.p( 0 , 0 ) , 20 , nil , nil , nil , MColor.deep_brown )
  createLabel( cell , game.getStrByKey( "recommend" ) , cc.p( 20 , 16 ) , cc.p( 0 , 0 ) , 20 , nil , nil , nil , MColor.deep_brown)
  local group = cc.Node:create()
  setNodeAttr( group ,  cc.p( 90 , -5 ) , cc.p( 0 , 0.5 ) )
  cell:addChild( group )
  for i = 1 , 5 do
    if i <= curData.xing then
      createSprite( group , "res/group/star/s4.png" , cc.p( i * 40-5 , 15 ) , cc.p( 0 , 0 ) )
    else
      createSprite( group , "res/group/star/s3.png" , cc.p( i * 40-5 , 15 ) , cc.p( 0 , 0 ) )
    end
  end
  local menuitem = createMenuItem( cell , "res/component/button/39.png" , cc.p( 520 , 55 ) , function()
      local isOpen = true
      if curData.Value then
        _,isOpen = __GotoTarget( {ru = curData.ru,Value = tonumber(curData.Value) } )
      else
        if curData.ru == "a1" then
          local lv = getConfigItemByKey("NewFunctionCfg","q_ID",NF_TASK_DAILY,"q_level")
          if lv then
            if lv > MRoleStruct:getAttr(ROLE_LEVEL) then
              TIPS({str = string.format(game.getStrByKey("func_unavailable_lv"),lv), type = 1})
              return
            end
          end
        end
        _,isOpen = __GotoTarget( {ru = curData.ru} )
      end
      if self.parent and isOpen then
        removeFromParent(self.parent:getParent():getParent()) 
      end
 end )
  createLabel( menuitem , game.getStrByKey("getinto")  , cc.p( menuitem:getContentSize().width/2 , menuitem:getContentSize().height/2 ) , cc.p( 0.5 , 0.5 ) , 25 , true , nil , nil , MColor.yellow_gray , nil , nil , MColor.black , 3 )

  return cell
end

return esoterica