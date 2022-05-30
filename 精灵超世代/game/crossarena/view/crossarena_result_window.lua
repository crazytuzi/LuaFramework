--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-05-05 17:13:39
-- @description    : 
		-- 跨服竞技场结算界面
---------------------------------
local _controller = CrossarenaController:getInstance()
local _model = _controller:getModel()
local _string_format = string.format

CrossArenaResultWindow = CrossArenaResultWindow or BaseClass(BaseView)

function CrossArenaResultWindow:__init()
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Tips
    self.layout_name = "crossarena/crossarena_result_window"

    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("crossarena_result", "crossarena_result"), type = ResourcesType.plist},
    }

    self.award_item_list = {}
    self.show_ani_num = 0  -- 标识是否正在播放动画的item数量
    self.is_get_award = false -- 标识是否已经翻牌
end

function CrossArenaResultWindow:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    self.container = self.root_wnd:getChildByName("container")

    self.success_bg = self.container:getChildByName("success_bg")
    self.fail_bg = self.container:getChildByName("fail_bg")

    self.cancel_btn = self.container:getChildByName("cancel_btn")
    self.cancel_btn:getChildByName("label"):setString(TI18N("回到竞技场"))
    self.confirm_btn = self.container:getChildByName("confirm_btn")
    self.confirm_btn:getChildByName("label"):setString(TI18N("确定"))
    self.harm_btn = self.container:getChildByName("harm_btn")
    self.harm_btn:getChildByName("harm_lab"):setString(TI18N("数据统计"))

    self.container:getChildByName("title_award"):setString(TI18N("奖励选择"))
    self.top_name = self.container:getChildByName("top_name")
    self.bottom_name = self.container:getChildByName("bottom_name")
    self.free_time_txt = self.container:getChildByName("free_time_txt")
    self.free_time_txt:setString(TI18N("免费开启次数:1"))

    self.title_container = self.root_wnd:getChildByName("title_container")
    self.title_width = self.title_container:getContentSize().width
    self.title_height = self.title_container:getContentSize().height

    self.top_head = PlayerHead.new(PlayerHead.type.circle)
    self.top_head:setScale(0.8)
    self.top_head:setPosition(153, 475)
    self.container:addChild(self.top_head)

    self.top_result = createRichLabel(24, Config.ColorData.data_new_color4[6], cc.p(0, 0.5), cc.p(500, 475))
    self.container:addChild(self.top_result)

    self.bottom_head = PlayerHead.new(PlayerHead.type.circle)
    self.bottom_head:setScale(0.8)
    self.bottom_head:setPosition(153, 355)
    self.container:addChild(self.bottom_head)

    self.bottom_result = createRichLabel(24, Config.ColorData.data_new_color4[6], cc.p(0, 0.5), cc.p(500, 355))
    self.container:addChild(self.bottom_result)

    self.fight_text = createLabel(24, Config.ColorData.data_new_color4[6], nil, 360, 543, "",self.container, nil, cc.p(0.5,0.5))
    local name = Config.BattleBgData.data_fight_name[BattleConst.Fight_Type.CrossArenaWar]
    if name then
        self.fight_text:setString(TI18N("当前战斗：")..name)
    end
end

function CrossArenaResultWindow:register_event(  )
	-- 关闭
	registerButtonEventListener(self.confirm_btn, function (  )
        if self:checkIsCanCloseWindow() then
            _controller:openCrossarenaResultWindow(false)
        end
	end, true, 2)

    -- 回到竞技场
    registerButtonEventListener(self.cancel_btn, function (  )
        if self:checkIsCanCloseWindow() then
            _controller:openCrossarenaResultWindow(false)
            if not _controller:getCrossarenaMainRoot() then
                MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.main_scene, MainuiConst.sub_type.crossarenawar)
            end
        end
    end, true)

    registerButtonEventListener(self.harm_btn, handler(self, self._onClickHarmBtn), true)

    -- 监听翻牌数据变化
    self:addGlobalEvent(CrossarenaEvent.Update_Card_Info_Event, function ( data )
        self:setRewardsList(data)
    end)
end

-- 检测是否可以关闭界面
function CrossArenaResultWindow:checkIsCanCloseWindow(  )
    if not self.is_get_award then -- 还没有领取奖励
        local pos = math.random(1, 3)
        _controller:sender25613(pos)
        for k,item in pairs(self.award_item_list) do
            item:setTouchEnabled(false)
        end
        return false
    end

    -- 正在播放翻转动画
    if self.show_ani_num > 0 then return false end

    return true
end

function CrossArenaResultWindow:_onClickHarmBtn(  )
    if self.data and self.data.all_hurt_statistics then
        table.sort( self.data.all_hurt_statistics, function(a, b) return a.round < b.round end)
        local role_vo = RoleController:getInstance():getRoleVo()
        for i,v in ipairs(self.data.all_hurt_statistics) do
            v.atk_name = role_vo.name
            v.target_role_name = self.data.tar_name
        end
        BattleController:getInstance():openBattleHarmInfoView(true, self.data.all_hurt_statistics)
    end
end

function CrossArenaResultWindow:openRootWnd( data )
	playOtherSound("c_arenasettlement", AudioManager.AUDIO_TYPE.COMMON)
    _controller:sender25612() -- 请求翻牌数据
    if data ~= nil then
        BattleResultMgr:getInstance():setWaitShowPanel(true)
        self.data = data
        self:setBaseInfo()
        self.success_bg:setVisible(data.result == 1)
        self.fail_bg:setVisible(data.result == 2)
        self:handleEffect(true)
        self.harm_btn:setVisible(true)
    end
end

-- 基础信息
function CrossArenaResultWindow:setBaseInfo(  )
	if not self.data then return end

    local role_vo = RoleController:getInstance():getRoleVo()
    if not role_vo then return end
    self.top_head:setHeadRes(role_vo.face_id, false, LOADTEXT_TYPE, role_vo.face_file, role_vo.face_update_time)
    self.top_head:setLev(role_vo.lev)
    self.top_name:setString(role_vo.name)

    self.bottom_head:setHeadRes(self.data.tar_face, false, LOADTEXT_TYPE, self.data.face_file, self.data.face_update_time)
    self.bottom_name:setString(self.data.tar_name)
    self.bottom_head:setLev(self.data.tar_lev)

    local top_str = ""
    if self.data.get_score == 0 then
        top_str = _string_format(TI18N("积分:%s"), self.data.score)
    else
        if self.data.result == 1 then
            top_str = _string_format(TI18N("积分:<div fontcolor=#ffcc00>%s    </div><img src=%s scale=1 visible=true /><div fontcolor=#ffcc00>%s</div>"), self.data.score, PathTool.getResFrame("common", "common_1086"), self.data.get_score)
        else
            top_str = _string_format(TI18N("积分:<div fontcolor=#e14737>%s    </div><img src=%s scale=1 visible=true />><div fontcolor=#ff3a3a>%s</div>"), self.data.score, PathTool.getResFrame("common", "common_1087"), self.data.get_score)
        end
    end
    self.top_result:setString(top_str)

    local bottom_str = ""
    if self.data.lose_score == 0 then
        bottom_str = _string_format(TI18N("积分:%s"), self.data.tar_score)
    else
        if self.data.result == 1 then
            bottom_str = _string_format(TI18N("积分:<div fontcolor=#ffffff>%s    </div><img src=%s scale=1 visible=true /><div fontcolor=#ff3a3a>%s</div>"), self.data.tar_score, PathTool.getResFrame("common", "common_1087"), math.abs(self.data.lose_score))
        else
            bottom_str = _string_format(TI18N("积分:<div fontcolor=#ffffff>%s    </div><img src=%s scale=1 visible=true />><div fontcolor=#ffcc00>%s</div>"), self.data.tar_score, PathTool.getResFrame("common", "common_1086"), math.abs(self.data.lose_score))
        end

    end
    self.bottom_result:setString(bottom_str)
end

-- 奖励
function CrossArenaResultWindow:setRewardsList( data )
    if not data then return end

    table.sort(data, SortTools.KeyLowerSorter("pos"))

	local star_x = 145
	local distance_x = 20
	for i,v in ipairs(data) do
		local award_item = self.award_item_list[i]
		if not award_item then
			award_item = CrossareanResultItem.New(self.container, handler(self, self.showAniCallBack))
            self.award_item_list[i] = award_item
		end
		award_item:setPosition(cc.p(star_x + (i-1)*(distance_x+195), 180))
        award_item:setData(v)
        if v.status ~= 0 then
            self.is_get_award = true
        end
	end
end

function CrossArenaResultWindow:showAniCallBack( status, flag )
    if status ~= nil then
        if status == true then
            self.show_ani_num = self.show_ani_num + 1
        else
            self.show_ani_num = self.show_ani_num - 1
        end
        self.free_time_txt:setVisible(false)
    end
    if flag == true then
        for k,item in pairs(self.award_item_list) do
            item:setTouchEnabled(false)
        end
    end
end

function CrossArenaResultWindow:handleEffect(status)
    if status == false then
        if self.play_effect then
            self.play_effect:clearTracks()
            self.play_effect:removeFromParent()
            self.play_effect = nil
        end
    else
        local effect_id = 103
        local action = PlayerAction.action_2
        if self.data and self.data.result == 2 then
            effect_id = 104
            action = PlayerAction.action
            self.title_container:setPositionY(996)
        end
        if not tolua.isnull(self.title_container) and self.play_effect == nil then
            self.play_effect = createEffectSpine(PathTool.getEffectRes(effect_id), cc.p(self.title_width*0.5,self.title_height*0.5), cc.p(0.5, 0.5), false, action)
            self.title_container:addChild(self.play_effect, 1)
        end
    end
end

function CrossArenaResultWindow:close_callback(  )
	for k,v in pairs(self.award_item_list) do
		v:DeleteMe()
		v = nil
	end
	self:handleEffect(false)
    GlobalEvent:getInstance():Fire(BattleEvent.CLOSE_RESULT_VIEW)
	_controller:openCrossarenaResultWindow(false)
end

-----------------------@ item
CrossareanResultItem = CrossareanResultItem or BaseClass()

function CrossareanResultItem:__init(parent, callback)
    self.is_init = false
    self.open_status = false -- 是否已经翻开
    self.parent = parent
    self.callback = callback

    self:createRoorWnd()
    self:registerEvent()
end

function CrossareanResultItem:createRoorWnd(  )
	self.size = cc.size(216, 142)
	self.root_wnd = ccui.Layout:create()
	self.root_wnd:setContentSize(self.size)
	self.root_wnd:setAnchorPoint(cc.p(0.5, 0.5))
	self.root_wnd:setTouchEnabled(true)
    if not tolua.isnull(self.parent) then
        self.parent:addChild(self.root_wnd)
    end

    self.container = ccui.Layout:create()
    self.container:setContentSize(self.size)
    self.container:setAnchorPoint(cc.p(0.5, 0.5))
    self.container:setPosition(cc.p(self.size.width/2, self.size.height/2))
    self.container:setTouchEnabled(false)
    self.root_wnd:addChild(self.container)

    self.image_bg = createImage(self.container, PathTool.getResFrame("crossarena_result", "crossarena_result_3"), self.size.width/2, self.size.height/2, cc.p(0.5, 0.5), true)
    self.image_bg:setTouchEnabled(false)
end

function CrossareanResultItem:registerEvent(  )
	registerButtonEventListener(self.root_wnd, function (  )
		self:_onClickAwardItem()
	end, true, nil, nil, nil, 0.5)
end

function CrossareanResultItem:_onClickAwardItem(  )
	if self.data then
        _controller:sender25613(self.data.pos)
        if self.callback then
            self.callback(nil, true)
        end
    end
end

function CrossareanResultItem:setData( data )
    if not data then return end

    if not self.effect_id and data.reward and data.reward[1] then
        local bid = data.reward[1].item_id
        local item_cfg = Config.ItemData.data_get_data(bid)
        if item_cfg and item_cfg.quality >= BackPackConst.quality.orange then
            self.effect_id = 1201
        else
            self.effect_id = 1202
        end
    end
    if self.data and self.data.status == 0 then
        self.data = data
        if data.status == 1 then -- 从未开启到可购买(延迟翻牌)
            delayRun(self.container, 0.3, function (  )
                self:showRotateAni(true)
            end)
        elseif data.status == 2 then -- 从未开启到已获得(直接翻牌)
            self:showRotateAni()
        end
    else
        self.data = data
        if self.data and self.data.status == 2 and self.item_node then
            self.item_node:setGotIcon(true)
            if self.buy_btn then
                self.buy_btn:setVisible(false)
            end
        end
    end
end

-- 显示翻转动画 is_auto:是否为自动翻转
function CrossareanResultItem:showRotateAni( is_auto )
	if self.open_status then return end

    self.container:stopAllActions()
    -- 开始翻转则不让点击卡牌了
    self.root_wnd:setTouchEnabled(false)

    if not is_auto then
        self:handleEffect(true, PlayerAction.action_1)
    end
    local delay = cc.DelayTime:create(0.3)
	local action1 = cc.ScaleTo:create(0.1, 0.01, 1.2)
    local function call_back_1(  )
    	if not self.item_node then
    		self.item_node = BackPackItem.new(true, true)
            self.item_node:setAnchorPoint(0.5, 0.5)
            self.item_node:setScale(0.8)
            self.item_node:setPosition(cc.p(self.size.width/2, self.size.height/2+10))
            self.item_node:setDefaultTip()
            self.container:addChild(self.item_node)
    	end
        if self.data.reward and self.data.reward[1] then
            local bid = self.data.reward[1].item_id
            local num = self.data.reward[1].num
            self.item_node:setBaseData(bid, num)
            self.item_node:setExtendDesc(true)

            local item_cfg = Config.ItemData.data_get_data(bid)
            self.image_bg:loadTexture(PathTool.getResFrame("crossarena_result", "crossarena_result_2"), LOADTEXT_TYPE_PLIST)
            --self.effect_id = 1201
            if item_cfg and item_cfg.quality >= BackPackConst.quality.orange then
                --self.image_bg:loadTexture(PathTool.getResFrame("crossarena_result", "crossarena_result_1"), LOADTEXT_TYPE_PLIST)
                self.effect_id = 1201
            else
                --self.image_bg:loadTexture(PathTool.getResFrame("crossarena_result", "crossarena_result_2"), LOADTEXT_TYPE_PLIST)
                self.effect_id = 1202
            end
        end
    end
    local action2 = cc.ScaleTo:create(0.1, 1)
    local function call_back_2(  )
    	if is_auto then -- 自动翻转的需要显示购买按钮
            if not self.buy_btn then
                local btn_size = cc.size(168, 62)
                self.buy_btn = createButton(self.container, nil, self.size.width*0.5, -40, btn_size, PathTool.getResFrame("common", "common_1018"))
                self.buy_btn:addTouchEventListener(handler(self, self._onClickBuyBtn))
                self.buy_btn_label = createRichLabel(26, 1, cc.p(0.5, 0.5), cc.p(btn_size.width/2, btn_size.height/2))
                self.buy_btn:addChild(self.buy_btn_label)
            end
            if self.buy_btn_label and self.data.val and self.data.val[1] then
                local bid = self.data.val[1].item_id
                local num = self.data.val[1].num
                local item_cfg = Config.ItemData.data_get_data(bid)
                if item_cfg then
                    self.buy_btn_label:setString(_string_format(TI18N("<img src=%s scale=0.3 /><div >%d 获取</div>"), PathTool.getItemRes(item_cfg.icon), num))
                end
            end
        else
            self:handleEffect(true, PlayerAction.action_2)
        end
        if self.data and self.data.status == 2 and self.item_node then
            self.item_node:setGotIcon(true)
            if self.buy_btn then
                self.buy_btn:setVisible(false)
            end
        end
        if self.callback then
            self.callback(false)
        end
        self.open_status = true
    end
    if self.callback then
        self.callback(true)
    end
    self.container:runAction(cc.Sequence:create(delay, action1, cc.CallFunc:create(call_back_1), action2, cc.CallFunc:create(call_back_2)))
end

-- 点击购买
function CrossareanResultItem:_onClickBuyBtn( sender, event_type )
    if event_type == ccui.TouchEventType.ended then
        if self.data and self.data.pos then
            _controller:sender25613(self.data.pos)
        end
    end
end

-- 播放特效
function CrossareanResultItem:handleEffect( status, action )
    if status == false then
        if self.play_effect then
            self.play_effect:clearTracks()
            self.play_effect:removeFromParent()
            self.play_effect = nil
        end
    elseif self.effect_id then
        if not tolua.isnull(self.root_wnd) and self.play_effect == nil then
            self.play_effect = createEffectSpine(PathTool.getEffectRes(self.effect_id), cc.p(self.size.width/2, self.size.height/2+10), cc.p(0.5, 0.5), false, action)
            self.root_wnd:addChild(self.play_effect, 99)
        elseif self.play_effect then
            self.play_effect:setToSetupPose()
            self.play_effect:setAnimation(0, action, false)
        end
    end
end

function CrossareanResultItem:setPosition( pos )
	if self.root_wnd then
		self.root_wnd:setPosition(pos)
	end
end

function CrossareanResultItem:setTouchEnabled( status )
    if self.root_wnd then
        self.root_wnd:setTouchEnabled(status)
    end
end

function CrossareanResultItem:__delete(  )
    self:handleEffect(false)
	if self.item_node then
        self.item_node:DeleteMe()
        self.item_node = nil
    end
end