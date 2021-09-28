local _M = {}
_M.__index = _M


local Util                  = require "Zeus.Logic.Util"
local ItemModel = require 'Zeus.Model.Item'
local ChatUIItemShow = require "Zeus.UI.Chat.ChatUIItemShow"
local ChatUtil  = require "Zeus.UI.Chat.ChatUtil"

local self = {
	menu = nil,
}

local function GetItemShowStr(data)
    return ChatUtil.AddItemByData(nil,data)
	
	










	
end

local function OnClickItem(equip)
    if self.faceCb then
        self.faceCb(1, GetItemShowStr(equip.detail))
    end
end

local function InitItem(self,node,equip)
	if equip == nil then
		node.Visible = false	
		return
	end
	node.Visible = true	
	local static_data = ItemModel.GetItemStaticDataByCode(equip.TemplateId)	
	local itshow = Util.ShowItemShow(node,equip.IconId,equip.Quality)
	itshow.EnableTouch = true
	itshow.TouchClick = function (sender)
		OnClickItem(equip)
	end	
	node.Name = equip.Id
end

local function InitSpList()
	local equip_item_pack = DataMgr.Instance.UserData.RoleEquipBag	
	local bag_item_pack = DataMgr.Instance.UserData.RoleBag	
	
	
	
		
	local allItemMap = {}	
	local iter = equip_item_pack.AllData:GetEnumerator()
	while iter:MoveNext() do
		local data = iter.Current.Value
		table.insert(allItemMap, data)
		
	end
	
	local iter = bag_item_pack.AllData:GetEnumerator()
	while iter:MoveNext() do
		local data = iter.Current.Value
		table.insert(allItemMap, data)
	end

	local item_counts = #allItemMap
	self.sp_list.Scrollable:ClearGrid()
	if self.sp_list.Rows <= 0 then
		self.sp_list.Visible = true
		local cs = self.cvs_icon.Size2D
		self.sp_list:Initialize(cs.x + 15 ,cs.y + 15,2,item_counts%2 == 0 and item_counts/2 or item_counts/2 +1,self.cvs_icon,
		function (gx,gy,node)
			local equip = allItemMap[gx*2 + gy+1]
			InitItem(self,node,equip)
		end,
		function ()	end)
	else
		self.sp_list.Rows = item_counts
	end	
end

local function OnEnter()
   InitSpList()
end

function _M.AddToChatExtend(self,chat_tab_list)
	OnEnter()	
	
	chat_tab_list.RemoveAllChildren()
    chat_tab_list.cvs_extend2:AddChild(chat_tab_list.ChatUIShowItemMenu)
    
    OnEnter()
end

local function OnExit()

end

function _M.Exit()
    
   OnExit()
end

local function InitUI()
    
    local UIName = {
        "sp_list",
        "cvs_icon",
        "cvs_list",
    }
	
    for i = 1, #UIName do
        self[UIName[i]] = self.menu:GetComponent(UIName[i])
    end
end

local function InitCompnent()
    InitUI()
	self.cvs_icon.Visible = false
	
end

local function Init(tag,params)
    local index = tonumber(params)
    if index then
        self.default = index
    end
	self.menu = LuaMenuU.Create("xmds_ui/chat/chat_item.gui.xml", GlobalHooks.UITAG.GameUIChatShowItem)
    self.menu.ShowType = UIShowType.Cover
	InitCompnent()
	return self.menu
end

local function Create(tag,params)
	self = {}
    
	setmetatable(self, _M)
	local node = Init(tag, params)
	return self
end

local function initial()
  print("DungeonMain.initial")
end

return {Create = Create, initial = initial}
