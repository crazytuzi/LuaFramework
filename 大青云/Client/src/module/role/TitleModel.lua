--[[
	称号数据
	2014年11月24日, PM 02:12:11
	wangyanwei
]]--

_G.TitleModel=Module:new();

TitleModel.oldTitleData = {};

TitleModel.timeKey = nil;

function TitleModel:Create()
	-- if self.timeKey then 
		-- return;
	-- else
		-- self:OnTimeHandler();
	-- end
	
end

--更新称号数据
function TitleModel:OnUpDataTitleInfo(titleListVO)
	if #self.oldTitleData < 1 then
		for i , v in pairs (t_titlegroup) do
			self.oldTitleData[i] = {};
		end
	end
	
	local verSionName = Version:GetName();

	for i , v in pairs(titleListVO) do
		local titleCfg = t_title[v.id];
		if not titleCfg then return end
		if titleCfg.plat == '' or titleCfg.plat == verSionName then
			local titleVO = {};
			titleVO.id = v.id;
			titleVO.state = v.state;
			titleVO.time = v.time;
			titleVO.showIndex = t_title[v.id].showIndex;
			
			local _type = titleCfg.type;
			self.oldTitleData[_type][titleVO.showIndex] = titleVO;
			if v.state == 2 then
				--改为所有类别中同时只可以佩戴一个称号 yanghongbin/jianghaoran 2016-8-20
				for t1, type in pairs(self.oldTitleData) do
					for t2, cfg in pairs(type) do
						if t_title[cfg.id].type == titleCfg.type then
							if cfg.id ~= v.id then
								if cfg.state == 2 then
									cfg.state = 1;
								end
							end
						else
							if cfg.state == 2 then
								cfg.state = 1;
							end
						end
					end
				end
				--[[
				for i,cfg in pairs(self.oldTitleData[titleCfg.type]) do
					if t_title[cfg.id].type == titleCfg.type then 
						if cfg.id ~= v.id then
							if cfg.state == 2 then
								cfg.state = 1;
							end
						end
					end
				end
				]]
			end
		end
	end
	self:sendNotification(NotifyConsts.TitleNumChange);
	self:GetDressTitle();  --更新身上的称号数据
end

--计时算法
-- TitleModel.oldTimeInt = {};
-- function TitleModel:OnTimeHandler()
	-- local timeTitleCfg = self.oldTitleData[TitleConsts.RType_Activity];
	-- if timeTitleCfg == {} then return end
	-- local func = function()
		-- for i , f in pairs(timeTitleCfg) do
			-- if f.time ~= -1 then
				-- if f.state ~= 0 then
					-- local numTime = f.time - GetServerTime();
					-- local minTime = toint(numTime/60,1);
					-- if numTime < 1 then  --做下判断  是否移除掉计时器
						
					-- end
					-- if minTime <= 10 then
						--if not self.oldTimeInt[f.id] or self.oldTimeInt[f.id] < 0 then
						--	self.oldTimeInt[f.id] = minTime;
						--	if not TitleTimeTip:IsShow() then 
								--TitleTimeTip:Open(t_title[f.id]);
						--	end
						--elseif self.oldTimeInt[f.id] ~= minTime then
						--	self.oldTimeInt[f.id] = minTime;
						--end
							-- self:sendNotification(NotifyConsts.TitleTipTime,f);
					-- end
				-- end
			-- end
		-- end
	-- end
	-- self.timeKey = TimerManager:RegisterTimer(func,1000);
-- end

--根据ID获得身上的是否获得这个称号
function TitleModel:GetTitle(id)
	local titleCfg = t_title[id];
	if not titleCfg then return false end
	local tableType = titleCfg.type;
	local typeCfg = self.oldTitleData[tableType];
	if not typeCfg then return false end
	for i , title in pairs(typeCfg) do
		if title.id == id then
			if title.state == 0 then return false end
			return true
		end
	end
	return false
end

--根据ID获得身上的称号
function TitleModel:GetTitleCfg(id)
	local titleCfg = t_title[id];
	if not titleCfg then return nil end
	local tableType = titleCfg.type;
	local typeCfg = self.oldTitleData[tableType];
	if not typeCfg then return nil end
	for i , title in pairs(typeCfg) do
		if title.id == id then
			if title.state == 0 then return nil end
			return title
		end
	end
	return nil
end

--服务器发送获得或者删除称号称号
function TitleModel:OnGetTitleBcakInfo(titleListVO)
	local titleVO = {};
	titleVO.id = titleListVO.id;
	titleVO.time = titleListVO.time;
	titleVO.showIndex = t_title[titleListVO.id].showIndex;
	if titleVO.time == 0 then
		titleVO.state = 0 ;
	elseif titleVO.time == -1 then
		titleVO.state = 1 ;
	else
		titleVO.state = 1 ;
	end
	local titleCfg = t_title[titleVO.id];
	if not titleCfg then return end
	if not self.oldTitleData[titleCfg.type] then return end
	self.oldTitleData[titleCfg.type][titleVO.showIndex] = titleVO;	
	if titleVO.state == 0 then
		self:sendNotification(NotifyConsts.TitleNumChange,titleVO);
		self:sendNotification(NotifyConsts.TitleRemoveTime,titleVO);
		return ;
	end
	local cfg = t_title[titleListVO.id];
	if isDebug then 
		--print(titleListVO.id .. 'Error' .. '称号错误');
		--debug.debug();
		trace(cfg);
		print('获得新称号↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑')
	end
	if not cfg then return end
	if not UITitleGetTips:IsShow() then
		UITitleGetTips:Open(t_title[titleListVO.id].bigIcon,titleListVO.id);
	else
		UITitleGetTips:SetOpen(t_title[titleListVO.id].bigIcon,titleListVO.id);
	end
	self:sendNotification(NotifyConsts.TitleNumChange,titleVO);
	self:sendNotification(NotifyConsts.TitleGetItem,titleVO);
	self:sendNotification(NotifyConsts.TitleRemoveTime,titleVO);
end

-------------------------------------面板请求操作-------------------------------------------

--穿戴显示
function TitleModel:OnEquipBoolean(id)
	for i , v in pairs(self.oldTitleData[t_title[id].type]) do 
		if v.id == id then 
			if v.state == 2 then 
				return true;
			else
				return false;
			end
		end;
	end;
	--当以上判断无效时 返回false；↓
	return false;
end

--获取穿戴按钮txt的状态
function TitleModel:GetBtnState(id)
	local cfgId = t_title[id];
	if not cfgId then return  end
	local cfg =self.oldTitleData[t_title[id].type] ;
	if not cfg then return UIStrConfig["title012"]; end
	for i , v in pairs(self.oldTitleData[t_title[id].type]) do 
		if v.id == id then
			if v.state == 0 then 
				return UIStrConfig["title012"];
			elseif v.state == 1 then
				return UIStrConfig["title010"];
			else
				return UIStrConfig["title011"];
			end
		end
	end
	--当以上判断无效时 返回false；↓
	return UIStrConfig["title012"];
end

--获取该ID类型的所有称号
function TitleModel:GetTitleTable(typeID)
	local list ={};
	local verSionName = Version:GetName();
	for i,v in pairs(t_title) do
		if v.type == typeID and v.plat then
			if v.plat ~= '' then
				if verSionName == v.plat then
					table.push(list,v);
				end
			else
				table.push(list,v);
			end
		end
	end
	-- trace(list)
	-- print('===')
	-- debug.debug();
	table.sort(list,function(A,B)
		return A.showIndex < B.showIndex
	end)
	-- local listPairs = {};
	-- for i,v in ipairs(list) do 
		-- table.push(listPairs,v);
	-- end
	--将table引用排序进行导出
	return list;
end

--点击穿戴卸下按钮请求的数据
function TitleModel:GetEquipDisboard(id)
	local cfg = self.oldTitleData[t_title[id].type][id] ;
	if not cfg then return end;
	
	if cfg.state == 0 then 
		return ;
	elseif cfg.state == 1 then 
		TitleController:OnEquipTitle(cfg.id,0);
	else
		TitleController:OnEquipTitle(cfg.id,1);
	end
end

--请求属性值
function TitleModel:GetTitleData(id)
	local cfg = t_title[id];
	if not cfg then return "" ; end;
	local obj ={};
	obj.att = cfg.att;
	obj.def = cfg.def;
	obj.hp = cfg.hp;
	obj.hit = cfg.hit;
	obj.dodge = cfg.dodge;
	obj.cri = cfg.cri;
	obj.defcri = cfg.defcri;
	return obj;
end

--获取ID的类型
function TitleModel:GetTitleType(id)
	for i , v in ipairs(self.oldTitleData) do
		for j , k in pairs(t_title) do
			if i == k.type then
				if k.id == id then
					return i;
				end
			end
		end	
	end
	return nil;
end

--获取时间
function TitleModel:GetTitleTimeHandler(id)
	local cfgId = t_title[id];
	if not cfgId then return 0; end
	local cfg = self.oldTitleData[t_title[id].type][t_title[id].showIndex];
	local objTime = {};
	if not cfg or cfg.time == 0 then return 0; end;
	if cfg.time == -1 then return -1; end;
	local day,hour,min,sec = CTimeFormat:sec2formatEx(cfg.time - GetServerTime());
	local num = cfg.time - GetServerTime();
	objTime.hour = hour;
	objTime.day = day;
	objTime.min = min;
	objTime.sec = sec;
	return objTime;
end

--身上穿戴的称号
TitleModel.nowTitleImg = {};
function TitleModel:GetDressTitle()
	self.nowTitleImg = {};
	for i , v in pairs(self.oldTitleData) do
		for j , f in pairs(v) do
			if f.state == 2 then
				local titleUrl = ResUtil:GetTitleIconSwf(t_title[f.id].bigIcon);
				table.push(self.nowTitleImg,titleUrl);
			end
		end
	end
end

--获取当前穿戴的称号图片
function TitleModel:GetNowTitleImg()
	return self.nowTitleImg;
end

--获取当前穿戴的称号图片
function TitleModel:GetImgByID(obj)
	local titleObj = {};
	for i,v in pairs(obj) do
		if t_title[v] then 
			local titleUrl = ResUtil:GetTitleIconSwf(t_title[v].bigIcon);
			table.push(titleObj,titleUrl);
		end
	end
	return titleObj;
end

------------------------------------UI发送请求---------------------------------------

--请求更换按钮状态
function TitleModel:SetTitleStateHandler(id)
	for i ,v in pairs(self.oldTitleData[t_title[id].type]) do
		if v.id == id then
			local obj = {};
			obj.id = v.id;
			obj.state = v.state;
			TitleController:OnEquipTitle(obj);
		end
	end
	return ;
end