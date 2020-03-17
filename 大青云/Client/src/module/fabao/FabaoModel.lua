_G.FabaoModel = Module:new();

FabaoModel.list = {};
FabaoModel.selectid = 0;
FabaoModel.defaluts = nil;
FabaoModel.count = 0;

FabaoModel.PickFabao = 0;
FabaoModel.PickBook = 1;
FabaoModel.pillPage = nil;

function FabaoModel:SetpillPage(pillPage)
	self.pillPage = pillPage;
end

function FabaoModel:GetpillPage()
	return self.pillPage;
end

-- 获得宝石合成界面list
function FabaoModel:GetBoegeyPillList(openlist)
	local treeData = {};
	treeData.label = "root";
	treeData.open = true;
	treeData.isShowRoot = false;
	treeData.nodes = {};
	
	local isfirst = true;
	for i , v in ipairs(FabaoConsts.FabaoCfg) do
		local node = {};
		node.titlename = UIStrConfig['fabao55' .. i];
		node.ischild = false;
		node.nodes = {};
		node.open = false;
		
		if isfirst == true then
			node.open = true;
			isfirst = false;
		end
		for j, voj in ipairs(v) do
			local vochild = {};
			vochild.ischild = true;
			vochild.itemname = string.format(StrConfig['fabao18'],t_fabao[voj].name);  ---item标题名
			vochild.modelId = t_fabao[voj].model; 
			vochild.id = voj;
			vochild.btnSelected = false;
			table.push(node.nodes,vochild);
		end
		table.push(treeData.nodes, node);
	end
	return treeData;
end

function FabaoModel:AddFabao(msg)
	local fabao = self:GetFabaoById(msg.id);
	if not fabao then
		-- print('------------------------------ FabaoModel:AddFabao()--'..msg.tid)
		fabao = self:CreateFabao(msg.tid);
		self.list[msg.id] = fabao;
		self.count = self.count+1;
	end
	
	fabao.id = msg.id;
	fabao.level = msg.level;
	fabao.maxlv = t_fabaolv[msg.level];
	fabao.maxExp = t_fabaolv[msg.level].exp;
	fabao.state = msg.state;
	fabao.fighting = fabao.state == 1;
	fabao.view.state = fabao.fighting;
	fabao.changed = msg.changed;
	if msg.changed == 0 then
		fabao.rebornItem = self:CreateNeedItem(fabao.config.feed_reborn[1],fabao.config.feed_reborn[2]);
	else
		fabao.rebornItem = self:CreateNeedItem(fabao.config.feed_bianyi[1],fabao.config.feed_bianyi[2]);
	end
	fabao.exp = msg.exp;
	fabao.view.id = msg.id;
	fabao.attrList = {};
	-- fabao.fight = 0;
	for i=1,#msg.attrList do
		if msg.attrList[i].val>0 then
			table.push(fabao.attrList,msg.attrList[i].val);
		end
	end
	
	local list = {};
	local t = {"hp","att","def","hit","dodge"};
	for i = 1,#fabao.attrList do
		local vo = {};
		vo.name = t[i];
		vo.val = fabao.attrList[i]
		vo.type = AttrParseUtil.AttMap[t[i]];
		table.push(list,vo);
	end
	-- UILog:print_table(list)
	-- WriteLog(LogType.Normal,true,'---------------------FabaoModel:AddFabao(msg)',list)
	fabao.fight = PublicUtil:GetFigthValue(list);
	fabao.abilityList = {};
	for i=1,#msg.abilityList do
		if msg.abilityList[i].val>0 then
			table.push(fabao.abilityList,msg.abilityList[i].val);
		end
	end
	
	if #msg.skillList > 0 then
		fabao.skills = {};
	end
	
	for si,sv in ipairs(msg.skillList) do
		if sv.sid>0 then
			table.push(fabao.skills,self:CreateBuff(sv.sid));
		end
	end
	-- print('------------------------------------fabaomodel：'..#fabao.skills)
	for id,skill in pairs(fabao.skills) do
		if  tostring(skill.modelId)== tostring(t_fabao[fabao.modelId].skill) then
			skill.state = true;
		else
			skill.state = false;
		end
	end
end

function FabaoModel:ChangeState(id,state)
	local fabao = self:GetFabaoById(id);
	if not fabao then
		return;
	end
	fabao.state = state;
	fabao.fighting = fabao.state == 1;
	fabao.view.state = fabao.fighting;
	if fabao.fighting then
		SkillController:OnFabaoSkillChange(fabao.sskill.modelId);
		SkillController:OnFabaoNSkillChange(fabao.nskill.modelId);
	else
		SkillController:OnFabaoSkillChange(0);
		SkillController:OnFabaoNSkillChange(0);
	end
	return fabao;
end

function FabaoModel:RemoveFabao(id)
	local fabao = self:GetFabaoById(id);
	if fabao then
		self.list[id] = nil;
		self.count = self.count-1;
	end
	return fabao;
end

function FabaoModel:UpdateFabao(msg)
end

function FabaoModel:GetFabaoById(id)
	if not id then
		return;
	end
	
	return self.list[id];
end

function FabaoModel:GetFabao(id,modelId)
	local list = self.defaluts;
	if type(id)=='string'	then
		list = self.list;
	end
	if not list then
		return;
	end
	
	for k,vo in pairs(list) do
		if vo.id == id and vo.modelId == modelId then
			return vo;
		end
	end
	return;
end

function FabaoModel:CreateFabao(modelId)
	local vo = {};
	local view = {};
	local config = t_fabao[modelId];
	local attrCfg = t_fabaoshuxing[modelId];
	
	vo.modelId = modelId;
	vo.id = -1;
	vo.state = 0;
	vo.changed = false;
	vo.exp = 0;
	vo.level = 0;
	vo.name = config.name;
	vo.skillList = nil;
	vo.potential = attrCfg.power_up + attrCfg.body_up + attrCfg.agile_up;
	vo.ability = attrCfg.ability;
	vo.attrList = {};
	local value = (attrCfg.body*attrCfg.hp_ability[2]*(attrCfg.hp_number/1000))/10000;
	table.push(vo.attrList,value);
	value = (attrCfg.power*attrCfg.atk_ability[2]*(attrCfg.atk_number/1000))/10000;
	table.push(vo.attrList,value);
	value = (attrCfg.body*attrCfg.defend_ability[2]*(attrCfg.defend_number/1000))/10000;
	table.push(vo.attrList,value);
	value = (attrCfg.agile*attrCfg.hit_ability[2]*(attrCfg.hit_number/1000))/10000;
	table.push(vo.attrList,value);
	value = (attrCfg.agile*attrCfg.critical_ability[2]*(attrCfg.critical_number/1000))/10000;
	table.push(vo.attrList,value);
	
	
	
	vo.abilityList = {};
	value = (attrCfg.ability*attrCfg.hp_ability[1])/10000;
	table.push(vo.abilityList,value);
	value = (attrCfg.ability*attrCfg.atk_ability[1])/10000;
	table.push(vo.abilityList,value);
	value = (attrCfg.ability*attrCfg.defend_ability[1])/10000;
	table.push(vo.abilityList,value);
	value = (attrCfg.ability*attrCfg.hit_ability[1])/10000;
	table.push(vo.abilityList,value);
	value = (attrCfg.ability*attrCfg.critical_ability[1])/10000;
	table.push(vo.abilityList,value);
	vo.config = config;
	vo.nskill = self:CreateSkill(config.fight_skill[1]);
	vo.sskill = self:CreateSkill(config.fight_skill[2]);
	vo.skills = {};
	
	local groups = string.split(config.skill_group,',');
	for i = 1,#groups do
		local skills = self:GetGroupSkills(toint(groups[i]))
		if #skills > 0 then
			local skill = skills[1];
			table.push(vo.skills,self:CreateBuff(skill.id));
		end
	end
	
	local gskill = self:CreateBuff(toint(config.skill));
	if gskill then
		table.push(vo.skills,gskill);
		gskill.state = true;
	end
	
	
	vo.feedItem = self:CreateNeedItem(config.feed[1],config.feed[2]);
	vo.feedItem.hasItem = true;
	
	-- vo.iconUrl = ResUtil:GetShenLingIcon(config.name_icon);
	view.iconUrl = ResUtil:GetFabaoImg(modelId);
	view.feedUrl = ResUtil:GetFabaoLevelImg(modelId);
	view.hasItem = true;
	view.name = config.name;
	view.modelId = modelId;
	view.id = vo.id;
	vo.view = view;
	return vo;
end

FabaoModel.groupSkills = nil;
function FabaoModel:GetGroupSkills(groupId)
	if not self.groupSkills then
		self.groupSkills = {};
	end
	
	local skills = self.groupSkills[groupId];
	if not skills then
		skills = {};
		for id ,config in pairs(t_fabaojineng) do
			if config.skill_set == groupId then
				table.push(skills,config);
			end
		end
		self.groupSkills[groupId] = skills;
		table.sort(skills,function(A,B)
			if A.skill_rate < B.skill_rate then
				return true;
			else
				return false;
			end
		end);
	end
	
	return skills;
end

function FabaoModel:CreateSkill(id)
	local config = t_skill[id];
	if not config then
		return;
	end
	local skill = {};
	skill.iconUrl = ResUtil:GetSkillIconUrl(config.icon);
	skill.modelId = id;
	skill.name = config.name;
	skill.hasItem = true;
	skill.state = false;
	return skill;
end

function FabaoModel:CreateBuff(id)
	local config = t_passiveskill[id];
	if not config then
		return;
	end
	
	local buff = {}
	buff.iconUrl = ResUtil:GetSkillIconUrl(config.icon);
	buff.modelId = id;
	buff.name = config.name;
	buff.hasItem = true
	buff.state = false;
	
	return buff;
end

function FabaoModel:CreateNeedItem(id,count)
	local item = {};
	item.showCount = count;
	item._isSmall = false;
	local a = t_item[id].bind; 
	if a == 1 then item.showBind = false; else item.showBind = true; end
	item.iconUrl = ResUtil:GetItemIconUrl(t_item[id].icon);
	local icon_Url = ResUtil:GetSlotQuality(t_item[id].quality);
	item.qualityUrl = icon_Url;
	item.quality = t_item[id].quality;
	item.name = t_item[id].name;
	item.id = id;
	return item;
end

function FabaoModel:GetDefaults()
	if self.defaluts then
		return self.defaluts;
	end
	
	self.defaluts = {};
	for id,config in pairs(t_fabao) do
		-- print('------------------------------ FabaoModel:GetDefaults()--'..id)
		local vo = self:CreateFabao(id);
		table.push(self.defaluts,vo);
	end
	
	table.sort(self.defaluts,function(A,B)
		if A.modelId < B.modelId then
			return true;
		else
			return false;
		end
	end);
	
	return self.defaluts;
end

function FabaoModel:GetCount()
	return self.count;
end

function FabaoModel:GetDevourFabao(src,dst)
	if not src or not dst then
		return;
	end
	
	local result = {};
	local view = {};
	local config = t_fabao[src.modelId];
	
	result.modelId = src.modelId;
	result.id = src.id;
	result.name = src.name;
	result.state = 0;
	result.changed = src.changed;
	result.exp = src.exp;
	result.level = src.level;
	result.potential = src.potential;
	result.ability = src.ability;
	result.nskill = table.clone(src.nskill);
	result.sskill = table.clone(src.sskill);
	
	result.skills = {};
	local skills = src.skills;
	if #skills<#dst.skills then
		skills = dst.skills;
	end
	for i = 1,#skills do
		table.push(result.skills,table.clone(skills[i]));
	end
	
	result.abilityList = {};
	for i = 1,#src.abilityList do
		local value = nil;
		if src.abilityList[i]>dst.abilityList[i] then
			value = dst.abilityList[i]..'-'..src.abilityList[i];
		else
			value = src.abilityList[i]..'-'..dst.abilityList[i];
		end
		table.push(result.abilityList,value);
	end
	
	view.iconUrl = ResUtil:GetFabaoImg(src.modelId);
	view.feedUrl = ResUtil:GetFabaoLevelImg(src.modelId);
	view.hasItem = true;
	view.name = config.name;
	view.modelId = modelId;
	view.id = result.id;
	result.view = view;
	
	return result;
end

function FabaoModel:GetFighting()
	for id,fabao in pairs(self.list) do
		if fabao.state == 1 then
			return fabao;
		end
	end
	return
end

--- 从法宝列表随便取出一个法宝
function FabaoModel:GetRandomFabao()
	for k, v in pairs(self.list) do
		return v
	end
end
 

