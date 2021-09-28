local map = import(".map.groundmap")
local magic = import(".common.magic")
local common = import(".common.common")
local ground = class("ground", function ()
	return display.newLayer()
end)
local settingLogic = import(".common.settingLogic")

table.merge(slot3, {})

ground.ctor = function (self)
	self.map = nil
	self.player = nil

	self.scale(self, g_data.setting.display.mapScale)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_NEWMAP, self, self.onSM_NEWMAP)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_FirstAppearInfo, self, self.onSM_FirstAppearInfo)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_ACT_FAIL, self, self.onActFail)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_ACT_GOOD, self, self.onActGood)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_SAFE_ZONE_INFO, self, self.onSM_SAFE_ZONE_INFO)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_MAPDESCRIPTION, self, self.onSM_MAPDESCRIPTION)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_Appear, self, self.onSM_Appear)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_Turn, self, self.onSM_Turn)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_WALK, self, self.onSM_WALK)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_RUN, self, self.onSM_RUN)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_RUSH, self, self.onSM_RUSH)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_RUSHKUNG, self, self.onSM_RUSHKUNG)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_BACKSTEP, self, self.onSM_BACKSTEP)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_GHOST, self, self.onSM_GHOST)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_PHYSICAL_ATT, self, self.onSM_PHYSICAL_ATT)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_CHANGEMAP, self, self.onSM_CHANGEMAP)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_STRUCK, self, self.onSM_STRUCK)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_UserName, self, self.onSM_UserName)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_DEATH, self, self.onSM_DEATH)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_RELIVE, self, self.onSM_RELIVE)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_ITEMHIDE, self, self.onSM_ITEMHIDE)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_ITEMSHOW, self, self.onSM_ITEMSHOW)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_LNGONOFF, self, self.onSM_LNGONOFF)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_WIDONOFF, self, self.onSM_WIDONOFF)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_FIREON, self, self.onSM_FIREON)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_MAGICFIRE, self, self.onSM_MAGICFIRE)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_SPELL, self, self.onSM_SPELL)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_HEALTHSPELLCHANGED, self, self.onSM_HEALTHSPELLCHANGED)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_LEVELUP, self, self.onSM_LEVELUP)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_SWORDHITON, self, self.onSM_SWORDHITON)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_AutoRoute, self, self.onSM_AutoRoute)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_CHGSTATUS, self, self.onSM_CHGSTATUS)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_SHOWEVENT, self, self.onSM_SHOWEVENT)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_DIGUP, self, self.onSM_DIGUP)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_FLYAXE, self, self.onSM_FLYAXE)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_DIGDOWN, self, self.onSM_DIGDOWN)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_SLAVE_BORN, self, self.onSM_SLAVE_BORN)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_SLAVE_VANISH, self, self.onSM_SLAVE_VANISH)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_HIDEEVENT, self, self.onSM_HIDEEVENT)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_COMMON_INFORMATION, self, self.onSM_COMMON_INFORMATION)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_AREASTATE, self, self.onSM_AREASTATE)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_FEATURE_CHANGED, self, self.onSM_FEATURE_CHANGED)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_SPACEMOVE_SHOW, self, self.onSM_SPACEMOVE_SHOW)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_DOORSTATUS, self, self.onSM_DOORSTATUS)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_BUTCH, self, self.onSM_BUTCH)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_BIGHEARTHIT, self, self.onSM_BIGHEARTHIT)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_POWER_OK, self, self.onSM_POWER_OK)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_Marry_Name, self, self.onSM_Marry_Name)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_TradeBankYB_On, self, self.onSM_TradeBankYB_On)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_TradeBankGold_On, self, self.onSM_TradeBankGold_On)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_Juniority, self, self.onSM_Juniority)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_ShowedTitle, self, self.onSM_ShowedTitle)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_DamageEffect, self, self.onSM_DamageEffect)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_SKILLCD, self, self.onSM_SKILLCD)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_ChgZoneToClient, self, self.onSM_ChgZoneToClient)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_SERVER_TYPE, self, self.onSM_SERVER_TYPE)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_ChangeRideState, self, self.onSM_ChangeRideState)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_PetState, self, self.onSM_PetState)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_WarFlagState, self, self.onSM_WarFlagState)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_OperateWarFlag, self, self.onSM_OperateWarFlag)

	if 0 < DEBUG and clientRsbQueue then
		clientRsbQueue:init()
	end

	return 
end
ground.onSM_Juniority = function (self, result, protoId)
	main_scene.ui.console:call("btnPet", "startCd")

	return 
end
ground.onSM_TradeBankYB_On = function (self, result, protoId)
	if result then
		g_data.isYBTradeShopClose = not result.FBoOn
	end

	return 
end
ground.onSM_TradeBankGold_On = function (self, result, protoId)
	if result then
		g_data.isJBTradeShopClose = not result.FBoOn
	end

	return 
end
ground.onSM_SPACEMOVE_SHOW = function (self, result, protoId)
	if result and self.map then
		self.map:addMsg({
			roleid = result.FUserId,
			ident = SM_SPACEMOVE_SHOW,
			x = result.FCurx,
			y = result.FCury,
			dir = result.FCurDir,
			effect = {
				(result.FEffecttype == 1 and "spaceMoveShow") or "spaceMoveShow2",
				{
					roleid = result.FUserId
				}
			}
		})
	end

	return 
end
ground.onSM_POWER_OK = function (self, result, protoId)
	if result then
		g_data.player:setHitEnable("pow", true)
	end

	return 
end
ground.onSM_BIGHEARTHIT = function (self, result, protoId)
	if result then
		self.map:addMsg({
			effect = {
				"effectNum1",
				{
					x = result.FX,
					y = result.FY
				}
			}
		})
	end

	return 
end
ground.onSM_COMMON_INFORMATION = function (self, result, protoId)
	if result and result.FIsSafeZone == 6 then
		g_data.player:setIsUnlimitedMove(result.FCanThrough == true)

		if result.FCanThrough == true then
			main_scene.ui:tip("进入安全区!", 4)
		else
			main_scene.ui:tip("离开安全区!", 4)
		end
	end

	return 
end
ground.onSM_FEATURE_CHANGED = function (self, result, protoId)
	self.map:addMsg({
		roleid = result.FId,
		ident = protoId,
		feature = common.convertFeature(result.FFeature)
	})

	return 
end
ground.onSM_AREASTATE = function (self, result, protoId)
	if result then
		g_data.map:setMapState(result.FState)
		main_scene.ui.console:call("bottom", "uptMap")
	end

	return 
end
ground.onSM_HIDEEVENT = function (self, result, protoId)
	if result then
		self.map:hideEvent(result.FId)
	end

	return 
end
ground.onSM_SLAVE_BORN = function (self, result, protoId)
	if result then
		g_data.player:addSlave(result.FMonId)

		if self.map then
			local mon = self.map:findRole(result.FMonId)

			if mon then
				mon.isHaveMaster = true
			end
		end

		print("ground:onSM_SLAVE_BORN(")
	end

	return 
end
ground.onSM_SLAVE_VANISH = function (self, result, protoId)
	if result then
		g_data.player:removeSlave(result.FMonId)
	end

	return 
end
ground.onSM_DIGUP = function (self, result, protoId)
	if result then
		self.map:addMsg({
			roleid = result.FValue.FUserId,
			ident = SM_DIGUP,
			x = result.FValue.FCurrX,
			y = result.FValue.FCurrY,
			dir = result.FValue.FDir,
			feature = common.convertFeature(result.FValue.FFeature),
			isHaveMaster = (result.Flag == 1 and true) or false
		})
	end

	return 
end
ground.onSM_FLYAXE = function (self, result, protoId)
	if result then
		self.map:addMsg({
			roleid = result.FUserId,
			ident = SM_FLYAXE,
			x = result.FX,
			y = result.FY,
			roleParams = {
				x = result.FTargetX,
				y = result.FTargetY
			}
		})
	end

	return 
end
ground.onSM_DIGDOWN = function (self, result, protoId)
	if result then
		self.map:addMsg({
			roleid = result.FUserId,
			ident = SM_DIGDOWN,
			x = result.FX,
			y = result.FY,
			dir = result.FDir
		})
	end

	return 
end
ground.onSM_SHOWEVENT = function (self, result, protoId)
	if result then
		self.map:showEvent(result.FId, result.FX, result.FY, result.FKind, result.FDESC)
	end

	return 
end
ground.onSM_CHGSTATUS = function (self, result, protoId)
	if result then
		if self.player.roleid == result.FUserId then
			self.player:processMsg(SM_CHGSTATUS, nil, nil, nil, nil, result.FBodyStatus)
		else
			self.map:addMsg({
				roleid = result.FUserId,
				ident = SM_CHGSTATUS,
				state = result.FBodyStatus
			})
		end
	end

	return 
end
ground.onSM_AutoRoute = function (self, result, protoId)
	if result then
		main_scene.ui.console.controller.autoFindPath:searching(result.FPosX, result.FPosY, result.FMapID, nil, nil, result)
	end

	return 
end
ground.onSM_SWORDHITON = function (self, result, protoId)
	if result then
		g_data.client:setLastTime("swordhit", true)
		g_data.player:setHitEnable("sword", true)
		common.addMsg("您的剑气已凝聚成形", 219, 256, true)
		main_scene.ui.console:call("skill58", "startCd")
	end

	return 
end
ground.onSM_HEALTHSPELLCHANGED = function (self, result, protoId)
	if result then
		if self.player.roleid == result.FUserId then
			local missHp = g_data.player.ability.FHP - result.FHP
			local missMp = g_data.player.ability.FMP - result.FMP
			g_data.player.ability.FHP = result.FHP
			g_data.player.ability.FMaxHP = result.FMaxHP

			if result.FMaxMP ~= 0 then
				g_data.player.ability.FMP = result.FMP
				g_data.player.ability.FMaxMP = result.FMaxMP
			end

			self.player.info:setHP(result.FHP, result.FMaxHP)

			if 0 < missHp then
				settingLogic.missHp(missHp, true, false)
			end

			if 0 < missMp then
				settingLogic.missHp(missMp, false, false)
			end
		else
			self.map:addMsg({
				roleid = result.FUserId,
				ident = SM_HEALTHSPELLCHANGED,
				hp = result.FHP,
				maxhp = result.FMaxHP
			})
		end
	end

	return 
end
ground.onSM_LEVELUP = function (self, result, protoId)
	if result then
		self.map:showEffectForName("levelup", {
			x = self.player.x,
			y = self.player.y + 1
		})
	end

	return 
end
ground.onSM_MAGICFIRE = function (self, result, protoId)
	if result then
		self.map:addMsg({
			magic = {
				result.FUserId,
				Lobyte(result.FEffect),
				Hibyte(result.FEffect),
				result.FCur_X,
				result.FCur_Y,
				result.FTargetId,
				result.FPlayCnt
			}
		})

		if result.FUserId == g_data.player.roleid then
			local skillConfig = def.magic.getMagicConfig(Hibyte(result.FEffect))

			if skillConfig then
				main_scene.ui.console:call("skill" .. tostring(skillConfig.uid), "startCd")
			end
		end

		local effectType = Lobyte(result.FEffect)
		local effectId = Hibyte(result.FEffect)
		local playCnt = result.FPlayCnt

		if effectType == 15 and effectId == 84 then
			self.map:addMsg({
				skillEffectId = 84,
				roleid = result.FUserId
			})
		elseif effectType == 16 and effectId == 85 then
			self.map:addMsg({
				skillEffectId = 85,
				roleid = result.FUserId
			})
		elseif (effectType == 2 and effectId == 79 and playCnt == 2) or (effectType == 2 and effectId == 70 and playCnt == 2) then
			self.map:addMsg({
				skillEffectId = 70,
				roleid = result.FUserId
			})
		end
	end

	return 
end
ground.onSM_SPELL = function (self, result, protoId)
	if result then
		local tmp = {
			roleid = result.FUserId,
			ident = SM_SPELL,
			roleParams = {
				targetY = result.FCur_Y,
				targetX = result.FCur_X,
				effect = {
					effectID = Byte(result.FEffect - 1),
					magicId = result.FMagId,
					magicLevel = result.FmagLv
				}
			}
		}

		self.map:addMsg(tmp)
	end

	return 
end
ground.onSM_LNGONOFF = function (self, result, protoId)
	if result then
		if result.FIsOpen then
			g_data.player:setHitEnable("long", true)

			if result.Flag == 1 then
				common.addMsg("开启刺杀剑术", 219, 256, true)
			end
		else
			g_data.player:setHitEnable("long", false)

			if result.Flag == 1 then
				common.addMsg("关闭刺杀剑术", 219, 256, true)
			end
		end

		if result.Flag == 1 then
			main_scene.ui.console:call("skill12", "startCd")
		end
	end

	return 
end
ground.onSM_WIDONOFF = function (self, result, protoId)
	if result then
		if result.FIsOpen then
			g_data.player:setHitEnable("wide", true)
		else
			g_data.player:setHitEnable("wide", false)
		end

		if not main_scene.ui.console.autoRat.enableRat then
			if result.FIsOpen then
				common.addMsg("开启半月弯刀", 219, 256, true)
			else
				common.addMsg("关闭半月弯刀", 219, 256, true)
			end
		end

		main_scene.ui.console:call("skill25", "startCd")
	end

	return 
end
ground.onSM_FIREON = function (self, result, protoId)
	if result then
		g_data.client:setLastTime("fire", true)
		g_data.player:setHitEnable("fire", true)
		common.addMsg("您的武器因精神火球而炙热", 219, 256, true)
		main_scene.ui.console:call("skill26", "startCd")
	end

	return 
end
ground.onSM_RELIVE = function (self, result, protoId)
	if result then
		main_scene.ground.map:processMsg({
			roleid = result.FPlayerStateRec.FUserId,
			ident = SM_RELIVE,
			x = result.FPlayerStateRec.FCurrX,
			y = result.FPlayerStateRec.FCurrY,
			dir = result.FPlayerStateRec.FDir,
			feature = common.convertFeature(result.FPlayerStateRec.FFeature),
			state = result.FPlayerStateRec.FStatus
		})

		if result.FPlayerStateRec.FUserId == g_data.player.roleid then
			g_data.eventDispatcher:dispatch("NOW_RELIVE")
		end
	end

	return 
end
ground.onSM_DEATH = function (self, result, protoId)
	if result then
		self.map:addMsg({
			roleid = result.FPlayerStateRec.FUserId,
			ident = SM_DEATH,
			x = result.FPlayerStateRec.FCurrX,
			y = result.FPlayerStateRec.FCurrY,
			dir = result.FPlayerStateRec.FDir,
			feature = common.convertFeature(result.FPlayerStateRec.FFeature),
			state = result.FPlayerStateRec.FStatus,
			roleParams = {
				flag = result.FState
			}
		})

		if result.FState == 1 and result.FPlayerStateRec.FUserId == g_data.player.roleid then
			g_data.eventDispatcher:dispatch("NOW_DEATH")
		end
	end

	return 
end
ground.onSM_ITEMSHOW = function (self, result, protoId)
	if result then
		self.map:showItem(false, true, result.FItemID, result.Fx, result.Fy, result.FFloorItem_ItemName, result.FLook, result.FFloorItem_Owner, result.FFloorItem_NonsuchPoint)
	end

	return 
end
ground.onSM_ITEMHIDE = function (self, result, protoId)
	if result then
		self.map:showItem(result.Flag == 1, false, result.FItemID)
	end

	return 
end
ground.onSM_UserName = function (self, result, protoId)
	if result then
		self.map:addMsg({
			roleid = result.FUserId,
			ident = SM_UserName,
			name = result.FName,
			nameColor = result.FNameColor,
			honourTitleIDArr = result.FHonourTitleIDArr
		})
	end

	return 
end
ground.onSM_STRUCK = function (self, result, protoId)
	if g_data.login:isChangeSkinCheckServer() then
		return 
	end

	if result then
		if result.FUserId == self.player.roleid then
			g_data.player.ability.FHP = result.FHP
			g_data.player.ability.FMaxHP = result.FMaxHP

			if result.FMP ~= 0 and result.FMaxMP ~= 0 then
				settingLogic.missHp(g_data.player.ability.FMP - result.FMP, false)

				g_data.player.ability.FMP = result.FMP
				g_data.player.ability.FMaxMP = result.FMaxMP
			end

			self.player.info:setHP(result.FMP, result.FMaxMP, result.FOutHP)
			settingLogic.missHp(result.FOutHP, true)
		end

		self.map:addMsg({
			roleid = result.FUserId,
			ident = SM_STRUCK,
			hp = result.FHP,
			maxhp = result.FMaxHP,
			outhp = result.FOutHP,
			flag = result.Fflag
		})
	end

	return 
end
ground.onSM_CHANGEMAP = function (self, result, protoId)
	if result then
		if g_data.player.useBackHomeSkill then
			if main_scene.ui.console:get("btnBackHome") then
				main_scene.ui.console:get("btnBackHome"):startCd()
			end

			g_data.client:setLastTime("common.checkAmulet", true)

			g_data.player.useBackHomeSkill = false
		end

		local params = {
			isPlayer = true,
			roleid = self.player.roleid,
			x = result.FCurX,
			y = result.FCurY,
			dir = self.player.dir,
			feature = self.player.feature,
			state = self.player.state,
			guildName = self.player.guildName,
			marryName = self.player.marryName
		}
		local name = self.player.info.name
		local title = self.player.info.title
		local hitSpeed = self.player.hitSpeed

		if self.map then
			self.map:removeSelf()
		end

		self.map = map.new(result.FMapName):addto(self)
		g_data.map.state = result.FMapState
		self.player = self.map:findRole(params.roleid, params)

		if g_data.player.ability then
			self.player.info:setHP(g_data.player.ability.FHP, g_data.player.ability.FMaxHP)
		end

		if name.texts then
			self.player.info:setName(name.texts, name.color)
		end

		if name.color then
			self.player.info:setNameColor(name.color)
		end

		if title.texts then
			self.player.info:setTitle(title.texts, true)
		end

		self.player.hitSpeed = hitSpeed

		main_scene.ui:hidePanel("npc")
		main_scene.ui:hidePanel("bigmapOther")
		main_scene.ui:hidePanel("bag")
		main_scene.ui:hidePanel("upgradeWeapon")
		main_scene.ui:hidePanel("weaponIdentify")
		main_scene.ui:hidePanel("milRankComposition")
		main_scene.ui:hidePanel("horseSoulComposition")
		main_scene.ui:hidePanel("horseUpgrade")

		if main_scene.ui.panels.minimap then
			main_scene.ui.panels.minimap:reload()
		end

		main_scene.ui.console.controller.autoFindPath:singleMapPathStop()
		main_scene.ui.console.controller.autoFindPath:research(true)

		if g_data.useRandomSend then
			g_data.useRandomSend = nil
		else
			main_scene.ui.console.autoRat:stop()
		end

		if g_data.map.state == 10 then
			main_scene.ui:initBtnAutoRatConfig2()
		else
			main_scene.ui.console:removeWidget("btnAutoRat2")
		end

		if g_data.map.state ~= 11 then
			main_scene.ui.leftTopTip:showPVP({}, {})
		end

		g_data.eventDispatcher:dispatch("M_CHANGEMAP")
	end

	return 
end
ground.onSM_PHYSICAL_ATT = function (self, result, protoId)
	if result and result.FClientPhyAttRec then
		local hitMode = result.FClientPhyAttRec.FhitMode

		self.map:addMsg({
			roleid = result.FClientPhyAttRec.FUserId,
			ident = hitMode,
			x = result.FClientPhyAttRec.FCurrX,
			y = result.FClientPhyAttRec.FCurrY,
			dir = result.FClientPhyAttRec.FDir,
			roleParams = {
				effectType = result.FEffectType,
				effectId = result.FEffectId
			}
		})
	end

	return 
end
ground.onSM_WALK = function (self, result, protoId)
	if result and result.FActInfo and self.player and result.FActInfo.FUserId ~= self.player.roleid then
		self.map:addMsg({
			roleid = result.FActInfo.FUserId,
			ident = SM_WALK,
			x = result.FActInfo.FCurr_X,
			y = result.FActInfo.FCurr_Y,
			dir = result.FActInfo.FCurr_dir
		})
	end

	return 
end
ground.onSM_GHOST = function (self, result, protoId)
	if result and result.FUserId ~= g_data.player.roleid and self.map then
		self.map:addMsg({
			remove = true,
			roleid = result.FUserId
		})
	end

	return 
end
ground.onSM_RUN = function (self, result, protoId)
	if result and result.FActInfo and self.player and result.FActInfo.FUserId ~= main_scene.ground.player.roleid then
		self.map:addMsg({
			roleid = result.FActInfo.FUserId,
			ident = SM_RUN,
			x = result.FActInfo.FCurr_X,
			y = result.FActInfo.FCurr_Y,
			dir = result.FActInfo.FCurr_dir
		})
	end

	return 
end
ground.onSM_BACKSTEP = function (self, result, protoId)
	if result and result.FActInfo then
		self.map:addMsg({
			roleid = result.FActInfo.FUserId,
			ident = SM_BACKSTEP,
			x = result.FActInfo.FCurr_X,
			y = result.FActInfo.FCurr_Y,
			dir = result.FActInfo.FCurr_dir
		})
	end

	return 
end
local rushEffectId2SkillId = {
	[0] = "skill27",
	[81.0] = "skill63"
}
local rushRimeSpace = 2.73
ground.onSM_RUSH = function (self, result, protoId)
	if result then
		self.map:addMsg({
			roleid = result.FActInfo.FUserId,
			ident = SM_RUSH,
			x = result.FActInfo.FCurr_X,
			y = result.FActInfo.FCurr_Y,
			dir = result.FActInfo.FCurr_dir,
			roleParams = {
				effectId = result.FEffectId
			}
		})

		if result.FActInfo.FUserId == self.player.roleid then
			local rushTime = g_data.client.rush[rushEffectId2SkillId[result.FEffectId]]

			if rushTime and socket.gettime() - rushTime < rushRimeSpace then
				return 
			end

			local skill = rushEffectId2SkillId[result.FEffectId]

			main_scene.ui.console:call(skill, "startCd")

			g_data.client.rush[rushEffectId2SkillId[result.FEffectId]] = socket.gettime()
		end
	end

	return 
end
ground.onSM_RUSHKUNG = function (self, result, protoId)
	if result then
		self.map:addMsg({
			roleid = g_data.player.roleid,
			ident = SM_RUSHKUNG,
			roleParams = {
				effectId = result.FEffectId
			}
		})

		local rushTime = g_data.client.rush[rushEffectId2SkillId[result.FEffectId]]

		if rushTime and socket.gettime() - rushTime < rushRimeSpace then
			return 
		end

		local skill = rushEffectId2SkillId[result.FEffectId]

		main_scene.ui.console:call(skill, "startCd")

		g_data.client.rush[rushEffectId2SkillId[result.FEffectId]] = socket.gettime()
	end

	return 
end
ground.onSM_SKILLCD = function (self, result, protoId)
	if result then
		local cd_data = result.FCdlist

		for _, v in ipairs(cd_data) do
			if 0 < v.FCd then
				local skill = "skill" .. v.FMagid

				main_scene.ui.console:call(skill, "updateCd", v.FCd)
			end
		end
	end

	return 
end
ground.onEnter = function (self)
	return 
end
ground.onExit = function (self)
	return 
end
ground.update = function (self, dt)
	if self.map then
		self.map:update(dt)
	end

	if 0 < DEBUG and clientRsbQueue then
		clientRsbQueue:update(dt)
	end

	return 
end
ground.onSM_Turn = function (self, result, proIc)
	if result and result.FValue then
		self.map:addMsg({
			roleid = result.FValue.FUserId,
			ident = SM_Turn,
			x = result.FValue.FCurrX,
			y = result.FValue.FCurrY,
			dir = result.FValue.FDir,
			feature = common.convertFeature(result.FValue.FFeature),
			state = result.FValue.FStatus,
			job = result.FJob,
			name = result.FName
		})

		if not result.FJob or 2 < result.FJob or result.FJob < 0 then
			luaReportException("createRole Exception", "ground:onSM_Turn", "result.FJob:" .. (result.FJob or "") .. " result.FName:" .. (result.FName or ""))
		end
	end

	return 
end
ground.onSM_Appear = function (self, result, proIc)
	if result and result.FValue then
		self.map:addMsg({
			roleid = result.FValue.FUserId,
			ident = SM_Appear,
			x = result.FValue.FCurrX,
			y = result.FValue.FCurrY,
			dir = result.FValue.FDir,
			feature = common.convertFeature(result.FValue.FFeature),
			state = result.FValue.FStatus,
			job = result.FJob,
			name = result.FName,
			nameColor = result.FNameClr,
			level = result.FLevel,
			guildName = result.FGildName,
			marryName = result.MarryName,
			honourTitleIDArr = result.FHonourTitleIDArr,
			isHaveMaster = (result.Flag == 1 and true) or false
		})

		if not result.FJob or 2 < result.FJob or result.FJob < 0 then
			luaReportException("createRole Exception", "ground:onSM_Appear", "result.FJob:" .. (result.FJob or "") .. " result.FName:" .. (result.FName or ""))
		end
	end

	return 
end
ground.onSM_ShowedTitle = function (self, result, proIc)
	if result then
		self.map:addMsg({
			roleid = result.FUserId,
			honourTitleIDArr = result.FHonourTitleIDArr
		})
	end

	return 
end
ground.onSM_NEWMAP = function (self, result, proIc)
	if result then
		if self.map then
			self.map:removeSelf()
		end

		self.map = map.new(result.FMapName)

		if tolua.isnull(self) or tolua.isnull(self.map) then
			return 
		end

		self.map:addto(self)

		self.player = nil

		main_scene.ui.console.autoRat:stop()

		if g_data.select.newRoleEnterGame and g_data.serConfig.showNewRoleGuide == 1 then
			main_scene.ui:togglePanel("welcome")

			g_data.select.newRoleEnterGame = false
		end
	end

	return 
end
ground.onSM_FirstAppearInfo = function (self, result, proIc)
	if result then
		self.player = self.map:findRole(result.FUserId, {
			isPlayer = true,
			roleid = result.FUserId,
			x = result.FCurX,
			y = result.FCurY,
			dir = result.FDir,
			feature = {
				race = result.FRace,
				sex = result.FSex,
				hair = result.FHair,
				weapon = result.FWeapon,
				dress = result.FDress,
				riding = result.FRiding,
				wing = result.FWing,
				fcloth = result.FFEClothID,
				fweapon = result.FFEWeaponID,
				speEffect = result.FSpecShapeIDArr
			},
			state = result.FBodyState,
			guildName = result.FGildName,
			marryName = result.MarryName
		})

		self.map:addMsg({
			roleid = result.FUserId,
			ident = SM_UserName,
			name = g_data.select:getCurName(),
			job = g_data.select:getCurJob(),
			nameColor = result.FNameColor,
			guildName = result.FGildName,
			honourTitleIDArr = result.FHonourTitleIDArr
		})

		local mJob = g_data.select:getCurJob()
		local mName = g_data.select:getCurName()

		if not mJob or 2 < mJob or mJob < 0 then
			luaReportException("createRole Exception", "ground:onSM_FirstAppearInfo", "Job:" .. (mJob or "") .. " Name:" .. (mName or ""))
		end

		self.player:addAct({
			type = "walk",
			x = result.FCurX,
			y = result.FCurY,
			dir = result.FDir
		})

		g_data.player.lastUnlockTime = socket.gettime()
		local rsb = DefaultClientMessage(CM_QUERYBAGITEMS)

		MirTcpClient:getInstance():postRsb(rsb)

		local rsb = DefaultClientMessage(CM_QueryWingInfo)

		MirTcpClient:getInstance():postRsb(rsb)

		local rsb = DefaultClientMessage(CM_QueryPetInfo)

		MirTcpClient:getInstance():postRsb(rsb)

		local rsb = DefaultClientMessage(CM_QueryHorseInfo)

		MirTcpClient:getInstance():postRsb(rsb)

		local rsb = DefaultClientMessage(CM_QueryEquipBarInfo)

		MirTcpClient:getInstance():postRsb(rsb)

		local rsb = DefaultClientMessage(CM_ClientQueryMIInfo)

		MirTcpClient:getInstance():postRsb(rsb)
		g_data.player:setRoleID(result.FUserId)
		g_data.player:setSex(result.FSex)
		g_data.player:setAllowGroup(result.FSwState == 1)
		main_scene.ui:show()
		main_scene.ui:showPanel("minimap")
		g_data.mail:startSchedule()
	end

	return 
end
ground.onActGood = function (self, result, proIc)
	if 0 < DEBUG and g_data.openMoveLog then
		local curTime = socket.gettime()
		local interval = g_data.client:getIntervalTime("sendRsb")

		p2("net", "SM_ActGood -- time interval: " .. math.ceil(interval*1000) .. ", curTime: " .. math.ceil(curTime*1000))
	end

	if result and self.map then
		self.map:hideLubiao()

		if self.player then
			self.player:executeSuccess()
		end

		main_scene.ui.console.autoRat:onActGood()
	end

	return 
end
ground.onActFail = function (self, result, proIc)
	if 0 < DEBUG and g_data.openMoveLog then
		local curTime = socket.gettime()
		local interval = g_data.client:getIntervalTime("sendRsb")

		p2("net", "SM_ActFail -- time interval: " .. math.ceil(interval*1000) .. ", curTime: " .. math.ceil(curTime*1000))
	end

	if result then
		local x, y, dir = nil

		if 0 < result.FActInfo.FCurr_X and 0 < result.FActInfo.FCurr_Y then
			dir = result.FActInfo.FCurr_dir
			y = result.FActInfo.FCurr_Y
			x = result.FActInfo.FCurr_X
		end

		if self.player then
			self.player:executeFail(x, y, dir)
		end

		main_scene.ui.console.autoRat:onActFail(x, y, dir)
		p2("error", "ground:onActFail ------ ActFail!!! x   -", result.FActInfo.FCurr_X, " y   -", result.FActInfo.FCurr_Y, " dir   -", result.FActInfo.FCurr_dir)
		p2("error", "ground:onActFail ------ ActFail!!! oriX-", self.player.x, " oriY-", self.player.y, " oriDir-", self.player.dir)
	end

	return 
end
ground.onSM_SAFE_ZONE_INFO = function (self, result, proIc)
	if result then
		g_data.map:setSafeZone(result)
	end

	return 
end
ground.onSM_MAPDESCRIPTION = function (self, result, proIc)
	if result then
		g_data.map:setMapTitle(result.FMapAreaDesc)
		main_scene.ui.console:call("bottom", "uptMap")

		if main_scene.ui.panels.bigmap then
			main_scene.ui.panels.bigmap:updateTitle()
		end
	end

	return 
end
ground.onSM_DOORSTATUS = function (self, result, protoId)
	self.map:setDoorState(result.FStatus == 1, result.Fx, result.Fy)
	g_data.client:setLastTime("openDoor")

	return 
end
ground.onSM_BUTCH = function (self, result, protoId)
	if self.player.roleid ~= result.FCreature then
		self.map:addMsg({
			roleid = result.FCreature,
			ident = protoId,
			x = result.FX,
			y = result.FY,
			dir = Lobyte(result.FDir)
		})
	end

	return 
end
ground.onSM_Marry_Name = function (self, result)
	if result and result.UserId then
		self.map:updateMarryName(result.UserId, result.Name)
	end

	return 
end
ground.onSM_DamageEffect = function (self, result, protoId)
	if not result then
		return 
	end

	self.map:addMsg({
		roleid = result.FId,
		ident = SM_DamageEffect,
		effectId = result.FEffect
	})

	return 
end
ground.onSM_ChgZoneToClient = function (self, result, protoId)
	if not result then
		return 
	end

	def.setip(result.FIP or "", "")

	g_data.isKickOut = true

	if MirTcpClient:getInstance():isConnected() then
		MirTcpClient:getInstance():disconnect(false)
	end

	self.conectResult = result
	self.reconnectHandle = nil
	g_data.netReconnect = true

	g_data.eventDispatcher:dispatch("NET_DISCONNECTED")

	self.reconnectHandle = scheduler.performWithDelayGlobal(function ()
		if reConnectLogic then
			reConnectLogic:getloginLGSuccess(self.conectResult)
		end

		return 
	end, 3)

	return 
end
ground.onSM_SERVER_TYPE = function (self, result, protoId)
	if not result then
		return 
	end

	g_data.isKickOut = false

	g_data.player:setCrossServerState(result.FServerType)

	return 
end
ground.onSM_ChangeRideState = function (self, result, protoId)
	if not result then
		return 
	end

	main_scene.ui.loading:hide()
	g_data.player:setRideState(result.FRideState)

	return 
end
ground.onSM_PetState = function (self, result, protoId)
	if not result then
		return 
	end

	g_data.player:setPetState(result.FCurrState)

	return 
end
ground.onSM_WarFlagState = function (self, result, protoId)
	if not result then
		return 
	end

	g_data.player:setFlagState(result.FCurrState)

	return 
end
ground.onSM_OperateWarFlag = function (self, result, protoId)
	if not result then
		return 
	end

	g_data.client:setLastTime("OperateWarFlag", true)
	g_data.player:setFlagState(result.FCurrState)

	if main_scene.ui.console:get("btnFlag") then
		main_scene.ui.console:get("btnFlag"):startCd()
	end

	return 
end

return ground
