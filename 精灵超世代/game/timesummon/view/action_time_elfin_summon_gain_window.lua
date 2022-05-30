-- --------------------------------------------------------------------
-- 
-- 
-- @author: xhj(必填, 创建模块的人员)
-- @editor: xhj(必填, 后续维护以及修改的人员)
-- @description:
--      精灵召唤获得界面
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
ActionTimeElfinSummonGainWindow = ActionTimeElfinSummonGainWindow or BaseClass(BaseView)

local controller = TimesummonController:getInstance() 
local model = controller:getModel()

function ActionTimeElfinSummonGainWindow:__init(is_call)
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.item_list = {} --物品列表
    self.win_type = WinType.Full
    self.is_action_ing = false
    self.is_call = is_call or TRUE --是否先召唤结算

    self.is_show_title = false
    self.music_info = AudioManager:getInstance():getMusicInfo()
    self.elfin_summon_type = 1 --1:限时精灵召唤  2：常驻精灵召唤
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("partnersummon", "partnersummon"), type = ResourcesType.plist },
        { path = PathTool.getPlistImgForDownLoad("bigbg", "bigbg_12"), type = ResourcesType.single },
        { path = PathTool.getPlistImgForDownLoad("bigbg", "txt_cn_bigbg_18"), type = ResourcesType.single },
    }

    self.config_data = Config.HolidaySpriteLotteryData.data_summon
end

function ActionTimeElfinSummonGainWindow:createRootWnd()
    self.size = cc.size(SCREEN_WIDTH, SCREEN_HEIGHT)
    self.root_wnd = ccui.Layout:create()
    self.root_wnd:setAnchorPoint(cc.p(0.5, 0.5))
    self.root_wnd:setPosition(cc.p(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2))
    self.root_wnd:setContentSize(self.size)
    showLayoutRect(self.root_wnd,255)

    -- 预加载音效
    AudioManager:getInstance():preLoadEffect(AudioManager.AUDIO_TYPE.Recruit, "recruit_action")
    AudioManager:getInstance():preLoadEffect(AudioManager.AUDIO_TYPE.Recruit, "recruit_action2")
    AudioManager:getInstance():preLoadEffect(AudioManager.AUDIO_TYPE.Recruit, "result_01")
    AudioManager:getInstance():preLoadEffect(AudioManager.AUDIO_TYPE.COMMON, 'c_get')

    self.source_container = ccui.Layout:create()
    self.source_container:setTouchEnabled(true)
    self.source_container:setAnchorPoint(cc.p(0.5, 0.5))
    self.source_container:setOpacity(255)
    self.source_container:setContentSize(cc.size(SCREEN_WIDTH, SCREEN_HEIGHT))
    self.source_container:setCascadeOpacityEnabled(true)
    self.source_container:setScale(display.getMaxScale())
    self.source_container:setPosition(cc.p(self.size.width/2, SCREEN_HEIGHT / 2))
    self.root_wnd:addChild(self.source_container)

    self.draw_container = ccui.Layout:create()
    self.draw_container:setTouchEnabled(false)
    self.draw_container:setAnchorPoint(cc.p(0.5, 0.5))
    self.draw_container:setContentSize(cc.size(SCREEN_WIDTH, SCREEN_HEIGHT))
    self.draw_container:setPosition(cc.p(self.size.width/2, SCREEN_HEIGHT / 2))
    self.root_wnd:addChild(self.draw_container)

    self.image_bg = createSprite(nil, SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2, self.source_container, cc.p(0.5, 0.5), LOADTEXT_TYPE)
    self.image_bg:setVisible(false)
    self.image_bg:setScale(display.getMaxScale())

    self.image_top_bg = createScale9Sprite(PathTool.getPlistImgForDownLoad("bigbg", "bigbg_12"), SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2 - 40, LOADTEXT_TYPE, self.source_container)
    self.image_top_bg:setAnchorPoint(cc.p(0.5, 0.5))
    self.image_top_bg:setVisible(false)
    self.image_top_bg:setContentSize(cc.size(SCREEN_WIDTH + 100,640))

    local top_bg_line_1 = createSprite(PathTool.getResFrame("partnersummon", "partnersummon_line"), self.image_top_bg:getContentSize().width/2, self.image_top_bg:getContentSize().height -5, image_top_bg, cc.p(0, 0.5), LOADTEXT_PLIST)
    local top_bg_line_2 = createSprite(PathTool.getResFrame("partnersummon", "partnersummon_line"), self.image_top_bg:getContentSize().width/2,self.image_top_bg:getContentSize().height - 5, image_top_bg, cc.p(0, 0.5), LOADTEXT_PLIST)
    top_bg_line_1:setScaleX(-1)
    --self.image_bottom_bg = createScale9Sprite(PathTool.getPlistImgForDownLoad("bigbg", "bigbg_12"),SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2 + 55, LOADTEXT_TYPE, self.source_container)
    --self.image_bottom_bg:setContentSize(cc.size(SCREEN_WIDTH + 100, 220))
    --self.image_bottom_bg:setScaleY(-1)
    --self.image_bottom_bg:setVisible(false)
    --self.image_bottom_bg:setAnchorPoint(cc.p(0.5, 0))

    self.title_bg = createSprite(PathTool.getPlistImgForDownLoad("bigbg", "txt_cn_bigbg_18"), SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2 + 525, self.source_container, cc.p(0.5, 0.5), LOADTEXT_TYPE)
    self.title_bg:setVisible(false)
    self.title_bg:setScale(1.5)
  
    self.item_container = ccui.Layout:create()
    self.item_container:setAnchorPoint(cc.p(0.5, 0.5))
    self.item_container:setOpacity(255)
    self.item_container:setContentSize(cc.size(SCREEN_WIDTH, 440))
    self.item_container:setCascadeOpacityEnabled(true)
    self.item_container:setPosition(cc.p(self.size.width / 2, SCREEN_HEIGHT / 2))
    self.item_container:setVisible(false)
    self.root_wnd:addChild(self.item_container)

    if self.is_call == TRUE then
        self.again_btn = createButton(self.item_container,TI18N("再抽一次"),165,-55,cc.size(168,66),PathTool.getResFrame("common","common_1018"))
        self.again_btn:setRichText(TI18N("<div fontColor=#ffffff fontsize=26 shadow=0,-2,2,#854000>再抽一次</div>"))
        self.item_label = createRichLabel(26, Config.ColorData.data_new_color4[6], cc.p(0.5, 0.5), cc.p(80,90),0,0,500)
        self.item_label:setString("")
        self.again_btn:addChild(self.item_label)
        self.comfirm_btn = createButton(self.item_container,TI18N("确定"),560,-55,cc.size(168,66),PathTool.getResFrame("common","common_1017"))
        self.comfirm_btn:setRichText(TI18N("<div fontColor=#ffffff fontsize=26 shadow=0,-2,2,#0e73b3>确定</div>"))
    end
    self:resgiter_event()
end

function ActionTimeElfinSummonGainWindow:openRootWnd(data,is_call,elfin_summon_type)
    BattleResultMgr:getInstance():setWaitShowPanel(true)
    self.tiems = data.times
    self.group_id = data.group_id or 0
    self.reward_list = data.rewards
    self.elfin_summon_type = elfin_summon_type or 1
    self.config_data = Config.HolidaySpriteLotteryData.data_summon

    local config = self.config_data[data.group_id]
    if config then
        self.one_icon_item = config.loss_item_once[1][1]
        self.five_icon_item = config.loss_item_ten[1][1]
        self.again_btn:setVisible(true)
        self.comfirm_btn:setPosition(cc.p(560, -55))
    else
        self.again_btn:setVisible(false)
        self.comfirm_btn:setPosition(cc.p(self.item_container:getContentSize().width/2, -55))
    end
    self.bg_res_id = PathTool.getPlistImgForDownLoad("bigbg/partnersummon", "partnersummon_call_bg_300", true)
    self.resources_bg_load = loadSpriteTextureFromCDN(self.image_bg, self.bg_res_id, ResourcesType.single, self.resources_bg_load)
    self:callAction(data)
end

function ActionTimeElfinSummonGainWindow:callAction(data)
    self.is_action_ing = true
    self:updateEffectAction()
end

function ActionTimeElfinSummonGainWindow:updateEffectAction()
    local action = PlayerAction.action
    if self.config_data[self.group_id] then
        action = self.config_data[self.group_id].action_name
    end

    local music_name = "recruit_action"
    if self.group_id and self.group_id ~= 0 then
       music_name = "recruit_"..action
    end
    self.recuit_music = AudioManager:getInstance():playEffect(AudioManager.AUDIO_TYPE.Recruit, music_name, false)
    self:clickSkilAction()
end




-- 4星立绘的底盘特效
function ActionTimeElfinSummonGainWindow:showDrawEffect1( status )
    if status == true then
        if not tolua.isnull(self.source_container) and self.draw_effect_1 == nil then
            self.draw_effect_1 = createEffectSpine(Config.EffectData.data_effect_info[1313], cc.p(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2), cc.p(0.5, 0.5), true, PlayerAction.action_1)
            self.source_container:addChild(self.draw_effect_1)
        end
    else
        if self.draw_effect_1 then
            self.draw_effect_1:clearTracks()
            self.draw_effect_1:removeFromParent()
            self.draw_effect_1 = nil
        end
    end
end
-- 4星的白光特效
function ActionTimeElfinSummonGainWindow:showDrawEffect2( status )
    if status == true then
        if not tolua.isnull(self.source_container) and self.draw_effect_2 == nil then
            self.draw_effect_2 = createEffectSpine(Config.EffectData.data_effect_info[1313], cc.p(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2), cc.p(0.5, 0.5), true, PlayerAction.action_2)
            self.source_container:addChild(self.draw_effect_2)
        end
    else
        if self.draw_effect_2 then
            self.draw_effect_2:clearTracks()
            self.draw_effect_2:removeFromParent()
            self.draw_effect_2 = nil
        end
    end
end

-- 五星底盘背景特效
function ActionTimeElfinSummonGainWindow:showDrawEffect3(status)
    if status == true then
        if not tolua.isnull(self.source_container) and self.draw_effect_3 == nil then
            self.draw_effect_3 = createEffectSpine(Config.EffectData.data_effect_info[1317], cc.p(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2), cc.p(0.5, 0.5), true, PlayerAction.action_2)
            self.source_container:addChild(self.draw_effect_3)
        elseif self.draw_effect_3 then
            self.draw_effect_3:setToSetupPose()
            self.draw_effect_3:setAnimation(0, PlayerAction.action_2, true)
        end
    else
        if self.draw_effect_3 then
            self.draw_effect_3:clearTracks()
            self.draw_effect_3:removeFromParent()
            self.draw_effect_3 = nil
        end
    end
end

-- 五星粒子特效
function ActionTimeElfinSummonGainWindow:showDrawEffect4(status)
    if status == true then
        if not tolua.isnull(self.draw_container) and self.draw_effect_4 == nil then
            self.draw_effect_4 = createEffectSpine(Config.EffectData.data_effect_info[1313], cc.p(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2), cc.p(0.5, 0.5), true, PlayerAction.action_3)
            self.draw_container:addChild(self.draw_effect_4, 1)
        end
    else
        if self.draw_effect_4 then
            self.draw_effect_4:clearTracks()
            self.draw_effect_4:removeFromParent()
            self.draw_effect_4 = nil
        end
    end
end

--更新物品列表
function ActionTimeElfinSummonGainWindow:updateItemData(data)
    self.is_action_ing = false
    self.item_container:setVisible(true)
    self.image_top_bg:setVisible(true)
    --self.image_bottom_bg:setVisible(true)
    self.image_bg:setVisible(true)
    -- self.cur_hero_is_five_star = (hero_cfg.star >= 5)
    
    self:showDrawEffect1(false)
    self:showDrawEffect3(false)
    self:showDrawEffect4(true)
    self.title_bg:setVisible(true)
    local sum = #data
    local col = 5
    -- 算出最多多少行
    self.row = math.ceil(sum / col)
    self.space = 20
    local max_height = self.space + (self.space + 20 + BackPackItem.Height) * self.row
    self.max_height = math.max(max_height, self.item_container:getContentSize().height)
    self.title_bg:setPosition(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2 + 270)
    if sum >= col then
        sum = col
    end
    local total_width = sum * BackPackItem.Width + (sum - 1) * self.space
    self.start_x = (self.item_container:getContentSize().width - total_width) * 0.5
    -- 只有一行的话
    if self.row == 1 then
        self.start_y = self.max_height * 0.5 + 65 - 65
    else
        self.start_y = self.max_height - self.space - BackPackItem.Height * 0.5 - 50
    end
    self.show_elfin_tips = {}
    local is_show_effect = false
    for i, v in ipairs(data) do
        local item = BackPackItem.new(false,true)
        item:setAnchorPoint(cc.p(0.5,0.5))
        item:setBaseData(v.base_id,v.num)
        item:setScale(1.2)
        item:setOpacity(0)
        item:setDefaultTip()
        item.config = Config.ItemData.data_get_data(v.base_id)  
        self.item_container:addChild(item)
        local _x = self.start_x + BackPackItem.Width * 0.5 + ((i - 1) % col) * (BackPackItem.Width + self.space)
        local _y = self.start_y - math.floor((i - 1) / col) * (BackPackItem.Height + self.space + 20)
        item:setPosition(cc.p(_x, _y))
        self.item_list[i] = item
       
        if self.elfin_summon_type == 2 then
            local list_cfg = Config.HolidaySpriteLotteryData.data_const["sprite_lottery_rare_list"]
            if item.config and BackPackConst.checkIsElfin(item.config.type) and list_cfg then
                for k,v in pairs(list_cfg.val) do
                    if item.config.quality == v then
                        table.insert(self.show_elfin_tips, item.config)
                    end
                end
            end
        end
        if BackPackConst.checkIsElfin(item.config.type) and item.config.quality == BackPackConst.quality.orange then
            is_show_effect = true
        end
    end

    if is_show_effect == true then
        self:showDrawEffect1(false)
        self:showDrawEffect2(false)
        self:showDrawEffect3(true)   
        self.bg_res_id = PathTool.getPlistImgForDownLoad("bigbg/partnersummon", "partnersummon_call_bg_400", true)
    else
        self:showDrawEffect1(true)
        self:showDrawEffect2(true)
        self:showDrawEffect3(false)
        self.bg_res_id = PathTool.getPlistImgForDownLoad("bigbg/partnersummon", "partnersummon_call_bg_300", true)
    end
    self.resources_bg_load = loadSpriteTextureFromCDN(self.image_bg, self.bg_res_id, ResourcesType.single, self.resources_bg_load)
    
    AudioManager:getInstance():playEffect(AudioManager.AUDIO_TYPE.COMMON, 'c_get', false)
    delayOnce(function ()
        if self.item_list then
            for i, item in ipairs(self.item_list) do
                if item and item then
                    local fadeIn = cc.FadeIn:create(0.1)
                    local scaleTo = cc.ScaleTo:create(0.1, 1)
                    item:runAction(cc.Sequence:create(cc.DelayTime:create(0.1 * i ),cc.Spawn:create(fadeIn, scaleTo,cc.CallFunc:create(function ()
                        item:playItemSound()  
                        item:showItemEffect(true,156,PlayerAction.action_3,false)
                    end),cc.CallFunc:create(function ()
                        if item.config and BackPackConst.checkIsElfin(item.config.type) and item.config.quality >=BackPackConst.quality.purple then
                            item:showItemEffect(false)
                            local effect_id = 1750
                            local action = PlayerAction.action_1
                            if item.config.quality >= BackPackConst.quality.orange then
                                action = PlayerAction.action_2
                            end
                            item:showItemEffect(true, effect_id, action, true)
                        end
                    end))))
                end
            end
        end
    end,0.2)
 
    if self.is_call == TRUE then
        if self.tiems == 10 and self.item_label and self.five_icon_item then
            self.again_btn:setRichText(TI18N("<div fontColor=#ffffff fontsize=26 shadow=0,-2,2,#854000>再抽十次</div>"))
            self:updateTenSummon()
        else
            self.again_btn:setRichText(TI18N("<div fontColor=#ffffff fontsize=26 shadow=0,-2,2,#854000>再抽一次</div>"))
            self:updateSingleSummon()
        end
    else 
    end

    local time = 0.1
    if self.item_list then
        time = #self.item_list * time
    end
    delayOnce(function ()
        self:checkElfinTips()
    end,time+0.7)

end

function ActionTimeElfinSummonGainWindow:updateTenSummon(  )
    local summon_have_num = BackpackController:getInstance():getModel():getItemNumByBid(self.five_icon_item)
    local item_icon = Config.ItemData.data_get_data(self.five_icon_item).icon
    if summon_have_num >= self.tiems then
        self._item_enough = true
        self.item_label:setString(string.format(TI18N("<img src=%s visible=true scale=0.5 /><div fontColor=#0e7709 fontsize=26 shadow=0,-2,2,#854000>%d</div><div fontColor=#3d5078 fontsize=26 shadow=0,-2,2,#854000>/%d</div>"), PathTool.getItemRes(item_icon), summon_have_num, self.tiems))
    else
        self._item_enough = false
        self.item_label:setString(string.format(TI18N("<img src=%s visible=true scale=0.5 /><div fontColor=#d63636 fontsize=26 shadow=0,-2,2,#854000>%d</div><div fontColor=#3d5078 fontsize=26 shadow=0,-2,2,#854000>/%d</div>"), PathTool.getItemRes(item_icon), summon_have_num, self.tiems))
    end
end

function ActionTimeElfinSummonGainWindow:updateSingleSummon()
    if not self.one_icon_item then return end
    local summon_have_num = BackpackController:getInstance():getModel():getItemNumByBid(self.one_icon_item)
    local item_cfg = Config.ItemData.data_get_data(self.one_icon_item)
    if not item_cfg then return end
    local item_icon = item_cfg.icon
    if summon_have_num >= self.tiems then
        self._item_enough = true
        self.item_label:setString(string.format(TI18N("<img src=%s visible=true scale=0.5 /><div fontColor=#0e7709 fontsize=26 shadow=0,-2,2,#854000>%d</div><div fontColor=#3d5078 fontsize=26 shadow=0,-2,2,#854000>/%d</div>"), PathTool.getItemRes(item_icon), summon_have_num, self.tiems))
    else
        self._item_enough = false
        self.item_label:setString(string.format(TI18N("<img src=%s visible=true scale=0.5 /><div fontColor=#d63636 fontsize=26 shadow=0,-2,2,#854000>%d</div><div fontColor=#3d5078 fontsize=26 shadow=0,-2,2,#854000>/%d</div>"), PathTool.getItemRes(item_icon), summon_have_num, self.tiems))
    end
end


function ActionTimeElfinSummonGainWindow:showAlert(num, item_icon_2, val_str, val_num, call_num,call_back)
    if self.alert then
        self.alert:close()
        self.alert = nil
    end

    local cancle_callback = function()
        if self.alert then
            self.alert:close()
            self.alert = nil
        end
    end

    local have_sum = RoleController:getInstance():getRoleVo().gold + RoleController:getInstance():getRoleVo().red_gold
    local str = string.format(TI18N("是否使用<img src=%s visible=true scale=0.3 /><div fontColor=#289b14 fontsize= 26>%s</div><div fontColor=#764519>(拥有:</div><div fontColor=#289b14 fontsize= 26>%s</div><div fontColor=#764519>)\n</div>"), PathTool.getItemRes(item_icon_2), num, have_sum)
    local str_ = str .. string.format(TI18N("<div fontColor=#764519>购买</div><div fontColor=#289b14 fontsize= 26>%s</div><div fontColor=#764519>%s(同时附赠</div><div fontColor=#289b14 fontsize= 26>%s</div><div fontColor=#764519>次招募)</div>"), val_num, val_str, call_num)
    self.alert = CommonAlert.show(str_, TI18N("确定"), call_back, TI18N("取消"), nil, CommonAlert.type.rich,nil)
end


function ActionTimeElfinSummonGainWindow:clickSkilAction(is_click)
    if self.is_action_ing ==  false then
        return 
    end

    if self.item_list and next(self.item_list or {}) ~= nil then
        for i, item in ipairs(self.item_list) do
            if item and item:getRootWnd() then
                item:getRootWnd():setScale(1)
                item:getRootWnd():stopAllActions()
            end
        end
    end
    if self.title_effect and self.is_show_title == false then
        if self.title_effect then
            self.title_effect:runAction(cc.RemoveSelf:create(true))
            self.title_effect = nil
        end
    end
    if not self.title_effect then
        self.is_show_title = true
        self.title_bg:runAction(cc.Sequence:create(cc.CallFunc:create(function()
            self.title_bg:setVisible(true)
        end), cc.DelayTime:create(0.1), cc.ScaleTo:create(0.1, 1)))
    end
    if self.reward_list and self.is_call == TRUE then
        self:updateItemData(self.reward_list)
    elseif self.is_call == FALSE then
        
    end
end


function ActionTimeElfinSummonGainWindow:resgiter_event()
    if self.source_container then
        self.source_container:setTouchEnabled(true)
        self.source_container:addTouchEventListener(function(sender, event_type)    
            if event_type == ccui.TouchEventType.ended then
                playButtonSound2()
                if not self.is_action_ing then
                else
                    self:clickSkilAction()
                end
            end
        end)
    end
    if self.again_btn then
        self.again_btn:addTouchEventListener(function(sender, event_type)
            customClickAction(sender,event_type)
            if event_type == ccui.TouchEventType.ended then
                self.show_elfin_tips = {}
                if self._item_enough then
                    if self.elfin_summon_type == 2 then
                        ElfinController:getInstance():send26551( self.tiems, 4 ,true)
                    else
                        TimesummonController:getInstance():send26522( self.tiems, 4 ,true)
                    end
                    return
                end
                local config = self.config_data[self.group_id]
                if self.tiems == 1 then
                    local num = config.loss_gold_once[1][2]
                    local call_back = function ()
                        if self.elfin_summon_type == 2 then
                            ElfinController:getInstance():send26551( 1, 3 ,true )
                        else
                            TimesummonController:getInstance():send26522( 1, 3 ,true )
                        end
                    end
                    local item_icon_2 = Config.ItemData.data_get_data(config.loss_gold_once[1][1]).icon
                    local val_str = Config.ItemData.data_get_data(config.gain_once[1][1]).name or ""
                    local val_num = config.gain_once[1][2]
                    local call_num = 1
                    self:showAlert(num,item_icon_2,val_str,val_num,call_num,call_back)
                else
                    local num = config.loss_gold_ten[1][2]
                    local call_back = function ()
                        if self.elfin_summon_type == 2 then
                            ElfinController:getInstance():send26551( 10, 3 ,true )
                        else
                            TimesummonController:getInstance():send26522( 10, 3 ,true )
                        end
                        
                    end
                    local item_icon_2 = Config.ItemData.data_get_data(config.loss_gold_ten[1][1]).icon
                    local val_str = Config.ItemData.data_get_data(config.gain_ten[1][1]).name or ""
                    local val_num = config.gain_ten[1][2]
                    local call_num = 10
                    self:showAlert(num,item_icon_2,val_str,val_num,call_num,call_back)
                end
            end
        end)
    end
    if self.comfirm_btn then
        self.comfirm_btn:addTouchEventListener(function(sender, event_type)
            customClickAction(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                controller:openActionTimeElfinSummonGainWindow(false)
            end
        end)
    end

    -- 召唤数据更新
	if not self.elfin_check_show_tips_event then
        self.elfin_check_show_tips_event = GlobalEvent:getInstance():Bind(ElfinEvent.Elfin_Check_Show_Tips_Event,function ()
            delayOnce(function ()
                self:checkElfinTips()
            end,0.1)
        end)
	end
end

-- 检测精灵抽奖弹精灵tip界面
function ActionTimeElfinSummonGainWindow:checkElfinTips()
    if ElfinController:getInstance().elfin_info_wnd and ElfinController:getInstance().elfin_info_wnd:isOpen() == true then
        return
    end
    
	if self.show_elfin_tips and next(self.show_elfin_tips or {}) ~= nil then
		local awards = table.remove(self.show_elfin_tips, 1)
        if awards then
            ElfinController:getInstance():openElfinInfoWindow(true, awards)
		end
	end
end

function ActionTimeElfinSummonGainWindow:close_callback()
    self.show_elfin_tips = {}
    GlobalEvent:getInstance():Fire(PokedexEvent.Call_End_Event)
    if self.item_list and next(self.item_list or {}) ~= nil then
        for i, item in ipairs(self.item_list) do
            if item then
                item:DeleteMe()
            end
        end
        self.item_list = {}
    end
   
    self:showDrawEffect1(false)
    self:showDrawEffect2(false)
    self:showDrawEffect3(false)
    self:showDrawEffect4(false)

    if self.resources_bg_load then
        self.resources_bg_load:DeleteMe()
    end
    self.resources_bg_load = nil

    if self.elfin_check_show_tips_event then
		GlobalEvent:getInstance():UnBind(self.elfin_check_show_tips_event)
		self.elfin_check_show_tips_event = nil
	end

    GlobalEvent:getInstance():Fire(BattleEvent.NEXT_SHOW_RESULT_VIEW)
    controller:openActionTimeElfinSummonGainWindow(false)
end
