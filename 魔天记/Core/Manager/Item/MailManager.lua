require "Core.Module.Mail.MailNotes";
require "Core.Module.Mail.MailProxy";

MailManager = { };

local _mailList = { };
local _dict = { };
local _sortfunc = table.sort
local _redPoint = false; 

function MailManager.SetData(data)
    if data == nil then
        data = { };
    else
        _dict = {};
        for i, v in ipairs(data) do
            _dict[v.id] = v;
        end
    end
    _mailList = data;
    MailManager._Sort();
    MailManager.UpdateRedPoint();
    MailManager.PostListEvent();
end

function MailManager.UpdateRedPoint()
    _redPoint = false;
    for k, v in pairs(_dict) do
        if v.status == 0 then
            _redPoint = true;
            break;
        end
    end
end

function MailManager._Sort()
    _sortfunc(_mailList,
        function(a, b)
            if (a.time > b.time) then
                return true;
            elseif(a.time == b.time) then
                return a.id > b.id;
            else 
                return false;
            end
        end
    );
end

function MailManager.SetDetail(data)
    local info = MailManager.GetInfoById(data.id);
    if (info ~= nil and info.status == 0) then
        info.status = 1;
        MailManager.UpdateRedPoint();
        MailManager.PostListEvent();
    end
    MessageManager.Dispatch(MailManager, MailNotes.MAIL_UPDATE_DETAIL, data);
end


function MailManager.PostListEvent()
    MessageManager.Dispatch(MailManager, MailNotes.MAIL_UPDATE_LIST);
end

function MailManager.GetInfoById(id)
    return _dict[id];
end 

function MailManager.GetMailList()
    return _mailList;
end

function MailManager.GetMailCount()
    return #_mailList;
end

function MailManager.SetMailPicked(ids)
    for i, v in ipairs(ids) do
        local info = MailManager.GetInfoById(v);
        if info then
            info.status = 2;
        end
    end
    MailManager.UpdateRedPoint();
    MailManager.PostListEvent();
    MessageManager.Dispatch(MailManager, MailNotes.RSP_MAIL_PICK, ids);
end

function MailManager.DelMail(ids)
    for i = 1, table.getn(ids) do
        local id = ids[i];
        local info = MailManager.GetInfoById(id);
        if(info~= nil) then 
            _dict[id] = nil;
            RemoveTableItem(_mailList, info, false);
        end
    end
    MailManager.UpdateRedPoint();
    MailManager.PostListEvent();
end

--红点:是否有未读邮件
function MailManager.GetRedPoint() 
    return _redPoint;
end

function MailManager.SetRedPoint(v)
    _redPoint = v;
end


