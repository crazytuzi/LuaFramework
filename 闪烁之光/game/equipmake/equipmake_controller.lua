-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: xxx@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-07-26
-- --------------------------------------------------------------------
EquipmakeController = EquipmakeController or BaseClass(BaseController)

function EquipmakeController:config()
    self.model = EquipmakeModel.New(self)
    self.dispather = GlobalEvent:getInstance()
end

function EquipmakeController:getModel()
    return self.model
end

function EquipmakeController:registerEvents()
end

function EquipmakeController:registerProtocals()
    self:RegisterProtocal(11080, "on11080") --更新已接任务进度
end

--==============================--
--desc:打开橙装制作或者进阶面板
--time:2018-07-26 02:08:52
--@status:
--@data:
--@return 
--==============================--
function EquipmakeController:openEquipmakeMainWindow(status, data)
    if not status then
        if self.equipmake_window ~= nil then
            self.equipmake_window:close()
            self.equipmake_window = nil
        end
    else
        if self.equipmake_window == nil then
            self.equipmake_window = EquipmakeMainWindow.New()
        end
        self.equipmake_window:open(data)
    end
end

--==============================--
--desc:橙装碎片来源面板
--time:2018-07-26 05:29:23
--@status:
--@return 
--==============================--
function EquipmakeController:openEquipmakeSourcesWindow(status)
    if not status then
        if self.equipmake_sources_window ~= nil then
            self.equipmake_sources_window:close()
            self.equipmake_sources_window = nil
        end
    else
        if self.equipmake_sources_window == nil then
            self.equipmake_sources_window = EquipmakeSourcesWindow.New()
        end
        self.equipmake_sources_window:open()
    end
end

--==============================--
--desc:请求进阶或者合成装备
--time:2018-07-27 11:39:29
--@partner_id:伙伴唯一id
--@type:装备类型武器衣服头和鞋子
--@return 
--==============================--
function EquipmakeController:requestEquipmake(partner_id, eqm_type)
    local protocal = {}
    protocal.partner_id = partner_id
    protocal.eqm_type = eqm_type
    self:SendProtocal(11080, protocal)
end

--==============================--
--desc:合成或者进阶装备返回
--time:2018-07-27 11:37:10
--@data:
--@return 
--==============================--
function EquipmakeController:on11080(data)
    message(data.msg)
    if data.result == TRUE then
        GlobalEvent:getInstance():Fire(EquipmakeEvent.UpdateEquipmakeEvent, data.partner_id, data.eqm_type)
    end
end

function EquipmakeController:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end
