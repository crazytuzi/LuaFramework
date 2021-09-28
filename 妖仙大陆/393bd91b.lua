local Helper = require 'Zeus.Logic.Helper'

GlobalHooks.DB = GlobalHooks.DB or {}


local function init_merge_tables()
  if GlobalHooks.DB.merge then return end
  GlobalHooks.DB.merge = {}
  GlobalHooks.DB.merge_filenames = {}
  local ok, ret = pcall(require, 'Data._merge_')
  if ok then
    for k,v in pairs(ret) do
      GlobalHooks.DB.merge[k] = v
      for _,vv in ipairs(v) do
        local fname = string.split(vv,'.')
        if fname and #fname > 0 then
          GlobalHooks.DB.merge_filenames[fname[#fname]] = vv
        end
      end
    end
  end
end

local function GetDataTable(tb_name)
  if not GlobalHooks.DB.data then
    init_merge_tables()
    GlobalHooks.DB.data = {}
  end
  local tb = GlobalHooks.DB.data[tb_name]
  if not tb then
    local ok, ret = pcall(require, 'Data.'..tb_name)
    if ok then
      tb = ret
      GlobalHooks.DB.data[tb_name] = tb
    else
      local tb_path = GlobalHooks.DB.merge_filenames[tb_name]
      if tb_path then
        ok, ret = pcall(require, 'Data.'..tb_path)
        if ok then
          tb = ret
          GlobalHooks.DB.data[tb_name] = tb
        end
      end
    end
  end
  return tb  
end

function GlobalHooks.ClearCache()
  GlobalHooks.DB.data = nil
end

function GlobalHooks.SetClientConfig(key,value,toserver)
  if key == 'guide_closed' then
    GlobalHooks.Drama.Stop()
  end
  if toserver ~= nil then
    DataMgr.Instance.UserData:SetClientConfig(key,value,toserver)
  else
    DataMgr.Instance.UserData:SetClientConfig(key,value,true)
  end
end






function GlobalHooks.DB.Count(tb_name)
  local tb = GetDataTable(tb_name)
  if type(tb) ~= 'table' then return 0 end
  if tb._key_ then
    local count = 0
    for _,__ in pairs(tb) do
      count = count + 1
    end
    return (count > 0 and count-1) or 0
  else
    return (#tb - 1)
  end
end

local function TryFindMergeTb(tb_name,find_key)
  if not GlobalHooks.DB.merge then return end
  local merge = GlobalHooks.DB.merge[tb_name]
  if merge then
    local all_ret = {}
    local key_ret
    local is_key = type(find_key) ~= 'table'
    for _,v in ipairs(merge) do
      local ret = GlobalHooks.DB.Find(v, find_key)
      if is_key then
        if ret then
          key_ret = ret
          break
        end
      elseif ret and #ret > 0 then
        for _,v in ipairs(ret) do
          table.insert(all_ret,v)
        end
      end
    end
    if is_key then 
      return key_ret
    else
      return all_ret
    end
  end
end

local function GetConfigByName(filename, key)
  
  local ele = unpack(GlobalHooks.DB.Find(filename,{ParamName=key}))
  if not ele then
    return nil
  elseif ele.ParamType == 'NUMBER' then
    return tonumber(ele.ParamValue)
  else
    return ele.ParamValue
  end
end


function GlobalHooks.DB.GetPetGlobalConfig(name)
  return GetConfigByName("PetConfig", name)
end


function GlobalHooks.DB.GetGlobalConfig(name)
  local ele = unpack(GlobalHooks.DB.Find('Parameters',{ParamName=name}))
  if not ele then
    return nil
  elseif ele.ParamType == 'NUMBER' then
    return tonumber(ele.ParamValue)
  else
    return ele.ParamValue
  end
end

function GlobalHooks.DB.GetFullTable(tb_name)
  return GlobalHooks.DB.Find(tb_name,{})
end

function GlobalHooks.DB.FindByDict(tb_name,dict)
  local Util = require 'Zeus.Logic.Util'
  local t = Util.StringObjDict2LuaTable(dict)
  return GlobalHooks.DB.Find(tb_name,t)
end





function GlobalHooks.DB.Find(tb_name, find_key)
  local tb = GetDataTable(tb_name)
  if not tb then 
    return TryFindMergeTb(tb_name, find_key) 
  end

  if not find_key or not (tb._key_ or tb[1]) then return end
  local function get_key(index)
    if tb._key_ then
      return tb._key_[index]
    else
      return tb[1][index]
    end
  end

  local function gen_table(arr)
    local ret = {}
    for i,v in ipairs(arr) do
      ret[get_key(i)] = v
    end
    return ret
  end

  local function check(key,v,t)
    for k,c in pairs(t) do
      if key == k then
        if type(c) == 'function' then
          if not c(v) then return false end
        elseif c ~= v then
          return false
        end
      end
    end
    return true
  end
  
  if type(find_key) == 'table' then
    local ret = {}
    for k,v in pairs(tb) do
      if (tb._key_ and k ~= '_key_') or (not tb._key_ and k > 1) then
        local check_ok = true
        for i,vv in ipairs(v) do   
          local key = get_key(i) 
          if not check(key,vv,find_key) then
            check_ok = false
            break
          end
        end
        if check_ok then
          table.insert(ret,gen_table(v))
        end
      end
    end
    return ret
  elseif type(find_key) == 'function' then
    local ret = {}
    for _,v in pairs(tb) do
      local check_t = gen_table(v)
      if find_key(check_t) then
        table.insert(ret,check_t)
      end
    end
    return ret
  elseif tb[find_key] then
    return gen_table(tb[find_key])
  else 
    return nil
  end

end

function GlobalHooks.DB.PetAutoUseInit()
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
end

local function initial()
end


return {initial = initial}
