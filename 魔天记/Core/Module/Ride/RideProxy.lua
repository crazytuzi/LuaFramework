require "Core.Module.Pattern.Proxy"

RideProxy = Proxy:New();

local feedMaterials = { }
function RideProxy:OnRegister()
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.RideActivate, RideProxy.ActivateRideCallBack);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.UseRide, RideProxy.UseRideCallBack);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.CancleRide, RideProxy.CancleRideCallBack);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.RideExpired, RideProxy.RideExpiredCallBack);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.RideBecomeExpired, RideProxy.RideBecomeExpiredCallBack);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.RideRenewal, RideProxy.RideRenewalCallBack);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GetDownRide, RideProxy.GetDownRideCallBack);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GetOnRide, RideProxy.GetOnRideCallBack);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.RideFeed, RideProxy.RideFeedCallBack);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.RideFeedOneKey, RideProxy.RideFeedOneKeyCallBack);


end

function RideProxy:OnRemove()
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.RideActivate, RideProxy.ActivateRideCallBack);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.UseRide, RideProxy.UseRideCallBack);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.CancleRide, RideProxy.CancleRideCallBack);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.RideExpired, RideProxy.RideExpiredCallBack);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.RideBecomeExpired, RideProxy.RideBecomeExpiredCallBack);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.RideRenewal, RideProxy.RideRenewalCallBack);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GetDownRide, RideProxy.GetDownRideCallBack);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GetOnRide, RideProxy.GetOnRideCallBack);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.RideFeed, RideProxy.RideFeedCallBack);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.RideFeedOneKey, RideProxy.RideFeedOneKeyCallBack);
end

function RideProxy.RideFeedCallBack(cmd, data)
    if (data and data.errCode == nil) then
        RideProxy.ResetRideFeedMaterials()
        RideManager.UpdateFeedData(data)
        ModuleManager.SendNotification(RideNotes.UPDATE_RIDEPANEL)
        ModuleManager.SendNotification(RideNotes.SHOW_RIDEFEED_UPDATEEFFECT)
        UISoundManager.PlayUISound(UISoundManager.ui_enhance1)
        PlayerManager.CalculatePlayerAttribute(HeroController.CalculateAttrType.RideFeed)
    end
end

function RideProxy.RideFeedOneKeyCallBack(cmd, data)
    if (data and data.errCode == nil) then
        RideProxy.ResetRideFeedMaterials()
        RideManager.UpdateFeedData(data)
        ModuleManager.SendNotification(RideNotes.UPDATE_RIDEPANEL)
        ModuleManager.SendNotification(RideNotes.SHOW_RIDEFEED_UPDATEEFFECT)
        UISoundManager.PlayUISound(UISoundManager.ui_enhance1)
        PlayerManager.CalculatePlayerAttribute(HeroController.CalculateAttrType.RideFeed)

    end
end

local insert = table.insert
function RideProxy.SendRideFeed()
    if (table.getCount(feedMaterials) > 0) then
        local items = { }
        for k, v in pairs(feedMaterials) do
            insert(items, k)
        end
        SocketClientLua.Get_ins():SendMessage(CmdType.RideFeed, { items = items });
    else
        MsgUtils.ShowTips("ride/rideProxy/selectFeedMaterial")
    end
end

function RideProxy.SendRideFeedOnKey()
    SocketClientLua.Get_ins():SendMessage(CmdType.RideFeedOneKey);
end

function RideProxy.GetDownRideCallBack(cmd, data)
    if (data and data.errCode == nil) then
        MessageManager.Dispatch(RideManager, RideManager.RideDownOrOn, false)
    end
end

function RideProxy.GetOnRideCallBack(cmd, data)
    if (data and data.errCode == nil) then
        MessageManager.Dispatch(RideManager, RideManager.RideDownOrOn, true)
    end
end

-- 坐骑一分钟后消失（服务器通知）
function RideProxy.RideBecomeExpiredCallBack(cmd, data)
    if (data and data.errCode == nil) then
        ModuleManager.SendNotification(ConfirmNotes.OPEN_CONFIRM1PANEL, {
            msg = LanguageMgr.Get("ride/rideProxy/rideExpire"),
            hander = function()
                ModuleManager.SendNotification(RideNotes.OPEN_RIDEPANEL)
            end
            ,
            ok_Label = LanguageMgr.Get("ride/rideProxy/rideOk"),
            cance_lLabel = LanguageMgr.Get("ride/rideProxy/rideCancle")
        } );
    end
end

function RideProxy.RideRenewalCallBack(cmd, data)
    if (data and data.errCode == nil) then
        MsgUtils.ShowTips("ride/rideProxy/renewSuc")
        local rideData = RideManager.GetRideDataById(data.id)
        rideData.info:SetServerInfo(0, data.rt)
        RideManager.SetAllRidePropertyUpdate(true)
        ModuleManager.SendNotification(RideNotes.UPDATE_RIDEPANEL)
        PlayerManager.CalculatePlayerAttribute(HeroController.CalculateAttrType.Ride)
    end
end

function RideProxy.SendRideRenewal(id)
    SocketClientLua.Get_ins():SendMessage(CmdType.RideRenewal, { id = id });
end

function RideProxy.RideExpiredCallBack(cmd, data)
    if (data and data.errCode == nil) then
        RideManager.SetRideUnActivate(data.id)
        ModuleManager.SendNotification(RideNotes.UPDATE_RIDEPANEL)
        PlayerManager.CalculatePlayerAttribute(HeroController.CalculateAttrType.Ride)

    end
end

-- id:坐骑id int
function RideProxy.SendActivateRide(id)
    SocketClientLua.Get_ins():SendMessage(CmdType.RideActivate, { id = id });
end

function RideProxy.SendUseRide()
    SocketClientLua.Get_ins():SendMessage(CmdType.UseRide, { id = RideManager.GetCurrentRideId() });
end

function RideProxy.SendCancleRide()
    SocketClientLua.Get_ins():SendMessage(CmdType.CancleRide, { });
end

function RideProxy.SendGetOnRide()
    SocketClientLua.Get_ins():SendMessage(CmdType.GetOnRide, { });
end

function RideProxy.SendGetDownRide()
    SocketClientLua.Get_ins():SendMessage(CmdType.GetDownRide, { });
end

function RideProxy.ActivateRideCallBack(cmd, data)
    if (data.errCode == nil) then
        RideManager.SetRideActive(data)
        ModuleManager.SendNotification(RideNotes.UPDATE_RIDEPANEL)
        PlayerManager.CalculatePlayerAttribute(HeroController.CalculateAttrType.Ride)
        UISoundManager.PlayUISound(UISoundManager.ui_realm)
        SequenceManager.TriggerEvent(SequenceEventType.Guide.MOUNT_ACITVITY, data.id)
    end
end

function RideProxy.UseRideCallBack(cmd, data)
    if (data.errCode == nil) then
        RideProxy.SendGetOnRide()
        RideManager.SetRideUsed(data.id)
        ModuleManager.SendNotification(RideNotes.UPDATE_RIDEPANEL)
    end
end

function RideProxy.CancleRideCallBack(cmd, data)
    if (data.errCode == nil) then
        RideManager.SetRideUnUsed()
        ModuleManager.SendNotification(RideNotes.UPDATE_RIDEPANEL)
    end
end

function RideProxy.SetCurrentRideId(id)
    -- local rideData = RideManager.GetRideDataById(id)
    --    if (rideData) then
    --        local needItem = rideData.info:GetSynthetic()
    --        if (needItem) then
    --            local count = BackpackDataManager.GetProductTotalNumBySpid(needItem.itemId)
    --            if (count >= needItem.itemCount) then
    --                RideProxy.SendActivateRide(id)
    --            end
    --        end
    --    end
    RideManager.SetCurrentRideId(id)
    ModuleManager.SendNotification(RideNotes.UPDATE_RIDEPANEL)
end

function RideProxy.AddRideFeedMaterial(id, spid, count)
    feedMaterials[id] = { }
    feedMaterials[id].id = spid
    feedMaterials[id].am = count

end

function RideProxy.RemoveRideFeedMaterial(id)
    feedMaterials[id] = nil
end

function RideProxy.ResetRideFeedMaterials()
    feedMaterials = { }
end

function RideProxy.IsMaterialSelect(id)
    return feedMaterials[id] or false
end



function RideProxy.HasSelectMaterial()
    return feedMaterials and table.getCount(feedMaterials) > 0
end

-- 第一个是添加等级 第二个 经验分子 第三个是经验分母
function RideProxy.GetExpAndLevel()
    if (feedMaterials == nil) then return 0, 0, 0 end
    local level = 0
    local allexp = 0
    local exp = 0
    local maxExp = 0
    local config
    local _RideManager = RideManager
    -- for k, v in feedMaterials do
    for k, v in pairs(feedMaterials) do
        config = _RideManager.GetRideFeedExpConfigById(v.id)
        allexp = allexp + config.feed_exp * v.am
    end

    local data = _RideManager.GetFeedData()
    local curExp = data.curExp
    local maxExp = data.maxExp
    while (allexp + curExp >= maxExp) do

        allexp = allexp -(maxExp - curExp)
        curExp = 0
        local feedConfig = _RideManager.GetRideFeedConfigByLevel(data.lev + level+1)
        if (feedConfig) then
            maxExp = feedConfig.feed_exp;
            level = level + 1
            
        else
            allexp = maxExp
            break
        end
    end


    return level, allexp, maxExp;
end 