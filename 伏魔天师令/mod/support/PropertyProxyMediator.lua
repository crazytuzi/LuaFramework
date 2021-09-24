local PropertyProxyMediator = classGc(mediator,function(self,_view)
    self.name="PropertyProxyMediator"
    self.view=_view
    self:regSelfLong()

    self.m_firstGoScene=true
end)

PropertyProxyMediator.protocolsList={
    _G.Msg["ACK_ROLE_CURRENCY"], -- {[1022]货币 -- 角色 }
    _G.Msg["ACK_ROLE_ENERGY_OK"], -- [1261]请求体力值成功 -- 角色
    _G.Msg["ACK_ROLE_LV_MY"], -- [1311]请求vip回复 -- 角色
    _G.Msg["ACK_ROLE_PROPERTY_REVE"], -- [1108]玩家属性 -- 角色
    -- _G.Msg["ACK_ROLE_PARTNER_DATA"], -- [1109]伙伴属性 -- 角色
    _G.Msg["ACK_ROLE_PROPERTY_UPDATE"],
    _G.Msg["ACK_ROLE_PROPERTY_UPDATE2"], -- [1130]玩家单个属性更新 -- 角色 --1131
    _G.Msg["ACK_INN_YUAN_HUN"], -- [31385]妖灵 -- 角色 
    _G.Msg["ACK_GOODS_EQUIP_BACK"],    --  2242角色装备信息返回
    _G.Msg["ACK_GOODS_REMOVE"],    --- [2040]消失物品/装备 -- 物品/背包
    _G.Msg["ACK_GOODS_CHANGE"],    -- [2050]物品/装备属性变化 -- 物品/背包
    _G.Msg["ACK_SKILL_INFO"],                 -- [6530]技能信息 -- 技能系统
    _G.Msg["ACK_SKILL_EQUIP_INFO"],           -- [6545]返回装备技能信息 -- 技能系统
    _G.Msg["ACK_ROLE_BUFF_ENERGY"],
    -- _G.Msg["ACK_INN_RES_PARTNER"],  -- (手动) -- [31270]离队/归队结果 -- 客栈  -- {1:归队成功0:离队成功}
    _G.Msg["ACK_SKILL_LIST"],  -- [6520]技能列表数据 -- 技能

    _G.Msg["ACK_MAKE_XUANJING"], -- [2800]玄铁 -- 物品/打造/强化
    _G.Msg["ACK_LINGYAO_YUANHUN"],    -- [2800]妖灵 -- 灵妖兑换
    _G.Msg["ACK_MAKE_PART_ALL_REP"], -- (2736手动) -- [2736]所有部位返回 -- 物品/打造/强化 
    _G.Msg["ACK_COPY_UP_STATE"], -- [7110]挂机状态 -- 副本 
    _G.Msg["ACK_LINGYAO_RENOWN"], --灵妖声望
    _G.Msg["ACK_ROLE_VIP_LV"], -- [1313]玩家VIP等级 -- 角色 
    _G.Msg.ACK_ROLE_PROPERTY_REVE2, --[查看玩家专用]

    _G.Msg.ACK_ARENA_THROUGH,-- [23829]验证通过 -- 封神台
    _G.Msg.ACK_COPY_THROUGH,-- [7032]验证通过 -- 副本

    _G.Msg.ACK_SCENE_CHANG_TITLE,
    _G.Msg.ACK_FEATHER_SKILL,

    _G.Msg.ACK_MAGIC_EQUIP_USE_REPLY,
    
    _G.Msg.ACK_ROLE_CREATE_TIME,
    _G.Msg.ACK_ROLE_TIME_USE,
}

PropertyProxyMediator.commandsList=nil

function PropertyProxyMediator.__enterGame(self)
    if gc.UserCache.setServerId==nil then return end

    gcprint("SDK submitRoleDatas=============>>>>>>>>")


    local mainProperty=self.view:getMainPlay()
    gc.UserCache:getInstance():setServerId(tostring(_G.GLoginPoxy:getServerId()))
    gc.UserCache:getInstance():setServerName(_G.GLoginPoxy:getServerName())
    gc.UserCache:getInstance():setRoleId(tostring(mainProperty:getUid()))
    gc.UserCache:getInstance():setRoleName(mainProperty:getName())
    gc.UserCache:getInstance():setRoleLevel(tostring(mainProperty:getLv()))
    gc.UserCache:getInstance():setRoleVIP(tostring(mainProperty:getVipLv()))
    gc.UserCache:getInstance():setRoleMoney(tostring(mainProperty:getGold()))
    gc.UserCache:getInstance():setRoleRMB(tostring(mainProperty:getRmb()))
    gc.UserCache:getInstance():setRoleRMB_Bind(tostring(mainProperty:getBindRmb()))
    gc.UserCache:getInstance():setClanName(mainProperty:getClanName() or "")

    local isCreateRole=_G.GLoginPoxy:getFirstLogin()
    if isCreateRole then
        gc.UserCache:getInstance():setObject("isCreateRole","1")
    else
        gc.UserCache:getInstance():setObject("isCreateRole","0")
    end
    gc.UserCache:getInstance():setObject("rolePro",tostring(mainProperty:getPro()))

    gc.SDKManager:getInstance():submitRoleDatas()

    if _G.SysInfo:isYayaImSupport() then
        local cpName=string.format("{\"nickname\":\"%s\",\"uid\":\"%s\"}",mainProperty:getName(),tostring(mainProperty:getUid()))
        gc.VoiceManager:getInstance():loginVoiceCP(cpName)
    end

    local szUrl=_G.SysInfo:urlInto()
    local xhrRequest = cc.XMLHttpRequest:new()
    xhrRequest.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
    xhrRequest:open("GET", szUrl)
    print("__enterGame->  url="..szUrl)

    local function http_handler()
        if xhrRequest.readyState == 4 and (xhrRequest.status >= 200 and xhrRequest.status < 207) then
            local response = xhrRequest.response
            print("__enterGame.http_handler response="..response)
        else
            print("lua error!!!!!!!!! __enterGame.http ERROR!!!!")
        end
    end

    xhrRequest:registerScriptHandler(http_handler)
    xhrRequest:send()
end

-- [31270]休息/出战结果 -- 客栈  -- {2:休息:出战}
function PropertyProxyMediator.ACK_INN_RES_PARTNER( self, _ackMsg )
    local _type      = _ackMsg.type
    local war_type   = _ackMsg.war_type
    local partner_id = _ackMsg.partner_id
    local partner_idx = _ackMsg.partner_idx
    print("PropertyProxyMediator.ACK_INN_RES_PARTNER:   85",_type,war_type,partner_id,"@1#@",partner_idx)
    local mainProperty = self.view:getMainPlay()
    -- local templist = mainProperty :getPartner() or {}
    -- if _type == _G.Const.CONST_INN_OPERATION2 then --出战/休息操作   已招募
    --     print("PropertyProxyMediator.ACK_INN_RES_PARTNER:   89",_type,war_type,partner_id)
    if war_type == _G.Const.CONST_INN_STATA2 then
        --请求伙伴身上装备 
         
        -- local msg=REQ_ROLE_PROPERTY()
        -- msg:setArgs(_G.GLoginPoxy:getServerId(),self.m_mainUid,partner_idx)
        -- _G.Network:send(msg)
        
        -- local msg=REQ_GOODS_EQUIP_ASK()
        -- msg:setArgs(self.m_mainUid,partner_idx)
        -- _G.Network:send( msg)
    else
        mainProperty:setWarPartner()
    end

    local command = CCharacterPartnerWarCommand(_ackMsg)
    _G.controller:sendCommand( command )
end

--  2242角色装备信息返回
function PropertyProxyMediator.ACK_GOODS_EQUIP_BACK( self, _ackMsg )
    -- body
    print( "得到玩家装备")
    local uid        = _ackMsg.uid     --玩家UID
    local partnerIdx = _ackMsg.partner --伙伴ID
    local roleProperty = nil
    if partnerIdx == 0 then
        if self.m_mainUid==uid then
            --玩家自己
            roleProperty = self.view:getMainPlay()
        else
            --其他玩家
            roleProperty = self.view:getOneByUid( uid, _G.Const.CONST_PLAYER)
            if roleProperty == nil then
                roleProperty = require("mod.support.Property")()
                roleProperty : setUid( uid )
                self.view:addOne( roleProperty, _G.Const.CONST_PLAYER )
            end
        end
    else
        --伙伴 索引为uid..id
        local index = tostring(uid)..tostring(partnerIdx)
        roleProperty = self.view:getOneByUid( index, _G.Const.CONST_PARTNER )
        if roleProperty == nil then
            roleProperty = require("mod.support.Property")()
            roleProperty : setUid( uid )
            roleProperty : setPartner_idx( partnerIdx )
            -- local partnerinfo = self :getPartnerInfo( partnerIdx)
            -- roleProperty : updateProperty( _G.Const.CONST_ATTR_NAME,  partnerinfo.partner_name)
            -- roleProperty : updateProperty( _G.Const.CONST_ATTR_NAME_COLOR,  partnerinfo.name_colour)
            self.view:addOne( roleProperty, _G.Const.CONST_PARTNER )
        end
    end

    if roleProperty == nil then
        print("[PropertyProxyMediator.ACK_GOODS_EQUIP_BACK] 人物缓存找不到  %d,%d",uid,partnerIdx)
        return
    end
    
    roleProperty:setAllEquipList(_ackMsg.msg_group)
    roleProperty:setEquipPartList(_ackMsg.msg_group2)
end

-- [2040]消失物品/装备 -- 物品/背包
function PropertyProxyMediator.ACK_GOODS_REMOVE( self, _ackMsg)
    if _ackMsg.type ~= 2 then
        --只接受装备
        return
    end
    print( "[PropertyProxyMediator.ACK_GOODS_REMOVE] GoIn here 人物装备消失")

    local characterId  = _ackMsg.id
    local roleProperty = nil
    if characterId == 0 then
        print("[PropertyProxyMediator.ACK_GOODS_REMOVE]--玩家自己")--玩家自己
        roleProperty = self.view:getMainPlay()
    else
        --伙伴 索引为uid..id
        local index = tostring(self.m_mainUid)..tostring(characterId)
        print("[PropertyProxyMediator.ACK_GOODS_REMOVE]--伙伴 索引为uid..id:"..index)
        roleProperty = self.view:getOneByUid( index, _G.Const.CONST_PARTNER )
    end
    if roleProperty == nil then
        print("[PropertyProxyMediator.ACK_GOODS_REMOVE]--人物缓存找不到")
        return
    end
    roleProperty :removeSomeEquip(_ackMsg.index)

    local command = CCharacterEquipInfoUpdataCommand(_ackMsg.MsgID)
    _G.controller :sendCommand( command)
end

-- [2050]物品/装备属性变化 -- 物品/背包
function PropertyProxyMediator.ACK_GOODS_CHANGE( self, _ackMsg)
    local backpackType     = _ackMsg.type
    if backpackType ~= 2 then
        return
    end
    print( "[PropertyProxyMediator.ACK_GOODS_CHANGE] GoIn here 人物装备改变")
    
    local characterId  = _ackMsg.id
    local roleProperty = nil
    if characterId == 0 then
        --玩家自己
        roleProperty=self.view:getMainPlay()
    else
        --伙伴 索引为uid..id
        local index = tostring(self.m_mainUid)..tostring(characterId)
        roleProperty = self.view:getOneByUid( index, _G.Const.CONST_PARTNER )
    end

    if roleProperty == nil then
        print("[PropertyProxyMediator.ACK_GOODS_CHANGE] 人物缓存找不到 %d",characterId)
        return
    end
    roleProperty:chuangeSomeEquip(_ackMsg.goods_msg_no)

    local command=CCharacterEquipInfoUpdataCommand(_ackMsg.MsgID)
    _G.controller:sendCommand(command)
end

-- (2736手动) -- [2736]所有部位返回 -- 物品/打造/强化 
function PropertyProxyMediator.ACK_MAKE_PART_ALL_REP(self,_ackMsg)
    local characterId = _ackMsg.id
    local roleProperty = nil
    if characterId == 0 then
        --玩家自己
        roleProperty=self.view:getMainPlay()
    else
        --伙伴 索引为uid..id
        local index = tostring(self.m_mainUid)..tostring(characterId)
        roleProperty = self.view:getOneByUid( index, _G.Const.CONST_PARTNER )
    end
    if roleProperty==nil then
        print("[PropertyProxyMediator.ACK_MAKE_PART_ALL_REP] 人物缓存找不到 %d",characterId)
        return
    end
    local nCount=#_ackMsg.msg_xxx
    if nCount>0 then
        for i=1,nCount do
            roleProperty:updateEquipPart(_ackMsg.msg_xxx[i])
        end
        local command=CCharacterEquipInfoUpdataCommand(_ackMsg.MsgID)
        _G.controller:sendCommand(command)
    end
end


-- {[1022]货币 -- 角色 }
function PropertyProxyMediator.ACK_ROLE_CURRENCY( self, _ackMsg )
    print("货币更新===>>>",_ackMsg.gold,_ackMsg.rmb,_ackMsg.bind_rmb)

	local mainProperty=self.view:getMainPlay()
	mainProperty:setGold(_ackMsg.gold)
	mainProperty:setRmb(_ackMsg.rmb)
	mainProperty:setBindRmb(_ackMsg.bind_rmb)

    local comm=CPropertyCommand(CPropertyCommand.MONEY)
    _G.controller:sendCommand(comm)
end

function PropertyProxyMediator.ACK_MAKE_XUANJING( self, _ackMsg )
    print("玄铁更新===>>>",_ackMsg.xuanjing)

    local mainProperty = self.view:getMainPlay()
    mainProperty:setXuanJing( _ackMsg.xuanjing or 0 )
    local comm=CPropertyCommand(CPropertyCommand.MONEY)
    _G.controller:sendCommand(comm)
end

function PropertyProxyMediator.ACK_LINGYAO_YUANHUN( self, _ackMsg )
    print("妖灵更新_LINGYAO_YUANHUN===>>>",_ackMsg.yuanhun)

    local mainProperty = self.view:getMainPlay()
    mainProperty:setYaoLing( _ackMsg.yuanhun or 0 )
    local comm=CPropertyCommand(CPropertyCommand.MONEY)
    _G.controller:sendCommand(comm)
end

-- [1261]请求体力值成功 -- 角色
function PropertyProxyMediator.ACK_ROLE_ENERGY_OK( self, _ackMsg )
    print("体力更新===>>>".._ackMsg.sum .. "  ," .._ackMsg.max)

	local mainProperty=self.view:getMainPlay()
	mainProperty:setSum(_ackMsg.sum)
	mainProperty:setMax(_ackMsg.max)

    local command=CPropertyCommand(CPropertyCommand.ENERGY)
    command.sum=_ackMsg.sum
    command.max=_ackMsg.max
    _G.controller:sendCommand(command)
end

--08.23 add
-- [1262]额外赠送精力 -- 角色
function PropertyProxyMediator.ACK_ROLE_BUFF_ENERGY( self, _ackMsg)
    print("额外体力更新===>>>".._ackMsg.buff_value)
    local mainProperty=self.view:getMainPlay()
    mainProperty:setBuffValue(_ackMsg.buff_value)

    local comm=CPropertyCommand(CPropertyCommand.ENERGY)
    _G.controller:sendCommand(comm)
end
--08.23 end

-- [1311]请求vip回复 -- 角色
function PropertyProxyMediator.ACK_ROLE_LV_MY( self, _ackMsg )
    print("VIP更新===>>>".._ackMsg.lv.."   ,".._ackMsg.vip_up)
	local mainProperty = self.view:getMainPlay()
	mainProperty : setVipLv( _ackMsg.lv)
	mainProperty : setVipUp( _ackMsg.vip_up)
    --告诉StageMediator进入场景
    if _G.g_Stage:isInit() == false then
        -- [1101]请求玩家属性 -- 角色 本玩家
        local msg_role=REQ_ROLE_PROPERTY()
        msg_role:setArgs(_G.GLoginPoxy:getServerId(),self.m_mainUid,0)
        _G.Network:send(msg_role)

        --请求技能信息  --角色自己
        print("请求技能信息开始")
        local msg_skill = REQ_SKILL_REQUEST()
        _G.Network :send( msg_skill )

        --请求玩家身上装备 --本玩家
        print("请求玩家身上装备开始")--有错
        local msg_goods=REQ_GOODS_EQUIP_ASK()
        msg_goods:setArgs(self.m_mainUid,0)
        _G.Network:send(msg_goods)

        if mainProperty:getLv() >= _G.Const.CONST_MATIAX_OPEN then
            print("请求阵法数据")
            local msg_matirx=REQ_MATRIX_REQUEST()
            msg_matirx:setArgs(0)
            _G.Network:send( msg_matirx )
        end
    else
        local command = CPropertyCommand(CPropertyCommand.VIP)
        command.vipLv = _ackMsg.lv
        _G.controller :sendCommand(command)
    end
    if _G.g_Stage.m_isCity then
        _G.g_Stage:getMainPlayer():setVipSpr()
    end
end


function PropertyProxyMediator.ACK_ROLE_VIP_LV( self, _ackMsg )
    local uid = _ackMsg.uid
    local vip = _ackMsg.lv

    local property = self.view:getOneByUid( uid, _G.Const.CONST_PLAYER )
    if property==nil then
        property=require("mod.support.Property")()
        property:setUid(uid)
        self.view:addOne(property,_G.Const.CONST_PLAYER)
    end
    print("PropertyProxyMediator.ACK_ROLE_VIP_LV==",uid,vip)
    property:updateProperty(_G.Const.CONST_ATTR_VIP,vip)
end

function PropertyProxyMediator.ACK_LINGYAO_RENOWN(self, _ackMsg)
    local property = self.view:getOneByUid( self.m_mainUid, _G.Const.CONST_PLAYER )
    property:setRenown(_ackMsg.renown)
end

function PropertyProxyMediator.ACK_ROLE_PROPERTY_REVE( self, _ackMsg )
    CCLOG("PropertyProxyMediator得到玩家属性UID:_ackMsg.uid＝%d",_ackMsg.uid,self.m_mainUid)
    CCLOG("_ackMsg.name=%s,  pro=%d",_ackMsg.name,_ackMsg.pro)
    CCLOG("_ackMsg.skin_armor=%d",_ackMsg.skin_armor)
    CCLOG("_ackMsg.skin_mount=%d",_ackMsg.skin_mount)
    CCLOG("_ackMsg.meiren_id=%d",_ackMsg.meiren_id)
    CCLOG("_ackMsg.is_guide=%d",_ackMsg.is_guide)
    CCLOG("_ackMsg.clan=%s",_ackMsg.clan)
    CCLOG("_ackMsg.clan_pro=%s",_ackMsg.clan_pro)
    print("--clan_name-",_ackMsg.clan_name)
    local uid = _ackMsg.uid
    local property = self.view:getOneByUid( uid, _G.Const.CONST_PLAYER )
    if property == nil then
        print("new Property..................")
        property = require("mod.support.Property")()
        property : setUid( uid )
        self.view:addOne( property, _G.Const.CONST_PLAYER )
    end

    property : updateProperty( _G.Const.CONST_ATTR_NAME,  _ackMsg.name)
    property : updateProperty( _G.Const.CONST_ATTR_NAME_COLOR,  _ackMsg.name_color)
    -- property : setRenown( _ackMsg.renown)
    property : setPro( _ackMsg.pro)
    property : setSex( _ackMsg.sex)
    property : updateProperty( _G.Const.CONST_ATTR_LV,  _ackMsg.lv)
    property : updateProperty( _G.Const.CONST_ATTR_RANK,  _ackMsg.rank)
    property : updateProperty( _G.Const.CONST_ATTR_COUNTRY,  _ackMsg.country)
    property : updateProperty( _G.Const.CONST_ATTR_CLAN, _ackMsg.clan)
    property : updateProperty( _G.Const.CONST_ATTR_CLAN_NAME, _ackMsg.clan_name)
    property : updateProperty( _G.Const.CONST_ATTR_POWERFUL,  _ackMsg.powerful)
    property : updateProperty( _G.Const.CONST_ATTR_EXP,  _ackMsg.exp)
    property : updateProperty( _G.Const.CONST_ATTR_EXPN,  _ackMsg.expn)
    property : updateProperty( _G.Const.CONST_ATTR_WEAPON,  _ackMsg.skin_weapon)
    property : updateProperty( _G.Const.CONST_ATTR_ARMOR,  _ackMsg.skin_armor)    
    property : setMountId(_ackMsg.skin_mount)
    print( "这里受到mount_tx？ = ", _ackMsg.mount_tx )
    property : setMountTexiao( _ackMsg.mount_tx )
    property : setCount( _ackMsg.count)
    property : setIs_guide(_ackMsg.is_guide)
    property : setPower(_ackMsg.power)   
    property : setWingLv(_ackMsg.wing_press)   
    property : setMountLv(_ackMsg.mount_grade) 
    property : setTitle_msg(_ackMsg.title_msg)
    property : setWingSkin( _ackMsg.skin_wing)
    property : setMeirenId( _ackMsg.meiren_id )
    property : setSkinFeather( _ackMsg.skin_feather )
    property : setClanPost( _ackMsg.clan_pro )
    property : setExt1( _ackMsg.ext1)
    property : setExt2( _ackMsg.ext2)
    property : setExt3( _ackMsg.ext3)
    property : setExt4( _ackMsg.ext4)
    property : setExt5( _ackMsg.ext5)

    property : setmagicSkinIdmsg(_ackMsg.magic_msg) --神器数据

    --attr 角色基本属性块2002
    local attr = _ackMsg.attr
    if attr.is_data == true then
        property.attr : setIsData( attr.is_data )
        property : updateProperty( _G.Const.CONST_ATTR_SP ,attr.sp )
        property : updateProperty( _G.Const.CONST_ATTR_HP ,attr.hp )
        property : updateProperty( _G.Const.CONST_ATTR_STRONG_ATT ,attr.att )
        property : updateProperty( _G.Const.CONST_ATTR_STRONG_DEF ,attr.def )
        property : updateProperty( _G.Const.CONST_ATTR_DEFEND_DOWN ,attr.wreck )
        property : updateProperty( _G.Const.CONST_ATTR_HIT , attr.hit)
        property : updateProperty( _G.Const.CONST_ATTR_DODGE , attr.dod)
        property : updateProperty( _G.Const.CONST_ATTR_CRIT ,attr.crit )
        property : updateProperty( _G.Const.CONST_ATTR_RES_CRIT ,attr.crit_res )
        property : updateProperty( _G.Const.CONST_ATTR_BONUS ,attr.bonus )
        property : updateProperty( _G.Const.CONST_ATTR_REDUCTION ,attr.reduction )
    end
    ----------------------------------------------------------------------

    CCLOG("PropertyProxyMediator.ACK_ROLE_PROPERTY_REVE _ackMsg.uid=%d,self.m_mainUid=%d,伙伴数量:%d",_ackMsg.uid,self.m_mainUid,_ackMsg.count)

    if _ackMsg.count>0 and _ackMsg.uid==self.m_mainUid then
        for i=1,_ackMsg.count do
            CCLOG("Partner Idx=%d,state=%d, _ackMsg.uid=%d",_ackMsg.partnerData[i].idx,_ackMsg.partnerData[i].state,_ackMsg.uid)
            if _ackMsg.partnerData[i].idx~=0 then
                if _ackMsg.partnerData[i].state==_G.Const.CONST_INN_STATA2 then
                    local msg=REQ_ROLE_PROPERTY()
                    msg:setArgs(_G.GLoginPoxy:getServerId(),_ackMsg.uid,_ackMsg.partnerData[i].idx)
                    _G.Network:send( msg )
                    --请求伙伴身上装备
                    msg=REQ_GOODS_EQUIP_ASK()
                    msg:setArgs(_ackMsg.uid,_ackMsg.partnerData[i].idx)
                    _G.Network:send( msg)
                end
            end
        end
    end

    --若是玩家。。。
    if _ackMsg.uid==self.m_mainUid then
        _G.SpineManager.resetPlayerMountRes(_ackMsg.skin_mount)
        _G.SpineManager.resetPlayerWeaponRes(_ackMsg.skin_weapon)
        _G.SpineManager.resetPlayerFeatherRes(_ackMsg.skin_feather)

        if not self.m_firstGoScene then return end

        if not _G.GLoginPoxy:getFirstLogin() then
            print("[isFirstLogin]...... no crete new. Go city")
            local msg=REQ_SCENE_ENTER()
            msg:setArgs(0)
            _G.Network:send(msg)
            -- _G.Network:disconnect()
        else
            print("[isFirstLogin]...... no crete new. Go copy")
            local msg=REQ_COPY_CREAT()
            msg:setArgs(_G.Const.CONST_COPY_FIRST_COPY)
            _G.Network:send(msg)
        end

        self.m_firstGoScene=nil
        self:__enterGame()
    end
    print("[isFirstLogin]......  All checked finish!!!!!!!!")
    -------------------------------------------------------------------------
end

--更新伙伴的名字和颜色
function PropertyProxyMediator.getPartnerInfo( self, _partnerid)
    return _G.Cfg.partner_init[_partnerid]
end

-- [1109]伙伴属性 -- 角色
function PropertyProxyMediator.ACK_ROLE_PARTNER_DATA( self, _ackMsg )
    CCLOG("PropertyProxyMediator.ACK_ROLE_PARTNER_DATA 得到伙伴属性UID:%d,state:%d",_ackMsg.uid,_ackMsg.stata)
    local uid        = _ackMsg.uid
    local partner_id = _ackMsg.partner_id
    local idx        = _ackMsg.partner_idx
    local index      = tostring( uid)..tostring(idx)

    CCLOG("PropertyProxyMediator.ACK_ROLE_PARTNER_DATA uid=%d,partner_id=%d,index=%s",uid,partner_id,index)

    local property = self.view:getOneByUid( index, _G.Const.CONST_PARTNER )
    local playProperty = self.view:getOneByUid( uid, _G.Const.CONST_PLAYER )
    if playProperty==nil then
        print("未找到武将的主人。。。。")
        return
    end

    local isNeedUpdateOrther=false
    if property == nil then
        property = require("mod.support.Property")()
        property : setUid( uid )
        property : setPartner_idx(idx)

        isNeedUpdateOrther=true

        self.view:addOne( property, _G.Const.CONST_PARTNER )
    elseif partner_id~=property:getPartnerId() then
        isNeedUpdateOrther=true
    end

    if isNeedUpdateOrther then
        local partnerinfo=_G.g_CnfDataManager:getPartnerData(partner_id)
        if partnerinfo~=nil then
            property : updateProperty( _G.Const.CONST_ATTR_NAME,  partnerinfo.name)
            property : updateProperty( _G.Const.CONST_ATTR_NAME_COLOR,partnerinfo.name_color)
            property : setSkinArmor( partnerinfo.skin)
            property : setAI(partnerinfo.ai or partnerinfo.skin)

            print("name=%s,name_colour=%d,skinId=%d",partnerinfo.name,partnerinfo.name_color,partnerinfo.skin)
            print("partnerinfo.ai=%d",partnerinfo.ai)
        end
    end

    property : setPro( _ackMsg.partner_pro)
    property : updateProperty( _G.Const.CONST_ATTR_LV,  _ackMsg.partner_lv)
    property : updateProperty( _G.Const.CONST_ATTR_POWERFUL,  _ackMsg.powerful)
    property : updateProperty( _G.Const.CONST_ATTR_EXP,  _ackMsg.exp)
    property : updateProperty( _G.Const.CONST_ATTR_EXPN,  _ackMsg.next_exp)
    property : setPartnerId( partner_id)
    property : setStata( _ackMsg.stata)
    property : setLock(_ackMsg.lock)
    property : setTeamID( playProperty:getTeamID())

    print("playProperty:getTeamID()=%d",playProperty:getTeamID())

    --attr 角色基本属性块2002
    local attr = _ackMsg.attr
    if attr.is_data == true then
        property.attr : setIsData( attr.is_data )
        property : updateProperty( _G.Const.CONST_ATTR_SP ,attr.sp )
        property : updateProperty( _G.Const.CONST_ATTR_HP ,attr.hp )
        property : updateProperty( _G.Const.CONST_ATTR_STRONG_ATT ,attr.att )
        property : updateProperty( _G.Const.CONST_ATTR_STRONG_DEF ,attr.def )
        property : updateProperty( _G.Const.CONST_ATTR_DEFEND_DOWN ,attr.wreck )
        property : updateProperty( _G.Const.CONST_ATTR_HIT , attr.hit)
        property : updateProperty( _G.Const.CONST_ATTR_DODGE , attr.dod)
        property : updateProperty( _G.Const.CONST_ATTR_CRIT ,attr.crit )
        property : updateProperty( _G.Const.CONST_ATTR_RES_CRIT ,attr.crit_res )
        property : updateProperty( _G.Const.CONST_ATTR_BONUS ,attr.bonus )
        property : updateProperty( _G.Const.CONST_ATTR_REDUCTION ,attr.reduction )
    end

    print("sssssssssssssss======>>>>",_ackMsg.stata,_G.Const.CONST_INN_STATA2)
    if _ackMsg.stata==_G.Const.CONST_INN_STATA2 then
        playProperty:setWarPartner(property)
    end

    local command = CCharacterPartnerAttrCommand()
    command.partnerid = partner_id
    _G.controller:sendCommand( command )
end

function PropertyProxyMediator.ACK_ROLE_PROPERTY_UPDATE2( self, _ackMsg )
    print("更新角色/伙伴属性UID:",_ackMsg.id)
    self:ACK_ROLE_PROPERTY_UPDATE(_ackMsg)
end

-- [31385]妖灵 -- 角色 
function PropertyProxyMediator.ACK_INN_YUAN_HUN ( self, _ackMsg )
    local property = self.view:getMainPlay()
    property : setSoul(_ackMsg.yuan_hun)
end

-- [1130]玩家单个属性更新 -- 角色
function PropertyProxyMediator.ACK_ROLE_PROPERTY_UPDATE( self, _ackMsg )
    print("更新角色/伙伴属性UID:",_ackMsg.id)
    local partner_id = _ackMsg.id
    local property = nil
    if partner_id==0 then
        print("更新玩家属性")
        property = self.view:getMainPlay()
    else
        local index = tostring(self.m_mainUid)..tostring(partner_id)
        property = self.view:getOneByUid(index,_G.Const.CONST_PARTNER)
        print("更新伙伴属性：",index)
    end
    if property==nil then
        print("没有找到玩家/伙伴")
        return
    end

    property:updateProperty( _ackMsg.type,_ackMsg.value)

    local command = CCharacterPartnerAttrCommand()
    command.partnerid = partner_id
    _G.controller:sendCommand( command )

    -- print(":::::::", _G.Const.CONST_ATTR_CLAN_NAME, _G.Const.CONST_ATTR_CLAN, "[[[[[===]]]]]",_ackMsg.type, _ackMsg.value)
    if _ackMsg.type == _G.Const.CONST_ATTR_CLAN_NAME then
        local temp = _ackMsg.value or "null name"
        print("自己的门派信息更改！！！  clan or clan_name=",_ackMsg.value)
    elseif _ackMsg.type == _G.Const.CONST_ATTR_ALLS_POWER then
        local updateCommand = CPropertyCommand( CPropertyCommand.POWERFUL_ALL )
        _G.controller :sendCommand( updateCommand )
    elseif _ackMsg.type == _G.Const.CONST_ATTR_POWERFUL then
        local updateCommand=CPropertyCommand( CPropertyCommand.POWERFUL )
        updateCommand.uid=partner_id
        updateCommand.powerful=_ackMsg.value
        _G.controller :sendCommand( updateCommand )
    elseif _ackMsg.type == _G.Const.CONST_ATTR_EXP or _ackMsg.type==_G.Const.CONST_ATTR_EXPN then
        print("发送经验更新")
        local updateCommand = CPropertyCommand( CPropertyCommand.EXP )
        _G.controller :sendCommand( updateCommand )
    elseif _ackMsg.type == _G.Const.CONST_ATTR_LV and partner_id==0 then
        print("人物升级")
        local updateCommand = CPropertyCommand(CPropertyCommand.LEVELUP)
        updateCommand.lv = _ackMsg.value
        _G.controller :sendCommand( updateCommand )
        
        if not _G.SysInfo:isYiJieChannel() or not _G.SysInfo:isUCChannel()
            or not _G.SysInfo:is19YOUChannel() then
            gc.UserCache:getInstance():setRoleLevel(tostring(_ackMsg.value))
            gc.SDKManager:getInstance():executeCommand(_G.Const.SDK_COMMAND_LEVEL)
        end
    elseif _ackMsg.type == _G.Const.CONST_ATTR_NAME and partner_id==0 then
        print("名字改变") 
        local command=CErrorBoxCommand(_G.Lang.LAB_N[911].._ackMsg.value)
        controller:sendCommand(command)

        if partner_id==0 then
            local command=CPropertyCommand(CPropertyCommand.NAME)
            command.name=_ackMsg.value
            _G.controller:sendCommand(command)
        end

        local tempPlayer=_G.CharacterManager:getPlayerByID(property:getUid())
        if tempPlayer~=nil then
            tempPlayer:setNameString(_ackMsg.value)
        end
    end

    local command=CCharacterInfoUpdataCommand(_ackMsg.id)
    _G.controller:sendCommand(command)
end

-- [6530]技能信息 -- 技能系统
function PropertyProxyMediator.ACK_SKILL_INFO( self, _ackMsg)
    CCLOG("PropertyProxyMediator.ACK_SKILL_INFO skill_id=%d, skill_lv=%d",_ackMsg.skill_id,_ackMsg.skill_lv)

    local singleSkillData ={
        skill_id=_ackMsg.skill_id,
        skill_lv=_ackMsg.skill_lv,
    }
    local roleProperty=self.view:getMainPlay()
    local roleSkillData=roleProperty:getSkillData()

    if roleSkillData.skill_study_list == nil then
        roleSkillData.skill_study_list = {}
    end

    roleSkillData.skill_study_list[ _ackMsg.skill_id] = singleSkillData

    local command = CSkillDataUpdateCommand( CSkillDataUpdateCommand.TYPE_UPDATE)
    _G.controller :sendCommand( command)
end

-- [6545]返回装备技能信息 -- 技能系统
function PropertyProxyMediator.ACK_SKILL_EQUIP_INFO( self, _ackMsg)
    
    CCLOG("PropertyProxyMediator.ACK_SKILL_EQUIP_INFO equip_pos=%d ,skill_id=%d,skill_lv=%d",_ackMsg.equip_pos, _ackMsg.skill_id, _ackMsg.skill_lv)

    local singleSkillData = {
        equip_pos = _ackMsg.equip_pos,
        skill_id  = _ackMsg.skill_id,
        skill_lv  = _ackMsg.skill_lv,
    }

    local roleProperty=self.view:getMainPlay()

    local roleSkillData=roleProperty:getSkillData()
    roleSkillData:addEquipSkillData(singleSkillData)

    -- _G.SpineManager.resetPlayerSkillRes()

    local command = CSkillDataUpdateCommand( CSkillDataUpdateCommand.TYPE_EQUIP)
    _G.controller :sendCommand( command)
end

function PropertyProxyMediator.ACK_SKILL_LIST( self, _ackMsg )
    local power = _ackMsg.power
    local roleProperty = self.view:getMainPlay()
    roleProperty:setPower(power)
    print("战功更新===>>>",power)
end

function PropertyProxyMediator.ACK_ROLE_PROPERTY_REVE2(self,_ackMsg)
    print("ACK_ROLE_PROPERTY_REVE2==================>>>>>>>>11111111111",_ackMsg.powerful,_ackMsg.power,_ackMsg.vip)
    local uid = _ackMsg.uid
    local property=self.view:getOneByUid(uid,_G.Const.CONST_PLAYER)
    if property==nil then
        print("new Property..................")
        property=require("mod.support.Property")()
        property:setUid(uid)
        self.view:addOne(property,_G.Const.CONST_PLAYER)
    end
    print("CONST_ATTR_VIP-->_ackMsg.vip====>",_ackMsg.vip)
    property : updateProperty( _G.Const.CONST_ATTR_VIP,_ackMsg.vip)
    property : updateProperty( _G.Const.CONST_ATTR_NAME,_ackMsg.name)
    property : setPro( _ackMsg.pro)
    property : updateProperty( _G.Const.CONST_ATTR_LV,  _ackMsg.lv)
    property : updateProperty( _G.Const.CONST_ATTR_CLAN, _ackMsg.clan)
    property : updateProperty( _G.Const.CONST_ATTR_CLAN_NAME, _ackMsg.clan_name)
    property : updateProperty( _G.Const.CONST_ATTR_POWERFUL,  _ackMsg.powerful)
    property : updateProperty( _G.Const.CONST_ATTR_EXP,  _ackMsg.exp)
    property : updateProperty( _G.Const.CONST_ATTR_EXPN,  _ackMsg.expn)
    property : updateProperty( _G.Const.CONST_ATTR_WEAPON,  _ackMsg.skin_weapon)
    property : updateProperty( _G.Const.CONST_ATTR_ARMOR,  _ackMsg.pro+10000)
    property : updateProperty( _G.Const.CONST_CURRENCY_ADV_SKILL+1,  _ackMsg.power)

    property : setWingSkin( _ackMsg.skin_wing)
    property : setSkinFeather( _ackMsg.skin_feather )

    --attr 角色基本属性块2002
    local attr = _ackMsg.attr
    property.attr : setIsData( true )
    property : updateProperty( _G.Const.CONST_ATTR_SP ,attr.sp )
    property : updateProperty( _G.Const.CONST_ATTR_HP ,attr.hp )
    property : updateProperty( _G.Const.CONST_ATTR_STRONG_ATT ,attr.att )
    property : updateProperty( _G.Const.CONST_ATTR_STRONG_DEF ,attr.def )
    property : updateProperty( _G.Const.CONST_ATTR_DEFEND_DOWN ,attr.wreck )
    property : updateProperty( _G.Const.CONST_ATTR_HIT , attr.hit)
    property : updateProperty( _G.Const.CONST_ATTR_DODGE , attr.dod)
    property : updateProperty( _G.Const.CONST_ATTR_CRIT ,attr.crit )
    property : updateProperty( _G.Const.CONST_ATTR_RES_CRIT ,attr.crit_res )
    property : updateProperty( _G.Const.CONST_ATTR_BONUS ,attr.bonus )
    property : updateProperty( _G.Const.CONST_ATTR_REDUCTION ,attr.reduction )

    self:ACK_GOODS_EQUIP_BACK(_ackMsg.equip)

    -- if _ackMsg.p_count>0 then
    --     self:ACK_ROLE_PARTNER_DATA(_ackMsg.p_property)
    --     self:ACK_GOODS_EQUIP_BACK(_ackMsg.p_equip)
    -- end

    local command=CCharacterPropertyACKCommand(_ackMsg.uid)
    _G.controller:sendCommand(command)

    print("ACK_ROLE_PROPERTY_REVE2==================<<<<<<<<")
end

function PropertyProxyMediator.ACK_COPY_UP_STATE(self,_ackMsg)
    print("ACK_COPY_UP_STATE======>>>>>",_ackMsg.state)
    local roleProperty=self.view:getMainPlay()
    roleProperty.mopType=_ackMsg.state

    local command=CMainUiCommand(CMainUiCommand.MOPTYPE)
    command.mopType=_ackMsg.state
    controller:sendCommand(command)
end

-- [23829]验证通过 -- 封神台 
function PropertyProxyMediator.ACK_ARENA_THROUGH(self,_ackMsg)
    self.view:getMainPlay():setBattleKey(_ackMsg.key)
end
-- [7032]验证通过 -- 副本 
function PropertyProxyMediator.ACK_COPY_THROUGH(self,_ackMsg)
    self.view:getMainPlay():setBattleKey(_ackMsg.key)
end

function PropertyProxyMediator.ACK_SCENE_CHANG_TITLE(self,_ackMsg)
    local uid=_ackMsg.uid
    local property=self.view:getOneByUid(uid,_G.Const.CONST_PLAYER)
    if property==nil then
        return
    end
    property:setTitle_msg(_ackMsg.title_msg)

    if _G.CharacterManager then
        local temp_play=_G.CharacterManager:getPlayerByID(uid)
        if temp_play==nil or temp_play.m_lpContainer==nil then
            return
        end
        temp_play:setTitleSpr()
    end
end

function PropertyProxyMediator.ACK_FEATHER_SKILL(self,_ackMsg)
    print("ACK_FEATHER_SKILL======>>>",_ackMsg.id,_ackMsg.lv)
    local mainProperty=self.view:getMainPlay()
    mainProperty:setSkinFeather(_ackMsg.id)
    mainProperty:setFeatherLv(_ackMsg.lv)
    _G.SpineManager.resetPlayerFeatherRes(_ackMsg.id)

    -- local command=CFeatherChuangeCommand()
    -- _G.controller:sendCommand(command)
end

function PropertyProxyMediator.ACK_MAGIC_EQUIP_USE_REPLY(self,_ackMsg)
    print("ACK_MAGIC_EQUIP_USE_REPLY=====>>>>",_ackMsg.skill_id,_ackMsg.lv)
    local mainProperty=self.view:getMainPlay()
    mainProperty:setArtifactSkillId(_ackMsg.skill_id)
    mainProperty:setArtifactSkillLv(_ackMsg.lv)
end

function PropertyProxyMediator.ACK_ROLE_CREATE_TIME(self,_ackMsg)
    print("ACK_ROLE_CREATE_TIME====>>>>",_ackMsg.time_reg,_ackMsg.time_lv_up)
    _ackMsg.time_lv_up=_ackMsg.time_lv_up==0 and _ackMsg.time_reg or _ackMsg.time_lv_up
    gc.UserCache:getInstance():setObject("roleCTime",tostring(_ackMsg.time_reg))
    gc.UserCache:getInstance():setObject("roleLevelMTime",tostring(_ackMsg.time_lv_up))
end
function PropertyProxyMediator.ACK_ROLE_TIME_USE(self,_ackMsg)
    print("ACK_ROLE_TIME_USE====>>>>",_ackMsg.lv,_ackMsg.time)
    if _G.SysInfo:isYiJieChannel() or _G.SysInfo:isUCChannel()
        or _G.SysInfo:is19YOUChannel() then
        gc.UserCache:getInstance():setRoleLevel(tostring(_ackMsg.lv))
        gc.UserCache:getInstance():setObject("roleLevelMTime",tostring(_ackMsg.time))
        gc.SDKManager:getInstance():executeCommand(_G.Const.SDK_COMMAND_LEVEL)
    end
end

return PropertyProxyMediator
