--[[
    Created by IntelliJ IDEA.
    User: Hongbin Yang
    Date: 2016/7/12
    Time: 18:04
    黄金boss的model
   ]]


_G.ActivityGoldenBoss = setmetatable({}, { __index = BaseActivity });
ActivityModel:RegisterActivityClass(ActivityConsts.T_GoldenBoss, ActivityGoldenBoss);
--当前打的黄金boss已经获得的收益
ActivityGoldenBoss.gotReward = 0;
ActivityGoldenBoss.curMonsterBoss = nil;
ActivityGoldenBoss.curGoldHeap = 0;
ActivityGoldenBoss.curBossHp = 0;
function ActivityGoldenBoss:RegisterMsg()
	--技能释放提前通知
--	MsgManager:RegisterCallBack(MsgType.SC_GoldBossNotice, self, self.OnGoldBossSkillNotice);
	--金币BOSS金币收益
	MsgManager:RegisterCallBack(MsgType.SC_GoldBossReward, self, self.OnGoldBossReward);
	--boss血量更新
	MsgManager:RegisterCallBack(MsgType.SC_Update_GoldBossInfo_Notify, self, self.OnGoldBossUpdateInfo);

end

function ActivityGoldenBoss:GetType()
	return ActivityConsts.T_GoldenBoss;
end


-- 进入活动执行方法
function ActivityGoldenBoss:OnEnter()
	UIActivity:Hide();

	if not UIGoldenBossInfoPanel:IsShow() then
		UIGoldenBossInfoPanel:Show();
	end
end
--活动场景改变
function ActivityGoldenBoss:OnSceneChange()
	local goldBossCFG = t_goldboss[ActivityModel.worldLevel];
	if goldBossCFG then
		local monster = MonsterModel:GetMonsterByTid(goldBossCFG.bossID);
		if monster then
			self.curMonsterBoss = monster;
		end
		self.curGoldHeap = goldBossCFG.heap;
	end
	Notifier:sendNotification(NotifyConsts.GoldenBossOnScene);
end
-- 退出活动执行方法
function ActivityGoldenBoss:OnQuit()
	UIGoldenBossInfoPanel:Hide();
end

function ActivityGoldenBoss:OnAddMonster()
end

function ActivityGoldenBoss:OnRemoveMonster()
end

function ActivityGoldenBoss:OnGoldBossSkillNotice(msg)
	local mapid = CPlayerMap:GetCurMapID();
	local posStrA = GoldenBossUtil:GetAreaASkillPosition(mapid);
	local posStrB = GoldenBossUtil:GetAreaBSkillPosition(mapid);
	local tA = split(posStrA, ",");
	local tB = split(posStrB, ",");
	local posA = _Vector3.new(toint(tA[2]),toint(tA[3]),0);
	local posB = _Vector3.new(toint(tB[2]),toint(tB[3]),0);
	local name = "";
	local pfxPath = "";
	local pos = nil;
	if msg.type == 1 then
		name = "Area_A_Skill_A";
		pfxPath = "v_xieshane_miaozhun.pfx";
		pos = posA;
	elseif msg.type == 2 then
		name = "Area_A_Skill_B";
		pfxPath = "v_xieshane_jinbidiaoluo.pfx";
		pos = posA;
	elseif msg.type == 3 then
		name = "Area_B_Skill_A";
		pfxPath = "v_xieshane_miaozhun.pfx";
		pos = posB;
	elseif msg.type == 4 then
		name = "Area_B_Skill_B";
		pfxPath = "v_xieshane_jinbidiaoluo.pfx";
		pos = posB;
	end
	if not pos then return; end
	CPlayerMap:GetSceneMap():PlayPfxByPos(name, pfxPath, pos);
end

function ActivityGoldenBoss:OnGoldBossReward(msg)
	local totalDrop = msg.reward;
	if totalDrop == self.gotReward then return;
	end
	local currentDrop = totalDrop - self.gotReward;
	self.gotReward = totalDrop;
	self:ShowGoldDrop(currentDrop);
	--派发金币收益通知
	Notifier:sendNotification(NotifyConsts.GoldenBossGotReward,
		{ currentDrop = currentDrop, totalDrop = self.gotReward });
end

--显示金币掉落
function ActivityGoldenBoss:ShowGoldDrop(currentDrop)
	local goldBossCFG = t_goldboss[ActivityModel.worldLevel];
	if goldBossCFG then
		local monster = MonsterModel:GetMonsterByTid(goldBossCFG.bossID);
		if monster then
			self.curMonsterBoss = monster;
		end
		self.curGoldHeap = goldBossCFG.heap;
	end
	if not self.curMonsterBoss then return;
	end

	local heapCount = self.curGoldHeap;
	local dropList = RandomUtil:randomaAvgSeparate(currentDrop, heapCount, 0.05);
	local monster = self.curMonsterBoss;
	for i = 1, #dropList do
		if not monster:GetPos() then break; end
		local vo = {};
		vo.isSim = true;
		_randomSeed(_now());
		vo.charId = tonumber(GetServerTime() .. i .. RandomUtil:int(1, 1000));
		vo.charType = enEntType.eEntType_Item;
		vo.x = RandomUtil:int(monster:GetPos().x - 100, monster:GetPos().x + 100);
		vo.y = RandomUtil:int(monster:GetPos().y - 100, monster:GetPos().y + 100);
		vo.faceto = monster.faceto;
		vo.configId = 10 --绑定银两
		vo.ownerId = MainPlayerController:GetRoleID();
		vo.stackCount = dropList[i];
		vo.source = monster:GetCid();
		vo.born = 1;
		SimDropItemController:AddItem(vo);
	end
end

function ActivityGoldenBoss:OnGoldBossUpdateInfo(msg)
	self.curBossHp = msg.curhp;
	Notifier:sendNotification(NotifyConsts.GoldenBossUpdateBoss, {hp = msg.curhp});
end