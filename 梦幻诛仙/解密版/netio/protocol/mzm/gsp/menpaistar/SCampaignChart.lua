local SCampaignChart = class("SCampaignChart")
SCampaignChart.TYPEID = 12612365
function SCampaignChart:ctor(occupationid, ranks, page, total_page)
  self.id = 12612365
  self.occupationid = occupationid or nil
  self.ranks = ranks or {}
  self.page = page or nil
  self.total_page = total_page or nil
end
function SCampaignChart:marshal(os)
  os:marshalInt32(self.occupationid)
  os:marshalCompactUInt32(table.getn(self.ranks))
  for _, v in ipairs(self.ranks) do
    v:marshal(os)
  end
  os:marshalInt32(self.page)
  os:marshalInt32(self.total_page)
end
function SCampaignChart:unmarshal(os)
  self.occupationid = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.menpaistar.CampaignChartInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.ranks, v)
  end
  self.page = os:unmarshalInt32()
  self.total_page = os:unmarshalInt32()
end
function SCampaignChart:sizepolicy(size)
  return size <= 65535
end
return SCampaignChart
