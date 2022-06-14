local itemtips = class( "itemtips", layout );

global_event.ITEMTIPS_SHOW = "ITEMTIPS_SHOW";
global_event.ITEMTIPS_HIDE = "ITEMTIPS_HIDE";

function itemtips:ctor( id )
	itemtips.super.ctor( self, id );
	self:addEvent({ name = global_event.ITEMTIPS_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.ITEMTIPS_HIDE, eventHandler = self.onHide});
end

function itemtips:onShow(event)
	if self._show then
		return;
	end

	self:Show();

	self.itemtips = LORD.toLayout(self:Child( "itemtips" ));
	self.itemtips_common = self:Child( "itemtips-common" );
	self.itemtips_item = LORD.toStaticImage(self:Child( "itemtips-item" ));
	self.itemtips_item_image = LORD.toStaticImage(self:Child( "itemtips-item-image" ));
	self.itemtips_name = self:Child( "itemtips-name" );
	self.itemtips_money = LORD.toStaticImage(self:Child( "itemtips-money" ));
	self.itemtips_money_num = self:Child( "itemtips-money-num" );
	self.itemtips_money_text = self:Child( "itemtips-money-text" );
	self.itemtips_num = self:Child( "itemtips-num" );
	self.itemtips_lv = self:Child( "itemtips-lv" );
	self.itemtips_lv_num = self:Child( "itemtips-lv-num" );
	self.itemtips_equip = self:Child( "itemtips-equip" );
	self.itemtips_word = self:Child( "itemtips-word" );
	self.itemtips_equipattri = self:Child( "itemtips-equipattri" );
	self.itemtips_attri1 =  (self:Child( "itemtips-attri1" ));
	self.itemtips_attri1_num = self:Child( "itemtips-attri1-num" );
	self.itemtips_attri2 =  (self:Child( "itemtips-attri2" ));
	self.itemtips_attri2_num = self:Child( "itemtips-attri2-num" );
	self.itemtips_itemback = LORD.toStaticImage(self:Child( "itemtips-itemback" ));
	self.itemtips_patch = self:Child( "itemtips-patch" );
	self.itemtips_patch:SetText("")
	
	self:init(event);
end

function itemtips:onHide(event)
	self:Close();
end

function itemtips:init(event)

	if event.tipsType == enum.REWARD_TYPE.REWARD_TYPE_ITEM then
		local itemConfigInfo = itemManager.getConfig(event.id);
		if itemConfigInfo then
			-- info
			local icon = itemConfigInfo.icon;
			local star = itemConfigInfo.star;
			local maskicon = nil;
			if itemConfigInfo.type == enum.ITEM_TYPE.ITEM_TYPE_DEBRIS then
				maskicon = "itemmask.png";
			end
			self.itemtips_itemback:SetImage( itemManager.getBackImage(itemConfigInfo.type == enum.ITEM_TYPE.ITEM_TYPE_DEBRIS) )
			local subID = itemConfigInfo.subID;
			
			-- 设置通用信息
			self.itemtips_item:SetImage(itemManager.getImageWithStar(star, maskicon~=nil));			
			global.setMaskIcon(self.itemtips_item_image, maskicon);
			
			self.itemtips_item_image:SetImage(icon);
			self.itemtips_name:SetText(itemConfigInfo.name);
			self.itemtips_word:SetText(itemConfigInfo.text);
			self.itemtips_money_num:SetText(itemConfigInfo.sellToShop);
		
			
			-- show hide
			-- 设置信息
			self.itemtips_common:SetVisible(true);
			
			if itemConfigInfo.type == enum.ITEM_TYPE.ITEM_TYPE_EQUIP then
				self.itemtips_equipattri:SetVisible(true);
				self.itemtips_equip:SetVisible(true);
			
				self.itemtips_lv:SetVisible(true);
				self.itemtips_num:SetVisible(false);
				self.itemtips_money:SetVisible(false);
				self.itemtips_word:SetVisible(false);
				
				local equipConfig = itemManager.getEquipConfig(subID);
				if equipConfig then
					self.itemtips_lv_num:SetText(equipConfig.requireLevel);
					
					--self.itemtips_attri1:SetImage(enum.EQUIP_ATTR_ICON[equipConfig.attr]);
					--self.itemtips_attri2:SetImage(enum.EQUIP_ATTR_ICON[equipConfig.attr2]);
					
					
					self.itemtips_attri1:SetText(enum.EQUIP_ATTR_TEXT[equipConfig.attr] or "" );
					self.itemtips_attri2:SetText(enum.EQUIP_ATTR_TEXT[equipConfig.attr2]  or "" );
					
					if equipConfig.attr < 0 then
						self.itemtips_attri1_num:SetText("");
					else
						self.itemtips_attri1_num:SetText(equipConfig.baseAttrValue);
					end
					
					if equipConfig.attr2 < 0 then
						self.itemtips_attri2_num:SetText("");
					else
						self.itemtips_attri2_num:SetText(equipConfig.baseAttrValue2);
					end
					self.itemtips_equip:SetText( itemManager.getEquipPartDes(equipConfig.part) )
					
				end
			elseif itemConfigInfo.type == enum.ITEM_TYPE.ITEM_TYPE_DEBRIS then
				self.itemtips_equipattri:SetVisible(false);
				self.itemtips_equip:SetVisible(false);
				self.itemtips_lv:SetVisible(false);
				self.itemtips_num:SetVisible(true);
				self.itemtips_money:SetVisible(false);
				self.itemtips_word:SetVisible(true);
				
				local debrisConfig = itemManager.getDebrisConfig(subID);
				if debrisConfig then
					local needCount = debrisConfig.needCount;
					local currenCount = dataManager.bagData:getItemNums(enum.BAG_TYPE.BAG_TYPE_BAG, event.id);
					
					self.itemtips_num:SetText(currenCount);
					local config = itemManager.getConfig(debrisConfig.productID)
					if(config.type == enum.ITEM_TYPE.ITEM_TYPE_EQUIP )then
						local equipConfig =  itemManager.getEquipConfig(config.subID)
						self.itemtips_lv:SetVisible(true);
						self.itemtips_lv_num:SetText(equipConfig.requireLevel);
						---self.itemtips_num:SetText(equipConfig.requireLevel);
						self.itemtips_equip:SetVisible(true);
						self.itemtips_equip:SetText( itemManager.getEquipPartDes(equipConfig.part) )
					
						self.itemtips_attri1:SetText(enum.EQUIP_ATTR_TEXT[equipConfig.attr] or "" );
						self.itemtips_attri2:SetText(enum.EQUIP_ATTR_TEXT[equipConfig.attr2]  or "" );
						self.itemtips_equipattri:SetVisible(true);
						if equipConfig.attr < 0 then
							self.itemtips_attri1_num:SetText("");
						else
							self.itemtips_attri1_num:SetText(equipConfig.baseAttrValue);
						end
						
						if equipConfig.attr2 < 0 then
							self.itemtips_attri2_num:SetText("");
						else
							self.itemtips_attri2_num:SetText(equipConfig.baseAttrValue2);
						end
					end
		 
				end
				
			else
				self.itemtips_equipattri:SetVisible(false);
				self.itemtips_equip:SetVisible(false);
				self.itemtips_lv:SetVisible(false);
				self.itemtips_num:SetVisible(false);
				self.itemtips_money:SetVisible(itemConfigInfo.noSell == false );
				self.itemtips_word:SetVisible(true);			
			end
		
		end		
	elseif event.tipsType == enum.REWARD_TYPE.REWARD_TYPE_MAGIC_EXP then
		-- 只显示名字，描述
		self.itemtips_equipattri:SetVisible(false);
		self.itemtips_equip:SetVisible(false);
		self.itemtips_lv:SetVisible(false);
		self.itemtips_num:SetVisible(false);
		self.itemtips_money:SetVisible(false);
		self.itemtips_word:SetVisible(true);
		self.itemtips_common:SetVisible(true);
		local magicInfo = dataConfig.configs.magicConfig[event.id];
		if magicInfo then
			self.itemtips_item:SetImage(itemManager.getImageWithStar(0, false));			
			global.setMaskIcon(self.itemtips_item_image, nil);
			
			self.itemtips_item_image:SetImage(magicInfo.icon);
			self.itemtips_name:SetText(magicInfo.name);
			
			--local magicInstance = dataManager.kingMagic:getMagic(event.id);
			print("event.id "..event.id);
			print("event.level "..event.level);
			
			local text = dataManager.playerData:parseText(magicInfo.text, event.id, event.level, dataManager.playerData:getIntelligence());
			self.itemtips_word:SetText(text);
			
			local magic = dataManager.kingMagic:getMagic(event.id)
			local _text = ""
			
			if(magic)then
			
				if(magic:isTopLevel() == false)then
					
					local nextExp = magic:getNextExp();
					local currentExp = magic:getCurrentExp();
					local levelupLeftExp = nextExp - currentExp;
					
					if(magic:getStar() <= 0) then
						--_text = "再收集"..nextExp.."个碎片可获得【"..magicInfo.name.."】"
						_text = "获得此新魔法";
					else
						_text = "熟练度再增加"..levelupLeftExp.."可升至".. magic:getStar() + 1 .."星"
					end
				else
					
					_text = "星级已满"
					
				end
				
			end
			
			self.itemtips_patch:SetText(_text)
		end
	elseif event.tipsType == enum.REWARD_TYPE.REWARD_TYPE_CARD_EXP then
		self.itemtips_equipattri:SetVisible(false);
		self.itemtips_equip:SetVisible(false);
		self.itemtips_lv:SetVisible(false);
		self.itemtips_num:SetVisible(false);
		self.itemtips_money:SetVisible(false);
		self.itemtips_word:SetVisible(true);
		self.itemtips_common:SetVisible(true);
		
		local unitInfo = dataConfig.configs.unitConfig[event.id];
		if unitInfo then
			self.itemtips_item:SetImage(itemManager.getImageWithStar(0, false));			
			global.setMaskIcon(self.itemtips_item_image, nil);
			
			self.itemtips_item_image:SetImage(unitInfo.icon);
			self.itemtips_name:SetText(unitInfo.name);
			self.itemtips_word:SetText(unitInfo.text);		
			
			local unit  = cardData.getCardInstance(event.id)
			local _text = ""
			
			
			local nowExp = 0
			local nextExp =  dataConfig.configs.ConfigConfig[0].startLevelTable[1] 
			if(unit)then
			
				if(unit:isMaxStar() == false)then
					nowExp = unit:getExp()
					nextExp = unit:getNextExp() - unit:getCurrentExp()
					if(nowExp == 0) then
						_text = "再收集"..nextExp.."个碎片可获得【"..unitInfo.name.."】"
						--_text = "获得此新军团";
					else
						_text = "再收集"..nextExp.."个碎片可升至".. unit:getStar() + 1 .."星"
					end
				else
					_text = "星级已满"
					
				end	
				
			else
				--_text = "再收集"..nextExp.."个碎片可获得【"..unitInfo.name.."】"
				_text = "获得此新军团";
			end
			self.itemtips_patch:SetText(_text)
		end
			
	-- 原生资源, 神像升级用
	elseif event.tipsType == enum.REWARD_TYPE.REWARD_TYPE_PRIMAL then
		
		local itemConfigInfo = dataManager.idolBuildData:getPrimalItemInfo(event.id);
		
		self.itemtips_equipattri:SetVisible(false);
		self.itemtips_equip:SetVisible(false);
		self.itemtips_lv:SetVisible(false);
		self.itemtips_num:SetVisible(false);
		self.itemtips_money:SetVisible(false);
		self.itemtips_word:SetVisible(true);
		self.itemtips_common:SetVisible(true);
		self.itemtips_item:SetImage(itemManager.getImageWithStar(itemConfigInfo.star, false));
		
		self.itemtips_item_image:SetImage(itemConfigInfo.icon);
		self.itemtips_name:SetText(itemConfigInfo.name);
		self.itemtips_word:SetText(itemConfigInfo.text);
		
	end
	
	self.itemtips:LayoutChild();
	
	self:calcTipsPositionFree(event);
end

-- 新的计算tips的规则
function itemtips:calcTipsPositionFree(event)
	
	local clickWindowRect = event.windowRect;
	local clickWindowWidth = clickWindowRect:getWidth();
	local clickWindowHeight = clickWindowRect:getHeight();

	local layoutWidth = self.itemtips:GetWidth().offset;
	local layoutHeight = self.itemtips:GetHeight().offset;

	local x = clickWindowRect.left - layoutWidth*0.5;
	local y = clickWindowRect.top - layoutHeight-10;
	

	local layoutSize = self.itemtips:GetPixelSize();
	
	if y < 0 then
		
		x = clickWindowRect.right+10;
		y = clickWindowRect.top-15;
		
		if x + layoutSize.x > engine.rootUiSize.w then
			x = clickWindowRect.left - layoutWidth;
			y = clickWindowRect.top;
		end
	
	elseif x < 0 then
		
		x = 0;
	
	elseif x + layoutSize.x > engine.rootUiSize.w then
		
		x = engine.rootUiSize.w - layoutSize.x;
			
	end
	
		
	self.itemtips:SetXPosition(LORD.UDim(0, x));
	self.itemtips:SetYPosition(LORD.UDim(0, y));
	
end


function itemtips:calcTipsPosition(event)
	
	local clickWindowRect = event.windowRect;
	local clickWindowWidth = clickWindowRect:getWidth();
	local clickWindowHeight = clickWindowRect:getHeight();
	
	local layoutWidth = self.itemtips:GetWidth().offset;
	local layoutHeight = self.itemtips:GetHeight().offset;
	
	local x = clickWindowRect.left;
	local y = clickWindowRect.top;
		
	if event.dir == "left" then
		x = LORD.UDim(0, clickWindowRect.left) - self.itemtips:GetWidth();
		y = LORD.UDim(0, clickWindowRect.top - 0.5*(layoutHeight - clickWindowHeight));
	elseif event.dir == "right" then
	
		x = LORD.UDim(0, clickWindowRect.right);
		y = LORD.UDim(0, clickWindowRect.top - 0.5*(layoutHeight - clickWindowHeight));
	elseif event.dir == "top" then
		
		x = LORD.UDim(0, clickWindowRect.left - 0.5*(layoutWidth - clickWindowWidth));
		y = LORD.UDim(0, clickWindowRect.top) - self.itemtips:GetHeight();
	elseif event.dir == "bottom" then

		x = LORD.UDim(0, clickWindowRect.left - 0.5*(layoutWidth - clickWindowWidth));
		y = LORD.UDim(0, clickWindowRect.bottom);
	end
	
	x = x + LORD.UDim(0, event.offsetX);
	y = y + LORD.UDim(0, event.offsetY);
	
	local s = self.itemtips:GetPixelSize()
	if( x.offset + s.x > engine.rootUiSize.w)then
		x.offset = engine.rootUiSize.w - s.x -5
	end
	
	if ( x.offset < 0 ) then
		x.offset = 0;
	end
	
	if( y.offset + s.y > engine.rootUiSize.h)then
		y.offset = engine.rootUiSize.h - s.y -5
	end
	
	if y.offset < 0 then
		y.offset = 0;
	end
	
	self.itemtips:SetXPosition(x);
	self.itemtips:SetYPosition(y);
end

return itemtips;
