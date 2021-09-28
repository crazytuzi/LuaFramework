-- Filename: RobTreasureCell.lua
-- Author: zhz
-- Date: 2013-11-6
-- Purpose: 创建强夺宝物的Cell

module("RobTreasureCell",package.seeall)

require "script/ui/hero/HeroPublicCC"
require "script/ui/treasure/TreasureUtil"
require "script/ui/treasure/TreasureService"
require "script/ui/treasure/TreasureData"
require "script/model/user/UserModel"
require "script/audio/AudioUtil"
require "script/ui/item/ItemUtil"

require "script/ui/tip/AnimationTip"


local _item_temple_id = nil
local _callbackFunc= nil
local _robtime = 10


-- 抢夺的回调函数
local function robAction( tag, item )
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    require "script/guide/RobTreasureGuide"
    if(NewGuide.guideClass ==  ksGuideRobTreasure) then
        RobTreasureGuide.cleanLayer()
    end
    item:setEnabled(false)
    
    local uid = tag
    require "script/ui/treasure/RobTreasureView"

    TreasureService.seizeRicher(uid, _item_temple_id,function ( isSuccess)
        item:setEnabled(true)
        if(isSuccess) then
          RobTreasureView.refreshUI()
          if(RobTreasureView.curUserLevel < UserModel.getHeroLevel()) then
            RobTreasureView.robCallBack()
          end
        end
    end
     )
end

--一键夺宝回调 
-- added by DJN in 2014/07/22
function quickRobBtnCallback( tag, item )

    local config = string.split(DB_Normal_config.getDataById(1).duobao1display_lv, "|")
    local needLevel = tonumber(config[2])
    if UserModel.getHeroLevel() < needLevel then
      AnimationTip.showTip(GetLocalizeStringBy("lcyx_3000", needLevel))
      return
    end
    
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    local uid = tag
    
    --判断背包
    if ( ItemUtil.isBagFull() ) then 
      return 
    end
    -- 判断武将是否已满
    require "script/ui/hero/HeroPublicUI"
    if HeroPublicUI.showHeroIsLimitedUI() then
      return
    end
    --获取当前耐力
    local stamina = UserModel.getStaminaNumber() 
    --判断耐力是否足够抽1次
    if(stamina < 2)then
        --耐力不足提示使用耐力丹
        require "script/ui/item/StaminaAlertTip"
        require "script/ui/treasure/RobTreasureView"
        StaminaAlertTip.showTip(RobTreasureView.refreshUI)
        return
    end 
    item:setEnabled(false)
    --计算当前耐力最多可以抽几次，并传给后端,最多十次
    local times = math.floor(stamina/2)
    if(times > 10)then
      times = 10
    end
    --网络回调
    TreasureService.quickSeize(uid, _item_temple_id,times, function ( isSuccess)
        item:setEnabled(true)
        if(isSuccess) then
            if(RobTreasureView.curUserLevel < UserModel.getHeroLevel()) then
              RobTreasureView.robCallBack()
            end 
            RobTreasureView.refreshUI()
            --创建结果展示面板
            require "script/ui/treasure/QuickRobResultLayer"
            QuickRobResultLayer.showLayer()
        
        end
    end)
 end

 
--一键夺宝回调 
-- added by DJN in 2014/07/22
--[[
function quickRobBtnCallback( tag, item )
    require "script/ui/treasure/QuickRobData"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    local uid = tag
    
    --存下欲获取的碎片
    QuickRobData.setItemid(_item_temple_id)
    --判断背包
    if ( ItemUtil.isBagFull() ) then  
      return 
    end

    -- 判断武将是否已满
    require "script/ui/hero/HeroPublicUI"
    if HeroPublicUI.showHeroIsLimitedUI() then
      return
    end

    local stamina = UserModel.getStaminaNumber()
    --判断耐力是否足够抽10次
    if(stamina < 2*_robtime)then
      --耐力不足提示使用耐力丹
      require "script/ui/item/StaminaAlertTip"
      require "script/ui/treasure/RobTreasureView"
      StaminaAlertTip.showTip(RobTreasureView.refreshUI)
      item:setEnabled(true)
      return
    end 

    item:setEnabled(false)
    --网络回调
    TreasureService.quickSeize(uid, _item_temple_id,10, function ( data)
        item:setEnabled(true)
        if(RobTreasureView.curUserLevel < UserModel.getHeroLevel()) then
          RobTreasureView.robCallBack()
        end 
        --获取网络数据
        QuickRobData.setQuickRobData(data)

        local m_QuickRobInfo = QuickRobData.getQuickRobData() 
        --更新获得的reward中得银币
        QuickRobData.UpdateSilverInReward(m_QuickRobInfo.ret)

        if(m_QuickRobInfo.ret == "fail" )then
          --提示战斗失败，让用户返回检查是否有此碎片
          --后端规则为：如果已经有了这个碎片，再抢夺，会返回fail
          --在个活动中，有一个概率非常非常非常非常非常小的事件，抢夺的时候没有抢到想要的碎片，但是翻牌的时候翻到了，所以加这一层判断
          AnimationTip.showTip(GetLocalizeStringBy("djn_7"))
          return
        end
        if(m_QuickRobInfo.ret ~= nil) then
          local donum = tonumber(m_QuickRobInfo.ret.donum)
          UserModel.addStaminaNumber(-(donum*2))
          RobTreasureView.refreshUI()
          --创建结果展示面板
          require "script/ui/treasure/QuickRobResultLayer"
          QuickRobResultLayer.showLayer()
        else
          --提示战斗出错
          AnimationTip.showTip(GetLocalizeStringBy("lic_1014"))
        end
    end)
 end
--]]
--[[
function quickRobBtnCallback( tag, item )
 require "script/ui/treasure/CrossServerRewardPreviewLayer"
 CrossServerRewardPreviewLayer.showLayer()
end
--]]


-- 创建cell
function createCell( cellValues, item_temple_id)
    _item_temple_id = item_temple_id

  	local tCell = CCTableViewCell:create()

  	-- cell 的背景
  	local cellBg= CCScale9Sprite:create("images/arena/arena_cellbg.png")

  	tCell:addChild(cellBg,1,101)

  	-- 名字背景
  	local fullRect = CCRectMake(0,0,47,27)
  	local insetRect = CCRectMake(15,12,5,5)
  	local nameBg = CCScale9Sprite:create("images/arena/heroname_bg.png", fullRect, insetRect)
  	--nameBg:setContentSize(CCSizeMake(248,26))
    nameBg:setContentSize(CCSizeMake(288,26))
  	nameBg:setAnchorPoint(ccp(0,1))
  	nameBg:setPosition(ccp(20,cellBg:getContentSize().height-15))
  	cellBg:addChild(nameBg)
  	-- lv
  	local lvSprite = CCSprite:create("images/common/lv.png") 
  	lvSprite:setAnchorPoint(ccp(0,0.5))
  	lvSprite:setPosition(ccp(10,nameBg:getContentSize().height*0.5))
  	nameBg:addChild(lvSprite)
  	-- -等级
  	local lvLabel = CCRenderLabel:create( "" .. cellValues.level , g_sFontName, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    lvLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    lvLabel:setPosition(ccp(lvSprite:getPositionX()+lvSprite:getContentSize().width+5,nameBg:getContentSize().height-3))
    nameBg:addChild(lvLabel)
   	--  -- 名字
   	local nameLabel = CCRenderLabel:create( cellValues.uname , g_sFontName, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    nameLabel:setColor(ccc3(0xff, 0xff, 0xff))
    nameLabel:setPosition(ccp(lvLabel:getPositionX()+lvLabel:getContentSize().width+18,nameBg:getContentSize().height-1))
   	nameBg:addChild(nameLabel)

   	-- 概率
    local nameColor = TreasureUtil.getPercentColorByName(cellValues.ratioDesc)

   	local ratioDesc = CCRenderLabel:create(cellValues.ratioDesc, g_sFontPangWa, 23, 1, ccc3(0x00,0x00,0x00), type_stroke)
   	-- ratioDesc:setColor(ccc3(0x36,0xff,0x00))
    ratioDesc:setColor(nameColor)
   	ratioDesc:setPosition(ccp(cellBg:getContentSize().width/2 , cellBg:getContentSize().height-12))
   	ratioDesc:setAnchorPoint(ccp(0,1))
   	cellBg:addChild(ratioDesc)


   	-- 对方英雄的背景
   	local fullRect = CCRectMake(0, 0, 75, 75)
    local insetRect = CCRectMake(30, 30, 15, 10)
   	local heroBg = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png", fullRect, insetRect)
   	heroBg:setContentSize(CCSizeMake(444,100))
   	heroBg:setAnchorPoint(ccp(0,0.5))
   	heroBg:setPosition(ccp(23,cellBg:getContentSize().height*0.5))
   	cellBg:addChild(heroBg)

   	--英雄
    local vip = cellValues.vip or 0
    local sortSquad = TreasureUtil.sortQuad(cellValues.squad, cellValues.npc)
   	for k,v in pairs(sortSquad) do
      if( k <4) then
     		local robHeadSprite = TreasureUtil.getRobberHeadIcon(cellValues.npc,v, vip)
        robHeadSprite:setAnchorPoint(ccp(0,0.5))
        robHeadSprite:setPosition(30 + 132*(k-1), heroBg:getContentSize().height/2)
        heroBg:addChild(robHeadSprite)
      end
   	end

   	local menu = CCMenu:create()
   	menu:setPosition(ccp(0,0))
   	cellBg:addChild(menu,1,101)
   	--抢夺按钮
   	local robBtn =  LuaCC.create9ScaleMenuItem("images/common/btn/btn_blue_n.png","images/common/btn/btn_blue_h.png",CCSizeMake(144, 83),GetLocalizeStringBy("key_1946"),ccc3(0xfe, 0xdb, 0x1c),40,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
   	robBtn:setPosition(heroBg:getContentSize().width + heroBg:getPositionX()+10, cellBg:getContentSize().height * 0.28)
   	robBtn:setAnchorPoint(ccp(0, 0.5))
   	robBtn:registerScriptTapHandler(robAction)
   	menu:addChild(robBtn,1,cellValues.uid)
    --连续抢夺按钮
    local quickRobBtn =  LuaCC.create9ScaleMenuItem("images/common/btn/btn_violet_n.png","images/common/btn/btn_violet_h.png",CCSizeMake(144, 83),GetLocalizeStringBy("lcy_10046"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    quickRobBtn:setPosition(heroBg:getContentSize().width + heroBg:getPositionX()+12, cellBg:getContentSize().height * 0.72)
    quickRobBtn:setAnchorPoint(ccp(0, 0.5))
    quickRobBtn:registerScriptTapHandler(quickRobBtnCallback)
    menu:addChild(quickRobBtn,1,cellValues.uid)

    local config = string.split(DB_Normal_config.getDataById(1).duobao1display_lv, "|")
    local showLevel = tonumber(config[1])

    if(tonumber(cellValues.npc) ~= 1 or tonumber(UserModel.getHeroLevel())<showLevel ) then
      quickRobBtn:setVisible(false)
      robBtn:setPosition(heroBg:getContentSize().width + heroBg:getPositionX()+10, cellBg:getContentSize().height * 0.5)
    end


	return tCell
end
