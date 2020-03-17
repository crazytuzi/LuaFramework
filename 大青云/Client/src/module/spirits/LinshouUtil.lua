--[[
武魂皮肤Util 神兽
liyuan
2014年9月27日10:12:24
]]

_G.LinshouUtil = {};

LinshouUtil.size = 50
LinshouUtil.gap = 16
LinshouUtil.startX = 106
LinshouUtil.startY = 661
LinshouUtil.hunzhuNum = 5
LinshouUtil.wuhunOrderList = {}
LinshouUtil.currentPage = 1
LinshouUtil.pageCount = 6
LinshouUtil.currentPageWuhuns = {}
-- 武魂列表显示
--{node.wuhunId,
-- node.iconUrl,
-- node.isFushen,
-- node.levelUrl,
-- node.nameUrl
-- node.selected
-- }

function LinshouUtil:GetLinshouSkinList(openlist)
	local treeData = {};
	treeData.label = "root";
	treeData.open = true;
	treeData.isShowRoot = false;
	treeData.nodes = {};
	
	local nodeputong = {};
	nodeputong.nodes = {};
	nodeputong.label1 = 1;
	
	if self:GetIsOpen(nodeputong, openlist) == true then
		nodeputong.open = true;
	else
		nodeputong.open = false;
	end
	
	nodeputong.label = "";
	nodeputong.lvl = 1;
	nodeputong.mounttype = 1;
	
	--普通皮肤
	for i=1001,1000 + SpiritsConsts.LingshuCountMax do
		local cfgts = t_wuhunachieve[i];
		if cfgts then
			local vochild = {};
			vochild.label1 = 1;
			vochild.label2 = cfgts.id;
			vochild.id = cfgts.id;
			
			if LinshouUtil:GetLinshouTime(cfgts.id) == 0 then
				vochild.label = string.format( StrConfig["mount28"], cfgts.name );
			else
				vochild.label = string.format( StrConfig["mount27"], cfgts.name );
			end
			vochild.lvl = 2;
			if self:GetIsOpen(vochild, openlist) == true then
				vochild.open = true;
			else
				vochild.open = false;
			end
			table.push(nodeputong.nodes,vochild);
		end
	end
	table.push(treeData.nodes, nodeputong);
	
	return treeData;
end

--该节点是否是打开的
function LinshouUtil:GetIsOpen(node, openlist)
	for i,vo in pairs(openlist) do
		if vo then
			local ishave = true;
			for i=1,2 do
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

function LinshouUtil:GetLinshouTime(id)
	local list = LinshouModel:GetShenShouList();
	local vo = list[id];
	if vo then
		return vo.time;
	end
	return 0;
end

--根据神兽id得到wuhunid
function LinshouUtil:GetWuhunIdByssid(shenshouid)
	local ssvo = t_wuhunachieve[shenshouid];
	if ssvo then
		for i,vo in pairs(t_wuhun) do
			trace(vo.ui_id)
			if ssvo.ui_id == vo.ui_id then
				return vo.id;
			end
		end
	end
	return 0;
end

function LinshouUtil:GetWuhunList(selectedIndex)
	self.wuhunOrderList = {};
	for index, wuhunVO in pairs(LinshouModel.wuhunList) do
		if selectedIndex and index == selectedIndex then
			table.push(self.wuhunOrderList, self:GetWuhunListVo(wuhunVO.wuhunId, 1))
		else	
			table.push(self.wuhunOrderList, self:GetWuhunListVo(wuhunVO.wuhunId, 0))
		end
	end
	
	if #self.wuhunOrderList > 0 then
		table.sort(self.wuhunOrderList,function(A,B)
					if A.wuhunState > B.wuhunState then
						return true
					elseif A.wuhunState == B.wuhunState then
						if A.wuhunId < B.wuhunId then
							return true
						else
							return false
						end
					else
						return false
					end
		
				end)
	end

	return self.wuhunOrderList;
end

-- 得到武魂在列表中第一个
function LinshouUtil:GetWuhunFirst()
	if #self.wuhunOrderList > 0 then
		return self.wuhunOrderList[1].wuhunId;
	end
	
	return -1
end


function LinshouUtil:GetTotalPageNum()
	if #self.wuhunOrderList > 0 then
		return math.ceil(#self.wuhunOrderList/LinshouUtil.pageCount)
	end
	
	return 0
end

-- 根据页数得到武魂列表
function LinshouUtil:GetWuhunListByPage(selectedIndex)
	local wuhunList = LinshouUtil:GetWuhunList(selectedIndex)
	LinshouUtil.currentPageWuhuns = {}
	local startIndex = (LinshouUtil.currentPage - 1)*LinshouUtil.pageCount + 1
	
	for i = startIndex, startIndex+LinshouUtil.pageCount-1 do
		if wuhunList[i] then
			table.push(LinshouUtil.currentPageWuhuns, wuhunList[i])
		end
	end
	
	return LinshouUtil.currentPageWuhuns
end

function LinshouUtil:GotoNextPage()
	if not LinshouUtil:IsNextPage() then
		return nil
	end
	
	LinshouUtil.currentPage = LinshouUtil.currentPage + 1
	return true
end

function LinshouUtil:GotoPrePage()
	if not LinshouUtil:IsPrePage() then
		return nil
	end
	
	LinshouUtil.currentPage = LinshouUtil.currentPage - 1
	return true
end

function LinshouUtil:IsPrePage()
	if LinshouUtil.currentPage <= 1 then 
		LinshouUtil.currentPage = 1 
		return false 
	end
	return true
end

function LinshouUtil:IsNextPage()
	if LinshouUtil.currentPage >= LinshouUtil:GetTotalPageNum() then 
		LinshouUtil.currentPage = LinshouUtil:GetTotalPageNum() 
		return false 
	end
	return true
end

function LinshouUtil:IsInCurrentPage(wuhunId)
	for k,v in pairs (LinshouUtil.currentPageWuhuns) do
		if wuhunId == v.wuhunId then
			return true
		end
	end
	
	return false
end	

-- 得到武魂在列表中第一个
function LinshouUtil:GetCurrentPageFirst()
	if #self.currentPageWuhuns > 0 then
		return self.currentPageWuhuns[1].wuhunId;
	end
	
	return -1
end


function LinshouUtil:GetWuhunListVo(wuhunId, isSelected)
	local wuhunVO = LinshouModel:getWuhuVO(wuhunId, isSelected)

	local node = {}
		-- Debug("--------------------------"..type(wuhunVO.wuhunId)..wuhunVO.wuhunId)
	local cfg = t_wuhunachieve[wuhunVO.wuhunId]
	-- trace(cfg)
	node.wuhunId = wuhunVO.wuhunId
	-- 图标
	--self:Print('是否选中'..isSelected..'//'..wuhunId)
	node.isKejihuo = 0 
	if wuhunVO.wuhunState == 0 then
		if LinshouModel:IsActive(wuhunVO.wuhunId) then
			node.isKejihuo = 1 
		end
	end
	
	node.iconUrl1 = ResUtil:GetWuhunIcon(cfg.face_icon)
	node.iconUrl2 = ResUtil:GetWuhunIcon(cfg.face_icon..'_p')
	node.iconUrl3 = ResUtil:GetWuhunIcon(cfg.face_icon..'_d')
	
	node.selected = isSelected
	
	-- 附身图标
	if wuhunVO.wuhunState == 2 then
		node.isFushen = 1
	else
		node.isFushen = 0
	end
	
	-- 未激活等级图标
	-- Debug("------------------------"..wuhunVO.wuhunState)
	node.canActiveUrl = ''
	node.noGet = false
	if wuhunVO.wuhunState == 0 then
		local isReach = LinshouUtil:isActiveConditionReached(wuhunVO.wuhunId)
		if isReach then
			node.levelUrl = ''
			node.canActiveUrl = ResUtil:GetWuhunKejihuoIcon()
		else
			node.levelUrl = ''
			node.noGet = true
		end
	else
		-- node.levelUrl = ResUtil:GetWuhunLevelIcon(cfg.order)
	end
	
	-- 名字图标	
	node.wuhunState = wuhunVO.wuhunState	
	local uiCfg = t_lingshouui[cfg.ui_id]
	if uiCfg then
		node.nameUrl1 = ResUtil:GetWuhunIcon(uiCfg.name_icon .. "_1")
		node.nameUrl2 = ResUtil:GetWuhunIcon(uiCfg.name_icon .. "_2")
		node.nameUrl3 = ResUtil:GetWuhunIcon(uiCfg.name_icon .. "_3")
	end
	
	return node
end

-- 武魂主动技能
--{node.iconUrl,
-- node.skillId
-- node.isUpdate}
function LinshouUtil:GetWuhunSkillZhudong(wuhunId)
	local wuhunSkills = {};
	local wuhunvo = t_wuhunachieve[wuhunId];
	if wuhunvo then
		local tskill = wuhunvo.active_skill;
		local node = {}
		local skillVo = t_skill[tskill[2]]
		node.iconUrl = ResUtil:GetSkillIconUrl(skillVo.icon, "54")
		node.isUpdate = 0
		node.skillId = tskill[2]
		table.push(wuhunSkills, node)
	end
	
	return wuhunSkills
end

-- 武魂被动技能
--{node.iconUrl,
-- node.skillId
-- node.isUpdate}
function LinshouUtil:GetWuhunSkillBeidong(wuhunId)
	local skillIds = t_wuhunachieve[wuhunId].active_skillpassive
	if not skillIds or skillIds == '' then return nil end
	local list = split(skillIds, '#')
	
	local wuhunSkills = {};
	for index, skillId in pairs(list) do
		local node = {}
		local skillVo = t_passiveskill[tonumber(skillId)]
		node.iconUrl = ResUtil:GetSkillIconUrl(skillVo.icon, "54")
		node.isUpdate = 0
		node.skillId = skillId
		table.push(wuhunSkills, node)
	end
	
	return wuhunSkills
end

-- 当前选中的魂珠
function LinshouUtil:GetSelectedWuhunPos(wuhunId)
	local index = LinshouModel:GetWuhunIndex(wuhunId)
	-- self:Print(index)
	local x = self.startX + index * (self.size + self.gap)
	return x, self.startY, index
end

-- 激活条件是否达成
function LinshouUtil:isActiveConditionReached(wuhunId)
	local result = true
	if self:isActiveConditionItemReached(wuhunId) == false or self:isActiveConditionLevelReached(wuhunId) == false then
		result = false
	end
		
	return result
end

--是否有可激活的武魂
function LinshouUtil:HasActWuhun()
	local result = false
	for index, wuhunVO in pairs(LinshouModel.wuhunList) do
		if wuhunVO.wuhunState == 0 then
			if LinshouUtil:isActiveConditionReached(wuhunVO.wuhunId) then
				result = true
				break
			end
		end
	end
	
	return result
end

function LinshouUtil:GetActiveItemId(wuhunId)
	if not t_wuhunachieve[wuhunId] then return 0 end

	local conditions = t_wuhunachieve[wuhunId].active_if
	local list = split(conditions, '#')
	if list == nil then
		list = {conditions}
	end
	
	-- self:Trace(list)
	for i, condiStr in pairs(list) do
		local condiList = split(condiStr, ',')
		local itemId = tonumber(condiList[1])
		if itemId ~= nil and itemId > 1000 then
			return itemId
		end
	end
	
	return 0
end

-- 激活道具条件是否满足
function LinshouUtil:isActiveConditionItemReached(wuhunId)
	if not t_wuhunachieve[wuhunId] then return false end

	local conditions = t_wuhunachieve[wuhunId].active_if
	local list = split(conditions, '#')
	if list == nil then
		list = {conditions}
	end
	
	-- self:Trace(list)
	for i, condiStr in pairs(list) do
		local condiList = split(condiStr, ',')
		local itemId = tonumber(condiList[1])
		if itemId ~= nil and itemId > 1000 then
			local num = BagModel:GetItemNumInBag(itemId)
			local needNum = 1
			if needNum > num then
				return false
			end
		end
	end
	
	return true
end

-- 激活等级条件是否满足
function LinshouUtil:isActiveConditionLevelReached(wuhunId)
	local conditions = t_wuhunachieve[wuhunId].active_if
	local list = split(conditions, '#')
	if list == nil then
		list = {conditions}
	end
	
	--self:Trace(list)
	for i, condiStr in pairs(list) do
		local condiList = split(condiStr, ',')
		
		--self:Trace(condiList)
		if condiList[1] == 'level' then
			local needLv = tonumber(condiList[2])
			if needLv > MainPlayerModel.humanDetailInfo.eaLevel then
				return false
			end
		end
	end
	
	return true
end

-- 激活道具条件文字显示
function LinshouUtil:GetActiveConditionItem(wuhunId)
	local conditions = t_wuhunachieve[wuhunId].active_if
	local list = split(conditions, '#')
	if list == nil then
		list = {conditions}
	end
	
	--self:Trace(list)
	for i, condiStr in pairs(list) do
		local condiList = split(condiStr, ',')
		local itemId = tonumber(condiList[1])
		if itemId ~= nil and itemId > 1000 then
			local cfg = t_item[itemId]
			if not cfg then
				self:Print('没有在item表中找到数据:'..itemId)
				return ""
			end
			
			local num = BagModel:GetItemNumInBag(itemId)
			local needNum = tonumber(condiList[2])
			if needNum > num then
				return string.format(StrConfig["wuhun2"], cfg.name)..string.format(StrConfig["wuhun45"], num, condiList[2]);
			else
				return string.format(StrConfig["wuhun2"], cfg.name)..string.format(StrConfig["wuhun46"], num, condiList[2]);
			end
		end
	end
	
	return ""
end

-- 激活等级条件文字显示
function LinshouUtil:GetActiveConditionLevel(wuhunId)
	local conditions = t_wuhunachieve[wuhunId].active_if
	local list = split(conditions, '#')
	if list == nil then
		list = {conditions}
	end
	
	-- self:Trace(list)
	for i, condiStr in pairs(list) do
		local condiList = split(condiStr, ',')
		
		--self:Trace(condiList)
		if condiList[1] == 'level' then
			local needLv = tonumber(condiList[2])
			local isLvReach = StrConfig['wuhun4']--未达成
			local isReachColor = '#780000'
			if MainPlayerModel.humanDetailInfo.eaLevel >= needLv then
				isLvReach = StrConfig['wuhun5']--已达成
				isReachColor = '#236017'
			end
			return string.format(StrConfig["wuhun6"],isReachColor,condiList[2])..isLvReach;
		end
	end
	
	return ""
end

-- 获取每次喂养的增加属性
function LinshouUtil:GetPropertyUP(wuhunId)
	return 0, 0, 0, 0, 0, 0, 0
	-- local ups = t_wuhunachieve[wuhunId].feed_prop
	
	-- local list = split(ups, '#')
	-- if list == nil then
		-- list = {ups}
	-- end
	
	-- local att,def,hp,hit,dodge,critical,defcri = 0,0,0,0,0,0,0 		--攻击 防御 生命 命中 闪避 暴击 韧性
	-- for i, upStr in pairs(list) do
		-- local upList = split(upStr, ',')
		-- if upList[1] == 'att' then att = tonumber(upList[2])
		-- elseif upList[1] == 'def' then def = tonumber(upList[2])
		-- elseif upList[1] == 'hit' then hit = tonumber(upList[2])
		-- elseif upList[1] == 'hp' then hp = tonumber(upList[2])
		-- elseif upList[1] == 'critical' then critical = tonumber(upList[2])
		-- elseif upList[1] == 'dodge' then dodge = tonumber(upList[2])
		-- elseif upList[1] == 'defcri' then defcri = tonumber(upList[2])
		-- end
	-- end
	
	-- return att, def, hp, hit, dodge, critical, defcri
end

-- 由喂养次数计算出喂养所增加的属性
function LinshouUtil:GetPropertyTotalUP(wuhunId, feedNum)
	return 0, 0, 0, 0, 0, 0, 0--[[
	local wuhunCfg = t_wuhunachieve[wuhunId]
	local totalatt,totaldef,totalhp,totalhit,totaldodge,totalcritical,totalDefcri = 0,0,0,0,0,0,0 		--攻击 防御 生命 命中 闪避 暴击 韧性
	local att, def, hp, hit, dodge, critical, defcri = self:GetPropertyUP(wuhunId)
	-- 当前阶增加的属性
	totalatt,totaldef,totalhp,totalhit,totaldodge,totalcritical,totalDefcri 
		= att*feedNum,def*feedNum,hp*feedNum,hit*feedNum,dodge*feedNum,critical*feedNum,defcri*feedNum
	
	-- 以前阶增加的属性
	-- self:Print(totalatt,totaldef,totalhp,totalhit,totaldodge,totalcritical..'feedNum'..feedNum)
	-- self:Print(wuhunCfg.id)
	if 	wuhunCfg.order > 1 then
		for i = wuhunCfg.id - 1, wuhunCfg.id - wuhunCfg.order + 1, -1 do
			local preCfg = t_wuhunachieve[i]
			local preatt, predef, prehp, prehit, predodge, precritical, predefcri = self:GetPropertyUP(i)
			totalatt,totaldef,totalhp,totalhit,totaldodge,totalcritical,totalDefcri = totalatt + preatt*preCfg.feed_progress*self.hunzhuNum,
																		  totaldef + predef*preCfg.feed_progress*self.hunzhuNum,
																		  totalhp + prehp*preCfg.feed_progress*self.hunzhuNum,
																		  totalhit + prehit*preCfg.feed_progress*self.hunzhuNum,
																		  totaldodge + predodge*preCfg.feed_progress*self.hunzhuNum,
																		  totalcritical + precritical*preCfg.feed_progress*self.hunzhuNum,
																		  totalDefcri + predefcri*preCfg.feed_progress*self.hunzhuNum
			-- self:Print(totalatt,totaldef,totalhp,totalhit,totaldodge,totalcritical..'feedNum'..i)
		end
	
	end
	return totalatt,totaldef,totalhp,totalhit,totaldodge,totalcritical,totalDefcri--]]
end

-- 获得魂珠的总的属性加成
function LinshouUtil:GetCurrentHunzhuProperty(wuhunId, hunzhuId)
	local wuhunCfg = t_wuhunachieve[wuhunId]
	local totalatt,totaldef,totalhp,totalhit,totaldodge,totalcritical,totalDefcri = 0,0,0,0,0,0,0 		--攻击 防御 生命 命中 闪避 暴击 韧性
	local att, def, hp, hit, dodge, critical, defcri = self:GetPropertyUP(wuhunId)
	
	totalatt,totaldef,totalhp,totalhit,totaldodge,totalcritical,totalDefcri = att*wuhunCfg.feed_progress*hunzhuId,
																			 def*wuhunCfg.feed_progress*hunzhuId,
																			  hp*wuhunCfg.feed_progress*hunzhuId,
																			 hit*wuhunCfg.feed_progress*hunzhuId,
																		   dodge*wuhunCfg.feed_progress*hunzhuId,
																		critical*wuhunCfg.feed_progress*hunzhuId,
																		defcri*wuhunCfg.feed_progress*hunzhuId
	-- self:Print(totalatt..totaldef..totalhp..totalhit..totaldodge..totalcritical)						
	return totalatt,totaldef,totalhp,totalhit,totaldodge,totalcritical,totalDefcri
end

-- 获得下一阶武魂的属性增加值
function LinshouUtil:GetPropertyNextUP(wuhunId)
	local wuhunCfg = t_wuhunachieve[wuhunId]
	if wuhunCfg.order_next == nil then
		return 0,0,0,0,0,0,0
	end
	
	local nextCfg = t_wuhunachieve[wuhunCfg.order_next]
	
	if not nextCfg then
		return 0,0,0,0,0,0,0
	end
	local att, def, hp, hit, dodge, critical, defcri =  nextCfg.prop_attack - wuhunCfg.prop_attack, 
														nextCfg.prop_defend - wuhunCfg.prop_defend,
														nextCfg.prop_hp - wuhunCfg.prop_hp,
														nextCfg.prop_critical - wuhunCfg.prop_critical,
														nextCfg.prop_dodge - wuhunCfg.prop_dodge,
														nextCfg.prop_hit - wuhunCfg.prop_hit,
														nextCfg.prop_defcri - wuhunCfg.prop_defcri
												
	return att, def, hp, hit, dodge, critical, defcri
end

function LinshouUtil:GetFeedItemId(wuhunId)
	local feedTable = t_wuhunachieve[wuhunId].feed_consume
	local feedItemId = feedTable[1]
	return feedItemId
end

-- 魂珠喂养的道具是否够
function LinshouUtil:CanFeed(wuhunId, guanzhuNum)
	local feedTable = t_wuhunachieve[wuhunId].feed_consume
	local feedItemId = feedTable[1]
	local needfeedItemNum = feedTable[2] * guanzhuNum
	local itemNum = BagModel:GetItemNumInBag(feedItemId)
	self:Print(itemNum ..':'..needfeedItemNum)
	if itemNum >= needfeedItemNum then
		return true
	else 
		return false
	end	
end

function LinshouUtil:GetFeedItemNum(wuhunId, guanzhuNum)
	local feedTable = t_wuhunachieve[wuhunId].feed_consume
	local feedItemNum = feedTable[2] * guanzhuNum
	return feedItemNum
end

function LinshouUtil:SetWuhunPfx(roleId, wuhunId, roleAvatar, prof)
	if roleId == MainPlayerController:GetRoleID() then
		if wuhunId == 0 then
			wuhunId = SpiritsModel:GetFushenWuhunId()
		end
		
		self:Print('roleId == MainPlayerController:GetRoleID()'..wuhunId)
	end
	
	if roleAvatar then
		self:RemoveWuhunFushengPfx(wuhunId, prof, roleAvatar)
	end
	self:SetWuhunFushengPfx(wuhunId, prof, roleAvatar)
end

function LinshouUtil:SetWuhunFushengPfx(wuhunId, prof, roleAvatar)
	if wuhunId and wuhunId ~= 0 then
		local sknID = nil
		if t_wuhunachieve[wuhunId] then 
			sknID = t_wuhunachieve[wuhunId].skin 
		elseif t_wuhunachieve[wuhunId] then 
			sknID = t_wuhunachieve[wuhunId].skin 
		end
		if not sknID then return end
		
		print("LinshouUtil:SetWuhunFushengPfx", ">>>>>>>>>>>>>>>>>>>>>>>>>>")
		local sknlistID = tonumber(prof .. string.format("%03d", sknID))
		if not _G.t_wuhunskin[sknlistID] then
			self:Print('Error:没有找到武魂皮肤的配置文件sknlistID:' .. sknlistID)
			return
		end		
		local skns = _G.t_wuhunskin[sknlistID].skn
		if skns and skns ~= "" then
			local sknlist = GetPoundTable(skns)
			for i=1, #sknlist do
				local partKeyValue = split(sknlist[i], ':')
				roleAvatar:SetPart(partKeyValue[1], partKeyValue[2])
			end
		end

        if roleAvatar.dwArmsModalID and roleAvatar.dwArmsModalID ~=0 then
            local wq = _G.t_wuhunskin[sknlistID].wq --武器
            if wq and wq ~= "" then
            	local pfxName = string.sub(wq, 3) .. ".pfx"
            	roleAvatar:PlayPfxOnBone(wq, pfxName, pfxName)
            end
        end
        
        local dress = t_wuhunskin[sknlistID].dress --穿着
        local skl = t_wuhunskin[sknlistID].skl
        if dress and dress ~= "" then
        	local boneList = GetPoundTable(skl)
	        local pfxList = GetPoundTable(dress)
	        for index, bonePfx in pairs(pfxList) do
	        	local pfxName = bonePfx .. ".pfx"
	        	roleAvatar:PlayPfxOnBone(boneList[index], pfxName, pfxName)
	        end
	    end

		local submesh1 = t_wuhunskin[sknlistID].submesh1
		if submesh1 and submesh1 ~= "" then
			local mesh = roleAvatar:SetPart("submesh1", submesh1)
			local subskl1 = t_wuhunskin[sknlistID].subskl1
			if subskl1 and subskl1 ~= "" then
				local skeleton = mesh:attachSkeleton(subskl1)
				local subsan1 = t_wuhunskin[sknlistID].subsan1
				if subsan1 and subsan1 ~= "" then
					local anima = skeleton:addAnima(subsan1)
					anima:play()
					anima.loop = true
				end
			end
		end

		local submesh2 = t_wuhunskin[sknlistID].submesh2
		if submesh2 and submesh2 ~= "" then
			if not roleAvatar.spiritsAvatar then
				local spiritsAvatar = SpiritsAvatar:new(sknlistID)
			    roleAvatar.objMesh:addSubMesh(spiritsAvatar.objMesh)
			    roleAvatar.spiritsAvatar = spiritsAvatar
			    spiritsAvatar:SetDefAction(roleAvatar)
			end
		end
	end
end

function LinshouUtil:RemoveWuhunPfx(roleId, wuhunId, roleAvatar, prof)
	if roleId == MainPlayerController:GetRoleID() then
		if wuhunId == 0 then
			wuhunId = SpiritsModel:GetFushenWuhunId()
		end
		if MainPlayerController:GetPlayer() then
			roleAvatar = MainPlayerController:GetPlayer():GetAvatar()
		end
	end
	
	if roleAvatar then
		self:RemoveWuhunFushengPfx(wuhunId, prof, roleAvatar)
	end
end

function LinshouUtil:RemoveWuhunFushengPfx(wuhunId, prof, roleAvatar)
	if wuhunId and wuhunId ~= 0 then
		local sknID = nil
		if t_wuhunachieve[wuhunId] then 
			sknID = t_wuhunachieve[wuhunId].skin 
		elseif t_wuhunachieve[wuhunId] then 
			sknID = t_wuhunachieve[wuhunId].skin 
		end
		if not sknID then return end
		
		local sknlistID = tonumber(prof .. string.format("%03d", sknID))
		if not _G.t_wuhunskin[sknlistID] then
			self:Print('Error:没有找到武魂皮肤的配置文件sknlistID:'..sknlistID)
			return
		end
		local skns = _G.t_wuhunskin[sknlistID].skn
		if skns and skns ~= "" then
			local sknlist = GetPoundTable(skns)
			for i=1, #sknlist do
				local partKeyValue = split(sknlist[i], ':')
				roleAvatar:SetPart(partKeyValue[1], nil)
			end
		end

        if roleAvatar.dwArmsModalID and roleAvatar.dwArmsModalID ~=0 then
            local wq = _G.t_wuhunskin[sknlistID].wq --武器
            if wq and wq ~= "" then
				local pfxName = string.sub(wq, 3) .. ".pfx"
	        	roleAvatar:StopPfxByName(pfxName)
            end
        end
        
        local dress = _G.t_wuhunskin[sknlistID].dress --穿着
        if dress and dress ~= "" then
	        local bonePfxList = GetPoundTable(dress)
	        for inde, bonePfx in pairs(bonePfxList) do
	        	local pfxName = bonePfx .. ".pfx"
	        	roleAvatar:StopPfxByName(pfxName)
	        end
	    end

		local submesh1 = t_wuhunskin[sknlistID].submesh1
		if submesh1 and submesh1 ~= "" then
			roleAvatar:SetPart("submesh1", nil)
		end

		if roleAvatar.spiritsAvatar then
			roleAvatar.objMesh:delSubMesh(roleAvatar.spiritsAvatar.objMesh)
			roleAvatar.spiritsAvatar = nil
		end

	end
end


function LinshouUtil:GetServerWuhunList()
	local msg = RespWuHunListResultMsg:new()
	SpiritsController:OnWuHunListResult(msg)
end

function LinshouUtil:SetWuhunWeaponPfx(roleId)
    local mplayer = nil
    local wuhunId = 0
	if roleId == MainPlayerController:GetRoleID() then
		mplayer = MainPlayerController:GetPlayer()
		if not mplayer then self:Print('LinshouUtil:SetWuhunFushengPfx(roleId)没有找到player'..roleId) return end
		wuhunId = SpiritsModel:GetFushenWuhunId()
	else
		mplayer = CPlayerMap:GetPlayer(roleId)
		if not mplayer then self:Print('LinshouUtil:SetWuhunFushengPfx(roleId)没有找到player'..roleId) return end
		wuhunId = mplayer:GetWuhun()
	end
	
	self:SetWuhunFushengWeaponPfx(wuhunId, mplayer:GetPlayerInfoByType(enAttrType.eaProf), mplayer:GetAvatar())
end

function LinshouUtil:SetWuhunFushengWeaponPfx(wuhunId, prof, roleAvatar)
    if wuhunId and wuhunId ~= 0 then
		if not t_wuhunachieve[wuhunId] then return end
		
        local sknID = t_wuhunachieve[wuhunId].skin
        local sknlistID = tonumber(prof .. string.format("%03d", sknID))
        --Debug("################### ", sknlistID)

        if not _G.t_wuhunskin[sknlistID] then
            self:Print('Error:没有找到武魂皮肤的配置文件sknlistID:'..sknlistID)
            return
        end
		--Debug("###################roleAvatar.dwArmsModalID ", roleAvatar.dwArmsModalID)
        if roleAvatar.dwArmsModalID and roleAvatar.dwArmsModalID ~=0 then
            local wq = _G.t_wuhunskin[sknlistID].wq --武器
            --Debug("######wq: ", wq)
            if wq and wq ~= "" then
	            local pfxName = string.sub(wq, 3) .. ".pfx"
            	roleAvatar:PlayPfxOnBone(wq, pfxName, pfxName)
	        end
        end
    end
end

function LinshouUtil:RemoveWuhunWeaponPfx(roleId)
    local mplayer = nil
    local wuhunId = 0
    if roleId == MainPlayerController:GetRoleID() then
		mplayer = MainPlayerController:GetPlayer()
		if not mplayer then self:Print('LinshouUtil:SetWuhunFushengPfx(roleId)没有找到player'..roleId) return end
		wuhunId = SpiritsModel:GetFushenWuhunId()
	else
		mplayer = CPlayerMap:GetPlayer(roleId)
		if not mplayer then self:Print('LinshouUtil:SetWuhunFushengPfx(roleId)没有找到player'..roleId) return end
		wuhunId = mplayer:GetWuhun()
	end
	
	self:RemoveWuhunFushengWeaponPfx(wuhunId, mplayer:GetPlayerInfoByType(enAttrType.eaProf), mplayer:GetAvatar())
end

function LinshouUtil:RemoveWuhunFushengWeaponPfx(wuhunId, prof, roleAvatar)
    if wuhunId and wuhunId ~= 0 then
		if not t_wuhunachieve[wuhunId] then return end
		
        local sknID = t_wuhunachieve[wuhunId].skin
        local sknlistID = tonumber(prof .. string.format("%03d", sknID))
       -- Debug("################### ", sknlistID)

        if not _G.t_wuhunskin[sknlistID] then
            self:Print('Error:没有找到武魂皮肤的配置文件sknlistID:'..sknlistID)
            return
        end

        -- if roleAvatar.dwArmsModalID and roleAvatar.dwArmsModalID ~=0 then
        local wq = _G.t_wuhunskin[sknlistID].wq --武器
        --Debug("x######wq: ", wq)
        if wq and wq ~= "" then
			local pfxName = string.sub(wq, 3) .. ".pfx"
        	roleAvatar:StopPfxByName(pfxName)
        end
        -- end
    end
end

_G.FPrint = function(outStr)
	-- Debug("- - - - - - - - - - - - - - - - - -Liyuan:"..outStr)
end

_G.FTrace = function(outTable, outStr)
	-- local outMsg = "- - - - - - - - - - - - - - - - - -LiyuanTable:"
	-- if outStr then outMsg = outMsg .. outStr end
	-- Debug(outMsg)
	-- trace(outTable)
end

