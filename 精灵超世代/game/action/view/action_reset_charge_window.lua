-- --------------------------------------------------------------------
-- 充值限时重置活动
-- --------------------------------------------------------------------
ActionResetChargeWindow = ActionResetChargeWindow or BaseClass(BaseView)

local controller = ActionController:getInstance()
function ActionResetChargeWindow:__init()
	self.win_type = WinType.Tips
	self.view_tag = ViewMgrTag.TOP_TAG -- DIALOGUE_TAG
	self.layout_name = "action/action_reset_charge_window"
	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("welfare", "welfare"), type = ResourcesType.plist},
		{path = PathTool.getPlistImgForDownLoad("bigbg/action", "txt_cn_action_reset_charge_bg"), type = ResourcesType.single},
	}
end

function ActionResetChargeWindow:open_callback()
	self.background = self.root_wnd:getChildByName("background")
	self.background:setAnchorPoint(cc.p(0.5, 0.5))
	self.background:setPosition(360,640)
	self.background:setScale(display.getMaxScale())
	
	self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container, 2)
	self.info_panel = self.main_container:getChildByName("info_panel")
	self.btn_close = self.info_panel:getChildByName("btn_close")
	
end

function ActionResetChargeWindow:openRootWnd()

end

function ActionResetChargeWindow:register_event()
	
	-- registerButtonEventListener(self.background, function()
	-- 	controller:openActionResetChargeWindow(false)
	-- end, false, 2)
	
	registerButtonEventListener(self.btn_close, function()
		controller:openActionResetChargeWindow(false)
	end, true, 2)
end

function ActionResetChargeWindow:close_callback()
	doStopAllActions(self.main_container)

	controller:openActionResetChargeWindow(false)
end