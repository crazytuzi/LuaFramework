-- @Author: lwj
-- @Date:   2018-11-29 19:17:32
-- @Last Modified time: 2019-06-25 15:17:41

VipModel = VipModel or class("VipModel", BaseBagModel)
local VipModel = VipModel

function VipModel:ctor()
    VipModel.Instance = self
    self:Reset()
end

function VipModel:Reset()
    self.roleData = nil
    self.vipInfo = nil
    self.curLv = nil
    self.haveNotGetLv = 0
    self.curGiftType = 0
    self.vipExpPool = 0
    self.isGetExpPool = true
    self.isFirstOpen = true
    self.rebate_info = {}                   --V4激活返利
    self.taste_stime = 0                    --Vip体验时间
    self.taste_etime = 0
    self.is_show_gift_rd = false

    self.mc_info = {}
    self.is_buying = false
    self.is_first_rd = true
    self.is_show_mc_once = false
    self.side_rd_list = {}
    self.mc_item_rd_list = {}
    self.is_buy_when_begin = false
    self.is_fetching_mc_rewa = false

    self.inves_info = {}
    self.is_had_invesrd_showed = false      --是否已经显示过一次性红点
    self.default_tog = 1
    self.cur_sel_grade = 1
    self.vip_rights_cf = {}
    self.is_show_rd_after_close = false     --在关闭VIp界面的时候是否显示下一等级的投资

    self:SortVipRights()
    self:SortInvestRewaCF()
    self:InitVipGiftCF()
    self.inve_btn_state = 1                 --1：已投资过的档位 2:投资档位

    self.have_pay_list = {}                 --已经充过的档位

    self.is_showed_first_rd = false            --Vip礼包一次性红点
    self.is_check = false                       --Vip过期，登录不再提醒
end

function VipModel:SortVipRights()
    for i, v in pairs(Config.db_vip_rights) do
        self.vip_rights_cf[#self.vip_rights_cf + 1] = v
    end
    local function sort(a, b)
        return a.order < b.order
    end
    table.sort(self.vip_rights_cf, sort)
end

function VipModel:GetVipRightsCf()
    return self.vip_rights_cf
end

function VipModel.GetInstance()
    if VipModel.Instance == nil then
        VipModel()
    end
    return VipModel.Instance
end

function VipModel:GetValueByType(type, value)
    local result = ""
    if value ~= 0 then
        if type == 0 then
            result = value
        elseif type == 1 then
            result = tostring(tonumber(value) / 100) .. "%%"
        end
        return result
    end
end

function VipModel:GetVipExpPool()
    return self.vipExpPool
end

function VipModel:SetVipExpPool(value)
    self.vipExpPool = value
end

function VipModel:CheckIsFetchedByLv(lv)
    local is_fetched = false
    for i, v in pairs(self.vipInfo.lv_reward) do
        if v == lv then
            is_fetched = true
            break
        end
    end
    return is_fetched
end

function VipModel:IsFetchWeek()
    return self.vipInfo.weekly_gift
end

function VipModel:SetMCInfo(info)
    self.mc_info = info
end

function VipModel:IsBuyMC()
    return self.mc_info.buy
end

function VipModel:GetMCStateByDay(day)
    return self.mc_info.fetch[day]
end

function VipModel:SortMCData()
    local list = {}
    local no_achi = {}
    local rewarded = {}
    local cf = Config.db_vip_mcard
    for i = 1, #cf do
        local data = self:GetMCStateByDay(cf[i].day)
        if data == false then
            list[#list + 1] = cf[i]
        elseif data == nil then
            no_achi[#no_achi + 1] = cf[i]
        elseif data == true then
            rewarded[#rewarded + 1] = cf[i]
        end
    end
    for i = 1, #no_achi do
        list[#list + 1] = no_achi[i]
    end
    for i = 1, #rewarded + 1 do
        list[#list + 1] = rewarded[i]
    end
    return list
end

function VipModel:AddSideRD(index)
    self.side_rd_list[index] = true
end

function VipModel:RemoveSideRD(index)
    self.side_rd_list[index] = nil
end

function VipModel:GetSideRD(index)
    local result = self.side_rd_list[index]
    if not result then
        result = false
    end
    return result
end

function VipModel:GetMCCanFetchList()
    local info = self.mc_info.fetch
    for i = 1, 31 do
        local day = i - 1
        if info[day] == false then
            self.mc_item_rd_list[day] = true
        else
            self.mc_item_rd_list[day] = nil
        end
    end
end

function VipModel:IsCanFetchMC()
    return table.nums(self.mc_item_rd_list) > 0
end

function VipModel:GetMCItemRDByDay(day)
    local result = self.mc_item_rd_list[day]
    if not result then
        result = false
    end
    return result
end


-------------------------------------------------------投资

function VipModel:SetInvesInfo(info)
    self.inves_info = info
end

function VipModel:GetInvesInfo()
    return self.inves_info
end

function VipModel:IsTopInvesting()
    if not self.inves_info then
        logError("VipModel,没有inves_info")
        return
    end
    return self.inves_info.type == 2
end

function VipModel:IsInvested()
    return self.inves_info.grade ~= 0
end

function VipModel:GetInvestGrade()
    return self.inves_info.grade
end

--巅峰投资档位 需要+3
function VipModel:GetRealGrade()
    local cur_grade = self:GetInvestGrade()
    return self:IsTopInvesting() and 3 + cur_grade or cur_grade
end

function VipModel:GetInvestType()
    return self.inves_info.type
end

function VipModel:IsCanHideMainIconRD()
    return table.nums(self.side_rd_list) == 0
end

function VipModel:SortInvestRewaCF()
    self.inverst_rewa_cf = {}
    local cf = Config.db_vip_invest_reward
    for i = 1, #cf do
        local data = cf[i]
        if not self.inverst_rewa_cf[data.type] then
            self.inverst_rewa_cf[data.type] = {}
        end
        if not self.inverst_rewa_cf[data.type][data.grade] then
            self.inverst_rewa_cf[data.type][data.grade] = {}
        end
        self.inverst_rewa_cf[data.type][data.grade][#self.inverst_rewa_cf[data.type][data.grade] + 1] = data
    end
end

function VipModel:GetInverstCFByGrade(grade)
    local type = self.inves_info.type
    local list = {}
    if not self.inverst_rewa_cf[type] then
        return list
    end
    local cf = self.inverst_rewa_cf[type][grade]
   
    local fall_list = {}
    for i = 1, #cf do
        local data = cf[i]
        if self:IsSameLineRewarded(data.line) then
            --沉底
            fall_list[#fall_list + 1] = data
        else
            list[#list + 1] = data
        end
    end
    for i = 1, #fall_list do
        list[#list + 1] = fall_list[i]
    end
    return list
end

function VipModel:GetTogList()
    local cf = Config.db_vip_invest
    local cur_grade = self.inves_info.grade
    local list = {}
    for i = 1, #cf do
        if cur_grade <= cf[i].grade and self.inves_info.type == cf[i].type then
            list[#list + 1] = cf[i]
        end
    end
    return list
end

function VipModel:GetInvestRewaInfoById(id)
    local list = self.inves_info.list
    local result
    for i = 1, #list do
        if list[i].id == id then
            result = list[i]
            break
        end
    end
    return result
end

function VipModel:UpdateInveRewaInfo(info)
    local list = self.inves_info.list
    local result_idx
    for i = 1, #list do
        if list[i].id == info.id then
            result_idx = i
            break
        end
    end
    if result_idx then
        self.inves_info.list[result_idx] = info
    else
        self.inves_info.list[#self.inves_info.list + 1] = info
        local function sort(a, b)
            return a.id < b.id
        end
        table.sort(self.inves_info.list, sort)
    end
end

function VipModel:IsSameLineRewarded(line)
    local list = self.inves_info.list
    local result
    for i = 1, #list do
        local cur_line = Config.db_vip_invest_reward[list[i].id].line
        if cur_line == line then
            if list[i].state == 2 then
                result = list[i]
            end
            break
        end
    end
    return result
end

--获得当前投资的最大档位
function VipModel:GetCurInvestMaxGrade()
    local config = Config.db_vip_invest
    local type = 2
    type = self.inves_info and self.inves_info.type or 1
    local idx = 0
    for i = 1, #config do
        local cf = config[i]
        if cf.type == type then
            idx = idx + 1
        end
    end
    return idx
end

--计算预计获得的回扣
function VipModel:CountPreiGetNum(grade)
    local is_top = self:IsTopInvesting()
    local type = is_top and 2 or 1
    local sum = 0
    local config = Config.db_vip_invest_reward
    for _, cf in pairs(config) do
        if cf.type == type and cf.grade == grade then
            local tbl = String2Table(cf.reward)[1]
            sum = sum + tbl[2]
        end
    end
    return sum
end

------------------------------------------------Vip礼包
function VipModel:InitVipGiftCF()
    local list = Config.db_mall
    self.vip_gift_cf = {}
    for _, data in pairs(list) do
        if data.limit_type == 5 then
            self.vip_gift_cf[data.order] = data
        end
    end
end

function VipModel:GetVipGiftCF()
    return self.vip_gift_cf
end

--Vip礼包首次红点
function VipModel:CheckIsShowGiftFirstRD()
    if self.is_showed_first_rd then
        return false
    end
    local vip = RoleInfoModel.GetInstance():GetMainRoleVipLevel()
    local list = self:GetVipGiftCF()
    local is_show = false
    for i = 1, #list do
        local cf = list[i]
        local bought_num = ShopModel.GetInstance():GetGoodsBoRecordById(cf.id)
        local vip_limit = cf.limit_vip
        if vip >= vip_limit then
            --没买过
            if not bought_num then
                is_show = true
            elseif cf.limit_num - bought_num > 0 then
                is_show = true
            end
            break
        end
    end
    return is_show
end

--Vip是否过期
function VipModel:IsOutOfDate()
    return RoleInfoModel.GetInstance():GetMainRoleVipLevel() == 0
end

function VipModel:CheckPayedById(id)
    local result = false
    for _, lv_id in pairs(self.have_pay_list) do
        if lv_id == id then
            result = true
            break
        end
    end
    return result
end

function VipModel:IsCanFetchRebate()
    return self.rebate_info.time ~= 0 and self.rebate_info.time <= os.time() and (not self.rebate_info.fetch)
end

function VipModel:IsFetchedRebate()
    return self.rebate_info.fetch
end

function VipModel:GetRebateEndTime()
    return self.rebate_info.time
end