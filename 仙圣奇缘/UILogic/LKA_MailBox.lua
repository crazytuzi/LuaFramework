--------------------------------------------------------------------------------------
-- 文件名: LKA_MailBox.lua
-- 版  权:    (C)深圳美天互动科技有限公司
-- 创建人: 	陆奎安
-- 日  期:    2013-2-12 9:37
-- 版  本:    1.0
-- 描  述:    图鉴界面
-- 应  用:  本例子是用类对象的方式实现
---------------------------------------------------------------------------------------
Game_MailBox = class("Game_MailBox")
Game_MailBox.__index = Game_MailBox

function Game_MailBox:requestRelationSendMsg(tbId)
	local tbServerMsg = zone_pb.DelMailRequest()
	for key, value in ipairs(tbId) do
		table.insert(tbServerMsg.mail_id, value)
	end
	g_MsgMgr:sendMsg(msgid_pb.MSGID_DELMAIL_REQUEST, tbServerMsg)
end

local currenListViewIdex = 0

function getConfigMgrMailItem()
	return g_Mail.tb_ConfigMgrMailItem
end

function Game_MailBox:ItemReadResponse(mail_id)
	for i,v in ipairs(g_Mail.tb_ConfigMgrMailItem)do
		if mail_id == v.mail_id then
			g_Mail.tb_ConfigMgrMailItem[i].gain_flag = 1
			--g_DbMgr:insert(g_Mail.tableName, mail_id, tableToString(g_Mail.tb_ConfigMgrMailItem[i]))
			g_DbMgr:exec("update "..g_Mail.tableName.." set buffer ='"..tableToString(g_Mail.tb_ConfigMgrMailItem[i]).."' where id ="..mail_id)
		end
	end
end

function Game_MailBox:delMailResponse(tbMailid)
	for i,v in ipairs(g_Mail.tb_ConfigMgrMailItem)do
		for j,mail_id in ipairs(tbMailid.mail_id)do
			if v.mail_id == mail_id then
				table.remove(g_Mail.tb_ConfigMgrMailItem,i)
                g_Mail.tb_ConfigMgrMailItemById[mail_id] = nil
                g_DbMgr:exec("delete from "..g_Mail.tableName.." where id ="..mail_id)
			end
		end
	end 
    self.curMailBoxItem = nil
	self.LuaListView_MailBox:updateItems(#g_Mail.tb_ConfigMgrMailItem,currenListViewIdex)
	if #g_Mail.tb_ConfigMgrMailItem == 0 then
		self.Image_MailIsEmpty:setVisible(true)
		self:setMailBoxContentPNL(1)
	end
end

function Game_MailBox:ItemRewardResponse(mail_id)
	for i,v in ipairs(g_Mail.tb_ConfigMgrMailItem)do
		if mail_id == v.mail_id then
			g_Mail.tb_ConfigMgrMailItem[i].gain_flag = 1
			--g_DbMgr:insert(g_Mail.tableName, mail_id, tableToString(g_Mail.tb_ConfigMgrMailItem[i]))
			g_DbMgr:exec("update "..g_Mail.tableName.." set buffer ='"..tableToString(g_Mail.tb_ConfigMgrMailItem[i]).."' where id ="..mail_id)
		end
		if curMailId == v.mail_id then
			self:setGainFlagStatus(1)
            local Panel_MailBoxItem = self.LuaListView_MailBox:getChildByIndex(i-1)
            if Panel_MailBoxItem then
				local Button_MailBoxItem = tolua.cast(Panel_MailBoxItem:getChildByName("Button_MailBoxItem"), "Button")
				Button_MailBoxItem:setTag(mail_id)
			    local Label_AttachmentTip = tolua.cast(Button_MailBoxItem:getChildByName("Label_AttachmentTip"), "Label")
			    Label_AttachmentTip:setText(_T("(附件已领取)"))
				self:set_Button_MailBoxItem(Button_MailBoxItem, i, 1)
			end
		    g_Hero:addBubbleNotify("mail", -1)
		    
		end
	end
end

function Game_MailBox:setGainFlagStatus(nGainFlag)
	local nGainFlag = nGainFlag or 0
	if nGainFlag == 1 then
		self.Button_Accept:setVisible(false)
		self.Button_Delete:setVisible(true)
		self.LuaListView_DropItem:updateItems(0)
	else
		self.Button_Accept:setVisible(true)
		self.Button_Delete:setVisible(false)
	end
end

-- add by zgj
function Game_MailBox:setDropItem(widget,index)
	local itemModel = g_CloneDropItemModel(self.tbDropItemList[index])
	widget:removeAllChildren()
	if itemModel then
		itemModel:setPositionXY(50,55)
		itemModel:setScale(0.8)
		widget:addChild(itemModel)

		local function onClick(pSender, eventType)
			if eventType == ccs.TouchEventType.ended then
				g_ShowDropItemTip(self.tbDropItemList[index])
			end
		end
		itemModel:setTouchEnabled(true)
		itemModel:addTouchEventListener(onClick)
	end
end
--over

function Game_MailBox:setButtonAttachItem(tb_drop_result, nGainFlag, is_visible)
	self.tbDropItemList = {}
	local bDrop = false
    if tb_drop_result then
    	if tb_drop_result.drop_lst then
		    for k, v in ipairs(tb_drop_result.drop_lst) do
			    local tbDropList = {}
			    tbDropList.DropItemType = v.drop_item_type or 0
			    tbDropList.DropItemID = v.drop_item_config_id or 0
				if v.drop_item_star_lv and v.drop_item_star_lv <= 0 then
					v.drop_item_star_lv = 1
				end
			    tbDropList.DropItemStarLevel = v.drop_item_star_lv or 0
			    tbDropList.DropItemNum = v.drop_item_num or 0
			    tbDropList.DropItemEvoluteLevel = v.drop_item_blv or 0
			    table.insert(self.tbDropItemList, tbDropList)
		    end
		    self.LuaListView_DropItem:updateItems(#self.tbDropItemList)
		    bDrop = true
		else
            self.LuaListView_DropItem:removeAllChildren()
        end
    else
        self.LuaListView_DropItem:removeAllChildren()
        return
    end

	local nGainFlag = nGainFlag or 0

	if nGainFlag ==1 then
		self.Button_Accept:setVisible(false)
		self.Button_Delete:setVisible(true)
		self.LuaListView_DropItem:updateItems(0)	
	else
		self.Button_Accept:setVisible(true)
		if bDrop then
			self.BitmapLabel_FuncName:setText(_T("领取奖励"))
		else
			self.BitmapLabel_FuncName:setText(_T("确定"))
		end
		self.Button_Delete:setVisible(false)	
	end
	
end

function getMsgContent(tbServerMsg)
	local text = g_initMsgContent(tbServerMsg.mail_context, 38, tbServerMsg.str_param, tbServerMsg.data_param) 
	return text
end

function Game_MailBox:setMailBoxContentPNL(nIndex)
	local Image_MailBoxContentPNL = tolua.cast(self.rootWidget:getChildByName("Image_MailBoxContentPNL"), "ImageView")
	
	local Image_TitlePNL = tolua.cast(Image_MailBoxContentPNL:getChildByName("Image_TitlePNL"), "ImageView")
	local Label_Title = tolua.cast(Image_TitlePNL:getChildByName("Label_Title"), "Label")
	local Label_ReceivedDate = tolua.cast(Image_TitlePNL:getChildByName("Label_ReceivedDate"), "Label")
	
	local Image_ContentPNL = tolua.cast(Image_MailBoxContentPNL:getChildByName("Image_ContentPNL"), "ImageView")
	local ScrollView_Content = tolua.cast(Image_ContentPNL:getChildByName("ScrollView_Content"), "ScrollView")
	local Label_Content = tolua.cast(ScrollView_Content:getChildByName("Label_Content"), "Label")
	
	self.Button_Accept = tolua.cast(Image_MailBoxContentPNL:getChildByName("Button_Accept"), "Button")
	self.BitmapLabel_FuncName = tolua.cast(self.Button_Accept:getChildByName("BitmapLabel_FuncName"), "LabelBMFont")
	self.Button_Delete = tolua.cast(Image_MailBoxContentPNL:getChildByName("Button_Delete"), "Button")

	local tbServerMsg = g_Mail.tb_ConfigMgrMailItem[nIndex]
	
	if not tbServerMsg then 
		Label_Title:setText("")
		Label_ReceivedDate:setText("")
		Label_Content:setText("")
		self.Button_Accept:setVisible(false)
		self.Button_Delete:setVisible(false) 
		self:setButtonAttachItem(nil,nil,false)
		return 
	end 
	curMailId = tbServerMsg.mail_id
	if tbServerMsg.gain_flag ==0 and   tbServerMsg.drop_result and tbServerMsg.drop_result[1] then
		self.Button_Accept:setVisible(true)
		self.Button_Delete:setVisible(false)
	else
		self.Button_Accept:setVisible(false)
		self.Button_Delete:setVisible(true)
	end
	
	if tbServerMsg.read_flag == 1 then
		g_MsgMgr:MailReadRequest(tbServerMsg.mail_id)
	end
	Label_Title:setText(tbServerMsg.mail_tile)
	Label_Content:setText(getMsgContent(tbServerMsg)) 

	self:setButtonAttachItem(tbServerMsg.drop_result,tbServerMsg.gain_flag)
	local size = Label_Content:getSize()
	local ScrollHeight = 190
	if size.height > ScrollHeight then
		ScrollHeight = size.height
	end 
	self.ScrollView_Content:setInnerContainerSize(CCSizeMake(500,ScrollHeight))
	Label_Content:setPosition(ccp(5,ScrollHeight - 5))
	
	local timeDateY = os.date("%Y", tbServerMsg.timestamp ) 
	local timeDateM = os.date("%m", tbServerMsg.timestamp)
	local timeDateD = os.date("%d", tbServerMsg.timestamp)
	local timeDate = timeDateY.."-"..timeDateM.."-"..timeDateD
	Label_ReceivedDate:setText(timeDate)
end

function Game_MailBox:set_Button_MailBoxItem(Button_MailBoxItem, nIndex, nGainFlag)
	local nMailId = Button_MailBoxItem:getTag()

	local function onPressing_Button_MailBoxItem(pSender, nTag)
		if nGainFlag == 0 then
			g_ClientMsgTips:showMsgConfirm(_T("您还有未领取的附件, 邮件无法被删除"))
			return
		end
		
		local function onPressed_Confirm()
			local tbId = {}
			table.insert(tbId, nMailId)
			self:requestRelationSendMsg(tbId) 
		end
		g_ClientMsgTips:showConfirm(_T("删除邮件之后将不可被恢复, 是否确认删除？"), onPressed_Confirm, nil)
	end
	
	local function onPressed_Button_MailBoxItem(pSender, nTag)
		self.LuaListView_MailBox:scrollToTop(nIndex)
	end
	 g_SetBtnWithPressingEvent(Button_MailBoxItem, nMailId, nil, onPressed_Button_MailBoxItem, nil, true, 0.25)
end

function Game_MailBox:onUpdate_ListView_MailBox(Panel_MailBoxItem, nIndex)
	local tbServerMsg = g_Mail.tb_ConfigMgrMailItem[nIndex]
	if not tbServerMsg then 
		return 
	end 
	local mail_type = tbServerMsg.mail_type or 0
	
	local Button_MailBoxItem = tolua.cast(Panel_MailBoxItem:getChildByName("Button_MailBoxItem"), "Button")
	
	local Label_TitleName = tolua.cast(Button_MailBoxItem:getChildByName("Label_TitleName"), "Label")
	Label_TitleName:setText(tbServerMsg.mail_tile)
	
	local Label_Receive = tolua.cast(Button_MailBoxItem:getChildByName("Label_Receive"), "Label")
	Label_Receive:setText(getStrTime(tbServerMsg.timestamp))
	
	g_SetBtnWithEvent(Button_MailBoxItem, tbServerMsg.mail_id, nil, true)
	
	if not self.curMailBoxItem then
	
	else
		self.curMailBoxItem:loadTextureNormal(getUIImg("ListItem_Mail"))
		self.curMailBoxItem:loadTexturePressed(getUIImg("ListItem_Mail_Press"))
		self.curMailBoxItem:loadTextureDisabled(getUIImg("ListItem_Mail"))
	end
	if currenListViewIdex == nIndex then
		self.curMailBoxItem = Button_MailBoxItem
		self.curMailBoxItem:loadTextureNormal(getUIImg("ListItem_Mail_Check"))
		self.curMailBoxItem:loadTexturePressed(getUIImg("ListItem_Mail_Check_Press"))
		self.curMailBoxItem:loadTextureDisabled(getUIImg("ListItem_Mail_Check"))
	else
		Button_MailBoxItem:loadTextureNormal(getUIImg("ListItem_Mail"))
		Button_MailBoxItem:loadTexturePressed(getUIImg("ListItem_Mail_Press"))
		Button_MailBoxItem:loadTextureDisabled(getUIImg("ListItem_Mail"))
	end
	
	local Label_AttachmentTip = tolua.cast(Button_MailBoxItem:getChildByName("Label_AttachmentTip"), "Label")
	if tbServerMsg.gain_flag == 0 and  tbServerMsg.drop_result then
		Label_AttachmentTip:setText(_T("(附件未领取)"))
	elseif tbServerMsg.gain_flag == 1 and tbServerMsg.drop_result then
		Label_AttachmentTip:setText(_T("(附件已领取)"))
	else
		Label_AttachmentTip:setText(_T("(无附件)"))
	end
	
	self:set_Button_MailBoxItem(Button_MailBoxItem, nIndex, tbServerMsg.gain_flag)
	
	local CSV_MailBox = g_DataMgr:getCsvConfig_FirstKeyData("MailBox", tbServerMsg.mail_cfg_id)
	local Image_MailIcon = tolua.cast(Button_MailBoxItem:getChildByName("Image_MailIcon"), "ImageView")
	local Image_Icon = tolua.cast(Image_MailIcon:getChildByName("Image_Icon"), "ImageView")
	if CSV_MailBox.ID > 0 then
		Image_Icon:loadTexture(getIconImg(CSV_MailBox.Icon))
	else
		Image_Icon:loadTexture(getIconImg("System_Mail"))
	end

	if eLanguageVer.LANGUAGE_viet_VIET == g_LggV:getLanguageVer() then
		Label_TitleName:setFontSize(19)
		Label_Receive:setFontSize(19)
		Label_AttachmentTip:setFontSize(19)
	end
end

------------initListViewListEx---------
function Game_MailBox:register_ListView_MailBox(ListView_MailBox, itemModel)
    local LuaListView_MailBox = Class_LuaListView:new()
    LuaListView_MailBox:setListView(ListView_MailBox)

    local function onAdjust_ListView_MailBox(Panel_MailBoxItem, nIndex)
		currenListViewIdex = nIndex
		self:onUpdate_ListView_MailBox(Panel_MailBoxItem, nIndex)
		self:setMailBoxContentPNL(nIndex)
    end
    LuaListView_MailBox:setUpdateFunc(handler(self, self.onUpdate_ListView_MailBox))
    LuaListView_MailBox:setAdjustFunc(onAdjust_ListView_MailBox)
    LuaListView_MailBox:setModel(itemModel)
    self.LuaListView_MailBox = LuaListView_MailBox
end

function MailResponse(tb_SeverMailmsg)
	local receipt_msg = zone_pb.MailRevRequest() --回执
	for i,tbMailInfo in ipairs(tb_SeverMailmsg.mail_info)do
		
		if not tbMailInfo then return end
		if tbMailInfo.mail_context == "" then
			local CSV_MailBox = g_DataMgr:getCsvConfig_FirstKeyData("MailBox", tbMailInfo.mail_cfg_id)
			tbMailInfo.mail_context = CSV_MailBox.Content
			tbMailInfo.mail_tile = CSV_MailBox.Name
            if tbMailInfo.mail_cfg_id == 8 and g_strAndroidTS == "open" then
                tbMailInfo.mail_context = "感谢您来到这个丰富多彩的修仙世界，除了丰富精彩\\n的游戏内容外，还有贴心客服为您服务。\\n客服电话：4006668223\\n客服邮箱：800069894@qq.com"
            end
            if g_bVersionAndroid_0_0_ == "jinli_1.0.1" then
                tbMailInfo.mail_context = "感谢您来到这个丰富多彩的修仙世界，除了丰富精彩\\n的游戏内容外，还有贴心客服为您服务。\\n客服邮箱：800069894@qq.com"
            end
		end

		table.insert(receipt_msg.mail_id, tbMailInfo.mail_id)

		local szBuffer = tostring(tbMailInfo)
		szBuffer = string.sub(szBuffer,11, string.len(szBuffer))
        local getMailFunc = loadstring("return "..szBuffer)
        if getMailFunc then
            local tbMail = getMailFunc()
            --if not tbMail.drop_result.drop_lst then
			g_DbMgr:insert(g_Mail.tableName, tbMail.mail_id, szBuffer)
		    --end
		    --if not g_Mail.tb_ConfigMgrMailItemById[tbMail.mail_id] then
			g_Hero:addBubbleNotify("mail", 1)
		    --end
		    g_Mail.tb_ConfigMgrMailItemById[tbMail.mail_id] = tbMail
        else
            cclog("mail_id为"..tbMailInfo.mail_id.."的邮件转换为table错误")
        end
	end
    if #tb_SeverMailmsg.mail_info ~= 0 then
	    g_MsgMgr:sendMsg(msgid_pb.MSGID_MAIL_REV_REQUEST,receipt_msg)
    end
	g_Mail.update = true
	local wnd = g_WndMgr:getWnd("Game_MailBox")
	if wnd then
		wnd:openWnd()
	end

	local wndHome = g_WndMgr:getWnd("Game_Home")
	if wndHome then

        wndHome:shouFunctionsByLevel()

		wndHome:addNoticeAnimation_Mail()
	end

end

--初始化界面
function Game_MailBox:setCMailBoxWnd()
	currenListViewIdex = 0
	local Image_MailBoxPNL = tolua.cast(self.rootWidget:getChildByName("Image_MailBoxPNL"), "ImageView")
	local ListView_MailBox = tolua.cast(Image_MailBoxPNL:getChildByName("ListView_MailBox"), "ListViewEx")
	local imgScrollSlider = ListView_MailBox:getScrollSlider()
	if not g_tbScrollSliderXY.ListView_MailBox_X then
		g_tbScrollSliderXY.ListView_MailBox_X = imgScrollSlider:getPositionX()
	end
	imgScrollSlider = imgScrollSlider:setPositionX(g_tbScrollSliderXY.ListView_MailBox_X - 8)
	
	local Image_MailBoxContentPNL = tolua.cast(self.rootWidget:getChildByName("Image_MailBoxContentPNL"), "ImageView")
	local Image_ContentPNL = tolua.cast(Image_MailBoxContentPNL:getChildByName("Image_ContentPNL"), "ImageView")

	self:register_ListView_MailBox(ListView_MailBox, g_WidgetModel.Panel_MailBoxItem)
	self.ScrollView_Content = tolua.cast(Image_ContentPNL:getChildByName("ScrollView_Content"), "ScrollView")
	self.ScrollView_Content:setTouchEnabled(true)
	self.ScrollView_Content:setClippingEnabled(true)
	
	local Button_Accept = tolua.cast(Image_MailBoxContentPNL:getChildByName("Button_Accept"), "Button")
	local function onClickAccept()
		g_MsgMgr:MailRewardRequest(curMailId) 
	end
	g_SetBtnWithGuideCheck(Button_Accept, 1, onClickAccept, true)
	
	local Button_Delete = tolua.cast(Image_MailBoxContentPNL:getChildByName("Button_Delete"), "Button")
	local function onClickDelete()
		local function onClick_Confirm()
			local tbId = {}
			table.insert(tbId,curMailId)
			self:requestRelationSendMsg(tbId)
		end
		g_ClientMsgTips:showConfirm(_T("删除邮件之后将不可恢复, 是否确认删除?"), onClick_Confirm)
	end
	g_SetBtnWithGuideCheck(Button_Delete, 1, onClickDelete, true)

	self.Image_MailIsEmpty = tolua.cast(Image_MailBoxPNL:getChildByName("Image_MailIsEmpty"), "ImageView")
end

local function MailSort(tb1,tb2)
	return tb1.mail_id > tb2.mail_id
end

function Game_MailBox:setConfigMgrMailItem()
	g_Mail.tb_ConfigMgrMailItem = {}
	for i,v in pairs(g_Mail.tb_ConfigMgrMailItemById)do
		table.insert(g_Mail.tb_ConfigMgrMailItem,v)
	end
	if  #g_Mail.tb_ConfigMgrMailItem >= 2 then
		table.sort(g_Mail.tb_ConfigMgrMailItem,MailSort)
	end
end

function Game_MailBox:initWnd()
	local Image_MailBoxContentPNL = tolua.cast(self.rootWidget:getChildByName("Image_MailBoxContentPNL"), "ImageView")
	local ListView_DropItem = tolua.cast(Image_MailBoxContentPNL:getChildByName("ListView_DropItem"), "ListViewEx")
	local Panel_DropItem = ListView_DropItem:getChildByName("Panel_DropItem")
	self.LuaListView_DropItem = registerListViewEvent(ListView_DropItem, Panel_DropItem, handler(self,self.setDropItem))
	self.LuaListView_DropItem:removeAllChildren()

	self:setCMailBoxWnd()
end

--打开界面调用
function Game_MailBox:openWnd()
	self:setMailBoxInfo()
end

function Game_MailBox:closeWnd()
	self.curMailBoxItem = nil
	self.LuaListView_MailBox:updateItems(0)
	g_MsgMgr:ignoreCheckWaitTime(nil)
	g_FormMsgSystem:UnRegistFormMsg(FormMsg_MailBox_Info)

	--add by zgj
	if #g_Mail.tb_ConfigMgrMailItem > g_Mail.max then
		g_DbMgr:exec("delete from "..g_Mail.tableName.." where id < "..g_Mail.tb_ConfigMgrMailItem[g_Mail.max].mail_id)
	end
	--over
end

function Game_MailBox:setMailBoxInfo()
	g_MsgMgr:ignoreCheckWaitTime(true)
    if g_bReturn  then  return  end
	if self.curMailBoxItem then
		self.curMailBoxItem = nil
	end
	
	if next(g_Mail.tb_ConfigMgrMailItemById) == nil then
		self.Image_MailIsEmpty:setVisible(true)
		self:setMailBoxContentPNL(1)
	else
		self.Image_MailIsEmpty:setVisible(false)
	end
	if g_Mail.update == true then
		self:setConfigMgrMailItem()
		g_Mail.update = false	
	end
	self.LuaListView_MailBox:updateItems(#g_Mail.tb_ConfigMgrMailItem)
end

function Game_MailBox:initBaseInfo()
	-- add by zgj
	g_Mail = {
		tb_ConfigMgrMailItem = {},
		tb_ConfigMgrMailItemById = {},
		firstOpen = false,
		update = true
	}
	g_Mail.max = g_DataMgr:getCsvConfigByTwoKey("GlobalCfg", 73, "Data")

    if not g_Mail.firstOpen then
		g_Mail.firstOpen = true
		g_Mail.tableName = "mail_"..g_MsgMgr:getUin()
		g_DbMgr:exec("create table if not exists "..g_Mail.tableName..[[ (
					id INTEGER PRIMARY KEY, 
					buffer TEXT)
				]])
		local db = g_DbMgr:getDB()
		for row in db:nrows("SELECT * FROM "..g_Mail.tableName) do
			local getMailFunc = loadstring("return "..row.buffer)
	        if getMailFunc then
				local tb = getMailFunc()
				tb.gain_flag = 1
				g_Mail.tb_ConfigMgrMailItemById[tb.mail_id] = tb
				--if tb.gain_flag == 0 then
					--g_Hero:addBubbleNotify("mail", 1)
				--end
			end
		end
	end	
end

function Game_MailBox:ModifyWnd_viet_VIET()
    local Label_TitleLB = self.rootWidget:getChildAllByName("Label_TitleLB")
	local Label_Title = self.rootWidget:getChildAllByName("Label_Title")
    g_AdjustWidgetsPosition({Label_TitleLB, Label_Title}, 3)
end