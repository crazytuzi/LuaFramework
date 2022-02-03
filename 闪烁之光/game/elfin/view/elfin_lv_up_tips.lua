--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-08-28 15:57:56
-- @description    : 
		-- 灵窝升级提示界面
---------------------------------
local _controller = ElfinController:getInstance()
local _model = _controller:getModel()
local _string_format = string.format

ElfinLvUpTipsWindow = ElfinLvUpTipsWindow or BaseClass(BaseView)

function ElfinLvUpTipsWindow:__init()
	self.win_type = WinType.Tips
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.is_full_screen = false
	self.layout_name = "elfin/elfin_up_lv_tips"
end

function ElfinLvUpTipsWindow:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
	if self.background then
		self.background:setScale(display.getMaxScale())
	end

	local container = self.root_wnd:getChildByName("container")
    self:playEnterAnimatianByObj(container, 2)

	self.btn_uplv = container:getChildByName("btn_uplv")
	self.btn_uplv_label = self.btn_uplv:getChildByName("label")
	self.btn_uplv_label:setString(TI18N("确定"))
	self.btn_cancel = container:getChildByName("btn_cancel")
	self.btn_cancel:getChildByName("label"):setString(TI18N("取消"))

	container:getChildByName("win_title"):setString(TI18N("提示"))
	self.vip_tips = container:getChildByName("vip_tips")
	self.vip_tips:setVisible(false)

	container:getChildByName("cur_hatch_plan_title"):setString(TI18N("孵化效率:"))
	self.cur_hatch_plan_txt = container:getChildByName("cur_hatch_plan_txt")
	container:getChildByName("cur_hatch_lv_title"):setString(TI18N("当前等级:"))
	self.cur_hatch_lv_txt = container:getChildByName("cur_hatch_lv_txt")
	container:getChildByName("next_hatch_plan_title"):setString(TI18N("孵化效率:"))
	self.next_hatch_plan_txt = container:getChildByName("next_hatch_plan_txt")
	container:getChildByName("next_hatch_lv_title"):setString(TI18N("当前等级:"))
	self.next_hatch_lv_txt = container:getChildByName("next_hatch_lv_txt")

	if not self.lv_up_tips_txt then
		self.lv_up_tips_txt = createRichLabel(24, 274, cc.p(0.5, 0.5), cc.p(340, 300), 10, nil, 550)
		container:addChild(self.lv_up_tips_txt)
	end
end

function ElfinLvUpTipsWindow:register_event(  )
	registerButtonEventListener(self.btn_cancel, function (  )
		_controller:openElfinLvUpTipsWindow(false)
	end, true, 2)

	registerButtonEventListener(self.background, function ( )
		_controller:openElfinLvUpTipsWindow(false)
	end, false, 2)

	registerButtonEventListener(self.btn_uplv, function (  )
		self:onClickLvUpBtn()
	end, true)
end

function ElfinLvUpTipsWindow:onClickLvUpBtn(  )
	if self.hatch_id then
		_controller:sender26502(self.hatch_id)
	end
	_controller:openElfinLvUpTipsWindow(false)
end

function ElfinLvUpTipsWindow:openRootWnd( hatch_id, hatch_lev )
	self.hatch_id = hatch_id
	self:setData(hatch_lev)
end

function ElfinLvUpTipsWindow:setData( hatch_lev )
	local cur_hatch_lev_cfg = Config.SpriteData.data_hatch_lev[hatch_lev]
    local next_hatch_lev_cfg = Config.SpriteData.data_hatch_lev[hatch_lev+1]
    if not cur_hatch_lev_cfg or not next_hatch_lev_cfg then return end

    local tips_str = TI18N("是否花费")
    for i,v in ipairs(next_hatch_lev_cfg.expend) do
        local bid = v[1]
        local num = v[2]
        local item_config = Config.ItemData.data_get_data(bid)
        if item_config then
            tips_str = tips_str .. _string_format(TI18N(" <img src='%s' scale=0.3 /> %d"), PathTool.getItemRes(item_config.icon), num)
        end
    end
    tips_str = tips_str .. TI18N("提升孵化等级，加快自动孵化的速度？")
    self.lv_up_tips_txt:setString(tips_str)

    self.cur_hatch_lv_txt:setString("Lv." .. hatch_lev)
    self.cur_hatch_plan_txt:setString(_string_format(TI18N("-1点/%d秒"), cur_hatch_lev_cfg.do_time))
    self.next_hatch_lv_txt:setString("Lv." .. (hatch_lev+1))
    self.next_hatch_plan_txt:setString(_string_format(TI18N("-1点/%d秒"), next_hatch_lev_cfg.do_time))

    local role_vo = RoleController:getInstance():getRoleVo()
    self.vip_tips:setString(_string_format(TI18N("VIP%d开启"), next_hatch_lev_cfg.limit_vip))
    self.vip_tips:setVisible(role_vo.vip_lev < next_hatch_lev_cfg.limit_vip)
    if role_vo.vip_lev < next_hatch_lev_cfg.limit_vip then
    	setChildUnEnabled(true, self.btn_uplv)
        self.btn_uplv_label:disableEffect(cc.LabelEffect.OUTLINE)
        self.btn_uplv:setTouchEnabled(false)
    end
end

function ElfinLvUpTipsWindow:close_callback(  )
	_controller:openElfinLvUpTipsWindow(false)
end