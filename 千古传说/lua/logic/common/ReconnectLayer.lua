--[[
******断线重链接*******

	-- by haidong.gan
	-- 2013/12/27
]]

local ReconnectLayer = class("ReconnectLayer", BaseLayer);

CREATE_SCENE_FUN(ReconnectLayer);
CREATE_PANEL_FUN(ReconnectLayer);

function ReconnectLayer:ctor()
	self.super.ctor(self);
	self:init("lua.uiconfig_mango_new.common.OperateSure2");
	self.isCanNotClose = true;
end

function ReconnectLayer:onShow()
	self.super.onShow(self)
    self:refreshBaseUI();
    self:refreshUI();
end

function ReconnectLayer:refreshBaseUI()

end

function ReconnectLayer:initUI(ui)
	self.super.initUI(self,ui);
	-- self.btn_close       = TFDirector:getChildByPath(ui, 'btn_close');

	self.btn_confirm     = TFDirector:getChildByPath(ui, 'btn_ok');
	self.txt_message     = TFDirector:getChildByPath(ui, 'txt_message');
	--self.txt_message:setText("网络异常，请重新连接。。。")
	self.txt_message:setText(localizable.common_net_reset_connnet)
	--self.btn_confirm:setText("重新连接")
	self.btn_confirm:setText(localizable.common_net_reset)
end

function ReconnectLayer:refreshUI()
    if not self.isShow then
        return;
    end

end

function ReconnectLayer:removeUI()
	self.super.removeUI(self);
end

function ReconnectLayer.onConfirmClickHandle(sender)
	local self = sender.logic;
	AlertManager:close();
	if PlayerGuideManager.now_step ~= 0 or (PlayerGuideManager.now_functionId < 20 and PlayerGuideManager.now_functionId > 0)  then
		local scene = Public:currentScene()
		if scene.__cname  == 'HomeScene' then
			PlayerGuideManager:restart()
			AlertManager:closeAll()
		elseif scene.__cname == "FightResultScene" or  scene.__cname == "FightScene" then
			PlayerGuideManager:restart()
			AlertManager:changeScene(SceneType.HOME,nil,TFSceneChangeType_PopBack)
			AlertManager:closeAll()
		end
	end
	CommonManager.autoConnect = true
	CommonManager:loginServer()
end

function ReconnectLayer:registerEvents()
	self.super.registerEvents(self);
	-- ADD_ALERT_CLOSE_LISTENER(self,self.btn_close)
    -- self.btn_close:setClickAreaLength(100);
    
	self.btn_confirm.logic    = self;   
	self.btn_confirm:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onConfirmClickHandle),1);

end

function ReconnectLayer:removeEvents()
	self.super.removeEvents(self);
end

return ReconnectLayer;
