-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: xhj(必填, 创建模块的人员)
-- @editor: xhj(必填, 后续维护以及修改的人员)
-- @description:
--      冒险奇遇
-- <br/>Create: 2019-10-10
-- --------------------------------------------------------------------
EncounterController = EncounterController or BaseClass(BaseController)

function EncounterController:config()
    self.model = EncounterModel.New(self)
    self.dispather = GlobalEvent:getInstance()
end

function EncounterController:getModel()
    return self.model
end

function EncounterController:registerEvents()
end

function EncounterController:registerProtocals()
    self:RegisterProtocal(27100, "handle27100") -- 基础信息
    self:RegisterProtocal(27101, "handle27101") -- 奖励领取
    self:RegisterProtocal(27102, "handle27102") -- 图鉴冒险奇遇
    self:RegisterProtocal(27103, "handle27103") -- 奇遇翻页记录
    self:RegisterProtocal(27104, "handle27104") -- 奇遇答题选项
end

--协议相关
function EncounterController:send27100()
    local protocol = {}
    self:SendProtocal(27100, protocol)
end

function EncounterController:handle27100(data)
    if data then
        self.model:setEncounterInfo(data)
    end
end

function EncounterController:send27101()
    local protocol = {}
    self:SendProtocal(27101, protocol)
end

function EncounterController:handle27101(data)
    if data then
        message(data.msg)
    end
end

function EncounterController:send27102()
    local protocol = {}
    self:SendProtocal(27102, protocol)
end

function EncounterController:handle27102(data)
    self.model:setEncounterFinishInfo(data.id_list)
    GlobalEvent:getInstance():Fire(EncounterEvent.CHECK_SHOW_LIBRARY_ENCOUNTER,data.id_list)
end

function EncounterController:send27103(id,page)
    local protocol = {}
    protocol.id = id
    protocol.page = page
    self:SendProtocal(27103, protocol)
end

function EncounterController:handle27103(data)
    
end

function EncounterController:send27104(choice)
    local protocol = {}
    protocol.choice = choice
    self:SendProtocal(27104, protocol)
end

function EncounterController:handle27104(data)
    if data then
        message(data.msg)
    end
end

--打开界面相关--
--[[
    @desc: 
    author:{author}
    --@status: 打开主界面
    @return:
]]
function EncounterController:openEncounterWindow(status,id)
    if status == true then
        if not self.encounter_window then
            self.encounter_window = EncounterWindow.New()
        end
        if self.encounter_window and self.encounter_window:isOpen() == false then
            self.encounter_window:open(id)
        end
    else 
        if self.encounter_window then 
            self.encounter_window:close()
            self.encounter_window = nil
        end
    end
end

--[[
    @desc: 
    author:{author}
    --@status: 打开物语图鉴界面
    @return:
]]
function EncounterController:openEncounterLibraryWindow(status)
    if status == true then
        if not self.encounter_library_window then
            self.encounter_library_window = EncounterLibraryWindow.New()
        end
        if self.encounter_library_window and self.encounter_library_window:isOpen() == false then
            self.encounter_library_window:open()
        end
    else 
        if self.encounter_library_window then 
            self.encounter_library_window:close()
            self.encounter_library_window = nil
        end
    end
end

function EncounterController:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end