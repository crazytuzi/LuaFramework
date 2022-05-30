ForgeHouseController = ForgeHouseController or BaseClass(BaseController)

function ForgeHouseController:config()
    self.model = ForgeHouseModel.New(self)
    self.dispather = GlobalEvent:getInstance()
end

function ForgeHouseController:getModel()
    return self.model
end

function ForgeHouseController:registerEvents()

end

function ForgeHouseController:registerProtocals()
    self:RegisterProtocal(11079, "handle11079")
    self:RegisterProtocal(11080, "handle11080")
    self:RegisterProtocal(11081, "handle11081")
    self:RegisterProtocal(11082, "handle11082")
end

function ForgeHouseController:openForgeHouseView(bool, sub_type)
    if bool == true then
        local config = Config.CityData.data_base[CenterSceneBuild.mall]
        if config == nil then return end
        local is_open = MainuiController:getInstance():checkIsOpenByActivate(config.activate)
        if not is_open then
            message(config.desc)
            return
        end

        if not self.forgehouseView then
            self.forgehouseView = ForgeHouseWindow.New()
        end
        self.forgehouseView:open(sub_type)
    else
        if self.forgehouseView then 
            self.forgehouseView:close()
            self.forgehouseView = nil
        end
    end
end
-- 一键合成装备预览
function ForgeHouseController:send11079(base_id,num)
    local proto = {}
    proto.base_id = base_id
    proto.num = num or 0
    self:SendProtocal(11079, proto)
end
function ForgeHouseController:handle11079(data)
    if next(data.list) == nil then
        message(TI18N("暂时无法合成任何装备或金币不足"))
        return
    end
    if data.type == 0 then
        self:openEquipmentAllSynthesisWindow(true,data)
    end
end
--合成装备
function ForgeHouseController:send11080(id,num)
	local proto = {}
	proto.base_id = id
	proto.num = num
	self:SendProtocal(11080, proto)
end
function ForgeHouseController:handle11080(data)
    message(data.msg)
    -- if data.result == 1 then
        GlobalEvent:getInstance():Fire(ForgeHouseEvent.Composite_Result)
    -- end
end
--一键合成
function ForgeHouseController:send11081(base_id,num)
    local proto = {}
    proto.base_id = base_id
    proto.num = num or 0
    self:SendProtocal(11081, proto)
end
function ForgeHouseController:handle11081(data)
    message(data.msg)
    if data.result == 1 then
        self:openEquipmentAllSynthesisWindow(false)
        GlobalEvent:getInstance():Fire(ForgeHouseEvent.Composite_Result)
    end
end
function ForgeHouseController:openEquipmentAllSynthesisWindow(bool,data)
    if bool == true then 
        if not self.all_synthsis_view then
            self.all_synthsis_view = EquipmentAllSynthesisWindow.New(data)
        end
        self.all_synthsis_view:open()
    else
        if self.all_synthsis_view then 
            self.all_synthsis_view:close()
            self.all_synthsis_view = nil
        end
    end
end
--合成日志
function ForgeHouseController:send11082()
    self:SendProtocal(11082, {})
end
function ForgeHouseController:handle11082(data)
    GlobalEvent:getInstance():Fire(ForgeHouseEvent.Composite_Record,data)
end
function ForgeHouseController:openEquipmentCompRecordWindow(bool)
    if bool == true then 
        if not self.comp_record_view then
            self.comp_record_view = EquipmentCompRecordWindow.New()
        end
        self.comp_record_view:open()
    else
        if self.comp_record_view then 
            self.comp_record_view:close()
            self.comp_record_view = nil
        end
    end
end

function ForgeHouseController:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end
