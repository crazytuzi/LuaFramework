---------------------------------
-- @Author: htp
-- @Editor: htp
-- @date 2019/11/28 10:06:35
-- @description: 位面冒险事件的数据结构
---------------------------------
PlanesEvtVo = PlanesEvtVo or BaseClass(EventDispatcher)

function PlanesEvtVo:__init(  )
    self.index = 0 -- 格子坐标
    self.evtid = 0 -- 事件id
    self.status = PlanesConst.Evt_State.None -- 事件状态
    self.platform = 0 -- 升降台状态(1升0降)
    self.switch = 0 -- 开关状态(1开0关)
    self.is_hide = 0 -- 是否隐藏(0不隐藏，1隐藏)
    self.config = {} -- 配置数据
end

function PlanesEvtVo:updateData(data)
	for key, value in pairs(data) do
        self[key] = value
        if key == "evtid" then
            self.config = Config.SecretDunData.data_evt_info[value] or {}
        end
    end 
    self:dispatchUpdateAttrByKey()
end

function PlanesEvtVo:dispatchUpdateAttrByKey(  )
    self:Fire(PlanesEvent.Update_Evt_Status_Event)
end

function PlanesEvtVo:__delete(  )
end