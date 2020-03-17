--[[
	妖丹Util
	2015年5月5日, PM 02:24:16
	wangyanwei
]]
_G.RoleBoegeyPillUtil = {};

RoleBoegeyPillUtil.PillTipBoolean = false;
RoleBoegeyPillUtil.panelUISEN = "v_danyao.sen";

function RoleBoegeyPillUtil:OnCanFeedPill(itemId)
	local cfg = t_item[itemId];
	
	local playerinfo = MainPlayerModel.humanDetailInfo;
	if playerinfo.eaLevel < cfg.needlevel then
		return false;
	end
	
	--VIP判断
	if RoleBoegeyPillUtil:OnIsVIPPill(itemId) == true then
		if playerinfo.eaVIPLevel <= 0 then
			return false;
		end
	end
	
	local dayilNum = BagModel:GetDailyUseNum(itemId);
	if dayilNum >= BagModel:GetDailyTotalNum(itemId) and self.PillTipBoolean == false then
		return false;
	end
	return true;
end

--获取的物品是不是妖丹
function RoleBoegeyPillUtil:OnIsPill(itemId)
	if self:OnIsCommonPill(itemId) == true or self:OnIsVIPPill(itemId) == true then
		return true;
	end
	return false;
end

--获取的物品是不是普通妖丹
function RoleBoegeyPillUtil:OnIsCommonPill(itemId)
	if t_item[itemId] then
		for i , v in ipairs(RoleBoegeyConsts.BoegeyID) do
			if v == itemId then
				return true;
			end
		end
	end
	return false;
end

--获取的物品是不是VIP妖丹
function RoleBoegeyPillUtil:OnIsVIPPill(itemId)
	if t_item[itemId] then
		for i , v in ipairs(RoleBoegeyConsts.BoegeyVipID) do
			if v == itemId then
				return true;
			end
		end
	end
	return false;
end

--获取第几个标签 第几个妖丹
RoleBoegeyPillUtil.pillPage = nil;
RoleBoegeyPillUtil.pillIndex = nil;
function RoleBoegeyPillUtil:OnSetPillPage(itemId)
	local page = self:GetPage(itemId);
	local index = self:GetPillIndex(page,itemId);
	self.pillPage,self.pillIndex = page,index;
	
	RoleBoegeyPillModel:Seteffectitem(itemId);
end

--同时一键使用该妖丹
function RoleBoegeyPillUtil:UseAllSameItem(itemId)
	local list = self:GetBogyePillSameType(itemId);
	
	if not list then
		RoleBoegeyPillModel:Seteffectitem(0);
		return;
	end
	if #list <= 0 then
		RoleBoegeyPillModel:Seteffectitem(0);
		return;
	end
	
	BagController:UseAllItem(BagConsts.BagType_Bag,list);
end

function RoleBoegeyPillUtil:SetItemGuideInfo()
	local yaodancfg = t_yaodan[RoleBoegeyPillModel:Geteffectitem()];
	if yaodancfg then
		RoleBoegeyPillModel:SetpillPage(yaodancfg.order);
		RoleBoegeyPillModel:SetpillIndex(self.pillIndex);
		RoleBoegeyPillModel:SetIsShowEffect(true);
	end
end

function RoleBoegeyPillUtil:ClearItemGuideInfo()
	RoleBoegeyPillModel:SetpillPage(nil);
	RoleBoegeyPillModel:SetpillIndex(nil);
	RoleBoegeyPillModel:SetIsShowEffect(false);
	RoleBoegeyPillModel:Seteffectitem(0);
end

--得到指引的page 与 index
function RoleBoegeyPillUtil:GetPillPageOrIndex()
	local a = self.pillPage or 1;
	local b = self.pillIndex or 1;
	return {page = a,index = b}
end

--返回这个妖丹的类型RoleBoegeyPillModel.oldBogeypillData
function RoleBoegeyPillUtil:GetPage(itemId)
	RoleBoegeyPillModel:OnSetMyOldBoegeyDataHandler()
	for i , v in ipairs(RoleBoegeyPillModel.oldBogeypillData) do
		for j , k in ipairs(v) do
			if itemId == k.id then
				return i;
			end
		end
	end
end

--返回这个妖丹的Index
function RoleBoegeyPillUtil:GetPillIndex(page,itemId)
	local cfg = RoleBoegeyPillModel.oldBogeypillData[page];
	for i , v in ipairs(cfg) do
		if v.id == itemId then
			return i;
		end
	end
end

--一键使用一类妖丹
function RoleBoegeyPillUtil:GetBogyePillSameType(tid)
	local list = {};
	local itemvo = {};
	itemvo.item_tid = tid;
	
	local num = math.abs(BagModel:GetDailyTotalNum(tid) - BagModel:GetDailyUseNum(tid));
	if num > BagModel:GetItemNumInBag(tid) then
		itemvo.item_count = BagModel:GetItemNumInBag(tid)
	else
		itemvo.item_count = num;
	end
	table.push(list,itemvo);
	return list;
end
	
--获得妖丹
-- @param true  vip丹药
-- @param false 普通丹药
function RoleBoegeyPillUtil:GetBogeyPillList(isvip)
	local bagVO = BagModel:GetBag(BagConsts.BagType_Bag);
	if not bagVO then return; end;
	local bogeylist = {};    --当前背包里所有的丹药
	local itemlist = nil;    --显示分类时的Item列表
	itemlist = bagVO:GetItemListByShowType(BagConsts.ShowType_Consum);
	for i,vo in ipairs(itemlist) do   --遍历消耗列表
		if vo then
			local tid = vo:GetTid();
			if isvip == false then    --普通妖丹
				if self:OnIsCommonPill(tid) == true then
					if not bogeylist[tid] then
						bogeylist[tid] = vo:GetCount();
					else
						bogeylist[tid] = bogeylist[tid] + vo:GetCount();
					end
				end	
			end
		end
	end
	local list = {};
	local dayilyUseNum ;   --丹药每日使用的数量
	local dayilyCanUseNum; --每日可以使用的丹药总数量
	local usenum ;         --当前已经使用(这一生使用)的妖丹总数量
	local lifeMaxNum;      --一生所需要的最大妖丹数量,更具转生状态来修改
	local defaultNum = toint(ZhuanZhiModel:GetLv()) or 0;    --当前玩家的转生阶段,目前默认为1
	local splitT;
	for i,vo in pairs(bogeylist) do
		local tvo = t_item[i];
		if tvo then
			local playerinfo = MainPlayerModel.humanDetailInfo;
			if playerinfo.eaLevel >= tvo.needlevel then     --判断是否大于限制等级
				local num = BagModel:GetItemCanUseNum(i);
				local itemnum = BagModel:GetItemNumInBag(i);--背包中丹药数量
				local itemvo = {};
				itemvo.item_tid = i;
				splitT = split(t_item[i].zhuan_number,",")
				lifeMaxNum = splitT[defaultNum + 1];
				lifeMaxNum = tonumber(lifeMaxNum)
				usenum = BagModel:GetLifeUseNum(i);
				dayilyUseNum = BagModel:GetDailyUseNum(i);
				dayilyCanUseNum = BagModel:GetDailyTotalNum(i);
				-- 条件2
				if itemnum > lifeMaxNum then
					itemnum = lifeMaxNum - usenum
				else
					itemnum = itemnum
				end
				-- 条件1
				local full = false;
				local dayilLeftNum = dayilyCanUseNum - dayilyUseNum  --今日可以使用的丹药数量
				if dayilLeftNum > 0 and usenum < lifeMaxNum then   --每日剩余数量大于0，并且一生已经使用的总数量小于一生可以使用的总数量
					if itemnum > dayilyCanUseNum - dayilyUseNum then
						itemnum = dayilLeftNum
					end
					local lifeLeft = lifeMaxNum - usenum      --一生所剩的
					if itemnum > lifeLeft then
						itemnum = lifeLeft
					end
					local dayAndLifeMin = dayilLeftNum >= lifeLeft and lifeLeft or dayilLeftNum
					itemnum = dayAndLifeMin >= itemnum and itemnum or dayAndLifeMin
				else
					full = true;
				end
				itemvo.item_count = itemnum
				--[[
				local dayilyUseNum = BagModel:GetDailyUseNum(i);
				local dayilCanUseNum = BagModel:GetDailyTotalNum(i);
				itemvo.daily_UseNum    = dayilUseNum      --改物品日使用数量
				itemvo.daily_CanUseNum = dayilCanUseNum   --改丹药日可使用最大数量
				--]]
				if not full then
					table.push(list,itemvo);
				end
			end
		end
	end
	return list
	--[[
	-- 条件1：丹药使用数量不能大于今日可以使用丹药数量
	-- 条件2：丹药使用数量不能大于一生可以使用丹药数量
	-- @param item_count ：    背包丹药数量
	-- @param item_tid   :     丹药id
	-- @param daily_UseNum:    今日已经使用的丹药数量
	-- @param daily_CanUseNum: 今日可使用的丹药总数量
	--]]

	--[[
	local isHaveMax = false
	local newList = {};
	for k,v in pairs(list) do
		if v.item_count < lifeMaxNum then
			isHaveMax = true
		end
	end
	---参有饱和丹药
	if isHaveMax == true then
		for k,v in pairs(list) do
			if v.item_count == lifeMaxNum + 1 then
				v.item_count = 0
			end
			newList = deepcopy(list)
		end
	end
	-- 从所有的丹药中找出满足条件1和条件2的丹药存在新的list中
	---全是饱和丹药
	if isHaveMax == false then
		newList = deepcopy(list)
	end
	return newList;
	--]]
end

---table的深拷贝
 function RoleBoegeyPillUtil:deepcopy(t, n)
    local newT = {}
    if n == nil then    -- 默认为浅拷贝。。。
        n = 1
     end
      for i,v in pairs(t) do
          if n>0 and type(v) == "table" then
              local T = self:deepcopy(v, n-1)
            newT[i] = T
        else
             local x = v
             newT[i] = x
        end
     end
     return newT
  end


--VIP妖丹是否能使用
function RoleBoegeyPillUtil:GetVIPExtraNum(tid)
	local playerinfo = MainPlayerModel.humanDetailInfo;
	if playerinfo.eaVIPLevel <= 0 then
		return 0;
	end
	
	if self:OnIsCommonPill(tid) == false then
		return 0;
	end
	
	local itemList = split(t_vip[playerinfo.eaVIPLevel].vip_yaodan_extra_num,"#");
	for i,itemStr in ipairs(itemList) do
		if i == t_yaodan[tid].order then
			return itemStr;
		end
	end
	
	return 0;
end

-- 获得每一阶妖丹的使用进度
function RoleBoegeyPillUtil:GetBogeyPillUsePro()
	local list = {};
	local defaultNum = toint(ZhuanZhiModel:GetLv()) or 0    --当前玩家的转生阶段
	-- print("---------------当前玩家的转生阶段",defaultNum)
	-- if QuestController:IsShowZhuanShen() then
	-- 	defaultNum = ZhuanModel:GetZhuanType()
	-- end
	for i , v in ipairs(RoleBoegeyConsts.BoegeyCfg) do
		local pro = 0;
		local lifeusenum = 0;
		local liseusemax = 0;
		for j, vo in ipairs (v) do
			lifeusenum = lifeusenum + BagModel:GetLifeUseNum(vo);
			local tvo = t_item[vo];
			if tvo then
				liseusemax = liseusemax + tvo.life_limit;   --changer:houxudong add:更具转生状态读取不同的值
				local t = split(t_item[vo].zhuan_number,",") 
				-- trace(t)
				liseusemax = liseusemax + toint(t[defaultNum+1]);
			end
		end
		
		pro = lifeusenum / liseusemax * 100;
		pro = string.format("%.1f",pro);
		
		-- pro = self:formatfloat(pro);
		
		table.push(list, pro);
	end
	
	return list;
end

--优化小数
function RoleBoegeyPillUtil:formatfloat(floatnum)
	local newpro = floatnum * 10;
		
	local smallnum = -1;
	for i = 1,4 do
		local nzhengshu = math.modf(newpro % 10);
		if nzhengshu > 0 then
			smallnum = i;
		else
			newpro = newpro * 10;
		end
	end
	
	if smallnum == -1 then
		return string.format("%d",floatnum);
	else
		return string.format("%."..smallnum.."f",floatnum);
	end
end

-- 获得妖丹list
function RoleBoegeyPillUtil:GetBoegeyPillList(openlist)
	local treeData = {};
	treeData.label = "root";
	treeData.open = true;
	treeData.isShowRoot = false;
	treeData.nodes = {};
	
	local prolist = self:GetBogeyPillUsePro();
	
	local isfirst = true;
	for i , v in ipairs(RoleBoegeyConsts.BoegeyCfg) do
		local node = {};
		node.titlename = UIStrConfig['role55' .. i];
		node.pro = string.format(StrConfig["role401"],prolist[i]);
		node.ischild = false;
		node.nodes = {};
		node.open = false;
		
		if isfirst == true then
			node.open = true;
			isfirst = false;
		end
		
		if RoleBoegeyPillModel:GetpillPage() then
			if RoleBoegeyPillModel:GetIsShowEffect() == true then
				node.open = false;
				if RoleBoegeyPillModel:GetpillPage() == i then
					node.open = true;
				end
			end
		end
			
		for j, voj in ipairs(v) do
			local vochild = {};
			vochild.ischild = true;
			vochild.isplayeffect = false;
			if RoleBoegeyPillModel:GetpillPage() and RoleBoegeyPillModel:Geteffectitem() == voj then
				vochild.isplayeffect = true;
			end
			if t_item[voj].quality==1 then
				vochild.itemname = string.format(StrConfig['role442'],t_item[voj].name);  ---item标题名
			elseif t_item[voj].quality==2 then
				vochild.itemname = string.format(StrConfig['role443'],t_item[voj].name);  ---item标题名
			elseif t_item[voj].quality==3 then
				vochild.itemname = string.format(StrConfig['role444'],t_item[voj].name);  ---item标题名
			end
			--属性加成及数量
			local defaultNum = toint(ZhuanZhiModel:GetLv()) or 0    --当前玩家的转生阶段   --当前玩家的转生阶段
			local t = split(t_item[voj].zhuan_number,",")   --分割字符串
			if t_item[voj].use_param_1 == enAttrType.eaGongJi then
				vochild.attrinfo = string.format(StrConfig['role402'],BagModel:GetLifeUseNum(voj) * t_item[voj].use_param_2);
				vochild.attrnum = string.format(StrConfig['role405'],BagModel:GetLifeUseNum(voj),t[defaultNum+1]);
				vochild.maximum = toint(t[defaultNum+1]);
				vochild.value = toint(BagModel:GetLifeUseNum(voj));
			elseif t_item[voj].use_param_1 == enAttrType.eaFangYu then
				vochild.attrinfo = string.format(StrConfig['role403'],BagModel:GetLifeUseNum(voj) * t_item[voj].use_param_2);
				vochild.attrnum = string.format(StrConfig['role405'],BagModel:GetLifeUseNum(voj),t[defaultNum+1]);
				vochild.maximum = toint(t[defaultNum+1]);
				vochild.value = toint(BagModel:GetLifeUseNum(voj));
			elseif t_item[voj].use_param_1 == enAttrType.eaMaxHp then
				vochild.attrinfo = string.format(StrConfig['role404'],BagModel:GetLifeUseNum(voj) * t_item[voj].use_param_2);
				vochild.attrnum = string.format(StrConfig['role405'],BagModel:GetLifeUseNum(voj),t[defaultNum+1]);
				vochild.maximum = toint(t[defaultNum+1]);
				vochild.value = toint(BagModel:GetLifeUseNum(voj));
			elseif t_item[voj].use_param_1 == enAttrType.eaTiPo then
				vochild.attrinfo = string.format(StrConfig['role406'],BagModel:GetLifeUseNum(voj) * t_item[voj].use_param_2);
				vochild.attrnum = string.format(StrConfig['role405'],BagModel:GetLifeUseNum(voj),t[defaultNum+1]);
				vochild.maximum = toint(t[defaultNum+1]);
				vochild.value = toint(BagModel:GetLifeUseNum(voj));				
			elseif t_item[voj].use_param_1 == enAttrType.eaShenFa then
				vochild.attrinfo = string.format(StrConfig['role407'],BagModel:GetLifeUseNum(voj) * t_item[voj].use_param_2);
				vochild.attrnum = string.format(StrConfig['role405'],BagModel:GetLifeUseNum(voj),t[defaultNum+1]);
				vochild.maximum = toint(t[defaultNum+1]);
				vochild.value = toint(BagModel:GetLifeUseNum(voj));
			elseif t_item[voj].use_param_1 == enAttrType.eaHunLi then
				vochild.attrinfo = string.format(StrConfig['role408'],BagModel:GetLifeUseNum(voj) * t_item[voj].use_param_2);
				vochild.attrnum = string.format(StrConfig['role405'],BagModel:GetLifeUseNum(voj),t[defaultNum+1]);
				vochild.maximum = toint(t[defaultNum+1]);
				vochild.value = toint(BagModel:GetLifeUseNum(voj));
			elseif t_item[voj].use_param_1 == enAttrType.eaJingShen then
				vochild.attrinfo = string.format(StrConfig['role409'],BagModel:GetLifeUseNum(voj) * t_item[voj].use_param_2);
				vochild.attrnum = string.format(StrConfig['role405'],BagModel:GetLifeUseNum(voj),t[defaultNum+1]);
				vochild.maximum = toint(t[defaultNum+1]);
				vochild.value = toint(BagModel:GetLifeUseNum(voj));
			end
			local rewardSlotVO = RewardSlotVO:new();
			rewardSlotVO.id = voj;
			rewardSlotVO.count = 0;
			vochild.id = rewardSlotVO.id;
			vochild.count = rewardSlotVO.count;
			vochild.showCount = rewardSlotVO:GetShowCount();
			vochild.iconUrl = rewardSlotVO:GetIcon();
			vochild.bind = rewardSlotVO.bind;
			vochild.showBind = rewardSlotVO:GetShowBind();
			vochild.qualityUrl = rewardSlotVO:GetQualityUrl(true);
			vochild.quality = rewardSlotVO:GetQuality();
			vochild.isBlack = rewardSlotVO.isBlack and true or false;
			table.push(node.nodes,vochild);
		end
		table.push(treeData.nodes, node);
	end
	return treeData;
end

--得到妖丹增加属性
function RoleBoegeyPillUtil:GetBogyePillAttr()
	local list = {};
	for i,vo in pairs(t_yaodan) do
		local usenum = BagModel:GetLifeUseNum(vo.id);
		if usenum > 0 then
			local itemvo = t_item[vo.id];
			if itemvo then
				if not list[vo.type] then
					list[vo.type] = usenum * itemvo.use_param_2;   --use_param_2 == 0
				else
					list[vo.type] = list[vo.type] + usenum * itemvo.use_param_2;
				end
			end
		end
	end
	return list;
end

--获取今天VIP使用的妖丹数量
function RoleBoegeyPillUtil:GetDailyVIPUseNum()
	local vipcount = 0;
	for i,vo in pairs(t_yaodan) do
		local usenum = BagModel:GetDailyUseNum(vo.id);
		if usenum > 0 then
			local itemvo = t_item[vo.id];
			if itemvo then
				if usenum > BagModel:GetDailyTotalWithOutVipNum(itemvo.id) then
					vipcount = vipcount + (usenum - BagModel:GetDailyTotalWithOutVipNum(itemvo.id));
				end
			end
		end
	end
	return vipcount;
end

--获取今天VIP使用的妖丹数量(新)
function RoleBoegeyPillUtil:GetDailyVIPUseNumNew(id)
	local vipcount = 0;
	local usenum = BagModel:GetDailyUseNum(id);
	if usenum > 0 then
		local itemvo = t_item[id];
		if itemvo then
			if usenum > BagModel:GetDailyTotalWithOutVipNum(itemvo.id) then
				vipcount = vipcount + (usenum - BagModel:GetDailyTotalWithOutVipNum(itemvo.id))
			end
		end
	end
	return vipcount
end