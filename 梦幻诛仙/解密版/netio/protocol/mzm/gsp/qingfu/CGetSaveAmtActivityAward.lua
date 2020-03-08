local CGetSaveAmtActivityAward = class("CGetSaveAmtActivityAward")
CGetSaveAmtActivityAward.TYPEID = 12588813
function CGetSaveAmtActivityAward:ctor(activity_id, sortid)
  self.id = 12588813
  self.activity_id = activity_id or nil
  self.sortid = sortid or nil
end
function CGetSaveAmtActivityAward:marshal(os)
  os:marshalInt32(self.activity_id)
  os:marshalInt32(self.sortid)
end
function CGetSaveAmtActivityAward:unmarshal(os)
  self.activity_id = os:unmarshalInt32()
  self.sortid = os:unmarshalInt32()
end
function CGetSaveAmtActivityAward:sizepolicy(size)
  return size <= 65535
end
return CGetSaveAmtActivityAward
