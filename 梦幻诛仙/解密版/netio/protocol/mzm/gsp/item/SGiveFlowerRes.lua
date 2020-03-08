local SGiveFlowerRes = class("SGiveFlowerRes")
SGiveFlowerRes.TYPEID = 12584792
function SGiveFlowerRes:ctor(giverRoleid, giverRoleName, receiverRoleid, receiverRoleName, itemid, itemnum, addIntimacyNum, message, effectid, isall, isbulletin)
  self.id = 12584792
  self.giverRoleid = giverRoleid or nil
  self.giverRoleName = giverRoleName or nil
  self.receiverRoleid = receiverRoleid or nil
  self.receiverRoleName = receiverRoleName or nil
  self.itemid = itemid or nil
  self.itemnum = itemnum or nil
  self.addIntimacyNum = addIntimacyNum or nil
  self.message = message or nil
  self.effectid = effectid or nil
  self.isall = isall or nil
  self.isbulletin = isbulletin or nil
end
function SGiveFlowerRes:marshal(os)
  os:marshalInt64(self.giverRoleid)
  os:marshalString(self.giverRoleName)
  os:marshalInt64(self.receiverRoleid)
  os:marshalString(self.receiverRoleName)
  os:marshalInt32(self.itemid)
  os:marshalInt32(self.itemnum)
  os:marshalInt32(self.addIntimacyNum)
  os:marshalString(self.message)
  os:marshalInt32(self.effectid)
  os:marshalInt32(self.isall)
  os:marshalInt32(self.isbulletin)
end
function SGiveFlowerRes:unmarshal(os)
  self.giverRoleid = os:unmarshalInt64()
  self.giverRoleName = os:unmarshalString()
  self.receiverRoleid = os:unmarshalInt64()
  self.receiverRoleName = os:unmarshalString()
  self.itemid = os:unmarshalInt32()
  self.itemnum = os:unmarshalInt32()
  self.addIntimacyNum = os:unmarshalInt32()
  self.message = os:unmarshalString()
  self.effectid = os:unmarshalInt32()
  self.isall = os:unmarshalInt32()
  self.isbulletin = os:unmarshalInt32()
end
function SGiveFlowerRes:sizepolicy(size)
  return size <= 65535
end
return SGiveFlowerRes
