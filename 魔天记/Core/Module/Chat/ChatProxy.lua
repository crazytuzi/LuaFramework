require "Core.Module.Pattern.Proxy"

ChatProxy = Proxy:New();
ChatProxy.channel = nil
ChatProxy.InputText = ""
ChatProxy.worldShow = {ChatChannel.world}--世界聊天显示频道
ChatProxy.cdTimeDefault = 1
ChatProxy.cdTimeWorld = 30
ChatProxy.cdTime = {}
function ChatProxy:OnRegister()
    --local socket = SocketClientLua.Get_ins()
    --socket:AddDataPacketListener(CmdType.Chat_ReceiveMsg, ChatProxy.ReceiveMsg);
    --    socket:AddDataPacketListener(CmdType.Chat_SendWorld, ChatProxy.SendWorld);
    --    socket:AddDataPacketListener(CmdType.Chat_SendSchool, ChatProxy.SendSchool);
    --    socket:AddDataPacketListener(CmdType.Chat_SendTeam, ChatProxy.SendTeam);
    --    socket:AddDataPacketListener(CmdType.Chat_SendPrivate, ChatProxy.SendPrivate);
    --    socket:AddDataPacketListener(CmdType.Chat_HistroyMsg, ChatProxy.HistroyMsg);
end
function ChatProxy.ReceiveMsg(cmd,data)
    ChatManager.ReceiveMsg(data)
end
function ChatProxy.SendMsg(text)
    if text == ChatProxy.InputText then return end
    local c = tostring(ChatProxy.channel)
    --print(c,"----" , tostring(ChatProxy.cdTime[c]), LanguageMgr.Get("ChatPorxy/cdTime"))
    if ChatProxy.cdTime[c] ~= nil then
        local lt = ChatProxy.cdTime[c]:GetRemainTime()
        MsgUtils.ShowTips(nil, nil, nil, math.ceil(lt) .. LanguageMgr.Get("ChatPorxy/cdTime"));
        return 
    end
    local suf = ChatManager.SendMsg(ChatProxy.channel,text)
    if not suf then return end
    ChatProxy.AddMyHistroy(text)
    ChatProxy.cdTime[c] = Timer.New(function()
        ChatProxy.cdTime[c] = nil
        --logTrace("333" .. tostring(ChatProxy.cdTime[c]))
    end, ChatProxy.channel == ChatChannel.world and ChatProxy.cdTimeWorld or ChatProxy.cdTimeDefault, 1, false)
    --logTrace(c == ChatChannel.world and ChatProxy.cdTimeWorld or ChatProxy.cdTimeDefault)
    ChatProxy.cdTime[c]:Start()
end
--function ChatProxy.SendSchool()
--end
--function ChatProxy.SendTeam()
--end
--function ChatProxy.SendPrivate()
--end
--function ChatProxy.HistroyMsg()
--end
function ChatProxy:OnRemove()
    --local socket = SocketClientLua.Get_ins()
    --socket:RemoveDataPacketListener(CmdType.Chat_ReceiveMsg, ChatProxy.ReceiveMsg);
    --    socket:RemoveDataPacketListener(CmdType.Chat_SendWorld, ChatProxy.SendWorld);
    --    socket:RemoveDataPacketListener(CmdType.Chat_SendSchool, ChatProxy.SendSchool);
    --    socket:RemoveDataPacketListener(CmdType.Chat_SendTeam, ChatProxy.SendTeam);
    --    socket:RemoveDataPacketListener(CmdType.Chat_SendPrivate, ChatProxy.SendPrivate);
    --    socket:RemoveDataPacketListener(CmdType.Chat_HistroyMsg, ChatProxy.HistroyMsg);
end

ChatProxy._Myhistroy = {}
ChatProxy.MyhistroyKey = "mtj_chat_MyhistroyKey"
ChatProxy.MyhistroyKeySplit = "~&~"
local insert = table.insert

function ChatProxy.GetMyHistroy()
    --Util.RemoveData(ChatProxy.MyhistroyKey)
    local settings = Util.GetString(ChatProxy.MyhistroyKey)
    --logTrace("settings=" .. tostring(settings))
    if settings ~= nil and string.len(settings) > 0 then
        ChatProxy._Myhistroy = string.split(settings, ChatProxy.MyhistroyKeySplit)
    end
    --for k,v in pairs(ChatProxy._Myhistroy) do logTrace(tostring(k)  .. "==" ..  tostring(v)) end
    return ChatProxy._Myhistroy
end
function ChatProxy.AddMyHistroy(text)
    --if string.len(text) > 15 then text = string.sub(text,0,15) end
    for k,v in pairs(ChatProxy._Myhistroy) do if v == text then
        table.remove(ChatProxy._Myhistroy, k)
    end end
    if #ChatProxy._Myhistroy == 5 then table.remove(ChatProxy._Myhistroy) end
    insert(ChatProxy._Myhistroy, 1, text)
    local strs = { }
    for k, v in pairs(ChatProxy._Myhistroy) do insert(strs, v) end
    --for k,v in pairs(ChatProxy._Myhistroy) do logTrace(tostring(k)  .. "_" ..  tostring(v)) end
    strs = table.concat(strs, ChatProxy.MyhistroyKeySplit)
    Util.SetString(ChatProxy.MyhistroyKey, strs)
end


function ChatProxy.GetNameColor(channel,txt)
    if channel == ChatChannel.world then
        return "[d7dadc]" .. txt .. "[-]";
    elseif channel == ChatChannel.team then
        return "[85c55e]" .. txt .. "[-]";
    elseif channel == ChatChannel.school then
        return "[4087df]" .. txt .. "[-]";
    elseif channel == ChatChannel.active then
        return "[b168f5]" .. txt .. "[-]";
    elseif channel == ChatChannel.system then
        return "[e69e57]" .. txt .. "[-]";
    end
end
