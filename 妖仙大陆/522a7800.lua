local _M = {}
_M.__index = _M

local  Util = require 'Zeus.Logic.Util'
local Helper = require'Zeus.Logic.Helper'
local function node_size(item )
  local ctype = tostring(typeof(item.node))
  if (not item.template.W) and (not item.template.H) then
    if ctype == 'CommonUnity3D.UGUIEditor.UI.HZLabel' then
      local w,h = item.node.PreferredSize.x,item.node.PreferredSize.y       
      item.node.Size2D = UnityEngine.Vector2.New(0,0)
      
      return w,h
    elseif ctype == 'CommonUnity3D.UGUIEditor.UI.HZTextBoxHtml' or 
           ctype == 'CommonUnity3D.UGUIEditor.UI.HZTextBox' then
      
      
      
      local lb_content = item.node.TextComponent     
      
      item.node.Height = lb_content.PreferredSize.y
      return lb_content.PreferredSize.x,lb_content.PreferredSize.y
    else
      return item.node.Size2D.x, item.node.Size2D.y
    end
  else 
    return item.node.Size2D.x, item.node.Size2D.y
  end
end


local function calc_pt(item, pos)
  local w,h = node_size(item)
  local padding_x,padding_y = 0,0
  local off_w,off_h = w,h

  local node_x, node_y = item.node.Position2D.x,item.node.Position2D.y
  if not item.template.X  then
    node_x = pos.x
  else
    off_w = off_w + (node_x-pos.x)
  end
  if not item.template.Y then
    node_y = pos.y
  else
    off_h = off_h + (node_y-pos.y)
  end
  local direction = 'v'

  if item.parent then
    direction = (item.parent.template.direction or 'v')
  end
  if direction == 'h' then
    off_w = off_w + (item.template.padding or 0)
    pos.x = pos.x + off_w
  else
    
    off_h = off_h + (item.template.padding or 0)
    pos.y = pos.y + off_h
  end
  item.node.Position2D = UnityEngine.Vector2.New(node_x,node_y)
  return off_w,off_h
end

local function SetData(con)
  local name = tostring(typeof(con.node))
  local data = con.template.data

  if type(data) ~= 'table' then
    if name == 'CommonUnity3D.UGUIEditor.UI.HZLabel' then
      con.template.Text = data
    elseif name == 'CommonUnity3D.UGUIEditor.UI.HZTextBoxHtml' then
      con.template.XmlText = data
    elseif name == 'CommonUnity3D.UGUIEditor.UI.HZTextBox' then
      con.template.XmlText = data  
    elseif name == 'CommonUnity3D.UGUIEditor.UI.HZImageBox' then
      con.template.Img = data
    elseif name == 'ItemShow' then
      con.template.IconID = data
    end
  else
    for k,v in pairs(data) do
      
      con.template[k] = v
    end
  end
end

local function isArray( t )
  local count = 0
  for _,__ in pairs(t) do
    count = count + 1
  end
  return (count == #t)
end

local function tryParse(con,k,v)
  if k == 'FontSize' then
    con.node.FontSize = v
  elseif k == 'Color' then
    con.node.FontColorRGBA = v
  
  
  elseif k == 'SupportRichtext' then
    con.node.SupportRichtext = v
  elseif k == 'TextAnchor' then

    con.node.EditTextAnchor = v
  elseif k == 'W' then
    con.node.Size2D = UnityEngine.Vector2.New(v, con.node.Size2D.y)
  elseif k == 'H' then
    con.node.Size2D = UnityEngine.Vector2.New(con.node.Size2D.x,v)
  elseif k == 'Img' then
    
    local style = con.template.UIStyle or nil
    local clipSize = con.template.ClipSize or 8
    if not style and (con.template.W or con.template.H) then
      style = LayoutStyle.IMAGE_STYLE_BACK_4
    end

    Util.HZSetImage(con.node, v, false, style, clipSize)
    local s = con.node.Layout.PreferredSize
    local w = con.template.W or s.x
    local h = con.template.H or s.y
    con.node.Size2D = Vector2.New(w,h)

  elseif k == 'HtmlText' then
    con.node.HtmlText = v
  elseif k == 'ContentW' then
    
    con.node.Size2D = UnityEngine.Vector2.New(v, con.node.Size2D.y)
  elseif k == 'padding' then
    
  elseif k == 'direction' then
    
  elseif k == 'id' then
    
  elseif k == 'sub_id' then
    
  elseif k == 'data' then
  elseif k == 'UIStyle' then
  elseif k == 'ClipSize' then
  elseif type(v) ~= 'function' then
    
    con.node[k] = v
  end
end










local function CreateCavas(name)
  local node = HZCanvas.New()
  node.Name = name
  node.Enable = false
  return node
end

local function recursion(template,data)
  local num = 1
  local con = {}
  local pos = {x=0,y=0}
  local local_data
  local is_array = false
  if template.id then
    local_data = data[template.id]
    if not local_data then
      num = 0
    elseif type(local_data) == 'table' and isArray(local_data) then
      
      num = #local_data
      is_array = true
    end
  elseif template.sub_id then
    local_data = data[template.sub_id]
  end

  for i=1,num do 
    
    local node = nil
    local nextCon = {}
    local maxw,maxh,totalw,totalh = 0,0,0,0
    local looptemplate
    local loopdata 
    if is_array then
      looptemplate = Helper.copy_table(template)
      loopdata = local_data[i]
    else 
      looptemplate = template
      loopdata = local_data
    end

    if type(looptemplate[1]) == 'function' then
      node = template[1]()
      
      node.Name = template.id or template.sub_id or '-'
      looptemplate.data = loopdata
      local class_str = tostring(typeof(node))
      if class_str == 'CommonUnity3D.UGUIEditor.UI.HZLabel' then
        node.EditTextAnchor = TextAnchor.L_T
      
      
      
      end
      
    else  
      node = CreateCavas(template.id or template.sub_id or '-')
      
    end

    nextCon.node = node
    nextCon.template = looptemplate
    if local_data then 
      SetData(nextCon)
    end
    local nodepos = {x=0,y=0}
    
    local count = 0
    Helper.each_t(function(map) 
      count = count + 1
      if map.key~= 'data' and type(map.val) == 'table' then
        local nextdata

        if map.val.sub_id and (not map.val.id) and (not map.val.data) then
          
          nextdata = loopdata
        else
          nextdata = data
        end
        local childcon = recursion(map.val,nextdata)
        Helper.each_t(function(map)
          map.val.parent = nextCon
          node:AddChild(map.val.node)
          local off_w,off_h = calc_pt(map.val,nodepos)
          maxw = (maxw > off_w and maxw) or off_w
          maxh = (maxh > off_h and maxh) or off_h
          totalw = totalw + off_w
          totalh = totalh + off_h
        end,childcon)
      else
        tryParse(nextCon,map.key,map.val)
      end
    end,nextCon.template)
    if tostring(typeof(node)) == 'CommonUnity3D.UGUIEditor.UI.HZCanvas' then
      
      local nodew, nodeh = maxw,maxh
      if template.direction == nil or template.direction == 'v' then
        nodew,nodeh = maxw,totalh
      else
        nodew,nodeh = totalw,maxh
      end
      node.Size2D = UnityEngine.Vector2(nodew,nodeh)
      
    end
    
    table.insert(con,nextCon)
  end
  return con
end


local function create_template(template,data)
  local localT = Helper.copy_table(template)
  local com =  recursion(localT,data)
  if #com == 1 then
    return com[1]
  else
    return nil
  end
end

_M.create_template = create_template
return _M
