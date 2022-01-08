--[[
******游戏数据阵法管理类*******


	-- by king
	-- 2014/8/13
	
	-- 血战乖点刷新 
	-- by king
	-- 2014/9/15
]]


local BloodFightManager = class("BloodFightManager")
local CardRole = require('lua.gamedata.base.CardRole')
BloodFightManager.UPDATE_STARTEGY_POS     = "BloodFightManager.UPDATE_STARTEGY_POS";
BloodFightManager.UPDATE_GENERRAL_LIST    = "BloodFightManager.UPDATE_GENERRAL_LIST";
BloodFightManager.AUTO_WAR_MATIX_RESULT   = "BloodFightManager.AUTO_WAR_MATIX_RESULT";
BloodFightManager.LOOK_PLAYE_INFO		  = "BloodInfolayerEvent"
BloodFightManager.GET_ENEMY_LSIT		  = "GET_ENEMY_LSIT"
BloodFightManager.MSG_UPDATE_BOX 		  = "BloodFightManager.MSG_UPDATE_BOX" 		-- 宝箱更新
BloodFightManager.MSG_GOT_BOX 		  	  = "BloodFightManager.MSG_GOT_BOX" 		-- 宝箱更新
BloodFightManager.MSG_BATTLE_RESULT 	  = "BloodFightManager.MSG_BATTLE_RESULT"	-- 战斗结果更新
BloodFightManager.MSG_INSPIRE_RESULT 	  = "BloodFightManager.MSG_INSPIRE_RESULT"	-- 鼓舞更新
--
BloodFightManager.MSG_REQUEST_ROLELIST_RESULT 	  = "BloodFightManager.MSG_REQUEST_ROLELIST_RESULT"

BloodFightManager.MSG_UPDATE_PAGE_DATA 	  = "BloodFightManager.MSG_UPDATE_PAGE_DATA" -- 更新八个怪点
BloodFightManager.MSG_DAILY_RESET 	      = "BloodFightManager.MSG_DAILY_RESET" -- 更新八个怪点
BloodFightManager.MSG_RESET_MANUAL 		  =	"BloodFightManager.MSG_RESET_MANUAL"	--手动重置成功

-- BloodFightManager.inspireList = require("lua.table.t_s_bloody_inspire_config")

function BloodFightManager:ctor()
	self:init();
	TFDirector:addProto(s2c.BLOODY_WAR_MATIX_CONF_RESULT, self, self.onReceiveWarMatixConfResult);
	TFDirector:addProto(s2c.BLOODY_WAR_MATIX_CONF, self, self.onReceiveWarMatixConf);
	TFDirector:addProto(s2c.BLOODY_WAR_MATIX_CAPACITY, self, self.onReceiveWarMatixSizeUpdate);
	
	-- 查看信息
	TFDirector:addProto(s2c.BLOODY_ENEMY_SIMPLE_INFO_LIST, self, self.onReceiveEnemyList);
	
	-- 获取血战信息
	TFDirector:addProto(s2c.BLOODY_ENEMY_DETAIL, self, self.onReceiveBloodDetail);
	-- 获取每个怪点的信息
	TFDirector:addProto(s2c.BLOODY_ENEMY_INFO_LIST, self, self.onReceiveBloodyEnemyInfo);
	--宝箱更新
	TFDirector:addProto(s2c.GET_BLOODY_BOX_RESULT, self, self.onReceiveBoxUpdate);
	
	--当前关卡更新
	TFDirector:addProto(s2c.BLOODY_CURR_SECTION_UPDATE, self, self.onReceiveBattleSectionUpdate);
	
	--当前鼓舞更新
	TFDirector:addProto(s2c.BLOODY_INSPIRE_RESULT, self,   self.onReceiveInspireUpdate);

	--手动重置成功,add by wkdai
	TFDirector:addProto(s2c.BLOODY_RESET_SUCCESS, self,   self.onReceiveResetSuccess)
	TFDirector:addProto(s2c.BLOODY_WILL_RESET_NOTIFY, self,   self.prepareResetManual)
	
	--扫荡
	TFDirector:addProto(s2c.BLOODY_SWEEP_RESULT, self,   self.bloodySweepResult)

end

function BloodFightManager:init()

	self.strategylist 	= {}					--当前阵型排列
	self.maxNum		 	= 7 					--最大人数
	self.num 			= 0 					--当前上阵人数 
	self.useId  		= 0 					--当前使用的阵法

	self.roleHpList		= {}					--当前血量列表
	self.playerList     = {}					--挑战角色的列表
	self.boxList     	= {}					--宝箱列表
	self.battleNodeList = {}

	self.curFightIndex  = 1 					--当前打到的索引
	self.maxMissionCount= 24					--关卡总数

	-- 玩家节点的状态
	self.PLAYER_TYPE	= 1
	self.PLAYER_LOCK	= 1
	self.PLAYER_PASS	= 2
	self.PLAYER_NOW		= 3

	--宝箱节点的状态
	self.BOX_TYPE		= 2
	self.BOX_LOCK		= 1
	self.BOX_PASS		= 2
	self.BOX_NOW		= 3

	--当前血战状态
	self.PlayerIsInBloodFighting = false

	
	self.inspireList1   = TFArray:new()
    self.inspireList2   = TFArray:new()

    local inspireList = require("lua.table.t_s_bloody_inspire_config")
    -- local inspireList = BloodFightManager.inspireList

    -- { id = 1, inspire_count = 1, need_res_type = 3, need_res_num = 100, add_attribute_percent = 30, need_vip_level = 1}
    for v in inspireList:iterator() do
        if EnumDropType.COIN == v.need_res_type  then
            self.inspireList1:push(v)
        elseif EnumDropType.SYCEE == v.need_res_type  then
            self.inspireList2:push(v)
        end
    end
    
    -- 比较函数
    local function sortlist( v1,v2 )
        if v1.id < v2.id then
            return true
        end
        return false
    end

    self.inspireList1:sort(sortlist)
    self.inspireList2:sort(sortlist)
end

function BloodFightManager:restart()
	-- self:dispose();
	-- self:init();
end

function BloodFightManager:dispose()
	----print("-----------------------BloodFightManager:dispose()----------------------------");
	self.strategylist  	= nil;
	self.maxNum		 	= nil;			--最大人数
	self.num 			= nil;			--当前上阵人数 
	self.useId  		= nil;			--当前使用的阵法
	self.roleHpList		= nil;			--当前血量列表
	self.playerList     = nil;			--挑战角色的列表
	self.boxList     	= nil;			--宝箱列表

	self.requestStrategy = nil
end


function BloodFightManager:bPlayerIsInBloodFighting()
	return self.PlayerIsInBloodFighting
end

function BloodFightManager:PlayerEnterBloodFighting()
	----print("----------------进入血战")
	self.PlayerIsInBloodFighting = true
end

function BloodFightManager:PlayerExitBloodFighting()
	----print("----------------退出血战")
	self.PlayerIsInBloodFighting = false

	self.showQuickPassLayer = false
	
	-- 牛逼的策划要显示小伙伴的缘分
	CardRoleManager:UpdateRoleFate()
end


function BloodFightManager:onReceiveEnemyList( event )
	local data = event.data;
	--print("----BloodFightManager:onReceiveEnemyList-----", data);

	-- self:updateEnemyList(event.data.allEnemys)
	--print("one Page comepelte --- updateEnemyList")
	self:updateEnemyList(event.data.allEnemys)
	--print("one Page comepelte --- onReceiveBattleSectionUpdate")
	-- if not self.showQuickPassLayer then
		self:onReceiveBattleSectionUpdate(event)
	-- end
	-- --print("self.playerList = ", self.playerList)

	TFDirector:dispatchGlobalEventWith(self.MSG_UPDATE_PAGE_DATA, {mapIndex = self:getCurMapIndex()})
end


--战阵请求处理结果
function BloodFightManager:onReceiveWarMatixConfResult( event )
	local data = event.data;
	--print("11111BloodFightManager:onReceiveWarMatixConfResult",data);
	hideLoading();

	self:changeStrategy(data.fromPos,data.toPos,data.roleId);
	-- CardRoleManager:UpdateRoleFate()
end

--更新战阵的开放位置上限信息
function BloodFightManager:onReceiveWarMatixSizeUpdate( event )
	-- hideLoading();
	local data = event.data;
	self.maxNum = data.capacity;
end

--一键布阵完成
function BloodFightManager:onReceiveAutoMatixCom( event )
	hideLoading();
	TFDirector:dispatchGlobalEventWith(self.AUTO_WAR_MATIX_RESULT);
	-- toastMessage("一键布阵完成");
end

--战阵更新指令，服务器在某些时刻主动推动，下发给客户端
function BloodFightManager:onReceiveWarMatixConf( event )
	hideLoading();
	local data = event.data;
	self.maxNum = data.capacity;

	--print("--------------------")
	--先全部下阵
	self.strategylist = {}
    local roleList = self:getList();
    for index,roleGmId in pairs(roleList) do
    	local role = CardRoleManager:getRoleByGmid(roleGmId);
    	if (role) then
    		self:setRoleIndex(0, role );
    		role.blood_tag = 0
    	else
    		local mercenary = EmployManager:getMyHireRoleDetailsByType( EnumFightStrategyType.StrategyType_BLOOY )
			if mercenary and mercenary.instanceId == roleGmId then
				self:setRoleIndex( 0, mercenary );
	    		mercenary.blood_tag 		= 0
			end
    	end
    end

    if data.stations then
		for k,v in pairs(data.stations) do
			local role = CardRoleManager:getRoleByGmid(v.roleId);
			if role then
				self:setRoleIndex( (v.index + 1), role );
	    		role.blood_tag 		= 1
	    		role.blood_maxHp	= v.maxHp
				role.blood_curHp    = v.currHp
			else
				local mercenary = EmployManager:getMyHireRoleDetailsByType( EnumFightStrategyType.StrategyType_BLOOY )
				if mercenary and mercenary.instanceId == v.roleId then
					print(v)
					self:setRoleIndex( (v.index + 1), mercenary );
		    		mercenary.blood_tag 	= 1
		    		mercenary.blood_maxHp	= v.maxHp
					mercenary.blood_curHp    = v.currHp
				end
			end
		end
	end
	print("1111111111111111111self.strategylist = ", self.strategylist)

	--CardRoleManager:UpdateRoleFate()
	self:updateAllFate(false)
	TFDirector:dispatchGlobalEventWith(self.UPDATE_GENERRAL_LIST);
	TFDirector:dispatchGlobalEventWith(self.MSG_REQUEST_ROLELIST_RESULT, {})
end


function BloodFightManager:getList()
	return self.strategylist
end

function BloodFightManager:requestStrategy()
	if self.requestStrategy == nil then
		showLoading();
    	TFDirector:send(c2s.QUERY_BLOODY_INFO,{});
	else
		self:openRoleList()
	end
end

function BloodFightManager:getPosByGmId( gmid )
	for i=1,9 do
		if self.strategylist[i] and self.strategylist[i] == gmid then
			return i
		end
	end
	return 0
end

function BloodFightManager:getRoleByIndex(index)
	local gmId = self.strategylist[index];
	-- ----print("gmid = ", gmId)
	if gmId == nil or gmId == 0 then
		return nil;
	end
	local role = CardRoleManager:getRoleByGmid(gmId);
	if role then
		return role , 0;
	end
	local mercenary = EmployManager:getMyHireRoleDetailsByType( EnumFightStrategyType.StrategyType_BLOOY )
	if mercenary and mercenary.instanceId == gmId then
		return mercenary , 1
	end
end

function BloodFightManager:setRoleIndex( index,role )
	--print("BloodFightManager:setRoleIndex = ", index)
	--print(self.strategylist)
    --安全判断
    if role == nil then
        self.strategylist[index] = 0;
        --print("shit = ")
        return;
    end

    --仅仅将卡牌下阵
	if index == 0 then
		if role.blood_pos and role.blood_pos ~= 0 then
        	self.strategylist[role.blood_pos] = 0
        	TFDirector:dispatchGlobalEventWith(self.UPDATE_STARTEGY_POS,role.blood_pos);
        	role.blood_pos = nil;
    	end
		return;
	end
    
    --已经在阵上，先下阵(要到新的位置去)
	if role.blood_pos and role.blood_pos ~= 0 then
    	self.strategylist[role.blood_pos] = 0;
		TFDirector:dispatchGlobalEventWith(self.UPDATE_STARTEGY_POS,role.blood_pos);
	end

    --原先的位置上有卡牌，先将其下阵（替换）
	local oldRole = self:getRoleByIndex(index);
	if oldRole then
	    oldRole.blood_pos = 0;
	end


	self.strategylist[index] = role.gmId or role.instanceId;



	TFDirector:dispatchGlobalEventWith(self.UPDATE_STARTEGY_POS,index);

	role.blood_pos = index;
	role.blood_tag = 1;

	--print("self.strategylist =", self.strategylist)
end

function BloodFightManager:getMercenaryById( instanceId )
	local mercenary = EmployManager:getMyHireRoleDetailsByType( EnumFightStrategyType.StrategyType_BLOOY )
	if mercenary and mercenary.instanceId == instanceId then
		return mercenary
	end
	return nil
end

--战阵请求处理结果成功，开始换
function BloodFightManager:changeStrategy(fromPos, toPos, roleGmId)



	local role = nil
	--选中目标不在阵上
	if fromPos == 0 then
		--目标位置是否已经有角色
		if toPos ~= 0  then
			--下阵
			role ,isMercenary= self:getRoleByIndex(toPos)
			if role then
				self:setRoleIndex(0,role)
				if isMercenary == 0 then
					role:updateFate()
				end
			end
		end
		--上阵
		role = CardRoleManager:getRoleByGmid(roleGmId)
		if role == nil then
			role = self:getMercenaryById(roleGmId)
		end
		self:setRoleIndex(toPos,role)
	else
		--下阵
		if toPos == 0  then
			role = CardRoleManager:getRoleByGmid(roleGmId)
			if role == nil then
				role = self:getMercenaryById(roleGmId)
				self:setRoleIndex(0,role)
			else
				self:setRoleIndex(0,role)
				role:updateFate()
			end
		--交换
		else
			role = self:getRoleByIndex(toPos)
			if role then
				self:setRoleIndex(fromPos,role)
			end
			role = CardRoleManager:getRoleByGmid(roleGmId)
			if role == nil then
				role = self:getMercenaryById(roleGmId)
			end
			self:setRoleIndex(toPos,role)
		end
	end

	print("2222 self.strategylist = ", self.strategylist)

	self:updateAllFate(true)
	TFDirector:dispatchGlobalEventWith(self.UPDATE_GENERRAL_LIST)

end

function BloodFightManager:getFightRoleNum()
	local num = 0;
	-- --print("self.strategylist11111 = ", self.strategylist)
	for i=1,10 do
		if self.strategylist[i] and self.strategylist[i] ~= 0 then
			num = num + 1;
		end
	end
	self.num = num;
	return num;
end

function BloodFightManager:getPower()
	if 1 then
		return AssistFightManager:getStrategyPower( LineUpType.LineUp_BloodyBattle )
	end

	local allPower = 0;
	for i=1,10 do
		if self.strategylist[i] and self.strategylist[i] ~= 0 then
			local role = CardRoleManager:getRoleByGmid(self.strategylist[i]);
			if role then
            	allPower = allPower + role:getpower();
            end
		end
	end
	return allPower;
end

function BloodFightManager:canAddFightRole()
	local num = self:getFightRoleNum();
	if self.maxNum > self.num then 
		return true;
	else
		return false;
	end
end

function BloodFightManager:getMaxNum()
	return self.maxNum;
end

--通过序号获取上阵角色实例。所谓序号是指不为空的战阵位置
function BloodFightManager:getFightRoleBySequence(sequence)
	local tmp = 0
	for i=1,10 do
		if self.strategylist[i] and self.strategylist[i] ~= 0 then
			tmp = tmp + 1
			if tmp == sequence then
				local role = CardRoleManager:getRoleByGmid(self.strategylist[i])
				return role
			end
		end
	end
	return nil
end

function BloodFightManager:getRoleTemplateIdTable()
	local table = {}
	for i=1,10 do
		if self.strategylist[i] and self.strategylist[i] ~= 0 then
			local role = CardRoleManager:getRoleByGmid(self.strategylist[i])
			table[i] = role.id
		end
	end
	return table
end

function BloodFightManager:getRoleByTemplateId(id)
	for i=1,10 do
		if self.strategylist[i] and self.strategylist[i] ~= 0 then
			local role = CardRoleManager:getRoleByGmid(self.strategylist[i])
			if role and role.id == id then 
				return role
			end
		end
	end
	return nil
end

--[[
更新所有战阵的角色的缘分
]]
function BloodFightManager:updateAllFate(showMessage)
	for i=1,10 do
		if self.strategylist[i] and self.strategylist[i] ~= 0 then
			local role = CardRoleManager:getRoleByGmid(self.strategylist[i])
			if role then
				role:updateFate(showMessage)
			end
		end
	end
end

-- 上阵
function BloodFightManager:OnBattle(gmid, posIndex)
	----print("上阵 ", gmid, posIndex)
    showLoading();
    TFDirector:send(c2s.BLOODY_TO_BATTLE,{{gmid, posIndex}})
end

-- 下阵
function BloodFightManager:OutBattle(gmid)
	--print("下阵 gmid  = ", gmid)
	----print("下阵", gmid)
    showLoading();
    TFDirector:send(c2s.BLOODY_OFF_BATTLE,{gmid})
end

-- 换位置
function BloodFightManager:ChangePos(oldPos, newPos)
	----print("换位置")
    showLoading();
    ----print({oldPos, newPos})
    TFDirector:send(c2s.BLOODY_CHANGE_STATION,{oldPos, newPos});
end

-- 查看信息
function BloodFightManager:lookPlayerInfo(playerId)
	showLoading();
	local InfoMsg = 			
	{
		playerId,
	}
	TFDirector:send(c2s.GET_PLAYER_DETAILS	, InfoMsg)
end

function BloodFightManager:getAttackRoleInfoRequest(event)
	hideLoading();

	self:openArmyInfo(event.data)
end

--打开角色详细信息
function BloodFightManager:openArmyInfo( userData  )

	----print("openArmyInfo:",userData)
	local section = userData.section

	-- local layer = AlertManager:addLayerByFile("lua.logic.bloodFight.BloodyArmyLayer",AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_1);
	local layer = AlertManager:addLayerByFile("lua.logic.bloodFight.BloodybattleOtherArmyVSLayer",AlertManager.BLOCK);
	TFDirector:dispatchGlobalEventWith(self.LOOK_PLAYE_INFO, layer)
	----print("section = "..section.."  self.curFightIndex"..self.curFightIndex)
	if section <= self.curFightIndex then
		layer.btn_army:setVisible(false)
	end

	layer:loadData(userData);
    AlertManager:show()
end

function BloodFightManager:getMapNum()
	return 3
end


function BloodFightManager:getCurMapIndex()
	return math.ceil(self.curFightIndex / 8)
end

function BloodFightManager:getMissionIndex()
	return self.curFightIndex
end

function BloodFightManager:getMissionTotalCount()
	return self.maxMissionCount
end

--血量列表
function BloodFightManager:onReceivePlayerList( event )

end

function BloodFightManager:onReceiveBloodyEnemyInfo(event)
	----print("onReceiveBloodyEnemyInfo:",event.data)

	local userData = event.data.enemyList[1]
	-- local cardList = userData.warside
	
	-- local layer = AlertManager:addLayerByFile("lua.logic.bloodFight.BloodyArmyLayer",AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_1);
	local layer = AlertManager:addLayerByFile("lua.logic.bloodFight.BloodybattleOtherArmyVSLayer",AlertManager.BLOCK);
	TFDirector:dispatchGlobalEventWith(self.LOOK_PLAYE_INFO, layer)
	
	-- userData.power = 100
	layer:loadData(userData);
	layer.section = userData.section
	hideLoading();

    AlertManager:show()



    if layer.section < self.curFightIndex then
        layer.btn_army:setVisible(false)
    end
        
end

function BloodFightManager:QueryBloodyEnemyInfo(index)

	showLoading();
	TFDirector:send(c2s.QUERY_BLOODY_ENEMY_INFO	, {index})
end

-- 获取血战详情 
function BloodFightManager:onReceiveBloodDetail( event )

	print("BloodFightManager:onReceiveBloodDetail")
	
	self.curFightIndex 			= event.data.currSection + 1 		--已过关最大关卡号
	self.coinInspireCount 		= event.data.coinInspireCount 		--铜币鼓舞次数
	self.sysceeInspireCount 	= event.data.sysceeInspireCount 	--元宝鼓舞次数
	self.dailyMaxInspireCount	= event.data.dailyMaxInspireCount 	--鼓舞上线

	--add by wkdai
	self.remainResetCount 		= event.data.resetCount 				--剩余重置次数

	-- local allEnemys = event.data.allEnemys
	-- for k,v in pairs(allEnemys) do
	-- 	local name_ 	= v.name -- npc名称
	-- 	local section 	= v.section -- 第几关(从1开始)

	-- 	if self.playerList[section] == nil then
	-- 		self.playerList[section] = {}
	-- 	end

	-- 	self.playerList[section].index 		= section
	-- 	self.playerList[section].name 		= name_
	-- 	self.playerList[section].playerId 	= v.roleId
	-- 	self.playerList[section].star 		= v.star
	-- end

	self:updateEnemyList(event.data.allEnemys)


	--更新箱子数据
	self:updateBoxList(event.data.BloodyBoxList)
	--初始化血战数据
	self:BloodFightInit()


	--为了区分和血战的缘分系统 add by king
	hideLoading();
    if self.PlayerIsInBloodFighting == false then
		--进入血战
			-- hideLoading();
		self:showHomeLayer()
	else
    	-- 在血战界面直接更新
    	--print("在血战界面直接更新")
    	-- TFDirector:dispatchGlobalEventWith(self.MSG_DAILY_RESET, {})
	end
	    --更新所有缘分
    CardRoleManager:UpdateRoleFate()

end

function BloodFightManager:EnterBlood()
	-- 初始化关卡相关信息
	self.playerList = {}
	for i=1,24 do
		local name_ 	= localizable.BloodFightManager_weikaiqi --"未开启"
		local section 	= i -- 第几关(从1开始)

		if self.playerList[section] == nil then
			self.playerList[section] = {}
		end

		self.playerList[section].index 		= section
		self.playerList[section].name 		= name_
		self.playerList[section].playerId 	= 10000000
		self.playerList[section].star 		= 1
	end

	showLoading();
	TFDirector:send(c2s.QUERY_BLOODY_DETAIL	, {})
end

--当前关卡更新
function BloodFightManager:onReceiveBattleSectionUpdate( event )
	--print("---- BloodFightManager:onReceiveBattleSectionUpdate --- ")
	
	-- BloodyEnemySimpleInfo enemy = 2;		//血战npc简单信息
	self:updateEnemyList(event.data.enemy)

	local currSection = event.data.currSection 	--已过关最大关卡号
	-- self.curFightIndex = event.data.currSection + 1 	--已过关最大关卡号
	if currSection then
		--print("self.curFightIndex = ", self.curFightIndex)
		--print("currSection = ", currSection)
		if self.curFightIndex ~= (currSection + 1) then
			self.curFightIndex = currSection + 1
			--当前调整成功
			--print("更新怪点 = ",{last = currSection, now = self.curFightIndex})
			TFDirector:dispatchGlobalEventWith(self.MSG_BATTLE_RESULT, {last = currSection, now = self.curFightIndex})
		
			-- 开启宝箱
			local boxIndex = math.floor(currSection/4)

			if self.boxList and self.boxList[boxIndex] then
				if self.boxList[boxIndex].got == 0 then
					self.boxList[boxIndex].got = 3
					TFDirector:dispatchGlobalEventWith(self.MSG_UPDATE_BOX, {index = boxIndex})
				end

				-- -- 关闭之前那个宝箱 20141016
				-- local lastBoxIndex = boxIndex-1
				-- if lastBoxIndex >= 1 then
				-- 	-- if self.boxList[lastBoxIndex].got == 0 then
				-- 		self.boxList[lastBoxIndex].got = 2
				-- 		TFDirector:dispatchGlobalEventWith(self.MSG_UPDATE_BOX, {index = lastBoxIndex})
				-- 	-- end
				-- end
			end

		end
	end

end
	
--当前鼓舞更新
function BloodFightManager:onReceiveInspireUpdate( event )
	hideLoading();
	local coinInspireCount 		= event.data.coinInspireCount 	--铜币鼓舞次数
	local sysceeInspireCount 	= event.data.sysceeInspireCount --元宝鼓舞次数
	if coinInspireCount and sysceeInspireCount then
		self.coinInspireCount 	= coinInspireCount
		self.sysceeInspireCount = sysceeInspireCount
		--当前调整成功
		TFDirector:dispatchGlobalEventWith(self.MSG_INSPIRE_RESULT, {})
	end
end

function BloodFightManager:inspireUpgrade(inspireType)
	showLoading();
	TFDirector:send(c2s.BLOODY_INSPIRE, {inspireType})
end


function BloodFightManager:openRoleList(section)
	-- CardRoleManager:setBloodLvLimit(0)
	EmployManager:requestAllEmployInfo()
	local layer =  AlertManager:addLayerByFile("lua.logic.bloodFight.BloodFightArmyLayer",AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_1)
 	layer.section = section
 	AlertManager:show()
end

function BloodFightManager:requestRoleList()
	showLoading();
    TFDirector:send(c2s.QUERY_BLOODY_INFO,{});
end

function BloodFightManager:showHomeLayer()

	-- 侠客等级达到10级或以上才能参加血战
	
    AlertManager:addLayerByFile("lua.logic.bloodFight.BloodybattleMainLayer.lua");
    AlertManager:show();
end


function BloodFightManager:showBoxLayer(boxIndex)
	local box = self.boxList[boxIndex]
	----print("box = ", box)
	if box.got == 3 then
	    local layer = AlertManager:addLayerByFile("lua.logic.bloodFight.BloodReward.lua",AlertManager.BLOCK_AND_GRAY)--,AlertManager.TWEEN_1);
		layer:loadBoxData(boxIndex, box.data);
    elseif box.got == 1 or box.got == 2 then
	    local layer = AlertManager:addLayerByFile("lua.logic.bloodFight.BloodRewardBuy.lua",AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_1);
		layer:loadBoxData(boxIndex, box.data, box.needResType, box.cost);
    end

    AlertManager:show();
end

-- 开始抽奖
function BloodFightManager:beginGetPrize(boxIndex, bAction)
    local box = self.boxList[boxIndex]
    local layer = nil

    if bAction == nil or bAction == false then
    	layer = AlertManager:addLayerByFile("lua.logic.bloodFight.BloodRewardBuy.lua",AlertManager.BLOCK_AND_GRAY)--,AlertManager.TWEEN_1);
	elseif bAction == true then
		layer = AlertManager:addLayerByFile("lua.logic.bloodFight.BloodRewardBuy.lua",AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1);
	end

	-- layer:loadBoxData(boxIndex, box.data);
	layer:loadBoxData(boxIndex, box.data, box.needResType, box.cost);
    AlertManager:show();
end

function BloodFightManager:updateBoxList(BloodyBoxList)
	--print("BloodFightManager:updateBoxList = ", BloodyBoxList)
	for k,v in pairs(BloodyBoxList) do
		local boxIndex 	= v.index 		-- 
		local status 	= v.status      --
		-- ----print("boxIndex = ", index)
		if self.boxList[boxIndex] == nil then
			self.boxList[boxIndex] = {}
			self.boxList[boxIndex].data = {}
			-- ----print("self.boxList is nil")
		end

		-- 宝箱状态
		-- self.boxList[boxIndex].got 	 = status
		self.boxList[boxIndex].got 	 = 0
		self.boxList[boxIndex].index = boxIndex
		self.boxList[boxIndex].needResType  = v.needResType
		self.boxList[boxIndex].cost  = v.needResNum

	-- 		required int32 needResType 	= 4; 	//购买需要的资源类型
	-- required int32 needResNum 	= 5; 	//购买需要的资源数量

		local gotPrizecount = 0

		----print("boxList = ", boxList)
		for j,l in pairs(v.BloodyBoxList) do
			local prizeIndex 		= l.index 		-- 
			local id 				= l.rewardId      --
			local needResType 		= l.needResType      --
			local cost 				= l.needResNum      --
			local isGet 			= l.bIsget      --
			
			local type 		= l.type
			local number 	= l.number
			local itemId	= l.itemId

			if self.boxList[boxIndex].data[prizeIndex] == nil then
				self.boxList[boxIndex].data[prizeIndex] = {}
			end

			self.boxList[boxIndex].data[prizeIndex].index  		= prizeIndex
			self.boxList[boxIndex].data[prizeIndex].id  	 	= id
			self.boxList[boxIndex].data[prizeIndex].needResNum  = cost
			self.boxList[boxIndex].data[prizeIndex].needResType = needResType
			self.boxList[boxIndex].data[prizeIndex].isGet  		= isGet
			-- 物品详细
			self.boxList[boxIndex].data[prizeIndex].number  	= number
			-- 奖品类型
			self.boxList[boxIndex].data[prizeIndex].type  		= type
			-- 奖品id
			self.boxList[boxIndex].data[prizeIndex].itemId  	= itemId

			
			if isGet then
				gotPrizecount = gotPrizecount + 1
			end
		end

		--是否可领
		local boxOpenMissionIndex = 4 * boxIndex
		if boxOpenMissionIndex < self.curFightIndex then
			self.boxList[boxIndex].got = 1 -- 当前奖励可领取
			if gotPrizecount == 0 then
				self.boxList[boxIndex].got = 3 -- 一个都没有领过
			elseif gotPrizecount == 3 then	
				self.boxList[boxIndex].got = 2 -- 当前奖励已领完
			end
		else
			--是否全部领完
			if gotPrizecount == 3 then
				self.boxList[boxIndex].got = 2 -- 当前奖励已领完
			end
		end

		local boxMaxIndex = math.floor(self.curFightIndex/4)
		
		-- -- 只开启最新的一个宝箱 20141016
		-- if boxIndex < boxMaxIndex then
		-- 	self.boxList[boxIndex].got = 2 -- 当前奖励已领完
		-- else
		-- 	-- 是否全部领完
		-- 	-- if gotPrizecount == 3 then
		-- 	if gotPrizecount >= 1 then
		-- 		self.boxList[boxIndex].got = 2 -- 当前奖励已领完
		-- 	end
		-- end

		-- -- 		--是否全部领完
		-- if gotPrizecount == 3 then
		-- 	self.boxList[boxIndex].got = 2 -- 当前奖励已领完
		-- end

		-- self.boxList[boxIndex].got = 3
	end

end

function BloodFightManager:updateEnemyList(EnemyList)
	--print("BloodFightManager:updateEnemyList = ", EnemyList)

	if EnemyList == nil then
		--print("EnemyList is nil")
		return
	end

	local allEnemys = EnemyList
	for k,v in pairs(allEnemys) do
		local name_ 	= v.name -- npc名称
		local section 	= v.section -- 第几关(从1开始)

		if self.playerList[section] == nil then
			self.playerList[section] = {}
		end

		self.playerList[section].index 		= section
		self.playerList[section].name 		= name_
		self.playerList[section].playerId 	= v.roleId
		self.playerList[section].star 		= v.star
	end
end

function BloodFightManager:onReceiveBoxUpdate( event )
	self:updateBoxList(event.data.BloodyBoxList)
	----print("BloodFightManager:onReceiveBoxUpdate = ", event.data)
	local index_ 		= event.data.BloodyBoxList[1].index --宝箱索引
	local prizeIndex_ 	= event.data.index -- 宝箱内奖励的索引
	local getType_ 		= event.data.getType -- 获取类型(1-免费领取，2-购买)

	hideLoading()
	TFDirector:dispatchGlobalEventWith(self.MSG_UPDATE_BOX, {index = index_, prizeIndex = prizeIndex_, getType = getType_})
end

function BloodFightManager:buyBox(boxIndex, prizeIndex)
	----print("BloodFightManager:buyBox = "..boxIndex.."/"..prizeIndex)
	showLoading();
    TFDirector:send(c2s.GET_BLOODY_BOX, {boxIndex, prizeIndex, 2}) --
end

function BloodFightManager:choose(boxIndex, prizeIndex)
	----print("BloodFightManager:choose = "..boxIndex.."/"..prizeIndex)
	showLoading();
    TFDirector:send(c2s.GET_BLOODY_BOX, {boxIndex, prizeIndex, 1}) --//1：免费领取 2：购买
end

function BloodFightManager:Attack(section)
    ----print("BloodFightManager.Attack = ",section) 
    showLoading();
    TFDirector:send(c2s.CHALLENGE_BLOODY_ENEMY, {section})
end

function BloodFightManager:CheckAllRuleReachBeforeAttack()
	local totalHp 		= 0 --上阵的总血量
	local numOnFight 	= 0 --上阵的人数
	for i=1,10 do
		if self.strategylist[i] and self.strategylist[i] ~= 0 then
			local role = CardRoleManager:getRoleByGmid(self.strategylist[i])
			if role ~= nil then
				numOnFight 	= numOnFight + 1
				totalHp 	= totalHp + role.blood_curHp
			else
				local mercenary = self:getMercenaryById(self.strategylist[i])
				if mercenary then
					numOnFight 	= numOnFight + 1
					totalHp 	= totalHp + mercenary.hp
				end
			end
		end
	end

	if numOnFight == 0 then
		-- toastMessage("至少上阵一人")
		toastMessage(localizable.BloodFightManager_zhishaoshangzhenyiren)
		return false
	end

	if numOnFight > 0 and totalHp <= 0 then
		-- toastMessage("阵上的人已全部阵亡，请重新布阵")
		toastMessage(localizable.BloodFightManager_quanzhenwang)
		return false
	end
	
	return true
end

function BloodFightManager:getPlayer(index)
	return self.playerList[index]
end

function BloodFightManager:getPlayerStaus(index)
	if index == self.curFightIndex then
		return self.PLAYER_NOW
	elseif index < self.curFightIndex then
		return self.PLAYER_PASS
	elseif index > self.curFightIndex then
		return self.PLAYER_LOCK
	end
end

function BloodFightManager:getBox(index)
	return self.boxList[index]
end

function BloodFightManager:getBoxStaus(index)
	local status = self.boxList[index].got

end


function BloodFightManager:getInfo(index)
	return self.battleNodeList[index]
end

function BloodFightManager:BloodFightInit()
	-- self.playerList     = {}					--挑战角色的列表
	-- self.boxList     	= {}					--宝箱列表
	-- self.battleNodeList = {}

	-- for i=1,24 do
	-- 	local name_ = string.format("Player%d",i)
	-- 	local player = {index = i, playerId = "2539", name = name_, star = 2}
	-- 	table.insert(self.playerList, player)
	-- end

	-- for i=1,6 do
	-- 	local boxInfo = {{index = 1, type = 1, id = 30018, num = 1, cost = 100, isGet = true},{index = 2, type = 1, id = 30018, num = 2,  cost = 100, isGet = false},{index = 3, type = 1, id = 30018,num = 3, cost = 100,  isGet = true}}
	-- 	local box = {index = i, boxId = "12314", got = 1, data = boxInfo} -- 0 1 2
	-- 	table.insert(self.boxList, box)
	-- end

	local playerCount = 0
	local boxIndCount = 1
	local totalIndex  = 1
	-- 
	for i=1,#self.playerList do
		local info      = {type = 1, index = i}
		table.insert(self.battleNodeList, info)
		-- 
		self.playerList[i].totalIndex = totalIndex
		totalIndex = totalIndex + 1
		--

		playerCount = playerCount + 1
		if playerCount == 4 then
			local box      = {type = 2, index = boxIndCount}
			table.insert(self.battleNodeList, box)
			boxIndCount = boxIndCount + 1
			playerCount = 0

			--
			totalIndex = totalIndex + 1
		end
	end

end

--[[
准备重置雁门关
]]
function BloodFightManager:prepareResetManual()
	-- 初始化关卡相关信息
	self.playerList = {}
	for i=1,24 do
		local name_ 	= localizable.BloodFightManager_weikaiqi --"未开启"
		local section 	= i -- 第几关(从1开始)

		if self.playerList[section] == nil then
			self.playerList[section] = {}
		end

		self.playerList[section].index 		= section
		self.playerList[section].name 		= name_
		self.playerList[section].playerId 	= 10000000
		self.playerList[section].star 		= 1
	end
end

--[[
手动重置雁门关
]]
function BloodFightManager:requestResetManual()
	showLoading()
	TFDirector:send(c2s.RESET_BLOODY_REQUEST,{})
end

--[[
手动重置雁门关成功
]]
function BloodFightManager:onReceiveResetSuccess(event)
	hideLoading()
	self.remainResetCount = event.data.remainResetTime
	TFDirector:dispatchGlobalEventWith(self.MSG_RESET_MANUAL, event.data)
end

-- --打开角色详细信息
-- function BloodFightManager:openRoleInfo( cardRoleGmid )
--    local layer = AlertManager:addLayerByFile("lua.logic.role.RoleInfoLayer",AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_1);
--    local cardRole = self:getRoleByGmid(cardRoleGmid);
--    local selectIndex = self.cardRoleList:indexOf(cardRole);
--    layer:loadSelfData(selectIndex);
--    AlertManager:show();
-- end

function BloodFightManager:requestBloodySweep(layer)
	self.BloodySweepLayer = layer
	self.showQuickPassLayer = true

	showLoading()
	TFDirector:send(c2s.BLOODY_SWEEP_REQUEST,{})
end

function BloodFightManager:bloodySweepResult( event )
	hideLoading()
    local datalist = event.data.result
    print('bloodySweepResult = ',event.data)   
    -- datalist = {}
    -- for j=1,2 do
    --     datalist[j] = {}
    --     datalist[j].exp = 0
    --     datalist[j].oldLevel = 0
    --     datalist[j].currentLevel = 0
    --     datalist[j].coin = 0
    --     datalist[j].sectionId = j
    --     datalist[j].item = {}
    --     for i=1,2 do
    --         datalist[j].item[i] = {}
    --         datalist[j].item[i].type = EnumDropType.COIN
    --         datalist[j].item[i].number = 10000
    --         datalist[j].item[i].itemId = 3000
    --     end       
    -- end
    
    
    local ccdata = {}
    for i=1,#datalist do
        ccdata[i] = {}
        ccdata[i].currLev = datalist[i].currentLevel
        ccdata[i].addCoin = datalist[i].coin
        ccdata[i].addExp = datalist[i].exp
        ccdata[i].oldLev = datalist[i].oldLevel
        ccdata[i].itemlist = datalist[i].item
        self.curFightIndex = datalist[i].sectionId
        --更新宝箱
	    local boxIndex = math.floor(self.curFightIndex/4)
	    if self.boxList and self.boxList[boxIndex] then
	    	self.boxList[boxIndex].got = 3
		end	
    end

    

    -- self.showQuickPassLayer = true
    local layer = AlertManager:addLayerByFile("lua.logic.bloodFight.BloodyQuickPassLayer",AlertManager.BLOCK_AND_GRAY_CLOSE,AlertManager.TWEEN_1);
    layer:loadData(ccdata, self.curFightIndex, self.BloodySweepLayer)
    
    AlertManager:show();	
end
return BloodFightManager:new();