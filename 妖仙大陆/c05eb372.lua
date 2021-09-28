local _M = {}
_M.__index = _M


local ChatModel = require 'Zeus.Model.Chat'

local self = {
    m_Root = nil,
    setChannel = nil,
    tbt_channel = nil,
}



local function OnClickClose(displayNode)
    
    if self.clickActionCb ~= nil then
        self.clickActionCb(-1)
    end
    self.m_Root:Close()
end

local function Dealdata(data)
    
    if data > 0 then
        return "+" .. data
    else
        return "" .. data
    end
end

local function OnEnter()
    local index = tonumber(self.m_Root.ExtParam)
    ChatModel.interactConfigRequest(function (params)
        
        
        if index == 1 then
            self.lb_propname3.Visible = true
            self.lb_propname4.Visible = true
            self.btn_throw[1].Visible = true
            self.btn_throw[2].Visible = true
            local layout = XmdsUISystem.CreateLayoutFroXml("#dynamic_n/chat/chat.xml|chat|24", LayoutStyle.IMAGE_STYLE_BACK_4, 0)
            self.ib_icon1.Layout = layout
            layout = XmdsUISystem.CreateLayoutFroXml("#dynamic_n/chat/chat.xml|chat|23", LayoutStyle.IMAGE_STYLE_BACK_4, 0)
            self.ib_icon2.Layout = layout
            self.lb_attribute1.Text = Dealdata(params.s2c_data[1].charm)
            self.lb_attribute2.Text = Dealdata(params.s2c_data[2].charm)
        else
            self.lb_propname3.Visible = false
            self.lb_propname4.Visible = false
            self.btn_throw[1].Visible = false
            self.btn_throw[2].Visible = false
            local layout = XmdsUISystem.CreateLayoutFroXml("#dynamic_n/chat/chat.xml|chat|24", LayoutStyle.IMAGE_STYLE_BACK_4, 0)
            self.ib_icon1.Layout = layout
            layout = XmdsUISystem.CreateLayoutFroXml("#dynamic_n/chat/chat.xml|chat|23", LayoutStyle.IMAGE_STYLE_BACK_4, 0)
            self.ib_icon2.Layout = layout
            self.lb_attribute1.Text = Dealdata(params.s2c_data[3].charm)
            self.lb_attribute2.Text = Dealdata(params.s2c_data[4].charm)
        end

        for i =  1, 2 do
            local ib_nubicon = self.m_Root:GetComponent("ib_nubicon" .. i)
            local lb_num = self.m_Root:GetComponent("lb_num" .. i)
            local cdata = params.s2c_data[index * 2 - 2 + i]
            if cdata.diamond == 0 then
                local layout = XmdsUISystem.CreateLayoutFroXml("#static_n/func/common2.xml|common2|172", LayoutStyle.IMAGE_STYLE_BACK_4, 0)
                ib_nubicon.Layout = layout
                lb_num.Text = "" .. cdata.gold
            else
                local layout = XmdsUISystem.CreateLayoutFroXml("#static_n/func/common2.xml|common2|173", LayoutStyle.IMAGE_STYLE_BACK_4, 0)
                ib_nubicon.Layout = layout
                lb_num.Text = "" .. cdata.diamond
            end
        end
    end)

    ChatModel.interactTimesRequest(function (params)
        
        
        self.lb_timenum.Text = params.s2c_data[index].times
    end)
end

local function OnClickThrow(index)
    
    if self.clickActionCb ~= nil then
        self.clickActionCb(index)
    end
    self.m_Root:Close()
end

local function InitUI()
    
    local UIName = {
        "lb_propname3",
        "lb_propname4",
        "ib_icon1",
        "ib_icon2",
        "lb_attribute1",
        "lb_attribute2",
        "lb_timenum",
        "btn_close",
    }

    for i = 1, #UIName do
        self[UIName[i]] = self.m_Root:GetComponent(UIName[i])
    end
end


local function InitCompnent()
    InitUI()
    self.m_Root.mRoot.IsInteractive = true
    self.m_Root.mRoot.Enable = true
    self.m_Root.mRoot.EnableChildren = true
    LuaUIBinding.HZPointerEventHandler({node = self.m_Root.mRoot, click = OnClickClose})

    self.btn_close.TouchClick = OnClickClose

    self.btn_throw = {}
    for i = 1, 2 do
        local namestr = "btn_throw" .. i
        self.btn_throw[i] = self.m_Root:GetComponent(namestr)
        self.btn_throw[i].TouchClick = function()
            
            OnClickThrow(i)
        end
    end

    self.m_Root:SubscribOnEnter(OnEnter)
    self.m_Root:SubscribOnDestory(function()
        self = nil
    end)
end

local function Init(tag,params)
	self.m_Root = LuaMenuU.Create("xmds_ui/chat/chat_interaction.gui.xml", GlobalHooks.UITAG.GameUIChatGift)
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
  print("DungeonMain.initial")
end

return {Create = Create, initial = initial}
