--[[
******强化预览*******

    -- by Stephen.tao
    -- 2014/2/20
]]

local EquipmentIntensifyResult = class("EquipmentIntensifyResult", BaseLayer)

--CREATE_SCENE_FUN(EquipmentIntensifyResult)
CREATE_PANEL_FUN(EquipmentIntensifyResult)


function EquipmentIntensifyResult:ctor()
    self.super.ctor(self,data)
    self:init("lua.uiconfig_mango_new.item.EquipmentIntensifyResult")
end


function EquipmentIntensifyResult:initUI(ui)
	self.super.initUI(self,ui)


    self.img 		= {}
    self.att 		= {}

    for i=1,3 do
    	local str = "img_" .. i
    	self.img[i]        = TFDirector:getChildByPath(ui, str)
    	str = "att_" .. i
    	self.att[i]     = TFDirector:getChildByPath(ui, str)    	
    end
	self.txt_level     = TFDirector:getChildByPath(ui, "txt_level")    
	self.img_ok     = TFDirector:getChildByPath(ui, "img_ok")    
end

function EquipmentIntensifyResult:removeUI()
	self.super.removeUI(self)

    self.img 		= nil
    self.att 		= nil
    self.txt_level 	= nil
    self.img_ok 	= nil
end

function EquipmentIntensifyResult:setResult( result )
	self.txt_level:setText("D" .. result.level)
	if result.level == 1 then
		self.img_ok:setTexture("ui_new/item/zbqh_qhcg_word.png")
		TFAudio.stopAllEffects()
		TFAudio.playEffect("sound/effect/intensify.mp3", false)
	else
		play_qianghuabaoji_shengxingchenggong()
		self.img_ok:setTexture("ui_new/item/zbqh_qhbj_word.png")
	end
	local index = 1
	for i=1,(EnumAttributeType.Max-1) do
		if result.change_attr[i] and result.change_attr[i] ~= 0 then
			self.img[index]:setVisible(true)
			self.att[index]:setVisible(true)
			self.img[index]:setTexture("ui_new/item/zbqh_attr_"..i..".png")
			self.att[index]:setText("D"..result.change_attr[i])
			index = index + 1
		end
	end
	while index <= 3 do
		self.img[index]:setVisible(false)
		self.att[index]:setVisible(false)
		index = index + 1
	end
end

function EquipmentIntensifyResult:registerEvents()
    self.super.registerEvents(self)
end


return EquipmentIntensifyResult
