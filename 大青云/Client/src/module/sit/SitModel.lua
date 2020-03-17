--[[
打坐model
郝户
2014年11月11日16:32:38
]]

_G.SitModel = Module:new();

SitModel.sitRoleList   = {} -- 我的阵法中玩家列表
SitModel.exp           = 0; -- 本次打坐获得经验
SitModel.zhenqi        = 0; -- 本次打坐获得灵力
SitModel.nearbySitList = {} -- 附近打坐列表
SitModel.sitList       = {} -- 场景内所有打坐列表

function SitModel:SetSitState(id, sitRoleList, sitX, sitY)
	self.sitX = sitX
	self.sitY = sitY
	self.sitRoleList = sitRoleList

	for index, nearbySit in pairs( self.nearbySitList ) do
		if nearbySit.id == id then
			table.remove( self.nearbySitList, index )
			break
		end
	end
	self:sendNotification( NotifyConsts.SitFormationChange )
end

function SitModel:GetRoleNum()
	return #self.sitRoleList;
end

-- 打坐状态
-- SitConsts.NoneSit  = 0; -- 未打坐
-- SitConsts.OneSit   = 1; -- 一人打坐
-- SitConsts.TwoSit   = 2; -- 两仪阵
-- SitConsts.ThreeSit = 3; -- 三才阵
-- SitConsts.FourSit  = 4; -- 四象阵
function SitModel:GetSitState()
	return self:GetRoleNum();
end

-- 打坐结束，数据复原
function SitModel:SitCancel()
	self.sitX          = nil
	self.sitY          = nil
	self.sitRoleList   = {}
	self.nearbySitList = {}
	self.exp           = 0
	self.zhenqi        = 0
	self:sendNotification( NotifyConsts.SitCancel )
end

-- 打坐收益
function SitModel:Gain( exp, zhenqi )
	self.exp    = self.exp + exp;
	self.zhenqi = self.zhenqi + zhenqi;
	self:sendNotification( NotifyConsts.SitGainChange )
end

function SitModel:GetGainExp()
	return self.exp
end

function SitModel:GetGainzhenqi()
	return self.zhenqi
end

--------------------------------------------------------------------------------------------------------


function SitModel:SetNearbySit( nearbySitList )
	self.nearbySitList = nearbySitList
	self:sendNotification( NotifyConsts.SitNearby )
end

function SitModel:GetNearbySit()
	return self.nearbySitList
end

function SitModel:HasNearbySit()
	return #self.nearbySitList > 0
end