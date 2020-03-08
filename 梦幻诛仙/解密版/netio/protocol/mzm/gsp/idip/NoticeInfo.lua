local OctetsStream = require("netio.OctetsStream")
local NoticeInfo = class("NoticeInfo")
function NoticeInfo:ctor(noticeId, noticeType, displayType, hrefType, hrefText, hrefUrl, sendType, noticeTitle, pictureUrl, startTime, endTime, minOpenServerDays, maxOpenServerDays, minCreatRoleDays, maxCreatRoleDays, minRoleLevel, maxRoleLevel, minSaveAmt, maxSaveAmt, noticeTag, badge, noticeSortID)
  self.noticeId = noticeId or nil
  self.noticeType = noticeType or nil
  self.displayType = displayType or nil
  self.hrefType = hrefType or nil
  self.hrefText = hrefText or nil
  self.hrefUrl = hrefUrl or nil
  self.sendType = sendType or nil
  self.noticeTitle = noticeTitle or nil
  self.pictureUrl = pictureUrl or nil
  self.startTime = startTime or nil
  self.endTime = endTime or nil
  self.minOpenServerDays = minOpenServerDays or nil
  self.maxOpenServerDays = maxOpenServerDays or nil
  self.minCreatRoleDays = minCreatRoleDays or nil
  self.maxCreatRoleDays = maxCreatRoleDays or nil
  self.minRoleLevel = minRoleLevel or nil
  self.maxRoleLevel = maxRoleLevel or nil
  self.minSaveAmt = minSaveAmt or nil
  self.maxSaveAmt = maxSaveAmt or nil
  self.noticeTag = noticeTag or nil
  self.badge = badge or nil
  self.noticeSortID = noticeSortID or nil
end
function NoticeInfo:marshal(os)
  os:marshalInt64(self.noticeId)
  os:marshalInt32(self.noticeType)
  os:marshalInt32(self.displayType)
  os:marshalInt32(self.hrefType)
  os:marshalOctets(self.hrefText)
  os:marshalOctets(self.hrefUrl)
  os:marshalInt32(self.sendType)
  os:marshalOctets(self.noticeTitle)
  os:marshalOctets(self.pictureUrl)
  os:marshalInt64(self.startTime)
  os:marshalInt64(self.endTime)
  os:marshalInt32(self.minOpenServerDays)
  os:marshalInt32(self.maxOpenServerDays)
  os:marshalInt32(self.minCreatRoleDays)
  os:marshalInt32(self.maxCreatRoleDays)
  os:marshalInt32(self.minRoleLevel)
  os:marshalInt32(self.maxRoleLevel)
  os:marshalInt64(self.minSaveAmt)
  os:marshalInt64(self.maxSaveAmt)
  os:marshalInt32(self.noticeTag)
  os:marshalInt32(self.badge)
  os:marshalInt32(self.noticeSortID)
end
function NoticeInfo:unmarshal(os)
  self.noticeId = os:unmarshalInt64()
  self.noticeType = os:unmarshalInt32()
  self.displayType = os:unmarshalInt32()
  self.hrefType = os:unmarshalInt32()
  self.hrefText = os:unmarshalOctets()
  self.hrefUrl = os:unmarshalOctets()
  self.sendType = os:unmarshalInt32()
  self.noticeTitle = os:unmarshalOctets()
  self.pictureUrl = os:unmarshalOctets()
  self.startTime = os:unmarshalInt64()
  self.endTime = os:unmarshalInt64()
  self.minOpenServerDays = os:unmarshalInt32()
  self.maxOpenServerDays = os:unmarshalInt32()
  self.minCreatRoleDays = os:unmarshalInt32()
  self.maxCreatRoleDays = os:unmarshalInt32()
  self.minRoleLevel = os:unmarshalInt32()
  self.maxRoleLevel = os:unmarshalInt32()
  self.minSaveAmt = os:unmarshalInt64()
  self.maxSaveAmt = os:unmarshalInt64()
  self.noticeTag = os:unmarshalInt32()
  self.badge = os:unmarshalInt32()
  self.noticeSortID = os:unmarshalInt32()
end
return NoticeInfo
