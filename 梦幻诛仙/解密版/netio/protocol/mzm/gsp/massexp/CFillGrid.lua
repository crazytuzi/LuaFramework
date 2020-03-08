local CFillGrid = class("CFillGrid")
CFillGrid.TYPEID = 12608266
function CFillGrid:ctor(cur_index)
  self.id = 12608266
  self.cur_index = cur_index or nil
end
function CFillGrid:marshal(os)
  os:marshalInt32(self.cur_index)
end
function CFillGrid:unmarshal(os)
  self.cur_index = os:unmarshalInt32()
end
function CFillGrid:sizepolicy(size)
  return size <= 65535
end
return CFillGrid
