--[[
******微信*******

]]
local FightLoadingLayer = class("FightLoadingLayer", BaseLayer);

CREATE_SCENE_FUN(FightLoadingLayer);
CREATE_PANEL_FUN(FightLoadingLayer);


function FightLoadingLayer:ctor(data)
    self.super.ctor(self,data);
    self:init("lua.uiconfig_mango_new.mission.Loading");
end

function FightLoadingLayer:initUI(ui)
    self.super.initUI(self,ui);
    self.img_tips   = TFDirector:getChildByPath(ui, 'Img');
    self.txt_tip   = TFDirector:getChildByPath(ui, 'txt_tip');
    self.bg_bar   = TFDirector:getChildByPath(ui, 'bg_bar');
    self.bar_load   = TFDirector:getChildByPath(ui, 'bar_load');
    self.txt_update   = TFDirector:getChildByPath(ui, 'txt_update');
    self.panel_role   = TFDirector:getChildByPath(ui, 'panel_role');
    self.panel_tip   = TFDirector:getChildByPath(ui, 'panel_tip');
    self.img_big   = TFDirector:getChildByPath(ui, 'img_big');

    -- if self.loading == nil then
    --     local resPath = "effect/loading.xml"
    --     TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
    --     local effect = TFArmature:create("loading_anim")

    --     effect:setAnimationFps(GameConfig.ANIM_FPS)
    --     effect:setPosition(ccp(480, 83))

    --     -- self.img_bg:addChild(effect, 1)

    --     self.bg_bar:addChild(effect, 1)
    --     self.loading = effect
    -- end

    -- self.loading:playByIndex(0, -1, -1, 1)

    self:showHelpText()
end

function FightLoadingLayer:onShow()
    self.super.onShow(self)
end


function FightLoadingLayer:removeUI()
   self.super.removeUI(self);
end
--[[
    @param nDelay:定的时间间隔
    @param nRepeatCount:执行的次数, -1表示无限制
    @param timerCompleteCallBackFunc:定时器完成执行的回调函数
    @param timerCallBackFunc:定时器每执行一次所执行的回调函数
    @return 定时器的id
]]
function FightLoadingLayer:setData( nDelay ,nRepeatCount ,timerCompleteCallBackFunc ,timerCallBackFunc )
    if self.timer ~= nil then
        TFDirector:removeTimer(self.timer)
        self.timer = nil
    end
    self.bar_load:setPercent(0)
    local index = 1
    self.bar_timer = TFDirector:addTimer(50 ,-1 ,nil,function ()
        local percent = math.ceil(index/(nRepeatCount-1)*100)
        local now_percent = self.bar_load:getPercent()
        if now_percent < percent then
            now_percent = now_percent + 5
        end
        if now_percent > percent then
            now_percent = percent
        end
        self.bar_load:setPercent(now_percent)
        --self.txt_update:setText("正在载入资源···  "..now_percent.."%")
        self.txt_update:setText(stringUtils.format(localizable.fightLoadingLayer_loading,now_percent))
        if now_percent >= 100 then
            --self.txt_update:setText("载入完成 ，正在进入")
            self.txt_update:setText(localizable.fightLoadingLayer_loading_over)
            TFDirector:removeTimer(self.bar_timer)
            self.bar_timer = nil
        end
    end)

    self.timer = TFDirector:addTimer(nDelay ,nRepeatCount ,timerCompleteCallBackFunc,function()
        TFFunction.call(timerCallBackFunc)
        index = index + 1
    end)
end

--注册事件
function FightLoadingLayer:registerEvents()
    self.super.registerEvents(self);
end

function FightLoadingLayer:removeEvents()
    self.super.removeEvents(self);
    if self.timer ~= nil then
        TFDirector:removeTimer(self.timer)
        self.timer = nil
    end
    if self.bar_timer ~= nil then
        TFDirector:removeTimer(self.bar_timer)
        self.bar_timer = nil
    end
end

function FightLoadingLayer:showHelpText()

    local load_guideList = FightLoadingGuide:getGuildeListByLevel(MainPlayer:getLevel())
    local tips = nil
    while tips == nil do
        local _type = math.random(1, 4)
        if load_guideList[_type] ~= nil then
            local randomTip = math.random(1, load_guideList[_type]:length())
            tips = load_guideList[_type]:objectAt(randomTip)
        end
    end

    -- if tips == nil then
    --     return
    -- end

    if tips.tip_type == 3 then
        self.panel_tip:setVisible(false)
        self.img_big:setVisible(false)
        self.panel_role:setVisible(true)
        self:setHeroLoading( tips ,self.panel_role)
        return
    elseif tips.tip_type == 4 then
        self.panel_tip:setVisible(false)
        self.img_big:setVisible(true)
        self.panel_role:setVisible(false)
        self.img_big:setTexture("ui_new/guide/".. tips.img ..".jpg")
    elseif tips.tip_type == 1 or tips.tip_type == 2 then
        self.panel_tip:setVisible(true)
        self.img_big:setVisible(false)
        self.panel_role:setVisible(false)
        self.img_tips:setTexture("ui_new/guide/".. tips.img ..".jpg")
        local _randomTip = math.random(1, tips.tip_num)
        self.txt_tip:setText(tips["tip".._randomTip])
    end
end

function FightLoadingLayer:setHeroLoading( tip ,panel)
    local role_id = tip.img
    local roleInfo = RoleData:objectByID(role_id)
    if roleInfo == nil then
        print("没有角色数据 id== ",role_id)
        return
    end
 --  local img_role = TFDirector:getChildByPath(panel, 'img_role');
 --  img_role:setTexture(roleInfo:getBigImagePath())
    local armatureID = roleInfo.image
    ModelManager:addResourceFromFile(1, armatureID, 1)
    local model = ModelManager:createResource(1, armatureID)
    model:setPosition(ccp(200,200))
    ModelManager:playWithNameAndIndex(model, "stand", -1, 1, -1, -1)
    panel:addChild(model, 1.2)
    model:setOpacity(255)
    model:setZOrder(-1)

    local img_quality = TFDirector:getChildByPath(panel, 'img_quality');
    img_quality:setTexture(GetFontByQuality( roleInfo.quality ))

    local img_name = TFDirector:getChildByPath(panel, 'img_name');
    img_name:setTexture("ui_new/guide/".. tip.tip1..".png")

    local img_professional = TFDirector:getChildByPath(panel, 'img_professional');
    img_professional:setTexture("ui_new/guide/icon_zy".. roleInfo.outline..".png")
    local txt_professional = TFDirector:getChildByPath(panel, 'txt_professional');
    txt_professional:setText( roleInfo.attr_description)
    local txt_des = TFDirector:getChildByPath(panel, 'txt_des');
    txt_des:setText( roleInfo.description)


    local skillInfo = SkillBaseData:objectByID(roleInfo.skill)
    if skillInfo == nil then
        print("没有技能信息  skill id== ",roleInfo.skill)
        return
    end

    local img_skill = TFDirector:getChildByPath(panel, 'img_skill');
    img_skill:setTexture(skillInfo:GetPath())
    local txt_skill = TFDirector:getChildByPath(panel, 'txt_skill');
    txt_skill:setText( skillInfo.name)
    local skill_des = TFDirector:getChildByPath(panel, 'skill_des');
    skill_des:setText( skillInfo.description)


end

return FightLoadingLayer;