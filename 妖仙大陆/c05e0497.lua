local _M = {}
_M.__index = _M


local Util                  = require "Zeus.Logic.Util"


local self = {
	menu = nil,
}

local faceNum = 48
local facePage = 3
local numPreRow = 7
local numPreColumn = 3

local maxUseNum = 6 

local function OnSaveFaceNum( )
    for i = 1, #self.faceNum do
        UnityEngine.PlayerPrefs.SetInt(i .. "faceNum", self.faceNum[i])
    end
    
end

local function OnClickBegin(displayNode)
    
    self.faceCb(3)
    self.menu:Close()
end

local function OnClickFace(index)
    
    
    if self.faceCb then
        self.faceCb(0, index - 1)
        self.faceNum[index] = self.faceNum[index] + 1
    end
    OnSaveFaceNum()
end

local function RefreshFace(index, node)
    node.Visible = true
    local cpjName = nil
    local cur = index - 1
    if cur < 10 then
        cpjName = "e0" .. cur
    else
        cpjName = "e" .. cur
    end
    
    local ib_biaoqing1 = node:FindChildByEditName("ib_biaoqing1", true)
    local layout = XmdsUISystem.CreateLayoutFromCpj("dynamic_n/ui_chat/emotion/output/emotion.xml", cpjName, 0)
    ib_biaoqing1.X = 0
    ib_biaoqing1.Y = 0
    ib_biaoqing1.Layout = layout

    local lb_facename = node:FindChildByEditName("lb_facename", true)
    local name = Util.GetText(TextConfig.Type.CHAT, 'emotion_name' .. index)
    if name ~= nil then
        lb_facename.Text = name
    else
        lb_facename.Text = ""
    end

    node.TouchClick = function (displayNode, pos)
        OnClickFace(index)
    end
end

local function InitItem(parent, index)
    if index then
        local node = DisplayNode.New("facePageNode" .. index)
        node.IsInteractive = true
        node.Enable = true
        node.EnableChildren = true
        node.Size2D = self.sp_facelist.Size2D
        for i = 1, numPreRow*numPreColumn do 
            local curIndex = index * numPreRow*numPreColumn + i
            if curIndex < faceNum then
                local child = self.cvs_biaoq:Clone()
                RefreshFace(curIndex, child)
                child.Position2D = Vector2.New(((i - 1)% numPreRow) * 90, math.floor((i - 1) / numPreRow) * 70)
                node:AddChild(child)
            end
        end
        return node 
    end
    
end

local function DealSlide(index)
  
  local tbt_tab = "tbt_tab" .. index
  MenuBaseU.InitMultiToggleButton(self.cvs_tab, tbt_tab, CommonUnity3D.UGUIEditor.UI.TouchClickHandle(function(sender)
    
    for i = 1, facePage do
        if i ~= self.curIndex and sender.EditName== "tbt_tab" .. i then
            self.curIndex = i
            self.sp_facelist.Scrollable:LookAt(Vector2.New(self.sp_facelist.Width * (self.curIndex - 1), 0))
        end
    end
   
  end))
  self.curIndex = index
end

local function LoadFaceUseTimes()
    self.faceNum = {}
    self.maxUse = {}
    for i = 1, faceNum do
        self.faceNum[i] =  UnityEngine.PlayerPrefs.GetInt(i .. "faceNum", 0)
        if self.faceNum[i] ~= 0 then
            if #self.maxUse < maxUseNum then
                self.maxUse[#self.maxUse + 1] = i
            else
                local curnum = self.faceNum[i]
                local curIndex = i
                for j = 1, maxUseNum do
                    if self.faceNum[self.maxUse[j]] < curnum then
                        local tempIndex = self.maxUse[j]
                        self.maxUse[j] = curIndex
                        curIndex = tempIndex
                        curnum = self.faceNum[curIndex]
                    end
                end
            end
        end
    end

    self.cvs_maxuse:RemoveChildren(0, -1, true)
    for j = 1, #self.maxUse do
        local child = self.cvs_biaoq:Clone()
        RefreshFace(self.maxUse[j], child)
        child.Position2D = Vector2.New(((j - 1)% 2) * 90, math.floor((j - 1) / 2) * 70)
        self.cvs_maxuse:AddChild(child)
    end
end

local function OnEnter()
    
    DealSlide(1)
    LoadFaceUseTimes()
end

function _M.AddToChatExtend(self,chat_tab_list)
    chat_tab_list.RemoveAllChildren()
    chat_tab_list.cvs_extend2:AddChild(chat_tab_list.ChatUIFaceMenu)
    
    OnEnter()
end

local  function OnExit()
    
    
end

function _M.Exit()
    
   OnExit()
end

local function InitUI()
    
    local UIName = {
        "sp_facelist",
        "cvs_biaoq",
        "cvs_tab",
        "cvs_maxuse",
    }

    for i = 1, #UIName do
        self[UIName[i]] = self.menu:GetComponent(UIName[i])
    end
end

local function InitCompnent()
    InitUI()
    LuaUIBinding.HZPointerEventHandler({node = self.menu, click = OnClickBegin})
    self.cvs_biaoq.Visible = false

    self.btn_close = self.menu:GetComponent("btn_close")
    self.btn_close.TouchClick = OnClickBegin
    
    self.sp_facelist.Scrollable.ScrollSnap.nextPageThreshold = 100
    self.sp_facelist.Scrollable:Initialize(facePage, Vector2.New(self.sp_facelist.Width, self.sp_facelist.Height), 
            LuaUIBinding.CreatePageItemHandler(InitItem))

    self.sp_facelist.Scrollable.event_OnEndDrag = function()
        if (self.curIndex - 1)* self.sp_facelist.Width + self.sp_facelist.Scrollable.Container.Position2D.x < -self.sp_facelist.Scrollable.ScrollSnap.nextPageThreshold  then
            self.curIndex = self.curIndex + 1
            DealSlide(self.curIndex, true)
        elseif (self.curIndex - 1)* self.sp_facelist.Width + self.sp_facelist.Scrollable.Container.Position2D.x > self.sp_facelist.Scrollable.ScrollSnap.nextPageThreshold  then
            self.curIndex = self.curIndex - 1
            DealSlide(self.curIndex, true)
        end
        DealSlide(self.curIndex)
    end
    
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
	self.menu = LuaMenuU.Create("xmds_ui/chat/chat_biaoqing.gui.xml", GlobalHooks.UITAG.GameUIChatFace)
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
