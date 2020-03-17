--[[
RoleUtil
lizhuangzhuang
2014年10月23日22:13:57
]]

_G.RoleUtil = {};

--获取自动加点方案
function RoleUtil:GetAutoPoint(point)
	--配置顺序
	local pointSequence = {enAttrType.eaHunLi,enAttrType.eaTiPo,enAttrType.eaShenFa,enAttrType.eaJingShen};
	local cfg = t_playerinfo[MainPlayerModel.humanDetailInfo.eaProf];
	if point<=0 or not cfg then 
		local vo = {};
		for i,eaType in ipairs(pointSequence) do
			vo[eaType] = 0;
		end
		return vo;
	end
	local t = split(cfg.autoPoint,",");
	local vo = {};
	local leftPoint = point;
	local maxEaType = 0;--最大属性列
	local maxAddVal = -1;--最大属性
	for i,eaType in ipairs(pointSequence) do
		local addVal = toint(tonumber(t[i])/100*point,-1);
		vo[eaType] = addVal;
		leftPoint = leftPoint - addVal;
		if addVal > maxAddVal then
			maxAddVal = addVal;
			maxEaType = eaType;
		end
	end
	vo[maxEaType] = vo[maxEaType] + leftPoint;
	return vo;
end

--判断是否可以转换称号的状态
function RoleUtil:GetProTitleData(id)
	for i , v in pairs(TitleModel.oldTitleData[t_title[id].type]) do
		if v.id == id then
			if v.state == 0 then 
				return false;
			else
				return true;
			end
		end
	end
	return false;
end

-- 去掉字符串"]"之前的字符(用于去掉名字中的区服)
function RoleUtil:TailorName( str )
	local firstRank = string.find( str, "]" ) or 0
	return string.sub( str, firstRank + 1, -1 )
end

--adder:houxudong 
--date:2016/8/1
--潜能加点红点提示
function RoleUtil:CheckIsHavePoint( )
	local info = MainPlayerModel.humanDetailInfo;
	local totalPoint = info.eaLeftPoint;
	if totalPoint > 0 then
		return true
	else
		return false
	end
end

--获得妖丹
function RoleUtil:GetBogeyPillList(isvip)
	local isCanUse = false
	local bagVO = BagModel:GetBag(BagConsts.BagType_Bag);
	if not bagVO then return; end;
	
	local bogeylist = {};
	local itemlist = nil;    --显示分类时的Item列表
	itemlist = bagVO:GetItemListByShowType(BagConsts.ShowType_Consum);
	--遍历消耗列表
	for i,vo in ipairs(itemlist) do
		if vo then
			local tid = vo:GetTid();
			--普通妖丹
			if isvip == false then
				if RoleBoegeyPillUtil:OnIsCommonPill(tid) == true then
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
	local usenum ;    ----当前已经使用的妖丹数量
	local lifeMaxNum;  ----一生所需要的最大妖丹数量,更具转生状态来修改
	local defaultNum = toint(ZhuanZhiModel:GetLv()) or 0;    --当前玩家的转生阶段,目前默认为1
	local splitT;
	-- trace(bogeylist)
	for i,vo in pairs(bogeylist) do
		local tvo = t_item[i];
		if tvo then
			local playerinfo = MainPlayerModel.humanDetailInfo;
			if playerinfo.eaLevel >= tvo.needlevel then   ---判断是否大于限制等级
				local num = BagModel:GetItemCanUseNum(i);
				local haveNum = BagModel:GetItemNumInBag(i);
				local itemnum = BagModel:GetItemNumInBag(i);
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
				if usenum == lifeMaxNum then
				    itemnum = lifeMaxNum + 1  
				end
				-- print("每日可以使用的丹药总数量:",dayilyCanUseNum)
				-- print("丹药每日使用的数量:",dayilyUseNum)
				-- print("vip可以使用的丹药总数量:",RoleBoegeyPillUtil:GetDailyVIPUseNum())
				
				-- 条件1
				local dayilLeftNum = dayilyCanUseNum - (dayilyUseNum)  --今日可以使用的丹药数量
				local lifeLeft = lifeMaxNum - usenum    --一生剩余的数量
				if dayilLeftNum > 0 and lifeLeft > 0 then
					isCanUse = true;
				else
					isCanUse = false;
				end
			end
		end  
		if isCanUse then
			return isCanUse;
		end
	end
	return isCanUse
end