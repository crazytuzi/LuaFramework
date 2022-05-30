 -- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      组队竞技场比赛场数
-- <br/> 2019年10月17日
-- --------------------------------------------------------------------
ArenateamFightVedioPanel = ArenateamFightVedioPanel or BaseClass(BaseView)

local controller = ArenateamController:getInstance()
local string_format = string.format
local table_insert = table.insert
local table_sort = table.sort


function ArenateamFightVedioPanel:__init()
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

function ArenateamFightVedioPanel:open_callback()
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
    local size = self.scroll_container:getContentSize()
    self.scroll_container:setContentSize(cc.size(size.width, size.height - 26 ))
    self.scroll_container:setPositionY(self.scroll_container:getPositionY() - 26)

    local panel_bg_0 = self.main_panel:getChildByName("panel_bg_0")
     local size = panel_bg_0:getContentSize()
    panel_bg_0:setContentSize(cc.size(size.width, size.height - 26 ))
    panel_bg_0:setPositionY(panel_bg_0:getPositionY() - 13)

    self.close_btn = self.main_panel:getChildByName("close_btn")
    self.left_label = self.main_panel:getChildByName("left_label")
    self.left_label:setPositionY(882)
    self.left_name = createLabel(24, cc.c4b(0x64,0x32,0x23,0xff), nil, 20.5, 848, "", self.main_panel, nil, cc.p(0,0.5))
    self.right_label = self.main_panel:getChildByName("right_label")
    self.right_label:setPositionY(882)
    self.right_name = createLabel(24, cc.c4b(0x64,0x32,0x23,0xff), nil, 653, 848, "", self.main_panel, nil, cc.p(1,0.5))
    self.centre_label = self.main_panel:getChildByName("centre_label")
end

function ArenateamFightVedioPanel:register_event()
    registerButtonEventListener(self.background, handler(self, self.onClickBtnClose) ,false, 1)
    registerButtonEventListener(self.close_btn, handler(self, self.onClickBtnClose) ,true, 2)

    self:addGlobalEvent(ArenateamEvent.ARENATEAM_SINGLE_REPORT_EVENT, function(data)
        if not data then return end
        self:setData(data)
    end)
end

--关闭
function ArenateamFightVedioPanel:onClickBtnClose()
    controller:openArenateamFightVedioPanel(false)
end

--@level_id 段位
function ArenateamFightVedioPanel:openRootWnd(setting)
    local setting = setting or {}
    local data = setting.data
    if not data then return end
    local combat_type = BattleConst.Fight_Type.Arean_Team
    --回合数
    self.max_action_count = 0
    local config = Config.CombatTypeData.data_fight_list[combat_type]
    if config then
        self.max_action_count = config.max_action_count
    end
    self.data = data

    controller:sender27256(data.id)
    
    local str = transformNameByServ(data.atk_name, data.a_srv_id)
    self.left_label:setString(TI18N("我方队伍名:"))
    self.left_name:setString(str)

    local str = transformNameByServ(data.b_team_name, data.b_srv_id)
    self.right_label:setString(TI18N("敌方队伍名:"))
    self.right_name:setString(str)

    str = string_format("%s:%s", data.win_count, data.lose_count)
    self.centre_label:setString(str)
end
function ArenateamFightVedioPanel:setData(data)
    self.show_list = data.arena_replay_infos
    table_sort(self.show_list,function(a, b) return a.order < b.order end)
    self:updateList()
end

function ArenateamFightVedioPanel:updateList()
    if self.item_scrollview == nil then
        local scroll_view_size = self.scroll_container:getContentSize()
        local setting = {
            start_x = 0,                     -- 第一个单元的X起点
            space_x = 0,                     -- x方向的间隔
            start_y = 0,                     -- 第一个单元的Y起点
            space_y = 0,                     -- y方向的间隔
            item_width = 628,                -- 单元的尺寸width
            item_height = 310,               -- 单元的尺寸height
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
function ArenateamFightVedioPanel:createNewCell(width, height)
   local cell = ArenateamFightVedioItem.new()
   -- cell:setActionRankCommonType(self.holiday_bid, self.type)
    -- cell:addCallBack(function() self:onCellTouched(cell) end)
    return cell
end
--获取数据数量
function ArenateamFightVedioPanel:numberOfCells()
    if not self.show_list then return 0 end
    return #self.show_list
end
--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--index :数据的索引
function ArenateamFightVedioPanel:updateCellByIndex(cell, index)
    cell.index = index
    local cell_data = self.show_list[index]
    if not cell_data then return end
    cell:setData(cell_data, self.max_action_count, self.data)
end


function ArenateamFightVedioPanel:close_callback()
    if self.item_scrollview then
        self.item_scrollview:DeleteMe()
    end
    self.item_scrollview = nil
    GlobalEvent:getInstance():Fire(VedioEvent.OpenCollectViewEvent, false)
    controller:openArenateamFightVedioPanel(false)
end

------------------------------------------
-- 子项
ArenateamFightVedioItem = class("ArenateamFightVedioItem", function()
    return ccui.Widget:create()
end)

function ArenateamFightVedioItem:ctor()
    self:configUI()
    self:register_event()
end

function ArenateamFightVedioItem:configUI(  )
    self.size = cc.size(628,335)
    self:setTouchEnabled(true)
    self:setContentSize(self.size)

    local csbPath = PathTool.getTargetCSB("arenateam/arenateam_fight_vedio_item")
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

function ArenateamFightVedioItem:register_event( )
    registerButtonEventListener(self.play_btn, handler(self, self.onClickPlayBtn) ,true, 2)
    registerButtonEventListener(self.info_btn, handler(self, self.onClickInfoBtn) ,true, 2)
end

function ArenateamFightVedioItem:onClickPlayBtn()
    if not self.data then return end
    BattleController:getInstance():csRecordBattle(self.data.id, self.parent_data.a_srv_id)
end

function ArenateamFightVedioItem:onClickInfoBtn()
    if not self.data then return end
    local hurt_data = {}
    hurt_data.atk_name = self.atk_name or ""
    hurt_data.target_role_name = self.def_name or ""
    hurt_data.hurt_statistics = self.data.hurt_statistics
    BattleController:getInstance():openBattleHarmInfoView(true, hurt_data)
end


function ArenateamFightVedioItem:setData(data, max_action_count, parent_data)
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


    if data.ret == 1 then --左边胜利
        self.result_win:setPositionX(self.result_win_x)
        self.result_loss:setPositionX(self.result_loss_x)
    else --右边胜利了
        self.result_loss:setPositionX(self.result_win_x)
        self.result_win:setPositionX(self.result_loss_x)
    end

    --左右

    local order = data.a_order
    --查找队员名字
    local name = ""
    for i,v in ipairs(parent_data.a_team_members) do
        if v.pos == order then
            name = v.name
        end
    end
    self.atk_name = name
    local power = data.a_power 
    local pos_info = data.a_plist 
    local formation_type = data.a_formation_type
    local rid = data.rid
    local srv_id = data.srv_id 
    local hp_percent = data.a_end_hp
    self:initItemInfo(self.left_item, order, name, power, pos_info,formation_type, rid, srv_id, hp_percent)

    local order = data.b_order
    local name = ""
    for i,v in ipairs(parent_data.b_team_members) do
        if v.pos == order then
            name = v.name
        end
    end
    self.def_name = name
    local power = data.b_power 
    local pos_info = data.b_plist 
    local formation_type = data.b_formation_type
    local rid = data.b_rid
    local srv_id = data.b_srv_id 
    local hp_percent = data.b_end_hp
    self:initItemInfo(self.right_item, order, name, power, pos_info,formation_type, rid, srv_id, hp_percent)
end

function ArenateamFightVedioItem:initItemInfo(item, order, name, power, pos_info,formation_type, rid, srv_id, hp_percent)
    item.team_name:setString("")
    item.name:setString(name)
    item.fight_count:setString(power)

    self:updateHeroInfo(item, pos_info, formation_type, rid, srv_id)

    -- self:showProgressbar(item, hp_percent, hp_percent.."%")
end


function ArenateamFightVedioItem:updateHeroInfo(item, pos_info, formation_type, rid, srv_id)
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
function ArenateamFightVedioItem:showProgressbar(item, percent, label)
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

function ArenateamFightVedioItem:DeleteMe( )
    if self.item_list then
        for i,v in ipairs(self.item_list) do
            v:DeleteMe()
        end
    end
    if self.item_load then
        self.item_load:DeleteMe()
        self.item_load = nil
    end
    self:removeAllChildren()
    self:removeFromParent()
end