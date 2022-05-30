-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: xxx@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2019-09-19
-- --------------------------------------------------------------------
PetardActionModel = PetardActionModel or BaseClass()

function PetardActionModel:__init(ctrl)
    self.ctrl = ctrl
    self:config()
end

function PetardActionModel:config()
	self.petard_base_info = {}   -- 花火大会基础数据
	self.petard_redbag_data = {} -- 红包数据
end

-- 基础数据
function PetardActionModel:setPetardBaseInfo( data )
	self.petard_base_info = data or {}
end

function PetardActionModel:getPetardBaseInfo(  )
	return self.petard_base_info
end

-- 获取全服最大烟花热度值
function PetardActionModel:getMaxPetardHotVal(  )
	if self.petard_base_info then
		return self.petard_base_info.lev_score or 0
	end
	return 0
end

-- 红包数据
function PetardActionModel:setPetardRedbagData( data )
	self.petard_redbag_data = data or {}
end

function PetardActionModel:getPetardRedbagData(  )
	return self.petard_redbag_data
end

-- 活动是否达到开启条件
function PetardActionModel:checkPetardIsOpen(  )
	local is_open = false
	local holiday_open_lev_cfg = Config.HolidayPetardData.data_const["holiday_open_lev"]
	local holiday_open_day_cfg = Config.HolidayPetardData.data_const["holiday_open_day"]
	local role_vo = RoleController:getInstance():getRoleVo()
	if holiday_open_lev_cfg and holiday_open_lev_cfg.val <= role_vo.lev and holiday_open_day_cfg and holiday_open_day_cfg.val <= role_vo.open_day then
		is_open = true
	end
	return is_open
end

-- 是否可以燃放大烟花
function PetardActionModel:checkCanUseBigPetard(  )
	if not self.petard_base_info then return false end
	local cur_time = GameNet:getInstance():getTime()
	local end_time = self.petard_base_info.end_time or 0
	if cur_time > end_time then
		message(TI18N("活动未开启"))
		return false
	else
		local petard_start_time_cfg = Config.HolidayPetardData.data_const["petard_start_time"]
		local petard_end_time_cfg = Config.HolidayPetardData.data_const["petard_end_time"]
		local cur_hour = tonumber(os.date("%H", cur_time))
		if petard_start_time_cfg and petard_end_time_cfg and cur_hour >= petard_start_time_cfg.val and cur_hour < petard_end_time_cfg.val then
			return true
		else
			message(TI18N("请在19:00-23:00之间使用"))
			return false
		end
	end
end

function PetardActionModel:__delete()
end