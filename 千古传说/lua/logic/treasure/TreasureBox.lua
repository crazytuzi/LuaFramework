--宝箱界面

local TreasureBox = class("TreasureBox",BaseLayer)

function TreasureBox:ctor(data)
	self.super.ctor(self, data)
	self:init("lua.uiconfig_mango_new.treasure.BaoXiangLayer")
end

function TreasureBox:initUI( ui )
	self.super.initUI(self,ui)
	self.btn_boxs ={}
	self.posXs ={}
	for i=1,5 do
    	local box = TFDirector:getChildByPath(ui, 'img_baoxiang'..i)
    	local posX = box:getPosition().x
    	local txt_numb = TFDirector:getChildByPath(box,"txt_numb")
    	table.insert(self.btn_boxs,{box = box,txt_numb = txt_numb})
    	table.insert(self.posXs,posX)
	end
	
	self.txt_count = TFDirector:getChildByPath(ui,"txt_numb_count")
end

function TreasureBox:loadData(boxCounts,round,boxIndex,count,boxRewardList)
	self.boxCounts = boxCounts
	self.boxIndex = boxIndex
	self.round = round
	self.count = count
	self.rewardList = {}
    for i=1,#boxRewardList do
   		table.insert(self.rewardList,boxRewardList[i].boxReward)
   	end

	self:refreshUI()
end
function TreasureBox:refreshUI()
    --local number = self.boxCounts[5]
	for k,v in pairs(self.btn_boxs) do
		if k > self.boxIndex then
			local count = self.boxCounts[k] +  self.round * self.boxCounts[5]
			--v.txt_numb:setText( string.format(localizable.treasureMain_text3 ,count))
			v.txt_numb:setText( stringUtils.format(localizable.treasureMain_text3 ,count))						
			v.box.count = count
		else
			local count = self.boxCounts[k] +  (self.round + 1)* self.boxCounts[5]
			v.txt_numb:setText(stringUtils.format(localizable.treasureMain_text3 ,count)) 
			v.box.count = count
		end       
	end
	--local count = 
	self.new_btn_boxs = {}
  --  self.newBoxCounts = {}
	for i=self.boxIndex + 1,5 do
		table.insert(self.new_btn_boxs, self.btn_boxs[i].box)
	end
	for i=1,self.boxIndex do
		table.insert(self.new_btn_boxs, self.btn_boxs[i].box)
	end

	for i=1,5 do
		self.new_btn_boxs[i]:setPositionX(self.posXs[i])    
	end

	local open_state = true 
	local count = self.new_btn_boxs[1].count
	if self.count < count then
		open_state = false
	end	
	CommonManager:setRedPoint(self.new_btn_boxs[1], open_state,"boxOpen",ccp(-6,-12)) 
	
	for i=2,5 do
		CommonManager:setRedPoint(self.new_btn_boxs[i], false,"boxOpen",ccp(-6,-12)) 
	end

	self.txt_count:setText(self.count)
end

function TreasureBox:setData(round,boxIndex,count)
    self.boxIndex = boxIndex
	self.round = round
	self.count = count
    self:refreshUI()
end

function TreasureBox.onBtnBox(sender)
	local self = sender.logic
	local index = sender.index
	
	
	if self.boxIndex + 1 == index then
		if self.count >= sender.count then
        	TreasureManager:requestBoxReward(self.boxIndex + 1)
        else
        	local layer = require("lua.logic.treasure.TreasureRewardShow"):new()
		    layer:setRewardList(self.rewardList[index])
		    AlertManager:addLayer(layer,AlertManager.BLOCK_AND_GRAY_CLOSE,AlertManager.TWEEN_1)
		    AlertManager:show()
    	end
	else
		local layer = require("lua.logic.treasure.TreasureRewardShow"):new()
	    layer:setRewardList(self.rewardList[index])
	    AlertManager:addLayer(layer,AlertManager.BLOCK_AND_GRAY_CLOSE,AlertManager.TWEEN_1)
	    AlertManager:show()
	end	
	
end

function TreasureBox:removeUI()
   	self.super.removeUI(self)  
end

function TreasureBox:onShow()
    self.super.onShow(self)
end

function TreasureBox:registerEvents()
	self.super.registerEvents(self)
    for k,v in pairs(self.btn_boxs) do
    	v.box:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onBtnBox))
    	v.box.logic = self
    	v.box.index = k
    end

   self.onBoxResult = function(event)
        print("onOnceResult------------")
        print(event)
        self.round = event.data[1].round
        self.boxIndex = event.data[1].boxIndex
        self:refreshUI()
    end
    TFDirector:addMEGlobalListener(TreasureManager.BoxMessage,self.onBoxResult)

end

function TreasureBox:removeEvents()
	self.super.removeEvents(self)
    TFDirector:removeMEGlobalListener(TreasureManager.BoxMessage,self.onBoxResult)
end


function TreasureBox:dispose()
    self.super.dispose(self)
end

return TreasureBox