---------------------------------
-- @Author: htp
-- @Editor: htp
-- @date 2019/10/19 14:12:41
-- @description: 圣夜奇境boss界面
---------------------------------
local _controller = MonopolyController:getInstance()
local _model = _controller:getModel()
local _table_insert = table.insert
local _table_sort = table.sort
local _string_format = string.format

HolynightBossWindow = HolynightBossWindow or BaseClass(BaseView)

function HolynightBossWindow:__init()
    self.win_type = WinType.Big
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.is_full_screen = false
    self.layout_name = "monopoly/holynight_boss_window"
    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("monopoly", "monopolyboss"), type = ResourcesType.plist},
    }

    self.cur_step_id = 1 -- 当前阶段id
    self.show_customs_data = {} -- boss数据
    self.mian_hero_list = {} -- 主题英雄图标

    self.role_vo = RoleController:getInstance():getRoleVo()
    self.gold_item_bid = 0 -- 糖果bid
    local gold_cfg = Config.MonopolyMapsData.data_const["monopoly_gold_id"]
    if gold_cfg then
        self.gold_item_bid = gold_cfg.val
    end
end

function HolynightBossWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background then
		self.background:setScale(display.getMaxScale())
    end

    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container , 1) 

    self.main_container:getChildByName("win_title"):setString(TI18N("挑战BOSS"))
    self.main_container:getChildByName("rank_title"):setString(TI18N("通关排行榜"))
    
    self.rule_btn = self.main_container:getChildByName("rule_btn")
    self.chapter_btn = self.main_container:getChildByName("chapter_btn")
    self.chapter_btn_arrow = self.chapter_btn:getChildByName("arrow_sp")
    self.close_btn = self.main_container:getChildByName("close_btn")
    
    self.probe_txt = self.main_container:getChildByName("probe_txt")
    self.item_num_txt = self.main_container:getChildByName("item_num_txt")
    self.chapter_name_txt = self.main_container:getChildByName("chapter_name_txt")
    self.atk_txt = self.main_container:getChildByName("atk_txt")
    self.atk_txt:setString("+0")
    self.hp_txt = self.main_container:getChildByName("hp_txt")
    self.hp_txt:setString("+0")
    self.role_info_title = self.main_container:getChildByName("role_info_title")
    self.rank_more_txt = createRichLabel(22, 1, cc.p(0.5, 0.5), cc.p(539, 754))
    self.main_container:addChild(self.rank_more_txt)
    self.rank_more_txt:setString(TI18N("<div href=checkmore fontcolor=#249112 >查看详情</div>"))
    local function clickLinkCallBack( _type, value )
        if _type == "href" then
            _controller:openMonopolyRankWindow(true, self.cur_step_id)
        end
    end
    self.rank_more_txt:addTouchLinkListener(clickLinkCallBack,{"href"})

    self.rank_name_list = {}
    for i = 1, 3 do
        local rank_name_txt = self.main_container:getChildByName("rank_name_txt_" .. i)
        if rank_name_txt then
            _table_insert(self.rank_name_list, rank_name_txt)
        end
    end

    local item_sp = self.main_container:getChildByName("item_sp")
    if self.gold_item_bid then
        local gold_item_cfg = Config.ItemData.data_get_data(self.gold_item_bid)
        if gold_item_cfg then
            loadSpriteTexture(item_sp, PathTool.getItemRes(gold_item_cfg.icon), LOADTEXT_TYPE)
        end
    end

	local order_list = self.main_container:getChildByName("order_list")
	local list_size = order_list:getContentSize()
	local scroll_view_size = cc.size(list_size.width, list_size.height)
    local setting = {
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 0,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 5,                   -- y方向的间隔
        item_width = 617,               -- 单元的尺寸width
        item_height = 142,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 1,                         -- 列数，作用于垂直滚动类型
        need_dynamic = true
    }
    self.item_scrollview = CommonScrollViewSingleLayout.new(order_list, cc.p(0,0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
    self.item_scrollview:setSwallowTouches(false)

    self.item_scrollview:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
    self.item_scrollview:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
    self.item_scrollview:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
end

function HolynightBossWindow:createNewCell()
    local cell = HolynightBossItem.new()
    return cell
end

function HolynightBossWindow:numberOfCells()
    if not self.show_customs_data then return 0 end
    return #self.show_customs_data
end

function HolynightBossWindow:updateCellByIndex(cell, index)
    if not self.show_customs_data then return end
    cell.index = index
    local cell_data = self.show_customs_data[index]
    if not cell_data then return end
    cell:setData(cell_data)
end

function HolynightBossWindow:register_event()
    registerButtonEventListener(self.background, handler(self, self.onClickCloseBtn), false, 2)
    registerButtonEventListener(self.close_btn, handler(self, self.onClickCloseBtn), true, 2)
    registerButtonEventListener(self.chapter_btn, handler(self, self.onClickChapterBtn), true)
    registerButtonEventListener(self.rule_btn, function (param,sender, event_type)
        local rule_cfg = Config.MonopolyMapsData.data_const["monopoly_rule_2"]
        if rule_cfg then
            TipsManager:getInstance():showCommonTips(rule_cfg.desc, sender:getTouchBeganPosition())
        end
    end, true)

    -- buff数据
    self:addGlobalEvent(MonopolyEvent.Update_Buff_Data_Event, function ()
        self:updateBuffData()
    end)

    -- boss数据
    self:addGlobalEvent(MonopolyEvent.Get_Boss_Data_Event, function (data)
        if data and data.id == self.cur_step_id then
            self:setData(data)
        end
    end)

    -- 公会排行数据
    self:addGlobalEvent(MonopolyEvent.Get_Guild_Rank_Data_Event, function (data)
        if data and data.id == self.cur_step_id then
            self:updateRankData(data)
        end
    end)

    -- 道具数量变化
	if not self.role_assets_event and self.role_vo then
        self.role_assets_event =  self.role_vo:Bind(RoleEvent.UPDATE_ROLE_ACTION_ASSETS, function(id, value) 
            if id and id == self.gold_item_bid and self.role_vo then 
                self:updateItemNum()
            end
        end)
    end
end

function HolynightBossWindow:onClickChapterBtn()
    local world_pos = self.chapter_btn:convertToWorldSpace(cc.p(0, 0))
    if not self.all_chapter_data then
        self.all_chapter_data = {}
        for k,v in pairs(Config.MonopolyMapsData.data_customs) do
            _table_insert(self.all_chapter_data, {id = v.id, value = v.name})
        end
        table.sort(self.all_chapter_data, SortTools.KeyLowerSorter("id"))
    end
    local setting = {}
    setting.select_index = self.cur_step_id
    setting.offsetx = -110
    CommonUIController:getInstance():openCommonComboboxPanel(true, world_pos, handler(self, self.onChoseChapterBtn), self.all_chapter_data, setting )
end

function HolynightBossWindow:onChoseChapterBtn(index)
    if self.all_chapter_data[index] then
        self.cur_step_id = self.all_chapter_data[index].id
        _controller:sender27500(self.cur_step_id)
        _controller:sender27503(self.cur_step_id, 0)
    end
end

function HolynightBossWindow:updateItemNum()
    local have_num = self.role_vo:getActionAssetsNumByBid(self.gold_item_bid)
    self.item_num_txt:setString(have_num)
end

function HolynightBossWindow:updateBuffData()
    local buff_data = _model:getMonopolyBuffData()
    local atk_buff_val = 0
    local hp_buff_val = 0
    for k,v in pairs(buff_data) do
        if v.buff_id == 1 then
            atk_buff_val = v.val
        elseif v.buff_id == 2 then
            hp_buff_val = v.val
        end
    end
    self.atk_txt:setString(_string_format(TI18N("+%d"), atk_buff_val))
    self.hp_txt:setString(_string_format(TI18N("+%d"), hp_buff_val))
end

function HolynightBossWindow:onClickCloseBtn()
    _controller:openHolynightBossWindow(false)
end

function HolynightBossWindow:openRootWnd(step_id)
    self.cur_step_id = step_id or 1
    _controller:sender27500(self.cur_step_id)
    _controller:sender27504()
    _controller:sender27503(self.cur_step_id, 0)
end

function HolynightBossWindow:setData(data)
    if not data then return end

    self.data = data

    -- 章节名称
    local customs_cfg = Config.MonopolyMapsData.data_customs[data.id]
    if customs_cfg then
        self.chapter_name_txt:setString(customs_cfg.name)
    end

    -- 主题英雄
    local main_hero_cfg = Config.MonopolyDungeonsData.data_main_hero[data.id]
    if main_hero_cfg then
        self.role_info_title:setString(_string_format(TI18N("主题英雄上阵伤害提升%d%%"), main_hero_cfg.buff_val or 0))
        for i, item in pairs(self.mian_hero_list) do
            item:setVisible(false)
        end
        for i, bid in ipairs(main_hero_cfg.main_partner) do
            local hero_item = self.mian_hero_list[i]
            if not hero_item then
                hero_item = HeroExhibitionItem.new(0.7)
                self.main_container:addChild(hero_item)
                self.mian_hero_list[i] = hero_item
            end
            local pos_x = 100 + (i-1)*105
            hero_item:setPosition(cc.p(pos_x, 775))
            local partner_data = Config.PartnerData.data_partner_base[bid]
            hero_item:setData(partner_data)
            hero_item:setVisible(true)
        end
    end

    -- 探索值
    self.probe_txt:setString(TI18N("探索值:") .. data.develop)

    -- boss列表
    self.show_customs_data = {}
    local all_cfg_data = Config.MonopolyDungeonsData.data_boss_info[self.cur_step_id]
    if all_cfg_data then
        for k, v in pairs(all_cfg_data) do
            local show_data = deepCopy(v)
            show_data.state, show_data.hp, show_data.max_hp = self:getBossStateById(v.boss_id)
            _table_insert(self.show_customs_data, show_data)
        end 
    end
    _table_sort(self.show_customs_data, SortTools.KeyLowerSorter("boss_id"))
    self.item_scrollview:reloadData()

    self:updateItemNum()
end

-- 公会排行数据
function HolynightBossWindow:updateRankData(rank_data)
    if not rank_data then return end

    local function getRankGuildName(index)
        local guild_name = TI18N("暂无")
        for k, info in pairs(rank_data.guild_stage_rank or {}) do
            if info.rank == index then
                guild_name = info.name
                break
            end
        end
        return guild_name
    end
    for i,txt in ipairs(self.rank_name_list) do
        txt:setString(getRankGuildName(i))
    end
end

-- 根据bossid获取状态 1：未解锁，2：可挑战 3：已击败, 4可追击
function HolynightBossWindow:getBossStateById(id)
    if not self.data then return 1 end
    local state = 1
    local hp = 0
    local max_hp = 1
    for k, info in pairs(self.data.boss_list) do
        if info.boss_id == id then
            state = info.status
            hp = info.hp
            max_hp = info.max_hp
            break
        end
    end
    return state, hp, max_hp
end

function HolynightBossWindow:close_callback()
    -- 还原ui战斗类型
    MainuiController:getInstance():resetUIFightType()
    if self.item_scrollview then
        self.item_scrollview:DeleteMe()
        self.item_scrollview = nil
    end
    if self.role_assets_event and self.role_vo then
        self.role_vo:UnBind(self.role_assets_event)
        self.role_assets_event = nil
    end
    for k, item in pairs(self.mian_hero_list) do
        item:DeleteMe()
        item = nil
    end
    _controller:openHolynightBossWindow(false)
end