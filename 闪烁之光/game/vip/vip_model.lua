-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: xxx@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: {DATE}
-- --------------------------------------------------------------------
VipModel = VipModel or BaseClass()

function VipModel:__init(ctrl)
    self.ctrl = ctrl
    self:config()
end

function VipModel:config()
	self.get_list = {}
    self.daily_gift = {}
    self.privilege_list = {}
end

--vip礼包信息
function VipModel:setGetGiftList( list )
	if list and #list>0 then
		for k,v in pairs(list) do
			self.get_list[v.lev] = v.lev
		end	
	end
	GlobalEvent:getInstance():Fire(VipEvent.UPDATE_GET_LIST)
end

function VipModel:getGetGiftList( )
    if self.get_list then
    	return self.get_list
    end
    return nil
end
--获取VIP item是否存在未购买的情况
function VipModel:getVIPIsBuyStatus(lev)
    if self.get_list and self.get_list[lev] then
        return true
    end
    return nil
end
--累充信息
function VipModel:setAccList( list )
	self.acc_list = list
end
function VipModel:getAccList(  )
	return self.acc_list
end


function VipModel:checkGiftList(vip_lev)
	for _,v in pairs(self.get_list) do
        if v == vip_lev then
            return true
        end
    end
    return false
end

function VipModel:getGiftListVip()
    local vip_lev = 1
    local is_get = false
    local list = {}
    if Config.VipData.data_get_vip_icon then
        for i,v in pairs(Config.VipData.data_get_vip_icon) do
            table.insert(list,v)
        end
    end
    table.sort(list,function (a,b)
        return a.vip_lev < b.vip_lev
    end)
    for i, v in ipairs(list) do
        local is_get = self:checkGiftList(v.vip_lev)
        if not is_get then
            vip_lev = v.vip_lev
            break
        end
    end 
    return vip_lev
end
--是否有未领取累充礼包
function VipModel:getIsGetAcc(  )
	if self.acc_list and next(self.acc_list)~=nil then 
		local index = 0 
		for k,v in pairs(self.acc_list) do
			if v.status == 1 then  --可领取
				return true
			elseif v.status == 0 or v.status == 2 then --未达成/已领取
				index = index+1
			end
		end
		if index == #self.acc_list then 
			return false
		end
	end
	return false
end

-- 每日礼包数据
function VipModel:setDailyGiftData( data )
    self.daily_gift = data or {}
end

-- 获取每日礼包已购数量
function VipModel:getDailyGiftBuyCountById( id )
    local count = 0
    for k,v in pairs(self.daily_gift) do
        if v.id == id then
            count = v.count
            break
        end
    end
    return count
end

-- 特权礼包数据
function VipModel:setPrivilegeList( data )
    self.privilege_list = data or {}
end

-- 获取特权礼包数据
function VipModel:getPrivilegeDataById( id )
    for k,v in pairs(self.privilege_list) do
        if v.id == id then
            return v
        end
    end
end

-- 获取特权礼包红点
function VipModel:getPrivilegeRedStatus(  )
    local privelege_red = false
    -- 登陆时未购买过vip特权礼包的需要显示红点
    if not self.privilege_flag then
        privelege_red = true
        for k,v in pairs(self.privilege_list) do
            if v.status == 1 then
                privelege_red = false
                break
            end
        end
    end
    return privelege_red
end

-- 记录打开过vip特权礼包界面
function VipModel:setPrivilegeOpenFlag( flag )
    self.privilege_flag = flag
end

--月卡领取
function VipModel:setMonthCard(status)
    self.monthCard = status
end
function VipModel:getMonthCard()
    local status = false
    self.monthCard = self.monthCard or 0
    if self.monthCard == 1 then
        status = true
    else
        status = false
    end
    return status
end

function VipModel:__delete()
end