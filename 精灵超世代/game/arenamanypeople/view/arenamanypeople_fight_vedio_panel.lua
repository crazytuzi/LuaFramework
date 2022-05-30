 -- --------------------------------------------------------------------
-- @author: xhj@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      多人竞技场比赛场数
-- <br/> 2020年3月23日
-- --------------------------------------------------------------------
ArenaManyPeopleFightVedioPanel = ArenaManyPeopleFightVedioPanel or BaseClass(BaseView)

local controller = ArenaManyPeopleController:getInstance()
local string_format = string.format
local table_insert = table.insert
local table_sort = table.sort


function ArenaManyPeopleFightVedioPanel:__init()
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Big   
    self.is_full_screen = false
    self.layout_name = "elitematch/elitematch_fight_vedio_panel"

    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("vedio","vedio"), type = ResourcesType.plist },
    }

    --奖励
    self.show_list = {}
end

function ArenaManyPeopleFightVedioPanel:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end

    self.main_container = self.root_wnd:getChildByName("main_container")
    self.main_panel = self.main_container:getChildByName("main_panel")

    self.title = self.main_panel:getChildByName("win_title")
    self.title:setString(TI18N("录像列表"))

    self.scroll_container = self.main_panel:getChildByName("scroll_container")


    self.close_btn = self.main_panel:getChildByName("close_btn")
    self.left_label = self.main_panel:getChildByName("left_label")
    self.left_label:setTextColor(cc.c4b(0x24,0x90,0x03,0xff))
    self.right_label = self.main_panel:getChildByName("right_label")
    self.right_label:setTextColor(cc.c4b(0xd9,0x50,0x14,0xff))
    self.centre_label = self.main_panel:getChildByName("centre_label")
end

function ArenaManyPeopleFightVedioPanel:register_event()
    registerButtonEventListener(self.background, handler(self, self.onClickBtnClose) ,false, 1)
    registerButtonEventListener(self.close_btn, handler(self, self.onClickBtnClose) ,true, 2)

    self:addGlobalEvent(ArenaManyPeopleEvent.ARENAMANYPOEPLE_SINGLE_REPORT_EVENT, function(data)
        if not data then return end
        self:setData(data)
    end)
end

--关闭
function ArenaManyPeopleFightVedioPanel:onClickBtnClose()
    controller:openArenaManyPeopleFightVedioPanel(false)
end

--@level_id 段位
function ArenaManyPeopleFightVedioPanel:openRootWnd(setting)
    local setting = setting or {}
    local data = setting.data
    if not data then return end
    local combat_type = BattleConst.Fight_Type.AreanManyPeople
    --回合数
    self.max_action_count = 0
    local config = Config.CombatTypeData.data_fight_list[combat_type]
    if config then
        self.max_action_count = config.max_action_count
    end
    self.data = data

    controller:sender29027(data.id)
    
    self.left_label:setString(TI18N("我方队伍"))
    
    self.right_label:setString(TI18N("敌方队伍"))
    
    local my_is_atk = data.is_atk or 0
    local str = string_format("%s:%s", data.win_count, data.lose_count)
    if my_is_atk == 0 then
        str = string_format("%s:%s", data.lose_count, data.win_count)
    end
    
    self.centre_label:setString(str)
end
function ArenaManyPeopleFightVedioPanel:setData(data)
    self.show_list = data.replay_infos
    table_sort(self.show_list,function(a, b) return a.order < b.order end)
    self:updateList()
end

function ArenaManyPeopleFightVedioPanel:updateList()
    if self.item_scrollview == nil then
        local scroll_view_size = self.scroll_container:getContentSize()
        local setting = {
            start_x = 0,                     -- 第一个单元的X起点
            space_x = 0,                     -- x方向的间隔
            start_y = 0,                     -- 第一个单元的Y起点
            space_y = 0,                     -- y方向的间隔
            item_width = 628,                -- 单元的尺寸width
            item_height = 403,               -- 单元的尺寸height
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
end


--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function ArenaManyPeopleFightVedioPanel:createNewCell(width, height)
   local cell = ArenaManyPeopleFightVedioItem.new()
   -- cell:setActionRankCommonType(self.holiday_bid, self.type)
    -- cell:addCallBack(function() self:onCellTouched(cell) end)
    return cell
end
--获取数据数量
function ArenaManyPeopleFightVedioPanel:numberOfCells()
    if not self.show_list then return 0 end
    return #self.show_list
end
--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--index :数据的索引
function ArenaManyPeopleFightVedioPanel:updateCellByIndex(cell, index)
    cell.index = index
    local cell_data = self.show_list[index]
    if not cell_data then return end
    cell:setData(cell_data, self.max_action_count, self.data)
end


function ArenaManyPeopleFightVedioPanel:close_callback()
    if self.item_scrollview then
        self.item_scrollview:DeleteMe()
    end
    self.item_scrollview = nil
    GlobalEvent:getInstance():Fire(VedioEvent.OpenCollectViewEvent, false)
    controller:openArenaManyPeopleFightVedioPanel(false)
end

------------------------------------------
-- 子项
ArenaManyPeopleFightVedioItem = class("ArenaManyPeopleFightVedioItem", function()
    return ccui.Widget:create()
end)

function ArenaManyPeopleFightVedioItem:ctor()
    self:configUI()
    self:register_event()
end

function ArenaManyPeopleFightVedioItem:configUI(  )
    self.size = cc.size(628.00,403)
    self:setTouchEnabled(true)
    self:setContentSize(self.size)

    local csbPath = PathTool.getTargetCSB("arenamanypeople/amp_fight_vedio_item")
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
        item.panel_elfin = container:getChildByName(prefix.."panel_elfin")
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
    
end

function ArenaManyPeopleFightVedioItem:register_event( )
    registerButtonEventListener(self.play_btn, handler(self, self.onClickPlayBtn) ,true, 2)
    registerButtonEventListener(self.info_btn, handler(self, self.onClickInfoBtn) ,true, 2)
end

function ArenaManyPeopleFightVedioItem:onClickPlayBtn()
    if not self.data then return end
    BattleController:getInstance():csRecordBattle(self.data.id, self.parent_data.a_srv_id)
end

function ArenaManyPeopleFightVedioItem:onClickInfoBtn()
    if not self.data then return end

    local harmInfo = {}
        harmInfo.atk_name = self.atk_name
        harmInfo.target_role_name = self.def_name
        harmInfo.hurt_statistics = {}
        if self.data.ret == 1 then
            harmInfo.result = 1
        elseif self.data.ret == 2 then
            harmInfo.result = 2
        end
        for i=1,2 do
            local temp_data = {}
            temp_data.type = i
            temp_data.partner_hurts = {}
            if i == 1 then
                for i,v in ipairs(self.data.a_plist) do
                    v.rid = self.data.rid
                    v.srvid = self.data.srv_id
                    v.dps = v.hurt
                    v.cure = v.curt
                    table_insert(temp_data.partner_hurts, v)
                end
            else
                for i,v in ipairs(self.data.b_plist) do
                    v.rid = self.data.b_rid
                    v.srvid = self.data.b_srv_id
                    v.dps = v.hurt
                    v.cure = v.curt
                    table_insert(temp_data.partner_hurts, v)
                end
            end
       
            table_insert(harmInfo.hurt_statistics, temp_data)
        end
    BattleController:getInstance():openBattleHarmInfoView(true, harmInfo)
end


function ArenaManyPeopleFightVedioItem:setData(data, max_action_count, parent_data)
    if not data then return end
    if not max_action_count then return end
    if not parent_data then return end
    self.data = data
    self.parent_data = parent_data

    -- 中间
    local round = data.round or 1
    if round > max_action_count then
        round = max_action_count
    end
    local str = string_format("%s/%s %s", round, max_action_count, TI18N("回合"))
    self.centre_war_name:setString(str)
    local time = TimeTool.getYMDHM(data.time)
    self.centre_time:setString(time)

    local my_is_atk = self.parent_data.is_atk or 0
    if my_is_atk == 1 then
        if data.ret == 1 then --左边胜利
            self.result_win:setPositionX(self.result_win_x)
            self.result_loss:setPositionX(self.result_loss_x)
        else --右边胜利了
            self.result_loss:setPositionX(self.result_win_x)
            self.result_win:setPositionX(self.result_loss_x)
        end
    else
        if data.ret == 1 then --左边胜利
            self.result_loss:setPositionX(self.result_win_x)
            self.result_win:setPositionX(self.result_loss_x)
        else --右边胜利了
            self.result_win:setPositionX(self.result_win_x)
            self.result_loss:setPositionX(self.result_loss_x)
        end
    end
   

    
    --左右

    local order = data.a_order
    --查找队员名字
    local name = data.a_name
    self.atk_name = name
    local power = data.a_power 
    local pos_info = data.a_plist 
    local formation_type = data.a_formation_type
    local rid = data.rid
    local srv_id = data.srv_id 
    local hp_percent = data.a_end_hp
    local tree_lv = data.a_sprite_lev or 0
    local sprite_data = data.a_sprites or {}
    if my_is_atk == 1 then
        self:initItemInfo(self.left_item, order, name, power, pos_info,formation_type, rid, srv_id, hp_percent,tree_lv,sprite_data)
    else
        self:initItemInfo(self.right_item, order, name, power, pos_info,formation_type, rid, srv_id, hp_percent,tree_lv,sprite_data)
    end
    

    local order = data.b_order
    local name = data.b_name
 
    self.def_name = name
    local power = data.b_power 
    local pos_info = data.b_plist 
    local formation_type = data.b_formation_type
    local rid = data.b_rid
    local srv_id = data.b_srv_id 
    local hp_percent = data.b_end_hp
    local tree_lv = data.b_sprite_lev or 0
    local sprite_data = data.b_sprites or {}
    if my_is_atk == 1 then
        self:initItemInfo(self.right_item, order, name, power, pos_info,formation_type, rid, srv_id, hp_percent,tree_lv,sprite_data)
    else
        self:initItemInfo(self.left_item, order, name, power, pos_info,formation_type, rid, srv_id, hp_percent,tree_lv,sprite_data)
    end
    
end

function ArenaManyPeopleFightVedioItem:initItemInfo(item, order, name, power, pos_info,formation_type, rid, srv_id, hp_percent,tree_lv,sprite_data)
    item.team_name:setString("")
    item.name:setString(name)
    item.fight_count:setString(power)

    self:updateHeroInfo(item, pos_info, formation_type, rid, srv_id)

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

-- 根据位置获取精灵的bid
function ArenaManyPeopleFightVedioItem:getElfinBidByPos( sprite_data, pos )
    if not sprite_data or next(sprite_data) == nil then return end
    for k,v in pairs(sprite_data) do
        if v.pos == pos then
            return v.item_bid
        end
    end
end

function ArenaManyPeopleFightVedioItem:setElfinSkillItemData( skill_item, sprite_data, pos )
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

function ArenaManyPeopleFightVedioItem:updateHeroInfo(item, pos_info, formation_type, rid, srv_id)
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



function ArenaManyPeopleFightVedioItem:DeleteMe( )
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

    if self.left_item and self.left_item.hero_item_list and next(self.left_item.hero_item_list) ~= nil then
        for i,v in pairs(self.left_item.hero_item_list) do
            v:DeleteMe()
        end
        self.left_item.hero_item_list = {}
    end

    
    if self.right_item and self.right_item.elfin_list and next(self.right_item.elfin_list) ~= nil then
        for i,v in pairs(self.right_item.elfin_list) do
            v:DeleteMe()
        end
        self.right_item.elfin_list = {}
    end

    if self.right_item and self.right_item.hero_item_list and next(self.right_item.hero_item_list) ~= nil then
        for i,v in pairs(self.right_item.hero_item_list) do
            v:DeleteMe()
        end
        self.right_item.hero_item_list = {}
    end

    self:removeAllChildren()
    self:removeFromParent()
end