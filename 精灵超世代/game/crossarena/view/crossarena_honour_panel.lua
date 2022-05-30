--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-05-08 15:37:53
-- @description    : 
		-- 跨服竞技场 赛季荣耀
---------------------------------
local _controller = CrossarenaController:getInstance()
local _model = _controller:getModel()
local _table_insert = table.insert

CrossarenaHonourPanel = CrossarenaHonourPanel or BaseClass()

function CrossarenaHonourPanel:__init(parent)
    self.is_init = true
    self.parent = parent
    self:createRoorWnd()
    self:registerEvent()

    self.role_item_list = {}
    print("time",TimeTool.getYMDHMS(GameNet:getInstance():getTime()))
end

function CrossarenaHonourPanel:createRoorWnd(  )
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("crossarena/crossarena_honour_panel"))
    if not tolua.isnull(self.parent) then
        self.parent:addChild(self.root_wnd)
    end

    self.container = self.root_wnd:getChildByName("container")

    local bottom_panel = self.container:getChildByName("bottom_panel")

    bottom_panel:getChildByName("like_tips"):setString(TI18N("每日点赞可获点赞奖励"))
    bottom_panel:getChildByName("title_my_rank"):setString(TI18N("当前排名:"))
    self.txt_my_rank = bottom_panel:getChildByName("txt_my_rank")
    self.title_max_rank = bottom_panel:getChildByName("title_max_rank")
    self.title_max_rank:setString(TI18N("历史最高排名:"))
    self.txt_max_rank = bottom_panel:getChildByName("txt_max_rank")
    self.txt_max_rank:setPositionX(self.title_max_rank:getPositionX() + self.title_max_rank:getContentSize().width + 31)
    bottom_panel:getChildByName("title_award"):setString(TI18N("当前排名可获得以下赛季结算奖励:"))

    if not self.check_award_txt then
    	self.check_award_txt = createRichLabel(24, 1, cc.p(0.5, 0.5), cc.p(558, 348))
    	self.check_award_txt:setString(string.format(TI18N("<img src='%s' scale=1 /><div href=xxx fontcolor=#0cff01 >奖励预览</div>"), PathTool.getResFrame("common", "common_1093")))
    	bottom_panel:addChild(self.check_award_txt)
    	local function clickLinkCallBack( _type, value )
    		if _type == "href" then
    			_controller:openCrossarenaAwardWindow(true)
    		end
    	end
    	self.check_award_txt:addTouchLinkListener(clickLinkCallBack,{"href"})
    end

    local award_list = bottom_panel:getChildByName("award_list")
    local scroll_view_size = award_list:getContentSize()
    local scale = 0.8
    local setting = {
        item_class = BackPackItem,      -- 单元类
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 10,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 0,                   -- y方向的间隔
        item_width = BackPackItem.Width*scale,               -- 单元的尺寸width
        item_height = BackPackItem.Height*scale,              -- 单元的尺寸height
        row = 1,                        -- 行数，作用于水平滚动类型
        col = 0,                         -- 列数，作用于垂直滚动类型
        scale = scale
    }
    self.good_scrollview = CommonScrollViewLayout.new(award_list, cc.p(0,0) , ScrollViewDir.horizontal, ScrollViewStartPos.top, scroll_view_size, setting)
    self.good_scrollview:setSwallowTouches(false)

    -- 适配
    local bottom_off = display.getBottom(main_container)
    bottom_panel:setPositionY(bottom_off)
end

function CrossarenaHonourPanel:registerEvent(  )
    -- 个人信息
    if not self.update_my_info_event then
        self.update_my_info_event = GlobalEvent:getInstance():Bind(CrossarenaEvent.Update_MyBaseInfo_Event, function ( )
            self:updateMyselfInfo()
        end)
    end

    -- 赛季荣耀数据
    if not self.update_honour_data_event then
        self.update_honour_data_event = GlobalEvent:getInstance():Bind(CrossarenaEvent.Update_Honour_Data_Event, function ( )
            self:updateRoleItemList()
        end)
    end
end

function CrossarenaHonourPanel:setVisibleStatus( status )
	if not tolua.isnull(self.root_wnd) then
        self.root_wnd:setVisible(status)
    end

    if status == true and self.is_init == true then
        self.is_init = false
        -- 初次打开
        self:updateMyselfInfo()
        _controller:sender25614() -- 请求赛季荣耀数据
    end
end

-- 创建宝可梦列表
function CrossarenaHonourPanel:updateRoleItemList(  )
    local honour_role_data = _model:getHonourRoleData()

    local function _getItemRoleData( index )
        for k,v in pairs(honour_role_data) do
            if (index == 1 and v.rank == 2) or (index == 2 and v.rank == 1) or (index == 3 and v.rank == 3) then
                return v
            end
        end
    end

    for i=1,3 do
        delayRun(self.container, i / display.DEFAULT_FPS, function ()
            local data = _getItemRoleData(i)
            local role_item = self.role_item_list[i]
            if not role_item then
                role_item = CrossareanHonourItem.New(self.container)
                self.role_item_list[i] = role_item
            end
            role_item:setData(data, i)
        end)
    end
end

-- 玩家信息
function CrossarenaHonourPanel:updateMyselfInfo(  )
    local myBaseInfo = _model:getCrossarenaMyBaseInfo()

    -- 当前排名
    if not myBaseInfo.rank or myBaseInfo.rank == 0 then
        self.txt_my_rank:setString(TI18N("暂无排名"))
    else
        self.txt_my_rank:setString(myBaseInfo.rank)
    end

    -- 历史最高排名
    if not myBaseInfo.max_rank or myBaseInfo.max_rank == 0 then
        self.txt_max_rank:setString(TI18N("暂无排名"))
    else
        self.txt_max_rank:setString(myBaseInfo.max_rank)
    end

    -- 排名奖励
    local award_cfg = _model:getCrossarenaRankAward(myBaseInfo.rank or 0)
    local award_data = {}
    for i,v in ipairs(award_cfg or {}) do
        local bid = v[1]
        local num = v[2]
        local vo = deepCopy(Config.ItemData.data_get_data(bid))
        vo.quantity = num
        _table_insert(award_data, vo)
    end
    self.good_scrollview:setData(award_data)
    self.good_scrollview:addEndCallBack(function ()
        local list = self.good_scrollview:getItemList()
        for k,v in pairs(list) do
            v:setDefaultTip()
        end
    end)
end

function CrossarenaHonourPanel:__delete()
    for k,v in pairs(self.role_item_list) do
        v:DeleteMe()
        v = nil
    end
    if self.update_my_info_event then
        GlobalEvent:getInstance():UnBind(self.update_my_info_event)
        self.update_my_info_event = nil
    end
    if self.update_honour_data_event then
        GlobalEvent:getInstance():UnBind(self.update_honour_data_event)
        self.update_honour_data_event = nil
    end
    if self.good_scrollview then
        self.good_scrollview:DeleteMe()
        self.good_scrollview = nil
    end
end