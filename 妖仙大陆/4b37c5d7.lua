local _M = { }
_M.__index = _M
local self={}

local function InitUI()
	local UIName = {
		"btn_close",
		"lb_money",
	}
	for i=1,#UIName do
		self[UIName[i]] = self.menu:GetComponent(UIName[i])
	end

	self.btn_close.TouchClick = function()
        if self ~= nil and self.menu ~= nil then
        	self.menu:Close()
    	end
    end
end

function _M:setData(params1,params2)
	self.lb_money.Text = params1
	if params2 == 0 then
		self.lb_money.Layout = XmdsUISystem.CreateLayoutFroXml("#static_n/func/common2.xml|common2|173", LayoutStyle.IMAGE_STYLE_BACK_4_CENTER, 8)
	else
		self.lb_money.Layout = XmdsUISystem.CreateLayoutFroXml("#static_n/func/common2.xml|common2|172", LayoutStyle.IMAGE_STYLE_BACK_4_CENTER, 8)
	end
end

local function OnEnter()

end

local function OnExit()
	self.lb_money.Text = ""
end


local function  Init( params )
	self.menu = LuaMenuU.Create("xmds_ui/chat/chat_hongbao_get.gui.xml", GlobalHooks.UITAG.GameUIRedPacketGet)
	self.menu.Enable = true
	self.menu.mRoot.Enable = true
	InitUI()
	self.menu:SubscribOnEnter(OnEnter)
	self.menu:SubscribOnExit(OnExit)
	return self.menu
end

local function Create(params)
    self = { }
    setmetatable(self, _M)
     Init(params)
    return self
end

return { Create = Create }
