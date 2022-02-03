-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      组队竞技场主界面 后端 锋林 策划 康杰
-- <br/>Create: 2019年9月29日
ArenateamMainWindow = ArenateamMainWindow or BaseClass(BaseView)

local controller = ArenateamController:getInstance()
local model = controller:getModel()
local string_format = string.format
local table_sort = table.sort
local table_insert = table.insert
local math_ceil = math.ceil
local math_floor = math.floor

function ArenateamMainWindow:__init()
    self.win_type = WinType.Full
    self.is_full_screen = true
    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("arenateam", "arenateam"), type = ResourcesType.plist},

        {path = PathTool.getPlistImgForDownLoad("bigbg/battle_bg/10032", "b_bg", true), type = ResourcesType.single},
    }
    self.layout_name = "arenateam/arenateam_main_window"
end

function ArenateamMainWindow:open_callback(  )
    self.background = self.root_wnd:getChildByName("background")
    local scale = display.getMaxScale() or 1
    self.background:setScale(scale)
    self.background:loadTexture(PathTool.getPlistImgForDownLoad("bigbg/battle_bg/10032", "b_bg", true), LOADTEXT_TYPE)


    self.container = self.root_wnd:getChildByName("container")
    self:playEnterAnimatianByObj(self.container, 1)
    self.container_size = self.container:getContentSize()
    
    self.top_panel = self.container:getChildByName("top_panel")
    self.bottom_panel = self.container:getChildByName("bottom_panel")

    self.close_btn = self.container:getChildByName("close_btn")
    self.look_btn = self.top_panel:getChildByName("look_btn")

    --top_panel
    self.panel_bg = self.top_panel:getChildByName("panel_bg")
    self.panel_bg_0 = self.top_panel:getChildByName("panel_bg_0")
    self.name = self.top_panel:getChildByName("name")
    self.name:setString(TI18N("排行榜"))


    self.lay_srollview = self.top_panel:getChildByName("lay_srollview")

    self.time_label = createRichLabel(22, cc.c4b(0x64,0x32,0x23,0xff), cc.p(1, 0.5), cc.p(680, -555),nil,nil,500)
    self.top_panel:addChild(self.time_label)

    --商店
    self.shop_btn = self.top_panel:getChildByName("shop_btn")
    self.shop_btn:getChildByName("label"):setString(TI18N("商店"))
    --排行榜
    self.rank_btn = self.top_panel:getChildByName("rank_btn")
    self.rank_btn:getChildByName("label"):setString(TI18N("排行奖励"))


    -- bottom_panel
    self.report_btn = self.bottom_panel:getChildByName("report_btn")
    self.report_btn:getChildByName("label"):setString(TI18N("战报"))

    self.form_btn = self.bottom_panel:getChildByName("form_btn")
    self.form_btn:getChildByName("label"):setString(TI18N("布阵"))

    self.fight_btn = self.bottom_panel:getChildByName("fight_btn")
    self.fight_btn:setVisible(false)
    self.fight_btn_icon = self.fight_btn:getChildByName("Sprite_1")
    self.fight_btn_label = self.fight_btn:getChildByName("label")
    self.fight_btn_label:setString(TI18N("组队大厅"))

    self.reward_btn = self.bottom_panel:getChildByName("reward_btn")
    self.reward_btn:getChildByName("label"):setString(TI18N("挑战奖励"))
    self.reward_count = self.reward_btn:getChildByName("count")
    self.spine = self.reward_btn:getChildByName("spine")

    local res_id = PathTool.getEffectRes(110)
    self.reward_box = createEffectSpine(res_id, cc.p(0, -20), cc.p(0.5, 0.5), true, PlayerAction.action_1)
    self.spine:addChild(self.reward_box)

    --挑战次数
    self.change_count = self.bottom_panel:getChildByName("change_count")
    self.change_count:setString(TI18N("挑战次数: 0"))
    self.resume_count = createRichLabel(20, cc.c4b(0xff,0xf8,0xbf,0xff), cc.p(0.5, 0.5), cc.p(612, 125),nil,nil,500)
    self.bottom_panel:addChild(self.resume_count)

    self.open_tips = self.bottom_panel:getChildByName("open_tips")
    self.open_tips:setString(TI18N("暂未开启组队"))

    self.open_tips_time = createRichLabel(22, cc.c4b(0x95,0x53,0x22,0xff), cc.p(0.5, 0.5), cc.p(360, 347),nil,nil,1000) 
    self.bottom_panel:addChild(self.open_tips_time)

    --需要隐藏的一条线
    self.line = self.bottom_panel:getChildByName("line")
    self.my_team_name = self.bottom_panel:getChildByName("my_team_name")
    self.my_team_name:setString(TI18N("队伍名字"))
    --我的队伍信息
    self.team_info = self.bottom_panel:getChildByName("team_info")
    self.team_info:setVisible(false)
    self.chat_btn = self.team_info:getChildByName("chat_btn")
    self.chat_btn:getChildByName("label"):setString(TI18N("组队聊天"))    

    self.my_team_index = self.team_info:getChildByName("my_team_index")
    self.my_team_score = self.team_info:getChildByName("my_team_score")
    self.my_team_score:setString(TI18N("积分:  0"))
    self.power = self.team_info:getChildByName("power")

    self.head_list = {}
    for i=1,3 do
        self.head_list[i] = PlayerHead.new(PlayerHead.type.circle)
        self.head_list[i]:setHeadLayerScale(0.90)
        self.head_list[i]:setPosition(188 + 100 * (i - 1) , 56)
        self.head_list[i]:setLev(99)
        self.team_info:addChild(self.head_list[i])
    end

    self:adaptationScreen()
end

--设置适配屏幕
function ArenateamMainWindow:adaptationScreen()
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

    --多出的高度
    local height = (top_y - self.container_size.height) - bottom_y

    local size = self.panel_bg:getContentSize()
    self.panel_bg:setContentSize(cc.size(size.width, size.height + height))

    local size = self.panel_bg_0:getContentSize()
    self.panel_bg_0:setContentSize(cc.size(size.width, size.height + height))

    local lay_size = self.lay_srollview:getContentSize()
    self.lay_srollview:setContentSize(cc.size(lay_size.width, lay_size.height + height))

    local time_y = self.time_label:getPositionY()
    self.time_label:setPositionY(time_y - height)
    -- --主菜单 顶部的高度
    -- local top_height = MainuiController:getInstance():getMainUi():getTopViewHeight()
    -- --主菜单 底部的高度
    -- local bottom_height = MainuiController:getInstance():getMainUi():getTopViewHeight()
end


function ArenateamMainWindow:register_event(  )
    registerButtonEventListener(self.close_btn, handler(self, self.onClickCloseBtn), true, REGISTER_BUTTON_SOUND_CLOSED_TYPY)
    registerButtonEventListener(self.look_btn, handler(self, self.onClickRuleBtn), true, REGISTER_BUTTON_SOUND_BUTTON_TYPY, nil, 0.8)
    registerButtonEventListener(self.shop_btn, handler(self, self.onClickShopBtn), true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)
    registerButtonEventListener(self.rank_btn, handler(self, self.onClickRankBtn), true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)
   
    registerButtonEventListener(self.form_btn, handler(self, self.onClickFormBtn), true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)
    registerButtonEventListener(self.fight_btn, handler(self, self.onClickFightBtn), true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)

    registerButtonEventListener(self.chat_btn, handler(self, self.onClickChatBtn), true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)
    registerButtonEventListener(self.report_btn, handler(self, self.onClickReportBtn), true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)
    registerButtonEventListener(self.reward_btn, handler(self, self.onClickRewardBtn), true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)
    

    for i,head in ipairs(self.head_list) do
        head:addCallBack(function() self:onClickHead(i) end )
    end

    self:addGlobalEvent(ArenateamEvent.ARENATEAM_MAIN_EVENT, function(scdata)
        if not scdata then return end
        self:setScdata(scdata)
    end)
    self:addGlobalEvent(ArenateamEvent.ARENATEAM_MAIN_RANK_EVENT, function(rank_data)
        if not rank_data then return end
        self:setRankData(rank_data)
    end)


    --宝箱更新
    self:addGlobalEvent(ArenateamEvent.ARENATEAM_RECEIVE_BOX_EVENT, function()
        self:updateBoxRedPoint()
    end)

    --    --  增加物品的更新,红点
    -- self:addGlobalEvent(BackpackEvent.ADD_GOODS, function(bag_code, add_list)
    --     self:updateItemInfo()
    -- end)

    -- -- 删除一个物品更新,红点
    -- self:addGlobalEvent(BackpackEvent.DELETE_GOODS, function(bag_code,del_list)
    --     self:updateItemInfo()
    -- end)

    -- self:addGlobalEvent(BackpackEvent.MODIFY_GOODS_NUM, function(bag_code,change_list)
    --     self:updateItemInfo()
    -- end)

    -- -- 金币更新
    -- if not self.role_lev_event and self.role_vo then
    --     self.role_lev_event = self.role_vo:Bind(RoleEvent.UPDATE_ROLE_ATTRIBUTE, function(key, value) 
    --         if key == "brave_symbol" then 
    --             self:updateItemInfo()
    --         end
    --     end)
    -- end

    -- 组队竞技场红点变化事件
    self:addGlobalEvent(ArenateamEvent.ARENATEAM_ALL_RED_POINT_EVENT, function (  )
        self:updateRedPoint()
    end)

    -- 在线
    self:addGlobalEvent(ArenateamEvent.ARENATEAM_ONLINE_EVENT, function (  data)
        --在线信息
        self:updateOnlineInfo(data)
    end)
    
end

function ArenateamMainWindow:updateRedPoint()
    if not self.scdata then return end

    if self.scdata.state == 1 or self.scdata.state == 2 then
        --申请邀请的红点
        if model.is_apply_red or model.is_invitation_red then
            addRedPointToNodeByStatus(self.fight_btn, true, 0, 5)
        else
            addRedPointToNodeByStatus(self.fight_btn, false, 5, 5)
        end

        --聊天红点
        if model.is_chat_red then
            addRedPointToNodeByStatus(self.chat_btn, true, 5, 5)
        else
            addRedPointToNodeByStatus(self.chat_btn, false, 5, 5)
        end
    else
        addRedPointToNodeByStatus(self.fight_btn, false, 5, 5)
        addRedPointToNodeByStatus(self.chat_btn, false, 5, 5)
    end
    --战报红点
    if model.is_report_red then
        addRedPointToNodeByStatus(self.report_btn, true, 5, 5)
    else
        addRedPointToNodeByStatus(self.report_btn, false, 5, 5)
    end
    
end

function ArenateamMainWindow:onClickHead(i)
    local team_members = self.scdata.team_members or {}
    local data = team_members[i]

    if not data then return end
    if self.head_list and self.head_list[i] then
        local roleVo = RoleController:getInstance():getRoleVo()
        if roleVo and data.rid == roleVo.rid and data.sid == roleVo.srv_id then 
            message(TI18N("这是你自己~"))
            return
        end
        FriendController:getInstance():openFriendCheckPanel(true, {srv_id = data.sid, rid = data.rid})
    end
end

-- 关闭
function ArenateamMainWindow:onClickCloseBtn(  )
    controller:openArenateamMainWindow(false)
end
-- 打开规则说明
function ArenateamMainWindow:onClickRuleBtn(  )
    MainuiController:getInstance():openCommonExplainView(true, Config.ArenaTeamData.data_explain)
end

-- 商店
function ArenateamMainWindow:onClickShopBtn(  )
    CrossarenaController:getInstance():openCrossarenaShopWindow(true)
end

-- 排行榜
function ArenateamMainWindow:onClickRankBtn(  )
    if not self.scdata then return end
    controller:openArenateamRankRewardPanel(true)
end

-- 布阵
function ArenateamMainWindow:onClickFormBtn(  )
    if not self.scdata then return end
    if self.scdata.tid == 0 then
        -- 打开个人队伍布阵
        HeroController:getInstance():openFormGoFightPanel(true, PartnerConst.Fun_Form.ArenaTeam, {}, HeroConst.FormShowType.eFormSave)
    else
        controller:openArenateamFormPanel(true)
    end
end
-- 战报
function ArenateamMainWindow:onClickReportBtn(  )
    controller:openArenateamFightRecordPanel(true)
end
-- 奖励
function ArenateamMainWindow:onClickRewardBtn(  )
    if not self.scdata then return end
    controller:openArenateamBoxRewardPanel(true)
end

-- 打开聊天
function ArenateamMainWindow:onClickChatBtn(  )
    controller:openArenateamChatPanel(true)
end

-- 战斗
function ArenateamMainWindow:onClickFightBtn(  )
    if not self.scdata then return end

    if self.scdata.state == 0 or self.scdata.state == 3 then
        message(TI18N("组队竞技场未开启"))
        return
    elseif self.scdata.state == 1 or (self.scdata.state == 2 and self.scdata.is_sign == 0) then
        if self.scdata.tid ~= 0 then
            --有队伍
            controller:openArenateamHallPanel(true ,{index = ArenateamConst.TeamHallTabType.eMyTeam})
        else
            controller:openArenateamHallPanel(true)
        end
    elseif self.scdata.state == 2 then
        if self.scdata.tid == 0 then
            message(TI18N("未组队不能参赛"))
            return
        end
        controller:openArenateamFightListPanel(true)
    elseif self.scdata.state == 4 then --战斗结算中
        message(TI18N("战斗结算中,请耐心等待"))
    end
end

function ArenateamMainWindow:openRootWnd(setting)
    local setting = setting or {}
    controller:sender27220()

    controller:sender27223(1, 100)
end

function ArenateamMainWindow:setScdata(scdata)
    self.scdata = scdata
    -- （0:未开启， 1:开启组队  2:开启挑战  3:排行展示）
    if self.scdata.state == 0 or self.scdata.state == 3 then
        self.my_team_name:setString(TI18N("我的队伍"))

        self.team_info:setVisible(false)
        self.line:setVisible(false)
        self.open_tips:setVisible(true)
        self.open_tips:setString(TI18N("暂未开启组队"))
        self.open_tips:setPositionY(380)

        self.fight_btn:setVisible(false)
        self.open_tips_time:setVisible(true)
        local time = self.scdata.end_time-- - GameNet:getInstance():getTime()
        if time < 0 then
            time = 0
        end
        commonCountDownTime(self.open_tips_time, time, {callback = function(time) self:setOPenTipsTimeFormatString(time) end})
        self.time_label:setVisible(false)
        self:updateChangeCount(false)
    elseif self.scdata.state == 1 or (self.scdata.state == 2 and self.scdata.is_sign == 0) then --开启组队 没有报名
        self.open_tips_time:setVisible(false)
        self.fight_btn:setVisible(true)
        self.fight_btn_label:setString(TI18N("组队大厅"))
        self:setFightBtnIcon(1)
        self:updateTeamInfo()

        self.time_label:setVisible(true)
        if self.scdata.state == 2 then
            self.time_key = TI18N("挑战关闭倒计时")
        else
            self.time_key = TI18N("挑战开启倒计时")
        end
        local time = self.scdata.end_time -- GameNet:getInstance():getTime()
        if time < 0 then
            time = 0
        end
        commonCountDownTime(self.time_label, time, {callback = function(time) self:setTimeValFormatString(time) end})

        self:updateChangeCount(false)
    elseif (self.scdata.state == 2 and self.scdata.is_sign == 1)  then --开启挑战
        self.open_tips_time:setVisible(false)
        self.fight_btn:setVisible(true)
        self.fight_btn_label:setString(TI18N("挑 战"))
        self:setFightBtnIcon(2)
        self:updateTeamInfo()
        
        self.time_key = TI18N("挑战关闭倒计时")

        local time = self.scdata.end_time -- GameNet:getInstance():getTime()
        if time < 0 then
            time = 0
        end
        commonCountDownTime(self.time_label, time, {callback = function(time) self:setTimeValFormatString(time) end})
        self:updateChangeCount(true)
    elseif self.scdata.state == 4 then
        self.my_team_name:setString(TI18N("我的队伍"))
        self.team_info:setVisible(false)
        self.line:setVisible(false)
        self.open_tips:setVisible(true)
        self.open_tips:setString(TI18N("赛季结算期无法进行组队或挑战"))
        self.open_tips:setPositionY(368)

        self.fight_btn:setVisible(false)
        self.open_tips_time:setVisible(false)
       
        self.time_key = TI18N("结算奖励发放倒计时")
        local time = self.scdata.end_time -- GameNet:getInstance():getTime()
        if time < 0 then
            time = 0
        end
        commonCountDownTime(self.time_label, time, {callback = function(time) self:setTimeValFormatString(time) end})
        self:updateChangeCount(false)
    end
    self:updateRedPoint()
    self:setTitleName(self.scdata.state)
end

function ArenateamMainWindow:setTitleName(state)
    if state == 0 then
        self.name:setString(TI18N("排行榜"))
    elseif state == 1 then
        self.name:setString(TI18N("排行榜(组队期)"))
    elseif state == 2 then
        self.name:setString(TI18N("排行榜(挑战期)"))
    elseif state == 3 then
        self.name:setString(TI18N("上赛季排行榜"))
    elseif state == 4 then
        self.name:setString(TI18N("排行榜(结算期)"))
    else
        self.name:setString(TI18N("排行榜"))
    end
end

--开启的tips倒计时
function ArenateamMainWindow:setOPenTipsTimeFormatString(time)
    if time > 0 then
        local str = string_format(TI18N("组队开启倒计时： <div fontcolor=#249003>%s</div>"),TimeTool.GetTimeForFunction(time))
        self.open_tips_time:setString(str)
    else
        self.open_tips_time:setString(string_format(TI18N("组队竞技场即将开启")))
    end
end
--开启的tips倒计时
function ArenateamMainWindow:setTimeValFormatString(time)
    if time > 0 then
        local str = string_format("<div fontcolor=#643223>%s：</div><div fontcolor=#249003> %s</div>", self.time_key, TimeTool.GetTimeFormatDayIIIIIIII(time))
        self.time_label:setString(str)
    else
        self.time_label:setString(string_format(TI18N("%s即将开启"), self.time_key))
    end
end

-- 恢复时间
function ArenateamMainWindow:setTimeFormatString(time)
    if time > 0 then
        local str = string_format(TI18N("<div outline=2,#000000>恢复时间: </div><div fontcolor=#7af655 outline=2,#000000 >%s</div>"),TimeTool.GetTimeForFunction(time))
        self.resume_count:setString(str)
    else
        local str = string_format(TI18N("<div outline=2,#000000>恢复时间: </div><div fontcolor=#7af655 outline=2,#000000 >%s</div>"),"00:00:00")
        self.resume_count:setString(str)
    end
end

function ArenateamMainWindow:setFightBtnIcon(status)
    if not self.fight_btn_icon then return end
    local res
    if status == 1 then --组队
        res = PathTool.getResFrame("arenateam","arenateam_17")
    elseif status == 2 then --战斗
        res = PathTool.getResFrame("common","common_2016")
    end
    if res then
        if self.record_fight_btn_res == nil or self.record_fight_btn_res  ~= res then
            self.record_fight_btn_res = res
            loadSpriteTexture(self.fight_btn_icon, res, LOADTEXT_TYPE_PLIST)
        end
    end
end

function ArenateamMainWindow:updateOnlineInfo(data)
    if not data then return end
    if self.scdata and self.scdata.team_members then
        for i,v in ipairs(self.scdata.team_members) do
            if v.rid == data.rid and v.sid == data.sid then
                local head = self.head_list[i]
                if head then
                    v.is_online = data.is_online
                    head:showOnline(true, data.is_online == 1)
                end
            end
        end
    end
end

function ArenateamMainWindow:updateTeamInfo()
    if not self.scdata then return end
    if self.scdata.tid ~= 0 then
        self.open_tips:setVisible(false)
        self.team_info:setVisible(true)
        self.line:setVisible(true)

        self.my_team_name:setString(self.scdata.team_name)
        self.power:setString(self.scdata.team_power)
        self.my_team_score:setString(string_format(TI18N("积分:  %s"), self.scdata.score))
        if self.scdata.rank == 0 then
            self.my_team_index:setString(TI18N("未上榜"))
        else
            self.my_team_index:setString(self.scdata.rank)
        end

        local team_members = self.scdata.team_members or {}
        for i,member_data in ipairs(team_members) do
            member_data.is_leader = 0
            for i,v in ipairs(member_data.ext) do
                if v.extra_key == 1 then --是否队长
                    if v.extra_val == 1 then
                        member_data.is_leader = 1
                    else
                        member_data.is_leader = -member_data.pos
                    end
                elseif v.extra_key == 6 then
                    member_data.is_online = v.extra_val
                end
            end
        end
        table_sort(team_members, function(a, b) return a.is_leader > b.is_leader end)

        for i,head in ipairs(self.head_list) do
            local member_data = team_members[i]
            if member_data then
                head:setHeadRes(member_data.face_id, false, LOADTEXT_TYPE, member_data.face_file, member_data.face_update_time)
                head:setLev(member_data.lev)
                if member_data.is_leader == 1 then
                    head:showLeader(true)    
                else
                    head:showLeader(false)
                end
                head:showOnline(true, member_data.is_online == 1)

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
            else
                --没有数据..还原
                head:clearHead()
                head:closeLev()
                head:showOnline(false)
                local bgRes = PathTool.getResFrame("common","common_1031")
                head:showBg(bgRes, nil, true)
                head:showLeader(false)
            end
        end
    else
        self.team_info:setVisible(false)
        self.line:setVisible(false)
        self.open_tips:setVisible(true)
        self.open_tips:setString(TI18N("暂未加入队伍，请前往组队大厅寻找或创建队伍"))
        self.open_tips:setPositionY(369) --395
        self.my_team_name:setString(TI18N("我的队伍"))
    end
end

function ArenateamMainWindow:updateChangeCount(status)
    if not self.scdata then return end

    
    self:updateBoxRedPoint()
    if status then
        self.change_count:setVisible(true)
        self.resume_count:setVisible(true)
        
        local limit_number = Config.ArenaTeamData.data_const.limit_number
        local max_count = 12
        if limit_number then
            max_count = limit_number.val
        end 

        local str = string_format("%s/%s",  self.scdata.count, max_count)
        self.change_count:setString(TI18N("挑战次数: "..str))

        local time = self.scdata.add_time - GameNet:getInstance():getTime()
        if time < 0 then
            time = 0
        end
        commonCountDownTime(self.resume_count, time, {callback = function(time) self:setTimeFormatString(time) end})
    else
        self.resume_count:setVisible(false)
        self.change_count:setVisible(false)
    end
end

function ArenateamMainWindow:updateBoxRedPoint()
    if not self.scdata then return end
    local config_list = Config.ArenaTeamData.data_challenge_count_reward_info
    if config_list and next(config_list) ~= nil then
        local config = config_list[#config_list]
        local max_box = config.count
        local str = string_format("%s/%s", self.scdata.do_count, max_box)
        self.reward_count:setString(str)

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

function ArenateamMainWindow:setRankData(rank_data)
    if not rank_data then return end
    self.show_list = rank_data.ranks or {}
    table_sort(self.show_list, function(a,b) return a.rank < b.rank end)
    self:updateItemlist()
end

--列表
function ArenateamMainWindow:updateItemlist()
    if not self.show_list then return end
    if self.scrollview_list == nil then
        local scrollview_size = self.lay_srollview:getContentSize()
        
        local setting = {
            start_x = 0,                     -- 第一个单元的X起点
            space_x = 0,                     -- x方向的间隔
            start_y = 0,                     -- 第一个单元的Y起点
            space_y = 0,                     -- y方向的间隔
            item_width = 648,                -- 单元的尺寸width
            item_height = 140,               -- 单元的尺寸height
            row = 1,                         -- 行数，作用于水平滚动类型
            col = 1,                         -- 列数，作用于垂直滚动类型
            delay = 1,                       -- 创建延迟时间
            once_num = 1,                    -- 每次创建的数量
        }
        self.scrollview_list = CommonScrollViewSingleLayout.new(self.lay_srollview, cc.p(0,0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scrollview_size, setting, cc.p(0, 0))

        self.scrollview_list:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
        self.scrollview_list:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
        self.scrollview_list:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
    end
    self.scrollview_list:reloadData()
    if #self.show_list == 0 then
        commonShowEmptyIcon(self.lay_srollview, true , {text = TI18N("虚位以待...")})
    else
        commonShowEmptyIcon(self.lay_srollview, false)
    end
end

--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function ArenateamMainWindow:createNewCell(width, height)
    local cell = ArenateamMainItem.new(width, height, self)
    return cell
end

--获取数据数量
function ArenateamMainWindow:numberOfCells()
    if not self.show_list then return 0 end
    return #self.show_list
end

--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--index :数据的索引
function ArenateamMainWindow:updateCellByIndex(cell, index)
    cell.index = index
    local data = self.show_list[index] 
    if data then
        cell:setData(data, index)
    end
    
end


function ArenateamMainWindow:close_callback(  )
    if self.role_lev_event and self.role_vo then
        self.role_vo:UnBind(self.role_lev_event)
        self.role_lev_event = nil
    end
    if self.head_list then
        for k,head in pairs(self.head_list) do
            head:DeleteMe()
        end
        self.head_list = nil
    end

    if self.scrollview_list then
        self.scrollview_list:DeleteMe()
    end
    self.scrollview_list = nil

    controller:openArenateamMainWindow(false)
end

-- 子项
ArenateamMainItem = class("ArenateamMainItem", function()
    return ccui.Widget:create()
end)

function ArenateamMainItem:ctor(width, height, parent)
    self.parent = parent
    self:configUI(width, height)
    self:register_event()
end

function ArenateamMainItem:configUI(width, height)
    self.size = cc.size(width,height)
    self:setTouchEnabled(true)
    self:setContentSize(self.size)

    local csbPath = PathTool.getTargetCSB("arenateam/arenateam_main_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self.root_wnd:setAnchorPoint(cc.p(0.5, 0.5))
    self.root_wnd:setPosition(width * 0.5, height * 0.5)
    self:addChild(self.root_wnd)

    self.main_container = self.root_wnd:getChildByName("main_container")

    self.head_node = self.main_container:getChildByName("head_node")
    self.head_list = {}
    for i=1,3 do
        self.head_list[i] = PlayerHead.new(PlayerHead.type.circle)
        self.head_list[i]:setSwallowTouches(false)
        self.head_list[i]:setHeadLayerScale(0.95)
        self.head_list[i]:setPosition(110 * (i - 1) , 0)
        self.head_list[i]:setLev(99)
        self.head_node:addChild(self.head_list[i])
    end

    self.team_index = self.main_container:getChildByName("team_index")
    self.team_name = self.main_container:getChildByName("team_name")
    self.team_score_key = self.main_container:getChildByName("team_score_key")
    self.team_score_value = self.main_container:getChildByName("team_score_value")

    self.sprite = self.main_container:getChildByName("sprite")
    self.power = self.main_container:getChildByName("power")

    self.team_score_key:setString(TI18N("积分:"))
end

function ArenateamMainItem:register_event( )
    for i,head in ipairs(self.head_list) do
        head:addCallBack(function() self:onClickHead(i) end )
    end
end

function ArenateamMainItem:onClickHead(i)
    local team_members = self.data.team_members or {}
    local data = team_members[i]

    if not data then return end
    if self.head_list and self.head_list[i] then
        local roleVo = RoleController:getInstance():getRoleVo()
        if roleVo and data.rid == roleVo.rid and data.sid == roleVo.srv_id then 
            message(TI18N("这是你自己~"))
            return
        end
        FriendController:getInstance():openFriendCheckPanel(true, {srv_id = data.sid, rid = data.rid})
    end
end

function ArenateamMainItem:setData(data, index)
    self.data = data

    self.team_name:setString(data.team_name)
    self.team_score_value:setString(data.score)
    self.power:setString(data.team_power)
    local team_members = data.team_members or {}
    for i,member_data in ipairs(team_members) do
        member_data.is_leader = 0
        for i,v in ipairs(member_data.ext) do
            if v.extra_key == 1 then --是否队长
                if v.extra_val == 1 then
                    member_data.is_leader = 1
                else
                    member_data.is_leader = -member_data.pos
                end
            end
        end
    end
    table_sort(team_members, function(a, b) return a.is_leader > b.is_leader end)


    for i,head in ipairs(self.head_list) do
        local member_data = team_members[i]
        if member_data then
            head:setHeadRes(member_data.face_id, false, LOADTEXT_TYPE, member_data.face_file, member_data.face_update_time)
            head:setLev(member_data.lev)
            if member_data.is_leader == 1 then
                head:showLeader(true)  
            else
                head:showLeader(false)
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
        else
            --没有数据..还原
            head:clearHead()
            head:closeLev()
            head:showLeader(false)
            local bgRes = PathTool.getResFrame("common","common_1031")
            head:showBg(bgRes, nil, true)
        end
    end

    if index == 1 then
        self.sprite:setVisible(true)
        self.team_index:setVisible(false)
        loadSpriteTexture(self.sprite, PathTool.getResFrame("common","common_2001"), LOADTEXT_TYPE_PLIST)
    elseif index == 2 then
        self.sprite:setVisible(true)
        self.team_index:setVisible(false)
        loadSpriteTexture(self.sprite, PathTool.getResFrame("common","common_2002"), LOADTEXT_TYPE_PLIST)
    elseif index == 3 then
        self.sprite:setVisible(true)
        self.team_index:setVisible(false)
        loadSpriteTexture(self.sprite, PathTool.getResFrame("common","common_2003"), LOADTEXT_TYPE_PLIST)
    else
        self.sprite:setVisible(false)
        self.team_index:setVisible(true)
        self.team_index:setString(index or 0)
    end
end


function ArenateamMainItem:DeleteMe()
    if self.item_list then
        for i,item in ipairs(self.item_list) do
            item.item:DeleteMe()
        end
        self.item_list = {}
    end

    if self.head_list then
        for k,head in pairs(self.head_list) do
            head:DeleteMe()
        end
        self.head_list = nil
    end

    self:removeAllChildren()
    self:removeFromParent()
end

