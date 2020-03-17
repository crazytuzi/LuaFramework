--[[
武魂Util
liyuan
2014年9月27日10:12:24
]]

_G.SpiritsUtil = {};

SpiritsUtil.size = 50
SpiritsUtil.gap = 16
SpiritsUtil.startX = 106
SpiritsUtil.startY = 661
SpiritsUtil.hunzhuNum = 5
SpiritsUtil.wuhunOrderList = {}
SpiritsUtil.currentPage = 1
SpiritsUtil.pageCount = 6
SpiritsUtil.currentPageWuhuns = {}
-- 武魂列表显示
--{node.wuhunId,
-- node.iconUrl,
-- node.isFushen,
-- node.levelUrl,
-- node.nameUrl
-- node.selected
-- }
function SpiritsUtil:GetWuhunList(selectedIndex)
	self.wuhunOrderList = {};
	if selectedIndex then self:Trace('选中index'..selectedIndex) end
	
	for index, wuhunVO in pairs(SpiritsModel.wuhunList) do
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
function SpiritsUtil:GetWuhunFirst()
	if #self.wuhunOrderList > 0 then
		return self.wuhunOrderList[1].wuhunId;
	end
	
	return -1
end


function SpiritsUtil:GetTotalPageNum()
	if #self.wuhunOrderList > 0 then
		return math.ceil(#self.wuhunOrderList/SpiritsUtil.pageCount)
	end
	
	return 0
end

-- 根据页数得到武魂列表
function SpiritsUtil:GetWuhunListByPage(selectedIndex)
	local wuhunList = SpiritsUtil:GetWuhunList(selectedIndex)
	SpiritsUtil.currentPageWuhuns = {}
	local startIndex = (SpiritsUtil.currentPage - 1)*SpiritsUtil.pageCount + 1
	
	for i = startIndex, startIndex+SpiritsUtil.pageCount-1 do
		if wuhunList[i] then
			table.push(SpiritsUtil.currentPageWuhuns, wuhunList[i])
		end
	end
	
	return SpiritsUtil.currentPageWuhuns
end

function SpiritsUtil:GotoNextPage()
	if not SpiritsUtil:IsNextPage() then
		return nil
	end
	
	SpiritsUtil.currentPage = SpiritsUtil.currentPage + 1
	return true
end

function SpiritsUtil:GotoPrePage()
	if not SpiritsUtil:IsPrePage() then
		return nil
	end
	
	SpiritsUtil.currentPage = SpiritsUtil.currentPage - 1
	return true
end

function SpiritsUtil:IsPrePage()
	if SpiritsUtil.currentPage <= 1 then 
		SpiritsUtil.currentPage = 1 
		return false 
	end
	return true
end

function SpiritsUtil:IsNextPage()
	if SpiritsUtil.currentPage >= SpiritsUtil:GetTotalPageNum() then 
		SpiritsUtil.currentPage = SpiritsUtil:GetTotalPageNum() 
		return false 
	end
	return true
end

function SpiritsUtil:IsInCurrentPage(wuhunId)
	for k,v in pairs (SpiritsUtil.currentPageWuhuns) do
		if wuhunId == v.wuhunId then
			return true
		end
	end
	
	return false
end	

-- 得到武魂在列表中第一个
function SpiritsUtil:GetCurrentPageFirst()
	if #self.currentPageWuhuns > 0 then
		return self.currentPageWuhuns[1].wuhunId;
	end
	
	return -1
end

-- 武魂主动技能
--{node.iconUrl,
-- node.skillId
-- node.isUpdate}
function SpiritsUtil:GetWuhunSkillZhudong(wuhunId)
	local wuhunSkills = {};
	local cfg = t_wuhun[wuhunId];
	if cfg then
		local list = cfg.active_skill
		for index, skillId in pairs(list) do
			local skillVo = t_skill[skillId]
			if skillVo then
				local node = {}
				node.iconUrl = ResUtil:GetSkillIconUrl(skillVo.icon)
				node.isUpdate = 0
				node.skillId = skillId
				table.push(wuhunSkills, node)
			end
		end
	end
	return wuhunSkills
end

-- 武魂被动技能
--{node.iconUrl,
-- node.skillId
-- node.isUpdate}
function SpiritsUtil:GetWuhunSkillBeidong(wuhunId)
	local skillIds = t_wuhun[wuhunId].gift_skill
	local list = split(skillIds, '#')
	
	local wuhunSkills = {};
	for index, skillId in pairs(list) do
		local node = {}
		local skillVo = t_passiveskill[tonumber(skillId)]
		-- Debug("---------------------------liyuan"..skillId)
		-- trace(skillVo)
		node.iconUrl = ResUtil:GetSkillIconUrl(skillVo.icon, "54")
		node.isUpdate = 0
		node.skillId = skillId
		table.push(wuhunSkills, node)
	end
	
	return wuhunSkills
end

-- 当前选中的魂珠
function SpiritsUtil:GetSelectedWuhunPos(wuhunId)
	local index = SpiritsModel:GetWuhunIndex(wuhunId)
	-- self:Print(index)
	local x = self.startX + index * (self.size + self.gap)
	return x, self.startY, index
end

-- 激活条件是否达成
function SpiritsUtil:isActiveConditionReached(wuhunId)
	local result = true
	if self:isActiveConditionItemReached(wuhunId) == false or self:isActiveConditionLevelReached(wuhunId) == false then
		result = false
	end
		
	return result
end

function SpiritsUtil:GetActiveItemId(wuhunId)
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
function SpiritsUtil:isActiveConditionItemReached(wuhunId)
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
			local needNum = tonumber(condiList[2])
			if needNum > num then
				return false
			end
		end
	end
	
	return true
end

-- 激活等级条件是否满足
function SpiritsUtil:isActiveConditionLevelReached(wuhunId)
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
function SpiritsUtil:GetActiveConditionItem(wuhunId)
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
function SpiritsUtil:GetActiveConditionLevel(wuhunId)
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
				isReachColor = '#29CC00'
			end
			return string.format(StrConfig["wuhun6"],isReachColor,condiList[2])..isLvReach;
		end
	end
	
	return ""
end

-- 获取每次喂养的增加属性
function SpiritsUtil:GetPropertyUP(wuhunId)
	local ups = t_wuhun[wuhunId].feed_prop
	
	local list = split(ups, '#')
	if list == nil then
		list = {ups}
	end
	
	local att,def,hp,hit,dodge,critical,defcri = 0,0,0,0,0,0,0 		--攻击 防御 生命 命中 闪避 暴击 韧性
	for i, upStr in pairs(list) do
		local upList = split(upStr, ',')
		if upList[1] == 'att' then att = tonumber(upList[2])
		elseif upList[1] == 'def' then def = tonumber(upList[2])
		elseif upList[1] == 'hit' then hit = tonumber(upList[2])
		elseif upList[1] == 'hp' then hp = tonumber(upList[2])
		elseif upList[1] == 'critical' then critical = tonumber(upList[2])
		elseif upList[1] == 'dodge' then dodge = tonumber(upList[2])
		elseif upList[1] == 'defcri' then defcri = tonumber(upList[2])
		end
	end
	
	return att, def, hp, hit, dodge, critical, defcri
end

-- 由喂养次数计算出喂养所增加的属性
function SpiritsUtil:GetPropertyTotalUP(wuhunId, feedNum)
	local wuhunCfg = t_wuhun[wuhunId]
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
			local preCfg = t_wuhun[i]
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
	local attsxd, defsxd, hpsxd = SpiritsUtil:GetSpiritsSXDAttrMap();
	return totalatt + attsxd,totaldef + defsxd,totalhp + hpsxd,totalhit,totaldodge,totalcritical,totalDefcri
end

-- 获得魂珠的总的属性加成
function SpiritsUtil:GetCurrentHunzhuProperty(wuhunId, hunzhuId)
	local wuhunCfg = t_wuhun[wuhunId]
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

-- 灵兽属性丹
function SpiritsUtil:GetSpiritsSXDAttrMap()
	local attrMap = AttrParseUtil:ParseAttrToMap(t_consts[117].param);
	return attrMap["att"]*2 * SpiritsModel:GetPillNum(),attrMap["def"]*2 * SpiritsModel:GetPillNum(),attrMap["hp"]*2 * SpiritsModel:GetPillNum();
end

-- 获得下一阶武魂的属性增加值
function SpiritsUtil:GetPropertyNextUP(wuhunId, feedNum)
	local wuhunCfg = t_wuhun[wuhunId]
	if wuhunCfg.order_next == nil then
		return 0,0,0,0,0,0,0
	end
	
	local nextCfg = t_wuhun[wuhunCfg.order_next]
	local preCfg = t_wuhun[wuhunId]
	
	if not nextCfg then
		return 0,0,0,0,0,0,0
	end
	local att, def, hp, hit, dodge, critical, defcri =  nextCfg.prop_attack - wuhunCfg.prop_attack, 
														nextCfg.prop_defend - wuhunCfg.prop_defend,
														nextCfg.prop_hp - wuhunCfg.prop_hp,
														nextCfg.prop_hit - wuhunCfg.prop_hit,
														nextCfg.prop_dodge - wuhunCfg.prop_dodge,
														nextCfg.prop_critical - wuhunCfg.prop_critical,
														nextCfg.prop_defcri - wuhunCfg.prop_defcri
	-- 加成	
	local vipUPRate = VipController:GetLingshouLvUp()/100
	local atttype = ''
	local addP = 0
	
	atttype = AttrParseUtil.AttMap['att'];
	addP = MainPlayerModel.humanDetailInfo[Attr_AttrPMap[atttype]];	
	att = toint(att*(1+addP+vipUPRate))
	
	atttype = AttrParseUtil.AttMap['def'];
	addP = MainPlayerModel.humanDetailInfo[Attr_AttrPMap[atttype]];	
	def = toint(def*(1+addP+vipUPRate))
	
	atttype = AttrParseUtil.AttMap['hp'];
	addP = MainPlayerModel.humanDetailInfo[Attr_AttrPMap[atttype]];	
	hp = toint(hp*(1+addP+vipUPRate))
	
	atttype = AttrParseUtil.AttMap['hit'];
	addP = MainPlayerModel.humanDetailInfo[Attr_AttrPMap[atttype]];	
	hit = toint(hit*(1+addP+vipUPRate))
	
	atttype = AttrParseUtil.AttMap['dodge'];
	addP = MainPlayerModel.humanDetailInfo[Attr_AttrPMap[atttype]];	
	dodge = toint(dodge*(1+addP+vipUPRate))
	
	atttype = AttrParseUtil.AttMap['cri'];
	addP = MainPlayerModel.humanDetailInfo[Attr_AttrPMap[atttype]];	
	critical = toint(critical*(1+addP+vipUPRate))
	
	atttype = AttrParseUtil.AttMap['defcri'];
	addP = MainPlayerModel.humanDetailInfo[Attr_AttrPMap[atttype]];	
	defcri = toint(defcri*(1+addP+vipUPRate))
	
	return att, def, hp, hit, dodge, critical, defcri
end

function SpiritsUtil:GetFeedItemId(wuhunId)
	local feedTable = t_wuhun[wuhunId].feed_consume
	local feedItemId = feedTable[1]
	return feedItemId
end

-- 魂珠喂养的道具是否够
function SpiritsUtil:CanFeed(wuhunId, guanzhuNum)
	local feedTable = t_wuhun[wuhunId].feed_consume
	local feedItemId = feedTable[1]
	local needfeedItemNum = feedTable[2] * guanzhuNum
	local itemNum = BagModel:GetItemNumInBag(feedItemId)
	-- self:Print(itemNum ..':'..needfeedItemNum)
	if itemNum >= needfeedItemNum then
		return true
	else 
		return false
	end	
end

function SpiritsUtil:GetFeedItemNum(wuhunId, guanzhuNum)
	local feedTable = t_wuhun[wuhunId].feed_consume
	local feedItemNum = feedTable[2] * guanzhuNum
	return feedItemNum
end

function SpiritsUtil:SetWuhunPfx(roleId, wuhunId, roleAvatar, prof)
	if not wuhunId then
		return
	end
	if roleId == MainPlayerController:GetRoleID() then
		if wuhunId == 0 then
			wuhunId = SpiritsModel:GetFushenWuhunId()
		end
		-- print(debug.traceback())
		self:Print('roleId == MainPlayerController:GetRoleID()'..wuhunId)
	end
	
	if roleAvatar then
		self:RemoveWuhunFushengPfx(wuhunId, prof, roleAvatar)
	end
	self:SetWuhunFushengPfx(wuhunId, prof, roleAvatar)
end

function SpiritsUtil:SetWuhunFushengPfx(wuhunId, prof, roleAvatar)
	-- if wuhunId and wuhunId ~= 0 then
	-- 	local sknID = nil
	-- 	if t_wuhun[wuhunId] then 
	-- 		sknID = t_wuhun[wuhunId].skin 
	-- 	elseif t_wuhunachieve[wuhunId] then 
	-- 		sknID = t_wuhunachieve[wuhunId].skin 
	-- 	end
	-- 	if not sknID then return end
		
	-- 	--print("SpiritsUtil:SetWuhunFushengPfx", ">>>>>>>>>>>>>>>>>>>>>>>>>>", debug.traceback())
	-- 	local sknlistID = tonumber(prof .. string.format("%03d", sknID))
	-- 	if not _G.t_wuhunskin[sknlistID] then
	-- 		self:Print('Error:没有找到武魂皮肤的配置文件sknlistID:' .. sknlistID)
	-- 		return
	-- 	end		
	-- 	local skns = _G.t_wuhunskin[sknlistID].skn
	-- 	local liuguang = t_wuhunskin[sknlistID].liuguang
	-- 	local liuguangImage = t_wuhunskin[sknlistID].liuguang_dds
	-- 	if skns and skns ~= "" then
	-- 		local sknlist = split(skns, "#");
	-- 		for i=1, #sknlist do
	-- 			local partKeyValue = split(sknlist[i], ':')
	-- 			local skinMesh = roleAvatar:SetPart(partKeyValue[1], partKeyValue[2])
	-- 			if liuguang and liuguang ~= "" then
	-- 				local liuguangList = split(liuguang, "#")
	-- 				skinMesh:enumMesh('', true, function(mesh, name)
	-- 					mesh.isPaint = true
	-- 				end)
	-- 				skinMesh:setEnvironmentMap(_Image.new(liuguangImage), true, 1)
	-- 				skinMesh.isPaint = true
	-- 				skinMesh.blender = _Blender.new()
	-- 				skinMesh.blender:environment(0, 0, tonumber(liuguangList[1]), tonumber(liuguangList[4]), tonumber(liuguangList[5]), tonumber(liuguangList[2]), false, tonumber(liuguangList[3]))
	-- 				skinMesh.blender.playMode = _Blender.PlayPingPong
	-- 			end
	-- 		end
	-- 	end

 --        if roleAvatar.dwArmsModalID and roleAvatar.dwArmsModalID ~=0 then
 --            local wq = _G.t_wuhunskin[sknlistID].wq --武器
 --            if wq and wq ~= "" then
 --            	local pfxName = wq .. ".pfx"
 --            	roleAvatar:PlayPfxOnBone(wq, pfxName, pfxName)
 --            end
 --        end
        
 --        local dress = t_wuhunskin[sknlistID].dress --穿着
 --        local skl = t_wuhunskin[sknlistID].skl
 --        if dress and dress ~= "" then
 --        	local boneList = GetPoundTable(skl)
	--         local bonePfxList = GetPoundTable(dress)
	--         for index, bonePfx in pairs(bonePfxList) do
	--         	local pfxName = bonePfx .. ".pfx"
	--         	roleAvatar:PlayPfxOnBone(boneList[index], pfxName, pfxName)
	--         end
	--     end

	-- 	local submesh1 = t_wuhunskin[sknlistID].submesh1
	-- 	if submesh1 and submesh1 ~= "" then
	-- 		local mesh = roleAvatar:SetPart("submesh1", submesh1)
	-- 		local subskl1 = t_wuhunskin[sknlistID].subskl1
	-- 		if subskl1 and subskl1 ~= "" then
	-- 			local skeleton = mesh:attachSkeleton(subskl1)
	-- 			local subsan1 = t_wuhunskin[sknlistID].subsan1
	-- 			if subsan1 and subsan1 ~= "" then
	-- 				local anima = skeleton:addAnima(subsan1)
	-- 				anima:play()
	-- 				anima.loop = true
	-- 			end
	-- 		end
	-- 	end

	-- 	local submesh2 = t_wuhunskin[sknlistID].submesh2
	-- 	if submesh2 and submesh2 ~= "" then
	-- 		if not roleAvatar.spiritsAvatar then
	-- 			local spiritsAvatar = SpiritsAvatar:new(sknlistID)
	-- 		    roleAvatar.objMesh:addSubMesh(spiritsAvatar.objMesh)
	-- 		    roleAvatar.spiritsAvatar = spiritsAvatar
	-- 		    spiritsAvatar:SetDefAction(roleAvatar)
	-- 		end
	-- 	end
	-- end
end

function SpiritsUtil:RemoveWuhunPfx(roleId, wuhunId, roleAvatar, prof)
	-- if roleId == MainPlayerController:GetRoleID() then
	-- 	if wuhunId == 0 then
	-- 		wuhunId = SpiritsModel:GetFushenWuhunId()
	-- 	end
	-- 	if MainPlayerController:GetPlayer() then
	-- 		roleAvatar = MainPlayerController:GetPlayer():GetAvatar()
	-- 	end
	-- end
	
	-- if roleAvatar then
	-- 	self:RemoveWuhunFushengPfx(wuhunId, prof, roleAvatar)
	-- end
end

function SpiritsUtil:RemoveWuhunFushengPfx(wuhunId, prof, roleAvatar)
	-- if wuhunId and wuhunId ~= 0 then
	-- 	local sknID = nil
	-- 	if t_wuhun[wuhunId] then 
	-- 		sknID = t_wuhun[wuhunId].skin 
	-- 	elseif t_wuhunachieve[wuhunId] then 
	-- 		sknID = t_wuhunachieve[wuhunId].skin 
	-- 	end
	-- 	if not sknID then return end
		
	-- 	local sknlistID = tonumber(prof .. string.format("%03d", sknID))
	-- 	if not _G.t_wuhunskin[sknlistID] then
	-- 		self:Print('Error:没有找到武魂皮肤的配置文件sknlistID:'..sknlistID)
	-- 		return
	-- 	end
	-- 	local skns = _G.t_wuhunskin[sknlistID].skn
	-- 	if skns and skns ~= "" then
	-- 		local sknlist = split(skns, "#")
	-- 		for i=1, #sknlist do
	-- 			local partKeyValue = split(sknlist[i], ':')
	-- 			roleAvatar:SetPart(partKeyValue[1], nil)
	-- 		end
	-- 	end

 --        if roleAvatar.dwArmsModalID and roleAvatar.dwArmsModalID ~=0 then
 --            local wq = _G.t_wuhunskin[sknlistID].wq --武器
 --            if wq and wq ~= "" then
	-- 			local pfxName = wq .. ".pfx"
	--         	roleAvatar:StopPfxByName(pfxName)
 --            end
 --        end
        
 --        local dress = _G.t_wuhunskin[sknlistID].dress --穿着
 --        if dress and dress ~= "" then
	--         local bonePfxList = GetPoundTable(dress)
	--         for index, bonePfx in pairs(bonePfxList) do
	--         	local pfxName = bonePfx .. ".pfx"
	--         	roleAvatar:StopPfxByName(pfxName)
	--         end
	--     end

	-- 	local submesh1 = t_wuhunskin[sknlistID].submesh1
	-- 	if submesh1 and submesh1 ~= "" then
	-- 		roleAvatar:SetPart("submesh1", nil)
	-- 	end

	-- 	if roleAvatar.spiritsAvatar then
	-- 		roleAvatar.objMesh:delSubMesh(roleAvatar.spiritsAvatar.objMesh)
	-- 		roleAvatar.spiritsAvatar = nil
	-- 	end

	-- end
end


function SpiritsUtil:GetServerWuhunList()
	local msg = RespWuHunListResultMsg:new()
	SpiritsController:OnWuHunListResult(msg)
end

function SpiritsUtil:SetWuhunWeaponPfx(roleId)
    local mplayer = nil
    local wuhunId = 0
	if roleId == MainPlayerController:GetRoleID() then
		mplayer = MainPlayerController:GetPlayer()
		if not mplayer then self:Print('SpiritsUtil:SetWuhunFushengPfx(roleId)没有找到player'..roleId) return end
		wuhunId = SpiritsModel:GetFushenWuhunId()
	else
		mplayer = CPlayerMap:GetPlayer(roleId)
		if not mplayer then self:Print('SpiritsUtil:SetWuhunFushengPfx(roleId)没有找到player'..roleId) return end
		wuhunId = mplayer:GetWuhun()
	end
	
	self:SetWuhunFushengWeaponPfx(wuhunId, mplayer:GetPlayerInfoByType(enAttrType.eaProf), mplayer:GetAvatar())
end

function SpiritsUtil:SetWuhunFushengWeaponPfx(wuhunId, prof, roleAvatar)
    if wuhunId and wuhunId ~= 0 then
		if not t_wuhun[wuhunId] then return end
		
        local sknID = t_wuhun[wuhunId].skin
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
	            local pfxName = wq .. ".pfx"
            	roleAvatar:PlayPfxOnBone(wq, pfxName, pfxName)
	        end
        end
    end
end

function SpiritsUtil:RemoveWuhunWeaponPfx(roleId)
    local mplayer = nil
    local wuhunId = 0
    if roleId == MainPlayerController:GetRoleID() then
		mplayer = MainPlayerController:GetPlayer()
		if not mplayer then self:Print('SpiritsUtil:SetWuhunFushengPfx(roleId)没有找到player'..roleId) return end
		wuhunId = SpiritsModel:GetFushenWuhunId()
	else
		mplayer = CPlayerMap:GetPlayer(roleId)
		if not mplayer then self:Print('SpiritsUtil:SetWuhunFushengPfx(roleId)没有找到player'..roleId) return end
		wuhunId = mplayer:GetWuhun()
	end
	
	self:RemoveWuhunFushengWeaponPfx(wuhunId, mplayer:GetPlayerInfoByType(enAttrType.eaProf), mplayer:GetAvatar())
end

function SpiritsUtil:RemoveWuhunFushengWeaponPfx(wuhunId, prof, roleAvatar)
    if wuhunId and wuhunId ~= 0 then
		if not t_wuhun[wuhunId] then return end
		
        local sknID = t_wuhun[wuhunId].skin
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
			local pfxName = wq .. ".pfx"
        	roleAvatar:StopPfxByName(pfxName)
        end
        -- end
    end
end

--被动技能排序
function SpiritsUtil:GetMountSortSkill()
	local list = {};
	local skilllist = SkillUtil:GetPassiveSkillListByShow(SkillConsts.ShowType_WuHun);
	for i,skillgp in pairs(t_lingshouskill) do
		if skillgp then
			for j,vo in pairs(skilllist) do
				if skillgp.skillGroup == t_passiveskill[vo.skillId].group_id then
					list[i] = vo;
				end
			end
		end
	end
	-- FTrace(list)
	return list;
end

--获取列表VO
function SpiritsUtil:GetSkillListVO(skillId,lvl)
	local vo = {};
	vo.skillId = skillId;
	local cfg = t_passiveskill[skillId];
	if cfg then
		vo.name = cfg.name;
		vo.lvl = lvl
		vo.needItem = cfg.needItem;
		vo.needSpecail = cfg.needSpecail
		vo.effectStr = cfg.effectStr
		vo.icon = cfg.icon;
		vo.iconUrl = ResUtil:GetSkillIconUrl(cfg.icon,"");
		vo.group_id = cfg.group_id;
		
		vo.maxLvl = 0
		if t_skillgroup[cfg.group_id] then
			vo.maxLvl = t_skillgroup[cfg.group_id].maxLvl;
		end
	end
	return vo;
end

function SpiritsUtil:Print(msg)
	-- Debug("- - - - - - - - - - - - - - - - - -Liyuan:"..msg)
end

function SpiritsUtil:Trace(msgTable)
	-- Debug("- - - - - - - - - - - - - - - - - -LiyuanTable:")
	-- trace(msgTable)
end