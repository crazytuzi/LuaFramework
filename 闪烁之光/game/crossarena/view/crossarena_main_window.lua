--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-04-30 16:31:49
-- @description    : 
		-- 跨服战场主界面
---------------------------------
local _controller = CrossarenaController:getInstance()
local _model = _controller:getModel()

CrossareanMainWindow = CrossareanMainWindow or BaseClass(BaseView)

function CrossareanMainWindow:__init()
    self.is_full_screen = true
    self.layout_name = "crossarena/crossarena_main_window"
    self.win_type = WinType.Full  
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("crossarena","crossarena"), type = ResourcesType.plist },
        { path = PathTool.getPlistImgForDownLoad("bigbg","bigbg_87", true), type = ResourcesType.single },
    }

    self.tab_list = {}
    self.panel_list = {}
end

function CrossareanMainWindow:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
    self.background:loadTexture(PathTool.getPlistImgForDownLoad("bigbg","bigbg_87",true), LOADTEXT_TYPE)
    self.background:setScale(display.getMaxScale())

	local main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(main_container, 1)

	self.view_panel = main_container:getChildByName("view_panel")

	local top_panel = main_container:getChildByName("top_panel")

	self.btn_rule = top_panel:getChildByName("btn_rule")
	self.btn_rank = top_panel:getChildByName("btn_rank")
	self.btn_rank:getChildByName("label"):setString(TI18N("排行榜"))
	self.btn_shop = top_panel:getChildByName("btn_shop")
	self.btn_shop:getChildByName("label"):setString(TI18N("声望商店"))
	self.btn_award = top_panel:getChildByName("btn_award")
	self.btn_award:getChildByName("label"):setString(TI18N("排名奖励"))
	self.btn_record = top_panel:getChildByName("btn_record")
	self.btn_record:getChildByName("label"):setString(TI18N("挑战记录"))
	self.btn_defend = top_panel:getChildByName("btn_defend")
	self.btn_defend:getChildByName("label"):setString(TI18N("防守阵容"))
	self.close_btn = main_container:getChildByName("close_btn")

	local tab_container = top_panel:getChildByName("tab_container")
	for i=1,2 do
		local tab_btn = tab_container:getChildByName("tab_btn_" .. i)
		if tab_btn then
			local object = {}
            object.select_bg = tab_btn:getChildByName('select_bg')
            object.select_bg:setVisible(true)
            object.unselect_bg = tab_btn:getChildByName('unselect_bg')
            object.tab_btn = tab_btn
            object.index = i
            self.tab_list[i] = object
		end
	end

	-- 适配
	local top_off = display.getTop(main_container)
	local bottom_off = display.getBottom(main_container)
	top_panel:setPositionY(top_off)
	self.close_btn:setPositionY(bottom_off+147)
end

function CrossareanMainWindow:register_event(  )
	-- 关闭
	registerButtonEventListener(self.close_btn, function (  )
		_controller:openCrossarenaMainWindow(false)
	end, true, 2)

	-- 规则说明
	registerButtonEventListener(self.btn_rule, function (  )
		MainuiController:getInstance():openCommonExplainView(true, Config.ArenaClusterData.data_explain)
	end, true)

	-- 排行榜
	registerButtonEventListener(self.btn_rank, function (  )
		_controller:openCrossarenaRankWindow(true)
	end, true)

	-- 声望商店
	registerButtonEventListener(self.btn_shop, function (  )
		_controller:openCrossarenaShopWindow(true)
	end, true)

	-- 排名奖励
	registerButtonEventListener(self.btn_award, function (  )
		_controller:openCrossarenaAwardWindow(true)
	end, true)
	
	-- 挑战记录
	registerButtonEventListener(self.btn_record, function (  )
		_controller:openCrossarenaVideoWindow(true)
	end, true)

	-- 防守阵容
	registerButtonEventListener(self.btn_defend, function (  )
		HeroController:getInstance():openFormGoFightPanel(true, PartnerConst.Fun_Form.CrossArenaDef, {}, HeroConst.FormShowType.eFormSave)
	end, true)

	-- tab按钮
	for k, object in pairs(self.tab_list) do
        if object.tab_btn then
            object.tab_btn:addTouchEventListener(function(sender, event_type)
                if event_type == ccui.TouchEventType.ended then
                    playTabButtonSound()
                    self:changeSelectedTab(object.index)
                end
            end)
        end
    end

    -- 跨服竞技场红点
	self:addGlobalEvent(CrossarenaEvent.Update_Red_Status_Event, function (  )
		self:updateRedStatusShow()
	end)
end

function CrossareanMainWindow:updateRedStatusShow(  )
	-- 点赞红点
	local like_red_status = _model:getCrossarenaRedStatus(CrossarenaConst.Red_Index.Like)
	if self.tab_list[2] and self.tab_list[2].tab_btn then
		addRedPointToNodeByStatus(self.tab_list[2].tab_btn, like_red_status)
	end

	-- 挑战记录红点
	local recred_red_status = _model:getCrossarenaRedStatus(CrossarenaConst.Red_Index.Record)
	if self.btn_record then
		addRedPointToNodeByStatus(self.btn_record, recred_red_status)
	end
end

-- 切换标签页
function CrossareanMainWindow:changeSelectedTab( index )
	if self.tab_object ~= nil and self.tab_object.index == index then return end
    if self.tab_object then
        self.tab_object.select_bg:setVisible(true)
        self.tab_object = nil
    end
    self.tab_object = self.tab_list[index]
    if self.tab_object then
        self.tab_object.select_bg:setVisible(false)
    end

    if self.select_panel then
		self.select_panel:setVisibleStatus(false)
		self.select_panel = nil
	end

	self.select_panel = self.panel_list[index]
	if self.select_panel == nil then
		if index == CrossarenaConst.Sub_Type.Challenge then
			self.select_panel = CrossarenaChallengePanel.New(self.view_panel)
		elseif index == CrossarenaConst.Sub_Type.Honour then
            self.select_panel = CrossarenaHonourPanel.New(self.view_panel)
		end

        if self.select_panel then
		    self.panel_list[index] = self.select_panel
        end
	end
    if self.select_panel then
	    self.select_panel:setVisibleStatus(true)
    end

    self.btn_defend:setVisible(index == CrossarenaConst.Sub_Type.Challenge)
    self.btn_record:setVisible(index == CrossarenaConst.Sub_Type.Challenge)
end

function CrossareanMainWindow:openRootWnd( sub_type )
	sub_type = sub_type or self:getDefaultSubType()
	self:changeSelectedTab(sub_type)
	self:updateRedStatusShow()
	-- 进入跨服竞技场，则去掉活动开启的红点
	_model:updateCrossarenaRedStatus(CrossarenaConst.Red_Index.Open, false)
end

function CrossareanMainWindow:getDefaultSubType(  )
	local cur_status = _model:getCrossarenaStatus()
	if cur_status == CrossarenaConst.Open_Status.Open then
		return CrossarenaConst.Sub_Type.Challenge
	else
		return CrossarenaConst.Sub_Type.Honour
	end
end

function CrossareanMainWindow:close_callback(  )
	for k,v in pairs(self.panel_list) do
		v:DeleteMe()
		v = nil
	end
	_controller:openCrossarenaMainWindow(false)
end