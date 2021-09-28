local SanguozhiPageViewItem = class("SanguozhiPageViewItem",function (data)
    if data.type == 1 then
    	return CCSPageCellBase:create("ui_layout/sanguozhi_SanguozhiPageViewItem01.json")
    elseif data.type == 2 then
    	return CCSPageCellBase:create("ui_layout/sanguozhi_SanguozhiPageViewItem02.json")
    elseif data.type == 3 then
    	return CCSPageCellBase:create("ui_layout/sanguozhi_SanguozhiPageViewItem03.json")
    elseif data.type == 4 then
    	return CCSPageCellBase:create("ui_layout/sanguozhi_SanguozhiPageViewItem04.json")
    else 
    	return CCSPageCellBase:create("ui_layout/sanguozhi_SanguozhiPageViewItem05.json")
    end
end)


local EffectNode = require("app.common.effects.EffectNode")
local SanguozhiQiPao = require("app.scenes.sanguozhi.SanguozhiQiPao")

function SanguozhiPageViewItem:ctor(data,...)
	self._mxButtonList = {
		self:getButtonByName("Button_mx01"),
		self:getButtonByName("Button_mx02"),
		self:getButtonByName("Button_mx03"),
		self:getButtonByName("Button_mx04"),
		self:getButtonByName("Button_mx05"),
	}

	self._qipaoList = {}
	self._listData = data.data
	self:refreshWidgets()
end



function SanguozhiPageViewItem:refreshWidgets()
	if self._listData == nil or #self._listData%5 ~= 0 then
		--表有问题
		return
	end
	if self.effectNode ~= nil then
		self.effectNode:removeFromParent()
		self.effectNode = nil
	end
	local lastId = G_Me.sanguozhiData:getLastUsedId()
	for i,v in ipairs(self._mxButtonList) do
		v:setVisible(true)
		v:loadTextureNormal(G_Path.getSanguozhiIcon(self._listData[i].seen_icon))
		if v.showAsGray then
			v:showAsGray(self._listData[i].id > lastId)
		end
		if self._listData[i].id == (lastId + 1) then
			__Log("等于 lastId = %s",lastId)
			self:_addEffectNode(v)
		end
		self:registerBtnClickEvent(v:getName(),function()
			-- 播放动画
			local qipao = self._qipaoList[v:getName()]
			if qipao ~= nil then
				qipao:removeFromParentAndCleanup(true)
				qipao = nil
			end 
			local itemDesc = self._listData[i].seen_directions
			self._qipaoList[v:getName()] = self:_addQiPao(v,itemDesc,i~=5 and -10 or 0)
			if self._qipaoList[v:getName()] then
				self._qipaoList[v:getName()]:playQiPao(i==5)
			end
			end)
	end
	--奖励的气泡  道具名称
	local itemDesc = self._listData[5].seen_directions
	if itemDesc ~= nil then
		local button = self._mxButtonList[5]
		if self._qipaoList[button:getName()] ~= nil then
			self._qipaoList[button:getName()]:removeFromParentAndCleanup(true)
			self._qipaoList[button:getName()] = nil
		end
		self._qipaoList[button:getName()] = self:_addQiPao(self._mxButtonList[5],itemDesc)
	else
		if self._sanguozhiQiPao then
			self._sanguozhiQiPao:setVisible(false)
		end
	end
end

--[[
	text:文字
	diffY:y轴的差值,i~=5时有
]]
function SanguozhiPageViewItem:_addQiPao(widget,text,diffY)
	-- if not widget then
	-- 	return
	-- end
	-- local qipao = SanguozhiQiPao.new()
	-- if text then
	-- 	qipao:setText(text)
	-- end
	-- qipao:setVisible(true)
	-- local size = widget:getContentSize()
	-- diffY = diffY and diffY or 0

	-- if diffY == nil or type(diffY) ~= "number" then
	-- 	diffY = 0
	-- end

	-- point = ccp(widget:getPositionX()-0.26*size.width,widget:getPositionY() + size.height/2 + diffY)
	-- qipao:setPosition(point)
	-- self:addChild(qipao)
	local qipao = SanguozhiQiPao.add(text,widget,diffY)
	return qipao
end


function SanguozhiPageViewItem:_addEffectNode(widget)
	if widget == nil then
		return
	end
	if self.effectNode ~= nil then
		self.effectNode:removeFromParentAndCleanup(true)
		self.effectNode = nil
	end

	local EffectNode = require "app.common.effects.EffectNode"
	self.effectNode = EffectNode.new("effect_mx_light", function(event, frameIndex)
	        end)     
	self.effectNode:setScale(1.2)
	self.effectNode:play()
	local pt = self.effectNode:getPositionInCCPoint()
	self.effectNode:setPosition(ccp(pt.x, pt.y))
	widget:addNode(self.effectNode)
end


--[[
	
]]
function SanguozhiPageViewItem:startPlayEffect(layer,_id,callback)
	if self.effectNode ~= nil then
		self.effectNode:removeFromParent()
		self.effectNode = nil
	end

	--添加点亮动画
	self.effectNodeLight = EffectNode.new("effect_prepare_compose", function(event, frameIndex)
		if event == "finish" then
			if self.effectNodeLight ~= nil then
				self.effectNodeLight:removeFromParentAndCleanup(true)
				self.effectNodeLight = nil
			end

			if callback and type(callback) == "function" then
				callback()
			end
			self:refreshWidgets()

		end
		end)
	if not _id or type(_id) ~= "number" then
		return
	end
	self.effectNodeLight:play()
	local pt = self.effectNodeLight:getPositionInCCPoint()
	self.effectNodeLight:setPosition(ccp(pt.x, pt.y))
	local index = _id%5==0 and 5 or _id%5
	self._mxButtonList[index]:addNode(self.effectNodeLight)
	
end

return SanguozhiPageViewItem
