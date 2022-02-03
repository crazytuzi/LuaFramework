--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2018-11-05 17:31:16
-- @description    : 
		-- 天梯结算界面
---------------------------------

LadderBattleResultWindow = LadderBattleResultWindow or BaseClass(BaseView)

local role_vo = RoleController:getInstance():getRoleVo()
local string_format = string.format
local controller = LadderController:getInstance()

function LadderBattleResultWindow:__init()
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Tips
    self.layout_name = "ladder/ladder_battle_result_window"
    self.effect_cache_list = {}

    self.item_list = {}

    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("ladder", "ladder"), type = ResourcesType.plist},
    }
end

function LadderBattleResultWindow:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    local container = self.root_wnd:getChildByName("container")
    container:getChildByName("get_title"):setString(TI18N("获\n得\n奖\n励"))

    self.success_bg = container:getChildByName("success_bg")
    self.fail_bg = container:getChildByName("fail_bg")

    self.confirm_btn = container:getChildByName("confirm_btn")
    self.confirm_btn:getChildByName("label"):setString(TI18N("确定"))
    self.confirm_btn:setVisible(false)

    self.time_label = container:getChildByName("time_label")
    self.left_time = 10
    self.time_label:setString(TI18N("10秒后关闭"))

    self.harm_btn = container:getChildByName("harm_btn")
    self.harm_btn:setVisible(false)
    self.harm_btn:getChildByName("harm_lab"):setString(TI18N("数据统计"))
    
    self.top_head = PlayerHead.new(PlayerHead.type.circle)
    self.top_head:setScale(0.8)
    self.top_head:setPosition(153, 377)
    container:addChild(self.top_head)

    self.top_name = container:getChildByName("top_name")
    self.top_result = createRichLabel(22, cc.c3b(255, 232, 183), cc.p(0, 0.5), cc.p(380, 377))
    container:addChild(self.top_result)

    self.bottom_head = PlayerHead.new(PlayerHead.type.circle)
    self.bottom_head:setScale(0.8)
    self.bottom_head:setPosition(153, 275)
    container:addChild(self.bottom_head)
    self.bottom_name = container:getChildByName("bottom_name")
    self.bottom_result = createRichLabel(22, cc.c3b(255, 232, 183), cc.p(0, 0.5), cc.p(380, 275))
    container:addChild(self.bottom_result)

    self.title_container = self.root_wnd:getChildByName("title_container")
    self.title_width = self.title_container:getContentSize().width
    self.title_height = self.title_container:getContentSize().height

    self.container = container

    self.fight_text = createLabel(24, cc.c4b(0xff,0xee,0xac,0xff), nil, 360, 438, "",self.container, nil, cc.p(0.5,0.5))

    local name = Config.BattleBgData.data_fight_name[BattleConst.Fight_Type.LadderWar]
    if name then
        self.fight_text:setString(TI18N("当前战斗：")..name)
    end

    self.comfirm_btn = createButton(self.container,TI18N("确定"), 620, 580, cc.size(162, 62), PathTool.getResFrame("common", "common_1017"), 24, Config.ColorData.data_color4[1])
    self.comfirm_btn:setPosition(self.container:getContentSize().width / 2 - 170, 47)
    self.comfirm_btn:enableOutline(Config.ColorData.data_color4[264], 2)
    self.comfirm_btn:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            self:_onClickBtnClose()
        end
    end)

    self.cancel_btn = createButton(self.container,TI18N("返回玩法"), 620, 580, cc.size(162, 62), PathTool.getResFrame("common", "common_1018"), 24, Config.ColorData.data_color4[1])
    self.cancel_btn:setPosition(self.container:getContentSize().width / 2 + 170, 47)
    self.cancel_btn:enableOutline(Config.ColorData.data_color4[263], 2)
    self.cancel_btn:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            BattleResultReturnMgr:returnByFightType(BattleConst.Fight_Type.LadderWar) --先
            self:_onClickBtnClose()
        end
    end)
end

function LadderBattleResultWindow:register_event(  )
	registerButtonEventListener(self.background, handler(self, self._onClickBtnClose), false, 2)
	-- registerButtonEventListener(self.confirm_btn, handler(self, self._onClickBtnClose), true, 2)
    registerButtonEventListener(self.harm_btn, handler(self, self._onClickHarmBtn), true)
end

function LadderBattleResultWindow:_onClickHarmBtn(  )
    if self.data then
        local setting = {}
        setting.fight_type = BattleConst.Fight_Type.LadderWar
        BattleController:getInstance():openBattleHarmInfoView(true, self.data, setting)
    end
end

function LadderBattleResultWindow:_onClickBtnClose(  )
	controller:openLadderBattleResultWindow(false)
end

function LadderBattleResultWindow:handleEffect( status )
	if status == false then
        if self.play_effect then
            self.play_effect:clearTracks()
            self.play_effect:removeFromParent()
            self.play_effect = nil
        end
    else
        local effect_id = 103
        local action = PlayerAction.action_2
        if self.data.result == 2 then
            effect_id = 104
            action = PlayerAction.action
            self.title_container:setPositionY(912)
        end
        if not tolua.isnull(self.title_container) and self.play_effect == nil then
            self.play_effect = createEffectSpine(PathTool.getEffectRes(effect_id), cc.p(self.title_width*0.5,self.title_height*0.5), cc.p(0.5, 0.5), false, action)
            self.title_container:addChild(self.play_effect, 1)
        end
    end
end

function LadderBattleResultWindow:openRootWnd( data )
	playOtherSound("c_arenasettlement", AudioManager.AUDIO_TYPE.COMMON)
    if data ~= nil then

        BattleResultMgr:getInstance():setWaitShowPanel(true)
        self.data = data
        self:setBaseInfo()
        self:setRewardsList()
        self.success_bg:setVisible(data.result == 1)
        self.fail_bg:setVisible(data.result == 2)
        self:handleEffect(true)
        self:openCloseWindowTimer(true)
        if data.hurt_statistics then
            self.harm_btn:setVisible(true)
        end
    end
end

function LadderBattleResultWindow:setBaseInfo(  )
	if self.data == nil then return end
    self.top_head:setHeadRes(role_vo.face_id, false, LOADTEXT_TYPE, role_vo.face_file, role_vo.face_update_time)
    self.top_name:setString(role_vo.name)
    self.top_head:setLev(role_vo.lev)

    self.bottom_head:setHeadRes(self.data.def_face, false, LOADTEXT_TYPE, self.data.def_face_file, self.data.def_face_update_time)
    self.bottom_name:setString(self.data.def_name)
    self.bottom_head:setLev(self.data.def_lev)

    local top_str = ""
    local up_res = PathTool.getResFrame("common", "common_1086")
    local down_res = PathTool.getResFrame("common", "common_1087")

    local my_rank = self.data.atk_rank
    if not my_rank or my_rank == 0 then
        my_rank = TI18N("暂无")
    else
        my_rank = tostring(my_rank)
    end
    if self.data.atk_change_rank == 0 then -- 排名不变
        top_str = string_format(TI18N("排名:%s"), my_rank)
    else
        if self.data.atk_change_rank > 0 then -- 排名上升
        	top_str = string_format(TI18N("排名:<div fontcolor=#14ff32>%s</div><img src=%s scale=1 />"), my_rank, up_res)
        	if self.data.is_change_best_rank == 1 then
        		top_str = top_str .. string_format("    <img src=%s scale=1 />", PathTool.getResFrame("ladder", "txt_cn_ladder_highest"))
        	end
        else
        	top_str = string_format(TI18N("排名:<div fontcolor=#ff5050>%s</div><img src=%s scale=1 />"), my_rank, down_res)
        end
    end
    self.top_result:setString(top_str)

    local bottom_str = ""
    local def_rank = self.data.def_rank
    if not def_rank or def_rank == 0 then
        def_rank = TI18N("暂无")
    else
        def_rank = tostring(def_rank)
    end
    if self.data.def_change_rank == 0 then
    	bottom_str = string_format(TI18N("排名:%s"), def_rank)
    else
        if self.data.def_change_rank > 1 then
            bottom_str = string_format(TI18N("排名:<div fontcolor=#14ff32>%s</div><img src=%s scale=1 />"), def_rank, up_res)
        else
            bottom_str = string_format(TI18N("排名:<div fontcolor=#ff5050>%s</div><img src=%s scale=1 />"), def_rank, down_res)
        end

    end
    self.bottom_result:setString(bottom_str)
end

function LadderBattleResultWindow:setRewardsList(  )
	if self.data == nil or self.data.reward == nil or next(self.data.reward) == nil then return end
    local scale = 0.8
    local off = 40/(#self.data.reward)
    local _x, _y = 0, 164
    local item_conf = nil
    local index = 1
    local item = nil
    for i, v in ipairs(self.data.reward) do
        item_conf = Config.ItemData.data_get_data(v.bid)
        if item_conf then
            if self.item_list[index] == nil then
                item = BackPackItem.new(false, true, false, scale, false, true)
                self.container:addChild(item)
                table.insert(self.item_list, item)
            end
            item = self.item_list[index]
            
            _x = 212 + (BackPackItem.Width * scale + off) * (index-1) + BackPackItem.Width*scale*0.5
            item:setPosition(_x, _y)
            item:setBaseData(v.bid, v.num)
            item:setExtendDesc(true, item_conf.name, 1)
            index = index + 1
        end
    end 
end

function LadderBattleResultWindow:openCloseWindowTimer( status )
	if status then
		if self.close_timer == nil then
            self.close_timer = GlobalTimeTicket:getInstance():add(function()
                self.left_time = self.left_time - 1
                if self.left_time > 0 then
                	self.time_label:setString(string.format(TI18N("%d秒后关闭"), self.left_time))
                else
                	GlobalTimeTicket:getInstance():remove(self.close_timer)
            		self.close_timer = nil
            		self:_onClickBtnClose()
                end
            end, 1)
        end
	else
		if self.close_timer ~= nil then
            GlobalTimeTicket:getInstance():remove(self.close_timer)
            self.close_timer = nil
        end
	end
end

function LadderBattleResultWindow:close_callback(  )
	for k,v in pairs(self.item_list) do
        v:DeleteMe()
    end
    self.item_list = nil
    if self.top_head then
        self.top_head:DeleteMe()
        self.top_head = nil
    end
    if self.bottom_head then
        self.bottom_head:DeleteMe()
        self.bottom_head = nil
    end
    doStopAllActions(self.container)
    self:handleEffect(false)
    self:openCloseWindowTimer(false)
    GlobalEvent:getInstance():Fire(BattleEvent.CLOSE_RESULT_VIEW)
    controller:openLadderBattleResultWindow(false)
end