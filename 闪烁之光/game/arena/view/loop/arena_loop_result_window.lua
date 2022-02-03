-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      竞技场循环赛挑战胜利结算面板
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
ArenaLoopResultWindow = ArenaLoopResultWindow or BaseClass(BaseView)

local role_vo = RoleController:getInstance():getRoleVo()
local string_format = string.format
local controller = ArenaController:getInstance()

function ArenaLoopResultWindow:__init()
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Tips
    self.layout_name = "arena/arena_loop_result_window"
    self.effect_cache_list = {}

    self.item_list = {}

    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("arena", "arenaloop"), type = ResourcesType.plist},
    }
end

function ArenaLoopResultWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    local container = self.root_wnd:getChildByName("container")
    container:getChildByName("get_title"):setString(TI18N("获\n得\n奖\n励"))

    self.success_bg = container:getChildByName("success_bg")
    self.fail_bg = container:getChildByName("fail_bg")

    self.confirm_btn = container:getChildByName("confirm_btn")
    self.confirm_btn:getChildByName("label"):setString(TI18N("确定"))
    self.confirm_btn:getChildByName("label"):enableOutline(Config.ColorData.data_color4[264], 2)
    self.cancel_btn = container:getChildByName("cancel_btn")
    self.cancel_btn:getChildByName("label"):setString(TI18N("回到竞技场"))
    self.cancel_btn:getChildByName("label"):enableOutline(Config.ColorData.data_color4[263], 2)
    self.harm_btn = container:getChildByName("harm_btn")
    self.harm_btn:setVisible(false)
    self.harm_btn:getChildByName("harm_lab"):setString(TI18N("数据统计"))

    self.top_head = PlayerHead.new(PlayerHead.type.circle)
    self.top_head:setScale(0.8)
    self.top_head:setPosition(153, 317)
    container:addChild(self.top_head)

    self.top_name = container:getChildByName("top_name")
    self.top_result = createRichLabel(24, cc.c3b(0xff, 0xcc, 0x00), cc.p(0, 0.5), cc.p(380, 317))
    container:addChild(self.top_result)

    self.bottom_head = PlayerHead.new(PlayerHead.type.circle)
    self.bottom_head:setScale(0.8)
    self.bottom_head:setPosition(153, 215)
    container:addChild(self.bottom_head)
    self.bottom_name = container:getChildByName("bottom_name")
    self.bottom_result = createRichLabel(24, 1, cc.p(0, 0.5), cc.p(380, 215))
    container:addChild(self.bottom_result)

    self.title_container = self.root_wnd:getChildByName("title_container")
    self.title_width = self.title_container:getContentSize().width
    self.title_height = self.title_container:getContentSize().height

    self.container = container

    self.fight_text = createLabel(24, cc.c4b(0xff,0xee,0xac,0xff), nil, 360, 378, "",self.container, nil, cc.p(0.5,0.5))
    local name = Config.BattleBgData.data_fight_name[BattleConst.Fight_Type.Arena]
    if name then
        self.fight_text:setString(TI18N("当前战斗：")..name)
    end
end

function ArenaLoopResultWindow:register_event()
    self.background:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playCloseSound()
            controller:openLoopResultWindow(false)
        end
    end)

    self.confirm_btn:addTouchEventListener(function(sender, event_type)
        customClickAction(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playCloseSound()
            controller:openLoopResultWindow(false)
        end
    end)

    self.cancel_btn:addTouchEventListener(function(sender, event_type)
        customClickAction(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playCloseSound()
            controller:openLoopResultWindow(false)
            if controller:getArenaRoot() == nil then
                MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.main_scene, MainuiConst.sub_type.arena_call) 
            end
        end
    end)

    registerButtonEventListener(self.harm_btn, handler(self, self._onClickHarmBtn), true)
end

function ArenaLoopResultWindow:_onClickHarmBtn(  )
    if self.data then
        local setting = {}
        setting.fight_type = BattleConst.Fight_Type.Arena
        BattleController:getInstance():openBattleHarmInfoView(true, self.data, setting)
    end
end

function ArenaLoopResultWindow:handleEffect(status)
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

function ArenaLoopResultWindow:openRootWnd(data)
    if data ~= nil then
        BattleResultMgr:getInstance():setWaitShowPanel(true)
        self.data = data
        self:setBaseInfo()
        self:setRewardsList()
        self.success_bg:setVisible(data.result == 1)
        self.fail_bg:setVisible(data.result == 2)
        self:handleEffect(true)
        self.harm_btn:setVisible(true)
        if data.result == 1 then
            playOtherSound("b_win", AudioManager.AUDIO_TYPE.BATTLE)
        end
    end
end

function ArenaLoopResultWindow:setBaseInfo()
    if self.data == nil then return end
    self.top_head:setHeadRes(role_vo.face_id, false, LOADTEXT_TYPE, role_vo.face_file, role_vo.face_update_time)
    self.top_name:setString(role_vo.name)
    self.top_head:setLev(role_vo.lev)

    self.bottom_head:setHeadRes(self.data.tar_face, false, LOADTEXT_TYPE, self.data.face_file, self.data.face_update_time)
    self.bottom_name:setString(self.data.tar_name)
    self.bottom_head:setLev(self.data.tar_lev)

    local config =  Config.ArenaData.data_const.score_iocn
    if config then
        local str = ""
        if self.data.get_score == 0 then
            str = string_format("<img src=%s scale=0.3 visible=true /> %s", PathTool.getItemRes(config.val), self.data.score)
        else
            if self.data.result == 1 then
                str = string_format("<img src=%s scale=0.3 visible=true /> <div fontcolor=#ffcc00>%s    </div><img src=%s scale=1 visible=true /><div fontcolor=#ffcc00>%s</div>", PathTool.getItemRes(config.val), self.data.score, PathTool.getResFrame("common", "common_1086"), self.data.get_score)
            else
                str = string_format("<img src=%s scale=0.3 visible=true /> <div fontcolor=#e14737>%s    </div><img src=%s scale=1 visible=true />><div fontcolor=#ff3a3a>%s</div>", PathTool.getItemRes(config.val), self.data.score, PathTool.getResFrame("common", "common_1087"), self.data.get_score)
            end
        end
        self.top_result:setString(str)
        local bottom_str = ""
        if self.data.lose_score == 0 then
            bottom_str = string_format("<img src=%s scale=0.3 visible=true />%s", PathTool.getItemRes(config.val), self.data.tar_score)
        else
            if self.data.result == 1 then
                bottom_str = string_format("<img src=%s scale=0.3 visible=true /> <div fontcolor=#ffffff>%s    </div><img src=%s scale=1 visible=true /><div fontcolor=#ff3a3a>%s</div>", PathTool.getItemRes(config.val), self.data.tar_score, PathTool.getResFrame("common", "common_1087"), math.abs(self.data.lose_score))
            else
                bottom_str = string_format("<img src=%s scale=0.3 visible=true /> <div fontcolor=#ffffff>%s    </div><img src=%s scale=1 visible=true />><div fontcolor=#ffcc00>%s</div>", PathTool.getItemRes(config.val), self.data.tar_score, PathTool.getResFrame("common", "common_1086"), math.abs(self.data.lose_score))
            end

        end
        self.bottom_result:setString(bottom_str)
    end
end

function ArenaLoopResultWindow:setRewardsList()
    if self.data == nil or self.data.items == nil or next(self.data.items) == nil then return end
    local scale = 0.8
    local off = 40
    local _x, _y = 0, 104
    local item_conf = nil
    local index = 1
    local item = nil
    for i, v in ipairs(self.data.items) do
        item_conf = Config.ItemData.data_get_data(v.bid)
        if item_conf then
            if self.item_list[index] == nil then
                item = BackPackItem.new(false, true, false, scale, false, true)
                self.container:addChild(item)
                table.insert(self.item_list, item)
            end
            item = self.item_list[index]
            
            _x = 312 + (BackPackItem.Width * scale + off) * (index-1) + BackPackItem.Width*scale*0.5
            item:setPosition(_x, _y)
            item:setBaseData(v.bid, v.num)
            item:setExtendDesc(true, item_conf.name, 1)
            index = index + 1
        end
    end 
end

function ArenaLoopResultWindow:close_callback()
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
    GlobalEvent:getInstance():Fire(BattleEvent.CLOSE_RESULT_VIEW)
    controller:openLoopResultWindow(false)
end