-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      竞猜界面
-- <br/> 2019年11月13日
-- --------------------------------------------------------------------
ArenapeakchampionGuessingTabGuessing = class("ArenapeakchampionGuessingTabGuessing", function()
    return ccui.Widget:create()
end)

local controller = ArenapeakchampionController:getInstance()
local model = controller:getModel()
local table_insert = table.insert
local string_format = string.format

function ArenapeakchampionGuessingTabGuessing:ctor(parent)
    self.parent = parent
    self.role_vo = RoleController:getInstance():getRoleVo()
    self:loadResources()
end

function ArenapeakchampionGuessingTabGuessing:loadResources()

    --竞猜信息 必须优先注册
    if self.apc_guessing_info_event == nil then
        self.apc_guessing_info_event = GlobalEvent:getInstance():Bind(ArenapeakchampionEvent.ARENAPEAKCHAMPION_GUESSING_INFO_EVENT,function ( data )
            if not data then return end
            self.is_init_data = true
            self.scdata = data
            self:setData()
        end)
    end  

    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("bigbg/arenapeakchampion", "arenapeakchampion_guessing_centre", false), type = ResourcesType.single},
        {path = PathTool.getPlistImgForDownLoad("bigbg/arenapeakchampion", "txt_cn_arenapeakchampion_guessing_top", false), type = ResourcesType.single},
    } 
    self.resources_load = ResourcesLoad.New(true) 
    self.resources_load:addAllList(self.res_list, function()
        if self.parent then
            self:config()
            self:layoutUI()
            self:registerEvents()
            self.is_init_res = true
            self:setData()
        end
    end)
end

function ArenapeakchampionGuessingTabGuessing:config()

end

function ArenapeakchampionGuessingTabGuessing:layoutUI()
    local csbPath = PathTool.getTargetCSB("arenapeakchampion/arenapeakchampion_guessing_tab_guessing")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    --读取文件的大小
    self.size = self.root_wnd:getContentSize()
    self:setContentSize(self.size)

    self.container = self.root_wnd:getChildByName("container")
    -- self.container:setSwallowTouches(false)

    self.top_img = self.container:getChildByName("top_img")
    self.centre_img = self.container:getChildByName("centre_img")
    

    --缺 bg29
    loadSpriteTexture(self.top_img, PathTool.getPlistImgForDownLoad("bigbg/arenapeakchampion", "txt_cn_arenapeakchampion_guessing_top", false), LOADTEXT_TYPE)
    loadSpriteTexture(self.centre_img, PathTool.getPlistImgForDownLoad("bigbg/arenapeakchampion", "arenapeakchampion_guessing_centre", false), LOADTEXT_TYPE)
    
    -- self.look_btn = self.container:getChildByName("look_btn")
    -- self.look_btn:getChildByName("label"):setString(TI18N("规则说明"))
    -- self.record_btn = self.container:getChildByName("record_btn")
    -- self.record_btn:getChildByName("label"):setString(TI18N("竞猜记录"))

    --写弹幕留言
    -- self.wirte_btn = self.container:getChildByName("wirte_btn")
    -- self.wirte_btn:getChildByName("label"):setString(TI18N("发送弹幕"))
    -- self.info_btn = self.container:getChildByName("info_btn")
    -- self.info_btn_lable = self.info_btn:getChildByName("label")
    -- self.info_btn_lable:setString(TI18N("发送弹幕"))
    -- vs
    self.vs_img = self.container:getChildByName("vs_img")

    --我的代币
    self.item_count_label = createRichLabel(22, cc.c4b(0xff,0xf3,0xaa,0xff), cc.p(1, 0.5), cc.p(694,1081),nil,nil,1000)
    self.container:addChild(self.item_count_label)
    self:updateItemCount()

    self.centre_panel = self.container:getChildByName("centre_panel")
    self.empty_panel = self.container:getChildByName("empty_panel")

    self.win_img = self.centre_panel:getChildByName("win_img")
    self.left_good_img = self.centre_panel:getChildByName("left_good_img")
    self.right_good_img = self.centre_panel:getChildByName("right_good_img")
    self.left_good_img:setVisible(false)
    self.right_good_img:setVisible(false)

    local left_play_node = self.centre_panel:getChildByName("left_play_node")
    local left_power_click = self.centre_panel:getChildByName("left_power_click")
    self.left_fight_label = CommonNum.new(20, left_power_click, 0, - 2, cc.p(0.5, 0.5))
    self.left_fight_label:setPosition(103, 28)

    self.left_play_head = PlayerHead.new(PlayerHead.type.circle)
    -- self.left_play_head:setHeadLayerScale(0.90)
    self.left_play_head:setLev(99)
    self.left_play_head:addCallBack(function() self:onClickHeadBtn(1) end)
    left_play_node:addChild(self.left_play_head)

    local right_play_node = self.centre_panel:getChildByName("right_play_node")
    local right_power_click = self.centre_panel:getChildByName("right_power_click")
    self.right_fight_label = CommonNum.new(20, right_power_click, 0, - 2, cc.p(0.5, 0.5))
    self.right_fight_label:setPosition(103, 28)

    self.right_play_head = PlayerHead.new(PlayerHead.type.circle)
    -- self.right_play_head:setHeadLayerScale(0.90)
    self.right_play_head:setLev(99)
    self.right_play_head:addCallBack(function() self:onClickHeadBtn(2) end)
    right_play_node:addChild(self.right_play_head)

    self.centre_left_name = self.centre_panel:getChildByName("left_name")
    self.left_srv_name = self.centre_panel:getChildByName("left_srv_name")
    self.centre_right_name = self.centre_panel:getChildByName("right_name")
    self.right_srv_name = self.centre_panel:getChildByName("right_srv_name")
    self.time_val = self.centre_panel:getChildByName("time_val")
    self.match_value = createRichLabel(22, cc.c4b(0xf8,0xf0,0xba,0xff), cc.p(0.5, 0.5), cc.p(360,906),nil,nil,1000)
    self.container:addChild(self.match_value)

    --回放
    self.fight_btn = self.centre_panel:getChildByName("fight_btn")
    self.fight_btn:getChildByName("label"):setString(TI18N("观战"))
    --数据
    self.fight_info_btn = self.centre_panel:getChildByName("fight_info_btn")
    self.fight_info_btn:getChildByName("label"):setString(TI18N("对阵详情"))
    self.fight_info_btn:setVisible(false)

    --竞猜
    self.guessing_panel = self.container:getChildByName("guessing_panel")

    self.progress_bar = self.guessing_panel:getChildByName("progress_bar")
    self.progress_bar_x = self.progress_bar:getPositionX()
    self.progress_bar:setScale9Enabled(true)
    self.left_guess_btn = self.guessing_panel:getChildByName("left_guess_btn")
    self.right_guess_btn = self.guessing_panel:getChildByName("right_guess_btn")

    self.progress_img = self.guessing_panel:getChildByName("progress_img")
    self.left_name = self.guessing_panel:getChildByName("left_name")
    self.right_name = self.guessing_panel:getChildByName("right_name")

    self.left_guess_bg = self.guessing_panel:getChildByName("left_guess_bg")
    self.left_bet_name = self.guessing_panel:getChildByName("left_bet_name")
    self.right_guess_bg = self.guessing_panel:getChildByName("right_guess_bg")
    self.right_bet_name = self.guessing_panel:getChildByName("right_bet_name")

    self.left_rate = self.guessing_panel:getChildByName("left_rate")
    self.right_rate = self.guessing_panel:getChildByName("right_rate")

    self.left_guess_name = self.guessing_panel:getChildByName("left_guess_name")
    self.left_guess_name:setString(TI18N("竞猜"))
    self.right_guess_name = self.guessing_panel:getChildByName("right_guess_name")
    self.right_guess_name:setString(TI18N("竞猜"))
end

--事件
function ArenapeakchampionGuessingTabGuessing:registerEvents()
    -- registerButtonEventListener(self.province_btn, function() self:onProvinceBtn()  end ,false, 1)
    -- registerButtonEventListener(self.look_btn, function() self:onClickLookBtn()  end ,true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)
    -- registerButtonEventListener(self.record_btn, function() self:onClickRecordBtn()  end ,true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)
    registerButtonEventListener(self.fight_btn, function() self:onClickFightBtn()  end ,true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)
    registerButtonEventListener(self.fight_info_btn, function() self:onClickFightInfoBtn()  end ,true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)
    --左右竞猜
    registerButtonEventListener(self.right_guess_btn, function() self:onClickGuessBtn(2)  end ,true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)
    registerButtonEventListener(self.left_guess_btn, function() self:onClickGuessBtn(1)  end ,true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)

    --主面板信息 更新时间状态用
    if self.apc_main_event == nil then
        self.apc_main_event = GlobalEvent:getInstance():Bind(ArenapeakchampionEvent.ARENAPEAKCHAMPION_MAIN_EVENT,function ( data )
            self:updateTime()
            if data and data.step == 1 and data.round == 1 then
                controller:sender27703()
            end
        end)
    end 
    --通知客户端观看录像
    if self.apc_show_vedion_event == nil then
        self.apc_show_vedion_event = GlobalEvent:getInstance():Bind(ArenapeakchampionEvent.ARENAPEAKCHAMPION_SHOW_VEDIO_EVENT,function ( data )
            if self.parent and self.parent.cur_tab_index and self.parent.cur_tab_index == ArenapeakchampionConstants.guessing_tab.eGuessing then
                self.must_play_vedio = true
            end
            controller:sender27703()
        end)
    end 

    --竞猜信息
    if self.arenapeakchampion_update_guessing_info_event == nil then
        self.arenapeakchampion_update_guessing_info_event = GlobalEvent:getInstance():Bind(ArenapeakchampionEvent.ARENAPEAKCHAMPION_UPDATE_GUESSING_INFO_EVENT,function ( data )
            if not data then return end
            self:updateGuessPanel(data)
        end)
    end
    -- --竞猜押注返回
    if self.apc_guessing_stake_event == nil then
        self.apc_guessing_stake_event = GlobalEvent:getInstance():Bind(ArenapeakchampionEvent.ARENAPEAKCHAMPION_GUESSING_STAKE_EVENT,function ( data )
            if not data then return end
            if self.scdata then
                self.scdata.bet_type = data.bet_type
            end
            self:updateGuessName(data.bet_type)
        end)
    end
    -- --刷新竞猜币
    if self.apc_single_info_event == nil then
        self.apc_single_info_event = GlobalEvent:getInstance():Bind(ArenapeakchampionEvent.ARENAPEAKCHAMPION_SINGLE_INFO_EVENT,function ( data )
            self:updateItemCount()
        end)
    end
    -- 红点
    if self.apc_all_red_point_event == nil then
        self.apc_all_red_point_event = GlobalEvent:getInstance():Bind(ArenapeakchampionEvent.ARENAPEAKCHAMPION_ALL_RED_POINT_EVENT,function ( data )
            self:updateRedPoint()
        end)
    end
    -- self.role_vo = RoleController:getInstance():getRoleVo()
    -- if self.role_vo ~= nil then
    --     if self.role_assets_event == nil then
    --         self.role_assets_event = self.role_vo:Bind(RoleEvent.UPDATE_ROLE_ATTRIBUTE, function(key, value)
    --             if key == "peak_guess_cent" then
    --                 self:updateItemCount()
    --             end
    --         end)
    --     end
    -- end
end


-- 点击头像
function ArenapeakchampionGuessingTabGuessing:onClickHeadBtn( index )
    if not self.scdata then return end
    local rid 
    local srv_id
    if index == 1 then
        --左边
        rid = self.scdata.a_rid
        srv_id = self.scdata.a_srv_id
    else
        rid = self.scdata.b_rid
        srv_id = self.scdata.b_srv_id
    end
    if rid and srv_id then
        local roleVo = RoleController:getInstance():getRoleVo()
        if roleVo and rid == roleVo.rid and srv_id == roleVo.srv_id then 
            message(TI18N("这是你自己~"))
            return
        end

        if srv_id == "" then
            message(TI18N("角色信息丢失在异域中"))
            return
        end
        FriendController:getInstance():openFriendCheckPanel(true, {srv_id = srv_id, rid = rid})
    end
end

--说明
function ArenapeakchampionGuessingTabGuessing:onClickLookBtn()
    MainuiController:getInstance():openCommonExplainView(true, Config.ArenaPeakChampionData.data_explain_guess)
end

--记录
function ArenapeakchampionGuessingTabGuessing:onClickRecordBtn()
    controller:openArenapeakchampionGuessInfoPanel(true)
end

--战斗详情
function ArenapeakchampionGuessingTabGuessing:onClickFightInfoBtn()
    if not self.scdata then return end
    if self.scdata.step == 0 then
        message(TI18N("巅峰竞技场未开赛"))
        return
    end
    controller:openArenapeakchampionFightInfoPanel(true,{data = self.scdata})
end
--回放
function ArenapeakchampionGuessingTabGuessing:onClickFightBtn()
    if self.scdata then
        controller:openLookFightVedioPanel(self.scdata)
    end
end


function ArenapeakchampionGuessingTabGuessing:onClickGuessBtn(_type)
    if not self.scdata then return end
    if self.scdata.bet_type ~= 0 then
        message(TI18N("已经竞猜过啦"))
        return
    end

    local main_data = model:getMainData()
    if main_data.step == 0 or main_data.step_status == 2 then
        message(TI18N("赛季未开启"))
        return
    end
    
    if main_data and main_data.round_status == 2 then 
        if not self.a_ratio then return end
        if not self.b_ratio then return end
        --只有竞猜阶段才有效
        if _type == 1 then --左边
            controller:openArenapeakchampionGuessCountPanel(true, {name = self.scdata.a_name, bet_type = 1, ratio = self.a_ratio})
        else --右边
            controller:openArenapeakchampionGuessCountPanel(true, {name = self.scdata.b_name, bet_type = 2, ratio = self.b_ratio})
        end
    else
        message(TI18N("非竞猜阶段不可下注"))
    end
end

function ArenapeakchampionGuessingTabGuessing:updateItemCount()
    if not self.item_count_label then return end
      local item_cfg = Config.ItemData.data_get_data(33)
    if item_cfg then
        local guess_data = model:getMyGuessData()
        if guess_data then
            local count = guess_data.can_bet
            self.item_count_label:setString(string_format(TI18N("我的代币: <img src='%s' scale=0.25 /> %s"),PathTool.getItemRes(item_cfg.icon), count))
        end
    end
end

function ArenapeakchampionGuessingTabGuessing:updateTime()
    local main_data = model:getMainData()
    if main_data and main_data.step ~= 0 then
           --- 
        doStopAllActions(self.time_val)
        local time = main_data.round_status_time - GameNet:getInstance():getTime() 
        if time < 0 then
            time = 0
        end
        commonCountDownTime(self.time_val, time)
        if main_data.round_status == 2 then --竞猜
            self.fight_btn:setVisible(false)
            self.vs_img:setVisible(true)
            self.fight_info_btn:setVisible(true)
        else--休整和对战阶段
            if main_data.round_status == 1 then
                local res = PathTool.getResFrame("arenapeakchampion", "arenapeakchampion_guessing_19_1", false, "arenapeak_guessing")
                self.fight_btn:loadTexture(res, LOADTEXT_TYPE_PLIST)
                self.fight_btn:getChildByName("label"):setString(TI18N("查看"))
            else
                local res = PathTool.getResFrame("arenapeakchampion", "arenapeakchampion_guessing_19", false, "arenapeak_guessing")
                self.fight_btn:loadTexture(res, LOADTEXT_TYPE_PLIST)
                self.fight_btn:getChildByName("label"):setString(TI18N("观战"))
            end
            self.fight_btn:setVisible(true)
            self.vs_img:setVisible(false)
            self.fight_info_btn:setVisible(false)
        end
        if self.current_round_status == nil then
            self.current_round_status = main_data.round_status
        else
            --在这个界面变了状态
            if self.current_round_status ~= main_data.round_status then
                if self.current_round_status == 2 and main_data.round_status == 3 then
                    --从 竞猜阶段变成 对战阶段 --申请最新的对战信息(得有录像id)
                    -- self.must_play_vedio = true
                else
                    if main_data.round_status == 1 or main_data.round_status == 2 then
                        --从  对战阶段 变成休整阶段 --刷新代币
                        controller:sender27701()
                    end
                end
                controller:sender27703()
                self.current_round_status = main_data.round_status
            end
        end
    end
end

--@hero_vo 英雄数据
function ArenapeakchampionGuessingTabGuessing:setData()
    if not self.scdata then return end
    if self.is_init_data and self.is_init_res then
        --中间部分
        local main_data = model:getMainData()
        if not main_data then return end

        if main_data.step == 0 or main_data.step_status == 2 then
            --未开启页面
            self:showEmptyInfo(true, main_data)
            self:unEnabledGuessBtn(true)

            self.progress_bar:setPercent(50)
            self.progress_img:setPositionX(self.progress_bar_x)
            self.left_name:setString("")
            self.right_name:setString("")
            self.left_rate:setString("")
            self.right_rate:setString("")

            self.left_guess_bg:setVisible(false)
            self.left_bet_name:setVisible(false)
            self.right_guess_bg:setVisible(false)
            self.right_bet_name:setVisible(false)
            return
        end
        self:showEmptyInfo(false)
        if self.must_play_vedio then
            --需要进入播放录像
            self.must_play_vedio = false
            if #self.scdata.result_info > 0 then
                table.sort( self.scdata.result_info, function(a,b) return a.order < b.order end)
                for i,v in ipairs(self.scdata.result_info) do
                    if v.replay_id ~= 0  then
                        BattleController:getInstance():csRecordBattle(v.replay_id, v.replay_sid)
                        return        
                    end
                end
            end
        end

        self:updateTime()
        self:updateCentrePanel()
        self:updateGuessPanel()    
    end
end

--更新中间部分
function ArenapeakchampionGuessingTabGuessing:updateCentrePanel( )
    if not self.scdata then return end
    self:setHeadInfo(self.left_play_head, self.scdata.a_lev, self.scdata.a_face,self.scdata.a_avatar_id, self.scdata.a_face_file, self.scdata.a_face_update_time)
    self:setHeadInfo(self.right_play_head, self.scdata.b_lev, self.scdata.b_face,self.scdata.b_avatar_id,self.scdata.b_face_file, self.scdata.b_face_update_time)

    self.centre_left_name:setString(self.scdata.a_name)
    self.centre_right_name:setString(self.scdata.b_name)

    local srv_name = getServerName(self.scdata.a_srv_id)
    if srv_name == "" then
        srv_name = TI18N("异域")
    end
    self.left_srv_name:setString(string_format("[%s]",srv_name))

    srv_name = getServerName(self.scdata.b_srv_id)
    if srv_name == "" then
        srv_name = TI18N("异域")
    end
    self.right_srv_name:setString(string_format("[%s]",srv_name))
    
    self.left_fight_label:setNum(self.scdata.a_power)
    self.right_fight_label:setNum(self.scdata.b_power)
    --"结果(0:未打 1:胜利 2:失败)"}
    if self.scdata.ret == 0 then
        self.win_img:setVisible(false)
    else
        self.win_img:setVisible(true)
        if self.scdata.ret == 1 then --左边胜利
            self.win_img:setPositionX(60)
        else
            self.win_img:setPositionX(632)
        end
    end
    local main_data = model:getMainData()
    if main_data then
        local str, str1 = model:getMacthText(main_data.step, main_data.round, main_data.round_status)
        local match_str = str or ""
        if str1 then
            match_str = match_str ..string_format("<div fontcolor=#52f559>%s</div>", str1)
        end
        self.match_value:setString(match_str)
    end
end

function ArenapeakchampionGuessingTabGuessing:setHeadInfo(head, lev, face_id, avatar_bid, face_file, face_update_time)
    head:setHeadRes(face_id or 1001, false, LOADTEXT_TYPE, face_file, face_update_time)
    head:setLev(lev or 1)

    if avatar_bid and head.record_res_bid == nil or head.record_res_bid ~= avatar_bid then
        head.record_res_bid = avatar_bid
        local vo = Config.AvatarData.data_avatar[avatar_bid]
        --背景框
        if vo then
            local res_id = vo.res_id or 1
            local res = PathTool.getTargetRes("headcircle", "txt_cn_headcircle_" .. res_id, false, false)
            head:showBg(res, nil, false, vo.offy)
        end
    end
end

function ArenapeakchampionGuessingTabGuessing:unEnabledGuessBtn(status)
    if status then
        self.left_guess_name:disableEffect(cc.LabelEffect.OUTLINE)
        self.right_guess_name:disableEffect(cc.LabelEffect.OUTLINE)
        setChildUnEnabled(true, self.left_guess_btn)
        setChildUnEnabled(true, self.right_guess_btn)
        setChildUnEnabled(true, self.left_guess_name)
        setChildUnEnabled(true, self.right_guess_name)
    else
        self.left_guess_name:enableOutline(cc.c4b(0x16,0x35,0x76,0xff), 2)
        self.right_guess_name:enableOutline(cc.c4b(0x8E,0x3A,0x08,0xff), 2)
        setChildUnEnabled(false, self.left_guess_btn)
        setChildUnEnabled(false, self.right_guess_btn)
        setChildUnEnabled(false, self.left_guess_name)
        setChildUnEnabled(false, self.right_guess_name)
    end
end

function ArenapeakchampionGuessingTabGuessing:updateGuessName(bet_type)
    if not self.left_guess_name then return end
    if not self.scdata then return end
    if not bet_type then return end

    if bet_type == 0 then
        self.left_guess_bg:setVisible(false)
        self.left_bet_name:setVisible(false)
        self.right_guess_bg:setVisible(false)
        self.right_bet_name:setVisible(false)

        local main_data = model:getMainData()
        if main_data and main_data.round_status == 2 then 
            --只有竞猜阶段才亮
            self:unEnabledGuessBtn(false)    
        else
            self:unEnabledGuessBtn(true)
        end

        self.left_good_img:setVisible(false)
        self.right_good_img:setVisible(false)
    else
        local bet_name 

        if bet_type == 1 then
            self.left_guess_bg:setVisible(true)
            self.left_bet_name:setVisible(true)
            self.right_guess_bg:setVisible(false)
            self.right_bet_name:setVisible(false)
            bet_name = self.left_bet_name
            self.left_good_img:setVisible(true)
            self.right_good_img:setVisible(false)
        else
            self.left_guess_bg:setVisible(false)
            self.left_bet_name:setVisible(false)
            self.right_guess_bg:setVisible(true)
            self.right_bet_name:setVisible(true)
            self.left_good_img:setVisible(false)
            self.right_good_img:setVisible(true)
            bet_name = self.right_bet_name
        end

        --置灰
        self:unEnabledGuessBtn(true)

        if self.scdata.ret == 0 then
            --已下注
            bet_name:setString(TI18N("已下注"))
            bet_name:setTextColor(cc.c4b(0x0e, 0xfc, 0x13, 0xff))
        else
            --胜利方 和猜测放一致 说明猜中了
            if self.scdata.ret == self.scdata.bet_type  then
                bet_name:setString(TI18N("猜中"))
                bet_name:setTextColor(cc.c4b(0x0e, 0xfc, 0x13, 0xff))
            else
                bet_name:setString(TI18N("猜错"))
                bet_name:setTextColor(cc.c4b(0xfc, 0x5c, 0x0e, 0xff))
            end

        end
    end
end

function ArenapeakchampionGuessingTabGuessing:updateGuessPanel(data)
    if not self.scdata then return end
    if data == nil then
        --不是实时更新的 
        self:updateGuessName(self.scdata.bet_type)
        self.left_name:setString(transformNameByServ(self.scdata.a_name, self.scdata.a_srv_id))
        self.right_name:setString(transformNameByServ(self.scdata.b_name, self.scdata.b_srv_id))
    end
    local data = data or self.scdata

    self.a_ratio =  data.a_bet_ratio
    self.b_ratio =  data.b_bet_ratio

    self.left_rate:setString(string_format(TI18N("赔率:%0.2f"), self.a_ratio/1000))
    self.right_rate:setString(string_format(TI18N("赔率:%0.2f"), self.b_ratio/1000))

     -- 设置竞猜值
    local total_bet = data.a_bet + data.b_bet
    if total_bet == 0 then
        self.progress_bar:setPercent(50)
        self.progress_img:setPositionX(self.progress_bar_x)
    else
        local width = 461
        local rate = 100 * data.a_bet/total_bet
        self.progress_bar:setPercent(rate)
        local x = self.progress_bar_x - width * 0.5 + width * (rate / 100)
        self.progress_img:setPositionX(x)
    end
    self:updateRedPoint() 
end
function ArenapeakchampionGuessingTabGuessing:updateRedPoint(  )
    local status = model:getGuessRedPoint()
    if self.left_guess_btn then
        addRedPointToNodeByStatus(self.left_guess_btn, status, 0, 0)
    end
    if self.right_guess_btn then
        addRedPointToNodeByStatus(self.right_guess_btn, status, 0, 0)
    end
end

function ArenapeakchampionGuessingTabGuessing:showEmptyInfo(is_show, main_data)
    if not self.empty_panel then return end
    if is_show then
        if self.centre_img then
            self.centre_img:setVisible(false)
        end
        self.centre_panel:setVisible(false)
        self.vs_img:setVisible(false)
        self.empty_panel:setVisible(true)
        if self.gril_img_load == nil then
            local gril_img = self.empty_panel:getChildByName("gril_img")
            local res  = PathTool.getPlistImgForDownLoad("bigbg","bigbg_50", false)
            self.gril_img_load = loadSpriteTextureFromCDN(gril_img, res, ResourcesType.single, self.gril_img_load) 
        end

        if self.talk_img_load == nil then
            local talk_img = self.empty_panel:getChildByName("talk_img")
            local res  = PathTool.getPlistImgForDownLoad("bigbg","bigbg_96", false)
            self.talk_img_load = loadSpriteTextureFromCDN(talk_img, res, ResourcesType.single, self.talk_img_load) 
        end

        self.empty_label = createRichLabel(28, cc.c4b(0x64,0x32,0x23,0xff), cc.p(0.5, 0.5), cc.p(360,112),nil,nil,1000)
        self.empty_panel:addChild(self.empty_label)
        if main_data then
            local time = main_data.start_time - GameNet:getInstance():getTime() 
            if time < 0 then
                time = 0
            end
            commonCountDownTime(self.empty_label, time,{callback = function(time) self:setTimeFormatString(time) end})
        end
        self.match_value:setString(TI18N("未开赛"))
    else
        self.empty_panel:setVisible(false)
        if self.empty_label then
            doStopAllActions(self.empty_label)
        end
        if self.centre_img then
            self.centre_img:setVisible(true)
        end
        self.centre_panel:setVisible(true)
    end
end

function ArenapeakchampionGuessingTabGuessing:setTimeFormatString(time)
    if time > 0 then
        self.empty_label:setString(string_format(TI18N("距离比赛开启: <div fontcolor=#249003>%s</div>"), TimeTool.GetTimeFormatDay(time)))
    else
        self.empty_label:setString(TI18N("巅峰冠军赛即将开始"))
    end
end

function ArenapeakchampionGuessingTabGuessing:setVisibleStatus(bool)
    self:setVisible(bool)
    if bool then
        if not self.is_init then
            self.is_init = true
            controller:sender27703()
            controller:sender27701()
        end
    end
end

--移除
function ArenapeakchampionGuessingTabGuessing:DeleteMe()

    if self.resources_load then
        self.resources_load:DeleteMe()
    end
    self.resources_load = nil
    
    self.parent = nil
    doStopAllActions(self.time_val)
    if self.empty_label then
        doStopAllActions(self.empty_label)
    end
    if self.apc_main_event then
        GlobalEvent:getInstance():UnBind(self.apc_main_event)
        self.apc_main_event = nil
    end
    if self.apc_show_vedion_event then
        GlobalEvent:getInstance():UnBind(self.apc_show_vedion_event)
        self.apc_show_vedion_event = nil
    end

    if self.apc_guessing_info_event then
        GlobalEvent:getInstance():UnBind(self.apc_guessing_info_event)
        self.apc_guessing_info_event = nil
    end

    if self.arenapeakchampion_update_guessing_info_event then
        GlobalEvent:getInstance():UnBind(self.arenapeakchampion_update_guessing_info_event)
        self.arenapeakchampion_update_guessing_info_event = nil
    end

    if self.apc_guessing_stake_event then
        GlobalEvent:getInstance():UnBind(self.apc_guessing_stake_event)
        self.apc_guessing_stake_event = nil
    end

    if self.apc_single_info_event then
        GlobalEvent:getInstance():UnBind(self.apc_single_info_event)
        self.apc_single_info_event = nil
    end

    if self.apc_all_red_point_event then
        GlobalEvent:getInstance():UnBind(self.apc_all_red_point_event)
        self.apc_all_red_point_event = nil
    end

    -- if self.role_vo ~= nil then
    --     if self.role_assets_event ~= nil then
    --         self.role_vo:UnBind(self.role_assets_event)
    --         self.role_assets_event = nil
    --     end
    --     self.role_vo = nil
    -- end

    if self.left_fight_label then
        self.left_fight_label:DeleteMe()
        self.left_fight_label = nil
    end
    if self.right_fight_label then
        self.right_fight_label:DeleteMe()
        self.right_fight_label = nil
    end

    -- if self.role_update_event and self.role_vo then
    --     self.role_update_event = self.role_vo:UnBind(self.role_update_event)
    --     self.role_update_event = nil
    -- end
end
