-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: xhj(必填, 创建模块的人员)
-- @editor: xhj(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2019-10-10
-- --------------------------------------------------------------------
EncounterModel = EncounterModel or BaseClass()


function EncounterModel:__init(ctrl)
    self.ctrl = ctrl
    self.finishArr = {}
    self.is_show_red = false
    self:config()
end

function EncounterModel:config()
    self.encounter_id = 0 --冒险奇遇id
    self.encounter_page = 0 --对话步数
end

function EncounterModel:setEncounterInfo(data)
    if self.encounter_id~=0 then
        table.insert( self.finishArr, {id = self.encounter_id})
    end
    self.encounter_id = data.id
    self.encounter_page = data.page
    self:updateRedStatus()
end


function EncounterModel:getEncounterId()
    return self.encounter_id 
end

function EncounterModel:setEncounterPage(page)
    if self.encounter_id>0 then
        self.encounter_page  = page
    end
end

function EncounterModel:getEncounterPage()
    return self.encounter_page 
end

function EncounterModel:setEncounterFinishInfo(list)
    self.finishArr = list
end

function EncounterModel:isFinishByid( id )
    for i,v in pairs(self.finishArr) do
        if v and v.id == id then
            return true
        end
    end
    return false
end

--更新红点
function EncounterModel:updateRedStatus()
    local is_show_red = false
    if self.encounter_id >0 then
        is_show_red = true
    end
    self.is_show_red = is_show_red
    GlobalEvent:getInstance():Fire(EncounterEvent.UPDATA_RED_STATUS ,is_show_red)
    BattleDramaController:getInstance():getModel():checkRedPoint()--刷新出击红点
end

function EncounterModel:getRedStatus()
    return self.is_show_red
end

function EncounterModel:__delete()
end