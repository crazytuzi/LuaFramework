-- --------------------------------------------------------------------
-- 服务端过来的建筑信息数据
-- 
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @editor: shiraho@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2017-xx-xx
-- --------------------------------------------------------------------
BuildVo = BuildVo or BaseClass(EventDispatcher)

BuildVo.Update_self_event = "BuildVo.Update_self_event"

BuildVo.status_type = {
    LOCK = 0,
    UNLOCK = 1
}

function BuildVo:__init(config, is_lock, activate, desc, is_verifyios)
    self.config = config                    -- 配置数据，存放在mainscene_data中
    self.is_lock = is_lock                  -- 没有通关指定的剧情副本，则为锁定状态
    self.activate = activate                -- 开启条件
    self.tips_list = {}                     -- 红点状态，因为一个建筑可能有多个红点状态
    self.tips_status = false                -- 是否有红点
    self.desc = desc
    self.in_fight = false
    self.fight_status_list = {}
    self.is_verifyios  = is_verifyios or 1  -- ios提审服标识

    self.group_id = 0                       -- 召唤那边特殊处理的
end

function BuildVo:setLockStatus(status)
    if self.is_lock ~= status then
        self.is_lock = status
        self:Fire(BuildVo.Update_self_event, "lock_status")
    end
end

function BuildVo:setTipsStatus(data)
    local need_update = false
    if data == nil then
        data = not self.tips_status
    end
    if type(data) == "table" then
        if data.bid ~= nil then
            if self.tips_list[data.bid] ~= data.status then
                need_update = true
                self.tips_list[data.bid] = data.status
            end
        else
            for k, v in pairs(data) do
                if v.bid ~= nil then
                    if  self.tips_list[v.bid] ~= v.status then
                        need_update = true
                        self.tips_list[v.bid] = v.status
                    end
                end
            end
        end
    else
        if self.tips_status ~= data then
            need_update = true
            self.tips_status = data
        end
    end 
    if need_update == true then
        self:Fire(BuildVo.Update_self_event, "tips_status")
    end
end

--==============================--
--desc:清空所有红点状态
--time:2018-06-07 10:06:16
--@return 
--==============================--
function BuildVo:clearTipsStatus()
    local need_update = false
    for k,v in pairs(self.tips_list) do
        if v == true then
            need_update = true 
            break
        end
    end
    if self.tips_status == true then
        need_update = true
    end
    self.tips_status = false
    self.tips_list = {}
    if need_update == true then
        self:Fire(BuildVo.Update_self_event, "tips_status")
    end 
end

--- 设置战斗状态
function BuildVo:setFightStatus(status_list)
    local old_status = false
    for k,v in pairs(self.fight_status_list) do
        if v == true then
            old_status = true
            break
        end
    end

    local cur_status = false
    for k,v in pairs(status_list) do
        if v == true then
            cur_status = true
            break
        end
    end
    if old_status == cur_status then return end
    self.fight_status_list = status_list 
    self:Fire(BuildVo.Update_self_event, "fight_status")
end

function BuildVo:setSpecialGroupId(id)
     if self.group_id ~= id then
        self.group_id = id
        self:Fire(BuildVo.Update_self_event, "group_id")
    end
end

function BuildVo:getFightStatus()
    for k,v in pairs(self.fight_status_list) do
        if v == true then
            return true
        end
    end
    return false
end

function BuildVo:getTipsStatus()
	for k, status in pairs(self.tips_list) do
		if status == true then
			return true
		end
	end
	return self.tips_status
end

function BuildVo:__datale()
end