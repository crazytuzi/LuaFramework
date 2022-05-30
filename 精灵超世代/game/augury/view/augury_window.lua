-- --------------------------------------------------------------------
-- 竖版星命占卜主界面
-- 
-- @author: cloud@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
AuguryWindow = AuguryWindow or BaseClass(BaseView)

local backpack_model = BackpackController:getInstance():getModel()
local controller = AuguryController:getInstance() 

function AuguryWindow:__init()
    self.is_full_screen = true
    self.layout_name = "augury/augury_window"
    self.cur_type = 0
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("augury","augury"), type = ResourcesType.plist },
        { path = PathTool.getPlistImgForDownLoad("bigbg","bigbg_30",true), type = ResourcesType.single },
        { path = PathTool.getPlistImgForDownLoad("bigbg","bigbg_31"), type = ResourcesType.single },
    }
    self.tab_list = {}
    self.select_type = 1 --伙伴类型选择,默认全部为1
    self.view_list = {}
    self.effect_cache_list = {}
    self.is_init  = true

    self.quality_list = {[1]=3,[2]=2,[3]=5,[4]=4,[5]=1}
    self.old_quality = 0
    --是否播放观星特效 中
    self.is_play_effect = false
end

function AuguryWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:loadTexture(PathTool.getPlistImgForDownLoad("bigbg","bigbg_30",true), LOADTEXT_TYPE)
        self.background:setScale(display.getMaxScale())
    end
    
    self.mainContainer = self.root_wnd:getChildByName("main_container")

    self.container = self.mainContainer:getChildByName("container")
    self.effect_panel = self.mainContainer:getChildByName("effect_panel")
    self.effect_panel:setVisible(false)
    self.effect_panel:setTouchEnabled(false)

    local list = {[1]=TI18N(""),[2]=TI18N("试练塔"),[3]=TI18N("星命背包"),[4]=TI18N("星命商店")}
    for i=1,4 do
        local tab = {}
        local btn = self.mainContainer:getChildByName("tab_btn_"..i)
        btn:setTouchEnabled(true)
        tab.btn = btn
        tab.label = btn:getChildByName("label")
        tab.unselect_bg =btn:getChildByName("bg") 
        tab.index = i
        tab.label:setString(list[i])
        self.tab_list[i] = tab
    end
   
    self.close_btn = self.mainContainer:getChildByName("close_btn")

    self.flash_btn = self.mainContainer:getChildByName("flash_btn")
    local label = self.flash_btn:getChildByName("label")
    label:setString(TI18N("刷新运势"))

    self.one_cost_config = Config.StarDivinationData.data_divination_const["divine_change"] 
    self.ten_cost_config = Config.StarDivinationData.data_divination_const["divine_change10"] 

    self.one_call_label = createRichLabel(24, 1, cc.p(0.5, 0.5), cc.p(155, 65))
    local item_icon = Config.ItemData.data_get_data(self.one_cost_config.val[1]).icon
    local num = self.one_cost_config.val[2]
    local str = string.format(TI18N("<img src=%s visible=true scale=0.3 /> <div fontColor=#ffffff fontsize=22 > %s</div>"), PathTool.getItemRes(item_icon), num)
    self.one_call_label:setString(str)
    self.mainContainer:addChild(self.one_call_label)

    self.ten_gold_label = createRichLabel(24, 1, cc.p(0.5, 0.5), cc.p(565, 65))
    local item_icon = Config.ItemData.data_get_data(self.ten_cost_config.val[1]).icon
    local num = self.ten_cost_config.val[2]
    local str = string.format(TI18N("<img src=%s visible=true scale=0.3 /> <div fontColor=#ffffff fontsize=22 > %s</div>"), PathTool.getItemRes(item_icon), num)
    self.ten_gold_label:setString(str)
    self.mainContainer:addChild(self.ten_gold_label)

    self.gold_btn = self.mainContainer:getChildByName("gold_btn")
    local label = self.gold_btn:getChildByName("label")
    label:setString(self.ten_cost_config.desc)  
    label:setLocalZOrder(99)

    self.call_btn = self.mainContainer:getChildByName("call_btn")
    local label = self.call_btn:getChildByName("label")
    label:setString(self.one_cost_config.desc)
    label:setLocalZOrder(99)

    self.item_container = self.mainContainer:getChildByName("item_container_1")
    local img = self.item_container:getChildByName("img")
    self.item_label_1 = self.item_container:getChildByName("label")

    self.item_config_1 = Config.StarDivinationData.data_divination_const.up_item 
    if self.item_config_1 then
        local item_config = Config.ItemData.data_get_data(self.item_config_1.val)
        if item_config then
            loadSpriteTexture(img, PathTool.getItemRes(item_config.icon), LOADTEXT_TYPE)
        end
    end

    self.other_item_container = self.mainContainer:getChildByName("item_container_2")
    local img = self.other_item_container:getChildByName("img") 
    self.item_label_2 = self.other_item_container:getChildByName("label")
    self.item_config_2 = Config.StarDivinationData.data_divination_const.exchange_item 
    if self.item_config_2 then
        local item_config = Config.ItemData.data_get_data(self.item_config_2.val)
        if item_config then
            loadSpriteTexture(img, PathTool.getItemRes(item_config.icon), LOADTEXT_TYPE)
        end
    end

    self:createDesc()
end

function AuguryWindow:register_event()
    self.close_btn:addTouchEventListener(function(sender, event_type) 
        customClickAction(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playCloseSound()
            controller:openMainView(false)
        end
    end)
    self.item_container:addTouchEventListener(function(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            if self.item_config_1 then
                BackpackController:getInstance():openTipsSource(true, self.item_config_1.val)
            end
        end
    end)
    self.other_item_container:addTouchEventListener(function(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            if self.item_config_2 then
                BackpackController:getInstance():openTipsSource(true, self.item_config_2.val)
            end
        end
    end)
    self.flash_btn:addTouchEventListener(function(sender, event_type) 
        customClickAction(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            local now_tower = StartowerController:getInstance():getModel():getNowTowerId() or 0
            if now_tower <10 then 
                message(TI18N("无需刷新，当前仅可抽取白羊座命格"))
                return
            end
            controller:openAlertWidnow(true,3)
        end
    end)
    self.gold_btn:addTouchEventListener(function(sender, event_type) 
        customClickAction(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            if self.is_play_effect then return end
            playButtonSound2()
            controller:openAlertWidnow(true,2)
        end
    end)
    self.call_btn:addTouchEventListener(function(sender, event_type) 
        customClickAction(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            if self.is_play_effect then return end
            playButtonSound2()
            local free_status = controller:getModel():checkHaveFreeTimes()
            if free_status == true then
			    controller:sender11331(1,1)
            else
                controller:openAlertWidnow(true,1)
            end
        end
    end)

    for k, tab in pairs(self.tab_list) do
        tab.btn:addTouchEventListener(function(sender, event_type)
            customClickAction(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                playButtonSound2()
                self:clickBtn(tab.index)
            end
        end)
    end

    if not self.augury_success_event then 
        self.augury_success_event = GlobalEvent:getInstance():Bind(AuguryEvent.Augury_Success_Event,function(data)
            self.success_data =data
            self:playActionEffect(data)
        end)
    end

    if not self.update_data_event then 
        self.update_data_event = GlobalEvent:getInstance():Bind(AuguryEvent.Update_Event,function()
            --当前运势
            local luck = controller:getModel():getLuck() or 0
            local config = Config.StarDivinationData.data_divination_flash_name[luck] 
            if config then
                self.now_lucky:setString(string.format(TI18N("当前运势：<div fontcolor=#cc6031>%s</div>"),config.star_name))
                self.tips_desc:setString(string.format(TI18N("获得%s座命格几率提升"),config.star_name))
            end
            
            -- 单次召唤状态,因为可能存在免费
            self:checkOneCallStatus()
            local count = controller:getModel():getLessCount() or 0
            --必出次数
            self.call_num:setString(string.format(TI18N("再抽<div fontcolor=#35ff14>%s</div>次"),count))
            if self.is_init == true then
                self:handleEffect(true)
                self.is_init = false
                local quality = controller:getModel():getQuality() or 1
                if self.old_quality ~= quality then 
                    self:createQualityEffect(quality)
                    self.old_quality = quality
                end
            end
        end)
    end

    if not self.goods_add_event then
        self.goods_add_event = GlobalEvent:getInstance():Bind(BackpackEvent.ADD_GOODS, function(bag_code, item_list) 
            if bag_code ~= BackPackConst.Bag_Code.BACKPACK then return end
            if self.item_config_1 == nil then return end
            for k,v in pairs(item_list) do
                if v.base_id == self.item_config_1.val then
                    self:updateItemSum()
                    break
                end
            end

        end)
    end

    if not self.goods_update_event then
        self.goods_update_event = GlobalEvent:getInstance():Bind(BackpackEvent.MODIFY_GOODS_NUM, function(bag_code, item_list) 
            if bag_code ~= BackPackConst.Bag_Code.BACKPACK then return end
            if self.item_config_1 == nil then return end
            for k,v in pairs(item_list) do
                if v.base_id == self.item_config_1.val then
                    self:updateItemSum()
                    break
                end
            end

        end)
    end

    if self.role_assets_event == nil then
        if self.role_vo == nil then
            self.role_vo = RoleController:getInstance():getRoleVo()
        end
        if self.role_vo then
            self.role_assets_event = self.role_vo:Bind(RoleEvent.UPDATE_ROLE_ATTRIBUTE,function(key ,value) 
                if key == "star_point" then
                    self:updateHaveAssert()
                end
            end)
        end
    end
end

function AuguryWindow:createDesc()
    local size = self.container:getContentSize()
    --当前运势
    self.now_lucky = createRichLabel(26, cc.c4b(0x6a,0x40,0x22,0xff), cc.p(0,0), cc.p(245,200), 0, 0, 500)
    self.container:addChild(self.now_lucky)

    --再抽x次必出xx
    self.call_num = createRichLabel(26, cc.c4b(0xff,0xd7,0x77,0xff), cc.p(0.5,0), cc.p(size.width/2,67), 0, 0, 500)
    self.container:addChild(self.call_num)
    self.must_label = createRichLabel(26, cc.c4b(0xff,0xd7,0x77,0xff), cc.p(0.5,0), cc.p(size.width/2,33), 0, 0, 500)
    self.must_label:setString(string.format(TI18N("必出紫色以上命格")))
    self.container:addChild(self.must_label)
 
    --tips描述
    self.tips_desc = createRichLabel(24, Config.ColorData.data_color4[175], cc.p(0.5,0), cc.p(360,160), 0, 0, 500)
    self.container:addChild(self.tips_desc)  
end

function AuguryWindow:updateHaveAssert()
    if self.role_vo == nil then return end
    self.item_label_2:setString(self.role_vo.star_point or 0)
end

function AuguryWindow:updateItemSum()
    if self.item_config_1 == nil then return end
    local sum = backpack_model:getBackPackItemNumByBid(self.item_config_1.val)
    self.item_label_1:setString(sum )
end

function AuguryWindow:openRootWnd()
    controller:sender11330()
    self.is_play_effect = false
    -- 更新星魂积分
    self:updateHaveAssert()
    self:updateItemSum()
end

function AuguryWindow:checkOneCallStatus()
    local free_status = controller:getModel():checkHaveFreeTimes()
    if free_status == true then
        self.one_call_label:setString(TI18N("本次免费"))
    else
        if self.one_cost_config then
            local item_icon = Config.ItemData.data_get_data(self.one_cost_config.val[1]).icon
            local num = self.one_cost_config.val[2]
            local str = string.format(TI18N("<img src=%s visible=true scale=0.3 /> <div fontColor=#ffffff fontsize=22 > %s</div>"), PathTool.getItemRes(item_icon), num)
            self.one_call_label:setString(str) 
        end
    end
end

--[[
    @desc: 切换标签页
    author:{author}
    time:2018-05-03 21:58:15
    --@type: 
    return
]]

function AuguryWindow:clickBtn(index)
    index = index or 1
    if index == 1 then --规则说明
        MainuiController:getInstance():openCommonExplainView(true, Config.StarDivinationData.data_explain,TI18N("规则说明"))
    elseif index ==2 then --星命塔
        MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.main_scene, MainuiConst.sub_type.startower) 
    elseif index ==3 then--星命背包
    elseif index ==4 then--星命商店
    end
end

function AuguryWindow:handleEffect(status)    
    if status == false then
        for k,v in pairs(self.effect_cache_list) do
           v:removeFromParent()
        end
        self.effect_cache_list = {}
    else
        local effect_list = {{ res = Config.EffectData.data_effect_info[137], is_loop = true, action = PlayerAction.action,pos=cc.p(360,457)}
                            ,{ res = Config.EffectData.data_effect_info[138], is_loop = true, action = PlayerAction.action_6,pos=cc.p(270,425)}
                            ,{ res = Config.EffectData.data_effect_info[138], is_loop = true, action = PlayerAction.action_7,pos=cc.p(-150,430)}
                            }
        for i,v in ipairs(effect_list) do
            delayRun(self.container, (i-1)*5/display.DEFAULT_FPS, function()
                self.effect_cache_list[i] = createEffectSpine(v.res, v.pos, cc.p(0.5, 0.5), v.is_loop, v.action) 
                if i == 1 then
                    self.container:addChild(self.effect_cache_list[i], i)
                elseif i == 2 then 
                    self.call_btn:addChild(self.effect_cache_list[i], i)
                elseif i == 3 then
                    self.gold_btn:addChild(self.effect_cache_list[i], i) 
                end
            end)
        end
    end
end
function AuguryWindow:createQualityEffect(quality)
    if not tolua.isnull(self.quality_effect) then
        self.quality_effect:removeFromParent()
        self.quality_effect = nil
    end

    local effect_name =  Config.EffectData.data_effect_info[138]
    self.quality_effect = createSpineByName(effect_name)
    local true_quality = self.quality_list[quality] or 1
    local action = "action"..true_quality
    self.quality_effect:setAnimation(0, action, true)
    self.container:addChild(self.quality_effect,10)
    self.quality_effect:setPosition(cc.p(360,454))
end

--播放占卜特效

function AuguryWindow:playActionEffect()
    if self.is_play_effect then return end
    self.is_play_effect = true
    self.effect_panel:setVisible(true)
    self.effect_panel:setTouchEnabled(true)

    local function one_fun()
        if self.he_effect then
            self.he_effect:runAction(cc.RemoveSelf:create(true)) 
            self.he_effect = nil
        end
    end
    
    local effect_id = Config.EffectData.data_effect_info[139]
    local true_quality = self.quality_list[self.old_quality]
    local action = "action"..true_quality
    self.he_effect = createEffectSpine(effect_id, cc.p(360, 485), cc.p(0.5, 0.5), false, action, one_fun, cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888)
    self.effect_panel:addChild(self.he_effect, 1)

    local function animationEventFunc(event)
        if event.eventData.name == "appear" then
            self:playEffect()
        end
    end
    self.he_effect:registerSpineEventHandler(animationEventFunc, sp.EventType.ANIMATION_EVENT)
end

function AuguryWindow:playEffect()
    local function func()
        if self.boom_effect then
            self.boom_effect:runAction(cc.RemoveSelf:create(true)) 
            self.boom_effect = nil
            self.is_play_effect = false
        end
        self.effect_panel:setVisible(false)
        self.effect_panel:setTouchEnabled(false)
    end
    
    local effect_id = Config.EffectData.data_effect_info[139]
    local action = "action6"
    self.boom_effect = createEffectSpine(effect_id, cc.p(360, 485), cc.p(0.5, 0.5), false, action, func, cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888)
    self.boom_effect:setAnimation(0, action, true)
    self.effect_panel:addChild(self.boom_effect, 1)
   
    local function animationEventFunc(event)
        if event.eventData.name == "appear" then
            controller:openGetWidnow(true,self.success_data)
            local quality = controller:getModel():getQuality() or 1
            if self.old_quality ~= quality then 
                self:createQualityEffect(quality)
                self.old_quality = quality
            end
        end
    end
    self.boom_effect:registerSpineEventHandler(animationEventFunc, sp.EventType.ANIMATION_EVENT)
end

--[[
    @desc: 设置标签页面板数据内容
    author:{author}
    time:2018-05-03 21:57:09
    return
]]
function AuguryWindow:setPanelData()
end

function AuguryWindow:close_callback()
    self.is_play_effect = false
    if self.role_assets_event then
        if self.role_vo then
            self.role_vo:UnBind(self.role_assets_event)
        end
        self.role_assets_event = nil
    end
    self.role_vo = nil

    if self.goods_add_event then
        GlobalEvent:getInstance():UnBind(self.goods_add_event)
        self.goods_add_event = nil
    end
    if self.goods_update_event then
        GlobalEvent:getInstance():UnBind(self.goods_update_event)
        self.goods_update_event = nil
    end
    controller:openMainView(false)
    if self.augury_success_event then 
        GlobalEvent:getInstance():UnBind(self.augury_success_event)
        self.augury_success_event = nil
    end
    if self.update_data_event then
        GlobalEvent:getInstance():UnBind(self.update_data_event)
        self.update_data_event = nil
    end
    self:handleEffect(false)
    if not tolua.isnull(self.quality_effect) then
        self.quality_effect:removeFromParent()
        self.quality_effect = nil
    end
end
