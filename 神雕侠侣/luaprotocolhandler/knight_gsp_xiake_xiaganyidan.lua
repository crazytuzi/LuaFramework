local p = require "protocoldef.knight.gsp.xiake.xiaganyidan.sopenxgyd"
function p:process()
	if self.startover == 1 then
		XiakeMng.ClearXiaKeYuanZhengData()
	end
	local XiaGanYiDanMapDlg = require "ui.xiaganyidan.xiaganyidanmapdlg"
	XiaGanYiDanMapDlg:GetSingletonDialogAndShowIt():RefreshData(self.lefttimes, self.curstage, self.takeawardlist)
end

local p = require "protocoldef.knight.gsp.xiake.xiaganyidan.sopenmatchxgyd"
function p:process()
	for k,v in pairs(self.xiakeqixue) do
		XiakeMng.RefreshXiaKeYuanZhengData(k, nil, v)
	end
	for k,v in pairs(self.deadxiakes) do
		XiakeMng.RefreshXiaKeYuanZhengData(k, true)
	end
	XiakeMng.m_vBattleOrder_yuanzheng = self.fightxiakes
	local XiaGanYiDanBattleDlg = require "ui.xiaganyidan.xiaganyidanbattledlg"
	XiaGanYiDanBattleDlg:GetSingletonDialogAndShowIt():RefreshData(self.rolezonghescore, self.roleqixue, self.fightxiakes, self.matchrole.rolename, self.matchrole.shape, self.matchrole.level, self.matchrole.xiakemap, self.matchrole.zonghe, self.formid)
end

local p = require "protocoldef.knight.gsp.xiake.xiaganyidan.schangexiake"
function p:process()
	XiakeMng.m_vBattleOrder_yuanzheng = self.fightxiakes
	MyXiake_xiake.getInstance():RefreshMyXiakes()
	local XiaGanYiDanBattleDlg = require "ui.xiaganyidan.xiaganyidanbattledlg"
	if XiaGanYiDanBattleDlg:getInstanceOrNot() then
		XiaGanYiDanBattleDlg:getInstanceOrNot():RefreshMyXiaKe(XiakeMng.m_vBattleOrder_yuanzheng)
	end
end
