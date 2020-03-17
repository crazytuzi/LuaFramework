_G.Collection = {}
local metaCollection = {__index = Collection}

function Collection:NewCollection(configId, cid, x, y, faceto)
	local cfgCollection = t_collection[configId]
	if not cfgCollection then
		Error("don't exist this Collection configId" .. configId)
		return
	end
	local collection = {}
	setmetatable(collection, metaCollection)
	collection.configId = configId
	collection.cid = cid
	collection.x = x
	collection.y = y
	collection.__type = "collection"
	collection.faceto = faceto
	collection.avatar = CollectionAvatar:NewCollectionAvatar(configId, cid)
	local cfg = collection:GetCfg();
	if cfg and cfg.isHideLoading == 0 then
		collection.avatar.avatarLoader:beginRecord(true)
	end
	collection.avatar:InitAvatar()
	if cfg and cfg.isHideLoading == 0 then
		collection.avatar.avatarLoader:endRecord()
	end
	collection.isShowHeadBoard = true			-- 不在任务中需要隐藏
	if cfgCollection.taskType == 1 then
		if not QuestController:CheckCollect(configId) then
			collection.isShowHeadBoard = false
		else
			collection.isShowHeadBoard = true
		end
	elseif cfgCollection.taskType == 3 then 
		if DungeonController:CheckCollect(configId) then
			collection.isShowHeadBoard = true
		else
			collection.isShowHeadBoard = false
		end
	end
	
	return collection
end

function Collection:GetconfigId()
	return self.configId
end

--获取Collection对象的配表
function Collection:GetCfg()
	if not t_collection[self.configId] then
		Debug("cannot find Collection in table.CollectionId:" .. self.configId)
		return
	end
	return t_collection[self.configId]
end

function Collection:GetPos()
	if self.avatar then
		return self.avatar:GetPos()
	else
		return {x = self.x, y = self.y}
	end
end

function Collection:GetAvatar()
	return self.avatar
end

function Collection:GetDir()
	if self.avatar then
		return self.avatar:GetDirValue()
	else
		return self.faceto
	end
end

function Collection:ShowCollection()
	self.avatar:EnterMap(self.x, self.y, self.faceto)
	self.avatar:ExecIdleAction()
end

local pos = _Vector3.new()
local name2d = _Vector2.new()
local name2ds = _Vector2.new()
local pos2d = _Vector2.new()
local collectionFont = _Font.new("SIMHEI", 11, 0, 1, true)
function Collection:Update()
	if not self.isShowHeadBoard then --不是采集任务
		return
	end 
	--if self.isHideName then --不是采集任务

	--	return
	--end
	if self.isHide then
		return
	end
	
	local configId = self.configId
	local cfgCollection = t_collection[configId]
	if not cfgCollection then
		return
	end
	local name = cfgCollection.name
	local name_swf = cfgCollection.name_swf
	local name_image = cfgCollection.name_image
	local cfg = CUICardConfig[999]
	-- local name2d = _Vector2.new()
    local mePos = self:GetPos()
	if not mePos then return end
    pos.x = 0
    pos.y = 0
    pos.z = cfgCollection.height or 1

    pos.x = mePos.x + pos.x
    pos.y = mePos.y + pos.y
    pos.z = mePos.z + pos.z
    _rd:projectPoint( pos.x, pos.y, pos.z, pos2d)
    --name
   if name_swf and name_swf ~= "" then
		name2d.x, name2d.y = pos2d.x, pos2d.y + 24
		if not self.nameLoader and not self.nameSwf then
			local loader = _Loader.new()
			self.nameLoader = loader
			loader:load("resfile/swf/" .. name_swf)
			loader.lowPriority = false
			loader:onFinish(function()
				if not self.nameSwf then
					self.nameLoader = nil
					self.nameSwf = CResStation:GetImage("resfile/swf/" .. name_swf) 
				end
			end)
		end
		if self.nameSwf then
			self.nameSwf:drawImage(name2d.x - self.nameSwf.w/2, name2d.y - self.nameSwf.h/2, name2d.x + self.nameSwf.w/2, name2d.y + self.nameSwf.h/2)
		end
	elseif name_image and name_image ~= "" then
		name2d.x, name2d.y = pos2d.x, pos2d.y + 24
		local nameImage = CResStation:GetImage(name_image)
		nameImage:drawImage(name2d.x - nameImage.w / 2, name2d.y - nameImage.h, name2d.x + nameImage.w / 2, name2d.y)
	elseif name and name ~= "" then
	    name2d.x, name2d.y = pos2d.x, pos2d.y + 24
	    if self:CheckCollectDistance() then
			collectionFont.edgeColor = cfg.can_collect_edgeColor
		    collectionFont.textColor = cfg.can_collect_textcolor
		else
			collectionFont.edgeColor = cfg.cannot_collect_edgeColor
		    collectionFont.textColor = cfg.cannot_collect_textcolor
		end
	    collectionFont:drawText(name2d.x, name2d.y,
	        name2d.x, name2d.y, name, _Font.hCenter + _Font.vTop)
	end

	--adder:houxudong
	--date:2016/7/30
	-- 北仓界活动采集物头上显示数字
	--3D映射到屏幕坐标
	--[[
	if ActivityController:GetCurrId() == ActivityConsts.Beicangjie or ActivityController:GetCurrId() == ActivityConsts.Beicangjie2 then
		_rd:projectPoint(pos.x, pos.y, pos.z, name2ds)
		self.headBoardX = round(name2ds.x)
		self.headBoardY = round(name2ds.y)
		local x = name2ds.x
		local y = name2ds.y
		local score = t_beicangjiecaiji[configId] and t_beicangjiecaiji[configId].score or 0
		if score > 0 then
			local scoreString = tostring(score)
			local nLen = string.len(scoreString)
			local scale = 0.5
	        for nY = nLen, 1, -1 do
	            local szIndex = string.char(scoreString:byte(nY))
	            local img = CResStation:GetImage(ResUtil:GetLingzhiIcon(szIndex))
	            img:drawImage(x - img.w * scale, y - img.h * scale, x, y)
	             x = x - img.w * scale
	        end
	    end
	end
	--]]
end

-- isHide 隐藏掉自己 显示自己 
function Collection:HideSelf(isHide)
	self.isHide = isHide;
	local avatar = self:GetAvatar()
	if not avatar then
		return
	end
	if not avatar.objNode then
		return
	end
	if not avatar.objNode.entity then
		return
	end
	if isHide then
		avatar.objNode.visible = false
	else
		if StoryController:IsStorying() then return end
		avatar.objNode.visible = true
	end
end

function Collection:Open()
	local avatar = self:GetAvatar()
	if not avatar then
		return
	end
	local modelId = avatar.modelId
	if not modelId then
		return
	end
	local look = _G.t_model[modelId]
	if not look then
		return
	end

	local cfgCollection = self:GetCfg()

	local deadFile = look.san_dead
	if deadFile and deadFile ~= "" then
		if self.openTimePlan then
			TimerManager:UnRegisterTimer(self.openTimePlan)
		end

		local opentime = cfgCollection.opentime
		if opentime > 0 then
			self.openTimePlan = TimerManager:RegisterTimer(function()
				if avatar then
		        	avatar:StopAllAction()
					avatar:ExecAction(deadFile, false)
				end
		    end, opentime, 1)
		else
			avatar:StopAllAction()
			avatar:ExecAction(deadFile, false)
		end
	end

	local sfxId = cfgCollection.sfxId
	if sfxId and sfxId ~= 0 then
		SoundManager:PlaySfx(sfxId)
	end

	local selfPlayer = MainPlayerController:GetPlayer()
	if selfPlayer then
		local selfAvatar = selfPlayer:GetAvatar()
		if selfAvatar then
			local pfxId = cfgCollection.pfxId
			if pfxId and pfxId ~= "" then
			    selfAvatar:PlayerPfxOnSkeleton(pfxId)
			end
		end
	end
	

end

function Collection:SetCollectionState()
	self.collected = true
end

function Collection:GetCollectionState()
	return self.collected
end

function Collection:FadeOut()
	if self.fadeTimePlan then
		TimerManager:UnRegisterTimer(self.fadeTimePlan)
	end
	local cfgCollection = self:GetCfg()
	local aftertime = cfgCollection.aftertime
	if aftertime > 0 then
		local cid = self.cid;
		self.fadeTimePlan = TimerManager:RegisterTimer(function()
	        CollectionController:DestroyCollection(cid)
	    end, aftertime, 1)
	end
end

function Collection:GetAfterTime()
	local configId = self.configId
	local cfgCollection = t_collection[configId]
	return cfgCollection.aftertime
end

function Collection:GetCid()
	return self.cid
end

function Collection:Born()
	local avatar = self:GetAvatar()
	if not avatar then
		return
	end
	local modelId = avatar.modelId
	if not modelId then
		return
	end
	local look = _G.t_model[modelId]
	if not look then
		return
	end
	local bornFile = look.san_born
	if not bornFile and bornFile == "" then
		return
	end
	avatar:ExecAction(bornFile, false)
end

function Collection:StopMove(x, y, faceto)
	local currPos = self:GetPos()
	if not currPos then
		return
	end
	local vecPos = {x = x, y = y}
	self.avatar:StopMove(vecPos, faceto)
end

function Collection:MoveTo(x, y)
	local speed = self:GetSpeed()
	local vecPos = {x = x, y = y}
	self.avatar:MoveTo(vecPos, function()
		self.avatar:StopMove()
	end, speed)
end


function Collection:GetSpeed()
	return self.speed
end

function Collection:SetSpeed(speed)
	self.speed = speed
end

function Collection:CheckCollectDistance()
	local selfPlayer = MainPlayerController:GetPlayer()
	if not selfPlayer then
		return false
	end
	local conllectionId = self.configId
	local config = t_collection[conllectionId]
	if not config then
		return false
	end
	local pos1 = selfPlayer:GetPos()
	local pos2 = self:GetPos()
	if not pos1 or not pos2 then
		return false
	end
	
	local config_dis = config.distance
	local dis = GetDistanceTwoPoint(pos1, pos2)
	if dis >= config_dis then
		return false
	end
	return true
end