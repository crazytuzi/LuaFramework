-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
-- @author: xhj@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      多人竞技场主界面 后端 锋林 策划 康杰
-- <br/>Create: 2020-03-18
ArenaManyPeopleMainWindow = ArenaManyPeopleMainWindow or BaseClass(BaseView)

local controller = ArenaManyPeopleController:getInstance()
local model = controller:getModel()
local string_format = string.format
local table_sort = table.sort

function ArenaManyPeopleMainWindow:__init()
    self.win_type = WinType.Full
    self.is_full_screen = true
    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("bigbg/battle_bg/11006", "b_bg", true), type = ResourcesType.single},
        {path = PathTool.getPlistImgForDownLoad("arenampmatch", "amp_rank_bg_1"), type = ResourcesType.single},
        {path = PathTool.getPlistImgForDownLoad("arenampmatch", "amp_rank_bg_2"), type = ResourcesType.single},
        {path = PathTool.getPlistImgForDownLoad("arenampmatch", "amp_rank_bg_3"), type = ResourcesType.single},
        {path = PathTool.getPlistImgForDownLoad("arenampmatch", "arenamp"), type = ResourcesType.plist},
    }
    self.layout_name = "arenamanypeople/amp_main_window"
    self.role_vo = RoleController:getInstance():getRoleVo()
    self.hero_panel_list = {}
    self.team_info_list = {}
end

function ArenaManyPeopleMainWindow:open_callback(  )
    self.background = self.root_wnd:getChildByName("background")
    local scale = display.getMaxScale() or 1
    self.background:setScale(scale)
    self.background:loadTexture(PathTool.getPlistImgForDownLoad("bigbg/battle_bg/11006", "b_bg", true), LOADTEXT_TYPE)


    self.container = self.root_wnd:getChildByName("container")
    self.container_size = self.container:getContentSize()
    
    self.top_panel = self.container:getChildByName("top_panel")
    
    self.bottom_panel = self.container:getChildByName("bottom_panel")
    
    self.close_btn = self.container:getChildByName("close_btn")
    self.look_btn = self.bottom_panel:getChildByName("look_btn")

    --top_panel
    for i=1,3 do
        local object = {}
        local panel = self.top_panel:getChildByName("hero_panel_"..i)
        local icon_img = panel:getChildByName("icon_img")
        local role_name = panel:getChildByName("role_name")
        local score_num = panel:getChildByName("score_num")
        local power_num = panel:getChildByName("power_num")
        local lev_num = panel:getChildByName("lev_num")
        
        local head_icon = PlayerHead.new(PlayerHead.type.circle)
        head_icon:setHeadLayerScale(0.80)
        head_icon:setPosition(119 , 300)
        panel:addChild(head_icon)
        head_icon:addCallBack(function() self:onClickHead(i,true) end )
        panel:setVisible(false)
        object.panel = panel
        object.icon_img = icon_img
        object.role_name = role_name
        object.score_num = score_num
        object.power_num = power_num
        object.lev_num = lev_num
        object.head_icon = head_icon
        object.rank_tips = self.top_panel:getChildByName("rank_tips_"..i)
        object.rank_tips:setString(TI18N("虚位以待"))
        object.rank_tips:setVisible(false)
        self.hero_panel_list[i] = object
    end


    -- bottom_panel
    self.time_label = createRichLabel(22, cc.c4b(0xff,0xf8,0xbf,0xff), cc.p(0.5, 0.5), cc.p(360, 640),nil,nil,500)
    self.bottom_panel:addChild(self.time_label)

    
    --排行榜
    self.rank_btn = self.bottom_panel:getChildByName("rank_btn")
    self.rank_btn:getChildByName("label"):setString(TI18N("排行榜"))

    self.shop_btn = self.bottom_panel:getChildByName("shop_btn")
    self.shop_btn:getChildByName("label"):setString(TI18N("兑换商店"))
    
    self.report_btn = self.bottom_panel:getChildByName("report_btn")
    self.report_btn:getChildByName("label"):setString(TI18N("战报"))

    self.form_btn = self.bottom_panel:getChildByName("form_btn")
    self.form_btn:getChildByName("label"):setString(TI18N("布阵调整"))

    self.fight_btn = self.bottom_panel:getChildByName("fight_btn")
    self.fight_btn:setVisible(false)
    
    self.fight_btn_label = self.fight_btn:getChildByName("label")
    self.fight_btn_label:setString(TI18N("挑 战"))

    self.reward_btn = self.bottom_panel:getChildByName("reward_btn")
    self.reward_btn:getChildByName("label"):setString(TI18N("段位奖励"))
    self.spine = self.reward_btn:getChildByName("spine")

    self.team_btn = self.bottom_panel:getChildByName("team_btn")
    self.team_btn_label = self.team_btn:getChildByName("label")
    self.team_btn_label:setString(TI18N("组队大厅"))

    self.out_btn = self.bottom_panel:getChildByName("out_btn")
    self.out_btn:getChildByName("label"):setString(TI18N("转让队长"))

    self.exit_btn = self.bottom_panel:getChildByName("exit_btn")
    self.exit_btn:getChildByName("label"):setString(TI18N("退出队伍"))

    self.add_btn = self.bottom_panel:getChildByName("add_btn")
    
    
    local res_id = PathTool.getEffectRes(110)
    self.reward_box = createEffectSpine(res_id, cc.p(0, -20), cc.p(0.5, 0.5), true, PlayerAction.action_1)
    self.spine:addChild(self.reward_box)
    self.bottom_panel:getChildByName("title_lab"):setString(TI18N("我的队伍"))
    

    --挑战次数
    self.change_count = self.bottom_panel:getChildByName("change_count")
    self.change_count:setString(TI18N("挑战次数: 0"))
    self.buy_count = self.bottom_panel:getChildByName("buy_count")
    self.buy_count:setString(TI18N("可购买次数: 0"))
    self.tips_lab = self.bottom_panel:getChildByName("tips_lab")
    self.tips_lab:setString(TI18N("暂无队友"))

    for i=1,2 do
        local object = {}
        local team_info = self.bottom_panel:getChildByName("team_info_"..i)
        team_info:setVisible(false)
        local lev_icon = team_info:getChildByName("lev_icon")
        
        local rank_num = team_info:getChildByName("rank_num")
        local score_num = team_info:getChildByName("score_num")
        local fight_num = team_info:getChildByName("fight_num")
        local power = team_info:getChildByName("power")
        local name_lab = team_info:getChildByName("name_lab")
        local lev_num = team_info:getChildByName("lev_num")
        local head_icon = PlayerHead.new(PlayerHead.type.circle)
        head_icon:setHeadLayerScale(0.90)
        head_icon:setPosition(150 , 61)
        team_info:addChild(head_icon)
        head_icon:addCallBack(function() self:onClickHead(i,false) end )

        object.team_info = team_info
        object.lev_icon = lev_icon
        object.rank_num = rank_num
        object.score_num = score_num
        object.fight_num = fight_num
        object.power = power
        object.name_lab = name_lab
        object.lev_num = lev_num
        object.head_icon = head_icon
        self.team_info_list[i] = object
    end


    self:adaptationScreen()

    -- 通用进场动效
    ActionHelp.itemUpAction(self.top_panel, 0, -360, 0.5)

    -- 通用进场动效
    ActionHelp.itemUpAction(self.bottom_panel, 720, 0, 0.25)
    
end

--设置适配屏幕
function ArenaManyPeopleMainWindow:adaptationScreen()
    --对应主窗口.四面对应xy位置 ..相对位置是self.main_container左下角(0,0)
    local top_y = display.getTop(self.container)
    local bottom_y = display.getBottom(self.container)
    
    local tab_y = self.top_panel:getPositionY()
    self.top_panel:setPositionY(top_y)

    local bottom_panel_y = self.bottom_panel:getPositionY()
    self.bottom_panel:setPositionY(bottom_y)
    local close_btn_y = self.close_btn:getPositionY()
    self.close_btn:setPositionY(bottom_y + close_btn_y)

end


function ArenaManyPeopleMainWindow:register_event(  )
    registerButtonEventListener(self.close_btn, handler(self, self.onClickCloseBtn), true, REGISTER_BUTTON_SOUND_CLOSED_TYPY)
    registerButtonEventListener(self.look_btn, handler(self, self.onClickRuleBtn), true, REGISTER_BUTTON_SOUND_BUTTON_TYPY, nil, 0.8)
    
    registerButtonEventListener(self.rank_btn, handler(self, self.onClickRankBtn), true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)
    registerButtonEventListener(self.shop_btn, handler(self, self.onClickShopBtn), true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)
    
    registerButtonEventListener(self.form_btn, handler(self, self.onClickFormBtn), true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)
    registerButtonEventListener(self.fight_btn, handler(self, self.onClickFightBtn), true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)

    registerButtonEventListener(self.report_btn, handler(self, self.onClickReportBtn), true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)
    registerButtonEventListener(self.reward_btn, handler(self, self.onClickRewardBtn), true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)
    registerButtonEventListener(self.out_btn, handler(self, self.onClickOutBtn), true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)
    registerButtonEventListener(self.team_btn, handler(self, self.onClickTeamBtn), true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)
    registerButtonEventListener(self.exit_btn, handler(self, self.onClickExitBtn), true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)
    registerButtonEventListener(self.add_btn, handler(self, self.onClickAddBtn), true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)
    

    self:addGlobalEvent(ArenaManyPeopleEvent.ARENAMANYPOEPLE_MAIN_EVENT, function(scdata)
        if not scdata then return end
        self:setScdata(scdata)
    end)
 

    --宝箱更新
    self:addGlobalEvent(ArenaManyPeopleEvent.ARENAMANYPOEPLE_RECEIVE_BOX_EVENT, function()
        self:updateBoxRedPoint()
    end)


    -- 组队竞技场红点变化事件
    self:addGlobalEvent(ArenaManyPeopleEvent.ARENAMANYPOEPLE_ALL_RED_POINT_EVENT, function (  )
        self:updateRedPoint()
    end)

    -- 排行榜
    self:addGlobalEvent(ArenaManyPeopleEvent.ARENAMANYPOEPLE_MAIN_RANK_EVENT, function (rank_data)
        if not rank_data then return end
        self:setRankData(rank_data)
        if self.scdata and self.scdata.state == 1 then
            self:updateTeamInfo()
        end
    end)
    
    -- 刷新购买次数
    self:addGlobalEvent(ArenaManyPeopleEvent.ARENAMANYPOEPLE_UPDATE_BUYNUM_EVENT, function ()
        self:updateChangeCount(true)
        if self.team_info_list and self.team_info_list[1] and self.scdata then
            self.team_info_list[1].fight_num:setString(string_format(TI18N("剩余挑战次数：%d"),self.scdata.count))
        end
    end)

    -- 关闭结算界面 刷新排行榜
    self:addGlobalEvent(BattleEvent.CLOSE_RESULT_VIEW, function ()
        controller:sender29025(1,3)
    end)
    
end

function ArenaManyPeopleMainWindow:updateRedPoint()
    if not self.scdata then return end

    if self.scdata.state == 1 then
        --申请邀请的红点
        -- if self.scdata.count > 0 then
        --     addRedPointToNodeByStatus(self.fight_btn, true, 0, 5,nil,2)
        -- else
        --     addRedPointToNodeByStatus(self.fight_btn, false, 5, 5,nil,2)
        -- end
    else
        addRedPointToNodeByStatus(self.fight_btn, false, 5, 5,nil,2)
    end
    --邀请红点
    local i_info = model:getInvitationInfo()
    if i_info and i_info.team_members and #i_info.team_members >0  then
        addRedPointToNodeByStatus(self.team_btn, true, 5, 5)
    else
        addRedPointToNodeByStatus(self.team_btn, false, 5, 5)
    end
    
    local is_show = model:getIsReportRedpoint()
    if is_show == true then
        addRedPointToNodeByStatus(self.report_btn, true, 5, 5)
    else
        addRedPointToNodeByStatus(self.report_btn, false, 5, 5)
    end
    
end

function ArenaManyPeopleMainWindow:onClickHead(i,is_top)
    local head_list = self.team_info_list
    if is_top == true then
        head_list = self.hero_panel_list
    end
    
    if head_list and head_list[i] and head_list[i].head_icon and head_list[i].head_icon:getData() then
        local data = head_list[i].head_icon:getData()
        if self.role_vo and data.rid == self.role_vo.rid and data.sid == self.role_vo.srv_id then 
            message(TI18N("这是你自己~"))
            return
        end
        FriendController:getInstance():openFriendCheckPanel(true, {srv_id = data.sid, rid = data.rid})
    end
end

-- 关闭
function ArenaManyPeopleMainWindow:onClickCloseBtn(  )
    controller:openArenaManyPeopleMainWindow(false)
end
-- 打开规则说明
function ArenaManyPeopleMainWindow:onClickRuleBtn(  )
    MainuiController:getInstance():openCommonExplainView(true, Config.HolidayArenaTeamData.data_explain)
end


-- 排行榜
function ArenaManyPeopleMainWindow:onClickRankBtn(  )
    if self.scdata and self.scdata.state == 0 then
        message(TI18N("活动未开启"))
        return
    end
    controller:openArenaManyPeopleRankWindow(true)
end

-- 兑换商店
function ArenaManyPeopleMainWindow:onClickShopBtn(  )
    local action_controller = ActionController:getInstance()
    local tab_vo = action_controller:getActionSubTabVo(ActionRankCommonType.mysterious_store)
    if tab_vo then
        action_controller:openActionMainPanel(true, nil, tab_vo.bid) 
    else
        message(TI18N("该活动已结束或未到开启时间段"))
    end
end

-- 布阵
function ArenaManyPeopleMainWindow:onClickFormBtn(  )
    HeroController:getInstance():openFormGoFightPanel(true, PartnerConst.Fun_Form.ArenaManyPeople, {}, HeroConst.FormShowType.eFormSave)
end
-- 战报
function ArenaManyPeopleMainWindow:onClickReportBtn(  )
    if self.scdata and self.scdata.state == 0 then
        message(TI18N("活动未开启"))
        return
    end
    model:setIsReportRedpoint(false)
    controller:openArenaManyPeopleFightRecordPanel(true)
end
-- 奖励
function ArenaManyPeopleMainWindow:onClickRewardBtn(  )
    if self.scdata and self.scdata.state == 0 then
        message(TI18N("活动未开启"))
        return
    end
    controller:openArenaManyPeopleBoxRewardPanel(true)
end

-- 移交队长
function ArenaManyPeopleMainWindow:onClickOutBtn(  )
    if not self.scdata then return end
    local data = nil
    if self.scdata.team_members then
        for i,v in ipairs(self.scdata.team_members) do
            if v.is_leader ~= 1 then
                data = v
                break
            end
        end
    end
    if data then
        controller:sender29007(data.rid,data.sid)
    end
end

--  组队大厅
function ArenaManyPeopleMainWindow:onClickTeamBtn(  )
    controller:openArenaManyPeopleHallPanel(true)
end

--  退出队伍
function ArenaManyPeopleMainWindow:onClickExitBtn(  )
    if not self.scdata then return end
    if self.scdata.team_members and #self.scdata.team_members>=2 then
        controller:sender29006()
    end
end

-- 购买挑战次数
function ArenaManyPeopleMainWindow:onClickAddBtn(  )
    if not self.scdata then return end

    if self.scdata.state == 0 then
        message(TI18N("活动未开启"))
        return
    end

    local my_info = model:getMyInfo()
    if my_info then
        local buy_config = Config.HolidayArenaTeamData.data_battle_pay[(self.scdata.buy_count+1)]
        if buy_config then
            local item_id =  buy_config.expend[1][1] 
            local count =  buy_config.expend[1][2] 
            local iconsrc = PathTool.getItemRes(Config.ItemData.data_get_data(item_id).icon)
            local str = string_format(TI18N("是否花费 <img src='%s' scale=0.3 /> %d购买挑战次数？"), iconsrc, count)
            local call_back = function()
                controller:sender29030()
            end
            CommonAlert.show(str, TI18N("确定"), call_back, TI18N("取消"), nil, CommonAlert.type.rich)
            return
        else
            message(TI18N("已到达今日可购买次数上限"))
        end
    end
end


-- 战斗
function ArenaManyPeopleMainWindow:onClickFightBtn(  )
    if not self.scdata then return end

    if self.scdata.state == 0 then
        message(TI18N("多人竞技场未开启"))
        return
    end

    if self.scdata.count<=0 then
        local my_info = model:getMyInfo()
        if my_info then
            local buy_config = Config.HolidayArenaTeamData.data_battle_pay[(self.scdata.buy_count+1)]
            if buy_config then
                local item_id =  buy_config.expend[1][1] 
                local count =  buy_config.expend[1][2] 
                local iconsrc = PathTool.getItemRes(Config.ItemData.data_get_data(item_id).icon)
                local str = string_format(TI18N("是否花费 <img src='%s' scale=0.3 /> %d购买挑战次数？"), iconsrc, count)
                local call_back = function()
                    model:setIsTouchFight(true)
                    controller:sender29030()
                end
                CommonAlert.show(str, TI18N("确定"), call_back, TI18N("取消"), nil, CommonAlert.type.rich)
                return
            end
        end
    end

    controller:sender29016()
end

function ArenaManyPeopleMainWindow:openRootWnd()    
    controller:sender29000()
    controller:sender29025(1,3)
    controller:sender29035()
end

function ArenaManyPeopleMainWindow:setScdata(scdata)
    self.scdata = scdata
    -- (0:未开启  1:进行中)
    if self.scdata.state == 0 then     
        self.out_btn:setVisible(false)
        self.team_btn:setVisible(false)
        self.exit_btn:setVisible(false)
        self.fight_btn:setVisible(false)
        doStopAllActions(self.time_label)
        self.time_label:setVisible(false)
        self:updateChangeCount(false)
    elseif self.scdata.state == 1 then
        self.team_btn:setVisible(false)
        self.exit_btn:setVisible(false)
        self.fight_btn:setVisible(true)
        self.time_label:setVisible(true)
        self:updateTeamInfo()
        local time = self.scdata.end_time - GameNet:getInstance():getTime()
        if time < 0 then
            time = 0
        end
        commonCountDownTime(self.time_label, time, {callback = function(time) self:setTimeValFormatString(time) end})
        self:updateChangeCount(true)
    end
    self:updateRedPoint()
end



--开启的tips倒计时
function ArenaManyPeopleMainWindow:setTimeValFormatString(time)
    if time > 0 then
        local str = string_format("<div outline=2,#000000>距离赛季结束：</div><div fontcolor=#7af655 outline=2,#000000> %s</div>", TimeTool.GetTimeFormatDayIIIIIIII(time))
        self.time_label:setString(str)
    else
        self.time_label:setString("")
    end
end


function ArenaManyPeopleMainWindow:updateTeamInfo()
    if not self.scdata then return end

    self.tips_lab:setVisible(true)
    for i,panel in ipairs(self.team_info_list) do
        if i == 2 and panel then
            panel.team_info:setVisible(false)
        end
    end

    local is_show_btn = false

    local team_members = self.scdata.team_members or {}
    local member_num = #team_members or 1
    for i,member_data in ipairs(team_members) do
        local item = nil
        if self.role_vo and member_data.rid == self.role_vo.rid and member_data.sid == self.role_vo.srv_id then --自己放第一个
            if self.team_info_list[1] then
                item = self.team_info_list[1]
            end
            if member_data.is_leader == 1 and member_num>1 then
                is_show_btn = true
            end
        else
            if self.team_info_list[2] then
                item = self.team_info_list[2]
            end
            self.tips_lab:setVisible(false)
        end

        if item then
            item.team_info:setVisible(true)
            if item.head_icon then
                local head = item.head_icon
                head:setHeadData(member_data)
                head:setHeadRes(member_data.face_id, false, LOADTEXT_TYPE, member_data.face_file, member_data.face_update_time)
                head:setLev(member_data.lev)
                if member_data.is_leader == 1 and member_num>1 then
                    head:showLeader(true)    
                else
                    head:showLeader(false)
                end
                if member_num>1 then
                    head:showOnline(true, member_data.is_online == 1)
                else
                    head:showOnline(false)
                end

                local avatar_bid = member_data.avatar_bid 
                
                if head.record_res_bid == nil or head.record_res_bid ~= avatar_bid then
                    head.record_res_bid = avatar_bid
                    local vo = Config.AvatarData.data_avatar[avatar_bid]
                    --背景框
                    if vo then
                        local res_id = vo.res_id or 1
                        local res = PathTool.getTargetRes("headcircle", "txt_cn_headcircle_" .. res_id, false, false)
                        head:showBg(res, nil, false, vo.offy)
                    else
                        local bgRes = PathTool.getResFrame("common","common_1031")
                        head:showBg(bgRes, nil, true)
                    end
                end
            end
            if member_data.rank > 0 then
                item.rank_num:setString(string_format(TI18N("%d名"),member_data.rank))
                item.rank_num:setFontSize(26)
            else
                item.rank_num:setString(TI18N("未上榜"))
                item.rank_num:setFontSize(20)
            end
            
            item.score_num:setString(string_format(TI18N("%d分"),member_data.score))
            item.power:setString(tostring(member_data.power))
            item.name_lab:setString(member_data.name)
            local count_num = self.scdata.team_count
            if self.role_vo and member_data.rid == self.role_vo.rid and member_data.sid == self.role_vo.srv_id then --自己
                count_num = self.scdata.count
            end
            item.fight_num:setString(string_format(TI18N("剩余挑战次数：%d"),count_num))
            
            local elite_config = Config.HolidayArenaTeamData.data_elite_level[member_data.score_lev]
            if elite_config then
                local color = cc.c4b(0x56,0x2e,0x0d,0xff)
                if elite_config.icon == "amp_icon_1" or elite_config.icon == "amp_icon_2" or elite_config.icon == "amp_icon_3" then
                    color = cc.c4b(0x30,0x38,0x53,0xff)
                end
                item.lev_num:enableOutline(color,2)
                item.lev_num:setString(elite_config.name)
                local res = PathTool.getPlistImgForDownLoad("arenampmatch/arenampmatch_icon", elite_config.icon)
                item.item_load = loadSpriteTextureFromCDN(item.lev_icon, res, ResourcesType.single, item.item_load)
            end
        end
    end
    
    self.out_btn:setVisible(is_show_btn)
    if team_members and #team_members>=2 then
        self.exit_btn:setVisible(true)
        self.team_btn:setVisible(false)
    else
        self.exit_btn:setVisible(false)
        self.team_btn:setVisible(true)
    end
end

function ArenaManyPeopleMainWindow:updateChangeCount(status)
    if not self.scdata then return end
    
    self:updateBoxRedPoint()
    if status then
        self.change_count:setVisible(true)   
        self.buy_count:setVisible(true)
    
        local team_battle_pay = Config.HolidayArenaTeamData.data_const.team_battle_pay
        if team_battle_pay then
            self.buy_count:setString(string_format(TI18N("可购买次数: %d"),  team_battle_pay.val-self.scdata.buy_count))
        end
        
        local team_battle_free = Config.HolidayArenaTeamData.data_const.team_battle_free
        if team_battle_free then
            local str = string_format("%s/%s",  self.scdata.count, team_battle_free.val)
            self.change_count:setString(TI18N("挑战次数: "..str))
        end
    else   
        self.change_count:setVisible(false)
        self.buy_count:setVisible(false)
    end
end

function ArenaManyPeopleMainWindow:updateBoxRedPoint()
    if not self.scdata then return end
    local config_list = Config.ArenaTeamData.data_challenge_count_reward_info
    if config_list and next(config_list) ~= nil then
        local redpoint = false
        for i,v in ipairs(self.scdata.award_list) do
            if v.status == 1 then
                redpoint = true
                break
            end
        end
        if redpoint then
            self.reward_box:setAnimation(0, PlayerAction.action_2, true)
        else
            self.reward_box:setAnimation(0, PlayerAction.action_1, true)
        end
    end
end

function ArenaManyPeopleMainWindow:setRankData(rank_data)
    if not rank_data then return end
    for k,v in pairs(self.hero_panel_list) do
        v.rank_tips:setVisible(true)
    end

    local temp_list = rank_data.team_members or {}
    table_sort(temp_list, SortTools.KeyLowerSorter("rank"))
    for i,v in ipairs(temp_list) do 
        if self.hero_panel_list[i] and self.hero_panel_list[i].head_icon then
            local panel = self.hero_panel_list[i].panel
            local head = self.hero_panel_list[i].head_icon
            panel:setVisible(true)
            self.hero_panel_list[i].rank_tips:setVisible(false)
            head:setHeadData(v)
            head:setHeadRes(v.face_id, false, LOADTEXT_TYPE, v.face_file, v.face_update_time)
            head:setLev(v.lev)

            local avatar_bid = v.avatar_bid 
            if head.record_res_bid == nil or head.record_res_bid ~= avatar_bid then
                head.record_res_bid = avatar_bid
                local vo = Config.AvatarData.data_avatar[avatar_bid]
                --背景框
                if vo then
                    local res_id = vo.res_id or 1
                    local res = PathTool.getTargetRes("headcircle", "txt_cn_headcircle_" .. res_id, false, false)
                    head:showBg(res, nil, false, vo.offy)
                else
                    local bgRes = PathTool.getResFrame("common","common_1031")
                    head:showBg(bgRes, nil, true)
                end
            end
            
            
            self.hero_panel_list[i].role_name:setString(v.name)
            self.hero_panel_list[i].score_num:setString(string_format(TI18N("积分：%d"),v.score))
            self.hero_panel_list[i].power_num:setString(tostring(v.power))
            
            local elite_config = Config.HolidayArenaTeamData.data_elite_level[v.score_lev]
            if elite_config then
                local color = cc.c4b(0x56,0x2e,0x0d,0xff)
                if elite_config.icon == "amp_icon_1" or elite_config.icon == "amp_icon_2" or elite_config.icon == "amp_icon_3" then
                    color = cc.c4b(0x30,0x38,0x53,0xff)
                end
                self.hero_panel_list[i].lev_num:enableOutline(color,2)
                self.hero_panel_list[i].lev_num:setString(elite_config.name)

                local res = PathTool.getPlistImgForDownLoad("arenampmatch/arenampmatch_icon", elite_config.icon)
                self.hero_panel_list[i].item_load = loadSpriteTextureFromCDN(self.hero_panel_list[i].icon_img, res, ResourcesType.single, self.hero_panel_list[i].item_load)
            end
        end

        if i>=4 then
            return
        end
    end
end



function ArenaManyPeopleMainWindow:close_callback(  )
    doStopAllActions(self.time_label)
    doStopAllActions(self.top_panel)
    doStopAllActions(self.bottom_panel)

    if self.reward_box then
        self.reward_box:clearTracks()
        self.reward_box:removeFromParent()
        self.reward_box = nil
    end

    if self.hero_panel_list then
        for k,v in pairs(self.hero_panel_list) do
            if v and v.head_icon and v.head_icon.DeleteMe then
                v.head_icon:DeleteMe()
                v.head_icon = nil    
            end
    
            if v and v.item_load and v.item_load.DeleteMe then
                v.item_load:DeleteMe()
                v.item_load = nil    
            end
        end
        self.hero_panel_list = nil
    end
    
    if self.team_info_list then
        for k,v in pairs(self.team_info_list) do
            if v and v.head_icon and v.head_icon.DeleteMe then
                v.head_icon:DeleteMe()
                v.head_icon = nil    
            end
    
            if v and v.item_load and v.item_load.DeleteMe then
                v.item_load:DeleteMe()
                v.item_load = nil    
            end
        end
        self.team_info_list = nil
    end

    controller:openArenaManyPeopleMainWindow(false)
end
