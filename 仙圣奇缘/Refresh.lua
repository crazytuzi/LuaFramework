local function SendNoticy()
	
end

local function SendForbidMsg()
	local name = "田家骏1" --封号玩家名称
	local hours = 24*3 --持续时间 最低一小时

	local msg = zone_pb.AddForbidLoginRole()
	msg.name = name
	msg.hours = hours
	g_MsgMgr:sendMsg(msgid_pb.MSGID_ADD_FORBID_LOGIN_ROLE, msg)
end

local function SendDelForbidMsg()
	local name = "田家骏1" --取消封号玩家名称

	local msg = zone_pb.DelForbidLoginRole()
	msg.name = name
	g_MsgMgr:sendMsg(msgid_pb.MSGID_DEL_FORBID_LOGIN_ROLE, msg)
end

local function SendSeverDrop()
	local title = "答题奖励"				--标题
	local context  = "今日答题环节结束。共问7个问题。玩家比较积极活跃。由于没提前设置好奖励规则，所以有个玩家得两次奖励。今天先发两次奖励。以后会说明奖励规则。奖励1000元宝."			--邮件内容
	cclog("s1")
	--local title = "删档充值返还"				--标题
	--local context = "亲爱的玩家，您在《斩仙传奇》删档前充值了2000元，现向您额外返还20000元宝"			--邮件内容	
	
	local pathfile = "role_id.txt"			--服务器生成的发送对象文件 "xxx/xxx/main.lua"
	local account_List = {}--

	--掉落id (掉落表) 里面要填充单个的物品信息
	--
	--[[
		enum ITEM_TYPE
		{
			ITEM_TYPE_CARD 				= 1;				//卡牌
			ITEM_TYPE_EQUIP 			= 2;				//装备
			ITEM_TYPE_ARRAYMETHOD 		= 3;				//阵法(暂时作废)
			ITEM_TYPE_FATE 				= 4;				//命格
			ITEM_TYPE_CARD_GOD 			= 5;				//魂魄 星级没用的了
			ITEM_TYPE_MATERIAL 			= 6;				//ItemBase(道具)
			ITEM_TYPE_SOUL 				= 7;				//卡魂
			ITEM_TYPE_MASTER_EXP 		= 8;				//掌门阅历
			ITEM_TYPE_MASTER_ENERGY 	= 9;				//体力
			ITEM_TYPE_COUPONS 			= 10;				//点券、元宝
			ITEM_TYPE_GOLDS 			= 11;				//金币、铜钱
			ITEM_TYPE_PRESTIGE 			= 12;				//声望
			ITEM_TYPE_KNOWLEDGE 		= 13;				//学识
			ITEM_TYPE_INCENSE 			= 14;				//香火
			ITEM_TYPE_POWER 			= 15;				//神力
			ITEM_TYPE_ARENA_TIME 		= 16;				//竞技场挑战次数
			ITEM_TYPE_ESSENCE 			= 17;				//灵力
			ITEM_TYPE_FRIENDHEART 		= 18;				//友情之心
			ITEM_TYPE_CARDEXPINBATTLE 	= 19;				//出战伙伴经验
			ITEM_TYPE_XIAN_LING 		= 20;				//仙令
			ITEM_TYPE_DRAGON_BALL 		= 21;				//龙珠
			ITEM_TYPE_XIANMAI_ONE_KEY	= 22;				// 一键消除
			ITEM_TYPE_XIANMAI_BA_ZHE	= 23;				// 霸者横栏			
			ITEM_TYPE_XIANMAI_LIAN_SUO	= 24;				// 消除连锁
			ITEM_TYPE_XIANMAI_DOU_ZHUAN	= 25;				// 斗转星移
			ITEM_TYPE_XIANMAI_DIAN_DAO	= 26;				// 颠倒乾坤
			ITEM_TYPE_XIANMAI_ELEMENT_METAL = 33; 			//金灵核
			ITEM_TYPE_XIANMAI_ELEMENT_NATURE = 34;			 //木灵核
			ITEM_TYPE_XIANMAI_ELEMENT_WATER = 35; 			//水灵核
			ITEM_TYPE_XIANMAI_ELEMENT_FIRE = 36; 			//火灵核
			ITEM_TYPE_XIANMAI_ELEMENT_EARTH = 37; 			//土灵核
			ITEM_TYPE_XIANMAI_ELEMENT_AIR = 38; 			//风灵核
			ITEM_TYPE_XIANMAI_ELEMENT_LIGHTNING = 39;		//雷灵核
			ITEM_TYPE_SECRET_JIANGHUN = 40; 				//将魂石
			ITEM_TYPE_SECRET_REFRESH_TOKEN = 41; 			//将魂令
		}
	]]
	local DropResult =
	{
		 {
			 ["drop_item_type"] 		= 10 ,				-- 类型 ITEM_TYPE 见上面注释 （直接填 int）
			 ["drop_item_config_id"] = 0 ,				-- int
			 ["drop_item_star_lv"] 	= 0 ,				-- int
			 ["drop_item_lv"] 		= 0 ,				-- int
			 ["drop_item_num"] 		= 1000 				-- int
		 }
	}

	for line in io.lines(pathfile) do
		if line then
			print("==========>发送GM礼包="..tonumber(line))
			table.insert(account_List, tonumber(line))
		end
	end

	if #account_List == 0 then return end
cclog("s2")
	local msg = zone_pb.SendSysMailToRole()
	msg.title = title
	msg.text = context

cclog("s3")
	--添加列表
	for k, v in ipairs(account_List)do
		table.insert(msg.role_id_list, v)
	end
	
	--msg.drop_result = common_pb.DropResult()
	msg.drop_result.drop_id = 1
	
	--添加掉落
	for m, n in ipairs(DropResult)do
		local Drop = common_pb.DropInfo()
		Drop.drop_item_type 		= n.drop_item_type
		Drop.drop_item_config_id 	= n.drop_item_config_id
		Drop.drop_item_star_lv		= n.drop_item_star_lv
		Drop.drop_item_lv 			= n.drop_item_lv
		Drop.drop_item_num 			= n.drop_item_num

		table.insert(msg.drop_result.drop_lst, Drop)
	end
	

	g_MsgMgr:sendMsg(msgid_pb.MSGID_SEND_SYS_MAIL_TO_ROLE, msg)
end

local function SendMailTest()
					local msg = common_pb.BroadcastMail()
					
					msg.title = "开服狂欢领奖魂魄BUG补偿"
					msg.context = "补偿魂魄100"
					--msg.drop_result._is_present_in_parent = true
					msg.drop_result.drop_id = 0
						
					msg.is_male = true
					local Drop = common_pb.DropInfo()
					Drop.drop_item_type 		= 5
					Drop.drop_item_config_id 	= 3001
					Drop.drop_item_star_lv		= 0
					Drop.drop_item_lv 			= 0
					Drop.drop_item_num 			= 100
					
				
				--[[						
					msg.is_male = false
					local Drop = common_pb.DropInfo()
					Drop.drop_item_type 		= 5
					Drop.drop_item_config_id 	= 3002
					Drop.drop_item_star_lv		= 0
					Drop.drop_item_lv 			= 0
					Drop.drop_item_num 			= 100
--]]
					--table.insert(drop_result.drop_lst, Drop)
                    table.insert(msg.drop_result.drop_lst, Drop)
					local szStr = msg:SerializeToString()
					
					g_MsgMgr:sendMsg(msgid_pb.MSGID_SEND_BROADCAST_MAIL, msg)
end




local function checkspine()
	local total = 0
	local tbtest = {}


	for k, v in pairs(ConfigMgr["CardBase"]) do

		for j, l in pairs(v) do
			-- if "NvFeiZei1" ~= v.SpineAnimation and
			-- "ZhiZHuHuang" ~= v.SpineAnimation and
			-- "ZhiZHuLv" ~= v.SpineAnimation and
			-- "LinFuJiaDing" ~= v.SpineAnimation and
			-- "LinFuDaShou" ~= v.SpineAnimation and
			-- "JiangShiNv2" ~= v.SpineAnimation and
			-- "JiangShiNv1" ~= v.SpineAnimation and
			-- "ZhiZHuHei" ~= v.SpineAnimation and
		 --   "NvFeiZei2" ~= v.SpineAnimation and
		 --  	not tbtest[l.SpineAnimation] then
		 if not tbtest[v.SpineAnimation] then

				total = total + 1
			   	local szJson = string.format("SpineCharacter/%s.json", v.SpineAnimation)
				local szAtlas = string.format("SpineCharacter/%s.atlas", v.SpineAnimation)
					local skeletonNode = SkeletonAnimation:createWithFile(szJson, szAtlas, 1)
					cclog("=====CardBase===== spine name ="..v.SpineAnimation.." num ="..total)
					-- skeletonNode:retain()
					skeletonNode:release()

					tbtest[v.SpineAnimation] = 1
				
			end
		end
	end

	cclog(" SpineAnimation CardBase bOver")


	for k, v in pairs(ConfigMgr["MonsterBase"]) do
		
		-- if "NvFeiZei1" ~= v.SpineAnimation and
		-- 	"ZhiZHuHuang" ~= v.SpineAnimation and
		-- 	"ZhiZHuLv" ~= v.SpineAnimation and
		-- 	"LinFuJiaDing" ~= v.SpineAnimation and
		-- 	"LinFuDaShou" ~= v.SpineAnimation and
		-- 	"JiangShiNv2" ~= v.SpineAnimation and
		-- 	"JiangShiNv1" ~= v.SpineAnimation and
		-- 	"ZhiZHuHei" ~= v.SpineAnimation and
		--    "NvFeiZei2" ~= v.SpineAnimation and
		--   	not tbtest[v.SpineAnimation] then

		if not tbtest[v.SpineAnimation] then
			

		  	total = total + 1
		   	local szJson = string.format("SpineCharacter/%s.json", v.SpineAnimation)
			local szAtlas = string.format("SpineCharacter/%s.atlas", v.SpineAnimation)
				local skeletonNode = SkeletonAnimation:createWithFile(szJson, szAtlas, 1)
				cclog("====MonsterBase====== spine name ="..v.SpineAnimation.." num ="..total)
				-- skeletonNode:retain()
				skeletonNode:release()

				tbtest[v.SpineAnimation] = 1
			
		end
		
	end

	cclog(" SpineAnimation MonsterBase bOver")
end


local function plua(v)
    local function str(t)
        return type(t)=="string" and ('"' .. string.gsub(t,"\n","\\n") .. '"') or tostring(t)
    end

    local reg = {}
    local ret = {}
    local function _plua(k,t,tab)
        if type(t)=="table" then
            if reg[t]~=nil then
                ret[#ret+1] = reg[t] .. "\n"
            else
                reg[t] = tostring(k) .. "(" .. tostring(t) .. "),"
                ret[#ret+1] = "{\n"
                local old = tab
                tab = tab .. "    "
                for k,v in pairs(t) do
                    ret[#ret+1] = tab .. tostring(k) .. " = "
                    _plua(k,v,tab)
                end
                ret[#ret+1] = old .. "}, --" .. tostring(k) .. "\n"
            end
        else
            ret[#ret+1] = str(t) .. ",\n"
        end
    end

    _plua("root", v, "")
    return table.concat(ret)
end

local tinsert = table.insert
local function strsplit(v)
	local tb = {}
	for v in string.gmatch(v, "[^.]+") do
		tinsert(tb, v)
	end
	return tb
end

function print_lua(v)
	local vstr = "_G"
	local ret = _G
	local tb = strsplit(v)
	for _, str in ipairs(tb) do
		if not ret then break end
		vstr = vstr.."."..str
		ret = ret[str]
	end
	cclog(vstr .. " = ")
	cclog(plua(ret))
	--API_CreatThread(1000, "tesfunction")
end

local function ReloadLuaAll()
	package.loaded["LuaScripts/init"] = nil
	require("LuaScripts/init")
	g_MsgMgr:create() --初始化网络
	local sceneGame = LYP_GetLoadingScene()
	CCDirector:sharedDirector():replaceScene(sceneGame)
end

local function ReloadLuaFile()
	if(not package.loaded["LuaScripts/Refresh.lua"] )then
		require("LuaScripts/Refresh")
	end
	
	g_WndMgr:reset(true)
	LoadGamWndFile()
	
	g_WndMgr:openWnd("Game_Home")
	CCDirector:sharedDirector():replaceScene(mainWnd)
end


local function refreshBattle()
	--g_Hero:RequestGM(".date")
	g_bLocalMsg = true
	package.loaded["LuaScripts/BattleReport"] = nil
	require("LuaScripts/BattleReport")
	g_WndMgr:openWnd("Game_Battle", MsgData) 
end

local function ReLogin()
	g_Hero = nil
	package.loaded["LuaScripts/GameLogic/Class_Hero"] = nil
	require("LuaScripts/GameLogic/Class_Hero")
	
	local sceneGame = LYP_GetStartGameScene()
	CCDirector:sharedDirector():replaceScene(sceneGame)
end

local VK_F1      =      0x70
local VK_F2       =     0x71
local VK_F3       =      0x72
local VK_F4       =      0x73
local VK_F5       =      0x74
local VK_F6       =      0x75
local VK_F7       =     0x76
local VK_F8        =    0x77
local VK_F9        =    0x78
local VK_F10      =     0x79
local VK_F11      =     0x7A
local VK_F12      =     0x7B
--[[* 添加物品信息，也包括资源等,此gm命令使用掉落系统实现
* 命令格式：additem itemname configid nNum star lv; 注:itemname:物品名称， configid:配置表id nNum:物品数量 star:星级  lv 等级
* itemname 目前支持 {card,equip,arraymethod,fate,god,material,soul,exp,energy,
coupons,golds, prestige, knowledge,vip, incense, power, atimes}]]
--[[ incense 香贡
	power 神力
	atimes 竞技场挑战次数
--]]
--各种按键的处理,其他字符的按键处理可以相应处理
function WindowProc(wParam, lParam)
	-- cclog("WindowProc  "..wParam)
	if(wParam == 27)then --按键Esc
		if not g_GMConsole_CheckListOpen then
			g_WndMgr:showWnd("Game_GMConsole")
		end
	elseif(wParam == VK_F1)then --刷新脚本
		ReloadLuaFile()
	elseif(wParam == VK_F2)then --按键VK_F2
		ReLogin()
	elseif(wParam == VK_F3)then --重新加载该文件
		local filename = "LuaScripts/Refresh.lua"
		package.loaded[filename] = nil
		require(filename)
	elseif(wParam == VK_F4)then --刷新脚本并关闭新手引导
		ReloadLuaFile()
		g_nForceGuideMaxID = 0
	elseif(wParam == VK_F5)then --重新换角色
		-- g_Hero:RequestGM(".date -s 2015-06-30 23:58:01")
		if g_Hero.isF then 
			g_Hero.isF = false
			cclog("临时关闭 剧情对话")
		else
			g_Hero.isF = true
			cclog("对话可以每次都显示，重启游戏后没有效果")
		end
		
		---g_Hero:RequestGM(".additem dragon_ball 0 100000 1 1")
		g_Hero:RequestGM(".additem material 27 10 1 1")
	elseif(wParam == VK_F6)then --
		-- 将魂石
		g_Hero:RequestGM(".additem material 27 999 1 1")
		-- 将魂令
		g_Hero:RequestGM(".additem material 28 999 1 1")
		
		-- 任选道具
		-- g_Hero:RequestGM(".additem material 76 999 1 1")
		-- g_Hero:RequestGM(".additem material 77 999 1 1")
		-- g_Hero:RequestGM(".additem material 78 999 1 1")
		-- g_Hero:RequestGM(".additem material 79 999 1 1")
		-- g_Hero:RequestGM(".additem material 80 999 1 1")
		
		-- g_Hero:RequestGM(".additem material 86 999 1 1")
		-- g_Hero:RequestGM(".additem material 87 999 1 1")
		-- g_Hero:RequestGM(".additem material 88 999 1 1")
		-- g_Hero:RequestGM(".additem material 89 999 1 1")
		-- g_Hero:RequestGM(".additem material 90 999 1 1")
		
		-- g_Hero:RequestGM(".additem material 92 999 1 1")
		-- g_Hero:RequestGM(".additem material 94 999 1 1")
		
		-- g_Hero:RequestGM(".additem material 95 999 3 1")
		-- g_Hero:RequestGM(".additem material 95 999 4 1")
		-- g_Hero:RequestGM(".additem material 96 999 4 1")
		
		-- g_Hero:RequestGM(".additem material 97 999 1 1")
		-- g_Hero:RequestGM(".additem material 97 999 2 1")
		-- g_Hero:RequestGM(".additem material 97 999 3 1")
		-- g_Hero:RequestGM(".additem material 97 999 4 1")
		-- g_Hero:RequestGM(".additem material 97 999 5 1")
		
		-- g_Hero:RequestGM(".additem material 98 999 1 1")
		-- g_Hero:RequestGM(".additem material 98 999 2 1")
		-- g_Hero:RequestGM(".additem material 98 999 3 1")
		-- g_Hero:RequestGM(".additem material 98 999 4 1")
		-- g_Hero:RequestGM(".additem material 98 999 5 1")
		
		-- g_Hero:RequestGM(".additem material 3101 999 1 1")
		-- g_Hero:RequestGM(".additem material 3101 999 2 1")
		-- g_Hero:RequestGM(".additem material 3101 999 3 1")
		-- g_Hero:RequestGM(".additem material 3101 999 4 1")
		-- g_Hero:RequestGM(".additem material 3101 999 5 1")
		-- g_Hero:RequestGM(".additem material 3101 999 6 1")
		-- g_Hero:RequestGM(".additem material 3101 999 7 1")
		-- g_Hero:RequestGM(".additem material 3101 999 8 1")
		-- g_Hero:RequestGM(".additem material 3101 999 9 1")
		
		-- g_Hero:RequestGM(".additem material 3102 999 1 1")
		-- g_Hero:RequestGM(".additem material 3102 999 2 1")
		-- g_Hero:RequestGM(".additem material 3102 999 3 1")
		-- g_Hero:RequestGM(".additem material 3102 999 4 1")
		-- g_Hero:RequestGM(".additem material 3102 999 5 1")
		-- g_Hero:RequestGM(".additem material 3102 999 6 1")
		-- g_Hero:RequestGM(".additem material 3102 999 7 1")
		-- g_Hero:RequestGM(".additem material 3102 999 8 1")
		-- g_Hero:RequestGM(".additem material 3102 999 9 1")
		
		-- g_Hero:RequestGM(".additem material 3202 999 1 1")
		-- g_Hero:RequestGM(".additem material 3202 999 2 1")
		-- g_Hero:RequestGM(".additem material 3202 999 3 1")
		-- g_Hero:RequestGM(".additem material 3202 999 4 1")
		-- g_Hero:RequestGM(".additem material 3202 999 5 1")
		
		-- g_Hero:RequestGM(".additem material 3204 999 1 1")
		-- g_Hero:RequestGM(".additem material 3204 999 2 1")
		-- g_Hero:RequestGM(".additem material 3204 999 3 1")
		-- g_Hero:RequestGM(".additem material 3204 999 4 1")
		-- g_Hero:RequestGM(".additem material 3204 999 5 1")
		
		-- g_Hero:RequestGM(".additem material 3208 999 1 1")
		-- g_Hero:RequestGM(".additem material 3208 999 2 1")
		-- g_Hero:RequestGM(".additem material 3208 999 3 1")
		-- g_Hero:RequestGM(".additem material 3208 999 4 1")
		-- g_Hero:RequestGM(".additem material 3208 999 5 1")
		
		-- g_Hero:RequestGM(".additem material 3209 999 1 1")
		-- g_Hero:RequestGM(".additem material 3209 999 2 1")
		-- g_Hero:RequestGM(".additem material 3209 999 3 1")
		-- g_Hero:RequestGM(".additem material 3209 999 4 1")
		-- g_Hero:RequestGM(".additem material 3209 999 5 1")
		
		-- g_Hero:RequestGM(".additem material 3210 999 1 1")
	elseif(wParam == VK_F7)then --
		local function showBroadcast()
			g_Hero:RequestGM(".sys short_time_notice 1 本次删档内测将于21:30结束，到时服务器将会关闭，请加官方QQ群138133410并期待12月23日的不删档。")
		end
		showBroadcast()
		g_Timer:pushLimtCountTimer(300, 30, showBroadcast)
	elseif(wParam == VK_F8)then --
	SendSeverDrop()
	elseif(wParam == VK_F9)then --
		--CCTextureCache:sharedTextureCache():dumpCachedTextureInfo()
        --API_DumpProcessMem()
		local filename = "Config/CardBase.lua"
		package.loaded[filename] = nil
		require(filename)
	elseif wParam == 491 then
		-- cclog("增加主角经验")
		-- g_Hero:RequestGM(".additem knowledge 5002 500 5 105 4")
	elseif wParam == VK_F11 then
		g_MsgMgr:ignoreCheckWaitTime(true)
		g_Hero:RequestGM(".openallmap open_new_map 6")
		g_MsgMgr:ignoreCheckWaitTime(nil)
    elseif wParam == VK_F12 then
        g_Hero:RequestGM(".additem material 28 10 1 1")
	elseif wParam == 76 then --增加技能碎片
		-- g_Hero:RequestGM(".additem material 11011 10 3 1")
		-- g_Hero:RequestGM(".additem material 11012 10 4 1")
		-- g_Hero:RequestGM(".additem material 11013 10 4 1")
	end
end


	
--g_Hero:RequestGM(".additem golds 0 9900000 1 1")
