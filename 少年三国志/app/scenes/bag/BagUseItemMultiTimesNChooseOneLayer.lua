-- 道具批量使用之N选一道具


local BagUseItemMultiTimesNChooseOneLayer = class("BagUseItemMultiTimesNChooseOneLayer", UFCCSModelLayer)

local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
local MAX_RESULT_NUM = 500


-- TODO:可能需要考虑可配置活动的道具箱子
-- @param itemId 			所使用道具的id
-- @param data 				道具对应的 item_box_info
-- @param maxLimit 			对应的背包上限值
-- @param currNum  			当前拥有多少这种道具对应的物品
-- @param canGetGoodsNum 	开完拥有的所有这种箱子可以得到多少对应的物品
function BagUseItemMultiTimesNChooseOneLayer.show( itemId, data, maxLimit, currNum, canGetGoodsNum, ... )

	if not data then
		return
	end
	local items = {}
	for i=1,4 do
		local _type = data["choice_type_"..i]
		if _type > 0 then
			items["type_"..i] = data["choice_type_"..i]
			items["value_"..i] = data["choice_value_"..i]
			items["size_"..i] = data["choice_size_"..i]
		end
	end

	local layer = BagUseItemMultiTimesNChooseOneLayer.new("ui_layout/bag_NChooseOneMultiUse.json",
				 Colors.modelColor, itemId, items, maxLimit, currNum, canGetGoodsNum, ...)
	uf_sceneManager:getCurScene():addChild(layer)
end


function BagUseItemMultiTimesNChooseOneLayer:ctor(json, color, itemId, dataOrId, maxLimit, currNum, canGetGoodsNum, ... )
	-- 当前道具的ID
	self._itemId = itemId
	-- 选择了哪种开出来的东西
	self._selectIndex = 0
	-- 当前选择了要打开多少个箱子
	self._resultCount = 0
	-- 对应的背包上限值（调用时传入）
	self._maxLimit = maxLimit
	-- 当前拥有多少这种道具对应的物品（调用时传入）
	self._currNum = currNum
	-- 开完拥有的所有这种箱子可以得到多少东西（调用时传入）
	self._canGetGoodsNum = canGetGoodsNum
	-- 显示当前选择了多少个箱子的Label
	self._countLabel = self:getLabelByName("Label_Use_Count")

	if type(dataOrId) == "number" then
		self._data = main_growth_info.get(dataOrId)
	elseif type(dataOrId) == "table" then
		self._data = dataOrId
	end

	self:_initEvent()
	self:_initWidgets()

	if self._data then
		self:_setWidgets()
	end

	self:_checkUseNumDiff(1)

	self.super.ctor(self, json)
end


function BagUseItemMultiTimesNChooseOneLayer:onLayerLoad( ... )
	-- body
end


function BagUseItemMultiTimesNChooseOneLayer:onLayerEnter( ... )
	EffectSingleMoving.run(self:getImageViewByName("Image_bg"), "smoving_bounce")
	self:showAtCenter(true)
	self:closeAtReturn(true)
end

function BagUseItemMultiTimesNChooseOneLayer:_initWidgets()
	--道具品质背景图
	self._qualityImageBgList = {
		self:getImageViewByName("Image_qualityBg01"),
		self:getImageViewByName("Image_qualityBg02"),
		self:getImageViewByName("Image_qualityBg03"),
		self:getImageViewByName("Image_qualityBg04"),
	}
	self._itemImageList = {
		self:getImageViewByName("Image_item01"),
		self:getImageViewByName("Image_item02"),
		self:getImageViewByName("Image_item03"),
		self:getImageViewByName("Image_item04"),
	}
	self._qualityButtonList = {
		self:getButtonByName("Button_quality01"),
		self:getButtonByName("Button_quality02"),
		self:getButtonByName("Button_quality03"),
		self:getButtonByName("Button_quality04"),
	}
	self._numLabelList = {
		self:getLabelByName("Label_num01"),
		self:getLabelByName("Label_num02"),
		self:getLabelByName("Label_num03"),
		self:getLabelByName("Label_num04"),
	}	
	self._nameLabelList = {
		self:getLabelByName("Label_name01"),
		self:getLabelByName("Label_name02"),
		self:getLabelByName("Label_name03"),
		self:getLabelByName("Label_name04"),
	}
	self._buttonList = {
		self:getButtonByName("Button_01"),
		self:getButtonByName("Button_02"),
		self:getButtonByName("Button_03"),
		self:getButtonByName("Button_04"),
	}

	for i=1,#self._nameLabelList do
		self._nameLabelList[i]:createStroke(Colors.strokeBrown,1)
		self._numLabelList[i]:createStroke(Colors.strokeBrown,1)
	end

	self:getLabelByName("Label_Title"):createStroke(Colors.strokeBrown,1)

	self._checkBoxList = {
		self:getCheckBoxByName("CheckBox_01"),
		self:getCheckBoxByName("CheckBox_02"),
		self:getCheckBoxByName("CheckBox_03"),
		self:getCheckBoxByName("CheckBox_04"),
	}

	self._countLabel:setText("1")

	-- strokes
	self:getLabelByName("Label_Multi_Use"):createStroke(Colors.strokeBrown, 1)
	self:getLabelByName("Label_Sub_Ten"):createStroke(Colors.strokeBrown, 1)
	self:getLabelByName("Label_Sub_One"):createStroke(Colors.strokeBrown, 1)
	self:getLabelByName("Label_Add_Ten"):createStroke(Colors.strokeBrown, 1)
	self:getLabelByName("Label_Add_One"):createStroke(Colors.strokeBrown, 1)
end

function BagUseItemMultiTimesNChooseOneLayer:_initEvent()
	self:registerBtnClickEvent("Button_01", function() self:_setCheckBox(1) end)
	self:registerBtnClickEvent("Button_02", function() self:_setCheckBox(2) end)
	self:registerBtnClickEvent("Button_03", function() self:_setCheckBox(3) end)
	self:registerBtnClickEvent("Button_04", function() self:_setCheckBox(4) end)

	self:registerBtnClickEvent("Button_Add_One", function () self:_onClickChangeNum(1) end)
	self:registerBtnClickEvent("Button_Add_Ten", function () self:_onClickChangeNum(MAX_RESULT_NUM) end)
	self:registerBtnClickEvent("Button_Sub_One", function () self:_onClickChangeNum(-1) end)
	self:registerBtnClickEvent("Button_Sub_Ten", function () self:_onClickChangeNum(-10) end)

	self:registerBtnClickEvent("Button_Close",function() self:animationToClose() end)
	self:registerBtnClickEvent("Button_Confirm",function()
		if self._selectIndex == 0 then
			G_MovingTip:showMovingTip(G_lang:get("LANG__SAN_GUO_ZHI_QING_XUAN_ZE_JIANGLI"))
			return
		end

		G_HandlersManager.bagHandler:sendUseItemInfo(self._itemId, self._selectIndex, self._resultCount)
		self:animationToClose()
	end)
end

function BagUseItemMultiTimesNChooseOneLayer:_onClickChangeNum( diff )
	self:_checkUseNumDiff(diff)
end

function BagUseItemMultiTimesNChooseOneLayer:_checkUseNumDiff( num )
	-- 点击了加减号之后将要开出的次数，最少开1次
	local newGetCount = math.max(self._resultCount + num, 1)
	-- 如果开这么多次，加上已有的对应物品，最后会有多少个
	local newResultCount = newGetCount + self._currNum		

	-- 如果最终的产出物品大于玩家可拥有的上限
	if self._maxLimit > 0 and newResultCount > self._maxLimit then
		newGetCount = math.floor((self._maxLimit - self._currNum))
	end
	
	-- 再和当前拥有的数量取最小值
	newGetCount = math.min(self._canGetGoodsNum, newGetCount)

	self._resultCount = newGetCount
	self._countLabel:setText(self._resultCount)
end

function BagUseItemMultiTimesNChooseOneLayer:_setCheckBox(index)
	self._selectIndex = index
	for i,v in ipairs(self._checkBoxList)do
		v:setSelectedState(i == index)
	end
end


function BagUseItemMultiTimesNChooseOneLayer:_setWidgets()
	local len = 0 --奖励的长度
	for i=1,4 do
		local good = G_Goods.convert(self._data["type_" .. i],self._data["value_" .. i],self._data["size_" .. i])
		if good then
			len = len + 1
			self._qualityImageBgList[i]:loadTexture(G_Path.getEquipIconBack(good.quality))
			self._itemImageList[i]:loadTexture(good.icon)
			self._qualityButtonList[i]:loadTextureNormal(G_Path.getEquipColorImage(good.quality,good.type))
			self._qualityButtonList[i]:loadTexturePressed(G_Path.getEquipColorImage(good.quality,good.type))
			self:registerBtnClickEvent(self._qualityButtonList[i]:getName(),function()
				require("app.scenes.common.dropinfo.DropInfo").show(self._data["type_" .. i],self._data["value_" .. i]) 
				end)
			self._nameLabelList[i]:setColor(Colors.qualityColors[good.quality])
			self._nameLabelList[i]:setText(good.name)
			self._numLabelList[i]:setText("x" .. good.size)
		else
			self:showWidgetByName("Button_0" .. i,false)
		end
	end
	if len<4 then
		len =  len < 0 and 0 or len
		for i = (len>=1)and (len+1) or 1,4 do
			self:showWidgetByName("Button_0" .. i,false)
		end
		local width = self:getWidgetByName("Panel_Inner_Bg"):getContentSize().width
		local btnWidth = self._buttonList[1]:getContentSize().width
		local space = (width-len*btnWidth)/(len + 1)
		for i=1,len do
			self._buttonList[i]:setPositionX(space*i + btnWidth/2 +(i-1)*btnWidth)
		end
	end
end


function BagUseItemMultiTimesNChooseOneLayer:onLayerExit( ... )
	-- body
end


function BagUseItemMultiTimesNChooseOneLayer:onLayerUnload( ... )
	-- body
end


return BagUseItemMultiTimesNChooseOneLayer