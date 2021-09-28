local _M = {}
_M.__index = _M

local Util  = require 'Zeus.Logic.Util'

local function InitComponent(self, tag,params)
    self.menu = LuaMenuU.Create('xmds_ui/solo/solo_rule.gui.xml',tag)
    
    local tb_rule = self.menu:GetComponent("tb_rule")
    local btn_close = self.menu:GetComponent("btn_close")


    tb_rule.XmlText = Util.GetText(TextConfig.Type.SOLO, "battlerule")
    tb_rule.Scrollable = true

    btn_close.TouchClick = function()
        if self ~= nil and self.menu ~= nil then
        	self.menu:Close()
    	end
    end

    self.menu.mRoot.IsInteractive = true
    self.menu.mRoot.Enable = true
    self.menu.mRoot.EnableChildren = true
    LuaUIBinding.HZPointerEventHandler({node = self.menu.mRoot, click = function(sender)
        self.menu:Close()
    end})


    return self.menu
end


local function Create(tag,params)
    local self = {}
    setmetatable(self, _M)
    InitComponent(self,tag, params)
    return self
end

return {Create = Create}
