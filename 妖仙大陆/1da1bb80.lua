local _M = {}
_M.__index = _M

local Util                  = require "Zeus.Logic.Util"
local ChatUtil              = require "Zeus.UI.Chat.ChatUtil"
local ItemModel             = require 'Zeus.Model.Item'
local ExchangeUtil          = require "Zeus.UI.ExchangeUtil"

local self = {
	menu = nil,
}

local columns = 1

local function OnCloseMenu(displayNode)
	
	if self ~= nil and self.menu ~= nil then
        if self.closeEvent then
            self.closeEvent()
        end
        self.menu:Close()
	end
end

local function InitItemUI(ui, node)
    
    local UIName = {
        "cvs_pc",
        "lb_name",
        "lb_condition",
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
    ui.lb_name.Text = data.FunDes
    ui.lb_condition.Text = data.Tips
    Util.HZSetImage(ui.cvs_pc, "static_n/functions/" .. data.FunIcon .. ".png", false,LayoutStyle.IMAGE_STYLE_BACK_4)
end

local function InitItem(node)
    local btn_go = node:FindChildByEditName("btn_go", true)
    LuaUIBinding.HZPointerEventHandler({node = btn_go, click = function (displayNode, pos)
        local index = node.UserTag
        local data = self.m_Items[index]
        EventManager.Fire('Event.Goto',{id = data.FunID, param = self.menu.ExtParam})
        self.menu:Close()
    end} )
end

local function InitListInfo(WaysID)
    local array = split(WaysID, ",")
    self.m_Items = {}
    for i = 1, #array do
        local search_t = {FunID = array[i]}
        local Items = GlobalHooks.DB.Find('Functions',search_t)
        if Items ~= nil then
            table.insert(self.m_Items, Items[1])
        end
    end
    
    local rows = 1
    if self.m_Items == nil then
        self.m_Items = {}
    else
        rows = math.ceil(#self.m_Items/columns)
    end

    self.sp_see:Initialize(self.cvs_channel.Width, self.cvs_channel.Height,  rows, columns, self.cvs_channel, 
        LuaUIBinding.HZScrollPanUpdateHandler(RefreshItem), 
        LuaUIBinding.HZTrusteeshipChildInit(InitItem))
end

local function InitUI(ui, node)
	local UIName = {
        "btn_close",
        "btn_back",
        "ib_mask",
        "sp_see",
        "cvs_channel",
        "tbh_name",
        "tbh_effect",
        "cvs_icon"
    }

    for i = 1, #UIName do
        ui[UIName[i]] = node:FindChildByEditName(UIName[i], true)
    end
end

local function OnExit()
    OnCloseMenu()
    
end

local function InitOwnInfo(detail)
    
    local item = Util.ShowItemShow(self.cvs_icon, detail.Icon,detail.Qcolor)
    self.tbh_effect.UnityRichText = detail.Desc
    self.tbh_name.XmlText = ExchangeUtil.GetItemName(detail.Name, detail.Qcolor, 24)
end

local function OnEnter()
    
    local code = self.menu.ExtParam
    local ele = GlobalHooks.DB.Find('Items',code)
    
    if ele then
        InitOwnInfo(ele)
        InitListInfo(ele.WaysID)
    end
end


local function InitCompnent(params)

    self.menu.mRoot.IsInteractive = true
    self.menu.mRoot.Enable = true
    self.menu.mRoot.EnableChildren = true
    LuaUIBinding.HZPointerEventHandler({node = self.menu.mRoot, click = OnCloseMenu})

	InitUI(self, self.menu)

    self.btn_close.TouchClick = OnCloseMenu
    self.btn_back.TouchClick = OnCloseMenu
    self.cvs_channel.Visible = false

    
    

	self.menu:SubscribOnEnter(OnEnter)
	self.menu:SubscribOnExit(OnExit)
	self.menu:SubscribOnDestory(function()
        self = nil
    end)
end

local function Init(params)
	
	self.menu = LuaMenuU.Create("xmds_ui/pet/pet_getway.gui.xml", GlobalHooks.UITAG.GameUIItemGetDetail)
	
	InitCompnent(params)
	return self.menu
end

local function Create(params)
	self = {}
	setmetatable(self, _M)
	local node = Init(params)
	return self
end


local function initial()
	
end

return {Create = Create, initial = initial}
