



local _M = {}
_M.__index = _M

local function CreateRowNode(self)
  local node = UICanvas.New()
  node.Bounds = Rectangle2D.New(self.pan.Bounds.width,
                  self.cellNode.Bounds.height+2*self.vspace)
  local x
  local offet
  if not self.offetX then
    x = self.startx or 1
    offet = GameUtil.GetWeltGridOffset(node.Bounds.width,self.cellNode.Bounds.width,x,self.column)
  else
    offet = self.offetX
    
    local totalw = self.column * (self.cellNode.Bounds.width + offet) - offet
    x = (self.startx or 1) + (self.pan.Bounds.width - totalw) * 0.5
  end

  self.children = self.children or {}

  for i=1,self.column do
    local clone = self.cellNode:Clone()
    clone.X = x
    clone.Y = self.vspace
    node:AddChild(clone)
    table.insert(self.children, clone)
    x = x + offet + clone.Bounds.width
  end
  return node
end


function _M:CreateHorizList(pan,cellNode,column,startx,vspace)
	self.cells = {}
  cellNode.Visible = false
  self.pan = pan
  self.column = column
  self.vspace = vspace or 0
  self.startx = startx or 1
  self.cellNode = cellNode
  pan.OnChildEnterBounds = LuaUIBinding.LuaScrollPanAddChildHandler(function(gx,gy)
    local node
    if #self.cells > 0 then 
      node = self.cells[1]
      table.remove(self.cells,1)
    else
      node = CreateRowNode(self)
    end
    for i=1,self.column do
      local childNode = node:GetChildAt(i-1)
      local d = gy * self.column + i
      local ret = false
      if self.eachFunc and d <= self.num then
        local check = self.eachFunc(d,childNode)
        if check == nil then
          error('eachFunc must return bool value')
        else
          ret = check
        end
      end
      childNode.Visible = ret
    end
    node.Visible = true
    return node    
  end)
  pan.OnChildExitBounds = LuaUIBinding.LuaScrollPanRemoveChildHandler(function(gx,gy,obj) 
    table.insert(self.cells,obj)
     for i=1,column do
       local childNode = obj:GetChildAt(i-1)
     end
    obj.Visible = false
  end)

end

function _M:UpdateList(num,eachFunc)
  local row = math.floor(num / self.column)
  if num % self.column ~= 0 then
    row = row + 1
  end
  
  self.cells = {}
  print('UpdateList ================== ',row)
  self.eachFunc = eachFunc or self.eachFunc
  if self.num then
    self.num = num
    self.pan:SetRows(row,true)
  else
    self.num = num
    self.pan:Initialize(self.pan.Bounds.width,self.cellNode.Bounds.height+self.vspace,row,1)
  end

end

function _M:Clear()
  for _,v in ipairs(self.cells) do
    v:Dispose()
  end
end

local function New()
  local ret = {}
  setmetatable(ret,_M)
  return ret
end
return {New = New}
