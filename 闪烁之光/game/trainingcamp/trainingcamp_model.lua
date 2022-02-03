-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: xhj(必填, 创建模块的人员)
-- @editor: xhj(必填, 后续维护以及修改的人员)
-- @description:
--      新手训练营
-- <br/>Create: 2019-11-06
-- --------------------------------------------------------------------
TrainingcampModel = TrainingcampModel or BaseClass()

function TrainingcampModel:__init(ctrl)
    self.ctrl = ctrl
    self.isFinish = false -- 是否完成新手初阶训练
    self.finish_ids = {}
    self:config()
end

function TrainingcampModel:config()
end

function TrainingcampModel:setInfo(data)
    if data == nil then
        return
    end
    if data.flag == 1 then
        self.isFinish = true
    else
        self.isFinish = false
    end
    self.finish_ids = data.ids
end

--是否完成新手初阶训练
function TrainingcampModel:getIsFinish()
    return self.isFinish
end

--是否完成新手所有训练
function TrainingcampModel:getIsALLFinish()
    local status = true
    if Config.TrainingCampData and Config.TrainingCampData.data_info then
        for i,v in ipairs(Config.TrainingCampData.data_info) do
            if self:IsFinishById(v.id) == false then
                status =  false
                break
            end
        end
    end
    return status
end


--是否完成对应Id训练
function TrainingcampModel:IsFinishById(id)
    local isFinish = false
    for i,v in ipairs(self.finish_ids) do
        if v.id == id then
            isFinish = true
        end
    end
    return isFinish
end

function TrainingcampModel:__delete()
end