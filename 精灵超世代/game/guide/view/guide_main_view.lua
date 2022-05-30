-- --------------------------------------------------------------------
-- 引导的主界面,主要是一个裁剪的面板,这个容器是最上一层,特效id E51050
-- 
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @editor: shiraho@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2017-xx-xx
-- --------------------------------------------------------------------
GuideMainView = GuideMainView or class("GuideMainView", function()
	return ccui.Layout:create()
end)

function GuideMainView:ctor(ctrl)
    self.ctrl = ctrl
    self.is_open = false
    self.ticket = GlobalTimeTicket:getInstance()
    self.is_true_start = false
    self.had_move = false
    self.time_num = 0           -- 超时计时器
    self.time_interval = 10

    self.size = cc.size(display.width, display.height)
    self.center = cc.p(SCREEN_WIDTH/2, SCREEN_HEIGHT/2)
	self:setAnchorPoint(cc.p(0.5,0.5))
	self:setContentSize(self.size)
	self:setCascadeOpacityEnabled(true)
    self:setTouchEnabled(true)
	self:setPosition(self.center)

    self.skip_btn = createImage(self, PathTool.getResFrame("common","txt_cn_common_30011"), display.width - 90, display.height - 126, cc.p(0.5, 0.5), true, 10)
    self.skip_btn:setTouchEnabled(true)
    breatheShineAction(self.skip_btn)

    self:registerEvent()
end

function GuideMainView:open(config)
    --xprint("GuideMainView:open")
    if self.is_open == true then return end
    if config == nil or config.act == nil or next(config.act) == nil then return end
	self.is_open = true
	if self:getParent() == nil then
		ViewManager:getInstance():addToLayerByTag(self, ViewMgrTag.MSG_TAG)
	end
    self.target = nil
    self.root_wnd = nil
    self.act_config = config
    self.act_list = deepCopy(config.act)

    self.cur_zone_list = {}

    self.need_save = FALSE
    self.guide_step = 0
    self.guide_cache_data = RoleEnv:getInstance():get(RoleEnv.keys.guide_step_list, {})

    self:playNextGuide()
end

function GuideMainView:registerEvent()
    self.skip_btn:addTouchEventListener(function(sender, event_type)
        customClickAction(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            self:endPlayGuide(true)
        end
    end)

    self:addTouchEventListener(function(sender, event_type)
        if self.wait_delay ~= 0 then return end
        if event_type == ccui.TouchEventType.began then
            local pos = sender:getTouchBeganPosition()
            pos = self:convertToNodeSpace(pos)
            if self.rect then
                if cc.rectContainsPoint( self.rect, pos ) then
                    self:setSwallowTouches(false)
                else
                    self:showGuideNotice()
                    self:setSwallowTouches(true)
                end
            end
        end
    end)
end

--==============================--
--desc:点击之后立马设置吞噬掉点击
--time:2018-07-27 10:35:43
--@return 
--==============================--
function GuideMainView:checkDoNextGuide()
    if not tolua.isnull(self.target) then
        self.target:setTouchEnabled(false)
    end
    self:setSwallowTouches(true)
    self.rect = nil

    if self.need_save == FALSE then
        self:readyDoNextGuide()
    else
        if self.act_config == nil then
            self:endPlayGuide()
            return
        end
        self.ctrl:checkNetWorkNormal(self.act_config.id, self.guide_step)
    end
    -- 关闭所有窗体
    if self.close_all == TRUE then
        BaseView.closeAllView()
    end
end

--==============================--
--desc:关键步
--time:2017-08-17 03:09:26
--@id:
--@step:
--@return 
--==============================--
function GuideMainView:doNextGuideFromServer(id, step)
    if self.act_config == nil then return end
    if self.act_config.id ~= id or self.guide_step ~= step then return end
    self:readyDoNextGuide()
end

--==============================--
--desc:当前引导步骤操作完成,准备执行下一波
--time:2017-08-18 09:29:49
--@return 
--==============================--
function GuideMainView:readyDoNextGuide()
    if self.notice_container and not tolua.isnull(self.notice_container) then
        self.notice_container:setVisible(false)
    end
    if self.backgroundLayer and not tolua.isnull(self.backgroundLayer) then
        self.backgroundLayer:setVisible(false)
    end
    if self.clipNode and not tolua.isnull(self.clipNode) then
        self.clipNode:setVisible(false)
    end
    if self.guide_effect and not tolua.isnull(self.guide_effect) then
        doStopAllActions(self.guide_effect)
        self.guide_effect:setVisible(false)
    end
    if self.guide_tips_bg and not tolua.isnull(self.guide_tips_bg) then
        self.guide_tips_bg:setVisible(false)
    end
    if self.txt_tips and not tolua.isnull(self.txt_tips) then
        self.txt_tips:setVisible(false)
    end
    if self.target and not tolua.isnull(self.target) and self.target.clearGuideListener then
        self.target:clearGuideListener()
    end
    if self.delay == 0 then
        self:playNextGuide()
    else
        self:delayPlayNextGuide(self.delay)
    end
end

--==============================--
--desc:延迟执行下一步引导
--time:2017-08-18 09:30:23
--@delay:
--@return 
--==============================--
function GuideMainView:delayPlayNextGuide(delay)
    local function call_back()
        self:playNextGuide()
    end
    self.ticket:remove("delayPlayNextGuide")
    self.ticket:add(call_back, delay, 1, "delayPlayNextGuide")
end

--==============================--
--desc:储存引导
--time:2017-08-10 09:56:50
--@return 
--==============================--
function GuideMainView:saveGuideStep()
    -- 储存关键步
    if self.need_save ~= FALSE then
        if self.guide_cache_data[self.act_config.id] == nil then
            self.guide_cache_data[self.act_config.id] = {}
        end
        self.guide_cache_data[self.act_config.id][self.guide_step] = true
        RoleEnv:getInstance():set(RoleEnv.keys.guide_step_list, self.guide_cache_data, true)
    end

    -- 达到某一个关键步之后,把关联区间的所有步骤都设置已完成状态,本次无效,下次有效
    if self.act_config ~= nil and self.act_config.special_step ~= 0 and next(self.act_config.special_step) ~= nil then
        for i,v in ipairs(self.act_config.special_step) do
            local target_step = v[1] or 0
            local min_step = v[2] or 0
            local max_step = v[3] or 0
            if target_step == self.guide_step then
                if self.guide_cache_data[self.act_config.id] == nil then
                    self.guide_cache_data[self.act_config.id] = {}
                end
                for index=min_step,max_step do
                    if not self.guide_cache_data[self.act_config.id][index] then
                        self.guide_cache_data[self.act_config.id][index] = true
                        self.cur_zone_list[index] = true
                    end
                end
                RoleEnv:getInstance():set(RoleEnv.keys.guide_step_list, self.guide_cache_data, true)
                break
            end
        end
    end
    -- 如果有客户端完成步,则表示完成
    if self.act_config ~= nil and self.act_config.over_step ~= 0 and self.act_config.over_step == self.guide_step then
        if self.guide_cache_data[self.act_config.id] == nil then
            self.guide_cache_data[self.act_config.id] = {}
        end
        self.guide_cache_data[self.act_config.id][RoleEnv.keys.guide_over_step] = true
        RoleEnv:getInstance():set(RoleEnv.keys.guide_step_list, self.guide_cache_data, true)
    end
end

--==============================--
--desc:开始播放引导下一步
--time:2017-08-10 09:52:49
--@return 
--==============================--
function GuideMainView:playNextGuide()
    self:saveGuideStep()
    self:clearTargetInfo()
    if self.act_list == nil or next(self.act_list) == nil then
        self:endPlayGuide()
    else
        self.target_data = table.remove(self.act_list, 1)
        self.guide_step = self.guide_step + 1
        -- 判断当前步骤是否已经做过了,
        if self.guide_cache_data[self.act_config.id] and self.guide_cache_data[self.act_config.id][self.guide_step] == true and not self.cur_zone_list[self.guide_step]  then
            self:playNextGuide()
        else
            if self.target_data ~= nil and type(self.target_data) == "table" then
                local first_act = self.target_data[1]
                if first_act == "checkstatus" then
                    self:findRootWndByParams4()
                elseif first_act == "openview" then
                    self:findRootWndByParams3()
                elseif first_act == "conditonstatus" then
                    self:findRootWndByCondition()
                elseif first_act == "emptystep" then    -- 占位步数
                    self:playNextGuide()
                else
                    if #self.target_data == 2 then
                        self:findRootWndByParams2()
                    else
                        self:findTargetByParams()
                    end
                end
                -- 超过5秒就出现跳过引导
                self:addSkipTimeTicket()
            end
        end
    end
end

function GuideMainView:findTargetByParams()
    if self.target_data ~= nil and type(self.target_data) == "table" then
        local target_type = self.target_data[1]              -- 是根据名字查找还是根据tag查找
        self.delay = self.target_data[2] or 0                -- 处理完当前引导之后,到下一个引导的间隔事件
        local target_name = self.target_data[3]              -- 需要查找的对象的标志,可能是name或者tag
        local target_clickback = self.target_data[4] or 0    -- 是否是自身点击返回
        self.need_save = self.target_data[5] or 0            -- 如果需要保存的话,那么就要配置这个步骤为1,如果是2就是记录自己,并且记录上一步,同时如果这个需要记录,则会跟服务器交互,一般是消耗材料的步骤
        self.close_all = self.target_data[6] or 0            -- 是否需要关闭所有窗体
        self.wait_delay = self.target_data[7] or 0           -- 如果配置了时间,则表示这一步,不是需要点击处理的,而是等这个时间自动下一步
        self.show_guide_step = self.target_data[8] or TRUE   -- 有一类窗体不需要显示也不需要显示手指到的,这个时候就用这个参数控制
        self.figer_off_x = self.target_data[9] or 0          -- 引导的偏移x
        self.figer_off_y = self.target_data[10] or 0         -- 引导的偏移y
        local strMsgId = self.target_data[11]          -- 引导描述框的内容描述
        if strMsgId and Config.DramaData.data_guide_desc[strMsgId] then
           self.guide_msg = Config.DramaData.data_guide_desc[strMsgId].desc
        else
            self.guide_msg = ""
        end
        
        self.sprite_off_x = self.target_data[12] or 0        -- 引导描述框的偏移x
        self.sprite_off_y = self.target_data[13] or 0        -- 引导描述框的偏移y
        self.sprite_flip = self.target_data[14] or 0         -- 引导描述框的翻转
        self.bg_opacity = self.target_data[15] or 100        -- 压黑背景透明度
        self.sound_name = self.target_data[16] or ""         -- 引导音效

        if target_type == "name" then
            self.target = findNodeByName(self.root_wnd, target_name)
        elseif target_type == "tag" then
            self.target = findNodeByTag(self.root_wnd, tonumber(target_name))
        end
        local function click_callback()
            self:checkDoNextGuide()
        end
        self.time_num = self.time_num + 1
        self:removeTimer()
        if not tolua.isnull(self.target) and (self.target.isVisible and self.target:isVisible()) then
            self:drawTargetRect()
            if self.wait_delay == 0 then
                if target_clickback == TRUE then
                    self.target.guide_call_back = click_callback
                else
                    if self.target.addTouchGuideListener then
                        self.target:addTouchGuideListener(function(sender) 
                            if sender == self.target then
                                self:checkDoNextGuide()
                            end
                        end)
                    end
                end
            end
        else
            if self.time_num >= self.time_interval then
                self:endPlayGuide(true)
            else
                self.add_timer = GlobalTimeTicket:getInstance():add(function() 
                    self:findTargetByParams()
                end, 1, 1)
            end
        end
    end
end

--==============================--
--desc:条件判断,
--time:2018-06-28 11:22:41
--@return 
--==============================--
function GuideMainView:findRootWndByCondition()
    if self.target_data == nil or self.target_data[4] == nil then return end
    local root_name = self.target_data[2]
    self.delay = self.target_data[3]
    local root_wnd = nil
    if root_name == "partner" then
        root_wnd = HeroController:getInstance():getHeroBagRoot()
    elseif root_name == "battletopscene" then
        root_wnd = BattleDramaController:getInstance():getBattleDramaUI()
    elseif root_name == "battlesceneview" then
        root_wnd = BattleController:getInstance():getCtrlBattleScene() 
    elseif root_name == "checkmainui" then
        local btn_index = MainuiController:getInstance():getMainUIIndex()
        if btn_index ~= MainuiConst.btn_index.main_scene then
            root_wnd = MainuiController:getInstance():getMainUiRoot()
        end
    elseif root_name == "adventurescene" then
        root_wnd = AdventureController:getInstance():getAdventureRoot()
    elseif root_name == "partnerform" then
        root_wnd = HeroController:getInstance():getHeroFormRoot()
    elseif root_name == "partnereinfoview" then
        root_wnd = HeroController:getInstance():getHeroMianInfoRoot()
    elseif root_name == "partnergofight" then
        root_wnd = HeroController:getInstance():getHeroGoFightRoot()
    elseif root_name == "hallowsactivitywindow" then
        root_wnd = HallowsController:getInstance():getHallowsActivityRoot()
    elseif root_name == "hallowspreview" then
        root_wnd = HallowsController:getInstance():getHallowsPreviewRoot()
    elseif root_name == "hallowswindow" then
        root_wnd = HallowsController:getInstance():getHallowsRoot()
    elseif root_name == "adventureevtview" then
        root_wnd = AdventureController:getInstance():getAdventureEvtRoot()
    elseif root_name == "esecsiceview" then
        root_wnd = EsecsiceController:getInstance():getEsecsiceRoot()
    elseif root_name == "stonedunview" then
        root_wnd = Stone_dungeonController:getInstance():getStoneDungeonRoot()
    elseif root_name == "varietystoreview" then
        root_wnd = MallController:getInstance():getVarietyStoreRoot()
    elseif root_name == "homeworldscene" then
        root_wnd = HomeworldController:getInstance():getHomeworldRoot()
    elseif root_name == "homeworldshop" then
        root_wnd = HomeworldController:getInstance():getHomeShopRoot()
    elseif root_name == "homemyunit" then
        -- 家园中的仓库是否在显示中
        if HomeworldController:getInstance():getHomeEditStatus() then
            root_wnd = HomeworldController:getInstance():getHomeworldRoot()
        end
    elseif root_name == "trainingcampview" then
        root_wnd = TrainingcampController:getInstance():getTrainingcampRoot()
    elseif root_name == "areascene" then
        root_wnd = Area_sceneController:getInstance():getAreaSceneRoot()
    elseif root_name == "planesmainview" then
        root_wnd = PlanesController:getInstance():getPlanesMainRoot()
    elseif root_name == "planesinfoview" then
        root_wnd = PlanesController:getInstance():getPlanesInfoRoot()
    elseif root_name == "elfinSelectview" then
        root_wnd = ElfinController:getInstance():getElfinSelectRoot()
    elseif root_name == "heavenmainview" then
        root_wnd = HeavenController:getInstance():getHeavenMainWindowRoot()
    elseif root_name == "equipclothview" then
        root_wnd = HeroController:getInstance():getHeroHolyEquipClothPanelRoot()
    elseif root_name == "adventureactivityview" then
        root_wnd = AdventureActivityController:getInstance():getAdventureActivityWindowRoot()
    elseif root_name == "heroresonateiew" then
        root_wnd = HeroController:getInstance():getHeroResonateWindowRoot()
    end

    
    if root_wnd == nil then -- 这个时候走第二种
        local act_list = self.target_data[4][2]
        if act_list and next(act_list) then
            self.act_list = DeepCopy(act_list)
            self.guide_step = 0
        end
    else
        self.root_wnd = root_wnd
        local act_list = self.target_data[4][1]
        if act_list and next(act_list) then
            self.act_list = DeepCopy(act_list)
            self.guide_step = 0
        end
    end
    self:playNextGuide()
end

--==============================--
--desc:根据4个参数查找对象,主要用于主场景的移动顺便只想对象以及检测窗体状态
--time:2017-08-21 10:14:38
--@return 
--==============================--
function GuideMainView:findRootWndByParams4()
    if self.target_data == nil then return end
    local root_name = self.target_data[2]
    local taget_id = self.target_data[3]
    self.delay = self.target_data[4]
    if root_name == "centercity" then
        local target = MainSceneController:getInstance():getCenterCityBuildById(taget_id)
        if target ~= nil then -- 还没有创建建筑的时候不要做移动或者选中处理
            self.root_wnd = MainSceneController:getInstance():getMainCenterScene()
            GlobalEvent:getInstance():Fire(SceneEvent.MoveToBuildEvent, taget_id, false, self.delay)
        end
    end        
    self.time_num = self.time_num + 1
    self:removeTimer()
    if not tolua.isnull(self.root_wnd) and (self.root_wnd.isVisible and self.root_wnd:isVisible()) then
        if self.delay == 0 then
            self:playNextGuide()
        else
            self:delayPlayNextGuide(self.delay)
        end
    else
        if self.time_num >= self.time_interval then
            self:endPlayGuide(true)
        else
            self.add_timer = GlobalTimeTicket:getInstance():add(function() 
                self:findRootWndByParams4()
            end, 1, 1)
        end
    end
end

--==============================--
--desc:控制打开一个面板
--time:2018-08-02 03:10:33
--@return 
--==============================--
function GuideMainView:findRootWndByParams3()
    if self.target_data == nil then return end
    local root_name = self.target_data[2]
    self.delay = self.target_data[3]
    if root_name == "firstrecharge" then
        ActionController:getInstance():openFirstChargeView(true)
    elseif root_name == "newfirstrecharge" or root_name == "newfirstrecharge1" or root_name == "newfirstrecharge2" or root_name == "newfirstrecharge3" then
        NewFirstChargeController:getInstance():openNewFirstChargeView(true)
    elseif root_name == "limittimeview" then
        LimitTimeActionController:getInstance():openLimitTimeGiftWindow(true)
    end    
    if self.delay == 0 then
        self:playNextGuide()
    else
        self:delayPlayNextGuide(self.delay)
    end   
end

--==============================--
--desc:根据2个参数查找对象,找不到的话 每1秒找一次,直到查找到
--time:2017-08-21 10:07:38
--@return 
--==============================--
function GuideMainView:findRootWndByParams2()
    if self.target_data ~= nil and type(self.target_data) == "table" and #self.target_data == 2 then
        local root_name = self.target_data[1]
        self.delay = self.target_data[2] or 0
        if root_name == "mainui" then
            self.root_wnd = MainuiController:getInstance():getMainUiRoot()
        elseif root_name == "summon" then
            self.root_wnd = PartnersummonController:getInstance():getSummonRoot() 
        elseif root_name == "summonresult" then
            self.root_wnd = PartnersummonController:getInstance():getSummonResultRoot()
        elseif root_name == "partner" then
            self.root_wnd = HeroController:getInstance():getHeroBagRoot()
        elseif root_name == "partnerform" then
            self.root_wnd = HeroController:getInstance():getHeroFormRoot()
        elseif root_name == "battlesceneview" then
            self.root_wnd = BattleController:getInstance():getCtrlBattleScene() 
        elseif root_name == "partnereinfoview" then
            self.root_wnd = HeroController:getInstance():getHeroMianInfoRoot()
        elseif root_name == "partnergofight" then
            self.root_wnd = HeroController:getInstance():getHeroGoFightRoot()
        elseif root_name == "battlequickview" then
            self.root_wnd = BattleDramaController:getInstance():getDramBattleQuickRoot() 
        elseif root_name == "battletophookrewards" then
            self.root_wnd = BattleDramaController:getInstance():getDramaBattleHookRewardRoot()
        elseif root_name == "battletoppassrewards" then
            self.root_wnd = BattleDramaController:getInstance():getDramaBattlePassRewardRoot()
        elseif root_name == "battletopscene" then
            self.root_wnd = BattleDramaController:getInstance():getBattleDramaUI()
        elseif root_name == "getitemview" then
            self.root_wnd = MainuiController:getInstance():getItemExhibtionRoot() 
        elseif root_name == "backpack" then
            self.root_wnd = BackpackController:getInstance():getBackpackRoot() 
        elseif root_name == "backpacksell" then
            self.root_wnd = BackpackController:getInstance():getBackpackSellRoot()
        elseif root_name == "arenaloopview" then
            self.root_wnd = ArenaController:getInstance():getArenaRoot()
        elseif root_name == "guildinitview" then
            self.root_wnd = GuildController:getInstance():getGuildInitRoot()
        elseif root_name == "startowerview" then
            self.root_wnd = StartowerController:getInstance():getStarTowerRoot() 
        elseif root_name == "startowerchallengeview" then
            self.root_wnd = StartowerController:getInstance():getStarTowerChallengeRoot() 
        elseif root_name == "auguryview" then
            self.root_wnd = AuguryController:getInstance():getAuguryRoot()
        elseif root_name == "summonshowview" then
            self.root_wnd = PartnersummonController:getInstance():getSummonShowRoot() 
        elseif root_name == "mallview" then
            self.root_wnd = MallController:getInstance():getMallRoot() 
        elseif root_name == "adventurescene" then
            self.root_wnd = AdventureController:getInstance():getAdventureRoot()
        elseif root_name == "adventureevtview" then
            self.root_wnd = AdventureController:getInstance():getAdventureEvtRoot()
        elseif root_name == "adventurenextfloor" then
            self.root_wnd = AdventureController:getInstance():getNextAlertRoot()
        elseif root_name == "battleqingbaoview" then
            self.root_wnd = BattleDramaController:getInstance():getBattleQingbaoRoot() 
        elseif root_name == "tipssourceroot" then
            self.root_wnd = BackpackController:getInstance():getItemTipsSourceRoot() 
        elseif root_name == "skybattleresult" then
            self.root_wnd = BattleController:getInstance():getFinishView(BattleConst.Fight_Type.Adventrue)
        elseif root_name == "activitywindow" then
            self.root_wnd = ActivityController:getInstance():getActivityRoot()
        elseif root_name == "hallowswindow" then
            self.root_wnd = HallowsController:getInstance():getHallowsRoot()
        elseif root_name == "hallowsactivitywindow" then
            self.root_wnd = HallowsController:getInstance():getHallowsActivityRoot()
        elseif root_name == "hallowspreview" then
            self.root_wnd = HallowsController:getInstance():getHallowsPreviewRoot()
        elseif root_name == "comptipsview" then
            self.root_wnd = TipsManager:getInstance():getCompTipsRoot()
        elseif root_name == "esecsiceview" then
            self.root_wnd = EsecsiceController:getInstance():getEsecsiceRoot()
        elseif root_name == "stonedunview" then
            self.root_wnd = Stone_dungeonController:getInstance():getStoneDungeonRoot()
        elseif root_name == "varietystoreview" then
            self.root_wnd = MallController:getInstance():getVarietyStoreRoot()
        elseif root_name == "sevenloginview" then
            self.root_wnd = ActionController:getInstance():getSevenLoginRoot()
        elseif root_name == "welfareview" then
            self.root_wnd = WelfareController:getInstance():getWelfareRoot()
        elseif root_name == "treasureview" then
            self.root_wnd = ActionController:getInstance():getTreasureRoot()
        elseif root_name == "voyageview" then
            self.root_wnd = VoyageController:getInstance():getVoyageMainRoot()
        elseif root_name == "strongerview" then
            self.root_wnd = StrongerController:getInstance():getStrongerRoot()
        elseif root_name == "seerpalaceview" then
            self.root_wnd = SeerpalaceController:getInstance():getSeerpalaceMainRoot()
        elseif root_name == "voyagedispatchview" then
            self.root_wnd = VoyageController:getInstance():getVoyageDispatchRoot()
        elseif root_name == "homeworldscene" then
            self.root_wnd = HomeworldController:getInstance():getHomeworldRoot()
        elseif root_name == "homeworldshop" then
            self.root_wnd = HomeworldController:getInstance():getHomeShopRoot()
        elseif root_name == "homeworldshopbuy" then
            self.root_wnd = HomeworldController:getInstance():getHomeworldBuyRoot()
        elseif root_name == "homeworldunlockkey" then
            self.root_wnd = HomeworldController:getInstance():getHomeworldUnlockKey()
        elseif root_name == "trainingcampview" then
            self.root_wnd = TrainingcampController:getInstance():getTrainingcampRoot()
        elseif root_name == "areascene" then
            self.root_wnd = Area_sceneController:getInstance():getAreaSceneRoot()
        elseif root_name == "planesmainview" then
            self.root_wnd = PlanesController:getInstance():getPlanesMainRoot()
        elseif root_name == "planesinfoview" then
            self.root_wnd = PlanesController:getInstance():getPlanesInfoRoot()
        elseif root_name == "elfinSelectview" then
            self.root_wnd = ElfinController:getInstance():getElfinSelectRoot()
        elseif root_name == "heavenmainview" then
            self.root_wnd = HeavenController:getInstance():getHeavenMainWindowRoot()
        elseif root_name == "equipclothview" then
            self.root_wnd = HeroController:getInstance():getHeroHolyEquipClothPanelRoot()
        elseif root_name == "adventureactivityview" then
            self.root_wnd = AdventureActivityController:getInstance():getAdventureActivityWindowRoot()
        elseif root_name == "heroresonateiew" then
            self.root_wnd = HeroController:getInstance():getHeroResonateWindowRoot()
        end 
        self.time_num = self.time_num + 1
        self:removeTimer()   
        
        if not tolua.isnull(self.root_wnd) and (self.root_wnd.isVisible and self.root_wnd:isVisible()) then
            if self.delay == 0 then
                self:playNextGuide()
            else
                self:delayPlayNextGuide(self.delay)
            end
        else
            if self.time_num >= self.time_interval then
                self:endPlayGuide(true)
            else
                self.add_timer = GlobalTimeTicket:getInstance():add(function() 
                    self:findRootWndByParams2()
                end, 1, 1)
            end
        end
    end
end

function GuideMainView:removeTimer()
    if self.add_timer ~= nil then
        GlobalTimeTicket:getInstance():remove(self.add_timer)
        self.add_timer = nil
    end
end

function GuideMainView:removeSkipTimeTicket()
    if self.skip_time_ticket ~= nil then
        GlobalTimeTicket:getInstance():remove(self.skip_time_ticket)
        self.skip_time_ticket = nil
    end
    if not tolua.isnull(self.skip_btn) then
        self.skip_btn:setVisible(false)
    end
end

function GuideMainView:addSkipTimeTicket()
    if self.act_config.skip == TRUE then
        if self.skip_time_ticket == nil then
            self.skip_time_ticket = GlobalTimeTicket:getInstance():add(function() 
                if not tolua.isnull(self.skip_btn) then
                    self.skip_btn:setVisible(true)
                end
            end, 5, 1)
        end
    end
end

--==============================--
--desc:移到结束,每一步写进缓存中区
--time:2017-07-27 11:13:24
--@return 
--==============================--
function GuideMainView:endPlayGuide(is_skip)
    if self.act_config then
        self.ctrl:startPlayGuide(false, self.act_config.id, is_skip)
    end
end

function GuideMainView:clearTargetInfo()
    if not tolua.isnull(self.target) then
        self.target:setTouchEnabled(true)
        if self.target.guide_call_back ~= nil then
            self.target.guide_call_back = nil
        end
    end 
    self:removeTimer()
    self:removeSkipTimeTicket()
    self.cur_pos = nil
    self.need_save = FALSE
    self.target = nil
    self.delay = 0
    self.step = 0
    self.time_num = 0
end

--==============================--
--desc:绘画下一个引导的区域
--time:2017-06-06 04:19:34
--return 
--==============================--
function GuideMainView:drawTargetRect()
    if tolua.isnull(self.target) then
        self:endPlayGuide(true)
        return
    end
    local world_pos = self.target:convertToWorldSpace(cc.p(0, 0))
    print("world_pos",world_pos.x, world_pos.y)
    local size = self.target:getContentSize()
    local scale = 1
    if self.target.getScale ~= nil then
        scale = self.target:getScale()
    end
    -- 转换到本地坐标
    world_pos = self:convertToNodeSpace(world_pos)
    print("world_pos",world_pos.x, world_pos.y, size.width, size.height)

    self.rect = cc.rect(world_pos.x, world_pos.y, size.width, size.height)
    self.cur_pos = cc.p(world_pos.x + scale * size.width / 2  + self.figer_off_x, world_pos.y + scale * size.height / 2 + self.figer_off_y)

    -- 播放引导音效
    if self.sound_name and self.sound_name ~= "" then
        AudioManager:getInstance():stopAllSoundByType(AudioManager.AUDIO_TYPE.Drama)
        AudioManager:getInstance():playEffect(AudioManager.AUDIO_TYPE.Drama, self.sound_name, false)
    end

    -- 这种情况下,既不需要显示小精灵又不需要显示提示
    if self.show_guide_step == TRUE then
        local last_pos = GuideController:getInstance():getGuideLastPos()
        if self.guide_effect == nil then
            local action_name = PlayerAction.action_1
            if last_pos then
                action_name = PlayerAction.action_2
            end
            self.guide_effect = createEffectSpine(PathTool.getEffectRes(240), last_pos or self.cur_pos, cc.p(0.5, 0.5), true, action_name)
            self:addChild(self.guide_effect)
        else
            self.guide_effect:setVisible(true)
        end
        if last_pos then
            self.guide_effect:setToSetupPose()
            self.guide_effect:setAnimation(0, PlayerAction.action_2, true)
            local pos_x, pos_y = self.guide_effect:getPosition()
            local distance = math.sqrt(math.pow((pos_x-self.cur_pos.x), 2)+math.pow((pos_y-self.cur_pos.y), 2))
            local move_time = distance/GuideConst.Finger_Speed
            if move_time < GuideConst.Finger_Min_Time then
                move_time = GuideConst.Finger_Min_Time
            end
            local move_act = cc.MoveTo:create(move_time, self.cur_pos)
            local function callback(  )
                if self.guide_effect then
                    self.guide_effect:setAnimation(0, PlayerAction.action_1, true)
                end
            end
            local sequence = cc.Sequence:create(move_act, cc.CallFunc:create(callback))
            self.guide_effect:runAction(sequence)
        end
        GuideController:getInstance():setGuideLastPos(self.cur_pos)

        -- 小精灵
        if self.guide_msg ~= "" then
            self:showLittleSpiritAndTips(world_pos, size, scale)
            --self:showBackGroundLayer(true)

            -- 当有小精灵时，手指特效与裁剪延迟0.5秒出现
            if self.guide_effect then
                self.guide_effect:setVisible(true)
                self:showNoticeContainer()

                --[[self.guide_effect:setVisible(false)
                delayRun(self.guide_effect, 0.5, function ()
                    self.guide_effect:setVisible(true)
                    self:showBackGroundLayer(false)
                    self:showNoticeContainer()
                end)--]]
            end
        else
            --self:showBackGroundLayer(false)
            self:showNoticeContainer()
        end
    end

    -- 这个是非操作类的引导需要这么去弄个
    if self.wait_delay ~= 0 then
        self:delayPlayNextGuide(self.wait_delay)
    end
end

function GuideMainView:DeleteMe()
    doStopAllActions(self.skip_btn)
    self:clearTargetInfo()
    self.ticket:remove("delayPlayNextGuide")
    if not tolua.isnull(self.guide_effect) then
		self.guide_effect:setVisible(false)
		self.guide_effect:clearTracks()
		self.guide_effect:runAction(cc.RemoveSelf:create(true)) 
        self.guide_effect = nil
    end
    if not tolua.isnull(self.touch_effect) then
        self.touch_effect:setVisible(false)
        self.touch_effect:clearTracks()
        self.touch_effect:runAction(cc.RemoveSelf:create(true)) 
        self.touch_effect = nil
    end
    if not tolua.isnull(self.guide_tips_bg) then
        self.guide_tips_bg:removeAllChildren()
        self.guide_tips_bg:removeFromParent()
        self.guide_tips_bg = nil
    end
    if not tolua.isnull(self.txt_tips) then
        self.txt_tips:removeAllChildren()
        self.txt_tips:removeFromParent()
        self.txt_tips = nil
    end
	self:removeAllChildren()
	self:removeFromParent()
end

function GuideMainView:clearTouchEffect()
    if not tolua.isnull(self.touch_effect) then
        self.touch_effect:setVisible(false)
        self.touch_effect:clearTracks()
        self.touch_effect:runAction(cc.RemoveSelf:create(true)) 
        self.touch_effect = nil
    end
    --[[if not tolua.isnull(self.notice_container) then
        self.notice_container:setVisible(false)
    end--]]
end

--==============================--
--desc:当有引导目标的时候，点击的不是引导目标，则提示一个目标区域特效
--time:2017-08-13 01:37:23
--@return 
--==============================--
function GuideMainView:showGuideNotice()
    self:clearTouchEffect()
    if self.cur_pos == nil then return end
    local function finish_callback(event)
        self:clearTouchEffect()
    end
    local res_id = Config.EffectData.data_effect_info[198]
    if res_id and res_id ~= "" then
        self:showNoticeContainer()

        if not tolua.isnull(self.notice_container) then
            local draw = createSprite(PathTool.getResFrame("common","common_1032"), self.cur_pos.x, self.cur_pos.y, nil, cc.p(0.5, 0.5))
            self.notice_container:setStencil(draw)

            self.touch_effect = createEffectSpine( res_id, self.cur_pos, cc.p(0.5,0.5), false, PlayerAction.action, finish_callback)
            self.notice_container:addChild(self.touch_effect)
        end
    end
end

-- 创建 notice_container
function GuideMainView:showNoticeContainer(  )
    if self.cur_pos == nil then return end
    if self.notice_container == nil then
        self.notice_container = cc.ClippingNode:create()
        self.notice_container:setAnchorPoint(cc.p(0.5,0.5))
        self.notice_container:setContentSize(self.size)
        self.notice_container:setCascadeOpacityEnabled(true)
        self.notice_container:setPosition(self.size.width/2, self.size.height/2)
        self.notice_container:setInverted(true)
        self.notice_container:setAlphaThreshold(0)
        self:addChild(self.notice_container, -1)

        local draw = createSprite(PathTool.getResFrame("common","common_1032"), self.cur_pos.x, self.cur_pos.y, nil, cc.p(0.5, 0.5))
        self.notice_container:setStencil(draw)

        local background = ccui.Layout:create()
        background:setAnchorPoint(cc.p(0.5,0.5))
        background:setContentSize(self.size)
        background:setPosition(self.size.width/2, self.size.height/2) 
        background:setTouchEnabled(false)
        --showLayoutRect(background, self.bg_opacity)
        self.notice_background = background
        self.notice_container:addChild(background)
    else
        if not tolua.isnull(self.notice_background) then
            --showLayoutRect(self.notice_background, self.bg_opacity)
        end
        if not tolua.isnull(self.notice_container) then
            local draw = createSprite(PathTool.getResFrame("common","common_1032"), self.cur_pos.x, self.cur_pos.y, nil, cc.p(0.5, 0.5))
            self.notice_container:setStencil(draw)
            self.notice_container:setVisible(true)
        end
    end
end

-- 显示/隐藏一个压黑背景层
function GuideMainView:showBackGroundLayer( isShow )
    isShow = isShow or false
    if not self.backgroundLayer then
        self.backgroundLayer = ccui.Layout:create()
        self.backgroundLayer:setAnchorPoint(cc.p(0.5,0.5))
        self.backgroundLayer:setContentSize(self.size)
        self.backgroundLayer:setPosition(self.size.width/2, self.size.height/2) 
        self.backgroundLayer:setTouchEnabled(false)
        self:addChild(self.backgroundLayer, -1)
    end
    --showLayoutRect(self.backgroundLayer, self.bg_opacity)
    self.backgroundLayer:setVisible(isShow)
end

-- 显示小精灵和文字提示
function GuideMainView:showLittleSpiritAndTips( targetWorldPos, targetSize, targetScale )
    if self.guide_tips_bg == nil then
        self.guide_tips_bg = createImage(self, PathTool.getResFrame("common","common_30010"), nil, nil, cc.p(0.5,0.5),true,nil,true)
        self.guide_tips_bg:setCapInsets(cc.rect(10,10,1,1))
    end
    local bgSize = getTextBgSizeByTextContent( self.guide_msg, 20, 40, 20, 280, 24, 10)
    self.guide_tips_bg:setContentSize(bgSize)

    if self.sprite_flip == 1 then
        self.guide_tips_bg:setScaleX(1)
    elseif self.sprite_flip == 0 then
        self.guide_tips_bg:setScaleX(-1)
    end

    if self.txt_tips == nil then
        self.txt_tips = createRichLabel(20, Config.ColorData.data_new_color4[6], cc.p(0.5, 0.5), nil, 10, nil, 280)
        self:addChild(self.txt_tips)
    end
    --[[if self.guide_sprite == nil then
        self.guide_sprite = createImage(self.guide_tips_bg, PathTool.getResFrame("mainui","mainui_guide_sprite"), nil, nil, cc.p(0.5,0.5),true)
        self.guide_sprite:setPosition(cc.p(-49, -3))
    end--]]
 
    local bgPos = self:getGuideTipsBgPos(targetWorldPos, targetSize, targetScale, bgSize)
    self.guide_tips_bg:setPosition(bgPos)
    self.txt_tips:setString(self.guide_msg)
    self.txt_tips:setPosition(cc.p(bgPos.x, bgPos.y+10))
    
    self.guide_tips_bg:setVisible(true)
    self.txt_tips:setVisible(true)
    --self.guide_sprite:setVisible(true)
end

-- 获取文字框提示合适的位置
function GuideMainView:getGuideTipsBgPos( targetWorldPos, targetSize, targetScale, bgSize )
    local margin = 30 -- 文字背景与目标的高度间距
    local offset_l = 40 -- 文字背景与屏幕左边边缘最小边距
    local offset_r = 40 -- 文字背景与屏幕右边边缘最小边距
    local bgPosx = targetWorldPos.x + targetSize.width/2*targetScale + bgSize.width/4 + 55
    local bgPosY = targetWorldPos.y + bgSize.height/2 + margin + targetSize.height*targetScale

    -- x坐标
    if (bgPosx+bgSize.width/2+offset_r) > display.width then -- 超出右边界
        bgPosx = bgPosx - ((bgPosx+bgSize.width/2+offset_r)-display.width)
    elseif (bgPosx-bgSize.width/2-offset_l) < 0 then -- 超出左边界
        bgPosx = offset_l+bgSize.width/2
    end
    -- y坐标
    if (bgPosY + bgSize.height/2 + offset_r) > display.height then -- 超出上边界
        bgPosY = targetWorldPos.y - targetSize.height/2*targetScale - margin - bgSize.height/2
    end

    bgPosx = bgPosx + self.sprite_off_x
    bgPosY = bgPosY + self.sprite_off_y
    return cc.p(bgPosx, bgPosY)
end

-- 获取小精灵合适的位置(暂时保留，怕策划后续要求支持单独调整小精灵的位置)
function GuideMainView:getGuideSpritePos( spriteSize, bgSize, bgPos )
    local spritePosX = -20
    local spritePosY = -10
    local isFlip = false -- 是否要水平翻转
    if bgPos.x - math.abs(spritePosX) - bgSize.width/2 - spriteSize.width/2 < 0 then -- 超出左边界
        spritePosX = bgSize.width + 20
        isFlip = true
    end
    if bgPos.y - bgSize.height/2 - math.abs(spritePosY) - spriteSize.height/2 < 0 then -- 超出下边界
        spritePosY = spritePosY - (bgPos.y - bgSize.height/2 - math.abs(spritePosY) - spriteSize.height/2)
    end

    spritePosX = spritePosX + self.sprite_off_x
    spritePosY = spritePosY + self.sprite_off_y

    return cc.p(spritePosX, spritePosY), isFlip
end


