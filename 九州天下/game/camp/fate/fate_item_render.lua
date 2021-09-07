
----------------------------------------------------------------------------
--CampFateAttackItemRender	气运进攻方战报列表
----------------------------------------------------------------------------
CampFateAttackItemRender = CampFateAttackItemRender or BaseClass(BaseCell)
function CampFateAttackItemRender:__init()
	self.lbl_log_text = self:FindVariable("LogText")
end

function CampFateAttackItemRender:__delete()
	self.lbl_log_text = nil
end

function CampFateAttackItemRender:OnFlush()
	if not self.data or not next(self.data) then return end

	local str = ""
	local content = Language.Camp.AttackReportText[self.data.report_type]
	local time = os.date('%Y-%m-%d %H:%M:%S', self.data.report_timestamp)

	if self.data.report_type == CAMP_REPORT_TYPE.REPORT_TYPE_KILL_DACHEN then							-- 击杀大臣
		str = string.format(content, time, Language.Common.CampName[self.data.enemy_camp] or "", self.data.rob_qiyun_val)
	
	elseif self.data.report_type == CAMP_REPORT_TYPE.REPORT_TYPE_KILL_FLAG then							-- 击杀国旗
		str = string.format(content, time, Language.Common.CampName[self.data.enemy_camp] or "", self.data.rob_qiyun_val)
	
	elseif self.data.report_type == CAMP_REPORT_TYPE.REPORT_TYPE_KILL_QIYUN_TOWER_SPEED_CHANGE then		-- 摧毁气运塔，生产时间被改变
		str = string.format(content, time, Language.Common.CampName[self.data.enemy_camp] or "", self.data.rob_qiyun_val, self.data.percent)

	elseif self.data.report_type == CAMP_REPORT_TYPE.REPORT_TYPE_KILL_QIYUN_TOWER_SPEED_REFRESH then	-- 摧毁气运塔，刷新生成加成时间
		str = string.format(content, time, Language.Common.CampName[self.data.enemy_camp] or "", self.data.rob_qiyun_val)
	end

	self.lbl_log_text:SetValue(str)
end

----------------------------------------------------------------------------
--CampFateDefendItemRender	气运防守方战报列表
----------------------------------------------------------------------------
CampFateDefendItemRender = CampFateDefendItemRender or BaseClass(BaseCell)
function CampFateDefendItemRender:__init()
	self.lbl_log_text = self:FindVariable("LogText")
end

function CampFateDefendItemRender:__delete()
	self.lbl_log_text = nil
end

function CampFateDefendItemRender:OnFlush()
	if not self.data or not next(self.data) then return end

	local str = ""
	local content = Language.Camp.DefendReportText[self.data.report_type]
	local time = os.date('%Y-%m-%d %H:%M:%S', self.data.report_timestamp)

	if self.data.report_type == CAMP_REPORT_TYPE.REPORT_TYPE_KILL_DACHEN then							-- 击杀大臣
		str = string.format(content, time, Language.Common.CampName[self.data.enemy_camp] or "", self.data.rob_qiyun_val)
	
	elseif self.data.report_type == CAMP_REPORT_TYPE.REPORT_TYPE_KILL_FLAG then							-- 击杀国旗
		str = string.format(content, time, Language.Common.CampName[self.data.enemy_camp] or "", self.data.rob_qiyun_val)
	
	elseif self.data.report_type == CAMP_REPORT_TYPE.REPORT_TYPE_KILL_QIYUN_TOWER_SPEED_CHANGE then		-- 摧毁气运塔，生产时间被改变
		str = string.format(content, time, Language.Common.CampName[self.data.enemy_camp] or "", self.data.rob_qiyun_val, self.data.percent)

	elseif self.data.report_type == CAMP_REPORT_TYPE.REPORT_TYPE_KILL_QIYUN_TOWER_SPEED_REFRESH then	-- 摧毁气运塔，刷新生成加成时间
		str = string.format(content, time, Language.Common.CampName[self.data.enemy_camp] or "", self.data.rob_qiyun_val)

	elseif self.data.report_type == CAMP_REPORT_TYPE.REPORT_TYPE_DACHEN_DEFEND_SUCC then				-- 成功保卫大臣
		str = string.format(content, time, self.data.rob_qiyun_val)

	elseif self.data.report_type == CAMP_REPORT_TYPE.REPORT_TYPE_FLAG_DEFEND_SUCC then					-- 成功保卫国旗
		str = string.format(content, time, self.data.rob_qiyun_val)

	end
	self.lbl_log_text:SetValue(str)
end
