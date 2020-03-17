--[[
帮派地宫争夺战
zhangshuhui
]]
_G.UnionDiGongModel = Module:new()

UnionDiGongModel.digongunionList = {};  --帮派地宫信息列表
UnionDiGongModel.unionBidList = {};     --帮派地宫竞标列表

UnionDiGongModel.nRank = 0;--排名
UnionDiGongModel.isAtWarActivity = false;

UnionDiGongModel.curUnionName = "";		--当前扛旗帮派
UnionDiGongModel.curRoleName = "";		--当前扛旗人名

UnionDiGongModel.isShowFlag = false;	--当前是否显示旗帜
UnionDiGongModel.flagposX = 0;			--旗帜x坐标
UnionDiGongModel.flagposY = 0;			--旗帜y坐标

UnionDiGongModel.nDiGongTime = 0;		--活动剩余时间

UnionDiGongModel.unionInfo = {};		--两个帮派信息
UnionDiGongModel.win_unionid = 0;		--获胜方帮派id

UnionDiGongModel.unionNameInfo = {};	--帮派名称

UnionDiGongModel.isGoGetFlag = false;   --是否自动追踪旗帜

UnionDiGongModel.bossList = {};

function UnionDiGongModel:SetBossInfo(bossInfo)
	self.bossList[bossInfo.tid] = bossInfo
	UICaveBossInfo:ResetBossHp(bossInfo.tid)
end

function UnionDiGongModel:getBossInfo(tid)
	return self.bossList[tid]
end

function UnionDiGongModel:SetDiGongUnionList(list)
	self.digongunionList = list;
	self:sendNotification(NotifyConsts.UnionDiGongInfoUpdate);
end;
function UnionDiGongModel:GetDiGongUnionList()
	return self.digongunionList;
end;

function UnionDiGongModel:GetGuildIdById(id)
	if not self.digongunionList then return nil; end
	for i,vo in pairs(self.digongunionList) do
		if vo.id == id then
			return vo.Unionid;
		end
	end
	return nil;
end

function UnionDiGongModel:SetUnionBidList(list)
	self.unionBidList = list;
	self:sendNotification(NotifyConsts.UnionDiGongBidListUpdate);
end;
function UnionDiGongModel:GetUnionBidList()
	return self.unionBidList;
end;

function UnionDiGongModel:GetisMyBuState(buId)
	local myUnionId = UnionModel:GetMyUnionId()
	local list = UnionDiGongController.curBuildState;
	for i,info in ipairs(list) do 
		if info.id == (UnionDiGongConsts.ZhuZiBaseid + buId) and info.Unionid == myUnionId  then 
			return 1
		end;
	end;	
	return 0;
end;

function  UnionDiGongModel:GetJianzhuInfo(buId)
	local list = UnionDiGongController.curBuildState;
	for i,info in ipairs(list) do 
		if info.id == (UnionDiGongConsts.ZhuZiBaseid + buId) then 
			return info
		end;
	end;
	return {};
end;	

function UnionDiGongModel:SetRank(nrank)
	self.nRank = nrank;
	--self:sendNotification(NotifyConsts.CityUnionWarResult);
end;
function UnionDiGongModel:GetRank()
	return self.nRank;
end;

function UnionDiGongModel:GetIsAtUnionActivity()
	return self.isAtWarActivity
end;
function UnionDiGongModel:SetIsAtUnionActivity(isAtWarActivity)
	self.isAtWarActivity = isAtWarActivity;
end;

function UnionDiGongModel:SetCurFlagInfo(curUnionName, curRoleName)
	self.curUnionName = curUnionName;
	self.curRoleName = curRoleName;
end
function UnionDiGongModel:GetCurFlagInfo()
	return self.curUnionName,self.curRoleName;
end

function UnionDiGongModel:SetFlagPos(posX,posY)
	self.flagposX = posX;
	self.flagposY = posY;
end
function UnionDiGongModel:GetFlagPos()
	return self.flagposX,self.flagposY;
end

function UnionDiGongModel:SetIsShowFlag(isShowFlag)
	self.isShowFlag = isShowFlag;
end
function UnionDiGongModel:GetIsShowFlag()
	return self.isShowFlag;
end

function UnionDiGongModel:SetDiGongTime(nDiGongTime)
	self.nDiGongTime = nDiGongTime;
end
function UnionDiGongModel:GetDiGongTime()
	return self.nDiGongTime;
end

function UnionDiGongModel:ClearData()
	self.unionInfo = {};
end
function UnionDiGongModel:GetUnionInfo()
	return self.unionInfo;
end
function UnionDiGongModel:UpdateUnionInfo(vo1,vo2)
	self.unionInfo[vo1.id] = vo1;
	self.unionInfo[vo2.id] = vo2;
	self:sendNotification(NotifyConsts.UnionDiGongWarUpdate);
end

function UnionDiGongModel:GetWinUnionId()
	return self.win_unionid;
end
function UnionDiGongModel:SetWinUnionId(id)
	self.win_unionid = id;
end

function UnionDiGongModel:GetUnionNameById(id)
	return self.unionNameInfo[id];
end
function UnionDiGongModel:SetUnionNameById(vo)
	self.unionNameInfo[vo.id] = vo.unionName;
end

function UnionDiGongModel:GetIsGoGetFlag()
	return self.isGoGetFlag;
end
function UnionDiGongModel:SetIsGoGetFlag(isGo)
	self.isGoGetFlag = isGo;
end

function UnionDiGongModel:HasCanFightBoss()
	local level = MainPlayerModel.humanDetailInfo.eaLevel;
	for k, v in pairs(self.bossList) do
		if v.state == 0 then
			if level >= t_swyj[v.tid].needLv then
				return true;
			end
		end
	end
	return false;
end