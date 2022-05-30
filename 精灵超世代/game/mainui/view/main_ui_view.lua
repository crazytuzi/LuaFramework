-- --------------------------------------------------------------------
-- 项目的主UI,包含了头像,图标,经验,聊天等
--
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @editor: shiraho@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2017-xx-xx
-- --------------------------------------------------------------------
MainUiView = MainUiView or BaseClass()

local string_format = string.format
local controler = MainuiController:getInstance()
local tolua_isnull = tolua.isnull
local role_vo = RoleController:getInstance():getRoleVo()
local table_insert = table.insert
local unfold_ani_time = 0.1
local bg_unfold_time = 0.01

function MainUiView:__init()
    self:initConfig()
    self:createRootWnd()
    self:registerEvent()
end

function MainUiView:initConfig()
    self.bottom_btn_list = {}					-- 下方的功能按钮
    self.icon_container_list = {}				-- 根据方位保存需要储存的图标的父节点
    self.wealth_item_key = {"coin", "gold"}     --资产icon显示数据 key 是role_vo里面的变量
    self.record_wealth_icon_res = {}            --记录当前资产的icon
    self.wealth_icon_list = {}                 -- 资产的数值icon
    self.wealth_label_list = {}					-- 资产的数值按钮
    self.is_open = true 						-- 是否是打开状态下
    self.cur_select_index = 0					-- 当前选中的按钮id

    self.render_list = {}						-- 待添加的实例对象
    self.render_list_dic = {}					-- 但添加实例字典
    self.function_list = {}						-- 显示的实例对象
    self.cur_vip_lev = nil                      -- VIP等级
    self.top_left_off = 15
    self.left_off = 20
    self.right_off = 40
    self.top_left_max_sum = 6
    self.left_max_sum = 7

    self.is_in_shrink = false
    self.is_shrink = false

    self.layout_list = {}
    for k, v in pairs(FunctionIconVo.type) do
        self.layout_list[v] = {}
    end
    self.btn_cache_tips = {}    --红点缓存

    self.hide_container_status = true

    self.dungeon_item_label = {}

    self.left_icon_unfold = true -- 左侧图标展开状态
    self.right_icon_unfold = true -- 右侧图标展开状态
    self.func_show_status = true
    self.red_bag_2_type = 0 --1：花火红包 2：年兽红包  用于点击事件判断
    self.training_camp_lev_limit = Config.TrainingCampData.data_const.training_camp_lev_limit
end

function MainUiView:createRootWnd()
    self.node = ccui.Layout:create()
    self.node:setContentSize(cc.size(SCREEN_WIDTH, SCREEN_HEIGHT))
    self.node:setAnchorPoint(cc.p(0, 0))

    self.root_wnd = createCSBNote(PathTool.getTargetCSB("mainui/mainui_view"))
    self.root_wnd:setAnchorPoint(0.5, 0.5)
    self.root_wnd:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
    self.size = self.root_wnd:getContentSize()
    self.node:addChild(self.root_wnd)

    self.bottom_container = self.root_wnd:getChildByName("bottom_container")
    for i = 1, 7 do
        local btn = self.bottom_container:getChildByName("mainui_tab_"..i)
        local tips_point = btn:getChildByName("tips_point")
        tips_point:setVisible(false)

        btn:addTouchEventListener(function(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                playButtonSound()
                self:changeMainUiStatus(i)
            end
        end)

        -- 用于飘物品的位置使用
        if i == MainuiConst.btn_index.backpack then
            local pos = self.bottom_container:convertToWorldSpace(cc.p(btn:getPosition()))
            pos.y = pos.y + display.getBottom(self.root_wnd)
            controler:setBackPackBtnPos(pos) 
        end

        local object = {}
        object.btn = btn
        object.index = i
        object.tips_point = tips_point
        object.normal = btn:getChildByName("normal")
        object.selected = btn:getChildByName("selected")
        object.icon = btn:getChildByName("icon")
        object.notice = btn:getChildByName("notice")
        object.title = btn:getChildByName("title")
        object.tips_status = false
        object.init_y = btn:getPositionY()
        local config = Config.FunctionData.data_base[i]
        if config and config.activate then
            object.config = config
            if object.notice then
                object.notice:setString(config.label)
            end
        end
        print("object.title",object.title)
        if object.title then
            object.title:setString(config.name)
        end
        self.bottom_btn_list[i] = object
        object.normal:setVisible(false)
        if i == 1 then
            self.cur_select_index = i
            self.cur_select_btn = object
            self.cur_select_btn.normal:setVisible(true)
            --self.cur_select_btn.selected:setVisible(true)
            --object.btn:setPositionY(object.init_y+10)
        end
    end

    self.top_container = self.root_wnd:getChildByName("top_container")
    self.exp_bar = self.top_container:getChildByName("exp_bar")
    self.exp_bar:setScale9Enabled(true)

    local head_container = self.top_container:getChildByName("head_container")
    self.role_head = PlayerHead.new(PlayerHead.type.circle)
    self.role_head:setPosition(40, 40)
    head_container:addChild(self.role_head)

    self.info_container = self.top_container:getChildByName("info_container")
    self.lev_label = self.info_container:getChildByName("lev_label")
    self.name_label = self.info_container:getChildByName("name_label")
    for i = 1, 2 do
        self.wealth_label_list[i] = self.info_container:getChildByName("wealth_label_"..i)
        self.wealth_icon_list[i] = self.info_container:getChildByName("wealth_icon_"..i)
    end
    self.fight_label = self.info_container:getChildByName("fight_label")

    self.gold_touch = self.top_container:getChildByName("gold_touch")
    self.coin_touch = self.top_container:getChildByName("coin_touch")
    self.coin_redpoint = self.top_container:getChildByName("Sprite_8")

    self.hide_container = self.root_wnd:getChildByName("hide_container")
    self.handle_btn = self.hide_container:getChildByName("handle_btn")
    -- 系统提示
    self.prompt_container = self.root_wnd:getChildByName("prompt_container")
    self.prompt_tips_layout = self.prompt_container:getChildByName("tips_layout")
    self.prompt_bubble_layout = self.prompt_container:getChildByName("bubble_layout")
    self.prompt_desc = self.prompt_bubble_layout:getChildByName("desc")
    self.prompt_bubble = self.prompt_bubble_layout:getChildByName("bubble")
    self.prompt_bubble_size = self.prompt_bubble:getContentSize()
    self.effect_container = self.prompt_container:getChildByName("effect_container")
    self.effect_container:setVisible(false)
    -- 引导需要
    self.effect_container:setName("guide_effect_btn")    
    self.prompt_container_effect_size = self.effect_container:getContentSize()
    self.tips_btn = self.prompt_container:getChildByName("tips_btn")

    self.prompt_tips_scroll = self.prompt_tips_layout:getChildByName("tips_scroll")
    self.prompt_tips_scroll:setScrollBarEnabled(false)
    self.prompt_tips_scroll_size = self.prompt_tips_scroll:getContentSize()
    self.count_size_label = self.prompt_tips_layout:getChildByName("count_size_label")

    self.prompt_tips_bg = self.prompt_tips_layout:getChildByName("tips_bg")
    self.prompt_tips_bg_size = self.prompt_tips_bg:getContentSize()
    self.prompt_tips_layout:setVisible(false)
    -- self.prompt_bubble_layout:setVisible(false)

    local handle_y = display.getBottom() + self.bottom_container:getContentSize().height + 60
    local handle_x = display.getRight() - 45
    self.handle_btn:setPosition(handle_x, handle_y)
    self.prompt_container:setPositionY(handle_y-90)

    --红包推送容器
    self.red_bag_container = self.hide_container:getChildByName("red_bag_container")
    self.red_bag_container:setVisible(false)
    self.red_bag_size = self.red_bag_container:getContentSize()

    -- 红包推送容器2
    self.red_bag_container_2 = self.hide_container:getChildByName("red_bag_container_2")
    self.red_bag_container_2:setVisible(false)
    self.red_bag_container_2:setPositionY(531)
    self.red_bag_2_size = self.red_bag_container_2:getContentSize()

    -- 红包推送容器2
    self.red_bag_container_3 = self.hide_container:getChildByName("red_bag_container_3")
    self.red_bag_container_3:setVisible(false)
    self.red_bag_3_size = self.red_bag_container_3:getContentSize()

    -- 定时领奖（神明的新春祝福）入口特效
    self.time_collect_container = self.hide_container:getChildByName("time_collect_container")
    self.time_collect_container:setVisible(false)
    self.time_collect_size = self.time_collect_container:getContentSize()
    
    --合服问卷调查 
    self.vote_mergeServer_container = self.hide_container:getChildByName("vote_mergeServer_container")
    self.vote_mergeServer_container:setVisible(false)
    self.vote_mergeServer_container:setPosition(cc.p(-50,300))
    self.vote_mergeServer_container_size = self.vote_mergeServer_container:getContentSize()

    -- 图标
    self.icon_container = self.root_wnd:getChildByName("icon_container")
    for k, v in pairs(FunctionIconVo.type) do
        local partner_container
        if v == FunctionIconVo.type.right_bottom_1 or v == FunctionIconVo.type.right_bottom_2 then
            partner_container = self.hide_container
        else
            partner_container = self.icon_container
        end
        local icon_container = partner_container:getChildByName("icon_container_"..v)
        if icon_container then
            self.icon_container_list[v] = icon_container
            local _x, _y = 0, 0
            if v == FunctionIconVo.type.right_top_1 then -- 右上横向
                _x = display.getRight() - 10
                _y = display.getTop() - self.top_container:getContentSize().height + 10 - 10
            elseif v == FunctionIconVo.type.right_top_2 then -- 右上纵向
                _x = display.getLeft() + 11
                _y = display.getTop() - self.top_container:getContentSize().height - 44
            elseif v == FunctionIconVo.type.right_bottom_1 then
                _x = handle_x - 57
                _y = handle_y
            elseif v == FunctionIconVo.type.right_bottom_2 then
                _x = handle_x
                _y = handle_y + 55
            elseif v == FunctionIconVo.type.left_top then -- 左上纵向 (现右上角)
                local handle_left_x = display.getRight() - 10
                _x = handle_left_x
                _y = display.getTop() - self.top_container:getContentSize().height - 92 - 110
                --要记录位置
            end
            icon_container:setPosition(_x, _y)
        end
    end

    --VIP图标
    -- local pos_y = display.getTop()-self:getTopViewHeight() - 27
    -- self.vip_image_btn = createImage(self.icon_container, PathTool.getResFrame("mainui", "txt_cn_mainui_vip"), 44, pos_y, cc.p(0.5,0.5), true)
    -- self.vip_image_btn:setTouchEnabled(true)
    -- self.vip_image_btn:setVisible(false)
    --头顶的
    self.vip_label = CommonNum.new(19, self.info_container, 1, -2, cc.p(0.5, 0.5))
    self.vip_label:setPosition(342, 38)

    --独立的
    -- self.vip_image_label = CommonNum.new(33, self.vip_image_btn, 1, -2, cc.p(0.5, 0.5))
    -- self.vip_image_label:setPosition(34, 42)

    -- if not self.vip_image_heffect then         
    --     self.vip_image_effect = createEffectSpine("E50117", cc.p(34, 30), cc.p(0.5, 0.5), true, PlayerAction.action)
    --     self.vip_image_btn:addChild(self.vip_image_effect)
    -- end

    self.handle_x = handle_x
    self.handle_y = handle_y

    -- if not IS_IOS_PLATFORM then
    --     sdkPerfer_prize()
    -- end
    -- 提审服 不显示这些东西
    self:updateHandleBtnShowStatus()
    if MAKELIFEBETTER == true then
        local icon_container_1 = self.icon_container_list[FunctionIconVo.type.right_bottom_1]
        local icon_container_2 = self.icon_container_list[FunctionIconVo.type.right_bottom_2]
        if icon_container_1 then
            icon_container_1:setVisible(false)
        end
        if icon_container_2 then
            icon_container_2:setVisible(false)
        end

        self.top_container:getChildByName("Image_2"):setVisible(false)
        self.top_container:getChildByName("Sprite_6"):setVisible(false)
        self.vip_label:setVisible(false)

        -- self.vip_image_btn:setVisible(false)
        -- if self.vip_image_effect then
        --     self.vip_image_effect:setVisible(false)
        -- end
    end

end

function MainUiView:getMainUiIndex()
    return self.cur_select_index 
end

--==============================--
--desc:判断是否是有战斗的ui
--time:2019-01-17 10:09:56
--@index:
--@return 
--==============================--
function MainUiView:checkFightUi(index)
    return index == MainuiConst.btn_index.main_scene or index == MainuiConst.btn_index.drama_scene or index == MainuiConst.btn_index.esecsice or index == MainuiConst.btn_index.guild or index == MainuiConst.btn_index.partner
end

--==============================--
--desc:底部5个按钮的处理，不直接传按钮对象是因为外部也会调用这个
--time:2018-06-06 07:45:43
--@index:
--@sub_type:
--@force:是否强制退出战斗
--@return 
--==============================--
function MainUiView:changeMainUiStatus(index, sub_type, extend_data, force)
    local btn = self.bottom_btn_list[index]
    if btn == nil or (not btn.is_unlock) then
        if btn.config ~= nil then
            message(btn.config.desc)
        end
        return
    end
    -- 在剧情中不给点击
	if StoryController:getInstance():getModel():isStoryState() then return end

    -- 检查是否是观战状态
    if self:checkFightClickStatus(force) == true then return end

    -- 一些状态处理
    if self.cur_select_index == index and index ~= MainuiConst.btn_index.main_scene then
        if index == MainuiConst.btn_index.drama_scene then
            BaseView.closeAllView()
        end
        return
    end

    -- 如果上一个处于有战斗的,则退出战斗
    if self:checkFightUi(self.cur_select_index) then
        BattleController:getInstance():openBattleView(false)
    end

    -- 点击下面图标都关闭窗体
    BaseView.closeAllView()

    -- 设置主ui的按钮状态
    self:setMaiuiBtnStatus(index)

    -- 切换标签，修改切换音乐  
    if index ~= MainuiConst.btn_index.drama_scene then
        self:changeBackgroundMusic()
    end

    if index == MainuiConst.btn_index.main_scene then
        MainSceneController:getInstance():handleSceneStatus(true)
    elseif index == MainuiConst.btn_index.partner then
        HeroController:getInstance():openHeroBagWindow(true, sub_type, extend_data)
    elseif index == MainuiConst.btn_index.backpack then
        if BackpackController:getInstance():getModel():checkEquipsIsFull() == true then
            sub_type = BackPackConst.item_tab_type.EQUIPS
        end
        BackpackController:getInstance():openMainView(true,sub_type)
    elseif index == MainuiConst.btn_index.drama_scene then
        controler:requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.Darma)
    elseif index == MainuiConst.btn_index.esecsice then
        EsecsiceController:getInstance():openEsecsiceView(true)
    elseif index == MainuiConst.btn_index.guild then
        GuildController:getInstance():checkOpenGuildWindow()
        -- 清楚主界面上面的红点
	    GuildskillController:getInstance():getModel():clearGuildSkillIconRed()
    elseif index == MainuiConst.btn_index.hallows then
        if extend_data then
            local hallows_id = extend_data[1]
            local index = extend_data[2]
            local magic_id = extend_data[3]
            HallowsController:getInstance():openHallowsMainWindow(true, hallows_id, index, magic_id)
        else
            HallowsController:getInstance():openHallowsMainWindow(true)
        end
    end
    -- 设置一些显示
    self:changeSomeShowStatus(index)
    -- 延迟跳转
    self:doChangeBySubType(index, sub_type, extend_data)
end

--==============================--
--desc:设置主ui按钮的状态
--time:2018-07-24 07:14:25
--@index:
--@return 
--==============================--
function MainUiView:setMaiuiBtnStatus(index)
    if self.cur_select_btn ~= nil then
        --if self.cur_select_index == MainuiConst.btn_index.drama_scene then
        --    self:changeChallengeEffectStatus(false)
        --else
            self.cur_select_btn.normal:setVisible(false)
            --self.cur_select_btn.selected:setVisible(false)
            self.cur_select_btn.btn:setPositionY(self.cur_select_btn.init_y)
        --end
        self.cur_select_btn = nil
    end
    self.cur_select_index = index
    self.cur_select_btn = self.bottom_btn_list[index]
    if self.cur_select_btn ~= nil then
        --if self.cur_select_index == MainuiConst.btn_index.drama_scene then
        --    self:changeChallengeEffectStatus(true)
        --else
            self.cur_select_btn.normal:setVisible(true)
            --self.cur_select_btn.selected:setVisible(true)
            self.cur_select_btn.btn:setPositionY(self.cur_select_btn.init_y+10)
        --end
    end
    local fight_type = self:getUIFightByIndex(index)
    controler:setUIFightType(fight_type)
end

--==============================--
--desc:根据主按钮下标获取对应ui战斗类型
--time:2018-10-08 05:38:55
--@index:
--@return 
--==============================--
function MainUiView:getUIFightByIndex(index)
    if index == MainuiConst.btn_index.main_scene then
        return MainuiConst.ui_fight_type.main_scene
    elseif index == MainuiConst.btn_index.partner then 
        return MainuiConst.ui_fight_type.partner
    elseif index == MainuiConst.btn_index.backpack then 
        return MainuiConst.ui_fight_type.backpack
    elseif index == MainuiConst.btn_index.drama_scene then 
        return MainuiConst.ui_fight_type.drama_scene
    else
        return MainuiConst.ui_fight_type.normal
    end
end

--==============================--
--desc:跳转处理
--time:2018-07-20 09:53:44
--@type:
--@sub_type:
--@return 
--==============================--
function MainUiView:doChangeBySubType(main_type, sub_type, extend_data)

    if main_type == nil or sub_type == nil then return end
    self.sub_type = sub_type
    delayRun(self.root_wnd, 0.2, function()
        if self.sub_type and self.sub_type ~= sub_type then return end
        if main_type == MainuiConst.btn_index.main_scene then
            if sub_type == MainuiConst.sub_type.arena_call then
                MainSceneController:getInstance():openBuild(CenterSceneBuild.arena, ArenaConst.arena_type.loop)
            elseif sub_type == MainuiConst.sub_type.champion_call then
                MainSceneController:getInstance():openBuild(CenterSceneBuild.arena, ArenaConst.arena_type.rank)
            elseif sub_type == MainuiConst.sub_type.guild_boss then
                if role_vo and role_vo.gid == 0 then
                    message(TI18N("您暂时还没有加入公会"))
                else
			        controler:requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.GuildDun)
                end
            elseif sub_type == MainuiConst.sub_type.startower then --试练塔
                controler:requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.StarTower)
            elseif sub_type == MainuiConst.sub_type.partnersummon then
                PartnersummonController:getInstance():openPartnerSummonWindow(true)
            elseif sub_type == MainuiConst.sub_type.escort then
                controler:requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.Escort, extend_data) 
            elseif sub_type == MainuiConst.sub_type.forge_house then --锻造屋
                if extend_data and type(extend_data) == "number" then
                    ForgeHouseController:getInstance():openForgeHouseView(true, extend_data)
                else
                    ForgeHouseController:getInstance():openForgeHouseView(true)
                end
            elseif sub_type == MainuiConst.sub_type.seerpalace then -- 先知殿
                if extend_data and type(extend_data) == "number" then
                    SeerpalaceController:getInstance():openSeerpalaceMainWindow(true, extend_data)
                else
                    SeerpalaceController:getInstance():openSeerpalaceMainWindow(true)
                end
            elseif sub_type == MainuiConst.sub_type.wonderful then
                if type(extend_data) == "number" then
                    ActionController:getInstance():openActionMainPanel(true, nil, extend_data) 
                elseif type(extend_data) == "table" then
                    local function_id = extend_data[1]
                    local action_bid = extend_data[2]
                    ActionController:getInstance():openActionMainPanel(true, function_id, action_bid) 
                end
            elseif sub_type == MainuiConst.sub_type.godbattle then
                controler:requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.Godbattle)
            elseif sub_type == MainuiConst.sub_type.world_boss then
                controler:requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.WorldBoss)
            elseif sub_type == MainuiConst.sub_type.function_icon then
                controler:iconClickHandle(extend_data)
            elseif sub_type == MainuiConst.sub_type.guild_skill then
                --跳转公会技能
                GuildskillController:getInstance():openGuildSkillMainWindow(true)
            elseif sub_type == MainuiConst.sub_type.guildwar then
                controler:requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.GuildWar)
            elseif sub_type == MainuiConst.sub_type.ladderwar then
                controler:requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.LadderWar)
            elseif sub_type == MainuiConst.sub_type.primuswar then
                controler:requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.PrimusWar) 
            elseif sub_type == MainuiConst.sub_type.expedit_fight then
                -- controler:requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.ExpeditFight)
                HeroExpeditController:getInstance():requestEnterHeroExpedit()
            elseif sub_type == MainuiConst.sub_type.endless then
                controler:requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.Endless)
            elseif sub_type == MainuiConst.sub_type.dungeonstone then
                controler:requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.DungeonStone, extend_data) 
            elseif sub_type == MainuiConst.sub_type.adventure then
                AdventureController:getInstance():requestEnterAdventure()           -- 跳转神界冒险
            elseif sub_type == MainuiConst.sub_type.eliteMatchWar then -- 精英大赛
                ElitematchController:getInstance():openElitematchMainWindow(true)
            elseif sub_type == MainuiConst.sub_type.elementWar then -- 元素圣殿
                controler:requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.ElementWar, extend_data)
            elseif sub_type == MainuiConst.sub_type.heavenwar then -- 天界副本
                if extend_data == HeavenConst.Tab_Index.DialRecord then
                    HeavenController:getInstance():openHeavenMainWindow(true,nil,HeavenConst.Tab_Index.DialRecord)
                else
                    controler:requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.HeavenWar)
                end
            elseif sub_type == MainuiConst.sub_type.crossarenawar then -- 跨服竞技场
                controler:requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.CrossArenaWar)
            elseif sub_type == MainuiConst.sub_type.homeworld then --家园
                HomeworldController:getInstance():requestOpenMyHomeworld(  )
            elseif sub_type == MainuiConst.sub_type.crosschampion then --跨服冠军赛
                controler:requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.CrossChampion)
            elseif sub_type == MainuiConst.sub_type.limitexercise then --试炼之镜
                controler:requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.LimitExercise)
            elseif sub_type == MainuiConst.sub_type.termbegins then --开学季
                controler:requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.TermBegins, {index = 1})
            elseif sub_type == MainuiConst.sub_type.termbeginsboss then --开学季
                controler:requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.TermBegins, {index = 2})
            elseif sub_type == MainuiConst.sub_type.adventruemine then --矿脉
                AdventureController:getInstance():requestEnterMaxAdventureMine()
            elseif sub_type == MainuiConst.sub_type.guildsecretarea then --公会秘境
                MainuiController:getInstance():requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.GuildSecretArea)
            elseif sub_type == MainuiConst.sub_type.arenateam then --组队竞技场
                MainuiController:getInstance():requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.Arean_Team)
            elseif sub_type == MainuiConst.sub_type.monopolywar_1 then --大富翁阶段一
                MainuiController:getInstance():requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.MonopolyWar_1)
            elseif sub_type == MainuiConst.sub_type.monopolywar_2 then --大富翁阶段二
                MainuiController:getInstance():requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.MonopolyWar_2)
            elseif sub_type == MainuiConst.sub_type.monopolywar_3 then --大富翁阶段三
                MainuiController:getInstance():requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.MonopolyWar_3)
            elseif sub_type == MainuiConst.sub_type.monopolywar_4 then --大富翁阶段四
                MainuiController:getInstance():requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.MonopolyWar_4)
            elseif sub_type == MainuiConst.sub_type.monopolyboss then --大富翁boss
                MainuiController:getInstance():requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.MonopolyBoss)
            elseif sub_type == MainuiConst.sub_type.peakchampion then --巅峰冠军赛
                -- controler:requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.Arenapeakchampion)
                 ArenapeakchampionController:getInstance():openArenapeakchampionGuessingWindow(true)
            elseif sub_type == MainuiConst.sub_type.planeswar then --位面
                MainuiController:getInstance():requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.PlanesWar, extend_data)
            elseif sub_type == MainuiConst.sub_type.yearmonsterWar then --年兽
                ActionyearmonsterController:getInstance():sender28204()
            elseif sub_type == MainuiConst.sub_type.whitedaywar then --女神试炼
                ActionController:getInstance():openActionMainPanel(true, nil, ActionRankCommonType.white_day)
            elseif sub_type == MainuiConst.sub_type.planes_rank then --位面迷踪
                ActionController:getInstance():openActionMainPanel(true, nil, ActionRankCommonType.planes_rank)
            elseif sub_type == MainuiConst.sub_type.arenamanypeople then --多人竞技场
                MainuiController:getInstance():requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.AreanManyPeople)
            end 
        elseif main_type == MainuiConst.btn_index.drama_scene then
            if sub_type == MainuiConst.sub_type.dungeon_auto then
                local battle_drama_model = BattleDramaController:getInstance():getModel()
                local drama_data = battle_drama_model:getDramaData()
                if battle_drama_model and drama_data then
                    local data = battle_drama_model:getSingleBossData(drama_data.max_dun_id)
                    BattleDramaController:getInstance():openDramBossInfoView(true, data)
                end 
            end
        end
    end)
end

--==============================--
--desc:设置一下显示状态的
--time:2018-07-23 03:02:31
--@index:
--@return 
--==============================--
function MainUiView:changeSomeShowStatus(index)
end

--==============================--
--desc:观战状态
--time:2018-07-20 10:04:45
--force:是否强制退出战斗
--@return 
--==============================--
function MainUiView:checkFightClickStatus(force)
    local is_click_status = BattleController:getInstance():getIsClickStatus() 
    if is_click_status then
        if (GuideController:getInstance():isInGuide() == true) or (force == true) then -- 如果在引导中
            BattleController:getInstance():csFightExit()
            is_click_status = false
        else
            local str = TI18N("正在观看录像或切磋中，是否退出?")
            if BattleController:getInstance():getIsHeroTestWar() then
                str = TI18N("正在观看战斗演示，是否切换界面?")
            end
            if self.tips_alert then
                self.tips_alert:close()
                self.tips_alert = nil
            end
            local function fun()
                BattleController:getInstance():csFightExit()
            end
            local function cancelfunc()
                if self.tips_alert then
                    self.tips_alert:close()
                    self.tips_alert = nil
                end
            end
            if not self.tips_alert then
                self.tips_alert = CommonAlert.show(str, TI18N("确定"), fun, TI18N("取消"), cancelfunc, CommonAlert.type.rich, cancelfunc, nil, nil, true)
            end
        end
    end 
    return is_click_status
end

function MainUiView:changeBackgroundMusic()
    local music_name = RoleController:getInstance():getModel().city_music_name or "s_002"
    AudioManager:getInstance():playMusic(AudioManager.AUDIO_TYPE.SCENE, music_name, true)
end

--==============================--
--desc:
--time:2018-05-29 02:00:36
--@id:下面按钮序号
--@data:data 可以是单纯bool值，或者是table形式{[1]={id=xxx,status=false}}
--@return 
--==============================--
function MainUiView:updateBtnTipsPoint(id, data)
    if not self.bottom_btn_list[id] then return end

    if data == nil then
        self.btn_cache_tips[id] = nil
    else
        if type(data) ~= "table" then
            self.btn_cache_tips[id] = data
        else
            if self.btn_cache_tips[id] == nil then
                self.btn_cache_tips[id] = {}
            end
            if data.bid ~= nil then
                self.btn_cache_tips[id][data.bid] = data.status
            else
                for k, v in pairs(data) do
                    if v.bid ~= nil then
                        self.btn_cache_tips[id][v.bid] = v.status
                    end
                end
            end
        end
    end
    local bool = false
    if self.btn_cache_tips[id] then
        if type(self.btn_cache_tips[id]) == "table" then
            for i, v in pairs(self.btn_cache_tips[id]) do
                if v == true then
                    bool = true
                    break
                end
            end
        else
            bool = self.btn_cache_tips[id]
        end
    end

    local btn_object = self.bottom_btn_list[id]
    if btn_object and btn_object.tips_status ~= bool then
        btn_object.tips_status = bool
        if btn_object.tips_point then
            btn_object.tips_point:setVisible(bool)
        end
    end
end

function MainUiView:showRedBagEffect(bool)
    if bool == true and not tolua_isnull(self.play_effect) then return end
    self.red_bag_container:setVisible(bool)
	if bool == true and self.play_effect == nil then
        self.play_effect = createEffectSpine(PathTool.getEffectRes(260), cc.p(self.red_bag_size.width/2,self.red_bag_size.height/2), cc.p(0.5, 0.5), true, PlayerAction.action)
        self.red_bag_container:addChild(self.play_effect, 1)
    else
        if self.play_effect then 
            self.play_effect:removeFromParent()
            self.play_effect = nil
        end
    end
end

function MainUiView:showRedBagEffect2(bool, show_type)
    self.red_bag_container_2:setVisible(bool)
    if bool == true then
        if not self.redbag_effect then
            self.redbag_effect = createEffectSpine(PathTool.getEffectRes(331), cc.p(self.red_bag_2_size.width/2, self.red_bag_2_size.height/2), cc.p(0.5, 0.5), true, PlayerAction.action_1)
            self.red_bag_container_2:addChild(self.redbag_effect, 1)
        else
            self.redbag_effect:setToSetupPose()
        end
        show_type = show_type or 1
        if show_type == 1 then
            self.redbag_effect:setAnimation(0, PlayerAction.action_1, true)
            self.red_bag_container_2:setPositionX(-100)
        else
            self.redbag_effect:setAnimation(0, PlayerAction.action_2, true)
            self.red_bag_container_2:setPositionX(-40)
        end
    else
        if self.redbag_effect then 
            self.redbag_effect:removeFromParent()
            self.redbag_effect = nil
        end
    end
end

function MainUiView:showRedBagEffect3(bool, show_type)
    self.red_bag_container_3:setVisible(bool)
    if bool == true then
        if not self.redbag_effect_2 then
            self.redbag_effect_2 = createEffectSpine(PathTool.getEffectRes(331), cc.p(self.red_bag_3_size.width/2, self.red_bag_3_size.height/2), cc.p(0.5, 0.5), true, PlayerAction.action_1)
            self.red_bag_container_3:addChild(self.redbag_effect_2, 1)
        else
            self.redbag_effect_2:setToSetupPose()
        end
        show_type = show_type or 1
        if show_type == 1 then
            self.redbag_effect_2:setAnimation(0, PlayerAction.action_1, true)
            self.red_bag_container_3:setPositionX(-100)
        else
            self.redbag_effect_2:setAnimation(0, PlayerAction.action_2, true)
            self.red_bag_container_3:setPositionX(-40)
        end
    else
        if self.redbag_effect_2 then 
            self.redbag_effect_2:removeFromParent()
            self.redbag_effect_2 = nil
        end
    end
end

--合服调查问卷
function MainUiView:showMergeEffect(bool,action_type)
    self.vote_mergeServer_container:setVisible(bool)
    if bool == true then
        if not self.show_MergeEffect then
            self.show_MergeEffect = createEffectSpine(PathTool.getEffectRes(205), cc.p(self.vote_mergeServer_container_size.width/2, self.vote_mergeServer_container_size.height/2), cc.p(0.5, 0.5), true, PlayerAction.action_2)
            self.vote_mergeServer_container:addChild(self.show_MergeEffect, 1)
        else
            self.show_MergeEffect:setToSetupPose()
        end
        _type = action_type or 1
        if _type == 1 then
            self.show_MergeEffect:setAnimation(0, PlayerAction.action_2, true)
            self.vote_mergeServer_container:setPositionX(-50)
        else
            self.show_MergeEffect:setAnimation(0, PlayerAction.action_1, true)
            self.vote_mergeServer_container:setPositionX(-60)
        end
    else
        if self.show_MergeEffect then 
            self.show_MergeEffect:removeFromParent()
            self.show_MergeEffect = nil
        end
    end
end

--定时领奖（神明的新春祝福）入口特效
function MainUiView:showTimeCollectEffect(bool)
    self.time_collect_container:setVisible(bool)
    if bool == true then
        if not self.timecollect_effect then 
            self.timecollect_effect = createEffectSpine(PathTool.getEffectRes(538), cc.p(self.time_collect_size.width/2, self.time_collect_size.height/2), cc.p(0.5, 0.5), true, PlayerAction.action_1)
            self.time_collect_container:addChild(self.timecollect_effect, 1)
        else
            self.timecollect_effect:setToSetupPose()
        end
        self.timecollect_effect:setAnimation(0, PlayerAction.action, true)
    else
        if self.timecollect_effect then 
            self.timecollect_effect:removeFromParent()
            self.timecollect_effect = nil
        end
    end
end

--==============================--
--desc:打开ui
--time:2018-06-06 05:13:26
--@return 
--==============================--
function MainUiView:open()
    if self.node:getParent() == nil then
        ViewManager:getInstance():addToLayerByTag(self.node, ViewMgrTag.TOP_TAG)

        -- 初始化更新数据
        self:updateRoleData()

        -- 判断等级解锁主按钮
        self:checkUnLockStatusByLev()

        -- 创建战斗图标的特效
        --self:createChallengeEffect()

        -- 创建聊天泡泡
        self:createChatBubble()

        -- 适配处理
        self:adaptScreen()

        -- 所有活动的时间倒计时,统一用一个定时器在这里做处理
        if self.function_time_ticket == nil then
            self.function_time_ticket = GlobalTimeTicket:getInstance():add(function() 
                self:functionTimeTicketList()
            end, 1)
        end
    else
        self:handleHideContainer(true)
    end
end

function MainUiView:handleHideContainer(status)
    self.hide_container_status = status

    if self.wait_update == nil then
        self.wait_update = GlobalTimeTicket:getInstance():add(function() 
            if self.hide_container_status == true then
                self.is_open = self.hide_container_status
                self.hide_container:setVisible(self.is_open)
                self.icon_container:setVisible(self.is_open)
                self.prompt_container:setVisible(self.is_open)
            end
            GlobalTimeTicket:getInstance():remove(self.wait_update)
            self.wait_update = nil
        end, 0.2, 1)
    end
end

--==============================--
--desc:打开包含全屏窗体的时候，需要隐藏一些主UI上面的东西，以及切换玩法的时候
--time:2018-06-06 09:46:18
--@return 
--==============================--
function MainUiView:close()
    if not tolua_isnull(self.hide_container) then
        self.is_open = false
        self.hide_container_status = false
        self.hide_container:setVisible(false)
        self.icon_container:setVisible(false)
        self.prompt_container:setVisible(false)
    end
end

function MainUiView:isOpen()
    return self.is_open
end

-- ---------------------- 图标部分 start---------------------- --

-- 显示\隐藏顶部功能图标
function MainUiView:showFuncIconList( status )
    if not tolua_isnull(self.icon_container) then
        self.icon_container:setVisible(status)
    end
end

--==============================--
--desc:初始化技能图标列表
--time:2018-06-06 05:13:41
--@list:
--@return 
--==============================--
function MainUiView:addIconList(list)
    if list == nil then return end
    for k, vo in pairs(list) do
        if vo ~= nil and vo.config ~= nil then
            if not self:checkIconIn(vo.config.id) then
                self.render_list_dic[vo.config.id] = vo
                table.insert(self.render_list, vo)
            end
        end
    end
    -- 这里先做一个排序
    if self.render_list ~= nil and next(self.render_list) ~= nil then
        local sort_func = SortTools.tableLowerSorter({ "pos", "sort" })
        table.sort(self.render_list, sort_func)
    end
    -- 开启计时器,准备创建图标ƒ
    if self.add_function_timer == nil then
        self.add_function_timer = GlobalTimeTicket:getInstance():add(function()
            self:createFunctionIcon()
        end, 2 / display.DEFAULT_FPS)
    end
end

--==============================--
--desc:动态添加一个图标
--time:2018-06-06 05:13:57
--@vo:
--@return 
--==============================--
function MainUiView:addIcon(vo)
    if vo == nil or vo.config == nil or self:checkIconIn(vo.config.id) then return end
    self.render_list_dic[vo.config.id] = vo

    table.insert(self.render_list, vo)
    local sort_func = SortTools.tableLowerSorter({ "pos", "sort" })
    table.sort(self.render_list, sort_func)
    -- 开启计时器,准备创建图标
    if self.add_function_timer == nil then
        self.add_function_timer = GlobalTimeTicket:getInstance():add(function()
            self:createFunctionIcon()
        end, 2 / display.DEFAULT_FPS)
    end
end

--==============================--
--desc:监测一个图标是否存在
--time:2018-06-06 05:14:30
--@id:
--@return 
--==============================--
function MainUiView:checkIconIn(id)
    if self.function_list[id] ~= nil or self.render_list_dic[id] ~= nil then
        return true
    end
    return false
end

--==============================--
--desc:动态移除一个图标
--time:2018-06-06 05:14:09
--@id:
--@return 
--==============================--
function MainUiView:removeIcon(id)
    local config = Config.FunctionData.data_info[id]
    if config == nil then return end
    if self.function_list[id] ~= nil then
        if self.function_list[id].DeleteMe then
            self.function_list[id]:DeleteMe()
            self.function_list[id] = nil
        end
    end

    for i, v in ipairs(self.render_list) do
        if v.config.id == id then
            table.remove(self.render_list, i)
            break
        end
    end
    self.render_list_dic[id] = nil

    if self.layout_list == nil or self.layout_list[config.type] == nil then return end
    for i, v in ipairs(self.layout_list[config.type]) do
        if v and v.config.id == id then
            table.remove(self.layout_list[config.type], i)
            break
        end
    end
    self:updateIconLayout(config.type)
end

--==============================--
--desc:创建一个图标
--time:2018-06-06 05:14:21
--@return 
--==============================--
function MainUiView:createFunctionIcon()
    if self.render_list == nil or next(self.render_list) == nil then
        if self.add_function_timer ~= nil then
            GlobalTimeTicket:getInstance():remove(self.add_function_timer)
            self.add_function_timer = nil
        end
        self.can_touch_unfold = true
        return
    end
    local data = table.remove(self.render_list, 1)
    if data == nil then return end
    self.render_list_dic[data.config.id] = nil
    -- 这类图标不需要在主界面显示
    if data.config and data.config.is_show == 0 then return end
    self:addItemToTabArray(data)
end

--==============================--
--desc:将图标添加到父节点容器
--time:2018-06-06 05:15:01
--@data:
--@return 
--==============================--
function MainUiView:addItemToTabArray(data)
    if data == nil or data.config == nil then return end
    if self.layout_list == nil then
        self.layout_list = {}
    end
    if self.layout_list[data.config.type] == nil then
        self.layout_list[data.config.type] = {}
    end

    local is_new = true
    for k, v in pairs(self.layout_list[data.config.type]) do
        if v.config.id == data.config.id then
            v = data
            is_new = false
            break
        end
    end
    data.is_new = is_new
    table.insert(self.layout_list[data.config.type], data)
    table.sort(self.layout_list[data.config.type], SortTools.KeyLowerSorter("sort"))
    self:updateIconLayout(data.config.type)
end

--==============================--
--desc:更新图标位置
--time:2018-06-06 05:15:18
--@type:
--@return 
--==============================--
function MainUiView:updateIconLayout(type)
    self:updateIconBgShowStatus(type)
    if self.layout_list == nil or self.layout_list[type] == nil or next(self.layout_list[type]) == nil then return end
    local layout = self:getContainerByType(type)
    if layout == nil or tolua_isnull(layout) then return end
    local len = #self.layout_list[type]
    local data, icon = nil, nil
    for i = 1, len do
        data = self.layout_list[type][i]
        if data and data.config then
            if self.function_list[data.config.id] == nil then
                if data.is_new == true then
                    data.is_new = false
                    icon = FunctionIcon.new(data)
                    layout:addChild(icon)
                    self.function_list[data.config.id] = icon
                end
            end
            icon = self.function_list[data.config.id]
            if icon ~= nil then
                self:setIconPosition(icon, i, layout, type)
            end
        end
    end

    self:updateIconRedStatus()
    self:updateHandleBtnShowStatus()
end

-- 左上纵向和右上纵向，如果没有图标则不显示背景条
function MainUiView:updateIconBgShowStatus( _type )
    if _type == FunctionIconVo.type.right_top_2 then
        if next(self.layout_list[_type]) ~= nil then
            local icon_container = self.icon_container_list[_type]
            if not self.right_icon_bg then
                local con_size = icon_container:getContentSize()
                self.right_icon_bg = createImage(icon_container, PathTool.getResFrame("common", "mainui_1036"), con_size.width*0.5 + 14, 190, cc.p(0.5, 1), true, -1, true)
                self.right_icon_bg:setCapInsets(cc.rect(1, 1, 103, 1))
                -- 点击区域
                self.right_arrow_btn = ccui.Layout:create()
                self.right_arrow_btn:setTouchEnabled(true)
                self.right_arrow_btn:setContentSize(cc.size(110, 90))
                self.right_arrow_btn:setAnchorPoint(0.5,0)
                self.right_arrow_btn:setPosition(55, 0)
                self.right_icon_bg:addChild(self.right_arrow_btn)

                self.right_arrow_img = createImage(self.right_arrow_btn, PathTool.getResFrame("common", "mainui_1041"), 54, 58, cc.p(0.5, 0.5), true, -1)

                registerButtonEventListener(self.right_arrow_btn, function (  )
                    self:onClickArrowBtn(1)
                end, true, 1, nil, nil, 0.5)
            end
            local bg_hight = #self.layout_list[_type]*(84+10)+164 + 34
            self.right_icon_bg.bg_hight = bg_hight
            self.right_icon_bg:setVisible(true)
            if self.right_icon_unfold == true then
                self.right_icon_bg:setContentSize(cc.size(108, bg_hight))
            end
        elseif self.right_icon_bg then
            self.right_icon_bg:setVisible(false)
        end
    --[[ elseif _type == FunctionIconVo.type.left_top then
        if next(self.layout_list[_type]) ~= nil then
            local icon_container = self.icon_container_list[_type]
            if not self.left_icon_bg then
                local con_size = icon_container:getContentSize()
                self.left_icon_bg = createImage(icon_container, PathTool.getResFrame("mainui", "mainui_1036"), con_size.width*0.5, 192, cc.p(0.5, 1), true, -1, true)
                self.left_icon_bg:setCapInsets(cc.rect(40, 120, 10, 1))
                -- 点击区域
                self.left_arrow_btn = ccui.Layout:create()
                self.left_arrow_btn:setTouchEnabled(true)
                self.left_arrow_btn:setContentSize(cc.size(100, 70))
                self.left_arrow_btn:setAnchorPoint(0.5,0)
                self.left_arrow_btn:setPosition(50, 0)
                self.left_icon_bg:addChild(self.left_arrow_btn)

                registerButtonEventListener(self.left_arrow_btn, function (  )
                    self:onClickArrowBtn(2)
                end, true, 1, nil, nil, 0.5)
            end
            local bg_hight = #self.layout_list[_type]*(84+10)+164
            self.left_icon_bg.bg_hight = bg_hight
            self.left_icon_bg:setVisible(true)
            if self.left_icon_unfold == true then
                self.left_icon_bg:setContentSize(cc.size(98, bg_hight))
            end
        elseif self.left_icon_bg then
            self.left_icon_bg:setVisible(false)
        end ]]
    end
    self:adjustTopcontainerPos()
end

function MainUiView:onClickArrowBtn( index )
    if not self.can_touch_unfold then return end
    if index == 1 then -- 右侧图标
        if #self.layout_list[FunctionIconVo.type.right_top_2] <= 1 then
            return
        end
        local icon_list, target_pos = self:getIconListByType(FunctionIconVo.type.right_top_2)
        if self.right_icon_unfold == true then -- 收起来
            self.right_icon_unfold = false
            self:showIconUnfoldAni(icon_list, 1, target_pos)
            self:showIconBgUnfoldAni(self.right_icon_bg, 1)
        else
            self.right_icon_unfold = true
            self:showIconUnfoldAni(icon_list, 2, target_pos)
            self:showIconBgUnfoldAni(self.right_icon_bg, 2)
        end
        self:updateIconRedStatus()
    --[[ else
        if #self.layout_list[FunctionIconVo.type.left_top] <= 1 then
            return
        end
        local icon_list, target_pos = self:getIconListByType(FunctionIconVo.type.left_top)
        if self.left_icon_unfold == true then -- 收起来
            self.left_icon_unfold = false
            self:showIconUnfoldAni(icon_list, 1, target_pos)
            self:showIconBgUnfoldAni(self.left_icon_bg, 1)
        else
            self.left_icon_unfold = true
            self:showIconUnfoldAni(icon_list, 2, target_pos)
            self:showIconBgUnfoldAni(self.left_icon_bg, 2)
        end
        self:updateIconRedStatus() ]]
    end
end

-- 更新红点
function MainUiView:updateIconRedStatus(  )
    -- 右侧
    local right_icon_list = self:getIconListByType(FunctionIconVo.type.right_top_2)
    if self.right_icon_unfold == true then
        addRedPointToNodeByStatus(self.right_icon_bg, false)
    else
        local red_status = false
        for k,icon in pairs(right_icon_list) do
            if icon:getIconRedStatus() == true then
                red_status = true
                break
            end
        end
        local bg_size = self.right_icon_bg:getContentSize()
        addRedPointToNodeByStatus(self.right_icon_bg, red_status, -5, -bg_size.height+55)
    end

    --[[ -- 左侧
    local left_icon_list = self:getIconListByType(FunctionIconVo.type.left_top)
    if self.left_icon_unfold == true then
        addRedPointToNodeByStatus(self.left_icon_bg, false)
    else
        local red_status = false
        for k,icon in pairs(left_icon_list) do
            if icon:getIconRedStatus() == true then
                red_status = true
                break
            end
        end
        local bg_size = self.left_icon_bg:getContentSize()
        addRedPointToNodeByStatus(self.left_icon_bg, red_status, -5, -bg_size.height+55)
    end ]]
end

-- 图标背景收展动画 
function MainUiView:showIconBgUnfoldAni( icon_bg, _type )
    local index = 0
    local limit_time = 10
    local def_height = 258 + 34 -- 背景默认高度
    local dif_height = (icon_bg.bg_hight - def_height)/limit_time
    self.icon_bg_timer_id = GlobalTimeTicket:getInstance():add(function (  )
        index = index + 1
        local height
        if _type == 1 then -- 收缩
            height = icon_bg.bg_hight - (index*dif_height)
            self.right_arrow_img:setFlippedY(true)
        else -- 展开
            height = def_height + (index*dif_height)
            self.right_arrow_img:setFlippedY(false)

        end
        icon_bg:setContentSize(cc.size(108, height))
        if index >= limit_time then
            GlobalTimeTicket:getInstance():remove(self.icon_bg_timer_id)
        end
    end, bg_unfold_time, limit_time, self.icon_bg_timer_id)
end

-- 获取icon列表
function MainUiView:getIconListByType( _type )
    local icon_list = {}
    local target_pos
    local len = #self.layout_list[_type]
    for i = 1, len do
        local data = self.layout_list[_type][i]
        if data and data.config then
            icon = self.function_list[data.config.id]
            if i == 1 then
                target_pos = icon.original
            else
                table_insert(icon_list, icon)
            end
        end
    end
    return icon_list, target_pos
end

-- _type:1收起 2展开
function MainUiView:showIconUnfoldAni( icon_list, _type, target_pos )
    if _type == 1 then
        if target_pos then
            for _,icon in pairs(icon_list) do
                local move_to = cc.MoveTo:create(unfold_ani_time, target_pos)
                local fade_out = cc.FadeOut:create(unfold_ani_time)
                icon:setIsShowUnfoldAni(true)
                icon:runAction(cc.Sequence:create(cc.Spawn:create(move_to, fade_out), cc.CallFunc:create(function (  )
                    icon:setVisible(false)
                    icon:setIsShowUnfoldAni(false)
                end)))
            end
        end
    else
        for _,icon in pairs(icon_list) do
            if icon.original then
                local move_to = cc.MoveTo:create(unfold_ani_time, icon.original)
                local fade_in = cc.FadeIn:create(unfold_ani_time)
                icon:setPosition(target_pos)
                icon:setVisible(true)
                icon:setIsShowUnfoldAni(true)
                icon:runAction(cc.Sequence:create(cc.Spawn:create(move_to, fade_in), cc.CallFunc:create(function (  )
                    icon:setIsShowUnfoldAni(false)
                end)))
            end
        end
    end
end

-- 提审服或者右下角没有icon时，则不显示右下角的+号
function MainUiView:updateHandleBtnShowStatus(  )
    if not MAKELIFEBETTER and (#self.layout_list[FunctionIconVo.type.right_bottom_1] > 0 or #self.layout_list[FunctionIconVo.type.right_bottom_2] > 0) then
        self.handle_btn:setVisible(true)
    else
        self.handle_btn:setVisible(false)
    end
end

--==============================--
--desc:根据位置获取图标父节点信息
--time:2018-06-06 05:15:33
--@type:
--@return 
--==============================--
function MainUiView:getContainerByType(type)
    if self.icon_container_list ~= nil then
        return self.icon_container_list[type]
    end
end

--==============================--
--desc:设置图标的位置
--time:2018-06-06 05:15:52
--@icon:图标实例
--@index:图标目标位置下表
--@layout:所在父节点
--@type:图标方向位置枚举
--@return 
--==============================--
function MainUiView:setIconPosition(icon, index, layout, type)
    local size = layout:getContentSize()
    local _x, _y = 0, 0
    local off_height = 10
    if type == FunctionIconVo.type.right_top_1 then
        _x = size.width - icon.width * 0.5 - ((index - 1) % self.top_left_max_sum) * (icon.width + self.top_left_off) 
        _y = size.height  - math.floor((index - 1) / self.top_left_max_sum) * (size.height + off_height) - size.height * 0.5
    elseif type == FunctionIconVo.type.right_bottom_1 then
        _x = size.width - icon.width * 0.5 - ((index - 1) % self.left_max_sum) * (icon.width + self.left_off) 
        _y = size.height  - math.floor((index - 1) / self.left_max_sum) * size.height - size.height * 0.5
    elseif type == FunctionIconVo.type.right_bottom_2 then
        _x = size.width * 0.5 
        _y = icon.height * 0.5 + (index - 1) * (icon.height + self.right_off)
    elseif type == FunctionIconVo.type.right_top_2 then
        _x = size.width * 0.5 +10
        _y = size.height - icon.height * 0.5 - (index - 1) * (icon.height + off_height)
    elseif type == FunctionIconVo.type.left_top then
        _x = size.width * 0.5 
        _y = size.height - icon.height * 0.5 - (index - 1) * (icon.height + off_height)
    end

    if icon.original == nil or getNorKey(icon.original.x, icon.original.y) ~= getNorKey(_x, _y) then
        icon:setPosition(_x, _y)
        icon.original = cc.p(_x, _y)
    end

    -- 当前是收起模式，则直接隐藏，第一个不隐藏
    if index ~= 1 and (type == FunctionIconVo.type.right_top_2 and not self.right_icon_unfold) then
        icon:setOpacity(0)
        icon:setVisible(false)
    else
        icon:setOpacity(255)
        icon:setVisible(true)
    end

    -- 动态调整 right_top_1 的位置
    self:adjustTopcontainerPos()

    -- 动态调整 right_top_2 的位置
    --[[ local off_y = 0
    if type == FunctionIconVo.type.right_top_1 then
        off_y = math.abs(size.height  - (math.floor((index - 1) / self.left_max_sum) + 1) * (size.height + off_height)) + size.height
    elseif type == FunctionIconVo.type.right_top_2 then
        local layout_list = self.layout_list[FunctionIconVo.type.right_top_1]
        if layout_list then
            local len = tableLen(layout_list)
            off_y = math.abs(size.height  - (math.floor((len - 1) / self.left_max_sum) + 1) * (size.height + off_height)) + size.height
        end
    end
    if off_y ~= 0 and self.top_2_off_y ~= off_y then
        self.top_2_off_y = off_y
        local top_1 = self.icon_container_list[FunctionIconVo.type.right_top_1]
        local top_2 = self.icon_container_list[FunctionIconVo.type.right_top_2]
        top_2:setPositionY(top_1:getPositionY() - off_y)
    end ]]
end

-- 动态调整 top_1 的位置
function MainUiView:adjustTopcontainerPos(  )
    -- 动态调整 right_top_1 的位置
    local layout_list = self.layout_list[FunctionIconVo.type.right_top_2]
    local is_have_top_2 = 0
    if layout_list and tableLen(layout_list) > 0 then
        is_have_top_2 = 1
    end
    if self.is_have_top_2 ~= is_have_top_2 then
        self.is_have_top_2 = is_have_top_2
        local top_1 = self.icon_container_list[FunctionIconVo.type.right_top_1]
        if is_have_top_2 == 1 then
            top_1:setPositionX(display.getRight() - 11)
        else
            top_1:setPositionX(display.getRight() - 11)
        end
    end
end

--==============================--
--desc:定时器的统一倒计时
--time:2018-06-06 05:15:52
--@return 
--==============================--
function MainUiView:functionTimeTicketList()
    if self.function_list and next(self.function_list) ~= nil then
        for k,icon in pairs(self.function_list) do
            if icon.data and icon.data.end_time and icon.data.end_time > 0 then
                if icon.updateTime then
                    icon:updateTime()       -- 自己里面计算,外面负责倒计时
                end
            end
        end
    end
end

-- ---------------------- 图标部分 end---------------------- --

-- ---------------------- 资产部分 start---------------------- -- 
function MainUiView:updateRoleData()
    self:updateRoleLev()
    self:updateRoleFc()
    self:updateRoleName()
    self:updateRoleExp()
    self:updateRoleHead()
    self:updateRoleHeadCircle()
    self:updateRoleVip()
    self:updateRoleAssets()
end

function MainUiView:updateRoleLev()
    if role_vo == nil then return end
    if self.cur_lev == role_vo.lev then return end
    self.cur_lev = role_vo.lev
    self.lev_label:setString(self.cur_lev)
    -- 判断等级是否需要显示气泡
    -- self:createChatBubble()
end

function MainUiView:updateRoleFc()
    if role_vo == nil then return end
    if self.cur_fc == role_vo.power then return end
    self.cur_fc = role_vo.power
    local showPower = changeBtValueForPower(self.cur_fc)
    self.fight_label:setString(showPower)
end

function MainUiView:updateRoleName()
    if role_vo == nil then return end
    if self.cur_name == role_vo.name then return end
    self.cur_name = role_vo.name
    self.name_label:setString(self.cur_name)
end

function MainUiView:updateRoleExp()
    if role_vo == nil or role_vo.exp == nil or role_vo.exp_max == nil then return end
    local pro = 100 * role_vo.exp / role_vo.exp_max
    self.exp_bar:setPercent(pro)
end

--- 更新角色头像,这里要特殊处理了,有可能是自定义头像,也有可能是系统头像,优先判断系统头像,这里应该需要判断如果还没有初始化cos，就不处理
function MainUiView:updateRoleHead()
    local check_status_str = TencentCos:getInstance():getSecretid()
    if check_status_str == nil or check_status_str == "" then return end
    if role_vo == nil then return end
    local res_id = role_vo.face_id
    local face_update_time = role_vo.face_update_time
    self.role_head:setHeadRes(res_id, false, LOADTEXT_TYPE, role_vo.face_file, role_vo.face_update_time)
end

function MainUiView:updateRoleHeadCircle()
    if role_vo == nil then return end
    if self.avatar_base_id == role_vo.avatar_base_id then return end
    self.avatar_base_id = role_vo.avatar_base_id
    local vo = Config.AvatarData.data_avatar[role_vo.avatar_base_id]
    if vo then
        local res_id = vo.res_id or 1
        local res = PathTool.getTargetRes("headcircle", "txt_cn_headcircle_" .. res_id, false, false)
        self.role_head:showBg(res, nil, false, vo.offy)
    end
end

function MainUiView:updateRoleVip()
    if role_vo == nil then return end
    
    self.vip_label:setNum(role_vo.vip_lev)
    -- self.vip_image_label:setNum(role_vo.vip_lev)
end

function MainUiView:updateRoleAssets()
    if role_vo == nil then return end
    for i,key in ipairs(self.wealth_item_key) do
        local label = self.wealth_label_list[i]
        local key_value = role_vo[key] or 0
        label:setString(MoneyTool.GetMoneyString(key_value))
        local item_id = Config.ItemData.data_assets_label2id[key]
        local config = Config.ItemData.data_get_data(item_id)
        if config then 
            local res = PathTool.getItemRes(config.icon, false)
            if self.record_wealth_icon_res[i] == nil or self.record_wealth_icon_res[i] ~= res then
                self.record_wealth_icon_res[i] = res
                if self.wealth_icon_list[i] then
                    loadSpriteTexture(self.wealth_icon_list[i], res, LOADTEXT_TYPE)
                end
            end
        end
    end
end
-- ---------------------- 资产部分 end---------------------- --

--==============================--
--desc:获取主ui上下之间空白区域，这个区域主要用于聊天动态尺寸
--time:2018-06-06 05:16:44
--@return 
--==============================--
function MainUiView:getFreeSize()
    if self.free_size == nil then
        local _height = (display.height - SCREEN_HEIGHT) * 0.5
        local _title_y = self.top_container:getPositionY()
        local _title_h = self.top_container:getContentSize().height
        local _bottom_y = self.bottom_container:getPositionY()
        local _bottom_h = self.bottom_container:getContentSize().height
        self.free_size = 2 * _height + _title_y + math.abs(_bottom_y) + SCREEN_HEIGHT - _bottom_h - _title_h - display.height
    end
    return self.free_size
end

function MainUiView:getTopViweBottomY()
    if self.top_view_bottom_y == nil then
        local world_pos = self.top_container:convertToWorldSpace(cc.p(0, 0))
        self.top_view_bottom_y = world_pos.y
    end
    return self.top_view_bottom_y 
end

function MainUiView:getTopViewHeight()
    if self.top_height == nil then
        self.top_height = self.top_container:getContentSize().height + 20
    end
    return self.top_height
end

--==============================--
--desc:ui屏幕的适配
--time:2018-06-06 05:17:27
--@return 
--==============================--
function MainUiView:adaptScreen()
    self.top_container:setPositionY(display.getTop())
    self.bottom_container:setPositionY(display.getBottom())
    -- local scale = display.specialScale()
    -- self.top_container:setScale(scale)
    -- self.bottom_container:setScale(scale)
end

--==============================--
--desc:获取主ui从底部到聊天界面的高度，世界坐标系高度
--time:2018-06-12 07:20:06
--@return 
--==============================--
function MainUiView:getBottomHeight()
    if self.bottom_height == nil then
        self.bottom_height = self.bottom_container:getContentSize().height + 20
    end
    return self.bottom_height 
end

--==============================--
--desc:聊天的高度加位置
--time:2018-07-24 08:41:20
--@return 
--==============================--
function MainUiView:getChatHeightPositionY()
    -- local chat_height_position_y = self.chat_ui:getPositionY() + self.chat_ui:getContentSize().height
    -- return chat_height_position_y
    if self.bottom_world_height == nil then
        self.bottom_world_height = display.getBottom() + self.bottom_container:getContentSize().height
    end
    return self.bottom_world_height 
end

--==============================--
--desc:监测开启条件
--time:2018-06-06 07:10:02
--@return 
--==============================--
function MainUiView:checkUnLockStatus(max_dun_id)
    if max_dun_id == nil then return end
    local is_unlock = false
    for k, btn in pairs(self.bottom_btn_list) do
        if btn.config and btn.config.activate then
            local activate = btn.config.activate[1]
            if activate[1] == "dun" then
                is_unlock = (max_dun_id >= activate[2])
                if is_unlock ~= btn.is_unlock then
                    btn.is_unlock = is_unlock
                    if btn.notice then
                        btn.notice:setVisible(not is_unlock)
                    end
                    if is_unlock == false then
                        setChildUnEnabled(true, btn)
                    else
                        setChildUnEnabled(false, btn)
                    end
                end
            end
        end
    end
end

--==============================--
--desc:升级的时候判断等级开启
--time:2018-06-06 07:37:20
--@lev:
--@return 
--==============================--
function MainUiView:checkUnLockStatusByLev(lev)
    if role_vo == nil then return end
    local is_unlock = false
    for k, btn in pairs(self.bottom_btn_list) do
        if btn.config and btn.config.activate then
            local activate = btn.config.activate[1]
            if activate[1] == "lev" then
                is_unlock = (role_vo.lev >= activate[2])
                if is_unlock ~= btn.is_unlock then
                    btn.is_unlock = is_unlock 
                    if btn.notice then
                        btn.notice:setVisible(not is_unlock)
                    end
                    if is_unlock == false then
                        setChildUnEnabled(true, btn)
                    else
                        setChildUnEnabled(false, btn)
                    end
                end
            end
        end
    end
end

--==============================--
--desc:挑战图标的特效
--time:2018-07-24 06:05:51
--@return 
--==============================--
function MainUiView:createChallengeEffect()
    if self.challenge_effect ~= nil then return end
    local btn_object = self.bottom_btn_list[MainuiConst.btn_index.drama_scene]
    if btn_object == nil then return end

    local btn = btn_object.btn
    local btn_size = btn:getContentSize()
    local action = PlayerAction.action_1
    if self.cur_select_index == MainuiConst.btn_index.drama_scene then
        action = PlayerAction.action_2
    end
    self.challenge_effect = createEffectSpine(PathTool.getEffectRes(310), cc.p(5,10), cc.p(0, 0), true, action)
    btn_object.icon:addChild(self.challenge_effect)
end

--==============================--
--desc:设置于取消状态
--time:2018-07-24 06:57:21
--@status:
--@return 
--==============================--
function MainUiView:changeChallengeEffectStatus(status)
    if self.challenge_effect == nil then return end
    if status == true then
        self.challenge_effect:setAnimation(0, PlayerAction.action_2, true)
    else
        self.challenge_effect:setAnimation(0, PlayerAction.action_1, true)
    end
end

--==============================--
--desc:更新聊天总数
--time:2018-07-27 04:22:45
--@return 
--==============================--
function MainUiView:updateChatMsgNum()
    local chat_ctrl = ChatController:getInstance()
    -- 是否显示红点，设置为不显示时，仅显示公会和私聊的红点
    local total = 0
    local chat_red_open = SysEnv:getInstance():getBool(SysEnv.keys.chat_red_open,true)
    if chat_red_open == false then
        total = chat_ctrl:getChannelMsgSum(ChatConst.Channel.Friend) + chat_ctrl:getChannelMsgSum(ChatConst.Channel.Gang)
    else
        total = chat_ctrl:getTotalMsgSum()
    end
    if self.chat_red_container then
        self.chat_red_container:setVisible(total>0)
        if total > 99 then
            total = "+99"
        end
        self.chat_red_num:setString(total)
    end
end

--==============================--
--desc:注册事件
--time:2017-09-09 02:23:00
--@return
--==============================--
function MainUiView:registerEvent()
    if role_vo then
        if self.role_update_event == nil then
            self.role_update_event = role_vo:Bind(RoleEvent.UPDATE_ROLE_ATTRIBUTE, function(key, value)
                if key == "power" or key == "match_rank" then 		--段位分
                    self:updateRoleFc()
                elseif key == "lev" then 	--等级
                    self:updateRoleLev()
                    self:updataVIPRedPoint()
                    self:checkUnLockStatusByLev(value)
                    self.overLev = false
                    if value >= Config.MergeVotingData.data_const.level_limit.val then
                        self.overLev = true
                        MergeserverController:getInstance():sender10991()
                    end
                    self:showPromptEffect(true)
                    self:updateTipsBtnStatus()
                    self:updateCityDesc(true)
                    self:updataExchangeRedPoint()
                elseif key == "exp" or key == "exp_max" then 	--经验
                    self:updateRoleExp()
                elseif key == "name" then 	-- 改名的时候
                    self:updateRoleName()
                elseif key == "face_id" or key == "face_update_time" or key == "custom_face_file" then
                    self:updateRoleHead()
                elseif key == "avatar_base_id" then
                    self:updateRoleHeadCircle()
                elseif key == "coin" or key == "gold" or key == "red_gold" or key == "silver_coin" or key == "hero_exp" then
                    self:updateRoleAssets()
                elseif key == "vip_lev" then
                    self:updateRoleVip()
                elseif key == "gid" and value == 0 then
                    self:showRedBagEffect(false)
                end
            end)
        end
    end
    --vip图标跳转
    -- self.vip_image_btn:addTouchEventListener(function(sender, event_type)
    --     if event_type == ccui.TouchEventType.ended then
    --         playButtonSound2()
    --         VipController:getInstance():openVipMainWindow(true)
    --     end
    -- end)
    --vip图标红点
    if self.vip_image_redpoint == nil then
        self.vip_image_redpoint = GlobalEvent:getInstance():Bind(VipEvent.SUPRE_CARD_GET, function(status)
            self:updataVIPRedPoint()
        end)
    end

    self.red_bag_container:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            RedbagController:getInstance():openMainView(true)
        end
    end)

    self.red_bag_container_2:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            if self.red_bag_2_type == 1 then
                PetardActionController:getInstance():openRedbagWindow(true)
            elseif self.red_bag_2_type == 2 then
                JumpController:getInstance():jumpViewByEvtData({70})
            end 
        end
    end)

    self.red_bag_container_3:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            ReturnActionController:getInstance():openReturnRedbagWindow(true)
        end
    end)
    
    self.time_collect_container:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            ActionController:getInstance():openActionTimeCollectWindow(true)
        end
    end)

    --合服问卷调查
    self.vote_mergeServer_container:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            MergeserverController:getInstance():openMergeWindow(true)
        end
    end)

    if self.role_head then
        self.role_head:addCallBack(function()
            RoleController:getInstance():openRolePersonalSpacePanel(true)
        end, false)
    end

    if self.gold_touch then
        self.gold_touch:addTouchEventListener(function(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                playButtonSound2()

                if self.wealth_item_key[2]  then
                    if self.wealth_item_key[2] == "hero_exp" then --宝可梦经验 
                        local config = Config.ItemData.data_get_data(Config.ItemData.data_assets_label2id.hero_exp)
                        if config then
                            BackpackController:getInstance():openTipsSource(true, config)
                        end
                    else --默认钻石的
                        --MallController:getInstance():openChargeShopWindow(true, MallConst.Charge_Shop_Type.Diamond)
                        VipController:getInstance():openVipMainWindow(true, VIPTABCONST.CHARGE)
                    end
                else
                    --MallController:getInstance():openChargeShopWindow(true, MallConst.Charge_Shop_Type.Diamond)
                    VipController:getInstance():openVipMainWindow(true, VIPTABCONST.CHARGE)    
                end
            end
        end)
    end

    self.handle_btn:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            self:shrinkBtnContainer()
        end
    end)

    self.effect_container:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            if self.training_camp_lev_limit and self.training_camp_lev_limit.val > role_vo.lev then
                message(string_format(TI18N("%d级开启变强攻略"),self.training_camp_lev_limit.val))
                return
            end
            MainuiController:getInstance():requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.Training_Camp)    
        end
    end)

    self.tips_btn:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            local status = false
            if self.prompt_tips_layout:isVisible() then
                status = false
            else
                status = true
            end
            self:_onClickPromptTips(status)
        end
    end)
    
    if self.coin_touch then
        self.coin_touch:addTouchEventListener(function(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                playButtonSound2()
                if self.wealth_item_key[1] then
                    --目前只有默认金币的.还没有其他需求
                    ExchangeController:getInstance():openExchangeMainView(true)
                else
                    ExchangeController:getInstance():openExchangeMainView(true)    
                end
                
            end
        end)
    end
    --点金红点
    if self.coin_touch_redpoint == nil then
        self.coin_touch_redpoint = GlobalEvent:getInstance():Bind(ExchangeEvent.Extra_Reward, function(data)
            self.exchange_data = data
            self:updataExchangeRedPoint()
        end)
    end

    if self.new_msg_add_event == nil then
        self.new_msg_add_event = GlobalEvent:getInstance():Bind(EventId.CHAT_NEWMSG_FLAG, function()
            self:updateChatMsgNum()
        end)
    end

    --红包推送
    if self.red_bag_event == nil then 
        self.red_bag_event = GlobalEvent:getInstance():Bind(RedbagEvent.Can_Get_Red_Bag,function(vo)
            if vo and next(vo) ~=nil then 
                self:showRedBagEffect(true)
            else
                self:showRedBagEffect(false)
            end
        end)
    end

    if self.petard_red_bag_event == nil then
        self.petard_red_bag_event = GlobalEvent:getInstance():Bind(PetardActionEvent.Update_Petard_Main_Redbag_Event, function(code)
            if self.red_bag_2_type == 2 and self.red_bag_container_2 and self.red_bag_container_2:isVisible() == true then
                return
            end
            if code and code ~= 0 then 
                self.red_bag_2_type = 1
                self:showRedBagEffect2(true, code)
            else
                self:showRedBagEffect2(false)
            end
        end)
    end

    if self.year_red_bag_event == nil then
        self.year_red_bag_event = GlobalEvent:getInstance():Bind(ActionyearmonsterEvent.Update_Year_Main_Redbag_Event, function(code)
            if self.red_bag_2_type == 1 and self.red_bag_container_2 and self.red_bag_container_2:isVisible() == true then
                return
            end
            if code and code ~= 0 then 
                self.red_bag_2_type = 2
                self:showRedBagEffect2(true, 2)
            else
                self:showRedBagEffect2(false)
            end
        end)
    end
    

    if self.return_red_bag_event == nil then
        self.return_red_bag_event = GlobalEvent:getInstance():Bind(ReturnActionEvent.Update_Return_Main_Redbag_Event, function(code)
            if code and code ~= 0 then 
                self:showRedBagEffect3(true, code)
            else
                self:showRedBagEffect3(false)
            end
        end)
    end

    if self.time_collect_event == nil then
        self.time_collect_event = GlobalEvent:getInstance():Bind(ActionEvent.Update_Time_Collect_Main_Icon_Event, function(code)
            if code and code == 1 then 
                self:showTimeCollectEffect(true)
            else
                self:showTimeCollectEffect(false)
            end
        end)
    end
    
    

    --合服调查问卷事件
    if self.vote_mergeServer_event == nil then
        self.vote_mergeServer_event = GlobalEvent:getInstance():Bind(MergeserverEvent.Update_Main_Mergeserver_Event, function(data)
            if data and next(data) ~= nil then
                local role_vo = RoleController:getInstance():getRoleVo()
                local server_time = GameNet:getInstance():getTime()
                local lev_limit =  Config.MergeVotingData.data_const.level_limit.val
                local openday_limit =  Config.MergeVotingData.data_const.role_time_limit.val
                local action_type = 1
                if  data.status == 1 then
                    if data.is_vote == 1 then
                        action_type = 2
                    else
                        action_type = 1
                    end
                elseif data.status == 2 then
                    action_type = 1
                end

                if role_vo.lev >= lev_limit and ((server_time - role_vo.reg_time)/86400) >= openday_limit then
                    if data.status == 1  then  --投票期间与公告期间
                        self:showMergeEffect(true, action_type)
                    else
                        self:showMergeEffect(false)
                    end 
                end
                if data.status == 2 then
                    self:showMergeEffect(true, 1)
                end
            end
        end)
    end

    if self.vote_mergeSuccess_event == nil then
        self.vote_mergeSuccess_event = GlobalEvent:getInstance():Bind(MergeserverEvent.Update_Merge_Success_Event, function(data)
            if data.flag == 1  then  --投票成功
                message(data.msg)
                self.show_MergeEffect:setAnimation(0, PlayerAction.action_1, true)
                self.vote_mergeServer_container:setPositionX(-60)
            else
                self.show_MergeEffect:setAnimation(0, PlayerAction.action_2, true)
                self.vote_mergeServer_container:setPositionX(-50)
            end
        end)
    end

    if self.vote_mergeAction_event == nil then
        self.vote_mergeAction_event = GlobalEvent:getInstance():Bind(MergeserverEvent.vote_mergeAction_event, function(status)
            if status == false  then --
                self.show_MergeEffect:setAnimation(0, PlayerAction.action_1, true)
                self.vote_mergeServer_container:setPositionX(-60)
            else
                self.show_MergeEffect:setAnimation(0, PlayerAction.action_2, true)
                self.vote_mergeServer_container:setPositionX(-50)
            end
        end)
    end


    --头部资产更新事件
    if self.update_wealth_event == nil then
        self.update_wealth_event = GlobalEvent:getInstance():Bind(MainuiEvent.HEAD_UPDATE_WEALTH_EVENT, function(index, id)
            if index and id  then
                self.wealth_item_key[index] = Config.ItemData.data_assets_id2label[id]
                self:updateRoleAssets()
            end
        end)
    end


    --系统提示增加
    if not self.update_prompt_tips then 
        self.update_prompt_tips = GlobalEvent:getInstance():Bind(PromptEvent.ADD_PROMPT_DATA,function ( data )
            -- 主城正在显示且不在聊天界面才显示气泡
            if self.is_open and not ChatController:getInstance():isChatOpen() then
            
                local model = PromptController:getInstance():getModel()
                local list = model:getPromptList()
                if tableLen(list) > 0 then 
                    self:showPromptTips(true,list)
                end
            end
        end)
    end

    --系统提示移除
    if not self.remove_prompt_tips then 
        self.remove_prompt_tips = GlobalEvent:getInstance():Bind(PromptEvent.REMOVE_PROMPT_DATA,function (  )
            local model = PromptController:getInstance():getModel()
            local list = model:getPromptList()
            if tableLen(list) > 0 then 
                self:showPromptTips(true,list)
            else
                self:showPromptTips(false)
            end
        end)
    end

    --新手训练营数据刷新
    if not self.update_trainingcamp_data then 
        self.update_trainingcamp_data = GlobalEvent:getInstance():Bind(TrainingcampEvent.Update_Trainingcamp_Data_Event,function (  )
            self:showPromptEffect(true)
            self:updateTipsBtnStatus()
            self:updateCityDesc(false)
            self:updateCityDesc(true)
        end)
    end
    
end

--更新VIP红点
function MainUiView:updataVIPRedPoint()
    if not role_vo then return end
    if MAKELIFEBETTER ~= true then
        if role_vo.lev < 6 then return end
        -- 隐藏vip图标
        -- self.vip_image_btn:setVisible(true)
        -- local red_status_1 = VipController:getInstance():getIsFirst()
        -- local red_status_2 = VipController:getInstance():getModel():getMonthCard()
        -- addRedPointToNodeByStatus(self.vip_image_btn,red_status_1 or red_status_2)
    end
end

--更新点金红点
function MainUiView:updataExchangeRedPoint()
    if not self.exchange_data then
        return
    end
    local red_lev_min =  Config.ConvertData.data_trade_cost.red_lev_min
    for i,v in ipairs(self.exchange_data.list) do
        if v.id == 1 and self.coin_redpoint then
            local status = false
            if (v.max - v.num) > 0 and role_vo and red_lev_min and red_lev_min.val <= role_vo.lev then
                status = true
            end
            addRedPointToNodeByStatus(self.coin_redpoint,status,11,7)
        end
    end
end


function MainUiView:setMergeServerContainerPositionY(is_offset)
    if is_offset then
        self.vote_mergeServer_container:setPositionY(300)
    else
        self.vote_mergeServer_container:setPositionY(300)
    end
end

function MainUiView:setMainUIChatBubbleStatus(status)
    if not tolua_isnull(self.chat_bubble) then
        self.chat_bubble_status = status
        -- 延迟显示
        if self.chat_wait_update == nil and status == true then
            self.chat_wait_update = GlobalTimeTicket:getInstance():add(function()
                if self.chat_bubble_status == true then
                    self.chat_bubble:setVisible(self.chat_bubble_status)
                end
                GlobalTimeTicket:getInstance():remove(self.chat_wait_update)
                self.chat_wait_update = nil
            end, 0.2, 1)
        else
            self.chat_bubble:setVisible(self.chat_bubble_status)
        end
    end
end


--==============================--
--desc:创建聊天泡泡
--time:2018-06-06 05:17:38
--@return 
--==============================--
function MainUiView:createChatBubble()
    -- if role_vo == nil or role_vo.lev < 15 then return end
    if not tolua_isnull(self.chat_bubble) then return end
    if MAKELIFEBETTER == true then return end

    self.chat_bubble = ccui.Layout:create()
    self.chat_bubble:setContentSize(cc.size(44, 44))
    self.chat_bubble:setAnchorPoint(cc.p(0.5,0.5))
    self.chat_bubble:setTouchEnabled(true)

    self.chat_bubble:setPosition(self.handle_x, self.handle_y + 512)

    local bubble_img = createSprite(PathTool.getResFrame("mainui", "mainui_chat_main_icon"), 22, 22, self.chat_bubble, cc.p(0.5,0.5), LOADTEXT_TYPE_PLIST)

    self.chat_red_container = createSprite(PathTool.getResFrame("mainui", "mainui_1034"), 44, 48, self.chat_bubble, cc.p(0.5,0.5), LOADTEXT_TYPE_PLIST)
    self.chat_red_num = createLabel(18, 1, nil, 18, 14, "99", self.chat_red_container, nil, cc.p(0.5,0.5))

    self.chat_bubble:addTouchEventListener(function(sender, event_type)
        customClickAction(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            if self.is_move == false then
                playButtonSound2()
                ChatController:getInstance():openChatPanel()
            end
        elseif event_type == ccui.TouchEventType.began then
            self.is_move = false
            self.touch_began = sender:getTouchBeganPosition()
        elseif event_type == ccui.TouchEventType.moved then
            local pos = sender:getTouchMovePosition()
            if not self.is_move and self.touch_began then
                local is_click = math.abs(pos.x - self.touch_began.x) <= 30 and math.abs(pos.y - self.touch_began.y) <= 30
                if is_click == false then
                    self.is_move = true
                end
            end
            if self.is_move == true then
                pos = sender:getParent():convertToNodeSpaceAR(pos)
                if self:checkPosInRect(pos) then
                    sender:setPosition(cc.p(pos.x, pos.y))
                end
            end
        end
    end)
    self:updateChatMsgNum()
    ViewManager:getInstance():addToLayerByTag(self.chat_bubble, ViewMgrTag.DIALOGUE_TAG)

    if GuideController:getInstance():isInGuide() then
        self:setMainUIChatBubbleStatus(false)
    end 
end

--==============================--
--desc:拖动这个聊天泡泡的时候,判断点是否在可是范围以内
--time:2018-06-06 05:17:38
--@return 
--==============================--
function MainUiView:checkPosInRect(pos)
    local left_x = 0
    local right_x = SCREEN_WIDTH
    local bottom_y = self:getBottomHeight()-math.abs(display.getBottom())
    local top_y = display.getTop()-self:getTopViewHeight()
    local off_space = 40
    if pos.x < (left_x + off_space) then return false end
    if pos.x > (right_x - off_space) then return false end
    if pos.y < (bottom_y + off_space) then return false end
    if pos.y > (top_y - off_space) then return false end

    return true
end

--==============================--
--desc:收缩右下角的图标
--time:2018-06-06 05:17:38
--@return 
--==============================--
function MainUiView:shrinkBtnContainer()
    if self.is_in_shrink == true then return end
    self.is_in_shrink = true

    local layout_1 = self.icon_container_list[FunctionIconVo.type.right_bottom_1]
    local layout_2 = self.icon_container_list[FunctionIconVo.type.right_bottom_2]
    self.is_shrink = not self.is_shrink

    layout_1:setVisible(true)
    layout_2:setVisible(true)

    local len = 100
    local move_by_1 = nil
    local move_by_2 = nil
    local fade_1 = nil
    local fade_2 = nil

    if self.is_shrink == true then
        move_by_1 = cc.MoveBy:create(0.1, cc.p(len, 0))
        move_by_2 = cc.MoveBy:create(0.1, cc.p(0, -len))
        fade_1 = cc.FadeOut:create(0.1)
        fade_2 = cc.FadeOut:create(0.1)
    else
        move_by_1 = cc.MoveBy:create(0.1, cc.p(-len, 0))
        move_by_2 = cc.MoveBy:create(0.1, cc.p(0, len))
        fade_1 = cc.FadeIn:create(0.1)
        fade_2 = cc.FadeIn:create(0.1)
    end

    local call_fun_1 = cc.CallFunc:create(function()
        self.is_in_shrink = false
        if self.is_shrink == true then
            layout_1:setVisible(false)
        end
    end)

    local call_fun_2 = cc.CallFunc:create(function()
        if self.is_shrink == true then
            layout_2:setVisible(false)
        end
    end)
    layout_1:runAction(cc.Sequence:create(cc.Spawn:create(move_by_1, fade_1), call_fun_1)) 
    layout_2:runAction(cc.Sequence:create(cc.Spawn:create(move_by_2, fade_2), call_fun_2)) 
end

function MainUiView:_onClickPromptTips( status )
    if status == false then
        self.prompt_tips_layout:setVisible(false)

    else
        local temp_pos = cc.p(50.38,68.23)
        local is_finish = TrainingcampController:getInstance():getModel():getIsALLFinish()
        if (self.training_camp_lev_limit and self.training_camp_lev_limit.val > role_vo.lev) or is_finish == true then
            temp_pos = cc.p(0,68.23)
        end
        self.prompt_tips_layout:setPosition(temp_pos)
        self.prompt_tips_layout:setVisible(true)
    end
end

-- 检测是否有新的气泡提示
function MainUiView:checkShowNewPromptBubble(  )
    local model = PromptController:getInstance():getModel()

    local list = model:getPromptList()
    if tableLen(list) > 0 then 
        self:showPromptTips(true,list)
    end
end

-- 显示系统提示气泡
function MainUiView:showPromptBubble( )
    local num = math.random(#Config.TrainingCampData.data_city_tips) or 1
    local cof = Config.TrainingCampData.data_city_tips[num]
    if cof then
        self.prompt_bubble_layout:stopAllActions()
        self.prompt_bubble_layout:setVisible(true)
        self.prompt_desc:setString(cof.desc)
        local size = self.prompt_desc:getContentSize()
        self.prompt_bubble:setContentSize(cc.size(size.width + 39, size.height+52))
        local fadein = cc.FadeIn:create(0.7)
        local fadeout = cc.FadeOut:create(0.7)
        local delay_time = cc.DelayTime:create(1.5)
        self.prompt_bubble_layout:runAction(cc.Sequence:create(fadein,delay_time,fadeout))
    end
end

function MainUiView:updateCityDesc(status)
    if status == true then
        local is_all_finish = TrainingcampController:getInstance():getModel():getIsALLFinish()
        if (self.training_camp_lev_limit and self.training_camp_lev_limit.val > role_vo.lev) or (self.prompt_tips_layout and self.prompt_tips_layout:isVisible() == true) or is_all_finish == true then
            status = false
        end
    end
    
    if status then
        if not self.prompt_desc then
            return
        end
        if self.time_ticket == nil then
            local name = "city_tips_cd"
            local is_finish = TrainingcampController:getInstance():getModel():getIsFinish()
            if is_finish == true then
                name = "city_complete_cd"
            end
            
            if Config.TrainingCampData.data_const and Config.TrainingCampData.data_const[name] then
                local config = Config.TrainingCampData.data_const[name] 
                self.time_ticket = GlobalTimeTicket:getInstance():add(function() 
                    self:showPromptBubble()
                end, config.val)
            end
        end
    else
        if self.time_ticket then
            GlobalTimeTicket:getInstance():remove(self.time_ticket)
            self.time_ticket = nil
        end
        if self.prompt_bubble_layout then
            self.prompt_bubble_layout:stopAllActions()
            self.prompt_bubble_layout:setVisible(false)    
        end
    end
end 

--刷新小灯泡状态 is_open_tips 默认为nil
function MainUiView:updateTipsBtnStatus(is_open_tips)
    local status = false
    local is_open_eff = false
    local model = PromptController:getInstance():getModel()
    local list = model:getPromptList()
    if tableLen(list) > 0 then 
        status = true
        is_open_eff = true
    end

    
    if status == true then
        local is_finish = TrainingcampController:getInstance():getModel():getIsALLFinish()
        if self.training_camp_lev_limit and self.training_camp_lev_limit.val <= role_vo.lev and is_finish == false then
            status = false
        else
            is_open_eff = false
        end    
    end

    if self.tips_btn and not tolua_isnull(self.tips_btn) then
        self.tips_btn:setVisible(status)    
    end

    if is_open_tips ~= nil then
        self:_onClickPromptTips(is_open_tips)
    else
        if is_open_eff == false then
            if self.prompt_tips_layout:isVisible() then
                is_open_eff = true
            else
                is_open_eff = false
            end
        end
            
        self:_onClickPromptTips(is_open_eff)
    end
end


-- 显示系统提示
function MainUiView:showPromptTips( status,list )
    if status == true and list and next(list)~=nil then
        self.prompt_tips_scroll:removeAllChildren()
        local max_width = 0
        for k,v in pairs(list) do
            self.count_size_label:setString(v.name)
            local size = self.count_size_label:getContentSize()
            if max_width < size.width then
                max_width = size.width
            end
        end
        if max_width < 168 then
            max_width = 168 --原本的大小
        end
        --字的宽度和按钮的宽度相差20
        max_width = max_width + 20

        local len = tableLen(list)
        local button_height = 49
        local button_height_space = 12
        local res = PathTool.getResFrame("mainui","mainui_tips_bg1") 
        local max_height = math.max(self.prompt_tips_scroll_size.height, len*(button_height_space + button_height))
        local scroll_height = math.min(len*(button_height_space + button_height),160)

        --根据大小调整下scroll和背景大小
        local tips_scroll_width = max_width + 4
        local tips_bg_width = tips_scroll_width + (self.prompt_tips_bg_size.width - self.prompt_tips_scroll_size.width)
        self.prompt_tips_scroll:setContentSize(cc.size(tips_scroll_width, scroll_height))
        self.prompt_tips_scroll:setInnerContainerSize(cc.size(tips_scroll_width, scroll_height))
        self.prompt_tips_bg:setContentSize(cc.size(tips_bg_width, scroll_height + 60))
        
        if scroll_height > 160 then
            self.prompt_tips_scroll:setInnerContainerSize(cc.size(tips_scroll_width, max_height))
        end
        for i,v in pairs(list) do
            local item = createButton(self.prompt_tips_scroll, v.name, tips_scroll_width/2, 5+(button_height_space + button_height)*(i-1) , cc.size(max_width, button_height), res, 22,Config.ColorData.data_color4[175], res, res, LOADTEXT_TYPE_PLIST)
            item:setAnchorPoint(0.5,0)
            item:addTouchEventListener(function ( sender, event_type )
                if event_type == ccui.TouchEventType.ended then
                    controler:onClickPromptTipsItem(v)
                end
            end)
        end
        self:updateTipsBtnStatus(true)
        self:updateCityDesc(false)
    else
        self:updateTipsBtnStatus(false)
        self:updateCityDesc(true)
    end
end

--新手训练营和提示入口特效
function MainUiView:showPromptEffect(bool)
    local is_finish = TrainingcampController:getInstance():getModel():getIsALLFinish()
    if (self.training_camp_lev_limit and self.training_camp_lev_limit.val > role_vo.lev) or is_finish == true then
        bool = false
    end
    
    if bool == true then
        self.effect_container:setVisible(true)
        if not self.show_PromptEffect then
            self.show_PromptEffect = createEffectSpine(PathTool.getEffectRes(160), cc.p(self.prompt_container_effect_size.width/2, 0), cc.p(0.5, 0.5), true, PlayerAction.action)
            self.effect_container:addChild(self.show_PromptEffect, 1)
            self.show_PromptEffect:setScale(5)
        else
            self.show_PromptEffect:setToSetupPose()
        end
        
    else
        if self.show_PromptEffect then 
            self.show_PromptEffect:removeFromParent()
            self.show_PromptEffect = nil
        end
        self.effect_container:setVisible(false)
    end
end

-- 隐藏/显示mianui
function MainUiView:setIsShowMainUI( status )
    self.top_container:stopAllActions()
    self.bottom_container:stopAllActions()
    if status then
        self.top_container:runAction(cc.Spawn:create(cc.MoveTo:create(0.2, cc.p(360, display.getTop())), cc.FadeIn:create(0.2)))
        self.bottom_container:runAction(cc.Spawn:create(cc.MoveTo:create(0.2, cc.p(360, display.getBottom())), cc.FadeIn:create(0.2)))
    else
        self.top_container:runAction(cc.Spawn:create(cc.MoveTo:create(0.2, cc.p(360, display.getTop()+300)), cc.FadeOut:create(0.2)))
        self.bottom_container:runAction(cc.Spawn:create(cc.MoveTo:create(0.2, cc.p(360, display.getBottom()-300)), cc.FadeOut:create(0.2)))
    end
end

function MainUiView:setShowBottomUI( status )
    self.bottom_container:setVisible(status)
end

--==============================--
--desc:移除主ui这个操作只有在切换账号的时候触发
--time:2018-06-06 05:17:38
--@return 
--==============================--
function MainUiView:__delete()
    self:showPromptEffect(false)
    self:updateCityDesc(false)
    if self.function_time_ticket then
        GlobalTimeTicket:getInstance():remove(self.function_time_ticket)
        self.function_time_ticket = nil
    end
    for k, layer in pairs(self.icon_container_list) do
        if layer ~= nil and not tolua_isnull(layer) then
            layer:stopAllActions()
        end
    end
    if self.vip_label then
        self.vip_label:DeleteMe()
        self.vip_label = nil
    end
    if self.vip_image_label then
        self.vip_image_label:DeleteMe()
        self.vip_image_label = nil
    end
    
    -- if self.chat_ui then
    --     self.chat_ui:DeleteMe()
    --     self.chat_ui = nil
    -- end
    if self.add_function_timer ~= nil then
        GlobalTimeTicket:getInstance():remove(self.add_function_timer)
        self.add_function_timer = nil
    end
    if role_vo then
        if self.role_update_event ~= nil then
            role_vo:UnBind(self.role_update_event)
            self.role_update_event = nil
        end
        role_vo = nil
    end
    if self.update_acc then
        GlobalEvent:getInstance():UnBind(self.update_acc)
        self.update_acc = nil
    end

    if self.red_bag_event then 
        GlobalEvent:getInstance():UnBind(self.red_bag_event)
        self.red_bag_event = nil
    end
    if self.petard_red_bag_event then
        GlobalEvent:getInstance():UnBind(self.petard_red_bag_event)
        self.petard_red_bag_event = nil
    end

    if self.year_red_bag_event then
        GlobalEvent:getInstance():UnBind(self.year_red_bag_event)
        self.year_red_bag_event = nil
    end
    
    if self.return_red_bag_event then
        GlobalEvent:getInstance():UnBind(self.return_red_bag_event)
        self.return_red_bag_event = nil
    end

    if self.time_collect_event then
        GlobalEvent:getInstance():UnBind(self.time_collect_event)
        self.time_collect_event = nil
    end
    
    
    if self.new_msg_add_event then
        GlobalEvent:getInstance():UnBind(self.new_msg_add_event)
        self.new_msg_add_event = nil
    end
    if self.update_recharge_red then
        GlobalEvent:getInstance():UnBind(self.update_recharge_red)
        self.update_recharge_red = nil
    end
    if self.vote_mergeServer_event then
        GlobalEvent:getInstance():UnBind(self.vote_mergeServer_event)
        self.vote_mergeServer_event = nil
    end
    if self.vote_mergeSuccess_event then
        GlobalEvent:getInstance():UnBind(self.vote_mergeSuccess_event)
        self.vote_mergeSuccess_event = nil
    end
        if self.vote_mergeAction_event then
        GlobalEvent:getInstance():UnBind(self.vote_mergeAction_event)
        self.vote_mergeAction_event = nil
    end
    if self.update_drama_max_event then
        GlobalEvent:getInstance():UnBind(self.update_drama_max_event)
        self.update_drama_max_event = nil
    end
    if self.update_wealth_event then
        GlobalEvent:getInstance():UnBind(self.update_wealth_event)
        self.update_wealth_event = nil
    end
    if self.update_prompt_tips then
        GlobalEvent:getInstance():UnBind(self.update_prompt_tips)
        self.update_prompt_tips = nil
    end
    if self.remove_prompt_tips then
        GlobalEvent:getInstance():UnBind(self.remove_prompt_tips)
        self.remove_prompt_tips = nil
    end
    if self.coin_touch_redpoint then
        GlobalEvent:getInstance():UnBind(self.coin_touch_redpoint)
        self.coin_touch_redpoint = nil
    end
    if self.vip_image_redpoint then
        GlobalEvent:getInstance():UnBind(self.vip_image_redpoint)
        self.vip_image_redpoint = nil
    end
    if self.vip_image_effect then
        self.vip_image_effect:clearTracks()
        self.vip_image_effect:removeFromParent()
        self.vip_image_effect = nil
    end

    for k, v in pairs(self.function_list) do
        if v.DeleteMe then
            v:DeleteMe()
        end
    end
    self.function_list = {}
    self.render_list = {}
    self.render_list_dic = {}
    self:showRedBagEffect2(false)
    self:showRedBagEffect3(false)
    self:showTimeCollectEffect(false)
    if not tolua_isnull(self.chat_bubble) then
        self.chat_bubble:removeFromParent()
    end
    self.chat_bubble = nil

    if not tolua_isnull(self.node) then
        self.node:removeAllChildren()
        self.node:removeFromParent()
    end
end
