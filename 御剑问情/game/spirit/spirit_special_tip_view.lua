SpiritSpecialView = SpiritSpecialView or BaseClass(BaseView)

function SpiritSpecialView:__init()
    self.ui_config = {"uis/views/spiritview_prefab", "SpiritSpecialModle"}
    self.play_audio = true
end

function SpiritSpecialView:__delete()
    -- body
end

function SpiritSpecialView:LoadCallBack()

    self.item = ItemCell.New()
    self.item:SetInstanceParent(self:FindObj("Item"))
    self.display = self:FindObj("Display")
    self.model = RoleModel.New("display_model_sepcial_spirit")
    self.model:SetDisplay(self.display.ui3d_display)

    self.hp_value = self:FindVariable("hp_value")
    self.attack_value = self:FindVariable("attack_value")
    self.fangyu_value = self:FindVariable("fangyu_value")
    self.sepcial_name = self:FindVariable("SpecialName")
    self.fight_power = self:FindVariable("FightPower")
    self.cost_value = self:FindVariable("CostValue")
    self.add_attr_per = self:FindVariable("AddAttrPer")
    self.free_time = self:FindVariable("FreeTime")
    self.show_cancel = self:FindVariable("ShowCancelHuanHua")
    self.show_huan_hua_btn = self:FindVariable("ShowHuanHuaBtn")
    self.show_buy_btn = self:FindVariable("ShowBuyBtn")
    self.show_limit_text = self:FindVariable("ShowLimitText")
    self.show_fetch_flag = self:FindVariable("ShowFetchFlag")
    self.show_active_btn = self:FindVariable("ShowActiveBtn")
    self.show_red_point = self:FindVariable("ShowRedPoint")
    self.level = self:FindVariable("Level")

    self:ListenEvent("OnClickBuy",BindTool.Bind(self.OnClickBuy,self))
    self:ListenEvent("Close",BindTool.Bind(self.ClickClose, self))
    self:ListenEvent("OnClickHuanHua",BindTool.Bind(self.OnClickHuanHua, self))
    self:ListenEvent("OnClickCancelIma",BindTool.Bind(self.OnClickCancelIma, self))
    self:ListenEvent("OnCLickFetch",BindTool.Bind(self.OnCLickFetch, self))
    self:ListenEvent("OnClickActive",BindTool.Bind(self.OnClickActive, self))
end

function SpiritSpecialView:ReleaseCallBack()
    if self.model then
        self.model:DeleteMe()
        self.model = nil
    end

    if self.item then
        self.item:DeleteMe()
        self.item = nil
    end

    self.hp_value = nil
    self.attack_value = nil
    self.fangyu_value = nil
    self.sepcial_name = nil
    self.fight_power = nil
    self.cost_value = nil
    self.add_attr_per = nil
    self.free_time = nil
    self.show_huan_hua = nil
    self.show_huan_hua_btn = nil
    self.show_buy_btn = nil
    self.show_cancel = nil
    self.show_limit_text = nil
    self.show_fetch_flag = nil
    self.show_active_btn = nil
    self.show_red_point = nil
    self.level = nil
    self.display = nil

    self:RemoveCountDown()
end

function SpiritSpecialView:OpenCallBack()
    SpiritCtrl.Instance:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_SPECIAL_JINGLING_INFO)
    self:Flush()
end


function SpiritSpecialView:CloseCallBack()
    -- body
end

function SpiritSpecialView:ClickClose()
    self:Close()
end

function SpiritSpecialView:InitModel()
    local id = SpiritData.Instance:GetSpecialSpiritHuanHuaId()
    local huanhua_cfg = SpiritData.Instance:GetSpecialSpiritImageCfg(id)
    if huanhua_cfg == nil then
        return
    end
    local res_id = huanhua_cfg.res_id
    bundle, asset = ResPath.GetSpiritModel(res_id)
    if bundle and asset and self.model then
        self.model:SetMainAsset(bundle, asset)
    end
end

function SpiritSpecialView:InitDataDisplay()
    --特殊精灵配置
    local spirit_cfg = SpiritData.Instance:GetSingleSpecialSpiritCfgByIndex(1)
    if spirit_cfg == nil then 
        return
    end
    --特殊精灵幻化id
    local special_index = spirit_cfg.param_0 or 0
    --特殊精灵幻化信息
    local huanhua_cfg = SpiritData.Instance:GetSpecialSpiritImageCfg(special_index)
    if huanhua_cfg == nil then
        return
    end

    --幻化按钮
    local spirit_info = SpiritData.Instance:GetSpiritInfo()
    local bit_list = bit:ll2b(spirit_info.special_img_active_flag_high, spirit_info.special_img_active_flag_low)
    self.show_huan_hua_btn:SetValue((bit_list[64 - special_index] == 1) and (spirit_info.phantom_imageid ~= special_index))
    self.show_cancel:SetValue(spirit_info.phantom_imageid == special_index)
    --幻化等级
    local huanhua_level = spirit_info.phantom_level_list[special_index + 1]
    huanhua_level = huanhua_level > 0 and huanhua_level or 1
    self.level:SetValue(huanhua_level or 1)
    --基础属性
    local hp_value = huanhua_cfg.maxhp or 0
    local attack_value = huanhua_cfg.gongji or 0
    local fangyu_value = huanhua_cfg.fangyu or 0
    self.hp_value:SetValue(hp_value)
    self.attack_value:SetValue(attack_value)
    self.fangyu_value:SetValue(fangyu_value)

    local cost = spirit_cfg.cost or 0
    local add_attr = spirit_cfg.add_attr_per or 0
    self.cost_value:SetValue(cost)
    self.add_attr_per:SetValue(string.format(Language.JingLing.SpecialSpiritAttr, add_attr/100))
    self.sepcial_name:SetValue(huanhua_cfg.image_name)
    local data = {item_id = huanhua_cfg.item_id, is_bind = 1}
    self.item:SetData(data)

    --战力计算
    local add_all_power = SpiritData.Instance:GetSpecialSpiritAddAllPower()
    local data = SpiritData.Instance:GetSpiritHuanhuaCfgById(special_index,huanhua_level)
    local attr_list = CommonDataManager.GetAttributteNoUnderline(data, true)
    local power = CommonDataManager.GetCapability(attr_list)
    self.fight_power:SetValue(power + add_all_power)

    --免费时间
    local special_item_index = 1
    local free_remind_time = SpiritData.Instance:GetSpecialSpiritFreeTime(special_item_index)
    if free_remind_time <= 0 then
        self.show_limit_text:SetValue(false) 
    else
        self:RemoveCountDown()
        self.count_down = CountDown.Instance:AddCountDown(free_remind_time, 1, BindTool.Bind(self.FlushCountDown, self))
    end
end

function SpiritSpecialView:RemoveCountDown()
    if CountDown.Instance:HasCountDown(self.count_down) then
        CountDown.Instance:RemoveCountDown(self.count_down)
        self.count_down = nil
    end
end

function SpiritSpecialView:FlushCountDown(elapse_time, total_time)
    local time_interval = total_time - elapse_time
    if time_interval > 0 then
        self:SetTime(time_interval)
    else
        self.show_limit_text:SetValue(false)
    end
end

--按钮的显示
function SpiritSpecialView:OnFlushButtonState()
    local index = 1
    local limit_free_time = SpiritData.Instance:GetSpecialSpiritFreeTime(index) or 0
    local fetch_falg = SpiritData.Instance:GetSpecialSpiritFetchFlag(index)   --是否领取
    local active_card_flag = SpiritData.Instance:GetSpecialSpiritActiveCard(index)  --能否领取
    local active_flag = SpiritData.Instance:GetSpecialSpiritActiveFlag()

    local has_card_in_bag = SpiritData.Instance:HaveSpecialSpiritActiveCardInBag()
    --购买按钮 可领取为0，领取为0
    self.show_buy_btn:SetValue(fetch_falg == false and active_card_flag == false and has_card_in_bag == -1)
    --领取按钮 可领取为1，领取为0
    self.show_fetch_flag:SetValue(active_card_flag == true and fetch_falg == false)
    --激活按钮 已领取fetch_flag = 1
    self.show_active_btn:SetValue(active_flag == false and (fetch_falg == true or has_card_in_bag ~= -1))
    --限时文字
    local limit_tiem_show = (limit_free_time > 0 and active_flag == false and active_card_flag == false)
    self.show_limit_text:SetValue(limit_tiem_show and (has_card_in_bag == -1) and fetch_falg == false)
    self.show_red_point:SetValue(has_card_in_bag ~= -1)
end

function SpiritSpecialView:OnFlush()
    self:InitModel()
    self:InitDataDisplay()
    self:OnFlushButtonState()
end

function SpiritSpecialView:OnClickBuy()
    local index = 1
    local spirit_cfg = SpiritData.Instance:GetSingleSpecialSpiritCfgByIndex(index)
    local cost_gold = spirit_cfg.cost or 0
  
    local ok_fun = function ()
        local vo = GameVoManager.Instance:GetMainRoleVo()
        if vo.gold < cost_gold then
            TipsCtrl.Instance:ShowLackDiamondView()
            return
        else
            SpiritCtrl.Instance:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_SPECIAL_JINGLING_BUY,spirit_cfg.special_item_index)
        end
    end
    local tips_text = string.format(Language.JingLing.BuySpecialTips, cost_gold)
    TipsCtrl.Instance:ShowCommonTip(ok_fun, nil, tips_text)
    return
end

function SpiritSpecialView:OnClickHuanHua()
    local special_img_id = SpiritData.Instance:GetSpecialSpiritHuanHuaId()
    SpiritCtrl.Instance:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_PHANTOM, 0, 0, 0, special_img_id, "")
end

function SpiritSpecialView:OnClickCancelIma()
    SpiritCtrl.Instance:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_PHANTOM, 0, 0, 0, - 1, "")
end

function SpiritSpecialView:OnCLickFetch()
    local title_cfg = SpiritData.Instance:GetSingleSpecialSpiritCfgByIndex(1)
    if title_cfg == nil then
        return
    end
    local select_index = title_cfg.special_item_index
    SpiritCtrl.Instance:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_SPECIAL_JINGLING_FETCH,select_index)
end

function SpiritSpecialView:OnClickActive()
    local special_index = SpiritData.Instance:GetSpecialSpiritHuanHuaId()
    local huanhua_cfg = SpiritData.Instance:GetSpecialSpiritImageCfg(special_index)
    if huanhua_cfg == nil then
        return 
    end
    local has_card_in_bag = SpiritData.Instance:HaveSpecialSpiritActiveCardInBag()
    if has_card_in_bag == -1 then
        TipsCtrl.Instance:ShowSystemMsg(string.format(Language.Common.ActivedErrorTips, huanhua_cfg.image_name))
        return
    end
    SpiritCtrl.Instance:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_UPPHANTOM, 0, 0, 0, special_index, "")
end

--设置时间
function SpiritSpecialView:SetTime(time)
    local show_time_str = ""
    if time > 3600 * 24 then
        show_time_str = TimeUtil.FormatSecond(time, 7)
    elseif time > 3600 then
        show_time_str = TimeUtil.FormatSecond(time, 1)
    else
        show_time_str = TimeUtil.FormatSecond(time, 4)
    end
    self.free_time:SetValue(show_time_str)
end