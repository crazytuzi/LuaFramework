local SCommonResultRes = class("SCommonResultRes")
SCommonResultRes.TYPEID = 12585985
SCommonResultRes.RENAME_DUPLICATE = 0
SCommonResultRes.RENAME_SENSITIVE = 1
SCommonResultRes.RENAME_SUCCESS = 2
SCommonResultRes.RENAME_BAN_BY_IDIP = 101
SCommonResultRes.VIGOR_NOT_ENOUGH = 3
SCommonResultRes.VIGOR_OUT_OF_LIMIT = 4
SCommonResultRes.USE_VIGOR_ITEM_DAY_LIMIT = 5
SCommonResultRes.ADD_EXP_REACH_MAX_LEVEL = 6
SCommonResultRes.NO_MORE_CHANGE_TO_XIULIAN = 7
SCommonResultRes.ADD_SILVER_REACH_MAX_LEVEL = 10
SCommonResultRes.ADD_GOLD_REACH_MAX_LEVEL = 11
SCommonResultRes.CHECK_ROLE_INFO__NOT_EXIST = 20
SCommonResultRes.CHECK_ROLE_INFO__DIFF_SERVER = 21
function SCommonResultRes:ctor(result)
  self.id = 12585985
  self.result = result or nil
end
function SCommonResultRes:marshal(os)
  os:marshalInt32(self.result)
end
function SCommonResultRes:unmarshal(os)
  self.result = os:unmarshalInt32()
end
function SCommonResultRes:sizepolicy(size)
  return size <= 65535
end
return SCommonResultRes
