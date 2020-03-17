
--[[
跨服场景追踪界面
]]

_G.UIInterSSRight = BaseUI:new("UIInterSSRight");


function UIInterSSRight:Create()
	self:AddSWF("interserSceneRight.swf", true, "interserver");
	self:AddChild(UIInterSSceneMap,"mapcc")
end;
function UIInterSSRight:OnLoaded(objSwf)
	self:GetChild("mapcc"):SetContainer(objSwf.childPanelc)
	objSwf.questlist.itemClick = function(e) self:OnQuestClick(e) end;
	objSwf.questlist.btnRClick = function(e) self:OnQiQuestClick(e) end;
	objSwf.bossList.itemClick = function(e) self:OnBossListClick(e) end;

	objSwf.map_btn.click = function() self:IsShowMap() end;
	objSwf.team_btn.click = function() self:OnShowTwam() end;
	objSwf.quest_btn.click = function() self:OnShowQuest() end;

	objSwf.killRoleRank_btn.click = function() self:ShowRanklist() end;
	objSwf.outAct_btn.click = function() self:OnOutActivaty() end;
end;

function UIInterSSRight:OnOutActivaty() 
	InterSerSceneController:ReqOutInterServiceScene(); 
	self:Hide();
end;

function UIInterSSRight:SetssNum()
	local num = InterSerSceneModel:GetSSSCoreNum()
	print(num,' sdsdadsd sasds 撒打算打算')
	self.objSwf.ssNum.htmlText = num;
end;

function UIInterSSRight:OnShow()
	InterSerSceneController:ReqInterSSQuestMyInfo(); --请求我的任务信息

	self:UpdataQuestList();
	self:UpdataBossList();
	--地图
	--self:IsShowMap()
	--倒计时
	self:SetLastTime();
	--跨服积分
	self:SetssNum();
	if MainInterServiceUI:IsShow() then 
		MainInterServiceUI:Hide();
	end;

end;

function UIInterSSRight:SetLastTime()
	local objSwf = self.objSwf;
	if not objSwf then return end;

	local time = InterSerSceneModel:GetLastTime();
	local t,s,f = CTimeFormat:sec2format(time)
	local str = string.format("%02d:%02d:%02d",t,s,f)
	objSwf.lastTime.htmlText = str;
end;

function UIInterSSRight:ShowRanklist(type)
	if not self:IsShow() then return end;
	if  UIInteSSRanklist:IsShow() then 
		UIInteSSRanklist:Hide();
	else
		UIInteSSRanklist:Show()
	end;
end;

function UIInterSSRight:OnHide()

	if UIInterSerSceneMainPage:IsShow() then 
		UIInterSerSceneMainPage:Hide();
	end;

	if UIInteSSRanklist:IsShow() then 
		UIInteSSRanklist:Hide();
	end;

	if UIInterSSQuestTwo:IsShow() then 
		UIInterSSQuestTwo:Hide();
	end;

	-- if not MainInterServiceUI:IsShow() then 
	-- 	MainInterServiceUI:Show("uiInterServiceScene");
	-- end;
	if UIQiZhanDungeonTip:IsShow() then 
		UIQiZhanDungeonTip:Hide();
	end;
end;

function UIInterSSRight:OnShowQuest()
	if not self:IsShow() then return end;
	if UIInterSSQuestTwo:IsShow() then 
		UIInterSSQuestTwo:Hide();
	else
		UIInterSSQuestTwo:Show();
	end;
end;

function UIInterSSRight:OnShowTwam()
	if not self:IsShow() then return end;
	if UIInterSSTeam:IsShow() then 
		UIInterSSTeam:Hide();
	else

		UIInterSSTeam:Show()
	end;
end;

function UIInterSSRight:OnQiQuestClick(e)
	-- print("questUId",e.item.questUId,'')
	-- print("questId",e.item.questId)
	local okfun = function() 
		InterSerSceneController:ReqInterSSQuestDiscard(e.item.questUId)
	end
	UIConfirm:Open(string.format(StrConfig['interServiceDungeon437']),okfun);
end;

function UIInterSSRight:OnQuestClick(e)
	-- print("questUId",e.item.questUId)
	-- print("questId",e.item.questId)
	local cfg = t_kuafuquest[e.item.questId];
	if cfg.questType == 3 then return end;
	local point = QuestUtil:GetQuestPos(cfg.pos);

	if not point then return; end
	local completeFuc = function()
		AutoBattleController:OpenAutoBattle();
	end

	local selfPlayer = MainPlayerController:GetPlayer()
    if selfPlayer:IsDead() then--死亡不能移动
    	FloatManager:AddNormal(StrConfig['interServiceDungeon461'])
    	return
    end

	if not MainPlayerController:DoAutoRun(point.mapId,_Vector3.new(point.x,point.y,0),completeFuc) then
		FloatManager:AddSysNotice(2005014);--已达上限
	else
		MainPlayerController:DoAutoRun(point.mapId,_Vector3.new(point.x,point.y,0),completeFuc);
	end

end;


function UIInterSSRight:OnBossListClick(e)
	-- print("monsterId",e.item.monsterId)

	local cfg = t_kuafusceneboss[e.item.monsterId];
	local point = QuestUtil:GetQuestPos(cfg.pos);
	if not point then return; end
	local completeFuc = function()
		AutoBattleController:OpenAutoBattle();
	end

	local selfPlayer = MainPlayerController:GetPlayer()
    if selfPlayer:IsDead() then--死亡不能移动
    	FloatManager:AddNormal(StrConfig['interServiceDungeon461'])
    	return
    end
    
	if not MainPlayerController:DoAutoRun(point.mapId,_Vector3.new(point.x,point.y,0),completeFuc) then
		FloatManager:AddSysNotice(2005014);--已达上限
	else
		MainPlayerController:DoAutoRun(point.mapId,_Vector3.new(point.x,point.y,0),completeFuc);
	end

end;

function UIInterSSRight:UpdataQuestList()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	local list =  InterSerSceneModel:GetMyQuestInfo()
	local uilist = {};


	-- 排序
	table.sort(list,function(A,B)
			if A.questState < B.questState then
				return true;
			else
				return false;
			end
		end);


	for i,info in pairs(list) do 
		local vo = {};
		local cfg = t_kuafuquest[info.questId];
		if cfg then 
			local str = StrConfig['interServiceDungeon409'];
			local numCfg = split(cfg.questGoals,",")
			if info.questState == 3 then 
				break;
			end;
			if info.questState == 2 then  -- 已完成
				if cfg.questType == 1 or cfg.questType == 2 then 
					str = str .. "<font color='#00ff00'>" .. t_monster[toint(numCfg[1])].name .. "</font>";
					--str = str .. "<font color='#c8c8c8'>(" .. info.condition .. "/" .. numCfg[2] .. ")</font>"
				elseif cfg.questType == 3 then 
					str = str .. StrConfig["interServiceDungeon435"] 
					--str = str .. "<font color='#c8c8c8'>(" .. info.condition .. "/" .. numCfg[1] .. ")</font>"
				end;
				vo.Desc = str .. StrConfig['interServiceDungeon436']

			else --任务未完成
				if cfg.questType == 1 or cfg.questType == 2 then 
					str = str .. "<font color='#00ff00'>" .. t_monster[toint(numCfg[1])].name .. "</font>";
					str = str .. "<font color='#c8c8c8'>(" .. info.condition .. "/" .. numCfg[2] .. ")</font>"
				elseif cfg.questType == 3 then 
					str = str .. StrConfig["interServiceDungeon435"] 
					str = str .. "<font color='#c8c8c8'>(" .. info.condition .. "/" .. numCfg[2] .. ")</font>"
				end;
				vo.Desc = str;
			end;
			vo.Name = cfg.questName;
			vo.questUId = info.questUId
			vo.questId = info.questId;
			vo.questState = info.questState;

			table.push(uilist,UIData.encode(vo));
		end;
	end;

	objSwf.questlist.dataProvider:cleanUp();
	objSwf.questlist.dataProvider:push(unpack(uilist));
	objSwf.questlist:invalidateData();

end;

function UIInterSSRight:UpdataBossList()
	local objSwf = self.objSwf;
	if not objSwf then return end;

	local list = InterSerSceneModel:GetBossMonsterInfo()
	local uilist = {};
	-- trace(list)
	-- print("-------boss状态")
	for i,info in pairs(list) do 
		local vo = {};
		local mcfg = t_monster[info.monsterId]
		if mcfg then 
			if info.state == 2 then 
				local str = "";
				local t,s,f = CTimeFormat:sec2format(info.upTime)
				local time = string.format("%02d:%02d",s,f)
				str = str .. "<font color='#ff0000'><u>" .. mcfg.name .. "</u></font>  " .. time .. StrConfig["interServiceDungeon414"] ;
				vo.Name = str;
				vo.monsterId = info.monsterId
			else
				vo.Name = "<font color='#00ff00'><u>" .. mcfg.name .. "</u></font>";
				vo.monsterId = info.monsterId
			end;
			table.push(uilist,UIData.encode(vo));
		else
			print(info.monsterId,debug.traceback());
		end;
	end;

	objSwf.bossList.dataProvider:cleanUp();
	objSwf.bossList.dataProvider:push(unpack(uilist));
	objSwf.bossList:invalidateData();

end

function UIInterSSRight:IsShowMap()
	if not UIInterSSceneMap:IsShow() then 
		UIInterSSceneMap:Show();
	else
		UIInterSSceneMap:Hide();
	end;
end;

-- notifaction
function UIInterSSRight:ListNotificationInterests()
	return {
		NotifyConsts.InterSerSceneTeamUpdata,
		}
end;

function UIInterSSRight:HandleNotification(name,body)
	if not self.bShowState then return; end  -- 关闭等于False
	if name == NotifyConsts.InterSerSceneTeamUpdata then
		if UIInterSerSceneMainPage:IsShow() then 
			UIInterSerSceneMainPage:OnShow();
		else
			UIInterSerSceneMainPage:Show()
		end;
	end;
end;

function UIInterSSRight:GetWidth()
	return 280
end;