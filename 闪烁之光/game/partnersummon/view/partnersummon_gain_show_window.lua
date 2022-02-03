-- --------------------------------------------------------------------
-- 
-- 
-- @author: mengjiabin@syg.com(必填, 创建模块的人员)
-- @editor: mengjiabin@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--     主要是用于展示获得伙伴的英雄
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
PartnerSummonGainShowWindow = PartnerSummonGainShowWindow or BaseClass(BaseView)

local controller = PartnersummonController:getInstance()
local model = PartnersummonController:getInstance():getModel()

function PartnerSummonGainShowWindow:__init(bg_type)
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Full
    self.role_spine_list = {}
    self.skill_item_list = {}

    --[[if bg_type and bg_type == 2 then
        self.partnersummon_call_bg_res = PathTool.getPlistImgForDownLoad("bigbg/partnersummon", "partnersummon_call_bg_200")
    else
        self.partnersummon_call_bg_res = PathTool.getPlistImgForDownLoad("bigbg/partnersummon", "partnersummon_call_bg_100")
    end--]]
    --self.partnersummon_call_bg_res = PathTool.getPlistImgForDownLoad("bigbg/partnersummon", "partnersummon_call_bg_300", true)
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("partnersummon", "partnersummon"), type = ResourcesType.plist },
        --{ path = self.partnersummon_call_bg_res, type = ResourcesType.single },
        { path = PathTool.getPlistImgForDownLoad("bigbg", "bigbg_12"), type = ResourcesType.single },
        { path = PathTool.getPlistImgForDownLoad("bigbg", "txt_cn_bigbg_18"), type = ResourcesType.single },
    }
end

function PartnerSummonGainShowWindow:createRootWnd()
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

    self.image_bg = createSprite(self.partnersummon_call_bg_res, SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2, self.source_container, cc.p(0.5, 0.5), LOADTEXT_TYPE)
    self.image_bg:setVisible(false)
    self.image_bg:setScale(display.getMaxScale())

    self.title_bg = createSprite(PathTool.getPlistImgForDownLoad("bigbg", "txt_cn_bigbg_18"), SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2 + 525, self.source_container, cc.p(0.5, 0.5), LOADTEXT_TYPE)
    self.title_bg:setVisible(false)
    self.title_bg:setScale(1.5)

    self.effect_container = ccui.Layout:create()
    self.effect_container:setAnchorPoint(cc.p(0.5, 0.5))
    self.effect_container:setContentSize(cc.size(SCREEN_WIDTH, SCREEN_HEIGHT))
    self.effect_container:setCascadeOpacityEnabled(true)
    self.effect_container:setPosition(cc.p(self.size.width / 2, SCREEN_HEIGHT / 2))
    self.root_wnd:addChild(self.effect_container,99)

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

    -- 引导需要
    --self.comfirm_next_btn:setName("guildsign_summon_next_btn")

    if self.comfirm_next_btn then
        self.comfirm_next_btn:addTouchEventListener(function(sender, event_type)
            customClickAction(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                controller:openSummonGainShowWindow(false)
            end
        end)
    end

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
    self:resgiter_event()
end

function PartnerSummonGainShowWindow:openRootWnd(data)
    self.is_chips = data.is_chips
    self:callAction(data)
end

function PartnerSummonGainShowWindow:callAction(data)
    self.data = data or {}
    self.role_list = {}
    self.is_action_ing = true
    local config = deepCopy(Config.PartnerData.data_partner_base[data.partner_bid]) or {}
    config.star = data.init_star
    -- 预加载英雄音效
    if config.voice ~= "" then
        AudioManager:getInstance():preLoadEffect(AudioManager.AUDIO_TYPE.DUBBING, config.voice)
    end
    self.show_type = data.show_type or PartnersummonConst.Gain_Show_Type.Common_Show
    table.insert(self.role_list, config)
    self:quickShowHero()
end

function PartnerSummonGainShowWindow:quickShowHero()
    self.is_action_ing = false
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
    --[[if self.role_list and next(self.role_list or {}) ~= nil then
        local count = 0
        local effect_action = PlayerAction.action_3
        for i, v in ipairs(self.role_list) do
            if not self.role_spine_list[i] then
                local size = self.effect_container:getContentSize()
                local spine_sp = createSprite(nil, size.width / 2, size.height / 2 + 170, self.effect_container, cc.p(0.5, 0.5), LOADTEXT_TYPE)
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

-- 显示英雄详细信息（立绘等）
function PartnerSummonGainShowWindow:showHeroDetailInfo(  )
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
        if self.show_type == PartnersummonConst.Gain_Show_Type.Skin_show then
            local skin_cfg = Config.PartnerSkinData.data_skin_info[self.data.skin_id]
            if skin_cfg then
                self.hero_name_txt:setString(skin_cfg.skin_name or "")
            end
        else
            self.hero_name_txt:setString(hero_cfg.name)
        end
        -- 阵营
        local camp_res = PathTool.getHeroCampTypeIcon(hero_cfg.camp_type)
        loadSpriteTexture(self.hero_camp_sp, camp_res, LOADTEXT_TYPE_PLIST)
        local camp_pos_x = 360 - self.hero_name_txt:getContentSize().width*0.5 - 25
        self.hero_camp_sp:setPosition(cc.p(camp_pos_x, 1195))

        -- 是否显示new标识
        self.is_show_new = false
        if self.show_type == PartnersummonConst.Gain_Show_Type.Skin_show or HeroController:getInstance():getModel():getHeroNumByBid(hero_cfg.bid) <= 1 then
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
        self.hero_draw_scale = 1
        if self.show_type == PartnersummonConst.Gain_Show_Type.Skin_show then
            local skin_cfg = Config.PartnerSkinData.data_skin_info[self.data.skin_id]
            if skin_cfg and skin_cfg.draw_res ~= "" then
                local draw_res_path = PathTool.getPlistImgForDownLoad("herodraw/herodrawres", skin_cfg.draw_res, false)
                self.hero_draw_load = loadSpriteTextureFromCDN(self.hero_draw_sp, draw_res_path, ResourcesType.single, self.hero_draw_load)
            end
            -- 皮肤立绘缩放和位置偏移
            if skin_cfg.scale_2 then
                self.hero_draw_scale = skin_cfg.scale_2/100
            end
            if skin_cfg.draw_offset_2 and skin_cfg.draw_offset_2[1] then
                local offset_x = skin_cfg.draw_offset_2[1][1] or 0
                local offset_y = skin_cfg.draw_offset_2[1][2] or 0
                self.hero_draw_sp:setPosition(cc.p(offset_x, offset_y))
            end
        else
            if hero_cfg.draw_res ~= "" then
                local draw_res_path = PathTool.getPlistImgForDownLoad("herodraw/herodrawres", hero_cfg.draw_res, false)
                self.hero_draw_load = loadSpriteTextureFromCDN(self.hero_draw_sp, draw_res_path, ResourcesType.single, self.hero_draw_load)
            end
            -- 立绘缩放和位置偏移
            if hero_cfg.draw_scale then
                self.hero_draw_scale = hero_cfg.draw_scale/100
            end
            if hero_cfg.draw_offset then
                local offset_x = hero_cfg.draw_offset[1] or 0
                local offset_y = hero_cfg.draw_offset[2] or 0
                self.hero_draw_sp:setPosition(cc.p(offset_x, offset_y))
            end
        end
        
        -- 类型
        local type_res_str = "txt_cn_partnersummon_type_" .. hero_cfg.type
        if hero_cfg.star >= 5 then
            type_res_str = type_res_str .. "_s"
        end
        local type_res = PathTool.getResFrame("partnersummon", type_res_str)
        loadSpriteTexture(self.hero_type_sp, type_res)
        self.hero_type_txt:setString(hero_cfg.hero_pos or "")

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
    else
        controller:openSummonGainShowWindow(false)
    end
end

-- 4星立绘的底盘特效
function PartnerSummonGainShowWindow:showDrawEffect1( status )
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
function PartnerSummonGainShowWindow:showDrawEffect2( status )
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
function PartnerSummonGainShowWindow:showDrawEffect3(status)
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

-- 四星、五星通用粒子特效
function PartnerSummonGainShowWindow:showDrawEffect4(status)
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

function PartnerSummonGainShowWindow:quickShowHeroInfo(  )
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
    self.hero_type_bg:setPosition(cc.p(81, 458))
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

    self.is_show_enter_ani = false
end

-- 创建英雄详细信息界面
function PartnerSummonGainShowWindow:createHeroInfoNode(  )
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
function PartnerSummonGainShowWindow:onClickCommentBtn(  )
    if self.cur_show_hero_cfg then
        PokedexController:getInstance():openCommentWindow(true, self.cur_show_hero_cfg)
    end
end

-- 点击分享按钮
function PartnerSummonGainShowWindow:onClickShareBtn(  )
    if FINAL_CHANNEL == "syios_smzhs" then
        message(TI18N("暂不支持"))
        return
    end
    self:showHeroShareLayer(true)
end

-- 点击技能按钮
function PartnerSummonGainShowWindow:onClickSkillBtn(  )
    if not self.cur_show_hero_cfg  then return end
    local pokedex_config = Config.PartnerData.data_partner_pokedex[self.cur_show_hero_cfg.bid]
    if pokedex_config and pokedex_config[1] then
        local star = pokedex_config[1].star or 1
        HeroController:getInstance():openHeroInfoWindowByBidStar(self.cur_show_hero_cfg.bid, star, true)
    end
end

function PartnerSummonGainShowWindow:onClickShareReturnBtn(  )
    self:showHeroShareLayer(false)
end

function PartnerSummonGainShowWindow:onClickShareSaveBtn(  )
    self:shardErweimaImg()
end

-- 切换分享和角色信息界面
function PartnerSummonGainShowWindow:showHeroShareLayer( status )
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
function PartnerSummonGainShowWindow:handleFlickerEffect(status, action_name)
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
function PartnerSummonGainShowWindow:handleHigherFlickerEffect(status)
    if status == true then
        if not tolua.isnull(self.draw_container) and self.higher_flicker_effect == nil then
            self.higher_flicker_effect = createEffectSpine(PathTool.getEffectRes(1317), cc.p(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2), cc.p(0.5, 0.5), false, PlayerAction.action_1)
            self.draw_container:addChild(self.higher_flicker_effect, 99)

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
function PartnerSummonGainShowWindow:showStarEffect(status, action)
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
function PartnerSummonGainShowWindow:showRareEffect(status)
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
function PartnerSummonGainShowWindow:showHeroInfoEnterAni(  )
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

--创建卡片上额外的元素
function PartnerSummonGainShowWindow:createExtendCard(data)
    local layout = ccui.Layout:create()
    layout:setCascadeOpacityEnabled(true)
    layout:setContentSize(cc.size(323, 65))
    if self.show_type == PartnersummonConst.Gain_Show_Type.Common_Show then
        showLayoutRect(layout)
        local res = PathTool.getResFrame("partnersummon", "partnersummon_type_" .. data.type)
        local career_tag = createSprite(res, 5, layout:getContentSize().height + 11, layout, cc.p(0, 0), LOADTEXT_TYPE_PLIST)
        if data.camp_type then
            local type_res = PathTool.getHeroCampTypeIcon(data.camp_type)
            local camp_tag = createSprite(type_res, 5, layout:getContentSize().height+390, layout, cc.p(0, 0), LOADTEXT_TYPE_PLIST)
        end
        local star_list = {}
        local init_star = data.star or data.show_star
        local start_x = layout:getContentSize().width * 0.5 - (init_star - 1) * 30
        for i = 1, init_star do
            if not star_list[i] then
                local star = createSprite(PathTool.getResFrame("common", "common_90011"), layout:getContentSize().width / 2, layout:getContentSize().height / 2, layout, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST)
                local _x = start_x + (i - 1) * (60)
                star:setPosition(_x, layout:getContentSize().height / 2)
                star_list[i] = star
            end
        end
    end
    return layout
end

function PartnerSummonGainShowWindow:showHeroAction()
    self.temp_spine = table.remove(self.role_spine_list, 1)
    self.cur_show_card = self.temp_spine
    local delay_time = cc.DelayTime:create(2)
    local action = cc.FadeIn:create(0.1)
    if self.effect_spine_2 then
        self.effect_spine_2:setVisible(false)
    end
    if self.effect_spine_4 then
        self.effect_spine_4:setVisible(false)
    end
    self.is_show_hero = true
    if self.temp_spine then
        self.temp_spine:setOpacity(0)
        self.temp_spine:setVisible(false)
        self.temp_spine.container:setVisible(false)
        self.title_bg:setVisible(false)
        self.btn_container:setVisible(false)
        self.new_desc_container:setVisible(false)
        self.title_bg:setScale(1.5)

        local action_name = PlayerAction.action_2
        if Config.RecruitData.data_partnersummon_data[self.group_id] and Config.RecruitData.data_partnersummon_data[self.group_id].action_card_name and Config.RecruitData.data_partnersummon_data[self.group_id].action_card_name ~= "" then
            action_name = Config.RecruitData.data_partnersummon_data[self.group_id].action_card_name
        end
        if self.temp_spine and self.temp_spine.data then
            if not self.is_show_item then

                local res_id 
                if self.show_type == PartnersummonConst.Gain_Show_Type.Skin_show then
                    local skin_config = Config.PartnerSkinData.data_skin_info[self.data.skin_id]
                    if skin_config then
                        res_id = PathTool.getPlistImgForDownLoad("bigbg/partnercard", "partnercard_"..skin_config.head_card_id)
                    else
                        res_id = PathTool.getPlistImgForDownLoad("bigbg/partnercard", "partnercard_2001")
                    end
                else --PartnersummonConst.Gain_Show_Type.Common_Show
                    res_id = PathTool.getPlistImgForDownLoad("bigbg/partnercard", "partnercard_" .. self.temp_spine.data.bid)
                end
                self.item_load = createResourcesLoad(res_id, ResourcesType.single, function()
                    if not tolua.isnull(self.temp_spine) and PathTool.isFileExist(res_id) then
                        loadSpriteTexture(self.temp_spine, res_id, LOADTEXT_TYPE)
                    end
                end, self.item_load)
              
                if not self.effect_spine_2 then
                    if self.show_type == PartnersummonConst.Gain_Show_Type.Skin_show then
                        self.effect_spine_2 = self:playEffect("E51007", action_name, self.effect_container:getContentSize().width / 2, self.effect_container:getContentSize().height / 2 + 160, 99, self.effect_container)
                    else --PartnersummonConst.Gain_Show_Type.Common_Show
                        self.effect_spine_2 = self:playEffect(Config.EffectData.data_effect_info[123], action_name, self.effect_container:getContentSize().width / 2, self.effect_container:getContentSize().height / 2 + 160, 99, self.effect_container)
                    end
                    self.effect_spine_2:setScale(display.getMaxScale())
                else
                    self.effect_spine_2:setVisible(true)
                    self.effect_spine_2:setToSetupPose()
                    self.effect_spine_2:setAnimation(0, action_name, false)
                end
                self.temp_spine:runAction(cc.Sequence:create(cc.CallFunc:create(function()
                    self.temp_spine:setVisible(true)
                end),
                cc.DelayTime:create(0.1), action, cc.Spawn:create(cc.CallFunc:create(function()
                    self.temp_spine.container:setVisible(true)
                end))))
                local function animationEventFunc(event)
                    if event.eventData.name == "appear" then
                        AudioManager:getInstance():playEffect(AudioManager.AUDIO_TYPE.Recruit, "result_01", false)
                        if self.effect_spine_4 and not tolua.isnull(self.effect_spine_4)then
                            self.effect_spine_4:setVisible(true)
                        else
                            if self.show_type == PartnersummonConst.Gain_Show_Type.Skin_show then
                                self.effect_spine_4 = self:playEffect("E51007", PlayerAction.action_3, self.effect_container:getContentSize().width / 2, self.effect_container:getContentSize().height / 2 + 160, 99, self.effect_container)
                            else--PartnersummonConst.Gain_Show_Type.Common_Show
                                self.effect_spine_4 = self:playEffect(Config.EffectData.data_effect_info[123], PlayerAction.action_3, self.effect_container:getContentSize().width / 2, self.effect_container:getContentSize().height / 2 + 160, 99, self.effect_container)
                            end
                        end
                        self.title_bg:runAction(cc.Sequence:create(cc.CallFunc:create(function()
                            self.title_bg:setVisible(true)
                        end), cc.DelayTime:create(0.1), cc.ScaleTo:create(0.1, 1)))

                        self:updateNewDesc(self.temp_spine.data, self.temp_spine.base_data)
                        self:shakeScreen(self.root_wnd)
                        self:updateButton()
                    end
                end
                local function animationCompleteFunc()
                    if self.temp_spine and self.temp_spine.data.voice and self.temp_spine.data.voice ~= " " then 
                        self.hero_music = AudioManager:getInstance():playEffect(AudioManager.AUDIO_TYPE.DUBBING, self.temp_spine.data.voice, false)
                    end
                end
                self.effect_spine_2:registerSpineEventHandler(animationEventFunc, sp.EventType.ANIMATION_EVENT)
                self.effect_spine_2:registerSpineEventHandler(animationCompleteFunc, sp.EventType.ANIMATION_COMPLETE)
            end
        end
    end
end

function PartnerSummonGainShowWindow:playEffect(effect_id, action, x, y, zorder, parent, is_loop)
    zorder = zorder or 1
    is_loop = is_loop or false
    local effect
    local function func()
    end
    effect = createEffectSpine(effect_id, cc.p(x, y), cc.p(0.5, 0.5), is_loop, action, func, cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888)
    parent:addChild(effect, zorder)
    return effect
end

function PartnerSummonGainShowWindow:updateNewDesc(data, base_data)
    if not self.name then
        self.name = createLabel(70, 1, 2, self.new_desc_container:getContentSize().width/2,475, data.name, self.new_desc_container, nil, cc.p(0.5, 0.5), "fonts/title.ttf")
    end
    if not self.hero_pos then
        self.hero_pos = createLabel(40, 198,199, self.new_desc_container:getContentSize().width/2,415, data.hero_pos, self.new_desc_container, nil, cc.p(0.5, 0.5), "fonts/title.ttf")
    end
    
   
    if self.show_type == PartnersummonConst.Gain_Show_Type.Skin_show then --皮肤召唤
        local skin_config = Config.PartnerSkinData.data_skin_info[self.data.skin_id]
        if skin_config then
            self.hero_pos:setPositionY(393)
            self.hero_pos:setString(string.format(TI18N("%s·皮肤"), data.name))
            self.name:setString(skin_config.skin_name)
        end
    elseif self.show_type == PartnersummonConst.Gain_Show_Type.Common_Show then --普通召唤
        self.name:setString(data.name)
        self.hero_pos:setString(data.hero_pos)

        local skill_list = {}
        for k,v in pairs(base_data.skills or {}) do
            if v[1] ~= 1 then
                local skill_id = v[2]
                if skill_id then
                    table.insert(skill_list, skill_id)
                end
            end
        end

        for k,v in pairs(self.skill_item_list) do
            v:setVisible(false)
        end

        for i, skill_id in ipairs(skill_list) do
            local config = Config.SkillData.data_get_skill(skill_id)
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
    end
    self.new_desc_container:setVisible(true)
end

function PartnerSummonGainShowWindow:updateButton()
    if self.btn_container then
        self.btn_container:setVisible(true)
        self.share_btn:setVisible(true)
        -- if IS_SHOW_SHARE ~= false then
        --     self.share_label:setVisible(true)
        --     self.share_btn:setVisible(true)
        --     self:updateShareLable()
        -- end
    end
end

function PartnerSummonGainShowWindow:updateShareLable()
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

function PartnerSummonGainShowWindow:shareLayout(status)
    if not self.root_layout then
        self.root_layout = ccui.Layout:create()
        self.root_layout:setContentSize(cc.size(SCREEN_WIDTH,80))
        self.root_layout:setAnchorPoint(0.5, 0)
        self.root_layout:setPosition(SCREEN_WIDTH*0.5, 0)
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
                download_qrcode_png(
                    apk_data.message.qrcode_url,
                    function(code, filepath)
                        if code == 0 then
                            self.er_wei_ma:loadTexture(filepath, LOADTEXT_TYPE)
                        else
                            self.er_wei_ma:loadTexture(PathTool.getResFrame('partnersummon', 'partnersummon_erweima'), LOADTEXT_TYPE_PLIST)
                        end
                    end
                )
            else
                self.er_wei_ma:loadTexture(PathTool.getResFrame('partnersummon', 'partnersummon_erweima'), LOADTEXT_TYPE_PLIST)
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

--==============================--
--desc:分享
--time:2019-01-26 02:16:15
--@return 
--==============================--
function PartnerSummonGainShowWindow:shardErweimaImg()
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

function PartnerSummonGainShowWindow:changeShardStatus(status)
	if tolua.isnull(self.share_layout) then return end
	self.share_layout:setVisible(status)
end 

function PartnerSummonGainShowWindow:wxShare(share_type)
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

function PartnerSummonGainShowWindow:handleShareStatus(status)
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

function PartnerSummonGainShowWindow:shakeScreen(root_wnd)
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

function PartnerSummonGainShowWindow:resgiter_event()
end

function PartnerSummonGainShowWindow:close_callback()
    if self.item_load then
        self.item_load:DeleteMe()
    end
    self.item_load = nil
    if self.hero_draw_load then
        self.hero_draw_load:DeleteMe()
        self.hero_draw_load = nil
    end
    self:showDrawEffect1(false)
    self:showDrawEffect2(false)
    self:showDrawEffect3(false)
    self:showDrawEffect4(false)
    self:handleFlickerEffect(false)
    self:handleHigherFlickerEffect(false)
    self:showStarEffect(false)
    self:showRareEffect(false)
    if self.effect_spine_2 then
        self.effect_spine_2:runAction(cc.RemoveSelf:create(true))
        self.effect_spine_2 = nil
    end
    if self.effect_spine_4 then
        self.effect_spine_4:runAction(cc.RemoveSelf:create(true))
        self.effect_spine_4 = nil
    end
    if self.card_music ~= nil then
        AudioManager:getInstance():removeEffectByData(self.card_music)
    end
    controller:openSummonGainShowWindow(false)
end
