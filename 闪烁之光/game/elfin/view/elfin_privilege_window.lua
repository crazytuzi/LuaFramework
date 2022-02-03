--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-08-15 16:09:47
-- @description    : 
		-- 特权灵窝提示
---------------------------------
local _controller = ElfinController:getInstance()
local _model = _controller:getModel()
local _table_insert = table.insert

ElfinPrivilegeWindow = ElfinPrivilegeWindow or BaseClass(BaseView)

function ElfinPrivilegeWindow:__init()
	self.win_type = WinType.Big
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.is_full_screen = false
	self.layout_name = "elfin/elfin_privilege_window"

	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("elfin", "elfin"), type = ResourcesType.plist},
        {path = PathTool.getPlistImgForDownLoad("elfin","txt_cn_privilege_bg"), type = ResourcesType.single },
	}
end

function ElfinPrivilegeWindow:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
	if self.background then
		self.background:setScale(display.getMaxScale())
	end

	local container = self.root_wnd:getChildByName("container")
    self:playEnterAnimatianByObj(container, 2)

	self.go_to_btn = container:getChildByName("go_to_btn")
	self.btn_lab = self.go_to_btn:getChildByName("label")
	self.btn_lab:setString(TI18N("前往激活"))
	self.btn_close = container:getChildByName("btn_close")

	container:getChildByName("txt_tips_1"):setString(TI18N("解锁全新灵窝，孵化效率提升"))
	container:getChildByName("txt_tips_2"):setString(TI18N("获得专属金羽蛋，孵化极品精灵"))
	container:getChildByName("txt_tips_3"):setString(TI18N("每日赠送水灵蛋，连续7天"))
end

function ElfinPrivilegeWindow:register_event(  )
	registerButtonEventListener(self.background, function (  )
		_controller:openElfinPrivilegeWindow(false)
	end, false, 2)

	registerButtonEventListener(self.btn_close, function (  )
		_controller:openElfinPrivilegeWindow(false)
	end, true, 2)

	registerButtonEventListener(self.go_to_btn, function (  )
		local privilege_data = RoleController:getInstance():getModel():getPrivilegeDataById(5)
		if privilege_data and privilege_data.expire_time and privilege_data.status == 1 then --已激活
			return
		end

		VipController:getInstance():openVipMainWindow(true, VIPTABCONST.PRIVILEGE)
		--MallController:getInstance():openChargeShopWindow(true, MallConst.Charge_Shop_Type.Privilege)
		_controller:openElfinPrivilegeWindow(false)
	end, true)
end

function ElfinPrivilegeWindow:openRootWnd(  )
	local privilege_data = RoleController:getInstance():getModel():getPrivilegeDataById(5)
	if privilege_data and privilege_data.expire_time and privilege_data.status == 1 then --已激活
		setChildUnEnabled(true, self.go_to_btn)
        self.btn_lab:disableEffect(cc.LabelEffect.OUTLINE)
		self.btn_lab:setString(TI18N("已激活"))
	else
		setChildUnEnabled(false, self.go_to_btn)
        self.btn_lab:enableOutline(Config.ColorData.data_color4[264], 2)
		self.btn_lab:setString(TI18N("前往激活"))
	end
end

function ElfinPrivilegeWindow:close_callback(  )
	_controller:openElfinPrivilegeWindow(false)
end