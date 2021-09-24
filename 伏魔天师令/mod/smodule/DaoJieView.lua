
local DaoJieView = classGc(view,function (self,_data)
       self.m_DaoJieMediator   =  require("mod.smodule.DaoJieMediator")(self) 
       self.m_winSize=cc.Director:getInstance():getWinSize()
       self.oldSceneId = _data
       self.m_Tag = {}
       self.m_ChapBtn = {}
       self.m_rewardSpr = {}
       self.m_rewardSpr[1] = {}
       self.m_rewardSpr[2] = {}
       self.m_rewardSpr[3] = {}     
    end)
local FONTSIZE        = 20 
local leftSprSize     =  cc.size(218,517)
local rightSprSize    =  cc.size(620,517)
local chapCount       =  20 
local COPYCOUNT       =  8 
local R_COUNT         = 7

local NUM_ROLE  = 5  -- 人物数量
local NUM_SKILL = 5  -- 技能数量
local LEV_SKILL = _G.Const.CONST_THOUSAND_SKILL_LV  -- 技能等级

function DaoJieView.create(self)
  print("开始创建道劫界面")
    self: getMainData()
    self.m_normalView=require("mod.general.NormalView")()
    self.m_rootLayer=self.m_normalView:create()

    local function nCloseFun()
        self:closeWindow()
    end
    self.m_normalView:addCloseFun(nCloseFun)
    local tempScene=cc.Scene:create()
    tempScene:addChild(self.m_rootLayer)
    self:getChapData()
    self:initDaojieView(tempScene)
    self : loadCopyIcon ()
    self : REQ_HOOK_REQUEST ()  -- 发送请求

    
   -- self.m_mediator=require("mod.smodule.FuTuMediator")(self)
    --self : getRoleData ()
   -- self : isChallengeQualification(60010)

    return tempScene
end
 
function DaoJieView.initDaojieView(self,Scene)
   local xPos = self.m_winSize.width/2
   local yPos = self.m_winSize.height/2
   
   ----[[
   local leftNode = cc.Node : create()
   --leftNode : setContentSize (leftSprSize)
   leftNode : setPosition(cc.p(xPos-322,yPos-45))
   Scene : addChild(leftNode)
   --local PageView = self : CreatePageView(xPos,yPos)
  -- leftNode : addChild(PageView)
   --]]   
   
   print("initDaojieView--->","加入背景",xPos,yPos)
   local rightBgSpr = ccui.Scale9Sprite:createWithSpriteFrameName("general_di2kuan.png")
   rightBgSpr : setPreferredSize(rightSprSize)
   rightBgSpr : setPosition(cc.p(xPos+104,yPos-45))
   self.m_rootLayer : addChild(rightBgSpr)
   self.m_rightBgSpr = rightBgSpr  
   
   local leftSpr = ccui.Scale9Sprite:createWithSpriteFrameName("general_di2kuan.png")
   leftSpr : setPreferredSize(leftSprSize)
   leftSpr : setPosition(cc.p(xPos-320,yPos-45))
   self.m_rootLayer : addChild(leftSpr)

   local BtnLayerView =  self : DaoJieChapScrollView(xPos,yPos)
   --BtnLayerView : setAnchorPoint (0,0.5)
   --BtnLayerView : setPosition(cc.p(0,leftSprSize.height-5))
   leftSpr : addChild (BtnLayerView)


    local barView=require("mod.general.ScrollBar")(BtnLayerView)
    barView:setPosOff(cc.p(0,0))
    self.m_barView = barView
    
  local rightChonJieSize = cc.size(rightSprSize.width-14,rightSprSize.height-14)
  local rightChonJieSpr = ccui.Scale9Sprite : createWithSpriteFrameName("general_input.png")
  rightChonJieSpr : setPreferredSize (rightChonJieSize)
  rightChonJieSpr : setPosition (cc.p(rightSprSize.width/2,rightSprSize.height/2))
  rightBgSpr : addChild (rightChonJieSpr)
   
  
  for i = 1,2 do 
    local LineSpr  = ccui.Scale9Sprite : createWithSpriteFrameName("general_double_line.png")
    LineSpr : setPreferredSize(cc.size(514,2))
    LineSpr : setPosition(cc.p(rightChonJieSize.width/2,(rightChonJieSize.height-60)-(i-1)*300))
    rightChonJieSpr : addChild(LineSpr)
  end

    local TitleLab = self.m_chapArray[self.m_chapTabIdex[1]].chap_name
    local LayerTitleLab =  _G.Util : createLabel("",FONTSIZE+12)
    LayerTitleLab : setAnchorPoint(cc.p(0,0.35))
    LayerTitleLab : setColor(_G.ColorUtil : getRGB(_G.Const.CONST_COLOR_YELLOW))
    LayerTitleLab : setPosition(cc.p(rightChonJieSize.width/2-40,rightChonJieSize.height-40))
    rightChonJieSpr : addChild(LayerTitleLab)
    self.m_LayerTitleLab = LayerTitleLab
    self.m_LayerTitleLab : setString(TitleLab)

    local saodangNumLab =  _G.Util : createLabel("扫荡次数：",FONTSIZE-2)
    saodangNumLab : setAnchorPoint(cc.p(0,0.35))
    saodangNumLab : setPosition(cc.p(rightChonJieSize.width-165,rightChonJieSize.height-40))
    rightChonJieSpr : addChild(saodangNumLab)    

    local saodangVlueLab =  _G.Util : createLabel("",FONTSIZE)
    saodangVlueLab : setAnchorPoint(cc.p(0,0.35))
    saodangVlueLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GRASSGREEN))
    saodangVlueLab : setPosition(cc.p(rightChonJieSize.width-76,rightChonJieSize.height-42))
    rightChonJieSpr : addChild(saodangVlueLab)
    self.m_saodanLab =    saodangVlueLab

    local rewarLabel = _G.Util : createLabel("通关奖励:",FONTSIZE)
    rewarLabel : setAnchorPoint(cc.p(0,0.35))
    rewarLabel : setPosition(cc.p(18,96))
    rightChonJieSpr : addChild(rewarLabel)
    
    --[[
    local conditionLabel = _G.Util : createLabel("通关条件：",FONTSIZE-2)
    conditionLabel : setAnchorPoint(cc.p(0,0.35))
    conditionLabel : setPosition(cc.p(rightChonJieSize.width-218,14))
    rightChonJieSpr : addChild(conditionLabel)
    --]]
    
    local function tempButtonCallBack(sender,eventType)
       local tag = sender : getTag()
       print("tempButtonCallBack-->",tag)
       --local TitleLab = getTitleText()
       if eventType == ccui.TouchEventType.ended  then 
         local TitleLab = self.m_DekaronBtn : getTitleText()
          print ("tempButtonCallBack--> ",tag,TitleLab)
          if TitleLab  == "扫荡"  then 
             self : saoDangView(tag)
          else
              self : dekaronView(tag)
          end
       end
    end  
    local tempButton = gc.CButton : create()
    tempButton : loadTextures("general_btn_gold.png")
    tempButton : setTitleText("开始挑战")
    tempButton : setButtonScale(0.9)
    tempButton : setTitleFontSize (FONTSIZE)
    tempButton : addTouchEventListener (tempButtonCallBack)
    tempButton : setPosition(cc.p(rightChonJieSize.width-112,65))
    rightChonJieSpr : addChild(tempButton)
    tempButton : setBright(false)
    tempButton : setEnabled(false)
    self.m_DekaronBtn = tempButton
    self.m_DekaronBtnState = 0

    local  ValueLabel = _G.Util : createLabel ("",FONTSIZE-2)
    ValueLabel : setAnchorPoint(cc.p(0,0.35))
    ValueLabel : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_RED))
    --ValueLabel : setPosition(cc.p(rightChonJieSize.width-220,14))
    rightChonJieSpr : addChild(ValueLabel)
    self.m_openTJLabel = ValueLabel

    self.m_rewardKBtn  = {}
    for i = 1, 3 do
       local rewardKuangBtn = gc.CButton : create()
       rewardKuangBtn : loadTextures("general_tubiaokuan.png")
       rewardKuangBtn : setPosition(cc.p(164+(i-1)*88,70))
       rightChonJieSpr : addChild(rewardKuangBtn)
       self.m_rewardKBtn[i] =  rewardKuangBtn
       local BtnSize = rewardKuangBtn : getContentSize()
       local waiKuangSpr = cc.Sprite : createWithSpriteFrameName ("ui_goods_fram_2.png")
       waiKuangSpr : setPosition (BtnSize.width/2,BtnSize.height/2)
       rewardKuangBtn : addChild (waiKuangSpr)
    end

    local guideId=_G.GGuideManager:getCurGuideId()

    if guideId==_G.Const.CONST_NEW_GUIDE_SYS_DAOJIE then
      _G.GGuideManager:initGuideView(self.m_rootLayer)
      _G.GGuideManager:registGuideData(1,tempButton)
      _G.GGuideManager:runNextStep()

      -- _G.GGuideManager:removeCurGuideNode()

      self.m_hasGuide=true
      local command=CGuideNoticHide()
      controller:sendCommand(command)
    end
end

function DaoJieView.upInitDate(self,_tag,_TGCopy)
    -- 设置章节标题 _tag 为按钮编号
    local TitleLab = self.m_chapArray[self.m_chapTabIdex[_tag]].chap_name 
    self.m_LayerTitleLab : setString(TitleLab)   
    self : loadCopyIcon(_tag) 
    self : addTGicon(_tag,_TGCopy)
---[[
 ---恢复章节和副本退出前的选项
   if self.oldSceneId then 
      self.m_iconTag = nil
      print("self.oldSceneId -->",self.oldSceneId)
      for i = 1 ,COPYCOUNT do
         print("_G.Cfg.scene_copy[].scene[1].id->",self.m_chapTabIdex[i])
         if _G.Cfg.scene_copy[self.m_chapArray[self.m_chapTabIdex[_tag]].copy_id[i]].scene[1].id  ==  self.oldSceneId  then
            self.m_iconBtn[i] : setBright(true)
            self.m_iconBtn[i] : setEnabled(false)
            self.m_iconTag = i
            if self.m_prveSpr ~= nil then self.m_prveSpr : removeFromParent() self.m_prveSpr = nil end 
            local stateSpr = cc.Sprite : createWithSpriteFrameName ("copyui_icon_light.png")
            local iConSize = self.m_iconBtn[i] : getContentSize()
            stateSpr : setPosition(iConSize.width/2,iConSize.height/2)
            self.m_iconBtn[i] : addChild(stateSpr)
            self.m_prveSpr = stateSpr
            self:addRewardSprLab(i,self.m_chapArray[self.m_chapTabIdex[_tag]].copy_id[i])
            self.m_DekaronBtn : setTag(self.m_chapArray[self.m_chapTabIdex[_tag]].copy_id[i]) -- 设置扫荡按钮TAG
            self : sendCopyNetwork(self.m_chapArray[self.m_chapTabIdex[_tag]].copy_id[i])
            break
         end
      end
    end
    if self.oldSceneId  and self.m_iconTag then return  end 
           self.m_iconBtn[1] : setBright(true)
           self.m_iconBtn[1] : setEnabled(false)
           self.m_iconTag = 1
         --   self : addPosui(self.m_ChapBtn[_tag])
            if self.m_prveSpr ~= nil then self.m_prveSpr : removeFromParent() self.m_prveSpr = nil end 
            local stateSpr = cc.Sprite : createWithSpriteFrameName ("copyui_icon_light.png")
            local iConSize = self.m_iconBtn[1] : getContentSize()
            stateSpr : setPosition(iConSize.width/2,iConSize.height/2)
            self.m_iconBtn[1] : addChild(stateSpr)
            self.m_prveSpr = stateSpr
            print("333333333333333333,_tag",_tag)
            self:addRewardSprLab(1,self.m_chapArray[self.m_chapTabIdex[_tag]].copy_id[1])
            self.m_DekaronBtn : setTag(self.m_chapArray[self.m_chapTabIdex[_tag]].copy_id[1]) -- 设置扫荡按钮TAG
            if  self.oldSceneId then self : addPosui(self.m_ChapBtn[_tag])  end  -- 添加章节开放特效
            self : sendCopyNetwork(self.m_chapArray[self.m_chapTabIdex[_tag]].copy_id[1])

   --]]
end 
function DaoJieView.saoDangView(self,_copyId)
    print("扫荡视图",_copyId)
   -- local subTimes=self.m_copysMsg.times_all-self.m_copysMsg.times
    local  data = {}
    local selectTimes =  1
    local canMopTimes =  self.m_Times
    local subTimes    =   5
    data._copyId      = _copyId
    data._selectTimes = selectTimes
    data._canMopTimes = canMopTimes
    data._surplusTimes=  self.m_Times
    data._view = self
    data._eva         = 1
    data._isOffLine   = false    

    local CopyMSaoDangView  =  require("mod.copy.CopySaoDangView")(data)
    view =  CopyMSaoDangView : create()
    self.m_rootLayer : addChild(view,100)
end 

function DaoJieView.getMainData(self)
   local MainData = _G.GPropertyProxy : getMainPlay() --获取玩家数据
   local powerful = MainData.powerful
   local lv = MainData.lv
   local yuanhun = MainData : getYaoLing()
end 

function DaoJieView.dekaronView(self,_copyId)
   print("dekaronView开始跳战视图",_copyId)
   if _copyId == 0 then return end 
   local copyId = _copyId
   
     self : REQ_COPY_NEW_CREAT (copyId)
   
end 
--[[
function DaoJieView.REQ_COPY_CREAT( self,_copyId )
  local msg = REQ_COPY_CREAT()
  msg : setArgs(_copyId)
  _G.Network : send( msg )
end
--]]
function DaoJieView.REQ_COPY_NEW_CREAT(self,_copyId,_key)
   print("REQ_COPY_NEW_CREAT--->",self.m_MsgcopyId,_key)
   local msg = REQ_COPY_NEW_CREAT()

    msg : setArgs(_copyId,_key)
   _G.Network : send(msg)
   --self.m_MsgcopyId = nil
end 

--创建章节按钮
function DaoJieView.DaoJieChapScrollView(self)
    self : removeScrollView ()
    local ScrollView  = cc.ScrollView : create()
    self.m_ScrollView = ScrollView
    
    local viewSize   = cc.size(leftSprSize.width-8,leftSprSize.height-10)
    local oneBtnSize = math.ceil(leftSprSize.height/R_COUNT)
    local ScrollSize   = cc.size(leftSprSize.width,oneBtnSize*chapCount-48)

    ScrollView      : setDirection(ccui.ScrollViewDir.vertical)  -- 设置滚动方向  垂直
    ScrollView      : setViewSize(viewSize)
    ScrollView      : setContentSize(ScrollSize)
    ScrollView      : setContentOffset(cc.p(0,0))              --设置内容的偏移
    ScrollView      : setPosition(cc.p(0,0.5))
   
    ScrollView      : setBounceable(false)         --- 是否开启弹性效果
    ScrollView      : setTouchEnabled(true)
    ScrollView      : setDelegate()

   
   self.m_LastTag = nil 
   local function cfun(sender,eventType) 
  
   end 
   local function DaoJieCallBack(sender,eventType)
       local tag = sender : getTag()
       if eventType == ccui.TouchEventType.ended then
          print("重劫按钮处理函数tag-->",tag)
          ---[[
          local posY = sender : getWorldPosition().y
          if posY>500 or posY< 50  then return end
          print(self.m_chapTabIdex[tag], self.m_chapMsgIds[tag])
          if self.m_chapTabIdex[tag] ~= self.m_chapMsgIds[tag] then 
             local command = CErrorBoxCommand("未完全通关前一层")
             controller : sendCommand( command )
             return 
          end 
          --]]
          if self.m_LastTag ~= nil then 
            self.m_ChapBtn[self.m_LastTag] : setBright(true)
            self.m_ChapBtn[self.m_LastTag] : setEnabled(true)             
          end 
          self.m_LastTag = tag 
          self.m_ChapBtn[tag] : setBright(false)
          self.m_ChapBtn[tag] : setEnabled(false)
          local TitleLab = self.m_chapArray[self.m_chapTabIdex[tag]].chap_name 
          self.m_LayerTitleLab : setString(TitleLab)
          self : loadCopyIcon(tag)
          local TGCopy = {}   
          self : addTGicon(tag,self.m_TGcopys,self.m_MsgChapID)   --给全部通关的章节加通关图标
          self : sendCopyNetwork(self.m_chapArray[self.m_chapTabIdex[tag]].copy_id[1])
      end
    end  


    
    if self.m_chapArray == nil and self.m_chapTabIdex == nil then self:getChapData() end
    local chapArray = self.m_chapArray
    local chapTabIdx = self.m_chapTabIdex
    -- 创建20个BTN
    for i = 1,chapCount do 
      local idex =  chapTabIdx[i]
      local chapData = chapArray[idex]
     
      self.m_Tag[i] = i
      local ChonJieBtn = gc.CButton:create("general_title_one.png","general_title_two.png","general_title_two.png")
      ChonJieBtn : setPosition(cc.p(leftSprSize.width/2,39+(i-1)*71))
      ChonJieBtn : setTag(self.m_Tag[i])
      ChonJieBtn : addTouchEventListener (DaoJieCallBack)
      ChonJieBtn : setSwallowTouches(false)
      --ChonJieBtn : setEnabled(true)
      ScrollView : addChild (ChonJieBtn)
      local BtnSize =  ChonJieBtn : getContentSize()
      local  ChonJieLab = _G.Util : createLabel (chapData.chap_name,FONTSIZE)
      ChonJieLab : setPosition(cc.p(BtnSize.width/2,BtnSize.height/2))
      ChonJieBtn : addChild(ChonJieLab)
      self.m_ChapBtn[i] = ChonJieBtn
    
     end  
     --self : setBtnScrollView(8)
  return ScrollView
end
function DaoJieView.removeScrollView( self )
  if self.m_ScrollView~=nil then
    self.m_ScrollView:removeFromParent(true)
    self.m_ScrollView=nil
  end
  if self.m_barView~=nil then
    self.m_barView:remove()
    self.m_barView=nil
  end
end


function DaoJieView.getChapData(self,_tag)
   print("加载按钮对应副本数据",_tag)
   self.m_chapTabIdex = {}  -- 存放章节id
   self.m_chapArray = {}
   --local tempChapTable = {}
  --local CopychapTable = Cfg.ResList.GetList(_G.Const.CONST_FUNC_OPEN_DAOJIE)
  local chapArray= _G.Cfg.copy_chap[_G.Const.CONST_COPY_TYPE_COPY_HOOK]
   print("chapArray",chapArray[60020].chap_id)
   local i = 0 
   for idex ,onechapTable in pairs(chapArray) do 
       i = i + 1
       
       self.m_chapTabIdex[i]  = tonumber(idex)
   end 
   self : sort (self.m_chapTabIdex)
   self.m_chapArray =  chapArray

end
function DaoJieView.REQ_HOOK_REQUEST (self)
   print("请求道劫界面-->")
   local msg = REQ_HOOK_REQUEST()
   _G.Network : send(msg)

end

function DaoJieView.sort(self,_dataTable) 
 -- print("DaoJieView---》排序")
  table.sort(_dataTable, function (aa,bb)
    return aa<bb
  end)
--[[
 local i =0
 for idex ,onechapTable in pairs(_dataTable) do 
       i = i + 1
       print("id22--->",idex,onechapTable)
       --tempChapTable[i]  =  onechapTable
  end  
--]]
end

--设置扫荡按钮的状态和条件文本的颜色
function DaoJieView.setBtnState(self,_nRet)
   print("setBtnState--->rrrrr",self.m_openTJLabel)
   local nRet = _nRet or  0
  if  nRet == 0 then
      if self.m_DekaronBtnState == 0 then  return end 
      self.m_DekaronBtn : setTitleText("开始挑战")
      self.m_DekaronBtn : setBright(false)
      self.m_DekaronBtn : setEnabled(false)
      self.m_DekaronBtnState = 0
      self.m_openTJLabel : setColor(_G.ColorUtil : getRGB(_G.Const.CONST_COLOR_RED))
  elseif  nRet == 1 then
      if self.m_DekaronBtnState == 1 then return end
      self.m_DekaronBtn : setTitleText("开始挑战")
      self.m_DekaronBtn : setBright(true)
      self.m_DekaronBtn : setEnabled(true)
      self.m_DekaronBtnState = 1  
       self.m_openTJLabel : setColor(_G.ColorUtil : getRGB(_G.Const.CONST_COLOR_GREEN))
  else
      if self.m_DekaronBtnState == 2 then return  end
      self.m_DekaronBtn : setTitleText("扫荡")   
      self.m_DekaronBtn : setBright(true)
      self.m_DekaronBtn : setEnabled(true)
      self.m_openTJLabel : setColor(_G.ColorUtil : getRGB(_G.Const.CONST_COLOR_GREEN))
      self.m_DekaronBtnState = 2
  end
end 
function DaoJieView.sendCopyNetwork(self,_CopyId)
   print("发送副本请求--》",_CopyId)
   if _CopyId == nil then return end
   local copyId = tonumber(_CopyId) 
   print("_CopyId--->", copyId)
   local msg = REQ_HOOK_REQUEST_MSG()
   msg : setArgs(copyId)
   _G.Network : send(msg)
end
function DaoJieView.pushCopyData(self,_flag,_value)
   local flag = _flag or 0
   self : setBtnState(flag)
   self : upTiaoJianLabel(_value)
end 
function DaoJieView.loadCopyIcon(self, _tag) 
   print("loadCopyIcon--->",_tag)
   self : clearCopyIcon()
   local m_iconBtn = {}
   self.m_prveSpr = nil 
   local tag = _tag or 1
   if  self.m_chapTabIdex == nil then return  end 
   local idex = self.m_chapTabIdex[tag]
   local chapData =  self.m_chapArray[idex]
   local tiaoJianTab = {}
   self.m_iconTag  = nil 
   self.m_rewardTab  = {}  

   local function IconBntCallBack(sender, eventType) 
      local tag = sender : getTag () 
      if eventType == ccui.TouchEventType.ended  then 
         m_iconBtn[tag] : setBright(true)
         m_iconBtn[tag] : setEnabled(false)
         if self.m_iconTag ~= nil then  
            m_iconBtn[self.m_iconTag] : setBright (false) 
            m_iconBtn[self.m_iconTag] : setEnabled(true) 
            self.m_iconTag =  tag 

         end 
         self.m_DekaronBtn : setTag(chapData.copy_id[tag])
         self : sendCopyNetwork(chapData.copy_id[tag])
         --self : setBtnState (tag%3)
         
         if self.m_prveSpr ~= nil then self.m_prveSpr : removeFromParent() self.m_prveSpr = nil  end 
         local stateSpr = cc.Sprite : createWithSpriteFrameName ("copyui_icon_light.png")
         local iConSize = m_iconBtn[tag] : getContentSize()
         stateSpr : setPosition(iConSize.width/2,iConSize.height/2)
         m_iconBtn[tag] : addChild(stateSpr)
         self.m_prveSpr = stateSpr
         self:addRewardSprLab(tag,chapData.copy_id[tag])
      end
   end
   local nCount =  #chapData.copy_id
   local item = 0
   for i = 1, nCount/4  do    --nCount = 8
       local  xPos = 0 
       local  yPos  = 0            
      for ii = 1, nCount/2  do 
        item = item + 1
         xPos = rightSprSize.width/2-220+(ii-1)*146  
         yPos = rightSprSize.height/2-28 + (i-1)*146

         local iconName,copyName,openCondition  = self : getCopyPictureAndName(tag,item)
         tiaoJianTab[item]  =  openCondition
         
         local IconBnt = gc.CButton : create()
         IconBnt : loadTextures ("copyui_dec_bg.png")
         IconBnt : setPosition(cc.p(xPos,yPos))
         IconBnt : setButtonScale(0.9)
         IconBnt : setTag(item)
         IconBnt : addTouchEventListener(IconBntCallBack)
         if self.m_rightBgSpr == nil then print("error") return  end 
         self.m_rightBgSpr : addChild(IconBnt)
         m_iconBtn[item] =  IconBnt
         IconBnt : setBright (false)  
         IconBnt : setEnabled (true)
         if item == 1 and self.oldSceneId == nil then 
            IconBnt : setBright (true)  
            IconBnt : setEnabled (false)
            self.m_iconTag = item
            self.m_DekaronBtn : setTag(self.m_chapArray[self.m_chapTabIdex[1]].copy_id[1])    -- 设置扫荡按钮TAG       
            if self.m_prveSpr ~= nil then self.m_prveSpr : removeFromParent() self.m_prveSpr = nil end 
            local stateSpr = cc.Sprite : createWithSpriteFrameName ("copyui_icon_light.png")
            local iConSize = m_iconBtn[1] : getContentSize()
            stateSpr : setPosition(iConSize.width/2,iConSize.height/2)
            m_iconBtn[1] : addChild(stateSpr)
            self.m_prveSpr = stateSpr
         end 
         
         local IconSize =  IconBnt : getContentSize ()
         --local IconSpr =  cc.Sprite : createWithSpriteFrameName(iconName)
         local  IconSpr = gc.GraySprite : createWithSpriteFrameName(iconName)
         IconSpr : setScale(1.2)
         IconSpr : setPosition(cc.p(IconSize.width/2-7,IconSize.height/2+3.4))
         IconBnt : addChild(IconSpr,-1)
        
         if copyName == nil  then  return end
         local copyNameLab = _G.Util : createLabel (copyName,FONTSIZE-1)
          local IconSprSize =  IconSpr : getContentSize()
          copyNameLab : setPosition(IconSprSize.width/2+30,IconSprSize.height/2-18)
         local ColorVaue = _G.ColorUtil : getRGB(_G.Const.CONST_COLOR_RED)
         -- self.m_openTJLabel : setColor(ColorVaue)
          IconBnt : addChild(copyNameLab)
      end
   end 
   
   self.m_tiaoJianTab =  tiaoJianTab
   self.m_iconBtn    =  m_iconBtn
   self:addRewardSprLab(1,chapData.copy_id[1])
end 

function DaoJieView.clearCopyIcon(self)
  if self.m_iconBtn == nil then return  end
  print("清空所有按钮图标")
  for i = 1,8 do 
   if self.m_iconBtn[i] ~= nil then 
    self.m_iconBtn[i] : removeFromParent(true)
    self.m_iconBtn[i] = nil 
   end
  end
end
   
function DaoJieView.addRewardSprLab( self,_idex,_copyId )
    local BtnSize =  self.m_rewardKBtn[1] : getContentSize()
    local nCount = #self.m_rewardTab[_idex]
    for i = 1,nCount do
      if i > 3 then break end
      if self.m_rewardSpr[1][i] ~= nil then self.m_rewardSpr[1][i] : removeFromParent (true) self.m_rewardSpr[1][i] = nil end 
      if self.m_rewardSpr[2][i] ~= nil then self.m_rewardSpr[2][i] : removeFromParent (true) self.m_rewardSpr[2][i] = nil end 
      if self.m_rewardSpr[3][i] ~= nil then self.m_rewardSpr[3][i] : removeFromParent (true) self.m_rewardSpr[2][i] = nil end 

      local strIcon = string.format("%s.png",tostring(self.m_rewardTab[_idex][i][1][1]))
      local goodsName = self.m_rewardTab[_idex][i][1][2]
      local goodData = _G.Cfg.goods[self.m_rewardTab[_idex][i][1][1]]
      --local goodName = goodData.name 
      local goodColr = goodData.name_color      
      print("strIcon-->",strIcon,BtnSize.width/2)

      local function cFun(sender,eventType)
        if eventType==ccui.TouchEventType.ended then
          local btn_tag=sender:getTag()
          local _pos = sender:getWorldPosition()
          local temp = _G.TipsUtil:createById(btn_tag,nil,_pos)
          cc.Director:getInstance():getRunningScene():addChild(temp,1000)
        end
      end
      local rewardSpr = _G.ImageAsyncManager:createGoodsBtn(goodData,cFun,goodData.id,goodsName)
      -- rewardSpr : setScale(0.8)
      rewardSpr : setPosition(BtnSize.width/2,BtnSize.height/2)
      self.m_rewardKBtn[i] : addChild(rewardSpr) 
      self.m_rewardSpr[1][i] = rewardSpr

      -- local rewardNumLab = _G.Util : createLabel(tostring(goodsName),FONTSIZE-2)
      -- rewardNumLab : setHorizontalAlignment(cc.TEXT_ALIGNMENT_RIGHT)
      -- rewardNumLab : setPosition(BtnSize.width/2,BtnSize.height/2-26)
      -- self.m_rewardKBtn[i] : addChild(rewardNumLab)
      -- self.m_rewardSpr[2][i] = rewardNumLab
      
      --[[
      local goodNameLab = _G.Util : createLabel(goodName,FONTSIZE)
      goodNameLab : setPosition(BtnSize.width/2,BtnSize.height/2+22)
      goodNameLab : setColor(_G.ColorUtil : getRGB(goodColr))
      self.m_rewardKBtn[i] : addChild(goodNameLab)
      self.m_rewardSpr[3][i] = goodNameLab
      --]]
    end
end
function DaoJieView.getCopyPictureAndName(self,_idex,item) 
    local szIcon="copyui_icon_0.png"
    local SFCache=cc.SpriteFrameCache:getInstance()

   if self.m_chapArray == nil then self : getChapData () end
   local idex = self.m_chapTabIdex[_idex]
   local chapTab = self.m_chapArray[idex]
   local iconId = chapTab.copy_id[item]
    local teamData = _G.Cfg.scene_copy[iconId]
    local copyName = teamData.copy_name
    local DekaronLv = teamData.lv
    local openCondition = teamData.tiaojian
    self.m_rewardTab[item] = teamData.reward
    local nIcon = teamData. img[1] 
    local szHead = nil 
    if nIcon and nIcon >0 then
      szHead = string.format("h%d.png",nIcon)
      if not SFCache:getSpriteFrame(szHead) then
        szHead="h20001.png"
      end 
    end   
    --print("szHead-->",szHead)
   return szHead ,copyName,openCondition
end 

--获取主角资质
function DaoJieView.getTiaoJianText(self,_tiaojianTab)
   local tiaoJianTab = _tiaojianTab or  1

   local needData = nil
   if tiaoJianTab == _G.Const.CONST_DAOJIE_DENGJI  then  needData =  "等级" end 
   if tiaoJianTab == _G.Const.CONST_DAOJIE_SHIPIN  then  needData =  "饰品战力" end 
   if tiaoJianTab == _G.Const.CONST_DAOJIE_YUANPO  then  needData =  "元魄战力" end 
   if tiaoJianTab == _G.Const.CONST_DAOJIE_BAGUA   then needData  =  "八卦战力" end 
   if tiaoJianTab == _G.Const.CONST_DAOJIE_LINGYAO  then needData =  "灵妖战力" end 
   if tiaoJianTab == _G.Const.CONST_DAOJIE_ZUOQI  then needData   =  "坐骑战力" end 
   if tiaoJianTab == _G.Const.CONST_DAOJIE_CHONGWU  then needData =  "宠物战力" end 
   if tiaoJianTab == _G.Const.CONST_DAOJIE_SHENQI  then needData  =  "神器战力" end 
   if tiaoJianTab == _G.Const.CONST_DAOJIE_CHIBANG  then needData =  "翅膀战力" end 
   if tiaoJianTab == _G.Const.CONST_DAOJIE_WUQI    then needData  =  "武器战力" end 
   if tiaoJianTab == _G.Const.CONST_DAOJIE_ZHANLI then needData   =  "总战力" end 
   if tiaoJianTab == _G.Const.CONST_DAOJIE_WUXING then needData  =  "五行战力" end 
   if tiaoJianTab == _G.Const.CONST_DAOJIE_BAOSHI then needData   =  "宝石战力" end 
   return needData
end 

function DaoJieView.isChallengeQualification(self,_roleData,_tiaojianTab)
    
    if _roleData == nil or _tiaojianTab == nil then return  false   end  --- 临时返回true 要改false
    print("_tiaojianTab",_tiaojianTab[1],_tiaojianTab[2])
    print("_roleData",_roleData[_tiaojianTab[1]])
    if _roleData[_tiaojianTab[1]] > _tiaojianTab[2]   then return true  end 
   return false 
end 
function DaoJieView.pushDada(self,_ackMsg)
   self.m_Times  = _ackMsg.times
   self.m_TGcopys = _ackMsg.copys 
   self.m_MsgChapID = _ackMsg.chap_id
   if _ackMsg.times <= _G.Const.CONST_DAOJIE_SAODANG and  _ackMsg.alltimes  <= _G.Const.CONST_DAOJIE_SAODANG then  
      local strSaodang = string.format("%d/%d",_ackMsg.times, _ackMsg.alltimes)
      print("strSaodang-->",strSaodang)
      self.m_saodanLab : setString(strSaodang)
    else 
       print("扫荡次数错误")
   end 

   local chapIds = {}
   if _ackMsg.count == 0 then  
      chapIds[1] = _ackMsg.chap_id
     -- self : setLeftBtnState(chapIds)
   else 
      for i = 1, _ackMsg.count do
         chapIds[i] = _ackMsg.chaps[i].chap_id
         print("chapIds[i]-->",chapIds[i])
      end 
    --  self : setLeftBtnState(chapIds)
  end
  self : sort(chapIds)
  self.m_chapMsgIds = chapIds
--设置默认按钮
  for i = 1,chapCount do 
     if self.m_chapTabIdex[i] == _ackMsg.chap_id then 
        if chapIds[i] ~= nil and  self.m_LastTag == nil then  -- 第一次才进入
          self.m_ChapBtn[i] : setBright(false)
          self.m_ChapBtn[i] : setEnabled(false)
          self.m_LastTag = i
          -- 设置章节按钮滚动位置
          self : setBtnScrollView(i)
          self : upInitDate(self.m_LastTag,_ackMsg.copys)
          break
        end      
     end
  end 
end 

-- 给按钮添加开放特效
function DaoJieView.addPosui(self,_button)
   print("给按钮添加开放特效")
    local Size = _button : getContentSize()
    local tempGafAsset=gaf.GAFAsset:create("gaf/posui.gaf")
    self.tempObj = tempGafAsset:createObject()
    local nPos=cc.p(Size.width/2,Size.height/2)
    self.tempObj:setLooped(false,false)
    self.tempObj:start()
    self.tempObj:setPosition(nPos)
    _button : addChild(self.tempObj,1000)
end 
-- 设置章节按钮滚动位置
function DaoJieView.setBtnScrollView(self,_tag) 
   local ScrroViewSize = self.m_ScrollView : getContentSize()
   local oneHeight  = ScrroViewSize.height/chapCount  -- 一个按钮占的高度
    if _tag > R_COUNT and _tag < 2*R_COUNT then 
       local yPos = R_COUNT * oneHeight 
       print("yPos---->",ScrroViewSize,oneHeight,yPos)
       self.m_ScrollView :setContentOffset(cc.p(0,-yPos+4)) 
    end 
    if _tag >= 2*R_COUNT then 
       local yPos = 2*R_COUNT*oneHeight - oneHeight
       self.m_ScrollView :setContentOffset(cc.p(0,-yPos+4)) 
    end 
end 
--添加副本通关标签
function DaoJieView.addTGicon(self,_chapTag,_TGcopy)
   if self.m_iconBtn == nil then return end 
   local BtnSize = self.m_iconBtn[1] : getContentSize()
   local isCopy = {}
   local TGcopy = _TGcopy or {}
   print("addTGicon-->",_chapTag,#self.m_chapMsgIds, #TGcopy)

   local copyIds = self.m_chapArray[self.m_chapTabIdex[_chapTag]].copy_id
   for _,v in ipairs(TGcopy) do 
      --print("isCopy[v]--->",v.id)
      isCopy[v.id] = true
   end
   for i = 1,8 do 
      if _chapTag < #self.m_chapMsgIds then 
         local TGSpr = cc.Sprite : createWithSpriteFrameName("copyui_pass.png")
         TGSpr : setRotation (-40)
         TGSpr : setPosition(BtnSize.width/2-54 ,BtnSize.height/2+10)
         self.m_iconBtn[i] : addChild(TGSpr)
      end 

      if _chapTag == #self.m_chapMsgIds and  isCopy[copyIds[i]] == true  then 
        print("--------------sss")
         local TGSpr = cc.Sprite : createWithSpriteFrameName("copyui_pass.png")
         TGSpr : setRotation (-40)
         TGSpr : setPosition(BtnSize.width/2-54 ,BtnSize.height/2+10)
         self.m_iconBtn[i] : addChild(TGSpr)
      end
   end 
end 
function DaoJieView.upTiaoJianLabel(self,_value)
    print("-->upTiaoJianLabel,_value===》",_value,self.m_iconTag,self.m_tiaoJianTab)
    local strViue = self : getTiaoJianText(self.m_tiaoJianTab[self.m_iconTag][1])
    local strTiaoJian = string.format("%s达到%d/%s",strViue,_value,tostring(self.m_tiaoJianTab[self.m_iconTag][2]))
    self.m_openTJLabel : setPosition(rightSprSize.width-126-#strTiaoJian*4,16)
    self.m_openTJLabel : setString(strTiaoJian)  
    print("strTiaoJian-->",#strTiaoJian)

end
function DaoJieView.closeWindow(self)
    print("closeWindow---->")
    if self.m_rootLayer==nil then return end
    self.m_rootLayer=nil
    self.m_rewardSpr = nil 
    self.m_iconTag = nil
    self.m_prveSpr = nil 
    self.m_iconBtn = nil
    self.m_saodanLab = nil
    self.m_chapMsgIds = nil 
    self.m_LastTag = nil 
    self.m_DekaronBtnState  = nil 
    self.m_TGcopys =  nil
    self.m_MsgChapID = nil  
    if self.tempObj  then  self.tempObj :removeFromParent()  self.tempObj  = nil end
    self : removeScrollView()
     
    cc.Director:getInstance():popScene()
    self: destroy()
    self:__removeMopScheduler()

    self : unregister()
  ----[[
    if self.m_hasGuide then
        local command=CGuideNoticShow()
        controller:sendCommand(command)
    end
 --]]
end
function DaoJieView.unregister(self)
    self.m_DaoJieMediator : destroy()
    self.m_DaoJieMediator = nil 
    self.m_chapMsgIds = nil 
end

function DaoJieView.__removeMopScheduler(self)
    if self.m_mopScheduler then
        _G.Scheduler:unschedule(self.m_mopScheduler)
        self.m_mopScheduler=nil
    end
end


return DaoJieView 