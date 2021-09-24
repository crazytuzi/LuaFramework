--此类为生成当前客户端唯一标识ID
--不过是从负数开始
local UniqueID = classGc(function ( self )
    self.m_nID     = 0
    self.m_nNextId = 0
end)

function UniqueID.getNewID( self )
    self.m_nID = self.m_nID -1
    return self.m_nID
end

function UniqueID.getNextID( self )
    self.m_nNextId = self.m_nNextId+1
    return self.m_nNextId
end

return UniqueID