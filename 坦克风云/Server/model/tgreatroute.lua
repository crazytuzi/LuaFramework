--[[
    伟大航线(部队)
]]
local function model_tgreatroute(self)
    -- 固定写法 ------------

    self._initPrivate{
        dbData={ -- 初始化的数据
            uid = uid,
            bid = 0, -- 大战id
            troops = {}, -- 部队显示信息(纯给客户端展示用的)
            binfo = {}, -- 部队战斗数据
            updated_at=0,   -- 更新时间
        },
        pkName = "uid", -- 主键名
        tableName = "ugreatroute_troops", -- 表名
    }

    local canSaveFlag = true

    -- ----------------

    function self.toArray()
        return self._getData()
    end

    -- 玩家部队模块用公用数据模块来加载，调用时不必加锁
    -- 所以这里保存时要处理一下只读标识，让只读状态下能保存
    function self.save()
        if canSaveFlag then
            self._setReadOnlyFlag()
            return self._save()
        end
    end

    function self.init()
    end

    function self.serverRequest(params)
        local config = getConfig("config.z"..getZoneId()..".worldwar")
        local result = sendGameserver(config.host,config.port,params)

        -- 服务器无返回
        if type(result) ~= "table" then
            writeLog({params=params,serverRequest=result or "no result"},"greatroute")
            return false
        end

        if result.ret == 0 then
            return true, result
        end

        return false, result.ret
    end

    -- 设置部队
    -- 首次设置部队时，需要将自己的信息及部队数据同步至跨服，以待入侵时作为入侵者使用
    function self.setTroops(bid,fleet,troopsInfo)
        if self.bid ~= bid then
            local mUserinfo = getUserObjs(self.uid).getModel('userinfo')
            local data={
                cmd='greatroute.server.setMember',
                params = {
                    bid="b" .. bid,
                    zid=getZoneId(),
                    aid=mUserinfo.alliance,
                    uid=self.uid,
                    pic=mUserinfo.pic,
                    bpic=mUserinfo.bpic,
                    apic=mUserinfo.apic,
                    nickname=mUserinfo.nickname,
                    aname = mUserinfo.alliancename,
                    level=mUserinfo.level,
                    fc=mUserinfo.fc,
                    troops=fleet,
                    binfo=troopsInfo,
                }
            }
            
            if not self.serverRequest(data) then
                return false, -27029
            end
        end
        
        self.bid = bid
        self.troops = fleet
        self.binfo = troopsInfo

        return true
    end

    --[[
        获取部队数据
        玩家会有探索buff影响战斗属性，调用后不能保存

        param bool portBuff 是否有港口BUFF(3位攻击)
    ]]
    function self.getTroops(buffId,portBuff)
        if next (self.troops) then
            if buffId then
                local buffCfg = getConfig("greatRoute").buff[buffId]
                if buffCfg.attType then
                    canSaveFlag = false

                    local n2attrCfg = getConfig("common").attrNumForAttrStr
                    for k,v in pairs(self.binfo) do
                        if next(v) then
                            for attrKey,attrName in pairs(buffCfg.attType) do
                                attrName = n2attrCfg[attrName]
                                if buffCfg.type == 1 then
                                    v[attrName] = v[attrName] * (1 + buffCfg.att[attrKey])
                                else
                                    v[attrName] = v[attrName] * (1 - buffCfg.att[attrKey])
                                end

                                -- 属性变更后重新计算血量
                                v.maxhp = math.floor(v.maxhp)
                                v.hp   = v.maxhp * v.num
                            end
                        end
                    end
                end
            end

            if portBuff then
                canSaveFlag = false
                for k,v in pairs(self.binfo) do
                    if v.dmg then
                        v.dmg = v.dmg * 3
                    end
                end
            end

            return self.troops, self.binfo
        end
    end

    return self
end

return model_tgreatroute
