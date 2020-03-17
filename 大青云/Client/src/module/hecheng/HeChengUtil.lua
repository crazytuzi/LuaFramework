--[[
道具合成Util
zhangshuhui
2014年12月27日15:20:20
]]

_G.HeChengUtil = {};

--获取合成道具tree
--节点定义
--Node.nodeType 0一级,1二级,2三级
--Node.lvl 道具lvl 用于鼠标单击判断 1一级，2二级，3三级
--Node.id 道具id
function HeChengUtil:GetHeChengTree(cfg,type,openlist)
	local treeData = {};
	treeData.label = "root";
	treeData.open = true;
	treeData.isShowRoot = false;
	treeData.nodes = {};
	
	local selid = 0;
	
	local list = {};
	for i,vo in pairs(cfg) do
		if vo then
			table.push(list, vo);
		end
	end
	list = self:SortHeChengList(list);
	
	local isget = false;
	for i,vo in pairs(list) do
		if vo then
			if isget == false then
				isget = true;
				selid = vo.id;
			end
			
			self:AddTreeNode(treeData, vo, type, 1, openlist);
		end
	end
	
	return treeData, selid;
end


function HeChengUtil:AddTreeNode(treeData, vo, type, index, openlist)
	local ishave = false;
	for i,voi in pairs(treeData.nodes) do
		if voi["label"..index] == vo["label"..index] then
			self:AddDataNode(voi, vo, type, index+1, openlist);
			ishave = true;
			break;
		end
	end
	
	if ishave == false then
		local node = {};
		node.label1 = vo["label"..index];
		node.nodes = {};
		if self:GetIsOpen(node, openlist) == true then
			node.open = true;
		else
			node.open = false;
		end
		node.withIcon = true;
		node.label = string.format( StrConfig['hecheng12'], vo["name"..index]);
		node.lvl = index;
		self:AddDataNode(node, vo, type, index+1, openlist);
		
		table.push(treeData.nodes, node);
	end
end

function HeChengUtil:AddDataNode(datavo, vo, type, index, openlist)
	if index >= 5 then
		return;
	end
	
	--空的
	if index < 4 then
		if vo["name"..index] == "" then
			self:AddDataNode(datavo, vo, type, index+1, openlist);
			return;
		end
	end
	
	local ishave = false;
	for i,voi in pairs(datavo.nodes) do
		if voi["label"..index] == vo["label"..index] then
			self:AddDataNode(voi, vo, type, index+1, openlist);
			ishave = true;
			break;
		end
	end
	
	if ishave == false then
		local node = {};
		for i=1,index do
			node["label"..i] = vo["label"..i];
		end
		node.nodes = {};
		
		if self:GetIsOpen(node, openlist) == true then
			node.open = true;
		else
			node.open = false;
		end
		node.withIcon = true;
		-- 第一层
		if index == 1 then
			node.label = string.format( StrConfig['hecheng12'], vo["name"..index]);
		-- 第二层 (丹药)
		elseif index == 2 then
			local heChengTwoCount = 0;
			local sameLabeltwoList = self:GetTreeTwoSimpleList(vo.id)
			if type == 1 then  --只计算合成
				if sameLabeltwoList then
					for k,v in pairs(sameLabeltwoList) do
						heChengTwoCount = heChengTwoCount + self:GetHeChengMax(v.id) 
					end
				end
			end
			if heChengTwoCount == 0 then
				node.label = string.format( StrConfig['hecheng18'], vo["name"..index]);
			else
				node.label = string.format( StrConfig['hecheng181'], vo["name"..index],heChengTwoCount);
			end
			node.labels = string.format( StrConfig['hecheng18'], vo["name"..index]);
		-- 第三层(多少阶丹药)
		elseif index == 3 then
			local heChengThreeCount = 0;
			local sameLabelthreeList = self:GetTreeThreeSimpleList(vo.id)
			if type == 1 then  --只计算合成
				if sameLabelthreeList then
					for k,v in pairs(sameLabelthreeList) do
						heChengThreeCount = heChengThreeCount + self:GetHeChengMax(v.id) 
					end
				end
			end
			-- print("合成数量:",heChengThreeCount)
			local toolItem = t_item[vo.id];
			if not toolItem then
				toolItem = t_equip[vo.id];
			end
			if toolItem then
				if heChengThreeCount == 0 then
					node.label = string.format( StrConfig['hecheng11'], vo["name"..index]);
				else
					node.label = string.format( StrConfig['hecheng111'], vo["name"..index],heChengThreeCount);
				end
			end
			node.labels = string.format( StrConfig['hecheng11'], vo["name"..index]);
		elseif index == 4 then
			--合成分解数量
			local hechengcount = 0;
			if type == 1 then
				hechengcount = self:GetHeChengMax(vo.id)  --合成所需要的数量
			elseif type == 2 then
				hechengcount = self:GetFenJieMax(vo.id)
			end
			local toolItem = t_item[vo.id];
			if not toolItem then
				toolItem = t_equip[vo.id];
			end
			if toolItem then
				if hechengcount == 0 then
					node.label = string.format( StrConfig['hecheng10'], toolItem.name);
				else
					-- 第四个页签上的合成物品名以及他的数量
					node.label = string.format( StrConfig['hecheng9'], toolItem.name, hechengcount);
				end
			end
			node.id = vo.id;
		end
		node.lvl = index;
		self:AddDataNode(node, vo, type, index+1, openlist);
		
		table.push(datavo.nodes, node);
	end
end

-- 树的第二层总数量
function HeChengUtil:GetTreeTwoSimpleList( id )
	local sameLabelTwoList = {}
	local cfg = t_itemcompound[id]
	if not cfg then return end
	local label2 = cfg.label2
	if label2 == 0 then return end
	for k,v in pairs(t_itemcompound) do
		if v.label2 == label2 then
			local vo = {}
			vo.id = v.id
			table.push(sameLabelTwoList,vo)
		end
	end
	return sameLabelTwoList
end

-- 输的第三层总数量
-- @param1 物品id
function HeChengUtil:GetTreeThreeSimpleList(id) 
	local sameLabelthreeList = {}
	local cfg = t_itemcompound[id]
	if not cfg then return end
	local label3 = cfg.label3
	if label3 == 0 then return end
	for k,v in pairs(t_itemcompound) do
		if v.label3 == label3 then
			local vo = {}
			vo.id = v.id
			table.push(sameLabelthreeList,vo)
		end
	end
	return sameLabelthreeList
end

--该节点是否是打开的
function HeChengUtil:GetIsOpen(node, openlist)
	for i,vo in pairs(openlist) do
		if vo then
			local ishave = true;
			for i=1,HeChengConsts.CENGMAX do
				if node["label"..i] and vo["label"..i] then
					if node["label"..i] ~= vo["label"..i] then
						ishave = false;
						break;
					end
				elseif (not node["label"..i] and vo["label"..i]) or (node["label"..i] and not vo["label"..i]) then
					ishave = false;
					break;
				end
			end
			
			if ishave == true then
				return true;
			end
		end
	end
	
	return false;
end



--两个列表相加
function HeChengUtil:AddList(listsrc, listtarget)
	for i,vo in pairs(listtarget) do
		table.insert(listsrc ,vo);
	end
	
	return listsrc;
end

--获取物品品质
function HeChengUtil:GetQualityUrl(itemId)
    local cfg = t_equip[itemId] or t_item[itemId];
    local qURL = cfg and ResUtil:GetSlotQuality( cfg.quality ) or "";
    return qURL;
end

--合成道具最大数
function HeChengUtil:GetHeChengMax(itemId)
	local hechengmax = 0;
    local itemvo = t_itemcompound[itemId];
	if itemvo then
		local itemList = RewardManager:ParseToVO( itemvo.materialitem );
		local materiallist = {};
		
		--材料数量
		for i,vo in ipairs(itemList) do
			if vo then
				if not materiallist[vo.id] then
					materiallist[vo.id] = vo.count;
				else
					materiallist[vo.id] = materiallist[vo.id] + vo.count;
				end
			end
		end
		local isSet = false;
		for j,voj in pairs(materiallist) do
			local intemNum = BagModel:GetItemNumInBag(j);
			local hechengmaterialmax = math.ceil(intemNum/materiallist[j]);
			if intemNum%materiallist[j] > 0 then
				hechengmaterialmax = hechengmaterialmax - 1;
			end
			
			if isSet == false then
				isSet = true;
				hechengmax = hechengmaterialmax;
			elseif hechengmax > hechengmaterialmax then
				hechengmax = hechengmaterialmax;
			end
		end
	end
	
	
	return hechengmax;
end

--分解道具最大数
function HeChengUtil:GetFenJieMax(itemId)
	local hechengmax = 0;
    local itemvo = t_itemresolve[itemId];
	if itemvo then
		hechengmax = BagModel:GetItemNumInBag(itemId);
	end
	
	return hechengmax;
end

--列表排序
function HeChengUtil:SortHeChengList(cfg)
	table.sort(cfg,function(A,B)
		if A.label1 == B.label1 then
			if A.label2 == B.label2 then
				if A.label3 == B.label3 then
					return A.label4 < B.label4;
				else
					return A.label3 < B.label3;
				end
			else
				return A.label2 < B.label2;
			end
		else
			return A.label1 < B.label1;
		end
	end);
	
	return cfg;
end

--合成材料数量列表
function HeChengUtil:GetHeChengMaterialList(itemId)
	local list = {};
    local itemvo = t_itemcompound[itemId];
	if itemvo then
		local itemList = RewardManager:ParseToVO( itemvo.materialitem );
		local materiallist = {};
		
		--材料数量
		for i,vo in ipairs(itemList) do
			if vo then
				if not materiallist[vo.id] then
					materiallist[vo.id] = 1;
				else
					materiallist[vo.id] = materiallist[vo.id] + 1;
				end
			end
		end
		
		--遍历每一种材料的数量
		for j,voj in pairs(materiallist) do
			local intemNum = BagModel:GetItemNumInBag(j);
			--同种材料平分数量
			local materialcount = math.ceil(intemNum/materiallist[j]);
			--多余的分到前面的材料
			local yushu = intemNum % materiallist[j];
			if yushu > 0 then
				materialcount = materialcount - 1;
			end
			local index = 0;
			for i,vo in ipairs(itemList) do
				if vo.id == j then
					if index >= yushu then
						list[i] = materialcount;
					else
						list[i] = materialcount + 1;
					end
					index = index + 1;
				end
			end
			
			--再次判断是否赋值
			for i,vo in ipairs(itemList) do
				if vo.id == j then
					if not list[i] then
						list[i] = materialcount;
					end
				end
			end
		end
	end
	
	return list;
end

--解析材料
function HeChengUtil:ToolParse(str)
	local list = {}
	if str ~= "" then
		local itemList = split(str,"#");
		for i,itemStr in ipairs(itemList) do
			local item = split(itemStr,",");
			local vo = RewardSlotVO:new();
			vo.id = tonumber(item[1]);
			vo.count = 0;
			vo.bind = BagConsts.Bind_None;
			table.push(list,vo:GetUIData());
		end
	end
	return list;
end

--根据道具id得到openlist
function HeChengUtil:GetHeChengTreeById(cfg,selid)
	local list = {};
	for i,vo in pairs(cfg) do
		if vo then
			table.push(list, vo);
		end
	end
	list = self:SortHeChengList(list);
	
	local openlist = {};
	for i,vo in pairs(list) do
		if vo then
			if selid == vo.id then
				for j=1,HeChengConsts.CENGMAX do
					local voceng = {};
					for k=1,j do
						voceng["label"..k] = vo["label"..k];
					end
					table.push(openlist, voceng);
				end
			end
		end
	end
	
	return openlist;
end

--得到翅膀list
function HeChengUtil:GetWingList(cfg, openlist)
	local treeData = {};
	treeData.label = "root";
	treeData.open = true;
	treeData.isShowRoot = false;
	treeData.nodes = {};
	
	local selid = 0;
	
	local list = {};
	for i,vo in pairs(cfg) do
		if vo then
			if vo.id > 1000 then
				table.push(list, vo);
			end
		end
	end
	table.sort(list,function(A,B)
		if A.id < B.id then
			return true;
		else
			return false;
		end
	end);
	
	local isget = false;
	for i,vo in pairs(list) do
		if vo then
			if isget == false then
				isget = true;
				selid = vo.id;
			end
			
			self:AddWingTreeNode(treeData, vo, 1, openlist);
		end
	end
	
	return treeData, selid;
end

function HeChengUtil:AddWingTreeNode(treeData, vo, index, openlist)
	local ishave = false;
	for i,voi in pairs(treeData.nodes) do
		if voi["label"..index] == vo["label"..index] then
			self:AddWingDataNode(voi, vo, index+1, openlist);
			ishave = true;
			break;
		end
	end
	
	if ishave == false then
		local node = {};
		node.label1 = vo["label"..index];
		node.nodes = {};
		if self:GetIsWingOpen(node, openlist) == true then
			node.open = true;
		else
			node.open = false;
		end
		node.withIcon = true;
		node.label = string.format( StrConfig['hecheng20'], vo["name"..index]);
		node.lvl = index;
		self:AddWingDataNode(node, vo, index+1, openlist);
		
		table.push(treeData.nodes, node);
	end
end

function HeChengUtil:AddWingDataNode(datavo, vo, index, openlist)
	if index >= 5 then
		return;
	end
	
	--空的
	if index < 4 then
		if not vo["name"..index] or vo["name"..index] == "" then
			self:AddWingDataNode(datavo, vo, index+1, openlist);
			return;
		end
	end
	
	local ishave = false;
	-- for i,voi in pairs(datavo.nodes) do
		-- if voi["label"..index] == vo["label"..index] then
			-- self:AddWingDataNode(voi, vo, index+1, openlist);
			-- ishave = true;
			-- break;
		-- end
	-- end
	
	if ishave == false then
		local node = {};
		for i=1,index do
			node["label"..i] = vo["label"..i];
		end
		node.nodes = {};
		node.id = vo.id;
		
		if self:GetIsWingOpen(node, openlist) == true then
			node.open = true;
		else
			node.open = false;
		end
		node.withIcon = true;
		if index == 1 then
			node.label = string.format( StrConfig['hecheng20'], vo["name"..index]);
		elseif index == 2 then
			node.label = string.format( StrConfig['hecheng18'], vo["name"..index]);
		elseif index == 3 then
			node.label = string.format( StrConfig['hecheng11'], vo["name"..index]);
		elseif index == 4 then
			local toolItem = t_item[vo.itemId];
			if not toolItem then
				toolItem = t_equip[vo.itemId];
			end
			if toolItem then
				local hechengcount = HeChengUtil:GetHeChengWingMax(vo.itemId);
				if hechengcount <= 0 then
					node.label = toolItem.name;
				else
					node.label =  string.format( StrConfig['hecheng21'], hechengcount);
				end
			end
			node.id = vo.id;
		end
		node.lvl = index;
		
		table.push(datavo.nodes, node);
	end
end

--该节点是否是打开的
function HeChengUtil:GetIsWingOpen(node, openlist)
	for i,vo in pairs(openlist) do
		if vo then
			local ishavelabel1 = false;
			local ishave = true;
			for i=1,HeChengConsts.CENGMAX do
				if i == 1 then
					--该层是第一层 并且
					if not node.id and not vo.label2 and not vo["label"..i] then
						ishave = false;
						break;
					end
				elseif i == 4 then
					if node.id then
						if vo.id then
							if node.id ~= vo.id then
								ishave = false;
							end
						else
							ishave = false;
						end
					end
				end
				
				if vo.label1 and not vo.label2 and not vo.id then
					ishavelabel1 = true;
				end
			end
			
			if ishavelabel1 == false then
				if not node.id then
					ishave = false;
				end
			end
			
			if ishave == true then
				return true;
			end
		end
	end
	
	return false;
end

--翅膀材料数量列表
function HeChengUtil:GetWingMaterialList(wingid)
	local list = {};
    local itemvo = t_wing[wingid];
	if itemvo then
		local itemList = RewardManager:ParseToVO( itemvo.compound );
		local materiallist = {};
		
		--材料数量
		for i,vo in ipairs(itemList) do
			if vo then
				if not materiallist[vo.id] then
					materiallist[vo.id] = 1;
				else
					materiallist[vo.id] = materiallist[vo.id] + 1;
				end
			end
		end
		
		--遍历每一种材料的数量
		for j,voj in pairs(materiallist) do
			local intemNum = BagModel:GetItemNumInBag(j);
			--同种材料平分数量
			local materialcount = math.ceil(intemNum/materiallist[j]);
			--多余的分到前面的材料
			local yushu = intemNum % materiallist[j];
			if yushu > 0 then
				materialcount = materialcount - 1;
			end
			local index = 0;
			for i,vo in ipairs(itemList) do
				if vo.id == j then
					if index >= yushu then
						list[i] = materialcount;
					else
						list[i] = materialcount + 1;
					end
					index = index + 1;
				end
			end
			
			--再次判断是否赋值
			for i,vo in ipairs(itemList) do
				if vo.id == j then
					if not list[i] then
						list[i] = materialcount;
					end
				end
			end
		end
	end
	
	return list;
end

--得到成功率
function HeChengUtil:GetSucRant()
	local rantnum = 0;
	for i,vo in ipairs(HeChengModel.rantitemlist) do
		if vo and vo.tid > 0 then
			rantnum = rantnum + t_item[vo.tid].use_param_1;
		end
	end
	
	return rantnum;
end

--当前能合成的数量
function HeChengUtil:GetHeChengWingMax(id)
	local hechengcount = -1;
	local cfg = t_wing[id];
	if cfg then
		local list = RewardManager:ParseToVO( cfg.compound );
		for i,vo in ipairs(list) do
			if vo then
				local intemNum = BagModel:GetItemNumInBag(vo.id);
				local count = toint(intemNum/vo.count);
				if hechengcount == -1 then
					hechengcount = count;
				elseif hechengcount > count then
					hechengcount = count;
				end
			end
		end
	end
	return hechengcount;
end

-------------------------------------合成翅膀的工具检测--------------------------------------
--adder:houxudong
--date:2016/7/31 02:18:25
--合成条件是否道具满足
function HeChengUtil:GetIsToolCanHeCheng(wingID)
	self.selid = wingID
	local itemvo = t_wing[self.selid];
	if itemvo then
		local materiallist = self:GetWingMaterialList(self.selid);
		local list = RewardManager:ParseToVO( itemvo.compound );
		for i,vo in ipairs(list) do
			if vo then
				local intemNum = materiallist[i];
				if intemNum < vo.count then
					return false;
				end
			end
		end
	end
	return true;
end

--得到是否金钱足够
function HeChengUtil:GetIsMoneyCanHeCheng(wingID)
	self.selid = wingID
	local itemvo = t_wing[self.selid];
	if itemvo then
		local playerinfo = MainPlayerModel.humanDetailInfo;
		if playerinfo.eaBindGold + playerinfo.eaUnBindGold >= itemvo.consume_money then
			return true;
		end
	end
	return false;
end


--翅膀是否可以合成检测
function HeChengUtil:WingCanHeChen( )
	local canHeChengWing = false;
	local wingIdTable= {1002,1003,1004,1005,1006,1007,1008}   --wing表有问题，后面新增翅膀找我加. note:houxudong  date:2016/7/31 2:37:25
	for i=1,#wingIdTable do
		if self:GetIsToolCanHeCheng(toint(wingIdTable[i])) and self:GetIsMoneyCanHeCheng(toint(wingIdTable[i])) then
			canHeChengWing = true
		end
		if canHeChengWing then
			return canHeChengWing;
		end
	end
	return canHeChengWing;
end

--adder:houxudong
--date:2016/7/31 19:18:00
--翅膀是否可以强化检测
function HeChengUtil:WingCanQianghua( )
	local canQianghua = false;

	local wingStarLevel = WingStarUpModel:GetWingStarLevel(); --获得当前玩家翅膀的星级
	if not wingStarLevel then wingStarLevel = 1 end
	local cfg = t_wingequip[wingStarLevel + 1];
	if not cfg then cfg = t_wingequip[#t_wingequip]; end
	local starItemCfg = split(cfg.starItem,',');
	local itemCfg = t_item[toint(starItemCfg[1])];
	if itemCfg then
		local bgItemNum = BagModel:GetItemNumInBag(itemCfg.id);
		if bgItemNum >= toint(starItemCfg[2]) and MainPlayerModel.humanDetailInfo.eaBindGold + MainPlayerModel.humanDetailInfo.eaUnBindGold >=
		cfg.gold then  --道具,金钱
			canQianghua = true;
		end
	end
	return canQianghua;
end

-- adder: houxudong
-- date: 2016/11/30 16:12:26
-- 计算合成功能是否有可以合成的物品
function HeChengUtil:CheckHechengCanDo( )
	for k,v in pairs(t_itemcompound) do
		if v.id and v.id ~= 150100002 then  --合成中不包含升星道具
			local materialitem = v.materialitem
			local consume_money = v.consume_money
			if materialitem and consume_money then
				local materialiList = split(materialitem,'#')
				for i,v in pairs(materialiList) do
					local itemId = toint(split(v,',')[1])
					local num = toint(split(v,',')[2])
					if BagModel:GetItemNumInBag(itemId) >= num and MainPlayerModel.humanDetailInfo.eaBindGold >= toint(consume_money) then
						return true
					end
				end
			end
		end
	end
	return false
end

-- adder: houxudong
-- date: 2016/12/5 12:30:26
-- 计算合成功能中是否有可以合成的丹药
function HeChengUtil:CheckCanUsePill( )
	for k,v in pairs(t_itemcompound) do
		if v.id and v.label2 == 1 then   --丹药
			local materialitem = v.materialitem
			local consume_money = v.consume_money
			if materialitem and consume_money then
				local materialiList = split(materialitem,'#')
				for i,v in pairs(materialiList) do
					local itemId = toint(split(v,',')[1])
					local num = toint(split(v,',')[2])
					if BagModel:GetItemNumInBag(itemId) >= num and MainPlayerModel.humanDetailInfo.eaBindGold >= toint(consume_money) then
						return true
					end
				end
			end	
		end
	end
	return false
end