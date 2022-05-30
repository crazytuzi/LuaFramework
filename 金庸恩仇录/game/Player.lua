local data_equipquench_equipquench = require("data.data_equipquench_equipquench")

require("game.model.FashionModel")

local Player = class("Player")

function Player:ctor(...)
	self.m_gamenote = nil
	self.m_extendData = {}
	self.m_serverID = 1
	self.m_thirdID = ""
	self.m_uid = ""
	self.m_playerID = ""
	self.m_sessionID = ""
	self.m_zoneID = 1
	self.m_sdkID = ""
	self.m_loginName = ""
	self.m_serverKey = ""
	self.m_logout = false
	self.m_maxLevel = 0
	self.m_subMapID = 0
	self.m_battleData = {}
	self.m_battleData.cur_bigMapId = 0
	self.m_battleData.cur_subMapId = 0
	self.m_battleData.new_bigMapId = 0
	self.m_battleData.new_subMapId = 0
	self.m_battleData.isOpenNewBigmap = false
	self.m_mail_battle = 0
	self.m_mail_friend = 0
	self.m_mail_system = 0
	self._biwuCollTime = 0
	self._yaBiaoCollTime = 0
	self.m_majorHeros = {
	0,
	0,
	0,
	0,
	0,
	0
	}
	self.m_heroSouls = {}
	self.m_guildMgr = nil
	self.m_isChangedServer = false
	self.m_appOpenData = {}
	self.m_skills = {}
	self.m_pets = {}
	self.m_petFragments = {}
	self.m_unlock_levels = {}
	self.m_levels_fight_count = {}
	self.m_currect_level = 11
	self.m_package = {}
	self.m_mails = {}
	self.m_friends = {}
	self.m_orderList = self.m_orderList or {}
	self.m_formation = {}
	self.m_arena = {
	times = 5,
	rankID = 0,
	score = 0
	}
	self.m_recruit = {}
	self.m_collections = {
	{},
	{},
	{}
	}
	self.openBoxCout = 0
	self.m_Purchased = false
	self.m_giftPackages = {}
	self.m_levelUpAry = {}
	self.m_levelUpAry.isLevelUp = false
	self.m_levelUpAry.beforeLevel = 0
	self.m_levelUpAry.curLevel = 0
	self.m_cur_normal_fuben_ID = 1101
	self.m_fubenDisOffset = cc.p(0, 0)
	self.m_submapOffset = cc.p(0, 0)
	self.m_herolistOffset = cc.p(0, 0)
	self:initNotification()
	function self.setFubenDisOffset(_, offset)
		self.m_fubenDisOffset = offset or self.m_fubenDisOffset
	end
	function self.getFubenDisOffset()
		return self.m_fubenDisOffset
	end
	function self.setSubmapOffset(_, offset)
		self.m_submapOffset = offset or self.m_submapOffset
	end
	function self.getSubmapOffet()
		return self.m_submapOffset
	end
	function self.setHeroListOffset(_, offset)
		self.m_herolistOffset = offset or self.m_herolistOffset
	end
	function self.getHeroListOffset()
		return self.m_herolistOffset
	end
	function self.getBattleData(param)
		return self.m_battleData
	end
	function self.getCurSubMapID()
		return self.m_battleData.cur_subMapId
	end
	function self.setBattleData(_, param)
		self.m_battleData.new_bigMapId = param.new_bigMapId or self.m_battleData.new_bigMapId
		self.m_battleData.new_subMapId = param.new_subMapId or self.m_battleData.new_subMapId
		self.m_battleData.cur_bigMapId = param.cur_bigMapId or self.m_battleData.cur_bigMapId
		self.m_battleData.cur_subMapId = param.cur_subMapId or self.m_battleData.cur_subMapId
		if param.isOpenNewBigmap ~= nil then
			self.m_battleData.isOpenNewBigmap = param.isOpenNewBigmap
		end
	end
	function self.getZoneID()
		return self.m_zoneID
	end
	function self.setAppOpenData(_, data)
		self.m_appOpenData = data or {}
		self.m_appOpenData.b_liaotian = self.m_appOpenData.b_liaotian or 0
		self.m_appOpenData.b_qiecuo = self.m_appOpenData.b_qiecuo or 0
		self.m_appOpenData.b_siliao = self.m_appOpenData.b_siliao or 0
		self.m_appOpenData.c_vipbtn = self.m_appOpenData.c_vipbtn or 0
		self.m_appOpenData.c_yueka = self.m_appOpenData.c_yueka or 0
		self.m_appOpenData.chengzhang = self.m_appOpenData.chengzhang or 0
		self.m_appOpenData.chongwu = self.m_appOpenData.chongwu or 0
		self.m_appOpenData.dengji = self.m_appOpenData.dengji or 0
		self.m_appOpenData.huodong = self.m_appOpenData.huodong or 0
		self.m_appOpenData.hy_qiecuo = self.m_appOpenData.hy_qiecuo or 0
		self.m_appOpenData.kaifu = self.m_appOpenData.kaifu or 0
		self.m_appOpenData.kezhan = self.m_appOpenData.kezhan or 0
		self.m_appOpenData.lianhuashenmi = self.m_appOpenData.lianhuashenmi or 0
		self.m_appOpenData.shouchong = self.m_appOpenData.shouchong or 0
		self.m_appOpenData.zaixian = self.m_appOpenData.zaixian or 0
		self.m_appOpenData.zhifuqiehuan = self.m_appOpenData.zhifuqiehuan or 0
		self.m_appOpenData.zijianbangzhu = self.m_appOpenData.zijianbangzhu or 0
		self.m_appOpenData.kaifukuanghuan = self.m_appOpenData.kaifukuanghuan or 0
		self.m_appOpenData.appstore = self.m_appOpenData.appstore or 0
		self.m_appOpenData.redbag = self.m_appOpenData.redbag or 0
		self.m_appOpenData.qiandao = self.m_appOpenData.qiandao or 1
		self.m_appOpenData.zhenshen = self.m_appOpenData.zhenshen or 1
		self.m_appOpenData.seven_day = self.m_appOpenData.seven_day or 1
		self.m_appOpenData.gvg_battle = self.m_appOpenData.gvg_battle or 0
		self.m_appOpenData.youai = self.m_appOpenData.youai or 1
	end
	function self.getAppOpenData()
		return self.m_appOpenData
	end
end

function Player:setOpenBoxCout(count)
	self.openBoxCout = count
end

function Player:getOpenBoxCout(count)
	return self.openBoxCout
end

function Player:getGuildMgr(...)
	if self.m_guildMgr == nil then
		self.m_guildMgr = require("game.guild.GuildMgr").new()
	end
	return self.m_guildMgr
end

function Player:getGuildInfo(...)
	return self:getGuildMgr():getGuildInfo()
end

local isCanSleep = function(t)
	local t = t / 1000
	local nowTime = os.date("*t", os.time())
	local hour = nowTime.hour
	if hour >= 18 and hour < 20 or hour >= 12 and hour < 14 then
		if t > 0 then
			local lastTime = os.date("*t", t)
			if nowTime.month > lastTime.month then
				return 1
			elseif nowTime.month == lastTime.month then
				if nowTime.day > lastTime.day then
					return 1
				elseif nowTime.day == lastTime.day then
					if lastTime.hour >= 18 and lastTime.hour < 20 then
						return 0
					elseif nowTime.hour >= 18 and nowTime.hour < 20 then
						return 1
					end
				end
			end
			return 0
		else
			return 1
		end
	else
		return 0
	end
end

function Player:updateNotification(data)
	if data ~= nil and type(data) == "table" then
		self.m_choukaNum = data[1] or 0
		self:setJingyingNum(data[2] or 0)
		self:setHuodongNum(data[3] or 0)
		self.m_qiandaoNum = data[4] or 0
		local kaifu = data[5]
		if kaifu ~= nil then
			if kaifu[1] == 1 then
				self.m_isShowKaifuLibao = true
			else
				self.m_isShowKaifuLibao = false
			end
			self.m_kaifulibao = kaifu[2] or 0
		else
			self.m_isShowKaifuLibao = false
			self.m_kaifulibao = 0
		end
		local dengji = data[6]
		if dengji ~= nil then
			if dengji[1] == 1 then
				self.m_isSHowDengjiLibao = true
			else
				self.m_isSHowDengjiLibao = false
			end
			self.m_dengjilibao = dengji[2] or 0
		else
			self.m_isSHowDengjiLibao = false
			self.m_dengjilibao = 0
		end
		local rewardcenter = data[7]
		if rewardcenter ~= nil then
			if rewardcenter[1] == 1 then
				self.m_isShowRewardCenter = true
			else
				self.m_isShowRewardCenter = false
			end
			self.m_rewardcenterNum = rewardcenter[2] or 0
		else
			self.m_isShowRewardCenter = false
			self.m_rewardcenterNum = 0
		end
		if data[8] ~= nil and 0 < data[8] then
			self.m_isShowChengzhang = true
		else
			self.m_isShowChengzhang = false
		end
		local kuanghuan = data[9]
		if kuanghuan ~= nil then
			if kuanghuan[1] == 1 then
				self.m_isKaiFuKuangHuan = true
			else
				self.m_isKaiFuKuangHuan = false
			end
			self.m_kuangHuanNum = kuanghuan[2] or 0
		else
			self.m_isKaiFuKuangHuan = false
			self.m_kuangHuanNum = 0
		end
		local zhuangbei = data[11]
		if zhuangbei then
			self.m_zhuangbeiNum = zhuangbei
		end
		local xiake = data[12]
		if xiake then
			self.m_xiakeNum = xiake
		end
		self.m_JiangHuBoxNum = data[10] or 0
		self.m_betterEquip = data[13] or 0
		local hefukuanghuan = data[14] or nil
		if hefukuanghuan ~= nil then
			if hefukuanghuan[1] == 1 then
				self.m_isHeFuKuangHuan = true
			else
				self.m_isHeFuKuangHuan = false
			end
			self.m_hefukuangHuanNum = hefukuanghuan[2] or 0
		else
			self.m_isHeFuKuangHuan = false
			self.m_hefukuangHuanNum = 0
		end
		local chongwu = data[15]
		if chongwu then
			self.m_PetNum = chongwu
		end
		self:setZhenshenNum(data[16] or 0)
		local qitianle = data[17]
		if qitianle ~= nil then
			if qitianle[1] == 1 then
				self.m_isCJQiTianLe = true
			else
				self.m_isCJQiTianLe = false
			end
			self.m_CJQitianLeNum = qitianle[2] or 0
		else
			self.m_isCJQiTianLe = false
			self.m_CJQitianLeNum = 0
		end
		local kuanghuangou = data[18] or {}
		KuangHuanModel:init(kuanghuangou)
		local kuanghuangou = KuangHuanModel:getKuangHuanGou()
		self.m_kuangHuanGouNum = {}
		for i, v in ipairs(kuanghuangou) do
			self.m_kuangHuanGouNum[tostring(v.t)] = v.n
		end
		CheatsModel.setCheatsNum(data[19] or 0)
	end
end

--初始化提醒
function Player:initNotification()
	self.m_onlineRewardTime = 0
	self.m_isShowOnlineReward = false
	self.m_isShowRewardCenter = false
	self.m_isShowKaifuLibao = true
	self.m_isSHowDengjiLibao = true
	self.m_isShowChengzhang = false
	self.m_isKaiFuKuangHuan = false
	self.m_isCJQiTianLe = false
	self.m_isHeFuKuangHuan = false
	self.m_betterEquip = 0
	self.m_choukaNum = 0
	self.m_qiandaoNum = 0
	self.m_kaifulibao = 0
	self.m_dengjilibao = 0
	self.m_rewardcenterNum = 0
	self.m_chatNewNum = 0
	self.m_chatLastReviTime = {}
	self.m_jingyingNum = 0
	self.m_huodongNum = 0
	self.m_zhenshenNum = 0
	self.m_guildApplyNum = 0
	self.m_JiangHuBoxNum = 0
	
	--抽卡
	function self.getChoukaNum()
		return self.m_choukaNum
	end
	
	function self.setChoukaNum(_, num)
		self.m_choukaNum = num
		if self.m_choukaNum < 0 then
			self.m_choukaNum = 0
		end
	end
	
	--签到
	function self.getQiandaoNum()
		return self.m_qiandaoNum
	end
	
	function self.setQiandaoNum(_, num)
		self.m_qiandaoNum = num
		if self.m_qiandaoNum < 0 then
			self.m_qiandaoNum = 0
		end
	end
	
	--领奖提醒
	function self.getRewardcenterNum()
		return self.m_rewardcenterNum
	end
	
	function self.setRewardcenterNum(_, num)
		self.m_rewardcenterNum = num
		if self.m_rewardcenterNum <= 0 then
			self.m_rewardcenterNum = 0
			self.m_isShowRewardCenter = false
		end
	end
	
	--开服礼包
	function self.getKaifuLibao()
		return self.m_kaifulibao
	end
	
	function self.setKaifuLibao(_, num)
		self.m_kaifulibao = num
		if self.m_kaifulibao <= 0 then
			self.m_kaifulibao = 0
		end
	end
	
	--开服狂欢
	function self.getkuangHuanNum()
		return self.m_kuangHuanNum
	end
	
	function self.setkuangHuanNum(_, num)
		self.m_kuangHuanNum = num
		if self.m_kuangHuanNum <= 0 then
			self.m_kuangHuanNum = 0
		end
	end
	
	--七天乐
	function self.getCJQiTianLeNum()
		return self.m_CJQitianLeNum
	end
	
	function self.setCJQiTianLeNum(_, num)
		self.m_CJQitianLeNum = num
		if self.m_CJQitianLeNum <= 0 then
			self.m_CJQitianLeNum = 0
		end
	end
	
	--合服狂欢
	function self.getHeFukuangHuanNum()
		return self.m_hefukuangHuanNum
	end
	
	function self.setHeFukuangHuanNum(_, num)
		self.m_hefukuangHuanNum = num
		if self.m_hefukuangHuanNum <= 0 then
			self.m_hefukuangHuanNum = 0
		end
	end
	
	--等级礼包
	function self.getDengjilibao()
		return self.m_dengjilibao
	end
	
	function self.setDengjilibao(_, num)
		self.m_dengjilibao = num
		if self.m_dengjilibao <= 0 then
			self.m_dengjilibao = 0
		end
	end
	
	--聊天
	function self.getChatNewNum()
		return self.m_chatNewNum
	end
	
	function self.setChatNewNum(_, num)
		self.m_chatNewNum = num
		if self.m_chatNewNum <= 0 then
			self.m_chatNewNum = 0
		end
	end
	
	function self:getChatLastTime(type, playerid)
		local time = self.m_chatLastReviTime[type]
		if not time then
			return "1000000000000"
		end
		if tonumber(type) == CHAT_TYPE.friend then
			if not time[playerid] then
				return "1000000000000"
			else
				return time[playerid]
			end
		end
		return time
	end
	
	function self:updateLastTime(type, time, playerid)
		if tonumber(type) == CHAT_TYPE.friend then
			local data = self.m_chatLastReviTime[type]
			if data and data[playerid] then
				print(tonumber(self.m_chatLastReviTime[type][playerid]))
				if tonumber(self.m_chatLastReviTime[type][playerid]) < tonumber(time) then
					self.m_chatLastReviTime[type][playerid] = time
					return
				end
			end
			if not data then
				self.m_chatLastReviTime[type] = {}
			end
			self.m_chatLastReviTime[type][playerid] = time
			return
		end
		if not self.m_chatLastReviTime[type] then
			self.m_chatLastReviTime[type] = time
			return
		end
		if tonumber(self.m_chatLastReviTime[type]) < tonumber(time) then
			self.m_chatLastReviTime[type] = time
		end
	end
	
	--精英副本
	function self.getJingyingNum()
		return self.m_jingyingNum
	end
	
	function self.setJingyingNum(_, num)
		self.m_jingyingNum = num
		if self.m_jingyingNum <= 0 then
			self.m_jingyingNum = 0
		end
	end
	
	--活动
	function self.getHuodongNum()
		return self.m_huodongNum
	end
	
	function self.setHuodongNum(_, num)
		self.m_huodongNum = num
		if self.m_huodongNum <= 0 then
			self.m_huodongNum = 0
		end
	end
	
	--真身
	function self.getZhenshenNum()
		return self.m_zhenshenNum or 0
	end
	
	function self.setZhenshenNum(_, num)
		self.m_zhenshenNum = checknumber(num) or 0
		if self.m_zhenshenNum <= 0 then
			self.m_zhenshenNum = 0
		end
	end
	
	--挑战
	function self.getIsShowChallengeNotice()
		local bHasOpen_hd = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.HuoDong_FuBen, self.m_level, self.m_vip)
		local bHasOpen_jy = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.JiYing_FuBen, self.m_level, self.m_vip)
		local bHasOpen_zs = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.ZhenShen_FuBen, self.m_level, self.m_vip)
		if self.m_huodongNum > 0 and bHasOpen_hd then
			return true
		elseif 0 < self.m_jingyingNum and bHasOpen_jy then
		elseif 0 < self.m_zhenshenNum and bHasOpen_zs then
			return true
		else
			return false
		end
	end
	
	--装备
	function self.setEquipmentsNum(_, num)
		self.m_zhuangbeiNum = num
		if self.m_zhuangbeiNum <= 0 then
			self.m_zhuangbeiNum = 0
		end
	end
	
	function self.getEquipmentsNum()
		if self.m_zhuangbeiNum == nil then
			return 0
		else
			return self.m_zhuangbeiNum
		end
	end
	
	--侠客
	function self.setXiakeNum(_, num)
		self.m_xiakeNum = num
		if self.m_xiakeNum <= 0 then
			self.m_xiakeNum = 0
		end
	end
	
	function self.getXiakeNum()
		if self.m_xiakeNum == nil then
			return 0
		else
			return self.m_xiakeNum
		end
	end
	
	--宠物
	function self.setPetNum(_, num)
		self.m_PetNum = num
		if self.m_PetNum <= 0 then
			self.m_PetNum = 0
		end
	end
	
	function self.getPetNum()
		if self.m_PetNum == nil then
			return 0
		else
			return self.m_PetNum
		end
	end
	
	--俱乐部申请
	function self.setGuildApplyNum(_, num)
		self.m_guildApplyNum = num
		if self.m_guildApplyNum <= 0 then
			self.m_guildApplyNum = 0
		end
	end
	function self.getGuildApplyNum()
		return self.m_guildApplyNum
	end
	function self.getJiangHuBoxNum()
		return self.m_JiangHuBoxNum
	end
	function self.setJiangHuBoxNum(_, num)
		self.m_JiangHuBoxNum = num
		if self.m_JiangHuBoxNum < 0 then
			self.m_JiangHuBoxNum = 0
		end
	end
	function self.getBetterEquip()
		return self.m_betterEquip
	end
	function self.set_betterEquip(_, num)
		self.m_betterEquip = num
		if self.m_betterEquip < 0 then
			self.m_betterEquip = 0
		end
	end
end

function Player:init(data)
	self.m_playerID = data.id
	self.m_name = data.name or "name"
	self.m_title = ""
	self.m_level = data.level or 0
	self.m_exp = data.exp or 0
	self.m_gold = data.gold or 0
	self.m_silver = data.silver or 0
	self.m_energy = data.resisVal
	self.m_strength = data.physVal
	self.m_battlepoint = data.attack
	self.m_class = data.cls or 0
	self.m_fashionId = data.fashionId or 0
	self.m_star = data.star or 3
	self.m_maxStrength = data.propLimitAry[1] or 0
	self.m_maxEnergy = data.propLimitAry[2] or 0
	self.m_maxExp = data.propLimitAry[3] or 0
	self.hb_activityisopen = false
	self.hb_isshake = false
	self.hb_lasttime = -1
	self.hb_livetime = 0
	self.m_gender = data.resId
	self.m_befExp = data.exp or 0
	self.m_vip = data.vip or 0
	self.m_isHasBuyGold = false
	local _items = {}
	local _spirit = {}
	local _equips = {}
	local _hero = {}
	local _spiritBagMax = 0
	function self.setSpiritBagMax(_, num)
		_spiritBagMax = num
	end
	function self.getSpiritBagMax()
		return _spiritBagMax or 0
	end
	function self.getStar(_)
		return self.m_star or 0
	end
	function self.setSkills(_, skills)
		self.m_skills = skills
	end
	function self.getSkills(_, sortFunc)
		if sortFunc then
			table.sort(self.m_skills, sortFunc)
		end
		return self.m_skills
	end
	function self.setHero(_, hero)
		_hero = hero
		table.sort(_hero, function(lh, rh)
			if lh.pos > 0 and rh.pos == 0 then
				return true
			elseif lh.pos == 0 and rh.pos > 0 then
				return false
			else
				return lh.star > rh.star
			end
		end)
	end
	function self.getCulianAttr(_, pos, index)
		local function checkData(index)
			for k, v in pairs(self.m_formation["5"][index]) do
				if v.pos == pos then
					dump(v)
					return v
				end
			end
		end
		if self.m_formation["5"][index] then
			local data = checkData(index)
			if data and data.cls ~= 0 then
				return data
			end
		end
		return nil
	end
	function self.addCulianAttr()
	end
	function self.setCulianAttr(_, index, pos, value)
		if self.m_formation["5"][index] and self.m_formation["5"][index][pos] then
			self.m_formation["5"][index][pos].cls = value
			dump(self.m_formation["5"][index][pos])
		end
	end
	function self.getFormList(_)
		return self.m_formation["1"]
	end
	function self.getHero(_)
		HeroModel.sort(_hero)
		return _hero
	end
	
	function self.getEquipments()
		return _equips
	end
	
	function self.setEquipments(_, equip)
		_equips = equip
		self.noramlEquips = {}
		self.fashionEquips = {}
		local equipFashion = nil
		if _equips ~= nil then
			for k, v in ipairs(_equips) do
				if v.type == 2 then
					table.insert(self.fashionEquips, v)
					if v.pos ~= 0 then
						equipFashion = v
						self.setFashionId(_, equipFashion.resId)
					end
				else
					table.insert(self.noramlEquips, v)
				end
			end
		end
		FashionModel.initFashionList(self.fashionEquips, equipFashion)
	end
	
	function self.getNormalEquipments()
		return self.noramlEquips
	end
	
	function self.getFashionEquipments()
		return self.fashionEquips
	end
	
	function self.getLevel()
		return self.m_level
	end
	
	function self.setItem(_, id, num)
		_items[id] = num
	end
	
	function self.getItem(_, id)
		return _items[id] or 0
	end
	
	function self.setSpirit(_, spirit)
		_spirit = spirit
	end
	
	function self.getSpirit(_, sortFunc)
		_spirit = require("game.Spirit.SpiritCtrl"):getSpirit()
		if sortFunc then
			table.sort(_spirit, sortFunc)
		end
		return _spirit
	end
	local _bagCountMax = 0
	local _bagCountUsed = 0
	
	function self.getGold(_)
		return self.m_gold or 0
	end
	
	function self.setGold(_, num)
		self.m_gold = num
	end
	
	function self.setSilver(_, num)
		self.m_silver = num
	end
	
	function self.addSilver(_, num)
		self.m_silver = self.m_silver + num
		return self.m_silver or 1
	end
	
	function self.getSilver()
		return self.m_silver or 1
	end
	
	function self.getBagCountMax(_)
		return _bagCountMax or 1
	end
	
	function self.getBagCountUsed(_)
		return _bagCountUsed or 1
	end
	
	function self.setBagCountMax(_, count)
		_bagCountMax = count
	end
	
	function self.setBagCountUsed(_, count)
		_bagCountUsed = count
	end
	
	function self.setStrength(_, num)
		self.m_strength = num
	end
	
	function self.getStrength()
		return self.m_strength or 0
	end
	
	function self.addStrength(_, num)
		self.m_strength = self.m_strength + num
	end
	
	function self.getBattlePoint()
		return self.m_battlepoint or 0
	end
	
	function self.getPlayerName()
		return self.m_name or ""
	end
	
	function self.getClass()
		return self.m_class + 1
	end
	
	function self.setFashionId(_, fashionId)
		self.m_fashionId = fashionId or 0
	end
	
	function self.getFashionId(_)
		return self.m_fashionId
	end
	
	function self.getNaili()
		return self.m_energy
	end
	
	function self.setNaili(_, naili)
		self.m_energy = naili
	end
	
	function self.getExp()
		return self.m_exp or 0
	end
	
	function self.getMaxExp()
		return self.m_maxExp or 0
	end
	
	function self.getGender()
		return self.m_gender or 0
	end
	
	function self.updateLevelUpData(_, param)
		self.m_levelUpAry.isLevelUp = param.isLevelUp or false
		self.m_levelUpAry.beforeLevel = param.beforeLevel or self.m_level
		self.m_levelUpAry.curLevel = param.curLevel or self.m_level
	end
	function self.getLevelUpData()
		return self.m_levelUpAry
	end
	function self.getVip()
		return self.m_vip
	end
	function self.setVip(_, vip)
		self.m_vip = vip or self.m_vip
	end
	function self.getIsHasBuyGold()
		return self.m_isHasBuyGold
	end
	function self.setIsHasBuyGold(_, hasBuy)
		self.m_isHasBuyGold = hasBuy or self.m_isHasBuyGold
		PostNotice(NoticeKey.MainMenuScene_Shouchong)
	end
	function self.getPlayerIconName()
		local data_card_card = require("data.data_card_card")
		local gender = self.m_gender
		return data_card_card[gender].arr_role_icon[self:getClass()] .. ".png"
	end
	function self.setMailTip(_, mailTip)
		self.m_mail_battle = mailTip.battle or 0
		self.m_mail_friend = mailTip.friend or 0
		self.m_mail_system = mailTip.system or 0
	end
	function self.resetMailBattle()
		self.m_mail_battle = 0
	end
	function self.getMailBattle()
		return self.m_mail_battle
	end
	function self.resetMailFriend()
		self.m_mail_friend = 0
	end
	function self.getMailFriend()
		return self.m_mail_friend
	end
	function self.resetMailSystem()
		self.m_mail_system = 0
	end
	function self.getMailSystem()
		return self.m_mail_system
	end
	function self.hasMailTip()
		if self:getMailBattle() > 0 or 0 < self:getMailFriend() or 0 < self:getMailSystem() then
			return true
		end
		return false
	end
end

function Player:getPlayerID()
	return self.m_playerID
end

function Player:updateMainMenu(param)
	self.m_silver = param.silver or self.m_silver
	self.m_gold = param.gold or self.m_gold
	self.m_battlepoint = param.zhanli or self.m_battlepoint
	self.m_energy = param.naili or self.m_energy
	self.m_maxEnergy = param.maxNaili or self.m_maxEnergy
	self.m_strength = param.tili or self.m_strength
	self.m_maxStrength = param.maxTili or self.m_maxStrength
	self.m_befExp = self.m_exp or param.exp
	self.m_exp = param.exp or self.m_exp
	self.m_maxExp = param.maxExp or self.m_maxExp
	self.m_level = param.lv or self.m_level
	self.m_vip = param.vip or self.m_vip
	self.m_name = param.name or self.m_name
	if param.hasBuyGold ~= nil then
		if param.hasBuyGold == 1 then
			self.m_isHasBuyGold = true
		elseif param.hasBuyGold == 0 then
			self.m_isHasBuyGold = false
		end
	end
	local guildBoss = param.unionBossState or 0
	local sleepState = param.sleepState or 0
	self.m_quickAccessState = {
	[QuickAccess.SLEEP] = isCanSleep(sleepState),
	[QuickAccess.BOSS] = param.bossState or 0,
	[QuickAccess.LIMITCARD] = param.limitCardstate or 0,
	[QuickAccess.GUILD_BOSS] = guildBoss - 1,
	[QuickAccess.GUILD_BBQ] = param.bbqState,
	[QuickAccess.CAIQUAN] = param.caiquan or 0,
	[QuickAccess.YABIAO] = param.yabiao or 0,
	[QuickAccess.TANBAO] = param.rouletteStatus or 0,
	[QuickAccess.WABAO] = param.mazeState or 0,
	[QuickAccess.SHOP] = param.LimitShopState or 0,
	[QuickAccess.CREDIT_SHOP] = param.CreditShopState or 0,
	[QuickAccess.LUCKY_POOL] = param.luckOpenState or 0,
	[QuickAccess.DIAOYU_ACT] = param.fishOpenState or 0
	}
end

function Player:initBaseInfo(param)
	local function loadStorge()
		if not self.m_uid or self.m_uid == "" then
			local uid = CCUserDefault:sharedUserDefault():getStringForKey("accid")
			if uid == nil or uid == "" then
				uid = os.time()
				CCUserDefault:sharedUserDefault():setStringForKey("accid", uid)
				CCUserDefault:sharedUserDefault():flush()
			end
			self.m_uid = uid
		end
		self.m_sessionID = 0
		self.m_platformID = param.platformID
		self.m_loginName = param.nickname or ""
	end
	--if device.platform == "mac" or device.platform == "windows" then
	loadStorge()
	--else
	self.m_sessionID = param.sessionId
	self.m_platformID = param.platformID
	--end
end

function Player:deleteUID()
	CCUserDefault:sharedUserDefault():setStringForKey("accid", "")
	CCUserDefault:sharedUserDefault():flush()
end

function Player:setUid(uid)
	if uid ~= nil then
		self.m_uid = uid
	end
end

function Player:updateHongBao(func)
	local function _callback(data)
		game.player.hb_lasttime = tonumber(data.rtnObj.endTime)
		game.player.hb_livetime = tonumber(data.rtnObj.residueRewardTime)
		if func then
			func()
		end
	end
	local _error = function(data)
	end
	local msg = {
	m = "activity",
	a = "redPacketView"
	}
	RequestHelper.request(msg, _callback, _error)
end

function Player:updateBaseData(_callBack)
	RequestHelper.getBaseInfo({
	callback = function(data)
		if #data["0"] > 0 then
			show_tip_label(data["0"])
		else
			local basedata = data["1"]
			local param = {
			silver = basedata.silver,
			gold = basedata.gold,
			lv = basedata.level,
			zhanli = basedata.attack,
			vip = basedata.vip
			}
			param.exp = basedata.exp[1]
			param.maxExp = basedata.exp[2]
			param.naili = basedata.resisVal[1]
			param.maxNaili = basedata.resisVal[2]
			param.tili = basedata.physVal[1]
			param.maxTili = basedata.physVal[2]
			param.hasBuyGold = data["3"]
			self:updateMainMenu(param)
			local checkAry = data["2"]
			self:updateNotification(checkAry)
		end
		if _callBack then
			_callBack()
		end
	end
	})
end

function Player:setExtendData(extend)
	if extend ~= nil then
		self.m_extendData = extend
	end
end

function Player:canSetSpeed(nextSpeed, isShowLabel)
	local data_item_speed = require("data.data_item_speed")
	if self.m_level >= data_item_speed[nextSpeed].level then
		return true
	else
		if isShowLabel ~= false then
			show_tip_label("[" .. data_item_speed[nextSpeed].level .. common:getLanguageString("@kaifang") .. nextSpeed .. common:getLanguageString("@beisu"))
		end
		local isDebug = false
		if device.platform == "windows" or device.platform == "mac" then
			isDebug = true
		end
		return isDebug
	end
end

function Player:checkIsSelfByAcc(acc)
	local bSelf = false
	local selfAcc = string.lower(self.m_uid)
	if acc == selfAcc then
		bSelf = true
	end
	return bSelf
end

function Player:isSelf(id)
	return self.m_playerID == id
end

function Player:getServerID()
	local selfIdx = self.m_serverID
	return selfIdx
end

function Player:getAccount()
	local selfAcc = self.m_uid
	return selfAcc
end

function Player:getBagReq(cb)
	local RequestInfo = require("network.RequestInfo")
	local reqs = {}
	local data1, data2, data3
	table.insert(reqs, RequestInfo.new({
	modulename = "skill",
	funcname = "list",
	param = {},
	oklistener = function(data)
		data1 = data
	end
	}))
	table.insert(reqs, RequestInfo.new({
	modulename = "packet",
	funcname = "list",
	param = {},
	oklistener = function(data)
		data2 = data
	end
	}))
	table.insert(reqs, RequestInfo.new({
	modulename = "gift",
	funcname = "list",
	param = {},
	oklistener = function(data)
		data3 = data
	end
	}))
	RequestHelperV2.request2(reqs, function()
		cb(data1, data2, data3)
	end)
end

return Player