local _M = {}
_M.__index = _M

local Util = require "Zeus.Logic.Util"
local Item = require "Zeus.Model.Item"
local MasteryUtil       = require 'Zeus.UI.MasteryUtil'
local AchievementUtil = require "Zeus.UI.XmasterStronger.StrongerAchievementUtil"
local AchievementAPI = require "Zeus.Model.Achievement"

local self = {
    menu = nil,
}

local GROWUP_TARGET_FLAG = {
  3401,
  3402,
  3403,
  3404,
  3405,
  3406,
  3407,
  3408,
  3409,
  3410,
}

local function UpdateChapterFlag(index)
  local num = DataMgr.Instance.FlagPushData:GetFlagState(GROWUP_TARGET_FLAG[index])
  self.ibList[index].Visible = num ~= 0
end

local function InitChapterFlag(flagIb,index)
  table.insert(self.ibList,flagIb)
  UpdateChapterFlag(index)
end

local function RefreshCellData(cell, achievementInfo, achievementData)
  local icon = cell:FindChildByEditName("ib_icon",true)
  Util.HZSetImage(icon,achievementInfo.icon,false,LayoutStyle.IMAGE_STYLE_BACK_4)

  local nameLabel = cell:FindChildByEditName("lb_cross", true)
  nameLabel.Text = achievementInfo.name

  local desLabel = cell:FindChildByEditName("lb_help", true)
  desLabel.Text = achievementInfo.des.."("..achievementData.scheduleCurr.."/"..achievementInfo.TargetNum..")"

  local awardicon = cell:FindChildByEditName("ib_award_icon",true)
  awardicon.Enable = true
  local it = GlobalHooks.DB.Find("Items",achievementInfo.awardKey)
  local itemshow = Util.ShowItemShow(awardicon,it.Icon,it.Qcolor,1)

  awardicon.event_PointerDown = function (sender) 
      Util.ShowItemDetailTips(itemshow,Item.GetItemDetailByCode(achievementInfo.awardKey))
  end
  
  

  local awardNum = cell:FindChildByEditName("lb_num",true)
  awardNum.Text = achievementInfo.awardValue

  local btn_go = cell:FindChildByEditName("btn_go",true)
  local btn_get = cell:FindChildByEditName("btn_get",true)
  local ib_over = cell:FindChildByEditName("ib_over",true)
  local ib_not = cell:FindChildByEditName("ib_not",true)
  local lb_bj_active = cell:FindChildByEditName("lb_bj_active",true)

  btn_go.Visible = achievementData.status == 0
  btn_get.Visible = achievementData.status == 1
  ib_over.Visible = achievementData.status == 2
  ib_not.Visible = achievementData.status == 0
  lb_bj_active.Visible = achievementData.status == 1

  btn_go.Visible = false
  btn_go.TouchClick = function ()

  end

  btn_get.TouchClick = function ()
    if achievementData.status == 1 then
        AchievementAPI.requestReward(achievementData.id,1,function ()
          achievementData.status = 2
          AchievementAPI.sortAchievementListData()
          UpdateChapterFlag(self.selectChapterIndex)
          EventManager.Fire("Event.Achievement.sortDataComplete", {})
        end)
    end
  end
end

local function GetAchievementInfo(achievementList, id)
  for i,v in ipairs(achievementList) do
    if v.id == id then
      return v
    end
  end
end

local function RefreshList()
  local data = AchievementAPI.getAchievementListData()
  local achievementList = AchievementAPI.getAchievementList(self.chapterId)
  
  if data.s2c_achievements ~= nil and #data.s2c_achievements > 0 then
    self.sp_list1:Initialize(
            self.cvs_get_single.Width + 0, 
            self.cvs_get_single.Height + 0, 
            #data.s2c_achievements,
            1,
            self.cvs_get_single, 
            function(x, y, cell)
              local index = y + 1
              local achievementData = data.s2c_achievements[index]
              local achievementInfo = GetAchievementInfo(achievementList, achievementData.id)
              RefreshCellData(cell, achievementInfo, achievementData)
            end,
            function() end)
  else
    self.sp_list1.Scrollable.Container:RemoveAllChildren(true)
  end
end

local function SetChapterInfo(chapterId, data)
  local totalReward = 0
  if data.s2c_achievements then
    totalReward = #data.s2c_achievements
  end
  self.lb_progress.Text = data.s2c_rewardCount.."/"..totalReward

  self.ib_open.Visible = data.s2c_reward_status == 2
  self.lb_bj_active.Visible = data.s2c_reward_status == 1
  self.ib_close.Visible = data.s2c_reward_status == 0 or data.s2c_reward_status == 1
  
  if self.lb_bj_active.Visible == true then
    Util.showUIEffect(self.ib_close,3)
  else
    Util.clearAllEffect(self.ib_close)
  end

  self.cvs_reward.TouchClick = function ()
    if data.s2c_reward_status == 1 then
      AchievementAPI.requestReward(chapterId,0,function ()
          data.s2c_reward_status = 2
          SetChapterInfo(chapterId, data)
          UpdateChapterFlag(self.selectChapterIndex)
        end)
    else
      EventManager.Fire('Event.OnPreviewItems',{items = data.s2c_chest_view})
    end
  end
end

local function InitChapter(sender)
  if sender.Enable == true then
    local index = sender.UserTag
    self.selectChapterIndex = index
    self.chapterId = self.AllChapters[index].TypeId
    
    self.lb_section_title.Visible = true
    self.lb_section_name.Visible = true
    self.lb_progress.Visible = true
    self.cvs_reward.Visible = true

    self.lb_section_title.Text = Util.GetText(TextConfig.Type.ACHIEVEMENT, "chapterName", MasteryUtil.numToHanzi[index+1])
    self.lb_section_name.Text = self.AllChapters[index].Type
  
    AchievementAPI.requestAchievements(self.chapterId, function(data)
        RefreshList()
        SetChapterInfo(self.chapterId, data)
    end)
  end
end

local function isChapterOpen(id)
  if self.openChapList ~= nil then
    for i,v in ipairs(self.openChapList) do
      if v == self.AllChapters[id].TypeId then
        return true
      end
    end
  end
  return false
end

function _M.InitUI()
  self.ibList = {}

  self.lb_section_title.Visible = false
  self.lb_section_name.Visible = false
  self.lb_progress.Visible = false
  self.cvs_reward.Visible = false

  self.sp_list.Scrollable.Container:RemoveAllChildren(true)
  
  if not EventManager.HasSubscribed("Event.Achievement.sortDataComplete", RefreshList) then
    EventManager.Subscribe("Event.Achievement.sortDataComplete", RefreshList)
  end

  self.cvs_section.Visible = false
  self.cvs_get_single.Visible = false

  self.AllChapters = AchievementUtil.getChapters()
  self.btnList = {}
  AchievementAPI.requestOpenChapter(function(data)
      self.openChapList = data
      for i=1,#self.AllChapters do
        local node = self.cvs_section:Clone()
        local button = node:FindChildByEditName("tbt_section", true)
        local lockImg = node:FindChildByEditName("ib_lock", true)

        local ricon = node:FindChildByEditName("ib_ricon", true)
        InitChapterFlag(ricon,i)

        button.UserTag = i
        button.Visible = true
        button.Text = Util.GetText(TextConfig.Type.ACHIEVEMENT, "chapterName", MasteryUtil.numToHanzi[i+1])
        
        local isopen = isChapterOpen(i)
        button.Enable = isopen
        lockImg.Visible = not isopen
      
        node.X = button.X+(i-1)*button.Width
        self.sp_list.Scrollable.Container:AddChild(node)
        table.insert(self.btnList,button)
      end
    
      Util.InitMultiToggleButton(function(sender)
        InitChapter(sender)
      end, self.btnList[1], self.btnList)
  end)
end

local function OnEnter()

end

local function OnExit()
  EventManager.Unsubscribe("Event.Achievement.sortDataComplete", RefreshList)
end

local ui_names = 
{
  
  {name = 'sp_list'},
  {name = 'cvs_section'},
  {name = 'sp_list1'},
  {name = 'cvs_get_single'},
  {name = 'lb_section_title'},
  {name = 'lb_section_name'},
  {name = 'lb_progress'},
  {name = 'cvs_reward'},
  {name = 'ib_open'},
  {name = 'ib_close'},
  {name = 'lb_bj_active'},
}

local function InitCompnent()
  Util.CreateHZUICompsTable(self.menu,ui_names,self)
  _M.InitUI()
end

local function Init(params)
  self.menu = LuaMenuU.Create("xmds_ui/garden/zhongzi.gui.xml", GlobalHooks.UITAG.GameUIGardenSeeds)
  self.menu.Enable = true
  self.menu.mRoot.Enable = true
  InitCompnent()
  self.menu:SubscribOnEnter(OnEnter)
  self.menu:SubscribOnExit(OnExit)
  self.menu:SubscribOnDestory(function ()
    self = nil
  end)
  return self.menu
end

local function Create(params)
    self = {}
    setmetatable(self, _M)
    local node = Init(params)
    return self
end

return {Create = Create}
