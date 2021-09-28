require "Core.Module.Pattern.Proxy"

XLTInstanceProxy = Proxy:New();

XLTInstanceProxy.MESSAGE_SAO_DANG_INFOCHANGE = "MESSAGE_SAO_DANG_INFOCHANGE";

XLTInstanceProxy.MESSAGE_SAO_DANG_PROINFOCHANGE = "MESSAGE_SAO_DANG_PROINFOCHANGE";

XLTInstanceProxy.MESSAGE_CHUANGGUAN_AWARDLOG = "MESSAGE_CHUANGGUAN_AWARDLOG";

XLTInstanceProxy.MESSAGE_NEED_UP_INSTREDS = "MESSAGE_NEED_UP_INSTREDS";

function XLTInstanceProxy:OnRegister()

    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.XLTReSetTiaoZhanTime, XLTInstanceProxy.XLTReSetTiaoZhanTimeResult);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.XLTReSetSaoDangTime, XLTInstanceProxy.XLTReSetSaoDangTimeResult);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.TryGetChuangGuanAward, XLTInstanceProxy.TryGetChuangGuanAwardResult);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GetChuangGuanAwardLog, XLTInstanceProxy.GetChuangGuanAwardLogResult);

    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.TryGetXLTSaoDangAwards, XLTInstanceProxy.TryGetXLTSaoDangAwardsResult);

    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GetXLTSaoDangProsInfo, XLTInstanceProxy.GetXLTSaoDangProsInfoResult);

    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.TryXLTSaoDang, XLTInstanceProxy.TryXLTSaoDangResult);

    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GetXLTSaoDangInfo, XLTInstanceProxy.GetXLTSaoDangInfoResult);
end

function XLTInstanceProxy:OnRemove()

    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.XLTReSetTiaoZhanTime, XLTInstanceProxy.XLTReSetTiaoZhanTimeResult);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.XLTReSetSaoDangTime, XLTInstanceProxy.XLTReSetSaoDangTimeResult);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.TryGetChuangGuanAward, XLTInstanceProxy.TryGetChuangGuanAwardResult);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GetChuangGuanAwardLog, XLTInstanceProxy.GetChuangGuanAwardLogResult);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.TryGetXLTSaoDangAwards, XLTInstanceProxy.TryGetXLTSaoDangAwardsResult);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GetXLTSaoDangProsInfo, XLTInstanceProxy.GetXLTSaoDangProsInfoResult);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.TryXLTSaoDang, XLTInstanceProxy.TryXLTSaoDangResult);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GetXLTSaoDangInfo, XLTInstanceProxy.GetXLTSaoDangInfoResult);


end

function XLTInstanceProxy.XLTReSetTaoZhanTime(fid)

    SocketClientLua.Get_ins():SendMessage(CmdType.XLTReSetTiaoZhanTime, { id = fid .. "" });
end


function XLTInstanceProxy.XLTReSetTiaoZhanTimeResult(cmd, data)

    if (data.errCode == nil) then
        InstanceDataManager.UpData();
        MessageManager.Dispatch(XLTInstanceProxy, XLTInstanceProxy.MESSAGE_NEED_UP_INSTREDS);
    end
end

function XLTInstanceProxy.XLTReSetSaoDangTimeResult(cmd, data)

    if (data.errCode == nil) then

        MessageManager.Dispatch(XLTInstanceProxy, XLTInstanceProxy.MESSAGE_NEED_UP_INSTREDS);
    end
end

----------------------------------------------------------------------------------------------------------------------

function XLTInstanceProxy.XLTReSetSaoDangTime(fid)

    SocketClientLua.Get_ins():SendMessage(CmdType.XLTReSetSaoDangTime, { id = fid .. "" });
end


function XLTInstanceProxy.XLTReSetSaoDangTimeResult(cmd, data)

    if (data.errCode == nil) then
        MessageManager.Dispatch(XLTInstanceProxy, XLTInstanceProxy.MESSAGE_NEED_UP_INSTREDS);
    end
end





function XLTInstanceProxy.TryGetChuangGuanAward(id)

    SocketClientLua.Get_ins():SendMessage(CmdType.TryGetChuangGuanAward, { id = id .. "" });
end

--[[
0E 获取第一次副本通过奖励
输入：
id：副本ID
输出：
items:[(spId,num)....]
0x0F0E
C
]]
function XLTInstanceProxy.TryGetChuangGuanAwardResult(cmd, data)

    if (data.errCode == nil) then
        --  S <-- 10:32:35.318, 0x0F0F, 17, {"l":{"l":[]}}
        local items = data.items;
        XLTInstanceProxy.GetChuangGuanAwardLog();
    end
end


------------------------------------------------------------------
XLTInstanceProxy.GetIngChuangGuanAwardLog = false;
function XLTInstanceProxy.GetChuangGuanAwardLog()

    if not XLTInstanceProxy.GetIngChuangGuanAwardLog then

        SocketClientLua.Get_ins():SendMessage(CmdType.GetChuangGuanAwardLog, { });

        XLTInstanceProxy.GetIngChuangGuanAwardLog = true;

    else

    end


end

function XLTInstanceProxy.__IsHasGetAward(l, fb_id)
    local lenj = table.getn(l);
    for j = 1, lenj do
        local obj = l[j];
        if tonumber(obj.id) == tonumber(fb_id) then
          if obj.flag == 1  then
            return true;
          end 
        end 
    end
     return false;
end


function XLTInstanceProxy.CheckCanGetXMLChuangAward(l)


    --------  需要判断是否有可以 领取的奖励
    local awardList = InstanceDataManager:GetXLTFirstAwardArr();
    local len = table.getn(awardList);

    for i = 1, len do
        local fbcf = awardList[i];
       
        if fbcf.id <= FBMLTItem.hasPassMaxFb_id then
            local res = XLTInstanceProxy.__IsHasGetAward(l, fbcf.id);
          
            -- 应 到达 可以 奖励 的情况
            if not res then
                return true;
            end

        end
    end
    return false;
end

--[[
0F 获取虚灵塔第一次通过奖励记录

输入：
输出：
l:[id:副本ID，flag：是否领取 0未领取，1：领取）
0x0F0C
]]
function XLTInstanceProxy.GetChuangGuanAwardLogResult(cmd, data)

    if (data.errCode == nil) then
        --  S <-- 10:32:35.318, 0x0F0F, 17, {"l":{"l":[]}}

        data.canGetAward = XLTInstanceProxy.CheckCanGetXMLChuangAward(data.l);
        XLTInstanceProxy.chuangGuanAwardLog = data;
        MessageManager.Dispatch(XLTInstanceProxy, XLTInstanceProxy.MESSAGE_CHUANGGUAN_AWARDLOG, data);
    end

    XLTInstanceProxy.GetIngChuangGuanAwardLog = false;
end


-------------------------------------------------------------------------------------------------

function XLTInstanceProxy.TryGetXLTSaoDangAwards()


    SocketClientLua.Get_ins():SendMessage(CmdType.TryGetXLTSaoDangAwards, { });

end

function XLTInstanceProxy.TryGetXLTSaoDangAwardsResult(cmd, data)


    if (data.errCode == nil) then
        ModuleManager.SendNotification(XLTInstanceNotes.CLOSE_XLTSAODANGAWARDPANEL);

        -- 需要更新按钮
        MessageManager.Dispatch(XLTInstanceProxy, XLTInstanceProxy.MESSAGE_SAO_DANG_INFOCHANGE, { t = - 1 });

        MsgUtils.ShowTips("XLTInstance/XLTInstanceProxy/label1");

        MessageManager.Dispatch(XLTInstanceProxy, XLTInstanceProxy.MESSAGE_NEED_UP_INSTREDS);
    end

end


-----------------------------------------------------------------------
function XLTInstanceProxy.GetXLTSaoDangProsInfo()


    SocketClientLua.Get_ins():SendMessage(CmdType.GetXLTSaoDangProsInfo, { });

end

--[[
 S <-- 18:09:55.488, 0x0F14, 17, {"items":[{"num":1,"spId":408005},{"num":1,"spId":402005}]}
]]
function XLTInstanceProxy.GetXLTSaoDangProsInfoResult(cmd, data)


    if (data.errCode == nil) then

        local items = data.items;
        MessageManager.Dispatch(XLTInstanceProxy, XLTInstanceProxy.MESSAGE_SAO_DANG_PROINFOCHANGE, items);


    end

end


function XLTInstanceProxy.TryXLTSaoDang(fb_id)


    SocketClientLua.Get_ins():SendMessage(CmdType.TryXLTSaoDang, { });

end

--[[
10 虚灵塔副本扫荡
输出：
t:剩余时间
0x0F10


]]
function XLTInstanceProxy.TryXLTSaoDangResult(cmd, data)


    if (data.errCode == nil) then

        -- t:剩余时间（-1：标示没有进行扫荡，0：可以领取奖励，大于1：扫荡剩余时间）
        MessageManager.Dispatch(XLTInstanceProxy, XLTInstanceProxy.MESSAGE_SAO_DANG_INFOCHANGE, data);

    end

end



function XLTInstanceProxy.TryGetXLTSaoDangInfo()

    SocketClientLua.Get_ins():SendMessage(CmdType.GetXLTSaoDangInfo, { });

end

function XLTInstanceProxy.GetXLTSaoDangInfoResult(cmd, data)


    if (data.errCode == nil) then

        -- t:剩余时间（-1：标示没有进行扫荡，0：可以领取奖励，大于1：扫荡剩余时间）

        MessageManager.Dispatch(XLTInstanceProxy, XLTInstanceProxy.MESSAGE_SAO_DANG_INFOCHANGE, data);


    end

end

