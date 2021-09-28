require "Core.Module.Pattern.Proxy";
require "net/CmdType";
require "net/SocketClientLua";
require "Core.Info.MailInfo";


MailProxy = Proxy:New();
function MailProxy:OnRegister()
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Mail_New, MailProxy._RspMailNew);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Mail_List, MailProxy._RspMailList);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Mail_Read, MailProxy._RspMailRead);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Mail_Pick, MailProxy._RspMailPick);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Mail_Del, MailProxy._RspMailDel);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Mail_AllPick, MailProxy._RspMailAllPick);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Mail_AllDel, MailProxy._RspMailAllDel);
end

function MailProxy:OnRemove()
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Mail_New, MailProxy._RspMailNew);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Mail_List, MailProxy._RspMailList);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Mail_Read, MailProxy._RspMailRead);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Mail_Pick, MailProxy._RspMailPick);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Mail_Del, MailProxy._RspMailDel);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Mail_AllPick, MailProxy._RspMailAllPick);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Mail_AllDel, MailProxy._RspMailAllDel);
end

-- 新邮件
function MailProxy._RspMailNew(cmd, data)
    MailManager.SetRedPoint(true);
    MessageManager.Dispatch(MailManager, MailNotes.MAIL_UPDATE_NEW);
end

-- 获取邮件列表
function MailProxy._RspMailList(cmd, data)
    local tmp = { };
    if (data ~= nil and data.errCode == nil) then
        local list = data["l"];
        local i = 1;
        for k, v in pairs(list) do
            tmp[i] = MailInfo:New(v);
            i = i + 1;
        end

        MailManager.SetData(tmp);
    end
end

-- 读取邮件
function MailProxy._RspMailRead(cmd, data)
    if (data ~= nil and data.errCode == nil) then
        local tmp = { };
        table.copyTo(data, tmp);

        for i = 1, #tmp.ah do
            local o = ProductInfo:New();
            o:Init(tmp.ah[i]);
            tmp.ah[i] = o;
        end

        MailManager.SetDetail(tmp);
    end
end

-- 收取邮件附件
function MailProxy._RspMailPick(cmd, data)
    if (data ~= nil) then
        if (data.errCode == nil) then
            MailManager.SetMailPicked({data.id});
        else
--            --ModuleManager.SendNotification(ConfirmNotes.OPEN_CONFIRM2PANEL, {title = "提示", msg = "[ff0000]"..data.errMsg.."[-]"});
--            MsgUtils.ShowTips(nil, nil, nil, data.errMsg);

        end
    end
end

-- 删除邮件
function MailProxy._RspMailDel(cmd, data)
    if (data ~= nil) then
        if (data.errCode == nil) then
            MailManager.DelMail({data.id});
        end
    end
end

-- 全部收取
function MailProxy._RspMailAllPick(cmd, data)
     if (data ~= nil and data.errCode == nil) then
        local ids = data.ids;
        MailManager.SetMailPicked(ids);
        --[[
        local isFull = false;
        for i,info in ipairs(MailManager.GetMailList()) do
            if info.status ~= 2 and info.annex > 0 then
                isFull = true;
                break;
            end
        end

        if isFull then
            MsgUtils.ShowTips(nil, nil, nil, "背包装不下了");
        end
        ]]
     end
end

-- 全部删除
function MailProxy._RspMailAllDel(cmd, data)
    if (data ~= nil and data.errCode == nil) then
        local ids = data.ids;
        MailManager.DelMail(ids);      
     end
end

function MailProxy.ReqMailList()
    SocketClientLua.Get_ins():SendMessage(CmdType.Mail_List);
end

function MailProxy.ReqMailRead(mid)
    return SocketClientLua.Get_ins():SendMessage(CmdType.Mail_Read, { id = mid });
end

function MailProxy.ReqMailPick(mid)
    SocketClientLua.Get_ins():SendMessage(CmdType.Mail_Pick, { id = mid });
end

function MailProxy.ReqMailDel(mid)
    SocketClientLua.Get_ins():SendMessage(CmdType.Mail_Del, { id = mid });
end

function MailProxy.ReqMailAllPick()
    SocketClientLua.Get_ins():SendMessage(CmdType.Mail_AllPick);
end

function MailProxy.ReqMailAllDel()
    SocketClientLua.Get_ins():SendMessage(CmdType.Mail_AllDel);
end