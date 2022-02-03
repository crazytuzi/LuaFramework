-- --------------------------------------------------------------------
-- @author: xhj(必填, 创建模块的人员)
-- @description:
--      精灵重生
-- <br/>Create: 2020年1月2日
--
-- --------------------------------------------------------------------
ActionSpriteResetWindow = class("ActionSpriteResetWindow", function()
    return ccui.Widget:create()
end)

local controller = ActionController:getInstance()
local model = controller:getModel()
local hero_controller = HeroController:getInstance()

function ActionSpriteResetWindow:ctor()
    self.sprite_retrun_items = {}
    self.cur_action_id = 17422
    self.config_list = {}
    self:loadResources()
end

function ActionSpriteResetWindow:loadResources()
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("actionspritereset","actionspritereset"), type = ResourcesType.plist },
        { path = PathTool.getPlistImgForDownLoad("bigbg/action","action_sprite_return_bg", false), type = ResourcesType.single }
    } 
    self.resources_load = ResourcesLoad.New(true) 
    self.resources_load:addAllList(self.res_list, function()
        self:configUI()
        self:register_event()
    end)
end

function ActionSpriteResetWindow:configUI()
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("action/action_sprite_reset_panel"))
    self.root_wnd:setPosition(-40,-80)
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self:setAnchorPoint(0,0)


    self.main_container = self.root_wnd:getChildByName("main_container")
    local res  = PathTool.getPlistImgForDownLoad("bigbg/action", "action_sprite_return_bg",false)
    self.background = self.main_container:getChildByName("background")
    
    if not self.bg_load then
        self.bg_load = createResourcesLoad(res, ResourcesType.single, function()
            if not tolua.isnull(self.background) then
                loadSpriteTexture(self.background, res, LOADTEXT_TYPE)
            end
        end, self.bg_load)
    end

    self.change_btn = self.main_container:getChildByName("change_btn")
    local size = self.change_btn:getContentSize()
    self.change_btn_label = createRichLabel(26, cc.c4b(0xff,0xff,0xff,0xff), cc.p(0.5,0.5), cc.p(size.width * 0.5 ,size.height * 0.5), nil, nil, 900)
    self.change_btn:addChild(self.change_btn_label)
    self.change_btn_label:setString(TI18N("<div outline=2,#764519>重 生</div>"))
    

    self.reset_layout = self.main_container:getChildByName("reset_layout")
    self.time_title_0 = self.reset_layout:getChildByName("time_title_0")
    self.time_title_0:setString(TI18N("获\n得\n预\n览"))
    
    self.item_scrollview = self.main_container:getChildByName("item_scrollview")

    local desc_label = createRichLabel(22, cc.c4b(0xff,0xff,0xff,0xff), cc.p(0.5,0.5), cc.p(360, 230), nil, nil, 9000)
    self.main_container:addChild(desc_label)
    desc_label:setString(TI18N("<div outline=2,#000000>精灵重生会返还全部奥术之尘与一定数量的精灵之魂</div>"))

    self.look_btn = self.main_container:getChildByName("look_btn")
    
    --重生精灵信息
    self.lay_hero = self.main_container:getChildByName("lay_hero")
    self.hero_info_panel = self.lay_hero:getChildByName("hero_info_panel")
    
    self.bg_img = self.lay_hero:getChildByName("bg_img")
    self.mode_node = self.lay_hero:getChildByName("mode_node")
    self.mode_node:setZOrder(2)
    
    self.name = self.hero_info_panel:getChildByName("name")

    if controller:getActionSubTabVo(ActionRankCommonType.sprite_return) then -- 精灵重生
        local info = controller:getActionSubTabVo(ActionRankCommonType.sprite_return)
        self.cur_action_id = info.camp_id
    end
    
    self:initData()
end


function ActionSpriteResetWindow:register_event()
    registerButtonEventListener(self.change_btn, function() self:onChangeBtn() end,true, 1)
    registerButtonEventListener(self.lay_hero, function() self:onResetBtn() end,false, 1)
    registerButtonEventListener(self.look_btn, function(param,sender, event_type) 
        local config =  Config.SpriteData.data_const.reborn_tips
        if config then
            TipsManager:getInstance():showCommonTips(config.desc, sender:getTouchBeganPosition())
        end
    end ,true, 1)


    --精灵重生返回
    if not self.action_sprite_reset_event  then
        self.action_sprite_reset_event = GlobalEvent:getInstance():Bind(ActionEvent.SPRITE_RESET_EVENT,function (data)
            if not data then return end
            self.is_reseting = false
            if data.flag == TRUE then
                self.select_sprite_vo = nil
                self:initData()
            end
        end)
    end

    --精灵选择返回
    if not self.hero_sprite_select_event  then
        self.hero_sprite_select_event = GlobalEvent:getInstance():Bind(ActionEvent.SPRITE_RESET_SELECT_EVENT,function (select_sprite_vo)
            self.select_sprite_vo = select_sprite_vo
            self:initData()
        end)
    end
end


function ActionSpriteResetWindow:onChangeBtn()
    if not self.select_sprite_vo  then
        message(TI18N("请选择重生的精灵"))
        return
    end
    if self.is_reseting  then
        message(TI18N("精灵重生中"))
        return
    end
    if self.sprite_retrun_items and #self.sprite_retrun_items[self.select_sprite_vo.base_id] == 0 then
        self:checkSender()
    elseif self.sprite_retrun_items[self.select_sprite_vo.base_id] then
        hero_controller:openHeroResetOfferPanel(true, self.sprite_retrun_items[self.select_sprite_vo.base_id], false, function()
            self:checkSender()
        end, HeroConst.ResetType.eSpriteReturn)
    end
end

function ActionSpriteResetWindow:initData()
    local data_list = {}
    local setting = {}
    setting.scale = 0.8
    setting.max_count = 4
    setting.is_center = true
    setting.space_x = 20
    local config_list = Config.SpriteData.data_elfin_reset[self.cur_action_id]
    self.config_list = config_list
    if self.select_sprite_vo == nil then
        self.bg_img:setVisible(true)
        
        self.hero_info_panel:setVisible(false)
        self.mode_node:setVisible(false)
        
        self:playCommonEffect(false)
        local config = Config.SpriteData.data_const.reborn_exhibition
        if config then
            data_list = Config.SpriteData.data_const.reborn_exhibition.val
        end
        self.item_list = hero_controller:showSingleRowItemList(self.item_scrollview, self.item_list, data_list, setting)
    else
        self.bg_img:setVisible(false)
        if self.select_sprite_vo.config then
            self.name:setString(self.select_sprite_vo.config.name)
        end
        
        self.hero_info_panel:setVisible(true)

        self.mode_node:setVisible(true)
        self:updateSprite(self.select_sprite_vo)
        
        self:playCommonEffect(true)
        if self.sprite_retrun_items and self.sprite_retrun_items[self.select_sprite_vo.base_id] then
            self.item_list = hero_controller:showSingleRowItemList(self.item_scrollview, self.item_list, self.sprite_retrun_items[self.select_sprite_vo.base_id], setting)
        else
            local list = {}
            if config_list then
                local config_info = config_list[self.select_sprite_vo.base_id]
                if config_info and config_info[1] then
                    list = config_info[1].award
                    self.sprite_retrun_items[self.select_sprite_vo.base_id] = list
                end
            end
            self.item_list = hero_controller:showSingleRowItemList(self.item_scrollview, self.item_list, list, setting)
        end
    end
end

function ActionSpriteResetWindow:updateSprite( sprite_vo )
    if sprite_vo and sprite_vo.config then
        local res = PathTool.getPlistImgForDownLoad("actionspritereset", "sprite_"..sprite_vo.config.icon, false)
        self.item_load = loadSpriteTextureFromCDN(self.mode_node, res, ResourcesType.single, self.item_load)
    end
end

--播放常态效果
function ActionSpriteResetWindow:playCommonEffect(status)
    if status == false then
        if self.play_effect then
            self.play_effect:clearTracks()
            self.play_effect:removeFromParent()
            self.play_effect = nil
        end
    else
        -- AudioManager:getInstance():playEffect(AudioManager.AUDIO_TYPE.COMMON,"c_xianji")
        if self.play_effect == nil then
            self.play_effect = createEffectSpine("E24702", cc.p(75, 45), cc.p(0.5, 0.5), true, PlayerAction.action)
            self.play_effect:setScale(0.8)
            self.lay_hero:addChild(self.play_effect, 1)
        else
            self.play_effect:setAnimation(0, PlayerAction.action, true)
        end
    end
end

--选择重生列表
function ActionSpriteResetWindow:onResetBtn()
    if self.is_reseting then
        return
    end
    -- body
    controller:openActionSpriteResetSelectPanel(true, { select_sprite_vo = self.select_sprite_vo,can_select_sprite_list = self.config_list})
end

function ActionSpriteResetWindow:checkSender()
    if not self.select_sprite_vo then return end
    
    local str = TI18N("请确认需要重生该精灵，重生后该精灵会消失！")
    local call_back = function()
        if tolua.isnull(self.root_wnd) then
            return
        end
        self.is_reseting = true
        
        self:playResetEffect(true)
        delayRun(self.main_container, 1, function()
            controller:send26530(self.select_sprite_vo.base_id)                
        end)
    end
    CommonAlert.show(str, TI18N("确定"), call_back, TI18N("取消"), nil, CommonAlert.type.rich)
end


--播放重生效果
function ActionSpriteResetWindow:playResetEffect(status)
    if status == false then
        if self.play_effect2 then
            self.play_effect2:clearTracks()
            self.play_effect2:removeFromParent()
            self.play_effect2 = nil
        end
    else
        -- AudioManager:getInstance():playEffect(AudioManager.AUDIO_TYPE.COMMON,"c_xianji")
        if self.play_effect2 == nil then
            self.play_effect2 = createEffectSpine("E24701", cc.p(83, 175), cc.p(0.5, 0.5), false, PlayerAction.action)
            self.lay_hero:addChild(self.play_effect2, 3)
        else
            self.play_effect2:setAnimation(0, PlayerAction.action, false)
        end
    end
end

function ActionSpriteResetWindow:setVisibleStatus(bool)
    bool = bool or false
    self:setVisible(bool) 
end


function ActionSpriteResetWindow:DeleteMe()
    if self.resources_load then
		self.resources_load:DeleteMe()
		self.resources_load = nil
    end
    
    if self.item_load then 
        self.item_load:DeleteMe()
        self.item_load = nil
    end

    if self.action_sprite_reset_event then
        GlobalEvent:getInstance():UnBind(self.action_sprite_reset_event)
        self.action_sprite_reset_event = nil
    end

    if self.hero_sprite_select_event then
        GlobalEvent:getInstance():UnBind(self.hero_sprite_select_event)
        self.hero_sprite_select_event = nil
    end

    CommonAlert.closeAllWin()
    if self.item_list ~= nil then
        for k, v in pairs(self.item_list) do
            v:DeleteMe()
        end
    end
    self.item_list = nil
    self:playCommonEffect(false)
    self:playResetEffect(false)

    if self.bg_load ~= nil then
        self.bg_load:DeleteMe()
        self.bg_load = nil
    end
    
end