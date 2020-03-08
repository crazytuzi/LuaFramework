local SEnterCrossCompeteMapFailBrd = class("SEnterCrossCompeteMapFailBrd")
SEnterCrossCompeteMapFailBrd.TYPEID = 12616737
SEnterCrossCompeteMapFailBrd.NO_FACTION = 1
SEnterCrossCompeteMapFailBrd.INVALID_MEMBER = 2
SEnterCrossCompeteMapFailBrd.NO_COMPETE = 3
SEnterCrossCompeteMapFailBrd.INVALID_STAGE = 4
SEnterCrossCompeteMapFailBrd.FORBID_TEAM_STATUS = 5
SEnterCrossCompeteMapFailBrd.ROAM_EXCEPTION = 6
SEnterCrossCompeteMapFailBrd.GEN_TOKEN_FAIL = 11
SEnterCrossCompeteMapFailBrd.ROAM_ROLE_DATA_FAIL = 12
SEnterCrossCompeteMapFailBrd.ROAM_TIMEOUT = 13
SEnterCrossCompeteMapFailBrd.MAKE_CONTEXT = 14
function SEnterCrossCompeteMapFailBrd:ctor(reason)
  self.id = 12616737
  self.reason = reason or nil
end
function SEnterCrossCompeteMapFailBrd:marshal(os)
  os:marshalInt32(self.reason)
end
function SEnterCrossCompeteMapFailBrd:unmarshal(os)
  self.reason = os:unmarshalInt32()
end
function SEnterCrossCompeteMapFailBrd:sizepolicy(size)
  return size <= 65535
end
return SEnterCrossCompeteMapFailBrd
