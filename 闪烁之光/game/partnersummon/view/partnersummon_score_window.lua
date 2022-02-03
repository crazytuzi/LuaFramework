--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2018-11-19 14:37:17
-- @description    : 
		-- 积分召唤
---------------------------------
PartnerSummonScoreWindow = PartnerSummonScoreWindow or BaseClass(BaseView)

function PartnerSummonScoreWindow:__init()
    self.ctrl = PartnersummonController:getInstance()
    self.model = self.ctrl:getModel()
    self.is_full_screen = false
    self.win_type = WinType.Mini  
    self.view_tag = ViewMgrTag.DIALOGUE_TAG 
    self.layout_name = "partnersummon/partnersummon_sore_window"
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("partnersummon", "partnersummon"), type = ResourcesType.plist },
    }
end

function PartnerSummonScoreWindow:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
	if self.background then
		self.background:setScale(display.getMaxScale())
	end

	local main_panel = self.root_wnd:getChildByName("main_panel")
    self:playEnterAnimatianByObj(main_panel , 2)
	local main_container  = main_panel:getChildByName("main_container")

	local content_label = main_container:getChildByName("content_label")
	local score_cost = self.model:getScoreSummonNeedCount()
	content_label:setString(string.format(TI18N("消耗%d点积分可进行积分召唤，必出5星传说英雄"), score_cost))
	local tips_label = main_container:getChildByName("tips_label")
	local vip_limit_lv = 3
	if Config.RecruitData.data_partnersummon_const.recruit_vip then
		vip_limit_lv = Config.RecruitData.data_partnersummon_const.recruit_vip.val or vip_limit_lv
	end
	self.vip_limit_lv = vip_limit_lv
	tips_label:setString(string.format(TI18N("（VIP%d方可召唤）"), vip_limit_lv))

	-- 英雄图标
	if not self.item_node then
		self.item_node = BackPackItem.new(false, false, false)
		self.item_node:setPosition(cc.p(290, 80))
		self.item_node:setBaseData(29999)
		main_container:addChild(self.item_node)
	end

	local title_container = main_panel:getChildByName("title_container")
	local title_label = title_container:getChildByName("title_label")
	title_label:setString(TI18N("积分召唤"))

	self.close_btn = main_panel:getChildByName("close_btn")
	self.ok_btn = main_panel:getChildByName("ok_btn")
	self.ok_btn_label = self.ok_btn:getChildByName("label")
	self.ok_btn_label:setString(TI18N("召唤"))
end

function PartnerSummonScoreWindow:register_event(  )
	registerButtonEventListener(self.close_btn, handler(self, self._onClickCloseBtn), false, 2)
	registerButtonEventListener(self.ok_btn, handler(self, self._onClickOkBtn), true)
end

function PartnerSummonScoreWindow:_onClickCloseBtn(  )
	self.ctrl:openPartnerSummonScoreWindow(false)
end

function PartnerSummonScoreWindow:_onClickOkBtn(  )
	self.ctrl:send23201(PartnersummonConst.Summon_Type.Score, 1, 3)
end

-- 刷新召唤按钮状态
function PartnerSummonScoreWindow:refreshBtnStatus(  )
	local role_vo = RoleController:getInstance():getRoleVo()
	local cur_score = role_vo.recruit_hero
    local max_score = self.model:getScoreSummonNeedCount()
    if cur_score >= max_score and role_vo.vip_lev >= self.vip_limit_lv then
    	setChildUnEnabled(false, self.ok_btn)
    	self.ok_btn:setTouchEnabled(true)
    else
    	setChildUnEnabled(true, self.ok_btn)
    	self.ok_btn:setTouchEnabled(false)
	    self.ok_btn_label:disableEffect(cc.LabelEffect.OUTLINE)
    end
end

function PartnerSummonScoreWindow:openRootWnd(  )
	self:refreshBtnStatus()
end

function PartnerSummonScoreWindow:close_callback(  )
	if self.item_node then
		self.item_node:DeleteMe()
		self.item_node = nil
	end
	self.ctrl:openPartnerSummonScoreWindow(false)
end
