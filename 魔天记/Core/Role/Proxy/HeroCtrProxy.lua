
HeroCtrProxy = { };

HeroCtrProxy.MESSAGE_USEMOUNT_SUCCESS = "MESSAGE_USEMOUNT_SUCCESS";

-- 正在请求上载具的 信息
HeroCtrProxy.OnIngMount_id = nil;


function HeroCtrProxy.TryUseMount(mount_id)

    HeroCtrProxy.OnIngMount_id = mount_id;

    SocketClientLua.Get_ins():SendMessage(CmdType.UseMount, { mid = mount_id });

end

function HeroCtrProxy.UseMountResult(cmd, data)


    if (data.errCode == nil) then
        MessageManager.Dispatch(HeroCtrProxy, HeroCtrProxy.MESSAGE_USEMOUNT_SUCCESS, data);

        MessageManager.Dispatch(NewTrumpManager, NewTrumpManager.SelfTrumpFollow);

    end

    HeroCtrProxy.OnIngMount_id = nil;
end

--[[
获取正在请求 上的载具 id
]]
function HeroCtrProxy.IsOnIngMountId()
    return HeroCtrProxy.OnIngMount_id;
end

function HeroCtrProxy.TryUnUseMount()

    SocketClientLua.Get_ins():SendMessage(CmdType.UnUseMount, { });

end


function HeroCtrProxy.AddLister()
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.UnUseMount, HeroCtrProxy.UnUseMountResult);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.UseMount, HeroCtrProxy.UseMountResult);
end


function HeroCtrProxy.RemoveLister()

    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.UseMount, HeroCtrProxy.UseMountResult);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.UnUseMount, HeroCtrProxy.UnUseMountResult);

end

--[[
收到 服务器 的 下载具 通知
]]
function HeroCtrProxy.UnUseMountResult(cmd, data)

    if (data.errCode == nil) then

        local mid = data.mid;
        local mount_config = ConfigManager.GetMount(mid);
        local ins = HeroController.GetInstance();

        if mount_config.type == MountManager.TYPE_F_MOUNT then
            local fmt = ins:Get_mountController();
            if fmt ~= nil then
                fmt:Stop(true);
            end

        elseif mount_config.type == MountManager.TYPE_L_MOUNT then

            local mt = ins:Get_mountLangController();
            if mt ~= nil then
                mt:Stop(true);
            end
            MessageManager.Dispatch(NewTrumpManager, NewTrumpManager.SelfTrumpFollow);
        end





    end

end

HeroCtrProxy.HeroAutoFightState = nil;
function HeroCtrProxy.SetHeroAutoFightState(f)

    if HeroCtrProxy.HeroAutoFightState ~= f then
        SocketClientLua.Get_ins():SendMessage(CmdType.HeroAutoFightState, { f = f });
        HeroCtrProxy.HeroAutoFightState = f;
    end

end