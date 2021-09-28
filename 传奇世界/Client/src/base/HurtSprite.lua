local HurtSprite = class("HurtSprite", function() return  cc.Sprite:create() end)

function HurtSprite:ctor(strname,hurt_num,m_rect,pe_width,is_with_symbol,span) 
	local number_texture = Director:getTextureCache():addImage(strname)
	if number_texture then
		local m_span = span or 0
		local hurt_str = tostring(hurt_num) 
		local str_len = string.len(hurt_str)
		local num_tab = {}
		for i=1,str_len do
			num_tab[i] = tonumber(string.sub(hurt_str,i,i))
		end
		self:setTexture(number_texture)
		if is_with_symbol then
			self:setTextureRect(cc.rect(m_rect[1],m_rect[2],pe_width,m_rect[4]))
			for i=1,str_len do
				local num_sp = cc.Sprite:createWithTexture(number_texture,cc.rect(m_rect[1]+pe_width*(num_tab[i]+1),m_rect[2],pe_width,m_rect[4]))
				num_sp:setPosition(cc.p((pe_width+m_span)*i,0))
				num_sp:setAnchorPoint(cc.p(0.0,0.0))
				self:addChild(num_sp)
			end
		else
			self:setTextureRect(cc.rect(m_rect[1]+pe_width*num_tab[1],m_rect[2],pe_width,m_rect[4]))
			for i=2,str_len do
				local num_sp = cc.Sprite:createWithTexture(number_texture,cc.rect(m_rect[1]+pe_width*num_tab[i],m_rect[2],pe_width,m_rect[4]))
				num_sp:setPosition(cc.p((pe_width+m_span)*(i-1),0))
				num_sp:setAnchorPoint(cc.p(0.0,0.0))
				self:addChild(num_sp)
			end
		end
	end
end

return HurtSprite