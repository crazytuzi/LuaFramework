-- --------------------------------------------------------------------

-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      联盟宝库 后端 国辉 策划 松岳
-- <br/>Create: 2019-09-04
-- --------------------------------------------------------------------
GuildmarketplaceModel = GuildmarketplaceModel or BaseClass()

function GuildmarketplaceModel:__init(ctrl)
    self.ctrl = ctrl
    self:config()
end
local string_format = string.format

function GuildmarketplaceModel:config()
end

-- 3联盟秘境系统 4联盟战 5圣诞期间
function GuildmarketplaceModel:getStrByType(_type, name)
    if not _type then return end
    local str
    if _type == GuildmarketplaceConst.RewardRecordType.eSecretArea then
        str = string_format(TI18N(" <div fontcolor=#d95014>联盟秘境·%s</div>的奖励已放入"), name)
    elseif _type == GuildmarketplaceConst.RewardRecordType.eGuildWar then
        str = TI18N(" <div fontcolor=#d95014>联盟战</div>的奖励已放入")
    elseif _type == GuildmarketplaceConst.RewardRecordType.eMonopoly then
        str = string_format(TI18N(" <div fontcolor=#d95014>圣夜奇境·%s</div>的奖励已放入"), name)
    else
        str = string_format(TI18N(" <div fontcolor=#d95014>%s</div>的奖励已放入"), name)
    end
    return str
end

function GuildmarketplaceModel:__delete()
end