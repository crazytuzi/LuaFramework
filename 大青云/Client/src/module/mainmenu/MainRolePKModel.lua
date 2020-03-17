--[[
	PKModel
	2014年12月6日, PM 03:31:13
	wangyanwei
]]
--peace team union servicer camp goodEvil allRole custom
_G.classlist['MainRolePKModel'] = 'MainRolePKModel'
_G.MainRolePKModel=Module:new();
MainRolePKModel.objName = 'MainRolePKModel'
MainRolePKModel.pkStateNum = 0;


--常量

MainRolePKModel.PKData = {
	{pkBoolean = false},{pkBoolean = false},{pkBoolean = false},{pkBoolean = false},{pkBoolean = false},{pkBoolean = false}
}

MainRolePKModel.pkNum = -1;	--在都是自定义的情况下  判断不必要重复的发送；

MainRolePKModel.PK_Guild = 32;  -- 同帮派
MainRolePKModel.PK_League = 16;  -- 结盟玩家
MainRolePKModel.PK_Hostility = 8;  -- 敌对帮派
MainRolePKModel.PK_Team = 4;  -- 同队伍
MainRolePKModel.PK_RedName = 2;  -- 红名玩家
MainRolePKModel.PK_GrayName = 1;  -- 灰名玩家

MainRolePKModel.pkState = 0;  --自己PK的状态（是否PK保护或者红名）

function MainRolePKModel:UpDataPkState(stateObj)
	if not stateObj then return end;
	AutoBattleController:ResetAutoSendHangStateTime()
	self.pkState = stateObj.mystate;
	if stateObj.pkid ~= 7 then 
		self.pkStateNum = stateObj.pkid;
		self:sendNotification(NotifyConsts.UpPKStateIconUrlChange);
		return;
	end
	self.pkStateNum = stateObj.pkid;
	self.pkNum = stateObj.myselfpk;
	if bit.band(stateObj.myselfpk,self.PK_Guild) == self.PK_Guild then self.PKData[1].pkBoolean = true; else self.PKData[1].pkBoolean = false; end
	if bit.band(stateObj.myselfpk,self.PK_League) == self.PK_League then self.PKData[2].pkBoolean = true; else self.PKData[2].pkBoolean = false; end
	if bit.band(stateObj.myselfpk,self.PK_Hostility) == self.PK_Hostility then self.PKData[3].pkBoolean = true; else self.PKData[3].pkBoolean = false; end
	if bit.band(stateObj.myselfpk,self.PK_Team) == self.PK_Team then self.PKData[4].pkBoolean = true; else self.PKData[4].pkBoolean = false; end
	if bit.band(stateObj.myselfpk,self.PK_RedName) == self.PK_RedName then self.PKData[5].pkBoolean = true; else self.PKData[5].pkBoolean = false; end
	if bit.band(stateObj.myselfpk,self.PK_GrayName) == self.PK_GrayName then self.PKData[6].pkBoolean = true; else self.PKData[6].pkBoolean = false; end
	self:sendNotification(NotifyConsts.UpPKStateIconUrlChange);
end

--发送PK状态
function MainRolePKModel:SetPKStateHandler(pkIndex,defined)
	local obj = {};
	obj.pkid = pkIndex;
	if obj.pkid ~= 7 then 
		if obj.pkid == self.pkStateNum then
			return ;
		end
	end
	obj.myselfpk = defined;
	if obj.pkid == self.pkStateNum then
		if self.pkNum == obj.myselfpk then
			return;
		end
	end
	self.pkNum = obj.myselfpk;
	MainMenuController:OnSendPkState(obj.pkid,obj.myselfpk);
end
--获取都可以选择哪些PK模式
function MainRolePKModel:GetStatePKData()
	local objState = {};
	for i = 1 , 8 do
		table.push(objState,{});
	end
	objState[1].peace = false;
	objState[2].team = true;
	objState[3].union = true;
	objState[4].servicer = true;
	objState[5].camp = true;
	objState[6].goodEvil = true;
	objState[7].allRole = true;
	objState[8].custom = true;
	local playerLevel=MainPlayerModel.humanDetailInfo.eaLevel;
	if playerLevel < 30 then return objState; end
	local cfg = t_map[CPlayerMap:GetCurMapID()];
	if cfg.have_punish then
		objState[6].goodEvil = false;
	else
		objState[6].goodEvil = true;
	end
	objState[7].allRole = false;
	objState[8].custom = false;
	local team = TeamModel:IsInTeam();
	if team then objState[2].team = false else objState[2].team = true; end
	objState[5].camp = true;
	objState[4].servicer = false;
	local union = UnionUtils:CheckMyUnion();
	if union then objState[3].union = false; else objState[3].union = true; end
	return objState ;
end
--获取自身PK状态  （是否红名）、
function MainRolePKModel:GetPKState()
	return self.pkState;
end
--获取PK模式索引
function MainRolePKModel:GetPKIndex()
	return self.pkStateNum;
end