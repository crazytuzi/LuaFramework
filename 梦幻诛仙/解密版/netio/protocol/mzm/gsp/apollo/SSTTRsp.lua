local SSTTRsp = class("SSTTRsp")
SSTTRsp.TYPEID = 12602639
function SSTTRsp:ctor(retcode, file_id, file_text)
  self.id = 12602639
  self.retcode = retcode or nil
  self.file_id = file_id or nil
  self.file_text = file_text or nil
end
function SSTTRsp:marshal(os)
  os:marshalInt32(self.retcode)
  os:marshalOctets(self.file_id)
  os:marshalOctets(self.file_text)
end
function SSTTRsp:unmarshal(os)
  self.retcode = os:unmarshalInt32()
  self.file_id = os:unmarshalOctets()
  self.file_text = os:unmarshalOctets()
end
function SSTTRsp:sizepolicy(size)
  return size <= 65535
end
return SSTTRsp
