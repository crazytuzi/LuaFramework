-- --------------------------------------------------------------------
--      召唤伙伴主界面
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
NewPartnerSummonWindow = NewPartnerSummonWindow or BaseClass(BaseView)

local item_pos_limit1 = 240
local item_pos_limit2 = 490
local item_img_width  = 360 --图片的宽度
local item_center_pos = {360,640} --位于中间的位置
local item_pos_x = {0,360,720}
-- local item_pos_y = 157
-- 100 --基础召唤-- 200 --友情召唤-- 300 --高级召唤
local recruit_list = {100,300,200}

local base_info = Config.RecruitData.data_partnersummon_data
local controller = NewPartnersummonController:getInstance()
local model = controller:getModel()
function NewPartnerSummonWindow:__init()
    self.win_type = WinType.Full
    self.layout_name = "newpartnersummon/newpartnersummon_window"
    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("newpartnersummon", "newpartnersummon"), type = ResourcesType.plist},
        -- { path = PathTool.getPlistImgForDownLoad("newpartnersummon","newpartnersummon_bg1",true), type = ResourcesType.single },
        -- { path = PathTool.getPlistImgForDownLoad("newpartnersummon","newpartnersummon_bg2",true), type = ResourcesType.single },
        -- { path = PathTool.getPlistImgForDownLoad("newpartnersummon","newpartnersummon_bg3",true), type = ResourcesType.single },
        -- { path = PathTool.getPlistImgForDownLoad("newpartnersummon","partnersummon_role1"), type = ResourcesType.single },
        -- { path = PathTool.getPlistImgForDownLoad("newpartnersummon","partnersummon_role2"), type = ResourcesType.single },
        -- { path = PathTool.getPlistImgForDownLoad("newpartnersummon","partnersummon_role3"), type = ResourcesType.single },
    }
    self.sprite_role_load = {}
    self.item_list_res = {}
    self.item_list_time = {}
    self.cur_index = 2
    self.cur_box_status = nil
    self.first_come = nil
    self.happening_touch = nil --避免玩家不断点击动画的时候
    self.use_once_item = {}
    self.use_five_item = {}
    self.summon_timer = {}
    self.is_use_once_ext = false
    self.is_use_five_ext = false
    self.role_vo = RoleController:getInstance():getRoleVo()
end

function NewPartnerSummonWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")

    local main_container = self.root_wnd:getChildByName("main_container")
    local bottom_y = display.getBottom(main_container)
    local pos_y = 0
    if display.getMaxScale() > 1 then
        pos_y = 20
    end
    main_container:setPositionY(main_container:getPositionY() + bottom_y + pos_y)

    self.main_container = main_container
    self.sprite_role = main_container:getChildByName("sprite_role")
    self.summon_type_txt = main_container:getChildByName("summon_type_txt")
    self.score_btn = main_container:getChildByName("score_btn")
    self.advanced_bg = main_container:getChildByName("Sprite_2") --高级召唤必出
    self.advanced_bg:setVisible(false)
    self.btn_rule = main_container:getChildByName("btn_rule")

    self.touch_layer = main_container:getChildByName("touch_layer")
    self.touch_layer:setScale(display.getMaxScale())
    self.touch_rect = main_container:getChildByName("touch_rect")
    self.touch_rect:setTouchEnabled(false)
    self.btn_left = self.touch_rect:getChildByName("btn_left")
    self.btn_right = self.touch_rect:getChildByName("btn_right")
    self.redpoint = {}
    for i=1,3 do
        local tab = {}
        tab.item = self.touch_rect:getChildByName("item_"..i)
        tab.item:setTouchEnabled(true)
        tab.item:setSwallowTouches(false)
        tab.item:setPositionX(item_pos_x[i])
        self.item_list_time[i] = self.touch_rect:getChildByName("time_"..i)
        self.item_list_time[i] = createRichLabel(20,1,cc.p(1,0.5),cc.p(tab.item:getContentSize().width-20,20))
        tab.item:addChild(self.item_list_time[i])
        tab.kuang = createSprite(PathTool.getResFrame("newpartnersummon","newpartnersummon_13"), tab.item:getContentSize().width*0.5, tab.item:getContentSize().height*0.5, tab.item, cc.p(0.5, 0.5))
        tab.kuang:setVisible(false)
        self.redpoint[i] = tab.item:getChildByName("redpoint_"..i)
        if self.redpoint[i] then
            self.redpoint[i]:setLocalZOrder(1)
            self.redpoint[i]:setVisible(false)
        end
        tab.item:loadTexture(PathTool.getResFrame("newpartnersummon", "newpartnersummon_" .. i), LOADTEXT_TYPE_PLIST)
        tab.index = i
        self.item_list_res[i] = tab
    end
    self.item_pos_y = self.item_list_res[1].item:getPositionY()
    self.progress_bg = createSprite(PathTool.getResFrame("newpartnersummon","newpartnersummon_9"), 657, 1100, main_container, cc.p(0.5, 0.5))
    self.score_progress = cc.ProgressTimer:create(createSprite(PathTool.getResFrame("newpartnersummon", "newpartnersummon_8"), 0, 0, nil, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST))
    self.score_progress:setPosition(self.progress_bg:getContentSize().width*0.5, self.progress_bg:getContentSize().height*0.5)
    self.score_progress:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
    self.progress_bg:addChild(self.score_progress)
    self.score_progress:setPercentage(0)

    local item_bg = main_container:getChildByName("item_bg")
    item_bg:setPositionX(65)
    local score_bg = main_container:getChildByName("score_bg")
    score_bg:setLocalZOrder(1)
    self.score_label = score_bg:getChildByName("Text_2")
    self.score_label:setString("")

    --推荐阵容
    self.btn_lineup = main_container:getChildByName("btn_lineup")
    self.btn_lineup:getChildByName("Text_3"):setString(TI18N("推荐阵容"))
    --招募一次
    self.btn_summon_1 = main_container:getChildByName("btn_summon_1")
    self.btn_summon_1:setScale(0.95)
    self.btn_summon_1:setPositionY(self.btn_summon_1:getPositionY()-5)
    self.btn_summon_1:getChildByName("Text_1"):setString(TI18N("招募1次"))
    self.summon_1_diammand = createRichLabel(20,58,cc.p(0.5,0.5),cc.p(self.btn_summon_1:getContentSize().width*0.5,28))
    self.btn_summon_1:addChild(self.summon_1_diammand)
    --招募10次
    self.btn_summon_10 = main_container:getChildByName("btn_summon_10")
    self.btn_summon_10:setScale(0.95)
    self.btn_summon_10:setPositionY(self.btn_summon_10:getPositionY()-5)
    self.btn_summon_10:getChildByName("Text_1"):setString(TI18N("招募10次"))
    self.summon_10_diammand = createRichLabel(20,58,cc.p(0.5,0.5),cc.p(self.btn_summon_10:getContentSize().width*0.5,28))
    self.btn_summon_10:addChild(self.summon_10_diammand)
    
    self:showArenaPeakEffect(self.btn_summon_1, true)
    self:showArenaPeakEffect(self.btn_summon_10, true)

    for i=1,3 do
        self:itemData(i,recruit_list[i])
    end
    self.first_come = true
    -- 引导需要
    local dun_id = self:getDramaDunMaxID()
    if dun_id <= 1 then
        self.cur_index = 1
        self:setMoveItenPos(360)
        self.btn_summon_1:setName("guildsign_summon_1_1")
    else
        self.btn_summon_1:setName("guildsign_summon_3_1")
    end
    self:tabChangeIndex(self.cur_index)

    -- 适配
    local top_y = display.getTop(self.main_container)
    local main_container_size = main_container:getContentSize()
    local tab_y = self.btn_lineup:getPositionY()
    self.btn_lineup:setPositionY(top_y - (main_container_size.height - tab_y))

    local tab_y = self.progress_bg:getPositionY()
    self.progress_bg:setPositionY(top_y - (main_container_size.height - tab_y))

    local tab_y = score_bg:getPositionY() - 25
    score_bg:setPositionY(top_y - (main_container_size.height - tab_y))

    local tab_y = self.score_btn:getPositionY() - 25
    self.score_btn:setPositionY(top_y - (main_container_size.height - tab_y))

    local tab_y = self.btn_rule:getPositionY() - 25
    self.btn_rule:setPositionY(top_y - (main_container_size.height - tab_y))
end

function NewPartnerSummonWindow:getDramaDunMaxID()
    local dun_id = 1
    local drame_controller = BattleDramaController:getInstance()
    local drama_data = drame_controller:getModel():getDramaData()
    if drama_data and drama_data.max_dun_id then
        local current_dun = Config.DungeonData.data_drama_dungeon_info(drama_data.max_dun_id)
        if current_dun then
            dun_id = current_dun.floor or 1
        end
    end
    return dun_id
end

function NewPartnerSummonWindow:register_event()
    registerButtonEventListener(self.btn_rule,function()
        MainuiController:getInstance():openCommonExplainView(true, Config.RecruitData.data_explain,TI18N("规则说明"),true)
    end)
    -- 积分更新
    if self.role_vo ~= nil then
        if self.role_assets_event == nil then
            self.role_assets_event = self.role_vo:Bind(RoleEvent.UPDATE_ROLE_ATTRIBUTE, function(key, value)
                if key == "recruit_hero" then
                    local cur_score = value
                    local max_score = PartnersummonController:getInstance():getModel():getScoreSummonNeedCount()
                    local percent = (cur_score/max_score)*100
                    self.score_progress:setPercentage(percent)
                    self.score_label:setString(string.format("%d/%d", cur_score, max_score))
                    self:showScoreFullAction(cur_score>=max_score)
                elseif key == "friend_point" then
                    if self.touch_index and base_info then
                        local group_id = recruit_list[self.touch_index]
                        local item_id = base_info[group_id].item_once[1][1]
                        local res = PathTool.getItemRes(Config.ItemData.data_get_data(item_id).icon)
                        local str = string.format("<img src=%s visible=true scale=0.40 /><div fontcolor=#ffffff outline=2,#000000>  %s</div>",res, value)
                        self.summon_assets:setString(str)
                    end
                end
            end)
        end
    end

    registerButtonEventListener(self.score_btn,function()
        PartnersummonController:getInstance():openPartnerSummonScoreWindow(true)
    end)

    registerButtonEventListener(self.btn_summon_1,function()
        self:ChooseSummonType(1)
    end,true)
    registerButtonEventListener(self.btn_summon_10,function()
        self:ChooseSummonType(10)
    end,true)

    for k, object in pairs(self.item_list_res) do
        if object.item then
            registerButtonEventListener(object.item,function()
                self.cur_index = object.index
            end)
        end
    end

    registerButtonEventListener(self.btn_lineup,function()
        JumpController:getInstance():jumpViewByEvtData({16, 3})
    end,true)
    
    self:addGlobalEvent(PartnersummonEvent.updateSummonItemEvent, function(data)
        if data then
            local check_index = nil
            for i=1, #recruit_list do
                if data.group_id == recruit_list[i] then
                    check_index = i
                    break
                end
            end
            if check_index == nil then
                return
            end

            self:itemData(check_index, data.group_id)
        end
    end)
    self:addGlobalEvent(PartnersummonEvent.updateSummonFiveStarEvent,function()
        self:heightSummonFiveStar()
    end)

    -- 道具数量更新
    self:addGlobalEvent(BackpackEvent.ADD_GOODS,function(bag_code, data_list)
        self:refreshExchangeItemNum(bag_code,data_list)
    end)
    self:addGlobalEvent(BackpackEvent.DELETE_GOODS,function(bag_code, data_list)
        self:refreshExchangeItemNum(bag_code,data_list)
    end)
    self:addGlobalEvent(BackpackEvent.MODIFY_GOODS_NUM,function(bag_code, data_list)
        self:refreshExchangeItemNum(bag_code,data_list)
    end)
end

function NewPartnerSummonWindow:showArenaPeakEffect(obj, bool)
    if not obj then return end
    if bool == true then
        if obj.arenapeak_effect == nil then
            local size = obj:getContentSize()
            obj.arenapeak_effect = createEffectSpine("E24756", cc.p(size.width * 0.5, size.height * 0.5), cc.p(0.5, 0.5), true, PlayerAction.action)
            obj:addChild(obj.arenapeak_effect, 1)
        else
            obj.arenapeak_effect:setAnimation(0, PlayerAction.action, true)
        end    
    else
        if obj.arenapeak_effect then 
            obj.arenapeak_effect:setVisible(false)
            obj.arenapeak_effect:removeFromParent()
            obj.arenapeak_effect = nil
        end
    end
end
-- 刷新道具显示
function NewPartnerSummonWindow:refreshExchangeItemNum(bag_code,data_list)
    if bag_code == BackPackConst.Bag_Code.BACKPACK and self.touch_index then
        local group_id = recruit_list[self.touch_index]
        local item_id = base_info[group_id].item_once[1][1]
        local item_config = Config.ItemData.data_get_data(item_id)
        local res = PathTool.getItemRes(item_config.icon)
        for i,v in pairs(data_list) do 
            if v and v.base_id and item_id == v.base_id then 
                local count = BackpackController:getInstance():getModel():getBackPackItemNumByBid(item_id)
                -- local str = string.format("<div fontcolor=#ffffff outline=2,#000000>%s </div><img src=%s visible=true scale=0.40 /><div fontcolor=#ffffff outline=2,#000000> %s</div>",TI18N("拥有物品"),res, count)
                local str = string.format("<img src=%s visible=true scale=0.40 /><div fontcolor=#ffffff outline=2,#000000>  %s</div>",res, count)
                self.summon_assets:setString(str)
            end
        end
        self:setOnceStatus(group_id)
        self:setTenStatus(group_id)
    end
end

function NewPartnerSummonWindow:openRootWnd()
    self:refreshProgressInfo(  )
    self:heightSummonFiveStar()
    self:registerEvent()
end
-- 刷新进度条相关信息
function NewPartnerSummonWindow:refreshProgressInfo(  )
    if self.role_vo then
        local cur_score = self.role_vo.recruit_hero
        local max_score = PartnersummonController:getInstance():getModel():getScoreSummonNeedCount()
        local percent = (cur_score/max_score)*100
        self.score_progress:setPercentage(percent)
        self.score_label:setString(string.format("%d/%d", cur_score, max_score))
        self:showScoreFullAction(cur_score>=max_score)
    end
end
function NewPartnerSummonWindow:showScoreFullAction(status)
    if self.cur_box_status == status then return end
    self.cur_box_status = status
    local action = PlayerAction.action_1
    if status then
        action = PlayerAction.action_2
    end
    if self.box_effect then
        self.box_effect:clearTracks()
        self.box_effect:removeFromParent()
        self.box_effect = nil
    end
    self.box_effect = createEffectSpine(PathTool.getEffectRes(110), cc.p(self.progress_bg:getContentSize().width*0.5, 28), cc.p(0.5, 0), true, action)
    self.progress_bg:addChild(self.box_effect)
end
function NewPartnerSummonWindow:registerEvent()
    local function onTouchBegin(touch, event)
        
        if self.touch_ticket == nil then
            self.touch_ticket = GlobalTimeTicket:getInstance():add(function()
                self.happening_touch = nil
                if self.touch_ticket ~= nil then
                    GlobalTimeTicket:getInstance():remove(self.touch_ticket)
                    self.touch_ticket = nil
                end
            end, 0.3)
        end
        if self.happening_touch then
            -- message(TI18N("点击过快"))
            return false
        end
        self.happening_touch = true
        self.touch_began = touch:getLocation()
        self.touch_point = nil
        doStopAllActions(self.item_list_res[1].item)
        doStopAllActions(self.item_list_res[2].item)
        doStopAllActions(self.item_list_res[3].item)

        local status = self:isTouchRect(self.touch_began.x ,self.touch_began.y)
        return status
    end
    -- local function onTouchMoved(touch, event)
        -- self.touch_point = touch:getDelta()
        -- self:setMoveItenPos(self.touch_point.x)
    -- end
    local function onTouchEnded(touch, event)
        self.touch_end = touch:getLocation()
        local is_click = false
        if self.touch_began then
            is_click = math.abs(self.touch_end.x - self.touch_began.x) >= 30 
        end
        local dis = self.touch_end.x - self.touch_began.x
        -- print("is_click..... ",is_click,self.cur_index,self.touch_index, dis, self.touch_end.x)
        self.cur_index = self.touch_index
        if is_click then--滑动的时候
            self:itemAction(is_click, dis)
        else--点击的时候
            if self:isTouchRectLeft(self.touch_began.x ,self.touch_began.y) then
                self:itemAction(true, 1)
            elseif self:isTouchRectRight(self.touch_began.x ,self.touch_began.y) then
                self:itemAction(true, -1)
            end
        end
        self:tabChangeIndex(self.cur_index)
    end
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(onTouchBegin,cc.Handler.EVENT_TOUCH_BEGAN)
    -- listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED)
    self.touch_rect:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self.touch_rect)
end
--判断是否在点击区域里面
function NewPartnerSummonWindow:isTouchRect(x,y)
    local status = false
    local y_ = self.touch_rect:getPositionY()
    local height_ = self.touch_rect:getContentSize().height
    if y >= (y_) and y <= (y_ + height_) then
        status = true
    end
    return status
end
--判断左边
function NewPartnerSummonWindow:isTouchRectLeft(x,y)
    local status = false
    local x_ = self.btn_left:getPositionX()
    local y_ = self.btn_left:getPositionY()
    local start_y = self.touch_rect:getPositionY() --y轴开始位置
    local width_ = self.btn_left:getContentSize().width
    local height_ = self.btn_left:getContentSize().height
    local bottom_y = 0--display.getBottom(self.main_container)
    if x >= x_ and x <= width_ and y >= (y_ - bottom_y+start_y) and y <= (y_+start_y + height_ - bottom_y) then
        status = true
    end
    return status
end
--判断右边
function NewPartnerSummonWindow:isTouchRectRight(x,y)
    local status = false
    local x_ = self.btn_right:getPositionX()
    local y_ = self.btn_right:getPositionY()
    local start_y = self.touch_rect:getPositionY() --y轴开始位置
    local width_ = self.btn_right:getContentSize().width
    local height_ = self.btn_right:getContentSize().height
    local bottom_y = 0--display.getBottom(self.main_container)
    if x >= x_ and x <= (x_+width_) and y >= (y_ - bottom_y+start_y) and y <= (y_+start_y + height_ - bottom_y) then
        status = true
    end
    return status
end


function NewPartnerSummonWindow:setMoveItenPos(inter_x)
    for i=1, 3 do
        if self.item_list_res[i].item then
            local item_x = self.item_list_res[i].item:getPositionX() 
            local x = item_x + inter_x

            if x <= (-item_img_width/2) then
                x = x + 720 + item_img_width 
            end
            if x > (720 + item_img_width/2) then
                x = x - (720 + item_img_width) 
            end
            self.item_list_res[i].item:setPositionX(x)
        end
    end
end

local local_right_pos = {
    {2,3,1},
    {1,2,3},
    {3,1,2},
}
local local_left_pos = {
    {2,3,1},
    {1,2,3},
    {3,1,2},
}
function NewPartnerSummonWindow:itemAction(is_move, dire)
    if is_move == false then return end

    local time = 0.2
    if dire >= 0 then
        self.cur_index = self.cur_index - 1
        if self.cur_index <= 0 then
            self.cur_index = 3
        end
        -- print("itemAction(::::: ",self.cur_index)
        for i=1,3 do
            if local_right_pos[self.cur_index][i] == 1 then
                local root_move_to = cc.MoveTo:create(0.05, cc.p(900, self.item_pos_y))
                local ease_out = cc.EaseSineOut:create(root_move_to)

                local fadeout = cc.FadeOut:create(0.01) --隐藏
                local root_move_to_1 = cc.MoveTo:create(0.01, cc.p(-200, self.item_pos_y))
                local spawn = cc.Sequence:create(fadeout,root_move_to_1)
                
                local fadein = cc.FadeIn:create(0.01) --显示
                local root_move_to_2 = cc.MoveTo:create(0.1, cc.p(0, self.item_pos_y))
                local ease_out_2 = cc.EaseSineOut:create(root_move_to_2)
                local spawn_2 = cc.Spawn:create(fadein,ease_out_2)
                self.item_list_res[i].item:runAction(cc.Sequence:create(ease_out,spawn,spawn_2))
            else
                local root_move_to = cc.MoveTo:create(time, cc.p(item_pos_x[local_right_pos[self.cur_index][i]], self.item_pos_y))
                local ease_out = cc.EaseSineOut:create(root_move_to)
                self.item_list_res[i].item:runAction(cc.Sequence:create(ease_out))
            end
        end
    else
        self.cur_index = self.cur_index + 1
        if self.cur_index > 3 then
            self.cur_index = 1
        end
        for i=1,3 do
            if local_left_pos[self.cur_index][i] == 3 then
                local root_move_to = cc.MoveTo:create(0.05, cc.p(-200, self.item_pos_y))
                local ease_out = cc.EaseSineOut:create(root_move_to)

                local fadeout = cc.FadeOut:create(0.01) --隐藏
                local root_move_to_1 = cc.MoveTo:create(0.01, cc.p(900, self.item_pos_y))
                local spawn = cc.Sequence:create(fadeout,root_move_to_1)
                
                local fadein = cc.FadeIn:create(0.01) --显示
                local root_move_to_2 = cc.MoveTo:create(0.1, cc.p(720, self.item_pos_y))
                local ease_out_2 = cc.EaseSineOut:create(root_move_to_2)
                local spawn_2 = cc.Spawn:create(fadein,ease_out_2)
                self.item_list_res[i].item:runAction(cc.Sequence:create(ease_out,spawn,spawn_2))
            else
                local root_move_to = cc.MoveTo:create(time, cc.p(item_pos_x[local_left_pos[self.cur_index][i]], self.item_pos_y))
                local ease_out = cc.EaseSineOut:create(root_move_to)
                self.item_list_res[i].item:runAction(cc.Sequence:create(ease_out))
            end
        end
    end
end

function NewPartnerSummonWindow:tabChangeIndex(index)
    if self.touch_index == index then return end
    self.touch_index = index

    self:showArenaPeakEffect(self.btn_summon_1, true)
    self:showArenaPeakEffect(self.btn_summon_10, true)

    if self.select_visible ~= nil then
        self.select_visible:setVisible(false)
    end
    self.select_visible = self.item_list_res[self.touch_index].kuang
    if self.select_visible then
        self.select_visible:setVisible(true)
    end
    self:heightSummonFiveStar()
    local num = PartnersummonController:getInstance():getModel():getFiveStarHeroIsOut()
    if num ~= 0 and index == 2 then
        self.advanced_bg:setVisible(true)
    else
        self.advanced_bg:setVisible(false)
    end

    local res_bg = PathTool.getPlistImgForDownLoad("newpartnersummon","newpartnersummon_bg"..index,true)
    self.background:loadTexture(res_bg, LOADTEXT_TYPE)
    self.background:setScale(display.getMaxScale())
    self.background:setOpacity(0)
    local fadein = cc.FadeIn:create(0.2)
    self.background:runAction(fadein)

    local res = PathTool.getPlistImgForDownLoad("newpartnersummon","partnersummon_role"..index)
    if not self.sprite_role_load[index] then
        self.sprite_role_load[index] = loadSpriteTextureFromCDN(self.sprite_role, res, LOADTEXT_TYPE, self.sprite_role_load[index])
    end
    if self.sprite_role_load[index] then
        loadSpriteTexture(self.sprite_role, res, LOADTEXT_TYPE)
        self:setRoleDispose(self.sprite_role, index)
        self.sprite_role:setOpacity(0)
        local fadein = cc.FadeIn:create(0.2)
        self.sprite_role:runAction(fadein)
    end
    loadSpriteTexture(self.summon_type_txt, PathTool.getResFrame("newpartnersummon", "txt_cn_newpartnersummon_" .. index), LOADTEXT_TYPE_PLIST)

    local group_id = recruit_list[index]
    --拥有的劵数
    --10
    self:setTenStatus(group_id)
    
    if not self.summon_assets then
        self.summon_assets = createRichLabel(24,1,cc.p(0,0.5),cc.p(5,622))
        self.main_container:addChild(self.summon_assets)
    end
    if self.summon_assets then
        local item_id_10 = base_info[group_id].item_five[1][1]
        local coupon_num = BackpackController:getInstance():getModel():getBackPackItemNumByBid(base_info[group_id].item_five[1][1])
        if index == NewPartnersummonConst.Partnersummon_Type.Friend then
            coupon_num = self.role_vo.friend_point
        end
        local item_config_1 = Config.ItemData.data_get_data(base_info[group_id].item_once[1][1])
        local res_1 = PathTool.getItemRes(item_config_1.icon)
        local str = string.format("<img src=%s visible=true scale=0.40 /><div fontcolor=#ffffff outline=2,#000000>  %s</div>",res_1, coupon_num)
        self.summon_assets:setString(str)
    end

    if self.first_come then
        self:itemData(index,group_id)
    end
end
--根据策划需要对里面的人物进行处理
function NewPartnerSummonWindow:setRoleDispose(node, index)
    if not node then return end
    --index  1:基础  2:高级  3:友情 
    --x轴坐标基准是360  y轴坐标基准是301
    --下移10  左移10   右移35
    if index == 1 then
        node:setScale(1)
        node:setPosition(360, 301 - 10)
    elseif index == 2 then
        node:setScale(1.04)
        node:setPosition(360 - 10, 301)
    elseif index == 3 then
        node:setScale(1)
        node:setPosition(360 + 35, 301)
    end
end
--免費時間
function NewPartnerSummonWindow:itemData(index,group_id)
    local item_data = model:getSummonItemData(group_id)
    if item_data then
        if self.redpoint[index] then
            self.redpoint[index]:setVisible(item_data.free_num == 1)
        end
        self.left_time = item_data.time_num - GameNet:getInstance():getTime()
        if item_data.free_num == 0 then --代表召唤过的
            if group_id ~= 200 then
                if self.left_time > 0 then
                    if not self.summon_timer[index] then
                        self.summon_timer[index] = GlobalTimeTicket:getInstance():add(function()
                            if item_data.time_num and (item_data.time_num - GameNet:getInstance():getTime()) > 0 then
                                self.left_time = item_data.time_num - GameNet:getInstance():getTime()
                                self.item_list_time[index]:setString(string.format(TI18N("<div  fontColor=#35ff14 outline=2,#000000 >%s</div><div fontColor=#ffffff outline=2,#000000>后免费</div>"), TimeTool.GetTimeFormat(self.left_time)))
                            else
                                self.item_list_time[index]:setString(string.format("<div fontColor=#ffffff outline=2,#000000>%s</div>", TI18N("免费抽取")))
                                local str = string.format("<div fontcolor=#ffffff outline=2,#000000> %s</div>",TI18N("免费召唤"))
                                self.summon_1_diammand:setString(str)
                                GlobalTimeTicket:getInstance():remove(self.summon_timer[index])
                                self.summon_timer[index] = nil
                            end
                        end, 1)
                    end
                else
                    self.item_list_time[index]:setString(string.format("<div fontColor=#ffffff outline=2,#000000>%s</div>", TI18N("免费抽取")))
                    local str = string.format("<div fontcolor=#ffffff outline=2,#000000> %s</div>",TI18N("免费召唤"))
                    self.summon_1_diammand:setString(str)
                    if self.summon_timer[index] ~= nil then
                        GlobalTimeTicket:getInstance():remove(self.summon_timer[index])
                        self.summon_timer[index] = nil
                    end
                end
            end
            self:setOnceStatus(group_id)
        else
            self.item_list_time[index]:setString(string.format("<div fontColor=#ffffff outline=2,#000000>%s</div>", TI18N("免费抽取")))
            local str = string.format("<div fontcolor=#ffffff outline=2,#000000> %s</div>",TI18N("免费召唤"))
            self.summon_1_diammand:setString(str)
        end
    end
end
--设置单抽按钮的状态
function NewPartnerSummonWindow:setOnceStatus(group_id)
    self.is_use_once_ext = false
    if group_id == 400 then return end
    local consume_item_ext
    if base_info[group_id].ext_item_once and base_info[group_id].ext_item_once[1] then
        consume_item_ext = base_info[group_id].ext_item_once[1]
    end
    local consume_item_ext_num = (consume_item_ext and consume_item_ext[1] and BackpackController:getInstance():getModel():getBackPackItemNumByBid(consume_item_ext[1])) or 0 --单抽拥有特殊道具数量
    self.use_once_item = base_info[group_id].item_once[1]
    if consume_item_ext and consume_item_ext[2] and consume_item_ext_num >= consume_item_ext[2] then
        self.use_once_item = consume_item_ext
        self.is_use_once_ext = true
    end
    local item_config_1 = Config.ItemData.data_get_data(self.use_once_item[1])
    local res_1 = PathTool.getItemRes(item_config_1.icon)
    local consume_1 = self.use_once_item[2]
    local coupon_num = BackpackController:getInstance():getModel():getBackPackItemNumByBid(self.use_once_item[1])
    if coupon_num < consume_1 then
        local once_data = base_info[group_id].exchange_once[1]
        if once_data then
            item_config_1 = Config.ItemData.data_get_data(once_data[1])
            res_1 = PathTool.getItemRes(item_config_1.icon)
            consume_1 = once_data[2]
        end
    end
    local str = string.format("<img src=%s visible=true scale=0.30 /><div fontcolor=#ffffff outline=2,#000000> %s</div>",res_1, consume_1)
    self.summon_1_diammand:setString(str)
end
--设置10连抽的按钮状态
function NewPartnerSummonWindow:setTenStatus(group_id)
    self.is_use_five_ext = false
    if group_id == 400 then return end
    local consume_item_ext
    if base_info[group_id].ext_item_five and base_info[group_id].ext_item_five[1] then
        consume_item_ext = base_info[group_id].ext_item_five[1]
    end
    local consume_item_ext_num = (consume_item_ext and consume_item_ext[1] and BackpackController:getInstance():getModel():getBackPackItemNumByBid(consume_item_ext[1])) or 0 --单抽拥有特殊道具数量
    self.use_five_item = base_info[group_id].item_five[1]
    if consume_item_ext and consume_item_ext[2] and consume_item_ext_num >= consume_item_ext[2] then
        self.use_five_item = consume_item_ext
        self.is_use_five_ext = true
    end

    local item_id_10 = self.use_five_item[1]
    local consume_10 = self.use_five_item[2]
    local coupon_num = BackpackController:getInstance():getModel():getBackPackItemNumByBid(item_id_10)
    local item_config_10 = Config.ItemData.data_get_data(item_id_10)
    local res_10 = PathTool.getItemRes(item_config_10.icon)
    if coupon_num < consume_10 then
        local ten_data = base_info[group_id].exchange_five[1]
        if ten_data then
            item_config_10 = Config.ItemData.data_get_data(ten_data[1])
            res_10 = PathTool.getItemRes(item_config_10.icon)
            consume_10 = ten_data[2]
        end
    end
    local str = string.format("<img src=%s visible=true scale=0.30 /><div fontcolor=#ffffff outline=2,#000000> %s</div>",res_10, consume_10)
    self.summon_10_diammand:setString(str)
end
--召唤的模式
function NewPartnerSummonWindow:ChooseSummonType(_type)
    self.is_use_ext = false
    if self.touch_summon then return end
    if self.touch_summon_ticket == nil then
        self.touch_summon_ticket = GlobalTimeTicket:getInstance():add(function()
            self.touch_summon = nil
            if self.touch_summon_ticket ~= nil then
                GlobalTimeTicket:getInstance():remove(self.touch_summon_ticket)
                self.touch_summon_ticket = nil
            end
        end,2)
    end
    self.touch_summon = true
    local max, count = HeroController:getInstance():getModel():getHeroMaxCount()
    if count >= max then
        local str = TI18N("英雄列表已满，可通过提升VIP等级或购买增加英雄携带数量，是否前往购买？")
        local call_back = function()
            MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.partner)
            controller:openNewPartnerSummonWindow(false)
        end
        CommonAlert.show(str, TI18N("前往"), call_back, TI18N("取消"), nil, CommonAlert.type.common)
        return
    end

    local data = base_info[recruit_list[self.touch_index]]
    if data then
        local summon_type = 4 --默认是道具
        if self.touch_index == NewPartnersummonConst.Partnersummon_Type.Normal then --普通召唤的时候
            local item_data = model:getSummonItemData(data.group_id)
            if item_data and item_data.free_num == 1 and _type == 1 then
                summon_type = 1
            end
        elseif self.touch_index == NewPartnersummonConst.Partnersummon_Type.Advanced then --高级召唤的时候
            local item_data = model:getSummonItemData(data.group_id)
            if item_data and item_data.free_num == 1 and _type == 1 then
                summon_type = 1
            else
                -- local item_id = base_info[data.group_id].item_five[1][1]
                -- local consume = base_info[data.group_id].item_five[1][2] --消耗
                local item_id = self.use_five_item[1]
                local consume = self.use_five_item[2] --消耗
                self.is_use_ext = false
                if self.is_use_five_ext then
                    self.is_use_ext = true
                end
                if _type == 1 then
                    -- item_id = base_info[data.group_id].item_once[1][1]
                    -- consume = base_info[data.group_id].item_once[1][2] --消耗
                    item_id = self.use_once_item[1]
                    consume = self.use_once_item[2] --消耗
                    self.is_use_ext = false
                    if self.is_use_once_ext then
                        self.is_use_ext = true
                    end
                end
                local coupon_num = BackpackController:getInstance():getModel():getBackPackItemNumByBid(item_id) --背包
                if coupon_num < consume then
                    local have_sum = self.role_vo.gold + self.role_vo.red_gold
                    local ten_data = base_info[data.group_id].exchange_once[1][2]
                    local call_num = base_info[data.group_id].draw_list[1] or 1
                    local val_num = base_info[data.group_id].exchange_once_gain[1][2]

                    local val_str = Config.ItemData.data_get_data(base_info[data.group_id].exchange_five_gain[1][1]).name or ""                    
                    if _type == 10 then
                        ten_data = base_info[data.group_id].exchange_five[1][2]
                        call_num = base_info[data.group_id].draw_list[2] or 10
                        val_num = base_info[data.group_id].exchange_five_gain[1][2]
                    end
                    local function call_back()
                        controller:send23201(data.group_id, _type, 3)    
                    end
                    local str = string.format("%s<img src=%s visible=true scale=0.3 /><div fontColor=#289b14 fontsize= 26>%s</div><div fontColor=#764519>(%s:</div><div fontColor=#289b14 fontsize= 26>%s</div><div fontColor=#764519>)\n</div>",TI18N("是否使用"),PathTool.getItemRes(3),ten_data,TI18N("拥有"),have_sum)
                    local str_ = str..string.format("<div fontColor=#764519>%s</div><div fontColor=#289b14 fontsize= 26>%s</div><div fontColor=#764519></div><div fontColor=#d95014 fontsize= 26>%s</div><div fontColor=#764519>(%s</div><div fontColor=#289b14 fontsize= 26>%s</div><div fontColor=#764519>%s)</div>",TI18N("购买"),val_num,val_str,TI18N("同时附赠"),call_num,TI18N("次招募"))
                    CommonAlert.show(str_, TI18N("确定"), call_back, TI18N("取消"), nil, CommonAlert.type.rich)
                    return
                end
            end
        elseif self.touch_index == NewPartnersummonConst.Partnersummon_Type.Friend then --友情召唤的时候
            summon_type = 4
        end
        -- print("data.group_id, _type,... ",self.touch_index,data.group_id, _type, summon_type)
        if self.is_use_ext then
            controller:send23201(data.group_id, _type, 5)
        else
            controller:send23201(data.group_id, _type, summon_type)
        end
    end
end

--10次以内召唤得5星英雄
function NewPartnerSummonWindow:heightSummonFiveStar()
    if self.touch_index ~= 2 then return end
    local num = PartnersummonController:getInstance():getModel():getFiveStarHeroIsOut()
    if num == 0 then
        if self.remain_star_num then
            self.remain_star_num:DeleteMe()
            self.remain_star_num = nil
        end
        if self.star_num then
            self.star_num:DeleteMe()
            self.star_num = nil
        end
        if self.five_star then
            self.five_star:setVisible(false)
        end
        -- if not self.special_label then
        --     self.special_label = createRichLabel(22, cc.c4b(0xff,0xff,0xff,0xff), cc.p(0.5, 0.5), cc.p(360, 600),nil,nil,600)
        --     self.main_container:addChild(self.special_label)
        -- end
        self.advanced_bg:setVisible(false)
        -- self.special_label:setString(TI18N("<div fontcolor=#ffffff fontsize=22 outline=2,#8f1c00>随机召唤1个或10个3~5星英雄</div>"))
    else
        self.advanced_bg:setVisible(true)
        if not self.remain_star_num then
            self.remain_star_num = CommonNum.new(31, self.advanced_bg, 1, 5, cc.p(0.5, 0.5))
            self.remain_star_num:setPosition(43, 36)
        end
        self.remain_star_num:setNum(num)

        if not self.star_num then
            self.star_num = CommonNum.new(31, self.advanced_bg, 1, 5, cc.p(0.5, 0.5))
            self.star_num:setPosition(228, 36)
        end
        self.star_num:setNum(5)
    end
end

function NewPartnerSummonWindow:close_callback()
    CommonAlert.closeAllWin()
    if self.touch_ticket ~= nil then
        GlobalTimeTicket:getInstance():remove(self.touch_ticket)
        self.touch_ticket = nil
    end
    for i,v in pairs(self.summon_timer) do
        if v ~= nil then
            GlobalTimeTicket:getInstance():remove(v)
            v = nil
        end
    end
    for i,v in pairs(self.sprite_role_load) do
        if v then
            v:DeleteMe()
            v = nil
        end
    end
    if self.role_vo ~= nil then
        if self.role_assets_event ~= nil then
            self.role_vo:UnBind(self.role_assets_event)
            self.role_assets_event = nil
        end
    end
    if self.box_effect then
        self.box_effect:clearTracks()
        self.box_effect:removeFromParent()
        self.box_effect = nil
    end
    if self.remain_star_num then
        self.remain_star_num:DeleteMe()
        self.remain_star_num = nil
    end
    if self.star_num then
        self.star_num:DeleteMe()
        self.star_num = nil
    end
    if self.touch_summon_ticket ~= nil then
        GlobalTimeTicket:getInstance():remove(self.touch_summon_ticket)
        self.touch_summon_ticket = nil
    end
    self:showArenaPeakEffect(self.btn_summon_1, false)
    self:showArenaPeakEffect(self.btn_summon_10, false)
    doStopAllActions(self.item_list_res[1].item)
    doStopAllActions(self.item_list_res[2].item)
    doStopAllActions(self.item_list_res[3].item)
    controller:openNewPartnerSummonWindow(false)
end