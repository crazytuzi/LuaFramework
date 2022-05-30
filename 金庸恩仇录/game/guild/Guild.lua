local Guild = class("Guild")

function Guild:ctor(param)
	self:init(param)
	function self.getName()
		return self.m_name
	end
	function self.getLv()
		return self.m_lv
	end
end

function Guild:init(param)
	self.m_id = param.id
	self.m_name = param.name
	self.m_level = param.level
	self.m_rank = param.rank
	self.m_roleMaxNum = param.roleNum
	self.m_createTime = param.createTime
	self.m_sumAttack = param.sumAttack
	self.m_bossId = param.bossId
	self.m_unionIndes = param.unionIndes
	self.m_unionOutdes = param.unionOutdes
	self.m_totalUnionMoney = param.totalUnionMoney
	self.m_currentUnionMoney = param.currentUnionMoney
	self.m_workshoplevel = param.workShopLevel
	self.m_barbecueTime = param.barbecueTime
	self.m_openBarRole = param.openBarRole
	self.m_shoplevel = param.shopLevel
	self.m_coverTime = param.coverTime
	self.m_freeworknum = param.freeworkNum
	self.m_buyworkNum = param.buyworkNum
	self.m_starworktime = param.starworktime
	self.m_worktype = param.worktype
	self.m_overtimeflag = param.overtimeflag
	self.m_buyNum = param.buyNum
	self.m_selfMoney = param.selfMoney
	self.m_nowRoleNum = param.nowRoleNum
	self.m_greenDragonTempleLevel = param.greenDragonTempleLevel
	self.m_leaderName = param.leaderName
	self.m_jopType = param.jopType
	self.m_fubenLevel = param.fblevel
end

function Guild:updateData(param)
	self.m_selfMoney = param.selfMoney or self.m_selfMoney
	self.m_currentUnionMoney = param.currentUnionMoney or self.m_currentUnionMoney
	self.m_workshoplevel = param.workshopLevel or self.m_workshoplevel
	self.m_greenDragonTempleLevel = param.qinglongLevel or self.m_greenDragonTempleLevel
	self.m_fubenLevel = param.fubenLevel or self.m_fubenLevel
end

return Guild