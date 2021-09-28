local Helper = require 'Zeus.Logic.Helper'
local Util   = require 'Zeus.Logic.Util'
local ArenaModel = require 'Zeus.Model.Arena'
local ItemModel = require 'Zeus.Model.Item'
local TitleAPI = require "Zeus.Model.Title"

local ItemDetail = require 'Zeus.UI.XmasterBag.ItemDetailMenu'
local Leaderboard = require "Zeus.Model.Leaderboard"
local ServerTime = require "Zeus.Logic.ServerTime"

local _M = {}
_M.__index = _M


local MAP_TYPE = 4

local function Close(self)
  self.menu:Close()  
end



local Text = {
  rule = Util.GetText(TextConfig.Type.SOLO,'arenaRule'),
    titleTips = Util.GetText(TextConfig.Type.SOLO,'arenaTitleTips'),
    titleTips_click = Util.GetText(TextConfig.Type.SOLO,'arenaTitleTips2'),
    rankIndex = Util.GetText(TextConfig.Type.SOLO,'oneRank'),
    noneRankIndex = Util.GetText(TextConfig.Type.SOLO,'noneRankIndex'),
    sunReward = Util.GetText(TextConfig.Type.SOLO,'sunReward'),
    rewardStatus1 = Util.GetText(TextConfig.Type.SOLO,'rewardStatus1'),
  rewardStatus2 = Util.GetText(TextConfig.Type.SOLO,'rewardStatus2'),
}

local iconList = {
    "#dynamic_n/arena/arena.xml|arena|2",
    "#dynamic_n/arena/arena.xml|arena|1",
    "#dynamic_n/arena/arena.xml|arena|0",
    "#dynamic_n/arena/arena.xml|arena|3",
}

local function ShowTitleTip(self,ele,has)
  self.cvs_detailed.Visible = true
  local lb_title = self.cvs_detailed:FindChildByEditName('lb_title',true)
  lb_title.Text = ele.RankName
  lb_title.FontColorRGBA = Util.GetQualityColorRGBA(ele.RankQColor)
  local list = ItemModel.FormatAttribute(ele)
  for i=1,4 do
    local label = self.cvs_detailed:FindChildByEditName("lb_attribute"..i,true)
    local attr = list[i]
    label.Visible = attr ~= nil
    if attr then
        label.Text = ItemModel.AttributeValue2NameValue(attr)
    end
  end
  
  local tb_target = self.cvs_detailed:FindChildByEditName("tb_target",true)
  tb_target.Text = ele.Tips
  local lb_get = self.cvs_detailed:FindChildByEditName("lb_get",true)
  lb_get.Y = tb_target.Y + tb_target.TextComponent.PreferredSize.y
  lb_get.FontColorRGBA = (has and Util.GetQualityColorRGBA(GameUtil.Quality_Green)) or Util.GetQualityColorRGBA(GameUtil.Quality_Red)
  lb_get.Text = Util.GetText(TextConfig.Type.TITLE, (has and "geted") or "notGeted")
end

local function SwitchToRule(self)
    self.cvs_titlelist.Visible = false
    
    self.tbx_click:DecodeAndUnderlineLink(Text.titleTips)
end

local function SwitchToTitle(self)
    self.cvs_titlelist.Visible = true
    
    self.tbx_click:DecodeAndUnderlineLink(Text.titleTips_click)

    if self.sp_titlelist.Rows <= 0 then
        
        local eles = GlobalHooks.DB.Find('RankList',{BelongTo = 2})
        self.sp_titlelist:Initialize(self.cvs_title.Width,self.cvs_title.Height,#eles,1,self.cvs_title,
            function (gx,gy,node)
                local ele = eles[gy+1]
                if ele then
                    node.Visible = true
                    local ib_title = node:FindChildByEditName('ib_title',false)
                    
                    Util.HZSetImage2(ib_title, "#static_n/title_icon/title_icon.xml|title_icon|"..ele.Show)

                    
                    local tbn_brief = node:FindChildByEditName('tbn_brief',false)
                    tbn_brief.TouchClick = function (sender)
                        if tbn_brief.IsChecked then
                            if self.selectTile ~= nil then
                                self.selectTile.IsChecked = false
                            end
                            self.selectTile = tbn_brief

                            local titles = TitleAPI.GetTitleIdList()
                            local isget = false
                            for _,v in ipairs(titles or {}) do
                                if v.id == ele.RankID then
                                    isget = true
                                    break
                                end
                            end
                            ShowTitleTip(self,ele,isget)
                        else
                            self.cvs_detailed.Visible = false
                            self.selectTile = nil
                        end
                        
                    end
                    
                    





                end
            end,function () end)
    end
end

local SINGLE_REWARD = 1
local MULTI_REWARD = 2

local function CheckPvpIndex(self, v, reward_type)
    if reward_type == MULTI_REWARD then
        if not self.total_index or self.total_index <= 0  or self.totalReward == 0 then
            return false
        else
            return self.total_index >= v.StartRank and (self.total_index <= v.StopRank or v.StopRank == 0)
        end
    else
        if not self.single_index or self.single_index <= 0 or self.singleReward == 0 then
            return false
        else
            return self.single_index >= v.StartRank and (self.single_index <= v.StopRank or v.StopRank == 0)
        end
    end
end

local single = Util.GetText(TextConfig.Type.ATTRIBUTE, 136)
local two = Util.GetText(TextConfig.Type.ATTRIBUTE, 137)
local rewardTypeText = {single,two}
local seasonText = Util.GetText(TextConfig.Type.ATTRIBUTE, 138)
local seasenTextNone = Util.GetText(TextConfig.Type.ATTRIBUTE, 139)
local function SwitchToReward(self,sender)
    local data
    local reward_type

    if sender == self.tbt_singlereward then
        
        reward_type = SINGLE_REWARD
        self.lb_season_ranking.Visible = true
        self.lb_season_rankingnum.Visible = true
        self.tb_sa_desc.Visible = false

        self.tb_award_desc.Visible = true
        self.lb_ranking.Visible = true
        self.lb_rankingnum.Visible = true
        self.lb_rankingnum.Text = self.totalScore
        if self.single_index == 0 then
          self.lb_season_rankingnum.Text = Util.GetText(TextConfig.Type.ATTRIBUTE, 140)
        else
          self.lb_season_rankingnum.Text = tostring(self.single_index)
        end
    elseif sender == self.tbt_totalreward then
        
        reward_type = MULTI_REWARD

        self.lb_season_ranking.Visible = true
        self.lb_season_rankingnum.Visible = true
        self.tb_sa_desc.Visible = true

        self.tb_award_desc.Visible = false
        self.lb_ranking.Visible = true
        self.lb_rankingnum.Visible = true
        self.lb_rankingnum.Text = self.totalScore
        
        if self.total_index == 0 then
          self.tb_sa_desc.XmlText = seasenTextNone
        else
          self.tb_sa_desc.XmlText = Util.Format1234(seasonText,self.total_index)
        end

        if self.currentTotalRank == 0 then
          self.lb_season_rankingnum.Text = Util.GetText(TextConfig.Type.ATTRIBUTE, 140)
        else
          self.lb_season_rankingnum.Text = tostring(self.currentTotalRank)
        end

    end

    local function FillRewardItem(node,v,select_index)
        local cvs_choose = node:FindChildByEditName('cvs_choose',false)
        local btn_get = node:FindChildByEditName('btn_get',false)
        local lb_name = node:FindChildByEditName('lb_name',false)
        local ib_redpoint1 = node:FindChildByEditName('ib_redpoint1',false)
        local ib_rank = node:FindChildByEditName('ib_rank',false)
        if ib_rank~= nil then
            local iconIndex = select_index > 4 and 4 or select_index
            ib_rank.Layout = XmdsUISystem.CreateLayoutFroXml(iconList[iconIndex],LayoutStyle.IMAGE_STYLE_BACK_4_CENTER,8)
        end

        if v.StopRank == 0 then
            
        elseif v.StartRank == v.StopRank then
            lb_name.Text = Util.CSharpStringformat(Text.rankIndex,v.StartRank)
        else
            local indexStr = v.StartRank..'-'..v.StopRank
            lb_name.Text = Util.CSharpStringformat(Text.rankIndex,indexStr)
        end
        ib_redpoint1.Visible = false
        local isMyIndex = CheckPvpIndex(self, v, reward_type)
        
        if cvs_choose ~= nil then
            cvs_choose.Visible = isMyIndex
        end
        local items = string.split(v.RankReward,';')

        if isMyIndex then
            if (self.singleReward == 2 and reward_type == SINGLE_REWARD) or 
                 (self.totalReward == 2 and reward_type == MULTI_REWARD) then
                btn_get.IsGray = true
                btn_get.Enable = false
                btn_get.Text = Text.rewardStatus2
            else
                btn_get.Enable = true
                btn_get.IsGray = false
                btn_get.Text = Text.rewardStatus1
                ib_redpoint1.Visible = true
            end
            btn_get.TouchClick = function ()
                
                ArenaModel.RequestArenaReward(reward_type,function ()
                    
                    if reward_type == SINGLE_REWARD then
                        self.singleReward = 2
                    elseif reward_type == MULTI_REWARD then
                        self.totalReward = 2
                    end
                    ib_redpoint1.Visible = false
                    btn_get.Text = Text.rewardStatus2
                    btn_get.IsGray = true
                    btn_get.Enable = false

                    
                    local  reward = {}
                    for i=1,3 do 
                        local tmp = string.split(items[i],':')
                        local code = tmp[1]
                        local num = tmp[2]
                        local detail = ItemModel.GetItemDetailByCode(code)
                        reward[detail.static.Name .. "(".. code .. ")"] = num
                    end
                    Util.SendBIData("arenaReward","",rewardTypeText[reward_type],"","",reward,"")
                    
                end)
            end
        else
            btn_get.Text = Text.rewardStatus1
            btn_get.IsGray = true
            btn_get.Enable = false
        end

        
        for i=1,3 do            
            local cvs_icon = node:FindChildByEditName('cvs_icon'..i,false)
            local item = items[i]
            cvs_icon.Visible = item ~= nil
            if item then
                local tmp = string.split(item,':')
                local code = tmp[1]
                local num = tmp[2]
                
                local detail = ItemModel.GetItemDetailByCode(code)
                local select_key = select_index..'_'..i
                local itshow = Util.ShowItemShow(cvs_icon,detail.static.Icon,detail.static.Qcolor,num)
                itshow.EnableTouch = true
                itshow.IsSelected = self.select_key == select_key
                if itshow.IsSelected then
                    self.select_itshow = itshow
                end

                local bag_data = DataMgr.Instance.UserData.RoleBag
                local vItem = bag_data:MergerTemplateItem(detail.static.Code)

                
                
                
                
                
                
                
                
                itshow.TouchClick = function (sender)
                    EventManager.Fire('Event.ShowItemDetail',{data=detail}) 
                  
                  
                  
                  
                  
                  
                  
                  
                  
                  
                  
                  
                        
                  
                  
                  
                  
                  
                  
                  
                  
                  
                  
                  
                  
                  
                  
                  
                end
            end
        end
    end
    self.select_key = nil
    self.select_itshow =nil
    
    local eles = GlobalHooks.DB.Find('JJCReward',{Type = reward_type})
    local function UpdateRewardItem(gx,gy,node)
        FillRewardItem(node,eles[gy+1],gy+1)
    end

    local s = self.cvs_rewardinfo.Size2D
    if sender == self.tbt_singlereward then 
        self.sp_rewardinfo1:Initialize(s.x,s.y,#eles-1,1,self.cvs_rewardinfo,UpdateRewardItem,function() end)
        self.cvs_rewardinfo1.Visible = true
        self.sp_rewardinfo.Visible = false
        self.sp_rewardinfo1.Visible = true
        FillRewardItem(self.cvs_rewardinfo1,eles[#eles],0)
    else
        self.sp_rewardinfo:Initialize(s.x,s.y,#eles,1,self.cvs_rewardinfo,UpdateRewardItem,function() end)
        self.cvs_rewardinfo1.Visible = false
        self.sp_rewardinfo.Visible = true
        self.sp_rewardinfo1.Visible = false
        
    end
end

function _M:checkEnterEffect()
    local num = DataMgr.Instance.FlagPushData:GetFlagState(FlagPushData.FLAG_JJC_ENTER)
    if num ~= 0 then
        Util.showUIEffect(self.btn_enter,55)
    else
        Util.clearUIEffect(self.btn_enter,55)
    end
end

local function ToCountDownSecond(endTime)
    if endTime == nil then
        return
    end
    local passTime = math.floor(endTime/1000-ServerTime.GetServerUnixTime())
    return Util.GetText(TextConfig.Type.SOLO,"endSeason",ServerTime.GetCDStrCut2(passTime))
end

function _M:OnEnter()
  
  self.cvs_detailed.Visible = false
  TitleAPI.RequestAwardTitleInfoAsync(function (titles)
    self.self_titles = {}
    for _,v in ipairs(titles or {}) do
        self.self_titles[v.id] = v
    end

  end)


  self.menu.mRoot.Visible = false
  ArenaModel.RequetArenaInfo(function (data)
    
    self.menu.mRoot.Visible = true
    self.single_index = data.s2c_singleRank
    self.total_index = data.s2c_totalRank
    self.singleReward = data.s2c_singleReward
    self.totalReward = data.s2c_totalReward
    self.currentTotalRank = data.s2c_currentTotalRank
    self.totalScore = data.s2c_currentTotalScore
    self.tbx_overtime.XmlText = ToCountDownSecond(data.s2c_seasonEndTime)
    SwitchToRule(self)
    self.tbt_totalreward.IsChecked = true
  end)

    self:checkEnterEffect()

    DataMgr.Instance.FlagPushData:AttachLuaObserver(GlobalHooks.UITAG.GameUIMultiPvpFrame,{Notify = function(status, flagdate)
        if status == FlagPushData.FLAG_JJC_ENTER then
            self:checkEnterEffect()
        end      
    end})
end

function _M:OnExit()
    DataMgr.Instance.FlagPushData:DetachLuaObserver(GlobalHooks.UITAG.GameUIMultiPvpFrame)
end

local function OnDestory(self)
  
end

local ui_names = 
{
    {name = 'lb_rankingnum'},
    {name = 'lb_ranking'},
    {name = 'sp_rewardinfo'},
    {name = 'sp_rewardinfo1'},
    {name = 'sp_titlelist'},
    {name = 'tbt_singlereward'},
    {name = 'tbt_totalreward'},
    {name = 'ib_title'},
    {name = 'ib_redpoint2'},
    {name = 'cvs_jjcreward'},
    {name = 'cvs_ruletips'},
    {name = 'cvs_mainreward'},
    {name = 'cvs_rewardinfo'},
    {name = 'cvs_rewardinfo1'},
    {name = 'cvs_titlelist'},
    {name = 'cvs_title'},
    {name = 'cvs_detailed'},
    {name = 'tb_neirong'},
    {name = 'tbx_click'},
    {name = 'tb_award_desc'},
    {name = 'tb_sa_desc'},
    {name = 'lb_season_ranking'},
    {name = 'lb_season_rankingnum'},
    {name = 'lb_ranking'},
    {name = "tbx_overtime"},
    {name = 'btn_enter',click = function (self)
        
        ArenaModel.RequestEnterArenaArea()
        Util.SendBIData("arenaEnter","1","","","","","")
    end},
    {name = 'btn_closetitle',click = function (self)
        
        SwitchToRule(self)
    end},
    {name = 'btn_rank',click = function(self)
      MenuMgrU.Instance:OpenUIByTag(GlobalHooks.UITAG.GameUILeaderboard,0,Leaderboard.LBType.MELEE)
    end}
}


local function InitComponent(self,tag)
    
    self.menu = LuaMenuU.Create('xmds_ui/arena/jjc_reward.gui.xml',tag)
    Util.CreateHZUICompsTable(self.menu,ui_names,self)
    self.menu.Enable = false
    
    self.cvs_rewardinfo.Visible = false

  
  self.tb_neirong.XmlText = Text.rule
  self.tb_neirong.Scrollable = true

  self.tb_award_desc.XmlText = self.tb_award_desc.Text

  MenuBaseU.SetEnableUENode(self.tbx_click,true,false)
  self.tbx_click:DecodeAndUnderlineLink(Text.titleTips)
  self.tbx_click.LinkClick = function (link_str)
    if self.cvs_titlelist.Visible then
        SwitchToRule(self) 
    else
        
        SwitchToTitle(self)
      end
  end
  self.tbx_click.Visible = false
  Util.InitMultiToggleButton(function (sender)
    SwitchToReward(self,sender)
  end,nil,{self.tbt_singlereward,self.tbt_totalreward})
end


local function Create(tag)
  local ret = {}
  setmetatable(ret, _M)
  InitComponent(ret,tag)
  return ret
end

_M.Create = Create
_M.Close  = Close

return _M
