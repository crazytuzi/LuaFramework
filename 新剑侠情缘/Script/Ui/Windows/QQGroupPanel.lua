local tbUi = Ui:CreateClass("QQGroupPanel");

function tbUi:OnOpen(tbGroupList)
	if not next(tbGroupList) then
		me.MsgBox("暂无可绑定Q群，是否创建Q群并绑定？", {{"是", function ()
			Kin:BindQQGroupRemote(true);
		end}, {"否"}});
		return 0;
	end
end

function tbUi:OnOpenEnd(tbGroupList)
	self.szGroupName = nil;
	self.szGroupNumber = nil;

	self:Update(tbGroupList);
end

function tbUi:Update(tbGroupList)
	local function fnSetItem(itemObj, nIdx)
		local tbItem = tbGroupList[nIdx];
		itemObj.pPanel:Label_SetText("TxtGroupNum", tbItem.gc);
		itemObj.pPanel:Label_SetText("TxtGroupName", tbItem.group_name);
		itemObj.pPanel:Button_SetCheck("Main", tbItem.gc == self.szGroupNumber);
		itemObj.pPanel.OnTouchEvent = function ()
			self.szGroupNumber = tbItem.gc;
			self.szGroupName = tbItem.group_name;
			itemObj.pPanel:Button_SetCheck("Main", true);
		end
	end

	self.ScrollView:Update(tbGroupList, fnSetItem);
end

tbUi.tbOnClick = tbUi.tbOnClick or {};

function tbUi.tbOnClick:BtnSure()
	if not self.szGroupNumber then
		me.MsgBox("没有选择Q群，是否创建Q群并绑定？", {{"确认", function ()
			self.tbOnClick.BtnCreat(self);
		end}, {"取消"}});
		return;
	end

	local szMsg = string.format("确认绑定Q群：%s?", self.szGroupName);
	me.MsgBox(szMsg, {{"确认", function ()
		Kin:BindQQGroupRemote(false, self.szGroupNumber, self.szGroupName);
		Ui:CloseWindow(self.UI_NAME);
	end}, {"取消"}});
end

function tbUi.tbOnClick:BtnCreat()
	Kin:BindQQGroupRemote(true);
	Ui:CloseWindow(self.UI_NAME);
end

function tbUi.tbOnClick:BtnClose()
	Ui:CloseWindow(self.UI_NAME);
end