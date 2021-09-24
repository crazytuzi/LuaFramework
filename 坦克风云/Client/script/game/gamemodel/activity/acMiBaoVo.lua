acMiBaoVo=activityVo:new()

function acMiBaoVo:updateSpecialData(data)

  if self.advanced == nil then
    self.advanced = {}
  end

  if data.br ~= nil then
    self.advanced = data.br
  end
  
  -- 碎片数量
  if self.pieces == nil then
    self.pieces = {}
  end

  if data.ls ~= nil then
    self.pieces = data.ls
  end
  
  -- 碎片配置
  if self.piecesCfg == nil then
    self.piecesCfg = {}-- 拼合道具需要的各种碎片的数量
  end

  if data.pc ~= nil then
    self.piecesCfg = data.pc
  end
  
  -- 拼合后得到的道具
  if self.pinHeId == nil then
    self.pinHeId = "p406"
  end

  if data.pid ~= nil then
    self.pinHeId = data.pid
  end

end