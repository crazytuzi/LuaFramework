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
	-- for i=1,5 do
	-- 	if i <= role.starlevel then
	-- 		self.img_star[i]:setVisible(true)
	-- 	else
	-- 		self.img_star[i]:setVisible(false)
	-- 	end
	-- end
	self:changeNum(num)



	Public:addPieceImg(self.img_icon,nil,false);
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

    self.btn_icon:addMEListener(TFWIDGET_TOUCHBEGAN, self.IconBtnTouchBeganHandle);
    self.btn_icon:addMEListener(TFWIDGET_TOUCHMOVED, self.IconBtnTouchMovedHandle);
    self.btn_icon:addMEListener(TFWIDGET_TOUCHENDED, self.IconBtnTouchEndedHandle);

	self.btn_chongzhi:addMEListener(TFWIDGET_CLICK, audioClickfun(self.DelBtnClickHandle))

    self.btn_chongzhi:addMEListener(TFWIDGET_TOUCHBEGAN, self.DelBtnTouchBeganHandle);
    self.btn_chongzhi:addMEListener(TFWIDGET_TOUCHMOVED, self.DelBtnTouchMovedHandle);
    self.btn_chongzhi:addMEListener(TFWIDGET_TOUCHENDED, self.DelBtnTouchEndedHandle);
end

function DogfoodIcon:setSoulId( id ,num)
	self.id  = id
	self.type = 2

	local bagItem = BagManager:getItemById(id)
    if bagItem == nil then
        print("该道具不存在背包 id =="..id)
        return
    end
	self.maxnum = bagItem.num

	self.img_zhiye:setVisible(false)
	self.img_martialLevel:setVisible(false)

    local item = ItemData:objectByID(id)
    if item == nil then
        print("该卡牌不存在 id =="..id)
        return
    end

    if item.kind == 3 then
		self.txt_name:setText(item.name)
		self.img_icon:setTexture("icon/roleicon/" .. item.display .. ".png")
		self.img_quality:setTexture(GetColorIconByQuality( item.quality ))
	else
		local role = RoleData:objectByID(item.usable)
		if role == nil then
			print("无法找到该角色  id =="..id)
			return
		end

		self.txt_name:setText(role.name)
		-- self.txt_name:setColor(GetColorByQuality(role.quality))
		self.img_icon:setTexture(role:getIconPath())
		self.img_quality:setTexture(GetColorIconByQuality( role.quality ))
		-- for i=1,5 do
		-- 	if i <= role.init_star_level then
		-- 		self.img_star[i]:setVisible(true)
		-- 	else
		-- 		self.img_star[i]:setVisible(false)
		-- 	end
		-- end
	end

	self.img_soul:setVisible(true)
	self.img_soul1:setVisible(false)
	
	local rewardItem = {itemid = id}

	if item.kind ~= 3 then
		Public:addPieceImg(self.img_icon,rewardItem,true);
	else
		Public:addPieceImg(self.img_icon,rewardItem,false);
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
                    --msg = "该侠客身上已穿戴装备，请先卸下装备再进行传功"
                    msg = localizable.dogfoodIcon_chuangong
                    }
            )
		else
			self.logic:addDogFood( self.id , self );
		end
	else
		-- for i=1,self.maxnum - self.num do
			-- self.logic:addCatFood( self.id , self ,self.maxnum - self.num )
			self.logic:addCatFood( self.id , self ,1 )
		-- end
		-- function addCatFood()
	 --      	self.logic:addCatFood( self.id , self )
	 --    end

	 --    if self.timeId ~= nil then
	 --        TFDirector:removeTimer(self.timeId);
	 --    end
	 --    if  self.maxnum - self.num > 0 then
	 --        self.timeId = TFDirector:addTimer(100, self.maxnum - self.num, nil, addCatFood);
	 --    end
	end
end

function DogfoodIcon.DelBtnTouchBeganHandle(sender)
    local self = sender.logic;

	if self.type ~= 1 then
 		local times = 1;

	    local function onLongTouch()
			if self.num == 0 then
				return
			end

			self.isDel = true;
			self.logic:delCatFood( self.id , self ,true)
	    	TFDirector:removeTimer(self.longDelTouchTimerId);

	    	if times < 6 then
	    		self.longDelTouchTimerId = TFDirector:addTimer(200, 1, nil, onLongTouch); 
	    	else
	    		self.longDelTouchTimerId = TFDirector:addTimer(50, 1, nil, onLongTouch); 
	    	end
	    	times = times + 1;
	    end
	    self.longDelTouchTimerId = TFDirector:addTimer(300, 1, nil, onLongTouch); 

	end
end

function DogfoodIcon.DelBtnTouchMovedHandle(sender)
    local self = sender.logic;
    TFDirector:removeTimer(self.longDelTouchTimerId);
end

function DogfoodIcon.DelBtnTouchEndedHandle(sender)
    local self = sender.logic;
    if (self.longDelTouchTimerId) then
        TFDirector:removeTimer(self.longDelTouchTimerId);
        self.longDelTouchTimerId = nil;
    end

    if self.isDel then
    	self.logic:showDelCatFoodFly( self.id , self )
    end
    self.isDel = false;
end


function DogfoodIcon.IconBtnTouchBeganHandle(sender)
    local self = sender.logic;
	if self.type ~= 1 then
		local times = 1;
		local num_addSpeed = 1
		local num_add = 1
		local function onLongTouch()
			if self.num >= self.maxnum then
				self.num = self.maxnum
				return;
			end
			self.isAdd = true;
			if num_add + self.num >= self.maxnum then
				num_add = self.maxnum - self.num
			end
			local isConLongTouch = self.logic:addCatFood( self.id , self , num_add,true)
			TFDirector:removeTimer(self.longAddTouchTimerId);

			if num_addSpeed == 3 then
				num_addSpeed = 0
				num_add = num_add + 1
			else
				num_addSpeed = num_addSpeed + 1
			end

			local speed = 1
			if isConLongTouch then
				if times < 6 then
					self.longAddTouchTimerId = TFDirector:addTimer(200, 1, nil, onLongTouch);
					-- speed = 1.5
				else
					self.longAddTouchTimerId = TFDirector:addTimer(50, 1, nil, onLongTouch);
					-- speed = 2
				end
				times = times + 1;
				self.logic:showLongClickAddCatFoodFly( self.id , self ,speed)
			else
				self.isAdd = false;
			end
		end
		self.longAddTouchTimerId = TFDirector:addTimer(300, 1, nil, onLongTouch);
	end
end

function DogfoodIcon.IconBtnTouchMovedHandle(sender)
    local self = sender.logic;

    local v = ccpSub(sender:getTouchStartPos(), sender:getTouchMovePos());
    if v.y > 15 or v.y < -15 then
   	 	TFDirector:removeTimer(self.longAddTouchTimerId);
    end

end

function DogfoodIcon.IconBtnTouchEndedHandle(sender)
    local self = sender.logic;
    if (self.longAddTouchTimerId) then
        TFDirector:removeTimer(self.longAddTouchTimerId);
        self.longAddTouchTimerId = nil;
    end

    if self.isAdd then
    	self.logic:showAddCatFoodFly( self.id , self )
    end
    self.isAdd = false;
end

function DogfoodIcon.DelBtnClickHandle(sender)
	local self = sender.logic
	if self.num == 0 then
		return
	end
	if self.type == 1 then
		self.logic:delDogFood( self.id , self )
	else
		self.logic:delCatFood( self.id , self )
	end
end

function DogfoodIcon:setLogic( logic )
	self.logic = logic
end

function DogfoodIcon:registerEvents()
	self.super.registerEvents(self)

end

function DogfoodIcon:removeEvents()
	self.super.removeEvents(self)

end

return DogfoodIcon

