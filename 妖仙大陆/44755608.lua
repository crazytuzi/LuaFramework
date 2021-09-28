local _M = {}
_M.__index = _M


local Util                  = require "Zeus.Logic.Util"

local self = {
    m_Root = nil,
    pageNum = 4,
}

local actionEachPage = 10

local chat_tab = nil

local function OnClickClose(displayNode)
    
    
	if chat_tab ~= nil then
		chat_tab.PlayCloseEffect()
	end
end

local function OnClickAction(index)
    
    if self.faceCb then
        self.faceCb(2, index)
        OnClickClose()
    end
end

local function RefreshAction(index, node)
    local btn =  node:FindChildByEditName('btn_action1',false)   
    node.Visible = true
    btn.Text = self.data[index].actionName
    btn.TouchClick = function (displayNode, pos)
        OnClickAction(index)
		print('-----------index: '..index ..'---'..btn.Text)
    end
end

local function InitItem(parent, index)
    if index then
        local node = DisplayNode.New("actionPageNode")
        node.IsInteractive = true
        node.Enable = true
        node.EnableChildren = true
        node.Size2D = self.sp_actionlist.Size2D
        for i = 1, actionEachPage do 
            local curIndex = index * actionEachPage + i
            if curIndex < #self.data then
                local child = self.cvs_action1:Clone()
                RefreshAction(curIndex, child)
                child.Position2D = Vector2.New(((i - 1)% 5) * 160 + 10, math.floor((i - 1) / 5) * 92 + 30)
                node:AddChild(child)
            end
        end
        return node 
    end
    
end

local function InitSildePoint()
    
    self.cvs_tab = self.m_Root:GetComponent("cvs_tab")
    for i = (self.pageNum + 1), 8 do
        local tbt_tab = self.m_Root:GetComponent("tbt_tab" .. i)
        tbt_tab.Visible = false
    end
    self.cvs_tab.X = 164 + (self.cvs_tab.Width - self.pageNum * 24)/ 2
end

local function DealSlide(index)
  
  local tbt_tab = "tbt_tab" .. index
  MenuBaseU.InitMultiToggleButton(self.cvs_tab, tbt_tab, CommonUnity3D.UGUIEditor.UI.TouchClickHandle(function(sender)
    
    
    for i = 1, self.pageNum do
        if i ~= self.curIndex and sender.EditName== "tbt_tab" .. i then
            self.curIndex = i
            
        end
    end
   
  end))
  self.curIndex = index
end

local function OnEnter()
    
end

function _M.Exit()

end

function _M.AddToChatExtend(self,chat_tab_list,data)
	if data ~= nil then
		_M.InitData(data)
	end
	chat_tab_list.RemoveAllChildren()
    chat_tab_list.cvs_extend2:AddChild(chat_tab_list.ChatUIActionMenu)
	chat_tab = chat_tab_list
end

function _M.InitData(data)
    self.data = data
    local count = #self.data
    self.pageNum = math.floor(count / actionEachPage)
    if count % actionEachPage  > 0 then
        self.pageNum = self.pageNum + 1
    end

    InitSildePoint()
	self.sp_actionlist.Scrollable:Initialize(self.pageNum, Vector2.New(self.sp_actionlist.Width, self.sp_actionlist.Height), 
            LuaUIBinding.CreatePageItemHandler(InitItem))
    DealSlide(1)
end

local function InitCompnent()
    self.m_Root.mRoot.IsInteractive = true
    self.m_Root.mRoot.Enable = true
    self.m_Root.mRoot.EnableChildren = true
    

    self.btn_close = self.menu:GetComponent("btn_close")
    self.btn_close.TouchClick = OnClickClose

    self.sp_actionlist = self.menu:GetComponent("sp_actionlist")
    self.sp_actionlist.Scrollable.ScrollSnap.nextPageThreshold = 100
    
    self.cvs_action1 = self.menu:GetComponent("cvs_action1")
    self.cvs_action1.Visible = false    
   
    self.sp_actionlist.Scrollable.event_OnEndDrag = function()
        if (self.curIndex - 1)* self.sp_actionlist.Width + self.sp_actionlist.Scrollable.Container.Position2D.x < -self.sp_actionlist.Scrollable.ScrollSnap.nextPageThreshold  then
            self.curIndex = self.curIndex + 1
            DealSlide(self.curIndex, true)
        elseif (self.curIndex - 1)* self.sp_actionlist.Width + self.sp_actionlist.Scrollable.Container.Position2D.x > self.sp_actionlist.Scrollable.ScrollSnap.nextPageThreshold  then
            self.curIndex = self.curIndex - 1
            DealSlide(self.curIndex, true)
        end
        DealSlide(self.curIndex)
    end

    self.menu:SubscribOnEnter(OnEnter)

    self.menu:SubscribOnDestory(function()
        self = nil
    end)
end

local function Init(tag,params)
	self.m_Root = LuaMenuU.Create("xmds_ui/chat/chat_dongzuo.gui.xml", GlobalHooks.UITAG.GameUIChatAction)
    self.m_Root.ShowType = UIShowType.Cover
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

local function initial()
  	
end

return {Create = Create, initial = initial}
