-- Filename：	PreRequest.lua
-- Author：		Cheng Liang
-- Date：		2013-7-16
-- Purpose：		物品Item
module("PreRequest", package.seeall)

require "script/network/RequestCenter"
require "script/model/DataCache"
require "script/utils/LuaUtil"
require "script/ui/star/StarUtil"
require "script/ui/copy/CopyUtil"
require "script/ui/copy/ShowNewCopyLayer"
require "script/ui/tower/TowerCache"
require "script/ui/main/MainBaseLayer"
require "script/ui/item/GodWeaponItemUtil"
require "script/ui/copy/CopyService"

local _new_useItem_num = 0  	-- 新增的使用物品的个数

function getNewUseItemNum()
	return _new_useItem_num
end

function clearNewuseItemNum()
	_new_useItem_num = 0
end

----------------------- 通知到界面的方法 --------------------
local _bagDataChangedDelegate = nil
function setBagDataChangedDelete( delegateFunc )
	_bagDataChangedDelegate = delegateFunc
end

----------------------- 组队战的开始的委托函数 --------------------
local _copyteamBattleDelegate = nil
function registerTeamBattleDelegate( delegateFunc)
	_copyteamBattleDelegate= delegateFunc
end


----------------------- 背包推送接口 -----------------------------
function re_bag_baginfo_callback( cbFlag, dictData, bRet )
	if(dictData.err == "ok") then
		if(table.isEmpty(dictData.ret) == false) then
			local tmplBagInfo = DataCache.getRemoteBagInfo()
			local re_bagInfo = {}
			for k,v in pairs(dictData.ret) do
				re_bagInfo = v
			end
			for gid, r_itemInfo in pairs(re_bagInfo) do
				-- 临时背包的数据
				local isTmplArm 			= false
				local isTmplProps 			= false
				local isTmplHeroFrag 		= false
				local isTmplTreas 			= false
				local isTmplArmFrag 		= false
				local isTmplFightSoul		= false
				local isTmplDress 			= false
				local isTmplPetFrag 		= false
				local isTmplGodWeapon 		= false
				local isTmplGodWeaponFrag 	= false
				local isTmplRune 			= false
				local isTmplRuneFrag 		= false
				local isTmplPocket 			= false
				local isTmplTally			= false
				local isTmplTallyFrag		= false
				local isTmplCharito 		= false
				if ( tonumber(gid) <=  (tonumber(tmplBagInfo.gridStart.tmp) + tonumber(tmplBagInfo.gridMaxNum.tmp)) ) then
					-- 如果是临时背包
					if(table.isEmpty(r_itemInfo))then
						tmplBagInfo.arm[gid] 		= nil
						tmplBagInfo.props[gid]  	= nil
						tmplBagInfo.heroFrag[gid] 	= nil
						tmplBagInfo.treas[gid]		= nil
						tmplBagInfo.armFrag[gid]	= nil
						tmplBagInfo.fightSoul[gid]	= nil
						tmplBagInfo.dress[gid]		= nil
						tmplBagInfo.petFrag[gid] 	= nil
						tmplBagInfo.godWp[gid] 		= nil
						tmplBagInfo.godWpFrag[gid] 	= nil
						tmplBagInfo.rune[gid] 		= nil
						tmplBagInfo.runeFrag[gid] 	= nil
						tmplBagInfo.pocket[gid] 	= nil
						tmplBagInfo.tally[gid] 		= nil
						tmplBagInfo.tallyFrag[gid] 	= nil
						tmplBagInfo.chariotBag[gid]	= nil
					else
						local item_tmpl_id = tonumber( r_itemInfo.item_template_id )
						if(item_tmpl_id >= 400001 and item_tmpl_id <= 500000) then
							-- 武将碎片
							isTmplHeroFrag =true
						elseif(item_tmpl_id >= 100001 and item_tmpl_id <= 200000)then
							-- 装备
							isTmplArm = true
						elseif(item_tmpl_id >= 500001 and item_tmpl_id <= 600000)then
							-- 宝物
							isTmplTreas = true
						elseif(item_tmpl_id >= 1000001 and item_tmpl_id <= 5000000)then
							-- 装备碎片
							isTmplArmFrag = true
						elseif(item_tmpl_id >= 80001 and item_tmpl_id <= 90000)then
							-- 时装
							isTmplDress = true
						elseif(item_tmpl_id >= 70001 and item_tmpl_id <= 80000)then
							-- 战魂
							isTmplFightSoul = true
						elseif(item_tmpl_id >= 600001 and item_tmpl_id <= 700000)then
							-- 神兵
							isTmplGodWeapon = true
						elseif(item_tmpl_id >= 7000001 and item_tmpl_id <= 8000000)then
							-- 神兵碎片
							isTmplGodWeaponFrag = true
						elseif(item_tmpl_id >= 700001 and item_tmpl_id <= 800000)then
							-- 符印
							isTmplRune = true
						elseif(item_tmpl_id >= 8000001 and item_tmpl_id <= 9000000)then
							-- 符印碎片
							isTmplRuneFrag = true
						elseif(item_tmpl_id >= 800001 and item_tmpl_id <= 900000)then
							-- 锦囊
							isTmplPocket = true
						elseif(item_tmpl_id >= 900001 and item_tmpl_id <= 910000)then
							-- 兵符
							isTmplTally = true
						elseif(item_tmpl_id >= 9000001 and item_tmpl_id <= 9100000)then
							-- 兵符碎片
							isTmplTallyFrag = true
						elseif(item_tmpl_id >= 920001 and item_tmpl_id <= 930000)then
							-- 战车
							isTmplCharito = true
						else
							-- 道具
							isTmplProps = true
						end
					end
				end
				-- 装备
				if (isTmplArm or ( tonumber(gid) >= tonumber(tmplBagInfo.gridStart.arm) and tonumber(gid) < (tonumber(tmplBagInfo.gridStart.arm) + tonumber(tmplBagInfo.gridMaxNum.arm)) )) then
					if(table.isEmpty(r_itemInfo))then
						tmplBagInfo.arm[gid] = nil
					else
						tmplBagInfo.arm[gid] = r_itemInfo
					end

				-- 道具
				elseif (isTmplProps or ( tonumber(gid) >= tonumber(tmplBagInfo.gridStart.props) and tonumber(gid) < (tonumber(tmplBagInfo.gridStart.props) + tonumber(tmplBagInfo.gridMaxNum.props)) )) then
					if(table.isEmpty(r_itemInfo))then
						tmplBagInfo.props[gid] = nil
					else
						-- 如果是可使用的物品
						local m_template_id = tonumber(r_itemInfo.item_template_id)
						if( MainScene.getOnRunningLayerSign() ~= "bagLayer" and (m_template_id >= 10001 and m_template_id <50000)  )then
							local add_num = 0
							if(not table.isEmpty(tmplBagInfo.props[gid]) )then
								add_num = tonumber(r_itemInfo.item_num) - tonumber(tmplBagInfo.props[gid].item_num)
							else
								add_num = tonumber(r_itemInfo.item_num)
							end
							if(add_num>0)then
								_new_useItem_num = _new_useItem_num + add_num
								MenuLayer.refreshMenuItemTipSprite()
							end
						end

						tmplBagInfo.props[gid] = r_itemInfo
					end
				-- 武将碎片
				elseif ( isTmplHeroFrag or ( tonumber(gid) >= tonumber(tmplBagInfo.gridStart.heroFrag) and tonumber(gid) < (tonumber(tmplBagInfo.gridStart.heroFrag) + tonumber(tmplBagInfo.gridMaxNum.heroFrag)) )) then
					
					if(table.isEmpty(r_itemInfo))then
						tmplBagInfo.heroFrag[gid] = nil
					else
						tmplBagInfo.heroFrag[gid] = r_itemInfo
					end
				elseif (isTmplTreas or ( tonumber(gid) >= tonumber(tmplBagInfo.gridStart.treas) and tonumber(gid) < (tonumber(tmplBagInfo.gridStart.treas) + tonumber(tmplBagInfo.gridMaxNum.treas)) )) then
					-- 宝物
					if(table.isEmpty(r_itemInfo) )then
						tmplBagInfo.treas[gid] = nil
					else
						if( table.isEmpty(r_itemInfo.va_item_text) ) then
							r_itemInfo.va_item_text = {}
						end
						if( r_itemInfo.va_item_text.treasureLevel == nil )then
							r_itemInfo.va_item_text.treasureLevel = "0"
						end
						tmplBagInfo.treas[gid] = r_itemInfo
					end

				elseif (isTmplArmFrag or ( tonumber(gid) >= tonumber(tmplBagInfo.gridStart.armFrag) and tonumber(gid) < (tonumber(tmplBagInfo.gridStart.armFrag) + tonumber(tmplBagInfo.gridMaxNum.armFrag)) )) then
					-- 装备碎片
					if(table.isEmpty(r_itemInfo) )then
						tmplBagInfo.armFrag[gid] = nil
					else
						tmplBagInfo.armFrag[gid] = r_itemInfo
					end
				elseif ( isTmplFightSoul or ( tonumber(gid) >= tonumber(tmplBagInfo.gridStart.fightSoul) and tonumber(gid) < (tonumber(tmplBagInfo.gridStart.fightSoul) + tonumber(tmplBagInfo.gridMaxNum.fightSoul)) )) then
					-- 战魂
					if(table.isEmpty(r_itemInfo) )then
						tmplBagInfo.fightSoul[gid] = nil
					else
						tmplBagInfo.fightSoul[gid] = r_itemInfo
					end
					
				elseif ( isTmplDress or ( tonumber(gid) >= tonumber(tmplBagInfo.gridStart.dress) and tonumber(gid) < (tonumber(tmplBagInfo.gridStart.dress) + tonumber(tmplBagInfo.gridMaxNum.dress)) )) then
					-- 时装
					if(table.isEmpty(r_itemInfo) )then
						tmplBagInfo.dress[gid] = nil
					else
						tmplBagInfo.dress[gid] = r_itemInfo
						
						-- 有变化
						require "script/ui/dressRoom/DressRoomCache"
						DressRoomCache.addNewDress(r_itemInfo.item_template_id)
						-- 时装套装更新缓存数据
						require "script/ui/fashion/fashionsuit/FashionSuitData"
						FashionSuitData.updateHaveDressInfoByTid(r_itemInfo.item_template_id)
					end
				elseif ( isTmplPetFrag or ( tonumber(gid) >= tonumber(tmplBagInfo.gridStart.petFrag) and tonumber(gid) < (tonumber(tmplBagInfo.gridStart.petFrag) + tonumber(tmplBagInfo.gridMaxNum.petFrag)) )) then
					-- 宠物碎片
					if(table.isEmpty(r_itemInfo) )then
						tmplBagInfo.petFrag[gid] = nil
					else
						tmplBagInfo.petFrag[gid] = r_itemInfo
					end

				elseif ( isTmplGodWeapon or ( tonumber(gid) >= tonumber(tmplBagInfo.gridStart.godWp) and tonumber(gid) < (tonumber(tmplBagInfo.gridStart.godWp) + tonumber(tmplBagInfo.gridMaxNum.godWp)) )) then
					-- 神兵
					if(table.isEmpty(r_itemInfo) )then
						tmplBagInfo.godWp[gid] = nil
					else
						tmplBagInfo.godWp[gid] = r_itemInfo
					end
				elseif ( isTmplGodWeaponFrag or ( tonumber(gid) >= tonumber(tmplBagInfo.gridStart.godWpFrag) and tonumber(gid) < (tonumber(tmplBagInfo.gridStart.godWpFrag) + tonumber(tmplBagInfo.gridMaxNum.godWpFrag)) )) then
					-- 神兵碎片
					if(table.isEmpty(r_itemInfo) )then
						tmplBagInfo.godWpFrag[gid] = nil
					else
						tmplBagInfo.godWpFrag[gid] = r_itemInfo
					end
				elseif ( isTmplRune or ( tonumber(gid) >= tonumber(tmplBagInfo.gridStart.rune) and tonumber(gid) < (tonumber(tmplBagInfo.gridStart.rune) + tonumber(tmplBagInfo.gridMaxNum.rune)) )) then
					-- 符印
					if(table.isEmpty(r_itemInfo) )then
						tmplBagInfo.rune[gid] = nil
					else
						tmplBagInfo.rune[gid] = r_itemInfo
					end
					
				elseif ( isTmplRuneFrag or ( tonumber(gid) >= tonumber(tmplBagInfo.gridStart.runeFrag) and tonumber(gid) < (tonumber(tmplBagInfo.gridStart.runeFrag) + tonumber(tmplBagInfo.gridMaxNum.runeFrag)) )) then
					-- 符印碎片
					if(table.isEmpty(r_itemInfo) )then
						tmplBagInfo.runeFrag[gid] = nil
					else
						tmplBagInfo.runeFrag[gid] = r_itemInfo
					end
				elseif ( isTmplPocket or ( tonumber(gid) >= tonumber(tmplBagInfo.gridStart.pocket) and tonumber(gid) < (tonumber(tmplBagInfo.gridStart.pocket) + tonumber(tmplBagInfo.gridMaxNum.pocket)) )) then
					-- 锦囊
					if(table.isEmpty(r_itemInfo) )then
						tmplBagInfo.pocket[gid] = nil
					else
						tmplBagInfo.pocket[gid] = r_itemInfo
					end
				elseif ( isTmplTally or ( tonumber(gid) >= tonumber(tmplBagInfo.gridStart.tally) and tonumber(gid) < (tonumber(tmplBagInfo.gridStart.tally) + tonumber(tmplBagInfo.gridMaxNum.tally)) )) then
					-- 兵符
					if(table.isEmpty(r_itemInfo) )then 
						tmplBagInfo.tally[gid] = nil
					else
						tmplBagInfo.tally[gid] = r_itemInfo
						-- 更新缓存数据
						require "script/ui/tally/preview/TallyPreviewData"
						TallyPreviewData.activeBingfu(r_itemInfo.item_template_id)
					end
				elseif ( isTmplTallyFrag or ( tonumber(gid) >= tonumber(tmplBagInfo.gridStart.tallyFrag) and tonumber(gid) < (tonumber(tmplBagInfo.gridStart.tallyFrag) + tonumber(tmplBagInfo.gridMaxNum.tallyFrag)) )) then
					-- 兵符碎片
					if(table.isEmpty(r_itemInfo) )then
						tmplBagInfo.tallyFrag[gid] = nil 
					else
						tmplBagInfo.tallyFrag[gid] = r_itemInfo
					end

				elseif ( isTmplCharito or ( tonumber(gid) >= tonumber(tmplBagInfo.gridStart.chariotBag) and tonumber(gid) < (tonumber(tmplBagInfo.gridStart.chariotBag) + tonumber(tmplBagInfo.gridMaxNum.chariotBag)) )) then
					-- 战车
					if(table.isEmpty(r_itemInfo) )then 
						tmplBagInfo.chariotBag[gid] = nil
					else
						-- tmplBagInfo.chariotBag[gid] = r_itemInfo

						-- print("==================== r_itemInfo ==================")
						-- print_t(r_itemInfo)
						
						require "script/ui/chariot/ChariotMainData"
						tmplBagInfo.chariotBag[gid] = ChariotMainData.parseNetChariot(r_itemInfo, gid)

						-- 战车背包红点(拥有新的战车)
						require "script/ui/bag/BagUtil"
						BagUtil.setNewChariotWithPush( tmplBagInfo.chariotBag[gid].item_id )

						-- 更新战车图鉴数据
						require "script/ui/chariot/illustrate/ChariotIllustrateData"
						ChariotIllustrateData.activeChariotByTid(r_itemInfo.item_template_id)
					end
				else
				end
			end

			-- 需要修改背包的信息已经过期
			DataCache.setBagStatus(true)

			-- 更新缓存
			if(_bagDataChangedDelegate ~= nil) then
				_bagDataChangedDelegate()
			end
			
		end
	else
		print("err re_bag_baginfo_callback ", dictData.err)
	end
end
local function re_bag_baginfo_request( )
	Network.re_rpc(re_bag_baginfo_callback, "re.bag.bagInfo", "re.bag.bagInfo")
end

------------------------- 名将的推送接口 ------------------------

local function re_star_addNewNotice_callback(cbFlag, dictData, bRet )
	if(dictData.err == "ok") then
		if( not table.isEmpty( dictData.ret ) ) then
			for k,t_star in pairs(dictData.ret) do

				StarUtil.saveNewStarId( tonumber(t_star.star_id))
				DataCache.addStarToCache(t_star)
			end
		end
	end
end
------------------------------------------------------------- added by bzx 城池战报中战斗出结果
local function push_citywar_battleEnd_callback(cbFlag, dictData, bRet)
    if dictData.err == "ok" then
        require "script/ui/guild/city/BattlefieldReportLayer"
        BattlefieldReportLayer.battleEnd(tonumber(dictData.ret.cityId))
    end
end

local function push_citywar_battleEnd()
    Network.re_rpc(push_citywar_battleEnd_callback, "push.citywar.battleEnd", "push.citywar.battleEnd")
end
-------------------------------------------------------------
local function re_star_addNewNotice()
	Network.re_rpc(re_star_addNewNotice_callback, "re.star.addNewNotice", "re.star.addNewNotice")
end

-------------------------- 邮件推送接口 -------------------------------
local function re_mail_addNewMail_callback(cbFlag, dictData, bRet )
	if(dictData.err == "ok") then
		require "script/ui/mail/MailData"
		MailData.setHaveNewMailStatus( "true" )
		MailData.updateShowIsHaveNewMail()
		-- 资源矿new
		MailData.updateResourcesNewMail(dictData.ret.templateId)
	end
end
local function re_mail_addNewMail()
	Network.re_rpc(re_mail_addNewMail_callback, "re.mail.newMail", "re.mail.newMail")
end

-------------------------- 好友推送接口 -------------------------------
local function re_friend_newFriend_callback(cbFlag, dictData, bRet )
	if(dictData.err == "ok") then
		-- require "script/ui/friend/FriendData"
		-- 只通知有新好友，没有数据
	end
end
local function re_friend_newFriend()
	Network.re_rpc(re_friend_newFriend_callback, "re.friend.newFriend", "re.friend.newFriend")
end


-------------------------- 删除好友推送接口 -------------------------------
local function re_friend_delFriend_callback(cbFlag, dictData, bRet )
	if(dictData.err == "ok") then
		-- 被对方从对方好友列表删除
		require "script/ui/main/MainScene"
		if(MainScene.getOnRunningLayerSign() == "friendLayer")then
			require "script/ui/friend/MyFriendLayer"
			MyFriendLayer.updateMyFriendLayer()
			require "script/ui/friend/GetStaminaLayer"
			GetStaminaLayer.updateGetStaminaLayer()
		end
	end
end
local function re_friend_delFriend()
	Network.re_rpc(re_friend_delFriend_callback, "push.friend.del", "push.friend.del")
end

-------------------------- 好友上线推送接口 -------------------------------
local function push_friend_login_callback(cbFlag, dictData, bRet )
	if(dictData.err == "ok") then
		require "script/ui/main/MainScene"
		if(MainScene.getOnRunningLayerSign() == "friendLayer")then
			require "script/ui/friend/FriendData"
			if(FriendData.allfriendData ~= nil)then
				-- 返回上线好友的uid
				require "script/ui/friend/MyFriendLayer"
				MyFriendLayer.updateOnlineFriend( dictData.ret )
			end
		end
	end
end
local function push_friend_login()
	Network.re_rpc(push_friend_login_callback, "push.friend.login", "push.friend.login")
end

-------------------------- 好友下线推送接口 -------------------------------
local function push_friend_logoff_callback(cbFlag, dictData, bRet )
	if(dictData.err == "ok") then
		require "script/ui/main/MainScene"
		if(MainScene.getOnRunningLayerSign() == "friendLayer")then
			require "script/ui/friend/FriendData"
			if(FriendData.allfriendData ~= nil)then
				-- 返回下线好友的uid
				require "script/ui/friend/MyFriendLayer"
				MyFriendLayer.updateOfflineFriend( dictData.ret )
			end
		end
	end
end
local function push_friend_logoff()
	Network.re_rpc(push_friend_logoff_callback, "push.friend.logoff", "push.friend.logoff")
end

-------------------------- 好友可领取耐力列表推送接口 -------------------------------
local function re_friend_receiveStamina_callback(cbFlag, dictData, bRet )
	if(dictData.err == "ok") then
		require "script/ui/main/MainScene"
		if(MainScene.getOnRunningLayerSign() == "friendLayer")then
			require "script/ui/friend/GetStaminaLayer"
			GetStaminaLayer.upDateReciveDataAndUi()
		end
	end
end

local function re_friend_receiveStamina()
	Network.re_rpc(re_friend_receiveStamina_callback, "push.friend.newLove", "push.friend.newLove")
end

-------------------------- 竞技场推送接口 -------------------------------
--[[
(uid,
position,
cur_suc,
max_suc,
opponents = {}
--]]
local function re_arena_dataRefresh_callback(cbFlag, dictData, bRet )
	if(dictData.err == "ok") then
		local ret = dictData.ret
		require "script/ui/main/MainScene"
		if(MainScene.getOnRunningLayerSign() == "arenaLayer")then
			require "script/ui/arena/ArenaData"
			-- 设置玩家排名
			ArenaData.setSelfRanking(ret.position)
			if(table.count(ret.opponents) ~= 0)then
				-- 设置挑战列表数据
				ArenaData.setOpponentsData( ret.opponents )
				-- 更新列表
				require "script/ui/arena/ArenaChallenge"
				ArenaChallenge.updateArenaChallengeTableView()
			end
		end
	end
end

local function re_arena_dataRefresh()
	Network.re_rpc(re_arena_dataRefresh_callback, "re.arena.dataRefresh", "re.arena.dataRefresh")
end

-------------------------- 比武推送接口 -------------------------------
local function re_match_dataRefresh_callback(cbFlag, dictData, bRet )
	if(dictData.err == "ok") then
		local ret = dictData.ret
		require "script/ui/main/MainScene"
		if(MainScene.getOnRunningLayerSign() == "matchLayer")then
			require "script/ui/match/MatchPlace"
			MatchPlace.upDateMacthDataAndui( ret )
		end
	end
end

local function re_match_dataRefresh()
	Network.re_rpc(re_match_dataRefresh_callback, "push.compete.refresh", "push.compete.refresh")
end

-------------------------- 比武发奖推送接口 -------------------------------
local function re_match_reward_callback(cbFlag, dictData, bRet )
	if(dictData.err == "ok") then
		local ret = dictData.ret
		require "script/ui/main/MainScene"
		if(MainScene.getOnRunningLayerSign() == "matchLayer")then
			require "script/ui/match/MatchLayer"
			MatchLayer.updateUIforRewardState( ret[1] )
		end
	end
end

local function re_match_reward()
	Network.re_rpc(re_match_reward_callback, "push.compete.reward", "push.compete.reward")
end

--------------------------团购活动推送接口 -------------------------------
local function re_tuan_callback(cbFlag, dictData, bRet )
	if(dictData.err == "ok") then
		local ret = dictData.ret
		require "script/ui/rechargeActive/TuanLayer"
		TuanLayer.pushRefreshFun(ret)
	end
end

local function re_tuan()
	Network.re_rpc(re_tuan_callback, "push.groupon.buygood", "push.groupon.buygood")
end
-------------------------聊天的推送接口 开始------------------------
-- channel  1<=>广播频道 2<=>世界频道（用户发的消息，出现在世界频道） 3<=>系统频道 (系统发的消息，出现在世界频道)
-- 4<=>私人频道 5<=>私人广播频道(大喇叭) 100<=>副本频道 101<=>公会频道 102<=>弹幕频道
function re_chat_getMsg_callback(cbFlag, dictData, bRet )
	if(dictData.err == "ok") then
		if( not table.isEmpty( dictData.ret ) ) then
			local m_info = dictData.ret
			if(tonumber(m_info.channel)== 1)then
				-- 走马灯
				require "script/ui/main/BulletinData"
            	BulletinData.setMsgData(m_info)
			elseif(tonumber(m_info.channel)==102)then
				require "script/ui/main/BulletinData"
				if(BulletinData.getShow()==true)then
            		BulletinData.bulletScreenData(m_info)
            	end
			else
				-- require "script/ui/chat/ChatMainLayer"
            	--ChatMainLayer.addChat(m_info)
            	require "script/ui/chat/ChatControler"
	           	ChatControler.addChat(m_info)
			end
		end
	end
end


local function re_chat_getMsg()
	Network.re_rpc(re_chat_getMsg_callback, "re.chat.getMsg", "re.chat.getMsg")
end

-------------------------聊天的推送接口 结束------------------------

-------------------------------------- 活动卡包得推送接口 --------------------------
local function push_hero_rfrrank_callback(cbFlag, dictData, bRet)
	if(dictData.err == "ok") then
		if( not table.isEmpty( dictData.ret ) ) then
			require "script/ui/rechargeActive/ActiveCache"
			require "script/ui/rechargeActive/CardPackActiveLayer"
			ActiveCache.setRankInfo(dictData.ret)
            CardPackActiveLayer.refreshBottomUI()
		end
	end

end

local function push_hero_rfrrank( )
	Network.re_rpc(push_hero_rfrrank_callback, "push.heroshop.rfrrank", "push.heroshop.rfrrank")
end

--------------------------------------- 活动卡包得推送接口 end ---------------------------------
local function push_hero_endact_callback(cbFlag, dictData, bRet)
	if(dictData.err == "ok") then
		require "script/ui/rechargeActive/ActiveCache"
		require "script/ui/rechargeActive/CardPackActiveLayer"
		CardPackActiveLayer.endactAction()
	end

end



local function push_hero_endact( )
	Network.re_rpc(push_hero_endact_callback, "push.heroshop.endact", "push.heroshop.endact")
end

-------------------------军团推送接口 ----------------------------
-- 个人信息发生变化  agreeApply，kickMember，setVicePresident，unsetVicePresident，transPresident  这几个地方会触发
function pushGuildRefreshMember( cbFlag, dictData, bRet )
	if(dictData.err == "ok")then
		require "script/ui/guild/GuildDataCache"
		GuildDataCache.setMineSigleGuildInfo(dictData.ret)
		if(GuildDataCache.isInGuildFunc() and GuildDataCache.isInGuildFunc() == true )then
			-- 在军团界面的话
			require "script/ui/guild/GuildImpl"
			GuildImpl.showLayer()
		end
	end
end

local function re_guild_refreshMember()
	Network.re_rpc(pushGuildRefreshMember, "push.guild.refreshMember", "push.guild.refreshMember")
end

-------------------------- 城池战报名城池推送接口 -------------------------------
local function re_city_signup_callback(cbFlag, dictData, bRet )
	if(dictData.err == "ok") then
		local ret = dictData.ret
		require "script/ui/main/MainScene"
		if(MainScene.getOnRunningLayerSign() == "BigMap")then
			require "script/ui/guild/city/CityData"
			CityData.updateSignupTable( ret )
		end
	end
end

local function re_city_signup()
	Network.re_rpc(re_city_signup_callback, "push.citywar.signRefresh", "push.citywar.signRefresh")
end


----------------------军团粮仓推送---------------------
function push_guildrob_info( ... )
	require "script/ui/guild/guildRobList/GuildRobData"
	Network.re_rpc(GuildRobData.handlePushGuildRobInfo, "push.guildrob.info", "push.guildrob.info")
end

-------------------------刷新关公殿 ----------------------------

function pushGuildRefreshGuangong( cbFlag, dictData, bRet )
	require "script/ui/main/MainScene"
	if (dictData.err == "ok") then
		if(MainScene.getOnRunningLayerSign() == "guangongTempleLayer")then
			require "script/ui/guild/GuangongTempleLayer"
			GuangongTempleLayer.refreshBaiNum(dictData.ret.reward_num)
		end
	end
end

local function re_guild_refreshGuangong()
	Network.re_rpc(pushGuildRefreshGuangong, "push.refreshGuild", "push.refreshGuild")
end

--------------------------新的神兵录推送-----------------------------
local function re_guild_newGodWeaponBook()
	local pushNewBook = function( cbFlag, dictData, bRet )
		if (dictData.err == "ok") then
			require "script/ui/godweapon/GodWeaponData"
			GodWeaponData.addNewBook(dictData.ret)
		end
	end
	Network.re_rpc(pushNewBook,"push.godweapon.newDict","push.godweapon.newDict")
end
----------------------刷新福利活动翻牌积分-----------------------
function pushActivityRefreshBenefitCard(cbFlag,dictData,bRet)
	require "script/ui/rechargeActive/BenefitActiveLayer"
	if (dictData.err == "ok") then
		BenefitActiveLayer.writePreAccountNum(dictData.ret.point_today)
	end
end

local function re_activity_refreshBenefitCard()
	Network.re_rpc(pushActivityRefreshBenefitCard,"push.weal.kapoint","push.weal.kapoint")
end

------------------------刷新军团商店------------------------------------
local function pushGuildGoods( cbFlag, dictData, bRet )
	if(dictData.err == "ok")then
		require "script/ui/guild/GuildDataCache"
		require "script/ui/shopall/GuildShopLayer"
		if(MainScene.getOnRunningLayerSign() == "guildShopLayer")then

			GuildDataCache.addPushGoodsInfo(dictData.ret)
			GuildShopLayer.refreshTableView()
		end
	end
end


local function re_guild_refreshShop()
	Network.re_rpc(pushGuildGoods, "push.refreshGoods", "push.refreshGoods")
end

------------------------军团组队推送的接口------------------------------------
local function pushDataChanged( cbFlag, dictData, bRet )
	if(dictData.err == "ok")then
		if(MainScene.getOnRunningLayerSign() == "guildCopyLayer") then
			require "script/ui/teamGroup/TeamGroupData"
			TeamGroupData.setTeamUpdate( dictData.ret )
		end
	end
end

local function re_team_changed()
	Network.re_rpc(pushDataChanged, "team.update", "team.update")
end

------------------------木牛流马邀请协助推送的接口------------------------------------
local function pushHelpDataChanged( cbFlag, dictData, bRet )
	if(dictData.err == "ok")then
		print("huhuhahahaha")
		require "script/ui/horse/HorseData"
		HorseData.addOtherHelpData( dictData.ret )
	end
end

local function re_help_changed()
	Network.re_rpc(pushHelpDataChanged, "push.chargedart.invitefriendy", "push.chargedart.invitefriendy")
end

-------------------------军团粮仓开启推送接口 ----------------------------
function pushGuildRefreshBarnBuilding( cbFlag, dictData, bRet )
	if(dictData.err == "ok")then
		if(GuildDataCache.isInGuildFunc() and GuildDataCache.isInGuildFunc() == true )then

			local guildMemberInfoCallback = function (cbFlag,dictData1,bRet)
				if(dictData1.err == "ok")then
					require "script/ui/guild/GuildDataCache"
					GuildDataCache.setMineSigleGuildInfo(dictData1.ret)

					if( MainScene.getOnRunningLayerSign() == "guildMainLayer" and tonumber(dictData.ret[1]) <= 0 ) then
						-- 第一次开启粮仓加初始cd
						require "script/ui/guild/liangcang/BarnData"
						GuildDataCache.setGuildShareNextTime(BTUtil:getSvrTimeInterval() + BarnData.getShareFoodCd())
						-- 粮仓开启 刷新下粮仓建筑
						require "script/ui/guild/GuildMainLayer"
						GuildMainLayer.refreshBarnBuildingUI()
					end

					if( MainScene.getOnRunningLayerSign() == "LiangCangMainLayer" and tonumber(dictData.ret[1]) > 0 ) then
						-- 粮田开启  刷新下粮田
						require "script/ui/guild/LiangCangMainLayer"
						LiangCangMainLayer.linagTianOpenPushUpdateUI()
					end
				end
			end
			-- 拉一把个人信息
			require "script/network/RequestCenter"
			RequestCenter.guild_getMemberInfo(guildMemberInfoCallback)
		end
	end
end

local function re_guild_refreshBarnBuilding()
	Network.re_rpc(pushGuildRefreshBarnBuilding, "push.guild.barnLevel", "push.guild.barnLevel")
end

-------------------------军团粮田全部刷新推送接口 ----------------------------
function pushGuildRefreshAll( cbFlag, dictData, bRet )
	if(dictData.err == "ok")then
		if(GuildDataCache.isInGuildFunc() and GuildDataCache.isInGuildFunc() == true )then
			require "script/ui/guild/GuildDataCache"
			GuildDataCache.updateSurplusCollectNum(dictData.ret)

			if(MainScene.getOnRunningLayerSign() == "LiangCangMainLayer")then
				require "script/ui/guild/liangcang/LiangCangMainLayer"
				LiangCangMainLayer.refreshAllPushUpdateUI()
			end
		end
	end
end

local function re_guild_refreshAll()
	Network.re_rpc(pushGuildRefreshAll, "push.guild.refreshAll", "push.guild.refreshAll")
end

-------------------------军团粮田采集时候，推送等级经验接口 ----------------------------
function pushGuildfieldHarvest( cbFlag, dictData, bRet )
	if(dictData.err == "ok")then
		if(GuildDataCache.isInGuildFunc() and GuildDataCache.isInGuildFunc() == true )then
			require "script/ui/guild/GuildDataCache"
			GuildDataCache.updateLiangTianLvAndExp(dictData.ret)

			if(MainScene.getOnRunningLayerSign() == "LiangCangMainLayer")then
				require "script/ui/guild/liangcang/LiangCangMainLayer"
				LiangCangMainLayer.refreshLvAndExpPushUpdateUI()
			end
		end
	end
end

local function re_guild_rfieldHarvest()
	Network.re_rpc(pushGuildfieldHarvest, "push.guild.fieldHarvest", "push.guild.fieldHarvest")
end

------------------------- 军团粮仓分粮冷却时间推送 ----------------------------
function pushGuildShareCd( cbFlag, dictData, bRet )
	if(dictData.err == "ok")then
		if(GuildDataCache.isInGuildFunc() and GuildDataCache.isInGuildFunc() == true )then
			require "script/ui/guild/GuildDataCache"
			GuildDataCache.updateShareCd(dictData.ret)

			if(MainScene.getOnRunningLayerSign() == "LiangCangMainLayer")then
				require "script/ui/guild/liangcang/LiangCangMainLayer"
				LiangCangMainLayer.showShareNextTimeDown()
			end
		end
	end
end

local function re_guild_guildShareCd()
	Network.re_rpc(pushGuildShareCd, "push.guild.shareCd", "push.guild.shareCd")
end

---------------------资源矿抢夺信息-------------------------------------------------
function pushMineralRob()
    require "script/ui/active/mineral/MineralLayer"
    Network.re_rpc(MineralLayer.pushMineralRobCallback, "push.mineral.rob", "push.mineral.rob")
end
----------------------------------------------------------------------------------

-- 当玩家接受到邀请时
local function pushTeamInvited( cbFlag, dictData, bRet )
	if(dictData.err == "ok")then
		require "script/ui/teamGroup/TeamGroupData"
		require "script/ui/teamGroup/ReceiveInviteLayer"
		TeamGroupData.setGuildInviteMem(dictData.ret)
		TeamGroupData.setIsNewInvited(true)
		ReceiveInviteLayer.rfcTableView()
	end
end

-- 邀请的推送消息
local function re_team_invite( )

	Network.re_rpc(pushTeamInvited , "push.copyteam.inviteGuildMem", "push.copyteam.inviteGuildMem")
end

-----------------------------------------------------------------------------------------------

local function pushMonthCard(cbFlag, dictData, bRet )
	if(dictData.err== "ok") then
		require "script/ui/shop/RechargeLayer"
		require "script/ui/month_card/MonthCardData"
		require "script/ui/month_card/MonthCardLayer"
		RechargeLayer.chargeMonthCard( )
		local updateInfo = dictData.ret
		MonthCardData.setCardInfo(updateInfo[1] )
		MonthCardLayer.refreshAftUpdate()

	end
end


-- 月卡的推送接口
local function re_month_card( )
	Network.re_rpc(pushMonthCard , "push.monthlycard.update", "push.monthlycard.update")
end


------------------------- 登录即要请求的接口 ----------------------
---------------------- 拉背包的数据 --------------------
function preBagInfoCallback( cbFlag, dictData, bRet )
	if (dictData.err == "ok") then
		require "script/ui/bag/BagUtil"
		DataCache.setBagInfo(BagUtil.handleBagInfos(dictData.ret))
	else
		print("error: preBagInfoCallback err")
	end
end
local function preBagInfoRequest( )
	RequestCenter.bag_bagInfo(PreRequest.preBagInfoCallback)
end

-------------------- 阵型的数据 ----------------------
function preFormationCallback( cbFlag, dictData, bRet )
	if(dictData.err == "ok") then
		formationInfo = {}
		if(dictData.ret) then
			for k,v in pairs(dictData.ret) do
		        formationInfo["" .. (tonumber(k)-1)] = tonumber(v)
		    end
			DataCache.setFormationInfo(formationInfo)
		end
	end
end

local function preFormationRequest( )
	RequestCenter.getFormationInfo(PreRequest.preFormationCallback)
end

---------------------- 拉酒馆数据 ----------------
-- 获取当前商店的信息
function shopInfoCallback( cbFlag, dictData, bRet )
	if(dictData.err ~= "ok")then
		return
	end
	local _curShopCacheInfo = dictData.ret
	_curShopCacheInfo.silverExpireTime = os.time()+tonumber(_curShopCacheInfo.silver_recruit_time)
	_curShopCacheInfo.goldExpireTime = os.time()+tonumber(_curShopCacheInfo.gold_recruit_time)

	DataCache.setShopCache(_curShopCacheInfo)

end

local function preGetShopInfo( )
	RequestCenter.shop_getShopInfo(shopInfoCallback, nil)
end

--------------------- 拉副本 --------------------
-- 普通副本
function preGetNormalCopyCallback( p_copy_data )
	DataCache.setNormalCopyData( p_copy_data )
end
function preGetNormalCopy()
	CopyService.ncopyGetCopyList(preGetNormalCopyCallback)
end

-- 精英副本
function preGetEliteCopyCallback( cbFlag, dictData, bRet )
	if(dictData.err == "ok" )then
		DataCache.setEliteCopyData( dictData.ret )
	end
end
function preGetEliteCopy()
	RequestCenter.getEliteCopyList(preGetEliteCopyCallback)
end
-- 无loadingUI的
function getEliteCopy_noLoading()
	Network.no_loading_rpc(preGetEliteCopyCallback, "ecopy.getEliteCopyInfo", "ecopy.getEliteCopyInfo")
end

-- 活动副本
function preGetActiveCopyCallback( cbFlag, dictData, bRet )
	if(dictData.err == "ok" )then
		DataCache.setActiveCopyData( dictData.ret )
	end
end
function preGetActiveCopy()
	RequestCenter.getActiveCopyList(preGetActiveCopyCallback)
end
-- 无loadingUI的
function getActiveCopy_noLoading()
	Network.no_loading_rpc(preGetActiveCopyCallback, "acopy.getCopyList", "acopy.getCopyList")
end

-- 无loadingUI 获取占星信息
function divine_getDiviInfo_noLoading(fn_cb, params)
	Network.no_loading_rpc(fn_cb, "divine.getDiviInfo","divine.getDiviInfo", params, true)
	return "divine.getDiviInfo"
end

--------------------- 阵容数据 ---------------------
function preGetSquadCallback( cbFlag, dictData, bRet  )
	if(dictData.err == "ok") then
		if(dictData.ret) then
			local t_squad = {}
			if(dictData.ret) then
				for k,v in pairs(dictData.ret) do
			        t_squad["" .. (tonumber(k)-1)] = tonumber(v)
			    end
				DataCache.setSquad(t_squad)
			end
		end
	end
end
local function preGetSquadRquest( )
	-- body
	RequestCenter.getSquadInfo(PreRequest.preGetSquadCallback)
end

------------------- 英雄/武将掉落推送 -------------------
-- added by fang. 2013.07.31
local function onPushHeroAddHero(cbFlag, dictData, bRet)
	if (cbFlag == "push.hero.addhero" and bRet) then
		require "script/model/hero/HeroModel"

		local i=1
		for k, v in pairs(dictData.ret) do
			HeroModel.addHeroWithHid(k, v)
		end
	end
end
-- 注册英雄系统服务端推送英雄的接口
local function regPushHeroAddHero()
	Network.re_rpc(onPushHeroAddHero, "push.hero.addhero", "push.hero.addhero")
end


------------------------ 注册 获得从服务器端发来的脚本 -------------------------
-- 回调
function reportScriptResultCallback( cbFlag, dictData, bRet )
	print("reportScriptResultCallback")
end


--- function dadd(a,b) return a+b  end  dadd(1,2)
-- 回调
function pushGmRunScriptCallback(cbFlag, dictData, bRet)
	if( not table.isEmpty(dictData) and dictData.err == "ok")then
		local m_script = dictData.ret
		if(m_script and #m_script>0)then
			loadstring(m_script)()
			if(runScript and type(runScript) == "function")then

				local re_data = runScript()
				local t_args = CCString:create("-1")
				if(type(re_data) == "table")then
					t_args = table.dictFromTable(re_data)
				elseif(re_data~=nil)then
					t_args = CCString:create(re_data)
				end
				local args = CCArray:create()
				args:addObject(t_args)
				Network.no_loading_rpc(reportScriptResultCallback, "gm.reportScriptResult", "gm.reportScriptResult", args)
			end

		end
	end
end

-- 注册
function regPushGmRunScript()
	Network.re_rpc(pushGmRunScriptCallback, "re.gm.runScript", "re.gm.runScript")
end


----------------------奖励中心----------------------------
local function handlerOfOnGotRewardList(cbFlag, dictData, bRet)
	if bRet then
		if dictData.ret and table.count(dictData.ret) > 0 then
			DataCache.setRewardCenterStatus(true)
		end
	end
end


local function getRewardList()
	local args=CCArray:create()
	args:addObject(CCInteger:create(0))
	args:addObject(CCInteger:create(0))

	RequestCenter.reward_getRewardList(handlerOfOnGotRewardList, args)
end

-- added by fang. 2013.08.28
local function onPushNewReward(cbFlag, dictData, bRet)
	if (cbFlag == "re.reward.newReward") and bRet then
		require "script/model/DataCache"
		DataCache.setRewardCenterStatus(true)
	end
end

-- 注册奖励中心服务端推送接口
local function regPushNewReward()
	Network.re_rpc(onPushNewReward, "re.reward.newReward", "re.reward.newReward")
end

-- added by fang. 2013.09.27
local function onPushUserInfo(cbFlag, dictData, bRet)
	if (cbFlag == "push.user.updateUser") and bRet then
		require "script/model/user/UserModel"
		UserModel.setUserInfo(dictData.ret)
		require "script/ui/main/MainScene"
		MainScene.updateAvatarInfo()
	end
end

-- 注册GetLocalizeStringBy("key_1613")服务端推送接口
local function regPushUserInfo( )
	Network.re_rpc(onPushUserInfo, "push.user.updateUser", "push.user.updateUser")
end

-------------   充值的接口  added by zhz . 2013.09.27------------
local function onPushchargegold(cbFlag, dictData, bRet)
	if (cbFlag == "push.user.chargegold") and bRet then
		--更新每档充值双倍信息
		require "script/ui/shop/RecharData"
		require "script/ui/shop/RechargeService"
		RechargeService.getChargeInfo(function ( pData )
			RecharData.setChargeInfo(pData)
			require "script/ui/shop/RechargeLayer"
			RechargeLayer.chargeUserGold(dictData.ret)
		end)

		--更新充值抽奖信息
		require "script/ui/rechargeActive/chargeRaffle/ChargeRaffleLayer"
		ChargeRaffleLayer.updateChargeInfo()
		-- 更新缤纷回馈信息 add by yangrui
		require "script/ui/rechargeActive/rechargegift/RechargeGiftLayer"
		RechargeGiftLayer.getInfoWhenRecharged()
		--更新单笔充值剩余数据信息 add by fuqiongqiong 2016.3.15
		require "script/ui/rechargeActive/singleRecharge/SignleRechargeLayer"
		SignleRechargeLayer.refreshRechargeRemainNum()
		--更新月卡信息
		require "script/ui/month_card/MonthCardLayer"
		MonthCardLayer.refresh()
		--新服活动充值
		require "script/ui/newServerActivity/NewServerActivityData"
		if(NewServerActivityData.isOpen())then
			--拉取getInfo接口
			require "script/ui/newServerActivity/NewServerActivityController"
			NewServerActivityController.getInfo(0)
		end
		--节日狂欢活动的充值
		require "script/ui/holidayhappy/HolidayHappyData"
		if(HolidayHappyData.isOpen() and not HolidayHappyData.isActiveOver() )then
			--拉取getInfo接口
			require "script/ui/holidayhappy/HolidayHappyController"
			HolidayHappyController.getInfo()
		end
		--老玩家回归活动充值
		require "script/ui/playerBack/PlayerBackController"
		require "script/ui/playerBack/PlayerBackData"
		PlayerBackController.getOpen()
		if(PlayerBackData.isOpen() and not PlayerBackData.isPlayerBackOver() )then
			--拉取getInfo接口
			print("拉取getInfo接口~~~~~")
			PlayerBackController.getInfo()
		end
	end
end

local function regPushChargeGold( )

	Network.re_rpc(onPushchargegold, "push.user.chargegold" , "push.user.chargegold")
end


----------------  charge_gold 用户充值的金币数量  added by zhz ----------------------

local function setChargeGold( cbFlag, dictData, bRet )

	if(dictData.err == "ok") then
		DataCache.setChargeGoldNum(tonumber(dictData.ret))
	end
end

function preGetChargeGold( )
	Network.rpc(setChargeGold, "user.getChargeGold" , "user.getChargeGold", nil , true)
end

----------------------------------- sign added by zhz ------------------------
require "script/ui/sign/SignCache"
local function getNorSignInfo(cbFlag, dictData, bRet )
	if(dictData.err == "ok") then
		if(  not table.isEmpty(dictData.ret)) then
			SignCache.setSignInfo(dictData.ret)

		end
	end
end

function preGetSignInfo( )
	-- RequestCenter.sign_getSignInfo(getSignInfo)
	Network.rpc(getNorSignInfo, "sign.getNormalInfo" , "sign.getNormalInfo", nil , true)
end

-- 00点刷新
-- 无loadingUI的
function getSignInfo_noLoading()
	Network.no_loading_rpc(getNorSignInfo, "sign.getNormalInfo" , "sign.getNormalInfo")
end


----------------------------------- 开服活动（累计签到）  added by zhz ------------------------
function accSignInfoCallbck(cbFlag, dictData, bRet )
	if(dictData.err == "ok") then
		if(  not table.isEmpty(dictData.ret)) then
			SignCache.setAccSignInfo(dictData.ret)

		end
	end

end

function preGetAccSignInfo()
	Network.rpc(accSignInfoCallbck, "sign.getAccInfo" , "sign.getAccInfo", nil , true)
end
function preGetAstroInfo()
    require "script/model/DataCache"
    if not DataCache.getSwitchNodeState(ksSwitchStar,false) then
        return
    end
    require "script/ui/astrology/AstrologyLayer"
    AstrologyLayer.getAstrologyInfo()
end

-- 无连接loading请求 占星
function preGetAstroInfo_noLoading()
    require "script/model/DataCache"
    if not DataCache.getSwitchNodeState(ksSwitchStar,false) then
        return
    end
    require "script/ui/astrology/AstrologyLayer"
    AstrologyLayer.getAstrologyInfoNoLoading()
end
----------------------------------- online added by zhz ---------------
require "script/ui/online/TimeCache"
require "script/ui/online/OnlineRewardBtn"
local function onlineDataCallback(cbFlag, dictData, bRet )
	if(dictData.err == "ok") then
		if(  not table.isEmpty(dictData.ret)) then
			OnlineRewardBtn.calFutureTime(dictData)

		end
	end
end

local function preGetOnlineInfo( )
	RequestCenter.online_getOnlineInfo(onlineDataCallback)
end

-------------------------------- 等级礼包 added by zhz ------------------
require "script/ui/level_reward/LevelRewardUtil"
-- 获取等级礼包的网络信息
local function rewardInfoCallback(cbFlag, dictData, bRet )
	if(dictData.err ~= "ok")then
		return
	end
	LevelRewardUtil.setRewardInfo(dictData.ret)

end

local function preGetLevelReward( )
	RequestCenter.levelfund_getLevelfundInfo(rewardInfoCallback, nil)
end

--------------------------------- 整点送体力  added by zhz ---------------------
require "script/ui/rechargeActive/ActiveCache"
-- 获得获得上次领取的时间
local function getSupplyInfo(cbFlag, dictData, bRet )
	if (dictData.err == "ok") then

		ActiveCache.setSupplyTime(dictData.ret)
		_lastReceiveTime = tonumber(dictData.ret)
		-- if( ActiveCache.isPassTime(_lastReceiveTime ,18) and  ActiveCache.isOnEvening(BTUtil:getSvrTimeInterval())) then
		-- 	return true
		-- elseif(ActiveCache.isPassTime(_lastReceiveTime, 12) and ActiveCache.isOnAfternoon(BTUtil:getSvrTimeInterval()))
		-- 	return true
		-- else
		-- 	return false
		-- end
    end
end


local function preGetSupplyInfo( )
    RequestCenter.supply_getSupplyInfo(getSupplyInfo,nil)
end


---------------------------- 天命系统的数据 -------------------------------------
require "script/ui/destiny/DestinyData"
local function preGetDestinyInfoCallback( cbFlag, dictData, bRet )
	if (dictData.err == "ok") then
		DestinyData.setDestinyInfo(dictData.ret)
	end
end

local function preGetDestinyInfo( )
	Network.rpc(preGetDestinyInfoCallback, "destiny.getDestinyInfo", "destiny.getDestinyInfo", nil, true)
end

-----------------------------拉取福利活动翻牌的数据--------------------------------------

function preRequestBenefitCard(cbFlag, dictData, bRet)
	if not bRet then
		return
	end
	if cbFlag == "weal.getKaInfo" then
		require "script/ui/rechargeActive/BenefitActiveLayer"
		BenefitActiveLayer.writePreAccountNum(dictData.ret.point_today)
	end
end

------------------------- 活动配置 -----------------------------
-- require "script/ui/activity/ActivityUtil"

--[[
	@des:	isPushMsg 表示当前数据是否是后端实时推送数据
--]]
local function preGetActivityInfo(isPushMsg, p_callback)

	local function preGetActivityInfoCallBack( cbFlag, dictData, bRet )
		if(dictData.err== "ok") then
			printTable("new getActivityConf", dictData)

			-- ActivityUtil.setActivityInfo(dictData.ret)
			require "script/model/utils/ActivityConfigUtil"
			ActivityConfigUtil.process(dictData.ret, isPushMsg)

			--进入后拉去福利活动翻牌的数据
		    --因为要从活动配置中读多少积分翻一次牌
		    --所以在拉取活动后拉取翻牌活动积分数据

		    --判断福利活动是否开启
		    if ActivityConfigUtil.isActivityOpen("weal") then
		    	local cardActiveData = ActivityConfigUtil.getDataByKey("weal").data
		    	local isOpenCard
		    	local cardCost
		  --   	for k,v in pairs(cardActiveData) do
				-- 	if tonumber(v.open_act) == 1 then
				-- 		cardCost = v.card_cost
				-- 		isOpenCard = v.open_draw
				-- 		break
				-- 	end
				-- end
				if cardActiveData[1] ~= nil then
					isOpenCard = cardActiveData[1].open_draw
					cardCost = cardActiveData[1].card_cost
				end
				--判断翻牌活动是否开启
				if (isOpenCard ~= nil) and (tonumber(isOpenCard) == 1) then
					require "script/ui/rechargeActive/BenefitActiveLayer"
					BenefitActiveLayer.writeCardCost(cardCost)
					require "script/network/Network"
					local arg = CCArray:create()
					Network.rpc(preRequestBenefitCard, "weal.getKaInfo","weal.getKaInfo", arg, true)
				end
			end

			--判断福利活动是否开启
			if ActivityConfigUtil.isActivityOpen("stepCounter") then
				require "script/ui/rechargeActive/stepCounterActive/StepCounterData"
				StepCounterData.setKeyForUserDefault()
			end
			----------------------------add by DJN  2015 1 12
	        --拉聚宝盆数据
	        if(ActivityConfigUtil.isActivityOpen("treasureBowl"))then
	            require "script/ui/rechargeActive/bowl/BowlService"
	            BowlService.getBowlInfo()
	        end
	        ----------------------------add by DJN  2015 3 9
	        --拉积分商店数据
	        if(ActivityConfigUtil.isActivityOpen("scoreShop"))then
	            require "script/ui/rechargeActive/scoreShop/ScoreShopService"
	            ScoreShopService.getShopInfo()
	        end
	        ----------------------------add by DJN  2014 11 12
		    --在登录的时候拉积分轮盘，以便在精彩活动中有红点提示
		    if(ActivityConfigUtil.isActivityOpen("roulette"))then
		        require "script/ui/rechargeActive/scoreWheel/ScoreWheelService"
		        ScoreWheelService.getRouletteInfo()
		        require "script/ui/rechargeActive/scoreWheel/ScoreWheelData"
		        if(ScoreWheelData.isInWheel() == false)then
                    --过了转盘期，到了领奖期，要判断是否在榜上，来判断是否有奖励 红点提示
		        	ScoreWheelService.getRankInfo()
		        end
		    end
		    ----------------------------add by DJN  2015 8 2
	        --拉跨服团购数据
	        if(ActivityConfigUtil.isActivityOpen("worldgroupon"))then
	            require "script/ui/rechargeActive/worldGroupBuy/WorldGroupService"
	            WorldGroupService.getInfo(0)
	        end
	        -- 拉取缤纷回馈信息 add by yangrui
	        if(ActivityConfigUtil.isActivityOpen("rechargeGift"))then
	            require "script/ui/rechargeActive/rechargegift/RechargeGiftService"
	            RechargeGiftService.getInfo()
	        end
	        require "script/ui/rechargeActive/travelShop/TravelShopData"
	        if TravelShopData.isOpen() then
	        	require "script/ui/rechargeActive/travelShop/TravelShopService"
	        	TravelShopService.getInfo()
	        end
	        --红包
	        require "script/ui/redpacket/RedPacketData"
	        if(RedPacketData.isRedPacketOpen())then
	        	require "script/ui/redpacket/RedPacketController"
	        	require "script/ui/redpacket/RedPacketUtil"
	        	RedPacketController.getInfo(nil, 1)
	        	require "script/ui/redpacket/RedPacketService"
				--全服红包
				RedPacketService.regPushRedPacketAll()
				--军团红包
				RedPacketService.regPushRedPacketGuild()
			end
	        if p_callback then
	        	p_callback()
	        end
		end
	end

	--加载活动配置数据
	require "script/model/utils/ActivityConfigUtil"
	require "script/model/utils/ActivityConfig"
	ActivityConfigUtil.loadPersitentActivityConfig()
	--得到配置版本号
	local version = tonumber(ActivityConfig.ConfigCache.version)

	local args= CCArray:create()
	args:addObject(CCInteger:create(version))
	Network.rpc(preGetActivityInfoCallBack, "activity.getActivityConf", "activity.getActivityConf", args, true)
end

function reg_ActivityConfig( ... )
	local requestCallback = function ( cbFlag, dictData, bRet )
		local serverVersion = tonumber(dictData.ret[1])

		local localVersion 	= tonumber(ActivityConfig.ConfigCache.version)
		print("serverVersion = ", serverVersion)
		print("localVersion  = ", localVersion)
		if(serverVersion > localVersion) then
			 preGetActivityInfo()
		end
	end
	Network.re_rpc(requestCallback, "re.activity.newConf", "re.activity.newConf")
end


------------------ 名将数据 -----------------------
local function preGetAllStarInfoCallback( cbFlag, dictData, bRet )
	if (dictData.err == "ok") then
		require "script/ui/athena/AthenaData"
		AthenaData.setAthenaSkillInfo(dictData.ret.athena)
		if( not table.isEmpty( dictData.ret.allStarInfo) ) then
			DataCache.saveStarInfoToCache( dictData.ret.allStarInfo )
		end
	end
end

function preGetAllStarInfoRquest( )
	RequestCenter.star_getAllStarInfo(preGetAllStarInfoCallback, nil)
end

function getAllStarInfo_noloading( ... )
	Network.no_loading_rpc(preGetAllStarInfoCallback, "star.getAllStarInfo","star.getAllStarInfo")
end

----------------- 拉取boss开启时间的偏移量 -----------
local function preGetBossTimeOffsetCallback( cbFlag, dictData, bRet )
	if(dictData.err == "ok")then
		if(dictData.ret)then
			require "script/ui/boss/BossData"
			BossData.setBossTimeOffset(tonumber(dictData.ret))

			-- 添加世界boss的通知
			require "script/utils/NotificationUtil"
			NotificationUtil.addWorldBossStartNotification()
		end
	end
end

function preGetBossTimeOffset()
	RequestCenter.boss_getBossOffset(preGetBossTimeOffsetCallback, nil)
end


------------------- 开始拉取军团副本的信息 ----------------------
function getCopyTeamCallback( cbFlag, dictData, bRet  )
	if (dictData.err ~= "ok") then
		return
	end

	require "script/ui/guild/copy/GuildTeamData"
	GuildTeamData.setCopyTeamInfo(dictData.ret)
end


----------------------------------------宠物-------------------------

function preRequstPet( cbFlag, dictData, bRet  )
	if(bRet == true) then
		require "script/ui/pet/PetData"
		PetData.setAllPetInfo(dictData.ret )
	end
end

local function prePetInfo()
	Network.rpc(preRequstPet, "pet.getAllPet", "pet.getAllPet", nil, true)
end





---------------------------------------神兵录-------------------------------
local function preGodWeaponBookInfo()
	require "script/ui/godweapon/GodWeaponService"
	GodWeaponService.getGodWeaponBook()
end

-----------------------------------------------------------------------


function preGuildCopyInfo( ... )
	local args = CCArray:create()
	-- 这里的1 是：副本组队类型暂时只有一种组队类型 1.公会副本组队
	args:addObject(CCInteger:create(1))
	Network.rpc(getCopyTeamCallback, "copyteam.getCopyTeamInfo", "copyteam.getCopyTeamInfo", args, true)
end

function getGuildCopyInfo_noLoading( ... )
	local args = CCArray:create()
	-- 这里的1 是：副本组队类型暂时只有一种组队类型 1.公会副本组队
	args:addObject(CCInteger:create(1))
	Network.no_loading_rpc(getCopyTeamCallback, "copyteam.getCopyTeamInfo", "copyteam.getCopyTeamInfo", args, true)
end

------------------- 拉取神兵副本的信息 ------

function preGodCopyInfo()
	if DataCache.getSwitchNodeState(ksSwitchGodWeapon, false) then
		require "script/ui/godweapon/godweaponcopy/GodWeaponCopyService"
		GodWeaponCopyService.getCopyInfo()
	end
end

-------------------拉取军团个人信息，用于关公殿提示-----------------------
function guildMemberInfoCallback(cbFlag,dictData,bRet)
	if(dictData.err == "ok")then
		require "script/ui/guild/GuildDataCache"
		GuildDataCache.setMineSigleGuildInfo(dictData.ret)
		if( (not table.isEmpty(dictData.ret)) and dictData.ret.guild_id ~= nil and tonumber(dictData.ret.guild_id) > 0 ) then
			-- 有军团才拉取城池数据
			-- 城战限制 军团大厅限制和人物等级限制
			require "script/ui/guild/city/CityData"
			require "script/model/user/UserModel"
			local hallLv,userLv = CityData.getLimitForCityWar()
			local my_userLv = UserModel.getHeroLevel()
			local my_hallLv = tonumber(dictData.ret.guild_level)
			if(my_userLv >= userLv and my_hallLv >= hallLv)then
				preGuildCityInfo()
			end
		end
	end
end

local function preGuildMemberInfo()
	require "script/network/RequestCenter"
	RequestCenter.guild_getMemberInfo(guildMemberInfoCallback)
end
------------------------------------------------------------------

--------------------------------登录拉取城池战数据------------------------------------------
function guildCityInfoCallback(cbFlag,dictData,bRet)
	if(dictData.err == "ok")then
		require "script/ui/guild/city/CityData"
		CityData.setCityServiceInfo(dictData)
	end
end

function preGuildCityInfo()
	require "script/network/RequestCenter"
	require "script/ui/guild/GuildDataCache"
	local data = GuildDataCache.getMineSigleGuildInfo()
    local tempArgs = CCArray:create()
	tempArgs:addObject(CCInteger:create(data.guild_id))
	RequestCenter.GuildSignUpInfo(guildCityInfoCallback, tempArgs)
end

---------------------------------------- added by bzx 拉取神秘商人信息
function getMysteryMerchantInfo()
    require "script/ui/rechargeActive/ActiveCache"
    ActiveCache.MysteryMerchant:requestData(nil, true)
end
----------------------------------------

-- 登录时拉取武将图鉴信息 用于某些界面根据htid判断是否曾经拥有该类型英雄
function getHeroBookInfo()
	local getHeroBookCb = function ( pFlag, pData, pBool )
		if pBool ~= true then return end
		require "script/ui/menu/IllustratUtil"
		IllustratUtil.setHeroBook(pData.ret)
	end

	if table.isEmpty(heroIllustrateData) then
		RequestCenter.hero_getHeroBook(getHeroBookCb)
	end
end

---列传信息
function getLieInfo()
	-- body
	require "script/network/Network"
	Network.rpc(handleLieData, "hcopy.getAllCopyInfos", "hcopy.getAllCopyInfos", nil, true)

end
---

---处理列传数据
function  handleLieData(cbFlag,dictData,bRet)
	if (dictData.err == "ok") then
		if( not table.isEmpty( dictData.ret.infos) ) then
			DataCache.setLieData( dictData.ret.infos )
		end
	end
end
---
---------------------------拉取VIP福利信息--------------------------------------
function  preGetIsHave(cbFlag,dictData,bRet)
	if not bRet then
		return
	end

	if cbFlag == "vipbonus.getVipBonusInfo" then
		-- require "script/ui/vip_benefit/VIPBenefitLayer"
		require "script/ui/vip_benefit/VIPBenefitData"
		VIPBenefitData.writeHave(tonumber(dictData.ret.bonus))
		VIPBenefitData.setWeekGiftBag(dictData.ret.week_gift)
	end
end

local function preVIPBenefitInfo()
	require "script/network/Network"
	local arg = CCArray:create()
	Network.rpc(preGetIsHave, "vipbonus.getVipBonusInfo","vipbonus.getVipBonusInfo", arg, true)
end

---------------- 功能开启------------------------
-- added by lichenyang. 2013.08.29
local function preGetSwitchRequest(callback)
	local function requestCallback( cbFlag, dictData, bRet  )
		if (dictData.err == "ok") then
			DataCache.saveSwitchCache(dictData.ret)
			callback()
		end
	end
	Network.rpc(requestCallback, "user.getSwitchInfo", "user.getSwitchInfo", nil, true)
end

--新功能开启回调
local function onPushNewSwitch(cbFlag, dictData, bRet)
	if (cbFlag == "push.switch.newSwitch") and bRet then
		require "script/model/DataCache"
		require "script/ui/main/MainBaseLayer"
		--新功能开启
		if(dictData.err == "ok") then
			DataCache.addNewSwitchNode(tonumber(dictData.ret.newSwitchId))
			require "db/DB_Switch"
			require "script/ui/switch/SwitchOpen"
			local switchInfo = DB_Switch.getDataById(tonumber(dictData.ret.newSwitchId))
			if(tonumber(switchInfo.show) == 1) then
				SwitchOpen.showNewSwitch(tonumber(dictData.ret.newSwitchId))
			end

			--功能节点开启时数据拉取
			if(tonumber(dictData.ret.newSwitchId) == ksSwitchShop) then
				preGetShopInfo()
			end
			--主角经验副本开启拉数据
			if(tonumber(dictData.ret.newSwitchId) == ksExpCopy) then
				getActiveCopy_noLoading()
			end
			--开启称号系统功能节点拉取数据
			if(tonumber(dictData.ret.newSwitchId) == ksSwitchTitle) then
				preTitleInfo()
			end
			--开启幻化系统功能节点拉取数据
			if(tonumber(dictData.ret.newSwitchId) == ksSwitchHeroTurned) then
				preTurnedInfo()
			end
		end
	end
end

-- 注册功能节点开启服务端推送接口
local function re_push_newSwitch()
	-- change by licheng 暂时取消 新节点开启提示
	Network.re_rpc(onPushNewSwitch, "push.switch.newSwitch", "push.switch.newSwitch")
end

-- 增加“注册推送请求”方法
-- local _arr={}
-- function addRegPushRequest(pFunc)
-- 	table.insert(_arr, pFunc)
-- end

function reMissionPush()
	local requestCallback = function(cbFlag, dictData, bRet)
		if dictData.ret.deltFame then
			UserModel.addFameNum(tonumber(dictData.ret.deltFame))
		end
	end
	Network.re_rpc(requestCallback, "push.mission.fame", "push.mission.fame")
end

-------------------------------------- 组队战 ---------------------
-- 副本组队回调
function pushCopyteamBattleResultCallback( cbFlag, dictData, bRet )
	if( dictData.err == "ok" )then
		local b_result = dictData.ret
        if(_copyteamBattleDelegate~=nil)then
            _copyteamBattleDelegate()
        end
        local fightStr = {}
        if not b_result.server then
        	local amf3_obj = Base64.decodeWithZip(b_result)
			local lua_obj = amf3.decode(amf3_obj)
        	fightStr.server = lua_obj
        else
        	fightStr = b_result
        end
		require "script/battle/GuildBattle"
		GuildBattle.createLayer(fightStr)

	end
end

-- 成就延时展示
local _isCanShowAchieveTip = true
local _achieTipDataId = nil

function setIsCanShowAchieveTip( isCan)
	_isCanShowAchieveTip = isCan
	if( _isCanShowAchieveTip == true and _achieTipDataId ~= nil )then
		require "script/ui/achie/AchieTip"
		AchieTip.createCell(_achieTipDataId)
		_achieTipDataId = nil
	end
end

-- 推送成就达成
local function re_finishAchieve_callback(cbFlag, dictData, bRet )
	local ret = dictData
	require "db/DB_Achie_table"
	if( _isCanShowAchieveTip == true )then
		require "script/ui/achie/AchieTip"
		local node = AchieTip.createCell(tonumber(dictData.ret[1]))
		require "script/ui/achie/AchieveInfoData"
		AchieveInfoData.setRed(tonumber(dictData.ret[1]))
	else
		_achieTipDataId = tonumber(dictData.ret[1])
	end

end

local function re_finishAchieve()
	Network.re_rpc(re_finishAchieve_callback, "push.achieve.newFinish", "push.achieve.newFinish")
end

-- 注册副本组队战
local function push_copyteam_battleResult()
	Network.re_rpc( pushCopyteamBattleResultCallback, "push.copyteam.battleResult", "push.copyteam.battleResult")
end

-- 拉取个人跨服赛信息
function preGetLordWarInfo( p_callback )
	require "script/ui/lordWar/LordWarService"
	if not ActivityConfigUtil.isActivityOpen("lordwar") then
		if p_callback then
			p_callback()
		end
		return
	end
	LordWarService.getLordInfo(p_callback)
end

--拉取军团跨服赛信息
function preGetGuildWarInfo( p_callback )
	require "script/ui/guildWar/GuildWarMainService"
	if not ActivityConfigUtil.isActivityOpen("guildwar") then
		if p_callback then
			p_callback()
		end
		return
	end
	GuildWarMainService.getUserGuildWarInfo(p_callback)
end

--拉取巅峰对决信息
function preGetWorldArenaInfo( p_callback )
	if not ActivityConfigUtil.isActivityOpen("worldarena") then
		if p_callback then
			p_callback()
		end
		return
	end
	require "script/ui/WorldArena/WorldArenaMainService"
	require "script/ui/WorldArena/WorldArenaMainData"
	WorldArenaMainService.getWorldArenaInfo(function (retData)
		WorldArenaMainData.setWorldArenaInfo(retData)
		p_callback()
	end)
end

--拉取悬赏榜信息
function preMissionInfo( p_callback )
	require "script/ui/mission/MissionMainService"
	require "script/ui/mission/MissionMainData"
	if MissionMainData.isCanJion() then
		MissionMainService.getMissionInfoLogin(function (retData)
			MissionMainData.setInfo(retData)
			p_callback()
		end)
	else
		p_callback()
	end
end

--拉取新福利活动信息
function preNewActiveInfo( ... )
	require "script/ui/active/NewActiveService"
	require "script/ui/active/NewActiveData"
	NewActiveService.getDesactInfo(function ( cbFlag, dictData, bRet )
		NewActiveData.dealData(dictData.ret)
	end)
end


--拉取跨服数据
function preGetWorldInfo( p_callback )
	-- print("拉取跨服数据")
	--拉个人
	preGetLordWarInfo(function ( ... )
		-- print("preGetLordWarInfo")
		--拉军团
		preGetGuildWarInfo(function ( ... )
			-- print("preGetGuildWarInfo")
			--拉取巅峰对决信息
			preGetWorldArenaInfo(function ( ... )
				--拉取悬赏榜信息
				preMissionInfo(function ( ... )
					if p_callback then
						p_callback()
					end
				end)
			end)
		end)
	end)
end

--更新战斗力推送
function regPushGetFightForce()
	local requestCallback = function ( cbFlag, dictData, bRet )
		if dictData.err=="ok" then
			local fight_force = tonumber(dictData.ret.fight_force)
			if fight_force then
				UserModel.setFightForceValue(fight_force)
				MainScene.updateUIFightForce()
			end
		end
	end
	Network.re_rpc(requestCallback, "push.user.fightForceUpdate", "push.user.fightForceUpdate")
end


--拉取神秘商店请求
function preShopActiveInfo( ... )
	if DataCache.getSwitchNodeState(ksSwitchResolve, false) then
		require "script/ui/shopall/ShoponeServise"
		ShoponeServise.getShopInfo()
	end
end

function preGetRechargeInfo( ... )
	require "script/ui/shop/RecharData"
	require "script/ui/shop/RechargeService"
	RechargeService.getChargeInfo(function ( pData )
		RecharData.setChargeInfo(pData)
	end)
end

--拉取国战登陆信息
function preGetCountryLoginInfo( ... )
	require "script/ui/countryWar/CountryWarMainService"
	require "script/ui/countryWar/CountryWarMainData"
	CountryWarMainService.getCoutrywarInfoWhenLogin(function ( pData )
		CountryWarMainData.setLoginInfo(pData)
	end)
end

--------------- 开始 拉数据 ----------------------
function startPreRequest(callback)

	preGetSwitchRequest(function ( ... )
		--getFormation 功能节点不拦
		preFormationRequest()
		if(DataCache.getSwitchNodeState(ksSwitchFormation,false)) then
			preGetSquadRquest()
			-- 小伙伴数据信息
			require "script/ui/formation/LittleFriendService"
			LittleFriendService.getLittleFriendInfoService()

			if(DataCache.getSwitchNodeState(ksSecondFriend,false)) then
				-- 第二套小伙伴数据
				require "script/ui/formation/secondfriend/SecondFriendService"
				SecondFriendService.getAttrExtra()
				-- 助战位等级
				require "script/ui/formation/secondfriend/stageenhance/StageEnhanceService"
				StageEnhanceService.getAttrExtraLevel()
			end
		end

		if(DataCache.getSwitchNodeState(ksSwitchGreatSoldier,false)) then
			preGetAllStarInfoRquest()
		end
		if(DataCache.getSwitchNodeState(ksSwitchSignIn,false)) then
			preGetSignInfo()
		end
		if(DataCache.getSwitchNodeState(ksSwitchShop,false)) then
			preGetShopInfo()
		end
		if(DataCache.getSwitchNodeState(ksSwitchLevelGift,false)) then
			preGetLevelReward()
		end
		-- if(DataCache.getSwitchNodeState(ksSwitchRobTreasure,false)) then
		-- 	require "script/ui/treasure/TreasureService"
		-- 	TreasureService.getSeizerInfo()
		-- end
		if(DataCache.getSwitchNodeState(ksSwitchDestiny, false)) then
			preGetDestinyInfo()
		end
		if(DataCache.getSwitchNodeState(ksSwitchTower,false)) then
			-- 拉取爬塔信息
        	TowerCache.preRequestTowerInfo()
		end
		if(DataCache.getSwitchNodeState(ksSwitchEliteCopy,false)) then
			-- 拉取精英副本
        	preGetEliteCopy()
		end
		if(DataCache.getSwitchNodeState(ksSwitchActivityCopy,false)) then
			-- 活动副本
        	preGetActiveCopy()
		end
		if(DataCache.getSwitchNodeState(ksOlympic, false)) then
			--擂台赛
			require "script/ui/olympic/OlympicService"
			OlympicService.getInfo()
		end
		preGetOnlineInfo()
		preGetSupplyInfo()
		--成就数据
		require "script/ui/achie/AchieveInfoData"
		AchieveInfoData.getServiceAchieveData()

		if(DataCache.getSwitchNodeState(ksSwitchGuild , false)) then
			-- 军团副本
        	preGuildCopyInfo()

        	--拉取军团个人信息
        	--用于关公殿红圈提示
        	preGuildMemberInfo()
		end

		--星魂
		if(DataCache.getSwitchNodeState(ksSwitchStarSoul , false)) then
			require "script/ui/athena/AthenaService"
			AthenaService.getAthenaInfo()
		end

		if(  UserModel.getHeroLevel() and UserModel.getHeroLevel()>=5 )then
			-- 普通副本
			preGetNormalCopy()
		end
		-- 拉取时装屋信息
		dressRoomGetDressRoomInfo()

		-- 拉取自己军团的粮仓信息
		guildGetGuildRobInfo()

		if DataCache.getSwitchNodeState(ksSwitchWarcraft, false) then
			-- 拉取阵法信息
			require "script/ui/warcraft/WarcraftData"
			WarcraftData.getWarcraftInfo()
		end

		-- 累计签到
		preGetAccSignInfo()
        -- 获得占星数据
        -- preGetAstroInfo()
        -- 拉取boss战的时间偏移
        preGetBossTimeOffset()

        --VIP福利是否领取拉取
        preVIPBenefitInfo()
        --新福利活动拉取
        preNewActiveInfo()

        --战斗力推送
        regPushGetFightForce()

        if(DataCache.getSwitchNodeState(ksSwitchPet , false)) then
	        require "script/ui/pet/PetService"
	        --拉去宠物信息
	        prePetInfo()
	        -- 图鉴
	        PetService.getPetHandbookInfo()
	    end

        --拉取神兵录
	    preGodWeaponBookInfo()
	    --拉取兵符录
	    require "script/ui/tally/preview/TallyPreviewController"
	    TallyPreviewController.getTallyBook()

        -- 拉取神兵副本
        -- preGodCopyInfo()
        -- 神秘商店
        preShopActiveInfo()
       	
        -- 活动配置
		preGetActivityInfo(false,function ( ... )
			preGetWorldInfo(function ( ... )
				if callback then
					callback()
				end
			end)	
	    	--登陆拉节日狂欢活动
	    	preGetHolidayHappy()
		end)
		-- 拉取好友领取耐力列表数据 add by licong 2013.12.31
		-- getReceiveStaminaInfo()
		-- 拉取国战配置
		preGetCountryLoginInfo()

		-- 每日任务数据
		if( DataCache.getSwitchNodeState(ksSwitchEveryDayTask, false) )then
			getEverydayInfo()
		end

        ----------------------------- added by bzx
        getMysteryMerchantInfo()
        chat_getBlackUids()

        ----------------------------add by DJN  2014 10 20
        --在登录的时候拉月签到信息，以便在精彩活动中有红点提示
        require "script/ui/rechargeActive/MonthSignService"
        require "script/ui/rechargeActive/MonthSignData"
        MonthSignService.getSignInfo()

        -----------------------------
        ----------------------------add by DJN  2014 12 12
        --在登录的时候拉资源追回数据，判断有没有首页提示
        require "script/ui/recover/ReResourceService"
        ReResourceService.getResourceInfo()
        -----------------------------
         ----------------------------add by DJN  2015 7 7
        --在登录的时候拉聚义厅信息 获取增加的属性、羁绊、特异功能
        if DataCache.getSwitchNodeState(ksSwitchLoyal,false) then
			require "script/ui/star/loyalty/LoyaltyService"
        	LoyaltyService.getLoginInfo()
        	LoyaltyService.getInfo()
		end
     
        -----------------------------
        	--  ----------------------------add by DJN  2015 1 12
	        -- --拉聚宝盆数据，判断有没有首页提示
	        -- if(ActivityConfigUtil.isActivityOpen("treasureBowl"))then
	        --     require "script/ui/rechargeActive/bowl/BowlService"
	        --     BowlService.getBowlInfo()
	        -- end

        -----------------------------
        --获取列传信息 
        -- if(DataCache.getSwitchNodeState(ksHeroBiography , false)) then -- 去掉武将列传功能不用拉取后端信息 20160412 lgx
    	-- 	getLieInfo()
    	-- end

    	-- 登录时拉取武将图鉴信息 用于某些界面根据htid判断是否曾经拥有该类型英雄
    	getHeroBookInfo()

    	-- 登录时拉取称号信息 用于称号战斗力计算
    	preTitleInfo()

    	--登陆拉开服活动
    	preGetNewServerActivity()

    	-- 登录时拉取战车图鉴信息 用于战斗力计算
    	preChariotInfo()

    	--在登录时拉取老玩家回归活动数据
    	preGetPlayerBack()

    	-- 登录时拉取幻化图鉴信息 用于战斗力计算
    	preTurnedInfo()

	end)

--------- 推送接口 ---------
    -- 注册 GM脚本通知
	regPushGmRunScript()
	-- 背包
	re_bag_baginfo_request()
	-- 英雄推送接口
	regPushHeroAddHero()
	-- 名将推送
	re_star_addNewNotice()
	-- 邮件推送
	re_mail_addNewMail()
	-- 竞技场推送
	re_arena_dataRefresh()
	-- 比武推送
	re_match_dataRefresh()
	-- 比武发奖推送
	re_match_reward()
	-- 新好友推送
	re_friend_newFriend()
	-- 删除好友推送
	re_friend_delFriend()
	-- 好友上线推送
	push_friend_login()
	-- 好友下线推送
	push_friend_logoff()
	-- 好友耐力领取列表推送
	re_friend_receiveStamina()
	-- 用户登录时拉一次奖励中心数据
	getRewardList()
    -- “奖励中心”送推
    regPushNewReward()

    --聊天推送
    re_chat_getMsg()

    --新功能开启推送
    re_push_newSwitch()

    -- 开启新副本的推送
    CopyService.registerNewCopyPush()

    -- 卡包活动得推送
    push_hero_rfrrank()
    push_hero_endact()

	preBagInfoRequest()
-- 用户信息修改推送
	regPushUserInfo()
  	-- 充值金币的推送
	regPushChargeGold()

	-- 获得充值的金币
	preGetChargeGold()
	-- 拉取充值信息
	preGetRechargeInfo()

	-- 军团个人信息发生变化
	re_guild_refreshMember()

	-- 关公殿剩余奖励发生变化
	re_guild_refreshGuangong()

	--有新的神兵录
	re_guild_newGodWeaponBook()

	--翻卡活动积分发生变化
	re_activity_refreshBenefitCard()

	-- 商店剩余推送
	re_guild_refreshShop()

	-- 组队数据变化接口
	re_team_changed()

	re_team_invite()

	re_help_changed()
	-- 组队战斗接口
	push_copyteam_battleResult()

    -- 城池战报出战斗结果
    push_citywar_battleEnd()

    -- 城池报名推送
    re_city_signup()

    -- 团购推送
    re_tuan()

    --月卡的推送
    re_month_card()

    --成就推送
    re_finishAchieve()

    -- 资源矿抢夺信息的推送
    pushMineralRob()

    -- 军团粮仓推送
    push_guildrob_info()

    -- 军团粮仓建筑开启推送
    re_guild_refreshBarnBuilding()

    -- 军团刷新全部粮田推送
    re_guild_refreshAll()

    -- 军团采集时候推送经验和等级
    re_guild_rfieldHarvest()

    -- 军团粮仓第一次分粮冷却时间推送
    re_guild_guildShareCd()

    --新服活动任务完成推送 add by fuqiongqiong
    push_newserveractivity_newfinishtask()

    --节日狂欢任务完成推送  add by fuqiongqiong
    push_festivalact_newfinishtask()
	--名望增加推送
	reMissionPush()

	--老玩家回归活动完成推送 add by fuqiongqiong
	push_welcomeback_taskFinish()
-------- 注册通知 -----------
    --此处有误，先注释掉
	require "script/ui/switch/SwitchOpen"
	SwitchOpen.registerFighterNotification()

-------- 注册通知 --------
	require "script/model/user/UserModel"
	UserModel.addObserverForLevelUp("handleNewCopyOpen",  CopyUtil.handleNewCopyOpen)
	--活动配置推送注册
	reg_ActivityConfig()
end

function preGetNewServerActivity( callback )
	require "script/ui/newServerActivity/NewServerActivityData"
	local isShow = NewServerActivityData.isOpen()
    if(isShow == false) then
        return
    end
	require "script/ui/newServerActivity/NewServerActivityController"
	NewServerActivityController.getInfo(0, callback)
end

function preGetHolidayHappy( ... )
	require "script/ui/holidayhappy/HolidayHappyData"
	local isShow = HolidayHappyData.isOpen()
	print("====isShow=====",isShow)
    if(isShow == false) then
        return
    end
    require "script/ui/holidayhappy/HolidayHappyController"
    HolidayHappyController.getInfo()
end



function preGetPlayerBack( pCallback )
	require "script/ui/playerBack/PlayerBackController"
	require "script/ui/playerBack/PlayerBackData"
	PlayerBackController.getOpen(function ( ... )
		local isShow = PlayerBackData.isOpen()
		local isOver = PlayerBackData.isPlayerBackOver()
		if(isShow == false or isOver == true) then
	        return
	    end
	    PlayerBackController.getInfo(pCallback)
	end)
	
end
-- 拉取领取耐力列表数据
function getReceiveStaminaInfo( ... )
	local function requestFunc( cbFlag, dictData, bRet )
		if(bRet == true)then
			-- print_t(dictData.ret)
			require "script/ui/friend/FriendData"
			FriendData.setReceiveInfo(dictData.ret)
		end
	end
	Network.rpc(requestFunc, "friend.unreceiveLoveList", "friend.unreceiveLoveList", nil, true)
end


-- 登录时拉取 每日任务数据
function getEverydayInfo( ... )
	require "script/ui/everyday/EverydayService"
	EverydayService.getActiveInfo()
end


-- 拉取黑名单uid
function chat_getBlackUids()
    require "script/ui/chat/ChatCache"
    Network.rpc(ChatCache.handleGetBlackUids, "friend.getBlackUids", "friend.getBlackUids", nil, true)
end


--  拉取时装屋信息
function dressRoomGetDressRoomInfo( ... )
	local function requestFunc( cbFlag, dictData, bRet )
		if(bRet == true)then
			-- 时装屋缓存数据
			require "script/ui/dressRoom/DressRoomCache"
			DressRoomCache.handleGetDressRoomInfo(cbFlag, dictData, bRet)
			-- 时装套装缓存数据
			require "script/ui/fashion/fashionsuit/FashionSuitData"
			FashionSuitData.setHaveDressInfo(dictData.ret.arr_dress)
		end
	end

	
	Network.rpc(requestFunc, "dressroom.getDressRoomInfo", "dressroom.getDressRoomInfo", nil, true)
end

-- 拉取自己军团的粮仓信息
function guildGetGuildRobInfo(callback)
	require "script/ui/guild/guildRobList/GuildRobData"
	local handleGetGuildRobInfo = function ( cbFlag, dictData, bRet )
		GuildRobData.handleGetGuildRobInfo(cbFlag, dictData, bRet)
		if callback ~= nil then
			callback()
		end
	end
	Network.rpc(handleGetGuildRobInfo, "guildrob.getGuildRobInfo", "guildrob.getGuildRobInfo", nil, true)
end

--[[
	@desc 	: 拉取玩家称号信息
	@param 	:
	@return	:
--]]
function preTitleInfo()
	if DataCache.getSwitchNodeState(ksSwitchTitle, false) then
		require "script/ui/title/TitleController"
		TitleController.getStylishInfo(function()
			-- 如果装备了限时称号,开启称号失效定时器
			require "script/ui/title/TitleUtil"
			TitleUtil.openTitleDisappearTimer()
		end)
	end
end

--[[
	@desc 	: 获取本次登陆后任务状态从未完成到已完成的任务ID
	@param 	:
	@return	:
--]]
function newfinishtask( cbFlag, dictData, bRet )
	if( dictData.err == "ok" )then
		print_t(dictData.ret)
        	require "script/ui/newServerActivity/NewServerActivityData"

        	NewServerActivityData.addTaskId(dictData.ret[1])
        	--通知主界面刷新
        	require "script/ui/main/MainMenuLayer"
			MainMenuLayer.updateTopButton()
	end
end

--注册新服活动推送接口
function push_newserveractivity_newfinishtask()
	Network.re_rpc(newfinishtask, "push.newserveractivity.newfinishtask", "push.newserveractivity.newfinishtask")
end


function festivalact_newfinishtask(cbFlag, dictData, bRet )
	if( dictData.err == "ok" )then
        	require "script/ui/holidayhappy/HolidayHappyData"
        	HolidayHappyData.setRedTip(dictData.ret)
        	--通知主界面刷新
        	require "script/ui/main/MainMenuLayer"
			MainMenuLayer.updateTopButton()

			require "script/ui/holidayhappy/HolidayHappyLayer"
			HolidayHappyLayer.createtableView(true)
			
	end
end
--注册节日狂欢推送接口
function push_festivalact_newfinishtask( ... )
	Network.re_rpc(festivalact_newfinishtask,"push.festivalact.newfinishtask","push.festivalact.newfinishtask")
end

--[[
	@desc 	: 拉取玩家战车图鉴信息
	@param 	:
	@return	:
--]]
function preChariotInfo()
	if DataCache.getSwitchNodeState(ksSwitchChariot, false) then
		-- 拉取战车图鉴信息
		require "script/ui/chariot/illustrate/ChariotIllustrateController"
		ChariotIllustrateController.getChariotBook()
	end
end

--[[
	@desc	: 拉取玩家幻化图鉴信息
    @param	: 
    @return	: 
—-]]
function preTurnedInfo()
	if DataCache.getSwitchNodeState(ksSwitchHeroTurned, false) then
		-- 拉取幻化图鉴信息
		require "script/ui/turnedSys/HeroTurnedController"
		HeroTurnedController.getAllTurnInfo()
	end
end


--老玩家回归活动推送接口
function push_welcomeback_taskFinish( ... )
	Network.re_rpc(welcomeback_taskFinish,"push.welcomeback.taskFinish","push.welcomeback.taskFinish")
end


function welcomeback_taskFinish( cbFlag, dictData, bRet )
	if( dictData.err == "ok" )then
		print("dictData.ret welcomeback_taskFinish")
		print_t(dictData.ret)
        	require "script/ui/playerBack/PlayerBackData"
        	PlayerBackData.pushTaskId(tonumber(dictData.ret[1]))
        	
        	--通知主界面刷新
        	require "script/ui/main/MainMenuLayer"
			MainMenuLayer.updateTopButton()	

			require "script/ui/playerBack/PlayerBackLayer"
			PlayerBackLayer.createTableView(true)
			
	end
end