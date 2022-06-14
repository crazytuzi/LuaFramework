local skillbag = class( "skillbag", layout );

global_event.SKILLBAG_SHOW = "SKILLBAG_SHOW";
global_event.SKILLBAG_HIDE = "SKILLBAG_HIDE";

function skillbag:ctor( id )
	skillbag.super.ctor( self, id );
	self:addEvent({ name = global_event.SKILLBAG_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.SKILLBAG_HIDE, eventHandler = self.onHide});
end

function skillbag:onShow(event)
	if self._show then
		return;
	end

	self:Show();

	function onSkillBagTabChange(args)
		
		local window = LORD.toRadioButton(LORD.toWindowEventArgs(args).window);
		local userdata =  window:GetUserData();
		if window:IsSelected() then
			self:initAllMagicInfo(userdata);
			
			local index = (userdata+2);
			
			print("---------index"..index);
			for i=1, 5 do
				
				local skillbag_tab_text_n = self:Child("skillbag-tab"..i.."-text-n");
				local skillbag_tab_text = self:Child("skillbag-tab"..i.."-text");
				
				skillbag_tab_text_n:SetVisible(i==index);
				skillbag_tab_text:SetVisible(i~=index);
				
			end
			
		end
	end
	
	function onClickSkillBagClose()
		self:onHide();
	end
	
	self.skillbag_huadong = LORD.toScrollPane(self:Child( "skillbag-huadong" ));
	self.skillbag_huadong:init();
	
	self.skillbag_close = self:Child( "skillbag-close" );
	self.skillbag_close:subscribeEvent("ButtonClick", "onClickSkillBagClose");
		
	-- 筛选的标签
	self.skillbag_tab = {};
	for i=1, 5 do
		self.skillbag_tab[i] = LORD.toRadioButton(self:Child("skillbag-tab"..i));
		-- 类型
		self.skillbag_tab[i]:SetUserData(i-2);
		self.skillbag_tab[i]:subscribeEvent("RadioStateChanged", "onSkillBagTabChange");
	end
	
	self.skillbag_name = self:Child( "skillbag-name" );
	self.skillbag_star_bar = self:Child( "skillbag-star-bar" );
	self.skillbag_text = self:Child( "skillbag-text" );
	self.skillbag_skillinfor = self:Child( "skillbag-skillinfor" );
	
	self.skillbag_tab[1]:SetSelected(true);
	
end

function skillbag:onHide(event)
	self:Close();
end

function skillbag:initAllMagicInfo(magicType)
	
	self.skillbag_item = {};
	self.skillbag_item_icon = {};
	self.skillbag_item_name = {};
	self.skillbag_item_xuanzhong = {};
	self.skillbag_item_star = {};
		
	self.skillbag_huadong:ClearAllItem();
	self.skillbag_huadong:InitializePos();
	
	local xEdge = LORD.UDim(0, 15);
	local yEdge = LORD.UDim(0, -5);
	
	local xPos = LORD.UDim(0, xEdge.offset);
	local yPos = LORD.UDim(0, yEdge.offset);
	
	self.iconWidth = LORD.UDim(0, 50);
	self.iconHeight = LORD.UDim(0, 50);
	
	local scrollPanelSize = self.skillbag_huadong:GetPixelSize();
	
	-- 星级排序
	--for k,v in ipairs(dataConfig.configs.magicConfig) do
	
	local firstMagic = nil;
	
	for key, value in ipairs(dataManager.kingMagic:getSortMagicIDList()) do
		
		-- k是魔法id， v是表格data
		local k = value.magicID;
		local v = dataConfig.configs.magicConfig[k];
		local magicInstance = dataManager.kingMagic:getMagic(v.id);
				
		if (not dataManager.kingMagic:isGreatMagic(v.id)) and magicInstance and magicInstance:getExp() > 0 and (magicType < 0 or magicType == v.magicLabel ) then
		
			if firstMagic == nil then
				firstMagic = k;
			end
			
			--print("addMagicItem "..v.id);
			self:addMagicItem(k, xPos, yPos);
			
			xPos = xPos + xEdge + self.iconWidth;
			
			local xRightPosition = xPos + self.iconWidth;
			if xRightPosition.offset > scrollPanelSize.x then
				-- 行尾
				xPos = xEdge;
				yPos = yPos + yEdge + self.iconHeight;
			end
		end
	end
	
	self:onSelectMagic(firstMagic);
end

function skillbag:addMagicItem(index, xPos, yPos)
	
	function onClickSkillBagMagic(args)
		local window = LORD.toWindowEventArgs(args).window;
		local magicID = window:GetUserData();
		self:onSelectMagic(magicID);
	end
	
	local k = index;
	local v = dataConfig.configs.magicConfig[k];
	local magicInstance = dataManager.kingMagic:getMagic(v.id);
	
	self.skillbag_item[k] = LORD.GUIWindowManager:Instance():CreateWindowFromTemplate("skillbag_"..k, "battleskillitem.dlg");
	self.iconWidth = self.skillbag_item[k]:GetWidth();
	self.iconHeight = self.skillbag_item[k]:GetHeight();
	
	self.skillbag_item[k]:SetXPosition(xPos);
	self.skillbag_item[k]:SetYPosition(yPos);
	self.skillbag_huadong:additem(self.skillbag_item[k]);
	
	self.skillbag_item_icon[k] = LORD.toStaticImage(self:Child("skillbag_"..k.."_battleskillitem-item"));
	self.skillbag_item_icon[k]:SetImage(v.icon);
	self.skillbag_item_icon[k]:SetUserData(k);
	
	local battleskillitem_equity = LORD.toStaticImage(self:Child("skillbag_"..k.."_battleskillitem-equity"));
	battleskillitem_equity:SetImage(itemManager.getImageWithStar(magicInstance:getStar()));
	
	local fakeWindow = self:Child("skillbag_"..k.."_battleskillitem-fake");
	fakeWindow:SetVisible(false);
	
	self.skillbag_item_icon[k]:subscribeEvent("WindowTouchUp", "onClickSkillBagMagic");
	--self.skillbag_item_icon[k]:subscribeEvent("WindowTouchDown", "onClickSkillBagMagicTips");
	--self.skillbag_item_icon[k]:subscribeEvent("MotionRelease", "onHideMagicTips");
	
	self.skillbag_item_name[k] = self:Child("skillbag_"..k.."_battleskillitem-name");
	self.skillbag_item_name[k]:SetText(v.name);
	self.skillbag_item_xuanzhong[k] = LORD.toStaticImage(self:Child("skillbag_"..k.."_battleskillitem-chose"));
	self.skillbag_item_xuanzhong[k]:SetVisible(false);
	
	-- 星级显示,根据魔法等级
	self.skillbag_item_star[k] = {};
	for i=1, 5 do
		self.skillbag_item_star[k][i] = self:Child("skillbag_"..k.."_battleskillitem1-star"..i);
		if i <= magicInstance:getStar() then
			self.skillbag_item_star[k][i]:SetVisible(true);
		else
			self.skillbag_item_star[k][i]:SetVisible(false);
		end
	end
		
end

function skillbag:onSelectMagic(magicID)
	local magicInstance = dataManager.kingMagic:getMagic(magicID);
	if magicInstance then
		
		for k, v in pairs(self.skillbag_item_xuanzhong) do
			if k == magicID then
				v:SetVisible(true);
			else
				v:SetVisible(false);
			end
		end
		
		local configData = magicInstance:getConfig();
		self.skillbag_skillinfor:SetVisible(true);
		
				local magicInstance = dataManager.kingMagic:getMagic(magicID);
		local desc = dataManager.playerData:parseText(configData.text, magicID, magicInstance:getStar(), dataManager.playerData:getIntelligence());

		
		self.skillbag_name:SetText(configData.name);
		self.skillbag_text:SetText(desc);
		
		--print("magicInstance:getCurrentExp() "..magicInstance:getCurrentExp());
		--print("magicInstance:getNextExp() "..magicInstance:getNextExp());
		
		local percent = magicInstance:getCurrentExp() / magicInstance:getNextExp();
		self.skillbag_star_bar:SetProperty("Progress", percent);
		
		-- add 0513 新的信息
		local skillbag_skillequity = LORD.toStaticImage(self:Child("skillbag-skillequity"));
		skillbag_skillequity:SetImage(itemManager.getImageWithStar(magicInstance:getStar()));
		
		local skillbag_skillitem = LORD.toStaticImage(self:Child("skillbag-skillitem"));
		skillbag_skillitem:SetImage(configData.icon);
		
		local skillbag_skillstar = {};
		for i=1, 5 do
			skillbag_skillstar[i] = self:Child("skillbag-skillstar"..i);
			skillbag_skillstar[i]:SetVisible(i<=magicInstance:getStar());
		end
		
		local skillbag_star_bar_num = self:Child("skillbag-star-bar-num");
		skillbag_star_bar_num:SetText(magicInstance:getCurrentExp().."/"..magicInstance:getNextExp());
		
		local skillbag_cost_num = self:Child("skillbag-cost-num");
		skillbag_cost_num:SetText(magicInstance:getMpCost());
		local skillbag_cd_num = self:Child("skillbag-cd-num");
		skillbag_cd_num:SetText(configData.cooldown);
		
		uiaction.turnaround(self.skillbag_skillinfor, 300);
		
	else
		self.skillbag_skillinfor:SetVisible(false);
	end
end

return skillbag;
