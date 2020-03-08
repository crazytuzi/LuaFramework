local CUseBaotuFinish = class("CUseBaotuFinish")
CUseBaotuFinish.TYPEID = 12583686
function CUseBaotuFinish:ctor()
  self.id = 12583686
end
function CUseBaotuFinish:marshal(os)
end
function CUseBaotuFinish:unmarshal(os)
end
function CUseBaotuFinish:sizepolicy(size)
  return size <= 65535
end
return CUseBaotuFinish
