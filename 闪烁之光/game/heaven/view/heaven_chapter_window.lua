--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-04-12 15:16:41
-- @description    : 
		-- 天界副本章节界面
---------------------------------
local _controller = HeavenController:getInstance()
local _model = _controller:getModel()
local _table_insert = table.insert
local _string_format = string.format
local _table_sort = table.sort

HeavenChapterWindow = HeavenChapterWindow or BaseClass(BaseView)

function HeavenChapterWindow:__init()
    self.is_full_screen = true
    self.layout_name = "heaven/heaven_chapter_window"
    self.win_type = WinType.Full  
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("heaven","heaven"), type = ResourcesType.plist },
        { path = PathTool.getPlistImgForDownLoad("bigbg","bigbg_84", true), type = ResourcesType.single },
    }

    self.star_list = {}
    self.desc_list = {}
    self.customs_item_list = {}
    self.line_node_list = {}
    self.award_box_list = {}
    self.award_item_list = {}
    self.show_customs_num = 0 -- 当前显示的关卡数量
    self.boss_item_list = {}
end

function HeavenChapterWindow:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
    --self.background:loadTexture(PathTool.getPlistImgForDownLoad("bigbg","bigbg_84",true), LOADTEXT_TYPE)
    self.background:setScale(display.getMaxScale())

    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container, 1)

    self.customs_panel = self.main_container:getChildByName("customs_panel")

    local top_panel = self.main_container:getChildByName("top_panel")
    self.arrow_left = top_panel:getChildByName("arrow_left")
    self.arrow_right = top_panel:getChildByName("arrow_right")
    self.wnd_title = top_panel:getChildByName("wnd_title")
    self.btn_rule = top_panel:getChildByName("btn_rule")

    self.award_panel = self.main_container:getChildByName("award_panel")
    local progress_bg = self.award_panel:getChildByName("progress_bg")
    self.progress = progress_bg:getChildByName("progress")
    self.progress:setScale9Enabled(true)
    self.progress:setPercent(0)
    self.star_count = self.award_panel:getChildByName("star_count")

    local bottom_panel = self.main_container:getChildByName("bottom_panel")
    self.bottom_panel = bottom_panel
    self.image_bust = bottom_panel:getChildByName("image_bust")
    self.image_bust:ignoreContentAdaptWithSize(true)
    self.first_sp = bottom_panel:getChildByName("first_sp")
    self.btn_check = bottom_panel:getChildByName("btn_check")
    self.btn_check:setVisible(false)
    self.add_btn = bottom_panel:getChildByName("add_btn")
    self.challenge_btn = bottom_panel:getChildByName("challenge_btn")
    self.challenge_btn:getChildByName("label"):setString(TI18N("挑战"))
    self.sweep_btn = bottom_panel:getChildByName("sweep_btn")
    self.sweep_btn:getChildByName("label"):setString(TI18N("扫荡"))
    self.customs_num = bottom_panel:getChildByName("customs_num")
    self.power_txt = bottom_panel:getChildByName("power_txt")
    self.count_label = bottom_panel:getChildByName("count_label")
    bottom_panel:getChildByName("count_title"):setString(TI18N("挑战次数:"))

    for i=1,3 do
        local star = bottom_panel:getChildByName("star_" .. i)
        if star then
            star:setVisible(false)
            _table_insert(self.star_list, star)
        end
    end
    for i=1,3 do
        local desc_txt = bottom_panel:getChildByName("star_desc_" .. i)
        if desc_txt then
            desc_txt:setString("")
            _table_insert(self.desc_list, desc_txt)
        end
    end

    local award_list = bottom_panel:getChildByName("award_list")
    local bgSize = award_list:getContentSize()
    local scroll_view_size = cc.size(bgSize.width, bgSize.height)
    local scale = 0.6
    local setting = {
        item_class = BackPackItem,      -- 单元类
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 5,                    -- x方向的间隔
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
    
    self.close_btn = self.main_container:getChildByName("close_btn")

    -- 适配
    local top_off = display.getTop(self.main_container)
    local bottom_off = display.getBottom(self.main_container)
    top_panel:setPositionY(top_off - 158)
    self.award_panel:setPositionY(top_off - 238)
    bottom_panel:setPositionY(bottom_off+110)
    self.close_btn:setPositionY(bottom_off+150)
end

function HeavenChapterWindow:register_event(  )
	registerButtonEventListener(self.close_btn, function (  )
        _controller:openHeavenChapterWindow(false)
    end, true, 2)

    -- 规则说明
    registerButtonEventListener(self.btn_rule, function ( param, sender, event_type )
        local rule_cfg = Config.DungeonHeavenData.data_const["dunheaven_rule"]
        if rule_cfg then
            TipsManager:getInstance():showCommonTips(rule_cfg.desc, sender:getTouchBeganPosition())
        end
    end, true)

    registerButtonEventListener(self.arrow_left, function (  )
        self:onClickLeftArrow()
    end, true)

    registerButtonEventListener(self.arrow_right, function (  )
        self:onClickRightArrow()
    end, true)

    registerButtonEventListener(self.btn_check, function (  )
        self:onClickCheckBtn()
    end, true)

    registerButtonEventListener(self.add_btn, function (  )
        self:onClickAddCountBtn()
    end, true)

    registerButtonEventListener(self.challenge_btn, function ( )
        self:onClickChallengeBtn()
    end, true)

    registerButtonEventListener(self.sweep_btn, function ( )
        self:onClickSweepBtn()
    end, true)

    -- 挑战次数更新
    self:addGlobalEvent(HeavenEvent.Update_Chapter_Count_Event, function (  )
        self:updateChallengeCount()
        self:updateLeftBuyCount()
    end)

    -- 章节关卡数据
    self:addGlobalEvent(HeavenEvent.Update_Chapter_Basedata_Event, function (  )
        self:updateCustomsList()
        self:updateStarAwardInfo()
        self:updateCustomsInfo(self.cur_customs_cfg)
        self:updateArrowBtnStatus()
    end)

    -- 领取章节奖励
    self:addGlobalEvent(HeavenEvent.Get_Chapter_Award_Event, function (  )
        for k,v in pairs(self.award_box_list) do
            v:updateEffectStatus()
        end
    end)
end

function HeavenChapterWindow:onClickLeftArrow(  )
    if self.chapter_id and _model:checkHeavenChapterIsOpen(self.chapter_id - 1) then
        self.chapter_id = self.chapter_id - 1
        self:setData()
        if not _model:checkIsHaveCustomsCache(self.chapter_id) then
            _controller:sender25201(self.chapter_id)
        end     
    end
end

function HeavenChapterWindow:onClickRightArrow(  )
    if self.chapter_id and _model:checkHeavenChapterIsOpen(self.chapter_id + 1) then
        self.chapter_id = self.chapter_id + 1
        self:setData()
        if not _model:checkIsHaveCustomsCache(self.chapter_id) then
            _controller:sender25201(self.chapter_id)
        end     
    end
end

-- 查看怪物
function HeavenChapterWindow:onClickCheckBtn(  )
    self:showCustomsBossList()
end

-- 增加购买次数
function HeavenChapterWindow:onClickAddCountBtn( )
    local max_count_cfg = Config.DungeonHeavenData.data_const["refresh_number"]
    if not max_count_cfg then return end
    local left_challenge_num = _model:getLeftChallengeCount()
    if left_challenge_num >= max_count_cfg.val then
        message(TI18N("当前挑战次数已满"))
        return
    end

    local buy_num = _model:getTodayBuyCount()
    local buy_cfg = Config.DungeonHeavenData.data_count_buy[buy_num+1]
    if buy_cfg then
        local role_vo = RoleController:getInstance():getRoleVo()
        if buy_cfg.limit_vip <= role_vo.vip_lev then
            local str = string.format(TI18N("是否消耗<img src=%s visible=true scale=0.3 />%d购买一次挑战次数？"), PathTool.getItemRes(3), buy_cfg.cost)                  
            CommonAlert.show( str, TI18N("确定"), function()
                _controller:sender25207()
            end, TI18N("取消"), nil, CommonAlert.type.rich)
        else
            message(TI18N("提升VIP等级可增加购买次数"))
        end
    else
        message(TI18N("今日购买次数已用完"))
    end
end

-- 挑战
function HeavenChapterWindow:onClickChallengeBtn(  )
    --[[if _model:getLeftChallengeCount() <= 0 then
        message(TI18N("挑战次数不足"))
        return
    end--]]
    if self.cur_customs_cfg then
        if self.cur_customs_cfg.type == 1 then -- BOSS关
            HeroController:getInstance():openFormGoFightPanel(true, PartnerConst.Fun_Form.HeavenBoss, {chapter_id = self.cur_customs_cfg.id, customs_id = self.cur_customs_cfg.order_id})
        else
            HeroController:getInstance():openFormGoFightPanel(true, PartnerConst.Fun_Form.Heaven, {chapter_id = self.cur_customs_cfg.id, customs_id = self.cur_customs_cfg.order_id})
        end
    end
end

-- 扫荡
function HeavenChapterWindow:onClickSweepBtn(  )
    if self.cur_customs_cfg then
         _controller:checkHeavenSweep(self.cur_customs_cfg.id, self.cur_customs_cfg.order_id)
    end
end

function HeavenChapterWindow:openRootWnd( chapter_id )
	self.chapter_id = chapter_id
    self:setData()
    if not _model:checkIsHaveCustomsCache(chapter_id) then
        _controller:sender25201(chapter_id)
    end
end

function HeavenChapterWindow:setData(  )
    if not self.chapter_id then return end

    self.cur_customs_cfg = nil

    -- 章节数据
    self.chapter_cfg = Config.DungeonHeavenData.data_chapter[self.chapter_id]
    -- 关卡数据
    self.customs_cfg = Config.DungeonHeavenData.data_customs[self.chapter_id]
    if not self.chapter_cfg or not self.customs_cfg then return end

    self.wnd_title:setString(self.chapter_cfg.type)

    -- 背景地图
    if self.chapter_cfg.map_id and self.chapter_cfg.map_id ~= 0 and self.background then
        local map_res = PathTool.getPlistImgForDownLoad("bigbg", _string_format("bigbg_" .. self.chapter_cfg.map_id), true)
        self.map_load = loadImageTextureFromCDN(self.background, map_res, ResourcesType.single, self.map_load)
    end

    for k,v in pairs(self.line_node_list) do
        v:setVisible(false)
    end
    self:updateChallengeCount()
    self:updateLeftBuyCount()
    self:updateBossBust()
    self:updateCustomsList(true)
    self:updateArrowBtnStatus()
    self:updateStarAwardInfo()
end

-- 关卡列表
function HeavenChapterWindow:updateCustomsList( force )
    if not self.customs_cfg or not self.chapter_cfg then return end

    -- 所有可以挑战的关卡数据
    local all_customs_list = _model:getAllCanShowCustomsDataById(self.chapter_cfg.id)
    if not force and self.show_customs_num == #all_customs_list then -- 如果数量没有变化，就不必进行刷新（item内会监听各自的刷新事件）
        return
    end

    -- self.main_container:stopAllActions()
    for k,v in pairs(self.customs_item_list) do
        v:setVisible(false)
    end

    self.all_customs_vo = all_customs_list
    self.show_customs_num = #all_customs_list
    local pos_list = Config.DungeonHeavenData.data_customs_pos[self.chapter_cfg.pos_id]
    if pos_list then
        local default_id = self:getDefaultChoseCustomsId()
        for i,customs_vo in ipairs(self.all_customs_vo) do
            delayRun(self.customs_panel, i / display.DEFAULT_FPS, function()
                local customs_item = self.customs_item_list[i]
                if not customs_item then
                    customs_item = HeavenCustomsItem.new(handler(self, self._onClickCustomsItem))
                    self.customs_panel:addChild(customs_item, 1)
                    self.customs_item_list[i] = customs_item
                end
                local pos_data = pos_list[customs_vo.id]
                if pos_data then
                    local pos_x = pos_data.pos[1] or 0
                    local pos_y = pos_data.pos[2] or 0
                    customs_item:setPosition(cc.p(pos_x, pos_y))
                end
                customs_item:setVisible(true)
                local cfg_data = self.customs_cfg[customs_vo.id]
                customs_item:setData(customs_vo, cfg_data)
                if default_id == customs_vo.id then -- 默认选中最后一个关卡
                    self:_onClickCustomsItem(customs_item)
                end
            end)
        end
    end

    self:updateLineList(pos_list)
end

-- 获取默认选中的关卡id
function HeavenChapterWindow:getDefaultChoseCustomsId(  )
    local customs_id = 1
    for k,customs_vo in pairs(self.all_customs_vo or {}) do
        if customs_vo.id > customs_id then
            customs_id = customs_vo.id
        end
    end
    return customs_id
end

function HeavenChapterWindow:_onClickCustomsItem( item_node )
    if self.cur_customs_cfg and self.cur_customs_cfg.order_id == item_node:getCustomsId() then return end
    if self.cur_item_node then
        self.cur_item_node:setSelected(false)
    end
    item_node:setSelected(true)
    self.cur_item_node = item_node

    local cus_cfg_data = item_node:getData()
    self:updateCustomsInfo(cus_cfg_data)
end

-- 底部关卡信息
function HeavenChapterWindow:updateCustomsInfo( cus_cfg_data )
    if not cus_cfg_data then return end
    self.cur_customs_cfg = cus_cfg_data
    local customs_vo = _model:getCustomsDataById(cus_cfg_data.id, cus_cfg_data.order_id)

    local show_award_data = {}
    if customs_vo and customs_vo.state == 2 then
        show_award_data = cus_cfg_data.show_award
        loadSpriteTexture(self.first_sp, PathTool.getResFrame("heaven", "txt_cn_heaven_award"), LOADTEXT_TYPE_PLIST)
    else
        show_award_data = cus_cfg_data.f_show_award
        loadSpriteTexture(self.first_sp, PathTool.getResFrame("heaven", "txt_cn_heaven_first"), LOADTEXT_TYPE_PLIST)
    end

    if customs_vo and customs_vo.star == 3 then
        self.challenge_btn:setVisible(false)
        self.sweep_btn:setVisible(true)
    else
        self.challenge_btn:setVisible(true)
        self.sweep_btn:setVisible(false)
    end

    self.customs_num:setString(_string_format(TI18N("第%d关"), cus_cfg_data.order_id))
    self.power_txt:setString(_string_format(TI18N("推荐战力:%d"), cus_cfg_data.power))

    -- 是否为boss
    self.btn_check:setVisible(cus_cfg_data.type == 1)

    for k,v in pairs(self.desc_list) do
        v:setString("")
    end
    for k,v in pairs(self.star_list) do
        v:setVisible(false)
    end
    for i,v in ipairs(cus_cfg_data.cond_info or {}) do
        local star_id = v[1]
        local con_id = v[2]
        local desc_txt = self.desc_list[i]
        local con_cfg = Config.DungeonHeavenData.data_star_cond[con_id]
        if desc_txt and con_cfg then
            desc_txt:setString(con_cfg.type)
        end
        local star = self.star_list[i]
        if star and customs_vo then
            local star_status = 0
            for k,v in pairs(customs_vo.star_info) do
                if v.star_id == star_id then
                    star_status = v.flag
                end
            end
            star:setVisible(star_status == 1)
        end
    end

    -- 奖励
    local award_data = {}
    for i,v in ipairs(show_award_data) do
        local bid = v[1]
        local num = v[2]
        local vo = deepCopy(Config.ItemData.data_get_data(bid))
        vo.quantity = num
        _table_insert(award_data, vo)
    end
    self.good_scrollview:setData(award_data)
    self.good_scrollview:addEndCallBack(function ()
        local list = self.good_scrollview:getItemList()
        local book_id_cfg = Config.DungeonHeavenData.data_const["heaven_handbook"]
        for k,v in pairs(list) do
            local iData = v:getData()
            local is_special
            if iData and book_id_cfg then
                for n,m in pairs(book_id_cfg.val) do
                    if m == iData.id then
                        is_special = 2
                        break
                    end
                end
            end
            v:setDefaultTip(true, nil, nil, is_special)
        end
    end)
end

-- 连接线
function HeavenChapterWindow:updateLineList( pos_list )
    if not self.all_customs_vo or not pos_list then return end
    local line_num = #self.all_customs_vo - 1
    if line_num < 1 then return end
    for k,v in pairs(self.line_node_list) do
        v:setVisible(false)
    end
    local temp_index = 1   
    for i=1,line_num do
        local pos_data = pos_list[i]
        if pos_data then
            local bezier_pos_data = {}
            local start_x = pos_data.start_pos[1]
            local start_y = pos_data.start_pos[2]
            local end_x = pos_data.end_pos[1]
            local end_y = pos_data.end_pos[2]
            _table_insert(bezier_pos_data, cc.p(start_x, start_y))
            if pos_data.bessel_pos_1 and next(pos_data.bessel_pos_1) ~= nil then
                _table_insert(bezier_pos_data, cc.p(pos_data.bessel_pos_1[1], pos_data.bessel_pos_1[2]))
            end
            if pos_data.bessel_pos_2 and next(pos_data.bessel_pos_2) ~= nil then
                _table_insert(bezier_pos_data, cc.p(pos_data.bessel_pos_2[1], pos_data.bessel_pos_2[2]))
            end
            _table_insert(bezier_pos_data, cc.p(end_x, end_y))

            local distance = math.sqrt(math.pow(end_x-start_x, 2) + math.pow(end_y-start_y, 2))
            local add_value = 1/(distance/30)

            local show_pos_list = {}
            local time = 0
            while time < 1 do
                local pos = self:getBezierPos(bezier_pos_data, time)
                table.insert(show_pos_list, pos)
                time = time + add_value
            end

            for i,pos in ipairs(show_pos_list) do
                local node = self.line_node_list[temp_index]
                if not node then
                    node = createSprite(PathTool.getResFrame("heaven","heaven_1013"), pos.x, pos.y, self.customs_panel, cc.p(0.5, 0.5))
                    self.line_node_list[temp_index] = node
                end
                node:setPosition(pos)
                node:setVisible(true)
                temp_index = temp_index + 1
            end
        end
    end
end

function HeavenChapterWindow:factorial(n)
    if n == 0 then
        return 1
    else
        return n * self:factorial(n - 1)
    end
end 

function HeavenChapterWindow:getBezierPos(posData,t)
    local n = #posData -1
    local x = 0
    local y = 0
    for idx,pos in pairs(posData) do 
        x = x + pos.x *(self:factorial(n)/(self:factorial(n-idx+1)*self:factorial(idx-1))) * math.pow(1-t,n-idx+1) * math.pow(t,idx-1)
        y = y + pos.y *(self:factorial(n)/(self:factorial(n-idx+1)*self:factorial(idx-1))) * math.pow(1-t,n-idx+1) * math.pow(t,idx-1)
    end
    return cc.p(x,y)
end

-- 翻页箭头按钮状态
function HeavenChapterWindow:updateArrowBtnStatus(  )
    if self.chapter_id then
        local left_is_open = _model:checkHeavenChapterIsOpen(self.chapter_id - 1)
        local right_is_open = _model:checkHeavenChapterIsOpen(self.chapter_id + 1)
        self.arrow_left:setVisible(left_is_open)
        self.arrow_right:setVisible(right_is_open)
    else
        self.arrow_left:setVisible(false)
        self.arrow_right:setVisible(false)
    end
end

-- 挑战次数
function HeavenChapterWindow:updateChallengeCount(  )
    local max_num_cfg = Config.DungeonHeavenData.data_const["refresh_number"]
    if max_num_cfg then
        local left_num = _model:getLeftChallengeCount()
        self.count_label:setString(left_num .. "/" .. max_num_cfg.val)
    end
end

-- 更新今日剩余购买次数
function HeavenChapterWindow:updateLeftBuyCount(  )
    if not self.left_buy_count then
        self.left_buy_count = createRichLabel(20, 1, cc.p(0.5, 0.5), cc.p(590, 6))
        self.bottom_panel:addChild(self.left_buy_count)
    end
    local left_count = _model:getTodayLeftBuyCount()
    self.left_buy_count:setString(string.format(TI18N("<div fontcolor=#fff8bf outline=2,#000000>(剩余购买次数:</div><div fontcolor=#39e522 outline=2,#000000>%d</div><div fontcolor=#fff8bf outline=2,#000000>)</div>"), left_count))
end

-- 星级奖励
function HeavenChapterWindow:updateStarAwardInfo(  )
    if not self.chapter_id then return end
    local award_cfg = Config.DungeonHeavenData.data_star_award[self.chapter_id]
    local chapter_vo = _model:getChapterDataById(self.chapter_id)
    if not award_cfg or not chapter_vo then return end

    local cur_star = chapter_vo.all_star
    local max_star = _model:getChapterMaxStarNum(self.chapter_id)
    self.progress:setPercent(cur_star/max_star*100)
    self.star_count:setString(cur_star .. "/" .. max_star)

    for k,v in pairs(self.award_box_list) do
        v:setVisible(false)
    end

    for i,aData in ipairs(award_cfg) do
        local box_node = self.award_box_list[i]
        if not box_node then
            box_node = HeavenAwardBoxItem.new(handler(self, self._onClickShowAwardTips))
            self.award_panel:addChild(box_node)
            self.award_box_list[i] = box_node
        end
        local pos_x = (aData.limit_star/max_star)*324
        box_node:setPosition(cc.p(pos_x, 20))
        box_node:setData(aData, self.chapter_id)
        box_node:setVisible(true)
    end
end

function HeavenChapterWindow:_onClickShowAwardTips( node, data, pos )
    if not self.tips_layer then
        self.tips_layer = ccui.Layout:create()
        self.tips_layer:setContentSize(cc.size(SCREEN_WIDTH, display.height))
        self.main_container:addChild(self.tips_layer)
        self.tips_layer:setTouchEnabled(true)
        self.tips_layer:setSwallowTouches(false)
        registerButtonEventListener(self.tips_layer, function()
            self.tips_layer:setVisible(false)
        end, false, 1)
    end

    self.tips_layer:setVisible(true)
    
    if not self.tips_bg then
        self.tips_bg = createImage(self.tips_layer, PathTool.getResFrame("common","common_1056"), 0, 0, cc.p(0,0), true, 10, true)
        self.tips_bg:setTouchEnabled(true)
    end
    if self.tips_bg then
        local bg_size = cc.size(BackPackItem.Width*#data+72, BackPackItem.Height+50)
        self.tips_bg:setContentSize(bg_size)
        self.tips_bg:setAnchorPoint(cc.p(0.5, 1))
        local world_pos = node:convertToWorldSpace(cc.p(0, 0))
        local node_pos = self.main_container:convertToNodeSpace(world_pos)
        if node_pos.x - bg_size.width/2 < 0 then
            node_pos.x = 10 + bg_size.width/2
        end
        self.tips_bg:setPosition(node_pos)
    end

    for k,v in pairs(self.award_item_list) do
        v:setVisible(false)
    end
    for i,v in pairs(data) do
        local award_item = self.award_item_list[i]
        local item_config = Config.ItemData.data_get_data(v[1])
        if item_config then
            if not award_item then
                award_item = BackPackItem.new(nil,true,nil,0.8)
                self.award_item_list[i] = award_item
                award_item:setAnchorPoint(cc.p(0,0.5))
                self.tips_bg:addChild(award_item)
                award_item:setBaseData(v[1], v[2])
                award_item:setPosition(cc.p((BackPackItem.Width+18)*(i-1)+30, 95))
                award_item:setDefaultTip()
                award_item:setExtendDesc(true, item_config.name, 275)
            else
                award_item:setBaseData(v[1], v[2])
                award_item:setExtendDesc(true, item_config.name, 275)
                award_item:setPosition(cc.p((BackPackItem.Width+18)*(i-1)+30, 95))
                award_item:setVisible(true)
            end
        end
    end
end

-- 半身像
function HeavenChapterWindow:updateBossBust(  )
    if not self.chapter_cfg then return end

    if not self.bust_res or self.chapter_cfg.bust_id ~= self.bust_res then
        self.bust_res = self.chapter_cfg.bust_id -- 记录一下资源id，避免一样资源重复加载纹理
        local bust_path = PathTool.getPartnerBustRes_2( self.chapter_cfg.bust_id )
        self.bust_load = loadImageTextureFromCDN(self.image_bust, bust_path, ResourcesType.single, self.bust_load)
    end
end

-- 显示boss关卡的boss列表
function HeavenChapterWindow:showCustomsBossList(  )
    if self.cur_customs_cfg and self.cur_customs_cfg.type == 1 then
        local unit_cfg_list = {}
        for i,v in ipairs(self.cur_customs_cfg.unit_id) do
            local unit_data = Config.UnitData.data_unit(v)
            if unit_data then
                for k=1,5 do
                    local monster_id = unit_data["monster" .. k]
                    if monster_id and Config.UnitData.data_unit(monster_id) then
                        _table_insert(unit_cfg_list, Config.UnitData.data_unit(monster_id))
                    end
                end
            end
        end
        
        if not self.boss_tips_mask then
            self.boss_tips_mask = ccui.Layout:create()
            self.boss_tips_mask:setContentSize(SCREEN_WIDTH, display.height)
            self.boss_tips_mask:setPositionY(display.getBottom(self.main_container))
            self.boss_tips_mask:setTouchEnabled(true)
            self.main_container:addChild(self.boss_tips_mask, 1)
            self.boss_tips_mask:setSwallowTouches(true)
            self.boss_tips_mask:addTouchEventListener(function(sender, event_type)
                if event_type == ccui.TouchEventType.ended then
                    self.boss_tips_mask:setVisible(false)
                    self.boss_tips_show = false
                end
            end)
        end
        self.boss_tips_mask:setVisible(true)

        if not self.boss_tips_bg then
            local btn_world_pos = self.btn_check:convertToWorldSpace(cc.p(0, 0))
            local node_pos = self.main_container:convertToNodeSpace(btn_world_pos)
            self.boss_tips_bg = createImage(self.boss_tips_mask, PathTool.getResFrame("common","common_1092"), node_pos.x, node_pos.y+75, cc.p(0.5, 0), true, nil, true)
            self.boss_tips_bg:setContentSize(cc.size(576, 362))
            self.boss_tips_bg:setTouchEnabled(true)
        end
        if not self.boss_unit_bg_1 then
            self.boss_unit_bg_1 = createImage(self.boss_tips_bg, PathTool.getResFrame("common","common_90058"), 576/2, 250, cc.p(0.5, 0.5), true, nil, true)
            self.boss_unit_bg_1:setContentSize(cc.size(563, 120))
        end
        if not self.boss_team_1 then
            self.boss_team_1 = createLabel(22, cc.c3b(224, 191, 152), nil, 20, 329, TI18N("队伍一:"), self.boss_tips_bg, nil, cc.p(0, 0.5))
        end
        if not self.boss_unit_bg_2 then
            self.boss_unit_bg_2 = createImage(self.boss_tips_bg, PathTool.getResFrame("common","common_90058"), 576/2, 90, cc.p(0.5, 0.5), true, nil, true)
            self.boss_unit_bg_2:setContentSize(cc.size(563, 120))
        end
        if not self.boss_team_2 then
            self.boss_team_2 = createLabel(22, cc.c3b(224, 191, 152), nil, 20, 168, TI18N("队伍二:"), self.boss_tips_bg, nil, cc.p(0, 0.5))
        end

        for k,v in pairs(self.boss_item_list) do
            v:setVisible(false)
        end
        for i,unit_cfg in ipairs(unit_cfg_list) do
            delayRun(self.boss_tips_mask, i / display.DEFAULT_FPS, function (  )
                local boss_item = self.boss_item_list[i]
                if not boss_item then
                    boss_item = HeroExhibitionItem.new(0.8, true)
                    self.boss_tips_bg:addChild(boss_item)
                    self.boss_item_list[i] = boss_item
                end
                local hero_vo = HeroVo.New()
                hero_vo.bid = tonumber(unit_cfg.head_icon)
                hero_vo.star = unit_cfg.star
                hero_vo.camp_type = unit_cfg.camp_type
                hero_vo.lev = unit_cfg.lev
                boss_item:setData(hero_vo)
                local pos_x = 0
                local pos_y = 250
                if i > 5 then
                    pos_x = 75 + (i-6)*(HeroExhibitionItem.Width*0.8+10)
                    pos_y = 90
                else
                    pos_x = 75 + (i-1)*(HeroExhibitionItem.Width*0.8+10)
                end
                boss_item:setPosition(cc.p(pos_x, pos_y))
                boss_item:setVisible(true)
            end)
        end
    end
end

function HeavenChapterWindow:close_callback(  )
	if self.bust_load then
        self.bust_load:DeleteMe()
        self.bust_load = nil
    end
    if self.map_load then
        self.map_load:DeleteMe()
        self.map_load = nil
    end
    for k,item in pairs(self.customs_item_list) do
        item:DeleteMe()
        item = nil
    end
    for k,v in pairs(self.award_box_list) do
        v:DeleteMe()
        v = nil
    end
    for k,v in pairs(self.award_item_list) do
        v:DeleteMe()
        v = nil
    end
    for k,v in pairs(self.boss_item_list) do
        v:DeleteMe()
        v = nil
    end
    if self.good_scrollview then
        self.good_scrollview:DeleteMe()
        self.good_scrollview = nil
    end
    if self.chapter_id then
        _model:setHeavenLastShowChapterId(self.chapter_id)
    end
	_controller:openHeavenChapterWindow(false)
end

-------------------------@ 奖励宝箱item
HeavenAwardBoxItem = class("HeavenAwardBoxItem", function()
    return ccui.Widget:create()
end)

function HeavenAwardBoxItem:ctor(call_back)
    self.call_back = call_back

    self:configUI()
    self:register_event()
end

function HeavenAwardBoxItem:configUI(  )
    self.size = cc.size(50, 50)
    self:setTouchEnabled(false)
    self:setContentSize(self.size)

    self.container = ccui.Layout:create()
    self.container:setTouchEnabled(true)
    self.container:setContentSize(self.size)
    self.container:setAnchorPoint(0.5, 0.5)
    self.container:setPosition(cc.p(self.size.width/2, self.size.height/2))
    self:addChild(self.container)
end

function HeavenAwardBoxItem:register_event(  )
    registerButtonEventListener(self.container, function ( param, sender, event_type )
        if self.award_status == 1 then
            if self.chapter_id and self.data then
                _controller:sender25215(self.chapter_id, self.data.award_id)
            end
        elseif self.data and self.call_back then
            self.call_back(self, self.data.award, sender:getTouchBeganPosition())
        end
    end)
end

function HeavenAwardBoxItem:setData( data, chapter_id )
    if not data or not chapter_id then return end

    self.data = data
    self.chapter_id = chapter_id

    if not self.star_num_txt then
        self.star_num_txt = createLabel(20, 1, cc.c3b(22, 5, 0), self.size.width/2, 5, "", self.container, 2, cc.p(0.5, 1))
    end
    self.star_num_txt:setString(data.limit_star)

    self:updateEffectStatus()
end

function HeavenAwardBoxItem:updateEffectStatus(  )
    if not self.data or not self.chapter_id then return end

    self.award_status = _model:getChapterStarAwardStatus(self.chapter_id, self.data.award_id)
    local action = PlayerAction.action_1
    if self.award_status == 1 then
        action = PlayerAction.action_2
    elseif self.award_status == 2 then
        action = PlayerAction.action_3
    end
    self:handleEffect(true, action)
end

function HeavenAwardBoxItem:handleEffect( status, action )
    if status == true then
        if not tolua.isnull(self.container) and self.box_effect == nil and self.data then
            self.box_effect = createEffectSpine(Config.EffectData.data_effect_info[self.data.effect_id], cc.p(self.size.width/2, 8), cc.p(0.5, 0.5), true, action)
            self.container:addChild(self.box_effect)
        elseif self.box_effect and (not self.cur_action_name or self.cur_action_name ~= action) then
            self.box_effect:setToSetupPose()
            self.box_effect:setAnimation(0, action, true)
        end
        self.cur_action_name = action
    else
        if self.box_effect then
            self.box_effect:clearTracks()
            self.box_effect:removeFromParent()
            self.box_effect = nil
        end
    end
end

function HeavenAwardBoxItem:DeleteMe(  )
    self:handleEffect(false)
    self:removeAllChildren()
    self:removeFromParent()
end