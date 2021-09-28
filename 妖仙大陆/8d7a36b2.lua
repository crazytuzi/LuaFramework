



local pairs = pairs
local type = type

local _M = {}
_M.__index = _M

local function is_empty(t)
  local break_flag = false
  for name,val in pairs(t) do
    break_flag = true
    break
  end
  return not break_flag
end

local function each(func, t)
  for name,val in pairs(t) do
    func({key=name, val=val})
  end
end

local function eachi(func, t)
  for name,val in ipairs(t) do
    func({key=name, val=val})
  end
end

local function map_t(func, t)
  local rtn = {}
  for name,val in pairs(t) do
    rtn[name] = func({key=name, val=val}) 
  end
  return rtn
end

local function fold_t(func, z, t)
  
  for name,val in pairs(t) do
    z = func(z, {key=name, val=val}) 
  end
  return z
end

local function filter_t(func, t)
  local rtn = {} 
  for name,val in pairs(t) do
    if func({key=name, val=val}) then
      rtn[name] = val
    end
  end
  return rtn
end

local function merge_table(tTarget, tOrigin, isEmptyClean)
  
    
      
        
      
      
    
      
    
  
  assert(tTarget, "merge_table target cant be nil")
  local func = function(z, item)
    if type(item.val) == "table" then
      
      if not z[item.key] then
        z[item.key] = {}
      end
      if isEmptyClean and is_empty(item.val) then
        
        z[item.key] = {}
      else
        merge_table(z[item.key], item.val, isEmptyClean)
      end
    else
      z[item.key] = item.val
      
    end
    return z
  end
  fold_t(func, tTarget, tOrigin)
end

local function rec_print_table(t)
  local func = function (item)
    if type(item.val) == "table" then
      print("in table", item.key)
      rec_print_table(item.val)
    else
      print(item.key, item.val)
    end
  end
  each(func, t)
end

local function copy_table(org)
    local rtn = {}
    local func = function(z, i)
        if type(i.val) == "table" then
            z[i.key] = copy_table(i.val)
        else
            z[i.key] = i.val
        end
        return z
    end
    if org ~= nil then 
      fold_t(func, rtn, org)
    end
    
    return rtn
end

_M.each_t = each
_M.each_i = eachi
_M.map_t = map_t
_M.fold_t = fold_t
_M.filter_t = filter_t
_M.merge_table = merge_table
_M.rec_print_table = rec_print_table
_M.copy_table = copy_table
_M.is_empty = is_empty
return _M
