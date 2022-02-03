-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: xxx@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-11-20
-- --------------------------------------------------------------------
SeerpalaceModel = SeerpalaceModel or BaseClass()

function SeerpalaceModel:__init(ctrl)
    self.ctrl = ctrl
    self:config()
end

function SeerpalaceModel:config()
	self.change_flag = false  -- 标记是否为置换英雄
	self.change_partner_id = 0 -- 当前已置换但未保存的英雄id,0为无
	self.last_summon_group_id = 0 -- 记录最后一次召唤的组id，用于获得物品界面点击再次召唤
end

function SeerpalaceModel:setChangeFlag( flag )
	self.change_flag = flag
end

function SeerpalaceModel:getChangeFlag(  )
	return self.change_flag
end

-- 设置当前已置换但未保存的英雄id
function SeerpalaceModel:setChangePartnerId( partner_id )
	self.change_partner_id = partner_id or 0
end

function SeerpalaceModel:getChangePartnerId(  )
	return self.change_partner_id
end

-- 记录最后一次召唤的组id
function SeerpalaceModel:setLastSummonGroupId( group_id )
	self.last_summon_group_id = group_id
end

function SeerpalaceModel:getLastSummonGroupId(  )
	return self.last_summon_group_id
end

function SeerpalaceModel:setFirstOpen( is_open )
	self.score_summon_is_open = is_open
end

function SeerpalaceModel:getFirstOpen()
	return self.score_summon_is_open or false
end

-- 更新先知积分召唤红点
function SeerpalaceModel:updateScoreSummonRed()
	if self:getFirstOpen() and self:getScoreSummonRed() then
		MainSceneController:getInstance():setBuildRedStatus(CenterSceneBuild.seerpalace, true)
	else
		MainSceneController:getInstance():setBuildRedStatus(CenterSceneBuild.seerpalace, false)
	end
end

-- 获取先知积分召唤红点
function SeerpalaceModel:getScoreSummonRed()
	self.role_vo = RoleController:getInstance():getRoleVo()
    local config = Config.RecruitHighData.data_seerpalace_const
    if config and config.recruit_vip and config.nature_score and config.light_dark_score then
		if self.role_vo.vip_lev >= config.recruit_vip.val then
			if self.role_vo.predict_point >= config.nature_score.val then
				return true
			end
			if self.role_vo.predict_point >= config.light_dark_score.val then
				return true
			end
		end
	end
	return false
end

function SeerpalaceModel:__delete()
end