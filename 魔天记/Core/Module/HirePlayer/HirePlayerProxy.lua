require "Core.Module.Pattern.Proxy"

HirePlayerProxy = Proxy:New();
function HirePlayerProxy:OnRegister()
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.HireList, HirePlayerProxy._OnDataHandler, self);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.HirePlayer, HirePlayerProxy._OnHirePlayerHandler, self);
end

function HirePlayerProxy:OnRemove()
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.HireList, HirePlayerProxy._OnDataHandler, self);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.HirePlayer, HirePlayerProxy._OnHirePlayerHandler, self);
end

function HirePlayerProxy:_OnDataHandler(cmd, data)    
    if data and data.errCode == nil then
        --if (data.rc > 0) then 
            ModuleManager.SendNotification(HirePlayerNotes.OPEN_HIREPLAYERPANEL,data)
        --else
        --    MsgUtils.ShowTips(nil, nil, nil, LanguageMgr.Get("HirePlayerPanel/tip1"));
        --end
    end    
end

function HirePlayerProxy:_OnHirePlayerHandler(cmd, data)    
    if data and data.errCode == nil then
        ModuleManager.SendNotification(HirePlayerNotes.CLOSE_HIREPLAYERPANEL)
        ModuleManager.SendNotification(FriendNotes.CLOSE_FRIENDPANEL)
        ModuleManager.SendNotification(LSInstanceNotes.CLOSE_LSINSTANCEPANEL);
        ModuleManager.SendNotification(ActivityNotes.CLOSE_ACTIVITY);
        GameSceneManager.GoToFB(HirePlayerProxy._mapData)
        HirePlayerProxy._mapData = nil;
    end    
end

function HirePlayerProxy.LoadDataByInstanceId(mapData)
    HirePlayerProxy._mapData = mapData
    if (mapData) then
        SocketClientLua.Get_ins():SendMessage(CmdType.HireList,{});
    end
end

function HirePlayerProxy.HirePlayer(list)
    if (list) then
        SocketClientLua.Get_ins():SendMessage(CmdType.HirePlayer,{pl = list});
    end
end