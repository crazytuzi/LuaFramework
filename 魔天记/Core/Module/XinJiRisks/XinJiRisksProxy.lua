require "Core.Module.Pattern.Proxy"


XinJiRisksProxy = Proxy:New();




function XinJiRisksProxy:OnRegister()
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.XinJiRisksGetCurrState, XinJiRisksProxy.XinJiRisksGetCurrStateHandler);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.XinJiRisksRecState, XinJiRisksProxy.XinJiRisksRecStateHandler);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.XinJiRisksAnswer, XinJiRisksProxy.XinJiRisksAnswerHandler);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.XinJiRisksRecServerNotice, XinJiRisksProxy.XinJiRisksRecServerNoticeHandler);
end

function XinJiRisksProxy:OnRemove()

    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.XinJiRisksGetCurrState, XinJiRisksProxy.XinJiRisksGetCurrStateHandler);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.XinJiRisksRecState, XinJiRisksProxy.XinJiRisksRecStateHandler);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.XinJiRisksAnswer, XinJiRisksProxy.XinJiRisksAnswerHandler);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.XinJiRisksRecServerNotice, XinJiRisksProxy.XinJiRisksRecServerNoticeHandler);


end

--  MessageManager.Dispatch(WorldBossNotes, WorldBossNotes.EVENT_BOSSINFOS, data);

function XinJiRisksProxy.XinJiRisksGetCurrStateHandler(cmd, data)
    if data and data.errCode == nil then
        MessageManager.Dispatch(XinJiRisksNotes, XinJiRisksNotes.MESSAGE_XINJIRISKSGETCURRSTATE_CHANGE, data);
    end
end

function XinJiRisksProxy.XinJiRisksRecStateHandler(cmd, data)
    if data and data.errCode == nil then
        MessageManager.Dispatch(XinJiRisksNotes, XinJiRisksNotes.MESSAGE_XINJIRISKSGETCURRSTATE_CHANGE, data);
    end
end

function XinJiRisksProxy.XinJiRisksAnswerHandler(cmd, data)
    if data and data.errCode == nil then
     XinJiRisksProxy.myAnswer = data.a;
        MessageManager.Dispatch(XinJiRisksNotes, XinJiRisksNotes.MESSAGE_MY_ANSWER_SUCCESS, data);
    end
end

function XinJiRisksProxy.XinJiRisksRecServerNoticeHandler(cmd, data)
    if data and data.errCode == nil then
        MessageManager.Dispatch(XinJiRisksNotes, XinJiRisksNotes.MESSAGE_SERVER_GIVE_NOTICE, data);
    end
end


function XinJiRisksProxy.Try_XinJiRisksGetCurrState()
    SocketClientLua.Get_ins():SendMessage(CmdType.XinJiRisksGetCurrState, { });
end

-- a：回答答案1-4
function XinJiRisksProxy.Try_XinJiRisksAnswer(a)
    SocketClientLua.Get_ins():SendMessage(CmdType.XinJiRisksAnswer, { a = a });
end
