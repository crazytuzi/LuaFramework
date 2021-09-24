local SubGoodsUse=classGc(function(self,_goodsArray)
	self.m_goodsMagArray=_goodsArray
end)

local P_WinSize=cc.Director:getInstance():getWinSize()
local P_EndPos=cc.p(P_WinSize.width-300,250)
local P_TouchSize=cc.size(300,200)
local P_TouchRect=cc.rect(P_EndPos.x-P_TouchSize.width*0.5,P_EndPos.y-P_TouchSize.height*0.5,P_TouchSize.width,P_TouchSize.height)
local P_StartPos=cc.p(P_WinSize.width+P_TouchSize.width*0.5,P_EndPos.y)


function SubGoodsUse.create(self)
	_G.pmainView:getIconActivity():hideTaskGuideEffect()
	
	local nAction=cc.Sequence:create(cc.MoveTo:create(0.35,cc.p(P_EndPos.x-10,P_EndPos.y)),
                                    cc.MoveTo:create(0.1,cc.p(P_EndPos.x+5,P_EndPos.y)),
                                    cc.MoveTo:create(0.05,P_EndPos))
	self.m_rootNode=cc.Node:create()
	self.m_rootNode:setPosition(P_StartPos)
	self.m_rootNode:runAction(nAction)
	self:__initView()
	self:__showNextGoodsUse()

	return self.m_rootNode
end

function SubGoodsUse.__initView(self)
	local tempSpr=cc.Sprite:createWithSpriteFrameName("general_tubiaokuan.png")
	self.m_rootNode:addChild(tempSpr)

	local sprSize=tempSpr:getContentSize()

	local nameLabel=_G.Util:createBorderLabel("",18)
	nameLabel:setPosition(sprSize.width*0.5,sprSize.height+15)
	tempSpr:addChild(nameLabel)

	local function c(sender,eventType)
		if eventType == ccui.TouchEventType.ended then
			local nTag=sender:getTag()
			if nTag==1 and self.m_curUesData~=nil then
				local goodsMsg=self.m_curUesData.goodsMsg
				local msg=REQ_GOODS_USE()
                msg:setArgs(1,self.m_curUesData.uid or 0,goodsMsg.index,goodsMsg.goods_num)
                _G.Network:send(msg)

                if self.m_curUesData.uid~=nil then
                	_G.Util:playAudioEffect("ui_inventory_items")
                elseif goodsMsg.goods_type==_G.Const.CONST_GOODS_ORD then
                	local goodsCnf=_G.Cfg.goods[goodsMsg.goods_id]
                	if goodsCnf.type_sub==_G.Const.CONST_GOODS_COMMON_GIFT then
                        _G.Util:playAudioEffect("ui_opengift")
                    else
                        _G.Util:playAudioEffect("ui_props")
                    end
                end
            	self:__showNextGoodsUse()
            	return
			end
			self:closeWindow()
		end
	end
	local useBtn=gc.CButton:create("general_btn_gold.png")
	useBtn:setPosition(sprSize.width*0.5,-23)
	useBtn:addTouchEventListener(c)
	useBtn:setTitleFontSize(24)
    useBtn:setTitleText("使 用")
    useBtn:setTitleFontName(_G.FontName.Heiti)
	useBtn:setButtonScale(0.7)
	useBtn:setTag(1)
	tempSpr:addChild(useBtn)

	local closeBtn=gc.CButton:create("general_close_2.png")
	closeBtn:setPosition(sprSize.width+25,sprSize.height*0.5)
	closeBtn:addTouchEventListener(c)
	closeBtn:setTag(2)
	tempSpr:addChild(closeBtn)

	local myLv=_G.GPropertyProxy:getMainPlay():getLv()
	if myLv<=_G.Const.CONST_NEW_GUIDE_LV_EQUIP then
		local goodsMsg=self.m_goodsMagArray[1].goodsMsg
		if goodsMsg.goods_type==_G.Const.CONST_GOODS_EQUIP or goodsMsg.goods_type==_G.Const.CONST_GOODS_WEAPON then
			local effectSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_box_choice.png")
			effectSpr:setPreferredSize(cc.size(120,180))
			effectSpr:setPosition(sprSize.width*0.5,sprSize.height*0.5-5)
			effectSpr:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeTo:create(0.5,150),cc.FadeTo:create(0.5,255))))
			tempSpr:addChild(effectSpr,-1)

			if myLv<=2 then
				local btnSize=useBtn:getContentSize()
				local guideNode=_G.GGuideManager:createTouchNode()
			    guideNode:setPosition(btnSize.width*0.5,btnSize.height*0.5)
			    useBtn:addChild(guideNode,100)

				local noticNode=_G.GGuideManager:createNoticNode("好棒的装备，快换上",true)
	            noticNode:setPosition(-160,-5)
	            effectSpr:addChild(noticNode)
			end
		end
	end

	self.m_goodsNameLb=nameLabel
	self.m_goodsFramSpr=tempSpr
	self.m_framSize=sprSize
end

function SubGoodsUse.__showNextGoodsUse(self)
	self.m_curUesData=table.remove(self.m_goodsMagArray,1)

	if self.m_curUesData==nil then
		self:closeWindow()
	else
		local goodsId=self.m_curUesData.goodsMsg.goods_id
		local goodsCnf=_G.Cfg.goods[goodsId] or _G.Cfg.goods[1001]

		if self.m_goodsIconSpr~=nil then
			self.m_goodsIconSpr:removeFromParent(true)
			self.m_goodsIconSpr=nil
		end
		local iconSpr=_G.ImageAsyncManager:createGoodsSpr(goodsCnf,self.m_curUesData.goodsMsg.goods_num)
		iconSpr:setPosition(self.m_framSize.width*0.5,self.m_framSize.height*0.5)
		self.m_goodsFramSpr:addChild(iconSpr)
		self.m_goodsIconSpr=iconSpr

		self.m_goodsNameLb:setString(goodsCnf.name)
	end
end

function SubGoodsUse.addSomeGoodsToUse(self,_goodsArray)
	for i=1,#_goodsArray do
		local addGoodsMsg=_goodsArray[i].goodsMsg
		local addUid=_goodsArray[i].uid
		local curGoodsMsg=self.m_curUesData.goodsMsg

		if curGoodsMsg.index==addGoodsMsg.index then
			if curGoodsMsg.goods_id==addGoodsMsg.goods_id and curGoodsMsg.goods_num~=addGoodsMsg.goods_num then
				if self.m_goodsIconSpr~=nil then
					self.m_goodsIconSpr:removeFromParent(true)
					self.m_goodsIconSpr=nil
				end

				local goodsCnf=_G.Cfg.goods[addGoodsMsg.goods_id]
				local iconSpr=_G.ImageAsyncManager:createGoodsSpr(goodsCnf,addGoodsMsg.goods_num)
				iconSpr:setPosition(self.m_framSize.width*0.5,self.m_framSize.height*0.5)
				self.m_goodsFramSpr:addChild(iconSpr)
				self.m_goodsIconSpr=iconSpr

				self.m_curUesData.goodsMsg=addGoodsMsg
			end
		else
			local curCount=#self.m_goodsMagArray
			local isSameGoods=false
			for i=1,curCount do
				local forMsg=self.m_goodsMagArray[i].goodsMsg
				if forMsg.index==addGoodsMsg.index then
					isSameGoods=true
					self.m_goodsMagArray[i].goodsMsg=addGoodsMsg
					break
				end
			end
			if not isSameGoods then
				local tempT={
					goodsMsg=addGoodsMsg,
					uid=addUid
				}
				curCount=curCount+1
				self.m_goodsMagArray[curCount]=tempT
			end
		end
	end
end
function SubGoodsUse.delGoodsToUse(self,_goodsMsg)
	if _goodsMsg.index==self.m_curUesData.goodsMsg.index then
		self:__showNextGoodsUse()
	else
		local curCount=#self.m_goodsMagArray
		for i=1,curCount do
			local tempMsg=self.m_goodsMagArray[i].goodsMsg
			if tempMsg.index==_goodsMsg.index then
				table.remove(self.m_goodsMagArray,i)
				break
			end
		end
	end
end

function SubGoodsUse.closeWindow(self)
	if self.m_rootNode==nil then return end

	self.m_rootNode:removeFromParent(true)
	self.m_rootNode=nil

	local command=CMainUiCommand(CMainUiCommand.SUBVIEW_FINISH)
    _G.controller:sendCommand(command)

    _G.pmainView:getIconActivity():showTaskGuideEffect()
end

return SubGoodsUse