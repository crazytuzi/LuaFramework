--------------------------------------------------------------------------
-- SwordArtOnlineView 刀剑神域面板
--------------------------------------------------------------------------
SwordArtOnlineView = SwordArtOnlineView or BaseClass(BaseRender)
local Tips_Type =
{
    ALL_HUALING = 1,
    HUALING_TIPS = 2,
    LINGZHU_TIPS = 3,
    BUY_TIPS = 4,
}

local BUY_LINGLI = "buy_lingli"

function SwordArtOnlineView:__init()
    SwordArtOnlineView.Instance = self
    self.icon_right_cell_list = {}
    self.icon_left_cell_list = {}
    self:InitView()
end

function SwordArtOnlineView:__delete()
    SwordArtOnlineView.Instance = nil

    for k,v in pairs(self.icon_right_cell_list) do
        if v then
            v:DeleteMe()
        end
    end

    self.icon_right_cell_list = {}

    for k,v in pairs(self.icon_left_cell_list) do
        if v then
            v:DeleteMe()
        end
    end
    UnityEngine.PlayerPrefs.DeleteKey(BUY_LINGLI)

    self.icon_left_cell_list = {}
end

function SwordArtOnlineView:InitView()
    self:ListenEvent("ClosenBuyClick", BindTool.Bind(self.OnClosenBuyClick, self))
    self:ListenEvent("ClosenUpLevelClick", BindTool.Bind(self.OnClosenUpLevelClick, self))
    self:ListenEvent("BuyClick", BindTool.Bind(self.OnBuyClick, self))
    self:ListenEvent("HelpClick", BindTool.Bind(self.OnHelpClick, self))
    self:ListenEvent("PreviewClick", BindTool.Bind(self.OnPreviewClick, self))
    self:ListenEvent("UpLevelClick", BindTool.Bind(self.OnUpLevelClick, self))
    self:ListenEvent("PlusClick", BindTool.Bind(self.OnPlusClick, self))
    self:ListenEvent("SubClick", BindTool.Bind(self.OnSubClick, self))
    self:ListenEvent("LingZhuClick", BindTool.Bind(self.OnLingZhuClick, self))
    self:ListenEvent("ClosenLingZhuClick", BindTool.Bind(self.OnClosenLingZhuClick, self))
    self:ListenEvent("ClosenBagClick", BindTool.Bind(self.OnClosenBagClick, self))
    self:ListenEvent("AllHuaLingClick", BindTool.Bind(self.OnAllHuaLingClick, self))
    self:ListenEvent("HuaLingClick", BindTool.Bind(self.OnHuaLingClick, self))
    self:ListenEvent("ClosenHuaLingClick", BindTool.Bind(self.OnClosenHuaLingClick, self))
    self:ListenEvent("ReciveClick", BindTool.Bind(self.OnReciveClick, self))

    self:ListenEvent("GreenBuyClick", BindTool.Bind(self.OnGreenBuyClick, self))
    self:ListenEvent("OrangeBuyClick", BindTool.Bind(self.OnOrangeBuyClick, self))
    self:ListenEvent("PurpleBuyClick", BindTool.Bind(self.OnPurpleBuyClick, self))
    self:ListenEvent("ReciveTenAgainClick", BindTool.Bind(self.OnReciveTenAgainClick, self))
    self:ListenEvent("ReciveTenClick", BindTool.Bind(self.OnReciveTenClick, self))
    self:ListenEvent("AddGold",BindTool.Bind(self.HandleAddGold, self))

    self.zh_name_level_cur = self:FindVariable("zh_name_level_cur")
    self.zh_name_level_next = self:FindVariable("zh_name_level_next")
    self.need_liling = self:FindVariable("need_liling")
    self.def_cur = self:FindVariable("def_cur")
    self.hp_cur = self:FindVariable("hp_cur")
    self.atk_cur = self:FindVariable("atk_cur")
    self.def_next = self:FindVariable("def_next")
    self.hp_next = self:FindVariable("hp_next")
    self.atk_next = self:FindVariable("atk_next")
    self.have_lingli = self:FindVariable("have_lingli")
    self.want_level = self:FindVariable("want_level")
    self.have_sword_num = self:FindVariable("have_sword_num")
    self.need_sword_num = self:FindVariable("need_sword_num")
    self.sword_name = self:FindVariable("sword_name")
    self.cardzu_name = self:FindVariable("cardzu_name")
    self.recieve_lingli = self:FindVariable("recieve_lingli")
    self.active_num = self:FindVariable("active_num")
    self.tips_text = self:FindVariable("tips_text")
    self.today_buy_num = self:FindVariable("today_buy_num")
    self.is_angle = self:FindVariable("is_angle")
    self.batch_need_gold = self:FindVariable("batch_need_gold")
    self.need_gold = self:FindVariable("need_gold")
    self.ten_need_gold = self:FindVariable("ten_need_gold")
    self.bind_get_lingli = self:FindVariable("bind_get_lingli")
    self.one_get_lingli = self:FindVariable("one_get_lingli")
    self.ten_get_lingli = self:FindVariable("ten_get_lingli")
    self.is_max_level = self:FindVariable("is_max_level")
    self.bt_text = self:FindVariable("bt_text")
    self.gold = self:FindVariable("gold")
    self.get_lingli = self:FindVariable("get_lingli")

    self.left_data = {}
    self.right_data = {}
    self.uplevel_data = {}
    self.ling_zhu_data = {}
    self.hua_ling_data = {}
    self.cur_card_id = 0
    self.is_uplevel_active = false
    self.is_lingzhu_active = false
    self.is_bag_active = false
    self.is_hualing_active = false
    self.is_receive_one = false
    self.is_receive_ten = false
    self.is_buy = false
    self.tips_type = Tips_Type.ALL_HUALING

    self.buy_rect = self:FindObj("buy_rect")
    self.up_level_rect = self:FindObj("up_level_rect")
    self.ling_zhu_rect = self:FindObj("ling_zhu_rect")
    self.bag_rect = self:FindObj("bag_rect")
    self.hua_ling_rect = self:FindObj("hua_ling_rect")
    -- self.recive_one_rect = self:FindObj("recive_one_rect")
    self.upLevelBt = self:FindObj("upLevelBt")
    self.next_attr = self:FindObj("next_attr")
    self.full_level_tips = self:FindObj("full_level_tips")
    -- self.recive_ten_rect = self:FindObj("recive_ten_rect")

    -- 提示框
    self.cellobj_list = {}
    self.cell_variable_table = {}
    self.cell_name_table = {}
    self.cell_sword_list = {}
    self.cell_star_bg_list = {}
    -- self.cell_star_list = {}
    for i=1,2 do
        self.cellobj_list[i] = self:FindObj("CellObj"..i)
        self.cell_variable_table[i] = self.cellobj_list[i]:GetComponent(typeof(UIVariableTable))
        self.cell_name_table[i] = self.cellobj_list[i]:GetComponent(typeof(UINameTable))
        self.cell_sword_list[i] = self.cell_variable_table[i]:FindVariable("sword")
        self.cell_star_bg_list[i] = self.cell_variable_table[i]:FindVariable("star_bg")
        -- self.cell_star_list[i] = {}
        -- for j=1,6 do
        --     self.cell_star_list[i][j] = self.cell_name_table[i]:Find("star0"..j)
        -- end
    end

    self:InitRightListView()
    self:InitLeftListView()

    -- 背包
    self.bag_list = {}
    self.bag_name_table = {}
    self.bag_variable_table = {}
    self.bag_event_table = {}
    self.sword_list = {}
    self.star_bg_list = {}
    self.num_lst = {}
    -- self.is_gray_list = {}
    -- self.star_list = {}
    for i = 1, 18 do
        self.bag_list[i] = self:FindObj("BagObj" .. i)
        self.bag_name_table[i] = self.bag_list[i]:GetComponent(typeof(UINameTable))
        self.bag_variable_table[i] = self.bag_list[i]:GetComponent(typeof(UIVariableTable))
        self.bag_event_table[i] = self.bag_list[i]:GetComponent(typeof(UIEventTable))

        -- 获取变量
        self.sword_list[i] = self.bag_variable_table[i]:FindVariable("sword")
        self.star_bg_list[i] = self.bag_variable_table[i]:FindVariable("star_bg")
        self.num_lst[i] = self.bag_variable_table[i]:FindVariable("num")
        -- self.is_gray_list[i] = self.bag_variable_table[i]:FindVariable("is_gray")

        self.bag_event_table[i]:ListenEvent("Click", BindTool.Bind2(self.OnBagCellClick, self, i))

        -- self.star_list[i] = {}
        -- for j=1,6 do
        --     self.star_list[i][j] = self.bag_name_table[i]:Find("star0"..j)
        -- end
    end

    -- 十连抽框
    -- self.tenobj_list = {}
    -- self.ten_variable_table = {}
    -- self.ten_name_table = {}
    -- self.ten_sword_list = {}
    -- self.ten_star_bg_list = {}
    -- -- self.ten_star_list = {}
    -- self.ten_name_list = {}
    -- for i=1,10 do
    --     self.tenobj_list[i] = self:FindObj("RecieveObj"..i)
    --     self.ten_variable_table[i] = self.tenobj_list[i]:GetComponent(typeof(UIVariableTable))
    --     self.ten_name_table[i] = self.tenobj_list[i]:GetComponent(typeof(UINameTable))
    --     self.ten_sword_list[i] = self.ten_variable_table[i]:FindVariable("sword")
    --     self.ten_star_bg_list[i] = self.ten_variable_table[i]:FindVariable("star_bg")
    --     self.ten_name_list[i] = self.ten_variable_table[i]:FindVariable("name")
    --     -- self.ten_star_list[i] = {}
    --     -- for j=1,6 do
    --     --     self.ten_star_list[i][j] = self.ten_name_table[i]:Find("star0"..j)
    --     -- end
    -- end
end

function SwordArtOnlineView:HandleAddGold()
    VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
    ViewManager.Instance:Open(ViewName.VipView)
end

function SwordArtOnlineView:FlushGold()
    local vo = GameVoManager.Instance:GetMainRoleVo()
    local count = vo.gold
    if count > 99999 and count <= 99999999 then
        count = count / 10000
        count = math.floor(count)
        count = count .. Language.Common.Wan
    elseif count > 99999999 then
        count = count / 100000000
        count = math.floor(count)
        count = count .. Language.Common.Yi
    end
    self.gold:SetValue(count)
end

function SwordArtOnlineView:FlushSwordRedPt()
    MoLongView.Instance:SwordArtOnlineShowRedPoint(false)
    for j=1,4 do
        for i=1,7 do
            local level = SwordArtOnlineData.Instance:GetZhLevelById(i - 1)
            if level < 1 then
                level = 1
            end
            right_data = SwordArtOnlineData.Instance:GetCellDataByIdAndLevel(j - 1,i - 1,level,true)
            cur_zh_level = SwordArtOnlineData.Instance:GetZhLevelById(right_data.zuhe_idx)
            local have_num_list = {}
            have_num_list[1] = SwordArtOnlineData.Instance:GetSwordNumById(right_data.need_card1_id)
            have_num_list[2] = SwordArtOnlineData.Instance:GetSwordNumById(right_data.need_card2_id)
            have_num_list[3] = SwordArtOnlineData.Instance:GetSwordNumById(right_data.need_card3_id)

            if cur_zh_level <= 0 then
                if have_num_list[1] >= right_data.need_card1_num and have_num_list[2] >= right_data.need_card2_num and have_num_list[3] >= right_data.need_card3_num then
                   MoLongView.Instance:SwordArtOnlineShowRedPoint(true)
                   return
                end
            end
        end
    end
end

function SwordArtOnlineView:FlushInfoView()
    self:FlushGold()
    self.have_lingli:SetValue(SwordArtOnlineData.Instance:GetLingLi())
    self:FlushLeftInfo()
    self:FlushRightInfo()
    self.active_num:SetValue(string.format("%s/%s",SwordArtOnlineData.Instance:GetCzActiveNum(),28))
    if self.is_receive_one then
        self:FlushOneReceive()
    end

    if self.is_buy then
        self.today_buy_num:SetValue(5 - SwordArtOnlineData.Instance:GetCurCardZuBuyTimesById(self.cur_card_id))
    end

    if self.is_receive_ten then
        self:FlushTenReceive()
    end

    if self.is_uplevel_active then
        self:FlushUpLevel()
    end

    if self.is_lingzhu_active then
        self:FlushLingZhu()
    end

    if self.is_bag_active then
        self:FlushPreviewBag()
    end

    if self.is_hualing_active then
        self:FlushHuaLing()
    end
end

function SwordArtOnlineView:GetCurSelectIndex()
    return self.cur_card_id or 0
end

function SwordArtOnlineView:OnClosenBuyClick()
    self.buy_rect:SetActive(false)
end

function SwordArtOnlineView:OnClosenUpLevelClick()
    self.up_level_rect:SetActive(false)
    self.is_uplevel_active = false
end

function SwordArtOnlineView:HideRect()
    self.is_uplevel_active = false
    self.is_lingzhu_active = false
    self.is_bag_active = false
    self.is_hualing_active = false
    self.is_receive_one = false
    self.is_receive_ten = false
    self.is_buy = false
    self.up_level_rect:SetActive(false)
    self.buy_rect:SetActive(false)
    self.ling_zhu_rect:SetActive(false)
    self.bag_rect:SetActive(false)
    self.hua_ling_rect:SetActive(false)
    -- self.bag_tips_rect:SetActive(false)
    -- self.recive_one_rect:SetActive(false)
    -- self.recive_ten_rect:SetActive(false)
end

function SwordArtOnlineView:OnBuyClick()
    self.buy_rect:SetActive(true)
    self.batch_need_gold:SetValue(SwordArtOnlineData.Instance:GetChouCardInfo().choucard_need_gold_bind)
    self.need_gold:SetValue(SwordArtOnlineData.Instance:GetChouCardInfo().choucard_need_gold)
    self.ten_need_gold:SetValue(SwordArtOnlineData.Instance:GetChouCardInfo().choucard_batch_need_gold)
    self.today_buy_num:SetValue(SwordArtOnlineData.Instance:GetChouCardInfo().gold_bind_chouka_max_time - SwordArtOnlineData.Instance:GetCurCardZuBuyTimesById(self.cur_card_id))
    self.bind_get_lingli:SetValue(SwordArtOnlineData.Instance:GetChouCardInfo().gold_bind_choucard_lingli)
    self.one_get_lingli:SetValue(SwordArtOnlineData.Instance:GetChouCardInfo().gold_choucard_lingli)
    self.ten_get_lingli:SetValue(SwordArtOnlineData.Instance:GetChouCardInfo().batch_gold_choucard_lingli)
end

function SwordArtOnlineView:OnHelpClick()
    local tips_id = 84 -- 神域帮助
    TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function SwordArtOnlineView:OnPreviewClick()
    self:OpenPreviewBag()
end

function SwordArtOnlineView:OnGreenBuyClick()
   self.is_buy = true
   local num = SwordArtOnlineData.Instance:GetCurCardZuBuyTimesById(self.cur_card_id)
   if num > SwordArtOnlineData.Instance:GetChouCardInfo().gold_bind_chouka_max_time - 1 then
        TipsCtrl.Instance:ShowSystemMsg(Language.EquipShen.TodayNotBuy)
        return
   end

   if GameVoManager.Instance:GetMainRoleVo().bind_gold < SwordArtOnlineData.Instance:GetChouCardInfo().choucard_need_gold_bind then
        TipsCtrl.Instance:ShowSystemMsg(Language.Common.NoBindGold)
        return
   end

   SwordArtOnlineData.Instance:SetCurBuyLottoType(0)
   MoLongCtrl.Instance:SendSwordArtOnlineOperaReq(CARDZU_REQ_TYPE.CARDZU_REQ_TYPE_CHOU_CARD,self.cur_card_id,3)
   self:OpenOneReceive(true)
end

function SwordArtOnlineView:OnOrangeBuyClick()
    if GameVoManager.Instance:GetMainRoleVo().gold < SwordArtOnlineData.Instance:GetChouCardInfo().choucard_need_gold then
        TipsCtrl.Instance:ShowLackDiamondView()
        return
   end

    SwordArtOnlineData.Instance:SetCurBuyLottoType(0)
    MoLongCtrl.Instance:SendSwordArtOnlineOperaReq(CARDZU_REQ_TYPE.CARDZU_REQ_TYPE_CHOU_CARD,self.cur_card_id,1)
    self:OpenOneReceive(false)
end

function SwordArtOnlineView:OnPurpleBuyClick()
    if GameVoManager.Instance:GetMainRoleVo().gold < (SwordArtOnlineData.Instance:GetChouCardInfo().choucard_batch_need_gold) then
        TipsCtrl.Instance:ShowLackDiamondView()
        return
    end

    SwordArtOnlineData.Instance:SetCurBuyLottoType(1)
    MoLongCtrl.Instance:SendSwordArtOnlineOperaReq(CARDZU_REQ_TYPE.CARDZU_REQ_TYPE_CHOU_CARD,self.cur_card_id,2)
    self:OpenTenReceive()
    -- self.tips_type = Tips_Type.BUY_TIPS
    -- self:OpenTipsRect()
end

function SwordArtOnlineView:SetCurCardId(id)
   self.cur_card_id = id
end

function SwordArtOnlineView:SetLottoType(LOTTO_TYPE)
    if LOTTO_TYPE == CHEST_SHOP_MODE.CHEST_SWORD_BIND_MODE_1 then
        self:OpenOneReceive(true)
    elseif LOTTO_TYPE ==CHEST_SHOP_MODE.CHEST_SWORD_GOLD_MODE_1 then
        self:OpenOneReceive(false)
    elseif LOTTO_TYPE ==CHEST_SHOP_MODE.CHEST_SWORD_GOLD_MODE_10 then
        self:OpenTenReceive(true)
    end
end

-- 一次抽领奖框
function SwordArtOnlineView:OpenOneReceive(is_bind_buy)
    -- self.recive_one_rect:SetActive(true)
    self.is_receive_one = true
    self.is_bind_buy = is_bind_buy
end

function SwordArtOnlineView:FlushOneReceive()
    self.is_receive_one = false

    if self.is_bind_buy then
        TipsCtrl.Instance:ShowTreasureView(CHEST_SHOP_MODE.CHEST_SWORD_BIND_MODE_1)
        -- self.get_lingli:SetValue(SwordArtOnlineData.Instance:GetChouCardInfo().gold_bind_choucard_lingli)
    else
        TipsCtrl.Instance:ShowTreasureView(CHEST_SHOP_MODE.CHEST_SWORD_GOLD_MODE_1)
        -- self.get_lingli:SetValue(SwordArtOnlineData.Instance:GetChouCardInfo().gold_choucard_lingli)
    end
    -- self.sword_name:SetValue(SwordArtOnlineData.Instance:GetSwordNameByOneReceive().name)
    -- for i=1,6 do
    --     self.cell_star_list[3][i]:SetActive(false)
    -- end

    -- for i=1,SwordArtOnlineData.Instance:GetSwordNameByOneReceive().star_count do
    --     self.cell_star_list[3][i]:SetActive(true)
    -- end
    -- local star_str = "star_bg_"..SwordArtOnlineData.Instance:GetSwordNameByOneReceive().star_count
    -- self.cell_star_bg_list[3]:SetAsset("uis/views/swordartonline",star_str)

    -- local sword_str = "sword_"..SwordArtOnlineData.Instance:GetSwordNameByOneReceive().res_id
    -- self.cell_sword_list[3]:SetAsset("uis/views/swordartonline",sword_str)
end

function SwordArtOnlineView:OnReciveClick()
    self.is_receive_one = false
    -- self.recive_one_rect:SetActive(false)
end
-- 结束

-- 十次抽框
function SwordArtOnlineView:OpenTenReceive()
    -- self.recive_ten_rect:SetActive(true)
    self.is_receive_ten = true
end

function SwordArtOnlineView:FlushTenReceive()
    -- for i=1,10 do
    --     local data = SwordArtOnlineData.Instance:GetSwordNameByTenReceive(i)
    --     self.ten_name_list[i]:SetValue(data.name)
    --     -- for j=1,6 do
    --     --     self.ten_star_list[i][j]:SetActive(false)
    --     -- end

    --     -- for j=1,data.star_count do
    --     --     self.ten_star_list[i][j]:SetActive(true)
    --     -- end
    --     local star_str = "star_bg_"..data.star_count
    --     self.ten_star_bg_list[i]:SetAsset("uis/views/swordartonline",star_str)

    --     local sword_str = "sword_"..data.res_id
    --     self.ten_sword_list[i]:SetAsset("uis/views/swordartonline",sword_str)
    -- end
    self.is_receive_ten = false
    TipsCtrl.Instance:ShowTreasureView(CHEST_SHOP_MODE.CHEST_SWORD_GOLD_MODE_10)
end

function SwordArtOnlineView:OnReciveTenAgainClick()
    MoLongCtrl.Instance:SendSwordArtOnlineOperaReq(CARDZU_REQ_TYPE.CARDZU_REQ_TYPE_CHOU_CARD,self.cur_card_id,2)
    self:OpenTenReceive()
end

function SwordArtOnlineView:OnReciveTenClick()
    self.is_receive_ten = false
    -- self.recive_ten_rect:SetActive(false)
end
-- 结束

-- 提示框
function SwordArtOnlineView:FlushTipsRect()
    local OnAllHuaLingSureClick = function ()
        if self.tips_type == Tips_Type.ALL_HUALING then
            local data = {}
            local have_num = 0
            local is_send = false
            for i=1,18 do
                data = SwordArtOnlineData.Instance:GetBagInfoByIdAndIndex(self.cur_card_id,i)
                have_num = SwordArtOnlineData.Instance:GetSwordNumById(data.card_idx)
                if have_num > 0 and SwordArtOnlineData.Instance:GetCanIsHuaLing(self.cur_card_id,data.card_idx) then
                    MoLongCtrl.Instance:SendSwordArtOnlineOperaReq(CARDZU_REQ_TYPE.CARDZU_REQ_TYPE_HUALING,data.card_idx,have_num)
                    is_send = true
                end
            end

            if not is_send then
                TipsCtrl.Instance:ShowSystemMsg(Language.EquipShen.NoHuaLingCard)
            end
        elseif self.tips_type == Tips_Type.HUALING_TIPS then
            local have_num = SwordArtOnlineData.Instance:GetSwordNumById(self.hua_ling_data.card_idx)
            MoLongCtrl.Instance:SendSwordArtOnlineOperaReq(CARDZU_REQ_TYPE.CARDZU_REQ_TYPE_HUALING,self.hua_ling_data.card_idx,have_num)
            self:OnClosenHuaLingClick()
        elseif self.tips_type == Tips_Type.LINGZHU_TIPS then
            if self.is_hualing_active then
                MoLongCtrl.Instance:SendSwordArtOnlineOperaReq(CARDZU_REQ_TYPE.CARDZU_REQ_TYPE_LINGZHU,self.hua_ling_data.card_idx)
            elseif self.is_lingzhu_active then
                MoLongCtrl.Instance:SendSwordArtOnlineOperaReq(CARDZU_REQ_TYPE.CARDZU_REQ_TYPE_LINGZHU,self.ling_zhu_data.card_idx)
            end
        elseif self.tips_type == Tips_Type.BUY_TIPS then
            MoLongCtrl.Instance:SendSwordArtOnlineOperaReq(CARDZU_REQ_TYPE.CARDZU_REQ_TYPE_CHOU_CARD,self.cur_card_id,2)
            self:OpenTenReceive()
        end
    end
    if self.tips_type == Tips_Type.ALL_HUALING then
        TipsCtrl.Instance:ShowCommonTip(OnAllHuaLingSureClick,nil,Language.EquipShen.SureAllHuaLing)
    elseif self.tips_type == Tips_Type.HUALING_TIPS then
        local have_num = SwordArtOnlineData.Instance:GetSwordNumById(self.hua_ling_data.card_idx)
        local value = self.hua_ling_data.got_lingli * have_num
        TipsCtrl.Instance:ShowCommonTip(OnAllHuaLingSureClick,nil,string.format(Language.EquipShen.CardHuaLing,self.hua_ling_data.name,have_num,value))
    elseif self.tips_type == Tips_Type.LINGZHU_TIPS then
        if self.is_hualing_active then
            TipsCtrl.Instance:ShowCommonTip(OnAllHuaLingSureClick,nil,string.format(Language.EquipShen.CardLingZhu,self.hua_ling_data.need_lingli,self.hua_ling_data.name))
        elseif self.is_lingzhu_active then
            TipsCtrl.Instance:ShowCommonTip(OnAllHuaLingSureClick,nil,string.format(Language.EquipShen.CardLingZhu,self.ling_zhu_data.need_lingli,self.ling_zhu_data.name))
        end
    elseif self.tips_type == Tips_Type.BUY_TIPS then
        TipsCtrl.Instance:ShowCommonTip(OnAllHuaLingSureClick,nil,Language.EquipShen.BuyTenConfirmTip,nil,nil,true,nil,BUY_LINGLI)
    end
end

function SwordArtOnlineView:OpenTipsRect()
    self:FlushTipsRect()
end
-- 结束

-- 预览背包
function SwordArtOnlineView:OpenPreviewBag()
    self.is_bag_active = true
    self.bag_rect:SetActive(true)
    self:FlushPreviewBag()
end

function SwordArtOnlineView:FlushPreviewBag()
    self.have_lingli:SetValue(SwordArtOnlineData.Instance:GetLingLi())
    self.cardzu_name:SetValue(SwordArtOnlineData.Instance:GetCardZuInfoById(self.cur_card_id).cardzu_name)

    -- bag
    local data = {}
    local have_num = 0
    for i=1,18 do
        data = SwordArtOnlineData.Instance:GetBagInfoByIdAndIndex(self.cur_card_id,i)
        have_num = SwordArtOnlineData.Instance:GetSwordNumById(data.card_idx)

        local star_str = "star_bg_"..data.star_count
        self.star_bg_list[i]:SetAsset("uis/views/swordartonline",star_str)

        local sword_str = "sword_"..data.res_id
        self.sword_list[i]:SetAsset("uis/views/swordartonline",sword_str)

        self.num_lst[i]:SetValue(have_num)
        -- if have_num < 1 then
        --     self.is_gray_list[i]:SetValue(false)
        --     self.num_lst[i]:SetValue("")
        -- else
        --     self.is_gray_list[i]:SetValue(true)
        -- end

        -- for j=1,6 do
        --     self.star_list[i][j]:SetActive(false)
        -- end

        -- for j=1,data.star_count do
        --     self.star_list[i][j]:SetActive(true)
        -- end
    end
end

function SwordArtOnlineView:OnBagCellClick(i)
    local data = SwordArtOnlineData.Instance:GetBagInfoByIdAndIndex(self.cur_card_id,i)
    self:OpenHuaLing(data)
end

function SwordArtOnlineView:OnClosenBagClick()
    self.is_bag_active = false
    self.bag_rect:SetActive(false)
end

function SwordArtOnlineView:OnAllHuaLingClick()
    self.tips_type = Tips_Type.ALL_HUALING
    self:OpenTipsRect()
end
-- 结束

-- 化灵
function SwordArtOnlineView:OpenHuaLing(data)
    self.hua_ling_data = data
    self.hua_ling_rect:SetActive(true)
    self.is_hualing_active = true
    self:FlushHuaLing()
end

function SwordArtOnlineView:FlushHuaLing()
    self.lingli = SwordArtOnlineData.Instance:GetLingLi()

    self.recieve_lingli:SetValue(self.hua_ling_data.got_lingli)

    if self.hua_ling_data.need_lingli > self.lingli then
        self.need_liling:SetValue(string.format("<color=#ff0000>%s</color>",self.hua_ling_data.need_lingli))
    else
        self.need_liling:SetValue(self.hua_ling_data.need_lingli)
    end
    self.sword_name:SetValue(self.hua_ling_data.name)

    local have_num = SwordArtOnlineData.Instance:GetSwordNumById(self.hua_ling_data.card_idx)
    if have_num > self.lingli then
        self.have_sword_num:SetValue(string.format("<color=#ff0000>%s</color>",have_num))
    else
        self.have_sword_num:SetValue(have_num)
    end

    -- for i=1,6 do
    --     self.cell_star_list[2][i]:SetActive(false)
    -- end

    -- for i=1,self.hua_ling_data.star_count do
    --     self.cell_star_list[2][i]:SetActive(true)
    -- end
    local star_str = "star_bg_"..self.hua_ling_data.star_count
    self.cell_star_bg_list[2]:SetAsset("uis/views/swordartonline",star_str)

    local sword_str = "sword_"..self.hua_ling_data.res_id
    self.cell_sword_list[2]:SetAsset("uis/views/swordartonline",sword_str)
end

function SwordArtOnlineView:OnHuaLingClick()
    self.tips_type = Tips_Type.HUALING_TIPS
    if SwordArtOnlineData.Instance:GetSwordNumById(self.hua_ling_data.card_idx) > 0 then
        self:OpenTipsRect()
    else
        TipsCtrl.Instance:ShowSystemMsg(Language.EquipShen.CardNumLack)
    end
end

function SwordArtOnlineView:OnClosenHuaLingClick()
    self.is_hualing_active = false
    self.hua_ling_rect:SetActive(false)
end
-- 结束

-- 灵铸
function SwordArtOnlineView:OnLingZhuClick()
    self.tips_type = Tips_Type.LINGZHU_TIPS
    self:OpenTipsRect()
end

function SwordArtOnlineView:OpenLingZhu(data)
    self.is_lingzhu_active = true
    self.ling_zhu_rect:SetActive(true)
    self.ling_zhu_data = data
    self:FlushLingZhu()
end

function SwordArtOnlineView:FlushLingZhu()
    self.lingli = SwordArtOnlineData.Instance:GetLingLi()
    -- print_error("self",self.ling_zhu_data)
    local have_num = SwordArtOnlineData.Instance:GetSwordNumById(self.ling_zhu_data.card_idx)
    local data = SwordArtOnlineData.Instance:GetInfoBySwordId(self.ling_zhu_data.index,self.ling_zhu_data.card_idx)
    local cur_data = {}
    cur_data = SwordArtOnlineData.Instance:GetCellDataByIdAndLevel(self.cur_card_id,data.zuhe_idx,1)
    self.need_liling:SetValue(self.ling_zhu_data.need_lingli)
    if self.lingli < self.ling_zhu_data.need_lingli then
        self.have_lingli:SetValue(string.format("<color=#ff0000>%s</color>",self.lingli))
    else
        self.have_lingli:SetValue(self.lingli)
    end
    if have_num < data.need_num then
        self.have_sword_num:SetValue(string.format("<color=#ff0000>%s</color>",have_num))
    else
        self.have_sword_num:SetValue(have_num)
    end
    -- print_error(">>>>>>>>",data)
    self.need_sword_num:SetValue(data.need_num)
    self.sword_name:SetValue(self.ling_zhu_data.name)
    -- for i=1,6 do
    --     self.cell_star_list[1][i]:SetActive(false)
    -- end

    -- for i=1,self.ling_zhu_data.star_count do
    --     self.cell_star_list[1][i]:SetActive(true)
    -- end
    local star_str = "star_bg_"..self.ling_zhu_data.star_count
    self.cell_star_bg_list[1]:SetAsset("uis/views/swordartonline",star_str)

    local sword_str = "sword_"..self.ling_zhu_data.res_id
    self.cell_sword_list[1]:SetAsset("uis/views/swordartonline",sword_str)
end

function SwordArtOnlineView:OnClosenLingZhuClick()
    self.is_lingzhu_active = false
    self.ling_zhu_rect:SetActive(false)
end
-- 结束

--  升级面板
function SwordArtOnlineView:OpenUpLevel(data)
    self.need_ll = 0
    self.up_level_rect:SetActive(true)
    self.uplevel_data = data
    if self.uplevel_data.cur_zh_level > 10 then
        self.uplevel_data.want_level = self.uplevel_data.cur_zh_level
    else
        self.uplevel_data.want_level = self.uplevel_data.cur_zh_level + 1
        local next_data = SwordArtOnlineData.Instance:GetCellDataByIdAndLevel(self.uplevel_data.cardzu_id,self.uplevel_data.zuhe_idx,self.uplevel_data.cur_zh_level)
        self.need_ll = self.need_ll + next_data.upgrade_need_lingli
    end
    self.is_uplevel_active = true
    self:FlushUpLevel()
end

function SwordArtOnlineView:OnUpLevelClick()
    MoLongCtrl.Instance:SendSwordArtOnlineOperaReq(CARDZU_REQ_TYPE.CARDZU_REQ_TYPE_UPGRADE_ZUHE,self.uplevel_data.zuhe_idx,self.uplevel_data.want_level)
    if self.lingli >= self.need_ll then
        self.need_ll = 0
        self:OnPlusClick()
    end
end

function SwordArtOnlineView:OnPlusClick()
    if self.uplevel_data.want_level < 11 then
        local next_data = SwordArtOnlineData.Instance:GetCellDataByIdAndLevel(self.uplevel_data.cardzu_id,self.uplevel_data.zuhe_idx,self.uplevel_data.want_level)
        self.need_ll = self.need_ll + next_data.upgrade_need_lingli
        self.uplevel_data.want_level = self.uplevel_data.want_level + 1
    end
    self:FlushUpLevel()
end

function SwordArtOnlineView:OnSubClick()
    if self.uplevel_data.want_level > self.uplevel_data.cur_zh_level + 1 then
        self.uplevel_data.want_level = self.uplevel_data.want_level - 1
        local next_data = SwordArtOnlineData.Instance:GetCellDataByIdAndLevel(self.uplevel_data.cardzu_id,self.uplevel_data.zuhe_idx,self.uplevel_data.want_level)
        self.need_ll = self.need_ll - next_data.upgrade_need_lingli
    end
    self:FlushUpLevel()
end

function SwordArtOnlineView:FlushUpLevel()
    self.lingli = SwordArtOnlineData.Instance:GetLingLi()
    self.uplevel_data.cur_zh_level = SwordArtOnlineData.Instance:GetZhLevelById(self.uplevel_data.zuhe_idx)
    self.zh_name_level_cur:SetValue(string.format("%s <color=#ffff00>LV.%s</color>",self.uplevel_data.zuhe_name,self.uplevel_data.cur_zh_level))
    self.zh_name_level_next:SetValue(string.format("%s <color=#ffff00>LV.%s</color>",self.uplevel_data.zuhe_name,self.uplevel_data.want_level))

    local cur_data = {}
    cur_data = SwordArtOnlineData.Instance:GetCellDataByIdAndLevel(self.uplevel_data.cardzu_id,self.uplevel_data.zuhe_idx,self.uplevel_data.cur_zh_level)

    local is_angle = false
    local value = 0
    if cur_data.fang_yu > 0 and cur_data.max_hp > 0 and cur_data.gong_ji > 0 then
        is_angle = false
    else
        is_angle = true
        if cur_data.max_hp > 0 then
            value = string.format(Language.Common.PassvieSkillAttr.max_hp.." <color=#00ff00>+ %s</color>",cur_data.max_hp)
        elseif cur_data.fang_yu > 0 then
            value = string.format(Language.Common.PassvieSkillAttr.fang_yu.." <color=#00ff00>+ %s</color>",cur_data.fang_yu)
        elseif cur_data.gong_ji > 0 then
            value = string.format(Language.Common.PassvieSkillAttr.gong_ji.." <color=#00ff00>+ %s</color>",cur_data.gong_ji)
        elseif cur_data.ming_zhong > 0 then
            value = string.format(Language.Common.PassvieSkillAttr.ming_zhong.." <color=#00ff00>+ %s</color>",cur_data.ming_zhong)
        elseif cur_data.shan_bi > 0 then
            value = string.format(Language.Common.PassvieSkillAttr.shan_bi.." <color=#00ff00>+ %s</color>",cur_data.shan_bi)
        elseif cur_data.bao_ji > 0 then
            value = string.format(Language.Common.PassvieSkillAttr.bao_ji.." <color=#00ff00>+ %s</color>",cur_data.bao_ji)
        elseif cur_data.jian_ren > 0 then
            value = string.format(Language.Common.PassvieSkillAttr.jian_ren.." <color=#00ff00>+ %s</color>",cur_data.jian_ren)
        end
    end

    if is_angle then
        self.is_angle:SetValue(true)
        self.def_cur:SetValue(value)
    else
        self.is_angle:SetValue(false)
        self.def_cur:SetValue(string.format(Language.Common.PassvieSkillAttr.fang_yu.." <color=#00ff00>+ %s</color>",cur_data.fang_yu))
        self.hp_cur:SetValue(cur_data.max_hp)
        self.atk_cur:SetValue(cur_data.gong_ji)
    end

    local next_data = {}
    next_data = SwordArtOnlineData.Instance:GetCellDataByIdAndLevel(self.uplevel_data.cardzu_id,self.uplevel_data.zuhe_idx,self.uplevel_data.want_level)
    if is_angle then
        if next_data.max_hp > 0 then
            value = string.format(Language.Common.PassvieSkillAttr.max_hp.." <color=#00ff00>+ %s</color>",next_data.max_hp)
        elseif next_data.fang_yu > 0 then
            value = string.format(Language.Common.PassvieSkillAttr.fang_yu.." <color=#00ff00>+ %s</color>",next_data.fang_yu)
        elseif next_data.gong_ji > 0 then
            value = string.format(Language.Common.PassvieSkillAttr.gong_ji.." <color=#00ff00>+ %s</color>",next_data.gong_ji)
        elseif next_data.ming_zhong > 0 then
            value = string.format(Language.Common.PassvieSkillAttr.ming_zhong.." <color=#00ff00>+ %s</color>",next_data.ming_zhong)
        elseif next_data.shan_bi > 0 then
            value = string.format(Language.Common.PassvieSkillAttr.shan_bi.." <color=#00ff00>+ %s</color>",next_data.shan_bi)
        elseif next_data.bao_ji > 0 then
            value = string.format(Language.Common.PassvieSkillAttr.bao_ji.." <color=#00ff00>+ %s</color>",next_data.bao_ji)
        elseif next_data.jian_ren > 0 then
            value = string.format(Language.Common.PassvieSkillAttr.jian_ren.." <color=#00ff00>+ %s</color>",next_data.jian_ren)
        end
        self.def_next:SetValue(value)
    else
        self.def_next:SetValue(string.format(Language.Common.PassvieSkillAttr.fang_yu.." <color=#00ff00>+ %s</color>",next_data.fang_yu))
        self.hp_next:SetValue(next_data.max_hp)
        self.atk_next:SetValue(next_data.gong_ji)
    end

    if self.uplevel_data.cur_zh_level > 10 then
        self.upLevelBt.button.interactable = false
        self.upLevelBt.grayscale.GrayScale = 255
        self.next_attr:SetActive(false)
        self.full_level_tips:SetActive(true)
        self.need_liling:SetValue(0)
        self.is_max_level:SetValue(true)
        self.bt_text:SetValue(Language.Common.YiManJi)
    else
        self.bt_text:SetValue(Language.Common.Confirm)
        self.is_max_level:SetValue(false)
        self.upLevelBt.button.interactable = true
        self.upLevelBt.grayscale.GrayScale = 0
        self.next_attr:SetActive(true)
        self.full_level_tips:SetActive(false)
        if self.lingli < self.need_ll then
            self.need_liling:SetValue(string.format("<color=#ff0000>%s</color>",self.need_ll))
        else
            self.need_liling:SetValue(self.need_ll)
        end
    end

    self.have_lingli:SetValue(self.lingli)
    self.want_level:SetValue(self.uplevel_data.want_level)
end
-- 结束

function SwordArtOnlineView:FlushRightInfo()
    self.right_scroller_list_view.scroller:RefreshActiveCellViews()
end

function SwordArtOnlineView:FlushLeftInfo()
    self.left_scroller_list_view.scroller:RefreshActiveCellViews()
end

--左ListView逻辑
function SwordArtOnlineView:InitLeftListView()
    self.left_scroller_list_view = self:FindObj("sword_left_view")
    local list_delegate = self.left_scroller_list_view.list_simple_delegate
    list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetLeftNumberOfCells, self)
    list_delegate.CellRefreshDel = BindTool.Bind(self.LeftRefreshCell, self)
end

function SwordArtOnlineView:GetLeftNumberOfCells()
    return 4
end

function SwordArtOnlineView:LeftRefreshCell(cell, data_index)
    local icon_cell = self.icon_left_cell_list[cell]
    if icon_cell == nil then
        icon_cell = SwordLeftCell.New(cell.gameObject, self)
        self.icon_left_cell_list[cell] = icon_cell
    end
    self.left_data = SwordArtOnlineData.Instance:GetCardZuInfoById(data_index)
    icon_cell:SetIndex(data_index)
    icon_cell:SetData(self.left_data)
end

function SwordArtOnlineView:SetHighForCell(index)
    for k,v in pairs(self.icon_left_cell_list) do
        if index == v:GetIndex() then
            v:SetIsHighLight(true)
        else
            v:SetIsHighLight(false)
        end
    end
end

--右ListView逻辑
function SwordArtOnlineView:BagJumpPage(page)
    local jump_index = page
    local scrollerOffset = 0
    local cellOffset = 0
    local useSpacing = false
    local scrollerTweenType = self.right_scroller_list_view.scroller.snapTweenType
    local scrollerTweenTime = 0.1
    local scroll_complete = nil
    self.right_scroller_list_view.scroller:JumpToDataIndex(
        jump_index, scrollerOffset, cellOffset, useSpacing, scrollerTweenType, scrollerTweenTime, scroll_complete)
end

function SwordArtOnlineView:InitRightListView()
    self.right_scroller_list_view = self:FindObj("sword_right_view")
    local list_delegate = self.right_scroller_list_view.list_simple_delegate
    list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetRightNumberOfCells, self)
    list_delegate.CellRefreshDel = BindTool.Bind(self.RightRefreshCell, self)
end

function SwordArtOnlineView:GetRightNumberOfCells()
    return 7
end

function SwordArtOnlineView:RightRefreshCell(cell, data_index)
    local icon_cell = self.icon_right_cell_list[cell]
    if icon_cell == nil then
        icon_cell = SwordRightCell.New(cell.gameObject, self)
        self.icon_right_cell_list[cell] = icon_cell
    end
    local level = SwordArtOnlineData.Instance:GetZhLevelById(data_index + SwordArtOnlineView.Instance:GetCurSelectIndex()*7)
    if level < 1 then
        level = 1
    end
    self.right_data = SwordArtOnlineData.Instance:GetCellDataByIdAndLevel(self.cur_card_id,data_index,level,true)
    icon_cell:SetData(self.right_data)
    icon_cell:SetIndex(data_index)
    local id_list = {}
    id_list[1] = self.right_data.need_card1_id
    id_list[2] = self.right_data.need_card2_id
    id_list[3] = self.right_data.need_card3_id
    local data = {}
    local zuhe_idx = self.right_data.zuhe_idx
    for i=1,3 do
        data = SwordArtOnlineData.Instance:GetSwordInfoByZhId(id_list[i])
        icon_cell:SetCellData(i,data,zuhe_idx)
        icon_cell:SetCellIndex(i,data_index+7*(self.cur_card_id))
    end
end

--------------------------------------------------------------------------
--SwordLeftCell     左格子
--------------------------------------------------------------------------
SwordLeftCell = SwordLeftCell or BaseClass(BaseCell)
function SwordLeftCell:__init()
    self.name = self:FindVariable("name")
    self.fight = self:FindVariable("fight")
    self.bg = self:FindVariable("bg")
    self.active_tips = self:FindVariable("active_tips")
    self.active_name = self:FindVariable("active_name")

    self.is_show_redpt = self:FindVariable("is_show_redpt")
    self.ActiveHigh = self:FindVariable("ActiveHigh")

    self.mask_bg = self:FindObj("Bg")
    self.lock = self:FindObj("Lock")
    self:ListenEvent("CellClick", BindTool.Bind(self.OnCellClick, self))
end

function SwordLeftCell:__delete()

end

function SwordLeftCell:FlushRedPt()
    self.is_show_redpt:SetValue(false)
    for i=1,7 do
        local level = SwordArtOnlineData.Instance:GetZhLevelById(i - 1)
        if level < 1 then
            level = 1
        end
        right_data = SwordArtOnlineData.Instance:GetCellDataByIdAndLevel(self.index,i - 1,level,true)
        cur_zh_level = SwordArtOnlineData.Instance:GetZhLevelById(right_data.zuhe_idx)
        local have_num_list = {}
        have_num_list[1] = SwordArtOnlineData.Instance:GetSwordNumById(right_data.need_card1_id)
        have_num_list[2] = SwordArtOnlineData.Instance:GetSwordNumById(right_data.need_card2_id)
        have_num_list[3] = SwordArtOnlineData.Instance:GetSwordNumById(right_data.need_card3_id)

        if cur_zh_level <= 0 then
            if have_num_list[1] >= right_data.need_card1_num and have_num_list[2] >= right_data.need_card2_num and have_num_list[3] >= right_data.need_card3_num then
               self.is_show_redpt:SetValue(true)
               return
            end
        end
    end
end

function SwordLeftCell:OnFlush()
    if not next(self.data) then return end

    -- 刷新选中特效
    local select_index = SwordArtOnlineView.Instance:GetCurSelectIndex()
    if select_index ~= self.index then
        self.ActiveHigh:SetValue(false)
    elseif select_index == self.index then
        self.ActiveHigh:SetValue(true)
    end

    self.name:SetValue(self.data.cardzu_name)
    local fight = SwordArtOnlineData.Instance:GetFightById(self.data.cardzu_id)
    self.fight:SetValue(fight)
    self:SetImage()

    if SwordArtOnlineData.Instance:CardZuActiveById(self.index) then
        self.mask_bg.grayscale.GrayScale = 0
        self.lock:SetActive(false)
    else
        local active_data = {}
        active_data = SwordArtOnlineData.Instance:GetCardZuInfoById(self.index - 1)
        self.mask_bg.grayscale.GrayScale = 255
        self.lock:SetActive(true)
        self.active_name:SetValue(active_data.cardzu_name)
        local active_num = SwordArtOnlineData.Instance:CardZuActiveById(self.index,true)
        if active_num > self.data.need_active_count then
            self.active_tips:SetValue(string.format("<color=#00ff00>%s/%s</color>",active_num,self.data.need_active_count))
        else
            self.active_tips:SetValue(string.format("<color=#ff0000>%s</color><color=#00ff00>/%s</color>",active_num,self.data.need_active_count))
        end
    end

    self:FlushRedPt()
end

function SwordLeftCell:SetImage()
    local str = "sword_back0"..self.data.cardzu_id
    self.bg:SetAsset("uis/views/swordartonline",str)
end

function SwordLeftCell:OnCellClick()
    if SwordArtOnlineData.Instance:CardZuActiveById(self.index) then
        SwordArtOnlineView.Instance:SetCurCardId(self.index)
        SwordArtOnlineView.Instance:FlushRightInfo()
        SwordArtOnlineView.Instance:SetHighForCell(self.index)
    else
        TipsCtrl.Instance:ShowSystemMsg(Language.EquipShen.FormerNoEnoughCondition)
    end
end

function SwordLeftCell:SetInteractable(enable)
    self.root_node.toggle.interactable = enable
end

function SwordLeftCell:SetIsHighLight(enable)
    self.ActiveHigh:SetValue(enable)
end

--------------------------------------------------------------------------
--SwordRightCell    右格子
--------------------------------------------------------------------------
SwordRightCell = SwordRightCell or BaseClass(BaseCell)

function SwordRightCell:__init(instance)
    self.name = self:FindVariable("name")
    self.def = self:FindVariable("def")
    self.hp = self:FindVariable("hp")
    self.atk = self:FindVariable("atk")
    self.num01 = self:FindVariable("num01")
    self.num02 = self:FindVariable("num02")
    self.num03 = self:FindVariable("num03")
    self.by_txt = self:FindVariable("by_txt")
    self.is_grey = self:FindVariable("is_grey")
    self.is_angle = self:FindVariable("is_angle")
    self.is_show_redpt = self:FindVariable("is_show_redpt")
    self.is_active = self:FindVariable("is_active")

    self.Button = self:FindObj("Button")

    self:ListenEvent("bt_click", BindTool.Bind(self.OnBtClick, self))

    self.item_cell = {}
    for i = 1, 3 do
        local cell = SwordCell.New(self:FindObj("Cell0" .. i))
        table.insert(self.item_cell, cell)
    end
end

function SwordRightCell:__delete()
    for k, v in pairs(self.item_cell) do
        v:DeleteMe()
    end
    self.item_cell = {}
end

function SwordRightCell:OnBtClick()
    if self.data.cur_zh_level > 0 then
        SwordArtOnlineView.Instance:OpenUpLevel(self.data)
    else
        MoLongCtrl.Instance:SendSwordArtOnlineOperaReq(CARDZU_REQ_TYPE.CARDZU_REQ_TYPE_ACTIVE_ZUHE,self.data.zuhe_idx)
    end
end

function SwordRightCell:SetCellData(i,data,zuhe_idx)
    self.item_cell[i]:SetData(data)
    self.item_cell[i]:SetZuHeId(zuhe_idx)
end

function SwordRightCell:SetCellIndex(i,index)
    self.item_cell[i]:SetIndex(index)
end

function SwordRightCell:OnFlush()
    if not next(self.data) then return end
    local have_num_list = {}
    have_num_list[1] = SwordArtOnlineData.Instance:GetSwordNumById(self.data.need_card1_id)
    have_num_list[2] = SwordArtOnlineData.Instance:GetSwordNumById(self.data.need_card2_id)
    have_num_list[3] = SwordArtOnlineData.Instance:GetSwordNumById(self.data.need_card3_id)

    local is_angle = false
    local value = 0
    if self.data.fang_yu > 0 and self.data.max_hp > 0 and self.data.gong_ji > 0 then
        is_angle = false
    else
        is_angle = true
        if self.data.max_hp > 0 then
            value = Language.Common.PassvieSkillAttr.max_hp.." +"..self.data.max_hp
        elseif self.data.fang_yu > 0 then
            value = Language.Common.PassvieSkillAttr.fang_yu.." +"..self.data.fang_yu
        elseif self.data.gong_ji > 0 then
            value = Language.Common.PassvieSkillAttr.gong_ji.." +"..self.data.gong_ji
        elseif self.data.ming_zhong > 0 then
            value = Language.Common.PassvieSkillAttr.ming_zhong.." +"..self.data.ming_zhong
        elseif self.data.shan_bi > 0 then
            value = Language.Common.PassvieSkillAttr.shan_bi.." +"..self.data.shan_bi
        elseif self.data.bao_ji > 0 then
            value = Language.Common.PassvieSkillAttr.bao_ji.." +"..self.data.bao_ji
        elseif self.data.jian_ren > 0 then
            value = Language.Common.PassvieSkillAttr.jian_ren.." +"..self.data.jian_ren
        end
    end

    if is_angle then
        self.is_angle:SetValue(true)
        self.def:SetValue(value)
    else
        self.is_angle:SetValue(false)
        self.def:SetValue(Language.Common.PassvieSkillAttr.fang_yu.." +"..self.data.fang_yu)
        self.hp:SetValue(self.data.max_hp)
        self.atk:SetValue(self.data.gong_ji)
    end

    if have_num_list[1] >= self.data.need_card1_num then
        self.num01:SetValue(string.format("%s/%s",have_num_list[1],self.data.need_card1_num))
    else
        self.num01:SetValue(string.format("<color=#ff0000>%s</color>/%s",have_num_list[1],self.data.need_card1_num))
    end

    if have_num_list[2] >= self.data.need_card2_num then
        self.num02:SetValue(string.format("%s/%s",have_num_list[2],self.data.need_card2_num))
    else
        self.num02:SetValue(string.format("<color=#ff0000>%s</color>/%s",have_num_list[2],self.data.need_card2_num))
    end

    if have_num_list[3] >= self.data.need_card3_num then
        self.num03:SetValue(string.format("%s/%s",have_num_list[3],self.data.need_card3_num))
    else
        self.num03:SetValue(string.format("<color=#ff0000>%s</color>/%s",have_num_list[3],self.data.need_card3_num))
    end

    self.data.cur_zh_level = SwordArtOnlineData.Instance:GetZhLevelById(self.data.zuhe_idx)
    self.name:SetValue(string.format("%s LV.%s",self.data.zuhe_name,self.data.cur_zh_level))
    if self.data.cur_zh_level > 0 then
        self.by_txt:SetValue(Language.Common.Up)
        self.is_active:SetValue(true)
        self.is_show_redpt:SetValue(false)
        if self.data.cur_zh_level > 10 then
            self.Button.button.interactable = false
            self.by_txt:SetValue(Language.Common.MaxLv)
            self.is_grey:SetValue(true)
        else
            self.Button.button.interactable = true
            self.is_grey:SetValue(false)
        end
    else
        if have_num_list[1] >= self.data.need_card1_num and have_num_list[2] >= self.data.need_card2_num and have_num_list[3] >= self.data.need_card3_num then
            self.is_show_redpt:SetValue(true)
        else
            self.is_show_redpt:SetValue(false)
        end
        self.Button.button.interactable = true
        self.is_grey:SetValue(false)
        self.is_active:SetValue(false)
        self.by_txt:SetValue(Language.Common.Activate)
    end
end

---------------------------------------------------------------------------- 格子剑类
SwordCell = SwordCell or BaseClass(BaseCell)

function SwordCell:__init()
    self.sword = self:FindVariable("sword")
    self.star_bg = self:FindVariable("star_bg")
    -- self.star = {}
    -- for i=1,6 do
    --     self.star[i] = self:FindObj("star0"..i)
    -- end

    self:ListenEvent("Click",BindTool.Bind(self.OnClick, self))
end

function SwordCell:OnClick()
    self.data.cur_zh_level = SwordArtOnlineData.Instance:GetZhLevelById(self.zuhe_idx)
    if self.data.cur_zh_level > 0 then
        return
    end
    self.data.index = self.index
    SwordArtOnlineView.Instance:OpenLingZhu(self.data)
end

function SwordCell:SetZuHeId(zuhe_idx)
    self.zuhe_idx = zuhe_idx
end

function SwordCell:OnFlush()
    if not next(self.data) then return end

    -- for i=1,6 do
    --     self.star[i]:SetActive(false)
    -- end

    -- for i=1,self.data.star_count do
    --     self.star[i]:SetActive(true)
    -- end
    self:SetImage()
end

function SwordCell:SetImage()
    local star_str = "star_bg_"..self.data.star_count
    self.star_bg:SetAsset("uis/views/swordartonline",star_str)

    local sword_str = "sword_"..self.data.res_id
    self.sword:SetAsset("uis/views/swordartonline",sword_str)
end

function SwordCell:__delete()
    if self.item_cell then
        self.item_cell:DeleteMe()
        self.item_cell = nil
    end
end