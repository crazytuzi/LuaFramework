require("game.realname.RequireRealName")
RealNameController = RealNameController or class("RealNameController", BaseController)

function RealNameController:ctor()
    RealNameController.Instance = self
    self.model = RealNameModel:GetInstance()
    self:AddEvents()
    self:RegisterAllProtocal()
   -- self:BindRoleUpdate()
    self.role = RoleInfoModel.GetInstance():GetMainRoleData()
end

function RealNameController:dctor()
    if self.role_update_list then
        for k, event_id in pairs(self.role_update_list) do
            self.role_data:RemoveListener(event_id)
        end
        self.role_update_list = nil
    end
end

function RealNameController:GetInstance()
    if not RealNameController.Instance then
        RealNameController.new()
    end
    return RealNameController.Instance
end

function RealNameController:GameStart()
    local function step()
            --self:RequestRealNameInfo(3)
        --if PlatformManager:GetInstance():IsIos() then
        --    self:RequestRealNameInfo(3,nil,nil,nil,nil,nil)
        --else
            PlatformManager:GetInstance():getPlayerInfo()
        --end
    end
    GlobalSchedule:StartOnce(step,Constant.GameStartReqLevel.High)
end

function RealNameController:BindRoleUpdate()
    self.role_data = RoleInfoModel.GetInstance():GetMainRoleData()
    self.role_update_list = self.role_update_list or {}
    --local function call_back(level)
    --    if  not self.model.isRegisterd then
    --        if level >= 240 and self.model.isFrist  then
    --            self:RequestRealNameInfo()
    --        end
    --    end
    --
    --end
    --self.role_update_list[#self.role_update_list + 1] = self.role_data:BindData("level", call_back) --绑定升级
end

function RealNameController:RegisterAllProtocal()
    self.pb_module_name = "pb_1116_realname_pb"
    self:RegisterProtocal(proto.REALNAME_INFO, self.HandleRealNameInfo);   -- 查询实名情况
    self:RegisterProtocal(proto.REALNAME_REGISTER, self.HandleRealNameRegister);   -- 实名登记
    self:RegisterProtocal(proto.REALNAME_CANCEL, self.HandleNameRealCancel);

end

function RealNameController:AddEvents()
    local function call_back(data)
        lua_panelMgr:GetPanelOrCreate(RealNamePanel):Open(data)
    end
    GlobalEvent:AddListener(RealNameEvent.OpenRealNamePanel, call_back)



    local function call_back(data) --SDKPlayerInfo
        self.model.playInfo = data
        local code = 1
        if data.retCode == "AUTHENTICATION_OK" then
            code = 1
            self:RequestRealNameInfo(code,data.real_name_authentication,data.age,data.is_adult,data.id_card,data.real_name)
        elseif data.retCode == "AUTHENTICATION_UNKNOWN" then
            code = 2
            self:RequestRealNameInfo(code,nil,nil,nil,nil,nil)
        elseif data.retCode == "AUTHENTICATION_NEVER" then
            code =3
            self:RequestRealNameInfo(code,nil,nil,nil,nil,nil)
        elseif data.retCode == "ANTI_INDULGENCE_REALIZED" then
            code = 4
            self:RequestRealNameInfo(code,nil,nil,nil,nil,nil)
        end
    end
    GlobalEvent:AddListener(EventName.SDKPlayerInfo, call_back)

    local function call_back(data)
        if  data.gain[enum.ITEM.ITEM_GOLD] and self.model.curCharge then
           -- data.gain[enum.ITEM.ITEM_GOLD]
            self.model.curCharge = self.model.curCharge + (data.gain[enum.ITEM.ITEM_GOLD])/10

        end
    end
    GlobalEvent:AddListener(EventName.PaySucc, call_back)
end
--请求实名情况
function RealNameController:RequestRealNameInfo(status,is_registerd,age,is_adult,id_card,real_name)
    local pb = self:GetPbObject("m_realname_info_tos")
    pb.status = status
    if is_registerd~=nil then
        if type(is_registerd) == "string" then
            local boo = true
            if is_registerd == "false" then
                boo = false
            end
            pb.is_registerd = boo
        else
            pb.is_registerd = is_registerd
        end

    end
    if age~=nil then
        if type(age) == "string" then
            local num = 0
            if string.isNilOrEmpty(age) then
                num = 0
            else
                num = tonumber(age)
            end
            pb.age = num
        else
            pb.age = age
        end

    end
    if is_adult~=nil then
        if type(is_adult) == "string" then
            local boo = true
            if is_adult == "false" then
                boo = false
            end
            pb.is_adult = boo
        else
            pb.is_adult = is_adult
        end
       -- pb.is_adult = is_adult
    end
    if id_card~=nil then
        pb.id_card = tostring(id_card)
    end
    if real_name~=nil then
        pb.real_name = tostring(real_name)
    end
    self:WriteMsg(proto.REALNAME_INFO,pb)
end

function RealNameController:HandleRealNameInfo()
    local data = self:ReadMsg("m_realname_info_toc")
   -- logError("返回实名")
  --  logError(Table2String(data))
    self.model:DealRealNameInfo(data)
    --if not data.is_open then   --false 渠道不支持实名
    --    return
    --end
   -- self.model:IsRealNameCondition(data)
end

function RealNameController:RequesRealNameRegister(game_id, channel_id, game_channel_id, user_id, area_code, id_card, real_name)
    local pb = self:GetPbObject("m_realname_register_tos")
    pb.game_id = tostring(game_id)
    pb.channel_id = tostring(channel_id)
    pb.game_channel_id = tostring(game_channel_id)
    pb.user_id = tostring(user_id)
    pb.area_code = tostring(area_code)
    pb.id_card = tostring(id_card)
    pb.real_name = tostring(real_name)
    self:WriteMsg(proto.REALNAME_REGISTER,pb)
end

function RealNameController:HandleRealNameRegister()
    local data = self:ReadMsg("m_realname_register_toc")
    if data.succ then
        self.model.isAdult = data.is_adult
        self.model.age = data.age
        if not self.model.isAdult then --未成年
            self.model:OpenIndulgence()
        else
            self.model:StopSchedule()
        end
    end


    -- print('--LaoY RealNameController.lua,line 90--')
    -- dump(data,"data")
    GlobalEvent:Brocast(RealNameEvent.RealNameRegister,data)
end
function RealNameController:RequesNameRealCancel()
    local pb = self:GetPbObject("m_realname_cancel_tos")
    self:WriteMsg(proto.REALNAME_CANCEL,pb)
end


function RealNameController:HandleNameRealCancel()
    local data = self:ReadMsg("m_realname_cancel_toc")
    self.model:OpenIndulgence()
end








