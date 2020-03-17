--[[
	 任务详细信息
	 wangshuai
]]

_G.UIHomesAQuestVo = BaseUI:new("UIHomesAQuestVo");

UIHomesAQuestVo.curGuid = 0;
UIHomesAQuestVo.curBossNum = 3;
UIHomesAQuestVo.curPupil = {};

function UIHomesAQuestVo:Create()
	self:AddSWF("homesteadAQuestVoPanel.swf",true,nil)
end;

function UIHomesAQuestVo:OnLoaded(objSwf)
	 objSwf.getQuest_btn.click = function() self:OnGetQuset()end;
	 objSwf.list.itemClick = function(e) self:ItemClick(e)end;
	 objSwf.list.itemSkillRollOver = function(e) self:ItemSkillOver(e)end;
	 objSwf.list.itemSkillRollOut = function()  UIHomesSkillTips:Hide(); end;

	 objSwf.closebtn.click = function() self:BackParent()end;
	 RewardManager:RegisterListTips(objSwf.rewardlist);
	 for i=1,1 do 
	 	local monsteritem = objSwf["bossitem"..i]
	 	monsteritem.listSkill.itemRollOver = function(e)self:OnSkillOver(e)end;
	 	monsteritem.listSkill.itemRollOut  = function() UIHomesSkillTips:Hide();end;
	 	monsteritem._visible = false;
	 	monsteritem.iconTips.rollOver = function() self:OnIconTips()end;
	 	monsteritem.iconTips.rollOut  = function() TipsManager:Hide() end;
	 end;

	 for i=1,3 do 
	 	local pupilitem = objSwf["pupilitemup"..i];
	 	pupilitem._visible = false;
	 	pupilitem.click = function()self:OnPupilItem(pupilitem)end;
	 end;
end;

function UIHomesAQuestVo:OnShow()
	self:ShowMyPupilList();
	self:ShowRightPanel();
	self:ShowBosslist();
	self:ShowPupilList();
end;

function UIHomesAQuestVo:OnHide()
	UIHomesAQuestVo.curGuid = 0;
	UIHomesAQuestVo.curBossNum = 3;
	UIHomesAQuestVo.curPupil = {};
	UIHomesteadMainView:ShowMainQuestView()
	UIHomesMainQuest:OnTabButtonClick("list")
end;

function UIHomesAQuestVo:OnIconTips()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	local questVo = HomesteadModel:getAQuestInfo(self.curGuid)
	if not questVo then return end;
	local monsterlist = questVo.monsterVo;
	local info = monsterlist[1]
	local cfg = t_homequestmon[info.id]
	local skillVo = split(cfg.skill,",")
	local uilist = {};
	local skiName = ""
	for i,info in ipairs(skillVo) do 
		local skVo = t_homepupilskill[toint(info)];
		if skVo then 
			skiName = skiName .. skVo.skillName .. "、";
		end;
	end;
	local str = string.format(StrConfig["homestead064"],cfg.name,skiName)
	TipsManager:ShowBtnTips(str,TipsConsts.Dir_RightDown);
end;

function UIHomesAQuestVo:BackParent()
	self:Hide();
end;

function UIHomesAQuestVo:ItemClick(e)
	local uid = e.item.uid
	local lenght = 0;
	for i,info in pairs(self.curPupil) do 
		if info.guid then 
			lenght = lenght + 1;
		end
	end;
	if self.curBossNum <= lenght then 
		FloatManager:AddNormal( StrConfig['homestead007']); 
		return 
	end;
	if self.curPupil[uid] and self.curPupil[uid].guid == uid then 
		FloatManager:AddNormal( StrConfig['homestead054']); 
		return 
	end;
	local dataVo = HomesteadModel:GetApupilList(uid);
	if dataVo.queststeat ~= 1 then 
		FloatManager:AddNormal( StrConfig['homestead059']); 
		return 
	end;
	self.curPupil[uid] = dataVo
	self:ShowPupilList();
	self:ShowMyPupilList();
	self:ShowBosslist();
end;

function UIHomesAQuestVo:ItemSkillOver(e)
	UIHomesSkillTips:SetSkillId(e.item.skillId);
end;

function UIHomesAQuestVo:OnSkillOver(e)
	UIHomesSkillTips:SetSkillId(toint(e.item.skillId));
end;

function UIHomesAQuestVo:OnPupilItem(target)
	local index = target.uid;
	if self.curPupil[index] then 
		self.curPupil[index] = nil;
		self:ShowPupilList();
		self:ShowMyPupilList();
		self:ShowBosslist();
	end;
end;

function UIHomesAQuestVo:OnGetQuset()
	local questId = self.curGuid
	local puililist = {};
	for i,info in pairs(self.curPupil) do 
		table.push(puililist,info.guid)
	end;
	if #puililist == 0 then 
		FloatManager:AddNormal(StrConfig["homestead053"])
		return 
	end;
	HomesteadController:GetQuest(questId,puililist[1],puililist[2],puililist[3])
	UIHomesMainQuest:OnTabButtonClick("list")
end;

function UIHomesAQuestVo:SetUIdata(guid)
	self.curGuid = guid;
end;

function UIHomesAQuestVo:ShowRightPanel()
	local objSwf = self.objSwf;
	local questVo = HomesteadModel:getAQuestInfo(self.curGuid)
	local questCfg = t_homequestrange[questVo.tid]
	if not questCfg then 
		return 
	end;
	objSwf.lvl_txt.htmlText = questVo.questlvl
	objSwf.name_txt.htmlText = HomesteadUtil:GetQualityColor(questVo.quality,questCfg.QuestName);

	local r,t,s,f = CTimeFormat:sec2formatEx(questVo.time)
	if r >= 1 then 
		t = r * 24 + t
	end;
	objSwf.time_txt.htmlText = string.format("%02d:%02d:%02d",t,s,f)
	objSwf.desc_txt.htmlText = questCfg.QuestTxt;
	local val = HomesteadUtil:GetQuestBaseRate(questVo,self.curPupil)
	objSwf.rateNum_txt.htmlText = string.format("%.2f",val).."%";

	local rewardList = {};
	local reward1 = RewardSlotVO:new()
	reward1.id = questVo.rewardType;
	reward1.count = questVo.rewardNum;

	local reward2 = RewardSlotVO:new();
	reward2.id = 64;
	reward2.count = questVo.pupilExp;

	table.push(rewardList,reward1:GetUIData())
	table.push(rewardList,reward2:GetUIData())

	if questVo.itemid and questVo.itemid ~= 0 then 
		local reward3 = RewardSlotVO:new();
		reward3.id = questVo.itemid;
		table.push(rewardList,reward3:GetUIData())
	else
	end;

	objSwf.rewardlist.dataProvider:cleanUp();
	objSwf.rewardlist.dataProvider:push(unpack(rewardList));
	objSwf.rewardlist:invalidateData();
end;

function UIHomesAQuestVo:ShowBosslist()
	local objSwf = self.objSwf;
	local questVo = HomesteadModel:getAQuestInfo(self.curGuid)
	local monsterlist = questVo.monsterVo;
	local questRange = t_homequestrange[questVo.tid]
	if not questRange then return end;
	local questfit = t_homequestfit[questRange.needAttr];
	if not questfit then 
		questfit = {};
		questfit.professionName = ""
	end;
	for i=1,1 do 
		local info = monsterlist[i]
		local item = objSwf["bossitem"..i];
		if not info then 
			item._visible = false;
			return
		end;

		local youjiImg = HomesteadUtil:GetSkillState(self.curPupil,info.id)
		trace(youjiImg)
		for y,j in ipairs(youjiImg) do 
			if item["youtu_"..y] then 
				item["youtu_"..y]._visible = j;
			end;
		end;

		local cfg = t_homequestmon[info.id]

		if cfg then 
			item.icon.source = ResUtil:GetHomeMonsterIcon(cfg.image)
			item.Name.htmlText = cfg.name;
			item.needZhiye_txt.htmlText = questfit.professionName
			local skuidata = HomesteadUtil:GetUiBossSkillData(info.id)
			item.listSkill.dataProvider:cleanUp();
			item.listSkill.dataProvider:push(unpack(skuidata));
			item.listSkill:invalidateData();
			item._visible = true;
			--objSwf["kuang"..i.."_mc"]._visible = true;
		else
			item._visible = false;
			--objSwf["kuang"..i.."_mc"]._visible = false;
		end;
	end;
end;

function UIHomesAQuestVo:ShowPupilList()
	local objSwf = self.objSwf;
	local index =0;
	for i=1,3 do
		objSwf["pupilitemup"..i]._visible = false;
	end;
	for i,info in pairs(self.curPupil) do 
		index = index + 1;
		local item = objSwf["pupilitemup"..index];
		if info.guid and item then 
			item.uid = info.guid;
			item.icon.source = ResUtil:GetHomePupilIcon(info.iconId)
			item.quality_mc:gotoAndStop(info.atb);
			item.Name.htmlText =  HomesteadUtil:GetQualityColor(info.quality,info.roleName);
			item.lvl.htmlText = string.format(StrConfig["homestead008"],info.lvl);
			item._visible = true;
		else
			item._visible = false;
		end;
	end;
	self:RateNumUpdata();
end;

function UIHomesAQuestVo:RateNumUpdata()
	local puplist = self.curPupil;
	local questVo = HomesteadModel:getAQuestInfo(self.curGuid)
	local read = HomesteadUtil:GetQuestBaseRate(questVo,self.curPupil)
	local objSwf = self.objSwf;
	objSwf.rateNum_txt.htmlText = string.format("%.2f",read).."%";
end;

function UIHomesAQuestVo:ShowMyPupilList()
	local datalist = HomesteadUtil:GetMyPupilData(true,self.curGuid,self.curPupil)--HomesteadUtil:GetXunXianListData(true)
	local objSwf = self.objSwf;
	objSwf.list.dataProvider:cleanUp();
	objSwf.list.dataProvider:push(unpack(datalist));
	objSwf.list:invalidateData();
end;


-- -- 居中
-- function UIHomesAQuestVo:AutoSetPos()
-- 	if self.parent == nil then return; end
-- 	if not self.isLoaded then return; end
-- 	if not self.swfCfg then return; end
-- 	if not self.swfCfg.objSwf then return; end
-- 	local objSwf = self.swfCfg.objSwf;

-- 	local Vx = toint(HomesteadConsts.MainViewWH.width / 2) - self:GetWidth()/2
-- 	local Vy = toint(HomesteadConsts.MainViewWH.height / 2) - self:GetHeight()/2
-- 	objSwf.content._x = Vx--toint(x or objSwf.content._x,  -1); 
-- 	objSwf.content._y = Vy--toint(y or objSwf.content._y, -1);
-- end;

function UIHomesAQuestVo:GetHeight()
	return 600
end;

-----------------------以下是引导-----------------
function UIHomesAQuestVo:GetFirstPupil()
	if not self:IsShow() then return; end
	local uvo = HomesteadModel:GetPupilList();
	if not uvo[1] then return nil; end
	return self.objSwf.pupilitem1;
end

function UIHomesAQuestVo:ClickFirstPupil()
	if not self:IsShow() then return; end
	local uvo = HomesteadModel:GetPupilList();
	self.curPupil[uvo[1].guid] = HomesteadModel:GetApupilList(uvo[1].guid);
	self:ShowPupilList();
end

function UIHomesAQuestVo:GetGetQuestBtn()
	if not self:IsShow() then return nil; end
	return self.objSwf.getQuest_btn;
end