--
-- @Author: chk
-- @Date:   2018-08-29 19:39:31
--
require("game.equip.RequireEquip")
EquipController = EquipController or class("EquipController", BaseController)
local EquipController = EquipController

function EquipController:ctor()
    EquipController.Instance = self
    self.model = EquipModel:GetInstance()
    self:AddEvents()
    self:RegisterAllProtocal()
end

function EquipController:dctor()
end

function EquipController:GetInstance()
    if not EquipController.Instance then
        EquipController.new()
    end
    return EquipController.Instance
end

function EquipController:RegisterAllProtocal()
    -- protobuff的模块名字，用到pb一定要写
    self.pb_module_name = "pb_1106_equip_pb"
    self:RegisterProtocal(proto.EQUIP_LIST, self.HandleEquipList)
    self:RegisterProtocal(proto.EQUIP_PUTON, self.HandlePutOnEquip)
    self:RegisterProtocal(proto.EQUIP_TAKEDOWN, self.HnadlePutOff)
    self:RegisterProtocal(proto.EQUIP_STRENGTH, self.HandleStrong)
    self:RegisterProtocal(proto.EQUIP_STRONG_BLESS,self.HandleStrongBless)
    self:RegisterProtocal(proto.EQUIP_UPDATE_EQUIP, self.HandleEquipUpdate)
    self:RegisterProtocal(proto.EQUIP_GETSTRENGTHSUITE, self.HandStrongSuite)
    self:RegisterProtocal(proto.EQUIP_STONE_FILLIN, self.ResponeMountStone)
    self:RegisterProtocal(proto.EQUIP_STONE_UPLEVEL, self.ResponeUpStone)
    self:RegisterProtocal(proto.EQUIP_STONE_TAKEDOWN, self.ResponeTakeOffStone)
    self:RegisterProtocal(proto.EQUIP_GET_SUITE, self.ResponeEquipSuit)
    self:RegisterProtocal(proto.EQUIP_SUITE_MAKE, self.ReponseBuildSuit)
    self:RegisterProtocal(proto.EQUIP_SMELT_INFO, self.HandleSmeltInfo)
    self:RegisterProtocal(proto.EQUIP_SMELT, self.HanleSmelt)
    self:RegisterProtocal(proto.EQUIP_CAST, self.HandleCast)
    self:RegisterProtocal(proto.EQUIP_REFINE_INFO, self.HandleRefineInfo)
    self:RegisterProtocal(proto.EQUIP_REFINE_UNLOCK, self.HandleActiveSlot)
    self:RegisterProtocal(proto.EQUIP_REFINE_UNLOCK_HOLE, self.HandleActiveHole)
    self:RegisterProtocal(proto.EQUIP_REFINE, self.HandleRefine)
    self:RegisterProtocal(proto.EQUIP_REFINE_BACK, self.HandleRefineBack)
    self:RegisterProtocal(proto.EQUIP_STRENGTH_ALL, self.HandleStrongAll)
    self:RegisterProtocal(proto.EQUIP_STRONG_SUITE_UP, self.HandleUpStrongSuite)
    self:RegisterProtocal(proto.EQUIP_DECOMBINE, self.HandleDecombine)
end

function EquipController:AddEvents()
    -- --请求基本信息
    -- local function ON_REQ_BASE_INFO()
    -- self:RequestLoginVerify()
    -- end
    -- self.model:AddListener(EquipModel.REQ_BASE_INFO, ON_REQ_BASE_INFO)

    GlobalEvent:AddListener(EquipEvent.RequestEquipList, handler(self, self.RequestEquipList))
    GlobalEvent:AddListener(EquipEvent.ShowEquipUpPanel, handler(self, self.DealShowEquipUpPanel))

    local function call_back()
        self:ShowRedDot()
    end
    GlobalEvent:AddListener(BagEvent.UpdateGoods, call_back)
    GlobalEvent:AddListener(EquipEvent.BuildSuitSucess, call_back)
    GlobalEvent:AddListener(EquipEvent.UpdateEquipDetail, call_back)
    GlobalEvent:AddListener(EquipEvent.StrongSucess, call_back)
    GlobalEvent:AddListener(EquipEvent.StrongFail, call_back)
    GlobalEvent:AddListener(EquipEvent.PutOnEquipSucess, call_back)
    GlobalEvent:AddListener(EquipEvent.UpdateRefineInfo, call_back)
    GlobalEvent:AddListener(EquipEvent.EquipStrongSuite, call_back)
    RoleInfoModel:GetInstance():GetMainRoleData():BindData("coin", call_back)

    local function call_back()
        self:RequestRefineInfo()
    end
    GlobalEvent:AddListener(EventName.CrossDayAfter, call_back)
end

function EquipController:DealShowEquipUpPanel(id, sub_id)
    EquipModel.Instance.equipUpPanelIndex = id
    lua_panelMgr:GetPanelOrCreate(EquipUpPanel):Open(sub_id)
end

function EquipController:HandleEquipUpdate()
    local data = self:ReadMsg("m_equip_update_equip_toc")
    self.model:UpdateEquipDetail(data.item)
end

-- overwrite
function EquipController:GameStart()
    local function call_back()
        self:RequestRefineInfo()
        self:RequestStrongSuite()
    end
    GlobalSchedule:StartOnce(call_back, Constant.GameStartReqLevel.Low)
    EquipSuitModel.GetInstance():FormatEquipSuite()
    EquipRefineModel.GetInstance():LoadLocks()
end

--请求装备列表
function EquipController:RequestEquipList()
    local pb = self:GetPbObject("m_equip_list_tos")
    self:WriteMsg(proto.EQUIP_LIST, pb)
end

function EquipController:HandleEquipList()
    local data = self:ReadMsg("m_equip_list_toc")
    self.model:AddPutOnedEquips(data.equips)
    self.model.is_first_return = false
    self:ShowRedDot()
    self:CheckAllFairy()
end

--打开外部装备面板
function EquipController:OpenEquipPanelOut(equipItem, parent)
    self.model.outEquipItem = equipItem
    lua_panelMgr:GetInstance():GetPanelOrCreate(EquipPanel):Open()
end

--请求购买装备
function EquipController:RequestBuy(uid)
    local pb = self:GetPbObject("m_bag_open_tos")
    -- pb.bag_id = tonumber(bagId)
    -- pb.num = tonumber(count)
    -- self:WriteMsg(proto.BAG_OPEN,pb)
end

--请求强化套装
function EquipController:RequestStrongSuite()
    local pb = self:GetPbObject("m_equip_getstrengthsuite_tos")
    self:WriteMsg(proto.EQUIP_GETSTRENGTHSUITE, pb)
end

function EquipController:HandStrongSuite()
    local data = self:ReadMsg("m_equip_getstrengthsuite_toc")
    EquipStrongModel:GetInstance().suitId = data.id
    GlobalEvent:Brocast(EquipEvent.ShowSuitAttr, data.id)
end

--请求强化
function EquipController:RequestStrong(slot)
    local pb = self:GetPbObject("m_equip_strength_tos")
    pb.slot = slot
    self:WriteMsg(proto.EQUIP_STRENGTH, pb)
end

function EquipController:HandleStrong()
    local data = self:ReadMsg("m_equip_strength_toc")
    if data.result == 0 then
        GlobalEvent:Brocast(EquipEvent.StrongSucess, data.slot, data.result)
    else
        GlobalEvent:Brocast(EquipEvent.StrongFail, data.slot, data.result)
    end
end

--一键强化
function EquipController:RequestStrongAll(slot)
    local pb = self:GetPbObject("m_equip_strength_all_tos")
    pb.slot = slot
    self:WriteMsg(proto.EQUIP_STRENGTH_ALL, pb)
end

function EquipController:HandleStrongAll()
    Notify.ShowText("Quick enhancement successful")
    GlobalEvent:Brocast(EquipEvent.EquipStrongAll)
end

--强化套装升级
function EquipController:UpStrongSuite()
    local pb = self:GetPbObject("m_equip_strong_suite_up_tos")
    self:WriteMsg(proto.EQUIP_STRONG_SUITE_UP, pb)
end

function EquipController:HandleUpStrongSuite()
    Notify.ShowText("Upgraded")
    GlobalEvent:Brocast(EquipEvent.EquipStrongSuite)
end



--请求装备的祝福值
function EquipController:RequestStrongBless(slot)
    local pb = self:GetPbObject("m_equip_strong_bless_tos")
    pb.slot = slot
    self:WriteMsg(proto.EQUIP_STRONG_BLESS,pb)
end

function EquipController:HandleStrongBless()
    local data = self:ReadMsg("m_equip_strong_bless_toc")
    GlobalEvent:Brocast(EquipEvent.StrongBless,data)
end

function EquipController:RequestPutOnEquip2()
    local pb = self:GetPbObject("m_equip_puton_tos")
    pb.uid = self.model.operateEquipItem.uid
    self:WriteMsg(proto.EQUIP_PUTON, pb)
    print("请求穿上装备:" .. pb.uid)
end

function EquipController:RequestPutOnEquip(uid)
    local pb = self:GetPbObject("m_equip_puton_tos")
    pb.uid = uid
    self:WriteMsg(proto.EQUIP_PUTON, pb)
    print("请求穿上装备:" .. pb.uid)
end

local wake2str={
    [1] = "1",
    [2] = "2",
    [3] = "3",
    [4] = "4",
    [5] = "5"
}
--请求穿上装备
function EquipController:RequestPutOnEquipByItem(equipItem)
    self.model.operateEquipItem = equipItem

    local equipCfg = Config.db_equip[equipItem.id]
    local itemConfig = Config.db_item[equipItem.id]
    local roleInfoModel = RoleInfoModel:GetInstance():GetMainRoleData()

    local itemCfg = Config.db_item[equipCfg.id]

    local careerCfg = {}
    if equipCfg.career == "0" then
        table.insert(careerCfg, 1)
        table.insert(careerCfg, 2)
    else
        careerCfg = String2Table(equipCfg.career)
    end

    local mathCareer = false
    for k, v in pairs(careerCfg) do
        if EquipModel.Instance:GetMapCrntCareer(v, equipCfg.id) then
            mathCareer = true
            break
        end
    end
    if not mathCareer then
        Notify.ShowText(string.format(ConfigLanguage.Equip.NotMatchSex, equipCfg.wake))
    elseif itemConfig.level > roleInfoModel.level then
        Dialog.ShowOne(ConfigLanguage.Mix.Tips,string.format(ConfigLanguage.Equip.NeedLVToPutOn,
            GetLevelShow(itemConfig.level), itemConfig.level - roleInfoModel.level),ConfigLanguage.Mix.Confirm)
        --Notify.ShowText(string.format(ConfigLanguage.Equip.NeedLVToPutOn, itemConfig.level))
    elseif equipCfg.wake > roleInfoModel.wake then
        Dialog.ShowOne(ConfigLanguage.Mix.Tips,string.format(ConfigLanguage.Equip.NeedWakeToPutOn,equipCfg.wake,
                equipCfg.wake - roleInfoModel.wake), ConfigLanguage.Mix.Confirm)
    else
        local putOnEquip = EquipModel.Instance.putOnedEquipList[equipCfg.slot]
        --强化是否要提示
        local less = false
        local tips = {}
        local titles = {}

        if putOnEquip ~= nil and equipCfg.slot ~= enum.ITEM_STYPE.ITEM_STYPE_FAIRY and 
           equipCfg.slot ~= enum.ITEM_STYPE.ITEM_STYPE_FAIRY2 then
            local putOnEquipCfg = Config.db_equip[putOnEquip.id]
            local putOnItemCfg = Config.db_item[putOnEquip.id]
            local suitLvCfg = Config.db_equip_suite_level[2]
            local activeLV1 = EquipSuitModel.Instance:GetActiveByEquip(putOnEquipCfg.slot, 1)
            local activeLV2 = EquipSuitModel.Instance:GetActiveByEquip(putOnEquipCfg.slot, 2)

            --[[if activeLV2 then
                --激活了2级套装
                if EquipSuitModel.Instance:GetCanBuildMaxSuitLv(equipItem.id) <= 1 then
                    --穿上的小于等于1
                    table.insert(tips, ConfigLanguage.Equip.PutOnEquipSuitTip)
                    table.insert(titles, ConfigLanguage.Mix.Tips)
                end
            elseif activeLV1 then
                if EquipSuitModel.Instance:GetCanBuildMaxSuitLv(equipItem.id) < 1 then
                    table.insert(tips, ConfigLanguage.Equip.PutOnEquipSuitTip)
                    table.insert(titles, ConfigLanguage.Mix.Tips)
                end
            end--]]
            if activeLV1 or activeLV2 then
                if equipCfg.order ~= putOnEquipCfg.order or equipCfg.star ~= putOnEquipCfg.star or putOnItemCfg.color ~= itemConfig.color then
                    table.insert(tips, ConfigLanguage.Equip.PutOnEquipSuitTip)
                    table.insert(titles, ConfigLanguage.Mix.Tips)
                end
            end

            local strong_limit_key = equipCfg.slot .. "@" .. equipCfg.order .. "@" .. itemConfig.color

            local equipLV = putOnEquip.equip.stren_lv + putOnEquip.equip.stren_phase * 10
            if equipLV > Config.db_equip_strength_limit[strong_limit_key].max_phase * 10 then
                less = true
            end
            local puton_maxlevel = EquipStrongModel.GetInstance():GetCastMaxLevel(putOnEquip.id)
            local max_level = EquipStrongModel.GetInstance():GetCastMaxLevel(equipItem.id)
            if putOnEquip.equip.cast > 0 and puton_maxlevel ~= max_level then
                table.insert(tips, ConfigLanguage.Equip.PutOnEquipCastTip)
                table.insert(titles, ConfigLanguage.Mix.Tips)
            end
        end
        if less then
            local itemConfig = Config.db_item[equipItem.id]
            local strong_limit_key = equipCfg.slot .. "@" .. equipCfg.order .. "@" .. itemConfig.color

            local strong_str = string.format("%s%s%s%s", Config.db_equip_strength_limit[strong_limit_key].max_phase - 1,
                    ConfigLanguage.Equip.Phase, 10, ConfigLanguage.Equip.LV)
            local tipInfo = string.format(ConfigLanguage.Equip.PutOnEquipStrongTip, ColorUtil.GetColor(ColorUtil.ColorType.Green),
                    strong_str, ColorUtil.GetColor(ColorUtil.ColorType.Green))
            table.insert(tips, tipInfo)
            table.insert(titles, ConfigLanguage.Equip.PutOnEquipStrongTipTitle)
        end

        if not table.isempty(tips) then
            Dialog.ShowTwoWithMultyClickOK(titles, tips, ConfigLanguage.Mix.Confirm,
                    handler(self, self.RequestPutOnEquip2))
        else
            self:RequestPutOnEquip2()
        end
    end
end

function EquipController:HandlePutOnEquip()
    local data = self:ReadMsg("m_equip_puton_toc")
    GlobalEvent:Brocast(EquipEvent.PutOnEquipSucess, self.model.putOnedEquipDetailList[data.slot])
end

--请求卸下
function EquipController:RequestPutOff(slot)
    local pb = self:GetPbObject("m_equip_takedown_tos")
    pb.slot = slot
    self:WriteMsg(proto.EQUIP_TAKEDOWN, pb)
end

function EquipController:HnadlePutOff()
    local data = self:ReadMsg("m_equip_takedown_toc")
    self.model:DelPutOnEquip(data.slot)
    GlobalEvent:Brocast(EquipEvent.PutOffEquip, data.slot)
end

--请求镶嵌宝石
function EquipController:RequestMountStone(slot, hole, itemId)
    local pb = self:GetPbObject("m_equip_stone_fillin_tos")
    pb.slot = slot
    pb.hole = hole
    pb.item_id = itemId
    self:WriteMsg(proto.EQUIP_STONE_FILLIN, pb)
end

--宝石镶嵌请求的返回
function EquipController:ResponeMountStone()
    local data = self:ReadMsg("m_equip_stone_fillin_toc")
--    GlobalEvent:Brocast(EquipEvent.StoneChange, data.slot)
end

--请求升级指定装备位的指定孔位上的宝石
function EquipController:RequestUpStone(slot, hole, level)
    local pb = self:GetPbObject("m_equip_stone_uplevel_tos")
    pb.slot = slot
    pb.hole = hole
    pb.to_level = level
    self:WriteMsg(proto.EQUIP_STONE_UPLEVEL, pb)
end

--宝石升级请求的返回
function EquipController:ResponeUpStone()
    local data = self:ReadMsg("m_equip_stone_uplevel_toc")
    GlobalEvent:Brocast(EquipEvent.StoneChange, data.slot)
end

--请求卸下宝石
function EquipController:RequestTakeOffStone(slot, hole)
    local pb = self:GetPbObject("m_equip_stone_takedown_tos")
    pb.slot = slot
    pb.hole = hole
    self:WriteMsg(proto.EQUIP_STONE_TAKEDOWN, pb)
end

--卸下宝石请求的返回
function EquipController:ResponeTakeOffStone()
    local data = self:ReadMsg("m_equip_stone_takedown_toc")
    GlobalEvent:Brocast(EquipEvent.TakeOffStone, data.slot)
end

--请求套装
function EquipController:RequestEquipSuit(suitLv)
    local pb = self:GetPbObject("m_equip_get_suite_tos")
    pb.level = suitLv
    self:WriteMsg(proto.EQUIP_GET_SUITE, pb)
end

function EquipController:ResponeEquipSuit()
    local data = self:ReadMsg("m_equip_get_suite_toc")
    --if table.isempty(data.active) then
    EquipSuitModel.GetInstance():CleanActiveSuitBySuitLv(data.level)
    --end
    for i, v in pairs(data.active) do
        EquipSuitModel.GetInstance():AddActiveSuit(data.level, i, v)
    end

    EquipSuitModel.GetInstance():AddActiveSlot(data.level, data.maked_slots)
    EquipSuitModel.GetInstance():Brocast(EquipEvent.SuitList)
end

function EquipController:RequestBuildSuit(suitLv, slot)
    local pb = self:GetPbObject("m_equip_suite_make_tos")
    pb.level = suitLv
    pb.slot = slot
    self:WriteMsg(proto.EQUIP_SUITE_MAKE, pb)
end

function EquipController:ReponseBuildSuit()
    local data = self:ReadMsg("m_equip_suite_make_toc")
    GlobalEvent:Brocast(EquipEvent.BuildSuitSucess)
end


function EquipController:RequestSmeltInfo()
    local pb = self:GetPbObject("m_equip_smelt_info_tos")
    self:WriteMsg(proto.EQUIP_SMELT_INFO, pb)
end

function EquipController:HandleSmeltInfo()
    local data = self:ReadMsg("m_equip_smelt_info_toc")
    self.model:Brocast(EquipEvent.UpdateSmeltInfo, data)
end

function EquipController:RequestSmelt(equips)
    local pb = self:GetPbObject("m_equip_smelt_tos")
    for cellid, _ in pairs(equips) do
        pb.uids:append(cellid)
    end
    self:WriteMsg(proto.EQUIP_SMELT, pb)
end

function EquipController:HanleSmelt()
    local data = self:ReadMsg("m_equip_smelt_toc")
    GlobalEvent:Brocast(EquipEvent.SmeltSuccess)
end

--铸造
function EquipController:RequestCast(slot)
    local pb = self:GetPbObject("m_equip_cast_tos")
    pb.slot = slot
    self:WriteMsg(proto.EQUIP_CAST, pb)
end

function EquipController:HandleCast()
    local data = self:ReadMsg("m_equip_cast_toc")
    Notify.ShowText("Forged")
    GlobalEvent:Brocast(EquipEvent.EquipCastSuccess)
end

--获取洗练信息
function EquipController:RequestRefineInfo( )
    local pb = self:GetPbObject("m_equip_refine_info_tos")
    self:WriteMsg(proto.EQUIP_REFINE_INFO, pb)
end

function EquipController:HandleRefineInfo()
    local data = self:ReadMsg("m_equip_refine_info_toc")

    EquipRefineModel.GetInstance():SetInfo(data)
    GlobalEvent:Brocast(EquipEvent.UpdateRefineInfo)
end

--解锁部位
function EquipController:RequestActiveSlot(slot)
    local pb = self:GetPbObject("m_equip_refine_unlock_tos")
    pb.slot = slot
    self:WriteMsg(proto.EQUIP_REFINE_UNLOCK, pb)
end

function EquipController:HandleActiveSlot()
    Notify.ShowText("Unlocked")
end

--解锁槽位
function EquipController:RequestActiveHole(slot, hole)
    local pb = self:GetPbObject("m_equip_refine_unlock_hole_tos")
    pb.slot = slot
    pb.hole = hole
    self:WriteMsg(proto.EQUIP_REFINE_UNLOCK_HOLE, pb)
end

function EquipController:HandleActiveHole()
    Notify.ShowText("Unlocked")
end

--洗练
function EquipController:RequestRefine(slot, item_id, locks)
    local pb = self:GetPbObject("m_equip_refine_tos")
    pb.slot = slot
    pb.itemid = item_id or 0
    if locks then
        for i=1, #locks do
            pb.locks:append(locks[i])
        end
    end
    self:WriteMsg(proto.EQUIP_REFINE, pb)
end

function EquipController:HandleRefine()
    Notify.ShowText("Refined")
end

--还原
function EquipController:RequestRefineBack(slot)
    local pb = self:GetPbObject("m_equip_refine_back_tos")
    pb.slot = slot
    self:WriteMsg(proto.EQUIP_REFINE_BACK, pb)
end

function EquipController:HandleRefineBack()
    Notify.ShowText("Recovered")
end

--装备拆解
function EquipController:RequestDecombine(item_uid)
    local pb = self:GetPbObject("m_equip_decombine_tos")
    pb.item_uid = item_uid
    self:WriteMsg(proto.EQUIP_DECOMBINE, pb)
end

function EquipController:HandleDecombine()
    Notify.ShowText("拆解成功")
end

function EquipController:CheckAllFairy()
    self:CheckFairy()
    self:CheckFairy2()
end

function EquipController:CheckFairy()
    local pitem = self.model:GetEquipBySlot(enum.ITEM_STYPE.ITEM_STYPE_FAIRY)
    if not pitem then
        return
    end
    local color = Config.db_item[pitem.id].color
    if color == enum.COLOR.COLOR_PURPLE then
        local now = os.time()
        if pitem.etime <= now then
            if self.model.is_checked_fairy then
                return
            end
            GlobalEvent:Brocast(ShopEvent.OpenBuyFairyPanel, pitem.uid, pitem.id)
            self.model.is_checked_fairy = true
        else
            self.model.is_checked_fairy = false
        end
    end
end

function EquipController:CheckFairy2()
    local pitem = self.model:GetEquipBySlot(enum.ITEM_STYPE.ITEM_STYPE_FAIRY2)
    if not pitem then
        return
    end
    local color = Config.db_item[pitem.id].color
    if color == enum.COLOR.COLOR_PURPLE then
        local now = os.time()
        if pitem.etime <= now then
            if self.model.is_checked_fairy2 then
                return
            end
            GlobalEvent:Brocast(ShopEvent.OpenBuyFairyPanel, pitem.uid, pitem.id)
            self.model.is_checked_fairy2 = true
        else
            self.model.is_checked_fairy2 = false
        end
    end
end

function EquipController:ShowRedDot()
    local show1, show2, show3, show4, show5, show6,show7
    if OpenTipModel.GetInstance():IsOpenSystem(120, 3) then
        show1 = EquipSuitModel.GetInstance():GetNeedShowRedDot()
        GlobalEvent:Brocast(MainEvent.ChangeSystemShowInStronger, 3, show1)
    end
    if OpenTipModel.GetInstance():IsOpenSystem(120, 1) then
        show2 = EquipStrongModel.GetInstance():GetNeedShowRedDot()
        show4 = EquipStrongModel.GetInstance():GetNeedShowCastRedDot()
        show6 = EquipStrongModel.GetInstance():IsCanUpStrongSuite()
        GlobalEvent:Brocast(MainEvent.ChangeSystemShowInStronger, 1, show2)
        GlobalEvent:Brocast(MainEvent.ChangeSystemShowInStronger, 48, show4)
        GlobalEvent:Brocast(MainEvent.ChangeSystemShowInStronger, 53, show6)
    end
    if OpenTipModel.GetInstance():IsOpenSystem(120, 2) then
        show3 = EquipMountStoneModel.GetInstance():GetNeedShowRedDotByState(EquipMountStoneModel.GetInstance().states.gem)
        GlobalEvent:Brocast(MainEvent.ChangeSystemShowInStronger, 2, show3)
    end
    if OpenTipModel.GetInstance():IsOpenSystem(120, 6) then
        show7 = EquipMountStoneModel.GetInstance():GetNeedShowRedDotByState(EquipMountStoneModel.GetInstance().states.spar)
        GlobalEvent:Brocast(MainEvent.ChangeSystemShowInStronger, 67, show7)
    end
    if OpenTipModel.GetInstance():IsOpenSystem(120, 4) then
        show5 = EquipRefineModel.GetInstance():GetNeedShowRedDot()
        --GlobalEvent:Brocast(MainEvent.ChangeSystemShowInStronger, 2, show5)
    end

    local show = show1 or show2 or show3 or show4 or show5 or show6 or show7
    GlobalEvent:Brocast(MainEvent.ChangeRedDot, "equip", show)
end
