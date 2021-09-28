require "ui.drawrole.drawroledlg"
require "ui.drawrole.drawrolereminder"

DrawRoleManager = {}
DrawRoleManager.__index = DrawRoleManager


----------------------- singleton --------------------

local _instance;
function DrawRoleManager.getInstance()
    if not _instance then
        _instance = DrawRoleManager:new()
    end

    return _instance
end

function DrawRoleManager:getInstanceNotCreate( )
    return _instance
end

function DrawRoleManager.removeInstance()
	_instance = nil
end

function DrawRoleManager.Destroy()
    if _instance then 
        LogInfo("DrawRoleManager Destroy")
        _instance = nil
    end
end
-----------------------------------------------------

function DrawRoleManager:new()
    local self = {}
    setmetatable(self, DrawRoleManager)

    self.m_activityList = {}
    self.m_currId = 0

    self.m_sortFunc = function(a, b) return a.time < b.time end

    return self
end

function DrawRoleManager:drawRole( id )
    local record = BeanConfigManager.getInstance():GetTableByName("knight.gsp.game.claren"):getRecorder(id);
    if not record then
        record = BeanConfigManager.getInstance():GetTableByName("knight.gsp.game.claren"):getRecorder(1);
    end
    if record then
        self:setInfo(id, record.time, record.content)
       	self:showDetailById(id)     
    end
end

function DrawRoleManager:run( delta )
    for i,v in ipairs(self.m_activityList) do
        local old = math.floor(v.time)
        v.time = v.time - delta * 0.001
        if v.time < 0 then
            self:removeInfoById(v.id)
            return
        end
        if v.time < old and self.m_currId == v.id then
            DrawRoleDlg:getInstance():setTime(old - 1)
        end
    end
    if DrawRoleReminder:getInstanceNotCreate() then
        DrawRoleReminder:getInstance():run(delta)
    end
end

function DrawRoleManager:showDetailById( id ) --显示详细内容
    for i,v in ipairs(self.m_activityList) do
        if v.id == id then
            local dlg = DrawRoleDlg:getInstanceAndShow()
            dlg:setText(v.content)
            dlg:setTime(math.floor(v.time))
            self.m_currId = id
            self:updateReminder()
	    
	    if GetBattleManager():IsInBattle() then
            	self:hideDetail()
	    end
	    return
        end
    end
end

function DrawRoleManager:showDetailAtBtn( index ) --显示详细内容
    local currIndex = self:getIndexById(self.m_currId)
    if currIndex ~= 0 and currIndex <= index then
        index = index + 1
    end

    self.m_currId = self.m_activityList[index].id
    local v = self.m_activityList[index]
    local dlg = DrawRoleDlg:getInstanceAndShow()
    dlg:setText(v.content)
    dlg:setTime(math.floor(v.time))
    self:updateReminder()
end

function DrawRoleManager:hideDetail( ) --点击稍后按钮
    self.m_currId = 0
    DrawRoleDlg:getInstance():SetVisible(false)
    DrawRoleReminder:getInstance():startAnimation()
end

function DrawRoleManager:setInfo( id, time, content )
    for i,v in ipairs(self.m_activityList) do
        if v.id == id then  --already in the list, update
            v.time = time
            v.content = content

            table.sort(self.m_activityList, self.m_sortFunc)
            return
        end
    end

    table.insert(self.m_activityList, {["id"] = id, ["time"] = time, ["content"] = content})
    table.sort(self.m_activityList, self.m_sortFunc)
end

function DrawRoleManager:removeInfoById( id )
    if self.m_currId == id then
        self.m_currId = 0
        DrawRoleDlg:getInstance():SetVisible(false)
    end
    for i,v in ipairs(self.m_activityList) do
        if v.id == id then 
            table.remove(self.m_activityList, i)
            break
        end
    end
    table.sort(self.m_activityList, self.m_sortFunc)
    self:updateReminder()
end

function DrawRoleManager:updateReminder( )
    local num = table.maxn(self.m_activityList)
    if num == 0 then
        DrawRoleDlg:DestroyDialog()
        DrawRoleReminder:DestroyDialog()
        return
    end
    if self.m_currId ~= 0 then
        num = num - 1
    end
    DrawRoleReminder:getInstance():setBtnNum(num)
end

function DrawRoleManager:drawAccepted()
    if self.m_currId == 0 then
        LogErr("DrawRoleManager drawAccepted error")
    end

    local p = require "protocoldef.knight.gsp.faction.cagreedrawrole" : new()
    p.agree = 1 
    p.flag = self.m_currId
    require "manager.luaprotocolmanager":send(p)
    DrawRoleDlg:getInstance():SetVisible(false)
    self:removeInfoById( self.m_currId )
end

function DrawRoleManager:drawCancel()
    if self.m_currId == 0 then
        LogErr("DrawRoleManager drawCancel error")
    end
    local p = require "protocoldef.knight.gsp.faction.cagreedrawrole" : new()
    p.agree = 0 
    p.flag = self.m_currId
    require "manager.luaprotocolmanager":send(p)
    DrawRoleDlg:getInstance():SetVisible(false)
    self:removeInfoById( self.m_currId )
end

function DrawRoleManager:getIndexById( id )
    if id == 0 then return 0 end
    for i,v in ipairs(self.m_activityList) do
        if v.id == id then
            return i
        end
    end
    return 0
end

return DrawRoleManager
