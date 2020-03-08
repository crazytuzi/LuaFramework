local Lplus = require("Lplus")
local pb_helper = require("PB.pb_helper")
local ECGame = require("Main.ECGame")
local function on_instance_info(sender, msg)
  local game = ECGame.Instance()
  local instance = game.m_Instance
  local total_info = msg.total_info
  if total_info then
    local count = #msg.info
    local tbl = {}
    if count == 1 then
      tbl = instance.InstanceTotalInfo
    else
      instance.InstanceTotalInfo = tbl
    end
    for i = 1, count do
      local info = msg.info[i]
      tbl[info.tid] = {}
      local item = tbl[info.tid]
      item.count = info.count
      item.addition_count = info.addition_count
      item.max_difficulty = info.max_difficulty
    end
    count = #msg.passed_instance
    for i = 1, count do
      local tid = msg.passed_instance[i]
      instance.InstancePassInfo[tid] = tid
    end
    if count == 1 then
    end
  else
    local count = #msg.info
    for i = 1, count do
      local info = msg.info[i]
      local item = instance.InstanceTotalInfo[info.tid]
      if item ~= nil then
        item.count = info.count
        item.addition_count = info.addition_count
        item.max_difficulty = info.max_difficulty
      else
        instance.InstanceTotalInfo[info.tid] = {}
        item = instance.InstanceTotalInfo[info.tid]
        item.count = info.count
        item.addition_count = info.addition_count
        item.max_difficulty = info.max_difficulty
      end
    end
    count = #msg.passed_instance
    for i = 1, count do
      local tid = msg.passed_instance[i]
      instance.InstancePassInfo[tid] = tid
    end
  end
  local InstanceInfoEvent = require("Event.InstanceInfoEvent")
  ECGame.EventManager:raiseEvent(nil, InstanceInfoEvent())
end
pb_helper.AddHandler("gp_instance_info", on_instance_info)
local function on_hero_trial_config(sender, msg)
  local game = ECGame.Instance()
  local instance = game.m_Instance
  local herotbl = instance.HeroTrialInfo
  local info = msg.config
  herotbl.free_refresh_times = info.free_refresh_times
  herotbl.pay_refresh_times = info.pay_refresh_times
  herotbl.hero = info.cur_hero_tid
  local InstanceNotify = require("Event.InstanceNotify")
  local event = InstanceNotify.InstanceHeroTrial.new(info.cur_hero_tid, info.free_refresh_times)
  ECGame.EventManager:raiseEvent(nil, event)
end
pb_helper.AddHandler("gp_hero_trial_config", on_hero_trial_config)
