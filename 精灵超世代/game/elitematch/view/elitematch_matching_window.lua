-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      精英赛匹配界面
-- <br/>Create: 2019年2月26日
ElitematchMatchingWindow = ElitematchMatchingWindow or BaseClass(BaseView)

local controller = ElitematchController:getInstance()
local model = controller:getModel()

local hero_controller = HeroController:getInstance()
local hero_model = hero_controller:getModel()

local string_format = string.format
local table_sort = table.sort

function ElitematchMatchingWindow:__init()
    self.win_type = WinType.Full
    self.is_full_screen = true
    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("elitematch_matching", "elitematch_matching"), type = ResourcesType.plist},
        -- {path = PathTool.getPlistImgForDownLoad("bigbg","bigbg_66",true), type = ResourcesType.single }
        {path = PathTool.getPlistImgForDownLoad("bigbg/elitematch", "elitematch_matching_bg", true), type = ResourcesType.single},
        {path = PathTool.getPlistImgForDownLoad("bigbg/elitematch", "elitematch_matching_head", false), type = ResourcesType.single}
    }
    self.layout_name = "elitematch/elitematch_matching_window"


    --标志已经匹配到敌人了
    self.is_match = false

    --标志在匹配中了
    self.is_matching = false

end

function ElitematchMatchingWindow:open_callback(  )
    self.background = self.root_wnd:getChildByName("background")
    self.background:loadTexture(PathTool.getPlistImgForDownLoad("bigbg/elitematch", "elitematch_matching_bg", true), LOADTEXT_TYPE)
    self.background:setScale(display.getMaxScale())

    self.container = self.root_wnd:getChildByName("container")
    self:playEnterAnimatianByObj(self.container, 1)
    self.container_size = self.container:getContentSize()
    self.close_btn = self.container:getChildByName("close_btn")

    --头
    --self.matching_14 = self.container:getChildByName("matching_14")
    --self.matching_14_1 = self.matching_14:getChildByName("matching_14_1")
    self.title_name = self.container:getChildByName("title_name")

    self.vs_node = self.container:getChildByName("vs_node")
    local function _getTeamItem(bg, panel)
        local item = {}
        item.bg = bg
        item.panel = panel

        --阵法icon
        local form_bg = panel:getChildByName("form_bg")
        item.form_icon = form_bg:getChildByName("form_icon")
        item.form_icon:setScale(1.5)

        --战力
        local fight_bg = panel:getChildByName("fight_bg")
        item.fight_label = CommonNum.new(20, fight_bg, 0, - 2, cc.p(0, 0.5))
        item.fight_label:setPosition(15, 36) 

        --位置
        item.pos_list = {}
        item.hero_item_list = {}
        for i=1,9 do
            local item_bg = panel:getChildByName("item_bg_"..i)
            local x, y = item_bg:getPosition()
            item.pos_list[i] = cc.p(x, y)
        end
        return item
    end

    --我方信息
    local up_panel = self.container:getChildByName("up_panel")
    local bg_02_left = up_panel:getChildByName("bg_02_left")
    local bg_02_right = up_panel:getChildByName("bg_02_right")
    local left_panel = up_panel:getChildByName("left_panel")
    local right_panel = up_panel:getChildByName("right_panel")

    self.up_base_info = {}
    --名字
    self.up_base_info.name = up_panel:getChildByName("name")
    self.up_base_info.elite_name = self.up_base_info.name:getChildByName("elite_name")
    self.up_base_info.sex_icon = up_panel:getChildByName("sex_icon")

    --阶级icon
    self.up_base_info.level_icon = up_panel:getChildByName("level_icon")
    self.up_base_info.level_icon_1 = up_panel:getChildByName("level_icon_1")
    --半身像
    self.up_base_info.half_head = up_panel:getChildByName("half_head")


    self.up_left_team_info = _getTeamItem(bg_02_left, left_panel)
    self.up_right_team_info = _getTeamItem(bg_02_right, right_panel)

    --敌方信息
    local down_panel = self.container:getChildByName("down_panel")
    local bg_02_left = down_panel:getChildByName("bg_02_left")
    local bg_02_right = down_panel:getChildByName("bg_02_right")
    local left_panel = down_panel:getChildByName("left_panel")
    local right_panel = down_panel:getChildByName("right_panel")

    self.down_base_info = {}
    --名字
    self.down_base_info.name = down_panel:getChildByName("name")
    self.down_base_info.elite_name = self.down_base_info.name:getChildByName("elite_name")
    self.down_base_info.elite_name:setString("")
    self.down_base_info.sex_icon = self.down_base_info.name:getChildByName("sex_icon")
    --阶级icon
    self.down_base_info.level_icon = down_panel:getChildByName("level_icon")
    self.down_base_info.level_icon_1 = down_panel:getChildByName("level_icon_1")
    --半身像
    self.down_base_info.half_head = down_panel:getChildByName("half_head")

    self.down_left_team_info = _getTeamItem(bg_02_left, left_panel)
    self.down_right_team_info = _getTeamItem(bg_02_right, right_panel)

    --问号半身像
    self.miss_half_head = down_panel:getChildByName("miss_half_head")

    --按钮
    self.left_btn = self.container:getChildByName("left_btn")
    self.left_btn:getChildByName("label"):setString(TI18N("调整阵容"))
    self.right_btn = self.container:getChildByName("right_btn")
    self.right_btn_label = self.right_btn:getChildByName("label")
    self.right_btn_label:setString(TI18N("匹配对手"))

    self.checkbox = self.container:getChildByName("checkbox")
    self.checkbox:getChildByName("name"):setString(TI18N("跳过战前布阵"))
    self.checkbox:setSelected(false)

    self.cool_time = createRichLabel(20, cc.c4b(0xff,0xf8,0xbf,0xff), cc.p(0.5,0.5), cc.p(560,182), nil, nil, 600)
    self.container:addChild(self.cool_time)

    self.step_time = createRichLabel(28, cc.c4b(0xff,0xf8,0xbf,0xff), cc.p(0.5,0.5), cc.p(360,223), nil, nil, 600)
    self.container:addChild(self.step_time)
    -- --比赛时间
    -- self.match_time = createRichLabel(24, cc.c4b(0xff,0xf8,0xbf,0xff), cc.p(0.5,0.5), cc.p(360,-21), nil, nil, 600)
    -- self.top_panel:addChild(self.match_time)

    local buy_panel = self.container:getChildByName("buy_panel")
    buy_panel:getChildByName("key"):setString(TI18N("匹配次数:"))
    self.buy_count = buy_panel:getChildByName("label")
    self.buy_btn = buy_panel:getChildByName("add_btn")

    self.buy_tips = createRichLabel(18, 1, cc.p(0.5,0.5), cc.p(580,136), nil, nil, 600)
    self.container:addChild(self.buy_tips)

    self:adaptationScreen()
end

--设置适配屏幕
function ElitematchMatchingWindow:adaptationScreen()
    --对应主窗口.四面对应xy位置 ..相对位置是self.main_container左下角(0,0)
    -- local top_y = display.getTop(self.container)
    local bottom_y = display.getBottom(self.container)
    -- local left_x = display.getLeft(self.container)
    -- local right_x = display.getRight(self.container)

    local close_btn_y = self.close_btn:getPositionY()
    self.close_btn:setPositionY(bottom_y + close_btn_y)

    -- --主菜单 顶部的高度
    -- local top_height = MainuiController:getInstance():getMainUi():getTopViewHeight()
    -- --主菜单 底部的高度
    -- local bottom_height = MainuiController:getInstance():getMainUi():getTopViewHeight()
end

--加载所用到的音效( 移除 的是自动化管理的 音效用完6秒后 会被移除)
function ElitematchMatchingWindow:reloadAudioEffect()
    self.audio_list = {
        [1] = PathTool.getSound(AudioManager.AUDIO_TYPE.COMMON, "c_vs") --vs 音效
        ,[2] = PathTool.getSound(AudioManager.AUDIO_TYPE.COMMON, "c_scroll") -- 滚动音效
    }

    for i,path in pairs(self.audio_list) do
        AudioManager:getInstance():preLoadEffectByPath(v)    
    end
    -- AudioManager:getInstance():playEffect(AudioManager.AUDIO_TYPE.COMMON,"c_scroll", true)
end

--配置当前显示的ui
function ElitematchMatchingWindow:configShowUI()
    --清空一下可能出现的信息
    if self.step_time then
        self.step_time:setString("")
    end

    local title_res
    if self.match_type == ElitematchConst.MatchType.eNormalMatch then
        self.title_name_str = TI18N("常规赛 匹配")
        self.title_name:setString(self.title_name_str)
        --title_res = PathTool.getResFrame("elitematch_matching", "elitematch_matching_14")
        --self.up_left_team_info.bg:setPositionX(155)
        self.up_left_team_info.panel:setPositionX(155)

        self.down_base_info.name:setVisible(false)
        self.down_base_info.level_icon:setVisible(false)
        self.down_base_info.level_icon_1:setVisible(false)
        self.down_base_info.sex_icon:setVisible(false)
        self.down_base_info.half_head:setVisible(false)

        --self.down_right_team_info.bg:setVisible(false)
        self.down_right_team_info.panel:setVisible(false)

        self.half_head_x = self.down_base_info.half_head:getPositionX()
        self.down_right_x = self.down_right_team_info.panel:getPositionX()
        self.down_y = self.down_right_team_info.panel:getPositionY()
    else
        self.title_name_str = TI18N("常规赛 匹配")
        self.title_name:setString(self.title_name_str)
        title_res = PathTool.getResFrame("elitematch_matching", "elitematch_matching_15")
        
        --self.up_left_team_info.bg:setPositionX(196)
        self.up_left_team_info.panel:setPositionX(196)

        --self.up_right_team_info.bg:setVisible(true)
        self.up_right_team_info.panel:setVisible(true)
        --基本信息
        self.down_base_info.name:setVisible(false)
        self.down_base_info.level_icon:setVisible(false)
        self.down_base_info.level_icon_1:setVisible(false)
        self.down_base_info.sex_icon:setVisible(false)
        self.down_base_info.half_head:setVisible(false)
        --右边信息
        --self.down_right_team_info.bg:setPositionX(530)
        self.down_right_team_info.panel:setPositionX(530)

        --self.down_right_team_info.bg:setVisible(false)
        self.down_right_team_info.panel:setVisible(false)
        --左边信息
        --self.down_left_team_info.bg:setVisible(false)
        self.down_left_team_info.panel:setVisible(false)

        self.down_right_x = self.down_right_team_info.panel:getPositionX()
        self.down_left_x = self.down_left_team_info.panel:getPositionX()
        self.down_y = self.down_right_team_info.panel:getPositionY()
    end
    
    local head_res = PathTool.getPlistImgForDownLoad("bigbg/elitematch", "elitematch_matching_head", false)
    loadSpriteTexture(self.miss_half_head, head_res, LOADTEXT_TYPE)
    --if title_res then
    --    loadSpriteTexture(self.matching_14, title_res, LOADTEXT_TYPE_PLIST)
    --    loadSpriteTexture(self.matching_14_1, title_res, LOADTEXT_TYPE_PLIST)
    --end
end


function ElitematchMatchingWindow:register_event(  )
    registerButtonEventListener(self.close_btn, handler(self, self.onClickCloseBtn), true, 2)
    registerButtonEventListener(self.left_btn, handler(self, self.onClickLeftBtn), true, 1)
    registerButtonEventListener(self.buy_btn, handler(self, self.onClickBuyCountBtn), true, 1)

    --跳过战前布阵
    self.checkbox:addEventListener(function ( sender,event_type )
        playButtonSound2()
        if  not self.scdata then return end
        local is_select = self.checkbox:isSelected()

        if is_select then
            self.scdata.is_skip = 1
        else
            self.scdata.is_skip = 0
        end
    end)

    self.right_btn:addTouchEventListener(function(sender, event_type)
        if self.unenble_right_btn  then
            return
        end
        customClickAction(sender, event_type, scale)
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            self:onClickRightBtn()
        end
    end)
    self:addGlobalEvent(ElitematchEvent.Get_Elite_Enemy_Info_Event, function(data)
        if not data then return end
        self:setData(data)
    end)

    --布阵信息返回
    self:addGlobalEvent(ElitematchEvent.Update_Elite_Fun_Form, function(data)
        if not data then return end
        if self.match_type == data.type then
            if self.match_type == ElitematchConst.MatchType.eKingMatch and #data.formations == 1 then                --说明第二队伍没有信息 模拟
               self:updateMyTeamInfo({formation_type = 1, pos_info = {}}, 2) 
            end

            for i,v in ipairs(data.formations) do
                self:updateMyTeamInfo(v, v.order)
            end
        end
    end)

    --发送出战协议
    self:addGlobalEvent(ElitematchEvent.Update_Elite_Save_Form, function(data)
        if not data then return end
        controller:sender24920(self.match_type)
    end)

    --购买次数
    self:addGlobalEvent(ElitematchEvent.Elite_buy_count_Event, function(data)
        if not data then return end
        self.scdata.day_buy_count = data.day_buy_count
        self.scdata.day_combat_count = data.day_combat_count
        if self.enemy_scdata then
            self.enemy_scdata.day_combat_count = data.day_combat_count
        end
        self:updateBuyCount(data.day_combat_count)
        if self.is_send_matching then
            self.is_send_matching = false
            self:onClickRightBtn()
        end
    end)

    --挑战对手失败
    self:addGlobalEvent(ElitematchEvent.Elite_Fight_Fail_Event, function()
       self.is_send24903 = false
    end)
    --战斗结算
    self:addGlobalEvent(ElitematchEvent.Elite_Fight_Result_Event, function()
        self:reloadMatchUI()    
    end)

    --主信息返回了.说明可以继续打了
    self:addGlobalEvent(ElitematchEvent.Get_Elite_Main_Info_Event, function(scdata)
        if not scdata then return end
        self:updateLevelUpInfo()
        self:updateHeadInfo(self.up_base_info, nil, scdata.lev, nil)
        if self.enemy_scdata then
            self.enemy_scdata.day_combat_count = scdata.day_combat_count
        end
        self:updateBuyCount(scdata.day_combat_count)
        self.is_send24903 = false
    end)

end

-- 关闭
function ElitematchMatchingWindow:onClickCloseBtn(  )
    controller:openElitematchMatchingWindow(false)
end

-- 购买次数
--@ is_matching 是否匹配进来
function ElitematchMatchingWindow:onClickBuyCountBtn(is_matching)
    if not self.scdata  then return end
    if self.scdata.state == 0 then return end

    local config = Config.ArenaEliteData.data_elite_const.match_count
    if config then 
        -- if self.scdata.day_combat_count >= config.val then
        --     message(TI18N("匹配次数已满"))
        --     return
        -- end

        local buy_config = Config.ArenaEliteData.data_elite_buy[(self.scdata.day_buy_count + 1)]

        if buy_config == nil then
            if is_matching then
                message(TI18N("已达到今日挑战次数上限"))
            else
                message(TI18N("购买次数已达上限"))
            end
            return
        end
        

        if buy_config.need_vip > 0 then
            local role_vo = RoleController:getInstance():getRoleVo()
            if role_vo and role_vo.vip_lev < buy_config.need_vip then
                message(string_format(TI18N("需要vip%s才能购买"), buy_config.need_vip))
                return
            end
            if role_vo == nil then
                return
            end
        end
        
        local item_id =  buy_config.cost[1][1] 
        local count =  buy_config.cost[1][2] 
        local iconsrc = PathTool.getItemRes(Config.ItemData.data_get_data(item_id).icon)
        local str
        if is_matching then
            str = string_format(TI18N("匹配次数不足, 是否花费 <img src='%s' scale=0.3 /> %s购买一次匹配次数？"), iconsrc, count, config.val)
        else
            str = string_format(TI18N("是否花费 <img src='%s' scale=0.3 /> %s购买一次匹配次数？"), iconsrc, count, config.val)
        end
         
        local call_back = function()
            self.is_send_matching = is_matching
            controller:sender24904()
        end
        CommonAlert.show(str, TI18N("确定"), call_back, TI18N("取消"), nil, CommonAlert.type.rich)
    end
end


-- 调整阵容
function ElitematchMatchingWindow:onClickLeftBtn(  )
    if not self.enemy_scdata then return end
    if self.is_match then
        local time = self.enemy_scdata.to_combat_time - GameNet:getInstance():getTime()
        if time <= 0 then
            --说明开战了 不给调整布阵了
            return 
        end
        HeroController:getInstance():openFormMainWindow(true, PartnerConst.Fun_Form.EliteMatch, {match_type = self.match_type, end_time = self.enemy_scdata.to_combat_time})
    else
        HeroController:getInstance():openFormMainWindow(true, PartnerConst.Fun_Form.EliteMatch, {match_type = self.match_type})
    end
end

-- 我要挑战
function ElitematchMatchingWindow:onClickRightBtn(  )
    if not self.enemy_scdata then return end

    if self.is_matching then
        message(TI18N("匹配中..."))
        return 
    end
    
    if self.is_match then
        if self.is_send24903 then
            return 
        end
        self.is_match = false
        self.is_send24903 = true
        controller:sender24903()
        -- self:reloadMatchUI()
        -- self:onClickCloseBtn()
    else
        if self.enemy_scdata.day_combat_count == 0 then
            self:onClickBuyCountBtn(true)
            return
        end
        local cur_time = GameNet:getInstance():getTime()
        if cur_time < self.enemy_scdata.match_cd_time then
            return
        end
        self.is_matching = true
        controller:sender24902(self.scdata.is_skip)
        if self.miss_half_head then
            self.miss_half_head:setVisible(false)
        end
        self:playMatchEffect(true)
        self.checkbox:setVisible(false)
        self.is_time_out = false
        self.is_data_back = false

        self:setBtnTime()
        delayRun(self.container, 1, function() 
            self.is_time_out = true
            self:setDataByCondition()
        end)
    end
end

function ElitematchMatchingWindow:reloadMatchUI()
    self.is_match = false
    if self.miss_half_head then
        self.miss_half_head:setVisible(true)
    end
    self.checkbox:setVisible(true)
    
    self.step_time:stopAllActions()
    self.step_time:setString("")

    self.right_btn_label:stopAllActions()
    self.right_btn_label:setString(TI18N("匹配对手"))
    self:playVsEffect(false)

    if self.match_type == ElitematchConst.MatchType.eNormalMatch then
        self.down_base_info.half_head:setVisible(false)
    else
        --左边信息
        --self.down_left_team_info.bg:setVisible(false)
        self.down_left_team_info.panel:setVisible(false)
    end
    --右边信息
    --self.down_right_team_info.bg:setVisible(false)
    self.down_right_team_info.panel:setVisible(false)

    self.down_base_info.name:setVisible(false)
    self.down_base_info.level_icon:setVisible(false)
    self.down_base_info.level_icon_1:setVisible(false)
    self.down_base_info.sex_icon:setVisible(false)
    
    self.down_base_info.elite_name:setString("")
    self.left_btn:setVisible(true)
    self.right_btn:setVisible(true)
end

function ElitematchMatchingWindow:setDataByCondition(time)
    -- if not self.is_matching then end
    if self.is_time_out and self.is_data_back then
        self.left_btn:setVisible(true)
        self.right_btn:setVisible(true)
        self.right_btn_label:stopAllActions()
        self.right_btn_label:setString(TI18N("立刻挑战"))

        self.checkbox:setVisible(false)

        self.is_match = true
        self:updateMatchBtn(false)
        self:playMatchEffect(false)
        if self.miss_half_head then
            self.miss_half_head:setVisible(false)
        end

        if self.enemy_scdata then
            --后端说默认拿第一个...
            local rand = self.enemy_scdata.rand_list[1]
            for i,v in ipairs(rand.defense) do
                if v.type == self.match_type then
                    table_sort(v.defense_info, function(a,b) return a.order < b.order end)
                    for k,t in ipairs(v.defense_info) do
                        self:updateEnemyTeamInfo(t, t.order, rand)   
                    end
                    if self.match_type == ElitematchConst.MatchType.eKingMatch and #v.defense_info == 1 then
                        --说明第二队伍没有信息 模拟
                       self:updateEnemyTeamInfo({formation_type = 1, partner_infos = {}}, 2) 
                    end
                end
            end
            local srv_name = getServerName(rand.srv_id)
            local name = string_format("[%s]%s", srv_name, rand.name)
            self:updateHeadInfo(self.down_base_info, name, rand.elite_lev, rand.look_id, rand.sex)
        end
        self.is_matching = false
        local time = time or 5
        self:setStepTime(time)
    end
end

--@setting.match_type 比赛类型  参考ElitematchConst.MatchType.eNormalMatch
--@setting.scdata 29400数据
function ElitematchMatchingWindow:openRootWnd( setting)
    local setting = setting or {}
    local match_type = setting.match_type or ElitematchConst.MatchType.eNormalMatch
    self.scdata = setting.scdata
    if not self.scdata then return end
    self.is_time_out = true
    self.is_matching = false
    
    self.match_type = match_type

    self.level_id = self.scdata.lev
    self:configShowUI()


    if self.scdata.is_skip and self.scdata.is_skip == 1 then
        self.checkbox:setSelected(true)
    else
        self.checkbox:setSelected(false)
    end
    self.checkbox:setVisible(false)
    -- hero_controller:sender11211(PartnerConst.Fun_Form.EliteMatch)
    controller:sender24920(self.match_type)
    controller:sender24901()
end

function ElitematchMatchingWindow:setData(data)
    self.enemy_scdata = data
    self:updateBuyCount(self.enemy_scdata.day_combat_count)
    GlobalEvent:getInstance():Fire(ElitematchEvent.Elite_Challenge_count_Event, data)
    
    self:updateLevelUpInfo()
    if self.enemy_scdata.is_match == 1 then
        --在匹配中
        self.right_btn_label:setString(TI18N("匹配对手"))
        self.checkbox:setVisible(false)
        self:updateMatchBtn(true)
        self:playMatchEffect(true)
        self.is_matching = true
        self.is_data_back = false
        self:setBtnTime()
        if self.miss_half_head then
            self.miss_half_head:setVisible(false)
        end
        return
    end
    self.checkbox:setVisible(true)
    if #self.enemy_scdata.rand_list > 0 then
        --已有匹配对手
        self.is_data_back = true
        local time = data.to_combat_time - GameNet:getInstance():getTime()
        if time < 0 then
            time = 0 
        end
        self:setDataByCondition(time)
        -- self.enemy_scdata
    else
        self:playMatchEffect(false)
        self:updateMatchBtn(true)
        self.is_matching = false
        self:reloadMatchUI()
    end
end

function ElitematchMatchingWindow:updateLevelUpInfo()
    if not self.scdata then return end
    if #self.scdata.promoted_info > 0 then
        -- 表示晋级赛
        self.title_name:setString(self.title_name_str..TI18N("(升段赛)"))
    else
        self.title_name:setString(self.title_name_str)
    end
end

function ElitematchMatchingWindow:updateMatchBtn(status)
    if not self.enemy_scdata then return end
    if status then
        local cur_time = GameNet:getInstance():getTime()
        if cur_time < self.enemy_scdata.match_cd_time then
            --说明有冷却时间
            --self.right_btn_label:disableEffect(cc.LabelEffect.OUTLINE)
            setChildUnEnabled(true, self.right_btn)
            --变灰按钮中
            self.unenble_right_btn = true
            local time = self.enemy_scdata.match_cd_time - cur_time
            self:setCoolTime(time)
        end
    else
        self.cool_time:stopAllActions()
        self.cool_time:setString("")
        self.unenble_right_btn = false
        setChildUnEnabled(false, self.right_btn)
        --self.right_btn_label:enableOutline(Config.ColorData.data_color4[264], 2)
    end
end

--设置冷却时间的倒计时
function ElitematchMatchingWindow:setCoolTime(less_time)
    if tolua.isnull(self.cool_time) then
        return
    end
    local less_time =  less_time or 0
    self.cool_time:stopAllActions()
    if less_time > 0 then
        self:setCoolTimeFormatString(less_time)
        self.cool_time:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1),
            cc.CallFunc:create(function()
                less_time = less_time - 1
                if less_time < 0 then
                    self.cool_time:stopAllActions()
                else
                    self:setCoolTimeFormatString(less_time)
                end
            end))))
    else
        self:setCoolTimeFormatString(less_time)
    end
end

function ElitematchMatchingWindow:setCoolTimeFormatString(time)
    if time > 0 then
        local str = string.format(TI18N("<div outline=2,#000000>冷却时间:</div><div fontcolor=#3df424 outline=2,#000000>%s</div>"), TimeTool.GetTimeDayOrTime(time))
        self.cool_time:setString(str)
    else
        self:updateMatchBtn(false)
    end
end

--设置倒计时
function ElitematchMatchingWindow:setStepTime(less_time)
    local less_time =  less_time or 0
    if tolua.isnull(self.step_time) then
        return
    end
    self.step_time:stopAllActions()
    if less_time > 0 then
        self:setStepTimeFormatString(less_time)
        self.step_time:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1),
            cc.CallFunc:create(function()
                less_time = less_time - 1
                if less_time < 0 then
                    self.step_time:stopAllActions()
                    -- self:onClickRightBtn()
                    self.step_time:setString("")
                else
                    self:setStepTimeFormatString(less_time)
                end
            end))))
    else
        self:setStepTimeFormatString(less_time)
    end
end

function ElitematchMatchingWindow:setStepTimeFormatString(time)
    local str = string.format(TI18N("<div fontcolor=#3df424 outline=2,#000000>%s</div><div outline=2,#000000> 秒后进入战斗</div>"), time)
    self.step_time:setString(str)
end


--设置倒计时
function ElitematchMatchingWindow:setBtnTime()
    if tolua.isnull(self.right_btn_label) then
        return 
    end
    self.right_btn_label:stopAllActions()
    local btn_time = 1
    self:setBtnTimeFormatString(btn_time)
    self.right_btn_label:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(0.5),
    cc.CallFunc:create(function()
            btn_time = btn_time + 1
            if btn_time > 4 then
                btn_time = 1
            end
            self:setBtnTimeFormatString(btn_time)
    end))))
   
end

function ElitematchMatchingWindow:setBtnTimeFormatString(time)
    if time == 1 then
        self.right_btn_label:setString(TI18N("匹配中."))
    elseif time == 2 then
        self.right_btn_label:setString(TI18N("匹配中.."))
    elseif time == 3 then
        self.right_btn_label:setString(TI18N("匹配中..."))
    else
        self.right_btn_label:setString(TI18N("匹配中"))
    end

end

--更新我方信息
function ElitematchMatchingWindow:updateMyTeamInfo(data, index)
    local up_team_info
    if self.match_type == ElitematchConst.MatchType.eNormalMatch then
        if index == 1 then
            up_team_info = self.up_left_team_info
            self.my_team_left_scdata = data
        else
            return
        end
    elseif self.match_type == ElitematchConst.MatchType.eKingMatch then
        if index == 1 then
            up_team_info = self.up_left_team_info
            self.my_team_left_scdata = data
        elseif index == 2 then
            up_team_info = self.up_right_team_info
            self.my_team_right_scdata = data
        else
            return
        end
    end

    self:updateFormIcon(up_team_info, data.formation_type)
    self:updateHeroInfo(up_team_info, data.pos_info, data.formation_type)

    if index == 1 then
        local role_vo = RoleController:getInstance():getRoleVo()
        local srv_name = getServerName(role_vo.srv_id)
        local name = string_format("[%s]%s", srv_name, role_vo.name)
        self:updateHeadInfo(self.up_base_info, name, self.level_id, role_vo.look_id, role_vo.sex)
    end
end
--更新敌方信息
function ElitematchMatchingWindow:updateEnemyTeamInfo(defense_info, index, role_data)
    local down_team_info
    local temp_x = 360
    if self.match_type == ElitematchConst.MatchType.eNormalMatch then
        if index == 1 then
            down_team_info = self.down_right_team_info
            self.enemy_team_right_scdata = defense_info

            self:playVsEffect(true)
            self:playFireEffect(true)
            self:runDownAction(self.down_base_info.half_head, self.half_head_x - temp_x, self.half_head_x)
            --self:runDownAction(self.down_right_team_info.bg, self.down_right_x + temp_x, self.down_right_x)
            self:runDownAction(self.down_right_team_info.panel, self.down_right_x + temp_x, self.down_right_x)

            self.down_base_info.name:setVisible(true)
            self.down_base_info.level_icon:setVisible(true)
            self.down_base_info.level_icon_1:setVisible(true)
            self.down_base_info.sex_icon:setVisible(true)
            self.down_base_info.half_head:setVisible(true)

        else
            return
        end
    elseif self.match_type == ElitematchConst.MatchType.eKingMatch then
        if index == 1 then
            down_team_info = self.down_left_team_info
            self.enemy_team_left_scdata = defense_info

            self:playVsEffect(true)
            self:playFireEffect(true)
            --self:runDownAction(self.down_left_team_info.bg, self.down_left_x - temp_x, self.down_left_x)
            self:runDownAction(self.down_left_team_info.panel, self.down_left_x - temp_x, self.down_left_x)

            self.down_base_info.name:setVisible(true)
            self.down_base_info.level_icon:setVisible(true)
            self.down_base_info.level_icon_1:setVisible(true)
            self.down_base_info.sex_icon:setVisible(true)

        elseif index == 2 then
            down_team_info = self.down_right_team_info
            self.enemy_team_right_scdata = defense_info
            --self:runDownAction(self.down_right_team_info.bg, self.down_right_x + temp_x, self.down_right_x)
            self:runDownAction(self.down_right_team_info.panel, self.down_right_x + temp_x, self.down_right_x)
        else
            return
        end
    end
    --down_team_info.bg:setVisible(true)
    down_team_info.panel:setVisible(true)
    self:updateFormIcon(down_team_info, defense_info.formation_type)
    self:updateHeroInfo(down_team_info, defense_info.partner_infos, defense_info.formation_type, true, role_data)
end

function ElitematchMatchingWindow:runDownAction(runObj, start_x, end_x)
    local temp_x = 360
    runObj:setPositionX(start_x)
    local moveto1 = cc.EaseSineOut:create(cc.MoveTo:create(0.4,cc.p(end_x, self.down_y)))
    runObj:runAction(moveto1)
end

--更新头信息 名字 阶级icon
function ElitematchMatchingWindow:updateHeadInfo(base_info, name, level_id, look_id, sex)
    if not base_info then return end

    if sex then 
        local res
        if sex == 1 then
            res = PathTool.getResFrame("common", "common_sex1")
        else
            res = PathTool.getResFrame("common", "common_sex0")
        end
        loadSpriteTexture(base_info.sex_icon, res, LOADTEXT_TYPE_PLIST)
    end
    --名字
    if name then
        base_info.name:setString(name)
    end
    --阶级icon
    if level_id then
        local config = Config.ArenaEliteData.data_elite_level[level_id]
        if config then
            base_info.elite_name:setString(config.name)
            local name = config.little_ico
            if name == nil or name == "" then
                name = "icon_iron"
            end
            local bg_res = PathTool.getPlistImgForDownLoad("elitematch/elitematch_icon",name, false)
            base_info.little_item_load = loadSpriteTextureFromCDN(base_info.level_icon , bg_res, ResourcesType.single, base_info.little_item_load)
            base_info.level_icon:setScale(0.2)
            name = config.little_name_ico
            if name == nil or name == "" then
                name = "num_2_2"
            end
            local bg_res = PathTool.getPlistImgForDownLoad("elitematch/elitematch_icon",name, false)
            base_info.little_item_load_1 = loadSpriteTextureFromCDN(base_info.level_icon_1 , bg_res, ResourcesType.single, base_info.little_item_load_1)


        end
    end

    if self.match_type == ElitematchConst.MatchType.eNormalMatch then
        --半身像
        if look_id then
            local config = Config.LooksData.data_data[look_id]
            if config==nil then
                config = Config.LooksData.data_data[110401]
            end
            if config then
                local res = PathTool.getPartnerBustRes(config.mvp_res)
                print("res",res)
                base_info.item_load = loadSpriteTextureFromCDN(base_info.half_head, res, ResourcesType.single, base_info.item_load)
            end
        end
    else
        base_info.half_head:setVisible(false)
    end
end

--更新队伍阵法icon 
--@team_info 结构 对应  self.up_left_team_info self.up_left_team_info 这些
--@formation_type 阵法类型
function ElitematchMatchingWindow:updateFormIcon(team_info,formation_type)
    if not team_info then return end
        --阵法
    if formation_type then
        if formation_type < 1 then
            formation_type = 1
        end
        if formation_type > 6 then
            formation_type = 6
        end
        local res = PathTool.getResFrame("elitematch_matching", "elitematch_form_icon_"..formation_type)
        loadSpriteTexture(team_info.form_icon, res, LOADTEXT_TYPE_PLIST)
    end
end


--@更新队伍战力
--@team_info 结构 对应  self.up_left_team_info self.up_left_team_info 这些
function ElitematchMatchingWindow:updateTeamPower(team_info, power)
    if not team_info then return end
        --战力
    if power then
        team_info.fight_label:setNum(power)
    end
end

--更新宝可梦信息
--@team_info 结构 对应  self.up_left_team_info self.up_left_team_info 这些
--@pos_info 队伍信息
--@formation_type 阵法类型
--@is_other_team 是否别人队伍 表示是网络返回的队友队伍或者敌方队伍
--@other_info 如果是别人队伍.那么是记录队友或者敌方的 角色信息 
function ElitematchMatchingWindow:updateHeroInfo(team_info, pos_info, formation_type, is_other_team, other_info)
    if not team_info then return end
    --队伍位置
    local formation_config = Config.FormationData.data_form_data[formation_type]
    if formation_config then

        --转换位置信息
        local dic_pos_info = {}
        for k,v in pairs(pos_info) do
            dic_pos_info[v.pos] = v
        end

        for k,item in pairs(team_info.hero_item_list) do
            item:setVisible(false)
        end
        local power = 0
        for i,v in ipairs(formation_config.pos) do
            local index = v[1] 
            local pos = v[2] 
            local hero_vo 
            if is_other_team then
                hero_vo = dic_pos_info[index]
                if hero_vo and hero_vo.extra then
                    for i,v in ipairs(hero_vo.extra) do
                        if v.key == 5 then
                            hero_vo.use_skin = v.val
                        end
                    end
                end
            else
                if dic_pos_info[index] then
                    hero_vo = hero_model:getHeroById(dic_pos_info[index].id)
                end
            end
            if hero_vo then
                --这里bugly说power是nil value 错的莫名其妙呀..先容错..--by lwc
                local ppower = hero_vo.power or 0
                power = power + ppower
            end
            
            --更新位置
            if team_info.hero_item_list[index] == nil then
                team_info.hero_item_list[index] = HeroExhibitionItem.new(0.7, false)
                team_info.panel:addChild(team_info.hero_item_list[index])
            else
                team_info.hero_item_list[index]:setVisible(true)
            end
            team_info.hero_item_list[index]:setPosition(team_info.pos_list[pos])
            
            if hero_vo then
                team_info.hero_item_list[index]:setData(hero_vo)
                team_info.hero_item_list[index]:addCallBack(function()
                    if  is_other_team then
                        -- ArenaController:getInstance():requestRabotInfo(other_info.rid, other_info.srv_id, index)
                    else
                        HeroController:getInstance():openHeroTipsPanel(true, hero_vo)
                    end
                end)
            else
                team_info.hero_item_list[index]:setData(nil)
            end
        end
        self:updateTeamPower(team_info, power)
    end
end

--播放匹配的效果
function ElitematchMatchingWindow:playMatchEffect(status)
    if status == false then
        if self.play_effect then
            self.play_effect:clearTracks()
            self.play_effect:removeFromParent()
            self.play_effect = nil
        end
        if self.scroll_audio_effect then
            AudioManager:getInstance():removeEffectBySoundId(self.scroll_audio_effect)
            self.scroll_audio_effect = nil
        end
    else
        -- self.play_effect = createEffectSpine(Config.EffectData.data_effect_info[681], cc.p(0, 0), cc.p(0.5, 0.5), false, PlayerAction.action_2)
        if self.scroll_audio_effect == nil then
            self.scroll_audio_effect = AudioManager:getInstance():playEffectForHandAudoRemove(AudioManager.AUDIO_TYPE.COMMON,"c_scroll", true)
        end
        self.play_effect = createEffectSpine("E24161", cc.p(7, -261), cc.p(0.5, 0.5), true, PlayerAction.action)
        self.vs_node:addChild(self.play_effect, 1)
    end
end


--播放vs的效果
function ElitematchMatchingWindow:playVsEffect(status)
    if status == false then
        if self.play_effect1 then
            self.play_effect1:clearTracks()
            self.play_effect1:removeFromParent()
            self.play_effect1 = nil
        end
    else
        -- self.play_effect1 = createEffectSpine(Config.EffectData.data_effect_info[681], cc.p(0, 0), cc.p(0.5, 0.5), false, PlayerAction.action_2)
        self.vs_audio_effect = AudioManager:getInstance():playEffect(AudioManager.AUDIO_TYPE.COMMON,"c_vs")
        self.play_effect1 = createEffectSpine("E24162", cc.p(0, -10), cc.p(0.5, 0.5), false, PlayerAction.action)
        self.vs_node:addChild(self.play_effect1, 1)
    end
end

--播放火花的效果
function ElitematchMatchingWindow:playFireEffect(status)
    if status == false then
        if self.play_effect2 then
            self.play_effect2:clearTracks()
            self.play_effect2:removeFromParent()
            self.play_effect2 = nil
        end
    else
        -- self.play_effect2 = createEffectSpine(Config.EffectData.data_effect_info[681], cc.p(0, 0), cc.p(0.5, 0.5), false, PlayerAction.action_2)
        self.play_effect2 = createEffectSpine("E24163", cc.p(-231, -398), cc.p(0.5, 0.5), false, PlayerAction.action)
        self.vs_node:addChild(self.play_effect2, 1)
    end
end

--@day_combat_count 剩余匹配次数
function ElitematchMatchingWindow:updateBuyCount(day_combat_count)
    if not self.scdata then return end
    local day_combat_count = day_combat_count or 1
    local config = Config.ArenaEliteData.data_elite_const.match_count
    if config then
        local str = string_format("%s/%s",day_combat_count, config.val)
        self.buy_count:setString(str)
    end

    local day_buy_count = self.scdata.day_buy_count or 1
    
    local count = self.scdata.day_max_buy_count - day_buy_count
    if count < 0 then
        count = 0
    end
    local str = string.format(TI18N("<div outline=2,##3D5078>%s</div><div fontcolor=#0CFF01 >%s</div>"),TI18N("剩余购买次数:"), count)
    self.buy_tips:setString(str)
    
end

function ElitematchMatchingWindow:close_callback(  )
    BattleController:getInstance():openBattleView(false)
    -- 还原ui战斗类型
    MainuiController:getInstance():resetUIFightType()

    if self.role_vo ~= nil then
        if self.role_assets_event ~= nil then
            self.role_vo:UnBind(self.role_assets_event)
            self.role_assets_event = nil
        end
    end

    if self.up_base_info.item_load then
        self.up_base_info.item_load:DeleteMe()
    end
    self.up_base_info.item_load = nil

    if self.down_base_info.item_load then
        self.down_base_info.item_load:DeleteMe()
    end
    self.down_base_info.item_load = nil

    if self.up_base_info.little_item_load then
        self.up_base_info.little_item_load:DeleteMe()
    end
    self.up_base_info.little_item_load = nil

    if self.down_base_info.little_item_load then
        self.down_base_info.little_item_load:DeleteMe()
    end
    self.down_base_info.little_item_load = nil

    if self.up_base_info.little_item_load_1 then
        self.up_base_info.little_item_load_1:DeleteMe()
    end
    self.up_base_info.little_item_load_1 = nil

    if self.down_base_info.little_item_load_1 then
        self.down_base_info.little_item_load_1:DeleteMe()
    end
    self.down_base_info.little_item_load_1 = nil

    if self.up_left_team_info and self.up_left_team_info.fight_label then
        self.up_left_team_info.fight_label:DeleteMe()
        self.up_left_team_info.fight_label = nil
    end
    if self.up_right_team_info and self.up_right_team_info.fight_label then
        self.up_right_team_info.fight_label:DeleteMe()
        self.up_right_team_info.fight_label = nil
    end

    self:playMatchEffect(false)
    self:playVsEffect(false)
    self:playFireEffect(false)
    self.container:stopAllActions()
    self.cool_time:stopAllActions()
    self.right_btn_label:stopAllActions()
    controller:openElitematchMatchingWindow(false)
end