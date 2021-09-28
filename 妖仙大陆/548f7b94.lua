


local Util = require 'Zeus.Logic.Util'
local PageUIProperty = require "Zeus.UI.XmasterActor.PageUIProperty"
local PageUIStrg = require "Zeus.UI.XmasterActor.PageUIStrg"
local PageUIInlay = require "Zeus.UI.XmasterActor.PageUIInlay"
local _M = {
    menu = nil,func_btns = nil,pages = nil,curShowPage = nil
}
_M.__index = _M

local ui_name = {
    {
        name = "btn_close",
        click = function(self)
            self:Close();
        end
    },
    { name = "tbt_property"},
    { name = "tbt_title"},
    { name = "tbt_strg"},
    { name = "tbt_inlay"},
    { name = "lb_bj_pro"},
    { name = "lb_bj_title"},
    { name = "lb_bj_strg"},
    { name = "lb_bj_inlay"},
    { name = "cvs_content"}

}

local funcBtnNames = {
    "tbt_property","tbt_title","tbt_strg","tbt_inlay"
}

function _M:Close()
    self.menu:Close()
end

function _M.Notify(status, userdata, self)
    if userdata == DataMgr.Instance.FlagPushData then
        if status == FlagPushData.FLAG_ACTOR_STRENGTH then
            self.lb_bj_strg.Visible = (DataMgr.Instance.FlagPushData:GetFlagState(FlagPushData.FLAG_ACTOR_STRENGTH) ~= 0)
        elseif status == FlagPushData.FLAG_ACTOR_INLAY then
            self.lb_bj_inlay.Visible = (DataMgr.Instance.FlagPushData:GetFlagState(FlagPushData.FLAG_ACTOR_INLAY) ~= 0)
        end 
    
    
    
    
    
    
    end
end

local function OnEnter(self)
    self.paramStrg = 1
    if self.menu.ExtParam then
        local params = string.split(self.menu.ExtParam,"|")
        if(params[1] == "strength") then
            if #params > 1 then
                self.paramStrg = tonumber(params[2])
            else
                self.paramStrg = 1
            end
            Util.ChangeMultiToggleButtonSelect(self.tbt_strg, self.func_btns)
        elseif (params[1] == "inlay") then
            Util.ChangeMultiToggleButtonSelect(self.tbt_inlay, self.func_btns)
        else
            Util.ChangeMultiToggleButtonSelect(self.tbt_property, self.func_btns)
        end
    else
        Util.ChangeMultiToggleButtonSelect(self.tbt_property, self.func_btns)
    end

    self.tbt_strg.Visible = GlobalHooks.CheckFuncOpenByTag(GlobalHooks.UITAG.GameUIStrengthenMain, false)
    self.tbt_inlay.Visible = GlobalHooks.CheckFuncOpenByTag(GlobalHooks.UITAG.GameUIJewelryInlay, false)

    
    DataMgr.Instance.FlagPushData:AttachLuaObserver(100, self)
    
    self.Notify(FlagPushData.FLAG_ACTOR_STRENGTH, DataMgr.Instance.FlagPushData, self)
    self.Notify(FlagPushData.FLAG_ACTOR_INLAY, DataMgr.Instance.FlagPushData, self)
    
end

local function OnExit(self)
    for k,v in pairs(self.pages) do
        v:OnExit()
    end
    self.curShowPage = -1

end

local function OnDestory(self)
    DataMgr.Instance.FlagPushData:DetachLuaObserver(100)
     
end


local function OpenUIProperty(self)
    if(self.pages.property == nil) then
        self.pages.property = PageUIProperty.Create(GlobalHooks.UITAG.GameUIRoleAttribute,self)
    end
    for k,v in pairs(self.pages) do
        if k ~= "property" then
            v:OnExit()
        end
    end
    self.pages.property:OnEnter()
    self.pages.property:SetVisible(true)
end

function _M:OpenUITitle()
    
    
    
    
    
    
    
end

function _M:OpenUIStrg()
    if(self.pages.strg == nil) then
        self.pages.strg = PageUIStrg.Create(3,self)
    end
    for k,v in pairs(self.pages) do
        v:OnExit()
    end
    self.pages.strg:OnEnter()
    self.pages.strg:SetVisible(true)
end

function _M:OnenUIInlay()
    if(self.pages.inlay == nil) then
        self.pages.inlay = PageUIInlay.Create(4,self)
    end
    for k,v in pairs(self.pages) do
        v:SetVisible(false)
    end
    self.pages.inlay:OnEnter()
    self.pages.inlay:SetVisible(true)
end

local function getIndexForBtnSender(self,sender)
    for i = 1,#self.func_btns,1 do
        if(sender == self.func_btns[i]) then
            return i
        end 
    end
    return 1
end


local function OnFuncBtnChecked(self,sender)
    local senderIndex = getIndexForBtnSender(self,sender)
    if (self.curShowPage == senderIndex) then
        return
    end
    self.curShowPage = senderIndex
    if(sender == self.tbt_property) then
        OpenUIProperty(self)
    elseif (sender == self.tbt_title) then
        self:OpenUITitle()
    elseif (sender == self.tbt_strg) then
        self:OpenUIStrg()
    elseif (sender == self.tbt_inlay) then
        self:OnenUIInlay()
    end
end

local function InitComponent(self,tag)
    self.menu = LuaMenuU.Create('xmds_ui/character/background.gui.xml',tag)
    Util.CreateHZUICompsTable(self.menu, ui_name, self)
    self.menu.ShowType = UIShowType.HideBackHud
    self.curShowPage = 0
    self.pages = {}
    self.menu:SubscribOnExit( function()
        OnExit(self)
    end )
    self.menu:SubscribOnEnter( function()
        OnEnter(self)
    end )
    self.menu:SubscribOnDestory( function()
        OnDestory(self)
    end )
    local main = self
    self.func_btns = {self.tbt_property,self.tbt_title,self.tbt_strg,self.tbt_inlay}
    if(self.pages.property == nil) then
        self.pages.property = PageUIProperty.Create(GlobalHooks.UITAG.GameUIRoleAttribute,self)
    end
    if(self.pages.strg == nil) then
        self.pages.strg = PageUIStrg.Create(3,self)
    end
    if(self.pages.inlay == nil) then
        self.pages.inlay = PageUIInlay.Create(4,self)
    end
    Util.InitMultiToggleButton( function(sender)
        OnFuncBtnChecked(main, sender)
    end , nil, self.func_btns)   
end

function _M.Create(tag)
    local ret = {}
    setmetatable(ret,_M)
    InitComponent(ret,tag)
    return ret
end



return _M

