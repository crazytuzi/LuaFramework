require "Core.Module.Pattern.Proxy"
require "net/SocketClientLua"
require "net/CmdType"

local insert = table.insert
MessageProxy = Proxy:New();

function MessageProxy:OnRegister()
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Message_Marquee, MessageProxy._RspMarquee);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Message_Notice, MessageProxy._RspNotice);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Message_Tips, MessageProxy._RspTips);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Message_Props, MessageProxy._RspProps);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Message_Trumpet, MessageProxy._RspTrumpet);
    
end

function MessageProxy:OnRemove()
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Message_Marquee, MessageProxy._RspMarquee);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Message_Notice, MessageProxy._RspNotice);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Message_Tips, MessageProxy._RspTips);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Message_Props, MessageProxy._RspProps);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Message_Trumpet, MessageProxy._RspTrumpet);
end


function MessageProxy._RspMarquee(cmd, data)
    local p = nil;
    if data.pl then
        p = MsgUtils.ArrayToParam(data.pl);
    end
    if data.id > 0 then
        MessageProxy.ToChatSys(data.id, p);
        MsgUtils.ShowMarquee(data.id, p);
    else
        --后端指定内容的跑马灯
        ChatManager.SystemMsg(data.msg, ChatTag.system);
        MsgUtils.ShowMarquee(0, p, data.msg);
    end
end

function MessageProxy._RspNotice(cmd, data)
    local p = MsgUtils.ArrayToParam(data.pl);
    MessageProxy.ToChatSys(data.id, p);
	MsgUtils.ShowNotice(data.id, p);
end

function MessageProxy._RspTips(cmd, data)
	MsgUtils.ShowTips(nil, nil, nil, data.msg); 
    ChatManager.SystemMsg(data.msg, ChatTag.system);
end

function MessageProxy._RspProps(cmd, data)
--	local arr1 = {};
    local arr2 = {};
    --local add = PlayerManager.GetExpAdd()
	for i, v in ipairs(data.l) do
		--local o = ProductInfo:New();
    	--o:Init({spId = v.spId, am = v.am});	
        if v.spId ~= 4 then
--            local d = {spId = v.spId, am = v.am}
--            if add > 100 then d.add = add end
--            insert(arr1, d);
--        elseif v.spId == 1 then
--            insert(arr1, {spId = v.spId, am = v.am});
--        else
            insert(arr2, {spId = v.spId, am = v.am});
        end
	end
    
--	if #arr1 > 0 then
--        MsgUtils.ShowProps(arr1, "message/prop/1");
--    end
    
    if #arr2 > 0 then
        for i, v in ipairs(arr2) do
            if v.am > 1 then
                MsgUtils.ShowTips("message/prop/1", v, nil, nil, "");
            else
                MsgUtils.ShowTips("message/prop/0", v, nil, nil, "");
            end
        end
    end

end

function MessageProxy._RspTrumpet(cmd, data)
    local p = MsgUtils.ArrayToParam(data.pl);
    MessageProxy.ToChatSys(data.id, p);
    MsgUtils.ShowTrumpet(data.id, p);
end

--取带链接的字符串给聊天系统
function MessageProxy.ToChatSys(id, p)
    local cfg = MsgUtils.GetMsgCfgById(id);
    local msg = LanguageMgr.ApplyFormat(cfg and cfg.msgStr or "", p, true);
    ChatManager.SystemMsg(msg, cfg.label);
end

function MessageProxy.HasOffLineItem()
    local item = BackpackDataManager.GetProductBySpid(500116);
    item = item or BackpackDataManager.GetProductBySpid(500112);
    return item and item.am > 0;
end

function MessageProxy.AddOffLineTIme()
    local item = BackpackDataManager.GetProductBySpid(500116);
    item = item or BackpackDataManager.GetProductBySpid(500112);
    --local num = BackpackDataManager.GetProductTotalNumBySpid(500112);

    if item and item.am > 0 then
        ProductTipProxy.TryUseProduct(item, 1)
    else
        ModuleManager.SendNotification(MessageNotes.CLOSE_OFFLINE_PANEL);
        ModuleManager.SendNotification(ActivityNotes.CLOSE_ACTIVITY);

        storeConfig = MallManager.GetStoreById(106);
        ModuleManager.SendNotification(MallNotes.OPEN_MALLPANEL, { val = 1, other = storeConfig })
    end
end

