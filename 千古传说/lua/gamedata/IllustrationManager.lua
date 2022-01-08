--
-- Author: King
-- Date: 2014-07-21 
--

local IllustrationManager = class("IllustrationManager")

IllustrationManager.IllustrationUpdate = "IllustrationUpdate"

function IllustrationManager:ctor()
	self:RegisterEvents()

	-- local qualityRoleList = self:FilterRoleList(0)
	-- -- for i=1,4 do
	-- -- 	local SamequalityRoleList = self.qualityRoleList[i]
	-- -- 	print("----------------------------")
	-- -- 	print("quality = ", i)
	-- -- 	for n=1,#SamequalityRoleList do
	-- -- 		local role = SamequalityRoleList[n]
	-- -- 		print("role id = ", role.id)
	-- -- 	end
	-- -- end

	-- -- self.qualityEquipList = self:FilterEquipList(0)
	-- -- for i=1,4 do
	-- -- 	local SamequalityRoleList = self.qualityEquipList[i]
	-- -- 	print("----------------------------")
	-- -- 	print("quality = ", i)
	-- -- 	for n=1,#SamequalityRoleList do
	-- -- 		local role = SamequalityRoleList[n]
	-- -- 		print("equip id = ", role.id)
	-- -- 	end
	-- -- end

	-- local numList = self:CountNumInList(qualityRoleList)

	-- -- for i,v in ipairs(numList) do
	-- -- 	print(i,v)
	-- -- end
end

function IllustrationManager:restart()
	if self.RoleList == nil then
		self.RoleList = {}
	end

	if self.EquipList == nil then
		self.EquipList = {}
	end
	if self.SkyBookList == nil then
		self.SkyBookList = {}
	end

end

--打开图鉴首页
function IllustrationManager:openIllustrationLayer()

	self:RequestIllustration()
	--显示
	local layer = require('lua.logic.illustration.IllustrationLayer'):new()
	AlertManager:addLayer(layer)
	AlertManager:show()

	-- 请求网络消息
end

function IllustrationManager:RegisterEvents()
	TFDirector:addProto(s2c.TUPU, self, self.onReceiveIllustration)
end

function IllustrationManager:RequestIllustration()
	showLoading()
	TFDirector:send(c2s.QUERY_TUPU_LIST, {})
end

function IllustrationManager:onReceiveIllustration(event)
	hideLoading()

	if self.RoleList == nil then
		self.RoleList = {}
	end
	local data = event.data
	--拥有过的角色id列表
	if data.roleStr and string.len(data.roleStr) > 0 then
		print("data.roleStr = ", data.roleStr)
		local RoleList = string.split(data.roleStr, ",")
		
		for i=1,#RoleList do
			local id = tonumber(RoleList[i])
			self.RoleList[id] = 1
		end
	end

	if self.EquipList == nil then
		self.EquipList = {}
	end
	--拥有过的装备ID列表	
	if data.equipStr and string.len(data.equipStr) > 0  then
		print("data.equipStr = ", data.equipStr)
		local EquipList = string.split(data.equipStr, ",")
		
		for i=1,#EquipList do
			local id = tonumber(EquipList[i])
			self.EquipList[id] = 1
		end
	end
	if self.SkyBookList == nil then
		self.SkyBookList = {}
	end
	--拥有过的装备ID列表	
	if data.bibleStr and string.len(data.bibleStr) > 0  then
		print("data.bibleStr = ", data.bibleStr)
		local SkyBookList = string.split(data.bibleStr, ",")
		
		for i=1,#SkyBookList do
			local id = tonumber(SkyBookList[i])
			self.SkyBookList[id] = 1
		end
	end

	-- 消息分发
	TFDirector:dispatchGlobalEventWith(IllustrationManager.IllustrationUpdate)
end


-- 检查是拥有过
function IllustrationManager:checkRoleIsPossess(roleid)
	if self.RoleList == nil then
		return false
	end

	if self.RoleList[roleid] == nil then
		-- print("roleid=", roleid)
		return false
	end

	return true
end

-- 通过角色类型筛选
function IllustrationManager:FilterRoleList(outline)
	local qualityRoleList = {}

	local quality 			= 1
	local key 				= 0
	for v in RoleData:iterator() do

		local curquality = v.quality
		if qualityRoleList[curquality] == nil then
			qualityRoleList[curquality] = {}
		end

		local bHave = false
		-- 检测这个是否拥有过
		if self:checkRoleIsPossess(v.id) then
			-- print("拥有该角色=", v.id)
			bHave = true
		end

		-- if v.on_show == 1 then --, show_way 
		-- 	if outline == 0 then
		-- 		table.insert(qualityRoleList[curquality], {id = v.id, quality = v.quality, isOwn = bHave})
		-- 	elseif v.outline == outline then
		-- 		table.insert(qualityRoleList[curquality], {id = v.id, quality = v.quality, isOwn = bHave})
		-- 	end
		-- end

		if v.on_show == 1 then --, show_way
			if self:roleDisplayCondition(v.id) then
				if outline == 0 then
					table.insert(qualityRoleList[curquality], {id = v.id, quality = v.quality, isOwn = bHave ,show_weight = v.show_weight or 0})
				elseif v.outline == outline then
					table.insert(qualityRoleList[curquality], {id = v.id, quality = v.quality, isOwn = bHave ,show_weight = v.show_weight or 0})
				end
			end
		end

    end

    return qualityRoleList
end

-- 检查是拥有过
function IllustrationManager:checkEquipIsPossess(Equipid)
	if self.EquipList == nil then
		return false
	end

	if self.EquipList[Equipid] == nil then
		return false
	end

	return true
end

-- 通过武器类型筛选
function IllustrationManager:FilterEquipList(kind)
	local qualityEquipList = {}

	local quality 			= 1
	local key 				= 0
	for v in ItemData:iterator() do

		local curquality = v.quality
		if qualityEquipList[curquality] == nil then
			qualityEquipList[curquality] = {}
		end

		local bHave = false
		-- 检测这个是否拥有过
		if self:checkEquipIsPossess(v.id) then
			bHave = true
			-- print("拥有该武器=", v.id)
		end

		
		if kind == 0 and v.type == 1 then
			table.insert(qualityEquipList[curquality], {id = v.id, quality = v.quality, isOwn = bHave , show_weight = v.show_weight or 0})
		elseif v.kind == kind and v.type == 1 then
			table.insert(qualityEquipList[curquality], {id = v.id, quality = v.quality, isOwn = bHave , show_weight = v.show_weight or 0})
		end
    end

    return qualityEquipList
end

-- 检查是拥有过
function IllustrationManager:checkSkyBookIsPossess(bookId)
	if self.SkyBookList == nil then
		return false
	end

	if self.SkyBookList[bookId] == nil then
		return false
	end

	return true
end
-- 通过武器类型筛选
function IllustrationManager:getSkyBookList()
	local qualitySkyBookList = {}

	for v in ItemData:iterator() do

		if v.type == 12 then
			local curquality = v.quality
			if qualitySkyBookList[curquality] == nil then
				qualitySkyBookList[curquality] = {}
			end

			local bHave = false
			if self:checkSkyBookIsPossess(v.id) then
				bHave = true
			end

			table.insert(qualitySkyBookList[curquality], {id = v.id, quality = v.quality, isOwn = bHave,show_weight = v.show_weight or 0})
		end
    end

    return qualitySkyBookList
end

-- 计算每个品质的个数
function IllustrationManager:CountNumInList(list)

	if list == nil then
		return nil
	end

	-- print("list = ", list)
	local qualityRoleNum = {}
	for i=1,(QualityHeroType.Max - 1) do
		if list[i] then
			local SamequalityList = list[i]
			local num = #SamequalityList
			if num > 0 then
				local myOwnNum = 0
				for j=1,num do
					if SamequalityList[j].isOwn == true then
						myOwnNum = myOwnNum + 1
					end
				end
				table.insert(qualityRoleNum, 1, {quality = i, number = num, curNum = myOwnNum})
			end
		end
	end

    return qualityRoleNum
end


--param = {equipId = self.equipid}) or {roleId = self.cardRoleId})
function IllustrationManager:showOutputList(param)
    local layer  = require("lua.logic.illustration.IllustrationOutPutLayer"):new(param)
    AlertManager:addLayer(layer, AlertManager.BLOCK_AND_GRAY)
    AlertManager:show()
end


function IllustrationManager:gotoProductSystem(type, mission)

-- --                       1       2        3          4       5        6          7       8        9          10        11       12        13       14     15      16    17   18       20         
-- EnumItemOutPutType = {"关卡", "群豪谱", "无量山", "摩诃崖", "护驾", "龙门镖局", "商店", "酒馆" ,"金宝箱", "银宝箱", "铜宝箱","VIP奖励","VIP礼包","活动","签到","成就","日常" , "雁门关"} 祈愿

    if type == 1 then
        local open    = MissionManager:getMissionIsOpen(mission)
        print("mission = ", mission)
        if open then
            MissionManager:showHomeToMissionLayer(mission)
        else
            -- toastMessage("关卡尚未开启")
            toastMessage(localizable.IllustrationManager_tips[type])
        end
        
    elseif type == 2 then
        if FunctionOpenConfigure:getOpenLevel(301) <= MainPlayer:getLevel() then
            -- MallManager:openQunHaoShopHome()
            ActivityManager:showLayer(ActivityManager.TAP_Arena)
        else
            -- toastMessage("群豪谱尚未开启")
            toastMessage(localizable.IllustrationManager_tips[type])
        end

    elseif type == 3 then
        if FunctionOpenConfigure:getOpenLevel(401) <= MainPlayer:getLevel() then
            -- ClimbManager:showMountainLayer()
            ActivityManager:showLayer(ActivityManager.TAP_Climb)

        else
            -- toastMessage("无量山尚未开启")
            toastMessage(localizable.IllustrationManager_tips[type])
        end

    elseif type == 4 then
        if FunctionOpenConfigure:getOpenLevel(601) <= MainPlayer:getLevel() then
            -- ClimbManager:showCarbonListLayer()
            ActivityManager:showLayer(ActivityManager.TAP_Carbon)

        else
            -- toastMessage("摩诃崖尚未开启")
            toastMessage(localizable.IllustrationManager_tips[type])
        end
    
    -- 奇遇
    elseif type == 5 or type == 6 or type == 15 then
        QiyuManager:OpenHomeLayer()


    -- 商店
    elseif type == 7 then
        -- 进入商店
        -- MallManager:openMallLayer()
        MallManager:openMallLayer(1)

    -- 酒馆
    elseif type == 8 then
        MallManager:openRecruitLayer()    

    -- vip 奖励
    elseif type == 12 then
        PayManager:showVipLayer()

    -- vip 礼包
    elseif type == 13 then
        -- 进入商店
        -- MallManager:openMallLayer()
        MallManager:openMallLayer(2)

    -- 活动
    elseif type == 14 then
        OperationActivitiesManager:openHomeLayer()

     -- 成就
    elseif type == 16 then
        TaskManager:ShowTaskLayer(1)

    -- 日常
    elseif type == 17 then
        if FunctionOpenConfigure:getOpenLevel(1001) <= MainPlayer:getLevel() then
            -- ClimbManager:showCarbonListLayer()
            TaskManager:ShowTaskLayer(0)

        else
            -- toastMessage("日常尚未开启")
            
            toastMessage(localizable.IllustrationManager_tips[type])
        end

    elseif type == 18 then
        if FunctionOpenConfigure:getOpenLevel(501) <= MainPlayer:getLevel() then
            ActivityManager:showLayer(ActivityManager.TAP_EverQuest)

        else
            -- toastMessage("雁门关尚未开启")
            toastMessage(localizable.IllustrationManager_tips[type])
        end
    elseif type == 20 then
        if FunctionOpenConfigure:getOpenLevel(2202) <= MainPlayer:getLevel() then
            -- ActivityManager:showLayer(ActivityManager.TAP_EverQuest)
            QiYuanManager:OpenQiYuanLayer()

        else
            --toastMessage("祈愿尚未开启")
            toastMessage(localizable.IllustrationManager_not_open)
        end
    elseif type == 21 then
		MallManager:openMallLayerByType(EnumMallType.AdventureMall,1)
    elseif type == 22 then
		local open = true
		local missionInfo = AdventureMissionManager:getMissionById(mission)
		if missionInfo.starLevel == MissionManager.STARLEVEL0 then
			open = false
		end
		if open then
			local layer = AdventureManager:openMissLayer()
			if layer then 
				layer:showMissionById(mission)
			end
		else
			toastMessage(localizable.Tianshu_hecheng_text4)
		end
    end
end

function IllustrationManager:roleDisplayCondition(roleid)
	local bShow = true

	-- 252 任我行
	-- 278 东方不败
	if roleid == 252 or roleid == 278 then
		local nowTime   = os.time()--MainPlayer:getNowtime()
	    local time1     = os.time({year=2016, month=2, day=12, hour=0})

	    if nowTime >= time1 then
	        bShow = true
	    else
			bShow = false
	    end
	-- elseif roleid == 280 then
	-- 	return false
	end

    return bShow
end



return IllustrationManager:new()