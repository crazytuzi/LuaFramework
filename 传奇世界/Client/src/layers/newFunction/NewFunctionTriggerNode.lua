local NewFunctionTriggerNode = class("NewFunctionTriggerNode", function() return cc.Node:create() end)

require("src/layers/newFunction/NewFunctionDefine")

function NewFunctionTriggerNode:ctor()
	local msgids = {TARGETREWARD_SC_CHECK_RET, TARGETREWARD_SC_GET_RET}
	require("src/MsgHandler").new(self,msgids)

	self.data = {}
	self.noticeData = {}--require("src/config/NewFunctionNotice")
	self.noticeExData = require("src/config/NewFunctionExCfg")
	self.triggerData = require("src/config/NewFunctionCfg")
	self.funcData = {}
	self.funcDataInit = false
	self.triggerLayer = nil

	-- if G_RING_INFO.ringNum and G_RING_INFO.ringNum > 0 then
	-- 	self:unLockFunction(NF_RING)
	-- 	self:check()
	-- end
end

function NewFunctionTriggerNode:init()
	--log("NewFunctionTriggerNode:init")
	self:updateData()
end

function NewFunctionTriggerNode:initFuncData()
	--log("NewFunctionTriggerNode:initFuncData")
	local lv = MRoleStruct:getAttr(ROLE_LEVEL)
	local taskId
	if DATA_Mission and DATA_Mission.getLastTaskData() then
		taskId = DATA_Mission.getLastTaskData().q_taskid
		if DATA_Mission.getLastTaskData().isBan then
			taskId = taskId - 1
		end
	end
	--log("NewFunctionTriggerNode:initFuncData lv = "..lv)
	if lv == nil then
		return
	end

	for k,v in pairs(self.triggerData) do
		local record = v

		-- local resultLv = true
		-- if lv and record.q_level then
		-- 	if lv < tonumber(record.q_level) then
		-- 		resultLv = false
		-- 	else
		-- 		resultLv = true
		-- 	end
		-- else
		-- 	resultLv = true
		-- end

		-- local resultVip = true
		-- if record.q_vip then
		-- 	if G_VIP_INFO and G_VIP_INFO.vipLevel then
		-- 		if G_VIP_INFO.vipLevel < tonumber(record.q_vip) then
		-- 			resultVip = false
		-- 		else
		-- 			resultVip = true
		-- 		end
		-- 	end
		-- else
		-- 	resultVip = true
		-- end

		-- local result = false
		-- if record.q_or then
		-- 	if tonumber(record.q_or) == 0 then
		-- 		result = resultLv or resultVip
		-- 	elseif tonumber(record.q_or) == 1 then
		-- 		result = resultLv and resultVip
		-- 	end 
		-- else
		-- 	result = resultLv and resultVip
		-- end

		-- if record.q_condition == 1 then
		-- 	result = false
		-- end

		--用任务来判断 start
		local result
		if taskId and record.q_task then
			if taskId < tonumber(record.q_task) then
				result = false
			else
				result = true
			end
		-- else
		-- 	result = true
		end
		--用任务来判断 end

		if lv and record.q_level then
			if lv < tonumber(record.q_level) then
				result = false
			else
				result = true
			end
		-- else
		-- 	result = true
		end

		self.funcData[record.q_ID] = result
		--print("id = "..record.q_ID.." is "..tostring(self.funcData[record.q_ID]))
	end

	if G_NF_DATA.NF_SOUL and G_NF_DATA.NF_SOUL == true then
		self.funcData[NF_SOUL] = true
	end

	if G_NF_DATA.NF_MYSTERY and G_NF_DATA.NF_MYSTERY == true then
		self.funcData[NF_MYSTERY] = true
	end

	self.funcDataInit = true
	--dump(self.funcData)
end

function NewFunctionTriggerNode:initFunc()
	--log("NewFunctionTriggerNode:initFunc")
	if self.funcDataInit ~= true then
		self:initFuncData()
	end

	for i,v in ipairs(self.data) do
		--print("v.tag = "..tostring(v.tag))
		if self:isFuncOn(v.tag) then
			self:setAvailable(v)
		else
			self:setUnavailable(v)
		end
	end
	--dump(self.data)
	-- if G_MAINSCENE then
	-- 	G_MAINSCENE:resetTopBtnPos()
	-- end
end

--功能是否开启
function NewFunctionTriggerNode:isFuncOn(tag)
	return self.funcData[tag]
end

function NewFunctionTriggerNode:setFunc(tag, state)
	self.funcData[tag] = state
	if tag == NF_SIGN_IN and G_MAINSCENE then 
		G_MAINSCENE:refreshActivityReddot()
	end
end

function NewFunctionTriggerNode:check(lvEx, isCheckEx)
	--log("NewFunctionTriggerNode:check")
	--dump(self.noticeExData)
	local lv
	if lvEx then
		lv = lvEx
	else
		lv = MRoleStruct:getAttr(ROLE_LEVEL)
	end
	local school = MRoleStruct:getAttr(ROLE_SCHOOL)

	local taskId = 0
	if DATA_Mission and DATA_Mission.getLastTaskData() then
		taskId = DATA_Mission.getLastTaskData().q_taskid
		if DATA_Mission.getLastTaskData().isBan then
			taskId = taskId - 1
		end
	end

	-- if not lv or not school then
	-- 	return
	-- end

	--处理功能预告
	-- for i,v in pairs(self.noticeData) do
	-- 	if lv >= v.q_level then
	-- 		self:notice(v)
	-- 	end

	-- 	if lv >= v.q_close then
	-- 		self:removeNotice()
	-- 	end
	-- end

	--处理功能开启Ex
	-- for i,v in pairs(self.noticeExData) do
	-- 	if lv >= v.lvMin and lv < v.lvMax and school == v.school then
	-- 		self:noticeEx(v)
	-- 	end
	-- end
	-- if lv >= self.noticeExData[#self.noticeExData].lvMax then
	-- 	self:removeNoticeEx()
	-- end

	if isCheckEx ~= false then
		self:checkNewFunctionEx()
	end

	--处理功能开启
	for i,v in pairs(self.triggerData) do
		-- local result = true

		-- local resultLv = true
		-- if v.q_level then
		-- 	if lv < v.q_level then
		-- 		resultLv = false
		-- 	end
		-- else
		-- 	resultLv = true
		-- end

		-- local resultVip = true
		-- if v.q_vip then
		-- 	if G_VIP_INFO and G_VIP_INFO.vipLevel then
		-- 		--dump(G_VIP_INFO)
		-- 		if G_VIP_INFO.vipLevel < tonumber(v.q_vip) then
		-- 			resultVip = false
		-- 		end
		-- 	end
		-- else
		-- 	resultVip = true
		-- end

		-- if v.q_or then
		-- 	if tonumber(v.q_or) == 0 then
		-- 		result = resultLv or resultVip
		-- 	elseif tonumber(v.q_or) == 1 then
		-- 		result = resultLv and resultVip
		-- 	end 
		-- else
		-- 	result = resultLv and resultVip
		-- end

		--用任务来判断 start
		local result
		if taskId and v.q_task then
			if taskId < tonumber(v.q_task) then
				result = false
			else
				result = true
			end
		-- else
		-- 	result = true
		end
		--用任务来判断 end

		if lv and v.q_level then
			if lv < tonumber(v.q_level) then
				result = false
			else
				result = true
			end
		-- else
		-- 	result = true
		end

		if result == true then
			--log("test 1")
			if v.q_condition == 0 then
				--log("test 2")
				if self:isFuncOn(v.q_ID) == false then
					--log("test 3")
					--self:trigger(v, lv~=v.q_level and v.q_ID~=21)
					if v.q_task then
						self:trigger(v, taskId~=v.q_task or v.q_ID==3)
					elseif v.q_level then
						log("trigger v.q_ID = "..v.q_ID)
						self:trigger(v, lv~=v.q_level or v.q_ID==3)
					end
				end
			else
				--print(v.q_ID.." locked!!!!!!!!!!!!!!!!!!!!!!!")
			end
		end
	end

	if isCheckEx ~= false then
		if G_ROLE_MAIN and G_ROLE_MAIN.obj_id then
			--处理功能目标奖励
			--g_msgHandlerInst:sendNetDataByFmtExEx(TARGETREWARD_CS_CHECK, "i", G_ROLE_MAIN.obj_id)
			g_msgHandlerInst:sendNetDataByTableExEx(TARGETREWARD_CS_CHECK, "CheckTargetRewardProtocol", {})
		end
	end
end

function NewFunctionTriggerNode:unLockFunction(id)
	--log("NewFunctionTriggerNode:unLockFunction "..id)
	for i,v in pairs(self.triggerData) do
		if v.q_ID == id then
			v.q_condition = 0
			--print("set "..v.q_ID.." q_condition = 0 !!!!!!!!!!!!!!!!!!!!!!!!!!!")
			break
		end
	end
end

function NewFunctionTriggerNode:checkNewFunctionEx()
	--print("################################self.nowTagetId = "..tostring(self.nowTagetId))
	if self.nowTagetId == nil or self.nowTagetId == 0 then
		if self.nowTagetId == 0 then
			self:removeNoticeEx()
		end
		return
	end

	local lv = MRoleStruct:getAttr(ROLE_LEVEL)
	local school = MRoleStruct:getAttr(ROLE_SCHOOL)

	if lv and school then
		--处理功能开启Ex
		for i,v in pairs(self.noticeExData) do
			if lv >= v.lvMin and school == v.school and self.nowTagetId == v.id then
				self:noticeEx(v) 
			end
		end

		if self.noticeExData[#self.noticeExData] and lv >= self.noticeExData[#self.noticeExData].lvMax and self.nowTagetId == nil then
			self:removeNoticeEx()
		end
	end
end

function NewFunctionTriggerNode:triggerById(id, noShow)
	local record
	for i,v in ipairs(self.triggerData) do
		if v.q_ID == id then
			record = v
			break
		end
	end

	if record then
		self:trigger(record, noShow)
	end
end

function NewFunctionTriggerNode:trigger(record, noShow)
	log("NewFunctionTriggerNode:trigger id = "..record.q_ID)
	if G_MAINSCENE == nil then
		return
	end

	--关闭目标提示
	if G_MAINSCENE.newFuntionNodeEx then
		G_MAINSCENE.newFuntionNodeEx:removeShow()
	end
	--刚出公平竞技场不弹
	if G_SKYARENA_DATA.tipsLimit and G_SKYARENA_DATA.tipsLimit.functionOpenStopTimes and G_SKYARENA_DATA.tipsLimit.functionOpenStopTimes==0 then
		noShow=true
	end
	self:addShow(record, noShow)

	if record.q_ID == NF_LOTTERY then
		--寻宝是登陆时设置的红点，这里做一个假的设置
		if TOPBTNMG then TOPBTNMG:showRedMG( "Lotter" , true ) end
	-- elseif record.q_ID == NF_SIGN_IN then
		--签到打开会自己处理红点(已经换位置216.1.6)
	end
end

function NewFunctionTriggerNode:notice(record)
	--log("NewFunctionTriggerNode:notice")
	if G_MAINSCENE == nil then
		return
	end
	G_MAINSCENE:createNewFunctionBtn(record)
end

function NewFunctionTriggerNode:removeNotice()
	--log("NewFunctionTriggerNode:removeNotice")
	if G_MAINSCENE == nil then
		return
	end
	G_MAINSCENE:removeNewFunctionBtn()
end

function NewFunctionTriggerNode:noticeEx(record)
	--log("NewFunctionTriggerNode:noticeEx")
	--self:removeNoticeEx()
	if G_MAINSCENE == nil then
		return
	end
	G_MAINSCENE:createNewFunctionBtnEx(record)
end

function NewFunctionTriggerNode:removeNoticeEx()
	--log("NewFunctionTriggerNode:removeNoticeEx")
	if G_MAINSCENE == nil then
		return
	end
	G_MAINSCENE:removeNewFunctionBtnEx()
end

function NewFunctionTriggerNode:setUnavailable(record)
	-- log("NewFunctionTriggerNode:setUnavailable")
	-- print("setUnavailable "..tostring(record.tag))
	if record.node then
		if getConfigItemByKey("NewFunctionCfg", "q_ID", record.tag) and 
			getConfigItemByKey("NewFunctionCfg", "q_ID", record.tag).q_type and 
			getConfigItemByKey("NewFunctionCfg", "q_ID", record.tag).q_type == NF_NO_RELATIVE then
			--record.node:setVisible(false)
			if TOPBTNMG then
				TOPBTNMG:showMG(record.node, false)
			end
			G_MAINSCENE:resetBottomBtn()
		end
	end
end

function NewFunctionTriggerNode:setAvailable(record, opacity, isReal)
	-- log("NewFunctionTriggerNode:setAvailable")
	if record.node and getConfigItemByKey("NewFunctionCfg", "q_ID", record.tag).q_type == NF_NO_RELATIVE then
		--record.node:setVisible(true)
		if TOPBTNMG then
			TOPBTNMG:showMG(record.node, true)
		end
		if opacity then
			record.node:setOpacity(opacity)
		end

        -- 大退会报错
        if (G_MAINSCENE ~= nil) then
		    G_MAINSCENE:resetBottomBtn()
        end
	end

	if isReal ~= false then
		self:setFunc(record.tag, true)
	end
end

function NewFunctionTriggerNode:setRed(record)
	-- if record.tag == NF_RIDE 
	-- 	or record.tag == NF_WING
	-- 	or record.tag == NF_FACTION
	-- 	or record.tag == NF_FRIEND
	-- 	or record.tag == NF_AUCTION
		
	-- then
	--  	if record.node then
	-- 		local red = createSprite(record.node , "res/component/flag/red.png"  , cc.p(record.node:getContentSize().width-5 , record.node:getContentSize().height-15) , cc.p(0.5, 0.5))
	-- 		red:setTag(100)
	-- 	end
	-- end

	-- if record.tag == NF_BATTLE then
	-- 	DATA_Battle:setRedData("jjc", true)
	-- elseif record.tag == NF_RING then
	-- 	DATA_Battle:setRedData("Spiritring", true)
	-- elseif record.tag == NF_MINE then
	-- 	DATA_Battle:setRedData("ZXWK", true)
	-- elseif record.tag == NF_GOD then
	-- 	DATA_Battle:setRedData("GodEquipLayer", true)
	-- elseif record.tag == NF_SOUL then
	-- 	DATA_Battle:setRedData("LXWK", true)
	-- elseif record.tag == NF_FB_SINGLE or record.tag == NF_FB_PROTECT or record.tag == NF_FB_TOWER then
	-- 	DATA_Battle:setRedData("FB", true)
	-- end 

	-- if record.tag == NF_LOTTERY then
	-- 	DATA_Activity:setRedData("Lotter", true)
	-- elseif record.tag == NF_RING then
	-- 	DATA_Activity:setRedData("Spiritring", true)
	-- elseif record.tag == NF_MINE then
	-- 	DATA_Activity:setRedData("ZXWK", true)
	-- elseif record.tag == NF_GOD then
	-- 	DATA_Activity:setRedData("GodEquipLayer", true)
	-- elseif record.tag == NF_SOUL then
	-- 	DATA_Activity:setRedData("LXWK", true)
	-- end 
end

function NewFunctionTriggerNode:addShow(record, noShow)
	local dataRecord
	--dump(self.data)
	for i,v in ipairs(self.data) do
		--log("v.tag = "..v.tag)
		if v.tag == record.q_ID then
			dataRecord = v
		end
	end

	--功能已经开启
	if self:isFuncOn(record.q_ID) == true then
		--print("return 1")
	 	return
	end

	--功能在开启中
	if self.triggerLayer ~= nil then
		--print("return 2")
		return
	end

	if dataRecord == nil then
		--print("return 3")
		--log("dataRecod is nil record.q_ID = "..record.q_ID)
		return
	end

	-- startTimerAction(self, 2, false, function()
	-- 	if G_SHOW_ORDER_DATA.showFuncEx == true then
	-- 		startTimerAction(self, 6, false, function()
	-- 			--打开底部菜单
	-- 			G_MAINSCENE:setFullShortNode(true)
	-- 			--打开顶部菜单
	-- 			if TOPBTNMG then
	-- 				TOPBTNMG:openTop(true)
	-- 			end

	-- 			local param = {}
	-- 			param.triggerNode = self
	-- 			param.dataRecord = dataRecord
	-- 			param.triggerDataRecord = record
	-- 			local layer = require("src/layers/newFunction/NewFunctionLayer").new(param)
	-- 			self.triggerLayer = layer
	-- 			getRunScene():addChild(layer, 150)
	-- 		end)
	-- 	else
			--打开底部菜单
			G_MAINSCENE:setFullShortNode(true)
			--打开顶部菜单
			if TOPBTNMG then
				TOPBTNMG:openTop(true)
			end
			G_MAINSCENE:hideTopIcon(false)
			--dump(noShow)
			if noShow then
				self:setAvailable(dataRecord)
			else
				local param = {}
				param.triggerNode = self
				param.dataRecord = dataRecord
				param.triggerDataRecord = record
				local layer = require("src/layers/newFunction/NewFunctionLayer").new(param)
				self.triggerLayer = layer
				getRunScene():addChild(layer, 150)
			end
	-- 	end
	-- end)

	self:setRed(record)
end

function NewFunctionTriggerNode:updateData(isCheckEx, isFirstCheck)
	self:fixData()
	if isFirstCheck == true then
		self:initFuncData()
	end
	self:initFunc()
	self:check(nil, isCheckEx)

	-- if G_MAINSCENE then
	-- 	G_MAINSCENE:resetTopBtnPos(nil, true)
	-- end
end

function NewFunctionTriggerNode:addData(node, tag)
	--self.data[tag] = node
	table.insert(self.data, {tag=tag, node=node, pos=nil})
	self:updateData()
end

function NewFunctionTriggerNode:fixData()
	if self.data then
		for k,v in pairs(self.data) do
			v.pos = v.node:convertToWorldSpace(cc.p(v.node:getContentSize().width/2, v.node:getContentSize().height/2))
		end
	end
end

function NewFunctionTriggerNode:networkHander(buff, msgid)
	local switch = {
		[TARGETREWARD_SC_CHECK_RET] = function()
			--log("get TARGETREWARD_SC_CHECK_RET")
			local t = g_msgHandlerInst:convertBufferToTable("CheckTargetRewardRetProtocol", buff)
			--local roleId = buff:popInt()
			self.nowTagetId = t.targetRewardID
			self:checkNewFunctionEx()
			--log("self.nowTagetId = "..tostring(self.nowTagetId))
			for i,v in pairs(self.noticeExData) do
				if self.nowTagetId ~= 0 and v.id >= self.nowTagetId then
					break
				else
					if self.nowTagetId == 5 then
						--self:unLockFunction(NF_RING)
						--self:unLockFunction(NF_RIDE)
					elseif self.nowTagetId == 6 or self.nowTagetId == 7 or self.nowTagetId == 8 then
						--self:unLockFunction(NF_RING)
						--self:unLockFunction(NF_RIDE)
					-- elseif self.nowTagetId == 9 or self.nowTagetId == 10 then
					-- 	self:unLockFunction(NF_RING)
					-- 	self:unLockFunction(NF_RIDE)
					-- 	self:unLockFunction(NF_GOD)
					-- elseif self.nowTagetId == 11 then
					-- 	self:unLockFunction(NF_RING)
					-- 	self:unLockFunction(NF_RIDE)
					-- 	self:unLockFunction(NF_GOD)
					-- 	self:unLockFunction(NF_WING)
					-- elseif self.nowTagetId == 12 then
					-- 	self:unLockFunction(NF_RING)
					-- 	self:unLockFunction(NF_RIDE)
					-- 	self:unLockFunction(NF_GOD)
					-- 	self:unLockFunction(NF_WING)
					-- 	self:unLockFunction(NF_BEAUTY)
					-- elseif self.nowTagetId == 13 then
					-- 	self:unLockFunction(NF_RING)
					-- 	self:unLockFunction(NF_RIDE)
					-- 	self:unLockFunction(NF_GOD)
					-- 	self:unLockFunction(NF_WING)
					-- 	self:unLockFunction(NF_BEAUTY)
					-- 	self:unLockFunction(NF_WEAPON)
					-- elseif self.nowTagetId == 14 then
					-- 	self:unLockFunction(NF_RING)
					-- 	self:unLockFunction(NF_RIDE)
					-- 	self:unLockFunction(NF_GOD)
					-- 	self:unLockFunction(NF_WING)
					-- 	self:unLockFunction(NF_BEAUTY)
					-- 	self:unLockFunction(NF_WEAPON)
					-- 	self:unLockFunction(NF_ARM)
					-- elseif self.nowTagetId == 15 then
					-- 	self:unLockFunction(NF_RING)
					-- 	self:unLockFunction(NF_RIDE)
					-- 	self:unLockFunction(NF_GOD)
					-- 	self:unLockFunction(NF_WING)
					-- 	self:unLockFunction(NF_BEAUTY)
					-- 	self:unLockFunction(NF_WEAPON)
					-- 	self:unLockFunction(NF_ARM)
					-- 	self:unLockFunction(NF_BABY)
					elseif self.nowTagetId == 0 then
						-- self:unLockFunction(NF_RING)
						-- self:unLockFunction(NF_RIDE)
					-- 	self:unLockFunction(NF_GOD)
					-- 	self:unLockFunction(NF_WING)
					-- 	self:unLockFunction(NF_BEAUTY)
					-- 	self:unLockFunction(NF_WEAPON)
					-- 	self:unLockFunction(NF_ARM)
					-- 	self:unLockFunction(NF_BABY)
					-- 	self:unLockFunction(NF_BABY_QUALITY)
					end
				end
			end

			if self.isFirstCheck == nil then
				self.isFirstCheck = true
				self:updateData(false, true)
			else
				self:updateData(false)
			end
			
		end
		,
		[TARGETREWARD_SC_GET_RET] = function()
			log("get TARGETREWARD_SC_GET_RET")
			local t = g_msgHandlerInst:convertBufferToTable("GetTargetRewardRetProtocol", buff)
			--MessageBox("get TARGETREWARD_SC_GET_RET 22222222222222222222222222222")
			--local roleId = buff:popInt()
			local result = t.getResult
			--log("roleId = "..roleId)
			log("result = "..tostring(result))
			if result then
				self.nowTagetId = t.nextTargetRewardID
				--log("111111111111111111111 self.nowTagetId = "..self.nowTagetId)
				self:checkNewFunctionEx()
				log("self.nowTagetId = "..tostring(self.nowTagetId))
				if self.nowTagetId == 5 then
					--self:unLockFunction(NF_RING)
					-- self:unLockFunction(NF_RIDE)
				elseif self.nowTagetId == 6 or self.nowTagetId == 7 or self.nowTagetId == 8 then
					--self:unLockFunction(NF_RING)
					-- self:unLockFunction(NF_RIDE)
				-- elseif self.nowTagetId == 9 or self.nowTagetId == 10 or self.nowTagetId == 11 then
				-- 	self:unLockFunction(NF_RING)
				-- 	self:unLockFunction(NF_RIDE)
				-- 	self:unLockFunction(NF_GOD)
				-- elseif self.nowTagetId == 12 then
				-- 	self:unLockFunction(NF_RING)
				-- 	self:unLockFunction(NF_RIDE)
				-- 	self:unLockFunction(NF_GOD)
				-- 	self:unLockFunction(NF_WING)
				-- elseif self.nowTagetId == 13 then
				-- 	self:unLockFunction(NF_RING)
				-- 	self:unLockFunction(NF_RIDE)
				-- 	self:unLockFunction(NF_GOD)
				-- 	self:unLockFunction(NF_WING)
				-- 	self:unLockFunction(NF_BEAUTY)
				-- elseif self.nowTagetId == 14 or self.nowTagetId == 15 then
				-- 	self:unLockFunction(NF_RING)
				-- 	self:unLockFunction(NF_RIDE)
				-- 	self:unLockFunction(NF_GOD)
				-- 	self:unLockFunction(NF_WING)
				-- 	self:unLockFunction(NF_BEAUTY)
				-- 	self:unLockFunction(NF_WEAPON)
				elseif self.nowTagetId == 0 then
					-- self:unLockFunction(NF_RING)
					-- self:unLockFunction(NF_RIDE)
				-- 	self:unLockFunction(NF_GOD)
				-- 	self:unLockFunction(NF_WING)
				-- 	self:unLockFunction(NF_BEAUTY)
				-- 	self:unLockFunction(NF_WEAPON)
				-- 	self:unLockFunction(NF_ARM)
				end

				self:check()
			else
				self:check()
			end
		end
	}

 	if switch[msgid] then 
 		switch[msgid]()
 	end
end

function NewFunctionTriggerNode:isBottomNode(node)
	for k,v in pairs(self.data) do
		if v.node == node then
			local tag = v.tag
			--print("tag = "..tag)
			for i,v in ipairs(iconBottom) do
				if tag == v.tag then
					return true
				end
			end
		end
	end

	return false
end

function NewFunctionTriggerNode:setBottom(node, isOn)
	for k,v in pairs(self.data) do
		if v.node == node then
			local tag = v.tag
			--print("tag = "..tag)
			for i,v in ipairs(iconBottom) do
				if tag == v.tag then
					if isOn then
						node:setImages(v.onRes)
					else
						node:setImages(v.offRes)
					end
				end
			end
		end
	end
end

return NewFunctionTriggerNode