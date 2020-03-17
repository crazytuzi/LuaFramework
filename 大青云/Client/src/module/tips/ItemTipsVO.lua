--[[
物品tipsVO
lizhuangzhuang
2014年8月19日10:04:29
]]

_G.ItemTipsVO = {};

ItemTipsVO.tipsType = TipsConsts.Type_Item;--Tips类型
ItemTipsVO.tipsShowType = TipsConsts.ShowType_Normal;--Tips显示类型
ItemTipsVO.compareTipsVO = nil;--对比显示时对方的VO
ItemTipsVO.isInBag = false;--物品是否在玩家背包内
ItemTipsVO.id = 0;--物品id
ItemTipsVO.count = 1;--数量
ItemTipsVO.cfg = nil;--配置表  ---可能是多条
ItemTipsVO.iconUrl = "";--icon
ItemTipsVO.levelAccord = true;--等级是否足够
ItemTipsVO.needLevel = 0;--使用需要等级
ItemTipsVO.param1 = 0 --道具参数
ItemTipsVO.param2 = 0 --道具参数
ItemTipsVO.param4 = 0 --道具参数
ItemTipsVO.needAttrOne = 0;-- 第一条属性
ItemTipsVO.needAttr = 0; --第二条属性
ItemTipsVO.profAccord = true;--职业是否符合
ItemTipsVO.prof = 0;--职业
ItemTipsVO.equiped = false;--是否已装备
ItemTipsVO.bindState = 0;  --绑定状态
ItemTipsVO.vipLvl = 0; --是否有vip等级，有取这个，没有取人物自己的

ItemTipsVO.strenLvl = 0;--强化等级
ItemTipsVO.refinLvl = 0;--炼化等级
ItemTipsVO.baseAttrList = nil;--装备基础属性值
ItemTipsVO.strenAttrList = nil;--装备强化属性值
ItemTipsVO.refinAttrList = nil;--炼化基础属性值

ItemTipsVO.extraLvl = 0;--追加属性等级
ItemTipsVO.extraBaseAttrList = nil;--追加增加的基础属性
ItemTipsVO.extraStrenAtrrList = nil;--追加增加的强化属性
ItemTipsVO.extraRefinAttrList = nil;--追加增加的炼化属性

ItemTipsVO.superVO = nil;--卓越列表
ItemTipsVO.superAttrList = nil;--卓越增加的属性
ItemTipsVO.superDefStr = nil;--不是自己的装备时,显示随机获得的数量
ItemTipsVO.superDetailStr = nil;--装备打造用

ItemTipsVO.newSuperList = nil;--新卓越列表
ItemTipsVO.newSuperAttrList = nil;--新卓越增加的属性
ItemTipsVO.newSuperDefStr = nil;--不是自己的装备时,显示随机获得的数量
ItemTipsVO.newSuperDetailStr = nil;--装备打造用

ItemTipsVO.gemList = nil;--装备宝石列表(只有id,等级)
ItemTipsVO.gemAttrList = nil;--装备宝石属性

ItemTipsVO.groupId = 0;--套装id
ItemTipsVO.groupEList = nil;--玩家身上的装备列表list:VO{id:装备id,groupId:套装id}(更改这个字段,实现查看别人套装时的效果)
ItemTipsVO.groupId2 = 0;--套装id2；
ItemTipsVO.groupId2Level = 0;--套装id2等级；

ItemTipsVO.itemSuperVO = nil;--道具的卓越属性 VO:{id,val1,val2}

ItemTipsVO.reuseNum = 0;--特殊道具时,使用次数
ItemTipsVO.reuseDayNum = 0;--特殊道具时,每日使用次数

ItemTipsVO.wingTime = nil;--翅膀到期时间,-1永久
ItemTipsVO.wingAttrFlag = false;--翅膀是否有特殊属性

ItemTipsVO.isUnionContr = false;  -- 是否显示当前装备价值贡献值！

ItemTipsVO.ringLvl = 0;--戒指等级；
ItemTipsVO.ringType = 0;--戒指类型；
ItemTipsVO.ringStren = 0;--戒指强化等级；

ItemTipsVO.shenWuLevel = 0
ItemTipsVO.shenWuStar = 0
ItemTipsVO.shenWuSkills = {}

ItemTipsVO.newGroupInfo = nil --临时添加套装效果

function ItemTipsVO:new()
	local obj = {};
	for k,v in pairs(ItemTipsVO) do
		obj[k] = v;
	end
	return obj;
end

--获取装备基础属性
function ItemTipsVO:GetEquipBaseAttr()
	if self.baseAttrList then
		return self.baseAttrList;
	end
	self.baseAttrList = EquipUtil:GetEquipBaseAttr(self.id);
	return self.baseAttrList;
end

--获取装备的强化属性
function ItemTipsVO:GetEquipStrenAttr()
	if self.strenLvl <= 0 then return {}; end
	if self.strenAttrList then
		return self.strenAttrList;
	end
	self.strenAttrList = EquipUtil:GetEquipStrenAttr(self:GetEquipBaseAttr(),self.strenLvl);
	return self.strenAttrList;
end

--获取洗练属性
function ItemTipsVO:GetEquipWashAttr()
	if not self.washList then return {} end
	if self.washAttrList then
		return self.washAttrList
	end
	self.washAttrList = {}
	for k, v in pairs(self.washList) do
		local vo = {}
		local cfg = t_extraatt[v.id]
		vo.type = AttrParseUtil.AttMap[cfg.type]
		vo.name = cfg.type
		vo.lv = cfg.lv
		if attrIsPercent(vo.type) then
			vo.val = cfg.att/10000;
		else
			vo.val = cfg.att;
		end
		table.push(self.washAttrList, vo)
	end
	return self.washAttrList
end

--获取戒指属性（由于这里判断过了 所以所有的装备都可以走这里）
function ItemTipsVO:GetEquipRingAttr()
	if 1 then return {} end
	if not self.ring then return {} end
	if self.ringAttrList then
		return self.ringAttrList, self.ringSkillList
	end
	local cfg = t_ring[self.ring]
	if not cfg then 
		self.ring = nil
		return {}, {}
	end
	self.ringAttrList, self.ringSkillList = {}, {}

	self.ringAttrList = AttrParseUtil:Parse(cfg.attr)

	local skill = split(cfg.skill, ",")
	for k, v in ipairs(skill) do
		table.push(self.ringSkillList, toint(v))
	end
	return self.ringAttrList,self.ringSkillList
end

--获取圣器属性
function ItemTipsVO:GetRelicAttr()
	local cfg
	if self.param1 and self.param1 > 0 then
		cfg = t_newequip[self.param1]
	else
		cfg = t_newequip[BagUtil:GetRelicId(self.id)]
	end
	if not cfg then
		return {}
	end
	return AttrParseUtil:Parse(cfg.att)
end

function ItemTipsVO:GetRingSkillFight()
	if not self.ringSkillList then
		return 0
	end
	local value = 0
	for k, v in pairs(self.ringSkillList) do
		local cfg = t_passiveskill[v]
		if cfg then
			value = value + (cfg.power_point or 0)
		end
	end
	return value
end

--获取装备的炼化属性
function ItemTipsVO:GetEquipRefinAttr()
	if self.refinLvl <= 0 then return {}; end
	if self.refinAttrList then
		return self.refinAttrList;
	end
	local refinId = self.cfg.pos*10000+self.refinLvl;
	self.refinAttrList = EquipUtil:GetEquipRefinAttr(self:GetEquipBaseAttr(),refinId);
	return self.refinAttrList;
end

--获取追加增加的基础属性
function ItemTipsVO:GetExtraBaseAttr()
	if self.extraLvl <= 0 then return {}; end
	if self.extraBaseAttrList then
		return self.extraBaseAttrList;
	end
	local baseAttrList = self:GetEquipBaseAttr();
	self.extraBaseAttrList = {};
	local cfg = t_equipExtra[self.cfg.level*10+self.cfg.quality];
	if not cfg then
		return self.extraBaseAttrList;
	end
	for i,vo in ipairs(baseAttrList) do
		local v = {};
		v.type = vo.type;
		v.val = toint(vo.val*cfg["lvl"..self.extraLvl]/100,0.5);
		table.push(self.extraBaseAttrList,v);
	end
	return self.extraBaseAttrList;
end

--获取追加增加的强化属性
function ItemTipsVO:GetExtraStrenAttr()
	if self.extraLvl <= 0 then return {}; end
	if self.strenLvl <= 0 then return {}; end
	if self.extraStrenAtrrList then
		return self.extraStrenAtrrList;
	end
	self.extraStrenAtrrList = EquipUtil:GetEquipStrenAttr(self:GetExtraBaseAttr(),self.strenLvl,false);
	return self.extraStrenAtrrList;
end

--获取追加增加的炼化属性
function ItemTipsVO:GetExtraRefinAttr()
	if self.extraLvl <= 0 then return {}; end
	if self.refinLvl <= 0 then return {}; end
	if self.extraRefinAttrList then
		return self.extraRefinAttrList;
	end
	local refinId = self.cfg.pos*10000+self.refinLvl;
	self.extraRefinAttrList = EquipUtil:GetEquipRefinAttr(self:GetExtraBaseAttr(),refinId,false);
	return self.extraRefinAttrList;
end

--获取卓越增加的属性
function ItemTipsVO:GetSuperAttr()
	if not self.superVO then
		return {};
	end
	if self.superAttrList then
		return self.superAttrList;
	end
	self.superAttrList = {};
	for i=1,self.superVO.superNum do
		local vo = self.superVO.superList[i];
		if vo.id > 0 then
			local cfg = t_fujiashuxing[vo.id];
			local v = {};
			v.type = AttrParseUtil.AttMap[cfg.attrType];
			if attrIsPercent(v.type) then
				v.val = vo.val1/10000;
			else
				v.val = vo.val1;
			end
			table.push(self.superAttrList,v);
		end
	end
	return self.superAttrList;
end

--获取装备的宝石
function ItemTipsVO:GetEquipGem()
	return self.gemList;
end

--获取装备的宝石属性
function ItemTipsVO:GetEquipGemAttr()
	if self.gemAttrList then
		return self.gemAttrList;
	end
	self.gemAttrList = {};
	if not self.gemList then return self.gemAttrList; end
	local vipAdd = 0;
	if self.vipLvl and self.vipLvl > 0 then 
		vipAdd = VipController:GetBaoshishuxingUp(self.vipLvl) / 100;
	else
		vipAdd = VipController:GetBaoshishuxingUp() / 100;
	end;
	for i,gemVO in ipairs(self.gemList) do
		local gemCfg = t_gemgroup[gemVO.id];
		if gemVO.used and gemCfg then
			local vo = {};
			vo.type = AttrParseUtil.AttMap[gemCfg.atr];
			vo.val = gemCfg.atr1;
			vo.lvl = gemVO.level;
			vo.val = toint(vo.val+vo.val*vipAdd,-1);
			self.gemAttrList[i] = vo
		end
	end
	return self.gemAttrList;
end

--获取新卓越增加的属性
function ItemTipsVO:GetNewSuperAttr()
	if not self.newSuperList then 
		return {};
	end
	if self.newSuperAttrList then
		return self.newSuperAttrList;
	end
	self.newSuperAttrList = {};
	for i=1,#self.newSuperList do
		local vo = self.newSuperList[i];
		if vo.id > 0 then
			local cfg = t_zhuoyueshuxing[vo.id];
			local v = {};
			v.type = AttrParseUtil.AttMap[cfg.attrType];
			if attrIsPercent(v.type) then   --- checkout attr is percent or number; changer:hoxuduong date:2016/5/10 15:05
				v.val = tonumber(vo.wash)/10000;    ---cfg.val/10000;
			else
				v.val = vo.wash --vo.wash;
			end
			table.push(self.newSuperAttrList,v);
		end
	end
	return self.newSuperAttrList;
end

--累加所有属性,计算装备的原始属性
function ItemTipsVO:GetOriginAttrList()
	local baseAttrList = self:GetEquipBaseAttr();
	local strenAttrList = self:GetEquipStrenAttr();
	local refinAttrList = self:GetEquipRefinAttr();
	local extraAttrList = self:GetExtraBaseAttr();
	local washList = self:GetEquipWashAttr()
	local extraStrenAtrrList = self:GetExtraStrenAttr();
	local extraRefinAttrList = self:GetExtraRefinAttr();
	local superAttrList = self:GetSuperAttr();
	local newSuperAttrList = self:GetNewSuperAttr();
	return EquipUtil:AddUpAttr(baseAttrList,strenAttrList,refinAttrList,extraAttrList,
								extraStrenAtrrList,extraRefinAttrList,superAttrList,newSuperAttrList,washList);
end

--获取装备的属性对比
function ItemTipsVO:GetCompareAttrList()
	if not self.compareTipsVO then
		return {};
	end
	local attrList = self:GetOriginAttrList();
	local compareAttrList = self.compareTipsVO:GetOriginAttrList();
	return EquipUtil:CompareAttr(attrList,compareAttrList);
end

--获取战斗力基础评分
function ItemTipsVO:GetFight()
	-- local fight = EquipUtil:GetEquipFight(self.id,self.groupId,self.groupId2,self.groupId2Level,self.refinLvl,self.strenLvl,self.extraLvl,
	-- 										self.superVO,self.newSuperList);
	-- local shenwuFight = ShenWuUtils:GetFight(self.equiped, self.cfg.pos, self.shenWuLevel, self.shenWuStar)
	-- return fight + shenwuFight;
	-- 这里现在只处理基础 升星 卓越 宝石
	return EquipUtil:GetEquipFightValue(self.id, self:GetEquipBaseAttr(), self:GetNewSuperAttr())
end

--总评分
function ItemTipsVO:GetTotalFight()
	local ringSkillValue = self:GetRingSkillFight()
	return ringSkillValue + EquipUtil:GetEquipFightValue(self.id,self:GetEquipBaseAttr(),self:GetEquipStrenAttr(),self:GetNewSuperAttr(),self:GetEquipGemAttr(),self:GetEquipWashAttr(), self:GetEquipRingAttr(), self:GetRelicAttr())
end