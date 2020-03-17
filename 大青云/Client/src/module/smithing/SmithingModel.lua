_G.SmithingModel = Module:new();
SmithingModel.equips = {};
SmithingModel.groups = {};
SmithingModel.maxlevels = {};
SmithingModel.equipGroup = {};  --装备套装数据信息

SmithingModel.RingInfo = {} --戒指数据

SmithingModel.EquipCollectInfo = {} --玩家收集装备数据

function SmithingModel:AddGem(msg)
	local equip = self:GetEquipByPos(msg.pos);
	if not equip then
		return;
	end
	
	local gem = equip.gems[msg.slot];
	gem.id = msg.tid;
	gem.host = equip;
	gem.used = true;
	local config = t_gemgroup[gem.id];
	gem.pos = config.slot;
	gem.name = config.name;
	gem.level = config.level;
	gem.view.id = gem.id;
	gem.view.pos = gem.pos;
	gem.view.iconUrl = ResUtil:GetEquipGemIconUrl(config.icon,config.level,'54');
	return gem;
end

function SmithingModel:GetEquipByPos(pos)
	local equip = self.equips[pos];
	if not equip then
		equip = self:CreateEquip(pos);
		self.equips[pos] = equip;
	end
	return equip;
end

function SmithingModel:GetInEquipGem(pos,hole)
	local equip = self:GetEquipByPos(pos);
	if not equip then
		return;
	end
	local gem = equip.gems[hole];
	return gem;
end 

function SmithingModel:InGemToEquip(msg)
	
end

function SmithingModel:RemoveGemInEquip(pos,hole)
	local gem = self:GetInEquipGem(pos,hole);
	if not gem then
		return;
	end
	self:ResetGem(gem);
	return pos;
end

function SmithingModel:ResetGem(gem)
	if not gem then
		return;
	end
	
	gem.host = nil;
	gem.id = nil;
	gem.used = false;
	gem.name = nil;
	gem.view.pos = gem.pos;
	gem.view.id = gem.id;
	gem.view.iconUrl = nil;
end

function SmithingModel:CreateEquip(pos)
	local config = t_equipgem[pos];
	if not config then
		return;
	end
	local vo  = {};
	vo.view = {};
	vo.config = config;
	vo.pos = config.pos;
	vo.id = 0;
	vo.view.id = vo.id;
	vo.view.pos = vo.pos;
	vo.view.iconUrl = ResUtil:GetSmithingIcon(config.icon);
	vo.gems = {};
	for i = 1,5 do
		local gem = {lvLimit=config['lv'..i],host=nil,pos=i,used=false,level=0};
		gem.view = {pos=gem.pos,id=0};
		table.push(vo.gems,gem);
	end
	
	return vo;
end

function SmithingModel:GetEquipCount()
	return #t_equipgem;
end

function SmithingModel:GetGemGroup(pos)
	local group = self.groups[pos];
	if group then
		return group;
	end
	
	group = {};
	for i,config in pairs(t_gemgroup) do
		if config.pos == pos then
			local holes = self.maxlevels[pos];
			if not holes then
				holes = {};
				self.maxlevels[pos] = holes;
			end
			local hole = holes[config.slot];
			if not hole then
				hole = config.level;
				holes[config.slot] = hole;
			end
			if hole<config.level then
				hole = config.level;
				holes[config.slot] = hole;
			end
			table.push(group,config);
		end
	end
	self.groups[pos] = group;
	return group
end

function SmithingModel:GetGemMaxLevel(pos,hole)
	local holes = self.maxlevels[pos];
	if not holes then
		self:GetGemGroup(pos);
	end
	holes = self.maxlevels[pos];
	return holes[hole];
end

function SmithingModel:IsEmptyEquip(pos)
	local result = true;
	local equip = self.equips[pos];
	if not equip then
		return result;
	end
	
	for i=1,#equip.gems do
		if equip.gems[i].used then
			result = false;
			return result;
		end
	end
	
	return result;
end

function SmithingModel:IsEmptyGem(pos,hole)
	local result = true;
	local gem = SmithingModel:GetInEquipGem(pos,hole);
	if not gem then
		return result;
	end
	result = gem.used == false;
	return result; 
end

local allValues = function(i)
	local nValue = 1
	for i = 1, i - 1 do
		nValue = nValue * 3
	end
	return nValue
end

function SmithingModel:isCanChangeMoreGood(pos, hole, level)
	local list = {};
	local bag = BagModel:GetBag(BagConsts.BagType_Bag);
	local items = bag:BagItemListBySub(BagConsts.SubT_EquipGem);
	if #items<1 then
		return false;
	end
	local group = self:GetGemGroup(pos);
	if not group then
		return false;
	end
	for i,config in ipairs(group) do
		if config.slot == hole then
			for j=1,#items do
				local item = items[j];
				if item:GetTid() == config.itemid and config.level > level then
					return true
				end
			end						
		end
	end
	return false
end

--- 获取固定位置指定等级以下的背包宝石兑换为一级宝石的数量
function SmithingModel:getAllLvInBag(pos, hole, level)
	local list = {};
	local bag = BagModel:GetBag(BagConsts.BagType_Bag);
	local items = bag:BagItemListBySub(BagConsts.SubT_EquipGem);
	if #items<1 then
		return 0;
	end
	local group = self:GetGemGroup(pos);
	if not group then
		return 0;
	end
	local nValue = 0
	for i,config in ipairs(group) do
		if config.slot == hole then
			for j=1,#items do
				local item = items[j];
				if item:GetTid() == config.itemid and config.level <= level then
					nValue = item:GetCount()* allValues(config.level) + nValue
				end
			end						
		end
	end
	return nValue
end

function SmithingModel:GemIsCanActive(pos, hole)
	local gem = self:GetInEquipGem(pos, hole)
	if gem.used then
		return false
	end
	if gem.lvLimit > MainPlayerModel.humanDetailInfo.eaLevel then
		return false
	end
	local group = self:GetGemGroup(pos);
	for k, config in pairs(group) do
		if config.slot == hole and config.level == 1 then
			if BagModel:GetItemNumInBag(config.itemfly) > 0 then
				return true
			end
			if BagModel:GetItemNumInBag(config.itemsume) >= config.itemnum then
				return true
			end
			return false
		end
	end
	return false
end

-- 获取消耗
function SmithingModel:GetGemCost(pos, hole, level)
	level = level or 1
	local group = self:GetGemGroup(pos)
	for k, config in pairs(group) do
		if config.slot == hole and config.level == level then
			return {config.itemfly, config.itemsume, config.itemnum, config.id}
		end
	end
	return nil
end

--获取属性
function SmithingModel:GetGemAtt(pos, hole, level)
	local group = self:GetGemGroup(pos)
	for k, config in pairs(group) do
		if config.slot == hole and config.level == level then
			return {type = config.atr, val = config.atr1}
		end
	end
	return nil
end

-- 获取激活图标
function  SmithingModel:GetGemIcon(pos, hole)
	local group = self:GetGemGroup(pos)
	for k, config in pairs(group) do
		if config.slot == hole and config.level == 1 then
			return ImgUtil:GetGrayImgUrl(ResUtil:GetEquipGemIconUrl(config.icon,config.level,'54'))
		end
	end
	return nil
end

function SmithingModel:GemIsCanLvUp(pos, hole)
	local gem = self:GetInEquipGem(pos, hole)
	local group = self:GetGemGroup(pos)
	if gem.lvLimit > MainPlayerModel.humanDetailInfo.eaLevel then
		return false
	end
	for k, config in pairs(group) do
		if config.slot == hole and config.level == gem.level + 1 then
			if BagModel:GetItemNumInBag(config.itemfly) > 0 then
				return true
			end
			if BagModel:GetItemNumInBag(config.itemsume) >= config.itemnum then
				return true
			end
			return false
		end
	end
	return false, true
end

function SmithingModel:GetGemProTypeByHole(pos, hole)
	local group = self:GetGemGroup(pos)
	if not group then
		return "att"
	end

	for i, config in pairs(group) do
		if config.slot == hole then
			return config.atr
		end
	end
end

function SmithingModel:CheckGemUpgrade(gem)
	if not gem or not gem.used then
		return;
	end
	
	local max = SmithingModel:GetGemMaxLevel(gem.host.pos,gem.pos);
	return gem.level<max;
end

function SmithingModel:IsGemHoleLocked(gem)
	local result = true;
	if not gem then
		return result;
	end
	
	local level = MainPlayerModel.humanDetailInfo.eaLevel;
	result = gem.lvLimit>level;

	return result;
end

function SmithingModel:GemIsCanUpLv(pos, hole)
	local gem = self.equips[pos].gems[hole]

	if not SmithingModel:CheckGemUpgrade(gem) then
		return
	end
	return 2 * allValues(gem.level) <= self:getAllLvInBag(pos, hole, gem.level)
end

function SmithingModel:GetNoticeStr(pos)
	local str = 0
	for j,gem in ipairs(self:GetEquipByPos(pos) and self:GetEquipByPos(pos).gems or {}) do
		if not self:IsGemHoleLocked(gem) and (not gem.used) then
			if SmithingModel:GemIsCanActive(pos, j) then
				return 1
			end
		elseif gem.used then
			if SmithingModel:GemIsCanLvUp(pos, j) then
				if str == 0 then
					str = 3
				end
			end
		end
	end
	return str
end

function SmithingModel:GetEquipedGems()
	local list = {};
	for i,equip in ipairs(self.equips) do
		for j,gem in ipairs(equip.gems) do
			if gem.used then
				table.push(list,gem);
			end
		end
	end
	return list;
end

function SmithingModel:GetAllEquipGemLv()
	local level = 0;
	for i,equip in pairs(self.equips) do
		for j,gem in ipairs(equip.gems) do
			if gem.used then
				level = level+gem.level;
			end
		end
	end
	return level;
end

function SmithingModel:GetEquipGemLv(pos)
	local level = 0;
	for j,gem in ipairs(self.equips[pos].gems) do
		if gem.used then
			level = level+gem.level;
		end
	end
	return level;
end

function SmithingModel:GetGemLinkId()
	local id = 0;
	local level = self:GetAllEquipGemLv();
	for l,k in ipairs(t_gemlock) do 
		if level >= k.lvl then
			id = k.id;
		else
			break
		end
	end
	return id;
end

function SmithingModel:GetMaxStarCount(equipid)
	local equip = t_equip[equipid];
	if not equip then
		return 0;
	end
	local star = t_strenxingji[equip.level * 1000 + equip.quality];
	if not star then
		return 0;
	end
	return star.maxstar;
end

function SmithingModel:GetMoonLevel(equipid)
	local equip = t_equip[equipid];
	if not equip then
		return 0;
	end
	local star = t_strenxingji[equip.level * 1000 + equip.quality];
	if not star then
		return 0;
	end
	return star.moon;
end

function SmithingModel:GetAddAttr(id,star)
	local result = {max=false};
	local equip = t_equip[id];
	if not equip then
		return result;
	end
	
	local list = AttrParseUtil:Parse(equip.baseAttr);
	local config = t_strenattr[star];
	for i,data in pairs(list) do
		result.value = 0
		if config then
			local attr = config[data.name];
			if attr then
				result.value = attr;
			end
			result.value = result.value + toint(data.val*config.addPercent/100,0.5)
		end
		result.attr = data.type
		result.name = PublicAttrConfig.proSpaceName[data.name]
	end
	result.fight = PublicUtil:GetFigthValue({{val = result.value, type = result.attr}}, equip.level)
	
	return result;
end

function SmithingModel:GetStarSuccessRate(target)
	local result = 100;
	local config = t_stren[target];
	if not config then
		return result;
	end
	result = config.extremeRate/100;
	return result;
end

function SmithingModel:GetEquipStrenInfo(item)
	if not item then
		return;
	end
	
	local id = item:GetId();
	local equip = EquipModel:GetEquipInfo(id);
	return equip
end


function SmithingModel:GetEquipAttrInfo(item)   ---Add: hoxudong 2016/5/6 9:59
	if not item then
		return;
	end
	local id = item:GetId();
	local equipAttr = EquipModel:GetNewSuperVO(id);
	return equipAttr;
end


-------------------------------------------------------------------装备套装-------------------------------------------------------------------------
function SmithingModel:InitEquipGroupInfo(data)
	for k, v in pairs(data) do
		if not self.equipGroup[v.pos] then
			self.equipGroup[v.pos] = {}
		end
		self.equipGroup[v.pos][v.index + 1] = v.lvl
	end
end

-- 开锁
function SmithingModel:EquipGroupActive(pos, index)
	if not self.equipGroup[pos] then
		self.equipGroup[pos] = {}
	end
	self.equipGroup[pos][index + 1] = -1
end

-- 激活
function SmithingModel:EquipGroupOpen(pos, index)
	if not self.equipGroup[pos] then
		self.equipGroup[pos] = {}
	end
	self.equipGroup[pos][index + 1] = 0
end

function SmithingModel:EquipGroupUpLv(pos, index, lv)
	if not self.equipGroup[pos] then
		self.equipGroup[pos] = {}
	end
	self.equipGroup[pos][index + 1] = lv
end

function SmithingModel:GetEquipGroupInfo(pos)
	return self.equipGroup[pos] or {}
end

-----------------------------------------------------------------------------左戒-------------------------------------------------------------------
function SmithingModel:RingDataUpdate(data)
	self.RingInfo.ringData = {}
	self.RingInfo.ringData[data.cid] = data.lv
end

function SmithingModel:RingTaskUpdate(data)
	self.RingInfo.monsterNum = data.number
end

function SmithingModel:GetRingTaskNum()
	return self.RingInfo.monsterNum
end

function SmithingModel:GetRingCid()
	for k, v in pairs(self.RingInfo.ringData or {}) do
		return k
	end
end

function SmithingModel:GetRingLv()
	for k, v in pairs(self.RingInfo.ringData or {}) do
		return v
	end
end



---- 好几个界面画模型 放在这里了
function SmithingModel:DrawScene(UIClass, loader)
	local swf = UIClass.objSwf;
	--debug.debug();
	loader._x = -230
	loader._y = -190
	-- if not UIClass.viewPort then UIClass.viewPort = _Vector2.new(1200, 700); end
	local prof = MainPlayerModel.humanDetailInfo.eaProf; 
	if prof == 4 then
		loader._y = -150
		if not self.viewPort then self.viewPort = _Vector2.new(1400, 795); end  --795
	else
		if not self.viewPort then self.viewPort = _Vector2.new(1300, 815); end  --795
	end
	if not UIClass.scene then
		UIClass.scene = UISceneDraw:new(UIClass, loader, self.viewPort, false);
	end
	UIClass.scene:SetUILoader(loader)
	
	local src = Assets:GetRolePanelSen(MainPlayerModel.humanDetailInfo.eaProf);
	UIClass.scene:SetScene(src, function()
		self:DrawRole(UIClass);
	end );
	UIClass.scene:SetDraw( true );
end

function SmithingModel:DrawRole(UIClass)
	if UIClass.objAvatar then
		UIClass.objAvatar:ExitMap();
		UIClass.objAvatar = nil;
	end
	
	local vo = {};
	local info = MainPlayerModel.sMeShowInfo;
	vo.prof = MainPlayerModel.humanDetailInfo.eaProf;
	vo.arms = info.dwArms;
	vo.dress = info.dwDress;
	vo.shoulder = info.dwShoulder;
	vo.fashionsHead = info.dwFashionsHead;
	vo.fashionsArms = info.dwFashionsArms;
	vo.fashionsDress = info.dwFashionsDress;
	vo.wuhunId = SpiritsModel:GetFushenWuhunId();
	-- vo.wing = info.dwWing;
	vo.suitflag = info.suitflag;
	vo.shenwuId = info.shenwuId;
	
	UIClass.objAvatar = CPlayerAvatar:new();
	UIClass.objAvatar.bIsAttack = false;
	UIClass.objAvatar:CreateByVO(vo);
	
	UIClass.meshDir = 0;
	UIClass.objAvatar.objMesh.transform:setRotation(0,0,1,UIClass.meshDir);
	--播放特效
	local sex = MainPlayerModel.humanDetailInfo.eaSex;
	
	local markers = UIClass.scene:GetMarkers();
	local indexc = "marker2";
	UIClass.objAvatar:EnterUIScene(UIClass.scene.objScene,markers[indexc].pos,markers[indexc].dir,markers[indexc].scale, enEntType.eEntType_Player);
	
end

function SmithingModel:ClearScene(UIClass)
	if UIClass.scene then 
		UIClass.scene:SetDraw(false)
		UIClass.scene:SetUILoader(nil)
		UIDrawManager:RemoveUIDraw(UIClass)
		UIClass.scene = nil
	end
	
	if UIClass.objAvatar then
		UIClass.objAvatar:ExitMap();
		UIClass.objAvatar = nil;
	end
end

-------------------------------------------------------------装备收集----------------------------------------------------------------
function SmithingModel:OnEquipCollectInfoInit(info)
	self.EquipCollectInfo[info.lv] = {}
	local collectInfo = self.EquipCollectInfo[info.lv]
	collectInfo.get = info.get
	collectInfo.pro1 = info.first_activite
	collectInfo.pro2 = info.second_activite
	collectInfo.pro3 = info.third_activite
	collectInfo.actlist = {}
	for k, v in pairs(info.actlist) do
		collectInfo.actlist[v.index] = v.state
	end
	
end

function SmithingModel:AddEquipCollectInfo(info)
	if not self.EquipCollectInfo[info.lv] then
		self.EquipCollectInfo[info.lv] = {}
	end
	if not self.EquipCollectInfo[info.lv].actlist then
		self.EquipCollectInfo[info.lv].actlist = {}
	end
	self.EquipCollectInfo[info.lv].actlist[info.index] = 1
end

function SmithingModel:GetCollectRewardResult(lv)
	self.EquipCollectInfo[lv].get = 1
end

function SmithingModel:EquipCollectActiveResult(lv, number)
	self.EquipCollectInfo[lv]["pro" ..number] = 1
end

function SmithingModel:GetEquipCollectInfo(lv)
	if not self.EquipCollectInfo[lv] then
		self.EquipCollectInfo[lv] = {}
		self.EquipCollectInfo[lv].get = 0
		self.EquipCollectInfo[lv].pro1 = 0
		self.EquipCollectInfo[lv].pro2 = 0
		self.EquipCollectInfo[lv].pro3 = 0
		self.EquipCollectInfo[lv].actlist = {}
	end
	return self.EquipCollectInfo[lv]
end


local t_equipCollect = {3, 6, 11}
function SmithingModel:IsEquipCollectCanActive(lv, number)
	local level = MainPlayerModel.humanDetailInfo.eaLevel
	if level < t_equipcollectionbasis[lv].openlv then
		return false
	end
	local info = self:GetEquipCollectInfo(lv)
	if info['pro' ..number] == 1 then
		return false
	end
	local value = 0
	for k, v in pairs(info.actlist) do
		if v == 1 then
			value = value + 1
		end
	end
	if value >= t_equipCollect[number] then
		return true
	end
end

function SmithingModel:IsEquipCollectCanGetReward(lv)
	if 1 then return false end  ---todo 这个奖励暂时屏蔽
	local info = self:GetEquipCollectInfo(lv)
	if info.get == 1 then
		return false
	end
	local value = 0
	for k, v in pairs(info.actlist) do
		if v == 1 then
			value = value + 1
		end
	end
	if value >= t_equipCollect[3] then
		return true
	end
end

--是否收集完当前套装
function SmithingModel:IsEquipCollectGetAll(lv)
	local info = self:GetEquipCollectInfo(lv)
	local value = 0
	for k, v in pairs(info.actlist) do
		if v == 1 then
			value = value + 1
		end
	end
	if value >= t_equipCollect[3] then
		return true
	end
	return false
end

function SmithingModel:IsEquipCollectCanOperate(lv)
	for i = 1, 3 do
		if self:IsEquipCollectCanActive(lv, i) then
			return true
		end
	end
	return self:IsEquipCollectCanGetReward(lv)
end

function SmithingModel:IsEquipCollectCanOperate1()
	for i = 1, #t_equipcollectionbasis do
		if SmithingModel:IsEquipCollectCanOperate(i) then
			return true
		end
	end
	return false
end

function SmithingModel:GetEquipCollectGroupNum()
	local num = 0
	for k, v in pairs(t_equipcollectionbasis) do
		if num < v.sequence and v.openlv <= MainPlayerModel.humanDetailInfo.eaLevel then
			num = v.sequence
		end
	end
	return num
end

function SmithingModel:GetCollectIcon(group)
	for k, v in pairs(t_equipcollectionbasis) do
		if v.sequence == group then
			return ResUtil:GetEquipCollectIcon(v.name)
		end
	end
end

function SmithingModel:GetCollectInfoByGroup(group)
	local list = {}
	for k, v in ipairs(t_equipcollectionbasis) do
		if group == v.sequence and v.openlv <= MainPlayerModel.humanDetailInfo.eaLevel then
			table.insert(list, v)
		end
	end
	return list
end