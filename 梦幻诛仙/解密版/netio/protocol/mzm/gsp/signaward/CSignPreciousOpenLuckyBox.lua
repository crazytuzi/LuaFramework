local CSignPreciousOpenLuckyBox = class("CSignPreciousOpenLuckyBox")
CSignPreciousOpenLuckyBox.TYPEID = 12593425
function CSignPreciousOpenLuckyBox:ctor(current_yuan_bao_num)
  self.id = 12593425
  self.current_yuan_bao_num = current_yuan_bao_num or nil
end
function CSignPreciousOpenLuckyBox:marshal(os)
  os:marshalInt64(self.current_yuan_bao_num)
end
function CSignPreciousOpenLuckyBox:unmarshal(os)
  self.current_yuan_bao_num = os:unmarshalInt64()
end
function CSignPreciousOpenLuckyBox:sizepolicy(size)
  return size <= 65535
end
return CSignPreciousOpenLuckyBox
