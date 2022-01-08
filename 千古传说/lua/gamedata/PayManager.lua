--[[
******充值管理类*******

	-- by haidong.gan
	-- 2013/12/27
]]


local PayManager = class("PayManager")


PayManager.EVENT_PAY_COMPLETE = "PayManager.EVENT_PAY_COMPLETE";
PayManager.GET_VIP_REWARD_RESULT = "PayManager.GET_VIP_REWARD_RESULT";
PayManager.GET_FIRST_CHARGE_REWARD_RESULT = "PayManager.GET_FIRST_CHARGE_REWARD_RESULT";

function PayManager:ctor()
    TFDirector:addProto(s2c.PAY_BILL_NO, self, self.onReceiveBillNo);
    TFDirector:addProto(s2c.PAY_COMPLETE, self, self.onReceivePayComplete);
    TFDirector:addProto(s2c.PAY_RECORD_LIST, self, self.onReceiveRecordList);

    TFDirector:addProto(s2c.GET_VIP_REWARD_RESULT, self, self.onReceiveVipRewardResult);
    TFDirector:addProto(s2c.VIP_REWARD_LIST, self, self.onReceiveVipRewardList);

    TFDirector:addProto(s2c.FIRST_RECHARGE_STATE, self, self.onReceiveFirstChargeState);
    TFDirector:addProto(s2c.GET_FIRST_RECHARGE_SUCCESS, self, self.onReceiveGetFirstChargeReward);

    TFDirector:addProto(s2c.DOUBLE_RECHARGE_INFO_LIST, self, self.onReceiveDoubleRechargeInfo);
    -- 
    self.firstChargeStatus = false -- 首冲没有被领取

    if CC_TARGET_PLATFORM == CC_PLATFORM_IOS then
        self.rechargeList = require("lua.table.t_s_recharge_ios");
    else
        self.rechargeList = require("lua.table.t_s_recharge");
    end
    
    self.vipList = require("lua.table.t_s_vip");
    self.paySource = 0
    self.firstRechargeRewardList = require("lua.table.t_s_first_recharge_reward");

    self.doubleRechargeInfo = {}
end


function PayManagerPaySDKCallBack( result )
    print("PayManagerPaySDKCallBack===",result)
    
    hideLoading();
    
    -- -- 
    -- if HeitaoSdk == nil then
    --     return
    -- end
    
    -- if HeitaoSdk.LOGIN_PAY_SUC == result then

    -- elseif HeitaoSdk.LOGIN_PAY_FAIL == result then
    --     hideLoading();
    -- end

end

function PayManager:onReceiveBillNo( event )
    print("onReceiveBillNo000000")
    print(event.data,MainPlayer:getPlayerId(),SaveManager:getUserInfo().currentServer)

    -- local payTab = TFSdk.payTab
    -- if not payTab then
    --     return
    -- end

    -- print(event.data)
    -- local userInfo = SaveManager:getUserInfo()
    -- payTab[TFSdk.ORDER_NO] = event.data.billNo
    -- payTab[TFSdk.PRODUCT_NAME]=event.data.goodName
    -- payTab[TFSdk.PRODUCT_PRICE]=event.data.price
    -- payTab[TFSdk.ROLE_ID]=MainPlayer:getPlayerId()
    -- payTab[TFSdk.SERVER_ID]=userInfo.currentServer
    -- TFSdk:payForProduct(payTab,PayManagerPaySDKCallBack)

    --local payTab = TFSdk.payTab
    --payTab[TFSdk.ORDER_NO] = event.data.billNo
    --payTab[TFSdk.PRODUCT_NAME]="ppppppp"
    --payTab[TFSdk.PRODUCT_PRICE]="1"
    --payTab[TFSdk.ROLE_ID]="0"
    --payTab[TFSdk.SERVER_ID]="0"
    --TFSdk:payForProduct(payTab,PayManagerPaySDKCallBack)

     -- local info = {
     --       Product_Price="1", 
     --       Product_Id="monthly",  
     --       Product_Name="gold",  
     --       Server_Id="13",  
     --       Product_Count="1",  
     --       Role_Id="1001",  
     --       Role_Name="zhangsan",
     --       Role_Grade="50",
     --       Role_Balance="1"
     --   }
    -- local userInfo = SaveManager:getUserInfo()
    -- local itemInfo = {}
    -- itemInfo["Product_Price"]   = ""..event.data.price
    -- itemInfo["Product_Id"]      = event.data.billNo
    -- itemInfo["Product_Name"]    = event.data.goodName
    -- itemInfo["Server_Id"]       = userInfo.currentServer
    -- itemInfo["Product_Count"]   = "1"
    -- itemInfo["Role_Id"]         = ""..MainPlayer:getPlayerId()
    -- itemInfo["Role_Name"]       = ""..MainPlayer:getPlayerName()
    -- itemInfo["Role_Grade"]      = ""..MainPlayer:getLevel()
    -- itemInfo["Role_Balance"]    = "元宝"

    -- print("itemInfo1 = ", itemInfo)
    -- local function payCallback(code, msg, info)
    --     if code == PayResultCode.kPaySuccess  then
    --        print("Pay Success")
    --     end
    -- end
    -- TFPlugins.setPayCallback(payCallback)
    -- TFPlugins.pay(itemInfo)
    
    hideLoading();

    local monthPay = 0 -- 是否为月卡
    local rechargeId = event.data.id
    local rechargeItem = self.rechargeList:objectByID(rechargeId)
    if rechargeItem.id == 7 then
        monthPay = 1
    elseif rechargeItem.id == 11 then
        monthPay = 1
    end

    local userInfo = SaveManager:getUserInfo()
    if HeitaoSdk then
        local price         = event.data.price
        local rate          = 10
        local count         = 1
        local fixedMoney    = true
        --local unitName      = "元宝"
        local unitName      = localizable.common_gold
        local productId     = event.data.billNo
        local serverId      = userInfo.currentServer
        local name          = event.data.goodName
        local callbackUrl   = nil
        local description   = nil
        local cpExtendInfo  = productId
        
        local sycee         = MainPlayer:getSycee()
        local level         = MainPlayer:getLevel()
        local viplevel      = MainPlayer:getVipLevel()
        local party         = ""
        local month         = monthPay 

        HeitaoSdk.setPayCallBack(PayManagerPaySDKCallBack)
        HeitaoSdk.pay(price, rate, count, fixedMoney, unitName, productId, serverId, name, callbackUrl, description, cpExtendInfo, sycee, level, viplevel, month, party)
    end
end

function PayManager:onReceivePayComplete( event )
    -- print("onReceivePayComplete")
    -- print(event.data)
    
    play_chongzhichenggong()

    hideLoading();

    local baseValue,extValue = self:getSyceeNumDetail(event.data.isFirstPay,event.data.id)

    local rechargeId = event.data.id
    local rechargeItem = self.rechargeList:objectByID(rechargeId)
    local textMsg = nil
    local textTemplete = [[<p style="text-align:left margin:5px"><font color="#000000" fontSize = "24">每日登陆即可领取</font><font color="#FF0000" fontSize = "24">%s</font><font color="#000000" fontSize = "24">元宝</font></p>]]
    if rechargeId == 7 then
        --toastMessage("恭喜您激活了大侠月卡")
        local cardInfo = MonthCardManager:getBtnStatus( MonthCardManager.CARD_TYPE_1 ) 
        local textSub = string.format(textTemplete, cardInfo.YB)
        -- textMsg = [[<p style="text-align:left margin:5px"><font color="#000000" fontSize = "24">]]
        -- textMsg = textMsg.."恭喜您激活了大侠月卡"
        -- textMsg = textMsg..[[<br></br>]]
        -- textMsg = textMsg.."充值成功获得 元宝"..baseValue
        -- textMsg = textMsg..[[<br></br>]]..[[<br></br>]]
        -- textMsg = textMsg..textSub
        -- textMsg = textMsg..[[</font>]]
        -- textMsg = textMsg..[[</p>]]

        textMsg = stringUtils.format(localizable.PayManager_monthCard_desc,  localizable.PayManager_monthCard_name1, baseValue, cardInfo.YB)
        
    elseif rechargeId == 11 then
        --toastMessage("恭喜您激活了豪侠月卡")
        MonthCardManager:buyBigMonthCardSuccess()
        local cardInfo = MonthCardManager:getBtnStatus( MonthCardManager.CARD_TYPE_2 ) 
        local textSub = string.format(textTemplete, cardInfo.YB)
        -- textMsg = [[<p style="text-align:left margin:5px"><font color="#000000" fontSize = "24">]]
        -- textMsg = textMsg.."恭喜您激活了豪侠月卡"
        -- textMsg = textMsg..[[<br></br>]]
        -- textMsg = textMsg.."充值成功获得 元宝"..baseValue
        -- textMsg = textMsg..[[<br></br>]]..[[<br></br>]]
        -- textMsg = textMsg..textSub
        -- textMsg = textMsg..[[</font>]]
        -- textMsg = textMsg..[[</p>]]        
        textMsg = stringUtils.format(localizable.PayManager_monthCard_desc, localizable.PayManager_monthCard_name2,  baseValue, cardInfo.YB)
    end
    if textMsg then
        local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.pay.CardJihuoLayer",AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_1)
        layer:setTextMsg(textMsg)            
        AlertManager:show()

       -- TFDirector:dispatchGlobalEventWith(PayManager.EVENT_PAY_COMPLETE, event.data);
        --return
    end
    -- if event.data.isFirstPay then
    --     self:showFirstPayResultLayer(event.data.id);
    -- else
    --     local baseValue,extValue = self:getSyceeNumDetail(event.data.isFirstPay,event.data.id)

    --     self:showPayResult(baseValue,extValue)
    --     -- toastMessage("已成功充值" .. self:getSyceeNumForPayCompelete(event.data.isFirstPay,event.data.id) .. "元宝！");
    -- end

    --local baseValue,extValue = self:getSyceeNumDetail(event.data.isFirstPay,event.data.id)

    self.index = rechargeId
    if rechargeId == 7 then
        self.index = 2
    elseif rechargeId == 11 then
        self.index = 3
    elseif rechargeId > 7 and rechargeId < 11 then
        self.index = rechargeId - 1
    end

    if baseValue and baseValue > 0 then
        local showValue = extValue
        print("event.data.multiple ==============",event.data.multiple)
        print("self.doubleRechargeInfo ==============",self.doubleRechargeInfo)
        if event.data.multiple then
            local multiple = self.doubleRechargeInfo[event.data.id]
            if multiple and multiple ~= 0 then
                showValue = showValue + math.ceil(multiple*baseValue)
            end
            self.doubleRechargeInfo = {}
        end
        self:showPayResult(baseValue,showValue, not event.data.multiple)
    end


    TFDirector:dispatchGlobalEventWith(PayManager.EVENT_PAY_COMPLETE, event.data);

    -- self:updateRecordList()
end

function PayManager:onReceiveVipRewardResult( event )
    -- print("onReceiveVipRewardResult")
    -- print(event.data)
    
    hideLoading();

    TFDirector:dispatchGlobalEventWith(PayManager.GET_VIP_REWARD_RESULT, event.data);
end

function PayManager:onReceiveRecordList( event )
    -- print("onReceiveRecordList")
    -- print(event.data)
    
    hideLoading();
    ViewDataCache:setCache(self.updateRecordList, event.data,ViewDataCache.Forever);
    TFDirector:dispatchGlobalEventWith(self.updateRecordList, event.data);
end

function PayManager:onReceiveVipRewardList( event )
    -- print("onReceiveVipRewardList")
    -- print(event.data)
    
    hideLoading();
    ViewDataCache:setCache(self.updateVipRewardList, event.data,ViewDataCache.Forever);
    TFDirector:dispatchGlobalEventWith(self.updateVipRewardList, event.data);
end

function PayManager:getSyceeNumForPayCompelete(isFirstPay,rechargeId)
    local rechargeItem = self.rechargeList:objectByID(rechargeId);


    -- 记录新的充值
    OperationActivitiesManager:SysceeSupply(rechargeId, rechargeItem)


    if self:isHavePay(rechargeItem.id) then
        return rechargeItem.sycee + rechargeItem.extra_sycee ;
    else
        return rechargeItem.sycee * 2 + rechargeItem.extra_sycee ;
    end

    -- if isFirstPay then
    --     return rechargeItem.sycee * ConstantData:getValue("Recharge.First.Multiple") + rechargeItem.extra_sycee ;
    -- else
    --     return rechargeItem.sycee + rechargeItem.extra_sycee ;
    -- end
end

function PayManager:getSyceeNumDetail(isFirstPay,rechargeId)
    local rechargeItem = self.rechargeList:objectByID(rechargeId);


    -- 记录新的充值
    OperationActivitiesManager:SysceeSupply(rechargeId, rechargeItem)

    local baseValue = 0
    local extValue = 0
    if rechargeItem.id ==7 or rechargeItem.id == 11 then
        baseValue = rechargeItem.sycee
        extValue  = rechargeItem.extra_sycee
    elseif self:isHavePay(rechargeItem.id) then
        baseValue = rechargeItem.sycee
        extValue  = rechargeItem.extra_sycee
    else
        -- baseValue = rechargeItem.sycee * 2
        baseValue = rechargeItem.sycee
        -- extValue  = rechargeItem.extra_sycee + rechargeItem.sycee
        extValue  = rechargeItem.sycee
    end


    return baseValue, extValue
end

function PayManager:getRewardListForFirstPay()
    local rewardList = TFArray:new();
    for rewardItem in self.firstRechargeRewardList:iterator() do
        local reward = {};
        reward.itemId = rewardItem.res_id;
        reward.number = rewardItem.number;
        reward.type   = rewardItem.res_type;
        rewardList:push(BaseDataManager:getReward(reward))
    end      
    return rewardList;
end

function PayManager:getReward(vipId)
    local vipItem = self.vipList:objectByID(vipId)
    return RewardConfigureData:GetRewardItemListById(tonumber(vipItem.reward));
end

function PayManager:getNextVip()
    local nextVip = MainPlayer:getVipLevel() + 1 ;

    if self.vipList:objectByID(nextVip) then
        return nextVip;
    end
    return -1;
end

function PayManager:getNextNeedMoney()
    local nextVip = self:getNextVip() ;
    if nextVip ~= -1 then
        return  self.vipList:objectByID(nextVip).recharge - MainPlayer:getTotalRecharge();
    end
    return -1;
end

function PayManager:getNextVipNeedMoney()
    local nextVip = self:getNextVip() ;
    if nextVip ~= -1 then
        return  self.vipList:objectByID(nextVip).recharge
    end
    return -1;
end

function PayManager:isHavePay(id)
    -- print("self.updateRecordList = ", self.updateRecordList)
    local dataCache  = ViewDataCache:getCache(self.updateRecordList)
    if not dataCache then
        return false;
    end
    
    -- local recordList =ViewDataCache:getCache(self.updateRecordList).recordList
    local recordList = dataCache.recordList

    if not recordList then
        return false;
    end
    for k,record in pairs(recordList) do
        if record.buyTimes > 0 and record.id == id then
            return true;
        end
    end
    return false;
end


function PayManager:getTotalRecharge()
    local dataCache  = ViewDataCache:getCache(self.updateRecordList)
    if not dataCache then
        return 0;
    end
    
    local recordList = dataCache.recordList
    if not recordList then
        return 0;
    end
    local total = 0
    for k,record in pairs(recordList) do
        -- if record.id ~= 7 and record.id ~= 11 then
            local rechargeItem = self.rechargeList:objectByID(record.id);
            if rechargeItem then
                total = total + record.buyTimes * rechargeItem.price
            end
        -- end
    end
    return total;
end
function PayManager:isHaveGetVipReward(id)
    if not ViewDataCache:getCache(self.updateVipRewardList) then
        print("PayManager 111111111")
        return false;
    end
    
    local rewardList = ViewDataCache:getCache(self.updateVipRewardList).rewardList;
    if not rewardList then
        print("PayManager 2222222")
        return false;
    end
    for k,item in pairs(rewardList) do
        if item.id == id then
            print("PayManager 33333333")
            return item.isHaveGot;
        end
    end
    return false;
end

function PayManager:getNeedMoneyVip(vip)
    return  self.vipList:objectByID(vip).recharge
end

function PayManager:createIconRewardNode(rewardItem)
    local reward_item  = createUIByLuaNew("lua.uiconfig_mango_new.pay.RewardItem");

    local txt_name =  TFDirector:getChildByPath(reward_item, 'txt_name');
    txt_name:setText(rewardItem.name);

    local img_icon =  TFDirector:getChildByPath(reward_item, 'img_icon');
    img_icon:setTexture(rewardItem.path);

    local txt_num =  TFDirector:getChildByPath(reward_item, 'txt_num');
    txt_num:setText("x" .. rewardItem.number);

    return reward_item;
end

function PayManager:setPaySource(source)
    self.paySource = source
end

function PayManager:pay(rechargeId, index)
    self.vipLevelBeforePay = MainPlayer:getVipLevel()
    self.index = index
    showLoading();
    TFDirector:send(c2s.PAY_GET_BILL_NO, {rechargeId, self.paySource});
end


function PayManager:getVipReward(vipId)
    showLoading();
    TFDirector:send(c2s.GET_VIP_REWARD, {vipId} );
end

function PayManager:updateRecordList()
    showLoading();
    TFDirector:send(c2s.GET_PAY_RECORD_LIST, {} );
end

function PayManager:updateVipRewardList()
    showLoading();
    TFDirector:send(c2s.GET_VIP_REWARD_LIST, {} );
end


function PayManager:restart()
    self.doubleRechargeInfo = {}
end


function PayManager:resetFreeTime()
    self.doubleRechargeInfo = {}
end

function PayManager:showPayLayer(callbackFunc,tween,isShowFirstPay)
    -- self:showVipLayer(tween);
    if MainPlayer:isPayOpen() == false then
        --toastMessage("充值暂未开放");
        toastMessage(localizable.PayManager_not_open)
        return
    end
    tween = tween or AlertManager.TWEEN_1;
    if isShowFirstPay == nil then
        isShowFirstPay = false
    end
    if isShowFirstPay == true and MainPlayer:getTotalRecharge() == 0 then
    -- if  self:IsUserFirstPay() == true then
        local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.pay.NeedFirstPayLayer",AlertManager.BLOCK_AND_GRAY,tween);
        AlertManager:show();
    else
        local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.pay.PayLayer",AlertManager.BLOCK_AND_GRAY,tween);
        layer:setCloseCallback(callbackFunc)
        AlertManager:show();
        getDynamicData(self, self.updateRecordList);
    end
end

function PayManager:showFirstPayLayer(tween)
    -- self:showVipLayer(tween);
    if MainPlayer:isPayOpen() == false then
        --toastMessage("充值暂未开放");
        toastMessage(localizable.PayManager_not_open)
        return
    end

    local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.pay.NeedFirstPayLayer",AlertManager.BLOCK_AND_GRAY,tween);
    AlertManager:show();
end

function PayManager:showPayHomeLayer(tween)
    -- self:showVipLayer(tween);
    if MainPlayer:isPayOpen() == false then
        --toastMessage("充值暂未开放");
        toastMessage(localizable.PayManager_not_open)
        return
    end
    tween = tween or AlertManager.TWEEN_1;
    AlertManager:addLayerToQueueAndCacheByFile("lua.logic.pay.PayLayer",AlertManager.BLOCK_AND_GRAY,tween);

    AlertManager:show();
    getDynamicData(self, self.updateRecordList);
end

function PayManager:showVipLayer(tween)
    tween = tween or AlertManager.TWEEN_1;
    AlertManager:addLayerToQueueAndCacheByFile("lua.logic.pay.VipLayer",AlertManager.BLOCK_AND_GRAY,tween);
    AlertManager:show();

    getDynamicData(self, self.updateVipRewardList);
end

function PayManager:showVipChangeLayer(tween)
    local tween = AlertManager.TWEEN_1;
    AlertManager:addLayerToQueueAndCacheByFile("lua.logic.pay.VipChangeLayer",AlertManager.BLOCK_AND_GRAY,tween);
    AlertManager:show();
    getDynamicData(self, self.updateVipRewardList);
end

function PayManager:showNeedSycee(tween)
    -- self:showVipLayer(tween);
    tween = tween or AlertManager.TWEEN_1;
    if MainPlayer:getTotalRecharge() == 0 then
        AlertManager:addLayerToQueueAndCacheByFile("lua.logic.pay.NeedFirstPayLayer",AlertManager.BLOCK_AND_GRAY,tween);
    else
        AlertManager:addLayerToQueueAndCacheByFile("lua.logic.pay.NeedPayLayer",AlertManager.BLOCK_AND_GRAY,tween);
    end

 
    AlertManager:show();
end


function PayManager:showFirstPayResultLayer(rechargeId)
    local sycee = self:getSyceeNumForPayCompelete(true,rechargeId);
    local rewardList = self:getRewardListForFirstPay();

    local reward_sycee = {};
    reward_sycee.itemId = 1;
    reward_sycee.number = sycee;
    reward_sycee.type   = EnumDropType.SYCEE;

    rewardList:push(BaseDataManager:getReward(reward_sycee));

    RewardManager:showRewardListLayer( rewardList )

    -- local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.pay.FirstPayResultLayer");
    -- layer:loadData(rechargeId);
    -- AlertManager:show();
end

function PayManager:showPayResult(baseValue, extValue,showMultiple)
    -- local bVipChanged = false
    local curVipLevel = MainPlayer:getVipLevel()
    
    if self.index == nil then
        self.index = 5
    end
    
    if self.vipLevelBeforePay == nil then
        self.vipLevelBeforePay = curVipLevel
    end

    -- if self.vipLevelBeforePay ~= curVipLevel then
    --     bVipChanged = true
    -- end

    tween = tween or AlertManager.TWEEN_1
    local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.pay.PayResultLayer",AlertManager.BLOCK_AND_GRAY_CLOSE,tween)
    layer:setValue(baseValue, extValue,showMultiple)
    layer:setVipLevel(self.vipLevelBeforePay, curVipLevel)
    layer:setIcon(self.index)
    AlertManager:show()

    self.vipLevelBeforePay = curVipLevel
end

function PayManager:addLayerToCache()

end

function PayManager:IsUserFirstPay()

    for recharge in self.rechargeList:iterator()  do
        if self:isHavePay(recharge.id) then
            return false
        end
    end

    return true
end
--是否单次首冲了超过cost的充值
function PayManager:IsFirstPayMore(cost)

    for recharge in self.rechargeList:iterator()  do
        if recharge.price >= cost and self:isHavePay(recharge.id) then
            return true
        end
    end

    return false
end

-- true 可领取  false不可以领取
function PayManager:getFirstChargeState()
    
    return self.firstChargeStatus
end

function PayManager:onReceiveFirstChargeState(event)

    -- 
    self.firstChargeStatus = event.data.enable ---- true 可领取  false不可以领取


end

function PayManager:onReceiveDoubleRechargeInfo(event)
    local data = event.data
    self.doubleRechargeInfo  = {}
    if data.list == nil then
        return
    end
    for i=1,#data.list do
        local info = data.list[i]
        self.doubleRechargeInfo[info.index] = info.multiple/100
    end
    -- self.doubleRechargeInfo = data.list
end


function PayManager:getDoubleRechargeListNum()
    local num = 0
    for k,v in pairs(self.doubleRechargeInfo) do
        if v ~= 0 then
            num = num + 1
        end
    end
    return num
end


function PayManager:getDoubleRechargeByIndex(index)
    local num = 1
    for k,v in pairs(self.doubleRechargeInfo) do
        if num == index then
            return k ,v
        end
        num = num + 1
    end
    return 0,0
end

function PayManager:onReceiveGetFirstChargeReward(event)
    self.firstChargeStatus = false

    hideLoading()

    TFDirector:dispatchGlobalEventWith(self.GET_FIRST_CHARGE_REWARD_RESULT, event.data)
end

function PayManager:requestFirstChargeReward()

    showLoading();
    TFDirector:send(c2s.GET_FIRST_RECHARGE_REWARD, {})
end


return PayManager:new();
