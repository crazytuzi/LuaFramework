acPeijianhuzengVo=activityVo:new()
function acPeijianhuzengVo:new()
  local nc={}
  setmetatable(nc,self)
  self.__index=self
  return nc
end

function acPeijianhuzengVo:updateSpecialData(data)
	if data~=nil then
      if data.reward then
        self.reward = data.reward
      end
      if data.cost then
        self.cost = data.cost
      end
      if data.v then
        self.v = data.v
      end
      if data.r then
        self.r = data.r
      end
  end
end