------------------------------------------------------
--2018/05/10
--zengqingfeng
------------------------------------------------------
module(..., package.seeall)

local require = require

local BASE = i3k_entity;
		
local CROP_BUFF_WET = 1
local CROP_BUFF_CARE = 2
local CROP_BUFF_HARVEST = 3
local CROP_BUFF_STEAL = 4

-- 不同状态下标题的显示与否
local titleState = {
	-- 依次是名字，倒计时+产量，进度条, 和二级状态的显示
	[g_CROP_STATE_LOCK] = {
		name = true, time = false, bar = false, 
		[CROP_BUFF_WET] = false, [CROP_BUFF_CARE] = false, [CROP_BUFF_HARVEST] = false, [CROP_BUFF_STEAL] = false
	}, 
	[g_CROP_STATE_UNLOCK] = {
	    name = true, time = false, bar = false, 
		[CROP_BUFF_WET] = false, [CROP_BUFF_CARE] = false, [CROP_BUFF_HARVEST] = false, [CROP_BUFF_STEAL] = false
	},
	[g_CROP_STATE_SEED] = {
		name = true, time = true, bar = true, 
		[CROP_BUFF_WET] = true, [CROP_BUFF_CARE] = false, [CROP_BUFF_HARVEST] = false, [CROP_BUFF_STEAL] = false
	},
	[g_CROP_STATE_STRONG] = {
		name = true, time = true, bar = true, 
		[CROP_BUFF_WET] = true, [CROP_BUFF_CARE] = true, [CROP_BUFF_HARVEST] = false, [CROP_BUFF_STEAL] = false
	},
	[g_CROP_STATE_MATURE] = {
		name = true, time = false, bar = false, 
		[CROP_BUFF_WET] = false, [CROP_BUFF_CARE] = false, [CROP_BUFF_HARVEST] = true, [CROP_BUFF_STEAL] = true
	},
}

local iconCfg = i3k_db_home_land_base.cropStateIcon
local buffImg = {
	[CROP_BUFF_WET] = iconCfg.waterIcon,
	[CROP_BUFF_CARE] = iconCfg.careIcon,
	[CROP_BUFF_HARVEST] = iconCfg.harvestIcon,
	[CROP_BUFF_STEAL] = iconCfg.stealIcon,
}

local titleMul = {
	["name"] = {uitype = "text", x = 0, w = 3, y = 1.25, h = 0.5, name = "name", labelId = nil},
	["time"] = {uitype = "text", x = 0, w = -2, y = 0.3, h = 0.35, name = "time", labelId = nil},
	["bar"] = {uitype = "bar", x = -1.0, w = 2, y =  -1.0, h = 0.15, name = "bar", labelId = nil},
	[CROP_BUFF_WET] = {uitype = "img", x = -1.7, w = 1, y = -2.8, h = 1},
	[CROP_BUFF_CARE] = {uitype = "img", x = -0.7, w = 1, y = -2.8, h = 1},
	[CROP_BUFF_HARVEST] = {uitype = "img", x = 0.3, w = 1, y = -2.8, h = 1},
	[CROP_BUFF_STEAL] = {uitype = "img", x = 0.3, w = 1, y = -2.8, h = 1},
}

-- 植物不同状态的动画
local stateStandAction = {
	[g_CROP_STATE_SEED] = i3k_db_home_land_base.cropActCfg.actSeed,
	[g_CROP_STATE_STRONG] = i3k_db_home_land_base.cropActCfg.actStrong,
	[g_CROP_STATE_MATURE] = i3k_db_home_land_base.cropActCfg.actMature,
}

local showBuffPos = {
	CROP_BUFF_CARE, CROP_BUFF_HARVEST, CROP_BUFF_WET, CROP_BUFF_STEAL
}

local transAction = {
	--[[[g_CROP_STATE_STRONG] = "shengji1",
	[g_CROP_STATE_MATURE] = "shengji2",--]]
}

------------------------------------------------------
i3k_crop = i3k_class("i3k_crop", BASE);
function i3k_crop:ctor(guid)
	self._entityType	= eET_Crop;
	self:CreateActor()
end

function i3k_crop:Create(gid, id, typeId, groundIndex)
	self._gid		= gid; -- 土地序列号
	self._iid		= id;  -- 土地模型id
	self._typeid    = typeId; -- 土地类型id
	--self._roleId    = roleId -- 所有者id -- 暂时没用
	self._groundIndex = groundIndex -- 同一类型地块的序号
	self._cropState = g_CROP_STATE_LOCK; -- 土地的一级状态
	self._ground    = nil    -- 上次保存的ground数据
	
	-- <常数>
	--ground.key            int32
	--ground.groundId:		int32	
	--ground.typeId:		int32	
	--ground.groundIndex    int32
	--ground._plantCfg    --种植表
	-- </常数>
	
	-- <变量>
	--ground.level:		int32	--等于0的时候未解锁是空模型
	-- 可能为空
	--ground.curPlant:		DBHomelandPlant	
		--curPlant.id:		int32	
		--curPlant.plantTime:		int32	
		--curPlant.lastWaterTime:		int32	
		--curPlant.waterTimes:		map[int32, int32]	
		--curPlant.lastStealTime:		int32	
		--curPlant.lastNurseTime:		int32	
		--curPlant.nurseTimes:		int32	
		--curPlant.lastHarvestTime:		int32	
		--curPlant.harvestTimes:		int32	
		--curPlant.plantLevel:		int32	
	-- </变量>
	
	self._update_cd = 0.5
	self._countdown = 0    -- 倒计时 默认为0
	self._countdownMax = 0
	self._seedInfo = {} 
	self._strongInfo = {}
	-- 可并存的二级状态 
	self._crop_buff = {
		[CROP_BUFF_WET]     = false, -- 是否需要浇水
		[CROP_BUFF_CARE]    = false, -- 是否需要护理 
		[CROP_BUFF_HARVEST] = false, -- 是否可以收货
		[CROP_BUFF_STEAL]   = false, -- 是否可以偷窃
	}
	self.txtInfo = {
		["name"] = {name = "name", labelId = nil},
		["time"] = {name = "time", labelId = nil},
		["bar"] = {name = "bar", labelId = nil},
	}
	
	if self._entity then
		self._entity:SyncScenePos(self:IsPlayer());
	end
	self:createModel(id)
end

function i3k_crop:OnLogic(dTick)
	BASE.OnLogic(self, dTick);
end

function i3k_crop:createModel(id)
	local mcfg = i3k_db_models[id];
	if mcfg then
		self._resCreated = 0
		self._name		= mcfg.desc;
		self._dropEff	= mcfg.dropEff;
		if name then
			self._name = "haha"; -- 临时参数
		end

		if self._entity:CreateHosterModel(mcfg.path, string.format("entity_%s", self._gid)) then -- 这里路径会不会有问题
			self._baseScale = mcfg.scale;
			self:SetScale(self._baseScale);

			self._title = self:CreateTitle();
			self._entity:EnterWorld(false);
			self:SetFaceDir(self._faceDir.x, self._faceDir.y + i3k_db_home_land_base.baseCfg.cameraAngle, self._faceDir.z)
		end
	end
end 

function i3k_crop:CreateTitle()
	self._needUpdateTitle = false
	local _T = require("logic/entity/i3k_entity_title");
	if self._title and self._title.node then
		self._title.node:Release();
		self._title.node = nil;
	end
	self._title = nil;
	local title = { };
	title.node = _T.i3k_entity_title.new();
	if title.node:Create("crop_title_node_" .. self._guid) then
		local color = tonumber("0xffffff00", 16)
		title.nameTb = {}
		local showCfg = titleState[self:getCropState()]
		local showBuffNum = 0
		for k, e in pairs(titleMul) do
			if showCfg[k] then 
				if e.uitype == "text" then 
					local info = self.txtInfo[k]
					title.nameTb[k] = title.node:AddTextLable(e.x, e.w, e.y, e.h, color, info.name);
					info.labelId = title.nameTb[k]
				elseif e.uitype == "bar" then 
					title.nameTb[k] = title.node:AddBloodBar(e.x, e.w, e.y, e.h, false);
					self.txtInfo[k].labelId = title.nameTb[k]
				elseif self._crop_buff[k] then 
					showBuffNum = showBuffNum + 1
					local path = g_i3k_db.i3k_db_get_scene_icon_path(buffImg[k])
					local posE = titleMul[showBuffPos[showBuffNum]]
					title.nameTb[k] = title.node:AddImgLable(posE.x, posE.w, posE.y, posE.h, path);
				end
			end 
		end
	else
		title.node = nil;
	end

	if title.node then
		title.node:SetVisible(true);
		title.node:EnterWorld();
		self._entity:AddTitleNode(title.node:GetTitle(), i3k_db_models[self._iid].titleOffset);
	end
	self._title = title 
	return title;
end

function i3k_crop:IsAttackable(attacker)
	return false;
end

-- 更换模型
function i3k_crop:changeModel(id)
	if id == self._iid then -- 无需切换
		return 
	end
	local mcfg = i3k_db_models[id];
	if mcfg then
		self._name		= mcfg.desc;
		self._dropEff	= mcfg.dropEff;

		if self._entity:ChangeHosterModel(mcfg.path, string.format("entity_%s", self._gid), false, mcfg.titleOffset) then
			self._baseScale = mcfg.scale;
			self:SetScale(self._baseScale);
		end 
		self._iid = id
	end 
end 

-- 植物外观随状态变化
function i3k_crop:changeActionByState(state, isChange)
	--[[if not self:isPlant() then -- 非植物状态不需要更换动作 
		return 
	end --]]
	
	--[[local alist = {}
	if isChange then 
		if transAction[state] then 
			table.insert(alist, {actionName = transAction[state], actloopTimes = 1})
		end
	end 
	local act = stateStandAction[state] or "stand"
	table.insert(alist, {actionName = act, actloopTimes = -1})
	self:PlayActionList(alist, -1, true)--]]
	
	local act = stateStandAction[state] or "stand"
	self:Play(act, -1, true)
end 

function i3k_crop:OnSelected(val, ready)
	BASE.OnSelected(self, val)
	
	if not val then 
		return false
	end 
	
	local curState = self:getCropState()
	if curState == g_CROP_STATE_UNLOCK then    -- 空地状态，打开种子面板	
		self:openPlantUI()
	elseif curState == g_CROP_STATE_LOCK then  -- 锁定状态，打开土地升级面板
		self:openGroundLvlUpUI()
	else                                       -- 植物状态，打开操作面板（需要区分主客）
		self:openOperateUI()	
	end
end

function i3k_crop:OnUpdate(dTime)
	BASE.OnUpdate(self, dTime)
	
	self._update_cd = self._update_cd - dTime
	self._countdown = math.max(self._countdown - dTime, 0)
	if self._update_cd <= 0 then 
		self._update_cd = 0.5
	else 
		return 
	end 
	
	local ground = self._ground
	local curPlant = ground.curPlant
	
	-- 不同状态的特殊处理 植物状态不是很复杂就不用状态机了
	local curState = self:getCropState()
	if curState == g_CROP_STATE_STRONG then 
		if curPlant then 
			self:updateBuffState(CROP_BUFF_CARE, g_i3k_game_context:homelandCheckCanCare(ground, curState))
		end 
	end
	
	-- 更新当前的二级状态 
	if curPlant and curState == g_CROP_STATE_SEED or curState == g_CROP_STATE_STRONG then 
		self:updateBuffState(CROP_BUFF_WET, g_i3k_game_context:homelandCheckCanWater(ground, curState))
	end 

	if curPlant and curState == g_CROP_STATE_MATURE then 
		if g_i3k_game_context:isInMyHomeLand() then 
			self:updateBuffState(CROP_BUFF_STEAL, false)
			self:updateBuffState(CROP_BUFF_HARVEST, g_i3k_db.i3k_db_checkCanHarvestCrop(ground))
		else
			self:updateBuffState(CROP_BUFF_HARVEST, false)
			self:updateBuffState(CROP_BUFF_STEAL, g_i3k_db.i3k_db_checkCanStealCrop(ground))
		end
	end

	-- 是否需要刷新模型标题或者只是需要刷新时间文本
	if self._needUpdateTitle then 
		self:CreateTitle()
	elseif curState == g_CROP_STATE_SEED or curState == g_CROP_STATE_STRONG then -- 成长倒计时
		self:updateGrowTime()
	end
end

function i3k_crop:updateGrowTime()	
	if self._countdown <= 0 then 
		self._countdown = 0 
		-- 倒计时已到需要新的后端信息（或者前端自己转换）
		self:updateInfo()
	end 
	local timeStr = i3k_get_time_show_text(self._countdown)
	self:updateUILabelText("time", timeStr)
	self._title.node:UpdateBloodBar(self.txtInfo["bar"].labelId, (1 - self._countdown / self._countdownMax))
end 

function i3k_crop:onItemCropOperate(operateType, arg1, arg2)
	--self.operateType:		int32
		-- （1偷窃土地 2浇水 3护理 5土地升级 <上方对应图标消失，重新计算生长时间和成熟产量>）
		-- （4种植 6收获                     <需要其他协议的数据来刷新>）
	--self.arg1:		int32  1幼苗 2健壮 3成熟 -- 土地升级的话就是土地等级
	local isInMyHomeland = g_i3k_game_context:isInMyHomeLand()
    local curTime = i3k_game_get_time()
	if operateType == 1 then -- 偷窃
		self._ground.curPlant.lastStealTime = curTime -- 更新偷窃时间cd
--[[		if not isInMyHomeland then 
			self._countdown = i3k_db.i3k_db_getStealLeftTime(self._ground.curPlant)
		end --]]
	elseif operateType == 2 then -- 浇水 
		g_i3k_game_context:addWaterTimes(self._ground.curPlant, self._cropState)
		self._ground.curPlant.lastWaterTime = curTime
		self:changeActionByState(self._cropState, true)
	elseif operateType == 3 then -- 护理
		self._ground.curPlant.nurseTimes = self._ground.curPlant.nurseTimes + 1
		self._ground.curPlant.lastNurseTime = curTime
		self:changeActionByState(self._cropState, true)
	elseif operateType == 4 then -- 种植新作物(之前是空地)
		g_i3k_game_context:initPlantData(self._ground, arg1, arg2)
	elseif operateType == 5 then -- 土地升级
		self._ground.level = arg1
		if self._ground.level > 1 then 
			return
		end 
	elseif operateType == 6 then -- 收获
		-- 需要收获的协议获取获得的产量
		-- 不过这里可以更新次数的信息，当收获次数用完更新植物状态
		self._ground.curPlant.lastHarvestTime = curTime 
		self._ground.curPlant.harvestTimes = self._ground.curPlant.harvestTimes + 1 
	--[[	if isInMyHomeland then 
			self._countdown = i3k_db.i3k_db_getHarvestLeftTime(self._ground.curPlant)
		end --]]
		if g_i3k_db.i3k_db_checkHarvestFinished(self._ground) then 
			self._ground.curPlant = nil -- 收获完毕移除植物
		end
	elseif operateType == 7 then  -- 移除植物
		self._ground.curPlant = nil 
	else 
		g_i3k_ui_mgr:PopupTipMessage("未知土地操作")
	end
	
	-- 根据数据更新表现
	self:updateInfo()
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_HomelandPlantOperate, "onOperate", self)
end 

-- 根据当前数据来更新
function i3k_crop:updateInfo(ground)
	if not ground then 
		ground = self._ground
	else 
		self._ground = ground
	end 
	
	if ground.groundId ~= self._gid or ground.groundType ~= self._typeid then 
		return false 
	end
	
	local newState, isChange = self:getNewCropState(ground)
	self._needUpdateTitle = isChange
	
	self:changeActionByState(newState, isChange) -- 植物的动作切换
	self:updateGround(ground)
end

-- 根据当前数据和状态更新(当状态被提前确定的时候)
function i3k_crop:updateGround(ground) 
	local newState = self:getCropState()
		-- 不同状态的特殊处理
	self:updateGroundModel(ground) 
	self:updateUILabelText("name", i3k_db.i3k_db_getCropNameByState(ground, newState))
	
	--self._ground = ground
	
	-- 将新数据保存到全局 可能没有用因为大部分情况下这里的引用就是来自于全局
	local homelandMapData = g_i3k_game_context:getHomelandMapData()
	homelandMapData.grounds[ground.key] = ground 
end 

-- <状态相关函数>
-- 根据信息计算新的状态
function i3k_crop:getNewCropState(ground)
	local newState = nil 
	local oldState = self:getCropState()
	
	if not ground.level or ground.level <= 0 then 
		newState = g_CROP_STATE_LOCK
	elseif self:isPlant() then -- 有植物的情况
		newState, self._seedInfo, self._strongInfo = self:getCurPlantStep(ground)
		if newState == g_CROP_STATE_SEED then 
			self._countdown = self._seedInfo.curLeftTime
			self._countdownMax = self._seedInfo.realGrowTime 
		elseif newState == g_CROP_STATE_STRONG then 
			self._countdown = self._strongInfo.curLeftTime
			self._countdownMax = self._strongInfo.realGrowTime 
		elseif newState == g_CROP_STATE_MATURE then 
--[[		if g_i3k_game_context:isInMyHomeLand() then 
				self._countdown = i3k_db.i3k_db_getHarvestLeftTime(ground.curPlant)
			else 
				self._countdown = i3k_db.i3k_db_getStealLeftTime(ground.curPlant)
			end
			--]]
		end
	else 
		newState = g_CROP_STATE_UNLOCK
	end
	
	self:setCropState(newState)
	return newState, oldState ~= newState
end 

function i3k_crop:getCurPlantStep(ground)
	if not self:isPlant() then 
		return g_CROP_STATE_LOCK
	end 
	
	return g_i3k_db.i3k_db_getCurPlantStep(ground.curPlant, ground._plantCfg)
end

function i3k_crop:setCropState(newState)
	if newState then 
		self._cropState = newState
	end 
end 

function i3k_crop:getCropState()
	return self._cropState or g_CROP_STATE_LOCK
end  

function i3k_crop:updateBuffState(key ,value)
	if value ~= nil then 
		if self._crop_buff[key] ~= value then 
			self._needUpdateTitle = true
			self._crop_buff[key] = value
		end
	end
end  

-- 更新地块模型(有必要的话)
function i3k_crop:updateGroundModel(ground)
	local emptyModelID = g_i3k_db.i3k_db_getGroundEmptyModelID(ground.groundId)
	if not self:isPlant() then -- 没有植物状态
		if self._iid ~= emptyModelID then  -- 空地状态之前的模型还不是空地的话就要更换模型了
			self._needUpdateTitle = true 
			self:changeModel(emptyModelID)
		end
	else 
		local plantModelID = ground._plantCfg.modelID
		if self._iid == emptyModelID or self._iid ~= plantModelID then 
			self._needUpdateTitle = true
			self:changeModel(plantModelID) -- 更换成植物的模型
		end
	end
end 

function i3k_crop:updateUILabelText(key, value)
	local info = self.txtInfo[key]
	if not info then 
		return 
	end
	
	if info.name ~= value and self._title and self._title.node then 
		self._title.node:UpdateTextLable(info.labelId, value, true, tonumber("0xffffff00", 16), false);
		info.name = value
	end
end 
-- </状态判断相关函数>
-- 家园种植界面
function i3k_crop:openPlantUI()
	if g_i3k_game_context:isInMyHomeLand() then 
		g_i3k_logic:openPlantUI(self._typeid, self._groundIndex, self._ground.level)
	end 
end 

-- 土地升级界面
function i3k_crop:openGroundLvlUpUI()
	if g_i3k_game_context:isInMyHomeLand() then 
		g_i3k_logic:openHomelandStructureUI(self._gid)
	end 
end 

-- 土地操作界面（偷取，护理，浇水，收获)
function i3k_crop:openOperateUI()
	g_i3k_logic:openOperateUI(self)
end 

-- 现在是不是植物
function i3k_crop:isPlant()
	return (self._ground.curPlant ~= nil and next(self._ground.curPlant))
end 
-- </界面开启函数>

function i3k_crop:ValidInWorld()
	return true
end
