local modalTip = class( "modalTip", layout );

global_event.MODALTIP_SHOW = "MODALTIP_SHOW";
global_event.MODALTIP_HIDE = "MODALTIP_HIDE";

function modalTip:ctor( id )
	modalTip.super.ctor( self, id );
	self:addEvent({ name = global_event.MODALTIP_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.MODALTIP_HIDE, eventHandler = self.onHide});
	self.tipHandle = nil
end

function modalTip:onShow(event)
	if self._show then
		self:onHide();
	end

	self:Show();
	
	self.wnd ={} 
	
	
	function onClickModalTipOther()
		
		eventManager.dispatchEvent({name =global_event.WARNINGHINT_SHOW ,tip = "现在还不可以摸那里，要按指引进行操作哦~" })
	end	
	
	
	for i=1,4 do
		self.wnd[i] =  LORD.toStaticImage( self:Child("modalTip-mask_"..(i-1)) )
		
		--设置遮罩图片
		self.wnd[i]:SetImage("set:common.xml image:backblak")
		--self.wnd[i]:SetImage("")
		--设置图片透明度0-1.0
		self.wnd[i]:SetAlpha(0)
		self.wnd[i]:subscribeEvent("WindowTouchUp", "onClickModalTipOther")	
	end
	
	
	
	
	local rect  = event.rect 
	self.ui = event.ui
	
	rect.left = 	rect.x  
	rect.top = 		rect.y  
	rect.bottom = 	rect.h +   rect.top
	rect.right = 	rect.w +   rect.left
	
	function tipHandleTimeTick(dt)
		
		
		
			--rect = LORD.Rect(300,300,500,500)
			if( self.ui )then
				local p = self.ui:GetParent()
				if( p and engine.uiRoot:GetName() ~= p:GetName() )then
					rect = p:GetUnclippedOuterRect();--LORD.Rect
					print("p name "..p:GetName())
				else
					rect = self.ui:GetUnclippedOuterRect();--LORD.Rect
					rect = LORD.Rect(rect.left,rect.top,rect.right + rect:getWidth() ,rect.bottom + rect:getHeight() )
				end
					rect.left = rect.left -50
					rect.top = rect.top -50
					rect.right = rect.left +200
					rect.bottom = rect.top +200
			end
			--print("rect---------------"..rect.left.." "..rect.top.." "..rect.right.." "..rect.bottom)
			
		
			
			
			local pos = LORD.UVector2(LORD.UDim(0, rect.left ), LORD.UDim(0, rect.top))
		 
			local wnd = self.wnd[1]
			local width = wnd:GetWidth()
			local height = wnd:GetHeight()
			
			local wxpos =  LORD.UDim(0, 0)
			local wypos =  LORD.UDim(0, rect.top) - height	
			wnd:SetPosition(LORD.UVector2(wxpos,  wypos ))


			wnd = self.wnd[2]
			wypos =  LORD.UDim(0, rect.bottom) 	
		  
			wnd:SetPosition(LORD.UVector2(wxpos,  wypos ))
			
			wnd = self.wnd[3]
			width = wnd:GetWidth()
			wypos =  LORD.UDim(0, rect.top) 	
			wxpos =   LORD.UDim(0, rect.left) - width
			wnd:SetPosition(LORD.UVector2(wxpos,  wypos ))
			wnd:SetHeight( LORD.UDim(0, rect.bottom - rect.top )  )
			
			wnd = self.wnd[4]
			wxpos =  LORD.UDim(0, rect.right) 	
			wnd:SetPosition(LORD.UVector2(wxpos,  wypos ))
			wnd:SetHeight( LORD.UDim(0, rect.bottom - rect.top )  )
		
	end	
	
	if(self.tipHandle ~= nil)then
		scheduler.unscheduleGlobal(self.tipHandle)
		self.tipHandle = nil
	end
	
	if(self.tipHandle == nil)then
		self.tipHandle = scheduler.scheduleGlobal(tipHandleTimeTick,0)
	end	
	
end




function modalTip:onHide(event)
	self:Close();
	if(self.tipHandle ~= nil)then
		scheduler.unscheduleGlobal(self.tipHandle)
		self.tipHandle = nil
	end
end

return modalTip;
