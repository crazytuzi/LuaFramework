local ShopScoreLayer = class("ShopScoreLayer",UFCCSNormalLayer)
require("app.const.ShopType")
require("app.cfg.corps_market_info")
--[[
	_type 商店类型
]]

local BagConst = require("app.const.BagConst")

function ShopScoreLayer.create(_type, ...)
	return ShopScoreLayer.new("ui_layout/shop_ShopScoreLayer.json",_type, ...)
end
ShopScoreLayer.WUSH_CHENG_HONG_ZHUANG = 80     --三国无双橙红装

function ShopScoreLayer:ctor(json,_type, scenePack, ...)
	self._type =_type
	self._listData = {}
	--使用btnName为key
	self._listDataIndex = {}
	self.super.ctor(self,...)
	self._tabs = require("app.common.tools.Tabs").new(1, self, self._onCheckCallback)
	self._views = {}

	--判断数据是否被初始化 --因为有可能是第一次进入场景
	self._isDataInit = false 
	--checkbox的name
	self._buttonNames = {}
	--checkbox上label的name
	self._checkboxLabelNames = {}
	G_GlobalFunc.savePack(self, scenePack)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_SHOP_INFO, self._getShopInfo, self) 
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_SHOP_ITEM_BUY_RESULT, self._getBuyResult, self) 
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_WUSH_INFO, self._onWushInfoRsp, self)

	--军团商店信息
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_GET_CORP_SHOP_INFO, self._onCorpInfo, self)

	--军团购买结果
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_GET_CORP_SHOP_SHOPPING, self._onCorpResult, self)

	if not G_Me.shopData:checkEnterScoreShop() then 
		G_HandlersManager.shopHandler:sendShopInfo(SHOP_TYPE_SCORE)
	else
		if self._type == SCORE_TYPE.CHUANG_GUAN and G_Me.wushData:isNew() == true then
			G_HandlersManager.wushHandler:sendQueryWushInfo()
		else
			self:_initListData()
		end
	end


	--判断是否需要刷新军团特殊商店
	if self._type == SCORE_TYPE.JUN_TUAN and G_Me.legionData:hasCorp() then
		if not G_Me.shopData:checkEnterCorpShop() then
			G_HandlersManager.shopHandler:sendGetCorpSpecialShop()
		else
			self:_createJunTuanRefreshTimer()
		end
	end

	-- 某些商店要显示一些材料的数量
	if self._type == SCORE_TYPE.JING_JI_CHANG or
	   self._type == SCORE_TYPE.MO_SHEN or
	   self._type == SCORE_TYPE.CHUANG_GUAN or
	   self._type == SCORE_TYPE.CROSS_WAR or
	   self._type == SCORE_TYPE.TRIGRAMS  then
		self:_initMaterialNum()
		uf_eventManager:addEventListener(G_EVENTMSGID.EVNET_BAG_HAS_CHANGED, self._onRcvBagChanged, self)
	end

	self:_initWidget()
	self:_initEvent()
end
	
function ShopScoreLayer:_initWidget()
	self:_refreshCurrentScore()
	--设置title提示文字
	self:_setTitleTips()
	self:showWidgetByName("Panel_shengwangCheckBox",self._type == SCORE_TYPE.JING_JI_CHANG)
	self:showWidgetByName("Panel_moshenCheckBox",self._type == SCORE_TYPE.MO_SHEN)
	self:showWidgetByName("Panel_chuangguanCheckBox",self._type == SCORE_TYPE.CHUANG_GUAN)
	self:showWidgetByName("Panel_juntuanCheckBox",self._type == SCORE_TYPE.JUN_TUAN)
	self:showWidgetByName("Panel_zhuanpanCheckBox",self._type == SCORE_TYPE.ZHUAN_PAN)
	self:showWidgetByName("Panel_crosswarCheckBox",self._type == SCORE_TYPE.CROSS_WAR)
	self:showWidgetByName("Panel_tuiguangCheckBox",self._type == SCORE_TYPE.INVITOR)
	self:showWidgetByName("Panel_baguaCheckBox",self._type == SCORE_TYPE.TRIGRAMS)
	self:showWidgetByName("Panel_dailyPVPCheckBox",self._type == SCORE_TYPE.DAILY_PVP)
	self:showWidgetByName("Panel_heroSoulCheckBox",self._type == SCORE_TYPE.HERO_SOUL)


	if self._type == SCORE_TYPE.JING_JI_CHANG then
		self._buttonNames = {"CheckBox_jjc_shangpin","CheckBox_jjc_jiangli",}
		self._checkboxLabelNames = {"Label_jjc_shangpin","Label_jjc_jiangli",}
	elseif self._type == SCORE_TYPE.MO_SHEN then
		self._buttonNames = {"CheckBox_ms_shangpin"}
		self._checkboxLabelNames = {"Label__ms_shangpin",}
	elseif self._type == SCORE_TYPE.DUO_BAO then
		 
	elseif self._type == SCORE_TYPE.CHUANG_GUAN then
		self._buttonNames = {"CheckBox_cg_shangpin","CheckBox_cg_zizhuang","CheckBox_cg_chengzhuang","CheckBox_cg_jiangli",}
		self._checkboxLabelNames = {"Label_cg_shangpin","Label_cg_zizhuang","Label_cg_chengzhuang","Label_cg_jiangli",}
		local maxHis = G_Me.wushData:getStarHis()
		if maxHis >= 0 and maxHis >= ShopScoreLayer.WUSH_CHENG_HONG_ZHUANG then
		   --显示橙红装
		   self:showTextWithLabel("Label_cg_chengzhuang", G_lang:get("LANG_CHENG_HONG_ZHUANG"))
		   self:showTextWithLabel("Label_cg_chengzhuang_0", G_lang:get("LANG_CHENG_HONG_ZHUANG"))
		end
	elseif self._type == SCORE_TYPE.JUN_TUAN then
		self._buttonNames = {"CheckBox_jt_daoju","CheckBox_jt_shizhuang","CheckBox_jt_zhenpin","CheckBox_jt_jiangli",}
		self._checkboxLabelNames = {"Label_jt_daoju","Label_jt_shizhuang","Label_jt_zhenpin","Label_jt_jiangli",}
	elseif self._type == SCORE_TYPE.ZHUAN_PAN then
		self._buttonNames = {"CheckBox_zp_shangpin","CheckBox_zp_jiangli",}
		self._checkboxLabelNames = {"Label_zp_shangpin","Label_zp_jiangli",}
	elseif self._type == SCORE_TYPE.TRIGRAMS then
		self._buttonNames = {"CheckBox_bg_shangpin"} --,"CheckBox_bg_jiangli",}
		self._checkboxLabelNames = {"Label_bg_shangpin"}--,"Label_bg_jiangli",}
	elseif self._type == SCORE_TYPE.CROSS_WAR then
		self._buttonNames = {"CheckBox_cw_daoju"}
		self._checkboxLabelNames = {"Label_cw_daoju"}
	elseif self._type == SCORE_TYPE.INVITOR then
		self._buttonNames = {"CheckBox_tg_shangpin"}
		self._checkboxLabelNames = {"Label__tg_shangpin",}
	elseif self._type == SCORE_TYPE.DAILY_PVP then
		self._buttonNames = {"CheckBox_dpvp_daoju", "CheckBox_dpvp_jiangli"}
		self._checkboxLabelNames = {"Label_dpvp_daoju", "Label_dpvp_jiangli"}
	elseif self._type == SCORE_TYPE.HERO_SOUL then
		self._buttonNames = {"CheckBox_herosoul_zi", "CheckBox_herosoul_cheng", "CheckBox_herosoul_hong"}
		self._checkboxLabelNames = {"Label_herosoul_zi", "Label_herosoul_cheng", "Label_herosoul_hong"}
	else
		assert("传入type:%s类型不对",self._type)
	end
end

function ShopScoreLayer:_initListView( ... )
	local index = 0
	--[[
		--军团商店从第二个开始
		-- 第一个走另外个商城
	]]
	if self._type == SCORE_TYPE.JUN_TUAN then
		local btnName = self._buttonNames[3]
		self._tabs:add(self._buttonNames[3], self._views[btnName],self._checkboxLabelNames[3])
	end
	for i,v in pairs(self._listData) do
		index = index + 1
		local panelName = "Panel_listview0" .. index

		if self._type == SCORE_TYPE.JUN_TUAN and index == 3 then
			index = index + 1
		end
		self:_createTab(panelName,self._buttonNames[index],self._checkboxLabelNames[index],v)
	end
	self._tabs:checked(self._buttonNames[1])
end

--创建tab
function ShopScoreLayer:_createTab(panelName, btnName,labelName,listData)
	if self._views[btnName] == nil then
		self._tabs:add(btnName, self._views[btnName],labelName)
	    self._listDataIndex[btnName] = listData
	end

end

-- @param showMaterialPanel: 是否显示材料数量
function ShopScoreLayer:_setListView(panelName, btnName, showMaterial)
	self:showWidgetByName("Panel_materials", showMaterial)

	if self._views[btnName] == nil then
		local panel = self:getPanelByName(panelName)

		-- 如果要在顶上显示材料数量，则需要把listview区域缩短一些
		if showMaterial then
			local panel = self:getPanelByName(panelName)
			local oldSize = panel:getSize()
			panel:setSize(CCSize(oldSize.width, oldSize.height - 45))
		end

		self._views[btnName] = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_VERTICAL)
		self._tabs:updateTab(btnName,self._views[btnName])
	    self._views[btnName]:setCreateCellHandler(function ( list, index)
	    	local item = nil
	    	if self._type == SCORE_TYPE.JUN_TUAN and btnName == "CheckBox_jt_zhenpin" then
	    		item = require("app.scenes.shop.score.ShopScoreJunTuanItem").new(self._type)  
	    	else
				item = require("app.scenes.shop.score.ShopScoreItem").new(self._type)       
	    	end
	        return item
	    end)
	    self._views[btnName]:setUpdateCellHandler(function(list,index,cell)  
			local item = nil
			--[[
				军团珍品单独处理
			]]
			if self._type == SCORE_TYPE.JUN_TUAN and btnName == "CheckBox_jt_zhenpin" then
				item = G_Me.shopData:getCorpData()[index+1]
				cell:updateJunTuanItem(item)
			else
				item = self._listDataIndex[btnName][index+1]
				cell:updateCell(item)
				cell:setExchangeFunc(function() 
					local scoreEnable,tips = self:_checkScore(item)
					if not scoreEnable then
						if tips then
							G_MovingTip:showMovingTip(tips)
						end
						return
					end

					local extraEnable,extraTips = self:_checkExtraType(item)
					if not extraEnable then
						if extraTips then
							G_MovingTip:showMovingTip(extraTips)
						end
						return
					end

					--如果是转盘商店，判断商店是否已经关闭了
					if self._type == SCORE_TYPE.ZHUAN_PAN and G_Me.wheelData:getState() == 3 then
						G_MovingTip:showMovingTip(G_lang:get("LANG_WHEEL_SHOP_IS_CLOSED"))
						return
					end

					--判断道具数量是否足
					--item.extra_type2 item.extra_type3的情况在_checkExtraType已经检查过
					if item.extra_type > 0 then
						local ownNum = G_Me.bagData:getNumByTypeAndValue(item.extra_type,item.extra_value)

						if ownNum < item.extra_size then
							local good = G_Goods.convert(item.extra_type,item.extra_value,item.extra_size)
							--需要消耗的道具数量不足
							if good then
								if item.extra_type == G_Goods.TYPE_GOLD then
									require("app.scenes.shop.GoldNotEnoughDialog").show()
								else
									G_MovingTip:showMovingTip(G_lang:get("LANG_NO_ENOUGH_AMOUNT",{item_name=good.name}))
								end
							end
							return
						end
					end
					
					--检查购买次数
					if G_Me.shopData:checkScoreMaxPurchaseNumber(item.id) then
						G_MovingTip:showMovingTip(G_lang:get("LANG_PURCHASE_REACHED_MAXINUM"))
						return
					end

					local layer = nil

					--奇葩
					if self._type == SCORE_TYPE.TRIGRAMS then
						if G_Me.trigramsData:isClose() then
				            G_MovingTip:showMovingTip(G_lang:get("LANG_BAG_ITEM_IS_OVER"))
				            return
				        end
						layer = require("app.scenes.common.PurchaseScoreDialogMore").create(item.id)
					else
						layer = require("app.scenes.common.PurchaseScoreDialog").create(item.id)
					end

		            uf_sceneManager:getCurScene():addChild(layer)
				end)
			end
	    end)

    	self:registerListViewEvent(panelName, function ( ... )
    		-- this function is used for new user guide, you shouldn't care it
    	end)
	    self._views[btnName]:setSpaceBorder(0,60)

	    if self._listDataIndex[btnName] then
	    	self._views[btnName]:reloadWithLength(#self._listDataIndex[btnName],0,0.2)
	    end
	end 
end

function ShopScoreLayer:_refreshCurrentScore()
	local scoreLabel = self:getLabelByName("Label_currentScore")
	local scoreTagLabel = self:getLabelByName("Label_currentScoreTag")
	local scoreIcon = self:getImageViewByName("ImageView_scoreIcon")
	local score = 0
	if self._type == SCORE_TYPE.JING_JI_CHANG then
		score = G_Me.userData.prestige
		scoreIcon:loadTexture("icon_mini_shenwang.png",UI_TEX_TYPE_PLIST)
		scoreTagLabel:setText(G_lang:get("LANG_OWN_SHENGWANG"))
	elseif self._type == SCORE_TYPE.MO_SHEN then
		score = G_Me.userData.medal
		scoreIcon:loadTexture("icon_mini_jiangzhang.png",UI_TEX_TYPE_PLIST)
		scoreTagLabel:setText(G_lang:get("LANG_OWN_ZHANGONG"))
	elseif self._type == SCORE_TYPE.DUO_BAO then
		-- score = G_Me.userData.prestige
	elseif self._type == SCORE_TYPE.CHUANG_GUAN then
		score = G_Me.userData.tower_score
		scoreIcon:loadTexture("icon_mini_patajifen.png",UI_TEX_TYPE_PLIST)
		scoreTagLabel:setText(G_lang:get("LANG_OWN_WEIMING"))
	elseif self._type == SCORE_TYPE.JUN_TUAN then
		score = G_Me.userData.corp_point
		scoreIcon:loadTexture("icon_mini_juntuangongxian.png",UI_TEX_TYPE_PLIST)
		scoreTagLabel:setText(G_lang:get("LANG_OWN_GONGXIAN"))
	elseif self._type == SCORE_TYPE.ZHUAN_PAN then
		score = G_Me.wheelData.score
		scoreIcon:loadTexture("icon_mini_youxijifen.png",UI_TEX_TYPE_PLIST)
		scoreTagLabel:setText(G_lang:get("LANG_OWN_ZHUANPAN"))
	elseif self._type == SCORE_TYPE.CROSS_WAR then
		score = G_Me.userData.contest_point
		scoreIcon:loadTexture("icon_yanwuxunzhang.png",UI_TEX_TYPE_PLIST)
		scoreTagLabel:setText(G_lang:get("LANG_GOODS_CROSSWAR_MEDAL") .. "：")
	elseif self._type == SCORE_TYPE.INVITOR then
		score = G_Me.userData.invitor_score
		scoreIcon:loadTexture("icon_mini_tuiguangjifen.png",UI_TEX_TYPE_PLIST)
		scoreTagLabel:setText(G_lang:get("LANG_OWN_INVITOR"))
	elseif self._type == SCORE_TYPE.TRIGRAMS then
		--暂不处理
		score = 0
	elseif self._type == SCORE_TYPE.DAILY_PVP then
		score = G_Me.userData.dailyPVPScore
		scoreIcon:loadTexture("icon_mini_jizhanjifen.png", UI_TEX_TYPE_PLIST)
		scoreTagLabel:setText(G_lang:get("LANG_OWN_INVITOR"))
	elseif self._type == SCORE_TYPE.HERO_SOUL then
		score = G_Me.userData.qiyu_point
		scoreIcon:loadTexture("icon_qiyudian.png", UI_TEX_TYPE_PLIST)
		scoreTagLabel:setText(G_lang:get("LANG_OWN_QIYU_POINT"))
	else
		assert("传入type:%s类型不对",self._type)
	end
	scoreLabel:setText(score)
end

function ShopScoreLayer:_initListData()
	--数据被初始化过
	self._isDataInit = true
	self._listData = {}
	self._listData = G_Me.shopData:getScoreDataByType(self._type) or {}
end

--检查其他的消耗类型
function ShopScoreLayer:_checkExtraType(item)

	--暂时只针对挂盘商店
	if item.price_type <= 0 then	
		for i=2, 3 do
	    	if item["extra_type"..i] > 0 then
		        local _extraGood = G_Goods.convert(item["extra_type"..i],item["extra_value"..i],item["extra_size"..i])
		        if _extraGood then
		            local ownNum = G_Me.bagData:getNumByTypeAndValue(_extraGood.type, _extraGood.value)
		            if ownNum < _extraGood.size then
		            	return false, G_lang:get("LANG_NO_ENOUGH_AMOUNT",{item_name=_extraGood.name})
		            end
		        else
		        	return false
		        end
		    end
    	end
	end

	return true

end

--检查积分
function ShopScoreLayer:_checkScore(item)
	-- 如果超过了购买时间，则不能买
	if item.sell_open_time > 0 and item.sell_close_time > 0 then
		local curTime = G_ServerTime:getTime()
		if curTime < item.sell_open_time or curTime > item.sell_close_time then
            return false, G_lang:get("LANG_SHOP_PURCHASE_TIME_PASS")
        end
	end

	if item.price_type <= 0 then
		local extra_good = G_Goods.convert(item.extra_type,item.extra_value,item.extra_size)
		if not extra_good then
			return false
		end
		local ownNum = G_Me.bagData:getNumByTypeAndValue(extra_good.type,extra_good.value)
		return ownNum >= extra_good.size,G_lang:get("LANG_NO_ENOUGH_AMOUNT",{item_name=extra_good.name})
	end
	

	--转换成goods type
	local priceGoodType = G_Path.getPriceType(item.price_type)
	if not priceGoodType then
		return false
	end

	local isDiscount,discount = G_Me.activityData.custom:isItemDiscountById(item.id)   --折扣信息
	local price = item.price
	if isDiscount then
	    price = math.ceil(price * discount / 1000)
	end

	local priceGood = G_Goods.convert(priceGoodType,nil,price)   --priceType  一般都是积分形式，无value
	if not priceGood then
		return false
	end
	return G_Goods.checkOwnGood(priceGood),G_lang:get("LANG_NO_ENOUGH_AMOUNT",{item_name=priceGood.name})
end


--积分不足时的提示
function ShopScoreLayer:_getTips()
    if self._type == SCORE_TYPE.JING_JI_CHANG then  --竞技场
    	return G_lang:get("LANG_SHENG_WANG_NOT_ENOUGH")
    elseif self._type == SCORE_TYPE.MO_SHEN then --
    	return G_lang:get("LANG_JIANG_ZHANG_NOT_ENOUGH")
    elseif self._type == SCORE_TYPE.DUO_BAO then
    elseif self._type == SCORE_TYPE.CHUANG_GUAN then
    	return G_lang:get("LANG_ZHAN_GONG_JIFEN_NOT_ENOUGH")
    elseif self._type == SCORE_TYPE.JUN_TUAN then
    	return G_lang:get("LANG_JUN_TUAN_GONGXIAN_NOT_ENOUGH")
    elseif self._type == SCORE_TYPE.ZHUAN_PAN then
    	return G_lang:get("LANG_ZHUAN_PAN_JIFEN_NOT_ENOUGH")
    elseif self._type == SCORE_TYPE.CROSS_WAR then
    	return G_lang:get("LANG_CROSS_WAR_MEDAL_NOT_ENOUGH")
    elseif self._type == SCORE_TYPE.INVITOR then
    	return G_lang:get("LANG_INVITOR_SCORE_NOT_ENOUGH")
    elseif self._type == SCORE_TYPE.TRIGRAMS then
    	return G_lang:get("LANG_TRIGRAMS_NOT_ENOUGH")
    elseif self._type == SCORE_TYPE.DAILY_PVP then
    	return G_lang:get("LANG_DAILY_PVP_NOT_ENOUGH")
    elseif self._type == SCORE_TYPE.HERO_SOUL then
    	return G_lang:get("LANG_QIYU_POINT_NOT_ENOUGH")
    end

    return ""
end

function ShopScoreLayer:_initEvent()
	--返回
	self:registerBtnClickEvent("Button_back",function() 
		--pop scene

     local packScene = G_GlobalFunc.createPackScene(self)
     if packScene then 
     --	uf_sceneManager:replaceScene(packScene)
     	uf_sceneManager:popToRootAndReplaceScene(packScene)
     elseif self._type == SCORE_TYPE.TRIGRAMS then
     	GlobalFunc.popSceneWithDefault("app.scenes.mainscene.MainScene")
     else
     	GlobalFunc.popSceneWithDefault("app.scenes.mainscene.PlayingScene")
     end
	 
	end)
	self:registerWidgetClickEvent("ImageView_mm" , function(widget, _type)
	    self:_showMMDialog(2)
	end)

	GlobalFunc.replaceForAppVersion(self:getImageViewByName("ImageView_mm"))
	-- local appstoreVersion = (G_Setting:get("appstore_version") == "1")
	-- if appstoreVersion or IS_HEXIE_VERSION  then 
	-- 	local img = self:getImageViewByName("ImageView_mm")
	-- 	if img then
	-- 		img:loadTexture("ui/arena/xiaozhushou_hexie.png")
	-- 	end
	-- end
end

--[[
	适配
]]
function ShopScoreLayer:adapterLayer()
	self:adapterWidgetHeight("Panel_listviewBg", "", "", 0, 0)
	self:adapterWidgetHeight("Panel_listview01", "", "", 10, 0)
	self:adapterWidgetHeight("Panel_listview02", "", "", 10, 0)
	self:adapterWidgetHeight("Panel_listview03", "", "", 10, 0)
	self:adapterWidgetHeight("Panel_listview04", "", "", 10, 0)
	self:adapterWidgetHeight("Panel_listviewjuntuan", "Panel_juntuanrefreshTime", "", 50, 0)

	-- self:_createTab()
	if self._isDataInit == true then
		self:_initListView()
		self:showAwardTips()
	end
end

--[[
	trigger:触发条件
]]
function ShopScoreLayer:_showMMDialog(trigger)
	if self._wordsListData == nil then
		require("app.cfg.shop_dialogue_info")
		--购买成功弹出的对话
		self._wordsListData = {}
		--点击MM弹出对话
		self._clickWordsListData = {}
		for i=1,shop_dialogue_info:getLength() do
			local dialogue = shop_dialogue_info.indexOf(i)
			if dialogue.type == SCORE_TYPE.JING_JI_CHANG then
				if dialogue.trigger == 1 then
					table.insert(self._wordsListData,dialogue)
				else
					table.insert(self._clickWordsListData,dialogue)
				end 
			elseif dialogue.type == SCORE_TYPE.CHUANG_GUAN then
				if dialogue.trigger == 1 then
					table.insert(self._wordsListData,dialogue)
				else
					table.insert(self._clickWordsListData,dialogue)
				end
			end
		end
	end
	if self._wordsListData == nil or #self._wordsListData == 0 then 
		return
	end
	local _index = math.random(trigger == 1 and #self._wordsListData or #self._clickWordsListData) 
	local str = trigger == 1 and self._wordsListData[_index] or self._clickWordsListData[_index]
	local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
	self:getLabelByName("Label_tips"):setText(str["content"])
	if self._sayEffect ~= nil then
		self._sayEffect:resetPosition()
		self._sayEffect:stop()
		self._sayEffect = nil
	end
	self:getImageViewByName("Image_qipao"):setScale(1)
	self._sayEffect = EffectSingleMoving.run(self:getImageViewByName("Image_qipao"), "smoving_scalein", function(event)
		uf_funcCallHelper:callAfterFrameCount(20, function ( ... ) 
			if G_SceneObserver:getSceneName() == "ShopScoreScene" then
				if self and self.getImageViewByName then
					local image = self:getImageViewByName("Image_qipao")
					if image then
						image:setVisible(true)
					end
				end
				if self and self._setTitleTips then
					self:_setTitleTips()
				end
			end
			end)
		end)
end

function ShopScoreLayer:_setTitleTips()

	self:getLabelByName("Label_tips"):setVisible(true)
	self:getPanelByName("Panel_scoreRoot"):setVisible(true)
	self:getLabelByName("Label_tips_middle"):setVisible(false)

	if self._type == SCORE_TYPE.JING_JI_CHANG then
		self:getLabelByName("Label_tips"):setText(G_lang:get("LANG_JING_JI_CHANG_TITLE_TIPS"))
	elseif self._type == SCORE_TYPE.MO_SHEN then
		self:getLabelByName("Label_tips"):setText(G_lang:get("LANG_JING_MOSHEN_TIPS"))
	elseif self._type == SCORE_TYPE.DUO_BAO then
		 
	elseif self._type == SCORE_TYPE.CHUANG_GUAN then
		self:getLabelByName("Label_tips"):setText(G_lang:get("LANG_JING_CHUANG_GUAN_TIPS"))
	elseif self._type == SCORE_TYPE.JUN_TUAN then
		self:getLabelByName("Label_tips"):setText(G_lang:get("LANG_JING_JUN_TUAN_TIPS"))
	elseif self._type == SCORE_TYPE.ZHUAN_PAN then
		self:getLabelByName("Label_tips"):setText(G_lang:get("LANG_JING_ZHUAN_PAN_TIPS"))
	elseif self._type == SCORE_TYPE.CROSS_WAR then
		self:getLabelByName("Label_tips"):setText(G_lang:get("LANG_JING_CROSS_WAR_TIPS"))
	elseif self._type == SCORE_TYPE.INVITOR then
		self:getLabelByName("Label_tips"):setText(G_lang:get("LANG_JING_INVITOR_TIPS"))
	elseif self._type == SCORE_TYPE.TRIGRAMS then
		self:getLabelByName("Label_tips"):setVisible(false)
		self:getPanelByName("Panel_scoreRoot"):setVisible(false)
		self:getLabelByName("Label_tips_middle"):setVisible(true)
		self:getLabelByName("Label_tips_middle"):setText(G_lang:get("LANG_JING_TRIGRAMS_TIPS"))
		self:getLabelByName("Label_Material_bagua"):setText(G_lang:get("LANG_TRIGRAMS_ITEMNAME"))
	elseif self._type == SCORE_TYPE.DAILY_PVP then
		self:getLabelByName("Label_tips"):setText(G_lang:get("LANG_JING_DAILY_PVP_TIPS"))
	elseif self._type == SCORE_TYPE.HERO_SOUL then
		self:getLabelByName("Label_tips"):setText(G_lang:get("LANG_JING_HERO_SOUL_TIPS"))
	else
		assert("传入type:%s类型不对",self._type)
	end
end


--显示奖励 的tips
function ShopScoreLayer:showAwardTips()
	if self._type == SCORE_TYPE.JING_JI_CHANG then
		self:showWidgetByName("Image_jjc_tips",G_Me.shopData:checkAwardTipsByType(self._type))
	elseif self._type == SCORE_TYPE.MO_SHEN then
	elseif self._type == SCORE_TYPE.DUO_BAO then
		 
	elseif self._type == SCORE_TYPE.CHUANG_GUAN then
		self:showWidgetByName("Image_cg_tips",G_Me.shopData:checkAwardTipsByType(self._type))
	elseif self._type == SCORE_TYPE.JUN_TUAN then
		self:showWidgetByName("Image_jt_tips",G_Me.shopData:checkAwardTipsByType(self._type))
		self:showWidgetByName("Image_jt_zhenpin_tips",G_Me.shopData:getJunTuanHasNewData())
	elseif self._type == SCORE_TYPE.ZHUAN_PAN then
		self:showWidgetByName("Image_zp_tips",G_Me.shopData:checkAwardTipsByType(self._type))
	elseif self._type == SCORE_TYPE.TRIGRAMS then
		--self:showWidgetByName("Image_bg_tips",G_Me.shopData:checkAwardTipsByType(self._type))
	elseif self._type == SCORE_TYPE.INVITOR then
	elseif self._type == SCORE_TYPE.DAILY_PVP then
		self:showWidgetByName("Image_dpvp_tips",G_Me.shopData:checkAwardTipsByType(self._type))
	else
	end
	
end

function ShopScoreLayer:_onCheckCallback(name)
    if self._type == SCORE_TYPE.JING_JI_CHANG then
    	if name == "CheckBox_jjc_shangpin" then
    		--商品
			self:_setListView("Panel_listview01",name, G_Me.userData.level >= 50)
    	elseif name == "CheckBox_jjc_jiangli" then
    		-- 奖励
    		self:_setListView("Panel_listview02",name, G_Me.userData.level >= 50)
    	end
    elseif self._type == SCORE_TYPE.MO_SHEN then
    	self:_setListView("Panel_listview01",name, G_Me.userData.level >= 60)
    elseif self._type == SCORE_TYPE.DUO_BAO then
    elseif self._type == SCORE_TYPE.CHUANG_GUAN then
    	local redArmUnlocked = G_Me.wushData:getStarHis() >= ShopScoreLayer.WUSH_CHENG_HONG_ZHUANG
    	if name == "CheckBox_cg_shangpin" then
    		self:_setListView("Panel_listview01",name, redArmUnlocked)
    	elseif name == "CheckBox_cg_zizhuang" then
    		self:_setListView("Panel_listview02",name, redArmUnlocked)
    	elseif name == "CheckBox_cg_chengzhuang" then
    		self:_setListView("Panel_listview03",name, redArmUnlocked)
    	else
    		self:_setListView("Panel_listview04",name, redArmUnlocked)
    	end
    elseif self._type == SCORE_TYPE.JUN_TUAN then
    	--显示倒计时
    	self:showWidgetByName("Panel_juntuanrefreshTime",name == "CheckBox_jt_zhenpin")
    	if name == "CheckBox_jt_zhenpin" then
    		if self._views[name] == nil then
    			self:_setListView("Panel_listviewjuntuan",name)
    			self._views[name]:reloadWithLength(#G_Me.shopData:getCorpData(),0,0.2)
    		end
    		G_Me.shopData:clickJunTuan()
    	elseif name == "CheckBox_jt_daoju" then
    		self:_setListView("Panel_listview01",name)
    	elseif name == "CheckBox_jt_shizhuang" then
    		self:_setListView("Panel_listview02",name)
    	elseif name == "CheckBox_jt_jiangli" then
    		self:_setListView("Panel_listview04",name)
    	end
    elseif self._type == SCORE_TYPE.ZHUAN_PAN then
    	if name == "CheckBox_zp_shangpin" then
    		--商品
			self:_setListView("Panel_listview01",name)
    	elseif name == "CheckBox_zp_jiangli" then
    		-- 奖励
    		self:_setListView("Panel_listview02",name)
    	end
    elseif self._type == SCORE_TYPE.TRIGRAMS then
    	--if name == "CheckBox_bagua_shangpin" then
    		--商品
			self:_setListView("Panel_listview01",name, true)
    	--elseif name == "CheckBox_bagua_jiangli" then
    		-- 奖励
    	--	self:_setListView("Panel_listview02",name)
    	--end
    elseif self._type == SCORE_TYPE.CROSS_WAR then
    	self:_setListView("Panel_listview01",name, true)
  	elseif self._type == SCORE_TYPE.INVITOR then
  		self:_setListView("Panel_listview01",name)
  	elseif self._type == SCORE_TYPE.DAILY_PVP then
  		if name == "CheckBox_dpvp_daoju" then
  			self:_setListView("Panel_listview01", name)
  		elseif name == "CheckBox_dpvp_jiangli" then
  			self:_setListView("Panel_listview02", name)
  		end
  	elseif self._type == SCORE_TYPE.HERO_SOUL then
  		if name == "CheckBox_herosoul_zi" then
  			self:_setListView("Panel_listview01", name)
  		elseif name == "CheckBox_herosoul_cheng" then
			self:_setListView("Panel_listview02", name)
  		elseif name == "CheckBox_herosoul_hong" then
  			self:_setListView("Panel_listview03", name)
  		end
    else
    	assert("传入type:%s类型不对",self._type)
    end

    self:showAwardTips()
end


--START----接收网络请求

--[[
	军团特殊商店在第一个页签
]]
function ShopScoreLayer:_onCorpInfo(data)
	if data.ret == 1 then
		if self._views["CheckBox_jt_zhenpin"] then
			self._views["CheckBox_jt_zhenpin"]:reloadWithLength(#G_Me.shopData:getCorpData(),0,0.2)
		end
		self:_createJunTuanRefreshTimer()
	end
end

--军团刷新倒计时
function ShopScoreLayer:_createJunTuanRefreshTimer()
	if self._timer then
		GlobalFunc.removeTimer(self._timer )
		self._timer =nil
	end
	if self._timer == nil then
		self._timer = GlobalFunc.addTimer(1, function() 
			local nextTime = G_Me.shopData:getJunTuanRefreshTime()
			if nextTime == 0  then
				return
			end
			local leftTime = G_ServerTime:getLeftSeconds(nextTime)
			if leftTime <= 0 then 
				--重新发请求刷新数据,并移除计时器
				G_HandlersManager.shopHandler:sendGetCorpSpecialShop()
				if self._timer then
				    GlobalFunc.removeTimer(self._timer )
				    self._timer =nil
				end
			else
				local timeString = G_ServerTime:getLeftSecondsString(nextTime)
				self:getLabelByName("Label_refreshTime"):setText(timeString)
			end
		end)
	end
end

-- 某些商店里需要显示一些材料的数量
function ShopScoreLayer:_initMaterialNum()
	self._materialID = {0, 0}
	self._materialNum = {0, 0}
	local level = G_Me.userData.level

	if self._type == SCORE_TYPE.JING_JI_CHANG then
		self._materialID[1] = level >= 50 and 6 or 0    -- 突破石
		self._materialID[2] = level >= 60 and 3 or 0	-- 红将精华
	elseif self._type == SCORE_TYPE.CHUANG_GUAN then
		self._materialID[1] = 81						-- 红装精华
	elseif self._type == SCORE_TYPE.MO_SHEN then
		self._materialID[1] = level >= 60 and 3 or 0
	elseif self._type == SCORE_TYPE.CROSS_WAR then
		self._materialID[1] = 3
		self._materialID[2] = 81
	elseif self._type == SCORE_TYPE.TRIGRAMS then
		self._materialID[1] = BagConst.TRIGRAMS_TYPE.TIAN_TRIGRAM
		self._materialID[2] = BagConst.TRIGRAMS_TYPE.DI_TRIGRAM
		self._materialID[3] = BagConst.TRIGRAMS_TYPE.REN_TRIGRAM
	end

	-- 用于信息对齐的函数
	local alignToLeft = function(panel)
		local children = {}
		if device.platform == "wp8" or device.platform == "winrt" then
        	children = panel:getChildrenWidget() or {}
    	else
        	children = panel:getChildren() or {}
    	end
    	if not children then 
        	return 0
    	end
    	local count = children:count()

		local totalWidth = 0
		for i = 0, count - 1 do
			local obj = children:objectAtIndex(i)
			obj:setPositionX(totalWidth)
			totalWidth = totalWidth + obj:getContentSize().width
		end

		return totalWidth
	end

	-- 设置材料名字、图标和数量
	if self._type == SCORE_TYPE.TRIGRAMS then
		self:showWidgetByName("Panel_Material_1",  false)
		self:showWidgetByName("Panel_Material_2",  false)
		self:showWidgetByName("Panel_Material_bagua",  true)
	else
		self:showWidgetByName("Panel_Material_bagua",  false)
	end

	local panelWidth = 0
	for i, v in ipairs(self._materialID) do

		if self._type == SCORE_TYPE.TRIGRAMS then
			if v > 0 then
				local goodsInfo = G_Goods.convert(3, v)
				local num = G_Me.bagData:getNumByTypeAndValue(3, v)
				--self:showTextWithLabel("Label_MaterialNum_bagua_" .. i, goodsInfo.name .. "：")
				self:getImageViewByName("Image_Material_bagua_" .. i):loadTexture(goodsInfo.icon_mini)
				self:showTextWithLabel("Label_MaterialNum_bagua_" .. i , tostring(num))
				self._materialNum[i] = num
			end
		else
			self:showWidgetByName("Panel_Material_" .. i, v > 0)
			if v > 0 then
				local goodsInfo = G_Goods.convert(3, v)
				local num = G_Me.bagData:getNumByTypeAndValue(3, v)
				self:showTextWithLabel("Label_Material_" .. i, goodsInfo.name .. "：")
				self:getImageViewByName("Image_Material_" .. i):loadTexture(goodsInfo.icon_mini)
				self:showTextWithLabel("Label_MaterialNum_" .. i , tostring(num))
				self._materialNum[i] = num

				-- 对齐
				panelWidth = alignToLeft(self:getPanelByName("Panel_Material_" .. i))
			end
		end
	end
end

-- 收到背包里物品信息变化的消息
function ShopScoreLayer:_onRcvBagChanged()
	-- 更新材料的数量
	for i, v in ipairs(self._materialID) do
		if v > 0 then
			local newNum = G_Me.bagData:getNumByTypeAndValue(3, v)
			if newNum ~= self._materialNum[i] then
				if self._type == SCORE_TYPE.TRIGRAMS then
					self:_playChangeNum(self:getLabelByName("Label_MaterialNum_bagua_" .. i), self._materialNum[i], newNum)
				else
					self:_playChangeNum(self:getLabelByName("Label_MaterialNum_" .. i), self._materialNum[i], newNum)
				end
				self._materialNum[i] = newNum
			end
		end
	end
end

-- 播放数字增长跳动的效果
function ShopScoreLayer:_playChangeNum(label, oldNum, newNum)
	local scale = CCSequence:createWithTwoActions(CCScaleTo:create(0.25, 2), CCScaleTo:create(0.25, 1))
	local growUp = CCNumberGrowupAction:create(oldNum, newNum, 0.5, function(number) 
		label:setText(tostring(number))
	end)
	local act = CCSpawn:createWithTwoActions(scale, growUp)
	label:runAction(act)
end

function ShopScoreLayer:_onCorpResult(data)
	self:_getBuyResult(data)
end

function ShopScoreLayer:_getShopInfo(data)
	--再判断如果是闯关商店，判断是否进入过闯关
	if self._type == SCORE_TYPE.CHUANG_GUAN and G_Me.wushData:isNew() == true then
		G_HandlersManager.wushHandler:sendQueryWushInfo()
		return
	end
	self:_initListData()
	self:_initListView()
	self:showAwardTips()
end

function ShopScoreLayer:_onWushInfoRsp(data)
	self:_initWidget()
	self:_initListData()
	self:_initListView()
	self:showAwardTips()
end

function ShopScoreLayer:_getBuyResult(data)
	if data.ret == 1 then 
	    G_MovingTip:showMovingTip(G_lang:get("LANG_BUY_SUCCESS"))
		for i,v in pairs(self._views)do
			if v then
				v:refreshAllCell()
			end
		end
        self:_refreshCurrentScore()
        self:_showMMDialog(1)

        --判断是否还需要提示
        self:showAwardTips()
    elseif data.ret == G_NetMsgError.RET_CORP_SHOP_NO_LEFT then
    	G_HandlersManager.shopHandler:sendGetCorpSpecialShop()
	end
end 

--END----接收网络请求

function ShopScoreLayer:onLayerEnter( ... )
	self:getLabelByName("Label_refreshTime"):setText("")
	-- GlobalFunc.flyIntoScreenLR({self:getWidgetByName("Panel_scoreRoot")}, false, 0.2, 2, 100, function (  )
	-- end)
	-- GlobalFunc.flyIntoScreenLR({self:getWidgetByName("Panel_root")}, true, 0.2, 2, 100, function (  )
	-- end)
end

function ShopScoreLayer:onLayerLoad(...)
    self:registerKeypadEvent(true)
end
function ShopScoreLayer:onBackKeyEvent()
    uf_sceneManager:popScene()
    return true
end
function ShopScoreLayer:onLayerUnload()
	uf_eventManager:removeListenerWithTarget(self)
end

function ShopScoreLayer:onLayerExit()
	if self._timer then
	    GlobalFunc.removeTimer(self._timer )
	    self._timer =nil
	end
end
return ShopScoreLayer