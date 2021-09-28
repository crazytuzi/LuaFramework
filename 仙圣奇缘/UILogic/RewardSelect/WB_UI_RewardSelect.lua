--------------------------------------------------------------------------------------
-- 文件名:	WB_UI_BaXianFilter.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	
-- 日  期:	
-- 版  本:	1.0
-- 描  述:	奖励选择界面
-- 应  用:  本例子是用类对象的方式实现
---------------------------------------------------------------------------------------
function onClick_Button_Confirm()
    g_RewardSelectSys:SendUseSelectItemRequest()
    g_WndMgr:closeWnd("Game_RewardSelectBox")
end


Game_RewardSelectBox = class("Game_RewardSelectBox")
Game_RewardSelectBox.__index = Game_RewardSelectBox

function Game_RewardSelectBox:ctor()

end

g_LuaListView_RewardSelectBox_Index = 1
function Game_RewardSelectBox:initWnd()
	g_LuaListView_RewardSelectBox_Index = 1
end

function Game_RewardSelectBox:releaseWnd()

end

function Game_RewardSelectBox:openWnd()
	if g_bReturn then
		return
	end
    --选择个数label
    local Label_SelectTip = tolua.cast(self.rootWidget:getChildAllByName("Label_SelectTip"), "Label")
    local strTmp = string.format(_T("请选择%d种奖励领取"), g_RewardSelectSys.MustSelcetCnt)
    Label_SelectTip:setText(strTmp)
    
    --初始化listviewEx
    local ListView_RewardItems = tolua.cast(self.rootWidget:getChildAllByName("ListView_RewardItems"), "ListViewEx")
	local Panel_RewardItem = tolua.cast(ListView_RewardItems:getChildByName("Panel_RewardItem"), "Layout")
	local function updataRewardList(widget,nIndex)
		self:setListViewRewardItem(widget,nIndex)
	end
	
	local function onAdjustListView(widget, nIndex)
		g_LuaListView_RewardSelectBox_Index = nIndex
    end
	self.ListView_RewardItems = registerListViewEvent(ListView_RewardItems, Panel_RewardItem, updataRewardList, nil, onAdjustListView)
    --按钮响应
    self.Button_Confirm = tolua.cast(self.rootWidget:getChildAllByName("Button_Confirm"), "Button")
    g_SetBtn(self.rootWidget, "Button_Confirm", onClick_Button_Confirm, true)--  
    self.Button_Confirm:setTouchEnabled(false)
    g_SetBtnBright(self.Button_Confirm, false)
    
    --刷新listview
	g_LuaListView_RewardSelectBox_Index = g_LuaListView_RewardSelectBox_Index or 1
    self.ListView_RewardItems:updateItems(#g_RewardSelectSys.RewardList, g_LuaListView_RewardSelectBox_Index)
end

function Game_RewardSelectBox:closeWnd()

end

function Game_RewardSelectBox:setListViewRewardItem(widget, nIndex)
	local tbDrop = g_RewardSelectSys.RewardList[nIndex]
    if tbDrop  == nil then return end

	local itemModel = g_CloneDropItemModel(tbDrop)
	if itemModel then
		local Image_ItemPNL = tolua.cast(widget:getChildByName("Image_ItemPNL"), "ImageView")
		Image_ItemPNL:removeAllChildren()
		
        local CheckBox_Check = tolua.cast(widget:getChildByName("CheckBox_Check"), "CheckBox")
        CheckBox_Check:setSelectedState(tbDrop.bSelect)
        CheckBox_Check:setTouchEnabled(false)

		Image_ItemPNL:addChild(itemModel)
		itemModel:setPosition(ccp(0,0))
		itemModel:setScale(0.9)
		
		local function onClick(pSender, eventType)

            local bSelect = g_RewardSelectSys:changeRewardItemSelect(pSender:getTag())
            --[[if bSelect then 
                local Parent = pSender:getParent()
                local CheckBox_Check = tolua.cast(Parent:getChildAllByName("CheckBox_Check"), "CheckBox")
                CheckBox_Check:setSelectedState(bSelect)
            --end]]
            --设置按钮状态
            if g_RewardSelectSys:getSelectItemCnt() == g_RewardSelectSys.MustSelcetCnt then
                self.Button_Confirm:setTouchEnabled(true)
                g_SetBtnBright(self.Button_Confirm, true)
            else
                self.Button_Confirm:setTouchEnabled(false)
                g_SetBtnBright(self.Button_Confirm, false)
            end
            for i = 0, self.ListView_RewardItems:getChildrenCount()-1 do
                local item = tolua.cast(self.ListView_RewardItems:getChildByIndex(i), "Layout")
                local CheckBox_Check = tolua.cast(item:getChildAllByName("CheckBox_Check"), "CheckBox")
                local Button_Select = tolua.cast(item:getChildByName("Button_Select"), "Button")
                local BitmapLabel_FuncName = tolua.cast(Button_Select:getChildByName("BitmapLabel_FuncName"), "LabelBMFont")
                local tbDrop = g_RewardSelectSys.RewardList[Button_Select:getTag()]--[i+1]
                CheckBox_Check:setSelectedState(tbDrop.bSelect)
                if tbDrop.bSelect then
                    BitmapLabel_FuncName:setText(_T("取消"))
                else
                    BitmapLabel_FuncName:setText(_T("选择"))
                end
            end

		end
        local Button_Select = tolua.cast(widget:getChildByName("Button_Select"), "Button")
        g_SetBtnWithPressImage(Button_Select, nIndex, onClick, true)
        local BitmapLabel_FuncName = tolua.cast(Button_Select:getChildByName("BitmapLabel_FuncName"), "LabelBMFont")
                if tbDrop.bSelect then
            BitmapLabel_FuncName:setText(_T("取消"))
        else
            BitmapLabel_FuncName:setText(_T("选择"))
        end

        local function onClickitemModel(pSender, eventType)
		    if eventType == ccs.TouchEventType.ended then
			    g_ShowDropItemTip(tbDrop)
			end
		end
		itemModel:setTouchEnabled(true)
		itemModel:addTouchEventListener(onClickitemModel)
	end
end

function Game_RewardSelectBox:showWndOpenAnimation(funcWndOpenAniCall)
	local Image_RewardSelectBoxPNL = tolua.cast(self.rootWidget:getChildByName("Image_RewardSelectBoxPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIAppearAnimation_Scale(Image_RewardSelectBoxPNL, funcWndOpenAniCall, 1.05, 0.2, Image_Background)
end

function Game_RewardSelectBox:showWndCloseAnimation(funcWndCloseAniCall)
	local Image_RewardSelectBoxPNL = tolua.cast(self.rootWidget:getChildByName("Image_RewardSelectBoxPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIDisappearAnimation_Scale(Image_RewardSelectBoxPNL, funcWndCloseAniCall, 1.05, 0.2, Image_Background)
end

