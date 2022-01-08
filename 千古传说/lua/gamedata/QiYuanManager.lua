--[[
******祈愿管理类*******

	-- by Chikui Peng
	-- 2016/2/26
]]


local QiYuanManager = class("QiYuanManager")

QiYuanManager.Buy_Reward            = "QiYuanManager.Buy_Reward";
QiYuanManager.Init_Data             = "QiYuanManager.Init_Data";
QiYuanManager.Refresh_Data          = "QiYuanManager.Refresh_Data";
QiYuanManager.Day_Reward            = "QiYuanManager.Day_Reward";

function QiYuanManager:ctor()
    self.data = nil
    self.cdTime = 300--ConstantData:objectByID("Jiuguan.Qiyuan.Time").value
    --local addNum = VipRuleManager:getQiYuanTimesAddNum()
    self.maxTimes = 3 --+ addNum
    self.maxDay = 15--ConstantData:objectByID("Jiuguan.Qiyuan.MaxTime").value
    self.isRequest = false

    TFDirector:addProto(s2c.INVOCATORY, self, self.onReceiveInitData);
   
    TFDirector:addProto(s2c.SHOW_INVOCATORY_REWARD, self, self.onReceiveRefreshData);

    TFDirector:addProto(s2c.SEND_INVOCATORY_REWARD, self, self.onReceiveBuyInfo);

    TFDirector:addProto(s2c.SEND_INVOCATORY_DAY_REWARD, self, self.onReceiveDayReward);

    TFDirector:addProto(s2c.USED_INVOCATORY_GOODS_RESULT, self, self.onReceiveUsedItemRefreshData);
end

function QiYuanManager:requestInitData()
    print("QiYuanManager:requestInitData+++++++++++++++++++++++++++++++++++++++++++++++++++++")
    showLoading();
    TFDirector:send(c2s.QUERY_INVOCATORY, {} );
end

function QiYuanManager:requestQiYuan(roleId)
    print("QiYuanManager:requestQiYuan+++++++++++++++++++++++++++++++++++++++++++++++++++++")
    showLoading();
    local msg = {
        roleId
    }
    TFDirector:send(c2s.GET_INVOCATORY_REWARD, msg);
end

function QiYuanManager:requestUseItem(roleId)
    print("QiYuanManager:requestUseItem+++++++++++++++++++++++++++++++++++++++++++++++++++++")
    showLoading();
    local msg = {
        roleId
    }
    TFDirector:send(c2s.UES_INVOCATORY_GOODS, msg);
end

function QiYuanManager:requestBuyReward(Idx)
    print("QiYuanManager:requestBuyReward+++++++++++++++++++++++++++++++++++++++++++++++++++++")
    showLoading();
    local msg = {
        Idx
    }
    TFDirector:send(c2s.GET_REWARD, msg );
end

function QiYuanManager:requestGetReward()
    print("QiYuanManager:requestGetReward+++++++++++++++++++++++++++++++++++++++++++++++++++++")
    showLoading();
    TFDirector:send(c2s.GET_INVOCATORY_DAY_REWARD, {} );
end

function QiYuanManager:onReceiveDayReward(event)
    print("onReceiveDayReward")
    hideLoading();
    if event.data.success == 1 then
        self.data.rewardDay = 0
        TFDirector:dispatchGlobalEventWith(self.Day_Reward, nil);
    end
end

function QiYuanManager:onReceiveBuyInfo( event )
    print("onReceiveBuyInfo")
    hideLoading();
    local index = event.data.indexId
    self.data.info[index] = event.data.info[1]
    TFDirector:dispatchGlobalEventWith(self.Buy_Reward, nil);
end

function QiYuanManager:onReceiveInitData( event )
    print("onReceiveInitData")
    hideLoading();
    self.data = event.data
    TFDirector:dispatchGlobalEventWith(self.Init_Data, nil);
end

function QiYuanManager:onReceiveRefreshData( event )
    print("onReceiveRefreshData")
    hideLoading();
    self.data = event.data
    TFDirector:dispatchGlobalEventWith(self.Refresh_Data, nil);
end

function QiYuanManager:onReceiveUsedItemRefreshData( event )
    print("onReceiveUsedItemRefreshData")
    hideLoading();
    self.data.roleId = event.data.roleId
    self.data.rewardDay = event.data.rewardDay
    self.data.info = event.data.info
    TFDirector:dispatchGlobalEventWith(self.Refresh_Data, nil);
end

function QiYuanManager:restart()
    self.data = nil
    self.isRequest = false
end

function QiYuanManager:check()
    if nil == self.data then
        if self.isRequest == false then
            self:requestInitData()
            self:refreshData()
            self.isRequest = true
        end
        return false
    end
    return true
end

function QiYuanManager:refreshData()
    self.cdTime = ConstantData:objectByID("Jiuguan.Qiyuan.Time").value
    local addNum = VipRuleManager:getQiYuanTimesAddNum()
    self.maxTimes = 3 + addNum
    self.maxDay = ConstantData:objectByID("Jiuguan.Qiyuan.MaxTime").value
end

function QiYuanManager:getQiYuanCD()
    if self:check() == false then
        return 0
    end
    local time = self.cdTime
    if time <= 0 then
        return 0
    end
    time = self.data.rewardTime + time - MainPlayer:getNowtime()
    return time
end

function QiYuanManager:isCanQiyuan()
    if self:check() == false then
        return false
    end
    if self:getQiYuanItemNum() > 0 then
        return true
    end
    if self.data.todayCount >= self.maxTimes then
        return false
    end
    if self:getQiYuanCD() > 0 then
        return false
    end
    return true
end

function QiYuanManager:GetFree()
    if self:check() == false then
        return
    end
    for i=1,3 do
        if self.data.info[i].roleId > 0 then
            if self.data.info[i].roleSycee <= 0 and self.data.info[i].isGetReward == 0 then
                self:requestBuyReward(i)
            end
        end
    end
end

function QiYuanManager:isAllBought()
    if self:check() == false then
        return true
    end
    local bCanBuy = false
    for i=1,3 do
        if self.data.info[i].roleId > 0 then
            if self.data.info[i].roleSycee > 0 and self.data.info[i].isGetReward == 0 then
                bCanBuy = true
                break
            end
        end
    end
    return not bCanBuy
end

function QiYuanManager:getQiYuanItemNum()
    local item = BagManager:getItemById(30087)
    if item == nil then
        return 0
    end
    return item:getNum()
end

function QiYuanManager:OpenQiYuanLayer()
    if self:isUnLockQiYuan() == true then
        local layer =  AlertManager:addLayerByFile("lua.logic.shop.QiYuanLayer");
        AlertManager:show();
    else
        local openLev = FunctionOpenConfigure:getOpenLevel(2202)
        -- toastMessage("团队等级达到"..openLev.."级开启")
        toastMessage(stringUtils.format(localizable.common_function_openlevel, openLev))
    end
end

function QiYuanManager:isUnLockQiYuan()
    local teamLev = MainPlayer:getLevel()
    local openLev = FunctionOpenConfigure:getOpenLevel(2202)
    if teamLev < openLev then
        return false
    end
    return true
end

function QiYuanManager:isHaveQiYuanFree()
    if self:check() == false then
        return false
    end
    if self:isUnLockQiYuan() == false then
        return false
    end
    if self.data.todayCount >= self.maxTimes then
        return false
    end
    if self:getQiYuanCD() > 0 then
        return false
    end
    return true
end

function QiYuanManager:getSelectedRoleId()
    if self:check() == false then
        return nil
    end
    if self.data.roleId <= 0 then
        return nil
    end
    return self.data.roleId
end

function QiYuanManager:getTimes()

    local ret = {}
    ret.maxTimes = self.maxTimes
    if self:check() == false then
        ret.curTimes = 0
    else
        ret.curTimes = self.data.todayCount
    end
    return ret
end

function QiYuanManager:getInfos()
    local ret = {}
    ret = self.data.info
    return ret
end

function QiYuanManager:getDay()
    if self:check() == false then
        return 0,self.maxDay
    end
    return self.data.rewardDay,self.maxDay
end

return QiYuanManager:new();
