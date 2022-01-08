--[[
******主角头像框管理类*******

	-- by Chikui Peng
	-- 2016/3/4
]]


local HeadPicFrameManager = class("HeadPicFrameManager")

HeadPicFrameManager.Init_Data             = "HeadPicFrameManager.Init_Data";
HeadPicFrameManager.Change_Frame              = "HeadPicFrameManager.Change_Frame";
HeadPicFrameManager.Brush_Frame              = "HeadPicFrameManager.Brush_Frame";
HeadPicFrameManager.Clear_Red              = "HeadPicFrameManager.Clear_Red";

function HeadPicFrameManager:ctor()
    self.isRequest = false
    self.clearRed = false
    self.unlockedlist = {}
    self.lockedList = {}
    TFDirector:addProto(s2c.HEAD_PIC_FRAME_RESULT, self, self.onReceiveInitData);
    TFDirector:addProto(s2c.HEAD_PIC_FRAME_REFRESH_RESULT, self, self.onReceiveBrushFrame);
    TFDirector:addProto(s2c.HEAD_PIC_FRAME_SET_RESULT, self, self.onReceiveChangeHeadPicFrame);
    TFDirector:addProto(s2c.HEAD_PIC_FRAME_OPEN_RESULT, self, self.onReceiveOpenLayer);
end

function HeadPicFrameManager:requestHeadPicFrameData()
    print("HeadPicFrameManager:requestHeadPicFrameData+++++++++++++++++++++++++++++++++++++++++++++++++++++")
    showLoading();
    TFDirector:send(c2s.HEAD_PIC_FRAME_REQUEST, {});
end

function HeadPicFrameManager:requestChangeHeadPicFrame(frameId)
    print("HeadPicFrameManager:requestChangeHeadPicFrame+++++++++++++++++++++++++++++++++++++++++++++++++++++")
    showLoading();
    local msg = {
        frameId
    }
    TFDirector:send(c2s.HEAD_PIC_FRAME_SET, msg);
end

function HeadPicFrameManager:requestOpenLayer()
    print("HeadPicFrameManager:requestOpenLayer+++++++++++++++++++++++++++++++++++++++++++++++++++++")
    showLoading();
    TFDirector:send(c2s.HEAD_PIC_FRAME_OPEN, {});
end

function HeadPicFrameManager:onReceiveInitData( event )
    print("onReceiveInitData")
    hideLoading();
    self.unlockedlist = event.data.unlockedlist or {}
    self.lockedList = event.data.lockedList or {}
    TFDirector:dispatchGlobalEventWith(self.Init_Data, nil);
end

function HeadPicFrameManager:onReceiveBrushFrame( event )
    print("onReceiveBrushFrame")
    hideLoading();
    local unlockedlist = event.data.unlockedlist or {}
    local lockedList = event.data.lockedList or {}
    for k,v in ipairs(unlockedlist) do
        self:addUnlockedItem(v)
    end
    for k,v in ipairs(lockedList) do
        self:addLockedItem(v)
    end
    TFDirector:dispatchGlobalEventWith(self.Brush_Frame, nil);
end

function HeadPicFrameManager:addUnlockedItem(data)
    local index = nil;
    for k,v in ipairs(self.unlockedlist) do
        if v.id == data.id then
            index = k;
            break;
        end
    end
    if nil == index then
        index = 1 + #(self.unlockedlist);
    end
    self.unlockedlist[index] = data;
    index = nil;
    for k,v in ipairs(self.lockedList) do
        if v.id == data.id then
            index = k;
        end
    end
    if nil ~= index then
        local frameData = HeadPicFrameData:objectByID(self.lockedList[index].id)
        if frameData.visible == 1 then
            --toastMessage("成功解锁头像框:"..frameData.name)
            toastMessage(stringUtils.format(localizable.HeadPicFrameManager_jiesuo_success, frameData.name))
            table.remove( self.lockedList, index );
        end
    end
end

function HeadPicFrameManager:addLockedItem(data)
    local index = nil
    for k,v in ipairs(self.lockedList) do
        if v.id == data.id then
            index = k;
            break;
        end
    end
    if nil == index then
        index = 1 + #(self.lockedList);
    end
    self.lockedList[index] = data;
    index = nil;
    for k,v in ipairs(self.unlockedlist) do
        if v.id == data.id then
            index = k;
        end
    end
    if nil ~= index then
        --toastMessage("头像框已过期")
        table.remove( self.unlockedlist, index );
    end
end

function HeadPicFrameManager:checkFrameTime(frameId)
    local data = nil
    for k,v in ipairs(self.unlockedlist) do
        if frameId == v.id then
            data = v
            break;
        end
    end
    if data == nil then
        return false;
    end
    local frameData = HeadPicFrameData:objectByID(data.id);
    if frameData ~= nil then
        local validityTime = frameData.validity_hour;
        if validityTime > 0 then
            local leftTime =  data.expireTime / 1000 - MainPlayer:getNowtime();
            if leftTime <= 0 then
                local item = {
                    id = data.id,
                    currentNum = 0
                };
                self:addLockedItem(item);
                return false;
            end
        end
    else
        return false;
    end
    return true;
end

function HeadPicFrameManager:onReceiveOpenLayer( event )
    print("onReceiveOpenLayer");
    hideLoading();
    self.clearRed = true
end

function HeadPicFrameManager:ClearRed()
    self.clearRed = false
    for k,v in ipairs(self.unlockedlist) do
        self.unlockedlist[k].firstGet = false
    end
end

function HeadPicFrameManager:isClearRed()
    return self.clearRed
end

function HeadPicFrameManager:onReceiveChangeHeadPicFrame( event )
    print("onReceiveSetIcon")
    hideLoading();
    local frameId = event.data.code;
    if frameId == nil or frameId <= 0 then
        --toastMessage("无效的头像框")
        toastMessage(localizable.HeadPicFrameManager_wuxiao)
        print("....................."..frameId)
        return
    end
    MainPlayer:setHeadPicFrameId(frameId);
    TFDirector:dispatchGlobalEventWith(self.Change_Frame, {id = iconId});
end

function HeadPicFrameManager:isEnough(id)
    local frameData = HeadPicFrameData:objectByID(id)
    local num = BagManager:getItemNumById(frameData.gain_way_id)
    if num < frameData.gain_way_num then
        return false
    end
    return true
end

function HeadPicFrameManager:restart()
    self.clearRed = false
end

function HeadPicFrameManager:check()
    if nil == self.unlockedlist then
        return false;
    end
    return true;
end

function HeadPicFrameManager:checkValidity()
    for k,v in ipairs(self.unlockedlist) do
        local frameData = HeadPicFrameData:objectByID(v.id)
        if frameData ~= nil then
            local validityTime = frameData.validity_hour
            if validityTime > 0 then
                local leftTime =  v.expireTime / 1000 - MainPlayer:getNowtime()
                if leftTime <= 0 then
                    local data = {
                        id = v.id,
                        currentNum = 0
                    }
                    self:addLockedItem(data)
                end
            end
        end
    end
end

function HeadPicFrameManager:isUnlocked( frameId )
    for k,v in ipairs(self.unlockedlist) do
        if v.id == frameId then
            local frameData = HeadPicFrameData:objectByID(v.id)
            if frameData == nil then
                return true
            end
            local validityTime = frameData.validity_hour
            if validityTime > 0 then
                local leftTime =  v.expireTime / 1000 - MainPlayer:getNowtime()
                if leftTime <= 0 then
                    local data = {
                        id = v.id,
                        currentNum = 0
                    }
                    self:addLockedItem(data)
                    return false
                end
            end
            return true
        end
    end
    return false
end

function HeadPicFrameManager:OpenChangeIconLayer()
    self:requestOpenLayer()
end

function HeadPicFrameManager:getUnlockedList()
    local ret = self.unlockedlist;
    return ret;
end

function HeadPicFrameManager:getLockedList()
    local ret = self.lockedList;
    return ret;
end

function HeadPicFrameManager:haveFirstGetFrame()
    for k,v in pairs(self.unlockedlist) do
        if v.firstGet == true then
            return true
        end
    end
    return false
end

return HeadPicFrameManager:new();
