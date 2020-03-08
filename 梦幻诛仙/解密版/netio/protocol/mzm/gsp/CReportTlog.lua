local CReportTlog = class("CReportTlog")
CReportTlog.TYPEID = 12590100
function CReportTlog:ctor(tlog_name, tlog_content)
  self.id = 12590100
  self.tlog_name = tlog_name or nil
  self.tlog_content = tlog_content or nil
end
function CReportTlog:marshal(os)
  os:marshalOctets(self.tlog_name)
  os:marshalOctets(self.tlog_content)
end
function CReportTlog:unmarshal(os)
  self.tlog_name = os:unmarshalOctets()
  self.tlog_content = os:unmarshalOctets()
end
function CReportTlog:sizepolicy(size)
  return size <= 65535
end
return CReportTlog
