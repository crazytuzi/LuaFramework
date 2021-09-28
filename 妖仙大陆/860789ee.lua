local _M = {}
_M.__index = _M


local Util          = require "Zeus.Logic.Util"

local self = {
    m_Root = nil,

}

local function OnClickBegin(displayNode)
    
    self.menu:Close()
end

local function StrExchangeNode(data)
    
    
    local canvas = HZCanvas.New() 
    local label = HZTextBox.New()
    label.Size2D = Vector2.New(self.cvs_bagWidth - 20, 500)
    label.TextComponent.RichTextLayer:SetEnableMultiline(true)
    label.XmlText = "<f size= '20'>" .. data .. "</f>"
    label.X = 10
    label.Y = 5
    canvas:AddChild(label)
    canvas.Height = label.TextComponent.RichTextLayer.ContentHeight + 10
    return canvas
end

function _M.AddExtraNode(node)
	self.cvs_bag:AddChild(node)
	node.Y = self.cvs_bag.Height
	self.cvs_bag.Height = self.cvs_bag.Height + node.Height
	self.content_node = self.cvs_bag
end

function _M.SetXmlStr(str)
    _M.AddExtraNode(StrExchangeNode(str))
end

function _M.SetXmlSingleLineStr(str)
    local label = HZTextBox.New()
    label.Size2D = Vector2.New(1136, 500)
    label.TextComponent.RichTextLayer:SetEnableMultiline(true)
    label.XmlText = "<f size= '20'>" .. str .. "</f>"
    label.X = 10
    label.Y = 5
    self.cvs_bag.Height = label.TextComponent.RichTextLayer.ContentHeight + 10
    self.cvs_bag.Width = label.TextComponent.RichTextLayer.ContentWidth + 10
    self.cvs_bag:AddChild(label)

    self.content_node = self.cvs_bag
end

local function OnEnter()
	self.cvs_bag:RemoveAllChildren(true)
	self.cvs_bag.Height = 0
    self.cvs_bag.Width = self.cvs_bagWidth
end

local function OnExit()

end

local function InitCompnent()
    self.cvs_bag = self.menu:GetComponent('cvs_details')
    self.cvs_bagWidth = self.cvs_bag.Width

    LuaUIBinding.HZPointerEventHandler({node = self.menu, click = OnClickBegin})

	self.m_Root:SubscribOnEnter(OnEnter)
    self.m_Root:SubscribOnExit(OnExit)
    self.m_Root:SubscribOnDestory(function()
        self = nil
    end)
end

local function Init(tag,params)
    self.m_Root = LuaMenuU.Create("xmds_ui/tips/tips_details.gui.xml", GlobalHooks.UITAG.GameUIShowXmlTips)
    
    self.menu = self.m_Root
    InitCompnent()
    return self.m_Root
end

local function Create(tag,params)
    self = {}
    setmetatable(self, _M)
    local node = Init(tag, params)
    return self
end

return {Create = Create}
