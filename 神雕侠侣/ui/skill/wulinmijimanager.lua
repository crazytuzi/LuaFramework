-- wulinmijimanager.lua
-- It the a manager for wulinmiji
-- create by wuyao in 2014-3-10

WulinmijiManager = {}
WulinmijiManager.__index = WulinmijiManager

-- For singleton
local _instance
function WulinmijiManager.getInstance()
    if not _instance then
        _instance = WulinmijiManager:new()
    end
    
    return _instance
end

function WulinmijiManager.getInstanceNotCreate()
    return _instance
end

function WulinmijiManager.Destroy()
    if _instance then 
        _instance = nil
    end
end

function WulinmijiManager:new()
    local self = {}
    setmetatable(self, WulinmijiManager)

    self.m_iRoleSchool = nil
    self.m_iLeftPoint = 0
    self.m_iCurPoint = 0
    self.m_iJingjie = 0
    self.m_vSkillTable = nil
    self.m_iMijiID = 0
    self.m_iMijiGrade = 0
    self.m_iMijiFloor = 0
    self.m_iJingjieSum = 0

    self:InitBaseData()
    self:RequireData()
    return self
end

-- Init the skill table with defalut data (all none)
-- @return : no return
function WulinmijiManager:InitBaseData()
    -- Get school
    self.m_iRoleSchool = GetDataManager():GetMainCharacterSchoolID()
    -- Get base skill table
    self.m_vSkillTable = {}
    local luaUtil = require "utils.tableutil"
    local wholeSkillID = BeanConfigManager.getInstance():GetTableByName("knight.gsp.skill.cwulinmijiskill"):getDisorderAllID()
    for k,v in pairs(wholeSkillID) do
        local record = BeanConfigManager.getInstance():GetTableByName("knight.gsp.skill.cwulinmijiskill"):getRecorder(v)
        if record.skilllevel == 0 and record.skillgrade == 1 and record.menpai == self.m_iRoleSchool then
            self.m_vSkillTable[record.position] = {}
            self.m_vSkillTable[record.position].id = record.id
            self.m_vSkillTable[record.position].level = 0
            self.m_vSkillTable[record.position].curPoint = 0
        end
    end
    -- Get the base miji
    local wholeSpecialSkillID = BeanConfigManager.getInstance():GetTableByName("knight.gsp.skill.cwulinmijispecial"):getDisorderAllID()
    for k,v in pairs(wholeSpecialSkillID) do
        local record = BeanConfigManager.getInstance():GetTableByName("knight.gsp.skill.cwulinmijispecial"):getRecorder(v)
        if record.skillgrade == 0 and record.menpai == self.m_iRoleSchool then
            self.m_iMijiID = record.id
            self.m_iMijiGrade = 0
            self.m_iMijiFloor = 0
        end
    end
end

-- Require the data
-- @return : no return
function WulinmijiManager:RequireData(skillid, point)
    local req = require "protocoldef.knight.gsp.skill.cgetwulinskills".Create()
    LuaProtocolManager.getInstance():send(req)
    req = require "protocoldef.knight.gsp.skill.cgetjingjieinfo".Create()
    LuaProtocolManager.getInstance():send(req)
    req = require "protocoldef.knight.gsp.skill.cgetmijiinfo".Create()
    LuaProtocolManager.getInstance():send(req)
end

-- Refresh data when receive data from server
-- @param SGetWulinSkills : SGetWulinSkills protocol
-- @param SGetJingjieInfo : SGetJingjieInfo protocol
-- @param SGetMijiInfo : SGetMijiInfo protocol
-- @param SOpenMijiDlg : SOpenMijiDlg protocol
-- @return : no return
function WulinmijiManager:RefreshDataFromServer(SGetWulinSkills, SGetJingjieInfo, SGetMijiInfo, SOpenMijiDlg)
    if SGetWulinSkills ~= nil then
        for k,v in pairs(SGetWulinSkills.skills) do
            local curRecord = BeanConfigManager.getInstance():GetTableByName("knight.gsp.skill.cwulinmijiskill"):getRecorder(v.skillid)
            self.m_vSkillTable[curRecord.position].id = v.skillid
            self.m_vSkillTable[curRecord.position].level = v.level
            self.m_vSkillTable[curRecord.position].curPoint = v.curpoint
        end
    end

    if SGetJingjieInfo ~= nil then
        self.m_iCurPoint = SGetJingjieInfo.curpoint
        self.m_iJingjie = SGetJingjieInfo.hierarchy
        self.m_iJingjieSum = SGetJingjieInfo.hierarchypoint
    end

    if SGetMijiInfo ~= nil then
        if SGetMijiInfo.miji.id ~= 0 then
            self.m_iMijiID = SGetMijiInfo.miji.id
            self.m_iMijiGrade = SGetMijiInfo.miji.level
            self.m_iMijiFloor = SGetMijiInfo.miji.floor
        end
    end

    if SOpenMijiDlg ~= nil then
        if SOpenMijiDlg.miji.id ~= 0 then
            self.m_iMijiID = SOpenMijiDlg.miji.id
            self.m_iMijiGrade = SOpenMijiDlg.miji.level
            self.m_iMijiFloor = SOpenMijiDlg.miji.floor
            self.m_iJingjieSum = SOpenMijiDlg.hierarchypoint
        end
        self.m_iJingjie = SOpenMijiDlg.hierarchy
        for k,v in pairs(SOpenMijiDlg.skills) do
            local curRecord = BeanConfigManager.getInstance():GetTableByName("knight.gsp.skill.cwulinmijiskill"):getRecorder(v.skillid)
            self.m_vSkillTable[curRecord.position].id = v.skillid
            self.m_vSkillTable[curRecord.position].level = v.level
            self.m_vSkillTable[curRecord.position].curPoint = v.curpoint
        end
    end
end

-- Require to study
-- @param skillid : skillid to study
-- @param point : how many point to add
-- @return : no return
function WulinmijiManager:RequireStudy(skillid, point)
    local req = require "protocoldef.knight.gsp.skill.clearnwulinskill".Create()
    req.skillid = skillid
    req.point = point
    LuaProtocolManager.getInstance():send(req)
end

-- Require to shengji miji
-- @return : no return
function WulinmijiManager:RequireMijiShengji()
    local req = require "protocoldef.knight.gsp.skill.clearnmiji".Create()
    print(self.m_iMijiID)
    req.skillid = self.m_iMijiID
    req.learntype = 2
    LuaProtocolManager.getInstance():send(req)
end

-- Require to tupo miji
-- @return : no return
function WulinmijiManager:RequireMijiTupo()
    local req = require "protocoldef.knight.gsp.skill.clearnmiji".Create()
    print(self.m_iMijiID)
    req.skillid = self.m_iMijiID
    req.learntype = 1
    LuaProtocolManager.getInstance():send(req)
end

-- Get the skill table of wulinmiji
-- @return : a table with wulinmiji skill data, key is position, valus is id
function WulinmijiManager:GetSkillTable()
	return self.m_vSkillTable
end

-- Get the point current number of wulinmiji
-- @return : a table with wulinmiji skill data, key is position, valus is id
function WulinmijiManager:GetCurPoint()
    return self.m_iCurPoint
end

-- Get the special miji info
-- @return : a table with wulinmiji skill data, key is position, valus is id
function WulinmijiManager:GetMijiInfo()
    local mijiInfo = {}
    mijiInfo.id = self.m_iMijiID
    mijiInfo.level = self.m_iMijiGrade
    mijiInfo.floor = self.m_iMijiFloor
    return mijiInfo
end

-- Get the jingjie
-- @return : a num of jingjie
function WulinmijiManager:GetJingjie()
    return self.m_iJingjie
end

-- Get the jingjie point sum
-- @return : a num of jingjie
function WulinmijiManager:GetJingjieSum()
    return self.m_iJingjieSum
end

return WulinmijiManager