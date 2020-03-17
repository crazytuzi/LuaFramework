--[[
	Jiayan
	WangShuai
]]

_G.HomesteadModel = Module:new();


function HomesteadModel:testinfo()
	local list = {};
	for i=1,10 do 
		local vo = {};
		vo.roleName = "傻逼"..i
		vo.iconId = math.random(4)
		vo.guid = "3253423_"..i;
		vo.lvl = i
		vo.exp = math.random(100,10)
		vo.quality = math.random(5)
		vo.queststeat = math.random(2)
		vo.atb = math.random(5)
		vo.skills = {};
		for xi=1,math.random(3) do 
			local xvo = {};
			xvo.skillId = math.random(30,13)
			table.push(vo.skills,xvo)
		end;
		table.push(list,vo);
	end;
	self:SetMyPupilInfo(list,1)
	self:SetXunXianPupilInfo(list,1)
	local buildList ={};
	for i=1,3 do 
		local vo = {};
		vo.buildType = i;
		vo.lvl = i*2;
		table.push(buildList,vo)
	end;
	self:SetBuildInfo(buildList)

	local myquestli = {}
	for i=1,10 do 
		local vo = {};
		vo.guid = "3452366_"..i;
		vo.tid = math.random(5)
		vo.lastTime = math.random(1000)
		vo.questlvl = i;
		vo.MaxTime = 1000;
		vo.rewardType = 10;
		vo.rewardNum = math.random(1000);
		vo.pupilExp = math.random(500)
		vo.quality = math.random(4);
		vo.itemid = 140621037;
		table.push(myquestli,vo)
	end;
	HomesteadModel:SetMyQuestInfo(myquestli,1)

	local questlist= {};
	for i=1,10 do
		local vo = {};
		vo.guid = "45836236_"..i
		vo.tid = math.random(5);
		vo.time = math.random(1000,900)
		vo.questlvl = math.random(100,10)
		vo.rewardType = 10;
		vo.rewardNum = math.random(1000);
		vo.pupilExp = math.random(500)
		vo.itemid = 140621037;
		vo.quality = math.random(4);
		vo.list = {};
		for xi=1,math.random(3) do 
			local xvo = {};
			xvo.id = math.random(12)
			table.push(vo.list,xvo)
		end;
		table.push(questlist,vo)
	end;
	HomesteadModel:SetQuestInfo(questlist)

	local rodlist = {};
	for i=1,10 do 
		local vo = {};
		vo.roleName = "卧槽啊"..i
		vo.fight = math.random(10000,20000)
		vo.roleId = "2145440"..i;
		vo.guid = "45836236_"..i
		vo.tid = math.random(5);
		vo.questlvl = math.random(100)
		vo.rodNum = math.random(2);
		vo.rewardType = 10
		vo.rewardNum = math.random(999)
		vo.rolelvl = math.random(10000,20000)
		vo.quality = math.random(4)
		table.push(rodlist,vo)
	end;
	self:SetRodQuestInfo(rodlist)
	local  rodinfoList = {};
	for i=1,20 do 
		local vo = {};
		vo.time = math.random(1000,30000)
		vo.type = math.random(2)-1;
		vo.roleName = "对象名"..i;
		vo.rewardType = 10
		vo.rewardNum = math.random(999);
		table.push(rodinfoList,vo)
	end;
	self:SetRodQuestInfoTwo(rodinfoList)

	self:SetRodQuestNum(math.random(10),math.random(1000))
end;


-------------建筑物

HomesteadModel.buildInfoList = {}; -- 各建筑物信息list

function HomesteadModel:SetBuildInfo(list)
	--trace(list)
	self.buildInfoList = {};
	for i,info in pairs(list) do 
		local name = HomesteadConsts.CompareList[info.buildType]
		if name then 
			local vo = {};
			vo.buildType = name;
			vo.lvl  = info.lvl;
			self.buildInfoList[name] = vo;
		end;
	end;
	Notifier:sendNotification(NotifyConsts.ZhuLingProgress,{list=nil});
end;

function HomesteadModel:GetBUildInfoList()
	return self.buildInfoList;
end;

function HomesteadModel:GetBuildInfoLvl(name)
	if self.buildInfoList[name] then 
		return self.buildInfoList[name].lvl or 1;
	end
	return 1;
end;

function HomesteadModel:SetABuildInfoLvl(type,lvl)
	local name = HomesteadConsts.CompareList[type]
	if self.buildInfoList[name] then 
		self.buildInfoList[name].lvl = lvl;
	end
end;


-------------弟子

HomesteadModel.myPupilList = {} -- 我的弟子信息  
HomesteadModel.xunXianPupilList = {} -- 寻仙台弟子信息  

function HomesteadModel:SetMyPupilInfo(list,type)
	--trace(list)
	if type == 1 then 
		self.myPupilList = {};
	end;
	for i,info in pairs(list) do 
		local vo = {};
		vo.roleName = info.roleName;
		vo.iconId = info.iconId;
		vo.guid = info.guid;
		vo.lvl = info.lvl;
		vo.exp = info.exp;
		vo.quality = info.quality;
		vo.queststeat = info.queststeat;
		vo.atb = info.atb;
		vo.skillList = {};
		for xi,xinfo in pairs(info.skills) do 
			local xvo = {};
			xvo.skillId = xinfo.skillId;
			table.push(vo.skillList,xvo)
		end;
		if type == 2 then 
			local a,index = HomesteadModel:GetApupilList(info.guid)
			if index then 
				self.myPupilList[index] = vo;
			else
				table.push(self.myPupilList,vo);
			end;
		else
			table.push(self.myPupilList,vo);
		end;
	end;
end;

function HomesteadModel:GetPupilList()
	return self.myPupilList;
end;

function HomesteadModel:GetMyPupilAllNum()
	local num = 0;
	for i,info in pairs(self.myPupilList) do 
		num = num + 1;
	end;
	return num;
end;

function HomesteadModel:GetApupilList(uid)
	for i,info in pairs(self.myPupilList) do 
		if info.guid == uid then 
			return info,i;
		end;
	end;
end;

function HomesteadModel:DeleteAMyPupil(uid)
	local list = {};
	for i,info in pairs(self.myPupilList) do 
		if info.guid ~= uid then 
			table.push(list,info)
		end;
	end;
	self.myPupilList = list;
end;


-------------寻仙台弟子
function HomesteadModel:SetXunXianPupilInfo(list)
	--if type == 1 then 
	self.xunXianPupilList = {};
	self.xunXianPupilList.infolist = {};
	--end;
	for i,info in ipairs(list) do
		local vo = {};
		vo.roleName = info.roleName;
		vo.iconId = info.iconId;
		vo.guid = info.guid;
		vo.lvl = info.lvl;
		vo.quality = info.quality
		vo.atb = info.atb;
		vo.state = info.state;
		vo.skillList = {};
		for xi,xinfo in pairs(info.skills) do 
			local xvo = {};
			xvo.skillId = xinfo.skillId;
			table.push(vo.skillList,xvo)
		end;
		table.push(self.xunXianPupilList.infolist,vo)
	end;
end;

function HomesteadModel:GetXunXianPupilInfo()
	return self.xunXianPupilList.infolist or {};
end;

function HomesteadModel:SetXunXianTime(time)
	self.xunXianPupilList.lastTime = time;
end;

function HomesteadModel:GetXunXianTime()
	return self.xunXianPupilList.lastTime or -1;
end;

function HomesteadModel:SetXunXianUpdataNum(num)
	self.xunXianPupilList.updataNum = num + 1;
end;

function HomesteadModel:GetXunXianUpdataNum()
	return self.xunXianPupilList.updataNum or 1;
end;

function HomesteadModel:SetXunXianUpdataRescruit(num)
	self.xunXianPupilList.recruit = num + 1
end;

function HomesteadModel:GetXunXianUpdataRescruit()
	return self.xunXianPupilList.recruit or 1;
end;

function HomesteadModel:GetXunxianApupilList(uid)
	local list = self:GetXunXianPupilInfo()
	for i,info in pairs(list) do 
		if info.guid == uid then 
			return info;
		end;
	end;
end;




--------------------任务殿

HomesteadModel.myQuestList = {}; 	-- 我的任务信息
HomesteadModel.questList = {};		-- 任务殿信息；
HomesteadModel.questUpdataInfo = {};-- 任务殿刷新信息；
HomesteadModel.rodQuestList = {};	-- 掠夺任务
HomesteadModel.rodQuestinfo = {};	-- 掠夺任务操作信息
HomesteadModel.rodQuestVO = {};-- 信息；

function HomesteadModel:SetMyQuestInfo(list)
	--if type == 1 then 
		self.myQuestList = {};
--	end;
	for i,info in pairs(list) do
		local vo ={};
		vo.guid = info.guid;
		vo.tid = info.tid;
		vo.lastTime = info.lastTime;
		vo.questlvl = info.questlvl;
		vo.MaxTime = info.MaxTime;
		vo.rewardType = info.rewardType;
		vo.rewardNum = info.rewardNum;
		vo.pupilExp = info.pupilExp;
		vo.quality = info.quality 
		vo.itemid = info.itemid;
		vo.status = info.status;
		table.push(self.myQuestList,vo)
	end;
end;

function HomesteadModel:GetMyQuestInfo()
	return self.myQuestList;
end;

function HomesteadModel:DeleteMyAIngQuest(uid)
	local list = {};
	for i,info in pairs(self.myQuestList) do 
		if info.guid ~= uid then 
			table.push(list,info)
		end;
	end;
	self.myQuestList = list;
end;

function HomesteadModel:SetQuestInfo(list)
	self.questList = {};
	for i,info in pairs(list) do 
		local vo = {};
		vo.guid = info.guid;
		vo.tid = info.tid;
		vo.time = info.time;
		vo.questlvl = info.questlvl;
		vo.rewardType = info.rewardType;
		vo.rewardNum = info.rewardNum;
		vo.pupilExp = info.pupilExp;
		vo.quality = info.quality 
		vo.itemid = info.itemid;
		vo.questState = info.questState;
		vo.monsterVo = {};
		for xi,xinfo in pairs(info.list) do 
			local xvo = {};
			xvo.id = xinfo.id;
			table.push(vo.monsterVo,xvo)
		end;
		table.push(self.questList,vo)
	end;
end;

function HomesteadModel:GetQuestInfo()
	return self.questList;
end;

function HomesteadModel:getAQuestInfo(guid)
	for i,info in ipairs(self.questList) do 
		if info.guid == guid then 
			return info
		end;
	end;
	return nil;
end;


function HomesteadModel:SetRodQuestInfo(list)
	self.rodQuestList = {};
	for i,info in pairs(list) do
		local vo = {};
		vo.roleName = info.roleName;
		vo.fight = info.fight;
		vo.roleId = info.roleId;
		vo.guid = info.guid;
		vo.tid = info.tid;
		vo.questlvl = info.questlvl;
		vo.rodNum = info.rodNum;
		vo.rewardType = info.rewardType;
		vo.rewardNum = info.rewardNum;
		vo.rolelvl = info.rolelvl;
		vo.quality = info.quality
		table.push(self.rodQuestList,vo)
	end;
end;

function HomesteadModel:GetRodQuestInfo()
	return self.rodQuestList
end;

function HomesteadModel:SetARodQuestRodNum(uid)
	for i,info in ipairs(self.rodQuestList) do
		if info.guid == uid then 
			info.rodNum = info.rodNum + 1;
			if info.rewardNum > 1 then 
				local val = toint(info.rewardNum * 0.2);
				info.rewardNum = info.rewardNum - val;
			end;
			break;
		end;
	end;
end;


function HomesteadModel:SetRodQuestInfoTwo(list)
	self.rodQuestinfo = {};
	for i,info in pairs(list) do 
		local vo = {};
		vo.time = info.time;
		vo.type = info.type;
		vo.roleName = info.roleName;
		vo.rewardType = info.rewardType;
		vo.rewardNum = info.rewardNum;
		vo.descID = info.descID;
		table.push(self.rodQuestinfo,vo)
	end;
	table.sort(self.rodQuestinfo,function(A,B)
		if A.time > B.time then
			return true;
		else
			return false;
		end
	end);
end;

function HomesteadModel:GetRodQuestInfoTwo()
	return self.rodQuestinfo
end;

function HomesteadModel:SetRodQuestNum(rodNum,rodCD)
	self.rodQuestVO.rodNum = rodNum;
	self.rodQuestVO.rodCD = rodCD;
end;


function HomesteadModel:GetRodQuestNum()
	return self.rodQuestVO;
end;


function HomesteadModel:SetQusetTime(time)
	self.questUpdataInfo.lastTime = time;
end;

function HomesteadModel:GetQuestTime()
	return self.questUpdataInfo.lastTime or -1;
end;

function HomesteadModel:SetQuestUpdataNum(num)
	self.questUpdataInfo.updataNum = num + 1;
end;

function HomesteadModel:GetQuestUpdataNum()
	return self.questUpdataInfo.updataNum or 1;
end;







------------------remind状态
HomesteadModel.GetPupiUpdata = true;
function HomesteadModel:SetPupiUpdata(isUpdata)
	self.GetPupiUpdata = isUpdata;
end;

function HomesteadModel:GetPupilUpState()
	return self.GetPupiUpdata
end;

