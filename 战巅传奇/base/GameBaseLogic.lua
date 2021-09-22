local GameBaseLogic = {}

GameBaseLogic.sku = "hlsc"
GameBaseLogic.gameKey = "" --这个是账号
GameBaseLogic.gameTicket=""
GameBaseLogic.gameUserid = ""
GameBaseLogic.firstOpen = true
GameBaseLogic.anncVersion = "0"
GameBaseLogic.ClockTick = 0
GameBaseLogic.noSubmit = false
GameBaseLogic.lastSvr = nil
GameBaseLogic.svrRole = nil
GameBaseLogic.newRole = false
GameBaseLogic.accountId = "";

GameBaseLogic.isPlayVoice = false--是否正在播放留言

local boxTable = {
	[10099]={bindObj=10104, flag=0},
	[10100]={bindObj=10105, flag=0},
	[10101]={bindObj=10106, flag=0},
	[10102]={bindObj=10107, flag=0},
	[10103]={bindObj=10108, flag=0},

	[10104]={bindObj=10099,	flag=0},
	[10105]={bindObj=10100,	flag=0},
	[10106]={bindObj=10101,	flag=0},
	[10107]={bindObj=10102,	flag=0},
	[10108]={bindObj=10103,	flag=0},

}
GameBaseLogic.batchTable = {
	10001,10002,10008,10012,10013,10014,10048,10025,10071,
	10047,10051,10053,10055,10056,10057,10058,10059,10060,
	10061,10062,10063,10064,10065,10066,10067,10068,10074,
	10075,10076,10089,10090,10091,10092,10093,
	10099,10100,10101,10102,10103,10104,10105,10106,10107,10108,--宝箱、钥匙
	10124,10127,10128,10131,--强化石-金币
	17115,--元神令
	10079,10080,10081,
}
GameBaseLogic.PROMPT_ITEM={
	equip={},
	diss={},
}

--清理选服相关变量
function GameBaseLogic.initSvrVar()
	GameBaseLogic.serverIP=""
	GameBaseLogic.serverPort=0
	GameBaseLogic.zoneId = ""
	GameBaseLogic.zoneName = ""

	GameBaseLogic.serverList={}

	GameBaseLogic.currentSvr=nil

	GameBaseLogic.giftUrl = nil
	GameBaseLogic.renameUrl = nil
end

local _touchingRocker = false;

function GameBaseLogic.initVar()
	GameBaseLogic.job = ""
	GameBaseLogic.gender = ""
	GameBaseLogic.vip = ""
	GameBaseLogic.level = ""
	
	GameBaseLogic.firstLogin=false

	GameBaseLogic.chrName=""
	GameBaseLogic.seedName=""
	
		
	GameBaseLogic.wifiOK=false
	GameBaseLogic.allowTrade = true
		
	GameBaseLogic.lastChatMsg=""
	GameBaseLogic.bagFullFlag=false

	GameBaseLogic.appendText=""

	GameBaseLogic.wanderFight=false
	GameBaseLogic.httpLock=false
	GameBaseLogic.taskMon=""

	GameBaseLogic.panelTradeOpen = false
	
	GameBaseLogic.isChatOpen = false
	GameBaseLogic.applePaying = false

	GameBaseLogic.needLoadRes = {}
	GameBaseLogic.needLoadNum = 0
	GameBaseLogic.totalLoadNum = 0
	GameBaseLogic.downLoading = false --是否在下载资源
	GameBaseLogic.downloadAll = false --是否下载了全部资源
	GameBaseLogic.isDownloadAllState = false --是否选择了下载全部
	GameBaseLogic.isGetLoadAwarded = 0 --是否领取了奖励

	-- GameBaseLogic.shortCutShow = false
	-- GameBaseLogic.loadCache=false
	-- GameBaseLogic.betterItemPos=-999
	-- GameBaseLogic.showLeaveMap = false
	-- GameBaseLogic.showBottom = ""
	-- GameBaseLogic.bottomPos = {}
	-- GameBaseLogic.GDivContainerShow = true

	-- GameBaseLogic.relivePanelOn=false
	-- GameBaseLogic.bagFullShow=false

	-- GameBaseLogic.rockerRun=false

	-- GameBaseLogic.warHideWing=false

	GameBaseLogic.guiding = false -- 标记引导状态
	GameBaseLogic.isNewFunc = false -- 标记新功能开启状态
	GameBaseLogic.isNewSkill = false -- 标记新技能开启状态
	GameBaseLogic.equipsTipsOn = false -- 装备提示面板标记
	GameBaseLogic.isStoryLine = false
	GameBaseLogic.rechargeOn = false -- 充值面板标记

	GameBaseLogic.isJumpShow = false
	GameBaseLogic.isAutoMove = false

	GameBaseLogic.disEnterButton = false -- 选服界面的进入游戏按钮禁用
	GameBaseLogic.itemSchedule = nil
	
	GameBaseLogic.storyIndex = nil --剧情index避免重复
	GameBaseLogic.isQiangHua = nil

	GameBaseLogic.aimPos = nil

	_touchingRocker = false
end

function GameBaseLogic.cleanGame()
	-- GameCCBridge.callVoiceChat("logout_room")
	cc.AnimManager:getInstance():remAllAnimate()
	cc.SpriteManager:getInstance():removeAllFrames()
	cc.CacheManager:getInstance():releaseUnused(false)

	GameSocket:init()
	
	GameCharacter.initVar()
end

function GameBaseLogic.ExitToRelogin()

	MAIN_IS_IN_GAME = false
	
	--断开socket
	GameSocket:disconnect()

	GameBaseLogic.cleanGame()
	GameBaseLogic.initVar()
	GameBaseLogic.initSvrVar()

	if PLATFORM_TEST then
		asyncload_frames("ui/sprite/GPageServerList",".png",function ()
			display.replaceScene(GPageSignIn.new())
		end)
	else
		print("zzzz")
		--if device.platform == "windows" then
		asyncload_frames("ui/sprite/GUINewCommon",".png",function ()
			asyncload_frames("ui/sprite/GPageServerList",".png",function ()
				display.replaceScene(GPageSignIn.new()) --登陆流程
				GameCCBridge.doSdkReLogin()
			end)
		end)
		--end
	end
end

function GameBaseLogic.ExitToReSelect()

	MAIN_IS_IN_GAME = false
	print("ExitToReSelect000----------")
	GameSocket:disconnect()
	GameBaseLogic.initVar()

	GameBaseLogic.cleanGame()
	asyncload_frames("ui/sprite/GPageCharacterSelect",".png",function ()
		asyncload_frames("ui/sprite/GUINewCommon",".png",function ()
			display.replaceScene(GPageCharacterSelect.new(true)) --登陆流程
		end)
	end)
end

function GameBaseLogic.ShowExit()
	
end

function GameBaseLogic.GetMainRole()
	if not GameCharacter._mainAvatar then
		GameCharacter._mainAvatar = GameCharacter.updateAttr()
	end
	return  GameCharacter._mainAvatar
end
	
function GameBaseLogic.MainRoleLevelHigherThen(level)
	return GameBaseLogic.GetMainRole():NetAttr(GameConst.net_level) >= level
end

-- local video=ccexp.VideoPlayer:create()
-- video:setContentSize(cc.size(600,400))
-- wdg:addChild(video)
-- video:setFileName("res/cocosvideo.mp4")
-- video:play()

-- cc.Application:getInstance():openURL("http://www.cocos2d-x.org/")

-- if not self.m_webview then
-- 	self.m_webview=ccui.Widget:create()
-- 	self.m_webview:setContentSize(cc.size(600,300))
-- 	self.m_webview:setPosition(400,300)
-- 	self.m_webview:setTouchEnabled(true)
-- 	self:addChild(self.m_webview)
-- 	cc.SystemUtil:showWebView(self.m_webview,"http://wwww.baidu.com")
-- else
-- 	self.m_webview:removeFromParent()
-- 	self.m_webview=nil
-- end

function GameBaseLogic.clearHtmlText(str)
	str,n=string.gsub(str,"<[^>]*>","")
	str,_=string.gsub(str,">","")
	str,_=string.gsub(str,"<","")
	return str,n
end

function GameBaseLogic.getColor(color)
	local r,g,b
	r=bit.rshift(bit.band(color,0xFF0000),16)
	g=bit.rshift(bit.band(color,0x00FF00),8)
	b=bit.band(color,0x0000FF)
	return cc.c3b(r,g,b)
end

function GameBaseLogic.getColor4(color)
	local r,g,b
	r=bit.rshift(bit.band(color,0xFF0000),16)
	g=bit.rshift(bit.band(color,0x00FF00),8)
	b=bit.band(color,0x0000FF)
	return cc.c4b(r,g,b,255)
end

function GameBaseLogic.getColor4f(color)
	local r,g,b
	r=bit.rshift(bit.band(color,0xFF0000),16)
	g=bit.rshift(bit.band(color,0x00FF00),8)
	b=bit.band(color,0x0000FF)
	return cc.c4f(r / 255, g / 255, b / 255, 1)
end

function GameBaseLogic.getTime()
	return cc.SystemUtil:getTime()
end

function GameBaseLogic.getSkipTime()
	if not GameBaseLogic.initTime then
		return 0
	else
		return cc.SystemUtil:getTime()-GameBaseLogic.initTime
	end
	return 0
end

function GameBaseLogic.getAngle(from,to)
	local angle=math.atan((to.y-from.y)/(to.x-from.x))*(180/math.pi)
	if to.x<from.x then
		angle=angle+180
	end
	if to.y<=from.y then
		angle=angle+360
	end
	angle=angle%360

	return angle
end

function GameBaseLogic.getPixesDirection(from,to)
	local rot=GameBaseLogic.getAngle(from,to)
	if rot>=337.5 or rot<22.5 then
		return GameConst.DIR_RIGHT
	end
	if rot>=22.5 and rot<67.5 then
		return GameConst.DIR_UP_RIGHT
	end
	if rot>=67.5 and rot<112.5 then
		return GameConst.DIR_UP
	end
	if rot>=112.5 and rot<157.5 then
		return GameConst.DIR_UP_LEFT
	end
	if rot>=157.5 and rot<202.5 then
		return GameConst.DIR_LEFT
	end
	if rot>=202.5 and rot<247.5 then
		return GameConst.DIR_DOWN_LEFT
	end
	if rot>=247.5 and rot<292.5 then
		return GameConst.DIR_DOWN
	end
	if rot>=292.5 and rot<337.5 then
		return GameConst.DIR_DOWN_RIGHT
	end
	return GameConst.DIR_DOWN
end

function GameBaseLogic.getLogicDirection(from,to)
	local rot=GameBaseLogic.getAngle(from,to)
	if rot>=337.5 or rot<22.5 then
		return GameConst.DIR_RIGHT
	end
	if rot>=22.5 and rot<67.5 then
		return GameConst.DIR_DOWN_RIGHT
	end
	if rot>=67.5 and rot<112.5 then
		return GameConst.DIR_DOWN
	end
	if rot>=112.5 and rot<157.5 then
		return GameConst.DIR_DOWN_LEFT
	end
	if rot>=157.5 and rot<202.5 then
		return GameConst.DIR_LEFT
	end
	if rot>=202.5 and rot<247.5 then
		return GameConst.DIR_UP_LEFT
	end
	if rot>=247.5 and rot<292.5 then
		return GameConst.DIR_UP
	end
	if rot>=292.5 and rot<337.5 then
		return GameConst.DIR_UP_RIGHT
	end
	return GameConst.DIR_UP
end

function GameBaseLogic.getDirectionPoint(dir,num,dx,dy)
	local step = {{0,-1},{1,-1},{1,0},{1,1},{0,1},{-1,1},{-1,0},{-1,-1},}
	dx = dx + step[dir+1][1]*num
	dy = dy + step[dir+1][2]*num
	return dx,dy
end

--------------------------新的判断item类型函数--------------------------
function GameBaseLogic.isEquipMent(subType)
	return subType == GameConst.ITEM_TYPE_EQUIP
end

function GameBaseLogic.isMoney(subType)
	return subType == GameConst.ITEM_TYPE_MONEY
end

function GameBaseLogic.isDrug(subType)
	return subType == GameConst.ITEM_TYPE_DRUG
end

function GameBaseLogic.isMaterial(subType)
	return subType == GameConst.ITEM_TYPE_MATERIAL
end

function GameBaseLogic.isSkillBook(subType)
	return subType == GameConst.ITEM_TYPE_SKILLBOOK
end

function GameBaseLogic.isGem(subType)
	return subType == GameConst.ITEM_TYPE_GEM
end

function GameBaseLogic.isGift(subType)
	return subType == GameConst.ITEM_TYPE_GIFT
end

function GameBaseLogic.isChest(subType)
	return subType == GameConst.ITEM_TYPE_CHEST
end

function GameBaseLogic.isBuffItem(subType)
	return subType == GameConst.ITEM_TYPE_BUFF
end

function GameBaseLogic.isFashion(subType)
	return subType == GameConst.EQUIP_TYPE_FASHION_WEAPON or subType == GameConst.EQUIP_TYPE_FASHION_CLOTH or subType == GameConst.EQUIP_TYPE_FASHION_WING
end

function GameBaseLogic.isFashionWeapon(subType)
	return subType == GameConst.EQUIP_TYPE_FASHION_WEAPON
end

function GameBaseLogic.isFashionCloth(subType)
	return subType == GameConst.EQUIP_TYPE_FASHION_CLOTH
end

function GameBaseLogic.isFashionWing(subType)
	return subType == GameConst.EQUIP_TYPE_FASHION_WING
end

function GameBaseLogic.isScroll(subType)
	return subType == GameConst.ITEM_TYPE_SCROLL
end

function GameBaseLogic.isOther(subType)
	return subType == GameConst.ITEM_TYPE_OTHER
end
------------------------------------------------------------

function GameBaseLogic.IsEquipment(type_id)
	local id = GameSocket:getItemDefByID(type_id)
	if id then
		return id.SubType == GameConst.ITEM_TYPE_EQUIP
	end
end

--神炉四部件
function GameBaseLogic.IsFurnaceEquipment(type_id, id)
	if (not id) and type_id then
		id = GameSocket:getItemDefByID(type_id)
	end
	if id and id.SubType == GameConst.ITEM_TYPE_EQUIP then
		if id.mEquipType == GameConst.EQUIP_TYPE_JADE_PENDANT or id.mEquipType == GameConst.EQUIP_TYPE_SHIELD or id.mEquipType == GameConst.EQUIP_TYPE_DRAGON_HEART or id.mEquipType == GameConst.EQUIP_TYPE_WOLFANG then
			return true
		end
	end
end

function GameBaseLogic.IsViceEquipment(type_id, id)
	if (not id) and type_id then
		id = GameSocket:getItemDefByID(type_id)
	end
	if id and id.SubType == GameConst.ITEM_TYPE_EQUIP then
		if id.mEquipType >= GameConst.EQUIP_TYPE_JADE_PENDANT and id.mEquipType <= GameConst.EQUIP_TYPE_ACHIEVE_MEDAL then
			return true
		end
	end
end

function GameBaseLogic.IsSameFashion(type_id,pos,id)
	if (not id) and type_id and pos then
		id = GameSocket:getItemDefByID(type_id)
	end
	if id and id.mEquipType*-2 == pos then
		return true
	end
end

function GameBaseLogic.IsPosInDepot(pos)
	return (pos and pos >= GameConst.ITEM_DEPOT_BEGIN and pos < GameConst.ITEM_DEPOT_END)
end

function GameBaseLogic.IsPosInBag(pos)
	return (pos and pos >= GameConst.ITEM_BAG_BEGIN and pos < GameConst.ITEM_BAG_MAX)
end
function GameBaseLogic.IsPosInLottoryDepot(pos)
	return (pos and pos >= GameConst.ITEM_LOTTERYDEPOT_BEGIN and pos < GameConst.ITEM_LOTTERYDEPOT_BEGIN+GameConst.ITEM_LOTTERYSIZE)
end

--index=1:攻击宝石  index=2：物防宝石  index=3：魔防宝石  index=4:生命宝石
function GameBaseLogic.getTypeGems(index)
	local result = {}
	for i,v in pairs(GameSocket.mGemItems) do
		-- if index==1 and v.mTypeID>=17020 and v.mTypeID<=17031 then
		-- 	table.insert(result,1,v)
		-- elseif index==2 and v.mTypeID>=17032 and v.mTypeID<=17043 then
		-- 	table.insert(result,1,v)
		-- elseif index==3 and v.mTypeID>=17044 and v.mTypeID<=17055 then
		-- 	table.insert(result,1,v)
		-- elseif index==4 and v.mTypeID>=17056 and v.mTypeID<=17067 then
		-- 	table.insert(result,1,v)
		-- end
		table.insert(result,1,v)
	end
	GameBaseLogic.getGemNums()

	-- result = GameBaseLogic.sortGemAscend(result)
	return result
end

--升序排列宝石
function GameBaseLogic.sortGemAscend(gemTable)
	local result = {}
	for i=1,#gemTable do
		local max=gemTable[i]
		local temp = {}
		for j=i,#gemTable do
			if gemTable[j].mTypeID<=max.mTypeID then
				temp = max
				max = gemTable[j]
				gemTable[j] = temp
			end
		end
		result[i] = max
	end
	return result
end

--统计每个等级宝石数量
function GameBaseLogic.getGemNums()
	local result = {}
	for i,v in pairs(GameSocket.mGemItems) do
		local key = tostring(v.mTypeID)
		if result[key] then
			result[key] = result[key]+1
		else
			result[key] = 1
		end
	end
	return result
end


-- local equip_fight = {
-- 	[GameConst.JOB_ZS] = {mAddPower = ,mMaxHp=, mMaxMp=, mDC=, mDCMax=, mMC=, mMCMax=, mSC=, mSCMax, mAC=, mACMax=, mMAC=, mMACMax=, mBaojiProb= ,mBaojiPres= ,mAccuracy= ,mDodge= ,mLuck= , mTenacity},
-- 	[GameConst.JOB_FS] = {mAddPower = ,mMaxHp=, mMaxMp=, mDC=, mDCMax=, mMC=, mMCMax=, mSC=, mSCMax, mAC=, mACMax=, mMAC=, mMACMax=, mBaojiProb= ,mBaojiPres= ,mAccuracy= ,mDodge= ,mLuck= , mTenacity},
-- 	[GameConst.JOB_DS] = {mAddPower = ,mMaxHp=, mMaxMp=, mDC=, mDCMax=, mMC=, mMCMax=, mSC=, mSCMax, mAC=, mACMax=, mMAC=, mMACMax=, mBaojiProb= ,mBaojiPres= ,mAccuracy= ,mDodge= ,mLuck= , mTenacity},
-- }



function GameBaseLogic.getEquipFight(type_id)
	local fight = 0
	local itemdef = GameSocket:getItemDefByID(type_id)
	if itemdef then
		-- fight = 
	end
	return fight
end

function GameBaseLogic.isBetterInAvatar(pos)
	local isInAvatar = false
	local mItems = GameSocket.mItems
	local type_id = 0
	local itemdef = nil
	-- local MainAvatar = CCGhostManager:getMainAvatar()
	local tempItem
	if GameUtilSenior.isTable(pos) then
		type_id = pos.mTypeID
	elseif GameUtilSenior.isNumber(pos) then
		local tempItem = GameSocket:getNetItem(pos)
		isInAvatar = GameBaseLogic.IsPosInAvatar(pos)
		if tempItem then
			type_id = tempItem.mTypeID
		end
	end
	
	itemdef = GameSocket:getItemDefByID(type_id)
	if not itemdef then
		return GameConst.ITEM_WORSE_SELF
	end
	-- print("++",GameBaseLogic.IsEquipment(type_id),GameBaseLogic.IsPosInAvatar(pos))
	if GameBaseLogic.IsEquipment(type_id) and not isInAvatar then
		if GameBaseLogic.IsWeapon(type_id) then
			return GameBaseLogic.CompareItem(pos,GameConst.ITEM_WEAPON_POSITION)
		elseif GameBaseLogic.IsCloth(type_id) then
			return GameBaseLogic.CompareItem(pos,GameConst.ITEM_CLOTH_POSITION)
		elseif GameBaseLogic.IsHat(type_id) then
			return GameBaseLogic.CompareItem(pos,GameConst.ITEM_HAT_POSITION)
		elseif GameBaseLogic.IsRing(type_id) then -- 修改戒指好坏的比较逻辑

			local better1, pos1 = GameBaseLogic.CompareItem(pos,GameConst.ITEM_RING1_POSITION)

			local better2, pos2 = GameBaseLogic.CompareItem(pos,GameConst.ITEM_RING2_POSITION)
			-- print(better1, pos1, better2, pos2)
			if pos1 or pos2 then
				if pos1 then
					return GameConst.ITEM_BETTER_SELF, pos1, pos2
				elseif pos2 then
					return GameConst.ITEM_BETTER_SELF, pos2, pos1
				end
			else
				return ((better1 < better2) and better1) or better2
			end

		elseif GameBaseLogic.IsGlove(type_id) then  -- 修改护腕好坏的比较逻辑

			local better1, pos1 = GameBaseLogic.CompareItem(pos,GameConst.ITEM_GLOVE1_POSITION)

			local better2, pos2 = GameBaseLogic.CompareItem(pos,GameConst.ITEM_GLOVE2_POSITION)
			-- print(better1, pos1, better2, pos2)
			if pos1 or pos2 then
				if pos1 then
					return GameConst.ITEM_BETTER_SELF, pos1, pos2
				elseif pos2 then
					return GameConst.ITEM_BETTER_SELF, pos2, pos1
				end
			else
				return ((better1 < better2) and better1) or better2
			end
		elseif GameBaseLogic.IsNecklace(type_id) then
			return GameBaseLogic.CompareItem(pos,GameConst.ITEM_NICKLACE_POSITION)
		elseif GameBaseLogic.IsBelt(type_id) then
			return GameBaseLogic.CompareItem(pos,GameConst.ITEM_BELT_POSITION)
		elseif GameBaseLogic.IsBoot(type_id) then
			return GameBaseLogic.CompareItem(pos,GameConst.ITEM_BOOT_POSITION)
		elseif GameBaseLogic.IsWing(type_id) then
			return GameBaseLogic.CompareItem(pos,GameConst.ITEM_WING_POSITION)
		elseif GameBaseLogic.IsSoul(type_id) then
			return GameBaseLogic.CompareItem(pos,GameConst.ITEM_GUANZHI_POSITION)
		elseif GameBaseLogic.IsFashion(type_id) then
			return GameBaseLogic.CompareItem(pos,GameConst.ITEM_FASHION_POSITION)
		elseif GameBaseLogic.isBaoDing(type_id) then
			return GameBaseLogic.CompareItem(pos,GameConst.ITEM_BAODING_POSITION)
		end
		--其他装备比较
		local id = GameSocket:getItemDefByID(type_id)
		if id then
			local otherComparePos = {
				101,
				102,
				103,
				104,
				105,
				106,
				107,
				108,
				109,
				110,
				201,
				202,
				203,
				301,
				302,
				303,
				304,
				305,
				306,
				307,
				308,
				309,
				310,
				311,
				312,
				351,
				356,
				352,
				354,
				360,
				359,
				355,
				362,
				358,
				357,
				361,
				353,
				31,
				32,
				33,
				34,
				35,
				36,
				37,
				38,
				11,
				12,
				13,
				14,
				15,
				16
			}
			for i=1,#otherComparePos,1 do
				if otherComparePos[i]==id.mEquipType then
					return GameBaseLogic.CompareItem(pos,-2*otherComparePos[i])
				end
			end
		end
	end
	return GameConst.ITEM_NONE_SELF
end

function GameBaseLogic.getFightPoint(defOrAvatar,specialAvatar, job, mUpdLevel)
	local pointTable = {
		[100] = {
			mAddPower = 50,
			mMaxHp = 50,
			mMaxMp = 0,
			mDC = 10000,
			mDCMax = 5000,
			mMC = 0,
			mMCMax = 0,
			mSC = 0,
			mSCMax = 0,
			mAC = 20000,
			mACMax = 10000,
			mMAC = 20000,
			mMACMax = 10000,
			mBaojiProb = 60000,
			critProb = 60000,
			mBaojiPres = 10000,
			critPoint = 10000,
			mAccuracy = 0,
			mDodge = 0,
			mLuck = 4000000,
			tenacity = 30000,
		},
		[101] = {
			mAddPower = 2400,
			mMaxHp = 4800,
			mMaxMp = 0,
			mDC = 0,
			mDCMax = 0,
			mMC = 32000,
			mMCMax = 16000,
			mSC = 0,
			mSCMax = 0,
			mAC = 7000,
			mACMax = 5000,
			mMAC = 7000,
			mMACMax = 5000,
			mBaojiProb = 60000,
			critProb = 60000,
			mBaojiPres = 10000,
			critPoint = 10000,
			mAccuracy = 0,
			mDodge = 0,
			mLuck = 4000000,
			tenacity = 30000
		},
		[102] = {
			mAddPower = 1500,
			mMaxHp = 3000,
			mMaxMp = 0,
			mDC = 0,
			mDCMax = 0,
			mMC = 0,
			mMCMax = 0,
			mSC = 32000,
			mSCMax = 16000,
			mAC = 7000,
			mACMax = 5000,
			mMAC = 7000,
			mMACMax = 5000,
			mBaojiProb = 60000,
			critProb = 60000,
			mBaojiPres = 10000,
			critPoint = 10000,
			mAccuracy = 0,
			mDodge = 0,
			mLuck = 4000000,
			tenacity = 30000
		}
	}
	
	local pointSpecialTable = {
		[100] = {
			mSpecialAC = 20000,
			mSpecialACMax = 10000,
			mSpecialMAC = 20000,
			mSpecialMACMax = 10000,
			mSpecialDC = 10000,
			mSpecialDCMax = 5000,
			mSpecialMC = 10000,
			mSpecialMCMax = 5000,
			mSpecialSC = 10000,
			mSpecialSCMax = 5000,
			mSpecialLuck = 4000000,
			mSpecialCurse = 1000000,
			mSpecialAccuracy = 1000000,
			mSpecialDodge = 1000000,
			mSpecialAntiMagic = 100,
			mSpecialAntiPoison = 100,
			mSpecialMax_hp = 500,
			mSpecialMax_mp = 500,
			mSpecialMax_hp_pres = 100,
			mSpecialMax_mp_pres = 100,
			mSpecialHolyDam = 0.001
		}
	}
	local updAttrs = {}
	if mUpdLevel and mUpdLevel > 0 then
		local updId = job * 10000 + defOrAvatar.mEquipType * 100 + mUpdLevel
		local uid = GameSocket.mUpgradeDesp[updId]
		if uid then
			updAttrs = {
				mDC = uid.mDC,
				mDCMax = uid.mDCMax,
				mMC = uid.mMC,
				mMCMax = uid.mMCMax,
				mSC = uid.mSC,
				mSCMax = uid.mSCMax,
				mAC = uid.mAC,
				mACMax = uid.mACMax,
				mMAC = uid.mMAC,
				mMACMax = uid.mMACMax,
			}
		end
	end

	local point = 0
	for k,v in pairs(pointTable[job]) do
		if defOrAvatar[k] then
			point = point + (defOrAvatar[k] + (updAttrs[k] or 0)) * v
		end
	end
	for k,v in pairs(pointSpecialTable[job]) do
		if specialAvatar[k] then
			point = point + (specialAvatar[k]) * v
		end
	end
	return point
end

function GameBaseLogic.CompareItem(posBag, posAvatar, itemDef)
	local mItems = GameSocket.mItems
	local itemBag = nil
	local posBagLevel, posAvatarLevel

	if GameUtilSenior.isNumber(posBag) and mItems[posBag] then
		itemBag = GameSocket:getItemDefByID(mItems[posBag].mTypeID)
		posBagLevel = GameSocket:getNetItem(posBag).mLevel
	elseif GameUtilSenior.isTable(posBag) then 
		itemBag = GameSocket:getItemDefByID(posBag.mTypeID)
		posBagLevel = posBag.mLevel
	else
		itemBag = itemDef
	end

	if itemBag == nil then
		return GameConst.ITEM_UNUSE_SELF
	end

	local job = GameCharacter._mainAvatar:NetAttr(GameConst.net_job)
	if mItems[posAvatar] then
		posAvatarLevel = GameSocket:getNetItem(posAvatar).mLevel
		local itemAvatar = GameSocket:getItemDefByID(mItems[posAvatar].mTypeID)
		-- print("itemAvatar", GameUtilSenior.encode(itemAvatar))
		if itemBag and itemAvatar then
			if (itemBag.mJob == 0 or itemBag.mJob == job)
				and (itemBag.mGender == 0 or itemBag.mGender == GameCharacter._mainAvatar:NetAttr(GameConst.net_gender) ) then
				
				--if GameBaseLogic.getFightPoint(itemBag, job, posBagLevel) > GameBaseLogic.getFightPoint(itemAvatar, job, posAvatarLevel) then
				--print("============GameBaseLogic.getFightPoint(itemBag,mItems[posBag], job, posBagLevel)",posBag,posAvatar,itemBag.mName,GameBaseLogic.getFightPoint(itemBag,mItems[posBag], job, posBagLevel),GameBaseLogic.getFightPoint(itemAvatar,mItems[posAvatar], job, posAvatarLevel))
				if GameBaseLogic.getFightPoint(itemBag,mItems[posBag], job, posBagLevel) > GameBaseLogic.getFightPoint(itemAvatar,mItems[posAvatar], job, posAvatarLevel) then
				-- if itemBag.mNeedParam > itemAvatar.mNeedParam then
					return GameConst.ITEM_BETTER_SELF, posAvatar
				elseif itemBag.mNeedParam > itemAvatar.mNeedParam then
					return GameConst.ITEM_BETTER_SELF, posAvatar
				elseif itemBag.mNeedParam == itemAvatar.mNeedParam then
					return GameConst.ITEM_NONE_SELF
				end
				return GameConst.ITEM_WORSE_SELF
			end
			return GameConst.ITEM_UNUSE_SELF
		end
		return GameConst.ITEM_WORSE_SELF
	else
		if (itemBag.mJob == 0 or itemBag.mJob == job)
			and (itemBag.mGender == 0 or itemBag.mGender == GameCharacter._mainAvatar:NetAttr(GameConst.net_gender) ) then
			return GameConst.ITEM_BETTER_SELF, posAvatar
		end
		return GameConst.ITEM_UNUSE_SELF
	end
end

local EQUIP_TAG = {
	WEAPON = 1,CLOTH = 2,HAT = 3,RING = 4,GLOVE = 5,NECKLACE = 6,
	BELT = 7,BOOT = 8,WING = 9,FASHION = 10,SOUL = 11,ALL = 12,
}

local checkTab = {
	[EQUIP_TAG.WEAPON]		= "IsWeapon",
	[EQUIP_TAG.CLOTH]		= "IsCloth", 
	[EQUIP_TAG.HAT]			= "IsHat", 	
	[EQUIP_TAG.RING]		= "IsRing", 	
	[EQUIP_TAG.GLOVE]		= "IsGlove", 
	[EQUIP_TAG.NECKLACE]	= "IsNecklace", 
	[EQUIP_TAG.BELT]		= "IsBelt", 	
	[EQUIP_TAG.BOOT]		= "IsBoot", 	
	[EQUIP_TAG.WING]		= "IsWing", 	
	[EQUIP_TAG.FASHION]		= "IsFashion", 
	[EQUIP_TAG.SOUL]		= "IsSoul", 	
	-- [EQUIP_TAG.ALL] = "IsEquipment", 	
}

function GameBaseLogic.getEquipmentType(type_id)
	if GameBaseLogic.IsEquipment(type_id) then
		for i,v in ipairs(checkTab) do
			if game[v](type_id) then
				return i
			end
		end
		return false
	end
	return false
end

local qualityColor = {
	[0] = 0xfff7ec,
	[1] = 0x36de00,
	[2] = 0x1eb8ff,
	[3] = 0xff1fec,
	[4] = 0xff0a00,
	[5] = 0xfff843,
}

function GameBaseLogic.getItemColor(quality)
	return GameBaseLogic.getColor(qualityColor[quality] or qualityColor[0])
end

function GameBaseLogic.getItemColor4f(quality)
	return GameBaseLogic.getColor4f(qualityColor[quality] or qualityColor[1])
end

function GameBaseLogic.isEquipMatchGender(type_id, gender)
	local itemdef = GameSocket:getItemDefByID(type_id)
	if not itemdef then return end

	return itemdef.mGender == 0 or itemdef.mGender == gender
end

function GameBaseLogic.isEquipMatchJob(type_id, job)
	local itemdef = GameSocket:getItemDefByID(type_id)
	if not itemdef then return end

	return itemdef.mJob == 0 or itemdef.mJob == job
end

function GameBaseLogic.isEquipMatchType(type_id, etype)
	return etype == GameBaseLogic.getEquipmentType(type_id)
end

function GameBaseLogic.IsDissipative(type_id)
	if type_id > 20000000 and type_id < 29999999 then
		return true
	else
		return false
	end
end
--药品
function GameBaseLogic.IsDrug(type_id, itemdef)
	itemdef = itemdef or GameSocket:getItemDefByID(type_id)
	if not itemdef then return false end
	-- if itemdef.SubType == 3 then
	-- 	return true
	-- end
	return GameBaseLogic.isDrug(itemdef.SubType)
end
--材料
function GameBaseLogic.IsStuff(type_id)
	local itemdef = GameSocket:getItemDefByID(type_id)
	if not itemdef then return false end
	-- if type_id > 20000000 and type_id < 29999999 and itemdef.SubType ~= 8 then
	-- 	return true
	-- else
	-- 	return false
	-- end
	return GameBaseLogic.isMaterial(itemdef.SubType)
end

-- 金币
function GameBaseLogic.isCoin(type_id)
	-- body
	return type_id == 40000003 or type_id == 40000004
end

function GameBaseLogic.getPickState(type_id)
	-- print("pick---",type_id,G_AutoPickDrug,G_AutoPickStaff,G_AutoPickCoin,G_AutoPickEquip,G_AutoPickOther)
	if GameBaseLogic.IsDrug(type_id) then
		return G_AutoPickDrug > 0
	end

	if GameBaseLogic.IsStuff(type_id) then
		return G_AutoPickStaff > 0
	end

	if GameBaseLogic.isCoin(type_id) then
		return G_AutoPickCoin > 0 
	end

	if GameBaseLogic.IsEquipment(type_id) then
		local itemdef = GameSocket:getItemDefByID(type_id)
		if itemdef and(G_AutoPickEquipLevel>=100 and G_AutoPickEquipLevel<=itemdef.mNeedZsLevel*10+90  or G_AutoPickEquipLevel<100 and G_AutoPickEquipLevel<= itemdef.mNeedParam) then -- 判断装备等级
			return G_AutoPickEquip > 0
		end
		return false
	end
	return G_AutoPickOther >0
end

function GameBaseLogic.IsWeapon(type_id)
	local id = GameSocket:getItemDefByID(type_id)
	if id then
		return id.mEquipType == GameConst.EQUIP_TYPE_WEAPON
	end
end

function GameBaseLogic.isBaoDing(type_id)
	local id = GameSocket:getItemDefByID(type_id)
	if id then
		return id.mEquipType == GameConst.EQUIP_TYPE_BAODING
	end
end

function GameBaseLogic.IsCloak(type_id)
	if type_id > 120000 and type_id < 129999 then
		return true
	else
		return false
	end
end

function GameBaseLogic.IsCloth(type_id)
	local id = GameSocket:getItemDefByID(type_id)
	if id then
		return id.mEquipType == GameConst.EQUIP_TYPE_CLOTH
	end
end

function GameBaseLogic.IsHat(type_id)
	local id = GameSocket:getItemDefByID(type_id)
	if id then
		return id.mEquipType == GameConst.EQUIP_TYPE_HAT
	end
end

function GameBaseLogic.IsNecklace(type_id)
	local id = GameSocket:getItemDefByID(type_id)
	if id then
		return id.mEquipType == GameConst.EQUIP_TYPE_NICKLACE
	end
end

function GameBaseLogic.IsGlove(type_id)
	local id = GameSocket:getItemDefByID(type_id)
	if id then
		return id.mEquipType == GameConst.EQUIP_TYPE_GLOVE
	end
end

function GameBaseLogic.IsRing(type_id)
	local id = GameSocket:getItemDefByID(type_id)
	if id then
		return id.mEquipType == GameConst.EQUIP_TYPE_RING
	end
end

function GameBaseLogic.IsBelt(type_id)
	local id = GameSocket:getItemDefByID(type_id)
	if id then
		return id.mEquipType == GameConst.EQUIP_TYPE_BELT
	end
end

function GameBaseLogic.IsBoot(type_id)
	local id = GameSocket:getItemDefByID(type_id)
	if id then
		return id.mEquipType == GameConst.EQUIP_TYPE_BOOT
	end
end

function GameBaseLogic.IsMedal(type_id)--是否勋章
	if type_id > 110000 and type_id < 119999 then
		return true
	else
		return false
	end
end

function GameBaseLogic.IsWing(type_id)
	if type_id > 130000 and type_id < 139999 then
		return true
	else
		return false
	end
end

function GameBaseLogic.IsFashion(type_id)
	if type_id > 150000 and type_id < 159999 then
		return true
	else
		return false
	end
end

function GameBaseLogic.IsSoul(type_id)
	if type_id > 110000 and type_id < 119999 then
		return true
	else
		return false
	end
end

function GameBaseLogic.IsShield(type_id) -- 护盾
	local result, level
	if type_id >= 190001 and type_id <= 190010 then
		result = true
		level = type_id - 190000
	end
	return result, level
end

function GameBaseLogic.IsJewel(type_id) -- 宝石
	local result, level
	if type_id >= 200001 and type_id <= 200012 then
		result = true
		level = type_id - 200000
	end
	return result, level
end

function GameBaseLogic.IsCrittoken(type_id) -- 暴击令牌
	local result, level
	if type_id >= 210001 and type_id <= 210024 then
		result = true
		level = type_id - 210000
	end
	return result, level
end

function GameBaseLogic.IsPosInAvatar(pos)
	if pos then
		if pos > -999 and pos < 0 then
			return true
		else
			return false
		end
	end
	return false
end

function GameBaseLogic.IsPassiveSkill(skill_type) --被动技能
	if skill_type == GameConst.SKILL_TYPE_JiChuJianShu or 
		skill_type == GameConst.SKILL_TYPE_GongShaJianShu or 
		skill_type == GameConst.SKILL_TYPE_JinShenLiZhanFa then
		-- if skill_type == GameConst.SKILL_TYPE_YiBanGongJi and GameSocket.mCharacter.mJob == 100 then
		-- 	return false
		-- else
			return true
		-- end
	end
	return false
end

function GameBaseLogic.clearNumStr(str)
	local last,index = string.gsub(str,"%d","")
	return last
end

function GameBaseLogic.checkBagItem(type_id) ---验证背包是否有指定物品
	for pos = 0, GameConst.ITEM_BAG_SIZE + GameSocket.mBagSlotAdd - 1 do 
		local netItem = GameSocket:getNetItem(pos)
		if netItem and netItem.mTypeID == type_id then
			return true
		end
	end
end

function GameBaseLogic.checkMainTaskPaused()
	if GameBaseLogic.guiding or GameBaseLogic.isNewFunc or GameBaseLogic.isNewSkill or GameBaseLogic.equipsTipsOn or GameBaseLogic.isStoryLine or GameBaseLogic.isQiangHua or GameBaseLogic.rechargeOn then
		-- print(GameBaseLogic.guiding , GameBaseLogic.isNewFunc , GameBaseLogic.isNewSkill , GameBaseLogic.equipsTipsOn, GameBaseLogic.isStoryLine, GameBaseLogic.isQiangHua, GameBaseLogic.rechargeOn)
		-- print("checkMainTaskPausedcheckMainTaskPausedcheckMainTaskPausedcheckMainTaskPaused")
		return true
	end
end

-- function GameBaseLogic.recordBoxMatch()
-- 	for k,v in pairs(boxTable) do
-- 		v.flag=0
-- 	end
-- 	for k,v in pairs(GameSocket.bagItems) do
-- 		if boxTable[v.mTypeID] then
-- 			boxTable[v.mTypeID].flag=1
-- 		end
-- 	end
-- 	GameBaseLogic.enterGameBoxMatch()
-- end

-- function GameBaseLogic.enterGameBoxMatch()
-- 	local haveRed = false
-- 	for i=10099,10108 do
-- 		local state = GameBaseLogic.checkBoxMatch(i)
-- 		if state then haveRed=state end
-- 	end
-- 	if not haveRed then
-- 		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_REMOVE_REDPOINT, lv = 51,index = 1})
-- 	end
-- end

function GameBaseLogic.checkBoxMatch(typeid)
-- 	if typeid<10099 and typeid>10108 then return false end--不是宝箱或者钥匙
-- 	if boxTable[typeid] and boxTable[typeid].flag==1 and boxTable[boxTable[typeid].bindObj].flag==1 then
-- 		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_SHOW_REDPOINT, lv = 51,index = 1})
-- 		return true	
-- 	end
	return false
end

function GameBaseLogic.setQiangHuaTable(data)
	if not data then return end
	GameSocket.equipTable={}
	GameSocket.equipTable=data
	-- print(GameUtilSenior.encode(GameSocket.equipTable),"======================55555")
	GameBaseLogic.setQiangHuaEffect(data)
end

-- function GameBaseLogic.getEquipQiangHuaLev(typeid)
-- 	if not GameSocket.equipTable then
-- 		return 0 
-- 	else
-- 		local index = nil
-- 		if typeid>=20001 and typeid<=20046 then--武器
-- 			index = "-4"
-- 		elseif typeid>=30001 and typeid<=35043 then--衣服
-- 			index = "-6"
-- 		elseif typeid>=40001 and typeid<=40043 then--头盔
-- 			index = "-8"
-- 		elseif typeid>=70001 and typeid<=70043 then--项链
-- 			index = "-14"
-- 		elseif typeid>=60001 and typeid<=60043 then--护腕
-- 			if GameSocket.equipTable["-12"]>GameSocket.equipTable["-13"] then
-- 				index = "-12"
-- 			else
-- 				index = "-13"
-- 			end
-- 		elseif typeid>=50001 and typeid<=50043 then--戒指
-- 			if GameSocket.equipTable["-10"]>GameSocket.equipTable["-11"] then
-- 				index = "-10"
-- 			else
-- 				index = "-11"
-- 			end
-- 		elseif typeid>=90005 and typeid<=90043 then--腰带
-- 			index = "-18"
-- 		elseif typeid>=100005 and typeid<=100043 then--鞋子
-- 			index = "-20"
-- 		end
-- 		if index then
-- 			return GameSocket.equipTable[index]
-- 		else
-- 			return 0
-- 		end
-- 	end
-- end

function GameBaseLogic.stopAutoFight()
	if GameCharacter._mainAvatar then GameCharacter._mainAvatar:clearAutoMove() end
	GameCharacter._moveToNearAttack = false
	GameCharacter.stopAutoFight()
end

--主线是否可用
function GameBaseLogic.checkMainTaskUsable()
	local tid, ts = GameSocket:checkTaskState(1000)
	if tid and ts > 1 then
		return true
	end
end

--强化等级对应的素材
local resTable = {
	["80"] =  {resPre=1000300,resLater=1000301},
	["110"] = {resPre=1000400,resLater=1000401},
	["140"] = {resPre=1000500,resLater=1000501},
	["170"] = {resPre=1000600,resLater=1000601},
	["190"] = {resPre=1000700,resLater=1000701},
	["200"] = {resPre=1000800,resLater=1000801},
}
function GameBaseLogic.getQiangHuaResid(level)
	if resTable[tostring(level)] then
		return resTable[tostring(level)]
	else
		return nil
	end
end

--计算强化特特效显示
function GameBaseLogic.setQiangHuaEffect(data)
	local lowLev = 300
	for i,v in pairs(data) do
		if v<=lowLev then
			lowLev = v
		end
	end
	GameCharacter.handleQiangHuaChange(GameBaseLogic.getLow(lowLev))
end

function GameBaseLogic.getLow(level)
	if not level then return end
	local resid = 0
	if level>=200 then
		resid =200
	elseif level>=190 then
		resid =190
	elseif level>=170 then
		resid =170
	elseif level>=140 then
		resid =140
	elseif level>=110 then
		resid =110
	elseif level>=80 then
		resid =80
	end
	return resid
end

local type_str = {
	[1] = "武器",
	[2] = "衣服",
	[3] = "头盔",
	[4] = "项链",
	[5] = "手镯",
	[6] = "戒指",
	[7] = "腰带",
	[8] = "鞋子",
}

function GameBaseLogic.getItemType(typeid)
	local strType = "道具"
	if GameBaseLogic.IsEquipment(typeid) then
		strType = "装备"
		local b = math.floor((typeid % 100)/10)
		strType = type_str[b] or strType
	end
	return strType
end

local head_key ={"new_main_ui_head.png","head_fzs","head_mfs","head_ffs","head_mds","head_fds"}

function GameBaseLogic.getHeadRes(job, gender)
	local id = 1
	if job and gender then
		id = (job - 100) * 2 + gender - 199
	end
	return head_key[id]
end

-- 只有药品和回城石，传送石，随机传送石能放入快捷设置
local shortCutItems = {
	32010001, 32010002, 32010003, 25000068, 25000069, 25000070, 25000071
}
--物品能否快捷设置
function GameBaseLogic.checkShortCutItem(typeid)
	local itemdef = GameSocket:getItemDefByID(typeid)
	if itemdef then
		return GameBaseLogic.IsDrug(typeid, itemdef) or table.indexof(shortCutItems, typeid)
	end

	return false

	-- return GameBaseLogic.IsDissipative(typeid)
end

-- 战士技能
function GameBaseLogic.isWarriorSkill(skill_type)
	return skill_type > GameConst.SKILL_TYPE_YiBanGongJi and skill_type < GameConst.SKILL_TYPE_ZhuRiJianFa
end
-- 法师技能
function GameBaseLogic.isWizardSkill(skill_type)
	return skill_type > GameConst.SKILL_TYPE_HuoQiuShu and skill_type < GameConst.SKILL_TYPE_LiuXingHuoYu
end
--道士技能
function GameBaseLogic.isTaoistSkill(skill_type)
	return skill_type > GameConst.SKILL_TYPE_ZhiYuShu and skill_type < GameConst.SKILL_TYPE_ZhaoHuanYueLing
end

function GameBaseLogic.getSkillDesp(skill_type)
	for _,v in ipairs(GameSocket.m_skillsDesp) do
		if v.skill_id == skill_type then
			--攻速调整时也调整普通攻击技能的CD时间
			if v.skill_id==100 or v.skill_id==103 or v.skill_id==104 then
				local speed = GameCharacter._mainAvatar:NetAttr(GameConst.net_attack_speed)
				if speed>0 then
					speed = (speed+10000)/10000
				else
					speed = 1
				end
				v.mSKillCD = v.mSKillCD/speed
				v.mPublicCD = v.mPublicCD/speed
			end
			return v
		end
	end
end

-- 魔法是否充足
function GameBaseLogic.checkMpEnough(skill_type)
	local nsd = GameBaseLogic.getSkillDesp(skill_type)
	if nsd and GameCharacter._mainAvatar then
		return GameCharacter._mainAvatar:NetAttr(GameConst.net_mp) >= nsd.mConsumeMp
	end
end

function GameBaseLogic.getSkillCDTime(skill_type)
	local nsd = GameBaseLogic.getSkillDesp(skill_type)
	if nsd then
		-- print("GameBaseLogic.getSkillCDTime", GameUtilSenior.encode(nsd))
		return nsd.mSKillCD, nsd.mPublicCD
	end
end

function GameBaseLogic.checkSkillCD(skill_type, alert)
	if GameBaseLogic.IsSwitchSkill(skill_type) then
		return true
	end

	local mSkillCD, mPublicCD = GameBaseLogic.getSkillCDTime(skill_type)
	if mSkillCD and mPublicCD then
		local time = GameBaseLogic.getTime()
		--  公共cd检测
		if not GameSocket.mPublicCDTime[mPublicCD] then
			GameSocket.mPublicCDTime[mPublicCD] = 0
		end
		if time - mPublicCD >= GameSocket.mPublicCDTime[mPublicCD] then -- 公共cd满足
			-- 自身cd检测
			if not GameSocket.mSkillCDTime[mSkillCD] then
				GameSocket.mSkillCDTime[mSkillCD] = 0
			end
			--print("GameBaseLogic.checkSkillCD", time - mSkillCD,mSkillCD,GameSocket.mSkillCDTime[skill_type])
			if time - mSkillCD >= GameSocket.mSkillCDTime[skill_type] then -- 自身cd满足
				-- print("GameBaseLogic.checkSkillCD", skill_type, time, mPublicCD, GameSocket.mPublicCDTime[mPublicCD], mSkillCD, GameSocket.mPublicCDTime[mSkillCD])
				return true
			else
				if alert and DEBUG==1 then
					--GameSocket:alertLocalMsg("技能"..skill_type.."在CD中！", "alert")
					GameSocket:alertLocalMsg("技能在CD中！", "alert")
				end
			end
		else
			if alert and DEBUG==1 then
				print(GameSocket.mPublicCDTime[mPublicCD])
				--GameSocket:alertLocalMsg("技能"..skill_type.."在公共CD中！", "alert")
				GameSocket:alertLocalMsg("技能在公共CD中！", "alert")
			end
		end
	else
		if alert and DEBUG==1 then
			--GameSocket:alertLocalMsg("无法获取技能"..skill_type.."的CD时间！", "alert")
			GameSocket:alertLocalMsg("无法获取技能的CD时间！", "alert")
		end
	end
	return false
end

-------是否被动技能，被动技能不可设置到转盘 
-- (skill_type == GameConst.SKILL_TYPE_JiChuJianShu or skill_type == GameConst.SKILL_TYPE_JinShenLiZhanFa)
function GameBaseLogic.IsPassiveSkill(skill_type) --被动技能
	local nsd = GameBaseLogic.getSkillDesp(skill_type)
	if nsd and nsd.mCastWay == 3 then
		return true
	end
end

--是否开关技能
-- local switch_skills = {
	
-- }

function GameBaseLogic.IsSwitchSkill(skill_type)
	return skill_type == GameConst.SKILL_TYPE_CiShaJianShu or skill_type == GameConst.SKILL_TYPE_BanYueWanDao
end

function GameBaseLogic.IsLieHuoTypeSkill(skill_type)
	return skill_type == GameConst.SKILL_TYPE_LieHuoJianFa 
		or skill_type == GameConst.SKILL_TYPE_PoTianZhan 
		or skill_type == GameConst.SKILL_TYPE_ZhuRiJianFa
		or skill_type == GameConst.SKILL_TYPE_JiuJieJianFa
		or skill_type == GameConst.SKILL_TYPE_GuiYouZhan
		or skill_type == GameConst.SKILL_TYPE_ShenXuanJianFa
		or skill_type == GameConst.SKILL_TYPE_ZhanLongJianFa
		or skill_type == GameConst.SKILL_TYPE_PoKongJianFa
end

----------------宝石相关----------------

local gemConf = {
	[GameConst.GEM_TYPE_HOLY] = {
		mPriority = 1, mBegin = GameConst.ITEM_GEM_HOLY_BEGIN, mEnd = GameConst.ITEM_GEM_HOLY_END
	},
	[GameConst.GEM_TYPE_CRI_PROB] = {
		mPriority = 2, mBegin = GameConst.ITEM_GEM_CRI_PROB_BEGIN, mEnd = GameConst.ITEM_GEM_CRI_PROB_END
	},
	[GameConst.GEM_TYPE_CRI] = {
		mPriority = 3, mBegin = GameConst.ITEM_GEM_CRI_BEGIN, mEnd = GameConst.ITEM_GEM_CRI_END
	},
	[GameConst.GEM_TYPE_ATTACK] = {
		mPriority = 4, mBegin = GameConst.ITEM_GEM_ATTACK_BEGIN, mEnd = GameConst.ITEM_GEM_ATTACK_END
	},
	[GameConst.GEM_TYPE_AC] = {
		mPriority = 5, mBegin = GameConst.ITEM_GEM_AC_BEGIN, mEnd = GameConst.ITEM_GEM_AC_END
	},
	[GameConst.GEM_TYPE_MAC] = {
		mPriority = 6, mBegin = GameConst.ITEM_GEM_MAC_BEGIN, mEnd = GameConst.ITEM_GEM_MAC_END
	},
	[GameConst.GEM_TYPE_HP] = {
		mPriority = 7, mBegin = GameConst.ITEM_GEM_HP_BEGIN, mEnd = GameConst.ITEM_GEM_HP_END
	},
	[GameConst.GEM_TYPE_MP] = {
		mPriority = 8, mBegin = GameConst.ITEM_GEM_MP_BEGIN, mEnd = GameConst.ITEM_GEM_MP_END
	}
}

function GameBaseLogic.IsGem(typeId)
	return typeId and typeId > GameConst.ITEM_GEM_BEGIN and typeId < GameConst.ITEM_GEM_END
end

function GameBaseLogic.IsAttackGem(typeId)
	return typeId and typeId > GameConst.ITEM_GEM_ATTACK_BEGIN and typeId < GameConst.ITEM_GEM_ATTACK_END
end

function GameBaseLogic.IsACkGem(typeId)
	return typeId and typeId > GameConst.ITEM_GEM_AC_BEGIN and typeId < GameConst.ITEM_GEM_AC_END
end

function GameBaseLogic.IsMACkGem(typeId)
	return typeId and typeId > GameConst.ITEM_GEM_MAC_BEGIN and typeId < GameConst.ITEM_GEM_MAC_END
end

function GameBaseLogic.IsHpGem(typeId)
	return typeId and typeId > GameConst.ITEM_GEM_HP_BEGIN and typeId < GameConst.ITEM_GEM_HP_END
end

function GameBaseLogic.IsMpGem(typeId)
	return typeId and typeId > GameConst.ITEM_GEM_MP_BEGIN and typeId < GameConst.ITEM_GEM_MP_END
end

function GameBaseLogic.IsSpecialGem(typeId)
	return typeId and typeId > GameConst.ITEM_GEM_SPECIAL_BEGIN and typeId < GameConst.ITEM_GEM_SPECIAL_END
end
--神圣宝石
function GameBaseLogic.IsHolyGem(typeId)
	return typeId and typeId > GameConst.ITEM_GEM_HOLY_BEGIN and typeId < GameConst.ITEM_GEM_HOLY_END
end
--暴击宝石
function GameBaseLogic.IsCriProbGem(typeId)
	return typeId and typeId > GameConst.ITEM_GEM_CRI_PROB_BEGIN and typeId < GameConst.ITEM_GEM_CRI_PROB_END
end
--暴伤宝石
function GameBaseLogic.IsCriGem(typeId)
	return typeId and typeId > GameConst.ITEM_GEM_CRI_BEGIN and typeId < GameConst.ITEM_GEM_CRI_END
end

--宝石排序优先级
function GameBaseLogic.getGemPriority(typeId)
	for _, v in ipairs(gemConf) do
		if typeId > v.mBegin and typeId < v.mEnd then
			return v.mPriority
		end
	end
end

function GameBaseLogic.getGemType(typeId)
	for gemType, v in ipairs(gemConf) do
		if typeId > v.mBegin and typeId < v.mEnd then
			return gemType
		end
	end
end

local function sortFunc(gemPos1, gemPos2)
	local netItem1 = GameSocket:getNetItem(gemPos1)
	local netItem2 = GameSocket:getNetItem(gemPos2)
	local mPriority1 = GameBaseLogic.getGemPriority(netItem1.mTypeID)
	local mPriority2 = GameBaseLogic.getGemPriority(netItem2.mTypeID)
	if mPriority1 < mPriority2 then --先依据类别排序
		return true
	elseif mPriority1 == mPriority2 then -- 同类别依据等级排序
		return netItem1.mTypeID > netItem2.mTypeID
	end
end

--依据类型获取宝石pos的数组
--获取宝石数组排序好(神圣》暴击》暴伤》攻击》物防》魔防》生命》魔法)
function GameBaseLogic.getGemsAndSort(gemType)
	-- 宝石pos数组
	local gemTable = {}
	local netItem, mType
	for pos = GameConst.ITEM_BAG_BEGIN, GameConst.ITEM_BAG_BEGIN + GameConst.ITEM_BAG_SIZE + GameSocket.mBagSlotAdd - 1 do
		netItem = GameSocket:getNetItem(pos)
		if netItem and GameBaseLogic.IsGem(netItem.mTypeID) then
			if (not gemType) then
				table.insert(gemTable, pos)
			elseif type(gemType) == "number" then
				if GameBaseLogic.getGemType(netItem.mTypeID) == gemType then
					table.insert(gemTable, pos)
				end
			elseif type(gemType) == "table" then
				mType = GameBaseLogic.getGemType(netItem.mTypeID)
				if table.indexof(gemType, mType) then
					table.insert(gemTable, pos)
				end
			end
		end
	end
	-- 进行排序
	table.sort(gemTable, sortFunc)
	return gemTable
end

local guildInfo = {
	[1]={level = 1, need_exp=1000000,	opex=300,	upper_limit=100,dc=11,	buff_id=29001,},
	[2]={level = 2, need_exp=5000000,	opex=400,	upper_limit=100, dc=16,	buff_id=29002,},
	[3]={level = 3, need_exp=20000000,	opex=500,	upper_limit=100, dc=21,	buff_id=29003,},
	[4]={level = 4, need_exp=50000000,	opex=600,	upper_limit=100,	dc=26,	buff_id=29004,},
	[5]={level = 5, need_exp=100000000,	opex=800,	upper_limit=100,	dc=31,	buff_id=29005,},
	[6]={level = 6, need_exp=300000000,	opex=1000,	upper_limit=100,	dc=36,	buff_id=29006,},
	[7]={level = 7, need_exp=0,			opex=1200,	upper_limit=100,	dc=41,	buff_id=29007,},
}

function GameBaseLogic.getGuildMemberMax(level)
	if guildInfo[level] then
		return guildInfo[level].upper_limit
	end
	return 0
end

function GameBaseLogic.getSkillUseState(skillid)
	return table.indexof(GameSocket.NetAutoSkills, skillid) and true or false
end

local bloodStones = {
	20003001,
	20003002,
	20003003,
} 

function GameBaseLogic.isBloodStone(type_id)
	return type_id and table.indexof(bloodStones, type_id)
end

function GameBaseLogic.isUsageTipProp(type_id)
	-- local id = GameSocket:getItemDefByID(type_id)
	-- if id then
	-- 	if id.SubType == GameConst.ITEM_TYPE_MONEY then
	-- 		return true
	-- 	elseif id.SubType == GameConst.ITEM_TYPE_MATERIAL then
	-- 		return true
	-- 	elseif GameBaseLogic.isBloodStone(type_id) then
	-- 		return true
	-- 	end
	-- end
	return GameBaseLogic.isBloodStone(type_id)
end

---批量使用物品
function GameBaseLogic.canBatchUse(type_id)
	local itemDef = GameSocket:getItemDefByID(type_id)
	return type_id and itemDef and itemDef.mCanUse==2
end

--双击道具打开对应的面板
local itemsOpen = {
	[24000001]={itemName="护卫进阶丹",panelName="extend_mars"},
	[24060001]={itemName="宝藏钥匙",  panelName="extend_lottory"},

	[24020001]={itemName="黑铁矿石",  panelName="main_forge"},
	[24020002]={itemName="青铜矿石",  panelName="main_forge"},
	[24020003]={itemName="白银矿石",  panelName="main_forge"},
	[24020004]={itemName="紫金矿石",  panelName="main_forge"},

}
function GameBaseLogic.useItemOpen(type_id)
	if itemsOpen[type_id] then
		GameSocket:dispatchEvent({name=GameMessageCode.EVENT_OPEN_PANEL,str=itemsOpen[type_id].panelName,value = itemsOpen[type_id].value,id=type_id})
		return true
	end
	return false
end

local basic_func = {
	"btn_main_avatar",  "btn_main_skill", "btn_main_equip", "btn_main_wing", "btn_main_puzzle", "btn_main_achieve", "btn_main_social", "btn_main_rank", "btn_main_system", 
	"btn_main_forge", "btn_main_furnace", "btn_main_official", "btn_main_compose", "btn_main_convert", 
	"btn_main_friend", "btn_main_group", "btn_main_guild", "btn_main_mail", "btn_main_consign"
}
function GameBaseLogic.isMainButton(name)
	return table.indexof(basic_func, name)
end

function GameBaseLogic.setTouchingRocker(touching)
	_touchingRocker = touching
end

function GameBaseLogic.isTouchingRocker()
	return _touchingRocker
end

-- 背包物品需要显示使用红点提示
local needShowUseItems = {
	23000001,23000002,23000003,23010001,23010002,23010003,23020001,23020002,23020003,23030001,23030002,23030003,
}

function GameBaseLogic.checkItemShowUse(typeId)
	local itemdef = GameSocket:getItemDefByID(typeId)
	if itemdef and itemdef.mBagShow == 1 then
		-- print("////////////////////////////checkItemShowUse///////////////////////////", itemdef.mBagShow, itemdef.mTimesLimit, GameSocket:canItemUse(typeId))
		if (itemdef.mTimesLimit == 0) or (itemdef.mTimesLimit == 1 and GameSocket:canItemUse(typeId)) then
			return true
		end
	end
	return false
end

local canSellId = {
	32010001,32010002,32010003,20001001,20001002,20001003,20001004,20001005,20001006,
}
function GameBaseLogic.checkBatchSell(typeId)
	if table.indexof(canSellId,typeId) then 
		return true
	else
		return false
	end
	
end

--是装备且能穿戴
function GameBaseLogic.checkEquipDress(pos)
	local newItem = GameSocket.mItems[pos]
	if newItem then 
		local itemDef = GameSocket:getItemDefByID(newItem.mTypeID)
		if not GameBaseLogic.IsEquipment(newItem.mTypeID) then
			return false
		end
		if itemDef then
			local gender = GameCharacter._mainAvatar:NetAttr(GameConst.net_gender)
			local level = GameCharacter._mainAvatar:NetAttr(GameConst.net_level)
			local zlevel = GameCharacter._mainAvatar:NetAttr(GameConst.net_zslevel)
			local job = GameCharacter._mainAvatar:NetAttr(GameConst.net_job)
			-- print(gender,level,zlevel,job,"==============00000000000000000")
			if itemDef.mJob>0 and itemDef.mJob~=job then return false end--职业不匹配
			if itemDef.mGender>0 and gender~=itemDef.mGender then return false end--性别不匹配
			if level<itemDef.mNeedParam or zlevel<itemDef.mNeedZsLevel then return false end--等级不匹配
		end
	end
	return true
end

--获取背包里的拼图碎片pos
function GameBaseLogic.getPinTuPos()
	local result = {}
	local startId = 33000001
	local endId = 33001809
	for i=0,GameConst.ITEM_BAG_MAX do
		local newItem = GameSocket.mItems[i]
		if newItem and newItem.mTypeID>=startId and newItem.mTypeID<=endId then
			table.insert(result,i)
		end
	end
	return result
end

function GameBaseLogic.isPinTu(typeId)
	local startId = 33000001
	local endId = 33001809
	if typeId>=startId and typeId<=endId then
		return true
	end
	return false
end

function GameBaseLogic.c3b_to_c4b(c3b,a)
	return { r = c3b.r, g = c3b.g,  b = c3b.b, a and tonumber(a) or 255 }
end

return GameBaseLogic

