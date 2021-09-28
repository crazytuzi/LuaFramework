require("game/player/wing/wing_data")

-- 羽翼
WingCtrl = WingCtrl or BaseClass(BaseController)
function WingCtrl:__init()
    if WingCtrl.Instance then
        print_error("[WingCtrl] Attemp to create a singleton twice !")
        return
    end
    WingCtrl.Instance = self

    self.data = WingData.New()

    self:RegisterAllProtocols()
    self:RegisterAllEvents()
end

function WingCtrl:__delete()
    WingCtrl.Instance = nil

    self.data:DeleteMe()
    self.data = nil
end

-- 协议注册
function WingCtrl:RegisterAllProtocols()
    self:RegisterProtocol(SCWingInfo, "OnSwingInfo")
    self:RegisterProtocol(SCWingGrowExpType, "OnWingGrowExpType")

    self:RegisterProtocol(CSWingUseImage)
    self:RegisterProtocol(CSWingPromoteJinghua)
    self:RegisterProtocol(CSWingSpecialUpgrade)
end

function WingCtrl:RegisterAllEvents()
    -- GlobalEventSystem:Bind(LoginEventType.LOGIN_SERVER_CONNECTED, enter_login_server_callback)
end

-- 羽翼基本信息
function WingCtrl:OnSwingInfo(protocol)
    local old_jinhua = self.data:GetJinHua()
    local old_grade = self.data:GetFaZhenData().grade or 0
    self.data:SetSelectImageId(protocol.select_jinhua_img)
    self.data:SetJinHua(protocol.jinhua == 0 and 1 or protocol.jinhua)
    self.data:SetJinHuaBless(protocol.jinhua_bless)
    self.data:SetSpecialImgFlag(protocol.special_img_flag)
    self.data:SetSelectSpecialImg(protocol.select_special_img)
    self.data:SetShuxingdanInfo(protocol.shuxingdan_list)
    self.data:SetSpecialImgGradeList(protocol.special_img_grade_list)
    self.data:SetWingFuMoLevelList(protocol.fumo_level_list)

    local fazhen_data = {grade = protocol.grade, use_grade = protocol.use_grade, grade_bless_val = protocol.grade_bless_val}
    self.data:SetFaZhenData(fazhen_data)

    -- self.fz_view:Flush()

    -- if self.special_upgrade_view:IsOpen() then
    -- self.special_upgrade_view:Flush()
    -- end

    -- if old_grade ~= self.data:GetFaZhenData().grade then
    --     if PlayerCtrl.Instance:GetRoleView().is_auto_upfazhen then
    --         PlayerCtrl.Instance:GetRoleView().is_auto_upfazhen = false
    --         if PlayerCtrl.Instance:GetRoleView():IsOpen() then
    --             local is_max = self.data:GetIsFaZhenMaxGrade(protocol.grade)
    --             if not is_max then
    --                 PlayerCtrl.Instance:GetRoleView():SetFaZhenButtonEnabled(true)
    --             else
    --                 PlayerCtrl.Instance:GetRoleView():SetFaZhenButtonEnabled(false)
    --             end
    --         end
    --     end
    --     PlayerCtrl.Instance:GetRoleView():ShowFzGrowExpType(WingDataConst.Effect.Success)
    --     PlayerCtrl.Instance:GetRoleView():UpdataShowFazhenlist()
    -- end

    -- local old_cfg = ConfigManager.Instance:GetAutoConfig("wing_auto").jinhua[old_jinhua]
    -- local cur_cfg = ConfigManager.Instance:GetAutoConfig("wing_auto").jinhua[protocol.jinhua]

    -- if nil ~= old_cfg and nil ~= cur_cfg then
    --     if old_cfg.big_grade ~= cur_cfg.big_grade then
    --         self:RefreshWingImage(protocol.jinhua)
    --     end
    --     if old_cfg.star ~= cur_cfg.star and cur_cfg.star ~= 10 then
    --         PlayerCtrl.Instance:GetRoleView():ShowSuccessEffect(cur_cfg.star)
    --     end
    -- end

    -- local old_cfg = ConfigManager.Instance:GetAutoConfig("wing_auto").fazhen[old_grade]
    -- local cur_cfg = ConfigManager.Instance:GetAutoConfig("wing_auto").fazhen[protocol.grade]

    -- if nil ~= old_cfg and nil ~= cur_cfg then
    --     if old_cfg.star ~= cur_cfg.star and cur_cfg.star ~= 10 then
    --         PlayerCtrl.Instance:GetRoleView():ShowFzSuccessEffect(cur_cfg.star)
    --     end
    -- end
end

-- 羽翼进化暴击
function WingCtrl:OnWingGrowExpType(protocol)
    if not PlayerCtrl.Instance:GetRoleView():IsOpen() then
        return
    end
    PlayerCtrl.Instance:GetRoleView():FloatingText(protocol.increase_point)
    --if 1 == protocol.grow_type then
        -- PlayerCtrl.Instance:GetRoleView():ShowGrowExpType(WingDataConst.Effect.BaoJi)
    --end
end

-- 羽翼形象幻化请求
function WingCtrl:SendUseImageReq(image_id, is_spec)
    local send_protocol = ProtocolPool.Instance:GetProtocol(CSWingUseImage)
    send_protocol.wing_jinhua = image_id
    send_protocol.is_special_img = is_spec or 0
    send_protocol:EncodeAndSend()
end

-- 羽翼进阶请求
function WingCtrl:SendUppEvolHaReq(auto_buy)
    local send_protocol = ProtocolPool.Instance:GetProtocol(CSWingPromoteJinghua)
    send_protocol.is_auto_buy = auto_buy
    if auto_buy == 1 then
        local level = self.data:GetJinHua()
        local config = ConfigManager.Instance:GetAutoConfig("wing_auto").jinhua[level]
        if nil ~= config then
            send_protocol.repeat_times = config.pack_num
        else
            send_protocol.repeat_times = 1
        end
    else
        send_protocol.repeat_times = 1
    end
    send_protocol:EncodeAndSend()
end

-- 羽翼进阶结果
function WingCtrl:OnUppEvolOptResult(result)
    print_log("........................................羽翼进阶结果")
    if 0 == result then
        if PlayerCtrl.Instance:GetRoleView().is_auto_upgrade then
            PlayerCtrl.Instance:GetRoleView().is_auto_upgrade = false
            PlayerCtrl.Instance:GetRoleView():WingJinJieSetEvolButtonEnabled(true)
        end
    elseif 1 == result then
        PlayerCtrl.Instance:GetRoleView():AutoUpGradeOnce()
    end
end

function WingCtrl:SendWingSpecialUpgrade(img_id)
    local send_protocol = ProtocolPool.Instance:GetProtocol(CSWingSpecialUpgrade)
    send_protocol.img_id = img_id
    send_protocol:EncodeAndSend()
end

--羽翼附魔请求
function WingCtrl:SendWingFuMo(type, is_auto_buy)
    local  send_protocol = ProtocolPool.Instance:GetProtocol(CSWingFumoUplevel)
    send_protocol.type = type
    send_protocol.is_auto_buy = is_auto_buy
    send_protocol:EncodeAndSend()
end