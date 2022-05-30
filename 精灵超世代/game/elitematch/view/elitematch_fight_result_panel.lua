-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      精英赛战斗结果界面
-- <br/>Create: 2019年4月3日
-- --------------------------------------------------------------------
ElitematchFightResultPanel = ElitematchFightResultPanel or BaseClass(BaseView)

local controller = ElitematchController:getInstance()
local model = controller:getModel()
local table_insert = table.insert
local string_format = string.format

function ElitematchFightResultPanel:__init()
    self.win_type = WinType.Big
    self.layout_name = "elitematch/elitematch_fight_result_panel"
    self.view_tag = ViewMgrTag.DIALOGUE_TAG

    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("elitematch","elitematch"), type = ResourcesType.plist },
    }
end

function ElitematchFightResultPanel:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    self.container = self.root_wnd:getChildByName("container")
    self.Sprite_1 = self.container:getChildByName("Sprite_1")


    self.title_container = self.container:getChildByName("title_container")
    local size = self.title_container:getContentSize()
    self.title_width = size.width
    self.title_height = size.height
    
    self.harm_btn = self.container:getChildByName("harm_btn")
    self.harm_btn:getChildByName("harm_lab"):setString(TI18N("数据统计"))
    self.common_90044_0 = self.container:getChildByName("common_90044_0")
    self.level_icon = self.container:getChildByName("level_icon")
    self.node = self.container:getChildByName("node")
    self.level_name = self.container:getChildByName("level_name")
    self.score_key_0 = self.container:getChildByName("score_key_0")
    self.score_key_0:setString(TI18N("获取物品"))
    self.item_scrollview = self.container:getChildByName("item_scrollview")
    self.item_scrollview:setScrollBarEnabled(false)
    -- self.item_scrollview:setSwallowTouches(false)


    self.fight_text = createRichLabel(24, Config.ColorData.data_new_color4[6], cc.p(0.5, 0.5), cc.p(360, 550),nil,nil,1000)
    self.container:addChild(self.fight_text)

    self.comfirm_btn = createButton(self.container,TI18N("确定"), 620, 580, cc.size(162, 62), PathTool.getResFrame("common", "common_1017"), 24, Config.ColorData.data_color4[1])
    self.comfirm_btn:setPosition(self.container:getContentSize().width / 2 - 170, -50)
    --self.comfirm_btn:enableOutline(Config.ColorData.data_color4[264], 2)
    self.comfirm_btn:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            self:onClickBtnClose()
        end
    end)

    self.cancel_btn = createButton(self.container,TI18N("返回玩法"), 620, 580, cc.size(162, 62), PathTool.getResFrame("common", "common_1018"), 24, Config.ColorData.data_color4[1])
    self.cancel_btn:setPosition(self.container:getContentSize().width / 2 + 170, -50)
    --self.cancel_btn:enableOutline(Config.ColorData.data_color4[263], 2)
    self.cancel_btn:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            if not self.scdata then return end
            BattleResultReturnMgr:returnByFightType(self.scdata.combat_type) --先
            self:onClickBtnClose()
        end
    end)

end

function ElitematchFightResultPanel:register_event()
    registerButtonEventListener(self.background, handler(self, self.onClickBtnClose) ,false, 1)
    registerButtonEventListener(self.harm_btn, handler(self, self.onClickHarmBtn) ,false, 1)
end

function ElitematchFightResultPanel:onClickHarmBtn(  )
    if self.scdata and self.scdata.all_hurt_statistics then
        table.sort( self.scdata.all_hurt_statistics, function(a, b) return a.type < b.type end)
        local role_vo = RoleController:getInstance():getRoleVo()
        local atk_name = role_vo.name
        local target_role_name = self.scdata.target_role_name
        for i,v in ipairs(self.scdata.all_hurt_statistics) do
            if self.scdata.combat_type == BattleConst.Fight_Type.EliteKingMatchWar then
                v.atk_name  = string_format("%s(" .. TI18N("队伍").."%s)",atk_name, v.a_round)
                v.target_role_name  = string_format("%s("..TI18N("队伍").."%s)",target_role_name, v.b_round)
            else
                v.atk_name  = atk_name
                v.target_role_name  = target_role_name
            end
        end
        local setting = {}
        setting.fight_type = self.scdata.combat_type
        BattleController:getInstance():openBattleHarmInfoView(true, self.scdata.all_hurt_statistics, setting)
    end
end

--关闭
function ElitematchFightResultPanel:onClickBtnClose()
    controller:openElitematchFightResultPanel(false)
end

function ElitematchFightResultPanel:openRootWnd(scdata)
    -- local scdata = {}
    -- scdata.add_score = -50
    -- scdata.all_hurt_statistics = {}
    -- scdata.awards = {}
    -- scdata.big_score = 1108
    -- scdata.combat_type = 23
    -- scdata.elite_lev = 3
    -- scdata.end_score = -1
    -- scdata.lose_count = 1
    -- scdata.new_elite_lev = 2
    -- scdata.promoted_info = {}
    -- scdata.result = 2
    -- scdata.score = 18
    -- scdata.win_count = 0
    BattleResultMgr:getInstance():setWaitShowPanel(true)
    if not scdata then return end
    self.scdata = scdata
    if scdata.result == 1 then 
        playOtherSound("b_win", AudioManager.AUDIO_TYPE.BATTLE) 
    else
        --失败音乐
        -- playOtherSound("c_get")
    end
    
    self:handleEffect(true, scdata.result)
    self:setData(scdata)

    if self.fight_text then
        local name = Config.BattleBgData.data_fight_name[self.scdata.combat_type]
        if name then
            local str = string.format(TI18N("当前战斗：").."<div fontcolor = #0e7709>%s</div>",name)
            self.fight_text:setString(str)
        end
    end

    --申请网络刷新一下必要的界面.
    controller:sender24900()
end

function ElitematchFightResultPanel:setData(scdata)
    local config = Config.ArenaEliteData.data_elite_level[self.scdata.elite_lev]
    if config then
        self.level_name:setString(config.name)
        self:playLevelSpine(true, config)
    end

    --奖励
    local data_list = {}
    for i,v in ipairs(self.scdata.awards) do
        table_insert(data_list, {v.item_id, v.item_num})
    end
    local setting = {}
    setting.scale = 0.7
    setting.max_count = 4
    setting.is_center = true
    self.item_list = commonShowSingleRowItemList(self.item_scrollview, self.item_list, data_list, setting)


    local show_list = {}


    local left_count = self.scdata.big_score + self.scdata.add_score
    local left_count_2 = self.scdata.score + self.scdata.add_score

    local list = {key = TI18N("精英积分:"), left_value = left_count, right_value = self.scdata.add_score}
    table_insert(show_list, list)
    
    local list2 = {key = TI18N("段位经验:"), left_value = self.scdata.end_score, right_value = self.scdata.add_score}
    table_insert(show_list, list2)    

    --王者赛
    if self.scdata.combat_type == BattleConst.Fight_Type.EliteKingMatchWar then
        local str1 = string_format("%s: %s:%s",TI18N("总比分"), self.scdata.win_count, self.scdata.lose_count)
        table_insert(show_list, {score = str1})
    end

    --常规赛
    if #self.scdata.promoted_info > 0 then
        --晋级赛
        table_insert(show_list, {node = self.node})
        local max_count = config.promoted_info[1] or 1
        self:showLevelUpUI(true, max_count)
        local win_count = 0
        for i,v in ipairs(self.scdata.promoted_info) do
            if v.flag == 1 then
                win_count = win_count + 1
            end
        end
        local need_win_count = config.promoted_info[2] or 1
        if scdata.result == 0 or win_count < need_win_count then
            if show_list[1] then
                show_list[1].not_change = true
                show_list[2].not_change = true
            end
        end
    else
        --平常赛
        table_insert(show_list, {node = self.node, need_chang = true})

        local score = (self.scdata.score + self.scdata.add_score)
        --写进度条 还没写
        local per_data = {}

        local percent, str, blue_percent
        local total_exp = config.init_exp + config.need_exp
        if score >= 0 then
            percent, blue_percent, str  = self:getPercent(config, score)
            if score > config.need_exp then
                show_list[2].left_value = config.need_exp
                show_list[2].right_value = config.need_exp - self.scdata.score
                if config.next_id == 0 then
                    if self.scdata.score >= config.need_exp then
                        show_list[2].right_value = 0
                    end
                end
            end 
        else
            if self.scdata.elite_lev > self.scdata.new_elite_lev then
                --说明降级了--> 
                local new_config = Config.ArenaEliteData.data_elite_level[self.scdata.new_elite_lev]
                if new_config then
                    percent, blue_percent, str  = self:getPercent(new_config, self.scdata.end_score)
                end
            else
                percent, blue_percent, str  = self:getPercent(config, score)
            end
        end
        self.end_percent = percent
        self.end_blue_percent = blue_percent
        self.end_str = str
        self:showProgressbarEffect(config)
    end
   
    self:initShowList(show_list)
end

function ElitematchFightResultPanel:getPercent(config,  score)
    local percent, blue_percent, str
    local total_exp = config.init_exp + config.need_exp
    if score >= 0 then
        percent = (score + config.init_exp)*100/total_exp
        blue_percent = config.init_exp*100/total_exp
        if score > config.need_exp then
            score = config.need_exp
        end 
        str = string_format("%s/%s", score, config.need_exp)
    else
        percent = 0
        local count = config.init_exp + score
        blue_percent = count*100/total_exp
        str = count
    end
    return percent, blue_percent, str
end

function ElitematchFightResultPanel:showProgressbarEffect(config)
    -- local temp_score = (config.init_exp + config.need_exp)/100
    -- if temp_score < 1 then
     local temp_score = 1
    -- end
    if self.scdata.result ~= 1 then
        temp_score = -temp_score
    end
    local chang_score = 0
    local config = config
    local cur_score = self.scdata.score
    local call_back = function()
        cur_score = cur_score + temp_score
        chang_score = chang_score + temp_score
        local percent, blue_percent, str  = self:getPercent(config, cur_score)
        if math.abs(chang_score) >= math.abs(self.scdata.add_score) then
            --变化分超过了就结束了
            percent = self.end_percent
            str = self.end_str
            blue_percent = self.end_blue_percent
            GlobalTimeTicket:getInstance():remove("elitematch_fight_result_timer")
        end
        if blue_percent <= 0 then
            --说明蓝条也没了 
            if self.scdata.elite_lev > self.scdata.new_elite_lev then
                --掉级
                config = Config.ArenaEliteData.data_elite_level[self.scdata.new_elite_lev]
                if config then
                    cur_score = config.need_exp
                    percent, blue_percent, str = self:getPercent(config, cur_score)
                else
                    percent = 0 
                    str = 0
                    blue_percent = 0
                    GlobalTimeTicket:getInstance():remove("elitematch_fight_result_timer")
                end
            end
        end
        self:showProgressbar(true, percent, blue_percent, str)
    end
    GlobalTimeTicket:getInstance():add(call_back, 0.02, 0, "elitematch_fight_result_timer")
    -- call_back()
end

function ElitematchFightResultPanel:initShowList(show_list)
    if not show_list then return end
    local total_height = 130
    local start_y = 226
    local middle_x = 360

    local count = #show_list
    local item_width = total_height/count
    for i=1,count do
        local data = show_list[i]
        local y = start_y + (i - 1) * item_width + item_width *0.5
        if data.node ~= nil then
            data.node:setPositionY(y)
                --local size = self.common_90044_0:getContentSize()
            --if data.need_chang then
            --    self.common_90044_0:setContentSize(cc.size(size.width, total_height + 10))
            --else
            --    self.common_90044_0:setContentSize(cc.size(size.width, (count - 1) * item_width ))
            --end
        elseif data.score ~= nil then
            --显示比分的 FFEEAC
            createLabel(22, Config.ColorData.data_new_color4[6], nil, middle_x, y, data.score, self.container, 2, cc.p(0.5, 0.5))
        else --{key = "精英积分:", left_value = left_count, right_value = self.scdata.add_score, not_change = true}
            local str = string_format("%s %s", data.key, data.left_value)
            createLabel(22, Config.ColorData.data_new_color4[6], nil, 230, y, str, self.container, 2, cc.p(0, 0.5))
            local res , score
            if data.right_value >= 0 then
                res = PathTool.getResFrame("common", "common_1086")
            else
                res = PathTool.getResFrame("common", "common_1087")
            end
            score = math.abs(data.right_value)
            if data.not_change then
                createLabel(22, Config.ColorData.data_new_color4[12], nil, 496, y, TI18N("不变"), self.container, 2, cc.p(0, 0.5))
            else
                createSprite(res, 482, y, self.container, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST, 0)    
                createLabel(22, Config.ColorData.data_new_color4[12], nil, 496, y, tostring(score), self.container, 2, cc.p(0, 0.5))
            end
        end
    end
end


function ElitematchFightResultPanel:showProgressbar(status, percent, blue_percent, label)
    if not self.node then return end
    if status then
        local size = cc.size(220, 18)
        if not self.comp_bar then
            -- local res = PathTool.getResFrame("common","elitematch_18")
            -- local res1 = PathTool.getResFrame("common","elitematch_19")
            -- local res2 = PathTool.getResFrame("common","elitematch_21")
            local res = PathTool.getResFrame("elitematch","elitematch_bar_bg")
            local res1 = PathTool.getResFrame("elitematch","elitematch_bar")
            local res2 = PathTool.getResFrame("elitematch","elitematch_bar_1")
            self.camp_bar_record_res = res1
            local bg,comp_bar = createLoadingBar(res, res1, size, self.node, cc.p(0.5,0.5), 0, 0, true, true)
            self.comp_bar_bg = bg
            self.comp_bar = comp_bar

            --蓝色进度条
            local progress = ccui.LoadingBar:create()
            progress:setAnchorPoint(cc.p(0.5, 0.5))
            --progress:setScale9Enabled(true)
            progress:setCascadeOpacityEnabled(true)
            progress:loadTexture(res2,LOADTEXT_TYPE_PLIST)
            --progress:setContentSize(cc.size(size.width-4, size.height-4))
            progress:setPosition(cc.p(size.width/2, size.height/2))
            bg:addChild(progress)
            self.comp_bar_blue = progress
        end
        if not self.comp_bar_label then
            local text_color = cc.c3b(255,255,255)
            local line_color = cc.c3b(0,0,0)
            self.comp_bar_label = createLabel(16, text_color, line_color, 0, 0, "", self.node, 2, cc.p(0.5, 0.5))
        end

        self.comp_bar_bg:setVisible(true)

        self.comp_bar:setPercent(percent)    
        self.comp_bar_blue:setPercent(blue_percent)
        self.comp_bar_label:setString(label)
    else
        if self.comp_bar_bg then
            self.comp_bar_bg:setVisible(false)
        end
    end
end

function ElitematchFightResultPanel:showLevelUpUI(status, max_count)
    if self.level_up_item_list then
        for i,item in ipairs(self.level_up_item_list) do
            item:setVisible(false)
        end
    end
    if status then
        if self.level_up_item_list == nil then
            self.level_up_item_list = {}
        end
        local item_width = 50 
        local x = -item_width * max_count * 0.5 + item_width * 0.5
        local dic_data = {}
        for i,v in ipairs(self.scdata.promoted_info) do
            dic_data[v.count] = v.flag
        end
        for i=1,max_count do
            local _x = x + (i - 1) * item_width
            if self.level_up_item_list[i] == nil then
                self.level_up_item_list[i] = self:createLevelUpItem( _x, 0)
            else
                self.level_up_item_list[i]:setPositionX(_x)
            end
            if dic_data[i] == nil or dic_data[i] == 0 then
               self.level_up_item_list[i].icon:setVisible(false)
               self.level_up_item_list[i].mask_icon:setVisible(false)
            else
                self.level_up_item_list[i].icon:setVisible(true)
                self.level_up_item_list[i].mask_icon:setVisible(true)
                if dic_data[i] == 1 then
                    --胜利
                    setChildUnEnabled(false, self.level_up_item_list[i].icon)
                    local res2 = PathTool.getTargetRes("elitematch", "txt_cn_elitematch_15",false)
                    loadSpriteTexture(self.level_up_item_list[i].mask_icon, res2, LOADTEXT_TYPE)
                else
                    --失败
                    setChildUnEnabled(true, self.level_up_item_list[i].icon)
                    local res2 = PathTool.getTargetRes("elitematch", "txt_cn_elitematch_16",false)
                    loadSpriteTexture(self.level_up_item_list[i].mask_icon, res2, LOADTEXT_TYPE)
                end
            end
        end
    end
end

function ElitematchFightResultPanel:createLevelUpItem(x, y)
    if not self.node then return end
    local item = {}
    local res = PathTool.getResFrame("elitematch", "elitematch_14")
    item.bg = createSprite(res, x, y, self.node, cc.p(0.5,0.5))
    local bg_size = item.bg:getContentSize()
    local res1 = PathTool.getResFrame("elitematch", "elitematch_12")
    item.icon = createSprite(res1, bg_size.width * 0.5, bg_size.height * 0.5, item.bg, cc.p(0.5,0.5))
    local res2 = PathTool.getResFrame("elitematch", "txt_cn_elitematch_15")
    item.mask_icon = createSprite(res2, 35, 36, item.bg, cc.p(0.5,0.5))
    return item
end


function ElitematchFightResultPanel:handleEffect(status, result)
    if status == false then
        if self.play_effect then
            self.play_effect:clearTracks()
            self.play_effect:removeFromParent()
            self.play_effect = nil
        end
    else
        if not tolua.isnull(self.title_container) and self.play_effect == nil then
            if result == 1 then
                self.play_effect = createEffectSpine(Config.EffectData.data_effect_info[103], cc.p(self.title_width * 0.5, self.title_height * 0.5 - 14), cc.p(0.5, 0.5), false, PlayerAction.action_2)
            else
                self.play_effect = createEffectSpine(Config.EffectData.data_effect_info[104], cc.p(self.title_width * 0.5, self.title_height * 0.5 + 32), cc.p(0.5, 0.5), false, PlayerAction.action)
            end
            self.title_container:addChild(self.play_effect, 1)
        end
    end
end

function ElitematchFightResultPanel:playLevelSpine(status, config)
    if status == false then
        if self.level_spine then
            --self.level_spine:clearTracks()
            self.level_spine:removeFromParent()
            self.level_spine = nil
        end
    else
        if not config then return end
        if self.level_spine_record == nil or self.level_spine_record ~= config.ico then
            self.level_spine_record = config.ico
            self:playLevelSpine(false)
            --self.level_spine = createEffectSpine(config.ico, cc.p(0, 0), cc.p(0.5, 0.5), true, PlayerAction.action)
            --self.level_spine:setScale(0.5)
            --self.level_icon:addChild(self.level_spine, 1)
            local name = config.little_ico
            if name == nil or name == "" then
                name = "icon_iron"
            end
            local res = PathTool.getPlistImgForDownLoad("elitematch/elitematch_icon",name, false)
            self.level_spine = createSprite(res,0,0,self.level_icon,cc.p(0.5,0.5),LOADTEXT_TYPE)

            self:EliteEndAction(config)
        end
    end
end
--段位变化动画
function ElitematchFightResultPanel:EliteEndAction(config)
    if self.scdata then
        if self.scdata.elite_lev ~= self.scdata.new_elite_lev then
            --当前段位左移
            local function left_spine()
                local moveBy = cc.MoveBy:create(0.5,cc.p(-180, 0))
                self.level_spine:runAction(moveBy)
                if self.level_name then
                    local moveBy = cc.MoveBy:create(0.5,cc.p(-180, 0))
                    self.level_name:runAction(moveBy)
                end
            end

            local function level_sprite()
                local sprite = createSprite(PathTool.getResFrame("common","common_90034"), 0, 10, self.level_icon, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST)
                local fadein = cc.FadeIn:create(1.0)
                sprite:runAction(fadein)
            end

            local function right_spine()
                local next_config = Config.ArenaEliteData.data_elite_level[self.scdata.new_elite_lev]
                if next_config and next_config.ico then
                    local time = 0.5
                    if self.scdata.new_elite_lev > self.scdata.elite_lev then
                        self.next_lev_spine_bg = createEffectSpine(PathTool.getEffectRes(690), cc.p(0, 0), cc.p(0.5, 0.5), true, PlayerAction.action)
                        self.level_icon:addChild(self.next_lev_spine_bg, 1)
                        self.next_lev_spine_bg:setPosition(180,0)
                        local fadein_1 = cc.FadeIn:create(1.0)
                        self.next_lev_spine_bg:setOpacity(0)
                        self.next_lev_spine_bg:runAction(fadein_1)
                    end

                    local name = next_config.little_ico
                    if name == nil or name == "" then
                        name = "icon_iron"
                    end
                    local res = PathTool.getPlistImgForDownLoad("elitematch/elitematch_icon",name, false)
                    self.next_lev_spine = createSprite(res,0,0,nil,cc.p(0.5,0.5),LOADTEXT_TYPE)
                    --self.next_lev_spine = createEffectSpine(next_config.ico, cc.p(0, 0), cc.p(0.5, 0.5), true, PlayerAction.action)
                    --self.next_lev_spine:setScale(0.5)
                    self.level_icon:addChild(self.next_lev_spine, 3)
                    self.next_lev_spine:setPositionX(180)
                    self.next_lev_spine:setOpacity(0)

                    local fadein_2 = cc.FadeIn:create(time)
                    self.next_lev_spine:runAction(fadein_2)
                    local new_name = createLabel(22,Config.ColorData.data_new_color4[1],Config.ColorData.data_new_color4[6],0,0,"",self.level_icon,2, cc.p(0.5,0.5))
                    new_name:setLocalZOrder(10)
                    new_name:setString(next_config.name)
                    new_name:setPosition(180,0)
                    new_name:setOpacity(0)
                    local fadein_3 = cc.FadeIn:create(time)
                    new_name:runAction(fadein_3) 
                end
            end
            local seq = cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create(left_spine),
                                           cc.DelayTime:create(0.5), cc.CallFunc:create(level_sprite),
                                           cc.DelayTime:create(0.5),cc.CallFunc:create(right_spine))
            self.level_icon:setCascadeOpacityEnabled(true)
            self.level_icon:runAction(seq)
        end
    end
end

function ElitematchFightResultPanel:close_callback()
    self:handleEffect(false)
    self:playLevelSpine(false)
    --if self.next_lev_spine then
    --    self.next_lev_spine:clearTracks()
    --    self.next_lev_spine:removeFromParent()
    --    self.next_lev_spine = nil
    --end
    if self.next_lev_spine_bg then
        self.next_lev_spine_bg:clearTracks()
        self.next_lev_spine_bg:removeFromParent()
        self.next_lev_spine_bg = nil
    end    

    if self.sprite_1_load then
        self.sprite_1_load:DeleteMe()
        self.sprite_1_load = nil
    end

    if self.sprite_2_load then
        self.sprite_2_load:DeleteMe()
        self.sprite_2_load = nil
	end

    GlobalTimeTicket:getInstance():remove("elitematch_fight_result_timer")
    GlobalEvent:getInstance():Fire(BattleEvent.CLOSE_RESULT_VIEW)
    controller:openElitematchFightResultPanel(false)
end