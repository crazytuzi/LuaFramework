 ChatVo =BaseClass(ChatBaseVo)

 ChatVo.ParamType = {
 	Param = 1, 			--文本
 	Player = 2, 		--玩家
 	Item = 3, 			--物品
 	Equipment = 4, 		--装备
 	Team = 5, 			--组队 
 	Wing = 6, 			--翅膀
 	Style = 7, 			--时装 
 	Scene = 8, 			--场景
 	Family = 9, 		--家族
 	Clan = 10, 			--Clan
 }

 --品质颜色代码(黑底)
 ChatVo.RareColor = {
 	[0] = "#ebebeb",  	--白  
 	[1] = "#ebebeb",  	--白  
 	[2] = "#3dc476",	--绿
 	[3] = "#5fb6ff",	--蓝
 	[4] = "#b854ff",	--紫
 	[5] = "#ffc228",	--橙  

 	[6] = "#60bdf2",	--玩家
 	[7] = "#3dc476",	--组队
 	[8] = "#60bdf2",	--家族
 	[9] = "#60bdf2",	--交易行
 	[10] = "#ebebeb",	--副本
 	[11] = "#60bdf2",	--注灵
 	[12] = "#ebebeb",	--场景
 	[13] = "#60bdf2",	--clan
 }

 --品质颜色代码(白底)
 ChatVo.RareColor2 = {
 	[0] = "#2e3341",  	--白  
 	[1] = "#2e3341",  	--白  
 	[2] = "#348a37",	--绿
 	[3] = "#1b72de",	--蓝
 	[4] = "#8f3eb4",	--紫
 	[5] = "#d89401",	--橙 

	[6] = "#3668CB",	--玩家
 	[7] = "#348a37",	--组队
 	[8] = "#3668CB",	--家族
 	[9] = "#3668CB",	--交易行
 	[10] = "#2e3341",	--副本
 	[11] = "#3668CB",	--注灵
 	[12] = "#2e3341",	--场景
 	[13] = "#3668CB",	--clan
 }

function ChatVo:__init(data)
	if not data then return end
	self.sendPlayerId = data.sendPlayerId
	self.sendPlayerCareer = data.sendPlayerCareer
	self.sendPlayerName = data.sendPlayerName
	self.sendPlayerLevel = data.sendPlayerLevel
	self.sendPlayerTitle = data.sendPlayerTitle
	self.sendPlayerVip = data.sendPlayerVip
	self.toPlayerId = data.toPlayerId
	self.toPlayerName = data.toPlayerName
	self.type = data.type --消息类型(类型说明 0:未定义 1:世界,2:工会,3:组队,4:私人,5:系统,6:附近 7:个人)
	self.msgId = data.msgId
	self.content = data.content
	self.content2 = data.content
	self.params = {}
	if data.cerateTime then
		self.cerateTime = data.cerateTime
	else
		self.cerateTime = nil
	end
	self.isOperateMsg = false

	if data.sendPlayerId ~= nil and data.sendPlayerId ~= 0 then
		self.isFromPlayer = true
	else
		self.isFromPlayer = false
	end

	self.cfg = GetCfgData("notice"):Get(self.msgId)
	if self.cfg then
		self.content = self.cfg.msgContent
		self.type = self.cfg.chatChannel
		self.isRollMsg = self.cfg.isBroadcast == 1
	end
	
	if data.param and data.param ~= "" then
		local paramT = StringToTable(data.param)
		for i = 1, #paramT do
			local param = {}
			param.type = tonumber(paramT[i][1])
			param.paramInt = tonumber(paramT[i][2])
			param.paramInt2 = tonumber(paramT[i][3])
			param.paramStr = paramT[i][4]
			table.insert(self.params, param)
		end
	end

	ChatVo.ParseParam(self)
	self.content2 = "[color="..ChatNewModel.ChannelColor[self.type].."]"..self.content2.."[/color]"
end

function ChatVo.ParseParam(target)
	if #target.params > 0 then
		local strs = {}
		local strs2 = {}
		for i = 1, #target.params do
			local param = target.params[i]
			local tt = param.type
			local paramStr = param.paramStr
			local paramInt = param.paramInt
			local paramInt2 = param.paramInt2
			local ParamType = ChatVo.ParamType
			if tt == ParamType.Param then --文本
				table.insert(strs, paramStr)
				table.insert(strs2, paramStr)

			elseif tt == ParamType.Scene then --场景
				table.insert(strs, "[color="..ChatVo.RareColor2[12].."]["..paramStr.."][/color]")
				table.insert(strs2, "[color="..ChatVo.RareColor[12].."]["..paramStr.."][/color]")

			elseif tt == ParamType.Player then --玩家
				local playerId = paramInt
				local playerName = paramStr

				table.insert(strs, "[color="..ChatVo.RareColor2[6].."][url="..tt.."_".."".."_"..playerId.."]["..playerName.."][/url][/color]")
				table.insert(strs2, "[color="..ChatVo.RareColor[6].."][url="..tt.."_".."".."_"..playerId.."]["..playerName.."][/url][/color]")
			
			elseif tt == ParamType.Wing then --翅膀
				local id = paramInt
				local cfg = GetCfgData("wing"):Get(id)
				if cfg then
					local str = "[color="..GoodsVo.RareColor2[cfg.quality].."][url="..tt.."_"..id.."]["..cfg.name.."][/url][/color]"
					table.insert(strs, str)

					local str = "[color="..GoodsVo.RareColor[cfg.quality].."][url="..tt.."_"..id.."]["..cfg.name.."][/url][/color]"
					table.insert(strs2, str)
				end

			elseif tt == ParamType.Style then --时装
				local id = paramInt
				local cfg = GetCfgData("fashionable"):Get(id)
				if cfg then
					local str = "[color="..GoodsVo.RareColor2[cfg.quality].."][url="..tt.."_"..id.."]["..cfg.name.."][/url][/color]"
					table.insert(strs, str)

					local str = "[color="..GoodsVo.RareColor[cfg.quality].."][url="..tt.."_"..id.."]["..cfg.name.."][/url][/color]"
					table.insert(strs2, str)
				end

			elseif tt == ParamType.Item then --物品
				local id = paramInt
				local cfg = GetCfgData("item"):Get(id)
				if cfg then
					local str = "[color="..GoodsVo.RareColor2[cfg.rare].."][url="..tt.."_"..id.."]["..cfg.name.."][/url][/color]"
					table.insert(strs, str)

					local str = "[color="..GoodsVo.RareColor[cfg.rare].."][url="..tt.."_"..id.."]["..cfg.name.."][/url][/color]"
					table.insert(strs2, str)
				end

			elseif tt == ParamType.Equipment then --装备 
				local playerId = paramInt or ""
				local id = paramInt2

				local equipmentGuid = tonumber(paramStr) or ""
				local cfg = GetCfgData("equipment"):Get(id)
				if cfg then
					if target.isNotic then
						local str = "[color="..GoodsVo.RareColor2[cfg.rare].."]["..cfg.name.."][/color]"
						table.insert(strs, str)

						local str = "[color="..GoodsVo.RareColor[cfg.rare].."]["..cfg.name.."][/color]"
						table.insert(strs2, str)
					else
						local str = "[color="..GoodsVo.RareColor2[cfg.rare].."][url="..tt.."_"..equipmentGuid.."_"..playerId.."]["..cfg.name.."][/url][/color]"
						table.insert(strs, str)

						local str = "[color="..GoodsVo.RareColor[cfg.rare].."][url="..tt.."_"..equipmentGuid.."_"..playerId.."]["..cfg.name.."][/url][/color]"
						table.insert(strs2, str)
					end
				end

			elseif tt == ParamType.Team then --组队 
				local teamId = paramInt
				local str = "[color="..ChatVo.RareColor2[7].."][url="..tt.."_"..teamId.."][申请入队][/url][/color]"
				table.insert(strs, str)

				local str = "[color="..ChatVo.RareColor[7].."][url="..tt.."_"..teamId.."][申请入队][/url][/color]"
				table.insert(strs2, str)

			elseif tt == ParamType.Family then --家族
				local familyName = paramStr
				local familyId = paramInt

				local str = familyName.."[color="..ChatVo.RareColor2[7].."][url="..tt.."_"..familyId.."][加入家族][/url][/color]"
				table.insert(strs, str)

				local str = familyName.."[color="..ChatVo.RareColor[7].."][url="..tt.."_"..familyId.."][加入家族][/url][/color]"
				table.insert(strs2, str)

			elseif tt == ParamType.Clan then --Clan
				local clanName = paramStr
				local clanId = paramInt

				local str = clanName.."[color="..ChatVo.RareColor2[13].."][url="..tt.."_"..clanId.."][加入都护府][/url][/color]"
				table.insert(strs, str)

				local str = clanName.."[color="..ChatVo.RareColor[13].."][url="..tt.."_"..clanId.."][加入都护府][/url][/color]"
				table.insert(strs2, str)
			end
		end
		local contentTemp = StringFormatII(target.content, strs)
		target.content2 = StringFormatII(target.content, strs2)
		target.content = contentTemp
		target.hasLink = true
	end
end