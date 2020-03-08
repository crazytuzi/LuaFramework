local CFindPlayer = class("CFindPlayer")
CFindPlayer.TYPEID = 12587009
function CFindPlayer:ctor(content)
  self.id = 12587009
  self.content = content or nil
end
function CFindPlayer:marshal(os)
  os:marshalString(self.content)
end
function CFindPlayer:unmarshal(os)
  self.content = os:unmarshalString()
end
function CFindPlayer:sizepolicy(size)
  return size <= 65535
end
return CFindPlayer
