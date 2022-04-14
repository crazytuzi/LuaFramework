-- @Author: lwj
-- @Date:   2019-09-04 16:52:57 
-- @Last Modified time: 2019-09-04 16:53:03

NationModel = NationModel or class("NationModel", BaseBagModel)
local NationModel = NationModel

function NationModel:ctor()
    NationModel.Instance = self
    self:Reset()
end

function NationModel:Reset()
    self.act_id_list = { 780, 730, 407, 405, 404, 406, 403, 402, 401 }
    self.illact_id_list = { 742, 745 }
    self.default_sel_menu = nil     --默认选中活动id类型
    self.theme_cf_list = {}                         --活动配置
    self.show_theme_first_id = nil                  --正在开启的活动列表中的第一个活动id
    self.info_list = {}                             --活动信息
    self.rewa_cf_list = {}                          --reward配置
    self.is_open_panel = false                      --在接收活动数据时，是否打开界面
    self.act_end_list = {}                          --活动结束时间
    self.side_rd_list = {}                          --标签栏红点列表
    self.cur_high_pro = 0                           --当前嗨点进度值
    self.sorted_achi_cf_list = {}                   --整理过后的连充成就奖励配置
    self.egg_crack_info = {}                        --砸蛋活动信息
    self.cost_tbl = {}                              --砸蛋消耗
    self.is_check = false                           --消耗钻石砸蛋勾选状态
    self.egg_reco_info = {}                           --砸蛋记录
    self.is_show_achi_rd = false                    --是否显示连充累计活动的红点
    self.is_hanabi_check = false                    --当前登录不再提示
    self.cur_hanabi_cost_tbl = {}                   --当前烟花的消耗物品

    self.shop_cf = {}                               --抽奖商城配置
    self.lot_shop_type = 1                          --跨服云购当前类型  1:钻石  2：绑钻
    self.max_shop_reco = 32                         --记录最大显示数量
    self.defa_top_idx = 1                           --默认选中的云购类型
    self.cur_buy_times = 1                          --当前选中的购买次数
    self.shop_info = {}                             --跨服云购Info
    self.cur_cost = 0                               --当前购买总消耗

    self.illinfo_list = {}
    self.illtheme_cf_list = {}
    self.illrewa_cf_list = {}
    self.is_red = false
end

function NationModel.GetInstance()
    if NationModel.Instance == nil then
        NationModel()
    end
    return NationModel.Instance
end

---配置
function NationModel:SetThemeCf(cf)
    if (not cf) or (not cf.id) then
        return
    end
    self.theme_cf_list[cf.id] = cf
end
function NationModel:SetIllThemeCf(cf)
    if (not cf) or (not cf.id) then
        return
    end
    self.illtheme_cf_list[cf.id] = cf
end

function NationModel:GetThemeCf()
    return self.theme_cf_list
end

function NationModel:GetThemeCfById(id)
    return self.theme_cf_list[id]
end

function NationModel:GetIllThemeCfById(id)
    return self.illtheme_cf_list[id]
end

function NationModel:GetRewaCf()
    for act_id, info_list in pairs(self.info_list) do
        local list = {}
        for idx, task_info in pairs(info_list.tasks) do
            list[task_info.id] = OperateModel.GetInstance():GetRewardConfig(act_id, task_info.id)
        end
        self.rewa_cf_list[act_id] = list
    end
end
function NationModel:GetIllRewaCf()
    for act_id, info_list in pairs(self.illinfo_list) do
        local list = {}
        for idx, task_info in pairs(info_list.tasks) do
            list[task_info.id] = OperateModel.GetInstance():GetRewardConfig(act_id, task_info.id)
        end
        self.illrewa_cf_list[act_id] = list
    end
end

function NationModel:IsSelfAct(tar_id)
    local result = false
    for _, v in pairs(self.act_id_list) do
        if OperateModel:GetInstance():GetActIdByType(v) == tar_id then
            result = true
            break
        end
    end
    return result
end

---Info
function NationModel:SetActInfo(info)
    self.info_list[info.id] = info
    if table.isempty(self.theme_cf_list) then
        self:GetAllCf()
    end
    if info.id == OperateModel.GetInstance():GetActIdByType(403) then
        self:CheckCurProChange(info)
        self:CheckMainRD(info.id)
    end
end

function NationModel:SetActIllInfo(info)
    self.illinfo_list[info.id] = info
    self:GetIllAllCf()
end
function NationModel:CheckCurProChange(info)
    local list = info.tasks
    local max = 0
    for i, v in pairs(list) do
        if v.level == 2 then
            local pro = v.count
            if pro > max then
                max = pro
            end
        end
    end
    if max ~= self.cur_high_pro then
        self.cur_high_pro = max
        self:Brocast(NationEvent.UpdateHighCurPro, max)
    end
end

function NationModel:CheckMainRD(act_id)
    local is_show_rd = false
    local list = self.info_list[act_id].tasks
    for i, v in pairs(list) do
        if v.level == 2 and v.state == enum.YY_TASK_STATE.YY_TASK_STATE_FINISH then
            is_show_rd = true
            break
        end
    end
    self.side_rd_list[act_id] = is_show_rd
    if not is_show_rd and self:IsCanHide() == false then
        return is_show_rd
    end
    OperateModel.GetInstance():UpdateIconReddot(act_id, is_show_rd)
    return is_show_rd
end

function NationModel:SetEndTimeByActId(id, time_stamp)
    self.act_end_list[id] = time_stamp
end

function NationModel:GetEndTimeByActId(act_id)
    return self.act_end_list[act_id]
end

function NationModel:GetNationThemeList()
    local list = self:GetThemeCf()
    local interator = table.pairsByKey(list)
    local cf = {}
    for k, v in interator do
        local end_time = self.act_end_list[v.id]
        if end_time then
            if end_time > os.time() then
                --活动未结束
                cf[v.sort] = v
            end
        end
    end
    local tbl = {}
    local inter = table.pairsByKey(cf)
    for i, v in inter do
        tbl[#tbl + 1] = v
    end
    return tbl
end

function NationModel:FormatNum(num)
    return string.format("%02d", num)
end

function NationModel:GetRewaCfByActId(id)
    return self.rewa_cf_list[id]
end
function NationModel:GetIllRewaCfByActId(id)
    return self.illrewa_cf_list[id]
end

function NationModel:GetActInfoByActId(id)
    return self.info_list[id]
end

function NationModel:GetSingleTaskInfo(act_id, task_id)
    local act_info = self:GetActInfoByActId(act_id) or self:GetActIllInfoByActId(act_id)
    local result = {}
    for i, v in pairs(act_info.tasks) do
        if v.id == task_id then
            result = v
            break
        end
    end

    return result
end

function NationModel:GetActIllInfoByActId(id)
    return self.illinfo_list[id]
end

function NationModel:IsCanHide()
    local is_can_hide = true
    for i, v in pairs(self.side_rd_list) do
        local is_out_date = self:IsActOutDate(i)
        if v and (not is_out_date) then
            is_can_hide = false
            break
        end
    end
    return is_can_hide
end

---道具兑换
function NationModel:GetExchangeItemList()
    local list = self:GetRewaCfByActId(OperateModel.GetInstance():GetActIdByType(401))
    local lv = RoleInfoModel.GetInstance():GetMainRoleLevel()
    local final_list = {}
    for i = 1, #list do
        local cf = list[i]
        local show_lv = 0
        local sundries = String2Table(cf.sundries)
        local is_straight_add = false
        for _, tbl in pairs(sundries) do
            if type(tbl) == "number" then
                is_straight_add = true
                break
            elseif type(tbl) == "table" then
                if tbl[1] == "show_level" then
                    show_lv = tbl[2]
                    break
                end
            end
        end
        if is_straight_add or show_lv <= lv then
            final_list[#final_list + 1] = cf
        end
    end
    return final_list
end

function NationModel:CheckExchangeRD()
    local info = self.info_list[OperateModel.GetInstance():GetActIdByType(401)]
    if (not info) or (table.isempty(info.tasks)) then
        return
    end
    local list = info.tasks
    local is_show = false
    for i, v in pairs(list) do
        local rewa_cf = OperateModel.GetInstance():GetRewardConfig(OperateModel.GetInstance():GetActIdByType(401), list[i].id)
        local limit = String2Table(rewa_cf.limit)[2]
        if limit > list[i].count then
            local cost_tbl = String2Table(rewa_cf.cost)[1]
            local cost_id = cost_tbl[1]
            local have_num = BagModel.GetInstance():GetItemNumByItemID(cost_id)
            local need_num = cost_tbl[2]
            if have_num >= need_num then
                is_show = true
                break
            end
        end
    end
    return is_show
end

-----通常式检查红点
function NationModel:CheckRDNormal(act_id)
    if act_id == 0 then
        return
    end
    local info = self:GetActInfoByActId(act_id).tasks
    local is_show = false
    local is_high_act = act_id == OperateModel.GetInstance():GetActIdByType(403)
    for i = 1, #info do
        local data = info[i]
        local is_can_continue = true
        if is_high_act and data.level ~= 2 then
            is_can_continue = false
        end
        if is_can_continue and data.state == enum.YY_TASK_STATE.YY_TASK_STATE_FINISH then
            is_show = true
            break
        end
    end
    return is_show
end

-----连充
function NationModel:GetAchiRewaCf()
    if table.isempty(self.sorted_achi_cf_list) then
        self:SortAchiRewaCf()
    end
    return self.sorted_achi_cf_list
end

function NationModel:GetAcIllRewaCf()
    if table.isempty(self.illsorted_achi_cf_list) then
        self:SortIllAchiRewaCf()
    end
    return self.illsorted_achi_cf_list
end

function NationModel:SortAchiRewaCf()
    local cf = self:GetRewaCfByActId(OperateModel.GetInstance():GetActIdByType(404))
    local grade_list = {}
    for _, cf_list in pairs(cf) do
        local task_tbl = String2Table(cf_list.task)
        local day = task_tbl[2]
        local grade = task_tbl[3]
        if not grade_list[grade] then
            grade_list[grade] = {}
        end
        cf_list.grade = grade
        cf_list.day = day
        grade_list[grade][#grade_list[grade] + 1] = cf_list
    end
    local list = {}
    local interator = table.pairsByKey(grade_list)
    for grade, cf in interator do
        list[#list + 1] = cf
    end
    self.sorted_achi_cf_list = list
end

function NationModel:SortIllAchiRewaCf()
    local cf = self:GetIllRewaCfByActId(174200)
    local grade_list = {}
    for _, cf_list in pairs(cf) do
        local task_tbl = String2Table(cf_list.task)
        local day = task_tbl[2]
        local grade = task_tbl[3]
        if not grade_list[grade] then
            grade_list[grade] = {}
        end
        cf_list.grade = grade
        cf_list.day = day
        grade_list[grade][#grade_list[grade] + 1] = cf_list
    end
    local list = {}
    local interator = table.pairsByKey(grade_list)
    for grade, cf in interator do
        list[#list + 1] = cf
    end
    self.illsorted_achi_cf_list = list
end

--砸蛋
function NationModel:CheckCrackEggRD()
    --免费砸蛋
    local egg_info = self:GetEggCrackInfo()
    local is_show = false
    if not table.isempty(egg_info) then
        local remain_crack = egg_info.free_crack
        if remain_crack > 0 then
            is_show = true
        end
    end
    if not is_show then
        local config = self:GetActInfoByActId(OperateModel.GetInstance():GetActIdByType(406))
        if not config then
            return
        end
        local info = config.tasks
        for i = 1, #info do
            local data = info[i]
            if data.state == enum.YY_TASK_STATE.YY_TASK_STATE_FINISH then
                is_show = true
                break
            end
        end
    end
    if not is_show then
        local cost_tbl = {}
        local cf = self:GetThemeCfById(OperateModel.GetInstance():GetActIdByType(406))
        if not cf then
            self:GetAllCf()
            cf = self:GetThemeCfById(OperateModel.GetInstance():GetActIdByType(406))
        end
        local req_tbl = String2Table(cf.reqs)
        for _, tbl in pairs(req_tbl) do
            if tbl[1] == "cost" then
                cost_tbl = tbl[2][1]
                break
            end
        end
        local remain = BagModel.GetInstance():GetItemNumByItemID(cost_tbl[1])
        --身上是否有足够锤子锤一次
        if remain >= cost_tbl[2] then
            is_show = true
        end
    end
    return is_show
end

function NationModel:SetEggCrackInfo(data)
    self.egg_crack_info = data
end

function NationModel:GetEggCrackInfo()
    return self.egg_crack_info
end

function NationModel:SetSingleEggInfo(data)
    local item_list = data.items
    for pos, single_info in pairs(item_list) do
        self.egg_crack_info.items[pos] = single_info
    end
    self.egg_crack_info.free_crack = data.free_crack
    self.egg_crack_info.free_refresh = data.free_refresh
    self.egg_crack_info.crack = data.crack
end

function NationModel:SetRefreshEggInfo(data)
    local item_list = data.items
    for pos, single_info in pairs(item_list) do
        self.egg_crack_info.items[pos] = single_info
    end
    self.egg_crack_info.free_refresh = data.free_refresh
    self.egg_crack_info.crack = data.crack
end

function NationModel:GetHaventCrackedPos()
    local info = self.egg_crack_info.items
    local pos = nil
    for i = 1, #info do
        if info[i].reward_id == 0 then
            pos = i
            break
        end
    end
    return pos
end

function NationModel:GetCanCrackNum()
    local info = self.egg_crack_info.items
    local count = 0
    for i = 1, #info do
        if info[i].reward_id == 0 then
            count = count + 1
        end
    end
    return count
end

function NationModel:SetSingleReco(data)
    self.egg_reco_info[#self.egg_reco_info + 1] = data
end

function NationModel:GetAllCf()
    local list = self.act_id_list
    for _, type in pairs(list) do
        local id = OperateModel.GetInstance():GetActIdByType(type)
        local theme_cf = OperateModel.GetInstance():GetConfig(id)
        self:SetThemeCf(theme_cf)
    end
    self:GetRewaCf()
end
function NationModel:GetIllAllCf()
    local list = self.illact_id_list
    for _, type in pairs(list) do
        local id = OperateModel.GetInstance():GetActIdByType(type)
        local theme_cf = OperateModel.GetInstance():GetConfig(id)
        self:SetIllThemeCf(theme_cf)
    end
    self:GetIllRewaCf()
end

function NationModel:IsActOutDate(act_id)
    --local list = self:GetNationThemeList()
    --local is_out_date = true
    --for i, v in pairs(list) do
    --    if v.id == act_id then
    --        is_out_date = false
    --        break
    --    end
    --end
    return not OperateModel.GetInstance():IsActOpenByTime(act_id)
end

function NationModel:IsHaveFreeCrack()
    return self.egg_crack_info.free_crack > 0
end

function NationModel:CheckHanabiRD()
    local id = OperateModel.GetInstance():GetActIdByType(730)
    if id == 0 then
        return false
    end
    if not OperateModel.GetInstance():IsActOpen(id) then
        return
    end
    local cf = self:GetThemeCfById(id)
    if not cf then
        return false
    end
    local req = String2Table(cf.reqs)
    local tbl = {}
    for _, tb in pairs(req) do
        if tb[1] == "cost" then
            tbl = tb[2][1]
            break
        end
    end
    local cost_id = tbl[1]
    local cost_num = tbl[2]
    if (not cost_num) or (not cost_id) then
        logError("ChristmasHanabiView: 没有消耗id")
        return false
    end
    local have_num = BagModel.GetInstance():GetItemNumByItemID(cost_id)
    if have_num > 0 and have_num >= cost_num then
        return true
    else
        return false
    end
end

-------云购
--分类：1:钻石 2：绑钻
function NationModel:SortShopList()
    self.shop_cf = {}
    local cf = Config.db_yunying_lottery_shop
    for i = 1, #cf do
        local sin_cf = cf[i]
        local type = sin_cf.category
        self.shop_cf[type] = self.shop_cf[type] or {}
        self.shop_cf[type][sin_cf.yunying_id] = self.shop_cf[type][sin_cf.yunying_id] or {}
        self.shop_cf[type][sin_cf.yunying_id][sin_cf.id] = sin_cf
    end
end

function NationModel:GetShopList(type, act_id)
    local type_list = self.shop_cf[type]
    if not type_list then
        return {}
    end
    return type_list[act_id]
end

function NationModel:DealShopRecoList(list)
    local len = #list
    if len > self.max_shop_reco then
        len = self.max_shop_reco
    end
    local f_list = {}
    for i = 1, len do
        f_list[#f_list + 1] = list[i]
    end
    return f_list
end

function NationModel:GetShopItemCf(act_id, shop_id)
    local result
    local cf_one = self.shop_cf[1][act_id]
    if cf_one then
        result = cf_one[shop_id]
    end
    if not result then
        local cf_two = self.shop_cf[2][act_id]
        if cf_two then
            result = cf_two[shop_id]
        end
    end
    return result
end

function NationModel:DealShopItemList(act_id, list)
    local result = {}
    for i = 1, #list do
        local info = list[i]
        local cf = self:GetShopItemCf(act_id, info.id)
        if cf and cf.category == self.lot_shop_type then
            result[#result + 1] = info
        end
    end
    return result
end

function NationModel:UpdateBuyReco(log)
    self.shop_info = self.shop_info or {}
    for i = 1, #log do
        local sin_log = log[i]
        self.shop_info.logs[#self.shop_info.logs + 1] = sin_log
    end
    return self.shop_info.logs
end

--云购是否处于无限制次数购买状态
function NationModel:IsShopInNoSideSale()
    local stime = self.shop_info.reward_time - self.shop_info.unlimit_sec
    local is_in = false
    local cur_time = os.time()
    if cur_time >= stime and cur_time < self.shop_info.reward_time then
        is_in = true
    end
    return is_in
end

function NationModel:UpdatePShop(sin_info)
    local info = self.shop_info.list
    local is_find = false
    for i = 1, #info do
        local data = info[i]
        if data.id == sin_info.id then
            is_find = true
            self.shop_info.list[i] = sin_info
            break
        end
    end
    if not is_find then
        self.shop_info.list[#self.shop_info.list + 1] = sin_info
    end
end