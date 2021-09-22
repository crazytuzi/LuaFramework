local GameSocket = class("GameSocket")

local SocketManager=cc.SocketManager:getInstance()
local NetCC=cc.NetClient:getInstance()

NetCC:setNetMsgListen(GameMessageID.cNotifyMapEnter,true)
NetCC:setNetMsgListen(GameMessageID.cNotifyMapMiniNpc,true)
NetCC:setNetMsgListen(GameMessageID.cNotifyMapConn,true)
NetCC:setNetMsgListen(GameMessageID.cNotifyHPMPChange,true)
NetCC:setNetMsgListen(GameMessageID.cNotifyMapOption,true)
NetCC:setNetMsgListen(GameMessageID.cNotifyInjury,true)
NetCC:setNetMsgListen(GameMessageID.cNotifyGuildInfo,true)
NetCC:setNetMsgListen(GameMessageID.cNotifyForceMove,true)
NetCC:setNetMsgListen(GameMessageID.cNotifyCharacterLoad,true)
NetCC:setNetMsgListen(GameMessageID.cNotifyAvatarChange,true)
NetCC:setNetMsgListen(GameMessageID.cNotifyPowerChange,true)
NetCC:setNetMsgListen(GameMessageID.cNotifyBuffChange,true)
NetCC:setNetMsgListen(GameMessageID.cNotifyStatusChange,true)
NetCC:setNetMsgListen(GameMessageID.cNotifyListBuff,true)
NetCC:setNetMsgListen(GameMessageID.cNotifyTeamInfo,true)
--这两条在C++修改后可以去掉
-- NetCC:setNetMsgListen(GameMessageID.cNotifyRelive,true)
-- NetCC:setNetMsgListen(GameMessageID.cNotifyMapBye,true)


local zlib = require("zlib")

-- 去掉装备名称末尾的数字标识
local function reNameEquip(name)
	return string.gsub(name,"(.+)(.)([1-3])$",function(s,n,m)
		local temp = tonumber(n)
		if not temp and m then
			return s..n
		else
			return s..n..m
		end
	end)
end

function GameSocket:ctor()

	cc.GameObject.extend(self):addComponent("components.behavior.EventProtocol"):exportMethods()

	self._netChars={}
	self._reqChar=false
	self._connected=false
	self.nearByGroupInfo = {}
	
	self.PKMapIds = {"chiwooBattle",}
	-- self.inviteGQueue = {}
	-- self.applyGQueue = {}
	self.mGroupMembers = {}

	-- self.tipsMsg = {}
	self.applyList={}

	self.mails = {}

	self.guideTab={}

	self.skillRed={}

	self:init()

	self.NetFunc={

	[GameMessageID.cNotifySessionClosed] = function(mMsg)
		local msgstr=mMsg:readString()
		local function exitDelay()
			GameCCBridge.showMsg(msgstr)
			GameBaseLogic.ExitToRelogin()
		end
		local scene=cc.Director:getInstance():getRunningScene()
		scene:runAction(cc.Sequence:create(cc.DelayTime:create(3), cc.CallFunc:create(exitDelay)));
	end,

	[GameMessageID.cResAuthenticate] = function(mMsg)
		local param=mMsg:readInt()
		local code=mMsg:readInt()
		if code~=3 then
			GameUtilSenior.showAlert("", "客户端版本太低，请升级！", "知道了")
			local function exitDelay()
				GameBaseLogic.ExitToRelogin()
			end
			local scene=cc.Director:getInstance():getRunningScene()
			scene:runAction(cc.Sequence:create(cc.DelayTime:create(3), cc.CallFunc:create(exitDelay)));
			return
		end
		if param == 100 and self.kuaFuInfo then
			GameSocket:EnterGame(GameBaseLogic.chrName,GameBaseLogic.seedName)
		end
		self:dispatchEvent({name=GameMessageCode.EVENT_AUTHENTICATE,result=param})
	end,

	[GameMessageID.cNotifyYouKeSessionID] = function(mMsg)
		local param = mMsg:readString()
		self:dispatchEvent({name=GameMessageCode.EVENT_AUTHENTICATE,result=param})
	end,

	[GameMessageID.cResListCharacter] = function(mMsg)
		local netchar={}
		local mCharListChinaLimit = mMsg:readInt()
		local charlistnumber = mMsg:readInt()
		local curSvrid = 1
		if GameBaseLogic.lastSvr then
			curSvrid = tonumber(GameBaseLogic.lastSvr.serial) or 0
		end
		local isCurSvr = false
		for i=1,charlistnumber do
			-- if charlistnumber >0 and charlistnumber >= i then
			local char = {}
			char.mLevel			= mMsg:readInt()
			char.mJob			= mMsg:readInt()
			char.mGender		= mMsg:readInt()
			char.mSvrid			= mMsg:readInt()
			char.mOnline		= mMsg:readInt()
			char.mName			= mMsg:readString()
			char.mSeedName		= mMsg:readString()
			char.mCloth			= mMsg:readInt()
			char.mWeapon		= mMsg:readInt()
			char.mFashionCloth	= mMsg:readInt()
			char.mFashionWeapon	= mMsg:readInt()
			char.mWing			= mMsg:readInt()
			netchar[i] = char
			-- end
			if char.mSvrid>0 and curSvrid>0 and char.mSvrid == curSvrid then
				isCurSvr = true
			end
		end
		if self._reqChar then
			if isCurSvr then
				self._netChars = {}
				for k,v in ipairs(netchar) do
					if v.mSvrid == curSvrid or v.mSvrid == 0 then
						table.insert(self._netChars,v)
					end
				end
			else
				self._netChars=netchar
			end
			self:dispatchEvent({name=GameMessageCode.EVENT_LOADCHAR_LIST})
			self._reqChar=false
		end
	end,

	[GameMessageID.cResDeleteCharacter] = function(mMsg)
		local result = mMsg:readInt()
		if result == 100 then
			self:ListCharacter()
			--这个地方的url要检查
			--local url = CONFIG_CENTER_URL.."deleteRole?sku="..GameBaseLogic.sku.."&account="..GameBaseLogic.gameUserid.."&serverId="..GameBaseLogic.zoneId
			--	.."&pid="..GameCCBridge.getConfigString("platform_id").."&idfa="..GameCCBridge.getConfigString("system_code")
			--GameUtilSenior.httpRequest(url)--服务删角记录
		end
	end,

	[GameMessageID.cResEnterGame] = function(mMsg)

		local result=mMsg:readInt()

		if result==100 then
			GameBaseLogic.storyIndex = nil--防止意外掉线重连后不放剧情主线不继续

			-- if cc.UserDefault:getInstance():getStringForKey("last_receipt","")~="" then
			-- 	local last_receipt = "receipt|"..cc.UserDefault:getInstance():getStringForKey("last_receipt","")
			-- 	local last_money = cc.UserDefault:getInstance():getStringForKey("last_money","0")

			-- 	GameHttp:appCheckReceipt(last_receipt,last_money)

			-- 	local count = tonumber(cc.UserDefault:getInstance():getStringForKey("last_count","0"))
			-- 	cc.UserDefault:getInstance():setStringForKey("last_count",tostring(count+1))
			-- 	cc.UserDefault:getInstance():flush()
			-- end

			if not GameBaseLogic.noSubmit then
				if PLATFORM_APP_STORE then

				end
				GameBaseLogic.noSubmit = false
			end

			-- GameBaseLogic.cleanGame()
		elseif result==103 then
			GameBaseLogic.storyIndex = nil--防止意外掉线重连后不放剧情主线不继续

		else
			-- GameBaseLogic.ExitToRelogin()
			-- GameCCBridge.hideWaiting()
			-- GameCCBridge.showMsg("账号登录失败")
			-- GameUtilSenior.showAlert("", "账号登录失败", "知道了")
		end
		self:dispatchEvent({name=GameMessageCode.EVENT_RES_ENTER_GAME,result=result})
	end,

	[GameMessageID.cResCreateCharacter] = function(mMsg)
		local result=mMsg:readInt()
		local seedname=mMsg:readString()
		local chrname=mMsg:readString()

		local error_msg="角色创建成功"
		if result ~= 100 then
			if result == 101 then
				error_msg = "角色创建失败,系统错误"
			elseif result == 102 then
				error_msg = "角色创建失败,不能创建更多的人物了"
			elseif result == 103 then
				error_msg = "角色创建失败,名称重复"
			elseif result == 104 then
				error_msg = "角色创建失败, 名称中包含非法字符"
			end
		else
			
			--这个地方的url要检查
			-- local url = CONFIG_CENTER_URL.."createRole?sku="..GameBaseLogic.sku.."&account="..GameBaseLogic.gameUserid.."&serverId="..GameBaseLogic.zoneId
			-- 	.."&pid="..GameCCBridge.getConfigString("platform_id").."&idfa="..GameCCBridge.getConfigString("system_code")
			-- GameUtilSenior.httpRequest(url)--服务创角记录

			GameBaseLogic.newRole = true
			GameBaseLogic.chrName = chrname
		end
		self:dispatchEvent({name=GameMessageCode.EVENT_CREATECHARACTOR,result=result,msg=error_msg,seedname=seedname})
	end,
	
	[GameMessageID.cNotifyListUpgradeDesp] = function (mMsg)
		local count = mMsg:readInt()
		for i=1,count do
			local tt=mMsg:getValues("iiiiiiiiiiiii")
			local uid = {}
			uid.mJob = tt[1]
			uid.mEquipType = tt[2]
			uid.mLevel = tt[3]
			uid.mDC = tt[4]
			uid.mDCMax = tt[5]
			uid.mMC = tt[6]
			uid.mMCMax = tt[7]
			uid.mSC = tt[8]
			uid.mSCMax = tt[9]
			uid.mAC = tt[10]
			uid.mACMax = tt[11]
			uid.mMAC = tt[12]
			uid.mMACMax = tt[13]
			self.mUpgradeDesp[uid.mJob*10000+uid.mEquipType*100+uid.mLevel]=uid
		end
		-- print("/////////cNotifyListUpgradeDesp///////////", count, GameUtilSenior.encode(self.mUpgradeDesp))
	end,

	[GameMessageID.cNotifyListItemChange] = function (mMsg)
		local count = mMsg:readInt()
		for i=1,count do
			local tt=mMsg:getValues("iiiiiiisssssssssssssississiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii")
			local newItem = {}
			newItem.position = tt[1]
			newItem.mTypeID = tt[2]
			newItem.mDuraMax = tt[3]
			newItem.mDuration = tt[4]
			newItem.mItemFlags = tt[5]

			newItem.mLevel = tt[6]
			newItem.mNumber = tt[7]

			newItem.mAddAC = tt[8]
			newItem.mAddMAC = tt[9]
			newItem.mAddDC = tt[10]
			newItem.mAddMC = tt[11]
			newItem.mAddSC = tt[12]

			newItem.mUpdAC = tt[13]
			newItem.mUpdMAC = tt[14]
			newItem.mUpdDC = tt[15]
			newItem.mUpdMC = tt[16]
			newItem.mUpdSC = tt[17]

			newItem.mUpdMaxCount = tt[18]
			newItem.mUpdFailedCount = tt[19]

			newItem.mLuck = tt[20]
			local show_flags = tt[21]
			newItem.mProtect = tt[22]

			newItem.mSellPriceType = tt[23]
			newItem.mSellPrice = tt[24]

			newItem.mAddHp = tt[25]
			newItem.mAddMp = tt[26]
			newItem.mCreateTime = tt[27]
			newItem.mLastTime = tt[28]
			newItem.mZLevel = tt[29]
			newItem.mLock = tt[30]
			
			newItem.mSpecialAC = tt[31]
			newItem.mSpecialACMax = tt[32]
			newItem.mSpecialMAC = tt[33]
			newItem.mSpecialMACMax = tt[34]
			newItem.mSpecialDC = tt[35]
			newItem.mSpecialDCMax = tt[36]
			newItem.mSpecialMC = tt[37]
			newItem.mSpecialMCMax = tt[38]
			newItem.mSpecialSC = tt[39]
			newItem.mSpecialSCMax = tt[40]
			newItem.mSpecialLuck = tt[41]
			newItem.mSpecialCurse = tt[42]
			newItem.mSpecialAccuracy = tt[43]
			newItem.mSpecialDodge = tt[44]
			newItem.mSpecialAntiMagic = tt[45]
			newItem.mSpecialAntiPoison = tt[46]
			newItem.mSpecialMax_hp = tt[47]
			newItem.mSpecialMax_mp = tt[48]
			newItem.mSpecialMax_hp_pres = tt[49]
			newItem.mSpecialMax_mp_pres = tt[50]
			newItem.mSpecialHolyDam = tt[51]
			newItem.mSpecialXishou_prob = tt[52]
			newItem.mSpecialXishou_pres = tt[53]
			newItem.mSpecialFantan_prob = tt[54]
			newItem.mSpecialFantan_pres = tt[55]
			newItem.mSpecialBaoji_prob = tt[56]
			newItem.mSpecialBaoji_pres = tt[57]
			newItem.mSpecialXixue_prob = tt[58]
			newItem.mSpecialXixue_pres = tt[59]
			newItem.mSpecialMabi_prob = tt[60]
			newItem.mSpecialMabi_dura = tt[61]
			newItem.mSpecialDixiao_pres = tt[62]
			newItem.mSpecialFuyuan_cd = tt[63]
			newItem.mSpecialFuyuan_pres = tt[64]
			newItem.mSpecialBeiShang = tt[65]
			newItem.mSpecialMianShang = tt[66]
			newItem.mSpecialACRatio = tt[67]
			newItem.mSpecialMCRatio = tt[68]
			newItem.mSpecialDCRatio = tt[69]
			newItem.mSpecialIgnoreDCRatio = tt[70]
			newItem.mSpecialPlayDrop = tt[71]
			newItem.mSpecialMonsterDrop = tt[72]
			newItem.mSpecialDropProtect = tt[73]
			newItem.mSpecialMabiProtect = tt[74]
			newItem.mSpecialBingdong_prob = tt[75]
			newItem.mSpecialBingdong_dura = tt[76]
			newItem.mSpecialShidu_prob = tt[77]
			newItem.mSpecialShidu_dura = tt[78]
			newItem.mSpecialBingdongProtect = tt[79]
			newItem.mSpecialShiduProtect = tt[80]
			newItem.mSpecialAttackSpeed = tt[81]

			if newItem.mTypeID > 0 and newItem.position > -999 then
				self.mItems[newItem.position] = newItem
			end
		end
		self:dispatchEvent({name=GameMessageCode.EVENT_ALL_ITEM_LOADED})
	end,

	[GameMessageID.cNotifyItemChange] = function(mMsg)
		local tt=mMsg:getValues("iiiiiiisssssssssssssississiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii")

		local newItem = {}
		newItem.position = tt[1]
		newItem.mTypeID = tt[2]
		newItem.mDuraMax = tt[3]
		newItem.mDuration = tt[4]
		newItem.mItemFlags = tt[5]

		newItem.mLevel = tt[6]
		newItem.mNumber = tt[7]

		newItem.mAddAC = tt[8]
		newItem.mAddMAC = tt[9]
		newItem.mAddDC = tt[10]
		newItem.mAddMC = tt[11]
		newItem.mAddSC = tt[12]

		newItem.mUpdAC = tt[13]
		newItem.mUpdMAC = tt[14]
		newItem.mUpdDC = tt[15]
		newItem.mUpdMC = tt[16]
		newItem.mUpdSC = tt[17]

		newItem.mUpdMaxCount = tt[18]
		newItem.mUpdFailedCount = tt[19]


		newItem.mLuck = tt[20]
		local show_flags = tt[21]
		newItem.mProtect = tt[22]

		newItem.mSellPriceType = tt[23]
		newItem.mSellPrice = tt[24]

		newItem.mAddHp = tt[25]
		newItem.mAddMp = tt[26]
		newItem.mCreateTime = tt[27]
		newItem.mLastTime = tt[28]
		--print("======>>>",newItem.position,newItem.mTypeID,newItem.mLastTime)
		newItem.mZLevel = tt[29]
		newItem.mLock = tt[30]
		
		newItem.mSpecialAC = tt[31]
		newItem.mSpecialACMax = tt[32]
		newItem.mSpecialMAC = tt[33]
		newItem.mSpecialMACMax = tt[34]
		newItem.mSpecialDC = tt[35]
		newItem.mSpecialDCMax = tt[36]
		newItem.mSpecialMC = tt[37]
		newItem.mSpecialMCMax = tt[38]
		newItem.mSpecialSC = tt[39]
		newItem.mSpecialSCMax = tt[40]
		newItem.mSpecialLuck = tt[41]
		newItem.mSpecialCurse = tt[42]
		newItem.mSpecialAccuracy = tt[43]
		newItem.mSpecialDodge = tt[44]
		newItem.mSpecialAntiMagic = tt[45]
		newItem.mSpecialAntiPoison = tt[46]
		newItem.mSpecialMax_hp = tt[47]
		newItem.mSpecialMax_mp = tt[48]
		newItem.mSpecialMax_hp_pres = tt[49]
		newItem.mSpecialMax_mp_pres = tt[50]
		newItem.mSpecialHolyDam = tt[51]
		newItem.mSpecialXishou_prob = tt[52]
		newItem.mSpecialXishou_pres = tt[53]
		newItem.mSpecialFantan_prob = tt[54]
		newItem.mSpecialFantan_pres = tt[55]
		newItem.mSpecialBaoji_prob = tt[56]
		newItem.mSpecialBaoji_pres = tt[57]
		newItem.mSpecialXixue_prob = tt[58]
		newItem.mSpecialXixue_pres = tt[59]
		newItem.mSpecialMabi_prob = tt[60]
		newItem.mSpecialMabi_dura = tt[61]
		newItem.mSpecialDixiao_pres = tt[62]
		newItem.mSpecialFuyuan_cd = tt[63]
		newItem.mSpecialFuyuan_pres = tt[64]
		newItem.mSpecialBeiShang = tt[65]
		newItem.mSpecialMianShang = tt[66]
		newItem.mSpecialACRatio = tt[67]
		newItem.mSpecialMCRatio = tt[68]
		newItem.mSpecialDCRatio = tt[69]
		newItem.mSpecialIgnoreDCRatio = tt[70]
		newItem.mSpecialPlayDrop = tt[71]
		newItem.mSpecialMonsterDrop = tt[72]
		newItem.mSpecialDropProtect = tt[73]
		newItem.mSpecialMabiProtect = tt[74]
		newItem.mSpecialBingdong_prob = tt[75]
		newItem.mSpecialBingdong_dura = tt[76]
		newItem.mSpecialShidu_prob = tt[77]
		newItem.mSpecialShidu_dura = tt[78]
		newItem.mSpecialBingdongProtect = tt[79]
		newItem.mSpecialShiduProtect = tt[80]
		newItem.mSpecialAttackSpeed = tt[81]
		local oldType=nil
		if self.mItems[newItem.position] ~= nil then
			--装备卸下
			oldType=self.mItems[newItem.position].mTypeID
			self.mItems[newItem.position] = nil
		end
		if GameBaseLogic.isPinTu(newItem.mTypeID) then
			GameSocket:PushLuaTable("gui.PanelBossPictrue.handlePanelData",GameUtilSenior.encode({actionid = "reqCheckRedPoint",params={}}))
		end
		--print("///////////////check_better_item///////////////show_flags", show_flags)
		if newItem.mTypeID > 0 and newItem.position > -999 then
			self.mItems[newItem.position] = newItem
			if show_flags > 0 and show_flags ~= 100 then --获得更好装备提示以及需要提示使用消耗丹药
				local itemdef = self:getItemDefByID(newItem.mTypeID)
				if itemdef then
					--print("///////////////check_better_item///////////////itemdef.mCanPush", itemdef.mCanPush )
					if GameBaseLogic.IsPosInBag(newItem.position) then
						if itemdef.mCanPush == 1 then
							if GameBaseLogic.IsEquipment(newItem.mTypeID) then
								--print("///////////////check_better_item///////////////", newItem.position, self:check_better_item(newItem.position))
								if self:check_better_item(newItem.position) then
									-- if not self.tipsMsg["tip_equip"] then self.tipsMsg["tip_equip"] = {} end
									-- 右侧装备提示
									-- table.insert(GameBaseLogic.PROMPT_ITEM.equip,1,{newItem.mTypeID, newItem.position, time = os.time()})
									self:dispatchEvent({name=GameMessageCode.EVENT_BETTER_ITEM, itemPos = newItem.position, mTypeID = newItem.mTypeID})
								end
							else
								-- if GameBaseLogic.isUsageTipProp(newItem.mTypeID) then
									self:dispatchEvent({name=GameMessageCode.EVENT_BETTER_ITEM, itemPos = newItem.position, mTypeID = newItem.mTypeID})
								-- end
								-- if itemdef.mEquipLevel > 0 and show_flags ~= 110 then -- 获得消耗品的使用提示--暂时屏蔽
								-- 	-- table.insert(GameBaseLogic.PROMPT_ITEM.diss,1,{newItem.mTypeID, newItem.position})
								-- 	-- self:dispatchEvent({name=GameMessageCode.EVENT_BETTER_ITEM, diss = true})
								-- end
							end
						end
						
						--------------获得物品动画--------------
						self:dispatchEvent({name = GameMessageCode.EVENT_ITEM_GOT_ANIMATION, typeid = newItem.mTypeID})
					end

					local msg = {
						{"获得了物品:", "30FF00"},
						{itemdef.mName, "30FF00"}
					}
					if itemdef.mColor > 0 then msg[2][2] = GameUtilSenior.getColorHex(itemdef.mColor) end
					self:alertLocalMsg(GameUtilSenior.encode(msg),"right")
				end
			end

			-- if newItem.position < 0 then -- 装备穿戴
				-- local b = self:checkTaskState(1000)
				-- if b == 74 or b == 78 or b == 82 then
				-- 	self:PushLuaTable("gui.moduleGuide.checkMainTaskEquip","")
				-- end
				-- self:PushLuaTable("gui.PanelEquipPreview.onPanelData",GameUtilSenior.encode({actionid = "onEquipUpgraded"}))
				-- if MainRole then GameCharacter.handleEquipChange(newItem.position) end
			-- end
			if newItem.position < 0 then
				if newItem.position == -2 then
					GameMusic.play("music/34.mp3")
				else
					GameMusic.play("music/33.mp3")
				end
			end
		end

		GameBaseLogic.bagFullFlag=self:isBagFull()
		-- print(newItem.position,newItem.position,newItem.position,newItem.position)

		self:dispatchEvent({name=GameMessageCode.EVENT_ITEM_CHANGE,pos=newItem.position,oldType=oldType})
		
		if show_flags ~= 100 then
			self:dispatchEvent({name = GameMessageCode.EVENT_CHECK_BETTER_EQUIP})
		end

		if MainRole then -- 主线检测强化转移
			GameCharacter.checkShiftEquip()
		end

		if self:isPosInBag(newItem.position) then--背包物品
			self:checkBagFull(newItem.position)
			-- self.bagItems[newItem.position] = newItem
			-- GameBaseLogic.recordBoxMatch()
			self:checkBagRedDot()
		end

		if self.mGemItems[newItem.position]~=nil then
			self.mGemItems[newItem.position]=nil
		end

		--宝石背包
		-- if newItem.position >= GameConst.ITEM_XUANJING_BEGIN and newItem.position < GameConst.ITEM_XUANJING_BEGIN + GameConst.ITEM_XUANJING_SIZE then
		-- 	self.mGemItems[newItem.position] = newItem
		-- 	self:PushLuaTable("gui.PanelQiangHua.handlePanelData",GameUtilSenior.encode({actionid = "chechGemRed",params = {}}))
		-- end
		-- if newItem.mTypeID>=10154 and newItem.mTypeID<=10163 then--称号升级材料
		-- 	self:PushLuaTable("gui.ContainerTitle.onPanelData",GameUtilSenior.encode({actionid = "reqTitleUp",params = {}}))
		-- end
	end,
	[GameMessageID.cNotifyListItemDesp] = function (mMsg)
		local count = mMsg:readInt()
		for i=1,count do
			local tt=mMsg:getValues("zziiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiilliiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiziiiiiiiiiiii")
			local nid = {}
			nid.mName = tt[1]
			nid.mDesp = tt[2]
			nid.mTypeID = tt[3]
			nid.mIconID = tt[4]
			nid.mPrice = tt[5]

			nid.mWeight = tt[6]
			nid.mLastTime = tt[7]

			nid.mDurationMax = tt[8]
			nid.mNeedType = tt[9]
			nid.mNeedParam = tt[10]

			nid.mNeedReinLv = tt[11]
			nid.mColor = tt[12]
			nid.mNotips = tt[13]
			nid.mResMale = tt[14]
			nid.mResFeMale = tt[15]

			nid.mAC = tt[16]
			nid.mACMax = tt[17]
			nid.mMAC = tt[18]
			nid.mMACMax = tt[19]
			nid.mDC = tt[20]
			nid.mDCMax = tt[21]
			nid.mMC = tt[22]
			nid.mMCMax = tt[23]
			nid.mSC = tt[24]
			nid.mSCMax = tt[25]

			nid.mLuck = tt[26]

			nid.mCurse = tt[27]
			nid.mAccuracy = tt[28]
			nid.mDodge = tt[29]
			nid.mAntiMagic = tt[30]
			nid.mAntiPoison = tt[31]

			nid.mHpRecover = tt[32]
			nid.mMpRecover = tt[33]
			nid.mPoisonRecover = tt[34]
			nid.SubType = tt[35]
			nid.HPChange = tt[36]

			nid.MPChange = tt[37]
			nid.ZipType = tt[38]
			nid.ZipNumber = tt[39]
			nid.mMabiProb = tt[40]
			nid.mMabiDura = tt[41]
			
			nid.mBingdongProb = tt[42]
			nid.mBingdongDura = tt[43]
			nid.mShiduProb = tt[44]
			nid.mShiduDura = tt[45]

			nid.mDixiaoPres = tt[46]
			nid.mFuyuanCd = tt[47]
			nid.mFuyuanPres = tt[48]
			nid.mMaxHp = tt[49]
			nid.mMaxMp = tt[50]

			nid.mMaxHpPres = tt[51]
			nid.mMaxMpPres = tt[52]
			nid.mNeedZsLevel = tt[53]
			nid.mEquipLevel = tt[54]
			nid.mEquipComp = tt[55]
			nid.mEquipGroup = tt[56]
			nid.mEquipContribute = tt[57]
			nid.mShowDest = tt[58]
			nid.mAddPower = tt[59]
			nid.mJob = tt[60]
			nid.mGender = tt[61]
			nid.mBaoji = tt[62]

			nid.mDrop_luck = tt[63]
			nid.mStackMax = tt[64]
			nid.mEquipType = tt[65]
			nid.mXishouProb = tt[66]
			nid.mXishouPres = tt[67]

			nid.mFantanProb = tt[68]
			nid.mFantanPres = tt[69]
			nid.mBaojiProb = tt[70]
			nid.mBaojiPres = tt[71]
			nid.mXixueProb = tt[72]

			nid.mXixuePres = tt[73]
			nid.mRandAC = tt[74]
			nid.mRandMAC = tt[75]
			nid.mRandDC = tt[76]
			nid.mRandMC = tt[77]

			nid.mRandSC = tt[78]
			nid.mItemBg = tt[79]

			nid.mRecycleExp = tt[80]
			nid.mRecycleXuefu = tt[81]
			nid.mCanUse = tt[82]
			nid.mCanDestroy = tt[83]
			nid.mCanDepot = tt[84]
			nid.mCanPush = tt[85]
			nid.mBagShow = tt[86]
			nid.mTimesLimit = tt[87]
			nid.mSource = tt[88]
			nid.mBeiShang = tt[89]
			nid.mMianShang = tt[90]
			
			nid.mACRatio = tt[91] --人物总体物防万分比
			nid.mMCRatio = tt[92] --人物总体魔防万分比
			nid.mDCRatio = tt[93] --人物总体战攻万分比
			nid.mIgnoreDCRatio = tt[94] --忽视防御万分比
			nid.mPlayDrop = tt[95]    --人物爆率万分比提升
			nid.mMonsterDrop = tt[96]    --人物爆率万分比提升
			nid.mDropProtect = tt[97]    --防爆几率万分比
			nid.mMabiProtect = tt[98]    --防止麻痹万分比
			nid.mBingdongProtect = tt[99]    --防止冰冻万分比
			nid.mShiduProtect = tt[100]    --防止释毒万分比
		
			nid.mAttackSpeed = tt[101]    --攻击速度加成

			nid.mPlusA={}
			nid.mPlusB={}
			
			--print(nid.mTypeID)
			self.mItemDesp[nid.mTypeID]=nid
			-- print("cNotifyListItemDesp", nid.mTypeID, GameUtilSenior.encode(nid));
		end
		
		-- self:dispatchEvent({name = GameMessageCode.EVENT_NOTIFY_GETITEMDESP,type_id = nid.mTypeID})
	end,

	[GameMessageID.cNotifyItemDesp] = function(mMsg)
		local nid={}

		local tt=mMsg:getValues("zziiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiilliiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiziiiiiiiiiiii")
		nid.mName = tt[1]
		nid.mDesp = tt[2]
		nid.mTypeID = tt[3]
		nid.mIconID = tt[4]
		nid.mPrice = tt[5]

		nid.mWeight = tt[6]
		nid.mLastTime = tt[7]
		
		nid.mDurationMax = tt[8]
		nid.mNeedType = tt[9]
		nid.mNeedParam = tt[10]

		nid.mNeedReinLv = tt[11]
		nid.mColor = tt[12]
		nid.mNotips = tt[13]
		nid.mResMale = tt[14]
		nid.mResFeMale = tt[15]

		nid.mAC = tt[16]
		nid.mACMax = tt[17]
		nid.mMAC = tt[18]
		nid.mMACMax = tt[19]
		nid.mDC = tt[20]
		nid.mDCMax = tt[21]
		nid.mMC = tt[22]
		nid.mMCMax = tt[23]
		nid.mSC = tt[24]
		nid.mSCMax = tt[25]

		nid.mLuck = tt[26]

		nid.mCurse = tt[27]
		nid.mAccuracy = tt[28]
		nid.mDodge = tt[29]
		nid.mAntiMagic = tt[30]
		nid.mAntiPoison = tt[31]

		nid.mHpRecover = tt[32]
		nid.mMpRecover = tt[33]
		nid.mPoisonRecover = tt[34]
		nid.SubType = tt[35]
		nid.HPChange = tt[36]

		nid.MPChange = tt[37]
		nid.ZipType = tt[38]
		nid.ZipNumber = tt[39]
		nid.mMabiProb = tt[40]
		nid.mMabiDura = tt[41]

		nid.mBingdongProb = tt[42]
		nid.mBingdongDura = tt[43]
		nid.mShiduProb = tt[44]
		nid.mShiduDura = tt[45]

		nid.mDixiaoPres = tt[46]
		nid.mFuyuanCd = tt[47]
		nid.mFuyuanPres = tt[48]
		nid.mMaxHp = tt[49]
		nid.mMaxMp = tt[50]

		nid.mMaxHpPres = tt[51]
		nid.mMaxMpPres = tt[52]
		nid.mNeedZsLevel = tt[53]
		nid.mEquipLevel = tt[54]
		nid.mEquipComp = tt[55]
		nid.mEquipGroup = tt[56]
		nid.mEquipContribute = tt[57]
		nid.mShowDest = tt[58]
		nid.mAddPower = tt[59]
		nid.mJob = tt[60]
		nid.mGender = tt[61]
		nid.mBaoji = tt[62]

		nid.mDrop_luck = tt[63]
		nid.mStackMax = tt[64]
		nid.mEquipType = tt[65]
		nid.mXishouProb = tt[66]
		nid.mXishouPres = tt[67]

		nid.mFantanProb = tt[68]
		nid.mFantanPres = tt[69]
		nid.mBaojiProb = tt[70]
		nid.mBaojiPres = tt[71]
		nid.mXixueProb = tt[72]

		nid.mXixuePres = tt[73]
		nid.mRandAC = tt[74]
		nid.mRandMAC = tt[75]
		nid.mRandDC = tt[76]
		nid.mRandMC = tt[77]

		nid.mRandSC = tt[78]
		nid.mItemBg = tt[79]

		nid.mRecycleExp = tt[80]
		nid.mRecycleXuefu = tt[81]
		nid.mCanUse = tt[82]
		nid.mCanDestroy = tt[83]
		nid.mCanDepot = tt[84]
		nid.mCanPush = tt[85]
		nid.mBagShow = tt[86]
		nid.mTimesLimit = tt[87]
		nid.mSource = tt[88]
		nid.mBeiShang = tt[89]
		nid.mMianShang = tt[90]
		
		nid.mACRatio = tt[91] --人物总体物防万分比
		nid.mMCRatio = tt[92] --人物总体魔防万分比
		nid.mDCRatio = tt[93] --人物总体战攻万分比
		nid.mIgnoreDCRatio = tt[94] --忽视防御万分比
		nid.mPlayDrop = tt[95]    --人物爆率万分比提升
		nid.mMonsterDrop = tt[96]    --人物爆率万分比提升
		nid.mDropProtect = tt[97]    --防爆几率万分比
		nid.mMabiProtect = tt[98]    --防止麻痹万分比
		nid.mBingdongProtect = tt[99]    --防止冰冻万分比
		nid.mShiduProtect = tt[100]    --防止释毒万分比
		
		nid.mAttackSpeed = tt[101]    --攻击速度加成

		nid.mPlusA={}
		nid.mPlusB={}

		-- if nid.mName and not (nid.mName == "" ) then
		-- 	nid.mName = reNameEquip(nid.mName)
		-- end
		
		self.mItemDesp[nid.mTypeID]=nid
		self:dispatchEvent({name = GameMessageCode.EVENT_NOTIFY_GETITEMDESP,type_id = nid.mTypeID})

	end,

	[GameMessageID.cNotifyItemPlusDespGroup] = function(mMsg)
		local count = mMsg:getValues("i")[1]
		for i=1,count do
			local tt=mMsg:getValues("iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiilliii")

			local ipd={}

			ipd.mItemPlusDef = tt[1]
			ipd.mItemTypeID = tt[2]
			ipd.mNeedType = tt[3]
			ipd.mNeedParam1 = tt[4]
			ipd.mNeedParam2 = tt[5]
			ipd.mNeedParam3 = tt[6]
			ipd.mNeedParam4 = tt[7]
			ipd.mNeedParam5 = tt[8]

			ipd.mAC = tt[9]
			ipd.mACMax = tt[10]
			ipd.mMAC = tt[11]
			ipd.mMACMax = tt[12]
			ipd.mDC = tt[13]

			ipd.mDCMax = tt[14]
			ipd.mMC = tt[15]
			ipd.mMCMax = tt[16]
			ipd.mSC = tt[17]
			ipd.mSCMax = tt[18]

			ipd.mLuck = tt[19]
			ipd.mCurse = tt[20]
			ipd.mAccuracy = tt[21]
			ipd.mDodge = tt[22]
			ipd.mAntiMagic = tt[23]

			ipd.mAntiPosion = tt[24]
			ipd.mHpRecover = tt[25]
			ipd.mMpRecover = tt[26]
			ipd.mPosionRecover = tt[27]
			ipd.mMabiProb = tt[28]

			ipd.mMabiDura = tt[29]
			ipd.mDixiaoPres = tt[30]
			ipd.mFuyuanCd = tt[31]
			ipd.mFuyuanPres = tt[32]
			ipd.mMaxHP = tt[33]

			ipd.mMaxMP = tt[34]
			ipd.mMaxHPPres = tt[35]
			ipd.mMaxMPPres = tt[36]
			ipd.mHalfBaoji = tt[37]

			local itemdef = self:getItemDefByID(ipd.mItemTypeID)
			if itemdef then
				if ipd.mItemPlusDef > 40000 then
					if not table.keyof(itemdef.mPlusB,ipd) then
						table.insert(itemdef.mPlusB,ipd)
					end
				else
					if not table.keyof(itemdef.mPlusA,ipd) then
						table.insert(itemdef.mPlusA,ipd)
					end
				end
			end
		end
	end,
----------------------------------------------------------------------------人物状态相关
	[GameMessageID.cResUseSkill] = function(mMsg)
		-- result:(1:不可使用技能；3:魔不够)
		local result=mMsg:readInt()
		local skill_type=mMsg:readInt()

		-- print("=================res skill "..result)
		if MainRole then
			if GameBaseLogic.IsLieHuoTypeSkill(skill_type) then
				if result == 9 then
					self.mLiehuoAction = true
					self.mLiehuoType = skill_type

					local curtime = GameBaseLogic.getTime()
					local mSkillCD, mPublicCD = GameBaseLogic.getSkillCDTime(skill_type)
					self.mPublicCDTime[mPublicCD] = curtime
					self.mSkillCDTime[skill_type] = curtime

					if not GameBaseLogic.IsSwitchSkill(skill_type) then
						print("-------------================,GameMessageCode.EVENT_SKILL_COOLDOWN")
						self:dispatchEvent({name=GameMessageCode.EVENT_SKILL_COOLDOWN,type=skill_type})
					end

				elseif result == 7 and skill_type == self.mLiehuoType then
					self.mLiehuoAction = false
					self.mLiehuoType = 0
				end
			end
			self:dispatchEvent({name = GameMessageCode.EVENT_SKILL_CHANGE})
			-- GameCharacter.showSkillName(skill_type)
			-- if result == 1 then
			-- 	if self.mStartAutoFight and self.mCharacter.mJob == 100 then
			-- 		GameCharacter._moveToNearAttack = true
			-- 	end
			-- end
			-- GameCharacter._readyUseSkill = true

		end
		-- self.isWaitingSkill = false
		-- if self.waitMove and not self.isWaitingSkill then --执行等待的寻路
		-- 	print("I'm going to move to the wait pos 111111111111111111111111111111111111111111111111111111")
		-- 	GameCharacter.startAutoMoveToMap(self.waitMove.mapName, self.waitMove.mX, self.waitMove.mY, self.waitMove.flag)
		-- 	self.waitMove = nil
		-- end
	end,

	[GameMessageID.cNotifyInjury] = function(mMsg)
		local srcid = mMsg:readUInt()
		local newhp = mMsg:readLong()
		local newpower = mMsg:readLong()
		local change = mMsg:readLong()
		local ttdelay = mMsg:readInt()
		local attacker = mMsg:readUInt()
		local effect_flags = mMsg:readInt()
		local change_power = mMsg:readLong()
		-- local tttime = GameBaseLogic.getTime() + ttdelay

		local param = {}
		param.srcid = srcid
		param.hp = newhp
		-- param.mp = mp
		-- param.maxhp = maxhp
		-- param.maxmp = maxmp
		param.power = newpower

		local pGhost = NetCC:getGhostByID(srcid)
		if pGhost then
			local delay = GameBaseLogic.getSkipTime() + ttdelay/1000
			pGhost:setNetValue(GameConst.net_attacked_time,delay)
		end

		if srcid==GameCharacter.mID then
			self:dispatchEvent({name=GameMessageCode.EVENT_SELF_HPMP_CHANGE,param=param})
			GameCharacter.handleAttacked(attacker)
		end
	end,

	-- [GameMessageID.cNotifyAttackMiss] = function(mMsg)
	-- 	mMsg:readInt()
	-- end,
	-- [GameMessageID.cNotifyMapItemOwner] = function(mMsg)
	-- 	print(1111111)
	-- 	local srcid = mMsg:readInt()
	-- 	local mMapItemOwner = mMsg:readInt()
	-- 	local mMapItemType = mMsg:readInt()

	-- 	local item = self.mNetGhosts[srcid]
	-- 	if item then
	-- 		item.mMapItemOwner=mMapItemOwner
	-- 		item.mMapItemType=mMapItemType
	-- 		self:dispatchEvent({name=GameMessageCode.EVENT_NEAR_LIST})
	-- 	end
	-- end,

	[GameMessageID.cResRelive] = function (mMsg)
		local src_id = mMsg:readInt()
		print("relive-----------------------src_id",src_id)
		if MainRole and GameCharacter.mID == src_id then
			self:dispatchEvent({name = GameMessageCode.EVENT_PLAYER_RELIVE, srcId = src_id})
		end
	end,

	[GameMessageID.cNotifyDie] = function(mMsg)
		local srcid = mMsg:readUInt()
		local ttdelay = mMsg:readInt()

		-- if self.mNetGhosts[srcid]~=nil then
		-- 	self.mNetGhosts[srcid].mNextHp=0
		-- 	self.mNetGhosts[srcid].mDead = true
		-- print("die-------------------",GameCharacter._mainAvatar.mX,GameCharacter._mainAvatar)
		if type(GameCharacter._mainAvatar)=="table" then
			for k,v in pairs(GameCharacter._mainAvatar) do
				-- print("_mainAvatar",k,v)
			end
		end
	end,

	[GameMessageID.cNotifyFindRoadGotoNotify] = function(mMsg)
		local map_name = mMsg:readString()
		local mx = mMsg:readInt()
		local my = mMsg:readInt()
		local target = mMsg:readString()
		local flag = mMsg:readInt()
		GameCharacter._mainAvatar = GameCharacter._mainAvatar or CCGhostManager:getMainAvatar()

		if target ~= "" then
			GameCharacter._targetNPCName = target
		end
		-- if not GameBaseLogic.checkMainTaskPaused() then
			-- if not self.isWaitingSkill then
				--print("GameCharacter.startAutoMoveToMap",map_name,mx,my,flag)
				if GameCharacter.startAutoMoveToMap then
					GameCharacter.startAutoMoveToMap(map_name,mx,my,flag)
				end
				-- self.m_AutoMovePos = cc.p(mx,my)
				-- self.m_AutoMoveFlag = flag -- 9表示 藏宝图寻路
				-- self:dispatchEvent({name = GameMessageCode.EVENT_FLY_PARAM, mapid = map_name, x = mx, y = my, visible = true})--小飞鞋提示
			-- else
			-- 	self.waitMove = {
			-- 		mapName = map_name,
			-- 		mX = mx,
			-- 		mY = my,
			-- 		flag = flag,
			-- 	}
			-- end
		-- end
		-- self:dispatchEvent({name=GameMessageCode.EVENT_FLYBOOT_SHOW})
	end,
----------------------------------------------------------------------------
	-- [GameMessageID.cNotifyPlayerAddInfo] = function(mMsg)
	-- 	local id = mMsg:readUInt()
	-- 	local level = mMsg:readInt()
	-- 	local ghostJob = mMsg:readInt()
	-- 	local ghostGender = mMsg:readInt()
	-- 	local maxHp = mMsg:readInt()
	-- 	local hp = mMsg:readInt()
	-- 	if self.mNetGhosts[id]~=nil then
	-- 		self.mNetGhosts[id].mLevel = level
	-- 		self.mNetGhosts[id].mJob = ghostJob
	-- 		self.mNetGhosts[id].mGender = ghostGender
	-- 		self.mNetGhosts[id].mMaxHp = maxHp

	-- 		if id == self.mCharacter.mID then
	-- 			self.mCharacter.mJob = ghostJob
	-- 			self.mCharacter.mGender = ghostGender
	-- 		end

	-- 		if id == GameSocket.mLastAimGhost then
	-- 			if MainRole then
	-- 				MainRole:changeTheAim(id)
	-- 			end
	-- 		end
	-- 	end
	-- end,

--------------------------------------------------------------------------

	[GameMessageID.cNotifyTeamInfo] = function(mMsg)
		local srcId = mMsg:readInt()
		local team_id = mMsg:readInt()
		local team_name = mMsg:readString()
		-- local netghost = self.mNetGhosts[id]
		-- if netghost then
		-- 	netghost.mTeamID = team_id
		-- 	netghost.mTeamName = team_name
		-- 	-- netghost.cmdRefreshName = true
		-- 	-- GameBaseLogic.GhostManager():updateSomeOneName(id)
		-- end

		local pGhost = CCGhostManager:getPixesGhostByID(srcId)
		if pGhost then
			pGhost:updateName(true)
		end
		print("cNotifyTeamInfo-------------",srcId,team_id,team_name)
	end,
	[GameMessageID.cResFriendApply] = function( mMsg )
		local friendName = mMsg:readString()
		if not self.tipsMsg["tip_friend"] then self.tipsMsg["tip_friend"] = {} end
		local exist = false
		for i,v in ipairs(self.tipsMsg["tip_friend"]) do
			if v.name == friendName then
				exist = true
			end
		end
		local friend = self:getPlayerInfo(friendName)
		if friend and _G["G_ShieldAddFriend"] == 0 then
			if not exist then
				table.insert(self.tipsMsg["tip_friend"],1,friend)
			end
			self:dispatchEvent({name = GameMessageCode.EVENT_SHOW_BOTTOM,str="tip_friend"})
		end

		-- self:dispatchEvent({name=GameMessageCode.EVENT_SHOW_TIPS,str = "addFriend",pName = name})
	end,
	[GameMessageID.cResFriendChange] = function(mMsg)

		local name = mMsg:readString()
		local title = mMsg:readInt()
		title = title%1000
		local online_state = mMsg:readInt()--0不在线，1在线，2表示不在线，不知是好友还是陌生人不改变friend基本信息
		local job = mMsg:readInt()
		local gender = mMsg:readInt()
		local level = mMsg:readInt()
		local guild = mMsg:readString()
		self.mFriends = self.mFriends or {}

		if title>0 and online_state<2 then
			self.mFriends[name] = self.mFriends[name] or {}
			self.mFriends[name].name = name
			self.mFriends[name].title = title
			self.mFriends[name].online_state = online_state
			self.mFriends[name].gender = gender
			self.mFriends[name].job = job
			self.mFriends[name].level = level
			self.mFriends[name].guild = guild
		else--陌生人或者好友下线
			if self.mFriends[name] then
				self.mFriends[name].title = title--删除好友需要改变title，不改变基本信息
				self.mFriends[name].online_state = online_state == 2 and 0 or online_state
			end
		end
		for k,v in pairs(self.chatRecent) do
			if v.name == name then
				self.chatRecent[k].online_state = online_state == 2 and 0 or online_state
				self:dispatchEvent({name = GameMessageCode.EVENT_CHAT_RECENT,str="private"})
				break
			end
		end
		if title == 102 then
			self:removeChatRecentPlayer(name)
		end
		self:dispatchEvent({name=GameMessageCode.EVENT_FRIEND_FRESH})
	end,

	[GameMessageID.cResFriendFresh] = function(mMsg)
		self:dispatchEvent({name=GameMessageCode.EVENT_FRIEND_FRESH, action="fresh"})
	end,

	[GameMessageID.cNotifyBlackBoard] = function(mMsg)
		self.mBlackBoardFlags = mMsg:readInt()
		self.mBlackBoardTitle = mMsg:readString()
		self.mBlackBoardMsg = mMsg:readString()
		self:dispatchEvent({name=GameMessageCode.EVENT_LABEL_ZC})
	end,

	[GameMessageID.cNotifyAlert] = function(mMsg)

		local param={}
		local firstInQueue = nil
		param.lv = mMsg:readInt()
		param.flags = mMsg:readInt()
		param.msg = mMsg:readString()
		if self.mTradeInfo.mTradeResult == 1 and param.msg=="交易取消" then 	
			return
		end

		if param.flags % 10 == 1 then
			firstInQueue = true
		end

		if param.flags == 2 then
			local ret = GameUtilSenior.decode(param.msg)
			param.msg = ret.notice
		end
		if param.lv%10 == 1 then--在中间部位从下方移动到屏幕中间  1
			self:alertLocalMsg(param.msg,"alert",nil, firstInQueue)
		end
		if math.floor(param.lv%1000 / 100) == 1 then -- 头顶上方提示 100
			self:alertLocalMsg(param.msg,"mid",nil, firstInQueue)
		end

		if math.floor(param.lv%10000 / 1000) == 1 then -- 人脚下提示 1000
			self:alertLocalMsg(param.msg,"bottom",nil, firstInQueue)
		end

		if math.floor(param.lv%100000 / 10000) == 1 then -- 走马灯  10000
			self:alertLocalMsg(param.msg,"post",nil, firstInQueue)
		end

		if math.floor(param.lv%1000000 / 100000) == 1 then -- 收益类型  100000
			local msg = param.msg
			local award = "right"
			if not GameUtilSenior.decode(param.msg) then
				-- if string.find(param.msg,"获得内功") then
				-- 	award = "centerInnerPower"
				-- end
				msg = GameUtilSenior.encode({
						[1] = {param.msg, "30FF00"},
					})
			end
			self:alertLocalMsg(msg,award,nil, firstInQueue)
		end

		if math.floor(param.lv%100 / 10) == 1 then   --10
			local channel = "system"
			local chatmsg,num = string.gsub(param.msg,"^%b[]",function(p)
				channel = string.sub(p,2,-2)
				return ""
			end)
			local netChat = {}
			if channel == "system" then
				netChat.m_strType = GameConst.str_chat_system--"【系统】"
			elseif channel =="world" then
				netChat.m_strType = GameConst.str_chat_world
			elseif channel =="guild" then
				netChat.m_strType = GameConst.str_chat_guild
			elseif channel =="group" then
				netChat.m_strType = GameConst.str_chat_group
			elseif channel =="near" then
				netChat.m_strType = GameConst.str_chat_near
			elseif channel =="private" then
				netChat.m_strType = GameConst.str_chat_private
			end
			-- netChat.m_strName = GameConst.str_channel_system--需要就加，不需要就空值
			netChat.m_uSrcId = 0
			netChat.m_strMsg = chatmsg--string.gsub(param.msg,"^%b[]","")
			self:addToMsgHistory(netChat)
		end
	end,

	[GameMessageID.cNotifyLableInfo] = function(mMsg)
		local param={}
		param.id = mMsg:readInt()
		param.info = mMsg:readString()
	end,

	[GameMessageID.cNotifyFreeDirectFly] = function(mMsg)
		local param = mMsg:readInt()
    end,

	[GameMessageID.cNotifySlaveState] = function(mMsg)
		self.mSlaveState = mMsg:readInt()
    end,

	[GameMessageID.cNotifyTaskChange] = function(mMsg)
		local param={}
		param.mTaskID = mMsg:readInt()
		param.mFlags = mMsg:readInt()
		param.mState = mMsg:readInt()
		param.mParam_1 = mMsg:readShort()
		param.mParam_2 = mMsg:readShort()
		param.mParam_3 = mMsg:readShort()
		param.mParam_4 = mMsg:readInt()
		param.mName = mMsg:readString()
		param.mShortDesp = mMsg:readString()
		--print("cNotifyTaskChange",GameUtilSenior.encode(param))
		self.mTasks[param.mTaskID]=nil
		param.mInfo=GameUtilSenior.decode(param.mShortDesp)
		self.mTasks[param.mTaskID]=param
		--print("cNotifyTaskChange",GameUtilSenior.encode(param))
		if param.mTaskID >=3000 and param.mTaskID<=3010 and param.mParam_2 ==1 then
			self.mTasks.lastFBId = param.mTaskID
		end
		if param.mTaskID == 1000 then
			self.mTaskTargetMon = nil
			self.mTaskTargetMap = nil
			if param.mInfo and param.mInfo.target_type == "mon" and param.mInfo.target_name ~= "任意怪物" then
				self.mTaskTargetMon = param.mInfo.target_name
				self.mTaskTargetMap = param.mInfo.target_map
			end
		end

		self:dispatchEvent({name=GameMessageCode.EVENT_TASK_CHANGE,cur_id = param.mTaskID})
	end,

	[GameMessageID.cNotifySkillDesp] = function(mMsg)

		local nsd={}
		nsd.skill_id = mMsg:readInt()
		nsd.mName= mMsg:readString()
		nsd.mDesp= mMsg:readString()
		nsd.mIconID = mMsg:readInt()
		nsd.mLevel = mMsg:readInt()
		nsd.mLevelMax = mMsg:readInt()
		nsd.mShortcut = mMsg:readInt()
		nsd.mEffectType = mMsg:readInt()
		nsd.mEffectResID = mMsg:readInt()
		nsd.mBaseSpell = mMsg:readInt()
		nsd.mSpell = mMsg:readInt()
		nsd.mConsumeMp = mMsg:readInt()
		nsd.mUseRange =mMsg:readInt()
		nsd.mMinDis = mMsg:readInt()
		nsd.mMaxDis = mMsg:readInt()
		nsd.mSoundID = mMsg:readInt()

		-- nsd.mNeedL1= mMsg:readInt()
		-- nsd.mL1Train= mMsg:readInt()
		-- nsd.mNeedL2= mMsg:readInt()
		-- nsd.mL2Train= mMsg:readInt()
		-- nsd.mNeedL3= mMsg:readInt()
		-- nsd.mL3Train= mMsg:readInt()
		nsd.mIsShow = mMsg:readInt()
		nsd.mCastWay = mMsg:readInt()
		nsd.mSeletWay = mMsg:readInt()
		nsd.mSKillCD = mMsg:readInt()
		nsd.mPublicCD = mMsg:readInt()
		nsd.mOrderID = mMsg:readInt()
		nsd.mNeedLevel = mMsg:readInt()
		nsd.mNeedExp = mMsg:readInt()

		nsd.mDamageDesp = mMsg:readString()
		nsd.mRangeDesp = mMsg:readString()
		nsd.mCDDesp = mMsg:readString()
		nsd.mExtEffectDesp = mMsg:readString()

		nsd.mDamageDespNext = mMsg:readString()
		nsd.mRangeDespNext = mMsg:readString()
		nsd.mCDDespNext = mMsg:readString()
		nsd.mExtEffectDespNext = mMsg:readString()
		nsd.mDamageEffect = mMsg:readInt()
		
		if not self.mSkillCDTime[nsd.skill_id] then
			self.mSkillCDTime[nsd.skill_id] = 0
		end

		if not self.mPublicCDTime[nsd.mPublicCD] then
			self.mPublicCDTime[nsd.mPublicCD] = 0
		end

		for i=1,#self.m_skillsDesp do
			if self.m_skillsDesp[i].skill_id == nsd.skill_id then
				self.m_skillsDesp[i] = nsd
				return
			end
		end
		table.insert(self.m_skillsDesp,nsd)
	end,

	[GameMessageID.cNotifySkillChange] = function(mMsg)
		--var skill_type:int = -1
		local skill_temp = {}
		skill_temp.mTypeID = mMsg:readInt()
		skill_temp.mLevel = mMsg:readInt()
		skill_temp.mExp = mMsg:readInt()
		skill_temp.mParam1 = mMsg:readInt()
		-- if skill_temp.mTypeID == GameConst.SKILL_TYPE_Jump then
		-- 	return
		-- end
		-- if not self.m_netSkill[skill_temp.mTypeID] then
		-- 	if not GameBaseLogic.IsPassiveSkill(skill_temp.mTypeID) then
		-- 		table.insert(self.m_skillAddList,skill_temp.mTypeID)
		-- 		-- self:dispatchEvent({name=GameMessageCode.EVENT_SKILL_CHANGE})
		-- 	end
		-- end
		
		if skill_temp.mLevel == 0 then
			for i=1,#self.m_skillsDesp do
				if self.m_skillsDesp[i].skill_id == skill_temp.mTypeID then
					self.m_skillsDesp[i] = nil
					local keyindex = table.keyof(self.m_skillAddList,skill_temp.mTypeID)
					if keyindex then
						table.remove(self.m_skillAddList,keyindex)
						self:dispatchEvent({name=GameMessageCode.EVENT_SKILL_CHANGE,remove_id = skill_temp.mTypeID})
						self:checkSkillRedPoint(skill_temp)
						return
					end
				end
			end
		end
		local needUpdate
		local passiveSkill = {102,103,412,513,614}---被动技能
		if not self.m_netSkill[skill_temp.mTypeID] then
			needUpdate = true 
		end
		-- if not self.m_netSkill[skill_temp.mTypeID] and not table.indexof(passiveSkill, skill_temp.mTypeID) then 
		-- 	needUpdate = true 
		-- end

		local skillLevelUp = false
		if self.m_netSkill[skill_temp.mTypeID] and skill_temp.mLevel > self.m_netSkill[skill_temp.mTypeID].mLevel then
			skillLevelUp = true
		end

		self.m_netSkill[skill_temp.mTypeID] = skill_temp
		if skill_temp.mTypeID == GameConst.SKILL_TYPE_BanYueWanDao then
			self.m_bBanYueOn = (skill_temp.mParam1 > 0) and true or false
			self:dispatchEvent({name=GameMessageCode.EVENT_SKILL_STATE, skill_type = skill_temp.mTypeID})
		elseif skill_temp.mTypeID == GameConst.SKILL_TYPE_CiShaJianShu then
			self.m_bCiShaOn = (skill_temp.mParam1 > 0) and true or false
			self:dispatchEvent({name=GameMessageCode.EVENT_SKILL_STATE, skill_type = skill_temp.mTypeID})
		elseif GameBaseLogic.IsLieHuoTypeSkill(skill_temp.mTypeID) then
			if skill_temp.mParam1 == 0 and skill_temp.mTypeID == self.mLiehuoType then 
				self.mLiehuoAction = false
				self.mLiehuoType = 0
			end
		end

		
		if needUpdate then
			-- local mainAvatar = CCGhostManager:getMainAvatar()
			-- GameCharacter._mainAvatar = GameCharacter._mainAvatar or CCGhostManager:getMainAvatar()
			-- if GameCharacter._mainAvatar then GameCharacter._mainAvatar:clearAutoMove() end
			local nsd = GameBaseLogic.getSkillDesp(skill_temp.mTypeID)
			local param = {
				name = GameMessageCode.EVENT_SHOW_TIPS,
				str = "newSkill",
				skillId = skill_temp.mTypeID,
				skillName = nsd.mName,
			}
			-- print("")
			self:dispatchEvent(param)

			GameCharacter.stopAutoFight()
			GameBaseLogic.isNewSkill = true
			-- self:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL,str = "panel_generaltips",skillId=skill_temp.mTypeID})
		end	
		-- if needUpdate then self:dispatchEvent({name=GameMessageCode.EVENT_SKILL_CHANGE, add_id = skill_temp.mTypeID}) end
		if skillLevelUp then
			self:dispatchEvent({name = GameMessageCode.EVENT_SKILL_LEVEL_UP, skill_type=skill_temp.mTypeID})
		end

		self:checkSkillRedPoint(skill_temp)
	end,

	[GameMessageID.cNotifyStatusDef] = function(mMsg)
		local status_id = mMsg:readInt()
		local num = mMsg:readInt()
		for i=1,num do
			local sd={}
			sd.mStatusID = status_id
			sd.mLv = mMsg:readInt()
			sd.mIcon = mMsg:readInt()
			sd.mAC = mMsg:readLong()
			sd.mACmax = mMsg:readLong()
			sd.mMAC = mMsg:readLong()
			sd.mMACmax = mMsg:readLong()
			sd.mDC = mMsg:readLong()
			sd.mDCmax = mMsg:readLong()
			sd.mMC = mMsg:readLong()
			sd.mMCmax = mMsg:readLong()
			sd.mSC = mMsg:readLong()
			sd.mSCmax = mMsg:readLong()
			sd.mHPmax = mMsg:readLong()
			sd.mMPmax = mMsg:readLong()
			sd.mNodef = mMsg:readInt()
			sd.mFightPoint = mMsg:readLong()
			sd.baoji = mMsg:readInt()
			sd.baoprob = mMsg:readInt()
			sd.mName = mMsg:readString()
			self.mStatusDesp[sd.mStatusID*100+sd.mLv] = sd
		end
	end,

	-- [GameMessageID.cNotifyBuffDesp] = function(mMsg)
	-- 	local bd = {}
	-- 	bd.id = mMsg:readInt()
	-- 	bd.name = mMsg:readString()
	-- 	bd.icon = mMsg:readString()
	-- 	bd.ui = mMsg:readInt()
	-- 	bd.uiSort = mMsg:readInt()
	-- 	bd.mType = mMsg:readInt()
	-- 	bd.level = mMsg:readInt()
	-- 	bd.desp = mMsg:readString()
	-- 	bd.effType= mMsg:readInt()
	-- 	bd.effres= mMsg:readInt()
	-- 	bd.validTimeMax = mMsg:readInt()
	-- 	self.mBuffDef[bd.id] = bd
	-- 	-- for k,v in pairs(bd) do
	-- 	-- 	print("buffDef----------------------",k,v)
	-- 	-- end
	-- end,
	[GameMessageID.cNotifyStatusChange] = function(mMsg)
		
		local srcId = mMsg:readInt()
		local buffId = mMsg:readShort()
		local status_param = mMsg:readInt()
		local timeRemain = mMsg:readDouble()
		local gap = mMsg:readInt()
		
		if srcId == GameCharacter.mID and buffId==20 then
			if timeRemain>0 then
				self.mMabiFlag = true
				self:alertLocalMsg("您已被麻痹,无法移动!!!", "alert")
				self.actionMoving = false
				GameCharacter._moveToNearAttack = false
				GameCharacter._autoMoving = false
				GameCharacter._readyKeepAttack = false
			else
				self.mMabiFlag = false
				self:alertLocalMsg("麻痹失效,恢复移动!!!", "alert")
			end
		end
		
		if srcId == GameCharacter.mID and buffId==102 then
			if timeRemain>0 then
				self.mBingdongFlag = true
				self:alertLocalMsg("您已被冰冻,无法移动!!!", "alert")
				self.actionMoving = false
				GameCharacter._moveToNearAttack = false
				GameCharacter._autoMoving = false
				GameCharacter._readyKeepAttack = false
			else
				self.mBingdongFlag = false
				self:alertLocalMsg("冰冻失效,恢复移动!!!", "alert")
			end
		end
		
		if srcId == GameCharacter.mID and buffId==104 then
			if timeRemain>0 then
				self.mJinGuFlag = true
				self:alertLocalMsg("您已被禁锢,无法移动!!!", "alert")
				self.actionMoving = false
				GameCharacter._moveToNearAttack = false
				GameCharacter._autoMoving = false
			else
				self.mJinGuFlag = false
				self:alertLocalMsg("禁锢失效,恢复移动!!!", "alert")
			end
		end
				
	end,
	
	[GameMessageID.cNotifyBuffChange] = function(mMsg)
		local srcId = mMsg:readInt()
		local buffId = mMsg:readInt()
		local opCode = mMsg:readInt()
		local timeRemain = mMsg:readDouble()

		self.mNetBuff[srcId] = self.mNetBuff[srcId] or {}
		if opCode == 0 then
			if self.mNetBuff[srcId][buffId] then
				-- local buffdef = self.mNetBuff[srcId][buffId].buffdef
				self.mNetBuff[srcId][buffId] = nil
			end
		elseif opCode == 1 or opCode == 2 then
			self.mNetBuff[srcId] = self.mNetBuff[srcId] or {}
			local buffdef = NetCC:getBuffDef(buffId)
			if buffdef and buffdef.id then
				self.mNetBuff[srcId][buffId] = {
					buffId = buffId,
					timeRemain = timeRemain,
					buffdef = buffdef,
					enable = true,
					starttime = os.time()---(buffdef.timemax/1000-timeRemain),
				}
			end
		elseif opCode == 3 or opCode == 4 then
			if self.mNetBuff[srcId] and self.mNetBuff[srcId][buffId] then
				self.mNetBuff[srcId][buffId].enable = opCode>3  --3是禁用4是启用
			end
		end
		if srcId == GameCharacter.mID then
			self:dispatchEvent({name = GameMessageCode.EVENT_BUFF_CHANGE, srcId = srcId,opCode = opCode})
		end
	end,

	[GameMessageID.cNotifyListBuff] = function(mMsg)
		local srcId = mMsg:readInt()
		local num = mMsg:readInt()
		local buffId,timeRemain
		for i=1,num do
			buffId = mMsg:readInt()
			timeRemain = mMsg:readDouble() 
			local buffdef = NetCC:getBuffDef(buffId)
			if buffdef and buffdef.id then
				self.mNetBuff[srcId] = self.mNetBuff[srcId] or {}
				self.mNetBuff[srcId][buffId] = {
					buffId = buffId,
					timeRemain = timeRemain,
					buffdef = buffdef,
					starttime = os.time()---(buffdef.timemax/1000-timeRemain),
				}
			end
		end
		if srcId == GameCharacter.mID then
			self:dispatchEvent({name = GameMessageCode.EVENT_BUFF_CHANGE, srcId = srcId})
		end
	end,

	-- [GameMessageID.cNotifyPushCocosGui] = function(mMsg)
	-- 	local gui_type = mMsg:readInt()
	-- 	local gui_name = mMsg:readString()
	-- 	local gui_state = mMsg:readInt()
	-- end,

	[GameMessageID.cNotifyProsperityChange] = function(mMsg)
		local mProsperity = mMsg:readInt()
		local mProsperityNext = mMsg:readInt()
	end,

	[GameMessageID.cNotifyMiniMapConn] = function(mMsg)

		local num = mMsg:readInt()
		for i=1,num do
			local from = mMsg:readString()
			local to = mMsg:readString()
			if self.mMiniMapConn[from] == nil then
				local mapConn = {}
				table.insert(mapConn,to)
				self.mMiniMapConn[from] = mapConn
			else
				table.insert(self.mMiniMapConn[from],to)
			end
		end
	end,

	[GameMessageID.cNotifyWarInfo] = function(mMsg)
		self.mWarState = mMsg:readInt()
		self.mKingGuild = mMsg:readString()
		self.mKingOfKings = mMsg:readString()
		CCGhostManager:updatePlayerName()
	end,

	[GameMessageID.cNotifyGuildCondition] = function(mMsg)
		local mGuildCondition = mMsg:readString()
	end,

	[GameMessageID.cNotifySlotAdd] = function(mMsg)
		local lastBag = self.mBagSlotAdd
		local lastDepot = self.mDepotSlotAdd
		self.mDepotSlotAdd = mMsg:readInt()
		self.mBagSlotAdd = mMsg:readInt()
		self.mBagMaxSlot = mMsg:readInt()
		self.mBagSlotAdd = 0
		local dispath = false
		if lastBag < self.mBagSlotAdd then
			for i=(self.mBagSlotAdd-5),self.mBagSlotAdd-1 do
				self:dispatchEvent({name=GameMessageCode.EVENT_ITEM_CHANGE,pos=GameConst.ITEM_BAG_SIZE+i})
			end
			dispath = true
		end
		if lastDepot < self.mDepotSlotAdd then
			for i=(self.mDepotSlotAdd-5),self.mDepotSlotAdd do
				self:dispatchEvent({name=GameMessageCode.EVENT_ITEM_CHANGE,pos=GameConst.ITEM_DEPOT_SIZE+1000+i})
			end
			dispath = true
		end
		if dispath == true then
			self:dispatchEvent({name=GameMessageCode.EVENT_SOLT_CHANGE})
		end
	end,

	[GameMessageID.cNotifyAttributeChange] = function(mMsg)
		local tt=mMsg:getValues("lliiiiiilllllllllliiiiiliiiiiiliiiiiiiiiiiiiiiiiiiiii")

		--print(GameUtilSenior.encode(tt))
		--print(GameUtilSenior.encode(self.mCharacter))
		if self.mCharacter.mMaxHp then
			local diff = {
				[1]  = {char = "mHp:",			value = tt[1 ] - self.mCharacter.mMaxHp,},
				[2]  = {char = "mAC:",			value = tt[10] - self.mCharacter.mAC, 			value2 = tt[9] - self.mCharacter.mMaxAC},
				[3]  = {char = "mMAC:",			value = tt[12] - self.mCharacter.mMAC,			value2 = tt[11] - self.mCharacter.mMaxMAC},
				[4]  = {char = "mDC:",			value = tt[14] - self.mCharacter.mDC, 			value2 = tt[13] - self.mCharacter.mMaxDC},
				[5]  = {char = "mMC:",			value = tt[16] - self.mCharacter.mMC, 			value2 = tt[15] - self.mCharacter.mMaxMC},
				[6]  = {char = "mSC:",			value = tt[18] - self.mCharacter.mSC, 			value2 = tt[17] - self.mCharacter.mMaxSC},
				[7]  = {char = "critPoint:",	value = tt[29] - self.mCharacter.critPoint,},
				[8]  = {char = "critProb:",		value = tt[28] - self.mCharacter.critProb,},
				[9]  = {char = "mLuck:",		value = tt[25] - self.mCharacter.mLuck,},
				[10] = {char = "mDodge:",		value = tt[20] - self.mCharacter.mDodge,},
				[11] = {char = "mAccuracy:",	value = tt[19] - self.mCharacter.mAccuracy,},
				[12] = {char = "tenacity:",		value = tt[30] - self.mCharacter.tenacity,},
				[13] = {char = "holyDam:",		value = tt[31] - self.mCharacter.holyDam,},
			}
			if not self.msgMid then
				self.msgMid = {}
			else
				GameUtilSenior.handleAttrChange(diff)
			end
		end
		self.levelChanged = false


		self.mCharacter.mMaxHp			= tt[1]
		self.mCharacter.mMaxMp			= tt[2]
		self.mCharacter.mMaxBurden		= tt[3]
		self.mCharacter.mBurden			= tt[4]
		self.mCharacter.mMaxLoad		= tt[5]
		
		self.mCharacter.mLoad			= tt[6]
		self.mCharacter.mMaxBrawn		= tt[7]
		self.mCharacter.mBrawn			= tt[8]
		self.mCharacter.mMaxAC			= tt[9]
		self.mCharacter.mAC				= tt[10]
		
		self.mCharacter.mMaxMAC			= tt[11]
		self.mCharacter.mMAC			= tt[12]
		self.mCharacter.mMaxDC			= tt[13]
		self.mCharacter.mDC				= tt[14]
		self.mCharacter.mMaxMC			= tt[15]
		
		self.mCharacter.mMC				= tt[16]
		self.mCharacter.mMaxSC			= tt[17]
		self.mCharacter.mSC				= tt[18]
		self.mCharacter.mAccuracy		= tt[19]
		self.mCharacter.mDodge			= tt[20]
		
		self.mCharacter.mDropProb		= tt[21]
		self.mCharacter.mDoubleAttProb	= tt[22]
		self.mCharacter.mTotalUpdLevel	= tt[23]
		self.mCharacter.mFightPoint		= tt[24]
		self.mCharacter.mLuck			= tt[25]
		
		self.mCharacter.mHonor			= tt[26]
		self.mCharacter.mXishou			= tt[27]
		
		self.mCharacter.critProb		= tt[28]--暴击几率
		self.mCharacter.critPoint		= tt[29]--暴击伤害
		self.mCharacter.tenacity		= tt[30]--韧性
		self.mCharacter.holyDam		= tt[31]--神圣
		
		self.mCharacter.mMabi_prob		= tt[32]
		self.mCharacter.mMabi_dura 		= tt[33]
		self.mCharacter.mBingdong_prob		= tt[34]
		self.mCharacter.mBingdong_dura		= tt[35]
		self.mCharacter.mShidu_prob		= tt[36]
		self.mCharacter.mShidu_dura		= tt[37]
		self.mCharacter.mDixiao_pres		= tt[38]
		self.mCharacter.mFuyuan_cd 		= tt[39]
		self.mCharacter.mFuyuan_pres 		= tt[40]
		self.mCharacter.mBeiShang 		= tt[41]
		self.mCharacter.mMianShang		= tt[42]

		self.mCharacter.mACRatio = tt[43]--人物总体物防万分比
		self.mCharacter.mMACRatio = tt[44]--人物总体魔防万分比
		self.mCharacter.mDCRatio = tt[45]--人物总体战攻万分比
		self.mCharacter.mIgnoreDCRatio = tt[46]--忽视防御万分比
		self.mCharacter.mPlayDrop = tt[47]--人物爆率万分比提升
		self.mCharacter.mMonsterDrop = tt[48]--人物爆率万分比提升
		self.mCharacter.mDropProtect = tt[49]--防爆几率万分比
		self.mCharacter.mMabiProtect = tt[50]--防止麻痹万分比
		self.mCharacter.mBingdongProtect = tt[51]--防止冰冻万分比
		self.mCharacter.mShiduProtect = tt[52]--防止释毒万分比
		
		self.mCharacter.mMaxHpPres = tt[53]--HP上限百分比


		-- self:dispatchEvent({name=GameMessageCode.EVENT_POWER_CHANGE})
		self:dispatchEvent({name=GameMessageCode.EVENT_ATTRIBUTE_CHANGE})
		self:dispatchEvent({name=GameMessageCode.EVENT_POWER_CHANGE})
	end,

	-- [GameMessageID.cNotifyNameAdd] = function(mMsg)
	-- 	local srcid = mMsg:readUInt()
	-- 	local namepre = mMsg:readString()
	-- 	local namepro = mMsg:readString()
	-- 	local netghost = self.mNetGhosts[srcid]
	-- 	if netghost then
	-- 		netghost.mNamePre = namepre
	-- 		netghost.mNamePro = namepro
	-- 		-- netghost.cmdRefreshName = true
	-- 		GameBaseLogic.GhostManager():updateSomeOneName(srcid)
	-- 	end
	-- end,

	[GameMessageID.cNotifyExpChange] = function(mMsg)

		self.mCharacter.mCurExperience = mMsg:readDouble()
		self.mCharacter.mCurrentLevelMaxExp = mMsg:readDouble()
		self.mCharacter.ExperienceChangeValue = mMsg:readInt()
		if self.mCharacter.ExperienceChangeValue > 0 then
			local msg = {
				[1] = {"获得经验:"..self.mCharacter.ExperienceChangeValue, "30FF00"}, --aE为标识
			}
			self:alertLocalMsg(GameUtilSenior.encode(msg),"right")
		end
		self:dispatchEvent({name=GameMessageCode.EVENT_EXP_CHANGE})
	end,

	[GameMessageID.cNotifyLoadShortcut] = function(mMsg)
		local param = {}
		local num = mMsg:readInt()
		for i=1,num do
			local shortCut = {}
			shortCut.cut_id = mMsg:readInt()
			shortCut.type = mMsg:readInt()
			shortCut.param = mMsg:readInt()
			shortCut.itemnum = 1
			self.mShortCut[shortCut.cut_id] = shortCut
			--print("cNotifyLoadShortcut==99999999999999999999999", shortCut.cut_id, shortCut.type, shortCut.param, shortCut.itemnum)
		end
		-- cut_id 序号，type 类型 1 (物品) 2(技能)，param 物品id 或者 技能id， itemnum 默认为1
		-- 总长度为16 前8 分配给技能，9-12分配给物品 13-16待定
		-- print("cNotifyLoadShortcut cNotifyLoadShortcut cNotifyLoadShortcut cNotifyLoadShortcut", num, GameUtilSenior.encode(self.mShortCut))
		self:dispatchEvent({name = GameMessageCode.EVENT_SET_SHORTCUT})
	end,

	[GameMessageID.cNotifyFreeReliveLevel] = function(mMsg)
		local mFreeReliveLevel = mMsg:readInt()
	end,

	[GameMessageID.cNotifyLevelChange] = function(mMsg)
		self.levelChanged = true
		local level = mMsg:readInt()
		--GameCCBridge.callPlatformFunc({func="setPlayerLevel", level=level})
		local netGhost = NetCC:getMainGhost()
		if netGhost then
			netGhost:setNetValue(GameConst.net_level, level)
			if  self.mCharacter.mLevel ~= level then
				self.mCharacter.mLevel = level
				GameBaseLogic.level = self.mCharacter.mLevel
				self.m_bLevelChanged = true
				if GameCCBridge then
					if self.levelUpdateChangeLastTime+5 < os.time() then
						self.levelUpdateChangeLastTime = os.time()
						GameCCBridge.doSubmitExtendData(GameCCBridge.TYPE_LEVEL_UP)
							print("=============cNotifyLevelChange")
					end
				end
			end
			GameMusic.play("music/48.mp3")
			self:dispatchEvent({name = GameMessageCode.EVENT_LEVEL_CHANGE, level = level})
		end

		if GameBaseLogic.GetMainRole() and (PLATFORM_360 or PLATFORM_UC or PLATFORM_LINYOU) then

		end
	end,

	[GameMessageID.cNotifyMapMiniNpc] = function(mMsg)
		local nmmn={}
		nmmn.mID = mMsg:readInt()
		nmmn.mMapID = mMsg:readString()
		nmmn.mNpcName = mMsg:readString()
		nmmn.mNpcShortName = mMsg:readString()
		nmmn.mX = mMsg:readInt()
		nmmn.mY = mMsg:readInt()
		nmmn.mDirectFlyID = mMsg:readInt()
		nmmn.mShowNpcFlag = mMsg:readInt()
		nmmn.mNum = mMsg:readInt()

		if self.mNetMap.mMapID==nmmn.mMapID then
			local isExit = false
			for i=1,#self.mMiniNpc do
				if self.mMiniNpc[i].mID == nmmn.mID then
					self.mMiniNpc[i] = nmmn
					isExit = true
					--清理不需要的NPC
					if self.mMiniNpc[i].mX<1 and self.mMiniNpc[i].mY<1 then
						table.remove(self.mMiniNpc,i)
						return
					end
				end
			end
			if not isExit then
				table.insert(self.mMiniNpc,nmmn)
			end
		end
	end,

	[GameMessageID.cNotifyURL] = function(mMsg)
		local mRegURL = mMsg:readString()
		local mLoginURL = mMsg:readString()
		local mPayURL = mMsg:readString()
		local mWebhomeURL = mMsg:readString()
		local mBBSURL = mMsg:readString()
		local mDownloadURL = mMsg:readString()
		local mKefuURL = mMsg:readString()
		local mParamURL1 = mMsg:readString()
		local mParamURL2 = mMsg:readString()
		local mParamURL3 = mMsg:readString()
		local mParamURL4 = mMsg:readString()
		local mParamURL5 = mMsg:readString()
	end,

	[GameMessageID.cNotifyCapacityChange] = function(mMsg)
		local mCapacity = mMsg:readInt()
		local capacity = mMsg:readInt()
	end,

	[GameMessageID.cNotifyHPMPChange] = function(mMsg)

		local srcid = mMsg:readUInt()
		local hp = mMsg:readLong()
		local mp = mMsg:readLong()
		local maxhp = mMsg:readLong()
		local maxmp = mMsg:readLong()
		if hp<=0 then hp=0 end
		if mp<=0 then mp=0 end

		local param = {}
		param.srcid = srcid
		param.hp = hp
		param.mp = mp
		param.maxhp = maxhp
		param.maxmp = maxmp

		-- if self.mNetGhosts[srcid]~=nil then
		-- 	self.mNetGhosts[srcid].mHp=hp
		-- 	self.mNetGhosts[srcid].mMp=mp
		-- 	self.mNetGhosts[srcid].mMaxHp=maxhp
		-- 	self.mNetGhosts[srcid].mMaxmp=maxmp
		-- end
		-- GameCharacter.addGhostEffect(srcid,990012,"relive")
		if srcid==GameCharacter.mID then
			self:dispatchEvent({name=GameMessageCode.EVENT_SELF_HPMP_CHANGE,param=param})
		end
	end,

	[GameMessageID.cNotifyParamData] = function(mMsg)
		local srcid = mMsg:readInt()
		local id = mMsg:readInt()
		local desp = mMsg:readString()

		if not self.mParam[srcid] then
			self.mParam[srcid]={}
		end

		self.mParam[srcid][id]=desp
		-- print("cNotifyParamData------------------",srcid,id,desp)
	end,

	[GameMessageID.cNotifyParamDataLsit] = function(mMsg)
		local srcid = mMsg:readInt()
		local num = mMsg:readInt()

		if not self.mParam[srcid] then
			self.mParam[srcid]={}
		end

		for i=1,num do
			local id = mMsg:readInt()
			local desp = mMsg:readString()
			self.mParam[srcid][id]=desp
		end
	end,

	[GameMessageID.cNotifyOfflineExpInfo] = function(mMsg)
		local mOfflineTime = mMsg:readInt()
		local mOfflineTimeValide = mMsg:readInt()
		local mOfflineTimeValideMax = mMsg:readInt()
		local mOfflineExp = mMsg:readInt()
		local mOfflinePrice1 = mMsg:readInt()
		local mOfflinePrice2 = mMsg:readInt()
		local mOfflinePrice4 = mMsg:readInt()

	end,

	[GameMessageID.cNotifySetModel] = function(mMsg)
		local src_id = mMsg:readUInt()
		local id = mMsg:readInt()
		local model = mMsg:readInt()

		self.mModels[src_id] = self.mModels[src_id] or {}
		self.mModels[src_id][id] = model
		self:dispatchEvent({name=GameMessageCode.EVENT_MODEL_SET,modelId = id})
		-- self.other_panel_save="saved"
		if id==5 then -- vip
			show_player_vip(src_id)
			local nameSprite = GUIPixesObject.getPixesGhost(src_id):getNameSprite()
			if nameSprite then
				show_player_title(src_id,nameSprite)
			end
		end
		-- local mainAvatar = CCGhostManager:getMainAvatar()
		-- GameCharacter._mainAvatar = GameCharacter._mainAvatar or CCGhostManager:getMainAvatar()
		-- if GameCharacter._mainAvatar and  GameCharacter._mainAvatar:NetAttr(GameConst.net_id) == src_id and id == 7 and model > 0 then
		-- 	self:dispatchEvent({name = GameMessageCode.EVENT_HANDLE_FLOATING , btn = "main_mount" , visible = true})
		-- end
	end,

	-- [GameMessageID.cNotifyVipChange] = function(mMsg)
	-- 	local mVcoinAccu = mMsg:readInt()
	-- 	local mVipLevel = mMsg:readInt()
	-- end,

	[GameMessageID.cNotifyGameMoneyChange] = function(mMsg)
		self.mCharacter.mGameMoney = mMsg:readDouble()
		self.mCharacter.mGameMoneyBind = mMsg:readDouble()
		self.mCharacter.mVCoin = mMsg:readInt()
		self.mCharacter.mVCoinBind = mMsg:readInt()
		local param = {}
		param.gm_change = mMsg:readDouble()
		param.vc_change = mMsg:readInt()
		param.gmb_change = mMsg:readDouble()
		param.vcb_change = mMsg:readInt()
		-- GameMusic.play(GameConst.SOUND.give_gole_coin)

		-- if param.gm_change ~= 0 then--此物品已经废除
		-- 	self:dispatchChangeAlertMsg("获得金币","失去金币",param.gm_change)
		-- end
		if param.gm_change ~= 0 then
			if param.gm_change > 0 then
				local msg = {
					[1] = {"获得元宝:"..param.gm_change, "30FF00"},
				}
				self:alertLocalMsg(GameUtilSenior.encode(msg),"right")
			else
				self:dispatchChangeAlertMsg("获得元宝:","失去元宝:",param.gm_change)
			end
		end
		if param.gmb_change ~= 0 then
			self:dispatchChangeAlertMsg("获得绑定元宝:","失去绑定元宝:",param.gmb_change)
		end
		if param.vc_change ~= 0 then
			self:dispatchChangeAlertMsg("获得钻石:","失去钻石:",param.vc_change)
		end
		if param.vcb_change ~= 0 then
			self:dispatchChangeAlertMsg("获得绑定钻石:","失去绑定钻石:",param.vcb_change)
		end

		if param.gm_change>0 or param.vc_change>0 or param.gmb_change>0 or param.vcb_change>0 then
			--GameMusic.play("music/35.mp3")
		end

		self:dispatchEvent({name=GameMessageCode.EVENT_GAME_MONEY_CHANGE})
	end,

	[GameMessageID.cNotifyForceMove] = function(mMsg)
		local srcid = mMsg:readUInt()
		local newX = mMsg:readShort()
		local newY = mMsg:readShort()
		local dir = mMsg:readByte()
		-- GameCharacter.addGhostEffect(srcid,990013,"entermap")

		-- if GameCharacter._targetNPCName and GameCharacter._targetNPCName ~= "" then
		-- 	local pGhost=NetCC:findGhostByName(GameCharacter._targetNPCName)
		-- 	if pGhost then
		-- 		if pGhost:NetAttr(GameConst.net_type)==GameConst.GHOST_MONSTER then
		-- 			GameCharacter._targetNPCName = ""
		-- 			CCGhostManager:selectSomeOne(pGhost:NetAttr(GameConst.net_id))
		-- 			GameCharacter.startAutoFight()
		-- 		end
		-- 	end
		-- end
		if GameCharacter.mID == srcid then
			GameCharacter.MoveToContinueTask()
		end
	end,

	[GameMessageID.cNotifyCharacterLoad] = function(mMsg)
		GameCharacter._mainAvatar = CCGhostManager:getMainAvatar()
	end,

	[GameMessageID.cNotifyMapEnter] = function(mMsg)

		self.mNetMap={}
		self.mMiniNpc = {}
		self.mMapConn = {}

		local tt=mMsg:getValues("ziiiizziii")
		self.mNetMap.mMapID=tt[1]
		self.mNetMap.mMiniMapID=tt[5]
		self.mNetMap.mMapFile=tt[6]
		self.mNetMap.mName=tt[7]

		local wanderdight = tonumber(tt[10])
		GameBaseLogic.wanderFight=(wanderdight>0) and true or false
		print("----------------------cNotifyMapEnter",GameBaseLogic.wanderFight,MAIN_IS_IN_GAME)

		if MAIN_IS_IN_GAME then
			self:GameEnterMap()
		end
		
		--上传关卡日记
		GameCCBridge.doSdkStartPage(self.mNetMap.mName)
	end,

	[GameMessageID.cNotifyMapLeave] = function(mMsg)

		self.mNetMap.mLastMapID = self.mNetMap.mMapID
		self.mNetMap.mMapID = nil
		self.mCharacter.mX = 0
		self.mCharacter.mY = 0

		-- if self.mNetMap.mLastMapID and string.find(self.mNetMap.mLastMapID, "fbgr") then
		-- 	local b = self:checkTaskState(1000)
		-- 	if b == 26 or b == 39 or b == 54 then
		-- 		self.mNeedContinueTask = true
		-- 	end
		-- end
		self:dispatchEvent({name=GameMessageCode.EVENT_MAP_LEAVE})
		--活动地图取消小飞鞋
		-- local activityMap = {"v203","v204","v205","v202","v201","v301","chiwooBattle","v219","v220","v221","v222","v223","v224","v225","v226","v227","v228","v229"}
		-- if table.indexof(activityMap, self.mNetMap.mLastMapID) then
		-- 	self:dispatchEvent({name = GameMessageCode.EVENT_FLY_PARAM, visible = false})
		-- end
		
		--上传关卡日记
		GameCCBridge.doSdkFinishLevel(self.mNetMap.mName)
	end,

	[GameMessageID.cNotifyMapOption] = function(mMsg)
		self.loginEnded = true
		local mp ={}
		mp.map_id = mMsg:readString()
		mp.pkprohibit = mMsg:readByte()
		mp.pkallow = mMsg:readByte()
		mp.autoalive = mMsg:readByte()
		mp.nointeract = mMsg:readByte()
		mp.lockaction = mMsg:readByte()
		mp.wanderdight = mMsg:readByte()
		mp.fightstate = mMsg:readByte()
		-- for k,v in pairs(mp) do
		-- 	print("mp============",k,v)
		-- end
		GameSocket.mapOption = GameSocket.mapOption or {}
		GameSocket.mapOption[mp.map_id] = mp
		GameBaseLogic.wanderFight=(mp.wanderdight>0) and true or false

		if MainRole and GameCharacter._mainAvatar then --进入地图需要检测是否有自动移动的需求
			GameCharacter.checkAutoMove()
		end
	end,

	[GameMessageID.cNotifyTotalAttrParam] = function(mMsg)
		local num = mMsg:readInt()

		for i=1,num do
			local id = mMsg:readInt()
			self.mCharacter.mTotalAttrs[id] = {}
			self.mCharacter.mTotalAttrs[id].mJob 			= mMsg:readInt()
			self.mCharacter.mTotalAttrs[id].mLevel 			= mMsg:readInt()
			self.mCharacter.mTotalAttrs[id].mDC   			= mMsg:readInt()
			self.mCharacter.mTotalAttrs[id].mDCmax 			= mMsg:readInt()
			self.mCharacter.mTotalAttrs[id].mMC   			= mMsg:readInt()
			self.mCharacter.mTotalAttrs[id].mMCmax 			= mMsg:readInt()
			self.mCharacter.mTotalAttrs[id].mSC   			= mMsg:readInt()
			self.mCharacter.mTotalAttrs[id].mSCmax 			= mMsg:readInt()
			self.mCharacter.mTotalAttrs[id].mAC   			= mMsg:readInt()
			self.mCharacter.mTotalAttrs[id].mACmax 			= mMsg:readInt()
			self.mCharacter.mTotalAttrs[id].mMAC   			= mMsg:readInt()
			self.mCharacter.mTotalAttrs[id].mMACmax 		= mMsg:readInt()
			self.mCharacter.mTotalAttrs[id].mHPmax 			= mMsg:readLong()
			self.mCharacter.mTotalAttrs[id].mMPmax 			= mMsg:readLong()
			self.mCharacter.mTotalAttrs[id].mAccuary 		= mMsg:readInt()
			self.mCharacter.mTotalAttrs[id].mDodge 			= mMsg:readInt()
			self.mCharacter.mTotalAttrs[id].mLuck	 		= mMsg:readInt()
			self.mCharacter.mTotalAttrs[id].mDropProb 		= mMsg:readInt()
			self.mCharacter.mTotalAttrs[id].mDoubleAttProb 	= mMsg:readInt()
		end
	end,

	[GameMessageID.cNotifyMapConn] = function(mMsg)

		local nmc={}
		nmc.mMapID = mMsg:readString()
		nmc.mDesMapID = mMsg:readString()
		nmc.mDesMapName = mMsg:readString()
		nmc.mFromX = mMsg:readInt()
		nmc.mFromY = mMsg:readInt()
		nmc.mDesX = mMsg:readInt()
		nmc.mDesY = mMsg:readInt()
		nmc.mSize = mMsg:readInt()

		if self.mNetMap.mMapID==nmc.mMapID then
			self.mMapConn[nmc.mDesMapID] = nmc
		end

	end,

	[GameMessageID.cNotifyNpcShowFlags] = function(mMsg)
		local npc_id = mMsg:readUInt()
		local show_flag = mMsg:readInt()
	end,

	[GameMessageID.cNotifyAvatarChange] = function(mMsg)
		local srcid=mMsg:readUInt()
		local cloth=mMsg:readInt()
		local weapon=mMsg:readInt()
		local mount=mMsg:readInt()
		local name=mMsg:readString()
		local lovename=mMsg:readString()
		local wing=mMsg:readInt()
		local fabao=mMsg:readInt()
		local fashion=mMsg:readInt()
		--print("=====,",cloth,fashion)
		local zslevel=mMsg:readInt()
		local bemonster=mMsg:readInt()
		local low=mMsg:readByte()
		self:dispatchEvent({name=GameMessageCode.EVENT_AVATAR_CHANGE})
	end,
	[GameMessageID.cNotifyPowerChange] = function(mMsg)
		local srcId = mMsg:readInt()
		local power = mMsg:readLong()
		local maxPower = mMsg:readLong()
		-- print("innerpower_change --------------",srcId,power,maxPower)
		self:dispatchEvent({name=GameMessageCode.EVENT_INNERPOWER_CHANGE,srcId = srcId,power = power,maxPower = maxPower})
	end,
	
	-- [GameMessageID.cNotifyRelive] = function(mMsg)
	-- 	local srcId = mMsg:readInt()
	-- 	local rType = mMsg:readInt()
	-- 	local player = CCGhostManager:getPixesGhostByID(srcId)
	-- 	if player then
	-- 		player:showBloodBar()
	-- 	end
	-- end,

	-- [GameMessageID.cNotifyMapBye] = function(mMsg)
	-- 	local srcId = mMsg:readInt()
	-- 	ghost_map_bye(srcId)
	-- end,

	[GameMessageID.cResChangeAttackMode] = function(mMsg)
		local tempMode = mMsg:readInt()
		local changed = false
		if self.mAttackMode ~= tempMode then
			self.mAttackMode = tempMode
			changed = true
		end
		print("modeChange---------------------------",self.mAttackMode)
		self:dispatchEvent({name=GameMessageCode.EVENT_ATTACKMODE_CHANGE, modeChange = changed})
		-- GameBaseLogic.StatusManager().mAllReFreshName = true
		-- GameBaseLogic.GhostManager():updateAllName()
	end,

	[GameMessageID.cNotifyCountDown] = function(mMsg)
		self.m_nCountDownDelay = mMsg:readInt()
		self.m_strCountDownMsg = mMsg:readString()
		self:dispatchEvent({name=GameMessageCode.EVENT_COUNT_DOWN})
	end,

	-- [GameMessageID.cNotifyPKStateChange] = function(mMsg)
	-- 	local id = mMsg:readUInt()
	-- 	local pkvalue = mMsg:readInt()
	-- 	local pkstate = mMsg:readInt()
	-- 	local netghost = self.mNetGhosts[id]
	-- 	if netghost then
	-- 		netghost.mPKState = pkstate
	-- 		netghost.mPKValue = pkvalue
	-- 		-- netghost.cmdRefreshName = true
	-- 		GameBaseLogic.GhostManager():updateSomeOneName(id)
	-- 	end
	-- end,

	[GameMessageID.cNotifyGuildInfo] = function(mMsg)
		local guild_name = mMsg:readString()
		local guild_title = mMsg:readInt()
		local guild_seedid = mMsg:readString()
		
		local guildChanged = false -- 帮会是否改变，从无到有或者从有到无
		local titleChanged = false -- 帮会职务是否改变

		if self.mCharacter.mGuildName ~= guild_name then
			guildChanged = true
		end
		if self.mCharacter.mGuildTitle ~= guild_title then
			titleChanged = true
		end

		self.mCharacter.mGuildName = guild_name
		self.mCharacter.mGuildTitle = guild_title
		self.mCharacter.mGuildSeedId = guild_seedid

		-- GameCCBridge.callVoiceChat("logout_room")
		-- if self.mCharacter.mGuildName~="" then
		-- 	GameCCBridge.callVoiceChat("login_room",{seq=guild_seedid})
		-- end

		self:dispatchEvent({name=GameMessageCode.EVENT_GUILD_MSG, guildChanged = guildChanged, titleChanged = titleChanged})
		-- GUIMain.initVoiceSetting()
		-- self.mCharacter.cmdRefreshName = true
		-- GameBaseLogic.GhostManager():updateSomeOneName(self.mCharacter.mID)
	end,

	-- [GameMessageID.cNotifyGhostGuildInfo] = function(mMsg)
	-- 	local id = mMsg:readUInt()
	-- 	local guild_name = mMsg:readString()
	-- 	local guild_title = mMsg:readInt()
	-- 	local netghost = self.mNetGhosts[id]
	-- 	if netghost then
	-- 		-- print("==========cNotifyGhostGuildInfo",guild_name,guild_title)
	-- 		netghost.mGuildName = guild_name
	-- 		netghost.mGuildTitle = guild_title
	-- 		netghost.cmdRefreshName = true
	-- 		-- GameBaseLogic.GhostManager():updateSomeOneName(id)
	-- 		-- GameBaseLogic.GhostManager():updateSomeOneName(self.mCharacter.mID)
	-- 	end
	-- end,

	[GameMessageID.cNotifyGroupInfoChange] = function(mMsg)
		self.mCharacter.mGroupID = mMsg:readInt()
		self.mCharacter.mGroupPickMode = mMsg:readInt()
		self.mCharacter.mGroupName = mMsg:readString()

		-- if self.isFirstGetGroupInfoChange == nil then 
		-- 	self.isFirstGetGroupInfoChange = true 
		-- end

		local leader = mMsg:readString()
		local isSelfNew = false
		if GameBaseLogic.GetMainRole() then
			if string.len(leader) > 0 and leader ~= GameBaseLogic.GetMainRole():NetAttr(GameConst.net_name) and leader ~= self.mCharacter.mGroupLeader and not self.isFirstGetGroupInfoChange then
				self:alertLocalMsg("您成功加入["..leader.."]的队伍", "alert")
				isSelfNew = true
			end
		end
		self.mCharacter.mGroupLeader = leader

		local result = mMsg:readInt()
		local old = clone(self.mGroupMembers)
		if result == 0 and #old > 0 and not self.isFirstGetGroupInfoChange then
			self:alertLocalMsg("您已离开队伍", "alert")
		end

		self.mGroupMembers = {}
		for i=1,result do
			local gm={}
			local isNew = true
			gm.srcid = mMsg:readInt()
			gm.name = mMsg:readString()
			for j=1,#old do
				if gm.name == old[j].name then--老成员更新数据
					isNew = false
					gm.name = old[j].name
					gm.hp = old[j].hp
					gm.mp = old[j].mp
					gm.state = old[j].state

					gm.job = old[j].job
					gm.level = old[j].level
					gm.power = old[j].power
					gm.locateMap = old[j].locateMap
					gm.gender = old[j].gender
				end
			end
			if not isSelfNew and isNew and not self.isFirstGetGroupInfoChange then
				self:alertLocalMsg(gm.name.."加入了队伍", "alert")
			end
			self.mGroupMembers[i]=gm
		end

		if result ~= 0 and result < #old then
			for i,_ in ipairs(old) do
				local isLeave = true
				for j,__ in ipairs(self.mGroupMembers) do
					if old[i].name == self.mGroupMembers[j].name then
						isLeave = false
						break
					end
				end
				if isLeave and not self.isFirstGetGroupInfoChange then
					self:alertLocalMsg(old[i].name.."离开了队伍", "alert")
				end
			end
		end
		self.isFirstGetGroupInfoChange = false
		-- GUIMain.initVoiceSetting()
		self:dispatchEvent({name=GameMessageCode.EVENT_GROUP_LIST_CHANGED, type=GameMessageID.cNotifyGroupInfoChange})

		--刷新队伍内其他玩家名字
		if isSelfNew then
			--print("////////////////////////isSelfNew///////////////////////", isSelfNew)
			for i,v in ipairs(self.mGroupMembers) do
				local pGhost = CCGhostManager:getPixesGhostByID(v.srcid)
				--print("////////////////////////isSelfNew///////////////////////", v.srcid, pGhost)
				if pGhost then
					pGhost:updateName(true)
				end
			end
		end
	end,

	[GameMessageID.cNotifyGroupState] = function(mMsg)
		self.mCharacter.mGroupID = mMsg:readInt()
		local result = mMsg:readInt()
		for i=1,result do
			local gm={}
			gm.state = mMsg:readInt()
			gm.hp = mMsg:readLong()
			gm.mp = mMsg:readLong()
			gm.job = mMsg:readInt()
			gm.level = mMsg:readInt()
			gm.power = mMsg:readLong()
			gm.locateMap = mMsg:readString()
			gm.gender = mMsg:readInt()
			
			if i <= #self.mGroupMembers then
				table.merge(self.mGroupMembers[i], gm)
				-- self.mGroupMembers[i]=gm
			end
		end
		self:dispatchEvent({name=GameMessageCode.EVENT_GROUP_LIST_CHANGED, type=GameMessageID.cNotifyGroupState})
	end,

	[GameMessageID.cNotifyGroupInfo] = function(mMsg)
		local id =  mMsg:readInt()
		local group_id =  mMsg:readInt()
		local group_name =  mMsg:readString()
		local group_leader =  mMsg:readString()

		if group_id == 0 then
			self.nearByGroupInfo[id] = nil
		else
			self.nearByGroupInfo[id] = {
				group_id = group_id,
				group_leader = group_leader,
				group_name = group_name,
			}
		end
		print(id, group_id, group_name, group_leader)

		local pGhost = CCGhostManager:getPixesGhostByID(id)
		if pGhost then
			pGhost:updateName(true)
		end
		self:dispatchEvent({name=GameMessageCode.EVENT_GROUP_LIST_CHANGED, type=GameMessageID.cNotifyGroupInfo})
	end,

	[GameMessageID.cNotifyInviteGroupToMember] = function(mMsg)
		local mGroupLeader =  mMsg:readString()
		local mGroupID = mMsg:readInt()
		local inviter = NetCC:findGhostByName(mGroupLeader)
		if not self.tipsMsg["tip_group"] then self.tipsMsg["tip_group"] = {} end

		if not inviter then return end
		local groupType = GameSetting.getConf("GroupType")
		if groupType==3 then return end --拒绝组队邀请
		if groupType==1 then
			self:AgreeInviteGroup(mGroupLeader,mGroupID)
			return
		end

		local param = {
			name  = mGroupLeader,
			job   = inviter:NetAttr(GameConst.net_job),
			level = inviter:NetAttr(GameConst.net_level),
			power = inviter:NetAttr(GameConst.net_fight_point),
			gender= inviter:NetAttr(GameConst.net_gender),
			state = inviter:NetAttr(GameConst.net_state),
			group_id = mGroupID,
			msgType = "invite",
		}

		local needInsert = true
		for i,v in ipairs(self.tipsMsg["tip_group"]) do
			if v.name == mGroupLeader and v.msgType == "invite" then
				-- needInsert = false--只需要更新
				-- self.tipsMsg["tip_group"][i] = param
				table.remove(self.tipsMsg["tip_group"],i)
				break
			end
		end
		if needInsert then--需要插入新的申请，且消息数量+1
			table.insert(self.tipsMsg["tip_group"], param)
			self:dispatchEvent({name = GameMessageCode.EVENT_SHOW_BOTTOM,str="tip_group"})--申请加入
		end
	end,
	[GameMessageID.cNotifyJoinGroupToLeader] = function(mMsg)
		self.m_strApplyerName = mMsg:readString()
		local applyer = NetCC:findGhostByName(self.m_strApplyerName)
		if applyer then
			if not self.tipsMsg["tip_group"] then self.tipsMsg["tip_group"] = {} end

			local param = {
				name  = self.m_strApplyerName,
				job   = applyer:NetAttr(GameConst.net_job),
				level = applyer:NetAttr(GameConst.net_level),
				power = applyer:NetAttr(GameConst.net_fight_point),
				gender= applyer:NetAttr(GameConst.net_gender),
				state = applyer:NetAttr(GameConst.net_state),
				msgType = "apply",
			}

			local needInsert = true
			for i,v in ipairs(self.tipsMsg["tip_group"]) do
				if v.name == self.m_strApplyerName and v.msgType == "apply" then
					-- needInsert = false--只需要更新
					-- self.tipsMsg["tip_group"][i] = param
					table.remove(self.tipsMsg["tip_group"],i)
					break
				end
			end
			if needInsert then--需要插入新的申请，且消息数量+1
				table.insert(self.tipsMsg["tip_group"], param)
				self:dispatchEvent({name = GameMessageCode.EVENT_SHOW_BOTTOM,str="tip_group"})--申请加入
			end
		end
	end,

	[GameMessageID.cNotifyListGuildBegin] = function(mMsg)
		self.mGuildList = {}
		self.mCharacter.num_enter = 0
		print("//////////cNotifyListGuildBegin//////////")
	end,

	[GameMessageID.cNotifyListGuildEnd] = function(mMsg)
		-- local function compFunc(member1,member2)
		-- 	if member1.mLevelGuild ~= member2.mLevelGuild then
		-- 		return member1.mLevelGuild > member2.mLevelGuild
		-- 	else
		-- 		return member1.mMemberNumber > member2.mMemberNumber
		-- 	end
		-- end
		-- table.sort(self.mGuildList, compFunc)
		
		-- local selfGuildName = GameBaseLogic.GetMainRole():NetAttr(GameConst.net_guild_name)
		-- for i,v in ipairs(self.mGuildList) do
		-- 	if v.mName == selfGuildName then
		-- 		self.guildRanking = i
		-- 		break
		-- 	end
		-- end
		print("//////////cNotifyListGuildEnd//////////")
		self:dispatchEvent({name=GameMessageCode.EVENT_GUILD_LIST})
	end,

	[GameMessageID.cNotifyListGuildItem] = function(mMsg)
		local pName = mMsg:readString()
		local pGuild=self:getGuildByName(pName)
		if not pGuild then
			pGuild={}
			pGuild.mName=pName
			table.insert(self.mGuildList,pGuild)
		end
		pGuild.mGuildSeedId = mMsg:readString()
		pGuild.mMemberNumber = mMsg:readInt()
		pGuild.mDesp = mMsg:readString()
		pGuild.mMasterLevel = mMsg:readInt()
		pGuild.entering = mMsg:readInt()
		if pGuild.entering > 0 then
			self.mCharacter.num_enter = (self.mCharacter.num_enter or 0) + 1
		end
		pGuild.mLeader = mMsg:readString()
		pGuild.mLevelGuild = mMsg:readInt()
		pGuild.mGuildExp = mMsg:readInt()
		pGuild.mWarStatus = mMsg:readInt()
		pGuild.mWarStartTime = mMsg:readInt()

		print("//////////cNotifyListGuildItem//////////")
	end,

	[GameMessageID.cNotifyInfoItemChange] = function(mMsg)
		local src_id = mMsg:readUInt()
		local NetItem = {}
		NetItem.mPosition	= mMsg:readInt()
		NetItem.mTypeID 	= mMsg:readInt()
		NetItem.mDuraMax 	= mMsg:readInt()
		NetItem.mDuration  	= mMsg:readInt()
		NetItem.mItemFlags  = mMsg:readInt()
		NetItem.mLevel  	= mMsg:readInt()
		NetItem.mZLevel 	= mMsg:readInt()
		NetItem.mNumber 	= mMsg:readInt()
		NetItem.mAddAC  	= mMsg:readShort()
		NetItem.mAddMAC  	= mMsg:readShort()
		NetItem.mAddDC 		= mMsg:readShort()
		NetItem.mAddMC  	= mMsg:readShort()
		NetItem.mAddSC  	= mMsg:readShort()
		NetItem.mUpdAC  	= mMsg:readShort()
		NetItem.mUpdMAC 	= mMsg:readShort()
		NetItem.mUpdDC  	= mMsg:readShort()
		NetItem.mUpdMC  	= mMsg:readShort()
		NetItem.mUpdSC  	= mMsg:readShort()
		-- NetItem.mUpdMaxCount	= mMsg:readShort()--注释的4条服务器暂时没有发过来
		-- NetItem.mUpdFailedCount	= mMsg:readShort()
		NetItem.mLuck 		= mMsg:readShort()
		NetItem.mProtect  	= mMsg:readShort()
		-- NetItem.mSellPriceType	= mMsg:readShort()
		-- NetItem.mSellPrice 	= mMsg:readInt()
		NetItem.mAddHp  	= mMsg:readShort()
		NetItem.mAddMp  	= mMsg:readShort()
		NetItem.mCreateTime = mMsg:readInt()
		
		NetItem.mSpecialAC			= mMsg:readInt()
		NetItem.mSpecialACMax			= mMsg:readInt()
		NetItem.mSpecialMAC			= mMsg:readInt()
		NetItem.mSpecialMACMax			= mMsg:readInt()
		NetItem.mSpecialDC			= mMsg:readInt()
		NetItem.mSpecialDCMax			= mMsg:readInt()
		NetItem.mSpecialMC			= mMsg:readInt()
		NetItem.mSpecialMCMax			= mMsg:readInt()
		NetItem.mSpecialSC			= mMsg:readInt()
		NetItem.mSpecialSCMax			= mMsg:readInt()
		NetItem.mSpecialLuck			= mMsg:readInt()
		NetItem.mSpecialCurse			= mMsg:readInt()
		NetItem.mSpecialAccuracy			= mMsg:readInt()
		NetItem.mSpecialDodge			= mMsg:readInt()
		NetItem.mSpecialAntiMagic			= mMsg:readInt()
		NetItem.mSpecialAntiPoison			= mMsg:readInt()
		NetItem.mSpecialMax_hp			= mMsg:readInt()
		NetItem.mSpecialMax_mp			= mMsg:readInt()
		NetItem.mSpecialMax_hp_pres			= mMsg:readInt()
		NetItem.mSpecialMax_mp_pres			= mMsg:readInt()
		NetItem.mSpecialHolyDam			= mMsg:readInt()
		NetItem.mSpecialXishou_prob			= mMsg:readInt()
		NetItem.mSpecialXishou_pres			= mMsg:readInt()
		NetItem.mSpecialFantan_prob			= mMsg:readInt()
		NetItem.mSpecialFantan_pres			= mMsg:readInt()
		NetItem.mSpecialBaoji_prob			= mMsg:readInt()
		NetItem.mSpecialBaoji_pres			= mMsg:readInt()
		NetItem.mSpecialXixue_prob			= mMsg:readInt()
		NetItem.mSpecialXixue_pres			= mMsg:readInt()
		NetItem.mSpecialMabi_prob			= mMsg:readInt()
		NetItem.mSpecialMabi_dura			= mMsg:readInt()
		--NetItem.mSpecialBingdong_prob			= mMsg:readInt()   --元素属性没有加这个 
		--NetItem.mSpecialBingdong_dura			= mMsg:readInt()   --元素属性没有加这个 
		--NetItem.mSpecialShidu_prob			= mMsg:readInt()   --元素属性没有加这个 
		--NetItem.mSpecialShidu_dura			= mMsg:readInt()   --元素属性没有加这个 
		NetItem.mSpecialDixiao_pres			= mMsg:readInt()
		NetItem.mSpecialFuyuan_cd			= mMsg:readInt()
		NetItem.mSpecialFuyuan_pres			= mMsg:readInt()
		NetItem.mSpecialBeiShang			= mMsg:readInt()
		NetItem.mSpecialMianShang			= mMsg:readInt()
		NetItem.mSpecialACRatio			= mMsg:readInt()
		NetItem.mSpecialMCRatio			= mMsg:readInt()
		NetItem.mSpecialDCRatio			= mMsg:readInt()
		NetItem.mSpecialIgnoreDCRatio			= mMsg:readInt()
		NetItem.mSpecialPlayDrop			= mMsg:readInt()
		NetItem.mSpecialMonsterDrop			= mMsg:readInt()
		NetItem.mSpecialDropProtect			= mMsg:readInt()
		NetItem.mSpecialMabiProtect			= mMsg:readInt()
		NetItem.mSpecialBingdong_prob			= mMsg:readInt()
		NetItem.mSpecialBingdong_dura			= mMsg:readInt()
		NetItem.mSpecialShidu_prob			= mMsg:readInt()
		NetItem.mSpecialShidu_dura			= mMsg:readInt()
		NetItem.mSpecialBingdongProtect			= mMsg:readInt()
		NetItem.mSpecialShiduProtect			= mMsg:readInt()
		NetItem.mSpecialAttackSpeed 			= mMsg:readInt()
		--NetItem.mSpecialBingdongProtect			= mMsg:readInt()   --元素属性没有加这个 
		--NetItem.mSpecialShiduProtect			= mMsg:readInt()   --元素属性没有加这个 
		--print("NetItem.mPosition======>>>",NetItem.mPosition)
		--print("NetItem.mTypeID======>>>",NetItem.mTypeID)
		if self.mOthersItems[NetItem.mPosition] then
			self.mOthersItems[NetItem.mPosition] =nil
		end
		if NetItem.mTypeID > 0 then
			self.mOthersItems[NetItem.mPosition] = NetItem
			self.other_equip_save = "saved"
		end
		self:dispatchEvent({name=GameMessageCode.EVENT_PLAYEREQUIP_INFO})
	end,

	[GameMessageID.cResListGuild] = function(mMsg)
		local guild_num = mMsg:readInt()
		self.mGuildList = {}
		for i=1,guild_num do
			local pGuild			= {}
			pGuild.mName			= mMsg:readString()
			pGuild.mMemberNumber	= mMsg:readInt()
			pGuild.mDesp			= mMsg:readString()
			pGuild.mMasterLevel		= mMsg:readInt()
			pGuild.mLeader			= mMsg:readString()
			table.insert(self.mGuildList, pGuild)
		end
		print("//////////cResListGuild//////////")
	end,

	-- [GameMessageID.cNotifySessionClosed] = function(mMsg)
	-- 	local s =mMsg:readString()
	-- 	self.m_bIsDisConnect = true
	-- end,

	[GameMessageID.cNotifyShowProgressBar] = function(mMsg)
		local time = mMsg:readInt()
		local info = mMsg:readString()

		self:dispatchEvent({name=GameMessageCode.EVENT_START_PROGRESS,time = time,info=info})

		if self.m_bReqCollect then
			self.m_bCollecting = true
			self.m_bReqCollect = false
			self.m_collectTime = GameBaseLogic.getTime() + time*1500
		end
		print("cNotifyShowProgressBar")
	end,

	[GameMessageID.cNotifyCollectBreak] = function(mMsg)

		self:dispatchEvent({name=GameMessageCode.EVENT_STOP_PROGRESS})

		if self.m_bCollecting then
			self.m_bCollecting = false
		end
		print("cNotifyCollectBreak")
	end,
	[GameMessageID.cNotifyCollectEnd] = function (mMsg)
		local srcid = mMsg:readInt()
		if MainRole and GameCharacter.completeCollect then GameCharacter.completeCollect(srcid) end
		--self:dispatchEvent({name=GameMessageCode.EVENT_FINISH_COLLECT, srcid = srcid})
	end,
	
	[GameMessageID.cResListGuildMember] = function(mMsg)
		local guild_name = mMsg:readString()
		local list_type = mMsg:readInt()
		local result = mMsg:readInt()
		local member = {}
		for i=1,result do
			local guild_member = {}
			guild_member.nick_name = mMsg:readString()
			guild_member.title = mMsg:readShort()
			guild_member.online = mMsg:readShort()
			guild_member.gender = mMsg:readShort()
			guild_member.job = mMsg:readShort()
			guild_member.level = mMsg:readShort()
			guild_member.fight = mMsg:readLong()
			guild_member.guildpt = mMsg:readInt()
            guild_member.entertime = mMsg:readInt()
			member[guild_member.nick_name] = guild_member
		end
		local pGuild=self:getGuildByName(guild_name)
		-- for i=1,#self.mGuildList do
			-- if self.mGuildList[i].mName == guild_name then
			if pGuild then
				if list_type == 101 then
					pGuild.mRealMembers = member
				elseif list_type == 100 then
					pGuild.mEnteringMembers = member

				end
			end
		-- end
		self:dispatchEvent({name = GameMessageCode.EVENT_GUILD_MEMBER,data = pGuild, memberType = list_type})
		print("//////////cResListGuildMember//////////")
	end,
	[GameMessageID.cNotifyGuildMemberChange] = function(mMsg)
		self:dispatchEvent({name = GameMessageCode.EVENT_GUILD_MEMBER_CHANGE})
	end,
	
	[GameMessageID.cNotifyGuildWar] = function(mMsg)
		self:dispatchEvent({name = GameMessageCode.EVENT_GUILD_WAR_CHANGE})
	end,

	[GameMessageID.cResGetGuildInfo] = function(mMsg)
		-- local netGuild = {}
		-- netGuild.mName = mMsg:readString()
		-- netGuild.mMemberNumber = mMsg:readInt()
		-- netGuild.mDesp = mMsg:readString()
		-- netGuild.mNotice = mMsg:readString()
		-- table.insert(self.mGuildList,netGuild)
		local pName = mMsg:readString()
		local pGuild=self:getGuildByName(pName)
		if not pGuild then
			pGuild={}
			pGuild.mName=pName
			table.insert(self.mGuildList,pGuild)
		end
		pGuild.mMemberNumber = mMsg:readInt()
		pGuild.mDesp = mMsg:readString()
		pGuild.mNotice = mMsg:readString()
		pGuild.mLeader = mMsg:readString()
		pGuild.mLevelGuild = mMsg:readInt()
		pGuild.mGuildExp = mMsg:readInt()
		pGuild.mGuildSeedId = mMsg:readString()

		self:dispatchEvent({name = GameMessageCode.EVENT_GUILD_INFO})
		print("//////////cResGetGuildInfo//////////")
	end,

	[GameMessageID.cResGetChartInfo] = function(mMsg)
		local chart_type = mMsg:readInt()
		local page = mMsg:readInt()
		local num = mMsg:readInt()
		self.mChartData[chart_type] = {}
		for i = 1, num do
			local item	= {}
			item.name	= mMsg:readString()
			item.param	= mMsg:readLong()
			item.guild	= mMsg:readString()
			item.title	= mMsg:readString()
			item.job	= mMsg:readInt()
			item.lv		= mMsg:readInt()
			item.state	= mMsg:readByte()
			item.zslv 	= mMsg:readInt()
			item.gender = mMsg:readInt()
			table.insert(self.mChartData[chart_type], item)
			if item.name == GameBaseLogic.chrName then
				self.mChartData[chart_type].chartRank = i
			end
		end
		self.mChartType = chart_type
		self:dispatchEvent({name = GameMessageCode.EVENT_REQCHART_LIST,page=page})
	end,

	[GameMessageID.cResVcoinShopList] = function(mMsg)
		self.mVcoinShopNpcID = mMsg:readInt()
	end,

	[GameMessageID.cResNPCShop] = function(mMsg)
		local srcid = mMsg:readInt()
		local msg = mMsg:readString()
		local page = mMsg:readInt()
		local num = mMsg:readInt()
		self.mShopNpc.srcid = srcid
		self.mShopNpc.msg = msg
		self.mShopNpc.page = page
		self.mShopNpc.num = num
		self.mShopItemInfo = {}
		self.m_BestSellerNum = 0
		for i=1,num do
			local mSItemInfo = {}
			mSItemInfo.pos =  mMsg:readInt()
			mSItemInfo.good_id =  mMsg:readInt()
			mSItemInfo.type_id =  mMsg:readInt()
			mSItemInfo.number =  mMsg:readInt()
			mSItemInfo.price_type =  mMsg:readInt()
			mSItemInfo.price =  mMsg:readInt()
			mSItemInfo.oldprice =  mMsg:readInt()
			mSItemInfo.good_tag = mMsg:readInt()
			if mSItemInfo.pos > 1000 then
				self.m_BestSellerNum = self.m_BestSellerNum + 1
			end
			table.insert(self.mShopItemInfo,mSItemInfo)
		end
		if #self.mVcoinShopItem <= 0 and self.mShopNpc.srcid == self.mVcoinShopNpcID and page == 0 then
			self.mVcoinShopItem = {}
			for i=1,num do
				local mSItemInfo = {}
				mSItemInfo.pos = self.mShopItemInfo[i].pos
				mSItemInfo.good_id = self.mShopItemInfo[i].good_id
				mSItemInfo.type_id = self.mShopItemInfo[i].type_id
				mSItemInfo.number = self.mShopItemInfo[i].number
				mSItemInfo.price_type = self.mShopItemInfo[i].price_type
				mSItemInfo.price = self.mShopItemInfo[i].price
				mSItemInfo.oldprice = self.mShopItemInfo[i].oldprice
				mSItemInfo.good_tag = self.mShopItemInfo[i].good_tag
				table.insert(self.mVcoinShopItem,mSItemInfo)
			end
		end
		self:dispatchEvent({name = GameMessageCode.EVENT_NET_NPC_SHOP})
	end,

	[GameMessageID.cNotifyItemPanelFresh] = function(mMsg)
		local flag = mMsg:readInt();
		self.mSortFlag = nil
		self:dispatchEvent({name = GameMessageCode.EVENT_FRESH_ITEM_PANEL, flag = flag})
	end,

----------------------------------------------------------------------------------聊天相关
	[GameMessageID.cResMapChat] = function(mMsg)
		local netChat = {}
		local strMsg = mMsg:readString()
		netChat.m_strMsg,netChat.localPath,netChat.httpPath,netChat.duration,netChat.flag = GameSocket:SeparateVipAndMsg(strMsg)
		netChat.m_strType = GameConst.str_chat_near--"【附近】"--
		netChat.m_strName = GameBaseLogic.chrName
		self:addToMsgHistory(netChat)
	end,

	[GameMessageID.cNotifyMapChat] = function(mMsg)
		local netChat = {}
		netChat.m_uSrcId = mMsg:readInt()
		netChat.m_strName = mMsg:readString()
		netChat.m_lv = mMsg:readInt()
		netChat.m_gender = mMsg:readInt()
		netChat.m_job = mMsg:readInt()
		netChat.m_vip = mMsg:readInt()
		netChat.m_guild = mMsg:readString()

		local strMsg = mMsg:readString()
		netChat.m_strMsg,netChat.localPath,netChat.httpPath,netChat.duration,netChat.flag = GameSocket:SeparateVipAndMsg(strMsg)
		netChat.m_strType = GameConst.str_chat_near --"【附近】"
		if self:getRelation(netChat.m_strName)==102 then return end
		self:addToMsgHistory(netChat)
	end,

	[GameMessageID.cResPrivateChat] = function(mMsg)
		local netChat = {}
		netChat.m_strName = mMsg:readString()		
		local strMsg = mMsg:readString()
		netChat.m_strMsg,netChat.localPath,netChat.httpPath,netChat.duration,netChat.flag = GameSocket:SeparateVipAndMsg(strMsg)
		netChat.m_MyName = GameBaseLogic.chrName
		netChat.m_strType = "【私聊】"--GameConst.str_chat_private
		self:addToMsgHistory(netChat)
		self:addChatRecentPlayer(netChat.m_strName)
		local relation = self:getRelation(netChat.m_strName)
		if relation==0 and self.mFriends and self.mFriends[netChat.m_strName] then
			if self.mFriends[netChat.m_strName].online_state == 0 then
				self.mFriends[netChat.m_strName].online_state = 1
				self:dispatchEvent({name = GameMessageCode.EVENT_CHAT_RECENT,str="private"})
			end
		end
	end,

	[GameMessageID.cNotifyPrivateChat] = function(mMsg)
		local netChat = {}
		netChat.m_uSrcId = mMsg:readInt()
		netChat.m_strName = mMsg:readString()
		netChat.m_lv = mMsg:readInt()
		netChat.m_gender = mMsg:readInt()
		netChat.m_job = mMsg:readInt()
		netChat.m_vip = mMsg:readInt()
		netChat.m_guild = mMsg:readString()

		local strMsg = mMsg:readString()
		netChat.m_strMsg,netChat.localPath,netChat.httpPath,netChat.duration,netChat.flag = GameSocket:SeparateVipAndMsg(strMsg)
		netChat.m_strType = "【私聊】"--GameConst.str_chat_private
		local relation = self:getRelation(netChat.m_strName)
		if relation==102 then
			return
		elseif relation==0 then
			self.mFriends = self.mFriends or {}
			self.mFriends[netChat.m_strName] = self.mFriends[netChat.m_strName] or {}
			self.mFriends[netChat.m_strName].name = netChat.m_strName
			self.mFriends[netChat.m_strName].level = netChat.m_lv
			self.mFriends[netChat.m_strName].job = netChat.m_job
			self.mFriends[netChat.m_strName].title = 0
			self.mFriends[netChat.m_strName].guild = netChat.m_guild
			self.mFriends[netChat.m_strName].gender = netChat.m_gender
			if self.mFriends[netChat.m_strName].online_state ~= 1 then
				self.mFriends[netChat.m_strName].online_state = 1
				self:dispatchEvent({name = GameMessageCode.EVENT_CHAT_RECENT,str="private"})
			end
		end
		self:addToMsgHistory(netChat)
		self.tipsMsg["tip_private"] = {}
		table.insert(self.tipsMsg["tip_private"],netChat)
		self:dispatchEvent({name = GameMessageCode.EVENT_SHOW_BOTTOM,str="tip_private"})

		self:addChatRecentPlayer(netChat.m_strName)
	end,

	[GameMessageID.cResGuildChat] = function(mMsg)
		local netChat = {}
		local strMsg = mMsg:readString()
		netChat.m_strMsg,netChat.localPath,netChat.httpPath,netChat.duration,netChat.flag = GameSocket:SeparateVipAndMsg(strMsg)
		netChat.m_strName = GameBaseLogic.chrName
		-- netChat.m_strMsg = "<font color='#F5F5F5'>"..GameBaseLogic.chrName.."</font>"..netChat.m_strMsg
		netChat.m_strType = "【帮会】"--GameConst.str_chat_guild
		self:addToMsgHistory(netChat)
	end,

	[GameMessageID.cNotifyGuildChat] = function(mMsg)
		local netChat = {}
		netChat.m_uSrcId = mMsg:readInt()
		netChat.m_strName = mMsg:readString()
		netChat.m_lv = mMsg:readInt()
		netChat.m_gender = mMsg:readInt()
		netChat.m_job = mMsg:readInt()
		netChat.m_vip = mMsg:readInt()
		netChat.m_guild = mMsg:readString()

		local strMsg = mMsg:readString()
		netChat.m_strMsg,netChat.localPath,netChat.httpPath,netChat.duration,netChat.flag = GameSocket:SeparateVipAndMsg(strMsg)
		netChat.m_strType = "【帮会】"--GameConst.str_chat_guild
		if self:getRelation(netChat.m_strName)==102 then return end

		self:addToMsgHistory(netChat)
	end,

	[GameMessageID.cResGroupChat] = function(mMsg)
		local netChat = {}
		local strMsg = mMsg:readString()
		netChat.m_strMsg,netChat.localPath,netChat.httpPath,netChat.duration,netChat.flag = GameSocket:SeparateVipAndMsg(strMsg)
		-- netChat.m_strMsg = "<font color='#F5F5F5'>"..GameBaseLogic.chrName.."</font>"..netChat.m_strMsg
		netChat.m_strName = GameBaseLogic.chrName
		netChat.m_strType = "【队伍】"
		self:addToMsgHistory(netChat)
	end,

	[GameMessageID.cNotifyGroupChat] = function(mMsg)
		local netChat = {}
		netChat.m_uSrcId = mMsg:readInt()
		netChat.m_strName = mMsg:readString()
		netChat.m_lv = mMsg:readInt()
		netChat.m_gender = mMsg:readInt()
		netChat.m_job = mMsg:readInt()
		netChat.m_vip = mMsg:readInt()
		netChat.m_guild = mMsg:readString()
		local strMsg = mMsg:readString()
		netChat.m_strMsg,netChat.localPath,netChat.httpPath,netChat.duration,netChat.flag = GameSocket:SeparateVipAndMsg(strMsg)
		netChat.m_strType = "【队伍】"
		if self:getRelation(netChat.m_strName)==102 then return end
		self:addToMsgHistory(netChat)
	end,

	[GameMessageID.cResNormalChat] = function(mMsg)
		local netChat = {}
		local strMsg = mMsg:readString()
		netChat.m_strName = GameBaseLogic.chrName
		netChat.m_strMsg,netChat.localPath,netChat.httpPath,netChat.duration,netChat.flag = GameSocket:SeparateVipAndMsg(strMsg)
		netChat.m_strMsg = netChat.m_strMsg
		-- netChat.m_strMsg = "<font color='#F5F5F5'>"..GameBaseLogic.chrName..":</font>"..netChat.m_strMsg
		netChat.m_strType = GameConst.str_chat_near--"【普通】"
		self:addToMsgHistory(netChat)
	end,

	[GameMessageID.cNotifyNoramlChat] = function(mMsg)
		local netChat = {}
		netChat.m_uSrcId = mMsg:readInt()
		netChat.m_strName = mMsg:readString()
		netChat.m_lv = mMsg:readInt()
		netChat.m_gender = mMsg:readInt()
		netChat.m_job = mMsg:readInt()
		netChat.m_vip = mMsg:readInt()
		netChat.m_guild = mMsg:readString()
		local strMsg = mMsg:readString()
		netChat.m_strMsg,netChat.localPath,netChat.httpPath,netChat.duration,netChat.flag = GameSocket:SeparateVipAndMsg(strMsg)
		netChat.m_strType = GameConst.str_chat_near--"【普通】"
		if self:getRelation(netChat.m_strName)==102 then return end

		self:addToMsgHistory(netChat)

	end,

	[GameMessageID.cResWorldChat] = function(mMsg)
		local netChat = {}
		local strMsg = mMsg:readString()
		netChat.m_strMsg,netChat.localPath,netChat.httpPath,netChat.duration,netChat.flag = GameSocket:SeparateVipAndMsg(strMsg)
		netChat.m_strName = GameBaseLogic.chrName
		-- netChat.m_strMsg = "<font color='#DAA520'>"..GameBaseLogic.chrName..":</font>"..netChat.m_strMsg
		-- netChat.m_strMsg = GameBaseLogic.chrName..":"..netChat.m_strMsg
		netChat.m_strType = "【世界】"

		self:addToMsgHistory(netChat)
	end,

	[GameMessageID.cNotifyWorldChat] = function(mMsg)
		local netChat = {}
		netChat.m_uSrcId = mMsg:readInt()
		netChat.m_strName = mMsg:readString()
		netChat.m_lv = mMsg:readInt()
		netChat.m_gender = mMsg:readInt()
		netChat.m_job = mMsg:readInt()
		netChat.m_vip = mMsg:readInt()
		netChat.m_guild = mMsg:readString()

		local strMsg = mMsg:readString()
		netChat.m_strMsg,netChat.localPath,netChat.httpPath,netChat.duration,netChat.flag = GameSocket:SeparateVipAndMsg(strMsg)
		netChat.m_strType = "【世界】"
		if self:getRelation(netChat.m_strName)==102 then return end
	
		self:addToMsgHistory(netChat)
	end,

	[GameMessageID.cResHornChat] = function(mMsg)
		local netChat = {}
		local strMsg = mMsg:readString()
		netChat.m_strMsg,netChat.localPath,netChat.httpPath,netChat.duration,netChat.flag = GameSocket:SeparateVipAndMsg(strMsg)
		-- netChat.m_strMsg = "<font color='#C8C8C8'>"..GameBaseLogic.chrName.."</font>"..netChat.m_strMsg
		netChat.m_strMsg =  GameBaseLogic.chrName..":"..netChat.m_strMsg
		netChat.m_strType = "【喇叭】"
		netChat.m_strName = GameBaseLogic.chrName
		self:addToMsgHistory(netChat)
		local m_strHornMsg = netChat.m_strType..netChat.m_strMsg
		table.insert(self.mHornChat,m_strHornMsg)
		self:dispatchEvent({name = GameMessageCode.EVENT_HORN_CHAT})
	end,

	[GameMessageID.cNotifyHornChat] = function(mMsg)
		local netChat = {}
		netChat.m_uSrcId = mMsg:readInt()
		netChat.m_strName = mMsg:readString()
		netChat.m_lv = mMsg:readInt()
		netChat.m_gender = mMsg:readInt()
		netChat.m_job = mMsg:readInt()
		netChat.m_vip = mMsg:readInt()
		netChat.m_guild = mMsg:readString()
		local strMsg = mMsg:readString()
		netChat.m_strMsg,netChat.localPath,netChat.httpPath,netChat.duration,netChat.flag = GameSocket:SeparateVipAndMsg(strMsg)
		netChat.m_strType = "【喇叭】"
		if self:getRelation(netChat.m_strName)==102 then return end
		self:addToMsgHistory(netChat)
		local m_strHornMsg = netChat.m_strType.."["..netChat.m_strName.."]"..netChat.m_strMsg
		table.insert(self.mHornChat,m_strHornMsg)
		self:dispatchEvent({name = GameMessageCode.EVENT_HORN_CHAT})

	end,

	[GameMessageID.cNotifyMonsterChat] = function(mMsg)
		local netChat = {}
		netChat.m_uSrcId = mMsg:readInt()
		netChat.m_strMsg = mMsg:readString()
		local pixesGhost = GUIPixesObject.getPixesGhost(netChat.m_uSrcId)
		if pixesGhost then
			GUIPixesObject.addTypewritter(pixesGhost,netChat.m_strMsg)
		end
	end,

	[GameMessageID.cResNPCTalk] = function(mMsg)
		local n_id=mMsg:readUInt()
		local n_flag=mMsg:readInt()
		local n_param=mMsg:readInt()
		local n_title=mMsg:readString()
		local n_msg=mMsg:readString()
		--print("///////////////////cResNPCTalk////////////////////", n_id, n_flag, n_param, n_title, n_msg);
		if n_msg ~= "" then
			self.m_nNpcTalkId = n_id
			self.m_strNpcTalkMsg = n_msg
			local s,e = string.find(n_msg,"m_tasknpc")
			if s then
				self:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL,str = "panel_mainTask"})
			else
				self:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = "panel_npctalk"} )
			end
		end
	end,

	[GameMessageID.cNotifyGotoEndNotify] = function(mMsg)
		local target=mMsg:readString()
		GameCharacter._mainAvatar:clearAutoMove()
		GameCharacter.stopAutoFight()

		GameCharacter._targetNPCName = target

		GameCharacter.MoveToContinueTask()
	end,

	[GameMessageID.cResInfoPlayer] = function(mMsg)
		local playerEquip = {}
		playerEquip.player_id	= mMsg:readInt()
		playerEquip.name		= mMsg:readString()
		playerEquip.loverName	= mMsg:readString()
		playerEquip.guild		= mMsg:readString()
		playerEquip.job		    = mMsg:readInt()
		playerEquip.gender		= mMsg:readInt()
		playerEquip.fightpoint	= mMsg:readLong()

		playerEquip.level		= mMsg:readInt()		
		playerEquip.vipLv		= mMsg:readInt()
		local mountNum 			= mMsg:readInt()
		playerEquip.mountJie	= math.floor(mountNum/100)
		playerEquip.mountXing	= mountNum%100
		playerEquip.wingLv		= mMsg:readInt()

		-- playerEquip.vipLv		= self.mModels[playerEquip.player_id][5] or 0
		-- playerEquip.mountLv		= self.mModels[playerEquip.player_id][7] or 0
		-- playerEquip.wingLv		= self.mModels[playerEquip.player_id][11] or 0
		
		if self.m_PlayerEquip[playerEquip.name] then
			self.m_PlayerEquip[playerEquip.name] = playerEquip
		end
		self.other_avatar_save = "saved"

		if self.checkTargetName and self.checkTargetName == playerEquip.name then
			self:dispatchEvent({name=GameMessageCode.EVENT_OPEN_PANEL,str="panel_checkequip", pName = self.checkTargetName})
		end

		self:dispatchEvent({name = GameMessageCode.EVENT_PLAYER_INFO})
	end,

----------------------------------------------------------------------------------熔炉相关


--------------------------------------------------------------------------------------交易相关
	[GameMessageID.cNotifyTradeInvite] = function(mMsg)
		self.mTradeInviter = mMsg:readString()

		if G_CloseTrade < 1 then
			if not self.tipsMsg["tip_trade"] then self.tipsMsg["tip_trade"] = {} end
			table.insert(self.tipsMsg["tip_trade"],1, self.mTradeInviter)
			self:dispatchEvent({name = GameMessageCode.EVENT_SHOW_BOTTOM,str="tip_trade"})
		else
			self:PrivateChat(self.mTradeInviter, "我已关闭交易，请不要再烦我！")
		end
	end,

	[GameMessageID.cNotifyTradeInfo] = function(mMsg)

		self.mTradeInfo.mTradeGameMoney=mMsg:readInt()
		self.mTradeInfo.mTradeVcoin=mMsg:readInt()
		self.mTradeInfo.mTradeSubmit=mMsg:readInt()
		self.mTradeInfo.mTradeTarget=mMsg:readString()
		self.mTradeInfo.mTradeDesGameMoney=mMsg:readInt()
		self.mTradeInfo.mTradeDesVcoin=mMsg:readInt()
		self.mTradeInfo.mTradeDesSubmit=mMsg:readInt()
		self.mTradeInfo.mTradeDesLevel=mMsg:readInt()
		self.mTradeInfo.mTradeResult=mMsg:readInt()

		if self.mTradeInfo.mTradeVcoin > 0 then 
			self.mTradeRecord.mTradeVcoin = self.mTradeInfo.mTradeVcoin 
		end
		if self.mTradeInfo.mTradeDesVcoin > 0 then 
			self.mTradeRecord.mTradeDesVcoin = self.mTradeInfo.mTradeDesVcoin 
		end
		if self.mTradeInfo.mTradeTarget ~= "" then
			self.mTradeRecord.mTradeTarget = self.mTradeInfo.mTradeTarget 
		end
		------------------------------交易成功，记录交易------------------------------
		if self.mTradeInfo.mTradeResult == 1 then 
			local msgLost = ""
			for k,v in pairs(self.mThisTradeItems) do
				local itemName = self:getItemDefByID(v.mTypeID).mName
				if itemName then
					itemName = itemName.."*"..v.mNumber
					if msgLost == "" then 
						msgLost = itemName
					else
						msgLost = msgLost .."、"..itemName 
					end
				end
			end
			if self.mTradeRecord.mTradeVcoin and self.mTradeRecord.mTradeVcoin > 0 then
				msgLost = msgLost.."、"..self.mTradeRecord.mTradeVcoin.."元宝"
			end
			if msgLost ~= "" then msgLost = "失去:".. msgLost.."<br>" end

			local msgGot = ""
			for k,v in pairs(self.mDesTradeItems) do
				local itemName = self:getItemDefByID(v.mTypeID).mName
				if itemName then
					itemName = itemName.."*"..v.mNumber
					if msgGot == "" then 
						msgGot = itemName
					else
						msgGot = msgGot .."、"..itemName 
					end
				end
			end
			if self.mTradeRecord.mTradeDesVcoin and self.mTradeRecord.mTradeDesVcoin > 0 then
				msgGot = msgGot.."、"..self.mTradeRecord.mTradeDesVcoin.."元宝"
			end

			if msgGot ~= "" then msgGot = "获得:".. msgGot.."<br>" end

			if msgLost ~= "" or msgGot ~= "" then
				local record = "<font color=#00FF00>"..os.date("%Y-%m-%d %H:%M",os.time()).."</font><br>对象:<font color=#FF0000>"..self.mTradeRecord.mTradeTarget.."</font><br>"
				if msgLost ~= "" then
					record = record..msgLost
				end
				if msgGot ~= "" then
					record = record..msgGot
				end
				table.insert(self.mTradeLocalRecord, 1, record)
				-- -------------数据本地存储-------------
			end
		end

		-- self.mUiState = true
		-- if GameSocket.mUiState then
		if self.mTradeInfo.mTradeTarget ~= "" and not GameBaseLogic.panelTradeOpen then
			self:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL,str="panel_trade"})
			-- GameSocket.mUiState = false
		elseif self.mTradeInfo.mTradeTarget == "" and GameBaseLogic.panelTradeOpen then
			self:dispatchEvent({name = GameMessageCode.EVENT_CLOSE_PANEL,str="panel_trade"})
			-- GameSocket.mUiState = false
		end
		-- end
		self:dispatchEvent({name = GameMessageCode.EVENT_TRADE_MONEYCHANGE,str="panel_trade"})
	end,

	[GameMessageID.cNotifyTradeItemChange] = function(mMsg)
		local side = mMsg:readInt()
		local position = mMsg:readInt()
		local item = {}
		item.mTypeID 		= mMsg:readInt()
		item.mDuraMax 		= mMsg:readInt()
		item.mDuration 		= mMsg:readInt()
		item.mItemFlags 	= mMsg:readInt()
		item.mLevel 		= mMsg:readInt()
		item.mNumber 		= mMsg:readInt()
		item.mAddAC 		= mMsg:readShort()
		item.mAddMAC 		= mMsg:readShort()
		item.mAddDC 		= mMsg:readShort()
		item.mAddMC 		= mMsg:readShort()
		item.mAddSC 		= mMsg:readShort()
		item.mUpdAC 		= mMsg:readShort()
		item.mUpdMAC 		= mMsg:readShort()
		item.mUpdDC 		= mMsg:readShort()
		item.mUpdMC 		= mMsg:readShort()
		item.mUpdSC 		= mMsg:readShort()
		item.mLuck 			= mMsg:readShort()
		local show_flag 	= mMsg:readInt()
		item.mProtect 		= mMsg:readShort()
		item.mAddHp 		= mMsg:readShort()
		item.mAddMp 		= mMsg:readShort()
		item.mCreateTime 	= mMsg:readInt()
		--print("======>>>",item.mCreateTime)
		item.mSellPrice 	= mMsg:readInt()
		item.mZLevel 		= mMsg:readInt()
		item.mLock 			= mMsg:readInt()
		
		item.mSpecialAC			= mMsg:readInt()
		item.mSpecialACMax			= mMsg:readInt()
		item.mSpecialMAC			= mMsg:readInt()
		item.mSpecialMACMax			= mMsg:readInt()
		item.mSpecialDC			= mMsg:readInt()
		item.mSpecialDCMax			= mMsg:readInt()
		item.mSpecialMC			= mMsg:readInt()
		item.mSpecialMCMax			= mMsg:readInt()
		item.mSpecialSC			= mMsg:readInt()
		item.mSpecialSCMax			= mMsg:readInt()
		item.mSpecialLuck			= mMsg:readInt()
		item.mSpecialCurse			= mMsg:readInt()
		item.mSpecialAccuracy			= mMsg:readInt()
		item.mSpecialDodge			= mMsg:readInt()
		item.mSpecialAntiMagic			= mMsg:readInt()
		item.mSpecialAntiPoison			= mMsg:readInt()
		item.mSpecialMax_hp			= mMsg:readInt()
		item.mSpecialMax_mp			= mMsg:readInt()
		item.mSpecialMax_hp_pres			= mMsg:readInt()
		item.mSpecialMax_mp_pres			= mMsg:readInt()
		item.mSpecialHolyDam			= mMsg:readInt()
		item.mSpecialXishou_prob			= mMsg:readInt()
		item.mSpecialXishou_pres			= mMsg:readInt()
		item.mSpecialFantan_prob			= mMsg:readInt()
		item.mSpecialFantan_pres			= mMsg:readInt()
		item.mSpecialBaoji_prob			= mMsg:readInt()
		item.mSpecialBaoji_pres			= mMsg:readInt()
		item.mSpecialXixue_prob			= mMsg:readInt()
		item.mSpecialXixue_pres			= mMsg:readInt()
		item.mSpecialMabi_prob			= mMsg:readInt()
		item.mSpecialMabi_dura			= mMsg:readInt()
		item.mSpecialBingdong_prob			= mMsg:readInt()
		item.mSpecialBingdong_dura			= mMsg:readInt()
		item.mSpecialShidu_prob			= mMsg:readInt()
		item.mSpecialShidu_dura			= mMsg:readInt()
		item.mSpecialDixiao_pres			= mMsg:readInt()
		item.mSpecialFuyuan_cd			= mMsg:readInt()
		item.mSpecialFuyuan_pres			= mMsg:readInt()
		item.mSpecialBeiShang			= mMsg:readInt()
		item.mSpecialMianShang			= mMsg:readInt()
		item.mSpecialACRatio			= mMsg:readInt()
		item.mSpecialMCRatio			= mMsg:readInt()
		item.mSpecialDCRatio			= mMsg:readInt()
		item.mSpecialIgnoreDCRatio			= mMsg:readInt()
		item.mSpecialPlayDrop			= mMsg:readInt()
		item.mSpecialMonsterDrop			= mMsg:readInt()
		item.mSpecialDropProtect			= mMsg:readInt()
		item.mSpecialMabiProtect			= mMsg:readInt()
		item.mSpecialBingdong_prob			= mMsg:readInt()
		item.mSpecialBingdong_dura			= mMsg:readInt()
		item.mSpecialShidu_prob			= mMsg:readInt()
		item.mSpecialShidu_dura			= mMsg:readInt()
		item.mSpecialBingdongProtect			= mMsg:readInt()
		item.mSpecialShiduProtect			= mMsg:readInt()
		item.mSpecialAttackSpeed 			= mMsg:readInt()
		item.position 		= position

		if position < 12 then
			if side == 100 then
				self.mThisChangeItems[position] = true
				self.mThisTradeItems[position] = item
			elseif side == 101 then
				self.mDesChangeItems[position] = true
				self.mDesTradeItems[position] = item
			end
			self:dispatchEvent({name = GameMessageCode.EVENT_TRADE_ITEMCHANGE,mType = "faceTrade"})
		end
		if position>=4000 and position<4010 then
			
			if side == 101 then
				self:dispatchEvent({name = GameMessageCode.EVENT_TRADE_ITEMCHANGE,mType = "showItemDef",nItem = item})
			else
				self.mChatTradeItemList[position] = item

				self:dispatchEvent({name = GameMessageCode.EVENT_TRADE_ITEMCHANGE,mType = "chatTrade"})
			end
		end
	end,

--------------------------------------------------------------------------------------
	[GameMessageID.cNotifyItemTalk] = function(mMsg)
		self.m_nItemTalkId = mMsg:readInt()
		self.m_nNpcTalkId = mMsg:readInt()
		local title = mMsg:readString()
		self.m_strNpcTalkMsg = mMsg:readString()
		self:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL,str="panel_itemtalk"})
	end,

	[GameMessageID.cNotifyPlayerTalk] = function(mMsg)
		self.m_nNpcTalkId = mMsg:readInt()
		self.m_strNpcTalkMsg = mMsg:readString()
		--print("///////////////////cNotifyPlayerTalk////////////////////", self.m_nNpcTalkId, self.m_strNpcTalkMsg);
		self:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL,str="panel_playertalk"})
	end,

	[GameMessageID.cNotifyPushLuaTable] = function(mMsg)
		local ttype=mMsg:readString()
		local tflag=mMsg:readInt()
		local tdata=""
		if tflag > 0 then
			tdata=mMsg:readStringByZip(tflag)
			-- print("==================：",tdata)
		else
			tdata=mMsg:readString()
			-- print(tdata)
		end
		local result=GameUtilSenior.decode(tdata)
		if ttype == "npc_echo" then
			-- local pixesGhost = GUIPixesObject.getPixesGhost(result.id)
			-- GUIPixesObject.addTypewritter(pixesGhost,result.talk_str)
			-- print("///////////////////////npc_echo///////////////////////", tdata)
			self.m_nNpcTalkId = result.id
			self:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL,str = "panel_playertalk",result = result})
			GameCCBridge.doSdkEventReport ("npc_talk","npcName",result.talk_str.resData.talkTitle)
		elseif ttype == "npc_map_list" then
			self.m_nNpcTalkId = result.id
			self:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL,str = "container_npc_maplist",result = result})
			GameCCBridge.doSdkEventReport ("npc_talk","npcName",result.mapList.resData.talkTitle)
		elseif ttype == "npc_map_v9" then
			self.m_nNpcTalkId = result.id
			self:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL,str = "npc_map_v9",result = result})
			GameCCBridge.doSdkEventReport ("npc_talk","npcName",result.mapInfo.resData.talkTitle)
		elseif ttype == "npc_map_v11" then
			self.m_nNpcTalkId = result.id
			self:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL,str = "npc_map_v11",result = result})	
			GameCCBridge.doSdkEventReport ("npc_talk","npcName",result.talkInfo.resData.talkTitle)		
		elseif ttype == "dissolveGroup" then
			self:LeaveGroup()
		elseif ttype == "item_param" then
			self:dispatchEvent({name = GameMessageCode.EVENT_ITEM_TIME, param_id = result.param_id})
		elseif ttype == "guide" then
			-- if GameBaseLogic.isNewFunc then
			-- 	self.guideTab[1]=result.lv
			-- else
				self:dispatchEvent({name = GameMessageCode.EVENT_SHOW_GUIDE, lv = result.lv})
			-- end
		elseif ttype == "endGuide" then
			self:dispatchEvent({name = GameMessageCode.EVENT_END_GUIDE, lv = result.lv})
		elseif ttype == "fakeShowItem" then
			self:dispatchEvent({name=GameMessageCode.EVENT_BETTER_ITEM, mTypeID = result.mTypeID})
		elseif ttype == "taskChange" then -- 特殊处理左侧任务栏
			local param={}
			param.mTaskID = result.mTaskID
			param.mFlags = result.mFlags
			param.mState = result.mState
			param.mParam_1 = result.mParam_4
			param.mParam_2 = result.mParam_4
			param.mParam_3 = result.mParam_4
			param.mParam_4 = result.mParam_4
			param.mName = result.mName
			param.mInfo = result.mShortDesp
			self.mTasks[param.mTaskID]=param

			self:dispatchEvent({name=GameMessageCode.EVENT_TASK_CHANGE,cur_id = param.mTaskID})
		elseif ttype == "startAutoFight" then
			print("startAutoFight 1")
			--if MainRole then
				--print("startAutoFight 2")
				GameCharacter.startAutoFight()
			--end
		elseif ttype == "stopWaiteForRandom" then
			GameCharacter.waiteForRandom = false
		elseif ttype == "stopAutoFight" then
			if MainRole then 
				GameCharacter.stopAutoFight() 
			end
		elseif ttype == "showFly" then
			self:dispatchEvent({name = GameMessageCode.EVENT_SHOW_FLY, info = result.flyInfo})
		elseif ttype == "hideFly" then
			self:dispatchEvent({name = GameMessageCode.EVENT_SHOW_FLY})
		elseif ttype == "funcPreview" then
			self.mFuncPreview = {visible = result.visible, data = result}
			self:dispatchEvent({name = GameMessageCode.EVENT_HANDLE_FUNC_PREVIEW, visible = result.visible, data = result})
		elseif ttype == "showTaskTips" then
			self:dispatchEvent({name = GameMessageCode.EVENT_SHOW_TASK_TIPS, tips = result.tips})
		elseif ttype == "alert" then
			local param = {}
			table.merge(param, result)
			param.name = GameMessageCode.EVENT_PANEL_ON_ALERT
			param.confirmCallBack = function (num)
				self:PushLuaTable(result.path,GameUtilSenior.encode({actionid = result.actionid, param = result.param,args=num}))
			end
			param.cancelCallBack = function ()
				self:PushLuaTable(result.path,GameUtilSenior.encode({actionid = result.cancelid, param = result.param}))
			end
			self:dispatchEvent(param)
		elseif ttype =="tip_guild" then
			self.tipsMsg["tip_guild"] = self.tipsMsg["tip_guild"]  or {}
			table.insert(self.tipsMsg["tip_guild"],"tip_guild")
			self:dispatchEvent({name = GameMessageCode.EVENT_SHOW_BOTTOM,str="tip_guild"})--申请加入	
		elseif ttype == "tipsMsg" then
			self.tipsMsg[result.tipType] = self.tipsMsg[result.tipType]  or {}
			if result.visible then
				if result.tipId then
					if not table.indexof(self.tipsMsg[result.tipType], result.tipId) then
						table.insert(self.tipsMsg[result.tipType], result.tipId)
					end
				elseif not table.indexof(self.tipsMsg[result.tipType], result.tipType) then
					table.insert(self.tipsMsg[result.tipType], result.tipType)
				end
			else
				self.tipsMsg[result.tipType] = {}
			end
			self:dispatchEvent({name = GameMessageCode.EVENT_SHOW_BOTTOM, str=result.tipType})
		elseif ttype =="open" then
			if result.id~=nil then
				self.m_nNpcTalkId = result.id
			end
			self:dispatchEvent({name=GameMessageCode.EVENT_OPEN_PANEL,str=result.name, tab = result.tab, mParam = result.extend, from = result.from})
		elseif ttype == "openHuoDong" then
			--打开活动界面
			GUILeftHuoDongAnNiu.show(result.extend)
		elseif ttype == "closeHuoDong" then
			--关闭活动界面
			GUILeftHuoDongAnNiu.close()
		elseif ttype =="openTips" then
			if result.name == "confirm" then
				local param = {
					name = GameMessageCode.EVENT_SHOW_TIPS, str = result.name, lblConfirm = result.lblConfirm, 
					btnConfirm = result.confirmTitle, btnCancel = result.cancelTitle,
					confirmCallBack = function ()
						GameSocket:PushLuaTable(result.svrPath, GameUtilSenior.encode({actionid = result.confirmAction}))
					end,
					cancelCallBack = function ()
						GameSocket:PushLuaTable(result.svrPath, GameUtilSenior.encode({actionid = result.cancelAction}))
					end,
				}
				self:dispatchEvent(param)
			else
				self:dispatchEvent({
					name = GameMessageCode.EVENT_SHOW_TIPS, str = result.name, param = result
				})
			end
		elseif ttype =="closeTips" then
			self:dispatchEvent({
				name = GameMessageCode.EVENT_HIDE_TIPS, str = result.name, param = result
			})
		elseif ttype =="lockExtendBtns" then
			self:dispatchEvent({name = GameMessageCode.EVENT_EXTEND_VISIBLE,visible = result.visible,lock = result.lock or "unlock"})
		elseif ttype == "extendVisible" then
			self:dispatchEvent({name = GameMessageCode.EVENT_EXTEND_VISIBLE,visible = result.visible})
		elseif ttype =="close" then
			self:dispatchEvent({name=GameMessageCode.EVENT_CLOSE_PANEL,str=result.name})
		elseif ttype =="ChangeSkillCD" then
			for _,v in ipairs(self.m_skillsDesp) do
				if tonumber(v.skill_id) == tonumber(result.skilID) then
					v.mSKillCD = v.mSKillCD+tonumber(result.change)
					v.mPublicCD = v.mPublicCD+tonumber(result.change)
					if v.mSKillCD<0 then
						v.mSKillCD=0
					end
					if v.mPublicCD<0 then
						v.mPublicCD=0
					end
				end
			end
		elseif ttype == "newfunc" then -- 新功能开启
			if result.func and result.mType then
				if not self.m_func[result.mType] then self.m_func[result.mType] = {} end
				if not self.m_func[result.mType][result.func] then 
					self.m_func[result.mType][result.func] = 1
					if result.mType == "menu" then
						self.menuChange = true
					end

					if GameBaseLogic.guiding then
						self.guideTab[1]=tdata
					else
						self:dispatchEvent({name = GameMessageCode.EVENT_OPEN_NEWFUNC, data = tdata})
					end
				end
			end
		elseif ttype == "autoCast" then
			self.NetAutoSkills = {}
			if tdata and tdata ~= "" then
				self.NetAutoSkills = GameUtilSenior.decode(tdata)
			end
		elseif ttype == "switchAutoCast" then
			self.NetAutoSkills = self.NetAutoSkills or {}
			if result.state and not table.indexof(self.NetAutoSkills, result.skillType) then
				table.insert(self.NetAutoSkills, result.skillType)
				self:dispatchEvent({name = GameMessageCode.EVENT_SWITCH_AUTO_SKILL, skillType = result.skillType, state = result.state})
			elseif not result.state and table.indexof(self.NetAutoSkills, result.skillType) then
				table.removebyvalue(self.NetAutoSkills, result.skillType)
				self:dispatchEvent({name = GameMessageCode.EVENT_SWITCH_AUTO_SKILL, skillType = result.skillType, state = result.state})
			end
		elseif ttype == "allGuiButtons" then
			self.mAllFuncs = {}
			for i,v in ipairs(result.allFuncs) do
				self.mAllFuncs[v.funcid] = v
			end
			
			self.mExtendButtons = result.extend
			self.mBasicButtons = {}
			local param = {}
			if self.mAllFuncs then
				for k,v in pairs(self.mAllFuncs) do
					if not self.mBasicButtons[v.funcKey] then
						print(GameUtilSenior.encode(v))
						self.mBasicButtons[v.funcKey] = v
					elseif self.mBasicButtons[v.funcKey].level > v.level then
						self.mBasicButtons[v.funcKey] = v
					end
				end
			end

			if result.basic then
				self.mBasicButtons = result.basic
			end
			self:dispatchEvent({name = GameMessageCode.EVENT_GUI_BUTTON})
		elseif ttype == "showFun" then
			local param ={
				name = GameMessageCode.EVENT_SHOW_TIPS,
				str = "funOpen",
				openpanel = result.name,
				funName = result.funName,
				icon = result.showicon
			}
			self:dispatchEvent(param)
		elseif ttype == "allfunc" then 
			self.m_func = result.allfunc
		elseif ttype == "showGestureGuide" then
			self:dispatchEvent({name = GameMessageCode.EVENT_SHOW_GESTURE_GUIDE, slideIn = result.slideIn})
		elseif ttype == "removeGestureGuide" then
			self:dispatchEvent({name = GameMessageCode.EVENT_REMOVE_GESTURE_GUIDE, slideGuide = result.slideGuide})
		elseif ttype == "switchUIMode" then
			self:dispatchEvent({name = GameMessageCode.EVENT_SWITCH_UI_MODE, mode = result.simple and GameConst.UI_SIMPLIFIED or GameConst.UI_COMPLETE})
		elseif ttype == "redPoint" then
			if result.visible then
				self:dispatchEvent({name = GameMessageCode.EVENT_SHOW_REDPOINT, lv = result.lv,index = result.index})
			else
				self:dispatchEvent({name = GameMessageCode.EVENT_REMOVE_REDPOINT, lv = result.lv,index = result.index})
			end
		elseif ttype == "showConfirm" or ttype=="showAlert" then
			if PLATFORM_BANSHU and result.callFunc=="server.showChongzhi" then
				result.callFunc = ""
				result.labelConfirm = "确定"
			end
			local param = {
				name = GameMessageCode.EVENT_SHOW_TIPS, str = ttype == "showConfirm" and "confirm" or "alert", lblConfirm = result.str, btnConfirm = result.labelConfirm,btnCancel = result.labelCancel,
				checkBox = result.checkBox,
				confirmCallBack = function ()
					self:PushLuaTable(result.callFunc,result.book)
				end
			}
			self:dispatchEvent(param)
		elseif ttype == "showBottomMsg" then
			if result.str == "tip_king" or result.str =="tip_activity" then
				if not GameUtilSenior.isTable(self.tipsMsg[result.str]) then self.tipsMsg[result.str] = {} end
				if result.hide then
					self.tipsMsg[result.str] = {}
				else
					table.insert(self.tipsMsg[result.str],1,result)
				end
				self:dispatchEvent({name = GameMessageCode.EVENT_SHOW_BOTTOM,str = result.str})
			end
		elseif ttype == "callFriendIntime" then
			self.lastCallFriendTime = os.time()
		elseif ttype == "callFriend" then
			local param = {name = GameMessageCode.EVENT_SHOW_TIPS, str = "gotCallFriend", playerName = result.friendName}
			self:dispatchEvent(param)
		-- elseif ttype == "flyTips" then -- 传送提示
		-- 	local touchLink = result.link
		-- 	local param = {
		-- 		name = GameMessageCode.EVENT_PANEL_ON_ALERT, panel = "hint", visible = true, lblAlert1 = GameConst.str_warm_prompt , 
		-- 		alertTitle = GameConst.str_transfer_now,
		-- 		lblAlert2 =GameConst.str_transfer_tips1,
		-- 		timer = 5,
		-- 		alertCallBack = function ()
		-- 			GameUtilSenior.litenerTaskLink(touchLink)
		-- 			-- self:PushLuaTable(path, GameUtilSenior.encode({ actionid = actionid, param = {flytarget} }))
		-- 		end
		-- 	}
		-- 	self:dispatchEvent(param)
		elseif ttype == "clearTradeRecord" then
			self.mTradeLocalRecord = {}
			self:storeTradeRecord(tdata)
		elseif ttype == "ItemDailyLimitSingle" then
			if result.data then
				for i,v in ipairs(result.data) do
					self.itemDailyUseLimit[v.id] = v
					self:dispatchEvent({name = GameMessageCode.EVENT_ITEM_USELIMIT_CHANGE, typeId = v.id})
				end
				self:checkBagRedDot()
			end
		elseif ttype == "ItemDailyLimit" then
			if result.data then
				self.itemDailyUseLimit = {}
				-- print("////////////////////ItemDailyLimit/////////////////////////")
				for k,v in pairs(result.data) do
					-- print("////////////////////data/////////////////////////", v.id, v.leftTimes, v.totalTimes)
					self.itemDailyUseLimit[v.id] = v
				end
				self:checkBagRedDot()
			end
			-- for k,v in pairs(self.itemDailyUseLimit) do
			-- 	print(k,GameUtilSenior.encode(v))
			-- end
			-- local nameSprite = GUIPixesObject.getPixesGhost(GameBaseLogic.GetMainRole():NetAttr(GameConst.net_id)):getNameSprite()
			-- local mNameLabel = nameSprite:getChildByName("mNameLabel")
			-- if result.team_id ~= nil then
			-- 	local nameColor = cc.c4f(255, 0, 0, 255)
			-- 	if result.team_id == 2 then
			-- 		nameColor = cc.c4f(0, 0, 255, 255)
			-- 	end
			-- 	mNameLabel:setTextColor(nameColor)
			-- 	mNameLabel:setString(result.team_label..GameBaseLogic.chrName)
			-- elseif result.clearFlag then
			-- 	mNameLabel:setTextColor(cc.c4f(255, 255, 255, 255))
			-- 	mNameLabel:setString(GameBaseLogic.chrName)
			-- end
			-- GameUtilSenior.updateNamePos(nameSprite)
		elseif ttype == "clearExploitAward" then
			-- self:storeTradeRecord(tdata)
			GameCharacter._mainAvatar = GameCharacter._mainAvatar or CCGhostManager:getMainAvatar()
			if GameCharacter._mainAvatar then
				local charName = GameCharacter._mainAvatar:NetAttr(GameConst.net_name) or ""
				GameSetting.setInfos(charName, {}, "GongXunOpenAward")
				GameSetting.save("GongXunOpenAward")
			end
		elseif ttype == "KHcandidate" then--皇城战
			if not GameBaseLogic.GetMainRole() then return end
			if self.KHcandidate ~= result.KHcandidate then
				self.KHcandidate = result.KHcandidate
				local srcid = GameBaseLogic.GetMainRole():NetAttr(GameConst.net_id)
				local nameSprite = GUIPixesObject.getPixesGhost(srcid):getNameSprite()
				show_player_title(srcid, nameSprite)
				for i, v in ipairs(NetCC:getNearGhost(GameConst.GHOST_PLAYER, true)) do
					local player = CCGhostManager:getPixesGhostByID(v)
					if player then
						local nameSprite = GUIPixesObject.getPixesGhost(v):getNameSprite()
						if nameSprite then
							show_player_title(v, nameSprite)
						end
					end
				end				
			end
			GameUtilSenior.updateNamePos(nameSprite)
		-- elseif ttype == "blackBoard" then
		-- 	self:dispatchEvent({name = GameMessageCode.EVENT_BLACK_BOARD, type=ttype, data=tdata})
		-- elseif ttype == "activity" then
		-- 	self.tipsMsg["tip_activity"] = self.tipsMsg["tip_activity"] or {}
		-- 	table.insert(self.tipsMsg["tip_activity"], result)
		-- 	self:dispatchEvent({name = GameMessageCode.EVENT_SHOW_BOTTOM,str="tip_activity"})
		-- 	if GUIMain.InfoPart then--持续时间过了如果还没有点 则把这条消息删掉
		-- 		GUIMain.InfoPart:runAction(cca.seq({cca.delay(result.duration), cca.callFunc(function ()
		-- 			for i,v in ipairs(self.tipsMsg["tip_activity"]) do
		-- 				if v.msg == result.msg then
		-- 					table.remove(self.tipsMsg["tip_activity"], i)
		-- 					self:dispatchEvent({name = GameMessageCode.EVENT_SHOW_BOTTOM,str="tip_activity"})
		-- 					break
		-- 				end
		-- 			end
		-- 		end)}))
		-- 	end
		elseif ttype == "stopTask" then -- 服务端通知客户端停止任务()
			self:dispatchEvent({name = GameMessageCode.EVENT_CONTINUE_TASK}) 	
		elseif ttype == "continueTask" then -- 服务端通知客户端继续任务
			self:dispatchEvent({name = GameMessageCode.EVENT_CONTINUE_TASK}) 		
		elseif ttype == "effect_one" then
			self:dispatchEvent({name = GameMessageCode.EVENT_SHOW_TASK_ANIM,effect_type=result.effect_type})
		elseif ttype == "talk_npc" then
			self:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = "panel_npctalk",talk_tab = result} )
			GameCCBridge.doSdkEventReport ("npc_talk","npcName",result.title.str)
		elseif ttype == "fresh_npc" then
			self:dispatchEvent({name = GameMessageCode.EVENT_FRESH_NPC,talk_tab = result} )
		elseif ttype == "add_status" then
			self:dispatchEvent({name = GameMessageCode.EVENT_BUFF_GOT_ANIMATION, buff_id = result.buff_id,buff_level = result.buff_level})
		-- elseif ttype == "ChooseCard" then
		-- 	self:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL,str ="panel_card",award = result.award,baseAward = result.baseAward,choose = result.choose,actionId = result.actionId})
		-- elseif ttype == "check_equip" then
		-- 	self:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL,str="panel_check_equip", pName = result.name})
		-- elseif ttype == "storyline" then

		-- 	self:dispatchEvent({name = GameMessageCode.EVENT_SHOW_STORY_LINE, lv = result.lv, callback = function ()
		-- 		self:PushLuaTable(result.path, GameUtilSenior.encode({actionid = result.actionid, param = result.param}))
		-- 	end})
		-- elseif ttype == "runstory" then
			
		-- elseif ttype == "showdbqb" then
		-- 	self:dispatchEvent({name = GameMessageCode.EVENT_PANEL_ON_ALERT, panel="DbqbTip", dbqbdata=result.dbqbdata})
		elseif ttype == "activityOpen" then--活动开启提示
			if not GameUtilSenior.isTable(self.tipsMsg["tip_activity"]) then self.tipsMsg["tip_activity"] = {} end
			table.insert(self.tipsMsg["tip_activity"],1,result)
			self:dispatchEvent({name = GameMessageCode.EVENT_SHOW_BOTTOM,str = "tip_activity"})
		elseif ttype == "dieRecord" then
			local dieRecord = result.data;
			-- for k,v in pairs(dieRecord) do
			-- 	print("die--------------------",k,v)
			-- end
			local dieRecords = GameSetting.getInfos(dieRecord.name,"DieRecords") or {}
			table.insert(dieRecords,dieRecord)
			if #dieRecords>20 then
				table.remove(dieRecords,1)
			end
			GameSetting.setInfos(dieRecord.name, dieRecords, "DieRecords")
			GameSetting.save("DieRecords")
			-- print("···",#GameSetting.getInfos(dieRecord.name,"DieRecords"))
		elseif ttype == "showRefreshBoss" then
			self:dispatchEvent({name = GameMessageCode.EVENT_REFRESH_BOSS, info = result})
		elseif ttype == "playcz" then  --播放充值成功动画
			if result.actionid == "playcz" then
				-- local animate = cc.AnimManager:getInstance():getPlistAnimateAsync(parent,4,result.resid,4,1)--成就达成
				--GameUtilSenior.addEffect(GUIMain.m_GDivContainer:getEffectPanel(),"chongzhi",4,result.resid)
			end
		elseif ttype == "bossshow" then  --显示地图boss
			GUILeftCenter.setBossNum(result.m)
		elseif ttype == "bossnum" then  --显示地图boss
			GUILeftCenter.setBossNum(result.m)
		elseif ttype == "chongzhiResult" then  --充值结果
			GameCCBridge.doSdkChongZhiResult (result.money,result.vcoin)
		elseif ttype == "payResult" then  --充值结果
			GameCCBridge.doSdkPayResult (result.reason,result.vcoin+result.bvcoin)
		else
			if ttype == "equippreview" then
				self.previewData = result
			end

			if ttype == "hidePersonBoss" then
				self.PersonBossData = tdata
			end
			if PLATFORM_TEST then
				print("cNotifyPushLuaTable:",type)
			end
			self:dispatchEvent({name = GameMessageCode.EVENT_PUSH_PANEL_DATA, type=ttype, data=tdata})
		end
	end,

	[GameMessageID.cNotifyGameParam] = function(mMsg)
		local param={}
		-- param.mSteelEquipCostBase = mMsg:readInt()
		-- param.mSteelEquipCostMul = mMsg:readInt()
		param.mMaxMagicAnti = mMsg:readInt()
		param.mWalkSpeedWarriorClientParam = mMsg:readInt()
		param.mStandRelivePrice = mMsg:readInt()
		param.mChartOpenLimitLevel = mMsg:readInt()
		param.mAddDepotPrice = mMsg:readInt()
		-- param.mExchangeUpdProbBase = mMsg:readInt()
		-- param.mExchangeUpdProbGap = mMsg:readInt()
		-- param.mExchangeUpdDropMax = mMsg:readInt()
		-- param.mExchangeUpdCostGM = mMsg:readInt()
		-- param.mExchangeUpdCostBV = mMsg:readInt()
		-- param.mStatusQiseshendanAC = mMsg:readInt()
		-- param.mStatusQiseshendanACMax = mMsg:readInt()
		-- param.mStatusQiseshendanMAC = mMsg:readInt()
		-- param.mStatusQiseshendanMACMax = mMsg:readInt()
		-- param.mStatusQiseshendanDC = mMsg:readInt()
		-- param.mStatusQiseshendanDCMax = mMsg:readInt()
		-- param.mStatusQiseshendanMC = mMsg:readInt()
		-- param.mStatusQiseshendanMCMax = mMsg:readInt()
		-- param.mStatusQiseshendanSC = mMsg:readInt()
		-- param.mStatusQiseshendanSCMax = mMsg:readInt()
		-- param.mStatusQiseshendanHpmaxBase = mMsg:readInt()
		-- param.mStatusQiseshendanHpmaxGap = mMsg:readInt()
		-- param.mStatusQiseshendanMpmaxBase = mMsg:readInt()
		-- param.mStatusQiseshendanMpmaxGap = mMsg:readInt()
		-- param.mStatusYuanshenhutiAC = mMsg:readInt()
		-- param.mStatusYuanshenhutiACMax = mMsg:readInt()
		-- param.mStatusYuanshenhutiMAC = mMsg:readInt()
		-- param.mStatusYuanshenhutiMACMax = mMsg:readInt()
		-- param.mStatusYuanshenhutiDC = mMsg:readInt()
		-- param.mStatusYuanshenhutiDCMax = mMsg:readInt()
		-- param.mStatusYuanshenhutiMC = mMsg:readInt()
		-- param.mStatusYuanshenhutiMCMax = mMsg:readInt()
		-- param.mStatusYuanshenhutiSC = mMsg:readInt()
		-- param.mStatusYuanshenhutiSCMax = mMsg:readInt()
		-- param.mStatusTianshenhutiMAXHP = mMsg:readInt()
	 --    param.mStatusTianshenhutiDC = mMsg:readInt()
	 --    param.mStatusTianshenhutiDCMax = mMsg:readInt()
	 --    param.mStatusTianshenhutiMC = mMsg:readInt()
	 --    param.mStatusTianshenhutiMCMax = mMsg:readInt()
	 --    param.mStatusTianshenhutiSC = mMsg:readInt()
	 --    param.mStatusTianshenhutiSCMax = mMsg:readInt()
	 --    param.mStatusTianshenhutiSubDamageProb = mMsg:readInt()
	 --    param.mStatusTianshenhutiSubDamagePres = mMsg:readInt()
		-- param.mStatusBaqihutiAC = mMsg:readInt()
		-- param.mStatusBaqihutiACMax = mMsg:readInt()
		-- param.mStatusBaqihutiMAC = mMsg:readInt()
		-- param.mStatusBaqihutiMACMax = mMsg:readInt()
		-- param.mStatusBaqihutiDC = mMsg:readInt()
		-- param.mStatusBaqihutiDCMax = mMsg:readInt()
		-- param.mStatusBaqihutiMC = mMsg:readInt()
		-- param.mStatusBaqihutiMCMax = mMsg:readInt()
		-- param.mStatusBaqihutiSC = mMsg:readInt()
		-- param.mStatusBaqihutiSCMax = mMsg:readInt()
		-- param.mDeleteExchangeUpdFromEquip = mMsg:readInt()
		param.mDieDropBagProb = mMsg:readInt()
		param.mDieDropLoadProb = mMsg:readInt()
		param.mProtectItemPrice = mMsg:readInt()
		param.mProtectItemProbMax = mMsg:readInt()
		param.mProtectItemProb = mMsg:readInt()
		param.mProtectItemAdd = mMsg:readInt()
		param.mPKConfirm = mMsg:readInt()
		-- param.mStatusFuQiTongXinAC = mMsg:readInt()
		-- param.mStatusFuQiTongXinACMax = mMsg:readInt()
		-- param.mStatusFuQiTongXinMAC = mMsg:readInt()
		-- param.mStatusFuQiTongXinMACMax = mMsg:readInt()
		param.mGuildMemberMax = mMsg:readInt()
		param.mTotalAttrLevelLimit = mMsg:readInt()
		-- param.mStatusVipDC = mMsg:readInt()
		-- param.mStatusVipDCMax = mMsg:readInt()
		-- param.mStatusVipMC = mMsg:readInt()
		-- param.mStatusVipMCMax = mMsg:readInt()
		-- param.mStatusVipSC = mMsg:readInt()
		-- param.mStatusVipSCMax = mMsg:readInt()
		-- param.mStatusVipAC = mMsg:readInt()
		-- param.mStatusVipACMax = mMsg:readInt()
		-- param.mStatusVipMAC = mMsg:readInt()
		-- param.mStatusVipMACMax = mMsg:readInt()
		self.mGameParam = param
	end,

	[GameMessageID.cNotifyListChargeDart] = function(mMsg)
		local num = mMsg:readInt()
		local result = {}
		for i = 1, num do

			local param = {}
			param.charName = mMsg:readString()
			param.icon = mMsg:readInt()
			param.remainTime = mMsg:readInt()
			param.duration = mMsg:readInt()
			param.fightForce = mMsg:readInt()
			param.stolenTimes = mMsg:readInt()
			param.totalAwards = mMsg:readInt()
			param.remainAward = mMsg:readInt()
			param.state = mMsg:readInt()
			param.robName = mMsg:readString()


			local robname = string.split(param.robName,",")[param.stolenTimes+1]
			if GameBaseLogic.GetMainRole() then
				if param.robName and string.len(param.robName) > 0 and param.charName and GameBaseLogic.GetMainRole():NetAttr(GameConst.net_name)== param.charName and not(self.mFriends[robname] and self.mFriends[robname].title == 50) then
					if not string.find(param.robName, GameBaseLogic.GetMainRole():NetAttr(GameConst.net_name)) then
						if not self.stolenTimes then self.stolenTimes = 0 end
						if self.stolenTimes ~= param.stolenTimes then
							self.stolenTimes = param.stolenTimes

							if not self.tipsMsg["tip_car_robbed"] then self.tipsMsg["tip_car_robbed"] = {} end
							local param = {
								name = string.split(param.robName,",")[param.stolenTimes+1],
								robMoney = (param.totalAwards - param.remainAward)/param.stolenTimes
							}
							table.insert(self.tipsMsg["tip_car_robbed"], param)
							self:dispatchEvent({name = GameMessageCode.EVENT_SHOW_BOTTOM, str = "tip_car_robbed"})
						end
					end
				end
			end

			-- if self.dartcarState ~= param.state and param.state == 1 then--完成
			-- 	if not self.tipsMsg["tip_car_achieved"] then
			-- 		self.tipsMsg["tip_car_achieved"] = {}
			-- 	end
			-- 	table.insert(self.tipsMsg["tip_car_achieved"], {name = param.charName})
			-- 	self:dispatchEvent({name = GameMessageCode.EVENT_SHOW_BOTTOM, str = "tip_car_achieved"})
			-- end
			self.dartcarState = param.state

			table.insert(result, param)
		end

		self:dispatchEvent({name = GameMessageCode.EVENT_PUSH_DART_DATA, data=result})
	end,

	[GameMessageID.cResListGuildDepot] = function(mMsg)
		local size = mMsg:readInt()
		local result = {}
		for i = 1, size do
			local param = {}
			param.pos = mMsg:readInt()
			param.typeID = mMsg:readInt()
			param.level = mMsg:readInt()
			param.zlevel = mMsg:readInt()
			param.price = mMsg:readInt()
			param.job = mMsg:readInt()
			table.insert(result, param)
		end
		self:dispatchEvent({name = GameMessageCode.EVENT_GUILD_REPERTORY, data = result})
		-- print("//////////cResListGuildDepot//////////", GameUtilSenior.encode(result))
	end,

	[GameMessageID.cResGetMails] = function(mMsg)
		local mailCount = mMsg:readInt()
		local need2SelectFirst = false
		if #self.mails == 0 then
			need2SelectFirst = true
		end
		self.mails = {}
		self.tipsMsg["tip_mail"] = {}
		for i = 1, mailCount do
			local singleMail = {}
			singleMail.id = mMsg:readString()
			singleMail.title = mMsg:readString()
			singleMail.content = mMsg:readString()
			singleMail.date = mMsg:readInt()
			singleMail.isOpen = mMsg:readInt()--0是没有读过
			singleMail.isReceive = mMsg:readInt()--0是没有领
			singleMail.itemCount = mMsg:readInt()
			singleMail.item = {}

			for j = 1, singleMail.itemCount do
				local itemInfo = {
					id		= mMsg:readInt(),
					count	= mMsg:readInt(),
				}
				table.insert(singleMail.item, itemInfo)
			end
			table.insert(self.mails, 1, singleMail)

			if GameUtilSenior.checkMailPriority(singleMail) == 1 then
				if self.mailCount ~= mailCount and self.mailCount ~=nil  then----
					table.insert(self.tipsMsg["tip_mail"], singleMail.id)
				end
			end
			
		end
		
		-- self:dispatchEvent({name = #self.tipsMsg["tip_mail"] > 0 and GameMessageCode.EVENT_SHOW_REDPOINT or GameMessageCode.EVENT_REMOVE_REDPOINT, lv = 8,index = 1})
		
		local function sortF(a, b)--有红点的往前
			-- return GameUtilSenior.checkMailPriority(a) > GameUtilSenior.checkMailPriority(b)
			if a.isOpen == b.isOpen then
				if a.isReceive==b.isReceive then
					return a.date >b.date
				else
					return a.isReceive<b.isReceive
				end
			else
				return a.isOpen<b.isOpen
			end
		end
		table.sort(self.mails, sortF)
		
		self:dispatchEvent({name = GameMessageCode.EVENT_GET_MAILS, need2SelectFirst = need2SelectFirst})
		--print(self.mailCount, mailCount,"=========")
		if self.mailCount ~= mailCount then----
			if  self.mailCount ~=nil then 
				--print("999999999999999")
				self:dispatchEvent({name = GameMessageCode.EVENT_SHOW_BOTTOM, str = "tip_mail"})
			end  	
		end

		self.mailCount = mailCount

		-- if #self.tipsMsg["tip_mail"] >0 then
			
		-- end

		self:checkMailRedPoint()-----主面板红点
		self:dispatchEvent({name = GameMessageCode.EVENT_CHECK_MAIL_FULL})
	end,

	[GameMessageID.cNotifyMailNum] = function(mMsg)
		local num = mMsg:readInt()
		self:getMails()
	end,

	[GameMessageID.cNotifyMailReceiveSuccess] = function(mMsg)
		local id = mMsg:readString()
		-- self:getMails()
		for k,v in pairs(self.mails) do
			if v.id == id then
				v.isReceive = 1
			end
		end
		-- self:deleteMail(id)
		self:dispatchEvent({name = GameMessageCode.EVENT_GET_MAILS})
		self:checkMailRedPoint()-----主面板红点
	end,

	-- [GameMessageID.cNotifyQiangHuaAllValue] = function(mMsg)
	-- 	local result = {}
	-- 	result.acMin=mMsg:readInt()
	-- 	result.acMax=mMsg:readInt()
	-- 	result.mcMin=mMsg:readInt()
	-- 	result.mcMax=mMsg:readInt()
	-- 	result.scMin=mMsg:readInt()
	-- 	result.scMax=mMsg:readInt()
	-- 	result.defMin=mMsg:readInt()
	-- 	result.defMax=mMsg:readInt()
	-- 	result.mdefMin=mMsg:readInt()
	-- 	result.mdefMax=mMsg:readInt()
	-- 	result.hp=mMsg:readInt()
	-- 	result.mp=mMsg:readInt()
	-- 	result.monHurt=mMsg:readInt()
	-- 	result.countLev=mMsg:readInt()
	-- 	self:dispatchEvent({name = GameMessageCode.EVENT_QIANGHUA_CHANGE_VALUE, data = result})
	-- end,

	-- [GameMessageID.cNotifyQiangHuaEquip] = function(mMsg)
	-- 	local newItem = {}
	-- 	newItem.position=mMsg:readInt()
	-- 	newItem.acMin=mMsg:readInt()
	-- 	newItem.acMax=mMsg:readInt()
	-- 	newItem.mcMin=mMsg:readInt()
	-- 	newItem.mcMax=mMsg:readInt()
	-- 	newItem.scMin=mMsg:readInt()
	-- 	newItem.scMax=mMsg:readInt()
	-- 	newItem.defMin=mMsg:readInt()
	-- 	newItem.defMax=mMsg:readInt()
	-- 	newItem.mdefMin=mMsg:readInt()
	-- 	newItem.mdefMax=mMsg:readInt()
	-- 	newItem.hp=mMsg:readInt()
	-- 	newItem.mp=mMsg:readInt()
	-- 	newItem.addPer=mMsg:readInt()
	-- 	if newItem.position<0 then
	-- 		self.mEquipItems[newItem.position] = newItem
	-- 	end
	-- end,

	[GameMessageID.cResKuafuAuth] = function(mMsg)
		local result = mMsg:readInt()
		if result == 100 then
			self:EnterGame(self.kuaFuInfo.charname, GameBaseLogic.seedName)
		end
	end,

	[GameMessageID.cNotifyKuafuInfo] = function(mMsg)
		self.kuaFuInfo = {}
		self.kuaFuInfo.ticket			= mMsg:readString()
		self.kuaFuInfo.loginid			= mMsg:readString()
		self.kuaFuInfo.charname			= mMsg:readString()
		self.kuaFuInfo.kuafuip			= mMsg:readString()
		self.kuaFuInfo.kuafuport		= mMsg:readString()
		self.kuaFuInfo.kuafuparam		= mMsg:readString()
		self.kuaFuInfo.ticketseed		= mMsg:readInt()
		self.kuaFuInfo.localip			= mMsg:readString()
		self.kuaFuInfo.localport		= mMsg:readString()
		self.kuaFuInfo.localPTID		= mMsg:readString()
		self.kuaFuInfo.localServerID	= mMsg:readString()
		self.kuaFuInfo.localArea		= mMsg:readString()

		self.kuaFuState = true
		display.replaceScene(GPageAcrossServer.new())
	end,

	[GameMessageID.cNotifyKuafuEnterMainServer] = function(mMsg)
		local result = {}
		result.ticket = mMsg:readString();
		result.result = mMsg:readString();
		self:dispatchEvent({name = GameMessageCode.EVENT_KUAFU_ENTER_MAIN_SERVER, data = result})
	end,

	[GameMessageID.cResConsignItem] = function (mMsg)
		local ret = mMsg:readInt();
		-- -1:无此物品 0:成功 1:手续费不够 2:绑定物品不可寄售
		self:dispatchEvent({name = GameMessageCode.EVENT_CONSIGN_RESULT, ret = ret})
	end,

	[GameMessageID.cResGetConsignableItems] = function (mMsg)
		local param = {}
		param.mType = mMsg:readInt()
		-- param.endIndex = mMsg:readInt()
		param.job = mMsg:readInt()
		param.condition = mMsg:readInt()
		param.count = mMsg:readInt()
		param.items = {}
		for i=1, param.count do
			local ci={}
			ci.mSeedId = mMsg:readInt()
			ci.mIndex = mMsg:readInt()
			ci.mPrice = mMsg:readInt()
			ci.mTimeLeft = mMsg:readInt()
			ci.mTypeID = mMsg:readInt()
			ci.mDuraMax = mMsg:readInt()
			ci.mDuration = mMsg:readInt()
			ci.mItemFlags = mMsg:readInt()
			ci.mLuck = mMsg:readShort()
			ci.mLevel = mMsg:readInt()
			ci.mNumber = mMsg:readInt()
			ci.mAddAC = mMsg:readShort()
			ci.mAddMAC = mMsg:readShort()
			ci.mAddDC = mMsg:readShort()
			ci.mAddMC = mMsg:readShort()
			ci.mAddSC = mMsg:readShort()
			ci.mAddHp = mMsg:readShort()
			ci.mAddMp = mMsg:readShort()
			ci.mUpdAC = mMsg:readShort()
			ci.mUpdMAC = mMsg:readShort()
			ci.mUpdDC = mMsg:readShort()
			ci.mUpdMC = mMsg:readShort()
			ci.mUpdSC = mMsg:readShort()
			ci.mProtect = mMsg:readShort()
			ci.mUpdMaxCount = mMsg:readInt()
			ci.mUpdFailedCount = mMsg:readInt()
			ci.mZLevel = mMsg:readInt()
			ci.mLock = mMsg:readInt()
			
			ci.mSpecialAC			= mMsg:readInt()
			ci.mSpecialACMax			= mMsg:readInt()
			ci.mSpecialMAC			= mMsg:readInt()
			ci.mSpecialMACMax			= mMsg:readInt()
			ci.mSpecialDC			= mMsg:readInt()
			ci.mSpecialDCMax			= mMsg:readInt()
			ci.mSpecialMC			= mMsg:readInt()
			ci.mSpecialMCMax			= mMsg:readInt()
			ci.mSpecialSC			= mMsg:readInt()
			ci.mSpecialSCMax			= mMsg:readInt()
			ci.mSpecialLuck			= mMsg:readInt()
			ci.mSpecialCurse			= mMsg:readInt()
			ci.mSpecialAccuracy			= mMsg:readInt()
			ci.mSpecialDodge			= mMsg:readInt()
			ci.mSpecialAntiMagic			= mMsg:readInt()
			ci.mSpecialAntiPoison			= mMsg:readInt()
			ci.mSpecialMax_hp			= mMsg:readInt()
			ci.mSpecialMax_mp			= mMsg:readInt()
			ci.mSpecialMax_hp_pres			= mMsg:readInt()
			ci.mSpecialMax_mp_pres			= mMsg:readInt()
			ci.mSpecialHolyDam			= mMsg:readInt()
			ci.mSpecialXishou_prob			= mMsg:readInt()
			ci.mSpecialXishou_pres			= mMsg:readInt()
			ci.mSpecialFantan_prob			= mMsg:readInt()
			ci.mSpecialFantan_pres			= mMsg:readInt()
			ci.mSpecialBaoji_prob			= mMsg:readInt()
			ci.mSpecialBaoji_pres			= mMsg:readInt()
			ci.mSpecialXixue_prob			= mMsg:readInt()
			ci.mSpecialXixue_pres			= mMsg:readInt()
			ci.mSpecialMabi_prob			= mMsg:readInt()
			ci.mSpecialMabi_dura			= mMsg:readInt()
			ci.mSpecialDixiao_pres			= mMsg:readInt()
			ci.mSpecialFuyuan_cd			= mMsg:readInt()
			ci.mSpecialFuyuan_pres			= mMsg:readInt()
			ci.mSpecialBeiShang			= mMsg:readInt()
			ci.mSpecialMianShang			= mMsg:readInt()
			ci.mSpecialACRatio			= mMsg:readInt()
			ci.mSpecialMCRatio			= mMsg:readInt()
			ci.mSpecialDCRatio			= mMsg:readInt()
			ci.mSpecialIgnoreDCRatio			= mMsg:readInt()
			ci.mSpecialPlayDrop			= mMsg:readInt()
			ci.mSpecialMonsterDrop			= mMsg:readInt()
			ci.mSpecialDropProtect			= mMsg:readInt()
			ci.mSpecialMabiProtect			= mMsg:readInt()
			ci.mSpecialBingdong_prob			= mMsg:readInt()
			ci.mSpecialBingdong_dura			= mMsg:readInt()
			ci.mSpecialShidu_prob			= mMsg:readInt()
			ci.mSpecialShidu_dura			= mMsg:readInt()
			ci.mSpecialBingdongProtect			= mMsg:readInt()
			ci.mSpecialShiduProtect			= mMsg:readInt()
			ci.mSpecialAttackSpeed 			= mMsg:readInt()
			table.insert(param.items, ci)
		end
		-- print("////////", param.mType, param.job, param.condition, param.count, GameUtilSenior.encode(param.items))
		self:dispatchEvent({name = GameMessageCode.EVENT_CONSIGN_LIST, param = param})
	end,

	[GameMessageID.cResBuyConsignableItem] = function (mMsg)
		local ret = mMsg:readInt();
		local mSeedId = mMsg:readInt();
		-- ret: -1 不存在 1背包放不下 2钱不够 0成功
		if ret == -1 then
			self:alertLocalMsg("该物品不存在", "alert")
		elseif ret == 1 then
			self:alertLocalMsg("背包剩余控件不足", "alert")
		elseif ret == 2 then
			self:alertLocalMsg("费用不足", "alert")
		elseif ret == 3 then
			self:alertLocalMsg("充值金额不足500元，无法购买", "alert")
		elseif ret == 0 then
			self:alertLocalMsg("购买成功", "alert")
		end
		self:dispatchEvent({name = GameMessageCode.EVENT_CONSIGN_BUY_RESULT, ret = ret, mSeedId = mSeedId})
	end,

	[GameMessageID.cResTakeBackConsignableItem] = function (mMsg)
		local ret = mMsg:readInt();
		local mSeedId = mMsg:readInt();
		-- ret: -1 不存在 0成功
		self:dispatchEvent({name = GameMessageCode.EVENT_TAKE_CONSIGN_RESULT})
	end,

	[GameMessageID.cResTakeBackVCoin] = function (mMsg)
		local ret = mMsg:readInt();
		-- ret: 取回金币数量
		self:dispatchEvent({name = GameMessageCode.EVENT_TAKE_VCOIN_RESULT, ret = ret})
	end,

	[GameMessageID.cResGuildRedPacketLog] = function (mMsg)
		local count = mMsg:readInt()
		local logs = {}
		for i=1,count do
			local log = {}
			log.sender = mMsg:readString()
			log.opCode = mMsg:readInt()
			log.vcoin = mMsg:readInt()
			log.num = mMsg:readInt()
			table.insert(logs, log)
		end
		self:dispatchEvent({name = GameMessageCode.EVENT_GUILD_HONGBAO_LOGS, logs = logs})
	end,
	[GameMessageID.cNotifyGuildRedPacketLog] = function (mMsg)
		local log = {}
		log.sender = mMsg:readString()
		log.opCode = mMsg:readInt()
		log.vcoin = mMsg:readInt()
		log.num = mMsg:readInt()
		--print("cNotifyGuildRedPacketLog", GameUtilSenior.encode(log))
		self:dispatchEvent({name = GameMessageCode.EVENT_GUILD_HONGBAO_LOG, log = log})
	end,
	[GameMessageID.cResGuildItemLog] = function (mMsg)
		local count = mMsg:readInt()
		local logs = {}
		for i=1,count do
			local log = {}
			log.name = mMsg:readString()
			log.itemName = mMsg:readString()
			log.opCode = mMsg:readInt()
			log.time = mMsg:readInt()
			table.insert(logs, log)
		end
		-- print("cResGuildItemLog", count, GameUtilSenior.encode(logs))
		self:dispatchEvent({name = GameMessageCode.EVENT_GUILD_ITEM_LOGS, logs = logs})
	end,
	[GameMessageID.cNotifyMonExpHiterChange] = function (mMsg)
		local owner = {}
		owner.srcid = mMsg:readInt()
		owner.hiterid = mMsg:readInt()
		owner.name = mMsg:readString()
		self.mMonsterOwner[owner.srcid] = owner
		self:dispatchEvent({name = GameMessageCode.EVENT_MONSTER_OWNER_CHANGE, srcid = owner.srcid});
		-- print("/////////////cNotifyMonExpHiterChange/////////////", GameUtilSenior.encode(owner))
	end,
	[GameMessageID.cNotifyMapMonGen] = function (mMsg)
		local mapid = mMsg:readString()
		local size = mMsg:readShort()
		local name,x,y,time
		local thismap = self.mNetMap.mMapID == mapid

		self.mMapMonGenId = ""
		self.mMapMonGen = {}

		if thismap then
			self.mMapMonGenId = mapid
		end
		if size>0 then
			for i=1,size do
				name = mMsg:readString()
				x = mMsg:readShort()
				y = mMsg:readShort()
				time = mMsg:readInt()

				if thismap then
					table.insert(self.mMapMonGen,{name=name,x=x,y=y,time=time})
				end
			end
		end
	end,
	[GameMessageID.cResFindMapGhost] = function (mMsg)
		local mapid = mMsg:readString()
		local monName = mMsg:readString()
		local size = mMsg:readShort()
		local id,x,y,gtype
		local thismap = self.mNetMap.mMapID == mapid
		-- print("=---------------cResFindMapGhost",mapid) 

		self.mMapGhostMapId = ""
		self.mMapGhostList = {}
		self.mMapGhostRes = mapid

		if thismap then
			self.mMapGhostMapId = mapid
		end

		if size>0 then
			for i=1,size do
				id = mMsg:readInt()
				x = mMsg:readShort()
				y = mMsg:readShort()
				gtype = mMsg:readShort()

				if thismap then
					self.mMapGhostList[id] = {id=id,x=x,y=y,gtype=gtype}
				end
			end

			if thismap then
				-- self.mMapGhostReq = nil
				GameCharacter.setMapGhostList(self.mMapGhostMapId,self.mMapGhostList)
			end
		end

		-- if thismap then
		self.mMapGhostReq = nil
		-- end
	end,
}
end







function GameSocket:init()

	--这里存储当前角色所有相关信息

	self:removeAllEventListeners()

	self.mLogicMap=nil
	self.mPingDelay=GameBaseLogic.ClockTick

	self.mCharacter={mID=0,mType=GameConst.GHOST_THIS,mCloth=-1,mWeapon=-1,mMount=-1}
	self.mNetGhosts={}
	self.mItemDesp={}
	self.mUpgradeDesp={}
	self.mFriends={}
	self.mTasks={}
	self.mItems = {}
	self.mParam={}
	self.mPingTime = 0
	self.mPingTick = 0
	self.bagItems = {}

	self.mEquipItems = {}
	self.mGemItems = {}

	self.equipTable = {} --存放10个装备部件强化等级
	self.severDay = 0

	self.mExtendState={}
	self.mBottomState={}
	self.mSwitchState={}

	self.mModels={}
	self.mapOption ={}
	self.mMapConn = {}
	self.mMiniMapConn = {}
	-- self.mSafeData = {}
	self.mMiniNpc = {}
	self.mMapGhostReq = nil
	self.mMapGhostRes = nil
	self.mMapMonGenId = ""
	self.mMapMonGen = {}
	self.mMapGhostMapId = ""
	self.mMapGhostList = {}
	self.mNetMap={mMapID=nil,mLastMapID=nil}

	self.mGuildList = {}
	self.mChartData = {}
	self.mChartType = -1

	self.m_alertListAlert = {}
	self.m_alertListMid = {}
	self.m_alertListBottom = {}
	self.m_alertListPost = {}
	self.m_alertListRight = {}
	self.m_alertListCenterEXP = {}
	self.m_alertListCenterMoney = {}
	self.m_alertListCenterInnerPower = {}
	self.m_alertListMap = {}

	self.mVcoinShopNpcID = -1
	self.mShopNpc = {}
	self.mShopItemInfo = {}
	self.mVcoinShopItem = {}

	self.mGameParam = {}

	self.mChatHistroy = {}
	self.mHornChat = {}

	self.m_skillsDesp = {}

	--专门给技能展示用的
	self.m_skillsDespAngry = {}
	self.m_skillsDespNormal = {}

	self.m_nNpcId = 0
	self.m_nNpcTalkId = 0
	self.m_nItemTalkId = 0
	self.m_strNpcTalkMsg = ""
	self.m_strPrivateChatTarget = ""

	--消息验证
	self.mMoveStep=0
	self.mMoveStepRes=0
	self.mServerDir=0
	self.mServerX=0
	self.mServerY=0
	-- self.mMoveResTime=GameBaseLogic.getTime()
	self.mMoveReqX=0
	self.mMoveReqY=0

	self.mSkillSendTag=0
	self.mUseItemSendTag=0

	-- self.mCastSkillTime=GameBaseLogic.getTime()

	self.m_nCountDownDelay=0
	self.m_strCountDownMsg=""
	self.m_bLevelChanged=false
	self.m_bAllowInvite=true
	self.m_bGroupPickMode=true
	self.m_strApplyerName = ""
	-- self.m_bIsDisConnect = false
	self.m_bCollecting = false
	self.m_collectTime = 0
	self.m_bReqCollect = false
	self.m_bReqMountUp = false
	self.m_IsBagSellItem = false

	-- self.mStartAutoFight=false
	self.mAttackMode=101
	self.mBagSlotAdd = 0
	self.mDepotSlotAdd = 0
	self.mBagMaxSlot = 0
	self.mWarState = 0
	self.mKingGuild = ""
	self.mKingOfKings = ""
	self.KHcandidate = "" -- 皇宫显示的标志
	self.mXJ_slot_pos = 0  ---镶嵌位置
	self.mXJ_xq_or_hc = 1 ---1镶嵌 2合成
	self.mXJ_xq_data = {} ---镶嵌表

	self.m_IsBagSellItem = false
	self.m_BestSellerNum = 0
	self.m_netSkill = {}
	self.m_skillAddList = {}
	self.m_bBanYueOn = false
	self.m_bCiShaOn = false
	self.m_skillCD = {}
	self.mShortCut = {}
	self.mNetStatus = {}
	self.mStatusDesp = {}

	self.mOthersItems ={}
	self.m_PlayerEquip = {}

	--主角行为相关数据
	self.mLastAimGhost=-1
	self.mChangeAimFirst=false
	self.mCrossAutoMove = false
	self.m_bAutoWalk = false
	self.mLiehuoAction = false
	self.mLiehuoType = 0
	self.mTargetMap = ""
	self.mTargetMapX = 0
	self.mTargetMapY = 0
	self.mCrossMapPath = {}
	self.mSlaveState = 0
	self.mCreateJob = 0
	self.mCreateGender = 0
	-- self.m_AutoMovePos = nil--自动寻路坐标
	-- self.m_AutoMoveFlag = 0--自动寻路类型

	--交易信息
	self.mUiState = false
	self.mChatTradeItemList={}

	self.mTradeInviter=""
	self.mThisChangeItems = {}
	self.mDesChangeItems = {}
	self.mThisTradeItems = {}
	self.mDesTradeItems = {}
	self.mTradeInfo=
	{
		mTradeGameMoney=0,
		mTradeVcoin=0,
		mTradeSubmit=0,
		mTradeTarget="",
		mTradeDesGameMoney=0,
		mTradeDesVcoin=0,
		mTradeDesSubmit=0,
		mTradeDesLevel=0,
		mTradeResult=0,
	}
	self.mVoiceMsg = {}
	---------功能开启---------
	self.m_func = {}
	self.mExtendButtons = {}
	self.mBasicButtons = {}
	self.mAllFuncs = {}
	---------交易记录---------
	self.mTradeRecord = {
		mTradeVcoin = 0,
		mTradeDesVcoin = 0,
		mTradeTarget = "",
	}
	self.mTradeLocalRecord = {}

	---------装备提示面板---------
	self.mSuitLevel = nil

	self.mEquipsSuit = {}

	self.loginEnded = false
	self.mNeedContinueTask = false
	self.notice = {}
	self.previewData = nil
	self.menuChange = false
	self.PersonBossData = ""
	self.mHuoQiangOpen = false
	self.storyHasRun = {} --已经播放的剧情
	self.mGroupMembers = {}
	self.tipsMsg = {}
	self.chatRecent = {} --本次登录最近联系人

	--技能cd相关
	self.mPublicCDTime = {}
	self.mSkillCDTime = {}

	self.actionMoving = false --移动操作中

	self.mSelectGridSkill = nil -- 需要点击地面释放的技能
	self.mCastGridSkill = nil -- 打开后可持续点击地面释放技能
	self.mCDWaitNextSKill = nil

	self.NetAutoSkills = {} -- 自动释放技能数组
	self.lastCallFriendTime = 0

	self.GUIConfirm = {}

	self.mNetBuff = {}
	-- self.mBuffDef = {}

	-- 任务目标怪物
	self.mTaskTargetMon = nil
	self.mTaskTargetMap = nil

	self.mMonsterOwner = {}

	self.mExtendHalos = {}

	self.mFuncPreview = {}
	self.itemDailyUseLimit = {}--物品每日限制

	self.mSortFlag = nil

	self.mIsBagShowRedDot = false
	
	--上次等级变更时间
	self.levelUpdateChangeLastTime = 0
end

function GameSocket:ParseMsg(mMsg)
	local type=mMsg:readShort()
	--print(string.format("msg type: 0x%04X",type))
	if not GameMessageID.log[type] then
		--print(string.format("msg type: 0x%04X",type))
	elseif type==GameMessageID.cResPing then
		-- if self.mPingTick == 0 then
		-- 	self.mPingTick = os.time()
		-- else
		-- 	local pt = os.time() - self.mPingTick
		-- 	self.mPingTime = (self.mPingTime + pt)/2/2
		-- 	self.mPingTick = os.time()
		-- 	if GUILeftTop then
		-- 		if math.floor(self.mPingTime * 100) >= 10000 then
		-- 			GUILeftTop.updatePing( "ping:10000" )
		-- 		else
		-- 			GUILeftTop.updatePing( "ping:"..math.floor(self.mPingTime * 100) )
		-- 		end
		-- 	end
		-- end
	end

	self.mPingDelay = 0

	if self.NetFunc[type] then
		self.NetFunc[type](mMsg)
	end

end
-------------------------------------------------------------------请求

local function BuildBA(msgid)
	-- print("---------------BuildBA.msgid: "..msgid)
	local msg=SocketManager:getSendByteArray()
	msg:writeShort(msgid)
	return msg
end

function GameSocket:Authenticate(type,session,seed)
	local msg=BuildBA(GameMessageID.cReqAuthenticate)
	msg:writeInt(type)
	msg:writeString(session)
	msg:writeInt(seed)
	msg:writeInt(GameCCBridge.getPlatformId())
	msg:writeString((GameCCBridge.getConfigString("system_code")))

	self:sendMsg(msg)
end

function GameSocket:ListCharacter()
	self._reqChar = true
	local msg=BuildBA(GameMessageID.cReqListCharacter)

	msg:writeInt(0)
	self:sendMsg(msg)
end

function GameSocket:DeleteCharacter(charname)
	local msg=BuildBA(GameMessageID.cReqDeleteCharacter)

	msg:writeString(charname)

	self:sendMsg(msg)
end

function GameSocket:EnterGame(charname,sessionid)
	local msg=BuildBA(GameMessageID.cReqEnterGame)

	msg:writeString(charname)
	msg:writeString(sessionid)
	
	-- if sessionid~="" and PLATFORM_APP_STORE then
	-- 	cc.UserDefault:getInstance():setStringForKey("last_sid",sessionid)
	-- 	cc.UserDefault:getInstance():flush()
	-- end

	self:sendMsg(msg)
end

function GameSocket:CreateCharacter(chrname,job,gender,svrid,youke)

	if GameUtilSenior.checkInvalidChar(chrname) then
		GameUtilSenior.showAlert("","名称中包含非法字符","确定")
		return
	end

	youke=youke or ""

	local msg=BuildBA(GameMessageID.cReqCreateCharacter)

	msg:writeString(chrname)
	msg:writeInt(job)
	msg:writeInt(gender)
	msg:writeInt(svrid)
	msg:writeString(youke)

	self:sendMsg(msg)
end

function GameSocket:Turn(dir)
	local msg=BuildBA(GameMessageID.cReqTurn)
	msg:writeInt(dir)
	-- if MainRole then
	GameCharacter.mDir = dir
	-- end
	self.mServerDir = dir
	self:sendMsg(msg)
end

function GameSocket:UseSkill(skill_type,paramX,paramY,paramID)
	-- if self.mCharacter.mDead then return end
	
	
	if skill_type==100 or skill_type==103 then
		if GameCharacter.flagSkillCheckAndCast() then  --一般攻击自动触发跟随攻击,这个是我加的
		end
	end

	if skill_type == GameConst.SKILL_TYPE_YiBanGongJi or GameCharacter.isAttackSkill(skill_type) then
		if GameCharacter.checkCollect() then return end
	end

	if not GameBaseLogic.checkMpEnough(skill_type) then
		return
	end

	-- if self.m_skillCD[skill_type] then return end-- 老版本cd检测
	-- if not GameBaseLogic.IsSwitchSkill(skill_type) then
	if not GameBaseLogic.checkSkillCD(skill_type, true) then return end -- 新版本cd检测
	-- end

	local curtime = GameBaseLogic.getTime()
	local notifyCD = true
	
	if not GameBaseLogic.IsSwitchSkill(skill_type) then
		local mainAvatar = GameCharacter._mainAvatar or CCGhostManager:getMainAvatar()
		if mainAvatar then
			-- and mainAvatar:PAttr(GameConst.avatar_state)==GameConst.STATE_IDLE
			if skill_type==GameConst.SKILL_TYPE_YiBanGongJi then
				local todir= GameBaseLogic.getLogicDirection(cc.p(GameCharacter.mX,GameCharacter.mY),cc.p(paramX,paramY))
				if todir ~= GameCharacter.mDir then
					self:Turn(todir)
					-- mainAvatar:setPAttr(GameConst.avatar_dir,todir)
				end
			end

			local desp = GameBaseLogic.getSkillDesp(skill_type)
			if desp and self.m_netSkill[skill_type] then
				local efftype = desp.mEffectType
				local effres = desp.mEffectResID
				if mainAvatar:NetAttr(GameConst.net_job) == GameConst.JOB_ZS then
					--efftype = 10
					--effres = 0
					
					if skill_type == GameConst.SKILL_TYPE_LieHuoJianFa or 
						skill_type == GameConst.SKILL_TYPE_PoTianZhan or 
						skill_type == GameConst.SKILL_TYPE_ZhuRiJianFa or
						skill_type == GameConst.SKILL_TYPE_YeManChongZhuang or
						skill_type == GameConst.SKILL_TYPE_JiuJieJianFa or
						skill_type == GameConst.SKILL_TYPE_GuiYouZhan or
						skill_type == GameConst.SKILL_TYPE_ShenXuanJianFa or
						skill_type == GameConst.SKILL_TYPE_ZhanLongJianFa or
						skill_type == GameConst.SKILL_TYPE_PoKongJianFa then
						
						--print("=========>>>>>>skill_type=====start",skill_type,efftype,effres,temp_skill)
						mainAvatar:actionUseSkill(efftype,paramX,paramY,paramID,effres,self.m_netSkill[skill_type].mLevel)  --这一行是我加的,默认不显示特效
					-- elseif mainAvatar:NetAttr(GameConst.net_weapon) > 0 then
					else
						--efftype = 0
						local temp_skill = GameCharacter.getWarriorSkill()
						--print("=========>>>>>>skill_type=====start",skill_type,efftype,effres,temp_skill)
						-- local skillcd, _p = GameBaseLogic.getSkillCDTime(skill_type)
						if efftype~=0 and effres~=0 then
						elseif self.mLiehuoAction and self.mLiehuoType > 0 and GameCharacter.canCastLieHuo() then -- skillcd+self.mSkillCDTime[self.mLiehuoType] <= curtime
							desp = GameBaseLogic.getSkillDesp(self.mLiehuoType)
							if desp then
								efftype = 10
								effres = desp.mEffectResID

								self:dispatchEvent({name=GameMessageCode.EVENT_SKILL_COOLDOWN,type=self.mLiehuoType})

								self.mLiehuoAction = false
								self.mLiehuoType = 0
								notifyCD = false
							end
						elseif temp_skill ~= GameConst.SKILL_TYPE_YiBanGongJi then
							desp = GameBaseLogic.getSkillDesp(temp_skill)
							if desp then
								efftype = 10
								effres = desp.mEffectResID
							end
						elseif temp_skill == GameConst.SKILL_TYPE_YiBanGongJi then
							efftype = 10
							effres = 10000
						end

						if mainAvatar:NetAttr(GameConst.net_gender) == GameConst.SEX_MALE then
							if effres == 10100 then effres = 10110 end
							if effres == 10120 then effres = 10130 end
							if effres == 10200 then effres = 10210 end
							if effres == 10220 then effres = 10230 end
							if effres == 10310 then effres = 10320 end
						end
						--print("=========>>>>>>skill_type=====end",skill_type,efftype,effres,temp_skill)
						mainAvatar:actionUseSkill(efftype,paramX,paramY,paramID,effres,self.m_netSkill[skill_type].mLevel)
					end
				else
					mainAvatar:actionUseSkill(efftype,paramX,paramY,paramID,effres,self.m_netSkill[skill_type].mLevel)
				end
			end
		end
	end

	local mSkillCD, mPublicCD = GameBaseLogic.getSkillCDTime(skill_type)
	self.mPublicCDTime[mPublicCD] = curtime
	self.mSkillCDTime[skill_type] = curtime

	self.mSkillSendTag=self.mSkillSendTag+1

	if not GameBaseLogic.IsSwitchSkill(skill_type) and notifyCD then
		-- print("-------------================,GameMessageCode.EVENT_SKILL_COOLDOWN")
		self:dispatchEvent({name=GameMessageCode.EVENT_SKILL_COOLDOWN,type=skill_type})
	end

	--主线变装怪物后攻击目换常装

	if MainRole then GameCharacter.checkMonKilled(paramID) end

	-- print("=========================================use skill "..skill_type)

	local msg=BuildBA(GameMessageID.cReqUseSkill)  -- 服务器发送消息，施放技能
	msg:writeInt(skill_type)
	msg:writeInt(paramX)
	msg:writeInt(paramY)
	msg:writeUInt(paramID)
	msg:writeInt(self.mSkillSendTag)
	msg:writeInt(GameBaseLogic.getSkipTime())
	self:sendMsg(msg)
end

function GameSocket:GetItemDesp(typeid,itemName)
	local msg=BuildBA(GameMessageID.cReqGetItemDesp)
	msg:writeInt(typeid)
	msg:writeString(itemName)
	self:sendMsg(msg)
end

function GameSocket:setExtendState(ext_name,state)
	self.mExtendState[ext_name]=state
	self:dispatchEvent({name=GameMessageCode.EVENT_GUI_STATE})
end

function GameSocket:CountDownFinish()
	local msg=BuildBA(GameMessageID.cCountDownFinish)
	self:sendMsg(msg)
end

function GameSocket:ChangeAttackMode(attack_mode)
	if table.indexof(self.PKMapIds, self.mNetMap.mMapID) then
		return self:alertLocalMsg("PK战场不可以切换攻击模式", "alert")
	end

	-- if attack_mode == 105 then--
	-- 	self:alertLocalMsg("非PK地图不可切换至阵营模式", "alert")
	-- 	return
	-- end

	local msg=BuildBA(GameMessageID.cReqChangeAttackMode)
	msg:writeInt(attack_mode)
	self:sendMsg(msg)
end

function GameSocket:CreateGroup(flags)
	local msg=BuildBA(GameMessageID.cReqCreateGroup)
	msg:writeInt(flags)
	self:sendMsg(msg)
end

function GameSocket:LeaveGroup()
	local msg=BuildBA(GameMessageID.cReqLeaveGroup)
	self:sendMsg(msg)
end

function GameSocket:PickUp(itemid,x,y)
	local msg=BuildBA(GameMessageID.cReqPickUp)
	msg:writeInt(itemid)
	msg:writeInt(x or 0)
	msg:writeInt(y or 0)
	self:sendMsg(msg)
end

function GameSocket:FriendChange(name,title)
	local msg=BuildBA(GameMessageID.cReqFriendChange)
	msg:writeString(name)
	msg:writeInt(title)
	self:sendMsg(msg)
end

function GameSocket:FriendApplyAgree(name,agree)--1 同意 0 拒绝
	local msg=BuildBA(GameMessageID.cReqFriendApplyAgree)
	msg:writeString(name)
	msg:writeInt(agree)
	self:sendMsg(msg)
end

function GameSocket:FriendFresh()
	local msg=BuildBA(GameMessageID.cReqFriendFresh)
	self:sendMsg(msg)
end

function GameSocket:ListGuild(tag)
	local msg=BuildBA(GameMessageID.cReqListGuild)
	msg:writeInt(tag)
	self:sendMsg(msg)
end

function GameSocket:GetGuildInfo(guild_name,flags)
	local msg = BuildBA(GameMessageID.cReqGetGuildInfo)
	msg:writeString(guild_name)
	msg:writeInt(flags)
	self:sendMsg(msg)
end

function GameSocket:SetGuildInfo(guild_name,desp,notice)

	if GameUtilSenior.checkInvalidChar(guild_name) then
		--GameUtilSenior.showAlert("","名称中包含非法字符","确定")
		--return
	end

	if GameUtilSenior.checkInvalidChar(desp) then
		GameUtilSenior.showAlert("","文字中包含非法字符","确定")
		return
	end

	if GameUtilSenior.checkInvalidChar(notice) then
		GameUtilSenior.showAlert("","文字中包含非法字符","确定")
		return
	end

	local msg = BuildBA(GameMessageID.cReqSetGuildInfo)
	msg:writeString(guild_name)
	msg:writeString(desp)
	msg:writeString(notice)
	self:sendMsg(msg)
end

function GameSocket:CreateGuild(guild_name,flags)

	if GameUtilSenior.checkInvalidChar(guild_name) then
		GameUtilSenior.showAlert("","名称中包含非法字符","确定")
		return
	end

	local msg = BuildBA(GameMessageID.cReqCreateGuild)
	msg:writeString(guild_name)
	msg:writeInt(flags)
	self:sendMsg(msg)
end

function GameSocket:JoinGuild(guild_name,flags)
	local msg = BuildBA(GameMessageID.cReqJoinGuild)
	msg:writeString(guild_name)
	msg:writeInt(flags)
	self:sendMsg(msg)
end

function GameSocket:ListGuildMember(guild_name,list_type)
	local msg = BuildBA(GameMessageID.cReqListGuildMember)
	msg:writeString(guild_name)
	msg:writeInt(list_type)
	self:sendMsg(msg)
end

function GameSocket:ChangeGuildMemberTitle(guild_name,nick_name,dir)
	local msg = BuildBA(GameMessageID.cReqChangeGuildMemberTitle)
	msg:writeString(guild_name)
	msg:writeString(nick_name)
	msg:writeInt(dir)
	self:sendMsg(msg)
end

function GameSocket:LeaveGuild(guild_name)
	local msg = BuildBA(GameMessageID.cReqLeaveGuild)
	msg:writeString(guild_name)
	if self.mCharacter.num_enter and self.mCharacter.num_enter > 0 then
		self.mCharacter.num_enter = self.mCharacter.num_enter - 1
	end
	self:sendMsg(msg)
end

function GameSocket:CheckPlayerEquip( strName )
	self.mOthersItems = {}
	self.checkTargetName = strName
	self:InfoPlayer(strName)
end

function GameSocket:check_better_item(position, skiplevel)
	local ni
	if GameUtilSenior.isTable(position) then
		ni = self:getItemDefByID(position.mTypeID)
	elseif GameUtilSenior.isNumber(position) then
		ni = self:getNetItem(position);
	end
	if ni and GameCharacter._mainAvatar then
		if ni and ni.mTypeID then
			local item_define = self:getItemDefByID(ni.mTypeID);
			if item_define then
				if item_define.mJob == 0 or item_define.mJob == GameCharacter._mainAvatar:NetAttr(GameConst.net_job) then
					if not skiplevel and (item_define.mNeedParam > GameCharacter._mainAvatar:NetAttr(GameConst.net_level) or item_define.mNeedZsLevel > GameCharacter._mainAvatar:NetAttr(GameConst.net_zslevel)) then
						return;
					end
					local better = true;

					for i,v in pairs(self.mItems) do
						if v.position < 0 then
							local id = self:getItemDefByID(v.mTypeID);
							if id and id.mEquipType == item_define.mEquipType then
								if not GameBaseLogic.IsRing(v.mTypeID) and not GameBaseLogic.IsGlove(v.mTypeID) then
									if id.mNeedParam > item_define.mNeedParam then
										better = false;
									end
								elseif GameBaseLogic.IsRing(v.mTypeID) then
									local ring1 = self:getNetItem(GameConst.ITEM_RING1_POSITION)
									local ring2 = self:getNetItem(GameConst.ITEM_RING2_POSITION)
									if ring1 and ring2 then
										local ringDef1 = self:getItemDefByID(ring1.mTypeID)
										local ringDef2 = self:getItemDefByID(ring2.mTypeID)
										if ringDef1.mNeedParam > item_define.mNeedParam and ringDef2.mNeedParam > item_define.mNeedParam then
											better = false;
										end 
									end
								elseif GameBaseLogic.IsGlove(v.mTypeID) then
									local glove1 = self:getNetItem(GameConst.ITEM_GLOVE1_POSITION)
									local glove2 = self:getNetItem(GameConst.ITEM_GLOVE2_POSITION)
									if glove1 and glove2 then
										local gloveDef1 = self:getItemDefByID(glove1.mTypeID)
										local gloveDef2 = self:getItemDefByID(glove2.mTypeID)
										if gloveDef1.mNeedParam > item_define.mNeedParam and gloveDef2.mNeedParam > item_define.mNeedParam then
											better = false;
										end 
									end
								end
							end
						end
					end
					if better then
						--print("check_better_item",1)
						local betterType,posInAvatar1, posInAvatar2 = GameBaseLogic.isBetterInAvatar(position)
						if betterType == GameConst.ITEM_BETTER_SELF then
						--print("check_better_item",21)
							return better, posInAvatar1, posInAvatar2
						end
					end
				end
			end
		end
	end
end

function GameSocket:InfoPlayer(player_name)
	local msg = BuildBA(GameMessageID.cReqInfoPlayer)
	self.m_PlayerEquip[player_name] = {}
	self.other_avatar_save = "loaded"
	msg:writeString(player_name)
	self:sendMsg(msg)
end

function GameSocket:GetChartInfo(chart_type,page)
	local msg = BuildBA(GameMessageID.cReqGetChartInfo)
	msg:writeInt(chart_type)
	msg:writeInt(page)
	self:sendMsg(msg)
end

function GameSocket:StartCollect(id)
	-- if self.m_bReqMountUp then return end

	-- print("GameSocket:StartCollect",id)

	if not self.m_bCollecting and not self.m_bReqCollect then
		self.m_bReqCollect = true

		local monster=CCGhostManager:getPixesGhostByID(id)
		if monster then
			local todir= GameBaseLogic.getLogicDirection(cc.p(GameCharacter.mX,GameCharacter.mY),cc.p(monster:NetAttr(GameConst.net_x),monster:NetAttr(GameConst.net_y)))
			if todir~=GameCharacter.mDir then
				self:Turn(todir)
				if GameCharacter._mainAvatar then
					GameCharacter._mainAvatar:setPAttr(GameConst.avatar_dir,todir)
				end
			end
		end

		local msg = BuildBA(GameMessageID.cReqCollectStart)
		msg:writeInt(id)
		self:sendMsg(msg)
	end
end

function GameSocket:VcoinShopList(shop_id,flags)
	local msg = BuildBA(GameMessageID.cReqVcoinShopList)
	msg:writeInt(shop_id)
	msg:writeInt(flags)
	self:sendMsg(msg)
end

function GameSocket:NPCSell(npc_id,pos,type_id,number,flag)
	local msg = BuildBA(GameMessageID.cReqNPCSell)
	msg:writeInt(npc_id)
	msg:writeInt(pos)
	msg:writeInt(type_id)
	msg:writeInt(number)
	msg:writeInt(flag)
	self:sendMsg(msg)
end

function GameSocket:UndressItem(position)
	local msg = BuildBA(GameMessageID.cReqUndressItem)
	msg:writeInt(position)
	self:sendMsg(msg)
end

function GameSocket:ItemPositionExchange(from,to)
	local msg = BuildBA(GameMessageID.cReqItemPositionExchange)
	msg:writeInt(from)
	msg:writeInt(to)
	msg:writeInt(0)
	self:sendMsg(msg)
end

function GameSocket:TradeAddItem(pos,type_id,price,flag) --flag 0：面对面交易 ,1:聊天交易上架， 2：下架
	local msg = BuildBA(GameMessageID.cReqTradeAddItem)
	msg:writeInt(pos)
	msg:writeInt(type_id)
	msg:writeInt(price)
	msg:writeInt(flag)
	self:sendMsg(msg)
end

function GameSocket:TradeSubItem(pos,type_id)
	GameSocket:TradeAddItem(pos,type_id,0,2)
end

function GameSocket:TradeBuyItem(chrName,pos,type_id,lock,flag)--flag=1 购买，2 请求物品信息
	local msg = BuildBA(GameMessageID.cReqTradeBuyItem)
	msg:writeString(chrName)
	msg:writeInt(pos)
	msg:writeInt(type_id)
	msg:writeInt(lock)
	msg:writeInt(flag)
	self:sendMsg(msg)
end

function GameSocket:BagUseItemByType(type_id)
	for pos = GameConst.ITEM_BAG_BEGIN, GameConst.ITEM_BAG_SIZE + self.mBagSlotAdd - 1 do 
		local netItem = self:getNetItem(pos)

		if netItem and netItem.mTypeID == type_id then
			self:BagUseItem(pos,type_id)
			return true
		end
	end
end

function GameSocket:BagUseItem(position,type_id,num)
	if GameBaseLogic.IsGem(type_id) then
		self:dispatchEvent({name=GameMessageCode.EVENT_OPEN_PANEL,str="main_avatar", tab = 4, mParam = {tab=4,index=4}})
		return
	end
	if GameBaseLogic.useItemOpen(type_id) or GameUtilSenior.useItemOpen(type_id) then return end
	if GameBaseLogic.checkEquipDress(position) then
		if GUIExtendEquipAttr.useCheckJiCheng(position) then return end
	end
	local num = num or 1
	local msg = BuildBA(GameMessageID.cReqBagUseItem)
	msg:writeInt(position)
	msg:writeInt(type_id)
	msg:writeInt(num)
	self.mUseItemSendTag = self.mUseItemSendTag + 1
	msg:writeInt(self.mUseItemSendTag)
	self:sendMsg(msg)
	--喝药音效
end

function GameSocket:AddBagSlot()
	local msg = BuildBA(GameMessageID.cReqAddBagSlot)
	self:sendMsg(msg)
end

function GameSocket:AddDepotSlot()
	local msg = BuildBA(GameMessageID.cReqAddDepotSlot)
	self:sendMsg(msg)
end

function GameSocket:DropItem(pos,type_id,number)
	local msg = BuildBA(GameMessageID.cReqDropItem)
	msg:writeInt(pos)
	msg:writeInt(type_id)
	msg:writeInt(number)
	self:sendMsg(msg)
end

function GameSocket:SortItem(flag)

	GameMusic.play("music/26.mp3")

	local msg = BuildBA(GameMessageID.cReqSortItem)
	msg:writeInt(flag)
	self:sendMsg(msg)

	self.mSortFlag = flag
end

function GameSocket:PushLuaTable(type,table)
	local msg = BuildBA(GameMessageID.cReqPushLuaTable)
	msg:writeString(type)
	msg:writeString(table)
	self:sendMsg(msg)
end

function GameSocket:DirectFly(fly_id)
	local msg = BuildBA(GameMessageID.cReqDirectFly)
	msg:writeInt(fly_id)
	self:sendMsg(msg)
end

function GameSocket:ServerScript(param)  --执行服务器lua脚本,处理相关逻辑
	local msg = BuildBA(GameMessageID.cReqServerScript)
	msg:writeString(param)
	self:sendMsg(msg)
end

function GameSocket:NpcTalk(npcid,param)
	--self.m_nNpcTalkId = 0
	--self.m_strNpcTalkMsg = ""

	local msg = BuildBA(GameMessageID.cReqNPCTalk)
	msg:writeUInt(npcid)
	msg:writeString(param)
	self:sendMsg(msg)
end

function GameSocket:NpcTalk(npcid,param)
	--self.m_nNpcTalkId = 0
	--self.m_strNpcTalkMsg = ""

	local msg = BuildBA(GameMessageID.cReqNPCTalk)
	msg:writeUInt(npcid)
	msg:writeString(param)
	self:sendMsg(msg)
end

function GameSocket:PlayerTalk(seed,param)
	local msg = BuildBA(GameMessageID.cReqPlayerTalk)
	msg:writeInt(seed)
	msg:writeString(param)
	self:sendMsg(msg)
end

function GameSocket:ItemTalk(itemid,seed,param)
	local msg = BuildBA(GameMessageID.cReqItemTalk)
	msg:writeInt(itemid)
	msg:writeInt(seed)
	msg:writeString(param)
	self:sendMsg(msg)
end

function GameSocket:NormalChat(msgstr)
	if string.len(msgstr) > 511 then
		self:alertLocalMsg(GameConst.str_msg_too_long, "alert")
		return
	end
	if GameUtilSenior.checkInvalidChar(msgstr,true) then
		self:alertLocalMsg("请不要发送非法字符", "alert")
		return
	end
	self.lastChatChannel = GameConst.str_chat_near
	
	local msg = BuildBA(GameMessageID.cReqNormalChat)
	msg:writeString(msgstr)
	self:sendMsg(msg)
end

function GameSocket:MapChat(msgstr)
	if string.len(msgstr) > 511 then
		self:alertLocalMsg(GameConst.str_msg_too_long, "alert")
		return
	end
	if GameUtilSenior.checkInvalidChar(msgstr,true) then
		self:alertLocalMsg("请不要发送非法字符", "alert")
		return
	end

	local msg = BuildBA(GameMessageID.cReqMapChat)
	msg:writeString(msgstr)
	self:sendMsg(msg)
end

function GameSocket:PrivateChat(target,msgstr)
	if string.len(msgstr) > 511 then
		self:alertLocalMsg(GameConst.str_msg_too_long, "alert")
		return
	end
	if GameUtilSenior.checkInvalidChar(msgstr,true) then
		self:alertLocalMsg("请不要发送非法字符", "alert")
		return
	end
	self.lastChatChannel = GameConst.str_chat_private

	local msg = BuildBA(GameMessageID.cReqPrivateChat)
	msg:writeString(target)
	msg:writeString(msgstr)
	self:sendMsg(msg)
end

function GameSocket:WorldChat(msgstr)
	if string.len(msgstr) > 511 then
		self:alertLocalMsg(GameConst.str_msg_too_long, "alert")
		return
	end
	if GameUtilSenior.checkInvalidChar(msgstr,true) then
		self:alertLocalMsg("请不要发送非法字符", "alert")
		return
	end

	self.lastChatChannel = GameConst.str_chat_world

	self.WorldChatTime = self.WorldChatTime or 0
	if os.time() - self.WorldChatTime <10 then
		return self:alertLocalMsg(string.format("距下次世界频道发言%d秒",self.WorldChatTime +10-os.time()), "alert")
	end
	self.WorldChatTime = os.time()
	local msg = BuildBA(GameMessageID.cReqWorldChat)
	msg:writeString(msgstr)
	self:sendMsg(msg)
end

function GameSocket:HornChat(msgstr)
	if string.len(msgstr) > 256 then
		self:alertLocalMsg(GameConst.str_msg_too_long, "alert")
		return
	end
	if GameUtilSenior.checkInvalidChar(msgstr,true) then
		self:alertLocalMsg("请不要发送非法字符", "alert")
		return
	end

	self.lastChatChannel = GameConst.str_chat_private
	local msg = BuildBA(GameMessageID.cReqHornChat)
	msg:writeString(msgstr)
	self:sendMsg(msg)
end

function GameSocket:GuildChat(msgstr)
	if string.len(msgstr) > 511 then
		self:alertLocalMsg(GameConst.str_msg_too_long, "alert")
		return
	end
	if GameUtilSenior.checkInvalidChar(msgstr,true) then
		self:alertLocalMsg("请不要发送非法字符", "alert")
		return
	end
	self.lastChatChannel = GameConst.str_chat_guild

	local msg = BuildBA(GameMessageID.cReqGuildChat)
	msg:writeString(msgstr)
	self:sendMsg(msg)
end

function GameSocket:GroupChat(msgstr)
	if string.len(msgstr) > 511 then
		self:alertLocalMsg(GameConst.str_msg_too_long, "alert")
		return
	end
	if GameUtilSenior.checkInvalidChar(msgstr,true) then
		self:alertLocalMsg("请不要发送非法字符", "alert")
		return
	end
	self.lastChatChannel = GameConst.str_chat_group

	local msg = BuildBA(GameMessageID.cReqGroupChat)
	msg:writeString(msgstr)
	self:sendMsg(msg)
end
function GameSocket:sendChatToLastChannel(msg)
	if self.lastChatChannel == GameConst.str_chat_group then
		self:GroupChat(msg)
	elseif self.lastChatChannel == GameConst.str_chat_guild then
		self:GuildChat(msg)
	elseif self.lastChatChannel == GameConst.str_chat_private then
		self:PrivateChat(msg)
	elseif self.lastChatChannel == GameConst.str_chat_near then
		self:MapChat(msg)
	else
		self:WorldChat(msg)
	end
end
-- function GameSocket:UpgradeEquip(posEquip,posSteel,posAdd,pay_type)
-- 	local msg = BuildBA(GameMessageID.cReqUpgradeEquip)
-- 	self.m_upgradeFlag = false
-- 	msg:writeInt(posEquip)
-- 	msg:writeInt(posSteel)
-- 	msg:writeInt(posAdd)
-- 	msg:writeInt(pay_type)
-- 	self:sendMsg(msg)
-- end

-- function GameSocket:MergeSteel(pos1,pos2,pos3,posAdd,pay_type)
-- 	local msg = BuildBA(GameMessageID.cReqMergeSteel)
-- 	msg:writeInt(pos1)
-- 	msg:writeInt(pos2)
-- 	msg:writeInt(pos3)
-- 	msg:writeInt(posAdd)
-- 	msg:writeInt(pay_type)
-- 	self:sendMsg(msg)
-- end

-- function GameSocket:EquipExchangeUpgrade(posFrom,posTo,posAdd,pay_type)
-- 	local msg = BuildBA(GameMessageID.cReqEquipExchangeUpgrade)
-- 	msg:writeInt(posFrom)
-- 	msg:writeInt(posTo)
-- 	msg:writeInt(posAdd)
-- 	msg:writeInt(pay_type)
-- 	self:sendMsg(msg)
-- end

-- function GameSocket:SteelEquip(pos,type_id)
-- 	local msg = BuildBA(GameMessageID.cReqSteelEquip)
-- 	msg:writeInt(pos)
-- 	msg:writeInt(type_id)
-- 	self:sendMsg(msg)
-- end

-- function GameSocket:EquipReRandAdd(posEquip,posAdd)
-- 	local msg = BuildBA(GameMessageID.cReqEquipReRandAdd)
-- 	msg:writeInt(posEquip)
-- 	msg:writeInt(posAdd)
-- 	self:sendMsg(msg)
-- end

function GameSocket:SplitItem(pos,id,num)
	local msg = BuildBA(GameMessageID.cReqSplitItem)
	msg:writeInt(pos)
	msg:writeInt(id)
	msg:writeInt(num)
	self:sendMsg(msg)
end

function GameSocket:UpdateTicket()
	local msg = BuildBA(GameMessageID.cReqUpdateTicket)
	self:sendMsg(msg)
end

function GameSocket:NpcBuy(id,num)
	if self.mShopNpc then
		local itemdef = self:getItemDefByID(self.mShopItemInfo[id].type_id)
		print(self.mShopItemInfo[id].type_id,itemdef.mStackMax)
		if itemdef and self:getLeftBagNum() >= math.ceil(num/itemdef.mStackMax) then
			local msg = BuildBA(GameMessageID.cReqNPCBuy)
			msg:writeUInt(self.mShopNpc.srcid)
			msg:writeInt(self.mShopNpc.page)
			msg:writeInt(self.mShopItemInfo[id].pos)
			msg:writeInt(self.mShopItemInfo[id].good_id)
			msg:writeInt(self.mShopItemInfo[id].type_id)
			msg:writeInt(num)
			self:sendMsg(msg)
		else
			self:alertLocalMsg("背包格子不足！", "alert")
		end
	end
end

function GameSocket:VcoinShopBuy(id,num)
	if #self.mVcoinShopItem <= 0 or self.mVcoinShopNpcID < 0 then
		self.VcoinShopList(0,0)
		return
	end
	local msg = BuildBA(GameMessageID.cReqNPCBuy)
	msg:writeUInt(self.mVcoinShopNpcID)
	msg:writeInt(0)
	msg:writeInt(self.mShopItemInfo[id].pos)
	msg:writeInt(self.mShopItemInfo[id].good_id)
	msg:writeInt(self.mShopItemInfo[id].type_id)
	msg:writeInt(num)
	self:sendMsg(msg)
end

function GameSocket:InviteGroup(name)
	if checkint(self.mCharacter.mGroupID) == 0 then
		self:CreateGroup(0)
	end
	local msg = BuildBA(GameMessageID.cReqInviteGroup)
	msg:writeString(name)
	self:sendMsg(msg)
end

function GameSocket:JoinGroup(group_id)
	local msg = BuildBA(GameMessageID.cReqJoinGroup)
	msg:writeInt(group_id)
	self:sendMsg(msg)
end

function GameSocket:GroupKickMember(name)
	local msg = BuildBA(GameMessageID.cReqGroupKickMember)
	msg:writeString(name)
	self:sendMsg(msg)
end

function GameSocket:GroupSetLeader(name)
	local msg = BuildBA(GameMessageID.cReqGroupSetLeader)
	msg:writeString(name)
	self:sendMsg(msg)
end

function GameSocket:TradeInvite(name)
	local msg = BuildBA(GameMessageID.cReqTradeInvite)
	msg:writeString(name)
	self:sendMsg(msg)
end

function GameSocket:AgreeTradeInvite(inviter)
	local msg = BuildBA(GameMessageID.cReqAgreeTradeInvite)
	msg:writeString(inviter)
	self:sendMsg(msg)
end

function GameSocket:TradeSubmit()
	local msg = BuildBA(GameMessageID.cReqTradeSubmit)
	self:sendMsg(msg)
end

function GameSocket:CloseTrade()
	local target = self.mTradeInviter
	self.mTradeInviter=""
	self.mThisChangeItems = {}
	self.mDesChangeItems = {}
	self.mThisTradeItems = {}
	self.mDesTradeItems = {}
	
	self.mTradeInfo.mTradeGameMoney=0
	self.mTradeInfo.mTradeVcoin=0
	self.mTradeInfo.mTradeSubmit=0
	self.mTradeInfo.mTradeTarget=""
	self.mTradeInfo.mTradeDesGameMoney=0
	self.mTradeInfo.mTradeDesVcoin=0
	self.mTradeInfo.mTradeDesSubmit=0
	self.mTradeInfo.mTradeDesLevel=0
	
	self.mTradeRecord = {
		mTradeVcoin = 0,
		mTradeDesVcoin = 0,
		mTradeTarget = "",
	}

	--if self.mTradeInfo.mTradeResult == 1 then
		local msg = BuildBA(GameMessageID.cReqCloseTrade)
		msg:writeString(target)
		self:sendMsg(msg)
	--end
	
end

function GameSocket:TradeAddVcoin(num)
	local msg = BuildBA(GameMessageID.cReqTradeAddVcoin)
	msg:writeInt(num)
	self:sendMsg(msg)
end

function GameSocket:TradeAddGameMoney(num)
	local msg = BuildBA(GameMessageID.cReqTradeAddGameMoney)
	msg:writeInt(num)
	self:sendMsg(msg)
end

function GameSocket:AgreeInviteGroup(name,id)
	local msg = BuildBA(GameMessageID.cReqAgreeInviteGroup)
	msg:writeString(name)
	msg:writeInt(id)
	self:sendMsg(msg)
end

function GameSocket:AgreeJoinGroup(name)
	local msg = BuildBA(GameMessageID.cReqAgreeJoinGroup)
	msg:writeString(name)
	self:sendMsg(msg)
end

function GameSocket:DestoryItem(pos,id)
	local msg = BuildBA(GameMessageID.cReqDestoryItem)
	msg:writeInt(pos)
	msg:writeInt(id)
	self:sendMsg(msg)
end

function GameSocket:NpcShop(npc_id,page)

	local msg = BuildBA(GameMessageID.cReqNPCShop)
	msg:writeUInt(npc_id)
	msg:writeInt(page)
	self:sendMsg(msg)
end

function GameSocket:SaveShortcut(notDispatch)
	local numSkill = 0
	local msg = BuildBA(GameMessageID.cReqSaveShortcut)
	for i=1,16 do
		if self.mShortCut[i] and self.mShortCut[i].param ~= 0 then
			numSkill = numSkill + 1
		end
	end
	msg:writeInt(numSkill)
	for i=1,16 do
		if self.mShortCut[i] and self.mShortCut[i].param ~= 0 then
			msg:writeInt(self.mShortCut[i].cut_id)
			msg:writeInt(self.mShortCut[i].type)
			msg:writeInt(self.mShortCut[i].param)
		end
	end
	self:sendMsg(msg)
	if not notDispatch then
		self:dispatchEvent({name = GameMessageCode.EVENT_SET_SHORTCUT})
	end
end

function GameSocket:ChangeMount()
	if self.m_bReqMountUp then return end
	local msg = BuildBA(GameMessageID.cReqChangeMount)
	self:sendMsg(msg)
end
function GameSocket:freshHPMP()
	local msg = BuildBA(GameMessageID.cReqFreshHPMP)
	self:sendMsg(msg)
end

function GameSocket:Relive(type)
	local msg = BuildBA(GameMessageID.cReqRelive)
	msg:writeInt(type)
	self:sendMsg(msg)
end

function GameSocket:GuildReperotry()
	local msg = BuildBA(GameMessageID.cReqListGuildDepot)
	self:sendMsg(msg)
end

function GameSocket:getMails()
	local msg = BuildBA(GameMessageID.cReqGetMails)
	self:sendMsg(msg)
	
end

function  GameSocket:checkMailRedPoint()
	local flag=false
	for i=1,#self.mails do 
	-- if (#singleMail.item > 0 and singleMail.isReceive == 0) or (#singleMail.item == 0 and singleMail.isOpen == 0) then	
		if (self.mails[i].isReceive==0 and #self.mails[i].item>0) or (self.mails[i].isOpen==0 and #self.mails[i].item==0)  then 		
			flag=true
			break
		else
			flag=false		
		end	
	end 
	if flag then 
		self:dispatchEvent({name = GameMessageCode.EVENT_SHOW_REDPOINT, lv = 2051,index =1})
	else
		self:dispatchEvent({name = GameMessageCode.EVENT_REMOVE_REDPOINT, lv = 2051,index = 1})
	end
end

function GameSocket:checkSkillRedPoint(netSkill2)
	local show = false
	for k,v in pairs(self.m_netSkill) do
		local netSkill=v
		if netSkill.mTypeID~=100 then --不计算普通攻击
			if not MainRole or not GameCharacter._mainAvatar then return end
			local curLevel = GameCharacter._mainAvatar:NetAttr(GameConst.net_level)
			local nsd = GameBaseLogic.getSkillDesp(netSkill.mTypeID)
			if curLevel>=netSkill.mLevel and netSkill.mExp>=nsd.mNeedExp and netSkill.mExp>0 then
				-- self:dispatchEvent({name = GameMessageCode.EVENT_SHOW_REDPOINT, lv = 2022,index =1})
				self.skillRed[netSkill.mTypeID]=true
				show = true
				-- break
			else
				-- self:dispatchEvent({name = GameMessageCode.EVENT_REMOVE_REDPOINT, lv = 2022,index = 1})
				self.skillRed[netSkill.mTypeID]=false
			end
		end
	end
	
	if show then
		self:dispatchEvent({name = GameMessageCode.EVENT_SHOW_REDPOINT, lv = 2022,index =1})
	else
		self:dispatchEvent({name = GameMessageCode.EVENT_REMOVE_REDPOINT, lv = 2022,index = 1})
	end
end

function GameSocket:readMail(mailId)
	local msg = BuildBA(GameMessageID.cReqOpenMail)
	msg:writeString(mailId)
	self:sendMsg(msg)
	self:checkMailRedPoint()-----主面板红点
end

function GameSocket:getMailAward(mailId)
	local msg = BuildBA(GameMessageID.cReqReceiveMailItems)
	msg:writeString(mailId)
	self:sendMsg(msg)
end

function GameSocket:deleteMail(mailId)
	local msg = BuildBA(GameMessageID.cReqDeleteMail)
	msg:writeInt(1)
	-- for i,v in ipairs(self.mails) do
		msg:writeString(mailId)
	-- end
	self:sendMsg(msg)
end

function GameSocket:KuafuAuth(result)
	local msg = BuildBA(GameMessageID.cReqKuafuAuth)
	msg:writeString(result.ticket)
	msg:writeString(result.loginid)
	msg:writeString(result.charname)
	msg:writeString(result.kuafuip)
	msg:writeString(result.kuafuport)
	msg:writeString(result.localip)
	msg:writeString(result.localport)
	msg:writeString(result.kuafuparam)
	msg:writeInt(result.ticketseed)
	msg:writeString(result.localPTID)
	msg:writeString(result.localServerID)
	msg:writeString(result.localArea)
	self:sendMsg(msg)
end
--寄售
function GameSocket:consignItem(result)
	local msg = BuildBA(GameMessageID.cReqConsignItem)
	msg:writeInt(result.pos)
	msg:writeInt(result.num)
	msg:writeInt(result.price)
	msg:writeInt(result.time)
	self:sendMsg(msg)
end

-- int type; // 0:全部 1:装备 2:药品 3:材料 4:其他 5:自己
-- 	int begin_index; // 开始查找索引
-- 	int job; // 职业
-- 	int condition; // 筛选条件
-- 0 全部 1:0-80 2:80-2转 3:2转以上
--请求寄售列表
function GameSocket:reqConsignableItems(result)
	local msg = BuildBA(GameMessageID.cReqGetConsignableItems)
	msg:writeInt(result.type)
	msg:writeInt(result.index)
	msg:writeInt(result.job)
	msg:writeInt(result.level)
	msg:writeString(result.filter)
	self:sendMsg(msg)
end

--购买寄售物品
function GameSocket:reqBuyConsignItem(result)
	local msg = BuildBA(GameMessageID.cReqBuyConsignableItem)
	msg:writeInt(result.mSeedId)
	self:sendMsg(msg)
end

--寄售下架
function GameSocket:reqTakeBackConsignableItem(result)
	local msg = BuildBA(GameMessageID.cReqTakeBackConsignableItem)
	msg:writeInt(result.mSeedId)
	self:sendMsg(msg)
end

--提取寄售收益
function GameSocket:reqTakeBackVcoin()
	local msg = BuildBA(GameMessageID.cReqTakeBackVCoin)
	self:sendMsg(msg)
end

--请求红包日志
function GameSocket:reqGuildRedPacketLog()
	local msg = BuildBA(GameMessageID.cReqGuildRedPacketLog)
	self:sendMsg(msg)
end

--请求帮会仓库日志
function GameSocket:reqGuildItemLog()
	local msg = BuildBA(GameMessageID.cReqGuildItemLog)
	self:sendMsg(msg)
end

--请求查询地图上的物体
function GameSocket:reqFindMapGhost(mapid,num,name,gtype)
	if not gtype then gtype = 0 end
	if not name then name = "" end

	self.mMapGhostRes = nil
	self.mMapGhostReq = mapid

	print("reqFindMapGhost",mapid,num,name,gtype)

	local msg = BuildBA(GameMessageID.cReqFindMapGhost)
	msg:writeString(mapid)
	msg:writeShort(num)
	msg:writeString(name)
	msg:writeShort(gtype)
	self:sendMsg(msg)
end

----------------------------------工具方法--------------------------------

function GameSocket:GameEnterMap()

	if not self.mNetMap.mMapID then
		GameCCBridge.showMsg("登录失败,请重试")

		GameBaseLogic.ExitToRelogin()
	end

	self.mMapGhostReq = nil
	self.mMapGhostRes = nil
	self.mMapGhostMapId = ""
	self.mMapGhostList = {}
	self.mMapMonGenId = ""
	self.mMapMonGen = {}
	
	GameCharacter.setMapGhostList()
	GameCharacter.updateAttr()
	GameCharacter.stopAutoFight()
	-- GameCharacter.addGhostEffect(GameCharacter.mID,990013,"entermap")
	-- GameMusic.mapMusic(self.mNetMap.mMapID)
	if not MAIN_IS_IN_GAME then
		
	-- 	if CONFIG_IS_DEBUG == 1 then
	-- 		cc.Director:getInstance():runWithScene(GameScene.new())
	-- 	else
			-- cc.Director:getInstance():replaceScene(cc.SceneGame:create())
	-- 	end
	else
		cc.GhostManager:getInstance():remAllEffect()
		cc.GhostManager:getInstance():remAllSkill()
		cc.CacheManager:getInstance():releaseUnused(false)
	end
	self:alertLocalMsg(self.mNetMap.mName,"map")	--进入地图提示消息
	self:dispatchEvent({name = GameMessageCode.EVENT_CHANGE_MAP})
	self:dispatchEvent({name = GameMessageCode.EVENT_MOVE_END})
	self:dispatchEvent({name = GameMessageCode.EVENT_MAP_ENTER, PkEnable = table.indexof(self.PKMapIds, self.mNetMap.mMapID)})
	self:dispatchEvent({name = GameMessageCode.EVENT_CLOSE_PANEL, str = "panel_minimap"})
	if self.mNeedContinueTask then
		self:dispatchEvent({name = GameMessageCode.EVENT_CONTINUE_TASK})
		self.mNeedContinueTask = false
	end
	
	--  -- 邪恶龙神剧情
	-- if self.mNetMap.mName == "邪恶领地[副本]" then
	-- 	local tid, ts = self:checkTaskState(1000)
	-- 	if tid == 26 and ts < 4 then
	-- 		self:dispatchEvent({name = GameMessageCode.EVENT_SHOW_STORY_LINE, lv = 1000, callback = function ()
 --  				self:PushLuaTable("map.raid_main_task1.handleTimerStart", "")
 --  				GameCharacter.startAutoFight()
 --  			end})
	-- 	end
	-- end

	GUILeftTop.resetTick()
	-- --进入皇宫取消坐骑
	-- local forbidMountMap = {"v218"}
	-- if table.indexof(forbidMountMap,self.mNetMap.mMapID) and GameCharacter._mainAvatar then
	-- 	local mModels = self.mModels[GameCharacter._mainAvatar:NetAttr(GameConst.net_id)]
	-- 	if mModels[7] and mModels[7]>0 and GameCharacter._mainAvatar:NetAttr(GameConst.net_mount)>0 and GameCharacter._mainAvatar:NetAttr(GameConst.net_level)>=65 then
	-- 		self:PushLuaTable("gui.PanelMount.onPanelData",GameUtilSenior.encode({ actionid= "mounting"}))
	-- 		self:ChangeMount()
	-- 	end
	-- end
end

function GameSocket:getPlayerModel(srcid,mid)
	if self.mModels and self.mModels[srcid] then
		if self.mModels[srcid][mid] then
			return self.mModels[srcid][mid]
		end
	end
	return 0
end

function GameSocket:getItemDefByPos(pos)
	local netItem = self:getNetItem(pos)
	if netItem then
		return self:getItemDefByID(netItem.mTypeID)
	end
	return nil
end

function GameSocket:getItemDefByID(typeid)
	if self.mItemDesp[typeid] then
		return self.mItemDesp[typeid]
	else
		self:GetItemDesp(typeid,"")
	end
	return nil
end

function GameSocket:getItemDefByIDFromLocal(typeid)
	if self.mItemDesp[typeid] then
		return self.mItemDesp[typeid]
	end
	return nil
end

function GameSocket:getItemDefByName(name)
	for itemid,item in pairs(self.mItemDesp) do
		if item.mName == name then
			return item
		end
	end
	self:GetItemDesp(-1,name)
	return nil
end

function GameSocket:getItemPosByType(typeid)
	for pos,item in pairs(self.mItems) do
		if item and GameBaseLogic.IsPosInBag(item.position) then
			if item.mTypeID == typeid then
				return pos
			end
		end
	end
	return -999
end

function GameSocket:hasItem(name)
	local itemdef = self:getItemDefByName(name)
	if not itemdef then return false end

	for pos,item in pairs(self.mItems) do
		if item and GameBaseLogic.IsPosInBag(item.position) then
			if item.mTypeID == itemdef.mTypeID then
				return true
			end
		end
	end
	return false
end

function GameSocket:dispatchChangeAlertMsg(str1,str2,change)
	local msg = {
		[1] = {"获得了物品:", "30FF00"},
	}
	if change ~= 0 then
		if change > 0 then
			msg[1][1] = str1..change
			self:alertLocalMsg(GameUtilSenior.encode(msg),"right")
		else
			msg[1][1] = str2..(-change)
			self:alertLocalMsg(GameUtilSenior.encode(msg),"right")
		end
	end
end

function GameSocket:alertLocalMsg(msg,mtype,param,firstInQueue)
	if GameUtilSenior.decode(msg) then
		param = GameUtilSenior.decode(msg)
		if param.msg then
			msg = param.msg
		end
	end
	-- msg = GameBaseLogic.clearHtmlText(msg)
	if not mtype then mtype="alert" end
	table.insert(self["m_alertList"..string.ucfirst(mtype)],msg)
	param = param or {}
	param.firstInQueue = firstInQueue
	print("alertLocalMsg", msg, mtype);
	self:dispatchEvent({name=GameMessageCode.EVENT_ADD_ALERT,msg=msg,type=mtype, param = param})
end

function GameSocket:getNetItem(pos)
	if self.mItems[pos] then
		return self.mItems[pos]
	else
		return nil
	end
end

function GameSocket:getQiangHuaItem(pos)
	if self.mEquipItems[pos] then
		return self.mEquipItems[pos]
	else
		return nil
	end
end

function GameSocket:getNetItemById(typeid)
	for i=0,GameConst.ITEM_BAG_SIZE + self.mBagSlotAdd - 1 do
		if self.mItems[i] then
			if self.mItems[i].mTypeID == typeid then
				return i
			end
		end
	end
	return nil
end

function GameSocket:getTypeItemNum(typeid)
	local num=0
	for i=0,GameConst.ITEM_BAG_SIZE + self.mBagSlotAdd - 1 do
		if self.mItems[i] then
			if self.mItems[i].mTypeID == typeid then
				num=num+self.mItems[i].mNumber
			end
		end
	end
	return num
end

function GameSocket:getBagCount()
	local count = 0
	for i=0,GameConst.ITEM_BAG_SIZE + self.mBagSlotAdd - 1 do
		if self.mItems[i] then
			count = count + 1
		end
	end
	return count
end

function GameSocket:isBagFull()
	return self:getBagCount() >= GameConst.ITEM_BAG_SIZE + self.mBagSlotAdd
end

function GameSocket:isPosInBag(pos)
	return (pos>=0 and pos<GameConst.ITEM_BAG_SIZE + self.mBagSlotAdd)
end

function GameSocket:getLeftBagNum()
	return GameConst.ITEM_BAG_SIZE + self.mBagSlotAdd - self:getBagCount()
end

function GameSocket:checkBagFull(pos)
	local leftBagNum = self:getLeftBagNum()
	if leftBagNum <= 3 then
		-- if not self.tipsMsg["tip_bag_full"] then
		-- 	self.tipsMsg["tip_bag_full"] = {"full"}
		-- 	self:dispatchEvent({name = GameMessageCode.EVENT_SHOW_BOTTOM,str="tip_bag_full"})
		-- end
		self:dispatchEvent({name=GameMessageCode.EVENT_BAG_UNFULL,vis = true})
	else
		-- if self.tipsMsg["tip_bag_full"] and #self.tipsMsg["tip_bag_full"]>0 then
		-- end
		self:dispatchEvent({name=GameMessageCode.EVENT_BAG_UNFULL,vis = false})
	end
end

function GameSocket:checkBagRedDot()
	local showDot = false
	for i=0,GameConst.ITEM_BAG_SIZE + self.mBagSlotAdd - 1 do
		if self.mItems[i] and GameBaseLogic.checkItemShowUse(self.mItems[i].mTypeID) then
			showDot = true
			break
		end
	end

	-- if showDot and not self.mIsBagShowRedDot then
	-- 	self:dispatchEvent({name = GameMessageCode.EVENT_SHOW_REDPOINT, lv = 2071,index = 1})
	-- elseif not showDot and self.mIsBagShowRedDot then
	-- 	self:dispatchEvent({name = GameMessageCode.EVENT_REMOVE_REDPOINT, lv = 2071,index = 1})
	-- end
	self.mIsBagShowRedDot = showDot
	if showDot then
		self:dispatchEvent({name = GameMessageCode.EVENT_SHOW_REDPOINT, lv = 2071,index = 1})
	else
		self:dispatchEvent({name = GameMessageCode.EVENT_REMOVE_REDPOINT, lv = 2071,index = 1})
	end
end

function GameSocket:getServerParam(index)
	if self.mParam[GameCharacter.mID][index] then
		return self.mParam[GameCharacter.mID][index]
	end
	return 0
end

function GameSocket:addToMsgHistory(netChat)
	if self:getRelation(netChat.m_strName)==102 then return end
	table.insert(self.mChatHistroy,netChat)
	if #self.mChatHistroy > 200 then
		table.remove(self.mChatHistroy,1)
	end
	self:dispatchEvent({name = GameMessageCode.EVENT_CHAT_MSG,msg = netChat})
end

-- -- [2]文字信息  [3]本地  [4]http  [5]时长 
-- function GameSocket:saveNetVoiceMsg(params)
-- 	--"onVoice",charStr,localStr,httpStr,duration
-- 	self:dispatchEvent({name = GameMessageCode.EVENT_VOICE_HANDLE_MSG, params = params})
-- end

-- function GameSocket:onChangeTroopModel( model,isLeader )
-- 	self:dispatchEvent({name = GameMessageCode.EVENT_VOICE_MODEL_CHANGE,model = model,isLeader = isLeader})
-- end

function GameSocket:privateChatTo(name)
	if name == self.mCharacter.mName then
		return
	end
	self.m_strPrivateChatTarget = name

	self:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL,str="panel_chat", tab = 3})
end

function GameSocket:getRelation(name)
	self.mFriends = self.mFriends or {}
	if name and self.mFriends[name] then
		return checkint(self.mFriends[name].title)
	end
	return 0
end

function GameSocket:getPlayerInfo(name)
	if not name then return end
	local info
	self.mFriends = self.mFriends or {}
	for _,v in pairs(self.mFriends) do
		if v.name == name then
			info = v
		end
	end
	if not info then
		local pGhost=NetCC:findGhostByName(name)
		if pGhost then
			info = {
				name = pGhost:NetAttr(GameConst.net_name),
				level = pGhost:NetAttr(GameConst.net_level),
				title = 0,
				online_state = 1,
				job = pGhost:NetAttr(GameConst.net_job),
				gender = pGhost:NetAttr(GameConst.net_gender),
				guild = pGhost:NetAttr(GameConst.net_guild_name),
			}
			self.mFriends[name] = info
		end
	end
	return info
end

function GameSocket:removeChatRecentPlayer(name)
	if self.m_strPrivateChatTarget == name then
		self.m_strPrivateChatTarget = nil
	end
	for i,v in ipairs(self.chatRecent) do
		if v.name == name then
			table.remove(self.chatRecent,i)
		end
	end	
	self:dispatchEvent({name = GameMessageCode.EVENT_CHAT_RECENT,str="private"})
end

function GameSocket:addChatRecentPlayer(name)
	self.m_strPrivateChatTarget = name
	local change,exist = true,nil
	for i,v in ipairs(self.chatRecent) do
		if v.name == name then
			if i == 1 then
				change = false--此人正是第一个最近联系人不改变列表顺序
			end
			exist = i
			break;
		end
	end
	if change then
		local playerInfo = self:getPlayerInfo(name)
		if playerInfo then
			if exist then
				self.chatRecent[exist] = self.chatRecent[1]
				self.chatRecent[1] = playerInfo
			else
				table.insert(self.chatRecent,1,playerInfo)
			end
		end
		self:dispatchEvent({name = GameMessageCode.EVENT_CHAT_RECENT,str="private"})
	end
end

function GameSocket:getGuildByName(pName)
	for i=1,#self.mGuildList do
		if self.mGuildList[i].mName == pName then
			return self.mGuildList[i]
		end
	end
	return nil
end

function GameSocket:SeparateVipAndMsg(strMsg)
	local msg,localPath,httpPath,duration,flag = strMsg,nil,nil,0,0
	if string.find(msg,"<voice>") then
		print("SeparateVipAndMsg   ",msg)
		local params = string.split(msg,"|")
		if #params>=3 then
			httpPath = GameUtilSenior.FromBase64(params[2])
			flag = params[3]
			localPath = GameUtilSenior.FromBase64(params[4])
			duration = checknumber(params[5])
			msg = "语音消息"
		end
	end
	return msg,localPath,httpPath,duration,flag
end

--检测物品是否可用（每日限制）
function GameSocket:canItemUse(typeID)
	--print("canItemUse///////////////////////////////", typeID, self.itemDailyUseLimit[typeID])
	if self.itemDailyUseLimit[typeID] then
		--print("111111111111111111111111111111", self.itemDailyUseLimit[typeID].leftTimes, self.itemDailyUseLimit[typeID].totalTimes, self.itemDailyUseLimit[typeID].id)
		return self.itemDailyUseLimit[typeID].leftTimes > 0
	else
		return true
	end
end
--------------------------本地存储交易记录--------------------------

function GameSocket:storeTradeRecord(name)
	local strName = name
	if not strName then
		if GameCharacter._mainAvatar then strName = GameBaseLogic.seedName end
	end
	if strName then
		local tempjson=GameUtilSenior.encode(self.mTradeLocalRecord)
		if tempjson then
			local enjson=cc.DataBase64:EncodeData(tempjson)
			cc.UserDefault:getInstance():setStringForKey("tradeRecord"..strName, enjson)
			cc.UserDefault:getInstance():flush()
		end
	end
end

function GameSocket:checkTaskState(taskid)
	if self.mTasks[taskid] then
		local tid = math.floor(self.mTasks[taskid].mState / 10)
		local ts = math.fmod(self.mTasks[taskid].mState, 10)
		return tid, ts
	end
end

function GameSocket:checkGuiButton(name)
	-- print("///////////checkExtendShow//////////", GameUtilSenior.encode(GameSocket.mExtendButtons))
	if PLATFORM_BANSHU then --版署版本寻宝不可用
		if name == "btn_main_boss" then
			return false
		end
	end
	if self.mExtendButtons and table.indexof(self.mExtendButtons, name) then
		return true
	end
	return false
end

function GameSocket:checkFuncOpenedByID(funcid)
	if funcid and self.mAllFuncs[funcid] then
		return self.mAllFuncs[funcid].opened, self.mAllFuncs[funcid].level, self.mAllFuncs[funcid].funcname
	else
		return true
	end
end

function GameSocket:checkFuncOpened(name)
	-- print(GameUtilSenior.encode(self.mBasicButtons))
	if string.sub(name,0,5) == "main_" then
		name = "btn_"..name
	end

	if self.mBasicButtons[name] then
		return self.mBasicButtons[name].opened, self.mBasicButtons[name].level, self.mBasicButtons[name].funcname
	else
		return true
	end
end

function GameSocket:takeItemFromLottory(itemPos)
	if GameBaseLogic.IsPosInLottoryDepot(itemPos) and self:getNetItem(itemPos) then
		for pos = GameConst.ITEM_BAG_BEGIN, GameConst.ITEM_BAG_BEGIN + GameConst.ITEM_BAG_SIZE + self.mBagSlotAdd - 1 do
			if not self:getNetItem(pos) then -- 表示空位
				GameSocket:ItemPositionExchange(itemPos, pos)
				return true
			end
		end
	end
end

function GameSocket:getMonsterOwner(monId)
	return self.mMonsterOwner[monId];
end

-- 主界面右上角按钮光晕
function GameSocket:addExtendHalo(name)
	if name then
		table.insert(self.mExtendHalos, name)
	end
end

function GameSocket:checkExtendHalo(name)
	return table.indexof(self.mExtendHalos, name);
end

function GameSocket:isGroupMember(name)
	for i,v in ipairs(self.mGroupMembers) do
		if name == v.name then
			return true
		end
	end
	return false
end
----------------------------------system----------------------------------



----------------------------------socket----------------------------------

local socketdelay = nil

local function delayback()

	GameBaseLogic.disEnterButton=false

	if socketdelay then
		Scheduler.unscheduleGlobal(socketdelay)
		socketdelay=nil
	end			
end

function GameSocket:connect(__host, __port, connectType)
	local CONNECT_TYPES = {
		KUAFU	= 1,
		BACK	= 2,
	}

	if socketdelay then
		return
	end

	if self._connected==true then
		self:disconnect()
	end

	if self._connected==false then

		GameBaseLogic.disEnterButton = true

		socketdelay = Scheduler.scheduleGlobal(delayback,5.0)

		print("connect",__host,__port, connectType)

		SocketManager:startSocketAsync(__host,__port,function(result)
			self._connected=result
			if result then
				GameBaseLogic.initTime=cc.SystemUtil:getTime()
				print("connected initTime",GameBaseLogic.initTime)

				self:dispatchEvent({name=GameMessageCode.EVENT_CONNECT_ON})

				if connectType == CONNECT_TYPES.KUAFU then
					self:KuafuAuth(self.kuaFuInfo)
				elseif connectType == CONNECT_TYPES.BACK then
					self:Authenticate(103,GameBaseLogic.gameKey,0,0)
				end
			else
				GameBaseLogic.disEnterButton = false
			end
		end)
	end
end

-- function GameSocket:connect(__host, __port)

-- 	self:disconnect()

-- 	if self._connected==false then
-- 		print("connect",__host,__port)
-- 		if SocketManager:startSocket(__host,__port) then

-- 			self._connected=true

-- 			GameBaseLogic.initTime=cc.SystemUtil:getTime()
-- 			print("connected initTime",GameBaseLogic.initTime)

-- 			self:dispatchEvent({name=GameMessageCode.EVENT_CONNECT_ON})

-- 			if connectType == CONNECT_TYPES.KUAFU then
-- 				self:KuafuAuth(self.kuaFuInfo)
-- 			elseif connectType == CONNECT_TYPES.BACK then
-- 				self:Authenticate(103,GameBaseLogic.gameKey,0,0)
-- 			end
-- 		else
-- 			self:dispatchEvent({name=GameMessageCode.EVENT_CONNECT_FAILED})
-- 		end
-- 	end
-- end

function GameSocket:onMessage(mMsg)
	self:ParseMsg(mMsg)
end

function GameSocket:disconnect(reinit)
	if socketdelay then
		Scheduler.unscheduleGlobal(socketdelay)
		socketdelay=nil
	end

	GameBaseLogic.disEnterButton = false

	SocketManager:stopSocket()

	if not reinit then
		cc.NetClient:getInstance():initClient()
	end

	self._connected=false
end

function GameSocket:sendMsg(msg)
	SocketManager:sendPacket()
	-- print("sendMsg",self.mPingDelay)
	if self.mPingDelay == 0 then
		self.mPingDelay = GameBaseLogic.ClockTick
	end
end

return GameSocket:new()