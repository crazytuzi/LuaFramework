local _M = {}
_M.__index = _M


local Util                  = require "Zeus.Logic.Util"


local self = {
	menu = nil,
}

local faceNum = 48
local facePage = 3

local function OnClickBegin(displayNode)
    
    self.curData.curColor = self.oldcolor
    self.menu:Close()
end

local function OnClickYes(displayNode)
    
    self.menu:Close()
end

local function OnClickDefault(displayNode)
    
    self.curData.curColor = GameUtil.CovertHexStringToRGBA(self.curData.FontColor)
    local color = CommonUnity3D.UGUI.UIUtils.UInt32_RGBA_To_Color( self.curData.curColor)
    self.cvs_preview.Visible = true
    self.cvs_preview.Layout = UILayout.CreateUILayoutColor(color, color)
end

local function OnClickColorSel(index)
    
    local cvs_colour = self.menu:GetComponent("cvs_colour" .. index)
    self.cvs_preview.Visible = true
    self.cvs_preview.Layout = UILayout.CreateUILayoutColor(cvs_colour.Layout.FillColor, cvs_colour.Layout.BorderColor)
    self.curData.curColor = CommonUnity3D.UGUI.UIUtils.Color_To_UInt32_RGBA(cvs_colour.Layout.FillColor)
end

local function OnClickCustomColorSel(index)
    
    local cvs_custom = self.menu:GetComponent("cvs_custom" .. index)
    self.cvs_preview.Visible = true
    self.cvs_preview.Layout = UILayout.CreateUILayoutColor(cvs_custom.Layout.FillColor, cvs_custom.Layout.BorderColor)
    self.curData.curColor = CommonUnity3D.UGUI.UIUtils.Color_To_UInt32_RGBA(cvs_custom.Layout.FillColor)
end

local function OnColorCallBack(data)
    self.menu.Alpha = 1
    if not data then return end

    self.customcolor[self.curSelIndex] = data
    local cvs_custom = self.menu:GetComponent("cvs_custom" .. self.curSelIndex)
    local newcolor = CommonUnity3D.UGUI.UIUtils.UInt32_RGBA_To_Color(data)
    cvs_custom.Layout = UILayout.CreateUILayoutColor(newcolor, newcolor)
end

local function OnClickColorCustom(index, displayNode)
    local node, luaobj = GlobalHooks.FindUI(GlobalHooks.UITAG.GameUIChatSetting3rd, 0)
    if luaobj == nil then
        node, luaobj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIChatSetting3rd, 0)
        local cvs_custom = self.menu:GetComponent("cvs_custom" .. index)
        self.curSelIndex = index
        luaobj.SetInfo(self,cvs_custom.Layout.FillColor, self.defaultCustomColor, OnColorCallBack)

        self.menu.Alpha = 0
    end
end

local function InitCustomColorData()
    
    self.customcolor = {}
    for i = 1, 4 do
        self.customcolor[i] =  tonumber(UnityEngine.PlayerPrefs.GetString(i .. "customcolor", "0"))
        local cvs_custom = self.menu:GetComponent("cvs_custom" .. i)
        local cvs_tishi = self.menu:GetComponent("cvs_tishi" .. i)
        
        if self.defaultCustomColor == nil then
            self.defaultCustomColor = cvs_custom.Layout.FillColor
        end
        if self.customcolor[i] == 0 then
            
            cvs_custom.Layout = UILayout.CreateUILayoutColor(self.defaultCustomColor, self.defaultCustomColor)
            
        else
            local color = CommonUnity3D.UGUI.UIUtils.UInt32_RGBA_To_Color(self.customcolor[i])
            cvs_custom.Layout = UILayout.CreateUILayoutColor(color, color)
            
        end
        
    end
end

local function SaveCustomColorData()
    
    for i = 1, #self.customcolor do
        UnityEngine.PlayerPrefs.SetString(i .. "customcolor", tostring(self.customcolor[i]))
    end
end

local function OnEnter()
    
end

local  function OnExit()
    
    SaveCustomColorData()
    if self.setting1stcb then
        self.setting1stcb()
    end
end

local function InitUI()
    
    local UIName = {
        "btn_close",
        "cvs_preview",
        "cvs_now",
        "cvs_maxuse",
        "btn_yes",
        "btn_default",
    }

    for i = 1, #UIName do
        self[UIName[i]] = self.menu:GetComponent(UIName[i])
    end
end

function _M.SetInfo(data,cb)
    
    self.curData = data
    self.oldcolor = self.curData.curColor
    self.cvs_preview.Visible = false
    if self.curData.curColor ~= 0 and self.curData.curColor ~= 255 then
        local color = CommonUnity3D.UGUI.UIUtils.UInt32_RGBA_To_Color(self.curData.curColor)
        self.cvs_now.Layout = UILayout.CreateUILayoutColor(color, color)
    else
        local color = CommonUnity3D.UGUI.UIUtils.UInt32_RGBA_To_Color(GameUtil.CovertHexStringToRGBA(self.curData.FontColor))
        self.cvs_now.Layout = UILayout.CreateUILayoutColor(color, color) 
    end
    InitCustomColorData()
    self.setting1stcb = cb
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

    for i = 1, 10 do
        local btn_colour = self.menu:GetComponent("btn_colour" .. i)
        btn_colour.TouchClick = function( ... )
            
            OnClickColorSel(i)
        end
    end

    for i = 1, 4 do
        local btn_custom = self.menu:GetComponent("btn_custom" .. i)
        btn_custom.TouchClick = function( ... )
            
            OnClickCustomColorSel(i)
        end

        btn_custom.LongPressSecond = 0.5
        btn_custom.event_LongPoniterDownStep = function( ... )
            OnClickColorCustom(i, btn_custom)
        end
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
	self.menu = LuaMenuU.Create("xmds_ui/chat/chat_colour.gui.xml", GlobalHooks.UITAG.GameUIChatSetting2nd)
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
