-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      矿战冒险的胜利结算界面
-- <br/>2019年7月17日
-- --------------------------------------------------------------------
AdventureMineFightResultPanel = AdventureMineFightResultPanel or BaseClass(BaseView)

function AdventureMineFightResultPanel:__init(result, fight_type)
    self.win_type = WinType.Tips
    self.layout_name = "adventure/adventure_mine_fight_result_panel"
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.is_full_screen = false
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("battle", "battle"), type = ResourcesType.plist },
    }

    self.effect_list = {}
    self.result = result
    self.fight_type = fight_type
    self.item_list = {}
end


--初始化
function AdventureMineFightResultPanel:open_callback()
    local res = ""
    playOtherSound("b_win", AudioManager.AUDIO_TYPE.BATTLE) 

    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())
    self.source_container = self.root_wnd:getChildByName("container")
    self.title_container = self.source_container:getChildByName("title_container")
    self:playEnterAnimatianByObj(self.title_container, 2)
    self.title_width = self.title_container:getContentSize().width
    self.title_height = self.title_container:getContentSize().height
    self:handleEffect(true)
    self.Sprite_1 = self.source_container:getChildByName("Sprite_1")
    if self.sprite_1_load == nil then
        local res = PathTool.getPlistImgForDownLoad("bigbg","bigbg_97")
        self.sprite_1_load = loadSpriteTextureFromCDN(self.Sprite_1, res, ResourcesType.single, self.sprite_1_load)
    end
    
    self.Sprite_2 = self.source_container:getChildByName("Sprite_2")
    if self.sprite_2_load == nil then
        local res = PathTool.getPlistImgForDownLoad("bigbg","bigbg_98")
        self.sprite_2_load = loadSpriteTextureFromCDN(self.Sprite_2, res, ResourcesType.single, self.sprite_2_load)
    end
    
    
    self.Sprite_3 = self.source_container:getChildByName("Sprite_3")
    self.Sprite_4 = self.source_container:getChildByName("Sprite_4")

    self.fight_text = createLabel(24, cc.c4b(0xff,0xee,0xac,0xff), nil, 360, 806, "",self.root_wnd, nil, cc.p(0.5,0.5))
    -- local offset_y = 80
    -- self.Sprite_2:setPositionY(offset_y)
    -- self.Sprite_3:setPositionY(offset_y - 8)
    -- self.Sprite_4:setPositionY(offset_y - 8)
    self.time_label = createRichLabel(22, 1, cc.p(0.5, 0.5), cc.p(self.root_wnd:getContentSize().width / 2 + 5,389), nil, nil, 1000)
    -- self.time_label:setString(TI18N("10秒后关闭"))
    self.root_wnd:addChild(self.time_label)
    self.comfirm_btn = createButton(self.root_wnd,TI18N("占 领"), 620, 500, cc.size(162, 62), PathTool.getResFrame("common", "common_1017"), 24, Config.ColorData.data_color4[1])
    self.comfirm_btn:setPosition(self.root_wnd:getContentSize().width / 2 + 170,500)
    self.comfirm_btn:enableOutline(Config.ColorData.data_color4[264], 2)
    self.comfirm_btn:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            self:onClickOccupyBtn()
        end
    end)

    self.cancel_btn = createButton(self.root_wnd,TI18N("放弃占领"), 620, 500, cc.size(162, 62), PathTool.getResFrame("common", "common_1018"), 24, Config.ColorData.data_color4[1])
    self.cancel_btn:setPosition(self.root_wnd:getContentSize().width / 2 - 170 ,500)
    self.cancel_btn:enableOutline(Config.ColorData.data_color4[263], 2)
    self.cancel_btn:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            AdventureController:getInstance():openAdventureMineFightResultPanel(false)
            if self.data then
                AdventureController:getInstance():send20660(self.data.floor, self.data.room_id)
            end
        end
    end)

    self.harm_btn = self.source_container:getChildByName("harm_btn")
    self.harm_btn:setVisible(false)
    self.harm_btn:getChildByName("harm_lab"):setString(TI18N("数据统计"))

    local label  = createRichLabel(22,31, cc.p(0.5, 0.5), cc.p(360,340), nil, nil, 1000)
    label:setString(TI18N("获得物品"))
    self.source_container:addChild(label)
    local result_line_bg = createSprite(PathTool.getResFrame("common", "common_1094"), 320, 340, self.source_container, cc.p(0, 0.5))
    result_line_bg:setScaleX(-1)
    local result_line_bg_2 = createSprite(PathTool.getResFrame("common", "common_1094"), 400,340, self.source_container, cc.p(0, 0.5))

    self.scroll_view = createScrollView(SCREEN_WIDTH, 228, 0, 120, self.source_container, ccui.ScrollViewDir.vertical) 
end

function AdventureMineFightResultPanel:register_event()
    registerButtonEventListener(self.harm_btn, handler(self, self._onClickHarmBtn), true)
end

function AdventureMineFightResultPanel:onClickOccupyBtn(  )
    if not self.data then return end
    local setting = {}
    setting.floor = self.data.floor
    setting.room_id = self.data.room_id
    setting.is_occupy = true
    setting.end_time = self.data.end_time
    HeroController:getInstance():openAdventureMineFormGoFightPanel(true, PartnerConst.Fun_Form.Adventure_Mine_Def, setting, HeroConst.FormShowType.eFormSave)
    AdventureController:getInstance():openAdventureMineFightResultPanel(false)
end


function AdventureMineFightResultPanel:_onClickHarmBtn(  )
    if self.data and next(self.data) ~= nil then
        BattleController:getInstance():openBattleHarmInfoView(true, self.data)
    end
end

function AdventureMineFightResultPanel:openRootWnd(data,fight_type)
    self:setData(data, fight_type)
end

function AdventureMineFightResultPanel:setData(data, fight_type)
    if data then
        self.data = data 
        self.fight_type = fight_type
        local item_list ={}
        local first_award = self.data.first_award or {}

        self.harm_btn:setVisible(true)

        for i, v in ipairs(first_award) do
            v.is_first = true
            table.insert(item_list,v)
        end
        for i, v in ipairs(self.data.award) do
            v.is_first = false
            table.insert(item_list,v)
        end

        self.reward_list = item_list
        self.result = self.data.result
        --self.source_container:runAction(cc.Sequence:create(cc.FadeTo:create(0.2,150),cc.CallFunc:create(function ()
            self:rewardViewUI()
        --end))) 
        if self.fight_text then
            local name = Config.BattleBgData.data_fight_name[self.fight_type]
            if name then
                self.fight_text:setString(TI18N("当前战斗：")..name)
            end
        end  
    end
end

function AdventureMineFightResultPanel:handleEffect(status)
    if status == false then
        if self.play_effect then
            self.play_effect:clearTracks()
            self.play_effect:removeFromParent()
            self.play_effect = nil
        end
    else
        if not tolua.isnull(self.title_container) and self.play_effect == nil then
            self.play_effect = createEffectSpine(Config.EffectData.data_effect_info[103], cc.p(self.title_width * 0.5, self.title_height * 0.5), cc.p(0.5, 0.5), false, PlayerAction.action_2)
            self.title_container:addChild(self.play_effect, 1)
        end
    end
end


--奖励界面
function AdventureMineFightResultPanel:rewardViewUI()
    local sum = #self.reward_list
    local col =4
    -- 算出最多多少行
    self.row = math.ceil(sum / col)
    self.space = 30
    local max_height = self.space + (self.space + BackPackItem.Height) * self.row
    self.max_height = math.max(max_height, self.scroll_view:getContentSize().height)
    self.scroll_view:setInnerContainerSize(cc.size(self.scroll_view:getContentSize().width, self.max_height))

    if sum >= col then
        sum = col
    end
    if sum == 0 then
        if self.desc == nil then
            self.desc = createRichLabel(22, cc.c4b(0xff,0xff,0xff,0xff), cc.p(0.5,0.5), cc.p(360, 226), 6, nil, 900)
            self.source_container:addChild(self.desc)
            self.desc:setString(TI18N("该矿已经不能再被掠夺了~"))
        end
    end
    local total_width = sum * BackPackItem.Width + (sum - 1) * self.space
    self.start_x = (self.scroll_view:getContentSize().width - total_width) * 0.5

    -- 只有一行的话
    if self.row == 1 then
        self.start_y = self.max_height * 0.5
    else
        self.start_y = self.max_height - self.space - BackPackItem.Height * 0.5
    end
    for i, v in ipairs(self.reward_list) do
        local item = BackPackItem.new(true,true)
        item:setScale(1.3)
        item:setBaseData(v.item_id,v.num)
        if v.is_first  and v.is_first ==true then 
            item:showBiaoQian(true,TI18N("首通"))
        end
        local name  = Config.ItemData.data_get_data(v.item_id).name
        item:setGoodsName(name,nil,nil,1)
        local _x = self.start_x + BackPackItem.Width * 0.5 + ((i - 1) % col) * (BackPackItem.Width + self.space)
        local _y = self.start_y - math.floor((i - 1) / col) * (BackPackItem.Height + self.space)
        item:setPosition(cc.p(_x, _y))
        self.scroll_view:addChild(item)
        self.item_list[i] = item
    end
    self:ItemAciton()


end

function AdventureMineFightResultPanel:ItemAciton()
    if self.item_list and next(self.item_list or {}) ~= nil then
        local show_num = 0
        for i,v in pairs(self.item_list) do
            if v then
                delayRun(self.root_wnd,0.1 * (i - 1),function()
                    v:setVisible(true)
                    v:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1,1),cc.CallFunc:create(function ()
                            show_num = show_num + 1 
                            if show_num >= tableLen(self.item_list) then
                                self:updateTimer()
                            end
                    end)))
                end)
            end
        end
    else
        self:updateTimer()
    end
end

function AdventureMineFightResultPanel:updateTimer()
    if not self.data then return end
    local time = self.data.end_time - GameNet:getInstance():getTime()
    if time <= 0 then
        time = 1
    end
    local call_back = function()
        time = time - 1
        local new_time = math.ceil(time)
        if self.time_label and not tolua.isnull(self.time_label) then
            local str = new_time..TI18N("秒后自动放弃占领")
            self.time_label:setString(str)
        end
        if new_time <= 0 then
            AdventureController:getInstance():openAdventureMineFightResultPanel(false)
            GlobalTimeTicket:getInstance():remove("close_mine_result_reward")
        end
    end
    GlobalTimeTicket:getInstance():add(call_back,1, 0, "close_mine_result_reward")
    if self.time_label and not tolua.isnull(self.time_label) then
        local new_time = math.ceil(time)
        local str = new_time..TI18N("秒后自动放弃占领")
        self.time_label:setString(str)
    end
end

--清理
function AdventureMineFightResultPanel:close_callback()
    self:handleEffect(false)
    if not MainuiController:getInstance():checkIsInDramaUIFight() then
        AudioManager:getInstance():playLastMusic()
    end
    if BattleController:getInstance():getModel():getBattleScene() then
        local data = {result = self.result ,combat_type = self.fight_type}
        BattleController:getInstance():getModel():result(data)
    end

    if self.sprite_1_load then
        self.sprite_1_load:DeleteMe()
        self.sprite_1_load = nil
    end

    if self.sprite_2_load then
        self.sprite_2_load:DeleteMe()
        self.sprite_2_load = nil
    end

    GlobalTimeTicket:getInstance():remove("close_mine_result_reward")
    StartowerController:getInstance():openResultWindow(false)
end
