-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: xxx@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-09-04
-- --------------------------------------------------------------------
Stone_dungeonModel = Stone_dungeonModel or BaseClass()
local table_insert = table.insert
local change_num = Config.DungeonStoneData.data_type_open
function Stone_dungeonModel:__init(ctrl)
    self.ctrl = ctrl
    self:config()
end

function Stone_dungeonModel:config()
	self.change_count = {}
    self.passClearanceId = {}
end
--通关的副本ID
function Stone_dungeonModel:setPassClearanceID(data)
    if data and next(data) ~= nil then
        for i,v in pairs(data) do
            self.passClearanceId[v.id] = {status = 1}
        end
    end 
end
function Stone_dungeonModel:getPassClearanceID(id)
    if not self.passClearanceId then return nil end
    return self.passClearanceId[id]
end
--今天已挑战/扫荡次数
function Stone_dungeonModel:setChangeSweepCount(data)
    if data and next(data) ~= nil then
        for i,v in pairs(data) do
            if v and v.type and v.day_num then
                self.change_count[v.type] = v.day_num
            end
        end
    end
    local status = self:checkRedStatus()
    MainuiController:getInstance():setBtnRedPoint(MainuiConst.btn_index.esecsice, {bid=RedPointType.dungeonstone, status=status}) 
end
function Stone_dungeonModel:getChangeSweepCount(dup_type)
    if self.change_count and self.change_count[dup_type] then
        return self.change_count[dup_type] or 0
    end
    return 0
end
--==============================--
--desc:宝石副本红点
--time:2018-09-11 12:45:33
--@return 
--==============================--
function Stone_dungeonModel:checkRedStatus()
    local type_open = Config.DungeonStoneData.data_type_open
    if type_open and type_open[1] and type_open[1].activate then
        local bool = MainuiController:getInstance():checkIsOpenByActivate(type_open[1].activate)
        if bool == false then return false end
        if not self.change_count then return end
        local length = Config.DungeonStoneData.data_type_open_length
        for i=1,length do
            local bool = MainuiController:getInstance():checkIsOpenByActivate(type_open[i].activate) or false
            local count = self.change_count[i] or 0
            if count < 2 and bool == true then
                return true
            end
        end
        return false
    end
    return false
end

function Stone_dungeonModel:__delete()
end
