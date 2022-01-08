--[[
******微信*******

]]
local TmallWebLayer = class("TmallWebLayer", BaseLayer);

CREATE_SCENE_FUN(TmallWebLayer);
CREATE_PANEL_FUN(TmallWebLayer);

TmallWebLayer.LIST_ITEM_HEIGHT = 90; 

function TmallWebLayer:ctor(data)
    self.super.ctor(self,data);
    self.url = data
    self:init("lua.uiconfig_mango_new.main.notice");
end


function TmallWebLayer:initUI(ui)
    self.super.initUI(self,ui);
    self.btn_close   = TFDirector:getChildByPath(ui, 'btn_close');
    self.img_gonggao   = TFDirector:getChildByPath(ui, 'img_gonggao');
    self.img_gonggao:setVisible(false)
    -- self.img_gonggao   = TFDirector:getChildByPath(ui, 'img_gonggao');

    if HeitaoSdk then
  		local platformid = HeitaoSdk.getplatformId()

  		local notice_url = self.url --"https://pages.tmall.com/wow/portal/act/app-download?iframe=1&type=web&mmstat=jhxiakeling&src=jhxiakeling"
  		local designsize = CCDirector:sharedDirector():getOpenGLView():getDesignResolutionSize()
  		local newx = (designsize.width - 960) / 2 + 145
  		local newy = 100

  		TFWebView.showWebView(notice_url, newx, 135, 660, 350)
    end
    
end

function TmallWebLayer:onShow()
    self.super.onShow(self)
end


function TmallWebLayer:removeUI()
   self.super.removeUI(self);
end


--注册事件
function TmallWebLayer:registerEvents()
   self.super.registerEvents(self);
   -- ADD_ALERT_CLOSE_LISTENER(self,self.btn_close);
   -- self.btn_close:setClickAreaLength(100);

   self.btn_close:addMEListener(TFWIDGET_CLICK, audioClickfun(self.closeTmallWebLayer))

end

function TmallWebLayer:removeEvents()

end

function TmallWebLayer.closeTmallWebLayer(sender)
	TFWebView.removeWebView()
	AlertManager:close()
end

return TmallWebLayer