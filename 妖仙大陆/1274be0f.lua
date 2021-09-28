local _M = {}
_M.__index = _M


local Util                  = require "Zeus.Logic.Util"

local ChatUtil              = require "Zeus.UI.Chat.ChatUtil"

local self = {
	menu = nil,
}

local columns = 1
local function OnClickBegin(displayNode)
    
    self.menu:Close()
end

local function InitItemUI(ui, node)
    
    local UIName = {
        "tb_name",
    }

    for i = 1, #UIName do
        ui[UIName[i]] = node:FindChildByEditName(UIName[i], true)
    end
end

local function RefreshItem(x, y, node)
    local index = y * columns + x + 1
    local ui = {}
    if index > #self.m_Items then
        node.Visible = false
        return
    end
    node.Visible = true
    local data = self.m_Items[index]
    node.UserTag = index
    InitItemUI(ui, node)

    if data.serverData ~= nil then
        local str = "<f><f>Lv." .. data.serverData.s2c_level .. "</f><f color='" .. string.format("%08X",  GameUtil.RGBA_To_ARGB(ChatUtil.PorColor["PorColor" .. data.serverData.s2c_pro])) .. "'>【" .. data.serverData.s2c_name .. "】</f></f>"
        ui.tb_name.XmlText = str
    else
        
        ui.tb_name.XmlText = "<f>" .. data.s2c_name .. string.gsub(Util.GetText(TextConfig.Type.CHAT, 'call_limit'), "|1|", self.lefttimes) .. "</f>"
        if self.lefttimes <= 0 then
            node.Enable = false
        else
            node.Enable = true
        end
    end
    
end

local function InitItem(node)
    node.TouchClick = function( ... )
        
        local index = node.UserTag
        local data = self.m_Items[index]
        if self.callback ~= nil then
            self.callback(data)
            self.menu:Close()
        end
    end
end

local function InitListInfo()
    local rows = 1
    if self.m_Items == nil then
        self.m_Items = {}
    else
        rows = math.ceil(#self.m_Items/columns)
    end

    self.sp_see:Initialize(self.cvs_name.Width, self.cvs_name.Height,  rows, columns, self.cvs_name, 
        LuaUIBinding.HZScrollPanUpdateHandler(RefreshItem), 
        LuaUIBinding.HZTrusteeshipChildInit(InitItem))
    local pos = Vector2.New(0, self.cvs_name.Height * rows)
    self.sp_see.Scrollable:LookAt(pos,false)
end

function _M.SetData(data, cb, lefttimes, pos)
    
    
    
    self.m_Items = data
    self.lefttimes = lefttimes
    self.callback = cb
    InitListInfo()
    self.cvs_frame.Position2D = Vector2.New(0, 0)
    local v1 = self.cvs_frame:GlobalToLocal(pos, true)
    self.cvs_frame.Position2D = Vector2.New(v1.x, v1.y - self.cvs_frame.Height)
end

local function OnEnter()
    
end

local  function OnExit()
    
end

local function InitUI()
    
    local UIName = {
        "cvs_name",
        "sp_see",
        "cvs_frame",
    }

    for i = 1, #UIName do
        self[UIName[i]] = self.menu:GetComponent(UIName[i])
    end
end

local function InitCompnent()
    InitUI()
    LuaUIBinding.HZPointerEventHandler({node = self.menu, click = OnClickBegin})
    self.cvs_name.Visible = false
    
    self.menu:SubscribOnEnter(OnEnter)
    self.menu:SubscribOnExit(OnExit)
    self.menu:SubscribOnDestory(function()
        self = nil
    end)
end

local function Init(tag,params)
	
    local index = tonumber(params)
    if index then
        self.default = index
    end
	self.menu = LuaMenuU.Create("xmds_ui/chat/chat_private.gui.xml", GlobalHooks.UITAG.GameUIChatPersonList)
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
