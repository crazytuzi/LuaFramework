require "Core.Module.Pattern.Proxy"
require "net/SocketClientLua"
require "net/CmdType"

require "Core.Manager.Item.FriendDataManager"

AddFriendsProxy = Proxy:New();
function AddFriendsProxy:OnRegister()
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.AddFriend, AddFriendsProxy.AddFriend_Result);
     SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GetTJFriendList, AddFriendsProxy.GetTJFriendList_Result);
      SocketClientLua.Get_ins():AddDataPacketListener(CmdType.FindFriend, AddFriendsProxy.FindFriend_Result);
end

function AddFriendsProxy:OnRemove()
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.AddFriend, AddFriendsProxy.AddFriend_Result);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GetTJFriendList, AddFriendsProxy.GetTJFriendList_Result);
     SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.FindFriend, AddFriendsProxy.FindFriend_Result);

end



function AddFriendsProxy.TryAddFriend(id, target)

    AddFriendsProxy.addFriend_target = target;

    SocketClientLua.Get_ins():SendMessage(CmdType.AddFriend, { id = id .. "" });
end

function AddFriendsProxy.AddFriend_Result(cmd, data)

    if data.errCode == nil then

        FriendDataManager.SetFriend(data);

        if data.type == FriendDataManager.type_friend then

            MsgUtils.ShowTips("AddFriends/AddFriendsProxy/label1", { n = data.name });

        elseif data.type == FriendDataManager.type_enemy then

         MsgUtils.ShowTips("AddFriends/AddFriendsProxy/label3", { n = data.name });

        end



        if AddFriendsProxy.addFriend_target ~= nil then
            AddFriendsProxy.addFriend_target:AddFriendSuccessResult();
        end
        AddFriendsProxy.addFriend_target = nil;

    end
end

--[[
function AddFriendsProxy.TryAddFriends(ids)

    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.AddFriends, AddFriendsProxy.AddFriends_Result);
    SocketClientLua.Get_ins():SendMessage(CmdType.AddFriends, { ids = ids });
end


function AddFriendsProxy.AddFriends_Result(cmd, data)
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.AddFriends, AddFriendsProxy.AddFriends_Result);

    if data.errCode == nil then

        local list = data.l;
        local t_num = table.getn(list);
        for i = 1, t_num do
            FriendDataManager.SetFriend(list[i]);
        end

        MsgUtils.ShowTips("AddFriends/AddFriendsProxy/label2");

    end
end
]]

function AddFriendsProxy.TryGetTJFriendList()
   
    SocketClientLua.Get_ins():SendMessage(CmdType.GetTJFriendList, { });
end

function AddFriendsProxy.GetTJFriendList_Result(cmd, data)
    
    if data.errCode == nil then
        local l = data.l;
        MessageManager.Dispatch(AddFriendsNotes, AddFriendsNotes.MESSAGE_FRIENDLIST_UPDATA, l);
    end
end


function AddFriendsProxy.TryFindFriend(name)
   
    SocketClientLua.Get_ins():SendMessage(CmdType.FindFriend, { name = name });
end

function AddFriendsProxy.FindFriend_Result(cmd, data)
   
    if data.errCode == nil then
        local l = data.l;
        MessageManager.Dispatch(AddFriendsNotes, AddFriendsNotes.MESSAGE_FRIENDLIST_UPDATA, l);
    end
end