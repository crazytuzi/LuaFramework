local guildApply = class( "guildApply", layout );

global_event.GUILDAPPLY_SHOW = "GUILDAPPLY_SHOW";
global_event.GUILDAPPLY_HIDE = "GUILDAPPLY_HIDE";

function guildApply:ctor( id )
	guildApply.super.ctor( self, id );
	self:addEvent({ name = global_event.GUILDAPPLY_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.GUILDAPPLY_HIDE, eventHandler = self.onHide});
end

function guildApply:onShow(event)
	if self._show then
		return;
	end

	self:Show();
	
	function onGuildApplyClose()
		self:onHide();
	end
	
	local guildApply_close = self:Child("guildApply-close");
	guildApply_close:subscribeEvent("ButtonClick", "onGuildApplyClose");
	
	local guildApply_playerhead = LORD.toStaticImage(self:Child("guildApply-playerhead"));
	guildApply_playerhead:SetImage(dataManager.playerData:getHeadIconImage());
	
	local guildApply_playername = self:Child("guildApply-playername");
	guildApply_playername:SetText(dataManager.playerData:getName());
	
	local guildApply_costnum = self:Child("guildApply-costnum");
	guildApply_costnum:SetText(dataManager.guildData:getCreateCostDiamond());
	
	function onGuildApplyCreate()
		
		local guildApply_edit = self:Child("guildApply-edit");
		guildData:onHandleCreateGuild(guildApply_edit:GetText());
		
		self:onHide();
	end
	
	function onGuildApplyEditTextChange()
		
		local guildApply_edit = self:Child("guildApply-edit");
		local text = guildApply_edit:GetText();
		local guildApply_nameText = self:Child("guildApply-nameText");
		
		guildApply_nameText:SetVisible(text == "");
		
	end
	
	local guildApply_create = self:Child("guildApply-create");
	guildApply_create:subscribeEvent("ButtonClick", "onGuildApplyCreate");
	
	local guildApply_edit = self:Child("guildApply-edit");
	guildApply_edit:subscribeEvent("WindowTextChanged", "onGuildApplyEditTextChange");
	
end

function guildApply:onHide(event)
	self:Close();
end

return guildApply;
 