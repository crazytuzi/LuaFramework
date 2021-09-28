--------------------------------------------------------------------------------------
-- 文件名:	XXX.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	周光剑
-- 日  期:	2015-6-9
-- 版  本:	1.0
-- 描  述:	活动模版类
-- 应  用:  
---------------------------------------------------------------------------------------

Act_Template2 = class("Act_Template2")
Act_Template2.__index = Act_Template2

--角标文字的前缀后缀
Act_Template2.prefix = ""
Act_Template2.suffix = ""

function Act_Template2:sortAndUpdate()
	table.sort(self.tbItemList, function (a, b)
		if not self.tbMissions then
			return false
		end
		local state_a = self.tbMissions[a.ID]
		if not state_a then return false end
		local state_b = self.tbMissions[b.ID]
		if not state_b then return false end
		if state_a == state_b then
			return a.ID < b.ID
		else
			return state_a > state_b
		end
	end)
	if self.ListView_Activety and self.ListView_Activety:isExsit() then
		self.ListView_Activety:updateItems(math.ceil(#self.tbItemList/3))
	end
end

--领取响应回调
function Act_Template2:gainRewardResponseCB()
	self:sortAndUpdate()
end

--按钮事件
function Act_Template2:onClickGainReward(widget, nTag)
	local msg = zone_pb.AOLRewardRequest()
	msg.type = self.nActivetyID
	msg.mission_id = self.tbItemList[nTag]["ID"]
	g_MsgMgr:sendMsg(msgid_pb.MSGID_AOL_REWARD_REQUEST,msg)
	g_act:setRewardResponseCB(handler(self,self.gainRewardResponseCB))
end

pszBlackWhiteFSH =
[[
	#ifdef GL_ES                                
	precision mediump float;                    
	#endif                                      
	uniform sampler2D u_texture;                
	varying vec2 v_texCoord;                    
	varying vec4 v_fragmentColor;               
	void main(void)                              
	{                                           
	 // Convert to greyscale using NTSC weightings               
		vec4 col = texture2D(u_texture, v_texCoord);                
		float grey = dot(col.rgb, vec3(0.5, 0.5, 0.5));       
		gl_FragColor = vec4(grey / 2.0, grey / 2.0, grey / 2.0, col.a);               
	}                                           

]]

function Act_Template2:setButtonBright(Button_Activety, nIndex, bBright)
	local Image_Icon = tolua.cast(Button_Activety:getChildByName("Image_Icon"), "ImageView")
	local Image_Check = tolua.cast(Button_Activety:getChildByName("Image_Check"), "ImageView")
	local btnImage_path = getImgByPath(self.tbItemList[nIndex]["ActivityIconPath"], self.tbItemList[nIndex]["ActivityIconBase"])
	if bBright then
		Button_Activety:loadTextures(btnImage_path, btnImage_path, btnImage_path)
		Image_Check:loadTexture(btnImage_path)
		g_setImgShader(Image_Icon, pszNormalFragSource)
	else
		Button_Activety:loadTextures(getShopMallImg("VIPRightBase_Disabled"), getShopMallImg("VIPRightBase_Disabled"), getShopMallImg("VIPRightBase_Disabled"))
		Image_Check:loadTexture(getShopMallImg("VIPRightBase_Disabled"))
		g_setImgShader(Image_Icon, pszBlackWhiteFSH)
	end
end

function Act_Template2:setButtonState(Button_Activety, nIndex)
	local Image_Locker = Button_Activety:getChildByName("Image_Locker")
	local state = self.tbMissions[self.tbItemList[nIndex]["ID"]]
	if Image_Locker then
		Image_Locker:setVisible(ActState.DOING == state)
	end
	
	if ActState.INVALID == state then --已领取
		Button_Activety:setTouchEnabled(true)
		self.tbButtonEnable[nIndex] = false
		self:setButtonBright(Button_Activety, nIndex, false)
	elseif ActState.DOING == state then --未达到条件
		Button_Activety:setTouchEnabled(true)
		self.tbButtonEnable[nIndex] = false
		self:setButtonBright(Button_Activety, nIndex, true)
	elseif ActState.FINISHED == state then --可领取
		Button_Activety:setTouchEnabled(true)
		self.tbButtonEnable[nIndex] = true
		self:setButtonBright(Button_Activety, nIndex, true)
	end
end

--设置每个按钮列表项
function Act_Template2:setPanelItem(widget,nRow)
	local Button_Activety = tolua.cast(widget:getChildByName("Button_Activety"), "Button") 
	for i = 1, 3 do
		repeat 
			local nIndex = (nRow - 1) * 3 + i
			if i ~= 1 then
				local buttonItem = widget:getChildByName("Button_Activety"..i)
				if not buttonItem then
					buttonItem = Button_Activety:clone()
					widget:addChild(buttonItem, 1)
					buttonItem:setName("Button_Activety"..i)
					buttonItem:setPositionX(buttonItem:getPositionX() + 230)
				end
				Button_Activety = buttonItem
				--越界隐藏
				if not self.tbItemList[nIndex] then
					Button_Activety:setVisible(false)
					break
				else
					Button_Activety:setVisible(true)
				end
				Button_Activety = tolua.cast(Button_Activety, "Button")
			end
			
			self:setButtonState(Button_Activety, nIndex)
			
			local Image_Icon = tolua.cast(Button_Activety:getChildByName("Image_Icon"), "ImageView")
			Image_Icon:loadTexture(getImgByPath(self.tbItemList[nIndex]["ActivityIconPath"], self.tbItemList[nIndex]["ActivityIcon"]))
			Image_Icon:setScale(self.tbItemList[nIndex]["ActivityIconScale"]/ 100)

			local Lable_NeedValue = tolua.cast(Button_Activety:getChildByName("Label_NeedValue"), "Label")
			if Lable_NeedValue then
				Lable_NeedValue:setText(self.prefix..self.tbItemList[nIndex]["NeedValue"]..self.suffix)
				if eLanguageVer.LANGUAGE_viet_VIET == g_LggV:getLanguageVer() then
					Lable_NeedValue:setFontSize(18)
				end
			end

			local Label_RewardName = tolua.cast(Button_Activety:getChildByName("Label_RewardName"), "Label")
			if Label_RewardName then
				Label_RewardName:setText(self.tbItemList[nIndex]["ActivityName"])
				if eLanguageVer.LANGUAGE_viet_VIET == g_LggV:getLanguageVer() then
					Label_RewardName:setFontSize(16)
					Label_RewardName:setText(g_stringSize_insert(self.tbItemList[nIndex]["ActivityName"],"\n",16,200))
				end
				local CCNode_RewardName = tolua.cast(Label_RewardName:getVirtualRenderer(), "CCLabelTTF")
				CCNode_RewardName:disableShadow(true)
			end
			
			local Label_RewardNum = tolua.cast(Button_Activety:getChildByName("Label_RewardNum"), "Label")
			if Label_RewardNum then
				local CSV_DropSubPackClient = g_DataMgr:getCsvConfig_FirstAndSecondKeyData("DropSubPackClient", self.tbItemList[nIndex]["DropClientID"], 1)
				Label_RewardNum:setText("x"..CSV_DropSubPackClient["DropItemNum"])
				
				Image_Icon:removeAllChildren()
				Image_Icon:loadTexture(getUIImg("Blank"))
				local itemModel, tbCsvBase = g_CloneDropRewardModel(CSV_DropSubPackClient)
				itemModel:setPositionXY(0, 0)
				local fScale = itemModel:getScale()
				itemModel:setScale(fScale * 1.8)
				Image_Icon:addChild(itemModel)
				
				local Label_RewardName = tolua.cast(Button_Activety:getChildByName("Label_RewardName"), "Label")
				if Label_RewardName then
					Label_RewardName:setText(tbCsvBase.Name)
					if eLanguageVer.LANGUAGE_viet_VIET == g_LggV:getLanguageVer() then
						Label_RewardName:setText(g_stringSize_insert(tbCsvBase.Name,"\n",16,200))
					end
					local CCNode_RewardName = tolua.cast(Label_RewardName:getVirtualRenderer(), "CCLabelTTF")
					CCNode_RewardName:disableShadow(true)
				end
			end
			
		until true
	end
end


--活动是否有效
function Act_Template2:isEnable(id)
	self.nActivetyID = id
	self.tbMissions = g_act:getMissionsByID(id)
	
	-- 活动测试
	if g_Cfg.Platform == kTargetWindows then
		-- if (
			-- id == 1 or
			-- id == 3 or
			-- id == 5 or
			-- id == 6 or
			-- id == 7 or
			-- id == 8 or
			-- id == 9 or
			-- id == 10 or
			-- id == 11 or
			-- id == 12 or
			-- id == 13 or
			-- id == 14 or
			-- id == 15 or
			-- id == 16 or
			-- id == 17 or
			-- id == 18 or
			-- id == 19 or
			-- id == 20 or
			-- id == 21 or
			-- id == 22 or
			-- id == 23 or
			-- id == 24 or
			-- id == 25 or
			-- id == 26 or
			-- id == 27 or
			-- id == 28
		-- ) then
			-- self.tbMissions = {}
			-- for i = 1, 30 do
				-- table.insert(self.tbMissions, 1)
			-- end
		-- end
    end
	
	if not self.tbMissions then
		--测试用
		-- self.tbMissions = {}
		-- for i = 1,20 do
		-- 	table.insert(self.tbMissions, 1)
		-- end
		return false
	else
		return true
	end
end

--初始化
function Act_Template2:init(panel, tbItemList)
	if not panel then
		return 
	end
	self.tbButtonEnable = {}

	self.tbItemList = tbItemList
	self.ListView_Activety = tolua.cast(panel:getChildByName("ListView_Activety"), "ListViewEx")
	local item = self.ListView_Activety:getChildByName("Panel_Activety")
	local function updateFunc(widget,index)
		return self:setPanelItem(widget, index)
	end
	registerListViewEvent(self.ListView_Activety, item, updateFunc)
	self:sortAndUpdate()
	
	local imgScrollSlider = self.ListView_Activety:getScrollSlider()
	if not g_tbScrollSliderXY.ListView_Activety_X then
		g_tbScrollSliderXY.ListView_Activety_X = imgScrollSlider:getPositionX()
	end
	imgScrollSlider = imgScrollSlider:setPositionX(g_tbScrollSliderXY.ListView_Activety_X - 10)
    g_act:resetBubbleById(self.nActivetyID) --重置可领取奖励个数
end

--析构
function Act_Template2:destroy()
end