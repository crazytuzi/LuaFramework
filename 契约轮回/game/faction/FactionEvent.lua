--
-- @Author: chk
-- @Date:   2018-12-05 16:10:19
--
FactionEvent = {
    ShowMessagePanel = "FactionEvent.ShowMessagePanel",
    OpenFactionPanel = "FactionEvent.OpenFactionPanel",
    FactionList = "FactionEvent.FactionList",
    CancleApplySucess = "FactionEvent.CancleApplySucess",
	ApplySucess = "FactionEvent.ApplySucess",
    SelfFactionInfo = "FactionEvent.SelfFactionInfo",    --自己的帮派信息
    FactionCreateSucess = "FactionEvent.FactionCreateSucess",
    SelectCadre = "FactionEvent.SelectCadre",
    AppointmentSucess = "FactionEvent.AppointSucess",
    ApplyEnterFaction = "FactionEvent.ApplyEnterFaction",
    QuitSucess = "FactionEvent.QuitSucess",
    ModifyNoticeSucess = "FactionEvent.ModifyNoticeSucess",
    ApplyList = "FactionEvent.ApplyList",
    RefuseApply = "FactionEvent.RefuseApply",  --拒绝入帮申请
    AcceptApply = "FaceionEvent.AcceptApply",  --接受入帮申请
    FactionMessage = "FactionEvent.FactionMessage",
    DisCareerSucess = "FactionEvent.DisCareerSucess", --解除职位
    Demise = "FactionEvent.DisDemise",             --转让帮主
    KitOut = "FactionEvent.KitOut",                --踢出帮会
    ApplyCareer = "FactionEvent.ApplyCareer",      --申请职位
    CancleOperateApplyCareer = "FactionEvent.CancleOperateApply", --取消操作申请职位
    CancleOperateAppoint = "FactionEvent.CancleOperateAppoint", -- 取消操作任命
    CancleOtherOperateAppoint = "FactionEvent.CancleOtherOperateAppoint",
    AgreeApplyCareer = "FactionEvent.AgreeApplyCareer",         --同意职位申请
    RefuseApplyCareer = "FactionEvent.RefuseApplyCareer",        --拒绝职位申请
    Donate = "FactionEvent.Donate",                              --捐献
    ShowSkillInfo = "FactionEvent.ShowSkillInfo",
    SkillInfo = "FactionEvent.SkillInfo",                        --技能
    SkillUpLv = "FactionEvent.SkillUpLv",                        --技能升级
    UpLV = "FactionEvent.UpLV",                                  --升级
    Logs = "FactionEvent.Logs",                                  --日志
    ReceiveWelfare = "FactionEvent.ReceiveWelfare",              --领取福利
    FactionSetInfo = "FactionEvent.FactionSetInfo",              --帮派入会设置信息
    FactionSetSucess = "FactionEvent.FactionSetSucess",          --帮派入会设置成功
    DisbandFaction = "FactionEvent.DisbandFaction",              --解散帮会
    CloseOperateView = "FactionEvent.CloseOperateView",
    WareInfo = "FactionEvent.WareInfo",                          --
    RequestDonateEquip = "FactionEvent.RequestDonateEquip",      --请求捐献装备
    DonateEquip = "FactionEvent.DonateEquip",                    --捐献装备
    EquipDetailInfo = "FactionEvent.EquipDetailInfo",            --装备详细信息
    DonateLog = "FactionEvent.DonateLog",                        --捐献日志
    DestroyEquipSucess  = "FactionEvent.DestroyEquipSucess",     --成功销毁装备
    QuitManagerWare = "FactionEvent.QuitManagerWare",            --退出管理仓库
    AddWareItem = "FactionEvent.AddWareItem",                    --添加仓库物品
    ExchangeSucess = "FactionEvent.ExchangeSucess",              --兑换装备成功
    OpenBatchExchangeView = "FactionEvent.OpenBatchExchangeView",
    LoadWareItem = "FactionEvent.LoadItem",                       --加载
    JoinSucuss = "FactionEvent.JoinSucuss",                       --成功加入帮会
    RequestMember = "FactionEvent.RequestMember",                 --请求帮派成员
    FactionMember = "FactionEvent.FactionMember",
    FactionRename = "FactionEvent.FactionRename",
    UpdateRedDot = "FactionEvent.UpdateRedDot",
    ResponeMember = "FactionEvent.ResponeMember",
    BtnCountDown = "FactionEvent.BtnCountDown",
    ShowMainIcon = "FactionEvent.ShowMainIcon",
	
    ----------------------------公会战相关----------------------------
    Faction_OpenGuildWithWarOpeningEvent = "FactionEvent.OnOpenGuildWithWarOpening",
    Faction_OpenTempleEvent = "FactionEvent.OnOpenTemple",
    Faction_GuildWarRedPointEvent = "FactionEvent.OnGuildWarRedPoint",
    ------------------------------------------------------------------
    Faction_EnterGuildHouseEvent = "FactionEvent.EnterGuildHouseEvent",
    Faction_PreGuildHouseEvent = "FactionEvent.PreGuildHouseEvent",
    --打开公会守卫
    OPEN_GUILD_GUARD = "FactionEvent.OpenGuildGuard",

}
