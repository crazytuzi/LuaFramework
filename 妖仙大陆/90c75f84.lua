local _M = {}
_M.__index = _M
local self = {menu = nil}

local Helper = require 'Zeus.Logic.Helper'
local Util   = require 'Zeus.Logic.Util'

local TreeView = require "Zeus.Logic.TreeView"
local MountModel = require "Zeus.Model.Mount"
local CarnivalModel = require "Zeus.Model.Carnival"
local RideModelBase     = require 'Zeus.UI.XmasterRide.RideModelBase'

local self = {
    m_Root = nil,
}

local ui_names = 
{
    
    {name = 'btn_close'},
    {name = 'btn_change'},
    {name = 'btn_help1'},
    {name = 'cvs_introduce1'},
    {name = 'btn_help2'},
    {name = 'cvs_introduce2'},

    {name = 'cvs_frame'},
    {name = 'cvs_left'},
    {name = 'cvs_mid'},
    {name = 'cvs_mine'},
    {name = 'cvs_right'},

  
}

local bag_data = DataMgr.Instance.UserData.RoleBag

local currentMax=0;
local currentItemCode;

local bagFilter=ItemPack.FilterInfo.New()
bagFilter.CheckHandle = function (it)
  return it.TemplateId == currentItemCode
end
bagFilter.NofityCB = function()
  local lb_need_num = self.cvs_right:FindChildByEditName("lb_need_num", true)
  
  
  local vItem = bag_data:MergerTemplateItem(currentItemCode)
  local hasCount = (vItem and vItem.Num) or 0
  if(hasCount>=currentMax) then
    lb_need_num.Text="<color=lime>"..hasCount.."</color>/"..currentMax
    self.btn_change.Enable=true
  else
    lb_need_num.Text="<color=red>"..hasCount.."</color>/"..currentMax
    self.btn_change.Enable=false
  end
end


local function addBagFilter(itemcode)
  bag_data:RemoveFilter(bagFilter)
  currentItemCode=itemcode

  bag_data:AddFilter(bagFilter)
end

local function removeBagFilter()
  bag_data:RemoveFilter(bagFilter)
end

local lb_time = nil

local timeleft=0

local function UpdateTimer()
    
    
    
    
    
    
    if(timeleft>0) then
      timeleft=timeleft-1
    end
    if(timeleft==0) then
      lb_time.Text=Util.GetText(TextConfig.Type.SIGN, "isover")
    else
      local timeHour = math.floor(timeleft/3600)
      local timeMinute = math.fmod(math.floor(timeleft/60), 60)
      local timeSecond = math.fmod(timeleft, 60)
      lb_time.Text=timeHour..":"..timeMinute..":"..timeSecond
    end
end

local modelMgrLeft={}
local modelMgrRight={}

local function Release3DModel(modelMgr)
    if modelMgr.model ~= nil then
        GameObject.Destroy(modelMgr.model.obj)
        IconGenerator.instance:ReleaseTexture(modelMgr.model.key)
    end
    modelMgr.model = nil
end











































  
local function ShowPet3DModel(modelMgr, parent, data,callback)
  
  
  
  
  
  
  

  local modelFile = "/res/unit/pet/"..data..".assetbundles"
    if modelMgr.model == nil then
        

        
        local obj, key = GameUtil.Add3DModelLua(parent, modelFile, {}, nil, 0, true)

        modelMgr.model = {}
        modelMgr.model.obj = obj
        modelMgr.model.key = key
        

        
        IconGenerator.instance:SetLoadOKCallback(key, callback)
        
        
        

        
        
        

        
    else
        
        
        


        

        
        IconGenerator.instance:SetLoadOKCallback(modelMgr.model.key, callback)

        
        GameUtil.Change3DModelLua(modelMgr.model.key, modelFile, {}, 0)
        

        
        
        
        
        
      
      
    end
    
    
end

local function ShowRide3DModel(modelMgr, parent, data,callback)
  
  
  
  
  


  local modelFile = "/res/unit/mount/"..data..".assetbundles"
  if modelMgr.model == nil then
    
    
    
    local obj, key = GameUtil.Add3DModelLua(parent, modelFile, {}, nil, 0, true)

    modelMgr.model = {}
    modelMgr.model.obj = obj
    modelMgr.model.key = key
    

    
    IconGenerator.instance:SetLoadOKCallback(key, callback)
    
    
    
    

    
  else
    
    
    
    

    
    IconGenerator.instance:SetLoadOKCallback(modelMgr.model.key, callback)

    
    GameUtil.Change3DModelLua(modelMgr.model.key, modelFile, {}, 0)
      
      

      
      
          
          
          
          
          
          
          
          

  end
  
  

  
  
  
  
  

end


local function ShowActor3DModel(modelMgr, parent, modelFile,avatars,callback)
  
  
  
  
  
  
  local filter = bit.lshift(1,  GameUtil.TryEnumToInt(XmdsAvatarInfo.XmdsAvatar.Ride_Equipment))
  if modelMgr.model == nil then
    

    
    local obj, key = GameUtil.Add3DModelLua(parent, modelFile, avatars,nil, filter, true)

    modelMgr.model = {}
    modelMgr.model.obj = obj
    modelMgr.model.key = key
    
    

    
    IconGenerator.instance:SetLoadOKCallback(key, callback)

    
    
    

    
    

  else
    


    
    IconGenerator.instance:SetLoadOKCallback(modelMgr.model.key, callback)

    
    GameUtil.Change3DModelLua(modelMgr.model.key, modelFile, avatars, filter)

    
  end

  
  
  
  
    
  
  
  
  
  
  
end









































local function ShowActor3DFashionModel(modelMgr, parent,avatars,callback)
  local filter = bit.lshift(1,  GameUtil.TryEnumToInt(XmdsAvatarInfo.XmdsAvatar.Ride_Equipment))
  if modelMgr.model == nil then
    

    
    

    
    

    

    local obj, key = GameUtil.AddLua3DFashionModel(parent, avatars, '', nil, filter, true)

    modelMgr.model = {}
    modelMgr.model.obj = obj
    modelMgr.model.key = key

    

    
    IconGenerator.instance:SetLoadOKCallback(key, callback)

  else
    


    
    

    
    GameUtil.Change3DModelLua(modelMgr.model.key, modelFile, avatars, filter)  
  end
 
end



















local function InitLeft(self,data)
  local sp_type = self.cvs_left:FindChildByEditName("sp_type", true)
  local cvs_typename = self.cvs_left:FindChildByEditName("cvs_typename", true)
  local tbt_subtype = self.cvs_left:FindChildByEditName("tbt_subtype", true)

  local cvs_item = self.cvs_left:FindChildByEditName("cvs_item", true)
  cvs_item.Visible = false

  local subValues = {}
  local subValueChild = {}
  for i=1,#data.info do
    subValueChild[i]=#data.info[i].today
  end
  

  self.treeView = TreeView.Create(#subValueChild,0,sp_type.Size2D,TreeView.MODE_SINGLE) 
  
  local function rootCreateCallBack(index,node)
      node.Enable = true
      local lb_title = node:FindChildByEditName("lb_typename", false)
      lb_title.Text = data.info[index].name 
  end
  local function rootClickCallBack(node,visible)
      local tbt_open = node:FindChildByEditName("tbt_open",false)
      tbt_open.IsChecked = visible
      if visible == true then
        XmdsSoundManager.GetXmdsInstance():PlaySoundByKey('zuobiaoqian')
      end
  end
  local rootValue = TreeView.CreateRootValue(cvs_typename,#subValueChild,rootCreateCallBack,rootClickCallBack)

  self.subNodeList = {}


  local function setAward(cvs_reward,data)
    for i=1,4 do
      local cvs_n=cvs_reward:FindChildByEditName("cvs_"..i, true)
      local award=data[i]
      
      
      if(award~=nil) then
        local it = GlobalHooks.DB.Find("Items",award.itemcode)
        local itshow = Util.ShowItemShow(cvs_n,it.Icon,it.Qcolor,award.itemcount,true)
        Util.NormalItemShowTouchClick(itshow,award.itemcode)
        cvs_n.Visible=true
      else
        cvs_n.Visible=false
      end

    end
  end

  local function subClickCallback(rootIndex,subIndex,node)
    
    


    local function InitFront(self,data)
      local sp_title = self.cvs_mid:FindChildByEditName("sp_title", true)
      local tbt_classify = self.cvs_mid:FindChildByEditName("tbt_classify", true)
      tbt_classify.Visible=false

      
      

      
      sp_title.Scrollable.Container:RemoveAllChildren(true)

      local function InitContent(self,data,cell,label,rankKey,goto1,goto2,tip,title)
        local cvs_first = self.cvs_mid:FindChildByEditName("cvs_first", true)
        local sp_after_second = self.cvs_mid:FindChildByEditName("sp_after_second", true)
        local cvs_mid_list = sp_after_second:FindChildByEditName("cvs_mid_list", true)
        
        cvs_mid_list.Visible=false

        
        
        if(#data.config>1) then
          
          local configItem=data.config[1]


          local lb_name = cvs_first:FindChildByEditName("lb_name", true)
          local lb_rank = cvs_first:FindChildByEditName("lb_rank", true)
          local cvs_mod = cvs_first:FindChildByEditName("cvs_mod", true)
          local cvs_mod_guild = cvs_first:FindChildByEditName("cvs_mod_guild", true)
          local cvs_reward = cvs_first:FindChildByEditName("cvs_reward", true)
          local cvs_title = cvs_first:FindChildByEditName("cvs_title", true)
          local lb_num = cvs_first:FindChildByEditName("lb_num", true)
          
          if(configItem.player~=nil) then
            lb_name.Text=configItem.player.contents[3]
            lb_num.Text=label..":"..configItem.player.contents[2]
            lb_num.Visible=true

            
            if(rankKey~=8) then
              
              cvs_mod.Visible=true
              cvs_mod_guild.Visible=false
              
              local function showCallback(k)
              
                IconGenerator.instance:SetModelPos(modelMgrLeft.model.key, Vector3.New(0, -1.65, 2))
                IconGenerator.instance:SetModelScale(modelMgrLeft.model.key, Vector3.New(1, 1, 1))
                
              end
              ShowActor3DModel(modelMgrLeft, cvs_mod, nil, configItem.player.avatars,showCallback)
              local function onDragAvatar(sender,e)
                  if not modelMgrLeft.model then return end
                  if not modelMgrLeft.model.key then return end

                  local deltaX = e.delta.x
                  if deltaX ~= 0 then
                      
                      IconGenerator.instance:SetRotate(modelMgrLeft.model.key,-deltaX)
                      
                      
                  end
              end
              cvs_mod.event_PointerMove = onDragAvatar
              cvs_mod.EnableOutMove = true
              
              
              
              
              


              MenuBaseU.SetImageBox(cvs_first, "cvs_mod", "", LayoutStyle.IMAGE_STYLE_BACK_4, 8)
            else
              
              cvs_mod.Visible=false
              cvs_mod_guild.Visible=true

              Release3DModel(modelMgrLeft)
              MenuBaseU.SetImageBox(cvs_first, "cvs_mod_guild", "static_n/guild/"..configItem.player.contents[4]..".png", LayoutStyle.IMAGE_STYLE_BACK_4, 8)
            end
            if(title~=nil) then
              local rankListData = GlobalHooks.DB.Find("RankList", {RankID=data.titleId})[tonumber(title)]
              if(rankListData.Show~=-1) then
                cvs_title.Visible=true
                Util.HZSetImage2(cvs_title, "#static_n/title_icon/title_icon.xml|title_icon|"..rankListData.Show, true, LayoutStyle.IMAGE_STYLE_BACK_4_CENTER)
              end
            end
            
            
            
            
            
          else
            lb_name.Text="虚位以待"
            lb_num.Visible=false
            Release3DModel(modelMgrLeft)
            cvs_mod.Visible=false
            cvs_mod_guild.Visible=false
            cvs_title.Visible=false
            
          end

          setAward(cvs_reward,configItem.award)
        end



        
        if(#data.config>1) then
          sp_after_second:Initialize(
            cvs_mid_list.Width,
            cvs_mid_list.Height,
            #data.config-1,
            1,
            cvs_mid_list,
            function(x,y,cell)
              local lb_rank1=cell:FindChildByEditName("lb_rank1", true)
              local cvs_reward=cell:FindChildByEditName("cvs_reward", true)
              local cvs_23=cell:FindChildByEditName("cvs_23", true)

              local configItem=data.config[y+2]
              
              
              if(configItem.minRank==configItem.maxRank) then
                
                lb_rank1.Visible=false


                cvs_23.Visible=true
                local lb_rank=cvs_23:FindChildByEditName("lb_rank", true)
                local lb_name=cvs_23:FindChildByEditName("lb_name", true)
                local lb_number=cvs_23:FindChildByEditName("lb_number", true)

                local ib_player_dikuang=cvs_23:FindChildByEditName("ib_player_dikuang", true)
                local ib_icon=cvs_23:FindChildByEditName("ib_icon", true)
                local ib_lv_bg=cvs_23:FindChildByEditName("ib_lv_bg", true)
                local ib_lv_num=cvs_23:FindChildByEditName("ib_lv_num", true)
                lb_rank.Text=configItem.minRank

                if(configItem.player~=nil) then
                  lb_name.Text=configItem.player.contents[3]
                  lb_number.Text=label..":"..configItem.player.contents[2]
                  lb_number.Visible=true

                  if(rankKey~=8) then
                    
                    
                    MenuBaseU.SetImageBox(cvs_23, "ib_icon", "static_n/hud/target/"..configItem.player.contents[4]..".png", LayoutStyle.IMAGE_STYLE_BACK_4, 8)
                    
                    ib_lv_bg.Visible=true
                    
                  else
                    
                    MenuBaseU.SetImageBox(cvs_23, "ib_icon", "static_n/guild/"..configItem.player.contents[4]..".png", LayoutStyle.IMAGE_STYLE_BACK_4, 8)
                    ib_lv_bg.Visible=false
                    
                  end
                  ib_lv_num.Text=configItem.player.contents[5]
                  ib_player_dikuang.Visible=true
                  ib_icon.Visible=true
                  ib_lv_num.Visible=true

                else
                  lb_name.Text=Util.GetText(TextConfig.Type.SIGN, "xuweiyidai")
                  lb_number.Visible=false

                  ib_player_dikuang.Visible=false
                  ib_icon.Visible=false
                  ib_lv_bg.Visible=false
                  ib_lv_num.Visible=false
                end
              else
                
                lb_rank1.Text=label..Util.GetText(TextConfig.Type.SIGN, "rankreward",configItem.minRank,configItem.maxRank)
                lb_rank1.Visible=true

                cvs_23.Visible=false
              end

              
              setAward(cvs_reward,configItem.award)
            end,
            function()
              
            end
          )
        end

        
        

        
        local lb_name = self.cvs_mine:FindChildByEditName("lb_name", true)
        local lb_number = self.cvs_mine:FindChildByEditName("lb_number", true)
        local lb_rank = self.cvs_mine:FindChildByEditName("lb_rank", true)

        local ib_icon = self.cvs_mine:FindChildByEditName("ib_icon", true)
        local ib_rank_num = self.cvs_mine:FindChildByEditName("ib_rank_num", true)
        local ib_rank_back = self.cvs_mine:FindChildByEditName("ib_rank_back", true)

        if(data.self.contents~=nil) then
          lb_name.Text=data.self.contents[3]

          
          if(rankKey~=8) then
            
            
            MenuBaseU.SetImageBox(self.cvs_mine, "ib_icon", "static_n/hud/target/"..data.self.contents[4]..".png", LayoutStyle.IMAGE_STYLE_BACK_4, 8)
          else
            
            MenuBaseU.SetImageBox(self.cvs_mine, "ib_icon", "static_n/guild/"..data.self.contents[4]..".png", LayoutStyle.IMAGE_STYLE_BACK_4, 8)
          end
          
          ib_rank_num.Text=data.self.contents[5]
          ib_rank_back.Visible=true

          if(tonumber(data.self.contents[2])>0) then
            lb_number.Text=label..":"..data.self.contents[2]
          else
            lb_number.Text=Util.GetText(TextConfig.Type.SIGN, "notrank")
          end


          if(tonumber(data.self.contents[1])>0) then
            lb_rank.Text=data.self.contents[1]
          else
            lb_rank.Text=Util.GetText(TextConfig.Type.SIGN, "notrank")
          end
        else
          lb_name.Text=Util.GetText(TextConfig.Type.SIGN, "wu")

          
          MenuBaseU.SetImageBox(self.cvs_mine, "ib_icon", "", LayoutStyle.IMAGE_STYLE_BACK_4, 8)
          
          ib_rank_num.Text=""
          ib_rank_back.Visible=false

          lb_number.Text=Util.GetText(TextConfig.Type.SIGN, "notrank")


          lb_rank.Text=Util.GetText(TextConfig.Type.SIGN, "notrank")
        end


        local btn_look=self.cvs_mine:FindChildByEditName("btn_look", true)
        local btn_bestronger=self.cvs_mine:FindChildByEditName("btn_bestronger", true)

        local function OnLookClick(displayNode)
          
          if(goto1~="") then
            
            MenuMgrU.Instance:OpenUIByTag(GlobalHooks.UITAG.GameUILeaderboard, 0, tonumber(goto1))
          end
          
        end

        local function OnBestrongerClick(displayNode)
          
          
          
          
          
          
          EventManager.Fire('Event.Goto', {id = "ActivityCZTH"})
        end

        btn_look.TouchClick = OnLookClick
        btn_bestronger.TouchClick = OnBestrongerClick

        timeleft=data.timeleft
        UpdateTimer()

        local tb_introduce=self.cvs_introduce2:FindChildByEditName("tb_introduce", true)
        tb_introduce.Text=tip
        




        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
      end

      
      local btnList = {}
      for i=1,#data do
        local tbt_classify_n = tbt_classify:Clone()


        tbt_classify_n.UserTag = i
        tbt_classify_n.Visible = true
        tbt_classify_n.Text = data[i].name
        tbt_classify_n.X = (i-1)*tbt_classify.Width
        sp_title.Scrollable.Container:AddChild(tbt_classify_n)
        table.insert(btnList,tbt_classify_n)
      end
    
      Util.InitMultiToggleButton(function(cell)
        
        CarnivalModel.RequestRevelryGetRank(data[cell.UserTag].id,function(cb_data)
          InitContent(self,cb_data,cell,data[cell.UserTag].label,cb_data.rankKey,data[cell.UserTag].goto1,data[cell.UserTag].goto2,data[cell.UserTag].tip,cb_data.title)
        end)
        
      end, btnList[1], btnList)

      
      

      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      

      
      
    end

    InitFront(self,data.info[rootIndex].today[subIndex].column)
    
    


    

    

  end
  local function subCreateCallback(rootIndex,subIndex,node)
      node.UserTag = rootIndex*10+subIndex
      node.Enable = true
      node.IsChecked = false
      
      node.Text = data.info[rootIndex].today[subIndex].name 
      table.insert(self.subNodeList, node)
  end

  for i=1,#subValueChild do
    subValues[i] = TreeView.CreateSubValue(i,tbt_subtype,subValueChild[i], subClickCallback, subCreateCallback)
  end
  self.treeView:setValues(rootValue,subValues)
  sp_type.Scrollable.Container:RemoveAllChildren(true)
  sp_type:AddNormalChild(self.treeView.view)
  
  
  
  local selectedIndex=nil
  if(#self.subNodeList>0) then
    selectedIndex=1
  end
  if(data.selectedIndex~=nil and data.selectedIndex~=0) then
    selectedIndex=data.selectedIndex
  end
  Util.InitMultiToggleButton( function(sender)
    end , self.subNodeList[selectedIndex], self.subNodeList)
end







  














  





  









local function UpdateRightContent(self,data)
  
  local cvs_mount_pet = self.cvs_right:FindChildByEditName("cvs_mount&pet", true)
  local cvs_picture = cvs_mount_pet:FindChildByEditName("cvs_picture", true)
  local cvs_duihuan = cvs_mount_pet:FindChildByEditName("cvs_duihuan", true)

  local filter = bit.lshift(1,  GameUtil.TryEnumToInt(XmdsAvatarInfo.XmdsAvatar.Ride_Equipment))

  local function showCallback(k)
  
    
    
    
    local kingTable=GlobalHooks.DB.Find("King",{})[data.tabId]
    if(kingTable.ModelPercent~=nil) then
      local scale = tonumber(kingTable.ModelPercent)

      if(scale>0) then
        IconGenerator.instance:SetModelScale(modelMgrRight.model.key, Vector3.New(scale, scale, scale))
      end
    end
    if(kingTable.ModelY~=nil and kingTable.ModelZ~=nil) then
      local y=tonumber(kingTable.ModelY)
      local z=tonumber(kingTable.ModelZ)
      IconGenerator.instance:SetModelPos(modelMgrRight.model.key, Vector3.New(0, y, z))
    end
    if(kingTable.RoteY~=nil) then
      local y=tonumber(kingTable.RoteY)
      IconGenerator.instance:SetRotate(modelMgrRight.model.key, Vector3.New(0, y, 0))
    end
  end
  Release3DModel(modelMgrRight)
  if(data.showType==1) then
    
    ShowRide3DModel(modelMgrRight, cvs_picture, data.avatarId,showCallback)
  end
  if(data.showType==2) then 
    
    ShowPet3DModel(modelMgrRight, cvs_picture, data.avatarId,showCallback)
  end
      

  if (data.showType==3 or data.showType==4 or data.showType==5) then 
    

    

    
    
    
    
    
    
    
    
    
    
    
    
    local PartTag
    if(data.showType==3) then
      PartTag=GameUtil.TryEnumToInt(XmdsAvatarInfo.XmdsAvatar.R_Hand_Weapon)
    end
    if(data.showType==4) then
      PartTag=GameUtil.TryEnumToInt(XmdsAvatarInfo.XmdsAvatar.Avatar_Body)
    end
    if(data.showType==5) then
      PartTag=GameUtil.TryEnumToInt(XmdsAvatarInfo.XmdsAvatar.Rear_Equipment)
    end

    local avatars={}
    local ava = {
                    fileName = data.avatarId,
                    effectType = 0,
                    PartTag = PartTag,
                }
    table.insert(avatars,ava)
    

    ShowActor3DFashionModel(modelMgrRight, cvs_picture,avatars,showCallback)
  end

  

  

  
  
  

  cvs_picture.event_PointerClick = function (displayNode, pos)
      
      
      
  end
  local function onDragAvatar(sender,e)
      if not modelMgrRight.model.key then return end

      local deltaX = e.delta.x
      if deltaX ~= 0 then
          
          IconGenerator.instance:SetRotate(modelMgrRight.model.key,-deltaX)
          
          
      end
  end
  cvs_picture.event_PointerMove = onDragAvatar


  
  
  

  
  

  


  local cvs_icon=cvs_duihuan:FindChildByEditName("cvs_icon", true)
  local lb_name=cvs_duihuan:FindChildByEditName("lb_name", true)
  local lb_need_num=cvs_duihuan:FindChildByEditName("lb_need_num", true)

  local it1 = GlobalHooks.DB.Find("Items",data.item1code)
  local itshow1 = Util.ShowItemShow(cvs_icon,it1.Icon,it1.Qcolor,data.item1num,true)
  Util.NormalItemShowTouchClick(itshow1,data.item1code)

  local it2 = GlobalHooks.DB.Find("Items",data.item2code)

  
  
  
  

  lb_name.Text=Util.GetText(TextConfig.Type.SIGN, "xuyao")..it2.Name
  
  currentMax=data.item2num
  addBagFilter(data.item2code)

  local tb_introduce=self.cvs_introduce1:FindChildByEditName("tb_introduce", true)
  tb_introduce.Text=data.tip
  
end


local function InitRight(self,data)
  local sp_title = self.cvs_right:FindChildByEditName("sp_title", true)
  
  local tbt_classify = self.cvs_right:FindChildByEditName("tbt_classify", true)
  tbt_classify.Visible=false
  

  

  

  
  sp_title.Scrollable.Container:RemoveAllChildren(true)

  local btnList = {}
  for i=1,#data do
    local tbt_classify_n = tbt_classify:Clone()


    tbt_classify_n.UserTag = i
    tbt_classify_n.Visible = true
    tbt_classify_n.Text = data[i].tabName
    tbt_classify_n.X = (i-1)*tbt_classify.Width
    sp_title.Scrollable.Container:AddChild(tbt_classify_n)
    table.insert(btnList,tbt_classify_n)
  end

  Util.InitMultiToggleButton(function(cell)

    
    UpdateRightContent(self,data[cell.UserTag])
    

    self.btn_change.TouchClick = function()
      
      CarnivalModel.RequestRevelryExchange(data[cell.UserTag].tabId,1,function(cb_data)
        
        UpdateRightContent(self,data[cell.UserTag])
      end)
    end
      
    
  end, btnList[1], btnList)




  

  
    

    
    
    
end


local function OnClickClose(displayNode)
  
  if self ~= nil and self.m_Root ~= nil then
      self.m_Root:Close()
  end
end










local function ClearAll()
    if self.weaponFile then    
        UnityEngine.Object.DestroyObject(self.weaponAsset)
        if self.weaponkey then IconGenerator.instance:ReleaseTexture(self.weaponkey) end
        self.weaponFile = nil
    end
end

local function OnLoad(self, callback)
  
  
end













local function OnEnter(self)
  
  
  self.menu.Visible=false
  CarnivalModel.RequestRevelryGetColumn(function(data)
    

    InitLeft(self,data)
    InitRight(self,data.exchange)
    local rootViews = self.treeView:GetRootView()
    local subViews = self.treeView:GetSubViews()
    
    if(#subViews>=1) then
      if(#subViews[1]>=1) then
        local selectedIndex=1
        if(data.selectedIndex~=nil and data.selectedIndex~=0) then
          selectedIndex=data.selectedIndex
        end
        self.treeView:selectNode(1,selectedIndex,true)
      end
    end

    self.menu.Visible=true
  end)
  
  local lb_time = self.cvs_mid:FindChildByEditName("lb_time", true)

  if self.timer ~= nil then
    self.timer:Stop()
  end
  self.timer = Timer.New(UpdateTimer,1, -1)
    self.timer:Start()


  
end

local function OnExit(self)
  
  if self.timer ~= nil then
    self.timer:Stop()
  end

  Release3DModel(modelMgrLeft)
  Release3DModel(modelMgrRight)
  removeBagFilter()
end



local function Init(self,tag)
  self.m_Root = LuaMenuU.Create("xmds_ui/carnival/carnival.gui.xml", GlobalHooks.UITAG.GameUICarnival)
  self.menu = self.m_Root

  

  Util.CreateHZUICompsTable(self.menu,ui_names,self)
  lb_time = self.cvs_mid:FindChildByEditName("lb_time", true)
  self.menu.Enable = false
  self.menu.ShowType = UIShowType.HideBackHud
  
  
  


  
  
  
  self.menu:SubscribOnExit(function ()
    OnExit(self)
  end)
  self.menu:SubscribOnEnter(function ()
    OnEnter(self)
  end)
  self.menu:SubscribOnDestory(function()
    self = nil
  end)

  self.btn_help1.event_PointerDown = function()
      self.cvs_introduce1.Visible = true
  end
  self.btn_help1.event_PointerUp = function ()
      self.cvs_introduce1.Visible = false
  end

  self.btn_help2.event_PointerDown = function()
      self.cvs_introduce2.Visible = true
  end
  self.btn_help2.event_PointerUp = function ()
      self.cvs_introduce2.Visible = false
  end

  self.btn_close.TouchClick = OnClickClose
  

  MountModel.InitSkinList()
  
  

  
  
  
  

end



local function Create(tag)
  self = {}
  setmetatable(self, _M)
  Init(self,tag)
  return self
end


return {Create = Create}
