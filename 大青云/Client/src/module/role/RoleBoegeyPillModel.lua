--[[
	人物妖丹
	2014年12月12日, PM 02:31:16
	wangyanwei
]]--

_G.RoleBoegeyPillModel=Module:new();
RoleBoegeyPillModel.oldBogeypillData = {};  --妖丹的列表
RoleBoegeyPillModel.oldYaoHunExchangeData = {};	--妖魂兑换过类型的列表
RoleBoegeyPillModel.oldYaoHunNum = 0;				--身上有多少妖魂

RoleBoegeyPillModel.pillPage = nil;
RoleBoegeyPillModel.pillIndex = nil;
RoleBoegeyPillModel.isshoweffect = false; -- 是否显示右下角自动服用妖丹后的特效显示
RoleBoegeyPillModel.effectitem = 0;
--返回妖丹列表
function RoleBoegeyPillModel:OnUpDataYaoDanHandler(yaoDanList)
	if #self.oldBogeypillData < 1 then self:OnSetMyOldBoegeyDataHandler() end;  --如果为空   构置一下妖丹列表
	local body = {};
	for i , v in ipairs(self.oldBogeypillData) do
		for j , k in ipairs(v) do
			for f , g in pairs(yaoDanList) do
				if k.id == g.itemId then
					k.num = g.num;
					body = g;
				end
			end
		end
	end
	self:sendNotification(NotifyConsts.UpdataBogeyPillChangeList,body);
end

--服务器返回妖魂兑换属性列表
function RoleBoegeyPillModel:OnUpDataYaoHunAttrResultHandler(yaoHunList)
	if #self.oldYaoHunExchangeData < 1 then self:OnSetMyYaoHunDataHandler() end;  --如果为空   构置一下妖魂列表
		for i , v in ipairs(self.oldYaoHunExchangeData) do
			for j , k in pairs (yaoHunList) do
				if v.type == k.type then
					v.num = k.num;
				end
			end
		end
		
end

--返回妖魂值
function RoleBoegeyPillModel:OnUpDataYaoHunHandler(yaoHunVal)
	self.oldYaoHunNum = self.oldYaoHunNum + yaoHunVal;
end

--服务器返回妖魂兑换(是否成功与哪个类型)
function RoleBoegeyPillModel:OnUpDataYaoHunExchangeHandler(obj)
	if obj.result ~= 0 then return end; ---------------------兑换失败
	
	for i , v in ipairs(self.oldYaoHunExchangeData) do
		if v.type == obj.type then
			v.num = v.num + v.addVal;
			self.oldYaoHunNum = self.oldYaoHunNum - v.conVal;
		end
	end
	self:sendNotification(NotifyConsts.UpdataYaoHunChangeList);
end

--构置妖丹列表
function RoleBoegeyPillModel:OnSetMyOldBoegeyDataHandler()
	for i = 1 , 3 do
		self.oldBogeypillData[i] = {};
		for j = 1 , 6 do
			local vo = {};
			vo.id = RoleBoegeyConsts.BoegeyCfg[i][j];
			vo.num = BagModel:GetLifeUseNum(vo.id);
			local cfg = t_item[vo.id];
			if not cfg then return end
			vo.maxDayIndex = BagModel:GetDailyLimit(cfg.id);
			vo.maxIndex = cfg.life_limit;
			if not cfg.life_limit then 
				vo.maxIndex = 0;
			end
			self.oldBogeypillData[i][j] = vo;
		end
	end
	for i = 4 , 6 do
		for j = 1 , 6 do
			local vo = {};
			vo.id = RoleBoegeyConsts.BoegeyCfg[i][j];
			vo.num = BagModel:GetLifeUseNum(vo.id);
			local cfg = t_item[vo.id];
			if not cfg then return end
			vo.maxDayIndex = BagModel:GetDailyLimit(cfg.id);
			vo.maxIndex = cfg.life_limit;
			if not cfg.life_limit then 
				vo.maxIndex = 0;
			end
			self.oldBogeypillData[i - 3][j + 6] = vo;
		end
	end
end

--构置妖魂兑换列表
function RoleBoegeyPillModel:OnSetMyYaoHunDataHandler()
	local tList = t_consts[26].param;
	local tStr = split(tList,"#")
	for i , v in ipairs(tStr) do
		table.push(self.oldYaoHunExchangeData,{})
		local t = split(v,",");
		local vo = {};
		vo.num = 0;
		vo.type = AttrParseUtil.AttMap[t[1]];
		vo.addVal = tonumber(t[2]);
		vo.conVal = tonumber(t[3]);
		self.oldYaoHunExchangeData[i] = vo;
	end
end

--兑换请求
function RoleBoegeyPillModel:SetExYaoHunPleaseHandler(index)
	for i , v in ipairs(self.oldYaoHunExchangeData) do
		if v.type == index then
			if self.oldYaoHunNum >= v.conVal then
				RoleController:OnExChangeYaoHunHandler(index);
				return;
			end
			--妖魂不够``````````````````````````````````````````````
		end
	end
end

--获取指定类型的妖丹
function RoleBoegeyPillModel:GetYaoDanListHandler(indexType)
	if self.oldBogeypillData == {} then
		self:OnSetMyOldBoegeyDataHandler();
	end
	local obj = {};
	for i , v in ipairs(self.oldBogeypillData) do
		if i == indexType then
			obj = v ;
		end
	end
	return obj;
end

--返回总数与当前数
function RoleBoegeyPillModel:GetYaoDanNumHandler(indexID)
	local obj = {};
	for i , v in ipairs(self.oldBogeypillData) do
		for j , k in ipairs(v) do
			if k.id == indexID then
				obj.maxNum = k.maxIndex;
				obj.num = k.num;
				break;
			end
		end
	end
	return obj;
end

--获得当前妖丹得了多少属性
function RoleBoegeyPillModel:GetYaoDanNumList()
	self:OnSetMyOldBoegeyDataHandler()  --如果为空   构置一下妖丹列表
	local obj = {};
	for i = 1 , #self.oldBogeypillData do
		obj[i] = 0;
		local cfg = self.oldBogeypillData[i];
		for j , k in ipairs(cfg) do
			obj[i] = obj[i] + t_item[k.id].use_param_2 * k.num;
		end
	end
	return obj;
end

function RoleBoegeyPillModel:SetpillPage(pillPage)
	self.pillPage = pillPage;
end
function RoleBoegeyPillModel:GetpillPage()
	return self.pillPage;
end
function RoleBoegeyPillModel:SetpillIndex(pillIndex)
	self.pillIndex = pillIndex;
end
function RoleBoegeyPillModel:GetpillIndex()
	return self.pillIndex;
end
function RoleBoegeyPillModel:SetIsShowEffect(isshoweffect)
	self.isshoweffect = isshoweffect;
end
function RoleBoegeyPillModel:GetIsShowEffect()
	return self.isshoweffect
end
function RoleBoegeyPillModel:Seteffectitem(effectitem)
	self.effectitem = effectitem;
	
	
	print('=========self.effectitem=',effectitem)
end
function RoleBoegeyPillModel:Geteffectitem()
	return self.effectitem
end