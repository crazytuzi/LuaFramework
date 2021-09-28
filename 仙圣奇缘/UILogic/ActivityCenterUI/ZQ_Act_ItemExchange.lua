--------------------------------------------------------------------------------------
-- 文件名:	XXX.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	张齐
-- 日  期:	2016-8-15
-- 版  本:	1.0
-- 描  述:	道具兑换礼包
-- 应  用:  
---------------------------------------------------------------------------------------
Act_ItemExchange = class("Act_ItemExchange",Act_Template)
Act_ItemExchange.__index = Act_Template
Act_ItemExchange.szImage_RewardStatus = "Image_BuyStatus"

--设置兑换礼包所需要的道具
function Act_ItemExchange:setNeedItem(widget,index, tbNeedItem)
	local itemModel = g_CloneDropItemModel(tbNeedItem)
	widget:removeAllChildren()
	if itemModel then
		itemModel:setPositionXY(45,45)
		itemModel:setScale(0.7)
		widget:addChild(itemModel)

		local function onClick(pSender, eventType)
			if eventType == ccs.TouchEventType.ended then
				g_ShowDropItemTip(tbNeedItem)
			end
		end
		itemModel:setTouchEnabled(true)
		itemModel:addTouchEventListener(onClick)
	end
end 

--设置每个按钮列表项
function Act_ItemExchange:setPanelItem(widget,index)
    local buttonItem = tolua.cast(widget:getChildByName("Button_Activety"), "Button")
    local image_Tip = buttonItem:getChildByName("Image_Tip")
	local label_Tip = tolua.cast(image_Tip:getChildByName("Label_Tip"), "Label")
	label_Tip:setText(self.tbItemList[index]["Desc"])

    --折扣显示
    local BitmapLabel_Discount = tolua.cast(buttonItem:getChildByName("BitmapLabel_Discount"), "LabelBMFont")
	BitmapLabel_Discount:setText(self.tbItemList[index]["Discount"])

    --当前可领取次数
    local Label_Remain = tolua.cast(buttonItem:getChildByName("Label_Remain"), "Label")
    local cur_buy = g_act:getActValueByID(self.nActivetyID)
    local strTip = string.format(_T("剩余:%d/%d"), cur_buy[self.tbItemList[index]["ID"]], self.tbItemList[index]["LimitCount"])
    Label_Remain:setText(strTip)

    --礼包内容
    local listView_DropItem = tolua.cast(buttonItem:getChildByName("ListView_DropItemTarget"), "ListViewEx")
    local dropItem = listView_DropItem:getChildByName("Panel_DropItem")
	local tbDropItemList = g_DataMgr:getCsvConfig_SecondKeyTableData("DropSubPackClient", self.tbItemList[index]["DropClientID"])
	local function updateFunc(widget,index)
		return self:setDropItem(widget, index, tbDropItemList[index])
	end
	registerListViewEvent(listView_DropItem, dropItem, updateFunc, #tbDropItemList)
    if #tbDropItemList <= 3 then
		listView_DropItem:setBounceEnabled(false)
		listView_DropItem:setTouchEnabled(false)
	end 
    
    --兑换该礼包需要的道具
    local tbNeedItemList = {}
    if self.tbItemList[index]["NeedCurrencyNum"] > 0 then
        local num = #tbNeedItemList + 1 
        tbNeedItemList[num] = {}
        tbNeedItemList[num].DropItemType = self.tbItemList[index]["NeedCurrencyType"]
        tbNeedItemList[num].DropItemID = 0
        tbNeedItemList[num].DropItemStarLevel = 5
        tbNeedItemList[num].DropItemNum = self.tbItemList[index]["NeedCurrencyNum"] 
        tbNeedItemList[num].DropItemEvoluteLevel  = 0
    end

    if self.tbItemList[index]["ItemBaseNum"] > 0 then
        local num = #tbNeedItemList + 1 
        tbNeedItemList[num] = {}
        tbNeedItemList[num].DropItemType = macro_pb.ITEM_TYPE_MATERIAL
        tbNeedItemList[num].DropItemID = self.tbItemList[index]["ItemBaseId"]
        tbNeedItemList[num].DropItemStarLevel = self.tbItemList[index]["ItemBaseStarLevel"]
        tbNeedItemList[num].DropItemNum = self.tbItemList[index]["ItemBaseNum"] 
        tbNeedItemList[num].DropItemEvoluteLevel  = 0
    end

    local listView_NeedItem = tolua.cast(buttonItem:getChildByName("ListView_DropItemSource"), "ListViewEx")
    local needItem = listView_NeedItem:getChildByName("Panel_DropItem")
    local Image_Arrow = buttonItem:getChildByName("Image_Arrow")
    local function updateFunc(widget,index)
		return self:setNeedItem(widget, index, tbNeedItemList[index])
	end
	registerListViewEvent(listView_NeedItem, needItem, updateFunc, #tbNeedItemList)
    if #tbNeedItemList == 0 then
        listView_NeedItem:setVisible(false) 
        Image_Arrow:setVisible(false)
        listView_DropItem:setPositionX(listView_NeedItem:getPositionX())   
    else  
        if #tbNeedItemList <= 2 then
		    listView_NeedItem:setBounceEnabled(false)
		    listView_NeedItem:setTouchEnabled(false)
            Image_Arrow:setPositionX(self.f_Image_Arrow_X - 180 + #tbNeedItemList*90)
            listView_DropItem:setPositionX(self.f_listView_DropItem_X - 180 + #tbNeedItemList*90)
	    end
    end

	local button_GetReward = tolua.cast(buttonItem:getChildByName("Button_GetReward"), "Button")
	if button_GetReward then
		button_GetReward:setTag(index)
		button_GetReward:addTouchEventListener(handler(self,self.onClickGainReward))
		local image_RewardStatus = tolua.cast(button_GetReward:getChildByName("Image_RewardStatus"), "ImageView")
		local Image_RewardStatusYiLing = tolua.cast(buttonItem:getChildByName("Image_RewardStatusYiLing"), "ImageView")
		local state = self.tbMissions[self.tbItemList[index].ID]

		self:setButtonState(buttonItem, state)
	end
    
end

--初始化
function Act_ItemExchange:init(panel, tbItemList)
	if not panel then
		return 
	end
    self.f_Image_Arrow_X = -130
    self.f_listView_DropItem_X = -85
	self.super.init(self, panel, tbItemList)
end