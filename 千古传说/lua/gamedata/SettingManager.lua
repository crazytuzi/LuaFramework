--[[
******设置管理类*******

	-- by haidong.gan
	-- 2013/12/27
]]


local SettingManager = class("SettingManager")


SettingManager.EVENT_PAY_COMPLETE = "SettingManager.EVENT_PAY_COMPLETE";
SettingManager.changeProfessionSuccess = "SettingManager.changeProfessionSuccess"
SettingManager.SETTING_SAVE_CONFIG_RESULT = "SettingManager.SETTING_SAVE_CONFIG_RESULT"

--added by wuqi
SettingManager.text_vip = localizable.settingManager_text_vip

--聊天时vip等级为127则隐藏其vip标志
SettingManager.TAG_VIP_YINCANG = 127

function SettingManager:ctor()
    TFDirector:addProto(s2c.SETTING_CONFIG, self, self.onReceiveSettingConfig);
    TFDirector:addProto(s2c.SETTING_SAVE_CONFIG_RESULT, self, self.onReceiveSaveConfigResult);
    TFDirector:addProto(s2c.SETTING_SEND_BUG_RESULT, self, self.onReceiveSendBugResult);
    TFDirector:addProto(s2c.CHANGE_PROFESSION_RESULT, self, self.onChangeProfessionSuccess);

    self.helpList   = require("lua.table.t_s_help");
    self.contact    = require("lua.table.t_s_text");
    self.activitie  = require("lua.table.t_s_activites_tips");
    self.pushList  = require("lua.table.t_s_events");

    --added by wuqi
    --self.bHideVip = true
    --TFDirector:send(c2s.SETTING_GET_CONFIG, {} );

    self:loadConfigFromFile();
end

function SettingManager:onReceiveSettingConfig( event )
    print("onReceiveSettingConfig")
    print(event.data)

    hideLoading();

    --self.settingConfig = event.data;

    print("{{{{{{{{{{{{{{{ setting = ", event.data.vipVisible)

    --self.bHideVip = (not event.data.vipVisible) or true
    self.bShowVip = event.data.vipVisible or false
end

function SettingManager:onReceiveSaveConfigResult( event )
    print("onReceiveSaveConfigResult")
    print(event.data)

    hideLoading();

    if event.data.isSuccess then        
        if self:isVipShow() then 
            self:changeVipShow()          
            toastMessage(localizable.settingManager_text_not_show_vip)
        else
            self:changeVipShow()
            toastMessage(localizable.settingManager_text_show_vip)
        end
    else
        toastMessage(localizable.settingManager_change_fail)
    end
end

function SettingManager:onReceiveSendBugResult( event )
    print("onReceiveSendBugResult")
    print(event.data)

    hideLoading();
    AlertManager:close();
    -- toastMessage("发送成功");
    toastMessage(localizable.SettingManager_send_suc)
end

function SettingManager:gotoLoginLayer()
    MainPlayer:reset()
    CommonManager:closeConnection()
    print("SettingManager:gotoLoginLayer SceneType.LOGINNOTICE = ", SceneType.LOGINNOTICE)
    AlertManager:changeScene(SceneType.LOGINNOTICE)
    -- AlertManager:changeScene(SceneType.LOGIN)

end

function SettingManager:gotoUpdateLayer()
    MainPlayer:reset()
    CommonManager:closeConnection()
    if TFClientResourceUpdate == nil then 
        local UpdateLayer   = require("lua.logic.login.UpdateLayer")
        AlertManager:changeScene(UpdateLayer:scene())
    else
        print("SettingManager:gotoUpdateLayer 有最新的更新功能 用最新的")
        local UpdateLayer   = require("lua.logic.login.UpdateLayer_new")
        AlertManager:changeScene(UpdateLayer:scene())
    end
end

function SettingManager:LoginOut()
    print("SettingManager:LoginOut()")
    AlertManager:clearAllCache()
    CommonManager:closeConnection()
    -- if TFPlugins.isPluginExist()  then
    --     TFPlugins.LoginOut()
    -- else
    --     AlertManager:changeScene(SceneType.LOGIN)
    -- end
    if TFPlugins.isPluginExist()  then
        TFPlugins.LoginOut()

    elseif HeitaoSdk then
        -- MainPlayer:reset()
        -- AlertManager:changeScene(SceneType.LOGINNOTICE)

        if not  self.nTimerIdLoginOut then
            local function loginOut()
                HeitaoSdk.loginOut()

                TFDirector:removeTimer(self.nTimerIdLoginOut)
                self.nTimerIdLoginOut = nil
            end

            self.nTimerIdLoginOut = TFDirector:addTimer(500, -1, nil, loginOut)
        end
        
    else
        print("SettingManager:LoginOut()1111")
        MainPlayer:restart()
        AlertManager:changeSceneForce(SceneType.LOGIN)
    end
end

function SettingManager:getIsOpenMusic()
    return self.settingConfig.isOpenMusic;
end

function SettingManager:getIsOpenVolume()
    return self.settingConfig.isOpenVolume;
end

function SettingManager:getIsOpenChat()
    return self.settingConfig.isOpenChat;
end

function SettingManager:getConfig()
    self:loadConfigFromFile();

    --showLoading();
    --TFDirector:send(c2s.SETTING_GET_CONFIG, {} );
end

function SettingManager:sendBug(content)
    showLoading();
    TFDirector:send(c2s.SETTING_SEND_BUG, {content} );

    -- --测试代码 begin
    -- local event = require("testdata.Setting_s2c")
    -- self:onReceivePlayerList(event.settingEvent);
    -- --测试代码 end
end

--added by wuqi
function SettingManager:sendVipTequanChange()
    showLoading()
    TFDirector:send(c2s.SETTING_SAVE_CONFIG, {true, true, true, not self.bShowVip})
end

function SettingManager:changeVipShow()
    self.bShowVip = not self.bShowVip
end

--added by wuqi
function SettingManager:isVipShow()
    return self.bShowVip
end

--added by wuqi
function SettingManager:getTequanId()
    --在t_s_events中的id
    return 6
end

function SettingManager:changeIsOpenMusic()
    -- showLoading();
    self.settingConfig.isOpenMusic = not self.settingConfig.isOpenMusic;
    self:saveConfigToFile();
    -- self:loadConfigFromFile();
    SimpleAudioEngine:sharedEngine():setBackgroundMusicVolume((self.settingConfig.isOpenMusic and 0.6) or 0);
    if self.settingConfig.isOpenMusic then
        -- toastMessage("音乐已开启");
        toastMessage(localizable.SettingManager_music_open)
    else
        -- toastMessage("音乐已关闭");
        toastMessage(localizable.SettingManager_music_close)
    end

    -- TFDirector:send(c2s.SETTING_SAVE_CONFIG, {isOpenMusic,isOpenVolume,isOpenChat} );
end

function SettingManager:changeIsOpenVolume()
    -- showLoading();
    self.settingConfig.isOpenVolume = not self.settingConfig.isOpenVolume;
    self:saveConfigToFile();
    -- self:loadConfigFromFile();
    SimpleAudioEngine:sharedEngine():setEffectsVolume((self.settingConfig.isOpenVolume and 1) or 0);
    if self.settingConfig.isOpenVolume then
        -- toastMessage("音效已开启");
        toastMessage(localizable.SettingManager_effect_open)
    else
        -- toastMessage("音效已关闭");
        toastMessage(localizable.SettingManager_effect_close)
    end
    -- TFDirector:send(c2s.SETTING_SAVE_CONFIG, {isOpenMusic,isOpenVolume,isOpenChat} );

end

function SettingManager:changeIsOpenChat()
    -- showLoading();
    self.settingConfig.isOpenChat = not self.settingConfig.isOpenChat;
    self:saveConfigToFile();
    -- self:loadConfigFromFile();
    if self.settingConfig.isOpenChat then
        -- toastMessage("聊天提示已开启");
        toastMessage(localizable.SettingManager_chat_open)

    else
        -- toastMessage("聊天提示已关闭");
        toastMessage(localizable.SettingManager_chat_close)
    end
    -- TFDirector:send(c2s.SETTING_SAVE_CONFIG, {isOpenMusic,isOpenVolume,isOpenChat} );
end

function SettingManager:saveConfigToFile()
    CCUserDefault:sharedUserDefault():setBoolForKey("settingConfig.isOpenMusic",not self.settingConfig.isOpenMusic);
    CCUserDefault:sharedUserDefault():setBoolForKey("settingConfig.isOpenVolume",not self.settingConfig.isOpenVolume);
    CCUserDefault:sharedUserDefault():setBoolForKey("settingConfig.isOpenChat",not self.settingConfig.isOpenChat);
        
    CCUserDefault:sharedUserDefault():flush();
end

function SettingManager:loadConfigFromFile()
    self.settingConfig = {};

    self.settingConfig.isOpenMusic = not CCUserDefault:sharedUserDefault():getBoolForKey("settingConfig.isOpenMusic");
    self.settingConfig.isOpenVolume = not CCUserDefault:sharedUserDefault():getBoolForKey("settingConfig.isOpenVolume");
    self.settingConfig.isOpenChat = not CCUserDefault:sharedUserDefault():getBoolForKey("settingConfig.isOpenChat");

    SimpleAudioEngine:sharedEngine():setBackgroundMusicVolume((self.settingConfig.isOpenMusic and 0.6) or 0);
    SimpleAudioEngine:sharedEngine():setEffectsVolume((self.settingConfig.isOpenVolume and 1) or 0);

    --TFDirector:dispatchGlobalEventWith("SettingManager.changeIsOpenChat", {});

    self.settingConfig.pushSwitch = {}
    for v in self.pushList:iterator() do
        self.settingConfig.pushSwitch[v.id] = CCUserDefault:sharedUserDefault():getBoolForKey(v.key);
        if self.settingConfig.pushSwitch[v.id] == nil then
            self.settingConfig.pushSwitch[v.id] = true
        end
    end
end

function SettingManager:restart()

end

function SettingManager:showSettingLayer()
    AlertManager:addLayerByFile("lua.logic.setting.SettingLayer",AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_1);
    AlertManager:show();
end

function SettingManager:showHelpLayer()
    AlertManager:addLayerByFile("lua.logic.setting.HelpLayer",AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_1);
    AlertManager:show();
end

function SettingManager:showActivityLayer()
     --toastMessage("等斌哥哥的活动面板！");
     AlertManager:addLayerByFile("lua.logic.setting.ActivitiesTipsLayer",AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_1);
    AlertManager:show();
end

function SettingManager:showSendBugLayer()
    AlertManager:addLayerByFile("lua.logic.setting.SendBugLayer",AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_1);
    AlertManager:show();
end

function SettingManager:showContactLayer()
    AlertManager:addLayerByFile("lua.logic.setting.ContactLayer",AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_1);
    AlertManager:show();
end
function SettingManager:showExchangeLayer()
    AlertManager:addLayerByFile("lua.logic.setting.ExchangeLayer",AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_1);
    AlertManager:show();
end
function SettingManager:getPushList(index)
    if index == nil then
        return self.pushList
    else
        return self.pushList:objectByID(index)
    end
end

function SettingManager:saveConfigByKeyVaule(key , vaule)
    CCUserDefault:sharedUserDefault():setBoolForKey(key,vaule);
    CCUserDefault:sharedUserDefault():flush();
end
function SettingManager:saveConfigPushById(id , vaule)
    local  pushInfo = self.pushList:objectByID(id)
    self.settingConfig.pushSwitch[id] = vaule
    CCUserDefault:sharedUserDefault():setBoolForKey(pushInfo.key,vaule);
    CCUserDefault:sharedUserDefault():flush();
end

function SettingManager:getConfigPushById( id )
    --changed by wuqi
    if self:getTequanId() == id then
        return not self:isVipShow()
    end
    return self.settingConfig.pushSwitch[id]
end

function SettingManager:addLayerToCache()

end

--显示转职界面
function SettingManager:showZhuanhuanLayer()
    local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.setting.ChangeProfessionLayer",AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_NONE);  
    AlertManager:show();
end

--转职请求
function SettingManager:requestChangeProfession(roleId)
    local Msg = {
        roleId,
    }
    TFDirector:send(c2s.REQUEST_CHANGE_PROFESSION,Msg)
    showLoading()
end

--转职请求成功
function SettingManager:onChangeProfessionSuccess(event)
    hideLoading()
    local role = event.data.info
    --print("event.data1 ==",event.data)
    local cardRole = CardRoleManager:getRoleById(MainPlayer:getProfession())
    if cardRole == nil then
        print("找不到主角啊，怎么破")
        return
    end
    MainPlayer:setProfession(role.id)
    cardRole:initConfig(role.id)
    cardRole.name = MainPlayer:getPlayerName()
    cardRole.gmId  = role.userid;
    cardRole:setSpellLevelIdList(role.spellId);
    cardRole.skillId = role.spellId                 --技能ID
    local equiplist = cardRole:getEquipment():allAsArray()
    for equip in equiplist:iterator() do
        equip.equip = role.id
    end
    cardRole.martialList        = {}
    cardRole.bookAttrAdd = {}
    cardRole:refreshMartial()
    cardRole:RefresAcuPointAttrAdd()
    cardRole:updateStarLevelAttr()
    cardRole:updateSkillAttr()
    cardRole:updateFate()

    -- CardRoleManager:updateCardRoleByChangeProfession(self.beforeId,role)
    TFDirector:dispatchGlobalEventWith(SettingManager.changeProfessionSuccess,{})
end
return SettingManager:new();
