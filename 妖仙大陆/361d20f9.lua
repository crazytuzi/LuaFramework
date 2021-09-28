local _M = {}
_M.__index = _M


local Util                  = require "Zeus.Logic.Util"


local self = {
	menu = nil,
}

local columns = 1

local function OnClickBegin(displayNode)
    
    self.menu:Close()
end

local function InitItemUI(ui, node)
    
    local UIName = {
        "tbt_choose",
        "lb_pindao",
        "btn_colour",
        "cvs_setup",
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

    ui.tbt_choose.IsChecked = (data.IsHide == 1)
    ui.lb_pindao.Text = data.Channel
	ui.lb_pindao.FontColorRGBA = GameUtil.CovertHexStringToRGBA(data.FontColor) 
	
    if data.showConfigure == 1 then
        ui.cvs_setup.IsGray = false
        ui.tbt_choose.Enable = true
    else
        ui.cvs_setup.IsGray = true
        ui.tbt_choose.Enable = false
    end
    if data.FontConfigure == 1 then
        ui.btn_colour.Visible = true
    else
        ui.btn_colour.Visible = false
    end
end

local function InitItem(node)
    local btn_colour = node:FindChildByEditName("btn_colour", true)
    btn_colour.TouchClick = function( ... )
        
        local index = node.UserTag
        local data = self.m_Items[index]
        print("---------- data.curColor-----------", data.curColor, index)
        local node, luaobj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIChatSetting2nd, 0)
         self.menu.Alpha = 0
        luaobj.SetInfo(data,function ()
            
            self.menu.Alpha = 1
        end)
    end

    local tbt_choose = node:FindChildByEditName("tbt_choose", true)
    tbt_choose.TouchClick = function( ... )
        
        local index = node.UserTag
        local data = self.m_Items[index]
        if tbt_choose.IsChecked then
            data.IsHide = 1
        else
            data.IsHide = 0
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

    self.sp_see:Initialize(self.cvs_pindao.Width, self.cvs_pindao.Height,  rows, columns, self.cvs_pindao, 
        LuaUIBinding.HZScrollPanUpdateHandler(RefreshItem), 
        LuaUIBinding.HZTrusteeshipChildInit(InitItem))
end

function _M.SetData(data)
    
    self.m_Items = data
    InitListInfo()
end

local function OnEnter()
    
end

local  function OnExit()
    
end

local function InitUI()
    
    local UIName = {
        "sp_see",
        "cvs_pindao",
        "btn_close",
    }

    for i = 1, #UIName do
        self[UIName[i]] = self.menu:GetComponent(UIName[i])
    end
end

local function InitCompnent()
    InitUI()
    self.menu.mRoot.IsInteractive = true
    self.menu.mRoot.Enable = true
    self.menu.mRoot.EnableChildren = true
    LuaUIBinding.HZPointerEventHandler({node = self.menu.mRoot, click = OnClickBegin})
    self.cvs_pindao.Visible = false

    self.btn_close.TouchClick = OnClickBegin
    
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
	self.menu = LuaMenuU.Create("xmds_ui/chat/chat_setup.gui.xml", GlobalHooks.UITAG.GameUIChatSetting1st)
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
