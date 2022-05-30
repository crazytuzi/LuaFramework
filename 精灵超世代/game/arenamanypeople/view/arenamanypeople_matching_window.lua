--------------------------------------------
-- @Author  : xhj
-- @Date    : 2020年3月23日
-- @description    : 
        -- 多人竞技场匹配界面
---------------------------------
local controller = ArenaManyPeopleController:getInstance()
local model = controller:getModel()
local string_format = string.format
local table_sort = table.sort

ArenaManyPeopleMatchingWindow = ArenaManyPeopleMatchingWindow or BaseClass(BaseView)

function ArenaManyPeopleMatchingWindow:__init( )
    self.win_type = WinType.Big
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.is_full_screen = false

    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("arenampmatch","arenampmatch_bg"), type = ResourcesType.single },
        {path = PathTool.getPlistImgForDownLoad("arenampmatch", "arenampmatch"), type = ResourcesType.plist},
    }
    self.layout_name = "arenamanypeople/amp_matching_window"
    

    --标志已经匹配到敌人了
    self.is_match = false

    --标志在匹配中了
    self.is_matching = false

    self.left_panel_list = {}
    self.right_panel_list = {}
    self.role_vo = RoleController:getInstance():getRoleVo()
    
end

function ArenaManyPeopleMatchingWindow:open_callback(  )
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    self.container = self.root_wnd:getChildByName("main_container")

    self.left_btn = self.container:getChildByName("left_btn")
    self.left_btn:getChildByName("label"):setString(TI18N("重新匹配"))
    self.left_tips = createRichLabel(22, cc.c4b(0xff,0xee,0xac,0xff), cc.p(0.5,0.5), cc.p(80,-20), nil, nil, 600)
    self.left_btn:addChild(self.left_tips)

    self.right_btn = self.container:getChildByName("right_btn")
    self.right_btn:getChildByName("label"):setString(TI18N("确 定"))

    self.tips_lab = self.container:getChildByName("tips_lab")
    self.tips_lab:setString(TI18N("匹配中"))

    self.effect_panel = self.container:getChildByName("effect_panel")
    self.vs_img = self.container:getChildByName("vs_img")
    self.vs_img:setVisible(false)

    self.big_bg = self.container:getChildByName("big_bg")
    self.big_bg:setVisible(true)
    loadSpriteTexture(self.big_bg, PathTool.getPlistImgForDownLoad("arenampmatch","arenampmatch_bg"), LOADTEXT_TYPE)
    
    
    self.step_time = createRichLabel(22, cc.c4b(0xff,0xee,0xac,0xff), cc.p(0.5,0.5), cc.p(360,223), nil, nil, 600)
    self.container:addChild(self.step_time)
    
    local _getItem = function(prefix,is_touch,i)
        local item = {}
        item.fight_panel = self.container:getChildByName(prefix)
        item.fight_panel:setVisible(false)
        item.role_name = item.fight_panel:getChildByName("role_name")
        item.score_num = item.fight_panel:getChildByName("score_num")
        item.power_num = item.fight_panel:getChildByName("power_num")
        item.lev_icon = item.fight_panel:getChildByName("lev_icon")

        local head_icon = PlayerHead.new(PlayerHead.type.circle)
        head_icon:setHeadLayerScale(0.90)
        head_icon:setPosition(125 , 65)
        item.fight_panel:addChild(head_icon)
        item.head_icon = head_icon
        if is_touch and is_touch == true then
            head_icon:addCallBack(function() self:onClickHead(i) end )
        end
        return item
    end

    for i=1,3 do
        self.left_panel_list[i] = _getItem("left_"..i,true,i)
        self.right_panel_list[i] = _getItem("right_"..i,false,i)
    end

end

function ArenaManyPeopleMatchingWindow:register_event(  )
    registerButtonEventListener(self.left_btn, function (  )
        self:onLeftBtn()
    end, true)

    registerButtonEventListener(self.right_btn, function (  ) self:onRightBtn() end, true)

    -- -- 我的进攻阵容数据
    self:addGlobalEvent(ArenaManyPeopleEvent.ARENAMANYPOEPLE_MATCH_OTHER_EVENT, function ( scdata )
        if scdata  then
            self:setData(false)
        end
    end)

end

function ArenaManyPeopleMatchingWindow:onLeftBtn()
    if not self.data then return end

    if self.is_matching then
        message(TI18N("匹配中..."))
        return 
    end
    
    local team_refresh_num = Config.HolidayArenaTeamData.data_const.team_refresh_num
    if team_refresh_num and team_refresh_num.val < self.data.ref_count+1 then
        message(TI18N("已达到今日刷新次数上限"))
        return
    end

    --在匹配中
    self.right_btn:setVisible(false)
    self.left_btn:setVisible(false)
    -- self.big_bg:setVisible(false)
    self.vs_img:setVisible(false)
    self:playMatchEffect(true)
    self:playMatchEffect2(false)
    self.is_matching = true
    self.is_data_back = false
    self.is_time_out = false
    self:setBtnTime()
    self.step_time:stopAllActions()
    self.step_time:setString("")

    for i,v in ipairs(self.left_panel_list) do
        if v and v.fight_panel then
            v.fight_panel:setVisible(false)
        end
    end
    for i,v in ipairs(self.right_panel_list) do
        if v and v.fight_panel then
            v.fight_panel:setVisible(false)
        end
    end
    
    controller:sender29017()

    delayRun(self.container, 2, function() 
        self.is_time_out = true
        self:setDataByCondition()
    end)
end

function ArenaManyPeopleMatchingWindow:onRightBtn()
    controller:sender29018()
    controller:openArenaManyPeopleMatchingWindow(false)
    controller:openArenaManyPeopleFightTips(true)
end


function ArenaManyPeopleMatchingWindow:onClickHead(i)
    local head_list = self.left_panel_list
    
    if head_list and head_list[i] and head_list[i].head_icon:getData() then
        local data = head_list[i].head_icon:getData()
        if self.role_vo and data.rid == self.role_vo.rid and data.sid == self.role_vo.srv_id then 
            message(TI18N("这是你自己~"))
            return
        end
        FriendController:getInstance():openFriendCheckPanel(true, {srv_id = data.sid, rid = data.rid})
    end
end

function ArenaManyPeopleMatchingWindow:openRootWnd( )
    self.is_time_out = false
    self.is_matching = false
    self:setData(true)
end

function ArenaManyPeopleMatchingWindow:setData(is_first)
    local data = model:getMatchInfo()
    if not data then return end
    self.data = data
    
    if is_first == true then
        --在匹配中
        self.right_btn:setVisible(false)
        self.left_btn:setVisible(false)
        -- self.big_bg:setVisible(false)
        self.vs_img:setVisible(false)
        self:playMatchEffect(true)
        self:playMatchEffect2(false)
        self.is_matching = true
        self.is_data_back = false
        self.step_time:stopAllActions()
        self.step_time:setString("")
        self:setBtnTime()

        for i,v in ipairs(self.left_panel_list) do
            if v and v.fight_panel then
                v.fight_panel:setVisible(false)
            end
        end
        for i,v in ipairs(self.right_panel_list) do
            if v and v.fight_panel then
                v.fight_panel:setVisible(false)
            end
        end

        delayRun(self.container, 2, function() 
            self.is_time_out = true
            self:setDataByCondition()
        end)
    end
    
    if #self.data.atk_team_members > 0 and #self.data.def_team_members > 0 then
        --已有匹配对手
        self.is_data_back = true
        self:setDataByCondition()
    end
end


function ArenaManyPeopleMatchingWindow:setDataByCondition()
    if self.is_time_out and self.is_data_back then
        self.tips_lab:stopAllActions()
        self.tips_lab:setString("")

        self.is_match = true
        
        self:playMatchEffect(false)
        self:playMatchEffect2(true)
     
        self:updateLeftInfo()
        self:updateRightInfo()
        self:actionVs()
        
        self.is_matching = false

        if self.data then
            local time = self.data.end_time - GameNet:getInstance():getTime()
            if time < 0 then
                time = 0 
            end
            self:setStepTime(time)
        end
    end
end

function ArenaManyPeopleMatchingWindow:updateLeftInfo()
    if self.data then
        local atk_team_members = self.data.atk_team_members
        table_sort(atk_team_members, SortTools.KeyUpperSorter("is_leader"))
        for i,v in ipairs(atk_team_members) do
            if self.left_panel_list[i] then
                local item = self.left_panel_list[i]
                item.role_name:setString(v.name)
                item.score_num:setString(string_format(TI18N("积分：%d"),v.score))
                item.power_num:setString(tostring(v.power))
                
                local res = PathTool.getPlistImgForDownLoad("arenampmatch/arenampmatch_icon", "amp_icon_"..v.score_lev)
                item.item_load = loadSpriteTextureFromCDN(item.lev_icon, res, ResourcesType.single, item.item_load)
                if item.head_icon then
                    item.head_icon:setHeadData(v)
                    item.head_icon:setHeadRes(v.face_id, false, LOADTEXT_TYPE, v.face_file, v.face_update_time)
                    item.head_icon:setLev(v.lev)
                    
                    if v.is_leader == 1 then
                        item.head_icon:showLeader(true)    
                    else
                        item.head_icon:showLeader(false)
                    end

                    local avatar_bid = v.avatar_bid
                    if item.head_icon.record_res_bid == nil or item.head_icon.record_res_bid ~= avatar_bid then
                        item.head_icon.record_res_bid = avatar_bid
                        local vo = Config.AvatarData.data_avatar[avatar_bid]
                        --背景框
                        if vo then
                            local res_id = vo.res_id or 1
                            local res = PathTool.getTargetRes("headcircle", "txt_cn_headcircle_" .. res_id, false, false)
                            item.head_icon:showBg(res, nil, false, vo.offy)
                        else
                            local bgRes = PathTool.getResFrame("common","common_1031")
                            item.head_icon:showBg(bgRes, nil, true)
                        end
                    end
                end
                doStopAllActions(item.fight_panel)
                delayOnce(function()
                    local temp_x = 86
                    if item and item.fight_panel and not tolua.isnull(item.fight_panel) then
                        item.fight_panel:setPositionX(temp_x-(i-1)*68)
                        local pos_x, pos_y = item.fight_panel:getPosition()
                        item.fight_panel:setPosition(pos_x-580, pos_y)
                        local act_move = cc.MoveBy:create(0.2,cc.p(580, 0))
                        item.fight_panel:setVisible(true)
                        item.fight_panel:runAction(cc.EaseBackOut:create(act_move))
                    end
                    
                    if i == 1 and self.vs_img and not tolua.isnull(self.vs_img) then
                        self.vs_img:setVisible(true)
                    end
                end,(3-i)*0.2)
            end
        end
    end
end

function ArenaManyPeopleMatchingWindow:updateRightInfo()
    if self.data then
        local def_team_members = self.data.def_team_members
        table_sort(def_team_members, SortTools.KeyUpperSorter("is_leader"))
        local index = model:getHideIndex()
        for i,v in ipairs(def_team_members) do
            if self.right_panel_list[i] then
                local item = self.right_panel_list[i]
                item.role_name:setString(v.name)
                item.score_num:setString(string_format(TI18N("积分：%d"),v.score))
                
                if index and i==index then
                    item.power_num:setString("?")
                else
                    item.power_num:setString(tostring(v.power))
                end
                
                local res = PathTool.getPlistImgForDownLoad("arenampmatch/arenampmatch_icon", "amp_icon_"..v.score_lev)
                item.item_load = loadSpriteTextureFromCDN(item.lev_icon, res, ResourcesType.single, item.item_load)

                if item.head_icon then
                    item.head_icon:setHeadRes(v.face_id, false, LOADTEXT_TYPE, v.face_file, v.face_update_time)
                    item.head_icon:setLev(v.lev)
                    
                    if v.is_leader == 1 then
                        item.head_icon:showLeader(true)    
                    else
                        item.head_icon:showLeader(false)
                    end

                    local avatar_bid = v.avatar_bid
                    if item.head_icon.record_res_bid == nil or item.head_icon.record_res_bid ~= avatar_bid then
                        item.head_icon.record_res_bid = avatar_bid
                        local vo = Config.AvatarData.data_avatar[avatar_bid]
                        --背景框
                        if vo then
                            local res_id = vo.res_id or 1
                            local res = PathTool.getTargetRes("headcircle", "txt_cn_headcircle_" .. res_id, false, false)
                            item.head_icon:showBg(res, nil, false, vo.offy)
                        else
                            local bgRes = PathTool.getResFrame("common","common_1031")
                            item.head_icon:showBg(bgRes, nil, true)
                        end
                    end
                end
                doStopAllActions(item.fight_panel)
                delayOnce(function()
                    local temp_x = 253
                    if item and item.fight_panel and not tolua.isnull(item.fight_panel) then
                        item.fight_panel:setPositionX(temp_x-(i-1)*68)
                        local pos_x, pos_y = item.fight_panel:getPosition()
                        item.fight_panel:setPosition(pos_x+580, pos_y)
                        local act_move = cc.MoveBy:create(0.2,cc.p(-580, 0))
                        item.fight_panel:setVisible(true)
                        item.fight_panel:runAction(cc.EaseBackOut:create(act_move))
                    end
                end,(i-1)*0.2)
            end
        end
    end
end

function ArenaManyPeopleMatchingWindow:actionVs()
    doStopAllActions(self.vs_img)
    delayOnce(function()
        -- self.vs_img:setScale(5)
        -- local act_move = cc.EaseBackOut:create(cc.ScaleTo:create(0.25,1))
        -- self.vs_img:runAction(act_move)

        local team_refresh_num = Config.HolidayArenaTeamData.data_const.team_refresh_num
        if team_refresh_num and self.data and  team_refresh_num.val >= self.data.ref_count+1 then
            if self.left_tips and not tolua.isnull(self.left_tips) then
                self.left_tips:setString(string_format(TI18N("剩余刷新次数：%d"),team_refresh_num.val-self.data.ref_count))
            end
            if self.left_btn and not tolua.isnull(self.left_btn) then
                self.left_btn:setVisible(true)
            end
            if self.right_btn and not tolua.isnull(self.right_btn) then
                self.right_btn:setPositionX(540)
                self.right_btn:setVisible(true)
            end
        else
            if self.right_btn and not tolua.isnull(self.right_btn) then
                self.right_btn:setPositionX(360)
                self.right_btn:setVisible(true)
            end
            if self.left_btn and not tolua.isnull(self.left_btn) then
                self.left_btn:setVisible(false)
            end
        end
    end,0.6)
end

--设置倒计时
function ArenaManyPeopleMatchingWindow:setStepTime(less_time)
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
                    self.step_time:setString("")
                else
                    self:setStepTimeFormatString(less_time)
                end
            end))))
    else
        self:setStepTimeFormatString(less_time)
    end
end

function ArenaManyPeopleMatchingWindow:setStepTimeFormatString(time)
    local str = string.format(TI18N("<div fontcolor=#75ec51 >%s</div>秒后自动进入战斗"), time)
    self.step_time:setString(str)
end


--设置倒计时
function ArenaManyPeopleMatchingWindow:setBtnTime()
    if tolua.isnull(self.tips_lab) then
        return 
    end
    self.tips_lab:stopAllActions()
    local btn_time = 1
    self:setBtnTimeFormatString(btn_time)
    self.tips_lab:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(0.5),
    cc.CallFunc:create(function()
            btn_time = btn_time + 1
            if btn_time > 4 then
                btn_time = 1
            end
            self:setBtnTimeFormatString(btn_time)
    end))))
   
end

function ArenaManyPeopleMatchingWindow:setBtnTimeFormatString(time)
    if time == 1 then
        self.tips_lab:setString(TI18N("匹配中."))
    elseif time == 2 then
        self.tips_lab:setString(TI18N("匹配中.."))
    elseif time == 3 then
        self.tips_lab:setString(TI18N("匹配中..."))
    else
        self.tips_lab:setString(TI18N("匹配中"))
    end

end

-- 背景特效
function ArenaManyPeopleMatchingWindow:playMatchEffect(status)
    if status == true then
        if not tolua.isnull(self.effect_panel) and self.bg_effect == nil then
            self.bg_effect = createEffectSpine(Config.EffectData.data_effect_info[1771], cc.p(self.effect_panel:getContentSize().width / 2, self.effect_panel:getContentSize().height / 2), cc.p(0.5, 0.5), true, PlayerAction.action)
            self.effect_panel:addChild(self.bg_effect)
        end
    else
        if self.bg_effect then
            self.bg_effect:clearTracks()
            self.bg_effect:removeFromParent()
            self.bg_effect = nil
        end
    end
end


-- 背景特效2
function ArenaManyPeopleMatchingWindow:playMatchEffect2(status)
    if status == true then
        if not tolua.isnull(self.effect_panel) and self.bg_effect_2 == nil then
            self.bg_effect_2 = createEffectSpine(Config.EffectData.data_effect_info[1772], cc.p(self.effect_panel:getContentSize().width / 2, self.effect_panel:getContentSize().height / 2), cc.p(0.5, 0.5), false, PlayerAction.action,function() 
                -- if self.big_bg then
                --     self.big_bg:setVisible(true)
                -- end
            end)
            self.effect_panel:addChild(self.bg_effect_2)
        end
    else
        if self.bg_effect_2 then
            self.bg_effect_2:clearTracks()
            self.bg_effect_2:removeFromParent()
            self.bg_effect_2 = nil
        end
    end
end

function ArenaManyPeopleMatchingWindow:close_callback(  )
    for i,v in ipairs(self.left_panel_list) do
        if v and v.head_icon then
            v.head_icon:DeleteMe()
            v.head_icon = nil
        end
        
        if v.fight_panel then
            doStopAllActions(v.fight_panel)
        end

        if v.item_load then
            v.item_load:DeleteMe()
            v.item_load = nil
        end
    end
    
    for i,v in ipairs(self.right_panel_list) do
        if v and v.head_icon then
            v.head_icon:DeleteMe()
            v.head_icon = nil
        end
        
        if v.fight_panel then
            doStopAllActions(v.fight_panel)
        end

        if v.item_load then
            v.item_load:DeleteMe()
            v.item_load = nil
        end
    end
    
    doStopAllActions(self.tips_lab)
    doStopAllActions(self.step_time)
    doStopAllActions(self.vs_img)
    

    self:playMatchEffect(false)
    self:playMatchEffect2(false)
    

    controller:openArenaManyPeopleMatchingWindow(false)
end