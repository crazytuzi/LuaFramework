


local ShowValueLayer = class("ShowExpLayer",UFCCSNormalLayer)


function ShowValueLayer.create(compare_value)
    return ShowValueLayer.new("ui_layout/fightend_FightEndShowValueLayer.json",compare_value)
end

function ShowValueLayer:ctor( json,compare_value,... )
	self._compare_value = compare_value
	self.super.ctor(self, ...)
	self:getLabelByName("Label_title"):createStroke(Colors.strokeBrown,1)
	self:getLabelByName("Label_title"):setColor(Colors.darkColors.TITLE_02)
    self:getLabelByName("Label_value"):createStroke(Colors.strokeBrown,1)
    self:getLabelByName("Label_value"):setColor(Colors.darkColors.DESCRIPTION)
    self:getLabelByName("Label_title"):setText("")
    self:getLabelByName("Label_value"):setText("")

    self:getLabelByName("Label_baojilv"):createStroke(Colors.strokeBrown,1)
    self:getLabelByName("Label_active"):createStroke(Colors.strokeBrown,1)
    self:setClickSwallow(true)

end

function ShowValueLayer:getContentSize( )
	return self:getPanelByName("Panel_container"):getContentSize()
	
end

function ShowValueLayer:setEndCallback(endCallback)
    self._endCallback = endCallback

    self._flashInterval = 1/30
    self._maxFlashCount = 10

    self._currentValue = 0
    self._valueDelta = 0
    self._timer = nil
end



function ShowValueLayer:setData(key, value)
	self._value = value
	self._key = key
  

	if key == "money" then
	  	self:getLabelByName("Label_title"):setText(G_lang:get("LANG_FIGHTEND_GETMONEY"))
	  	self:getImageViewByName("ImageView_icon"):loadTexture("icon_mini_yingzi.png",      UI_TEX_TYPE_PLIST  )
        self:getImageViewByName("ImageView_icon"):setVisible(true)

  	elseif key == "tower_score" or key == "tower_money" then
  		if key == "tower_score" then
          self:showWidgetByName("Label_active",G_Me.activityData.custom:isWushActive())   --是否翻倍活动中
	  	  	self:getLabelByName("Label_title"):setText(G_lang:get("LANG_FIGHTEND_GETTOWERSCORE"))
	  	  	self:getImageViewByName("ImageView_icon"):loadTexture( "icon_mini_patajifen.png",      UI_TEX_TYPE_PLIST )
  		else
  			self:getLabelByName("Label_title"):setText(G_lang:get("LANG_FIGHTEND_GETMONEY"))
  			self:getImageViewByName("ImageView_icon"):loadTexture("icon_mini_yingzi.png",      UI_TEX_TYPE_PLIST  )
  		end
        self:getImageViewByName("ImageView_icon"):setVisible(true)
        --用来比对的
        if self._compare_value and type(self._compare_value) == "number" then
        	self:showWidgetByName("Label_baojilv",true)
          if G_Me.activityData.custom:isWushActive() and key == "tower_score" then   --威名翻倍
            self._compare_value = self._compare_value * 2
          end
        	local delta = value/self._compare_value
        	if delta == 1 then
        		self:getLabelByName("Label_baojilv"):setColor(Colors.qualityColors[4])
        		self:getLabelByName("Label_baojilv"):setText(G_lang:get("LANG_FIGHTEND_BAO_JI"))
        	elseif delta == 1.2 then
        		self:getLabelByName("Label_baojilv"):setText(G_lang:get("LANG_FIGHTEND_DA_BAO_JI"))
        		self:getLabelByName("Label_baojilv"):setColor(Colors.qualityColors[4])
        	elseif delta == 1.6 then
        		self:getLabelByName("Label_baojilv"):setText(G_lang:get("LANG_FIGHTEND_XING_YUN_BAO_JI"))
        		self:getLabelByName("Label_baojilv"):setColor(Colors.qualityColors[5])
        	else
        		self:showWidgetByName("Label_baojilv",false)
        	end
        end
  	elseif key == "damage" then
  	  	self:getLabelByName("Label_title"):setText(G_lang:get("LANG_FIGHTEND_GETDAMAGE"))
        self:getImageViewByName("ImageView_icon"):setVisible(false)
  	elseif key == "gongxun" then
  	  	self:getLabelByName("Label_title"):setText(G_lang:get("LANG_FIGHTEND_GETGONGXUN"))
  	  	self:getImageViewByName("ImageView_icon"):setVisible(false)
        self:showWidgetByName("Label_active",G_Me.activityData.custom:isGongxunActive())--是否翻倍活动中
    elseif key == "zhangong" then   --战功
        self:getLabelByName("Label_title"):setText(G_lang:get("LANG_FIGHTEND_ZHANGONG"))
        self:getImageViewByName("ImageView_icon"):loadTexture("icon_mini_jiangzhang.png",      UI_TEX_TYPE_PLIST  )
        self:getImageViewByName("ImageView_icon"):setVisible(true)
  	elseif key == "prestige" then
  	  	self:getLabelByName("Label_title"):setText(G_lang:get("LANG_FIGHTEND_GETSHENGWANG"))
  		self:getImageViewByName("ImageView_icon"):loadTexture(  "icon_mini_shenwang.png",      UI_TEX_TYPE_PLIST)
        self:getImageViewByName("ImageView_icon"):setVisible(true)
        self:showWidgetByName("Label_active",G_Me.activityData.custom:isShengwangActive())--是否翻倍活动中
    elseif key == "gongxian" then  --军团贡献
      self:getLabelByName("Label_title"):setText(G_lang:get("LANG_FIGHTEND_JUN_TUAN_GONG_XIAN"))
      self:getImageViewByName("ImageView_icon"):setVisible(true)
      self:getImageViewByName("ImageView_icon"):loadTexture("icon_mini_juntuangongxian.png",      UI_TEX_TYPE_PLIST  )

    elseif key == "last_attack" then   --最后一击
      self:getLabelByName("Label_title"):setText(G_lang:get("LANG_FIGHTEND_LAST_ATTACK"))
      self:getImageViewByName("ImageView_icon"):setVisible(true)
      self:getImageViewByName("ImageView_icon"):loadTexture(G_Path.getPriceTypeIcon(2))
    elseif key == "last_attack_award" then   --最后一击 奖励可能不是元宝
      self:getLabelByName("Label_title"):setText(G_lang:get("LANG_FIGHTEND_LAST_ATTACK"))
      self:getImageViewByName("ImageView_icon"):setVisible(true)
      local award = self._compare_value
      local goodInfo = G_Goods.convert(award.type, award.value, award.size)
      self:getImageViewByName("ImageView_icon"):loadTexture(goodInfo.icon_mini,goodInfo.texture_type)
    elseif key == "rob_exp" then  --军团战掠夺经验 
      self:getLabelByName("Label_title"):setText(G_lang:get("LANG_JUNTUAN_ROB_EXP"))
      self:getImageViewByName("ImageView_icon"):setVisible(false)
    elseif key == "crosswar_score" then --跨服演武积分
      self:getLabelByName("Label_title"):setText(G_lang:get("LANG_FIGHTEND_CROSSWARSCORE"))
      self:getImageViewByName("ImageView_icon"):setVisible(false)
    elseif key == "crosswar_medal" then --演武勋章
      self:getLabelByName("Label_title"):setText(G_lang:get("LANG_GOODS_CROSSWAR_MEDAL") .. "：")
      self:getImageViewByName("ImageView_icon"):setVisible(true)
      self:getImageViewByName("ImageView_icon"):loadTexture("icon_yanwuxunzhang.png", UI_TEX_TYPE_PLIST )
    elseif key == "rongyu" then
      -- 世界Boss
      self:getLabelByName("Label_title"):setText(G_lang:get("LANG_FIGHTEND_GETRONGYU"))
      self:getImageViewByName("ImageView_icon"):setVisible(false)
      self:showWidgetByName("Label_active", false)--是否翻倍活动中
    elseif key == "rice" then -- 争粮战粮草
      self:getLabelByName("Label_title"):setText(G_lang:get("LANG_ROB_RICE_ROB_RICE_MOUNT") .. "：")
      self:getImageViewByName("ImageView_icon"):setVisible(false)
    elseif key == "rice_prestige" then -- 夺粮战的声望奖励
      self:getLabelByName("Label_title"):setText(G_lang:get("LANG_FIGHTEND_GETSHENGWANG"))
      self:getImageViewByName("ImageView_icon"):loadTexture(  "icon_mini_shenwang.png",      UI_TEX_TYPE_PLIST)
      self:getImageViewByName("ImageView_icon"):setVisible(true)
    elseif key == "foster_pill" then -- 培养丹
      self:getLabelByName("Label_title"):setText(G_lang:get("LANG_ROB_RICE_FOSTER_PILL_MOUNT") .. "：")
      self:getImageViewByName("ImageView_icon"):loadTexture("icon_mini_peiyangdan.png", UI_TEX_TYPE_PLIST )
      self:getImageViewByName("ImageView_icon"):setVisible(true)
    elseif key == "zhangongboss" then   --叛军Boss的战功
      self:getLabelByName("Label_title"):setText(G_lang:get("LANG_FIGHTEND_ZHANGONG"))
      self:getImageViewByName("ImageView_icon"):loadTexture("icon_mini_jiangzhang.png",      UI_TEX_TYPE_PLIST  )
      self:getImageViewByName("ImageView_icon"):setVisible(true)
      -- 显示暴击
      local labelBaoJi = self:getLabelByName("Label_baojilv")
      local nCritId = G_Me.moshenData:getCritId()
      if nCritId ~= 1 then
          local tTmpl = rebel_boss_attack_reward_info.get(nCritId)
          if tTmpl then
              labelBaoJi:setText(tTmpl.name)
              labelBaoJi:setColor(Colors.qualityColors[tTmpl.quality])
              labelBaoJi:setVisible(true)
          end
      else
          labelBaoJi:setVisible(false)
      end
    elseif key == "crusade_pet_point" then --战宠积分
      local container = self:getPanelByName("Panel_container")
      --container:setPositionX(display.cx - container:getContentSize().width)
      container:setPositionX(20)
      self:getLabelByName("Label_title"):setText(G_lang:get("LANG_CRUSADE_GET_PET_POINT"))
      self:getImageViewByName("ImageView_icon"):setVisible(true)
      self:getImageViewByName("ImageView_icon"):loadTexture("icon_mini_shouhun.png", UI_TEX_TYPE_PLIST )
    elseif key == "crusade_award_size" then --百战沙场额外奖励
      if self._value > 0 then
        require("app.cfg.battlefield_info")
        local battlefield = battlefield_info.get(G_Me.crusadeData:getCurStage())
        --奖励
        local good = G_Goods.convert(battlefield.award_type, battlefield.award_value)
        if good then
          self:getPanelByName("Panel_container"):setPositionX(-30)   
          self:getLabelByName("Label_title"):setText(good.name..G_lang:get("LANG_CRUSADE_AWARD_COLON"))
          --self:getLabelByName("Label_title"):setColor(Colors.qualityColors[good.quality])
          self:getImageViewByName("ImageView_icon"):setVisible(true)
          self:getImageViewByName("ImageView_icon"):loadTexture(good.icon_mini,good.texture_type) 
        end
      else
        self:getLabelByName("Label_title"):setVisible(false)
        self:getLabelByName("Label_value"):setVisible(false)
        self:getImageViewByName("ImageView_icon"):setVisible(false)
      end

    elseif key == "wush_boss_baowujinglianshi" then -- 三国无双精英boss
      self:getLabelByName("Label_title"):setText(G_lang:get("LANG_WUSH_BOSS_BAOWUJINGLIANSHI"))
      self:getImageViewByName("ImageView_icon"):loadTexture("icon_mini_baowujinglianshi.png", UI_TEX_TYPE_PLIST)
      self:getImageViewByName("ImageView_icon"):setVisible(true)
    elseif key == "wush_boss_yinliang" then
      self:getLabelByName("Label_title"):setText(G_lang:get("LANG_WUSH_BOSS_YINLIANG"))
      self:getImageViewByName("ImageView_icon"):loadTexture("icon_mini_yingzi.png", UI_TEX_TYPE_PLIST)
      self:getImageViewByName("ImageView_icon"):setVisible(true)
    elseif key == "wush_boss_jipinjinglianshi" then
      self:getLabelByName("Label_title"):setText(G_lang:get("LANG_WUSH_BOSS_JIPINJINGLIANSHI"))
      self:getImageViewByName("ImageView_icon"):loadTexture("icon_mini_gaojijinlianshi.png", UI_TEX_TYPE_PLIST)
      self:getImageViewByName("ImageView_icon"):setVisible(true)
    elseif key == "wush_boss_hongsezhuangbeijinghua" then
      self:getLabelByName("Label_title"):setText(G_lang:get("LANG_WUSH_BOSS_HONGSEZHUANGBEIJINGHUA"))
      self:getImageViewByName("ImageView_icon"):loadTexture("icon_mini_hongsezhuangbeijinghua.png", UI_TEX_TYPE_PLIST)
      self:getImageViewByName("ImageView_icon"):setVisible(true)
    elseif key == "wush_boss_shizhuangjinghua" then
      self:getLabelByName("Label_title"):setText(G_lang:get("LANG_WUSH_BOSS_SHIZHUANGJINGHUA"))
      self:getImageViewByName("ImageView_icon"):loadTexture("icon_mini_shizhuangjinhua.png", UI_TEX_TYPE_PLIST)
      self:getImageViewByName("ImageView_icon"):setVisible(true)
    elseif key == "dungeon_daily_tuposhi" then -- 新版日常副本
      -- 突破石
      self:getLabelByName("Label_title"):setText(G_lang:get("LANG_DAILY_DUNGEON_TUPOSHI"))
      self:getImageViewByName("ImageView_icon"):loadTexture("icon_xilian.png", UI_TEX_TYPE_PLIST)
      self:getImageViewByName("ImageView_icon"):setVisible(true)
    elseif key == "dungeon_daily_jinlongbaobao" then
      -- 金龙宝宝
      self:getLabelByName("Label_title"):setText(G_lang:get("LANG_DAILY_DUNGEON_JINLONGBAOBAO"))
      self:getImageViewByName("ImageView_icon"):loadTexture("icon_mini_jinlong.png", UI_TEX_TYPE_PLIST)
      self:getImageViewByName("ImageView_icon"):setVisible(true)
    elseif key == "dungeon_daily_yinliang" then
      -- 银两
      self:getLabelByName("Label_title"):setText(G_lang:get("LANG_DAILY_DUNGEON_YINLIANG"))
      self:getImageViewByName("ImageView_icon"):loadTexture("icon_mini_yingzi.png", UI_TEX_TYPE_PLIST)
      self:getImageViewByName("ImageView_icon"):setVisible(true)
    elseif key == "dungeon_daily_jipinjinglianshi" then
      -- 极品精炼石
      self:getLabelByName("Label_title"):setText(G_lang:get("LANG_DAILY_DUNGEON_JIPINJINGLIANSHI"))
      self:getImageViewByName("ImageView_icon"):loadTexture("icon_mini_gaojijinlianshi.png", UI_TEX_TYPE_PLIST)
      self:getImageViewByName("ImageView_icon"):setVisible(true)
    elseif key == "dungeon_daily_huangjinjingyanbaowu" then
      -- 黄金经验宝物
      self:getLabelByName("Label_title"):setText(G_lang:get("LANG_DAILY_DUNGEON_HUANGJINJINGYANBAOWU"))
      self:getImageViewByName("ImageView_icon"):loadTexture("icon_mini_huangjinjingyanbaowu.png", UI_TEX_TYPE_PLIST)
      self:getImageViewByName("ImageView_icon"):setVisible(true)
    elseif key == "dungeon_daily_baowujinglianshi" then
      -- 宝物精炼石
      self:getLabelByName("Label_title"):setText(G_lang:get("LANG_DAILY_DUNGEON_BAOWUJINGLIANSHI"))
      self:getImageViewByName("ImageView_icon"):loadTexture("icon_mini_baowujinglianshi.png", UI_TEX_TYPE_PLIST)
      self:getImageViewByName("ImageView_icon"):setVisible(true)
    elseif key == "engaged_score" then
      -- 坑位占领积分
      self:getLabelByName("Label_title"):setText(G_lang:get("LANG_FIGHTEND_ENGAGED_SCORE"))
      self:getImageViewByName("ImageView_icon"):loadTexture("icon_mini_yingzi.png",      UI_TEX_TYPE_PLIST)
      self:getImageViewByName("ImageView_icon"):setVisible(false)
    elseif key == "hero_soul_point" then
      -- 灵玉
      self:getLabelByName("Label_title"):setText(G_lang:get("LANG_FIGHTEND_HERO_SOUL_POINT"))
      self:getImageViewByName("ImageView_icon"):loadTexture("icon_mini_lingyu.png",      UI_TEX_TYPE_PLIST)
      self:getImageViewByName("ImageView_icon"):setVisible(true)
	end



end


function ShowValueLayer:play()
	--闪动数字直到目标self._value
	self._timer = GlobalFunc.addTimer(self._flashInterval, handler(self, self._refreshValue))
    G_SoundManager:playSound(require("app.const.SoundConst").GameSound.SCROLL_NUMBER_SHORT)

	self._valueDelta = math.ceil(self._value / self._maxFlashCount)
	if self._valueDelta < 1 then
		self._valueDelta = 1
	end
end

function ShowValueLayer:_refreshValue()
	--闪动数字直到目标self._value
	self._currentValue = self._currentValue + self._valueDelta
	if self._currentValue >= self._value then
		self._currentValue = self._value		
	end


	self:getLabelByName("Label_value"):setText(tostring(self._currentValue))

	if self._currentValue >= self._value then
    self:getLabelByName("Label_value"):setText(G_GlobalFunc.ConvertNumToCharacter(self._value))
		self:_end()		
	end

end

function ShowValueLayer:_end()
	if self._timer then
		GlobalFunc.removeTimer(self._timer)
		self._timer = nil
	end

	if self._endCallback ~= nil then
		self._endCallback()
		self._endCallback = nil
	end
end
return ShowValueLayer
