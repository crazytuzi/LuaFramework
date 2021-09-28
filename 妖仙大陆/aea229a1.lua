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

local suitAtlaIndex = {50,48,52,49,51,47,46,44}

local togglebtnDown = {67,65,69,68,66,62,63,64}
local togglebtnUp = {75,76,70,71,74,73,72,77}

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

local function Release3DModel()
  if self.model ~= nil then
        GameObject.Destroy(self.model.obj)
        IconGenerator.instance:ReleaseTexture(self.model.key)
  end
  self.model = nil
end

local function ShowPet3DModel(parent, data)
  local modelFile = data.AvatarId
  local obj, key = GameUtil.Add3DModelLua(parent, modelFile, {}, nil, 0, true)

  local scale = data.ModelPercent
  IconGenerator.instance:SetModelScale(key, Vector3.New(scale,scale, scale))
  IconGenerator.instance:SetModelPos(key, Vector3.New(0, tonumber(data.ModelY), tonumber(data.ModelZ)))
  IconGenerator.instance:SetCameraParam(key, 0.1, 20, 2)
  IconGenerator.instance:SetRotate(key, Vector3.New(0, tonumber(data.RoteY), 0))

  obj.transform.sizeDelta = UnityEngine.Vector2.New(parent.Height, parent.Height)
  local rawImage = obj:GetComponent("UnityEngine.UI.RawImage")
  rawImage.raycastTarget = false
  self.model = {}
  self.model.obj = obj
  self.model.key = key
  self.model.avatarMode = data == nil
end

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
  
  
  
  Util.NormalItemShowTouchClick(itemshow,achievementInfo.awardKey)
  

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
  
  if data.s2c_reward_status == 1 then
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

local function UpdateSuitInfo(data,index)
    local suitData = GlobalHooks.DB.Find("ArmourAttribute",{ID = index})[1]
    self.cvs_left.Visible = true
    Util.HZSetImage2(self.lb_left_name, "#dynamic_n/carnival/carnival.xml|carnival|"..suitAtlaIndex[index], true, LayoutStyle.IMAGE_STYLE_BACK_4_CENTER)
    local activity = 1
    for i,v in ipairs(data) do
      if v.id == index then
        activity = v.states  
        break
      end
    end

    if activity == 1 then
        self.lb_left_tips.Text = Util.GetText(TextConfig.Type.SUIT, "targettips")
    elseif activity == 2 then
        self.lb_left_tips.Text = Util.GetText(TextConfig.Type.SUIT, "canjihuo")
    else
      self.lb_left_tips.Text = Util.GetText(TextConfig.Type.SUIT, "havejihuo")
    end
    self.lb_left_bj.Visible = activity == 2

    
    local tmp = string.split(suitData.Prop, ":")
    local attrEle = GlobalHooks.DB.Find('Attribute', tonumber(tmp[1]))
    self.lb_add_name.Text = string.gsub(attrEle.attDesc,'{A}',tostring(tmp[2]))

    self.btn_left_go.TouchClick = function ()
        GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUITargetSuit, -1, "index")
        self.menu:Close()
    end

    Release3DModel()
    if suitData.AvatarId ~= "" then
      ShowPet3DModel(self.ib_left_3d, suitData)
      self.ib_left_3d.Visible = true
      self.ib_left_icon.Visible = false
    else
      self.ib_left_icon.Layout = XmdsUISystem.CreateLayoutFromFile("static_n/item/"..suitData.Icon..".png",LayoutStyle.IMAGE_STYLE_BACK_4, 8)
      self.ib_left_3d.Visible = false
      self.ib_left_icon.Visible = true
    end
end

local function InitChapter(sender)
    local index = sender.UserTag
    self.selectChapterIndex = index
    self.chapterId = self.AllChapters[index].TypeId

    self.lb_section_title.Text = Util.GetText(TextConfig.Type.ACHIEVEMENT, "chapterName", MasteryUtil.numToHanzi[index+1])
    self.lb_section_name.Text = self.AllChapters[index].Type
  
    AchievementAPI.requestAchievements(self.chapterId, function(data)
        RefreshList()
        SetChapterInfo(self.chapterId, data)
    end)

    AchievementAPI.GetHolyArmorsRequest(function(data)
        UpdateSuitInfo(data,index)
    end)

    if index <=4 then
        self.sp_list.Scrollable:LookAt(Vector2.New(0,0),true)
    else
        self.sp_list.Scrollable:LookAt(Vector2.New(self.cvs_section.Width*4,0),true)
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

local function OnEnter()
  self.ibList = {}

  self.sp_list.Scrollable.Container:RemoveAllChildren(true)
  
  if not EventManager.HasSubscribed("Event.Achievement.sortDataComplete", RefreshList) then
    EventManager.Subscribe("Event.Achievement.sortDataComplete", RefreshList)
  end

  self.AllChapters = AchievementUtil.getChapters()
  self.btnList = {}
  AchievementAPI.requestOpenChapter(function(data)
      self.openChapList = data
      for i=1,#self.AllChapters do
        local node = self.cvs_section:Clone()
        local button = node:FindChildByEditName("tbt_section", true)
        

        local ricon = node:FindChildByEditName("ib_ricon", true)
        InitChapterFlag(ricon,i)

        button.UserTag = i
        button.Visible = true
        
        
        
        

        local up = XmdsUISystem.CreateLayoutFroXml("#dynamic_n/carnival/carnival.xml|carnival|13", LayoutStyle.IMAGE_STYLE_BACK_4_CENTER, 8)
        local down = XmdsUISystem.CreateLayoutFroXml("#dynamic_n/carnival/carnival.xml|carnival|11", LayoutStyle.IMAGE_STYLE_V_036, 8)
        button:SetLayout(up, down)
        local atlas = XmdsUISystem.CreateAtlas("dynamic_n/carnival/carnival.xml","carnival")
        button:SetAtlasImageText(atlas, togglebtnUp[i], atlas, togglebtnDown[i])

        node.X = button.X+(i-1)*button.Width

        self.sp_list.Scrollable.Container:AddChild(node)
        table.insert(self.btnList,button)
      end
      Util.InitMultiToggleButton(function(sender)
        InitChapter(sender)
      end, self.btnList[1], self.btnList)
  end)
end

local function OnExit()
  Release3DModel()
  EventManager.Unsubscribe("Event.Achievement.sortDataComplete", RefreshList)
end

local ui_names = 
{
  
  {name = 'btn_close'},

  {name = 'lb_section_title'},
  {name = 'lb_section_name'},
  {name = 'lb_progress'},
  {name = 'cvs_reward'},

  {name = 'sp_list'},
  {name = 'sp_list1'},
  {name = 'lb_section_name'},
  {name = 'cvs_section'},
  {name = 'cvs_get_single'},

  {name = 'ib_open'},
  {name = 'ib_close'},
  {name = 'lb_bj_active'},

  {name = 'ib_left_icon'},
  {name = 'ib_left_3d'},
  {name = "lb_left_name"},
  {name = "lb_left_tips"},
  {name = "lb_add_name"},
  {name = "btn_left_go"},
  {name = 'lb_left_bj'},
  {name = 'cvs_left'},
  
  
  
}

local function InitCompnent()
  Util.CreateHZUICompsTable(self.menu,ui_names,self)

  self.cvs_section.Visible = false
  self.cvs_get_single.Visible = false
  self.cvs_left.Visible = false

  self.btn_close.TouchClick = function ()
    self.menu:Close()
  end
end

local function Init(params)
  self.menu = LuaMenuU.Create("xmds_ui/chapter/target.gui.xml", GlobalHooks.UITAG.GameUITarget)
  self.menu.Enable = true
  self.menu.mRoot.Enable = true
  self.menu.ShowType = UIShowType.HideBackHud

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
