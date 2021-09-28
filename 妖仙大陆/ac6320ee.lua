



local _M = {}
_M.__index = _M
local Helper = require "Zeus.Logic.Helper"
local modules = {}

local function init()
  print("Battle Init")
  modules ={
    require "Zeus.Model.DataHelper",
    require "Zeus.Model.Player",
    require "Zeus.UI.UITag",
    require 'Zeus.UI.GameUINPCTalk',
    require 'Zeus.Logic.Goto',
    require 'Zeus.UI.GameUIQuest',
    
    require "Zeus.UI.LuaHudMgr",
    
    require "Zeus.UI.FuncEntryMenu",
    require "Zeus.UI.XmasterSocial.SocialUIMain",
    require "Zeus.UI.OpenUI",
    
    require 'Zeus.UI.NumInputMenu',
    require 'Zeus.UI.XmasterCommon.RoleRename',
    
    
    
    require "Zeus.Model.Item",
    require "Zeus.UI.XmasterMap.SceneMapU",
    require "Zeus.Model.Npc",
    
    
    require "Zeus.Model.Skill",
    require "Zeus.Model.Fashion",
    
    require "Zeus.UI.InteractiveMenu",
	require "Zeus.UI.Interactive2Menu",
    require "Zeus.Logic.drama.DramaManage",
    require "Zeus.Model.GS",
    require "Zeus.Model.AutoSetting",
    require "Zeus.Model.Mail",
    require "Zeus.Model.Chat",
    
    require "Zeus.Model.Pet",
    
    require "Zeus.Model.Sign",
    
    require "Zeus.Model.Daily",
    require "Zeus.Model.Friend",
    require "Zeus.Model.Daoyou",
    require "Zeus.Model.Mount",
    require "Zeus.Model.Achievement",
    require "Zeus.Model.Team",
    
    require "Zeus.Model.Title",
    
    require "Zeus.Model.Fuben",
    require "Zeus.Model.Relive",
    require "Zeus.UI.XmasterRelive.ReliveUI",
    
    require "Zeus.UI.GameUINewItems",
    require "Zeus.UI.GameUIPreviewItems",
    require 'Zeus.UI.FullBagTips',
    
    require 'Zeus.Model.Solo',
    require 'Zeus.Model.Welfare',
    require 'Zeus.UI.GameUIItemUseNow',
    require 'Zeus.UI.GameUIChangeLine',
    
    
    require 'Zeus.Model.Guild',
    require 'Zeus.Model.Leaderboard',
    require 'Zeus.Model.Arena',
    require 'Zeus.UI.XmasterArena.ArenaHud',
    require 'Zeus.UI.XmasterArena.ArenaUIEnd',
    require 'Zeus.Model.GuildDepot',
    require 'Zeus.Model.guildBless',
    
    
    
    require 'Zeus.UI.GameUIFishItem',
    require 'Zeus.Model.guildShop',
    require 'Zeus.Model.guildTech',
    require 'Zeus.Model.guildAuction',
    
    require 'Zeus.Model.FunctionOpen',
    
    
    
    
    require 'Zeus.Model.ItemCombine',
    require 'Zeus.Model.AD',
    require 'Zeus.Model.DemonTower',
    require 'Zeus.Model.5v5',
    require 'Zeus.Model.DailyActivity', 
    require 'Zeus.UI.XmasterLvTarget.LevelTargetUI',  
    require "Zeus.Model.BloodSoul", 
    require "Zeus.Model.GuildWar", 
    require "Zeus.Model.RedPacket", 
  }

  
  Helper.each_i(function (args)
    if type(args.val) == 'table' and args.val.initial then
      args.val.initial()
    end
  end,modules)
end

local function update(deltatime)
end

local function fin(relogin)
  Helper.each_i(function (args)
    if type(args.val) == 'table' and args.val.fin then
      args.val.fin(relogin)
    end
  end,modules)

  local remove_t = {}
  Helper.each_t(function (args)
    if string.sub(args.key, 0, 5) == "Zeus." then
      if relogin then
        table.insert(remove_t, args.key)
      elseif string.sub(args.key, 0, 10) ~= "Zeus.Model" and (type(args.val) ~= 'table' or not rawget(args.val, "dont_destroy")) then
        table.insert(remove_t, args.key)
      end
    end
  end,package.loaded)
  Helper.each_t(function (args)
    package.loaded[args.val] = nil
  end,remove_t)
  EventManager.UnsubscribeAll()
end

local function InitNetWork()
  Helper.each_i(function (args)
    if type(args.val) == 'table' and args.val.InitNetWork then
      args.val.InitNetWork()
    end
  end,modules)
end

_M.init = init
_M.update = update
_M.fin = fin
_M.InitNetWork = InitNetWork
return _M
