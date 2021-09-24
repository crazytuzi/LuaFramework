-- 军团活动
local function model_allianceactive(self)
    -- 固定写法 ------------
    local private = {
        dbData={ -- 初始化的数据
            aid=0,
            info={},
            updated_at=0,
        },
        pkName = "aid", -- 主键名
        tableName = "allianceactive", -- 表名
    }

    self._initPrivate(private)

    local activeObj = {}

    -- ----------------

    -- 过期检测
    -- 活动结束7天后删除
    local function expireCheck()
        local expire = getClientTs() - 604800

        for k,v in pairs(self.info) do
            if v.et < expire then
                self.info[k] = nil
            end
        end
    end

    function self.init()
        expireCheck()

        require 'model.active'
        local mActive = model_active()
        local actives = mActive.toArray(true)
        local ts = getClientTs()
        local newActive=getConfig('newActive')
        local activeCfg

        if type(actives) == 'table' then
            for k,v in pairs(actives) do
                activeCfg = newActive[k] and getConfig("active/"..k)
                if activeCfg and activeCfg._isAllianceActivity then
                    local flag
                    if not self.info[k] then
                        flag = true
                    elseif type(self.info[k]) == 'table' then
                        if tonumber(v.st)<ts then
                            -- 起始与结束时间都不一致
                            if self.info[k].st ~= tonumber(v.st) and self.info[k].et ~= tonumber(v.et) then
                                flag = true

                            -- 多配置文件活动，配置号变动需要重置
                            elseif activeCfg.multiSelectType and self.info[k].cfg and tonumber(self.info[k].cfg) ~= tonumber(v.cfg) then
                                flag = true
                            end
                        end  
                        self.info[k].et = tonumber(v.et) or 0
                    end
                    
                    if flag then
                        -- self.info[k] = ( self.aid > 0 and type(initFunc[k]) == "function" ) and initFunc[k](activeCfg[tonumber(v.cfg)]) or {}
                        self.info[k] = {
                            st = tonumber(v.st) or 0,
                            et = tonumber(v.et) or 0,

                        }

                        if activeCfg.multiSelectType then
                            self.info[k].cfg = tonumber(v.cfg)
                        end


                        regEventAfterSave(self.aid,'saveAllianceActive')
                    end
                end
            end
        end
    end

    function self.toArray()
        return self._getData()
    end

    function self.saveData()
        if self.aid > 0 then
            return self._save()
        end
    end

    function self.getActiveConfig(acname)
        local activeCfg = nil
        if self.info[acname].cfg then
            activeCfg = getConfig("active/" .. acname)[self.info[acname].cfg]
        else
            activeCfg = getConfig("active/" .. acname)
        end

        return activeCfg
    end

    function self.getActiveObj(activeName)
        if not activeObj[activeName] then
            local activeInfo = self.info[activeName]
            local activeCfg = self.getActiveConfig(activeName)
            activeObj[activeName] = require("model.active."..activeName).new(self.aid,activeName,activeInfo,activeCfg)
        end 

        return activeObj[activeName]
    end

    return self
end

return model_allianceactive