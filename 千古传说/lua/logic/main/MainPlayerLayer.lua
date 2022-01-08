--[[
******团队信息面板*******

    -- by haidong.gan
    -- 2014/6/14
]]

local MainPlayerLayer = class("MainPlayerLayer", BaseLayer)

--CREATE_SCENE_FUN(MainPlayerLayer)
CREATE_PANEL_FUN(MainPlayerLayer)


function MainPlayerLayer:ctor()
    self.super.ctor(self,data)
    self:init("lua.uiconfig_mango_new.main.MainPlayerLayer")
end


function MainPlayerLayer:initUI(ui)
	self.super.initUI(self,ui)



    self.btn_close      = TFDirector:getChildByPath(ui, 'btn_close')
    self.btn_rename     = TFDirector:getChildByPath(ui, 'btn_rename')
    self.btn_setting    = TFDirector:getChildByPath(ui, 'btn_shezhi')

    self.txt_sycee      = TFDirector:getChildByPath(ui, 'txt_sycee')
    self.txt_coin       = TFDirector:getChildByPath(ui, 'txt_coin')
    self.txt_zhenqi     = TFDirector:getChildByPath(ui, 'txt_zhenqi')
    self.txt_power      = TFDirector:getChildByPath(ui, 'txt_power')

    self.txt_vip        = TFDirector:getChildByPath(ui, 'txt_vip')
    self.img_vip        = TFDirector:getChildByPath(ui, 'img_vip')

    self.txt_id         = TFDirector:getChildByPath(ui, 'Label_MainPlayerLayer_1')
    self.txt_name       = TFDirector:getChildByPath(ui, 'txt_name')
    self.txt_level      = TFDirector:getChildByPath(ui, 'txt_level')
    self.bar_exp        = TFDirector:getChildByPath(ui, 'bar_exp')
    self.txt_exp        = TFDirector:getChildByPath(ui, 'txt_exp')

    self.txt_equip_max    = TFDirector:getChildByPath(ui, 'txt_equip_max')
    self.txt_level_max    = TFDirector:getChildByPath(ui, 'txt_level_max')
    self.txt_role_max     = TFDirector:getChildByPath(ui, 'txt_role_max')
    self.zhaunhuanBtn     = TFDirector:getChildByPath(ui, 'btn_genhuanzhujue')
    self.btn_SetHeadIcon  = TFDirector:getChildByPath(ui, 'btn_genhuantouxiang')
    self.btn_SetFrame     = TFDirector:getChildByPath(ui, 'btn_genhuanbiankuang-Copy1')

    self.bg_touxiang    = TFDirector:getChildByPath(ui, 'bg_touxiang')
    self.touxiang       = TFDirector:getChildByPath(ui, 'Image_MainPlayerLayer_1')

    self.node_pointArr        = {}
    self.txt_timesValue_arr   = {}
    self.txt_timeLeft_arr     = {}
    for i=1,4 do
        self.node_pointArr[i] = TFDirector:getChildByPath(ui, 'img_point_' .. i)
        self.txt_timesValue_arr[i] = TFDirector:getChildByPath(self.node_pointArr[i], 'txt_value')
        self.txt_timeLeft_arr[i] = TFDirector:getChildByPath(self.node_pointArr[i], 'txt_time')
    end
    self.node_pointArr[4]:setVisible(false) 
    self.img_head     = TFDirector:getChildByPath(ui, 'img_icon')

    --added by wuqi
    self.img_new_vip = TFDirector:getChildByPath(ui, "img_new_vip")
    self.btn_tequan = TFDirector:getChildByPath(ui, "btn_VIPtequan")
    self.btn_tequan.logic = self
end

--added by wuqi
function MainPlayerLayer:addVipEffect(btn)
    if btn.effect then
        btn.effect:removeFromParent()
        btn.effect = nil
    end
    local vipLevel = MainPlayer:getVipLevel()
    if vipLevel <= 18 then  --if vipLevel <= 15 or vipLevel > 18 then -- modify by zr 关掉高VIP特效
        return
    end
    local resPath = "effect/ui/vip_" .. vipLevel .. ".xml"
    TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
    local effect = TFArmature:create("vip_" .. vipLevel .. "_anim")
    effect:setAnimationFps(GameConfig.ANIM_FPS)
    effect:setPosition(ccp(btn:getContentSize().width / 2, btn:getContentSize().height / 2))
    effect:setVisible(true)
    effect:setScale(0.8)
    effect:playByIndex(0, -1, -1, 1)
    btn:addChild(effect, 200)
    btn.effect = effect
end

function MainPlayerLayer:onShow()
    self.super.onShow(self)
    self:refreshBaseUI();
    self:refreshUI();
    self:refreshTiemsUI();
end

function MainPlayerLayer:refreshBaseUI()

    self:refreshTiemsUI();

    self.onUpdated = function(event)
        self:refreshTiemsUI();
    end;

    if not  self.nTimerId then
        self.nTimerId = TFDirector:addTimer(1000, -1, nil, self.onUpdated); 
    end
end

function MainPlayerLayer:refreshUI()
    if not self.isShow then
        return;
    end

    if CommonManager:isTuhao() then
        self.btn_tequan:setVisible(true)
    else
        self.btn_tequan:setVisible(false)
    end
    
    self.img_vip:setVisible(true)
    self.img_new_vip:setVisible(false)

    if MainPlayer:getVipLevel() > 0 then 
        self.img_vip:setVisible(true)
        self.txt_vip:setText("o"..MainPlayer:getVipLevel())

        local vipLevel = MainPlayer:getVipLevel()
        --modify by zr VIP等级显示
        --[[if vipLevel > 15 then
            self.txt_vip:setVisible(false)
            self.img_new_vip:setVisible(true)
            self:addVipEffect(self.img_new_vip)
        end]]--
    else
        self.img_vip:setVisible(false)
        self.img_new_vip:setVisible(false)
    end

    self.txt_sycee:setText(MainPlayer:getSycee())
    self.txt_coin:setText(MainPlayer:getCoin())
    self.txt_zhenqi:setText(MainPlayer:getZhenqi())
    -- self.img_head:setTexture(MainPlayer:getBigImagePath())
    self.img_head:setTexture("ui_new/team/team_role_" .. MainPlayer:getProfession() .. ".png")
    self.touxiang:setTexture(MainPlayer:getIconPath())
    Public:addFrameImg(self.touxiang,MainPlayer:getHeadPicFrameId())
    
    self.txt_id:setText(MainPlayer:getPlayerId())
    self.txt_name:setText(MainPlayer:getPlayerName())
    -- self.txt_level:setText(MainPlayer:getLevel() .. "d:")
    self.txt_level:setText(MainPlayer:getLevel())
    self.txt_power:setText(StrategyManager:getPower())

    local expcur = MainPlayer:getExpCur()
    local expmax = MainPlayer:getExpMax()
    if expmax == 0 then
        --self.txt_exp:setText("满级")
        self.txt_exp:setText(localizable.common_max_level)
        self.bar_exp:setPercent(100)
    else
        self.txt_exp:setText(expcur .. "/" .. expmax)
        self.bar_exp:setPercent( expcur/expmax*100)
    end

    --self.txt_role_max:setText("上阵人数：" .. StrategyManager:getFightRoleNum() .. "/" .. StrategyManager:getMaxNum())
    self.txt_role_max:setText(stringUtils.format(localizable.common_person, StrategyManager:getFightRoleNum() , StrategyManager:getMaxNum() ))
    --self.txt_equip_max:setText("装备强化上限：".. ConstantData:getValue("Equip.StrengthenMax.Multiple")*MainPlayer:getLevel() .."级")
    self.txt_equip_max:setText(stringUtils.format(localizable.common_equip_max, ConstantData:getValue("Equip.StrengthenMax.Multiple")*MainPlayer:getLevel() ))
    --self.txt_level_max:setText("侠客等级上限：".. ConstantData:getValue("Role.LevelMax.Multiple")*MainPlayer:getLevel() .."级")
    self.txt_level_max:setText(stringUtils.format(localizable.common_player_max, ConstantData:getValue("Role.LevelMax.Multiple")*MainPlayer:getLevel() ))
   
   
    CommonManager:setRedPoint(self.btn_SetFrame, HeadPicFrameManager:haveFirstGetFrame(),"haveFirstGetFrame",ccp(10,0))

    local b = CommonManager:isTuhao() and CommonManager:getTuhaoFreeTimes() > 0 
    if b then
        CommonManager:updateRedPoint(self.btn_tequan, true, ccp(self.btn_tequan:getSize().width / 2 - 35, self.btn_tequan:getSize().height / 2 - 25))  
    else
        CommonManager:removeRedPoint(self.btn_tequan)
    end 
end

function MainPlayerLayer:refreshTiemsUI()
    for type=1,3 do
        local pointInfo =  MainPlayer:GetChallengeTimesInfo(type)

        local leftChallengeTimes = pointInfo:getLeftChallengeTimes()
        self.txt_timesValue_arr[type]:setText(leftChallengeTimes)
        if pointInfo.cdLeaveTimeOjb then
            local leftCoolTime = pointInfo.cdLeaveTimeOjb:getOneRecoverTime()
            if leftCoolTime > 0 and leftChallengeTimes  < pointInfo.maxValue then
                self.txt_timeLeft_arr[type]:setVisible(true)
                self.txt_timeLeft_arr[type]:setText(pointInfo.cdLeaveTimeOjb:getOneRecoverTimeString())
            else
                self.txt_timeLeft_arr[type]:setVisible(false)
            end
        else
            self.txt_timeLeft_arr[type]:setVisible(false)
        end
    end
end

function MainPlayerLayer:removeUI()

    self.super.removeUI(self)
end


function MainPlayerLayer.onRenameClickHandle(sender)
    local self = sender.logic

    CommonManager:showReNameLayer();
end

--added by wuqi
function MainPlayerLayer.onVipTequanClickHandle(sender)
    if not CommonManager:isTuhao() then
        toastMessage(localizable.common_vip_not_tuhao1)
        return
    end
    local self = sender.logic
    CommonManager:showTuhaoPopLayer(
        function(data)            
            NotifyManager:addTuhaoChatNotify(MainPlayer:getPlayerName(), data, MainPlayer:getVipLevel())
        end,
        function()            
        end,
        {
            title = localizable.mainPlayerLayer_tuhao_xuanyan,
            msg = msg,
            MaxLength = 40,
        }
    )
end

function MainPlayerLayer.onSettingClickHandle(sender)
    local self = sender.logic
    SettingManager:showSettingLayer()
end

function MainPlayerLayer.onSetHeadIconClick(sender)
    local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.main.ChangeIconLayer",AlertManager.BLOCK_AND_GRAY_CLOSE,AlertManager.TWEEN_1)
    AlertManager:show();
end

function MainPlayerLayer.onSetFramePicClick(sender)
    HeadPicFrameManager:OpenChangeIconLayer()
    local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.main.HeadPicFrameLayer",AlertManager.BLOCK_AND_GRAY_CLOSE,AlertManager.TWEEN_1)
    AlertManager:show();
end

function MainPlayerLayer.onZhuanhuanClickHandle(sender)
    SettingManager:showZhuanhuanLayer()
end

function MainPlayerLayer:registerEvents()
    self.super.registerEvents(self);
    ADD_ALERT_CLOSE_LISTENER(self, self.btn_close);

    self.btn_close:setClickAreaLength(100);

    self.btn_rename.logic = self;
    self.btn_rename:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onRenameClickHandle),1);


    self.btn_setting.logic = self;
    self.btn_setting:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onSettingClickHandle),1);


    self.updateChallengeTimesCallBack = function(event)
        self:refreshBaseUI();
    end;
    TFDirector:addMEGlobalListener(MainPlayer.ChallengeTimesChange ,self.updateChallengeTimesCallBack ) ;

    self.updateFrameCallBack = function(event)
        Public:addFrameImg(self.touxiang,MainPlayer:getHeadPicFrameId());
    end;
    TFDirector:addMEGlobalListener(HeadPicFrameManager.Change_Frame ,self.updateFrameCallBack);

    self.zhaunhuanBtn:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onZhuanhuanClickHandle),1);
    self.btn_SetHeadIcon:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onSetHeadIconClick),1);
    self.btn_SetFrame:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onSetFramePicClick),1);

    self.btn_tequan:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onVipTequanClickHandle), 1);
end

function MainPlayerLayer:removeEvents()
    TFDirector:removeMEGlobalListener(MainPlayer.ChallengeTimesChange,self.updateChallengeTimesCallBack);
    TFDirector:removeMEGlobalListener(HeadPicFrameManager.Change_Frame,self.updateFrameCallBack);
    if self.nTimerId then
        TFDirector:removeTimer(self.nTimerId);
        self.nTimerId = nil;
    end

    --     if self.nTimerId then
    --     TFDirector:removeTimer(self.nTimerId)
    --     self.nTimerId = nil
    -- end
    self.super.removeEvents(self);
end

return MainPlayerLayer
