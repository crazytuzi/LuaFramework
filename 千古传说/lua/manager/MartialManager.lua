--[[
	武学管理器，实现了武学系统相关模块的绝大部分逻辑，包括网络相关
	-- @author david.dai
	-- @date 2015/4/20
]]

local MartialManager = class("MartialManager")


local ResetData  = require('lua.table.t_s_reset_consume')
local SweepData  = require('lua.table.t_s_sweep')

MartialManager.MSG_MartialSynthesis  	= "MartialManager.MSG_MartialSynthesis"	-- 合成成功
MartialManager.MSG_MartialLearn  		= "MartialManager.MSG_MartialLearn"	-- 合成习得
MartialManager.MSG_MartialLevelUp   	= "MartialManager.MSG_MartialLevelUp"	-- 进阶
MartialManager.MSG_MartialEnchant   	= "MartialManager.MSG_MartialEnchant"	-- 附魔
MartialManager.OneKeyEquipMartialResult   	= "MartialManager.OneKeyEquipMartialResult"	-- 附魔

function MartialManager:ctor(data)
	TFDirector:addProto(s2c.EQUIP_MARTIAL_RESULT, self, self.onEquipMartial)
	TFDirector:addProto(s2c.SINGLE_MARTIAL_UPDATE, self, self.onSingleMartialUpdate)
	TFDirector:addProto(s2c.ROLE_MARTIAL_LIST, self, self.onRoleMartialListUpdate)
	TFDirector:addProto(s2c.ALL_MARTIAL_LIST, self, self.onAllMartialListUpdate)
	TFDirector:addProto(s2c.MARTIAL_LEVEL_UP_NOTIFY, self, self.onMartialLevelUp)
	TFDirector:addProto(s2c.MARTIAL_SYNTHESIS_RESULT, self, self.onMartialSynthesis)
	TFDirector:addProto(s2c.ONE_KEY_ENCHANT_SUCCESS, self, self.onMartialEnchantOneKey)
	TFDirector:addProto(s2c.ONE_KEY_EQUIP_MARTIAL_RESULT, self, self.OneKeyEquipMartialResult)
    self.quick_need_money_tip = CCUserDefault:sharedUserDefault():getBoolForKey("quick_need_money_tip");
end

function MartialManager:restart()

end

--[[
请求服务器装备武学
@roleInstance 角色实例，队友实例
@martialTemplate 武学信息配置，武学模版
@position 装备的位置
@autoSynthesis 是否自动合成，如果需要自动合成为true，否则为false
@return 是否可以装备，如果返回true则表示可以装备，并且已经发送请求到服务器，如果返回false则表示本地客户端验证不可装备
]]
function MartialManager:requestEquip(roleInstance,martialTemplate,position,autoSynthesis)
	local canEquip = roleInstance:isCanEquipMartial(martialTemplate,position)
	if not canEquip then
		return false
	end

	autoSynthesis = autoSynthesis or false
	local msg ={
		roleInstance.gmId,
		martialTemplate.id,
		position,
		autoSynthesis
	}
	showLoading()
	TFDirector:send(c2s.REQUEST_EQUIP_MARTIAL,msg)
	return true
end


--[[
请求服务器装备武学

]]
function MartialManager:requestEquip_Ext(rolegmId, bookid, position)
	local martialTemplate = MartialData:objectByID(bookid)

	local roleInstance = CardRoleManager:getRoleByGmid(rolegmId)

	-- print("martialTemplate = ", martialTemplate)
	-- print("roleInstance = ", roleInstance)
	-- print("position = ", position)
	-- print("bookid = ", bookid)
	TFDirector:dispatchGlobalEventWith("EquipmentChangeBegin",{})
	return self:requestEquip(roleInstance,martialTemplate,position,false)
end


--[[
收到此消息表示装备成功
@event 网络数据
]]
function MartialManager:onEquipMartial(event)
	hideLoading()
	local martialTemplate = MartialData:objectByID(event.data.martialId)
	if not martialTemplate then
		toastMessage("找不到武学数据 ： " .. event.data.martialId)
		return
	end

	local roleInstance = CardRoleManager:getRoleByGmid(event.data.roleId)
	roleInstance:addMartial(martialTemplate,event.data.position)
	--需要更新角色属性
	roleInstance:refreshMartial()

	TFDirector:dispatchGlobalEventWith("EquipmentChangeEnd",{})



	-- 学习武学成功
	TFDirector:dispatchGlobalEventWith(self.MSG_MartialLearn, {bookIndex = event.data.position})

	-- print("MartialManager:onEquipMartial martialList = ", roleInstance.martialList)
end

--[[
更新单个武学信息
@event 网络数据
]]
function MartialManager:onSingleMartialUpdate(event)
	hideLoading()
	MartialManager:updateMartialInstance(event.data.roleId,event.data.martial)


	TFDirector:dispatchGlobalEventWith(self.MSG_MartialEnchant, {})
end

--[[
更新武学实例信息
@roleId 角色id
@info 武学信息
]]
function MartialManager:updateMartialInstance(roleId,info)
	local roleInstance = CardRoleManager:getRoleByGmid(roleId)
	if not roleInstance then
		toastMessage("role [" .. roleId .. "] not found.")
		return
	end

	local martialInstance = roleInstance:findMartialByPosition(info.position)
	

	if not martialInstance then
		-- toastMessage("martial instance not found./n"..info)
		print("MartialManager:info = ", info)
		return
	end

	martialInstance.enchantLevel = info.enchantLevel
	martialInstance.enchantProgress = info.enchantProgress

	roleInstance:refreshMartial()

	TFDirector:dispatchGlobalEventWith(self.MSG_MartialEnchant, {})
end

--[[
添加或者更新武学实例
@roleId 角色id
@info 武学信息
]]
function MartialManager:addOrUpdateMartialInstance(roleId,info)
	local roleInstance = CardRoleManager:getRoleByGmid(roleId)
	if not roleInstance then
		toastMessage("role [" .. roleId .. "] not found.")
		return
	end

	local martialInstance = roleInstance:findMartialByPosition(info.position)
	if not martialInstance then
		local martialTemplate = MartialData:objectByID(info.id)
		if not martialTemplate then
			toastMessage("找不到武学数据 ： " .. info.id)
			return
		end
		martialInstance = roleInstance:addMartial(martialTemplate,info.position)
	end

	martialInstance.enchantLevel = info.enchantLevel
	martialInstance.enchantProgress = info.enchantProgress

end

--[[
更新一个角色所有武学信息
@event 网络数据
]]
function MartialManager:onRoleMartialListUpdate(event)
	hideLoading()
	local roleId = event.data.roleId
	MartialManager:updateRoleMartialList(roleId,event.data.martialLevel,event.data.martialInfo)
end

--[[
更新角色武学列表
@roleId 角色实例id
@martialLevel 角色武学等级
@martialList 武学列表
]]
function MartialManager:updateRoleMartialList(roleId,martialLevel,martialList)
	local roleInstance = CardRoleManager:getRoleByGmid(roleId)
	if not roleInstance then
		toastMessage("role [" .. roleId .. "] not found.")
		return
	end

	roleInstance.martialLevel = martialLevel
	if martialList then
		for k,v in pairs(martialList) do
			MartialManager:addOrUpdateMartialInstance(roleId,v)
		end
	end
	roleInstance:refreshMartial()
end

--[[
更新所有角色所有武学信息
@event 网络数据
]]
function MartialManager:onAllMartialListUpdate(event)
	hideLoading()
	for k,v in pairs(event.data.roleMartial) do
		MartialManager:updateRoleMartialList(v.roleId,v.martialLevel,v.martialInfo)
	end
end

--[[
请求武学升级
@roleInstance 角色实例
]]
function MartialManager:requestMartialLevelUp(roleInstance)
	showLoading()
	local msg = {
		roleInstance.gmId
	}

	TFDirector:dispatchGlobalEventWith("EquipmentChangeBegin",{})
	TFDirector:send(c2s.REQUEST_MARTIAL_LEVEL_UP, msg)
end

--[[
武学等级提升
@event 网络数据
]]
function MartialManager:onMartialLevelUp(event)
	hideLoading()
	local roleId = event.data.roleId
	local martialLevel = event.data.martialLevel

	local roleInstance = CardRoleManager:getRoleByGmid(roleId)
	if not roleInstance then
		toastMessage("role [" .. roleId .. "] not found.")
		return
	end

	roleInstance.martialLevel = martialLevel
	roleInstance.martialList = {}
	-- local newQuality = self:getQuality(martialLevel)
	-- if newQuality > roleInstance.quality then
	-- 	roleInstance.quality = newQuality
	-- end
	roleInstance:refreshMartial()
	TFAudio.playEffect("sound/effect/martial.mp3",false)
	-- TFDirector:dispatchGlobalEventWith("EquipmentChangeEnd",{})
	-- 武学进阶
	TFDirector:dispatchGlobalEventWith(self.MSG_MartialLevelUp, {})
end

--[[
获取武学等级对应的品质
]]
function MartialManager:getQuality(martialLevel)
	if martialLevel < 2 then
		return QualityType.Ding
	elseif martialLevel < 4 then
		return QualityType.Bing
	elseif martialLevel < 7 then
		return QualityType.Yi
	end
	return QualityType.Jia
end

--[[
请求合成武学
@martialId 将要合成生成的武学id，对应t_s_martial表格定义的id
]]
function MartialManager:requestMartialSynthesis(martialId)
	showLoading()
	local msg = {
		martialId,
		true	--是否自动合成，如果是，将自动由服务器合成其所有子级材料
	}
	TFDirector:send(c2s.REQUEST_MARTIAL_SYNTHESIS,msg)
end

--[[
武学合成
@event 网络数据
]]
function MartialManager:onMartialSynthesis(event)
	-- print("event = ", event.data)
	hideLoading()
	TFDirector:dispatchGlobalEventWith(self.MSG_MartialSynthesis, {})
	local item = ItemData:objectByID(event.data.martialId)
	if item then
		toastMessage(item.name .. "合成成功")
	end
end

--[[
请求武学附魔
@martialInstance 武学实例
@materials 材料，table表，每个元素{id,数量}
]]
function MartialManager:requestMartialEnchant(martialInstance,materials)
	showLoading()
	local msg = {
		martialInstance.roleId,
		martialInstance.position,
		materials
	}
	
	TFDirector:send(c2s.REQUEST_MARTIAL_ENCHANT,msg)
end

--[[
请求武学附魔
@martialInstance 武学实例
@materials 材料，table表，每个元素{id,数量}
]]
function MartialManager:requestMartialEnchantOneKey(roleId, bookPosition)
	
	showLoading()
	local msg = {
		roleId,
		bookPosition
	}
		-- RequestOneKeyEnchant
	TFDirector:send(c2s.REQUEST_ONE_KEY_ENCHANT,msg)
end

function MartialManager:onMartialEnchantOneKey(event)
	-- print("event = ", event)
	hideLoading()
	local roleId = event.data.roleId
	local roleInstance = CardRoleManager:getRoleByGmid(roleId)
	if not roleInstance then
		toastMessage("role [" .. roleId .. "] not found.")
		return
	end
	roleInstance:refreshMartial()
	TFDirector:dispatchGlobalEventWith(self.MSG_MartialSynthesis, {})
	-- toastMessage("Synthesis Success , product : [" .. event.data.martialId .. "]")
end



--[[
判断是否有足够材料合成
@martialId 合成目标武学id
@num 个数
@return 如果有足够材料合成此目标武学返回true，否则返回false
]]
function MartialManager:isCanSynthesisById(martialId,num)
	local martialTemplate = MartialData:objectByID(martialId)
	if not martialTemplate then
		return false,0
	end

	return self:isCanSynthesis(martialTemplate,num)
end

--[[
判断是否有足够材料合成
@martialTemplate 合成目标武学
@num 个数
@return 如果有足够材料合成此目标武学返回true，否则返回false
]]
function MartialManager:isCanSynthesis(martialTemplate,num)

	local material,index = martialTemplate:getMaterialTable()


	if not material then 			--不可合成
		return false,0
	end

	local materialNum = 0
	local totalCost   = martialTemplate.copper

	-- print("material = ",material)
	-- print("num = ",num)
	
	--多态适配，没有指定参数则为1
	num = num or 1
	for k,v in pairs(material) do

		materialNum = materialNum + 1
		local holdGoods = BagManager:getItemById(k)
		local needNum = v * num

		-- if not holdGoods or holdGoods.num < needNum then
		-- 	local canMerge = self:isCanSynthesisById(k, needNum - holdGoods.num)
		-- 	if not canMerge then
		-- 		return false
		-- 	end
		-- else
		-- 	local canMerge = self:isCanSynthesisById(k, needNum - 0)
		-- 	if not canMerge then
		-- 		return false
		-- 	end
		-- end

		local curNum = 0
		if holdGoods then
			curNum = holdGoods.num
		end

		if needNum > curNum then
			local canMerge,copper = self:isCanSynthesisById(k, needNum - curNum)
			if not canMerge then
				return false,totalCost
			end
			copper = copper or 0

			totalCost = totalCost + copper
		end
	end

	-- 没有材料列表 则无法合成
	if materialNum == 0 then
		return false,totalCost
	end

	return true,totalCost
end

-- 该角色是否有书可以穿在身上
function MartialManager:isHaveBook(cardRole)
    if cardRole == nil then 
        return false
    end

    -- 武学等级
    local martialLevel = cardRole.martialLevel
    local martialList  = cardRole.martialList
    local bookListData = MartialRoleConfigure:findByRoleIdAndMartialLevel(cardRole.id, martialLevel)

    local bookList     = bookListData:getMartialTable()
    for i=1, 6 do
        local status = self:isBookOnThisPosition(i, cardRole.level, bookList, martialList)

        if status == true then
            return true
        end
    end

    return false
end

function MartialManager:isBookOnThisPosition(index, roleLevel, bookList, martialList)

    local bookid   = bookList[index]
    local bookInfo = MartialData:objectByID(bookid)

    -- 该位置有书装备
    if martialList[index] == nil then

        local status = self:getBookStatus(bookInfo, roleLevel)

        if status ==  1 or status == 3 then

            return true
        end
    end


    return false
end

function MartialManager:getBookStatus(bookInfo, Level)
    
    -- 0 不存在
    -- 1 背包存在并且可以穿戴
    -- 2 背包存在并且不可以穿戴
    -- 3 可以合成并且可以穿戴
    -- 4 可以合成并且不可以穿戴
    local bookStatus = 0

    local roleLevel = Level
    local id        = bookInfo.goodsTemplate.id
    local bag       = BagManager:getItemById(id)
    local bookLevel = bookInfo.goodsTemplate.level

    -- 背包中存在
    if bag then
        bookStatus = 1
    else
        if self:isCanSynthesisById(id, 1) then
            bookStatus = 3
        end
    end

    -- 穿戴等级
    -- 有物品 才判断等级
    if bookLevel > roleLevel and bookStatus > 0 then
        bookStatus = bookStatus + 1
    end

    return bookStatus
end

--秘籍是否能被上阵的角色穿戴 2015-9-14
function MartialManager:bookIsCanBeLearn(cardRole, bookId)
    if cardRole == nil then 
        return false
    end

    local roleLevel = cardRole.level

    -- 武学等级
    local martialLevel = cardRole.martialLevel
    local martialList  = cardRole.martialList
    local bookListData = MartialRoleConfigure:findByRoleIdAndMartialLevel(cardRole.id, martialLevel)
    local bookList     = bookListData:getMartialTable()

    for index=1, 6 do
    	-- 该位置有书装备
	    if martialList[index] == nil then
	    	local bookid = bookList[index]
	    	if bookId == bookid then 
	    		local bookInfo = MartialData:objectByID(bookid)
		    	local bookLevel = bookInfo.goodsTemplate.level

		    	if roleLevel >= bookLevel then
		    		return true
		    	end

	    	end
	    	
	    end
    end

    return false
end

function MartialManager:dropRewardRedPoint(rewardItem)
    -- print("rewardItem = ", rewardItem)
    if rewardItem.type ~= EnumDropType.GOODS then
        return false
    end

    return CardRoleManager:bookIsCanBeLearn(rewardItem.itemid)
end



--[[
一键装备武学
@instanceId 角色实例
]]
function MartialManager:RequestOneKeyEquipMartial(instanceId)
	showLoading()
	local msg = {
		instanceId
	}
	TFDirector:dispatchGlobalEventWith("EquipmentChangeBegin",{})
	TFDirector:send(c2s.REQUEST_ONE_KEY_EQUIP_MARTIAL,msg)
end



--[[
一键装备武学成功
@instanceId 角色实例

// 一键装备武学
// code = 0x3410
message OneKeyEquipMartialResult{
	required int64 roleId = 1;				//角色id
	repeated MartialInfo martial = 2;		//新装备的武学
}

]]
function MartialManager:OneKeyEquipMartialResult(event)
	print("OneKeyEquipMartialResult",event.data)
	hideLoading()
	local data = event.data

	local roleInstance = CardRoleManager:getRoleByGmid(data.roleId)
	if not roleInstance then
		toastMessage("role [" .. data.roleId .. "] not found.")
		return
	end

	local showPos = {}
	if data.martial then
		for k,v in pairs(data.martial) do
			MartialManager:addOrUpdateMartialInstance(data.roleId,v)
			showPos[#showPos+1] = v.position
		end
	end
	roleInstance:refreshMartial()

	-- local martialTemplate = MartialData:objectByID(event.data.martialId)
	-- if not martialTemplate then
	-- 	toastMessage("找不到武学数据 ： " .. event.data.martialId)
	-- 	return
	-- end

	-- local roleInstance = CardRoleManager:getRoleByGmid(event.data.roleId)
	-- roleInstance:addMartial(martialTemplate,event.data.position)
	-- --需要更新角色属性
	-- roleInstance:refreshMartial()

	TFDirector:dispatchGlobalEventWith("EquipmentChangeEnd",{})



	-- -- 学习武学成功
	TFDirector:dispatchGlobalEventWith(self.OneKeyEquipMartialResult, {posList = showPos})

	-- print("MartialManager:onEquipMartial martialList = ", roleInstance.martialList)
end


--一键合成及通过关卡获取
function MartialManager:oneKeyToHechengAndGet( martialId)
	self.oneKeyTbl = {}
	if self:oneKeyToHechengAndGetById(martialId, 1 ,false,false,true) then
		return
	end
	self.oneKeyTbl = {}
	if self:oneKeyToHechengAndGetById(martialId, 1 ,true,false,true) then
		return
	end
	self.oneKeyTbl = {}
	if self:oneKeyToHechengAndGetById(martialId, 1 ,true,true,true) then
		return
	end
	self.oneKeyTbl = {}

	if self:isCanSynthesisById(martialId,1) then
		toastMessage(TFLanguageManager:getString(ErrorCodeData.Sweep_Synthesis))
	else
		toastMessage(TFLanguageManager:getString(ErrorCodeData.Sweep_No_Martial))
	end
end

--一键合成及通过关卡获取
function MartialManager:oneKeyToHechengAndGetById( martialId , num,isReset,isBuyReset,first)
	if num == nil then
		num = 1
	end
	self.oneKeyTbl[martialId] = self.oneKeyTbl[martialId] or 0
	self.oneKeyTbl[martialId] = self.oneKeyTbl[martialId] + num
	-- num = self.oneKeyTbl[martialId]
	local martialNum = BagManager:getItemNumById(martialId)   --背包是否拥有
	if martialNum >= self.oneKeyTbl[martialId] and first == false then
		return false
	end
	MissionManager:quickPassToGetFGoods(martialId, self.oneKeyTbl[martialId])
	local martialTemplate = MartialData:objectByID(martialId)
	if martialTemplate == nil then   --不是完本武学
		if self:getItemByShowWay(martialId ,isReset,isBuyReset) then
			return true
		end
	else
		local material,index = martialTemplate:getMaterialTable()   -- 合成所需的材料
		if not material or next(material) == nil  then 			--不可合成
			if self:getItemByShowWay(martialId ,isReset,isBuyReset) then
				return true
			end
		else
			for k,v in pairs(material) do
				if self:oneKeyToHechengAndGetById(k,v*num,isReset,isBuyReset,false) then
					return true
				end
			end
		end
	end
	return false
end

function MartialManager:getItemByShowWay( itemId ,isReset,isBuyReset)
	local itemInfo  = ItemData:objectByID(itemId)
	if itemInfo == nil then
		return false
	end
	if itemInfo.show_way == "" then
		print("获取途径为空 id == ",itemId)
		return false
	end
	local outputList  = string.split(itemInfo.show_way, "|")
	for i=1,#outputList do
		local output = string.split(outputList[i], "_")
		if tonumber(output[1]) == 1 then
			local missionId = tonumber(output[2])
			local mission = MissionManager:getMissionById(missionId);
			if mission == nil then
				print("mission == nil ,missionId =" , missionId)
				return false
			end
			if MissionManager:getMissionIsOpen(missionId) and self:quickMission(missionId,isReset,isBuyReset) then
				return true
			end
		end
	end
	return false
end

function MartialManager:quickMission( missionId ,isReset,isBuyReset )
    local mission = MissionManager:getMissionById(missionId);

    local difficulty = mission.difficulty
    local maxChallengeCount  = 0
    if difficulty == 1 then
    	maxChallengeCount = 9
    elseif difficulty == 2 then
    	maxChallengeCount = 5
    end

    local leftChallengeTimes = mission.maxChallengeCount - mission.challengeCount;
    if leftChallengeTimes <= 0 and isReset == false then
    	return false
    end
    local openVip = ConstantData:getValue("Mission.ManyQuick.NeedVIP");
	if MainPlayer:getVipLevel() < openVip then
		-- local msg =  "VIP" .. openVip .. "开启多次扫荡多次功能。";
		local msg =  "VIP" .. openVip .. "开启多次扫荡功能。\n\n是否前往充值？";
		CommonManager:showOperateSureLayer(
			function()
				PayManager:showPayLayer();
			end,
			nil,
			{
			title = "提升VIP",
			msg = msg,
			uiconfig = "lua.uiconfig_mango_new.common.NeedTpPayLayer"
			}
		)
		return true;
	end

	if leftChallengeTimes >= maxChallengeCount then
        leftChallengeTimes = maxChallengeCount
    end
    if not MainPlayer:isEnoughTimes( EnumRecoverableResType.PUSH_MAP , mission.consume * leftChallengeTimes, false )  then
        VipRuleManager:showReplyLayer(EnumRecoverableResType.PUSH_MAP)
        return true
    end
    if mission.challengeCount >= mission.maxChallengeCount then          --没次数
    	if isReset == false then
			return false
		end

		local useResetTime = mission.resetCount
        local vipItem = VipData:getVipItemByTypeAndVip(2020,MainPlayer:getVipLevel());
        local maxResetTime = (vipItem and vipItem.benefit_value) or 0;
        local need = (useResetTime + 1) * ConstantData:getValue("Mission.Reset.Times.price");


        if maxResetTime - useResetTime < 1 then
			if isBuyReset == false then
				return false
			end
            local nextUpVip = VipData:getVipNextAddValueVip(2020,MainPlayer:getVipLevel())
            if nextUpVip then
				local str1 = stringUtils.format(localizable.youli_text8, nextUpVip.vip_level, nextUpVip.benefit_value)
				local str2 = stringUtils.format(localizable.youli_text9, nextUpVip.vip_level, nextUpVip.benefit_value)
				--[[
                local msg = (maxResetTime <= 0 
                    and "提升至VIP" .. nextUpVip.vip_level .. "可每日购买挑战次数" .. nextUpVip.benefit_value .. "次。\n\n是否前往充值？"
                    or "今日购买次数已用完！\n\n提升至VIP" .. nextUpVip.vip_level .. "可每日购买挑战次数" .. nextUpVip.benefit_value .. "次。\n\n是否前往充值？"
                    );
				]]
				local msg = (maxResetTime <= 0 and str1 or str2);
                CommonManager:showOperateSureLayer(
                        function()
                            PayManager:showPayLayer();
                        end,
                        nil,
                        {
                        title = (maxResetTime <= 0 and "提升VIP" or "挑战次数已用完") ,
                        msg = msg,
                        uiconfig = "lua.uiconfig_mango_new.common.NeedTpPayLayer"
                        }
                )
            else
                toastMessage("挑战次数已用完，今日重置次数已用完");
            end
        else
            local configure = ResetData:objectByID(1)
            if configure then
                local toolId  = configure.token_id
                local temptbl = string.split(configure.token_num, ',')
                local usedResetIndex = useResetTime + 1
                if usedResetIndex > #temptbl then
                    usedResetIndex = #temptbl
                end

                local cost = tonumber(temptbl[usedResetIndex])

                local resetTool = BagManager:getItemById(toolId)
                if resetTool and resetTool.num >= cost then
                    local msg = "此次重置需要重置令" .. cost .. "个，是否确定重置？" ;
                    msg = msg .. "\n\n(当前拥有重置令：" .. resetTool.num..",今日还可以重置" .. maxResetTime - useResetTime .. "次)";
                    CommonManager:showOperateSureLayer(
                            function()
                                 MissionManager:resetChallengeCount( missionId );
                            end,
                            nil,
                            {
                                msg = msg
                            }
                    )
                    return true
                end
            end

            local msg = "是否花费" .. need .. "元宝重置此关卡挑战次数？" ;
            msg = msg .. "\n\n(今日还可以重置" .. maxResetTime - useResetTime .. "次)";
            CommonManager:showOperateSureLayer(
                    function()
                         if MainPlayer:isEnoughSycee( need , true) then
                                MissionManager:resetChallengeCount( missionId );
                         end
                    end,
                    nil,
                    {
                    msg = msg
                    }
            )
        end
        return true
    end


    local challengeTimes = math.min(mission.maxChallengeCount - mission.challengeCount, maxChallengeCount)

    --- vip对应的扫荡次数
    local vipQuickData  = VipData:getVipItemByTypeAndVip(2060, MainPlayer:getVipLevel()) 
    local vipQuickTimes = (vipQuickData and vipQuickData.benefit_value) or 0


    local saoDangCardNum = 0
    local sweepConfigure = SweepData:objectByID(1)
    if sweepConfigure then
        local cost = sweepConfigure.token_num or 1

        local sweepID = sweepConfigure.token_id
        -- 判断扫荡道具 30035
        local tool = BagManager:getItemById(sweepID)
        if tool and tool.num > 0 then
            saoDangCardNum = tool.num
        end

        saoDangCardNum = math.floor(saoDangCardNum/cost)
    end
    
    local totalFreeTimes = vipQuickTimes + saoDangCardNum - MissionManager.useQuickPassTimes

    print("vip扫荡次数----", vipQuickTimes)
    print("拥有扫荡卡----",  saoDangCardNum)
    print("扫荡用掉的次数----",  MissionManager.useQuickPassTimes)
    print("总的次数 ----",  totalFreeTimes)

    -- 需要花钱的次数
    local needCostTimes = challengeTimes - totalFreeTimes

    if needCostTimes <= 0 then
        needCostTimes = 0
        MissionManager:manyQuickPassMission(missionId,false,false,challengeTimes);
    else
        local freeQuickprice = ConstantData:getValue("Mission.FreeQuick.price");
        if challengeTimes == 1 then
            if MainPlayer:isEnoughSycee( freeQuickprice , true) then
                MissionManager:manyQuickPassMission(missionId,false,false,challengeTimes);
            end
            return true
        end

        local costNum =  freeQuickprice * needCostTimes
        local msg = "剩余免费次数和扫荡令总和不足,是否花费" .. costNum .. "元宝进行扫荡？" ;

        if not self.quick_need_money_tip then
            CommonManager:showOperateSureTipLayer(
                    function(data, widget)
                        if MainPlayer:isEnoughSycee( costNum , true) then
                            MissionManager:manyQuickPassMission(missionId,false,false,challengeTimes);
                            self:getHasTip(widget)
                        end
                    end,
                    function(data, widget)
                        AlertManager:close()
                        self:getHasTip(widget)
                    end,
                    {
                        msg = msg
                    }
            )
        else
            if MainPlayer:isEnoughSycee( costNum , true) then
                MissionManager:manyQuickPassMission(missionId,false,false,challengeTimes);
            end
        end
    end
    return true

end

function MartialManager:getHasTip( widget )
    local state = widget:getSelectedState();
    print("state == ",state)
    if state == true then
        self.quick_need_money_tip = true
        CCUserDefault:sharedUserDefault():setBoolForKey("quick_need_money_tip", self.quick_need_money_tip);
        CCUserDefault:sharedUserDefault():flush();
        return
    end
end

return MartialManager:new() 