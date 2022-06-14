local revengePlunderList = class( "revengePlunderList", layout );

global_event.REVENGEPLUNDERLIST_SHOW = "REVENGEPLUNDERLIST_SHOW";
global_event.REVENGEPLUNDERLIST_HIDE = "REVENGEPLUNDERLIST_HIDE";

function revengePlunderList:ctor( id )
	revengePlunderList.super.ctor( self, id );
	self:addEvent({ name = global_event.REVENGEPLUNDERLIST_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.REVENGEPLUNDERLIST_HIDE, eventHandler = self.onHide});
end

function revengePlunderList:onShow(event)
	if self._show then
		return;
	end

	self:Show();
	
	dataManager.idolBuildData:setRevengeReaded();
	eventManager.dispatchEvent({name = global_event.IDOLSTATUS_UPDATE});
	
	function onRevengePlunderListClose()
		self:onHide();
	end
	
	local closeButton = self:Child( "pvprecord-close" );
	closeButton:subscribeEvent("ButtonClick", "onRevengePlunderListClose");
	local titletext = self:Child( "pvprecord-title-text" );
	titletext:SetProperty("Text" , "仇人名单");
	
	self:onUpdate();
	
end

function revengePlunderList:onUpdate()
	
	if not self._show then
		return;
	end
	
	function onRevengePlunderClickRevenge(args)
		
		local window = LORD.toWindowEventArgs(args).window;
		local dbid = window:GetUserData();
		
		dataManager.idolBuildData:onClickRevenge(dbid);
		
	end
	
	local scrollList = LORD.toScrollPane(self:Child( "pvprecord-scroll" ));
	scrollList:init();
	scrollList:ClearAllItem();
	
	local revengeList = dataManager.idolBuildData:getRevengeSummary();
	
	if revengeList then
		
		local xpos = LORD.UDim(0,0);
		local ypos = LORD.UDim(0,0);
		
		for k, v in ipairs(revengeList) do
			
			local recorditem = LORD.GUIWindowManager:Instance():CreateWindowFromTemplate("revergePlunder"..k, "pvprecorditem.dlg");
			recorditem:SetXPosition(xpos);
			recorditem:SetYPosition(ypos);
			scrollList:additem(recorditem);
			
			ypos = ypos + recorditem:GetHeight();
			

			local pvprecorditem_record = self:Child("revergePlunder"..k.."_pvprecorditem-record");
			local pvprecorditem_share = self:Child("revergePlunder"..k.."_pvprecorditem-share");
			
			local pvprecorditem_arrow = self:Child("revergePlunder"..k.."_pvprecorditem-arrow");
			local pvprecorditem_result = self:Child("revergePlunder"..k.."_pvprecorditem-result");
			
			pvprecorditem_record:SetVisible(false);
			pvprecorditem_share:SetVisible(false);
			pvprecorditem_arrow:SetVisible(false);
			pvprecorditem_result:SetVisible(false);
			
			local pvprecorditem_resultrob = self:Child("revergePlunder"..k.."_pvprecorditem-resultrob");			
			pvprecorditem_resultrob:SetVisible(true);
			
			-- revenge button
			local pvprecorditem_re = self:Child("revergePlunder"..k.."_pvprecorditem-re");
			pvprecorditem_re:SetUserData(v.dbid);
			
			pvprecorditem_re:subscribeEvent("ButtonClick", "onRevengePlunderClickRevenge");
			
			-- player info
			local pvprecorditem_playerimage = LORD.toStaticImage(self:Child("revergePlunder"..k.."_pvprecorditem-playerimage"));
			pvprecorditem_playerimage:SetImage(global.getHeadIcon(v.enemyIcon));
			
			local pvprecorditem_lv_num = self:Child("revergePlunder"..k.."_pvprecorditem-lv-num");
			pvprecorditem_lv_num:SetText(v.enemyLevel);
			
			local pvprecorditem_time = self:Child("revergePlunder"..k.."_pvprecorditem-time");
			pvprecorditem_time:SetText(global.battleRecordTimeToDays(v.time:GetUInt()));
			
			local power_num = self:Child("revergePlunder"..k.."_pvprecorditem-power-num");
			power_num:SetText(v.enemyPwoer);
			
			local pvprecorditem_name = self:Child("revergePlunder"..k.."_pvprecorditem-name");
			pvprecorditem_name:SetText(v.enemyName);
			
			-- primal item
			local pvprecorditem_itemimage = LORD.toStaticImage(self:Child("revergePlunder"..k.."_pvprecorditem-itemimage"));
			local itemInfo = dataManager.idolBuildData:getPrimalItemInfo(v.primalType);
			pvprecorditem_itemimage:SetImage(itemInfo.icon);
			
			-- tips
			pvprecorditem_itemimage:SetUserData(v.primalType);
			global.onItemTipsShow(pvprecorditem_itemimage, enum.REWARD_TYPE.REWARD_TYPE_PRIMAL, "top");
			global.onItemTipsHide(pvprecorditem_itemimage);
		
		end
	end
	
end

function revengePlunderList:onHide(event)
	self:Close();
end

return revengePlunderList;
