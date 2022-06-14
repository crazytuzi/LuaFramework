local gameNotice = class( "gameNotice", layout );

global_event.GAMENOTICE_SHOW = "GAMENOTICE_SHOW";
global_event.GAMENOTICE_HIDE = "GAMENOTICE_HIDE";





GAME_UPDATE_MSG = [[
尊敬的《刀塔》玩家：
      自开服以来，受到了很多玩家的好评同时也收获了宝贵的意见，我们增加新系统，同时也优化了很多细节，以致于给予大家最棒的游戏体验！
^FF0000------------------------------------------------------------------^FFFFFF
新增内容：
1.奇迹系统：当玩家所有兵种达到一定星级时，可升级建筑，大幅度提升军团属性
2.VIP福利：调整了VIP特权及特权福利，同时增售VIP礼包
3.攻略录像：可以在精英关卡、副本挑战、极速挑战及远征等高难度关卡的战斗界面，点击观看其他玩家的优秀通关录像
体验优化：
1.战斗准备界面，增加自动战斗按钮
2.极速挑战副本，战败后不消耗超级魔法
3.修改部分BUG
^FF0000------------------------------------------------------------------^FFFFFF

在此《刀塔工作组》感谢广大玩家的热情参与和大力支持!
]]


function gameNotice:ctor( id )
	gameNotice.super.ctor( self, id );
	self:addEvent({ name = global_event.GAMENOTICE_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.GAMENOTICE_HIDE, eventHandler = self.onHide});
end

function gameNotice:onShow(event)
	if self._show then
		return;
	end

	self:Show();

	self.gameNotice_scroll = LORD.toScrollPane(self:Child( "gameNotice-scroll" ));
	self.gameNotice_close = self:Child( "gameNotice-close" );
	self.gameNotice_scroll:init();
	function onClickClosegameNotice()
		self:onHide()		
	end
		
	self.gameNotice_close:subscribeEvent("ButtonClick", "onClickClosegameNotice")	  
	
	
    local notice = LORD.GUIWindowManager:Instance():CreateWindowFromTemplate("gameNotice_", "gameNoticeText.dlg");
	notice:SetText(GAME_UPDATE_MSG)	
	
	local xpos = LORD.UDim(0, 10)
	local ypos = LORD.UDim(0, 10)
	notice:SetPosition(LORD.UVector2(xpos, ypos));		
	self.gameNotice_scroll:additem(notice);
	
	
	
end

function gameNotice:onHide(event)
	self:Close();
end

return gameNotice;
