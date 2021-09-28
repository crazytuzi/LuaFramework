local _M = {}
_M.__index = _M


local Util                  = require "Zeus.Logic.Util"


local self = {
	menu = nil,
}

local function OnClickBegin(displayNode)
    
    if self ~= nil then
        self.menu:Close()
        if self.oncolorcallback ~= nil then
            self.oncolorcallback(nil)
        end
    end
end

local function GetNewColor(r, g, b, a)
    
    local rgba = r * (2 ^ 24) + g *(2 ^ 16) + b * (2 ^ 8) + a
    return rgba
end

local function OnClickYes( ... )
    
    if self.oncolorcallback ~= nil and self.newcolor ~= nil then
        local color = GetNewColor(self.color[self.UIName[1]], self.color[self.UIName[2]], self.color[self.UIName[3]], 255)
        self.oncolorcallback(color)
        self.menu:Close()
    end
end

local function SetGauge(node, cur, max)
    
    node:SetGaugeMinMax(0, max)
    node.Value = (cur < max and cur) or max
    node.Text = tostring(cur)
end

local function OnClickDefault( ... )
    
    local color = CommonUnity3D.UGUI.UIUtils.UInt32_RGBA_To_Color(self.defaultcolor)
    self.cvs_now.Layout = UILayout.CreateUILayoutColor(color, color)
    self.color = {}
    self.color[self.UIName[1]] = math.floor(self.defaultcolor / (2 ^ 24)) % 256 
    self.color[self.UIName[2]] = math.floor(self.defaultcolor / (2 ^ 16)) % 256
    self.color[self.UIName[3]] = math.floor(self.defaultcolor / (2 ^ 8)) % 256
    self.newcolor = color

    for i = 1, #self.UIName do
        local gg_red = self[self.UIName[i]]:FindChildByEditName("gg_red", true)
        SetGauge(gg_red, self.color[self.UIName[i]], 256)
    end
    
    
end

local function OnEnter()
    
   
    
  
end

local  function OnExit()
    
   
end

local function OnGaugeRefresh(gg_red, index)
    
    if self.color[self.UIName[index]] < 0 then
        self.color[self.UIName[index]] = 0
    elseif self.color[self.UIName[index]] > 255 then
        self.color[self.UIName[index]] = 255
    end
    SetGauge(gg_red, self.color[self.UIName[index]], 256)
    self.newcolor = CommonUnity3D.UGUI.UIUtils.UInt32_RGBA_To_Color(GetNewColor(self.color[self.UIName[1]], self.color[self.UIName[2]], self.color[self.UIName[3]], 255))
    self.cvs_now.Layout = UILayout.CreateUILayoutColor(self.newcolor, self.newcolor)
    
    
end

function _M.SetInfo(setting2nd,color, default, cb)
    
    self.cvs_now.Layout = UILayout.CreateUILayoutColor(color, color)
    self.oldcolor = CommonUnity3D.UGUI.UIUtils.Color_To_UInt32_RGBA(color)
    self.defaultcolor = CommonUnity3D.UGUI.UIUtils.Color_To_UInt32_RGBA(default)
    self.oncolorcallback = cb
    self.color = {}
    self.color[self.UIName[1]] = math.floor(self.oldcolor / (2 ^ 24)) % 256 
    self.color[self.UIName[2]] = math.floor(self.oldcolor / (2 ^ 16)) % 256
    self.color[self.UIName[3]] = math.floor(self.oldcolor / (2 ^ 8)) % 256
    for i = 1, #self.UIName do
        local btn_reduce = self[self.UIName[i]]:FindChildByEditName("btn_reduce", true)
        local gg_red = self[self.UIName[i]]:FindChildByEditName("gg_red", true)
        SetGauge(gg_red, self.color[self.UIName[i]], 256)

        btn_reduce.TouchClick = function( ... )
            
            self.color[self.UIName[i]] = self.color[self.UIName[i]] - 10
            OnGaugeRefresh(gg_red, i)
        end

        btn_reduce.LongPressSecond = 0.1
        btn_reduce.event_LongPoniterDownStep = function( ... )
            
            self.color[self.UIName[i]] = self.color[self.UIName[i]] - 1
            OnGaugeRefresh(gg_red, i)
        end

        local btn_plus = self[self.UIName[i]]:FindChildByEditName("btn_plus", true)
        btn_plus.LongPressSecond = 0.1
        btn_plus.TouchClick = function( ... )
            
            self.color[self.UIName[i]] = self.color[self.UIName[i]] + 10
            OnGaugeRefresh(gg_red, i)
        end

        btn_plus.event_LongPoniterDownStep = function( ... )
            
            self.color[self.UIName[i]] = self.color[self.UIName[i]] + 1
            OnGaugeRefresh(gg_red, i)
        end
    end
end

local function InitUI()
    
    local UIName = {
        "btn_close",
        "btn_yes",
        "btn_default",
        "cvs_now",
    }

    self.UIName = {
        "cvs_r",
        "cvs_g",
        "cvs_b",
    }

    for i = 1, #UIName do
        self[UIName[i]] = self.menu:GetComponent(UIName[i])
    end

    for i = 1, #self.UIName do
        self[self.UIName[i]] = self.menu:GetComponent(self.UIName[i])
    end
end

local function InitCompnent()
    InitUI()
    self.menu.mRoot.IsInteractive = true
    self.menu.mRoot.Enable = true
    self.menu.mRoot.EnableChildren = true
    LuaUIBinding.HZPointerEventHandler({node = self.menu.mRoot, click = OnClickBegin})
    self.btn_close.TouchClick = OnClickBegin
    self.btn_yes.TouchClick = OnClickYes

    self.btn_default.TouchClick = OnClickDefault
    
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
	self.menu = LuaMenuU.Create("xmds_ui/chat/chat_rgb.gui.xml", GlobalHooks.UITAG.GameUIChatSetting3rd)
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
