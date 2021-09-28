

local Helper    = require 'Zeus.Logic.Helper'
local Util      = require 'Zeus.Logic.Util'
local ItemModel = require 'Zeus.Model.Item'
local _M = {}
_M.__index = _M
local filter 

local CLOCK_ID = 1
local function Close(self)
  if not self.current then
    return
  end
  self.current = nil
  self.menu:Close()  
end


local Text = {
  
}

local function OnEnter(self)
  
end

local function OnExit(self)
  
   
     local rolebag = DataMgr.Instance.UserData.RoleBag                                                        
    local iter = rolebag.AllData:GetEnumerator()                                  
    local isred = false                               
    while iter:MoveNext() do                                  
        local data = iter.Current.Value
        local it = GlobalHooks.DB.Find("Items", data.TemplateId)
        if data.Type == ItemData.TYPE_CHEST or (it.RedPoint and it.RedPoint == 1) then
           isred=true                                                                                 
        end                                           
    end                               
          
    EventManager.Fire("Event.Hud.red", {value=isred})
end

local function OnDestory(self)
  
end


local function Add(self,it,static_data)
  self.queue = self.queue or {}
  local get_num = it.Num - it.LastNum
  table.insert(self.queue,{clock_id = CLOCK_ID, num = get_num,id = it.Id,static = static_data})
  CLOCK_ID = CLOCK_ID + 1
end



local function Dequeue(self)
  local info = self.queue and self.queue[1]
  
  if not info then 
    Close(self)
    return 
  end

  local it = ItemModel.GetItemById(info.id)
  if not it then
    Close(self)
    return 
  end
  
  table.remove(self.queue,1)
  self.current = info
  local itshow = Util.ShowItemShow(self.cvs_icon,info.static.Icon,info.static.Qcolor,info.num)
  Util.NormalItemShowTouchClick(itshow,info.static.Code)
  self.lb_name.Text = info.static.Name
  self.lb_name.FontColorRGBA = Util.GetQualityColorRGBA(info.static.Qcolor)
  self.lb_tips.Text = info.static.ApplyTips
  local current_id = info.clock_id
  self.btn_one.TouchClick = function (sender)
    ItemModel.UseItemRequest(it.Index, 1, function (items)
      if items then
        EventManager.Fire('Event.OnShowNewItems',{items=items})
      end
      if self.current and current_id == self.current.clock_id then
        Dequeue(self)
      end
    end)
  end
  self.btn_all.TouchClick = function (sender)
    local it = ItemModel.GetItemById(info.id)
    ItemModel.UseItemRequest(it.Index, info.num, function (items)
      if items then
        EventManager.Fire('Event.OnShowNewItems',{items=items})
      end
      if self.current and current_id == self.current.clock_id then
        Dequeue(self)
      end
    end)
  end 
end

local function Remove(self,id)
  for i,v in ipairs(self.queue) do
    if v.id == id then
      table.remove(self.queue,i)
      break
    end
  end
  if self.current.id == id then
    Dequeue(self)
  end
end

local function Set(self,it,static_data)
	Add(self,it,static_data)
  Dequeue(self)
end

local ui_names = 
{
  {name = 'btn_one'},
  {name = 'btn_all'},
  {name = 'btn_close',click = function (self)
    Dequeue(self)
  end},
  {name = 'lb_get'},
  {name = 'lb_name'},
  {name = 'lb_tips'},
  {name = 'cvs_get'},
  {name = 'cvs_tips'},
  {name = 'cvs_icon'},
  {name = 'ib_light'},
}


local function InitComponent(self,tag)
  
  self.menu = LuaMenuU.Create('xmds_ui/common/common_item.gui.xml',tag)
  Util.CreateHZUICompsTable(self.menu,ui_names,self)
  self.menu.ShowType = UIShowType.Cover
  self.menu.Enable = false
  self.menu:SubscribOnExit(function ()
    OnExit(self)
  end)
  self.menu:SubscribOnEnter(function ()
    OnEnter(self)
  end)
  self.menu:SubscribOnDestory(function ()
    OnDestory(self)
  end)
end



local function Create(tag)
  local ret = {}
  setmetatable(ret, _M)
  InitComponent(ret,tag)
  return ret
end

local function OnCreateUseNowMenu(it, static_data)
  local menu,obj = GlobalHooks.FindUI(GlobalHooks.UITAG.GameUIItemUseNow)
  if menu then
    Add(obj,it,static_data)
  else
	  menu,obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIItemUseNow,-1)
	  Set(obj,it,static_data)
  end
end

local function initial()
  filter = ItemPack.FilterInfo.New()
  filter.CheckHandle = function (it)
    local static_data = ItemModel.GetItemStaticDataByCode(it.TemplateId)
	if static_data == nil then
		print("--------------------------------------------")
		print("GameUIItemUseNow filter.CheckHandle static_data == nil it.TemplateId = "..it.TemplateId)
	end
    return static_data ~= nil and static_data.IsApplyNow == 1 
  end

  filter.NofityCB = function (pack, status, index)
  	if status == ItemPack.NotiFyStatus.ADDITEM 
  	 or status == ItemPack.NotiFyStatus.UPDATEITEM then

  		local it = filter:GetItemDataAt(index)
      
      local isred = false
      local itemdata = GlobalHooks.DB.Find("Items", it.TemplateId)
      if it.Type == ItemData.TYPE_CHEST or (itemdata.RedPoint and itemdata.RedPoint == 1) then
         isred = true
      end 
      EventManager.Fire("Event.Hud.red", {value=isred})           


  		local get_num = it.Num - it.LastNum
  		if get_num > 0 then		
	  		local static_data = ItemModel.GetItemStaticDataByCode(it.TemplateId)
        local lv = DataMgr.Instance.UserData:TryToGetIntAttribute(UserData.NotiFyStatus.LEVEL, 0)
	  		if it and static_data.IsApplyNow == 1 and lv >= static_data.LevelReq then  			
	  			OnCreateUseNowMenu(it, static_data)
	  		end
	  	end
    elseif status == ItemPack.NotiFyStatus.RMITEM then
      
      local it = filter:GetItemDataAt(index)
      local rg = DataMgr.Instance.UserData.RoleBag
      local menu,obj = GlobalHooks.FindUI(GlobalHooks.UITAG.GameUIItemUseNow)
      
      if menu then
        Remove(obj,it.Id)
      end
  	end
  end
  DataMgr.Instance.UserData.RoleBag:AddFilter(filter)
end

local function fin()
	if filter then
		DataMgr.Instance.UserData.RoleBag:RemoveFilter(filter)
		filter = nil
	end
end

_M.fin = fin
_M.Create = Create
_M.Close  = Close
_M.initial = initial
return _M
