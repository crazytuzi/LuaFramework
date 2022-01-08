--[[
******微信*******

]]
local NoticeLayer = class("NoticeLayer", BaseLayer);

CREATE_SCENE_FUN(NoticeLayer);
CREATE_PANEL_FUN(NoticeLayer);

NoticeLayer.LIST_ITEM_HEIGHT = 90; 

function NoticeLayer:ctor(data)
    self.super.ctor(self,data);
    self:init("lua.uiconfig_mango_new.main.notice");
end

function NoticeLayer:initUI(ui)
    self.super.initUI(self,ui);
    self.btn_close   = TFDirector:getChildByPath(ui, 'btn_close');

    -- self.img_gonggao   = TFDirector:getChildByPath(ui, 'img_gonggao');

    if HeitaoSdk then
		local platformid = HeitaoSdk.getplatformId()

		local notice_url = "http://smi.heitao.com/mhqx/affiche?pfid="..platformid
		local designsize = CCDirector:sharedDirector():getOpenGLView():getDesignResolutionSize()
		local newx = (designsize.width - 960) / 2 + 145
		local newy = 100

		TFWebView.showWebView(notice_url, newx, 135, 660, 350)
    end
    
end

function NoticeLayer:onShow()
    self.super.onShow(self)
end


function NoticeLayer:removeUI()
   self.super.removeUI(self);
end


--注册事件
function NoticeLayer:registerEvents()
   self.super.registerEvents(self);
   -- ADD_ALERT_CLOSE_LISTENER(self,self.btn_close);
   -- self.btn_close:setClickAreaLength(100);

   self.btn_close:addMEListener(TFWIDGET_CLICK, audioClickfun(self.closeNoticeLayer))

end

function NoticeLayer:removeEvents()

end

function NoticeLayer.closeNoticeLayer(sender)
	TFWebView.removeWebView()
	AlertManager:close()
end

return NoticeLayer