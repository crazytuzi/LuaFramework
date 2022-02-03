-- --------------------------------------------------------------------
-- 
-- 
-- @author: mengjiabin@syg.com(必填, 创建模块的人员)
-- @editor: mengjiabin@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      召唤获得界面
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
PartnerSummonGainWindow = PartnerSummonGainWindow or BaseClass(BaseView)

local controller = PartnersummonController:getInstance() 
local model = controller:getModel()

function PartnerSummonGainWindow:__init(is_call)
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.item_list = {} --物品列表
    self.role_list = {}
    self.win_type = WinType.Full
    self.is_action_ing = false
    self.is_call = is_call or TRUE --是否先召唤结算

    self.single_status = 0 --主要是控制再来一次单抽的时候
    self.is_show_item = false
    self.is_show_title = false
    self.is_use_csb = false
    self.point_list = {}
    self.cur_show_card = nil
    self.skill_item_list = {}
    self.role_spine_list = {}
    self.is_show_hero = false
    self.music_info = AudioManager:getInstance():getMusicInfo()
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("partnersummon", "partnersummon"), type = ResourcesType.plist },
        -- { path = PathTool.getPlistImgForDownLoad("bigbg/partnersummon", "partnersummon_call_bg_100"), type = ResourcesType.single},
        { path = PathTool.getPlistImgForDownLoad("bigbg", "bigbg_12"), type = ResourcesType.single },
        { path = PathTool.getPlistImgForDownLoad("bigbg", "txt_cn_bigbg_18"), type = ResourcesType.single },
    }

    self.config_data = Config.RecruitData.data_partnersummon_data
end

function PartnerSummonGainWindow:createRootWnd()
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

    self.image_top_bg = createScale9Sprite(PathTool.getPlistImgForDownLoad("bigbg", "bigbg_12"), SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2 + 55, LOADTEXT_TYPE, self.source_container)
    self.image_top_bg:setAnchorPoint(cc.p(0.5, 0))
    self.image_top_bg:setVisible(false)
    self.image_top_bg:setContentSize(cc.size(SCREEN_WIDTH + 100,220))

    local top_bg_line_1 = createSprite(PathTool.getResFrame("partnersummon", "partnersummon_line"), self.image_top_bg:getContentSize().width/2, self.image_top_bg:getContentSize().height -5, image_top_bg, cc.p(0, 0.5), LOADTEXT_PLIST)
    local top_bg_line_2 = createSprite(PathTool.getResFrame("partnersummon", "partnersummon_line"), self.image_top_bg:getContentSize().width/2,self.image_top_bg:getContentSize().height - 5, image_top_bg, cc.p(0, 0.5), LOADTEXT_PLIST)
    top_bg_line_1:setScaleX(-1)
    self.image_bottom_bg = createScale9Sprite(PathTool.getPlistImgForDownLoad("bigbg", "bigbg_12"),SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2 + 55, LOADTEXT_TYPE, self.source_container)
    self.image_bottom_bg:setContentSize(cc.size(SCREEN_WIDTH + 100, 220))
    self.image_bottom_bg:setScaleY(-1)
    self.image_bottom_bg:setVisible(false)
    self.image_bottom_bg:setAnchorPoint(cc.p(0.5, 0))

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

    self.left_container = ccui.Layout:create()
    self.left_container:setAnchorPoint(cc.p(0.5, 0.5))
    self.left_container:setOpacity(0)
    self.left_container:setContentSize(cc.size(SCREEN_WIDTH, SCREEN_HEIGHT))
    self.left_container:setCascadeOpacityEnabled(true)
    self.left_container:setPosition(cc.p(-self.size.width, SCREEN_HEIGHT / 2))
    self.root_wnd:addChild(self.left_container)
    self.right_container = ccui.Layout:create()
    self.right_container:setAnchorPoint(cc.p(0.5, 0.5))
    self.right_container:setOpacity(0)
    self.right_container:setContentSize(cc.size(SCREEN_WIDTH, SCREEN_HEIGHT))
    self.right_container:setCascadeOpacityEnabled(true)
    self.right_container:setPosition(cc.p(self.size.width, SCREEN_HEIGHT / 2))
    self.root_wnd:addChild(self.right_container)

    self.effect_container = ccui.Layout:create()
    self.effect_container:setAnchorPoint(cc.p(0.5, 0.5))
    self.effect_container:setContentSize(cc.size(SCREEN_WIDTH, SCREEN_HEIGHT))
    self.effect_container:setCascadeOpacityEnabled(true)
    self.effect_container:setPosition(cc.p(self.size.width / 2, SCREEN_HEIGHT / 2))
    self.root_wnd:addChild(self.effect_container,99)

    self.first_container = ccui.Layout:create()
    self.first_container:setAnchorPoint(cc.p(0.5, 0.5))
    self.first_container:setContentSize(cc.size(SCREEN_WIDTH, SCREEN_HEIGHT))
    self.first_container:setCascadeOpacityEnabled(true)
    self.first_container:setPosition(cc.p(self.size.width / 2, SCREEN_HEIGHT / 2))
    self.root_wnd:addChild(self.first_container, 99)

    self.btn_container = ccui.Layout:create()
    self.btn_container:setAnchorPoint(cc.p(0.5, 0.5))
    self.btn_container:setContentSize(cc.size(SCREEN_WIDTH, SCREEN_HEIGHT))
    self.btn_container:setCascadeOpacityEnabled(true)
    self.btn_container:setPosition(cc.p(self.size.width / 2, SCREEN_HEIGHT / 2))
    self.btn_container:setVisible(false)
    self.root_wnd:addChild(self.btn_container, 99)

    self.new_desc_container = ccui.Layout:create()
    self.new_desc_container:setAnchorPoint(cc.p(0.5, 0.5))
    self.new_desc_container:setContentSize(cc.size(SCREEN_WIDTH, SCREEN_HEIGHT))
    self.new_desc_container:setCascadeOpacityEnabled(true)
    self.new_desc_container:setPosition(cc.p(self.size.width / 2, SCREEN_HEIGHT / 2))
    self.root_wnd:addChild(self.new_desc_container, 99)

    --[[self.share_btn = createButton(self.btn_container, TI18N("分享"), 155, 120, cc.size(220, 77), PathTool.getResFrame("partnersummon", "partnersummon_btn_2"), 24)
    self.share_btn:setRichText(TI18N("<div fontColor=#ffffff fontsize=34 outline=2,#823705>分享</div>"))
    self.share_btn:setVisible(false)--]]
    
    -- self.share_label = createRichLabel(32, 1, cc.p(0, 0.5), cc.p(50,60), 0, 0, 500)
    -- local str = string.format(TI18N("首次分享奖励<div fontColor=#ffffff fontsize= 32 >%s</div><img src=%s visible=true scale=1 />"),100,PathTool.getResFrame("partnersummon", "partnersummon_zuan"))
    -- self.share_label:setString(str)
    -- self.share_label:setVisible(false)
    -- self.btn_container:addChild(self.share_label)

    self.comfirm_next_btn = createButton(self.btn_container, TI18N("确定"), 555, 120, cc.size(220, 77), PathTool.getResFrame("partnersummon", "partnersummon_btn"), 24)
    self.comfirm_next_btn:setRichText(TI18N("<div fontColor=#ffffff fontsize=34 outline=2,#823705>确定</div>"))

    -- if IS_SHOW_SHARE == false then
    --     self.comfirm_next_btn:setPosition(self.btn_container:getContentSize().width/2,77)
    -- end

    if self.comfirm_next_btn then
        self.comfirm_next_btn:addTouchEventListener(function(sender, event_type)
            customClickAction(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                --[[if self.is_call == TRUE then
                    self:updateRoleAction()
                else
                    controller:openSummonGainWindow(false)
                end--]]
                controller:openSummonGainWindow(false)
            end
        end)
    end
    -- 引导需要
    --[[local button = self.comfirm_next_btn:getButton()
    button:setName("guildsign_summon_next_btn")--]]

    --[[if self.share_btn then
        self.share_btn:addTouchEventListener(function(sender, event_type)
            customClickAction(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                if FINAL_CHANNEL == "syios_smzhs" then
                    message(TI18N("暂不支持"))
                    return
                end
                self:handleShareStatus(false)
            end
        end)
    end--]]
    if self.is_call == TRUE then
        self.again_btn = createButton(self.item_container,TI18N("再抽一次"),165,-55,cc.size(220,77),PathTool.getResFrame("partnersummon","partnersummon_btn_2"))
        self.again_btn:setRichText(TI18N("<div fontColor=#ffffff fontsize=30 outline=2,#823705>再抽一次</div>"))
        self.item_label = createRichLabel(32, 1, cc.p(0.5, 0.5), cc.p(110,100),0,0,500)
        self.item_label:setString("")
        self.again_btn:addChild(self.item_label)
        self.comfirm_btn = createButton(self.item_container,TI18N("确定"),560,-55,cc.size(220,77),PathTool.getResFrame("partnersummon","partnersummon_btn"))
        self.comfirm_btn:setRichText(TI18N("<div fontColor=#ffffff fontsize=30 outline=2,#823705>确定</div>"))
        
        -- 引导需要
        local button = self.comfirm_btn:getButton()
        button:setName("guildsign_summon_comfirm_btn") 
    end
    self:resgiter_event()
end

function PartnerSummonGainWindow:openRootWnd(data,is_call)
    BattleResultMgr:getInstance():setWaitShowPanel(true)
    self.tiems = data.times
    self.group_id = data.group_id or 0
    self.reward_list = data.rewards
    self.partner_chips = data.partner_chips 
    self.type_flag = data.flag or 0
    self.floor_action, self.light_action = TimesummonController:getInstance():getModel():getEffectAction(data.rewards)
    self.partner_bids = {}
    for i, v in pairs(data.partner_bids) do
        self.partner_bids[v.partner_bid] = v.init_star
    end
    
    if self.type_flag == 0 then
        self.config_data = Config.RecruitData.data_partnersummon_data
    elseif self.type_flag == 1 then
        self.config_data = Config.RecruitHolidayData.data_summon
    elseif self.type_flag == 2 then
        self.config_data = Config.RecruitHolidayEliteData.data_summon
    elseif self.type_flag == 3 then
        self.config_data = Config.RecruitHolidayLuckyData.data_summon
    end

    local config = self.config_data[data.group_id]
    if self.group_id ~= PartnersummonConst.Summon_Type.Score and config then
        if self.type_flag == 0 then
            local one_special_icon_item
            if config.ext_item_once and config.ext_item_once[1] and config.ext_item_once[1][1] then
                one_special_icon_item = config.ext_item_once[1][1]
            end
            local one_icon_special_num = (one_special_icon_item and BackpackController:getInstance():getModel():getBackPackItemNumByBid(one_special_icon_item)) or 0 --单抽拥有特殊道具数量
            local ten_special_icon_item
            if config.ext_item_five and config.ext_item_five[1] and config.ext_item_five[1][1] then
                ten_special_icon_item = config.ext_item_five[1][1]
            end
            local ten_icon_special_num = (ten_special_icon_item and BackpackController:getInstance():getModel():getBackPackItemNumByBid(ten_special_icon_item)) or 0 --多抽拥有特殊道具数量
            if one_icon_special_num > 0 and one_icon_special_num >= config.ext_item_once[1][2] then
                self.one_icon_item = config.ext_item_once[1][1]
            else
                self.one_icon_item = config.item_once[1][1]
            end
            if ten_icon_special_num > 0 and ten_icon_special_num >= config.ext_item_five[1][2] then
                self.five_icon_item = config.ext_item_five[1][1]
            else
                self.five_icon_item = config.item_five[1][1]
            end
        elseif self.type_flag == 1 then
            self.one_icon_item = config.loss_item_once[1][1]
            self.five_icon_item = config.loss_item_ten[1][1]
        elseif self.type_flag == 2 or self.type_flag == 3 then --精英招募
            self.one_icon_item = config.loss_item_once[1][1]
            self.five_icon_item = config.loss_item_ten[1][1]
        end
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

function PartnerSummonGainWindow:callAction(data)
    self.role_list = {}
    local is_init_type = false
    self.is_action_ing = true
    for i, v in ipairs(data.partner_bids) do
        local config = deepCopy(Config.PartnerData.data_partner_base[v.partner_bid])
        -- 只有配置表配置了需要展示的才展示
        if config and config.show_effect == 1 then
            config.star = v.init_star
            -- 预加载英雄音效
            if config.voice ~= "" then
                AudioManager:getInstance():preLoadEffect(AudioManager.AUDIO_TYPE.DUBBING, config.voice)
            end
            table.insert(self.role_list,config)
        end
    end
    self:updateEffectAction()
end

function PartnerSummonGainWindow:updateEffectAction()
    local action = PlayerAction.action
    if self.config_data[self.group_id] then
        action = self.config_data[self.group_id].action_name
    end

    local music_name = "recruit_action"
    if self.group_id and self.group_id ~= 0 then
       music_name = "recruit_"..action
    end
    self.recuit_music = AudioManager:getInstance():playEffect(AudioManager.AUDIO_TYPE.Recruit, music_name, false)

    if self.type_flag == 0 then
        self.first_effect_spine = self:playEffect(Config.EffectData.data_effect_info[120],action,0,0, 99, self.first_container)
        self.first_effect_spine:setAnchorPoint(cc.p(0.5,0.5))
        --self.first_container:setScale(display.getMaxScale())
        local function animationEventFunc(event)
            if event.eventData.name == "appear" then
                if self.first_effect_spine then
                    self.first_effect_spine:runAction(cc.RemoveSelf:create(true))
                    self.first_effect_spine = nil
                end
                self.image_bg:setVisible(true)
                if not self.is_show_item then
                    if next(self.role_list or {}) == nil and self.is_call == TRUE then --表示这个没有英雄抽出
                        self:updateItemData(self.reward_list)
                    else
                        self:showHeroDetailInfo()
                    end
                end
            end
        end
        self.first_effect_spine:registerSpineEventHandler(animationEventFunc, sp.EventType.ANIMATION_EVENT)
    else
        self:handleTimeSummonEffect( true )
    end
end

-- 播放限时召唤特效
function PartnerSummonGainWindow:handleTimeSummonEffect( status )
    if status == true then
        self:handleFloorEffect(true)
        self:handleLightEffect(true)
        if not self.time_summon_bg then
            self.time_summon_bg = createSprite(nil, SCREEN_WIDTH/2, SCREEN_HEIGHT/2, self.first_container, cc.p(0.5, 0.5), LOADTEXT_TYPE, 99)
            self.time_summon_bg:setScale(display.getMaxScale())
            local bg_res = "timesummon_bg"
            if self.group_id then
                if self.type_flag == 3 then
                    bg_res = EliteSummonController:getInstance():getModel():getSummonBg()
                else
                    local data_summon = Config.RecruitHolidayEliteData.data_summon
                    if data_summon and data_summon[self.group_id] and data_summon[self.group_id].call_bg_card and data_summon[self.group_id].call_bg_card ~= "" then
                        bg_res = data_summon[self.group_id].call_bg_card
                    end
                end
            end
            local res_id = PathTool.getPlistImgForDownLoad("bigbg/timesummon",bg_res,true)
            self.summon_bg_load = createResourcesLoad(res_id, ResourcesType.single, function()
                if not tolua.isnull(self.time_summon_bg) and PathTool.isFileExist(res_id) then
                    loadSpriteTexture(self.time_summon_bg, res_id, LOADTEXT_TYPE)
                end
            end, self.summon_bg_load)
        end
        self.time_summon_bg:setVisible(true)
    else
        self:handleFloorEffect(false)
        self:handleLightEffect(false)
        self:handleBookEffect(false)
        if self.time_summon_bg then
            self.time_summon_bg:setVisible(false)
        end
    end
end

-- 地盘特效
function PartnerSummonGainWindow:handleFloorEffect( status )
    if status == true then
        if not tolua.isnull(self.first_container) and self.floor_effect == nil then
            local action = self.floor_action or PlayerAction.action_1
            self.floor_effect = createEffectSpine(Config.EffectData.data_effect_info[671], cc.p(SCREEN_WIDTH/2, 370), cc.p(0.5, 0.5), false, action)
            self.first_container:addChild(self.floor_effect, 100)

            local function animationEventFunc(event)
                if event.eventData.name == "appear" then
                    self:handleBookEffect(true)
                end
            end
            self.floor_effect:registerSpineEventHandler(animationEventFunc, sp.EventType.ANIMATION_EVENT)
        end
    else
        if self.floor_effect then
            self.floor_effect:clearTracks()
            self.floor_effect:removeFromParent()
            self.floor_effect = nil
        end
    end
end

-- 光束特效
function PartnerSummonGainWindow:handleLightEffect( status )
    if status == true then
        if not tolua.isnull(self.first_container) and self.light_effect == nil then
            local function animationEndFunc(event)
                self.image_bg:setVisible(true)
                if self.time_summon_bg then
                    self.time_summon_bg:setVisible(false)
                end
                if not self.is_show_item then
                    if next(self.role_list or {}) == nil and self.is_call == TRUE then --表示这个没有英雄抽出
                        self:updateItemData(self.reward_list)
                    else
                        self:showHeroDetailInfo()
                    end
                end
            end
            local action = self.light_action or PlayerAction.action_1
            self.light_effect = createEffectSpine(Config.EffectData.data_effect_info[670], cc.p(SCREEN_WIDTH/2, 400), cc.p(0.5, 0.5), false, action, animationEndFunc)
            self.first_container:addChild(self.light_effect, 102)
        end
    else
        if self.light_effect then
            self.light_effect:clearTracks()
            self.light_effect:removeFromParent()
            self.light_effect = nil
        end
    end
end

-- 书本特效
function PartnerSummonGainWindow:handleBookEffect( status )
    if status == true then
        if not tolua.isnull(self.first_container) and self.book_effect == nil then
            self.book_effect = createEffectSpine(Config.EffectData.data_effect_info[672], cc.p(SCREEN_WIDTH/2, 400), cc.p(0.5, 0.5), false, PlayerAction.action)
            self.first_container:addChild(self.book_effect, 101)
        end
    else
        if self.book_effect then
            self.book_effect:clearTracks()
            self.book_effect:removeFromParent()
            self.book_effect = nil
        end
    end
end

-- 显示英雄详细信息（立绘等）
function PartnerSummonGainWindow:showHeroDetailInfo(  )
    self:showRareEffect(false)
    local hero_cfg = table.remove(self.role_list, 1)
    if hero_cfg then
        self.cur_show_hero_cfg = hero_cfg
        if not self.hero_info_node then
            self:createHeroInfoNode()
        end

        self.cur_hero_is_five_star = (hero_cfg.star >= 5)
        -- 底盘特效
        self:showDrawEffect3(false)
        self:showDrawEffect4(false)
        if self.cur_hero_is_five_star then
            self:showDrawEffect1(false)
            self:showDrawEffect2(false)
        else
            self:showDrawEffect1(true)
            self:showDrawEffect2(true)
            self:showDrawEffect4(true)
        end

        if self.star_effect then
            self.star_effect:setVisible(false)
        end

        -- 名称
        self.hero_name_txt:setString(hero_cfg.name)
        -- 阵营
        local camp_res = PathTool.getHeroCampTypeIcon(hero_cfg.camp_type)
        loadSpriteTexture(self.hero_camp_sp, camp_res, LOADTEXT_TYPE_PLIST)
        local camp_pos_x = 360 - self.hero_name_txt:getContentSize().width*0.5 - 25
        self.hero_camp_sp:setPosition(cc.p(camp_pos_x, 1195))

        -- 是否显示new标识
        self.is_show_new = false
        local have_num = HeroController:getInstance():getModel():getHeroNumByBid(hero_cfg.bid)
        for _, cfg in pairs(self.role_list) do -- 可能同时召唤出两个一样的英雄
            if cfg.bid == hero_cfg.bid then
                have_num = have_num - 1
            end
        end
        if have_num <= 1 then
            self.is_show_new = true
        end

        -- 星数
        local bg_res_id = PathTool.getPlistImgForDownLoad("bigbg/partnersummon", "partnersummon_call_bg_300", true)
        if hero_cfg.star >= 5 then
            bg_res_id = PathTool.getPlistImgForDownLoad("bigbg/partnersummon", "partnersummon_call_bg_400", true)
            self.hero_type_txt:setTextColor(cc.c4b(250, 235, 173, 255))
            self.hero_share_btn:loadTexture(PathTool.getResFrame("partnersummon", "partnersummon_image_12_s"), LOADTEXT_TYPE_PLIST)
            self.hero_share_btn_label:enableOutline(PartnersummonConst.Outline_Color_1, 2)
            self.hero_comment_btn:loadTexture(PathTool.getResFrame("partnersummon", "partnersummon_image_14_s"), LOADTEXT_TYPE_PLIST)
            self.hero_comment_btn_label:enableOutline(PartnersummonConst.Outline_Color_1, 2)
            self.hero_skill_btn:loadTexture(PathTool.getResFrame("partnersummon", "partnersummon_image_9_s"), LOADTEXT_TYPE_PLIST)
            self.hero_skill_btn_label:enableOutline(PartnersummonConst.Outline_Color_1, 2)
            self.hero_type_bg:loadTexture(PathTool.getResFrame("partnersummon", "partnersummon_image_10_s"), LOADTEXT_TYPE_PLIST)
            self.hero_line:loadTexture(PathTool.getResFrame("partnersummon", "partnersummon_image_13_s"), LOADTEXT_TYPE_PLIST)
            self.hero_desc_bg:loadTexture(PathTool.getResFrame("partnersummon", "partnersummon_image_15_s"), LOADTEXT_TYPE_PLIST)
            loadSpriteTexture(self.hero_share_desc_sp, PathTool.getResFrame("partnersummon", "txt_cn_partnersummon_share_s"), LOADTEXT_TYPE_PLIST)
        else
            self.hero_type_txt:setTextColor(cc.c4b(35, 76, 107, 255))
            self.hero_share_btn:loadTexture(PathTool.getResFrame("partnersummon", "partnersummon_image_12"), LOADTEXT_TYPE_PLIST)
            self.hero_share_btn_label:enableOutline(PartnersummonConst.Outline_Color_2, 2)
            self.hero_comment_btn:loadTexture(PathTool.getResFrame("partnersummon", "partnersummon_image_14"), LOADTEXT_TYPE_PLIST)
            self.hero_comment_btn_label:enableOutline(PartnersummonConst.Outline_Color_2, 2)
            self.hero_skill_btn:loadTexture(PathTool.getResFrame("partnersummon", "partnersummon_image_9"), LOADTEXT_TYPE_PLIST)
            self.hero_skill_btn_label:enableOutline(PartnersummonConst.Outline_Color_2, 2)
            self.hero_type_bg:loadTexture(PathTool.getResFrame("partnersummon", "partnersummon_image_10"), LOADTEXT_TYPE_PLIST)
            self.hero_line:loadTexture(PathTool.getResFrame("partnersummon", "partnersummon_image_13"), LOADTEXT_TYPE_PLIST)
            self.hero_desc_bg:loadTexture(PathTool.getResFrame("partnersummon", "partnersummon_image_15"), LOADTEXT_TYPE_PLIST)
            loadSpriteTexture(self.hero_share_desc_sp, PathTool.getResFrame("partnersummon", "txt_cn_partnersummon_share"), LOADTEXT_TYPE_PLIST)
        end
        self.hero_line:setCapInsets(cc.rect(30,8,1,1))
        if not self.bg_res_id or self.bg_res_id ~= bg_res_id then
            self.bg_res_id = bg_res_id
            self.resources_bg_load = loadSpriteTextureFromCDN(self.image_bg, self.bg_res_id, ResourcesType.single, self.resources_bg_load)
        end

        -- 立绘
        if hero_cfg.draw_res ~= "" then
            local draw_res_path = PathTool.getPlistImgForDownLoad("herodraw/herodrawres", hero_cfg.draw_res, false)
            self.hero_draw_load = loadSpriteTextureFromCDN(self.hero_draw_sp, draw_res_path, ResourcesType.single, self.hero_draw_load)
        end
        
        -- 类型
        local type_res_str = "txt_cn_partnersummon_type_" .. hero_cfg.type
        if hero_cfg.star >= 5 then
            type_res_str = type_res_str .. "_s"
        end
        local type_res = PathTool.getResFrame("partnersummon", type_res_str)
        loadSpriteTexture(self.hero_type_sp, type_res)
        self.hero_type_txt:setString(hero_cfg.hero_pos or "")

        -- 立绘缩放和位置偏移
        self.hero_draw_scale = 1
        if hero_cfg.draw_scale then
            self.hero_draw_scale = hero_cfg.draw_scale/100
        end
        if hero_cfg.draw_offset then
            local offset_x = hero_cfg.draw_offset[1] or 0
            local offset_y = hero_cfg.draw_offset[2] or 0
            self.hero_draw_sp:setPosition(cc.p(offset_x, offset_y))
        end
        self.hero_draw_sp:stopAllActions()

        -- 描述
        local library_cfg = Config.PartnerData.data_partner_library(hero_cfg.bid)
        if library_cfg then
            self.hero_desc_txt:setString(library_cfg.voice_str)
        end

        -- 入场动画
        self.hero_info_node:setVisible(false)
        self.is_show_enter_ani = true -- 标识是否正在显示英雄详细信息的入场动画
        if hero_cfg.star >= 5 then
            self:handleHigherFlickerEffect(true)
        else
            self:handleFlickerEffect(true, PlayerAction.action_1)
        end

        -- 隐藏物品相关UI
        self:hideItemContainer()
    else
        self:updateItemData(self.reward_list)
    end
end

-- 4星立绘的底盘特效
function PartnerSummonGainWindow:showDrawEffect1( status )
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
function PartnerSummonGainWindow:showDrawEffect2( status )
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
function PartnerSummonGainWindow:showDrawEffect3(status)
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
function PartnerSummonGainWindow:showDrawEffect4(status)
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

function PartnerSummonGainWindow:quickShowHeroInfo(  )
    self.hero_draw_sp:stopAllActions()
    self.hero_draw_sp:setOpacity(255)
    self.hero_draw_sp:setScale(self.hero_draw_scale)
    self.hero_comment_btn:stopAllActions()
    self.hero_comment_btn:setOpacity(255)
    self.hero_comment_btn:setScale(1)
    self.hero_share_btn:stopAllActions()
    self.hero_share_btn:setOpacity(255)
    self.hero_share_btn:setScale(1)
    self.hero_camp_sp:stopAllActions()
    self.hero_camp_sp:setOpacity(255)
    local camp_pos_x = 360 - self.hero_name_txt:getContentSize().width*0.5 - 25
    self.hero_camp_sp:setPosition(cc.p(camp_pos_x, 1200))
    self.hero_name_txt:stopAllActions()
    self.hero_name_txt:setOpacity(255)
    self.hero_name_txt:setPosition(cc.p(360, 1200))
    self.hero_type_bg:stopAllActions()
    self.hero_type_bg:setPosition(cc.p(81, 485))
    self.hero_desc_bg:stopAllActions()
    self.hero_desc_bg:setScale(1)
    self.hero_desc_bg:setOpacity(255)
    self.hero_desc_bg:setPosition(cc.p(360, 232))
    self.hero_skill_btn:stopAllActions()
    self.hero_skill_btn:setPosition(cc.p(81, 358))
    self.hero_skill_btn:setOpacity(255)
    self.close_tips_sp:stopAllActions()
    self.close_tips_sp:setOpacity(255)
    self.hero_info_node:setVisible(true)
    -- 是否为新获得的英雄
    if self.is_show_new then
        self.hero_new_sp:setVisible(true)
    else
        self.hero_new_sp:setVisible(false)
    end

    -- 描述
    if self.cur_show_hero_cfg then
        local library_cfg = Config.PartnerData.data_partner_library(self.cur_show_hero_cfg.bid)
        if library_cfg then
            self.hero_desc_txt:setString(library_cfg.voice_str)
        end
        if self.cur_show_hero_cfg.voice ~= "" and self.quick_show_voice then
            self.quick_show_voice = false
            HeroController:getInstance():onPlayHeroVoice(self.cur_show_hero_cfg.voice, self.cur_show_hero_cfg.voice_time)
        end
        if self.cur_show_hero_cfg.rare_flag and self.cur_show_hero_cfg.rare_flag == 1 then
            self:showRareEffect(true)
        end
    end

    self.is_show_enter_ani = false
end

-- 创建英雄详细信息界面
function PartnerSummonGainWindow:createHeroInfoNode(  )
    self.hero_info_node = createCSBNote(PathTool.getTargetCSB("partnersummon/partnersummon_hero_info"))
    self.hero_info_node:setAnchorPoint(cc.p(0.5, 0.5))
    self.hero_info_node:setPosition(cc.p(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2))
    self.draw_container:addChild(self.hero_info_node)

    local container = self.hero_info_node:getChildByName("container")
    container:setName("guildsign_summon_next_btn")
    self.hero_info_container = container

    -- 点击可跳过入场动画
    registerButtonEventListener(container, function (  )
        if self.hero_is_show_share then return end
        if self.is_show_enter_ani then
            self:quickShowHeroInfo()
        else
            self:showHeroDetailInfo()
        end
    end, false)

    local pos_node = container:getChildByName("pos_node")
    self.hero_draw_sp = createSprite(nil, 0, 0, pos_node, cc.p(0.5, 0.5), LOADTEXT_TYPE)
    self.hero_new_sp = container:getChildByName("new_sp")
    self.hero_new_sp:setVisible(false)
    self.hero_line = container:getChildByName("line")
    self.hero_name_txt = container:getChildByName("hero_name_txt")
    self.hero_camp_sp = container:getChildByName("camp_sp")
    self.hero_comment_btn = container:getChildByName("comment_btn")
    self.hero_comment_btn_label = self.hero_comment_btn:getChildByName("label")
    self.hero_comment_btn_label:setString(TI18N("评论"))
    self.hero_share_btn = container:getChildByName("share_btn")
    self.hero_share_btn_label = self.hero_share_btn:getChildByName("label")
    self.hero_share_btn_label:setString(TI18N("分享"))
    self.hero_skill_btn = container:getChildByName("skill_btn")
    self.hero_skill_btn_label = self.hero_skill_btn:getChildByName("label")
    self.hero_skill_btn_label:setString(TI18N("查看技能"))
    self.hero_type_bg = container:getChildByName("type_bg")
    self.hero_type_sp = self.hero_type_bg:getChildByName("type_sp")
    self.hero_type_txt = self.hero_type_bg:getChildByName("type_txt")
    self.hero_desc_bg = container:getChildByName("desc_bg")
    self.hero_desc_txt = self.hero_desc_bg:getChildByName("desc_txt")
    self.hero_desc_txt:setString("")
    --self.new_flag_sp = createSprite(PathTool.getResFrame("partnersummon", "partnersummon_image_16"), 100, 1100, container, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST)

    self.close_tips_sp = container:getChildByName("close_tips_sp")

    -- 分享
    self.hero_share_bg = container:getChildByName("share_bg")
    self.hero_share_desc_sp = self.hero_share_bg:getChildByName("share_desc_sp")
    self.er_wei_ma_sp = self.hero_share_bg:getChildByName("er_wei_ma_sp")
    self.hero_share_bg:getChildByName("er_wei_ma_title"):setString(TI18N("长按识别二维码"))
    self.share_return_btn = self.hero_share_bg:getChildByName("share_return_btn")
    self.share_return_btn:getChildByName("label"):setString(TI18N("返回"))
    self.share_save_btn = self.hero_share_bg:getChildByName("share_save_btn")
    self.share_save_btn:getChildByName("label"):setString(TI18N("保存"))

    registerButtonEventListener(self.hero_comment_btn, handler(self, self.onClickCommentBtn), true)
    registerButtonEventListener(self.hero_share_btn, handler(self, self.onClickShareBtn), true)
    registerButtonEventListener(self.hero_skill_btn, handler(self, self.onClickSkillBtn), true)
    registerButtonEventListener(self.share_return_btn, handler(self, self.onClickShareReturnBtn), true)
    registerButtonEventListener(self.share_save_btn, handler(self, self.onClickShareSaveBtn), true)
end

-- 点击评论按钮
function PartnerSummonGainWindow:onClickCommentBtn(  )
    if self.cur_show_hero_cfg then
        PokedexController:getInstance():openCommentWindow(true, self.cur_show_hero_cfg)
    end
end

-- 点击分享按钮
function PartnerSummonGainWindow:onClickShareBtn(  )
    if FINAL_CHANNEL == "syios_smzhs" then
        message(TI18N("暂不支持"))
        return
    end
    self:showHeroShareLayer(true)
end

-- 点击技能按钮
function PartnerSummonGainWindow:onClickSkillBtn(  )
    if not self.cur_show_hero_cfg  then return end
    local pokedex_config = Config.PartnerData.data_partner_pokedex[self.cur_show_hero_cfg.bid]
    if pokedex_config and pokedex_config[1] then
        local star = pokedex_config[1].star or 1
        HeroController:getInstance():openHeroInfoWindowByBidStar(self.cur_show_hero_cfg.bid, star, true)
    end
end

function PartnerSummonGainWindow:onClickShareReturnBtn(  )
    self:showHeroShareLayer(false)
end

function PartnerSummonGainWindow:onClickShareSaveBtn(  )
    self:shardErweimaImg()
end

-- 切换分享和角色信息界面
function PartnerSummonGainWindow:showHeroShareLayer( status )
    self.hero_share_bg:setVisible(status)
    self.hero_comment_btn:setVisible(not status)
    self.hero_share_btn:setVisible(not status)
    self.hero_skill_btn:setVisible(not status)
    self.hero_desc_bg:setVisible(not status)
    self.close_tips_sp:setVisible(not status)
    if not status and self.is_show_new then
        self.hero_new_sp:setVisible(true)
    else
        self.hero_new_sp:setVisible(false)
    end

    self.hero_is_show_share = status

    if status == true then
        if IS_NEED_SHOW_LOGO ~= false then
            if not self.logo_img then
                self.logo_img = createSprite(PathTool.getLogoRes(), 4, display.getTop() - display.getBottom() - 26,self.hero_info_container,cc.p(0, 1),LOADTEXT_TYPE)
                self.logo_img:setScale(0.45)
            end
            self.logo_img:setVisible(true)
        elseif self.logo_img then
            self.logo_img:setVisible(false)
        end
        
        if IS_NEED_SHOW_ERWEIMA ~= false then
            local apk_data = RoleController:getInstance():getApkData()
            if apk_data then
                download_qrcode_png(apk_data.message.qrcode_url,function(code,filepath)
                    if not tolua.isnull(self.er_wei_ma_sp) then
                        if code == 0 then
                            loadSpriteTexture(self.er_wei_ma_sp, filepath, LOADTEXT_TYPE)
                        else
                            loadSpriteTexture(self.er_wei_ma_sp, PathTool.getResFrame("partnersummon", "partnersummon_erweima"), LOADTEXT_TYPE_PLIST)
                        end
                    end
                end)
            else
                loadSpriteTexture(self.er_wei_ma_sp, PathTool.getResFrame("partnersummon", "partnersummon_erweima"), LOADTEXT_TYPE_PLIST)
            end
            self.er_wei_ma_sp:setVisible(true)
        else
            self.er_wei_ma_sp:setVisible(false)
        end
    else
        if self.logo_img then
            self.logo_img:setVisible(false)
        end
        self.er_wei_ma_sp:setVisible(false)
    end
end

-- 闪光特效
function PartnerSummonGainWindow:handleFlickerEffect(status, action_name)
    if status == true then
        action_name = action_name or PlayerAction.action_1
        if not tolua.isnull(self.draw_container) and self.flicker_effect == nil then
            self.flicker_effect = createEffectSpine(PathTool.getEffectRes(1315), cc.p(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2), cc.p(0.5, 0.5), false, action_name)
            self.draw_container:addChild(self.flicker_effect, 99)

            local function animationEventFunc(event)
                if event.eventData.name == "appear" then
                    self:showHeroInfoEnterAni()
                end
            end
            self.flicker_effect:registerSpineEventHandler(animationEventFunc, sp.EventType.ANIMATION_EVENT)
        elseif self.flicker_effect then
            self.flicker_effect:setToSetupPose()
            self.flicker_effect:setAnimation(0, action_name, false)
        end
    else
        if self.flicker_effect then
            self.flicker_effect:clearTracks()
            self.flicker_effect:removeFromParent()
            self.flicker_effect = nil
        end
    end
end

-- 五星英雄闪光特效
function PartnerSummonGainWindow:handleHigherFlickerEffect(status)
    if status == true then
        if not tolua.isnull(self.draw_container) and self.higher_flicker_effect == nil then
            self.higher_flicker_effect = createEffectSpine(PathTool.getEffectRes(1317), cc.p(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2), cc.p(0.5, 0.5), false, PlayerAction.action_1)
            self.draw_container:addChild(self.higher_flicker_effect, 98)

            local function animationEventFunc(event)
                if event.eventData.name == "appear" then
                    self:handleFlickerEffect(true, PlayerAction.action_2)
                    self:showDrawEffect3(true)
                    self:showDrawEffect4(true)
                end
            end
            self.higher_flicker_effect:registerSpineEventHandler(animationEventFunc, sp.EventType.ANIMATION_EVENT)
        elseif self.higher_flicker_effect then
            self.higher_flicker_effect:setToSetupPose()
            self.higher_flicker_effect:setAnimation(0, PlayerAction.action_1, false)
        end
    else
        if self.higher_flicker_effect then
            self.higher_flicker_effect:clearTracks()
            self.higher_flicker_effect:removeFromParent()
            self.higher_flicker_effect = nil
        end
    end
end

-- 英雄星数特效
function PartnerSummonGainWindow:showStarEffect(status, action)
    if status == true then
        action = action or PlayerAction.action_1
        if not tolua.isnull(self.draw_container) and self.star_effect == nil then
            self.star_effect = createEffectSpine(PathTool.getEffectRes(1314), cc.p(SCREEN_WIDTH / 2, 1162), cc.p(0.5, 0.5), false, action)
            self.draw_container:addChild(self.star_effect)
        elseif self.star_effect then
            self.star_effect:setToSetupPose()
            self.star_effect:setAnimation(0, action, false)
            self.star_effect:setVisible(true)
        end
    else
        if self.star_effect then
            self.star_effect:clearTracks()
            self.star_effect:removeFromParent()
            self.star_effect = nil
        end
    end
end

-- 超稀有标识
function PartnerSummonGainWindow:showRareEffect(status)
    if status == true then
        if not tolua.isnull(self.draw_container) and self.rare_effect == nil then
            self.rare_effect = createEffectSpine(PathTool.getEffectRes(1316), cc.p(540, 1200), cc.p(0.5, 0.5), false, PlayerAction.action)
            self.draw_container:addChild(self.rare_effect)
        end
    else
        if self.rare_effect then
            self.rare_effect:clearTracks()
            self.rare_effect:removeFromParent()
            self.rare_effect = nil
        end
    end
end

-- 英雄详情界面的入场动画
function PartnerSummonGainWindow:showHeroInfoEnterAni(  )
    self.hero_name_txt:setPositionY(1155)
    self.hero_name_txt:setOpacity(0)
    self.hero_camp_sp:setPositionY(1155)
    self.hero_camp_sp:setOpacity(0)
    self.hero_comment_btn:setOpacity(0)
    self.hero_share_btn:setOpacity(0)
    self.hero_skill_btn:setPositionX(-80)
    self.hero_type_bg:setPositionX(-80)
    self.hero_desc_bg:setScale(0.3)
    self.hero_desc_bg:setOpacity(0)
    self.hero_desc_bg:setPositionY(432)
    self.close_tips_sp:setOpacity(0)
    self.hero_draw_sp:setScale(0.6)
    self.hero_draw_sp:setOpacity(0)
    self.hero_info_node:setVisible(true)
    -- 是否为新获得的英雄
    if self.is_show_new then
        self.hero_new_sp:setVisible(true)
        self.hero_new_sp:setOpacity(0)
    else
        self.hero_new_sp:setVisible(false)
    end
    self.quick_show_voice = true -- 点击快速展示时，是否播放英雄的音效

    self.card_music = AudioManager:getInstance():playEffect(AudioManager.AUDIO_TYPE.Recruit, "result_01", false)

    -- 星数
    local star_action = PlayerAction.action_1
    if self.cur_hero_is_five_star then
        star_action = PlayerAction.action_2
    end
    self:showStarEffect(true, star_action)

    self.hero_draw_sp:runAction(cc.Sequence:create(cc.Spawn:create(cc.ScaleTo:create(0.1, self.hero_draw_scale + 0.2), cc.FadeIn:create(0.1)), cc.ScaleTo:create(0.05, self.hero_draw_scale), cc.CallFunc:create(function ()
        local draw_sequence = cc.Sequence:create(cc.MoveBy:create(1.0, cc.p(0, 10)), cc.MoveBy:create(1.0, cc.p(0, -10)))
        self.hero_draw_sp:runAction(cc.RepeatForever:create(draw_sequence))
    end)))
    self.hero_name_txt:runAction(cc.Spawn:create(cc.FadeIn:create(0.25), cc.MoveTo:create(0.25, cc.p(360, 1200))))
    local camp_pos_x = 360 - self.hero_name_txt:getContentSize().width*0.5 - 25
    self.hero_camp_sp:runAction(cc.Spawn:create(cc.FadeIn:create(0.25), cc.MoveTo:create(0.25, cc.p(camp_pos_x, 1200))))
    self.hero_comment_btn:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.Spawn:create(cc.FadeIn:create(0.15), cc.ScaleTo:create(0.1, 2.0)), cc.ScaleTo:create(0.05, 1.0)))
    self.hero_share_btn:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.Spawn:create(cc.FadeIn:create(0.15), cc.ScaleTo:create(0.1, 2.0)), cc.ScaleTo:create(0.05, 1.0)))
    if self.is_show_new then
        self.hero_new_sp:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.Spawn:create(cc.FadeIn:create(0.15), cc.ScaleTo:create(0.1, 2.0)), cc.ScaleTo:create(0.05, 1.0)))
    end
    self.hero_skill_btn:runAction(cc.MoveTo:create(0.3, cc.p(81, 358)))
    self.hero_type_bg:runAction(cc.MoveTo:create(0.3, cc.p(81, 485)))
    self.hero_desc_bg:runAction(cc.Sequence:create(cc.DelayTime:create(0.3), cc.Spawn:create(cc.FadeIn:create(0.1), cc.MoveTo:create(0.1, cc.p(360, 232)), cc.ScaleTo:create(0.1, 1.2)), cc.ScaleTo:create(0.05, 1.0), cc.CallFunc:create(function ()
        if self.cur_show_hero_cfg then
            if self.cur_show_hero_cfg.voice ~= "" then
                self.quick_show_voice = false
                HeroController:getInstance():onPlayHeroVoice(self.cur_show_hero_cfg.voice, self.cur_show_hero_cfg.voice_time)
                if self.hero_music ~= nil then
                    AudioManager:getInstance():removeEffectByData(self.hero_music)
                    self.hero_music = nil
                end
                self.hero_music = AudioManager:getInstance():playEffect(AudioManager.AUDIO_TYPE.DUBBING,self.cur_show_hero_cfg.voice,false)
            end
            if self.cur_show_hero_cfg.rare_flag and self.cur_show_hero_cfg.rare_flag == 1 then
                self:showRareEffect(true)
            end
        end
    end)))
    self.close_tips_sp:runAction(cc.Sequence:create(cc.DelayTime:create(0.4), cc.FadeIn:create(0.2), cc.CallFunc:create(function (  )
        self.is_show_enter_ani = false
    end)))
end

--==============================--
--desc:分享
--time:2019-01-26 02:16:15
--@return 
--==============================--
function PartnerSummonGainWindow:shardErweimaImg()
    if not IS_IOS_PLATFORM and callFunc("checkWrite") == "false" then return end
	self:changeShardStatus(false)
	local save_name = "sy_gameshard_image"
	if getRandomSaveName then
		save_name = getRandomSaveName()
	end
	local fileName = cc.FileUtils:getInstance():getWritablePath() .. save_name .. ".png"
	delayOnce(function()
		cc.utils:captureScreen(function(succeed)
			if succeed then
				saveImageToPhoto(fileName)
				self:changeShardStatus(true)
			else
				message("保存失败")
			end
		end, fileName)
	end, 0.01)
end

function PartnerSummonGainWindow:changeShardStatus(status)
    if tolua.isnull(self.share_layout) then return end
    self.share_layout:setVisible(status)
end

function PartnerSummonGainWindow:wxShare(share_type)
    local filename = cc.FileUtils:getInstance():getWritablePath().."CaptureScreen.png"
    cc.utils:captureScreen(function (succeed)
        if succeed then
            if self.share_layout and not tolua.isnull(self.share_layout) then
                self.share_layout:setVisible(true)
            end
            wxSharePhoto(TI18N("我是测试title"),TI18N("我是测试内容"),filename,nil,share_type)
        else
            message(TI18N("操作失败"))
        end
    end,filename)
end

function PartnerSummonGainWindow:handleShareStatus(status)
    if self.btn_container and not tolua.isnull(self.btn_container) then
        self.btn_container:setVisible(status)
    end
    self:shareLayout(not status)
    self.title_bg:setVisible(status)
    if self.skill_item_list and next(self.skill_item_list or {}) ~= nil then
        for i, v in ipairs(self.skill_item_list) do
            if v then
                v:setVisible(status)
            end
        end
    end
end

--更新物品列表
function PartnerSummonGainWindow:updateItemData(data)
    if self.hero_info_node then
        self.hero_info_node:setVisible(false)
    end
    self:showStarEffect(false)
    self.is_action_ing = false
    self.effect_container:setVisible(false)
    self.left_container:setVisible(false)
    self.left_container:setOpacity(0)
    self.right_container:setVisible(false)
    self.right_container:setOpacity(0)
    self.item_container:setVisible(true)
    self.image_top_bg:setVisible(true)
    self.new_desc_container:setVisible(false)
    self.first_container:setVisible(false)
    --self.image_star_bg:setVisible(true)
    self.image_bottom_bg:setVisible(true)
    --self.desc_label:setVisible(true)
    self.image_bg:setVisible(true)
    if self.cur_hero_is_five_star then
        self:showDrawEffect1(false)
        self:showDrawEffect2(false)
        self:showDrawEffect3(true)   
    else
        self:showDrawEffect1(true)
        self:showDrawEffect2(true)
        self:showDrawEffect3(false)
    end
    self:showDrawEffect4(true)
    self.title_bg:setVisible(true)
    self.btn_container:setVisible(false)
    local sum = #data
    local col = 5
    -- 算出最多多少行
    self.row = math.ceil(sum / col)
    self.space = 20
    local max_height = self.space + (self.space + 20 + BackPackItem.Height) * self.row
    self.max_height = math.max(max_height, self.item_container:getContentSize().height)
    -- self.scroll_view:setInnerContainerSize(cc.size(self.scroll_view:getContentSize().width, self.max_height))
    self.title_bg:setPosition(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2 + 320)
    if sum >= col then
        sum = col
    end
    local total_width = sum * BackPackItem.Width + (sum - 1) * self.space
    self.start_x = (self.item_container:getContentSize().width - total_width) * 0.5
    -- 只有一行的话
    if self.row == 1 then
        self.start_y = self.max_height * 0.5 + 65
    else
        self.start_y = self.max_height - self.space - BackPackItem.Height * 0.5
    end
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
    end
    --[[if self.hero_music ~= nil then
        AudioManager:getInstance():removeEffectByData(self.hero_music)
    end--]]
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
                        if item.config and item.config.is_effect and item.config.is_effect == 1 then
                            local effect_id = 156
                            local action = PlayerAction.action_2
                            if item.config.quality >= 4 then
                                action = PlayerAction.action_1
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
            self.again_btn:setRichText(TI18N("<div fontColor=#ffffff fontsize=34 outline=2,#823705>再抽十次</div>"))
            self:updateTenSummon()
        else
            self.again_btn:setRichText(TI18N("<div fontColor=#ffffff fontsize=34 outline=2,#823705>再抽一次</div>"))
            self:updateSingleSummon()
        end
    else 
    end
end

-- 隐藏物品列表展示
function PartnerSummonGainWindow:hideItemContainer(  )
    self.item_container:setVisible(false)
    self.image_top_bg:setVisible(false)
    self.image_bottom_bg:setVisible(false)
end

function PartnerSummonGainWindow:updateTenSummon(  )
    if self.type_flag == 1 and self.item_label then
        local summon_have_num = BackpackController:getInstance():getModel():getItemNumByBid(self.five_icon_item)
        local item_icon = Config.ItemData.data_get_data(self.five_icon_item).icon
        if summon_have_num >= self.tiems then
            self._item_enough = true
            self.item_label:setString(string.format(TI18N("<img src=%s visible=true scale=0.5 /><div fontColor=#35ff14 outline=2,#000000>%d</div><div fontColor=#ffffff outline=2,#000000>/%d</div>"), PathTool.getItemRes(item_icon), summon_have_num, self.tiems))
        else
            self._item_enough = false
            self.item_label:setString(string.format(TI18N("<img src=%s visible=true scale=0.5 /><div fontColor=#e14737 outline=2,#000000>%d</div><div fontColor=#ffffff outline=2,#000000>/%d</div>"), PathTool.getItemRes(item_icon), summon_have_num, self.tiems))
        end
        return
    elseif (self.type_flag == 2 or self.type_flag == 3) and self.item_label then --精英招募
        local summon_have_num = BackpackController:getInstance():getModel():getItemNumByBid(self.five_icon_item)
        local item_icon = Config.ItemData.data_get_data(self.five_icon_item).icon
        if summon_have_num >= self.tiems then
            self._item_enough = true
            self.item_label:setString(string.format(TI18N("<img src=%s visible=true scale=0.5 /><div fontColor=#35ff14 outline=2,#000000>%d</div><div fontColor=#ffffff outline=2,#000000>/%d</div>"), PathTool.getItemRes(item_icon), summon_have_num, self.tiems))
        else
            self._item_enough = false
            self.item_label:setString(string.format(TI18N("<img src=%s visible=true scale=0.5 /><div fontColor=#e14737 outline=2,#000000>%d</div><div fontColor=#ffffff outline=2,#000000>/%d</div>"), PathTool.getItemRes(item_icon), summon_have_num, self.tiems))
        end
        return
    end

    if self.group_id == PartnersummonConst.Summon_Type.Score then
        self.item_label:setString("")
        return
    end

    local group_data = PartnersummonController:getInstance():getModel():getSummonGroupDataByGroupId(self.group_id)
    local config = group_data.info_data or {}

    local item_icon = Config.ItemData.data_get_data(self.five_icon_item).icon
    local need_count = config.item_five[1][2]
    local have_count = 0
    if self.group_id == PartnersummonConst.Summon_Type.Friend then
        local role_vo = RoleController:getInstance():getRoleVo()
        have_count = role_vo.friend_point
    else
        have_count = BackpackController:getInstance():getModel():getBackPackItemNumByBid(self.five_icon_item)
    end
    local str = string.format(TI18N("<img src=%s visible=true scale=0.5 /><div fontColor=#35ff14 outline=2,#000000>%d</div><div fontColor=#ffffff outline=2,#000000>/%d</div>"), PathTool.getItemRes(item_icon), have_count, need_count)
    if have_count < need_count then
        str = string.format(TI18N("<img src=%s visible=true scale=0.5 /><div fontColor=#e14737 outline=2,#000000>%d</div><div fontColor=#ffffff outline=2,#000000>/%d</div>"), PathTool.getItemRes(item_icon), have_count, need_count)
    end
    self.item_label:setString(str)
end

function PartnerSummonGainWindow:updateSingleSummon()
    if not self.one_icon_item then return end
    if self.type_flag == 1 and self.item_label then
        local summon_have_num = BackpackController:getInstance():getModel():getItemNumByBid(self.one_icon_item)
        local item_cfg = Config.ItemData.data_get_data(self.one_icon_item)
        if not item_cfg then return end
        local item_icon = item_cfg.icon
        if summon_have_num >= self.tiems then
            self._item_enough = true
            self.item_label:setString(string.format(TI18N("<img src=%s visible=true scale=0.5 /><div fontColor=#35ff14 outline=2,#000000>%d</div><div fontColor=#ffffff outline=2,#000000>/%d</div>"), PathTool.getItemRes(item_icon), summon_have_num, self.tiems))
        else
            self._item_enough = false
            self.item_label:setString(string.format(TI18N("<img src=%s visible=true scale=0.5 /><div fontColor=#e14737 outline=2,#000000>%d</div><div fontColor=#ffffff outline=2,#000000>/%d</div>"), PathTool.getItemRes(item_icon), summon_have_num, self.tiems))
        end
        return
    elseif (self.type_flag == 2 or self.type_flag == 3) and self.item_label then --精英招募
        local summon_have_num = BackpackController:getInstance():getModel():getItemNumByBid(self.one_icon_item)
        local item_cfg = Config.ItemData.data_get_data(self.one_icon_item)
        if not item_cfg then return end
        local item_icon = item_cfg.icon
        if summon_have_num >= self.tiems then
            self._item_enough = true
            self.item_label:setString(string.format(TI18N("<img src=%s visible=true scale=0.5 /><div fontColor=#35ff14 outline=2,#000000>%d</div><div fontColor=#ffffff outline=2,#000000>/%d</div>"), PathTool.getItemRes(item_icon), summon_have_num, self.tiems))
        else
            self._item_enough = false
            self.item_label:setString(string.format(TI18N("<img src=%s visible=true scale=0.5 /><div fontColor=#e14737 outline=2,#000000>%d</div><div fontColor=#ffffff outline=2,#000000>/%d</div>"), PathTool.getItemRes(item_icon), summon_have_num, self.tiems))
        end
        return
    end
    if self.group_id == PartnersummonConst.Summon_Type.Score then
        self.item_label:setString("")
        return
    end

    local group_data = PartnersummonController:getInstance():getModel():getSummonGroupDataByGroupId(self.group_id)
    local config = group_data.info_data or {}
    local proto_data = group_data.proto_data or {}

    if self.group_id == PartnersummonConst.Summon_Type.Friend then
        local role_vo = RoleController:getInstance():getRoleVo()
        self.one_icon_num = role_vo.friend_point
    else
        self.one_icon_num = BackpackController:getInstance():getModel():getBackPackItemNumByBid(self.one_icon_item)
    end

    local free_count = 0
    for k,v in pairs(proto_data.draw_list or {}) do
        if v.times == 1 and v.kv_list then
            for _,kv in pairs(v.kv_list) do
                if kv.key == PartnersummonConst.Recruit_Key.Free_Count then
                    free_count = kv.val
                    break
                end
            end
            break
        end
    end
    local desc_str = ""
    if free_count > 0 then --如果免费CD结束时间为0
        self.single_status = PartnersummonConst.Status.Free
        desc_str = TI18N("本次免费")
    elseif config then
        local one_special_icon_item
        if config.ext_item_once and config.ext_item_once[1] and config.ext_item_once[1][1] then
            one_special_icon_item = config.ext_item_once[1][1]
        end
        local one_icon_special_num = (one_special_icon_item and BackpackController:getInstance():getModel():getBackPackItemNumByBid(one_special_icon_item)) or 0 --单抽拥有特殊道具数量
        local special_need_count = (one_special_icon_item and config.ext_item_once[1][2]) or 0
        local item_icon = Config.ItemData.data_get_data(config.item_once[1][1]).icon
        local special_icon = Config.ItemData.data_get_data(self.one_icon_item).icon
        local need_count = config.item_once[1][2]
        if self.one_icon_num < need_count and (one_icon_special_num < special_need_count or special_need_count == 0) then --特殊道具和道具数量不够
            if self.group_id == PartnersummonConst.Summon_Type.Advanced then -- 只有高级召唤才能使用钻石兑换
                self.single_status = PartnersummonConst.Status.Gold
            else
                self.single_status = PartnersummonConst.Status.Item
            end
            desc_str = string.format(TI18N("<img src=%s visible=true scale=0.5 /><div fontColor=#e14737 outline=2,#000000>%d</div><div fontColor=#ffffff outline=2,#000000>/%d</div>"), PathTool.getItemRes(item_icon), self.one_icon_num, need_count)          
        elseif one_icon_special_num >= special_need_count and special_need_count ~= 0 then
            self.single_status = PartnersummonConst.Status.special
            desc_str = string.format(TI18N("<img src=%s visible=true scale=0.5 /><div fontColor=#35ff14 outline=2,#000000>%d</div><div fontColor=#ffffff outline=2,#000000>/%d</div>"), PathTool.getItemRes(special_icon), self.one_icon_num, special_need_count)
        else
            self.single_status = PartnersummonConst.Status.Item
            desc_str = string.format(TI18N("<img src=%s visible=true scale=0.5 /><div fontColor=#35ff14 outline=2,#000000>%d</div><div fontColor=#ffffff outline=2,#000000>/%d</div>"), PathTool.getItemRes(item_icon), self.one_icon_num, need_count)
        end
    end
    if self.item_label then
        self.item_label:setString(desc_str)
    end
end

function PartnerSummonGainWindow:sendFiveSummon()
    if self.group_id == PartnersummonConst.Summon_Type.Score then
        return
    end
    local five_icon_num = BackpackController:getInstance():getModel():getBackPackItemNumByBid(self.five_icon_item)
    local config = self.config_data[self.group_id]
    if config then
        if five_icon_num <= 0 and self.group_id == PartnersummonConst.Summon_Type.Advanced then
            local call_back = function()
                PartnersummonController:getInstance():send23201(self.group_id,self.tiems, 3)
            end
            if self.type_flag == 0 then
                local item_icon = Config.ItemData.data_get_data(config.item_five[1][1]).icon
                local item_icon_2 = Config.ItemData.data_get_data(config.exchange_five[1][1]).icon
                local num = config.exchange_five[1][2]
                local val_str = Config.ItemData.data_get_data(config.exchange_five_gain[1][1]).name or ""
                local val_num = config.exchange_five_gain[1][2]
                local call_num = 10
                self:showAlert(num, item_icon_2, val_str, val_num, call_num,call_back)
            elseif self.type_flag == 1 then
                local item_icon = Config.ItemData.data_get_data(config.loss_item_ten[1][1]).icon
                local item_icon_2 = Config.ItemData.data_get_data(config.loss_gold_ten[1][1]).icon
                local num = config.loss_gold_ten[1][2]
                local val_str = Config.ItemData.data_get_data(config.gain_ten[1][1]).name or ""
                local val_num = config.gain_ten[1][2]
                local call_num = 10
                self:showAlert(num, item_icon_2, val_str, val_num, call_num,call_back)
            end
        else
            local one_special_icon_item
            if config.ext_item_five and config.ext_item_five[1] and config.ext_item_five[1][1] then
                one_special_icon_item = config.ext_item_five[1][1]
            end
            local one_icon_special_num = (one_special_icon_item and BackpackController:getInstance():getModel():getBackPackItemNumByBid(one_special_icon_item)) or 0 --单抽拥有特殊道具数量
            if one_special_icon_item and one_icon_special_num >= config.ext_item_five[1][2] then --特殊道具
                PartnersummonController:getInstance():send23201(self.group_id,self.tiems, 5)
            else
                PartnersummonController:getInstance():send23201(self.group_id,self.tiems, 4)
            end
        end
    end
end

function PartnerSummonGainWindow:showAlert(num, item_icon_2, val_str, val_num, call_num,call_back)
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


function PartnerSummonGainWindow:playEffect(effect_id, action, x, y, zorder, parent,is_loop)
    zorder = zorder or 1
    is_loop = is_loop or false
    local effect = createEffectSpine(effect_id, cc.p(x, y), cc.p(0.5, 0.5), is_loop, action, nil, cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888)
    parent:addChild(effect, zorder)
    return effect
end

function PartnerSummonGainWindow:clickSkilAction(is_click)
    if self.is_action_ing ==  false then
        return 
    end
    self.is_show_item = true
    if self.role_spine_list and next(self.role_spine_list or {}) ~= nil then
        for i, spine in ipairs(self.role_spine_list) do
            if spine then
                spine:stopAllActions()
            end
        end
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
        self:showHeroDetailInfo()
    end
end

function PartnerSummonGainWindow:quickShowHero(is_normal_click)
    self.is_action_ing = false
    self.is_normal_click = is_normal_click  or false
    self.image_bg:setVisible(true)
    if self.cur_hero_is_five_star then
        self:showDrawEffect1(false)
        self:showDrawEffect2(false)
        self:showDrawEffect3(true)
    else
        self:showDrawEffect1(true)
        self:showDrawEffect2(true)
        self:showDrawEffect3(false)
    end
    self:showDrawEffect4(true)
    if self.first_effect_spine then
        self.first_effect_spine:runAction(cc.RemoveSelf:create(true))
        self.first_effect_spine = nil
    end
    self:handleTimeSummonEffect( false )
    --[[if self.role_list and next(self.role_list or {}) ~= nil then
        local count = 0
        local effect_action = PlayerAction.action_3
        for i, v in ipairs(self.role_list) do
            if not self.role_spine_list[i] then
                local size = self.effect_container:getContentSize()
                local spine_sp = createSprite(PathTool.getPlistImgForDownLoad("bigbg/partnercard", "partnercard_10101"), size.width / 2, size.height / 2 + 170, self.effect_container, cc.p(0.5, 0.5), LOADTEXT_TYPE)
                spine_sp:setOpacity(0)
                spine_sp:setVisible(true)
                local container = self:createExtendCard(v)
                container:setVisible(false)
                spine_sp:addChild(container)
                spine_sp.container = container
                v.effect_action = effect_action
                local base_data = Config.PartnerData.data_partner_star(getNorKey(v.bid, v.star))
                spine_sp.data = v
                spine_sp.base_data = base_data
                self.role_spine_list[i] = spine_sp
                count = count + 1
            end
        end
    end--]]
    self:showHeroDetailInfo()
end

function PartnerSummonGainWindow:resgiter_event()
    if self.source_container then
        self.source_container:setTouchEnabled(true)
        self.source_container:addTouchEventListener(function(sender, event_type)    
            if event_type == ccui.TouchEventType.ended then
                playButtonSound2()
                if not self.is_action_ing then
                else
                    if self.role_list and next(self.role_list or {}) ~=  nil and self.is_action_ing == true then
                        if self.is_show_hero == false then
                            self:quickShowHero(true)
                        end
                    else
                        self:clickSkilAction()
                    end
                end
            end
        end)
    end
    if self.again_btn then
        self.again_btn:addTouchEventListener(function(sender, event_type)
            customClickAction(sender,event_type)
            if event_type == ccui.TouchEventType.ended then
                if self.type_flag == 0 then
                    if self.tiems == 10 then  --10连再抽一次
                        self:sendFiveSummon()
                    else
                        if self.single_status ~= 0 then
                            if self.single_status == PartnersummonConst.Status.Free then --免费
                                PartnersummonController:getInstance():send23201(self.group_id, 1, 1)
                            elseif self.single_status == PartnersummonConst.Status.special then --特殊道具
                                PartnersummonController:getInstance():send23201(self.group_id, 1, 5)
                            elseif self.single_status == PartnersummonConst.Status.Item then --道具
                                PartnersummonController:getInstance():send23201(self.group_id, 1, 4)
                            elseif self.single_status == PartnersummonConst.Status.Gold then -- 钻石
                                self:showSingleAlert()
                            end
                        end
                    end
                else
                    if self._item_enough then
                        if self.type_flag == 2 then
                            if self.tiems == 1 then
                                EliteSummonController:getInstance():send23221(1,4)
                            elseif self.tiems == 10 then
                                EliteSummonController:getInstance():send23221(10,4)
                            end
                        elseif self.type_flag == 3 then
                            if self.tiems == 1 then
                                EliteSummonController:getInstance():send23231(1,4)
                            elseif self.tiems == 10 then
                                EliteSummonController:getInstance():send23231(10,4)
                            end
                        else
                            TimesummonController:getInstance():requestTimeSummon( self.tiems, 4 )
                        end
                        return
                    end
                    local config = self.config_data[self.group_id]
                    if self.tiems == 1 then
                        local num = config.loss_gold_once[1][2]
                        local call_back = function ()
                            if self.type_flag == 1 then
                                TimesummonController:getInstance():requestTimeSummon( 1, 3 )
                            elseif self.type_flag == 2 then --精英招募
                                EliteSummonController:getInstance():send23221(1,3)
                            elseif self.type_flag == 3 then --自选精英招募
                                EliteSummonController:getInstance():send23231(1,3)
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
                            if self.type_flag == 1 then
                                TimesummonController:getInstance():requestTimeSummon( 10, 3 )
                            elseif self.type_flag == 2 then --精英招募
                                EliteSummonController:getInstance():send23221(10,3)
                            elseif self.type_flag == 3 then --自选精英招募
                                EliteSummonController:getInstance():send23231(10,3)
                            end
                        end
                        local item_icon_2 = Config.ItemData.data_get_data(config.loss_gold_ten[1][1]).icon
                        local val_str = Config.ItemData.data_get_data(config.gain_ten[1][1]).name or ""
                        local val_num = config.gain_ten[1][2]
                        local call_num = 10
                        self:showAlert(num,item_icon_2,val_str,val_num,call_num,call_back)
                    end
                end
            end
        end)
    end
    if self.comfirm_btn then
        self.comfirm_btn:addTouchEventListener(function(sender, event_type)
            customClickAction(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                controller:openSummonGainWindow(false)
                -- ActionController:getInstance():checkOpenActionLimitGiftMainWindow()
            end
        end)
    end
    if not self.update_summon_data_event then
        self.update_summon_data_event = GlobalEvent:getInstance():Bind(PartnersummonEvent.updateSummonDataEvent, function(data)
            if data then
                self:updateSingleSummon()
            end
        end)
    end
    if not self.update_share_data_event then
        self.update_share_data_event = GlobalEvent:getInstance():Bind(PartnersummonEvent.updateSummonShareDataEvent, function()
            self:updateShareLable()
        end)
    end
end

-- 钻石召唤
function PartnerSummonGainWindow:showSingleAlert()
    local config = self.config_data[self.group_id]
    if config and self.group_id == PartnersummonConst.Summon_Type.Advanced then
        local call_back = function()
            PartnersummonController:getInstance():send23201(self.group_id, 1, 3)
        end
        if self.type_flag == 0 then
            local item_icon = Config.ItemData.data_get_data(config.item_once[1][1]).icon
            local item_icon_2 = Config.ItemData.data_get_data(config.exchange_once[1][1]).icon
            local num = config.exchange_once[1][2] 
            local val_str = Config.ItemData.data_get_data(config.exchange_once_gain[1][1]).name or ""
            local val_num = config.exchange_once_gain[1][2]
            local call_num = 1
            local have_sum = RoleController:getInstance():getRoleVo().gold + RoleController:getInstance():getRoleVo().red_gold
            local str_ = string.format(TI18N("是否使用<img src=%s visible=true scale=0.3 /><div fontColor=#289b14 fontsize= 26>%s</div><div fontColor=#764519>(拥有:</div><div fontColor=#289b14 fontsize= 26>%s</div><div fontColor=#764519>)\n</div>"), PathTool.getItemRes(item_icon_2), num, have_sum)
            local str = str_ .. string.format(TI18N("<div fontColor=#764519>购买</div><div fontColor=#289b14 fontsize= 26>%s</div><div fontColor=#764519>%s(同时附赠</div><div fontColor=#289b14 fontsize= 26>%s</div><div fontColor=#764519>次招募)</div>"), val_num, val_str, call_num)   
            CommonAlert.show(str, TI18N("确定"), call_back, TI18N("取消"), nil, CommonAlert.type.rich, nil)
        elseif self.type_flag == 1 then
            local item_icon = Config.ItemData.data_get_data(config.loss_item_once[1][1]).icon
            local item_icon_2 = Config.ItemData.data_get_data(config.loss_gold_once[1][1]).icon
            local num = config.loss_gold_once[1][2] 
            local val_str = Config.ItemData.data_get_data(config.gain_once[1][1]).name or ""
            local val_num = config.gain_once[1][2]
            local call_num = 1
            local have_sum = RoleController:getInstance():getRoleVo().gold + RoleController:getInstance():getRoleVo().red_gold
            local str_ = string.format(TI18N("是否使用<img src=%s visible=true scale=0.3 /><div fontColor=#289b14 fontsize= 26>%s</div><div fontColor=#764519>(拥有:</div><div fontColor=#289b14 fontsize= 26>%s</div><div fontColor=#764519>)\n</div>"), PathTool.getItemRes(item_icon_2), num, have_sum)
            local str = str_ .. string.format(TI18N("<div fontColor=#764519>购买</div><div fontColor=#289b14 fontsize= 26>%s</div><div fontColor=#764519>%s(同时附赠</div><div fontColor=#289b14 fontsize= 26>%s</div><div fontColor=#764519>次招募)</div>"), val_num, val_str, call_num)   
            CommonAlert.show(str, TI18N("确定"), call_back, TI18N("取消"), nil, CommonAlert.type.rich, nil)
        end
    end
end
function PartnerSummonGainWindow:close_callback()
    GlobalEvent:getInstance():Fire(PokedexEvent.Call_End_Event)
    if self.item_list and next(self.item_list or {}) ~= nil then
        for i, item in ipairs(self.item_list) do
            if item then
                item:DeleteMe()
            end
        end
        self.item_list = {}
    end
    if self.card_music ~= nil then
        AudioManager:getInstance():removeEffectByData(self.card_music)
    end
    self:handleTimeSummonEffect(false)
    self:showDrawEffect1(false)
    self:showDrawEffect2(false)
    self:showDrawEffect3(false)
    self:showDrawEffect4(false)
    self:handleFlickerEffect(false)
    self:handleHigherFlickerEffect(false)
    self:showStarEffect(false)
    self:showRareEffect(false)
    if self.summon_bg_load then
        self.summon_bg_load:DeleteMe()
        self.summon_bg_load = nil
    end
    if self.effect_spine_2 then
        self.effect_spine_2:runAction(cc.RemoveSelf:create(true))
        self.effect_spine_2 = nil
    end
    if self.effect_spine_4 then
        self.effect_spine_4:runAction(cc.RemoveSelf:create(true))
        self.effect_spine_4 = nil
    end
    if self.first_container then
        self.first_container:removeAllChildren()
        self.first_container = nil
    end
    if self.left_container then
        self.left_container:removeAllChildren()
        self.left_container = nil
    end
    if self.right_container then
        self.right_container:removeAllChildren()
        self.right_container = nil
    end
    if self.item_load then
        self.item_load:DeleteMe()
    end
    self.item_load = nil
    if self.resources_bg_load then
        self.resources_bg_load:DeleteMe()
    end
    self.resources_bg_load = nil
    if self.hero_draw_load then
        self.hero_draw_load:DeleteMe()
    end
    self.hero_draw_load = nil
    if self.effect_container then
        self.effect_container:removeAllChildren()
        self.effect_container = nil
    end
    if self.update_summon_data_event then
        GlobalEvent:getInstance():UnBind(self.update_summon_data_event)
        self.update_summon_data_event = nil
    end
    if self.update_share_data_event then
        GlobalEvent:getInstance():UnBind(self.update_share_data_event)
        self.update_share_data_event = nil
    end
    GlobalEvent:getInstance():Fire(BattleEvent.NEXT_SHOW_RESULT_VIEW)
    controller:openSummonGainWindow(false)
end

-----------------@ 以下为旧代码

function PartnerSummonGainWindow:shakeScreen(root_wnd)
    local scene = root_wnd
    if scene.action then
        self.is_shake = false
        scene:stopAllActions()--stopAction(scene.action)
        scene.action = nil
    end
    self.camera_shake_pos = cc.p(root_wnd:getPosition())
    self.is_shake = true
    local function returnPos()
        self.is_shake = false
        scene:setPosition(self.camera_shake_pos)
    end
    local order = { 1, 4, 7, 8, 9, 6, 3, 2 }
    local str = 15 --振幅，单位像素
    local damp = 3 --振动减衰, 单位像素
    local step = 0.015 --振动间隔，单位秒
    local shakeXTime = 0.25 --横向加倍
    local shakeYTime = 0.25 --纵向加倍
    local shakeTime =  1 --振动次数
    local xy_list = { {-0.7, 0.7 }, { 0, 1 }, { 0.7, 0.7 }, {-1, 0 }, { 0, 0 }, { 1, 0 }, {-0.7, -0.7 }, { 0, -1 }, { 0.7, -0.7 } }
    local function setRandomPos(index)
        local pos_x, pos_y
        pos_x = str * shakeYTime * xy_list[order[index]][1]
        pos_y = -str * shakeXTime * xy_list[order[index]][2]
        local pos = cc.p(self.camera_shake_pos.x + pos_x, self.camera_shake_pos.y + pos_y)
        scene:setPosition(pos)
    end
    local base_call = nil
    for j = 1, shakeTime do
        for i = 1, #order do
            local delay = cc.DelayTime:create(step)
            base_call = cc.Sequence:create(base_call, cc.CallFunc:create(function() setRandomPos(i) end), delay)
        end
        str = str - damp
    end
    base_call = cc.Sequence:create(base_call, cc.CallFunc:create(returnPos))
    scene.action = base_call
    scene:runAction(base_call)
end

function PartnerSummonGainWindow:updateRole(role_list)
    self.role_spine_list = {}
    if role_list and next(role_list or {}) ~= nil then
        local count = 0
        local effect_action = PlayerAction.action_3
        for i, v in ipairs(role_list) do
            if not self.role_spine_list[i] then
                local size = self.effect_container:getContentSize()
                local spine_sp = createSprite(PathTool.getPlistImgForDownLoad("bigbg/partnercard", "partnercard_10101"),size.width/2, size.height/2 + 170,self.effect_container,cc.p(0.5,0.5),LOADTEXT_TYPE)
                spine_sp:setOpacity(0)
                spine_sp:setVisible(true)
                local container = self:createExtendCard(v)
                spine_sp.container = container
                spine_sp.container:setVisible(false)
                spine_sp:addChild(container)
                v.effect_action = effect_action
                local base_data = Config.PartnerData.data_partner_star(getNorKey(v.bid, v.star))
                spine_sp.data = v
                spine_sp.base_data = base_data
                self.role_spine_list[i]= spine_sp
                count = count + 1
            end
        end
        if count >= tableLen(role_list) then
            self:updateRoleAction()
        end
    end
end

--创建卡片上额外的元素
function PartnerSummonGainWindow:createExtendCard(data)
    local layout = ccui.Layout:create()
    layout:setCascadeOpacityEnabled(true)
    layout:setContentSize(cc.size(323,65))
    showLayoutRect(layout) 
    local res = PathTool.getResFrame("partnersummon", "partnersummon_type_"..data.type)
    local career_tag = createSprite(res,5, layout:getContentSize().height + 11 , layout, cc.p(0, 0), LOADTEXT_TYPE_PLIST)
    if data.camp_type then
        local type_res = PathTool.getHeroCampTypeIcon(data.camp_type)
        local camp_tag = createSprite(type_res, 5, layout:getContentSize().height+390, layout, cc.p(0, 0), LOADTEXT_TYPE_PLIST)
    end
    local star_list = {}
    local init_star = data.star or data.show_star
    -- Debug.trace("===>>>>", init_star)
    local start_x = layout:getContentSize().width * 0.5 - (init_star - 1) * 30
    for i = 1, init_star do
        if not star_list[i] then
            local star = createSprite(PathTool.getResFrame("common","common_90011"),layout:getContentSize().width / 2, layout:getContentSize().height / 2, layout, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST)
            local _x = start_x + (i - 1) * (60)
            star:setPosition(_x,layout:getContentSize().height / 2)
            star_list[i] = star
        end
    end

    return  layout
end

function PartnerSummonGainWindow:updateRoleAction(is_click)
    if self.is_call == FALSE then 
        self.is_action_ing = false
    end
    if tableLen(self.role_spine_list) == 0 and self.is_action_ing == true and self.is_call == TRUE then
        self:updateItemData(self.reward_list)
        return 
    elseif self.is_normal_click == true and tableLen(self.role_spine_list) == 0 and self.is_call == TRUE then
       self:updateItemData(self.reward_list)
       return 
    end
    if self.cur_show_card then
        self.cur_show_card:setOpacity(0)
        self.cur_show_card:setVisible(false)
    end
    self:showHeroAction()
end

function PartnerSummonGainWindow:showHeroAction()
    self.temp_sp = table.remove(self.role_spine_list, 1)
    self.cur_show_card = self.temp_sp
    local delay_time = cc.DelayTime:create(2)
    local action = cc.FadeIn:create(0.1)
    if self.effect_spine_2 then
        self.effect_spine_2:setVisible(false)
    end
    if self.effect_spine_4 then
        self.effect_spine_4:setVisible(false)
    end
    self.is_show_hero = true
    if self.temp_sp then
        self.temp_sp:setOpacity(0)
        self.temp_sp:setVisible(false)
        self.temp_sp.container:setVisible(false)
        self.left_container:setPosition(cc.p(-self.size.width * 1.2, SCREEN_HEIGHT / 2 - 100))
        self.right_container:setPosition(cc.p(self.size.width * 1.2, SCREEN_HEIGHT / 2 + 100))
        self.title_bg:setVisible(false)
        self.btn_container:setVisible(false)
        self.new_desc_container:setVisible(false)
        self.title_bg:setScale(1.5)

        local action_name = PlayerAction.action_2
        if self.config_data[self.group_id] and self.config_data[self.group_id].action_card_name and self.config_data[self.group_id].action_card_name ~= "" then
            action_name = self.config_data[self.group_id].action_card_name
        end
        if self.temp_sp and self.temp_sp.data then
            if not self.is_show_item then
                local res_id = PathTool.getPlistImgForDownLoad("bigbg/partnercard", "partnercard_" .. self.temp_sp.data.bid)
                self.item_load = createResourcesLoad(res_id, ResourcesType.single, function()
                    if not tolua.isnull(self.temp_sp) and PathTool.isFileExist(res_id) then
                        loadSpriteTexture(self.temp_sp, res_id, LOADTEXT_TYPE)
                    end
                end, self.item_load)

                self.temp_sp:runAction(cc.Sequence:create(cc.CallFunc:create(function()
                    self.temp_sp:setVisible(true)
                end),
                cc.DelayTime:create(0.1), action, cc.Spawn:create(cc.CallFunc:create(function()
                    self.temp_sp.container:setVisible(true)
                end))))
                if not self.effect_spine_2 then
                    self.effect_spine_2 = self:playEffect(Config.EffectData.data_effect_info[123], action_name, self.effect_container:getContentSize().width / 2, self.effect_container:getContentSize().height / 2 + 160, 99, self.effect_container)
                    self.effect_spine_2:setScale(display.getMaxScale())
                else
                    self.effect_spine_2:setVisible(true)
                    self.effect_spine_2:setToSetupPose()
                    self.effect_spine_2:setAnimation(0, action_name, false)
                end
                
                local function animationEventFunc(event)
                    if event.eventData.name == "appear" then
                        if self.recuit_music ~= nil then
                            AudioManager:getInstance():removeEffectByData(self.recuit_music)
                        end
                        self.card_music = AudioManager:getInstance():playEffect(AudioManager.AUDIO_TYPE.Recruit, "result_01", false)
                        
                        if not tolua.isnull(self.effect_spine_4)then
                            self.effect_spine_4:setVisible(true)
                        else
                            self.effect_spine_4 = self:playEffect(Config.EffectData.data_effect_info[123], PlayerAction.action_3, self.effect_container:getContentSize().width / 2, self.effect_container:getContentSize().height / 2 + 160, 99, self.effect_container)
                        end
                        self.title_bg:runAction(cc.Sequence:create(cc.CallFunc:create(function()
                            self.title_bg:setVisible(true)
                            if not self.title_effect then
                                self.title_effect = self:playEffect(Config.EffectData.data_effect_info[140], PlayerAction.action, self.title_bg:getContentSize().width / 2, 0, 1, self.title_bg, false)
                            end
                        end), cc.DelayTime:create(0.1), cc.ScaleTo:create(0.1, 1)))
                        self:updateNewDesc(self.temp_sp.data, self.temp_sp.base_data)
                        self:shakeScreen(self.root_wnd)
                        self:updateButton()
                    end
                end
                local function animationCompleteFunc()
                    if self.card_music ~= nil then
                        AudioManager:getInstance():removeEffectByData(self.card_music)
                    end
                    if self.temp_sp.data.voice then
                        self.hero_music = AudioManager:getInstance():playEffect(AudioManager.AUDIO_TYPE.DUBBING,self.temp_sp.data.voice,false)
                    end
                end
                self.effect_spine_2:registerSpineEventHandler(animationEventFunc, sp.EventType.ANIMATION_EVENT)
                self.effect_spine_2:registerSpineEventHandler(animationCompleteFunc, sp.EventType.ANIMATION_COMPLETE)
            end
        end
    end
end

function PartnerSummonGainWindow:updateNewDesc(data, base_data)
    if not self.name then
        self.name = createLabel(70, 1, 2, self.new_desc_container:getContentSize().width/2,475, data.name, self.new_desc_container, nil, cc.p(0.5, 0.5), "fonts/title.ttf")
        self.hero_pos = createLabel(40, 198,199, self.new_desc_container:getContentSize().width/2,415, data.hero_pos, self.new_desc_container, nil, cc.p(0.5, 0.5), "fonts/title.ttf")
    end
    if self.name then
        self.name:setString(data.name)
    end
    if self.hero_pos then
        self.hero_pos:setString(data.hero_pos or "")
    end

    local skill_list = {}
    for k,v in pairs(base_data.skills or {}) do
        if v[1] ~= 1 then
            local skill_id = v[2]
            if skill_id then
                table.insert(skill_list, skill_id)
            end
        end
    end
    self.temp_skill_list = skill_list

    for k,v in pairs(self.skill_item_list) do
        v:setVisible(false)
    end

    for i, v in ipairs(skill_list) do
        local config = Config.SkillData.data_get_skill(v)
        if not self.skill_item_list[i] and config then
            local size = cc.size(105, 105)
            local mask = ccui.ImageView:create()
            mask:setCascadeOpacityEnabled(true)
            mask:setAnchorPoint(0.5, 0.5)
            local skill_pos = PartnersummonConst.Gain_Skill_Pos[#skill_list]
            if skill_pos[i] then
                mask:setPosition(skill_pos[i].x, skill_pos[i].y)
            end
            mask:setTouchEnabled(true)
            mask:addTouchEventListener(function(sender, event_type)
                if event_type == ccui.TouchEventType.ended then
                    playButtonSound2()
                    local skill_id = self.temp_skill_list[i]
                    if skill_id then
                        TipsManager:getInstance():showSkillTips(Config.SkillData.data_get_skill(skill_id), false, true)
                    end
                end
            end)
            self.new_desc_container:addChild(mask)
            mask:loadTexture(PathTool.getResFrame("partnersummon", "partnersummon_skill_kuang"),LOADTEXT_TYPE_PLIST)
            local icon = ccui.ImageView:create()
            icon:setCascadeOpacityEnabled(true)
            icon:setAnchorPoint(0.5, 0.5)
            icon:setPosition(mask:getContentSize().width/2,mask:getContentSize().height/2)
            mask:addChild(icon, 3)
           
            icon:loadTexture(PathTool.getSkillRes(config.icon), LOADTEXT_TYPE)
            self.skill_item_list[i] = mask
            self.skill_item_list[i].icon = icon
        end
        if self.skill_item_list[i].icon and config then
            self.skill_item_list[i]:setVisible(true)
            local skill_pos = PartnersummonConst.Gain_Skill_Pos[#skill_list]
            if skill_pos[i] then
                self.skill_item_list[i]:setPosition(skill_pos[i].x, skill_pos[i].y)
            end
            self.skill_item_list[i].icon:loadTexture(PathTool.getSkillRes(config.icon), LOADTEXT_TYPE)
        end
    end
    self.new_desc_container:setVisible(true)
end

function PartnerSummonGainWindow:updateButton()
    if self.btn_container then
        self.btn_container:setVisible(true)
        self.share_btn:setVisible(true)
        -- if  IS_SHOW_SHARE ~= false then
            -- self.share_label:setVisible(true)
            -- self.share_btn:setVisible(true)
            -- self:updateShareLable()
        -- end
    end
end

function PartnerSummonGainWindow:updateShareLable()
    -- local data = PartnersummonController:getInstance():getModel():getShareData()
    -- if data then
    --     local str = ""
    --     if data.is_share == FALSE then
    --         if Config.RecruitData.data_partnersummon_const["share_role"] then
    --             str = string.format(TI18N("首次分享奖励<img src=%s visible=true scale=0.45 /><div fontColor=#ffffff fontsize= 32 >%s</div>"),PathTool.getItemRes(Config.ItemData.data_assets_label2id.red_gold),Config.RecruitData.data_partnersummon_const["share_role"].val)
    --         end
    --     elseif data.is_day_share == FALSE then
    --         if Config.RecruitData.data_partnersummon_const["share_day"] then
    --             str = string.format(TI18N("每日首次分享奖励<img src=%s visible=true scale=0.45 /><div fontColor=#ffffff fontsize= 32 >%s</div>"),PathTool.getItemRes(Config.ItemData.data_assets_label2id.red_gold),Config.RecruitData.data_partnersummon_const["share_day"].val)
    --         end
    --     end
    --     self.share_label:setString(str)
    -- end
end

function PartnerSummonGainWindow:shareLayout(status)
    if not self.root_layout then
        self.root_layout = ccui.Layout:create()
        self.root_layout:setContentSize(cc.size(SCREEN_WIDTH,80))
        self.root_layout:setAnchorPoint(0.5, 0)
        self.root_layout:setPosition(SCREEN_WIDTH*0.5, display.getBottom())
        self.root_wnd:addChild(self.root_layout, 99)

        self.share_layout = ccui.Layout:create()
        self.share_layout:setContentSize(cc.size(SCREEN_WIDTH, 80))
        self.share_layout:setPosition(cc.p(display.getLeft(self.root_wnd), 0))
        showLayoutRect(self.share_layout, 155)
        self.root_layout:addChild(self.share_layout, 99)

        local scale = 0.62
        if IS_NEED_SHOW_LOGO ~= false then
            self.logo_img = createSprite(PathTool.getLogoRes(), 20, display.getTop() - display.getBottom() - 20,self.root_layout,cc.p(0, 1),LOADTEXT_TYPE)
            self.logo_img:setScale(scale)

            local size = self.logo_img:getContentSize()
            self.logo_desc = createSprite(PathTool.getResFrame("partnersummon","txt_cn_partnersummon_share"),
                size.width * scale + self.logo_img:getPositionX(), self.logo_img:getPositionY() - size.height * scale, self.root_layout, cc.p(0, 0), LOADTEXT_TYPE_PLIST)
        end
        
        if IS_NEED_SHOW_ERWEIMA ~= false then
            self.er_wei_ma = ccui.ImageView:create()
            self.er_wei_ma:setCascadeOpacityEnabled(true)
            self.er_wei_ma:setAnchorPoint(0.5, 0.5)
            self.er_wei_ma:setPosition(365,285)
            self.er_wei_ma:setTouchEnabled(true)
            self.er_wei_ma:addTouchEventListener(function(sender, event_type)
                if event_type == ccui.TouchEventType.ended then
                    playButtonSound2()
                end
            end)
            self.root_layout:addChild(self.er_wei_ma)
            
            local apk_data = RoleController:getInstance():getApkData()
            if apk_data then
                download_qrcode_png(apk_data.message.qrcode_url,function(code,filepath)
                    if not tolua.isnull(self.er_wei_ma) then
                        if code == 0 then
                            self.er_wei_ma:loadTexture(filepath,LOADTEXT_TYPE)
                        else
                            self.er_wei_ma:loadTexture(PathTool.getResFrame('partnersummon', 'partnersummon_erweima'), LOADTEXT_TYPE_PLIST)
                        end
                    end
                end)
            else
                self.er_wei_ma:loadTexture(PathTool.getResFrame("partnersummon", "partnersummon_erweima"), LOADTEXT_TYPE_PLIST)
            end
            
            self.er_wei_ma_desc = createLabel(26,1,nil,275,170,TI18N("长按识别二维码"),self.root_layout)
        end
        
        -- self.share_desc = createLabel(30, 1, nil,455,20, TI18N("分享到"), self.share_layout)
        -- self.weixin_btn = createButton(self.share_layout, TI18N(""), 595, 40, cc.size(62, 62), PathTool.getResFrame("partnersummon", "partnersummon_weixin"), 24)
        -- self.friend_btn = createButton(self.share_layout, TI18N(""), 675, 40, cc.size(62, 62), PathTool.getResFrame("partnersummon", "partnersummon_friend"), 24)
        self.return_btn = createButton(self.share_layout, TI18N(""), 114, 40, cc.size(220,77), PathTool.getResFrame("partnersummon", "partnersummon_return"), 24)
        self.return_btn:setRichText(TI18N("<div fontColor=#ffffff fontsize=34 outline=2,#823705>返回</div>"))
        self.return_btn:setRichLabelPosition(120,62)

        self.save_img_btn = createButton(self.share_layout, TI18N("确定"), 606, 40, cc.size(220, 77), PathTool.getResFrame("partnersummon", "partnersummon_btn"), 24)
        self.save_img_btn:setRichText(TI18N("<div fontColor=#ffffff fontsize=34 outline=2,#823705>保存</div>"))

        -- if self.friend_btn then
        --     self.friend_btn:addTouchEventListener(function(sender, event_type)
        --         customClickAction(sender, event_type)
        --         if event_type == ccui.TouchEventType.ended then
        --             self.share_layout:setVisible(false)
        --             self:wxShare(1)

        --         end
        --     end)
        -- end
        -- if self.weixin_btn then
        --     self.weixin_btn:addTouchEventListener(function(sender, event_type)
        --         customClickAction(sender, event_type)
        --         if event_type == ccui.TouchEventType.ended then
        --             self.share_layout:setVisible(false)
        --             self:wxShare(0)
        --         end
        --     end)
        -- end

        -- 保存
        if self.save_img_btn then
            self.save_img_btn:addTouchEventListener(function(sender, event_type)
                customClickAction(sender, event_type)
                if event_type == ccui.TouchEventType.ended then
                    self:shardErweimaImg()
                end
            end)
        end

        if self.return_btn then
            self.return_btn:addTouchEventListener(function(sender, event_type)
                customClickAction(sender, event_type)
                if event_type == ccui.TouchEventType.ended then
                    self:handleShareStatus(true)
                end
            end)
        end
    end

    if self.root_layout and not tolua.isnull(self.root_layout) then
        self.root_layout:setVisible(status)
    end
end