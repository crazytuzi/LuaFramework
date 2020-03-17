--[[
人物头顶血条
]]
_G.classlist['PlayerHeadBoard'] = 'PlayerHeadBoard'
_G.PlayerHeadBoard = {};
PlayerHeadBoard.objName = 'PlayerHeadBoard'

function PlayerHeadBoard:new(urlArray, vUrl, player, realmUrl)
	local obj = {}
	setmetatable(obj,{__index = PlayerHeadBoard});
	obj.headBoardX = nil
	obj.headBoardY = nil
	
	obj.playerNameWidth = nil
	obj.dwNewEdgeColor = nil
	
	obj.dwNewTextColor = nil--角色名
	obj.guildTextColor = nil--帮派名 
	
	obj.pkTextColor = nil--pk名
	obj.pkTextEdgeColor = nil
	obj.pk_width = 0
    obj.pk_height = 0
	obj.pkprotectStr = nil
	obj.guildName = nil
	
	obj.backHp = nil
    obj.frontHp = nil
	obj.namePos = _Vector3.new()
	obj.isRender = true
	obj.starTitleDic = {};
	obj.loaderList = {};
	obj.titleInfoList = {};
	obj.titleInfoList = self:OnChangeTitleInfo(urlArray);
	if #urlArray > 0 then
		for i , v in pairs(urlArray) do
			if not obj.starTitleDic then obj.starTitleDic = {} end
			if not obj.starTitleDic[i] then
				local loader = _Loader.new()
				loader.lowPriority = false;
				obj.loaderList[i] = loader;
				loader:load(v)
				loader:onFinish(function()
					if obj.starTitleDic then
						obj.starTitleDic[i] = _Image.new(v)
					end
					obj.loaderList[i] = nil;
				end)
			end
		end
	else
		obj.levelTitle = self:GetLevelTitleInfo(player);
	end
	obj.vImg = nil;
	if vUrl then
		obj.vImg = CResStation:GetImage(vUrl);
	end
	-- obj.zhuanzhiImg = nil
	obj.realmImg = nil;
	if realmUrl then
		obj.realmImg = CResStation:GetImage(realmUrl);
	end
	player = nil;
    return obj;
end

function PlayerHeadBoard:Update(player,showHp)
	if ToolsController.hideUI then return; end
	if not player then return end
	if not self.isRender then return end
	self:CalculateBoard(player,showHp)
	player = nil
end

function PlayerHeadBoard:Destory()
	self.isRender = false

	self.headBoardX = nil
	self.headBoardY = nil
	
	self.playerNameWidth = nil
	self.dwNewEdgeColor = nil
	
	self.dwNewTextColor = nil--角色名
	self.guildTextColor = nil--帮派名 
	
	self.pkTextColor = nil--pk名
	self.pkTextEdgeColor = nil
	self.pk_width = 0
    self.pk_height = 0
	self.pkprotectStr = nil
	self.guildName = nil
	self.backHp = nil
    self.frontHp = nil
	self.starTitleDic = nil
	self.levelTitle = nil
	-- self.zhuanzhiImg = nil
end


function PlayerHeadBoard:DrawHeadBoard()
	
end

local pos3d = _Vector3.new()
local ret2d = _Vector2.new()
function PlayerHeadBoard:GetNamePos(player)
	if not player then return nil end

	local mePos = player:GetPos()
	local posX,posY,posZ = mePos.x, mePos.y, mePos.z
	local horseId = player:GetHorseID()
	local prof = player.playerInfo[enAttrType.eaProf]

	pos3d.x = posX
	pos3d.y = posY
	if horseId > 0 then
		pos3d.z = posZ + PlayerHeadBoard:GetNameHeight(horseId, prof) * scale
	else
		pos3d.z = posZ + CUICardConfig["nameHeight"][prof] * scale
	end

	--3D映射到屏幕坐标
	_rd:projectPoint(pos3d.x, pos3d.y, pos3d.z, ret2d)
	player = nil
	return ret2d
end

local playerFont = _Font.new("SIMHEI", 11, 0, 1, true) --名字
local playerFont1 = _Font.new("SIMHEI", 11, 0, 1, true) --名字
local hp2d = _Vector2.new()
local name2d = _Vector2.new()
local pos = _Vector3.new()
local mat = _Matrix3D.new()


local pos1 = _Vector3.new()
function PlayerHeadBoard:CalculateBoard(player,showHp)
	if not player then return end
	if RenderConfig.batch == true then _rd.batchId = 1 end;

	local mePos = player:GetPos()
	local boneMat = nil
	if player:IsDead() then
		local avatar = player:GetAvatar()
		if avatar and avatar.objNode then
			local skl = avatar:GetSkl()
			if skl then
    			boneMat = skl:getBone("beatpoint")
    			if boneMat then
    				boneMat.parent = avatar.objNode.transform
    				boneMat:getTranslation(pos1)
        		end
			end
		end
	end
	local scale = player:GetScale()
	local posX, posY, posZ = 0, 0, 0
	if boneMat then
		posX, posY, posZ = pos1.x, pos1.y, pos1.z + 5
	else
		posX, posY, posZ = mePos.x, mePos.y, mePos.z + 5
	end
	local horseId = player:GetHorseID()
	local prof = player.playerInfo[enAttrType.eaProf]
	local name = player.playerInfo[enAttrType.eaName]
	local guildName = player.guildName
	local nameChanged = player.nameChanged
	local guildNameChanged = player.guildNameChanged
	local pkState = player:GetPKState()
	local eaHp = player.playerInfo[enAttrType.eaHp]
	local eaMaxHp = player.playerInfo[enAttrType.eaMaxHp]
	local titleImgUrl = player.titleImgUrl

	pos.x = posX
	pos.y = posY
	if horseId > 0 then
		pos.z = posZ + PlayerHeadBoard:GetNameHeight(horseId, prof) * scale
	else
		pos.z = posZ + CUICardConfig["nameHeight"][prof] * scale
	end

	--3D映射到屏幕坐标
	_rd:projectPoint(pos.x, pos.y, pos.z, name2d)
	self.headBoardX = round(name2d.x)
	self.headBoardY = round(name2d.y)
	--显示血条的
	if showHp then
		if not self.frontHp then
			self.frontHp = CResStation:GetImage("hp_temp.png")
			self.backHp =  CResStation:GetImage("hp_back_temp.png")
		end
	    local hpRate = 1
		if eaHp and eaMaxHp then
			hpRate =  eaHp/eaMaxHp
		else
			hpRate =  1
		end
		if hpRate < 0 then
			hpRate = 0
		end
	    hp2d.x = self.headBoardX - 45
	    hp2d.y = self.headBoardY
		if self.backHp then
			self.backHp:drawImage(hp2d.x, hp2d.y, hp2d.x + 90, hp2d.y + 7)
			self.frontHp:drawImage(hp2d.x + 1 , hp2d.y + 1, hp2d.x + 1 + 89 * hpRate , hp2d.y + 6)
		end
		self.headBoardY = self.headBoardY - CUICardConfig.hpZ
	end

	--显示名字和PK相关的
	--自己和别人名字颜色
	if player:IsSelf() then
        self.dwNewTextColor = CUICardConfig.nameColor.self_textcolor
        self.dwNewEdgeColor = CUICardConfig.nameColor.self_edgeColor
    else
        self.dwNewTextColor = CUICardConfig.nameColor.other_textcolor
        self.dwNewEdgeColor = CUICardConfig.nameColor.other_edgeColor
    end

	self.pkprotectStr = ""
	self.pk_width = 0
	local midNight = player:GetNightState()
	if midNight then
		self.pkprotectStr = StrConfig['skill1000003']
		self.pkTextColor = self.dwNewTextColor
		self.pkTextEdgeColor = self.dwNewEdgeColor
	else
		--if pkState == 1 then 		--新手
			-- self.pkprotectStr = StrConfig['skill1000002']
			-- self.pkTextColor = self.dwNewTextColor
			-- self.pkTextEdgeColor = self.dwNewEdgeColor
		if pkState == 2 then 	--红名
			player.pkColorState = 2;
		elseif pkState == 3 then 	--灰名
			player.pkColorState = 1;
		elseif pkState == 4 then 	--PK保护== false
			self.pkprotectStr = StrConfig['skill1000001']
			self.pkTextColor = self.dwNewTextColor
			self.pkTextEdgeColor = self.dwNewEdgeColor
		end
	end
	

	if self.pkprotectStr ~= "" then
		self.pk_width = playerFont1:stringWidth(self.pkprotectStr)
		playerFont1.textColor = self.pkTextColor
		playerFont1.edgeColor = self.pkTextEdgeColor
		player.pkColorState = 0
	end

	if player.pkColorState == 1 then		
		self.dwNewTextColor = CUICardConfig.nameColor.self_mgraycolor
		self.dwNewEdgeColor = CUICardConfig.nameColor.self_tgraycolor
	elseif player.pkColorState == 2 then
		self.dwNewTextColor = CUICardConfig.nameColor.self_readcolor
		self.dwNewEdgeColor = CUICardConfig.nameColor.self_graycolor
	end
	
	--把所有敌人颜色变红！！！！！！！！  i++
	if CPlayerMap:GetCurrMapIsPk() then
		if MainRolePKModel:GetPKIndex() == 1 then
			if not player:IsSelf() then
				if not TeamModel:IsTeammate(player.dwRoleID) then
					self.dwNewTextColor = CUICardConfig.nameColor.self_readcolor
					self.dwNewEdgeColor = CUICardConfig.nameColor.self_graycolor
				end
			end
		elseif MainRolePKModel:GetPKIndex() == 2 then
			if not player:IsSelf() then
				if UnionModel.MyUnionInfo.guildId ~= player.guildId then
					self.dwNewTextColor = CUICardConfig.nameColor.self_readcolor
					self.dwNewEdgeColor = CUICardConfig.nameColor.self_graycolor
				end
			end
		elseif MainRolePKModel:GetPKIndex() == 3 then
			if not player:IsSelf() then
				local selfServerId = InterServicePvpModel:GetGroupId()
				local otherServerId = player:GetServerId()
				if selfServerId ~= 0 then
					if selfServerId ~= otherServerId then
						self.dwNewTextColor = CUICardConfig.nameColor.self_readcolor
						self.dwNewEdgeColor = CUICardConfig.nameColor.self_graycolor
					end
				end
			end
		elseif MainRolePKModel:GetPKIndex() == 4 then
			--阵营判断
			if not player:IsSelf() then
				if player.camp ~= ActivityZhanChang:GetMyCamp() then
					self.dwNewTextColor = CUICardConfig.nameColor.self_readcolor
					self.dwNewEdgeColor = CUICardConfig.nameColor.self_graycolor
				end
			end
		elseif MainRolePKModel:GetPKIndex() == 5 then
			if not player:IsSelf() then
				if pkState == 2 then
					self.dwNewTextColor = CUICardConfig.nameColor.self_readcolor
					self.dwNewEdgeColor = CUICardConfig.nameColor.self_graycolor
				end
			end
		elseif MainRolePKModel:GetPKIndex() == 6 then
			if not player:IsSelf() then
				if pkState ~= 1 and pkState ~= 4 then
					self.dwNewTextColor = CUICardConfig.nameColor.self_readcolor
					self.dwNewEdgeColor = CUICardConfig.nameColor.self_graycolor
				end
			end
		elseif MainRolePKModel:GetPKIndex() == 7 then  --自定义 仍然缺少机制
			if not player:IsSelf() then
				if MainRolePKModel.PKData[1].pkBoolean then 
					if  player.guildId == '0_0' or UnionModel.MyUnionInfo.guildId ~= player.guildId then
						self.dwNewTextColor = CUICardConfig.nameColor.self_readcolor
						self.dwNewEdgeColor = CUICardConfig.nameColor.self_graycolor
					end
				end
				if MainRolePKModel.PKData[2].pkBoolean then
					if player.guildId == '0_0' or UnionModel.MyUnionInfo.alianceGuildId ~= player.guildId then
						self.dwNewTextColor = CUICardConfig.nameColor.self_readcolor
						self.dwNewEdgeColor = CUICardConfig.nameColor.self_graycolor
					end
				end
				if MainRolePKModel.PKData[3].pkBoolean then-- 敌对帮派
					
				end
				if MainRolePKModel.PKData[4].pkBoolean then
					if not TeamModel:IsTeammate(player.dwRoleID) then
						self.dwNewTextColor = CUICardConfig.nameColor.self_readcolor
						self.dwNewEdgeColor = CUICardConfig.nameColor.self_graycolor
					end
				end
				if MainRolePKModel.PKData[5].pkBoolean then
					if pkState ~= 2 then
						self.dwNewTextColor = CUICardConfig.nameColor.self_readcolor
						self.dwNewEdgeColor = CUICardConfig.nameColor.self_graycolor
					end
				end
				if MainRolePKModel.PKData[6].pkBoolean then
					if pkState ~= 3 then
						self.dwNewTextColor = CUICardConfig.nameColor.self_readcolor
						self.dwNewEdgeColor = CUICardConfig.nameColor.self_graycolor
					end
				end
			end
		end
	end
	
	if not self.playerNameWidth or nameChanged then
		self.playerNameWidth = playerFont:stringWidth(name)
	end
	playerFont.edgeColor = self.dwNewEdgeColor
    playerFont.textColor = self.dwNewTextColor
    local nameX = self.headBoardX - round((self.pk_width + self.playerNameWidth)/2)
    local nameY = self.headBoardY
    playerFont:drawText(nameX, nameY, nameX, nameY, name, _Font.hLeft + _Font.vCenter)
    if self.pkprotectStr ~= "" then
    	local pkX = self.headBoardX + round((self.playerNameWidth - self.pk_width)/2)
    	local pkY = self.headBoardY + 1
		playerFont1:drawText(pkX, pkY, pkX, pkY, self.pkprotectStr, _Font.hLeft + _Font.vCenter)
	end
	
	self.headBoardY = self.headBoardY - CUICardConfig.nameZ

	--帮派名
	if not self.guildName or guildNameChanged then
		if player:IsSelf() then
			if UnionUtils:CheckMyUnion() then 
				self.guildTextColor = CUICardConfig.nameColor.selfGuild_textcolor
				self.guildName = UnionModel.MyUnionInfo.guildName
			else
				self.guildTextColor = nil
				self.guildName = nil
			end
		else
			if UnionUtils:CheckMyUnion() then 
				if guildName and guildName ~= '' then
					if UnionModel.MyUnionInfo.guildId == player.guildId then
						self.guildTextColor = CUICardConfig.nameColor.selfGuild_textcolor
					else
						self.guildTextColor = CUICardConfig.nameColor.otherGuild_textcolor
					end
					if UnionModel.MyUnionInfo.alianceGuildId == player.guildId then
						self.guildTextColor = CUICardConfig.nameColor.selfAlianceGuildId_textColor
					end
					self.guildName = guildName
				else
					self.guildTextColor = nil
					self.guildName = nil
				end
			else
				if guildName and guildName ~= '' then
					self.guildTextColor = CUICardConfig.nameColor.otherGuild_textcolor
					self.guildName = guildName
				else
					self.guildTextColor = nil
					self.guildName = nil
				end
			end
		end
	end

		-- smart
	if player.camp == 6 or player.camp == 7 then
		local camp = player.camp
		local imageFile = ""
		if camp == 7 then
			imageFile = "ZhChCamp_B.png";
		elseif camp == 6  then 
			imageFile = "ZhChCamp_A.png";
		end
		local ZHChCamp = CResStation:GetImage(imageFile)
		local headX = self.headBoardX + (self.playerNameWidth/2) + 5;
		local headY = self.headBoardY - 20;
		ZHChCamp:drawImage(round(headX),
						   round(headY + ZHChCamp.h),
						   round(headX + ZHChCamp.w),
						   round(headY + (ZHChCamp.h*2))
						   );
	end;
	--player:GetStateInfoByType(PlayerState.UNIT_BIT_WITH_FLAG)
	local haveFlag = player.carryFlagState
	if haveFlag then
		local ZHChFlag = CResStation:GetImage("ZhChCamp_Flag.png")
		local headX = self.headBoardX +(self.playerNameWidth/2) + (ZHChFlag.w*2) - 5--+ round(ZHChFlag.w*3.5);
		local headY = self.headBoardY + round(ZHChFlag.h) - 5;
		ZHChFlag:drawImage(round(headX),
						   round(headY),
						   round(headX + round(ZHChFlag.w)),
						   round(headY + round(ZHChFlag.h))
						   );
	end
	
	if self.guildName then
		playerFont.textColor = self.guildTextColor
		playerFont.edgeColor = self.dwNewEdgeColor
		playerFont:drawText(self.headBoardX, self.headBoardY, self.headBoardX, self.headBoardY, '<'..self.guildName..'>', _Font.hCenter + _Font.vTop)
		self.headBoardY = self.headBoardY - CUICardConfig.guildNameZ
	end

	local partnerName = player:GetPartnerName()
	if player:IsSelf() then
		partnerName = MarryUtils:GetTitleName()
	end;
	if partnerName and partnerName ~= "" then
		local profId = player:GetProf()
		local str = ""
		if profId == 1 or profId == 4 then
			str = StrConfig["marriage0nv"]
		else
			str = StrConfig["marriage0na"]
		end
		str = partnerName .. str
		playerFont.textColor = CUICardConfig.nameColor.partner_textcolor
		playerFont.edgeColor = CUICardConfig.nameColor.partner_edgeColor
		playerFont:drawText(self.headBoardX, self.headBoardY, self.headBoardX, self.headBoardY, str, _Font.hCenter + _Font.vTop)
		self.headBoardY = self.headBoardY - CUICardConfig.guildNameZ
	end
	
	--活动id
	if ActivityController:GetCurrId() == ActivityConsts.Beicangjie or ActivityController:GetCurrId() == ActivityConsts.Beicangjie2 and player:GetLingZhi() ~= 0 then
		local lingzhi = player:GetLingZhi()
		local lingzhiLevel = player:GetLingzhiLevel()
		if lingzhi and lingzhiLevel then
			local bcLevelImg = CResStation:GetImage(ResUtil:GetBCLevelIcon(lingzhiLevel))
			local bcLevelImg1 = CResStation:GetImage(ResUtil:GetBCLevelIcon1(lingzhiLevel))
			bcLevelImg:drawImage(self.headBoardX - round(bcLevelImg.w), self.headBoardY - bcLevelImg.h + 20, self.headBoardX, self.headBoardY + 20)  --画出第一个图标
			bcLevelImg1:drawImage(self.headBoardX, self.headBoardY - bcLevelImg1.h + 20, self.headBoardX + bcLevelImg1.w, self.headBoardY + 20)      --画出第二个图标
			if player:IsSelf() then
				local x = self.headBoardX - round(bcLevelImg.w) - 10
				local y = self.headBoardY + 17
				local scale = 0.5
				local lingzhiString = tostring(lingzhi)
				local nLen = string.len(lingzhiString)
		        for nY = nLen, 1, -1 do
		            local szIndex = string.char(lingzhiString:byte(nY))
		            local img = CResStation:GetImage(ResUtil:GetLingzhiIcon(szIndex))
		            img:drawImage(x - img.w * scale, y - img.h * scale, x, y)
	                x = x - img.w * scale
		        end
		    end
		end
	elseif InterServicePvpModel:GetIsInCrossBoss() then
		local treasure = player:GetTreasure()
		if treasure and treasure > 0 then
			local x = self.headBoardX
			local y = self.headBoardY + 17

			local treasureImg = CResStation:GetImage(ResUtil:GetTreasureIcon())
			treasureImg:drawImage(x - treasureImg.w / 2,
				y - treasureImg.h,
				x + treasureImg.w / 2,
				y)

			x = x + treasureImg.w * 0.7
			y = y

			local treasureString = tostring(treasure)
			local nLen = string.len(treasureString)
	        for nY = 1, nLen do
	            local szIndex = string.char(treasureString:byte(nY))
	            local img = CResStation:GetImage(ResUtil:GetBossNumberIcon(szIndex))
	            img:drawImage(x - img.w, y - img.h, x, y)
                x = x + img.w
	        end
		end
	elseif InterContestModel:GetIsInContest() then
		local treasure = player:GetTreasure()
		if treasure and treasure > 0 then
			local x = self.headBoardX
			local y = self.headBoardY + 17

			local treasureString = tostring(treasure)
			local nLen = string.len(treasureString)
	        for nY = 1, nLen do
	            local szIndex = string.char(treasureString:byte(nY))
	            local img = CResStation:GetImage(ResUtil:GetBossNumberIcon(szIndex))
	            img:drawImage(x - img.w, y - img.h, x, y)
                x = x + img.w
	        end
		end
	else
		if not MainMenuController.inHideTitleMap then
--			if CGameApp.bIsActive then
			if _sys.fps > 6 then
				if player:IsSelf() or not SetSystemModel:GetIsShowTitle() then
					if #self.starTitleDic > 0 then
						for i = 1 , #self.starTitleDic do
							local titleImg = self.starTitleDic[i]
							local titleInfo = self.titleInfoList[i]
							if titleImg then
								if i == 1 then
									self.headBoardY =  self.headBoardY - titleInfo.titleBottom;
								end
								titleImg:drawImage(self.headBoardX - round(titleInfo.titleWidth*titleInfo.titlescale/2), self.headBoardY - titleInfo.titleHeight*titleInfo.titlescale/2,
								self.headBoardX + round(titleInfo.titleWidth*titleInfo.titlescale/2), self.headBoardY + titleInfo.titleHeight*titleInfo.titlescale/2);
								local nextInfo = self.titleInfoList[i + 1];
								if nextInfo then
									self.headBoardY = self.headBoardY - nextInfo.titleinterval	;
								end
							end
						end
					else
						if self.levelTitle then
							local lt = self.levelTitle;
							self.headBoardY =  self.headBoardY - lt.titleBottom;
							if lt.titleImg then
								lt.titleImg:drawImage(self.headBoardX - round(lt.titleWidth*lt.titlescale/2), self.headBoardY - lt.titleHeight*lt.titlescale/2,
									self.headBoardX + round(lt.titleWidth*lt.titlescale/2), self.headBoardY + lt.titleHeight*lt.titlescale/2);
							end
						end
					end
				end
			end
		else
			if MainMenuController.inShowFightMap then
				local x = self.headBoardX ;
				local y = self.headBoardY + 15
				local scale = 1
				local fight = toint(player:GetPlayerInfoByType(enAttrType.eaFight));
				local fightString = tostring(getNumShow(fight,true));
				local nLen = string.len(fightString)
				
				local fightImg = CResStation:GetImage("activityFight_v.png")
				
				x = x + fightImg.w / 2;
				
				for nY = nLen, 1, -1 do
					local szIndex = string.char(fightString:byte(nY));
					local img = CResStation:GetImage(ResUtil:GetActivityFight(szIndex))
					x = x + img.w / 2;
				end
				for nY = nLen, 1, -1 do
					local szIndex = string.char(fightString:byte(nY));
					local img = CResStation:GetImage(ResUtil:GetActivityFight(szIndex))
					img:drawImage(x - img.w * scale, y - img.h * scale, x, y)
					x = x - img.w * scale
				end
				fightImg:drawImage(x - fightImg.w * scale, y - fightImg.h * scale, x, y)
				x = x - fightImg.w * scale
			end
		end
		if player.vflag > 0 and self.vImg then
			self.vImg:drawImage(nameX - self.vImg.w, nameY - self.vImg.h / 2, nameX, nameY + self.vImg.h / 2)
		end
		-- if player.zhuanZhiLv > 0 then
		-- 	self.zhuanzhiImg = self.zhuanzhiImg or CResStation:GetImage(t_transferattr[player.zhuanZhiLv].icon)
		-- 	local nValue = self.vImg and self.vImg.w or 0
		-- 	self.zhuanzhiImg:drawImage(nameX - nValue - self.zhuanzhiImg.w, nameY - self.zhuanzhiImg.h/2, nameX - nValue, nameY + self.zhuanzhiImg.h/2)
		-- end
		if player.realm > 0 and self.realmImg then
			if player.vflag > 0 and self.vImg then
				self.realmImg:drawImage(nameX - self.realmImg.w - self.vImg.w, nameY - self.realmImg.h / 2, nameX - self.vImg.w , nameY + self.realmImg.h / 2)
			else
				self.realmImg:drawImage(nameX - self.realmImg.w, nameY - self.realmImg.h / 2, nameX, nameY + self.realmImg.h / 2)
			end
		end
	end
	
	if RenderConfig.batch == true then _rd.batchId = 0 end
	player = nil
end

function PlayerHeadBoard:OnChangeTitleSWF(urlArray, player)
	self.starTitleDic = {}
	for _ , loader in pairs(self.loaderList) do
		if loader then
			loader:stop();
			loader = nil;
		end
	end
	if #urlArray > 0 then
		for i , v in pairs(urlArray) do
			if not self.starTitleDic[i] then
				local loader = _Loader.new()
				loader.lowPriority = false;
				self.loaderList[i] = loader;
				loader:load(v)
				loader:onFinish(function()
					if self.starTitleDic then
						self.starTitleDic[i] = _Image.new(v)
						self.loaderList[i] = nil;
					end
				end)
			end
		end
	else
		self.levelTitle = self:GetLevelTitleInfo(player);
	end
	self.titleInfoList = {};
	self.titleInfoList = self:OnChangeTitleInfo(urlArray);
	player = nil;
end

function PlayerHeadBoard:OnChangeTitleInfo(urlArray)
	local obj = {};
	for i , v in ipairs(urlArray) do
		obj[i] = {};
		local cfg1 = split(v,'/');
		local cfg2 = split(cfg1[3],'.');
		for j , k in pairs(t_title) do
			if k.bigIcon == cfg2[1] then
				obj[i].titleWidth = k.titleWidth;
				obj[i].titleHeight = k.titleHeight;
				obj[i].titleinterval = k.titleinterval;
				obj[i].titlescale = k.titlescale;
				obj[i].titleBottom = k.titleBottom or 20;
				obj[i].id = k.id;
			end
		end
	end
	return obj
end

function PlayerHeadBoard:GetLevelTitleInfo(player)
	local obj = {};
	local lv = player:GetPlayerInfoByType(enAttrType.eaLevel);
	local cfg;
	for i = #t_leveltitle, 1, -1 do
		if lv >= t_leveltitle[i].lvtitle then
			cfg = t_leveltitle[i];
			break;
		end
	end
	if not cfg then return; end
	obj.titleURL = ResUtil:GetTitleIconSwf(cfg.bigIcon);
	local loader = _Loader.new()
	loader.lowPriority = false;
	loader:load(obj.titleURL)
	loader:onFinish(function()
		obj.titleImg = _Image.new(obj.titleURL);
		loader = nil;
	end)
	obj.titleWidth = cfg.titleWidth;
	obj.titleHeight = cfg.titleHeight;
	obj.titleBottom = cfg.titleBottom;
	obj.titleinterval = cfg.titleinterval;
	obj.titlescale = cfg.titlescale;
	return obj;
end

function PlayerHeadBoard:UpdateLevelTitleInfo(player)
	self.levelTitle = self:GetLevelTitleInfo(player);
	player = nil;
end

--V图标变换
function PlayerHeadBoard:OnChangeVTitle(vUrl)
	self.vImg = nil;
	if not vUrl or vUrl=="" then return; end
	vUrl = string.sub(vUrl,7,#vUrl);
	self.vImg = CResStation:GetImage(vUrl);
end

--- 转职图标变更
function PlayerHeadBoard:OnChangeZhuanzhi(zhuanZhiLv)
	-- if zhuanZhiLv > 0 then
	-- 	self.zhuanzhiImg = CResStation:GetImage(t_transferattr[zhuanZhiLv].icon)
	-- end
end

--境界图标变换
function PlayerHeadBoard:OnChangeRealmIcon(realmUrl)
	self.realmImg = nil;
	self.realmImg = CResStation:GetImage(realmUrl);
end

function PlayerHeadBoard:GetNameHeight(horseId, profId)
	local mountConfig = t_mountmodel[horseId]
	local height = 0
	if mountConfig then
		height = mountConfig["name_height" .. profId]
	end
	return height
end