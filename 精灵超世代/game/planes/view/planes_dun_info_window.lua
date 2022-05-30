---------------------------------
-- @Author: htp
-- @Editor: htp
-- @date 2019/12/10 23:09:49
-- @description: 位面冒险 副本信息界面
---------------------------------
local _controller = PlanesController:getInstance()
local _model = _controller:getModel()
local _table_insert = table.insert
local _string_format = string.format

PlanesDunInfoWindow = PlanesDunInfoWindow or BaseClass(BaseView)

function PlanesDunInfoWindow:__init()
	self.win_type = WinType.Big
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.is_full_screen = false
	self.layout_name = "planes/planes_dun_info_window"

    self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("planes", "planes_info"), type = ResourcesType.plist},
	}
end

function PlanesDunInfoWindow:open_callback( )
	self.background = self.root_wnd:getChildByName("background")
	if self.background then
		self.background:setScale(display.getMaxScale())
	end

	local main_container = self.root_wnd:getChildByName("main_container")
	self.main_container = main_container

	local txt_list = {
		{"win_title", TI18N("副本信息")},
        {"first_award_txt", TI18N("首通奖励")},
		{"award_txt", TI18N("征战奖励预览")},
		{"progress_title", TI18N("当前征战进度值")},
		{"tips_txt", TI18N("在本轮征战中每通过1个选择节点、或击败守卫和首领，将提升进度值")}
	}
	setTextContentList(main_container, txt_list)

	self.dun_bg_sp = main_container:getChildByName("dun_bg_sp")
	
	self.progress_bg = main_container:getChildByName("progress_bg")
	self.progress = self.progress_bg:getChildByName("progress")
    self.progress:setPercent(0)
    self.progress_value = self.progress_bg:getChildByName("progress_value")
	self.progress_value:setString("0%")
	self.progress_size = self.progress_bg:getContentSize()
	self.progress_bar = self.progress_bg:getChildByName("progress_bar")
	self.progress_bar:setPositionX(0)

	self.close_btn = main_container:getChildByName("close_btn")
	self.btn_begin = main_container:getChildByName("btn_begin")
	-- 引导需要
	self.btn_begin:setName("guide_begin_btn")
	self.btn_begin_label = self.btn_begin:getChildByName("label")
	self.btn_begin_label:setString(TI18N("开启征战"))

	self.btn_get_award = main_container:getChildByName("btn_get_award")
	self.btn_get_award:getChildByName("label"):setString(TI18N("领取"))
	self.got_award_sp = main_container:getChildByName("got_award_sp")
	self.not_pass_txt = main_container:getChildByName("not_pass_txt")
	self.not_pass_txt:setString(TI18N("尚未首通"))

	self.name_txt = main_container:getChildByName("name_txt")
	self.time_txt = main_container:getChildByName("time_txt")

	-- 首通奖励
	local first_award_list = main_container:getChildByName("first_award_list")
	local scroll_view_size = first_award_list:getContentSize()
    local setting = {
        item_class = BackPackItem,      -- 单元类
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 10,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 0,                   -- y方向的间隔
        item_width = BackPackItem.Width*0.6,               -- 单元的尺寸width
        item_height = BackPackItem.Height*0.6,              -- 单元的尺寸height
        row = 1,                        -- 行数，作用于水平滚动类型
        col = 0,                         -- 列数，作用于垂直滚动类型
        scale = 0.6
    }
    self.first_item_scrollview = CommonScrollViewLayout.new(first_award_list, cc.p(0,0) , ScrollViewDir.horizontal, ScrollViewStartPos.top, scroll_view_size, setting)
	
	-- 冒险奖励
	local award_list = main_container:getChildByName("award_list")
	scroll_view_size = award_list:getContentSize()
    local setting = {
        item_class = BackPackItem,      -- 单元类
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 10,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 0,                   -- y方向的间隔
        item_width = BackPackItem.Width*0.6,               -- 单元的尺寸width
        item_height = BackPackItem.Height*0.6,              -- 单元的尺寸height
        row = 1,                        -- 行数，作用于水平滚动类型
        col = 0,                         -- 列数，作用于垂直滚动类型
        scale = 0.6
    }
    self.award_item_scrollview = CommonScrollViewLayout.new(award_list, cc.p(0,0) , ScrollViewDir.horizontal, ScrollViewStartPos.top, scroll_view_size, setting)
end

function PlanesDunInfoWindow:register_event( )
	registerButtonEventListener(self.background, handler(self, self.onClickCloseBtn), false, 2)
	registerButtonEventListener(self.close_btn, handler(self, self.onClickCloseBtn), true, 2)
	registerButtonEventListener(self.btn_begin, handler(self, self.onClickBeginBtn), true)
	registerButtonEventListener(self.btn_get_award, handler(self, self.onClickGetAwardBtn), true)

	-- 更新领取按钮状态
	self:addGlobalEvent(PlanesEvent.Get_First_Award_Event, function (  )
		self:updateAwardBtnStatus()
	end)
end

function PlanesDunInfoWindow:onClickCloseBtn(  )
	_controller:openPlanesDunInfoWindow(false)
end

function PlanesDunInfoWindow:onClickBeginBtn(  )
	if self.dun_id then
		_controller:sender23105(self.dun_id) -- 请求进入副本
	end
	_controller:openPlanesDunInfoWindow(false)
end

function PlanesDunInfoWindow:onClickGetAwardBtn(  )
	if self.dun_id then
		_controller:sender23117(self.dun_id)
	end
end

function PlanesDunInfoWindow:openRootWnd( dun_id )
	self.dun_id = dun_id
	self:setData()
end

function PlanesDunInfoWindow:setData(  )
	if not self.dun_id then return end
	
	local dun_cfg = Config.SecretDunData.data_dun_info[self.dun_id]
	local customs_cfg = Config.SecretDunData.data_customs[self.dun_id]
	if not dun_cfg or not customs_cfg then return end

	local cur_chose_dun_id = _model:getCurDunId() -- 当前已选择的副本id

	self.name_txt:setString(dun_cfg.name)

	if not self.desc_txt then
		self.desc_txt = createRichLabel(22, cc.c4b(238, 218, 189, 255), cc.p(0.5, 1), cc.p(340, 655), 5, nil, 580)
		self.main_container:addChild(self.desc_txt)
	end
	self.desc_txt:setString(customs_cfg.desc)

	-- 背景
	local bg_res = _string_format("resource/planes/dun_bg/dun_bg_%s.png", customs_cfg.res_id)
	self.dun_bg_load = loadSpriteTextureFromCDN(self.dun_bg_sp, bg_res, ResourcesType.single, self.dun_bg_load)

	-- 首通奖励
	local first_award = {}
	for k, v in pairs(customs_cfg.first_reward) do
		local vo = {}
		vo.bid = v[1]
		vo.quantity = v[2]
		_table_insert(first_award, vo)
	end
	self.first_item_scrollview:setData(first_award)
	self.first_item_scrollview:addEndCallBack(function()
		local list = self.first_item_scrollview:getItemList()
		for k,v in pairs(list) do
			v:setDefaultTip()
		end
	end)

	-- 冒险奖励
	local award_list = {}
	for k, v in pairs(customs_cfg.award) do
		local vo = {}
		vo.bid = v
		_table_insert(award_list, vo)
	end
	self.award_item_scrollview:setData(award_list)
	self.award_item_scrollview:addEndCallBack(function()
		local list = self.award_item_scrollview:getItemList()
		for k,v in pairs(list) do
			v:setDefaultTip()
		end
	end)

	-- 重置时间
	local less_time = _model:getResetLessTime()
	commonCountDownTime(self.time_txt, less_time, {label_type=CommonAlert.type.rich, end_title=TI18N("%s后重置")})

	-- 探索进度值
	local progerss_val, progerss_max = _model:getCurDunProgressVal()
	local percent = math.floor(progerss_val/progerss_max*100)
	if percent > 100 then
		percent = 100
	end
	self.progress_value:setString(percent .. "%")
	self.progress:setPercent(percent)
	self.progress_bar:setPositionX(self.progress_size.width*percent/100)

	if cur_chose_dun_id == 0 then
		self.btn_begin_label:setString(TI18N("开启征战"))
	else
		self.btn_begin_label:setString(TI18N("继续征战"))
	end

	self:updateAwardBtnStatus()
end

-- 领取按钮状态
function PlanesDunInfoWindow:updateAwardBtnStatus(  )
	local is_can_get = _model:checkIsCanGetAwardByDunId(self.dun_id)
	local is_got_award = _model:checkIsGetAwardByDunId(self.dun_id)
	if is_got_award then -- 已领取
		self.btn_get_award:setVisible(false)
		self.got_award_sp:setVisible(true)
		self.not_pass_txt:setVisible(false)
	elseif not is_can_get then -- 不可领取
		self.got_award_sp:setVisible(false)
		self.btn_get_award:setVisible(false)
		self.not_pass_txt:setVisible(true)
	else -- 可领取
		self.got_award_sp:setVisible(false)
		self.btn_get_award:setVisible(true)
		self.not_pass_txt:setVisible(false)
	end
end

function PlanesDunInfoWindow:close_callback( )
	if self.first_item_scrollview then
		self.first_item_scrollview:DeleteMe()
		self.first_item_scrollview = nil
	end
	if self.award_item_scrollview then
		self.award_item_scrollview:DeleteMe()
		self.award_item_scrollview = nil
	end
	if self.dun_bg_load then
		self.dun_bg_load:DeleteMe()
		self.dun_bg_load = nil
	end
	_controller:openPlanesDunInfoWindow(false)
end