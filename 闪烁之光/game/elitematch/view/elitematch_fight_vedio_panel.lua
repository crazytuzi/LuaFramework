 -- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      王者赛录像
-- <br/> 2019年3月1日
-- --------------------------------------------------------------------
ElitematchFightVedioPanel = ElitematchFightVedioPanel or BaseClass(BaseView)

local controller = ElitematchController:getInstance()
local string_format = string.format
local table_insert = table.insert
local table_sort = table.sort


function ElitematchFightVedioPanel:__init()
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Big   
    self.is_full_screen = false
    self.layout_name = "elitematch/elitematch_fight_vedio_panel"

    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("vedio","vedio"), type = ResourcesType.plist },
    }

    --奖励
    -- self.dic_reward_list = {}
    self.show_list = {}
end

function ElitematchFightVedioPanel:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end

    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container, 1)
    self.main_panel = self.main_container:getChildByName("main_panel")

    self.title = self.main_panel:getChildByName("win_title")
    self.title:setString(TI18N("录像列表"))

    self.scroll_container = self.main_panel:getChildByName("scroll_container")

    self.close_btn = self.main_panel:getChildByName("close_btn")
    self.left_label = self.main_panel:getChildByName("left_label")
    self.right_label = self.main_panel:getChildByName("right_label")
    self.centre_label = self.main_panel:getChildByName("centre_label")
end

function ElitematchFightVedioPanel:register_event()
    registerButtonEventListener(self.background, handler(self, self.onClickBtnClose) ,false, 1)
    registerButtonEventListener(self.close_btn, handler(self, self.onClickBtnClose) ,true, 2)


     --积分发送改变的时候
    self:addGlobalEvent(ElitematchEvent.Elite_Challenge_Record_Info_Event, function(data)
        if not data then return end
        self:setData(data)
    end)
end

--关闭
function ElitematchFightVedioPanel:onClickBtnClose()
    controller:openElitematchFightVedioPanel(false)
end

--@level_id 段位
function ElitematchFightVedioPanel:openRootWnd(data, index, _type, setting)
    if not data then return end
    if not index then return end
    _type = _type or 1 -- 默认为精英赛

    GlobalEvent:getInstance():Fire(VedioEvent.OpenCollectViewEvent, true)

    --回合数
    self.max_action_count = 0
    local config = Config.CombatTypeData.data_fight_list[data.combat_type]
    if config then
        self.max_action_count = config.max_action_count
    end
    self.data = data

    if _type == 1 then -- 精英赛
        controller:sender24931(index, data.id)
        self.fight_type = BattleConst.Fight_Type.EliteMatchWar
    elseif _type == 2 then -- 跨服竞技场
        CrossarenaController:getInstance():sender25617(index, data.id)
    elseif _type == 3 then --巅峰冠军赛
        if data.win_count == 0 and data.lose_count == 0 then
            commonShowEmptyIcon(self.scroll_container, true, {text = TI18N("服务器正在获取数据中，请耐心等候~")})
        else
            local second_data = setting
            self:setData(second_data)
        end    
    end
        

    local srv_name = getServerName(data.srv_id)
    if srv_name == "" then
        srv_name = TI18N("异域")
    end
    local str = string_format("[%s] %s",srv_name, data.atk_name)
    self.left_label:setString(str)

    srv_name = getServerName(data.def_srv_id)
    if srv_name == "" then
        srv_name = TI18N("异域")
    end
    str = string_format("[%s] %s",srv_name, data.def_name)
    self.right_label:setString(str)

    str = string_format("%s:%s", data.win_count, data.lose_count)
    self.centre_label:setString(str)
end
function ElitematchFightVedioPanel:setData(data)
    self.show_list = data.arena_replay_infos
    table_sort(self.show_list,function(a, b) return a.order < b.order end)
    self:updateList()
end

function ElitematchFightVedioPanel:updateList()
    if self.item_scrollview == nil then
        local scroll_view_size = self.scroll_container:getContentSize()
        local setting = {
            start_x = 0,                     -- 第一个单元的X起点
            space_x = 0,                     -- x方向的间隔
            start_y = 0,                     -- 第一个单元的Y起点
            space_y = 0,                     -- y方向的间隔
            item_width = 628,                -- 单元的尺寸width
            -- item_height = 415,               -- 单元的尺寸height
            item_height = 435,               -- 单元的尺寸height
            row = 1,                         -- 行数，作用于水平滚动类型
            col = 1,                         -- 列数，作用于垂直滚动类型
            once_num = 1,                    -- 每次创建的数量
        }
        self.item_scrollview = CommonScrollViewSingleLayout.new(self.scroll_container, cc.p(0,0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting, cc.p(0, 0))

        self.item_scrollview:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
        self.item_scrollview:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
        self.item_scrollview:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
    end
    
    self.item_scrollview:reloadData()

    if #self.show_list == 0 then
        commonShowEmptyIcon(self.scroll_container, true, {text = TI18N("暂无数据")})
    else
        commonShowEmptyIcon(self.scroll_container, false)
    end
end


--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function ElitematchFightVedioPanel:createNewCell(width, height)
   local cell = ElitematchFightVedioItem.new(width, height)
   -- cell:setActionRankCommonType(self.holiday_bid, self.type)
    -- cell:addCallBack(function() self:onCellTouched(cell) end)
    return cell
end
--获取数据数量
function ElitematchFightVedioPanel:numberOfCells()
    if not self.show_list then return 0 end
    return #self.show_list
end
--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--index :数据的索引
function ElitematchFightVedioPanel:updateCellByIndex(cell, index)
    cell.index = index
    local cell_data = self.show_list[index]
    if not cell_data then return end
    cell:setData(cell_data, self.max_action_count, self.data, self.fight_type)
end


function ElitematchFightVedioPanel:close_callback()
    if self.item_scrollview then
        self.item_scrollview:DeleteMe()
    end
    self.item_scrollview = nil
    GlobalEvent:getInstance():Fire(VedioEvent.OpenCollectViewEvent, false)
    controller:openElitematchFightVedioPanel(false)
end

------------------------------------------
-- 子项
ElitematchFightVedioItem = class("ElitematchFightVedioItem", function()
    return ccui.Widget:create()
end)

function ElitematchFightVedioItem:ctor()
    self:configUI()
    self:register_event()
end

function ElitematchFightVedioItem:configUI(  )
    self.size = cc.size(628,435)
    self:setTouchEnabled(true)
    self:setContentSize(self.size)

    local csbPath = PathTool.getTargetCSB("elitematch/elitematch_fight_vedio_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    local container = self.root_wnd:getChildByName("container")
    self.container = container

    self.result_win = container:getChildByName("result_win")
    self.result_loss = container:getChildByName("result_loss")
    self.result_win_x = self.result_win:getPositionX()
    self.result_loss_x = self.result_loss:getPositionX()

    self.play_btn = container:getChildByName("play_btn")
    self.info_btn = container:getChildByName("info_btn")
    --中间部分
    self.centre_war_name = container:getChildByName("centre_war_name")
    self.centre_time = container:getChildByName("centre_time")

    local _getItem = function(prefix)
        local item = {}
        item.team_name = container:getChildByName(prefix.."team_name")
        item.name = container:getChildByName(prefix.."name")
        item.fight_count = container:getChildByName(prefix.."fight_count")
        item.tree_lv = container:getChildByName(prefix.."tree_lv")
        -- item.tree_lv:setVisible(false)
        item.panel_elfin = container:getChildByName(prefix.."panel_elfin")
        -- item.panel_elfin:setVisible(false)
        item.elfin_list = {}

        item.pos_list = {}
        item.hero_item_list = {}
        for i=1,9 do
            local item_bg = container:getChildByName(prefix.."hero_bg_"..i)
            local x, y = item_bg:getPosition()
            item.pos_list[i] = cc.p(x, y)
        end
        return item
    end
    self.left_item = _getItem("left_")
    self.right_item = _getItem("right_")
    self.left_item.progressbar_pos =  cc.p(116.30,28)
    self.right_item.progressbar_pos =  cc.p(510.50,28)
    
end

function ElitematchFightVedioItem:register_event( )
    registerButtonEventListener(self.play_btn, handler(self, self.onClickPlayBtn) ,true, 2)
    registerButtonEventListener(self.info_btn, handler(self, self.onClickInfoBtn) ,true, 2)
end

function ElitematchFightVedioItem:onClickPlayBtn()
    if not self.data then return end
    if not self.data.id or self.data.id == 0 then
        message(TI18N("当前战斗无录像"))
        return
    end
    if self.data.replay_sid then
        BattleController:getInstance():csRecordBattle(self.data.id, self.data.replay_sid) 
    else
        BattleController:getInstance():csRecordBattle(self.data.id, self.parent_data.srv_id)
    end
end

function ElitematchFightVedioItem:onClickInfoBtn()
    if not self.data then return end
    if not self.parent_data then return end
    local hurt_data = {}
    hurt_data.atk_name = self.parent_data.atk_name
    hurt_data.target_role_name = self.parent_data.def_name
    hurt_data.hurt_statistics = self.data.hurt_statistics
    hurt_data.replay_id = self.data.id
    if self.data.ret == 1 then
        hurt_data.result = 1
    elseif self.data.ret == 2 then
        hurt_data.result = 2
    end
    local setting = {}
    setting.fight_type = self.fight_type
    BattleController:getInstance():openBattleHarmInfoView(true, hurt_data, setting)
end


function ElitematchFightVedioItem:setData(data, max_action_count, parent_data, fight_type)
    if not data then return end
    if not max_action_count then return end
    if not parent_data then return end
    self.data = data
    self.parent_data = parent_data
    self.fight_type = fight_type
    -- 中间
    local round = data.round or 1
    if round > max_action_count then
        round = max_action_count
    end
    local str = string_format("%s/%s %s", round, max_action_count, TI18N("回合"))
    self.centre_war_name:setString(str)
    local time = TimeTool.getYMDHM(data.time)
    self.centre_time:setString(time)


    if data.ret == 1 then --左边胜利
        self.result_win:setPositionX(self.result_win_x)
        self.result_loss:setPositionX(self.result_loss_x)
    else --右边胜利了
        self.result_loss:setPositionX(self.result_win_x)
        self.result_win:setPositionX(self.result_loss_x)
    end

    --左右

    local order = data.a_order
    local name = parent_data.atk_name
    local power = data.a_power 
    local pos_info = data.a_plist 
    local formation_type = data.a_formation_type
    local rid = data.rid
    local srv_id = data.srv_id 
    local hp_percent = data.a_end_hp
    local tree_lv = data.a_tree_lv or data.a_sprite_lev or 0
    local sprite_data = data.a_sprite_data or data.a_sprites or {}
    local add_power = data.a_add_power or 0
    self:initItemInfo(self.left_item, order, name, power, add_power, pos_info,formation_type, rid, srv_id, hp_percent, tree_lv, sprite_data)

    local order = data.b_order
    local name = parent_data.def_name
    local power = data.b_power 
    local pos_info = data.b_plist 
    local formation_type = data.b_formation_type
    local rid = data.b_rid
    local srv_id = data.b_srv_id 
    local hp_percent = data.b_end_hp
    local tree_lv = data.b_tree_lv or data.b_sprite_lev or 0
    local sprite_data = data.b_sprite_data or data.b_sprites or {}
    local add_power = data.b_add_power or 0
    self:initItemInfo(self.right_item, order, name, power, add_power, pos_info,formation_type, rid, srv_id, hp_percent, tree_lv, sprite_data)
end

function ElitematchFightVedioItem:initItemInfo(item, order, name, power, add_power, pos_info,formation_type, rid, srv_id, hp_percent, tree_lv, sprite_data)
    local str =  string_format("[%s%s]", TI18N("队伍"), order)
    item.team_name:setString(str)
    item.name:setString(name)
    item.fight_count:setString(power)
    self:showPvpArrowUI(item, add_power)

    self:updateHeroInfo(item, pos_info, formation_type, rid, srv_id)

    if hp_percent then
        self:showProgressbar(item, hp_percent, hp_percent.."%")
    end

    item.tree_lv:setString(string_format(TI18N("古树：%s级"), tree_lv))

    for i=1,4 do
        local elfin_item = item.elfin_list[i]
        if not elfin_item then
            elfin_item = SkillItem.new(true, true, true, 0.4, true)
            local pos_x = 22 + (i-1)*54
            elfin_item:setPosition(cc.p(pos_x, 24))
            item.panel_elfin:addChild(elfin_item)
            item.elfin_list[i] = elfin_item
        end
        self:setElfinSkillItemData(elfin_item, sprite_data, i)
    end
end
--pos_type 1 左边 2 右边
function ElitematchFightVedioItem:showPvpArrowUI(item, pvp_power)
    if not item then return end
    pvp_power = 10
    if pvp_power and pvp_power > 0 then
        if item.pvp_arrow == nil  then
            item.pvp_arrow = createImage(self.container, PathTool.getResFrame("common","common_1086"), 170, 62, cc.p(0.5,0.5), true)
            item.pvp_arrow:setScale(0.7)
        else
            item.pvp_arrow:setVisible(true)
        end
        local size = item.fight_count:getContentSize()
        local x = item.fight_count:getPositionX()
        item.pvp_arrow:setPositionX(x + size.width + 15)
    else
        if item.pvp_arrow then
            item.pvp_arrow:setVisible(false)
        end
    end
  
end
-- 根据位置获取精灵的bid
function ElitematchFightVedioItem:getElfinBidByPos( sprite_data, pos )
    if not sprite_data or next(sprite_data) == nil then return end
    for k,v in pairs(sprite_data) do
        if v.pos == pos then
            return v.item_bid
        end
    end
end

function ElitematchFightVedioItem:setElfinSkillItemData( skill_item, sprite_data, pos )
    local elfin_bid = self:getElfinBidByPos(sprite_data, pos)
    if elfin_bid then
        skill_item:showLockIcon(false)
        local elfin_cfg = Config.SpriteData.data_elfin_data(elfin_bid)
        if elfin_bid == 0 or not elfin_cfg then -- 已解锁，但未放置精灵
            skill_item:setData()
            skill_item:showLevel(false)
        else
            local skill_cfg = Config.SkillData.data_get_skill(elfin_cfg.skill)
            if skill_cfg then
                skill_item:showLevel(true)
                skill_item:setData(skill_cfg)
            end
        end
    else
        skill_item:setData()
        skill_item:showLevel(false)
        skill_item:showLockIcon(true)
    end
end


function ElitematchFightVedioItem:updateHeroInfo(item, pos_info, formation_type, rid, srv_id)
    if not item then return end
    --队伍位置
    local formation_config = Config.FormationData.data_form_data[formation_type]
    if formation_config then

        --转换位置信息
        local dic_pos_info = {}
        for k,v in pairs(pos_info) do
            dic_pos_info[v.pos] = v
        end

        for k,item in pairs(item.hero_item_list) do
            item:setVisible(false)
        end

        for i,v in ipairs(formation_config.pos) do
            local index = v[1] 
            local pos = v[2] 
            local hero_vo = dic_pos_info[pos]
            if hero_vo and hero_vo.ext then
                for i,v in ipairs(hero_vo.ext) do
                    if v.key == 5 then
                        hero_vo.use_skin = v.val
                    end
                end
            end
            --更新位置
            if item.hero_item_list[index] == nil then
                item.hero_item_list[index] = HeroExhibitionItem.new(0.5, false)
                self.container:addChild(item.hero_item_list[index])
            else
                item.hero_item_list[index]:setVisible(true)
            end
            item.hero_item_list[index]:setPosition(item.pos_list[pos])
            
            if hero_vo then
                item.hero_item_list[index]:setData(hero_vo)
                item.hero_item_list[index]:addCallBack(function()
                    if rid and srv_id then
                        ArenaController:getInstance():requestRabotInfo(rid, srv_id, index)
                    end
                end)
            else
                item.hero_item_list[index]:setData(nil)
            end
        end
    end
end

--@percent 百分比
--@label 进度条中间文字描述
--@is_blue 是否 ture:蓝条
function ElitematchFightVedioItem:showProgressbar(item, percent, label)
    if not self.container then return end
    local size = cc.size(180, 20)
    if not item.comp_bar then
        local res = PathTool.getResFrame("common","common_90005")
        local res1 = PathTool.getResFrame("common","common_90006")
        item.camp_bar_record_res = res1
        local bg,comp_bar = createLoadingBar(res, res1, size, self.container, cc.p(0.5,0.5), item.progressbar_pos.x , item.progressbar_pos.y, true, true)
        item.comp_bar = comp_bar
    end
    if not item.comp_bar_label then
        local text_color = cc.c3b(255,255,255)
        local line_color = cc.c3b(0,0,0)
        item.comp_bar_label = createLabel(18, text_color, line_color, size.width/2, size.height/2, "", item.comp_bar, 2, cc.p(0.5, 0.5))
    end

    item.comp_bar:setVisible(true)
    item.comp_bar:setPercent(percent)    
    item.comp_bar_label:setString(label)
end

function ElitematchFightVedioItem:DeleteMe( )
    if self.item_list then
        for i,v in ipairs(self.item_list) do
            v:DeleteMe()
        end
    end
    if self.item_load then
        self.item_load:DeleteMe()
        self.item_load = nil
    end

    if self.left_item and self.left_item.elfin_list and next(self.left_item.elfin_list) ~= nil then
        for i,v in pairs(self.left_item.elfin_list) do
            v:DeleteMe()
        end
        self.left_item.elfin_list = {}
    end
    if self.right_item and self.right_item.elfin_list and next(self.right_item.elfin_list) ~= nil then
        for i,v in pairs(self.right_item.elfin_list) do
            v:DeleteMe()
        end
        self.right_item.elfin_list = {}
    end
    self:removeAllChildren()
    self:removeFromParent()
end