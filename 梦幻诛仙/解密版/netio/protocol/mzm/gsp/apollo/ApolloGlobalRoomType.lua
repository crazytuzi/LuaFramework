local OctetsStream = require("netio.OctetsStream")
local ApolloGlobalRoomType = class("ApolloGlobalRoomType")
ApolloGlobalRoomType.AGRT_DEFAULT = 1
function ApolloGlobalRoomType:ctor()
end
function ApolloGlobalRoomType:marshal(os)
end
function ApolloGlobalRoomType:unmarshal(os)
end
return ApolloGlobalRoomType
