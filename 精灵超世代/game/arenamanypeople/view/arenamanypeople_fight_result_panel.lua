-- --------------------------------------------------------------------
-- @author: xhj@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      多人竞技场结果界面
-- <br/>Create: 2020-03-18
-- --------------------------------------------------------------------
ArenaManyPeopleFightResultPanel = ArenaManyPeopleFightResultPanel or BaseClass(BaseView)

local controller = ArenaManyPeopleController:getInstance()
local model = controller:getModel()
local table_insert = table.insert
local string_format = string.format

function ArenaManyPeopleFightResultPanel:__init()
    self.win_type = WinType.Big
    self.layout_name = "arenamanypeople/amp_fight_result_panel"
    self.view_tag = ViewMgrTag.DIALOGUE_TAG

    self.res_list = {
        -- { path = PathTool.getPlistImgForDownLoad("elitematch","elitematch"), type = ResourcesType.plist },
    }
end

function ArenaManyPeopleFightResultPanel:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    self.container = self.root_wnd:getChildByName("container")
    self.Sprite_1 = self.container:getChildByName("Sprite_1")
    if self.sprite_1_load == nil then
        local res = PathTool.getPlistImgForDownLoad("bigbg","bigbg_97")
        self.sprite_1_load = loadSpriteTextureFromCDN(self.Sprite_1, res, ResourcesType.single, self.sprite_1_load)
    end
    
    self.Sprite_2 = self.container:getChildByName("Sprite_2")
    if self.sprite_2_load == nil then
        local res = PathTool.getPlistImgForDownLoad("bigbg","bigbg_98")
        self.sprite_2_load = loadSpriteTextureFromCDN(self.Sprite_2, res, ResourcesType.single, self.sprite_2_load)
    end

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
    


    self.fight_text = createLabel(24, cc.c4b(0xff,0xee,0xac,0xff), nil, 360, 455, "",self.container, nil, cc.p(0.5,0.5))


    self.comfirm_btn = createButton(self.container,TI18N("确定"), 620, 580, cc.size(162, 62), PathTool.getResFrame("common", "common_1017"), 24, Config.ColorData.data_color4[1])
    self.comfirm_btn:setPosition(self.container:getContentSize().width / 2 - 170, -50)
    self.comfirm_btn:enableOutline(Config.ColorData.data_color4[264], 2)
    self.comfirm_btn:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            self:onClickBtnClose()
        end
    end)

    self.cancel_btn = createButton(self.container,TI18N("返回玩法"), 620, 580, cc.size(162, 62), PathTool.getResFrame("common", "common_1018"), 24, Config.ColorData.data_color4[1])
    self.cancel_btn:setPosition(self.container:getContentSize().width / 2 + 170, -50)
    self.cancel_btn:enableOutline(Config.ColorData.data_color4[263], 2)
    self.cancel_btn:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            if not self.scdata then return end
            BattleResultReturnMgr:returnByFightType(BattleConst.Fight_Type.AreanManyPeople) --先
            self:onClickBtnClose()
        end
    end)

end

function ArenaManyPeopleFightResultPanel:register_event()
    registerButtonEventListener(self.background, handler(self, self.onClickBtnClose) ,false, 1)
    registerButtonEventListener(self.harm_btn, handler(self, self.onClickHarmBtn) ,false, 1)
end

function ArenaManyPeopleFightResultPanel:onClickHarmBtn(  )
    if self.scdata and self.scdata.all_hurt_statistics then
        table.sort( self.scdata.all_hurt_statistics, function(a, b) return a.type < b.type end)
        for i,v in ipairs(self.scdata.all_hurt_statistics) do
            v.atk_name  = v.a_name
            v.target_role_name  = v.b_name
            if v.ret == 1 then
                v.result = 1
            elseif v.ret == 2 then
                v.result = 2
            end
        end
        local setting = {}
        setting.fight_type = BattleConst.Fight_Type.AreanManyPeople
        BattleController:getInstance():openBattleHarmInfoView(true, self.scdata.all_hurt_statistics, setting)
    end
end

--关闭
function ArenaManyPeopleFightResultPanel:onClickBtnClose()
    controller:openArenaManyPeopleFightResultPanel(false)
end

function ArenaManyPeopleFightResultPanel:openRootWnd(scdata)
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
        local name = Config.BattleBgData.data_fight_name[BattleConst.Fight_Type.AreanManyPeople]
        if name then
            self.fight_text:setString(TI18N("当前战斗：")..name)
        end
    end

    --申请网络刷新一下必要的界面.
    controller:sender29000()
end

function ArenaManyPeopleFightResultPanel:setData(scdata)
    local config = Config.HolidayArenaTeamData.data_elite_level[self.scdata.score_lev]
    if config then
        local color = cc.c4b(0x56,0x2e,0x0d,0xff)
        if config.icon == "amp_icon_1" or config.icon == "amp_icon_2" or config.icon == "amp_icon_3" then
            color = cc.c4b(0x30,0x38,0x53,0xff)
        end
        self.level_name:enableOutline(color,2)
        self.level_name:setString(config.name)
        self:playLevelSpine(true, config)
    end

    local show_list = {}

    local left_count = self.scdata.new_score
    local left_count_2 = self.scdata.new_rank
    
    local list = {key = TI18N("积分:"), left_value = left_count, right_value = self.scdata.new_score-self.scdata.score,type = 1,old_value = self.scdata.score}
    table_insert(show_list, list)
    
    local list2 = {key = TI18N("排名:"), left_value = left_count_2, right_value = self.scdata.new_rank-self.scdata.rank,type = 2,old_value = self.scdata.rank}
    table_insert(show_list, list2)    

    --平常赛
    table_insert(show_list, {node = self.node, need_chang = true})

    local score = self.scdata.new_score-config.need_score
    --写进度条 还没写
    local per_data = {}

    local percent, str
    if score >= 0 then
        if self.scdata.new_score_lev > self.scdata.score_lev then
            local new_config = Config.HolidayArenaTeamData.data_elite_level[self.scdata.new_score_lev]
            if new_config then
                percent, str  = self:getPercent(new_config,self.scdata.new_score-new_config.need_score)
            end
        else
            percent, str  = self:getPercent(config, score)
        end
        
    else
        if self.scdata.score_lev > self.scdata.new_score_lev then
            --说明降级了--> 
            local new_config = Config.HolidayArenaTeamData.data_elite_level[self.scdata.new_score_lev]
            if new_config then
                percent, str  = self:getPercent(new_config, config.need_score - new_config.need_score + score)
            end
        else
            percent, str  = self:getPercent(config, score)
        end
    end
    
    self.end_percent = percent
    
    self.end_str = str
    self:showProgressbarEffect(config)
   
    self:initShowList(show_list)
end

function ArenaManyPeopleFightResultPanel:getPercent(config,  score)
    local next_score = 9999
    local next_config = Config.HolidayArenaTeamData.data_elite_level[config.lev+1]
    if next_config then
        next_score = next_config.need_score-config.need_score
    end

    local percent, str 
    local total_exp = next_score
    if score >= 0 then
        percent = score*100/total_exp
        
        if score > next_score then
            score = next_score
        end 
        str = string_format("%s/%s", score, next_score)
    else
        percent = 0
        local count = score
        str = count
    end
    return percent, str
end

function ArenaManyPeopleFightResultPanel:showProgressbarEffect(config)
    local temp_score = 1
    
    if self.scdata.result ~= 1 then
        temp_score = -temp_score
    end
    local chang_score = 0
    local config = config
    local cur_score = self.scdata.score - config.need_score
    local call_back = function()
        cur_score = cur_score + temp_score
        chang_score = chang_score + temp_score
        local percent, str  = self:getPercent(config, cur_score)
        if math.abs(chang_score) >= math.abs(self.scdata.new_score-self.scdata.score) then
            --变化分超过了就结束了
            percent = self.end_percent
            str = self.end_str
            GlobalTimeTicket:getInstance():remove("emp_fight_result_timer")
        end
        if self.scdata.score_lev > self.scdata.new_score_lev then
            --掉级
            local new_config = Config.HolidayArenaTeamData.data_elite_level[self.scdata.new_score_lev]
            if new_config then
                cur_score = self.scdata.new_score - new_config.need_score
                percent, str = self:getPercent(new_config, cur_score)
            else
                percent = 0 
                str = 0
                GlobalTimeTicket:getInstance():remove("emp_fight_result_timer")
            end
        end
        self:showProgressbar(true, percent, str)
    end
    GlobalTimeTicket:getInstance():add(call_back, 0.02, 0, "emp_fight_result_timer")
    -- call_back()
end

function ArenaManyPeopleFightResultPanel:initShowList(show_list)
    if not show_list then return end
    local total_height = 144
    local start_y = 90
    local middle_x = 360

    local count = #show_list
    local item_width = total_height/count
    for i=1,count do
        local data = show_list[i]
        local y = start_y + (i - 1) * item_width + item_width *0.5
        if data.node ~= nil then
            data.node:setPositionY(240)
                local size = self.common_90044_0:getContentSize()
            if data.need_chang then
                self.common_90044_0:setContentSize(cc.size(size.width, total_height + 10))
            else
                self.common_90044_0:setContentSize(cc.size(size.width, (count - 1) * item_width ))
            end
        elseif data.score ~= nil then
            --显示比分的 FFEEAC
            createLabel(24, cc.c4b(0xff,0xee,0xac,0xff), nil, middle_x, y, data.score, self.container, 2, cc.p(0.5, 0.5))
        else --{key = "精英积分:", left_value = left_count, right_value = self.scdata.add_score, not_change = true}
            local str = string_format("%s %s", data.key, data.left_value)
            createLabel(24, cc.c4b(0xff,0xee,0xac,0xff), nil, 200, y, str, self.container, 2, cc.p(0, 0.5))
            local res , score
            if data.type == 2 then --排名
                if data.old_value ~= 0 and data.right_value > 0 then
                    res = PathTool.getResFrame("common", "common_1087")
                else
                    res = PathTool.getResFrame("common", "common_1086")
                end
            else
                if data.right_value >= 0 then
                    res = PathTool.getResFrame("common", "common_1086")
                else
                    res = PathTool.getResFrame("common", "common_1087")
                end
            end
            
            score = math.abs(data.right_value)
            if data.not_change then
                createLabel(24, cc.c4b(0xff,0xee,0xac,0xff), nil, 466, y, TI18N("不变"), self.container, 2, cc.p(0, 0.5))
            else
                createSprite(res, 452, y, self.container, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST, 0)    
                createLabel(24, cc.c4b(0xff,0xee,0xac,0xff), nil, 466, y, tostring(score), self.container, 2, cc.p(0, 0.5))
            end
        end
    end
end


function ArenaManyPeopleFightResultPanel:showProgressbar(status, percent, label)
    if not self.node then return end
    if status then
        local size = cc.size(350, 24)
        if not self.comp_bar then
            local res = PathTool.getResFrame("common","common_90005")
            local res1 = PathTool.getResFrame("common","common_90006")
            local res2 = PathTool.getResFrame("common","common_90082")
            self.camp_bar_record_res = res1
            local bg,comp_bar = createLoadingBar(res, res1, size, self.node, cc.p(0.5,0.5), 0, 0, true, true)
            self.comp_bar_bg = bg
            self.comp_bar = comp_bar

        end
        if not self.comp_bar_label then
            local text_color = cc.c3b(255,255,255)
            local line_color = cc.c3b(0,0,0)
            self.comp_bar_label = createLabel(16, text_color, line_color, size.width/2, size.height/2, "", self.comp_bar, 2, cc.p(0.5, 0.5))
        end

        self.comp_bar_bg:setVisible(true)

        self.comp_bar:setPercent(percent)    
        self.comp_bar_label:setString(label)
    else
        if self.comp_bar_bg then
            self.comp_bar_bg:setVisible(false)
        end
    end
end


function ArenaManyPeopleFightResultPanel:handleEffect(status, result)
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

function ArenaManyPeopleFightResultPanel:playLevelSpine(status, config)
    if status == false then
        if self.level_spine then
            self.level_spine:setVisible(false)
        end
    else
        if not config then return end
        if self.level_spine_record == nil or self.level_spine_record ~= config.icon then
            self.level_spine_record = config.icon
            local res = PathTool.getPlistImgForDownLoad("arenampmatch/arenampmatch_icon", config.icon)
            self.level_spine = createSprite(nil, 0, 3, self.level_icon, cc.p(0.5, 0.5))
            self.item_load = loadSpriteTextureFromCDN(self.level_spine, res, ResourcesType.single, self.item_load)
            self.level_spine:setVisible(true)
            self:EliteEndAction(config)
        end
    end
end
--段位变化动画
function ArenaManyPeopleFightResultPanel:EliteEndAction(config)
    if self.scdata then
        if self.scdata.score_lev ~= self.scdata.new_score_lev then
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
                local sprite = createSprite(PathTool.getResFrame("common","common_30014"), 0, 0, self.level_icon, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST)
                local fadein = cc.FadeIn:create(1.0)
                sprite:runAction(fadein)
            end

            local function right_spine()
                local next_config = Config.HolidayArenaTeamData.data_elite_level[self.scdata.new_score_lev]
                if next_config and next_config.icon then
                    local time = 0.5
                    if self.scdata.new_score_lev > self.scdata.score_lev then
                        self.next_lev_spine_bg = createEffectSpine(PathTool.getEffectRes(690), cc.p(0, 3), cc.p(0.5, 0.5), true, PlayerAction.action)
                        self.level_icon:addChild(self.next_lev_spine_bg, 1)
                        self.next_lev_spine_bg:setPosition(180,0)
                        local fadein_1 = cc.FadeIn:create(1.0)
                        self.next_lev_spine_bg:setOpacity(0)
                        self.next_lev_spine_bg:runAction(fadein_1)
                    end

                    local res = PathTool.getPlistImgForDownLoad("arenampmatch/arenampmatch_icon", next_config.icon)
                    self.next_lev_spine = createSprite(nil, 0, 3, self.level_icon, cc.p(0.5, 0.5),nil,10)
                    self.item_load_2 = loadSpriteTextureFromCDN(self.next_lev_spine, res, ResourcesType.single, self.item_load_2)
                    self.next_lev_spine:setPositionX(180)
                    self.next_lev_spine:setOpacity(0)

                    local fadein_2 = cc.FadeIn:create(time)
                    self.next_lev_spine:runAction(fadein_2)
                    local new_name = createLabel(30,cc.c4b(0xff,0xff,0xff,0xff),cc.c4b(0x00,0x00,0x00,0xff),0,0,"",self.level_icon,2, cc.p(0.5,0.5))
                    new_name:setLocalZOrder(10)
                    local color = cc.c4b(0x56,0x2e,0x0d,0xff)
                    if next_config.icon == "amp_icon_1" or next_config.icon == "amp_icon_2" or next_config.icon == "amp_icon_3" then
                        color = cc.c4b(0x30,0x38,0x53,0xff)
                    end
                    new_name:enableOutline(color,2)

                    new_name:setString(next_config.name)
                    new_name:setPosition(180,-60)
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

function ArenaManyPeopleFightResultPanel:close_callback()
    self:handleEffect(false)
    self:playLevelSpine(false)

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
    
    if self.item_load then
        self.item_load:DeleteMe()
        self.item_load = nil
    end

    if self.item_load_2 then
        self.item_load_2:DeleteMe()
        self.item_load_2 = nil
    end

    GlobalTimeTicket:getInstance():remove("emp_fight_result_timer")
    GlobalEvent:getInstance():Fire(BattleEvent.CLOSE_RESULT_VIEW)
    controller:openArenaManyPeopleFightResultPanel(false)
end