-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: liwenchuang@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      神殿玩法  策划:星宇 后端:爵爷 
-- <br/>Create: 2018-10-26
-- --------------------------------------------------------------------
PrimusController = PrimusController or BaseClass(BaseController)

function PrimusController:config()
    self.model = PrimusModel.New(self)
    self.dispather = GlobalEvent:getInstance()
end

function PrimusController:getModel()
    return self.model
end

function PrimusController:registerEvents()
end

function PrimusController:registerProtocals()
    self:RegisterProtocal(20700, "handle20700")     --请求玩家挑战次数
    self:RegisterProtocal(20701, "handle20701")     --请求挑战位置信息
    self:RegisterProtocal(20702, "handle20702")     --请求发起挑战
    self:RegisterProtocal(20703, "handle20703")     --请求挑战记录
    self:RegisterProtocal(20705, "handle20705")     --请求挑战结束
    self:RegisterProtocal(20706, "handle20706")     --每天第一次登录的红点
end

 --请求玩家挑战次数
function PrimusController:requestPrimusChallengeCount()
    local protocal ={}
    self:SendProtocal(20700,protocal)
end

function PrimusController:handle20700(data)
    self.model:showPrimusRedPoint()
    GlobalEvent:getInstance():Fire(PrimusEvent.Updata_Primus_RedPoint)
end

--请求挑战位置信息
function PrimusController:sender20701()
    local protocal ={}
    self:SendProtocal(20701,protocal)
end

function PrimusController:handle20701(data)
    if data and self.primus_main_window then
        self.primus_main_window:setData(data)
    end
end

--请求发起挑战
function PrimusController:sender20702(pos, num)
    local protocal ={}
    protocal.pos = pos
    protocal.num = num
    self:SendProtocal(20702, protocal)
end

function PrimusController:handle20702(data)
    message(data.msg)
    if data.code == TRUE then
        self:openPrimusChallengePanel(false)
    end
end
--请求挑战记录
function PrimusController:sender20703(pos)
    local protocal ={}
    protocal.pos = pos
    self:SendProtocal(20703, protocal)
end

function PrimusController:handle20703(data)
    -- message(data.msg)
    self:openPrimusChallengeRecordPanel(true, data)
end
--战斗结果
function PrimusController:handle20705(data)
    -- message(data.msg)
    self:openPrimusChallengeResultWindow(true, data)
end


function PrimusController:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end

--- 打开荣耀神殿主角界面
function PrimusController:openPrimusMainWindow(status)
    if status == false then
        if self.primus_main_window ~= nil then
            self.primus_main_window:close()
            self.primus_main_window = nil
        end
    else
        local open_data = Config.DailyplayData.data_exerciseactivity[EsecsiceConst.exercise_index.honourfane]
        if open_data == nil then 
            message(TI18N("星河神殿数据异常"))
            return 
        end

        local bool = MainuiController:getInstance():checkIsOpenByActivate(open_data.activate)
        if bool == false then 
            message(open_data.lock_desc)
            return 
        end

        self.model.is_show_redpoint = false
        if self.primus_main_window == nil then
            self.primus_main_window = PrimusMainWindow.New()
        end
        self.primus_main_window:open()
    end
end
--- 打开荣耀神殿挑战界面
function PrimusController:openPrimusChallengePanel(status, data, is_have_title)
    if status == false then
        if self.primus_challenge_panel ~= nil then
            self.primus_challenge_panel:close()
            self.primus_challenge_panel = nil
        end
    else
        if self.primus_challenge_panel == nil then
            self.primus_challenge_panel = PrimusChallengePanel.New()
        end
        self.primus_challenge_panel:open(data, is_have_title)
    end
end


--- 打开荣耀神殿挑战界面
function PrimusController:openPrimusChallengeRecordPanel(status, data)
    if status == false then
        if self.primus_challenge_record_panel ~= nil then
            self.primus_challenge_record_panel:close()
            self.primus_challenge_record_panel = nil
        end
    else
        if self.primus_challenge_record_panel == nil then
            self.primus_challenge_record_panel = PrimusChallengeRecordPanel.New()
        end
        self.primus_challenge_record_panel:open(data)
    end
end
--- 打开荣耀神殿挑战结果
function PrimusController:openPrimusChallengeResultWindow(status, data)
    if status == false then
        if self.primus_challenge_result_window ~= nil then
            self.primus_challenge_result_window:close()
            self.primus_challenge_result_window = nil
        end
    else
        if self.primus_challenge_result_window == nil then
            self.primus_challenge_result_window = PrimusChallengeResultWindow.New()
        end
        self.primus_challenge_result_window:open(data)
    end
end

-- 判断是否开启星河神殿
function PrimusController:checkIsCanOpenPrimusWindow(  )
    local role_vo = RoleController:getInstance():getRoleVo()
    local lev = role_vo and role_vo.lev or 0
    local limit_lev = Config.PrimusData.data_const.open_lev.val
    if lev < limit_lev then
        message(string.format(TI18N("等级达到%s级开启\"星河神殿\"玩法"), limit_lev))
        return false
    end
    return true
end

--红点
function PrimusController:sender20706()
    self:SendProtocal(20706, {})
end
function PrimusController:handle20706(data)
    local status = false
    if data.is_show == 1 then
        status = true
    end
    self.model:setFirstLogin(status)
    GlobalEvent:getInstance():Fire(PrimusEvent.Updata_Primus_RedPoint)
end