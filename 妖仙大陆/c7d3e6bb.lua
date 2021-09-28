local _M = {}
_M.__index = _M


local Util                  = require "Zeus.Logic.Util"

local ChatModel             = require 'Zeus.Model.Chat'
local ChatUtil              = require "Zeus.UI.Chat.ChatUtil"

local self = {
	menu = nil,
}

local rows = 3

local function OnClickBegin(displayNode)
    
    self.menu:Close()
end

local function InitItemUI(ui, node)
    
    local UIName = {
        "tbh_lately",
        "cvs_latelybg",
    }

    for i = 1, #UIName do
        ui[UIName[i]] = node:FindChildByEditName(UIName[i], true)
    end
end

local function RefreshItem(x, y, node)
    local index = x * rows + y + 1
    local ui = {}
    if index > #self.m_Items then
        node.Visible = false
        return
    end
    node.Visible = true

    local data = self.m_Items[index]
    node.UserTag = index
    InitItemUI(ui, node)

    local mask = ui.cvs_latelybg.UnityObject:AddComponent(typeof(UnityEngine.UI.Mask))
    mask.showMaskGraphic = false

    local strcommon = ""
    if data.common ~= "" then
        strcommon = data.common
    else
        strcommon = data.content
    end
    local texta = ChatUtil.HandleChatClientDecode(strcommon, 0xf3ac50ff)
    ui.tbh_lately.TextComponent.RichTextLayer:SetString(texta)

    ui.tbh_lately.Y = (node.Height - ui.tbh_lately.TextComponent.RichTextLayer.ContentHeight)/2
end

local function InitItem(node)
    node.TouchClick = function( ... )
        
        local index = node.UserTag
        local data = self.m_Items[index]
        local strcommon = ""
        if data.common ~= "" then
            strcommon = data.common
        else
            strcommon = data.content
        end
        if self.callBack ~= nil then
            self.callBack(strcommon, function( ... )
                
                
            end)
        else
            
        end
    end
end

local function InitListInfo()
    local col = 1
    if self.m_Items == nil then
        self.m_Items = {}
    else
        col = math.ceil(#self.m_Items/rows)
    end

    self.sp_latelylist:Initialize(self.cvs_lately.Width, self.cvs_lately.Height,  rows, col, self.cvs_lately, 
        LuaUIBinding.HZScrollPanUpdateHandler(RefreshItem), 
        LuaUIBinding.HZTrusteeshipChildInit(InitItem))
end



local function OnEnter()
    
    self.m_Items =  ChatModel.mCommonItems[self.default]
    InitListInfo()
end

function _M.AddToChatExtend(self,chat_tab_list,channel)
    chat_tab_list.RemoveAllChildren()
    chat_tab_list.cvs_extend2:AddChild(chat_tab_list.ChatUICommonListMenu)
    self.default = channel

    OnEnter()


end

local  function OnExit()
    
end

function _M.Exit()
   OnExit()
end

local function InitUI()
    
    local UIName = {
        "btn_close",
        "sp_latelylist",
        "cvs_lately",
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
    

    self.btn_close.TouchClick = OnClickBegin
    self.cvs_lately.Visible = false
    
    self.menu:SubscribOnEnter(OnEnter)
    self.menu:SubscribOnExit(OnExit)
    self.menu:SubscribOnDestory(function()
        self = nil
    end)
end

local function Init(tag,params)
	
	self.menu = LuaMenuU.Create("xmds_ui/chat/chat_lately.gui.xml", GlobalHooks.UITAG.GameUIChatCommonList)
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
