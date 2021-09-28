local SanguozhiSelectAwardLayer = class("SanguozhiSelectAwardLayer",UFCCSModelLayer)
require("app.cfg.main_growth_info")

--[[
	dataOrId, id或者xxx.get(id)
	callback   点击确定回调事件
]]
function SanguozhiSelectAwardLayer.show(dataOrId,callback)
	local layer = SanguozhiSelectAwardLayer.create(dataOrId,callback)
	uf_sceneManager:getCurScene():addChild(layer)
end

--为了可配置活动
function SanguozhiSelectAwardLayer.showForCustomActivity(data,callback)
	if not data or type(data) ~= "table" then
		return
	end
	local item = {}
	for i=1,4 do
		local _type = data["award_type"..i]
		if _type > 0 then
			item["type_"..i] = data["award_type"..i]
			item["value_"..i] = data["award_value"..i]
			item["size_"..i] = data["award_size"..i]
		end
	end
	local layer = SanguozhiSelectAwardLayer.create(item,callback)
	uf_sceneManager:getCurScene():addChild(layer)
end

--使用道具
function SanguozhiSelectAwardLayer.showForUseItem(data,callback)
	if not data then
		return
	end
	local item = {}
	for i=1,4 do
		local _type = data["choice_type_"..i]
		if _type > 0 then
			item["type_"..i] = data["choice_type_"..i]
			item["value_"..i] = data["choice_value_"..i]
			item["size_"..i] = data["choice_size_"..i]
		end
	end

	local layer = SanguozhiSelectAwardLayer.create(item,callback)
	uf_sceneManager:getCurScene():addChild(layer)
end


function SanguozhiSelectAwardLayer.create(...)
	return SanguozhiSelectAwardLayer.new("ui_layout/sanguozhi_SanguozhiSelectAwardLayer.json",Colors.modelColor,...)
end

function SanguozhiSelectAwardLayer:ctor(json,color,dataOrId,callback,...)
	self._callback = callback
	self._selectIndex = 0
	self._id = id
	self.super.ctor(self,...)
	self:showAtCenter(true)
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
end

function SanguozhiSelectAwardLayer:_initWidgets()
	--道具品质背景图
	self.qualityImageBgList = {
		self:getImageViewByName("Image_qualityBg01"),
		self:getImageViewByName("Image_qualityBg02"),
		self:getImageViewByName("Image_qualityBg03"),
		self:getImageViewByName("Image_qualityBg04"),
	}
	self.itemImageList = {
		self:getImageViewByName("Image_item01"),
		self:getImageViewByName("Image_item02"),
		self:getImageViewByName("Image_item03"),
		self:getImageViewByName("Image_item04"),
	}

	self.qualityButtonList = {
		self:getButtonByName("Button_quality01"),
		self:getButtonByName("Button_quality02"),
		self:getButtonByName("Button_quality03"),
		self:getButtonByName("Button_quality04"),
	}

	self.numLabelList = {
		self:getLabelByName("Label_num01"),
		self:getLabelByName("Label_num02"),
		self:getLabelByName("Label_num03"),
		self:getLabelByName("Label_num04"),
	}	
	self.nameLabelList = {
		self:getLabelByName("Label_name01"),
		self:getLabelByName("Label_name02"),
		self:getLabelByName("Label_name03"),
		self:getLabelByName("Label_name04"),
	}

	self.buttonList = {
		self:getButtonByName("Button_01"),
		self:getButtonByName("Button_02"),
		self:getButtonByName("Button_03"),
		self:getButtonByName("Button_04"),
	}

	for i=1,#self.nameLabelList do
		self.nameLabelList[i]:createStroke(Colors.strokeBrown,1)
		self.numLabelList[i]:createStroke(Colors.strokeBrown,1)
	end

	self:getLabelByName("Label_title"):createStroke(Colors.strokeBrown,1)

	self._checkBoxList = {
		self:getCheckBoxByName("CheckBox_01"),
		self:getCheckBoxByName("CheckBox_02"),
		self:getCheckBoxByName("CheckBox_03"),
		self:getCheckBoxByName("CheckBox_04"),
	}
end

function SanguozhiSelectAwardLayer:_initEvent()
	self:registerBtnClickEvent("Button_01",function()
		self:_setCheckBox(1)
		end)
	self:registerBtnClickEvent("Button_02",function()
		self:_setCheckBox(2)
		end)
	self:registerBtnClickEvent("Button_03",function()
		self:_setCheckBox(3)
		end)
	self:registerBtnClickEvent("Button_04",function()
		self:_setCheckBox(4)
		end)
	self:registerBtnClickEvent("Button_close",function()
		self:animationToClose()
		end)
	self:registerBtnClickEvent("Button_ok",function()
		if self._selectIndex == 0 then
			G_MovingTip:showMovingTip(G_lang:get("LANG__SAN_GUO_ZHI_QING_XUAN_ZE_JIANGLI"))
			return
		end
		if self._callback ~= nil then
			self._callback(self._selectIndex)
			self:animationToClose()
		end
		end)

end


function SanguozhiSelectAwardLayer:_setCheckBox(index)
	self._selectIndex = index
	for i,v in ipairs(self._checkBoxList)do
		v:setSelectedState(i == index)
	end
end
function SanguozhiSelectAwardLayer:_setWidgets()
	local len = 0 --奖励的长度
	for i=1,4 do
		local good = G_Goods.convert(self._data["type_" .. i],self._data["value_" .. i],self._data["size_" .. i])
		if good then
			len = len + 1
			self.qualityImageBgList[i]:loadTexture(G_Path.getEquipIconBack(good.quality))
			self.itemImageList[i]:loadTexture(good.icon)
			self.qualityButtonList[i]:loadTextureNormal(G_Path.getEquipColorImage(good.quality,good.type))
			self.qualityButtonList[i]:loadTexturePressed(G_Path.getEquipColorImage(good.quality,good.type))
			self:registerBtnClickEvent(self.qualityButtonList[i]:getName(),function()
				require("app.scenes.common.dropinfo.DropInfo").show(self._data["type_" .. i],self._data["value_" .. i]) 
				end)
			self.nameLabelList[i]:setColor(Colors.qualityColors[good.quality])
			self.nameLabelList[i]:setText(good.name)
			self.numLabelList[i]:setText("x" .. good.size)
		else
			self:showWidgetByName("Button_0" .. i,false)
		end
	end
	if len<4 then
		len =  len < 0 and 0 or len
		for i = (len>=1)and (len+1) or 1,4 do
			self:showWidgetByName("Button_0" .. i,false)
		end
		local width = self:getWidgetByName("Panel_60"):getContentSize().width
		local btnWidth = self.buttonList[1]:getContentSize().width
		local space = (width-len*btnWidth)/(len + 1)
		for i=1,len do
			self.buttonList[i]:setPositionX(space*i + btnWidth/2 +(i-1)*btnWidth)
		end
	end
end

function SanguozhiSelectAwardLayer:onLayerEnter()
	self:closeAtReturn(true)
	require("app.common.effects.EffectSingleMoving").run(self, "smoving_bounce")
end

return SanguozhiSelectAwardLayer