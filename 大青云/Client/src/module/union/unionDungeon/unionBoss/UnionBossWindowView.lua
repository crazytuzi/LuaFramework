--[[
	activity unionBoss
	wangshuai
]]

_G.UIUnionBossWindow = BaseUI:new("UIUnionBossWindow")

function UIUnionBossWindow:Create()
	self:AddSWF("unionBossWindowPanel.swf",true,"center")
end;

function UIUnionBossWindow:OnLoaded(objSwf)
	objSwf.fight_btn.click = function() self:FightBtnClick() end;
	objSwf.outActivity_btn.click = function() self:OutActivityClick()end;
end;

function UIUnionBossWindow:OnShow()

	--UnionbossModel:SetBossInfo(10,500000,700000,10000000,1,50)
	local list = {};
	for i=1,5 do
		local vo = {};
		vo.roleName = "蹦擦擦"..i;
		vo.skillNum = math.random(5000,10000000)
		table.push(list,vo)

	end;
	--UnionbossModel:SetSkillList(list)
	self:UpdataInfo();
end;

function UIUnionBossWindow:UpdataInfo()
	self:ShowUiInfo();
	self:ShowroleList();
	self:TimeUpdata();
end;

function UIUnionBossWindow:OnHide()

end;

function UIUnionBossWindow:ShowUiInfo()
	local objSwf = self.objSwf;
	local info = UnionbossModel:GetBossInfo();
	-- trace(info)
	-- print(info.curid,"-----------------")
	local cfg = t_guildBoss[info.curid];
	if not cfg then 
		print("ERROR: curid is error",info.curid)
		return 
	end
	local monsterCfg = t_monster[cfg.bossid];
	objSwf.BossName_txt.htmlText = monsterCfg.name;
	objSwf.allrole_txt.htmlText = info.allnum;
	local myinfo = UnionbossModel:GetMyRankInfo()
	if not myinfo.rank then 
		myinfo.rank = "未上榜"
	end;
	objSwf.myrank_txt.htmlText = myinfo.rank;

	local mySkillNum = UnionbossModel:GetMyDamage() or 0-- UnionbossModel:GetMyRankInfo().skillNum or 0;
	local val = mySkillNum / info.bossAllHp * 100;
	-- WriteLog(LogType.Normal,true,'-------------mySkillNum:',mySkillNum,info.bossAllHp)
	objSwf.hurtVal_txt.htmlText = string.format(StrConfig["unionBoss010"],getNumShow(mySkillNum),string.format("%.2f",val));

	objSwf.ProSoulValue_mc.maximum = info.bossAllHp;
	objSwf.ProSoulValue_mc.value = toint(info.bossCurHp);
end

function UIUnionBossWindow:ShowroleList()
	local objSwf = self.objSwf;
	local list = UnionbossModel:GetSkilllist();
	local bosscfg = UnionbossModel:GetBossInfo();
	local uilist = {};
	for i,info in ipairs(list) do 
		local vo = {};
		vo.name = info.roleName;
		local val = (info.skillNum /bosscfg.bossAllHp) * 100
		vo.addNum = string.format(StrConfig["unionBoss011"],getNumShow(info.skillNum),string.format("%.2f",val)) ;
		vo.rank =  i;
		table.push(uilist,UIData.encode(vo))
	end;
	objSwf.list.dataProvider:cleanUp();
	objSwf.list.dataProvider:push(unpack(uilist));
	objSwf.list:invalidateData();
end;

function UIUnionBossWindow:FightBtnClick()
	local posVO = QuestUtil:GetQuestPos(19001)
	local completeFuc = function()
		AutoBattleController:OpenAutoBattle();
	end
	MainPlayerController:DoAutoRun( posVO.mapId, _Vector3.new( posVO.x, posVO.y, 0 ),completeFuc);
end;

function UIUnionBossWindow:OutActivityClick()
	local okfun = function () self:OutActivity(); end;
	UIConfirm:Open(StrConfig["unionBoss009"],okfun);

end;

function UIUnionBossWindow:OutActivity()
	self:Hide();
	UnionBossController:OutUnionBoss()
	UnionBossController:OutAct()
end;

function UIUnionBossWindow:TimeUpdata()
	local objSwf  = self.objSwf;
	local time = UnionbossModel:GetLastTime()
	if time <= 0 then 
		time = 0;
	end;
	local t,s,f = CTimeFormat:sec2format(time)
	objSwf.lasttime_txt.htmlText = string.format("%02d:%02d:%02d",t,s,f)
end;

