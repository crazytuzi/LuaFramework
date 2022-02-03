-- --------------------------------------------------------------------
-- @author: liwenchuang@syg.com(必填, 创建模块的人员)
-- @description:
--      英雄信息主界面
-- <br/> 2018年11月15日
--
-- --------------------------------------------------------------------
HeroMainInfoWindow = HeroMainInfoWindow or BaseClass(BaseView)

local controller =  HeroController:getInstance()
local model =  controller:getModel()
local table_sort = table.sort
local table_insert = table.insert
local string_format = string.format

function HeroMainInfoWindow:__init()
    self.win_type = WinType.Full
    self.layout_name = "hero/hero_main_info_window"

    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("hero", "hero"), type = ResourcesType.plist},
        -- {path = PathTool.getPlistImgForDownLoad("bigbg/hero", "hero_info_bg", false), type = ResourcesType.single}
    }

   -- 1 ~ 5星 星星列表
    self.star_list = {}
    -- 6 ~ 9星 星星列表
    self.star_list2 = {}
    -- 10星显示
    self.star10 = nil
    self.star_label = nil

    --
    self.tab_list = {}
    self.view_list = {}

    --能否点击左右切换按钮
    self.can_click_btn = true
    --升星按钮出现参数
    self.param_star = model.hero_info_upgrade_star_param
    --天赋领悟出现参数
    self.param_talent = 6

    --显示模式 英雄模型 和 图鉴模式  定义参考 HeroConst.BagTab
    self.show_model_type = HeroConst.BagTab.eBagHero

    self.camp_y = {
        [HeroConst.CampType.eWater] = 772,
        [HeroConst.CampType.eFire] = 745,
        [HeroConst.CampType.eWind] = 546,
        [HeroConst.CampType.eLight] = 804,
        [HeroConst.CampType.eDark] = 503
    }

    self.born_limit_lev = 100
    local config = Config.PartnerData.data_partner_const.born_limit_lev
    if config then
        self.born_limit_lev = config.val
    end
end

function HeroMainInfoWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale( display.getMaxScale())

    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container , 1)  
    self.main_panel = self.main_container:getChildByName("main_panel")

    self.hero_camp_bg = self.main_panel:getChildByName("hero_camp_bg")
    self.hero_camp_bg_y = self.hero_camp_bg:getPositionY()
    --按钮
    -- self.explain_btn = self.main_panel:getChildByName("explain_btn")
    -- self.draw_btn = self.main_panel:getChildByName("draw_btn")
    self.comment_btn = self.main_panel:getChildByName("comment_btn")
    self.lock_btn = self.main_panel:getChildByName("lock_btn")
    self.lock_btn_icon = self.lock_btn:getChildByName("Sprite_1_0")
    self.share_btn = self.main_panel:getChildByName("share_btn")
    self.reset_btn = self.main_panel:getChildByName("reset_btn")
    if self.reset_btn then
        self.reset_btn:setVisible(false)
    end

    self.close_btn = self.main_panel:getChildByName("close_btn")
    self.draw_btn = self.main_panel:getChildByName("skin_btn")

    --英雄信息
    local lay_hero = self.main_panel:getChildByName("lay_hero")
    self.lay_hero = lay_hero
    self.power_click = lay_hero:getChildByName("power_click")
    self.fight_label = CommonNum.new(20, self.power_click, 99999, - 2, cc.p(0.5, 0.5))
    self.fight_label:setPosition(103, 29) 
    --影子来的
    -- local hero_info_20 = lay_hero:getChildByName("hero_info_20")
    -- hero_info_20:setPositionY(62)

    -- self.arrow_bg = self.power_click:getChildByName("arrow_bg")
    --星星
    self.star_node = lay_hero:getChildByName("star_node")
    --模型
    self.mode_node = lay_hero:getChildByName("mode_node")
    --阵营
    self.camp_icon = lay_hero:getChildByName("camp_icon")
    self.hero_name = lay_hero:getChildByName("name")
    self.left_btn = lay_hero:getChildByName("left_btn")
    self.right_btn = lay_hero:getChildByName("right_btn")
    self.vocie_panel = lay_hero:getChildByName("voice_panel")

    self.tab_container = self.main_panel:getChildByName("tab_container")
    local tab_btn_obj = self.main_panel:getChildByName("tab_btn")

    self.tab_type_list = {HeroConst.MainInfoTab.eMainTrain}
    --最大支持4个..如果超过4个需要改csb 改成srcollview..
    for i=1,4 do
        local tab_btn = {}
        local item = tab_btn_obj:getChildByName("tab_btn_"..i)
        tab_btn.btn = item
        tab_btn.index = i
        tab_btn.select_bg = item:getChildByName("select_img")
        tab_btn.select_bg:setVisible(false)
        tab_btn.title = item:getChildByName("label")
        tab_btn.title:setTextColor(cc.c4b(0xEE, 0xD1, 0xAF, 0xff))
        tab_btn.title:enableOutline(cc.c4b(0x53, 0x3D, 0x32, 0xff), 2)
        tab_btn.red_point = item:getChildByName("red_point")
        tab_btn.red_point:setVisible(false)
        tab_btn.is_hide = true
        tab_btn.btn:setVisible(false)
        
        self.tab_list[i] = tab_btn
    end

    self.resonate_panel = self.main_panel:getChildByName("resonate_panel")
    if self.resonate_panel then
        self.resonate_time = self.resonate_panel:getChildByName("resonate_time")
        self.resonate_panel:setVisible(false)
    end
    -- self:adaptationScreen()
end
--设置适配屏幕
function HeroMainInfoWindow:adaptationScreen()
    --对应主窗口.四面对应xy位置 ..相对位置是self.main_container左下角(0,0)
    -- local top_y = display.getTop(self.main_container)
    -- local bottom_y = display.getBottom(self.main_container)
    -- local left_x = display.getLeft(self.main_container)
    -- local right_x = display.getRight(self.main_container)

    -- --主菜单 顶部的高度
    -- local top_height = MainuiController:getInstance():getMainUi():getTopViewHeight()
    -- --主菜单 底部的高度
    -- local bottom_height = MainuiController:getInstance():getMainUi():getTopViewHeight()

    -- -- local offy = top_y - top_height - 50 
    -- -- self.explain_btn:setAnchorPoint(cc.p(0.5,1))
    -- -- self.explain_btn:setPositionY(offy)

    -- local offx = right_x - 50 
    -- self.comment_btn:setPositionX(offx)
    -- self.lock_btn:setPositionX(offx)
    -- self.share_btn:setPositionX(offx)
end

function HeroMainInfoWindow:register_event()
    registerButtonEventListener(self.close_btn, function() controller:openHeroMainInfoWindow(false) end, true, 2)
    -- registerButtonEventListener(self.explain_btn, function() MainuiController:getInstance():openCommonExplainView(true, Config.PartnerData.data_explain) end ,true, 2)
    --右边三个按钮
    registerButtonEventListener(self.draw_btn, function() self:onClickDrawBtn() end ,true, 1)
    registerButtonEventListener(self.comment_btn, function() self:onClickCommentBtn() end ,true, 1)
    registerButtonEventListener(self.lock_btn, function() self:onClickLockBtn() end ,true, 1)
    registerButtonEventListener(self.skin_btn, function() self:onClickSkinBtn() end ,true, 1)
    registerButtonEventListener(self.reset_btn, function() self:onClickResetBtn() end ,true, 1)

    registerButtonEventListener(self.share_btn, function ( param, sender )
        local world_pos = sender:convertToWorldSpace(cc.p(0.5, 0))
        self:onClickSharetBtn(world_pos)
    end, true, 1)

        
    registerButtonEventListener(self.left_btn, handler(self, self._onClickBtnLeft) ,true, 1)
    registerButtonEventListener(self.right_btn, handler(self, self._onClickBtnRight) ,true, 1)

    for index, tab_btn in ipairs(self.tab_list) do
       registerButtonEventListener(tab_btn.btn, function() self:changeTabType(index, true, tab_btn.btn) end ,false, 1) 
    end

    self.vocie_panel:addTouchEventListener(function(sender, event_type)
        customClickAction(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            self:onClickVoiceBtn()
        end
    end)

    self.role_vo = RoleController:getInstance():getRoleVo()
    if self.role_vo ~= nil then
        if self.role_lev_event == nil then
            self.role_lev_event =  self.role_vo:Bind(RoleEvent.UPDATE_ROLE_ATTRIBUTE, function(key, lev) 
                if not self.select_hero_vo then return end
                --个人等级会影响神装开启
                if key == "lev" then
                    self:checkTabShow()
                end
            end)
        end
    end

    self:addGlobalEvent(RoleEvent.WORLD_LEV, function() 
         if not self.select_hero_vo then return end
         --世界等级英雄神装开启
         self:checkTabShow()
    end)


    self:addGlobalEvent(HeroEvent.Hero_Data_Update, function(hero_vo)
        if not hero_vo then return end
        if hero_vo.partner_id == self.select_hero_vo.partner_id then
            self:updatePower()
            self:updateHeroBg()
            self:createStar(self.select_hero_vo.star)
            self:updateSpine(self.select_hero_vo, false)
            self:checkTabShow()
            self:updateResetInfo()
        end
    end)
      --删除英雄
    self:addGlobalEvent(HeroEvent.Del_Hero_Event, function(list)
        if not list then return end
        local dic_parther = {}
        for i,v in ipairs(list) do
            dic_parther[v.partner_id] = true
        end

        local hero_list = {}
        for i,v in ipairs(self.hero_list) do
            if not dic_parther[v.partner_id] then
                table_insert(hero_list, v)
                if self.select_hero_vo.partner_id == v.partner_id then
                    self.select_index = #hero_list
                end
            end
        end
        self.hero_list = hero_list
    end)

    self:addGlobalEvent(HeroEvent.Hero_Detail_Data_Update, function(hero_vo)
        if not hero_vo then return end
        if hero_vo.partner_id == self.select_hero_vo.partner_id then
            if self.equip_panel then
                self.equip_panel:setData(self.select_hero_vo)
            end
        end
    end)

    --装备更新
    self:addGlobalEvent(HeroEvent.Equip_Update_Event, function()
        self:updatePower()
    end)
    --神装更新
    self:addGlobalEvent(HeroEvent.Holy_Equipment_Update_Event, function()
        self:updatePower()
    end)
    --神装更新
    self:addGlobalEvent(HeroEvent.Artifact_Update_Event, function()
        self:updatePower()
    end)

    --英雄解锁事件
    self:addGlobalEvent(HeroEvent.Hero_Lock_Event, function()
        if not self.select_hero_vo then return end
        self:setLock()
    end)

    --升级成功返回事件
    self:addGlobalEvent(HeroEvent.Hero_Level_Up_Success_Event, function()
        if not self.select_hero_vo then return end
        self:showLevelUpAction()
    end)

    --可以播放音效
    self:addGlobalEvent(HeroEvent.Hero_Can_Play_Level_UP_Music_Event, function()
        --能播放音效
        self.can_play_music = true
    end)

    --天赋技能返回
    self:addGlobalEvent(HeroEvent.Hero_Get_Talent_Event, function(list)
        if not list then return end
        if not self.select_hero_vo then return end
        for i,v in ipairs(list) do
            if v.partner_id == self.select_hero_vo.partner_id then
                self:updatePageRedPoint()        
            end
        end
    end)

    --神装信息返回
    self:addGlobalEvent(HeroEvent.Hero_Get_Holy_Equipment_Event, function(list)
        if not list then return end
        if not self.select_hero_vo then return end
        for i,v in ipairs(list) do
            if v.partner_id == self.select_hero_vo.partner_id then
                --更新一下页签
                self:updatePageInfo()
                self:updatePageRedPoint() 
            end
        end
    end)
    --神装信息更新返回
    self:addGlobalEvent(HeroEvent.Holy_Equipment_Update_Event, function(hero_vo)
        if not hero_vo then return end
        if not self.select_hero_vo then return end
        if hero_vo.partner_id == self.select_hero_vo.partner_id then
            self:updatePageRedPoint()
        end
    end)
    --星级信息返回 只在登陆的时候快速打开的时候处理的
    self:addGlobalEvent(HeroEvent.Get_Had_Hero_Star_Event, function()
        if not self.select_hero_vo then return end
        if self.select_hero_vo.star >= 13 then
            --当前英雄需要13星以上才需要处理
            self:updatePageInfo()
        end
    end)
    --升星关闭界面 事件
    self:addGlobalEvent(HeroEvent.Hero_Update_Star_Close_Event, function(hero_vo)
        if not self.select_hero_vo then return end
        if hero_vo and hero_vo.partner_id == self.select_hero_vo.partner_id then
            --需要 判断是否是13星
            if self.select_hero_vo.star == (model.hero_info_upgrade_star_param4 + 1) then
                self.is_show_open_talent_effect = true
                self:checkTalentOpenEffect()
            end
        end
    end)
end

--查看立绘
function HeroMainInfoWindow:onClickDrawBtn()
    if not self.select_hero_vo then return end

    local setting = {}
    setting.hero_vo = self.select_hero_vo
    controller:openHeroDrawMainWindow(true, setting)
    -- local draw_res 
    -- local name
    -- if self.select_hero_vo.use_skin ~= 0 then
    --     local skin_config = Config.PartnerSkinData.data_skin_info[self.select_hero_vo.use_skin]
    --     if skin_config then
    --         draw_res = skin_config.draw_res
    --         name = skin_config.skin_name
    --     end
    -- end

    -- if draw_res == nil then
    --     draw_res = self.select_hero_vo.draw_res
    --     name = self.select_hero_vo.name
    --     if draw_res == nil then
    --         local config = Config.PartnerData.data_partner_base[self.select_hero_vo.bid]
    --         if config then
    --             draw_res = config.draw_res
    --             name = config.name
    --         end
    --     end
    -- end
    -- if draw_res and draw_res ~= "" then
    --     controller:openHeroLookDrawWindow(true, draw_res, name, self.select_hero_vo)
    -- end
end
--播放英雄音效
function HeroMainInfoWindow:onClickVoiceBtn()
    if not self.select_hero_vo then return end
    local voice
    local time
    if self.select_hero_vo.use_skin ~= 0 then
        local skin_config = Config.PartnerSkinData.data_skin_info[self.select_hero_vo.use_skin]
        if skin_config then
            voice = skin_config.voice
            time = skin_config.voice_time
        end
    end
    if voice == nil or voice == "" then
        voice = self.select_hero_vo.voice
        time = self.select_hero_vo.voice_time
        if voice == nil then
            local config = Config.PartnerData.data_partner_base[self.select_hero_vo.bid]
            if config then
                voice = config.voice
                time = config.voice_time
            end
        end
    end
    --无英雄音效则不播点击音效
    if voice and voice ~= "" then
        playButtonSound2()
        controller:onPlayHeroVoice(voice, time)
    end
end
--打开皮肤面板
function HeroMainInfoWindow:onClickSkinBtn()
    if not self.select_hero_vo then return end
    controller:openHeroSkinWindow(true, self.select_hero_vo)
end
--打开重生界面
function HeroMainInfoWindow:onClickResetBtn()
    if not self.select_hero_vo then return end
    --重生信息没有回来也忽视
    if not self.select_hero_vo:isResetTimeInfo() then return end
    controller:openHeroResetComfirmPanel(true, self.select_hero_vo)
end
--评论
function HeroMainInfoWindow:onClickCommentBtn()
    if not self.select_hero_vo then return end
    PokedexController:getInstance():openCommentWindow(true, self.select_hero_vo)
end
--分享
function HeroMainInfoWindow:onClickSharetBtn(world_pos)
    local callback = function(btn_type, setting)
        if not btn_type or not setting then return end
        if self.root_wnd and (not tolua.isnull(self.root_wnd)) then
            local hero_vo = setting.hero_vo
            if hero_vo then
                if btn_type == HeroConst.ShareBtnType.eHeroShareCross then
                    --跨服频道
                    controller:sender11060(ChatConst.Channel.Cross, hero_vo.partner_id)
                elseif btn_type == HeroConst.ShareBtnType.eHeroShareWorld then
                    --世界频道
                    controller:sender11060(ChatConst.Channel.World, hero_vo.partner_id)
                elseif btn_type == HeroConst.ShareBtnType.eHeroShareGuild then
                    --公会频道
                    controller:sender11060(ChatConst.Channel.Gang, hero_vo.partner_id)
                end
            end
        end
    end
    controller:openHeroSharePanel(true, world_pos, callback, {offsetx = -60, offsety = -60, hero_vo = self.select_hero_vo})
end
--分享 --废弃 by lwc
function HeroMainInfoWindow:showSharePanel(bool)
    if bool == false and not self.share_panel then return end
    if not self.share_panel then 
        local size = cc.size(200,230)
        self.share_panel = ccui.Widget:create()
        self.share_panel:setContentSize(size)
        self.main_panel:addChild(self.share_panel) 
        self.share_panel:setPosition(cc.p(459,711))

        local res = PathTool.getResFrame("common","common_1056")
        local bg = createImage(self.share_panel, res, size.width/2,size.height/2, cc.p(0.5,0.5), true, 0, true)
        bg:setContentSize(size)
        bg:setCapInsets(cc.rect(14, 14, 14, 14))

        local res = PathTool.getResFrame("common","common_1017")
        local btn1 =  createButton(self.share_panel, TI18N("世界频道"), size.width/2, 115, cc.size(160,64), res, 26, Config.ColorData.data_color4[1])
        btn1:enableOutline(Config.ColorData.data_color4[264], 2)
        btn1:addTouchEventListener(function(sender, event_type) 
            if event_type == ccui.TouchEventType.ended then
                if not self.select_hero_vo then return end
                controller:sender11060(ChatConst.Channel.World,self.select_hero_vo.partner_id)
             
                self:showSharePanel(false)
            end
        end)
        local btn2 =  createButton(self.share_panel, TI18N("公会频道"), size.width/2, 45, cc.size(160,64), res, 26, Config.ColorData.data_color4[1])
        btn2:enableOutline(Config.ColorData.data_color4[264], 2)
        btn2:addTouchEventListener(function(sender, event_type) 
            if event_type == ccui.TouchEventType.ended then
                if not self.select_hero_vo then return end
                controller:sender11060(ChatConst.Channel.Gang,self.select_hero_vo.partner_id)
            
                self:showSharePanel(false)
            end
        end)
        local btn3 =  createButton(self.share_panel, TI18N("跨服频道"), size.width/2, 185, cc.size(160,64), res, 26, Config.ColorData.data_color4[1])
        btn3:enableOutline(Config.ColorData.data_color4[264], 2)
        btn3:addTouchEventListener(function(sender, event_type) 
            if event_type == ccui.TouchEventType.ended then
                if not self.select_hero_vo then return end
                controller:sender11060(ChatConst.Channel.Cross,self.select_hero_vo.partner_id)
            
                self:showSharePanel(false)
            end
        end)
    end

    self.share_panel:setVisible(bool)
end
--锁定
function HeroMainInfoWindow:onClickLockBtn()
    if not self.select_hero_vo then return end

    local is_lock = self.select_hero_vo.dic_locks[HeroConst.LockType.eHeroLock] or 0
    if is_lock == 1 then
        is_lock = 0
    else
        is_lock = 1
    end
    controller:sender11015(self.select_hero_vo.partner_id, is_lock)
end

--左边
function HeroMainInfoWindow:_onClickBtnLeft()
    if not self.can_click_btn then return end
    if not self.hero_list or #self.hero_list <= 1 then return end
    self.select_index = self.select_index -1
    if self.select_index <= 1 then
        self.select_index = 1
    end
    self:setBtnShowStatus()
    self.select_hero_vo = self.hero_list[self.select_index]
    self:updateData()
end
--右边
function HeroMainInfoWindow:_onClickBtnRight()
    if not self.can_click_btn then return end
    if not self.hero_list or #self.hero_list <= 1 then return end
    self.select_index = self.select_index + 1
    local count = #self.hero_list
    if self.select_index >= count then
        self.select_index = count 
    end
    self:setBtnShowStatus()
    self.select_hero_vo = self.hero_list[self.select_index]
    self:updateData()
end
--设置按钮状态
function HeroMainInfoWindow:setBtnShowStatus()
    if not self.select_index then return end
    if not self.hero_list then return end
    if #self.hero_list == 1 then
        self.left_btn:setVisible(false)
        self.right_btn:setVisible(false) 
        return 
    end
    if self.select_index == 1 then
        self.left_btn:setVisible(false)
        self.right_btn:setVisible(true) 
    elseif self.select_index == #self.hero_list then
        self.left_btn:setVisible(true)
        self.right_btn:setVisible(false) 
    else
        self.left_btn:setVisible(true)
        self.right_btn:setVisible(true)
    end
    self.is_hide_talent_Item = nil
end

-- @_type 参考 HeroConst.MainInfoTab 定义
--@check_repeat_click 是否检查重复点击
function HeroMainInfoWindow:changeTabType(index, check_repeat_click, sender)
    if not self.tab_type_list then return end
    if check_repeat_click and self.cur_tab_index == index then return end
    local _type = self.tab_type_list[index]
    if not _type then return end

    if _type == HeroConst.MainInfoTab.eMainUpgradeStar and self.is_star_lock then
        -- message(self.star_lock_dec)
        local top_y = display.getTop(self.main_container)
        local p = cc.p(360,top_y - 300)
        TipsManager:getInstance():showCommonTips(self.star_lock_dec, p,nil,nil,650, true)
        return
    elseif _type == HeroConst.MainInfoTab.eMainHolyequipment and self.is_holy_equp_lock then
        message(self.holy_equp_dec)
        return
    end

    if self.cur_tab ~= nil then
        self.cur_tab.title:setTextColor(cc.c4b(0xEE, 0xD1, 0xAF, 0xff))
        self.cur_tab.title:enableOutline(cc.c4b(0x53, 0x3D, 0x32, 0xff), 2)
        self.cur_tab.select_bg:setVisible(false)
        self.cur_tab.title:setFontSize(24)
    end
    self.cur_tab_index = index
    self.cur_type = _type
    self.cur_tab = self.tab_list[self.cur_tab_index]

    if self.cur_tab ~= nil then
        self.cur_tab.title:disableEffect(cc.LabelEffect.OUTLINE)
        self.cur_tab.title:setTextColor(cc.c4b(0x60, 0x35, 0x1a, 0xff))
        self.cur_tab.select_bg:setVisible(true)
        self.cur_tab.title:setFontSize(26)
    end

    if self.pre_panel ~= nil then
        if self.pre_panel.setVisibleStatus then
            self.pre_panel:setVisibleStatus(false)
        end
    end
    self.pre_panel = self:createSubPanel(self.cur_type)
    if self.pre_panel ~= nil then
        if self.pre_panel.setVisibleStatus then
            self.pre_panel:setVisibleStatus(true)
        end
    end
    self.pre_panel:setData(self.select_hero_vo, self.show_model_type)

    --处理红点
    self:updatePageRedPoint()
end

function HeroMainInfoWindow:createSubPanel(index)
    local panel = self.view_list[index]
    if panel == nil then
        if index == HeroConst.MainInfoTab.eMainTrain then
            panel = HeroMainTabTrainPanel.new() 
        elseif index == HeroConst.MainInfoTab.eMainUpgradeStar then
            panel = HeroMainTabUpgradeStarPanel.new()
        elseif index == HeroConst.MainInfoTab.eMainTalent then
            panel = HeroMainTabTalentPanel.new(self)
        elseif index == HeroConst.MainInfoTab.eMainHolyequipment then --神装
            panel = HeroMainTabHolyequipmentPanel.new()
        end
        local size = self.tab_container:getContentSize()
        panel:setPosition(cc.p(size.width * 0.5 , size.height * 0.5))
        self.tab_container:addChild(panel)
        self.view_list[index] = panel
    end
    return panel
end

--检查天赋开启效果
function HeroMainInfoWindow:checkTalentOpenEffect()
    if self.cur_type then
        if self.cur_type == HeroConst.MainInfoTab.eMainTalent then
            --已打开天赋界面
            local panel = self.view_list[self.cur_type]
            if panel.checkOpenTanlentEffect then
                panel:checkOpenTanlentEffect()
            end
        else
            for i,_type in ipairs(self.tab_type_list) do
                if _type == self.cur_type then
                    self:changeTabType(i, true)
                    break
                end
            end
        end
    end
end

function HeroMainInfoWindow:showLevelUpAction()
    if self.effect_parent == nil then
        self.effect_parent = ccui.Widget:create()
        self.effect_parent:setCascadeOpacityEnabled(true)
        self.effect_parent:setAnchorPoint(0,0)
        self.mode_node:addChild(self.effect_parent, 2)
        self.show_level_label_list = {}
        local height = 25
        local _y = 50
        for i=1,4 do
            local font_size = 20
            local text_color = cc.c3b(0x48,0xf4,0x50)
            local line_color = cc.c3b(0x00,0x00,0x00)
            local x, y = -40, _y - height * (i-1) - height * 0.5
            local text_content = "内容" 
            local parent_wnd = self.effect_parent
            local line_num = 2
            local anchorpoint = cc.p(0,0.5)
            local label = createLabel(font_size,text_color,line_color,x,y,text_content,parent_wnd,line_num, anchorpoint,font)
            self.show_level_label_list[i] = label
        end
    end
    local key_list = {"atk", "hp", "def", "speed"}
    for i,v in ipairs(key_list) do
        local str = v..2
        local value = self.select_hero_vo[str] or 0
        value = math.ceil(value/1000)
        local name  = Config.AttrData.data_key_to_name[v]
        if self.show_level_label_list[i] then
            local label = string_format("%s + %s", name, value)
            self.show_level_label_list[i]:setString(label)
        end
    end
    self.effect_parent:setVisible(true)
    self.effect_parent:stopAllActions()

    self.effect_parent:setPosition(-80,0)
    self.effect_parent:setOpacity(10)
    local moveto = cc.MoveTo:create(0.2,cc.p(0,0))
    local fadein = cc.FadeIn:create(0.2)

    local movetoup = cc.EaseSineOut:create(cc.MoveTo:create(0.4,cc.p(0,10)))
    local spawn = cc.Spawn:create(moveto, fadein)
    -- self.effect_parent:runAction(spawn)
    self:showLevelUpEffect(true)
    self.effect_parent:runAction(cc.Sequence:create(spawn,  movetoup ,cc.CallFunc:create( function() 
        self.effect_parent:setVisible(false)
    end )))
end

function HeroMainInfoWindow:showLevelUpEffect(status)
    if status == false then
        if self.level_up_effect then
            self.level_up_effect:clearTracks()
            self.level_up_effect:removeFromParent()
            self.level_up_effect = nil
        end
    else
        if not tolua.isnull(self.mode_node) and self.level_up_effect == nil then
            if self.can_play_music then
                self.can_play_music = false
                playOtherSound("c_levelup")
            end
            self.level_up_effect = createEffectSpine(PathTool.getEffectRes(185), cc.p(0, -30), cc.p(0.5, 0.5), false, PlayerAction.action)
            self.mode_node:addChild(self.level_up_effect, 1)
        elseif self.level_up_effect then
            if self.can_play_music then
                self.can_play_music = false
                playOtherSound("c_levelup")
            end
            self.level_up_effect:setAnimation(0, PlayerAction.action, false)
        end
    end
end

function HeroMainInfoWindow:sendRssetTimeProto(  )
    if not self.select_hero_vo then return end
    if self.select_hero_vo.isResetTimeInfo and not self.select_hero_vo:isResetTimeInfo() then
        controller:sender11067(self.select_hero_vo.partner_id)
    end
end

--@select_hero_vo --需要显示的 hero_vo
--@hero_list
--@ setting 结构
--setting.showType 显示英雄新的页签类型
--setting.show_model_type 显示模式 1:英雄模式  2:图鉴模式 定义参考 HeroConst.BagTab.eBagHero
--setting.is_hide_ui 是否隐藏界面上下部分的UI
function HeroMainInfoWindow:openRootWnd(select_hero_vo, hero_list, setting)
    if not select_hero_vo then return end
    self.select_hero_vo = select_hero_vo
    self.can_click_btn = true
    self.select_index = -1
    self.hero_list = hero_list
    local setting = setting or {}
    self.show_model_type = setting.show_model_type or HeroConst.BagTab.eBagHero
    self.is_hide_ui = setting.is_hide_ui or false

    if self.hero_list then
        for i,v in ipairs(self.hero_list) do
            if self.select_hero_vo.partner_id == v.partner_id then
                self.select_index = i
            end
        end
        if self.select_index == -1 then
            --说明没找到 
            return
        end
    end
    self:setBtnShowStatus()

    self.cur_type = setting.show_type or HeroConst.MainInfoTab.eMainTrain
    self:updateData()

    if self.is_hide_ui then
        MainuiController:getInstance():setMainUIShowStatus(false)
    end

    if self.show_model_type ==  HeroConst.BagTab.eBagPokedex then
        for i,v in pairs(self.tab_list) do
            v.btn:setVisible(false)
        end

        self.lock_btn:setVisible(false)
        self.share_btn:setVisible(false)
    end
    GlobalEvent:getInstance():Fire(MainuiEvent.HEAD_UPDATE_WEALTH_EVENT, 2, Config.ItemData.data_assets_label2id.hero_exp)
end

function HeroMainInfoWindow:updateData()
    if not self.select_hero_vo then return end
    --记录当前星级 用于判断星级不同显示 更新页签用
    self.record_cur_star = self.select_hero_vo.star
    self:updateHeadHeroInfo()
     --更新页签
    self:updatePageInfo()
    if self.show_model_type == HeroConst.BagTab.eBagHero then
        if model:isOpenTanlentByHerovo(self.select_hero_vo) and not self.select_hero_vo:ishaveTalentData() then
            controller:sender11099({{partner_id = self.select_hero_vo.partner_id}})
        end
        --因为修改 页签显示问题..兼容旧数据问题 改成打开英雄界面的时候申请 了
        if model:isOpenHolyEquipMentOldByHerovo(self.select_hero_vo) and not self.select_hero_vo:ishaveHolyEquipmentData() then
            controller:sender11092({{partner_id = self.select_hero_vo.partner_id}})
        end
        
        if not self.select_hero_vo:isInitAttr() then
            controller:sender11026({{partner_id = self.select_hero_vo.partner_id}})
        end
        
        --共鸣按钮
        if self.resonate_panel then
            if self.select_hero_vo.isResonateHero and self.select_hero_vo:isResonateHero() then
               
                self.resonate_panel:setVisible(true)
                local time = self.select_hero_vo.end_time - GameNet:getInstance():getTime()

                commonCountDownTime(self.resonate_time, time, {callback = function(time) self:setTimeFormatString(time) end})
            else
                self.resonate_panel:setVisible(false)
                doStopAllActions(self.resonate_time)
            end
        end
        
        --重生
        self:updateResetInfo()
    end
end

--更新重生信息
function HeroMainInfoWindow:updateResetInfo()
    if self.show_model_type == HeroConst.BagTab.eBagHero then 
        if self.reset_btn then
            --满足条件  不能是水晶英雄 也不能是 赋能英雄
            if (self.select_hero_vo.lev > 1 and self.select_hero_vo.lev <= self.born_limit_lev) and 
                (self.select_hero_vo.isResonateHero and not self.select_hero_vo:isResonateHero()) and
                (self.select_hero_vo.isResonateCrystalHero and not self.select_hero_vo:isResonateCrystalHero()) then
                self:sendRssetTimeProto()
                self.reset_btn:setVisible(true) 
            else
                self.reset_btn:setVisible(false) 
            end
        end
    end
end

function HeroMainInfoWindow:setTimeFormatString(time)
    if time > 0 then
        self.resonate_time:setString(TimeTool.GetTimeForFunction(time))
    else
        controller:openHeroMainInfoWindow(false)
    end
end


--更新上部分的英雄信息
function HeroMainInfoWindow:updateHeadHeroInfo()
    if not self.select_hero_vo then return end

    self:updateHeroBg()
    --职业icon
    local camp_type = self.select_hero_vo.camp_type or 1
    local res = PathTool.getHeroCampTypeIcon(self.select_hero_vo.camp_type)
    if self.record_camp_type_res == nil or self.record_camp_type_res ~= res then
        self.record_camp_type_res = res
        loadSpriteTexture(self.camp_icon, res, LOADTEXT_TYPE_PLIST)
    end

    self.hero_name:setString(self.select_hero_vo.name)
    self:updatePower()

    --星星self.select_hero_vo.star 
    local star = self.select_hero_vo.star or 1
    self:createStar(star)
    self:updateSpine(self.select_hero_vo, true)

    --装备页签 原本是在页签的 改到上面..不改动过大情况下 这样改了
    if self.show_model_type == HeroConst.BagTab.eBagHero then
        if self.equip_panel == nil then
            self.equip_panel = HeroMainTabEquipPanel.new(self.power_click)
            local size = self.lay_hero:getContentSize()
            self.equip_panel:setPosition(cc.p(size.width * 0.5 , size.height * 0.5))
            self.lay_hero:addChild(self.equip_panel)
        end
        self.equip_panel:setData(self.select_hero_vo)
    end

    --立绘资源
    local draw_res = self.select_hero_vo.draw_res
    if draw_res == nil then
        local config = Config.PartnerData.data_partner_base[self.select_hero_vo.bid]
        if config then
            draw_res = config.draw_res
        end
    end
    --音效资源
    local voice_res = self.select_hero_vo.voice
    if voice_res == nil then
        local config = Config.PartnerData.data_partner_base[self.select_hero_vo.bid]
        if config then
            voice_res = config.voice
        end
    end
    -- 提审状态下不显示立绘、音效按钮
    if MAKELIFEBETTER == true then
        self.draw_btn:setVisible(false)
    else
        if draw_res and draw_res ~= "" then
            self.draw_btn:setVisible(true)
        else
            self.draw_btn:setVisible(false)
        end
    end
end

function HeroMainInfoWindow:updateHeroBg()
    if not self.select_hero_vo then return end

    local skin_config 
    if self.select_hero_vo.use_skin ~= 0 then
        skin_config = Config.PartnerSkinData.data_skin_info[self.select_hero_vo.use_skin]
    end

    --背景
    local camp_type = self.select_hero_vo.camp_type or HeroConst.CampType.eWater
    local bg_res 
    if skin_config and skin_config.hero_info_bg_res and skin_config.hero_info_bg_res ~= "" then
        bg_res = PathTool.getPlistImgForDownLoad("bigbg/hero", skin_config.hero_info_bg_res, true)
    else
        bg_res = PathTool.getPlistImgForDownLoad("bigbg/hero", HeroConst.CampBgRes[camp_type], true)
    end
    if self.record_bg_res ~= bg_res then
        self.record_bg_res = bg_res
        self.item_load = loadImageTextureFromCDN(self.background, bg_res, ResourcesType.single, self.item_load) 
    end

    --背景门
    local camp_res = PathTool.getPlistImgForDownLoad("bigbg/hero",HeroConst.CampBottomBgRes[camp_type], false)
    if skin_config and skin_config.hero_camp_res and skin_config.hero_camp_res ~= "" then
        if skin_config.hero_camp_res == "null" then
            self.hero_camp_bg:setVisible(false)
        else
            self.hero_camp_bg:setVisible(true)
            camp_res =PathTool.getPlistImgForDownLoad("bigbg/hero", skin_config.hero_camp_res, false)
        end
    else
        self.hero_camp_bg:setVisible(true)
        camp_res = PathTool.getPlistImgForDownLoad("bigbg/hero",HeroConst.CampBottomBgRes[camp_type], false)
    end
    if self.record_camp_res ~= camp_res then
        self.record_camp_res = camp_res
        self.item_load_camp = loadSpriteTextureFromCDN(self.hero_camp_bg, camp_res, ResourcesType.single, self.item_load_camp) 
    end
    
    local camp_y = self.camp_y[camp_type] or 652
    if skin_config and skin_config.hero_camp_res and  skin_config.hero_camp_res == "hero_camp_rumengling" then --如梦令的台子还没变
        camp_y = 652
    end
    self.hero_camp_bg:setPositionY(camp_y)
end

function HeroMainInfoWindow:updatePageInfo()
    if self.show_model_type == HeroConst.BagTab.eBagHero then

        self.tab_type_list = {HeroConst.MainInfoTab.eMainTrain}
        local star = self.select_hero_vo.star or 1
        self.is_star_lock = false

        if self:checkStarTabShow(star) then
            table_insert(self.tab_type_list, HeroConst.MainInfoTab.eMainUpgradeStar)
        end
        if self:checkTalentTabShow(star) then
            table_insert(self.tab_type_list, HeroConst.MainInfoTab.eMainTalent)
        end
        self.is_holy_equp_lock = false
        if self:checkHolyequipmentTabShow() then
            table_insert(self.tab_type_list, HeroConst.MainInfoTab.eMainHolyequipment)
        end

        for i,tab_btn in ipairs(self.tab_list) do
            if self.tab_type_list[i] then
                --是否隐藏中
                tab_btn.is_hide = false
                tab_btn.type = self.tab_type_list[i]
                if tab_btn.type == HeroConst.MainInfoTab.eMainUpgradeStar and self.is_star_lock then
                    setChildUnEnabled(true, tab_btn.btn)
                elseif tab_btn.type == HeroConst.MainInfoTab.eMainHolyequipment and self.is_holy_equp_lock then
                    setChildUnEnabled(true, tab_btn.btn)
                else
                    setChildUnEnabled(false, tab_btn.btn)
                    tab_btn.title:setTextColor(cc.c4b(0xEE, 0xD1, 0xAF, 0xff))
                    tab_btn.title:enableOutline(cc.c4b(0x53, 0x3D, 0x32, 0xff), 2)
                end
                tab_btn.title:setString(HeroConst.MainInfoTabName[tab_btn.type])
                    
                
                if self.cur_type and self.cur_type == tab_btn.type then
                    self.cur_tab_index = i
                end
            else
                tab_btn.is_hide = true
                --如果上一次显示本次没有tab 默认显示第一个
                if self.cur_tab_index and self.cur_tab_index == i then 
                    self.cur_tab_index = 1
                end 
            end
            if tab_btn.type == HeroConst.MainInfoTab.eMainHolyequipment then
                tab_btn.btn:setName("holy_equip_btn")
            end
            tab_btn.btn:setVisible(not tab_btn.is_hide)
        end
        --锁定
        self:setLock()
    end


    if self.cur_tab_index == nil then
        self.cur_tab_index = 1 
    else
        --如果显示的页签是锁住的那么默认1
        if self.tab_type_list[self.cur_tab_index] == HeroConst.MainInfoTab.eMainUpgradeStar and self.is_star_lock then
            self.cur_tab_index = 1     
        elseif self.tab_type_list[self.cur_tab_index] == HeroConst.MainInfoTab.eMainHolyequipment and self.is_holy_equp_lock then
            self.cur_tab_index = 1 
        end
    end
    self:changeTabType(self.cur_tab_index, false)
end

--检测升星页签出现逻辑
function HeroMainInfoWindow:checkStarTabShow(star)
    local is_max_star_hero = model:isMaxStarHero(self.select_hero_vo.bid, star)
    if is_max_star_hero then
        --策划要求满星不出现升星页签
        return false
    end    --大于配置参数 6
    if star >= self.param_star then
        --更新星级页签解锁信息
        return self:updateStarLockInfo(star)
    end
    -- 熔炼祭坛 有的也要出现
    local fuse_star = Config.PartnerData.data_partner_fuse_star[self.select_hero_vo.bid]
    if fuse_star then
        for i,v in ipairs(fuse_star) do
            if star + 1 == v.star then
                return true
            end
        end
    end
    return false
end

function HeroMainInfoWindow:checkStartByConfig(config, config2)
    local is_open = true
    --条件1 个人等级
    if config and next(config.val) ~= nil then
        if config.val[1] == "lv"  then --目前只有等级
            local role_vo = RoleController:getInstance():getRoleVo()
            if role_vo and role_vo.lev and role_vo.lev < config.val[2] then
                is_open = false
            end
        end
    end
    if not is_open then
        --条件2 世界等级
        is_open = true
        if config2 and next(config2.val) ~= nil then
            if config2.val[1] == "world_lev"  then --目前只有等级
                local world_lev = RoleController:getInstance():getModel():getWorldLev() or 0
                if world_lev and world_lev < config2.val[2] then
                    is_open = false
                end
            end
        end
    end
    return is_open
end

function HeroMainInfoWindow:updateStarLockInfo(star)
    self.star_lock_dec = TI18N("等级不足")
    if star == model.hero_info_upgrade_star_param2 then
        local star_11_show = true
        --10星升11星
        local config = Config.PartnerData.data_partner_const.star_11_show_lv
        local config2 = Config.PartnerData.data_partner_const.star_11_show_worldlv

        local is_show = self:checkStartByConfig(config, config2)
        local is_open, tips_str = model:checkOpenStar11(true)
        if is_show and not is_open then
            self.is_star_lock = true
            self.star_lock_dec = tips_str
        else
            if is_show and self.is_star_lock then
                self.is_check_tab = true
            end
            if is_open then
                is_show = is_open
            end
        end
        return is_show
    elseif star == model.hero_info_upgrade_star_param3 then
        --11星升12有世界等级要求
        local config = Config.PartnerData.data_partner_const.star_12_show_lv
        local config2 = Config.PartnerData.data_partner_const.star_12_show_worldlv
        local is_show = self:checkStartByConfig(config, config2)
        local is_open, tips_str = model:checkOpenStar12(true)
        if is_show and not is_open then
            self.is_star_lock = true
            self.star_lock_dec = tips_str
        else
            if is_show and self.is_star_lock then
                self.is_check_tab = true
            end
            if is_open then
                is_show = is_open
            end
        end
        return is_show
    elseif star == model.hero_info_upgrade_star_param4 then
        --12星升13d的等级要求
        local config = Config.PartnerData.data_partner_const.star_13_show_lv
        local config2 = Config.PartnerData.data_partner_const.star_13_show_worldlv
        local is_show = self:checkStartByConfig(config, config2)
        local is_open, tips_str = model:checkOpenStar13(true)
        if is_show and not is_open then
            self.is_star_lock = true
            self.star_lock_dec = tips_str
        else
            if is_show and self.is_star_lock then
                self.is_check_tab = true
            end
            if is_open then
                is_show = is_open
            end
        end
        return is_show
    else
        return true
    end
end

--检查天赋技能出现逻辑
function HeroMainInfoWindow:checkTalentTabShow(star)
    --大于配置参数 6
    if star >= self.param_talent then    
        return true
    end
    return false
end

--检查神装页签出现逻辑
function HeroMainInfoWindow:checkHolyequipmentTabShow()
    -- 旧数据处理 如果有穿戴神装的需要显示页签 并且不置灰的
    local is_old_open = false
    if self.select_hero_vo:ishaveHolyEquipmentData() then
        if tableLen(self.select_hero_vo.holy_eqm_list) > 0 then
            is_old_open = true
        end
    end
    --旧数据没有才用新规则
    if not is_old_open then 
        local is_show, holy_equp_dec = model:isOpenHolyEquipMentTabByHerovo(self.select_hero_vo)
        self.holy_equp_dec = holy_equp_dec
        local is_open = model:isOpenHolyEquipMentByHerovo(self.select_hero_vo)
        if is_show and not is_open  then
            --可以显示但是未开启 表示需要锁住
            self.is_holy_equp_lock = true
        end
        return is_show
    end
    return true
end

--检查tab出现情况
function HeroMainInfoWindow:checkTabShow()
    if self.show_model_type ~= HeroConst.BagTab.eBagHero then return end
    
    --三个页签都要判定
    local isTabUpgradeStar = false
    local isTabTalent      = false
    local isTabHolyequip   = false
    for i,v in ipairs(self.tab_type_list) do
        if v == HeroConst.MainInfoTab.eMainUpgradeStar then
            isTabUpgradeStar = true
        elseif v == HeroConst.MainInfoTab.eMainTalent then
            isTabTalent = true
        elseif v ==  HeroConst.MainInfoTab.eMainHolyequipment then
            isTabHolyequip = true
        end
    end

    local is_update_page = false
    if self:checkStarTabShow(self.select_hero_vo.star) ~= isTabUpgradeStar then
        is_update_page = true
    end
    if self:checkTalentTabShow(self.select_hero_vo.star) ~= isTabTalent then
        is_update_page = true

        --需要判断是否要申请天赋信息
        if model:isOpenTanlentByHerovo(self.select_hero_vo) and not self.select_hero_vo:ishaveTalentData() then
            controller:sender11099({{partner_id = self.select_hero_vo.partner_id}})
        end
    end
    if self:checkHolyequipmentTabShow() ~= isTabHolyequip then
        is_update_page = true
    end

    --星级不同 也需要更新页签. 会刷新 神装和 升星的页签
    if self.record_cur_star and self.record_cur_star < self.select_hero_vo.star then
        is_update_page = true
        self.record_cur_star = self.select_hero_vo.star
        if self.select_hero_vo.star == (model.hero_info_upgrade_star_param4 + 1) then
            self.is_hide_talent_Item = true
        end
    end
    if self.is_check_tab then
        is_update_page = true
        self.is_check_tab = nil
    end

    if is_update_page then
        self:updatePageInfo()
    end
end

function HeroMainInfoWindow:setLock()
    local res 
    if self.select_hero_vo.dic_locks[HeroConst.LockType.eHeroLock] and 
        self.select_hero_vo.dic_locks[HeroConst.LockType.eHeroLock] == 1 then
        res = PathTool.getResFrame("hero","hero_info_5")
    else
        res = PathTool.getResFrame("hero","hero_info_6")
    end
    if self.lock_record_res == nil or self.lock_record_res ~= res then
        self.lock_record_res = res
        loadSpriteTexture(self.lock_btn_icon, res, LOADTEXT_TYPE_PLIST)
    end
end

--更新页签红点问题
function HeroMainInfoWindow:updatePageRedPoint()
    if self.show_model_type == HeroConst.BagTab.eBagHero then
        --背包英雄的才显示红点
        for i,tab_btn in ipairs(self.tab_list) do
            if tab_btn and not tab_btn.is_hide then
                if self.cur_tab_index == i then --选中没红点
                    tab_btn.red_point:setVisible(false)
                else
                    local is_redpoint 
                    if tab_btn.type == HeroConst.MainInfoTab.eMainTrain then --培养
                        is_redpoint = HeroCalculate.checkSingleHeroLevelUpRedPoint(self.select_hero_vo)
                    elseif tab_btn.type == HeroConst.MainInfoTab.eMainUpgradeStar then --升星
                        is_redpoint = HeroCalculate.checkSingleHeroUpgradeStarRedPoint(self.select_hero_vo)
                    elseif tab_btn.type == HeroConst.MainInfoTab.eMainTalent then --天赋
                        is_redpoint = HeroCalculate.checkSingleHeroTalentSkillRedPoint(self.select_hero_vo)
                    elseif tab_btn.type == HeroConst.MainInfoTab.eMainHolyequipment then --神装
                        is_redpoint = HeroCalculate.checkSingleHeroHolyEquipmentRedPoint(self.select_hero_vo)
                    end
                    tab_btn.red_point:setVisible(is_redpoint)
                end
            end
        end
    end
    
end

function HeroMainInfoWindow:updatePower()
    self.fight_label:setNum(self.select_hero_vo.power)
end

--更新星星显示
function HeroMainInfoWindow:createStar(num)
    local num = num or 0
    local width = 26
    self.star_setting = model:createStar(num, self.star_node, self.star_setting, width)
end

--更新模型,也是初始化模型
--@is_refresh  是否需要检测
function HeroMainInfoWindow:updateSpine(hero_vo, is_refresh)
    if self.record_spine_bid and self.record_spine_bid == hero_vo.bid and 
        self.record_spine_star and self.record_spine_star == hero_vo.star and
        self.record_spine_skin and self.record_spine_skin == hero_vo.use_skin then
        if is_refresh then
            if self.spine then
                local action1 = cc.FadeOut:create(0.2)
                local action2 = cc.FadeIn:create(0.2)
                self.spine:runAction(cc.Sequence:create(action1,action2))
            end    
        end
        return
    end
    self.record_spine_bid = hero_vo.bid
    self.record_spine_star = hero_vo.star
    self.record_spine_skin = hero_vo.use_skin

    


    local fun = function()    
        if not self.spine then
            self.spine = BaseRole.new(BaseRole.type.partner, hero_vo, nil, {scale = 1, skin_id = hero_vo.use_skin})
            self.spine:setAnimation(0,PlayerAction.show,true) 
            self.spine:setCascade(true)
            self.spine:setPosition(cc.p(0,104))
            self.spine:setAnchorPoint(cc.p(0.5,0.5)) 
            -- self.spine:setScale(1)
            self.mode_node:addChild(self.spine) 

            if self.select_hero_vo.use_skin ~= 0 then
                --策划要求..填null的话皮肤也不显示阴影 
                local skin_config = Config.PartnerSkinData.data_skin_info[self.select_hero_vo.use_skin]
                if skin_config and skin_config.hero_camp_res == "null" then
                    self.spine:showShadowUI(false)
                end
            end
            
            self.spine:setCascade(true)
            self.spine:setOpacity(0)
            local action = cc.FadeIn:create(0.2)
            self.spine:runAction(action)
        end
    end
    if self.spine then
        self.can_click_btn = false
        self.spine:setCascade(true)
        local action = cc.FadeOut:create(0.2)
        self.spine:runAction(cc.Sequence:create(action, cc.CallFunc:create(function()
                doStopAllActions(self.spine)
                self.spine:removeFromParent()
                self.spine = nil
                self.can_click_btn = true
                fun()
        end)))
    else
        fun()
    end
end


function HeroMainInfoWindow:close_callback()
    if self.hero_music ~= nil then
        AudioManager:getInstance():removeEffectByData(self.hero_music)
    end

    GlobalEvent:getInstance():Fire(MainuiEvent.HEAD_UPDATE_WEALTH_EVENT, 2, Config.ItemData.data_assets_label2id.gold)
    if self.spine then
        self.spine:DeleteMe()
        self.spine = nil
    end

    for i,v in pairs(self.view_list) do 
        v:DeleteMe()
    end
    self.view_list = nil

    if self.item_load then
        self.item_load:DeleteMe()
    end
    self.item_load = nil

    if self.item_load_camp then
        self.item_load_camp:DeleteMe()
    end
    self.item_load_camp = nil
    
    if self.fight_label then
        self.fight_label:DeleteMe()
    end
    self.fight_label = nil

    self:showLevelUpEffect(false)

    if self.role_lev_event and self.role_vo then
        self.role_lev_event = self.role_vo:UnBind(self.role_lev_event)
        self.role_lev_event = nil
    end

    MainuiController:getInstance():setMainUIShowStatus(true)
    controller:openHeroMainInfoWindow(false)
end
