-- -------------------------------------------
-- 屏蔽
-- hosr
-- -------------------------------------------
ShieldManager = ShieldManager or BaseClass(BaseManager)

function ShieldManager:__init()
    if ShieldManager.Instance then
        return
    end

    ShieldManager.Instance = self

    self.chatSheilTab = {}

    -- 暂时需求本次登陆有效，不计本地数据(重连不清)
    -- self:LoadChatSheild()
end

function ShieldManager:RequestInitData()
end

-- 加载本地聊天屏蔽数据
function ShieldManager:LoadChatSheild()
end

-- 查询是否在屏蔽列表中
function ShieldManager:CheckIsSheild(key)
    if self.chatSheilTab[key] ~= nil then
        return true
    end
    return false
end

-- 加入到聊天屏蔽列表
-- key = "rid_platform_zoneid"
function ShieldManager:AddChatSheild(key)
    self.chatSheilTab[key] = 1
end

-- 从聊天屏蔽列表移除
-- key = "rid_platform_zoneid"
function ShieldManager:RemoveChatSheild(key)
    self.chatSheilTab[key] = nil
end