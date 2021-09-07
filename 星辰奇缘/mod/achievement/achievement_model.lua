AchievementModel = AchievementModel or BaseClass(BaseModel)

function AchievementModel:__init()
    self.window = nil
    self.newAchievementWindow = nil
    self.achievementTips = nil

    self.currentMain = 1
    self.currentSub = 1

    self.classList = {}
    self.typeToPageIndexList = {}
    self.pageIndexToTypeList = {}
    self.achNumMax = 0 -- 总成就点数
    self.achNum = 0 -- 已完成成就点数
    self.mainTypeNumMaxList = {} -- 该主项的总数量
    self.mainTypeNumList = {} -- 该主项的已完成数量
    self.mainTypeAchNumMaxList = {} -- 该主项的总成就点数
    self.mainTypeAchNumList = {} -- 该主项的已完成成就点数

    self.typeNumMaxList = {} -- 该子项的总数量
    self.typeNumList = {} -- 该子项的已完成数量
    self.typeAchNumMaxList = {} -- 该子项的总成就点数
    self.typeAchNumList = {} -- 该子项的已完成成就点数

	self.subTypeNumList = {} -- 该子项的可见成就总数量

    self.achievementList = {} -- 服务器发来的成就列表
    self.allAchievementList = {} -- 所有的成就列表，报错服务器没发来的数据

    self.achievement_num_of_hasreward = 0

    self.dataTypeList = {}
    self.datalist = {}
    self.pageNum = {}
    self.shop_currentMain = 1
    self.shop_currentSub = 1

    self.achievementCompleteNumber = {}
    self.attentionList = {}

    self:InitData()
    self:InitShopData()
end

function AchievementModel:InitData()
    self.classList = { {name = TI18N("总 览"), icon = "Sword", subList = {}} }
	for i = 1, #DataAchievement.data_title do
		local subData = DataAchievement.data_title[i]
		local mainData = self.classList[subData.type]
		if mainData == nil then
			mainData = { name = subData.name, icon = subData.icon, subList = {} }
			table.insert(self.classList, mainData)
		end
		table.insert(mainData.subList, { name = subData.name_2, type = subData.type_2 })
	end

    self.typeToPageIndexList = {}
    self.pageIndexToTypeList = {}
    for k1,v1 in pairs(self.classList) do
        for k2,v2 in pairs(v1.subList) do
            self.typeToPageIndexList[v2.type] = {main = k1, sub = k2}
            self.pageIndexToTypeList[string.format("%s_%s", k1, k2)] = v2.type
        end
    end

    self.achNumMax = 0
    self.mainTypeNumMaxList = {}
	self.mainTypeAchNumMaxList = {}
	self.typeNumMaxList = {}
	self.typeAchNumMaxList = {}
	for k,v in pairs(DataAchievement.data_list) do
		self.achNumMax = self.achNumMax + v.ach_num

		local num_main = self.mainTypeNumMaxList[v.type]
		local achNum_main = self.mainTypeAchNumMaxList[v.type]
		if num_main == nil then num_main = 0 end
		if achNum_main == nil then achNum_main = 0 end
		self.mainTypeNumMaxList[v.type] = num_main + 1
		self.mainTypeAchNumMaxList[v.type] = achNum_main + v.ach_num


		local num = self.typeNumMaxList[v.sec_type]
		local achNum = self.typeAchNumMaxList[v.sec_type]
		if num == nil then num = 0 end
		if achNum == nil then achNum = 0 end
		self.typeNumMaxList[v.sec_type] = num + 1
		self.typeAchNumMaxList[v.sec_type] = achNum + v.ach_num
	end
-- BaseUtils.dump(self.typeAchNumMaxList, "?????????????????????????????????????????????????????????????????self.typeAchNumMaxList")
	for k,v in pairs(DataAchievement.data_list) do
		if self:getHasRewardById(v.id) then
			self.achievement_num_of_hasreward = self.achievement_num_of_hasreward + 1
		end
	end
end

function AchievementModel:InitShopData()
    self.datalist = {[1] = {nil, nil, nil}, [2] = {nil, nil, nil}}

    self.shop_buylist = {} -- 已购买物品标记
    self.new_buy_mark = false -- 新购买物品标记

    self.pageNum = {[1] = {0, 0, 0, 0, 0}, [2] = {0, 0, 0}}

	self.dataTypeList = {
        {name = TI18N("成就兑换"), order = 1,
            subList = {
                [1] = {name = TI18N("装饰"), icon = "1", order = 1}
                , [2] = {name = TI18N("徽章"), icon = "2", order = 2}
                , [3] = {name = TI18N("气泡"), icon = "3", order = 3}
                , [4] = {name = TI18N("队标"), icon = "4", order = 4}
				, [5] = {name = TI18N("前缀"), icon = "5", order = 5}
				, [6] = {name = TI18N("足迹"), icon = "6", order = 6}
                -- , [3] = {name = TI18N("神秘商店"), icon = "mystery", lev = 40, order = 3}
            }
        }
    }

    self.goodsPanelSetting = {[1] = { [1] = {3, 142, 158, 20, 6, 1, 20}
    								, [2] = {5, 72, 72, 26, 20, 2, 10}
    								, [3] = {3, 142, 158, 20, 6, 3, 20}
    								, [4] = {3, 142, 158, 20, 6, 4, 20}
									, [5] = {3, 142, 158, 20, 6, 5, 20}
								    , [6] = {3, 142, 158, 20, 6, 6, 20}}
    						, [2] = {}}
end

function AchievementModel:__delete()
    if self.window ~= nil then
        self.window:DeleteMe()
        self.window = nil
    end
end

function AchievementModel:OpenWindow(args)
    if self.window == nil then
        self.window = AchievementView.New(self)
    end
    self.window:Open(args)
end

function AchievementModel:CloseWindow()
    if self.window ~= nil then
        self.window:DeleteMe()
        self.window = nil
    end
end

function AchievementModel:OpenNewAchievementWindow(args)
    if self.newAchievementWindow == nil then
        self.newAchievementWindow = NewAchievementView.New(self)
    end
    self.newAchievementWindow:Show(args)
end

function AchievementModel:CloseNewAchievementWindow()
    if self.newAchievementWindow ~= nil then
        self.newAchievementWindow:DeleteMe()
        self.newAchievementWindow = nil
    end
end

function AchievementModel:OpenAchievementDetailsPanel(args)
    if self.achievementDetailsPanel == nil then
        self.achievementDetailsPanel = AchievementDetailsPanel.New(self)
    end
    self.achievementDetailsPanel:Show(args)
end

function AchievementModel:CloseAchievementDetailsPanel()
    if self.achievementDetailsPanel ~= nil then
        self.achievementDetailsPanel:DeleteMe()
        self.achievementDetailsPanel = nil
    end
end

function AchievementModel:OpenAchievementTips(args)
    if self.achievementTips == nil then
        self.achievementTips = AchievementTips.New(self)
    end
    self.achievementTips:Show(args)
end

function AchievementModel:CloseAchievementTips()
    if self.achievementTips ~= nil then
        self.achievementTips:DeleteMe()
        self.achievementTips = nil
    end
end

function AchievementModel:OpenAchievementShopWindow(args)
    if self.achievementShop == nil then
        self.achievementShop = AchievementShopView.New(self)
    end
    self.achievementShop:Open(args)
end

function AchievementModel:CloseAchievementShopWindow()
    if self.achievementShop ~= nil then
        self.achievementShop:DeleteMe()
        self.achievementShop = nil
    end
end

function AchievementModel:OpenAchievementBadgeTips(args)
    if self.achievementBadgeTips == nil then
        self.achievementBadgeTips = AchievementBadgeTips.New(self)
    end
    self.achievementBadgeTips:Show(args)
end

function AchievementModel:CloseAchievementBadgeTips()
    if self.achievementBadgeTips ~= nil then
        self.achievementBadgeTips:DeleteMe()
        self.achievementBadgeTips = nil
    end
end
-----------------------------------------------------

function AchievementModel:On10219(data)
	self.achievementList = {}
	for k,v in pairs(data.achievement_list) do
		local achievementData = DataAchievement.data_list[v.id]
		if achievementData ~= nil then
			v.name = achievementData.name
			v.type = achievementData.type
			v.sec_type = achievementData.sec_type
			v.group_id = achievementData.group_id
			v.star = achievementData.star
			v.lev = achievementData.lev
			v.pre_quest =  achievementData.pre_quest
			v.desc = achievementData.desc
			v.rewards_commit = achievementData.rewards_commit
			v.honor = achievementData.honor
			v.ach_num = achievementData.ach_num
			v.end_time = achievementData.end_time
			v.iconId = achievementData.iconId
			v.uiId = achievementData.uiId
			v.sortIndex = achievementData.sortIndex
			v.hideworldlev = achievementData.hideworldlev
			v.hidenotobtained = achievementData.hidenotobtained
			v.show_details = achievementData.show_details
			self.achievementList[v.id] = v
			v.has_reward = self:getHasRewardById(v.id)
		end
	end
	self:countStar()
	self:getRedPoint()
	self:makeAllAchievement()
	self:makeProgress()
	-- BaseUtils.dump(self.achievementList, "???????????????????????????????????????")
	-- BaseUtils.dump(data, "???????????????????????????????????????")
end

function AchievementModel:On10220(data)
	for k,v in pairs(data.achievement_list) do
		local achievementData = DataAchievement.data_list[v.id]
		if achievementData ~= nil then
			v.name = achievementData.name
			v.type = achievementData.type
			v.sec_type = achievementData.sec_type
			v.group_id = achievementData.group_id
			v.star = achievementData.star
			v.lev = achievementData.lev
			v.pre_quest =  achievementData.pre_quest
			v.desc = achievementData.desc
			v.rewards_commit = achievementData.rewards_commit
			v.honor = achievementData.honor
			v.ach_num = achievementData.ach_num
			v.end_time = achievementData.end_time
			v.iconId = achievementData.iconId
			v.uiId = achievementData.uiId
			v.sortIndex = achievementData.sortIndex
			v.hideworldlev = achievementData.hideworldlev
			v.hidenotobtained = achievementData.hidenotobtained
			self.achievementList[v.id] = v
			v.has_reward = self:getHasRewardById(v.id)

			if (v.finish == 1 and self:getHasRewardById(v.id)) or (v.finish == 2 and not self:getHasRewardById(v.id) )then -- 完成成就
				local data = BaseUtils.copytab(v)
				-- print(data)
				-- BaseUtils.dump(data)
				if achievementData.donotshowpanel ~= 1 then
					if self.newAchievementWindow == nil then
						self:OpenNewAchievementWindow({ data })
						SoundManager.Instance:Play(249)
					end
					AchievementManager.Instance:Send10229(data.id)
				end
			end
		end
	end
	AchievementManager.Instance.newAchievementMark = true
	AchievementManager.Instance.newAchievementTime = BaseUtils.BASE_TIME
	-- self:countStar()
	-- self:getRedPoint()
	-- self:makeAllAchievement()
	-- self:makeProgress()
	-- AchievementManager.Instance.OnUpdateList:Fire()
end


function AchievementModel:On10226(data)
    -- BaseUtils.dump(data,"协议10226回调的数据==========================================")

	-- 服务器的坑，忽然改成只发已买的，这里打个补丁，直接填上配置信息

	-- self.datalist[1][data.shop_type] = {}
	-- for k,v in pairs(data.goods_list) do
	--     table.insert(self.datalist[1][data.shop_type], v)
	-- end

	-- 服务器说没法发这个默认数据来，客户端自己写一个填进去
	if data.shop_type == 4 then
		table.insert(data.goods_list, { id = 301, state = 1})
	elseif data.shop_type == 5 then
		table.insert(data.goods_list, { id = 401, state = 1})
	end

	local mark = {}
	for k,v in pairs(data.goods_list) do
		mark[v.id] = v
		if self.shop_buylist[v.id] == nil then
			self.new_buy_mark = true
		end
		self.shop_buylist[v.id] = { v.state, v.expire }
	end

	self.datalist[1][data.shop_type] = {}
	for k,v in pairs(DataAchieveShop.data_list) do
		if v.goods_type == data.shop_type then
			local shopData = BaseUtils.copytab(v)
		    if mark[v.id] then
		    	shopData.state = mark[v.id].state
                shopData.expire = mark[v.id].expire
                -- BaseUtils.dump(mark[v.id])
            else
                shopData.state = 0
            end
		    table.insert(self.datalist[1][data.shop_type], shopData)
		end
	end

	if #self.datalist[1] == 5 then
		self.new_buy_mark = false
	end
    -- BaseUtils.dump(self.shop_buylist,"生成的商店列表===========================================????????????????????????????????????????????????????????????????????????????????????????")
    AchievementManager.Instance.onUpdateBuyPanel:Fire()
end
------------------------------------------------------------

function AchievementModel:getAchievementByType(currentMain, currentSub)
	local list = {}
	local data = nil
	if currentMain > 1 then data = self.classList[currentMain].subList[currentSub] end
	for k,v in pairs(self.achievementList) do
		if (currentMain == 0)
			or (currentMain == 1 and currentSub == 0 and (v.finish == 1 or v.finish == 2))
			or (currentMain == 1 and currentSub == 1 and (v.finish == 0))
			or (currentMain ~= 1 and data ~= nil and v.sec_type == data.type) then
			table.insert(list, BaseUtils.copytab(v))
		end
	end

	return list
end

function AchievementModel:removeHideAchievement(list)
	local world_lev = RoleManager.Instance.world_lev
	local newList = {}
	for k,v in pairs(list) do
		if ((v.hideworldlev == 0 or world_lev <= v.hideworldlev) and v.hidenotobtained == 0) or (v.finish == 1 or v.finish == 2) then
			table.insert(newList, v)
		end
	end

	return newList
end

function AchievementModel:getAchievementPageIndex(sec_type)
	return self.typeToPageIndexList[sec_type]
end

function AchievementModel:getAchievementType(main, sub)
	return self.pageIndexToTypeList[string.format("%s_%s", main, sub)]
end

function AchievementModel:sortAchievementData(data, type)
	local function sortfun(a,b)
        return ((type == 0) and (a.finish_time > b.finish_time))
        	or ((type == 1) and ((b.finish == 1 or b.finish == 2) and (a.finish ~= 1 and a.finish ~= 2)))
        	or ((type == 2) and ((a.finish == 1 or a.finish == 2) and (b.finish ~= 1 and b.finish ~= 2)))
        	or ((type == 3) and ((b.finish == 1 or b.finish == 2) and (a.finish ~= 1 and a.finish ~= 2)))
        	or ((type == 4) and ((a.finish == 1 or a.finish == 2) and (b.finish ~= 1 and b.finish ~= 2)))
        	or ((type == 5) and (a.progress[1] ~= nil and b.progress[1] ~= nil and (a.progress[1].value / a.progress[1].target_val) > (b.progress[1].value / b.progress[1].target_val)))
        	or ((type == 1 or type == 2 or type == 3 or type == 4) and (a.finish == b.finish) and (a.sortIndex < b.sortIndex))
    end

    table.sort(data, sortfun)

    return data
end

function AchievementModel:sortAchievementDataHasReward(data)
    local list = {}

    for _, value in pairs(data) do
    	if value.finish == 1 and self:getHasRewardById(value.id) then
    		table.insert(list, value)
    	end
    end

    for _, value in pairs(data) do
    	if not (value.finish == 1 and self:getHasRewardById(value.id)) then
    		table.insert(list, value)
    	end
    end

    return list
end

function AchievementModel:sortAchievementDataAttention(data)
	local function sortfun(a,b)
        return self.attentionList[a.id] and not self.attentionList[b.id]
    end

    table.sort(data, sortfun)

    return data
end

function AchievementModel:countStar()
	self.achNum = 0
	self.mainTypeNumList = {}
	self.mainTypeAchNumList = {}
	self.typeNumList = {}
	self.typeAchNumList = {}

	self.subTypeNumList = {}

	for k,v in pairs(self.achievementList) do
		local num_main = self.mainTypeNumList[v.type]
		local achNum_main = self.mainTypeAchNumList[v.type]
		if num_main == nil then num_main = 0 self.mainTypeNumList[v.type] = 0 end
		if achNum_main == nil then achNum_main = 0 self.mainTypeAchNumList[v.type] = 0 end

		local num = self.typeNumList[v.sec_type]
		local achNum = self.typeAchNumList[v.sec_type]
		if num == nil then num = 0 self.typeNumList[v.sec_type] = 0 end
		if achNum == nil then achNum = 0 self.typeAchNumList[v.sec_type] = 0 end

		if v.finish == 1 or v.finish == 2 then

			self.achNum = self.achNum + v.ach_num
			self.mainTypeNumList[v.type] = num_main + 1
			self.mainTypeAchNumList[v.type] = achNum_main + v.ach_num
			self.typeNumList[v.sec_type] = num + 1
			self.typeAchNumList[v.sec_type] = achNum + v.ach_num
		end

		local subTypeNum = self.subTypeNumList[v.sec_type]
		if subTypeNum == nil then subTypeNum = 0 self.subTypeNumList[v.sec_type] = 0 end
		self.subTypeNumList[v.sec_type] = subTypeNum + 1
	end
end

function AchievementModel:hideByGroupId(data)
	local list = {}
	for k,v in pairs(data) do
		if list[v.group_id] == nil then
			list[v.group_id] = v
		else
			if (list[v.group_id].star < v.star and list[v.group_id].finish == 2)
				or (list[v.group_id].star > v.star and v.finish == 1) then
				list[v.group_id] = v
			end
		end
	end
	local result = {}
	for k,v in pairs(list) do
		table.insert(result, v)
	end
	return result
end

function AchievementModel:getAchievementTypeRedPoint()
	local list = {}
	for k,v in pairs(self.achievementList) do
		if v.finish == 1 and self:getHasRewardById(v.id) then
			local pageIndexData = self:getAchievementPageIndex(v.sec_type)
			list[tostring(pageIndexData.main)] = true
			list[string.format("%s_%s", pageIndexData.main, pageIndexData.sub)] = true
		end
	end
	return list
end

function AchievementModel:getHasRewardById(id)
	-- local achievementData = self.achievementList[id]
	return #DataAchievement.data_list[id].rewards_commit > 0 or DataAchievement.data_list[id].honor ~= 0 or DataAchievement.data_attr[id] ~= nil
end

function AchievementModel:getRedPoint()
	local list = self:getAchievementTypeRedPoint()
	local length = 0
	for k,v in pairs(list) do
		length = length + 1
	end
	if self:checkAchievementRewardRedPoint() then
		length = length + 1
	end

	if length > 0 then
		MainUIManager.Instance.OnUpdateIcon:Fire(7, true)
		MainUIManager.Instance.OnUpdateIcon:Fire(30, true)
		return true
	else
		MainUIManager.Instance.OnUpdateIcon:Fire(7, false)
		MainUIManager.Instance.OnUpdateIcon:Fire(30, false)
		return false
	end
end

function AchievementModel:getMaxStarAndFinishInGroup(group_id)
	local index = 0
	local maxStar = 0
	for k,v in pairs(self.achievementList) do
		if group_id == v.group_id and (v.finish == 1 or v.finish == 2) and v.star > maxStar then
			index = k
			maxStar = v.star
		end
	end

	return self.achievementList[index]
end

function AchievementModel:ShareAchievement(panelType, channel, id)
	local achievementData = self.achievementList[id]
	if achievementData ~= nil then
		local roleData = RoleManager.Instance.RoleData
		local value = 0
		local target_val = 1
		if #achievementData.progress > 0 then
			value = achievementData.progress[1].value
			target_val = achievementData.progress[1].target_val
		end
		if achievementData.finish == 1 or achievementData.finish == 2 then value = target_val end
		local sendData = string.format("{achievement_1, %s, %s, %s, %s, %s, %s, %s, %s}", achievementData.id
			, roleData.name, roleData.id, roleData.platform, roleData.zone_id
			, value, target_val, achievementData.finish_time)
	    if panelType == MsgEumn.ExtPanelType.Friend then
	        FriendManager.Instance:SendMsg(channel.id, channel.platform, channel.zone_id, sendData)
        elseif panelType == MsgEumn.ExtPanelType.Chat then
            ChatManager.Instance:SendMsg(channel, sendData)
	    elseif panelType == MsgEumn.ExtPanelType.Group then
            FriendGroupManager:SendMsg(channel.group_rid, channel.group_platform, channel.group_zone_id, sendData)
	    end
	end
end

function AchievementModel:makeAllAchievement()
	self.allAchievementList = {}
	for k,v in pairs(DataAchievement.data_list) do
		local data = self.achievementList[k]
		if data == nil then
		 	data = BaseUtils.copytab(v)
		 	data.finish = 0
		 	data.end_time = 0
		 	data.finish_time = 0
		 	data.progress = {{ id = 0
							, finish = 0
							, target = 0
							, target_val = v.progress[1].target_val
							, value = -1}}
		elseif #data.progress == 0 then
			data.progress = {{ id = 0
							, finish = 0
							, target = 0
							, target_val = v.progress[1].target_val
							, value = -1}}
		end
		self.allAchievementList[k] = data
	end
end

function AchievementModel:makeProgress()
	for k,v in pairs(self.achievementList) do
		if v.progress[1].value == -1 then
			for k2,v2 in pairs(self.achievementList) do
				if v.group_id == v2.group_id then
					v.progress[1].value = v2.progress[1].value
				end
			end
			if v.progress[1].value == -1 then
				v.progress[1].value = 0
			end
		end
	end

	for k,v in pairs(self.allAchievementList) do
		if v.progress[1].value == -1 then
			for k2,v2 in pairs(self.achievementList) do
				if v.group_id == v2.group_id then
					v.progress[1].value = v2.progress[1].value
				end
			end
			if v.progress[1].value == -1 then
				v.progress[1].value = 0
			end
		end
	end
end

function AchievementModel:getAllAchievement()
	local list = {}
	for k,v in pairs(self.allAchievementList) do
		table.insert(list, BaseUtils.copytab(v))
	end

	return list
end

function AchievementModel:getSourceId(id)
	if id == nil then return 30016 end
	local shopData = DataAchieveShop.data_list[id]
	if shopData ~= nil then
		return shopData.source_id
	end
	return 30016
end

function AchievementModel:getFootSourceId(id)
	local source_id = 0
	if id == nil or id == 0 then
		return 0
	else
		local shopData = DataAchieveShop.data_list[id]
	    if shopData ~= nil then
		    source_id = shopData.source_id
	    end
	end
	return source_id
end

function AchievementModel:getBadgeData(num)
	local data = nil
	for _,value in ipairs(DataAchievement.data_badge) do
		if num >= value.num then
			data = value
		end
	end
	return data
end

function AchievementModel:getNextBadgeData(num)
	local data = nil
	for index,value in ipairs(DataAchievement.data_badge) do
		if num >= value.num then
			data = index
		end
	end
	return DataAchievement.data_badge[data+1]
end

function AchievementModel:getBadgeSourceId(num)
	local sourceId = 20001
	for _,value in ipairs(DataAchievement.data_badge) do
		if num >= value.num then
			sourceId = value.sourceId
		end
	end
	return sourceId
end

function AchievementModel:getBadgeDesc(num)
	local desc = ""
	for _,value in ipairs(DataAchievement.data_badge) do
		if num >= value.num then
			desc = value.desc
		end
	end
	return desc
end

function AchievementModel:getBadgeDataById(id)
	for _,value in ipairs(DataAchievement.data_badge) do
		if id == value.id then
			return value
		end
	end
	return nil
end

function AchievementModel:getProgress(progress_list)
	local value = 0
	local target_val = 0
	for _,progressItem in ipairs(progress_list) do
		value = value + progressItem.value
		target_val = target_val + progressItem.target_val
	end
	return { value = value, target_val = target_val }
end

function AchievementModel:getAchievementReward()
	local list = {}
	for k,v in pairs(DataAchievement.data_badge) do
		if v.num > 0 then
			local achievement_data = self.achievementList[v.achievement_id]
			if achievement_data ~= nil and #achievement_data.rewards_commit > 0 then
				local data = {}
				data.num = v.num
				data.id = achievement_data.id
				data.rewards_commit = achievement_data.rewards_commit
				data.finish = achievement_data.finish
				table.insert(list, data)
			end
		end
	end

	return list
end

function AchievementModel:checkAchievementRewardRedPoint()
	local datalist = self:getAchievementReward()
	for i=1, #datalist do
		if datalist[i].finish == 1 then
			return true
		end
	end
	return false
end