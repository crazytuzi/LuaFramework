--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2018-11-07 16:52:04
-- @description    : 
		-- 实名认证
---------------------------------
RoleAttestationWindow = RoleAttestationWindow or BaseClass(BaseView)

function RoleAttestationWindow:__init(ctrl)
	self.ctrl = ctrl
	self.model = self.ctrl:getModel()
	self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.is_full_screen = true
	self.win_type = WinType.Mini
	self.layout_name = "roleinfo/role_attestation_window"
	self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("bigbg/action","txt_cn_action_attestation"), type = ResourcesType.single },
    }
end

function RoleAttestationWindow:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
	if self.background then
		self.background:setScale(display.getMaxScale())
	end

	local container = self.root_wnd:getChildByName("container")
	self.container = container
    self:playEnterAnimatianByObj(container , 2)

	local win_title = container:getChildByName("win_title")
	win_title:setString(TI18N("实名认证"))

	self.close_btn = container:getChildByName("close_btn")
	self.confirm_btn = container:getChildByName("confirm_btn")
	self.confirm_btn_label = self.confirm_btn:getChildByName("label")
	self.confirm_btn_label:setString("")

	self.tips_label = createRichLabel(22, cc.c3b(104,69,42), cc.p(0, 0), cc.p(38, 255), 10, nil, 600)
	self.tips_label:setString(TI18N("相关部门要求，游戏正式开启实名认证！各位冒险家在完成实名认证后，即可获得一份认证好礼~（奖励仅限成年玩家领取）"))
	container:addChild(self.tips_label)

	self.good_con = container:getChildByName("good_con")
	self.good_con:setScrollBarEnabled(false)
end

function RoleAttestationWindow:setAwardData(  )
	local award_config = Config.MiscData.data_const["auth_award"]
	if award_config then
		local data_list = award_config.val
	    local setting = {}
	    setting.scale = 0.9
	    setting.max_count = 6
	    setting.is_center = true
	    self.item_list = commonShowSingleRowItemList(self.good_con, self.item_list, data_list, setting)
	end
end

function RoleAttestationWindow:openRootWnd(  )
	RoleController:getInstance():sender10960()
	self:setAwardData()
end

function RoleAttestationWindow:register_event(  )
	registerButtonEventListener(self.close_btn, handler(self, self._onClickBtnClose), false, 2)
	registerButtonEventListener(self.background, handler(self, self._onClickBtnClose), false, 2)
	registerButtonEventListener(self.confirm_btn, handler(self, self._onClickBtnConfirm), true)
	

	self:addGlobalEvent(RoleEvent.ROLE_NAME_AUTHENTIC, function(data)
        if data then
        	self.confirm_status = data.code
        	if data.code == 0 then
        		self.confirm_btn_label:setString(TI18N("领取奖励"))
        	else
        		self.confirm_btn_label:setString(TI18N("已领取"))
        	end
        end
    end)
end

function RoleAttestationWindow:_onClickBtnClose(  )
	self.ctrl:openRoleAttestationWindow(false)
end

function RoleAttestationWindow:_onClickBtnConfirm()
	-- print("self.confirm_status..... ",self.confirm_status)
	if not self.confirm_status then return end
	RoleController:getInstance():sender10961()
	-- showRealNameWindow()
	-- self.ctrl:openRoleAttestationWindow(false)
end

function RoleAttestationWindow:close_callback(  )
	if self.tips_label then
		self.tips_label:DeleteMe()
		self.tips_label = nil
	end
	if self.item_list then
        for i,v in ipairs(self.item_list) do
            v:DeleteMe()
        end
    end
    self.item_list = {}
	self.ctrl:openRoleAttestationWindow(false)
end