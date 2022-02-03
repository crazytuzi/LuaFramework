-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      公会秘境主界面 后端 国辉 策划 松岳
-- <br/>Create: 2019年9月11日 
GuildsecretareaMainWindow = GuildsecretareaMainWindow or BaseClass(BaseView)

local controller = GuildsecretareaController:getInstance()
local model = controller:getModel()
local string_format = string.format
local table_sort = table.sort
local table_insert = table.insert

function GuildsecretareaMainWindow:__init()
    self.win_type = WinType.Full
    self.is_full_screen = true
    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("guildsecretarea", "guildsecretarea"), type = ResourcesType.plist}
    }
    self.layout_name = "guildsecretarea/guildsecretarea_main_window"

    --宝箱奖励列表
    self.box_list = {}
    --技能item列表
    self.skill_item_list = {}

    --全三排行信息
    self.rank_list = {}

    self.my_guild_info = GuildController:getInstance():getModel():getMyGuildInfo()

    self.role_vo = RoleController:getInstance():getRoleVo()

    -- boss开启后下一次再开启后所需等待的时间
    self.boss_reset_interval = 172800
    local config = Config.GuildSecretAreaData.data_const.boss_reset_interval
    if config then
        self.boss_reset_interval = config.val
    end
    --玩家刷新挑战次数后下一次再能刷新挑战次数所需等待的时间
    self.player_reset_interval = 172800
    local config = Config.GuildSecretAreaData.data_const.player_reset_interval
    if config then
        self.player_reset_interval = config.val
    end
end

function GuildsecretareaMainWindow:open_callback(  )
    self.background = self.root_wnd:getChildByName("background")
    local scale = display.getMaxScale() or 1
    self.background:setScale(scale)

    self.container = self.root_wnd:getChildByName("container")
    self:playEnterAnimatianByObj(self.container, 1)
    self.container_size = self.container:getContentSize()
    self.close_btn = self.container:getChildByName("close_btn")

    self.top_panel = self.container:getChildByName("top_panel")
    self.bottom_panel = self.container:getChildByName("bottom_panel")


    --排行榜
    self.rank_container = self.top_panel:getChildByName("rank_container")
    -- self.rank_info_btn = self.rank_container:getChildByName("rank_btn")

    self.rank_info_btn = createRichLabel(22, cc.c4b(0x83,0xe7,0x73,0xff), cc.p(0.5, 0.5), cc.p(104, 16))
    self.rank_info_btn:setString(string_format("<div outline=2,#220101 href=xxx>%s</div>", TI18N("查看详情")))
    self.rank_info_btn:addTouchLinkListener(function(type, value, sender, pos)
        self:onClickRankBtn()
    end, { "click", "href" })
    self.rank_container:addChild(self.rank_info_btn)

    self.rank_container:getChildByName("rank_desc_label"):setString(TI18N("伤害排行前三"))

    self.look_btn = self.top_panel:getChildByName("look_btn")
    --难度
    self.name = self.top_panel:getChildByName("name")
    self.hand_key = self.top_panel:getChildByName("hand_key")
    self.hand_key:setString(TI18N("当前难度:"))
    self.hand_value = self.top_panel:getChildByName("hand_value")

    -- self.hand_icon = self.top_panel:getChildByName("hand_icon")

    --中间部分
    self.hero_icon = self.bottom_panel:getChildByName("hero_icon")
    self.bottom_bg = self.bottom_panel:getChildByName("bottom_bg")

    self.action_btn = self.bottom_panel:getChildByName("action_btn")

    self.box_btn = createRichLabel(22, cc.c4b(0x64,0x32,0x23,0xff), cc.p(0.5, 0.5), cc.p(630, 360))
    self.box_btn:setString(string_format("<div href=xxx>%s</div>", TI18N("查看全部")))
    self.box_btn:addTouchLinkListener(function(type, value, sender, pos)
        self:onClickBoxBtn()
    end, { "click", "href" })
    self.bottom_panel:addChild(self.box_btn)

    self.left_btn = self.bottom_panel:getChildByName("left_btn")
    self.right_btn = self.bottom_panel:getChildByName("right_btn")

    --进度条
    self.progress_container = self.bottom_panel:getChildByName("progress_container")
    self.progress = self.progress_container:getChildByName("progress")
    -- self.progress:setScale9Enabled(true)
    self.progress_container_size = self.progress_container:getContentSize()

    self.skill_container = self.bottom_panel:getChildByName("skill_container")
    self.skill_container_size = self.skill_container:getContentSize()
    self.skill_container:setScrollBarEnabled(false)

    self.item_container = self.bottom_panel:getChildByName("item_container")
    self.item_container:setScrollBarEnabled(false)

    
    self.less_time = createRichLabel(22, cc.c4b(0x64,0x32,0x23,0xff), cc.p(0.5, 0.5), cc.p(132, 224),nil,nil,720)
    self.bottom_panel:addChild(self.less_time)

    self.cost_label = createRichLabel(22, cc.c4b(0x64,0x32,0x23,0xff), cc.p(0.5, 0.5), cc.p(360, 308),nil,nil,720)
    self.bottom_panel:addChild(self.cost_label)

    local buy_panel = self.bottom_panel:getChildByName("buy_panel")
    buy_panel:getChildByName("key"):setString(TI18N("挑战次数:"))
    self.buy_count = buy_panel:getChildByName("label")
    self.buy_btn = buy_panel:getChildByName("add_btn")
    self.buy_tips = createRichLabel(20, cc.c4b(0xff,0xf8,0xbf,0xff), cc.p(0.5,0.5), cc.p(0,-20), nil, nil, 600)
    buy_panel:addChild(self.buy_tips)

    self.checkbox = self.bottom_panel:getChildByName("checkbox")
    self.checkbox:getChildByName("name"):setString(TI18N("跳过战斗"))
    self.checkbox:setSelected(false)
    self.checkbox:setVisible(false)

    self.reward_tips = self.bottom_panel:getChildByName("reward_tips")
    self.reward_tips:setString(TI18N("玩\n法\n奖\n励"))
    self.fight_btn = self.bottom_panel:getChildByName("fight_btn")
    self.fight_btn_label = self.fight_btn:getChildByName("label")

    self:adaptationScreen()
end

--设置适配屏幕
function GuildsecretareaMainWindow:adaptationScreen()
    --对应主窗口.四面对应xy位置 ..相对位置是self.main_container左下角(0,0)
    local top_y = display.getTop(self.container)
    local bottom_y = display.getBottom(self.container)
    local left_x = display.getLeft(self.container)
    local right_x = display.getRight(self.container)

    local tab_y = self.top_panel:getPositionY()
    self.top_panel:setPositionY(top_y - (self.container_size.height - tab_y))

    local bottom_panel_y = self.bottom_panel:getPositionY()
    self.bottom_panel:setPositionY(bottom_y + bottom_panel_y)
    local close_btn_y = self.close_btn:getPositionY()
    self.close_btn:setPositionY(bottom_y + close_btn_y)

    -- --主菜单 顶部的高度
    -- local top_height = MainuiController:getInstance():getMainUi():getTopViewHeight()
    -- --主菜单 底部的高度
    -- local bottom_height = MainuiController:getInstance():getMainUi():getTopViewHeight()
end

function GuildsecretareaMainWindow:setBackgroundImg(index)
    if not index then return end
    local bg_name = "secret_area_boss_"..index
    local bg_res = PathTool.getPlistImgForDownLoad("bigbg/guildsecretarea", bg_name, true)
    if self.record_hero_res == nil or self.record_hero_res ~= bg_res then
        self.record_hero_res = bg_res
        self.item_load_icon = loadSpriteTextureFromCDN(self.hero_icon, bg_res, ResourcesType.single, self.item_load_icon) 
    end

    local bg_name = "secret_area_boss_bottom_"..index
    local bg_res = PathTool.getPlistImgForDownLoad("bigbg/guildsecretarea", bg_name, true)
    if self.record_bottom_bg_res == nil or self.record_bottom_bg_res ~= bg_res then
        self.record_bottom_bg_res = bg_res
        self.item_load_bg = loadSpriteTextureFromCDN(self.bottom_bg, bg_res, ResourcesType.single, self.item_load_bg) 
    end    
end


function GuildsecretareaMainWindow:register_event(  )
    registerButtonEventListener(self.close_btn, handler(self, self.onClickCloseBtn), true, 2)
   
    registerButtonEventListener(self.look_btn, handler(self, self.onClickRuleBtn), true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)
    registerButtonEventListener(self.action_btn, handler(self, self.onClickActionBtn), true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)
    --查看全部
    -- registerButtonEventListener(self.box_btn, handler(self, self.onClickBoxBtn), true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)

    registerButtonEventListener(self.left_btn, handler(self, self.onClickLeftBtn), true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)
    registerButtonEventListener(self.right_btn, handler(self, self.onClickRigthBtn), true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)
    --排行榜
    -- registerButtonEventListener(self.rank_info_btn, handler(self, self.onClickRankBtn), true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)

    registerButtonEventListener(self.buy_btn, handler(self, self.onClickBuyCountBtn), true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)
    --开启
    registerButtonEventListener(self.fight_btn, function()
        self.is_show_continue_tips = false
        self:onClickFightBtn() 
    end, true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)

    --跳过战斗
    self.checkbox:addEventListener(function ( sender,event_type )
        playButtonSound2()
        if  not self.scdata then return end
        local is_select = self.checkbox:isSelected()

        if self.scdata.hp > 0 then
            if is_select then
                self.fight_btn_label:setString(TI18N("扫 荡"))
            else
                self.fight_btn_label:setString(TI18N("挑 战"))
            end
        else
            self.fight_btn_label:setString(TI18N("追 击"))
        end
    end)

    self:addGlobalEvent(GuildsecretareaEvent.GUILD_SECRET_AREA_MAIN_EVENT, function(scdata)
        if not scdata then return end
        self:setScData(scdata)
    end)

    --排行榜信息
    self:addGlobalEvent(GuildsecretareaEvent.GUILD_SECRET_AREA_RANK_COUNT_EVENT, function(data)
        if not data then return end
        if not self.boss_config then return end
        if self.boss_config.id == data.boss_id then
            self:updateRankInfo()
        end
    end)
    --领取奖励
    self:addGlobalEvent(GuildsecretareaEvent.TERM_BEGINS_RECEIVE_REWARD_EVENT, function(data)
        if not data then return end
        if not self.scdata then return end
        if not self.select_pass_id then return end
        self.dic_progress_reward[data.number] = true
        if self.scdata.bid ~= 0 and self.select_pass_id == self.pass_id then
            local per_hp = self.scdata.hp * 100/ self.scdata.max_hp 
            self:updateProgressInfo(per_hp, self.dic_progress_reward)
        end
    end)
    --刷新排行
    self:addGlobalEvent(GuildsecretareaEvent.GUILD_SECRET_AREA_REFRESH_RANK_EVENT, function()
        if not self.scdata then return end
        controller:sender26806(self.scdata.bid, 0)
    end)

    --购买次数
    self:addGlobalEvent(GuildsecretareaEvent.GUILD_SECRET_AREA_BUY_COUNT_EVENT, function(data)
        if not data then return end
        if not self.scdata then return end

        self.scdata.count = data.count
        self.scdata.last_buy_time = data.last_buy_time
        self:updateBuyCount()
        if self.is_send_matching then
            --打开布阵界面
            self.is_send_matching = false
            self:onClickFightBtn(true)
        end
    end)

    --需更新活跃度
    self:addGlobalEvent(GuildEvent.UpdataGuildGoalSingleTaskData, function(data)
        GuildsecretareaController:getInstance():sender26810()
    end)

    --公会信息
    if self.my_guild_info ~= nil then
        if self.my_guild_info ~= nil and self.update_guild_event == nil then
            self.update_guild_event = self.my_guild_info:Bind(GuildEvent.UpdateMyInfoEvent, function(key, value) 
                if key == "vitality" then
                    --活跃度更新
                    self:updateActiveInfo()
                end
            end)
        end
    end
end

-- 关闭
function GuildsecretareaMainWindow:onClickCloseBtn(  )
    controller:openGuildsecretareaMainWindow(false)
end
-- 打开规则说明
function GuildsecretareaMainWindow:onClickRuleBtn(  )
    MainuiController:getInstance():openCommonExplainView(true, Config.GuildSecretAreaData.data_explain)
end

-- 公会活跃
function GuildsecretareaMainWindow:onClickActionBtn(  )
   GuildController:getInstance():openGuildActionGoalWindow(true)
end

-- 宝库奖励展示
function GuildsecretareaMainWindow:onClickBoxBtn(  )
    if not self.select_boss_id then return end
    controller:openGuildsecretareaRewardWindow(true, self.select_boss_id)  --传入boss_id 
end

-- 左
function GuildsecretareaMainWindow:onClickLeftBtn(  )
    if not self.boss_list then return end
    if not self.select_boss_index then return end
    if #self.boss_list == 0 then return end
    self.select_boss_index = self.select_boss_index - 1 
    if self.select_boss_index <= 0 then
        self.select_boss_index = #self.boss_list
    end
    self:updateBossInfoByBossID(self.select_boss_index)
end

-- 右
function GuildsecretareaMainWindow:onClickRigthBtn(  )
    if not self.boss_list then return end
    if not self.select_boss_index then return end
    if #self.boss_list == 0 then return end
    self.select_boss_index = self.select_boss_index + 1 
    if self.select_boss_index > #self.boss_list then
        self.select_boss_index = 1
    end
    self:updateBossInfoByBossID(self.select_boss_index)
end

-- 打开排行榜
function GuildsecretareaMainWindow:onClickRankBtn(  )
    if not self.boss_config then return end
    local setting = {}
    setting.rank_type = RankConstant.RankType.guild_secretarea
    setting.title_name = TI18N("排行榜")
    setting.background_path = PathTool.getPlistImgForDownLoad("bigbg","bigbg_2",true)
    setting.boss_id = self.boss_config.id
    -- setting.show_tips = TI18N("奖励将在活动结束后通过邮件发放")
    RankController:getInstance():openSingleRankMainWindow(true, setting)
end

-- 购买次数
--@is_matching 是否是购买次数后进入布阵界面
function GuildsecretareaMainWindow:onClickBuyCountBtn(is_matching)
    if not self.scdata  then return end
    if self.scdata.bid == 0 then
        message(TI18N("该boss还未开启哦~"))
        return
    end

    if self.scdata.end_time < GameNet:getInstance():getTime() then
        --过期了
        if self.fight_config then
            local time = (self.player_reset_interval - self.fight_config.time) + self.scdata.end_time - GameNet:getInstance():getTime()
            if time < 0 then
                time = 0
            end
            local time_str = TimeTool.GetTimeFormatDayIIIIII(time)
            message(string_format(TI18N("距离讨伐机会重置还有%s，请耐心等待"), time_str))
        end
        return
    end 

    if self.scdata.last_buy_time <= 0 then
        if is_matching then
            message(TI18N("已达到本次讨伐挑战次数上限"))
        else
            message(TI18N("购买次数已达上限"))
        end
        return
    end

    if self.scdata.loss_list and next(self.scdata.loss_list) ~= nil then
        local item_id =  self.scdata.loss_list[1].loss_id
        local count =  self.scdata.loss_list[1].num
        local iconsrc = PathTool.getItemRes(Config.ItemData.data_get_data(item_id).icon)
        local str
        if is_matching then
            local is_select = self.checkbox:isSelected()
            if self.scdata.dps > 0 and is_select then 
                if self.scdata.hp > 0 then
                    str = string_format(TI18N("挑战次数不足, 是否花费 <img src='%s' scale=0.3 /> %s购买一次挑战次数？并扫荡根据上次的伤害量<div fontcolor=#249003>%s</div>进行结算"), iconsrc, count, self.scdata.dps)    
                else
                    if self:isShowContinueTips() then
                        return
                    end
                    str = string_format(TI18N("挑战次数不足, 是否花费 <img src='%s' scale=0.3 /> %s购买一次挑战次数？并追击根据上次的伤害量<div fontcolor=#249003>%s</div>进行结算"), iconsrc, count, self.scdata.dps)    
                end
            else
                if self.scdata.hp <= 0 then
                    if self:isShowContinueTips() then
                        return
                    end
                end
                str = string_format(TI18N("挑战次数不足, 是否花费 <img src='%s' scale=0.3 /> %s购买一次挑战次数？"), iconsrc, count)
            end
        else

            str = string_format(TI18N("是否花费 <img src='%s' scale=0.3 /> %s购买一次挑战次数？"), iconsrc, count)
        end

        local call_back = function()
            if self.scdata.bid ~= 0 then
                self.is_send_matching = is_matching
                controller:sender26803(self.scdata.bid)
            end
        end
        CommonAlert.show(str, TI18N("确定"), call_back, TI18N("取消"), nil, CommonAlert.type.rich)
    end
end

-- is_buy_back是否购买次数返回的
function GuildsecretareaMainWindow:onClickFightBtn(is_buy_back)
    if not self.scdata then return end
    if not self.select_pass_id then return end
    if not self.my_guild_info then return end
    if not self.role_vo then return end
    if not self.boss_config then return end

    if self.scdata.bid == 0 or self.is_start_fight then
        --权限拦截
        if self.role_vo.position == GuildConst.post_type.member then
            message(TI18N("需要会长或者副会长消耗公会活跃开启"))        
            return
        end

        -- 消耗拦截
        local total_active = self.my_guild_info.vitality
        if total_active < self.boss_config.active then
            message(TI18N("所需公会活跃不足"))        
            return 
        end
        --可以弹出确认了
        local msg = string_format(TI18N("确定消耗<div fontcolor=#249003>%s</div>点公会活跃开始讨伐<div fontcolor=#249003>%s</div>吗？"), self.boss_config.active, self.boss_config.name)
        local call_back = function()
            controller:sender26801(self.select_boss_id)
        end
        local extend_msg = TI18N("(直到讨伐时间结束都无法讨伐其他boss)")
        CommonAlert.show(msg, TI18N("确定"), call_back, TI18N("取消"), nil, CommonAlert.type.rich, nil, {off_y = 43, title = TI18N("开始讨伐"), extend_str = extend_msg, extend_offy = -5, extend_aligment = cc.TEXT_ALIGNMENT_CENTER }, nil, nil) 
    else
        

        if self.scdata.end_time < GameNet:getInstance():getTime() then
            --时间到了
            if self.fight_config then
                local time = (self.player_reset_interval - self.fight_config.time) + self.scdata.end_time - GameNet:getInstance():getTime()
                if time < 0 then
                    time = 0
                end
                local time_str = TimeTool.GetTimeFormatDayIIIIII(time)
                message(string_format(TI18N("距离讨伐机会重置还有%s，请耐心等待"), time_str))
            end
            return
        else
            --其他boss拦截
            if self.scdata.bid ~= 0 and self.select_pass_id ~= self.pass_id and not self.is_start_fight then
                message(TI18N("讨伐其他boss中"))
                return
            end
        end 

        --次数拦截
        if self.scdata.count <= 0 then
            self:onClickBuyCountBtn(true)
            return 
        end
        local is_select = self.checkbox:isSelected()
        if self.scdata.dps > 0 and is_select then 
            --扫荡
            if is_buy_back then
                controller:sender26805(self.select_boss_id)
            else
                local msg 
                if self.scdata.hp > 0 then
                    msg = string_format(TI18N("确定按照上次挑战的伤害量<div fontcolor=#249003>%s</div>扫荡一次吗？"), self.scdata.dps)
                else
                    if self:isShowContinueTips() then
                        return
                    end
                    msg = string_format(TI18N("确定按照上次挑战的伤害量<div fontcolor=#249003>%s</div>追击一次吗？"), self.scdata.dps)
                end
                CommonAlert.show(msg,TI18N("确定"),function() 
                    controller:sender26805(self.select_boss_id)
                end,TI18N("取消"),nil,CommonAlert.type.rich)
            end
        else
            if self.scdata.hp <= 0 then
                if self:isShowContinueTips() then
                    return
                end
            end
            --打开布阵界面
            local setting = {}
            setting.boss_id = self.select_boss_id
            HeroController:getInstance():openFormGoFightPanel(true, PartnerConst.Fun_Form.GuildSecretArea, setting)
        end
    end
end

--是否显示tips提示了
function GuildsecretareaMainWindow:isShowContinueTips()
    return false
    -- if self.is_show_continue_tips then
    --     return false
    -- end
    -- self.is_show_continue_tips = true
    -- local msg = TI18N("确定要继续追击领主吗？")
    -- local extend_msg = TI18N("(造成的伤害不再正常计入排行榜，且仍会消耗挑战次数)")
    -- CommonAlert.show(msg, TI18N("确定"), function()
    --     self:onClickFightBtn()
    -- end, TI18N("取消"), nil, nil, nil, {off_y = 43, title = TI18N("提示"), extend_str = extend_msg, extend_offy = -5, extend_aligment = cc.TEXT_ALIGNMENT_CENTER }, nil, nil)  
    -- return true
end


function GuildsecretareaMainWindow:openRootWnd(setting)
    local setting = setting or {}
    controller:sender26800()
    controller:sender26810()
end

function GuildsecretareaMainWindow:setScData(scdata)
    if not scdata then return end
    self.scdata = scdata
    self.boss_list = self.scdata.boss_list

    if next(self.boss_list) == nil then return end
    table_sort(self.boss_list, SortTools.KeyLowerSorter("boss_id"))

    for i,v in ipairs(self.boss_list) do
        local config = Config.GuildSecretAreaData.data_boss_info(v.boss_id)
        if config then
            v.config = config
            v.pass_id = config.pass_id
        end
    end

    if self.scdata.bid ~= 0 then
        --挑战boss的配置
        self.fight_config = Config.GuildSecretAreaData.data_boss_info(self.scdata.bid)
        if self.fight_config then
            self.pass_id = self.fight_config.pass_id 
        else
            self.pass_id = 1
        end
    end
 
    if self.select_boss_index == nil then
        if self.scdata.bid == 0 then
            self.select_boss_index = 1
        else
            for i,v in ipairs(self.boss_list) do
                if self.pass_id == v.pass_id then
                    self.select_boss_index = i
                    break
                end
            end
        end
        --容错用的
        if self.select_boss_index == nil then
            self.select_boss_index = 1
        end
    end
    --已领奖励信息
    self.dic_progress_reward = {}
    for i,v in ipairs(self.scdata.progress_reward) do
        self.dic_progress_reward[v.order] = true
    end
    --检查boss状态
    self:checkBossStatus()
    self:updateBossInfoByBossID(self.select_boss_index)
    self:updateBuyCount()
end

--@count 剩余挑战次数
function GuildsecretareaMainWindow:updateBuyCount()
    if not self.scdata then return end

    local count = self.scdata.count or 1
    local config = Config.GuildSecretAreaData.data_const.guild_secret_free_time
    if config then
        local str = string_format("%s/%s",count, config.val)
        self.buy_count:setString(str)
    end
    -- local is_redpoint = model:getMatchCountRedpoint()
    -- addRedPointToNodeByStatus(self.match_btn, is_redpoint, 5, 5)
    local last_buy_time = self.scdata.last_buy_time or 0
    local str = string.format(TI18N("<div outline=2,#000000>%s</div><div fontcolor=#3df424 outline=2,#000000>%s</div>"),TI18N("剩余购买次数:"), last_buy_time)
    self.buy_tips:setString(str)
end

function GuildsecretareaMainWindow:updateBossInfoByBossID(index)
    if not self.scdata then return end
    if not index then return end
    if not self.boss_list[index] then return end

    self.select_boss_id = self.boss_list[index].boss_id
    self.select_pass_id = self.boss_list[index].pass_id

    self.boss_config = Config.GuildSecretAreaData.data_boss_info(self.select_boss_id)
    if not self.boss_config then return end
    
    self:updateSkillInfo()
    self:updateRankInfo()
    --奖励
    local data_list = self.boss_config.boss_reward or {}
    local setting = {}
    setting.scale = 0.9
    setting.max_count = 4
    setting.is_center = true
    -- setting.show_effect_id = 263
    self.item_list = commonShowSingleRowItemList(self.item_container, self.item_list, data_list, setting)

    --boss名字
    self.name:setString(self.boss_config.name)
    self.hand_value:setString(self.boss_config.difficulty)

    --立绘
    self:setBackgroundImg(self.boss_config.pass_id)

   
    if self.scdata.bid ~= 0 and self.select_pass_id == self.pass_id then
        self.cost_label:setVisible(false)

        local per_hp = self.scdata.hp * 100/ self.scdata.max_hp 
        self:updateProgressInfo(per_hp, self.dic_progress_reward)
       
        --是讨伐中的boss
        if self.is_start_fight  then
            --可以讨伐
            doStopAllActions(self.less_time)
            self.cost_label:setVisible(true)
            self:updateActiveInfo()
            
            self:setTimeFormatString(self.boss_config.time)
            self.checkbox:setVisible(false)
            self.fight_btn_label:setString(TI18N("开始讨伐"))
            setChildUnEnabled(false, self.fight_btn) 
            self.fight_btn_label:enableOutline(cc.c4b(0x65,0x1d,0x00,0xff) , 2) 
        else

            local time = self.scdata.end_time - GameNet:getInstance():getTime()
            if time <= 0 then
                time = 0
            end
            if time > 0 then
                 --boss倒计时 
                commonCountDownTime(self.less_time, time, {callback = function(time) self:setTimeFormatString(time) end})

                if self.scdata.dps and self.scdata.dps > 0 then
                    self.checkbox:setVisible(true)
                else
                    self.checkbox:setVisible(false)
                end

                local is_select = self.checkbox:isSelected()

                if self.scdata.hp > 0 then
                    if is_select then
                        self.fight_btn_label:setString(TI18N("扫 荡"))
                    else
                        self.fight_btn_label:setString(TI18N("挑 战"))
                    end
                else
                    self.fight_btn_label:setString(TI18N("追 击"))
                end
                setChildUnEnabled(false, self.fight_btn) 
                self.fight_btn_label:enableOutline(cc.c4b(0x65,0x1d,0x00,0xff) , 2) 
            else
                if self.fight_config then
                    local time = (self.boss_reset_interval - self.fight_config.time) + self.scdata.end_time - GameNet:getInstance():getTime()
                    if time < 0 then
                        time = 0
                    end
                    commonCountDownTime(self.less_time, time, {callback = function(time) self:setTimeFormatString(time, 2) end})
                end
                self.cost_label:setVisible(true)
                self:updateActiveInfo()
                self.fight_btn_label:setString(TI18N("开始讨伐"))
                self.fight_btn_label:disableEffect(cc.LabelEffect.OUTLINE)
                setChildUnEnabled(true, self.fight_btn)
            end
        end
        
    else
        --不是讨伐中的boss
        doStopAllActions(self.less_time)

        self.checkbox:setVisible(false)

        self.cost_label:setVisible(true)
        --公会活跃度
        self:updateActiveInfo()

        self:updateProgressInfo(100)
        if self.scdata.bid ~= 0 and not self.is_start_fight then
            self.fight_btn_label:disableEffect(cc.LabelEffect.OUTLINE)
            setChildUnEnabled(true, self.fight_btn)

            if self.scdata.end_time < GameNet:getInstance():getTime() then
                if self.fight_config then
                    local time = (self.boss_reset_interval - self.fight_config.time) + self.scdata.end_time - GameNet:getInstance():getTime()
                    if time < 0 then
                        time = 0
                    end
                    commonCountDownTime(self.less_time, time, {callback = function(time) self:setTimeFormatString(time, 2) end})
                end
            else
                self:setTimeFormatString(self.boss_config.time)
            end
        else
            setChildUnEnabled(false, self.fight_btn) 
            self.fight_btn_label:enableOutline(cc.c4b(0x65,0x1d,0x00,0xff) , 2) 
            
            self:setTimeFormatString(self.boss_config.time)
        end
        self.fight_btn_label:setString(TI18N("开始讨伐"))
    end
end

--检查boss是否能讨伐状态
function GuildsecretareaMainWindow:checkBossStatus()
    if not self.scdata then return end

    self.is_start_fight = true
    if self.fight_config then
        local time = (self.boss_reset_interval - self.fight_config.time) + self.scdata.end_time - GameNet:getInstance():getTime()
        if time > 0 then
            self.is_start_fight = false
        end            
    end

    -- if self.scdata.button == 1 then
    --     self.is_start_fight = true
    -- else
    --     self.is_start_fight = false
    -- end
end

--是否同一天
function GuildsecretareaMainWindow:checkSameDay(count_time, time)
    local day = TimeTool.getMD3(count_time)
    local day2 = TimeTool.getMD3(time)
    if day == day2 then
        return true
    end
    return false
end

function GuildsecretareaMainWindow:setTimeFormatString(time, str_type)
    local str_type = str_type or 1
    local title_str
    if str_type == 2 then
        title_str = TI18N("讨伐重置时间")
    else
        title_str = TI18N("讨伐时间")
    end
    if time > 0 then
        local str = string.format(TI18N("%s:<div fontcolor=#157e22>%s</div>"), title_str, TimeTool.GetTimeFormatDayIIIIII(time))
        self.less_time:setString(str)
    else
        local str = title_str..":<div fontcolor=#157e22>00:00</div>"
        self.less_time:setString(str)
        doStopAllActions(self.less_time)
        self:checkBossStatus()
        self:updateBossInfoByBossID(self.select_boss_index)
    end
end

function GuildsecretareaMainWindow:updateActiveInfo()
    if not self.scdata then return end
    if not self.select_pass_id then return end
    if not self.my_guild_info then return end
    if not self.boss_config then return end

    local iconsrc = PathTool.getResFrame("guildsecretarea","guildsecretarea_10")
    local str
    local total_active = self.my_guild_info.vitality
    if total_active > self.boss_config.active then
        str = string_format(TI18N("需要消耗公会活跃: <img src='%s' scale=1 /> %s/%s"), iconsrc, self.boss_config.active, total_active)
    else
        str = string_format(TI18N("需要消耗公会活跃: <img src='%s' scale=1 /> <div fontcolor=#FF0000>%s</div>/%s"), iconsrc, self.boss_config.active, total_active)
    end
    self.cost_label:setString(str)
end

--进度条的宝箱信息
function GuildsecretareaMainWindow:updateProgressInfo(per_hp, dic_progress_reward)
    if not self.scdata then return end
    if not self.select_boss_id then return end
    if not self.box_list then return end
    self.progress:setPercent(per_hp)

    local box_reward_list = Config.GuildSecretAreaData.data_box_reward[self.select_boss_id]
    if box_reward_list and next(box_reward_list) ~= nil then
        table_sort( box_reward_list, function(a, b) return a.number < b.number end )
        local max_num = box_reward_list[#box_reward_list].number
        self.max_num = max_num
        local len = self.progress_container_size.width/ 100

        for i,config in ipairs(box_reward_list) do
            local box_item = self.box_list[i]
            local per = config.progress/10
            local x = len * per - 5
            local str = per .. "%"
            if config.progress == 0 then
                str = TI18N("击杀")
            end
            if box_item == nil then
                local res_id = PathTool.getEffectRes(config.effect_id or 110)
                local box = createEffectSpine(res_id, cc.p( x, 0), cc.p(0.5, 0.5), true, PlayerAction.action_1)
                self.progress_container:addChild(box)
                box_item = {}
                box_item.box = box

                local res = PathTool.getResFrame("guildsecretarea","guildsecretarea_08")
                local bg = createImage(self.progress_container, res, x + 2, -18, cc.p(0.5,0.5), true, 0, true)
                bg:setContentSize(cc.size(50, 26))
                bg:setCapInsets(cc.rect(8, 8, 1, 1))
                -- 
                box_item.label = createLabel(18, cc.c4b(0xff,0xff,0xff,0xff), cc.c4b(0x22,0x01,0x01,0xff), x, -18, str, self.progress_container, 2, cc.p(0.5,0.5))

                box_item.btn = createButton(self.progress_container,"", x, self.progress_container_size.height * 0.5, cc.size(52, 70), PathTool.getResFrame("common", "common_99998"))
                box_item.btn:addTouchEventListener(function(sender, event_type)
                    if event_type == ccui.TouchEventType.ended then
                        self:onClickBoxItemBtn(i, sender)
                    end
                end)
                self.box_list[i] = box_item
            else
                box_item.box:setPositionX(x)
                box_item.btn:setPositionX(x)
                box_item.label:setPositionX(x)
                box_item.label:setString(str)
            end

            box_item.is_receive = false
            if dic_progress_reward then
                if dic_progress_reward[config.number] then
                    self:updateBoxAnimation(box_item.box, 3)
                else 
                    if per_hp <= per and self.scdata.is_reward == 1 then
                        box_item.is_receive = true
                        self:updateBoxAnimation(box_item.box, 2)
                    else
                        self:updateBoxAnimation(box_item.box, 1)
                    end
                end
            else
                self:updateBoxAnimation(box_item.box, 1)
            end

            box_item.config = config --点击时候用到
            local pos = self.progress_container:convertToWorldSpace(cc.p(x, self.progress_container_size.height * 0.5))
            local newpos = self.container:convertToNodeSpace(pos)
            box_item.pos = newpos
        end
    end
end

--@status 1,未激活 2 ,已激活 3 已领取
function GuildsecretareaMainWindow:updateBoxAnimation(box, status)
    if not box then return end
    if status == 1 then
        box:setAnimation(0, PlayerAction.action_1, true)
    elseif status == 2 then
        box:setAnimation(0, PlayerAction.action_2, true)
    else
        box:setAnimation(0, PlayerAction.action_3, true)
    end
end

function GuildsecretareaMainWindow:onClickBoxItemBtn(index, sender)
    if not self.box_list then return end
    if not self.box_list[index] then return end
    if not self.scdata then return end
    local config = self.box_list[index].config

    if self.box_list[index].is_receive then
        controller:sender26804(self.scdata.bid, config.number)
    else
        self:showRewardItems(config.reward, index)
    end
end

--抄过来的
function GuildsecretareaMainWindow:showRewardItems(data, index)
    local size = self.container:getContentSize()
    if not self.tips_layer then
        self.tips_layer = ccui.Layout:create()
        self.tips_layer:setContentSize(size)
        self.container:addChild(self.tips_layer)
        self.tips_layer:setTouchEnabled(true)
        registerButtonEventListener(self.tips_layer, function()
            self.tips_bg:removeFromParent()
            self.tips_bg = nil
            self.tips_layer:removeFromParent()
            self.tips_layer = nil
        end,false, 1)
    end
    
    local list = {}
    if not self.tips_bg then
        self.tips_bg = createImage(self.tips_layer, PathTool.getResFrame("common","common_1056"), size.width*0.5, 100, cc.p(0,0), true, 10, true)
        self.tips_bg:setTouchEnabled(true)
    end
    if self.tips_bg then
        local pos = self.box_list[index].pos
        self.tips_bg:setContentSize(cc.size(BackPackItem.Width*#data+50,BackPackItem.Height+50))
        local ccp = cc.p(0.5,0)
        local tips_bg_width = self.tips_bg:getContentSize().width
        if tips_bg_width * 0.5 + pos.x >= 720 then
            ccp = cc.p(0.86,0)
        elseif pos.x - tips_bg_width * 0.5 < 0 then
            ccp = cc.p(0.3,0)
        end

        self.tips_bg:setAnchorPoint(ccp)
        self.tips_bg:setPosition(self.box_list[index].pos.x, self.box_list[index].pos.y - 190)
    end
    local size = self.tips_bg:getContentSize()
    local x =  25 + BackPackItem.Width * 0.5
    for i,v in pairs(data) do
        if not list[i] then
            list[i] = BackPackItem.new(nil,true,nil,0.8)
            list[i]:setAnchorPoint(cc.p(0.5,0.5))
            self.tips_bg:addChild(list[i])
            list[i]:setBaseData(v[1])
            list[i]:setPosition(cc.p(x + (i-1) * BackPackItem.Width, 100))
            list[i]:setDefaultTip()
            
            self.text_num = createLabel(22,cc.c4b(0xff,0xee,0xdd,0xff),nil,60,-25,"",list[i],nil, cc.p(0.5,0.5))
            self.text_num:setString("x"..v[2])
        else
            list[i]:setBaseData(v[1])
            list[i]:setPosition(cc.p(x + (i-1) * BackPackItem.Width, 100))
            self.text_num:setString("x"..v[2])
        end
    end
end

--刷新技能
function GuildsecretareaMainWindow:updateSkillInfo()
    if not self.boss_config then return end
    local skill_list = self.boss_config.boss_skill_id or {}
    -- skill_list = {203102,203102,203102,203102}
    --技能item的宽度
    self.skill_width = 100
    local item_width = self.skill_width + 10
    local total_width = item_width * #skill_list
    local max_width = math.max(self.skill_container_size.width, total_width)
    self.skill_container:setInnerContainerSize(cc.size(max_width, self.skill_container_size.height))

    for i,v in ipairs(self.skill_item_list) do
        v:setVisible(false)
    end
    
    local x = 0
    if total_width > self.skill_container_size.width then
        --技能的总宽度大于 显示的宽度 就从左往右显示
        x = 0
    else
        --否则从中从中间显示
        x = (self.skill_container_size.width - total_width) * 0.5
    end

    for i,skill_id in ipairs(skill_list) do
        local config = Config.SkillData.data_get_skill(skill_id)
        if config then
            --是否锁住
            if self.skill_item_list[i] == nil then
                self.skill_item_list[i] = {}
                self.skill_item_list[i] = SkillItem.new(true,true,true,0.8, false)
                self.skill_container:addChild(self.skill_item_list[i])
            end
            self.skill_item_list[i]:setData(config)
            self.skill_item_list[i]:setVisible(true)
            self.skill_item_list[i]:setPosition( x + item_width * (i - 1) + item_width * 0.5, self.skill_width/2 + 6)
        else 
            print(string_format("技能表id: %s 没发现", tostring(skill_id)))
        end
    end
end

function GuildsecretareaMainWindow:updateRankInfo()
    if not self.boss_config then return end
    local data = model:getBossRankInfoByBossID(self.boss_config.id)
    if data == nil then
        controller:sender26806(self.boss_config.id, 0)
        return
    end

    table_sort(data.dps_list, SortTools.KeyLowerSorter("rank"))
    local rank_list = {}
    for i=1,3 do
        local dps_data = data.dps_list[i]
        if dps_data then
            table_insert(rank_list, {name = dps_data.name, all_dps = dps_data.dps})
        else
            table_insert(rank_list, {name = TI18N("虚位以待")})
        end
    end

    if rank_list and next(rank_list or {}) ~= nil then
        for i, v in ipairs(rank_list) do
            local item = self.rank_list[i]
            if not item then
                item = self:createSingleRankItem(i,v)
                self.rank_container:addChild(item)
                self.rank_list[i] = item
            end
            
            if item then
                item:setPosition(0,238 - (i-1) * item:getContentSize().height)
                item.label:setString(v.name)
                if v.all_dps then
                    item.value:setString("["..MoneyTool.GetMoneyString(v.all_dps, false)..TI18N("伤害").."]")
                    item.label:setPositionY(40)
                else
                    item.value:setString("")
                    item.label:setPositionY(24)
                end
            end
        end
    end
end

--排行榜单项
function GuildsecretareaMainWindow:createSingleRankItem(i,data)
    local size = cc.size(208, 63)
    local container = ccui.Layout:create()
    container:setAnchorPoint(cc.p(0,1))
    container:setContentSize(size)
    local sp = createSprite(PathTool.getResFrame("common","common_300"..i), 10,size.height * 0.5,container)
    sp:setAnchorPoint(cc.p(0,0.5))
    sp:setScale(0.6)
    container.sp = sp
    local label = createLabel(22, cc.c4b(0xec,0xdd,0xcc,0xff), cc.c4b(0x22,0x01,0x01,0xff), 67, 40, "", container, 2, cc.p(0,0.5))
    local value = createLabel(18, cc.c4b(0xc8,0xad,0x83,0xff), cc.c4b(0x22,0x01,0x01,0xff), 67, 16, "", container, 2, cc.p(0,0.5))
    
    container.label = label
    container.value = value
    return  container
end

function GuildsecretareaMainWindow:close_callback(  )
    
    -- if self.role_vo ~= nil then
    --     if self.role_assets_event ~= nil then
    --         self.role_vo:UnBind(self.role_assets_event)
    --         self.role_assets_event = nil
    --     end
    -- end

    if self.my_guild_info ~= nil then
        if self.update_guild_event ~= nil then
            self.my_guild_info:UnBind(self.update_guild_event)
            self.update_guild_event = nil
        end
        self.my_guild_info = nil
    end

    if self.item_load then
        self.item_load:DeleteMe()
    end
    self.item_load = nil

    if self.item_load_icon then
        self.item_load_icon:DeleteMe()
    end
    self.item_load_icon = nil

    if self.item_load_bg then
        self.item_load_bg:DeleteMe()
    end
    self.item_load_bg = nil

    if self.item_list then
        for i,v in pairs(self.item_list) do
            v:DeleteMe()
        end
        self.item_list = nil
    end
    doStopAllActions(self.item_container)
    model:clearBossRankInfo()
    controller:openGuildsecretareaMainWindow(false)
end
