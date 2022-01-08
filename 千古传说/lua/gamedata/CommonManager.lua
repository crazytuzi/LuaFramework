--[[
******公共管理类*******

    -- by haidong.gan
    -- 2013/12/27
]]

local serverList = require('lua.config.server')

local CommonManager = class("CommonManager")

CommonManager.TryReLoginFailTimes = 0

CommonManager.TRY_RECONNECT_NET        = "CommonManager.TRY_RECONNECT_NET"    --网络重连

function CommonManager:ctor()
    TFDirector:addProto(s2c.UPDATE_PLAYER_NAME_RESULT, self, self.onReNameCom)
    TFDirector:addProto(s2c.RE_CONNECT_COMPLETE, self, self.onReconnectCom)
    TFDirector:addProto(s2c.BUY_TIME_RESULT, self, self.onReceiveReplyResult);
    TFDirector:addProto(s2c.RELOGON_NOTIFY, self, self.onReloginNotify);
end

function CommonManager:onReceiveReplyResult( event )
    print("onReceiveReplyResult")

    hideLoading();
    -- toastMessage("购买成功！");
    toastMessage(localizable.common_buy_suc)

    AlertManager:close();
end

function CommonManager:reply(type)
    showLoading();
    TFDirector:send(c2s.BUY_CHALLENGE_TIMES, { type,1 } );
end

function CommonManager:restart()

end

function CommonManager:showReplyLayer(type, isadd)
        if isadd == nil then
            isadd = true;
        end
        
        local timesInfo = MainPlayer:GetChallengeTimesInfo(type);
        local resConfigure = PlayerResConfigure:objectByID(type)
   
        if type == EnumRecoverableResType.PUSH_MAP then
            local item = ItemData:objectByID( 30010 );
            local num = BagManager:getItemNumById( 30010 );
            if num > 0 then
                local layer = self:showOperateSureLayer(
                        function()
                            BagManager:useBatchItem( item.id,num )
                            -- toastMessage("体力增加" .. item.usable * num)
                            toastMessage(stringUtils.format(localizable.CommonManager_tili_zengjia, item.usable * num))
                        end,
                        nil,
                        {
                        uiconfig = "lua.uiconfig_mango_new.common.UseCoinComfirmLayer",
                        -- title = item.name .. num .. "个",
                        -- msg = "可兑换" .. item.usable * num
                        title = stringUtils.format(localizable.CommonManager_good_num_desc, item.name, num),
                        msg = stringUtils.format(localizable.CommonManager_good_duihuan, item.usable * num)
                        
                        }
                )
                local img1 = TFDirector:getChildByPath(layer, 'img1');
                local img2 = TFDirector:getChildByPath(layer, 'img2');
      
                img1:setTexture(item:GetPath());
                img2:setTexture(GetResourceIconForGeneralHead(HeadResType.PUSH_MAP))
                return;
            end   

            local item = ItemData:objectByID( 30018 );
            local num = BagManager:getItemNumById( 30018 );
            if num > 0 then
                local layer = self:showOperateSureLayer(
                        function()
                            BagManager:useBatchItem( item.id,num )
                            --toastMessage("体力增加" .. item.usable * num)
                            toastMessage(stringUtils.format(localizable.CommonManager_tili_zengjia, item.usable * num))
                        end,
                        nil,
                        {
                        uiconfig = "lua.uiconfig_mango_new.common.UseCoinComfirmLayer",
                        --title = item.name .. num .. "个",
                        --msg = "可兑换" .. item.usable * num
                        title = stringUtils.format(localizable.CommonManager_good_num_desc, item.name, num),
                        msg = stringUtils.format(localizable.CommonManager_good_duihuan, item.usable * num)
                        }
                )
                local img1 = TFDirector:getChildByPath(layer, 'img1');
                local img2 = TFDirector:getChildByPath(layer, 'img2');
    
                img1:setTexture(item:GetPath());
                img2:setTexture(GetResourceIconForGeneralHead(HeadResType.PUSH_MAP))
                return;
            end   

            --vip限制功能
            if MainPlayer:getVipLevel() < ConstantData:getValue("Challenge.Time.Chapter.NeedVIP") then
                self:showOperateSureLayer(
                        function()
                            PayManager:showPayLayer();
                        end,
                        nil,
                        {
                        --title = isadd and "提升VIP" or "体力不足",
                        title = isadd and localizable.CommonManager_vip_up or localizable.CommonManager_tili_not_enough,
                        -- msg = "VIP" .. ConstantData:getValue("Challenge.Time.Chapter.NeedVIP") .. "方可购买体力。",
                        --msg = "VIP" .. ConstantData:getValue("Challenge.Time.Chapter.NeedVIP") .. "方可购买体力。\n\n是否前往充值？",
                        msg = stringUtils.format(localizable.CommonManager_need_vip, ConstantData:getValue("Challenge.Time.Chapter.NeedVIP")),
                        uiconfig = "lua.uiconfig_mango_new.common.NeedTpPayLayer"
                        }
                )
                return;

            else
                if timesInfo.dailyMaxBuyTimes - timesInfo.dailyBuyTimes < 1 then
                    --判断是否有没有更高的vip能够增加购买次数
                    local nextUpVip = VipData:getVipNextAddValueVip(2000,MainPlayer:getVipLevel())
                    if nextUpVip then
                        -- local msg = "今日购买次数已用完！\n\n提升至VIP" .. nextUpVip.vip_level .. "可购买" .. nextUpVip.benefit_value .. "次。";
                        --local msg = "今日购买次数已用完！\n\n提升至VIP" .. nextUpVip.vip_level .. "可购买" .. nextUpVip.benefit_value .. "次。\n\n是否前往充值？";
                        local msg = stringUtils.format(localizable.CommonManager_need_up_vip, nextUpVip.vip_level, nextUpVip.benefit_value)
                        self:showOperateSureLayer(
                                function()
                                    PayManager:showPayLayer();
                                end,
                                nil,
                                {
                                --title =  isadd and "购买次数已用完" or "体力不足",
                                title =  isadd and localizable.CommonManager_out_time or localizable.CommonManager_tili_not_enough,
                                msg = msg,
                                uiconfig = "lua.uiconfig_mango_new.common.NeedTpPayLayer"
                                }
                        )
                    else
                        if isadd then
                            --toastMessage("今日购买次数已用完");
                            toastMessage(localizable.CommonManager_out_time_today);
                        else
                            --toastMessage("体力不足，今日购买次数已用完");
                            toastMessage(localizable.CommonManager_out_time_today2)
                        end
                    end
                    return;
                end

            end
        end

        if type == EnumRecoverableResType.CLIMB then
            local item = ItemData:objectByID( 30014 );
            local num = BagManager:getItemNumById( 30014 );
            if num > 0 then
                local layer = self:showOperateSureLayer(
                        function()
                            BagManager:useBatchItem( item.id,num )
                            --toastMessage("无量山石增加" .. item.usable * num)
                            toastMessage(stringUtils.format(localizable.CommonManager_wuliangshanshi_add, item.usable * num))
                        end,
                        nil,
                        {
                        uiconfig = "lua.uiconfig_mango_new.common.UseCoinComfirmLayer",
                        --title = item.name .. num .. "个",
                        title = localizable.format(localizable.CommonManager_good_num_desc, item.name, num),
                        --msg = "可兑换" .. item.usable * num
                        msg = stringUtils.format(localizable.CommonManager_good_duihuan, item.usable * num)
                        }
                )
                local img1 = TFDirector:getChildByPath(layer, 'img1');
                local img2 = TFDirector:getChildByPath(layer, 'img2');
      
                img1:setTexture(item:GetPath());
                img2:setTexture(GetResourceIconForGeneralHead(HeadResType.CLIMB))
                return;
            end   

            --vip限制功能
            if MainPlayer:getVipLevel() < ConstantData:getValue("Challenge.Time.Climb.NeedVIP") then
                self:showOperateSureLayer(
                        function()
                            PayManager:showPayLayer();
                        end,
                        nil,
                        {
                        --title =  isadd and "提升VIP" or "无量山石不足",
                        title = isadd and localizable.CommonManager_vip_up or localizable.CommonManager_wuliangshanshi_not_enough,
                        -- msg = "VIP" .. ConstantData:getValue("Challenge.Time.Climb.NeedVIP") .. "方可购买无量山石。",
                        --msg = "VIP" .. ConstantData:getValue("Challenge.Time.Climb.NeedVIP") .. "方可购买无量山石。\n\n是否前往充值？",
                        msg = stringUtils.format(localizable.CommonManager_need_vip2, ConstantData:getValue("Challenge.Time.Climb.NeedVIP")),
                        uiconfig = "lua.uiconfig_mango_new.common.NeedTpPayLayer"
                        }
                )  
                return;
            else
                --判断是否有没有更高的vip能够增加购买次数
                if timesInfo.dailyMaxBuyTimes - timesInfo.dailyBuyTimes < 1 then
                    local nextUpVip = VipData:getVipNextAddValueVip(2002,MainPlayer:getVipLevel())
                    if nextUpVip then
                        -- local msg = "今日购买次数已用完！\n\n提升至VIP" .. nextUpVip.vip_level .. "可购买" .. nextUpVip.benefit_value .. "次。";
                        --local msg = "今日购买次数已用完！\n\n提升至VIP" .. nextUpVip.vip_level .. "可购买" .. nextUpVip.benefit_value .. "次。\n\n是否前往充值？";
                        local msg = stringUtils.format(localizable.CommonManager_need_up_vip, nextUpVip.vip_level, nextUpVip.benefit_value)
                        self:showOperateSureLayer(
                                function()
                                    PayManager:showPayLayer();
                                end,
                                nil,
                                {
                                --title =  isadd and "购买次数已用完" or "量山石不足",
                                title = isadd and localizable.CommonManager_out_time or localizable.CommonManager_wuliangshanshi_not_enough,
                                msg = msg,
                                uiconfig = "lua.uiconfig_mango_new.common.NeedTpPayLayer"
                                }
                        )
                    else
                        if isadd then
                            --toastMessage("今日购买次数已用完");
                            toastMessage(localizable.CommonManager_out_time_today);
                        else
                            --toastMessage("无量山石不足，今日购买次数已用完");
                            toastMessage(localizable.CommonManager_out_time_today3);
                        end
                    end
                    return;
                end
            end
        end

        if type == EnumRecoverableResType.QUNHAO then
            local item = ItemData:objectByID( 30011 );
            local num = BagManager:getItemNumById( 30011 );
            if num > 0 then
                local layer = self:showOperateSureLayer(
                        function()
                            BagManager:useBatchItem( item.id,num )
                            --toastMessage("挑战令增加" .. item.usable * num)
                            toastMessage(stringUtils.format(localizable.CommonManager_challenge_increase , item.usable * num))
                        end,
                        nil,
                        {
                        uiconfig = "lua.uiconfig_mango_new.common.UseCoinComfirmLayer",
                        --title = item.name .. num .. "个",
                        title = stringUtils.format(localizable.CommonManager_good_num_desc, item.name, num),
                        --msg = "可兑换" .. item.usable * num
                        msg = stringUtils.format(localizable.CommonManager_good_duihuan, item.usable * num)
                        }
                )
                local img1 = TFDirector:getChildByPath(layer, 'img1');
                local img2 = TFDirector:getChildByPath(layer, 'img2');
      
                img1:setTexture(item:GetPath());
                img2:setTexture(GetResourceIconForGeneralHead(HeadResType.QUNHAO))
                return;
            end   
            --vip限制功能
            if MainPlayer:getVipLevel() < ConstantData:getValue("Challenge.Time.Herolist.NeedVIP") then
                self:showOperateSureLayer(
                        function()
                            PayManager:showPayLayer();
                        end,
                        nil,
                        {
                        --title = isadd and "提升VIP" or "挑战令不足",
                        title = isadd and localizable.CommonManager_vip_up or localizable.CommonManager_challenge_not_enough,
                        -- msg = "VIP" .. ConstantData:getValue("Challenge.Time.Herolist.NeedVIP") .. "方可购买挑战令。",
                        --msg = "VIP" .. ConstantData:getValue("Challenge.Time.Herolist.NeedVIP") .. "方可购买挑战令。\n\n是否前往充值？",
                        msg = stringUtils.format(localizable.CommonManager_need_vip3, ConstantData:getValue("Challenge.Time.Herolist.NeedVIP")),
                        uiconfig = "lua.uiconfig_mango_new.common.NeedTpPayLayer"
                        }
                ) 
                return;
            else
                --判断是否有没有更高的vip能够增加购买次数
                if timesInfo.dailyMaxBuyTimes - timesInfo.dailyBuyTimes < 1 then
                    local nextUpVip = VipData:getVipNextAddValueVip(2001,MainPlayer:getVipLevel())
                    if nextUpVip then
                        -- local msg = "今日购买次数已用完！\n\n提升至VIP" .. nextUpVip.vip_level .. "可购买" .. nextUpVip.benefit_value .. "次。";
                        --local msg = "今日购买次数已用完！\n\n提升至VIP" .. nextUpVip.vip_level .. "可购买" .. nextUpVip.benefit_value .. "次。\n\n是否前往充值？";
                        local msg = stringUtils.format(localizable.CommonManager_need_up_vip, nextUpVip.vip_level, nextUpVip.benefit_value)
                        self:showOperateSureLayer(
                                function()
                                    PayManager:showPayLayer();
                                end,
                                nil,
                                {
                                --title =   isadd and "购买次数已用完" or "挑战令不足",
                                title = isadd and localizable.CommonManager_out_time or localizable.CommonManager_challenge_not_enough,
                                msg = msg,
                                uiconfig = "lua.uiconfig_mango_new.common.NeedTpPayLayer"
                                }
                        )
                    else
                        if isadd then
                            --toastMessage("今日购买次数已用完");
                            toastMessage(localizable.CommonManager_out_time_today)
                        else
                            --toastMessage("挑战令不足，今日购买次数已用完");
                            toastMessage(localizable.CommonManager_out_time_today4)
                        end
                    end
                    return;
                end
            end
        end
        if type == EnumRecoverableResType.SKILL_POINT then
            --vip限制功能
            if MainPlayer:getVipLevel() < ConstantData:getValue("Challenge.Time.Skill.NeedVIP") then
                self:showOperateSureLayer(
                        function()
                            PayManager:showPayLayer();
                        end,
                        nil,
                        {
                        --title =  isadd and "提升VIP" or "技能点不足",
                        title = isadd and localizable.CommonManager_vip_up or localizable.CommonManager_skillpoint_not_enough,
                        -- msg = "VIP" .. ConstantData:getValue("Challenge.Time.Skill.NeedVIP") .. "方可使用元宝购买技能点。",
                        --msg = "VIP" .. ConstantData:getValue("Challenge.Time.Skill.NeedVIP") .. "方可使用元宝购买技能点。\n\n是否前往充值？",
                        msg = stringUtils.format(localizable.CommonManager_need_vip4, ConstantData:getValue("Challenge.Time.Skill.NeedVIP")),
                        uiconfig = "lua.uiconfig_mango_new.common.NeedTpPayLayer"
                        }
                ) 
                return;
            else
                --判断是否有没有更高的vip能够增加购买次数
                if timesInfo.dailyMaxBuyTimes - timesInfo.dailyBuyTimes < 1 then
                    local nextUpVip = VipData:getVipNextAddValueVip(2004,MainPlayer:getVipLevel())
                    if nextUpVip then
                        -- local msg = "今日购买次数已用完！\n\n提升至VIP" .. nextUpVip.vip_level .. "可使用元宝购买" .. nextUpVip.benefit_value .. "次。";
                        --local msg = "今日购买次数已用完！\n\n提升至VIP" .. nextUpVip.vip_level .. "可使用元宝购买" .. nextUpVip.benefit_value .. "次。\n\n是否前往充值？";
                        local msg = stringUtils.format(localizable.CommonManager_need_up_vip2, nextUpVip.vip_level, nextUpVip.benefit_value)
                        self:showOperateSureLayer(
                                function()
                                    PayManager:showPayLayer();
                                end,
                                nil,
                                {
                                --title = isadd and "购买次数已用完" or "技能点不足",
                                title = isadd and localizable.CommonManager_out_time or localizable.CommonManager_skillpoint_not_enough,
                                msg = msg,
                                uiconfig = "lua.uiconfig_mango_new.common.NeedTpPayLayer"
                                }
                        )
                    else
                        if isadd then
                            --toastMessage("今日购买次数已用完");
                            toastMessage(localizable.CommonManager_out_time_today)
                        else
                            --toastMessage("技能点不足，今日购买次数已用完");
                            toastMessage(localizable.CommonManager_out_time_today5)
                        end
                    end
                    return;
                end
            end
        end

    local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.common.ReplyLayer",AlertManager.BLOCK_AND_GRAY_CLOSE,AlertManager.TWEEN_1);
    layer:setType(type,isadd);
    AlertManager:show()
end


function CommonManager:showErrorLayer(msg)
   local layer = self:showOperateSureLayer(
            function()
                restartLuaEngine()
                -- SettingManager:gotoUpdateLayer()
            end,
            nil,
            {
            --title = "出错啦",
            title = localizable.common_wrong,

            --msg = "这位大侠，游戏好像傲娇了，你只要轻轻点击“重新登录”就好啦。",
            msg = localizable.CommonManager_relogin,
            --okText = "重新登录",
            okText = localizable.common_relogin,
            showtype = AlertManager.BLOCK_AND_GRAY,
            uiconfig = "lua.uiconfig_mango_new.common.OperateSure2"
            }
    )
   layer.isCanNotClose = true;
end
function CommonManager:showFightPluginErrorLayer()
    local systemVersion = TFDeviceInfo.getSystemVersion() or "NULL"
    if systemVersion == "6.0" then
        return
    end
    self.showPluginTime = self.showPluginTime or 0
    if self.showPluginTime > 0 then
        return
    end
    self.showPluginTime = self.showPluginTime + 1
    local pluginTimer = TFDirector:addTimer(1000,1,nil,function ()
        TFDirector:removeTimer(pluginTimer)
        pluginTimer = nil
        TFDirector:pause()
    end)

    local machineName = TFDeviceInfo.getMachineName() or "NULL"
    local systemName = TFDeviceInfo.getSystemName() or "NULL"
    local deviceId = TFDeviceInfo.getMachineOnlyID() or "NULL"
    local str = "machineName = "..machineName..",systemName = "..systemName..",systemVersion ="..systemVersion..",deviceId = "..deviceId
    ErrorCodeManager:reportErrorMsg(str)

    local layer = self:showOperateSureLayer(
            function()
                if pluginTimer then
                    TFDirector:removeTimer(pluginTimer)
                    pluginTimer = nil
                end
                    self.showPluginTime = 0

                    AlertManager:clearAllCache()
                    CommonManager:closeConnection()
                    restartLuaEngine("CompleteUpdate")

            end,
            nil,
            {
            title = localizable.common_wrong, --"出错啦",
            -- msg = TFLanguageManager:getString(ErrorCodeData.illegal_Third_party),--"这位大侠，游戏好像傲娇了，你只要轻轻点击“重新登录”就好啦。",
            msg = localizable.illegal_Third_party,--"这位大侠，游戏好像傲娇了，你只要轻轻点击“重新登录”就好啦。",
            okText = localizable.common_relogin, --"重新登录",
            showtype = AlertManager.BLOCK_AND_GRAY,
            uiconfig = "lua.uiconfig_mango_new.common.OperateSure2"
            }
    )
   layer.isCanNotClose = true;
end

function CommonManager:showNeedUpdateLayer(clientViesion,serverViesion)
    local layer = self:showOperateSureLayer(
            function()
                SettingManager:gotoUpdateLayer()
            end,
            nil,
            {
            --title = "更新资源啦",
            title = localizable.CommonManager_update_version1,
            --msg = "更新资源啦，\n\n当前版本：" .. clientViesion .. ";最新版本：" .. serverViesion,
            msg = stringUtils.format(localizable.CommonManager_update, clientViesion, serverViesion),
            --okText = "立即更新",
            okText = localizable.CommonManager_update_now,
            showtype = AlertManager.BLOCK_AND_GRAY,
            uiconfig = "lua.uiconfig_mango_new.common.OperateSure2"
            }
    )
    layer.isCanNotClose = true;
end

function CommonManager:checkServerVersion(serverViesion)
    if TF_DEBUG_UPDATE_FLAG == 1 or CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 then
        return true;
    end
    
    local clientViesion = TFClientUpdate:getCurVersion();

    print("clientViesion",clientViesion)
    print("serverViesion",serverViesion)

    if serverViesion == "" or  serverViesion == nil then
        return true;
    end

    if clientViesion < serverViesion then
        self:showNeedUpdateLayer(clientViesion,serverViesion);
        return false;
    end
    
    return true;
end

function CommonManager:showNeedGemComfirmLayer()
    self:showOperateSureLayer(
            function()
                MallManager:openMallLayer()
            end,
            nil,
            {
            uiconfig = "lua.uiconfig_mango_new.common.NeedGemComfirmLayer",
            }
    )

end

function CommonManager:showNeedRoleComfirmLayer()
    self:showOperateSureLayer(
            function()
                -- MallManager:openMallLayer()
                MallManager:openRecruitLayer()
            end,
            nil,
            {
            uiconfig = "lua.uiconfig_mango_new.common.NeedRoleComfirmLayer",
            }
    )

end

function CommonManager:showNeedZhenqiComfirmLayer()
    self:showOperateSureLayer(
            function()
                 ActivityManager:showLayer(ActivityManager.TAP_Climb);
            end,
            nil,
            {
            uiconfig = "lua.uiconfig_mango_new.common.NeedZhenqiComfirmLayer",
            }
    )

end

function CommonManager:showNeedEquipComfirmLayer()
    self:showOperateSureLayer(
            function()
                MissionManager:showHomeLayer()
            end,
            nil,
            {
            uiconfig = "lua.uiconfig_mango_new.common.NeedEquipComfirmLayer",
            }
    )
end
function CommonManager:showNeedCoinComfirmLayer()
    local item = ItemData:objectByID( 30003 );
    local num = BagManager:getItemNumById( 30003 );
    if num > 0 then
        BagManager:useItem( 30003 ,false)
    else
        -- self:showBuyCoinComfirmLayer()
        self:showBuyCoinLayer()
    end
end

function CommonManager:showBuyCoinComfirmLayer()
    local item = ItemData:objectByID( 30003 );
     MallManager:openItemShoppingLayer(30003,
    function()
        local num = BagManager:getItemNumById( 30003 );
        self:showOperateSureLayer(
                function()
                    BagManager:useBatchItem( item.id,num )
                end,
                nil,
                {
                uiconfig = "lua.uiconfig_mango_new.common.BuyCoinResultLayer",
                --title = num .. "个",
                title = stringUtils.format(localizable.CommonManager_number, num),
                --msg = "可兑换" ..  item.usable * num
                msg = stringUtils.format(localizable.CommonManager_good_duihuan , item.usable * num)
                }
        )

    end,true);
end

function CommonManager:showOperateSureLayer(okhandle,cancelhandle,param)

    local flieName = "lua.logic.common.OperateSure"
    -- local _layer = AlertManager:getLayerByName( flieName )
    -- if  _layer ~= nil then
    --     AlertManager:closeLayer(_layer)
    -- end
    param = param or {}

    param.showtype = param.showtype or AlertManager.BLOCK_AND_GRAY_CLOSE;
    param.tweentype = param.tweentype or AlertManager.TWEEN_1;

    param.uiconfig = param.uiconfig or "lua.uiconfig_mango_new.common.OperateSure";


    local layer = AlertManager:addLayerByFile(flieName,param.showtype,param.tweentype);
    layer.toScene = Public:currentScene();
    layer:setUIConfig(param.uiconfig);

    layer:setBtnHandle(okhandle, cancelhandle);
    layer:setData(param.data);
    layer:setTitle(param.title);
    layer:setMsg(param.msg);
    layer:setTitleImg(param.titleImg);

    layer:setBtnOkText(param.okText);
    layer:setBtnCancelText(param.cancelText);

    AlertManager:show()

    return layer;
end

function CommonManager:showOperateSureTipLayer(okhandle,cancelhandle,param)
    param = param or {}

    param.showtype = param.showtype or AlertManager.BLOCK_AND_GRAY_CLOSE;
    param.tweentype = param.tweentype or AlertManager.TWEEN_1;

    param.uiconfig = param.uiconfig or "lua.uiconfig_mango_new.common.OperateSureTip";


    local layer = AlertManager:addLayerByFile("lua.logic.common.OperateSureTip",param.showtype,param.tweentype);
    layer.toScene = Public:currentScene();

    layer:setUIConfig(param.uiconfig);

    layer:setBtnHandle(okhandle, cancelhandle);
    layer:setData(param.data);
    layer:setTitle(param.title);
    layer:setMsg(param.msg);
    layer:setTitleImg(param.titleImg);

    layer:setBtnOkText(param.okText);
    layer:setBtnCancelText(param.cancelText);

    AlertManager:show()

    return layer;
end

function CommonManager:addLayerToCache()

end

function CommonManager:addLayerToCache()

end



--[[
更新控件状态，包括是否开放，点击时的提示信息绑定，是否显示红点
@widget UI控件
@functionId 功能ID，详情查看t_s_functionopen表定义
@visiable 红点是否可见
@offset 红点的相对于UI控件的偏移坐标
]]
function CommonManager:updateWidgetState(widget,functionId,visiable,offset)
    if not functionId then
        self:updateRedPoint(widget,visiable,offset)
        return
    end

    local configure = FunctionOpenConfigure:objectByID(functionId)
    if not configure then
        self:updateRedPoint(widget,visiable,offset)
        return
    end

    local teamLevel = MainPlayer:getLevel()
    -- print("CommonManager:updateWidgetState : ",teamLevel,configure.level)
    if configure.level > teamLevel then --功能没有达到开放条件
        local function showNotEnoughTeamLevelTips()
            -- toastMessage('此功能在团队等级达到[' .. configure.level .. ']后开放')
            toastMessage(stringUtils.format(localizable.common_function_openlevel, configure.level))
            widget:changeBtnStateToNormal()
            widget:setGrayEnabled(true)
        end
        widget:removeMEListener(TFWIDGET_CLICK)       --移除原来的监听方法
        --绑定点击监听方法
        widget:addMEListener(TFWIDGET_CLICK, audioClickfun(showNotEnoughTeamLevelTips),1)

        --设置控件为上锁状态
        widget:setGrayEnabled(true)
    else
        widget:setGrayEnabled(false)
        if widget.clickCallback then                    --如果控件原来绑定了点击回调事件重新绑定一下，依赖使用者自己赋值
            widget:addMEListener(TFWIDGET_CLICK, clickCallback)
        end
        self:updateRedPoint(widget,visiable,offset)
    end
end

--[[
更新红点状态
@widget UI控件
@visiable 红点是否可见
@offset 红点的相对于UI控件的偏移坐标
]]
function CommonManager:updateRedPoint(widget,visiable,offset)
    if not visiable then
        self:removeRedPoint(widget)
        return
    end

    self:addRedPoint(widget,offset)
end

--[[
删除控件的红点
@widget UI控件
]]
function CommonManager:removeRedPoint(widget)
    if not widget then
        return
    end

    local redPoint = widget:getChildByName("RedPoint")
    if not redPoint then
        return
    end
    redPoint:setVisible(false);
end

--[[
往控件添加红点
@widget UI控件
@offset 红点的相对于UI控件的偏移坐标
]]
function CommonManager:addRedPoint(widget,offset)
    if not widget then
        return
    end

    local redPoint = widget:getChildByName("RedPoint")
    if redPoint then
        redPoint:setVisible(true)
    else
        redPoint = TFImage:create("ui_new/common/splats.png")
        redPoint:setName("RedPoint")
        offset = offset or ccp(0,0)
        local widgetSize = widget:getSize()
        local pointSize = redPoint:getSize()
        local pos = ccp(widgetSize.width/2 - pointSize.width/2 + offset.x ,widgetSize.height/2 - pointSize.width/2 + offset.y)
        redPoint:setPosition(pos)
        widget:addChild(redPoint,100)
    end
end


function CommonManager:setRedPoint(parent,isshow,key,offset,functionId)
    if parent then
        local redPoint = parent:getChildByName("RedPoint");
        if redPoint and redPoint.key == key then
            redPoint:removeFromParent();
        end

        if functionId == nil or (functionId and PlayerGuideManager:isFunctionOpen(functionId)) then
            if isshow then
                local redPoint = parent:getChildByName("RedPoint");
                if not redPoint then
                    redPoint = TFImage:create("ui_new/common/splats.png");
                    redPoint:setName("RedPoint");
                    redPoint.key = key;
                    
                    offset = offset or ccp(0,0);
                    local pos = ccp(parent:getSize().width/2 - redPoint:getSize().width/2 + offset.x ,parent:getSize().height/2 - redPoint:getSize().width/2 + offset.y);

                    redPoint:setPosition(pos);

                    parent:addChild(redPoint,100);
                else
                    redPoint:setVisible(isshow)
                    redPoint.key = key;
                end
                redPoint.isshow = isshow;
            end
        end
    end
end

function CommonManager:reName(name)
    showLoading();
    TFDirector:send(c2s.UPDATE_PLAYER_NAME, {name} );
end

function CommonManager:onReNameCom(event)
    -- print("CardRoleManager:onReNameCom" )
    -- print(event.data)
    hideLoading();
    --MainPlayer.name = event.data.name;
    --修改为设置玩家名称方法，以兼容以前代码
    MainPlayer:setPlayerName(event.data.name)
    -- toastMessage("更名成功")
    toastMessage(localizable.CommonManager_change_name)

    AlertManager:close();
end

--add by david.dai
--是否掉线自动重连
local autoConnect = true
--重登录累计次数
local reConnectServerSum = 0
--连接状态，0：无连接；1：连接活动中
local connection_status = 0
local disableDisconnectLayerShow = false

function CommonManager:closeConnection()
    self:setAutoConnect(false)
    MainPlayer.firstLoginMark = true
    disableDisconnectLayerShow = true
    TFDirector:closeSocket()
    connection_status = 0
    disableDisconnectLayerShow = false
end

function CommonManager:setAutoConnect(enabled)
    autoConnect = enabled
end

function CommonManager:loginServer()
    if connection_status == 0 then
        if autoConnect then
            self:connectServer(true)
        end
    else
        if MainPlayer.firstLoginMark then
            self:sendLogin()
        else
            self:sendRelogin()
        end
    end
end

--连接服务器
function CommonManager:connectServer(requestLogin)
    if connection_status ~= 0 then
        return
    end
    
    local serverInfo = SaveManager:getCurrentSelectedServer()
    if serverInfo == nil then
        --toastMessage("请选择服务器")
        toastMessage(localizable.CommonManager_choose_server)
        return
    end

    for i=1,100 do
        showLongLoading()
    end


    local addressTable = string.split(serverInfo.address,":")
    local ip = addressTable[1]
    local port = addressTable[2]
    
    TFDirector:connect(ip, port, 
    function (nResult)
        self:connectHandle(nResult,requestLogin)
    end,
    nil,
    function (nResult)
        self:connectionClosedCallback(nResult)
    end)
end

--连接打开的回调方法，当连接创建成功后会由系统调用此方法
function CommonManager:connectHandle(nResult,requestLogin)
    print("-- CommonManager:connectHandle nResult = ", nResult)
    print("-- CommonManager:connectHandle requestLogin = ", requestLogin)
    TFDirector:setEncodeKeys({ 0xae, 0xbf, 0x56, 0x78, 0xab, 0xcd, 0xef, 0xf1 })
    if nResult then
        if nResult == 1 then
            connection_status = 1
            if requestLogin then
                if MainPlayer.firstLoginMark then
                    self:sendLogin()
                else
                    self:sendRelogin()
                end
            end

            -- 网络重连时通知前端
            TFDirector:dispatchGlobalEventWith(self.TRY_RECONNECT_NET, {})
            
        -- 连接失败
        elseif nResult == -2 or nResult == -1 then
            print("连接服务器失败")
            -- 是否为第一场战斗
            if FightManager.fightBeginInfo then 
                local fightType = FightManager.fightBeginInfo.fighttype

                if FightManager.fightBeginInfo.bGuideFight == true and fightType == 1  then
                    print("引导第一场战斗中断网")
                    -- toastMessage("网络连接失败")
                    toastMessage(localizable.common_net_wrong)
                    FightManager:Reset()
                    AlertManager:clear()
                    AlertManager:changeSceneForce(SceneType.LOGIN)
                    return
                end
            end

            local currentScene = Public:currentScene()
            print(" connectHandle __cname = ", currentScene:getTopLayer().__cname)
            if currentScene ~= nil and currentScene.getTopLayer then
                -- 登陆界面
                if currentScene:getTopLayer().__cname == "LoginNoticePage" then
                    hideAllLoading()
                    -- toastMessage("连接服务器失败")
                    toastMessage(localizable.common_net_wrong)

                -- 创建角色界面
                elseif currentScene:getTopLayer().__cname == "CreatePlayerNew" then
                    hideAllLoading()
                    -- toastMessage("连接服务器失败,请检查你的网络稍后再试")
                    toastMessage(localizable.common_net_desc)
                else
                    self:showDisconnectDialog()
                end
            else
                self:showDisconnectDialog()
            end

        -- elseif nResult == -1 then
        --     print("连接服务器失败111")
        end
        -- self.TryReLoginFailTimes = 0
    else
        self:showDisconnectDialog()
    end
end

function CommonManager:showDisconnectDialog()
    hideAllLoading()
    if MainPlayer.firstLoginMark then
        if disableDisconnectLayerShow then
            -- toastMessage("连接服务器失败")
            toastMessage(localizable.common_net_wrong)
        end
    else
        local currentScene = Public:currentScene()
        if currentScene ~= nil and currentScene.getTopLayer and currentScene:getTopLayer().__cname == "ReconnectLayer" then
            if disableDisconnectLayerShow then
                -- toastMessage("连接服务器失败")
                toastMessage(localizable.common_net_wrong)
            end
        else
            self.TryReLoginFailTimes = self.TryReLoginFailTimes + 1
            print("掉线重连次数 -- ", self.TryReLoginFailTimes)
            if self.TryReLoginFailTimes >= 3 then
                restartLuaEngine("CompleteUpdate")
            else
                self:showReconnectLayer()
            end
        end
    end
end

--发送登录服务器请求
function CommonManager:sendLogin()
    print("CommonManager:sendLogin()==================")
    -- MainPlayer:restart();
    for i=1,100 do
        showLongLoading()
    end

    local userInfo = SaveManager:getUserInfo()
    local token = getIOSDeviceTokens()
    if not token or token:len() < 1 then
        token = "NULL"
    end
    local machineName = TFDeviceInfo.getMachineName() or "NULL"
    local systemName = TFDeviceInfo.getSystemName() or "NULL"
    local systemVersion = TFDeviceInfo.getSystemVersion() or "NULL"
    local deviceId = TFDeviceInfo.getMachineOnlyID() or "NULL"
    local sdkVerison = "NULL"
    if TFPlugins.getSdkName() then
        sdkVerison = TFPlugins.getSdkVersion() or "NULL"
    end
    
        -- pc
    if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 then
        deviceId    = "Win32Simulator_001"
        sdkVerison  = "Win32Simulator_V1.0"
        systemName  = "Win32Simulator"
    end

    local validateCode = "Let Me In!"
    if not IS_TEST_GAME then
        if userInfo.validateLoginTable and userInfo.validateLoginTable.token then
            validateCode = userInfo.validateLoginTable.token
        end
        validateCode = TFPlugins.getCheckServerToken() or validateCode
    end
    
    local account = TFPlugins.getUserID() or userInfo.userName or "NULL"
    local site = 0
    if userInfo.currentServer then
        site = tonumber(userInfo.currentServer)
    end
    local MCC = "NULL"
    local IP = "NULL"
    local loginMsg =
    {
        account,
        validateCode,
        site,
        token,
        machineName,
        systemName,
        systemVersion,
        TFPlugins.getSdkName() or "NAN", --'168'
        TFPlugins.getSdkName() or "NAN",
        deviceId,           --设备ID唯一标识
        sdkVerison,         --SDK版本
        MCC,                --移动设备国家码
        IP                  --移动设备网络通信地址
    }
    print("send login : ",loginMsg)
    --TFDirector:send(c2s.LOGIN, loginMsg , 1)    --rsa加密
    local nResult = TFDirector:send(c2s.LOGIN, loginMsg)    --不加密
    TFDirector:setEncodeKeys({1,2,3,4,5,6,7,8})
    if nResult and nResult < 0 then
        self:showDisconnectDialog()
        return
    end
end


--获取当前的连接状态，true为连接 false为掉线
function CommonManager:getConnectionStatus()
    local status = true
    if CC_TARGET_PLATFORM ~= CC_PLATFORM_WIN32 then
        -- if connection_status == 0 and MainPlayer.bIsEnterGame == true then
        if connection_status == 0 then
            status = false
        end
    end
    
    return status
end


--连接关闭的回调方法，当连接关闭后会由系统调用此方法
function CommonManager:connectionClosedCallback(nResult)
    print("-- CommonManager:connectionClosedCallback nResult = ", nResult)
    connection_status = 0
    hideAllLoading()

    local currentScene = Public:currentScene()
        
    if currentScene ~= nil and currentScene.getTopLayer then
        print(" currentScene:getTopLayer().__cname = ", currentScene:getTopLayer().__cname)
        if currentScene:getTopLayer().__cname == "CreatePlayerNew" or currentScene:getTopLayer().__cname == "LoginNoticePage" then
            -- toastMessage("连接服务器失败")
            print("连接失败了 ")
            return
        end
    end

    self.TryReLoginFailTimes = self.TryReLoginFailTimes+1

    print("self.TryReLoginFailTimes = ", self.TryReLoginFailTimes)
    if self.TryReLoginFailTimes >= 3 then
        -- autoConnect = false
        self:showDisconnectDialog()
        return
    end

    -- if nResult == 4 then
    --     -- autoConnect = false
    --     self:showDisconnectDialog()
    --     return
    -- end
    if  autoConnect then
        print("autoConnect is ture")
    end

    if disableDisconnectLayerShow then
        print("disableDisconnectLayerShow is ture")
    end

    if MainPlayer.firstLoginMark  then
        print("MainPlayer.firstLoginMark  is ture")
    end

    print("connection_status = ", connection_status)

    if autoConnect and self.TryReLoginFailTimes < 3 then
        -- print("11111111111111")
        -- local currentScene = Public:currentScene()
        -- print(" currentScene:getTopLayer().__cname = ", currentScene:getTopLayer().__cname)
        -- if currentScene ~= nil and currentScene.getTopLayer then

        --     if currentScene:getTopLayer().__cname == "CreatePlayerLayer" or currentScene:getTopLayer().__cname == "LoginNoticePage" then
        --         toastMessage("连接服务器失败")
        --     else
        --         self:loginServer()
        --     end
        --     -- if disableDisconnectLayerShow then
        --     --     toastMessage("连接服务器失败")
        --     -- end
            
        --     print("------------------")
        -- else

        --      print("***************")
        --     self:loginServer()
        -- end
        self:loginServer()
    else

        print("22222222222222")
        self:showDisconnectDialog()
    end
end

--发送重新连接请求到服务器
function CommonManager:sendRelogin()
    -- MainPlayer:reload()
    for i=1,100 do
        showLongLoading()
    end

    local userInfo = SaveManager:getUserInfo()
    local token = getIOSDeviceTokens() or "NULL"
    local machineName = TFDeviceInfo.getMachineName() or "NULL"
    local systemName = TFDeviceInfo.getSystemName() or "NULL"
    local systemVersion = TFDeviceInfo.getSystemVersion() or "NULL"
    local deviceId = TFDeviceInfo.getMachineOnlyID() or "NULL"
    local sdkVerison = "NULL"
    if TFPlugins.getSdkName() then
        sdkVerison = TFPlugins.getSdkVersion() or "NULL"
    end

    -- pc
    if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 then
        deviceId    = "Win32Simulator_001"
        sdkVerison  = "Win32Simulator_V1.0"
        systemName  = "Win32Simulator"
    end

    local validateCode = "Let Me In!"
    if not IS_TEST_GAME then
        if userInfo.validateLoginTable and userInfo.validateLoginTable.token then
            validateCode = userInfo.validateLoginTable.token
        end
        validateCode = TFPlugins.getCheckServerToken() or validateCode
    end
    
    local account = TFPlugins.getUserID() or userInfo.userName or "NULL"
     local site = 0
    if userInfo.currentServer then
        site = tonumber(userInfo.currentServer)
    end
    local MCC = "NULL"
    local IP = "NULL"
    local loginMsg =
    {
        account,
        validateCode,
        site,
        token,
        machineName,
        systemName,
        systemVersion,
        TFPlugins.getSdkName() or "NAN",
        TFPlugins.getSdkName() or "NAN",
        deviceId,        --设备ID唯一标识
        sdkVerison,      --SDK版本
        MCC,             --移动设备国家码
        IP               --通信地址
    }
    --TFDirector:send(c2s.RE_CONNECT_REQUEST, loginMsg , 1);  --rsa加密
    local nResult = TFDirector:send(c2s.RE_CONNECT_REQUEST, loginMsg);  --不加密
    TFDirector:setEncodeKeys({1,2,3,4,5,6,7,8})
    if nResult and nResult < 0 then
        self:showDisconnectDialog()
        return
    end
end

--function CommonManager:getuserName()
--    local configTbl = {}
--    configTbl.areaid = CCUserDefault:sharedUserDefault():getStringForKey("login_areaid");
--    configTbl.name = CCUserDefault:sharedUserDefault():getStringForKey("login_name");
--    return configTbl;
--end

function CommonManager:onReconnectCom(event)
    hideAllLoading();
    -- if self:checkServerVersion(event.data.resVersion) then
        Public:currentScene():getBaseLayer():onShow();
        Public:currentScene():getBaseLayer():reShow();

        local currentScene = Public:currentScene()
        if currentScene ~= nil and currentScene.getTopLayer and currentScene:getTopLayer().__cname == "ReconnectLayer" then
            AlertManager:close();
        end

        TFDirector:dispatchGlobalEventWith(MainPlayer.RE_CONNECT_COMPLETE , {})
        PlayerGuideManager:doGuide()
    -- end
end

function CommonManager:showReconnectLayer()
    hideAllLoading();
    
    local layer = AlertManager:addLayerByFile("lua.logic.common.ReconnectLayer",AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_NONE);
    layer.toScene = Public:currentScene();

    AlertManager:show();
end

function CommonManager:showReNameLayer()
    AlertManager:addLayerByFile("lua.logic.main.ReNameLayer",AlertManager.BLOCK_AND_GRAY_CLOSE,AlertManager.TWEEN_1);
    AlertManager:show();
end

function CommonManager:showLevelUpLayer(info)
    local layer = AlertManager:addLayerByFile("lua.logic.main.MainLevelUpLayer",AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_1);
    layer:loadData(info)
    AlertManager:show();
end

function CommonManager:onReloginNotify( event )
    hideAllLoading();

    autoConnect = false
    local layer = self:showOperateSureLayer(
        function()
            MainPlayer.firstLoginMark = true
            AlertManager:clear()
            AlertManager:changeSceneForce(SceneType.LOGIN)
        end,
        nil,
        {
            msg = localizable.CommonManager_other_user_login, -- "您的账号在别处登录！重新登录？",
            showtype = AlertManager.BLOCK_AND_GRAY,
            tweentype = AlertManager.TWEEN_NONE,
            okText = localizable.common_relogin, -- "重新登录",
            -- cancelText = "更换账号",
            uiconfig = "lua.uiconfig_mango_new.common.OperateSure2"
        }
    )

    layer.__cname = "ReconnectLayer";
    layer.isCanNotClose = true
    self.TryReLoginFailTimes = 0
end

function CommonManager:addGeneralHead( logic ,zOrder)
    zOrder = zOrder or 1;
    local generalHead    = require('lua.logic.common.GeneralHead'):new()
    generalHead:setLogic(logic)
    generalHead:setPosition(ccp(0,0))
    generalHead:setZOrder(zOrder)

    local panel_head      = TFDirector:getChildByPath(logic, 'panel_head');
    panel_head:addChild(generalHead)

    return generalHead;
end

function CommonManager:openWarningLayer()
    AlertManager:addLayerByFile("lua.logic.common.WarningLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_0);
    AlertManager:show();
end
function CommonManager:openFirstDrawing()
    if MainPlayer:getTotalRecharge() == 0 then
        AlertManager:addLayerByFile("lua.logic.home.ShowFirstPayLayer",AlertManager.BLOCK,AlertManager.TWEEN_0);
        AlertManager:show();
    end
end

function CommonManager:openSecondDayDrawing()
    if MainPlayer:getRegisterDay() == 1 then
        AlertManager:addLayerByFile("lua.logic.home.ShowSecondDayLayer",AlertManager.BLOCK,AlertManager.TWEEN_0);
        AlertManager:show();
    end
end

function CommonManager:openEverydayNotice()
    if #EverydayNoticeManager:getInfo() <= 0 then
        return
    end
    AlertManager:addLayerByFile("lua.logic.home.EverydayNotice",AlertManager.BLOCK,AlertManager.TWEEN_0);
    AlertManager:show();
end


function CommonManager:openNoticeLayer()
    -- if CC_TARGET_PLATFORM ~= CC_PLATFORM_WIN32 then
        AlertManager:addLayerByFile("lua.logic.home.NoticeLayer",AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_0);
        AlertManager:show()
    -- end
end


function CommonManager:openTmall(url)
    -- if CC_TARGET_PLATFORM ~= CC_PLATFORM_WIN32 then

        -- AlertManager:addLayerByFile("lua.logic.home.TmallWebLayer",AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_0);

        print("tmall url = ", url)
        local layer = require("lua.logic.home.TmallWebLayer"):new(url)
        AlertManager:addLayer(layer, AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_0)

        AlertManager:show()
    -- end
end

function CommonManager:openWeixinDrawing()
    -- if MainPlayer:getServerSwitchStatue(ServerSwitchType.WeiXin) == true then
    
    -- local bOpen = OperationActivitiesManager:ActivityTypeIsOpen(OperationActivitiesManager.Type_Pay_Back_RedBag)

    local nowTime   = os.time()--MainPlayer:getNowtime()
    local time1     = os.time({year=2015, month=11, day=20, hour=0})
    local time2     = os.time({year=2015, month=11, day=26, hour=23, min=59})
    local bOpen     = false

    if nowTime >= time1 and nowTime <= time2 then
        bOpen = true
    end

    if bOpen then
        AlertManager:addLayerByFile("lua.logic.home.SBAddLayer",AlertManager.BLOCK,AlertManager.TWEEN_0);
        AlertManager:show();
    end
end

function CommonManager:showBuyCoinLayer()
    -- BuyCoinLayer 
    AlertManager:addLayerByFile("lua.logic.mall.BuyCoinLayer",AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1);
    AlertManager:show();
end

function CommonManager:addAssistFightView( logic ,Type, callBack)
    local assistFightView    = require('lua.logic.assistFight.AssistFightEntranceLayer'):new()
    --generalHead:setLogic(logic)
    assistFightView:setPosition(ccp(0,0))
    assistFightView:setZOrder(1)
    assistFightView:setLineUpType(Type, callBack)

    local panel_assist      = TFDirector:getChildByPath(logic, 'panel_assist');
    panel_assist:addChild(assistFightView)

    return assistFightView;
end

function CommonManager:showRuleLyaer( rule_id )
    local layer = AlertManager:addLayerByFile("lua.logic.common.RuleLayer", AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_1)
    layer:loadRuleId(rule_id)
    AlertManager:show()
end

function CommonManager:checkResourceVersion()
    -- local versionPath = TFPlugins.zipCheckPath       --更新文件检测地址
    -- local filePath    = TFPlugins.zipCheckPath       --zip下载地址

    -- if TFClientResourceUpdate == nil then
    --     print("老版本的资源更新")
    --     return
    -- end

    -- local TFClientUpdate =  TFClientResourceUpdate:GetClientResourceUpdate()

    -- local function checkNewVersionCallBack()
    --     local version       =  TFClientUpdate:getCurVersion()
    --     local LatestVersion =  TFClientUpdate:getLatestVersion()
    --     local Content       =  TFClientUpdate:GetUpdateContent()
    --     local totalSize     =  TFClientUpdate:GetTotalDownloadFileSize()

    --     print("===========find new version===========")
    --     print("version          = ", version)
    --     print("LatestVersion    = ", LatestVersion)
    --     print("Content          = ", Content)
    --     print("totalSize        = ", totalSize)
    --     print("=============== end ==================")
    --     -- TFClientUpdate:startDownloadZip(downloadingRecvData)

    --     self:showFindNewVersioDiag(LatestVersion)
    -- end

    -- local function StatusUpdateHandle(ret)
    --     -- 更新完成，或者当前版本已经是最新的了
    --     if ret == 0 then


    --     elseif ret == 1 then

    --     elseif ret < 0 then

    --     end
    -- end

    -- print("new--------------------versionPath  = ", versionPath)
    -- print("new--------------------filePath     = ", filePath)
    -- TFClientUpdate:CheckUpdate(versionPath, filePath, checkNewVersionCallBack, StatusUpdateHandle)
end

function CommonManager:showFindNewVersioDiag(version)

    local warningMsg = localizable.CommonManager_new_version -- "大侠，发现了一个新版本，是否立即更新？"
    self:showOperateSureLayer(
            function()
                AlertManager:clearAllCache()
                CommonManager:closeConnection()
                restartLuaEngine("Other")
            end,
            nil,
            {
                    msg = warningMsg,
                    title = localizable.CommonManager_update_version1, --"更新资源啦",
                    showtype = AlertManager.BLOCK_AND_GRAY,
                    okText = localizable.CommonManager_update_version2, --"更新",
                    uiconfig = "lua.uiconfig_mango_new.common.OperateSure2"
            }
    )
end


function CommonManager:openIllustrationRole(roleId )
    
    local CardRole      = require('lua.gamedata.base.CardRole')
    local cardRole = CardRole:new(roleId)
    cardRole:setLevel(1)
    cardRole.attribute = {}
    local baseAttr = cardRole.totalAttribute.attribute
    
    local attribute = baseAttr

    for i=1,(EnumAttributeType.Max-1) do
        cardRole.totalAttribute[i] = attribute[i] or 0
    end

    local roleList = TFArray:new()
    roleList:clear()
    roleList:push(cardRole)


   local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.role_new.RoleInfoLayer",AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_1)
   local selectIndex = roleList:indexOf(cardRole)
   layer:loadOtherData(selectIndex, roleList)
   layer.bShowTuPu = true
   AlertManager:show()
end

--added by wuqi
--打开土豪发言编辑界面
function CommonManager:showTuhaoPopLayer(okhandle, cancelhandle, param)
    local flieName = "lua.logic.main.TuhaoPopLayer"
    param = param or {}
    param.showtype = param.showtype or AlertManager.BLOCK_AND_GRAY_CLOSE;
    param.tweentype = param.tweentype or AlertManager.TWEEN_1;

    local layer = AlertManager:addLayerByFile(flieName,param.showtype,param.tweentype);
    layer:setBtnHandle(okhandle, cancelhandle);
    layer:setTitle(param.title);
    layer:setMsg(param.msg);
	
	
    if not self:isTuhao() then
        layer:setTimesInfo(0)
    else
        if self:getTuhaoFreeTimes() > 0 then
            layer:setTimesInfo(1, self:getTuhaoFreeTimes())
        else
            layer:setTimesInfo(2, self:getTuhaoItemNum(), self:getTuhaoItemId())
        end
    end

    layer:setContectMaxLength(param.MaxLength)
    AlertManager:show()
    return layer;
end

function CommonManager:getTuhaoFreeTimes()
    return 2 - MainPlayer:getVipDeclarationFreeTimes()
end

function CommonManager:getTuhaoItemNum()
	if MainPlayer:getVipLevel() == 16 then
        return BagManager:getItemNumById(30113)
    elseif MainPlayer:getVipLevel() == 17 then
        return BagManager:getItemNumById(30114)
    elseif MainPlayer:getVipLevel() == 18 then
        return BagManager:getItemNumById(30115)
    end

    return 0
end

function CommonManager:getTuhaoItemId()
    if MainPlayer:getVipLevel() == 16 then
        return 30113
    elseif MainPlayer:getVipLevel() == 17 then
        return 30114
    elseif MainPlayer:getVipLevel() == 18 then
        return 30115
    end
end

function CommonManager:isTuhao()
    if MainPlayer:getVipLevel() == 16 or MainPlayer:getVipLevel() == 17 or MainPlayer:getVipLevel() == 18 then
        return true
    end
    return false
end

function CommonManager:setLoginCompleteState( state )
    self.loginCompleteState = state
end

function CommonManager:checkLoginCompleteState()
    if self.loginCompleteState then
        return true
    end
    return false
end
return CommonManager:new();