_G.classlist['CharAddCmd'] = 'CharAddCmd'
_G.CharAddCmd = {}
CharAddCmd.objName = 'CharAddCmd'
function CharAddCmd:create(callback)
    self.callback = callback
    return self
end

function CharAddCmd:execute()
    ConnManager:addHandler(CharCmdDict.ADD_CHAR, self, CharAddCmd.onCharAdd)
end

function CharAddCmd:onCharAdd(pak)
    local vo = {}
    local buffLength,   idx     = readInt(pak)
    local charId,       idx     = readGuid(pak, idx)        vo.charId       = charId
    local charType,     idx     = readByte(pak, idx)        vo.charType     = charType
    local x,            idx     = readInt(pak, idx)         vo.x            = x
    local y,            idx     = readInt(pak, idx)         vo.y            = y
    local faceto,       idx     = readInt(pak, idx)         vo.faceto       = faceto      
    if charType == enEntType.eEntType_Item then
        local configId, idx = readInt(pak, idx)             vo.configId     = configId
        local ownerId, idx = readGuid(pak, idx)             vo.ownerId      = ownerId
        local stackCount, idx = readInt(pak, idx)           vo.stackCount   = stackCount
        local source, idx = readGuid(pak, idx)              vo.source       = source
        local born, idx = readByte(pak, idx)                vo.born         = born
    elseif charType == enEntType.eEntType_Monster then
        local speed, idx     = readInt(pak, idx)            vo.speed        = speed                                                            
        local configId, idx = readInt(pak, idx)             vo.configId     = configId
        local currHP, idx = readDouble(pak, idx)            vo.dwCurrHP     = currHP
        local maxHP, idx = readDouble(pak, idx)             vo.dwMaxHP      = maxHP
        local ubit, idx = readInt(pak, idx)                 vo.ubit         = ubit
        local born, idx = readByte(pak, idx)                vo.born         = born
        local camp, idx = readByte(pak, idx)                vo.camp         = camp
        local belongType, idx = readInt(pak, idx)           vo.belongType   = belongType
        local belongID, idx = readGuid(pak, idx)            vo.belongID     = belongID
    elseif charType == enEntType.eEntType_Npc then
        local configId, idx = readInt(pak, idx)             vo.configId     = configId
    elseif charType == enEntType.eEntType_Player then
        local speed, idx = readInt(pak, idx)                vo.speed        = speed
        local rolename, idx = readString32(pak, idx)        vo.szRoleName   = rolename
        local prof, idx = readInt(pak, idx)                 vo.dwProf       = prof
		local sex, idx = readByte(pak, idx)                 vo.dwSex        = sex  
		local dress, idx = readInt(pak, idx)                vo.dwDress      = dress
		local arms, idx = readInt(pak, idx)                 vo.dwArms       = arms
		local fashionshead, idx = readInt(pak, idx)         vo.dwFashionsHead = fashionshead
		local fashionsdress, idx = readInt(pak, idx)        vo.dwFashionsDress = fashionsdress
		local fashionsarms, idx = readInt(pak, idx)         vo.dwFashionsArms = fashionsarms
        local level, idx = readInt(pak, idx)                vo.dwLevel      = level
        local currHP, idx = readInt(pak, idx)               vo.dwCurrHP     = currHP
        local maxHP, idx = readInt(pak, idx)                vo.dwMaxHP      = maxHP
        local wuhun, idx = readInt(pak, idx)                vo.wuhun        = wuhun
        local teamId, idx = readGuid(pak, idx)              vo.teamId       = teamId
        local guildId, idx = readGuid(pak, idx)             vo.guildId      = guildId
		local guildName, idx = readString32(pak, idx)       vo.szGuildName  = guildName
		local horse, idx = readInt(pak, idx)				vo.dwHorseID	= horse
        local sitId, idx = readInt(pak, idx)                vo.sitId        = sitId
        local sitIndex, idx = readByte(pak, idx)            vo.sitIndex     = sitIndex
        local title, idx = readInt(pak, idx)                vo.title        = title
        local title1, idx = readInt(pak, idx)               vo.title1       = title1
        local title2, idx = readInt(pak, idx)               vo.title2       = title2
        local icon, idx = readByte(pak, idx)                vo.icon         = icon   
        local vipLevel, idx = readByte(pak, idx)            vo.eaVIPLevel   = vipLevel   
        local pkState, idx = readByte(pak, idx)				vo.rolePkState  = pkState
		local ubit, idx = readInt(pak, idx)                 vo.ubit         = ubit
        local camp, idx = readByte(pak, idx)                vo.roleCamp     = camp
        local lingzhi, idx = readInt(pak, idx)              vo.lingzhi      = lingzhi
        local vflag, idx = readInt(pak, idx)             	vo.vflag        = vflag
		local lovelypet, idx = readInt(pak, idx)            vo.lovelypet  	= lovelypet
        local wing, idx = readInt(pak, idx)                 vo.dwWing       = wing
        local suitflag, idx = readInt(pak, idx)             vo.suitflag     = suitflag
        local footprints, idx = readInt(pak, idx)           vo.footprints   = footprints
        local fightValue, idx = readInt64(pak, idx)         vo.fightValue   = fightValue
        local treasure, idx = readInt(pak, idx)             vo.treasure     = treasure
        local serverId, idx = readInt(pak, idx)             vo.serverId     = serverId
        local partnerName, idx = readString32(pak, idx)     vo.partnerName  = partnerName
        local shenwuId, idx = readByte(pak, idx)            vo.shenwuId     = shenwuId
		local shoulder, idx = readInt(pak, idx)             vo.dwShoulder   = shoulder
        local zhuanZhiLv, idx = readInt(pak, idx)           vo.zhuanZhiLv   = zhuanZhiLv
        local TransferModel, idx= readInt(pak,idx)          vo.TransferModel=TransferModel
        local XianJieModelId,idx=readInt(pak,idx)           vo.XianJieModelId =XianJieModelId
        local eatType, idx = readGuid(pak, idx)             vo.eatType      = eatType  -- 吃饭类型or椅子id
        local xuanBingId, idx = readInt(pak, idx)           vo.xuanBingId   = xuanBingId  -- 玄兵 tid
        local baoJiaId, idx = readInt(pak, idx)             vo.baoJiaId     = baoJiaId  -- 宝甲 tid
        local roleRealm, idx = readInt(pak, idx)            vo.roleRealm    = roleRealm   --境界
        local lingQi, idx = readInt(pak, idx)               vo.lingQi       = lingQi   --灵器
        local magicWeapon, idx = readInt(pak, idx)          vo.magicWeapon  = magicWeapon   --神兵
        local mingYu, idx = readInt(pak, idx)               vo.mingYu       = mingYu   --玉佩
        local tianshenStart, idx = readByte(pak, idx)       vo.tianshenStart= tianshenStart
        local tianshenLv, idx = readInt(pak, idx)       	vo.tianshenLv	= tianshenLv
        local tianshenColor, idx = readByte(pak, idx)       vo.tianshenColor= tianshenColor
    elseif charType == enEntType.eEntType_Collection then
        local speed, idx = readInt(pak, idx)                vo.speed        = speed
        local configId, idx = readInt(pak, idx)             vo.configId     = configId
        local born, idx = readByte(pak, idx)                vo.born         = born
    elseif charType == enEntType.eEntType_Trap then
        local configId, idx = readInt(pak, idx)             vo.configId     = configId
        local ownerId, idx  = readGuid(pak, idx)            vo.ownerId      = ownerId
        local born, idx = readByte(pak, idx)                vo.born         = born
    elseif charType == enEntType.eEntType_Duke then
        local rolename, idx = readString32(pak, idx)        vo.szRoleName   = rolename
        local prof, idx = readInt(pak, idx)                 vo.dwProf       = prof
        local sex, idx = readByte(pak, idx)                 vo.dwSex        = sex        
        local dress, idx = readInt(pak, idx)                vo.dwDress      = dress
        local arms, idx = readInt(pak, idx)                 vo.dwArms       = arms
        local fashionshead, idx = readInt(pak, idx)         vo.dwFashionsHead = fashionshead
        local fashionsdress, idx = readInt(pak, idx)        vo.dwFashionsDress = fashionsdress
        local fashionsarms, idx = readInt(pak, idx)         vo.dwFashionsArms = fashionsarms
        local level, idx = readInt(pak, idx)                vo.dwLevel      = level
        local wuhun, idx = readInt(pak, idx)                vo.wuhun        = wuhun
        local guildId, idx = readGuid(pak, idx)             vo.guildId      = guildId
        local guildName, idx = readString32(pak, idx)       vo.szGuildName  = guildName
        local horse, idx = readInt(pak, idx)                vo.dwHorseID    = horse
        local icon, idx = readByte(pak, idx)                vo.icon         = icon   
        local vipLevel, idx = readByte(pak, idx)            vo.eaVIPLevel   = vipLevel   
        local vflag, idx = readInt(pak, idx)                vo.vflag        = vflag
        local lovelypet, idx = readInt(pak, idx)            vo.lovelypet    = lovelypet
        local wing, idx = readInt(pak, idx)                 vo.dwWing       = wing
		local shoulder, idx = readInt(pak, idx)             vo.dwShoulder   = shoulder
    elseif charType == enEntType.eEntType_LingShou then
        local configId, idx = readInt(pak, idx)             vo.configId     = configId
        local ownerId, idx = readGuid(pak, idx)             vo.ownerId      = ownerId
        local speed, idx = readInt(pak, idx)                vo.speed        = speed
        local ubit, idx = readInt(pak, idx)                 vo.ubit         = ubit
        local flag, idx = readByte(pak, idx)                vo.flag         = flag
        local nType, idx = readByte(pak, idx)               vo.nType        = nType
    elseif charType == enEntType.eEntType_Portal then
        local configId, idx = readInt(pak, idx)             vo.configId     = configId
    elseif charType == enEntType.eEntType_Patrol then
        local configId, idx = readInt(pak, idx)             vo.configId     = configId
        local manName, idx = readString32(pak, idx)         vo.manName      = manName
        local womanName, idx = readString32(pak, idx)       vo.womanName      = womanName


    end
    if self.callback ~= nil then
        self.callback(vo)
    end
end