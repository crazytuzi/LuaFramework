


local Util = require "Zeus.Logic.Util"
local ItemComposeUI = require "Zeus.UI.XmasterBag.ItemComposeUI"
local Bag = require "Zeus.UI.XmasterBag.UIBagMain"
local MapModel              = require 'Zeus.Model.Map'

local _M = {}
_M.__index = _M


local SWITH_TABLE = 
{
	Exchange = function (fun_ele)
		MenuMgrU.Instance:OpenUIByTag(GlobalHooks.UITAG.GameUIExchangeMain, 0, fun_ele.FunID)
	end,

	SocialFriend = function (fun_ele)
		MenuMgrU.Instance:OpenUIByTag(GlobalHooks.UITAG.GameUISocialMain, 0, 1)
	end,

	SocialEnemy = function (fun_ele)
		MenuMgrU.Instance:OpenUIByTag(GlobalHooks.UITAG.GameUISocialMain, 0, 2)
	end,

	SocialBlacklist = function (fun_ele)
		MenuMgrU.Instance:OpenUIByTag(GlobalHooks.UITAG.GameUISocialMain, 0, 3)
	end,

	SocialNews = function (fun_ele)
		MenuMgrU.Instance:OpenUIByTag(GlobalHooks.UITAG.GameUISocialMain, 0, 4)
	end,

	SocialChange = function (fun_ele)
		MenuMgrU.Instance:OpenUIByTag(GlobalHooks.UITAG.GameUISocialMain, 0, 5)
	end,

	Ally = function (fun_ele)
        GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUISocialMain, 0, GlobalHooks.UITAG.GameUISocialDaoqun)
	end,

	
		
	

	
		
	

	JewelEnhance = function (fun_ele)
		
	end,

	
	
	
	
	
	
	

	Ride = function (fun_ele)
		GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIRideMain, 0)
	end,
	
	Pet = function (fun_ele)
		GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIPetMain, 0, 1)
	end,
	
	
	
	Character = function (fun_el)
		local menu,obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIRoleAttribute,0)
	end,
	Reworking = function (fun_el,param)
        GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIEquipReworkMain,0,param)
	end,
	FirstPay = function (fun_el)
		GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIFirstPay,-1,tostring(GlobalHooks.UITAG.GameUIFirstPay))
	end,
	
	
	
	
	
	
	
	
	
	
	
	LeaderBoard = function (fun_ele)
		GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUILeaderboard, 0, fun_ele.FunID)
	end,

	Consignment = function (fun_ele)
		local menu,obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIConsignmentMain, 0)
		
		if obj then
			obj:Start(0)
		end
	end,
	
	AllConsignment = function (fun_ele)
		local menu,obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIConsignmentMain, 0)
		
		if obj then
			obj:Start(1)
		end
	end,

	GuildContribute = function (fun_ele)
		if DataMgr.Instance.UserData.Guild then
		    local node,obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIGuildHall,0)
		    obj.setCall(obj.addMoney)
		else
		    GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIApplyGuild,0)
		end
	end,

	Title = function(fun_ele)
		
		local menu,obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIRoleBag,0)
    	
	end,

	Smelting = function (fun_ele)
        local menu,obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIBagMain,0)
		obj:OpenMelt()	
	end,
	
	GuildBoss = function (fun_ele)
		if DataMgr.Instance.UserData.Guild then
            GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIGuildBoss,0)
        else
           	GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.GUILD, "noguildTips"))
        end
	end,

	Mysterious = function (fun_ele)
		GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIMiJing)
	end,

	Guild = function (fun_ele)
		if DataMgr.Instance.UserData.Guild then
			GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIGuildHall,0)
		else
			GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIApplyGuild,0)
		end
	end,

	Arena = function (fun_ele)
		GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIMultiPvpFrame, 0)
	end,
	Ways = function (fun_ele, param)
		
	    if param ~= nil and param.s2c_itemCode ~= nil and string.gsub(param.s2c_itemCode, " ", "") ~= "" then
			GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIItemGetDetail, 0, param.s2c_itemCode)
		end
	end,

	
	
	
	
	
	

	
	
	
	

	
	
	
	

	
	
	
	

	
	
	
	

	PointToDungeon = function (fun_ele, fubenId)
		local sceneType = PublicConst.SceneTypeInt2Enum(DataMgr.Instance.UserData.SceneType)
		if PublicConst.SceneType.Dungeon  ~= sceneType then
			
			GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIFuben, 0, fubenId)
		end
	end,
	
	
	
	

	EquipEnhance = function (fun_ele, equipPos)
        
        local param = "strength"
        if(equipPos and string.len(equipPos) > 0) then
            equipPos = tonumber(equipPos)
            if equipPos > 0 then
                param = param.."|"..equipPos
            end
        end
        GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIRoleAttribute, 100,param)
	end,

	
	
	
	

	
	
	
	

	FirstCharge = function (fun_ele)
		
		GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIFirstPay, -1, 1)
	end,

	FirstCharge_Day = function (fun_ele)
		
		GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIDailyPay, 0, 1)
	end,

    Dreamland = function(fun_ele)
        
        GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIHuanJing, 0) 
    end,

    Activity = function(fun_ele)
        
        GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIActivityHJBoss, 0) 
    end,

    Gemstone = function(fun_ele,equipPos)
        
        
        local param = "inlay"
        GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIRoleAttribute, 100,param)
    end,

    Compose = function(fun_ele, code)
        local codes = { code }
        local composeProp = ItemComposeUI.getPropByCodes(codes)
        if composeProp then
            local param = composeProp.ID .. "-" .. composeProp.ParentID .. "-" .. composeProp.TagetCode
            local openBagParam = Bag.CreateTbtParam(0, GlobalHooks.UITAG.GameUICombine, param)
            GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIBagMain, 0, openBagParam)
        end
    end
}
local function checkNotDungeonScene()
	local sceneType = PublicConst.SceneTypeInt2Enum(DataMgr.Instance.UserData.SceneType)
	return PublicConst.SceneType.Dungeon  ~= sceneType
end

local SimpleOpenUIMap = {
	{ "VIP", 			GlobalHooks.UITAG.GameUIRechargeVip, "vip" },
	{ "Pay", 			GlobalHooks.UITAG.GameUIShop, "pay" },
	{ "Card", 			GlobalHooks.UITAG.GameUIShop, "card" },
	{ "Solo1", 			GlobalHooks.UITAG.GameUISolo, "info" },
	{ "Solo2", 			GlobalHooks.UITAG.GameUISolo, "reward" },
	{ "Activity", 		GlobalHooks.UITAG.GameUIActivityHJBoss, "Activity"},
	{ "Dungeons", 		GlobalHooks.UITAG.GameUIActivityHJBoss, "Dungeons"},
	{ "Lingzhu", 		GlobalHooks.UITAG.GameUIActivityHJBoss, "Lingzhu"},
	{ "Xianyuan", 		GlobalHooks.UITAG.GameUIActivityHJBoss, "Xianyuan"},
	{ "UltimateDungeons",GlobalHooks.UITAG.GameUIActivityHJBoss, "UltimateDungeons"},
	{ "JoinGuild", 		GlobalHooks.UITAG.GameUIApplyGuild },
	{ "Skill", 			GlobalHooks.UITAG.GameUISkillMain },
	{ "DiamondShop", 	GlobalHooks.UITAG.GameUIShop, "mall|diamond" },
	{ "TicketShop", 	GlobalHooks.UITAG.GameUIShop, "mall|ticket" },
	
	
	{ "strength",   GlobalHooks.UITAG.GameUIRoleAttribute,"strength"},
	{ "Gemstone",   GlobalHooks.UITAG.GameUIRoleAttribute,"inlay"},
	{ "Reworking",   GlobalHooks.UITAG.GameUIEquipReworkMain,GlobalHooks.UITAG.GameUIEquipReworkMake},
	{ "scurbbing",   GlobalHooks.UITAG.GameUIEquipReworkMain,GlobalHooks.UITAG.GameUIEquipReworkScurbing},
	{ "refine",   GlobalHooks.UITAG.GameUIEquipReworkMain,GlobalHooks.UITAG.GameUIEquipReworkRefine},
	{ "remake",   GlobalHooks.UITAG.GameUIEquipReworkMain,GlobalHooks.UITAG.GameUIEquipReworkReMake},
	{ "kaiguang",   GlobalHooks.UITAG.GameUIEquipReworkMain,GlobalHooks.UITAG.GameUIEquipReworkKaiguang},
	{ "Inherit",   GlobalHooks.UITAG.GameUIEquipReworkMain,GlobalHooks.UITAG.GameUIEquipReworkChuancheng},
	{ "DemonTower",GlobalHooks.UITAG.GameUIDemonTower},
	
	{ "LimitDungeons",   GlobalHooks.UITAG.GameUIResFubenSecondUI,"1"},
	{ "PetDungeons",   GlobalHooks.UITAG.GameUIResFubenSecondUI,"2"},
	{ "FarmDungeons",   GlobalHooks.UITAG.GameUIResFubenSecondUI,"3"},
	{ "Achievement",   GlobalHooks.UITAG.GameUITarget},
	{ "LuckyDraw",   GlobalHooks.UITAG.GameUISignXMDS, "tbt_choujiang"},
	{ "NewYearDraw",   GlobalHooks.UITAG.GameUISignXMDS, "tbt_choujiang1"},
	{ "ActivityCZTH",   GlobalHooks.UITAG.GameUISignXMDS, "tbt_czth"},
	{ "Blood",   GlobalHooks.UITAG.GameUIBloodMain},
	{ "BloodSuit",   GlobalHooks.UITAG.GameUIBloodSuit},
	{ "SoloFight",   GlobalHooks.UITAG.GameUISolo, "info" },
	{ "GroupFight",   GlobalHooks.UITAG.GameUI5V5Main},
	
}
for _,v in ipairs(SimpleOpenUIMap) do
	SWITH_TABLE[v[1]] = function()
		if not v[5] or v[5]() then
            if v[1] == "DiamondShop" or v[2] == "TicketShop" then
                
            end
			GlobalHooks.OpenUIOnlyOne(v[2], v[4] or 0, v[3])
		end
	end
end

local SWITH_PREFIX_TABLE = {
	DiamondShop = function(fun_ele, params, funUIDs)
		funUIDs[1] = "diamond"
        if params then
            if type(params) == "string" then
                table.insert(funUIDs,params)
            else
                table.insert(funUIDs, params.s2c_itemCode or params.code)
            end
        end
		GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIShop, 0, "mall|"..table.concat(funUIDs, '_'))
	end,
	TicketShop = function(fun_ele, params, funUIDs)
		funUIDs[1] = "ticket"
        if params then
            if type(params) == "string" then
                table.insert(funUIDs,params)
            else
                table.insert(funUIDs, params.s2c_itemCode or params.code)
            end
        end
		GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIShop, 0, "mall|"..table.concat(funUIDs, '_'))
	end,
	DungeonSupper = function(fun_ele, params, funUIDs)
		local sceneType = PublicConst.SceneTypeInt2Enum(DataMgr.Instance.UserData.SceneType)
		if PublicConst.SceneType.Dungeon  ~= sceneType then
			
			
			GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIFuben, 0, funUIDs[2])
		end
	end,

	GoldShop = function(fun_ele, params, funUIDs)
		if params == nil then
			params = ""
		end
		GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIShopScore, -1, "SundryShop|"..params)
	end,

	ScoreShop = function(fun_ele, params, funUIDs)
		if params == nil then
			params = ""
		end
		GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIShopScore, -1, "MallShop|"..params)
	end,

	FateShop = function(fun_ele, params, funUIDs)
		if params == nil then
			params = ""
		end
		GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIShopScore, -1, "FateShop|"..params)
	end,

	SoloShop = function(fun_ele, params, funUIDs)
		if params == nil then
			params = ""
		end
		GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIShopScore, -1, "AthleticShop|"..params)
	end,

	GuildShop = function(fun_ele, params, funUIDs)
		if params == nil then
			params = ""
		end
		GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIShopScore, -1, "GuildShop|"..params)
	end,

}


function GlobalHooks.DynamicPushs.OnFunGoToPush(ex, json)
  
  

  if ex == nil then
    local param = json:ToData()
    local id = param.s2c_funGoId
	local ret = unpack(GlobalHooks.DB.Find('FunGoTo', {FunGoID=id}))
	
	local content = ret.FunTips
	local title = ret.FunTitle
	local okStr = ret.okBtn
	local cancelStr = ret.cancelBtn
	local funId = ret.okBtnGoto

	if param.s2c_param then
		content = Util.FormatKV(content, param.s2c_param)
	end
	
	if funId == "Ways" then
		EventManager.Fire('Event.Goto', {id = funId, param = param})
	else
		if cancelStr ~= nil then
	    	GameAlertManager.Instance.AlertDialog:ShowAlertDialog(AlertDialog.PRIORITY_NORMAL, content, okStr, cancelStr, title, nil, 
	    		function(p)
	    			if param.s2c_id then
	    				
	    				Pomelo.PlayerHandler.gotoProcessRequest(param.s2c_id, emptyFunc)
	    			else
		    			EventManager.Fire('Event.Goto', {id = funId, param = param})
		    		end
	    		end, function() end)
		else
	    	GameAlertManager.Instance.AlertDialog:ShowAlertDialog(AlertDialog.PRIORITY_NORMAL, content, okStr, title, nil, 
	    		function(p) 
	    			EventManager.Fire('Event.Goto', {id = funId, param = param})
	    		end)
	    end
	end
  end
end

local function OnLocalAlertGoto(eventname,params)
	local ret = unpack(GlobalHooks.DB.Find('FunGoTo', {FunGoID=params.id}))
	local content = ret.FunTips
	local title = ret.FunTitle
	local okStr = ret.okBtn
	local cancelStr = ret.cancelBtn
	GameAlertManager.Instance.AlertDialog:ShowAlertDialog(AlertDialog.PRIORITY_NORMAL, 
		content, 
		okStr, 
		cancelStr,
		title, nil, 
		function(p)
			local funId = ret.okBtnGoto
			if funId and funId ~= '' then
				EventManager.Fire('Event.Goto', {id = funId, param = param})
  		end
  		if params.cb_ok then
  			params.cb_ok()
  		end
		end, 
		function()
  		if params.cb_cancel then
  			params.cb_cancel()
  		end			
		end)	
end


local function OnGoto(eventname,params)
    
	local ret = params.data or GlobalHooks.DB.Find('Functions',params.id)
	
	if not ret then return end
	if ret.FunUIID and ret.FunUIID ~= '' then
		
		
		if SWITH_TABLE[ret.FunUIID] then
           
              local rolelv = DataMgr.Instance.UserData:TryToGetLongAttribute(UserData.NotiFyStatus.LEVEL,0)
              local openLvData = GlobalHooks.DB.Find('OpenLv',{Fun = ret.FunUIID})[1]
              if  openLvData ~= nil then
                if rolelv<openLvData.OpenLv then
                    local  tipStr = tostring(openLvData.FunName) .. tostring(openLvData.Tips)
                    GameAlertManager.Instance:ShowNotify(tipStr)
                    return
                else
                    SWITH_TABLE[ret.FunUIID](ret,params.param)
                end
            else 
			    SWITH_TABLE[ret.FunUIID](ret,params.param)
            end
	    else
			local funUIIDS = string.split(ret.FunUIID, '_')
			if SWITH_PREFIX_TABLE[funUIIDS[1]] then
				SWITH_PREFIX_TABLE[funUIIDS[1]](ret, params.param, funUIIDS)
			end
		end
    elseif ret.FunID == "needBranch" then
        GameAlertManager.Instance:ShowNotify("可完成支线任务提升等级")
    elseif ret.FunID == "teacher" then
        



        local quests = DataMgr.Instance.QuestManager:GetAllQuest()
        local hasQuest = false
        local quest = nil
        for i = 0, quests.Count - 1 do
            local v = quests:get_Item(i)
            if v.Type == QuestData.QuestType.DAILY then
                hasQuest = true
                quest = v
                break;
            end
        end
        if hasQuest then
            
            quest:Seek()
        else
            local pointId = tonumber(ret.ToLocation)
            local mapId = tonumber(ret.SellIndex)
            local npcId = ret.ExchangeIndex
            
            if mapId == DataMgr.Instance.UserData.MapID then
                DataMgr.Instance.UserData:StartSeek(mapId,pointId,MoveData.MOVE_TYPE_NPCTALK, npcId)
            else
                EventManager.Fire("Event.Quest.CancelAuto", {});
                DataMgr.Instance.UserData:StartSeekAfterChangeScene(mapId, pointId, MoveData.MOVE_TYPE_NPCTALK, npcId)
                local param = {
                    ["areaID"] = ret.SellIndex
                }
                EventManager.Fire('Event.Delivery.Show', param)
            end
        end
    elseif ret.FunID == "oneDragon" then
        
        if DataMgr.Instance.TeamData.HasTeam then
            local quests = DataMgr.Instance.QuestManager:GetAllQuest()
            local hasQuest = false
            local quest = nil
            for i = 0, quests.Count - 1 do
                local v = quests:get_Item(i)
                if v.Type == QuestData.QuestType.RUNNING then
                    hasQuest = true
                    quest = v
                    break;
                end
            end
            if not DataMgr.Instance.TeamData:IsLeader() then
                if DataMgr.Instance.TeamData.TeamFollow == 1 then
                    GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.TEAM, "followCannotOperateTip"))
                    return
                end
                if hasQuest then
                    GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.TEAM, "onlyLeaderDo"))
                    return
                end
            end
            if hasQuest then
                
                quest:Seek()
            else
                local pointId = tonumber(ret.ToLocation)
                local mapId = tonumber(ret.SellIndex)
                local npcId = ret.ExchangeIndex
                if mapId == DataMgr.Instance.UserData.MapID then
                    DataMgr.Instance.UserData:StartSeek(mapId,pointId,MoveData.MOVE_TYPE_NPCTALK, npcId)
                else
                    EventManager.Fire("Event.Quest.CancelAuto", {});
                    DataMgr.Instance.UserData:StartSeekAfterChangeScene(mapId, pointId, MoveData.MOVE_TYPE_NPCTALK, npcId)
                    local param = {
                        ["areaID"] = ret.SellIndex
                    }
                    EventManager.Fire('Event.Delivery.Show', param)
                end
            end
        else
            
            GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUITeamMain, 0, "platform|find|1010,1")
        end
    elseif ret.FunID == "Gotofish" then
        local pointId = tonumber(ret.ToLocation)
        local mapId = tonumber(ret.SellIndex)
        local npcId = ret.ExchangeIndex
        if mapId == DataMgr.Instance.UserData.MapID then
            DataMgr.Instance.UserData:StartSeek(mapId,pointId,MoveData.MOVE_TYPE_PICKITEM,npcId )
        else
            EventManager.Fire("Event.Quest.CancelAuto", {});
            DataMgr.Instance.UserData:StartSeekAfterChangeScene(mapId, pointId, MoveData.MOVE_TYPE_PICKITEM, npcId)
            local param = {
                ["areaID"] = ret.SellIndex
            }
            EventManager.Fire('Event.Delivery.Show', param)
        end
        GlobalHooks.CloseUI(GlobalHooks.UITAG.GameUIQuestSubmitItem)
	elseif ret.ToLocation > 0 then
		
		Pomelo.PlayerHandler.transportRequest(ret.ToLocation,function() end)
	end
end


local function initial()
	EventManager.Subscribe("Event.Goto",OnGoto)
	EventManager.Subscribe("Event.Goto.Alert",OnLocalAlertGoto)
end


function _M.InitNetWork()
  
  
  Pomelo.GameSocket.functionGoToPush(GlobalHooks.DynamicPushs.OnFunGoToPush)
end

_M.initial = initial

return _M
