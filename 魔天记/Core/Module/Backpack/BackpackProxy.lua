require "Core.Module.Pattern.Proxy"
require "net/SocketClientLua"
require "net/CmdType"




BackpackProxy = Proxy:New();

BackpackProxy.MESSAGE_CD_BOXIDX_CHANGE = "MESSAGE_CD_BOXIDX_CHANGE";
BackpackProxy.MESSAGE_UNLOCK_BOX_NUM_CHANGE = "MESSAGE_UNLOCK_BOX_NUM_CHANGE";

function BackpackProxy:OnRegister()
SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Reset_BackPack, BackpackProxy.ResetPackBack_Result);
 SocketClientLua.Get_ins():AddDataPacketListener(CmdType.UnLockBackPack, BackpackProxy.UnLockBackPack_Result);


end

function BackpackProxy:OnRemove()
SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Reset_BackPack, BackpackProxy.ResetPackBack_Result);
 SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.UnLockBackPack, BackpackProxy.UnLockBackPack_Result);

end

function BackpackProxy.TryResetBackPack()
    
    SocketClientLua.Get_ins():SendMessage(CmdType.Reset_BackPack, { });
end

-- bag：背包 [Item,...]
function BackpackProxy.ResetPackBack_Result(cmd, data)
    if (data.errCode == nil) then
        BackpackDataManager.Reset(data.bag);
        
    end
end

function BackpackProxy.UnLockProudctBox(idx)

    local bag_size = BackpackDataManager._bsize;

    local num = idx - bag_size;

    local gold = 0
    for i = 1, num do
        gold = gold + 2 + math.floor((bag_size - 40 + i) / 4) * 2;
    end

    BackpackProxy.unLockNum = num;

    ModuleManager.SendNotification(ConfirmNotes.OPEN_CONFIRM1PANEL, {
        title = LanguageMgr.Get("backpack/proxy/tipTitle"),
        msg = LanguageMgr.Get("backpack/proxy/unLockProudctBoxTip",{ g = gold, n = num }),
        -- "您确定使用"..gold.."绑定仙玉/仙玉开启"..num.."个背包格？",
        ok_Label = LanguageMgr.Get("backpack/proxy/tip_bt_label_ok"),
        cance_lLabel = LanguageMgr.Get("backpack/proxy/tip_bt_label_cancel"),
        hander = BackpackProxy.UnLockProudctBoxHandler,
        data = nil
    } );
end

function BackpackProxy.UnLockProudctBoxHandler()
    BackpackProxy.unLockByTime = false;
   
    SocketClientLua.Get_ins():SendMessage(CmdType.UnLockBackPack, { type = 1, am = BackpackProxy.unLockNum });
end

--[[
0x0407 解锁背包
输入：
type：解锁类型（1:钻石解锁 2，时间解锁）
am：解锁数量，type=1才有效，缺省为1
输出
size：背包当前大小
bcd:解锁剩余时间（秒）

00:00:00

]]

function BackpackProxy.UnLockProudctBoxByTime()
    BackpackProxy.unLockByTime = true;
  
    SocketClientLua.Get_ins():SendMessage(CmdType.UnLockBackPack, { type = 2, am = 1 });
end

function BackpackProxy.UnLockBackPack_Result(cmd, data)
   
    if data.errCode and data.errCode ~= 0 then
  --  http://192.168.0.8:3000/issues/3222
       -- ModuleManager.SendNotification(ConfirmNotes.OPEN_CONFIRM2PANEL, { title = LanguageMgr.Get("backpack/proxy/tipTitle"), msg = data.errMsg });
    elseif data.errCode == nil then

        local size = data.size;
        local new_size = size - BackpackDataManager.GetBagSize();

        local bcd = data.bcd;
        BackpackDataManager.ResetSize(size);
        BackPackBoxLockCDCtr.Set_bcd(bcd);
        MessageManager.Dispatch(BackpackProxy, BackpackProxy.MESSAGE_CD_BOXIDX_CHANGE);

        MessageManager.Dispatch(BackpackProxy, BackpackProxy.MESSAGE_UNLOCK_BOX_NUM_CHANGE);

        local f = data.f;

        if f ~= nil then

            if f == 1 then

                if BackpackProxy.unLockByTime then
                    local old_size = size - 1;
                    local old_cd = 0;

                    if old_size <= 40 then
                        old_cd = 60;
                    else
                        old_cd =(old_size - 40) * 300;
                    end

                    old_cd = old_cd / 60;
                    old_cd = math.floor(old_cd);

                    MsgUtils.ShowTips("backpack/proxy/unLockProudctBoxsuccesTip1", { t = old_cd, a = new_size * 20 });
                else
                    MsgUtils.ShowTips("backpack/proxy/unLockProudctBoxsuccesTip", { n = new_size, a = new_size * 20 });
                end
                BackpackProxy.unLockByTime = false;


            end

        else
            MsgUtils.ShowTips("backpack/proxy/unLockProudctBoxsuccesTip", { n = new_size, a = new_size * 20 });

        end

    end
end