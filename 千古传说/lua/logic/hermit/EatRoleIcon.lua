--[[
******狗粮icon*******

	-- by Stephen.tao
	-- 2013/12/5
	
	-- by haidong.gan
	-- 2014/5/5
]]

local DogfoodIcon = class("DogfoodIcon", BaseLayer)


--CREATE_SCENE_FUN(DogfoodIcon)
CREATE_PANEL_FUN(DogfoodIcon)

function DogfoodIcon:ctor(data)
    self.super.ctor(self,data)
    self.num = 0
    self.use_type = data
    self:init("lua.uiconfig_mango_new.role.DogfoodIcon")
end

function DogfoodIcon:initUI(ui)
	self.super.initUI(self,ui)
	self.txt_num 		= TFDirector:getChildByPath(ui, 'txt_num')
	self.btn_icon	 	= TFDirector:getChildByPath(ui, 'btn_icon')
	self.img_quality 	= TFDirector:getChildByPath(ui, 'img_quality')
	self.img_icon 		= TFDirector:getChildByPath(ui, 'img_icon')
	self.img_soul 		= TFDirector:getChildByPath(ui, 'img_soul')

	self.img_star       = {}
	for i=1,5 do
		local str = "img_star"..i
		self.img_star[i] = TFDirector:getChildByPath(ui, str)
	end
	self.img_soul1 		= TFDirector:getChildByPath(ui, 'img_soul1')
	self.txt_lv 		= TFDirector:getChildByPath(ui, 'txt_lv')
	self.btn_chongzhi 	= TFDirector:getChildByPath(ui, 'btn_chongzhi')
	self.txt_name 		= TFDirector:getChildByPath(ui, 'txt_name')
	self.img_zhezhao 	= TFDirector:getChildByPath(ui, 'img_zhezhao')
	self.img_chuzhan 	= TFDirector:getChildByPath(ui, 'img_chuzhan')

	--quanhuan add 2015/11/30
	self.img_zhu = TFDirector:getChildByPath(ui, 'img_zhu')
	self.img_zhu:setVisible(false)


	self.img_zhiye 	= TFDirector:getChildByPath(ui, 'img_zhiye')
	self.img_martialLevel 	= TFDirector:getChildByPath(ui, 'img_martialLevel')

	self.btn_icon.logic = self
	self.btn_chongzhi.logic = self
end

function DogfoodIcon:removeUI()
	self.super.removeUI(self)

	self.txt_num 		= nil
	self.btn_icon	 	= nil
	self.img_quality 	= nil
	self.img_icon 		= nil
	self.img_soul 		= nil
	self.img_star 		= nil
	self.img_soul1 		= nil
	self.txt_lv 		= nil
	self.btn_chongzhi 	= nil
	self.txt_name 		= nil
	self.img_zhezhao 	= nil

	self.type = nil
	self.id   = nil
	self.num  = nil
	self.maxnum  = nil

	TFDirector:removeTimer(self.timeId);
    self.timeId = nil;
end



function DogfoodIcon:setRoleGmId( gmid ,num )
	self.txt_num :setVisible(false)
	self.img_soul :setVisible(false)
	self.id  = gmid
	self.type = 1
	local role = CardRoleManager:getRoleByGmid(gmid)
	if role == nil then
		print("无法找到该角色, gmid == "..gmid)
		return
	end
	--quanhuan add 2015/11/30
	if AssistFightManager:isInAssistAll( gmid ) then
		self.img_zhu:setVisible(true)
	else
		self.img_zhu:setVisible(false)
	end
	
	local name = role.name
	if role.starlevel > 0 then
		name = name .. "+" ..role.starlevel
	end
	self.txt_name:setText(name)
	-- self.txt_name:setColor(GetColorByQuality(role.quality))
	self.maxnum = 1
	self.img_icon:setTexture(role:getIconPath())
	self.img_quality:setTexture(GetColorIconByQuality( role.quality ))
	self.img_soul:setVisible(false)
	self.img_soul1:setVisible(true)

	self.img_zhiye:setVisible(true)
	self.img_zhiye:setTexture("ui_new/fight/zhiye_".. role.outline ..".png")
	self.img_martialLevel:setVisible(true)
	self.img_martialLevel:setTexture(GetFightRoleIconByWuXueLevel(role.martialLevel))

	self.txt_lv:setText(role.level)
	self:changeNum(num)

	Public:addPieceImg(self.img_icon,nil,false);
	self.img_chuzhan:setVisible(false)
end

function DogfoodIcon:changeNum( num )
	self.num = num
	if num == 0 then
		if self.type == 1 then
			self.txt_num:setVisible(false)
		else
			self.txt_num:setVisible(true)
			self.txt_num:setText(self.maxnum)
		end
		self.btn_chongzhi:setVisible(false)
		self.img_zhezhao:setVisible(false)
	else
		self.txt_num:setVisible(true)
		self.btn_chongzhi:setVisible(true)
		self.img_zhezhao:setVisible(true)
		self.txt_num:setText(self.num .."/".. self.maxnum)
	end
	self.img_zhezhao:setVisible(false)

	self.btn_icon:addMEListener(TFWIDGET_CLICK, audioClickfun(self.IconBtnClickHandle))

	self.btn_chongzhi:addMEListener(TFWIDGET_CLICK, audioClickfun(self.DelBtnClickHandle))

end

function DogfoodIcon:setSoulId( id ,num)
	self.id  = id
	self.type = 2

	local bagItem = BagManager:getItemById(id)
    if bagItem == nil then
        print("该道具不存在背包 id =="..id)
        return
    end
	--quanhuan add 2015/11/30
	if AssistFightManager:isInAssistBySoulid( id ) then
		self.img_zhu:setVisible(true)
	else
		self.img_zhu:setVisible(false)
	end

	self.maxnum = bagItem.num

	self.img_zhiye:setVisible(false)
	self.img_martialLevel:setVisible(false)

    local item = ItemData:objectByID(id)
    if item == nil then
        print("该卡牌不存在 id =="..id)
        return
    end
	self.img_chuzhan:setVisible(false)
    if item.kind == 3 then
		self.txt_name:setText(item.name)
		self.img_icon:setTexture("icon/roleicon/" .. item.display .. ".png")
		self.img_quality:setTexture(GetColorIconByQuality( item.quality ))
	else
		local role = RoleData:objectByID(item.usable)
		if role == nil and id ~= 2000  then
			print("无法找到该角色  id =="..id)
			return
		end
		if id == 2000 then
			role = RoleData:objectByID(MainPlayer:getProfession())
			self.txt_name:setText(MainPlayer:getPlayerName())
		else
			self.txt_name:setText(role.name)
		end

		self.img_icon:setTexture(role:getIconPath())
		self.img_quality:setTexture(GetColorIconByQuality( role.quality ))

		local roleInfo = CardRoleManager:getRoleById(role.id)
		if roleInfo and roleInfo.pos ~= nil and roleInfo.pos ~= 0 then
			self.img_chuzhan:setVisible(true)
		end
	end

	self.img_soul:setVisible(true)
	self.img_soul1:setVisible(false)
	
	local rewardItem = {itemid = id}

	if item.kind ~= 3 then
		Public:addPieceImg(self.img_icon,rewardItem,true);
	end
	self:changeNum(num)


end

function DogfoodIcon.IconBtnClickHandle(sender)
	local self = sender.logic
	if self.num >= self.maxnum then
		return
	end
	if self.type == 1 then
		local role = CardRoleManager:getRoleByGmid(self.id)
		local message = ""
		if self.use_type == "RoleFireLayer" then
			--message = "该侠客身上已穿戴装备，系统将自动卸下装备进行归隐"
			message = localizable.eatRoleIcon_tips1
		else
			--message = "该侠客身上已穿戴装备，系统将自动卸下装备进行重生"
			message = localizable.eatRoleIcon_tips2
		end
		if role:getEquipment():length() > 0 then

			CommonManager:showOperateSureLayer(
                    function()
						for i=1, 5 do
							local equipInfo = role:getEquipment():GetEquipByType(i)
							if equipInfo then
								EquipmentManager:unEquipmentChange({gmid = equipInfo.gmId,roleid = role.id});
							end
						end

						self.logic:addDogFood( self.id , self );
                    end,
                    nil,
                    {
                    msg = message
                    }
            )
		else
			self.logic:addDogFood( self.id , self );
		end
	else
			self.logic:addCatFood( self.id , self ,self.maxnum )
	end
end

function DogfoodIcon.DelBtnClickHandle(sender)
	local self = sender.logic
	if self.num == 0 then
		return
	end
	if self.type == 1 then
		self.logic:delDogFood( self.id , self )
	else
		self.logic:delCatFood( self.id , self ,1)
	end
end

function DogfoodIcon:setLogic( logic )
	self.logic = logic
end

function DogfoodIcon:registerEvents()
	self.super.registerEvents(self)
	self.delDogfoodCallBack = function (event)
		local data = event.data[1]
		if data.id == self.id then
			if data.add == true then
				self:changeNum(self.maxnum)

			else
				self:changeNum(0)
			end
		end
	end
	if self.use_type == "RoleFireLayer" then
		TFDirector:addMEGlobalListener("RoleFireLayer.DelDogFoodCall",self.delDogfoodCallBack)
	else
		TFDirector:addMEGlobalListener("RoleReBirthLayer.DelDogFoodCall",self.delDogfoodCallBack)
	end
end

function DogfoodIcon:removeEvents()
	self.super.removeEvents(self)
	if self.use_type == "RoleFireLayer" then
		TFDirector:removeMEGlobalListener("RoleFireLayer.DelDogFoodCall",self.delDogfoodCallBack)
	else
		TFDirector:removeMEGlobalListener("RoleReBirthLayer.DelDogFoodCall",self.delDogfoodCallBack)
	end
	self.delDogfoodCallBack = nil
end

return DogfoodIcon

