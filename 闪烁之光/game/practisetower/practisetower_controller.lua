-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--新人练武场
-- @author: xhj@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2020-4-09
-- --------------------------------------------------------------------
PractisetowerController = PractisetowerController or BaseClass(BaseController)

function PractisetowerController:config()
    self.model = PractisetowerModel.New(self)
    self.dispather = GlobalEvent:getInstance()
end

function PractisetowerController:getModel()
    return self.model
end

function PractisetowerController:registerEvents()
end

function PractisetowerController:registerProtocals()
    self:RegisterProtocal(29100, "handle29100")     --查看活动信息
    self:RegisterProtocal(29101, "handle29101")     --挑战Boss
    self:RegisterProtocal(29102, "handle29102")     --战斗结果
    self:RegisterProtocal(29103, "handle29103")     --重新挑战
    self:RegisterProtocal(29104, "handle29104")     --购买挑战次数
    self:RegisterProtocal(29105, "handle29105")     -- 查看排行榜
    self:RegisterProtocal(29106, "handle29106")     -- 当前自身排名
    self:RegisterProtocal(29107, "handle29107")     -- 日志上报
    
end


--打开主界面
function PractisetowerController:openMainView(bool)
    if bool == false then
        if self.main_view ~= nil then
            self.main_view:close()
            self.main_view = nil
        end
    else
        if not self.main_view then 
            self.main_view = PractiseTowerWindow.New()
        end
        if self.main_view and self.main_view:isOpen() == false then
            self.main_view:open()
        end
    end
end

--打开排行总览
function PractisetowerController:openRankWindow(bool)
    if bool == true then
        if not self.rank_window then 
            self.rank_window = PractisetowerRankWindow.New()
        end
        if self.rank_window and self.rank_window:isOpen() == false then
            self.rank_window:open()
        end

    else 
        if self.rank_window then 
            self.rank_window:close()
            self.rank_window = nil
        end
    end
end

--打开结算界面
function PractisetowerController:openResultWindow(bool,data)
    if bool == true then
        if not self.result_window then 
            self.result_window = PractiseTowerResultWindow.New(data.flag, BattleConst.Fight_Type.PractiseTower)
        end
        if self.result_window and self.result_window:isOpen() == false then
            self.result_window:open(data, BattleConst.Fight_Type.PractiseTower)
        end
    else 
        if self.result_window then 
            self.result_window:close()
            self.result_window = nil
        end
    end
end



--查看活动信息
function PractisetowerController:sender29100()
    self:SendProtocal(29100,{})
end
function PractisetowerController:handle29100( data )
    self.model:setPractiseTowerData(data)
end

--购买挑战次数
function PractisetowerController:sender29104()
    local protocal ={}
    self:SendProtocal(29104,protocal)
end
function PractisetowerController:handle29104( data )
    local touchData = self.model:getIsTouchFight()
    if data.flag == 1 and touchData ~= nil and touchData.id ~= nil and touchData.power ~= nil then
        local setting = {}
        setting.select_base_id = touchData.id
        setting.is_send = false
        setting.power = touchData.power
        HeroController:getInstance():openFormGoFightPanel(true, PartnerConst.Fun_Form.PractiseTower,setting)
        self.model:setIsTouchFight(nil)
    end
    message(data.msg)
end

--挑战Boss
function PractisetowerController:sender29101(id,formation_type,pos_info,hallows_id)
    local protocal ={}
    protocal.id = id
    protocal.formation_type = formation_type
    protocal.pos_info = pos_info
    protocal.hallows_id = hallows_id
    self:SendProtocal(29101,protocal)
end
function PractisetowerController:handle29101( data )
    message(data.msg)
end

--战斗结果
function PractisetowerController:handle29102( data )
    BattleController:getInstance():openFinishView(true, BattleConst.Fight_Type.PractiseTower, data)
end

--重新挑战
function PractisetowerController:sender29103()
    local protocal ={}
    self:SendProtocal(29103,protocal)    
end
function PractisetowerController:handle29103( data )
    message(data.msg)
    local reset_data = self.model:getResetFightId()
    if data.flag == 1 and reset_data and reset_data.id~=nil and reset_data.power~=nil then
        HeroController:getInstance():openFormGoFightPanel(false)
        local setting = {}
        setting.select_base_id = reset_data.id
        setting.is_send = true
        setting.power = reset_data.power
        HeroController:getInstance():openFormGoFightPanel(true, PartnerConst.Fun_Form.PractiseTower,setting)	
        self:openResultWindow(false)	
    end
    self.model:setResetFightId(nil)
end

function PractisetowerController:sender29105()
    self:SendProtocal(29105,{})
end
function PractisetowerController:handle29105(data)
    GlobalEvent:getInstance():Fire(PractisetowerEvent.Update_Top3_rank, data)
end

function PractisetowerController:handle29106(data)
    self.model:updateMyRank(data)
end

--日志上报
function PractisetowerController:sender29107(type)
    local protocal ={}
    protocal.type = type
    self:SendProtocal(29107,protocal)
end
function PractisetowerController:handle29107(data)
    
end


function PractisetowerController:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end